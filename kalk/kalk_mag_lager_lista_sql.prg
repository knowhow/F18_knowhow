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


#include "kalk.ch"


// ------------------------------------------------------------
// lager lista sql varijanata
// ------------------------------------------------------------
function kalk_mag_lager_lista_sql( params, ps )
local _data, _server
local _qry, _where
local _dat_od, _dat_do, _dat_ps, _m_konto
local _change_db
local _art_filter, _dok_filter, _tar_filter, _part_filter
local _db_params := my_server_params()
local _tek_database := my_server_params()["database"]
local _year_sez, _year_tek
local _zaokr := ALLTRIM( STR( gZaokr ) )

// pozovi uslove ako nisu zadati kod poziva funkcije
if params == NIL
    params := hb_hash()
    if !kalk_mag_lager_lista_vars( @params, ps )
        return NIL
    endif
endif

_dat_od := params["datum_od"]
_dat_do := params["datum_do"]
_dat_ps := params["datum_ps"]
_m_konto := params["m_konto"]
_change_db := params["change_db"] == "D"
_year_sez := YEAR( _dat_do )
_year_tek := YEAR( _dat_ps )


// sada mogu preci na izvrsenje sql upita
// where uslov
_where := " WHERE "
_where += _sql_date_parse( "k.datdok", _dat_od, _dat_do )
_where += " AND " + _sql_cond_parse( "k.idfirma", gFirma )
_where += " AND " + _sql_cond_parse( "k.mkonto", _m_konto )

_qry := " SELECT " + ;
            " k.idroba, " + ;
            " SUM( CASE " + ;
                    "WHEN k.mu_i = '1' AND k.idvd NOT IN ('12', '22', '94') THEN k.kolicina ELSE 0 " + ;
                "END ) AS ulaz, " + ;
            "ROUND( SUM( CASE " + ;
                    "WHEN k.mu_i = '1' AND k.idvd NOT IN ('12', '22', '94') THEN k.nc * k.kolicina ELSE 0 " + ;
                "END ), " + _zaokr + " ) AS nvu, " + ;
            "ROUND( SUM( CASE " + ;
                    "WHEN k.mu_i = '1' AND k.idvd NOT IN ('12', '22', '94') THEN r.vpc * k.kolicina ELSE 0 " + ;
                "END ), " + _zaokr + " ) AS vpvu, " + ;
            "SUM( CASE " + ;
                    "WHEN k.mu_i = '1' AND k.idvd IN ('12', '22', '94') THEN k.kolicina " + ;
                    "WHEN k.mu_i = '5' THEN k.kolicina ELSE 0 " + ;
                "END ) AS izlaz, " + ;
            "ROUND( SUM( CASE " + ;
                    "WHEN k.mu_i = '1' AND k.idvd IN ('12', '22', '94') THEN -( k.nc * k.kolicina ) " + ;
                    "WHEN k.mu_i = '5' THEN k.nc * k.kolicina ELSE 0 " + ;
                "END ), " + _zaokr + " ) AS nvi, " + ;
            "ROUND( SUM( CASE " + ;
                    "WHEN k.mu_i = '1' AND k.idvd IN ('12', '22', '94') THEN -( r.vpc * k.kolicina ) " + ;
                    "WHEN k.mu_i = '5' THEN r.vpc * k.kolicina ELSE 0 " + ;
                "END ), " + _zaokr + " ) AS vpvi " + ;
        " FROM fmk.kalk_kalk k " + ;
        " RIGHT JOIN fmk.roba r ON r.id = k.idroba "

_qry += _where

_qry += " GROUP BY k.idroba "
_qry += " ORDER BY k.idroba "

// prebaci se u sezonu
if ps .and. _change_db
    switch_to_database( _db_params, _tek_database, _year_sez )
endif

_server := pg_server()

if ps
    MsgO( "pocetno stanje - sql query u toku..." )
else
    MsgO( "formiranje podataka u toku....")
endif

// podaci pocetnog stanja su ovdje....
_data := _sql_query( _server, _qry )

if VALTYPE( _data ) == "L"
    _data := NIL    
else
    _data:Refresh()
    // ako nema zapisa u tabeli...
    if _data:LastRec() == 0
        _data := NIL
    endif
endif

MsgC()

// vrati se u tekucu bazu
if ps .and. _change_db
    switch_to_database( _db_params, _tek_database, _year_tek )
    _server := pg_server()
endif

return _data




// ------------------------------------------------------------
// lager lista magacina, uslovi izvjestaja
// ------------------------------------------------------------
function kalk_mag_lager_lista_vars( params, ps )
local _ret := .t.
local _m_konto, _dat_od, _dat_do, _nule, _pr_nab, _roba_tip_tu, _dat_ps, _do_nab
local _x := 1
local _art_filter := SPACE(300)
local _tar_filter := SPACE(300)
local _part_filter := SPACE(300)
local _dok_filter := SPACE(300)
local _brfakt_filter := SPACE(300)
local _curr_user := my_user()
local _storno_dok

// pocetno stanje parametar
if ps == NIL
    ps := .f.
endif

_min_kol := fetch_metric("kalk_lager_lista_mag_minimalne_kolicine", _curr_user, "N" )
_do_nab := fetch_metric("kalk_lager_Lista_mag_prikaz_do_nabavne", _curr_user, "N" )
_m_konto := fetch_metric("kalk_lager_lista_mag_id_konto", _curr_user, PADR( "1320", 7 ) )
_pr_nab := fetch_metric("kalk_lager_lista_mag_po_nabavnoj", _curr_user, "D" )
_nule := fetch_metric("kalk_lager_lista_mag_prikaz_nula", _curr_user, "N" )
_dat_od := fetch_metric("kalk_lager_lista_mag_datum_od", _curr_user, DATE() - 30 )
_dat_do := fetch_metric("kalk_lager_lista_mag_datum_do", _curr_user, DATE() )
_storno_dok := fetch_metric("kalk_lager_lista_ps_storno", _curr_user, "D" )
_dat_ps := NIL
_roba_tip_tu := "N"

// parametri za pocetno stanje
if ps
    _dat_od := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
    _dat_do := CTOD( "31.12." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
    _dat_ps := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) ) ) )
endif

Box( "# LAGER LISTA MAGACINA" + if( ps, " / POCETNO STANJE", "" ), 15, MAXCOLS() - 5 )

    @ m_x + _x, m_y + 2 SAY "Firma "
		
    ?? gFirma, "-", ALLTRIM( gNFirma )
 
    ++ _x	
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Magacinski konto:" GET _m_konto VALID P_Konto( @_m_konto )

    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Datum od:" GET _dat_od
 	@ m_x + _x, col() + 1 SAY "do:" GET _dat_do

    // pocetno stanje...
    if ps 
 	    @ m_x + _x, col() + 1 SAY "Datum poc.stanja:" GET _dat_ps
    endif

    // filteri...	
    ++ _x
    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Filter po artiklima:" GET _art_filter PICT "@S50"
 	++ _x
    @ m_x + _x, m_y + 2 SAY "Filter po tarifama:" GET _tar_filter PICT "@S50"
    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Filter po partnerima:" GET _part_filter PICT "@S50"
    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Filter po v.dokument:" GET _dok_filter PICT "@S50"
    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Filter po broju.fakt:" GET _brfakt_filter PICT "@S50"


    // ostali uslovi...
    ++ _x
    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Prikaz nabavne vrijednosti (D/N)" GET _pr_nab VALID _pr_nab $ "DN" PICT "@!"
 	@ m_x + _x, col() + 1 SAY "Prikaz stavki kojima je NV = 0 (D/N)" GET _nule VALID _nule $ "DN" PICT "@!"

    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Prikaz samo kriticnih zaliha (D/N)" GET _min_kol VALID _min_kol $ "DN" PICT "@!"

    ++ _x
	@ m_x + _x, m_y + 2 SAY "Prikaz robe tipa T/U (D/N)" GET _roba_tip_tu VALID _roba_tip_tu $ "DN" PICT "@!"
 
	if ps
	    ++ _x
		@ m_x + _x, m_y + 2 SAY "Formirati storno dokument na 31.12 (D/N)?" GET _storno_dok VALID _storno_dok $ "DN" PICT "@!"
	endif

    read

BoxC()

// ESC dogadjaj
if LastKey() == K_ESC
    return .f.
endif

// setuj parametre sql/par
set_metric("kalk_lager_Lista_mag_prikaz_do_nabavne", _curr_user, _do_nab )
set_metric("kalk_lager_lista_mag_id_konto", _curr_user, _m_konto )
set_metric("kalk_lager_lista_mag_po_nabavnoj", _curr_user, _pr_nab )
set_metric("kalk_lager_lista_mag_prikaz_nula", _curr_user, _nule )
set_metric("kalk_lager_lista_mag_datum_od", _curr_user, _dat_od )
set_metric("kalk_lager_lista_mag_datum_do", _curr_user, _dat_do )
set_metric("kalk_lager_lista_mag_minimalne_kolicine", _curr_user, _min_kol )
set_metric("kalk_lager_lista_ps_storno", _curr_user, _storno_dok )

// setuj matricu parametara
params["datum_od"] := _dat_od
params["datum_do"] := _dat_do
params["datum_ps"] := _dat_ps
params["m_konto"] := _m_konto
// kod verzije 1.5.x ne treba se svichati na baze
params["change_db"] := "N"
params["nule"] := _nule
params["roba_tip_tu"] := _roba_tip_tu
params["pr_nab"] := _pr_nab
params["do_nab"] := _do_nab
params["min_kol"] := _min_kol
params["storno_dok"] := _storno_dok
params["filter_dok"] := _dok_filter
params["filter_roba"] := _art_filter
params["filter_partner"] := _part_filter
params["filter_tarifa"] := _tar_filter
params["filter_brfakt"] := _brfakt_filter

return _ret



// ------------------------------------------------------------
// magacinsko pocetno stanje...
// ------------------------------------------------------------
function kalk_mag_pocetno_stanje()
local _ps := .t.
local _param := NIL
local _data
local _count := 0

// pozovi lager listu ali kao pocetno stanje...
_data := kalk_mag_lager_lista_sql( @_param, _ps )

if _data == NIL .or. VALTYPE( _data ) == "L"
    return
endif

// sada imam podatke
// trebam napraviti insert podataka u pripremu...
_count := kalk_mag_insert_ps_into_pripr( _data, _param )

if _count > 0
    
    // renumerisi brojeve u pripremi...
    renumeracija_kalk_pripr( nil, nil, .t. )
	close all
	// azuriraj kalkulaciju
	azur_kalk()

	if _param["storno_dok"] == "D"

		// .t. - storno dokument
		// datum mi setuj na 31.12
		_param["datum_ps"] := ( _param["datum_ps"] - 1 )	
		kalk_mag_insert_ps_into_pripr( _data, _param, .t. )
		renumeracija_kalk_pripr( nil, nil, .t. )
		close all
		azur_kalk()
	endif
		
    MsgBeep( "Formiran dokument pocetnog stanja i automatski azuriran !" )

endif

return




// ----------------------------------------------------------------
// ubacuje podatke pocetnog stanja u pripremu...
// ----------------------------------------------------------------
static function kalk_mag_insert_ps_into_pripr( data, params, storno )
local _count := 0
local _kalk_broj := ""
local _kalk_tip := "16"
local _kalk_datum := params["datum_ps"]
local _m_konto := params["m_konto"]
local _roba_tip_tu := params["roba_tip_tu"]
local _row, _sufix
local _ulaz, _izlaz, _nvu, _nvi, _id_roba, _vpvu, _vpvi
local _magacin_po_nabavnoj := IsMagPNab()
local _h_dok

if storno == NIL
	storno := .f.
endif

O_KALK_PRIPR
O_KALK_DOKS
O_KONCIJ
O_ROBA
O_TARIFA

// nadji mi novi broj dokumenta za ps

_h_dok := hb_hash()
_h_dok["idfirma"] := gFirma
_h_dok["idvd"] := _kalk_tip
_h_dok["brdok"] := ""
_h_dok["datdok"] := DATE()

if glBrojacPoKontima
     _kalk_broj := kalk_novi_broj_dokumenta( _h_dok, _m_konto )
else
     _kalk_broj := kalk_novi_broj_dokumenta( _h_dok )
endif

// pronadji konto u konta tipovi cijena...
select koncij
go top
seek _m_konto

MsgO( "Punjenje pripreme podacima pocetnog stanja u toku, dok: " + _kalk_tip + "-" + ALLTRIM( _kalk_broj ) )

do while !data:EOF()

    _row := data:GetRow()
    
    // zapisi....
    _id_roba := hb_utf8tostr( _row:FieldGet( _row:FieldPos("idroba") ) )
    _ulaz := _row:FieldGet( _row:FieldPos("ulaz") )
    _izlaz := _row:FieldGet( _row:FieldPos("izlaz") )
    _nvu := _row:FieldGet( _row:FieldPos("nvu") )
    _nvi := _row:FieldGet( _row:FieldPos("nvi") )
    _vpvu := _row:FieldGet( _row:FieldPos("vpvu") )
    _vpvi := _row:FieldGet( _row:FieldPos("vpvi") )

    // roba tip T ili U
    if _roba_tip_tu == "N" .and. roba->tip $ "TU"
        data:Skip()
        loop
    endif

    if ROUND( _ulaz - _izlaz, 2 ) == 0
        data:Skip()
        loop
    endif
        
    // pronadji artikal
    select roba
    go top
    seek _id_roba

    // dodaj u pripremu...
    select kalk_pripr
    append blank

    _rec := dbf_get_rec()

    _rec["idfirma"] := gFirma
    _rec["idvd"] := _kalk_tip
    _rec["brdok"] := _kalk_broj
    _rec["rbr"] := STR( ++ _count, 3 )
    _rec["datdok"] := _kalk_datum
    _rec["idroba"] := _id_roba
    _rec["idkonto"] := _m_konto
    _rec["mkonto"] := _m_konto
    _rec["idtarifa"] := roba->idtarifa
    _rec["mu_i"] := "1"
    _rec["brfaktp"] := PADR( "PS", LEN( _rec["brfaktp"] ) )
    _rec["datfaktp"] := _kalk_datum
    _rec["kolicina"] := ( _ulaz - _izlaz )
    _rec["nc"] := ( _nvu - _nvi ) / ( _ulaz - _izlaz )
    _rec["vpc"] := ( _vpvu - _vpvi ) / ( _ulaz - _izlaz )
    _rec["error"] := "0"
    
    if _magacin_po_nabavnoj
        _rec["vpc"] := _rec["nc"]
    endif

	// ako je storno, kolicina je suprotna u odnosu na prvobitnu
	// prakticno storniramo lager
	if storno
		_rec["kolicina"] := -( _rec["kolicina"] )
	endif

    dbf_update_rec( _rec )

    data:Skip()
	
enddo

MsgC()
		
return _count





