#include "f18.ch"

MEMVAR m_x, m_y, GetList

STATIC __import_dbf_path
STATIC __export_dbf_path
STATIC __import_zip_name
STATIC __export_zip_name


FUNCTION fin_udaljena_razmjena_podataka()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   __import_dbf_path := my_home() + "import_dbf" + SLASH
   __export_dbf_path := my_home() + "export_dbf" + SLASH
   __import_zip_name := "fin_exp.zip"
   __export_zip_name := "fin_exp.zip"

   // kreiraj ove direktorije odmah
   direktorij_kreiraj_ako_ne_postoji( __export_dbf_path )

   AAdd( _opc, "1. => export podataka               " )
   AAdd( _opcexe, {|| fin_export() } )
   AAdd( _opc, "2. <= import podataka    " )
   AAdd( _opcexe, {|| fin_import() } )

   f18_menu( "razmjena", .F., _izbor, _opc, _opcexe )

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
   delete_exp_files( __export_dbf_path, "fin" )

   // exportuj podatake
   _exported_rec := fin_export_impl( _vars, @_a_data )

   my_close_all_dbf()
   IF _exported_rec > 0

      _error := udaljenja_razmjena_compress_files( "fin", __export_dbf_path )

      IF _error == 0
         // pobrisi fajlove razmjene
         delete_exp_files( __export_dbf_path, "fin" )

         // otvori folder sa exportovanim podacima
         open_folder( __export_dbf_path )

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

   Box(, 1, 70 )
   @ m_x + 1, m_y + 2 SAY "import path:" GET cFinImportPath PICT "@S50"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   __import_dbf_path := AllTrim( cFinImportPath )
   set_metric( "fin_import_path", my_user(), cFinImportPath )

   // import fajl iz liste
   _imp_file := get_import_file( "fin", __import_dbf_path )

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
   IF razmjena_decompress_files( _imp_file, __import_dbf_path, __import_zip_name ) <> 0
      // ako je bilo greske
      RETURN .F.
   ENDIF

#ifdef __PLATFORM__UNIX
   set_file_access( __import_dbf_path )
#endif


   nImportovanihZapisa := fin_import_impl( _vars, @_a_data )

   my_close_all_dbf()

   // brisi fajlove importa
   delete_exp_files( __import_dbf_path, "fin" )

   IF ( nImportovanihZapisa > 0 )

      IF Pitanje(, "Pobrisati fajl razmjne ?", "D" ) == "D"
         delete_zip_files( _imp_file )
      ENDIF

      MsgBeep( "Importovao " + AllTrim( Str( nImportovanihZapisa ) ) + " dokumenta." )

      print_imp_exp_report( _a_data )

   ENDIF

   // vrati se na home direktorij nakon svega
   DirChange( my_home() )

   RETURN .T.



STATIC FUNCTION _vars_export( hVars )

   LOCAL _dat_od := fetch_metric( "fin_export_datum_od", my_user(), Date() - 30 )
   LOCAL _dat_do := fetch_metric( "fin_export_datum_do", my_user(), Date() )
   LOCAL _konta := fetch_metric( "fin_export_lista_konta", my_user(), PadR( "1320;", 200 ) )
   LOCAL _vrste_dok := fetch_metric( "fin_export_vrste_dokumenata", my_user(), PadR( "10;11;", 200 ) )
   LOCAL _exp_sif := fetch_metric( "fin_export_sifrarnik", my_user(), "D" )
   LOCAL _exp_path := fetch_metric( "fin_export_path", my_user(), PadR( "", 300 ) )
   LOCAL nX := 1
   LOCAL bKeyHanlder := { | oGet| info_bar( "get", "ulovio sam: " + oGet:cBuffer) }
   LOCAL bReader

   IF Empty( AllTrim( _exp_path ) )
      _exp_path := PadR( __export_dbf_path, 300 )
   ENDIF

   Box(, 15, 70 )

   @ m_x + nX, m_y + 2 SAY "*** Uslovi exporta dokumenata"
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "Vrste dokumenata:" GET _vrste_dok PICT "@S40"
   ++nX
   @ m_x + nX, m_y + 2 SAY "Datumski period od" GET _dat_od
   @ m_x + nX, Col() + 1 SAY "do" GET _dat_do
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY8 "Uzeti u obzir sljedeća konta:" GET _konta PICT "@S30"
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY8 "Export šifarnika (D/N) ?" GET _exp_sif PICT "@!" VALID _exp_sif $ "DN"

   ++nX
   @ m_x + nX, m_y + 2 SAY8 "Lokacija exporta:" GET _exp_path PICT "@S50"



   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "fin_export_datum_od", my_user(), _dat_od )
   set_metric( "fin_export_datum_do", my_user(), _dat_do )
   set_metric( "fin_export_lista_konta", my_user(), _konta )
   set_metric( "fin_export_vrste_dokumenata", my_user(), _vrste_dok )
   set_metric( "fin_export_sifrarnik", my_user(), _exp_sif )
   set_metric( "fin_export_path", my_user(), _exp_path )

   __export_dbf_path := AllTrim( _exp_path )

   hVars[ "datum_od" ] := _dat_od
   hVars[ "datum_do" ] := _dat_do
   hVars[ "konta" ] := _konta
   hVars[ "vrste_dok" ] := _vrste_dok
   hVars[ "export_sif" ] := _exp_sif

   RETURN .T.



// -------------------------------------------
// uslovi importa dokumenta
// -------------------------------------------
STATIC FUNCTION _vars_import( hVars )

   LOCAL _ret := .F.
   LOCAL _dat_od := fetch_metric( "fin_import_datum_od", my_user(), CToD( "" ) )
   LOCAL _dat_do := fetch_metric( "fin_import_datum_do", my_user(), CToD( "" ) )
   LOCAL _konta := fetch_metric( "fin_import_lista_konta", my_user(), PadR( "", 200 ) )
   LOCAL _vrste_dok := fetch_metric( "fin_import_vrste_dokumenata", my_user(), PadR( "", 200 ) )
   LOCAL _zamjeniti_dok := fetch_metric( "fin_import_zamjeniti_dokumente", my_user(), "N" )
   LOCAL _zamjeniti_sif := fetch_metric( "fin_import_zamjeniti_sifre", my_user(), "N" )
   LOCAL _iz_fmk := fetch_metric( "fin_import_iz_fmk", my_user(), "N" )
   LOCAL cFinImportPath := fetch_metric( "fin_import_path", my_user(), PadR( "", 300 ) )
   LOCAL nX := 1

   IF Empty( AllTrim( cFinImportPath ) )
      cFinImportPath := PadR( __import_dbf_path, 300 )
   ENDIF


   Box(, 15, 70 )

   @ m_x + nX, m_y + 2 SAY8 "*** Uslovi importa dokumenata"

   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY8 "Vrste dokumenata (prazno-sve):" GET _vrste_dok PICT "@S30"
   ++nX
   @ m_x + nX, m_y + 2 SAY8 "Datumski period od" GET _dat_od
   @ m_x + nX, Col() + 1 SAY "do" GET _dat_do
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY8 "Uzeti u obzir sljedeća konta:" GET _konta PICT "@S30"
   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY8 "Zamijeniti postojeće dokumente novim (D/N):" GET _zamjeniti_dok PICT "@!" VALID _zamjeniti_dok $ "DN"
   ++nX
   @ m_x + nX, m_y + 2 SAY8 "Zamijeniti postojeće šifre novim (D/N):" GET _zamjeniti_sif PICT "@!" VALID _zamjeniti_sif $ "DN"

//   ++nX
//   ++nX
//   @ m_x + nX, m_y + 2 SAY "Import fajl dolazi iz FMK (D/N) ?" GET _iz_fmk PICT "@!" VALID _iz_fmk $ "DN"

   ++nX
   ++nX
   @ m_x + nX, m_y + 2 SAY "Lokacija importa:" GET cFinImportPath PICT "@S50"


   READ

   BoxC()

   IF LastKey() <> K_ESC

      _ret := .T.
      set_metric( "fin_import_datum_od", my_user(), _dat_od )
      set_metric( "fin_import_datum_do", my_user(), _dat_do )
      set_metric( "fin_import_lista_konta", my_user(), _konta )
      set_metric( "fin_import_vrste_dokumenata", my_user(), _vrste_dok )
      set_metric( "fin_import_zamjeniti_dokumente", my_user(), _zamjeniti_dok )
      set_metric( "fin_import_zamjeniti_sifre", my_user(), _zamjeniti_sif )
      set_metric( "fin_import_iz_fmk", my_user(), _iz_fmk )
      set_metric( "fin_import_path", my_user(), cFinImportPath )

      // set static var
      __import_dbf_path := AllTrim( cFinImportPath )

      hVars[ "datum_od" ] := _dat_od
      hVars[ "datum_do" ] := _dat_do
      hVars[ "konta" ] := _konta
      hVars[ "vrste_dok" ] := _vrste_dok
      hVars[ "zamjeniti_dokumente" ] := _zamjeniti_dok
      hVars[ "zamjeniti_sifre" ] := _zamjeniti_sif
      hVars[ "import_iz_fmk" ] := _iz_fmk

   ENDIF

   RETURN _ret



STATIC FUNCTION fin_export_impl( hVars, a_details )

   LOCAL _id_firma, _id_vd, _br_dok
   LOCAL hRec
   LOCAL nCnt := 0
   LOCAL _dat_od, _dat_do, _konta, _vrste_dok, _export_sif
   LOCAL _usl_konto, _id_konto
   LOCAL cIdPartner
   LOCAL hRecExpDetalji

   // uslovi za export ce biti...
   _dat_od := hVars[ "datum_od" ]
   _dat_do := hVars[ "datum_do" ]
   _konta := AllTrim( hVars[ "konta" ] )
   _vrste_dok := AllTrim( hVars[ "vrste_dok" ] )
   _export_sif := AllTrim( hVars[ "export_sif" ] )

   fin_exp_cre_e_dbfs( __export_dbf_path )
   fin_exp_otvori_e_dbfs( __export_dbf_path )


   IF Select( "E_NALOG" ) == 0
      MsgBeep( "ERR e_nalog.dbf nije uspjesno kreiran !?##STOP!" )
      RETURN -1
   ENDIF

   // fin_exp_o_promet_tabele()

   Box(, 2, 65 )

   @ m_x + 1, m_y + 2 SAY "... export fin dokumenata u toku"

   find_nalog_za_period( self_organizacija_id(), NIL, _dat_od, _dat_do )

   DO WHILE !Eof()

      _id_firma := field->idfirma
      _id_vd := field->idvn
      _br_dok := field->brnal

      IF !Empty( _vrste_dok )
         IF !( field->idvn $ _vrste_dok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF _dat_od <> CToD( "" )
         IF ( field->datnal < _dat_od )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF _dat_do <> CToD( "" )
         IF ( field->datnal > _dat_do )
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
      @ m_x + 2, m_y + 2 SAY PadR(  PadL( AllTrim( Str( nCnt ) ), 6 ) + ". " + "dokument: " + _id_firma + "-" + _id_vd + "-" + AllTrim( _br_dok ), 50 )

      find_suban_by_broj_dokumenta( _id_firma, _id_vd, _br_dok )
      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvn == _id_vd .AND. field->brnal == _br_dok

         _id_konto := suban->idkonto
         cIdPartner := suban->idpartner

         hRec := dbf_get_rec()
         SELECT e_suban
         APPEND BLANK
         dbf_update_rec( hRec )

         SELECT select_o_konto( _id_konto )
         IF Found() .AND. _export_sif == "D"
            hRec := dbf_get_rec()
            SELECT e_konto
            SET ORDER TO TAG "ID"
            SEEK _id_konto
            IF !Found()
               APPEND BLANK
               dbf_update_rec( hRec )
               // napuni i sifk, sifv parametre
               razmjena_fill_sifk_sifv( "KONTO", _id_konto )
            ENDIF
         ENDIF

         select_o_partner( cIdPartner )
         IF Found() .AND. _export_sif == "D"

            hRec := dbf_get_rec()
            SELECT e_partn
            SET ORDER TO TAG "ID"
            SEEK cIdPartner
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


      find_sint_by_broj_dokumenta( _id_firma, _id_vd, _br_dok )
      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvn == _id_vd .AND. field->brnal == _br_dok

         hRec := dbf_get_rec() // sint
         SELECT e_sint
         APPEND BLANK
         dbf_update_rec( hRec )

         SELECT sint
         SKIP

      ENDDO


      find_anal_by_broj_dokumenta( _id_firma, _id_vd, _br_dok )
      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvn == _id_vd .AND. field->brnal == _br_dok

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
   LOCAL _id_firma, _id_vd, _br_dok
   LOCAL hRec
   LOCAL nCnt := 0
   LOCAL _dat_od, _dat_do, _konta, _vrste_dok, _zamjeniti_dok, _zamjeniti_sif, _iz_fmk
   LOCAL _roba_id, _partn_id, _konto_id
   LOCAL _sif_exist
   LOCAL _fmk_import := .F.
   LOCAL _redni_broj := 0
   LOCAL _total_suban := 0
   LOCAL _total_anal := 0
   LOCAL _total_sint := 0
   LOCAL _total_nalog := 0
   LOCAL _gl_brojac := 0
   LOCAL _dat_dok
   LOCAL hRecExpDetalji
   LOCAL lOk := .T.
   LOCAL hParams := hb_Hash()

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_nalog", "fin_anal", "fin_sint", "fin_suban" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN nCnt
   ENDIF

   _dat_od := hVars[ "datum_od" ]
   _dat_do := hVars[ "datum_do" ]
   _konta := hVars[ "konta" ]
   _vrste_dok := hVars[ "vrste_dok" ]
   _zamjeniti_dok := hVars[ "zamjeniti_dokumente" ]
   _zamjeniti_sif := hVars[ "zamjeniti_sifre" ]
   _iz_fmk := hVars[ "import_iz_fmk" ]

   IF _iz_fmk == "D"
      _fmk_import := .T.
   ENDIF

   fin_exp_otvori_e_dbfs( __import_dbf_path, _fmk_import )

   fin_exp_o_promet_tabele()

   SELECT e_nalog
   _total_nalog := RECCOUNT2()

   SELECT e_suban
   _total_suban := RECCOUNT2()

   SELECT e_nalog
   SET ORDER TO TAG "1"
   GO TOP

   Box(, 3, 70 )

   @ m_x + 1, m_y + 2 SAY PadR( "... import fin dokumenata u toku ", 69 ) COLOR f18_color_i()
   @ m_x + 2, m_y + 2 SAY "broj zapisa nalog/" + AllTrim( Str( _total_nalog ) ) + ", suban/" + AllTrim( Str( _total_suban ) )

   DO WHILE !Eof()

      _id_firma := field->idfirma
      _id_vd := field->idvn
      _br_dok := field->brnal
      _dat_dok := field->datnal

      IF _dat_od <> CToD( "" )
         IF field->datnal < _dat_od
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF _dat_do <> CToD( "" )
         IF field->datnal > _dat_do
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

      IF fin_dokument_postoji( _id_firma, _id_vd, _br_dok )

         hRecExpDetalji := hb_Hash()
         hRecExpDetalji[ "dokument" ] := _id_firma + "-" + _id_vd + "-" + _br_dok
         hRecExpDetalji[ "datum" ] := _dat_dok
         hRecExpDetalji[ "idpartner" ] := ""
         hRecExpDetalji[ "partner" ] := ""
         hRecExpDetalji[ "idkonto" ] := ""
         hRecExpDetalji[ "iznos" ] := 0

         IF _zamjeniti_dok == "D"

            hRecExpDetalji[ "tip" ] := "delete"
            export_import_add_to_details( @a_details, hRecExpDetalji )

            lOk := brisi_dokument_iz_kumulativa( _id_firma, _id_vd, _br_dok )

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
      @ m_x + 3, m_y + 2 SAY PadR( PadL( AllTrim( Str( nCnt ) ), 5 ) + ". dokument: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 60 )

      SELECT e_suban
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vd + _br_dok

      _redni_broj := 0

      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvn == _id_vd .AND. field->brnal == _br_dok

         hRec := dbf_get_rec()

         hRec[ "rbr" ] :=  ++_redni_broj

         _gl_brojac += _redni_broj

         @ m_x + 3, m_y + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + Str( hRec[ "rbr" ], 5 )

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
      SEEK _id_firma + _id_vd + _br_dok

      _redni_broj := 0

      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvn == _id_vd .AND. field->brnal == _br_dok

         hRec := dbf_get_rec()

         hRec[ "rbr" ] := PadL( AllTrim( Str( ++_redni_broj ) ), 3 )

         _gl_brojac += _redni_broj

         @ m_x + 3, m_y + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + hRec[ "rbr" ]

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
      SEEK _id_firma + _id_vd + _br_dok

      _redni_broj := 0

      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvn == _id_vd .AND. field->brnal == _br_dok

         hRec := dbf_get_rec()

         hRec[ "rbr" ] := PadL( AllTrim( Str( ++_redni_broj ) ), 3 )

         _gl_brojac += _redni_broj

         @ m_x + 3, m_y + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + hRec[ "rbr" ]

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

      @ m_x + 3, m_y + 2 SAY PadR( "", 69 )

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
   LOCAL _del_rec, _t_rec
   LOCAL lOk := .T.

   IF find_suban_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
      _del_rec := dbf_get_rec()
      lOk := delete_rec_server_and_dbf( "fin_suban", _del_rec, 2, "CONT" )
   ENDIF

   IF lOk
      IF find_nalog_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
         _del_rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( "fin_nalog", _del_rec, 1, "CONT" )
      ENDIF
   ENDIF

   IF lOk
      IF find_anal_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
         _del_rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( "fin_anal", _del_rec, 2, "CONT" )
      ENDIF
   ENDIF

   IF lOk
      IF find_sint_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )
         _del_rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( "fin_sint", _del_rec, 2, "CONT" )
      ENDIF
   ENDIF

   SELECT ( nDbfArea )

   RETURN lOk




STATIC FUNCTION fin_exp_cre_e_dbfs( cDbfPath )

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

   // tabela sifk
   o_sifk()
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( cDbfPath + "e_sifk" ) FROM ( my_home() + "struct" )

   // tabela sifv
   o_sifv()
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





STATIC FUNCTION fin_exp_otvori_e_dbfs( cDbfPath, lFromFmk )

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
