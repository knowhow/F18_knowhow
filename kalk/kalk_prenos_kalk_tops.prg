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

STATIC s_cKalkDestinacijaTopska := NIL
STATIC s_cTxtPrint

MEMVAR GetList

FUNCTION kalk_tops_meni()

   LOCAL cIDFirma := self_organizacija_id()
   LOCAL cIdVd := "80"
   LOCAL cBrDok := Space( 8 )

   DO WHILE .T.
      Box(, 5, 40 )
      SET CURSOR ON
      @ form_x_koord() + 1, form_y_koord() + 2 SAY "Generacija KALK -> TOPS: "
      @ form_x_koord() + 2, form_y_koord() + 2 SAY "-------------------------------"
      @ form_x_koord() + 4, form_y_koord() + 2 SAY "Dokument: " GET cIDFirma
      @ form_x_koord() + 4, form_y_koord() + 16 SAY " - " GET cIdVd VALID !Empty( cIdVd )
      @ form_x_koord() + 4, form_y_koord() + 23 SAY " - " GET cBrDok valid {|| cBrdok := kalk_fix_brdok( cBrDok ), .T. }
      READ
      ESC_BCR
      BoxC()

      IF kalk_dokument_postoji( cIDFirma, cIdVd, cBrDok, .F. )
         kalk_generisi_tops_dokumente( cIDFirma, cIdVd, cBrDok ) // generisi datoteku prenosa
      ENDIF

      cBrDok := kalk_fix_brdok_add_1( cBrDok )
   ENDDO

   RETURN .T.



/*
      generacija tops dokumenata na osnovu kalk dokumenata
*/

FUNCTION kalk_generisi_tops_dokumente( cIdFirma, cIdVd, cBrDok )

   LOCAL _katops_table := "katops.dbf"
   LOCAL nRbr, dDatDok
   LOCAL aPosLokacije
   LOCAL _lFromKumulativ := .T.
   LOCAL _total := 0
   LOCAL cStavke := ""
   LOCAL cPm, cPKonto

   my_close_all_dbf()

   IF PCount() == 0
      _lFromKumulativ := .F. // generisanje iz pripreme
   ENDIF


   IF !kalk_tops_prenos_prerequisites()
      // kalk_tops_o_gen_tables( _lFromKumulativ )
      RETURN .F.
   ENDIF

   kalk_tops_o_gen_tables( _lFromKumulativ ) // otvori tabele

   IF _lFromKumulativ
      open_kalk_as_pripr( cIdFirma, cIdVd, cBrDok ) // .T. => SQL table
   ENDIF

   _cre_katops_dbf( my_home() + _katops_table, _lFromKumulativ ) // kreiraj tabelu katops, ona ce se kreirati u privatnom direktoriju


   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   GO TOP

   IF !_lFromKumulativ
      cIdFirma := field->idfirma
      cIdVd := field->idvd
      cBrDok := field->brdok
   ENDIF

   SEEK cIdFirma + cIdVd + cBrDok

   nRbr := 0
   dDatDok := Date()


   aPosLokacije := {} // matrica pos mjesta koje kaci kalkulacija

   DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idvd == cIdVd .AND. field->brdok == cBrDok


      cStavke += AllTrim( idroba ) + " x " + AllTrim( Str( kolicina, 8, 2 ) ) + "; "

      select_o_roba( kalk_pripr->idroba )
      select_o_koncij( kalk_pripr->pkonto )

      cPKonto := kalk_pripr->pkonto

      IF Empty( koncij->idprodmjes ) // provjeri postoji li koncij zapis
         Msgbeep( "Nije definisano prodajno mjesto u tabeli konta - tipovi cijena !" )
         SELECT kalk_pripr
         RETURN .T.
      ENDIF

      SELECT katops
      APPEND BLANK

      cPm := koncij->idprodmjes
      IF AScan( aPosLokacije, {| x| x == koncij->idprodmjes } ) == 0
         AAdd( aPosLokacije, koncij->idprodmjes )
      ENDIF

      dDatDok := kalk_pripr->datdok

      REPLACE field->idfirma WITH self_organizacija_id()
      REPLACE field->idvd WITH kalk_pripr->idvd
      REPLACE field->idpos WITH koncij->idprodmjes
      REPLACE field->datdok WITH kalk_pripr->datdok
      REPLACE field->idkonto WITH kalk_pripr->idkonto
      REPLACE field->idkonto2 WITH kalk_pripr->idkonto2
      REPLACE field->idpartner WITH kalk_pripr->idpartner
      REPLACE field->idroba WITH kalk_pripr->idroba

      REPLACE field->kolicina WITH kalk_pripr->kolicina


      IF field->idvd == "IP"   // kod inventure
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


      IF kalk_pripr->pu_i == "3" // radi se o nivelaciji,  mpc - stara cijena
         REPLACE field->mpc WITH kalk_pripr->fcj
         REPLACE field->mpc2 WITH kalk_pripr->fcj + kalk_pripr->mpcsapp // mpc2 - nova cijena
      ENDIF

      IF kalk_pripr->pu_i == "5"
         REPLACE field->kolicina WITH -kolicina
      ENDIF

      IF Empty( koncij->idprodmjes )
         REPLACE field->idpos WITH gTops
      ENDIF

      _total += ( field->kolicina * field->mpc ) // saberi total
      ++ nRbr

      SELECT kalk_pripr
      SKIP

   ENDDO


   SELECT katops
   USE

   IF nRbr > 0
      kalk_tops_print_report( cIdFirma, cIdVd, cBrDok, nRbr, _total, cStavke, cPm, cPKonto ) // , _exp_file ) // ispisi report

      // _exp_file :=
      kalk_tops_kreiraj_fajl_prenosa( dDatDok, aPosLokacije, nRbr ) // napravi i prebaci izlazne fajlove gdje trebaju

      my_close_all_dbf()


   ENDIF

   my_close_all_dbf()

   RETURN .T.



STATIC FUNCTION kalk_tops_print_report( cIdFirma, cIdVd, cBrDok, nBrojStavki, nSaldo,  cStavke, cPm, cPKonto )

   // START PRINT CRET
   start_print_editor()
   ?
   ? Space( 2 ) + "Prenos KALK -> TOPS na dan: ", Date()
   ? Space( 2 ) + "---------------------------------------"
   // ? Space( 2 ) + "Formiran dokument: " + export_fajl
   ?
   ? Space( 2 ) + "KALK: " + cIdFirma + "-" + cIdVd + "-" + cBrDok, "PM:", cPm, "PKonto:", cPKonto
   ?
   ? Space( 2 ) + "Broj prenesenih stavki: " + AllTrim( Str( nBrojStavki ) )
   ? Space( 2 ) + "Saldo: " + AllTrim( Str( nSaldo, 10, 2 ) )
   ?
   ? Space( 2 ) + "Stavke:", cStavke

   IF cIdVd == "80" .AND. nSaldo == 0
      ? Space( 2 ) + "Predispozicija"
   ENDIF

   ?

   // ENDPRINT
   s_cTxtPrint := end_print_editor()

   RETURN .T.



FUNCTION kalk_destinacija_topska( cSet )

   IF s_cKalkDestinacijaTopska == NIL
      s_cKalkDestinacijaTopska := fetch_metric( "kalk_destinacija_topska", f18_user(), "" )
   ENDIF

   IF cSet != nil
      s_cKalkDestinacijaTopska := cSet
      set_metric( "kalk_destinacija_topska", f18_user(), AllTrim( cSet ) )
   ENDIF

   s_cKalkDestinacijaTopska := AllTrim( s_cKalkDestinacijaTopska )

   IF Right( s_cKalkDestinacijaTopska, 1 ) <> SLASH
      s_cKalkDestinacijaTopska := s_cKalkDestinacijaTopska + SLASH
   ENDIF

   RETURN s_cKalkDestinacijaTopska



STATIC FUNCTION kalk_tops_kreiraj_fajl_prenosa( datum, aPosLokacije, broj_stavki )

   LOCAL nI, _n
   LOCAL _dest_file, _dest_patt
   LOCAL _integ := {}
   LOCAL _table_name := "katops.dbf"
   LOCAL _table_path := my_home()
   LOCAL cExportHomeDir, cExporPosDir
   LOCAL cRet := ""
   LOCAL cTopsDest


   cTopsDest := kalk_destinacija_topska( cTopsDest )

   direktorij_kreiraj_ako_ne_postoji( cTopsDest ) // napravi direktorij prenosa ako ga nema
   cExportHomeDir := cTopsDest // export lokacija, bazna


   FOR _n := 1 TO Len( aPosLokacije ) // prodji kroz sve lokacije i postavi datoteke eksporta

      cExporPosDir := cExportHomeDir + AllTrim( aPosLokacije[ _n ] ) + SLASH // export ce biti u poddirektoriju kojem treba da bude, npr /prenos/1/

      direktorij_kreiraj_ako_ne_postoji( cExporPosDir ) // kreirati direktorij ako ne postoji

      DirChange( my_home() ) // nakon dir create prebaci se na my_local_folder

      _dest_patt := get_tops_kalk_export_file( "2", cExporPosDir, datum ) // pronadji naziv fajla koji je dozvoljen

      _dest_file := cExporPosDir + StrTran( _table_name, "katops.", _dest_patt + "." ) // kopiraj katops.dbf na destinaciju
      cRet := _dest_file

      IF FileCopy( _table_path + _table_name, _dest_file ) > 0
         _dest_file := StrTran( _dest_file, ".dbf", ".txt" ) // kopiraj txt fajl
         // FileCopy( my_home() + OUTF_FILE, _dest_file )
         FileCopy( s_cTxtPrint, _dest_file )
      ELSE
         MsgBeep( "Problem sa kopiranjem fajla na destinaciju #" + cExporPosDir )
      ENDIF

   NEXT

   RETURN cRet


// ---------------------------------------------------------------
// vraca naziv fajla za export
// ---------------------------------------------------------------
FUNCTION get_tops_kalk_export_file( topskalk, export_path, datum, prefix )

   LOCAL _file := ""
   LOCAL _prefix := "kt"
   LOCAL nI, _tmp
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

   FOR nI := 1 TO 99

      _tmp := PadL( AllTrim( Str( nI ) ), 2, "0" ) // nastavak na fajl
      _file := _prefix + _tmp_date + _tmp

      IF !File( export_path + _file + ".dbf" )
         // ovaj fajl moze da se koristi
         EXIT
      ENDIF
   NEXT

   RETURN _file





// -------------------------------------------
// kreiraj tabelu za prenos u TOPS
// -------------------------------------------
STATIC FUNCTION _cre_katops_dbf( dbf_table, lFromKumulativ )

   LOCAL _dbf

   IF lFromKumulativ == NIL
      lFromKumulativ := .F.
   ENDIF

   kalk_tops_o_gen_tables( lFromKumulativ )

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

   RETURN .T.




STATIC FUNCTION kalk_tops_prenos_prerequisites()

   LOCAL _ret := .F., cTopsDest

   cTopsDest := kalk_destinacija_topska()

   IF Empty( cTopsDest )
      MsgBeep( "Nije podesen direktorij za prenos podataka !" )
   ELSE
      _ret := .T.
   ENDIF

   IF _ret
      IF Pitanje(, "Generisati datoteku prenosa za modul TOPS (D/N) ?", "D" ) == "N"
         _ret := .F.
      ENDIF
   ENDIF

   RETURN _ret


/*
    tabele potrebne za generaciju
*/

STATIC FUNCTION kalk_tops_o_gen_tables( lFromKumulativ )

   IF lFromKumulativ == NIL
      lFromKumulativ := .F.
   ENDIF

   SELECT F_ROBA
   IF !Used()
      o_roba()
   ENDIF

   SELECT F_KONCIJ
   IF !Used()
      o_koncij()
   ENDIF

   IF lFromKumulativ == .T.
      // SELECT F_KALK

      // open_kalk_as_pripr( .T., cIdFirma, cIdVd, cBrDok ) // .T. => SQL table

   ELSE
      SELECT F_KALK_PRIPR
      IF !Used()
         o_kalk_pripr()
      ENDIF
   ENDIF

   RETURN .T.
