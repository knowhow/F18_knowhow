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


FUNCTION StKalk81( fzatops )

   LOCAL nCol1 := nCol2 := 0, npom := 0
   LOCAL _is_rok, _dok_hash

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2, nPRUC, aPorezi

   nMarza := nMarza2 := nPRUC := 0
   aPorezi := {}

   // iznosi troskova i marzi koji se izracunavaju u KTroskovi()

   nStr := 0
   cIdPartner := IdPartner; cBrFaktP := BrFaktP; dDatFaktP := DatFaktP

   cIdKonto := IdKonto; cIdKonto2 := IdKonto2

   IF fzaTops == NIL
      fzaTops := .F.
   ENDIF

   _is_rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"

   P_COND2

   ?? "KALK: KALKULACIJA BR:", cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), P_TipDok( cIdVD, -2 ), Space( 2 ), "Datum:", DatDok

   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   SELECT PARTN
   HSEEK cIdPartner

   ?U "DOBAVLJAČ:", cIdPartner, "-", PadR( naz, 20 ), Space( 5 ), "DOKUMENT Broj:", AllTrim( cBrFaktP ), "Datum:", dDatFaktP

   SELECT KONTO
   HSEEK cIdKonto

   ?U  "KONTO zadužuje :", cIdKonto, "-", AllTrim( naz )

   IF !fZaTops

      m := "--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

      IF IsPDV()
         m += " -----------"
      ENDIF

      IF lPrikPRUC
         m += " ----------"
         ? m
         ? "*R * ROBA     *  FCJ     * TRKALO   * KASA-    * " + c10T1 + " * " + c10T2 + " * " + c10T3 + " * " + c10T4 + " * " + c10T5 + " *   NC     * MARZA.   * POREZ NA *   MPC    * MPCSaPP *"
         ? "*BR* TARIFA   *  KOLICINA* OST.KALO * SKONTO   *          *          *          *          *          *          *          *   MARZU  *          *         *"
         ? "*  *          *          *          *          *          *          *          *          *          *          *          *          *          *         *"
      ELSE

         ? m
         ? "*R * ROBA     *  FCJ     * TRKALO   * KASA-    * " + c10T1 + " * " + c10T2 + " * " + c10T3 + " * " + c10T4 + " * " + c10T5 + " *   NC     * MARZA.   *   MPC    * MPCSaPP *"
         ? "*BR* TARIFA   *  KOLICINA* OST.KALO * SKONTO   *          *          *          *          *          *          *          *          *         *"
         ? "*  *          *          *          *          *          *          *          *          *          *          *          *          *         *"

      ENDIF
      ? m

   ELSE

      m := "--- ---------- ---------- ---------- ----------"

      ? m

      ? "*R * ROBA     * Kolicina *    PC    *PC sa PDV*"
      ? "*BR* TARIFA   *          *          *         *"
      ? "*  *          *          *          *         *"
      ? m

   ENDIF

   nTot := nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTotA := nTotb := nTotC := 0
   nTot9a := 0
   nUC := 0

   SELECT kalk_pripr

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

      KTroskovi()

      SELECT ROBA
      HSEEK kalk_pripr->IdRoba
      SELECT TARIFA
      HSEEK kalk_pripr->IdTarifa

      SELECT kalk_pripr

      Tarifa( field->pkonto, field->idRoba, @aPorezi )
      aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcSaPP, field->nc )

      nPor1 := aIPor[ 1 ]

      IF lPrikPRUC
         nPRUC := aIPor[ 2 ]
         nMarza2 := nMarza2 - nPRUC
      ENDIF

      IF PRow() > page_length() - 4
         FF
         @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
      ENDIF

      IF gKalo == "1"
         SKol := Kolicina - GKolicina - GKolicin2
      ELSE
         SKol := Kolicina
      ENDIF

      nTot +=  ( nU := FCj * Kolicina )
      IF gKalo == "1"
         nTot1 += ( nU1 := FCj2 * ( GKolicina + GKolicin2 ) )
      ELSE
         nTot1 += ( nU1 := NC * ( GKolicina + GKolicin2 ) )
      ENDIF
      nTot2 += ( nU2 := -Rabat / 100 * FCJ * Kolicina )
      nTot3 += ( nU3 := nPrevoz * SKol )
      nTot4 += ( nU4 := nBankTr * SKol )
      nTot5 += ( nU5 := nSpedTr * SKol )
      nTot6 += ( nU6 := nCarDaz * SKol )
      nTot7 += ( nU7 := nZavTr * SKol )
      nTot8 += ( nU8 := NC *    ( Kolicina - Gkolicina - GKolicin2 ) )
      nTot9 += ( nU9 := nMarza2 * ( Kolicina - Gkolicina - GKolicin2 ) )
      IF lPrikPRUC
         nTot9a += ( nU9a := nPRUC * ( Kolicina - Gkolicina - GKolicin2 ) )
      ENDIF
      nTotA += ( nUA := MPC   * ( Kolicina - Gkolicina - GKolicin2 ) )
      nTotB += ( nUB := MPCSAPP * ( Kolicina - Gkolicina - GKolicin2 ) )
      nTotC += ( nUC := nPor1 * ( Kolicina - Gkolicina - GKolicin2 ) )

      // prvi red
      @ PRow() + 1, 0 SAY rbr PICT "999"
      @ PRow(), 4 SAY ""
      ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"

      IF lKoristitiBK .AND. !Empty( roba->barkod )
         ?? ", BK: " + ROBA->barkod
      ENDIF

      IF _is_rok
         _dok_hash := hb_Hash()
         _dok_hash[ "idfirma" ] := field->idfirma
         _dok_hash[ "idtipdok" ] := field->idvd
         _dok_hash[ "brdok" ] := field->brdok
         _dok_hash[ "rbr" ] := field->rbr
         _item_istek_roka := CToD( get_kalk_atribut_rok( _dok_hash, .T. ) )
         IF DToC( _item_istek_roka ) <> DToC( CToD( "" ) )
            ?? " datum isteka roka:", _item_istek_roka
         ENDIF
      ENDIF

      @ PRow() + 1, 4 SAY IdRoba
      nCol1 := PCol() + 1
      IF !fZaTops
         @ PRow(), PCol() + 1 SAY FCJ                   PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY GKolicina             PICTURE PicKol
         @ PRow(), PCol() + 1 SAY -Rabat                PICTURE PicProc
         @ PRow(), PCol() + 1 SAY nPrevoz / FCJ2 * 100      PICTURE PicProc
         @ PRow(), PCol() + 1 SAY nBankTr / FCJ2 * 100      PICTURE PicProc
         @ PRow(), PCol() + 1 SAY nSpedTr / FCJ2 * 100      PICTURE PicProc
         @ PRow(), PCol() + 1 SAY nCarDaz / FCJ2 * 100      PICTURE PicProc
         @ PRow(), PCol() + 1 SAY nZavTr / FCJ2 * 100       PICTURE PicProc
         @ PRow(), PCol() + 1 SAY NC                    PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY nMarza2 / NC * 100        PICTURE PicProc
         IF lPrikPRUC
            @ PRow(), PCol() + 1 SAY aPorezi[ POR_PRUCMP ] PICTURE PicProc
         ENDIF
      ELSE
         @ PRow(), PCol() + 1 SAY Kolicina             PICTURE PicCDEM
      ENDIF
      @ PRow(), PCol() + 1 SAY MPC                   PICTURE PicCDEM
      IF IsPDV()
         @ PRow(), PCol() + 1 SAY aPorezi[ POR_PPP ] PICTURE PicProc
      ENDIF
      @ PRow(), PCol() + 1 SAY MPCSaPP               PICTURE PicCDEM

      // drugi red
      @ PRow() + 1, 4 SAY IdTarifa
      IF !fzatops
         @ PRow(), nCol1    SAY Kolicina             PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY GKolicin2            PICTURE PicKol
         @ PRow(), PCol() + 1 SAY -Rabat / 100 * FCJ       PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY nPrevoz              PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY nBankTr              PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY nSpedTr              PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY nCarDaz              PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY nZavTr               PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY Space( Len( picdem ) )
         @ PRow(), PCol() + 1 SAY nMarza2              PICTURE PicCDEM
         IF lPrikPRUC
            @ PRow(), PCol() + 1 SAY nPRUC                PICTURE PicCDEM
         ELSE
            @ PRow(), PCol() + 1 SAY Space( Len( PicCDEM ) )
         ENDIF
         IF IsPDV()
            @ PRow(), PCol() + 1 SAY nPor1 PICTURE PicCDEM
         ENDIF
      ENDIF

      // treci red
      IF !fZatops
         @ PRow() + 1, nCol1   SAY nU          PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU1         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU2         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU3         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU4         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU5         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU6         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU7         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU8         PICTURE         PICDEM
         @ PRow(), PCol() + 1  SAY nU9         PICTURE         PICDEM
         IF lPrikPRUC
            @ PRow(), PCol() + 1  SAY nU9a        PICTURE         PICDEM
         ENDIF
      ELSE
         @ PRow() + 1, nCol1 - 1   SAY Space( Len( picdem ) )
      ENDIF
      @ PRow(), PCol() + 1  SAY nUA         PICTURE         PICDEM
      IF IsPDV()
         @ PRow(), PCol() + 1  SAY nUC  PICTURE PICDEM
      ENDIF
      @ PRow(), PCol() + 1  SAY nUB         PICTURE         PICDEM
      SKIP
   ENDDO

   IF PRow() > page_length() - 3
      FF
      @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   ENDIF

   ? m

   @ PRow() + 1, 0        SAY "Ukupno:"
   // ************************** magacin *****************************
   IF !fzatops
      @ PRow(), nCol1     SAY nTot          PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot1         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot2         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot3         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot4         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot5         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot6         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot7         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot8         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nTot9         PICTURE         PICDEM
      IF lPrikPRUC
         @ PRow(), PCol() + 1  SAY nTot9a        PICTURE         PICDEM
      ENDIF
   ELSE
      @ PRow() + 1, nCol1 - 1   SAY Space( Len( picdem ) )
   ENDIF
   @ PRow(), PCol() + 1  SAY nTotA         PICTURE         PICDEM
   IF IsPDV()
      @ PRow(), PCol() + 1 SAY nTotC PICTURE PICDEM
   ENDIF
   @ PRow(), PCol() + 1  SAY nTotB         PICTURE         PICDEM

   ? m

   nTot1 := nTot2 := nTot2b := nTot3 := nTot4 := 0
   nTot5 := nTot6 := nTot7 := 0

   RekTarife()

   IF !fZaTops
      ? "RUC:";  @ PRow(), PCol() + 1 SAY nTot6 PICT picdem
   ENDIF

   ? m

   // potpis na dokumentu
   dok_potpis( 90, "L", nil, nil )

   RETURN .T.





/*! \fn StKalk81_2()
 *  \brief Stampa kalkulacije 81 - direktno zaduzenje prodavnice
 */

FUNCTION StKalk81_2()

   LOCAL _dok_hash, _is_rok
   LOCAL nCol1 := nCol2 := 0, npom := 0
   PRIVATE aPorezi

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2, nPRUC

   nMarza := nMarza2 := nPRUC := 0
   // iznosi troskova i marzi koji se izracunavaju u KTroskovi()

   nStr := 0
   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP
   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2

   _is_rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"

   P_10CPI
   ?? "ULAZ U PRODAVNICU DIREKTNO OD DOBAVLJACA"
   P_COND
   ?
   ?? "KALK: KALKULACIJA BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), P_TipDok( cIdVD, -2 ), Space( 2 ), "Datum:", DatDok
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   SELECT PARTN; HSEEK cIdPartner

   ?  "DOBAVLJAC:", cIdPartner, "-", PadR( naz, 20 ), Space( 5 ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP

   SELECT KONTO
   HSEEK cIdKonto

   ?  "KONTO zaduzuje :", cIdKonto, "-", AllTrim( naz )

   m := "---- ---------- ---------- ---------- ---------- ---------- ---------- ----------" + ;
      IF( lPrikPRUC, " ----------", "" ) + " ---------- -----------"

   IF IsPDV()
      m += " ----------"
   ENDIF

   ? m

   IF !IsPDV()
      IF lPrikPRUC
         ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   * POREZ NA *   MPC    * MPCSaPP  *"
         ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *   MARZU  *          *          *"
         ? "*  *          *   sum    *  sum     *    sum    *          *          *   sum    *   sum    *   sum    *   sum    *"
      ELSE
         ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   *   MPC    * MPCSaPP  *"
         ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *          *          *"
         ? "*  *          *   sum    *  sum     *    sum    *          *          *   sum    *   sum    *   sum    *"
      ENDIF
   ELSE
      IF lPrikPRUC
         ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   * POREZ NA *   MPC    * MPCSaPDV *"
         ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *   MARZU  *          *          *"
         ? "*  *          *   sum    *  sum     *    sum    *          *          *   sum    *   sum    *   sum    *   sum    *"
      ELSE
         ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   *    PC    *  PDV(%)  *    PC    *"
         ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *  BEZ PDV *  PDV     *  SA PDV  *"
         ? "*  *          *   sum    *  sum     *    sum    *          *          *   sum    *   sum    *   sum    *          *"
      ENDIF

   ENDIF

   ? m
   nTot := nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTotA := nTotb := 0
   nTot9a := 0
   nTotC := nUC := 0
   nPor1 := 0

   SELECT kalk_pripr

   aPorezi := {}
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

      KTroskovi()
      Tarifa( field->pkonto, field->idRoba, @aPorezi )

      SELECT ROBA
      HSEEK kalk_pripr->IdRoba
      SELECT TARIFA
      HSEEK kalk_pripr->IdTarifa
      SELECT kalk_pripr

      aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcSaPP, field->nc )

      nPor1 := aIPor[ 1 ]

      IF lPrikPRUC
         nPRUC := aIPor[ 2 ]
         nMarza2 := nMarza2 - nPRUC
      ENDIF

      IF PRow() > page_length()
         FF
         @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
      ENDIF

      IF gKalo == "1"
         SKol := Kolicina - GKolicina - GKolicin2
      ELSE
         SKol := Kolicina
      ENDIF

      nTot +=  ( nU := FCj * Kolicina )
      IF gKalo == "1"
         nTot1 += ( nU1 := FCj2 * ( GKolicina + GKolicin2 ) )
      ELSE
         nTot1 += ( nU1 := NC * ( GKolicina + GKolicin2 ) )
      ENDIF
      nTot2 += ( nU2 := -Rabat / 100 * FCJ * Kolicina )
      nTot3 += ( nU3 := nPrevoz * SKol )
      nTot4 += ( nU4 := nBankTr * SKol )
      nTot5 += ( nU5 := nSpedTr * SKol )
      nTot6 += ( nU6 := nCarDaz * SKol )
      nTot7 += ( nU7 := nZavTr * SKol )
      nTot8 += ( nU8 := NC *    ( Kolicina - Gkolicina - GKolicin2 ) )
      nTot9 += ( nU9 := nMarza2 * ( Kolicina - Gkolicina - GKolicin2 ) )
      IF lPrikPRUC
         nTot9a += ( nU9a := nPRUC * ( Kolicina - Gkolicina - GKolicin2 ) )
      ENDIF
      nTotA += ( nUA := MPC   * ( Kolicina - Gkolicina - GKolicin2 ) )
      nTotB += ( nUB := MPCSAPP * ( Kolicina - Gkolicina - GKolicin2 ) )
      nTotC += ( nUC := nPor1 * ( Kolicina - Gkolicina - GKolicin2 ) )

      // prvi red
      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      @ PRow(), 4 SAY  ""; ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"

      IF lKoristitiBK .AND. !Empty( roba->barkod )
         ?? ", BK: " + roba->barkod
      ENDIF

      IF _is_rok
         _dok_hash := hb_Hash()
         _dok_hash[ "idfirma" ] := field->idfirma
         _dok_hash[ "idtipdok" ] := field->idvd
         _dok_hash[ "brdok" ] := field->brdok
         _dok_hash[ "rbr" ] := field->rbr
         _item_istek_roka := CToD( get_kalk_atribut_rok( _dok_hash, .T. ) )
         IF DToC( _item_istek_roka ) <> DToC( CToD( "" ) )
            ?? " datum isteka roka:", _item_istek_roka
         ENDIF
      ENDIF

      @ PRow() + 1, 4 SAY IdRoba
      nCol1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY FCJ                   PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY -Rabat                PICTURE PicProc
      @ PRow(), PCol() + 1 SAY fcj * ( 1 -Rabat / 100 )     PICTURE piccdem
      @ PRow(), PCol() + 1 SAY ( nPrevoz + nBankTr + nSpedtr + nCarDaz + nZavTr ) / FCJ2 * 100       PICTURE PicProc
      @ PRow(), PCol() + 1 SAY NC                    PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY nMarza2 / NC * 100        PICTURE PicProc
      IF lPrikPRUC
         @ PRow(), PCol() + 1 SAY aPorezi[ POR_PRUCMP ] PICTURE PicProc
      ENDIF
      @ PRow(), PCol() + 1 SAY MPC                   PICTURE PicCDEM
      IF IsPDV()
         @ PRow(), PCol() + 1 SAY aPorezi[ POR_PPP ] PICTURE PicProc
      ENDIF
      @ PRow(), PCol() + 1 SAY MPCSaPP               PICTURE PicCDEM

      // drugi red
      @ PRow() + 1, 4 SAY IdTarifa
      @ PRow(), nCol1    SAY Kolicina             PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY -Rabat / 100 * FCJ       PICTURE PicCDEM
      @ PRow(), PCol() + 1 SAY Space( Len( piccdem ) )
      @ PRow(), PCol() + 1 SAY ( nPrevoz + nBankTr + nSpedtr + nCarDaz + nZavTr )   PICTURE Piccdem
      @ PRow(), PCol() + 1 SAY Space( Len( picdem ) )
      @ PRow(), PCol() + 1 SAY nMarza2              PICTURE PicCDEM
      IF lPrikPRUC
         @ PRow(), PCol() + 1 SAY nPRUC              PICTURE PicCDEM
      ENDIF
      IF IsPDV()
         @ PRow(), PCol() + 1 SAY Space( Len( picdem ) )
         @ PRow(), PCol() + 1 SAY nPor1  PICTURE PicCDEM
      ENDIF
      // treci red
      @ PRow() + 1, nCol1   SAY nU          PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU2         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nu + nU2         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nu3 + nu4 + nu5 + nu6 + nU7         PICTURE  PICDEM
      @ PRow(), PCol() + 1  SAY nU8         PICTURE         PICDEM
      @ PRow(), PCol() + 1  SAY nU9         PICTURE         PICDEM
      IF lPrikPRUC
         @ PRow(), PCol() + 1  SAY nU9a         PICTURE         PICDEM
      ENDIF
      @ PRow(), PCol() + 1  SAY nUA         PICTURE         PICDEM
      IF IsPDV()
         @ PRow(), PCol() + 1 SAY nUC  PICTURE  PICDEM
      ENDIF
      @ PRow(), PCol() + 1  SAY nUB         PICTURE         PICDEM

      SKIP
   ENDDO

   IF PRow() > page_length()
      FF
      @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   ENDIF
   ? m
   @ PRow() + 1, 0        SAY "Ukupno:"
   @ PRow(), nCol1     SAY nTot          PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot2         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot + nTot2         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY ntot3 + ntot4 + ntot5 + ntot6 + nTot7         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot8         PICTURE         PICDEM
   @ PRow(), PCol() + 1  SAY nTot9         PICTURE         PICDEM
   IF lPrikPRUC
      @ PRow(), PCol() + 1  SAY nTot9a        PICTURE         PICDEM
   ENDIF
   @ PRow(), PCol() + 1  SAY nTotA         PICTURE         PICDEM

   IF IsPDV()
      @ PRow(), PCol() + 1  SAY nTotC  PICTURE         PICDEM
   ENDIF

   @ PRow(), PCol() + 1  SAY nTotB         PICTURE         PICDEM

   ? m

   IF PRow() > page_length()
      FF
      @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   ENDIF
   ?
   IF  Round( ntot3 + ntot4 + ntot5 + ntot6 + ntot7, 2 ) <> 0
      ?  m
      ?  "Troskovi (analiticki):"
      ?  c10T1, ":"
      @ PRow(), 30 SAY  ntot3 PICT picdem
      ?  c10T2, ":"
      @ PRow(), 30 SAY  ntot4 PICT picdem
      ?  c10T3, ":"
      @ PRow(), 30 SAY  ntot5 PICT picdem
      ?  c10T4, ":"
      @ PRow(), 30 SAY  ntot6 PICT picdem
      ?  c10T5, ":"
      @ PRow(), 30 SAY  ntot7 PICT picdem
      ? m
      ? "Ukupno troskova:"
      @ PRow(), 30 SAY  ntot3 + ntot4 + ntot5 + ntot6 + ntot7 PICT picdem
      ? m
   ENDIF

   nTot1 := nTot2 := nTot2b := nTot3 := nTot4 := 0
   nTot5 := nTot6 := nTot7 := 0
   RekTarife()

   ? "RUC:";  @ PRow(), PCol() + 1 SAY nTot6 PICT picdem
   ? m

   RETURN
