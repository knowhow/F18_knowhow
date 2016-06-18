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



FUNCTION ObrazInv()

   LOCAL nRec
   PRIVATE nCnt := i := nT1 := nT4 := nT5 := nT6 := nT7 := 0
   PRIVATE nTT1 := nTT4 := nTT5 := nTT6 := nTT7 := 0
   PRIVATE n1 := n4 := n5 := n6 := n7 := 0
   PRIVATE nCol1 := 0
   PRIVATE PicCDEM := "999999.999"
   PRIVATE PicProc := "999999.99%"
   PRIVATE PicDEM := "@Z 9999999.99"
   PRIVATE Pickol := "@Z 999999"
   PRIVATE dDatOd := Date()
   PRIVATE dDatDo := Date()
   PRIVATE qqKonto := PadR( "132;", 60 )
   PRIVATE qqRoba := Space( 60 )
   PRIVATE cIdKPovrata := Space( 7 )
   PRIVATE ck7 := "N"

   cPrikKol := "D"
   O_PARAMS
   PRIVATE cSection := "F", cHistory := " ", aHistory := {}
   Params1()
   RPar( "c1", @cIdKPovrata )
   RPar( "c2", @qqKonto )
   RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo )

   cPoc := "D"
   cSNule := "N"
   cProredPC := "D"
   cObrNivelacije := "N"
   Box(, 15, 77 )
   SET CURSOR ON
   cNObjekat := Space( 20 )
   cKartica := "D"
   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Kriterij za objekte:" GET qqKonto PICT "@!S50"
      @ m_x + 3, m_y + 2 SAY "tekuci promet je period:" GET dDatOd
      @ m_x + 3, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 4, m_y + 2 SAY "Naziv objekta:" GET cNObjekat PICT "@!"
      @ m_x + 5, m_y + 2 SAY "Kriterij za robu :" GET qqRoba PICT "@!S50"
      @ m_x + 6, m_y + 2 SAY "Prikaz samo pocetnog stanja:" GET cPOC PICT "@!" VALID cPoc $ "DN"
      @ m_x + 7, m_y + 2 SAY "Prikaz starih artikala sa stanjem 0:" GET cSNule PICT "@!" VALID cSNule $ "DN"
      @ m_x + 9, m_y + 2 SAY "Magacin u koji se vrsi povrat rekl. robe:" GET cIdKPovrata PICT "@!"
      @ m_x + 10, m_Y + 2 SAY "Prikazi kolicine na obrascu"  GET cPrikKol PICT "@!" VALID cPrikkol $ "DN"
      @ m_x + 11, m_Y + 2 SAY "Atribut K2=X ne vrsi se  zbrajanje kolicina"
      @ m_x + 12, m_Y + 2 SAY "Cijene ocitavati sa kartica D/N" GET  cKartica PICT "@!" VALID ckartica $ "DN"
      @ m_x + 14, m_Y + 2 SAY "Prikazati obrazac promjene cijena D/N/2" GET  cObrNivelacije PICT "@!" VALID cObrNivelacije $ "DN2"
      @ m_x + 15, m_Y + 2 SAY "Prikazati sa proredom D/N" GET  cProredPC PICT "@!" VALID cProredPC $ "DN"
      READ
      ESC_BCR
      aUsl1 := Parsiraj( qqKonto, "MKonto" )
      aUsl2 := Parsiraj( qqKonto, "PKonto" )
      aUslR := Parsiraj( qqRoba, "IdRoba" )
      IF aUsl1 <> NIL .AND. aUslR <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   IF Params2()
      WPar( "c1", cIdKPovrata )
      WPar( "c2", @qqKonto )
      WPar( "d1", dDatOd )
      WPar( "d2", dDatDo )
   ENDIF
   SELECT params
   USE

#ifdef PROBA
   ?? aUslr
   Inkey( 0 )
#endif

   brisi_tabelu_pobjekti()
   napuni_tabelu_pobjekti_iz_objekti()

   CreTblRek1( "2" )

   O_POBJEKTI
   o_koncij()
   O_ROBA
   O_KONTO
   O_TARIFA
   O_K1
   O_OBJEKTI
   o_kalk()
   O_REKAP1

   GenRekap1( aUsl1, aUsl2, aUslR, cKartica, "2", nil, nil, nil, nil, cIdKPovrata )

   SELECT rekap1
   // g1+idtarifa+idroba+objekat
   SET ORDER TO TAG "2"
   aUsl3 := Parsiraj( qqKonto, "Objekat" )

   PRIVATE cFilt2 := ""

   cFilt2 := aUsl3 + ".and." + aUslR

   // postavi filter samo na zeljeni objekat
   SET FILTER to &cFilt2

   PRIVATE xxx := 0

   FOR xxx := 1 TO 3  // obrazac nivelacije
      cVarPC := "1"
      IF cOBrNivelacije == "2"
         IF xxx == 2
            cVarPc := "2"
         ELSE
            cVarPc := "3"
         ENDIF
      ENDIF
      SELECT rekap1
      GO TOP
      start PRINT cret
      ?

      PRIVATE PREDOVA := 62
      PRIVATE  aTarife := {}
      PRIVATE  aTarGr := {}
      PRIVATE nStr := 0
      IF xxx == 1
         kalk_zagl_inventura()
         nCol1 := 10
         m := "----- ---------------------------------------------------- --- ------- ------- ------ ---------- ------ ---------- ---------- ---------- ------ ---------- ------ ---------- ------ ---------- ------ ---------- ------ ----------"
      ELSE
         PRIVATE PREDOVA := 61
         m := "----- ---------------------------------------------------- --- --------- --------- --------- ------------ ------------ ------------"
         ZaglObrPC( cVarPC )
         nCol1 := 10
      ENDIF
      nT10 := nT11 := nT20 := nT21 := nT30 := nT31 := nT40 := nT41 := nT50 := nT51 := nT60 := nT61 := nT70 := nT71 := nT80 := nT81 := nT90 := nT91 := nT100 := nT101 := 0

      fFilovo := .F.
      nRec := 0
      DO WHILE !Eof()
         cG1 := g1
         nTT10 := nTT11 := nTT20 := nTT21 := nTT30 := nTT31 := nTT40 := nTT41 := nTT50 := nTT51 := nTT60 := nTT61 := nTT70 := nTT71 := nTT80 := nTT81 := nTT90 := nTT91 := nTT100 := nTT101 := 0
         nRbr := 0
         DO WHILE !Eof() .AND. cG1 == g1
            cIdTarifa := idtarifa
            nTTT10 := nTTT11 := nTTT20 := nTTT21 := nTTT30 := nTTT31 := nTTT40 := nTTT41 := nTTT50 := nTTT51 := nTTT60 := nTTT61 := nTTT70 := nTTT71 := nTTT80 := nTTT81 := nTTT90 := nTTT91 := nTTT100 := nTTT101 := 0
            fFilovo := .F.
            DO WHILE !Eof() .AND. cG1 == g1  .AND. idtarifa == cIdTarifa
               cIdroba := idroba
               SELECT roba
               HSEEK cIdRoba
               SELECT rekap1
               nK0 := 0 // u sluceju da je vise objekata u prikazu inventure, saberi
               nK1 := nK2 := nK3 := nK4 := nK5 := nK6 := nK7 := nK8 := 0
               nMPC := nNovaMPC := 0
               DO WHILE  !Eof() .AND. cG1 == field->g1  .AND. field->idtarifa == cIdTarifa .AND. cIdRoba == field->idroba
                  nK0 += k0
                  nK1 += k1
                  nK2 += k2
                  nK3 += k3
                  nK4 += k4
                  nK5 += k5
                  nK6 += k6
                  nK7 += k7
                  nK8 += k8
                  nMPC := mpc
                  // nadji prvu novu mpc
                  IF ( ( nNovaMpc == 0 ) .AND. ( field->novaMpc <> 0 ) )
                     nNovaMPC := field->novaMpc
                  ENDIF
                  ++nRec
                  ShowKorner( nRec, 10 )
                  SKIP
               ENDDO

               IF xxx = 1
                  // ako je pocetno stanje nula i prijem u mjesecu  je nula
                  IF cSNule == "N" .AND. roba->tip <> "N" .AND. Round( nk0, 4 ) = 0 .AND. Round( nk4, 4 ) = 0
                     // nk0 - pocetno stanje, nk4 - prijem u toku mjeseca
                     LOOP
                  ENDIF
               ELSE
                  // nivelacije
                  IF Round( nNovaMPC, 4 ) = 0
                     LOOP
                  ENDIF
                  IF cObrNivelacije == "2"
                     IF xxx == 2 .AND. ( nNovampc - field->nmpc ) < 0
                        LOOP
                     ENDIF
                     IF xxx == 3 .AND. ( nNovampc - field->nmpc ) > 0
                        LOOP
                     ENDIF
                  ENDIF
               ENDIF
               fFilovo := .T.
               IF xxx >= 2  // obrazac nivelacije
                  IF PRow() > PREDOVA
                     FF
                     ZaglObrPC( cVarPC )
                  ENDIF
                  IF cProredPC = "D"
                     ?
                  ENDIF
                  ? Str( ++nRbr, 4 ), " ", cidroba; ??  " "; ?? Left( roba->naz, 40 ); ??  " "
                  // grupa artikla - atvibut N1 - numericki
                  @ PRow(), PCol() SAY roba->N1 PICT  "999"; ??  " "
                  // tekuca cijena
                  @ PRow(), PCol() SAY nmpc PICT  "999999.99"; ??  " "
                  // nova cijena
                  @ PRow(), PCol() SAY nnovampc PICT  "@Z 999999.99"; ??  " "
                  IF cObrNivelacije == "2" .AND. xxx == 3
                     @ PRow(), PCol() SAY nMPC - nNovampc PICT  "999999.99"
                     ??  " "
                  ELSE
                     @ PRow(), PCol() SAY nNovampc - nmpc PICT  "999999.99"
                     ??  " "
                  ENDIF
                  ?? "____________ ____________ ____________"
               ENDIF
               IF xxx = 1
                  IF PRow() > PREDOVA
                     FF
                     kalk_zagl_inventura()
                  ENDIF
                  ? Str( ++nRbr, 4 ), "³", cidroba
                  ??  "³"
                  ?? Left( roba->naz, 40 )
                  ??  "³"
                  // grupa artikla - atvibut N1 - numericki
                  @ PRow(), PCol() SAY roba->N1 PICT "999"
                  ??  "³"
                  // tekuca cijena
                  @ PRow(), PCol() SAY nmpc PICT "9999.99"
                  ??  "³"
                  // nova cijena
                  @ PRow(), PCol() SAY nnovampc PICT "@Z 9999.99"
                  ??  "³"
               ENDIF
               nCol1 := PCol()
               IF cPrikKol == "D"
                  nPom := nk0
               ELSE
                  nPom := 0
               ENDIF

               IF roba->k2 <> "X"
                  nTTT10 += nPom
               ENDIF

               nTTT11 += nPom * nmpc

               IF xxx == 1
                  // predhodno stanje
                  @ PRow(), PCol() SAY nPom PICT pickol
                  ??  "³"
                  @ PRow(), PCol() SAY nPom * nmpc PICT picdem
                  ??  "³"
                  // prijem u mjesecu
                  IF cPoc == "D"
                     nPom := 0
                  ELSE
                     nPom := nK4 // prijem u mjesecu
                  ENDIF
                  @ PRow(), PCol() SAY nPom PICT pickol; ??  "³"
                  @ PRow(), PCol() SAY nPom * nmpc PICT picdem; ??  "³"
                  IF roba->k2 <> "X"
                     nTTT20 += nPom
                  ENDIF
                  nTTT21 += nPom * nmpc

                  // iznos povisenja
                  IF cPoc == "D"
                     nPom := 0
                  ELSE
                     IF ( nnovampc - nmpc ) > 0 .AND. Round( nnovampc, 3 ) <> 0
                        nPom := ( nnovampc - nmpc ) * nk2
                     ELSE
                        nPom := 0
                     ENDIF
                  ENDIF
                  @ PRow(), PCol() SAY nPom PICT picdem; ??  "³"
                  nTTT30 += nPom
                  // iznos snizenje
                  IF cPoc == "D"
                     nPom := 0
                  ELSE
                     IF ( nNovampc - nmpc ) < 0 .AND. Round( nnovampc, 3 ) <> 0
                        nPom := -( nnovampc - nMPC ) * nk2
                     ELSE
                        nPom := 0
                     ENDIF
                  ENDIF
                  @ PRow(), PCol() SAY nPom PICT picdem; ??  "³"
                  nTTT31 += nPom

                  // otpremljeno u mjesecu
                  IF cPoc == "D"
                     nPom := 0
                  ELSE
                     nPom := nK6 // izlaz iz prodavnice po ostalim osnovama
                  ENDIF
                  @ PRow(), PCol() SAY nPom PICT pickol; ??  "³"
                  @ PRow(), PCol() SAY nPom * nmpc PICT picdem; ??  "³"
                  IF roba->k2 <> "X"
                     nTTT40 += nPom
                  ENDIF
                  nTTT41 += nPom * nmpc
                  // reklamacija
                  IF cPoc == "D"
                     nPom := 0
                  ELSE
                     nPom := nK5 // reklamacije u mjesecu
                  ENDIF
                  @ PRow(), PCol() SAY nPom PICT pickol; ??  "³"
                  @ PRow(), PCol() SAY nPom * nmpc PICT picdem; ??  "³"
                  IF roba->k2 <> "X"
                     nTTT50 += nPom
                  ENDIF
                  nTTT51 += nPom * nmpc
                  // prodaja
                  IF cPoc == "D"
                     nPom := 0
                  ELSE
                     nPom := nK1 // prodaja mjesecu
                  ENDIF
                  @ PRow(), PCol() SAY nPom PICT pickol; ??  "³"
                  @ PRow(), PCol() SAY nPom * nmpc PICT picdem; ??  "³"
                  IF roba->k2 <> "X"
                     nTTT60 += nPom
                  ENDIF
                  nTTT61 += nPom * nmpc

                  // zaliha
                  IF cPoc == "D"
                     nPom := 0
                  ELSE
                     nPom := nk2
                  ENDIF

                  @ PRow(), PCol() SAY nPom PICT pickol; ??  "³"
                  IF Round( nNovaMPC, 3 ) == 0
                     @ PRow(), PCol() SAY nPom * nMPC PICT picdem; ??  "³"
                     IF roba->k2 <> "X"
                        nTTT70 += nPom
                     ENDIF
                     nTTT71 += nPom * nmpc
                  ELSE
                     @ PRow(), PCol() SAY nPom * nNovaMPC PICT picdem; ??  "³"
                     IF roba->k2 <> "X"
                        nTTT70 += nPom
                     ENDIF
                     nTTT71 += nPom * nNovampc
                  ENDIF

                  // kumulativno prodaja
                  IF cPoc == "D"
                     nPom := 0
                  ELSE
                     nPom := nk3
                  ENDIF

                  @ PRow(), PCol() SAY nPom PICT pickol; ??  "³"
                  @ PRow(), PCol() SAY nPom * nMPC PICT picdem; ??  "³"
                  IF roba->k2 <> "X"
                     nTTT80 += nPom
                  ENDIF
                  nTTT81 += nPom * nmpc

                  ?  m
               ENDIF// xxx=1
               SELECT rekap1
            ENDDO // cidtarifa
            IF !fFilovo
               LOOP
            ENDIF
            IF xxx >= 2  // obrazac nivelacije
               IF PRow() > PREDOVA
                  FF
                  ZaglObrPC( cVarPC )
               ENDIF
               ? m
               ? "Ukupno tarifa", cidtarifa
               ? m
            ENDIF
            IF xxx = 1
               IF PRow() > PREDOVA
                  FF
                  kalk_zagl_inventura()
               ENDIF
               // I_ON
               ? m
               ? "Ukupno tarifa", cidtarifa
               @ PRow(), nCol1 SAY nTTT10 PICT pickol; ??  "³"
               @ PRow(), PCol() SAY nTTT11 PICT picdem; ??  "³"
               @ PRow(), PCol() SAY nTTT20 PICT pickol; ??  "³"
               @ PRow(), PCol() SAY nTTT21 PICT picdem; ??  "³"
               @ PRow(), PCol() SAY nTTT30 PICT picdem; ??  "³"
               @ PRow(), PCol() SAY nTTT31 PICT picdem; ??  "³"
               @ PRow(), PCol() SAY nTTT40 PICT pickol; ??  "³"
               @ PRow(), PCol() SAY nTTT41 PICT picdem; ??  "³"
               @ PRow(), PCol() SAY nTTT50 PICT pickol; ??  "³"
               @ PRow(), PCol() SAY nTTT51 PICT picdem; ??  "³"
               @ PRow(), PCol() SAY nTTT60 PICT pickol; ??  "³"
               @ PRow(), PCol() SAY nTTT61 PICT picdem; ??  "³"
               @ PRow(), PCol() SAY nTTT70 PICT pickol; ??  "³"
               @ PRow(), PCol() SAY nTTT71 PICT picdem; ??  "³"
               @ PRow(), PCol() SAY nTTT80 PICT pickol; ??  "³"
               @ PRow(), PCol() SAY nTTT81 PICT picdem; ??  "³"
            ENDIF // xxx=1
            nInd := AScan( aTarife, {| x| x[ 1 ] = cIdTarifa } )
            IF nInd = 0
               AAdd( aTarife, { cIdTarifa, nTTT10, nTTT11, nTTT20, nTTT21, nTTT30, nTTT31, nTTT40, nTTT41, nTTT50, nTTT51, nTTT60, nTTT61, nTTT70, nTTT71, nTTT80, nTTT81 } )
            ELSE
               aTarife[ nInd, 2 ] += nTTT10
               aTarife[ nInd, 3 ] += nTTT11
               aTarife[ nInd, 4 ] += nTTT20
               aTarife[ nInd, 5 ] += nTTT21
               aTarife[ nInd, 6 ] += nTTT30
               aTarife[ nInd, 7 ] += nTTT31
               aTarife[ nInd, 8 ] += nTTT40
               aTarife[ nInd, 9 ] += nTTT41
               aTarife[ nInd, 10 ] += nTTT50
               aTarife[ nInd, 11 ] += nTTT51
               aTarife[ nInd, 12 ] += nTTT60
               aTarife[ nInd, 13 ] += nTTT61
               aTarife[ nInd, 14 ] += nTTT70
               aTarife[ nInd, 15 ] += nTTT71
               aTarife[ nInd, 16 ] += nTTT80
               aTarife[ nInd, 17 ] += nTTT81
            ENDIF
            nInd := AScan( aTarGr, {| x| x[ 1 ] = cG1 .AND. x[ 2 ] = cIdTarifa } )
            IF nInd = 0
               AAdd( aTarGr, ;
                  { cG1, cIdTarifa, ;
                  nTTT10, nTTT11, ;
                  nTTT20, nTTT21, ;
                  nTTT30, nTTT31, ;
                  nTTT40, nTTT41, ;
                  nTTT50, nTTT51, ;
                  nTTT60, nTTT61, ;
                  nTTT70, nTTT71, ;
                  nTTT80, nTTT81;
                  };
                  )
            ELSE
               aTarGr[ nInd, 3 ] += nTTT10 ;      aTarGr[ nInd, 4 ] += nTTT11
               aTarGr[ nInd, 5 ] += nTTT20 ;      aTarGr[ nInd, 6 ] += nTTT21
               aTarGr[ nInd, 7 ] += nTTT30 ;      aTarGr[ nInd, 8 ] += nTTT31
               aTarGr[ nInd, 9 ] += nTTT40 ;      aTarGr[ nInd, 10 ] += nTTT41
               aTarGr[ nInd, 11 ] += nTTT50;      aTarGr[ nInd, 12 ] += nTTT51
               aTarGr[ nInd, 13 ] += nTTT60;      aTarGr[ nInd, 14 ] += nTTT61
               aTarGr[ nInd, 15 ] += nTTT70;      aTarGr[ nInd, 16 ] += nTTT71
               aTarGr[ nInd, 17 ] += nTTT80;      aTarGr[ nInd, 18 ] += nTTT81
            ENDIF

            nTT10 += nTTT10; nTT11 += nTTT11
            nTT20 += nTTT20; nTT21 += nTTT21
            nTT30 += nTTT30; nTT31 += nTTT31
            nTT40 += nTTT40; nTT41 += nTTT41
            nTT50 += nTTT50; nTT51 += nTTT51
            nTT60 += nTTT60; nTT61 += nTTT61
            nTT70 += nTTT70; nTT71 += nTTT71
            nTT80 += nTTT80; nTT81 += nTTT81
            IF xxx = 1
               ? m
               I_OFF
            ENDIF
         ENDDO // cg1

         IF !fFilovo
            LOOP
         ENDIF

         // obrazac nivelacije
         IF ( xxx >= 2 )
            IF PRow() > PREDOVA
               FF
               ZaglObrPC( cVarPC )
            ENDIF
            ? m
            SELECT k1
            HSEEK cG1
            SELECT rekap1
            ? "Ukupno grupa", cG1, "-", k1->naz
            ? m
         ENDIF

         IF xxx = 1
            IF PRow() > PREDOVA
               FF
               kalk_zagl_inventura()
            ENDIF
            // B_ON
            ? m
            SELECT k1
            HSEEK cG1
            SELECT rekap1
            ? "Ukupno grupa", cG1, "-", k1->naz
            @ PRow(), nCol1 SAY  nTT10 PICT pickol; ??  "³"
            @ PRow(), PCol() SAY nTT11 PICT picdem; ??  "³"
            @ PRow(), PCol() SAY nTT20 PICT pickol; ??  "³"
            @ PRow(), PCol() SAY nTT21 PICT picdem; ??  "³"
            @ PRow(), PCol() SAY nTT30 PICT picdem; ??  "³"
            @ PRow(), PCol() SAY nTT31 PICT picdem; ??  "³"
            @ PRow(), PCol() SAY nTT40 PICT pickol; ??  "³"
            @ PRow(), PCol() SAY nTT41 PICT picdem; ??  "³"
            @ PRow(), PCol() SAY nTT50 PICT pickol; ??  "³"
            @ PRow(), PCol() SAY nTT51 PICT picdem; ??  "³"
            @ PRow(), PCol() SAY nTT60 PICT pickol; ??  "³"
            @ PRow(), PCol() SAY nTT61 PICT picdem; ??  "³"
            @ PRow(), PCol() SAY nTT70 PICT pickol; ??  "³"
            @ PRow(), PCol() SAY nTT71 PICT picdem; ??  "³"
            @ PRow(), PCol() SAY nTT80 PICT pickol; ??  "³"
            @ PRow(), PCol() SAY nTT81 PICT picdem; ??  "³"
         ENDIF // XXX
         nT10 += nTT10
         nT11 += nTT11
         nT20 += nTT20
         nT21 += nTT21
         nT30 += nTT30
         nT31 += nTT31
         nT40 += nTT40
         nT41 += nTT41
         nT50 += nTT50
         nT51 += nTT51
         nT60 += nTT60
         nT61 += nTT61
         nT70 += nTT70
         nT71 += nTT71
         nT80 += nTT80
         nT81 += nTT81

         ? m
         // B_OFF
      ENDDO // eof()


      IF xxx >= 2  // obrazac nivelacije
         IF PRow() > PREDOVA
            FF
            ZaglObrPC( cVarPC )
         ENDIF
         ? m
         ? "U K U P N O"
         ? m
      ENDIF

      IF xxx = 1
         IF PRow() > PREDOVA
            FF
            kalk_zagl_inventura()
         ENDIF
         // B_ON
         ? StrTran( m, "-", "=" )
         ? "U K U P N O"
         @ PRow(), nCol1 SAY  nT10 PICT pickol; ??  "³"
         @ PRow(), PCol() SAY nT11 PICT picdem; ??  "³"
         @ PRow(), PCol() SAY nT20 PICT pickol; ??  "³"
         @ PRow(), PCol() SAY nT21 PICT picdem; ??  "³"
         @ PRow(), PCol() SAY nT30 PICT picdem; ??  "³"
         @ PRow(), PCol() SAY nT31 PICT picdem; ??  "³"
         @ PRow(), PCol() SAY nT40 PICT pickol; ??  "³"
         @ PRow(), PCol() SAY nT41 PICT picdem; ??  "³"
         @ PRow(), PCol() SAY nT50 PICT pickol; ??  "³"
         @ PRow(), PCol() SAY nT51 PICT picdem; ??  "³"
         @ PRow(), PCol() SAY nT60 PICT pickol; ??  "³"
         @ PRow(), PCol() SAY nT61 PICT picdem; ??  "³"
         @ PRow(), PCol() SAY nT70 PICT pickol; ??  "³"
         @ PRow(), PCol() SAY nT71 PICT picdem; ??  "³"
         @ PRow(), PCol() SAY nT80 PICT pickol; ??  "³"
         @ PRow(), PCol() SAY nT81 PICT picdem; ??  "³"

         ? StrTran( m, "-", "=" )
         // B_OFF

         IF PRow() > PREDOVA - 8
            FF
            kalk_zagl_inventura()
         ENDIF
      ENDIF// xxx=1

      IF XXX = 1
         ?
         ?
         ? "UKUPNO TARIFE / GRUPE:"
         ?
      ENDIF
      ASort( aTarGr,,, {| x, y| x[ 2 ] + x[ 1 ] < y[ 2 ] + y[ 1 ] } )
      IF XXX == 1
         ? StrTran( m, "-", "=" )
         ? Len( aTarGr )
      ENDIF
      IF XXX = 1
         FOR nCnt := 1 TO Len( aTarGr )
            IF PRow() > PREDOVA; FF; kalk_zagl_inventura(); ENDIF
            SELECT k1
            HSEEK aTarGr[ nCnt, 1 ]
            ? aTarGr[ nCnt, 1 ], k1->naz, "(", Trim( aTarGr[ nCnt, 2 ] ), ")"
            @ PRow(), nCol1 SAY aTarGr[ nCnt, 3 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 4 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 5 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 6 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 7 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 8 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 9 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 10 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 11 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 12 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 13 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 14 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 15 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 16 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 17 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarGr[ nCnt, 18 ] PICT picdem; ??  "³"
            ? m
         NEXT
         ? StrTran( m, "-", "=" )
      ENDIF// XXX=1
      IF XXX = 1
         IF PRow() > PREDOVA - 4; FF; kalk_zagl_inventura(); ENDIF
         ?
         ?
         ? "UKUPNO PO TARIFAMA:"
         ?
         ASort( aTarife,,, {| x, y| x[ 1 ] < y[ 1 ] } )
         ? StrTran( m, "-", "=" )
         FOR nCnt := 1 TO Len( aTarife )
            IF PRow() > PREDOVA
               FF
               kalk_zagl_inventura()
            ENDIF
            ? aTarife[ nCnt, 1 ]
            @ PRow(), nCol1 SAY  aTarife[ nCnt, 2 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 3 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 4 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 5 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 6 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 7 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 8 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 9 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 10 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 11 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 12 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 13 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 14 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 15 ] PICT picdem; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 16 ] PICT pickol; ??  "³"
            @ PRow(), PCol() SAY aTarife[ nCnt, 17 ] PICT picdem; ??  "³"
            ? m
         NEXT
         ? StrTran( m, "-", "=" )
      ENDIF XXX = 1
      FF
      endprint
      IF cObrnivelacije == "N" .AND. xxx = 1
         EXIT
      ENDIF
      IF cObrNivelacije == "D" .AND. xxx == 2
         EXIT
      ENDIF
   NEXT
   my_close_all_dbf()

   RETURN


/* ZaglObrPC(cKako)
 *     Zaglavlje obrasca inventure za prodavnicu
 *   param: cKako
 */

FUNCTION ZaglObrPC( cKako )

   LOCAL cString := "NALOG ZA PROMJENU CIJENA"
   LOCAL cString2 := "promjena"
   Preduzece()
   IspisNaDan( 10 )
   P_10CPI
   IF cKako <> nil
      IF cKako == "2"
         cString := "POVECANJE CIJENA"
         cString2 := "povecanj"
      ELSEIF cKako == "3"
         cString := "SNIZENJE CIJENA"
         cString2 := "snizenje"
      ENDIF
   ENDIF
   ?
   ? "NAZIV OBJEKTA ", cNObjekat
   ?
   ? PadC( cString + " U PRODAVNICI:_________________" + "  ,  Datum " + DToC( dDatDo ), 80 )
   ?
   P_COND
   ? m
   ? "* R  *  Sifra    *        Naziv                           *   *   STARA *   NOVA  * " + cString2 + "*  zaliha    *   iznos    *  ukupno   *"
   ? "* BR *           *                                        *   *  cijena *  cijena *  cijene * (kolicina) *   poreza   * promjena  *"
   ? m

   RETURN


/*
  kalk_zagl_inventura()
  Zaglavlje inventure
*/

FUNCTION kalk_zagl_inventura()

   P_10CPI
   ??U gTS + ":", gNFirma, Space( 40 ), "Strana:" + Str( ++nStr, 3 )
   ?U
   ?U  "Obrazac obracuna inventure za period:", dDatOd, "-", dDAtDo
   ?U
   ?U  "NAZIV OBJEKTA ", cNObjekat, Space( 30 ), "Kriterij za Objekat:", Trim( qqKonto )
   ?U
   P_COND

   RETURN
