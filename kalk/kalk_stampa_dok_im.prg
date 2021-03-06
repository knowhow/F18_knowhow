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

MEMVAR m

FUNCTION kalk_stampa_dok_im()

   LOCAL nCol1 := 0
   LOCAL nCol2 := 0
   LOCAL nPom := 0

   LOCAL nTotalVisak, nTotalManjak, nU4
   LOCAL nTot5 := 0
   LOCAL nTot6 := 0
   LOCAL nTot7 := 0
   LOCAL nTot8 := 0
   LOCAL nTot9 := 0
   LOCAL nTota := 0
   LOCAL nTotb := 0
   LOCAL nTotc := 0
   LOCAL nTotd := 0
   LOCAL nTotKol := 0
   LOCAL nTotGKol := 0
   LOCAL nStr
   LOCAL cIdPartner
   LOCAL cBrFaktP
   LOCAL dDatFaktP
   LOCAL cIdKonto
   LOCAL cIdKonto2
   LOCAL cSamoObrazac, cPrikazCijene, cCijenaTip, nCijena, nC1, nColTotal

   PRIVATE nPrevoz
   PRIVATE nCarDaz
   PRIVATE nZavTr
   PRIVATE nBankTr
   PRIVATE nSpedTr
   PRIVATE nMarza
   PRIVATE nMarza2

   // iznosi troskova i marzi koji se izracunavaju u kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()

   nStr := 0
   cIdPartner := kalk_pripr->IdPartner
   cBrFaktP   := kalk_pripr->BrFaktP
   dDatFaktP  := kalk_pripr->DatFaktP
   cIdKonto   := kalk_pripr->IdKonto
   cIdKonto2  := kalk_pripr->IdKonto2

   cSamoObrazac := Pitanje(, "Prikaz samo obrasca inventure? (D/N)" )

   cPrikazCijene := "D"

   IF cSamoObrazac == "D"
      cPrikazCijene := Pitanje(, "Prikazati cijenu na obrascu? (D/N)" )
   ENDIF

   cCijenaTip := Pitanje(, "Na obrascu prikazati VPC (D) ili NC (N)?", "N" )

   P_10CPI
   select_o_konto( cIdkonto )
   SELECT kalk_pripr
   ?? "INVENTURA MAGACIN ", cIdkonto, "-", konto->naz
   P_COND2
   ?
   ? "DOKUMENT BR. :", cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), "Datum:", kalk_pripr->DatDok
   ?
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )


   SELECT kalk_pripr
   m := "--- --------------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -----------"
   ?U m
   ?U  "*R * ROBA                                  *  Popisana*  Knjižna *  Knjižna * Popisana *  Razlika *  Cijena  *   VIŠAK  *  MANJAK  *"
   ?U  "*BR* TARIFA                                *  Kolicina*  Količina*vrijednost*vrijednost*  (kol)   *          *          *          *"
   ?U m

   nTotalVisak := 0
   nTotalManjak := 0

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

      kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()
      kalk_pozicioniraj_roba_tarifa_by_kalk_fields()
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

      IF roba_barkod_pri_unosu() .AND. !Empty( roba->barkod )
         ?? ", BK: " + ROBA->barkod
      ENDIF

      @ PRow() + 1, 4 SAY IdTarifa + Space( 4 )
      IF cSamoObrazac == "D"
         @ PRow(), PCol() + 30 SAY Kolicina  PICTURE Replicate( "_", Len( kalk_pic_kolicina_bilo_gpickol() ) )
         @ PRow(), PCol() + 1 SAY GKolicina  PICTURE Replicate( " ", Len( kalk_pic_kolicina_bilo_gpickol() ) )
      ELSE
         @ PRow(), PCol() + 30 SAY Kolicina  PICTURE kalk_pic_kolicina_bilo_gpickol()
         @ PRow(), PCol() + 1 SAY GKolicina  PICTURE kalk_pic_kolicina_bilo_gpickol()
      ENDIF
      nC1 := PCol() + 1

      IF cSamoObrazac == "D"
         @ PRow(), PCol() + 1 SAY gkolicina * nCijena  PICTURE Replicate( " ", Len( kalk_pic_iznos_bilo_gpicdem() ) )
         @ PRow(), PCol() + 1 SAY kolicina * nCijena   PICTURE Replicate( "_", Len( kalk_pic_iznos_bilo_gpicdem() ) )
         @ PRow(), PCol() + 1 SAY Kolicina - GKolicina  PICTURE Replicate( " ", Len( kalk_pic_kolicina_bilo_gpickol() ) )
      ELSE
         @ PRow(), PCol() + 1 SAY gkolicina * nCijena PICTURE kalk_pic_iznos_bilo_gpicdem() // knjizna vrijednost
         @ PRow(), PCol() + 1 SAY kolicina * nCijena  PICTURE kalk_pic_iznos_bilo_gpicdem() // popisana vrijednost
         @ PRow(), PCol() + 1 SAY Kolicina - GKolicina  PICTURE kalk_pic_kolicina_bilo_gpickol() // visak-manjak
      ENDIF
      IF ( cPrikazCijene == "D" )
         @ PRow(), PCol() + 1 SAY nCijena  PICTURE PicCDEM // veleprodajna cij
      ELSE
         @ PRow(), PCol() + 1 SAY nCijena  PICTURE Replicate( " ", Len( kalk_pic_iznos_bilo_gpicdem() ) )
      ENDIF

      nTotb += kalk_pripr->gkolicina * nCijena
      nTotc += kalk_pripr->kolicina * nCijena

      nU4 := nCijena * ( kalk_pripr->Kolicina - kalk_pripr->gKolicina )

      IF nU4 > 0 // popisana - knjizna > 0 - visak
         nTotalVisak += nU4
      ELSE
         nTotalManjak += -nU4
      ENDIF

      nTotKol += kalk_pripr->kolicina
      nTotGKol += kalk_pripr->gkolicina

      IF cSamoObrazac == "D"
         @ PRow(), PCol() + 1 SAY nU4  PICT Replicate( " ", Len( kalk_pic_iznos_bilo_gpicdem() ) )
      ELSE
         @ PRow(), PCol() + 1 SAY nU4 PICT iif( nU4 > 0, kalk_pic_iznos_bilo_gpicdem(), Replicate( " ", Len( kalk_pic_iznos_bilo_gpicdem() ) ) )
         @ PRow(), PCol() + 1 SAY iif( nU4 < 0, - nU4, nU4 ) PICT iif( nU4 < 0, kalk_pic_iznos_bilo_gpicdem(), Replicate( " ", Len( kalk_pic_iznos_bilo_gpicdem() ) ) )
      ENDIF

      SKIP

   ENDDO

   print_nova_strana( 125, @nStr, 5 )

   IF cSamoObrazac == "D"
      PrnClanoviKomisije()
      RETURN .F.
   ENDIF

   ? m
   @ PRow() + 1, 0 SAY "Ukupno:"
   @ PRow(), ( PCol() * 6 ) + 2 SAY nTotKol PICT kalk_pic_kolicina_bilo_gpickol()
   @ PRow(), PCol() + 1 SAY nTotGKol PICT kalk_pic_kolicina_bilo_gpickol()
   @ PRow(), PCol() + 1 SAY nTotb PICT kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY nTotc PICT kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY Space( Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY Space( Len( kalk_pic_iznos_bilo_gpicdem() ) )
   nColTotal := PCol() + 1

   IF nTotalVisak > 0
      @ PRow(), nColTotal SAY nTotalVisak PICT kalk_pic_iznos_bilo_gpicdem()
   ELSE
      @ PRow(), nColTotal SAY Space( Len( kalk_pic_iznos_bilo_gpicdem() ) )
   ENDIF
   IF nTotalManjak > 0
      @ PRow(), PCol() + 1 SAY nTotalManjak PICT kalk_pic_iznos_bilo_gpicdem()
   ELSE
      @ PRow(), PCol() + 1 SAY Space( Len( kalk_pic_iznos_bilo_gpicdem() ) )
   ENDIF

   ?
   IF nTotalVisak - nTotalManjak > 0
      @ PRow(), nColTotal SAY nTotalVisak - nTotalManjak PICT kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY Space( Len( kalk_pic_iznos_bilo_gpicdem() ) )
   ELSE
      @ PRow(), nColTotal SAY Space( Len( kalk_pic_iznos_bilo_gpicdem() ) )
      @ PRow(), PCol() + 1 SAY - nTotalVisak + nTotalManjak PICT kalk_pic_iznos_bilo_gpicdem()
   ENDIF


   ? m

   RETURN .T.
