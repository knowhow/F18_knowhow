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


#include "fakt.ch"


FUNCTION fakt_lager_lista()

   PARAMETERS lPocStanje, cIdFirma, qqRoba, dDatOd, dDatDo

   LOCAL nKU, nKI, lSaberiKol
   LOCAL aPorezi := {}, cPoTar := "N"

   PRIVATE nRezerv, nRevers
   PRIVATE nUl, nIzl, nRbr, cRR, nCol1 := 0
   PRIVATE m := ""

   // tekuca strana
   PRIVATE nStr := 0
   PRIVATE cProred := "N"
   PRIVATE nGrZn := 99
   PRIVATE cLastIdRoba := ""

   // testni counter globalna varijabla
   gCnt1 := 0

   lBezUlaza := ( IzFMKINI( "IZVJESTAJI", "BezUlaza", "N", KUMPATH ) == "D" )

   IF lPocStanje == NIL
      lPocStanje := .F.
   ELSE
      lPocStanje := .T.
      O_FAKT_PRIPR
      nRbrPst := 0
      cBrPSt := "00001   "
      Box(, 2, 60 )
      @ m_x + 1, m_y + 2 SAY "Generacija poc. stanja  - broj dokumenta 00 -" GET cBrPSt
      READ
      BoxC()
   ENDIF

   IF lPocStanje
      PRIVATE fId_J := .F.
      IF IzFmkIni( "SifRoba", "ID_J", "N" ) == "D"
         fId_J := .T.
      ENDIF
   ENDIF

   O_FAKT_DOKS
   O_TARIFA
   O_PARTN
   O_SIFK
   O_SIFV
   O_ROBA
   O_RJ

   IF fId_J
      O_FAKT
      // idroba+dtos(datDok)
      SET ORDER TO TAG "3J"
   ELSE
      O_FAKT
      // idroba+dtos(datDok)
      SET ORDER TO TAG "3"
   ENDIF

   lSaberikol := .F.
   nKU := nKI := 0

   IF !gAppSrv
      cIdfirma := gFirma
      qqRoba := ""
      dDatOd := CToD( "" )
      dDatDo := Date()
   ENDIF

   cSaldo0 := "N"
   qqPartn := Space( 20 )
   PRIVATE qqTipdok := "  "

   Box(, 20, 66 )


   O_PARAMS
   PRIVATE cSection := "5"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   Params1()

   IF !gAppSrv
      RPar( "c1", @cIdFirma )
      RPar( "c2", @qqRoba )
      RPar( "c7", @qqPartn )
      RPar( "c8", @qqTipDok )
      RPar( "d1", @dDatOd )
      RPar( "d2", @dDatDo )
   ENDIF


   SELECT fakt


   IF gNW $ "DR"
      // cIdfirma:=gFirma
   ENDIF
   qqRoba := PadR( qqRoba, 60 )
   qqPartn := PadR( qqPartn, 20 )
   qqTipDok := PadR( qqTipDok, 2 )

   cRR := "N"
   cUI := "S"

   PRIVATE cTipVPC := "1"

   cK1 := cK2 := Space( 4 )

   DO WHILE .T.
      IF gNW $ "DR"
         @ m_x + 1, m_y + 2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. cidfirma == gFirma .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 2, m_y + 2 SAY "Roba   "  GET qqRoba   PICT "@!S40"
      @ m_x + 3, m_y + 2 SAY "Naziv partnera (prazno - svi)"  GET qqPartn   PICT "@!"
      @ m_x + 4, m_y + 2 SAY "Tip dokumenta (prazno - svi)"  GET qqTipdok
      @ m_x + 5, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 5, Col() + 1 SAY "do"  GET dDatDo

      IF lBezUlaza
         cRR := "N"
      ELSE
         @ m_x + 6, m_y + 2 SAY "Prikaz rezervacija, reversa (D)"
         @ m_x + 7, m_y + 2 SAY "Prikaz bez rezervacija, reversa (N)"
         @ m_x + 8, m_y + 2 SAY "Prikaz fakturisanog na osnovu otpremnica (F) "  GET cRR   PICT "@!" VALID cRR $ "DNF"
      ENDIF

      @ m_x + 10, m_y + 2 SAY "Prikaz stavki sa stanjem 0 (D/N)    "  GET cSaldo0 PICT "@!" VALID cSaldo0 $ "DN"
      IF gVarC $ "12"
         @ m_x + 11, m_y + 2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  GET cTipVpc PICT "@!" VALID cTipVPC $ "12"
      ENDIF
      @ m_x + 12, m_y + 2 SAY "Napraviti prored (D/N)    "  GET cProred PICT "@!" VALID cProred $ "DN"
      IF !lPocStanje
         @ m_x + 13, m_y + 2 SAY "Prikaz grupacija, grupa ima (99-ne prikazivati)" GET nGrZn PICT "99"
         @ m_x + 13, m_y + 53 SAY "znakova"
      ENDIF
      IF fakt->( FieldPos( "K1" ) ) <> 0 .AND. gDK1 == "D"
         @ m_x + 14, m_y + 2 SAY "K1" GET  cK1 PICT "@!"
         @ m_x + 14, m_y + 15 SAY "K2" GET  cK2 PICT "@!"
      ENDIF

      cPopis := "N"
      @ m_x + 15, m_y + 2 SAY "Prikazati obrazac za popis D/N" GET  cPopis PICT "@!" VALID cPopis $ "DN"

      cRealizacija := "N"
      IF !lBezUlaza
         @ Row() + 1, m_y + 2 SAY "Prikazati realizaciju " GET  cRealizacija PICT "@!" VALID cRealizacija $ "DN"
      ENDIF

      cSintetika := "N"

      IF !lPocStanje .AND. cSintetika == "D"
         @ Row() + 1, m_y + 2 SAY "Sinteticki prikaz? (D/N) " GET  cSintetika PICT "@!" VALID cSintetika $ "DN"
      ELSE
         cSintetika := "N"
      ENDIF

      IF !lBezUlaza
         @ Row() + 1, m_y + 2 SAY "Prikaz kolicina (U-samo ulaz, I-samo izlaz, S-sve)" GET cUI VALID cUI $ "UIS" PICT "@!"
      ELSE
         cUI := "S"
      ENDIF

      @ Row() + 1, m_y + 2 SAY "Prikaz stanja po tarifama? (D/N)" GET cPoTar VALID cPoTar $ "DN" PICT "@!"

      READ

      ESC_BCR
      IF fID_J
         aUsl1 := Parsiraj( qqRoba, "IdRoba_J" )
      ELSE
         aUsl1 := Parsiraj( qqRoba, "IdRoba" )
      ENDIF

      IF aUsl1 <> NIL
         EXIT
      ENDIF

   ENDDO

   IF lBezUlaza
      m := "---- ---------- ----------------------------------------" + " ----------- ---"
   ELSE

      IF cRR $ "NF"
         m := "---- ---------- ----------------------------------------" + iif( cUI == "S", " ----------- -----------", "" ) + " ----------- --- --------- -----------"
      ELSE
         m := "---- ---------- ----------------------------------------" + " ----------- ----------- ----------- ----------- --- --------- -----------"
      ENDIF

      IF gVarC == "4"
         m += " " + Replicate( "-", 12 )
      ENDIF

      IF cRealizacija == "D"
         m += " " + Replicate( "-", 12 ) + " " + Replicate( "-", 12 )
      ENDIF
   ENDIF


   SELECT params
   qqRoba := Trim( qqRoba )


   IF !gAppSrv
      WPar( "c1", cIdFirma )
      WPar( "c2", qqRoba )
      WPar( "c7", qqPartn )
      WPar( "c8", qqTipDok )
      WPar( "d1", dDatOd )
      WPar( "d2", dDatDo )
   ENDIF

   USE

   BoxC()

   fSMark := .F.
   IF Right( qqRoba, 1 ) = "*"
      // izvrsena je markacija robe ..
      fSMark := .T.
   ENDIF

   SELECT FAKT

   PRIVATE cFilt := ".t."

   IF aUsl1 <> ".t."
      cFilt += ".and." + aUsl1
   ENDIF

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilt += ".and. DatDok>=" + cm2str( dDatOd ) + ".and. DatDok<=" + cm2str( dDatDo )
   ENDIF

   IF cFilt == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilt
   ENDIF

   IF gAppSrv
      ? "Filter:", cFilt
      // set filter to
   ENDIF

   GO TOP


   EOF CRET


   START PRINT CRET

   Zaglfakt_lager_lista()

   _cijena := 0
   _cijena2 := 0

   nRbr := 0
   nIzn := 0
   nIzn2 := 0
   nIznR := 0 // iznos rabata
   nRezerv := nRevers := 0
   qqPartn := Trim( qqPartn )
   cidfirma := Trim( cidfirma )

   IF cSintetika == "D"
      bWhile1 := {|| !Eof() .AND. Left( cIdroba, gnDS ) == Left( IdRoba, gnDS )  }
   ELSE
      IF fId_J
         bWhile1 := {|| !Eof() .AND. cIdRoba == IdRoba_J + IdRoba }
      ELSE
         bWhile1 := {|| !Eof() .AND. cIdRoba == IdRoba }
      ENDIF
   ENDIF

   DO WHILE !Eof()
      IF fID_J
         cIdRoba := IdRoba_J + IdRoba
      ELSE
         cIdRoba := IdRoba
      ENDIF

      IF cSintetika == "D"
         NSRNPIdRoba( cIdRoba, .T. ); SELECT FAKT
      ENDIF

      nUl := nIzl := 0
      nRezerv := nRevers := 0
      // nReal1 realizacija , nReal2 - rabat
      nReal1 := 0
      nReal2 := 0

      IF cSintetika == "D"
         bWhile1 := {|| !Eof() .AND. ;
            Left( cIdroba, gnDS ) == Left( IdRoba, gnDS ) }
      ELSE
         IF fId_J
            bWhile1 := {|| !Eof() .AND. cIdRoba == IdRoba_J + IdRoba  }
         ELSE
            bWhile1 := {|| !Eof() .AND. cIdRoba == IdRoba }
         ENDIF
      ENDIF

      DO WHILE Eval( bWhile1 )

         IF !Empty( qqTipDok )
            IF idtipdok <> qqTipDok
               SKIP
               LOOP
            ENDIF
         ENDIF

         IF !Empty( cidfirma )
            IF idfirma <> cidfirma
               SKIP
               LOOP
            ENDIF
         ENDIF

         IF !Empty( qqPartn )
            SELECT fakt_doks
            hseek fakt->( IdFirma + idtipdok + brdok )
            SELECT fakt

            IF !( fakt_doks->partner = qqPartn )
               SKIP
               LOOP
            ENDIF
         ENDIF

         // atributi
         IF !Empty( cK1 ); IF ck1 <> K1; skip; loop; end; END

         IF !Empty( cK2 ); IF ck2 <> K2;  skip; loop; end; END

         IF !Empty( cIdRoba )
            IF cRR <> "F"
               // ulaz
               IF idtipdok = "0"
                  nUl += kolicina
                  IF lSaberikol .AND. !( roba->K2 = 'X' )
                     nKU += kolicina
                  ENDIF
                  // izlaz faktura
               ELSEIF idtipdok = "1"
                  IF !( serbr = "*" .AND. idtipdok == "10" ) // za fakture na osnovu otpremnice ne racunaj izlaz
                     nIzl += kolicina
                     nReal1 += Round( kolicina * Cijena, ZAOKRUZENJE )
                     nReal2 += Round( kolicina * Cijena * ( Rabat / 100 ), ZAOKRUZENJE )
                     IF lSaberikol .AND. !( roba->K2 = 'X' )
                        nKI += kolicina
                     ENDIF
                  ENDIF
               ELSEIF idtipdok $ "20#27"
                  IF serbr = "*"
                     nRezerv += kolicina
                  ENDIF
               ELSEIF idtipdok == "21"
                  nRevers += kolicina
                  IF lSaberikol .AND. !( roba->K2 = 'X' )
                     nKI += kolicina
                  ENDIF
               ENDIF
            ELSE
               // za fakture na osnovu otpremince ne racunaj izlaz
               IF ( serbr = "*" .AND. idtipdok == "10" )
                  nIzl += kolicina
                  // finansijski da !
                  nReal1 += Round( kolicina * Cijena, ZAOKRUZENJE )
                  nReal2 += Round( kolicina * Cijena * ( Rabat / 100 ), ZAOKRUZENJE )
                  IF lSaberikol .AND. !( roba->K2 = 'X' )
                     nKI += kolicina
                  ENDIF
               ENDIF
            ENDIF // crr=="F"
         ENDIF  // empty(
         SKIP
      ENDDO
  	
      IF PRow() > 61 -iif( cProred = "D", 1, 0 )
         Zaglfakt_lager_lista()
      ENDIF

      IF !Empty( cIdRoba )
         IF !( cSaldo0 == "N" .AND. ( nUl - nIzl ) == 0 )
            IF fID_J
               NSRNPIdRoba( SubStr( cIdRoba, 11 ), ( cSintetika == "D" ) )
               // desni dio sifre je interna sifra
            ELSE
               NSRNPIdRoba( cIdRoba, ( cSintetika == "D" ) )
            ENDIF

            IF nGrZn <> 99 .AND. ( Empty( cLastIdRoba ) .OR. Left( cLastIdRoba, nGrZn ) <> Left( cIdRoba, nGrZn ) )
               SELECT ROBA
               PushWA()
               SEEK Left( cIdRoba, nGrZn )
               IF Found() .AND. Right( Trim( id ), 1 ) == "."
                  cNazivGrupacije := Left( cIdRoba, nGrZn ) + " " + naz
               ELSE
                  cNazivGrupacije := Left( cIdRoba, nGrZn )
               ENDIF
               PopWA()
               IF cProred == "D"
                  ? Space( gnLMarg ); ?? m
               ENDIF
               ? Space( gnLMarg )
               ?? "GRUPA ARTIKALA: " + cNazivGrupacije
               cLastIdRoba := cIdRoba
            ENDIF
            SELECT FAKT
            IF cProred == "D"
               ? Space( gnLMarg ); ?? m
            ENDIF
            ? Space( gnLMarg )
            ?? Str( ++nRbr, 4 ), ;
               IF( cSintetika == "D" .AND. ROBA->tip == "S", ;
               ROBA->id, Left( cidroba, 10 ) ), PadR( ROBA->naz, 40 )

            IF cRR $ "NF" .AND. !lBezUlaza
               IF cUI $ "US"
                  @ PRow(), PCol() + 1 SAY nUl  PICT iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
               ENDIF
               IF cUI $ "IS"
                  @ PRow(), PCol() + 1 SAY nIzl PICT iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
               ENDIF
            ENDIF

            IF lBezUlaza
               nCol1 := PCol() + 1
            ENDIF
            IF cUI == "S"
               @ PRow(), PCol() + 1 SAY nUl - nIzl PICT iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
            ENDIF

            IF cRR == "D"
               @ PRow(), PCol() + 1 SAY nRevers PICT iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
               @ PRow(), PCol() + 1 SAY nRezerv PICT iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
               @ PRow(), PCol() + 1 SAY nUl - nIzl - nRevers - nRezerv PICT iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
            ENDIF
            @ PRow(), PCol() + 1 SAY roba->jmj
            IF cTipVPC == "2" .AND.  roba->( FieldPos( "vpc2" ) <> 0 )
               _cijena := roba->vpc2
            ELSE
               _cijena := if ( !Empty( cIdFirma ), fakt_mpc_iz_sifrarnika(), roba->vpc )
            ENDIF
            IF gVarC == "4"
               _cijena2 := roba->mpc
            ENDIF

            IF lPocStanje
               SELECT fakt_pripr
               IF cRR = "D"
                  nPrenesi := -nRevers - nRezerv
               ELSE
                  nPrenesi := nUl - nIzl
               ENDIF
               IF Round( nPrenesi, 4 ) <> 0
                  APPEND BLANK
                  REPLACE idfirma WITH cidfirma, idroba WITH Left( cIdRoba, 10 ), ;
                     datdok WITH dDatDo + 1, ;
                     idtipdok WITH "00", brdok WITH cBRPST,;
                     cijena WITH _cijena, ;
                     dindem WITH "KM ", ;
                     Rbr WITH Rednibroj( ++nRbrPst ), ;
                     kolicina WITH nPrenesi

                  IF fId_J
                     REPLACE idroba_J WITH Left( cIdRoba, 10 ), ;
                        idroba WITH SubStr( cIdroba, 11 )
                  ENDIF
                  REPLACE txt   WITH Chr( 16 ) + "" + Chr( 17 ) + ;
                     Chr( 16 ) + "" + Chr( 17 ) + Chr( 16 ) + "POCETNO STANJE" + Chr( 17 ) + ;
                     Chr( 16 ) + "" + Chr( 17 ) + Chr( 16 ) + "" + Chr( 17 )

               ENDIF
               SELECT fakt
            ENDIF

            IF cPoTar == "D"
               nMpv := ( nUl - nIzl ) * roba->mpc
               nPom := AScan( aPorezi, {| x| x[ 1 ] == roba->idTarifa } )
               IF nPom > 0
                  aPorezi[ nPom, 2 ] := aPorezi[ nPom, 2 ] + nMpv
               ELSE
                  AAdd( aPorezi, { roba->idTarifa, nMpv } )
               ENDIF
            ENDIF

            IF cRealizacija == "D"
               IF nIzl > 0
                  @ PRow(), PCol() + 1 SAY ( nReal1 - nReal2 ) / nIzl  PICT "99999.999"
               ELSE
                  @ PRow(), PCol() + 1 SAY 0  PICT "99999.999"
               ENDIF
               nCol1 := PCol() + 1
               @ PRow(), nCol1 SAY nReal1  PICT picdem
               @ PRow(), PCol() + 1 SAY nReal2  PICT picdem
               @ PRow(), PCol() + 1 SAY nReal1 - nReal2  PICT picdem
               nIzn += nReal1
               nIznR += nReal2
            ELSE
               nPomSt := IF( cUI == "S", nUl - nIzl, IF( cUI == "I", nIzl, nUl ) )
               IF !lBezUlaza
                  @ PRow(), PCol() + 1 SAY _cijena  PICT "99999.999"
                  nCol1 := PCol() + 1
                  @ PRow(), nCol1 SAY nPomSt * _cijena   PICT iif( cPopis == "N", picdem, Replicate( "_", Len( Picdem ) ) )
               ENDIF
               nIzn += nPomSt * _cijena
               IF gVarC == "4" // uporedo
                  IF !lBezUlaza
                     @ PRow(), PCol() + 1 SAY _cijena2   PICT picdem
                  ENDIF
                  nIzn2 += nPomSt * _cijena2
               ENDIF
            ENDIF

         ENDIF
      ENDIF

   ENDDO

   IF PRow() > 59
      Zaglfakt_lager_lista()
   ENDIF

   IF !lBezUlaza
      ? Space( gnLMarg )
      ?? m
      ? Space( gnLMarg )
      ?? " Ukupno:"
      IF cPopis == "N"
         @ PRow(), nCol1 SAY nIzn  PICT picdem
         IF cRealizacija == "D"
            @ PRow(), PCol() + 1 SAY nIznR  PICT picdem
            @ PRow(), PCol() + 1 SAY nIzn - nIznR  PICT picdem
         ENDIF
         IF gVarC == "4"
            ? Space( gnLMarg )
            IF IsPDV()
               ?? " Ukupno  PV:"
            ELSE
               ?? " Ukupno MPV:"
            ENDIF

            @ PRow(), nCol1 SAY nIzn2  PICT picdem
         ENDIF
      ENDIF
   ENDIF

   ? Space( gnLMarg )
   ?? m

   IF lSaberikol
      ? Space( gnLMarg ); ?? " Ukupno (kolicine):"
      IF lBezUlaza
         @ PRow(), nCol1 SAY nKU - nKI PICTURE iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
      ELSE
         IF cUI $ "US"
            @ PRow(), nCol1 - ( Len( picdem ) + 1 ) * 4 - 2  SAY nKU  PICTURE iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
         ENDIF
         IF cUI $ "IS"
            IF cUI == "I"
               @ PRow(), nCol1 - ( Len( picdem ) + 1 ) * 4 - 2 SAY nKI  PICTURE iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
            ELSE
               @ PRow(), PCol() + 1 SAY nKI  PICTURE iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
            ENDIF
         ENDIF
         IF cUI == "S"
            @ PRow(), PCol() + 1 SAY nKU - nKI PICTURE iif( cPopis == "N", pickol, Replicate( "_", Len( PicKol ) ) )
         ENDIF
      ENDIF
      ? Space( gnLMarg )
      ?? m
   ENDIF

   IF cPoTar == "D"
      IF PRow() > 59
         Zaglfakt_lager_lista()
      ENDIF
      ?
      z0 := "Rekapitulacija stanja po tarifama:"
      ? z0
      m := "------" + REPL( " " + REPL( "-", Len( gPicProc ) ), 3 ) + REPL( " " + REPL( "-", Len( PicDem ) ), 5 )
      ? m
      z1 := "Tarifa" + PadC( "PPP%", Len( gPicProc ) + 1 ) + PadC( "PPU%", Len( gPicProc ) + 1 ) + PadC( "PP%", Len( gPicProc ) + 1 ) + PadC( "MPV", Len( PicDem ) + 1 ) + PadC( "PPP", Len( PicDem ) + 1 ) + PadC( "PPU", Len( PicDem ) + 1 ) + PadC( "PP", Len( PicDem ) + 1 ) + PadC( "MPV+por", Len( PicDem ) + 1 )
      ? z1
      ? m
      ASort( aPorezi, {| x, y| x[ 1 ] < y[ 1 ] } )
      nUMPV := nUMPV0 := nUPor1 := nUPor2 := nUPor3 := 0
      FOR i := 1 TO Len( aPorezi )
         IF PRow() > 59
            Zaglfakt_lager_lista()
            ?
            ? z0
            ? m
            ? z1
            ? m
         ENDIF
         SELECT tarifa
         hseek aPorezi[ i, 1 ]
         fakt_vt_porezi()
         nMPV := aPorezi[ i, 2 ]
         nMPV0 := Round( nMPV / ( _ZPP + ( 1 + _OPP ) * ( 1 + _PPP ) ), ZAOKRUZENJE )
         nPor1 := Round( nMPV / ( _ZPP + ( 1 + _OPP ) * ( 1 + _PPP ) ) * _OPP, ZAOKRUZENJE )
         nPor2 := Round( nMPV / ( _ZPP + ( 1 + _OPP ) * ( 1 + _PPP ) * ( 1 + _OPP ) ) * _PPP, ZAOKRUZENJE )
         nPor3 := Round( nMPV / ( _ZPP + ( 1 + _OPP ) * ( 1 + _PPP ) ) * _ZPP, ZAOKRUZENJE )
         ? aPorezi[ i, 1 ], TRANS( 100 * _OPP, gPicProc ), TRANS( 100 * _PPP, gPicProc ), TRANS( 100 * _ZPP, gPicProc ), TRANS( nMPV0, PicDem ), TRANS( nPor1, PicDem ), TRANS( nPor2, PicDem ), TRANS( nPor3, PicDem ), TRANS( nMPV, PicDem )
         nUMPV += nMPV
         nUMPV0 += nMPV0
         nUPor1 += nPor1
         nUPor2 += nPor2
         nUPor3 += nPor3
      NEXT
      ? m
      ? PadR( "UKUPNO:", 3 * ( Len( gPicProc ) + 1 ) + 6 ), TRANS( nUMPV0, PicDem ), TRANS( nUPor1, PicDem ), TRANS( nUPor2, PicDem ), TRANS( nUPor3, PicDem ), TRANS( nUMPV, PicDem )
      ?
   ENDIF

   FF
   ENDPRINT

   my_close_all_dbf()

   RETURN



/*! \fn Zaglfakt_lager_lista()
 *  \brief Zaglavlje lager liste
 */

FUNCTION Zaglfakt_lager_lista()

   LOCAL cPomZK
   LOCAL _rj_tip := ""

   IF rj->( FieldPos( "tip" ) ) <> 0 .AND. rj->tip <> NIL
      _rj_tip := rj->tip
   ENDIF

   IF nStr > 0
      FF
   ENDIF

   ?
   P_COND
   SET CENTURY ON
   ? Space( 4 ), "   FAKT: Lager lista robe na dan", Date(), "      za period od", dDatOd, "-", dDatDo, Space( 6 ), "Strana:", Str( ++nStr, 3 )
   SET CENTURY OFF
   ?

   IF cUI == "U"
      ? Space( 4 ), "         (prikaz samo ulaza)"
      ?
   ELSEIF cUI == "I"
      ? Space( 4 ), "         (prikaz samo izlaza)"
      ?
   ENDIF

   IF cRR == "D"
      P_COND2
   ELSE
      P_COND
   ENDIF

   IF cRealizacija == "D"
      P_COND2
      ?
      ? Space( gnLMarg )
      ?? "**** FINANSIJSKI: PRIKAZ REALIZACIJE *****"
      ?
   ENDIF

   ? Space( gnLMarg )
   IspisFirme( cidfirma )

   IF !Empty( qqRoba )
      ? Space( gnLMarg )
      ?? "Roba:", qqRoba
   ENDIF

   IF !Empty( cK1 )
      ?
      ? Space( gnlmarg ), "- Roba sa osobinom K1:", ck1
   ENDIF

   IF !Empty( cK2 )
      ?
      ? Space( gnlmarg ), "- Roba sa osobinom K2:", ck2
   ENDIF

   ?

   IF cRealizacija == "N" .AND. cTipVPC == "2" .AND.  roba->( FieldPos( "vpc2" ) <> 0 )
      ? Space( gnlmarg )
      ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: " + cTipVPC
   ENDIF

   ?
   ? Space( gnLMarg )
   ?? m
   ? Space( gnLMarg )

   IF lBezUlaza
      ?? "R.br  Sifra       Naziv                                  "  + "  Stanje    jmj     "
   ELSE
      cPomZK := IIF( cUI $ "US", PadC( "Ulaz", 12 ), "" ) + ;
         IF( cUI $ "IS", PadC( "Izlaz", 12 ), "" ) + ;
         IF( cUI $ "S", PadC( "Stanje", 12 ), "" )
      IF cRR $ "NF"
         IF IsPDV()
            ?? "R.br  Sifra       Naziv                                  " + cPomZK + "jmj     " + iif( _rj_tip $ "N1#M1#M2" .AND. !Empty( cIdFirma ), "Cij.", iif( cRealizacija == "D", "PR.C", " PC " ) ) + ;
               iif( cREalizacija == "N", "      Iznos", "       PV        Rabat      Realizovano" )
         ELSE
            ?? "R.br  Sifra       Naziv                                  " + cPomZK + "jmj     " + iif( _rj_tip $ "N1#M1#M2" .AND. !Empty( cIdFirma ), "Cij.", iif( cRealizacija == "D", "PR.C", "VPC " ) ) + ;
               iif( cREalizacija == "N", "      Iznos", "      VPV        Rabat      Realizovano" )
         ENDIF
      ELSE
         ?? "R.br  Sifra       Naziv                                  " + "  Stanje       Revers    Rezervac.   Ostalo     jmj     " + IF( RJ->tip $ "N1#M1#M2" .AND. !Empty( cIdFirma ), "Cij.  Cij.", "VPC    VPC" ) + "*Stanje"
      ENDIF
      IF gVarC == "4"
         ?? PadC( "MPV", 13 )
      ENDIF
   ENDIF

   ? Space( gnLMarg )
   ?? m

   ShowKorner( nStr, 1, 16 )

   RETURN




// -----------------------------------------------------------------
// uslovi izvjestaja lager lista
// -----------------------------------------------------------------
FUNCTION fakt_lager_lista_vars( param, ps )

   LOCAL _ret := 1
   LOCAL _x := 1
   LOCAL _id_firma, _usl_roba, _usl_partn, _usl_tip_dok
   LOCAL _date_from, _date_to
   LOCAL _stavke_nula, _tip_prikaza
   LOCAL _date_ps

   IF ps == NIL
      // nije pocetno stanje
      _date_ps := NIL
      ps := .F.
      _date_from := fetch_metric( "fakt_lager_lista_datum_od", my_user(), Date() )
      _date_to := fetch_metric( "fakt_lager_lista_datum_do", my_user(), Date() )
   ELSE
      // pocetno stanje je u pitanju
      _date_ps := CToD( "01.01." + AllTrim( Str( Year( Date() ) ) ) )
      _date_from := CToD( "01.01." + AllTrim( Str( Year( Date() ) -1 ) ) )
      _date_to := CToD( "31.12." + AllTrim( Str( Year( Date() ) -1 ) ) )
   ENDIF

   _stavke_nula := "N"
   _tip_prikaza := "S"
   _usl_roba := Space( 300 )
   _usl_partn := Space( 300 )
   _usl_tip_dok := Space( 200 )
   _id_firma := gFirma

   Box(, 10, 70 )

   @ m_x + _x, m_y + 2 SAY "RJ (prazno-sve): " GET _id_firma VALID {|| Empty( _id_firma ), P_RJ( @_id_firma ), _id_firma := Left( _id_firma, 2 ), .T. }

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Datum od:" GET _date_from
   @ m_x + _x, Col() + 1 SAY "do:" GET _date_to

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Roba   " GET _usl_roba PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Naziv partnera (prazno - svi)" GET _usl_partn PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Tip dokumenta (prazno - svi)" GET _usl_tip_dok PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Prikaz stavki sa stanjem 0 (D/N)    " GET _stavke_nula PICT "@!" VALID _stavke_nula $ "DN"

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Prikaz količina ( U-samo ulaz, I-samo izlaz, S-sve )" GET _tip_prikaza VALID _tip_prikaza $ "UIS" PICT "@!"

   IF ps
      ++ _x
      ++ _x
      @ m_x + _x, m_y + 2 SAY8 "Datum početnog stanja:" GET _date_ps
   ENDIF

   READ

   BoxC()

   IF LastKey() == K_ESC
      _ret := 0
   ENDIF

   // snimi db parametre
   // nemoj ako je pocetno stanje u pitanju...
   IF !ps
      set_metric( "fakt_lager_lista_datum_od", my_user(), _date_from )
      set_metric( "fakt_lager_lista_datum_do", my_user(), _date_to )
   ENDIF

   // snimi parametre
   PARAM[ "datum_od" ] := _date_from
   PARAM[ "datum_do" ] := _date_to
   PARAM[ "datum_ps" ] := _date_ps
   PARAM[ "artikli" ] := _usl_roba
   PARAM[ "partneri" ] := _usl_partn
   PARAM[ "dokumenti" ] := _usl_tip_dok
   PARAM[ "stavke_nula" ] := _stavke_nula
   PARAM[ "tip_prikaza" ] := _tip_prikaza
   PARAM[ "id_firma" ] := _id_firma

   RETURN _ret




// -----------------------------------------------------------------
// generisanje xml fajla za lager listu
// -----------------------------------------------------------------
STATIC FUNCTION lager_lista_xml( table, params )

   LOCAL _ret := .T.
   LOCAL _row
   LOCAL _id_roba, _ulaz, _izlaz, _stanje
   LOCAL _count := 0
   LOCAL _t_ulaz := 0
   LOCAL _t_izlaz := 0
   LOCAL _t_stanje := 0

   O_ROBA
   O_PARTN

   // ima li zapisa...
   IF table:LastRec() == 0
      RETURN .F.
   ENDIF

   open_xml( _xml )
   xml_subnode( "lager", .F. )

   // podaci zaglavlja...
   // xml_node( "firma", gFirma )
   // xml_node( "datum_od", gFirma )
   // xml_node( "datum_do", gFirma )
   // xml_node( "roba", gFirma )

   table:GoTo(1)

   DO WHILE !table:Eof()

      _row := table:GetRow()

      _id_roba := _row:FieldGet( _row:FieldPos( "idroba" ) )
      _ulaz := _row:FieldGet( _row:FieldPos( "ulaz" ) )
      _izlaz := _row:FieldGet( _row:FieldPos( "izlaz" ) )

      IF params[ "tip_prikaza" ] == "U"
         _izlaz := 0
      ELSEIF params[ "tip_prikaza" ] == "I"
         _ulaz := 0
      ENDIF

      _stanje := ( _ulaz - _izlaz )

      _t_stanje += _stanje
      _t_ulaz += _ulaz
      _t_izlaz += _izlaz

      SELECT roba
      hseek _id_roba

      _cijena := roba->vpc

      // sta sa uslugama ???
      IF roba->tip == "U"
      ENDIF

      IF params[ "stavke_nula" ] == "N" .AND. Round( _stanje, 2 ) == 0
         table:Skip()
         LOOP
      ENDIF

      xml_subnode( "item", .F. )

      xml_node( "rbr", AllTrim( Str( ++_count ) ) )
      xml_node( "id", to_xml_encoding( _id_roba ) )
      xml_node( "naz", to_xml_encoding( roba->naz ) )
      xml_node( "jmj", to_xml_encoding( roba->jmj ) )
      xml_node( "ulaz", Str( _ulaz, 12, 2 ) )
      xml_node( "izlaz", Str( _izlaz, 12, 2 ) )
      xml_node( "stanje", Str( _stanje, 12, 2 ) )
      xml_node( "cijena", Str( _cijena, 12, 2 ) )

      xml_subnode( "item", .T. )

      table:Skip()

   ENDDO

   // totali lagerice
   xml_node( "t_ulaz", Str( _t_ulaz, 12, 2 ) )
   xml_node( "t_izlaz", Str( _t_izlaz, 12, 2 ) )
   xml_node( "t_stanje", Str( _t_stanje, 12, 2 ) )

   xml_subnode( "lager", .T. )
   close_xml()

   RETURN _ret



FUNCTION fakt_lager_lista_sql( param, ps )

   LOCAL _table
   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _db_params := my_server_params()

   IF param == NIL
      IF fakt_lager_lista_vars( @param ) == 0
         RETURN
      ENDIF
   ENDIF

   IF ps == NIL
      ps := .F.
   ENDIF

   _table := fakt_lager_lista_get_data( param, ps )

   RETURN _table



STATIC FUNCTION fakt_lager_lista_get_data( params, ps )

   LOCAL _tek_database := my_server_params()[ "database" ]
   LOCAL _db_params := my_server_params()
   LOCAL _table, _qry, _server
   LOCAL _date_from, _date_to, _data_ps
   LOCAL _id_firma, _usl_roba, _usl_partn, _usl_tip_dok

   _date_from := params[ "datum_od" ]
   _date_to := params[ "datum_do" ]
   _id_firma := params[ "id_firma" ]
   _usl_roba := params[ "artikli" ]
   _usl_partn := params[ "partneri" ]
   _usl_tip_dok := params[ "dokumenti" ]
   _date_ps := params[ "datum_ps" ]

   IF ps == NIL
      ps := .F.
   ENDIF

   IF ps
      my_server_logout()
      _db_params[ "database" ] := Left( _tek_database, Len( _tek_database ) - 4 ) + AllTrim( Str( Year( _date_from ) ) )
      my_server_params( _db_params )
      my_server_login( _db_params )
   ENDIF

   _server := pg_server()

   _qry := "SELECT " + ;
      "f.idroba, r.naz, " + ;
      "SUM( CASE " + ;
      "WHEN idtipdok LIKE '0%' THEN kolicina  " + ;
      "END ) as ulaz, " + ;
      "SUM( CASE " + ;
      "WHEN idtipdok LIKE '1%' THEN kolicina " + ;
      "END ) as izlaz, " + ;
      "r.jmj, " + ;
      "r.vpc " + ;
      "FROM fmk.fakt_fakt f " + ;
      "LEFT JOIN fmk.roba r ON f.idroba = r.id "

   _qry += " WHERE "
   _qry += _sql_cond_parse( "idfirma", _id_firma )
   _qry += " AND " + _sql_date_parse( "datdok", _date_from, _date_to )

   IF !Empty( _usl_roba )
      _qry += " AND " + _sql_cond_parse( "idroba", _usl_roba )
   ENDIF

   IF !Empty( _usl_partn )
      _qry += " AND " + _sql_cond_parse( "idpartner", _usl_partn )
   ENDIF

   IF !Empty( _usl_tip_dok )
      _qry += " AND " + _sql_cond_parse( "idtipdok", _usl_tip_dok )
   ENDIF

   _qry += " GROUP BY f.idroba, r.naz, r.jmj, r.vpc "
   _qry += " ORDER BY f.idroba "

   _table := _sql_query( _server, _qry )

   IF !is_var_objekat_tpquery( _table )
      _table := NIL
   ENDIF

   IF ps
      my_server_logout()
      _db_params[ "database" ] := Left( _tek_database, Len( _tek_database ) - 4 ) + AllTrim( Str( Year( _date_ps ) ) )
      my_server_params( _db_params )
      my_server_login( _db_params )
      _server := pg_server()
   ENDIF

   RETURN _table




FUNCTION fakt_vt_porezi()

   PUBLIC _ZPP := 0

   IF roba->tip == "V"
      PUBLIC _OPP := 0, _PPP := tarifa->ppp / 100
      PUBLIC _PORVT := tarifa->opp / 100
   ELSEIF roba->tip == "K"
      PUBLIC _OPP := tarifa->opp / 100, _PPP := tarifa->ppp / 100
      PUBLIC _PORVT := tarifa->opp / 100
   ELSE
      PUBLIC _OPP := tarifa->opp / 100
      PUBLIC _PPP := tarifa->ppp / 100
      PUBLIC _ZPP := tarifa->zpp / 100
      PUBLIC _PORVT := 0
   ENDIF

   RETURN


