/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

STATIC __import_dbf_path
STATIC __export_dbf_path
STATIC __import_zip_name
STATIC __export_zip_name


FUNCTION kalk_udaljena_razmjena_podataka()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   __import_dbf_path := my_home() + "import_dbf" + SLASH
   __export_dbf_path := my_home() + "export_dbf" + SLASH
   __import_zip_name := "kalk_exp.zip"
   __export_zip_name := "kalk_exp.zip"

   AAdd( _opc, "1. => export podataka               " )
   AAdd( _opcexe, {|| _kalk_export() } )
   AAdd( _opc, "2. <= import podataka    " )
   AAdd( _opcexe, {|| _kalk_import() } )

   f18_menu( "razmjena", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN


// ----------------------------------------
// export podataka modula KALK
// ----------------------------------------
STATIC FUNCTION _kalk_export()

   LOCAL _vars := hb_Hash()
   LOCAL _exported_rec
   LOCAL _error
   LOCAL _a_data := {}

   // uslovi exporta
   IF !_vars_export( @_vars )
      RETURN
   ENDIF

   // pobrisi u folderu tmp fajlove ako postoje
   delete_exp_files( __export_dbf_path, "kalk" )

   // exportuj podatake
   _exported_rec := __export( _vars, @_a_data )

   // zatvori sve tabele prije operacije pakovanja
   my_close_all_dbf()

   // arhiviraj podatke
   IF _exported_rec > 0

      // kompresuj ih u zip fajl za prenos
      _error := _compress_files( "kalk", __export_dbf_path )

      // sve u redu
      IF _error == 0

         // pobrisi fajlove razmjene
         delete_exp_files( __export_dbf_path, "kalk" )

         // otvori folder sa exportovanim podacima
         open_folder( __export_dbf_path )

      ENDIF

   ENDIF

   // vrati se na glavni direktorij
   DirChange( my_home() )

   IF ( _exported_rec > 0 )

      MsgBeep( "Exportovao " + AllTrim( Str( _exported_rec ) ) + " dokumenta." )

      // printaj izvjestaj
      print_imp_exp_report( _a_data )

   ENDIF

   my_close_all_dbf()

   RETURN



// ----------------------------------------
// import podataka modula KALK
// ----------------------------------------
STATIC FUNCTION _kalk_import()

   LOCAL _imported_rec
   LOCAL _vars := hb_Hash()
   LOCAL _imp_file
   LOCAL _a_data := {}
   LOCAL _imp_path := fetch_metric( "kalk_import_path", my_user(), PadR( "", 300 ) )

   Box(, 1, 70 )
   @ m_x + 1, m_y + 2 SAY "import path:" GET _imp_path PICT "@S50"
   READ
   BoxC()
	
   IF LastKey() == K_ESC
      RETURN
   endif

   // snimi u parametre
   __import_dbf_path := AllTrim( _imp_path )
   set_metric( "kalk_import_path", my_user(), _imp_path )

   // import fajl iz liste
   _imp_file := get_import_file( "kalk", __import_dbf_path )

   IF _imp_file == NIL .OR. Empty( _imp_file )
      MsgBeep( "Nema odabranog import fajla !????" )
      RETURN
   ENDIF

   // parametri
   IF !_vars_import( @_vars )
      RETURN
   ENDIF

   IF !import_file_exist( _imp_file )
      // nema fajla za import ?
      MsgBeep( "import fajl ne postoji !??? prekidam operaciju" )
      RETURN
   ENDIF

   // dekompresovanje podataka
   IF _decompress_files( _imp_file, __import_dbf_path, __import_zip_name ) <> 0
      // ako je bilo greske
      RETURN
   ENDIF

#ifdef __PLATFORM__UNIX
   set_file_access( __import_dbf_path )
#endif

   // import procedura
   _imported_rec := __import( _vars, @_a_data )

   // zatvori sve
   my_close_all_dbf()

   // brisi fajlove importa
   delete_exp_files( __import_dbf_path, "kalk" )

   IF ( _imported_rec > 0 )

      // nakon uspjesnog importa...
      IF Pitanje(, "Pobrisati fajl razmjne ?", "D" ) == "D"
         // brisi zip fajl...
         delete_zip_files( _imp_file )
      ENDIF

      MsgBeep( "Importovao " + AllTrim( Str( _imported_rec ) ) + " dokumenta." )

      // printaj izvjestaj
      print_imp_exp_report( _a_data )

   ENDIF

   // vrati se na home direktorij nakon svega
   DirChange( my_home() )

   RETURN


// -------------------------------------------
// uslovi exporta dokumenta
// -------------------------------------------
STATIC FUNCTION _vars_export( vars )

   LOCAL _ret := .F.
   LOCAL _dat_od := fetch_metric( "kalk_export_datum_od", my_user(), Date() - 30 )
   LOCAL _dat_do := fetch_metric( "kalk_export_datum_do", my_user(), Date() )
   LOCAL _konta := fetch_metric( "kalk_export_lista_konta", my_user(), PadR( "1320;", 200 ) )
   LOCAL _vrste_dok := fetch_metric( "kalk_export_vrste_dokumenata", my_user(), PadR( "10;11;", 200 ) )
   LOCAL _exp_sif := fetch_metric( "kalk_export_sifrarnik", my_user(), "D" )
   LOCAL _exp_path := fetch_metric( "kalk_export_path", my_user(), PadR( "", 300 ) )
   LOCAL _x := 1

   IF Empty( AllTrim( _exp_path ) )
      _exp_path := PadR( __export_dbf_path, 300 )
   ENDIF

   Box(, 15, 70 )

   @ m_x + _x, m_y + 2 SAY "*** Uslovi exporta dokumenata"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Vrste dokumenata:" GET _vrste_dok PICT "@S40"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Datumski period od" GET _dat_od
   @ m_x + _x, Col() + 1 SAY "do" GET _dat_do

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Uzeti u obzir sljedeca konta:" GET _konta PICT "@S30"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Eksportovati sifrarnike (D/N) ?" GET _exp_sif PICT "@!" VALID _exp_sif $ "DN"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Eksport lokacija:" GET _exp_path PICT "@S50"

   READ

   BoxC()

   // snimi parametre
   IF LastKey() <> K_ESC

      _ret := .T.

      set_metric( "kalk_export_datum_od", my_user(), _dat_od )
      set_metric( "kalk_export_datum_do", my_user(), _dat_do )
      set_metric( "kalk_export_lista_konta", my_user(), _konta )
      set_metric( "kalk_export_vrste_dokumenata", my_user(), _vrste_dok )
      set_metric( "kalk_export_sifrarnik", my_user(), _exp_sif )
      set_metric( "kalk_export_path", my_user(), _exp_path )

      // export path, set static var
      __export_dbf_path := AllTrim( _exp_path )

      vars[ "datum_od" ] := _dat_od
      vars[ "datum_do" ] := _dat_do
      vars[ "konta" ] := _konta
      vars[ "vrste_dok" ] := _vrste_dok
      vars[ "export_sif" ] := _exp_sif

   ENDIF

   RETURN _ret



// -------------------------------------------
// uslovi importa dokumenta
// -------------------------------------------
STATIC FUNCTION _vars_import( vars )

   LOCAL _ret := .F.
   LOCAL _dat_od := fetch_metric( "kalk_import_datum_od", my_user(), CToD( "" ) )
   LOCAL _dat_do := fetch_metric( "kalk_import_datum_do", my_user(), CToD( "" ) )
   LOCAL _konta := fetch_metric( "kalk_import_lista_konta", my_user(), PadR( "", 200 ) )
   LOCAL _vrste_dok := fetch_metric( "kalk_import_vrste_dokumenata", my_user(), PadR( "", 200 ) )
   LOCAL _zamjeniti_dok := fetch_metric( "kalk_import_zamjeniti_dokumente", my_user(), "N" )
   LOCAL _zamjeniti_sif := fetch_metric( "kalk_import_zamjeniti_sifre", my_user(), "N" )
   LOCAL _iz_fmk := fetch_metric( "kalk_import_iz_fmk", my_user(), "N" )
   LOCAL _imp_path := fetch_metric( "kalk_import_path", my_user(), PadR( "", 300 ) )
   LOCAL _x := 1

   IF Empty( AllTrim( _imp_path ) )
      _imp_path := PadR( __import_dbf_path, 300 )
   ENDIF

   Box(, 15, 70 )

   @ m_x + _x, m_y + 2 SAY "*** Uslovi importa dokumenata"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Vrste dokumenata (prazno-sve):" GET _vrste_dok PICT "@S30"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Datumski period od" GET _dat_od
   @ m_x + _x, Col() + 1 SAY "do" GET _dat_do

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Uzeti u obzir sljedeca konta:" GET _konta PICT "@S30"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Zamjeniti postojece dokumente novim (D/N):" GET _zamjeniti_dok PICT "@!" VALID _zamjeniti_dok $ "DN"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Zamjeniti postojece sifre novim (D/N):" GET _zamjeniti_sif PICT "@!" VALID _zamjeniti_sif $ "DN"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Import fajl dolazi iz FMK (D/N) ?" GET _iz_fmk PICT "@!" VALID _iz_fmk $ "DN"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Import lokacija:" GET _imp_path PICT "@S50"

   READ

   BoxC()

   // snimi parametre
   IF LastKey() <> K_ESC

      _ret := .T.

      set_metric( "kalk_import_datum_od", my_user(), _dat_od )
      set_metric( "kalk_import_datum_do", my_user(), _dat_do )
      set_metric( "kalk_import_lista_konta", my_user(), _konta )
      set_metric( "kalk_import_vrste_dokumenata", my_user(), _vrste_dok )
      set_metric( "kalk_import_zamjeniti_dokumente", my_user(), _zamjeniti_dok )
      set_metric( "kalk_import_zamjeniti_sifre", my_user(), _zamjeniti_sif )
      set_metric( "kalk_import_iz_fmk", my_user(), _iz_fmk )
      set_metric( "kalk_import_path", my_user(), _imp_path )

      // set static var
      __import_dbf_path := AllTrim( _imp_path )

      vars[ "datum_od" ] := _dat_od
      vars[ "datum_do" ] := _dat_do
      vars[ "konta" ] := _konta
      vars[ "vrste_dok" ] := _vrste_dok
      vars[ "zamjeniti_dokumente" ] := _zamjeniti_dok
      vars[ "zamjeniti_sifre" ] := _zamjeniti_sif
      vars[ "import_iz_fmk" ] := _iz_fmk

   ENDIF

   RETURN _ret



// -------------------------------------------
// export podataka
// -------------------------------------------
STATIC FUNCTION __export( vars, a_details )

   LOCAL _ret := 0
   LOCAL _id_firma, _id_vd, _br_dok
   LOCAL _app_rec
   LOCAL _cnt := 0
   LOCAL _dat_od, _dat_do, _konta, _vrste_dok, _export_sif
   LOCAL _usl_mkonto, _usl_pkonto
   LOCAL _id_partn, _p_konto, _m_konto
   LOCAL _id_roba
   LOCAL _detail_rec

   // uslovi za export ce biti...
   _dat_od := vars[ "datum_od" ]
   _dat_do := vars[ "datum_do" ]
   _konta := AllTrim( vars[ "konta" ] )
   _vrste_dok := AllTrim( vars[ "vrste_dok" ] )
   _export_sif := AllTrim( vars[ "export_sif" ] )


   // kreiraj tabele exporta
   _cre_exp_tbls( __export_dbf_path )

   // otvori export tabele za pisanje podataka
   _o_exp_tables( __export_dbf_path )

   // otvori lokalne tabele za prenos
   _o_tables()

   Box(, 2, 65 )

   @ m_x + 1, m_y + 2 SAY "... export kalk dokumenata u toku"

   SELECT kalk_doks
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      _id_firma := field->idfirma
      _id_vd := field->idvd
      _br_dok := field->brdok
      _id_partn := field->idpartner
      _p_konto := field->pkonto
      _m_konto := field->mkonto

      // provjeri uslove ?!??

      // lista konta...
      IF !Empty( _konta )

         _usl_mkonto := Parsiraj( AllTrim( _konta ), "mkonto" )
         _usl_pkonto := Parsiraj( AllTrim( _konta ), "pkonto" )

         IF !( &_usl_mkonto )
            IF !( &_usl_pkonto )
               SKIP
               LOOP
            ENDIF
         ENDIF

      ENDIF

      // lista dokumenata...
      IF !Empty( _vrste_dok )
         IF !( field->idvd $ _vrste_dok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      // datumski uslov...
      IF _dat_od <> CToD( "" )
         IF ( field->datdok < _dat_od )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF _dat_do <> CToD( "" )
         IF ( field->datdok > _dat_do )
            SKIP
            LOOP
         ENDIF
      ENDIF

      // ako je sve zadovoljeno !
      // dodaj zapis u tabelu e_doks
      _app_rec := dbf_get_rec()

      _detail_rec := hb_Hash()
      _detail_rec[ "dokument" ] := _app_rec[ "idfirma" ] + "-" + _app_rec[ "idvd" ] + "-" + _app_rec[ "brdok" ]
      _detail_rec[ "idpartner" ] := _app_rec[ "idpartner" ]
      _detail_rec[ "idkonto" ] := ""
      _detail_rec[ "partner" ] := ""
      _detail_rec[ "iznos" ] := 0
      _detail_rec[ "datum" ] := _app_rec[ "datdok" ]
      _detail_rec[ "tip" ] := "export"

      // dodaj u detalje
      add_to_details( @a_details, _detail_rec )

      SELECT e_doks
      APPEND BLANK
      dbf_update_rec( _app_rec )

      ++ _cnt
      @ m_x + 2, m_y + 2 SAY PadR(  PadL( AllTrim( Str( _cnt ) ), 6 ) + ". " + "dokument: " + _id_firma + "-" + _id_vd + "-" + AllTrim( _br_dok ), 50 )

      // dodaj zapis i u tabelu e_kalk
      SELECT kalk
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vd + _br_dok

      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvd == _id_vd .AND. field->brdok == _br_dok

         // uzmi robu...
         _id_roba := field->idroba

         // upisi zapis u tabelu e_kalk
         _app_rec := dbf_get_rec()
         SELECT e_kalk
         APPEND BLANK
         dbf_update_rec( _app_rec )

         // uzmi sada robu sa ove stavke pa je ubaci u e_roba
         SELECT roba
         HSEEK _id_roba
         IF Found() .AND. _export_sif == "D"
            _app_rec := dbf_get_rec()
            SELECT e_roba
            SET ORDER TO TAG "ID"
            SEEK _id_roba
            IF !Found()
               APPEND BLANK
               dbf_update_rec( _app_rec )
               // napuni i sifk, sifv parametre
               _fill_sifk( "ROBA", _id_roba )
            ENDIF
         ENDIF

         // idi dalje...
         SELECT kalk
         SKIP

      ENDDO

      // e sada mozemo komotno ici na export partnera
      SELECT partn
      HSEEK _id_partn
      IF Found() .AND. _export_sif == "D"
         _app_rec := dbf_get_rec()
         SELECT e_partn
         SET ORDER TO TAG "ID"
         SEEK _id_partn
         IF !Found()
            APPEND BLANK
            dbf_update_rec( _app_rec )
            // napuni i sifk, sifv parametre
            _fill_sifk( "PARTN", _id_partn )
         ENDIF
      ENDIF

      // i konta, naravno

      // prvo M_KONTO
      SELECT konto
      HSEEK _m_konto
      IF Found() .AND. _export_sif == "D"
         _app_rec := dbf_get_rec()
         SELECT e_konto
         SET ORDER TO TAG "ID"
         SEEK _m_konto
         IF !Found()
            APPEND BLANK
            dbf_update_rec( _app_rec )
         ENDIF
      ENDIF

      // zatim P_KONTO
      SELECT konto
      HSEEK _p_konto
      IF Found() .AND. _export_sif == "D"
         _app_rec := dbf_get_rec()
         SELECT e_konto
         SET ORDER TO TAG "ID"
         SEEK _p_konto
         IF !Found()
            APPEND BLANK
            dbf_update_rec( _app_rec )
         ENDIF
      ENDIF

      SELECT kalk_doks
      SKIP

   ENDDO

   BoxC()

   IF ( _cnt > 0 )
      _ret := _cnt
   ENDIF

   RETURN _ret



// ----------------------------------------
// import podataka
// ----------------------------------------
STATIC FUNCTION __import( vars, a_details )

   LOCAL _ret := 0
   LOCAL _id_firma, _id_vd, _br_dok
   LOCAL _app_rec
   LOCAL _cnt := 0
   LOCAL _dat_od, _dat_do, _konta, _vrste_dok, _zamjeniti_dok, _zamjeniti_sif, _iz_fmk
   LOCAL _usl_mkonto, _usl_pkonto
   LOCAL _roba_id, _partn_id, _konto_id
   LOCAL _sif_exist
   LOCAL _fmk_import := .F.
   LOCAL _redni_broj := 0
   LOCAL _total_doks := 0
   LOCAL _total_kalk := 0
   LOCAL _gl_brojac := 0
   LOCAL _detail_rec
   LOCAL lOk := .T.

   _dat_od := vars[ "datum_od" ]
   _dat_do := vars[ "datum_do" ]
   _konta := vars[ "konta" ]
   _vrste_dok := vars[ "vrste_dok" ]
   _zamjeniti_dok := vars[ "zamjeniti_dokumente" ]
   _zamjeniti_sif := vars[ "zamjeniti_sifre" ]
   _iz_fmk := vars[ "import_iz_fmk" ]

   IF _iz_fmk == "D"
      _fmk_import := .T.
   ENDIF

   _o_exp_tables( __import_dbf_path, _fmk_import )

   _o_tables()

   SELECT e_doks
   _total_doks := RECCOUNT2()

   SELECT e_kalk
   _total_kalk := RECCOUNT2()

   sql_table_update( nil, "BEGIN" )

   IF !f18_lock_tables( { "kalk_kalk", "kalk_doks" }, .T. )
      sql_table_update( nil, "END" )
      MsgBeep( "Ne mogu zaključati tabele !#Prekidam operaciju." )
      RETURN _cnt
   ENDIF

   SELECT e_doks
   SET ORDER TO TAG "1"
   GO TOP

   Box(, 3, 70 )

   @ m_x + 1, m_y + 2 SAY PadR( "... import kalk dokumenata u toku ", 69 ) COLOR "I"
   @ m_x + 2, m_y + 2 SAY "broj zapisa doks/" + AllTrim( Str( _total_doks ) ) + ", kalk/" + AllTrim( Str( _total_kalk ) )

   DO WHILE !Eof()

      _id_firma := field->idfirma
      _id_vd := field->idvd
      _br_dok := field->brdok
      _dat_dok := field->datdok

      IF _dat_od <> CToD( "" )
         IF field->datdok < _dat_od
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF _dat_do <> CToD( "" )
         IF field->datdok > _dat_do
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF !Empty( _konta )

         _usl_mkonto := Parsiraj( AllTrim( _konta ), "mkonto" )
         _usl_pkonto := Parsiraj( AllTrim( _konta ), "pkonto" )

         IF !( &_usl_mkonto )
            IF !( &_usl_pkonto )
               SKIP
               LOOP
            ENDIF
         ENDIF

      ENDIF

      IF !Empty( _vrste_dok )
         IF !( field->idvd $ _vrste_dok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF kalk_dokument_postoji( _id_firma, _id_vd, _br_dok )

         _detail_rec := hb_Hash()
         _detail_rec[ "dokument" ] := _id_firma + "-" + _id_vd + "-" + _br_dok
         _detail_rec[ "datum" ] := _dat_dok
         _detail_rec[ "idpartner" ] := ""
         _detail_rec[ "partner" ] := ""
         _detail_rec[ "idkonto" ] := ""
         _detail_rec[ "iznos" ] := 0

         IF _zamjeniti_dok == "D"

            _detail_rec[ "tip" ] := "delete"
            add_to_details( @a_details, _detail_rec )

            lOk := del_kalk_doc( _id_firma, _id_vd, _br_dok )

         ELSE

            _detail_rec[ "tip" ] := "x"
            add_to_details( @a_details, _detail_rec )

            SELECT e_doks
            SKIP
            LOOP

         ENDIF

      ENDIF

      IF !lOk
         EXIT
      ENDIF

      SELECT e_doks
      _app_rec := dbf_get_rec()

      _detail_rec := hb_Hash()
      _detail_rec[ "dokument" ] := _app_rec[ "idfirma" ] + "-" + _app_rec[ "idvd" ] + "-" + _app_rec[ "brdok" ]
      _detail_rec[ "idpartner" ] := _app_rec[ "idpartner" ]
      _detail_rec[ "idkonto" ] := ""
      _detail_rec[ "partner" ] := ""
      _detail_rec[ "iznos" ] := 0
      _detail_rec[ "datum" ] := _app_rec[ "datdok" ]
      _detail_rec[ "tip" ] := "import"
      add_to_details( @a_details, _detail_rec )

      _app_rec[ "podbr" ] := ""

      SELECT kalk_doks
      APPEND BLANK

      lOk := update_rec_server_and_dbf( "kalk_doks", _app_rec, 1, "CONT" )

      IF !lOk
         EXIT
      ENDIF
   
      ++ _cnt
      @ m_x + 3, m_y + 2 SAY PadR( PadL( AllTrim( Str( _cnt ) ), 5 ) + ". dokument: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 60 )

      SELECT e_kalk
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vd + _br_dok

      _redni_broj := 0

      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idvd == _id_vd .AND. field->brdok == _br_dok

         _app_rec := dbf_get_rec()

         hb_HDel( _app_rec, "roktr" )
         hb_HDel( _app_rec, "datkurs" )

         _app_rec[ "rbr" ] := PadL( AllTrim( Str( ++_redni_broj ) ), 3 )
         _app_rec[ "podbr" ] := ""

         _gl_brojac += _redni_broj

         @ m_x + 3, m_y + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + _app_rec[ "rbr" ]

         SELECT kalk
         APPEND BLANK

         lOk := update_rec_server_and_dbf( "kalk_kalk", _app_rec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT e_kalk
         SKIP

      ENDDO

      IF !lOk
         EXIT 
      ENDIF

      SELECT e_doks
      SKIP

   ENDDO

   IF lOk
      f18_free_tables( { "kalk_doks", "kalk_kalk" } )
      sql_table_update( nil, "END" )
   ELSE
      sql_table_update( nil, "ROLLBACK" )
      MsgBeep( "Problem sa ažuriranjem dokumenta na server !" )
   ENDIF

   IF _cnt >= 0 .AND. lOk

      @ m_x + 3, m_y + 2 SAY PadR( "", 69 )

      update_table_roba( _zamjeniti_sif )
      update_table_partn( _zamjeniti_sif )
      update_table_konto( _zamjeniti_sif )
      update_sifk_sifv()

   ENDIF

   BoxC()

   IF _cnt > 0
      _ret := _cnt
   ENDIF

   RETURN _ret



// ----------------------------------------------------------
// brisi dokument iz doks-a
// ----------------------------------------------------------
STATIC FUNCTION del_kalk_doc( id_firma, id_vd, br_dok )

   LOCAL _t_area := Select()
   LOCAL _del_rec
   LOCAL _ret := .F.

   SELECT kalk_doks
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vd + br_dok

   IF Found()
      _ret := .T.
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "kalk_doks", _del_rec, 1, "CONT" )
   ENDIF

   SELECT kalk
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vd + br_dok

   IF Found()
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "kalk_kalk", _del_rec, 2, "CONT" )
   ENDIF

   SELECT ( _t_area )

   RETURN _ret



// ----------------------------------------
// kreiranje tabela razmjene
// ----------------------------------------
STATIC FUNCTION _cre_exp_tbls( use_path )

   LOCAL _cre

   IF use_path == NIL
      use_path := my_home()
   ENDIF

   // provjeri da li postoji direktorij, pa ako ne - kreiraj
   _dir_create( use_path )

   // tabela kalk
   O_KALK
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_kalk" ) from ( my_home() + "struct" )

   // tabela doks
   O_KALK_DOKS
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_doks" ) from ( my_home() + "struct" )

   // tabela roba
   O_ROBA
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_roba" ) from ( my_home() + "struct" )

   // tabela partn
   O_PARTN
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_partn" ) from ( my_home() + "struct" )

   // tabela konta
   O_KONTO
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_konto" ) from ( my_home() + "struct" )

   // tabela sifk
   O_SIFK
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_sifk" ) from ( my_home() + "struct" )

   // tabela sifv
   O_SIFV
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_sifv" ) from ( my_home() + "struct" )

   RETURN


// ----------------------------------------------------
// otvaranje potrebnih tabela za prenos
// ----------------------------------------------------
STATIC FUNCTION _o_tables()

   O_KALK
   O_KALK_DOKS
   O_SIFK
   O_SIFV
   O_KONTO
   O_PARTN
   O_ROBA

   RETURN


// ----------------------------------------------------
// otvranje export tabela
// ----------------------------------------------------
STATIC FUNCTION _o_exp_tables( use_path, from_fmk )

   LOCAL _dbf_name

   IF ( use_path == NIL )
      use_path := my_home()
   ENDIF

   IF ( from_fmk == NIL )
      from_fmk := .F.
   ENDIF

   log_write( "otvaram kalk tabele importa i pravim indekse...", 9 )

   // zatvori sve prije otvaranja ovih tabela
   my_close_all_dbf()

   _dbf_name := "e_kalk.dbf"
   IF from_fmk
      _dbf_name := Upper( _dbf_name )
   ENDIF

   // otvori kalk tabelu
   SELECT ( F_TMP_E_KALK )
   my_use_temp( "E_KALK", use_path + _dbf_name, .F., .T. )
   INDEX on ( idfirma + idvd + brdok ) TAG "1"

   log_write( "otvorio i indeksirao: " + use_path + _dbf_name, 5 )

   _dbf_name := "e_doks.dbf"
   IF from_fmk
      _dbf_name := Upper( _dbf_name )
   ENDIF

   // otvori doks tabelu
   SELECT ( F_TMP_E_DOKS )
   my_use_temp( "E_DOKS", use_path + _dbf_name, .F., .T. )
   INDEX on ( idfirma + idvd + brdok ) TAG "1"

   log_write( "otvorio i indeksirao: " + use_path + _dbf_name, 5 )

   _dbf_name := "e_roba.dbf"
   IF from_fmk
      _dbf_name := Upper( _dbf_name )
   ENDIF

   // otvori roba tabelu
   SELECT ( F_TMP_E_ROBA )
   my_use_temp( "E_ROBA", use_path + _dbf_name, .F., .T. )
   INDEX on ( id ) TAG "ID"

   _dbf_name := "e_partn.dbf"
   IF from_fmk
      _dbf_name := Upper( _dbf_name )
   ENDIF

   // otvori partn tabelu
   SELECT ( F_TMP_E_PARTN )
   my_use_temp( "E_PARTN", use_path + _dbf_name, .F., .T. )
   INDEX on ( id ) TAG "ID"

   _dbf_name := "e_konto.dbf"
   IF from_fmk
      _dbf_name := Upper( _dbf_name )
   ENDIF

   // otvori konto tabelu
   SELECT ( F_TMP_E_KONTO )
   my_use_temp( "E_KONTO", use_path + _dbf_name, .F., .T. )
   INDEX on ( id ) TAG "ID"

   _dbf_name := "e_sifk.dbf"
   IF from_fmk
      _dbf_name := Upper( _dbf_name )
   ENDIF

   // otvori konto sifk
   SELECT ( F_TMP_E_SIFK )
   my_use_temp( "E_SIFK", use_path + _dbf_name, .F., .T. )
   INDEX on ( id + sort + naz ) TAG "ID"
   INDEX on ( id + oznaka ) TAG "ID2"

   _dbf_name := "e_sifv.dbf"
   IF from_fmk
      _dbf_name := Upper( _dbf_name )
   ENDIF

   // otvori konto tabelu
   SELECT ( F_TMP_E_SIFV )
   my_use_temp( "E_SIFV", use_path + _dbf_name, .F., .T. )
   INDEX on ( id + oznaka + idsif + naz ) TAG "ID"
   INDEX on ( id + idsif ) TAG "IDIDSIF"

   log_write( "otvorene sve import tabele i indeksirane...", 9 )

   RETURN
