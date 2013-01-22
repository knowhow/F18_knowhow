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

#include "fin.ch"


// ------------------------------------------
// otvori potrebne DBF fajlove
// ------------------------------------------
static function _o_tables()

select ( F_PKONTO )
if !Used()
    O_PKONTO
endif

select ( F_KONTO )
if !Used()
    O_KONTO
endif

select ( F_PARTN )
if !Used()
    O_PARTN
endif

select ( F_FIN_PRIPR )
if !Used()
    O_FIN_PRIPR
endif

return



// -----------------------------------------------------
// prenos dokumenata pocetnog stanja - sql varijanta
// -----------------------------------------------------
function fin_pocetno_stanje_sql()
local _dug_kto, _pot_kto, _dat_ps, _dat_od, _dat_do
local _k_1, _k_2, _k_3, _k_4
local _param := hb_hash()
local _sint

// ucitavanje parametara
_k_1 := fetch_metric( "fin_prenos_pocetno_stanje_k1", NIL, "9" )
_k_2 := fetch_metric( "fin_prenos_pocetno_stanje_k2", NIL, "9" )
_k_3 := fetch_metric( "fin_prenos_pocetno_stanje_k3", NIL, "99" )
_k_4 := fetch_metric( "fin_prenos_pocetno_stanje_k4", NIL, "99" )

// otvori potrebne tabele
_o_tables()

// otvori sifrarnik nacina prenosa u NG
P_PKonto()

_dug_kto := fetch_metric( "fin_klasa_duguje", NIL, "2" )
_pot_kto := fetch_metric( "fin_klasa_potrazuje", NIL, "4" )
_sint := fetch_metric( "fin_prenos_pocetno_stanje_sint", NIL, 3 )

_dat_od := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
_dat_do := CTOD( "31.12." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
_dat_ps := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) ) ) )

Box(, 7, 60 )

  	@ m_x + 1, m_y + 2 SAY "Za datumski period od:" GET _dat_od
  	@ m_x + 1, col() + 1 SAY "do:" GET _dat_do

  	@ m_x + 3, m_y + 2 SAY "Datum dokumenta pocetnog stanja:" GET _dat_ps

  	@ m_x + 5, m_y + 2 SAY "Klasa dugovnog  konta:" GET _dug_kto
  	@ m_x + 6, m_y + 2 SAY "Klasa potraznog konta:" GET _pot_kto 
  
  	@ m_x + 7, m_y + 2 SAY "Grupisem konta na broj mjesta ?" GET _sint PICT "9"
  	
    read

 	ESC_BCR
  
BoxC()

// odabrano ESC
if LastKey() == K_ESC
    return
endif

// snimi parametre
set_metric( "fin_klasa_duguje", NIL, _dug_kto )
set_metric( "fin_klasa_potrazuje", NIL, _pot_kto )
set_metric( "fin_prenos_pocetno_stanje_sint", NIL, _sint )
set_metric( "fin_prenos_pocetno_stanje_k1", NIL, _k_1 )
set_metric( "fin_prenos_pocetno_stanje_k2", NIL, _k_2 )
set_metric( "fin_prenos_pocetno_stanje_k3", NIL, _k_3 )
set_metric( "fin_prenos_pocetno_stanje_k4", NIL, _k_4 )

_param["klasa_duguje"] := _dug_kto
_param["klasa_potrazuje"] := _pot_kto
_param["k_1"] := _k_1
_param["k_2"] := _k_2
_param["k_3"] := _k_3
_param["k_4"] := _k_4
_param["datum_od"] := _dat_od
_param["datum_do"] := _dat_do
_param["datum_ps"] := _dat_ps
_param["sintetika"] := _sint

// izvuci mi podatke u matricu iz sql-a...
_data := get_data( _param )

if _data == NIL
    MsgBeep( "Ne postoje trazeni podaci... prekidam operaciju !!!" )
    return
endif

// generisi dokument u tabeli pripreme...
if !_insert_into_fin_priprema( _data, _param )
    return
endif

MsgBeep( "Dokument formiran i nalazi se u pripremi..." )

return



// --------------------------------------------------------------------
// napravi dokument u pripremi
// --------------------------------------------------------------------
static function _insert_into_fin_priprema( data, param )
local _fin_vn := "00"
local _fin_broj
local _dat_ps := param["datum_ps"]
local _sint := param["sintetika"]
local _kl_dug := param["klasa_duguje"]
local _kl_pot := param["klasa_potrazuje"]
local _ret := .f.
local _row, _duguje, _potrazuje, _id_konto, _id_partner
local _rec, _i_saldo
local _rbr := 0

_fin_broj := fin_brnal_0(gFirma, _fin_vn, DATE())

// otvori potrebne tabele
_o_tables()

// isprazni fin priprema
if !prazni_fin_priprema()
    return _ret
endif

MsgO( "Formiram dokument pocetnog stanja u pripremi ..." )

_i_saldo := 0

do while !data:EOF()

    _row := data:GetRow()

    _id_konto := PADR( _row:FieldGet( _row:FieldPos( "idkonto" ) ), 7 )
    _id_partner := PADR( hb_utf8tostr( _row:FieldGet( _row:FieldPos( "idpartner" ) ) ), 6 )

    // vidi ima li ove stavke u semama prenosa...
    select pkonto
    go top
    seek PADR( _id_konto, _sint )

    _tip_prenosa := "0"

    if FOUND()
        _tip_prenosa := pkonto->tip
    endif

    _i_saldo := 0

    // provrti razlicite nacine prenosa...
    do while !data:EOF() .and. PADR( data:FieldGet( data:FieldPos( "idkonto" ) ), 7 ) == _id_konto ;
                        .and. IF( _tip_prenosa == "2", ;
                            PADR( hb_utf8tostr( data:FieldGet( data:FieldPos("idpartner") ) ), 6 ) == _id_partner, .t. ) ;
    
        _row2 := data:GetRow()

        _i_saldo += _row2:FieldGet( _row2:FieldPos("saldo") )

        data:Skip()
        
    enddo

    // ako je saldo 0 - preskoci...
    if ROUND( _i_saldo, 2 ) == 0
        loop
    endif

    // postavke pojedinih polja...
    if _tip_prenosa == "0"
        _id_partner := SPACE(6)
    endif

    select fin_pripr
    append blank

    _rec := dbf_get_rec()

    _rec["idfirma"] := gFirma
    _rec["idvn"] := _fin_vn
    _rec["brnal"] := _fin_broj
    _rec["datdok"] := _dat_ps
    _rec["rbr"] := STR( ++ _rbr, 4 )
    _rec["idkonto"] := _id_konto
    _rec["idpartner"] := _id_partner
    _rec["opis"] := "POCETNO STANJE"
    _rec["brdok"] := "PS"

    if ROUND( _i_saldo, 2 ) > 0
        _rec["d_p"] := "1"
        _rec["iznosbhd"] := ABS( _i_saldo )
    else
        _rec["d_p"] := "2"
        _rec["iznosbhd"] := ABS( _i_saldo )
    endif

    dbf_update_rec( _rec )

enddo

MsgC()

if _rbr > 0
    _ret := .t.
endif

return _ret



// -------------------------------------------------------------------
// isprazni fin priprema ako nije prazna...
// -------------------------------------------------------------------
static function prazni_fin_priprema()
local _ret := .t.

select fin_pripr
if RECCOUNT2() == 0
    return _ret
endif

if Pitanje(, "Priprema FIN nije prazna ! Izbrisati postojece stavke (D/N) ?", "D" ) == "D"
    zapp()
    __dbPack()
    return _ret
else
    _ret := .f.
    return _ret
endif

return _ret



// ----------------------------------------------------------------------
// izvlacenje podataka za pocetno stanje iz sql-a u matricu
// ----------------------------------------------------------------------
static function get_data( param )
local _data, _server
local _qry, _where
local _dat_od := param["datum_od"]
local _dat_do := param["datum_do"]
local _dat_ps := param["datum_ps"]
local _db_params := my_server_params()
local _tek_database := my_server_params()["database"]
local _year_sez := YEAR( _dat_do )
local _year_tek := YEAR( _dat_ps )

// where uslov
_where := " WHERE "
_where += _sql_date_parse( "sub.datdok", _dat_od, _dat_do )
_where += " AND " + _sql_cond_parse( "sub.idfirma", gFirma )

// query
_qry := " SELECT " + ;
            "sub.idkonto, " + ;
            "sub.idpartner, " + ;
            "SUM( CASE WHEN sub.d_p = '1' THEN sub.iznosbhd ELSE -sub.iznosbhd END ) AS saldo " + ; 
        " FROM fmk.fin_suban sub "

_qry += _where

_qry += " GROUP BY sub.idkonto, sub.idpartner "
_qry += " ORDER BY sub.idkonto, sub.idpartner "


// 1) predji u sezonsko podrucje
// ------------------------------------------------------------
// prebaci se u sezonu
switch_to_database( _db_params, _tek_database, _year_sez )
// setuj server
_server := pg_server()

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

// 3) vrati se u tekucu bazu...
// ------------------------------------------------------------
switch_to_database( _db_params, _tek_database, _year_tek )
_server := pg_server()

return _data




// ----------------------------------------------------------
// prebaci se na rad sa sezonskim podrucjem
// ----------------------------------------------------------
function switch_to_database( db_params, database, year )

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






