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

// ------------------------------------------------------
// povrat dokumenta u pripremu
// ------------------------------------------------------
function povrat_fakt_dokumenta( rezerv, id_firma, id_tip_dok, br_dok, test )
local _vars := hb_hash()
local _brisi_kum := "D"
local _rec, _del_rec, _ok
local _field_ids, _where_block
local _t_rec

IF test == nil
    test := .f.
ENDIF

IF ( PCOUNT() == 0 )
    _vars["idfirma"]  := gFirma
    _vars["idtipdok"] := SPACE(2)
    _vars["brdok"]    := SPACE(8)
ELSE
    _vars["idfirma"]  := id_firma
    _vars["idtipdok"] := id_tip_dok
    _vars["brdok"]    := br_dok
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
id_firma   := _vars["idfirma"]
id_tip_dok := _vars["idtipdok"]
br_dok     := _vars["brdok"]

IF Pitanje("FAKT_POV_DOK", "Dokument " + id_firma + "-" + id_tip_dok + "-" + br_dok + " povuci u pripremu (D/N) ?", "D") == "N"
    CLOSE ALL
    RETURN 0
ENDIF

SELECT fakt
HSEEK id_firma + id_tip_dok + br_dok

// da li dokument uopste postoji ?
if !FOUND()
    MsgBeep( "Trazeni dokument u fakt_fakt ne postoji !" )
endif

if ( fakt->m1 == "X" )
    // izgenerisani dokument
    MsgBeep("Radi se o izgenerisanom dokumentu!!!")
    if Pitanje("IZGEN_CONT", "Zelite li nastaviti?!", "N")=="N"
        close all
        return 0
    endif
endif

// vrati dokument u pripremu    
DO WHILE !EOF() .and. id_firma == field->idfirma .and. id_tip_dok == field->idtipdok .and. br_dok == field->brdok

    SELECT fakt

    _rec := dbf_get_rec()

    SELECT fakt_pripr
    APPEND BLANK

    dbf_update_rec( _rec )

    SELECT fakt
    SKIP

ENDDO

// fakt atributi....
fakt_atributi_server_to_dbf( id_firma, id_tip_dok, br_dok )

 
IF test == .t.
    _brisi_kum := "D"
ELSE
    _brisi_kum := Pitanje( "FAKT_POV_KUM", "Zelite li izbrisati dokument iz datoteke kumulativa (D/N)?", "N" )
ENDIF
    
IF ( _brisi_kum == "D" )

    if !f18_lock_tables({"fakt_fakt", "fakt_doks", "fakt_doks2"})
          MsgBeep("Ne mogu lockovati fakt tables !?")
          return .f.
    endif

    Box(, 5, 70)

        _ok := .t.
        sql_table_update( nil, "BEGIN" )

        // FOREIGN key trazi da se prvo brisu fakt atributi...
        @ m_x + 4, m_y + 2 SAY "delete fakt_fakt_atributi"
        // pobrisi ih sa servera...
        _ok := _ok .and. delete_fakt_atributi_from_server( id_firma, id_tip_dok, br_dok )


        _tbl := "fakt_fakt"
        @ m_x + 1, m_y + 2 SAY "delete " + _tbl

        // algoritam 2  - nivo dokumenta
        select fakt
        _ok := _ok .and. delete_rec_server_and_dbf(_tbl, _vars, 2, "CONT")
        log_write("povrat u pripremu fakt_fakt"  + " : " + id_firma + "-" + id_tip_dok + "-" + br_dok, 2 )

        _tbl := "fakt_doks"
        @ m_x + 2, m_y + 2 SAY "delete " + _tbl
        select fakt_doks
        _ok := _ok .and. delete_rec_server_and_dbf(_tbl, _vars, 1, "CONT" )

        _tbl := "fakt_doks2"
        @ m_x + 3, m_y + 2 SAY "delete " + _tbl
        select fakt_doks2
        _ok := _ok .and. delete_rec_server_and_dbf(_tbl, _vars, 1, "CONT" )

        f18_free_tables({"fakt_fakt", "fakt_doks", "fakt_doks2"})
        sql_table_update( nil, "END" )

        // logiraj operaciju
        log_write( "F18_DOK_OPER: fakt povrat dokumenta u pripremu: " + id_firma + "-" + id_tip_dok + "-" + br_dok, 2 )

    BoxC()

ENDIF 

IF ( _brisi_kum == "N" )
    // u PRIPR resetujem flagove generacije, jer mi je dokument ostao u kumul.
    SELECT fakt_pripr
    SET ORDER TO TAG "1"
    HSEEK id_firma + id_tip_dok + br_dok 
    
    DO WHILE !EOF() .and. fakt_pripr->( field->idfirma + field->idtipdok + field->brdok ) == ( id_firma + id_tip_dok + br_dok )
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


// -----------------------------------------------------
// box - uslovi za povrat dokumenta prema kriteriju
// -----------------------------------------------------
static function _get_vars( vars )
local _tip_dok := vars["tip_dok"]
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

if Pitanje("FAKT_POV_KRITER" ,"Dokumente sa zadanim kriterijumom vratiti u pripremu ???","N")=="N"
    _ret := .f.
    return _ret
endif

// setuj varijable hash matrice
vars["rj"] := _rj
vars["tip_dok"] := _tip_dok
vars["br_dok"] := _br_dok
vars["datumi"] := _datumi
vars["uslov_dokumenti"] := Parsiraj( _br_dok, "brdok", "C" )
vars["uslov_datumi"] := Parsiraj( _datumi, "datdok", "D" )
vars["uslov_tipovi"] := Parsiraj( _tip_dok, "idtipdok", "C" )

return _ret




// ----------------------------------------------------------------------------
// povrat dokumenta prema kriteriju
// ----------------------------------------------------------------------------
function povrat_fakt_po_kriteriju( br_dok, dat_dok, tip_dok, firma )
local nRec
local _t_rec
local _vars := hb_hash()
local _filter
local _id_firma
local _br_dok
local _id_tip_dok
local _del_rec, _ok

if PCOUNT() <> 0

    _vars["br_dok"] := PADR( br_dok, 200 )

	if dat_dok == NIL
		dat_dok := CTOD("")
	endif

    _vars["datumi"] := PADR( DTOC( dat_dok ) , 200 )
	
	if tip_dok == NIL
		tip_dok := ";"
	endif

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

SELECT fakt_doks
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

// setuj filter
_filter := _vars["uslov_dokumenti"]

if !EMPTY( _vars["uslov_datumi"] )
	_filter += " .and. " + _vars["uslov_datumi"]
endif

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

f18_lock_tables({"fakt_doks", "fakt_doks2", "fakt_fakt"})
sql_table_update( nil, "BEGIN" )

DO WHILE !EOF()

    skip 1
    _t_rec := RECNO()
    skip -1

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
    MsgO("Brisem dokumente iz kumulativa: " + _id_firma + "-" + _id_tip_dok + "-" + PADR( _br_dok, 10 ) )

    SELECT fakt
    GO TOP
    SEEK _id_firma + _id_tip_dok + _br_dok

    if FOUND() 

        // brisi fakt....
        _del_rec := dbf_get_rec()
        delete_rec_server_and_dbf( "fakt_fakt", _del_rec, 2, "CONT" )
    
        // brisi fakt_doks
        select fakt_doks
        go top
        seek _id_firma + _id_tip_dok + _br_dok

        if FOUND()
            _del_rec := dbf_get_rec()
            delete_rec_server_and_dbf( "fakt_doks", _del_rec, 1, "CONT" )
        endif

        select fakt_doks2
        go top
        seek _id_firma + _id_tip_dok + _br_dok

        if FOUND()
            _del_rec := dbf_get_rec()
            delete_rec_server_and_dbf( "fakt_doks2", _del_rec, 1, "CONT" )
        endif

        log_write( "F18_DOK_OPER: fakt povrat dokumenta prema kriteriju: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok, 2 )

    endif
    
    MsgC()
    
    SELECT fakt_doks
    GO ( _t_rec )

enddo 

f18_free_tables({"fakt_doks", "fakt_doks2", "fakt_fakt"})
sql_table_update( nil, "END" )

close all
return


// ------------------------------------------
// provjeri status zabrane povrata
// ------------------------------------------
static function _chk_povrat_zabrana( vars )
local _area
local _ret := .t.

// fiscal zabrana
// ako je fiskalni racun u vezi, ovo nema potrebe vracati
// samo uz lozinku

if fiscal_opt_active() .and. vars["idtipdok"] $ "10#11"

    _area := SELECT()
    
    SELECT fakt_doks
    hseek vars["idfirma"] + vars["idtipdok"] + vars["brdok"]
    
    if FOUND()
        if ( fakt_doks->fisc_rn <> 0 .and. fakt_doks->iznos > 0 ) .or. ;
            ( fakt_doks->fisc_rn <> 0 .and. fakt_doks->fisc_st = 0 .and. fakt_doks->iznos < 0 )

            // veza sa fisc_rn postoji
            msgbeep("Za ovaj dokument je izdat fiskalni racun.#Opcija povrata je onemogucena !!!")
            _ret := .f.

            select ( _area )
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
local _firma   := vars["idfirma"]
local _tip_dok := vars["idtipdok"]
local _br_dok  := vars["brdok"]
local _ret     := .t.

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
vars["idfirma"]  := _firma
vars["idtipdok"] := _tip_dok
vars["brdok"]    := _br_dok

return _ret




// ---------------------------------------------------------
// pravi duplikat dokumenta u pripremi...
// ---------------------------------------------------------
function fakt_napravi_duplikat( id_firma, id_tip_dok, br_dok )
local _server := pg_server()
local _qry, _field
local _table, oRow
local _count := 0

if Pitanje(, "Napraviti duplikat dokumenta u pripremi (D/N) ? ", "D" ) == "N"
    return .t.
endif

select ( F_FAKT_PRIPR )
if !Used()
    O_FAKT_PRIPR
endif

_qry := "SELECT * FROM fmk.fakt_fakt " + ;
        " WHERE idfirma = " + _sql_quote( id_firma ) + ;
        " AND idtipdok = " + _sql_quote( id_tip_dok ) + ;
        " AND brdok = " + _sql_quote( br_dok ) + ;
        " ORDER BY idfirma, idtipdok, brdok, rbr " 

_table := _sql_query( _server, _qry )
_table:Refresh()

if _table:LastRec() == 0
    MsgBeep( "Trazeni dokument nisam pronasao !" ) 
    return .t.
endif

do while !_table:EOF()

    oRow := _table:GetRow()

    select fakt_pripr
    append blank
    _rec := dbf_get_rec()
    
    for each _field in _rec:keys
        _rec[ _field ] := oRow:FieldGet( oRow:FieldPos( _field ) )
        if VALTYPE( _rec[ _field ] ) == "C"
            _rec[ _field ] := hb_utf8tostr( _rec[ _field ] )
        endif
    next

    // ako ima koje pride polje obradi ga !!!
    _rec["brdok"] := fakt_prazan_broj_dokumenta()
    _rec["datdok"] := DATE()

    dbf_update_rec( _rec )

    _table:skip()

    ++ _count

enddo

select fakt_pripr
use

if _count > 0
    MsgBeep( "Novoformirani dokument se nalazi u pripremi !" )
endif

return .t.





