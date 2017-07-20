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


FUNCTION ld_platni_spisak()

   LOCAL nC1 := 20
   LOCAL cVarSort := "2"
   LOCAL lSviRadnici := .F.
   LOCAL cSviRadn := "N"

   cIdRadn := Space( LEN_IDRADNIK )
   cIdRj := gLDRadnaJedinica
   nMjesec := ld_tekuci_mjesec()
   nGodina := ld_tekuca_godina()
   cObracun := gObracun

   o_ld_rj()
   o_ld_radn()
   // select_o_ld()

   cProred := "N"
   cPrikIzn := "D"
   nProcenat := 100
   nZkk := gZaok
   cDrugiDio := "D"
   cNaslov := ""
   // ISPLATA PLATA
   cNaslovTO := ""
   // ISPLATA TOPLOG OBROKA
   nIznosTO := 0
   // export za banku
   cZaBanku := "N"

   // uzmi parametre iz sql/db
   cVarSort := fetch_metric( "ld_platni_spisak_sortiranje", my_user(), cVarSort )
   cNaslov := fetch_metric( "ld_platni_spisak_naslov", my_user(), cNaslov )
   cNaslov := PadR( cNaslov, 90 )
   cNaslovTO := fetch_metric( "ld_platni_spisak_naslov_to", my_user(), cNaslovTO )
   cNaslovTO := PadR( cNaslovTO, 90 )

   Box(, 13, 60 )

   @ get_x_koord() + 1, get_y_koord() + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ get_x_koord() + 2, get_y_koord() + 2 SAY "Mjesec: "  GET  nMjesec  PICT "99"
   @ get_x_koord() + 2, Col() + 2 SAY "Obracun: "  GET  cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   @ get_x_koord() + 3, get_y_koord() + 2 SAY "Godina: "  GET  nGodina  PICT "9999"
   @ get_x_koord() + 4, get_y_koord() + 2 SAY "Prored:"   GET  cProred  PICT "@!"  VALID cProred $ "DN"
   @ get_x_koord() + 5, get_y_koord() + 2 SAY "Prikaz iznosa:" GET cPrikIzn PICT "@!" VALID cPrikizn $ "DN"
   @ get_x_koord() + 6, get_y_koord() + 2 SAY "Prikaz u procentu %:" GET nprocenat PICT "999.99"
   @ get_x_koord() + 7, get_y_koord() + 2 SAY "Sortirati po (1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort $ "12"  PICT "9"
   @ get_x_koord() + 8, get_y_koord() + 2 SAY "Naslov izvjestaja"  GET cNaslov PICT "@S30"
   @ get_x_koord() + 9, get_y_koord() + 2 SAY "Naslov za topl.obrok"  GET cNaslovTO PICT "@S30"
   @ get_x_koord() + 10, get_y_koord() + 2 SAY "Iznos (samo za topli obrok)"  GET nIznosTO PICT gPicI
   @ get_x_koord() + 11, get_y_koord() + 2 SAY "Izlistati sve radnike (D/N)"  GET cSviRadn PICT "@!" VALID cSviRadn $ "DN"

   READ

   clvbox()
   ESC_BCR
   IF nProcenat <> 100

      @ get_x_koord() + 12, get_y_koord() + 2 SAY "zaokruzenje" GET nZkk PICT "99"
      @ get_x_koord() + 13, get_y_koord() + 2 SAY "Prikazati i drugi spisak (za " + LTrim( Str( 100 - nProcenat, 6, 2 ) ) + "%-tni dio)" GET cDrugiDio VALID cDrugiDio $ "DN" PICT "@!"

      READ
   ELSE
      cDrugiDio := "N"
   ENDIF

   BoxC()

   // snimi parametre u sql/db
   set_metric( "ld_platni_spisak_sortiranje", my_user(), cVarSort )
   set_metric( "ld_platni_spisak_naslov", my_user(), cNaslov )
   cNaslov := AllTrim( cNaslov )
   set_metric( "ld_platni_spisak_naslov_to", my_user(), cNaslovTO )
   cNaslovTO := AllTrim( cNaslovTO )

   IF cSviRadn == "D"
      lSviRadnici := .T.
   ENDIF

   IF nIznosTO <> 0
      cNaslov := cNaslovTO
      qqImaTO := my_get_from_ini( "LD", "UslovImaTopliObrok", 'UPPER(RADN->K2)=="D"', KUMPATH )
   ENDIF

   IF !Empty( cNaslov )
      cNaslov += ( Space( 1 ) + _l( "za mjesec:" ) + Str( nMjesec, 2 ) + ". " + _l( "godine:" ) + Str( nGodina, 4 ) + "." )
   ENDIF

   // SELECT ld
   // CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
   // CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")

   cObracun := Trim( cObracun )

   IF Empty( cIdRj )
      cIdRj := ""
      IF cVarSort == "1"
         // SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "2" ) )
         // HSEEK Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 ) + cObracun
         seek_ld_2( NIL, nGodina, nMjesec, cObracun )

      ELSE
         seek_ld_2( cIdRj, nGodina, nMjesec, cObracun )
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := iif( Empty( nMjesec ), ".t.", "MJESEC==" + _filter_quote( nMjesec ) ) + ".and." + ;
            iif( Empty( nGodina ), ".t.", "GODINA==" + _filter_quote( nGodina ) )
         cFilt += ".and. obr==" + _filter_quote( cObracun )
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ELSE

      IF cVarSort == "1"
         // SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "1" ) )
         // HSEEK Str( nGodina, 4 ) + cidrj + Str( nMjesec, 2 ) + cObracun
         seek_ld( cIdRj, nGodina, nMjesec, cObracun )
      ELSE
         seek_ld( cIdRj, nGodina, nMjesec, cObracun )
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := "IDRJ==cIdRj.and." + ;
            IF( Empty( nMjesec ), ".t.", "MJESEC==" + _filter_quote( nMjesec ) ) + ".and." + ;
            IF( Empty( nGodina ), ".t.", "GODINA==" + _filter_quote( nGodina ) )
         cFilt += ".and. obr=" + _filter_quote( cObracun )
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF
   ENDIF

   EOF CRET

   nStrana := 0

   m := "----- " + Replicate( "-", LEN_IDRADNIK ) + " ----------------------------------- ----------- -------------------------"
   bZagl := {|| ZPlatSp() }

   select_o_ld_rj( ld->idrj )
   SELECT ld

   START PRINT CRET

   nPocRec := RecNo()

   FOR nDio := 1 TO IF( cDrugiDio == "D", 2, 1 )

      IF nDio == 2
         GO ( nPocRec )
      ENDIF

      Eval( bZagl )

      nT1 := nT2 := nT3 := nT4 := 0
      nRbr := 0

      DO WHILE !Eof() .AND.  nGodina == godina .AND. idrj = cidrj .AND. nMjesec = mjesec .AND. !( ld_vise_obracuna() .AND. !Empty( cObracun ) .AND. obr <> cObracun )

         IF ld_vise_obracuna() .AND. Empty( cObracun )
            ScatterS( godina, mjesec, idrj, idradn )
         ELSE
            Scatter()
         ENDIF

         select_o_radn( _idradn )

         SELECT ld

         IF nIznosTO = 0
            // isplata plate
            IF !lSviRadnici .AND. !( Empty( radn->isplata ) .OR. radn->isplata = "BL" )
               SKIP
               LOOP
            ENDIF
         ELSE
            // isplata toplog obroka
            IF !( &qqImaTO )
               SKIP
               LOOP
            ENDIF
         ENDIF

         ? Str( ++nRbr, 4 ) + ".", idradn, RADNIK_PREZ_IME

         nC1 := PCol() + 1
         IF nIznosTO <> 0
            _uiznos := nIznosTO
         ENDIF
         IF cprikizn == "D"
            IF nProcenat <> 100
               IF nDio == 1
                  @ PRow(), PCol() + 1 SAY Round( _uiznos * nprocenat / 100, nzkk ) PICT gpici
               ELSE
                  @ PRow(), PCol() + 1 SAY Round( _uiznos, nzkk ) - Round( _uiznos * nprocenat / 100, nzkk ) PICT gpici
               ENDIF
            ELSE
               @ PRow(), PCol() + 1 SAY _uiznos PICT gpici
            ENDIF
         ELSE
            @ PRow(), PCol() + 1 SAY Space( Len( gpici ) )
         ENDIF

         @ PRow(), PCol() + 4 SAY Replicate( "_", 22 )

         IF cProred == "D"
            ?
         ENDIF

         nT1 += _usati
         nT2 += _uneto
         nT3 += _uodbici

         IF nProcenat <> 100
            IF nDio == 1
               nT4 += Round( _uiznos * nprocenat / 100, nzkk )
            ELSE
               nT4 += ( Round( _uiznos, nzkk ) - Round( _uiznos * nprocenat / 100, nzkk ) )
            ENDIF
         ELSE
            nT4 += _uiznos
         ENDIF

         SKIP
      ENDDO


      ? m
      ? Space( 1 ) + _l( "UKUPNO:" )

      IF cPrikIzn == "D"
         @ PRow(), nC1 SAY nT4 PICT gpici
      ENDIF

      ? m

      ? p_potpis()

      FF

   NEXT


   ENDPRINT

   my_close_all_dbf()

   RETURN .T.



FUNCTION ld_platni_spisak_tekuci_racun( cVarijanta )

   LOCAL nC1 := 20
   LOCAL cVarSort

   cIdRadn := Space( LEN_IDRADNIK )
   cIdRj := gLDRadnaJedinica
   nMjesec := ld_tekuci_mjesec()
   nGodina := ld_tekuca_godina()
   cObracun := gObracun
   cVarSort := "2"
   cProred := "N"
   cPrikIzn := "D"
   nProcenat := 100
   nZkk := gZaok

   // o_kred()
   o_ld_rj()
   o_ld_radn()
   // select_o_ld()

   PRIVATE cIsplata := ""
   PRIVATE cLokacija
   PRIVATE cConstBrojTR
   PRIVATE nH
   PRIVATE cParKonv

   IF cVarijanta == "1"
      cIsplata := "TR"
   ELSE
      cIsplata := "SK"
   ENDIF

   cZaBanku := "N"
   cIDBanka := Space( LEN_IDRADNIK )
   cDrugiDio := "D"
   cVarSort := fetch_metric( "ld_platni_spisak_sortiranje", my_user(), cVarSort )

   Box(, 11, 50 )

   @ get_x_koord() + 1, get_y_koord() + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ get_x_koord() + 2, get_y_koord() + 2 SAY "Mjesec: "  GET  nMjesec  PICT "99"
   @ get_x_koord() + 2, Col() + 2 SAY "Obracun: "  GET  cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   @ get_x_koord() + 3, get_y_koord() + 2 SAY "Godina: "  GET  nGodina  PICT "9999"
   @ get_x_koord() + 4, get_y_koord() + 2 SAY "Prored:"   GET  cProred  PICT "@!"  VALID cProred $ "DN"
   @ get_x_koord() + 5, get_y_koord() + 2 SAY "Prikaz iznosa:" GET cPrikIzn PICT "@!" VALID cPrikizn $ "DN"
   @ get_x_koord() + 6, get_y_koord() + 2 SAY "Prikaz u procentu %:" GET nprocenat PICT "999.99"
   @ get_x_koord() + 7, get_y_koord() + 2 SAY "Banka        :" GET cIdBanka VALID P_Kred( @cIdBanka )
   @ get_x_koord() + 8, get_y_koord() + 2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort $ "12"  PICT "9"
   @ get_x_koord() + 11, get_y_koord() + 2 SAY "Spremiti izvjestaj za banku (D/N)" GET cZaBanku PICT "@!"

   READ

   clvbox()

   ESC_BCR

   IF nProcenat <> 100
      @ get_x_koord() + 9, get_y_koord() + 2 SAY "zaokruzenje" GET nZkk PICT "99"
      @ get_x_koord() + 10, get_y_koord() + 2 SAY "Prikazati i drugi spisak (za " + LTrim( Str( 100 - nProcenat, 6, 2 ) ) + "%-tni dio)" GET cDrugiDio VALID cDrugiDio $ "DN" PICT "@!"
      READ
   ELSE
      cDrugiDio := "N"
   ENDIF

   BoxC()

   set_metric( "ld_platni_spisak_sortiranje", my_user(), cVarSort )

   IF cZaBanku == "D"
      CreateFileBanka()
   ENDIF

   //SELECT ld
   // CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
   // CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")

   cObracun := Trim( cObracun )

   IF Empty( cIdRj )

      cIdRj := ""

      IF cVarSort == "1"
         // SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "2" ) )
         // HSEEK Str( nGodina, 4 ) + Str( nMjesec, 2 ) + cObracun
         seek_ld_2( NIL, nGodina, nMjesec, cObracun )
      ELSE
         seek_ld( NIL, nGodina, nMjesec, cObracun )
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := iif( Empty( nMjesec ), ".t.", "MJESEC==" + _filter_quote( nMjesec ) ) + ".and." + IF( Empty( nGodina ), ".t.", "GODINA==" + _filter_quote( nGodina ) )
         IF ld_vise_obracuna()
            cFilt += ".and. obr=" + _filter_quote( cObracun )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF

   ELSE

      IF cVarSort == "1"
         // SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "1" ) )
         // HSEEK Str( nGodina, 4 ) + cidrj + Str( nMjesec, 2 ) + cObracun
         seek_ld( cIdRj, nGodina, nMjesec, cObracun )
      ELSE
         seek_ld( cIdRj, nGodina, nMjesec, cObracun )
         Box(, 2, 30 )
         nSlog := 0
         cSort1 := "SortPrez(IDRADN)"
         cFilt := "IDRJ==" + _filter_quote( cIdRj ) + ".and." + IF( Empty( nMjesec ), ".t.", "MJESEC==" + _filter_quote( nMjesec ) ) + ".and." + IF( Empty( nGodina ), ".t.", "GODINA==" + _filter_quote( nGodina ) )
         IF ld_vise_obracuna()
            cFilt += ".and. obr=" + _filter_quote( cObracun )
         ENDIF
         INDEX ON &cSort1 TO "tmpld" FOR &cFilt
         BoxC()
         GO TOP
      ENDIF

   ENDIF

   EOF CRET

   nStrana := 0

   // linija za zaglavlje
   m := Replicate( "-", 5 )
   m += Space( 1 )
   m += Replicate( "-", 6 )
   m += Space( 1 )
   m += Replicate( "-", 13 )
   m += Space( 1 )
   m += Replicate( "-", 35 )
   m += Space( 1 )
   m += Replicate( "-", 11 )
   m += Space( 1 )
   m += Replicate( "-", 25 )

   bZagl := {|| ZPlatSpTR() }

   select_o_ld_rj( ld->idrj )
   SELECT ld

   START PRINT CRET

   nPocRec := RecNo()

   FOR nDio := 1 TO IF( cDrugiDio == "D", 2, 1 )

      IF nDio == 2
         GO ( nPocRec )
      ENDIF

      Eval( bZagl )

      nT1 := 0
      nT2 := 0
      nT3 := 0
      nT4 := 0
      nRbr := 0

      DO WHILE !Eof() .AND.  nGodina == godina .AND. idrj = cIdRj .AND. nMjesec = mjesec .AND. !( ld_vise_obracuna() .AND. !Empty( cObracun ) .AND. obr <> cObracun )

         IF ld_vise_obracuna() .AND. Empty( cObracun )
            ScatterS( godina, mjesec, idrj, idradn )
         ELSE
            Scatter()
         ENDIF

         select_o_radn( _idradn )
         SELECT ld

         IF radn->isplata <> cIsplata .OR. ;
               radn->idbanka <> cIdBanka
            // samo za tekuce racune
            SKIP
            LOOP
         ENDIF


         ? Str( ++nRbr, 4 ) + ".", idradn, radn->matbr, RADNIK_PREZ_IME

         IF cZaBanku == "D"
            cZaBnkRadnik := FormatSTR( AllTrim( RADNZABNK ), 40 )
         ENDIF

         nC1 := PCol() + 1

         IF cPrikIzn == "D"
            IF nProcenat <> 100
               IF nDio == 1
                  @ PRow(), PCol() + 1 SAY Round( _uiznos * nprocenat / 100, nzkk ) PICT gpici
               ELSE
                  @ PRow(), PCol() + 1 SAY Round( _uiznos, nzkk ) - Round( _uiznos * nprocenat / 100, nzkk ) PICT gpici
               ENDIF
            ELSE
               @ PRow(), PCol() + 1 SAY _uiznos PICT gpici
               IF cZaBanku == "D"
                  cZaBnkIznos := FormatSTR( AllTrim( Str( _uiznos ), 8, 2 ), 8, .T. )
               ENDIF
            ENDIF
         ELSE
            @ PRow(), PCol() + 1 SAY Space( Len( gpici ) )
         ENDIF

         IF cIsplata == "TR"
            @ PRow(), PCol() + 4 SAY PadL( radn->brtekr, 22 )
            IF cZaBanku == "D"
               cZaBnkTekRn := FormatSTR( AllTrim( radn->brtekr ), 25, .F., "" )
            ENDIF
         ELSE
            @ PRow(), PCol() + 4 SAY PadL( radn->brknjiz, 22 )
            IF cZaBanku == "D"
               cZaBnkTekRn := FormatSTR( AllTrim( radn->brknjiz ), 25, .F., "" )
            ENDIF
         ENDIF

         IF cProred == "D"
            ?
         ENDIF

         nT1 += _usati
         nT2 += _uneto
         nT3 += _uodbici

         IF nProcenat <> 100
            IF nDio == 1
               nT4 += Round( _uiznos * nProcenat / 100, nZkk )
            ELSE
               nT4 += ( Round( _uiznos, nZkk ) - Round( _uiznos * nProcenat / 100, nZKK ) )
            ENDIF
         ELSE
            nT4 += _uiznos
         ENDIF

         SKIP

         // upisi u fajl za banku
         IF cZaBanku == "D"

            cUpisiZaBanku := ""
            cUpisiZaBanku += cZaBnkTekRn
            cUpisiZaBanku += cZaBnkRadnik
            cUpisiZaBanku += cZaBnkIznos

            // napravi konverziju
            KonvZnWin( @cUpisiZaBanku, cParKonv )

            Write2File( nH, cUpisiZaBanku, .T. )

            // reset varijable
            cUpisiZaBanku := ""

         ENDIF

      ENDDO


      ? m

      ? Space( 1 ) + _l( "UKUPNO:" )

      IF cPrikIzn == "D"
         @ PRow(), nC1 SAY nT4 PICT gPici
      ENDIF

      ? m

      ? p_potpis()

      FF

   NEXT

   IF cZaBanku == "D"
      CloseFileBanka( nH )
   ENDIF

   ENDPRINT

   my_close_all_dbf()

   RETURN .T.



FUNCTION ZPlatSp()

   ?
   P_12CPI

   ? Upper( tip_organizacije() ) + ":", self_organizacija_naziv()
   ?

   IF Empty( cidrj )
      ? _l( "Pregled za sve RJ ukupno:" )
   ELSE
      ? _l( "RJ:" ), cIdRj, ld_rj->naz
   ENDIF

   ?? Space( 2 ) + _l( "Mjesec:" ), Str( nMjesec, 2 ) + IspisObr()
   ?? Space( 4 ) + _l( "Godina:" ), Str( nGodina, 5 )
   DevPos( PRow(), 74 )
   ?? _l( "Str." ), Str( ++nStrana, 3 )
   ?

   IF !Empty( cNaslov )
      ? PadC( AllTrim( cNaslov ), 90 )
      ? PadC( REPL( "-", Len( AllTrim( cNaslov ) ) ), 90 )
   ENDIF

   IF nProcenat <> 100
      ?
      ? _l( "Procenat za isplatu:" )
      IF nDio == 1
         @ PRow(), PCol() + 1 SAY nprocenat PICT "999.99%"
      ELSE
         @ PRow(), PCol() + 1 SAY 100 - nprocenat PICT "999.99%"
      ENDIF
      ?
   ENDIF

   ? m
   ? _l( "Rbr   Sifra           Naziv radnika               " ) + iif( cPrikIzn == "D", _l( "ZA ISPLATU" ), "          " ) + "         " + _l( "Potpis" )
   ? m

   RETURN .T.



// ---------------------------------------------------
// zaglavlje platni spisak tekuci racun
// ---------------------------------------------------
FUNCTION ZPlatSpTR()

   select_o_kred( cIdBanka )

   SELECT ld

   ?

   P_12CPI
   P_COND

   ? _l( "Poslovna BANKA:" ) + Space( 1 ), cIDBanka, "-", kred->naz
   ?
   ? Upper( tip_organizacije() ) + ":", self_organizacija_naziv()
   ?

   IF Empty( cIdRj )
      ? _l( "Pregled za sve RJ ukupno:" )
   ELSE
      ? _l( "RJ:" ), cIdRj, ld_rj->naz
   ENDIF

   ?? Space( 2 ) + _l( "Mjesec:" ), Str( nMjesec, 2 ) + IspisObr()
   ?? Space( 4 ) + _l( "Godina:" ), Str( nGodina, 5 )

   DevPos( PRow(), 74 )

   ?? _l( "Str." ), Str( ++nStrana, 3 )

   ?

   IF nProcenat <> 100

      ?
      ? _l( "Procenat za isplatu:" )

      IF nDio == 1
         @ PRow(), PCol() + 1 SAY nprocenat PICT "999.99%"
      ELSE
         @ PRow(), PCol() + 1 SAY 100 - nprocenat PICT "999.99%"
      ENDIF

      ?

   ENDIF

   ?
   ? m
   ? _l( "Rbr   Sifra    JMB                 Naziv radnika               " ) + iif( cPrikIzn == "D", _l( "ZA ISPLATU" ), "          " ) + iif( cIsplata == "TR", Space( 9 ) + _l( "Broj T.Rac" ), Space( 8 ) + _l( "Broj St.knj" ) )
   ? m

   RETURN




FUNCTION ld_pregled_isplate_za_tekuci_racun( cVarijanta )

   LOCAL nC1 := 20

   cIdRadn := Space( LEN_IDRADNIK )
   cIdRj := gLDRadnaJedinica
   nMjesec := ld_tekuci_mjesec()
   nGodina := ld_tekuca_godina()
   cObracun := gObracun
   cVarSort := "2"
   cIdTipPr := "  "

   // o_tippr()
   // o_kred()
   // o_ld_rj()
   // o_ld_radn()
   // select_o_ld()
   // SET RELATION TO idradn into radn

   cProred := "N"
   cPrikIzn := "D"
   nZkk := gZaok

   PRIVATE cIsplata := ""
   PRIVATE cLokacija
   PRIVATE cConstBrojTR
   PRIVATE nH

   IF cVarijanta == "1"
      cIsplata := "TR"
   ELSE
      cIsplata := "SK"
   ENDIF



   cIDBanka := Space( FIELD_LD_RADN_IDBANKA )
   cVarSort := fetch_metric( "ld_platni_spisak_sortiranje", my_user(), cVarSort )

   Box(, 10, 50 )
   @ get_x_koord() + 1, get_y_koord() + 2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
   @ get_x_koord() + 2, get_y_koord() + 2 SAY "Mjesec: "  GET  nMjesec  PICT "99"
   @ get_x_koord() + 2, Col() + 2 SAY "Obracun: "  GET  cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   @ get_x_koord() + 3, get_y_koord() + 2 SAY "Godina: "  GET  nGodina  PICT "9999"
   @ get_x_koord() + 4, get_y_koord() + 2 SAY "Prored:"   GET  cProred  PICT "@!"  VALID cProred $ "DN"
   @ get_x_koord() + 5, get_y_koord() + 2 SAY "Prikaz iznosa:" GET cPrikIzn PICT "@!" VALID cPrikizn $ "DN"
   @ get_x_koord() + 6, get_y_koord() + 2 SAY "Primanje (prazno-sve ukupno):" GET cIdTipPr VALID Empty( cIdTipPr ) .OR. P_TipPr( @cIdTipPr )
   @ get_x_koord() + 7, get_y_koord() + 2 SAY "Banka (prazno-sve) :" GET cIdBanka VALID Empty( cIdBanka ) .OR. P_Kred( @cIdBanka )
   @ get_x_koord() + 8, get_y_koord() + 2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort $ "12"  PICT "9"



   READ

   clvbox()
   ESC_BCR

   BoxC()

   set_metric( "ld_platni_spisak_sortiranje", my_user(), cVarSort )


   SELECT ld
   // CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
   // CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")

   cObracun := Trim( cObracun )

   IF Empty( cIdRj )
      cIdRj := ""
      Box(, 2, 30 )
      nSlog := 0
      nUkupno := RECCOUNT2()
      IF cVarSort == "1"
         cSort1 := "radn->idbanka+IDRADN"
      ELSE
         cSort1 := "radn->idbanka+SortPrez(IDRADN)"
      ENDIF
      IF Empty( cIdBanka )
         cFilt := "radn->isplata==" + _filter_quote( cIsplata ) + ".and."
      ELSE
         cFilt := "radn->isplata==" + _filter_quote( cIsplata ) + ".and.radn->idBanka==" + _filter_quote( cIdBanka ) + ".and."
      ENDIF
      cFilt := cFilt + IF( Empty( nMjesec ), ".t.", "MJESEC==" + _filter_quote( nMjesec ) ) + ".and." + IF( Empty( nGodina ), ".t.", "GODINA==" + _filter_quote( nGodina ) )
      IF ld_vise_obracuna()
         cFilt += ".and. obr=" + _filter_quote( cObracun )
      ENDIF
      INDEX ON &cSort1 TO "tmpld" FOR &cFilt
      BoxC()
      GO TOP
   ELSE
      Box(, 2, 30 )
      nSlog := 0
      nUkupno := RECCOUNT2()
      IF cVarSort == "1"
         cSort1 := "radn->idbanka+IDRADN"
      ELSE
         cSort1 := "radn->idbanka+SortPrez(IDRADN)"
      ENDIF
      IF Empty( cIdBanka )
         cFilt := "radn->isplata==" + _filter_quote( cIsplata ) + ".and."
      ELSE
         cFilt := "radn->isplata==" + _filter_quote( cIsplata ) + ".and.radn->idBanka==" + _filter_quote( cIdBanka ) + ".and."
      ENDIF
      cFilt := cFilt + "IDRJ==" + _filter_quote( cIdRj ) + ".and." + IF( Empty( nMjesec ), ".t.", "MJESEC==" + _filter_quote( nMjesec ) ) + ".and." + IF( Empty( nGodina ), ".t.", "GODINA==" + _filter_quote( nGodina ) )
      IF ld_vise_obracuna()
         cFilt += ".and. obr=" + _filter_quote( cObracun )
      ENDIF
      INDEX ON &cSort1 TO "tmpld" FOR &cFilt
      BoxC()
      GO TOP
   ENDIF

   EOF CRET

   nStrana := 0
   m := "----- ------ ----------------------------------- ----------- -------------------------"
   bZagl := {|| ZIsplataTR() }

   SELECT ld_rj
   HSEEK ld->idrj
   SELECT ld

   START PRINT CRET

   DO WHILE !Eof()

      cIdTBanka := radn->idBanka
      nStrana := 0

      Eval( bZagl )

      nT1 := 0
      nT2 := 0
      nT3 := 0
      nT4 := 0
      nRbr := 0

      DO WHILE !Eof() .AND.  nGodina == godina .AND. idrj = cIdRj .AND. nMjesec = mjesec .AND. !( ld_vise_obracuna() .AND. !Empty( cObracun ) .AND. obr <> cObracun ) .AND. radn->idBanka == cIdTBanka

         IF ld_vise_obracuna() .AND. Empty( cObracun )
            ScatterS( godina, mjesec, idrj, idradn )
         ELSE
            Scatter()
         ENDIF



         IF Empty( cIdTipPr )
            nIznosTP := _uiznos
         ELSE
            nIznosTP := _I&cIdTipPr
         ENDIF

         IF nIznosTP = 0
            SKIP
            LOOP
         ENDIF


         ? Str( ++nRbr, 4 ) + ".", idradn, RADNIK_PREZ_IME
         cZaBnkRadnik := FormatSTR( RADNZABNK, 40 )

         nC1 := PCol() + 1
         IF cPrikIzn == "D"
            @ PRow(), PCol() + 1 SAY nIznosTP PICT gpici
            cZaBnkIznos := FormatSTR( AllTrim( Str( nIznosTP ) ), 20 )
         ELSE
            @ PRow(), PCol() + 1 SAY Space( Len( gpici ) )
         ENDIF
         IF cIsplata == "TR"
            @ PRow(), PCol() + 4 SAY PadL( radn->brtekr, 22 )
            cZaBnkTekRN := FormatSTR( AllTrim( radn->brtekr ), 6 )
         ELSE
            @ PRow(), PCol() + 4 SAY PadL( radn->brknjiz, 22 )
         ENDIF
         IF cProred == "D"
            ?
         ENDIF


         nT1 += _usati
         nT2 += _uneto
         nT3 += _uodbici
         nT4 += nIznosTP
         SKIP
      ENDDO


      ? m
      ? Space( 1 ) + _l( "UKUPNO:" )
      IF cPrikIzn == "D"
         @ PRow(), nC1 SAY nT4 PICT gpici
      ENDIF
      ? m

      ? p_potpis()

      FF

   ENDDO


   ENDPRINT

   my_close_all_dbf()

   RETURN .T.


FUNCTION ZIsplataTR()

   ?
   P_12CPI

   select_o_kred( cIdTBanka )
   SELECT ld

   ?
   ? _l( "Poslovna BANKA:" ) + Space( 1 ), cIDTBanka, "-", kred->naz
   ?
   ? Upper( tip_organizacije() ) + ":", self_organizacija_naziv()
   ?

   IF Empty( cidrj )
      ? _l( "Pregled za sve RJ ukupno:" )
   ELSE
      ? _l( "RJ:" ), cIdRj, ld_rj->naz
   ENDIF

   ?? Space( 2 ) + _l( "Mjesec:" ), Str( nMjesec, 2 ) + IspisObr()
   ?? Space( 4 ) + _l( "Godina:" ), Str( nGodina, 5 )
   DevPos( PRow(), 74 )
   ?? _l( "Str." ), Str( ++nStrana, 3 )
   ?
   IF Empty( cIdTipPr )
      ? _l( "PLATNI SPISAK" )
   ELSE
      ? _l( "ISPLATA TIPA PRIMANJA:" ), cIdTipPr, TIPPR->naz
   ENDIF
   ?
   ? m
   ? _l( "Rbr   Sifra           Naziv radnika               " ) + iif( cPrikIzn == "D", _l( "ZA ISPLATU" ), "          " ) + iif( cIsplata == "TR", Space( 9 ) + _l( "Broj T.Rac" ), Space( 8 ) + _l( "Broj St.knj" ) )
   ? m

   RETURN


// ----------------------------------------------
// formatiranje stringa ....
// ----------------------------------------------
FUNCTION FormatSTR( cString, nLen, lLeft, cFill )

   IF lLeft == nil
      lLeft := .F.
   ENDIF

   IF cFill == nil
      cFill := "0"
   ENDIF

   // formatiraj string na odredjenu duzinu
   cRet := PadR( cString, nLen )

   // zamjeni "." -> ","
   cRet := StrTran( cRet, ".", "," )

   IF lLeft == .T.
      cRet := PadL( AllTrim( cRet ), nLen, cFill )
   ENDIF

   RETURN cRet


// -----------------------------------------
// kreiranje fajla za eksport
// -----------------------------------------
FUNCTION CreateFileBanka( banka )

   LOCAL _file_name := ""

   IF banka == NIL .OR. Empty( banka )
      _file_name := "to.txt"
   ELSE
      _file_name := "to_" + AllTrim( banka ) + ".txt"
   ENDIF

   Box(, 5, 70 )

   cLokacija := PadR( my_home() + _file_name, 300 )
   cConstBrojTR := "56480 "
   cParKonv := "5"

   @ 1 + get_x_koord(), 2 + get_y_koord() SAY "PARAMETRI ***"
   @ 3 + get_x_koord(), 2 + get_y_koord() SAY "Sifra isplatioca tek.rac:" GET cConstBrojTR
   @ 4 + get_x_koord(), 2 + get_y_koord() SAY "Naziv fajla prenosa:" GET cLokacija PICT "@S30"
   @ 5 + get_x_koord(), 2 + get_y_koord() SAY "Konverzija znakova:" GET cParKonv

   READ

   BoxC()

   cConstBrojTR := FormatSTR( AllTrim( cConstBrojTR ), 6 )
   cLokacija := AllTrim( cLokacija )

   nH := FCreate( cLokacija )

   IF nH == -1
      MsgBeep( "Greska pri kreiranju fajla !!!" )
      RETURN
   ENDIF

   RETURN



FUNCTION CloseFileBanka( nHnd )

   FClose( nHnd )

   RETURN
