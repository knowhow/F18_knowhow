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


FUNCTION kalk_mag_lager_lista_sql( hParams, lPocetnoStanje )

   LOCAL _data
   LOCAL _qry, _where
   LOCAL dDatOd, dDatDo, dDatPocStanje, cIdKontoMagacin
   LOCAL _art_filter, _dok_filter, _tar_filter, _part_filter
   LOCAL _db_params := my_server_params()
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _year_sez, _year_tek
   LOCAL _zaokr := AllTrim( Str( gZaokr ) )

   IF hParams == NIL
      hParams := hb_Hash()
      IF !kalk_mag_lager_lista_vars( @hParams, lPocetnoStanje )
         RETURN NIL
      ENDIF
   ENDIF

   dDatOd := hParams[ "datum_od" ]
   dDatDo := hParams[ "datum_do" ]
   dDatPocStanje := hParams[ "datum_ps" ]
   cIdKontoMagacin := hParams[ "m_konto" ]
   _year_sez := Year( dDatDo )
   _year_tek := Year( dDatPocStanje )


   _where := " WHERE "
   _where += _sql_date_parse( "k.datdok", dDatOd, dDatDo )
   _where += " AND " + _sql_cond_parse( "k.idfirma", gFirma )
   _where += " AND " + _sql_cond_parse( "k.mkonto", cIdKontoMagacin )

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

   IF lPocetnoStanje
      switch_to_database( _db_params, _tek_database, _year_sez )
   ENDIF

   IF lPocetnoStanje
      MsgO( "početno stanje - sql query u toku..." )
   ELSE
      MsgO( "formiranje podataka u toku...." )
   ENDIF

   _data := run_sql_query( _qry )

   IF !is_var_objekat_tpqquery( _data )
      _data := NIL
   ELSE
      IF _data:LastRec() == 0
         _data := NIL
      ENDIF
   ENDIF

   MsgC()

   IF lPocetnoStanje
      switch_to_database( _db_params, _tek_database, _year_tek )
   ENDIF

   RETURN _data




FUNCTION kalk_mag_lager_lista_vars( hParams, lPocetnoStanje )

   LOCAL _ret := .T.
   LOCAL cIdKontoMagacin, dDatOd, dDatDo, _nule, _pr_nab, _roba_tip_tu, dDatPocStanje, _do_nab
   LOCAL nX := 1
   LOCAL _art_filter := Space( 300 )
   LOCAL _tar_filter := Space( 300 )
   LOCAL _part_filter := Space( 300 )
   LOCAL _dok_filter := Space( 300 )
   LOCAL _brfakt_filter := Space( 300 )
   LOCAL _curr_user := my_user()
   LOCAL cMinimalneKolicineDN

   IF lPocetnoStanje == NIL
      lPocetnoStanje := .F.
   ENDIF

   cMinimalneKolicineDN := fetch_metric( "kalk_lager_lista_mag_minimalne_kolicine", _curr_user, "N" )
   _do_nab := fetch_metric( "kalk_lager_Lista_mag_prikaz_do_nabavne", _curr_user, "N" )
   cIdKontoMagacin := fetch_metric( "kalk_lager_lista_mag_id_konto", _curr_user, PadR( "1320", 7 ) )
   _pr_nab := fetch_metric( "kalk_lager_lista_mag_po_nabavnoj", _curr_user, "D" )
   _nule := fetch_metric( "kalk_lager_lista_mag_prikaz_nula", _curr_user, "N" )
   dDatOd := fetch_metric( "kalk_lager_lista_mag_datum_od", _curr_user, Date() - 30 )
   dDatDo := fetch_metric( "kalk_lager_lista_mag_datum_do", _curr_user, Date() )
   dDatPocStanje := NIL
   _roba_tip_tu := "N"

   IF lPocetnoStanje
      dDatOd := CToD( "01.01." + AllTrim( Str( Year( Date() ) -1 ) ) )
      dDatDo := CToD( "31.12." + AllTrim( Str( Year( Date() ) -1 ) ) )
      dDatPocStanje := CToD( "01.01." + AllTrim( Str( Year( Date() ) ) ) )
   ENDIF

   Box( "# LAGER LISTA MAGACINA" + IIF( lPocetnoStanje, " / POČETNO STANJE", "" ), 15, MAXCOLS() - 5 )

   @ m_x + nX, m_y + 2 SAY "Firma "

   ?? gFirma, "-", AllTrim( gNFirma )

   ++ nX
   ++ nX
   @ m_x + nX, m_y + 2 SAY "Magacinski konto:" GET cIdKontoMagacin VALID P_Konto( @cIdKontoMagacin )

   ++ nX
   @ m_x + nX, m_y + 2 SAY "Datum od:" GET dDatOd
   @ m_x + nX, Col() + 1 SAY "do:" GET dDatDo

   IF lPocetnoStanje
      @ m_x + nX, Col() + 1 SAY8 "Datum poč.stanja:" GET dDatPocStanje
   ENDIF

   ++ nX
   ++ nX
   @ m_x + nX, m_y + 2 SAY "Filter po artiklima:" GET _art_filter PICT "@S50"
   ++ nX
   @ m_x + nX, m_y + 2 SAY "Filter po tarifama:" GET _tar_filter PICT "@S50"
   ++ nX
   @ m_x + nX, m_y + 2 SAY "Filter po partnerima:" GET _part_filter PICT "@S50"
   ++ nX
   @ m_x + nX, m_y + 2 SAY "Filter po v.dokument:" GET _dok_filter PICT "@S50"
   ++ nX
   @ m_x + nX, m_y + 2 SAY "Filter po broju.fakt:" GET _brfakt_filter PICT "@S50"

   ++ nX
   ++ nX
   @ m_x + nX, m_y + 2 SAY "Prikaz nabavne vrijednosti (D/N)" GET _pr_nab VALID _pr_nab $ "DN" PICT "@!"
   @ m_x + nX, Col() + 1 SAY "Prikaz stavki kojima je NV = 0 (D/N)" GET _nule VALID _nule $ "DN" PICT "@!"

   ++ nX
   @ m_x + nX, m_y + 2 SAY8 "Prikaz samo kritičnih zaliha (D/N)" GET cMinimalneKolicineDN VALID cMinimalneKolicineDN $ "DN" PICT "@!"

   ++ nX
   @ m_x + nX, m_y + 2 SAY "Prikaz robe tipa T/U (D/N)" GET _roba_tip_tu VALID _roba_tip_tu $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "kalk_lager_Lista_mag_prikaz_do_nabavne", _curr_user, _do_nab )
   set_metric( "kalk_lager_lista_mag_id_konto", _curr_user, cIdKontoMagacin )
   set_metric( "kalk_lager_lista_mag_po_nabavnoj", _curr_user, _pr_nab )
   set_metric( "kalk_lager_lista_mag_prikaz_nula", _curr_user, _nule )
   set_metric( "kalk_lager_lista_mag_datum_od", _curr_user, dDatOd )
   set_metric( "kalk_lager_lista_mag_datum_do", _curr_user, dDatDo )
   set_metric( "kalk_lager_lista_mag_minimalne_kolicine", _curr_user, cMinimalneKolicineDN )

   hParams[ "datum_od" ] := dDatOd
   hParams[ "datum_do" ] := dDatDo
   hParams[ "datum_ps" ] := dDatPocStanje
   hParams[ "m_konto" ] := cIdKontoMagacin
   hParams[ "nule" ] := _nule
   hParams[ "roba_tip_tu" ] := _roba_tip_tu
   hParams[ "pr_nab" ] := _pr_nab
   hParams[ "do_nab" ] := _do_nab
   hParams[ "min_kol" ] := cMinimalneKolicineDN
   hParams[ "filter_dok" ] := _dok_filter
   hParams[ "filter_roba" ] := _art_filter
   hParams[ "filter_partner" ] := _part_filter
   hParams[ "filter_tarifa" ] := _tar_filter
   hParams[ "filter_brfakt" ] := _brfakt_filter

   RETURN _ret



FUNCTION kalk_pocetno_stanje_magacin()

   LOCAL _ps := .T.
   LOCAL _param := NIL
   LOCAL _data
   LOCAL nCount := 0

   _data := kalk_mag_lager_lista_sql( @_param, _ps )

   IF _data == NIL
      RETURN .F.
   ENDIF

   nCount := kalk_mag_insert_ps_into_pripr( _data, _param )

   IF nCount > 0
      renumeracija_kalk_pripr( nil, nil, .T. )
      my_close_all_dbf()
      kalk_azuriranje_dokumenta( .T. )
      MsgBeep( "Formiran dokument početnog stanja i automatski ažuriran !" )
   ENDIF

   RETURN .T.


STATIC FUNCTION kalk_mag_insert_ps_into_pripr( oDataSet, hParams )

   LOCAL nCount := 0
   LOCAL cBrKalk := ""
   LOCAL cIdVd := "16"
   LOCAL dDatumKalk := hParams[ "datum_ps" ]
   LOCAL cIdKontoMagacin := hParams[ "m_konto" ]
   LOCAL _roba_tip_tu := hParams[ "roba_tip_tu" ]
   LOCAL oRow, _sufix
   LOCAL _ulaz, _izlaz, _nvu, _nvi, _id_roba, _vpvu, _vpvi
   LOCAL _magacin_po_nabavnoj := .T.
   LOCAL hRec

   o_kalk_pripr()
   o_kalk_doks()
   o_koncij()
   O_ROBA
   O_TARIFA

   cBrKalk := kalk_get_next_broj_v5( gFirma, cIdVd, cIdKontoMagacin )


   IF Empty( cBrKalk )
      cBrKalk := PadR( "00001", 8 )
   ENDIF

   SELECT koncij
   GO TOP
   SEEK cIdKontoMagacin

   MsgO( "Punjenje pripreme podacima početnog stanja u toku, dok: " + cIdVd + "-" + AllTrim( cBrKalk ) )

   oDataSet:GoTo(1)

   DO WHILE !oDataSet:Eof()

      oRow := oDataSet:GetRow()

      _id_roba := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "idroba" ) ) )
      _ulaz := oRow:FieldGet( oRow:FieldPos( "ulaz" ) )
      _izlaz := oRow:FieldGet( oRow:FieldPos( "izlaz" ) )
      _nvu := oRow:FieldGet( oRow:FieldPos( "nvu" ) )
      _nvi := oRow:FieldGet( oRow:FieldPos( "nvi" ) )
      _vpvu := oRow:FieldGet( oRow:FieldPos( "vpvu" ) )
      _vpvi := oRow:FieldGet( oRow:FieldPos( "vpvi" ) )

      SELECT roba
      GO TOP
      SEEK _id_roba

      IF _roba_tip_tu == "N" .AND. roba->tip $ "TU"
         oDataSet:Skip()
         LOOP
      ENDIF

      IF Round( _ulaz - _izlaz, 2 ) == 0
         oDataSet:Skip()
         LOOP
      ENDIF

      SELECT kalk_pripr
      APPEND BLANK

      hRec := dbf_get_rec()

      hRec[ "idfirma" ] := gFirma
      hRec[ "idvd" ] := cIdVd
      hRec[ "brdok" ] := cBrKalk
      hRec[ "rbr" ] := Str( ++nCount, 3 )
      hRec[ "datdok" ] := dDatumKalk
      hRec[ "idroba" ] := _id_roba
      hRec[ "idkonto" ] := cIdKontoMagacin
      hRec[ "mkonto" ] := cIdKontoMagacin
      hRec[ "idtarifa" ] := roba->idtarifa
      hRec[ "mu_i" ] := "1"
      hRec[ "brfaktp" ] := PadR( "PS", Len( hRec[ "brfaktp" ] ) )
      hRec[ "datfaktp" ] := dDatumKalk
      hRec[ "kolicina" ] := ( _ulaz - _izlaz )
      hRec[ "nc" ] := ( _nvu - _nvi ) / ( _ulaz - _izlaz )
      hRec[ "vpc" ] := ( _vpvu - _vpvi ) / ( _ulaz - _izlaz )
      hRec[ "error" ] := "0"

      IF _magacin_po_nabavnoj
         hRec[ "vpc" ] := hRec[ "nc" ]
      ENDIF

      dbf_update_rec( hRec )

      oDataSet:Skip()

   ENDDO

   MsgC()

   RETURN nCount
