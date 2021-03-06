/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


STATIC cLinija


/* kalk_dnevni_promet_prodavnice()
 *     Izvjestaj dnevnog prometa
 *  Ovaj izvjestaj nije dobro uradjen - formira se matrica, koja ce puci na velikom broju artikala

FUNCTION kalk_dnevni_promet_prodavnice()

   LOCAL i
   LOCAL cOldIni
   LOCAL dDan
   LOCAL cTops
   LOCAL cPodvuci
   LOCAL aR
   PRIVATE cFilter

   gPINI := ""
   dDan := Date()
   cTops := "D"
   cPodvuci := "N"
   cFilterDn := "D"

   cLinija := "----- ---------- ---------------------------------------- --- ---------- -------------"

   cFilter := my_get_from_ini( "KALK", "UslovPoRobiZaDnevniPromet", "(IDROBA=01)", KUMPATH )

   IF GetVars( @dDan, @cTops, @cPodvuci, @cFilterDn, @cFilter ) == 0
      RETURN
   ENDIF

   aR := {}
   IF ( cTops == "D" )
      IF ScanTops( dDan, @aR ) == 0
         RETURN
      ENDIF
   ELSE
      IF ScanKalk( dDan, @aR ) == 0
         RETURN
      ENDIF
   ENDIF

   cOldIni := gPINI
   -- start_print()
   nStr := 1
   Header( dDan, @nStr )

   nUk := 0
   nUkKol := 0
   FOR i := 1 TO Len( aR )
      ? Str( i, 4 ) + "."
      ?? "", PadR( aR[ i, 1 ], 10 )
      ?? "", PadR( aR[ i, 2 ], 40 )
      ?? "", PadR( aR[ i, 3 ], 3 )
      ?? "", TRANS( aR[ i, 4 ], "999999999" )
      ?? "", TRANS( aR[ i, 5 ], "9999999999.99" )
      IF ( cPodvuci == "D" )
         ?  cLinija
      ENDIF

      nUkKol += aR[ i, 4 ]
      nUk += aR[ i, 6 ]
   NEXT
   Footer( cPodvuci, nUk, nUkKol )
   end_print()

   gPINI := cOldIni
   CopyZaSlanje( dDan )

   CLOSERET

   RETURN
*/


/* PromPeriod()
 *     (Vise)dnevni promet za period

FUNCTION PromPeriod()


   LOCAL i
   LOCAL cOldIni
   LOCAL dDan
   LOCAL dDatDo
   LOCAL aUslPKto
   LOCAL cTops
   LOCAL cPodvuci
   LOCAL aR

   PRIVATE cFilter

   gPINI := ""
   dDan := Date()
   cTops := "D"
   cPodvuci := "N"
   cFilterDn := "D"
   aUslPKto := Space( 100 )
   dDatDo := Date()

   cLinija := "----- ---------- ---------------------------------------- --- ---------- -------------"

   cFilter := my_get_from_ini( "KALK", "UslovPoRobiZaDnevniPromet", "(IDROBA=01)", KUMPATH )

   IF GetVars( @dDan, @cTops, @cPodvuci, @cFilterDn, @cFilter, @dDatDo, @aUslPKto ) == 0
      RETURN
   ENDIF

   aR := {}
   IF ( cTops == "D" )
      IF ScanTops( dDan, @aR, dDatDo, aUslPKto ) == 0
         RETURN
      ENDIF
   ELSE
      IF ScanKalk( dDan, @aR, dDatDo, aUslPKto ) == 0
         RETURN
      ENDIF
   ENDIF

   cOldIni := gPINI
   -- start_print()
   nStr := 1
   Header( dDan, @nStr )

   nUkKol := 0
   nUk := 0
   FOR i := 1 TO Len( aR )
      ? Str( i, 4 ) + "."
      ?? "", PadR( aR[ i, 1 ], 10 )
      ?? "", PadR( aR[ i, 2 ], 40 )
      ?? "", PadR( aR[ i, 3 ], 3 )
      ?? "", TRANS( aR[ i, 4 ], "999999999" )
      ?? "", TRANS( aR[ i, 5 ], "9999999999.99" )
      IF ( cPodvuci == "D" )
         ?  cLinija
      ENDIF
      nUkKol += aR[ i, 4 ]
      nUk += aR[ i, 6 ]
   NEXT
   Footer( cPodvuci, nUk, nUkKol )
   end_print()

   gPINI := cOldIni
   CopyZaSlanje( dDan )

   CLOSERET

   RETURN .T.
 */


/* ScanTops(dDan, aR, dDatDo, cPKto)
 *     Skenira tabele kasa i kupi promet

STATIC FUNCTION ScanTops( dDan, aR, dDatDo, cPKto )


   LOCAL cTSifP
   LOCAL nSifP
   LOCAL cTKumP
   LOCAL nMpcBp

   o_tarifa()
   o_koncij()

   IF FieldPos( "KUMTOPS" ) = 0
      MsgBeep( "Prvo izvrsite modifikaciju struktura pomocu KALK.CHS !" )
      my_close_all_dbf()
      RETURN 0
   ENDIF
   GO TOP

   DO WHILE ( !Eof() )
      cTSifP := Trim( SIFTOPS )
      cTKumP := Trim( KUMTOPS )
      IF Empty( cTSifP ) .OR. Empty( cTKumP )
         SKIP 1
         LOOP
      ENDIF

      IF ( cPKto <> nil ) .AND. !Empty( cPKto )
         IF !( AllTrim( field->id ) $ AllTrim( cPKto ) )
            SKIP 1
            LOOP
         ENDIF
      ENDIF

      AddBs( @cTKumP )
      AddBs( @cTKumP )
      AddBs( @cTSifP )

      IF ( !File( cTKumP + "POS.DBF" ) .OR. !File( cTKumP + "POS.CDX" ) )
         SKIP 1
         LOOP
      ENDIF

      SELECT 0
      IF !File( cTSifP + "ROBA.DBF" ) .OR. !File( cTSifP + "ROBA.CDX" )
         USE ( SIFPATH + "ROBA" )
         SET ORDER TO TAG "ID"
      ELSE
         USE ( cTSifP + "ROBA" )
         SET ORDER TO TAG "ID"
      ENDIF

      SELECT 0
      USE ( cTKumP + "POS" )
      // dtos(datum)
      SET ORDER TO TAG "4"

      SEEK DToS( dDan )

      IF ( dDatDo <> nil )
         bDatCond := {|| DToS( datum ) >= DToS( dDan ) .AND. DToS( datum ) <= DToS( dDatDo ) }
      ELSE
         bDatCond := {|| DToS( datum ) == DToS( dDan ) }
      ENDIF

      DO WHILE !Eof() .AND. Eval( bDatCond )
         IF field->idvd <> "42"
            SKIP
            LOOP
         ENDIF
         IF ( cFilterDn == "D" )
            IF ! &cFilter
               SKIP 1
               LOOP
            ENDIF
         ENDIF

         select_o_roba( pos->idroba )
         select_o_tarifa( roba->idtarifa )
         SELECT POS

         nMpcBP := Round( cijena / ( 1 + tarifa->zpp / 100 + tarifa->ppp / 100 ) / ( 1 + tarifa->opp / 100 ), 2 )
         SELECT POS
         IF !Len( aR ) > 0 .OR. !( ( nPom := AScan( aR, {| x| x[ 1 ] == idroba } ) ) > 0 )
            AAdd( aR, { idroba, Left( ROBA->naz, 40 ), ROBA->jmj, kolicina, nMpCBP, cijena * kolicina } )
         ELSE
            aR[ nPom, 4 ] += kolicina
            aR[ nPom, 6 ] += nMpCBP * kolicina
         ENDIF
         SKIP 1
      ENDDO

      //SELECT roba
      //USE
      SELECT pos
      USE
      SELECT koncij
      SKIP 1
   ENDDO

   ASort( aR,,, {| x, y| x[ 1 ] < y[ 1 ] } )

   RETURN 1

*/


/* ScanKalk(dDan, aR, dDatDo, cPKto)
 *     Skenira tabelu kalk i kupi promet prodavnica

STATIC FUNCTION ScanKalk( dDan, aR, dDatDo, cPKto )


//   o_roba()
   -- o_kalk() // idFirma+dtos(datdok)+podbr+idvd+brdok
   SET ORDER TO TAG "5"

   SEEK self_organizacija_id() + DToS( dDan )

   IF ( dDatDo <> nil )
      bDatCond := {|| DToS( datdok ) >= DToS( dDan ) .AND. DToS( datdok ) <= DToS( dDatDo ) }
   ELSE
      bDatCond := {|| DToS( datdok ) == DToS( dDan ) }
   ENDIF

   DO WHILE !Eof() .AND. Eval( bDatCond )
      IF ( cPKto <> nil )
         IF !Empty( cPKto )
            IF !( AllTrim( field->pkonto ) $ AllTrim( cPKto ) )
               SKIP 1
               LOOP
            ENDIF
         ENDIF
      ELSE
         IF !( field->pkonto = "132" .AND. Left( field->idVd, 1 ) == "4" )
            SKIP 1
            LOOP
         ENDIF
      ENDIF

      IF !Len( aR ) > 0 .OR. !( ( nPom := AScan( aR, {| x| x[ 1 ] == idroba } ) ) > 0 )
         AAdd( aR, { field->idRoba, "", "", field->kolicina, field->mpc, field->mpc * field->kolicina } )
      ELSE
         aR[ nPom, 4 ] += field->kolicina
         aR[ nPom, 6 ] += field->mpc * field->kolicina
      ENDIF
      SKIP 1
   ENDDO

   ASort( aR,,, {| x, y| x[ 1 ] < y[ 1 ] } )
  -- SELECT ROBA
   FOR i := 1 TO Len( aR )
      HSEEK aR[ i, 1 ]
      aR[ i, 2 ] := Left( field->naz, 40 )
      aR[ i, 3 ] := field->jmj
   NEXT

   RETURN 1



STATIC FUNCTION GetVars( dDan, cTops, cPodvuci, cFilterDn, cFilter, dDatDo, aUslPKto )


   LOCAL cIspraviFilter

   cIspraviFilter := "N"
   cFilterDn := "N"
   Box( "#DNEVNI PROMET", 9, 60 )

   @ box_x_koord() + 2, box_y_koord() + 2 SAY "Za datum od" GET dDan
   IF ( dDatDo <> nil )
      @ box_x_koord() + 2, box_y_koord() + 27 SAY "do" GET dDatDo
   ENDIF
   @ box_x_koord() + 3, box_y_koord() + 2 SAY "Izvor podataka su kase tj. TOPS (D/N) ?" GET cTops VALID cTops $ "DN" PICT "@!"
   @ box_x_koord() + 4, box_y_koord() + 2 SAY "Linija ispod svakog reda (D/N) ?" GET cPodvuci VALID cPodvuci $ "DN" PICT "@!"
   @ box_x_koord() + 5, box_y_koord() + 2 SAY "Uzeti u obzir filter (D/N) ?" GET cFilterDn VALID cFilterDn $ "DN" PICT "@!"

   IF ( aUslPKto <> nil )
      @ box_x_koord() + 7, box_y_koord() + 2 SAY "Prodavnicka konta" GET aUslPKto PICT "@S40"
   ENDIF

   READ

   IF ( cFilterDn == "D" )
      @ box_x_koord() + 7, box_y_koord() + 2 SAY "Pregled, ispravka filtera " GET cIspraviFilterDn VALID cIspraviFilter $ "DN" PICTURE "@!"
      READ
      cFilter := PadR( cFilter, 200 )
      IF ( cIspraviFilter == "D" )
         @ box_x_koord() + 8, box_y_koord() + 2 SAY "Filter " GET cFilter PICTURE "@S30"
         READ
      ENDIF
      cFilter := Trim( cFilter )
   ENDIF

   IF ( LastKey() == K_ESC )
      BoxC()
      RETURN 0
   ENDIF

   BoxC()

   RETURN 1


STATIC FUNCTION Header( dDan, nStr )

   LOCAL b1
   LOCAL b2
   LOCAL b3

   b1 := {|| QOut( "KALK: EVIDENCIJA DNEVNOG PROMETA U MALOPRODAJI NA DAN " + DToC( dDan ), "    Str." + LTrim( Str( nStr ) )  ) }

   b2 := {|| QOut( "ID PM:", my_get_from_ini( "ZaglavljeDnevnogPrometa", "IDPM", "01    - Planika Flex BiH", EXEPATH )          ) }

   b3 := {|| QOut( "KONTO:", my_get_from_ini( "ZaglavljeDnevnogPrometa", "KONTO", "132   - ROBA U PRODAVNICI", EXEPATH )         ) }

   Eval( b1 )
   Eval( b2 )
   Eval( b3 )

   ? cLinija
   ? " R.  *  SIFRA   *      N A Z I V    A R T I K L A        *JMJ* KOLICINA *   MPC-PPP  *"
   ? " BR. * ARTIKLA  *                                        *   *          *            *"
   ? cLinija

   RETURN

STATIC FUNCTION Footer( cPodvuci, nUk, nUkKol )

   ? cLinija
   ? PadR( "UKUPNO:", 60 ), TRANS( nUkKol, "9999999999" ), Space( 1 ), TRANS( nUk, "999999999.99" )
   ? cLinija

   RETURN

STATIC FUNCTION CopyZaSlanje( dDan )

   LOCAL cS
   LOCAL cLokS
   LOCAL cNf
   LOCAL cDirDest

   PRIVATE cPom

   cNF := "FL" + StrTran( DToC( dDan ), ".", "" ) + ".TXT"

   IF Pitanje(, "Zelite li snimiti dokument radi slanja ?", "N" ) == "N"
      RETURN 0
   ENDIF

   SAVE SCREEN TO cS
   CLS

   cDirDest := ToUnix( "C:" + SLASH + "SIGMA" + SLASH + "SALJI" + SLASH )
   cLokS := my_get_from_ini( "FMK", "LokacijaZaSlanje", cDirDest, EXEPATH )
   cPom := "copy " + my_home() + "OUTF.TXT " + cLokS + cNf

   f18_run( cPom )


   RESTORE SCREEN FROM cS
   IF File( cLokS + cNf )
      MsgBeep( "Kopiranje dokumenta zavrseno!" )
   ELSE
      MsgBeep( "KOPIRANJE FAJLA-IZVJESTAJA NIJE USPJELO!" )
   ENDIF

   RETURN .T.

*/
