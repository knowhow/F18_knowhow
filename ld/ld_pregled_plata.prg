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


FUNCTION ld_pregled_plata()

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

   cIdMinuli := "17"
   cKontrola := "N"

   Box(, 11, 75 )
   @ m_x + 1, m_y + 2 SAY Lokal( "Radna jedinica (prazno-sve): " )  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cMjesec  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Koeficijent benef.radnog staza (prazno-svi): "  GET  cKBenef VALID Empty( cKBenef ) .OR. P_KBenef( @cKBenef )
   @ m_x + 5, m_y + 2 SAY "Vrsta posla (prazno-svi): "  GET  cVPosla
   @ m_x + 7, m_y + 2 SAY "Sifra primanja minuli: "  GET  cIdMinuli PICT "@!"
   @ m_x + 8, m_y + 2 SAY Lokal( "Sortirati po(1-sifri,2-prezime+ime)" )  GET cVarSort VALID cVarSort $ "12"  PICT "9"
   @ m_x + 9, m_y + 2 SAY "Prikaz bruto iznosa ?" GET cPrBruto ;
      VALID cPrBruto $ "DN" PICT "@!"
   @ m_x + 11, m_y + 2 SAY "Kontrola (br.-dopr.-porez)+(prim.van neta)-(odbici)=(za isplatu)? (D/N)" GET cKontrola VALID cKontrola $ "DN" PICT "@!"
   read; clvbox(); ESC_BCR
   BoxC()

   WPar( "VS", cVarSort )
   SELECT PARAMS
   USE

   ParObr( cMjesec, cGodina, IF( lViseObr, cObracun, ) )

   tipprn_use()

   IF !Empty( ckbenef )
      SELECT kbenef
      hseek  ckbenef
   ENDIF
   IF !Empty( cVPosla )
      SELECT vposla
      hseek  cvposla
   ENDIF

   SELECT ld

   // 1 - "str(godina)+idrj+str(mjesec)+idradn"
   // 2 - "str(godina)+str(mjesec)+idradn"

   IF Empty( cidrj )
      cidrj := ""
      IF cVarSort == "1"
         SET ORDER TO tag ( TagVO( "2" ) )
         hseek Str( cGodina, 4 ) + Str( cmjesec, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" )
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
         hseek Str( cGodina, 4 ) + cidrj + Str( cmjesec, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" )
      ELSE
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := "IDRJ==" + _filter_quote( cIdRj ) + ".and." + ;
            IF( Empty( cMjesec ), ".t.", "MJESEC==" + _filter_quote( cMjesec ) ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==" + _filter_quote( cGodina ) )
         IF lViseObr .AND. !Empty( cObracun )
            cFilt += ".and.OBR=" + _filter_quote( cObracun )
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

   bZagl := {|| ZPregPl() }

   SELECT ld_rj
   hseek ld->idrj
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

   DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. cmjesec = mjesec .AND. !( lViseObr .AND. !Empty( cObracun ) .AND. obr <> cObracun )
	
      ParObr( ld->mjesec, ld->godina, IF( lViseObr, cObracun, ), ld->idrj )
	
      IF lViseObr .AND. Empty( cObracun )
         ScatterS( godina, mjesec, idrj, idradn )
      ELSE
         Scatter()
      ENDIF
 	
      SELECT radn
      hseek _idradn
      SELECT vposla
      hseek _idvposla
      SELECT kbenef
      hseek vposla->idkbenef
      SELECT ld
 	
      IF !Empty( cvposla ) .AND. cvposla <> Left( _idvposla, 2 )
         SKIP
         LOOP
      ENDIF
 	
      IF !Empty( ckbenef ) .AND. ckbenef <> kbenef->id
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

      // if prow()>58+gPStranica
      // FF
      // Eval(bZagl)
      // endif

      cRTipRada := ""
      nPrKoef := 0
      cOpor := ""
      cTrosk := ""
      nLicOdb := 0
      nNetNr := 0
      nNeto := 0

      SELECT ld

      cRTipRada := g_tip_rada( ld->idradn, ld->idrj )
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
      IF radn_oporeziv( ld->idradn, ld->idrj ) .AND. cRTipRada <> "S"
         nPorez := izr_porez( nBrOsn - nDoprIz - nLicOdb, "B" )
      ENDIF
		
      nNeto := ( nBrOsn - nDoprIz )
      nNetNr := ( nBrOsn - nDoprIz - nPorez )

      SELECT ld

      ? Str( ++nRbr, 4 ) + ".", idradn, RADNIK
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
   ? Space( 1 ) + Lokal( "UKUPNO:" )
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
   END PRINT

   my_close_all_dbf()

   RETURN



STATIC FUNCTION ZPregPl()

   ?

   P_COND2

   ? Upper( gTS ) + ":", gnFirma
   ?

   IF Empty( cidrj )
      ? Lokal( "Pregled za sve RJ ukupno:" )
   ELSE
      ? Lokal( "RJ:" ), cIdRj, ld_rj->naz
   ENDIF

   ?? Space( 2 ) + Lokal( "Mjesec:" ), Str( cmjesec, 2 ) + IspisObr()
   ?? Space( 4 ) + Lokal( "Godina:" ), Str( cGodina, 5 )

   DevPos( PRow(), 74 )

   ?? Lokal( "Str." ), Str( ++nStrana, 3 )

   IF !Empty( cvposla )
      ? Lokal( "Vrsta posla:" ), cvposla, "-", vposla->naz
   ENDIF
   IF !Empty( cKBenef )
      ? Lokal( "Stopa beneficiranog r.st:" ), ckbenef, "-", kbenef->naz, ":", kbenef->iznos
   ENDIF

   ? m

   IF gVarPP == "2"
         ? Lokal( " Rbr * Sifra*         Naziv radnika            *  Sati   *   Redovan *  Minuli   *   Neto    *       VAN NETA       * ZA ISPLATU*" )
         ? Lokal( "     *      *                                  *         *     rad   *   rad     *           * Primanja  * Obustave *           *" )
   ELSE
         ? Lokal( " Rbr * Sifra*         Naziv radnika            *  Sati   * Primanja  * Bruto pl. * Dopr (iz) * L.odbici  *  Porez    *    Neto   *  Na ruke  *  Ostale  *  Odbici    * ZA ISPLATU*" )
         ? "     *      *                                  *         *           * 1 x koef. *  1 x 31%  *           *    10%    *   (2-3)   *  (2-3-5)  * naknade  *            *(7 + 8 + 9)*"
         ? "     *      *                                  *         *    (1)    *    (2)    *    (3)    *    (4)    *   (5)     *    (6)    *    (7)    *    (8)   *    (9)     *    (10)   *"
   ENDIF
   ? m

   RETURN
