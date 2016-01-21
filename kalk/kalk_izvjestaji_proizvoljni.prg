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


FUNCTION ProizvKalk()

   proizvoljni_izvjestaji()

   RETURN


FUNCTION OtBazPIKalk()

   O_ROBA
   O_TARIFA
   OProizv()

   RETURN


FUNCTION GenProIzvKalk()

   LOCAL nPr := 1, lKumSuma := .F.
   PRIVATE lDvaKonta := .F.  // ? ukinuti ovu var. ?
   PRIVATE lKljuc := .F.
   PRIVATE lArtikli := .F.

   // privatne var. koje bi trebalo inicijalizovati iz aplikacije
   // -----------------------------------------------------------

   // neophodne privatne varijable (pogodno za ELIB-a)
   // -------------------------------------------------
   dOd := CToD( "" ); dDo := Date()
   gTabela := 1; cPrikBezDec := "D"; cSaNulama := "D"; nKorZaLands := -18

   lIzrazi := .F.

   // --------------------------
   // POCETAK izvjestajnog upita
   // --------------------------
   O_PARAMS
   PRIVATE cSection := "I", cHistory := " ", aHistory := {}
   RPar( "03", @dOd )
   RPar( "04", @dDo )
   RPar( "05", @gTabela )
   RPar( "06", @cPrikBezDec )
   RPar( "07", @cSaNulama )
   RPar( "08", @nKorZaLands )
   SELECT PARAMS; USE

   Box(, 10, 70 )
   @ m_x + 4, m_y + 2 SAY "Period izvjestavanja od" GET dOd
   @ m_x + 5, m_y + 2 SAY "                     do" GET dDo
   READ
   BoxC()

   IF LastKey() == K_ESC
      CLOSERET
   ENDIF

   O_PARAMS
   PRIVATE cSection := "I", cHistory := " ", aHistory := {}
   WPar( "03", dOd )
   WPar( "04", dDo )
   SELECT PARAMS; USE
   // -----------------------
   // KRAJ izvjestajnog upita
   // -----------------------


   // dobro je odmah znati koriste li se uslovi za konta u kolonama
   // jer ce to omoguciti brzi rad na jednostavnijim izvjestajima
   // -------------------------------------------------------------
   SELECT KONIZ
   SET ORDER TO TAG "1"
   SET FILTER TO
   SET FILTER TO izv == cBrI
   GO TOP
   DO WHILE !Eof()
      IF Left( KONIZ->fi, 1 ) == "="; lIzrazi := .T. ; ENDIF
      // if !EMPTY(K2) .or. !EMPTY(ID2) .or. !EMPTY(FI2); lDvaKonta:=.t.; endif
      IF ri <> 0 .AND. Upper( Left( k, 1 ) ) == "K"; lKljuc := .T. ; ENDIF
      SKIP 1
   ENDDO

   aKolS := {}
   i := 0
   SELECT KOLIZ
   SET FILTER TO
   SET FILTER TO id == cBrI
   SET ORDER TO TAG "1"
   GO TOP
   DO WHILE !Eof()
      IF !Empty( KUSLOV )
         ++i
         AAdd( aKolS, { "KOL" + AllTrim( Str( i ) ), Trim( kuslov ) + IF( Upper( k1 ) == "K", "", ".and.DATDOK>=" + cm2str( dOd ) ), 0, Trim( sizraz ) } )
      ENDIF
      IF "KUMSUMA" $ FORMULA
         lKumSuma := .T.
      ENDIF
      IF "ROBA->" $ Upper( KUSLOV )
         lArtikli := .T.
      ENDIF
      SKIP 1
   ENDDO


   // --------------------------------------
   // POCETAK kreiranja pomocne baze POM.DBF
   // --------------------------------------
   SELECT ( F_POM )
   USE
   IF FErase( PRIVPATH + "POM.DBF" ) == -1
      MsgBeep( "Ne mogu izbrisati POM.DBF!" )
      ShowFError()
   ENDIF
   IF FErase( PRIVPATH + "POM.CDX" ) == -1
      MsgBeep( "Ne mogu izbrisati POM.CDX!" )
      ShowFError()
   ENDIF

   aDbf := {}
   AAdd ( aDbf, { "NRBR", "N",  5, 0 } )
   AAdd ( aDbf, { "KONTO", "C", 20, 0 } )
   AAdd ( aDbf, { "IMEKONTA", "C", 57, 0 } )
   IF !lKljuc
      AAdd ( aDbf, { "KUMSUMA", "N", 15, 2 } )
      AAdd ( aDbf, { "TEKSUMA", "N", 15, 2 } )
      AAdd ( aDbf, { "KPGSUMA", "N", 15, 2 } )
      AAdd ( aDbf, { "DUGUJE", "N", 15, 2 } )
      AAdd ( aDbf, { "POTRAZUJE", "N", 15, 2 } )
      AAdd ( aDbf, { "USLOV", "C", 80, 0 } )
      AAdd ( aDbf, { "SINT", "C",  2, 0 } )          // "Sn" ili "  "
   ENDIF
   AAdd ( aDbf, { "PREDZNAK", "N",  2, 0 } )          // "-1" ili " 1"
   AAdd ( aDbf, { "PODVUCI", "C",  1, 0 } )
   AAdd ( aDbf, { "K1", "C",  1, 0 } )          //
   AAdd ( aDbf, { "U1", "C",  3, 0 } )          // npr. >0 ili <0
   AAdd ( aDbf, { "AOP", "C",  5, 0 } )

   // polja koja se koriste u situaciji kada je neophodno postavljanje
   // dva razlicita uslova(filtera) na jednoj izvjestajnoj stavci
   // ----------------------------------------------------------------
   IF lDvaKonta
      AAdd ( aDbf, { "KONTO2", "C", 20, 0 } )
      AAdd ( aDbf, { "KUMSUMA2", "N", 15, 2 } )
      AAdd ( aDbf, { "TEKSUMA2", "N", 15, 2 } )
      AAdd ( aDbf, { "DUGUJE2", "N", 15, 2 } )
      AAdd ( aDbf, { "POTRAZUJE2", "N", 15, 2 } )
      AAdd ( aDbf, { "USLOV2", "C", 80, 0 } )
      AAdd ( aDbf, { "SINT2", "C",  2, 0 } )          // "Sn" ili "  "
      AAdd ( aDbf, { "PREDZNAK2", "N",  2, 0 } )          // "-1" ili " 1"
   ENDIF

   // polja koja su neophodna za slucaj razlicitih uslova(filtera) na
   // izvjestajnim kolonama
   // ---------------------------------------------------------------
   IF !Empty( aKolS )
      FOR i := 1 TO Len( aKolS )
         AAdd ( aDbf, { aKolS[ i, 1 ], "N", 15, 2 } )
      NEXT
   ENDIF


   DBCREATE2 ( PRIVPATH + "POM", aDbf )
   SELECT ( F_POM )
   usex ( PRIVPATH + "pom" )

   INDEX ON KONTO  TAG "1"
   IF lDvaKonta
      INDEX ON KONTO2 TAG "2"
   ENDIF
   INDEX ON AOP    TAG "3"
   GO TOP
   // -----------------------------------
   // KRAJ kreiranja pomocne baze POM.DBF
   // -----------------------------------


   // otvorimo neophodne baze, filterisimo osnovni
   // izvor (bazu) podataka i zadajmo odgovarajuci sort
   // -------------------------------------------------

   // dio za aplikaciju
   // ------------------
   cFilter := "DATDOK<=" + cm2str( dDo )

   IF !lKumSuma .AND. !lKljuc
      cFilter += ( ".and.DATDOK>=" + cm2str( dOd ) )
   ENDIF

   // priprema kljucnih baza za izvjestaj (indeksi, filteri)
   // ------------------------------------------------------
   MsgO( "Indeksiranje i filterisanje u toku..." )
   PripKBPI()
   MsgC()

   MsgO( "Counting ..." )
   nStavki := 0
   GO TOP
   nStavki := 100
   Msgc()


   // -----------------------------------------
   // POCETAK pripreme baze POM.DBF (stavljanje
   // opisnih podataka, uslova i formula)
   // -----------------------------------------
   SELECT KONIZ
   GO TOP
   COUNT TO i
   Postotak( 1, nStavki + i, "Priprema izvjestaja" )
   nStavki := 0

   nPomRbr := 0
   GO TOP
   DO WHILE !Eof() .AND. izv == cBrI                   // listam KONIZ.DBF
      Postotak( 2, ++nStavki )
      IF KONIZ->ri == 0
         SKIP 1; LOOP
      ENDIF

      // na osnovu tipa stavke u KONIZ-u odre�ujemo dalje akcije
      cTK11  := Upper( Left( KONIZ->k, 1 ) )
      cTK12  := Val( Right( KONIZ->k, 1 ) )

      IF cTK11 == "K"     // idi po kljucu
         lKljuc := .T.
         EXIT
      ENDIF

      lDrugiKonto := .F.
      IF cTK11 == "A"
         cUslovA := Left( KONIZ->id, cTK12 )
         Sel_KSif()
         SEEK cUslovA
         IF Left( id, cTK12 ) != cUslovA .AND. Empty( KONIZ->id2 )
            SELECT KONIZ; SKIP 1; LOOP
         ELSEIF !Empty( KONIZ->id2 )
            lDrugiKonto := .T.
         ENDIF
      ENDIF

      DO WHILE !lDrugiKonto            // ova petlja sluzi samo ako je cTK11="A"

         cIdKonto := KONIZ->id

         IF !Empty( KONIZ->fi )                                // po formuli
            IF Left( KONIZ->fi, 1 ) != "="
               aUslov := Parsiraj( KONIZ->fi, cPIKPolje, "C" )
            ELSE
               aUslov := ".f."
            ENDIF
            cTipK := "F"
            cNazKonta := KONIZ->opis
         ELSEIF cTK11 == "A"
            cNazKonta := IzKSif( "naz" )
            cIdKonto := IzKSif( "id" )
            IF Right( AllTrim( cIdKonto ), 1 ) == "0"       // sintetika
               cTipK := "S"
               cUslov := AllTrim( cIdKonto )
               DO WHILE Right( cUslov, 1 ) == "0"
                  cUslov := Left( cUslov, Len( cUslov ) -1 )
               ENDDO
            ELSE                                      // analitika
               cTipK := "A"
            ENDIF
         ELSEIF cTK11 == "S"
            IF Empty( KONIZ->opis )
               cNazKonta := Ocitaj( F_KSif(), cIdKonto, "naz" )
            ELSE
               cNazKonta := KONIZ->opis
            ENDIF
            cTipK := "S"
            cUslov := Left( cIdKonto, cTK12 )
         ELSEIF Right( AllTrim( cIdKonto ), 1 ) == "0"       // sintetika
            IF Empty( KONIZ->opis )
               cNazKonta := Ocitaj( F_KSif(), cIdKonto, "naz" )
            ELSE
               cNazKonta := KONIZ->opis
            ENDIF
            cTipK := "S"
            cUslov := AllTrim( cIdKonto )
            DO WHILE Right( cUslov, 1 ) == "0"
               cUslov := Left( cUslov, Len( cUslov ) -1 )
            ENDDO
         ELSE                                          // analitika
            cNazKonta := Ocitaj( F_KSif(), cIdKonto, "naz" )
            cTipK := "A"
         ENDIF

         SELECT POM
         APPEND BLANK
         REPLACE NRBR       WITH ++nPomRbr,;
            KONTO      WITH cIdKonto,;
            IMEKONTA   WITH cNazKonta,;
            PODVUCI    WITH KONIZ->podvuci,;
            K1         WITH KONIZ->k1,;
            U1         WITH KONIZ->u1,;
            AOP        WITH Str( KONIZ->RI, 5 )
         IF cTipK != "P"
            REPLACE PREDZNAK   WITH KONIZ->predzn
         ELSE
            REPLACE PREDZNAK   WITH 1
            RazvijUslove( KONIZ->fi )
         ENDIF
         IF cTipK == "F"
            REPLACE uslov WITH KONIZ->fi
         ELSEIF cTipK == "S"
            REPLACE sint WITH "S" + AllTrim( Str( Len( cUslov ) ) )
         ELSEIF cTipK == "P"
            REPLACE sint WITH "F" + AllTrim( Str( Len( cUslov ) ) )
         ENDIF

         IF cTK11 != "A"
            EXIT
         ELSE
            Sel_KSif()
            SKIP 1
            IF Left( id, cTK12 ) != cUslovA
               EXIT
            ENDIF
         ENDIF

      ENDDO                          // ova petlja sluzi samo ako je cTK11="A"

      SELECT KONIZ

      IF !lDvaKonta; SKIP 1; LOOP; ENDIF

      cTK21  := Upper( Left( KONIZ->k2, 1 ) )
      cTK22  := Val( Right( KONIZ->k2, 1 ) )

      IF cTK21 == "A"
         cUslovA2 := Left( KONIZ->id2, cTK22 )
         Sel_KSif()
         SEEK cUslovA2
         IF Left( id, cTK22 ) != cUslovA2
            SELECT KONIZ; SKIP 1; LOOP
         ENDIF
      ENDIF

      DO WHILE !Empty( KONIZ->id2 + KONIZ->fi2 )  // ova petlja se vrti samo ako je
         // cTK21="A"
         cIdKonto2 := KONIZ->id2

         IF !Empty( KONIZ->fi2 )                                // po formuli
            aUslov2 := Parsiraj( KONIZ->fi2, cPIKPolje, "C" )
            cTipK2 := "F"
            cNazKonta := KONIZ->opis
         ELSEIF cTK21 == "A"
            cNazKonta := IzKSif( "naz" )
            cIdKonto2 := IzKSif( "id" )
            IF Right( AllTrim( cIdKonto2 ), 1 ) == "0"       // sintetika
               cTipK2 := "S"
               cUslov2 := AllTrim( cIdKonto2 )
               DO WHILE Right( cUslov2, 1 ) == "0"
                  cUslov2 := Left( cUslov2, Len( cUslov2 ) -1 )
               ENDDO
            ELSE                                      // analitika
               cTipK2 := "A"
            ENDIF
         ELSEIF cTK21 == "S"
            cNazKonta := Ocitaj( F_KSif(), cIdKonto2, "naz" )
            cTipK2 := "S"
            cUslov2 := Left( cIdKonto2, cTK22 )
         ELSEIF Right( AllTrim( cIdKonto2 ), 1 ) == "0"       // sintetika
            cNazKonta := Ocitaj( F_KSif(), cIdKonto2, "naz" )
            cTipK2 := "S"
            cUslov2 := AllTrim( cIdKonto2 )
            DO WHILE Right( cUslov2, 1 ) == "0"
               cUslov2 := Left( cUslov2, Len( cUslov2 ) -1 )
            ENDDO
         ELSE                                          // analitika
            cNazKonta := Ocitaj( F_KSif(), cIdKonto2, "naz" )
            cTipK2 := "A"
         ENDIF

         SELECT POM
         my_flock()
         IF lDrugiKonto
            APPEND BLANK
            REPLACE NRBR       WITH ++nPomRbr,;
               KONTO      WITH KONIZ->id,;
               IMEKONTA   WITH cNazKonta,;
               PODVUCI    WITH KONIZ->podvuci,;
               K1         WITH KONIZ->k1,;
               U1         WITH KONIZ->u1,;
               AOP        WITH Str( KONIZ->RI, 5 )
            REPLACE PREDZNAK   WITH KONIZ->predzn
         ENDIF
         REPLACE KONTO2     WITH cIdKonto2
         REPLACE PREDZNAK2  WITH KONIZ->predzn2
         IF cTipK2 == "F"
            REPLACE uslov2 WITH KONIZ->fi2
         ELSEIF cTipK2 == "S"
            REPLACE sint2 WITH "S" + AllTrim( Str( Len( cUslov2 ) ) )
         ENDIF
         my_unlock()
         IF cTK21 != "A"
            EXIT
         ELSE
            Sel_KSif()
            SKIP 1
            IF Left( id, cTK22 ) != cUslovA2
               EXIT
            ENDIF
         ENDIF

      ENDDO                          // ova petlja sluzi samo ako je cTK21="A"

      SELECT KONIZ; SKIP 1
   ENDDO                                       // listam KONIZ.DBF
   // --------------------------
   // KRAJ pripreme baze POM.DBF
   // --------------------------


   // ---------------------------------------------------------------
   // konacno, uzimam podatke iz osnovnog izvora podataka (SUBAN.DBF)
   // i smjestam ih u POM.DBF prema postojecim formulama i uslovima
   // ---------------------------------------------------------------
   IF lKljuc                               // varijanta KONIZ->K="K"


      nPomRbr := 0
      nPr := KONIZ->predzn

      Sel_KBaza()
      GO TOP

      IF lArtikli
         cLastArt := idroba
         nArr := Select()
         SELECT ROBA; HSEEK cLastArt
         SELECT ( nArr )
      ENDIF

      DO WHILE !Eof()
         cIdKonto := &cPIKPolje
         nDug := nPot := 0
         FOR i := 1 TO Len( aKolS )
            aKolS[ i, 3 ] := 0
         NEXT
         DO WHILE !Eof() .AND. cIdKonto == &cPIKPolje
            IF lArtikli
               IF cLastArt <> idroba
                  cLastArt := idroba
                  nArr := Select()
                  SELECT ROBA; HSEEK cLastArt
                  SELECT ( nArr )
               ENDIF
            ENDIF
            Postotak( 2, ++nStavki )
            FOR i := 1 TO Len( aKolS )
               cPom   := aKolS[ i, 2 ]
               cPomIS := aKolS[ i, 4 ]
               IF Empty( cPomIS ); cPomIS := "iznosbhd"; ENDIF
               if &cPom
                  aKolS[ i, 3 ] += ( &cPomIS * nPr )
               ENDIF
            NEXT
            SKIP 1
         ENDDO

         // formula 2 polje (fi2) u KONIZ.DBF iskoristeno za dodatni uslov po redovima
         IF !Empty( koniz->fi2 )
            IF ! &( koniz->fi2 )
               Sel_KBaza()
               LOOP
            ENDIF
         ENDIF

         SELECT POM
         APPEND BLANK
         FOR i := 1 TO Len( aKolS )
            cPom := aKolS[ i, 1 ]
            REPLACE &cPom WITH aKolS[ i, 3 ]
         NEXT
         REPLACE KONTO WITH cIdKonto
         IF cPIKSif != "BEZ"
            REPLACE IMEKONTA WITH Ocitaj( F_KSif(), ;
               PadR( cIdKonto, Len( IzKSif( "ID" ) ) ), ;
               "naz" )
         ENDIF
         REPLACE NRBR WITH ++nPomRbr

         Sel_KBaza()
      ENDDO

   ELSE

      Sel_KBaza()
      GO TOP

      DO WHILE !Eof()
         cIdKonto := &cPIKPolje
         nDug := nPot := nPrDug := nPrPot := 0
         DO WHILE !Eof() .AND. cIdKonto == &cPIKPolje
            Postotak( 2, ++nStavki )
            // �ta sa DATDOK, IZNOSBHD i D_P ?!  VA�NO!
            // ---------------
            IF !lKumSuma .OR. datdok >= dOd   // tekuci period (od datuma dOd)
               IF D_P == "1"           // dug.
                  nDug += iznosbhd
               ELSE                  // pot.
                  nPot += iznosbhd
               ENDIF
            ELSE             // bitno samo za kumul.period (od datuma "  .  .  ")
               IF D_P == "1"           // dug.
                  nPrDug += iznosbhd
               ELSE                  // pot.
                  nPrPot += iznosbhd
               ENDIF
            ENDIF
            SKIP 1
         ENDDO

         nTekSuma := nDug - nPot
         nKumSuma := nTekSuma + nPrDug - nPrPot

         SELECT POM
         SET ORDER TO TAG "1"
         GO TOP
         my_flock()
         DO WHILE !Eof() .AND. Empty( konto )
            IF Empty( uslov ) .OR. Left( uslov, 1 ) == "="; SKIP 1; LOOP; ENDIF
            aUslov := PARSIRAJ( uslov, "cIdKonto", "C" )
            if &aUslov
               REPLACE kumsuma    WITH predznak * nKumSuma + kumsuma,;
                  teksuma    WITH predznak * nTekSuma + teksuma,;
                  duguje     WITH nDug + duguje,;
                  potrazuje  WITH nPot + potrazuje
            ENDIF
            SKIP 1
         ENDDO
         SEEK Left( cIdKonto, 1 )
         DO WHILE !Eof() .AND. cIdKonto >= PadR( konto, Len( cIdKonto ) )
            IF Left( sint, 1 ) == "S" .AND. Left( cIdKonto, Val( Right( sint, 1 ) ) ) == Left( konto, Val( Right( sint, 1 ) ) ) .OR. cIdKonto == PadR( konto, Len( cIdKonto ) )
               REPLACE kumsuma    WITH predznak * nKumSuma + kumsuma,;
                  teksuma    WITH predznak * nTekSuma + teksuma,;
                  duguje     WITH nDug + duguje,;
                  potrazuje  WITH nPot + potrazuje
            ENDIF
            SKIP 1
         ENDDO
         my_unlock()

         IF !lDvaKonta; Sel_KBaza(); LOOP; ENDIF

         SELECT POM; SET ORDER TO TAG "2"; GO TOP
         my_flock()
         DO WHILE !Eof() .AND. Empty( konto2 )
            IF Empty( uslov2 ); SKIP 1; LOOP; ENDIF
            aUslov := PARSIRAJ( uslov2, "cIdKonto", "C" )
            if &aUslov
               REPLACE kumsuma2    WITH predznak2 * nKumSuma + kumsuma2,;
                  teksuma2    WITH predznak2 * nTekSuma + teksuma2,;
                  duguje2     WITH nDug + duguje2,;
                  potrazuje2  WITH nPot + potrazuje2
            ENDIF
            SKIP 1
         ENDDO
         SEEK Left( cIdKonto, 1 )
         DO WHILE !Eof() .AND. cIdKonto >= PadR( konto2, Len( cIdKonto ) )
            IF Left( sint2, 1 ) == "S" .AND. Left( cIdKonto, Val( Right( sint2, 1 ) ) ) == Left( konto2, Val( Right( sint2, 1 ) ) ) .OR. cIdKonto == PadR( konto2, Len( cIdKonto ) )
               REPLACE kumsuma2    WITH predznak2 * nKumSuma + kumsuma2,;
                  teksuma2    WITH predznak2 * nTekSuma + teksuma2,;
                  duguje2     WITH nDug + duguje2,;
                  potrazuje2  WITH nPot + potrazuje2
            ENDIF
            SKIP 1
         ENDDO
         my_unlock()
         Sel_KBaza()
      ENDDO                                      // uzimam podatke iz SUBAN.DBF

   ENDIF
   Postotak( -1 )
   // -----------------------------------------
   // KRAJ uzimanja podataka iz osnovnog izvora
   // -----------------------------------------


   // -----------------------------------------------------
   // odstampajmo zaglavlje i izvjestajnu tabelu iz POM.DBF
   // -----------------------------------------------------
   nBrRedStr := -99
   StZagPI()
   gnLMarg := 0; gOstr := "D"
   StTabPI()

   SELECT POM; USE

   CLOSERET

   RETURN
// }




FUNCTION ParSviIzvjKalk()

   gTabela := 1; cPrikBezDec := "D"; cSaNulama := "D"; nKorZaLands := -18

   O_PARAMS
   PRIVATE cSection := "I", cHistory := " ", aHistory := {}
   RPar( "05", @gTabela )
   RPar( "06", @cPrikBezDec )
   RPar( "07", @cSaNulama )
   RPar( "08", @nKorZaLands )

   Box(, 10, 75 )
   @ m_x + 6, m_y + 2 SAY "TABELA(0/1/2)          " GET gTabela VALID gTabela >= 0 .AND. gTabela <= 2 PICT "9"
   @ m_x + 7, m_y + 2 SAY "Gdje moze, prikaz bez decimala? (D/N)" GET cPrikBezDec VALID cPrikBezDec $ "DN" PICT "@!"
   @ m_x + 8, m_y + 2 SAY "Prikazivati stavke bez prometa? (D/N)" GET cSaNulama VALID cSaNulama $ "DN" PICT "@!"
   @ m_x + 9, m_y + 2 SAY "Korekcija broja redova (za lendskejp)" GET nKorZaLands PICT "999"
   READ


   READ
   BoxC()
   IF LastKey() != K_ESC
      O_PARAMS
      PRIVATE cSection := "I", cHistory := " ", aHistory := {}
      WPar( "05", gTabela )
      WPar( "06", cPrikBezDec )
      WPar( "07", cSaNulama )
      WPar( "08", nKorZaLands )
      SELECT PARAMS; USE
   ENDIF

   RETURN
// }
