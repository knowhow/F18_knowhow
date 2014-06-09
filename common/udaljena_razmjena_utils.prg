/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"




// --------------------------------------------
// promjena privilegija fajlova
// --------------------------------------------
FUNCTION set_file_access( file_path, mask )

   LOCAL _ret := .T.
   PRIVATE _cmd

   IF file_path == NIL
      file_path := ""
   ENDIF

   IF mask == NIL
      mask := ""
   ENDIF

   _cmd := "chmod ugo+w " + file_path + mask + "*.*"

   run &_cmd

   RETURN _ret


// -----------------------------------------
// otvara listu fajlova za import
// vraca naziv fajla za import
// -----------------------------------------
FUNCTION get_import_file( modul, import_dbf_path )

   LOCAL _file
   LOCAL _filter

   IF modul == NIL
      modul := "kalk"
   ENDIF

   _filter := AllTrim( modul ) + "*.*"

   IF _gFList( _filter, import_dbf_path, @_file ) == 0
      _file := ""
   ENDIF

   RETURN _file


// ----------------------------------------------------------------
// update tabele konto na osnovu pomocne tabele
// ----------------------------------------------------------------
FUNCTION update_table_konto( zamjena_sifre, fmk_import )

   LOCAL _app_rec
   LOCAL _sif_exist := .T.

   IF fmk_import == NIL
      fmk_import := .F.
   ENDIF

   f18_lock_tables( { "konto" } )
   sql_table_update( nil, "BEGIN" )

   SELECT e_konto
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      _app_rec := dbf_get_rec()

      IF fmk_import
         // uskladi strukture
         update_rec_konto_struct( @_app_rec )
      ENDIF

      SELECT konto
      hseek _app_rec[ "id" ]

      _sif_exist := .T.
      IF !Found()
         _sif_exist := .F.
      ENDIF

      IF !_sif_exist .OR. ( _sif_exist .AND. zamjena_sifre == "D" )

         @ m_x + 3, m_y + 2 SAY "import partn id: " + _app_rec[ "id" ] + " : " + PadR( _app_rec[ "naz" ], 20 )

         SELECT konto

         IF !_sif_exist
            APPEND BLANK
         ENDIF

         update_rec_server_and_dbf( "konto", _app_rec, 1, "CONT" )

      ENDIF

      SELECT e_konto
      SKIP

   ENDDO

   sql_table_update( nil, "END" )
   f18_free_tables( { "konto" } )

   RETURN



// -----------------------------------------------------------
// update tabele partnera na osnovu pomocne tabele
// -----------------------------------------------------------
FUNCTION update_table_partn( zamjena_sifre, fmk_import )

   LOCAL _app_rec
   LOCAL _sif_exist := .T.

   IF fmk_import == NIL
      fmk_import := .F.
   ENDIF

   f18_lock_tables( { "partn" } )
   sql_table_update( nil, "BEGIN" )

   SELECT e_partn
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      _app_rec := dbf_get_rec()

      IF fmk_import
         // uskladi strukture
         update_rec_partn_struct( @_app_rec )
      ENDIF

      SELECT partn
      hseek _app_rec[ "id" ]

      _sif_exist := .T.
      IF !Found()
         _sif_exist := .F.
      ENDIF

      IF !_sif_exist .OR. ( _sif_exist .AND. zamjena_sifre == "D" )

         @ m_x + 3, m_y + 2 SAY "import partn id: " + _app_rec[ "id" ] + " : " + PadR( _app_rec[ "naz" ], 20 )

         SELECT partn

         IF !_sif_exist
            APPEND BLANK
         ENDIF

         update_rec_server_and_dbf( "partn", _app_rec, 1, "CONT" )
      ENDIF

      SELECT e_partn
      SKIP

   ENDDO

   sql_table_update( nil, "END" )
   f18_free_tables( { "partn" } )

   RETURN



// update podataka u tabelu robe
FUNCTION update_table_roba( zamjena_sifre, fmk_import )

   LOCAL _app_rec
   LOCAL _sif_exist := .T.

   IF fmk_import == NIL
      fmk_import := .F.
   ENDIF

   f18_lock_tables( { "roba" } )
   sql_table_update( nil, "BEGIN" )

   // moramo ziknuti i robu ako fali !
   SELECT e_roba
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      _app_rec := dbf_get_rec()

      IF fmk_import
         // uskladi strukture tabela
         update_rec_roba_struct( @_app_rec )
      ENDIF

      SELECT roba
      hseek _app_rec[ "id" ]

      _sif_exist := .T.
      IF !Found()
         _sif_exist := .F.
      ENDIF

      IF !_sif_exist .OR. ( _sif_exist .AND. zamjena_sifre == "D" )

         @ m_x + 3, m_y + 2 SAY "import roba id: " + _app_rec[ "id" ] + " : " + PadR( _app_rec[ "naz" ], 20 )

         SELECT roba

         IF !_sif_exist
            APPEND BLANK
         ENDIF

         update_rec_server_and_dbf( "roba", _app_rec, 1, "CONT" )

      ENDIF

      SELECT e_roba
      SKIP

   ENDDO

   sql_table_update( nil, "END" )
   f18_free_tables( { "roba" } )

   RETURN



STATIC FUNCTION update_rec_sifk_struct( rec )

   LOCAL _no_field
   LOCAL _struct := {}

   IF hb_HHasKey( rec, "unique" )
      rec[ "f_unique" ] := rec[ "unique" ]
   ENDIF

   IF hb_HHasKey( rec, "decimal" )
      rec[ "f_decimal" ] := rec[ "decimal" ]
   ENDIF

   IF hb_HHasKey( rec, "match_code" )
      rec[ "match_code" ] := ""
   ENDIF

   hb_HDel( rec, "unique" )
   hb_HDel( rec, "decimal" )

   RETURN



// --------------------------------------------------
// update strukture zapisa tabele konto
// --------------------------------------------------
STATIC FUNCTION update_rec_konto_struct( rec )

   LOCAL _no_field
   LOCAL _struct := {}

   // moguca nepostojeca polja tabele roba

   AAdd( _struct, "match_code" )
   AAdd( _struct, "pozbilu" )
   AAdd( _struct, "pozbils" )

   FOR EACH _no_field in _struct
      IF ! hb_HHasKey( rec, _no_field )
         rec[ _no_field ] := nil
      ENDIF
   NEXT

   RETURN



// --------------------------------------------------
// update strukture zapisa tabele partn
// --------------------------------------------------
STATIC FUNCTION update_rec_partn_struct( rec )

   LOCAL _no_field
   LOCAL _struct := {}

   // moguca nepostojeca polja tabele roba
   AAdd( _struct, "match_code" )

   FOR EACH _no_field in _struct
      IF ! hb_HHasKey( rec, _no_field )
         rec[ _no_field ] := nil
      ENDIF
   NEXT

   // pobrisi sljedece clanove...
   hb_HDel( rec, "brisano" )
   hb_HDel( rec, "rejon" )

   RETURN



// --------------------------------------------------
// update strukture zapisa tabele roba
// --------------------------------------------------
STATIC FUNCTION update_rec_roba_struct( rec )

   LOCAL _no_field
   LOCAL _struct := {}

   // moguca nepostojeca polja tabele roba
   AAdd( _struct, "idkonto" )
   AAdd( _struct, "sifradob" )
   AAdd( _struct, "strings" )
   AAdd( _struct, "k7" )
   AAdd( _struct, "k8" )
   AAdd( _struct, "k9" )
   AAdd( _struct, "mink" )
   AAdd( _struct, "fisc_plu" )
   AAdd( _struct, "match_code" )
   AAdd( _struct, "mpc4" )
   AAdd( _struct, "mpc5" )
   AAdd( _struct, "mpc6" )
   AAdd( _struct, "mpc7" )
   AAdd( _struct, "mpc8" )
   AAdd( _struct, "mpc9" )

   FOR EACH _no_field in _struct
      IF ! hb_HHasKey( rec, _no_field )
         rec[ _no_field ] := nil
      ENDIF
   NEXT

   // pobrisi sljedece clanove...
   hb_HDel( rec, "carina" )
   hb_HDel( rec, "_m1_" )
   hb_HDel( rec, "brisano" )

   RETURN



// ---------------------------------------------------------
// update tabela sifk, sifv na osnovu pomocnih tabela
// ---------------------------------------------------------
FUNCTION update_sifk_sifv( fmk_import )

   LOCAL _app_rec

   IF fmk_import == NIL
      fmk_import := .F.
   ENDIF

   SELECT e_sifk
   SET ORDER TO TAG "ID2"
   GO TOP

   DO WHILE !Eof()

      _app_rec := dbf_get_rec()

      IF fmk_import
         update_rec_sifk_struct( @_app_rec )
      ENDIF

      SELECT sifk
      SET ORDER TO TAG "ID2"
      GO TOP
      SEEK _app_rec[ "id" ] + _app_rec[ "oznaka" ]

      IF !Found()
         APPEND BLANK
      ENDIF

      @ m_x + 3, m_y + 2 SAY "import sifk id: " + _app_rec[ "id" ] + ", oznaka: " + _app_rec[ "oznaka" ]

      update_rec_server_and_dbf( "sifk", _app_rec, 1, "FULL" )

      SELECT e_sifk
      SKIP

   ENDDO

   SELECT e_sifv
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      _app_rec := dbf_get_rec()
      SELECT sifv
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK _app_rec[ "id" ] + _app_rec[ "oznaka" ] + _app_rec[ "idsif" ] + _app_rec[ "naz" ]

      IF !Found()
         APPEND BLANK
      ENDIF

      @ m_x + 3, m_y + 2 SAY "import sifv id: " + _app_rec[ "id" ] + ", oznaka: " + _app_rec[ "oznaka" ] + ", sifra: " + _app_rec[ "idsif" ]

      update_rec_server_and_dbf( "sifv", _app_rec, 1, "FULL" )

      SELECT e_sifv
      SKIP

   ENDDO

   RETURN


// ---------------------------------------------
// kreiraj direktorij ako ne postoji
// ---------------------------------------------
FUNCTION _dir_create( use_path )

   LOCAL _ret := .T.

   // _lokacija := _path_quote( my_home() + "export" + SLASH )

   IF DirChange( use_path ) != 0
      _cre := MakeDir ( use_path )
      IF _cre != 0
         MsgBeep( "kreiranje " + use_path + " neuspjesno ?!" )
         log_write( "dircreate err:" + use_path, 7 )
         _ret := .F.
      ENDIF
   ENDIF

   RETURN _ret


// -------------------------------------------------
// brise zip fajl exporta
// -------------------------------------------------
FUNCTION delete_zip_files( zip_file )

   IF File( zip_file )
      FErase( zip_file )
   ENDIF

   RETURN



// ---------------------------------------------------
// brise temp fajlove razmjene
// ---------------------------------------------------
FUNCTION delete_exp_files( use_path, modul )

   LOCAL _files := _file_list( use_path, modul )
   LOCAL _file, _tmp

   MsgO( "Brisem tmp fajlove ..." )
   FOR EACH _file in _files
      IF File( _file )
         // pobrisi dbf fajl
         FErase( _file )
         // cdx takodjer ?
         _tmp := ImeDbfCDX( _file )
         FErase( _tmp )
         // fpt takodjer ?
         _tmp := StrTran( _file, ".dbf", ".fpt" )
         FErase( _tmp )
      ENDIF
   NEXT
   MsgC()

   RETURN


// -------------------------------------------------------
// da li postoji import fajl ?
// -------------------------------------------------------
FUNCTION import_file_exist( imp_file )

   LOCAL _ret := .T.

   IF ( imp_file == NIL )
      imp_file := __import_dbf_path + __import_zip_name
   ENDIF

   IF !File( imp_file )
      _ret := .F.
   ENDIF

   RETURN _ret


// --------------------------------------------
// vraca naziv zip fajla
// --------------------------------------------
FUNCTION zip_name( modul, export_dbf_path )

   LOCAL _file
   LOCAL _ext := ".zip"
   LOCAL _count := 1
   LOCAL _exist := .T.

   IF modul == NIL
      modul := "kalk"
   ENDIF

   IF export_dbf_path == NIL
      export_dbf_path := my_home()
   ENDIF

   modul := AllTrim( Lower( modul ) )

   _file := export_dbf_path + modul + "_exp_" + PadL( AllTrim( Str( _count ) ), 2, "0" ) + _ext

   IF File( _file )

      // generisi nove nazive fajlova
      DO WHILE _exist

         ++ _count
         _file := export_dbf_path + modul + "_exp_" + PadL( AllTrim( Str( _count ) ), 2, "0" ) + _ext

         IF !File( _file )
            _exist := .F.
            EXIT
         ENDIF

      ENDDO

   ENDIF

   RETURN _file



// ----------------------------------------------------
// vraca listu fajlova koji se koriste kod prenosa
// ----------------------------------------------------
STATIC FUNCTION _file_list( use_path, modul )

   LOCAL _a_files := {}

   IF modul == NIL
      modul := "kalk"
   ENDIF

   DO CASE

   CASE modul == "kalk"

      AAdd( _a_files, use_path + "e_kalk.dbf" )
      AAdd( _a_files, use_path + "e_doks.dbf" )
      AAdd( _a_files, use_path + "e_roba.dbf" )
      AAdd( _a_files, use_path + "e_partn.dbf" )
      AAdd( _a_files, use_path + "e_konto.dbf" )
      AAdd( _a_files, use_path + "e_sifk.dbf" )
      AAdd( _a_files, use_path + "e_sifv.dbf" )

   CASE modul == "fakt"

      AAdd( _a_files, use_path + "e_fakt.dbf" )
      AAdd( _a_files, use_path + "e_fakt.fpt" )
      AAdd( _a_files, use_path + "e_doks.dbf" )
      AAdd( _a_files, use_path + "e_doks2.dbf" )
      AAdd( _a_files, use_path + "e_roba.dbf" )
      AAdd( _a_files, use_path + "e_partn.dbf" )
      AAdd( _a_files, use_path + "e_sifk.dbf" )
      AAdd( _a_files, use_path + "e_sifv.dbf" )


   CASE modul == "fin"

      AAdd( _a_files, use_path + "e_suban.dbf" )
      AAdd( _a_files, use_path + "e_sint.dbf" )
      AAdd( _a_files, use_path + "e_anal.dbf" )
      AAdd( _a_files, use_path + "e_nalog.dbf" )
      AAdd( _a_files, use_path + "e_partn.dbf" )
      AAdd( _a_files, use_path + "e_konto.dbf" )
      AAdd( _a_files, use_path + "e_sifk.dbf" )
      AAdd( _a_files, use_path + "e_sifv.dbf" )

   ENDCASE

   RETURN _a_files



// ------------------------------------------
// kompresuj fajlove i vrati path
// ------------------------------------------
FUNCTION _compress_files( modul, export_dbf_path )

   LOCAL _files
   LOCAL _error
   LOCAL _zip_path, _zip_name, _file
   LOCAL __path, __name, __ext

   // lista fajlova za kompresovanje
   _files := _file_list( export_dbf_path, modul )

   _file := zip_name( modul, export_dbf_path )

   hb_FNameSplit( _file, @__path, @__name, @__ext )

   _zip_path := __path
   _zip_name := __name + __ext

   // unzipuj fajlove
   _error := zip_files( _zip_path, _zip_name, _files )

   RETURN _error



// ------------------------------------------
// dekompresuj fajlove i vrati path
// ------------------------------------------
FUNCTION _decompress_files( imp_file, import_dbf_path, import_zip_name )

   LOCAL _zip_name, _zip_path
   LOCAL _error
   LOCAL __name, __path, __ext

   IF ( imp_file == NIL )

      _zip_path := import_dbf_path
      _zip_name := import_zip_name

   ELSE

      hb_FNameSplit( imp_file, @__path, @__name, @__ext )
      _zip_path := __path
      _zip_name := __name + __ext

   ENDIF

   log_write( "dekompresujem fajl:" + _zip_path + _zip_name, 7 )

   // unzipuj fajlove
   _error := unzip_files( _zip_path, _zip_name, import_dbf_path )

   RETURN _error


// --------------------------------------------------
// popunjava sifrarnike sifk, sifv
// --------------------------------------------------
FUNCTION _fill_sifk( sifrarnik, id_sif )

   LOCAL _rec

   PushWa()

   SELECT e_sifk

   IF RecCount2() == 0

      O_SIFK
      SELECT sifk
      SET ORDER TO TAG "ID"
      GO TOP

      DO WHILE !Eof()
         _rec := dbf_get_rec()
         SELECT e_sifk
         APPEND BLANK
         dbf_update_rec( _rec )
         SELECT sifk
         SKIP
      ENDDO

   ENDIF

   use_sql_sifv()
   // INDEX ON ID + IDSIF TAG IDIDSIF TO "sifv"

   SELECT sifv
   SET ORDER TO TAG "IDIDSIF"

   SEEK PadR( sifrarnik, 8 ) + id_sif

   DO WHILE !Eof() .AND. field->id = PadR( sifrarnik, 8 ) ;
         .AND. field->idsif = PadR( id_sif, Len( id_sif ) )

      _rec := dbf_get_rec()
      SELECT e_sifv
      APPEND BLANK
      dbf_update_rec( _rec )
      SELECT sifv
      SKIP
   ENDDO

   PopWa()

   RETURN
