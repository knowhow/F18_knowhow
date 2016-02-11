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


FUNCTION IzvjTar()

   PRIVATE Opc := {}
   PRIVATE opcexe := {}

   AAdd( Opc, "1. kartica                                " )
   AAdd( opcexe, {|| Kart41_42() } )
   AAdd( Opc, "2. kartica v2 (uplata,obaveza,saldo)" )
   AAdd( opcexe, {|| Kart412v2() } )
   AAdd( Opc, "5. realizovani porez" )
   AAdd( opcexe, {|| RekRPor } )

   PRIVATE Izbor := 1
   Menu_SC( "itar" )

   RETURN .F.



FUNCTION Kart41_42()

   LOCAL PicCDEM := gPicCDEM
   LOCAL PicProc := gPicProc
   LOCAL PicDEM := gPicDem
   LOCAL Pickol := "@Z " + gpickol

   O_TARIFA
   O_SIFK
   O_SIFV
   O_ROBA
   O_KONTO

   dDatOd := CToD( "" )
   dDatDo := Date()

   O_PARTN

   cIdFirma := gFirma
   cIdRoba := Space( 10 )
   cidKonto := PadR( "1320", 7 )
   cPredh := "N"


   O_PARAMS
   cBrFDa := "N"
   PRIVATE cSection := "4", cHistory := " ", aHistory := {}
   Params1()
   RPar( "c1", @cidroba ); RPar( "c2", @cidkonto ); RPar( "c3", @cPredh )
   RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo )
   RPar( "c4", @cBrFDa )


   Box(, 6, 50 )
   IF gNW $ "DX"
      @ m_x + 1, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ m_x + 2, m_y + 2 SAY "Konto " GET cIdKonto VALID P_Konto( @cIdKonto )
   @ m_x + 3, m_y + 2 SAY "Roba  " GET cIdRoba  VALID Empty( cidroba ) .OR. P_Roba( @cIdRoba ) PICT "@!"
   @ m_x + 5, m_y + 2 SAY "Datum od " GET dDatOd
   @ m_x + 5, Col() + 2 SAY "do" GET dDatDo
   @ m_x + 6, m_y + 2 SAY "sa prethodnim prometom (D/N)" GET cPredh PICT "@!" VALID cpredh $ "DN"
   read; ESC_BCR
   BoxC()

   IF Empty( cidroba ) .OR. cIdroba == "SIGMAXXXXX"
      IF pitanje(, "Niste zadali sifru artikla, izlistati sve kartice ?", "N" ) == "N"
         closeret
      ELSE
         IF !Empty( cidroba )
            IF Pitanje(, "Korekcija nabavnih cijena ???", "N" ) == "D"
               fKNabC := .T.
            ENDIF
         ENDIF
         cIdr := ""
      ENDIF
   ELSE
      cIdr := cidroba
   ENDIF


   IF Params2()
      WPar( "c1", cidroba ); WPar( "c2", cidkonto ); WPar( "c3", cPredh )
      WPar( "d1", dDatOd ); WPar( "d2", dDatDo )
      WPar( "c4", @cBrFDa )
   ENDIF
   SELECT params; USE


   O_KALK
   nKolicina := 0
   SELECT kalk
   SET ORDER TO TAG "4"
   // idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD
   // HSEEK cidfirma+cidkonto+cidroba
   HSEEK cidfirma + cidkonto + cidr
   EOF CRET

   gaZagFix := { 7, 4 }
   START PRINT CRET

   nLen := 1

   m := "-------- ----------- ------ ------ ---------- ---------- ---------- ----------"

   nTStrana := 0
   Zagl2()

   nCol1 := 10
   fPrviProl := .T.

   DO WHILE !Eof() .AND. idFirma + pkonto + idroba = cidfirma + cidkonto + cidr

      cidroba := idroba
      SELECT roba; HSEEK cidroba
      SELECT tarifa; HSEEK roba->idtarifa
      ? m
      ? "Artikal:", cidroba, "-", Trim( Left( roba->naz, 40 ) ) + " (" + roba->jmj + ")"
      ? m
      SELECT kalk

      nAv := nAvS := nOb := nObS := 0

      DO WHILE !Eof() .AND. cidfirma + cidkonto + cidroba == idFirma + pkonto + idroba

         IF datdok < ddatod .AND. cPredh == "N"
            skip; LOOP
         ENDIF
         IF datdok > ddatdo .OR. ! ( idvd $ "41#42" )
            skip; LOOP
         ENDIF

         IF cPredh == "D" .AND. datdok >= dDatod .AND. fPrviProl
            // ********************* ispis prethodnog stanja ***************
            fPrviprol := .F.
            ? "Stanje do ", ddatod

            @ PRow(),      35 SAY nAvS         PICT picdem
            @ PRow(), PCol() + 1 SAY nAvS         PICT picdem
            @ PRow(), PCol() + 1 SAY nObS         PICT picdem
            @ PRow(), PCol() + 1 SAY nObS         PICT picdem
            // ********************* ispis prethodnog stanja ***************
         ENDIF

         IF PRow() -gPStranica > 62; FF; Zagl2();ENDIF

         IF idvd == "41"    // avans
            nAv  := kolicina * MPCsaPP
            nAvS += nAv
            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, idtarifa, idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY nAv       PICT picdem
               @ PRow(), PCol() + 1 SAY nAvS      PICT picdem
            ENDIF
         ELSE                          // 42 - obracun
            nAv := 0; aOb := 0
            cKalk := idvd + brdok
            DO WHILE !Eof() .AND. cidfirma + cidkonto + cidroba == idFirma + pkonto + idroba .AND. ;
                  cKalk == idvd + brdok
               IF kolicina > 0
                  nOb += kolicina * MPCsaPP
               ELSE
                  nAv += kolicina * MPCsaPP
               ENDIF
               SKIP 1
            ENDDO
            SKIP -1
            nObS += nOb
            nAvS += nAv
            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, idtarifa, idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY nAv       PICT picdem
               @ PRow(), PCol() + 1 SAY nAvS      PICT picdem
               @ PRow(), PCol() + 1 SAY nOb       PICT picdem
               @ PRow(), PCol() + 1 SAY nObS      PICT picdem
            ENDIF
         ENDIF

         SKIP 1    // KALK
      ENDDO

      IF cPredh == "D" .AND. fPrviProl
         // ********************* ispis prethodnog stanja ***************
         ? "Stanje do ", ddatod

         @ PRow(),      35 SAY nAvS         PICT picdem
         @ PRow(), PCol() + 1 SAY nAvS         PICT picdem
         @ PRow(), PCol() + 1 SAY nObS         PICT picdem
         @ PRow(), PCol() + 1 SAY nObS         PICT picdem
         // ********************* ispis prethodnog stanja ***************
      ENDIF

      ? m
      ? "Iznosi predstavljaju maloprodajnu vrijednost sa ukalkulisanim porezima!"
      ? m

      ?
      ?
      fPrviProl := .T.

   ENDDO
   FF
   ENDPRINT
   CLOSERET



/*! \fn Zagl2()
 *  \brief Zaglavlje izvjestaja
 */

STATIC FUNCTION Zagl2()

   SELECT konto; HSEEK cidkonto

   Preduzece()
   P_12CPI
   ?? "KARTICA za period", ddatod, "-", ddatdo, Space( 10 ), "Str:", Str( ++nTStrana, 3 )
   ? "Konto: ", cidkonto, "-", konto->naz
   SELECT kalk
   P_COND
   ? m
   ? "                                                SALDO                 SALDO   "
   ? " Datum     Dokument  Tarifa  Partn   AVANS      AVANSA    OBRACUN    OBRACUNA "
   ? m

   RETURN ( nil )
// }



/*! \fn Kart412v2()
 *  \brief Kartica za varijantu "vodi samo tarife" varijanta 2
 *  \param
 */

FUNCTION Kart412v2()

   LOCAL PicCDEM := gPicCDEM
   LOCAL PicProc := gPicProc
   LOCAL PicDEM := gPicDem
   LOCAL Pickol := "@Z " + gpickol

   O_TARIFA
   O_SIFK
   O_SIFV
   O_ROBA
   O_KONTO

   dDatOd := CToD( "" )
   dDatDo := Date()


   O_PARTN

   cIdFirma := gFirma
   cIdRoba := Space( 10 )
   cidKonto := PadR( "1320", 7 )
   cPredh := "N"

   O_PARAMS
   cBrFDa := "N"
   PRIVATE cSection := "4", cHistory := " ", aHistory := {}
   Params1()
   RPar( "c1", @cidroba ); RPar( "c2", @cidkonto ); RPar( "c3", @cPredh )
   RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo )
   RPar( "c4", @cBrFDa )

   Box(, 6, 50 )
   IF gNW $ "DX"
      @ m_x + 1, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ m_x + 2, m_y + 2 SAY "Konto " GET cIdKonto VALID P_Konto( @cIdKonto )
   @ m_x + 3, m_y + 2 SAY "Roba  " GET cIdRoba  VALID Empty( cidroba ) .OR. P_Roba( @cIdRoba ) PICT "@!"
   @ m_x + 5, m_y + 2 SAY "Datum od " GET dDatOd
   @ m_x + 5, Col() + 2 SAY "do" GET dDatDo
   @ m_x + 6, m_y + 2 SAY "sa prethodnim prometom (D/N)" GET cPredh PICT "@!" VALID cpredh $ "DN"
   read; ESC_BCR
   BoxC()

   IF Empty( cidroba ) .OR. cIdroba == "SIGMAXXXXX"
      IF pitanje(, "Niste zadali sifru artikla, izlistati sve kartice ?", "N" ) == "N"
         closeret
      ELSE
         IF !Empty( cidroba )
            IF Pitanje(, "Korekcija nabavnih cijena ???", "N" ) == "D"
               fKNabC := .T.
            ENDIF
         ENDIF
         cIdr := ""
      ENDIF
   ELSE
      cIdr := cidroba
   ENDIF

   IF Params2()
      WPar( "c1", cidroba ); WPar( "c2", cidkonto ); WPar( "c3", cPredh )
      WPar( "d1", dDatOd ); WPar( "d2", dDatDo )
      WPar( "c4", @cBrFDa )
   ENDIF
   SELECT params; USE

   O_KALK
   nKolicina := 0
   SELECT kalk
   SET ORDER TO TAG "4"
   // idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD
   // HSEEK cidfirma+cidkonto+cidroba
   HSEEK cidfirma + cidkonto + cidr
   EOF CRET

   gaZagFix := { 7, 4 }
   START PRINT CRET

   nLen := 1

   m := "-------- ----------- ------ ---------- -------- ------ ---------- ---------- ---------- ----------"

   nTStrana := 0
   Zagl3()

   nCol1 := 10
   fPrviProl := .T.

   DO WHILE !Eof() .AND. idFirma + pkonto + idroba = cidfirma + cidkonto + cidr

      cidroba := idroba
      SELECT roba; HSEEK cidroba
      SELECT tarifa; HSEEK roba->idtarifa
      ? m
      ? "Artikal:", cidroba, "-", Trim( Left( roba->naz, 40 ) ) + " (" + roba->jmj + ")"
      ? m
      SELECT kalk

      // nAv:=nAvS:=nOb:=nObS:=0
      nOsn := nTotOsn := 0
      nUpl := nTotUpl := 0
      nObv := nTotObv := 0

      DO WHILE !Eof() .AND. cidfirma + cidkonto + cidroba == idFirma + pkonto + idroba

         IF datdok < ddatod .AND. cPredh == "N"
            skip; LOOP
         ENDIF
         IF datdok > ddatdo .OR. ! ( idvd $ "41#42" )
            skip; LOOP
         ENDIF

         IF cPredh == "D" .AND. datdok >= dDatod .AND. fPrviProl
            // ********************* ispis prethodnog stanja ***************
            fPrviprol := .F.
            ? "Stanje do ", ddatod

            @ PRow(),      55 SAY nTotOsn         PICT picdem
            @ PRow(), PCol() + 1 SAY nTotUpl         PICT picdem
            @ PRow(), PCol() + 1 SAY nTotObv         PICT picdem
            @ PRow(), PCol() + 1 SAY nTotUpl - nTotObv PICT picdem
            // ********************* ispis prethodnog stanja ***************
         ENDIF

         IF PRow() -gPStranica > 62; FF; Zagl3();ENDIF

         IF idvd == "41"    // avans
            nOsn := kolicina * MPCsaPP
            nTotOsn += nOsn
            nUpl := kolicina * ( mpcsapp - mpc )
            nTotUpl += nUpl
            IF datdok >= ddatod
               IF IzFMKIni( "VodiSamoTarife", "KarticaV2_KALK41_BezDatumaIBrojaFakture", "N", KUMPATH ) == "D"
                  ? datdok, idvd + "-" + brdok, idtarifa, Space( 10 ), Space( 8 ), idpartner
               ELSE
                  ? datdok, idvd + "-" + brdok, idtarifa, brfaktp, datfaktp, idpartner
               ENDIF
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY nOsn            PICT picdem
               @ PRow(), PCol() + 1 SAY nUpl            PICT picdem
               @ PRow(), PCol() + 1 SAY 0               PICT "@Z" + picdem
               @ PRow(), PCol() + 1 SAY nTotUpl - nTotObv PICT picdem
            ENDIF
         ELSE                          // 42 - obracun
            nOsn := nUpl := nObv := 0
            aStavke := {}
            cKalk := idvd + brdok
            DO WHILE !Eof() .AND. cidfirma + cidkonto + cidroba == idFirma + pkonto + idroba .AND. ;
                  cKalk == idvd + brdok
               IF kolicina > 0
                  nObv += kolicina * ( MPCsaPP - MPC )
                  AAdd( aStavke, { 0, 0, kolicina * ( MPCsaPP - MPC ), nTotUpl - nTotObv - nObv, brfaktp, datfaktp } )
               ELSE
                  nUpl += kolicina * ( MPCsaPP - MPC )
               ENDIF
               nOsn += kolicina * MPCsaPP
               SKIP 1
            ENDDO
            SKIP -1
            nUpl := Max( nObv + nUpl, 0 )     // ovdje se dobija stvarna uplata!
            nTotUpl += nUpl
            nOsn := Max( nOsn, 0 )          // ovdje se dobija stvarna osnovica!
            nTotOsn += nOsn
            nTotObv += nObv
            IF nUpl > 0
               AAdd( aStavke, { nOsn, nUpl, 0, nTotUpl - nTotObv, Space( 10 ), Space( 8 ) } )
            ENDIF
            IF datdok >= ddatod
               IF IzFMKINI( "VodiSamoTarife", "SvakaStavkaNaKarticu", "D", KUMPATH ) == "D"
                  FOR i := 1 TO Len( aStavke )
                     ? datdok, idvd + "-" + brdok, idtarifa, aStavke[ i, 5 ], aStavke[ i, 6 ], idpartner
                     nCol1 := PCol() + 1
                     @ PRow(), PCol() + 1 SAY aStavke[ i, 1 ]    PICT picdem
                     @ PRow(), PCol() + 1 SAY aStavke[ i, 2 ]    PICT picdem
                     @ PRow(), PCol() + 1 SAY aStavke[ i, 3 ]    PICT picdem
                     @ PRow(), PCol() + 1 SAY aStavke[ i, 4 ]    PICT picdem
                  NEXT
               ELSE
                  ? datdok, idvd + "-" + brdok, idtarifa, brfaktp, datfaktp, idpartner
                  nCol1 := PCol() + 1
                  @ PRow(), PCol() + 1 SAY nOsn            PICT picdem
                  @ PRow(), PCol() + 1 SAY nUpl            PICT picdem
                  @ PRow(), PCol() + 1 SAY nObv            PICT picdem
                  @ PRow(), PCol() + 1 SAY nTotUpl - nTotObv PICT picdem
               ENDIF
            ENDIF
         ENDIF

         SKIP 1    // kalk
      ENDDO

      IF cPredh == "D" .AND. fPrviProl  // nema prometa, ali ima prethodno stanje
         ? "Stanje do ", ddatod
      ELSE  // total
         ? m
         ? "UKUPNO:"
      ENDIF
      @ PRow(),      55 SAY nTotOsn         PICT picdem
      @ PRow(), PCol() + 1 SAY nTotUpl         PICT picdem
      @ PRow(), PCol() + 1 SAY nTotObv         PICT picdem
      @ PRow(), PCol() + 1 SAY nTotUpl - nTotObv PICT picdem
      ? m; ?; ?
      fPrviProl := .T.
      nTotOsn := nTotUpl := nTotObv := 0

   ENDDO
   FF
   ENDPRINT
   CLOSERET



/*! \fn Zagl3()
 *  \brief Zaglavlje izvjestaja
 */

STATIC FUNCTION Zagl3()

   SELECT konto; HSEEK cidkonto

   Preduzece()
   P_12CPI
   ?? "KARTICA za period", ddatod, "-", ddatdo, Space( 10 ), "Str:", Str( ++nTStrana, 3 )
   ? "Konto: ", cidkonto, "-", konto->naz
   SELECT kalk
   P_COND
   ? m
   ? "                                F A K T U R A           MPV+POREZ   UPLATA    OBAVEZA      SALDO  "
   ? " Datum     Dokument  Tarifa     Broj    Datum    Partn   (osnov)    POREZA    (POREZ)     UPL-OBAV"
   ? m

   RETURN ( nil )
