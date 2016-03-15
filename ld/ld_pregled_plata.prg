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


FUNCTION pregled_plata()

   LOCAL nC1 := 20
   LOCAL cPrBruto := "N"

   cIdRadn := Space( _LR_ )
   cIdRj := gRj
   cMjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun
   cVarSort := "2"

   O_KBENEF
   O_VPOSLA
   O_LD_RJ
   O_DOPR
   O_POR
   O_RADN
   O_LD
   O_PAROBR
   O_PARAMS

   PRIVATE cSection := "4"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "VS", @cVarSort )

   PRIVATE cKBenef := " "
   PRIVATE cVPosla := "  "

   PRIVATE nStepenInvaliditeta := 0
   PRIVATE nVrstaInvaliditeta := 0

   cIdMinuli := "17"
   cKontrola := "N"

   Box(, 14, 75 )
   @ m_x + 1, m_y + 2 SAY8 _l( "Radna jedinica (prazno-sve): " )  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY8 "Mjesec: "  GET  cMjesec  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY8 "Obračun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY8 "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY8 "Koeficijent benef.radnog staža (prazno-svi): "  GET  cKBenef VALID Empty( cKBenef ) .OR. P_KBenef( @cKBenef )
   @ m_x + 5, m_y + 2 SAY8 "Vrsta posla (prazno-svi): "  GET  cVPosla
   @ m_x + 7, m_y + 2 SAY8 "Šifra primanja minuli: "  GET  cIdMinuli PICT "@!"
   @ m_x + 8, m_y + 2 SAY8 "Sortirati po (1-šifri, 2-prezime+ime)"  GET cVarSort VALID cVarSort $ "12"  PICT "9"
   @ m_x + 9, m_y + 2 SAY "Prikaz bruto iznosa ?" GET cPrBruto ;
      VALID cPrBruto $ "DN" PICT "@!"
   @ m_x + 11, m_y + 2 SAY8 "Kontrola (br.-dopr.-porez)+(prim.van neta)-(odbici)=(za isplatu)? (D/N)" GET cKontrola VALID cKontrola $ "DN" PICT "@!"


   @ m_x + 13, m_y + 2 SAY8 "Vrsta invaliditeta (0 sve)  : "  GET  nVrstaInvaliditeta  PICT "9" VALID nVrstaInvaliditeta == 0 .OR. valid_vrsta_invaliditeta( @nVrstaInvaliditeta )
   @ m_x + 14, m_y + 2 SAY8 "Stepen invaliditeta (>=)    : "  GET  nStepenInvaliditeta  PICT "999" VALID valid_stepen_invaliditeta( @nStepenInvaliditeta )

   READ
   clvbox()
   ESC_BCR
   BoxC()

   WPar( "VS", cVarSort )
   SELECT PARAMS
   USE

   ParObr( cMjesec, cGodina, iif( lViseObr, cObracun, ) )

   tipprn_use()

   IF !Empty( cKbenef )
      SELECT kbenef
      HSEEK  cKbenef
   ENDIF

   IF !Empty( cVPosla )
      SELECT vposla
      HSEEK  cVposla
   ENDIF

   SELECT ld
   USE
   use_sql_ld_ld( cGodina, cMjesec, cMjesec, nVrstaInvaliditeta, nStepenInvaliditeta )

   // 1 - "str(godina)+idrj+str(mjesec)+idradn"
   // 2 - "str(godina)+str(mjesec)+idradn"
   IF Empty( cIdrj )
      cidrj := ""
      IF cVarSort == "1"
         SET ORDER TO tag ( TagVO( "2" ) )
         HSEEK Str( cGodina, 4, 0 ) + Str( cMjesec, 2, 0 ) + iif( lViseObr .AND. !Empty( cObracun ), cObracun, "" )
      ELSE
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := IF( Empty( cMjesec ), ".t.", "MJESEC==" + _filter_quote( cMjesec ) ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==" + _filter_quote( cGodina ) )
         IF lViseObr .AND. !Empty( cObracun )
            cFilt += ".and.OBR=" + _filter_quote( cObracun )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ELSE
      IF cVarSort == "1"
         SET ORDER TO tag ( TagVO( "1" ) )
         HSEEK Str( cGodina, 4 ) + cidrj + Str( cMjesec, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" )
      ELSE
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := "IDRJ==" + _filter_quote( cIdRj ) + ".and." + ;
            iif( Empty( cMjesec ), ".t.", "MJESEC==" + _filter_quote( cMjesec ) ) + ".and." + ;
            iif( Empty( cGodina ), ".t.", "GODINA==" + _filter_quote( cGodina ) )
         IF lViseObr .AND. !Empty( cObracun )
            cFilt += ".and.OBR==" + _filter_quote( cObracun )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ENDIF


   EOF CRET

   nStrana := 0

   IF gVarPP == "2"
      m := "----- ------ ---------------------------------- " + "-" + REPL( "-", Len( gPicS ) ) + " ----------- ----------- ----------- ----------- ----------- -----------"
   ELSE
      m := "----- ------ ---------------------------------- " + "-" + REPL( "-", Len( gPicS ) ) + " ----------- ----------- ----------- -----------"
   ENDIF

   m += " " + Replicate( "-", 11 )
   m += " " + Replicate( "-", 11 )
   m += " " + Replicate( "-", 11 )
   m += " " + Replicate( "-", 11 )
   m += " " + Replicate( "-", 11 )
   m += " " + Replicate( "-", 11 )

   IF cPrBruto == "D"
      m += " " + Replicate( "-", 12 )
   ENDIF

   bZagl := {|| zagl_pregled_plata() }

   SELECT ld_rj
   HSEEK ld->idrj
   SELECT ld

   START PRINT CRET

   P_12CPI

   Eval( bZagl )

   nRbr := 0
   nT2a := nT2b := 0
   nT1 := nT2 := nT3 := nT3b := nT4 := nT5 := 0
   nVanP := 0  // van neta plus
   nVanM := 0  // van neta minus

   nULicOdb := 0
   nUBruto := 0
   nUDoprIz := 0
   nUPorez := 0
   nUNetNr := 0
   nUNeto := 0

   DO WHILE !Eof() .AND.  cGodina == godina .AND. idrj = cidrj .AND. cMjesec = mjesec .AND. !( lViseObr .AND. !Empty( cObracun ) .AND. obr <> cObracun )

      ParObr( ld->mjesec, ld->godina, IIF( lViseObr, cObracun, ), ld->idrj )

      IF lViseObr .AND. Empty( cObracun )
         ScatterS( godina, mjesec, idrj, idradn )
      ELSE
         Scatter()
      ENDIF

      SELECT radn
      HSEEK _idradn

      SELECT vposla
      HSEEK _idvposla
      SELECT kbenef
      HSEEK vposla->idkbenef
      SELECT ld

      IF !Empty( cVposla ) .AND. cVposla <> Left( _idvposla, 2 )
         SKIP
         LOOP
      ENDIF

      IF !Empty( cKbenef ) .AND. cKbenef <> kbenef->id
         SKIP
         LOOP
      ENDIF

      nVanP := 0
      nVanM := 0
      nMinuli := 0

      FOR i := 1 TO cLDPolja

         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         SELECT tippr
         SEEK cPom
         SELECT ld

         IF tippr->( Found() ) .AND. tippr->aktivan == "D"

            nIznos := _i&cpom

            IF tippr->uneto == "N" .AND. nIznos <> 0

               IF nIznos > 0
                  nVanP += nIznos
               ELSE
                  nVanM += nIznos
               ENDIF

            ELSEIF tippr->uneto == "D" .AND. nIznos <> 0

               IF cPom == cIdMinuli
                  nMinuli := nIznos
               ENDIF

            ENDIF
         ENDIF
      NEXT


      cRTipRada := ""
      nPrKoef := 0
      cOpor := ""
      cTrosk := ""
      nLicOdb := 0
      nNetNr := 0
      nNeto := 0

      SELECT ld

      cRTipRada := g_tip_rada( _idradn, ld->idrj )
      nPrKoef := radn->sp_koef
      cOpor := radn->opor
      cTrosk := radn->trosk
      nLicOdb := _ulicodb

      nBO := bruto_osn( _uneto, cRTipRada, nLicOdb, nPrKoef, cTrosk )
      nMBO := nBO

      IF calc_mbruto()
         nMBO := min_bruto( nBo, ld->usati )
      ENDIF

      nBrOsn := nBo

      IF cRTipRada == "A" .AND. cTrosk <> "N"
         nTrosk := nBO * ( gAhTrosk / 100 )
         nBrOsn := nBO - nTrosk
      ELSEIF cRTipRada == "U" .AND. cTrosk <> "N"
         nTrosk := nBO * ( gUgTrosk / 100 )
         nBrOsn := nBO - nTrosk
      ENDIF

      nDoprIz := u_dopr_iz( nMBO, cRTipRada )

      nPorez := 0
      IF radn_oporeziv( _idradn, ld->idrj ) .AND. cRTipRada <> "S"
         nPorez := izr_porez( nBrOsn - nDoprIz - nLicOdb, "B" )
      ENDIF

      nNeto := ( nBrOsn - nDoprIz )
      nNetNr := ( nBrOsn - nDoprIz - nPorez )

      SELECT ld

      ? Str( ++nRbr, 4 ) + ".", _idradn, RADNIK_PREZ_IME
      nC1 := PCol() + 1

      @ PRow(), PCol() + 1 SAY _usati PICT gpics

      IF gVarPP == "2"
         @ PRow(), PCol() + 1 SAY _uneto - nMinuli PICT gpici
         @ PRow(), PCol() + 1 SAY nMinuli PICT gpici
      ENDIF

      @ PRow(), PCol() + 1 SAY _uneto PICT gpici
      @ PRow(), PCol() + 1 SAY nBrOsn PICT gpici
      @ PRow(), PCol() + 1 SAY nDoprIz PICT gpici
      @ PRow(), PCol() + 1 SAY nLicOdb PICT gpici
      @ PRow(), PCol() + 1 SAY nPorez PICT gpici
      @ PRow(), PCol() + 1 SAY nNeto PICT gpici
      @ PRow(), PCol() + 1 SAY nNetNr PICT gpici
      @ PRow(), PCol() + 1 SAY nVanP PICT gpici
      @ PRow(), PCol() + 1 SAY nVanM PICT gpici
      @ PRow(), PCol() + 1 SAY _uiznos PICT gpici

      IF cKontrola == "D"
         nKontrola := ( nBrOsn - nDoprIz - nPorez ) + nVanP + nVanM
         IF Round( _uiznos, 2 ) = Round( nKontrola, 2 )
            // nista
         ELSE
            @ PRow(), PCol() + 1 SAY "ERR"
         ENDIF
      ENDIF

      nT1 += _usati
      nT2a += _uneto - nMinuli
      nT2b += nMinuli
      nT2 += _uneto
      nT3 += nVanP
      nT3b += nVanM
      nT4 += _uiznos
      nULicOdb += nLicOdb
      nUBruto += nBrOsn
      nUDoprIz += nDoprIz
      nUPorez += nPorez
      nUNetNr += nNetNr
      nUNeto += nNeto

      SKIP

   ENDDO

   ? m
   ? Space( 1 ) + _l( "UKUPNO:" )
   @ PRow(), nC1 SAY  nT1 PICT gpics

   IF gVarPP == "2"
      @ PRow(), PCol() + 1 SAY nT2a PICT gpici
      @ PRow(), PCol() + 1 SAY nT2b PICT gpici
   ENDIF

   @ PRow(), PCol() + 1 SAY nT2 PICT gpici
   @ PRow(), PCol() + 1 SAY nUBruto PICT gpici
   @ PRow(), PCol() + 1 SAY nUDoprIz PICT gpici
   @ PRow(), PCol() + 1 SAY nULicOdb PICT gpici
   @ PRow(), PCol() + 1 SAY nUPorez PICT gpici
   @ PRow(), PCol() + 1 SAY nUNeto PICT gpici
   @ PRow(), PCol() + 1 SAY nUNetNR PICT gpici
   @ PRow(), PCol() + 1 SAY nT3 PICT gpici
   @ PRow(), PCol() + 1 SAY nT3b PICT gpici
   @ PRow(), PCol() + 1 SAY nT4 PICT gpici

   ? m
   ?
   ? p_potpis()

   FF
   ENDPRINT

   my_close_all_dbf()

   RETURN



STATIC FUNCTION zagl_pregled_plata()

   ?

   P_COND2

   ? Upper( gTS ) + ":", gnFirma
   ?

   IF Empty( cIdrj )
      ? "Pregled za sve RJ ukupno:"
   ELSE
      ? "RJ:", cIdRj, ld_rj->naz
   ENDIF

   ?? Space( 2 ) + "Mjesec:", Str( cMjesec, 2 ) + IspisObr()
   ?? Space( 4 ) + "Godina:", Str( cGodina, 5 )

   ?? SPACE(10), " Str.", Str( ++nStrana, 3 )

   IF nVrstaInvaliditeta > 0 .OR. nStepenInvaliditeta > 0
      ?
   ENDIF
   IF nVrstaInvaliditeta > 0
      ?? " Vr.invaliditeta:", Str( nVrstaInvaliditeta, 1, 0 )
   ENDIF
   IF nStepenInvaliditeta > 0
      ?? " St.invaliditeta", Str( nStepenInvaliditeta, 3, 0 )
   ENDIF


   IF !Empty( cVposla )
      ? "Vrsta posla:", cVposla, "-", vposla->naz
   ENDIF
   IF !Empty( cKBenef )
      ? "Stopa beneficiranog r.st:", cKbenef, "-", kbenef->naz, ":", kbenef->iznos
   ENDIF

   ? m

   IF gVarPP == "2"
      ?U " Rbr * Šifra*         Naziv radnika            *  Sati   *   Redovan *  Minuli   *   Neto    *       VAN NETA       * ZA ISPLATU*"
      ?U "     *      *                                  *         *     rad   *   rad     *           * Primanja  * Obustave *           *"
   ELSE
      ?U " Rbr * Šifra*         Naziv radnika            *  Sati   * Primanja  * Bruto pl. * Dopr (iz) * L.odbici  *  Porez    *    Neto   *  Na ruke  *  Ostale  *  Odbici    * ZA ISPLATU*"
      ?U "     *      *                                  *         *           * 1 x koef. *  1 x 31%  *           *    10%    *   (2-3)   *  (2-3-5)  * naknade  *            *(7 + 8 + 9)*"
      ?U "     *      *                                  *         *    (1)    *    (2)    *    (3)    *    (4)    *   (5)     *    (6)    *    (7)    *    (8)   *    (9)     *    (10)   *"
   ENDIF
   ? m

   RETURN .T.
