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


/*
   finansijsko stanje prodavnice
*/

FUNCTION finansijsko_stanje_prodavnica()

   LOCAL nKolUlaz
   LOCAL nKolIzlaz
   LOCAL hParams
   LOCAL dDatOd, dDatDo
   LOCAL cIdFirma

   PicDem := Replicate( "9", Val( gFPicDem ) ) + gPicDem
   PicCDem := Replicate( "9", Val( gFPicCDem ) ) + gPicCDem

   cIdFirma := gFirma
   cIdKonto := PadR( "133", gDuzKonto )

   o_koncij()
   O_ROBA
   o_tarifa()
   o_konto()

   dDatOd := CToD( "" )
   dDatDo := Date()
   qqRoba := Space( 200 )
   qqTarifa := qqidvd := Space( 60 )
   PRIVATE cPNab := "N"
   PRIVATE cNula := "D", cErr := "N"
   PRIVATE cTU := "2"

   Box(, 9, 60 )

   DO WHILE .T.

      IF gNW $ "DX"
         @ m_x + 1, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cIdfirma := Left( cidfirma, 2 ), .T. }
      ENDIF

      @ m_x + 2, m_y + 2 SAY "Konto   " GET cIdKonto VALID P_Konto( @cIdKonto )
      @ m_x + 4, m_y + 2 SAY "Tarife  " GET qqTarifa PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Vrste dokumenata  " GET qqIDVD PICT "@!S30"
      @ m_x + 6, m_y + 2 SAY "Roba  " GET qqRoba PICT "@!S30"
      @ m_x + 7, m_y + 2 SAY "Datum od " GET dDatOd
      @ m_x + 7, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 8, m_y + 2  SAY "Prikaz: roba tipa T / dokumenati IP (1/2)" GET cTU  VALID cTU $ "12"

      READ

      ESC_BCR

      PRIVATE aUsl2 := Parsiraj( qqTarifa, "idtarifa" )
      PRIVATE aUsl3 := Parsiraj( qqIDVD, "idvd" )
      PRIVATE aUsl4 := Parsiraj( qqRoba, "idroba" )

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

   // ovo je napusteno ...
   // fSaberikol := ( my_get_from_ini( 'Svi', 'SaberiKol', 'N' ) == 'D' )


   hParams := hb_Hash()

   hParams[ "idfirma" ] := cIdFirma

   IF Len( Trim( cIdkonto ) ) == 3  // sinteticki konto
      cIdkonto := Trim( cIdkonto )
      hParams[ "pkonto_sint" ] := cIdKonto
   ELSE
      hParams[ "pkonto" ] := cIdKonto
   ENDIF

   IF !Empty( dDatOd )
      hParams[ "dat_od" ] := dDatOd
   ENDIF

   IF !Empty( dDatDo )
      hParams[ "dat_do" ] := dDatDo
   ENDIF

   hParams[ "order_by" ] := "idFirma,datdok,idvd,brdok,rbr"

   MsgO( "Preuzimanje podataka sa SQL servera ..." )
   find_kalk_za_period( hParams )
   MsgC()

   cFilt1 := ".T."
   IF aUsl2 <> ".t."
      cFilt1 += ".and." + aUsl2
   ENDIF

   IF aUsl3 <> ".t."
      cFilt1 += ".and." + aUsl3
   ENDIF

   IF aUsl4 <> ".t."
      cFilt1 += ".and." + aUsl4
   ENDIF

   SET FILTER to &cFilt1
   GO TOP

   EOF CRET

   SELECT koncij
   SEEK Trim( cIdkonto )

   SELECT KALK

   nLen := 1

   aRFLLP := {}
   AAdd( aRFLLP, { 6, "Redni", " broj" } )
   AAdd( aRFLLP, { 8, "", " Datum" } )
   AAdd( aRFLLP, { 11, " Broj", "dokumenta" } )
   AAdd( aRFLLP, { Len( PicDem ), "  NV", " duguje" } )
   AAdd( aRFLLP, { Len( PicDem ), "  NV", " potraz." } )
   AAdd( aRFLLP, { Len( PicDem ), "  NV", " ukupno" } )

   AAdd( aRFLLP, { Len( PicDem ), "   PV", " duguje" } )
   AAdd( aRFLLP, { Len( PicDem ), "   PV", " potraz." } )
   AAdd( aRFLLP, { Len( PicDem ), "   PV", " ukupno" } )
   AAdd( aRFLLP, { Len( PicDem ), " PV sa PDV", " duguje" } )
   AAdd( aRFLLP, { Len( PicDem ), " PV sa PDV", " potraz." } )
   AAdd( aRFLLP, { Len( PicDem ), " Popust", "" } )
   AAdd( aRFLLP, { Len( PicDem ), " PV sa PDV", " - pop." } )
   AAdd( aRFLLP, { Len( PicDem ), " PV sa PDV", " ukupno" } )


   PRIVATE cLine := SetRptLineAndText( aRFLLP, 0 )
   PRIVATE cText1 := SetRptLineAndText( aRFLLP, 1, "*" )
   PRIVATE cText2 := SetRptLineAndText( aRFLLP, 2, "*" )

   start PRINT cret
   ?

   PRIVATE nTStrana := 0
   PRIVATE bZagl := {|| Zaglfinansijsko_stanje_prodavnica( dDatOd, dDatDo ) }
   PRIVATE aPorezi := {}

   Eval( bZagl, dDatOd, dDatDo )
   nTUlaz := nTIzlaz := 0
   ntMPVBU := ntMPVBI := ntMPVU := ntMPVI := ntNVU := ntNVI := ntMPVIP := 0
   ntPopust := 0

   nCol1 := nCol0 := 10
   PRIVATE nRbr := 0

#define CMORE

#xcommand CMINIT => ncmSlogova:=100; ncmRec:=1
   // #DEFINE CMNEOF  !eof() .and. ncmRec<=ncmSLOGOVA
   // #XCOMMAND CMSKIP => ++ncmRec; if ncmrec>ncmslogova;exit;end; skip
#define CMNEOF  !eof()
#xcommand CMSKIP => skip

   CMINIT
   showkorner( ncmslogova, 1, 16 )
   showkorner( 0, 100 )

   // kolicine ulaz/izlaz
   PRIVATE nKU := nKI := 0

   nKolUlaz := 0
   nKolIzlaz := 0

   DO WHILE CMNEOF .AND. cidfirma == idfirma .AND.  IspitajPrekid()

      nUlaz := nIzlaz := 0
      nMPVBU := nMPVBI := nMPVU := nMPVI := nNVU := nNVI := nMPVIP := 0
      nPopust := 0

      // nRabat:=0

      dDatDok := datdok
      cBroj := idvd + "-" + brdok

      DO WHILE CMNEOF  .AND. cidfirma + DToS( ddatdok ) + cbroj == idFirma + DToS( datdok ) + idvd + "-" + brdok .AND.  IspitajPrekid()

         SELECT roba
         HSEEK KALK->idroba
         SELECT KALK

         showkorner( 1, 100 )

         IF cTU == "2" .AND.  roba->tip $ "UT"
            // prikaz dokumenata IP, a ne robe tipa "T"
            CMSKIP
            LOOP
         ENDIF
         IF cTU == "1" .AND. idvd == "IP"
            CMSKIP
            LOOP
         ENDIF

         SELECT roba
         HSEEK KALK->idroba
         SELECT tarifa
         HSEEK KALK->idtarifa
         SELECT KALK

         VtPorezi()

         IF field->pu_i == "1"

            nMPVBU += mpc * kolicina
            nMPVU += mpcsapp * kolicina
            nNVU += nc * ( kolicina )

         ELSEIF field->pu_i == "5"

            Tarifa( field->pkonto, field->idroba, @aPorezi, field->idtarifa )
            // uracunaj i popust
            // racporezemp( matrica, mp_bez_pdv, mp_sa_pdv, nc )
            aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
            nPor1 := aIPor[ 1 ]

            IF field->idvd $ "12#13"

               nMPVBU -= mpc * kolicina
               nMPVU -= mpcsapp * kolicina
               nNVU -= nc * kolicina
               nPopust -= rabatv * kolicina
               nMPVIP -= ( mpc + nPor1 ) * kolicina
            ELSE

               nMPVBI += mpc * kolicina
               nMPVI += mpcsapp * kolicina
               nNVI += nc * kolicina
               nPopust += rabatv * kolicina
               nMPVIP += ( mpc + nPor1 ) * kolicina

            ENDIF

         ELSEIF pu_i == "3"

            // nivelacija
            nMPVBU += mpc * kolicina
            nMPVU += mpcsapp * kolicina

         ELSEIF pu_i == "I"

            Tarifa( field->pkonto, field->idRoba, @aPorezi, field->idtarifa )
            nMPVBI += DokMpc( field->idvd, aPorezi ) * field->gkolicin2
            // nMPVBI+=mpcsapp/((1+_OPP)*(1+_PPP))*gkolicin2
            nMPVI += mpcsapp * gkolicin2
            nNVI += nc * gkolicin2

         ENDIF

         CMSKIP

      ENDDO

      IF Round( nNVU - nNVI, 4 ) == 0 .AND. Round( nMPVU - nMPVI, 4 ) == 0
         LOOP
      ENDIF

      IF PRow() > page_length()
         FF
         Eval( bZagl )
      ENDIF

      ? Str( ++nrbr, 5 ) + ".", dDatDok, cBroj
      nCol1 := PCol() + 1

      ntNVU += nNVU
      ntNVI += nNVI
      ntMPVBU += nMPVBU
      ntMPVBI += nMPVBI
      ntMPVU += nMPVU
      ntMPVI += nMPVI
      ntPopust += nPopust
      ntMPVIP += nMPVIP

      @ PRow(), PCol() + 1 SAY nNVU PICT picdem
      @ PRow(), PCol() + 1 SAY nNVI PICT picdem
      @ PRow(), PCol() + 1 SAY ntNVU - ntNVI PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVBU PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVBI PICT picdem
      @ PRow(), PCol() + 1 SAY ntMPVBU - ntMPVBI PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVU PICT picdem
      @ PRow(), PCol() + 1 SAY nMPVI PICT picdem

      IF IsPDV()
         @ PRow(), PCol() + 1 SAY nPopust PICT picdem
         @ PRow(), PCol() + 1 SAY nMPVIP PICT picdem
      ENDIF

      @ PRow(), PCol() + 1 SAY ntMPVU - ntMPVI PICT picdem

   ENDDO

   ? cLine
   ? "UKUPNO:"

   @ PRow(), nCol1    SAY ntNVU PICT picdem
   @ PRow(), PCol() + 1 SAY ntNVI PICT picdem
   @ PRow(), PCol() + 1 SAY ntNVU - ntNVI PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVBU PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVBI PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVBU - ntMPVBI PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVU PICT picdem
   @ PRow(), PCol() + 1 SAY ntMPVI PICT picdem

   IF IsPDV()
      @ PRow(), PCol() + 1 SAY ntPopust PICT picdem
      @ PRow(), PCol() + 1 SAY ntMPVIP PICT picdem
   ENDIF

   @ PRow(), PCol() + 1 SAY ntMPVU - ntMPVI PICT picdem

   ? cLine


   FF
   ENDPRINT

   my_close_all_dbf()

   RETURN

// zaglavlje fin.stanje
FUNCTION Zaglfinansijsko_stanje_prodavnica( dDatOd, dDatDo )

   SELECT konto
   HSEEK cIdKonto
   Preduzece()

   IF Val( gFPicDem ) > 0
      P_COND2
   ELSE
      P_COND
   ENDIF

   ?? "KALK: Finansijsko stanje za period", dDatOd, "-", dDatDo, " NA DAN "
   ?? Date(), Space( 10 ), "Str:", Str( ++nTStrana, 3 )
   ? "Prodavnica:", cIdKonto, "-", konto->naz

   SELECT KALK

   ? cLine
   ? cText1
   ? cText2
   ? cLine

   RETURN .T.