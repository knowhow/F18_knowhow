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


#include "kalk.ch"

// rekapitulacija finansijskog stanja po objektima
FUNCTION RFLLP()

   LOCAL nKolUlaz
   LOCAL nKolIzlaz

   PRIVATE aPorezi

   aPorezi := {}

   PicDem := Replicate( "9", Val( gFPicDem ) ) + gPicDem
   PicCDem := Replicate( "9", Val( gFPicCDem ) ) + gPicCDem

   cIdFirma := gFirma
   cIdKonto := PadR( "132.", gDuzKonto )

   O_SIFK
   O_SIFV
   O_ROBA
   O_TARIFA
   O_KONCIJ
   O_KONTO
   O_PARTN

   dDatOd := CToD( "" )
   dDatDo := Date()
   qqRoba := Space( 60 )
   qqTarifa := qqidvd := Space( 60 )
   PRIVATE cPNab := "N"
   PRIVATE cNula := "D", cErr := "N"
   PRIVATE cTU := "2"

   Box(, 9, 60 )
   DO WHILE .T.
      IF gNW $ "DX"
         @ m_x + 1, m_y + 2 SAY "Firma "
         ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 2, m_y + 2 SAY "Konto   " GET cIdKonto VALID "." $ cidkonto .OR. P_Konto( @cIdKonto )
      @ m_x + 4, m_y + 2 SAY "Tarife  " GET qqTarifa PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Artikli " GET qqRoba   PICT "@!S50"
      @ m_x + 6, m_y + 2 SAY "Vrste dokumenata  " GET qqIDVD PICT "@!S30"
      @ m_x + 7, m_y + 2 SAY "Datum od " GET dDatOd
      @ m_x + 7, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 8, m_y + 2  SAY "Prikaz: roba tipa T / dokumenata IP (1/2)" GET cTU  VALID cTU $ "12"
      READ
      ESC_BCR
      PRIVATE aUsl2 := Parsiraj( qqTarifa, "IdTarifa" )
      PRIVATE aUsl3 := Parsiraj( qqIDVD, "idvd" )
      PRIVATE aUslR := Parsiraj( qqRoba, "idroba" )
      IF aUsl2 <> NIL
         EXIT
      ENDIF
      IF aUsl3 <> NIL
         EXIT
      ENDIF
      IF aUsl4 <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   // sinteticki konto
   IF Len( Trim( cIdKonto ) ) <= 3 .OR. "." $ cIdKonto
      IF "." $ cIdKonto
         cIdKonto := StrTran( cIdKonto, ".", "" )
      ENDIF
      cIdkonto := Trim( cIdKonto )
   ENDIF

   O_KALKREP
   SELECT kalk
   SET ORDER TO TAG "4"
   // "idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD"

   cFilt1 := "Pkonto=" + cm2Str( cIdkonto )

   IF !Empty( dDatOd ) .OR. !Empty( dDatdo )
      cFilt1 += ".and.DATDOK>=" + cm2str( dDatOd ) + ".and.DATDOK<=" + cm2str( dDatDo )
   ENDIF

   IF aUsl2 <> ".t."
      cFilt1 += ".and." + aUsl2
   ENDIF
   IF aUsl3 <> ".t."
      cFilt1 += ".and." + aUsl3
   ENDIF
   IF aUslR <> ".t."
      cFilt1 += ".and." + aUslR
   ENDIF

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )
   SET FILTER to &cFilt1

   hseek cIdFirma

   SELECT koncij
   SEEK Trim( cIdKonto )
   SELECT kalk

   EOF CRET

   nLen := 1

   aZaglTxt := {}
   AAdd( aZaglTxt, { 5, "R.br", "" } )
   AAdd( aZaglTxt, { 11, " Konto", "" } )
   AAdd( aZaglTxt, { Len( PicDem ), " MPV.Dug", "" } )
   AAdd( aZaglTxt, { Len( PicDem ), " MPV.Pot", "" } )
   AAdd( aZaglTxt, { Len( PicDem ), " MPV", "" } )
   AAdd( aZaglTxt, { Len( PicDem ), " MPV sa PP", "  Dug" } )
   AAdd( aZaglTxt, { Len( PicDem ), " MPV sa PP", "  Pot" } )
   AAdd( aZaglTxt, { Len( PicDem ), " MPV sa PP", "" } )

   PRIVATE cLine := SetRptLineAndText( aZaglTxt, 0 )
   PRIVATE cText1 := SetRptLineAndText( aZaglTxt, 1, "*" )
   PRIVATE cText2 := SetRptLineAndText( aZaglTxt, 2, "*" )

   start PRINT cret
   ?

   PRIVATE nTStrana := 0
   PRIVATE bZagl := {|| ZaglRFLLP() }

   Eval( bZagl )
   nTUlaz := nTIzlaz := 0
   ntMPVU := ntMPVI := nTNVU := nTNVI := 0
   ntMPVBU := ntMPVBI := 0
   // nTRabat:=0
   nCol1 := nCol0 := 50
   PRIVATE nRbr := 0

   nMPVBU := nMPVBI := 0
   aRTar := {}
   nKolUlaz := 0
   nKolIzlaz := 0

   DO WHILE !Eof() .AND. cIdFirma == idfirma .AND. IspitajPrekid()
      nUlaz := nIzlaz := 0
      nMPVU := nMPVI := nNVU := nNVI := 0
      nMPVBU := nMPVBI := 0
      dDatDok := datdok
      cBroj := pkonto
      DO WHILE !Eof() .AND. cIdFirma + cBroj == idFirma + pkonto .AND. IspitajPrekid()
         SELECT roba
         hseek kalk->idroba
         // uslov po K9, planika
         IF ( IsPlanika() .AND. !Empty( cK9 ) .AND. roba->k9 <> cK9 )
            SELECT kalk
            SKIP
            LOOP
         ENDIF
  		
         SELECT kalk
         IF cTU == "2" .AND.  roba->tip $ "UT"
            // prikaz dokumenata IP, a ne robe tipa "T"
            SKIP
            LOOP
         ENDIF
         IF cTU == "1" .AND. idvd == "IP"
            SKIP
            LOOP
         ENDIF

         SELECT roba
         hseek kalk->idroba
         SELECT tarifa
         hseek kalk->idtarifa
         SELECT kalk

         Tarifa( pkonto, idroba, @aPorezi, idtarifa )
         VtPorezi()

         nBezP := 0
         nSaP := 0
         nNV := 0

         IF pu_i == "1"
            nBezP := mpc * kolicina
            nMPVBU += nBezP
            nSaP := mpcsapp * kolicina
            nMPVU += nSaP
            nNVU += nc * ( kolicina )
            nNV += nc * ( kolicina )
         ELSEIF pu_i == "5"
            nBezP := -mpc * kolicina
            nSaP := -mpcsapp * kolicina
            IF idvd $ "12#13"
               nMPVBU += nBezP
               nMPVU += nSaP
               nNVU -= nc * kolicina
               nNV -= nc * kolicina
            ELSE
               nMPVBI -= nBezP
               nMPVI -= nSaP
               nNVI += nc * kolicina
               nNV -= nc * kolicina
            ENDIF
         ELSEIF pu_i == "3"
            nBezP := mpc * kolicina
            nMPVBU += nBezP
            nSaP := mpcsapp * kolicina
            nMPVU += nSaP
         ELSEIF pu_i == "I"
            nBezP := -MpcBezPor( mpcsapp, aPorezi,, nc ) * gkolicin2
            nMPVBI -= nBezP
            nSaP := -mpcsapp * gkolicin2
            nMPVI += -nSaP
            nNVI += nc * gkolicin2
            nNV -= nc * gkolicin2
         ENDIF

         IF IsPlanika()
            UkupnoKolP( @nKolUlaz, @nKolIzlaz )
         ENDIF

         nElem := AScan( aRTar, {| x| x[ 1 ] == TARIFA->ID } )

         IF glUgost
            nP1 := Izn_P_PPP( nBezP, aPorezi,, nSaP )
            nP2 := Izn_P_PRugost( nSaP, nBezP, nNV, aPorezi )
            nP3 := Izn_P_PPUgost( nSaP, nP2, aPorezi )
         ELSE
            nP1 := Izn_P_PPP( nBezP, aPorezi,, nSaP )
            nP2 := Izn_P_PPU( nBezP, aPorezi )
            nP3 := Izn_P_PP( nBezP, aPorezi )
         ENDIF

         IF nElem > 0
            aRTar[ nElem, 2 ] += nBezP
            aRTar[ nElem, 6 ] += nP1
            aRTar[ nElem, 7 ] += nP2
            aRTar[ nElem, 8 ] += nP3
            aRTar[ nElem, 9 ] += nP1 + nP2 + nP3
            aRTar[ nElem, 10 ] += nSaP
         ELSE
            AAdd( aRTar, { TARIFA->ID, nBezP, _OPP * 100, PrPPUMP(), _ZPP * 100, nP1, nP2, nP3, nP1 + nP2 + nP3, nSaP } )
         ENDIF
         SKIP
      ENDDO
	
      IF Round( nNVU - nNVI, 4 ) == 0 .AND. Round( nMPVU - nMPVI, 4 ) == 0
         LOOP
      ENDIF

      IF PRow() > ( RPT_PAGE_LEN + gPStranica )
         FF
         Eval( bZagl )
      ENDIF
	
      ? Str( ++nRbr, 4 ) + ".", PadR( cBroj, 11 )
      nCol1 := PCol() + 1

      nTMPVU += nMPVU
      nTMPVI += nMPVI
      nTMPVBU += nMPVBU
      nTMPVBI += nMPVBI
      nTNVU += nNVU
      nTNVI += nNVI

      @ PRow(), PCol() + 1 SAY nMPVBU PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVBI PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVBU - nMPVBI PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVU PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVI PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVU - nMPVI PICT picdem
   ENDDO

   ? cLine
   ? "UKUPNO:"

   @ PRow(), nCol1 SAY ntMPVBU PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVBI PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVBU - ntMPVBI PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVU PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVI PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVU - ntMPVI PICT picdem

   ? cLine

   aRptRTar := {}
   AAdd( aRptRTar, { 15, " TARIF", " BROJ" } )
   AAdd( aRptRTar, { Len( PicDem ), " MPV", " " } )
   AAdd( aRptRTar, { Len( gPicProc ), " PPP", "  %" } )
   AAdd( aRptRTar, { Len( gPicProc ), " PPU", "  %" } )
   AAdd( aRptRTar, { Len( gPicProc ), " PP", "  %" } )
   AAdd( aRptRTar, { Len( PicDem ), " PPP", "" } )
   AAdd( aRptRTar, { Len( PicDem ), " PPU", "" } )
   AAdd( aRptRTar, { Len( PicDem ), " PP", "" } )
   AAdd( aRptRTar, { Len( PicDem ), " UKUPNO", " POREZ" } )
   AAdd( aRptRTar, { Len( PicDem ), " MPV", " sa Por" } )

   cRTLine := SetRptLineAndText( aRptRTar, 0 )
   cRTTxt1 := SetRptLineAndText( aRptRTar, 1, "*" )
   cRTTxt2 := SetRptLineAndText( aRptRTar, 2, "*" )

   IF Val( gFPicDem ) > 0
      P_COND2
   ELSE
      P_COND
   ENDIF

   ?
   ?
   ?
   ? "REKAPITULACIJA PO TARIFAMA"
   ? "--------------------------"
   ? cRTLine
   ? cRTTxt1
   ? cRTTxt2
   ? cRTLine

   ASort( aRTar,,, {| x, y| x[ 1 ] < y[ 1 ] } )

   nT1 := nT4 := nT5 := nT6 := nT7 := nT5a := 0

   FOR i := 1 TO Len( aRTar )
      IF PRow() > ( RPT_PAGE_LEN + gPStranica )
         FF
      ENDIF
      @ PRow() + 1, 0        SAY Space( 6 ) + aRTar[ i, 1 ]
      nCol1 := PCol() + 4
      @ PRow(), PCol() + 4   SAY aRTar[ i, 2 ]  PICT  PicDEM
      @ PRow(), PCol() + 1   SAY aRTar[ i, 3 ]  PICT  gPicProc
      @ PRow(), PCol() + 1   SAY aRTar[ i, 4 ]  PICT  gPicProc
      @ PRow(), PCol() + 1   SAY aRTar[ i, 5 ]  PICT  gPicProc
      @ PRow(), PCol() + 1   SAY aRTar[ i, 6 ]  PICT  PicDEM
      @ PRow(), PCol() + 1   SAY aRTar[ i, 7 ]  PICT  PicDEM
      @ PRow(), PCol() + 1   SAY aRTar[ i, 8 ]  PICT  PicDEM
      @ PRow(), PCol() + 1   SAY aRTar[ i, 9 ]  PICT  PicDEM
      @ PRow(), PCol() + 1   SAY aRTar[ i, 10 ]  PICT  PicDEM
      nT1 += aRTar[ i, 2 ]
      nT4 += aRTar[ i, 6 ]
      nT5 += aRTar[ i, 7 ]
      nT5a += aRTar[ i, 8 ]
      nT6 += aRTar[ i, 9 ]
      nT7 += aRTar[ i, 10 ]
   NEXT

   IF PRow() > ( RPT_PAGE_LEN + gPStranica )
      FF
   ENDIF
   ? cRTLine
   ? "UKUPNO:"
   @ PRow(), nCol1     SAY  nT1  PICT picdem
   @ PRow(), PCol() + 1  SAY  0    PICT "@Z " + gPicProc
   @ PRow(), PCol() + 1  SAY  0    PICT "@Z " + gPicProc
   @ PRow(), PCol() + 1  SAY  0    PICT "@Z " + gPicProc
   @ PRow(), PCol() + 1  SAY  nT4  PICT picdem
   @ PRow(), PCol() + 1  SAY  nT5  PICT picdem
   @ PRow(), PCol() + 1  SAY  nT5a PICT picdem
   @ PRow(), PCol() + 1  SAY  nT6  PICT picdem
   @ PRow(), PCol() + 1  SAY  nT7  PICT picdem
   ? cRTLine

   IF IsPlanika()
      IF ( PRow() > ( RPT_PAGE_LEN + gPStranica ) )
         FF
      ENDIF
      PrintParovno( nKolUlaz, nKolIzlaz )
   ENDIF

   FF
   endprint

   closeret

   RETURN


// zaglavlje izvjestaja
FUNCTION ZaglRFLLP()

   Preduzece()
   P_12CPI
   SELECT konto
   hseek cidkonto
   ?? Space( 60 ), " DATUM "
   ?? Date(), Space( 5 ), "Str:", Str( ++nTStrana, 3 )
   IspisNaDan( 5 )
   ?
   ?
   ? "KALK: Rekapitulacija fin. stanja po objektima za period", dDatOd, "-", dDatDo
   ?
   ?
   ? "Kriterij za objekte:", cIdKonto, "-", konto->naz
   ?
   IF Len( aUslR ) <> 0
      ? "Kriterij za artikle:", qqRoba
   ENDIF

   IF IsPlanika() .AND. !Empty( cK9 )
      ? "Uslov po K9:", cK9
   ENDIF

   SELECT kalk

   IF Val( gFPicDem ) > 0
      P_COND2
   ELSE
      P_COND
   ENDIF

   ?
   ? cLine
   ? cText1
   ? cText2
   ? cLine

   RETURN
