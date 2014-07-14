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

static __stanje
static __vrijednost
static __dok_br


// --------------------------------------------
// prenos pocetnog stanja....
// --------------------------------------------
function p_poc_stanje()
local _params := hb_hash()
local _cnt := 0
local _padr := 80

__stanje := 0
__vrijednost := 0
__dok_br := ""

// parametri prenosa...
if _get_vars( @_params ) == 0
    return
endif

// prenesi pocetno stanje...
_cnt := pocetno_stanje_sql( _params )

if _cnt > 0
    _txt := "Izvrsen prenos pocetnog stanja, dokument 16-1 !"
else
	_txt := "Nema dokumenata za prenos !!!"
endif

MsgBeep( _txt )

return


// --------------------------------------------
// parametri prenosa
// --------------------------------------------
static function _get_vars( params )
local _x := 1
local _box_x := 8
local _box_y := 60
local _dat_od, _dat_do, _id_pos, _dat_ps
private GetList:={}

_dat_od := CTOD( "01.01." + ALLTRIM(STR(YEAR(DATE())-1)) )
_dat_do := CTOD( "31.12." + ALLTRIM(STR(YEAR(DATE())-1)) )
_dat_ps := CTOD( "01.01." + ALLTRIM(STR(YEAR(DATE()))) )
_id_pos := gIdPos

Box(, _box_x, _box_y )

	set cursor on
	
	@ m_x + _x, m_y + 2 SAY "Parametri prenosa u novu godinu" COLOR "BG+/B"
	
	_x += 2
	
	@ m_x + _x, m_y + 2 SAY "pos ID" GET _id_pos VALID !EMPTY( _id_pos )
	
	_x += 2
	
	@ m_x + _x, m_y + 2 SAY "Datum prenosa od:" GET _dat_od VALID !EMPTY(_dat_od)
	@ m_x + _x, col() + 1 SAY "do:" GET _dat_do VALID !EMPTY(_dat_do)
	
 	_x += 2
	
	@ m_x + _x, m_y + 2 SAY "Datum dokumenta pocetnog stanja:" GET _dat_ps VALID !EMPTY( _dat_ps )
	
	read
	
BoxC()

if LastKey() == K_ESC
	return 0
endif

// snimi parametre
params["datum_od"] := _dat_od
params["datum_do"] := _dat_do
params["id_pos"] := _id_pos
params["datum_ps"] := _dat_ps

return 1


// ----------------------------------------------------------
// prebaci se na rad sa sezonskim podrucjem
// ----------------------------------------------------------
static function prebaci_se_u_bazu( db_params, database, year )

if year == NIL
    year := YEAR( DATE() )
endif

// 1) odjavi mi se iz tekuce sezone
my_server_logout()

if year <> YEAR( DATE() )
    // 2) xxxx_2013 => xxxx_2012
    db_params["database"] := LEFT( database, LEN( database ) - 4 ) + ALLTRIM( STR( year ) )
else
    db_params["database"] := database
endif

// 3) setuj parametre
my_server_params( db_params )
// 4) napravi login
my_server_login( db_params )

return 



// -----------------------------------------------------
// pocetno stanje POS na osnovu sql upita...
// -----------------------------------------------------
static function pocetno_stanje_sql( param )
local _db_params := my_server_params()
local _tek_database := my_server_params()["database"]
local _date_from := param["datum_od"]
local _date_to := param["datum_do"]
local _date_ps := param["datum_ps"]
local _year_sez := YEAR( _date_to )
local _year_tek := YEAR( _date_ps )
local _id_pos := param["id_pos"]
local _server := pg_server()
local _qry, _table, _row
local _count := 0
local _rec, _id_roba, _kolicina, _vrijednost
local _n_br_dok 

// 1) predji u sezonsko podrucje
// ------------------------------------------------------------
// prebaci se u sezonu
prebaci_se_u_bazu( _db_params, _tek_database, _year_sez )
// setuj server
_server := pg_server()

// 2) izvuci podatke u matricu...
// ------------------------------------------------------------

// select
_qry := "SELECT " + ;
            "idroba, " + ;
            "SUM( CASE " + ;
            "WHEN idvd IN ('16', '00') THEN kolicina " + ;
            "WHEN idvd IN ('IN') THEN -(kolicina - kol2) " + ;
            "WHEN idvd IN ('42') THEN -kolicina " + ;
            "END ) as kolicina, " + ;
        "SUM( CASE  " + ;
            "WHEN idvd IN ('16', '00') THEN kolicina * cijena " + ;
            "WHEN idvd IN ('IN') THEN -(kolicina - kol2) * cijena " + ;
            "WHEN idvd IN ('42') THEN -kolicina * cijena " + ;
            "END ) as vrijednost " + ;
        "FROM fmk.pos_pos "
        
// where cond ...
_qry += " WHERE "
_qry += _sql_cond_parse( "idpos", _id_pos )
_qry += " AND " + _sql_date_parse( "datum", _date_from, _date_to )
_qry += " GROUP BY idroba "
_qry += " ORDER BY idroba "

msgO( "pocetno stanje sql query u toku..." )

// podaci pocetnog stanja su ovdje....
_table := _sql_query( _server, _qry )
_table:Refresh()

msgC()

// 3) vrati se u tekucu bazu...
// ------------------------------------------------------------
prebaci_se_u_bazu( _db_params, _tek_database, _year_tek )
_server := pg_server()

// otvori potrebne tabele
O_POS
O_POS_DOKS
O_ROBA


// 4) daj mi novi broj dokumenta zaduzenja
// ------------------------------------------------------------
_n_br_dok := pos_novi_broj_dokumenta( _id_pos, "16", _date_ps )


// 5) napravi push podataka u tekucem podrucju...
// ------------------------------------------------------------

// zakljucaj semafore pos-a
if !f18_lock_tables( {"pos_pos", "pos_doks" })
    return
endif
sql_table_update( nil, "BEGIN")

MsgO( "Formiranje dokumenta pocetnog stanja u toku... ")

do while !_table:EOF()

    _row := _table:GetRow()

    _id_roba := hb_utf8tostr( _row:Fieldget( _row:Fieldpos("idroba") ) )

    _kolicina := _row:Fieldget( _row:Fieldpos("kolicina") )
    __stanje += _kolicina

    _vrijednost := _row:Fieldget( _row:Fieldpos("vrijednost") )
    __vrijednost += _vrijednost

    select roba
    hseek _id_roba

    if ROUND( _kolicina, 2 ) <> 0

        select pos
        append blank

        _rec := dbf_get_rec()

		_rec["idpos"] := _id_pos
		_rec["idvd"] := "16"
		_rec["brdok"] := _n_br_dok
        _rec["rbr"] := PADL( ALLTRIM(STR( ++ _count ) ) , 5 ) 
		_rec["idroba"] := _id_roba
		_rec["kolicina"] := _kolicina
		_rec["cijena"] := pos_get_mpc() 
		_rec["datum"] := _date_ps
		_rec["idradnik"] := "XXXX"
		_rec["idtarifa"] := roba->idtarifa
		_rec["prebacen"] := "1"
		_rec["smjena"] := "1"
		_rec["mu_i"] := "1"
		
	    update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )

    endif

    _table:Skip()

enddo

// ima li za DOKS ?
if _count > 0

    select pos_doks
    append blank

    _rec := dbf_get_rec()

	_rec["idpos"] := _id_pos
	_rec["idvd"] := "16"
	_rec["brdok"] := _n_br_dok
	_rec["datum"] := _date_ps
	_rec["idradnik"] := "XXXX"
	_rec["prebacen"] := "1"
	_rec["smjena"] := "1"

    update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

endif


f18_free_tables( { "pos_pos", "pos_doks" } )
sql_table_update( nil, "END" )

MsgC()

select ( F_ROBA )
use
select ( F_POS_DOKS )
use
select ( F_POS )
use

return _count






