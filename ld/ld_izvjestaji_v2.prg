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


#include "ld.ch"


FUNCTION RekapBod()

   LOCAL nC1 := 20

   cIdRadn := Space( 6 )
   cIdRj := gRj; cmjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun

   O_KBENEF
   O_VPOSLA
   O_LD_RJ
   O_RADN
   O_LD

   PRIVATE cKBenef := " ", cVPosla := "  ", cTCekanje := "08", cTMinRad := "17"

   Box(, 8, 50 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cmjesec  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Koeficijent benef.radnog staza (prazno-svi): "  GET  cKBenef VALID Empty( cKBenef ) .OR. P_KBenef( @cKBenef )
   @ m_x + 5, m_y + 2 SAY "Vrsta posla (prazno-svi):  "  GET  cVPosla
   @ m_x + 7, m_y + 2 SAY "Sifra primanja cekanje   : "  GET  cTCekanje
   @ m_x + 8, m_y + 2 SAY "Sifra primanja minuli rad: "  GET  cTMinRad
   read; clvbox(); ESC_BCR
   BoxC()

   IF !Empty( ckbenef )
      SELECT kbenef
      hseek  ckbenef
   ENDIF
   IF !Empty( cVPosla )
      SELECT vposla
      hseek  cvposla
   ENDIF

   SELECT ld

   PRIVATE cSort
   PRIVATE cFilt
   IF Empty( cidrj )
      cidrj := ""
      cSort := "BodSort()"
   ELSE
      cSort := "cIdrj+BodSort()"
   ENDIF


   EOF CRET

   nStrana := 0
   m := "-------- ----------- ----------- ----------- ----------- ----------- -----------"

   SELECT ld_rj; hseek ld->idrj; SELECT ld


   cFilt := Str( cGodina ) + "==godina .and." + Str( cmjesec ) + "==mjesec .and. idrj='" + cidrj + "'"

   IF lViseObr .AND. !Empty( cObracun )
      cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
   ENDIF

   Box(, 1, 30 )
   INDEX on &cSort TO "TMPBOD" for &cFilt
   BoxC()
   START PRINT CRET


   nRbr := 0
   nT1 := nT2 := nT3 := nT4 := 0

   nURadnika := 0
   nUNeto := 0
   nUMinRad := 0
   nUUkupno := 0
   nUOdbici := 0

   P_10CPI
   ? "REKAPITULACIJA PO KOEFICIJENTIMA PRIMANJA (" + IF( gBodK == "1", "BROJ BODOVA", "KOEFICIJENT" ) + " RADNIKA)"
   ?
   ? Upper( Trim( gTS ) ) + ":", gnFirma
   P_COND
   ?
   IF Empty( cidrj )
      ? "Pregled za sve RJ ukupno:"
   ELSE
      ? "RJ:", cidrj, ld_rj->naz
   ENDIF
   ?? "  Mjesec:", Str( cmjesec, 2 ) + IspisObr()
   ?? "    Godina:", Str( cGodina, 5 )
   IF !Empty( cvposla )
      ? "Vrsta posla:", cvposla, "-", vposla->naz
   ENDIF
   IF !Empty( cKBenef )
      ? "Stopa beneficiranog r.st:", ckbenef, "-", kbenef->naz, ":", kbenef->iznos
   ENDIF
   P_COND
   ?
   ?
   ? m
   ? " Koefic.    Radnika  NETO-MinRad    MinRad      Neto        Odbici     Ukupno"
   ? m
   GO TOP
   DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. cmjesec = mjesec

      SELECT ld
      cBodsort := BodSort()
      nRadnika := 0
      nNeto := 0
      nMinRad := 0
      nUkupno := 0
      nOdbici := 0
      DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. cmjesec = mjesec .AND. BodSort() == cBodSort
         SELECT ld
         Scatter()
         SELECT radn; hseek _idradn
         SELECT vposla; hseek _idvposla
         SELECT kbenef; hseek vposla->idkbenef
         // if !empty(cvposla) .and. cvposla<>left(_idvposla,1)
         IF !Empty( cvposla ) .AND. cvposla <> Left( _idvposla, 2 )
            SELECT LD; SKIP 1; LOOP
         ENDIF
         IF !Empty( ckbenef ) .AND. ckbenef <> kbenef->id
            SELECT LD; SKIP 1; LOOP
         ENDIF
         nNeto += _UNeto
         nMinRad += _I&cTMinRad
         nOdbici += _UOdbici
         nUkupno += _UIznos
         IF ! ( lViseObr .AND. Empty( cObracun ) .AND. _obr <> "1" )
            ++nRadnika
         ENDIF
         SELECT ld
         SKIP
      ENDDO  // bodSort


      IF PRow() > RPT_PAGE_LEN; FF; ENDIF
      IF cBodSort > "99999.00"
         ? m
         ? "CEKANJE "
      ELSE
         ? cBodSort
      ENDIF
      nC1 := PCol() + 1


      @ PRow(), PCol() + 1 SAY nRadnika       PICT gpici
      @ PRow(), PCol() + 1 SAY nNeto - nMinRad  PICT gpici
      @ PRow(), PCol() + 1 SAY nMinRad  PICT gpici
      @ PRow(), PCol() + 1 SAY nNeto  PICT gpici
      @ PRow(), PCol() + 1 SAY nOdBici  PICT gpici
      @ PRow(), PCol() + 1 SAY nUkupno  PICT gpici


      nUNeto += nNeto; nUMinRad += nMinRad
      nUOdbici += nOdbici
      nUUkupno += nUkupno
      nURadnika += nRadnika
   ENDDO

   IF PRow() > 60; FF; ENDIF
   ? m
   ? " UKUPNO:"
   @ PRow(), nC1      SAY nURadnika        PICT gpici
   @ PRow(), PCol() + 1 SAY nUNeto - nUMinRad  PICT gpici
   @ PRow(), PCol() + 1 SAY nUMinRad  PICT gpici
   @ PRow(), PCol() + 1 SAY nUNeto  PICT gpici
   @ PRow(), PCol() + 1 SAY nUOdBici  PICT gpici
   @ PRow(), PCol() + 1 SAY nUUkupno  PICT gpici
   ? m

   ?
   ? p_potpis()

   FF
   END PRINT
   CLOSERET

   RETURN



FUNCTION TekRec()

   @ m_x + 1, m_y + 2 SAY RecNo()

   RETURN NIL


FUNCTION BodSort()

   // {
   IF ld->( I&cTCekanje ) <> 0
      RETURN Str( 99999.99, 8, 2 )
   ELSE
      RETURN Str( ld->brbod, 8, 2 )
   ENDIF

   RETURN
// }


FUNCTION ObrM4()

   // {

   CLOSERET

   RETURN
// }

// -----------------------------------------------
// pregled primanja za odredjeni period
// -----------------------------------------------
FUNCTION PregPrimPer()

   LOCAL nC1 := 20

   cIdRadn := Space( 6 )
   cIdRj := gRj
   cGodina := gGodina
   cObracun := gObracun

   O_LD_RJ
   O_RADN
   O_LD

   PRIVATE cTip := "  "
   cDod := "N"
   cKolona := Space( 20 )
   Box(, 6, 75 )
   cMjesecOd := cMjesecDo := gMjesec
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec od: "  GET  cmjesecOd  PICT "99"
   @ m_x + 2, Col() + 2 SAY "do" GET cMjesecDO  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Tip primanja: "  GET  cTip
   @ m_x + 5, m_y + 2 SAY "Prikaz dodatnu kolonu: "  GET  cDod PICT "@!" VALID cdod $ "DN"
   read; clvbox(); ESC_BCR
   IF cDod == "D"
      @ m_x + 6, m_y + 2 SAY "Naziv kolone:" GET cKolona
      READ
   ENDIF
   fRacunaj := .F.
   IF Left( cKolona, 1 ) = "="
      fRacunaj := .T.
      ckolona := StrTran( cKolona, "=", "" )
   ELSE
      ckolona := "radn->" + ckolona
   ENDIF
   BoxC()

   tipprn_use()

   SELECT tippr
   hseek ctip
   EOF CRET

   // "LDi4","str(godina)+idradn+str(mjesec)",KUMPATH+"LD")
   SELECT ld

   IF lViseObr .AND. !Empty( cObracun )
      SET FILTER TO obr == cObracun
   ENDIF

   SET ORDER TO tag ( TagVO( "4" ) )
   hseek Str( cGodina, 4 )

   EOF CRET

   nStrana := 0
   m := "----- ------ ---------------------------------- " + "-" + REPL( "-", Len( gPicS ) ) + " ----------- -----------"
   IF cdod == "D"
      IF Type( ckolona ) $ "UUIUE"
         Msg( "Nepostojeca kolona" )
         closeret
      ENDIF
   ENDIF
   bZagl := {|| ZPregPrimPer() }

   SELECT ld_rj; hseek ld->idrj; SELECT ld

   START PRINT CRET
   P_10CPI

   Eval( bZagl )

   nRbr := 0
   nT1 := nT2 := nT3 := nT4 := 0
   nC1 := 10

   DO WHILE !Eof() .AND.  cgodina == godina
      IF PRow() > RPT_PAGE_LEN; FF; Eval( bZagl ); ENDIF


      cIdRadn := idradn
      SELECT radn; hseek cidradn; SELECT ld

      wi&cTip := 0
      ws&cTip := 0

      IF fracunaj
         nKolona := 0
      ENDIF
      DO WHILE  !Eof() .AND. cgodina == godina .AND. idradn == cidradn
         Scatter()
         IF !Empty( cidrj ) .AND. _idrj <> cidrj
            skip; LOOP
         ENDIF
         IF cmjesecod > _mjesec .OR. cmjesecdo < _mjesec
            skip; LOOP
         ENDIF
         wi&cTip += _i&cTip
         IF ! ( lViseObr .AND. Empty( cObracun ) .AND. _obr <> "1" )
            ws&cTip += _s&cTip
         ENDIF
         IF fRacunaj
            nKolona += &cKolona
         ENDIF
         SKIP
      ENDDO

      IF wi&cTip <> 0 .OR. ws&cTip <> 0
         ? Str( ++nRbr, 4 ) + ".", cidradn, RADNIK
         nC1 := PCol() + 1
         IF tippr->fiksan == "P"
            @ PRow(), PCol() + 1 SAY ws&cTip  PICT "999.99"
         ELSE
            @ PRow(), PCol() + 1 SAY ws&cTip  PICT gpics
         ENDIF
         @ PRow(), PCol() + 1 SAY wi&cTip  PICT gpici
         nT1 += ws&cTip; nT2 += wi&cTip
         IF cdod == "D"
            IF fracunaj
               @ PRow(), PCol() + 1 SAY nKolona PICT gpici
            ELSE
               @ PRow(), PCol() + 1 SAY &ckolona
            ENDIF
         ENDIF

      ENDIF

      SELECT ld
   ENDDO

   IF PRow() > 60; FF; Eval( bZagl ); ENDIF
   ? m
   ? " UKUPNO:"
   @ PRow(), nC1 SAY  nT1 PICT gpics
   @ PRow(), PCol() + 1 SAY  nT2 PICT gpici
   ? m
   ?
   ? p_potpis()

   FF
   END PRINT
   CLOSERET

FUNCTION ZPregPrimPer()

   P_12CPI
   ? Upper( Trim( gTS ) ) + ":", gnFirma
   ?
   ? "Pregled primanja za period od", cMjesecOd, "do", cMjesecDo, "mjesec " + IspisObr()
   ?? cGodina
   ?
   IF Empty( cIdRj )
      ? "Pregled za sve RJ ukupno:"
   ELSE
      ? "RJ:", cIdRj, ld_rj->naz
   ENDIF
   ?? Space( 4 ), "Str.", Str( ++nStrana, 3 )
   ?
   ? "Pregled za tip primanja:", ctip, tippr->naz

   ? m
   ? " Rbr  Sifra           Naziv radnika               " + iif( tippr->fiksan == "P", " %  ", "Sati" ) + "      Iznos"
   ? m

FUNCTION SpecNovcanica()

   // {
   LOCAL aLeg := {}, aPom := {,, }

   gnLMarg := 0; gTabela := 1; gOstr := "D"; cOdvLin := "D"; cVarSpec := "1"

   cIdRj := gRj; cmjesec := gMjesec; cGodina := gGodina; cObracun := gObracun

   nAp1  := 100; nAp2  :=  50; nAp3  :=  20; nAp4  :=  10; nAp5  :=   5
   nAp6  :=   1; nAp7  := 0.5; nAp8  := 0.2; nAp9  := 0.1; nAp10 :=   0
   nAp11 :=   0; nAp12 :=   0
   cAp1 := cAp2 := cAp3 := cAp4 := cAp5 := cAp6 := cAp7 := cAp8 := cAp9 := "D"
   cAp10 := cAp11 := cAp12 := "N"

   O_KBENEF
   O_VPOSLA
   O_LD_RJ
   O_RADN

#ifdef CPOR
   IF Pitanje(, "Izvjestaj se pravi za isplacene(D) ili neisplacene(N) radnike?", "D" ) == "D"
      lIsplaceni := .T.
      O_LD
   ELSE
      lIsplaceni := .F.
      SELECT ( F_LDNO )  ; usex ( KUMPATH + "LDNO" ) ALIAS LD; SET ORDER TO 1
   ENDIF
#else
   O_LD
#endif

   O_PARAMS
   PRIVATE cSection := "4", cHistory := " ", aHistory := {}
   RPar( "t4", @gOstr ); RPar( "t5", @cOdvLin ); RPar( "t6", @gTabela )
   RPar( "u0", @cAp1 ) ; RPar( "u1", @cAp2 ) ; RPar( "u2", @cAp3 )
   RPar( "u3", @cAp4 ) ; RPar( "u4", @cAp5 ) ; RPar( "u5", @cAp6 )
   RPar( "u6", @cAp7 ) ; RPar( "u7", @cAp8 ) ; RPar( "u8", @cAp9 )
   RPar( "u9", @cAp10 ); RPar( "v0", @cAp11 ); RPar( "v1", @cAp12 )

   RPar( "v2", @nAp1 ) ; RPar( "v3", @nAp2 ) ; RPar( "v4", @nAp3 )
   RPar( "v5", @nAp4 ) ; RPar( "v6", @nAp5 ) ; RPar( "v7", @nAp6 )
   RPar( "v8", @nAp7 ) ; RPar( "v9", @nAp8 ) ; RPar( "z0", @nAp9 )
   RPar( "z1", @nAp10 ); RPar( "z2", @nAp11 ); RPar( "z3", @nAp12 )

   Box(, 19, 75 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cmjesec  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 2, Col() + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 3, m_y + 2 SAY "Varijanta (1-samo ukupno,2-po radnicima)"  GET cVarSpec VALID cVarSpec $ "12"
   @ m_x + 4, m_y + 2 SAY "Nacin crtanja tabele     (0/1/2)   "  GET gTabela VALID gTabela >= 0 .AND. gTabela <= 2 PICT "9"
   @ m_x + 5, m_y + 2 SAY "Ukljuceno ostranicavanje (D/N) ?   "  GET gOstr   VALID gOstr $ "DN"    PICT "@!"
   @ m_x + 6, m_y + 2 SAY "Odvajati podatke linijom (D/N) ?   "  GET cOdvLin VALID cOdvLin $ "DN"  PICT "@!"
   @ m_x + 8, m_y + 2 SAY "Iznos apoena:" GET nAp1 PICT "9999.99"
   @ m_x + 8, m_y + 32 SAY ", aktivan (D/N)" GET cAp1 VALID cAp1 $ "DN" PICT "@!"
   @ m_x + 9, m_y + 2 SAY "Iznos apoena:" GET nAp2 PICT "9999.99"
   @ m_x + 9, m_y + 32 SAY ", aktivan (D/N)" GET cAp2 VALID cAp2 $ "DN" PICT "@!"
   @ m_x + 10, m_y + 2 SAY "Iznos apoena:" GET nAp3 PICT "9999.99"
   @ m_x + 10, m_y + 32 SAY ", aktivan (D/N)" GET cAp3 VALID cAp3 $ "DN" PICT "@!"
   @ m_x + 11, m_y + 2 SAY "Iznos apoena:" GET nAp4 PICT "9999.99"
   @ m_x + 11, m_y + 32 SAY ", aktivan (D/N)" GET cAp4 VALID cAp4 $ "DN" PICT "@!"
   @ m_x + 12, m_y + 2 SAY "Iznos apoena:" GET nAp5 PICT "9999.99"
   @ m_x + 12, m_y + 32 SAY ", aktivan (D/N)" GET cAp5 VALID cAp5 $ "DN" PICT "@!"
   @ m_x + 13, m_y + 2 SAY "Iznos apoena:" GET nAp6 PICT "9999.99"
   @ m_x + 13, m_y + 32 SAY ", aktivan (D/N)" GET cAp6 VALID cAp6 $ "DN" PICT "@!"
   @ m_x + 14, m_y + 2 SAY "Iznos apoena:" GET nAp7 PICT "9999.99"
   @ m_x + 14, m_y + 32 SAY ", aktivan (D/N)" GET cAp7 VALID cAp7 $ "DN" PICT "@!"
   @ m_x + 15, m_y + 2 SAY "Iznos apoena:" GET nAp8 PICT "9999.99"
   @ m_x + 15, m_y + 32 SAY ", aktivan (D/N)" GET cAp8 VALID cAp8 $ "DN" PICT "@!"
   @ m_x + 16, m_y + 2 SAY "Iznos apoena:" GET nAp9 PICT "9999.99"
   @ m_x + 16, m_y + 32 SAY ", aktivan (D/N)" GET cAp9 VALID cAp9 $ "DN" PICT "@!"
   @ m_x + 17, m_y + 2 SAY "Iznos apoena:" GET nAp10 PICT "9999.99"
   @ m_x + 17, m_y + 32 SAY ", aktivan (D/N)" GET cAp10 VALID cAp10 $ "DN" PICT "@!"
   @ m_x + 18, m_y + 2 SAY "Iznos apoena:" GET nAp11 PICT "9999.99"
   @ m_x + 18, m_y + 32 SAY ", aktivan (D/N)" GET cAp11 VALID cAp11 $ "DN" PICT "@!"
   @ m_x + 19, m_y + 2 SAY "Iznos apoena:" GET nAp12 PICT "9999.99"
   @ m_x + 19, m_y + 32 SAY ", aktivan (D/N)" GET cAp12 VALID cAp12 $ "DN" PICT "@!"
   read; clvbox(); ESC_BCR
   BoxC()

   WPar( "t4", gOstr ); WPar( "t5", cOdvLin ); WPar( "t6", gTabela )
   WPar( "u0", cAp1 ) ; WPar( "u1", cAp2 ) ; WPar( "u2", cAp3 )
   WPar( "u3", cAp4 ) ; WPar( "u4", cAp5 ) ; WPar( "u5", cAp6 )
   WPar( "u6", cAp7 ) ; WPar( "u7", cAp8 ) ; WPar( "u8", cAp9 )
   WPar( "u9", cAp10 ); WPar( "v0", cAp11 ); WPar( "v1", cAp12 )

   WPar( "v2", nAp1 ) ; WPar( "v3", nAp2 ) ; WPar( "v4", nAp3 )
   WPar( "v5", nAp4 ) ; WPar( "v6", nAp5 ) ; WPar( "v7", nAp6 )
   WPar( "v8", nAp7 ) ; WPar( "v9", nAp8 ) ; WPar( "z0", nAp9 )
   WPar( "z1", nAp10 ); WPar( "z2", nAp11 ); WPar( "z3", nAp12 )
   SELECT PARAMS; USE

   tipprn_use()

   SELECT ld


   Box(, 2, 30 )
   nSlog := 0; nUkupno := RECCOUNT2()
   cSort1 := "IDRADN"
   cFilt := IF( Empty( cIdRj ), ".t.", "IDRJ==cIdRj" ) + ".and." + ;
      IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
      IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
   IF lViseObr .AND. !Empty( cObracun )
      cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
   ENDIF
   INDEX ON &cSort1 TO "tmpld" FOR &cFilt
   BoxC()

   EOF CRET
   GO TOP
   aKol := {}

   IF cVarSpec == "2"

#ifdef CPOR
      AAdd( aKol, { "SIFRA", {|| cIdRadn }, .F., "C", 13, 0, 1, 1 } )
#else
      AAdd( aKol, { "SIFRA", {|| cIdRadn }, .F., "C",  6, 0, 1, 1 } )
#endif

      AAdd( aKol, { "PREZIME I IME RADNIKA", {|| cNaziv }, .F., "C", 27, 0, 1, 2 } )

      aApoeni := {}; aApSort := {}; aNovc := {}; nKol := 2

      FOR i := 1 TO 12
         cPom := "cAp" + AllTrim( Str( i ) )
         nPom := "nAp" + AllTrim( Str( i ) )
         IF &cPom == "D" .AND. AScan( aApoeni, &nPom ) <= 0
            AAdd( aApoeni, &nPom )
            AAdd( aNovc, 0 )
            AAdd( aApSort, { &nPom, Len( aApoeni ) } )
            bBlok := "{|| " + "aNovc[" + AllTrim( Str( Len( aApoeni ) ) ) + "] }"
            AAdd( aKol, { "Apoen " + AllTrim( Str( &nPom ) ), &bBlok., .T., "N", 11, 0, 1, ++nKol } )
         ENDIF
      NEXT

      ASort( aApSort,,, {|x, y| x[ 1 ] > y[ 1 ] } )


      START PRINT CRET

      PRIVATE cIdRadn := "", cNaziv := ""

      ?? Space( gnLMarg ); ?? "LD: Izvjestaj na dan", Date()
      ? Space( gnLMarg ); IspisFirme( "" )
      ?
      IF Empty( cidrj )
         ? "Pregled za sve RJ ukupno:"
      ELSE
         ? "RJ:", cidrj + " - " + Ocitaj( F_RJ, cIdRj, "naz" )
      ENDIF
      ?? "  Mjesec:", IF( Empty( cMjesec ), "SVI", Str( cmjesec, 2 ) ) + IspisObr()
      ?? "    Godina:", IF( Empty( cGodina ), "SVE", Str( cGodina, 5 ) )
      ?

#ifdef CPOR
      StampaTabele( aKol, {|| FSvaki5() },, gTabela,, ;
         , "Specifikacija novcanica " + IF( lIsplaceni, "potrebnih za isplatu plata", "preostalih od neisplacenih plata" ), ;
         {|| FFor5() }, IF( gOstr == "D",, -1 ),, cOdvLin == "D",,, )
#else
      StampaTabele( aKol, {|| FSvaki5() },, gTabela,, ;
         , "Specifikacija novcanica potrebnih za isplatu plata", ;
         {|| FFor5() }, IF( gOstr == "D",, -1 ),, cOdvLin == "D",,, )
#endif

      ?
      FF
      END PRINT

   ELSE    // cVarSpec=="1"

      aApoeni := {}; aNovc := {}

      FOR i := 1 TO 12
         cPom := "cAp" + AllTrim( Str( i ) )
         nPom := "nAp" + AllTrim( Str( i ) )
         IF &cPom == "D" .AND. AScan( aApoeni, &nPom ) <= 0
            AAdd( aApoeni, &nPom )
            AAdd( aNovc, 0 )
         ENDIF
      NEXT

      DO WHILE !Eof()
         cIdRadn := IDRADN
         nPom := 0
         DO WHILE !Eof() .AND. cIdRadn == IDRADN
            nPom += uiznos
            SKIP 1
         ENDDO

         FOR i := 1 TO Len( aApoeni )
            IF Str( nPom, 12, 2 ) >= Str( aApoeni[ i ], 12, 2 )
               nPom2 := Int( Round( nPom, 2 ) / Round( aApoeni[ i ], 2 ) )
               aNovc[ i ] += nPom2
               nPom := nPom - nPom2 * aApoeni[ i ]
            ENDIF
         NEXT
      ENDDO

      nUkupno := 0
      START PRINT CRET
      ?? Space( gnLMarg ); ?? "LD: Izvjestaj na dan", Date()
      ? Space( gnLMarg ); IspisFirme( "" )
      ?
      IF Empty( cidrj )
         ? "Pregled za sve RJ ukupno:"
      ELSE
         ? "RJ:", cidrj + " - " + Ocitaj( F_RJ, cIdRj, "naz" )
      ENDIF
      ?? "  Mjesec:", IF( Empty( cMjesec ), "SVI", Str( cmjesec, 2 ) ) + IspisObr()
      ?? "    Godina:", IF( Empty( cGodina ), "SVE", Str( cGodina, 5 ) )
      ?
      ? "------------------------------"
      ? "   SPECIFIKACIJA NOVCANICA"
#ifdef CPOR
      IF lIsplaceni
         ? "  POTREBNIH ZA ISPLATU PLATA"
      ELSE
         ? "PREOSTALIH OD NEISPLACEN.PLATA"
      ENDIF
#else
      ? "  POTREBNIH ZA ISPLATU PLATA"
#endif
      ? "------------------------------"
      ?

      m := REPL( "-", 10 ) + " " + REPL( "-", 6 ) + " " + REPL( "-", 12 )
      ? m
      ? PadC( "APOEN", 10 ), PadC( "BROJ", 6 ), PadC( "IZNOS", 12 )
      ? m
      FOR i := 1 TO Len( aApoeni )
         ? PadC( AllTrim( Str( aApoeni[ i ] ) ), 10 ), PadC( AllTrim( Str( aNovc[ i ] ) ), 6 ), Str( aApoeni[ i ] * aNovc[ i ], 12, 2 )
         nUkupno += ( aApoeni[ i ] * aNovc[ i ] )
      NEXT
      ? m
      ? PadR( "UKUPNO:", 18 ) + Str( nUkupno, 12, 2 )
      ? m
      ?
      FF
      END PRINT

   ENDIF

   CLOSERET

FUNCTION FFor5()

   LOCAL nPom := 0, i := 0

   cIdRadn := IDRADN
   cNaziv := Ocitaj( F_RADN, cIdRadn, "TRIM(NAZ)+' '+TRIM(IME)" )
   nPom := 0
   DO WHILE !Eof() .AND. cIdRadn == IDRADN
      nPom += uiznos
      SKIP 1
   ENDDO
   SKIP -1

   FOR i := 1 TO Len( aApSort )
      IF Str( nPom, 12, 2 ) >= Str( aApSort[ i, 1 ], 12, 2 )
         aNovc[ aApSort[ i, 2 ] ] := Int( Round( nPom, 2 ) / Round( aApSort[ i, 1 ], 2 ) )
         nPom := nPom - aNovc[ aApSort[ i, 2 ] ] * aApSort[ i, 1 ]
      ELSE
         aNovc[ aApSort[ i, 2 ] ] := 0
      ENDIF
   NEXT

   RETURN .T.



STATIC FUNCTION FSvaki5()
   RETURN



// radnici po opstinama stanovanja
// -------------------------------
FUNCTION SpRadOpSt()

   LOCAL nC1 := 20

   cIdRadn := Space( _LR_ )
   cIdRj := gRj; cmjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun
   cVarSort := "2"

   O_OPS
   O_KBENEF
   O_VPOSLA
   O_LD_RJ
   O_RADN
   O_LD

   O_PARAMS
   PRIVATE cSection := "4", cHistory := " ", aHistory := {}
   RPar( "VS", @cVarSort )

   PRIVATE cKBenef := " ", cVPosla := "  "

   Box(, 8, 50 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cmjesec  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Koeficijent benef.radnog staza (prazno-svi): "  GET  cKBenef VALID Empty( cKBenef ) .OR. P_KBenef( @cKBenef )
   @ m_x + 5, m_y + 2 SAY "Vrsta posla (prazno-svi): "  GET  cVPosla
   @ m_x + 8, m_y + 2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort $ "12"  PICT "9"
   read; clvbox(); ESC_BCR
   BoxC()

   WPar( "VS", cVarSort )
   SELECT PARAMS; USE

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
   // CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
   // CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")
   IF Empty( cidrj )
      cidrj := ""
      IF cVarSort == "1"
         Box(, 2, 30 )
         nSlog := 0; nUkupno := RECCOUNT2()
         cSort1 := "SortOpSt(IDRADN)+idradn"
         cFilt := IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
         IF lViseObr .AND. !Empty( cObracun )
            cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ELSE
         Box(, 2, 30 )
         nSlog := 0; nUkupno := RECCOUNT2()
         cSort1 := "SortOpSt(IDRADN)+SortPrez(IDRADN)"
         cFilt := IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
         IF lViseObr .AND. !Empty( cObracun )
            cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ELSE
      IF cVarSort == "1"
         Box(, 2, 30 )
         nSlog := 0; nUkupno := RECCOUNT2()
         cSort1 := "SortOpSt(IDRADN)+idradn"
         cFilt := "IDRJ==cIdRj.and." + ;
            IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
         IF lViseObr .AND. !Empty( cObracun )
            cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ELSE
         Box(, 2, 30 )
         nSlog := 0; nUkupno := RECCOUNT2()
         cSort1 := "SortOpSt(IDRADN)+SortPrez(IDRADN)"
         cFilt := "IDRJ==cIdRj.and." + ;
            IF( Empty( cMjesec ), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==cGodina" )
         IF lViseObr .AND. !Empty( cObracun )
            cFilt += ( ".and. OBR==" + cm2str( cObracun ) )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ENDIF


   EOF CRET

   nStrana := 0

   m := "----- ------ ---------------------------------- ------- ----------- ----------- -----------"

   bZagl := {|| ZSRO() }

   SELECT ld_rj; hseek ld->idrj; SELECT ld

   START PRINT CRET
   P_12CPI

   Eval( bZagl )

   nRbr := 0
   nT2a := nT2b := 0
   nT1 := nT2 := nT3 := nT3b := nT4 := 0
   nVanP := 0  // van neta plus
   nVanM := 0  // van neta minus

   DO WHILE !Eof()

      cTekOpSt := SortOpSt( IDRADN )
      SELECT OPS; SEEK cTekOpSt
      ?
      ? "OPSTINA STANOVANJA: " + ID + " - " + NAZ
      ? "-----------------------------------------------"
      SELECT LD

      nRbr := 0
      nT2a := nT2b := 0
      nT1 := nT2 := nT3 := nT3b := nT4 := 0
      nVanP := 0  // van neta plus
      nVanM := 0  // van neta minus

      DO WHILE !Eof() .AND. SortOpSt( IDRADN ) == cTekOpSt

         IF lViseObr
            ScatterS( godina, mjesec, idrj, idradn )
         ELSE
            Scatter()
         ENDIF

         SELECT radn; hseek _idradn
         SELECT vposla; hseek _idvposla
         SELECT kbenef; hseek vposla->idkbenef
         SELECT ld
         IF !Empty( cvposla ) .AND. cvposla <> Left( _idvposla, 2 )
            skip; LOOP
         ENDIF
         IF !Empty( ckbenef ) .AND. ckbenef <> kbenef->id
            skip; LOOP
         ENDIF

         nVanP := 0
         nVanM := 0
         FOR i := 1 TO cLDPolja
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
            SELECT tippr; SEEK cPom; SELECT ld

            IF tippr->( Found() ) .AND. tippr->aktivan == "D"
               nIznos := _i&cpom
               IF tippr->uneto == "N" .AND. nIznos <> 0
                  IF nIznos > 0
                     nVanP += nIznos
                  ELSE
                     nVanM += nIznos
                  ENDIF
               ELSEIF tippr->uneto == "D" .AND. nIznos <> 0
               ENDIF
            ENDIF
         NEXT

         IF PRow() > RPT_PAGE_LEN + gPStranica; FF; Eval( bZagl ); ENDIF
         ? Str( ++nRbr, 4 ) + ".", idradn, RADNIK
         nC1 := PCol() + 1
         @ PRow(), PCol() + 1 SAY _usati  PICT gpics
         @ PRow(), PCol() + 1 SAY _uneto  PICT gpici
         @ PRow(), PCol() + 1 SAY nVanP + nVanM   PICT gpici
         @ PRow(), PCol() + 1 SAY _uiznos PICT gpici

         nT1 += _usati
         nT2 += _uneto; nT3 += nVanP; nT3b += nVanM; nT4 += _uiznos

         SKIP 1

      ENDDO


      IF PRow() > 60 + gpStranica; FF; Eval( bZagl ); ENDIF
      ? m
      ? " UKUPNO:"
      @ PRow(), nC1 SAY  nT1 PICT gpics
      @ PRow(), PCol() + 1 SAY  nT2 PICT gpici
      @ PRow(), PCol() + 1 SAY  nT3 + nT3b PICT gpici
      @ PRow(), PCol() + 1 SAY  nT4 PICT gpici
      ? m

   ENDDO

   FF
   END PRINT

   CLOSERET



   // **********************

FUNCTION ZSRO()

   // LD
   // **********************
   P_COND
   ? Upper( gTS ) + ":", gnFirma
   ?
   IF Empty( cidrj )
      ? "Pregled za sve RJ ukupno:"
   ELSE
      ? "RJ:", cidrj, ld_rj->naz
   ENDIF
   ?? "  Mjesec:", Str( cmjesec, 2 ) + IspisObr()
   ?? "    Godina:", Str( cGodina, 5 )
   DevPos( PRow(), 74 )
   ?? "Str.", Str( ++nStrana, 3 )
   IF !Empty( cvposla )
      ? "Vrsta posla:", cvposla, "-", vposla->naz
   ENDIF
   IF !Empty( cKBenef )
      ? "Stopa beneficiranog r.st:", ckbenef, "-", kbenef->naz, ":", kbenef->iznos
   ENDIF
   ? m
   ? " Rbr * Sifra*         Naziv radnika            *  Sati *   Neto    *  Odbici   * ZA ISPLATU*"
   ? "     *      *                                  *       *           *           *           *"
   ? m

   RETURN



FUNCTION SortOpSt( cId )

   LOCAL cVrati := "", nArr := Select()

   SELECT RADN
   HSEEK cId
   cVrati := IdOpsSt
   SELECT ( nArr )

   RETURN cVrati


FUNCTION ld_pregled_obr_doprinosa()

   LOCAL cTipRada := " "

   cIdRj    := gRj
   cGodina  := gGodina
   cObracun := gObracun
   cMjesecOd := cMjesecDo := gMjesec
   cObracun := " "
   cDopr   := "3X;"
   cNazDopr := "ZDRAVSTVENO OSIGURANJE"
   cPoOps := "S"

   O_PAROBR
   O_LD_RJ
   O_OPS
   O_RADN
   O_LD
   O_POR
   O_DOPR

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " ", aHistory := {}

   cMjesecOd := Str( cMjesecOd, 2 )
   cMjesecDo := Str( cMjesecDo, 2 )
   cGodina   := Str( cGodina,4 )

   RPar( "p1", @cMjesecOd )
   RPar( "p2", @cMjesecDo )
   RPar( "p3", @cGodina  )
   RPar( "p4", @cIdRj    )
   RPar( "p5", @cDopr    )
   RPar( "p6", @cNazDopr )
   RPar( "p7", @cPoOps )

   cMjesecOd := Val( cMjesecOd )
   cMjesecDo := Val( cMjesecDo )
   cGodina   := Val( cGodina  )
   cDopr     := PadR( cDopr, 40 )
   cNazDopr  := PadR( cNazDopr, 40 )

   Box( "#Uslovi za izvjestaj o obracunatim doprinosima", 8, 75 )
   @ m_x + 1, m_y + 2   SAY "Tip rada: "   GET cTipRada VALID val_tiprada( cTipRada )
   @ m_x + 2, m_y + 2   SAY "Radna jedinica (prazno-sve): "   GET cIdRJ
   @ m_x + 3, m_y + 2   SAY "Mjesec od: "                     GET cMjesecOd PICT "99"
   @ m_x + 3, Col() + 2 SAY "do"                              GET cMjesecDo PICT "99"
   @ m_x + 4, m_y + 2   SAY "Godina: "                        GET cGodina   PICT "9999"
   @ m_x + 4, Col() + 2 SAY "Obracun: "                       GET cObracun
   @ m_x + 5, m_y + 2   SAY "Doprinosi (npr. '3X;')"          GET cDopr PICT "@!"
   @ m_x + 6, m_y + 2   SAY "Obracunati doprinosi za (naziv)" GET cNazDopr PICT "@!"
   @ m_x + 7, m_y + 2   SAY "Po kantonu (S-stanovanja,R-rada)" GET cPoOps VALID cPoOps $ "SR" PICT "@!"
   READ; ESC_BCR
   BoxC()

   cMjesecOd := Str( cMjesecOd, 2 )
   cMjesecDo := Str( cMjesecDo, 2 )
   cGodina   := Str( cGodina,4 )
   cDopr     := Trim( cDopr )
   cNazDopr  := Trim( cNazDopr )

   WPar( "p1", cMjesecOd )
   WPar( "p2", cMjesecDo )
   WPar( "p3", cGodina  )
   WPar( "p4", cIdRj    )
   WPar( "p5", cDopr    )
   WPar( "p6", cNazDopr )
   WPar( "p7", cPoOps )
   SELECT PARAMS; USE

   cMjesecOd := Val( cMjesecOd )
   cMjesecDo := Val( cMjesecDo )
   cGodina   := Val( cGodina  )

   SELECT RADN
   IF cPoOps == "R"
      SET RELATION TO idopsrad INTO ops
   ELSE
      SET RELATION TO idopsst INTO ops
   ENDIF
   SELECT LD
   SET RELATION TO idradn INTO radn

   cSort := "OPS->idkan+SortPre2()+str(mjesec)"
   cFilt := "godina==cGodina .and. mjesec>=cMjesecOd .and. mjesec<=cMjesecDo"

   IF cDopr == "71;"
      cFilt += " .and. radn->k4 = 'BF'"
   ENDIF

   IF gVarObracun == "2"
      IF Empty( cTipRada )
         cFilt += " .and. radn->tiprada $ ' #N#I' "
      ELSE
         cFilt += " .and. radn->tiprada == " + cm2str( cTipRada )
      ENDIF
   ENDIF

   IF !Empty( cIdRj )
      cFilt += " .and. idrj=cIdRJ"
   ENDIF

   INDEX ON &cSort TO "tmpld" FOR &cFilt

   GO TOP
   IF Eof()
      MsgBeep( "Nema podataka!" )
      CLOSERET
   ENDIF

   START PRINT CRET
   gOstr := "D"; gTabela := 1
   cKanton := cRadnik := ""; lSubTot7 := .F. ; cSubTot7 := ""

   aKol := { { "PREZIME (IME RODITELJA) IME", {|| cRadnik   }, .F., "C", 32, 0, 1, 1 } }

   nKol := 1
   FOR i := cMjesecOd TO cMjesecDo
      cPom := "xneto" + AllTrim( Str( i ) )
      &cPom := 0
      AAdd( aKol, { ld_naziv_mjeseca( i ), {|| &cPom. }, .T., "N", 9, 2, 1, ++nKol } )
      cPom := "xdopr" + AllTrim( Str( i ) )
      &cPom := 0
      AAdd( aKol, { "NETO/DOPR", {|| &cPom. }, .T., "N", 9, 2, 2,   nKol } )
   NEXT

   xnetoUk := xdoprUk := 0
   AAdd( aKol, { "UKUPNO", {|| xnetoUk }, .T., "N", 10, 2, 1, ++nKol } )
   AAdd( aKol, { "NETO/DOPR", {|| xdoprUk }, .T., "N", 10, 2, 2,   nKol } )

   P_10CPI
   ?? gnFirma
   ?
   ? "Mjesec: od", Str( cMjesecOd, 2 ) + ".", "do", Str( cMjesecDo, 2 ) + "."
   ?? "    Godina:", Str( cGodina, 4 )
   ? "Obuhvacene radne jedinice: "; ?? IF( !Empty( cIdRJ ), "'" + cIdRj + "'", "SVE" )
   ? "Obuhvaceni doprinosi (sifre):", "'" + cDopr + "'"
   ?

   SELECT LD

   StampaTabele( aKol, {|| FSvaki7() },, gTabela,, ;
      , "IZVJESTAJ O OBRACUNATIM DOPRINOSIMA ZA " + cNazDopr, ;
      {|| FFor7() }, IF( gOstr == "D",, -1 ),,, {|| SubTot7() },, )
   FF

   END PRINT
   CLOSERET

STATIC FUNCTION FFor7()

   IF OPS->idkan <> cKanton .AND. Len( cKanton ) > 0
      lSubTot7 := .T.
      cSubTot7 := cKanton
   ENDIF

   cKanton := OPS->idkan
   xNetoUk := xDoprUk := 0
   cRadnik := RADN->( PadR(  Trim( naz ) + " (" + Trim( imerod ) + ") " + ime, 32 ) )
   cIdRadn := IDRADN
   nKLO := 0
   cTipRada := ""

   IF gVarObracun == "2"
      nKLO := radn->klo
      cTipRada := g_tip_rada( ld->idradn, ld->idrj )
   ENDIF

   FOR i := cMjesecOd TO cMjesecDo
      cPom := "xneto" + AllTrim( Str( i ) ); &cPom := 0
      cPom := "xdopr" + AllTrim( Str( i ) ); &cPom := 0
   NEXT

   DO WHILE !Eof() .AND. OPS->idkan == cKanton .AND. IDRADN == cIdRadn
      nTekMjes := mjesec
      _uneto := 0
      DO WHILE !Eof() .AND. OPS->idkan == cKanton .AND. IDRADN == cIdRadn .AND. mjesec == nTekMjes
         _uneto += uneto
         SKIP 1
      ENDDO
      SKIP -1
      // neto
      cPom    := "xneto" + AllTrim( Str( mjesec ) )
      &cPom   := _uneto
      xnetoUk += _uneto
      // doprinos
      PoDoIzSez( godina, mjesec )
      nDopr   := IzracDopr( cDopr, nKLO, cTipRada )
      cPom    := "xdopr" + AllTrim( Str( mjesec ) )
      &cPom   := nDopr
      xdoprUk += nDopr
      SKIP 1
   ENDDO

   SKIP -1

   RETURN .T.


STATIC FUNCTION FSvaki7()
   RETURN


STATIC FUNCTION SubTot7()

   LOCAL aVrati := { .F., "" }

   IF lSubTot7 .OR. Eof()
      aVrati := { .T., "UKUPNO KANTON '" + IF( Eof(), cKanton, cSubTot7 ) + "'" }
      lSubTot7 := .F.
   ENDIF

   RETURN aVrati


// ------------------------------------------
// izracunava doprinose
// ------------------------------------------
FUNCTION IzracDopr( cDopr, nKLO, cTipRada, nSpr_koef )

   LOCAL nArr := Select(), nDopr := 0, nPom := 0, nPom2 := 0, nPom0 := 0, nBO := 0, nBFOsn := 0
   LOCAL _a_benef := {}

   IF nKLO == nil
      nKLO := 0
   ENDIF

   IF cTipRada == nil
      cTipRada := ""
   ENDIF

   IF nSPr_koef == nil
      nSPr_koef := 0
   ENDIF

   ParObr( mjesec, godina, IF( lViseObr, cObracun, ), cIdRj )

   IF gVarObracun == "2"

      nBo := bruto_osn( Max( _UNeto, PAROBR->prosld * gPDLimit / 100 ), cTipRada, nKlo, nSPr_koef )

      IF UBenefOsnovu()

         IF !Empty( gBFForm )
            gBFForm := StrTran( gBFForm, "_", "" )
         ENDIF

         nBFOsn := bruto_osn( _UNeto - IF( !Empty( gBFForm ), &gBFForm, 0 ), cTipRada, nKlo, nSPr_koef )

         _benef_st := BenefStepen()
         add_to_a_benef( @_a_benef, AllTrim( radn->k3 ), _benef_st, nBFOsn )

      ENDIF

      IF cTipRada $ " #I#N"
         // minimalni bruto osnov
         IF calc_mbruto()
            nBo := min_bruto( nBo, ld->usati )
         ENDIF
      ENDIF

   ELSE
      nBo := round2( parobr->k3 / 100 * Max( _UNeto, PAROBR->prosld * gPDLimit / 100 ), gZaok2 )
   ENDIF

   SELECT DOPR
   GO TOP

   DO WHILE !Eof()

      IF gVarObracun == "2"
         IF cTipRada $ "I#N" .AND. Empty( dopr->tiprada )
            // ovo je uredu !
         ELSEIF dopr->tiprada <> cTipRada
            SKIP 1
            LOOP
         ENDIF
      ENDIF

      IF !( id $ cDopr )
         SKIP 1
         LOOP
      ENDIF

      PozicOps( DOPR->poopst )   // ? mozda ovo rusi koncepciju zbog sorta na LD-u

      IF !ImaUOp( "DOPR", DOPR->id )
         SKIP 1
         LOOP
      ENDIF

      IF !Empty( dopr->idkbenef )
         // beneficirani
         nPom := Max( dlimit, Round( iznos / 100 * get_benef_osnovica( _a_benef, dopr->idkbenef ), gZaok2 ) )
      ELSE
         nPom := Max( dlimit, Round( iznos / 100 * nBO, gZaok2 ) )
      ENDIF

      IF Round( iznos, 4 ) = 0 .AND. dlimit > 0
         // fuell boss
         // kartica plate
         nPom := 1 * dlimit
      ENDIF

      nDopr += nPom

      // resetuj matricu a_benef, posto nam treba za radnika
      _a_benef := {}

      SKIP 1

   ENDDO

   SELECT ( nArr )

   RETURN ( nDopr )


FUNCTION SortPre2()
   RETURN ( RADN->( naz + ime + imerod ) + idradn )



STATIC FUNCTION _specpr_o_tbl()

   O_TIPPR
   O_KRED
   O_RADKR
   SET ORDER TO TAG "1"
   O_LD_RJ
   O_RADN
   O_LD

   RETURN



FUNCTION SpecPrimRJ()

   LOCAL _alias, _table_name

   cGodina  := gGodina
   cMjesecOd := cMjesecDo := gMjesec
   cObracun := " "
   qqRj := ""
   qqPrimanja := ""

   _specpr_o_tbl()

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " ", aHistory := {}

   cMjesecOd := Str( cMjesecOd, 2 )
   cMjesecDo := Str( cMjesecDo, 2 )
   cGodina   := Str( cGodina,4 )

   RPar( "p1", @cMjesecOd )
   RPar( "p2", @cMjesecDo )
   RPar( "p3", @cGodina   )
   RPar( "p8", @qqRj      )
   RPar( "p9", @cObracun  )
   RPar( "pA", @qqPrimanja )

   cMjesecOd := Val( cMjesecOd )
   cMjesecDo := Val( cMjesecDo )
   cGodina   := Val( cGodina  )
   qqRj      := PadR( qqRj, 40 )
   qqPrimanja := PadR( qqPrimanja, 100 )

   DO WHILE .T.
      Box( "#Uslovi za specifikaciju primanja po radnim jedinicama", 8, 75 )
      @ m_x + 2, m_y + 2   SAY "Radne jedinice (prazno-sve): "   GET qqRj PICT "@S20"
      @ m_x + 3, m_y + 2   SAY "Mjesec od: "                     GET cMjesecOd PICT "99"
      @ m_x + 3, Col() + 2 SAY "do"                              GET cMjesecDo PICT "99"
      @ m_x + 4, m_y + 2   SAY "Godina: "                        GET cGodina   PICT "9999"
      IF lViseObr
         @ m_x + 4, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      ENDIF
      @ m_x + 5, m_y + 2   SAY "Sifre primanja (prazno-sve):"   GET qqPrimanja PICT "@S30"
      READ
      ESC_BCR
      BoxC()
      aUslRJ   := Parsiraj( qqRj, "IDRJ" )
      aUslPrim := Parsiraj( qqPrimanja, "cIDPRIM" )
      IF aUslRJ <> NIL
         EXIT
      ENDIF
   ENDDO

   cMjesecOd := Str( cMjesecOd, 2 )
   cMjesecDo := Str( cMjesecDo, 2 )
   cGodina   := Str( cGodina,4 )
   qqRj      := Trim( qqRj )
   qqPrimanja := Trim( qqPrimanja )

   WPar( "p1", cMjesecOd )
   WPar( "p2", cMjesecDo )
   WPar( "p3", cGodina   )
   WPar( "p8", qqRj      )
   RPar( "p9", cObracun  )
   WPar( "pA", qqPrimanja )
   SELECT PARAMS
   USE

   cMjesecOd := Val( cMjesecOd )
   cMjesecDo := Val( cMjesecDo )
   cGodina   := Val( cGodina  )

   _alias := "LDT22"
   _table_name := "ldt22"

   // pravim pomocnu bazu LDT22.DBF
   // -----------------------------
   aDbf := {    { "IDPRIM",  "C",  2, 0 },;
      { "IDKRED",  "C",  6, 0 },;
      { "IDRJ",  "C",  2, 0 },;
      { "IZNOS",  "N", 18, 4 } ;
      }

   DBCREATE2( f18_ime_dbf( _table_name ), aDbf )

   SELECT F_LDT22
   my_usex( _alias )

   CREATE_INDEX( "1", "idprim+idkred+idrj", _alias )
   USE

   _specpr_o_tbl()
   O_LDT22

   SET ORDER TO TAG "1"
   // -----------------------------

   aPrim  := {}       // standardna primanja
   aPrimK := {}       // primanja kao npr. krediti

   O_TIPPR

   FOR i := 1 TO cLDPolja
      cIDPRIM := PadL( AllTrim( Str( i ) ), 2, "0" )
      IF &aUslPrim
         IF "SUMKREDITA" $ Ocitaj( F_TIPPR, cIdPrim, "formula" )
            AAdd( aPrimK, "I" + cIdPrim )
         ELSE
            AAdd( aPrim, "I" + cIdPrim )
         ENDIF
      ENDIF
   NEXT

   PRIVATE cFilt := ".t."
   IF !Empty( qqRJ )    ; cFilt += ( ".and." + aUslRJ )                ; ENDIF
   IF !Empty( cObracun ); cFilt += ( ".and. OBR==" + cm2str( cObracun ) ); ENDIF
   IF cMjesecOd != cMjesecDo
      cFilt := cFilt + ".and.mjesec>=" + cm2str( cMjesecOd ) + ;
         ".and.mjesec<=" + cm2str( cMjesecDo ) + ;
         ".and.godina=" + cm2str( cGodina )
   ELSE
      cFilt := cFilt + ".and.mjesec=" + cm2str( cMjesecOd ) + ;
         ".and.godina=" + cm2str( cGodina )
   ENDIF

   SELECT LD
   SET FILTER TO &cFilt
   GO TOP
   aRJ := {}
   DO WHILE !Eof()
      // prolaz kroz standardna primanja
      // -------------------------------
      FOR i := 1 TO Len( aPrim )
         SELECT LD; nPom := &( aPrim[ i ] )
         SELECT LDT22; SEEK Right( aPrim[ i ], 2 ) + Space( 6 ) + LD->IDRJ
         IF Found()
            REPLACE iznos WITH iznos + nPom
         ELSE
            APPEND BLANK
            REPLACE idprim  WITH Right( aPrim[ i ], 2 ), ;
               idkred  WITH Space( 6 ),;
               idrj    WITH LD->IDRJ,;
               iznos   WITH iznos + nPom
            IF AScan( aRJ, {| x| x[ 1 ] == idrj } ) <= 0
               AAdd( aRJ, { idrj, 0 } )
            ENDIF
         ENDIF
         SELECT LD
      NEXT
      // prolaz kroz kredite
      // -------------------
      FOR i := 1 TO Len( aPrimK )
         SELECT LD; cKljuc := Str( godina, 4 ) + Str( mjesec, 2 ) + idradn
         SELECT RADKR; SEEK cKljuc
         IF Found()
            DO WHILE !Eof() .AND. Str( godina, 4 ) + Str( mjesec, 2 ) + idradn == cKljuc
               cIdKred := idkred
               nPom := 0
               DO WHILE !Eof() .AND. Str( godina, 4 ) + Str( mjesec, 2 ) + idradn + idkred == cKljuc + cIdKred
                  nPom += placeno
                  SKIP 1
               ENDDO
               nPom := -nPom      // kredit je odbitak
               SELECT LDT22; SEEK Right( aPrimK[ i ], 2 ) + cIdKred + LD->IDRJ
               IF Found()
                  REPLACE iznos WITH iznos + nPom
               ELSE
                  APPEND BLANK
                  REPLACE idprim  WITH Right( aPrimK[ i ], 2 ), ;
                     idkred  WITH cIdKred,;
                     idrj    WITH LD->IDRJ,;
                     iznos   WITH iznos + nPom
                  IF AScan( aRJ, {| x| x[ 1 ] == idrj } ) <= 0
                     AAdd( aRJ, { idrj, 0 } )
                  ENDIF
               ENDIF
               SELECT RADKR
            ENDDO
         ENDIF
      NEXT
      SELECT LD; SKIP 1
   ENDDO

   START PRINT CRET
   gOstr := "D"; gTabela := 1
   cPrimanje := ""; nUkupno := 0
   nKol := 0

   aKol := { { "PRIMANJE", {|| cPrimanje }, .F., "C", 40, 0, 1, ++nKol } }

   // radne jedinice
   ASort( aRJ,,, {| x, y| x[ 1 ] < y[ 1 ] } )
   FOR i := 1 TO Len( aRJ )
      cPom := AllTrim( Str( i ) )
      AAdd( aKol, { "RJ " + aRJ[ i, 1 ], {|| aRJ[ &cPom., 2 ] }, .T., "N", 15, 2, 1, ++nKol  } )
   NEXT

   // ukupno
   AAdd( aKol, { "UKUPNO", {|| nUkupno }, .T., "N", 15, 2, 1, ++nKol } )

   P_10CPI
   ?? gnFirma
   ?
   ? "Mjesec: od", Str( cMjesecOd, 2 ) + ".", "do", Str( cMjesecDo, 2 ) + "."
   ?? "    Godina:", Str( cGodina, 4 )
   ? "Obuhvacene radne jedinice  :", IF( !Empty( qqRJ ), "'" + qqRj + "'", "SVE" )
   ? "Obuhvacena primanja (sifre):", "'" + qqPrimanja + "'"
   ?

   SELECT LDT22; GO TOP

   StampaTabele( aKol,,, gTabela,, ;
      , "SPECIFIKACIJA PRIMANJA PO RADNIM JEDINICAMA", ;
      {|| FFor8() }, IF( gOstr == "D",, -1 ),,,,, )
   FF

   END PRINT
   CLOSERET

FUNCTION FFor8()

   LOCAL i, nPos, cIdPrim, cIdKred, cIdRj

   IF Empty( idkred )
      cPrimanje := idprim + "-" + Ocitaj( F_TIPPR, idprim, "naz" )
   ELSE
      cPrimanje := idprim + "-" + idkred + "-" + Ocitaj( F_KRED, idkred, "naz" )
   ENDIF
   cIdPrim := idprim
   cIdKred := idkred
   FOR i := 1 TO Len( aRJ ); aRJ[ i, 2 ] := 0; NEXT
   nUkupno := 0
   DO WHILE !Eof() .AND. cIdPrim + cIdKred == idprim + idkred
      cIdRJ := idrj
      nPos := AScan( aRJ, {| x| x[ 1 ] == cIdRj } )
      DO WHILE !Eof() .AND. cIdPrim + cIdKred + cIdRj == idprim + idkred + idrj
         aRJ[ nPos, 2 ] += iznos
         nUkupno     += iznos
         SKIP 1
      ENDDO
   ENDDO
   SKIP -1

   RETURN .T.


// ----------------
// REKapitulacija
// TEKucih
// RACuna
// ----------------
FUNCTION RekTekRac()

   LOCAL nC1 := 20, i
   LOCAL cTPNaz, nKrug := 1

   gnLMarg := 0; gTabela := 1; gOstr := "D"; cOdvLin := "D"

   cIdRj := gRj; cmjesec := gMjesec; cGodina := gGodina
   cObracun := gObracun
   cMjesecDo := cMjesec
   cNacinIsplate := "S"
   cZaIsplatu := "N"

   qqPrikPrim := ""

   O_PAROBR
   O_LD_RJ
   O_RADN
   O_KBENEF
   O_VPOSLA
   O_RADKR
   O_KRED

   cIdBanke := Space( Len( id ) )

   O_LD

   FOR i := 1 TO 100
      IF FieldPos( "I" + Right( "00" + AllTrim( Str( i ) ), 2 ) ) == 0; nPoljaPr := i - 1; EXIT; ENDIF
      nPoljaPr := i
   NEXT

   cIdRadn := Space( _LR_ )

   qqRJ := Space( 60 )
   Box( "#REKAPITULACIJA NACINA ISPLATE PO RADNIM JEDINICAMA I PRIMANJIMA", 13, 75 )

   O_PARAMS
   PRIVATE cSection := "4", cHistory := " ", aHistory := {}
   RPar( "pp", @qqPrikPrim )
   RPar( "tt", @gTabela )

   qqPrikPrim := PadR( qqPrikPrim, 80 )
   cTRSamoUk := "N"

   DO WHILE .T.
      @ m_x + 3, m_y + 2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
      @ m_x + 4, m_y + 2 SAY "Za mjesece od:"  GET  cmjesec  PICT "99" VALID {|| cMjesecDo := cMjesec, .T. }
      @ m_x + 4, Col() + 2 SAY "do:"  GET  cMjesecDo  PICT "99" VALID cMjesecDo >= cMjesec
      IF lViseObr
         @ m_x + 4, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      ENDIF
      @ m_x + 5, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
      @ m_x + 7, m_y + 2 SAY "Nacin isplate (S-svi,B-blagajna,T-tekuci racun)"  GET cNacinIsplate VALID cNacinIsplate $ "SBT" PICT "@!"
      @ m_x + 8, m_y + 2 SAY "Banka (prazno-sve): "  GET  cIdBanke PICT "@!" WHEN cNacinIsplate == "T" VALID Empty( cIdBanke ) .OR. P_Kred( @cIdBanke )
      @ m_x + 10, m_y + 2 SAY "Primanja za prikaz (npr.06;22;23;) "  GET  qqPrikPrim PICT "@S30"
      @ m_x + 11, m_y + 2 SAY "Prikazati iznos za isplatu? (D/N)"  GET cZaIsplatu VALID cZaIsplatu $ "DN" PICT "@!"
      @ m_x + 12, m_y + 2 SAY "Tip tabele (0/1/2)"  GET  gTabela VALID gTabela >= 0 .AND. gTabela <= 2 PICT "9"

      read; clvbox(); ESC_BCR
      aUsl1 := Parsiraj( qqRJ, "IDRJ" )
      aUsl2 := Parsiraj( qqRJ, "ID" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL; exit; ENDIF
   ENDDO

   IF cNacinIsplate == "S" .OR. cNacinIsplate == "T" .AND. Empty( cIdBanke )
      cTRSamoUk := Pitanje(, "Prikazati samo ukupno za sve tekuce racune? (D/N)", "N" )
   ENDIF

   SELECT PARAMS
   qqPrikPrim := Trim( qqPrikPrim )
   WPar( "pp", qqPrikPrim )
   WPar( "tt", gTabela )
   SELECT PARAMS; USE

   BoxC()

   tipprn_use()

   SELECT LD

   IF lViseObr
      cObracun := Trim( cObracun )
   ELSE
      cObracun := ""
   ENDIF

   // CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")
   SET ORDER TO tag ( TagVO( "2" ) )

   PRIVATE cFilt1 := ""
   cFilt1 := ".t." + IF( Empty( qqRJ ), "", ".and." + aUsl1 )

   IF lViseObr
      cFilt1 += ".and. OBR=" + cm2str( cObracun )
   ENDIF

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF cFilt1 == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilt1
   ENDIF

   SET RELATION TO idradn INTO RADN

   SEEK Str( cGodina, 4 ) + Str( cmjesec, 2 ) + cObracun
   EOF CRET

   nStrana := 0

   aVar := {}
   FOR i := 1 TO nPoljaPr
      cPom := Right( "00" + AllTrim( Str( i ) ), 2 )
      IF cPom $ qqPrikPrim
         AAdd( aVar, "I" + cPom )
      ENDIF
   NEXT
   AAdd( aVar, "UNETO" )
   IF ( cZaIsplatu == "D" )
      AAdd( aVar, "UIZNOS" )
   ENDIF

   CreREKNI( aVar )
   SELECT LD

   DO WHILE !Eof() .AND. godina == cGodina .AND. mjesec >= cMjesec .AND. mjesec <= cMjesecDo

      IF cNacinIsplate == "T" .AND. ( RADN->isplata <> "TR" .OR. ;
            !Empty( cIdBanke ) .AND. ;
            cIdBanke <> RADN->idbanka ) .OR. ;
            cNacinIsplate == "B" .AND. RADN->isplata == "TR"
         SKIP 1
         LOOP
      ENDIF

      cRJ := IDRJ
      IF RADN->isplata == "TR"
         cNIsplate := "TR" + IF( cTRSamoUk == "D", Space( 6 ), RADN->idbanka )
      ELSE
         cNIsplate := "BL" + Space( 6 )
      ENDIF

      SELECT REKNI
      HSEEK cNIsplate + cRJ
      IF !Found()
         APPEND BLANK
         Scatter()
         _NI   := cNIsplate
         _IDRJ := cRJ
      ELSE
         Scatter()
      ENDIF

      FOR i := 1 TO Len( aVar )
         cPom := aVar[ i ]
         _&cPom += LD->( &cPom )
      NEXT

      Gather()
      SELECT LD

      SKIP 1
   ENDDO

   aKol := {}
   nKol := 0
   AAdd( aKol, { "RJ", {|| IDRJ + "-" + ld_rj->NAZ }, .F., "C", 55, 0, 1, ++nKol } )
   FOR i := 1 TO Len( aVar )
      cPom := aVar[ i ]
      IF cPom = "I" .AND. Len( cPom ) == 3 .AND. ;
            SubStr( cPom, 2, 1 ) $ "0123456789" .AND. SubStr( cPom, 3, 1 ) $ "0123456789"
         cPom2 := SubStr( cPom, 2 ) + "-" + Ocitaj( F_TIPPR, SubStr( cPom, 2 ), "naz" )
         AAdd( aKol, { Left( cPom2, 12 ), {|| &cPom. }, .T., "N-", 12, 2, 1, ++nKol } )
         AAdd( aKol, { SubStr( cPom2, 13 ), {|| "#"   }, .F., "C", 12, 0, 2,   nKol } )
      ELSE
         IF cPom == "UIZNOS"
            AAdd( aKol, { "ZA ISPLATU", {|| &cPom. }, .T., "N-", 12, 2, 1, ++nKol } )
         ELSE
            AAdd( aKol, { cPom, {|| &cPom. }, .T., "N-", 12, 2, 1, ++nKol } )
         ENDIF
      ENDIF
      stot&cPom := 0
   NEXT

   START PRINT CRET

   // -------------------
   B_ON
   ?? "LD: Rekapitulacija dijela primanja po nacinu isplate"
   IF cMjesec == cMjesecDo
      ? "Firma:", gNFirma, "  Mjesec:", Str( cmjesec, 2 ) + IspisObr()
      ?? "    Godina:", Str( cGodina, 4 )
      B_OFF
   ELSE
      ? "Firma:", gNFirma, "  Za mjesece od:", Str( cmjesec, 2 ), "do", Str( cmjesecDo, 2 ) + IspisObr()
      ?? "    Godina:", Str( cGodina, 4 )
      B_OFF
   ENDIF
   ?
   // -------------------

   SELECT REKNI
   SET RELATION TO idrj INTO RJ
   GO TOP

   cNI := ""
   gaSubTotal := {}
   gaDodStavke := {}

   StampaTabele( aKol, {|| .T. },, gTabela, , ;
      ,, ;
      {|| FForRNI() }, IF( gOstr == "D",, -1 ),, cOdvLin == "D",,,, .F. )


   ?
   ? p_potpis()

   FF
   END PRINT

   CLOSERET

FUNCTION FForRNI()

   LOCAL lSubTotal := .F., i := 0, lDodZag := .F.

   lDodZag := ( cNI <> NI )

   cNI := NI
   gaSubTotal  := {}
   gaDodStavke := {}

   SKIP 1
   IF Eof() .OR. NI <> cNI
      lSubTotal := .T.
   ENDIF
   SKIP -1

   FOR i := 1 TO Len( aVar )
      cPom := aVar[ i ]
      stot&cPom += &cPom
   NEXT

   IF lSubTotal
      AAdd( gaSubTotal, { NIL } )
      FOR i := 1 TO Len( aVar )
         cPom := aVar[ i ]
         AAdd( gaSubTotal[ 1 ], stot&cPom )
         stot&cPom := 0
      NEXT
      IF cNI = "TR"
         IF cTRSamoUk == "D"
            cPom := "UKUPNO TEKUCI RACUNI"
         ELSE
            cPom := "UKUPNO T.R." + SubStr( cNI, 3 ) + "-" + Trim( Ocitaj( F_KRED, SubStr( cNI, 3 ), "naz" ) )
         ENDIF
      ELSE
         cPom := "UKUPNO BLAGAJNA"
      ENDIF
      AAdd( gaSubTotal[ 1 ], PadL( AllTrim( cPom ), 55, "*" ) )
   ENDIF

   IF lDodZag
      AAdd( gaDodStavke, {} )
      AAdd( gaDodStavke, {} )
      AAdd( gaDodStavke, {} )
      IF cNI = "TR"
         IF cTRSamoUk == "D"
            cPom := "TEKUCI RACUNI"
         ELSE
            cPom := "T.R." + SubStr( cNI, 3 ) + "-" + Trim( Ocitaj( F_KRED, SubStr( cNI, 3 ), "naz" ) )
         ENDIF
      ELSE
         cPom := "BLAGAJNA"
      ENDIF
      AAdd( gaDodStavke[ 1 ], PadC( AllTrim( cPom ), 55, " " ) )
      AAdd( gaDodStavke[ 2 ], REPL( "=", 55 ) )
      AAdd( gaDodStavke[ 3 ], IDRJ + "-" + ld_rj->NAZ )
      FOR i := 1 TO Len( aVar )
         cPom := aVar[ i ]
         AAdd( gaDodStavke[ 1 ], NIL )
         AAdd( gaDodStavke[ 2 ], NIL )
         AAdd( gaDodStavke[ 3 ], &cPom )
      NEXT
   ENDIF

   RETURN ( !lDodZag )



FUNCTION CreREKNI( aV )

   LOCAL i := 0

   aDbf := {   { "NI","C", 8, 0 }, ;
      { "IDRJ","C", 2, 0 };
      }
   FOR i := 1 TO Len( aV )
      AAdd( aDbf, { aV[ i ], "N", 12, 2 } )
   NEXT
   DBCREATE2( PRIVPATH + "REKNI", aDbf )
   SELECT 0; usex ( PRIVPATH + "REKNI" )
   INDEX ON NI + IDRJ TAG "1"
   INDEX ON  BRISANO TAG "BRISAN"
   USE
   SELECT 0; usex ( PRIVPATH + "REKNI" ) ; SET ORDER TO TAG "1"

   RETURN
