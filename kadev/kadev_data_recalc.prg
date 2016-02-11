/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */




#include "kadev.ch"


// -------------------------------------------------
// rekalkulacija statusa
// -------------------------------------------------
function kadev_recalc()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. rekalkulacija statusa                       " )
AADD( _opcexe, {|| kadev_rekstatall() } )
AADD( _opc, "2. rekalkulacija radnog staza  " )
AADD( _opcexe, {|| kadev_rekrstall() } )

f18_menu( "recl", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()

return


static function _o_tables()

O_KADEV_1
O_KADEV_0
O_KADEV_PROMJ
O_KBENEF
O_KDV_RJRMJ
O_KDV_RRASP

select kadev_1
set order to tag "1"
select kadev_promj
set order to tag "ID"
select kbenef
set order to tag "ID"
select kdv_rjrmj
set order to tag "ID"
select kdv_rrasp
set order to tag "ID"

select kadev_1
set relation to idpromj into kadev_promj
set relation to idrj+idrmj into kdv_rjrmj addi

select kadev_0
set relation to idrrasp into kdv_rrasp

return




function kadev_rekstatall()
local nOldArr
local _postotak := ( gPostotak == "D" )
local _radn_id := SPACE(13)

O_KADEV_0

PushWA()
nOldArr := SELECT()

_o_tables()

dDoDat := DATE()

Box("b0XX", 2, 65,.f.)  
    set cursor on
    @ m_x + 1, m_y + 2 SAY "Radnik (prazno-svi):" GET _radn_id VALID EMPTY( _radn_id ) .or. kadev_radnik_postoji( _radn_id )
    @ m_x + 2, m_y + 2 SAY "Kalkulacija do datuma:" GET dDoDat
    read
BoxC()

if LastKey() == K_ESC
    my_close_all_dbf()
    return
endif

select ( nOldArr )
go top

if _postotak
    Postotak( 1, RECCOUNT2(), "Rekalkulisanje statusa" )
else
    Box( "b0XY", 1, 55, .f. )
endif

n1 := 0

if !f18_lock_tables( { "kadev_0", "kadev_1" } )
    return
endif

sql_table_update( NIL, "BEGIN" )

select kadev_0

if !EMPTY( _radn_id )

    set order to tag "1"
    go top
    seek _radn_id

    if !FOUND()
        MsgBeep( "Nisam pronasao radnika !" )
        return
    endif

endif

do while !EOF() .and. IF( !EMPTY( _radn_id ), field->id == _radn_id, .t.  ) 
    
    if !_postotak
        @ m_x + 1, m_y + 2 SAY kadev_0->( id + ": " + prezime + " " + ime )
    else
        Postotak( 2, ++n1 )
    endif
    
    select kadev_1
    seek kadev_0->id
    
    if !RekalkStatus( dDoDat )
        f18_free_tables( { "kadev_0","kadev_1" } )
        sql_table_update( NIL, "ROLLBACK" )
        PopWa()
        my_close_all_dbf()
        return
    endif

    select ( nOldArr )
    skip

enddo

f18_free_tables( { "kadev_0","kadev_1" } )
sql_table_update( NIL, "END" )

if _postotak
    Postotak(0)
else
    BoxC()
endif

PopWa()

my_close_all_dbf()
return




function RekalkStatus( dDoDat )
local _int_status := " "     
// intervalni status (kod nezavrsenih interv.promjena)
local _ok := .f.
local _rec_0, _rec_1

// kadev_1 tabela
select kadev_0

_rec_0 := dbf_get_rec()
_rec_0["status"] := ""
_rec_0["idrj"] := ""
_rec_0["idrmj"] := ""
_rec_0["daturmj"] := CTOD("")
_rec_0["datvrmj"] := CTOD("")
_rec_0["idrrasp"] := ""
_rec_0["slvr"] := ""
_rec_0["vrslvr"] := 0
_rec_0["idstrspr"] := ""
_rec_0["datuf"] := CTOD("")
_rec_0["idzanim"] := ""

select kadev_1

do while field->id = kadev_0->id .and. ( field->datumod < dDoDat )

    select kadev_promj
    HSEEK kadev_1->idpromj

    select kadev_1

    // kadev_1 tabela
    _rec_1 := dbf_get_rec()
   
    if kadev_promj->tip <> "X" 
        _rec_0["status"] := kadev_promj->status
    endif

    if kadev_promj->srmj == "1"  
        // SRMJ=="1" - promjena radnog mjesta
        _rec_0["idrj"] := kadev_1->idrj
        _rec_0["idrmj"] := kadev_1->idrmj
        _rec_0["daturmj"] := kadev_1->datumod
        if empty( kadev_0->datUF )
            _rec_0["datuf"] := kadev_1->datumod
        endif
        _rec_0["datvrmj"] := CTOD("")
    else
        _rec_1["idrj"] := kadev_0->idrj
        _rec_1["idrmj"] := kadev_0->idrmj
    endif

    if kadev_promj->urrasp == "1" 
        // setovanje ratnog rasporeda
        _rec_0["idrrasp"] := cAtr1
    endif

    if kadev_promj->ustrspr == "1" 
        // setovanje strucne spreme
        _rec_0["idstrspr"] := cAtr1
        _rec_0["idzanim"] := cAtr2
    endif

    if kadev_promj->uradst = " " .and. kadev_promj->tip = " " 
        // fiksna promjena koja
        _rec_1["idrmj"] := ""
        _rec_1["idrj"] := ""
        _rec_0["datvrmj"] := kadev_1->datumod
    endif

    if kadev_promj->tip == "I"  

        // intervalna promjena
        if !( EMPTY( kadev_1->DatumDo ) .or. ( kadev_1->DatumDo > dDoDat )) 
            // zatvorena
            if kadev_promj->status = "M" .and. kdv_rrasp->catr = "V" 
                // catr="V" -> sluzenje vojnog roka
                _rec_0["slvr"] := "D"
                _rec_0["vrslvr"] := kadev_0->vrslvr + ( kadev_1->datumdo - kadev_1->datumod )
            endif
        endif

        if EMPTY( kadev_1->datumdo ) .or. ( kadev_1->datumdo > dDoDat )
            _rec_0["datvrmj"] := kadev_1->datumod
            _int_status := kadev_promj->status                  
        else   
            // vrsi se zatvaranje promjene
            if kadev_promj->urrasp = "1"  
                // ako je intervalna promjena setovala RRasp
                _rec_0["idrrasp"] := ""
            endif
            _rec_0["status"] := "A"
        endif
    endif

    // zatvori kadev_1 tabelu - azuriraj promjene
    if !update_rec_server_and_dbf( "kadev_1", _rec_1, 1, "CONT" )
        return _ok        
    endif

    skip

enddo

select kadev_0
// zatvori tabelu kadev_0 - azuriraj promjene
if !update_rec_server_and_dbf( "kadev_0", _rec_0, 1, "CONT" )
    return _ok        
endif

select kadev_1

_ok := .t.
return _ok


// lPom=.t. -> radni staz u firmi zapisuj u POM.DBF, a ne diraj KADEV_0.DBF
function kadev_rekrstall( lPom )
local nOldArr

IF lPom == NIL
    lPom :=.f.
ENDIF

O_KADEV_0

PushWA()
nOldArr:=SELECT()

O_KADEV_1
O_KADEV_PROMJ
O_KDV_RJRMJ
O_KDV_RRASP
O_KBENEF

select kadev_1
set order to tag "1"
select kadev_promj
set order to tag "ID"
select kdv_rjrmj
set order to tag "ID"
select kdv_rrasp
set order to tag "ID"
select kbenef 
set order to tag "ID"

// ovo je sumnjivo ??????? nesto ne radi kako treba
select kadev_1
set relation to idpromj into kadev_promj, to ( IdRj + IdRmj ) into kdv_rjrmj

select kdv_rjrmj
set relation to sbenefrst into kbenef

select kadev_0
set relation to idRrasp into kdv_rrasp

IF lPom
    dDoDat := DATE()      
    // ?
ELSE
    dDoDat:=DATE()
    Box("b0XX",1,65,.f.)
        set cursor on
        @ m_x+1,m_y+2 SAY "Kalkulacija do datuma:" GET dDoDat
        read
    BoxC()
    if lastkey()==K_ESC
        my_close_all_dbf()
        return
    endif
endif

select(nOldArr)
go top

IF gPostotak=="D"
  Postotak(1,RECCOUNT2(),"Rekalkulisanje radnog staza")
ELSE
  Box("b0XY",1,55,.f.)
ENDIF
n1:=0

// lock tables...
if !f18_lock_tables( { "kadev_0", "kadev_1" } )
    return
endif
sql_table_update( NIL, "BEGIN" )

do while !eof() 

    IF gPostotak!="D"
        @ m_x+1,m_y+2 SAY kadev_0->(id+": "+prezime+" "+ime)
    ELSE
        Postotak(2,++n1)
    ENDIF
    
    select kadev_1
    seek kadev_0->id

    if !RekalkRSt(dDoDat,lPom)
        // otkljucaj tabele...
        f18_free_tables( { "kadev_0", "kadev_1" } )
        sql_table_update( NIL, "ROLLBACK" )
        my_close_all_dbf()
        return
    endif

    select(nOldArr)
    skip
enddo

// otkljucaj tabele...
f18_free_tables( { "kadev_0", "kadev_1" } )
sql_table_update( NIL, "END" )
 
IF gPostotak=="D"
  IF lPom
    Postotak(-1)
  ELSE
    Postotak(0)
  ENDIF
ELSE
  BoxC()
ENDIF

PopWa()

my_close_all_dbf()

return



function RekalkRst( dDoDat, lPom )
local nArr := 0
local nRStUFe := 0
local nRStUFb := 0
local _ok := .f.
  
if lPom == NIL 
    lPom := .f.
endif
  
nRstE := 0
nRstB := 0
KBfR := 0
dOdDat := CTOD("")
fOtvoreno := .f.
  
do while id == kadev_0->id .and. ( DatumOd < dDoDat )

    select kadev_promj
    HSEEK kadev_1->idpromj

    select kadev_1

    if kadev_promj->Tip = "X" .and. kadev_promj->URadSt = "="
        nRstE   := nAtr1
        nRstB   := nAtr2
        nRstUFe := nAtr1
        nRstUFb := nAtr2
    endif

    if kadev_promj->Tip = "X" .and. kadev_promj->URadSt = "+"
        nRstE   += nAtr1
        nRstB   += nAtr2
        nRstUFe += nAtr1
        nRstUFb += nAtr2
    endif

    if kadev_promj->Tip = "X" .and. kadev_promj->URadSt = "-"
        nRstE-=nAtr1
        nRstB-=nAtr2
    endif

    if kadev_promj->Tip = "X" .and. kadev_promj->URadSt = "A"
        nRstE := ( nRstE + nAtr1 ) / 2
        nRstB := ( nRstB+nAtr2 ) / 2
    endif

    if kadev_promj->Tip = "X" .and. kadev_promj->URadSt = "*"
        nRstE := nRstE * nAtr1
        nRstB := nRstB * nAtr2
    endif

    if kadev_promj->Tip == "X" 
        // ignorisi ovu promjenu
        skip
        loop
    endif

    if fOtvoreno

        nPom := ( DatumOd - dOdDat )
        nPom2 := nPom * kBfR / 100
        
        if nPom < 0 .and. kadev_promj->tip=="I"      
            // .and. ... dodao MS 18.9.00.
            MsgO("Neispravne promjene kod "+kadev_0->prezime+" "+kadev_0->ime)
            Inkey(0)
            MsgC()
            return _ok
        else
            nRstE += nPom
            nRstB += nPom2
        endif

    endif

    if kadev_promj->Tip == " " .and. kadev_promj->URadSt $ "12" 
        //postavljenja,....
        dOdDat := DatumOd          
        // otpocinje proces kalkulacije
        if kadev_promj->URadSt == "1"
            KBfR := kbenef->iznos
        else   // za URadSt = 2 ne obracunava se beneficirani r.st.
            KBfR := 0
        endif
        fOtvoreno := .t.     // Otvaram pocetak trajanja promjene ....
    else
        fOtvoreno := .f.
    endif

    if kadev_promj->Tip == "I" .and. kadev_promj->URadSt==" "
        if empty(DatumDo)  // otvorena intervalna promjena koja se ne uracunava
            fOtvoreno:=.f.   // u radni staz - znaci nema vise
        else
            fOtvoreno:=.t.
            dOdDat:=iif(DatumDo>dDoDat,dDoDat,DatumDo) // ako je DatumDo unutar
            // promjene veci od Datuma kalkulacije onda koristi dDoDat
            KBfR:=kbenef->iznos
        endif
    endif

    if kadev_promj->Tip=="I" .and. kadev_promj->URadSt $ "12"
        nPom:=iif(empty(DatumDo),dDoDat,if(DatumDo>dDoDat,dDoDat,DatumDo))-DatumOd
        if kadev_promj->URadSt=="1"
            nPom2:=nPom*kbenef->iznos/100
        else   // za URadSt = 2 ne obracunava se beneficirani r.st.
            nPom2:=0
        endif
        if nPom<0
            MsgO("Neispravne intervalne promjene kod "+kadev_0->prezime+" "+kadev_0->ime)
            Inkey(0)
            MsgC()
            BoxC()
            return
        else
            nRstE+=nPom
            nRstB+=nPom2
            fOtvoreno:=.t.
            dOdDat:=iif(empty(DatumDo),dDoDat,iif(DatumDo>dDoDat,dDoDat,DatumDo))
            KBfR:=kbenef->iznos
        endif
    endif
    skip
enddo
  
if fOtvoreno
    nPom:=(dDoDat-dOdDat)
    nPom2:=nPom*kBfR/100
    if nPom<0
        MsgO("Neispravne promjene ili dat. kalkul. za "+kadev_0->prezime+" "+kadev_0->ime)
        Inkey(0)
        MsgC()
        BoxC()
        return _ok
    else
        nRstE+=nPom
        nRstB+=nPom2
    endif
endif

_t_area := SELECT()

if lPom
    
    SELECT (F_POM)
    APPEND BLANK
    REPLACE ID WITH KADEV_0->ID        ,;
               RADSTE WITH nRstE-nRStUFe  ,;
               RADSTB WITH nRstB-nRStUFb  ,;
               STATUS WITH KADEV_0->STATUS

    select ( _t_area )

else

    select kadev_0

    _rec_0 := dbf_get_rec()
    _rec_0["radste"] := nRstE
    _rec_0["radstb"] := nRstB

    if !update_rec_server_and_dbf( "kadev_0", _rec_0, 1, "CONT" )
        return _ok
    endif
    
    select ( _t_area )
  
endif

_ok := .t.

return _ok



