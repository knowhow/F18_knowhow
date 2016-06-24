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


FUNCTION kalk_prod_lager_lista_sql( params, ps )

   LOCAL _data
   LOCAL _qry, _where
   LOCAL _dat_od, _dat_do, _dat_ps, _p_konto
   LOCAL _art_filter, _dok_filter, _tar_filter, _part_filter
   LOCAL _db_params := my_server_params()
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _year_sez, _year_tek

   IF params == NIL
      params := hb_Hash()
      IF !kalk_prod_lager_lista_vars( @params, ps )
         RETURN NIL
      ENDIF
   ENDIF

   _dat_od := params[ "datum_od" ]
   _dat_do := params[ "datum_do" ]
   _dat_ps := params[ "datum_ps" ]
   _p_konto := params[ "p_konto" ]
   _year_sez := Year( _dat_do )
   _year_tek := Year( _dat_ps )


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
      " FROM " + F18_PSQL_SCHEMA_DOT + "kalk_kalk k "

   _qry += _where

   _qry += " GROUP BY k.idroba "
   _qry += " ORDER BY k.idroba "

   IF ps
      switch_to_database( _db_params, _tek_database, _year_sez )
   ENDIF

   IF ps
      MsgO( "pocetno stanje - sql query u toku..." )
   ELSE
      MsgO( "formiranje podataka u toku..." )
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

   IF ps
      switch_to_database( _db_params, _tek_database, _year_tek )
   ENDIF

   RETURN _data




FUNCTION kalk_prod_lager_lista_vars( params, ps )

   LOCAL _ret := .T.
   LOCAL _p_konto, _dat_od, _dat_do, _nule, _pr_nab, _roba_tip_tu, _dat_ps
   LOCAL _x := 1
   LOCAL _art_filter := Space( 300 )
   LOCAL _tar_filter := Space( 300 )
   LOCAL _part_filter := Space( 300 )
   LOCAL _dok_filter := Space( 300 )
   LOCAL _curr_user := my_user()
   LOCAL _set_roba := "N"

   IF ps == NIL
      ps := .F.
   ENDIF

   _p_konto := fetch_metric( "kalk_lager_lista_prod_id_konto", _curr_user, PadR( "1330", 7 ) )
   _pr_nab := fetch_metric( "kalk_lager_lista_prod_po_nabavnoj", _curr_user, "D" )
   _nule := fetch_metric( "kalk_lager_lista_prod_prikaz_nula", _curr_user, "N" )
   _dat_od := fetch_metric( "kalk_lager_lista_prod_datum_od", _curr_user, Date() - 30 )
   _dat_do := fetch_metric( "kalk_lager_lista_prod_datum_do", _curr_user, Date() )
   _dat_ps := NIL
   _roba_tip_tu := "N"

   IF ps
      _dat_od := CToD( "01.01." + AllTrim( Str( Year( Date() ) -1 ) ) )
      _dat_do := CToD( "31.12." + AllTrim( Str( Year( Date() ) -1 ) ) )
      _dat_ps := CToD( "01.01." + AllTrim( Str( Year( Date() ) ) ) )
   ENDIF

   Box( "# LAGER LISTA PRODAVNICE" + if( ps, " / POČETNO STANJE", "" ), 15, MAXCOLS() - 5 )

   @ m_x + _x, m_y + 2 SAY "Firma "

   ?? gFirma, "-", AllTrim( gNFirma )

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Prodavnički konto:" GET _p_konto VALID P_Konto( @_p_konto )

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
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Prikaz nabavne vrijednosti (D/N)" GET _pr_nab VALID _pr_nab $ "DN" PICT "@!"
   @ m_x + _x, Col() + 1 SAY "Prikaz stavki kojima je MPV=0 (D/N)" GET _nule VALID _nule $ "DN" PICT "@!"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Prikaz robe tipa T/U (D/N)" GET _roba_tip_tu VALID _roba_tip_tu $ "DN" PICT "@!"

   IF ps
      @ m_x + _x, Col() + 1 SAY8 "MPC uzmi iz šifarnika (D/N) ?" GET _set_roba VALID _set_roba $ "DN" PICT "@!"
   ENDIF

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "kalk_lager_lista_prod_id_konto", _curr_user, _p_konto )
   set_metric( "kalk_lager_lista_prod_po_nabavnoj", _curr_user, _pr_nab )
   set_metric( "kalk_lager_lista_prod_prikaz_nula", _curr_user, _nule )
   set_metric( "kalk_lager_lista_prod_datum_od", _curr_user, _dat_od )
   set_metric( "kalk_lager_lista_prod_datum_do", _curr_user, _dat_do )

   params[ "datum_od" ] := _dat_od
   params[ "datum_do" ] := _dat_do
   params[ "datum_ps" ] := _dat_ps
   params[ "p_konto" ] := _p_konto
   params[ "nule" ] := _nule
   params[ "roba_tip_tu" ] := _roba_tip_tu
   params[ "pr_nab" ] := _pr_nab
   params[ "filter_dok" ] := _dok_filter
   params[ "filter_roba" ] := _art_filter
   params[ "filter_partner" ] := _part_filter
   params[ "filter_tarifa" ] := _tar_filter
   params[ "set_mpc" ] := ( _set_roba == "D" )

   RETURN _ret



FUNCTION kalk_prod_pocetno_stanje()

   LOCAL _ps := .T.
   LOCAL _param := NIL
   LOCAL _data
   LOCAL _count := 0

   _data := kalk_prod_lager_lista_sql( @_param, _ps )

   IF _data == NIL
      RETURN
   ENDIF

   _count := kalk_prod_insert_ps_into_pripr( _data, _param )

   IF _count > 0
      renumeracija_kalk_pripr( nil, nil, .T. )
      my_close_all_dbf()
      kalk_azuriranje_dokumenta( .T. )
      MsgBeep( "Formiran dokument početnog stanja i automatski ažuriran !" )
   ENDIF

   RETURN




STATIC FUNCTION kalk_prod_insert_ps_into_pripr( data, params )

   LOCAL _count := 0
   LOCAL _kalk_broj := ""
   LOCAL _kalk_tip := "80"
   LOCAL _kalk_datum := params[ "datum_ps" ]
   LOCAL _p_konto := params[ "p_konto" ]
   LOCAL _roba_tip_tu := params[ "roba_tip_tu" ]
   LOCAL _row, _sufix
   LOCAL _ulaz, _izlaz, _nvu, _nvi, _mpvu, _mpvi, _id_roba

   PRIVATE aPorezi := {}

   o_kalk_pripr()
   o_kalk_doks()
   o_koncij()
   O_ROBA
   O_TARIFA

   IF glBrojacPoKontima
      _sufix := SufBrKalk( _p_konto )
      _kalk_broj := kalk_sljedeci_brdok( _kalk_tip, gFirma, _sufix )
   ELSE
      _kalk_broj := GetNextKalkDoc( gFirma, _kalk_tip )
   ENDIF

   IF Empty( _kalk_broj )
      _kalk_broj := PadR( "00001", 8 )
   ENDIF

   SELECT koncij
   GO TOP
   SEEK _p_konto

   MsgO( "Punjenje pripreme podacima početnog stanja u toku, dok: " + _kalk_tip + "-" + AllTrim( _kalk_broj ) )

   data:GoTo(1)

   DO WHILE !data:Eof()

      _row := data:GetRow()

      _id_roba := hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "idroba" ) ) )
      _ulaz := _row:FieldGet( _row:FieldPos( "ulaz" ) )
      _izlaz := _row:FieldGet( _row:FieldPos( "izlaz" ) )
      _nvu := _row:FieldGet( _row:FieldPos( "nvu" ) )
      _nvi := _row:FieldGet( _row:FieldPos( "nvi" ) )
      _mpvu := _row:FieldGet( _row:FieldPos( "mpvu" ) )
      _mpvi := _row:FieldGet( _row:FieldPos( "mpvi" ) )

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
      _rec[ "idkonto" ] := _p_konto
      _rec[ "pkonto" ] := _p_konto

      _rec[ "idtarifa" ] := Tarifa( _p_konto, _id_roba, @aPorezi )

      VTPorezi()

      _rec[ "tcardaz" ] := "%"
      _rec[ "pu_i" ] := "1"
      _rec[ "brfaktp" ] := PadR( "PS", Len( _rec[ "brfaktp" ] ) )
      _rec[ "datfaktp" ] := _kalk_datum
      _rec[ "tmarza2" ] := "A"

      _rec[ "kolicina" ] := ( _ulaz - _izlaz )
      _rec[ "nc" ] := ( _nvu - _nvi ) / ( _ulaz - _izlaz )
      _rec[ "fcj" ] := _rec[ "nc" ]
      _rec[ "vpc" ] := _rec[ "nc" ]
      _rec[ "error" ] := "0"
      _rec[ "mpcsapp" ] := Round( ( _mpvu - _mpvi ) / ( _ulaz - _izlaz ), 2 )

      IF params[ "set_mpc" ]
         _rec[ "mpcsapp" ] := UzmiMpcSif()
      ENDIF

      IF _rec[ "mpcsapp" ] <> 0
         _rec[ "mpc" ] := MpcBezPor( _rec[ "mpcsapp" ], aPorezi, NIL, _rec[ "nc" ] )
         _rec[ "marza2" ] := _rec[ "mpc" ] - _rec[ "nc" ]
      ENDIF

      dbf_update_rec( _rec )

      data:Skip()

   ENDDO

   MsgC()

   RETURN _count
