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


FUNCTION fin_pocetno_stanje_sql()

   LOCAL cFinKlasaDuguje, cFinKlasaPotrazuje, dDatumPocetnoStanje, dDatumOdStaraGodina, dDatumDoStaraGodina
   LOCAL _k_1, _k_2, _k_3, _k_4
   LOCAL cFinPrenosPocetnoStanjeDN
   LOCAL hParams := hb_Hash()
   LOCAL nSintetikaDuzina
   LOCAL _data, _partn_data, _konto_data

   _k_1 := fetch_metric( "fin_prenos_pocetno_stanje_k1", NIL, "9" )
   _k_2 := fetch_metric( "fin_prenos_pocetno_stanje_k2", NIL, "9" )
   _k_3 := fetch_metric( "fin_prenos_pocetno_stanje_k3", NIL, "99" )
   _k_4 := fetch_metric( "fin_prenos_pocetno_stanje_k4", NIL, "99" )

   open_tabele_za_pocetno_stanje()

   P_PKonto()

   cFinKlasaDuguje := fetch_metric( "fin_klasa_duguje", NIL, "2" )
   cFinKlasaPotrazuje := fetch_metric( "fin_klasa_potrazuje", NIL, "4" )
   nSintetikaDuzina := fetch_metric( "fin_prenos_pocetno_stanje_sint", NIL, 3 )
   cFinPrenosPocetnoStanjeDN := fetch_metric( "fin_prenos_pocetno_stanje_sif", NIL, "N" )

   dDatumOdStaraGodina := CToD( "01.01." + AllTrim( Str( Year( Date() ) -1 ) ) )
   dDatumDoStaraGodina := CToD( "31.12." + AllTrim( Str( Year( Date() ) -1 ) ) )
   dDatumPocetnoStanje := CToD( "01.01." + AllTrim( Str( Year( Date() ) ) ) )

   Box(, 9, 60 )

   @ m_x + 1, m_y + 2 SAY "Za datumski period od:" GET dDatumOdStaraGodina
   @ m_x + 1, Col() + 1 SAY "do:" GET dDatumDoStaraGodina

   @ m_x + 3, m_y + 2 SAY8 "Datum dokumenta početnog stanja:" GET dDatumPocetnoStanje

   @ m_x + 5, m_y + 2 SAY "Klasa dugovnog  konta:" GET cFinKlasaDuguje
   @ m_x + 6, m_y + 2 SAY8 "Klasa potražnog konta:" GET cFinKlasaPotrazuje

   @ m_x + 8, m_y + 2 SAY8 "Grupišem konta na broj mjesta ?" GET nSintetikaDuzina PICT "9"
   @ m_x + 9, m_y + 2 SAY8 "Kopiraj nepostojeće sifre (konto/partn) (D/N)?" GET cFinPrenosPocetnoStanjeDN VALID cFinPrenosPocetnoStanjeDN $ "DN" PICT "@!"

   READ

   ESC_BCR

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "fin_klasa_duguje", NIL, cFinKlasaDuguje )
   set_metric( "fin_klasa_potrazuje", NIL, cFinKlasaPotrazuje )
   set_metric( "fin_prenos_pocetno_stanje_sint", NIL, nSintetikaDuzina )
   set_metric( "fin_prenos_pocetno_stanje_sif", NIL, cFinPrenosPocetnoStanjeDN )
   set_metric( "fin_prenos_pocetno_stanje_k1", NIL, _k_1 )
   set_metric( "fin_prenos_pocetno_stanje_k2", NIL, _k_2 )
   set_metric( "fin_prenos_pocetno_stanje_k3", NIL, _k_3 )
   set_metric( "fin_prenos_pocetno_stanje_k4", NIL, _k_4 )

   hParams[ "klasa_duguje" ] := cFinKlasaDuguje
   hParams[ "klasa_potrazuje" ] := cFinKlasaPotrazuje
   hParams[ "k_1" ] := _k_1
   hParams[ "k_2" ] := _k_2
   hParams[ "k_3" ] := _k_3
   hParams[ "k_4" ] := _k_4
   hParams[ "datum_od" ] := dDatumOdStaraGodina
   hParams[ "datum_do" ] := dDatumDoStaraGodina
   hParams[ "datum_ps" ] := dDatumPocetnoStanje
   hParams[ "sintetika" ] := nSintetikaDuzina
   hParams[ "copy_sif" ] := cFinPrenosPocetnoStanjeDN

   get_data( hParams, @_data, @_konto_data, @_partn_data )

   IF _data == NIL
      MsgBeep( "Ne postoje traženi podaci... prekidam operaciju !" )
      RETURN
   ENDIF

   IF !fin_poc_stanje_insert_into_fin_pripr( _data, _konto_data, _partn_data, hParams )
      RETURN .F.
   ENDIF

   fin_set_broj_dokumenta()

   my_close_all_dbf()
   fin_gen_ptabele_stampa_nalozi( .T. )
   my_close_all_dbf()


   fin_azuriranje_naloga( .T. )

   MsgBeep( "Dokument formiran i automatski ažuriran!" )

   RETURN .T.



STATIC FUNCTION fin_poc_stanje_insert_into_fin_pripr( oDataset, oKontoDataset, oPartnerDataset, hParam )

   LOCAL _fin_vn := "00"
   LOCAL _fin_broj := fin_prazan_broj_naloga()
   LOCAL dDatumPocetnoStanje := hParam[ "datum_ps" ]
   LOCAL nSintetikaDuzina := hParam[ "sintetika" ]
   LOCAL _kl_dug := hParam[ "klasa_duguje" ]
   LOCAL _kl_pot := hParam[ "klasa_potrazuje" ]
   LOCAL cFinPrenosPocetnoStanjeDN := hParam[ "copy_sif" ]
   LOCAL _ret := .F.
   LOCAL _row, _duguje, _potrazuje, cIdKonto, cIdPartner
   LOCAL _dat_dok, _dat_val, _otv_st, cBrojVeze
   LOCAL hRecord, nSaldoZaBrDok
   LOCAL nRbr := 0
   LOCAL lOk := .T.
   LOCAL hParams, cBrojVezeDok, oRow2
   LOCAL cIdKontoPriprema, cIdPartnerPriprema

   open_tabele_za_pocetno_stanje()

   IF !prazni_fin_priprema()
      RETURN _ret
   ENDIF

   MsgO( "Formiram dokument početnog stanja u tabeli pripreme." )

   nSaldoZaBrDok := 0

   oDataset:GoTo( 1 )

   DO WHILE !oDataset:Eof()

      _row := oDataset:GetRow()

      cIdKonto := PadR( _row:FieldGet( _row:FieldPos( "idkonto" ) ), 7 )
      cIdPartner := PadR( hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "idpartner" ) ) ), 6 )
      cBrojVeze := PadR( hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "brdok" ) ) ), 20 )

      _dat_dok := _row:FieldGet( _row:FieldPos( "datdok" ) )
      _dat_val := fix_dat_var( _row:FieldGet( _row:FieldPos( "datval" ) ), .T. )

      _otv_st := _row:FieldGet( _row:FieldPos( "otvst" ) )

      SELECT pkonto
      GO TOP
      SEEK PadR( cIdKonto, nSintetikaDuzina )

      cTipPrenosaPS := "0"

      IF Found()
         cTipPrenosaPS := pkonto->tip
      ENDIF

      nSaldoZaBrDok := 0
      cBrojVezeDok := ""
      dDatumValute := NIL

      DO WHILE !oDataset:Eof() .AND. PadR( oDataset:FieldGet( oDataset:FieldPos( "idkonto" ) ), 7 ) == cIdKonto ;
        .AND. IIF( cTipPrenosaPS $ "1#2", PadR( hb_UTF8ToStr( oDataset:FieldGet( oDataset:FieldPos( "idpartner" ) ) ), 6 ) == cIdPartner, .T. ) ;
        .AND. IIF( cTipPrenosaPS $ "1", PadR( hb_UTF8ToStr( oDataset:FieldGet( oDataset:FieldPos( "brdok" ) ) ), 20 ) == cBrojVeze, .T. )

         oRow2 := oDataset:GetRow()

         nSaldoZaBrDok += oRow2:FieldGet( oRow2:FieldPos( "saldo" ) )

         IF cTipPrenosaPS == "1"

            cBrojVezeDok := PadR( hb_UTF8ToStr( oRow2:FieldGet( oRow2:FieldPos( "brdok" ) ) ), 20 )
            dDatumValute := fix_dat_var( oRow2:FieldGet( oRow2:FieldPos( "datval" ) ), .T. )
            IF dDatumValute == CToD( "" )
               dDatumValute := oRow2:FieldGet( oRow2:FieldPos( "datdok" ) )
            ENDIF

         ENDIF

         oDataset:Skip()

      ENDDO

      IF Round( nSaldoZaBrDok, 2 ) == 0
         LOOP
      ENDIF

      IF cTipPrenosaPS == "0"
         cIdPartner := Space( 6 )
      ENDIF

      SELECT fin_pripr
      APPEND BLANK

      hRecord := dbf_get_rec()

      hRecord[ "idfirma" ] := gFirma
      hRecord[ "idvn" ] := _fin_vn
      hRecord[ "brnal" ] := _fin_broj
      hRecord[ "datdok" ] := dDatumPocetnoStanje
      hRecord[ "rbr" ] := ++nRbr
      hRecord[ "idkonto" ] := cIdKonto
      hRecord[ "idpartner" ] := cIdPartner
      hRecord[ "opis" ] := "POCETNO STANJE"

      IF cTipPrenosaPS $ "0#2"
         hRecord[ "brdok" ] := "PS"
      ELSE
         hRecord[ "brdok" ] := cBrojVezeDok
         hRecord[ "datval" ] := fix_dat_var( dDatumValute, .T. )
      ENDIF

      IF cTipPrenosaPS == "1"

         IF Left( cIdKonto, 1 ) == _kl_pot
            hRecord[ "d_p" ] := "2"
            hRecord[ "iznosbhd" ] := -( nSaldoZaBrDok )
         ELSE
            hRecord[ "d_p" ] := "1"
            hRecord[ "iznosbhd" ] := nSaldoZaBrDok
         ENDIF

      ELSE

         IF Round( nSaldoZaBrDok, 2 ) > 0
            hRecord[ "d_p" ] := "1"
            hRecord[ "iznosbhd" ] := Abs( nSaldoZaBrDok )
         ELSE
            hRecord[ "d_p" ] := "2"
            hRecord[ "iznosbhd" ] := Abs( nSaldoZaBrDok )
         ENDIF

      ENDIF

      fin_konvert_valute( @hRecord, "D" )
      dbf_update_rec( hRecord )

   ENDDO

   MsgC()

   IF cFinPrenosPocetnoStanjeDN == "D"

      MsgO( "Provjeravam šifanike konto/partn ..." )

      SELECT fin_pripr
      SET ORDER TO TAG "1"
      GO TOP

      run_sql_query( "BEGIN" )
      IF !f18_lock_tables( { "partn", "konto" }, .T. )
         run_sql_query( "ROLLBACK" )
         MsgBeep( "Problem sa zaključavanjem tabela !#Prekidam operaciju." )
         RETURN _ret
      ENDIF

      DO WHILE !Eof()

         cIdKontoPriprema := field->idkonto
         cIdPartnerPriprema := field->idpartner

         IF !Empty( cIdKontoPriprema )

            lOk := append_sif_konto( cIdKontoPriprema, oKontoDataset )

            IF lOk
               lOk := append_sif_konto( PadR( Left( cIdKontoPriprema, 1 ), 7 ), oKontoDataset )
            ENDIF

            IF lOk
               lOk := append_sif_konto( PadR( Left( cIdKontoPriprema, 2 ), 7 ), oKontoDataset )
            ENDIF

            IF lOk
               lOk := append_sif_konto( PadR( Left( cIdKontoPriprema, 3 ), 7 ), oKontoDataset )
            ENDIF

         ENDIF

         IF !Empty( cIdPartnerPriprema ) .AND. lOk
            lOk := append_sif_partn( cIdPartnerPriprema, oPartnerDataset )
         ENDIF

         IF !lOk
            EXIT
         ENDIF

         SELECT fin_pripr
         SKIP

      ENDDO

      IF lOk
         hParams := hb_Hash()
         hParams[ "unlock" ] := { "partn", "konto" }
         run_sql_query( "COMMIT", hParams )
      ELSE
         run_sql_query( "ROLLBACK" )
         MsgBeep( "Problem sa dodavanjem novih šifri na server !" )
      ENDIF

      MsgC()

      GO TOP

   ENDIF

   IF nRbr > 0
      _ret := .T.
   ENDIF

   RETURN _ret


STATIC FUNCTION append_sif_konto( id_konto, oKontoDataset )

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

   oKontoDataset:GoTo( 1 )

   DO WHILE !oKontoDataset:Eof()

      oRow := oKontoDataset:GetRow()

      IF PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) ), 7 ) == id_konto
         _kto_id := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) )
         _kto_naz := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) )
         _append := .T.
         EXIT
      ENDIF

      oKontoDataset:Skip()

   ENDDO

   IF _append

      APPEND BLANK

      hRecord := dbf_get_rec()
      hRecord[ "id" ] := _kto_id
      hRecord[ "naz" ] := _kto_naz

      lOk := update_rec_server_and_dbf( "konto", hRecord, 1, "CONT" )

   ENDIF

   SELECT ( _t_area )

   RETURN lOk


STATIC FUNCTION append_sif_partn( id_partn, oPartnerDataset )

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

   oPartnerDataset:GoTo( 1 )

   DO WHILE !oPartnerDataset:Eof()

      oRow := oPartnerDataset:GetRow()

      IF PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) ), 6 ) == id_partn
         _part_id := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) )
         _part_naz := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) )

         _append := .T.

         EXIT

      ENDIF

      oPartnerDataset:Skip()

   ENDDO

   IF _append
      APPEND BLANK

      hRecord := dbf_get_rec()
      hRecord[ "id" ] := _part_id
      hRecord[ "naz" ] := _part_naz
      hRecord[ "ptt" ] := "?????"
      lOk := update_rec_server_and_dbf( "partn", hRecord, 1, "CONT" )

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



STATIC FUNCTION get_data( hParam, oFinQuery, oKontoDataset, oPartnerDataset )

   LOCAL cQuery, cQuery2, cQuery3, cWhere
   LOCAL dDatumOdStaraGodina := hParam[ "datum_od" ]
   LOCAL dDatumDoStaraGodina := hParam[ "datum_do" ]
   LOCAL dDatumPocetnoStanje := hParam[ "datum_ps" ]
   LOCAL cFinPrenosPocetnoStanjeDN := hParam[ "copy_sif" ]
   LOCAL _db_params := my_server_params()
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _year_sez := Year( dDatumDoStaraGodina )
   LOCAL _year_tek := Year( dDatumPocetnoStanje )

   cWhere := " WHERE "
   cWhere += _sql_date_parse( "sub.datdok", dDatumOdStaraGodina, dDatumDoStaraGodina )
   cWhere += " AND " + _sql_cond_parse( "sub.idfirma", gFirma )

   cQuery := " SELECT " + ;
      "sub.idkonto, " + ;
      "sub.idpartner, " + ;
      "sub.datdok, " + ;
      "sub.datval, " + ;
      "sub.brdok, " + ;
      "sub.otvst, " + ;
      "SUM( CASE WHEN sub.d_p = '1' THEN sub.iznosbhd ELSE -sub.iznosbhd END ) AS saldo " + ;
      " FROM " + F18_PSQL_SCHEMA_DOT + "fin_suban sub "

   cQuery += cWhere
   cQuery += " GROUP BY sub.idkonto, sub.idpartner, sub.brdok, sub.datdok, sub.datval, sub.otvst "
   cQuery += " ORDER BY sub.idkonto, sub.idpartner, sub.brdok, sub.datdok, sub.datval, sub.otvst "


   switch_to_database( _db_params, _tek_database, _year_sez )

   MsgO( "početno stanje - sql query u toku..." )

   oFinQuery := run_sql_query( cQuery )

   IF cFinPrenosPocetnoStanjeDN == "D"
      cQuery2 := "SELECT * FROM " + F18_PSQL_SCHEMA_DOT + "konto ORDER BY id"
      oKontoDataset := run_sql_query( cQuery2 )
      cQuery3 := "SELECT * FROM " + F18_PSQL_SCHEMA_DOT + "partn ORDER BY id"
      oPartnerDataset := run_sql_query( cQuery3 )
   ELSE
      oKontoDataset := NIL
      oPartnerDataset := NIL
   ENDIF

   IF !is_var_objekat_tpqquery( oFinQuery )
      oFinQuery := NIL
   ELSE
      IF oFinQuery:LastRec() == 0
         oFinQuery := NIL
      ENDIF
   ENDIF

   MsgC()

   switch_to_database( _db_params, _tek_database, _year_tek )

   RETURN .T.






FUNCTION switch_to_database( db_params, database, year )

   IF year == NIL
      year := Year( Date() )
   ENDIF

   my_server_logout()

   IF year <> Year( Date() )
      db_params[ "database" ] := Left( database, Len( database ) -4 ) + AllTrim( Str( year ) )
   ELSE
      db_params[ "database" ] := database
   ENDIF

   my_server_params( db_params )
   my_server_login( db_params )

   RETURN .T.

STATIC FUNCTION open_tabele_za_pocetno_stanje()

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

   RETURN .T.
