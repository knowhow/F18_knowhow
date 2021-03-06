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


FUNCTION kalk_stampa_dok_ip( fZaTops )

   LOCAL nCol1 := nCol2 := 0
   LOCAL nPom := 0

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2, aPorezi

   // iznosi troskova i marzi koji se izracunavaju u kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()

   aPorezi := {}
   nStr := 0
   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP
   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2

   IF fzatops == NIL
      fZaTops := .F.
   ENDIF

   IF !fZaTops
      cSamoObraz := Pitanje(, "Prikaz samo obrasca inventure (D-da,N-ne,S-sank lista) ?",, "DNS" )
      IF cSamoObraz == "S"
         stampa_obrasca_inventure_sank_lista()
         RETURN
      ENDIF
   ELSE
      cSamoObraz := "N"
   ENDIF

   P_10CPI
   select_o_konto( cIdkonto )
   SELECT kalk_pripr

   ?? "INVENTURA PRODAVNICA ", cIdkonto, "-", AllTrim( konto->naz )

   IspisNaDan( 10 )

   P_COND

   ?
   ? "DOKUMENT BR. :", cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), "Datum:", DatDok
   ?
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   SELECT kalk_pripr

   m := "--- --------------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

   ? m
   ? "*R * ROBA                                  *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika * Cijena  *  +VISAK  * -MANJAK  *"
   ? "*BR* TARIFA                                *  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *         *          *          *"
   ? m

   nTot4 := 0
   nTot5 := 0
   nTot6 := 0
   nTot7 := 0
   nTot8 := 0
   nTot9 := 0
   nTota := 0
   nTotb := 0
   nTotc := 0
   nTotd := 0
   nTotKol := 0
   nTotGKol := 0


   nTotVisak := 0
   nTotManjak := 0

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

/*
      IF idpartner + brfaktp + idkonto + idkonto2 <> cIdd
         Beep( 2 )
         Msg( "Unutar kalkulacije se pojavilo vise dokumenata !", 6 )
      ENDIF
*/
      kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()

      select_o_roba(  kalk_pripr->IdRoba )
      select_o_tarifa( kalk_pripr->IdTarifa )

      SELECT kalk_pripr

      IF ( PRow() - dodatni_redovi_po_stranici() ) > 59
         FF
         @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
      ENDIF

      SKol := Kolicina

      @ PRow() + 1, 0 SAY field->rbr PICT "XXX"
      @ PRow(), 4 SAY  ""

      ?? field->idroba, Trim( Left( roba->naz, 40 ) ), "(", roba->jmj, ")"

      IF roba_barkod_pri_unosu() .AND. !Empty( roba->barkod )
         ?? ", BK: " + roba->barkod
      ENDIF

      nPosKol := 30
      @ PRow() + 1, 4 SAY field->idtarifa + Space( 4 )

      IF cSamoObraz == "D"
         @ PRow(), PCol() + nPosKol SAY field->kolicina PICT Replicate( "_", Len( PicKol ) )
         @ PRow(), PCol() + 1 SAY field->gkolicina PICT Replicate( " ", Len( PicKol ) )
      ELSE
         @ PRow(), PCol() + nPosKol SAY field->kolicina PICT PicKol
         @ PRow(), PCol() + 1 SAY field->gkolicina PICT PicKol
      ENDIF

      nC1 := PCol()

      IF cSamoObraz == "D"
         @ PRow(), PCol() + 1 SAY field->fcj PICT Replicate( " ", Len( PicDEM ) )
         @ PRow(), PCol() + 1 SAY field->kolicina * field->mpcsapp PICT Replicate( "_", Len( PicDEM ) )
         @ PRow(), PCol() + 1 SAY field->Kolicina - field->gkolicina PICT Replicate( " ", Len( PicKol ) )
      ELSE
         @ PRow(), PCol() + 1 SAY field->fcj PICT Picdem // knjizna vrijednost
         @ PRow(), PCol() + 1 SAY field->kolicina * field->mpcsapp PICT Picdem
         @ PRow(), PCol() + 1 SAY field->kolicina - field->gkolicina PICT PicKol
      ENDIF

      @ PRow(), PCol() + 1 SAY field->mpcsapp PICT PicCDEM

      nTotb += field->fcj
      nTotc += field->kolicina * field->mpcsapp
      nTot4 += ( nU4 := ( field->MPCSAPP * field->Kolicina ) - field->fcj )
      nTotKol += field->kolicina
      nTotGKol += field->gkolicina

      IF cSamoObraz == "D"
         @ PRow(), PCol() + 1 SAY nU4 PICT Replicate( " ", Len( PicDEM ) )
      ELSE

         IF ( nU4 < 0 )

            // manjak
            @ PRow(), PCol() + 1 SAY 0 PICT picdem
            @ PRow(), PCol() + 1 SAY nU4 PICT picdem
            nTotManjak += nU4
         ELSE

            // visak
            @ PRow(), PCol() + 1 SAY nU4 PICT picdem
            @ PRow(), PCol() + 1 SAY 0 PICT picdem
            nTotVisak += nU4

         ENDIF
      ENDIF

      SKIP 1

   ENDDO


   IF PRow() -dodatni_redovi_po_stranici() > 58
      FF
      @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   ENDIF

   IF cSamoObraz == "D"
      ? m
      ?
      ?
      ? Space( 80 ), "Clanovi komisije: 1. ___________________"
      ? Space( 80 ), "                  2. ___________________"
      ? Space( 80 ), "                  3. ___________________"
      RETURN .T.
   ENDIF

   ? m
   @ PRow() + 1, 0 SAY PadR( "Ukupno:", 43 )
   @ PRow(), PCol() + 1 SAY nTotKol PICT pickol
   @ PRow(), PCol() + 1 SAY nTotGKol PICT pickol
   @ PRow(), PCol() + 1 SAY nTotb PICT picdem
   @ PRow(), PCol() + 1 SAY nTotc PICT picdem
   @ PRow(), PCol() + 1 SAY 0 PICT picdem
   @ PRow(), PCol() + 1 SAY 0 PICT picdem
   @ PRow(), PCol() + 1 SAY nTotVisak PICT picdem
   @ PRow(), PCol() + 1 SAY nTotManjak PICT picdem

   ? m

   ? "Rekapitulacija:"
   ? "---------------"
   ? "  popisana kolicina:", Str( nTotKol, 18, 2 )
   ? "popisana vrijednost:", Str( nTotC, 18, 2 )
   ? "   knjizna kolicina:", Str( nTotGKol, 18, 2 )
   ? " knjizna vrijednost:", Str( nTotB, 18, 2 )
   ? "          + (visak):", Str( nTotVisak, 18, 2 )
   ? "         - (manjak):", Str( nTotManjak, 18, 2 )

   ? m

   // Visak
   kalk_pripr_rekap_tarife( .T. )

   IF !fZaTops
      ?
      ?
      ? "Napomena: Ovaj dokument ima sljedeci efekat na karticama:"
      ? "     1 - izlaz za kolicinu manjka"
      ? "     2 - storno izlaza za kolicinu viska"
      ?
   ENDIF

   RETURN .T.




/* stampa_obrasca_inventure_sank_lista
 *     Stampa forme obrasca sank liste
 */

FUNCTION stampa_obrasca_inventure_sank_lista()

   LOCAL nCol1 := nCol2 := 0, npom := 0

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

   // iznosi troskova i marzi koji se izracunavaju u kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()

   nStr := 0
   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP
   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2


   P_10CPI
   select_o_konto( cIdkonto )
   SELECT kalk_pripr
   ?? "INVENTURA PRODAVNICA ", cidkonto, "-", konto->naz
   P_COND
   ?
   ? "DOKUMENT BR. :", cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), "Datum:", DatDok
   ?
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   SELECT kalk_pripr

   m := "--- -------------------------------------------- ------ ---------- ---------- ---------- --------- ----------- -----------"
   ? m
   ? "*R *                                            *      *  Pocetne * Primljena*  Zavrsna * Prodajna * Cijena  *   Iznos  *"
   ? "*BR*               R O B A                      *Tarifa*  zalihe  *  kolicina*  zaliha  * kolicina *         */realizac.*"
   ? m
   nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTota := ntotb := ntotc := nTotd := 0

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

/*
      IF idpartner + brfaktp + idkonto + idkonto2 <> cidd
         Beep( 2 )
         Msg( "Unutar kalkulacije se pojavilo vise dokumenata !", 6 )
      ENDIF
*/
      kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()

      select_o_roba( kalk_pripr->IdRoba )
      select_o_tarifa( kalk_pripr->IdTarifa )
      SELECT kalk_pripr

      IF PRow() -dodatni_redovi_po_stranici() > 59
         FF
         @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
      ENDIF

      SKol := Kolicina

      @ PRow() + 1, 0 SAY  Rbr PICTURE "XXX"
      @ PRow(), 4 SAY  ""
      ?? idroba, Left( ROBA->naz, 40 - 13 ), "(" + ROBA->jmj + ")"
      nPosKol := 1
      @ PRow(), PCol() + 1 SAY IdTarifa
      //IF gcSLObrazac == "2"
         @ PRow(), PCol() + nPosKol SAY Kolicina  PICTURE PicKol
      //ELSE
      //   @ PRow(), PCol() + nPosKol SAY GKolicina  PICTURE PicKol
      //ENDIF
      @ PRow(), PCol() + 1 SAY 0  PICTURE Replicate( "_", Len( PicKol ) )
      @ PRow(), PCol() + 1 SAY 0  PICTURE Replicate( "_", Len( PicKol ) )
      @ PRow(), PCol() + 1 SAY 0  PICTURE Replicate( "_", Len( PicKol ) )
      @ PRow(), PCol() + 1 SAY MPCSAPP             PICTURE PicCDEM
      nTotb += fcj
      ntotc += kolicina * mpcsapp
      nTot4 +=  ( nU4 := MPCSAPP * Kolicina - fcj )

      @ PRow(), PCol() + 1 SAY nU4  PICT Replicate( "_", Len( PicDEM ) )
      SKIP

   ENDDO


   IF PRow() - dodatni_redovi_po_stranici() > 58
      FF
      @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   ENDIF

   ? m

   RETURN
