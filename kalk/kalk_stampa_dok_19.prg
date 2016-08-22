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



FUNCTION kalk_stampa_dok_19()

   LOCAL nCol1 := nCol2 := 0, npom := 0

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2, aPorezi

   // iznosi troskova i marzi koji se izracunavaju u kalk_unos_troskovi()

   aPorezi := {}
   nStr := 0
   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP
   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2

   P_10CPI
   B_ON
   ?? "PROMJENA CIJENA U PRODAVNICI"
   ?
   B_OFF
   P_COND
   ? "KALK BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, ", Datum:", DatDok
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   SELECT PARTN
   HSEEK cIdPartner             // izbaciti?  19.5.00
   SELECT KONTO
   HSEEK cidkonto               // dodano     19.5.00

   ?  "KONTO zaduzuje :", cIdKonto, "-", naz

   SELECT kalk_pripr

   IF ( cIdVD == "19" )
      m := "--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
      ? m
      head_19()
      ? m
      nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := 0
   ENDIF

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVd == IdVd

      vise_kalk_dok_u_pripremi( cIdd )
      RptSeekRT()
      kalk_unos_troskovi()
      set_pdv_public_vars()

      Tarifa( kalk_pripr->pkonto, kalk_pripr->idroba, @aPorezi )

      // nova cijena
      nMpcSaPP1 := field->mpcSaPP + field->fcj
      nMpc1 := MpcBezPor( nMpcSaPP1, aPorezi,, field->nc )
      aIPor1 := RacPorezeMP( aPorezi, nMpc1, nMpcSaPP1, field->nc )

      // stara cijena
      nMpcSaPP2 := field->fcj
      nMpc2 := MpcBezPor( nMpcSaPP2, aPorezi,, field->nc )
      aIPor2 := RacPorezeMP( aPorezi, nMpc2, nMpcSaPP2, field->nc )

      print_nova_strana( 125, @nStr, 2 )

      nTot3 +=  ( nU3 := MPC * Kolicina )

      nPor1 := aIPor1[ 1 ] -aIPor2[ 1 ]
      nPor2 := aIPor1[ 2 ] -aIPor2[ 2 ]

      nTot4 +=  ( nU4 := ( nPor1 + nPor2 ) * Kolicina )
      nTot5 +=  ( nU5 := MPcSaPP * Kolicina )

      // 1. red

      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      @ PRow(), 4 SAY  ""
      ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"
      @ PRow() + 1, 4 SAY IdRoba
      @ PRow(), PCol() + 1 SAY Kolicina             PICTURE PicKol
      @ PRow(), PCol() + 1 SAY FCJ                  PICTURE PicCDEM
      nC0 := PCol() + 1
      @ PRow(), PCol() + 1 SAY MPC                  PICTURE PicCDEM
      nC1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY aPorezi[ POR_PPP ]            PICTURE PicProc
      @ PRow(), PCol() + 1 SAY nPor1                         PICTURE PicDEM
      @ PRow(), PCol() + 1 SAY nPor1 * Kolicina                PICTURE PicDEM
      @ PRow(), PCol() + 1 SAY MPCSAPP                       PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY MPCSAPP + FCJ                   PICTURE PicCDEM

      // 2. red

      @ PRow() + 1, nC1 SAY 0                       PICTURE PicProc
      @ PRow(), PCol() + 1 SAY nPor2                PICTURE PicDEM
      @ PRow(), PCol() + 1 SAY nPor2 * Kolicina     PICTURE PicDEM
      @ PRow(), PCol() + 1 SAY ( MPCSAPP / FCJ ) * 100  PICTURE picproc
      @ PRow(), PCol() + 1 SAY Space( Len( PicCDEM ) )

      SKIP

   ENDDO

   print_nova_strana( 125, @nStr, 3 )

   ? m
   @ PRow() + 1, 0        SAY "Ukupno:"
   @ PRow(), nC0        SAY  nTot3         PICTURE        PicDEM
   @ PRow(), PCol() + 1   SAY  Space( Len( picdem ) )
   @ PRow(), PCol() + 1   SAY  Space( Len( picdem ) )
   @ PRow(), PCol() + 1   SAY  nTot4         PICTURE        PicDEM
   @ PRow(), PCol() + 1   SAY  nTot5         PICTURE        PicDEM
   ? m

   ?
   Rektarife()

   PrnClanoviKomisije()

   RETURN
// }


FUNCTION head_19()

   // {
   IF IsPDV()
      ? "*R * ROBA     * Kolicina *  STARA   * RAZLIKA  * PDV   %  *IZN. PDV  * UK. PDV  * RAZLIKA  *  NOVA   *"
      ? "*BR*          *          *MPC SA PDV*   MPC    *          *          *          *MPC SA PDV*MPC SA PDV*"
      ? "*  *          *          *   sum    *   sum    *          *   sum    *   sum    *   sum    *   sum   *"
   ELSE
      ? "*R * ROBA     * Kolicina *  STARA   * RAZLIKA  * PPP   %  *IZN. PPP  * UK. PPP  * RAZLIKA  *  NOVA   *"
      ? "*BR*          *          *MPC SA PP *   MPC    * PPU   %  *IZN. PPU  * UK. PPU  * MPC SA PP*MPC SA PP*"
      ? "*  *          *          *   sum    *   sum    *          *   sum    *   sum    *   sum    *   sum   *"
   ENDIF

   RETURN
// }


/* Obraz19()
 *     Stampa dokumenta tipa 19 - obrazac nivelacije
 */

FUNCTION Obraz19()

   // {
   LOCAL nCol1 := nCol2 := 0, npom := 0

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2
   // iznosi troskova i marzi koji se izracunavaju u kalk_unos_troskovi()

   nStr := 0
   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP
   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2

   cProred := "N"
   cPodvuceno := "N"
   Box(, 2, 60 )
   @ m_x + 1, m_y + 2 SAY "Prikazati sa proredom:" GET cProred VALID cprored $ "DN" PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Prikazati podvuceno  :" GET cPodvuceno VALID cpodvuceno $ "DN" PICT "@!"
   READ
   ESC_BCR
   BoxC()

   START PRINT CRET
   ?
   Preduzece()

   P_10CPI
   B_ON
   ? PadL( "Prodavnica __________________________", 74 )
   ?
   ?
   ? PadC( "PROMJENA CIJENA U PRODAVNICI ___________________, Datum _________", 80 )
   ?
   B_OFF

   SELECT kalk_pripr

   P_COND
   ?
   @ PRow(), 110 SAY "Str:" + Str( ++nStr, 3 )

   IF cIdVD == "19"
      m := "--- --------------------------------------------------- ---------- ---------- ---------- ------------- ------------- -------------"
      ? m
      ? "*R *  Sifra   *        Naziv                           *  STARA   *   NOVA   * promjena *  zaliha     *   iznos     *  ukupno    *"
      ? "*BR*          *                                        *  cijena  *  cijena  *  cijene  * (kolicina)  *   poreza    * promjena   *"
      ? m
      nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := 0
   ENDIF

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

      vise_kalk_dok_u_pripremi( cIdd )

      SELECT ROBA
      HSEEK kalk_pripr->IdRoba
      SELECT TARIFA
      HSEEK kalk_pripr->IdTarifa
      SELECT kalk_pripr


      print_nova_strana( 110, @nStr, iif( cProred == "D", 2, 1 ) )

      ?
      IF cPodvuceno == "D"
         U_ON
      ENDIF
      ?? rbr + " " + idroba + " " + PadR( Trim( Left( ROBA->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 )
      @ PRow(), PCol() + 1 SAY FCJ                  PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY MPCSAPP + FCJ          PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY MPCSAPP              PICTURE PicCDEM
      IF cPodvuceno == "D"
         U_OFF
      ENDIF
      @ PRow(), PCol() + 1 SAY "_____________"
      @ PRow(), PCol() + 1 SAY "_____________"
      @ PRow(), PCol() + 1 SAY "_____________"
      IF cProred == "D"
         ?
      ENDIF
      SKIP

   ENDDO


   print_nova_strana( 110, @nStr, 12 )

   ? m
   ? " UKUPNO "
   ? m
   ?
   ?
   ?
   P_10CPI

   PrnClanoviKomisije()

   ENDPRINT

   RETURN
// }