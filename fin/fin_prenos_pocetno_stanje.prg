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

#include "f18.ch"


STATIC FUNCTION _o_tables()

   SELECT ( F_PKONTO )
   IF !Used()
      O_PKONTO
   ENDIF

   SELECT ( F_KONTO )
   IF !Used()
      O_KONTO
   ENDIF

   SELECT ( F_PARTN )
   IF !Used()
      O_PARTN
   ENDIF

   SELECT ( F_FIN_PRIPR )
   IF !Used()
      O_FIN_PRIPR
   ENDIF

   RETURN



FUNCTION fin_pocetno_stanje_sql()

   LOCAL _dug_kto, _pot_kto, _dat_ps, _dat_od, _dat_do
   LOCAL _k_1, _k_2, _k_3, _k_4
   LOCAL _copy_sif
   LOCAL _param := hb_Hash()
   LOCAL _sint
   LOCAL _data, _partn_data, _konto_data

   _k_1 := fetch_metric( "fin_prenos_pocetno_stanje_k1", NIL, "9" )
   _k_2 := fetch_metric( "fin_prenos_pocetno_stanje_k2", NIL, "9" )
   _k_3 := fetch_metric( "fin_prenos_pocetno_stanje_k3", NIL, "99" )
   _k_4 := fetch_metric( "fin_prenos_pocetno_stanje_k4", NIL, "99" )

   _o_tables()

   P_PKonto()

   _dug_kto := fetch_metric( "fin_klasa_duguje", NIL, "2" )
   _pot_kto := fetch_metric( "fin_klasa_potrazuje", NIL, "4" )
   _sint := fetch_metric( "fin_prenos_pocetno_stanje_sint", NIL, 3 )
   _copy_sif := fetch_metric( "fin_prenos_pocetno_stanje_sif", NIL, "N" )

   _dat_od := CToD( "01.01." + AllTrim( Str( Year( Date() ) -1 ) ) )
   _dat_do := CToD( "31.12." + AllTrim( Str( Year( Date() ) -1 ) ) )
   _dat_ps := CToD( "01.01." + AllTrim( Str( Year( Date() ) ) ) )

   Box(, 9, 60 )

   @ m_x + 1, m_y + 2 SAY "Za datumski period od:" GET _dat_od
   @ m_x + 1, Col() + 1 SAY "do:" GET _dat_do

   @ m_x + 3, m_y + 2 SAY8 "Datum dokumenta početnog stanja:" GET _dat_ps

   @ m_x + 5, m_y + 2 SAY "Klasa dugovnog  konta:" GET _dug_kto
   @ m_x + 6, m_y + 2 SAY8 "Klasa potražnog konta:" GET _pot_kto

   @ m_x + 8, m_y + 2 SAY8 "Grupišem konta na broj mjesta ?" GET _sint PICT "9"
   @ m_x + 9, m_y + 2 SAY8 "Kopiraj nepostojeće sifre (konto/partn) (D/N)?" GET _copy_sif VALID _copy_sif $ "DN" PICT "@!"
  	
   READ

   ESC_BCR

   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   set_metric( "fin_klasa_duguje", NIL, _dug_kto )
   set_metric( "fin_klasa_potrazuje", NIL, _pot_kto )
   set_metric( "fin_prenos_pocetno_stanje_sint", NIL, _sint )
   set_metric( "fin_prenos_pocetno_stanje_sif", NIL, _copy_sif )
   set_metric( "fin_prenos_pocetno_stanje_k1", NIL, _k_1 )
   set_metric( "fin_prenos_pocetno_stanje_k2", NIL, _k_2 )
   set_metric( "fin_prenos_pocetno_stanje_k3", NIL, _k_3 )
   set_metric( "fin_prenos_pocetno_stanje_k4", NIL, _k_4 )

   _param[ "klasa_duguje" ] := _dug_kto
   _param[ "klasa_potrazuje" ] := _pot_kto
   _param[ "k_1" ] := _k_1
   _param[ "k_2" ] := _k_2
   _param[ "k_3" ] := _k_3
   _param[ "k_4" ] := _k_4
   _param[ "datum_od" ] := _dat_od
   _param[ "datum_do" ] := _dat_do
   _param[ "datum_ps" ] := _dat_ps
   _param[ "sintetika" ] := _sint
   _param[ "copy_sif" ] := _copy_sif

   get_data( _param, @_data, @_konto_data, @_partn_data )

   IF _data == NIL
      MsgBeep( "Ne postoje traženi podaci... prekidam operaciju !" )
      RETURN
   ENDIF

   IF !_insert_into_fin_priprema( _data, _konto_data, _partn_data, _param )
      RETURN
   ENDIF

   fin_set_broj_dokumenta()

   my_close_all_dbf()
   fin_gen_ptabele_stampa_nalozi( .T. )
   my_close_all_dbf()


   fin_azuriranje_naloga( .T. )

   MsgBeep( "Dokument formiran i automatski ažuriran..." )

   RETURN



STATIC FUNCTION _insert_into_fin_priprema( data, konto_data, partn_data, param )

   LOCAL _fin_vn := "00"
   LOCAL _fin_broj := fin_prazan_broj_naloga()
   LOCAL _dat_ps := PARAM[ "datum_ps" ]
   LOCAL _sint := PARAM[ "sintetika" ]
   LOCAL _kl_dug := PARAM[ "klasa_duguje" ]
   LOCAL _kl_pot := PARAM[ "klasa_potrazuje" ]
   LOCAL _copy_sif := PARAM[ "copy_sif" ]
   LOCAL _ret := .F.
   LOCAL _row, _duguje, _potrazuje, _id_konto, _id_partner
   LOCAL _dat_dok, _dat_val, _otv_st, _br_veze
   LOCAL _rec, _i_saldo
   LOCAL _rbr := 0
   LOCAL lOk := .T.

   _o_tables()

   IF !prazni_fin_priprema()
      RETURN _ret
   ENDIF

   MsgO( "Formiram dokument početnog stanja u tabeli pripreme." )

   _i_saldo := 0

   data:GoTo(1)

   DO WHILE !data:Eof()

      _row := data:GetRow()

      _id_konto := PadR( _row:FieldGet( _row:FieldPos( "idkonto" ) ), 7 )
      _id_partner := PadR( hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "idpartner" ) ) ), 6 )
      _br_veze := PadR( hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "brdok" ) ) ), 20 )

      _dat_dok := _row:FieldGet( _row:FieldPos( "datdok" ) )
      _dat_val := _row:FieldGet( _row:FieldPos( "datval" ) )

      _otv_st := _row:FieldGet( _row:FieldPos( "otvst" ) )

      SELECT pkonto
      GO TOP
      SEEK PadR( _id_konto, _sint )

      _tip_prenosa := "0"

      IF Found()
         _tip_prenosa := pkonto->tip
      ENDIF

      _i_saldo := 0
      _i_br_veze := ""
      _i_dat_val := NIL

      DO WHILE !data:Eof() .AND. PadR( data:FieldGet( data:FieldPos( "idkonto" ) ), 7 ) == _id_konto ;
            .AND. IF( _tip_prenosa $ "1#2", ;
            PadR( hb_UTF8ToStr( data:FieldGet( data:FieldPos( "idpartner" ) ) ), 6 ) == _id_partner, .T. ) ;
            .AND. IF( _tip_prenosa $ "1", ;
            PadR( hb_UTF8ToStr( data:FieldGet( data:FieldPos( "brdok" ) ) ), 20 ) == _br_veze, .T. )

         _row2 := data:GetRow()

         _i_saldo += _row2:FieldGet( _row2:FieldPos( "saldo" ) )

         IF _tip_prenosa == "1"

            _i_br_veze := PadR( hb_UTF8ToStr( _row2:FieldGet( _row2:FieldPos( "brdok" ) ) ), 20 )

            _i_dat_val := _row2:FieldGet( _row2:FieldPos( "datval" ) )
            IF _i_dat_val == CToD( "" )
               _i_dat_val := _row2:FieldGet( _row2:FieldPos( "datdok" ) )
            ENDIF

         ENDIF

         data:Skip()

      ENDDO

      IF Round( _i_saldo, 2 ) == 0
         LOOP
      ENDIF

      IF _tip_prenosa == "0"
         _id_partner := Space( 6 )
      ENDIF

      SELECT fin_pripr
      APPEND BLANK

      _rec := dbf_get_rec()

      _rec[ "idfirma" ] := gFirma
      _rec[ "idvn" ] := _fin_vn
      _rec[ "brnal" ] := _fin_broj
      _rec[ "datdok" ] := _dat_ps
      _rec[ "rbr" ] := Str( ++_rbr, 4 )
      _rec[ "idkonto" ] := _id_konto
      _rec[ "idpartner" ] := _id_partner
      _rec[ "opis" ] := "POCETNO STANJE"

      IF _tip_prenosa $ "0#2"
         _rec[ "brdok" ] := "PS"
      ELSE
         _rec[ "brdok" ] := _i_br_veze
         _rec[ "datval" ] := _i_dat_val
      ENDIF

      IF _tip_prenosa == "1"

         IF Left( _id_konto, 1 ) == _kl_pot
            _rec[ "d_p" ] := "2"
            _rec[ "iznosbhd" ] := -( _i_saldo )
         ELSE
            _rec[ "d_p" ] := "1"
            _rec[ "iznosbhd" ] := _i_saldo
         ENDIF

      ELSE

         IF Round( _i_saldo, 2 ) > 0
            _rec[ "d_p" ] := "1"
            _rec[ "iznosbhd" ] := Abs( _i_saldo )
         ELSE
            _rec[ "d_p" ] := "2"
            _rec[ "iznosbhd" ] := Abs( _i_saldo )
         ENDIF

      ENDIF

      fin_konvert_valute( @_rec, "D" )

      dbf_update_rec( _rec )

   ENDDO

   MsgC()

   IF _copy_sif == "D"

      MsgO( "Provjeravam šifranike konto/partn ..." )

      SELECT fin_pripr
      SET ORDER TO TAG "1"
      GO TOP

      sql_table_update( NIL, "BEGIN" )
      IF !f18_lock_tables( { "partn", "konto" }, .T. )
         sql_table_update( NIL, "END" )
         MsgBeep( "Problem sa zaključavanjem tabela !#Prekidam operaciju." )
         RETURN _ret 
      ENDIF

      DO WHILE !Eof()

         _pr_konto := field->idkonto
         _pr_partn := field->idpartner

         IF !Empty( _pr_konto )
       		
            lOk := append_sif_konto( _pr_konto, konto_data )
				
            IF lOk
               lOk := append_sif_konto( PadR( Left( _pr_konto, 1 ), 7 ), konto_data )
            ENDIF

            IF lOk
               lOk := append_sif_konto( PadR( Left( _pr_konto, 2 ), 7 ), konto_data )
            ENDIF

            IF lOk
               lOk := append_sif_konto( PadR( Left( _pr_konto, 3 ), 7 ), konto_data )
            ENDIF

         ENDIF

         IF !Empty( _pr_partn ) .AND. lOk
            lOk := append_sif_partn( _pr_partn, partn_data )
         ENDIF

         IF !lOk
            EXIT
         ENDIF

         SELECT fin_pripr
         SKIP

      ENDDO

      IF lOk
         f18_free_tables( { "partn", "konto" } )
         sql_table_update( NIL, "END" )
      ELSE
         sql_table_update( NIL, "ROLLBACK" )
         MsgBeep( "Problem sa dodavanjem novih šifri na server !" )
      ENDIF

      MsgC()

      GO TOP

   ENDIF

   IF _rbr > 0
      _ret := .T.
   ENDIF

   RETURN _ret


STATIC FUNCTION append_sif_konto( id_konto, konto_data )

   LOCAL _t_area := Select()
   LOCAL _kto_id := ""
   LOCAL _kto_naz := ""
   LOCAL _append := .F.
   LOCAL oRow
   LOCAL lOk := .T.

   O_KONTO

   SELECT konto
   GO TOP
   SEEK PadR( id_konto, 7 )

   IF Found()
      SELECT ( _t_area )
      RETURN _append
   ENDIF

   konto_data:GoTo( 1 )

   DO WHILE !konto_data:Eof()

      oRow := konto_data:GetRow()

      IF PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) ), 7 ) == id_konto
         _kto_id := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) )
         _kto_naz := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) )
         _append := .T.
         EXIT
      ENDIF

      konto_data:Skip()

   ENDDO

   IF _append

      APPEND BLANK

      _rec := dbf_get_rec()
      _rec[ "id" ] := _kto_id
      _rec[ "naz" ] := _kto_naz

      lOk := update_rec_server_and_dbf( "konto", _rec, 1, "CONT" )

   ENDIF

   SELECT ( _t_area )

   RETURN lOk


STATIC FUNCTION append_sif_partn( id_partn, partn_data )

   LOCAL _t_area := Select()
   LOCAL _part_id := ""
   LOCAL _part_naz := ""
   LOCAL _append := .F.
   LOCAL oRow
   LOCAL lOk := .T.

   O_PARTN

   SELECT partn
   GO TOP
   SEEK PadR( id_partn, 6 )

   IF Found()
      SELECT ( _t_area )
      RETURN _append
   ENDIF

   partn_data:GoTo( 1 )

   DO WHILE !partn_data:Eof()

      oRow := partn_data:GetRow()

      IF PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) ), 6 ) == id_partn
         _part_id := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) )
         _part_naz := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) )

         _append := .T.

         EXIT

      ENDIF

      partn_data:Skip()

   ENDDO

   IF _append
      APPEND BLANK

      _rec := dbf_get_rec()
      _rec[ "id" ] := _part_id
      _rec[ "naz" ] := _part_naz
      _rec[ "ptt" ] := "?????"
      lOk := update_rec_server_and_dbf( "partn", _rec, 1, "CONT" )

   ENDIF

   SELECT ( _t_area )

   RETURN lOk




STATIC FUNCTION prazni_fin_priprema()

   LOCAL _ret := .T.

   SELECT fin_pripr
   IF RECCOUNT2() == 0
      RETURN _ret
   ENDIF

   IF Pitanje(, "Priprema FIN nije prazna ! Izbrisati postojeće stavke (D/N) ?", "D" ) == "D"
      my_dbf_zap()
      RETURN _ret
   ELSE
      _ret := .F.
      RETURN _ret
   ENDIF

   RETURN _ret



STATIC FUNCTION get_data( param, data_fin, konto_data, partner_data )

   LOCAL _server
   LOCAL _qry, _qry_2, _qry_3, _where
   LOCAL _dat_od := PARAM[ "datum_od" ]
   LOCAL _dat_do := PARAM[ "datum_do" ]
   LOCAL _dat_ps := PARAM[ "datum_ps" ]
   LOCAL _copy_sif := PARAM[ "copy_sif" ]
   LOCAL _db_params := my_server_params()
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _year_sez := Year( _dat_do )
   LOCAL _year_tek := Year( _dat_ps )

   _where := " WHERE "
   _where += _sql_date_parse( "sub.datdok", _dat_od, _dat_do )
   _where += " AND " + _sql_cond_parse( "sub.idfirma", gFirma )

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


   switch_to_database( _db_params, _tek_database, _year_sez )
   _server := pg_server()

   MsgO( "početno stanje - sql query u toku..." )

   data_fin := _sql_query( _server, _qry )

   IF _copy_sif == "D"
      _qry_2 := "SELECT * FROM fmk.konto ORDER BY id"
      konto_data := _sql_query( _server, _qry_2 )
      _qry_3 := "SELECT * FROM fmk.partn ORDER BY id"
      partner_data := _sql_query( _server, _qry_3 )
   ELSE
      konto_data := NIL
      partner_data := NIL
   ENDIF

   IF !is_var_objekat_tpquery( data_fin ) 
      data_fin := NIL
   ELSE
      IF data_fin:LastRec() == 0
         data_fin := NIL
      ENDIF
   ENDIF

   MsgC()

   switch_to_database( _db_params, _tek_database, _year_tek )
   _server := pg_server()

   RETURN






FUNCTION switch_to_database( db_params, database, year )

   IF year == NIL
      year := Year( Date() )
   ENDIF

   my_server_logout()

   IF year <> Year( Date() )
      db_params[ "database" ] := Left( database, Len( database ) - 4 ) + AllTrim( Str( year ) )
   ELSE
      db_params[ "database" ] := database
   ENDIF

   my_server_params( db_params )
   my_server_login( db_params )

   RETURN
