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
   LOCAL cKontaUslov := PadR( "", 100 )

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

   @ m_x + 5, m_y + 2 SAY8 "Klasa duguje (kupci)         :" GET cFinKlasaDuguje
   @ m_x + 6, m_y + 2 SAY8 "Klasa potražuje (dobavljači) :" GET cFinKlasaPotrazuje

   @ m_x + 7, m_y + 2 SAY8 "Uslov za konta :" GET cKontaUslov PICT "@S30"

   @ m_x + 8, m_y + 2 SAY8 "Grupišem konta na broj mjesta ?" GET nSintetikaDuzina PICT "9"
   // @ m_x + 9, m_y + 2 SAY8 "Kopiraj nepostojeće sifre (konto/partn) (D/N)?" GET cFinPrenosPocetnoStanjeDN VALID cFinPrenosPocetnoStanjeDN $ "DN" PICT "@!"

   READ

   ESC_BCR

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   IF !in_tekuca_godina()
      MsgBeep( "Opcija se pokreće u novoj godini da bi se napravilo početno stanje predhodne godine" )
      IF Pitanje( "Prekinuti izvršenje prenosa D/N", "D" ) == "D"
         RETURN .F.
      ENDIF
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
   hParams[ "konto_uslov" ] := cKontaUslov


   fin_pocetno_stanje_get_data( hParams, @_data, @_konto_data, @_partn_data )

   IF _data == NIL
      MsgBeep( "Ne postoje traženi podaci... prekidam operaciju !" )
      RETURN .F.
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

   LOCAL cIdVn := "00"
   LOCAL cBrNal := fin_prazan_broj_naloga()
   LOCAL dDatumPocetnoStanje := hParam[ "datum_ps" ]
   LOCAL nSintetikaDuzina := hParam[ "sintetika" ]
   LOCAL cKontoKlasaDuguje := hParam[ "klasa_duguje" ]
   LOCAL cKontoKlasaPotrazuje := hParam[ "klasa_potrazuje" ]
   LOCAL cFinPrenosPocetnoStanjeDN := hParam[ "copy_sif" ]
   LOCAL _ret := .F.
   LOCAL oRow, _duguje, _potrazuje, cIdKonto, cIdPartner
   LOCAL dDatDok, dDatVal, cOtvSt, cBrojVeze
   LOCAL hRecord, nSaldoBrDokOtvSt
   LOCAL nRbr := 0
   LOCAL lOk := .T.
   LOCAL hParams, cBrojVezeDok
   LOCAL cIdKontoPriprema, cIdPartnerPriprema
   LOCAL cTipPrenosaPS, cOpis
   LOCAL bEvalPartnerOrOtvorenaStavka, lPrvaStavka, nCnt

   open_tabele_za_pocetno_stanje()

   IF !prazni_fin_priprema()
      RETURN _ret
   ENDIF



   Box( "#Formiranje dokumenta početnog stanja ...", 2, 50 )

   // cTipPrenosaPS - 0 saldo konta, 1 - otvorene stavke, 2 - saldo partnera

   oDataset:GoTo( 1 )
   bEvalPartnerOrOtvorenaStavka :=  {|| !oDataset:Eof() .AND. PadR( oRow:FieldGet( oRow:FieldPos( "idkonto" ) ), 7 ) == cIdKonto ;
      .AND. iif( cTipPrenosaPS $ "12", PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "idpartner" ) ) ), 6 ) == cIdPartner, .T. ) ;
      .AND. iif( cTipPrenosaPS == "1", .F., .T. ) ;
      }

   nCnt := 0


   DO WHILE !oDataset:Eof()

      @ m_x + 1, m_y + 2 SAY Str( nCnt++, 7 )
      oRow := oDataSet:GetRow()
      cIdKonto := PadR( oRow:FieldGet( oRow:FieldPos( "idkonto" ) ), 7 )
      cIdPartner := PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "idpartner" ) ) ), 6 )
      cBrojVeze := PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "brdok" ) ) ), 20 )
      cOtvSt := oRow:FieldGet( oRow:FieldPos( "otvst" ) )

      SELECT pkonto
      GO TOP
      SEEK PadR( cIdKonto, nSintetikaDuzina )
      cTipPrenosaPS := "0"
      IF Found()
         cTipPrenosaPS := pkonto->tip  // 1-otvorene stavke, 2-saldo partnera
      ENDIF

      nSaldoBrDokOtvSt := 0

      lPrvaStavka := .T.
      DO WHILE lPrvaStavka .OR. Eval( bEvalPartnerOrOtvorenaStavka )

         lPrvaStavka := .F.
         dDatDok := oRow:FieldGet( oRow:FieldPos( "datdok" ) )

         dDatVal := fix_dat_var( oRow:FieldGet( oRow:FieldPos( "datval" ) ), .T. )
         IF dDatVal == CToD( "" )
            dDatVal := oRow:FieldGet( oRow:FieldPos( "datdok" ) )
         ENDIF

         IF cTipPrenosaPS == "1" // po otvorenim stavkama
            cOpis := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "opis" ) ) )
         ENDIF

         nSaldoBrDokOtvSt += oRow:FieldGet( oRow:FieldPos( "saldo" ) )
         oDataset:Skip()
         oRow := oDataset:GetRow() // nakon skip refresh oRow podaci

      ENDDO

      IF cTipPrenosaPS == "1" .AND. cOtvSt == "9" // stavka zatvorena
         nSaldoBrDokOtvSt := 0
      ENDIF

      IF Round( nSaldoBrDokOtvSt, 2 ) == 0
         LOOP
      ENDIF

      IF cTipPrenosaPS == "0"
         cIdPartner := Space( 6 )
      ENDIF

      SELECT fin_pripr
      APPEND BLANK

      hRecord := dbf_get_rec()
      hRecord[ "idfirma" ] := self_organizacija_id()
      hRecord[ "idvn" ] := cIdVn
      hRecord[ "brnal" ] := cBrNal
      hRecord[ "datdok" ] := dDatumPocetnoStanje
      hRecord[ "rbr" ] := ++nRbr
      hRecord[ "idkonto" ] := cIdKonto
      hRecord[ "idpartner" ] := cIdPartner
      hRecord[ "opis" ] := "POCETNO STANJE"

      IF cTipPrenosaPS $ "0#2"
         hRecord[ "brdok" ] := "PS" // saldo partnera ili saldo konta
      ELSE
         hRecord[ "brdok" ] := cBrojVeze
         hRecord[ "datval" ] := fix_dat_var( dDatVal, .T. )
      ENDIF

      IF cTipPrenosaPS == "1"  // po ptvorenim stavkama
         IF Left( cIdKonto, 1 ) == cKontoKlasaPotrazuje
            hRecord[ "d_p" ] := "2"  // dobavljaci
            hRecord[ "iznosbhd" ] := -( nSaldoBrDokOtvSt )
         ELSE
            hRecord[ "d_p" ] := "1" // kupci
            hRecord[ "iznosbhd" ] := nSaldoBrDokOtvSt
         ENDIF
         hRecord[ "opis" ] := cOpis

      ELSE // saldo partnera
         IF Round( nSaldoBrDokOtvSt, 2 ) > 0
            hRecord[ "d_p" ] := "1"
            hRecord[ "iznosbhd" ] := Abs( nSaldoBrDokOtvSt )
         ELSE
            hRecord[ "d_p" ] := "2"
            hRecord[ "iznosbhd" ] := Abs( nSaldoBrDokOtvSt )
         ENDIF
      ENDIF

      fin_konvert_valute( @hRecord, "D" )
      dbf_update_rec( hRecord )

   ENDDO

   BoxC()
   // MsgC()

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


STATIC FUNCTION append_sif_konto( cIdKonto, oKontoDataset )

   LOCAL nTableArea := Select()
   LOCAL cIdKontoTekuci := ""
   LOCAL cKontoNazTekuci := ""
   LOCAL lAppend := .F.
   LOCAL oRow
   LOCAL lOk := .T.
   LOCAL hRecord

   select_o_konto()
   SELECT konto
   GO TOP
   SEEK PadR( cIdKonto, 7 )

   IF Found()
      SELECT ( nTableArea )
      RETURN lAppend
   ENDIF

   oKontoDataset:GoTo( 1 )

   DO WHILE !oKontoDataset:Eof()

      oRow := oKontoDataset:GetRow()
      IF PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) ), 7 ) == cIdKonto
         cIdKontoTekuci := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) )
         cKontoNazTekuci := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) )
         lAppend := .T.
         EXIT
      ENDIF
      oKontoDataset:Skip()
   ENDDO

   IF lAppend

      APPEND BLANK
      hRecord := dbf_get_rec()
      hRecord[ "id" ] := cIdKontoTekuci
      hRecord[ "naz" ] := cKontoNazTekuci
      lOk := update_rec_server_and_dbf( "konto", hRecord, 1, "CONT" )

   ENDIF
   SELECT ( nTableArea )

   RETURN lOk


STATIC FUNCTION append_sif_partn( cIdPartner, oPartnerDataset )

   LOCAL nTableArea := Select()
   LOCAL cIdPartnerTekuci := ""
   LOCAL cPartnerNazTekuci := ""
   LOCAL lAppend := .F.
   LOCAL oRow
   LOCAL lOk := .T.
   LOCAL hRecord

   select_o_partner()
   SELECT partn
   GO TOP
   SEEK PadR( cIdPartner, 6 )

   IF Found()
      SELECT ( nTableArea )
      RETURN lAppend
   ENDIF

   oPartnerDataset:GoTo( 1 )

   DO WHILE !oPartnerDataset:Eof()

      oRow := oPartnerDataset:GetRow()
      IF PadR( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) ), 6 ) == cIdPartner
         cIdPartnerTekuci := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "id" ) ) )
         cPartnerNazTekuci := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) )
         lAppend := .T.
         EXIT
      ENDIF
      oPartnerDataset:Skip()

   ENDDO

   IF lAppend
      APPEND BLANK
      hRecord := dbf_get_rec()
      hRecord[ "id" ] := cIdPartnerTekuci
      hRecord[ "naz" ] := cPartnerNazTekuci
      hRecord[ "ptt" ] := "?????"
      lOk := update_rec_server_and_dbf( "partn", hRecord, 1, "CONT" )
   ENDIF

   SELECT ( nTableArea )

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



STATIC FUNCTION fin_pocetno_stanje_get_data( hParam, oFinQuery, oKontoDataset, oPartnerDataset )

   LOCAL cQuery, cQuery2, cQuery3, cWhere
   LOCAL dDatumOdStaraGodina := hParam[ "datum_od" ]
   LOCAL dDatumDoStaraGodina := hParam[ "datum_do" ]
   LOCAL dDatumPocetnoStanje := hParam[ "datum_ps" ]
   LOCAL cFinPrenosPocetnoStanjeDN := hParam[ "copy_sif" ]
   LOCAL hServerParams := my_server_params()
   LOCAL cDatabase := my_server_params()[ "database" ]
   LOCAL nYearSezona := Year( dDatumDoStaraGodina )
   LOCAL nYearTekucaGodina := Year( dDatumPocetnoStanje )
   LOCAL cKtoUslov

/*
   cQuery := " SELECT " + ;
      "idkonto,idpartner,datdok,COALESCE(datval,('1900-01-01'::date)) AS datval,brdok,COALESCE(opis,''::text) AS opis,otvst, " + ;
      "SUM( CASE WHEN sub.d_p = '1' THEN sub.iznosbhd ELSE -sub.iznosbhd END ) AS saldo " + ;
      " FROM " + F18_PSQL_SCHEMA_DOT + "fin_suban sub "
*/

   cQuery := " SELECT " + ;
      "idkonto,idpartner,datdok,datval,brdok,COALESCE(opis,''::text) AS opis,otvst, " + ;
      "SUM( CASE WHEN sub.d_p = '1' THEN sub.iznosbhd ELSE -sub.iznosbhd END ) AS saldo " + ;
      " FROM " + F18_PSQL_SCHEMA_DOT + "fin_suban sub "

   cWhere := " WHERE "
   cWhere += _sql_date_parse( "sub.datdok", dDatumOdStaraGodina, dDatumDoStaraGodina )
   cWhere += " AND " + _sql_cond_parse( "sub.idfirma", self_organizacija_id() )

   IF !Empty( hParam[ "konto_uslov" ] )
      AltD()
      IF Left( hParam[ "konto_uslov" ], 1 ) == "!"   // !211;
         cKtoUslov :=  SubStr( hParam[ "konto_uslov" ], 2 )
         cWhere += " AND NOT " + _sql_cond_parse( "sub.idkonto", cKtoUslov )
      ELSE
         cWhere += " AND " + _sql_cond_parse( "sub.idkonto", hParam[ "konto_uslov" ] )
      ENDIF
   ENDIF

   cQuery += cWhere

   cQuery += " GROUP BY idkonto,idpartner,brdok,datdok,datval,otvst,opis "
   cQuery += " ORDER BY idkonto,idpartner,brdok,datdok,datval,otvst "

   switch_to_database( hServerParams, cDatabase, nYearSezona )

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

   switch_to_database( hServerParams, cDatabase, nYearTekucaGodina )

   RETURN .T.





FUNCTION switch_to_database( hDbParams, cDatabase, nYear )

   IF nYear == NIL
      nYear := Year( Date() )
   ENDIF

   my_server_logout()

   IF nYear <> Year( Date() )
      hDbParams[ "database" ] := Left( cDatabase, Len( cDatabase ) -4 ) + AllTrim( Str( nYear ) )
   ELSE
      hDbParams[ "database" ] := cDatabase
   ENDIF
   my_server_params( hDbParams )
   my_server_login( hDbParams )
   set_sql_search_path()

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
