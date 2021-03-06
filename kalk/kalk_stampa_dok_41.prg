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


FUNCTION kalk_stampa_dok_41()

   LOCAL nCol0 := nCol1 := nCol2 := 0
   LOCAL nPom := 0
   LOCAL _line

   PRIVATE nMarza, nMarza2, nPRUC, aPorezi

   nMarza := nMarza2 := nPRUC := 0
   aPorezi := {}

   nStr := 0
   cIdPartner := IdPartner
   cBrFaktP := BrFaktP
   dDatFaktP := DatFaktP

   cIdKonto := IdKonto
   cIdKonto2 := IdKonto2

   P_10CPI

   Naslov4x()

   SELECT kalk_pripr

   _line := _get_line( cIdVd )

   ? _line

   _print_report_header( cIdvd )

   ? _line

   nTot1 := nTot1b := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := 0
   nTot4a := 0
   nTotMPP := 0

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2

   DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cBrDok == field->brdok .AND. cIdVD == field->idvd

/*
      IF field->idpartner + field->brfaktp + field->idkonto + field->idkonto2 <> cIdd
         SET DEVICE TO SCREEN
         Beep( 2 )
         Msg( "Unutar kalkulacije se pojavilo vise dokumenata !", 6 )
         SET DEVICE TO PRINTER
      ENDIF
*/

      // formiraj varijable _....
      Scatter()

      kalk_pozicioniraj_roba_tarifa_by_kalk_fields()


      kalk_marza_realizacija_prodavnica()
      kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()

      set_pdv_array_by_koncij_region_roba_idtarifa_2_3( pkonto, idRoba, @aPorezi, _idtarifa )

      // uracunaj i popust
      // kalk_porezi_maloprodaja_legacy_array( matrica, mp_bez_pdv, mp_sa_pdv, nc )
      aIPor := kalk_porezi_maloprodaja_legacy_array( aPorezi, field->mpc, field->mpcsapp, field->nc )

      nPor1 := aIPor[ 1 ]

      set_pdv_public_vars()

      print_nova_strana( 125, @nStr, 2 )

      // nabavna vrijednost
      nTot3 += ( nU3 := IF( roba->tip = "U", 0, nc ) * field->kolicina )
      // marza
      nTot4 += ( nU4 := nMarza2 * field->kolicina )
      // maloprodajna vrijednost bez popusta
      nTot5 += ( nU5 := ( field->mpc + field->rabatv ) * field->kolicina )
      // porez
      nTot6 += ( nU6 := ( nPor1 ) * field->kolicina )
      // maloprodajna vrijednost sa porezom
      nTot7 += ( nU7 := field->mpcsapp * field->kolicina )
      // maloprodajna vrijednost sa popustom bez poreza
      nTot8 += ( nU8 := ( field->mpc * field->kolicina ) )
      // popust
      nTot9 += ( nU9 := field->rabatv * field->kolicina )
      // mpv sa pdv - popust
      nTotMPP += ( nUMPP := ( field->mpc + nPor1 ) * field->kolicina )

      // ispis kalkulacije
      // ===========================================================

      // 1. red

      @ PRow() + 1, 0 SAY field->rbr PICT "999"
      @ PRow(), 4 SAY  ""

      ?? Trim( Left( roba->naz, 40 ) ), "(", roba->jmj, ")"

      IF roba_barkod_pri_unosu() .AND. !Empty( roba->barkod )
         ?? ", BK: " + roba->barkod
      ENDIF

      // 2. red

      @ PRow() + 1, 4 SAY field->idroba
      @ PRow(), PCol() + 1 SAY field->kolicina PICT pickol

      nCol0 := PCol()

      @ PRow(), nCol0 SAY ""

      IF field->idvd <> "47"

         // nabavna cijena
         IF roba->tip = "U"
            @ PRow(), PCol() + 1 SAY 0 PICT piccdem
         ELSE
            @ PRow(), PCol() + 1 SAY field->nc PICT piccdem
         ENDIF

         // marza
         @ PRow(), nMPos := PCol() + 1 SAY nMarza2 PICT piccdem

      ENDIF


      @ PRow(), PCol() + 1 SAY ( field->mpc + field->rabatv ) PICT PicCDEM// mpc ili prodajna cijena uvecana za rabat

      nCol1 := PCol() + 1


      IF field->idvd <> "47"

         // popust
         @ PRow(), PCol() + 1 SAY field->rabatv PICT PicCDEM

         // mpc sa pdv umanjen za popust
         @ PRow(), PCol() + 1 SAY field->mpc PICT PicCDEM

      ENDIF

      // pdv
      @ PRow(), PCol() + 1 SAY aPorezi[ POR_PPP ] PICT PicProc

      // mpc sa porezom
      @ PRow(), PCol() + 1 SAY ( field->mpc + nPor1 ) PICT PicCDEM

      // mpc sa porezom
      @ PRow(), PCol() + 1 SAY field->mpcsapp PICT PicCDEM


      // 3. red : totali stavke

      // tarifa
      @ PRow() + 1, 4 SAY field->idtarifa
      @ PRow(), nCol0 SAY ""

      IF cIdVd <> "47"

         // ukupna nabavna vrijednost stavke
         IF roba->tip = "U"
            @ PRow(), PCol() + 1 SAY 0 PICT picdem
         ELSE
            @ PRow(), PCol() + 1 SAY ( field->nc * field->kolicina ) PICT picdem
         ENDIF

         // ukupna marza stavke
         @ PRow(), PCol() + 1 SAY ( nMarza2 * field->kolicina ) PICT picdem

      ENDIF

      // ukupna mpv bez poreza ili ukupna prodajna vrijednost
      @ PRow(), PCol() + 1 SAY ( ( field->mpc + field->rabatv ) * field->kolicina ) PICT picdem

      // ukupne vrijednosti mpc sa porezom sa rabatom i sam rabat
      IF cIdVd <> "47"
         @ PRow(), PCol() + 1 SAY ( field->rabatv * field->kolicina ) PICT picdem
         @ PRow(), PCol() + 1 SAY ( field->mpc * field->kolicina ) PICT picdem
      ENDIF

      // ukupni PDV stavke
      @ PRow(), PCol() + 1 SAY ( nPor1 * field->kolicina ) PICT piccdem

      // ukupni PDV stavke
      @ PRow(), PCol() + 1 SAY ( ( nPor1 + field->mpc ) * field->kolicina ) PICT piccdem

      // ukupna maloprodajna vrijednost (sa PDV-om)
      @ PRow(), PCol() + 1 SAY ( field->mpcsapp * field->kolicina ) PICT picdem

      // 4. red

      // marza iskazana u procentu
      IF cIdVd <> "47"
         @ PRow() + 1, nMPos SAY ( nMarza2 / field->nc ) * 100 PICT picproc
      ENDIF

      SKIP 1

   ENDDO

   print_nova_strana( 125, @nStr, 3 )

   ? _line

   @ PRow() + 1, 0 SAY "Ukupno:"
   @ PRow(), nCol0 SAY ""

   IF cIDVD <> "47"

      // nabavna vrijednost
      @ PRow(), PCol() + 1 SAY nTot3 PICT PicDEM
      // marza
      @ PRow(), PCol() + 1 SAY nTot4 PICT PicDEM

   ENDIF

   // prodajna vrijednost
   @ PRow(), PCol() + 1 SAY nTot5 PICT PicDEM



   // popust
   @ PRow(), PCol() + 1 SAY nTot9 PICT PicDEM

   IF cIdVd <> "47"

      // prodajna vrijednost - popust
      @ PRow(), PCol() + 1 SAY nTot8 PICT PicDEM
      // porez
      @ PRow(), PCol() + 1 SAY nTot6 PICT PicDEM

   ENDIF

   // maloprodajna vrijednost sa porezom - popust
   @ PRow(), PCol() + 1 SAY nTotMPP PICT PicDEM

   // maloprodajna vrijednost sa porezom
   @ PRow(), PCol() + 1 SAY nTot7 PICT PicDEM

   ? _line

   print_nova_strana( 125, @nStr, 10 )

   nRec := RecNo()

   // rekapitulacija tarifa PDV
   kalk_stdok_41_rekap_pdv( cIdFirma, cIdVd, cBrDok, @nStr )

   SET ORDER TO TAG "1"
   GO nRec

   RETURN .T.




STATIC FUNCTION _get_line( id_vd )

   LOCAL _line

   _line := "--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
   IF id_vd <> "47"
      _line += " ---------- ---------- ----------"
   ENDIF

   RETURN _line


// --------------------------------------------------
// stampa header-a izvjestaja
// --------------------------------------------------
STATIC FUNCTION _print_report_header( id_vd )

   IF id_vd = "47"
      ? "*R * ROBA     * Kolicina *    MPC   *   PDV %  *   MPC     *"
      ? "*BR*          *          *          *   PDV    *  SA PDV   *"
      ? "*  *          *          *    sum   *    sum   *    sum    *"
   ELSE
      ? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  *  Prod.C  *  Popust  * PC-pop.  *   PDV %  *   MPC    * MPC     *"
      ? "*BR*          *          *   U MP   *         *  Prod.V  *          * PV-pop.  *   PDV    *  SA PDV  * SA PDV  *"
      ? "*  *          *          *   sum    *         *    sum   *          *          *    sum   * - popust *  sum    *"
   ENDIF

   RETURN



// -----------------------------------------------------
// vraca liniju za rekapitulaciju po tarifama
// -----------------------------------------------------
STATIC FUNCTION _get_rekap_line()

   LOCAL _line
   LOCAL nI

   _line := "------ "
   FOR nI := 1 TO 7
      _line += Replicate( "-", 10 ) + " "
   NEXT

   IF glUgost
      _line += " ---------- ----------"
   ENDIF

   RETURN _line


// ---------------------------------------------------
// stampa header rekapitulacije po tarifama
// ---------------------------------------------------
STATIC FUNCTION _print_rekap_header()

   ?  "* Tar *  PDV%    *  Prod.   *  Popust  * Prod.vr. *   PDV   * MPV-Pop. *  MPV    *"
   ?  "*     *          *   vr.    *          * - popust *   PDV   *  sa PDV  * sa PDV  *"

   RETURN .T.


// --------------------------------------------------
// rekapitulacija tarifa na dokumentu
// --------------------------------------------------
FUNCTION kalk_stdok_41_rekap_pdv( cIdFirma, cIdVd, cBrDok, nStr )

   LOCAL nTot1
   LOCAL nTot2
   LOCAL nTot3
   LOCAL nTot4
   LOCAL nTot5
   LOCAL nTotP
   LOCAL aPorezi
   LOCAL _line

   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   SEEK cIdfirma + cIdvd + cBrdok

   _line := _get_rekap_line()
   ? _line
   _print_rekap_header()
   ? _line

   nTot1 := 0
   nTot2 := 0
   nTot2b := 0
   nTot3 := 0
   nTot4 := 0
   nTot5 := 0
   nTot6 := 0
   nTot7 := 0
   nTot8 := 0
   // popust
   nTotP := 0

   aPorezi := {}

   DO WHILE !Eof() .AND. cIdfirma + cIdvd + cBrDok == field->idfirma + field->idvd + field->brdok

      cIdTarifa := field->idtarifa
      nU1 := 0
      nU2 := 0
      nU2b := 0
      nU5 := 0
      nUp := 0

      select_o_tarifa( cIdtarifa )

      set_pdv_array_by_koncij_region_roba_idtarifa_2_3( kalk_pripr->pkonto, kalk_pripr->idroba, @aPorezi, kalk_pripr->idtarifa )

      SELECT kalk_pripr

      fVTV := .F.

      DO WHILE !Eof() .AND. cIdfirma + cIdVd + cBrDok == field->idFirma + field->idVd + field->brDok .AND. field->idTarifa == cIdTarifa

         SELECT roba
         HSEEK kalk_pripr->idroba

         SELECT kalk_pripr

         set_pdv_public_vars()

         set_pdv_array_by_koncij_region_roba_idtarifa_2_3( kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi, kalk_pripr->idtarifa )

         // mpc bez poreza sa uracunatim popustom
         nU1 += field->mpc * field->kolicina

         aIPor := kalk_porezi_maloprodaja_legacy_array( aPorezi, field->mpc, field->mpcsapp, field->nc )

         // PDV

         nU2 += aIPor[ 1 ] * field->kolicina

         // ugostiteljstvo porez na potr
         IF glUgost
            nU2b += aIPor[ 3 ] * field->kolicina
         ENDIF

         nU5 += field->mpcsapp * field->kolicina

         nUP += field->rabatv * field->kolicina

         nTot6 += ( field->mpc - field->nc ) * field->kolicina

         SKIP
      ENDDO

      nTot1 += nU1
      nTot2 += nU2

      IF glUgost
         nTot2b += nU2b
      ENDIF

      nTot5 += nU5
      nTotP += nUP

      // ispisi rekapitulaciju
      // =========================================

      ? cIdtarifa

      @ PRow(), PCol() + 1 SAY aPorezi[ POR_PPP ] PICT picproc

      IF glUgost
         @ PRow(), PCol() + 1 SAY aPorezi[ POR_PP ] PICT picproc
      ENDIF

      nCol1 := PCol()

      // mpv bez pdv
      @ PRow(), nCol1 + 1 SAY nU1 + nUP PICT picdem

      // popust
      @ PRow(), PCol() + 1 SAY nUp PICT picdem

      // mpv - popust
      @ PRow(), PCol() + 1 SAY nU1 PICT picdem

      // PDV
      @ PRow(), PCol() + 1 SAY nU2 PICT picdem

      IF glUgost
         @ PRow(), PCol() + 1 SAY nU2b PICT picdem
      ENDIF

      // mpv
      @ PRow(), PCol() + 1 SAY ( nU1 + nU2 ) PICT picdem

      // mpv sa originalnom cijemo
      @ PRow(), PCol() + 1 SAY nU5 PICT picdem


   ENDDO

   print_nova_strana( 125, @nStr, 4 )

   ? _line

   ? "UKUPNO"

   // prodajna vrijednost bez popusta
   @ PRow(), nCol1 + 1 SAY ( nTot1 + nTotP ) PICT picdem

   // popust
   @ PRow(), PCol() + 1 SAY nTotP PICT picdem


   // prodajna vrijednost - popust
   @ PRow(), PCol() + 1 SAY nTot1 PICT picdem

   // pdv
   @ PRow(), PCol() + 1 SAY nTot2 PICT picdem

   // mpv sa uracunatim popustom
   @ PRow(), PCol() + 1 SAY ( nTot1 + nTot2 ) PICT picdem

   // mpv
   @ PRow(), PCol() + 1 SAY nTot5 PICT picdem


   ? _line

   IF cIdVd <> "47"
      ? "        UKUPNA RUC:"
      @ PRow(), PCol() + 1 SAY nTot6 PICT picdem
      ? "UKUPNO POPUST U MP:"
      @ PRow(), PCol() + 1 SAY nTot5 - ( nTot1 + nTot2 ) PICT picdem
      ? _line
   ENDIF

   RETURN .T.


FUNCTION Naslov4x()

   LOCAL cSvediDatFakt

   B_ON

   IF CIDVD == "41"
      ?? "IZLAZ IZ PRODAVNICE - KUPAC"
   ELSEIF CIDVD == "49"
      ?? "IZLAZ IZ PRODAVNICE PO OSTALIM OSNOVAMA"
   ELSEIF cIdVd == "43"
      ?? "IZLAZ IZ PRODAVNICE - KOMISIONA - PARAGON BLOK"
   ELSEIF cIdVd == "47"
      ?? "PREGLED PRODAJE"
   ELSE
      ?? "IZLAZ IZ PRODAVNICE - PARAGON BLOK"
   ENDIF

   B_OFF

   P_COND

   ?

   ?? "KALK BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), P_TipDok( cIdVD, -2 ), Space( 2 ), "Datum:", DatDok
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   select_o_partner( cIdPartner )

   IF cIdVd == "41"
      ?  "KUPAC:", cIdPartner, "-", PadR( naz, 20 ), Space( 5 ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP
   ELSEIF cidvd == "43"
      ?  "DOBAVLJAC KOMIS.ROBE:", cIdPartner, "-", PadR( naz, 20 )
   ENDIF

   select_o_konto( cIdKonto )
   ?  "Prodavnicki konto razduzuje:", cIdKonto, "-", PadR( naz, 60 )

   RETURN NIL
