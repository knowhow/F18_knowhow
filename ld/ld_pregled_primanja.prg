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

   cIdRadn := Space( LEN_IDRADNIK )
   cIdRj := gLDRadnaJedinica
   nMjesec := ld_tekuci_mjesec()
   nGodina := ld_tekuca_godina()
   cObracun := gObracun
   cVarSort := "2"
   lKredit := .F.
   cSifKred := ""

   nRbr := 0
   //o_ld_rj()
   //o_ld_radn()
   //select_o_ld()

   PRIVATE cTip := "  "

   cDod := "N"
   cKolona := Space( 20 )

   O_PARAMS

   PRIVATE cSection := "4"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "VS", @cVarSort )

   Box(, 7, 45 )
   @ form_x_koord() + 1, form_y_koord() + 2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ
   @ form_x_koord() + 2, form_y_koord() + 2 SAY "Mjesec: "  GET  nMjesec  PICT "99"
   IF ld_vise_obracuna()
      @ form_x_koord() + 2, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ form_x_koord() + 3, form_y_koord() + 2 SAY "Godina: "  GET  nGodina  PICT "9999"
   @ form_x_koord() + 4, form_y_koord() + 2 SAY "Tip primanja: "  GET  cTip
   @ form_x_koord() + 5, form_y_koord() + 2 SAY "Prikaz dodatnu kolonu: "  GET  cDod PICT "@!" VALID cdod $ "DN"
   @ form_x_koord() + 6, form_y_koord() + 2 SAY "Sortirati po (1-sifri, 2-prezime+ime)"  GET cVarSort VALID cVarSort $ "12"  PICT "9"
   READ

   clvbox()

   ESC_BCR

   IF cDod == "D"
      @ form_x_koord() + 7, form_y_koord() + 2 SAY "Naziv kolone:" GET cKolona
      READ
   ENDIF
   ckolona := "radn->" + ckolona

   BoxC()

   WPar( "VS", cVarSort )
   SELECT PARAMS
   USE

   set_tippr_ili_tippr2( cObracun )

   select_o_tippr( cTip )


   EOF CRET

   IF "SUMKREDITA" $ formula
      // radi se o kreditu, upitajmo da li je potreban prikaz samo za
      // jednog kreditora
      // ------------------------------------------------------------
      lKredit := .T.
      o_kred()
      cSifKred := Space( Len( id ) )
      Box(, 6, 75 )
      @ form_x_koord() + 2, form_y_koord() + 2 SAY "Izabrani tip primanja je kredit ili se tretira na isti nacin kao i kredit."
      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Ako zelite mozete dobiti spisak samo za jednog kreditora."
      @ form_x_koord() + 5, form_y_koord() + 2 SAY "Kreditor (prazno-svi zajedno)" GET cSifKred  VALID Empty( cSifKred ) .OR. P_Kred( @cSifKred ) PICT "@!"
      READ
      BoxC()
   ENDIF

   //IF !Empty( cSifKred )
      //O_RADKR
      //SET ORDER TO TAG "1"
   //ENDIF

   //SELECT ld

   IF ld_vise_obracuna()
      cObracun := Trim( cObracun )
   ELSE
      cObracun := ""
   ENDIF

   IF Empty( cIdRJ )

      cIdrj := ""
      IF cVarSort == "1"
         //SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "2" ) )
         //HSEEK Str( nGodina, 4 ) + Str( nMjesec, 2 ) + cObracun
         seek_ld_2( NIL, nGodina, nMjesec, cObracun )
      ELSE
         seek_ld( NIL, nGodina, nMjesec, cObracun )
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := IF( Empty( nMjesec ), ".t.", "MJESEC==" + _filter_quote( nMjesec ) ) + ".and." + ;
            IF( Empty( nGodina ), ".t.", "GODINA==" + _filter_quote( nGodina ) )
         IF ld_vise_obracuna()
            cFilt += ".and. OBR=" + _filter_quote( cObracun )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ELSE
      IF cVarSort == "1"
         //SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "1" ) )
         //HSEEK Str( nGodina, 4 ) + cidrj + Str( nMjesec, 2 ) + cObracun
         seek_ld( cIdRj, nGodina, nMjesec, cObracun )
      ELSE
         seek_ld( cIdRj, nGodina, nMjesec, cObracun )
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := "IDRJ==" + _filter_quote( cIdRj ) + " .and. "
         cFilt += iif( Empty( nMjesec ), ".t.", "MJESEC==" + _filter_quote( nMjesec ) ) + ".and."
         cFilt += iif( Empty( nGodina ), ".t.", "GODINA==" + _filter_quote( nGodina ) )

         IF ld_vise_obracuna()
            cFilt += ".and. OBR ==" + _filter_quote( cObracun )
         ENDIF

         INDEX ON &cSort1 TO "tmpld" FOR &cFilt

         BoxC()
         GO TOP
      ENDIF
   ENDIF

   EOF CRET

   nStrana := 0
   m := "----- " + Replicate( "-", LEN_IDRADNIK ) + " ---------------------------------- " + IF( lKredit .AND. !Empty( cSifKred ), REPL( "-", Len( RADKR->naosnovu ) + 1 ), "-" + REPL( "-", Len( gPicS ) ) ) + " ----------- -----------"
   IF cdod == "D"
      IF Type( ckolona ) $ "UUIUE"
         Msg( "Nepostojeca kolona" )
         closeret
      ENDIF
   ENDIF
   bZagl := {|| ZPregPrim() }

   select_o_ld_rj( ld->idrj )
   SELECT ld

   START PRINT CRET
   P_10CPI

   Eval( bZagl )

   nRbr := 0
   nT1 := nT2 := nT3 := nT4 := 0
   nC1 := 10

   DO WHILE !Eof() .AND.  nGodina == godina .AND. idrj = cidrj .AND. nMjesec = mjesec .AND. ;
         !( ld_vise_obracuna() .AND. !Empty( cObracun ) .AND. obr <> cObracun )

      IF ld_vise_obracuna() .AND. Empty( cObracun )
         ScatterS( godina, mjesec, idrj, idradn )
      ELSE
         Scatter()
      ENDIF

      IF lKredit .AND. !Empty( cSifKred )
         // provjerimo da li otplacuje zadanom kreditoru
         // --------------------------------------------
         //SELECT RADKR
         //SEEK Str( nGodina, 4 ) + Str( nMjesec, 2 ) + LD->idradn + cSifKred
         seek_radkr( nGodina, nMjesec, ld->IdRadn, cSifKred )
         lImaJos := .F.
         DO WHILE !Eof() .AND. Str( nGodina, 4 ) + Str( nMjesec, 2 ) + LD->idradn + cSifKred == Str( godina, 4 ) + Str( mjesec, 2 ) + idradn + idkred
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

      select_o_radn( _idradn )
      SELECT ld


      DO WHILE .T.

         IF PRow() > RPT_PAGE_LEN + dodatni_redovi_po_stranici()
            FF
            Eval( bZagl )
         ENDIF

         IF _I&cTip <> 0 .OR. _S&cTip <> 0
            ? Str( ++nRbr, 4 ) + ".", idradn, RADNIK_PREZ_IME
            nC1 := PCol() + 1
            IF lKredit .AND. !Empty( cSifKred )
               @ PRow(), PCol() + 1 SAY RADKR->naosnovu
            ELSEIF tippr->fiksan == "P"
               @ PRow(), PCol() + 1 SAY _S&cTip  PICT "999.99"
            ELSE
               @ PRow(), PCol() + 1 SAY _S&cTip  PICT gpics
            ENDIF
            IF lKredit .AND. !Empty( cSifKred )
               @ PRow(), PCol() + 1 SAY -RADKR->placeno  PICT gpici
               nT2 += ( - RADKR->placeno )
            ELSE
               @ PRow(), PCol() + 1 SAY _I&cTip  PICT gpici
               nT1 += _S&cTip; nT2 += _I&cTip
            ENDIF
            IF cdod == "D"
               @ PRow(), PCol() + 1 SAY &ckolona
            ENDIF
         ENDIF
         IF lKredit .AND. !Empty( cSifKred )
            lImaJos := .F.
            SELECT RADKR; SKIP 1
            DO WHILE !Eof() .AND. Str( nGodina, 4 ) + Str( nMjesec, 2 ) + LD->idradn + cSifKred == Str( godina, 4 ) + Str( mjesec, 2 ) + idradn + idkred
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

   IF PRow() > RPT_PAGE_LEN + dodatni_redovi_po_stranici()
      FF
      Eval( bZagl )
   ENDIF
   ? m
   ? Space( 1 ) + _l( "UKUPNO:" )
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
   ? Upper( tip_organizacije() ) + ":", self_organizacija_naziv()
   ?
   IF Empty( cidrj )
      ? _l( "Pregled za sve RJ ukupno:" )
   ELSE
      ? _l( "RJ:" ), cidrj, ld_rj->naz
   ENDIF

   ?? Space( 2 ) + _l( "Mjesec:" ), Str( nMjesec, 2 ) + IspisObr()
   ?? Space( 4 ) + _l( "Godina:" ), Str( nGodina, 5 )
   DevPos( PRow(), 74 )
   ?? _l( "Str." ), Str( ++nStrana, 3 )
   ?
#ifdef CPOR
   ? _l( "Pregled" ) + Space( 1 ) + IF( lIsplaceni, _l( "isplacenih iznosa" ), _l( "neisplacenih iznosa" ) ) + Space( 1 ) + _l( "za tip primanja:" ), ctip, tippr->naz
#else
   ? _l( "Pregled za tip primanja:" ), cTip, tippr->naz
   IF lKredit
      ? _l( "KREDITOR:" ) + Space( 1 )
      IF !Empty( cSifKred )
         ShowKreditor( cSifKred )
      ELSE
         ?? _l( "SVI POSTOJECI" )
      ENDIF
   ENDIF
#endif
   ?
   ? m
   IF lKredit .AND. !Empty( cSifKred )
      ? " Rbr  " + PadC( "Sifra ", LEN_IDRADNIK ) + "          " + _l( "Naziv radnika" ) + "               " + PadC( "Na osnovu", Len( RADKR->naosnovu ) ) + "      " + _l( "Iznos" )
   ELSE
      ? " Rbr  " + PadC( "Sifra ", LEN_IDRADNIK ) + "          " + _l( "Naziv radnika" ) + "               " + iif( tippr->fiksan == "P", " %  ", "Sati" ) + "      " + _l( "Iznos" )
   ENDIF
   ? m

   RETURN
