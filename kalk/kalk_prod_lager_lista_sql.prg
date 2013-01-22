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
function kalk_prod_lager_lista_sql( params, ps )
local _data, _server
local _qry, _where
local _dat_od, _dat_do, _dat_ps, _p_konto
local _art_filter, _dok_filter, _tar_filter, _part_filter
local _db_params := my_server_params()
local _tek_database := my_server_params()["database"]
local _year_sez, _year_tek

// pozovi uslove ako nisu zadati kod poziva funkcije
if params == NIL
    params := hb_hash()
    if !kalk_prod_lager_lista_vars( @params, ps )
        return NIL
    endif
endif

_dat_od := params["datum_od"]
_dat_do := params["datum_do"]
_dat_ps := params["datum_ps"]
_p_konto := params["p_konto"]
_year_sez := YEAR( _dat_do )
_year_tek := YEAR( _dat_ps )


// sada mogu preci na izvrsenje sql upita
// where uslov
_where := " WHERE "
_where += _sql_date_parse( "k.datdok", _dat_od, _dat_do )
_where += " AND " + _sql_cond_parse( "k.idfirma", gFirma )
_where += " AND " + _sql_cond_parse( "k.pkonto", _p_konto )

_qry := " SELECT " + ;
            " k.idroba, " + ;
            " SUM( CASE " + ;
                    "WHEN k.pu_i = '1' THEN k.kolicina " + ;
                    "WHEN k.pu_i = '5' AND k.idvd IN ('12', '13') THEN -k.kolicina " + ;
                "END ) AS ulaz, " + ;
            " SUM( CASE " + ;
                    "WHEN k.pu_i = '1' THEN k.kolicina * k.nc " + ;
                    "WHEN k.pu_i = '5' AND k.idvd IN ('12', '13') THEN -( k.kolicina * k.nc ) " + ;
                "END ) AS nvu, " + ;
            " SUM( CASE " + ;
                    "WHEN k.pu_i = '3' THEN k.kolicina * k.mpcsapp " + ;
                    "WHEN k.pu_i = '1' THEN k.kolicina * k.mpcsapp " + ;
                    "WHEN k.pu_i = '5' AND k.idvd IN ('12', '13') THEN -( k.kolicina * k.mpcsapp ) " + ;
                "END ) AS mpvu, " + ; 
            " SUM( CASE " + ;
                    "WHEN k.pu_i = '5' AND k.idvd NOT IN ('12', '13') THEN k.kolicina " + ;
                    "WHEN k.pu_i = 'I' THEN k.gkolicin2 " + ;
                "END ) AS izlaz, " + ;
            " SUM( CASE " + ;
                    "WHEN k.pu_i = '5' AND k.idvd NOT IN ('12', '13') THEN k.kolicina * k.nc " + ;
                    "WHEN k.pu_i = 'I' THEN k.gkolicin2 * k.nc " + ;
                "END ) AS nvi, " + ;
            " SUM( CASE " + ;
                    "WHEN k.pu_i = '5' AND k.idvd NOT IN ('12', '13') THEN k.kolicina * k.mpcsapp " + ;
                    "WHEN k.pu_i = 'I' THEN k.gkolicin2 * k.mpcsapp " + ;
                "END ) AS mpvi " + ;
        " FROM fmk.kalk_kalk k "

_qry += _where

_qry += " GROUP BY k.idroba "
_qry += " ORDER BY k.idroba "

// prebaci se u sezonu
if ps 
    switch_to_database( _db_params, _tek_database, _year_sez )
    _server := pg_server()
endif

MsgO( "pocetno stanje - sql query u toku..." )

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
if ps
    switch_to_database( _db_params, _tek_database, _year_tek )
    _server := pg_server()
endif

return _data




// ------------------------------------------------------------
// lager lista prodavnice, uslovi izvjestaja
// ------------------------------------------------------------
function kalk_prod_lager_lista_vars( params, ps )
local _ret := .t.
local _p_konto, _dat_od, _dat_do, _nule, _pr_nab, _roba_tip_tu, _dat_ps
local _x := 1
local _art_filter := SPACE(300)
local _tar_filter := SPACE(300)
local _part_filter := SPACE(300)
local _dok_filter := SPACE(300)
local _curr_user := my_user()

// pocetno stanje parametar
if ps == NIL
    ps := .f.
endif

_p_konto := fetch_metric("kalk_lager_lista_prod_id_konto", _curr_user, PADR( "1330", 7 ) )
_pr_nab := fetch_metric("kalk_lager_lista_prod_po_nabavnoj", _curr_user, "D" )
_nule := fetch_metric("kalk_lager_lista_prod_prikaz_nula", _curr_user, "N" )
_dat_od := fetch_metric("kalk_lager_lista_prod_datum_od", _curr_user, DATE() - 30 )
_dat_do := fetch_metric("kalk_lager_lista_prod_datum_do", _curr_user, DATE() )
_dat_ps := NIL
_roba_tip_tu := "N"

// parametri za pocetno stanje
if ps
    _dat_od := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
    _dat_do := CTOD( "31.12." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
    _dat_ps := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) ) ) )
endif

Box( "# LAGER LISTA PRODAVNICE" + if( ps, " / POCETNO STANJE", "" ), 15, MAXCOLS() - 5 )

    @ m_x + _x, m_y + 2 SAY "Firma "
		
    ?? gFirma, "-", ALLTRIM( gNFirma )
 
    ++ _x	
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Prodavnicki konto:" GET _p_konto VALID P_Konto( @_p_konto )

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

    // ostali uslovi...
    ++ _x
    ++ _x
 	@ m_x + _x, m_y + 2 SAY "Prikaz nabavne vrijednosti (D/N)" GET _pr_nab VALID _pr_nab $ "DN" PICT "@!"
 	@ m_x + _x, col() + 1 SAY "Prikaz stavki kojima je MPV=0 (D/N)" GET _nule VALID _nule $ "DN" PICT "@!"

    ++ _x
	@ m_x + _x, m_y + 2 SAY "Prikaz robe tipa T/U (D/N)" GET _roba_tip_tu VALID _roba_tip_tu $ "DN" PICT "@!"
 
    read

BoxC()

// ESC dogadjaj
if LastKey() == K_ESC
    return .f.
endif

// setuj parametre sql/par
set_metric("kalk_lager_lista_prod_id_konto", _curr_user, _p_konto )
set_metric("kalk_lager_lista_prod_po_nabavnoj", _curr_user, _pr_nab )
set_metric("kalk_lager_lista_prod_prikaz_nula", _curr_user, _nule )
set_metric("kalk_lager_lista_prod_datum_od", _curr_user, _dat_od )
set_metric("kalk_lager_lista_prod_datum_do", _curr_user, _dat_do )

// setuj matricu parametara
params["datum_od"] := _dat_od
params["datum_do"] := _dat_do
params["datum_ps"] := _dat_ps
params["p_konto"] := _p_konto
params["nule"] := _nule
params["roba_tip_tu"] := _roba_tip_tu
params["pr_nab"] := _pr_nab
params["filter_dok"] := _dok_filter
params["filter_roba"] := _art_filter
params["filter_partner"] := _part_filter
params["filter_tarifa"] := _tar_filter

return _ret



// ------------------------------------------------------------
// prodavnicko pocetno stanje...
// ------------------------------------------------------------
function kalk_prod_pocetno_stanje()
local _ps := .t.
local _param := NIL
local _data
local _count := 0

// pozovi lager listu ali kao pocetno stanje...
_data := kalk_prod_lager_lista_sql( @_param, _ps )

if _data == NIL .or. VALTYPE( _data ) == "L"
    return
endif

// sada imam podatke
// trebam napraviti insert podataka u pripremu...
_count := kalk_prod_insert_ps_into_pripr( _data, _param )

if _count > 0
    // renumerisi pripremu...
    renumeracija_kalk_pripr( nil, nil, .t. )
    MsgBeep( "Formiran dokument pocetnog stanja, nalazi se u pripremi !" )
endif

return




// ----------------------------------------------------------------
// ubacuje podatke pocetnog stanja u pripremu...
// ----------------------------------------------------------------
static function kalk_prod_insert_ps_into_pripr( data, params )
local _count := 0
local _kalk_broj := ""
local _kalk_tip := "80"
local _kalk_datum := params["datum_ps"]
local _p_konto := params["p_konto"]
local _roba_tip_tu := params["roba_tip_tu"]
local _row, _sufix
local _ulaz, _izlaz, _nvu, _nvi, _mpvu, _mpvi, _id_roba

private aPorezi := {}

O_KALK_PRIPR
O_KALK_DOKS
O_KONCIJ
O_ROBA
O_TARIFA

// nadji mi novi broj dokumenta za ps
if glBrojacPoKontima
    _sufix := SufBrKalk( _p_konto )
    _kalk_broj := SljBrKalk( _kalk_tip, gFirma, _sufix )
else
    _kalk_broj := GetNextKalkDoc( gFirma, _kalk_tip )
endif

// pronadji konto u konta tipovi cijena...
select koncij
go top
seek _p_konto

MsgO( "Punjenje pripreme podacima pocetnog stanja u toku, dok: " + _kalk_tip + "-" + ALLTRIM( _kalk_broj ) )

do while !data:EOF()

    _row := data:GetRow()
    
    // zapisi....
    _id_roba := hb_utf8tostr( _row:FieldGet( _row:FieldPos("idroba") ) )
    _ulaz := _row:FieldGet( _row:FieldPos("ulaz") )
    _izlaz := _row:FieldGet( _row:FieldPos("izlaz") )
    _nvu := _row:FieldGet( _row:FieldPos("nvu") )
    _nvi := _row:FieldGet( _row:FieldPos("nvi") )
    _mpvu := _row:FieldGet( _row:FieldPos("mpvu") )
    _mpvi := _row:FieldGet( _row:FieldPos("mpvi") )

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
    _rec["idkonto"] := _p_konto
    _rec["pkonto"] := _p_konto

    _rec["idtarifa"] := Tarifa( _p_konto, _id_roba, @aPorezi )

    VTPorezi()

    _rec["tcardaz"] := "%"
    _rec["pu_i"] := "1"
    _rec["brfaktp"] := PADR( "PS", LEN( _rec["brfaktp"] ) )
    _rec["datfaktp"] := _kalk_datum
    _rec["tmarza2"] := "A"

    _rec["kolicina"] := ( _ulaz - _izlaz )
    _rec["nc"] := ( _nvu - _nvi ) / ( _ulaz - _izlaz )
    _rec["mpcsapp"] := ROUND( ( _mpvu - _mpvi ) / ( _ulaz - _izlaz ), 2 )
	_rec["fcj"] := _rec["nc"]
	_rec["vpc"] := _rec["nc"]
	_rec["error"] := "0"
    
    if _rec["mpcsapp"] <> 0
        _rec["mpc"] := MpcBezPor( _rec["mpcsapp"], aPorezi, NIL, _rec["nc"] ) 
        _rec["marza2"] := _rec["mpc"] - _rec["nc"]
    endif

    dbf_update_rec( _rec )

    data:Skip()
	
enddo

MsgC()
		
return _count





