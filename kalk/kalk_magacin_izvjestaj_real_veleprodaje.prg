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
// realizacija vp po partnerima
// -------------------------------------------
FUNCTION kalk_real_partnera()

   LOCAL nT0 := nT1 := nT2 := nT3 := nT4 := 0
   LOCAL nCol1 := 0
   LOCAL nPom
   LOCAL PicCDEM := gPicCDEM       // "999999.999"
   LOCAL PicProc := gPicProc       // "999999.99%"
   LOCAL PicDEM := gPicDEM         // "9999999.99"
   LOCAL Pickol := gPicKol         // "999999.999"

   O_SIFK
   O_SIFV
   O_ROBA
   O_KONTO
   O_TARIFA
   O_PARTN

   PRIVATE dDat1 := dDat2 := CToD( "" )
   cIdFirma := self_organizacija_id()
   cIdKonto := PadR( "1310", 7 )

   IF IsVindija()
      cOpcine := Space( 50 )
   ENDIF

   qqPartn := Space( 60 )

   cPRUC := "N"
   Box(, 8, 70 )
   DO WHILE .T.
      SET CURSOR ON
      IF gNW $ "DX"
         @ m_x + 1, m_y + 2 SAY "Firma "; ?? self_organizacija_id(), "-", self_organizacija_naziv()
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 2, m_y + 2 SAY "Magacinski konto:" GET cidKonto PICT "@!" VALID P_Konto( @cIdKonto )
      @ m_x + 4, m_y + 2 SAY "Period:" GET dDat1
      @ m_x + 4, Col() + 1 SAY "do" GET dDat2

      @ m_x + 6, m_y + 2 SAY "Partneri:" GET qqPartn PICT "@!S40"

      IF IsVindija()
         @ m_x + 8, m_y + 2 SAY "Opcine:" GET cOpcine PICT "@!S40"
      ENDIF

      READ

      ESC_BCR

      aUslP := Parsiraj( qqPartn, "Idpartner" )
      IF auslp <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()


   O_TARIFA
   o_kalk()
   SET ORDER TO TAG PMAG

   PRIVATE cFilt1 := ""

   cFilt1 := ".t." + IF( Empty( dDat1 ), "", ".and.DATDOK>=" + dbf_quote( dDat1 ) ) + ;
      IF( Empty( dDat2 ), "", ".and.DATDOK<=" + dbf_quote( dDat2 ) )

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )


   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ENDIF

   HSEEK cIdFirma
   EOF CRET

   PRIVATE M := "   -------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ----------" + IF( !IsPDV(), " ----------", "" )

   START PRINT CRET
   ?

   B := 0

   PRIVATE nStrana := 0
   kalk_zagl_real_partnera()

   SEEK cIdFirma + cIdkonto

   nVPV := nNV := nVPVBP := nPRUC := nPP := nZarada := nRabat := 0
   nRuc := 0
   nNivP := nNivS := 0
   // nivelacija povecanje, snizenje
   nUlazD := nUlazND := 0
   nUlazO := nUlazNO := 0
   // ostali ulazi
   nUlazPS := nUlazNPS := 0
   // pocetno stanje
   nIzlazP := nIzlazNP := 0
   // izlazi prodavnica
   nIzlazO := nIzlazNO := 0
   // ostali izlazi

   DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cidkonto = mkonto .AND. IspitajPrekid()

      nPaNV := nPaVPV := nPaPruc := nPaRuc := nPaPP := nPaZarada := nPaRabat := 0
      cIdPartner := idpartner

      // Vindija - ispitaj opcine za partnera
      IF IsVindija() .AND. !Empty( cOpcine )
         SELECT partn
         HSEEK cIdPartner
         IF At( AllTrim( partn->idops ), cOpcine ) == 0
            SELECT kalk
            SKIP
            LOOP
         ENDIF
         SELECT kalk
      ENDIF

      DO WHILE !Eof() .AND. idfirma == cidfirma .AND. idpartner == cidpartner  .AND. cidkonto = mkonto .AND. IspitajPrekid()

         SELECT roba
         HSEEK kalk->idroba
         SELECT tarifa
         HSEEK kalk->idtarifa
         SELECT kalk

         IF idvd = "14"

            IF aUslp <> ".t." .AND. ! &aUslP
               SKIP
               LOOP
            ENDIF

            set_pdv_public_vars()

            nVPVBP := nVPV / ( 1 + _PORVT )
            nPaNV += Round( NC * kolicina, gZaokr )
            nPaVPV += Round( VPC * ( Kolicina ), gZaokr )
            nPaPP += Round( MPC / 100 * VPC * ( 1 -RabatV / 100 ) * Kolicina, gZaokr )

            nPaRabat += Round( RabatV / 100 * VPC * Kolicina, gZaokr )
            nPom := VPC * ( 1 -RabatV / 100 ) - NC
            nPaRuc += Round( nPom * Kolicina, gZaokr )

            IF nPom > 0
               // porez na ruc se obracunava
               // samo ako je pozit. razlika
               IF gVarVP == "1"
                  nPaPRUC += Round( nPom * Kolicina * tarifa->VPP / 100, gZaokr )
               ELSE
                  nPaPRUC += Round( nPom * Kolicina * tarifa->VPP / 100 / ( 1 + tarifa->VPP / 100 ), gZaokr )
                  // Preracunata stopa
               ENDIF
            ENDIF

         ELSEIF idvd == "18"
            // nivelacija
            IF vpc > 0
               nNivP += vpc * kolicina
            ELSE
               nNivS += vpc * kolicina
            ENDIF

         ELSEIF idvd $ "11#12#13"
            // prodavnica
            nIzlazNP += Round( NC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
            nIzlazP += Round( VPC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
         ELSEIF mu_i == "2"
            // ostali izlazi
            nIzlazNO += Round( NC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
            nIzlazO += Round( VPC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
         ELSEIF idvd == "10"
            nUlazND += Round( NC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
            nUlazD += Round( VPC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )

         ELSEIF mu_i == "1"
            // ostali ulazi
            IF Day( datdok ) = 1 .AND. Month( datdok ) = 1
               // datum 01.01
               nUlazNPS += Round( NC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
               nUlazPS += Round( VPC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
            ELSE
               nUlazNO += Round( NC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
               nUlazO += Round( VPC * ( Kolicina - GKolicina - GKolicin2 ), gZaokr )
            ENDIF

         ENDIF
         SKIP
      ENDDO


      nPaZarada := nPaVPV - nPaNV

      // zarada

      IF nPaNV = 0 .AND. nPAVPV = 0 .AND. nPaRabat = 0 .AND. nPaPP = 0 .AND. nPaZarada = 0
         LOOP
      ENDIF

      IF PRow() > RPT_PAGE_LEN
         FF
         kalk_zagl_real_partnera()
      ENDIF
      SELECT partn
      HSEEK cIdPartner
      SELECT kalk

      ? Space( 2 ), cIdPartner, PadR( partn->naz, 25 )

      nCol1 := PCol() + 1

      @ PRow(), nCol1    SAY nPaNV   PICT gpicdem
      @ PRow(), PCol() + 1 SAY nPaRUC  PICT gpicdem



      @ PRow(), PCol() + 1 SAY nPaZarada PICT gpicdem
      @ PRow(), PCol() + 1 SAY nPaVPV  PICT gpicdem
      @ PRow(), PCol() + 1 SAY nPaRabat PICT gpicdem
      @ PRow(), PCol() + 1 SAY nPaPP  PICT gpicdem
      @ PRow(), PCol() + 1 SAY nPaVPV - nPaRabat + nPaPP  PICT gpicdem

      nNV += nPaNV
      nVPV += nPaVPV
      nPRuc += nPaPruc
      nZarada += nPaZarada
      nRuc += nPaRuc
      nPP += nPaPP
      nRabat += nPaRabat

   ENDDO

   IF PRow() > RPT_PAGE_LEN
      FF
      kalk_zagl_real_partnera()
   ENDIF

   ? m
   ? "   Ukupno:"
   @ PRow(), nCol1    SAY nNV   PICT gpicdem
   @ PRow(), PCol() + 1 SAY nRUC  PICT gpicdem

   @ PRow(), PCol() + 1 SAY nZarada PICT gpicdem
   @ PRow(), PCol() + 1 SAY nVPV  PICT gpicdem
   @ PRow(), PCol() + 1 SAY nRabat PICT gpicdem
   @ PRow(), PCol() + 1  SAY nPP  PICT gpicdem
   @ PRow(), PCol() + 1 SAY nVPV - nRabat + nPP  PICT gpicdem

   ? m

   IF PRow() > 50
      FF
      kalk_zagl_real_partnera( .F. )
   ENDIF

   P_12CPI
   ?
   ? Replicate( "=", 45 )
   ? "Rekapitulacija  prometa za period :"
   ? Replicate( "=", 45 )
   ?
   ? "--------------------------------- ---------- --------"

   ? "                        Nab.vr.    Prod.vr     Ruc%"

   ? "--------------------------------- ---------- --------"
   ?

   ? "**** ULAZI: ********"
   IF nulazPS <> 0
      ? "-    pocetno stanje:  "
      @ PRow(), PCol() + 1 SAY nUlazNPS PICT gpicdem
      @ PRow(), PCol() + 1 SAY nUlazPS PICT gpicdem
      IF nulazPS <> 0
         @ PRow(), PCol() + 1 SAY ( nUlazPS - nUlazNPS ) / nUlazPS * 100 PICT "999.99%"
      ENDIF

   ENDIF
   IF nulazd <> 0
      ? "-       Dobavljaci :  "
      @ PRow(), PCol() + 1 SAY nUlazND PICT gpicdem
      @ PRow(), PCol() + 1 SAY nUlazD PICT gpicdem
      IF nulazD <> 0
         @ PRow(), PCol() + 1 SAY ( nUlazD - nUlazND ) / nUlazD * 100 PICT "999.99%"
      ENDIF
   ENDIF

   IF nulazo <> 0
      ? "-           ostalo :  "
      @ PRow(), PCol() + 1 SAY nUlazNO PICT gpicdem
      @ PRow(), PCol() + 1 SAY nUlazO PICT gpicdem
      IF nulazO <> 0
         @ PRow(), PCol() + 1 SAY ( nUlazO - nUlazNO ) / nUlazO * 100 PICT "999.99%"
      ENDIF
   ENDIF

   IF nNivP <> 0 .OR. nNivS <> 0
      ?
      ? "**** Nivelacije ****"
      IF nNivP <> 0
         ? "-        povecanje :  "
         @ PRow(), PCol() + 1 SAY Space( Len( gpicdem ) )
         @ PRow(), PCol() + 1 SAY nNivP PICT gpicdem
      ENDIF
      IF nNivS <> 0
         ? "-        snizenje  :  "
         @ PRow(), PCol() + 1 SAY Space( Len( gpicdem ) )
         @ PRow(), PCol() + 1 SAY nNivS PICT gpicdem
      ENDIF
   ENDIF

   ?

   ? "**** IZLAZI (Prod.vr.-Rabat) **"

   ? "-      realizacija :  "
   @ PRow(), PCol() + 1 SAY nNV PICT gpicdem
   @ PRow(), PCol() + 1 SAY nVPV - nRabat PICT gpicdem
   IF ( nVPV - nRabat ) <> 0
      @ PRow(), PCol() + 1 SAY nZarada / ( nVPV - nRabat ) * 100 PICT "999.99%"
   ENDIF

   IF nIzlazP <> 0
      ? "-       prodavnice :  "
      @ PRow(), PCol() + 1 SAY nIzlazNP PICT gpicdem
      @ PRow(), PCol() + 1 SAY nIzlazP PICT gpicdem
      IF nIzlazP <> 0
         @ PRow(), PCol() + 1 SAY ( nIzlazP - nIzlazNP ) / nIzlazP * 100 PICT "999.99%"
      ENDIF
   ENDIF

   IF nIzlazO <> 0
      ? "-           ostalo :  "
      @ PRow(), PCol() + 1 SAY nIzlazNo PICT gpicdem
      @ PRow(), PCol() + 1 SAY nIzlazo PICT gpicdem
      IF nIzlazO <> 0
         @ PRow(), PCol() + 1 SAY ( nIzlazO - nIzlazNO ) / nIzlazO * 100 PICT "999.99%"
      ENDIF
   ENDIF

   FF

   ENDPRINT
   closeret

   RETURN
// }




/* kalk_zagl_real_partnera(fTabela)
 *     Zaglavlje izvjestaja "realizacija veleprodaje po partnerima"
 */

FUNCTION kalk_zagl_real_partnera( fTabela )

   // {
   IF ftabela = NIL
      ftabela := .T.
   ENDIF

   Preduzece()
   P_12CPI

   SET CENTURY ON
   ? "  KALK: REALIZACIJA VELEPRODAJE PO PARTNERIMA    na dan:", Date()
   ?? Space( 6 ), "Strana:", Str( ++nStrana, 3 )
   ? "        Magacin:", cIdkonto, "   period:", dDat1, "DO", dDat2
   SET CENTURY OFF

   P_COND

   IF ftabela
      ?
      ? m

      ? "   *           Partner            *    NV     *  ZARADA  *   RUC    * Prod.vr  *  Rabat   *   PDV    *  Ukupno *"


      ? "   *                              *           *(RUC-RAB.)* (PV - NV) *         *          *          *          *" + IF( !IsPDV(), "         *", "" )

      ? m
   ENDIF

   RETURN
