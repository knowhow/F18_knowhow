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


#include "fakt.ch"

static __import_dbf_path 
static __export_dbf_path
static __import_zip_name
static __export_zip_name


// --------------------------------------------------------------------
// fakt: udaljena razmjena podataka modul FAKT->FAKT
// --------------------------------------------------------------------
function fakt_udaljena_razmjena_podataka()
local _opc := {}
local _opcexe := {}
local _izbor := 1

__import_dbf_path := ""
__export_dbf_path := my_home() + "export_dbf" + SLASH
__import_zip_name := "fakt_exp.zip"
__export_zip_name := "fakt_exp.zip"

// kreiraj ove direktorije odmah
_dir_create( __export_dbf_path )

AADD(_opc,"1. => export podataka               ")
AADD(_opcexe, {|| _fakt_export() })
AADD(_opc,"2. <= import podataka    ")
AADD(_opcexe, {|| _fakt_import() })

f18_menu( "razmjena", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return


// ----------------------------------------
// export podataka modula FAKT
// ----------------------------------------
static function _fakt_export()
local _vars := hb_hash()
local _exported_rec
local _error
local _a_data := {}

// uslovi exporta
if !_vars_export( @_vars )
    return
endif

// pobrisi u folderu tmp fajlove ako postoje
delete_exp_files( __export_dbf_path, "fakt" )

// exportuj podatake
_exported_rec := __export( _vars, @_a_data )

// zatvori sve tabele prije operacije pakovanja
my_close_all_dbf()

// arhiviraj podatke
if _exported_rec > 0 
   
    // kompresuj ih u zip fajl za prenos
    _error := _compress_files( "fakt", __export_dbf_path )

    // sve u redu
    if _error == 0
        
        // pobrisi fajlove razmjene
        delete_exp_files( __export_dbf_path, "fakt" )

        // otvori folder sa exportovanim podacima
        open_folder( __export_dbf_path )

    endif

endif

// vrati se na glavni direktorij
DirChange( my_home() )

if ( _exported_rec > 0 )

    MsgBeep( "Exportovao " + ALLTRIM(STR( _exported_rec )) + " dokumenta." )
	
	// printaj izvjestaj
	print_imp_exp_report( _a_data )

endif

my_close_all_dbf()
return



// ----------------------------------------
// import podataka modula FAKT
// ----------------------------------------
static function _fakt_import()
local _imported_rec
local _vars := hb_hash()
local _imp_file 
local _imp_path := fetch_metric( "fakt_import_path", my_user(), PADR("", 300) )
local _a_data := {}

Box(, 1, 70)
	@ m_x + 1, m_y + 2 SAY "import path:" GET _imp_path PICT "@S50"
	read 
BoxC()
	
if LastKey() == K_ESC
	return
endif	

// snimi u parametre
__import_dbf_path := ALLTRIM( _imp_path )
set_metric( "fakt_import_path", my_user(), _imp_path )

// import fajl iz liste
_imp_file := get_import_file( "fakt", __import_dbf_path )

if _imp_file == NIL .or. EMPTY( _imp_file )
    MsgBeep( "Nema odabranog import fajla !????" )
    return
endif

// parametri
if !_vars_import( @_vars )
    return
endif

if !import_file_exist( _imp_file )
    // nema fajla za import ?
    MsgBeep( "import fajl ne postoji !??? prekidam operaciju" )
    return
endif

// dekompresovanje podataka
if _decompress_files( _imp_file, __import_dbf_path, __import_zip_name ) <> 0
    // ako je bilo greske
    return
endif

#ifdef __PLATFORM__UNIX
	set_file_access( __import_dbf_path )
#endif

// import procedura
_imported_rec := __import( _vars, @_a_data )

// zatvori sve
my_close_all_dbf()

// brisi fajlove importa
delete_exp_files( __import_dbf_path, "fakt" )

if ( _imported_rec > 0 )

    // nakon uspjesnog importa...
    if Pitanje(, "Pobrisati fajl razmjne ?", "D" ) == "D"
        // brisi zip fajl...
        delete_zip_files( _imp_file )
    endif

    MsgBeep( "Importovao " + ALLTRIM( STR( _imported_rec ) ) + " dokumenta." )

	// printaj izvjestaj
	print_imp_exp_report( _a_data )

endif

// vrati se na home direktorij nakon svega
DirChange( my_home() )

return


// -------------------------------------------------------------
// -------------------------------------------------------------
function print_imp_exp_report( data )
local _i, _cnt
local _line
local _x_docs, _import_docs, _delete_docs, _exp_docs
local _descr

// struktura data
// data[1] = opis
// data[2] = broj dokumenta
// data[3] = idpartner
// data[4] = idkonto
// data[5] = opis partner
// data[6] = iznos
// data[7] = datum dokumenta

START PRINT CRET

?

P_10CPI
P_COND

? "REZUTATI OPERACIJE IMPORT/EXPORT PODATAKA"
?

_line := REPLICATE( "-", 5 )
_line += SPACE(1)
_line += REPLICATE( "-", 10 )
_line += SPACE(1)
_line += REPLICATE( "-", 16 )
_line += SPACE(1)
_line += REPLICATE( "-", 8 )
_line += SPACE(1)
_line += REPLICATE( "-", 30 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )

? _line
? PADR( "R.br", 5 ), PADC( "Operacija", 10 ), PADC( "Dokument", 16 ), PADC( "Datum", 8 ), PADR( "Partner opis", 30 ), PADC( "Iznos", 12 )
? _line

_cnt := 0

_x_docs := 0
_import_docs := 0
_delete_docs := 0
_exp_docs := 0

for _i := 1 to LEN( data )

	_descr := ALLTRIM( data[ _i, 1 ] ) 

	if _descr == "x"
		++ _x_docs
	elseif _descr == "import"
		++ _import_docs
	elseif _descr == "export"
		++ _exp_docs
	elseif _descr == "delete"
		++ _delete_docs
	endif

	// r.br
	? PADL( ALLTRIM( STR( ++ _cnt ) ), 4 ) + "."

	// opis
	@ prow(), pcol() + 1 SAY PADL( _descr, 10 )

	// dokument
	@ prow(), pcol() + 1 SAY PADR( data[ _i, 2 ], 16 )

	// datum
	@ prow(), pcol() + 1 SAY DTOC( data[ _i, 7 ] )

	// partner
	@ prow(), pcol() + 1 SAY PADR( data[ _i, 5 ], 27 ) + "..."

	// iznos
	@ prow(), pcol() + 1 SAY STR( data[ _i, 6 ], 12, 2 )


next


? _line

if _import_docs > 0
	? "Broj importovanih dokumenta: " + ALLTRIM( STR( _import_docs ) )
endif

if _exp_docs > 0
	? "Broj exportovanih dokumenta: " + ALLTRIM( STR( _exp_docs ) )
endif

if _delete_docs > 0
	? "    Broj brisanih dokumenta: " + ALLTRIM( STR( _delete_docs ) )
endif

if _x_docs > 0
	? "  Broj prekocenih dokumenta: " + ALLTRIM( STR( _x_docs ) )
endif

? _line


FF
END PRINT

return



// -------------------------------------------
// uslovi exporta dokumenta
// -------------------------------------------
static function _vars_export( vars )
local _ret := .f.
local _dat_od := fetch_metric( "fakt_export_datum_od", my_user(), DATE() - 30 )
local _dat_do := fetch_metric( "fakt_export_datum_do", my_user(), DATE() )
local _rj := fetch_metric( "fakt_export_lista_rj", my_user(), PADR( "10;", 200 ) )
local _vrste_dok := fetch_metric( "fakt_export_vrste_dokumenata", my_user(), PADR( "10;11;", 200 ) )
local _br_dok := fetch_metric( "fakt_export_brojevi_dokumenata", my_user(), PADR("", 300) )
local _exp_sif := fetch_metric( "fakt_export_sifrarnik", my_user(), "D" )
local _prim_sif := fetch_metric( "fakt_export_duzina_primarne_sifre", my_user(), 0 )
local _exp_path := fetch_metric( "fakt_export_path", my_user(), PADR("", 300) )
local _prom_rj_src := SPACE(2)
local _prom_rj_dest := SPACE(2) 
local _x := 1

if EMPTY( ALLTRIM( _exp_path ) )
	_exp_path := PADR( __export_dbf_path, 300 )
endif

Box(, 13, 70 )

    @ m_x + _x, m_y + 2 SAY "*** Uslovi exporta dokumenata"

    ++ _x
    ++ _x
        
    @ m_x + _x, m_y + 2 SAY "Vrste dokumenata:" GET _vrste_dok PICT "@S40"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Brojevi dokumenata:" GET _br_dok PICT "@S40"
    
	++ _x

    @ m_x + _x, m_y + 2 SAY "Datumski period od" GET _dat_od
    @ m_x + _x, col() + 1 SAY "do" GET _dat_do

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Uzeti u obzir sljedece rj:" GET _rj PICT "@S30"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Svoditi na primarnu sifru (duzina primarne sifre):" GET _prim_sif PICT "9"
    
 	++ _x

    @ m_x + _x, m_y + 2 SAY "Promjena radne jedinice" GET _prom_rj_src
    @ m_x + _x, col() + 1 SAY "u" GET _prom_rj_dest

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Eksportovati sifrarnike (D/N) ?" GET _exp_sif PICT "@!" VALID _exp_sif $ "DN"

	++ _x
	++ _x

    @ m_x + _x, m_y + 2 SAY "Eksport lokacija:" GET _exp_path PICT "@S50"

    read

BoxC()

// snimi parametre
if LastKey() <> K_ESC

    _ret := .t.

    set_metric( "fakt_export_datum_od", my_user(), _dat_od )
    set_metric( "fakt_export_datum_do", my_user(), _dat_do )
    set_metric( "fakt_export_lista_rj", my_user(), _rj )
    set_metric( "fakt_export_vrste_dokumenata", my_user(), _vrste_dok )
    set_metric( "fakt_export_sifrarnik", my_user(), _exp_sif )
    set_metric( "fakt_export_duzina_primarne_sifre", my_user(), _prim_sif )
    set_metric( "fakt_export_path", my_user(), _exp_path )
	set_metric( "fakt_export_brojevi_dokumenata", my_user(), _br_dok )

	// export path, set static var
	__export_dbf_path := ALLTRIM( _exp_path )

    vars["datum_od"] := _dat_od
    vars["datum_do"] := _dat_do
    vars["rj"] := _rj
    vars["vrste_dok"] := _vrste_dok
    vars["export_sif"] := _exp_sif
    vars["prim_sif"] := _prim_sif
    vars["rj_src"] := _prom_rj_src
    vars["rj_dest"] := _prom_rj_dest
	vars["brojevi_dok"] := _br_dok
    
endif

return _ret



// -------------------------------------------
// uslovi importa dokumenta
// -------------------------------------------
static function _vars_import( vars )
local _ret := .f.
local _dat_od := fetch_metric( "fakt_import_datum_od", my_user(), CTOD("") )
local _dat_do := fetch_metric( "fakt_import_datum_do", my_user(), CTOD("") )
local _rj := fetch_metric( "fakt_import_lista_rj", my_user(), PADR( "", 200 ) )
local _vrste_dok := fetch_metric( "fakt_import_vrste_dokumenata", my_user(), PADR( "", 200 ) )
local _br_dok := fetch_metric( "fakt_import_brojevi_dokumenata", my_user(), PADR( "", 300 ) )
local _zamjeniti_dok := fetch_metric( "fakt_import_zamjeniti_dokumente", my_user(), "N" )
local _zamjeniti_sif := fetch_metric( "fakt_import_zamjeniti_sifre", my_user(), "N" )
local _iz_fmk := fetch_metric( "fakt_import_iz_fmk", my_user(), "N" )
local _imp_path := fetch_metric( "fakt_import_path", my_user(), PADR("", 300) )
local _x := 1

if EMPTY( ALLTRIM( _imp_path) )
	_imp_path := PADR( __import_dbf_path, 300 )
endif

Box(, 15, 70 )

    @ m_x + _x, m_y + 2 SAY "*** Uslovi importa dokumenata"

    ++ _x
    ++ _x
        
    @ m_x + _x, m_y + 2 SAY "Vrste dokumenata (prazno-sve):" GET _vrste_dok PICT "@S30"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Brojevi dokumenata (prazno-sve):" GET _br_dok PICT "@S30"
    
	++ _x
    
	@ m_x + _x, m_y + 2 SAY "Datumski period od" GET _dat_od
    @ m_x + _x, col() + 1 SAY "do" GET _dat_do

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Uzeti u obzir sljedece radne jedinice:" GET _rj PICT "@S30"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Zamjeniti postojece dokumente novim (D/N):" GET _zamjeniti_dok PICT "@!" VALID _zamjeniti_dok $ "DN"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Zamjeniti postojece sifre novim (D/N):" GET _zamjeniti_sif PICT "@!" VALID _zamjeniti_sif $ "DN"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Import fajl dolazi iz FMK (D/N) ?" GET _iz_fmk PICT "@!" VALID _iz_fmk $ "DN"

	++ _x
	++ _x

    @ m_x + _x, m_y + 2 SAY "Import lokacija:" GET _imp_path PICT "@S50"

    read

BoxC()

// snimi parametre
if LastKey() <> K_ESC

    _ret := .t.

    set_metric( "fakt_import_datum_od", my_user(), _dat_od )
    set_metric( "fakt_import_datum_do", my_user(), _dat_do )
    set_metric( "fakt_import_lista_rj", my_user(), _rj )
    set_metric( "fakt_import_vrste_dokumenata", my_user(), _vrste_dok )
    set_metric( "fakt_import_zamjeniti_dokumente", my_user(), _zamjeniti_dok )
    set_metric( "fakt_import_zamjeniti_sifre", my_user(), _zamjeniti_sif )
    set_metric( "fakt_import_iz_fmk", my_user(), _iz_fmk )
    set_metric( "fakt_import_path", my_user(), _imp_path )
	set_metric( "fakt_import_brojevi_dokumenata", my_user(), _br_dok )

	// set static var
	__import_dbf_path := ALLTRIM( _imp_path )

    vars["datum_od"] := _dat_od
    vars["datum_do"] := _dat_do
    vars["rj"] := _rj
    vars["vrste_dok"] := _vrste_dok
    vars["zamjeniti_dokumente"] := _zamjeniti_dok
    vars["zamjeniti_sifre"] := _zamjeniti_sif
    vars["import_iz_fmk"] := _iz_fmk
    vars["brojevi_dok"] := _br_dok
    
endif

return _ret



// -------------------------------------------
// export podataka
// -------------------------------------------
static function __export( vars, a_details )
local _ret := 0
local _id_firma, _id_vd, _br_dok
local _app_rec
local _cnt := 0
local _dat_od, _dat_do, _rj, _vrste_dok, _export_sif
local _usl_rj, _usl_br_dok
local _id_partn
local _id_roba
local _prim_sif
local _rj_src, _rj_dest, _brojevi_dok
local _change_rj := .f.
local _detail_rec

// uslovi za export ce biti...
_dat_od := vars["datum_od"]
_dat_do := vars["datum_do"]
_rj := ALLTRIM( vars["rj"] )
_vrste_dok := ALLTRIM( vars["vrste_dok"] )
_export_sif := ALLTRIM( vars["export_sif"] )
_prim_sif := vars["prim_sif"]
_rj_src := vars["rj_src"]
_rj_dest := vars["rj_dest"]
_brojevi_dok := vars["brojevi_dok"]
 
// treba li mjenjati radne jedinice
if !EMPTY( _rj_src ) .and. !EMPTY( _rj_dest )
	_change_rj := .t.
endif

// kreiraj tabele exporta
_cre_exp_tbls( __export_dbf_path )

// otvori export tabele za pisanje podataka
_o_exp_tables( __export_dbf_path )

// otvori lokalne tabele za prenos
_o_tables()

Box(, 2, 65 )

@ m_x + 1, m_y + 2 SAY "... export fakt dokumenata u toku"

select fakt_doks
set order to tag "1"
go top

do while !EOF()

    _id_firma := field->idfirma
    _id_vd := field->idtipdok
    _br_dok := field->brdok
    _id_partn := field->idpartner

    // provjeri uslove ?!??

    // lista konta...
    if !EMPTY( _rj )

        _usl_rj := Parsiraj( ALLTRIM(_rj), "idfirma" )

        if !( &_usl_rj )
            skip
            loop
        endif

    endif

	if !EMPTY( _brojevi_dok )
		_usl_br_dok := Parsiraj( ALLTRIM( _brojevi_dok), "brdok" )
		if !( &_usl_br_dok )
			skip
			loop
		endif
	endif

    // lista dokumenata...
    if !EMPTY( _vrste_dok )
        if !( field->idtipdok $ _vrste_dok )
            skip
            loop
        endif
    endif

    // datumski uslov...
    if _dat_od <> CTOD("") 
        if ( field->datdok < _dat_od )
            skip
            loop
        endif
    endif

    if _dat_do <> CTOD("")
        if ( field->datdok > _dat_do )
            skip
            loop
        endif
    endif

    // ako je sve zadovoljeno !
    // dodaj zapis u tabelu e_doks
    _app_rec := dbf_get_rec()

	if _change_rj
		if _app_rec["idfirma"] == _rj_src
			_app_rec["idfirma"] := _rj_dest
		endif
	endif

    _detail_rec := hb_hash()
    _detail_rec["dokument"] := _app_rec["idfirma"] + "-" + _app_rec["idtipdok"] + "-" + _app_rec["brdok"]
    _detail_rec["idpartner"] := _app_rec["idpartner"]
    _detail_rec["idkonto"] := ""
    _detail_rec["partner"] := _app_rec["partner"]
    _detail_rec["iznos"] := _app_rec["iznos"]
    _detail_rec["datum"] := _app_rec["datdok"]
    _detail_rec["tip"] := "export"

	// dodaj u detalje
	add_to_details( @a_details, _detail_rec )

    select e_doks
    append blank
    dbf_update_rec( _app_rec )    

    ++ _cnt
    @ m_x + 2, m_y + 2 SAY PADR(  PADL( ALLTRIM(STR( _cnt )), 6 ) + ". " + "dokument: " + _id_firma + "-" + _id_vd + "-" + ALLTRIM( _br_dok ), 50 )

    // dodaj zapis i u tabelu e_fakt
    select fakt
    set order to tag "1"
    go top
    seek _id_firma + _id_vd + _br_dok

    _r_br := 0

    do while !EOF() .and. field->idfirma == _id_firma .and. field->idtipdok == _id_vd .and. field->brdok == _br_dok

        // uzmi robu...
        _id_roba := field->idroba

        // svodi na primarnu sifru
        if _prim_sif > 0
            _id_roba := PADR( _id_roba, _prim_sif )
        endif

        // upisi zapis u tabelu e_fakt
        _app_rec := dbf_get_rec()
        
		if _change_rj
			if _app_rec["idfirma"] == _rj_src
				_app_rec["idfirma"] := _rj_dest
			endif
		endif

        if _prim_sif > 0 
            _app_rec["rbr"] := PADL( ALLTRIM( STR( ++ _r_br ) ), 3 )
            _app_rec["idroba"] := _id_roba
        endif

        // prvo potrazi da li postoji ovaj zapis...
        select e_fakt
        set order to tag "2"
        
        if _prim_sif > 0

            go top
            seek _id_firma + _id_vd + _br_dok + _id_roba
        
            if !FOUND()
                append blank
                dbf_update_rec( _app_rec )
            else
                replace field->kolicina with field->kolicina + _app_rec["kolicina"]
            endif

        else

            append blank
            dbf_update_rec( _app_rec )

        endif

        // uzmi sada robu sa ove stavke pa je ubaci u e_roba
        select roba
        hseek _id_roba

        if FOUND() .and. _export_sif == "D"
            _app_rec := dbf_get_rec()        
            select e_roba
            set order to tag "ID"
            seek _id_roba
            if !FOUND()
                append blank
                dbf_update_rec( _app_rec )
                // napuni i sifk, sifv parametre
                _fill_sifk( "ROBA", _id_roba )
            endif
        endif

        // idi dalje...
        select fakt
        skip

    enddo

    // fakt_doks2
    select fakt_doks2
    set order to tag "1"
    go top
    seek _id_firma + _id_vd + _br_dok

    do while !EOF() .and. field->idfirma == _id_firma .and. field->idtipdok == _id_vd .and. field->brdok == _br_dok

        _app_rec := dbf_get_rec()

        select e_doks2
        append blank
        dbf_update_rec( _app_rec )

        select fakt_doks2
        skip

    enddo 

    // e sada mozemo komotno ici na export partnera
    select partn
    hseek _id_partn 
    if FOUND() .and. _export_sif == "D"
        _app_rec := dbf_get_rec()
        select e_partn
        set order to tag "ID"
        seek _id_partn
        if !FOUND()
            append blank
            dbf_update_rec( _app_rec )
            // napuni i sifk, sifv parametre
            _fill_sifk( "PARTN", _id_partn )
        endif
    endif

    select fakt_doks
    skip

enddo

BoxC()

if ( _cnt > 0 )
    _ret := _cnt
endif

return _ret


// ----------------------------------------------------------------
// dodaj u matricu sa detaljima
// ----------------------------------------------------------------
function add_to_details( details, rec )

AADD( details, { rec["tip"], ;
                rec["dokument"], ;
                rec["idpartner"], ;
                rec["idkonto"], ;
	            rec["partner"], ;
	            rec["iznos"], ;
	            rec["datum"] } )

return


// ----------------------------------------
// import podataka
// ----------------------------------------
static function __import( vars, a_details )
local _ret := 0
local _id_firma, _id_vd, _br_dok
local _app_rec
local _cnt := 0
local _dat_od, _dat_do, _rj, _vrste_dok, _zamjeniti_dok, _zamjeniti_sif, _iz_fmk
local _roba_id, _partn_id
local _usl_rj, _usl_br_dok
local _sif_exist
local _fmk_import := .f.
local _redni_broj := 0
local _total_doks := 0
local _total_fakt := 0
local _gl_brojac := 0
local _brojevi_dok
local _detail_rec

// lokuj potrebne tabele
if !f18_lock_tables({"fakt_doks", "fakt_doks2", "fakt_fakt"})
	return _cnt
endif

sql_table_update( nil, "BEGIN" )

// ovo su nam uslovi za import...
_dat_od := vars["datum_od"]
_dat_do := vars["datum_do"]
_rj := vars["rj"]
_vrste_dok := vars["vrste_dok"]
_zamjeniti_dok := vars["zamjeniti_dokumente"]
_zamjeniti_sif := vars["zamjeniti_sifre"]
_iz_fmk := vars["import_iz_fmk"]
_brojevi_dok := vars["brojevi_dok"]
 
if _iz_fmk == "D"
    _fmk_import := .t.
endif

// otvaranje export tabela
_o_exp_tables( __import_dbf_path, nil )

// otvori potrebne tabele za import podataka
_o_tables()

// broj zapisa u import tabelama
select e_doks
_total_doks := RECCOUNT2()

select e_fakt
_total_fakt := RECCOUNT2()

select e_doks
set order to tag "1"
go top

Box(, 3, 70 )

@ m_x + 1, m_y + 2 SAY PADR( "... import fakt dokumenata u toku ", 69 ) COLOR "I"
@ m_x + 2, m_y + 2 SAY "broj zapisa doks/" + ALLTRIM(STR( _total_doks )) + ", fakt/" + ALLTRIM(STR( _total_fakt ))


do while !EOF()

    _id_firma := field->idfirma
    _id_vd := field->idtipdok
    _br_dok := field->brdok

    // uslovi, provjera...

    // datumi...
    if _dat_od <> CTOD( "" ) 
        if field->datdok < _dat_od
            skip
            loop
        endif
    endif

    if _dat_do <> CTOD( "" )
        if field->datdok > _dat_do
            skip
            loop
        endif
    endif

    // lista konta...
    if !EMPTY( _rj )

        _usl_rj := Parsiraj( ALLTRIM(_rj), "idfirma" )

        if !( &_usl_rj )
            skip
            loop
        endif

    endif

    // brojevi dokumenata
    if !EMPTY( _brojevi_dok )

        _usl_br_dok := Parsiraj( ALLTRIM(_brojevi_dok), "brdok" )

        if !( &_usl_br_dok )
            skip
            loop
        endif

    endif


    // lista dokumenata...
    if !EMPTY( _vrste_dok )
        if !( field->idtipdok $ _vrste_dok )
            skip
            loop
        endif
    endif

    // da li postoji u prometu vec ?
    if _vec_postoji_u_prometu( _id_firma, _id_vd, _br_dok )

		select e_doks
		_app_rec := dbf_get_rec()
    
        _detail_rec := hb_hash()
        _detail_rec["dokument"] := _app_rec["idfirma"] + "-" + _app_rec["idtipdok"] + "-" + _app_rec["brdok"]
        _detail_rec["idpartner"] := _app_rec["idpartner"]
        _detail_rec["idkonto"] := ""
        _detail_rec["partner"] := _app_rec["partner"]
        _detail_rec["iznos"] := _app_rec["iznos"]
        _detail_rec["datum"] := _app_rec["datdok"]

        if _zamjeniti_dok == "D"

            // dokumente iz fakt, fakt_doks brisi !
            _detail_rec["tip"] := "delete"
			add_to_details( @a_details, _detail_rec )

            _ok := .t.
            _ok := del_fakt_doc( _id_firma, _id_vd, _br_dok )

        else

            _detail_rec["tip"] := "x"
			add_to_details( @a_details, _detail_rec )

			skip
            loop

        endif

    endif

    // zikni je u nasu tabelu doks
    select e_doks
    _app_rec := dbf_get_rec()

    _detail_rec := hb_hash()
    _detail_rec["dokument"] := _app_rec["idfirma"] + "-" + _app_rec["idtipdok"] + "-" + _app_rec["brdok"]
    _detail_rec["idpartner"] := _app_rec["idpartner"]
    _detail_rec["idkonto"] := ""
    _detail_rec["partner"] := _app_rec["partner"]
    _detail_rec["iznos"] := _app_rec["iznos"]
    _detail_rec["datum"] := _app_rec["datdok"]
    _detail_rec["tip"] := "import"

	// dodaj u detalje
	add_to_details( @a_details, _detail_rec )

    select fakt_doks
	append blank
    update_rec_server_and_dbf( "fakt_doks", _app_rec, 1, "CONT" )

    ++ _cnt
    @ m_x + 3, m_y + 2 SAY PADR( PADL( ALLTRIM( STR(_cnt) ), 5 ) + ". dokument: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 60 )

    // zikni je u nasu tabelu fakt
    select e_fakt
    set order to tag "1"
    go top
    seek _id_firma + _id_vd + _br_dok

    // setuj novi redni broj stavke
    _redni_broj := 0

    // prebaci mi stavke tabele FAKT
    do while !EOF() .and. field->idfirma == _id_firma .and. field->idtipdok == _id_vd .and. field->brdok == _br_dok
        
        _app_rec := dbf_get_rec()

        // setuj redni broj automatski...
        _app_rec["rbr"] := PADL( ALLTRIM(STR( ++_redni_broj )), 3 )
        // reset podbroj
        _app_rec["podbr"] := ""

        // uvecaj i globalni brojac stavki...
        _gl_brojac += _redni_broj

        @ m_x + 3, m_y + 40 SAY "stavka: " + ALLTRIM(STR( _gl_brojac )) + " / " + _app_rec["rbr"] 

        select fakt
		append blank
        update_rec_server_and_dbf( "fakt_fakt", _app_rec, 1, "CONT" )

        select e_fakt
        skip

    enddo

    // upisi i doks2 tabelu
    select e_doks2
    set order to tag "1"
    go top
    seek _id_firma + _id_vd + _br_dok

    do while !EOF() .and. field->idfirma == _id_firma .and. field->idtipdok == _id_vd .and. field->brdok == _br_dok

        _app_rec := dbf_get_rec()
        
        select fakt_doks2
		append blank
        update_rec_server_and_dbf( "fakt_doks2", _app_rec, 1, "CONT" )
        
        select e_doks2
        skip

    enddo

    select e_doks
    skip

enddo
   
// zavrsi transakciju
f18_free_tables({"fakt_doks", "fakt_doks2", "fakt_fakt"})
sql_table_update( nil, "END" )

// ako je sve ok, predji na import tabela sifrarnika
if _cnt > 0

    // ocisti mi 3 red
    @ m_x + 3, m_y + 2 SAY PADR( "", 69 )

    // update tabele roba
    update_table_roba( _zamjeniti_sif, _fmk_import )

    // update tabele partnera
    update_table_partn( _zamjeniti_sif, _fmk_import )

    // odradi update tabela sifk, sifv
    update_sifk_sifv( _fmk_import )

endif

BoxC()

if _cnt > 0
    _ret := _cnt
endif

return _ret



// ---------------------------------------------------------------------
// provjerava da li dokument vec postoji u prometu
// ---------------------------------------------------------------------
static function _vec_postoji_u_prometu( id_firma, id_vd, br_dok )
local _t_area := SELECT()
local _ret := .t.

select fakt_doks
go top
seek id_firma + id_vd + br_dok

if !FOUND()
    _ret := .f.
endif

select (_t_area)
return _ret




// ----------------------------------------------------------
// brisi dokument iz fakt-a
// ----------------------------------------------------------
static function del_fakt_doc( id_firma, id_vd, br_dok )
local _t_area := SELECT()
local _del_rec, _t_rec 
local _ret := .f.

select fakt
set order to tag "1"
go top
seek id_firma + id_vd + br_dok

if FOUND()
	_ret := .t.
	// brisi fakt_fakt
    _del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "fakt_fakt", _del_rec, 2, "CONT" )
endif

// brisi fakt_doks
select fakt_doks
set order to tag "1"
go top
seek id_firma + id_vd + br_dok
if FOUND()
	_del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "fakt_doks", _del_rec, 1, "CONT" )
endif
    
// doks2
select fakt_doks2
set order to tag "1"
go top
seek id_firma + id_vd + br_dok
if FOUND()
	_del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "fakt_doks2", _del_rec, 1, "CONT" )
endif

select ( _t_area )
return _ret



// ----------------------------------------
// kreiranje tabela razmjene
// ----------------------------------------
static function _cre_exp_tbls( use_path )
local _cre 

if use_path == NIL
    use_path := my_home()
endif

// provjeri da li postoji direktorij, pa ako ne - kreiraj
_dir_create( use_path )

// tabela fakt
O_FAKT
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_fakt") from ( my_home() + "struct")

// tabela doks
O_FAKT_DOKS
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_doks") from ( my_home() + "struct")

// tabela doks
O_FAKT_DOKS2
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_doks2") from ( my_home() + "struct")

// tabela roba
O_ROBA
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_roba") from ( my_home() + "struct")

// tabela partn
O_PARTN
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_partn") from ( my_home() + "struct")

// tabela sifk
O_SIFK
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_sifk") from ( my_home() + "struct")

// tabela sifv
O_SIFV
copy structure extended to ( my_home() + "struct" )
use
create ( use_path + "e_sifv") from ( my_home() + "struct")


return


// ----------------------------------------------------
// otvaranje potrebnih tabela za prenos
// ----------------------------------------------------
static function _o_tables()

O_FAKT
O_FAKT_DOKS
O_FAKT_DOKS2
O_SIFK
O_SIFV
O_PARTN
O_ROBA

return




// ----------------------------------------------------
// otvranje export tabela
// ----------------------------------------------------
static function _o_exp_tables( use_path, from_fmk )
local _dbf_name

if ( use_path == NIL )
    use_path := my_home()
endif

if ( from_fmk == NIL )
    from_fmk := .f.
endif

log_write("otvaram fakt tabele importa i pravim indekse...", 9 )

// zatvori sve prije otvaranja ovih tabela
my_close_all_dbf()

// setuj ove tabele kao temp tabele
_dbf_name := "e_doks2"
select ( F_TMP_E_DOKS2 )
my_use_temp( "E_DOKS2", use_path + _dbf_name, .f., .t. )
index on ( idfirma + idtipdok + brdok ) tag "1"

_dbf_name := "e_fakt"
select ( F_TMP_E_FAKT )
my_use_temp( "E_FAKT", use_path + _dbf_name, .f., .t. )
index on ( idfirma + idtipdok + brdok + rbr ) tag "1"
index on ( idfirma + idtipdok + brdok + idroba ) tag "2"

_dbf_name := "e_doks"
select ( F_TMP_E_DOKS )
my_use_temp( "E_DOKS", use_path + _dbf_name, .f., .t. )
index on ( idfirma + idtipdok + brdok ) tag "1"

_dbf_name := "e_roba"
select ( F_TMP_E_ROBA )
my_use_temp( "E_ROBA", use_path + _dbf_name, .f., .t. )
index on ( id ) tag "ID"

_dbf_name := "e_partn"
select ( F_TMP_E_PARTN )
my_use_temp( "E_PARTN", use_path + _dbf_name, .f., .t. )
index on ( id ) tag "ID"

_dbf_name := "e_sifk"
select ( F_TMP_E_SIFK )
my_use_temp( "E_SIFK", use_path + _dbf_name, .f., .t. )
index on ( id + sort + naz ) tag "ID"
index on ( id + oznaka ) tag "ID2"

_dbf_name := "e_sifv"
select ( F_TMP_E_SIFV )
my_use_temp( "E_SIFV", use_path + _dbf_name, .f., .t. )
index on ( id + oznaka + idsif + naz ) tag "ID"
index on ( id + idsif ) tag "IDIDSIF"

log_write("otvorene sve import tabele i indeksirane...", 9 )

return






