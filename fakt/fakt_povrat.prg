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

#include "fakt.ch"


// -----------------------------------------------------
// box - uslovi za povrat dokumenta prema kriteriju
// -----------------------------------------------------
static function _get_vars( vars )
local _tip_dok := vars["rj"]
local _br_dok := vars["br_dok"]
local _datumi := vars["datumi"]
local _rj := vars["rj"]
local _ret := .t.

Box(, 4, 60)
    @ m_x+1, m_y+2 SAY "Rj               "  GEt _rj pict "@!"
    @ m_x+2, m_y+2 SAY "Vrste dokumenata "  GEt _tip_dok pict "@S40"
    @ m_x+3, m_y+2 SAY "Broj dokumenata  "  GEt _br_dok pict "@S40"
    @ m_x+4, m_y+2 SAY "Datumi           "  GET _datumi pict "@S40"
    read
Boxc()

if Pitanje("","Dokumente sa zadanim kriterijumom vratiti u pripremu ???","N")=="N"
    _ret := .f.
    return _ret
endif

// setuj varijable hash matrice
vars["rj"] := _rj
vars["tip_dok"] := _tip_dok
vars["br_dok"] := _br_dok
vars["datumi"] := _datumi
vars["uslov_dokumenti"] := Parsiraj( _br_dok, "BrDok", "C" )
vars["uslov_datumi"] := Parsiraj( _datumi, "DatDok", "D" )
vars["uslov_tipovi"] := Parsiraj( _tip_dok, "IdTipdok", "C" )

return _ret




// ----------------------------------------------
// provjerava stanje lock-ova tabela
// ----------------------------------------------
static function _chk_lock_status()

select fakt
if !FLock()
    Msg("FAKT datoteka je zauzeta ", 3)
    return .f.
endif

select fakt_doks2
if !FLock()
    Msg("DOKS2 datoteka je zauzeta ", 3)
    return .f.
endif

select fakt_doks
if !FLock()
    Msg("DOKS datoteka je zauzeta ", 3)
    return .f.
endif

return .t.


// ----------------------------------------------------------------------------
// povrat dokumenta prema kriteriju
// ----------------------------------------------------------------------------
function Povrat_fakt_po_kriteriju( br_dok, dat_dok, tip_dok, firma )
local nRec
local _vars := hb_hash()
local _filter
local _id_firma
local _br_dok
local _id_tip_dok
local _del_rec, _ok, _field_ids, _where_block

if PCOUNT() <> 0
    _vars["br_dok"] := PADR( br_dok, 200 )
    _vars["datumi"] := PADR( dat_dok , 200 )
    _vars["tip_dok"] := PADR( tip_dok, 200 )
    _vars["rj"] := gFirma
else
    _vars["br_dok"] := SPACE( 200 )
    _vars["datumi"] := SPACE( 200 )
    _vars["tip_dok"] := SPACE( 200 )
    _vars["rj"] := gFirma
endif

O_FAKT
O_FAKT_PRIPR
O_FAKT_DOKS
O_FAKT_DOKS2

SELECT fakt
SET ORDER TO TAG "1"

// daj uslove za povrat dokumenta
if !_get_vars( @_vars )
    close all
    return
endif

Beep(6)

if Pitanje("","Jeste li sigurni ???","N")=="N"
    close all
    return
endif

// provjeri stanje lock-ova
if !_chk_lock_status()
    close all
    return
endif

// setuj filter
_filter := _vars["uslov_dokumenti"]
_filter += " .and. " + _vars["uslov_datumi"]
_filter += " .and. " + _vars["uslov_tipovi"]

if !EMPTY( _vars["rj"] )
    _filter += " .and. idfirma==" + cm2str( _vars["rj"] ) 
endif

_filter := STRTRAN( _filter, ".t..and.", "" )

if _filter == ".t."
    set filter to
else
    set filter to &_filter
endif

GO TOP

DO WHILE !EOF()

    _id_firma := field->idfirma
    _id_tip_dok := field->idtipdok
    _br_dok := field->brdok
    
    SELECT fakt
    SEEK _id_firma + _id_tip_dok + _br_dok

    if !FOUND()
        select fakt_doks
        skip
        loop
    endif

    SELECT fakt
    SEEK _id_firma + _id_tip_dok + _br_dok
        
    // prebaci u pripremu...
    DO WHILE !EOF() .and. _id_firma == field->idfirma .AND. ;
            _id_tip_dok == field->idtipdok .AND. _br_dok == field->brdok

        _rec := dbf_get_rec()
        
        SELECT fakt_pripr
        APPEND BLANK
        
        dbf_update_rec( _rec )

        SELECT fakt        
        SKIP
    ENDDO

    // sada pobrisi iz kumulativa...
    SELECT fakt
    GO TOP
    SEEK _id_firma + _id_tip_dok + _br_dok
 
    MsgO("del fakt")

    DO WHILE !EOF() .and. _id_firma == field->idfirma .AND. ;
            _id_tip_dok == field->idtipdok .AND. _br_dok == field->brdok

        _del_rec := dbf_get_rec()
        _ok := .t.
        _ok := delete_rec_server_and_dbf( "fakt", _del_rec  )
    
        SKIP

    ENDDO
    
    MsgC()
    
    // pobrisi doks i doks2

    _del_rec := hb_hash()
    _del_rec["idfirma"] := _id_firma
    _del_rec["idtipdok"] := _id_tip_dok
    _del_rec["brdok"] := _br_dok
    
    MsgO("del doks")
    _ok := delete_rec_server_and_dbf( "fakt_doks", _del_rec )
    MsgC()

    MsgO("del doks2")
    _ok := delete_rec_server_and_dbf( "fakt_doks2", _del_rec )
    MsgC()

    IF !_ok
        MsgBeep("Ajoooooooj del fakt/doks/doks2 nije ok ?! " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok )
        CLOSE ALL
        RETURN
    ENDIF

    SELECT fakt_doks

ENDDO 

close all
return


// ------------------------------------------
// provjeri status zabrane povrata
// ------------------------------------------
static function _chk_povrat_zabrana( vars )
local _area
local _ret := .t.

// provjeri pravila
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK" + vars["tip_dok"] ))
    
    if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOKDATUM" + vars["tip_dok"] )) == .f.
    
    _area := SELECT()

    select fakt
    hseek vars["id_firma"] + vars["tip_dok"] + vars["br_dok"]
    if FOUND()
        if fakt->datdok <> DATE()
            msgbeep("Datum dokumenta <> tekuci datum#Opcija onemogucena !")
            close all
            _ret := .f.
            return .f.
        endif
    endif
    
    SELECT ( _area )
   
   endif

else        
    msgbeep( cZabrana ) 
    close all
    _ret := .f.
    return _ret
endif

// fiscal zabrana
// ako je fiskalni racun u vezi, ovo nema potrebe vracati
// samo uz lozinku

if gFc_use == "D" .and. vars["tip_dok"] $ "10#11"

    _area := SELECT()
    
    SELECT fakt_doks
    hseek vars["id_firma"] + vars["tip_dok"] + vars["br_dok"]
    
    if FOUND()
        if ( fakt_doks->fisc_rn <> 0 .and. fakt_doks->iznos > 0 ) .or. ;
            ( fakt_doks->fisc_rn <> 0 .and. fakt_doks->fisc_st = 0 .and. fakt_doks->iznos < 0 )
            // veza sa fisc_rn postoji
            msgbeep("Za ovaj dokument je izdat fiskalni racun.#Opcija povrata je onemogucena !!!")
            _ret := .f.
            return _ret
        endif
    endif
    
    select (_area)

endif

return _ret


// -----------------------------------------------------
// vraca box sa uslovima povrata dokumenta
// -----------------------------------------------------
static function _get_povrat_vars( vars )
local _firma := vars["id_firma"]
local _tip_dok := vars["tip_dok"]
local _br_dok := vars["br_dok"]
local _ret := .t.

Box("", 1, 35)

    @ m_x+1, m_y+2 SAY "Dokument:"
    @ m_x+1,col()+1 GET _firma

    @ m_x+1,col()+1 SAY "-"
    @ m_x+1,col()+1 GET _tip_dok

    @ m_x+1,col()+1 SAY "-" GET _br_dok

    read

BoxC()

if LastKey() == K_ESC
    _ret := .f.
    return _ret
endif

// setuj varijable hash matrice
vars["id_firma"] := _firma
vars["tip_dok"] := _tip_dok
vars["br_dok"] := _br_dok

return _ret



// ------------------------------------------------------
// povrat dokumenta u pripremu
// ------------------------------------------------------
function povrat_fakt_dokumenta( rezerv, id_firma, id_tip_dok, br_dok, test )
local _vars := hb_hash()
local _brisi_kum := "D"
local _rec, _del_rec, _ok
local _id_tip_dok, _br_dok, _id_firma
local _field_ids, _where_block
local _t_rec

IF test == nil
    test := .f.
ENDIF

IF ( PCOUNT() == 0 )
    _vars["id_firma"] := gFirma
    _vars["tip_dok"] := SPACE(2)
    _vars["br_dok"] := SPACE(8)
ELSE
    _vars["id_firma"] := id_firma
    _vars["tip_dok"] := id_tip_dok
    _vars["br_dok"] := br_dok
ENDIF

O_FAKT
O_FAKT_PRIPR
O_FAKT_DOKS2
O_FAKT_DOKS

SELECT fakt
SET FILTER TO

SET ORDER TO TAG "1"

IF PCOUNT() == 0  
    // daj mi uslove za povrat dokumenta, nemam navedeno 
    IF !_get_povrat_vars( @_vars )
        CLOSE ALL
        RETURN 0
    ENDIF
ENDIF  

// provjeri zabrane povrata itd...
IF !_chk_povrat_zabrana( _vars )
    CLOSE ALL
    RETURN 0
ENDIF

// ovo su parametri dokumenta
_id_firma := _vars["id_firma"]
_id_tip_dok := _vars["tip_dok"]
_br_dok := _vars["br_dok"]

IF Pitanje("","Dokument " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok + " povuci u pripremu (D/N) ?","D")=="N"
    CLOSE ALL
    RETURN 0
ENDIF

SELECT fakt

// provjeri stanje lock-ova
if !_chk_lock_status()
    close all
    return 0
endif

SELECT fakt
HSEEK _id_firma + _id_tip_dok + _br_dok

if ( fakt->m1 == "X" )
    // izgenerisani dokument
    MsgBeep("Radi se o izgenerisanom dokumentu!!!")
    if Pitanje(,"Zelite li nastaviti?!", "N")=="N"
        close all
        return 0
    endif
endif

// vrati dokument u pripremu    
DO WHILE !EOF() .and. _id_firma == field->idfirma .and. _id_tip_dok == field->idtipdok .and. _br_dok == field->brdok
            
    SELECT fakt
        
    _rec := dbf_get_rec()
            
    SELECT fakt_pripr
    APPEND BLANK
       
    dbf_update_rec( _rec )
            
    SELECT fakt
    SKIP

ENDDO

IF test == .t.
    _brisi_kum := "D"
ELSE
    _brisi_kum := Pitanje( "", "Zelite li izbrisati dokument iz datoteke kumulativa (D/N)?", "N" )
ENDIF
    
IF ( _brisi_kum == "D" )

    SELECT fakt
    GO TOP
    SEEK _id_firma + _id_tip_dok + _br_dok

    MsgO("del fakt")

    DO WHILE !EOF() .and. _id_firma == field->idfirma .and. _id_tip_dok == field->idtipdok .and. _br_dok == field->brdok
        
        SKIP 1
        _t_rec := RECNO()
        SKIP -1

        _del_rec := dbf_get_rec()
        _ok := .t.
        _ok := delete_rec_server_and_dbf( "fakt", _del_rec )

        GO ( _t_rec )

    ENDDO

    MsgC()

    // pobrisi sada doks i doks2
    MsgO("del doks")
    select fakt_doks
    set order to tag "1"
    go top
    seek _id_firma + _id_tip_dok + _br_dok

    if found()
        _del_rec := dbf_get_rec()
        _ok := delete_rec_server_and_dbf( "fakt_doks", _del_rec )
    endif

    MsgC()

    MsgO("del doks2")
    select fakt_doks2
    set order to tag "1"
    go top
    seek _id_firma + _id_tip_dok + _br_dok

    if found()
        _del_rec := dbf_get_rec()
        _ok := delete_rec_server_and_dbf( "fakt_doks2", _del_rec )
    endif

    MsgC()

    IF !_ok
        MsgBeep("Ajoooooooj del fakt/doks/doks2 nije ok ?! " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok )
        CLOSE ALL
        return 0
    ENDIF
          
ENDIF 

IF ( _brisi_kum == "N" )
    // u PRIPR resetujem flagove generacije, jer mi je dokument ostao u kumul.
    SELECT fakt_pripr
    SET ORDER TO TAG "1"
    HSEEK _id_firma + _id_tip_dok + _br_dok 
    
    DO WHILE !EOF() .and. fakt_pripr->( field->idfirma + field->idtipdok + field->brdok ) == ( _id_firma + _id_tip_dok + _br_dok )
        IF ( fakt_pripr->m1 == "X" )
            _rec := dbf_get_rec()
            _rec["m1"] := SPACE(1)    
            dbf_update_rec( _rec )
        ENDIF
        SKIP
    ENDDO
ENDIF

close all
return 1



