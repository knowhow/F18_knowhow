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


// ------------------------------------------------
// stampa kalkulacije tipa "IM"
// ------------------------------------------------
FUNCTION kalk_stampa_dok_im()

   LOCAL nCol1 := 0
   LOCAL nCol2 := 0
   LOCAL nPom := 0

   PRIVATE nPrevoz
   PRIVATE nCarDaz
   PRIVATE nZavTr
   PRIVATE nBankTr
   PRIVATE nSpedTr
   PRIVATE nMarza
   PRIVATE nMarza2

   // iznosi troskova i marzi koji se izracunavaju u kalk_unos_troskovi()

   nStr := 0
   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP
   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2

   cSamoObrazac := Pitanje(, "Prikaz samo obrasca inventure? (D/N)" )

   cPrikazCijene := "D"

   IF cSamoObrazac == "D"
      cPrikazCijene := Pitanje(, "Prikazati cijenu na obrascu? (D/N)" )
   ENDIF

   cCijenaTip := Pitanje(, "Na obrascu prikazati VPC (D) ili NC (N)?", "N" )

   P_10CPI
   SELECT konto
   HSEEK cIdkonto
   SELECT kalk_pripr
   ?? "INVENTURA MAGACIN ", cidkonto, "-", konto->naz
   P_COND2
   ?
   ? "DOKUMENT BR. :", cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), "Datum:", DatDok
   ?
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )


   SELECT kalk_pripr
   m := "--- --------------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -----------"
   ? m
   ?  "*R * ROBA                                  *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika *  Cijena  *   VISAK  *  MANJAK  *"
   ?  "*BR* TARIFA                                *  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *          *          *          *"
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

   PRIVATE cIdd := idPartner + brFaktP + idKonto + idKonto2

   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVd

      kalk_unos_troskovi()
      RptSeekRT()
      print_nova_strana( 125, @nStr, 3 )
      SKol := Kolicina

      IF cCijenaTIP == "N"
         nCijena := field->nc
      ELSE
         nCijena := field->vpc
      ENDIF

      @ PRow() + 1, 0 SAY  Rbr PICTURE "XXX"
      @ PRow(), 4 SAY  ""
      ?? idroba, Trim( Left( ROBA->naz, 40 ) ), "(", ROBA->jmj, ")"

      IF lKoristitiBK .AND. !Empty( roba->barkod )
         ?? ", BK: " + ROBA->barkod
      ENDIF

      @ PRow() + 1, 4 SAY IdTarifa + Space( 4 )
      IF cSamoObrazac == "D"
         @ PRow(), PCol() + 30 SAY Kolicina  PICTURE Replicate( "_", Len( PicKol ) )
         @ PRow(), PCol() + 1 SAY GKolicina  PICTURE Replicate( " ", Len( PicKol ) )
      ELSE
         @ PRow(), PCol() + 30 SAY Kolicina  PICTURE PicKol
         @ PRow(), PCol() + 1 SAY GKolicina  PICTURE PicKol
      ENDIF
      nC1 := PCol() + 1

      IF cSamoObrazac == "D"
         @ PRow(), PCol() + 1 SAY gkolicina * nCijena  PICTURE Replicate( " ", Len( PicDEM ) )
         @ PRow(), PCol() + 1 SAY kolicina * nCijena   PICTURE Replicate( "_", Len( PicDEM ) )
         @ PRow(), PCol() + 1 SAY Kolicina - GKolicina  PICTURE Replicate( " ", Len( PicKol ) )
      ELSE
         @ PRow(), PCol() + 1 SAY gkolicina * nCijena PICTURE Picdem // knjizna vrijednost
         @ PRow(), PCol() + 1 SAY kolicina * nCijena  PICTURE Picdem // popisana vrijednost
         @ PRow(), PCol() + 1 SAY Kolicina - GKolicina  PICTURE PicKol // visak-manjak
      ENDIF
      IF ( cPrikazCijene == "D" )
         @ PRow(), PCol() + 1 SAY nCijena  PICTURE PicCDEM // veleprodajna cij
      ELSE
         @ PRow(), PCol() + 1 SAY nCijena  PICTURE Replicate( " ", Len( PicDEM ) )
      ENDIF

      nTotb += gkolicina * nCijena
      nTotc += kolicina * nCijena

      nU4 := nCijena * ( Kolicina - gKolicina )
      nTot4 += nU4

      nTotKol += kolicina
      nTotGKol += gkolicina

      IF cSamoObrazac == "D"
         @ PRow(), PCol() + 1 SAY nU4  PICT Replicate( " ", Len( PicDEM ) )
      ELSE
         @ PRow(), PCol() + 1 SAY nU4 PICT IF( nU4 > 0, picdem, Replicate( " ", Len( PicDEM ) ) )
         @ PRow(), PCol() + 1 SAY IF( nU4 < 0, -nU4, nU4 ) PICT IF( nU4 < 0, picdem, Replicate( " ", Len( PicDEM ) ) )
      ENDIF

      SKIP

   ENDDO

   print_nova_strana( 125, @nStr, 5 )

   IF cSamoObrazac == "D"
      PrnClanoviKomisije()
      RETURN
   ENDIF

   ? m
   @ PRow() + 1, 0 SAY "Ukupno:"
   @ PRow(), ( PCol() * 6 ) + 2 SAY nTotKol PICT gPicKol
   @ PRow(), PCol() + 1 SAY nTotGKol PICT gPicKol
   @ PRow(), PCol() + 1 SAY nTotb PICT gPicDem
   @ PRow(), PCol() + 1 SAY nTotc PICT gPicDem
   @ PRow(), PCol() + 1 SAY 0 PICT gPicDem
   @ PRow(), PCol() + 1 SAY 0 PICT gPicDem
   @ PRow(), PCol() + 1 SAY nTot4 PICT IF( nTot4 > 0, gPicDem, Replicate( " ", Len( PicDEM ) ) )
   @ PRow(), PCol() + 1 SAY IF( nTot4 < 0, -nTot4, nTot4 )  PICT IF( nTot4 < 0, gPicDem, Replicate( " ", Len( gPicDem ) ) )

   ? m

   RETURN
