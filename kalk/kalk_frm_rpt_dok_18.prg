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

/*
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_18.prg,v $
 * $Author: mirsad $
 * $Revision: 1.3 $
 * $Log: rpt_18.prg,v $
 * Revision 1.3  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 */


/* \file fmk/kalk/mag/dok/1g/rpt_18.prg
 *     Stampa dokumenta tipa 18
 */


/* StKalk18()
 *     Stampa dokumenta tipa 18
 */

FUNCTION StKalk18()

   // {
   LOCAL nCol1 := nCol2 := 0, npom := 0, nCR := 0

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2
   // iznosi troskova i marzi koji se izracunavaju u KTroskovi()

   IF cSeek != 'IZDOKS'  // stampa se vise dokumenata odjednom
      nStr := 1
   ENDIF

   cIdPartner := IdPartner; cBrFaktP := BrFaktP; dDatFaktP := DatFaktP

   cIdKonto := IdKonto; cIdKonto2 := IdKonto2

   P_10CPI
   B_ON
   ?? "PROMJENA CIJENA U MAGACINU"
   B_OFF
   ?
   P_COND
   ? "KALK BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), ", Datum:", DatDok
   @ PRow(), 122 SAY "Str:" + Str( nStr, 3 )

   SELECT KONTO; HSEEK cidkonto
   ?  "KONTO zaduzuje :", cIdKonto, "-", naz
   SELECT kalk_pripr

   m := "--- ------------------------------------------------ ----------- ---------- ---------- ---------- ---------- ---------- ----------"

   ? m
   IF IsPDV()
      ? "*RB*       ROBA                                     * Kolicina  * STARA PC *  RAZLIKA *  NOVA  PC*  IZNOS   *   PDV%  *  IZNOS   *"
      ? "*  *                                                *           *  BEZ PDV *PC BEZ PDV*  BEZ PDV *  RAZLIKE *         *   PDV    *"
   ELSE
      ? "*RB*       ROBA                                     * Kolicina  * STARA VPC*  RAZLIKA *  NOVA VPC*  IZNOS   *   PPP%  *  IZNOS   *"
      ? "*  *                                                *           *          *    VPC   *          *  RAZLIKE *         *   PPP    *"
   ENDIF
   ? m
   nTotA := nTotB := nTotC := 0


   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

/*
 if idpartner+brfaktp+idkonto+idkonto2<>cidd
  set device to screen
  Beep(2)
  Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
  set device to printer
 endif
*/


      SELECT ROBA; HSEEK kalk_pripr->IdRoba
      SELECT TARIFA; HSEEK kalk_pripr->IdTarifa
      SELECT kalk_pripr

      KTroskovi()

      IF PRow() > page_length()
         FF
         @ PRow(), 122 SAY "Str:" + Str( ++nStr, 3 )
      ENDIF

      VTPOREZI()

      nTotA += VPC * Kolicina
      nTotB += vpc / ( 1 + _PORVT ) * _PORVT * kolicina

      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      @ PRow(), PCol() + 1 SAY IdRoba
      aNaz := SjeciStr( Trim( ROBA->naz ) + " ( " + ROBA->jmj + " )", 37 )
      @ PRow(), ( nCR := PCol() + 1 ) SAY  ""; ?? aNaz[ 1 ]
      @ PRow(), 52 SAY Kolicina
      @ PRow(), PCol() + 1 SAY MPCSAPP  PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY VPC      PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY MPCSAPP + VPC  PICTURE PicCDEM
      nC1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY VPC * Kolicina  PICTURE PicDEM
      @ PRow(), PCol() + 1 SAY _porvt * 100    PICTURE Picproc
      @ PRow(), PCol() + 1 SAY vpc / ( 1 + _PORVT ) * _PORVT * kolicina   PICTURE Picdem

      // novi red
      IF Len( aNaz ) > 1
         @ PRow() + 1, 0 SAY ""
         @ PRow(), nCR  SAY ""; ?? aNaz[ 2 ]
      ENDIF

      SKIP

   ENDDO

   IF PRow() > page_length()
      FF
      @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   ENDIF
   ? m
   @ PRow() + 1, 0        SAY "Ukupno:"

   @ PRow(), nC1  SAY nTota         PICTURE PicDEM
   @ PRow(), PCol() + 1  SAY 0             PICTURE PicDEM
   @ PRow(), PCol() + 1  SAY nTotB         PICTURE PicDEM

   ? m

   ?
   P_10CPI
   ? PadL( "Clanovi komisije: 1. ___________________", 75 )
   ? PadL( "2. ___________________", 75 )
   ? PadL( "3. ___________________", 75 )
   ?

   RETURN
// }
