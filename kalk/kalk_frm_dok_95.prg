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



FUNCTION Get1_95()

   // izgenerisane stavke jos ne postoje
   pIzgSt := .F.


   SET KEY K_ALT_K TO KM2()
   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1 .OR. !fnovi .OR. gMagacin == "1"
      @  m_x + 5, m_y + 2   SAY "Dokument Broj:" GET _BrFaktP
      @  m_x + 5, Col() + 1 SAY "Datum:" GET _DatFaktP   ;
         valid {|| .T. }

      _IdZaduz := ""
      @ m_x + 8, m_y + 2 SAY8 "Magacinski konto razdužuje"  GET _IdKonto2 ;
         VALID Empty( _IdKonto2 ) .OR. P_Konto( @_IdKonto2, 21, 5 )
      IF gNW <> "X"
         @ m_x + 8, m_y + 40 SAY "Razdužuje:" GET _IdZaduz2   PICT "@!"  VALID Empty( _idZaduz2 ) .OR. P_Firma( @_IdZaduz2, 21, 5 )
      ELSE
         IF !Empty( cRNT1 ) .AND. _idvd $ "97#96#95"
            IF ( IsRamaGlas() )
               @ m_x + 8, m_y + 40 SAY "Rad.nalog:" GET _IdZaduz2 PICT "@!" VALID RadNalOK()
            ELSE
               @ m_x + 8, m_y + 40 SAY "Rad.nalog:" GET _IdZaduz2   PICT "@!"
            ENDIF
         ENDIF
      ENDIF
      IF _idvd $ "97#96#95"    // ako je otprema, gdje to ide

         @ m_x + 9, m_y + 2   SAY "Konto zaduzuje            " GET _IdKonto VALID  Empty( _IdKonto ) .OR. P_Konto( @_IdKonto, 21, 5 ) PICT "@!"

         IF ( _idvd == "95" .AND. IsVindija() )

            @ m_x + 9, m_y + 40 SAY "Šifra veze otpisa:" GET _IdPartner  VALID Empty( _idPartner ) .OR. P_Firma( @_IdPartner, 21, 5 ) PICT "@!"

         ELSEIF gMagacin == "1"
            @ m_x + 9, m_y + 40 SAY8 "Partner zadužuje:" GET _IdPartner  VALID Empty( _idPartner ) .OR. P_Firma( @_IdPartner, 21, 5 ) PICT "@!"

         ELSE
            IF _idvd == "96"
               @ m_x + 9, m_y + 40 SAY8 "Partner zadužuje:" GET _IdPartner  VALID Empty( _idPartner ) .OR. P_Firma( @_IdPartner, 21, 5 ) PICT "@!"
            ENDIF
         ENDIF

      ELSE
         _idkonto := ""
      ENDIF

   ELSE
      @  m_x + 6, m_y + 2   SAY "Dokument Broj: "; ?? _BrFaktP
      @  m_x + 6, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      _IdZaduz := ""
      @ m_x + 8, m_y + 2 SAY "Magacinski konto razduzuje "; ?? _IdKonto2
      @ m_x + 9, m_y + 2 SAY "Konto zaduzuje "; ?? _IdKonto
      IF gNW <> "X"
         @ m_x + 9, m_y + 40 SAY "Razduzuje: "; ?? _IdZaduz2
      ENDIF
   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.brÄ¿"

   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _idRoba := PadR( _idRoba, Val( gDuzSifIni ) ), .T. } valid  {|| P_Roba( @_IdRoba ), Reci( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), Reci( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF
   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   read; ESC_RETURN K_ESC
   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   _MKonto := _Idkonto2
   DatPosljK()
   DuplRoba()

   SELECT koncij
   SEEK Trim( _idkonto2 )
   SELECT TARIFA
   HSEEK _IdTarifa  // postavi TARIFA na pravu poziciju
   SELECT kalk_pripr  // napuni tarifu

   @ m_x + 13, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0


   IF gVarEv == "1"

      _GKolicina := 0
      IF fNovi

         SELECT ROBA; HSEEK _IdRoba
         IF koncij->naz == "P2"
            _VPC := PLC
         ELSE
            _VPC := KoncijVPC()
         ENDIF

         _NC := NC
      ENDIF

      IF gCijene = "2" .AND. fNovi
         // ///// utvrdjivanje fakticke VPC
         faktVPC( @_VPC, _idfirma + _idkonto2 + _idroba )
         SELECT kalk_pripr
      ENDIF

      
      nKolS := 0
      nKolZN := 0
      nc1 := nc2 := 0
      dDatNab := CToD( "" )

      lGenStavke := .F.

      IF _TBankTr <> "X"

         IF !Empty( gMetodaNC )  .AND. !( roba->tip $ "UT" )

               MsgO( "Racunam stanje na skladistu" )
               KalkNab( _idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
               MsgC()

               @ m_x + 12, m_y + 30   SAY "Ukupno na stanju "; @ m_x + 12, Col() + 2 SAY nKols PICT pickol
               @ m_x + 13, m_y + 30   SAY "Srednja nc "; @ m_x + 13, Col() + 2 SAY nc2 PICT pickol

         ENDIF

         IF dDatNab > _DatDok; Beep( 1 ); Msg( "Datum nabavke je " + DToC( dDatNab ), 4 ); ENDIF

         IF !( roba->tip $ "UT" )

            IF gMetodaNC $ "13"
               _nc := nc1
            ELSEIF gMetodaNC == "2"
               _nc := nc2
            ENDIF

            IF gMetodaNc == "2"
               IF _kolicina > 0

                     SELECT roba
                     _rec := dbf_get_rec()
                     _rec[ "nc" ] := _nc
                     update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
                     SELECT kalk_pripr // nafiluj sifrarnik robe sa nc sirovina, robe
                  ENDIF
               ENDIF

           ENDIF
      ENDIF

      SELECT kalk_pripr
         @ m_x + 14, m_y + 2  SAY "NAB.CJ   "  GET _NC  PICTURE gPicNC  VALID V_KolMag()
         PRIVATE _vpcsappp := 0
         IF !IsMagPNab()
            IF _vpc = 0
               _vpc := KoncijVPC()        // MS 19.12.00
            ENDIF
            IF IsPDV()
               @ m_x + 15, m_y + 2   SAY "PROD.CIJ " GET _VPC    PICTURE PicDEM
            ELSE
               @ m_x + 15, m_y + 2   SAY "VPC      " GET _VPC    PICTURE PicDEM
            ENDIF
            _PNAP := 0

            IF gMagacin == "1" .AND. !IsPDV()
               // ovu cijenu samo prikazati ako se vodi po nabavnim cijenama
               _VPCSAPPP := 0
            ENDIF

            IF IsPDV() .AND. gPDVMagNab == "N"

               _mpcsapp := roba->mpc
               // VPC se izracunava pomocu MPC cijene !!
               @ m_x + 17, m_y + 2 SAY "PROD.CJENA SA PDV:"
               @ m_x + 17, Col() + 2 GET _MPCSaPP  PICTURE PicDEM ;
                  valid {|| _mpcsapp := iif( _mpcsapp = 0, Round( _vpc * ( 1 + TARIFA->opp / 100 ), 2 ), _mpcsapp ), _mpc := _mpcsapp / ( 1 + TARIFA->opp / 100 ), iif( _mpc <> 0, _vpc := Round( _mpc, 2 ), _vpc ), ShowGets(), .T. }
               READ
            ELSE
               READ
            ENDIF

         ELSE // magacin po vpc
            READ
            _Marza := 0; _TMarza := "A"; _VPC := _NC
         ENDIF // magacin po nc
   ELSE    // ako je gVarEv=="2" tj. bez cijena
      READ
   ENDIF

   IF !IsPDV()
      _mpcsapp := 0
   ENDIF

   nStrana := 2
   _marza := _vpc - _nc
   _MKonto := _Idkonto2;_MU_I := "5"     // izlaz iz magacina
   _PKonto := ""; _PU_I := ""

   IF pIzgSt  .AND. _kolicina > 0 .AND.  LastKey() <> K_ESC // izgenerisane stavke postoje
      PRIVATE nRRec := RecNo()
      GO TOP
      my_flock()
      DO WHILE !Eof()  // nafiluj izgenerisane stavke
         IF kolicina == 0
            SKIP
            PRIVATE nRRec2 := RecNo()
            SKIP -1
            my_delete()
            GO nRRec2
            LOOP
         ENDIF
         IF brdok == _brdok .AND. idvd == _idvd .AND. Val( Rbr ) == nRbr
            IF IsMagPNab()
               nmarza := 0
               REPLACE vpc WITH kalk_pripr->nc, ;
                  vpcsap WITH  kalk_pripr->nc, ;
                  rabatv WITH  0,;
                  marza WITH  0
            ELSE
               nMarza := _VPC * ( 1 -_RabatV / 100 ) -_NC
               REPLACE vpc WITH _vpc, ;
                  vpcsap WITH _VPC * ( 1 -_RABATV / 100 ) + iif( nMarza < 0, 0, nMarza ) * TARIFA->VPP / 100, ;
                  rabatv WITH _rabatv, ;
                  marza  WITH _vpc - kalk_pripr->nc   // mora se uzeti nc iz ove stavke
            ENDIF
            REPLACE  mkonto WITH _mkonto, ;
               tmarza  WITH _tmarza, ;
               mpc     WITH  _MPC, ;
               mu_i WITH  _mu_i, ;
               pkonto WITH _pkonto, ;
               pu_i WITH  _pu_i,;
               error WITH "0"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
      GO nRRec
   ENDIF

   SET KEY K_ALT_K TO

   RETURN LastKey()



/*! \fn StKalk95()
 *  \brief Stampa kalkulacija tipa 16,95,96,97
 */

FUNCTION StKalk95()

   LOCAL nCol1 := nCol2 := 0
   LOCAL nPom := 0, nLijevo := 8

   PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

   nStr := 0
   cIdPartner := IdPartner; cBrFaktP := BrFaktP; dDatFaktP := DatFaktP

   cIdKonto := IdKonto; cIdKonto2 := IdKonto2

   P_10CPI
   B_ON; I_ON
   ?? Space( nLijevo ), "KALK BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, "  Datum:", DatDok
   B_OFF; I_OFF

   P_COND
   @ PRow() + 1, 125 SAY "Str:" + Str( ++nStr, 3 )

   SELECT PARTN; HSEEK cIdPartner

   IF cidvd == "16"  // doprema robe
      SELECT konto; HSEEK cidkonto
      P_10CPI; B_ON
      ?
      ? Space( nLijevo ), "PRIJEM U MAGACIN"
      ?
      ? Space( nLijevo ), "KONTO zaduzuje:", cIdKonto, "-", naz
      B_OFF
   ELSEIF cidvd $ "96#97"
      P_10CPI; B_ON
      ?
      IF cIdVd == "96"
         ? Space( nLijevo ), "OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
      ELSE
         ? Space( nLijevo ), "PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
      ENDIF
      ?
      IF cidvd $ "96#97"  // otprema iz magacina
         SELECT konto; HSEEK cidkonto2
         ?  Space( nLijevo ), "KONTO razduzuje :", cIdKonto2, "-", naz

         SELECT konto; HSEEK cidkonto
         B_OFF
         ?  Space( nLijevo ), "KONTO zaduzuje  :", cIdKonto, "-", naz
      ENDIF
      B_OFF
   ELSEIF cidvd == "95"
      P_10CPI; B_ON
      ?
      ? Space( nLijevo ), "OTPIS MAGACIN"
      IF ( !Empty( cIdPartner ) .AND. IsVindija() )
         B_OFF
         ?? " -", RTrim( cIdPartner ), "(" + PadR( partn->naz, 20 ) + ")"
         B_ON
      ENDIF
      ?
      SELECT konto; HSEEK cidkonto2
      ? Space( nLijevo ), "KONTO razduzuje:", cIdKonto2, "-", naz
      B_OFF
   ENDIF

   // /?  "PARTNER:",cIdPartner,"-",naz,SPACE(5),

   ? Space( nLijevo ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP

   IF !Empty( kalk_pripr->idzaduz2 )
      B_ON
      ?? "      RAD.NALOG:", kalk_pripr->idzaduz2
      B_OFF
   ENDIF

   P_COND

   SELECT kalk_pripr
   SELECT koncij; SEEK Trim( kalk_pripr->mkonto );SELECT kalk_pripr

   m := "--- ------------------------- ---------- ----------- ----------"
   IF !IsMagPNab()
      m += " ---------- ---------- --------- ---------- ----------"
   ELSE  // nabavne cijene
      nLijevo += 2
      P_10CPI
   ENDIF
   ?
   ?
   ? Space( nLijevo ), m
   ? Space( nLijevo ), "*R * ARTIKAL                 * Kolicina *  NABAV.  *    NV    *"
   IF !IsMagPNab()
      IF koncij->naz == "P1"
         ?? "   MARZA   *  MARZA  *   Iznos  *  Prod.C *  Prod.Vr *"
      ELSEIF koncij->naz == "P2"
         ?? "   MARZA   *  MARZA  *   Iznos  *  Plan.C *  Plan.Vr *"
      ELSE
         ?? "    RUC    *   RUC   *   Iznos  *   VPC   *   VPV    *"
      ENDIF
   ENDIF
   ? Space( nLijevo ), "*BR*                         *          *  CJENA   *          *"
   IF !IsMagPNab()
      IF koncij->naz == "P1"
         ?? "     %     *         *    marze *         *          *"
      ELSE
         ?? "     %     *         *     RUC  *         *          *"
      ENDIF
   ENDIF
   ? Space( nLijevo ), m
   nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTota := ntotb := ntotc := nTotd := 0

   PRIVATE cIdd := idpartner + brfaktp + idkonto + idkonto2
   IF ( !Empty( idkonto2 ) .AND. !Empty( Idkonto ) ) .AND. idvd $ "16"
      cidkont := idkonto
      cIdkont2 := idkonto2
      nProlaza := 2
   ELSE
      cidkont := idkonto
      nProlaza := 1
   ENDIF

   SELECT kalk_pripr
   nC1 := 30
   nRec := RecNo()
   unTot := unTot1 := unTot2 := unTot3 := unTot4 := unTot5 := unTot6 := unTot7 := unTot8 := unTot9 := unTotA := unTotb := 0

   FOR i := 1 TO nprolaza
      nTot := nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTotA := nTotb := 0
      GO nRec
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

         IF cIdVd $ "97" .AND. tbanktr == "X"
            SKIP 1; LOOP
         ENDIF

         IF Empty( cidkonto2 )
/*
            IF idpartner + brfaktp + idkonto + idkonto2 <> cidd
               SET DEVICE TO SCREEN
               Beep( 2 )
               Msg( "Unutar kalkulacije se pojavilo vise dokumenata !", 6 )
               SET DEVICE TO PRINTER
            ENDIF
*/
         ELSE
            IF ( i == 1 .AND. Left( idkonto2, 3 ) <> "XXX" ) .OR. ;
                  ( i == 2 .AND. Left( idkonto2, 3 ) == "XXX" )
               // nastavi
            ELSE
               skip; LOOP
            ENDIF
         ENDIF

         SELECT ROBA; HSEEK kalk_pripr->IdRoba
         SELECT TARIFA; HSEEK kalk_pripr->IdTarifa
         SELECT kalk_pripr
         KTroskovi()

         IF PRow() > ( RPT_PAGE_LEN + gPStranica )
            FF
            @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
         ENDIF

         SKol := Kolicina

         nTot4 +=  ( nU4 := Round( NC * Kolicina, gZaokr ) )  // nv
         nTot5 +=  ( nU5 := Round( nMarza * Kolicina, gZaokr ) ) // ruc
         nTot8 +=  ( nU8 := Round( VPC * Kolicina, gZaokr ) )

         @ PRow() + 1, 1 + nLijevo SAY  Rbr PICTURE "999"
         @ PRow(), 5 + nLijevo SAY  ""; ?? Trim( Left( ROBA->naz, 40 ) ) + "(" + ROBA->jmj + ")"
         IF roba->( FieldPos( "KATBR" ) ) <> 0
            ?? " KATBR:", roba->katbr
         ENDIF
         @ PRow() + 1, 5 + nLijevo SAY IdRoba
         @ PRow(), 31 + nLijevo SAY Kolicina  PICTURE PicKol
         nC1 := PCol() + 1
         @ PRow(), PCol() + 1   SAY NC                          PICTURE PicCDEM
         @ PRow(), PCol() + 1 SAY nU4  PICT picdem
         IF !IsMagPNab()
            @ PRow(), PCol() + 1 SAY IF( NC == 0, 0, nMarza / NC * 100 )    PICTURE PicProc
            @ PRow(), PCol() + 1 SAY nmarza PICT picdem
            @ PRow(), PCol() + 1 SAY nu5   PICT picdem
            @ PRow(), PCol() + 1 SAY VPC                  PICTURE PiccDEM
            @ PRow(), PCol() + 1 SAY nu8  PICT picdem
         ENDIF
         SKIP

      ENDDO

      IF nprolaza == 2
         ? Space( nLijevo ), m
         ? Space( nLijevo ), "Konto "
         IF i == 1
            ?? cidkont
         ELSE
            ?? cidkont2
         ENDIF
         @ PRow(), nc1      SAY 0  PICT "@Z " + picdem
         @ PRow(), PCol() + 1 SAY nTot4  PICT picdem

         IF !IsMagPNab()
            @ PRow(), PCol() + 1 SAY 0  PICT "@Z " + picdem
            @ PRow(), PCol() + 1 SAY 0  PICT "@Z " + picdem
            @ PRow(), PCol() + 1 SAY ntot5  PICT picdem
            @ PRow(), PCol() + 1 SAY 0  PICT "@Z " + picdem
            @ PRow(), PCol() + 1 SAY ntot8  PICT picdem
         ENDIF
         ? Space( nLijevo ), m
      ENDIF
      unTot4 += nTot4
      unTot5 += nTot5
      unTot8 += nTot8
   NEXT

   IF PRow() > ( RPT_PAGE_LEN + gPStranica )
      FF
      @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   ENDIF

   ? Space( nLijevo ), m
   @ PRow() + 1, 1 + nLijevo        SAY "Ukupno:"
   @ PRow(), nc1      SAY 0  PICT "@Z " + picdem
   @ PRow(), PCol() + 1 SAY unTot4  PICT picdem
   IF !IsMagPNab()
      @ PRow(), PCol() + 1 SAY 0  PICT "@Z " + picdem
      @ PRow(), PCol() + 1 SAY 0  PICT "@Z " + picdem
      @ PRow(), PCol() + 1 SAY untot5  PICT picdem
      @ PRow(), PCol() + 1 SAY 0  PICT "@Z " + picdem
      @ PRow(), PCol() + 1 SAY untot8  PICT picdem
   ENDIF
   ? Space( nLijevo ), m

   IF cidvd $ "95#96" .AND. !Empty( cidkonto )
      ?
      P_COND
      ? Space( nLijevo + 10 ), "Napomena: ovaj dokument ima SAMO efekat razduzenja ", cidkonto2
      ? Space( nLijevo + 10 ), "Ako zelite izvrsiti zaduzenje na ", cidkonto, "obradite odgovarajuci dokument tipa 16"
   ENDIF

   RETURN


FUNCTION RadNalOK()

   LOCAL nArr
   LOCAL lOK
   LOCAL nLenBrDok

   IF ( !IsRamaGlas() )
      RETURN .T.
   ENDIF
   nArr := Select()
   lOK := .T.
   nLenBrDok := Len( _idZaduz2 )
   SELECT rnal
   HSEEK PadR( _idZaduz2, 10 )
   IF !Found()
      MsgBeep( "Unijeli ste nepostojeci broj radnog naloga. Otvaram sifrarnik radnih##naloga da biste mogli izabrati neki od postojecih!" )
      P_fakt_objekti( @_idZaduz2, 8, 60 )
      _idZaduz2 := PadR( _idZaduz2, nLenBrDok )
      ShowGets()
   ENDIF
   SELECT ( nArr )

   RETURN lOK
