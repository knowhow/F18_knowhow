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


#include "f18.ch"

// -------------------------------------------
// otvori tabele potrebne za generaciju
// -------------------------------------------
STATIC FUNCTION _o_gen_tables( from_kum )

   IF from_kum == NIL
      from_kum := .F.
   ENDIF

   SELECT F_ROBA
   IF !Used()
      O_ROBA
   ENDIF

   SELECT F_KONCIJ
   IF !Used()
      o_koncij()
   ENDIF

   IF from_kum == .T.
      SELECT F_KALK
      IF !Used()
         open_kalk_as_pripr()
      ENDIF
   ELSE
      SELECT F_KALK_PRIPR
      IF !Used()
         o_kalk_pripr()
      ENDIF
   ENDIF

   RETURN



// -------------------------------------------
// kreiraj tabelu za prenos u TOPS
// -------------------------------------------
STATIC FUNCTION _cre_katops_dbf( dbf_table, from_kum )

   LOCAL _dbf

   IF from_kum == NIL
      from_kum := .F.
   ENDIF

   _o_gen_tables( from_kum )

   SELECT kalk_pripr
   GO TOP

   _dbf := {}
   AAdd( _dbf, { "IDFIRMA", "C", 2, 0 } )
   AAdd( _dbf, { "BRDOK", "C", 8, 0 } )
   AAdd( _dbf, { "IDVD", "C", 2, 0 } )
   AAdd( _dbf, { "DATDOK", "D", 8, 0 } )
   AAdd( _dbf, { "IDKONTO", "C", 7, 0 } )
   AAdd( _dbf, { "IDKONTO2", "C", 7, 0 } )
   AAdd( _dbf, { "IDPARTNER", "C", 6, 0 } )
   AAdd( _dbf, { "IDPOS", "C", 2, 0 } )
   AAdd( _dbf, { "IDROBA", "C", 10, 0 } )
   AAdd( _dbf, { "kolicina", "N", 13, 4 } )
   AAdd( _dbf, { "kol2", "N", 13, 4 } )
   AAdd( _dbf, { "MPC", "N", 13, 4 } )
   AAdd( _dbf, { "MPC2", "N", 13, 4 } )
   AAdd( _dbf, { "NAZIV", "C", 250, 0 } )
   AAdd( _dbf, { "IDTARIFA", "C", 6, 0 } )
   AAdd( _dbf, { "JMJ", "C", 3, 0 } )
   AAdd( _dbf, { "K1", "C", 4, 0 } )
   AAdd( _dbf, { "K2", "C", 4, 0 } )
   AAdd( _dbf, { "K7", "C", 1, 0 } )
   AAdd( _dbf, { "K8", "C", 2, 0 } )
   AAdd( _dbf, { "K9", "C", 3, 0 } )
   AAdd( _dbf, { "N1", "N", 12, 2 } )
   AAdd( _dbf, { "N2", "N", 12, 2 } )
   AAdd( _dbf, { "BARKOD", "C", 13, 0 } )

   // kreiraj tabelu
   dbCreate( dbf_table, _dbf )

   SELECT ( F_TMP_KATOPS )
   my_use_temp( "KATOPS", dbf_table )

   RETURN


// -------------------------------------------------------
// prenos prerequisites
// -------------------------------------------------------
STATIC FUNCTION _prenos_prereq()

   LOCAL _ret := .F.

   IF AllTrim( gTops ) <> "0"
      // provjeri i gTopsDest
      IF Empty( AllTrim( gTopsDest ) )
         MsgBeep( "Nije podesen direktorij za prenos podataka !" )
      ELSE
         _ret := .T.
      ENDIF
   ENDIF

   IF _ret
      IF Pitanje(, "Generisati datoteku prenosa za modul TOPS (D/N) ?", "N" ) == "N"
         _ret := .F.
      ENDIF
   ENDIF

   RETURN _ret


// ----------------------------------------------------------
// generacija tops dokumenata na osnovu kalk dokumenata
// ----------------------------------------------------------
FUNCTION kalk_generisi_tops_dokumente( id_firma, id_tip_dok, br_dok )

   LOCAL _katops_table := "katops.dbf"
   LOCAL _rbr, _dat_dok
   LOCAL _pos_locations
   LOCAL _from_kum := .T.
   LOCAL _total := 0

   my_close_all_dbf()

   IF PCount() == 0
      // generisanje iz pripreme
      _from_kum := .F.
   ENDIF

   // provjeri uslove za prenos
   IF !_prenos_prereq()

      _o_gen_tables( _from_kum )
      SELECT kalk_pripr
      RETURN

   ENDIF

   // otvori tabele
   _o_gen_tables( _from_kum )

   // kreiraj tabelu katops
   // ona ce se kreirati u privatnom direktoriju...
   _cre_katops_dbf( my_home() + _katops_table, _from_kum )

   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   GO TOP

   IF _from_kum == .F.
      id_firma := field->idfirma
      id_tip_dok := field->idvd
      br_dok := field->brdok
   ENDIF

   SEEK id_firma + id_tip_dok + br_dok

   _rbr := 0
   _dat_dok := Date()

   // matrica pos mjesta koje kaci kalkulacija
   _pos_locations := {}

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idvd == id_tip_dok .AND. field->brdok == br_dok

      SELECT roba
      HSEEK kalk_pripr->idroba

      SELECT koncij
      SEEK Trim( kalk_pripr->pkonto )

      // provjeri postoji li koncij zapis !
      IF Empty( koncij->idprodmjes )
         Msgbeep( "Nije definisano prodajno mjesto u tabeli konta - tipovi cijena !" )
         SELECT kalk_pripr
         RETURN
      ENDIF

      SELECT katops
      APPEND BLANK

      IF AScan( _pos_locations, {| x| x == koncij->idprodmjes } ) == 0
         AAdd( _pos_locations, koncij->idprodmjes )
      ENDIF

      _dat_dok := kalk_pripr->datdok

      REPLACE field->idfirma WITH gFirma
      REPLACE field->idvd WITH kalk_pripr->idvd
      REPLACE field->idpos WITH koncij->idprodmjes
      REPLACE field->datdok WITH kalk_pripr->datdok
      REPLACE field->idkonto WITH kalk_pripr->idkonto
      REPLACE field->idkonto2 WITH kalk_pripr->idkonto2
      REPLACE field->idpartner WITH kalk_pripr->idpartner
      REPLACE field->idroba WITH kalk_pripr->idroba

      REPLACE field->kolicina WITH kalk_pripr->kolicina

      // kod inventure
      IF field->idvd == "IP"
         REPLACE field->kol2 WITH kalk_pripr->gkolicina
      ENDIF

      REPLACE field->mpc WITH kalk_pripr->mpcsapp
      REPLACE field->naziv WITH roba->naz
      REPLACE field->idtarifa WITH kalk_pripr->idtarifa
      REPLACE field->jmj WITH roba->jmj
      REPLACE field->brdok WITH kalk_pripr->brdok
      REPLACE field->k1 WITH roba->k1
      REPLACE field->k2 WITH roba->k2
      REPLACE field->k7 WITH roba->k7
      REPLACE field->k8 WITH roba->k8
      REPLACE field->k9 WITH roba->k9
      REPLACE field->n1 WITH roba->n1
      REPLACE field->n2 WITH roba->n2
      REPLACE field->barkod WITH roba->barkod

      // cijene...
      IF kalk_pripr->pu_i == "3"
         // radi se o nivelaciji
         // mpc - stara cijena
         REPLACE field->mpc WITH kalk_pripr->fcj
         // mpc2 - nova cijena
         REPLACE field->mpc2 WITH kalk_pripr->( fcj + mpcsapp )
      ENDIF

      IF kalk_pripr->pu_i == "5"
         REPLACE field->kolicina WITH -kolicina
      ENDIF

      IF Empty( koncij->idprodmjes )
         REPLACE field->idpos WITH gTops
      ENDIF

      // saberi total...
      _total += ( field->kolicina * field->mpc )

      ++ _rbr

      SELECT kalk_pripr
      SKIP

   ENDDO

   // zatvori sta treba zatvoriti
   SELECT katops
   USE

   IF _rbr > 0

      // napravi i prebaci izlazne fajlove gdje trebaju
      _exp_file := _kreiraj_fajl_prenosa( _dat_dok, _pos_locations, _rbr )

      my_close_all_dbf()
      // ispisi report
      _print_report( id_firma, id_tip_dok, br_dok, _rbr, _total, _exp_file )

   ENDIF

   my_close_all_dbf()

   RETURN


// ---------------------------------------------
// printaj rezultat prenosa podataka
// ---------------------------------------------
STATIC FUNCTION _print_report( firma, tip_dok, br_dok, broj_stavki, total_prenosa, export_fajl )

   START PRINT CRET

   ?
   ? Space( 2 ) + "Prenos KALK -> TOPS na dan: ", Date()
   ? Space( 2 ) + "---------------------------------------"
   ?
   ? Space( 2 ) + "Formiran dokument: " + export_fajl
   ?
   ? Space( 2 ) + "Dokument: " + firma + "-" + tip_dok + "-" + br_dok
   ?
   ? Space( 2 ) + "Broj prenesenih stavki: " + AllTrim( Str( broj_stavki ) )
   ? Space( 2 ) + "Saldo: " + AllTrim( Str( total_prenosa, 10, 2 ) )
   ?
   ?

   IF tip_dok == "80" .AND. total_prenosa == 0
      ? Space( 2 ) + "Predispozicija"
   ENDIF

   ?

   ENDPRINT

   RETURN



// -------------------------------------------------------
// kreiranje fajla prenosa
// -------------------------------------------------------
STATIC FUNCTION _kreiraj_fajl_prenosa( datum, pos_locations, broj_stavki )

   LOCAL _i, _n
   LOCAL _dest_file, _dest_patt
   LOCAL _integ := {}
   LOCAL _table_name := "katops.dbf"
   LOCAL _table_path := my_home()
   LOCAL _export_location, _export
   LOCAL _ret := ""

   IF Right( AllTrim( gTopsDest ), 1 ) <> SLASH
      gTopsDest := AllTrim( gTopsDest ) + SLASH
   ENDIF

   // napravi direktorij prenosa ako ga nema !
   _dir_create( AllTrim( gTopsDest ) )

   // export lokacija generalna
   _export_location := AllTrim( gTopsDest )

   IF gMultiPM == "D"

      // prodji kroz sve lokacije i postavi datoteke eksporta
      FOR _n := 1 TO Len( pos_locations )

         // export ce biti u poddirektoriju kojem treba da bude...
         // recimo /prenos/1/
         _export := _export_location + AllTrim( pos_locations[ _n ] ) + SLASH

         // kreiraj mi ovaj direktorij ako ne postoji
         _dir_create( _export )

         // nakon dir create prebaci se na my_local_folder
         DirChange( my_home() )

         // pronadji mi naziv fajla koji je dozvoljen
         _dest_patt := get_topskalk_export_file( "2", _export, datum )

         // kopiraj katops.dbf
         _dest_file := _export + StrTran( _table_name, "katops.", _dest_patt + "." )
         _ret := _dest_file

         IF FileCopy( _table_path + _table_name, _dest_file ) > 0
            // kopiraj txt fajl
            _dest_file := StrTran( _dest_file, ".dbf", ".txt" )
            FileCopy( my_home() + OUTF_FILE, _dest_file )
         ELSE
            MsgBeep( "Problem sa kopiranjem fajla na destinaciju #" + _export )
         ENDIF

      NEXT

   ELSE

      _integ := IntegDbf( _table_name )
      NapraviCRC( AllTrim( gTopsDEST ) + "crckt.crc", _integ[ 1 ], _integ[ 2 ] )

   ENDIF

   RETURN _ret


// ---------------------------------------------------------------
// vraca naziv fajla za export
// ---------------------------------------------------------------
FUNCTION get_topskalk_export_file( topskalk, export_path, datum, prefix )

   LOCAL _file := ""
   LOCAL _prefix := "kt"
   LOCAL _i, _tmp
   LOCAL _tmp_date := Right( DToS( datum ), 4 )

   IF topskalk == "1"
      _prefix := "tk"
   ELSE
      _prefix := "kt"
   ENDIF

   IF prefix != NIL
      _prefix := prefix
   ENDIF

   // naziv fajla treba da bude
   // kt110401, kt110402 itd...

   FOR _i := 1 TO 99
      // nastavak na fajl
      _tmp := PadL( AllTrim( Str( _i ) ), 2, "0" )
      _file := _prefix + _tmp_date + _tmp

      IF !File( export_path + _file + ".dbf" )
         // ovaj fajl moze da se koristi
         EXIT
      ENDIF
   NEXT

   RETURN _file



// ------------------------------------------------------------------
// generisanje topska na osnovu azuriranog kalk dokumenta
// ------------------------------------------------------------------
FUNCTION mnu_prenos_kalk_u_tops()

   LOCAL cIDFirma := gFirma
   LOCAL cIDTipDokumenta := "80"
   LOCAL cBrojDokumenta := Space( 8 )

   Box(, 5, 40 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY "Generacija KALK -> TOPS: "
   @ m_x + 2, m_y + 2 SAY "-------------------------------"
   @ m_x + 4, m_y + 2 SAY "Dokument: " GET cIDFirma
   @ m_x + 4, m_y + 16 SAY " - " GET cIDTipDokumenta VALID !Empty( cIDTipDokumenta )
   @ m_x + 4, m_y + 23 SAY " - " GET cBrojDokumenta VALID !Empty( cBrojDokumenta )
   READ
   ESC_BCR
   BoxC()

   IF kalk_dokument_postoji( cIDFirma, cIDTipDokumenta, cBrojDokumenta, .F. )
      IF ( gTops <> "0 " .AND. Pitanje(, "Izgenerisati datoteku prenosa?", "N" ) == "D" )
         kalk_generisi_tops_dokumente( cIDFirma, cIDTipDokumenta, cBrojDokumenta ) // generisi datoteku prenosa
      ENDIF
   ENDIF

   RETURN .T.
