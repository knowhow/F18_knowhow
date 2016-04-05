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

MEMVAR m
MEMVAR nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2
MEMVAR nStr, cIdFirma, cIdVd, cBrDok, cIdPartner, cBrFaktP, dDatFaktP, cIdKonto, cIdKonto2

FIELD IdPartner, BrFaktP, DatFaktP, IdKonto, IdKonto2, Kolicina, DatDok
FIELD naz, pkonto, mkonto

FUNCTION StKalk14()

   LOCAL nCol1 := 0
   LOCAL nCol2 := 0
   LOCAL nPom := 0
   LOCAL oPDF, xPrintOpt, bZagl

   IF is_legacy_ptxt()
      RETURN StKalk14_txt()
   ENDIF

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

   m := "--- ---------- ---------- ----------  ---------- ---------- ---------- ----------- --------- ----------"

   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP
   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2

   oPDF := PDFClass():New()
   xPrintOpt := hb_Hash()
   xPrintOpt[ "tip" ] := "PDF"
   xPrintOpt[ "layout" ] := "portrait"
   xPrintOpt[ "opdf" ] := oPDF
   xPrintOpt[ "left_space" ] := 0
   f18_start_print( NIL, xPrintOpt,  "KALK Br:" + cIdFirma + "-" + cIdVD + "-" + cBrDok + " / " + AllTrim( P_TipDok( cIdVD, - 2 ) ) + " , Datum:" + DToC( DatDok ) )


   bZagl := {|| zagl() }

   EVAL( bZagl )

   nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTota := nTotb := nTotc := nTotd := 0

   fNafta := .F.

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

      SELECT ROBA
      HSEEK kalk_pripr->IdRoba
      SELECT TARIFA
      HSEEK kalk_pripr->IdTarifa
      SELECT kalk_pripr

      KTroskovi()


      check_nova_strana( bZagl, oPdf )


      IF kalk_pripr->idvd = "15"
         SKol := - Kolicina
      ELSE
         SKol := Kolicina
      ENDIF

      nVPCIzbij := 0

      IF roba->tip == "X"
         nVPCIzbij := ( MPCSAPP / ( 1 + tarifa->opp / 100 ) * tarifa->opp / 100 )
      ENDIF

      nTot4 +=  ( nU4 := Round( NC * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr )     )  // nv

      IF gVarVP == "1"
         IF ( roba->tip $ "UTY" )
            nU5 := 0
         ELSE
            nTot5 +=  ( Round( nU5 := nMarza * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr )  ) // ruc
         ENDIF
         nTot6 +=  ( nU6 := Round( TARIFA->VPP / 100 * iif( nMarza < 0, 0, nMarza ) * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr ) )  // pruc
         nTot7 +=  ( nU7 := nU5 - nU6  )    // ruc-pruc
      ELSE
         // obracun poreza unazad - preracunata stopa
         IF ( roba->tip $ "UTY" )
            nU5 := 0
         ELSE
            IF nMarza > 0
               ( nU5 := Round( nMarza * Kolicina * iif( idvd = "15", -1, 1 ) / ( 1 + tarifa->vpp / 100 ), gZaokr ) ) // ruc
            ELSE
               ( nU5 := Round( nMarza * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr ) ) // ruc
            ENDIF
         ENDIF

         nU6 := Round( TARIFA->VPP / 100 / ( 1 + tarifa->vpp / 100 ) * iif( nMarza < 0, 0, nMarza ) * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr )
         // nU6 = pruc

         // franex 20.11.200 nasteliti ruc + pruc = bruto marza !!
         IF Round( nMarza * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr ) > 0 // pozitivna marza
            nU5 :=  Round( nMarza * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr )  - nU6
            // bruto marza               - porez na ruc
         ENDIF
         nU7 := nU5 + nU6      // ruc+pruc

         nTot5 += nU5
         nTot6 += nU6
         nTot7 += nU7

      ENDIF

      nTot8 +=  ( nU8 := Round( ( VPC - nVPCIzbij ) * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr ) )
      nTot9 +=  ( nU9 := Round( RABATV / 100 * VPC * Kolicina * iif( idvd = "15", -1, 1 ), gZaokr ) )

      nTota +=  ( nUa := Round( nU8 - nU9, gZaokr ) )     // vpv sa ukalk rabatom

      IF idvd == "15" // kod 15-ke nema poreza na promet
         nUb := 0
      ELSE
         nUb := Round( nUa * mpc / 100, gZaokr ) // ppp
      ENDIF
      nTotb +=  nUb
      nTotc +=  ( nUc := nUa + nUb )   // vpv+ppp


      IF koncij->naz = "P"
         nTotd +=  ( nUd := Round( fcj * kolicina * iif( idvd = "15", -1, 1 ), gZaokr ) )  // trpa se planska cijena
      ELSE
         nTotd +=  ( nUd := nua + nub + nu6 )   // vpc+pornapr+pornaruc
      ENDIF

      // 1. PRVI RED
      @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
      @ PRow(), 4 SAY  ""
      ?? Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"
      IF lKoristitiBK .AND. !Empty( roba->barkod )
         ?? ", BK: " + roba->barkod
      ENDIF
      @ PRow() + 1, 4 SAY IdRoba
      @ PRow(), PCol() + 1 SAY Kolicina * iif( idvd = "15", -1, 1 )  PICTURE PicKol
      nC1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY NC                          PICTURE PicCDEM
      PRIVATE nNc := 0
      IF nc <> 0
         nNC := nc
      ELSE
         nNC := 99999999
      ENDIF

      @ PRow(), PCol() + 1 SAY ( VPC - nNC ) / nNC * 100               PICTURE PicProc

      @ PRow(), PCol() + 1 SAY VPC - nVPCIzbij       PICTURE PiccDEM
      @ PRow(), PCol() + 1 SAY RABATV              PICTURE PicProc
      @ PRow(), PCol() + 1 SAY VPC * ( 1 -RABATV / 100 ) -nVPCIzbij  PICTURE PiccDEM

      IF roba->tip $ "VKX"
         @ PRow(), PCol() + 1 SAY PadL( "VT-" + Str( tarifa->opp, 5, 2 ) + "%", Len( picproc ) )
      ELSE
         IF idvd = "15"
            @ PRow(), PCol() + 1 SAY 0          PICTURE PicProc
         ELSE
            @ PRow(), PCol() + 1 SAY MPC        PICTURE PicProc
         ENDIF
      ENDIF

      IF roba->tip = "X"  // nafta , kolona VPC SA PP
         @ PRow(), PCol() + 1 SAY VPC PICTURE PicCDEM
      ELSE
         @ PRow(), PCol() + 1 SAY VPC * ( 1 -RabatV / 100 ) * ( 1 + mpc / 100 ) PICTURE PicCDEM
      ENDIF

      // 2. DRUGI RED
      @ PRow() + 1, 4 SAY IdTarifa + roba->tip
      @ PRow(), nC1    SAY nU4  PICT picdem
      @ PRow(), PCol() + 1 SAY nu8 - nU4  PICT picdem
      @ PRow(), PCol() + 1 SAY nu8  PICT picdem
      @ PRow(), PCol() + 1 SAY nU9  PICT picdem
      @ PRow(), PCol() + 1 SAY nUA  PICT picdem
      @ PRow(), PCol() + 1 SAY nub  PICT picdem
      @ PRow(), PCol() + 1 SAY nUC  PICT picdem

      SKIP

   ENDDO

   check_nova_strana( bZagl, oPdf )

   ? m

   @ PRow() + 1, 0        SAY "Ukupno:"
   @ PRow(), nc1      SAY nTot4  PICT picdem
   @ PRow(), PCol() + 1 SAY ntot8 - nTot4  PICT picdem
   @ PRow(), PCol() + 1 SAY ntot8  PICT picdem
   @ PRow(), PCol() + 1 SAY ntot9  PICT picdem
   @ PRow(), PCol() + 1 SAY nTotA  PICT picdem
   @ PRow(), PCol() + 1 SAY nTotB  PICT picdem
   @ PRow(), PCol() + 1 SAY nTotC  PICT picdem

   ? m

   f18_end_print( NIL, xPrintOpt )

   RETURN .T.


STATIC FUNCTION zagl()


   IF cIdvd == "14" .OR. cIdvd == "74"
      ?U "IZLAZ KUPCU PO VELEPRODAJI"
   ELSEIF cIdvd == "15"
      ?U "OBRAČUN VELEPRODAJE"
   ELSE
      ?U "STORNO IZLAZA KUPCU PO VELEPRODAJI"
   ENDIF

   ? "KALK BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, ", Datum:", DatDok


   SELECT PARTN
   HSEEK cIdPartner

   ? "KUPAC:", cIdPartner, "-", PadR( naz, 20 ), Space( 5 ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP

   IF cIdvd == "94"
      SELECT konto
      HSEEK cidkonto2
      ?  "Storno razduzenja KONTA:", cIdKonto, "-", AllTrim( naz )
   ELSE
      SELECT konto
      HSEEK cidkonto2
      ?  "KONTO razduzuje:", kalk_pripr->mkonto, "-", AllTrim( naz )
      IF !Empty( kalk_pripr->Idzaduz2 )
         ?? " Rad.nalog:", kalk_pripr->Idzaduz2
      ENDIF
   ENDIF

   SELECT kalk_pripr
   SELECT koncij
   SEEK Trim( kalk_pripr->mkonto )
   SELECT kalk_pripr

   ? m
   ? "*R * ROBA     * Kolicina *  NABAV.  *  MARZA   * PROD.CIJ *  RABAT    * PROD.CIJ*   PDV    * PROD.CIJ *"
   ? "*BR*          *          *  CJENA   *          *          *           * -RABAT  *          * SA PDV   *"
   ? m

   RETURN .T.