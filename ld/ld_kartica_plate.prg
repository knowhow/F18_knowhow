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


STATIC DUZ_STRANA := 64
STATIC __var_obr
STATIC __radni_sati := "N"


FUNCTION ld_kartica_plate( cIdRj, cMjesec, cGodina, cIdRadn, cObrac )

   LOCAL i
   LOCAL aNeta := {}
   LOCAL _radni_sati := fetch_metric( "ld_radni_sati", nil, "N" )

   lSkrivena := .F.
   PRIVATE cLMSK := ""

   __radni_sati := _radni_sati

   l2kolone := .F.

   cVarSort := "1"

   PRIVATE cNKNS
   cNKNS := "N"

   IF ( PCount() < 4 )
      cIdRadn := Space( _LR_ )
      cIdRj := gRj
      cMjesec := gMjesec
      cGodina := gGodina
      cObracun := gObracun

      O_PAROBR
      O_LD_RJ
      O_RADN
      O_VPOSLA
      O_RADKR
      O_KRED
      O_LD

   ELSE
      cObracun := cObrac
   ENDIF

   IF __radni_sati == "D"
      O_RADSAT
   ENDIF

   PRIVATE nC1 := 20 + Len( cLMSK )

   cVarijanta := " "
   c2K1L := "D"

   IF ( PCount() < 4 )
      O_PARAMS
      PRIVATE cSection := "4"
      PRIVATE cHistory := " "
      PRIVATE aHistory := {}
      RPar( "VS", @cVarSort )
      RPar( "2K", @c2K1L )
      RPar( "NK", @cNKNS )
      cIdRadn := Space( _LR_ )
      Box(, 8, 75 )
      @ m_x + 1, m_y + 2 SAY _l( "Radna jedinica (prazno-sve rj): " )  GET cIdRJ VALID Empty( cidrj ) .OR. P_LD_RJ( @cidrj )
      @ m_x + 2, m_y + 2 SAY _l( "Mjesec: " ) GET cMjesec PICT "99"
      IF lViseObr
         @ m_x + 2, Col() + 2 SAY _l( "Obracun: " ) GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      ENDIF
      @ m_x + 3, m_y + 2 SAY _l( "Godina: " ) GET cGodina PICT "9999"
      @ m_x + 4, m_y + 2 SAY _l( "Radnik (prazno-svi radnici): " )  GET  cIdRadn  VALID Empty( cIdRadn ) .OR. P_Radn( @cIdRadn )
      @ m_x + 5, m_y + 2 SAY _l( "Varijanta ( /5): " )  GET  cVarijanta VALID cVarijanta $ " 5"
      @ m_x + 6, m_y + 2 SAY _l( "Ako su svi radnici, sortirati po (1-sifri,2-prezime+ime)" )  GET cVarSort VALID cVarSort $ "12"  PICT "9"
      @ m_x + 7, m_y + 2 SAY _l( "Dvije kartice na jedan list ? (D/N)" )  GET c2K1L VALID c2K1L $ "DN"  PICT "@!"
      @ m_x + 8, m_y + 2 SAY _l( "Ispis svake kartice krece od pocetka stranice? (D/N)" )  GET cNKNS VALID cNKNS $ "DN"  PICT "@!"
      READ
      clvbox()
      ESC_BCR
      BoxC()
      SELECT params
      WPar( "VS", cVarSort )
      WPar( "2K", c2K1L )
      WPar( "NK", cNKNS )
      SELECT PARAMS
      USE
      tipprn_use()
   ENDIF

   PoDoIzSez( cGodina, cMjesec )

   IF cVarijanta == "5"
      O_LDSM
   ENDIF

   SELECT LD

   cIdRadn := Trim( cidradn )

   IF Empty( cIdRadn ) .AND. cVarSort == "2"
      IF Empty( cIdRj )
         IF lViseObr .AND. !Empty( cObracun )
            INDEX ON Str( field->godina ) + Str( field->mjesec ) + field->obr + SortPrez( field->idradn ) + field->idrj TO "tmpld"
            SEEK Str( cGodina, 4 ) + Str( cMjesec, 2 ) + cObracun + cIdRadn
         ELSE
            INDEX ON Str( field->godina ) + Str( field->mjesec ) + SortPrez( field->idradn ) + idrj TO "tmpld"
            SEEK Str( cGodina, 4 ) + Str( cMjesec, 2 ) + cIdRadn
         ENDIF
         cIdrj := ""
      ELSE
         IF lViseObr .AND. !Empty( cObracun )
            INDEX ON Str( field->godina ) + field->idrj + Str( field->mjesec ) + field->obr + SortPrez( field->idradn ) TO "tmpld"
            SEEK Str( cGodina, 4 ) + cIdrj + Str( cMjesec, 2 ) + cObracun + cIdRadn
         ELSE
            INDEX ON Str( field->godina ) + field->idrj + Str( field->mjesec ) + SortPrez( field->idradn ) TO "tmpld"
            SEEK Str( cGodina, 4 ) + cIdrj + Str( cMjesec, 2 ) + cIdRadn
         ENDIF
      ENDIF
   ELSE
      IF Empty( cidrj )
         SET ORDER TO tag ( TagVO( "2" ) )
         SEEK Str( cGodina, 4 ) + Str( cMjesec, 2 ) + IIF( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + cIdRadn
         cIdrj := ""
      ELSE
         IF PCount() < 4
            SET ORDER TO TAG ( TagVO( "1" ) )
         ENDIF
         SEEK Str( cGodina, 4 ) + cidrj + Str( cMjesec, 2 ) + IIF( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + cIdRadn
      ENDIF
   ENDIF

   EOF CRET

   nStrana := 0

   SELECT vposla
   HSEEK ld->idvposla
   SELECT ld_rj
   HSEEK ld->idrj
   SELECT ld

   IF PCount() >= 4
      START PRINT RET
   ELSE
      START PRINT CRET
   ENDIF

   ?
   P_12CPI

   ParObr( cMjesec, cGodina, IIF( lViseObr, cObracun, ), cIdRj )

   PRIVATE lNKNS
   lNKNS := ( cNKNS == "D" )

   nRbrKart := 0

   bZagl := {|| ZaglKar() }

   nT1 := nT2 := nT3 := nT4 := 0

   // -- Prikaz samo odredjenih doprinosa na kartici plate
   // -- U fmk.ini /kumpath se definisu koji dopr. da se prikazuju
   // -- Po defaultu stoji prazno - svi doprinosi

   cPrikDopr := my_get_from_ini( "LD", "DoprNaKartPl", "D", KUMPATH )
   lPrikSveDopr := ( cPrikDopr == "D" )

   DO WHILE !Eof() .AND. cGodina == godina .AND. idrj = cidrj .AND. cMjesec = mjesec .AND. idradn = cIdRadn .AND. !( lViseObr .AND. !Empty( cObracun ) .AND. obr <> cObracun )

      aNeta := {}

      IF lViseObr .AND. Empty( cObracun )
         ScatterS( Godina, Mjesec, IdRJ, IdRadn )
      ELSE
         Scatter()
      ENDIF

      cRTRada := g_tip_rada( _idradn, _idrj )

      SELECT radn
      HSEEK _idradn
      SELECT vposla
      HSEEK _idvposla
      SELECT ld_rj
      HSEEK _idrj
      SELECT ld

      AAdd( aNeta, { vposla->idkbenef, _UNeto } )

      __var_obr := get_varobr()

      IF cRTRada == "S"
         ld_kartica_plate_samostalni( cIdRj, cMjesec, cGodina, cIdRadn, cObrac, @aNeta )
      ELSEIF cRTRada $ "AU"
         ld_kartica_plate_ugovori( cIdRj, cMjesec, cGodina, cIdRadn, cObrac, @aNeta )
      ELSEIF cRTRada == "P"
         ld_kartica_plate_upravni_odbor( cIdRj, cMjesec, cGodina, cIdRadn, cObrac, @aNeta )
      ELSE
         ld_kartica_plate_redovan_rad( cIdRj, cMjesec, cGodina, cIdRadn, cObrac, @aNeta )
      ENDIF

      nT1 += _usati
      nT2 += _uneto
      nT3 += _uodbici
      nT4 += _uiznos

      SELECT ld
      SKIP 1
   ENDDO

   IF PCount() >= 4  // predji na drugu stranu
      FF
   ENDIF

   ENDPRINT

   IF PCount() < 4
      my_close_all_dbf()
   ELSE // pcount >= "4"

      IF __radni_sati == "D"
         O_RADSAT
      ENDIF

      O_PAROBR
      O_LD_RJ
      O_RADN
      O_VPOSLA
      O_RADKR
      O_KRED
      O_LD

      SET ORDER TO tag ( TagVO( "1" ) )

   ENDIF

   RETURN



FUNCTION ZaglKar()

   ++nRBrKart

   // nova stranica odredjuje odakle ce se poceti stampati
   // gura karticu do polovine stranice ako fali redova
   IF !lNKNS .AND. !( gPrBruto $ "DX" ) .AND. c2K1L == "D" .AND. ( nRBrKart % 2 ) == 0
      DO WHILE PRow() < 34
         ?
      ENDDO
   ENDIF

   ?U "OBRAČUN PLATE ZA" + Space( 1 ) + Str( mjesec, 2 ) + "/" + Str( godina, 4 ) + " (obr. " + IspisObr() + ")", " ZA " + Upper( Trim( gTS ) ), gNFirma
   ? "RJ:", idrj, ld_rj->naz
   ? idradn, "-", RADNIK_PREZ_IME, "  Mat.br:", radn->matbr
   ShowHiredFromTo( radn->hiredfrom, radn->hiredto, "" )
   ? _l( "Radno mjesto:" ), radn->rmjesto, "  STR.SPR:", IDSTRSPR
   ? _l( "Vrsta posla:" ), idvposla, vposla->naz, "         Radi od:", radn->datod
   ? IF( gBodK == "1", _l( "Broj bodova :" ), _l( "Koeficijent :" ) ), Transform( brbod, "99999.99" ), Space( 24 )
   IF gMinR == "B"
         ?? _l( "Minuli rad:" ), Transform( kminrad, "9999.99" )
   ELSE
         ?? _l( "K.Min.rada:" ), Transform( kminrad, "99.99%" )
   ENDIF
   ? IF( gBodK == "1", _l( "Vrijednost boda:" ), _l( "Vr.koeficijenta:" ) ), Transform( parobr->vrbod, "99999.99999" )

   IF radn->n1 <> 0 .OR. radn->n2 <> 0
         ? _l( "N1:" ), Transform( radn->n1, "99999999.9999" )
         ?? Space( 2 ) + ;
            _l( "N2:" ), Transform( radn->n2, "99999999.9999" )
   ENDIF

   IF __var_obr == "2"
       ?? Space( 2 ) + _l( "Koef.licnog odbitka:" ), AllTrim( Str( g_klo( ld->ulicodb ) ) )
   ENDIF

   IF __radni_sati == "D"
       ?? Space( 2 ) + _l( "Radni sati:   " ) + AllTrim( Str( ld->radsat ) )
   ENDIF

   RETURN .T.


FUNCTION kart_redova()

   LOCAL nRows := 0
   LOCAL cField
   LOCAL cFIznos := "_I"
   LOCAL cFSati := "_S"
   LOCAL nStRedova := 23

   IF gPrBruto == "X"
      nStRedova := 32
   ENDIF

   // ako nema potpisa standardnih redova je manje
   IF gPotp == "N"
      nStRedova := nStRedova - 4
   ENDIF

   // ispitaj standardna ld polja _I(nn), _S(nn)
   FOR i := 1 TO cLDPolja
      cField := PadL( AllTrim( Str( i ) ), 2, "0" )
      if &( cFIznos + cField ) <> 0 .OR. &( cFSati + cField ) <> 0
         ++ nRows
      ENDIF
   NEXT

   // ispitaj kredite
   SELECT radkr
   SET ORDER TO 1
   SEEK Str( _godina, 4 ) + Str( _mjesec, 2 ) + _idradn
   DO WHILE !Eof() .AND. _godina == godina .AND. _mjesec = mjesec .AND. idradn == _idradn
      ++ nRows
      SKIP
   ENDDO
   SELECT ld

   RETURN ( nRows + nStRedova )


FUNCTION kart_potpis()

   IF gPotp == "D"
      ?
      ? cLMSK + Space( 5 ), _l( "   Obracunao:  " ), Space( 30 ), _l( "    Potpis:" )
      ? cLMSK + Space( 5 ), "_______________", Space( 30 ), "_______________"
      ?
   ENDIF

   RETURN



STATIC FUNCTION prikazi_primanja()

   LOCAL nIznos := 0

   IF "U" $ Type( "cLMSK" ); cLMSK := ""; ENDIF
   IF "U" $ Type( "l2kolone" ); l2kolone := .F. ; ENDIF
   IF tippr->( Found() ) .AND. tippr->aktivan == "D"
      IF _i&cpom <> 0 .OR. _s&cPom <> 0
         ? cLMSK + tippr->id + "-" + tippr->naz, tippr->opis
         nC1 := PCol()
         IF tippr->uneto == "N"
            nIznos := Abs( _i&cPom )
         ELSE
            nIznos := _i&cPom
         ENDIF
         IF tippr->fiksan $ "DN"
            @ PRow(), PCol() + 8 SAY _s&cPom  PICT gpics; ?? " s"
            @ PRow(), 60 + Len( cLMSK ) SAY niznos        PICT gpici
         ELSEIF tippr->fiksan == "P"
            @ PRow(), PCol() + 8 SAY _s&cPom  PICT "999.99%"
            @ PRow(), 60 + Len( cLMSK ) SAY niznos        PICT gpici
         ELSEIF tippr->fiksan == "B"
            @ PRow(), PCol() + 8 SAY Abs( _s&cPom )  PICT "999999"; ?? " b"
            @ PRow(), 60 + Len( cLMSK ) SAY niznos        PICT gpici
         ELSEIF tippr->fiksan == "C"
            IF !( "SUMKREDITA" $ tippr->formula )
               @ PRow(), 60 + Len( cLMSK ) SAY niznos        PICT gpici
            ENDIF
         ENDIF

         IF "SUMKREDITA" $ tippr->formula
            SELECT radkr
            SET ORDER TO 1
            SEEK Str( _godina, 4 ) + Str( _mjesec, 2 ) + _idradn
            ukredita := 0
            IF l2kolone
               P_COND2
            ELSE
               P_COND
            ENDIF
            ? m2 := cLMSK + " ------------------------------------------- --------- --------- -------"
            ? cLMSK + "    Kreditor   /             na osnovu         Ukupno    Ostalo   Rata"
            ? m2
            DO WHILE !Eof() .AND. _godina == godina .AND. _mjesec = mjesec .AND. idradn == _idradn
               SELECT kred
               HSEEK radkr->idkred
               SELECT radkr
               aIznosi := OKreditu( idradn, idkred, naosnovu, _mjesec, _godina )
               ? cLMSK, idkred, Left( kred->naz, 15 ), PadR( naosnovu, 20 )
               @ PRow(), PCol() + 1 SAY aIznosi[ 1 ] PICT "999999.99" // ukupno
               @ PRow(), PCol() + 1 SAY aIznosi[ 1 ] -aIznosi[ 2 ] PICT "999999.99"// ukupno-placeno
               @ PRow(), PCol() + 1 SAY iznos PICT "9999.99"
               ukredita += iznos
               SKIP
            ENDDO
            IF Round( ukredita - niznos, 2 ) <> 0
               SET DEVICE TO SCREEN
               Beep( 2 )
               Msg( "Za radnika " + _idradn + " iznos sume kredita ne odgovara stanju baze kredita !", 6 )
               SET DEVICE TO PRINTER
            ENDIF

            // ? m
            IF l2kolone
               P_COND2
            ELSE
               P_12CPI
            ENDIF
            SELECT ld
         ENDIF
         IF "_K" == Right( AllTrim( tippr->opis ), 2 )
            nKumPrim := ld_kumulativna_primanja( _IdRadn, cPom )

            IF SubStr( AllTrim( tippr->opis ), 2, 1 ) == "1"
               nKumPrim := nkumprim + radn->n1
            ELSEIF  SubStr( AllTrim( tippr->opis ), 2, 1 ) == "2"
               nKumPrim := nkumprim + radn->n2
            ELSEIF  SubStr( AllTrim( tippr->opis ), 2, 1 ) == "3"
               nKumPrim := nkumprim + radn->n3
            ENDIF

            IF tippr->uneto == "N"; nKumPrim := Abs( nKumPrim ); ENDIF
            ? m2 := cLMSK + "   ----------------------------- ----------------------------"
            ? cLMSK + "    SUMA IZ PRETHODNIH OBRA¬UNA   UKUPNO (SA OVIM OBRA¬UNOM)"
            ? m2
            ? cLMSK + "   " + PadC( Str( nKumPrim - nIznos ), 29 ) + " " + PadC( Str( nKumPrim ), 28 )
            ? m2
         ENDIF
      ENDIF
   ENDIF

   RETURN



FUNCTION ld_kumulativna_primanja( cIdRadn, cIdPrim )

   LOCAL j := 0, nVrati := 0, nOdGod := 0, nDoGod := 0

   cPom77 := cIdPrim
   IF cIdRadn == NIL; cIdRadn := ""; ENDIF
   SELECT LD
   PushWA()
   SET ORDER TO TAG ( TagVO( "4" ) )
   GO BOTTOM; nDoGod := godina
   GO TOP; nOdGod := godina
   FOR j := nOdGod TO nDoGod
      GO TOP
      SEEK Str( j, 4 ) + cIdRadn
      DO WHILE godina == j .AND. cIdRadn == IdRadn
         nVrati += i&cPom77
         SKIP 1
      ENDDO
   NEXT
   SELECT LD
   PopWA()

   RETURN nVrati
