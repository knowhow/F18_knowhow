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

#define D_MAX_FILES     150


FUNCTION kalk_preuzmi_tops_dokumente()

   // cTopskaImeDbf, lAutoRazduzenje, nBarkodoviIzmjena, cIdKontoMagacin )


   // opcija za automatko svodjeje prodavnice na 0
   // ---------------------------------------------
   // prenese se tops promet u dokument 11
   // pa se prenese tops promet u dokument 42
   // IF lAutoRazduzenje == NIL
   // lAutoRazduzenje := fetch_metric( "kalk_tops_prenos_auto_razduzenje", my_user(), "N" )
   // ENDIF

   tops_kalk_o_import_tabele() // otvori tabele bitne za import podataka

   // IF cTopskaImeDbf == NIL
   tops_kalk_import_meni()


  /*
     IF ( cIdVdPos == "42" .AND. lAutoRazduzenje == "D" )
        cBrKalk  := kalk_get_next_broj_v5( self_organizacija_id(), "11", NIL )
     ELSE

        IF find_kalk_doks_by_broj_dokumenta( self_organizacija_id(), cIdVdPos, cBrKalk )
           Msg( "Vec postoji dokument pod brojem " + self_organizacija_id() + "-" + cIdVdPos + "-" + cBrKalk + "#Prenos nece biti izvrsen" )
           my_close_all_dbf()
           RETURN .F.
        ENDIF

     ENDIF

         my_close_all_dbf()
         RETURN .F.
      ENDIF
   ENDIF
*/

   RETURN .T.



STATIC FUNCTION tops_kalk_import_meni()

   LOCAL aOpcije := {}
   LOCAL cPosImportLokacija
   LOCAL aProdajnaMjesta, cProdajnaMjesta
   LOCAL lReturn := .T.
   LOCAL nI, aTopskaDbfs, _opt, _h, _n
   LOCAL cDbfImportUslov := "TK*.DBF"
   LOCAL lIzvrsitiPrenos, nMeniOdabir, _a_tmp1, _a_tmp2
   LOCAL cTopsDest := kalk_destinacija_topska()
   LOCAL cTopsKalkImeDbf
   LOCAL lStampaj

   aProdajnaMjesta := get_sva_prodajna_mjesta_iz_koncij()

   lStampaj := ( Pitanje( NIL, "Želite li štampati kalk dokumente?", "D" ) == "D" )

   IF Len( aProdajnaMjesta ) == 0
      MsgBeep( "U tabeli koncij nisu definisana prodajna mjesta !" ) // imamo problem, nema prodajnih mjesta
      lReturn := .F.
      RETURN lReturn
   ENDIF

   cProdajnaMjesta := ""
   FOR nI := 1 TO Len( aProdajnaMjesta )

      cProdajnaMjesta += AllTrim( aProdajnaMjesta[ nI ] ) + "; "
      cPosImportLokacija := cTopsDest + AllTrim( aProdajnaMjesta[ nI ] ) + SLASH  // putanja

      BrisiSFajlove( cPosImportLokacija ) // brisi sve fajlove starije od 28 dana
      aTopskaDbfs := Directory( cPosImportLokacija + cDbfImportUslov ) // fajlove u matricu po pattern-u

      // ASort( aTopskaDbfs,,, { | x, y | DToS( x[ 3 ] ) + x[ 4 ] < DToS( y[ 3 ] ) + y[ 4 ] } ) // datum + vrijeme

      AEval( aTopskaDbfs, {| aElem| AAdd( aOpcije, ;
         PadR( AllTrim( aProdajnaMjesta[ nI ] ) + SLASH + Trim( aElem[ 1 ] ), 20 ) + " " + ;
         UChkPostoji() + " " + DToC( aElem[ 3 ] ) + " " + aElem[ 4 ] ;
         ) }, 1, D_MAX_FILES ) // dodaj u matricu za odabir


   NEXT

   ASort( aOpcije,,, {| x, y| Right( x, 19 ) < Right( y, 19 ) } ) // R/X + datum + vrijeme

   _h := Array( Len( aOpcije ) )
   FOR _n := 1 TO Len( _h )
      _h[ _n ] := ""
   NEXT

   IF Len( aOpcije ) == 0 // ima li stavki za preuzimanje ?

      MsgBeep( "U direktoriju za prenos TOPS->KALK nema podataka ?##" + cTopsDest + "## ProdMj: " + cProdajnaMjesta )
      RETURN .F.

   ENDIF

   nMeniOdabir := 1
   lIzvrsitiPrenos := .F.

   DO WHILE .T.

      nMeniOdabir := meni_0( "topk", aOpcije, nMeniOdabir, .F. )
      IF nMeniOdabir == 0
         EXIT
      ENDIF

      cTopsKalkImeDbf := cTopsDest + AllTrim( Left( aOpcije[ nMeniOdabir ], 20 ) )
      tops_kalk_view_txt( cTopsKalkImeDbf )

      IF Pitanje(, "Želite li izvrsiti prenos TOPS->KALK ?", "D" ) == "N"
         nMeniOdabir++
         LOOP
      ENDIF

      IF !tops_kalk_fill_kalk_pripr( cTopsKalkImeDbf )
         nMeniOdabir := 0
         lIzvrsitiPrenos := .F.
         LOOP
      ENDIF

      kalk_pripr_auto_obrada_i_azuriranje( lStampaj )
      lIzvrsitiPrenos := .T.
      // nMeniOdabir := 0
      nMeniOdabir++

   ENDDO

   IF !lIzvrsitiPrenos
      RETURN .F.
   ENDIF

   RETURN lReturn


FUNCTION tops_kalk_fill_kalk_pripr( cTopskaImeDbf ) // , lAutoRazduzenje )

   LOCAL cBrKalk, cIdVdPos
   LOCAL cRedniBroj, nRedniBroj
   LOCAL cBrDok, cIdKontoProdavnica
   LOCAL _bk_tmp
   LOCAL _app_rec

   // LOCAL aRobaReportData := {}
   LOCAL nCount := 0

   // LOCAL _razd_type := "1"

   select_o_kalk_pripr()
   IF reccount2() > 0
      MsgBeep( "kalk priprema mora biti prazna##STOP!" )
      RETURN .F.
   ENDIF

   SELECT ( F_TMP_TOPSKA )  // otvori temp tabelu
   my_use_temp( "TOPSKA", cTopskaImeDbf )

   GO BOTTOM

   cBrKalk := Left( StrTran( DToC( field->datum ), ".", "" ), 4 ) + "/" + AllTrim( field->idpos ) // utvrditi broj kalkulacije
   cIdVdPos := field->idvd

   SELECT koncij // provjeri da li postoji podesenje za ovaj fajl importa
   LOCATE FOR koncij->idprodmjes == topska->idpos

   IF !Found()
      MsgBeep( "U šifarniku KONTA-TIPOVI CIJENA nije postavljeno#nigdje prodajno mjesto :" + field->idprodmjes + "#Prenos nije izvrsen." )
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   // SELECT topska
   // GO TOP

   // nacin zamjene barkod-ova
   // 0 - ne mjenjaj
   // 1 - ubaci samo nove
   // 2 - zamjeni sve

/*
   IF nBarkodoviIzmjena == NIL
      nBarkodoviIzmjena := tops_kalk_get_nacin_zamjene_barkodova()
   ENDIF
*/

/*
   IF ( cIdVdPos == "42" .AND. lAutoRazduzenje == "D" ) .OR. ( cIdVdPos == "12" )  // konto magacina za razduzenje
      IF cIdKontoMagacin == NIL
         cIdKontoMagacin := tops_kalk_get_magacinski_konto()
      ENDIF
   ENDIF
*/

/*
   IF lAutoRazduzenje == "D"  // konacno idemo na import
      _razd_type := auto_razd // razduziti kao 11 ili kao 42
   ENDIF
*/

   cRedniBroj := "0"

   MsgO( "Prenos stavki POS -> KALK priprema ..." )

   // SELECT roba
   // SET ORDER TO TAG "ID"

   SELECT topska
   GO TOP
   DO WHILE !Eof()

      // SELECT roba
      // SEEK topska->idroba
      IF !find_roba_by_id( topska->idroba )

         // IF !Found()
         MsgBeep( "artikal " + topska->idroba + " ne postoji u KALK roba ?!#STOP operacije!" )
         my_close_all_dbf()
         RETURN .F.
      ENDIF
      SELECT topska
      SKIP

   ENDDO


   SELECT TOPSKA
   GO TOP
   DO WHILE !Eof()

      // cBrDok := cBrKalk
      cIdKontoProdavnica := koncij->id
      nRedniBroj := RbrUNum( cRedniBroj ) + 1
      cRedniBroj := RedniBroj( nRedniBroj )

/*
      // provjeri da li roba postoji u sifarniku, ako ne postoji dodaj, dodati u kontrolnu matricu ove informacije
      tops_kalk_import_roba( AllTrim( koncij->naz ) )
*/

      IF ( cIdVdPos == "42" .OR. cIdVdPos == "12" )

         // IF lAutoRazduzenje == "D" .AND. _razd_type == "2"
         // tops_kalk_import_row_11( cBrDok, cIdKontoProdavnica, cIdKontoMagacin, cRedniBroj )
         // ELSE
         tops_kalk_import_row_42( cBrKalk, cIdKontoProdavnica, cRedniBroj )
         // ENDIF

      ELSEIF ( cIdVdPos == "IN" )
         tops_kalk_import_row_ip( cBrKalk, cIdKontoProdavnica, cRedniBroj )  // inventura

      ENDIF

/*
      IF nBarkodoviIzmjena > 0 // zamjena barkod-a ako postoji

         SELECT roba
         SET ORDER TO TAG "ID"
         SEEK topska->idroba

         IF Found()
            _bk_tmp := roba->barkod
            IF nBarkodoviIzmjena == 2 .OR. ( nBarkodoviIzmjena == 1 .AND. !Empty( topska->barkod ) .AND. topska->barkod <> _bk_tmp )
               _app_rec := dbf_get_rec()
               _app_rec[ "barkod" ] := topska->barkod
               update_rec_server_and_dbf( "roba", _app_rec, 1, "FULL" )
            ENDIF
         ENDIF

      ENDIF
*/

      ++nCount
      SELECT topska
      SKIP

   ENDDO

   MsgC()

   my_close_all_dbf()
   // tops_kalk_show_report_roba( aRobaReportData )  // prikazi report o razlikama cijena pos-kalk

   IF ( nCount > 0 ) // .AND. lAutoRazduzenje == "N"
      IF FErase( cTopskaImeDbf ) == -1 // pobrisi fajlove
         MsgBeep( "Problem sa brisanjem fajla !" )
      ENDIF
      FErase( get_topska_ime_txt( cTopskaImeDbf ) )
   ENDIF

   RETURN .T.


STATIC FUNCTION tops_kalk_view_txt( cTopskaImeDbf )

   LOCAL cTopskaImeTxt := get_topska_ime_txt( cTopskaImeDbf )

   RETURN editor( cTopskaImeTxt )


STATIC FUNCTION get_topska_ime_txt( cTopskaImeDbf )

   LOCAL cRet

   cRet := StrTran( cTopskaImeDbf, ".dbf", ".txt" )
   cRet := StrTran( cRet, ".DBF", ".TXT" )

   RETURN cRet

/*
FUNCTION kalk_preuzmi_tops_dokumente_auto()

   LOCAL _file := my_home() + "tk_auto.dbf"
   LOCAL _tip_prenosa
   LOCAL _datum_od, _datum_do
   LOCAL _id_vd_pos := "42"
   LOCAL _id_pm
   LOCAL _barkod_zamjena
   LOCAL _params
   LOCAL cIdKontoMagacin


   PRIVATE gIdPos // incijalizacija radi TOPS funkcija

   IF !kalk_tops_get_parametri_prenosa( @_params )
      RETURN .F.
   ENDIF

   _datum_od := _params[ "datum_od" ]
   _datum_do := _params[ "datum_do" ]
   _id_pm := _params[ "id_pm" ]
   _tip_prenosa := _params[ "tip_prenosa" ]
   _barkod_zamjena := _params[ "barkod_zamjena" ]
   cIdKontoMagacin := _params[ "konto_magacin" ]

   MsgO( "Formiranje fajla prenosa u toku... " )

   // obrisi neki postojeci
   FileDelete( _file )
   FileDelete( StrTran( _file, ".dbf", ".txt" ) )

#ifdef POS_PRENOS_POS_KALK
   pos_prenos_pos_kalk( _datum_od, _datum_do, _id_vd_pos, _id_pm ) // 1)  napraviti prenos u POS-u...
#endif

   FileCopy( my_home() + "pom.dbf", _file ) // 2) kopiraj fajl u potrebni...

   IF !File( _file )
      MsgC()
      MsgBeep( "Neki problem !?" )
      RETURN .F.
   ENDIF

   kalk_preuzmi_tops_dokumente( _file, _tip_prenosa, _barkod_zamjena, cIdKontoMagacin ) // 3) pa zatim isti preuzmi iz POS-a

   MsgC()

   // 4) nakon preuzimanja pobrisi fajl razmjene
   FileDelete( _file )
   FileDelete( StrTran( _file, ".dbf", ".txt" ) )

   o_kalk_pripr()
   IF RecCount() <> 0
      MsgBeep( "Prenos dokumenata uspjesan, nalazi se u pripremi !" )
   ENDIF

   my_close_all_dbf()

   RETURN .T.

*/

/*
STATIC FUNCTION tops_kalk_get_nacin_zamjene_barkodova()

   LOCAL _ret := 0
   LOCAL _x := 1

   Box(, 7, 60 )

   @ m_x + _x, m_y + 2 SAY "Zamjena barkod-ova"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "0 - bez zamjene"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "1 - ubaci samo nove"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "2 - zamjeni sve"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY Space( 15 ) + "=> odabir" GET _ret PICT "9"

   READ

   BoxC()

   RETURN _ret

*/

/*
STATIC FUNCTION kalk_tops_get_parametri_prenosa( params )

   LOCAL _ok := .F.
   LOCAL _d_od := Date()
   LOCAL _d_do := Date()
   LOCAL _x := 1
   LOCAL _id_pm := PadR( fetch_metric( "IDPos", NIL, "1 " ), 2 )
   LOCAL cIdKontoMagacin := PadR( "1320", 7 )
   LOCAL _type := "1"
   PRIVATE GetList := {}

   Box(, 8, 70 )

   @ m_x + _x, m_y + 2 SAY "*** Automatsko razduzenje prodavnice ***" COLOR f18_color_i()

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Za datum od:" GET _d_od
   @ m_x + _x, Col() + 1 SAY "do:" GET _d_do

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Prodajno mjesto:" GET _id_pm VALID !Empty( _id_pm )

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Formiraj: [1] kalk.42, [2] kalk.11" GET _type VALID _type $ "12"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Kod 11-ke konto magacina:" GET cIdKontoMagacin

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   _ok := .T.
   params := hb_Hash()
   params[ "datum_od" ] := _d_od
   params[ "datum_do" ] := _d_do
   params[ "id_pm" ] := _id_pm
   params[ "tip_prenosa" ] := _type
   params[ "barkod_zamjena" ] := 0
   params[ "konto_magacin" ] := cIdKontoMagacin

   gIdPos := _id_pm

   RETURN _ok

*/

/*
STATIC FUNCTION tops_kalk_get_magacinski_konto()

   LOCAL _konto := PadR( "1320", 7 )
   LOCAL nDbfArea := Select()

   O_KONTO
   SELECT konto

   Box(, 3, 60 )
   @ m_x + 2, m_y + 2 SAY "Magacinski konto:" GET _konto VALID P_Konto( @_konto )
   READ
   BoxC()

   SELECT ( nDbfArea )

   RETURN _konto

*/

/*
STATIC FUNCTION tops_kalk_show_report_roba( aReportData )

   LOCAL _i
   LOCAL nRazlikaPosKalkCijena := 0

   START PRINT CRET
   ?
   P_COND2

   ? "TOPS->KALK Razlike u cijenama:"
   ? "--------------------------------------"
   ? PadR( "R.br", 5 ), PadR( "ID", 10 ), PadR( "naziv", 40 ), PadR( "POS cijena", 12 ), PadR( "KALK cijena", 12 )
   ? Replicate( "-", 80 )

   FOR _i := 1 TO Len( aReportData )

      ? PadR( AllTrim( Str( _i, 4 ) ) + ".", 5 ), ;
         aReportData[ _i, 1 ], ;
         PadR( aReportData[ _i, 2 ], 40 ), ;
         Str( aReportData[ _i, 3 ], 12, 2 ), ;
         Str( aReportData[ _i, 4 ], 12, 2 )

      nRazlikaPosKalkCijena += aReportData[ _i, 3 ] - aReportData[ _i, 4 ]

   NEXT

   ? Replicate( "-", 80 )
   ? "Ukupno razlika:", AllTrim( Str( nRazlikaPosKalkCijena, 12, 2 ) )

   FF
   ENDPRINT

   RETURN .T.

*/

/*
STATIC FUNCTION tops_kalk_import_roba( cTipMpc )

   LOCAL nDbfArea := Select()
   LOCAL hRec, cMpcNaziv

   IF topska->( FieldPos( "robanaz" ) ) == 0  // ako nema ovog polja, nista ne radi !
      MsgBepp( "tposka->robanaz nedostaje, import se nece izvršiti" )
      RETURN .F.
   ENDIF

   // IF lUpdateRoba == NIL
   // lUpdateRoba := .F.
   // ENDIF

   SELECT roba
   HSEEK topska->idroba


   IF !Found()

      APPEND BLANK
      hRec := dbf_get_rec()
      hRec[ "id" ] := topska->idroba
      hRec[ "naz" ] := topska->robanaz
      hRec[ "idtarifa" ] := topska->idtarifa
      hRec[ "barkod" ] := topska->barkod
      IF topska->( FieldPos( "jmj" ) ) <> 0
         hRec[ "jmj" ] := topska->jmj
      ENDIF
      IF AllTrim( cTipMpc ) == "M1" .OR. Empty( cTipMpc )
         hRec[ "mpc" ] := topska->mpc
      ELSE
         cMpcNaziv := StrTran( cTipMpc, "M", "mpc" ) // M3 -> mpc3
         hRec[ cMpcNaziv ] := topska->mpc
      ENDIF

      update_rec_server_and_dbf( "roba", hRec, 1, "FULL" )
      //AAdd( aRobaImportReport, { topska->idroba, topska->robanaz, topska->mpc, 0 } ) // dodaj u kontrolnu matricu

   ELSE

      hRec := dbf_get_rec() //roba
      IF AllTrim( cTipMpc ) == "M1" .OR. Empty( cTipMpc )
         cMpcNaziv := "mpc"
      ELSE
         cMpcNaziv := StrTran( cTipMpc, "M", "mpc" ) // M3 -> mpc3
      ENDIF

      IF Round( hRec[ cMpcNaziv ], 2 ) <> Round( topska->mpc, 2 )

         //AAdd( aRobaImportReport, { topska->idroba, topska->robanaz, topska->mpc, hRec[ cMpcNaziv ] } )
         hRec[ cMpcNaziv ] := topska->mpc  // hRec[ "mpc2" ] := topska->mpc
         //IF lUpdateRoba
          //  update_rec_server_and_dbf( "roba", hRec, 1, "FULL" )
         //ENDIF

      ENDIF

   ENDIF

   SELECT ( nDbfArea )

   RETURN .T.
*/


/*
     formiraj stavku inventure prodavnice
*/

STATIC FUNCTION tops_kalk_import_row_ip( cBrDok, cIdKontoProdavnica, nRbr )

   LOCAL _tip_dok := "IP"
   LOCAL nDbfArea := Select()
   LOCAL _kolicina := 0
   LOCAL _nc := 0
   LOCAL _fc := 0
   LOCAL _mpcsapp := 0
   LOCAL _marzap := 50

   IF ( topska->kol2 == 0 )
      RETURN .F.
   ENDIF


   kalk_roba_prodavnica_stanje( cIdKontoProdavnica, topska->idroba, topska->datum, @_kolicina, @_nc, @_fc, @_mpcsapp ) // sracunaj za ovu stavku stanje inventurno u kalk-u

   IF _kolicina == 0 // nema ga na stanju, morat cemo preci na rucni rad racunice
      _mpcsapp := topska->mpc
      _nc := Round( _mpcsapp * ( _marzap / 100 ), 2 )

   ENDIF

   _mpcsapp := topska->mpc // uvijek uzmi iz topska ovu cijenu pri prenosu

   SELECT kalk_pripr

   my_flock()

   LOCATE FOR field->idroba == topska->idroba

   IF !Found() // kalk_pripr

      APPEND BLANK
      REPLACE field->idfirma WITH self_organizacija_id()
      REPLACE field->idvd WITH _tip_dok
      REPLACE field->brdok WITH cBrDok
      REPLACE field->datdok WITH topska->datum
      REPLACE field->datfaktp WITH topska->datum
      REPLACE field->kolicina WITH topska->kol2
      REPLACE field->gkolicina WITH _kolicina
      REPLACE field->gkolicin2 with ( gkolicina - kolicina )
      REPLACE field->idkonto WITH cIdKontoProdavnica
      // REPLACE field->idkonto2 WITH cIdKontoProdavnica
      REPLACE field->pkonto WITH cIdKontoProdavnica
      REPLACE field->idroba WITH topska->idroba
      REPLACE field->rbr WITH nRbr
      REPLACE field->idtarifa WITH topska->idtarifa
      REPLACE field->mpcsapp WITH _mpcsapp
      REPLACE field->nc WITH _nc
      REPLACE field->fcj WITH _fc
      REPLACE field->pu_i WITH "I"
      REPLACE field->error WITH "0"

   ELSE

      REPLACE field->kolicina WITH field->kolicina + topska->kol2
      REPLACE field->gkolicin2 with ( gkolicina - kolicina )

   ENDIF

   my_unlock()

   SELECT ( nDbfArea )

   RETURN .T.


/*
STATIC FUNCTION tops_kalk_import_row_11( cBrDok, cIdKontoProdavnica, cIdKontoMagacin, nRbr )

   LOCAL _tip_dok := "11"
   LOCAL nDbfArea := Select()

   IF ( topska->kolicina == 0 )
      RETURN .F.
   ENDIF

   SELECT kalk_pripr

   my_flock()

   APPEND BLANK

   REPLACE field->idfirma WITH self_organizacija_id()
   REPLACE field->idvd WITH _tip_dok
   REPLACE field->brdok WITH cBrDok
   REPLACE field->datdok WITH topska->datum
   REPLACE field->datfaktp WITH topska->datum
   REPLACE field->kolicina WITH topska->kolicina
   REPLACE field->idkonto WITH cIdKontoProdavnica
   REPLACE field->idkonto2 WITH cIdKontoMagacin
   REPLACE field->idroba WITH topska->idroba
   REPLACE field->rbr WITH nRbr
   REPLACE field->tmarza2 WITH "%"
   REPLACE field->idtarifa WITH topska->idtarifa
   REPLACE field->mpcsapp WITH topska->( mpc - stmpc )
   REPLACE field->tprevoz WITH "R"

   my_unlock()

   SELECT ( nDbfArea )

   RETURN .T.
*/


STATIC FUNCTION tops_kalk_import_row_42( cBrDok, cIdKontoProdavnica, nRbr )

   LOCAL nDbfArea := Select()
   LOCAL _opp

   IF ( topska->kolicina == 0 )
      RETURN .F.
   ENDIF

   SELECT tarifa
   HSEEK topska->idtarifa
   _opp := tarifa->opp

   SELECT kalk_pripr

   my_flock()

   APPEND BLANK

   REPLACE field->idfirma WITH self_organizacija_id()
   REPLACE field->idvd WITH topska->idvd
   REPLACE field->brdok WITH cBrDok
   REPLACE field->datdok WITH topska->datum
   REPLACE field->datfaktp WITH topska->datum
   REPLACE field->kolicina WITH topska->kolicina
   REPLACE field->idkonto WITH cIdKontoProdavnica
   REPLACE field->idroba WITH topska->idroba
   REPLACE field->rbr WITH nRbr
   REPLACE field->tmarza2 WITH "%"
   REPLACE field->idtarifa WITH topska->idtarifa
   REPLACE field->mpcsapp WITH topska->mpc

   IF Round( topska->stmpc, 2 ) <> 0
      IF _opp > 0
         REPLACE field->rabatv with ( topska->stmpc / ( 1 + ( _opp / 100 ) ) )  // izbijamo PDV iz ove stavke ako je tarifa PDV17
      ELSE
         REPLACE field->rabatv WITH topska->stmpc // tarifa nije PDV17
      ENDIF
   ENDIF

   my_unlock()

   SELECT ( nDbfArea )

   RETURN .T.





STATIC FUNCTION get_sva_prodajna_mjesta_iz_koncij()

   LOCAL _a_pm := {}
   LOCAL _scan

   SELECT koncij
   GO TOP

   DO WHILE !Eof()
      // ako nije prazno
      // ako je maloprodaja
      IF !Empty( field->idprodmjes ) .AND. Left( field->naz, 1 ) == "M"
         _scan := AScan( _a_pm, {| x| AllTrim( x ) == AllTrim( field->idprodmjes ) } )
         IF _scan == 0
            AAdd( _a_pm, AllTrim( field->idprodmjes ) )
         ENDIF
      ENDIF
      SKIP
   ENDDO

   RETURN _a_pm




STATIC FUNCTION tops_kalk_o_import_tabele()

   SELECT ( F_ROBA )
   IF !Used()
      O_ROBA
   ENDIF

   SELECT ( F_TARIFA )
   IF !Used()
      O_TARIFA
   ENDIF

   SELECT ( F_KALK_PRIPR )
   IF !Used()
      o_kalk_pripr()
   ENDIF

   SELECT ( F_KONCIJ )
   IF !Used()
      o_koncij()
   ENDIF

   RETURN .T.




FUNCTION kalk_roba_prodavnica_stanje( cIdKontoProdavnica, cIdRoba, dDatDok, nKolicina, nNabCj, nFakturnaCijena, nMaloprodajnaCijena )

   LOCAL _t_area := Select()
   LOCAL _ulaz, _izlaz, _mpvu, _mpvi, _rabat, _nvu, _nvi

   _ulaz := 0
   _izlaz := 0
   _mpvu := 0
   _mpvi := 0
   _rabat := 0
   _nvu := 0
   _nvi := 0

   nKolicina := 0
   nNabCj := 0
   nFakturnaCijena := 0
   nMaloprodajnaCijena := 0


   // SELECT roba
   // HSEEK cIdRoba
   IF !find_roba_by_id( cIdRoba )
      RETURN .F.
   ENDIF

   IF roba->tip $ "UI"
      SELECT ( _t_area )
      RETURN .F.
   ENDIF

   SELECT koncij
   HSEEK cIdKontoProdavnica

   SELECT kalk
   SET ORDER TO TAG "4"
   HSEEK self_organizacija_id() + cIdKontoProdavnica + cIdRoba

   DO WHILE !Eof() .AND. field->idfirma == self_organizacija_id() .AND. field->pkonto == cIdKontoProdavnica .AND. field->idroba == cIdRoba

      IF dDatDok < field->datdok
         // preskoci
         SKIP
         LOOP
      ENDIF

      IF field->pu_i == "1"
         _ulaz += field->Kolicina - field->gkolicina - field->gkolicin2
         _mpvu += field->mpcsapp * field->kolicina
         _nvu += field->nc * field->kolicina

      ELSEIF field->pu_i == "5" .AND. !( field->idvd $ "12#13#22" )
         _izlaz += field->kolicina
         _mpvi += field->mpcsapp * field->kolicina
         _nvi += field->nc * field->kolicina

      ELSEIF field->pu_i == "5" .AND. ( field->idvd $ "12#13#22" )
         // povrat
         _ulaz -= field->kolicina
         _mpvu -= field->mpcsapp * field->kolicina
         _nvu -= field->nc * field->kolicina

      ELSEIF field->pu_i == "3"
         // nivelacija
         _mpvu += field->mpcsapp * field->kolicina

      ELSEIF field->pu_i == "I"
         _izlaz += field->gkolicin2
         _mpvi += field->mpcsapp * field->gkolicin2
         _nvi += field->nc * field->gkolicin2
      ENDIF

      SKIP

   ENDDO


   IF Round( _ulaz - _izlaz, 4 ) <> 0

      nKolicina := _ulaz - _izlaz
      nFakturnaCijena := _mpvu - _mpvi
      nMaloprodajnaCijena := Round( ( _mpvu - _mpvi ) / ( _ulaz - _izlaz ), 3 )
      nNabCj := Round( ( _nvu - _nvi ) / ( _ulaz - _izlaz ), 3 )

   ENDIF

   RETURN .T.
