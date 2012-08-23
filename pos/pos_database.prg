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


// --------------------
// otvori baze potrebne za 
// pregled racuna
// --------------------
function o_pregled()

SELECT F_ODJ
if !used()
    O_ODJ
endif

SELECT F_OSOB
if !used()
    O_OSOB
endif

SELECT F_VRSTEP
if !used()
    O_VRSTEP
endif

SELECT F_POS
if !used()
    O_POS
endif

SELECT F_POS_DOKS
if !used()
    O_POS_DOKS
endif

SELECT F_DOKSPF
if !used()
    O_DOKSPF
endif

SELECT F_ROBA
if !used()
    O_ROBA
endif

SELECT F_TARIFA
if !used()
    O_TARIFA
endif

SELECT F_SIFK
if !used()
    O_SIFK
endif

SELECT F_SIFV
if !used()
    O_SIFV
endif

select pos_doks

return


// -----------------------------------------------
// otvori tabele potrebne za unos stavki u racun
// ------------------------------------------------
function o_edit_rn()

select F__POS
if !used()
    O__POS
endif

select F__PRIPR
if !used()
    O__POS_PRIPR
endif

select F_K2C
if !used()
    O_K2C
endif

select F_MJTRUR
if !used()
    O_MJTRUR 
endif

select F_UREDJ
if !used()
    O_UREDJ 
endif

o_pregled()

return


 
function OpenPos()

O_PARTN
O_VRSTEP
O_DIO
O_ODJ
O_KASE
O_OSOB
set order to tag "NAZ"

O_TARIFA 
O_VALUTE
O_SIFK
O_SIFV
O_ROBA
O__POS
O_POS_DOKS
O_POS

return


function o_pos_sifre()

O_KASE
O_UREDJ
O_ODJ
O_ROBA
O_TARIFA
O_VRSTEP
O_VALUTE
O_PARTN
O_OSOB
O_STRAD
O_SIFK
O_SIFV

return


 
function O_InvNiv()

O_UREDJ
O_MJTRUR
O_ODJ
O_DIO

O_SIFK
O_SIFV

O_SAST
O_ROBA

O_POS_DOKS
O_POS
O__POS
O_PRIPRZ
return



 
function OpenZad()

O_UREDJ
O_MJTRUR
O_ODJ  
O_DIO
O_TARIFA
O_POS_DOKS
O_POS
O__POS
O_PRIPRZ
O_SIFK
O_SIFV
O_ROBA 
return


 
function ODbRpt()

O_OSOB
O_SIFK
O_SIFV
O_VRSTEP 
O_ROBA
O_ODJ 
O_DIO
O_KASE
O_POS
O_POS_DOKS

return


 
function o_pos_narudzba()

if gPratiStanje $ "D!"
    O_POS
endif

O_MJTRUR 
O_UREDJ 
O_ODJ 
O_K2C
O_ROBA
O_SIFK
O_SIFV
O__POS_PRIPR 
O__POS

return



function O_StAzur()
O__POS
O_ODJ
O_VRSTEP
O_PARTN
O_OSOB
O_VALUTE
O_TARIFA
O_POS_DOKS
O_POS
O_ROBA
return



// -----------------------------------------------------------------------
// vraca iznos racuna
// -----------------------------------------------------------------------
function pos_iznos_racuna( cIdPos, cIdVD, dDatum, cBrDok )
local _iznos := 0
local _popust := 0
local _total := 0

if PCOUNT() == 0

    cIdPos := pos_doks->IdPos
    cIdVD := pos_doks->IdVD
    dDatum := pos_doks->Datum
    cBrDok := pos_doks->BrDok

endif

select pos
Seek2( cIdPos + cIdVd + DTOS(dDatum) + cBrDok )

do while !EOF() .and. POS->( IdPos + IdVd + DTOS( datum ) + BrDok ) == ( cIdPos + cIdVd + DTOS( dDatum ) + cBrDok )
    _iznos += POS->( kolicina * cijena )
    _popust += POS->( kolicina * ncijena )
    SKIP
enddo

_total := ( _iznos - _popust )

select pos_doks

return _total



function pos_iznos_dokumenta( lUI )
local cRet:=SPACE(13)
local l_u_i
local nIznos:=0
local cIdPos, cIdVd, cBrDok
local dDatum

select pos_doks

cIdPos:=pos_doks->idPos
cIdVd:=pos_doks->idVd
cBrDok:=pos_doks->brDok
dDatum:=pos_doks->datum

if ((lUI==NIL) .or. lUI)
    // ovo su ulazi ...
        if pos_doks->IdVd $ VD_ZAD+"#"+VD_PCS+"#"+VD_REK
            SELECT pos
            set order to tag "1"
            go top
            SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok
            do while !eof().and.pos->(IdPos+IdVd+DTOS(datum)+BrDok)==cIdPos+cIdVd+DTOS(dDatum)+cBrDok
                nIznos+=pos->kolicina*pos->cijena
                SKIP
            enddo
        if pos_doks->idvd==VD_REK
            nIznos:=-nIznos
        endif
        endif
    
endif

if ((lUI==NIL) .or. !lUI)
    // ovo su, pak, izlazi ...
        if pos_doks->IdVd $ VD_RN+"#"+VD_OTP+"#"+VD_RZS+"#"+VD_PRR+"#"+"IN"+"#"+"IN"

            SELECT pos
            set order to tag "1"
            go top
            SEEK cIdPos+cIdVd+DTOS(dDatum)+cBrDok
            do while !eof() .and. pos->(IdPos+IdVd+DTOS(datum)+BrDok)==cIdPos+cIdVd+DTOS(dDatum)+cBrDok
                do case
                    case pos_doks->IdVd=="IN"
                            nIznos+=(pos->kol2-pos->kolicina)*pos->cijena
                    case pos_doks->IdVd==VD_NIV
                            nIznos+=pos->kolicina*(pos->nCijena-POS->Cijena)
                    otherwise
                            nIznos+=pos->kolicina*pos->cijena
                endcase
                SKIP
            enddo
        endif
endif

select pos_doks
cRet:=STR(nIznos,13,2)

return (cRet)






/*! \fn azur_pos_racun(cIdPos,cStalRac,cRadRac,cVrijeme,cNacPlac,cIdGost)
 *  \brief Azuriranje racuna ( _POS->POS, _POS->DOKS )
 *  \param cIdPos
 *  \param cStalRac    - prilikom azuriranja daje se broj cStalRac
 *  \param cRadRac     - racun iz _POS.DBF sa brojem cRadRac se prenosi u POS, DOKS
 *  \param cVrijeme
 *  \param cNacPlac
 *  \param cIdGost
 */
 
function azur_pos_racun( cIdPos, cStalRac, cRadRac, cVrijeme, cNacPlac, cIdGost )
local cDatum
local nStavki
local _rec, _append
local _cnt := 0
local _kolicina := 0
local _idroba, _idcijena, _cijena
private nIznRn := 0

_ok := .t.

// iskljuci mi semafore
my_use_semaphore_off()

log_write( "pos azuriranje racuna, racun: " + cStalRac + " - poceo", 5 )

o_stazur()

// zakljucaj semafore pos-a
if !pos_semaphores_lock()
    return
endif

if ( cNacPlac == NIL )
    cNacPlac := gGotPlac
endif

if ( cIdGost == NIL )
    cIdGost := ""
endif

select _pos
set order to tag "1"
seek cIdPos + "42" + DTOS( gDatum ) + cRadRac

if !FOUND()
    _msg := "Problem sa podacima tabele _POS, nema stavi !!!#Azuriranje nije moguce !" 
    log_write( _msg, 2 )
    msgbeep( _msg )
    my_use_semaphore_on()
    return
endif

// azuriraj racun u POS_DOKS
select pos_doks
append blank
_rec := dbf_get_rec()
_rec["idpos"] := cIdPos
_rec["idvd"] := VD_RN
_rec["datum"] := gDatum
_rec["brdok"] := cStalRac
_rec["vrijeme"] := cVrijeme
_rec["idvrstep"] := cNacPlac
_rec["idgost"] := cIdGost
_rec["idradnik"] := _pos->idradnik
_rec["m1"] := OBR_NIJE
_rec["prebacen"] := OBR_JEST
_rec["smjena"] := _pos->smjena

sql_table_update( nil, "BEGIN" )
update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT", .f. )

// azuriranje stavki u POS

select _pos
cDatum := DTOS( gDatum )  

do while !EOF() .and. _POS->( IdPos + IdVd + DTOS( Datum ) + BrDok ) == ( cIdPos + "42" + cDatum + cRadRac )

    nIznRn += ( _pos->kolicina * _pos->cijena )
    
    select pos
    append blank

    _rec := dbf_get_rec()

    _rec["idpos"] := cIdPos
    _rec["idvd"] := VD_RN
    _rec["datum"] := gDatum
    _rec["brdok"] := cStalRac
    _rec["rbr"] := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )
    _rec["m1"] := OBR_JEST
    _rec["prebacen"] := OBR_NIJE
    _rec["iddio"] := _pos->iddio 
    _rec["idodj"] := _pos->idodj
    _rec["idcijena"] := _pos->idcijena
    _rec["idradnik"] := _pos->idradnik
    _rec["idroba"] := _pos->idroba
    _rec["idtarifa"] := _pos->idtarifa
    _rec["kolicina"] := _pos->kolicina
    _rec["mu_i"] := _pos->mu_i
    _rec["ncijena"] := _pos->ncijena
    _rec["cijena"] := _pos->cijena
    _rec["smjena"] := _pos->smjena
    _rec["c_1"] := _pos->c_1
    _rec["c_2"] := _pos->c_2
    _rec["c_3"] := _pos->c_3

    update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT", .f. )

    select _pos
    skip

enddo

sql_table_update( nil, "END" )

// otkljucaj semafore
pos_semaphores_unlock()

// pos_pos check
check_recno( "pos_pos", .f. )
check_recno( "pos_doks", .f. )

my_use_semaphore_on()

log_write( "pos azuriranje racuna, racun: " + cStalRac + " - zavrsio", 5 )

// pobrisi _pos
select _pos
zap
__dbPack()

return



// ---------------------------------------------------------
// azuriranje zaduzenja...
// ---------------------------------------------------------
function AzurPriprZ(cBrDok, cIdVd)
local _rec, _app
local _cnt := 0
local _tbl_pos := "pos_pos"
local _tbl_doks := "pos_doks"
local _ok := .t.

SELECT PRIPRZ
GO TOP

set_global_memvars_from_dbf()

my_use_semaphore_off()

// zakljucaj semafore pos-a
if !pos_semaphores_lock()
    return
endif

sql_table_update( nil, "BEGIN")

select pos_doks
append blank

_brdok := cBrDok 

// zakljucene stavke
if gBrojSto == "D"
    if cIdVd <> VD_RN
        _zakljucen := "Z"
    endif
endif

if cIdVd == "PD"
    _IdVd := "16"
else
    _IdVd := cIdVd
endif

_app := get_dbf_global_memvars()
update_rec_server_and_dbf( "pos_doks", _app, 1, "CONT", .f. )

SELECT PRIPRZ

// dodaj u datoteku POS
do while !EOF()   
    
    SELECT PRIPRZ

    azur_sif_roba_row()

    SELECT PRIPRZ 

    set_global_memvars_from_dbf()

    SELECT POS
    APPEND BLANK

    _BrDok := cBrDok

    if cIdVd=="PD"
        _IdVd:="16"
    else
        _IdVd:=cIdVd
    endif
    
    if cIdVD=="PD"
        // !prva stavka storno
        _IdVd:="16"
        _IdDio:=_IdVrsteP
        _kolicina:=-_Kolicina
    endif

    _rbr := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )

    _app := get_dbf_global_memvars()

    update_rec_server_and_dbf( "pos_pos", _app, 1, "CONT", .f. )

    if cIdVD == "PD"  
        
        // druga stavka
        //append blank
        
        // !druga stavka storno storna = "+"
        _rec := hb_hash()
        _rec["idvd"] := "16"
        _rec["idodj"] := _rec["idvrstep"]  
        _rec["iddio"] := ""
        _rec["idvrstep"] := ""
        _rec["kolicina"] := - _rec["kolicina"]
        _rec["rbr"] := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )

        update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT", .f. )
    
    endif

    SELECT PRIPRZ

    Del_Skip()

enddo

// zavrsi transakciju
sql_table_update( nil, "END")

// otkljucaj mi semafore
pos_semaphores_unlock()

my_use_semaphore_on()

SELECT PRIPRZ
__dbPack()

// ova opcija ce setovati plu kodove u sifrarniku ako nisu vec setovani
if gFc_use == "D" .and. gFc_acd == "P" 

    nTArea := SELECT()

    // generisi plu kodove za nove sifre
    gen_all_plu( .t. )

    select (nTArea)

endif

return



// ------------------------------------------------------------------
// pos, uzimanje novog broja za tops dokument
// ------------------------------------------------------------------
function pos_novi_broj_dokumenta( id_pos, tip_dokumenta, dat_dok )
local _broj := 0
local _broj_doks := 0
local _param
local _tmp, _rest
local _ret := ""
local _t_area := SELECT()

if dat_dok == NIL
    dat_dok := gDatum
endif

// param: pos/10/10
_param := "pos" + "/" + id_pos + "/" + tip_dokumenta 
_broj := fetch_metric( _param, nil, _broj )

// konsultuj i doks uporedo
O_POS_DOKS
set order to tag "1"
go top
seek id_pos + tip_dokumenta + DTOS( dat_dok ) + "Ž"
skip -1

if field->idpos == id_pos .and. field->idvd == tip_dokumenta .and. DTOS( field->datum ) == DTOS( dat_dok )
    _broj_doks := VAL( field->brdok )
else
    _broj_doks := 0
endif

// uzmi sta je vece, doks broj ili globalni brojac
_broj := MAX( _broj, _broj_doks )

// uvecaj broj
++ _broj

// ovo ce napraviti string prave duzine...
_ret := PADL( ALLTRIM( STR( _broj ) ), 6  )

// upisi ga u globalni parametar
set_metric( _param, nil, _broj )

select ( _t_area )
return _ret


// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
function pos_set_param_broj_dokumenta()
local _param
local _broj := 0
local _broj_old
local _id_pos := gIdPos
local _tip_dok := "42"

Box(, 2, 60 )

    @ m_x + 1, m_y + 2 SAY "Dokument:" GET _id_pos
    @ m_x + 1, col() + 1 SAY "-" GET _tip_dok

    read

    if LastKey() == K_ESC
        BoxC()
        return
    endif

    // param: pos/10/10
    _param := "pos" + "/" + _id_pos + "/" + _tip_dok
    _broj := fetch_metric( _param, nil, _broj )
    _broj_old := _broj

    @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "999999"

    read

BoxC()

if LastKey() != K_ESC
    // snimi broj u globalni brojac
    if _broj <> _broj_old
        set_metric( _param, nil, _broj )
    endif
endif

return



// ------------------------------------------------------------
// resetuje brojač dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
function pos_reset_broj_dokumenta( id_pos, tip_dok, broj_dok )
local _param
local _broj := 0

// param: fakt/10/10
_param := "pos" + "/" + id_pos + "/" + tip_dok
_broj := fetch_metric( _param, nil, _broj )

if VAL( ALLTRIM( broj_dok ) ) == _broj
    -- _broj
    // smanji globalni brojac za 1
    set_metric( _param, nil, _broj )
endif

return



function Del_Skip()
local nNextRec
nNextRec:=0
SKIP
nNextRec:=RECNO()
Skip -1
delete
GO nNextRec
return



function GoTop2()
GO TOP
if DELETED()
    SKIP
endif
return



/*! \fn SR_ImaRobu(cPom,cIdRoba)
 *  \brief Funkcija koja daje .t. ako se cIdRoba nalazi na posmatranom racunu
 *  \param cPom
 *  \param cIdRoba
 */
 
function SR_ImaRobu( cPom, cIdRoba )
local lVrati:=.f.
local nArr:=SELECT()

SELECT POS
Seek2(cPom+cIdRoba)

if POS->(IdPos+IdVd+dtos(datum)+BrDok+idroba)==cPom+cIdRoba
    lVrati:=.t.
endif

SELECT (nArr)
return (lVrati)



/*! \fn Priprz2Pos()
 *  \brief prebaci iz priprz -> pos,doks
 *  \note azuriranje dokumenata zaduzenja, nivelacija
 *
 */

function Priprz2Pos()
local lNivel
local _rec
local _cnt := 0
local _tbl_pos := "pos_pos"
local _tbl_doks := "pos_doks"
local _ok := .t.

lNivel:=.f.

SELECT (cRsDbf)
SET ORDER TO TAG "ID"

log_write( "azuriranje stavki iz priprz u pos/doks, poceo", 5 )

MsgO( "Azuriranje priprema -> kumulativ u toku... sacekajte..." )

my_use_semaphore_off()

// lockuj semafore
if !pos_semaphores_lock()
    return
endif

sql_table_update( nil, "BEGIN" )

SELECT PRIPRZ
GO TOP

select pos_doks
APPEND BLANK

_rec := dbf_get_rec()
_rec["idpos"] := priprz->idpos
_rec["idvd"] := priprz->idvd
_rec["datum"] := priprz->datum
_rec["brdok"] := priprz->brdok
_rec["vrijeme"] := priprz->vrijeme
_rec["idvrstep"] := priprz->idvrstep 
_rec["idgost"] := priprz->idgost
_rec["idradnik"] := priprz->idradnik
_rec["m1"] := priprz->m1
_rec["prebacen"] := priprz->prebacen
_rec["smjena"] := priprz->smjena

update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT", .f. )

// upis inventure/nivelacije
SELECT PRIPRZ  

do while !eof()

    // dodaj stavku u pos
    SELECT POS  
    APPEND BLANK

    _rec := dbf_get_rec()
    _rec["idpos"] := priprz->idpos
    _rec["idvd"] := priprz->idvd
    _rec["datum"] := priprz->datum
    _rec["brdok"] := priprz->brdok
    _rec["m1"] := priprz->m1
    _rec["prebacen"] := priprz->prebacen
    _rec["iddio"] := priprz->iddio 
    _rec["idodj"] := priprz->idodj
    _rec["idcijena"] := priprz->idcijena
    _rec["idradnik"] := priprz->idradnik
    _rec["idroba"] := priprz->idroba
    _rec["idtarifa"] := priprz->idtarifa
    _rec["kolicina"] := priprz->kolicina
    _rec["kol2"] := priprz->kol2
    _rec["mu_i"] := priprz->mu_i
    _rec["ncijena"] := priprz->ncijena
    _rec["cijena"] := priprz->cijena
    _rec["smjena"] := priprz->smjena
    _rec["c_1"] := priprz->c_1
    _rec["c_2"] := priprz->c_2
    _rec["c_3"] := priprz->c_3
    _rec["rbr"] := PADL( ALLTRIM(STR( ++ _cnt ) ) , 5 ) 

    update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT", .f. )
    
    SELECT PRIPRZ

    // azur sifrarnik robe na osnovu priprz
    azur_sif_roba_row()

    SELECT PRIPRZ
    SKIP

enddo

MsgC()

sql_table_update( nil, "END" )

// otkljucaj semafore
pos_semaphores_unlock()

// pos_pos check
check_recno( "pos_pos", .f. )
check_recno( "pos_doks", .f. )

my_use_semaphore_on()

log_write( "azuriranje stavki iz priprz u pos/doks, zavrsio", 5 )

MsgO("brisem pripremu....")

// ostalo je jos da izbrisemo stavke iz pomocne baze
SELECT PRIPRZ

Zapp()
__dbPack()

MsgC()

return



// ------------------------------------------------
// zakljucaj pos semafore
// ------------------------------------------------
function pos_semaphores_lock()
local _ok := .t.
local _tbl_pos := "pos_pos"
local _tbl_doks := "pos_doks"

// lock semaphore
sql_table_update(nil, "BEGIN")
_ok := lock_semaphore( _tbl_pos, "lock" )
_ok := _ok .and. lock_semaphore( _tbl_doks,  "lock" )

if _ok
    sql_table_update(nil, "END")
    log_write( "uspjesno zakljucane tabele pos_pos i pos_doks", 7 )
else
    sql_table_update(nil, "ROLLBACK")
    my_use_semaphore_on()
    log_write( "nisam uspio zakljucati tabele pos_pos i pos_doks", 2 )
    MsgBeep("lock pos tabela neuspjesan, operacija prekinuta")
    return 
endif

return _ok



// ----------------------------------------------------
// otkljucaj semafore pos-a
// ----------------------------------------------------
function pos_semaphores_unlock()
local _tbl_pos := "pos_pos"
local _tbl_doks := "pos_doks"
local _ok := .t.

_ok := lock_semaphore( _tbl_pos, "free" )
_ok := _ok .and. lock_semaphore( _tbl_doks, "free" )

log_write( "otkljucane tabele pos_pos i pos_doks", 7 )

return _ok


// ------------------------------------------
// azuriraj sifrarnik robe
// priprz -> roba
// ------------------------------------------
static function azur_sif_roba_row()
local _rec

// u jednom dbf-u moze biti vise IdPos
// ROBA ili SIROV
select ( cRSDbf )
set order to tag "ID"

// pozicioniran sam na robi
hseek priprz->idroba  

lNovi:=.f.
if ( !FOUND() )

    // novi artikal
    // roba (ili sirov)
    append blank

    _rec := dbf_get_rec()
    _rec["id"] := priprz->idroba

else

    _rec := dbf_get_rec()

endif

_rec["naz"] := priprz->robanaz
_rec["jmj"] := priprz->jmj

if !IsPDV() 
    // u ne-pdv rezimu je bilo bitno da preknjizenje na pdv ne pokvari
    // star cijene
    if katops->idtarifa <> "PDV17"
        _rec["mpc"] := ROUND( priprz->cijena, 3 )        
    endif
else

    if cIdVd == "NI"
      // nivelacija - u sifrarnik stavi novu cijenu
      _rec["mpc"] := ROUND(priprz->ncijena, 3)
    else
      _rec["mpc"] := ROUND(priprz->cijena, 3)
    endif
    
endif

_rec["idtarifa"] := priprz->idtarifa
_rec["k1"] := priprz->k1
_rec["k2"] := priprz->k2
_rec["k7"] := priprz->k7
_rec["k8"] := priprz->k8
_rec["k9"] := priprz->k9
_rec["n1"] := priprz->n1
_rec["n2"] := priprz->n2
_rec["barkod"] := priprz->barkod

update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )

return


// ---------------------------------------------------------------
// koriguje broj racuna
// ---------------------------------------------------------------
static function _fix_rn_no( racun )
local _a_rn := {}

if !EMPTY( racun ) .and. ( "-" $ racun )

    _a_rn := TokToNiz( racun, "-" )

    if !EMPTY( _a_rn[2] )
        racun := PADR( ALLTRIM(_a_rn[2]), 6 )
    endif 

endif

return .t.



// ---------------------------------------------------------------
// storniranje racuna po fiskalnom isjecku
// ---------------------------------------------------------------
function pos_storno_fisc_no()
local nTArea := SELECT()
local _rec
local _datum, _broj_rn
local _fisc_broj := 0
private GetList := {}
private aVezani:={}

Box(, 1, 55 )
    @ m_x + 1, m_y + 2 SAY "broj fiskalnog isjecka:" GET _fisc_broj PICT "9999999999"
    read
BoxC()

if LastKey() == K_ESC
    select ( nTArea )
    return
endif

if _fisc_broj <= 0
    select ( nTArea )
    return
endif

select ( nTArea )

select pos_doks
set order to tag "FISC"
go top
seek STR( _fisc_broj, 10 )

if !FOUND()
    MsgBeep( "Ne postoji racun sa zeljenom vezom fiskalnog racuna !!!" )
    select (nTArea )
    return
endif

_datum := pos_doks->datum
_broj_rn := pos_doks->brdok

select pos_doks
set order to tag "1"

// filuj stavke storno racuna
__fill_storno( _datum, _broj_rn, STR( _fisc_broj, 10 ) )

select (nTArea)

// ovo refreshira pripremu
oBrowse:goBottom()
oBrowse:refreshAll()
oBrowse:dehilite()

do while !oBrowse:Stabilize() .and. ( ( Ch := INKEY() ) == 0 )
enddo

return







// -------------------------------------
// storniranje racuna
// -------------------------------------
function pos_storno_rn( lSilent, cSt_rn, dSt_date, cSt_fisc )
local nTArea := SELECT()
local _rec
local _datum := gDatum
local _danasnji := "D"
private GetList := {}
private aVezani:={}

if lSilent == nil
    lSilent := .f.
endif

if cSt_rn == nil
    cSt_rn := SPACE(6)
endif

if dSt_date == nil
    dSt_date := DATE()
endif

if cSt_fisc == nil
    cSt_fisc := SPACE(10)
endif

Box(, 4, 55 )
    
    @ m_x + 1, m_y + 2 SAY "Racun je danasnji ?" GET _danasnji VALID _danasnji $ "DN" PICT "@!"
    
    read

    if _danasnji == "N"
        _datum := NIL
    endif

    @ m_x + 2, m_y + 2 SAY "stornirati pos racun broj:" GET cSt_rn VALID {|| PRacuni( @_datum, @cSt_rn, .t. ), _fix_rn_no( @cSt_rn ), dSt_date := _datum,  .t. }
    @ m_x + 3, m_y + 2 SAY "od datuma:" GET dSt_date
    
    read
    
    cSt_rn := PADL( ALLTRIM(cSt_rn), 6 )

    if EMPTY( cSt_fisc )
        select pos_doks
        seek gIdPos + "42" + DTOS( dSt_date ) + cSt_rn
        cSt_fisc := PADR( ALLTRIM( STR( pos_doks->fisc_rn )), 10 )
    endif

    @ m_x + 4, m_y + 2 SAY "broj fiskalnog isjecka:" GET cSt_fisc
    
    read

BoxC()

if LastKey() == K_ESC
    select ( nTArea )
    return
endif

if EMPTY( cSt_rn )
    select ( nTArea )
    return
endif

select ( nTArea )

// filuj stavke storno racuna
__fill_storno( dSt_date, cSt_rn, cSt_fisc )

if lSilent == .f.

    // ovo refreshira pripremu
    oBrowse:goBottom()
    oBrowse:refreshAll()
    oBrowse:dehilite()

    do while !oBrowse:Stabilize() .and. ( ( Ch := INKEY() ) == 0 )
    enddo

endif

return


// --------------------------------------------------
// filuje pripremu sa storno stavkama
// --------------------------------------------------
static function __fill_storno( rn_datum, storno_rn, broj_fiscal )
local _t_area := SELECT()
local _t_roba, _rec

// napuni pripremu sa stavkama racuna za storno
select pos
seek gIdPos + "42" + DTOS( rn_datum ) + storno_rn

do while !EOF() .and. field->idpos == gIdPos ;
    .and. field->brdok == storno_rn ;
    .and. field->idvd == "42"

    _t_roba := field->idroba

    select roba
    seek _t_roba
    
    select pos

    _rec := dbf_get_rec()
    hb_hdel( _rec, "rbr" ) 
    
    select _pos_pripr
    append blank
    
    _rec["brdok"] :=  "PRIPRE"
    _rec["kolicina"] := ( _rec["kolicina"] * -1 )
    _rec["robanaz"] := roba->naz
    _rec["datum"] := gDatum

    dbf_update_rec( _rec )

    if _pos_pripr->(FIELDPOS("C_1")) <> 0
        if EMPTY( broj_fiscal )
            replace field->c_1 with storno_rn
        else
            replace field->c_1 with broj_fiscal
        endif
    endif

    select pos
    
    skip

enddo

select ( _t_area )

return



// ---------------------------------------------------------------------
// pos brisanje dokumenta
// ---------------------------------------------------------------------
function pos_brisi_dokument( id_pos, id_vd, dat_dok, br_dok )
local _ok := .t.
local _t_area := SELECT()
local _ret := .f.
local _rec

select pos
set order to tag "1"
go top
seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

if !FOUND()
    select ( _t_area )
    return _ret
endif 

log_write( "pos, brisanje racuna broj: " + br_dok + " od " + DTOC(dat_dok) + " poceo", 5 )
	           	
my_use_semaphore_off()
    
if !pos_semaphores_lock()
    select ( _t_area )
    return _ret
endif     

_ret := .t.          				
_rec := dbf_get_rec()

sql_table_update( nil, "BEGIN" )
	
delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT", .f. )

select pos_doks
set filter to
set order to tag "1"
go top
seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

if FOUND() 
    _rec := dbf_get_rec()		
	delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT", .f. )
endif

sql_table_update( nil, "END" )

pos_semaphores_unlock()

// pos_pos check
check_recno( "pos_pos", .f. )
check_recno( "pos_doks", .f. )

my_use_semaphore_on()

log_write( "pos, brisanje racuna broj: " + br_dok + " od " + DTOC(dat_dok) + " zavrsio", 5 )

select (_t_area)

return _ret



// -------------------------------------
// povrat racuna u pripremu
// -------------------------------------
function pos_povrat_rn( cSt_rn, dSt_date )
local nTArea := SELECT()
local _rec
private GetList := {}

if EMPTY( cSt_rn )
    select ( nTArea )
    return
endif

cSt_rn := PADL( ALLTRIM(cSt_rn), 6 )

// napuni pripremu sa stavkama racuna za storno
select pos
seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn

do while !EOF() .and. field->idpos == gIdPos ;
    .and. field->brdok == cSt_rn ;
    .and. field->idvd == "42"

    cT_roba := field->idroba
    select roba
    seek cT_roba
    
    select pos

    _rec := dbf_get_rec()
    hb_hdel( _rec, "rbr" ) 
    
    select _pos_pripr
    append blank
    
    _rec["robanaz"] := roba->naz

    dbf_update_rec( _rec )

    select pos

    skip

enddo

// pos brisi dokument iz baze...
pos_brisi_dokument( gIdPos, VD_RN, dSt_date, cSt_rn )

select ( nTArea )
    
return


// ---------------------------------------------
// import sifrarnika iz fmk
// ---------------------------------------------
function pos_import_fmk_roba()
local _location := fetch_metric( "pos_import_fmk_roba_path", my_user(), PADR( "", 300 ) )
local _cnt := 0
local _rec

O_ROBA

_location := PADR( ALLTRIM( _location ), 300 ) 

Box(, 1, 60)
    @ m_x + 1, m_y + 2 SAY "lokacija:" GET _location PICT "@S50"
    read
BoxC()

if LastKey() == K_ESC
    return
endif

// snimi parametar
set_metric( "pos_import_fmk_roba_path", my_user(), _location )

select ( F_TMP_1 )
if used()
    use
endif

my_use_temp( "TOPS_ROBA", ALLTRIM( _location ), .f., .t. )
index on ("id") tag "ID" 

// ----------
// predji na tops_roba

select tops_roba
set order to tag "ID"
go top

my_use_semaphore_off()
sql_table_update( nil, "BEGIN" )

Box(,1,60)

do while !EOF() 

    _id_roba := field->id

    select roba
    go top
    seek _id_roba

    if !FOUND()
        append blank
    endif
    
    _rec := dbf_get_rec()

    _rec["id"] := tops_roba->id

    _rec["naz"] := tops_roba->naz
    _rec["jmj"] := tops_roba->jmj
    _rec["idtarifa"] := tops_roba->idtarifa
    _rec["barkod"] := tops_roba->barkod

    _rec["mpc"] := tops_roba->cijena1
    _rec["mpc2"] := tops_roba->cijena2

    ++ _cnt
    @ m_x + 1, m_y + 2 SAY "import roba: " + _rec["id"] + ":" + PADR( _rec["naz"], 20 ) + "..."
    update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

    select tops_roba
    skip

enddo

BoxC()

sql_table_update( nil, "END" )
my_use_semaphore_on()

select ( F_TMP_1 )
use

if _cnt > 0
    msgbeep( "Update " + ALLTRIM( STR( _cnt ) ) + " zapisa !" )
endif

close all
return




