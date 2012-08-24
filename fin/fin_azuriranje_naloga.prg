/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

static lIzgenerisi := .f.
static cNal


// ---------------------------------------------------
// ---------------------------------------------------
function fin_azur(lAuto)
local oServer := pg_server()
local _nalozi, _i
local _id_firma, _id_vn, _br_nal 

if Logirati(goModul:oDataBase:cName,"DOK", "AZUR")
    lLogAzur:=.t.
else
    lLogAzur:=.f.
endif

if (lAuto==NIL)
    lAuto:=.f.
endif

o_fin_za_azuriranje()

if fin_pripr->( RECCOUNT() == 0 ) .or. ( !lAuto .and. Pitanje("pAz", "Izvrsiti azuriranje fin naloga ? (D/N)?", "N") == "N" )
    return
endif

select fin_pripr
go top

// postoji li nalog na serveru ?
if fin_doc_exist( fin_pripr->idfirma, fin_pripr->idvn, fin_pripr->brnal )
    MsgBeep( "Nalog " + fin_pripr->idfirma + "-" + fin_pripr->idvn + "-" + fin_pripr->brnal + ;
        " vec postoji u bazi!#Promijenite broj naloga pa ponovite proceduru." )
    return .f.
endif

// daj mi sve naloge iz pripreme u matricu...
// za azuriranje vise naloga od jednom...
// to-do
//_nalozi := get_fin_nalozi()

if !fin_azur_check(lAuto)
   return .f.
endif

MsgO( "Azuriranje dokumenta u toku...." )

if fin_azur_sql(oServer)
    o_fin_za_azuriranje()
    if !fin_azur_dbf(lAuto)
        msgc()
        MsgBeep("Neuspjesno FIN/DBF azuriranje !?")
        return .f.
   endif
else
    MsgC()
    MsgBeep("Neuspjesno FIN/SQL azuriranje !?")
    return .f.
endif

MsgC()

return .t.

// ------------------------------------------------
// popunjava sve u matricu iz pripreme
// ------------------------------------------------
static function get_fin_nalozi()
local _data := {}
local _scan

select fin_pripr
go top

do while !EOF()
    
    _scan := ASCAN( _data, { |var| var[1] == fin_pripr->idfirma .and. var[2] == fin_pripr->idvn .and. var[3] == fin_pripr->brnal  })
    
    if _scan == 0
        AADD( _data, { fin_pripr->idfirma, fin_pripr->idvn, fin_pripr->brnal } )
    endif

    skip
enddo

go top

return _data


// -----------------------------
// -----------------------------
function o_fin_za_azuriranje()

// otvori tabele
close all

my_use_semaphore_off()

O_KONTO
O_PARTN
O_FIN_PRIPR
O_SUBAN
O_ANAL
O_SINT
O_NALOG

O_PSUBAN
O_PANAL
O_PSINT
O_PNALOG

my_use_semaphore_on()
return


// ----------------------
// ----------------------
function fin_azur_sql( oServer )
local _ok := .t.
local _ids := {}
local _record
local _tmp_id
local _tmp_doc
local _ids_doc := {}
local _ids_tmp := {}
local _ids_suban := {}
local _ids_sint := {}
local _ids_anal := {}
local _ids_nalog := {}
local _tbl_suban
local _tbl_anal
local _tbl_sint
local _tbl_nalog
local _msg
local _i
local _n := 1

_tbl_suban := "fin_suban"
_tbl_anal  := "fin_anal"
_tbl_nalog := "fin_nalog"
_tbl_sint  := "fin_sint"

Box(, 5, 60 )

_tmp_id := "x"
  
if !f18_lock_tables({_tbl_suban, _tbl_anal, _tbl_sint, _tbl_nalog})
    MsgBeep("lock tabela neuspjesan, azuriranje prekinuto")
    return .f.
endif

sql_table_update( nil, "BEGIN" )

SELECT PSUBAN
GO TOP

_record := dbf_get_rec()
// algoritam 2 - dokument nivo
_tmp_id := _record["idfirma"] + _record["idvn"] + _record["brnal"]
AADD( _ids_suban, "#2" + _tmp_id )

@ m_x+1, m_y+2 SAY "fin_suban -> server: " + _tmp_id 

do while !EOF()

    _record := dbf_get_rec()

    if !sql_table_update("fin_suban", "ins", _record )
        _ok := .f.
        exit
    endif

    SKIP
enddo


// idi dalje, na anal ... ako je ok
if _ok == .t.

    @ m_x+2, m_y+2 SAY "fin_anal -> server" 


    SELECT PANAL
    GO TOP

    _record := dbf_get_rec()
    _tmp_id := _record["idfirma"] + _record["idvn"] + _record["brnal"]
    AADD( _ids_anal, "#2" + _tmp_id )

    do while !eof()
        _record := dbf_get_rec()
        if !sql_table_update("fin_anal", "ins", _record )
            _ok := .f.
            exit
        endif
        SKIP
    enddo

endif


// idi dalje, na sint ... ako je ok
if _ok == .t.
  
    @ m_x+3, m_y+2 SAY "fin_sint -> server" 

    SELECT PSINT
    GO TOP

    _record := dbf_get_rec()
    _tmp_id := _record["idfirma"] + _record["idvn"] + _record["brnal"]
    AADD( _ids_sint, "#2" + _tmp_id )

    do while !eof()
 
        _record := dbf_get_rec()
        if !sql_table_update("fin_sint", "ins", _record )
            _ok := .f.
            exit
        endif
        SKIP
    enddo

endif

// idi dalje, na nalog ... ako je ok
if _ok == .t.
  
    @ m_x+4, m_y+2 SAY "fin_nalog -> server" 

    SELECT PNALOG
    GO TOP
 
    _record := dbf_get_rec()
    _tmp_id := _record["idfirma"] + _record["idvn"] + _record["brnal"]
    AADD( _ids_nalog, _tmp_id )

    do while !eof()
 
        _record := dbf_get_rec()
        if !sql_table_update("fin_nalog", "ins", _record )
            _ok := .f.
            exit
        endif
        SKIP
    enddo

endif

if !_ok

    _msg := "FIN azuriranje, trasakcija " + _tmp_id + " neuspjesna ?!"

    log_write( _msg, 2 )
    MsgBeep(_msg)
    // transakcija neuspjesna
    // server nije azuriran 
    sql_table_update(nil, "ROLLBACK" )
    f18_free_tables({_tbl_suban, _tbl_anal, _tbl_sint, _tbl_nalog})

else

    push_ids_to_semaphore( _tbl_suban , _ids_suban )
    push_ids_to_semaphore( _tbl_sint  , _ids_sint  )
    push_ids_to_semaphore( _tbl_anal  , _ids_anal  )
    push_ids_to_semaphore( _tbl_nalog , _ids_nalog )

    f18_free_tables({_tbl_suban, _tbl_anal, _tbl_sint, _tbl_nalog})

    sql_table_update(nil, "END")

endif

BoxC()

return _ok



// ---------------------------
// provjeri prije azuriranja
// ----------------------------
function fin_azur_check(lAuto)
local lAzur
local nSaldo
local cNal
local _t_area 

_t_area := SELECT()

select fin_pripr
go top

// provjeri da li je broj naloga zadovoljen
if LEN( ALLTRIM( field->brnal ) ) < 8
    // mora biti LEN = 8
    MsgBeep( "Broj naloga mora biti sa vodecim nulama !?!" )
    select ( _t_area )
    return .f.
endif

go top

// provjera rednih brojeva u nalogu
if !provjeri_redni_broj() 
    MsgBeep( "Redni brojevi naloga nisu ispravni !!!" )
    select ( _t_area )
    return .f.
endif

select ( _t_area )

// provjeri da li se u pripremi nalazi vise dokumenata... razlicitih
if _is_vise_dok() == .t.
    // provjeri za duple stavke prilikom azuriranja...
    if prov_duple_stavke() == 1 
        return .f.
    endif
    // nafiluj sve potrebne tabele
    stnal( .t. )
endif

lAzur:=.t.
select PSUBAN
if reccount2()==0
  lAzur:=.f.
endif

select PANAL
if reccount2()==0
  lAzur:=.f.
endif

select PSINT
if reccount2()==0
  lAzur:=.f.
endif

if !lAzur
  MsgBeep("Niste izvrsili stampanje naloga ...")
  close all
  return .f.
endif

SELECT PSUBAN
GO TOP
do while !eof()

    // prodji kroz PSUBAN i vidi da li je nalog zatvoren
    // samo u tom slucaju proknjizi nalog u odgovarajuce datoteke
    cNal := IDFirma+IdVn+BrNal
    nSaldo:=0
    do while !eof() .and. cNal == IdFirma + IdVn + BrNal

        if !psuban_partner_check()
            close all
            return .f.
        endif

        if !psuban_konto_check()
            close all
            return .f.
        endif

        select psuban
        if D_P=="1"
            nSaldo+=IznosBHD
        else
            nSaldo-=IznosBHD
        endif
        skip

    enddo

    if round(nSaldo,4)<>0 .and. gRavnot=="D"
        Beep(1)
        Msg("Neophodna ravnoteza naloga " + cNal + "##, azuriranje nece biti izvrseno!")
        return .f.
    endif


    if nalog_postoji_u_suban(cNal)
        log_write("nalog vec postoji u suban " + cNal, 5 )
        return .f.
    endif
   
    SELECT PSUBAN

enddo


select PSUBAN
set order to TAG "1"
go top

lIzgenerisi:=.f.
if reccount2() > 9999 .and. !lAuto
  if Pitanje(,"Staviti na stanje bez provjere ?","N")=="D"
    lIzgenerisi:=.t.
  endif
endif


return lAzur

// ------------------------
// azuriraj dbf-ove
// -----------------------
function fin_azur_dbf(lAuto)
local nC
local nTArea := SELECT()
local nSaldo

Box("ad", 10, MAXCOLS()-10)

if lLogAzur
    cOpis := fin_pripr->idfirma + "-" +  fin_pripr->idvn + "-" + fin_pripr->brnal

    EventLog(nUser, goModul:oDataBase:cName, "DOK", "AZUR", nil, nil, nil, nil, cOpis, "", "", fin_pripr->datdok, Date(), ;
              "", "Azuriranje dokumenta - poceo !")
endif

select PSUBAN
set order to tag "1"
go top


SELECT PSUBAN
GO TOP
do while !eof()

    // prodji kroz PSUBAN i vidi da li je nalog zatvoren
    // samo u tom slucaju proknjizi nalog u odgovarajuce datoteke
    cNal := IDFirma+IdVn+BrNal
    // ----------------------------------------------------
    // ----------------------------------------------------
    if preskoci_ako_nalog_ima_tacku_u_nazivu(cNal)
           LOOP
    endif

    @ m_x+1,m_y+2 SAY "Azuriram nalog: " + IdFirma + "-" + idvn + "-" + ALLTRIM(brnal)

    nSaldo := 0
    cEvIdFirma := idfirma
    cEvVrBrNal := idvn + "-" + brnal
    dDatNaloga := datdok
    dDatValute := datval

    do while !eof() .and. cNal == IdFirma + IdVn + BrNal
        select psuban
        if D_P=="1"
          nSaldo += IznosBHD
        else
           nSaldo -= IznosBHD
        endif
        skip
    enddo

    log_write( "azuriram fin nalog: " + cNal + " saldo " + STR(nSaldo, 17, 2), 5 )

    pnalog_nalog(cNal)
    panal_anal(cNal)
    psint_sint(cNal)
    psuban_suban(cNal)

    if lLogAzur
            fin_azur_event_log(nUser, nSaldo, dDatNalog, dDatValute, cEvidFirma, cEvVrBrNal) 
    endif

    fin_pripr_delete(cNal)
    select PSUBAN

enddo

BoxC()

select fin_pripr
__dbpack()

select PSUBAN
zap
select PANAL
zap
select PSINT
zap
select PNALOG
zap
close all

return .t.


// ----------------------------------------
// ----------------------------------------
function preskoci_ako_nalog_ima_tacku_u_nazivu(cNal)

IF "." $ cNal
        MsgBeep("Nalog " + IdFirma + "-" + idvn + "-" + (brnal) + " sadrzi znak '.' i zato nece biti azuriran!")
        DO WHILE !EOF() .and. cNal==IDFirma+IdVn+BrNal
            SKIP 1
        ENDDO
        return .t.
ENDIF

return .f.

// --------------------------------
// --------------------------------
function nalog_postoji_u_suban( cNal )

select  SUBAN
SET ORDER TO TAG "4"  
// "idFirma+IdVN+BrNal+Rbr"
seek cNal
if found()
    MsgBeep("Vec postoji u suban ? "+ IdFirma + "-" + IdVn + "-" + ALLTRIM(BrNal) + "  !")
    close all
    return .t.
endif

return .f.

// -----------------------------
// -----------------------------
function psuban_partner_check()

if !empty(psuban->idpartner)
      
    select partn
    hseek psuban->idpartner

    if !found() .and. !lIzgenerisi
      
        MsgBeep("Stavka br." + psuban->rbr + ": Nepostojeca sifra partnera!")

        IF PSUBAN->idvn=="00" .and. Pitanje( ,"Preuzeti nepostojecu sifru iz sezone?","N") == 'D'
          PreuzSezSPK("P")
        ELSE
          select PSUBAN
          zapp()
          select PANAL
          zapp()
          select PSINT
          zapp()
          close all
          return .f.
        ENDIF

     endif
endif

SELECT PSUBAN 
return .t.


function fin_azur_event_log(nUser, nSaldo, dDatNalog, dDatValute, cEvidFirma, cEvVrBrNal) 
local cOpis

cOpis := cEvIdFirma + "-" + cEvVrBrNal
EventLog(nUser, goModul:oDataBase:cName, "DOK", "AZUR", ;
            nSaldo, nil, nil, nil, ;
            cOpis, "", "", dDatNaloga, dDatValute, ;
            "", "Azuriranje dokumenta - zavrsio !!!")

return



// -----------------------------
// -----------------------------
function psuban_konto_check()

if !empty(psuban->idkonto)
    
    select konto
    hseek psuban->idkonto
    
    if !found() .and. !lIzgenerisi
        
        MsgBeep("Stavka br." + psuban->rbr + ": Nepostojeca sifra konta!")
        IF PSUBAN->idvn=="00" .and. Pitanje( ,"Preuzeti nepostojecu sifru iz sezone?","N") == 'D'
           PreuzSezSPK("K")
        ELSE
          select PSUBAN
          select PANAL
          select PSINT
          close all
          return .f.
        ENDIF
    endif
endif

SELECT PSUBAN
return .t. 

// -------------------
// -------------------
function panal_anal(cNal)
local _rec

@ m_x + 3, m_y+2 SAY "ANALITIKA       "
select PANAL
seek cNal
do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    
    _rec := dbf_get_rec()

    select ANAL

    APPEND BLANK

    dbf_update_rec(_rec, .f.)

    select PANAL
    skip
enddo

return

// -------------------
// -------------------
function psint_sint(cNal)
local _rec
  
@ m_x + 3, m_y + 2 SAY "SINTETIKA       "
select PSINT
seek cNal

do while !eof() .and. cNal == IdFirma + IdVn + BrNal

    _rec:= dbf_get_rec()

    select SINT

    APPEND BLANK
    dbf_update_rec(_rec, .f.)
    
    select PSINT
    skip
enddo

return


//-----------------------
//-----------------------
function pnalog_nalog(cNal)
local _rec

select PNALOG
seek cNal
if found()
    _rec := dbf_get_rec()
    select NALOG
 
    APPEND BLANK
    dbf_update_rec(_rec, .f.)

else
    Beep(4)
    Msg("Greska... ponovi stampu naloga ...")
endif

return

//-----------------------
//-----------------------
function psuban_suban(cNal)
local nSaldo :=0
local nC := 0
local _rec

@ m_x + 3, m_y + 2 SAY "SUBANALITIKA   "

SELECT SUBAN
SET ORDER TO TAG "3"
SELECT PSUBAN
SEEK cNal
  
nC := 0
do while !eof() .and. cNal == IdFirma + IdVn + BrNal

    @ m_x + 3, m_y + 25 SAY ++nC  pict "99999999999"

    _rec:= dbf_get_rec()
    
    if _rec["d_p"] == "1" 
          nSaldo:= _rec["iznosbhd"]
    else
          nSaldo:= -_rec["iznosbhd"]
    endif

    SELECT SUBAN
    SEEK _rec["idfirma"] + _rec["idkonto"] + _rec["idpartner"] + _rec["brdok"]    

    nRec := recno()
    do while  !eof() .and. (_rec["idfirma"] + _rec["idkonto"] + _rec["idpartner"] + _rec["brdok"]) == (IdFirma + IdKonto + IdPartner + BrDok)
       if _rec["d_p"] == "1"
           nSaldo += field->IznosBHD
       else
           nSaldo -= field->IznosBHD
       endif
       skip
    enddo

    if ABS(round(nSaldo, 3)) <= gnLOSt
       
        GO nRec
        do while  !EOF() .and. (_rec["idfirma"] + _rec["idkonto"] + _rec["idpartner"] + _rec["brdok"]) == (IdFirma + IdKonto + IdPartner + BrDok)
            
            _rec_2 := dbf_get_rec()
            _rec_2["otvst"] := "9"
            update_rec_server_and_dbf("fin_suban", _rec_2, 1, "FULL")
            SKIP

        enddo
        _rec["otvSt"] := "9"

    endif

    SELECT SUBAN    
    APPEND BLANK
    dbf_update_rec(_rec, .t.)

    select PSUBAN
    SKIP

enddo

return


// ------------------------------
// ------------------------------
function fin_pripr_delete(cNal)
local ntRec

// nalog je uravnotezen, moze se izbrisati iz PRIPR
select fin_pripr
seek cNal

@ m_x+3,m_y+2 SAY "BRISEM PRIPREMU "

do while !eof() .and. cNal==IdFirma+IdVn+BrNal
    skip
    ntRec:=RECNO()
    skip -1
    delete
    go ntRec
enddo

__dbPack()

return .t.

// -----------------------------------------------------------------
// provjerava da li u pripremi postoji vise razlicitih dokumenata
// -----------------------------------------------------------------
static function _is_vise_dok()
local lRet := .f.
local nTRec := RECNO()
local cBrNal 
local cTmpNal := "XXXXXXXX"

select fin_pripr
go top

cTmpNal := field->brnal

do while !EOF() 
    cBrNal := field->brnal
    if  cBrNal == cTmpNal 
        cTmpNal := cBrNal
        skip
        loop
    else
        lRet := .t.
        exit
    endif
enddo

return lRet


// ------------------------------------------------------------
// provjeri duple stavke u pripremi za vise dokumenata
// ------------------------------------------------------------
static function prov_duple_stavke() 
local cSeekNal
local lNalExist:=.f.

select fin_pripr
go top

// provjeri duple dokumente
do while !EOF()
    cSeekNal := fin_pripr->(idfirma + idvn + brnal)
    if dupli_nalog(cSeekNal)
        lNalExist := .t.
        exit
    endif
    
    select fin_pripr
    skip
enddo

// postoje dokumenti dupli
if lNalExist
    MsgBeep("U pripremi su se pojavili dupli nalozi !!!")
    if Pitanje(,"Pobrisati duple naloge (D/N)?", "D")=="N"
        MsgBeep("Dupli nalozi ostavljeni u tabeli pripreme!#Prekidam operaciju azuriranja!")
        return 1
    else
        Box(,1,60)
            cKumPripr := "P"
            @ m_x+1, m_y+2 SAY "Zelite brisati stavke iz kumulativa ili pripreme (K/P)" GET cKumPripr VALID !Empty(cKumPripr) .or. cKumPripr $ "KP" PICT "@!"
            read
        BoxC()
        
        if cKumPripr == "P"
            // brisi pripremu
            return prip_brisi_duple()
        else
            // brisi kumulativ
            return kum_brisi_duple()
        endif
    endif
endif

return 0

// ------------------------------------------------------------
// brisi stavke iz pripreme koje se vec nalaze u kumulativu
// ------------------------------------------------------------
static function prip_brisi_duple()
local cSeek
local _brisao := .f.

select fin_pripr
go top

do while !EOF()

    cSeek := fin_pripr->(idfirma + idvn + brnal)
    
    if dupli_nalog( cSeek )
        // pobrisi stavku
        select fin_pripr
        delete
        _brisao := .t.    
    endif
    
    select fin_pripr
    skip

enddo

if _brisao
    __dbPack()
endif

return 0


// -------------------------------------------------------------
// brisi stavke iz kumulativa koje se vec nalaze u pripremi
// -------------------------------------------------------------
static function kum_brisi_duple()
local cSeek
select fin_pripr
go top

cKontrola := "XXX"

do while !EOF()
    
    cSeek := fin_pripr->(idfirma + idvn + brnal)
    
    if cSeek == cKontrola
        skip
        loop
    endif
    
    if dupli_nalog( cSeek )
        
        MsgO("Brisem stavke iz kumulativa ... sacekajte trenutak!")
        
        // brisi nalog
        select nalog
        
        if !flock()
            msg("Datoteka je zauzeta ",3)
            closeret
        endif
    
        set order to tag "1"
        go top
        seek cSeek
        
        if Found()
            
            do while !eof() .and. nalog->(idfirma+idvn+brnal) == cSeek
                skip 1
                nRec:=RecNo()
                skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
        
            // brisi iz suban
            select suban
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
            
            set order to tag "4"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. suban->(idfirma + idvn + brnal) == cSeek
                    
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
        
            // brisi iz sint
            select sint
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
        
            set order to tag "2"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. sint->(idfirma + idvn + brnal) == cSeek
                    
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
            
            // brisi iz anal
            select anal
            if !flock()
                msg("Datoteka je zauzeta ",3)
                closeret
            endif
            
            set order to tag "2"
            go top
            seek cSeek
            if Found()
                do while !EOF() .and. anal->(idfirma + idvn + brnal) == cSeek
                    skip 1
                    nRec:=RecNo()
                    skip -1
                    DbDelete2()
                    go nRec
                enddo
            endif
        
    
            MsgC()
       endif
    
       cKontrola := cSeek
    
       select fin_pripr
       skip

enddo

return 0

// ------------------------------------------
// provjerava da li je dokument dupli
// ------------------------------------------
static function dupli_nalog(cSeek)
select nalog
set order to tag "1"
go top
seek cSeek
if Found()
    return .t.
endif
return .f.



// ------------------------------------------------------------
// postoji fin nalog ?
// ------------------------------------------------------------
function fin_doc_exist( id_firma, id_vn, br_nal )
local _exist := .f.
local _server := pg_server()
local _tbl, _result

_tbl := "fmk.fin_nalog"
_result := table_count( _tbl, "idfirma=" + _sql_quote( id_firma ) + " AND idvn=" + _sql_quote( id_vn ) + " AND brnal=" + _sql_quote( br_nal ) ) 

if _result <> 0
    _exist := .t.
endif

return _exist



// --------------------------------
// validacija broja naloga
// --------------------------------
static function __val_nalog( cNalog )
local lRet := .t.
local cTmp
local cChar
local i

cTmp := RIGHT( cNalog, 4 )

// vidi jesu li sve brojevi
for i := 1 to LEN( cTmp )
    
    cChar := SUBSTR( cTmp, i, 1 )
    
    if cChar $ "0123456789"
        loop
    else
        lRet := .f.
        exit
    endif

next

return lRet



// ---------------------------------------------
// centralna funkcija za odredjivanje
// novog broja naloga !!!!
// cIdFirma - firma
// cIdVn - tip naloga
// ---------------------------------------------
function NextNal( cIdFirma, cIdVN )
local nArr
nArr:=SELECT()

O_NALOG
select nalog

if gBrojac=="1"
    set order to tag "1"
    seek cIdFirma+cIdVN+chr(254)
    skip -1
    
    if ( idfirma + idvn == cIdFirma + cIdVN )
        
        // napravi validaciju polja ...
        do while !BOF()

            if !__val_nalog( field->brnal )
                skip -1
                loop
            else
                exit
            endif
        enddo
        
        cBrNal := NovaSifra(brNal)
    else
        cBrNal := "00000001"
    endif
else
    set order to tag "2"
    seek cIdFirma+chr(254)
    skip -1
    cBrNal:=padl(alltrim(str(val(brnal)+1)),8,"0")
endif

select (nArr)

return cBrNal


// ----------------------------------------------------------------
// specijalna funkcija regeneracije brojeva naloga u kum tabelama
// C(4) -> C(8) konverzija
// stari broj A001 -> 0000A001
// ----------------------------------------------------------------
function regen_tbl()

if !SigmaSIF("REGEN")
    MsgBeep("Ne diraj lava dok spava !")
    return
endif

// otvori sve potrebne tabele
O_SUBAN

if LEN( suban->brnal ) = 4
    msgbeep("potrebno odraditi modifikaciju FIN.CHS prvo !")
    return
endif

O_NALOG
O_ANAL
O_SINT


// pa idemo redom
select suban
_renum_convert()
select nalog
_renum_convert()
select anal
_renum_convert()
select sint
_renum_convert()

return


// --------------------------------------------------
// konvertuje polje BRNAL na zadatoj tabeli
// --------------------------------------------------
static function _renum_convert()
local xValue
local nCnt
local _rec

set order to tag "0"
go top

Box(,2,50)

@ m_x + 1, m_y + 2 SAY "Konvertovanje u toku... "

f18_lock_tables({LOWER(ALIAS())})
sql_table_update( nil, "BEGIN" )

nCnt := 0
do while !EOF()

    xValue := field->brnal

    if !EMPTY(xValue)
        
        _rec := dbf_get_rec()
        _rec["brnal"] := PADL( ALLTRIM( xValue ), 8, "0" )
        update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
        ++ nCnt

    endif

    @ m_x + 2, m_y + 2 SAY PADR( "odradjeno " + ALLTRIM(STR(nCnt)), 45 )

    skip

enddo

f18_free_tables({LOWER(ALIAS())})
sql_table_update( nil, "END" )

BoxC()

return


