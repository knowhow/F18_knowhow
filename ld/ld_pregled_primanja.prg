/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"


FUNCTION ld_pregled_primanja()

   LOCAL nC1 := 20

   cIdRadn := Space( _LR_ )
   cIdRj := gRj
   cMjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun
   cVarSort := "2"
   lKredit := .F.
   cSifKred := ""

   nRbr := 0
   O_LD_RJ
   O_RADN
   O_LD

   PRIVATE cTip := "  "

   cDod := "N"
   cKolona := Space( 20 )

   O_PARAMS

   PRIVATE cSection := "4"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "VS", @cVarSort )

   Box(, 7, 45 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cMjesec  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Tip primanja: "  GET  cTip
   @ m_x + 5, m_y + 2 SAY "Prikaz dodatnu kolonu: "  GET  cDod PICT "@!" VALID cdod $ "DN"
   @ m_x + 6, m_y + 2 SAY "Sortirati po (1-sifri, 2-prezime+ime)"  GET cVarSort VALID cVarSort $ "12"  PICT "9"
   READ

   clvbox()

   ESC_BCR

   IF cDod == "D"
      @ m_x + 7, m_y + 2 SAY "Naziv kolone:" GET cKolona
      READ
   ENDIF
   ckolona := "radn->" + ckolona

   BoxC()

   WPar( "VS", cVarSort )
   SELECT PARAMS
   USE

   tipprn_use()

   SELECT tippr
   HSEEK cTip


   EOF CRET

   IF "SUMKREDITA" $ formula
      // radi se o kreditu, upitajmo da li je potreban prikaz samo za
      // jednog kreditora
      // ------------------------------------------------------------
      lKredit := .T.
      O_KRED
      cSifKred := Space( Len( id ) )
      Box(, 6, 75 )
      @ m_x + 2, m_y + 2 SAY "Izabrani tip primanja je kredit ili se tretira na isti nacin kao i kredit."
      @ m_x + 3, m_y + 2 SAY "Ako zelite mozete dobiti spisak samo za jednog kreditora."
      @ m_x + 5, m_y + 2 SAY "Kreditor (prazno-svi zajedno)" GET cSifKred  VALID Empty( cSifKred ) .OR. P_Kred( @cSifKred ) PICT "@!"
      READ
      BoxC()
   ENDIF

   IF !Empty( cSifKred )
      O_RADKR
      SET ORDER TO TAG "1"
   ENDIF

   SELECT ld

   IF lViseObr
      cObracun := Trim( cObracun )
   ELSE
      cObracun := ""
   ENDIF

   IF Empty( cIdRJ )

      cidrj := ""
      IF cVarSort == "1"
         SET ORDER TO tag ( TagVO( "2" ) )
         HSEEK Str( cGodina, 4 ) + Str( cMjesec, 2 ) + cObracun
      ELSE
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := IF( Empty( cMjesec ), ".t.", "MJESEC==" + _filter_quote( cMjesec ) ) + ".and." + ;
            IF( Empty( cGodina ), ".t.", "GODINA==" + _filter_quote( cGodina ) )
         IF lViseObr
            cFilt += ".and. OBR=" + _filter_quote( cObracun )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ELSE
      IF cVarSort == "1"
         SET ORDER TO tag ( TagVO( "1" ) )
         HSEEK Str( cGodina, 4 ) + cidrj + Str( cMjesec, 2 ) + cObracun
      ELSE
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := "IDRJ==" + _filter_quote( cIdRj ) + " .and. "
         cFilt += iif( Empty( cMjesec ), ".t.", "MJESEC==" + _filter_quote( cMjesec ) ) + ".and."
         cFilt += iif( Empty( cGodina ), ".t.", "GODINA==" + _filter_quote( cGodina ) )

         IF lViseObr
            cFilt += ".and. OBR ==" + _filter_quote( cObracun )
         ENDIF

         INDEX ON &cSort1 TO "tmpld" FOR &cFilt

         BoxC()
         GO TOP
      ENDIF
   ENDIF

   EOF CRET

   nStrana := 0
   m := "----- " + Replicate( "-", _LR_ ) + " ---------------------------------- " + IF( lKredit .AND. !Empty( cSifKred ), REPL( "-", Len( RADKR->naosnovu ) + 1 ), "-" + REPL( "-", Len( gPicS ) ) ) + " ----------- -----------"
   IF cdod == "D"
      IF Type( ckolona ) $ "UUIUE"
         Msg( "Nepostojeca kolona" )
         closeret
      ENDIF
   ENDIF
   bZagl := {|| ZPregPrim() }

   SELECT ld_rj
   HSEEK ld->idrj
   SELECT ld

   START PRINT CRET
   P_10CPI

   Eval( bZagl )

   nRbr := 0
   nT1 := nT2 := nT3 := nT4 := 0
   nC1 := 10

   DO WHILE !Eof() .AND.  cGodina == godina .AND. idrj = cidrj .AND. cMjesec = mjesec .AND. ;
         !( lViseObr .AND. !Empty( cObracun ) .AND. obr <> cObracun )

      IF lViseObr .AND. Empty( cObracun )
         ScatterS( godina, mjesec, idrj, idradn )
      ELSE
         Scatter()
      ENDIF

      IF lKredit .AND. !Empty( cSifKred )
         // provjerimo da li otplacuje zadanom kreditoru
         // --------------------------------------------
         SELECT RADKR
         SEEK Str( cGodina, 4 ) + Str( cMjesec, 2 ) + LD->idradn + cSifKred
         lImaJos := .F.
         DO WHILE !Eof() .AND. Str( cGodina, 4 ) + Str( cMjesec, 2 ) + LD->idradn + cSifKred == Str( godina, 4 ) + Str( mjesec, 2 ) + idradn + idkred
            IF placeno > 0
               lImaJos := .T.
               EXIT
            ENDIF
            SKIP 1
         ENDDO
         IF !lImaJos
            SELECT LD; SKIP 1; LOOP
         ELSE
            SELECT LD
         ENDIF
      ENDIF

      SELECT radn; HSEEK _idradn; SELECT ld

      DO WHILE .T.

         IF PRow() > RPT_PAGE_LEN + gPStranica
            FF
            Eval( bZagl )
         ENDIF

         IF _i&cTip <> 0 .OR. _s&cTip <> 0
            ? Str( ++nRbr, 4 ) + ".", idradn, RADNIK
            nC1 := PCol() + 1
            IF lKredit .AND. !Empty( cSifKred )
               @ PRow(), PCol() + 1 SAY RADKR->naosnovu
            ELSEIF tippr->fiksan == "P"
               @ PRow(), PCol() + 1 SAY _s&cTip  PICT "999.99"
            ELSE
               @ PRow(), PCol() + 1 SAY _s&cTip  PICT gpics
            ENDIF
            IF lKredit .AND. !Empty( cSifKred )
               @ PRow(), PCol() + 1 SAY -RADKR->placeno  PICT gpici
               nT2 += ( -RADKR->placeno )
            ELSE
               @ PRow(), PCol() + 1 SAY _i&cTip  PICT gpici
               nT1 += _s&cTip; nT2 += _i&cTip
            ENDIF
            IF cdod == "D"
               @ PRow(), PCol() + 1 SAY &ckolona
            ENDIF
         ENDIF
         IF lKredit .AND. !Empty( cSifKred )
            lImaJos := .F.
            SELECT RADKR; SKIP 1
            DO WHILE !Eof() .AND. Str( cGodina, 4 ) + Str( cMjesec, 2 ) + LD->idradn + cSifKred == Str( godina, 4 ) + Str( mjesec, 2 ) + idradn + idkred
               IF placeno > 0
                  lImaJos := .T.
                  EXIT
               ENDIF
               SKIP 1
            ENDDO
            SELECT LD
            IF !lImaJos
               EXIT
            ENDIF
         ELSE
            EXIT
         ENDIF
      ENDDO

      SKIP 1

   ENDDO

   IF PRow() > RPT_PAGE_LEN + gPStranica
      FF
      Eval( bZagl )
   ENDIF
   ? m
   ? Space( 1 ) + Lokal( "UKUPNO:" )
   IF lKredit .AND. !Empty( cSifKred )
      @ PRow(), nC1 SAY  Space( Len( RADKR->naosnovu ) )
   ELSE
      @ PRow(), nC1 SAY  nT1 PICT gpics
   ENDIF
   @ PRow(), PCol() + 1 SAY  nT2 PICT gpici
   ? m
   ?
   p_potpis()
   FF
   ENDPRINT
   my_close_all_dbf()

   RETURN



FUNCTION ZPregPrim()

   P_12CPI
   ? Upper( gTS ) + ":", gnFirma
   ?
   IF Empty( cidrj )
      ? Lokal( "Pregled za sve RJ ukupno:" )
   ELSE
      ? Lokal( "RJ:" ), cidrj, ld_rj->naz
   ENDIF

   ?? Space( 2 ) + Lokal( "Mjesec:" ), Str( cMjesec, 2 ) + IspisObr()
   ?? Space( 4 ) + Lokal( "Godina:" ), Str( cGodina, 5 )
   DevPos( PRow(), 74 )
   ?? Lokal( "Str." ), Str( ++nStrana, 3 )
   ?
#ifdef CPOR
   ? Lokal( "Pregled" ) + Space( 1 ) + IF( lIsplaceni, Lokal( "isplacenih iznosa" ), Lokal( "neisplacenih iznosa" ) ) + Space( 1 ) + Lokal( "za tip primanja:" ), ctip, tippr->naz
#else
   ? Lokal( "Pregled za tip primanja:" ), cTip, tippr->naz
   IF lKredit
      ? Lokal( "KREDITOR:" ) + Space( 1 )
      IF !Empty( cSifKred )
         ShowKreditor( cSifKred )
      ELSE
         ?? Lokal( "SVI POSTOJECI" )
      ENDIF
   ENDIF
#endif
   ?
   ? m
   IF lKredit .AND. !Empty( cSifKred )
      ? " Rbr  " + PadC( "Sifra ", _LR_ ) + "          " + Lokal( "Naziv radnika" ) + "               " + PadC( "Na osnovu", Len( RADKR->naosnovu ) ) + "      " + Lokal( "Iznos" )
   ELSE
      ? " Rbr  " + PadC( "Sifra ", _LR_ ) + "          " + Lokal( "Naziv radnika" ) + "               " + iif( tippr->fiksan == "P", " %  ", "Sati" ) + "      " + Lokal( "Iznos" )
   ENDIF
   ? m

   RETURN
