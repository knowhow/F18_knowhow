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


#include "f18.ch"


FUNCTION kalk_mag_lager_lista_sql( params, ps )

   LOCAL _data, _server
   LOCAL _qry, _where
   LOCAL _dat_od, _dat_do, _dat_ps, _m_konto
   LOCAL _art_filter, _dok_filter, _tar_filter, _part_filter
   LOCAL _db_params := my_server_params()
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _year_sez, _year_tek
   LOCAL _zaokr := AllTrim( Str( gZaokr ) )

   IF params == NIL
      params := hb_Hash()
      IF !kalk_mag_lager_lista_vars( @params, ps )
         RETURN NIL
      ENDIF
   ENDIF

   _dat_od := params[ "datum_od" ]
   _dat_do := params[ "datum_do" ]
   _dat_ps := params[ "datum_ps" ]
   _m_konto := params[ "m_konto" ]
   _year_sez := Year( _dat_do )
   _year_tek := Year( _dat_ps )


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
      "WHEN k.mu_i = '1' AND k.idvd IN ('12', '22', '94') THEN -k.kolicina " + ;
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
      " FROM " + F18_PSQL_SCHEMA_DOT + "kalk_kalk k " + ;
      " RIGHT JOIN " + F18_PSQL_SCHEMA_DOT + " roba r ON r.id = k.idroba "

   _qry += _where

   _qry += " GROUP BY k.idroba "
   _qry += " ORDER BY k.idroba "

   IF ps
      switch_to_database( _db_params, _tek_database, _year_sez )
      _server := pg_server()
   ENDIF

   IF ps
      MsgO( "početno stanje - sql query u toku..." )
   ELSE
      MsgO( "formiranje podataka u toku...." )
   ENDIF

   _data := _sql_query( _server, _qry )

   IF !is_var_objekat_tpqquery( _data ) 
      _data := NIL
   ELSE
      IF _data:LastRec() == 0
         _data := NIL
      ENDIF
   ENDIF

   MsgC()

   IF ps
      switch_to_database( _db_params, _tek_database, _year_tek )
      _server := pg_server()
   ENDIF

   RETURN _data




FUNCTION kalk_mag_lager_lista_vars( params, ps )

   LOCAL _ret := .T.
   LOCAL _m_konto, _dat_od, _dat_do, _nule, _pr_nab, _roba_tip_tu, _dat_ps, _do_nab
   LOCAL _x := 1
   LOCAL _art_filter := Space( 300 )
   LOCAL _tar_filter := Space( 300 )
   LOCAL _part_filter := Space( 300 )
   LOCAL _dok_filter := Space( 300 )
   LOCAL _brfakt_filter := Space( 300 )
   LOCAL _curr_user := my_user()

   IF ps == NIL
      ps := .F.
   ENDIF

   _min_kol := fetch_metric( "kalk_lager_lista_mag_minimalne_kolicine", _curr_user, "N" )
   _do_nab := fetch_metric( "kalk_lager_Lista_mag_prikaz_do_nabavne", _curr_user, "N" )
   _m_konto := fetch_metric( "kalk_lager_lista_mag_id_konto", _curr_user, PadR( "1320", 7 ) )
   _pr_nab := fetch_metric( "kalk_lager_lista_mag_po_nabavnoj", _curr_user, "D" )
   _nule := fetch_metric( "kalk_lager_lista_mag_prikaz_nula", _curr_user, "N" )
   _dat_od := fetch_metric( "kalk_lager_lista_mag_datum_od", _curr_user, Date() - 30 )
   _dat_do := fetch_metric( "kalk_lager_lista_mag_datum_do", _curr_user, Date() )
   _dat_ps := NIL
   _roba_tip_tu := "N"

   IF ps
      _dat_od := CToD( "01.01." + AllTrim( Str( Year( Date() ) -1 ) ) )
      _dat_do := CToD( "31.12." + AllTrim( Str( Year( Date() ) -1 ) ) )
      _dat_ps := CToD( "01.01." + AllTrim( Str( Year( Date() ) ) ) )
   ENDIF

   Box( "# LAGER LISTA MAGACINA" + if( ps, " / POČETNO STANJE", "" ), 15, MAXCOLS() - 5 )

   @ m_x + _x, m_y + 2 SAY "Firma "
		
   ?? gFirma, "-", AllTrim( gNFirma )

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Magacinski konto:" GET _m_konto VALID P_Konto( @_m_konto )

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Datum od:" GET _dat_od
   @ m_x + _x, Col() + 1 SAY "do:" GET _dat_do

   IF ps
      @ m_x + _x, Col() + 1 SAY8 "Datum poč.stanja:" GET _dat_ps
   ENDIF

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

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Prikaz nabavne vrijednosti (D/N)" GET _pr_nab VALID _pr_nab $ "DN" PICT "@!"
   @ m_x + _x, Col() + 1 SAY "Prikaz stavki kojima je NV = 0 (D/N)" GET _nule VALID _nule $ "DN" PICT "@!"

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Prikaz samo kritičnih zaliha (D/N)" GET _min_kol VALID _min_kol $ "DN" PICT "@!"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Prikaz robe tipa T/U (D/N)" GET _roba_tip_tu VALID _roba_tip_tu $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "kalk_lager_Lista_mag_prikaz_do_nabavne", _curr_user, _do_nab )
   set_metric( "kalk_lager_lista_mag_id_konto", _curr_user, _m_konto )
   set_metric( "kalk_lager_lista_mag_po_nabavnoj", _curr_user, _pr_nab )
   set_metric( "kalk_lager_lista_mag_prikaz_nula", _curr_user, _nule )
   set_metric( "kalk_lager_lista_mag_datum_od", _curr_user, _dat_od )
   set_metric( "kalk_lager_lista_mag_datum_do", _curr_user, _dat_do )
   set_metric( "kalk_lager_lista_mag_minimalne_kolicine", _curr_user, _min_kol )

   params[ "datum_od" ] := _dat_od
   params[ "datum_do" ] := _dat_do
   params[ "datum_ps" ] := _dat_ps
   params[ "m_konto" ] := _m_konto
   params[ "nule" ] := _nule
   params[ "roba_tip_tu" ] := _roba_tip_tu
   params[ "pr_nab" ] := _pr_nab
   params[ "do_nab" ] := _do_nab
   params[ "min_kol" ] := _min_kol
   params[ "filter_dok" ] := _dok_filter
   params[ "filter_roba" ] := _art_filter
   params[ "filter_partner" ] := _part_filter
   params[ "filter_tarifa" ] := _tar_filter
   params[ "filter_brfakt" ] := _brfakt_filter

   RETURN _ret



FUNCTION kalk_mag_pocetno_stanje()

   LOCAL _ps := .T.
   LOCAL _param := NIL
   LOCAL _data
   LOCAL _count := 0

   _data := kalk_mag_lager_lista_sql( @_param, _ps )

   IF _data == NIL
      RETURN
   ENDIF

   _count := kalk_mag_insert_ps_into_pripr( _data, _param )

   IF _count > 0
      renumeracija_kalk_pripr( nil, nil, .T. )
      my_close_all_dbf()
      kalk_azuriranje_dokumenta( .T. )
      MsgBeep( "Formiran dokument početnog stanja i automatski ažuriran !" )
   ENDIF

   RETURN


STATIC FUNCTION kalk_mag_insert_ps_into_pripr( data, params )

   LOCAL _count := 0
   LOCAL _kalk_broj := ""
   LOCAL _kalk_tip := "16"
   LOCAL _kalk_datum := params[ "datum_ps" ]
   LOCAL _m_konto := params[ "m_konto" ]
   LOCAL _roba_tip_tu := params[ "roba_tip_tu" ]
   LOCAL _row, _sufix
   LOCAL _ulaz, _izlaz, _nvu, _nvi, _id_roba, _vpvu, _vpvi
   LOCAL _magacin_po_nabavnoj := IsMagPNab()

   O_KALK_PRIPR
   O_KALK_DOKS
   O_KONCIJ
   O_ROBA
   O_TARIFA

   IF glBrojacPoKontima
      _sufix := SufBrKalk( _m_konto )
      _kalk_broj := SljBrKalk( _kalk_tip, gFirma, _sufix )
   ELSE
      _kalk_broj := GetNextKalkDoc( gFirma, _kalk_tip )
   ENDIF

   IF Empty( _kalk_broj )
      _kalk_broj := PadR( "00001", 8 )
   ENDIF

   SELECT koncij
   GO TOP
   SEEK _m_konto

   MsgO( "Punjenje pripreme podacima početnog stanja u toku, dok: " + _kalk_tip + "-" + AllTrim( _kalk_broj ) )

   data:GoTo(1)

   DO WHILE !data:Eof()

      _row := data:GetRow()

      _id_roba := hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "idroba" ) ) )
      _ulaz := _row:FieldGet( _row:FieldPos( "ulaz" ) )
      _izlaz := _row:FieldGet( _row:FieldPos( "izlaz" ) )
      _nvu := _row:FieldGet( _row:FieldPos( "nvu" ) )
      _nvi := _row:FieldGet( _row:FieldPos( "nvi" ) )
      _vpvu := _row:FieldGet( _row:FieldPos( "vpvu" ) )
      _vpvi := _row:FieldGet( _row:FieldPos( "vpvi" ) )

      SELECT roba
      GO TOP
      SEEK _id_roba

      IF _roba_tip_tu == "N" .AND. roba->tip $ "TU"
         data:Skip()
         LOOP
      ENDIF

      IF Round( _ulaz - _izlaz, 2 ) == 0
         data:Skip()
         LOOP
      ENDIF

      SELECT kalk_pripr
      APPEND BLANK

      _rec := dbf_get_rec()

      _rec[ "idfirma" ] := gFirma
      _rec[ "idvd" ] := _kalk_tip
      _rec[ "brdok" ] := _kalk_broj
      _rec[ "rbr" ] := Str( ++_count, 3 )
      _rec[ "datdok" ] := _kalk_datum
      _rec[ "idroba" ] := _id_roba
      _rec[ "idkonto" ] := _m_konto
      _rec[ "mkonto" ] := _m_konto
      _rec[ "idtarifa" ] := roba->idtarifa
      _rec[ "mu_i" ] := "1"
      _rec[ "brfaktp" ] := PadR( "PS", Len( _rec[ "brfaktp" ] ) )
      _rec[ "datfaktp" ] := _kalk_datum
      _rec[ "kolicina" ] := ( _ulaz - _izlaz )
      _rec[ "nc" ] := ( _nvu - _nvi ) / ( _ulaz - _izlaz )
      _rec[ "vpc" ] := ( _vpvu - _vpvi ) / ( _ulaz - _izlaz )
      _rec[ "error" ] := "0"

      IF _magacin_po_nabavnoj
         _rec[ "vpc" ] := _rec[ "nc" ]
      ENDIF

      dbf_update_rec( _rec )

      data:Skip()
	
   ENDDO

   MsgC()
		
   RETURN _count
