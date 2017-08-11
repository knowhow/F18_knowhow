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

THREAD STATIC __import_dbf_path
THREAD STATIC __export_dbf_path
THREAD STATIC __import_zip_name
THREAD STATIC __export_zip_name


FUNCTION fakt_udaljena_razmjena_podataka()

   LOCAL aOpc := {}
   LOCAL aOpcExe := {}
   LOCAL nIzbor := 1

   __import_dbf_path := ""
   __export_dbf_path := my_home() + "export_dbf" + SLASH
   __import_zip_name := "fakt_exp.zip"
   __export_zip_name := "fakt_exp.zip"

   direktorij_kreiraj_ako_ne_postoji( __export_dbf_path )

   AAdd( aOpc, "1. => export podataka               " )
   AAdd( aOpcExe, {|| _fakt_export() } )
   AAdd( aOpc, "2. <= import podataka    " )
   AAdd( aOpcExe, {|| _fakt_import() } )

   f18_menu( "razmjena", .F., nIzbor, aOpc, aOpcExe )

   my_close_all_dbf()

   RETURN .T.


STATIC FUNCTION _fakt_export()

   LOCAL _vars := hb_Hash()
   LOCAL _exported_rec
   LOCAL _error
   LOCAL _a_data := {}

   IF !_vars_export( @_vars )
      RETURN .F.
   ENDIF

   delete_exp_files( __export_dbf_path, "fakt" )

   _exported_rec := fakt_export_impl( _vars, @_a_data )

   my_close_all_dbf()

   IF _exported_rec > 0

      _error := udaljenja_razmjena_compress_files( "fakt", __export_dbf_path )

      IF _error == 0
         delete_exp_files( __export_dbf_path, "fakt" )
         open_folder( __export_dbf_path )
      ENDIF

   ENDIF

   DirChange( my_home() )

   IF ( _exported_rec > 0 )

      MsgBeep( "Exportovao " + AllTrim( Str( _exported_rec ) ) + " dokumenta." )
      print_imp_exp_report( _a_data )

   ENDIF

   my_close_all_dbf()

   RETURN .T.



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
      RETURN .F.
   ENDIF

   __import_dbf_path := AllTrim( _imp_path )
   set_metric( "fakt_import_path", my_user(), _imp_path )

   _imp_file := get_import_file( "fakt", __import_dbf_path )

   IF _imp_file == NIL .OR. Empty( _imp_file )
      MsgBeep( "Nema odabranog import fajla !????" )
      RETURN .F.
   ENDIF

   IF !_vars_import( @_vars )
      RETURN .F.
   ENDIF

   IF !import_file_exist( _imp_file )
      MsgBeep( "Import fajl ne postoji! Prekidam operaciju." )
      RETURN .F.
   ENDIF

   IF razmjena_decompress_files( _imp_file, __import_dbf_path, __import_zip_name ) <> 0
      RETURN .F.
   ENDIF

#ifdef __PLATFORM__UNIX
   set_file_access( __import_dbf_path )
#endif

   _imported_rec := __import( _vars, @_a_data )
   my_close_all_dbf()
   delete_exp_files( __import_dbf_path, "fakt" )

   IF ( _imported_rec > 0 )
      IF Pitanje(, "Pobrisati fajl razmjne ?", "D" ) == "D"
         delete_zip_files( _imp_file )
      ENDIF
      MsgBeep( "Importovao " + AllTrim( Str( _imported_rec ) ) + " dokumenta." )
      print_imp_exp_report( _a_data )
   ENDIF

   DirChange( my_home() )

   RETURN .T.


FUNCTION print_imp_exp_report( DATA )

   LOCAL nI, _cnt
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

   FOR nI := 1 TO Len( DATA )

      _descr := AllTrim( DATA[ nI, 1 ] )

      IF _descr == "x"
         ++_x_docs
      ELSEIF _descr == "import"
         ++_import_docs
      ELSEIF _descr == "export"
         ++_exp_docs
      ELSEIF _descr == "delete"
         ++_delete_docs
      ENDIF

      ? PadL( AllTrim( Str( ++_cnt ) ), 4 ) + "."
      @ PRow(), PCol() + 1 SAY PadL( _descr, 10 )
      @ PRow(), PCol() + 1 SAY PadR( DATA[ nI, 2 ], 16 )
      @ PRow(), PCol() + 1 SAY DToC( DATA[ nI, 7 ] )
      @ PRow(), PCol() + 1 SAY PadR( DATA[ nI, 5 ], 27 ) + "..."
      @ PRow(), PCol() + 1 SAY Str( DATA[ nI, 6 ], 12, 2 )

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
   ENDPRINT

   RETURN



STATIC FUNCTION _vars_export( hParams )

   LOCAL _ret := .F.
   LOCAL dDatOd := fetch_metric( "fakt_export_datum_od", my_user(), Date() - 30 )
   LOCAL dDatDo := fetch_metric( "fakt_export_datum_do", my_user(), Date() )
   LOCAL cIdRj := fetch_metric( "fakt_export_lista_rj", my_user(), PadR( "10;", 200 ) )
   LOCAL cVrsteDok := fetch_metric( "fakt_export_vrste_dokumenata", my_user(), PadR( "10;11;", 200 ) )
   LOCAL cBrDok := fetch_metric( "fakt_export_brojevi_dokumenata", my_user(), PadR( "", 300 ) )
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

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY "Vrste dokumenata:" GET cVrsteDok PICT "@S40"

   ++_x

   @ m_x + _x, m_y + 2 SAY "Brojevi dokumenata:" GET cBrDok PICT "@S40"

   ++_x

   @ m_x + _x, m_y + 2 SAY "Datumski period od" GET dDatOd
   @ m_x + _x, Col() + 1 SAY "do" GET dDatDo

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY8 "Uzeti u obzir sljedeće rj:" GET cIdRj PICT "@S30"

   ++_x

   @ m_x + _x, m_y + 2 SAY8 "Svoditi na primarnu šifru (dužina primarne šifre):" GET _prim_sif PICT "9"

   ++_x

   @ m_x + _x, m_y + 2 SAY "Promjena radne jedinice" GET _prom_rj_src
   @ m_x + _x, Col() + 1 SAY "u" GET _prom_rj_dest

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY8 "Export šifarnika (D/N) ?" GET _exp_sif PICT "@!" VALID _exp_sif $ "DN"

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY "Lokacija exporta:" GET _exp_path PICT "@S50"

   READ

   BoxC()

   IF LastKey() <> K_ESC

      _ret := .T.

      set_metric( "fakt_export_datum_od", my_user(), dDatOd )
      set_metric( "fakt_export_datum_do", my_user(), dDatDo )
      set_metric( "fakt_export_lista_rj", my_user(), cIdRj )
      set_metric( "fakt_export_vrste_dokumenata", my_user(), cVrsteDok )
      set_metric( "fakt_export_sifrarnik", my_user(), _exp_sif )
      set_metric( "fakt_export_duzina_primarne_sifre", my_user(), _prim_sif )
      set_metric( "fakt_export_path", my_user(), _exp_path )
      set_metric( "fakt_export_brojevi_dokumenata", my_user(), cBrDok )

      __export_dbf_path := AllTrim( _exp_path )

      hParams[ "datum_od" ] := dDatOd
      hParams[ "datum_do" ] := dDatDo
      hParams[ "rj" ] := cIdRj
      hParams[ "vrste_dok" ] := cVrsteDok
      hParams[ "export_sif" ] := _exp_sif
      hParams[ "prim_sif" ] := _prim_sif
      hParams[ "rj_src" ] := _prom_rj_src
      hParams[ "rj_dest" ] := _prom_rj_dest
      hParams[ "brojevi_dok" ] := cBrDok

   ENDIF

   RETURN _ret



STATIC FUNCTION _vars_import( hParams )

   LOCAL _ret := .F.
   LOCAL dDatOd := fetch_metric( "fakt_import_datum_od", my_user(), CToD( "" ) )
   LOCAL dDatDo := fetch_metric( "fakt_import_datum_do", my_user(), CToD( "" ) )
   LOCAL cIdRj := fetch_metric( "fakt_import_lista_rj", my_user(), PadR( "", 200 ) )
   LOCAL cVrsteDok := fetch_metric( "fakt_import_vrste_dokumenata", my_user(), PadR( "", 200 ) )
   LOCAL cBrDok := fetch_metric( "fakt_import_brojevi_dokumenata", my_user(), PadR( "", 300 ) )
   LOCAL cZamijenitiDokumenteDN := fetch_metric( "fakt_importcZamijenitiDokumenteDNumente", my_user(), "N" )
   LOCAL _zamjeniti_sif := fetch_metric( "fakt_import_zamjeniti_sifre", my_user(), "N" )
   LOCAL _iz_fmk := fetch_metric( "fakt_import_iz_fmk", my_user(), "N" )
   LOCAL _imp_path := fetch_metric( "fakt_import_path", my_user(), PadR( "", 300 ) )
   LOCAL _x := 1

   IF Empty( AllTrim( _imp_path ) )
      _imp_path := PadR( __import_dbf_path, 300 )
   ENDIF

   Box(, 15, 70 )

   @ m_x + _x, m_y + 2 SAY "*** Uslovi importa dokumenata"

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY "Vrste dokumenata (prazno-sve):" GET cVrsteDok PICT "@S30"

   ++_x

   @ m_x + _x, m_y + 2 SAY "Brojevi dokumenata (prazno-sve):" GET cBrDok PICT "@S30"

   ++_x

   @ m_x + _x, m_y + 2 SAY "Datumski period od" GET dDatOd
   @ m_x + _x, Col() + 1 SAY "do" GET dDatDo

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY8 "Uzeti u obzir sljedeće radne jedinice:" GET cIdRj PICT "@S30"

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY8 "Zamjeniti postojeće dokumente novim (D/N):" GET cZamijenitiDokumenteDN PICT "@!" VALID cZamijenitiDokumenteDN $ "DN"

   ++_x

   @ m_x + _x, m_y + 2 SAY8 "Zamjeniti postojeće šifre novim (D/N):" GET _zamjeniti_sif PICT "@!" VALID _zamjeniti_sif $ "DN"

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY "Import fajl dolazi iz FMK (D/N) ?" GET _iz_fmk PICT "@!" VALID _iz_fmk $ "DN"

   ++_x
   ++_x

   @ m_x + _x, m_y + 2 SAY "Import lokacija:" GET _imp_path PICT "@S50"

   READ

   BoxC()

   IF LastKey() <> K_ESC

      _ret := .T.

      set_metric( "fakt_import_datum_od", my_user(), dDatOd )
      set_metric( "fakt_import_datum_do", my_user(), dDatDo )
      set_metric( "fakt_import_lista_rj", my_user(), cIdRj )
      set_metric( "fakt_import_vrste_dokumenata", my_user(), cVrsteDok )
      set_metric( "fakt_importcZamijenitiDokumenteDNumente", my_user(), cZamijenitiDokumenteDN )
      set_metric( "fakt_import_zamjeniti_sifre", my_user(), _zamjeniti_sif )
      set_metric( "fakt_import_iz_fmk", my_user(), _iz_fmk )
      set_metric( "fakt_import_path", my_user(), _imp_path )
      set_metric( "fakt_import_brojevi_dokumenata", my_user(), cBrDok )

      __import_dbf_path := AllTrim( _imp_path )

      hParams[ "datum_od" ] := dDatOd
      hParams[ "datum_do" ] := dDatDo
      hParams[ "rj" ] := cIdRj
      hParams[ "vrste_dok" ] := cVrsteDok
      hParams[ "zamjeniti_dokumente" ] := cZamijenitiDokumenteDN
      hParams[ "zamjeniti_sifre" ] := _zamjeniti_sif
      hParams[ "import_iz_fmk" ] := _iz_fmk
      hParams[ "brojevi_dok" ] := cBrDok

   ENDIF

   RETURN _ret



STATIC FUNCTION fakt_export_impl( hParams, a_details )

   LOCAL _ret := 0
   LOCAL cIdFirma, cIdTipDok, cBrDok
   LOCAL hAppendRec
   LOCAL _cnt := 0
   LOCAL dDatOd, dDatDo, cIdRj, cVrsteDok, _export_sif
   LOCAL cUslovRj, _usl_br_dok
   LOCAL cIdPartner
   LOCAL cIdRoba
   LOCAL _prim_sif
   LOCAL _rj_src, _rj_dest, _brojevi_dok
   LOCAL _change_rj := .F.
   LOCAL _detail_rec
   LOCAL nRbr

   dDatOd := hParams[ "datum_od" ]
   dDatDo := hParams[ "datum_do" ]
   cIdRj := AllTrim( hParams[ "rj" ] )
   cVrsteDok := AllTrim( hParams[ "vrste_dok" ] )
   _export_sif := AllTrim( hParams[ "export_sif" ] )
   _prim_sif := hParams[ "prim_sif" ]
   _rj_src := hParams[ "rj_src" ]
   _rj_dest := hParams[ "rj_dest" ]
   _brojevi_dok := hParams[ "brojevi_dok" ]

   IF !Empty( _rj_src ) .AND. !Empty( _rj_dest )
      _change_rj := .T.
   ENDIF

   _cre_exp_tbls( __export_dbf_path )
   _o_exp_tables( __export_dbf_path )
   _o_tables()

   Box(, 2, 65 )

   @ m_x + 1, m_y + 2 SAY "... export fakt dokumenata u toku"

   //SELECT fakt_doks
   //SET ORDER TO TAG "1"
   //GO TOP
   find_fakt_doks_za_period( NIL, dDatOd, dDatDo, "FAKT_DOKS" )

   DO WHILE !Eof()

      cIdFirma := field->idfirma
      cIdTipDok := field->idtipdok
      cBrDok := field->brdok
      cIdPartner := field->idpartner

      IF !Empty( cIdRj )
         cUslovRj := Parsiraj( AllTrim( cIdRj ), "idfirma" )
         IF !( &cUslovRj )
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

      IF !Empty( cVrsteDok )
         IF !( field->idtipdok $ cVrsteDok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF dDatOd <> CToD( "" )
         IF ( field->datdok < dDatOd )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF dDatDo <> CToD( "" )
         IF ( field->datdok > dDatDo )
            SKIP
            LOOP
         ENDIF
      ENDIF

      hAppendRec := dbf_get_rec()

      IF _change_rj
         IF hAppendRec[ "idfirma" ] == _rj_src
            hAppendRec[ "idfirma" ] := _rj_dest
         ENDIF
      ENDIF

      _detail_rec := hb_Hash()
      _detail_rec[ "dokument" ] := hAppendRec[ "idfirma" ] + "-" + hAppendRec[ "idtipdok" ] + "-" + hAppendRec[ "brdok" ]
      _detail_rec[ "idpartner" ] := hAppendRec[ "idpartner" ]
      _detail_rec[ "idkonto" ] := ""
      _detail_rec[ "partner" ] := hAppendRec[ "partner" ]
      _detail_rec[ "iznos" ] := hAppendRec[ "iznos" ]
      _detail_rec[ "datum" ] := hAppendRec[ "datdok" ]
      _detail_rec[ "tip" ] := "export"

      export_import_add_to_details( @a_details, _detail_rec )

      SELECT e_doks
      APPEND BLANK
      dbf_update_rec( hAppendRec )

      ++_cnt
      @ m_x + 2, m_y + 2 SAY PadR(  PadL( AllTrim( Str( _cnt ) ), 6 ) + ". " + "dokument: " + cIdFirma + "-" + cIdTipDok + "-" + AllTrim( cBrDok ), 50 )

      seek_fakt( cIdFirma, cIdTipDok, cBrDok )
      nRbr := 0

      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idtipdok == cIdTipDok .AND. field->brdok == cBrDok

         cIdRoba := field->idroba
         IF _prim_sif > 0
            cIdRoba := PadR( cIdRoba, _prim_sif )
         ENDIF
         hAppendRec := dbf_get_rec()

         IF _change_rj
            IF hAppendRec[ "idfirma" ] == _rj_src
               hAppendRec[ "idfirma" ] := _rj_dest
            ENDIF
         ENDIF

         IF _prim_sif > 0
            hAppendRec[ "rbr" ] := PadL( AllTrim( Str( ++nRbr ) ), 3 )
            hAppendRec[ "idroba" ] := cIdRoba
         ENDIF

         SELECT e_fakt
         SET ORDER TO TAG "2"

         IF _prim_sif > 0

            GO TOP
            SEEK cIdFirma + cIdTipDok + cBrDok + cIdRoba // e_fakt

            IF !Found()
               APPEND BLANK
               dbf_update_rec( hAppendRec )
            ELSE
               RREPLACE field->kolicina WITH field->kolicina + hAppendRec[ "kolicina" ]
            ENDIF

         ELSE
            APPEND BLANK
            dbf_update_rec( hAppendRec )

         ENDIF

         select_o_roba( cIdRoba )

         IF !Eof() .AND. _export_sif == "D"
            hAppendRec := dbf_get_rec()
            SELECT e_roba
            SET ORDER TO TAG "ID"
            SEEK cIdRoba // e_roba
            IF !Found()
               APPEND BLANK
               dbf_update_rec( hAppendRec )
               razmjena_fill_sifk_sifv( "ROBA", cIdRoba )
            ENDIF
         ENDIF

         SELECT fakt
         SKIP

      ENDDO

      seek_fakt_doks2( cIdFirma, cIdTipDok, cBrDok )

      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idtipdok == cIdTipDok .AND. field->brdok == cBrDok

         hAppendRec := dbf_get_rec()

         SELECT e_doks2
         APPEND BLANK
         dbf_update_rec( hAppendRec )

         SELECT fakt_doks2
         SKIP

      ENDDO

      select_o_partner( cIdPartner )
      IF Found() .AND. _export_sif == "D"
         hAppendRec := dbf_get_rec()
         SELECT e_partn
         SET ORDER TO TAG "ID"
         SEEK cIdPartner // e_partn
         IF !Found()
            APPEND BLANK
            dbf_update_rec( hAppendRec )
            razmjena_fill_sifk_sifv( "PARTN", cIdPartner )
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


FUNCTION export_import_add_to_details( aDetails, hRec )

   AAdd( aDetails, { hRec[ "tip" ], ;
      hRec[ "dokument" ], ;
      hRec[ "idpartner" ], ;
      hRec[ "idkonto" ], ;
      hRec[ "partner" ], ;
      hRec[ "iznos" ], ;
      hRec[ "datum" ] } )

   RETURN .T.


STATIC FUNCTION __import( hParams, a_details )

   LOCAL _ret := 0
   LOCAL cIdFirma, cIdTipDok, cBrDok
   LOCAL hAppendRec
   LOCAL _cnt := 0
   LOCAL dDatOd, dDatDo, cIdRj, cVrsteDok, cZamijenitiDokumenteDN, _zamjeniti_sif, _iz_fmk
   LOCAL _roba_id, _partn_id
   LOCAL cUslovRj, _usl_br_dok
   LOCAL _sif_exist
   LOCAL lFmkImport := .F.
   LOCAL _redni_broj := 0
   LOCAL nTotalFaktDoks := 0
   LOCAL nTotalFakt := 0
   LOCAL _gl_brojac := 0
   LOCAL _brojevi_dok
   LOCAL _detail_rec
   LOCAL lOk := .T.
   //LOCAL hParams

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fakt_doks", "fakt_doks2", "fakt_fakt" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Problem sa zaključavanjem tabela.#Prekidam operaciju." )
      RETURN _cnt
   ENDIF

   dDatOd := hParams[ "datum_od" ]
   dDatDo := hParams[ "datum_do" ]
   cIdRj := hParams[ "rj" ]
   cVrsteDok := hParams[ "vrste_dok" ]
   cZamijenitiDokumenteDN := hParams[ "zamjeniti_dokumente" ]
   _zamjeniti_sif := hParams[ "zamjeniti_sifre" ]

   _brojevi_dok := hParams[ "brojevi_dok" ]

   IF hParams[ "import_iz_fmk" ] == "D"
      lFmkImport := .T.
   ENDIF

   _o_exp_tables( __import_dbf_path, NIL )
   _o_tables()

   SELECT e_doks
   nTotalFaktDoks := RECCOUNT2()

   SELECT e_fakt
   nTotalFakt := RECCOUNT2()

   SELECT e_doks
   SET ORDER TO TAG "1"
   GO TOP

   Box(, 3, 70 )

   @ m_x + 1, m_y + 2 SAY PadR( "... import fakt dokumenata u toku ", 69 ) COLOR f18_color_i()
   @ m_x + 2, m_y + 2 SAY "broj zapisa doks/" + AllTrim( Str( nTotalFaktDoks ) ) + ", fakt/" + AllTrim( Str( nTotalFakt ) )


   DO WHILE !Eof()

      cIdFirma := field->idfirma
      cIdTipDok := field->idtipdok
      cBrDok := field->brdok

      IF dDatOd <> CToD( "" )
         IF field->datdok < dDatOd
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF dDatDo <> CToD( "" )
         IF field->datdok > dDatDo
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF !Empty( cIdRj )
         cUslovRj := Parsiraj( AllTrim( cIdRj ), "idfirma" )
         IF !( &cUslovRj )
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

      IF !Empty( cVrsteDok )
         IF !( field->idtipdok $ cVrsteDok )
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF _vec_postoji_u_prometu( cIdFirma, cIdTipDok, cBrDok )

         SELECT e_doks
         hAppendRec := dbf_get_rec()

         _detail_rec := hb_Hash()
         _detail_rec[ "dokument" ] := hAppendRec[ "idfirma" ] + "-" + hAppendRec[ "idtipdok" ] + "-" + hAppendRec[ "brdok" ]
         _detail_rec[ "idpartner" ] := hAppendRec[ "idpartner" ]
         _detail_rec[ "idkonto" ] := ""
         _detail_rec[ "partner" ] := hAppendRec[ "partner" ]
         _detail_rec[ "iznos" ] := hAppendRec[ "iznos" ]
         _detail_rec[ "datum" ] := hAppendRec[ "datdok" ]

         IF cZamijenitiDokumenteDN == "D"
            _detail_rec[ "tip" ] := "delete"
            export_import_add_to_details( @a_details, _detail_rec )
            lOk := .T.
            lOk := del_fakt_doc( cIdFirma, cIdTipDok, cBrDok )
         ELSE
            _detail_rec[ "tip" ] := "x"
            export_import_add_to_details( @a_details, _detail_rec )
            SKIP
            LOOP
         ENDIF

      ENDIF

      SELECT e_doks
      hAppendRec := dbf_get_rec()

      _detail_rec := hb_Hash()
      _detail_rec[ "dokument" ] := hAppendRec[ "idfirma" ] + "-" + hAppendRec[ "idtipdok" ] + "-" + hAppendRec[ "brdok" ]
      _detail_rec[ "idpartner" ] := hAppendRec[ "idpartner" ]
      _detail_rec[ "idkonto" ] := ""
      _detail_rec[ "partner" ] := hAppendRec[ "partner" ]
      _detail_rec[ "iznos" ] := hAppendRec[ "iznos" ]
      _detail_rec[ "datum" ] := hAppendRec[ "datdok" ]
      _detail_rec[ "tip" ] := "import"

      export_import_add_to_details( @a_details, _detail_rec )

      SELECT fakt_doks
      APPEND BLANK

      lOk := update_rec_server_and_dbf( "fakt_doks", hAppendRec, 1, "CONT" )

      IF !lOk
         EXIT
      ENDIF

      ++_cnt
      @ m_x + 3, m_y + 2 SAY PadR( PadL( AllTrim( Str( _cnt ) ), 5 ) + ". dokument: " + cIdFirma + "-" + cIdTipDok + "-" + cBrDok, 60 )

      SELECT e_fakt
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cIdFirma + cIdTipDok + cBrDok // e_fakt

      _redni_broj := 0

      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idtipdok == cIdTipDok .AND. field->brdok == cBrDok

         hAppendRec := dbf_get_rec()

         hAppendRec[ "rbr" ] := PadL( AllTrim( Str( ++_redni_broj ) ), 3 )
         hAppendRec[ "podbr" ] := ""
         _gl_brojac += _redni_broj

         @ m_x + 3, m_y + 40 SAY "stavka: " + AllTrim( Str( _gl_brojac ) ) + " / " + hAppendRec[ "rbr" ]

         SELECT fakt
         APPEND BLANK
         lOk := update_rec_server_and_dbf( "fakt_fakt", hAppendRec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT e_fakt
         SKIP

      ENDDO

      IF !lOk
         EXIT
      ENDIF

      SELECT e_doks2
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cIdFirma + cIdTipDok + cBrDok // e_doks2

      DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idtipdok == cIdTipDok .AND. field->brdok == cBrDok

         hAppendRec := dbf_get_rec()

         SELECT fakt_doks2
         APPEND BLANK
         lOK := update_rec_server_and_dbf( "fakt_doks2", hAppendRec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         SELECT e_doks2
         SKIP

      ENDDO

      IF !lOk
         EXIT
      ENDIF

      SELECT e_doks
      SKIP

   ENDDO

   IF lOk
      hParams := hb_Hash()
      hParams[ "unlock" ] := { "fakt_fakt", "fakt_doks", "fakt_doks2" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
      Msgbeep( "Problem sa operacijom inserta dokumenata.#Prekidam operaciju." )
   ENDIF

   IF _cnt > 0 .AND. lOk

      @ m_x + 3, m_y + 2 SAY PadR( "", 69 )

      update_table_roba( _zamjeniti_sif )
      update_table_partn( _zamjeniti_sif )
      update_sifk_sifv()

   ENDIF

   BoxC()

   IF _cnt > 0
      _ret := _cnt
   ENDIF

   RETURN _ret



STATIC FUNCTION _vec_postoji_u_prometu( id_firma, id_vd, br_dok )

   LOCAL cWhere
   LOCAL nDbfArea := Select()
   LOCAL lRet := .T.

   seek_fakt_doks( id_firma, id_vd, br_dok )

   IF Eof()
      lRet := .F.
   ENDIF

   SELECT ( nDbfArea )

   RETURN lRet




// ----------------------------------------------------------
// brisi dokument iz fakt-a
// ----------------------------------------------------------

STATIC FUNCTION del_fakt_doc( id_firma, id_vd, br_dok )

   LOCAL nDbfArea := Select()
   LOCAL _del_rec, nTrec
   LOCAL _ret := .F.

   IF seek_fakt( id_firma, id_vd, br_dok )
   //IF !Eof()
      _ret := .T.
      // brisi fakt_fakt
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "fakt_fakt", _del_rec, 2, "CONT" )
   ENDIF

   // brisi fakt_doks
   IF seek_fakt_doks( id_firma, id_vd, br_dok )
   //IF !Eof()
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "fakt_doks", _del_rec, 1, "CONT" )
   ENDIF

   // doks2
   seek_fakt_doks2( id_firma, id_vd, br_dok )
   IF !Eof()
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "fakt_doks2", _del_rec, 1, "CONT" )
   ENDIF

   SELECT ( nDbfArea )

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
   direktorij_kreiraj_ako_ne_postoji( use_path )


   seek_fakt( "XXX" )
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_fakt" ) FROM ( my_home() + "struct" )

   seek_fakt_doks( "XXXX" )
   o_fakt_doks_dbf()
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_doks" ) FROM ( my_home() + "struct" )


   seek_fakt_doks2( "XXXX" )
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_doks2" ) FROM ( my_home() + "struct" )

   // tabela roba
   o_roba( "XXXXX" )
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_roba" ) FROM ( my_home() + "struct" )

   // tabela partn
   o_partner( "XXXX" )
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_partn" ) FROM ( my_home() + "struct" )

   // tabela sifk
   o_sifk()
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_sifk" ) FROM ( my_home() + "struct" )

   // tabela sifv
   o_sifv()
   COPY STRUCTURE EXTENDED TO ( my_home() + "struct" )
   USE
   CREATE ( use_path + "e_sifv" ) FROM ( my_home() + "struct" )

   RETURN .T.


// ----------------------------------------------------
// otvaranje potrebnih tabela za prenos
// ----------------------------------------------------
STATIC FUNCTION _o_tables()

   //o_fakt_dbf()
   //o_fakt_doks_dbf()
   //o_fakt_doks2_dbf()
   //o_sifk()
   //o_sifv()
   //o_partner()
   //o_roba()

   RETURN .T.




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
   INDEX ON ( idfirma + idtipdok + brdok ) TAG "1"

   _dbf_name := "e_fakt"
   SELECT ( F_TMP_E_FAKT )
   my_use_temp( "E_FAKT", use_path + _dbf_name, .F., .T. )
   INDEX ON ( idfirma + idtipdok + brdok + rbr ) TAG "1"
   INDEX ON ( idfirma + idtipdok + brdok + idroba ) TAG "2"

   _dbf_name := "e_doks"
   SELECT ( F_TMP_E_DOKS )
   my_use_temp( "E_DOKS", use_path + _dbf_name, .F., .T. )
   INDEX ON ( idfirma + idtipdok + brdok ) TAG "1"

   _dbf_name := "e_roba"
   SELECT ( F_TMP_E_ROBA )
   my_use_temp( "E_ROBA", use_path + _dbf_name, .F., .T. )
   INDEX ON ( id ) TAG "ID"

   _dbf_name := "e_partn"
   SELECT ( F_TMP_E_PARTN )
   my_use_temp( "E_PARTN", use_path + _dbf_name, .F., .T. )
   INDEX ON ( id ) TAG "ID"

   _dbf_name := "e_sifk"
   SELECT ( F_TMP_E_SIFK )
   my_use_temp( "E_SIFK", use_path + _dbf_name, .F., .T. )
   INDEX ON ( id + SORT + naz ) TAG "ID"
   INDEX ON ( id + oznaka ) TAG "ID2"

   _dbf_name := "e_sifv"
   SELECT ( F_TMP_E_SIFV )
   my_use_temp( "E_SIFV", use_path + _dbf_name, .F., .T. )
   INDEX ON ( id + oznaka + idsif + naz ) TAG "ID"
   INDEX ON ( id + idsif ) TAG "IDIDSIF"

   log_write( "otvorene sve import tabele i indeksirane...", 9 )

   RETURN .T.
