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


THREAD STATIC __KTO_DUG
THREAD STATIC __KTO_POT
THREAD STATIC __SH_SLD_VAR

// ----------------------------------------------------
// lJFill - samo se pune rn, drn pomocne tabele
// ----------------------------------------------------
FUNCTION StdokPDV( cIdFirma, cIdTipDok, cBrDok, lJFill )

   LOCAL cFax
   LOCAL lPrepisDok := .F.
   LOCAL _dok := hb_Hash(), _fill_params := hb_Hash()
   LOCAL _fakt_params := fakt_params()

   // samo kolicine
   LOCAL lSamoKol := .F.

   IF lJFill == NIL
      lJFill := .F.
   ENDIF

   IF PCount() == 4 .AND. ( cIdtipDok <> nil )
      lPrepisDok := .T.
      _fill_params[ "from_server" ] := .T.
      close_open_fakt_tabele( .T. )
   ELSE
      _fill_params[ "from_server" ] := .F.
      close_open_fakt_tabele()
   ENDIF

   close_open_racun_tbl()
   zap_racun_tbl()

   SELECT fakt_pripr

   // barkod artikla
   PRIVATE lPBarkod := .F.

   IF _fakt_params[ "barkod" ] $ "12"  // pitanje, default "N"
      lPBarkod := ( Pitanje( , "Želite li ispis barkodova ?", iif( _fakt_params[ "barkod" ] == "1", "N", "D" ) ) == "D" )
   ENDIF

   IF PCount() == 0 .OR. ( cIdTipDok == NIL .AND. lJFill == .T. )
      cIdTipdok := field->idtipdok
      cIdFirma := field->IdFirma
      cBrDok := field->BrDok
   ENDIF

   SEEK cIdFirma + cIdTipDok + cBrDok
   NFOUND CRET

   IF PCount() <= 1 .OR. ( cIdTipDok == NIL .AND. lJFill == .T. )
      SELECT fakt_pripr
   ENDIF

   // napuni podatke za stampu
   _dok[ "idfirma" ] := field->IdFirma
   _dok[ "idtipdok" ] := field->IdTipDok
   _dok[ "brdok" ] := field->BrDok
   _dok[ "datdok" ] := field->DatDok

   cDocumentName := doc_name( _dok, fakt_pripr->IdPartner )

   // prikaz samo kolicine
   IF cIdTipDok $ "01#00#12#13#19#21#22#23#26"
      IF ( ( gPSamoKol == "0" .AND. Pitanje(, "Prikazati samo kolicine (D/N)", "N" ) == "D" ) ) ;
            .OR. gPSamoKol == "D"
         lSamoKol := .T.
      ENDIF
   ENDIF

   IF Val( podbr ) = 0 .AND. Val( rbr ) == 1
   ELSE
      Beep( 2 )
      Msg( "Prva stavka mora biti  '1.'  ili '1 ' !", 4 )
      RETURN
   ENDIF

   _fill_params[ "barkod" ] := lPBarkod
   _fill_params[ "samo_kolicine" ] := lSamoKol

   IF !fill_porfakt_data( _dok, _fill_params )
      RETURN
   ENDIF

   IF lJFill
      RETURN
   ENDIF

   my_close_all_dbf()

   IF cIdTipDok $ "13#23"
      // stampa 13-ke
      omp_print()
   ELSE
      IF cIdTipDok == "11" .AND. gMPPrint $ "DXT"

         IF gMPPrint == "D" .OR. ( gMpPrint == "X" .AND. Pitanje(, "Stampati na traku (D/N)?", "D" ) == "D" ) .OR. gMPPrint == "T"

            // stampa na traku
            gLocPort := "LPT" + AllTrim( gMpLocPort )

            lStartPrint := .T.

            cPrn := gPrinter
            gPrinter := "0"

            IF gMPPrint == "T"
               // test mode
               gPrinter := "R"
            ENDIF

            st_rb_traka( lStartPrint, lPrepisDok )

            gPrinter := cPrn

         ELSE
            pf_a4_print( nil, cDocumentName )
         ENDIF

      ELSE
         pf_a4_print( nil, cDocumentName )
      ENDIF

   ENDIF

   my_close_all_dbf()

   RETURN


// ----------------------------------------------------------------------
// puni  pomocne tabele rn drn
// ----------------------------------------------------------------------
STATIC FUNCTION fill_porfakt_data( dok, params )

   LOCAL cTxt1, cTxt2, cTxt3, cTxt4, cTxt5
   LOCAL cIdPartner
   LOCAL dDatDok
   LOCAL cDestinacija
   LOCAL dDatVal
   LOCAL dDatIsp
   LOCAL aMemo
   LOCAL cIdRoba := ""
   LOCAL cRobaNaz := ""
   LOCAL cRbr := ""
   LOCAL cPodBr := ""
   LOCAL cJmj := ""
   LOCAL i
   LOCAL nTmp
   LOCAL nKol := 0
   LOCAL nCjPDV := 0
   LOCAL nCjBPDV := 0
   LOCAL nPopust := 0 // proc popusta
   LOCAL nPopNaTeretProdavca := 0
   LOCAL nVPDV := 0
   LOCAL nCj2PDV := 0
   LOCAL nCj2BPDV := 0
   LOCAL nPPDV := 0
   LOCAL nRCijen := 0
   LOCAL nCSum := 0
   LOCAL nTotal := 0
   LOCAL nUkBPDV := 0
   LOCAL nUkBPDVPop := 0
   LOCAL nUkVPop := 0
   LOCAL nVPopust := 0
   LOCAL nVPopNaTeretProdavca := 0
   LOCAL nUkPDV := 0
   LOCAL nUkPopNaTeretProdavca := 0
   LOCAL cTime := ""
   LOCAL cDinDem
   LOCAL nRec
   LOCAL nZaokr
   LOCAL nFZaokr := 0
   LOCAL nDrnZaokr := 0
   LOCAL cDokNaz
   LOCAL nUkKol := 0
   LOCAL lIno := .F.
   LOCAL cPdvOslobadjanje := ""
   LOCAL nPom1
   LOCAL nPom2
   LOCAL nPom3
   LOCAL nPom4
   LOCAL nPom5
   LOCAL cOpis := ""
   LOCAL _a_tmp, _tmp

   LOCAL lPdvObveznik := .F.

   LOCAL nDx1 := 0
   LOCAL nDx2 := 0
   LOCAL nDx3 := 0
   LOCAL nSw1 := 72
   LOCAL nSw2 := 1
   LOCAL nSw3 := 72
   LOCAL nSw4 := 31
   LOCAL nSw5 := 1
   LOCAL nSw6 := 1
   LOCAL nSw7 := 0

   LOCAL _fakt_params := fakt_params()

   // radi citanja parametara
   PRIVATE cSection := "F"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   SELECT F_PARAMS
   IF !Used()
      O_PARAMS
   ENDIF
   RPar( "x1", @nDx1 )
   RPar( "x2", @nDx2 )
   RPar( "x3", @nDx3 )

   RPar( "x4", @nSw1 )
   RPar( "x5", @nSw2 )
   RPar( "x6", @nSw3 )
   RPar( "x7", @nSw4 )
   // ovaj switch se koristi za poziv ptxt-a ... u principu
   // ovdje mi i ne treba
   RPar( "x8", @nSw5 )
   // narudzbenice - samo kolicine 0, cijene 1
   RPar( "x9", @nSw6 )
   RPar( "y1", @nSw7 )

   // napuni firmine podatke
   fill_firm_data()

   SELECT fakt_pripr

   // napuni podatke partnera

   lPdvObveznik := is_pdv_obveznik( field->idpartner )
   fill_part_data( field->idpartner, @lPdvObveznik )

   // popuni ostale podatke, radni nalog i slicno
   fill_other()

   SELECT fakt_pripr

   // vrati naziv dokumenta
   get_dok_naz( @cDokNaz, field->idtipdok, field->idvrstep, params[ "samo_kolicine" ] )

   SELECT fakt_pripr

   dDatDok := dok[ "datdok" ]

   dDatVal := dDatDok
   dDatIsp := dDatDok
   cDinDem := dindem

   nRec := RecNo()

   // ukupna kolicina
   nUkKol := 0

   DEC_CIJENA( ZAO_CIJENA() )
   DEC_VRIJEDNOST( ZAO_VRIJEDNOST() )

   lIno := .F.
   DO WHILE !Eof() .AND. field->idfirma == dok[ "idfirma" ] .AND. ;
         field->idtipdok == dok[ "idtipdok" ] .AND. ;
         field->brdok == dok[ "brdok" ]

      // Nastimaj (hseek) Sifr.Robe Na fakt_pripr->IdRoba
      // NSRNPIdRoba()
      SELECT roba
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK fakt_pripr->idroba

      IF !Found()
         Msgbeep( "Artikal " + fakt_pripr->idroba + " ne postoji u sifrarniku !!!" )
         RETURN .F.
      ENDIF

      // nastimaj i tarifu
      SELECT tarifa
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK roba->idtarifa

      IF !Found()
         MsgBeep( "Tarifa " + roba->idtarifa + " ne postoji u sifraniku !!!" )
         RETURN .F.
      ENDIF

      SELECT fakt_pripr

      aMemo := ParsMemo( field->txt )
      cIdRoba := field->idroba

      IF roba->tip == "U"
         cRobaNaz := aMemo[ 1 ]
      ELSE
         cRobaNaz := AllTrim( roba->naz )
         IF params[ "barkod" ]
            cRobaNaz := cRobaNaz + " (BK: " + roba->barkod + ")"
         ENDIF
      ENDIF

      // ako je roba grupa:
      IF glRGrPrn == "D"
         cPom := _op_gr( roba->id, "GR1" ) + ": " + _val_gr( roba->id, "GR1" ) + ;
            ", " + _op_gr( roba->id, "GR2" ) + ": " + _val_gr( roba->id, "GR2" )

         cRobaNaz += " "
         cRobaNaz += cPom
         SELECT fakt_pripr
      ENDIF

      // dodaj i vrijednost iz polja SERBR
      IF !Empty( AllTrim( fakt_pripr->serbr ) )
         cRobaNaz := cRobaNaz + ", " + AllTrim( fakt_pripr->serbr )
      ENDIF

      // resetuj varijable sa cijenama
      nCjPDV := 0
      nCj2PDV := 0
      nCjBPDV := 0
      nCj2BPDV := 0
      nVPopust := 0
      nPPDV := 0

      cRbr := field->rbr
      cPodBr := field->podbr
      cJmj := roba->jmj

      // procenat pdv-a
      nPPDV := tarifa->opp

      cIdPartner := field->idpartner

      IF Empty( cIdPartner )
         MsgBeep( "Partner na fakturi - prazno - nesto nije ok !????" )
         RETURN .F.
      ENDIF

      IF _fakt_params[ "fakt_opis_stavke" ]
         dok[ "rbr" ] := rbr
         cOpis := get_fakt_atribut_opis( dok, params[ "from_server" ] )
         SELECT fakt_pripr
      ELSE
         cOpis := ""
      ENDIF

      // rn Veleprodaje
      IF dok[ "idtipdok" ] $ "10#11#12#13#20#22#25"

         // ino faktura
         IF IsIno( cIdPartner )
            nPPDV := 0
            lIno := .T.
         ENDIF

         // ako je po nekom clanu PDV-a partner oslobodjenj
         // placanja PDV-a
         cPdvOslobadjanje := PdvOslobadjanje( cIdPartner )
         IF !Empty( cPdvOslobadjanje )
            nPPDV := 0
         ENDIF

      ENDIF

      IF dok[ "idtipdok" ] == "12"
         IF IsProfil( cIdPartner, "KMS" )
            // radi se o komisionaru
            nPPDV := 0
         ENDIF
      ENDIF

      // kolicina
      nKol := field->kolicina
      nRCijen := field->cijena

      IF Left( fakt_pripr->DINDEM, 3 ) <> Left( ValBazna(), 3 )
         // preracunaj u EUR
         // omjer EUR / KM
         nRCijen := nRCijen / OmjerVal( ValBazna(), fakt_pripr->DINDEM, fakt_pripr->datdok )
         nRCijen := Round( nRCijen, DEC_CIJENA() )
      ENDIF

      // resetuj prije eventualnog setovanja
      nPopNaTeretProdavca := 0

      // zasticena cijena, za krajnjeg kupca
      IF RobaZastCijena( tarifa->id )  .AND. !lPdvObveznik
         // krajnji potrosac
         // roba sa zasticenom cijenom
         nPopNaTeretProdavca := field->rabat
         nPopust := 0
      ELSE
         // rabat - popust
         nPopust := field->rabat
         nPopNaTeretProdavca := 0
      ENDIF

      // ako je 13-ka ili 27-ca
      // cijena bez pdv se utvrdjuje unazad
      IF ( field->idtipdok == "13" .AND. glCij13Mpc ) .OR. ( field->idtipdok $ "11#27" .AND. gMP $ "1234567" )
         // cjena bez pdv-a
         nCjPDV := nRCijen
         nCjBPDV := ( nRCijen / ( 1 + nPPDV / 100 ) )
      ELSE
         // cjena bez pdv-a
         nCjBPDV := nRCijen
         nCjPDV := ( nRCijen * ( 1 + nPPDV / 100 ) )
      ENDIF

      nVPopust := 0

      // izracunaj vrijednost popusta
      IF Round( nPopust, 4 ) <> 0
         // vrijednost popusta
         nVPopust := ( nCjBPDV * ( nPopust / 100 ) )
      ENDIF

      // resetuj prije eventualnog setovanja
      nVPopNaTeretProdavca := 0

      // izacunaj vrijednost popusta na teret prodavca
      IF Round( nPopNaTeretProdavca, 4 ) <> 0
         // vrijednost popusta
         nVPopNaTeretProdavca := ( nCjBPDV * ( nPopNaTeretProdavca / 100 ) )
      ENDIF


      // cijena sa popustom bez pdv-a
      nCj2BPDV := ( nCjBPDV - nVPopust )
      // izracuna PDV na cijenu sa popustom
      nCj2PDV := ( nCj2BPDV * ( 1 + nPPDV / 100 ) )

      // ukupno stavka
      nUkStavka := nKol * nCj2PDV
      nUkStavke := Round( nUkStavka, ZAO_VRIJEDNOST() + iif( idtipdok $ "11#13", 4, 0 ) )

      nPom1 := nKol * nCjBPDV
      nPom1 := Round( nPom1, ZAO_VRIJEDNOST() + iif( idtipdok $ "11#13", 4, 0 ) )
      // ukupno bez pdv
      nUkBPDV += nPom1


      // ukupno popusta za stavku
      nPom2 := nKol * nVPopust
      nPom2 := Round( nPom2, ZAO_VRIJEDNOST() + iif( idtipdok $ "11#13", 4, 0 ) )
      nUkVPop += nPom2

      // preracunaj VPDV sa popustom
      nVPDV := ( nCj2BPDV * ( nPPDV / 100 ) )


      // ukupno vrijednost bez pdva sa uracunatim poputstom
      nPom3 := nPom1 - nPom2
      nPom3 := Round( nPom3, ZAO_VRIJEDNOST() + iif( idtipdok $ "11#13", 4, 0 ) )
      nUkBPDVPop += nPom3


      // ukupno PDV za stavku = (ukupno bez pdv - ukupno popust) * stopa
      nPom4 := nPom3 * nPPDV / 100
      // povecaj preciznost
      nPom4 := Round( nPom4, ZAO_VRIJEDNOST() + iif( idtipdok $ "11#13", 4, 2 ) )
      nUkPDV += nPom4

      // ukupno za stavku sa pdv-om
      nTotal +=  nPom3 + nPom4

      nPom5 := nKol * nVPopNaTeretProdavca
      nPom5 := Round( nPom5, ZAO_VRIJEDNOST() )
      nUkPopNaTeretProdavca += nPom5

      ++ nCSum

      nUkKol += nKol

      dodaj_stavku_racuna( dok[ "brdok" ], cRbr, cPodBr, cIdRoba, cRobaNaz, cJmj, nKol, nCjPDV, nCjBPDV, nCj2PDV, nCj2BPDV, nPopust, nPPDV, nVPDV, nUkStavka, nPopNaTeretProdavca, nVPopNaTeretProdavca, "", "", "", cOpis )

      SELECT fakt_pripr
      SKIP

   ENDDO

   // zaokruzi pdv na zao_vrijednost()
   nUkPDV := Round( nUkPDV, ZAO_VRIJEDNOST() )

   nTotal := ( nUkBPDVPop + nUkPDV )


   nFZaokr := zaokr_5pf( nTotal )
   IF gZ_5pf == "N"
      nFZaokr := 0
   ENDIF


   IF ( gFZaok <> 9 .AND. Round( nFZaokr, 4 ) <> 0 )
      nDrnZaokr := nFZaokr
   ENDIF

   nTotal := Round( nTotal - nDrnZaokr, ZAO_VRIJEDNOST() )

   nUkPopNaTeretProdavca := Round( nUkPopNaTeretProdavca, ZAO_VRIJEDNOST() )
   nUkBPDV := Round( nUkBPDV, ZAO_VRIJEDNOST() )
   nUkVPop := Round( nUkVPop, ZAO_VRIJEDNOST() )

   SELECT fakt_pripr
   GO ( nRec )

   // nafiluj ostale podatke vazne za sam dokument
   aMemo := ParsMemo( txt )
   dDatDok := datdok

   IF Len( aMemo ) <= 5
      dDatVal := dDatDok
      dDatIsp := dDatDok
      cBrOtpr := ""
      cBrNar  := ""
   ELSE
      dDatVal := CToD( aMemo[ 9 ] )
      dDatIsp := CToD( aMemo[ 7 ] )
      cBrOtpr := aMemo[ 6 ]
      cBrNar  := aMemo[ 8 ]
   ENDIF

   // destinacija na fakturi
   IF Len( aMemo ) >= 18
      cDestinacija := aMemo[ 18 ]
   ELSE
      cDestinacija := ""
   ENDIF

   // dokument_veza
   IF Len( aMemo ) >= 19
      cM_d_veza := aMemo[ 19 ]
   ELSE
      cM_d_veza := ""
   ENDIF

   IF Len( aMemo ) >= 20
      cObjekti := aMemo[ 20 ]
   ELSE
      cObjekti := ""
   ENDIF

   // mjesto
   add_drntext( "D01", gMjStr )
   // naziv dokumenta
   add_drntext( "D02", cDokNaz )

   // slovima iznos fakture
   add_drntext( "D04", Slovima( nTotal - nUkPopNaTeretProdavca, cDinDem ) )

   // broj otpremnice
   add_drntext( "D05", cBrOtpr )

   // broj narudzbenice
   add_drntext( "D06", cBrNar )

   // DM/EURO
   add_drntext( "D07", cDinDem )

   // Destinacija
   add_drntext( "D08", cDestinacija )

   // objekakt
   IF !Empty( cObjekti )
      add_drntext( "O01", cObjekti )
      add_drntext( "O02", fakt_objekat_naz( cObjekti ) )
   ENDIF

   // tip dokumenta
   add_drntext( "D09", dok[ "idtipdok" ] )

   // radna jedinica
   add_drntext( "D10", dok[ "idfirma" ] )

   // dokument veza
   cTmp := cM_d_veza

   aTmp := SjeciStr( cTmp, 200 )
   nTmp := 30

   // koliko ima redova
   add_drntext( "D30", AllTrim( Str( Len( aTmp ) ) ) )
   FOR i := 1 TO Len( aTmp )
      add_drntext( "D" + AllTrim( Str( nTmp + i ) ), aTmp[ i ] )
   NEXT

   // tekst na kraju fakture F04, F05, F06
   fill_dod_text( aMemo[ 2 ], fakt_pripr->idpartner )

   // potpis na kraju
   fill_potpis( dok[ "idtipdok" ] )

   // parametri generalni za stampu dokuemnta
   // lijeva margina
   add_drntext( "P01", AllTrim( Str( gnLMarg ) ) )

   // zaglavlje na svakoj stranici
   add_drntext( "P04", if( gZagl == "1", "D", "N" ) )

   // prikaz dodatnih podataka
   add_drntext( "P05", if( gDodPar == "1", "D", "N" ) )
   // dodati redovi po listu

   add_drntext( "P06", AllTrim( Str( gERedova ) ) )

   // gornja margina
   add_drntext( "P07", AllTrim( Str( gnTMarg ) ) )

   // da li se formira automatsko zaglavlje
   add_drntext( "P10", gStZagl )

   DO CASE

   CASE lIno
      // ino faktura
      add_drntext( "P11", "INO" )

   CASE !Empty( cPdvOslobadjanje )
      add_drntext( "P11", cPdvOslobadjanje )

   OTHERWISE
      // domaca faktura
      add_drntext( "P11", "DOMACA" )

   ENDCASE

   // redova iznad "kupac"
   add_drntext( "X01", Str( nDx1, 2, 0 ) )
   // redova ispod "kupac"
   add_drntext( "X02", Str( nDx2, 2, 0 ) )
   // redova izmedju broja narudbze i tabele
   add_drntext( "X03", Str( nDx3, 2, 0 ) )


   add_drntext( "X04", Str( nSw1, 2, 0 ) )
   add_drntext( "X05", Str( nSw2, 2, 0 ) )
   add_drntext( "X06", Str( nSw3, 2, 0 ) )
   add_drntext( "X07", Str( nSw4, 2, 0 ) )
   add_drntext( "X08", Str( nSw5, 2, 0 ) )
   add_drntext( "X09", Str( nSw6, 1, 0 ) )
   add_drntext( "X10", Str( nSw7, 1, 0 ) )

   // header i footer - broj redova
   IF gPDFPrint == "D"
      add_drntext( "X11", Str( gFPicHRow, 2, 0 ) )
      add_drntext( "X12", Str( gFPicFRow, 1, 0 ) )
   ELSE
      // ako nije pdf stampa - nema parametara....
      add_drntext( "X11", Str( 0 ) )
      add_drntext( "X12", Str( 0 ) )
   ENDIF

   // fakturu stampaj u ne-compatibility modu
   gPtxtC50 := .F.
   DO CASE
   CASE nSw5 == 0
      gPtxtSw := "/noline /s /l /p"
   CASE nSw5 == 1
      gPtxtSw := "/p"

   OTHERWISE
      // citaj ini fajl
      gPtxtSw := nil
   ENDCASE


   // dodaj total u DRN
   add_drn( dok[ "brdok" ], dok[ "datdok" ], dDatVal, dDatIsp, cTime, nUkBPDV, nUkVPop, nUkBPDVPop, nUkPDV, nTotal, nCSum, nUkPopNaTeretProdavca, nDrnZaokr, nUkKol )

   IF ( dok[ "idtipdok" ] $ "10#11" ) .AND. Round( nUkPDV, 2 ) == 0
      IF Pitanje(, "Faktura je bez iznosa PDV-a! Da li je to uredu (D/N)", "D" ) == "N"
         RETURN .F.
      ENDIF
   ENDIF

   RETURN .T.


// -------------------------------------
// vraca opis grupe iz sifK
// -------------------------------------
STATIC FUNCTION _op_gr( cId, cSifK )

   LOCAL nTArea := Select()
   LOCAL cRet := ""

   O_SIFK
   SELECT sifk
   SET ORDER TO TAG "ID2"
   GO TOP
   SEEK PadR( "ROBA", 8 ) + PadR( cSifK, 4 )

   IF Found()
      cRet := AllTrim( field->naz )
   ENDIF

   SELECT ( nTArea )

   RETURN cRet


// -------------------------------------
// vraca vrijednost grupe iz sifK
// -------------------------------------
STATIC FUNCTION _val_gr( cId, cSifK )

   LOCAL cRet := ""

   cRet := IzSifKRoba( cSifK, cId, .F. )
   IF cRet == nil
      cRet := ""
   ENDIF

   RETURN AllTrim( cRet )


// ----------------------------------
// ----------------------------------
STATIC FUNCTION fill_potpis( cIdVD )

   LOCAL cPom
   LOCAL cPotpis

   IF ( cIdVd $ "01#00" )
      cPotpis := Replicate( " ", 12 ) + "Odobrio" + Replicate( " ", 25 ) + "Primio"

   ELSEIF cIdVd $ "19"
      cPotpis := Replicate( " ", 12 ) + "Odobrio" + Replicate( " ", 25 ) + "Predao"
   ELSE
      cPom := "G" + cIdVD + "STR2T"
      cPotpis := &cPom
   ENDIF

   // potpis
   add_drntext( "F10", cPotpis )

   RETURN


// -----------------------------------------------
// popunjavanje ostalih podataka fakture
// -----------------------------------------------
STATIC FUNCTION fill_other()

   // broj fiskalnog isjecka
   add_drntext( "O10", fisc_isjecak( fakt_pripr->idfirma, fakt_pripr->idtipdok, ;
      fakt_pripr->brdok ) )

   // traka - ispis, cjene bez pdv, sa pdv (1) bez pdv, (2) sa pdv
   cPom := gMPCjenPDV
   add_drntext( "P20", cPom )

   // stampa id roba na racunu D/N
   cPom := gMPArtikal
   add_drntext( "P21", cPom )

   // redukcija trake 0/1/2
   cPom := gMpRedTraka
   add_drntext( "P22", cPom )

   // ispis kupca na racunu
   cPom := "D"
   add_drntext( "P23", cPom )

   // mjesto
   cPom := gMjStr
   add_drntext( "R01", cPom )

   IF gSecurity == "D"
      // naziv operatera
      cPom := getfullusername( getuserid() )
      add_drntext( "R02", cPom )
   ENDIF

   // smjena
   cPom := "1"
   add_drntext( "R03", cPom )

   // vrsta placanja
   cPom := "GOTOVINA"
   add_drntext( "R05", cPom )

   // dodatni tekst racuna
   cPom := ""
   add_drntext( "R06", cPom )
   add_drntext( "R07", cPom )
   add_drntext( "R08", cPom )

   // broj linija za odcjep.trake
   cPom := "8"
   add_drntext( "P12", cPom )

   // sekv.otvaranje ladice
   cPom := ""
   add_drntext( "P13", cPom )

   // sekv.cjepanje trake
   cPom := ""
   add_drntext( "P14", cPom )

   // prodajno mjesto
   cPom := "prod. 1"
   add_drntext( "I04", cPom )

   RETURN


// --------------------------------------------------------------
// daj naziv dokumenta iz parametara
// --------------------------------------------------------------
FUNCTION get_dok_naz( cNaz, cIdVd, cVP, lSamoKol )

   LOCAL cPom
   LOCAL cSamoKol

   IF ( cIdVd == "01" )
      cNaz := "Prijem robe u magacin br."
   ELSEIF ( cIdVd == "00" )
      cNaz := "Pocetno stanje br."
   ELSEIF ( cIdVD == "19" )
      cNaz := "Izlaz po ostalim osnovama br."
   ELSEIF ( cIdVD == "10" .AND. cVP == "AV" )
      cNaz := "Avansna faktura br."
   ELSE
      cPom := "G" + cIdVd + "STR"
      cNaz := &cPom
   ENDIF

   // ako je lSamoKol := .t. onda je prikaz samo kolicina
   cSamoKol := "N"
   IF lSamoKol
      cSamoKol := "D"
   ENDIF

   add_drntext( "P03", cSamoKol )

   RETURN

// -----------------------------------------------
// filovanje dodatnog teksta
// cTxt - dodatni tekst
// cPartn - id partner
// -----------------------------------------------
STATIC FUNCTION fill_dod_text( cTxt, cPartn )

   LOCAL aLines // matrica sa linijama teksta
   LOCAL nFId // polje Fnn counter od 20 pa nadalje
   LOCAL nCnt // counter upisa u DRNTEXT
   LOCAL aTxt, n, i

   // obradi djokere...
   _txt_djokeri( @cTxt, cPartn )

   // slobodni tekst se upisuje u DRNTEXT od F20 -- F50
   cTxt := StrTran( cTxt, "" + Chr( 10 ), "" )
   // daj mi matricu sa tekstom line1, line2 itd...
   aLines := TokToNiz( cTxt, Chr( 13 ) + Chr( 10 ) )

   nFId := 20
   nCnt := 0
   FOR i := 1 TO Len( aLines )
      aTxt := SjeciStr( aLines[ i ], 250 )
      FOR n := 1 TO Len( aTxt )
         add_drntext( "F" + AllTrim( Str( nFId ) ), aTxt[ n ] )
         ++ nFId
         ++ nCnt
      NEXT
   NEXT

   // dodaj i parametar koliko ima linija texta
   add_drntext( "P02", AllTrim( Str( nCnt ) ) )

   RETURN



// ----------------------------------------
// obradi djokere
// cTxt - txt polje
// cPartn - id partner
// ----------------------------------------
FUNCTION _txt_djokeri( cTxt, cPartn )

   LOCAL cPom
   LOCAL cPom2
   LOCAL nSaldoKup
   LOCAL nSaldoDob
   LOCAL dPUplKup
   LOCAL dPPromKup
   LOCAL dPPromDob
   LOCAL cStrSlKup := "#SALDO_KUP#"
   LOCAL cStrSlDob := "#SALDO_DOB#"
   LOCAL cStrSlKD := "#SALDO_KUP_DOB#"
   LOCAL cStrDUpKup := "#D_P_UPLATA_KUP#"
   LOCAL cStrDPrKup := "#D_P_PROMJENA_KUP#"
   LOCAL cStrDPrDob := "#D_P_PROMJENA_DOB#"

   IF gShSld == "N"
      RETURN
   ENDIF

   IF gFinKtoDug <> nil

      __KTO_DUG := gFinKtoDug
      __KTO_POT := gFinKtoPot

   ENDIF

   // varijanta prikaza salda... 1 ili 2
   __SH_SLD_VAR := gShSldVar

   // saldo kupca
   nSaldoKup := get_fin_partner_saldo( cPartn, __KTO_DUG, gFirma )

   // saldo dobavljaca
   nSaldoDob := get_fin_partner_saldo( cPartn, __KTO_POT, gFirma )

   // datum zadnje uplate kupca
   dPUplKup := g_dpupl_part( cPartn, __KTO_DUG, gFirma )

   // datum zadnje promjene kupac
   dPPromKup := g_dpprom_part( cPartn, __KTO_DUG, gFirma )

   // datum zadnje promjene dobavljac
   dPPromDob := g_dpprom_part( cPartn, __KTO_POT, gFirma )


   // -------------------------------------------------------
   // SALDO KUPCA
   // -------------------------------------------------------
   IF At( cStrSlKup, cTxt ) <> 0

      IF gShSld == "D"

         cPom := AllTrim( Str( Round( nSaldoKup, 2 ) ) ) + " KM"
         cPom2 := ""

         IF __SH_SLD_VAR == 2
            cPom2 := "Va posljednji saldo iznosi: "
         ENDIF
      ELSE

         cPom := ""
         cPom2 := ""

      ENDIF

      cTxt := StrTran( cTxt, cStrSlKup, cPom2 + " " + cPom )
   ENDIF


   // -------------------------------------------------------
   // SALDO DOBAVLJACA
   // -------------------------------------------------------
   IF At( cStrSlDob, cTxt ) <> 0

      IF gShSld == "D"

         cPom := AllTrim( Str( Round( nSaldoDob, 2 ) ) ) + " KM"
         cPom2 := ""

         IF __SH_SLD_VAR == 2
            cPom2 := "Na posljednji saldo iznosi: "
         ENDIF
      ELSE

         cPom := ""
         cPom2 := ""

      ENDIF

      cTxt := StrTran( cTxt, cStrSlDob, cPom2 + " " + cPom )
   ENDIF

   // -------------------------------------------------------
   // SALDO KUPCA/DOBAVLJACA prebijeno
   // -------------------------------------------------------
   IF At( cStrSlKD, cTxt ) <> 0

      IF gShSld == "D"

         cPom := AllTrim( Str( Round( nSaldoKup, 2 ) - Round( nSaldoDob, 2 ) ) ) + " KM"
         cPom2 := ""

         IF __SH_SLD_VAR == 2
            cPom2 := "Prebijeno stanje kupac/dobavljac : "
         ENDIF
      ELSE

         cPom := ""
         cPom2 := ""

      ENDIF

      cTxt := StrTran( cTxt, cStrSlKD, cPom2 + " " + cPom )
   ENDIF


   // -------------------------------------------------------
   // DATUM POSLJEDNJE UPLATE KUPCA/DOBAVLJACA
   // -------------------------------------------------------
   IF At( cStrDUpKup, cTxt ) <> 0

      IF gShSld == "D"


         // datum posljednje uplate kupca
         cPom := DToC( dPUplKup )
         cPom2 := ""
         IF __SH_SLD_VAR == 2
            cPom2 := "Datum posljednje uplate: "
         ENDIF
      ELSE

         cPom := ""
         cPom2 := ""

      ENDIF

      cTxt := StrTran( cTxt, cStrDUpKup, cPom2 + " " + cPom )

   ENDIF

   // -------------------------------------------------------
   // DATUM POSLJEDNJE PROMJENE NA KONTU KUPCA
   // -------------------------------------------------------
   IF At( cStrDPrKup, cTxt ) <> 0

      IF gShSld == "D"

         // datum posljednje promjene kupac
         cPom := DToC( dPPromKup )
         cPom2 := ""
         IF __SH_SLD_VAR == 2
            cPom2 := "Datum posljednje promjene na kontu kupca: "
         ENDIF

      ELSE

         cPom := ""
         cPom2 := ""

      ENDIF

      cTxt := StrTran( cTxt, cStrDPrKup, cPom2 + " " + cPom )

   ENDIF

   // -------------------------------------------------------
   // DATUM POSLJEDNJE PROMJENE NA KONTU DOBAVLJACA
   // -------------------------------------------------------
   IF At( cStrDPrDob, cTxt ) <> 0

      IF gShSld == "D"


         // datum posljednje promjene dobavljac
         cPom := DToC( dPPromDob )
         cPom2 := ""
         IF __SH_SLD_VAR == 2
            cPom2 := "Datum posljednje promjene na kontu dobavljaca: "
         ENDIF

      ELSE

         cPom := ""
         cPom2 := ""

      ENDIF

      cTxt := StrTran( cTxt, cStrDPrDob, cPom2 + " " + cPom )

   ENDIF

   RETURN



STATIC FUNCTION set_partner_id_broj( cId )

   LOCAL cBroj := ""
   LOCAL cIdBroj := firma_id_broj( cId )
   LOCAL cPdvBroj := firma_pdv_broj( cId )

   cBroj += cIdBroj

   IF !Empty( cPdvBroj )
      cBroj += " PDV broj: " + cPdvBroj
   ENDIF

   RETURN cBroj


STATIC FUNCTION fill_part_data( cId, lPdvObveznik )

   LOCAL cIdBroj := ""
   LOCAL cPdvBroj := ""
   LOCAL cPorBroj := ""
   LOCAL cBrRjes := ""
   LOCAL cBrUpisa := ""
   LOCAL cPartNaziv := ""
   LOCAL cPartAdres := ""
   LOCAL cPartMjesto := ""
   LOCAL cPartTel := ""
   LOCAL cPartFax := ""
   LOCAL cPartPTT := ""
   LOCAL aMemo := {}
   LOCAL lFromMemo := .F.
   LOCAL _t_area := Select()

   IF Empty( AllTrim( cID ) )
      // ako je prazan partner uzmi iz memo polja
      aMemo := ParsMemo( txt )
      lFromMemo := .T.
   ELSE
      O_PARTN
      SELECT partn
      SET ORDER TO TAG "ID"
      HSEEK cId
   ENDIF

   IF !lFromMemo .AND. partn->id == cId
      cIdBroj := firma_id_broj( cId )
      cPdvBroj := firma_pdv_broj( cId )
      cPorBroj := IzSifKPartn( "PORB", cId, .F. )
      cBrRjes := IzSifKPartn( "BRJS", cId, .F. )
      cBrUpisa := IzSifKPartn( "BRUP", cId, .F. )
      cPartNaziv := partn->naz
      cPartAdres := partn->adresa
      cPartMjesto := partn->mjesto
      cPartPtt := partn->ptt
      cPartTel := partn->telefon
      cPartFax := partn->fax
   ELSE
      IF Len( aMemo ) == 0
         cPartNaziv := ""
         cPartAdres := ""
         cPartMjesto := ""
      ELSE
         cPartNaziv := aMemo[ 3 ]
         cPartAdres := aMemo[ 4 ]
         cPartMjesto := aMemo[ 5 ]
      ENDIF
   ENDIF

   // naziv
   add_drntext( "K01", cPartNaziv )
   // adresa
   add_drntext( "K02", cPartAdres )
   // mjesto
   add_drntext( "K10", cPartMjesto )
   // ptt
   add_drntext( "K11", cPartPTT )

   // idbroj staro polje, koje sadrži i id i pdv broj
   add_drntext( "K03", set_partner_id_broj( cId ) )

   // idbroj, pdvbroj, nova polja
   add_drntext( "K15", cIdBroj )
   add_drntext( "K16", cPdvBroj )
   // porbroj
   add_drntext( "K05", cPorBroj )

   // tel
   add_drntext( "K13", cPartTel )
   // fax
   add_drntext( "K14", cPartFax )

   // brrjes
   add_drntext( "K06", cBrRjes )
   // brupisa
   add_drntext( "K07", cBrUpisa )

   SELECT ( _t_area )

   RETURN


STATIC FUNCTION fill_firm_data()

   LOCAL i
   LOCAL cBanke
   LOCAL cPom
   LOCAL lPrazno
   LOCAL _t_area := Select()

   // opci podaci
   add_drntext( "I01", gFNaziv )
   add_drntext( "I20", gFPNaziv )
   add_drntext( "I02", gFAdresa )
   add_drntext( "I03", gFIdBroj )
   // 4. se koristi za id prod.mjesto u pos
   // telefon pos = I05
   add_drntext( "I05", AllTrim( gFTelefon ) )
   add_drntext( "I10", AllTrim( gFTelefon ) )
   add_drntext( "I11", AllTrim( gFEmailWeb ) )

   // banke
   cBanke := ""
   lPrazno := .T.

   FOR i := 1 TO 5
      IF i == 1
         cPom := AllTrim( gFBanka1 )
      ELSEIF i == 2
         cPom := AllTrim( gFBanka2 )
      ELSEIF i == 3
         cPom := AllTrim( gFBanka3 )
      ELSEIF i == 4
         cPom := AllTrim( gFBanka4 )
      ELSEIF i == 5
         cPom := AllTrim( gFBanka5 )
      ENDIF
      IF !Empty( cPom )
         IF !lPrazno
            cBanke += ", "
         ENDIF
         cBanke += cPom
         lPrazno := .F.
      ENDIF
   NEXT


   add_drntext( "I09", cBanke )

   // dodatni redovi
   add_drntext( "I12", AllTrim( gFText1 ) )
   add_drntext( "I13", AllTrim( gFText2 ) )
   add_drntext( "I14", AllTrim( gFText3 ) )

   SELECT ( _t_area )

   RETURN


// ------------------------------------
// ------------------------------------
FUNCTION ZAO_VRIJEDNOST()

   LOCAL nPos
   LOCAL nLen

   // 999.99
   nPos := At( ".", PicDem )
   // = 4
   nLen := Len( PicDEM )
   // = 6

   IF nPos == 0
      nPos := nLen
   ENDIF

   RETURN nLen - nPos


// ------------------------------------
// ------------------------------------
FUNCTION ZAO_CIJENA()

   LOCAL nPos
   LOCAL nLen

   // 999.99
   nPos := At( ".", PicCDem )
   // = 4
   nLen := Len( PicDEM )
   // = 6

   IF nPos == 0
      nPos := nLen
   ENDIF

   RETURN nLen - nPos


// -------------------------------------------
// cDocName
// -------------------------------------------
STATIC FUNCTION doc_name( dok, partner )

   LOCAL cFax
   LOCAL cPartner
   LOCAL cDocumentName

   // primjer cDocumentName = FAKT_DOK_10-10-00050_planika-flex-sarajevo_29.05.06_FAX:032440173
   cDocumentName := gModul + "_DOK_" + dok[ "idfirma" ]  + "-" + dok[ "idtipdok" ] + "-" + Trim( dok[ "brdok" ] ) + "-" + Trim( partner ) + "_" + DToC( DatDok )

   cPartner := AllTrim( g_part_name( partner ) )

   cPartner := StrTran( cPartner, " ", "-" )
   cPartner := StrTran( cPartner, '"', "" )
   cPartner := StrTran( cPartner, "'", "" )
   cPartner := StrTran( cPartner, '/', "-" )

   cDocumentName += "_" + cPartner

   // 032/440-170 => 032440170
   cFax := StrTran( g_part_fax( partner ), "-", "" )
   cFax := StrTran( cFax, "/", "" )
   cFax := StrTran( cFax, " ", "" )

   cDocumentName += "_FAX-" + cFax

   cDocumentName := KonvZnWin( cDocumentName, "4" )

   RETURN cDocumentName
