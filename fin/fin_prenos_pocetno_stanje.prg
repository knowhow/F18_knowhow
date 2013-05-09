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
local _copy_sif
local _param := hb_hash()
local _sint
local _data, _partn_data, _konto_data 
local _storno_dok

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
_copy_sif := fetch_metric("fin_prenos_pocetno_stanje_sif", NIL, "N" )
_storno_dok := fetch_metric("fin_prenos_pocetno_stanje_storno_dok", NIL, "D" )

_dat_od := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
_dat_do := CTOD( "31.12." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
_dat_ps := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) ) ) )

Box(, 11, 60 )

  	@ m_x + 1, m_y + 2 SAY "Za datumski period od:" GET _dat_od
  	@ m_x + 1, col() + 1 SAY "do:" GET _dat_do

  	@ m_x + 3, m_y + 2 SAY "Datum dokumenta pocetnog stanja:" GET _dat_ps

  	@ m_x + 5, m_y + 2 SAY "Klasa dugovnog  konta:" GET _dug_kto
  	@ m_x + 6, m_y + 2 SAY "Klasa potraznog konta:" GET _pot_kto 
  
  	@ m_x + 8, m_y + 2 SAY "Grupisem konta na broj mjesta ?" GET _sint PICT "9"
  	@ m_x + 9, m_y + 2 SAY "Kopiraj nepostojece sifre (konto/partn) (D/N)?" GET _copy_sif VALID _copy_sif $ "DN" PICT "@!"

  	@ m_x + 11, m_y + 2 SAY "Formirati storno dokument na 31.12 (D/N)?" GET _storno_dok VALID _storno_dok $ "DN" PICT "@!"

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
set_metric( "fin_prenos_pocetno_stanje_sif", NIL, _copy_sif )
set_metric( "fin_prenos_pocetno_stanje_storno_dok", NIL, _storno_dok )
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
_param["copy_sif"] := "N"
_param["change_db"] := "N"
_param["storno_dok"] := _storno_dok

// izvuci mi podatke u matricu iz sql-a...
get_data( _param, @_data, @_konto_data, @_partn_data )

if _data == NIL
    MsgBeep( "Ne postoje trazeni podaci... prekidam operaciju !!!" )
    return
endif

// generisi dokument u tabeli pripreme...
if !_insert_into_fin_priprema( _data, _konto_data, _partn_data, _param )
    return
endif

// azuriraj pocetno stanje
fin_set_broj_naloga()
close all
stampa_fin_document( .t. )
close all
fin_azur( .t. )

o_fin_edit()
 
// sada formiraj storno na osnovu ovog dokumenta
_param["datum_ps"] := ( _param["datum_ps"] - 1 )
_insert_into_fin_priprema( _data, _konto_data, _partn_data, _param, .t. )

// azuriraj storno dokument
fin_set_broj_naloga()
close all
stampa_fin_document( .t. )
close all
fin_azur( .t. )

o_fin_edit()
 
MsgBeep( "Dokument formiran i automatski azuriran !" )

return



// --------------------------------------------------------------------
// napravi dokument u pripremi
// --------------------------------------------------------------------
static function _insert_into_fin_priprema( data, konto_data, partn_data, param, storno )
local _fin_vn := "00"
local _fin_broj
local _dat_ps := param["datum_ps"]
local _sint := param["sintetika"]
local _kl_dug := param["klasa_duguje"]
local _kl_pot := param["klasa_potrazuje"]
local _copy_sif := param["copy_sif"]
local _ret := .f.
local _row, _duguje, _potrazuje, _id_konto, _id_partner
local _dat_dok, _dat_val, _otv_st, _br_veze
local _rec, _i_saldo
local _rbr := 0

if storno == NIL
	storno := .f.
endif

_fin_broj := fin_brnal_0( gFirma, _fin_vn, DATE() )

// otvori potrebne tabele
_o_tables()

// isprazni fin priprema
if !prazni_fin_priprema()
    return _ret
endif

MsgO( "Formiram dokument pocetnog stanja u pripremi ..." )

_i_saldo := 0

data:GoTo(1)

do while !data:EOF()

    _row := data:GetRow()

    // karakterna polja...
    _id_konto := PADR( _row:FieldGet( _row:FieldPos( "idkonto" ) ), 7 )
    _id_partner := PADR( hb_utf8tostr( _row:FieldGet( _row:FieldPos( "idpartner" ) ) ), 6 )
    _br_veze := PADR( hb_utf8tostr( _row:FieldGet( _row:FieldPos( "brdok" ) ) ), 20 )
 
    // datumi
    _dat_dok := _row:FieldGet( _row:FieldPos( "datdok" ) )
    _dat_val := _row:FieldGet( _row:FieldPos( "datval" ) )

    // marker otvorenih stavki
    _otv_st := _row:FieldGet( _row:FieldPos( "otvst" ) )

    // vidi ima li ove stavke u semama prenosa...
    select pkonto
    go top
    seek PADR( _id_konto, _sint )

    _tip_prenosa := "0"

    if FOUND()
        _tip_prenosa := pkonto->tip
    endif

    _i_saldo := 0
    _i_br_veze := ""
    _i_dat_val := NIL

    // provrti razlicite nacine prenosa...
    do while !data:EOF() .and. PADR( data:FieldGet( data:FieldPos( "idkonto" ) ), 7 ) == _id_konto ;
                        .and. IF( _tip_prenosa $ "1#2", ;
                            PADR( hb_utf8tostr( data:FieldGet( data:FieldPos("idpartner") ) ), 6 ) == _id_partner, .t. ) ;
                        .and. IF( _tip_prenosa $ "1", ;
                            PADR( hb_utf8tostr( data:FieldGet( data:FieldPos("brdok") ) ), 20 ) == _br_veze, .t. )
   
        _row2 := data:GetRow()

        // saldo
        _i_saldo += _row2:FieldGet( _row2:FieldPos("saldo") )

        if _tip_prenosa == "1"
            
            // broj veze
            _i_br_veze := PADR( hb_utf8tostr( _row2:FieldGet( _row2:FieldPos( "brdok" ) ) ), 20 )
        
            // datum valute ili datum naloga
            _i_dat_val := _row2:FieldGet( _row2:FieldPos( "datval" ) )
            if _i_dat_val == CTOD("")
                _i_dat_val := _row2:FieldGet( _row2:FieldPos( "datdok" ) )
            endif

        endif

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

    if _tip_prenosa $ "0#2"
        _rec["brdok"] := "PS"
    else
        _rec["brdok"] := _i_br_veze
        _rec["datval"] := _i_dat_val
    endif
  
    // po otvorenim stavkama...
    if _tip_prenosa == "1"

        if LEFT( _id_konto, 1 ) == _kl_pot
            _rec["d_p"] := "2"
            _rec["iznosbhd"] := -( _i_saldo )
        else
            _rec["d_p"] := "1"
            _rec["iznosbhd"] := _i_saldo
        endif

    else

    // ostale varijante prenosa...

        if ROUND( _i_saldo, 2 ) > 0
            _rec["d_p"] := "1"
            _rec["iznosbhd"] := ABS( _i_saldo )
        else
            _rec["d_p"] := "2"
            _rec["iznosbhd"] := ABS( _i_saldo )
        endif

    endif

	// konvertovanje valute za dvovalutni sistem
	fin_konvert_valute( @_rec, "D" )

	// ako je storno, storniraj stavku
	if storno
		_rec["iznosbhd"] := -( _rec["iznosbhd"] )
		_rec["iznosdem"] := -( _rec["iznosdem"] )
	endif

    dbf_update_rec( _rec )

enddo

MsgC()

// kopiranje sifrarnika - provjera
if _copy_sif == "D"
    
    MsgO( "Provjeravam sifranike konto/partn ..." )

    select fin_pripr
    set order to tag "1"
    go top

    f18_lock_tables( { "partn", "konto" } )
    sql_table_update( NIL, "BEGIN" )

    do while !EOF()

        _pr_konto := field->idkonto
        _pr_partn := field->idpartner
       
        if !EMPTY( _pr_konto )
            append_sif_konto( _pr_konto, konto_data )
        endif

        if !EMPTY( _pr_partn )
            append_sif_partn( _pr_partn, partn_data )
        endif

        select fin_pripr
        skip

    enddo

    sql_table_update( NIL, "END" )
    f18_free_tables( { "partn", "konto" } )

    MsgC()

    go top

endif

if _rbr > 0
    _ret := .t.
endif

return _ret




// -----------------------------------------------------------------
// appenduj u sifranik konta ako nema zapisa...
// -----------------------------------------------------------------
static function append_sif_konto( id_konto, konto_data )
local _t_area := SELECT()
local _kto_id := ""
local _kto_naz := ""
local _append := .f.
local oRow

O_KONTO

select konto
go top
seek PADR( id_konto, 7 )

if FOUND()
    select ( _t_area )
    return _append
endif

konto_data:GoTo(1)

// pronadji ga u matrici
do while !konto_data:EOF()

    oRow := konto_data:GetRow()

    if PADR( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("id") ) ), 7 ) == id_konto
        // imamo ga !!!
        _kto_id := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("id") ) )
        _kto_naz := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("naz") ) )

        _append := .t.

        exit

    endif

    konto_data:Skip()

enddo

if _append

    // nema zapisa, dodaj ga...
    APPEND BLANK

    _rec := dbf_get_rec()
    _rec["id"] := _kto_id
    _rec["naz"] := _kto_naz

    update_rec_server_and_dbf( "konto", _rec, 1, "CONT" )

endif

select ( _t_area )
return _append


// -----------------------------------------------------------------
// appenduj u sifranik partnera ako nema zapisa...
// -----------------------------------------------------------------
static function append_sif_partn( id_partn, partn_data )
local _t_area := SELECT()
local _part_id := ""
local _part_naz := ""
local _append := .f.
local oRow

O_PARTN

select partn
go top
seek PADR( id_partn, 6 )

if FOUND()
    select ( _t_area )
    return _append
endif

partn_data:GoTo(1)

// pronadji ga u matrici
do while !partn_data:EOF()

    oRow := partn_data:GetRow()

    if PADR( hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("id") ) ), 6 ) == id_partn
        // imamo ga !!!
        _part_id := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("id") ) )
        _part_naz := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos("naz") ) )

        _append := .t.

        exit

    endif

    partn_data:Skip()

enddo

if _append  
    // nema zapisa, dodaj ga...
    APPEND BLANK

    _rec := dbf_get_rec()
    _rec["id"] := _part_id
    _rec["naz"] := _part_naz
    _rec["ptt"] := "?????"
    update_rec_server_and_dbf( "partn", _rec, 1, "CONT" )

endif

select ( _t_area )
return _append




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
static function get_data( param, data_fin, konto_data, partner_data )
local _server
local _qry, _qry_2, _qry_3, _where
local _dat_od := param["datum_od"]
local _dat_do := param["datum_do"]
local _dat_ps := param["datum_ps"]
local _change_db := param["change_db"] == "D"
local _copy_sif := param["copy_sif"]
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
            "sub.datdok, " + ;
            "sub.datval, " + ;
            "sub.brdok, " + ;
            "sub.otvst, " + ;
            "SUM( CASE WHEN sub.d_p = '1' THEN sub.iznosbhd ELSE -sub.iznosbhd END ) AS saldo " + ; 
        " FROM fmk.fin_suban sub "

_qry += _where

_qry += " GROUP BY sub.idkonto, sub.idpartner, sub.brdok, sub.datdok, sub.datval, sub.otvst "
_qry += " ORDER BY sub.idkonto, sub.idpartner, sub.brdok, sub.datdok, sub.datval, sub.otvst "


// 1) predji u sezonsko podrucje
// ------------------------------------------------------------
// prebaci se u sezonu
// samo ako je potrebno !
if _change_db
	switch_to_database( _db_params, _tek_database, _year_sez )
endif

// setuj server
_server := pg_server()

MsgO( "pocetno stanje - sql query u toku..." )

// podaci pocetnog stanja su ovdje....
data_fin := _sql_query( _server, _qry )

if _copy_sif == "D"

    // prikupi podatke konta
    _qry_2 := "SELECT * FROM fmk.konto ORDER BY id"
    konto_data := _sql_query( _server, _qry_2 )

    // prikupi podatke partnera
    _qry_3 := "SELECT * FROM fmk.partn ORDER BY id"
    partner_data := _sql_query( _server, _qry_3 )

else

    konto_data := NIL
    partner_data := NIL

endif

if VALTYPE( data_fin ) == "L"
    data_fin := NIL    
else
    data_fin:Refresh()
    // ako nema zapisa u tabeli...
    if data_fin:LastRec() == 0
        data_fin := NIL
    endif
endif

MsgC()

// 3) vrati se u tekucu bazu...
// ------------------------------------------------------------
if _change_db
	switch_to_database( _db_params, _tek_database, _year_tek )
	_server := pg_server()
endif

return






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






