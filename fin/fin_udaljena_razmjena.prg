#include "f18.ch"


STATIC s_cImportDbfPath
STATIC s_cExportDbfPath
STATIC s_cImportZipIme
STATIC s_cExportZipIme


FUNCTION fin_udaljena_razmjena_podataka()

   LOCAL aOpc := {}
   LOCAL aOpcExe := {}
   LOCAL nIzbor := 1

   s_cImportDbfPath := my_home() + "import_dbf" + SLASH
   s_cExportDbfPath := my_home() + "export_dbf" + SLASH
   s_cImportZipIme := "fin_exp.zip"
   s_cExportZipIme := "fin_exp.zip"

   // kreiraj ove direktorije odmah
   direktorij_kreiraj_ako_ne_postoji( s_cExportDbfPath )

   AAdd( aOpc, "1. => export podataka               " )
   AAdd( aOpcExe, {|| fin_export() } )
   AAdd( aOpc, "2. <= import podataka    " )
   AAdd( aOpcExe, {|| fin_import() } )

   f18_menu( "razmjena", .F., nIzbor, aOpc, aOpcExe )

   my_close_all_dbf()

   RETURN .T.



STATIC FUNCTION fin_export()

   LOCAL _vars := hb_Hash()
   LOCAL _exported_rec
   LOCAL _error
   LOCAL _a_data := {}

   // uslovi exporta
   IF !_vars_export( @_vars )
      RETURN .F.
   ENDIF

   // pobrisi u folderu tmp fajlove ako postoje
   delete_exp_files( s_cExportDbfPath, "fin" )

   _exported_rec := fin_export_impl( _vars, @_a_data )

   my_close_all_dbf()
   IF _exported_rec > 0

      _error := udaljenja_razmjena_compress_files( "fin", s_cExportDbfPath )

      IF _error == 0
         // pobrisi fajlove razmjene
         delete_exp_files( s_cExportDbfPath, "fin" )

         // otvori folder sa exportovanim podacima
         open_folder( s_cExportDbfPath )

      ENDIF

   ENDIF

   DirChange( my_home() )    // vrati se na glavni direktorij

   IF ( _exported_rec > 0 )
      MsgBeep( "Exportovao " + AllTrim( Str( _exported_rec ) ) + " dokumenta." )
      print_imp_exp_report( _a_data )
   ENDIF

   my_close_all_dbf()

   RETURN .T.



STATIC FUNCTION fin_import()

   LOCAL nImportovanihZapisa
   LOCAL _vars := hb_Hash()
   LOCAL _imp_file
   LOCAL _a_data := {}
   LOCAL cFinImportPath := fetch_metric( "fin_import_path", my_user(), PadR( "", 300 ) )
   LOCAL GetList := {}

   Box(, 1, 70 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "import path:" GET cFinImportPath PICT "@S50"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   s_cImportDbfPath := AllTrim( cFinImportPath )
   set_metric( "fin_import_path", my_user(), cFinImportPath )

   // import fajl iz liste
   _imp_file := get_import_file( "fin", s_cImportDbfPath )

   IF _imp_file == NIL .OR. Empty( _imp_file )
      MsgBeep( "Nema odabranog import fajla !?" )
      RETURN .F.
   ENDIF


   IF !_vars_import( @_vars )
      RETURN .F.
   ENDIF

   IF !import_file_exist( _imp_file )
      MsgBeep( "import fajl ne postoji !? prekidam operaciju" )
      RETURN .F.
   ENDIF

   // dekompresovanje podataka
   IF razmjena_decompress_files( _imp_file, s_cImportDbfPath, s_cImportZipIme ) <> 0
      // ako je bilo greske
      RETURN .F.
   ENDIF

#ifdef __PLATFORM__UNIX
   set_file_access( s_cImportDbfPath )
#endif


   nImportovanihZapisa := fin_import_impl( _vars, @_a_data )

   my_close_all_dbf()

   // brisi fajlove importa
   delete_exp_files( s_cImportDbfPath, "fin" )

   IF ( nImportovanihZapisa > 0 )
      IF Pitanje(, "Pobrisati obrađeni zip fajl razmjene ?", "D" ) == "D"
         delete_zip_files( _imp_file )
      ENDIF
      MsgBeep( "Importovao " + AllTrim( Str( nImportovanihZapisa ) ) + " dokumenta." )
      print_imp_exp_report( _a_data )

   ENDIF

   // vrati se na home direktorij nakon svega
   DirChange( my_home() )

   RETURN .T.



STATIC FUNCTION _vars_export( hVars )

   LOCAL dDatOd := fetch_metric( "fin_export_datum_od", my_user(), Date() - 30 )
   LOCAL dDatDo := fetch_metric( "fin_export_datum_do", my_user(), Date() )
   LOCAL _konta := fetch_metric( "fin_export_lista_konta", my_user(), PadR( "1320;", 200 ) )
   LOCAL _vrste_dok := fetch_metric( "fin_export_vrste_dokumenata", my_user(), PadR( "10;11;", 200 ) )
   LOCAL _exp_sif := fetch_metric( "fin_export_sifrarnik", my_user(), "D" )
   LOCAL _exp_path := fetch_metric( "fin_export_path", my_user(), PadR( "", 300 ) )
   LOCAL nX := 1
   LOCAL bKeyHanlder := { | oGet| info_bar( "get", "ulovio sam: " + oGet:cBuffer) }
   LOCAL bReader
   LOCAL GetList := {}

   IF Empty( AllTrim( _exp_path ) )
      _exp_path := PadR( s_cExportDbfPath, 300 )
   ENDIF

   Box(, 15, 70 )

   @ box_x_koord() + nX, box_y_koord() + 2 SAY "*** Uslovi exporta dokumenata"
   ++nX
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY "Vrste dokumenata:" GET _vrste_dok PICT "@S40"
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY "Datumski period od" GET dDatOd
   @ box_x_koord() + nX, Col() + 1 SAY "do" GET dDatDo
   ++nX
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Uzeti u obzir sljedeća konta:" GET _konta PICT "@S30"
   ++nX
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Export šifarnika (D/N) ?" GET _exp_sif PICT "@!" VALID _exp_sif $ "DN"

   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Lokacija exporta:" GET _exp_path PICT "@S50"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "fin_export_datum_od", my_user(), dDatOd )
   set_metric( "fin_export_datum_do", my_user(), dDatDo )
   set_metric( "fin_export_lista_konta", my_user(), _konta )
   set_metric( "fin_export_vrste_dokumenata", my_user(), _vrste_dok )
   set_metric( "fin_export_sifrarnik", my_user(), _exp_sif )
   set_metric( "fin_export_path", my_user(), _exp_path )

   s_cExportDbfPath := AllTrim( _exp_path )

   hVars[ "datum_od" ] := dDatOd
   hVars[ "datum_do" ] := dDatDo
   hVars[ "konta" ] := _konta
   hVars[ "vrste_dok" ] := _vrste_dok
   hVars[ "export_sif" ] := _exp_sif

   RETURN .T.



// -------------------------------------------
// uslovi importa dokumenta
// -------------------------------------------
STATIC FUNCTION _vars_import( hVars )

   LOCAL _ret := .F.
   LOCAL dDatOd := fetch_metric( "fin_import_datum_od", my_user(), CToD( "" ) )
   LOCAL dDatDo := fetch_metric( "fin_import_datum_do", my_user(), CToD( "" ) )
   LOCAL _konta := fetch_metric( "fin_import_lista_konta", my_user(), PadR( "", 200 ) )
   LOCAL _vrste_dok := fetch_metric( "fin_import_vrste_dokumenata", my_user(), PadR( "", 200 ) )
   LOCAL _zamjeniti_dok := fetch_metric( "fin_import_zamjeniti_dokumente", my_user(), "N" )
   LOCAL _zamjeniti_sif := fetch_metric( "fin_import_zamjeniti_sifre", my_user(), "N" )
   LOCAL _iz_fmk := fetch_metric( "fin_import_iz_fmk", my_user(), "N" )
   LOCAL cFinImportPath := fetch_metric( "fin_import_path", my_user(), PadR( "", 300 ) )
   LOCAL nX := 1
   LOCAL GetList := {}

   IF Empty( AllTrim( cFinImportPath ) )
      cFinImportPath := PadR( s_cImportDbfPath, 300 )
   ENDIF


   Box(, 15, 70 )

   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "*** Uslovi importa dokumenata"

   ++nX
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Vrste dokumenata (prazno-sve):" GET _vrste_dok PICT "@S30"
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Datumski period od" GET dDatOd
   @ box_x_koord() + nX, Col() + 1 SAY "do" GET dDatDo
   ++nX
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Uzeti u obzir sljedeća konta:" GET _konta PICT "@S30"
   ++nX
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Zamijeniti postojeće dokumente novim (D/N):" GET _zamjeniti_dok PICT "@!" VALID _zamjeniti_dok $ "DN"
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY8 "Zamijeniti postojeće šifre novim (D/N):" GET _zamjeniti_sif PICT "@!" VALID _zamjeniti_sif $ "DN"

//   ++nX
//   ++nX
//   @ box_x_koord() + nX, box_y_koord() + 2 SAY "Import fajl dolazi iz FMK (D/N) ?" GET _iz_fmk PICT "@!" VALID _iz_fmk $ "DN"

   ++nX
   ++nX
   @ box_x_koord() + nX, box_y_koord() + 2 SAY "Lokacija importa:" GET cFinImportPath PICT "@S50"


   READ

   BoxC()

   IF LastKey() <> K_ESC

      _ret := .T.
      set_metric( "fin_import_datum_od", my_user(), dDatOd )
      set_metric( "fin_import_datum_do", my_user(), dDatDo )
      set_metric( "fin_import_lista_konta", my_user(), _konta )
      set_metric( "fin_import_vrste_dokumenata", my_user(), _vrste_dok )
      set_metric( "fin_import_zamjeniti_dokumente", my_user(), _zamjeniti_dok )
      set_metric( "fin_import_zamjeniti_sifre", my_user(), _zamjeniti_sif )
      set_metric( "fin_import_iz_fmk", my_user(), _iz_fmk )
      set_metric( "fin_import_path", my_user(), cFinImportPath )

      // set static var
      s_cImportDbfPath := AllTrim( cFinImportPath )

      hVars[ "datum_od" ] := dDatOd
      hVars[ "datum_do" ] := dDatDo
      hVars[ "konta" ] := _konta
      hVars[ "vrste_dok" ] := _vrste_dok
      hVars[ "zamjeniti_dokumente" ] := _zamjeniti_dok
      hVars[ "zamjeniti_sifre" ] := _zamjeniti_sif
      hVars[ "import_iz_fmk" ] := _iz_fmk

   ENDIF

   RETURN _ret



STATIC FUNCTION fin_export_impl( hVars, a_details )

   LOCAL cIdFirma, cIdVN, cBrNal
   LOCAL hRec
   LOCAL nCnt := 0
   LOCAL dDatOd, dDatDo, _konta, _vrste_dok, cExportSifDN
   LOCAL _usl_konto, cIdKonto
   LOCAL cIdPartner
   LOCAL hRecExpDetalji

   // uslovi za export ce biti...
   dDatOd := hVars[ "datum_od" ]
   dDatDo := hVars[ "datum_do" ]
   _konta := AllTrim( hVars[ "konta" ] )
   _vrste_dok := AllTrim( hVars[ "vrste_dok" ] )
   cExportSifDN := AllTrim( hVars[ "export_sif" ] )

   fin_export_cre_e_dbfs( s_cExportDbfPath )
   fin_export_otvori_e_dbfs( s_cExportDbfPath )


   IF Select( "E_NALOG" ) == 0
      MsgBeep( "ERR e_nalog.dbf nije uspjesno kreiran !?##STOP!" )
      RETURN -1
   ENDIF

   // fin_exp_o_promet_tabele()

   Box(, 2, 65 )

   @ box_x_koord() + 1, box_y_koord() + 2 SAY "... export fin dokumenata u toku"

   find_nalog_za_period( self_organizacija_id(), NIL, dDatOd, dDatDo )

   DO WHILE !Eof()

      cIdFirma := field->idfirma
      cIdVN := field->idvn
      cBrNal := field->brnal

      IF !Empty( _vrste_dok )
         IF !( field->idvn $ _vrste_dok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF dDatOd <> CToD( "" )
         IF ( field->datnal < dDatOd )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF dDatDo <> CToD( "" )
         IF ( field->datnal > dDatDo )
            SKIP
            LOOP
         ENDIF
      ENDIF

      hRec := dbf_get_rec()

      hRecExpDetalji := hb_Hash()
      hRecExpDetalji[ "dokument" ] := hRec[ "idfirma" ] + "-" + hRec[ "idvn" ] + "-" + hRec[ "brnal" ]
      hRecExpDetalji[ "idpartner" ] := ""
      hRecExpDetalji[ "idkonto" ] := ""
      hRecExpDetalji[ "partner" ] := ""
      hRecExpDetalji[ "iznos" ] := 0
      hRecExpDetalji[ "datum" ] := hRec[ "datnal" ]
      hRecExpDetalji[ "tip" ] := "export"

      export_import_add_to_details( @a_details, hRecExpDetalji )

      SELECT e_nalog
      APPEND BLANK
      dbf_update_rec( hRec )

      ++nCnt
      @ box_x_koord() + 2, box_y_koord() + 2 SAY PadR(  PadL( AllTrim( Str( nCnt ) ), 6 ) + ". " + "dokument: " + cIdFirma + "-" + cIdVN + "-" + AllTrim( cBrNal ), 50 )

      find_suban_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idvn == cIdVN .AND. field->brnal == cBrNal

         cIdKonto := suban->idkonto
         cIdPartner := suban->idpartner

         hRec := dbf_get_rec()
         SELECT e_suban
         APPEND BLANK
         dbf_update_rec( hRec )

         IF select_o_konto( cIdKonto ) .AND. cExportSifDN == "D"
            hRec := dbf_get_rec()
            SELECT e_konto
            SET ORDER TO TAG "ID"
            SEEK cIdKonto // e_konto
            IF !Found()
               APPEND BLANK
               dbf_update_rec( hRec )
               // napuni i sifk, sifv parametre
               razmjena_fill_sifk_sifv( "KONTO", cIdKonto )
            ENDIF
         ENDIF

         IF select_o_partner( cIdPartner ) .AND. cExportSifDN == "D"
            hRec := dbf_get_rec()
            SELECT e_partn
            SET ORDER TO TAG "ID"
            SEEK cIdPartner // e_partn
            IF !Found()
               APPEND BLANK
               dbf_update_rec( hRec )
               // napuni i sifk, sifv parametre
               razmjena_fill_sifk_sifv( "PARTN", cIdPartner )
            ENDIF
         ENDIF

         SELECT suban
         SKIP

      ENDDO


      find_sint_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idvn == cIdVN .AND. field->brnal == cBrNal

         hRec := dbf_get_rec() // sint
         SELECT e_sint
         APPEND BLANK
         dbf_update_rec( hRec )

         SELECT sint
         SKIP

      ENDDO


      find_anal_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idvn == cIdVN .AND. field->brnal == cBrNal

         hRec := dbf_get_rec() // anal

         SELECT e_anal
         APPEND BLANK
         dbf_update_rec( hRec )

         SELECT anal
         SKIP

      ENDDO


      SELECT nalog
      SKIP

   ENDDO

   BoxC()

   RETURN nCnt



STATIC FUNCTION fin_import_impl( hVars, a_details )

   LOCAL _ret := 0
   LOCAL cIdFirma, cIdVN, cBrNal
   LOCAL hRec
   LOCAL nCnt := 0
   LOCAL dDatOd, dDatDo, _konta, _vrste_dok, _zamjeniti_dok, _zamjeniti_sif, _iz_fmk
   LOCAL _roba_id, _partn_id, _konto_id
   LOCAL _sif_exist
   LOCAL lFmkImport := .F.
   LOCAL _redni_broj := 0
   LOCAL _total_suban := 0
   LOCAL _total_anal := 0
   LOCAL _total_sint := 0
   LOCAL _total_nalog := 0
   LOCAL _gl_brojac := 0
   LOCAL dDatNal
   LOCAL hRecExpDetalji
   LOCAL lOk := .T.
   LOCAL hParams := hb_Hash()

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_nalog", "fin_anal", "fin_sint", "fin_suban" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN nCnt
   ENDIF

   dDatOd := hVars[ "datum_od" ]
   dDatDo := hVars[ "datum_do" ]
   _konta := hVars[ "konta" ]
   _vrste_dok := hVars[ "vrste_dok" ]
   _zamjeniti_dok := hVars[ "zamjeniti_dokumente" ]
   _zamjeniti_sif := hVars[ "zamjeniti_sifre" ]
   _iz_fmk := hVars[ "import_iz_fmk" ]

   IF _iz_fmk == "D"
      lFmkImport := .T.
   ENDIF

   fin_export_otvori_e_dbfs( s_cImportDbfPath, lFmkImport )

   fin_exp_o_promet_tabele()

   SELECT e_nalog
   _total_nalog := RECCOUNT2()

   SELECT e_suban
   _total_suban := RECCOUNT2()

   SELECT e_nalog
   SET ORDER TO TAG "1"
   GO TOP

   Box(, 3, 70 )

   @ box_x_koord() + 1, box_y_koord() + 2 SAY PadR( "... import fin dokumenata u toku ", 69 ) COLOR f18_color_i()
   @ box_x_koord() + 2, box_y_koord() + 2 SAY "broj zapisa nalog/" + AllTrim( Str( _total_nalog ) ) + ", suban/" + AllTrim( Str( _total_suban ) )

   DO WHILE !Eof()

      cIdFirma := field->idfirma
      cIdVN := field->idvn
      cBrNal := field->brnal
      dDatNal := field->datnal

      IF dDatOd <> CToD( "" )
         IF field->datnal < dDatOd
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF dDatDo <> CToD( "" )
         IF field->datnal > dDatDo
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF !Empty( _vrste_dok )
         IF !( field->idvn $ _vrste_dok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF fin_dokument_postoji( cIdFirma, cIdVN, cBrNal )

         hRecExpDetalji := hb_Hash()
         hRecExpDetalji[ "dokument" ] := cIdFirma + "-" + cIdVN + "-" + cBrNal
         hRecExpDetalji[ "datum" ] := dDatNal
         hRecExpDetalji[ "idpartner" ] := ""
         hRecExpDetalji[ "partner" ] := ""
         hRecExpDetalji[ "idkonto" ] := ""
         hRecExpDetalji[ "iznos" ] := 0

         IF _zamjeniti_dok == "D"

            hRecExpDetalji[ "tip" ] := "delete"
            export_import_add_to_details( @a_details, hRecExpDetalji )

            lOk := brisi_dokument_iz_kumulativa( cIdFirma, cIdVN, cBrNal )

         ELSE

            hRecExpDetalji[ "tip" ] := "x"
            export_import_add_to_details( @a_details, hRecExpDetalji )

            SELECT e_nalog
            SKIP
            LOOP

         ENDIF

      ENDIF

      IF !lOk
         EXIT
      ENDIF

      SELECT e_nalog
      hRec := dbf_get_rec()

      hRecExpDetalji := hb_Hash()
      hRecExpDetalji[ "dokument" ] := hRec[ "idfirma" ] + "-" + hRec[ "idvn" ] + "-" + hRec[ "brnal" ]
      hRecExpDetalji[ "datum" ] := hRec[ "datnal" ]
      hRecExpDetalji[ "idpartner" ] := ""
      hRecExpDetalji[ "partner" ] := ""
      hRecExpDetalji[ "idkonto" ] := ""
      hRecExpDetalji[ "iznos" ] := 0
      hRecExpDetalji[ "tip" ] := "import"

      export_import_add_to_details( @a_details, hRecExpDetalji )

      SELECT nalog
      APPEND BLANK
      lOk := update_rec_server_and_dbf( "fin_nalog", hRec, 1, "CONT" )

      IF !lOk
         EXIT
      ENDIF

      ++nCnt
      @ box_x_koord() + 3, box_y_koord() + 2 SAY PadR( PadL( AllTrim( Str( nCnt ) ), 5 ) + ". dokument: " + cIdFirma + "-" + cIdVN + "-" + cBrNal, 60 )

      SELECT e_suban
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cIdFirma + cIdVN + cBrNal

      _redni_broj := 0

      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idvn == cIdVN .AND. field->brnal == cBrNal

         hRec := dbf_get_rec()

         hRec[ "rbr" ] :=  ++_redni_broj

         _gl_brojac += _redni_broj

         @ box_x_koord() + 3, box_y_koord() + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + Str( hRec[ "rbr" ], 5 )

         SELECT suban
         APPEND BLANK
         lOk := update_rec_server_and_dbf( "fin_suban", hRec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT e_suban
         SKIP

      ENDDO

      IF !lOk
         EXIT
      ENDIF

      SELECT e_anal
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cIdFirma + cIdVN + cBrNal

      _redni_broj := 0

      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idvn == cIdVN .AND. field->brnal == cBrNal

         hRec := dbf_get_rec()

         hRec[ "rbr" ] := PadL( AllTrim( Str( ++_redni_broj ) ), 3 )

         _gl_brojac += _redni_broj

         @ box_x_koord() + 3, box_y_koord() + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + hRec[ "rbr" ]

         SELECT anal
         APPEND BLANK
         lOk := update_rec_server_and_dbf( "fin_anal", hRec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT e_anal
         SKIP

      ENDDO

      IF !lOk
         EXIT
      ENDIF

      SELECT e_sint
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cIdFirma + cIdVN + cBrNal

      _redni_broj := 0

      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idvn == cIdVN .AND. field->brnal == cBrNal

         hRec := dbf_get_rec()

         hRec[ "rbr" ] := PadL( AllTrim( Str( ++_redni_broj ) ), 3 )

         _gl_brojac += _redni_broj

         @ box_x_koord() + 3, box_y_koord() + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + hRec[ "rbr" ]

         SELECT sint
         APPEND BLANK
         lOk := update_rec_server_and_dbf( "fin_sint", hRec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT e_sint
         SKIP

      ENDDO

      IF !lOk
         EXIT
      ENDIF

      SELECT e_nalog
      SKIP

   ENDDO

   IF lOk
      hParams[ "unlock" ] := { "fin_nalog", "fin_anal", "fin_sint", "fin_suban" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Problem sa importom finansijskih naloga u kumulativne tabele." )
   ENDIF

   IF nCnt > 0 .AND. lOk

      @ box_x_koord() + 3, box_y_koord() + 2 SAY PadR( "", 69 )

      update_table_partn( _zamjeniti_sif )
      update_table_konto( _zamjeniti_sif )
      update_sifk_sifv()

   ENDIF

   BoxC()

   IF nCnt > 0
      _ret := nCnt
   ENDIF

   RETURN _ret



STATIC FUNCTION brisi_dokument_iz_kumulativa( cIdFirma, cIdVN, cBrNal )

   LOCAL nDbfArea := Select()
   LOCAL hRecBrisi, nTrec
   LOCAL lOk := .T.

   IF find_suban_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
      hRecBrisi := dbf_get_rec()
      lOk := delete_rec_server_and_dbf( "fin_suban", hRecBrisi, 2, "CONT" )
   ENDIF

   IF lOk
      IF find_nalog_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
         hRecBrisi := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( "fin_nalog", hRecBrisi, 1, "CONT" )
      ENDIF
   ENDIF

   IF lOk
      IF find_anal_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
         hRecBrisi := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( "fin_anal", hRecBrisi, 2, "CONT" )
      ENDIF
   ENDIF

   IF lOk
      IF find_sint_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
         hRecBrisi := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( "fin_sint", hRecBrisi, 2, "CONT" )
      ENDIF
   ENDIF

   SELECT ( nDbfArea )

   RETURN lOk




STATIC FUNCTION fin_export_cre_e_dbfs( cDbfPath )

   LOCAL _cre

   IF cDbfPath == NIL
      cDbfPath := my_home()
   ENDIF

   // provjeri da li postoji direktorij, pa ako ne - kreiraj
   direktorij_kreiraj_ako_ne_postoji( cDbfPath )

   // tabela suban
   o_suban()
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_suban" ) FROM ( my_home() + "struct" )

   // tabela nalog
   o_nalog()
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_nalog" ) FROM ( my_home() + "struct" )

   // tabela sint
   o_sint()
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_sint" ) FROM ( my_home() + "struct" )

   // tabela anal
   o_anal()
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_anal" ) FROM ( my_home() + "struct" )

   select_o_partner( "XXXXX" )
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_partn" ) FROM ( my_home() + "struct" )


   select_o_konto( "XXXXX" )
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_konto" ) FROM ( my_home() + "struct" )


   o_sifk( "XXXX" )
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_sifk" ) FROM ( my_home() + "struct" )

   o_sifv( "XXXX" )
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_sifv" ) FROM ( my_home() + "struct" )

   RETURN .T.



STATIC FUNCTION fin_exp_o_promet_tabele()

   o_suban()
   o_nalog()
   o_anal()
   o_sint()
   // o_sifk()
   // o_sifv()
   // o_konto()
   // o_partner()

   RETURN .T.




STATIC FUNCTION fin_export_otvori_e_dbfs( cDbfPath, lFromFmk )

   LOCAL cDbfName

   IF ( cDbfPath == NIL )
      cDbfPath := my_home()
   ENDIF

   IF ( lFromFmk == NIL )
      lFromFmk := .F.
   ENDIF

   log_write( "otvaram fin tabele importa i pravim indekse...", 9 )

   my_close_all_dbf()

   cDbfName := "e_suban.dbf"

   SELECT ( F_TMP_E_SUBAN )
   my_use_temp( "E_SUBAN", cDbfPath + cDbfName, .F., .T. )
   INDEX ON ( idfirma + idvn + brnal ) TAG "1"

   log_write( "otvorio i indeksirao: " + cDbfPath + cDbfName, 5 )

   cDbfName := "e_nalog.dbf"
   SELECT ( F_TMP_E_NALOG )
   my_use_temp( "E_NALOG", cDbfPath + cDbfName, .F., .T. )
   INDEX ON ( idfirma + idvn + brnal ) TAG "1"

   log_write( "otvorio i indeksirao: " + cDbfPath + cDbfName, 5 )

   cDbfName := "e_sint.dbf"
   SELECT ( F_TMP_E_SINT )
   my_use_temp( "E_SINT", cDbfPath + cDbfName, .F., .T. )
   INDEX ON ( idfirma + idvn + brnal ) TAG "1"

   cDbfName := "e_anal.dbf"
   SELECT ( F_TMP_E_ANAL )
   my_use_temp( "E_ANAL", cDbfPath + cDbfName, .F., .T. )
   INDEX ON ( idfirma + idvn + brnal ) TAG "1"

   cDbfName := "e_partn.dbf"
   SELECT ( F_TMP_E_PARTN )
   my_use_temp( "E_PARTN", cDbfPath + cDbfName, .F., .T. )
   INDEX ON ( id ) TAG "ID"

   cDbfName := "e_konto.dbf"
   SELECT ( F_TMP_E_KONTO )
   my_use_temp( "E_KONTO", cDbfPath + cDbfName, .F., .T. )
   INDEX ON ( id ) TAG "ID"

   cDbfName := "e_sifk.dbf"
   SELECT ( F_TMP_E_SIFK )
   my_use_temp( "E_SIFK", cDbfPath + cDbfName, .F., .T. )
   INDEX ON ( id + SORT + naz ) TAG "ID"
   INDEX ON ( id + oznaka ) TAG "ID2"

   cDbfName := "e_sifv.dbf"
   SELECT ( F_TMP_E_SIFV )
   my_use_temp( "E_SIFV", cDbfPath + cDbfName, .F., .T. )
   INDEX ON ( id + oznaka + idsif + naz ) TAG "ID"
   INDEX ON ( id + idsif ) TAG "IDIDSIF"

   log_write( "otvorene sve import tabele i indeksirane...", 9 )

   RETURN .T.
