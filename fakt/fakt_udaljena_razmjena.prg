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


#include "fakt.ch"

STATIC __import_dbf_path
STATIC __export_dbf_path
STATIC __import_zip_name
STATIC __export_zip_name


// --------------------------------------------------------------------
// fakt: udaljena razmjena podataka modul FAKT->FAKT
// --------------------------------------------------------------------
FUNCTION fakt_udaljena_razmjena_podataka()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   __import_dbf_path := ""
   __export_dbf_path := my_home() + "export_dbf" + SLASH
   __import_zip_name := "fakt_exp.zip"
   __export_zip_name := "fakt_exp.zip"

   // kreiraj ove direktorije odmah
   _dir_create( __export_dbf_path )

   AAdd( _opc, "1. => export podataka               " )
   AAdd( _opcexe, {|| _fakt_export() } )
   AAdd( _opc, "2. <= import podataka    " )
   AAdd( _opcexe, {|| _fakt_import() } )

   f18_menu( "razmjena", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN


// ----------------------------------------
// export podataka modula FAKT
// ----------------------------------------
STATIC FUNCTION _fakt_export()

   LOCAL _vars := hb_Hash()
   LOCAL _exported_rec
   LOCAL _error
   LOCAL _a_data := {}

   // uslovi exporta
   IF !_vars_export( @_vars )
      RETURN
   ENDIF

   // pobrisi u folderu tmp fajlove ako postoje
   delete_exp_files( __export_dbf_path, "fakt" )

   // exportuj podatake
   _exported_rec := __export( _vars, @_a_data )

   // zatvori sve tabele prije operacije pakovanja
   my_close_all_dbf()

   // arhiviraj podatke
   IF _exported_rec > 0

      // kompresuj ih u zip fajl za prenos
      _error := _compress_files( "fakt", __export_dbf_path )

      // sve u redu
      IF _error == 0

         // pobrisi fajlove razmjene
         delete_exp_files( __export_dbf_path, "fakt" )

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
// import podataka modula FAKT
// ----------------------------------------
STATIC FUNCTION _fakt_import()

   LOCAL _imported_rec
   LOCAL _vars := hb_Hash()
   LOCAL _imp_file
   LOCAL _imp_path := fetch_metric( "fakt_import_path", my_user(), PadR( "", 300 ) )
   LOCAL _a_data := {}

   Box(, 1, 70 )
   @ m_x + 1, m_y + 2 SAY "import path:" GET _imp_path PICT "@S50"
   READ
   BoxC()
	
   IF LastKey() == K_ESC
      RETURN
   endif

   // snimi u parametre
   __import_dbf_path := AllTrim( _imp_path )
   set_metric( "fakt_import_path", my_user(), _imp_path )

   // import fajl iz liste
   _imp_file := get_import_file( "fakt", __import_dbf_path )

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
   delete_exp_files( __import_dbf_path, "fakt" )

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


// -------------------------------------------------------------
// -------------------------------------------------------------
FUNCTION print_imp_exp_report( data )

   LOCAL _i, _cnt
   LOCAL _line
   LOCAL _x_docs, _import_docs, _delete_docs, _exp_docs
   LOCAL _descr

   // struktura data
   // data[1] = opis
   // data[2] = broj dokumenta
   // data[3] = idpartner
   // data[4] = idkonto
   // data[5] = opis partner
   // data[6] = iznos
   // data[7] = datum dokumenta

   START PRINT CRET

   ?

   P_10CPI
   P_COND

   ? "REZUTATI OPERACIJE IMPORT/EXPORT PODATAKA"
   ?

   _line := Replicate( "-", 5 )
   _line += Space( 1 )
   _line += Replicate( "-", 10 )
   _line += Space( 1 )
   _line += Replicate( "-", 16 )
   _line += Space( 1 )
   _line += Replicate( "-", 8 )
   _line += Space( 1 )
   _line += Replicate( "-", 30 )
   _line += Space( 1 )
   _line += Replicate( "-", 12 )

   ? _line
   ? PadR( "R.br", 5 ), PadC( "Operacija", 10 ), PadC( "Dokument", 16 ), PadC( "Datum", 8 ), PadR( "Partner opis", 30 ), PadC( "Iznos", 12 )
   ? _line

   _cnt := 0

   _x_docs := 0
   _import_docs := 0
   _delete_docs := 0
   _exp_docs := 0

   FOR _i := 1 TO Len( data )

      _descr := AllTrim( DATA[ _i, 1 ] )

      IF _descr == "x"
         ++ _x_docs
      ELSEIF _descr == "import"
         ++ _import_docs
      ELSEIF _descr == "export"
         ++ _exp_docs
      ELSEIF _descr == "delete"
         ++ _delete_docs
      ENDIF

      // r.br
      ? PadL( AllTrim( Str( ++_cnt ) ), 4 ) + "."

      // opis
      @ PRow(), PCol() + 1 SAY PadL( _descr, 10 )

      // dokument
      @ PRow(), PCol() + 1 SAY PadR( DATA[ _i, 2 ], 16 )

      // datum
      @ PRow(), PCol() + 1 SAY DToC( DATA[ _i, 7 ] )

      // partner
      @ PRow(), PCol() + 1 SAY PadR( DATA[ _i, 5 ], 27 ) + "..."

      // iznos
      @ PRow(), PCol() + 1 SAY Str( DATA[ _i, 6 ], 12, 2 )


   NEXT


   ? _line

   IF _import_docs > 0
      ? "Broj importovanih dokumenta: " + AllTrim( Str( _import_docs ) )
   ENDIF

   IF _exp_docs > 0
      ? "Broj exportovanih dokumenta: " + AllTrim( Str( _exp_docs ) )
   ENDIF

   IF _delete_docs > 0
      ? "    Broj brisanih dokumenta: " + AllTrim( Str( _delete_docs ) )
   ENDIF

   IF _x_docs > 0
      ? "  Broj prekocenih dokumenta: " + AllTrim( Str( _x_docs ) )
   ENDIF

   ? _line


   FF
   END PRINT

   RETURN



// -------------------------------------------
// uslovi exporta dokumenta
// -------------------------------------------
STATIC FUNCTION _vars_export( vars )

   LOCAL _ret := .F.
   LOCAL _dat_od := fetch_metric( "fakt_export_datum_od", my_user(), Date() - 30 )
   LOCAL _dat_do := fetch_metric( "fakt_export_datum_do", my_user(), Date() )
   LOCAL _rj := fetch_metric( "fakt_export_lista_rj", my_user(), PadR( "10;", 200 ) )
   LOCAL _vrste_dok := fetch_metric( "fakt_export_vrste_dokumenata", my_user(), PadR( "10;11;", 200 ) )
   LOCAL _br_dok := fetch_metric( "fakt_export_brojevi_dokumenata", my_user(), PadR( "", 300 ) )
   LOCAL _exp_sif := fetch_metric( "fakt_export_sifrarnik", my_user(), "D" )
   LOCAL _prim_sif := fetch_metric( "fakt_export_duzina_primarne_sifre", my_user(), 0 )
   LOCAL _exp_path := fetch_metric( "fakt_export_path", my_user(), PadR( "", 300 ) )
   LOCAL _prom_rj_src := Space( 2 )
   LOCAL _prom_rj_dest := Space( 2 )
   LOCAL _x := 1

   IF Empty( AllTrim( _exp_path ) )
      _exp_path := PadR( __export_dbf_path, 300 )
   ENDIF

   Box(, 13, 70 )

   @ m_x + _x, m_y + 2 SAY "*** Uslovi exporta dokumenata"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Vrste dokumenata:" GET _vrste_dok PICT "@S40"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Brojevi dokumenata:" GET _br_dok PICT "@S40"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Datumski period od" GET _dat_od
   @ m_x + _x, Col() + 1 SAY "do" GET _dat_do

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Uzeti u obzir sljedece rj:" GET _rj PICT "@S30"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Svoditi na primarnu sifru (duzina primarne sifre):" GET _prim_sif PICT "9"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Promjena radne jedinice" GET _prom_rj_src
   @ m_x + _x, Col() + 1 SAY "u" GET _prom_rj_dest

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

      set_metric( "fakt_export_datum_od", my_user(), _dat_od )
      set_metric( "fakt_export_datum_do", my_user(), _dat_do )
      set_metric( "fakt_export_lista_rj", my_user(), _rj )
      set_metric( "fakt_export_vrste_dokumenata", my_user(), _vrste_dok )
      set_metric( "fakt_export_sifrarnik", my_user(), _exp_sif )
      set_metric( "fakt_export_duzina_primarne_sifre", my_user(), _prim_sif )
      set_metric( "fakt_export_path", my_user(), _exp_path )
      set_metric( "fakt_export_brojevi_dokumenata", my_user(), _br_dok )

      // export path, set static var
      __export_dbf_path := AllTrim( _exp_path )

      vars[ "datum_od" ] := _dat_od
      vars[ "datum_do" ] := _dat_do
      vars[ "rj" ] := _rj
      vars[ "vrste_dok" ] := _vrste_dok
      vars[ "export_sif" ] := _exp_sif
      vars[ "prim_sif" ] := _prim_sif
      vars[ "rj_src" ] := _prom_rj_src
      vars[ "rj_dest" ] := _prom_rj_dest
      vars[ "brojevi_dok" ] := _br_dok

   ENDIF

   RETURN _ret



// -------------------------------------------
// uslovi importa dokumenta
// -------------------------------------------
STATIC FUNCTION _vars_import( vars )

   LOCAL _ret := .F.
   LOCAL _dat_od := fetch_metric( "fakt_import_datum_od", my_user(), CToD( "" ) )
   LOCAL _dat_do := fetch_metric( "fakt_import_datum_do", my_user(), CToD( "" ) )
   LOCAL _rj := fetch_metric( "fakt_import_lista_rj", my_user(), PadR( "", 200 ) )
   LOCAL _vrste_dok := fetch_metric( "fakt_import_vrste_dokumenata", my_user(), PadR( "", 200 ) )
   LOCAL _br_dok := fetch_metric( "fakt_import_brojevi_dokumenata", my_user(), PadR( "", 300 ) )
   LOCAL _zamjeniti_dok := fetch_metric( "fakt_import_zamjeniti_dokumente", my_user(), "N" )
   LOCAL _zamjeniti_sif := fetch_metric( "fakt_import_zamjeniti_sifre", my_user(), "N" )
   LOCAL _iz_fmk := fetch_metric( "fakt_import_iz_fmk", my_user(), "N" )
   LOCAL _imp_path := fetch_metric( "fakt_import_path", my_user(), PadR( "", 300 ) )
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

   @ m_x + _x, m_y + 2 SAY "Brojevi dokumenata (prazno-sve):" GET _br_dok PICT "@S30"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Datumski period od" GET _dat_od
   @ m_x + _x, Col() + 1 SAY "do" GET _dat_do

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Uzeti u obzir sljedece radne jedinice:" GET _rj PICT "@S30"

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

      set_metric( "fakt_import_datum_od", my_user(), _dat_od )
      set_metric( "fakt_import_datum_do", my_user(), _dat_do )
      set_metric( "fakt_import_lista_rj", my_user(), _rj )
      set_metric( "fakt_import_vrste_dokumenata", my_user(), _vrste_dok )
      set_metric( "fakt_import_zamjeniti_dokumente", my_user(), _zamjeniti_dok )
      set_metric( "fakt_import_zamjeniti_sifre", my_user(), _zamjeniti_sif )
      set_metric( "fakt_import_iz_fmk", my_user(), _iz_fmk )
      set_metric( "fakt_import_path", my_user(), _imp_path )
      set_metric( "fakt_import_brojevi_dokumenata", my_user(), _br_dok )

      // set static var
      __import_dbf_path := AllTrim( _imp_path )

      vars[ "datum_od" ] := _dat_od
      vars[ "datum_do" ] := _dat_do
      vars[ "rj" ] := _rj
      vars[ "vrste_dok" ] := _vrste_dok
      vars[ "zamjeniti_dokumente" ] := _zamjeniti_dok
      vars[ "zamjeniti_sifre" ] := _zamjeniti_sif
      vars[ "import_iz_fmk" ] := _iz_fmk
      vars[ "brojevi_dok" ] := _br_dok

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
   LOCAL _dat_od, _dat_do, _rj, _vrste_dok, _export_sif
   LOCAL _usl_rj, _usl_br_dok
   LOCAL _id_partn
   LOCAL _id_roba
   LOCAL _prim_sif
   LOCAL _rj_src, _rj_dest, _brojevi_dok
   LOCAL _change_rj := .F.
   LOCAL _detail_rec

   // uslovi za export ce biti...
   _dat_od := vars[ "datum_od" ]
   _dat_do := vars[ "datum_do" ]
   _rj := AllTrim( vars[ "rj" ] )
   _vrste_dok := AllTrim( vars[ "vrste_dok" ] )
   _export_sif := AllTrim( vars[ "export_sif" ] )
   _prim_sif := vars[ "prim_sif" ]
   _rj_src := vars[ "rj_src" ]
   _rj_dest := vars[ "rj_dest" ]
   _brojevi_dok := vars[ "brojevi_dok" ]

   // treba li mjenjati radne jedinice
   IF !Empty( _rj_src ) .AND. !Empty( _rj_dest )
      _change_rj := .T.
   ENDIF

   // kreiraj tabele exporta
   _cre_exp_tbls( __export_dbf_path )

   // otvori export tabele za pisanje podataka
   _o_exp_tables( __export_dbf_path )

   // otvori lokalne tabele za prenos
   _o_tables()

   Box(, 2, 65 )

   @ m_x + 1, m_y + 2 SAY "... export fakt dokumenata u toku"

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      _id_firma := field->idfirma
      _id_vd := field->idtipdok
      _br_dok := field->brdok
      _id_partn := field->idpartner

      // provjeri uslove ?!??

      // lista konta...
      IF !Empty( _rj )

         _usl_rj := Parsiraj( AllTrim( _rj ), "idfirma" )

         IF !( &_usl_rj )
            SKIP
            LOOP
         ENDIF

      ENDIF

      IF !Empty( _brojevi_dok )
         _usl_br_dok := Parsiraj( AllTrim( _brojevi_dok ), "brdok" )
         IF !( &_usl_br_dok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      // lista dokumenata...
      IF !Empty( _vrste_dok )
         IF !( field->idtipdok $ _vrste_dok )
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

      IF _change_rj
         IF _app_rec[ "idfirma" ] == _rj_src
            _app_rec[ "idfirma" ] := _rj_dest
         ENDIF
      ENDIF

      _detail_rec := hb_Hash()
      _detail_rec[ "dokument" ] := _app_rec[ "idfirma" ] + "-" + _app_rec[ "idtipdok" ] + "-" + _app_rec[ "brdok" ]
      _detail_rec[ "idpartner" ] := _app_rec[ "idpartner" ]
      _detail_rec[ "idkonto" ] := ""
      _detail_rec[ "partner" ] := _app_rec[ "partner" ]
      _detail_rec[ "iznos" ] := _app_rec[ "iznos" ]
      _detail_rec[ "datum" ] := _app_rec[ "datdok" ]
      _detail_rec[ "tip" ] := "export"

      // dodaj u detalje
      add_to_details( @a_details, _detail_rec )

      SELECT e_doks
      APPEND BLANK
      dbf_update_rec( _app_rec )

      ++ _cnt
      @ m_x + 2, m_y + 2 SAY PadR(  PadL( AllTrim( Str( _cnt ) ), 6 ) + ". " + "dokument: " + _id_firma + "-" + _id_vd + "-" + AllTrim( _br_dok ), 50 )

      // dodaj zapis i u tabelu e_fakt
      SELECT fakt
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vd + _br_dok

      _r_br := 0

      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idtipdok == _id_vd .AND. field->brdok == _br_dok

         // uzmi robu...
         _id_roba := field->idroba

         // svodi na primarnu sifru
         IF _prim_sif > 0
            _id_roba := PadR( _id_roba, _prim_sif )
         ENDIF

         // upisi zapis u tabelu e_fakt
         _app_rec := dbf_get_rec()

         IF _change_rj
            IF _app_rec[ "idfirma" ] == _rj_src
               _app_rec[ "idfirma" ] := _rj_dest
            ENDIF
         ENDIF

         IF _prim_sif > 0
            _app_rec[ "rbr" ] := PadL( AllTrim( Str( ++_r_br ) ), 3 )
            _app_rec[ "idroba" ] := _id_roba
         ENDIF

         // prvo potrazi da li postoji ovaj zapis...
         SELECT e_fakt
         SET ORDER TO TAG "2"

         IF _prim_sif > 0

            GO TOP
            SEEK _id_firma + _id_vd + _br_dok + _id_roba

            IF !Found()
               APPEND BLANK
               dbf_update_rec( _app_rec )
            ELSE
               REPLACE field->kolicina WITH field->kolicina + _app_rec[ "kolicina" ]
            ENDIF

         ELSE

            APPEND BLANK
            dbf_update_rec( _app_rec )

         ENDIF

         // uzmi sada robu sa ove stavke pa je ubaci u e_roba
         SELECT roba
         hseek _id_roba

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
         SELECT fakt
         SKIP

      ENDDO

      // fakt_doks2
      SELECT fakt_doks2
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vd + _br_dok

      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idtipdok == _id_vd .AND. field->brdok == _br_dok

         _app_rec := dbf_get_rec()

         SELECT e_doks2
         APPEND BLANK
         dbf_update_rec( _app_rec )

         SELECT fakt_doks2
         SKIP

      ENDDO

      // e sada mozemo komotno ici na export partnera
      SELECT partn
      hseek _id_partn
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

      SELECT fakt_doks
      SKIP

   ENDDO

   BoxC()

   IF ( _cnt > 0 )
      _ret := _cnt
   ENDIF

   RETURN _ret


// ----------------------------------------------------------------
// dodaj u matricu sa detaljima
// ----------------------------------------------------------------
FUNCTION add_to_details( details, rec )

   AAdd( details, { rec[ "tip" ], ;
      rec[ "dokument" ], ;
      rec[ "idpartner" ], ;
      rec[ "idkonto" ], ;
      rec[ "partner" ], ;
      rec[ "iznos" ], ;
      rec[ "datum" ] } )

   RETURN


// ----------------------------------------
// import podataka
// ----------------------------------------
STATIC FUNCTION __import( vars, a_details )

   LOCAL _ret := 0
   LOCAL _id_firma, _id_vd, _br_dok
   LOCAL _app_rec
   LOCAL _cnt := 0
   LOCAL _dat_od, _dat_do, _rj, _vrste_dok, _zamjeniti_dok, _zamjeniti_sif, _iz_fmk
   LOCAL _roba_id, _partn_id
   LOCAL _usl_rj, _usl_br_dok
   LOCAL _sif_exist
   LOCAL _fmk_import := .F.
   LOCAL _redni_broj := 0
   LOCAL _total_doks := 0
   LOCAL _total_fakt := 0
   LOCAL _gl_brojac := 0
   LOCAL _brojevi_dok
   LOCAL _detail_rec

   // lokuj potrebne tabele
   IF !f18_lock_tables( { "fakt_doks", "fakt_doks2", "fakt_fakt" } )
      RETURN _cnt
   ENDIF

   sql_table_update( nil, "BEGIN" )

   // ovo su nam uslovi za import...
   _dat_od := vars[ "datum_od" ]
   _dat_do := vars[ "datum_do" ]
   _rj := vars[ "rj" ]
   _vrste_dok := vars[ "vrste_dok" ]
   _zamjeniti_dok := vars[ "zamjeniti_dokumente" ]
   _zamjeniti_sif := vars[ "zamjeniti_sifre" ]
   _iz_fmk := vars[ "import_iz_fmk" ]
   _brojevi_dok := vars[ "brojevi_dok" ]

   IF _iz_fmk == "D"
      _fmk_import := .T.
   ENDIF

   // otvaranje export tabela
   _o_exp_tables( __import_dbf_path, nil )

   // otvori potrebne tabele za import podataka
   _o_tables()

   // broj zapisa u import tabelama
   SELECT e_doks
   _total_doks := RECCOUNT2()

   SELECT e_fakt
   _total_fakt := RECCOUNT2()

   SELECT e_doks
   SET ORDER TO TAG "1"
   GO TOP

   Box(, 3, 70 )

   @ m_x + 1, m_y + 2 SAY PadR( "... import fakt dokumenata u toku ", 69 ) COLOR "I"
   @ m_x + 2, m_y + 2 SAY "broj zapisa doks/" + AllTrim( Str( _total_doks ) ) + ", fakt/" + AllTrim( Str( _total_fakt ) )


   DO WHILE !Eof()

      _id_firma := field->idfirma
      _id_vd := field->idtipdok
      _br_dok := field->brdok

      // uslovi, provjera...

      // datumi...
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

      // lista konta...
      IF !Empty( _rj )

         _usl_rj := Parsiraj( AllTrim( _rj ), "idfirma" )

         IF !( &_usl_rj )
            SKIP
            LOOP
         ENDIF

      ENDIF

      // brojevi dokumenata
      IF !Empty( _brojevi_dok )

         _usl_br_dok := Parsiraj( AllTrim( _brojevi_dok ), "brdok" )

         IF !( &_usl_br_dok )
            SKIP
            LOOP
         ENDIF

      ENDIF


      // lista dokumenata...
      IF !Empty( _vrste_dok )
         IF !( field->idtipdok $ _vrste_dok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      // da li postoji u prometu vec ?
      IF _vec_postoji_u_prometu( _id_firma, _id_vd, _br_dok )

         SELECT e_doks
         _app_rec := dbf_get_rec()

         _detail_rec := hb_Hash()
         _detail_rec[ "dokument" ] := _app_rec[ "idfirma" ] + "-" + _app_rec[ "idtipdok" ] + "-" + _app_rec[ "brdok" ]
         _detail_rec[ "idpartner" ] := _app_rec[ "idpartner" ]
         _detail_rec[ "idkonto" ] := ""
         _detail_rec[ "partner" ] := _app_rec[ "partner" ]
         _detail_rec[ "iznos" ] := _app_rec[ "iznos" ]
         _detail_rec[ "datum" ] := _app_rec[ "datdok" ]

         IF _zamjeniti_dok == "D"

            // dokumente iz fakt, fakt_doks brisi !
            _detail_rec[ "tip" ] := "delete"
            add_to_details( @a_details, _detail_rec )

            _ok := .T.
            _ok := del_fakt_doc( _id_firma, _id_vd, _br_dok )

         ELSE

            _detail_rec[ "tip" ] := "x"
            add_to_details( @a_details, _detail_rec )

            SKIP
            LOOP

         ENDIF

      ENDIF

      // zikni je u nasu tabelu doks
      SELECT e_doks
      _app_rec := dbf_get_rec()

      _detail_rec := hb_Hash()
      _detail_rec[ "dokument" ] := _app_rec[ "idfirma" ] + "-" + _app_rec[ "idtipdok" ] + "-" + _app_rec[ "brdok" ]
      _detail_rec[ "idpartner" ] := _app_rec[ "idpartner" ]
      _detail_rec[ "idkonto" ] := ""
      _detail_rec[ "partner" ] := _app_rec[ "partner" ]
      _detail_rec[ "iznos" ] := _app_rec[ "iznos" ]
      _detail_rec[ "datum" ] := _app_rec[ "datdok" ]
      _detail_rec[ "tip" ] := "import"

      // dodaj u detalje
      add_to_details( @a_details, _detail_rec )

      SELECT fakt_doks
      APPEND BLANK
      update_rec_server_and_dbf( "fakt_doks", _app_rec, 1, "CONT" )

      ++ _cnt
      @ m_x + 3, m_y + 2 SAY PadR( PadL( AllTrim( Str( _cnt ) ), 5 ) + ". dokument: " + _id_firma + "-" + _id_vd + "-" + _br_dok, 60 )

      // zikni je u nasu tabelu fakt
      SELECT e_fakt
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vd + _br_dok

      // setuj novi redni broj stavke
      _redni_broj := 0

      // prebaci mi stavke tabele FAKT
      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idtipdok == _id_vd .AND. field->brdok == _br_dok

         _app_rec := dbf_get_rec()

         // setuj redni broj automatski...
         _app_rec[ "rbr" ] := PadL( AllTrim( Str( ++_redni_broj ) ), 3 )
         // reset podbroj
         _app_rec[ "podbr" ] := ""

         // uvecaj i globalni brojac stavki...
         _gl_brojac += _redni_broj

         @ m_x + 3, m_y + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + _app_rec[ "rbr" ]

         SELECT fakt
         APPEND BLANK
         update_rec_server_and_dbf( "fakt_fakt", _app_rec, 1, "CONT" )

         SELECT e_fakt
         SKIP

      ENDDO

      // upisi i doks2 tabelu
      SELECT e_doks2
      SET ORDER TO TAG "1"
      GO TOP
      SEEK _id_firma + _id_vd + _br_dok

      DO WHILE !Eof() .AND. field->idfirma == _id_firma .AND. field->idtipdok == _id_vd .AND. field->brdok == _br_dok

         _app_rec := dbf_get_rec()

         SELECT fakt_doks2
         APPEND BLANK
         update_rec_server_and_dbf( "fakt_doks2", _app_rec, 1, "CONT" )

         SELECT e_doks2
         SKIP

      ENDDO

      SELECT e_doks
      SKIP

   ENDDO

   // zavrsi transakciju
   f18_free_tables( { "fakt_doks", "fakt_doks2", "fakt_fakt" } )
   sql_table_update( nil, "END" )

   // ako je sve ok, predji na import tabela sifrarnika
   IF _cnt > 0

      // ocisti mi 3 red
      @ m_x + 3, m_y + 2 SAY PadR( "", 69 )

      // update tabele roba
      update_table_roba( _zamjeniti_sif, _fmk_import )

      // update tabele partnera
      update_table_partn( _zamjeniti_sif, _fmk_import )

      // odradi update tabela sifk, sifv
      update_sifk_sifv( _fmk_import )

   ENDIF

   BoxC()

   IF _cnt > 0
      _ret := _cnt
   ENDIF

   RETURN _ret



// ---------------------------------------------------------------------
// provjerava da li dokument vec postoji u prometu
// ---------------------------------------------------------------------
STATIC FUNCTION _vec_postoji_u_prometu( id_firma, id_vd, br_dok )

   LOCAL _t_area := Select()
   LOCAL _ret := .T.

   SELECT fakt_doks
   GO TOP
   SEEK id_firma + id_vd + br_dok

   IF !Found()
      _ret := .F.
   ENDIF

   SELECT ( _t_area )

   RETURN _ret




// ----------------------------------------------------------
// brisi dokument iz fakt-a
// ----------------------------------------------------------
STATIC FUNCTION del_fakt_doc( id_firma, id_vd, br_dok )

   LOCAL _t_area := Select()
   LOCAL _del_rec, _t_rec
   LOCAL _ret := .F.

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vd + br_dok

   IF Found()
      _ret := .T.
      // brisi fakt_fakt
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "fakt_fakt", _del_rec, 2, "CONT" )
   ENDIF

   // brisi fakt_doks
   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vd + br_dok
   IF Found()
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "fakt_doks", _del_rec, 1, "CONT" )
   ENDIF

   // doks2
   SELECT fakt_doks2
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_vd + br_dok
   IF Found()
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "fakt_doks2", _del_rec, 1, "CONT" )
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

   // tabela fakt
   O_FAKT
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_fakt" ) from ( my_home() + "struct" )

   // tabela doks
   O_FAKT_DOKS
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_doks" ) from ( my_home() + "struct" )

   // tabela doks
   O_FAKT_DOKS2
   COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_doks2" ) from ( my_home() + "struct" )

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

   O_FAKT
   O_FAKT_DOKS
   O_FAKT_DOKS2
   O_SIFK
   O_SIFV
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

   log_write( "otvaram fakt tabele importa i pravim indekse...", 9 )

   // zatvori sve prije otvaranja ovih tabela
   my_close_all_dbf()

   // setuj ove tabele kao temp tabele
   _dbf_name := "e_doks2"
   SELECT ( F_TMP_E_DOKS2 )
   my_use_temp( "E_DOKS2", use_path + _dbf_name, .F., .T. )
   INDEX on ( idfirma + idtipdok + brdok ) TAG "1"

   _dbf_name := "e_fakt"
   SELECT ( F_TMP_E_FAKT )
   my_use_temp( "E_FAKT", use_path + _dbf_name, .F., .T. )
   INDEX on ( idfirma + idtipdok + brdok + rbr ) TAG "1"
   INDEX on ( idfirma + idtipdok + brdok + idroba ) TAG "2"

   _dbf_name := "e_doks"
   SELECT ( F_TMP_E_DOKS )
   my_use_temp( "E_DOKS", use_path + _dbf_name, .F., .T. )
   INDEX on ( idfirma + idtipdok + brdok ) TAG "1"

   _dbf_name := "e_roba"
   SELECT ( F_TMP_E_ROBA )
   my_use_temp( "E_ROBA", use_path + _dbf_name, .F., .T. )
   INDEX on ( id ) TAG "ID"

   _dbf_name := "e_partn"
   SELECT ( F_TMP_E_PARTN )
   my_use_temp( "E_PARTN", use_path + _dbf_name, .F., .T. )
   INDEX on ( id ) TAG "ID"

   _dbf_name := "e_sifk"
   SELECT ( F_TMP_E_SIFK )
   my_use_temp( "E_SIFK", use_path + _dbf_name, .F., .T. )
   INDEX on ( id + sort + naz ) TAG "ID"
   INDEX on ( id + oznaka ) TAG "ID2"

   _dbf_name := "e_sifv"
   SELECT ( F_TMP_E_SIFV )
   my_use_temp( "E_SIFV", use_path + _dbf_name, .F., .T. )
   INDEX on ( id + oznaka + idsif + naz ) TAG "ID"
   INDEX on ( id + idsif ) TAG "IDIDSIF"

   log_write( "otvorene sve import tabele i indeksirane...", 9 )

   RETURN
