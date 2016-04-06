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


FUNCTION kalk_stdok_95() // stampa kalkulacije tip-a 95, 96, 97

   LOCAL cKto1
   LOCAL cKto2
   LOCAL cIdZaduz2
   LOCAL cPom
   LOCAL _naslov
   LOCAL nCol1 := nCol2 := 0, nPom := 0
   LOCAL _page_len := RPT_PAGE_LEN
   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

   nStr := 0
   cIdPartner := field->IdPartner
   cBrFaktP := field->BrFaktP
   dDatFaktP := field->DatFaktP
   cIdKonto := field->IdKonto
   cIdKonto2 := field->IdKonto2
   cIdZaduz2 := field->IdZaduz2

   P_12CPI

   ?? "KALK BR:", cIdFirma + "-" + cIdVD + "-" + AllTrim( cBrDok ), "  Datum:", field->datdok

   @ PRow(), 76 SAY "Str:" + Str( ++nStr, 3 )

   // ispis naslov dokumenta
   _naslov := _get_naslov_dokumenta( cIdVd )

   ?
   ? _naslov
   ?

   IF cIdVd $ "95#96#97"
      cPom := "Razduzuje:"
      cKto1 := cIdKonto2
      cKto2 := cIdKonto
   ELSE
      cPom := "Zaduzuje:"
      cKto1 := cIdKonto
      cKto2 := cIdKonto2
   ENDIF

   SELECT konto
   hseek cKto1

   ? PadL( cPom, 14 ), AllTrim( cKto1 ) + " - " + PadR( konto->naz, 60 )

   IF !Empty( cKto2 )

      IF cIdVd $ "95#96#97"
         cPom := "Zaduzuje:"
      ELSE
         cPom := "Razduzuje:"
      ENDIF

      SELECT konto
      hseek cKto2

      ? PadL( cPom, 14 ), AllTrim( cKto2 ) + " - " + PadR( konto->naz, 60 )

   ENDIF

   IF !Empty( cIdZaduz2 )

      SELECT ( F_FAKT_OBJEKTI )
      IF !Used()
         O_FAKT_OBJEKTI
      ENDIF

      GO TOP
      hseek cIdZaduz2

      ? PadL( "Rad.nalog:", 14 ), AllTrim( cIdZaduz2 ) + " - " + AllTrim( fakt_objekti->naz )

   ENDIF

   ?

   SELECT kalk_pripr

   P_10CPI
   P_COND

   m := _get_line()

   ? m
   ?U "*Rbr.* Konto * ARTIKAL  (šifra-naziv-jmj)                                 * Količina *   NC     *    NV     *"
   ? m

   nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTota := nTotb := nTotc := nTotd := 0

   PRIVATE cIdd := field->idpartner + field->brfaktp + field->idkonto + field->idkonto2

   DO WHILE !Eof() .AND. cIdFirma == field->IdFirma ;
         .AND. cBrDok == field->BrDok ;
         .AND. cIdVD == field->IdVD

      nT4 := nT5 := nT8 := 0
      cBrFaktP := field->brfaktp
      dDatFaktP := field->datfaktp
      cIdpartner := field->idpartner

      SELECT ( F_PARTN )
      IF !Used()
         O_PARTN
      ENDIF
      SELECT partn
      hseek cIdPartner

      // vrni se na kalk
      SELECT kalk_pripr

      DO WHILE !Eof() .AND. cIdFirma == field->IdFirma ;
            .AND. cBrDok == field->BrDok ;
            .AND. cIdVD == field->IdVD ;
            .AND. field->idpartner + field->brfaktp + DToS( field->datfaktp ) == cIdpartner + cBrfaktp + DToS( dDatfaktp )

         IF cIdVd $ "97" .AND. field->tbanktr == "X"
            SKIP 1
            LOOP
         ENDIF

         SELECT roba
         hseek kalk_pripr->idroba

         SELECT tarifa
         hseek kalk_pripr->idtarifa

         SELECT kalk_pripr

         KTroskovi()

         print_nova_strana( 125, @nStr, 5 )

         skol := field->kolicina

         // NV
         nT4 += ( nU4 := field->nc * field->kolicina )

         @ PRow() + 1, 0 SAY field->rbr PICT "99999"

         IF field->idvd == "16"
            cNKonto := field->idkonto
         ELSE
            cNKonto := field->idkonto2
         ENDIF

         @ PRow(), 6 SAY ""

         ?? PadR( cNKonto, 7 ), PadR( AllTrim( field->idroba ) + "-" + ;
            AllTrim( roba->naz ) + " (" + AllTrim( roba->jmj ) + ")", 60 )

         @ PRow(), nC1 := PCol() + 1 SAY field->kolicina PICT PicKol
         @ PRow(), PCol() + 1 SAY field->nc PICT piccdem
         @ PRow(), PCol() + 1 SAY nU4 PICT picdem

         SKIP

      ENDDO

      nTot4 += nT4
      nTot5 += nT5
      nTot8 += nT8

      ? m

      print_nova_strana( 125, @nStr, 5 )

      @ PRow() + 1, 0 SAY "Ukupno za: "
      ?? AllTrim( cIdpartner ) +  " - " + AllTrim( partn->naz )

      print_nova_strana( 125, @nStr, 5 )

      ? "Broj fakture:", AllTrim( cBrFaktP ), "/", dDatFaktp
      @ PRow(), nC1 SAY 0 PICT "@Z " + picdem
      @ PRow(), PCol() + 1 SAY nT4 PICT picdem

      ? m

   ENDDO

   print_nova_strana( 125, @nStr, 5 )

   ? m

   @ PRow() + 1, 0 SAY "Ukupno:"
   @ PRow(), nC1 SAY 0 PICT "@Z " + picdem
   @ PRow(), PCol() + 1 SAY nTot4 PICT picdem

   ? m

   RETURN .T.




STATIC FUNCTION _get_naslov_dokumenta( id_vd )

   LOCAL _ret := "????"

   IF id_vd == "16"
      _ret := "PRIJEM U MAGACIN (INTERNI DOKUMENT):"
   ELSEIF id_vd == "96"
      _ret := "OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
   ELSEIF id_vd == "97"
      _ret := "PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
   ELSEIF id_vd == "95"
      _ret := "OTPIS MAGACIN:"
   ENDIF

   RETURN _ret


STATIC FUNCTION _get_line()

   LOCAL _line := ""

   _line += Replicate( "-", 5 )
   _line += Space( 1 )
   _line += Replicate( "-", 7 )
   _line += Space( 1 )
   _line += Replicate( "-", 60 )
   _line += Space( 1 )
   _line += Replicate( "-", 10 )
   _line += Space( 1 )
   _line += Replicate( "-", 10 )
   _line += Space( 1 )
   _line += Replicate( "-", 11 )

   RETURN _line
