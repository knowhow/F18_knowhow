/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "pos.ch"



function PRacuni(dDat, cBroj, fPrep, fScope, cPrefixFilter, qIdRoba)
local i
private fMark:=.f.
private cFilter
private ImeKol := {}
private Kol := {}

if cPrefixFilter==NIL
    cPrefixFilter:=""
endif
cFilter:=cPrefixFilter+" IdVd=='42'"
if fPrep==nil
    fPrep:=.f.
else
    fPrep:=fPrep
endif

if cBroj==nil
    cRacun:=SPACE(LEN(POS->BrDok))
else
    cRacun:=ALLTRIM(cBroj)
endif

cIdPos:=LEFT(cRacun,AT("-",cRacun)-1)
cIdPos:=PADR(cIdPOS,LEN(gIdPos))

if gVrstaRS<>"S".and.!EMPTY(cIdPos).and.cIdPOS<>gIdPos
    MsgBeep("Racun nije napravljen na ovoj kasi!#"+"Ne mozete napraviti promjenu!",20)
    return (.f.)
endif

cBroj:=RIGHT(cRacun,LEN(cRacun)-AT("-",cRacun))
cBroj:=PADL(cBroj,6)

AADD(ImeKol, { "Broj racuna", {|| padr(trim(IdPos)+"-"+alltrim(BrDok),9)}}) 

if pos_doks->(FIELDPOS("FISC_RN")) <> 0
    AADD(ImeKol, { "Fisk.rn",{|| fisc_rn}} )
endif

AADD(ImeKol, { "Iznos", {|| STR (SR_Iznos(), 13, 2)}} )
AADD(ImeKol, { IIF(gStolovi == "D", "Sto", "Smj"), ;
    {|| IIF(gStolovi == "D", sto_br , smjena)}})
AADD(ImeKol, { "Datum",{|| datum}} )
AADD(ImeKol, { "Vr.Pl",{|| idvrstep} } )
AADD(ImeKol, { IIF(IsPlNs(), "Broj NI", "Partner"),{|| idgost} })
AADD(ImeKol, { "Vrijeme",{|| vrijeme} })
AADD(ImeKol,{ "Placen",     {|| IIF (Placen==PLAC_NIJE,"  NE","  DA")} })

for i:=1 to LEN(ImeKol)
    AADD(kol,i)
next

select pos_doks

if fScope=nil
    fScope:=.t.
endif


if fScope
    SET SCOPEBOTTOM TO "W"
endif

if gVrstaRS=="S".or.KLevel<L_UPRAVN
    AADD(ImeKol,{"Radnik",{|| IdRadnik}})
    AADD(Kol, LEN(ImeKol))
    cFilter+=".and. (Idpos="+cm2str(gIdPos)+" .or. IdPos='X ')"
else
    cFilter+=".and. IdRadnik="+cm2str(gIdRadnik)+".and. Idpos="+cm2str(gIdPos)
endif

if kLevel==L_PRODAVAC
    cFilter+='.and. Datum='+cm2str(dDat)
endif

if qIdRoba<>nil.and.!EMPTY(qIdRoba)
    cFilter+=".and. SR_ImaRobu(IdPos+IdVd+dtos(datum)+BrDok,"+cm2str(qIdRoba)+")"
endif

SET FILTER TO &cFilter

if !EMPTY(cBroj)
    SEEK2(cIdPos+"42"+dtos(dDat)+cBroj)
    if FOUND()
            cBroj:=ALLTRIM(pos_doks->IdPos)+"-"+ALLTRIM(pos_doks->BrDok)
            dDat:=pos_doks->datum
            return(.t.)
    endif
else
    GO BOTTOM
endif

if fPrep
    cFnc:="<Enter>-Odabir   <+>-Markiraj/Demarkiraj   <P>-Pregled"
    fMark:=.t.
    // ako je prepis, aVezani je privatna varijabla funkcije <PrepisRacuna>
    bMarkF:={|| RacObilj ()}
else
    cFnc:="<Enter>-Odabir          <P>-Pregled"
    bMarkF:=NIL
endif

ObjDBedit( "racun" , MAXROWS() - 4, MAXCOLS() - 3, {|| EdPRacuni(fMark) },IIF(gRadniRac=="D", "  STALNI ","  ")+"RACUNI  ", "", nil,cFnc,,bMarkF)

SET FILTER TO

cBroj:=ALLTRIM(pos_doks->IdPos)+"-"+AllTrim (pos_doks->BrDok)

if cBroj='-'  // nema racuna
    cBroj:=SPACE(9)
endif

dDat:=pos_doks->datum

if LASTKEY()==K_ESC
    return(.f.)
endif

return(.t.)
*}


/*! \fn EdPRacuni()
 *  \brief Ispravka 
 */

function EdPRacuni()

//                   1            2               3              4
// aVezani : {pos_doks->IdPos, pos_doks->(BrDok), pos_doks->IdVrsteP, pos_doks->Datum})

local cLevel
local ii
local nTrec
local nTrec2
local _rec

// M->Ch je iz OBJDB, fMark je iz PRacuni
if M->Ch==0
    return (DE_CONT)
endif
if (LASTKEY()==K_ESC).or.(LASTKEY()==K_ENTER )
    return (DE_ABORT)

endif

O_DIO
O_ODJ

O_STRAD
select strad
hseek gStrad
cLevel:=prioritet
use
select pos_doks

if fMark .and. (LastKey()==Asc("+"))
    nPos := ASCAN (aVezani, {|x| (x[1]+dtos(x[4])+x[2])==pos_doks->(IdPos+dtos(datum)+BrDok)})
    if nPos == 0
            if LEN(aVezani)==0 .or.(aVezani[1][3]==pos_doks->IdVrsteP .and. aVezani[1][4]==pos_doks->Datum)
                AADD (aVezani, {pos_doks->IdPos, pos_doks->(BrDok), pos_doks->IdVrsteP, pos_doks->Datum})
            elseif aVezani[1][3]<>pos_doks->IdVrsteP
                MsgBeep ("Nemoguce spajanje!#Nacin placanja nije isti!")
            elseif aVezani[1][4]<>pos_doks->Datum
                MsgBeep ("Nemoguce spajanje!#Datum racuna nije isti!")
        endif
    else
            ADEL(aVezani, nPos)
            ASIZE(aVezani, LEN (aVezani)-1)
    endif
    
    return DE_REFRESH
endif

if UPPER(CHR(LASTKEY()))=="P"
    PreglSRacun(pos_doks->IdPos,pos_doks->datum,pos_doks->BrDok)
    return DE_REFRESH
endif



if UPPER(CHR(LASTKEY()))=="F"
    // stampa poreske fakture
    aVezani:={{IdPos, BrDok, IdVd, datum}}
    StampaPrep(IdPos, dtos(datum)+BrDok, aVezani, .t., nil, .t.)
    select pos_doks
    f7_pf_traka(.t.)
    select pos_doks
    
    return DE_REFRESH
endif

if UPPER(CHR(LASTKEY()))=="S"
    
    // storno racuna
    pos_storno_rn( .t., pos_doks->brdok, pos_doks->datum, ;
        PADR( ALLTRIM(STR(pos_doks->fisc_rn)), 10 ) )

    msgbeep("Storno racun se nalazi u pripremi !")

    select pos_doks
    return DE_REFRESH

endif

if UPPER(CHR(LASTKEY()))=="Z"
    PushWa()
    print_zak_br(pos_doks->zak_br)
    o_pregled()
    PopWa()
    return DE_REFRESH
endif

// setovanje veze sa brojem fiskalnog racuna
if ch == K_CTRL_R
    
    // ako nema polja ... nista
    if pos_doks->(FIELDPOS("FISC_RN")) = 0
        return DE_CONT
    endif
    
    nFisc_no := pos_doks->fisc_rn

    Box(,1,40)
        @ m_x + 1, m_y + 2 SAY "Broj fiskalnog racuna: " GET nFisc_no
        read
    BoxC()

    if LastKey() <> K_ESC
    
        _rec := dbf_get_rec()
        _rec["fisc_rn"] := nFisc_no
        update_rec_server_and_dbf( "pos_doks", _rec )   
        
        return DE_CONT
    
    endif

endif

cLast:=UPPER(CHR(LASTKEY()))
if KLevel="0".and.(cLast=="D".or.cLast == "S" .or. cLast=="V" )
    if Pitanje(,"Ispraviti vrijeme racuna ?","N")=="D"
        dOrigD:=Datum
        dDatum:=Datum
        cVrijeme:=Vrijeme
        cIBroj:="N"
        nNBrDok:=0
        set cursor on
        Box(,5,60)
            if cLast $ "SV"
                @ m_x+1,m_y+2 say "     Vrijeme" get cVrijeme
            endif
            if cLast $ "DV"
                @ m_x+2,m_y+2 say "Datum racuna" get dDatum
            endif
            
            @ m_x+3, m_y+2 say "Ispravka broja D/N" get cIBroj PICT "@!"
        READ

        if cIBroj=="D"
            @ m_x+5, m_y+2 SAY "Novi broj" GET nNBrDok PICT "999999"
            READ
            cNBrDok:=PADL(ALLTRIM(STR(nNBrDok)),6)
        else
            cNBrDok:=nil
        endif
        BoxC()
        if (LASTKEY()==K_ESC)
            return DE_CONT
        endif
            if dOrigD<>dDatum .and. lastkey()!=K_ESC
                IspraviDV(cLast, dOrigD, dDatum, cVrijeme, cNBrDok)
            endif 
        endif 

        return DE_REFRESH
endif


if cLevel<="0"   

    // samo sistem administrator
    if ch==K_F1
       	MSgBeep("Ctrl-F9  - brisi fizicki#"+"Shift-F9 - brisi fizicki period")
     	return DE_CONT
    endif

    if ch==K_CTRL_F9
      	return BrisiRacun()
    endif

    if ch==K_SH_F9
    	return  BrisiRNVP()
    endif

endif 

return (DE_CONT)




// ------------------------------------------
// vraca iznos racuna iz pos baze
// ------------------------------------------
function SR_Iznos()
local _iznos_rn := 0

select pos
set order to tag "1"
go top

Seek2( pos_doks->( IdPos + IdVd + dtos(datum) + BrDok ) )

while !EOF() .and. pos->( IdPos + IdVd + dtos(datum) + BrDok ) == pos_doks->( IdPos + IdVd +dtos(datum) + BrDok )
    _iznos_rn += pos->( kolicina * cijena )
    SKIP
end

select pos_doks
return ( _iznos_rn )



/*! \fn BrisiRacun()
 *  \brief Brisanje racuna
 */
function BrisiRacun()
local _rec
local _id_vd, _id_pos, _dat_dok, _br_dok
local _t_area := SELECT()

if Pitanje(,"Potpuno - fizicki izbrisati racun?","N")=="N"
    return DE_CONT
endif

select pos_doks
_br_dok := field->BrDok
_id_pos := field->IdPos
_dat_dok := field->datum
_id_vd := field->idvd

_rec := dbf_get_rec()

if empty(dMinDatProm)
    dMinDatProm := field->datum
else
    dMinDatProm := min( dMinDatProm, field->datum )
endif

my_use_semaphore_off()
sql_table_update( nil, "BEGIN" )

delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )


SELECT POS
set order to tag "1"
seek _id_pos + VD_RN + DTOS(_dat_dok) + _br_dok

if FOUND()
    delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT" )
endif

sql_table_update( nil, "END" )
my_use_semaphore_on()

select ( _t_area )

return (DE_REFRESH)


