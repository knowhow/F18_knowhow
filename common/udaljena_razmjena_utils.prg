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

#include "f18.ch"


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

   IF get_file_list( _filter, import_dbf_path, @_file ) == 0
      _file := ""
   ENDIF

   RETURN _file


/*
 update tabele konto na osnovu pomocne tabele
*/

FUNCTION update_table_konto( lZamijenitiSifre )

   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL hRec
   LOCAL _sif_exist := .T.
   LOCAL hParams

   run_sql_query( "BEGIN" )
   IF !f18_lock_tables( { "konto" }, .T. )
      run_sql_query( "ROLLBACK" )
      RETURN lRet
   ENDIF

   SELECT e_konto
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      hRec := dbf_get_rec()
      update_rec_konto_struct( @hRec )

      select_o_konto( hRec[ "id" ] )

      _sif_exist := .T.
      IF !Found()
         _sif_exist := .F.
      ENDIF

      IF !_sif_exist .OR. ( _sif_exist .AND. lZamijenitiSifre == "D" )

         @ m_x + 3, m_y + 2 SAY "import konto id: " + hRec[ "id" ] + " : " + PadR( hRec[ "naz" ], 20 )

         SELECT konto
         IF !_sif_exist
            APPEND BLANK
         ENDIF

         lOk := update_rec_server_and_dbf( "konto", hRec, 1, "CONT" )

         IF !lOk .AND. !_sif_exist
            delete_with_rlock()
         ENDIF

      ENDIF

      IF !lOk
         EXIT
      ENDIF

      SELECT e_konto
      SKIP

   ENDDO

   IF lOk
      lRet := .T.
      hParams := hb_Hash()
      hParams[ "unlock" ] :=  { "konto" }
      run_sql_query( "COMMIT", hParams )

   ELSE
      run_sql_query( "ROLLBACK" )
   ENDIF

   RETURN lRet



/*
   update tabele partnera na osnovu pomocne tabele
*/

FUNCTION update_table_partn( lZamijenitiSifre )

   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL hRec
   LOCAL _sif_exist := .T.
   LOCAL hParams

   run_sql_query( "BEGIN" )
   IF !f18_lock_tables( { "partn" }, .T. )
      run_sql_query( "ROLLBACK" )
      RETURN lRet
   ENDIF

   SELECT e_partn
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      hRec := dbf_get_rec()

      update_rec_partn_struct( @hRec )

      select_o_partner( hRec[ "id" ] )

      _sif_exist := .T.
      IF !Found()
         _sif_exist := .F.
      ENDIF

      IF !_sif_exist .OR. ( _sif_exist .AND. lZamijenitiSifre == "D" )

         @ m_x + 3, m_y + 2 SAY "import partn id: " + hRec[ "id" ] + " : " + PadR( hRec[ "naz" ], 20 )

         SELECT partn

         IF !_sif_exist
            APPEND BLANK
         ENDIF

         lOk := update_rec_server_and_dbf( "partn", hRec, 1, "CONT" )

         IF !lOk .AND. !_sif_exist
            delete_with_rlock()
         ENDIF

      ENDIF

      IF !lOk
         EXIT
      ENDIF

      SELECT e_partn
      SKIP

   ENDDO

   IF lOk
      lRet := .T.
      hParams := hb_Hash()
      hParams[ "unlock" ] :=  { "partn" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
   ENDIF

   RETURN lRet



FUNCTION update_table_roba( lZamijenitiSifre )

   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL hRec
   LOCAL _sif_exist := .T.
   LOCAL hParams

   run_sql_query( "BEGIN" )
   IF !f18_lock_tables( { "roba" }, .T. )
      run_sql_query( "ROLLBACK" )
      RETURN lRet
   ENDIF

   SELECT e_roba
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof()

      hRec := dbf_get_rec()

      update_rec_roba_struct( @hRec )

      SELECT roba
      HSEEK hRec[ "id" ]

      _sif_exist := .T.
      IF !Found()
         _sif_exist := .F.
      ENDIF

      IF !_sif_exist .OR. ( _sif_exist .AND. lZamijenitiSifre == "D" )

         @ m_x + 3, m_y + 2 SAY "import roba id: " + hRec[ "id" ] + " : " + PadR( hRec[ "naz" ], 20 )

         SELECT roba

         IF !_sif_exist
            APPEND BLANK
         ENDIF

         lOk := update_rec_server_and_dbf( "roba", hRec, 1, "CONT" )

         IF !lOk .AND. !_sif_exist
            delete_with_rlock()
         ENDIF

      ENDIF

      IF !lOk
         EXIT
      ENDIF

      SELECT e_roba
      SKIP

   ENDDO

   IF lOk
      lRet := .T.
      hParams := hb_Hash()
      hParams[ "unlock" ] :=  { "roba" }
      run_sql_query( "COMMIT", hParams )

   ELSE
      run_sql_query( "ROLLBACK" )
   ENDIF

   RETURN lRet



STATIC FUNCTION update_rec_sifk_struct( hRec )

   IF hb_HHasKey( hRec, "unique" )
      hRec[ "f_unique" ] := hRec[ "unique" ]
      hb_HDel( hRec, "unique" )
   ENDIF

   IF hb_HHasKey( hRec, "decimal" )
      hRec[ "f_decimal" ] := hRec[ "decimal" ]
      hb_HDel( hRec, "decimal" )
   ENDIF

   IF !hb_HHasKey( hRec, "match_code" ) .OR. hRec[ "match_code" ] == NIL
      hRec[ "match_code" ] := PadR( "", 10 )
   ENDIF

   RETURN .T.



STATIC FUNCTION update_rec_konto_struct( hRec )

   LOCAL _struct := {}

   AAdd( _struct, "match_code" )
   AAdd( _struct, "pozbilu" )
   AAdd( _struct, "pozbils" )

   dodaj_u_hash_matricu( _struct, @hRec )

   RETURN .T.




STATIC FUNCTION dodaj_u_hash_matricu( polja, hash )

   LOCAL _field

   IF polja == NIL .OR. Len( polja ) == 0
      RETURN .F.
   ENDIF

   FOR EACH _field in polja
      IF ! hb_HHasKey( hash, _field )
         hash[ _field ] := NIL
      ENDIF
   NEXT

   RETURN .T.




STATIC FUNCTION brisi_iz_hash_matrice( polja, hash )

   LOCAL _field

   IF polja == NIL .OR. Len( polja ) == 0
      RETURN .F.
   ENDIF

   FOR EACH _field in polja
      IF hb_HHasKey( hash, _field )
         hb_HDel( hash, _field )
      ENDIF
   NEXT

   RETURN .T.




// --------------------------------------------------
// update strukture zapisa tabele partn
// --------------------------------------------------
STATIC FUNCTION update_rec_partn_struct( hRec )

   LOCAL _add := {}
   LOCAL _remove := {}

   AAdd( _add, "match_code" )
   dodaj_u_hash_matricu( _add, @hRec )

   AAdd( _remove, "brisano" )
   AAdd( _remove, "rejon" )
   brisi_iz_hash_matrice( _remove, @hRec )

   RETURN .T.



// --------------------------------------------------
// update strukture zapisa tabele roba
// --------------------------------------------------
STATIC FUNCTION update_rec_roba_struct( hRec )

   LOCAL _add := {}
   LOCAL _remove := {}

   AAdd( _add, "idkonto" )
   AAdd( _add, "sifradob" )
   AAdd( _add, "strings" )
   AAdd( _add, "k7" )
   AAdd( _add, "k8" )
   AAdd( _add, "k9" )
   AAdd( _add, "mink" )
   AAdd( _add, "fisc_plu" )
   AAdd( _add, "match_code" )
   AAdd( _add, "mpc4" )
   AAdd( _add, "mpc5" )
   AAdd( _add, "mpc6" )
   AAdd( _add, "mpc7" )
   AAdd( _add, "mpc8" )
   AAdd( _add, "mpc9" )

   dodaj_u_hash_matricu( _add, @hRec )

   AAdd( _remove, "carina" )
   AAdd( _remove, "_m1_" )
   AAdd( _remove, "brisano" )

   brisi_iz_hash_matrice( _remove, @hRec )

   RETURN .T.



FUNCTION update_sifk_sifv( lFullTransaction )

   LOCAL hRec, cTran

   hb_default( @lFullTransaction, .T. )

   IF lFullTransaction
      cTran := "FULL"
   ELSE
      cTran := "CONT"
   ENDIF

   SELECT e_sifk
   SET ORDER TO TAG "ID2"
   GO TOP

   DO WHILE !Eof()

      hRec := dbf_get_rec( .T. ) // konvertuj stringove u utf8
      update_rec_sifk_struct( @hRec )

      SELECT sifk
      SET ORDER TO TAG "ID2"
      GO TOP
      SEEK hRec[ "id" ] + hRec[ "oznaka" ]

      IF !Found()
         APPEND BLANK
      ENDIF

      @ m_x + 3, m_y + 2 SAY "import sifk id: " + hRec[ "id" ] + ", oznaka: " + hRec[ "oznaka" ]

      update_rec_server_and_dbf( "sifk", hRec, 1, cTran )

      SELECT e_sifk
      SKIP

   ENDDO

   SELECT e_sifv
   SET ORDER TO TAG "ID"
   GO TOP

   DO WHILE !Eof() // brisanje sifv
      hRec := dbf_get_rec( .T. ) // konvertuj stringove u utf8
      SELECT sifv
      brisi_sifv_item( hRec[ "id" ], hRec[ "oznaka" ], hRec[ "idsif" ], cTran )
      SELECT e_sifv
      SKIP
   ENDDO

   SELECT e_sifv
   GO TOP
   DO WHILE !Eof() // e_sifv -> sifv

      hRec := dbf_get_rec( .T. ) // konvertuj stringove u utf8
      use_sql_sifv( hRec[ "id" ], hRec[ "oznaka" ], hRec[ "idsif" ] )
      GO TOP
      IF Eof()
         APPEND BLANK
         @ m_x + 3, m_y + 2 SAY "import sifv id: " + hRec[ "id" ] + ", oznaka: " + hRec[ "oznaka" ] + ", sifra: " + hRec[ "idsif" ]
         update_rec_server_and_dbf( "sifv", hRec, 1, cTran )
      ENDIF

      SELECT e_sifv
      SKIP

   ENDDO

   RETURN .T.



FUNCTION direktorij_kreiraj_ako_ne_postoji( use_path )

   LOCAL _ret := .T.

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

   RETURN .T.


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


/*
  popunjava sifrarnike e_sifk, e_sifv
*/

FUNCTION fill_sifk_sifv( cSifarnik, cIdSifra )

   LOCAL _rec

   PushWA()

   SELECT e_sifk

   IF RecCount2() == 0

      o_sifk()
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

   use_sql_sifv( PadR( cSifarnik, 8 ), "*", cIdSifra )
   GO TOP
   DO WHILE !Eof() .AND. field->id == PadR( cSifarnik, 8 ) .AND.    field->idsif == PadR( cIdSifra, 15 )

      _rec := dbf_get_rec()
      SELECT e_sifv
      APPEND BLANK
      dbf_update_rec( _rec )
      SELECT sifv
      SKIP
   ENDDO

   PopWa()

   RETURN .T.
