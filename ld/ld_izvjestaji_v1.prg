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


// prikaz primanja, opcina zenica
// ********************************
FUNCTION PrikPrimanje()

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
            // ? m
            // ? "  ","Od toga pojedinacni krediti:"
            SELECT radkr; SET ORDER TO 1
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
               SELECT kred; hseek radkr->idkred; SELECT radkr
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
            nKumPrim := KumPrim( _IdRadn, cPom )

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

FUNCTION KumPrim( cIdRadn, cIdPrim )

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



FUNCTION Rekap_OLD( fSvi )

   // {
   LOCAL nC1 := 20, i
   LOCAL cTPNaz, cUmPD := "N", nKrug := 1

   fPorNaRekap := IzFmkIni( "LD", "PoreziNaRekapitulaciji", "N", KUMPATH ) == "D"

   cIdRj := gRj; cmjesec := gMjesec; cGodina := gGodina
   cObracun := gObracun
   cMjesecDo := cMjesec

   IF fSvi == NIL
      fSvi := .F.
   ENDIF

   O_POR
   O_DOPR
   O_PAROBR
   O_LD_RJ
   O_RADN
   O_STRSPR
   O_KBENEF
   O_VPOSLA
   O_OPS
   O_RADKR
   O_KRED
   O_LD

   cIdRadn := Space( _LR_ ); cStrSpr := Space( 3 ); cOpsSt := Space( 4 ); cOpsRad := Space( 4 )

   IF fSvi
      // za sve radne jedinice
      qqRJ := Space( 60 )
      Box(, 10, 75 )

      DO WHILE .T.
#ifdef CPOR
         IF lIsplaceni
            @ m_x + 2, m_y + 2 SAY "Umanjiti poreze i doprinose za preplaceni iznos? (D/N)"  GET cUmPD VALID cUmPD $ "DN" PICT "@!"
         ENDIF
#endif
         @ m_x + 3, m_y + 2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
         @ m_x + 4, m_y + 2 SAY "Za mjesece od:"  GET  cmjesec  PICT "99" VALID {|| cMjesecDo := cMjesec, .T. }
         @ m_x + 4, Col() + 2 SAY "do:"  GET  cMjesecDo  PICT "99" VALID cMjesecDo >= cMjesec
         IF lViseObr
            @ m_x + 4, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
         ENDIF
         @ m_x + 5, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
         @ m_x + 7, m_y + 2 SAY "Strucna Sprema: "  GET  cStrSpr PICT "@!" VALID Empty( cStrSpr ) .OR. P_StrSpr( @cStrSpr )
         @ m_x + 8, m_y + 2 SAY "Opstina stanovanja: "  GET  cOpsSt PICT "@!" VALID Empty( cOpsSt ) .OR. P_Ops( @cOpsSt )
         @ m_x + 9, m_y + 2 SAY "Opstina rada:       "  GET  cOpsRad  PICT "@!" VALID Empty( cOpsRad ) .OR. P_Ops( @cOpsRad )

         read; clvbox(); ESC_BCR
         aUsl1 := Parsiraj( qqRJ, "IDRJ" )
         aUsl2 := Parsiraj( qqRJ, "ID" )
         IF aUsl1 <> NIL .AND. aUsl2 <> NIL; exit; ENDIF
      ENDDO

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
      cFilt1 := ".t." + IF( Empty( cStrSpr ), "", ".and.IDSTRSPR==" + cm2str( cStrSpr ) ) + ;
         IF( Empty( qqRJ ), "", ".and." + aUsl1 )

      IF cMjesec != cMjesecDo
         cFilt1 := cFilt1 + ".and.mjesec>=" + cm2str( cMjesec ) + ;
            ".and.mjesec<=" + cm2str( cMjesecDo ) + ;
            ".and.godina=" + cm2str( cGodina )
      ENDIF

      IF lViseObr
         cFilt1 += ".and. OBR=" + cm2str( cObracun )
      ENDIF

      cFilt1 := StrTran( cFilt1, ".t..and.", "" )

      IF cFilt1 == ".t."
         SET FILTER TO
      ELSE
         SET FILTER TO &cFilt1
      ENDIF

      IF cMjesec == cMjesecDo
         SEEK Str( cGodina, 4 ) + Str( cmjesec, 2 ) + cObracun
         EOF CRET
      ELSE
         GO TOP
      ENDIF

   ELSE
      // ****** samo jedna radna jedinica
      Box(, 8, 75 )
#ifdef CPOR
      IF lIsplaceni
         @ m_x + 1, m_y + 2 SAY "Umanjiti poreze i doprinose za preplaceni iznos? (D/N)"  GET cUmPD VALID cUmPD $ "DN" PICT "@!"
      ENDIF
#endif
      @ m_x + 2, m_y + 2 SAY "Radna jedinica: "  GET cIdRJ
      @ m_x + 3, m_y + 2 SAY "Za mjesece od:"  GET  cmjesec  PICT "99" VALID {|| cMjesecDo := cMjesec, .T. }
      @ m_x + 3, Col() + 2 SAY "do:"  GET  cMjesecDo  PICT "99" VALID cMjesecDo >= cMjesec
      IF lViseObr
         @ m_x + 3, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
      ENDIF
      @ m_x + 4, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
      @ m_x + 6, m_y + 2 SAY "Strucna Sprema: "  GET  cStrSpr PICT "@!" VALID Empty( cStrSpr ) .OR. P_StrSpr( @cStrSpr )
      @ m_x + 7, m_y + 2 SAY "Opstina stanovanja: "  GET  cOpsSt PICT "@!" VALID Empty( cOpsSt ) .OR. P_Ops( @cOpsSt )
      @ m_x + 8, m_y + 2 SAY "Opstina rada:       "  GET  cOpsRad  PICT "@!" VALID Empty( cOpsRad ) .OR. P_Ops( @cOpsRad )
      read; clvbox(); ESC_BCR
      BoxC()

      tipprn_use()

      SELECT LD

      IF lViseObr
         cObracun := Trim( cObracun )
      ELSE
         cObracun := ""
      ENDIF

      SET ORDER TO tag ( TagVO( "1" ) )

      PRIVATE cFilt1 := ""
      cFilt1 := ".t." + IF( Empty( cStrSpr ), "", ".and.IDSTRSPR==" + cm2str( cStrSpr ) )

      IF cMjesec != cMjesecDo
         cFilt1 := cFilt1 + ".and.mjesec>=" + cm2str( cMjesec ) + ;
            ".and.mjesec<=" + cm2str( cMjesecDo ) + ;
            ".and.godina=" + cm2str( cGodina )
      ENDIF

      IF lViseObr
         cFilt1 += ".and. OBR=" + cm2str( cObracun )
      ENDIF

      cFilt1 := StrTran( cFilt1, ".t..and.", "" )

      IF cFilt1 == ".t."
         SET FILTER TO
      ELSE
         SET FILTER TO &cFilt1
      ENDIF

      // IF cMjesec==cMjesecDo
      SEEK Str( cGodina, 4 ) + cidrj + Str( cmjesec, 2 ) + cObracun
      EOF CRET
      // ELSE
      // GO TOP
      // ENDIF

   ENDIF
   // ********************* fsvi

   PoDoIzSez( cGodina, cMjesecDo )

   nStrana := 0

   IF !fPorNaRekap
      m := "------------------------  ----------------               -------------------"
   ELSE
      m := "------------------------  ---------------  ---------------  -------------"
   ENDIF


   aDbf := {   { "ID","C", 1, 0 }, ;
      { "IDOPS","C", 4, 0 }, ;
      { "IZNOS","N", 25, 4 }, ;
      { "IZNOS2", "N", 25, 4 }, ;
      { "LJUDI","N", 10, 0 };
      }

   // id- 1 opsstan
   // id- 2 opsrad
   DBCREATE2( "opsld", aDbf )


   SELECT( F_OPSLD ) ; usex ( PRIVPATH + "opsld" )
   INDEX ON  ID + IDOPS TAG "1"
   INDEX ON  BRISANO TAG "BRISAN"
   USE


   // napraviti   godina, mjesec, idrj, cid , iznos1, iznos2
   aDbf := {    { "GODINA",  "C", 4, 0 },;
      { "MJESEC",  "C", 2, 0 },;
      { "ID",  "C", 30, 0 },;
      { "opis",  "C", 20, 0 },;
      { "opis2",  "C", 35, 0 },;
      { "iznos1",  "N", 25, 4 },;
      { "iznos2",  "N", 25, 4 } ;
      }
   AAdd( aDbf, { "idpartner",  "C",  6, 0 } )

   DBCREATE2( KUMPATH + "REKLD", aDbf )

   SELECT ( F_REKLD )
   usex ( KUMPATH + "rekld" )

   INDEX ON  BRISANO + "10" TAG "BRISAN"
   INDEX ON  godina + mjesec + id  TAG "1"
   SET ORDER TO TAG "1"
   USE

   O_REKLD
   O_OPSLD
   SELECT ld

   START PRINT CRET
   ?
   P_10CPI

   IF IzFMKIni( "LD", "RekapitulacijaGustoPoVisini", "N", KUMPATH ) == "D"
      lGusto := .T.
      gRPL_Gusto()
      nDSGusto := Val( IzFMKIni( "RekapGustoPoVisini", "DodatnihRedovaNaStranici", "11", KUMPATH ) )
      gPStranica += nDSGusto
   ELSE
      lGusto := .F.
      nDSGusto := 0
   ENDIF

   ParObr( cmjesec, cgodina, IF( lViseObr, cObracun, ), IF( !fSvi, cIdRj, ) )      // samo pozicionira bazu PAROBR na odgovaraju†i zapis

   PRIVATE aRekap[ cLDPolja, 2 ]

   FOR i := 1 TO cLDPolja
      aRekap[ i, 1 ] := 0
      aRekap[ i, 2 ] := 0
   NEXT

   nT1 := nT2 := nT3 := nT4 := 0
   nUNeto := 0
   nUNetoOsnova := 0
   nUIznos := nUSati := nUOdbici := nUOdbiciP := nUOdbiciM := 0
   nLjudi := 0

   PRIVATE aNeta := {}

   SELECT ld

   IF cMjesec != cMjesecDo
      IF fSvi
         PRIVATE bUslov := {|| cgodina == godina .AND. mjesec >= cmjesec .AND. mjesec <= cMjesecDo .AND. IF( lViseObr, obr = cObracun, .T. ) }
      ELSE
         PRIVATE bUslov := {|| cgodina == godina .AND. cidrj == idrj .AND. mjesec >= cmjesec .AND. mjesec <= cMjesecDo .AND. IF( lViseObr, obr = cObracun, .T. ) }
      ENDIF
   ELSE
      IF fSvi
         PRIVATE bUslov := {|| cgodina == godina .AND. cmjesec = mjesec .AND. IF( lViseObr, obr = cObracun, .T. ) }
      ELSE
         PRIVATE bUslov := {|| cgodina == godina .AND. cidrj == idrj .AND. cmjesec = mjesec .AND. IF( lViseObr, obr = cObracun, .T. ) }
      ENDIF
   ENDIF

   nPorOl := nUPorOl := 0

   aNetoMj := {}

   aUkTr := {}

   DO WHILE !Eof() .AND. Eval( bUSlov )

      IF lViseObr .AND. Empty( cObracun )
         ScatterS( godina, mjesec, idrj, idradn )
      ELSE
         Scatter()
      ENDIF

      SELECT radn; hseek _idradn
      SELECT vposla; hseek _idvposla

      IF ( !Empty( copsst ) .AND. copsst <> radn->idopsst )  .OR. ;
            ( !Empty( copsrad ) .AND. copsrad <> radn->idopsrad )
         SELECT ld
         SKIP 1; LOOP
      ENDIF

      _ouneto := Max( _uneto, PAROBR->prosld * gPDLimit / 100 )
      SELECT por; GO TOP
      nPor := nPorOl := 0
      DO WHILE !Eof()  // datoteka por
         PozicOps( POR->poopst )
         IF !ImaUOp( "POR", POR->id )
            SKIP 1; LOOP
         ENDIF
         nPor += round2( Max( dlimit, iznos / 100 * _oUNeto ), gZaok2 )
         SKIP
      ENDDO
      IF radn->porol <> 0 .AND. gDaPorOl == "D" .AND. !Obr2_9() // poreska olaksica
         IF AllTrim( cVarPorOl ) == "2"
            nPorOl := RADN->porol
         ELSEIF AllTrim( cVarPorol ) == "1"
            nPorOl := Round( parobr->prosld * radn->porol / 100, gZaok )
         ELSE
            nPorOl := &( "_I" + cVarPorol )
         ENDIF
         IF nPorOl > nPor // poreska olaksica ne moze biti veca od poreza
            nPorOl := nPor
         ENDIF
         nUPorOl += nPorOl
      ENDIF

      // **** nafiluj datoteku OPSLD *********************
      SELECT ops; SEEK radn->idopsst
      SELECT opsld
      SEEK "1" + radn->idopsst
      IF Found()
         REPLACE iznos WITH iznos + _ouneto, iznos2 WITH iznos2 + nPorOl, ljudi WITH ljudi + 1
      ELSE
         APPEND BLANK
         REPLACE id WITH "1", idops WITH radn->idopsst, iznos WITH _ouneto, ;
            iznos2 WITH iznos2 + nPorOl, ljudi WITH 1
      ENDIF
      SEEK "3" + ops->idkan
      IF Found()
         REPLACE iznos WITH iznos + _ouneto, iznos2 WITH iznos2 + nPorOl, ljudi WITH ljudi + 1
      ELSE
         APPEND BLANK
         REPLACE id WITH "3", idops WITH ops->idkan, iznos WITH _ouneto, ;
            iznos2 WITH iznos2 + nPorOl, ljudi WITH 1
      ENDIF
      SEEK "5" + ops->idn0
      IF Found()
         REPLACE iznos WITH iznos + _ouneto, iznos2 WITH iznos2 + nPorOl, ljudi WITH ljudi + 1
      ELSE
         APPEND BLANK
         REPLACE id WITH "5", idops WITH ops->idn0, iznos WITH _ouneto, ;
            iznos2 WITH iznos2 + nPorOl, ljudi WITH 1
      ENDIF
      SELECT ops; SEEK radn->idopsrad
      SELECT opsld
      SEEK "2" + radn->idopsrad
      IF Found()
         REPLACE iznos WITH iznos + _ouneto, iznos2 WITH iznos2 + nPorOl, ljudi WITH ljudi + 1
      ELSE
         APPEND BLANK
         REPLACE id WITH "2", idops WITH radn->idopsrad, iznos WITH _ouneto, ;
            iznos2 WITH iznos2 + nPorOl, ljudi WITH 1
      ENDIF
      SEEK "4" + ops->idkan
      IF Found()
         REPLACE iznos WITH iznos + _ouneto, iznos2 WITH iznos2 + nPorOl, ljudi WITH ljudi + 1
      ELSE
         APPEND BLANK
         REPLACE id WITH "4", idops WITH ops->idkan, iznos WITH _ouneto, ;
            iznos2 WITH iznos2 + nPorOl, ljudi WITH 1
      ENDIF
      SEEK "6" + ops->idn0
      IF Found()
         REPLACE iznos WITH iznos + _ouneto, iznos2 WITH iznos2 + nPorOl, ljudi WITH ljudi + 1
      ELSE
         APPEND BLANK
         REPLACE id WITH "6", idops WITH ops->idn0, iznos WITH _ouneto, ;
            iznos2 WITH iznos2 + nPorOl, ljudi WITH 1
      ENDIF
      SELECT ld
      // *************************



      nPom := AScan( aNeta, {| x| x[ 1 ] == vposla->idkbenef } )
      IF nPom == 0
         AAdd( aNeta, { vposla->idkbenef, _oUNeto } )
      ELSE
         aNeta[ nPom, 2 ] += _oUNeto
      ENDIF

      FOR i := 1 TO cLDPolja
         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         SELECT tippr; SEEK cPom; SELECT ld
#ifdef CPOR
         n777 := i + cMjesecDO - _mjesec
         aRekap[ IF( n777 > cLDPolja, cLDPolja, n777 ), 1 ] += _s&cPom  // sati
#else
         aRekap[ i, 1 ] += _s&cPom  // sati
#endif
         nIznos := _i&cPom
#ifdef CPOR
         n777 := i + cMjesecDO - _mjesec
         aRekap[ IF( n777 > cLDPolja, cLDPolja, n777 ), 2 ] += nIznos  // iznos
#else
         aRekap[ i, 2 ] += nIznos  // iznos
#endif
         IF tippr->uneto == "N" .AND. nIznos <> 0
            IF nIznos > 0
               nUOdbiciP += nIznos
            ELSE
               nUOdbiciM += nIznos
            ENDIF
         ENDIF
      NEXT

      ++nLjudi
      nUSati += _USati   // ukupno sati
      nUNeto += _UNeto  // ukupno neto iznos
      nUNetoOsnova += _oUNeto  // ukupno neto osnova za obracun por.i dopr.

      cTR := IF( RADN->isplata $ "TR#SK", RADN->idbanka, ;
         Space( Len( RADN->idbanka ) ) )

      IF Len( aUkTR ) > 0 .AND. ( nPomTR := AScan( aUkTr, {| x| x[ 1 ] == cTR } ) ) > 0
         aUkTR[ nPomTR, 2 ] += _uiznos
      ELSE
         AAdd( aUkTR, { cTR, _uiznos } )
      ENDIF

      nUIznos += _UIznos  // ukupno iznos

      nUOdbici += _UOdbici  // ukupno odbici

      IF cMjesec <> cMjesecDo
         nPom := AScan( aNetoMj, {| x| x[ 1 ] == mjesec } )
         IF nPom > 0
            aNetoMj[ nPom, 2 ] += _uneto
            aNetoMj[ nPom, 3 ] += _usati
         ELSE
            nTObl := Select()
            nTRec := PAROBR->( RecNo() )
            ParObr( mjesec, godina, IF( lViseObr, cObracun, ), IF( !fSvi, cIdRj, ) )      // samo pozicionira bazu PAROBR na odgovaraju†i zapis
            AAdd( aNetoMj, { mjesec, _uneto, _usati, PAROBR->k3, PAROBR->k1 } )
            SELECT PAROBR; GO ( nTRec )
            SELECT ( nTObl )
         ENDIF
      ENDIF

      IF RADN->isplata == "TR"  // isplata na tekuci racun
         Rekapld( "IS_" + RADN->idbanka, cgodina, cmjesecDo,;
            _UIznos, 0, RADN->idbanka, RADN->brtekr, RADNIK, .T. )
      ENDIF

      SELECT ld
      SKIP

   ENDDO

   IF nLjudi == 0
      nLjudi := 9999999
   ENDIF
   B_ON
   ?? "LD: Rekapitulacija primanja"
   B_OFF

#ifdef CPOR
   ?? IF( lIsplaceni, "", "-neisplaceni radnici-" )
#endif

   IF !Empty( cstrspr )
      ?? " za radnike strucne spreme ", cStrSpr
   ENDIF
   IF !Empty( cOpsSt )
      ? "Opstina stanovanja:", cOpsSt
   ENDIF
   IF !Empty( cOpsRad )
      ? "Opstina rada:", cOpsRad
   ENDIF

   IF fSvi
      SELECT por
      GO TOP
      SELECT ld_rj
      ? "Obuhvacene radne jedinice: "
      IF !Empty( qqRJ )
         SET FILTER TO &aUsl2
         GO TOP
         DO WHILE !Eof()
            ?? id + " - " + naz
            ? Space( 27 )
            SKIP 1
         ENDDO
      ELSE
         ?? "SVE"
         ?
      ENDIF
      B_ON
      IF cMjesec == cMjesecDo
         ? "Firma:", gNFirma, "  Mjesec:", Str( cmjesec, 2 ) + IspisObr()
         ?? "    Godina:", Str( cGodina, 4 )
         B_OFF
         ? IF( gBodK == "1", "Vrijednost boda:", "Vr.koeficijenta:" ), Transform( parobr->vrbod, "99999.99999" )
      ELSE
         ? "Firma:", gNFirma, "  Za mjesece od:", Str( cmjesec, 2 ), "do", Str( cmjesecDo, 2 ) + IspisObr()
         ?? "    Godina:", Str( cGodina, 4 )
         B_OFF
         // ? IF(gBodK=="1","Vrijednost boda:","Vr.koeficijenta:"), transform(parobr->vrbod,"99999.99999")
      ENDIF
      ?

   ELSE

      SELECT ld_rj
      hseek cIdrj

      SELECT por
      GO TOP

      SELECT ld

      ?
      B_ON
      IF cMjesec == cMjesecDo
         ? "RJ:", cidrj, ld_rj->naz, "  Mjesec:", Str( cmjesec, 2 ) + IspisObr()
         ?? "    Godina:", Str( cGodina, 4 )
         B_OFF
#ifndef CPOR
         ? IF( gBodK == "1", "Vrijednost boda:", "Vr.koeficijenta:" ), Transform( parobr->vrbod, "99999.99999" )
#endif
      ELSE
         ? "RJ:", cidrj, ld_rj->naz, "  Za mjesece od:", Str( cmjesec, 2 ), "do", Str( cmjesecDo, 2 ) + IspisObr()
         ?? "    Godina:", Str( cGodina, 4 )
         B_OFF
      ENDIF
      ?
   ENDIF // fsvi
   ? Space( 60 ) + "Porez:" + Str( por->iznos ) + "%"
   ? m
   cUNeto := "D"



   FOR i := 1 TO cLDPolja

      IF PRow() > 55 + gPStranica
         FF
      ENDIF

      // ********************* 90 - ke
      cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
      _s&cPom := aRekap[ i, 1 ]   // nafiluj ove varijable radi prora~una dodatnih stavki
      _i&cPom := aRekap[ i, 2 ]
      // **********************

      cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
      SELECT tippr; SEEK cPom
      IF tippr->uneto == "N" .AND. cUneto == "D"
         cUneto := "N"
         ? m
         IF !fPorNaRekap
            ? "UKUPNO NETO:"; @ PRow(), nC1 + 8  SAY  nUSati  PICT gpics; ?? " sati"
            @ PRow(), 60 SAY nUNeto PICT gpici; ?? "", gValuta
         ELSE
            ? "UKUPNO NETO:"; @ PRow(), nC1 + 5  SAY  nUSati  PICT gpics; ?? " sati"
            @ PRow(), 42 SAY nUNeto PICT gpici; ?? "", gValuta
            @ PRow(), 60 SAY nUNeto * ( por->iznos / 100 ) PICT gpici; ?? "", gValuta
         ENDIF
         // ****** radi 90 - ke
         _UNeto := nUNeto
         _USati := nUSati
         // ***********
         ? m
      ENDIF


      IF tippr->( Found() ) .AND. tippr->aktivan == "D" .AND. ( aRekap[ i, 2 ] <> 0 .OR. aRekap[ i, 1 ] <> 0 )
#ifdef CPOR
         aRez := GodMj( _godina, _mjesec, -Val( tippr->id ) + 1 )
         cTpnaz := PadR( "Za " + ;
            iif( tippr->id = '14', '<= ', '' ) + ;
            Str( arez[ 2 ], 2 ) + "/" + Str( arez[ 1 ], 4 ), ;
            Len( tippr->naz ) )
#else
         cTPNaz := tippr->naz
#endif
         ? tippr->id + "-" + cTPNaz
         nC1 := PCol()
         IF !fPorNaRekap
            IF tippr->fiksan $ "DN"
               @ PRow(), PCol() + 8 SAY aRekap[ i, 1 ]  PICT gpics; ?? " s"
               @ PRow(), 60 SAY aRekap[ i, 2 ]      PICT gpici
            ELSEIF tippr->fiksan == "P"
               @ PRow(), PCol() + 8 SAY aRekap[ i, 1 ] / nLjudi PICT "999.99%"
               @ PRow(), 60 SAY aRekap[ i, 2 ]        PICT gpici
            ELSEIF tippr->fiksan == "C"
               @ PRow(), 60 SAY aRekap[ i, 2 ]        PICT gpici
            ELSEIF tippr->fiksan == "B"
               @ PRow(), PCol() + 8 SAY aRekap[ i, 1 ] PICT "999999"; ?? " b"
               @ PRow(), 60 SAY aRekap[ i, 2 ]      PICT gpici
            ENDIF
         ELSE
            IF tippr->fiksan $ "DN"
               @ PRow(), PCol() + 5 SAY aRekap[ i, 1 ]  PICT gpics; ?? " s"
               @ PRow(), 42 SAY aRekap[ i, 2 ]      PICT gpici
               IF tippr->uneto == "D"
                  @ PRow(), 60 SAY aRekap[ i, 2 ] * ( por->iznos / 100 )      PICT gpici
               ENDIF
            ELSEIF tippr->fiksan == "P"
               @ PRow(), PCol() + 4 SAY aRekap[ i, 1 ] / nLjudi PICT "999.99%"
               @ PRow(), 42 SAY aRekap[ i, 2 ]        PICT gpici
               IF tippr->uneto == "D"
                  @ PRow(), 60 SAY aRekap[ i, 2 ] * ( por->iznos / 100 )      PICT gpici
               ENDIF
            ELSEIF tippr->fiksan == "C"
               @ PRow(), 42 SAY aRekap[ i, 2 ]        PICT gpici
               IF tippr->uneto == "D"
                  @ PRow(), 60 SAY aRekap[ i, 2 ] * ( por->iznos / 100 )      PICT gpici
               ENDIF
            ELSEIF tippr->fiksan == "B"
               @ PRow(), PCol() + 4 SAY aRekap[ i, 1 ] PICT "999999"; ?? " b"
               @ PRow(), 42 SAY aRekap[ i, 2 ]      PICT gpici
               IF tippr->uneto == "D"
                  @ PRow(), 60 SAY aRekap[ i, 2 ] * ( por->iznos / 100 )      PICT gpici
               ENDIF
            ENDIF
         ENDIF
         IF cMjesec == cMjesecDo
            Rekapld( "PRIM" + tippr->id, cgodina, cmjesec, aRekap[ i, 2 ], aRekap[ i, 1 ] )
         ELSE
            Rekapld( "PRIM" + tippr->id, cgodina, cMjesecDo, aRekap[ i, 2 ], aRekap[ i, 1 ] )
         ENDIF

#ifndef CPOR  // za porodilje to bi bio veliki spisak
         IF "SUMKREDITA" $ tippr->formula
            IF gReKrOs == "X"
               ? m
               ? "  ", "Od toga pojedinacni krediti:"
               SELECT RADKR; SET ORDER TO TAG "3"
               SET FILTER TO Str( cGodina, 4 ) + Str( cMjesec, 2 ) <= Str( godina, 4 ) + Str( mjesec, 2 ) .AND. ;
                  Str( cGodina, 4 ) + Str( cMjesecDo, 2 ) >= Str( godina, 4 ) + Str( mjesec, 2 )
               GO TOP
               DO WHILE !Eof()
                  cIdKred := IDKRED
                  SELECT KRED; HSEEK cIdKred; SELECT RADKR
                  nUkKred := 0
                  DO WHILE !Eof() .AND. IDKRED == cIdKred
                     cNaOsnovu := NAOSNOVU; cIdRadnKR := IDRADN
                     SELECT RADN; HSEEK cIdRadnKR; SELECT RADKR
                     cOpis2   := RADNIK
                     nUkKrRad := 0
                     DO WHILE !Eof() .AND. IDKRED == cIdKred .AND. cNaOsnovu == NAOSNOVU .AND. cIdRadnKR == IDRADN
                        mj := mjesec
                        IF fSvi
                           SELECT ld; SET ORDER TO tag ( TagVO( "2" ) ); hseek  Str( cGodina, 4 ) + Str( mj, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                           // "LDi2","str(godina)+str(mjesec)+idradn"
                        ELSE
                           SELECT ld; hseek  Str( cGodina, 4 ) + cidrj + Str( mj, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                        ENDIF // fsvi
                        SELECT radkr
                        IF ld->( Found() )
                           nUkKred  += iznos
                           nUkKrRad += iznos
                        ENDIF
                        SKIP 1
                     ENDDO
                     IF nUkKrRad <> 0
                        Rekapld( "KRED" + cidkred + cnaosnovu, cgodina, cmjesecDo, nUkKrRad, 0, cidkred, cnaosnovu, cOpis2, .T. )
                     ENDIF
                  ENDDO
                  IF nUkKred <> 0    // ispisati kreditora
                     IF PRow() > 55 + gPStranica
                        FF
                     ENDIF
                     ? "  ", cidkred, Left( kred->naz, 22 )
                     @ PRow(), 58 SAY nUkKred  PICT "(" + gpici + ")"
                  ENDIF
               ENDDO
            ELSE
               ? m
               ? "  ", "Od toga pojedinacni krediti:"
               cOpis2 := ""
               SELECT radkr; SET ORDER TO 3  ; GO TOP
               // "RADKRi3","idkred+naosnovu+idradn+str(godina)+str(mjesec)","RADKR")
               DO WHILE !Eof()
                  SELECT kred; hseek radkr->idkred; SELECT radkr
                  PRIVATE cidkred := idkred, cNaOsnovu := naosnovu
                  SELECT radn; hseek radkr->idradn; SELECT radkr
                  cOpis2 := RADNIK
                  SEEK cidkred + cnaosnovu
                  PRIVATE nUkKred := 0
                  DO WHILE !Eof() .AND. idkred == cidkred .AND. ( cnaosnovu == naosnovu .OR. gReKrOs == "N" )
                     IF fSvi
                        SELECT ld; SET ORDER TO tag ( TagVO( "2" ) ); hseek  Str( cGodina, 4 ) + Str( cmjesec, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                        // "LDi2","str(godina)+str(mjesec)+idradn"
                     ELSE
                        SELECT ld; hseek  Str( cGodina, 4 ) + cidrj + Str( cmjesec, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                     ENDIF // fsvi
                     SELECT radkr
                     IF ld->( Found() ) .AND. godina == cgodina .AND. mjesec = cmjesec
                        nUkKred += iznos
                     ENDIF
                     IF cMjesecDo > cMjesec
                        FOR mj := cMjesec + 1 TO cMjesecDo
                           IF fSvi
                              SELECT ld; SET ORDER TO tag ( TagVO( "2" ) ); hseek  Str( cGodina, 4 ) + Str( mj, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                              // "LDi2","str(godina)+str(mjesec)+idradn"
                           ELSE
                              SELECT ld; hseek  Str( cGodina, 4 ) + cidrj + Str( mj, 2 ) + if( lViseObr .AND. !Empty( cObracun ), cObracun, "" ) + radkr->idradn
                           ENDIF // fsvi
                           SELECT radkr
                           IF ld->( Found() ) .AND. godina == cgodina .AND. mjesec = mj
                              nUkKred += iznos
                           ENDIF
                        NEXT
                     ENDIF
                     SKIP
                  ENDDO
                  IF nukkred <> 0
                     IF PRow() > 55 + gPStranica
                        FF
                     ENDIF
                     ? "  ", cidkred, Left( kred->naz, 22 ), IF( gReKrOs == "N", "", cnaosnovu )
                     @ PRow(), 58 SAY nUkKred  PICT "(" + gpici + ")"
                     IF cMjesec == cMjesecDo
                        Rekapld( "KRED" + cidkred + cnaosnovu, cgodina, cmjesec, nukkred, 0, cidkred, cnaosnovu, cOpis2 )
                     ELSE
                        Rekapld( "KRED" + cidkred + cnaosnovu, cgodina, cMjesecDo, nukkred, 0, cidkred, cnaosnovu, cOpis2 )
                     ENDIF
                  ENDIF
               ENDDO
               SELECT ld
            ENDIF
         ENDIF
#endif  // CPOR

      ENDIF   // tippr aktivan

   NEXT  // cldpolja

   IF IzFMKIni( "LD", "Rekap_ZaIsplatuRasclanitiPoTekRacunima", "N", KUMPATH ) == "D" .AND. Len( aUkTR ) > 1
      ? m
      ? "ZA ISPLATU:"
      ? "-----------"
      nMArr := Select()
      SELECT KRED
      ASort( aUkTr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
      FOR i := 1 TO Len( aUkTR )
         IF Empty( aUkTR[ i, 1 ] )
            ? PadR( "B L A G A J N A", Len( aUkTR[ i, 1 ] + KRED->naz ) + 1 )
         ELSE
            HSEEK aUkTR[ i, 1 ]
            ? aUkTR[ i, 1 ], KRED->naz
         ENDIF
         @ PRow(), 60 SAY aUkTR[ i, 2 ] PICT gpici; ?? "", gValuta
      NEXT
      SELECT ( nMArr )
   ENDIF

   ? m
   IF !fPorNaRekap
      ?  "UKUPNO ZA ISPLATU";  @ PRow(), 60 SAY nUIznos PICT gpici; ?? "", gValuta
   ELSE
      ?  "UKUPNO ZA ISPLATU";  @ PRow(), 42 SAY nUIznos PICT gpici; ?? "", gValuta
   ENDIF

   ? m
   IF !lGusto
      ?
   ENDIF

   // proizvoljni redovi pocinju sa "9"
   ?
   SELECT tippr; SEEK "9"
   DO WHILE !Eof() .AND. Left( id, 1 ) = "9"
      IF PRow() > 55 + gPStranica
         FF
      ENDIF
      ? tippr->id + "-" + tippr->naz
      cPom := tippr->formula
      IF !fPorNaRekap
         @ PRow(), 60 SAY round2( &cPom, gZaok2 )      PICT gpici
      ELSE
         @ PRow(), 42 SAY round2( &cPom, gZaok2 )      PICT gpici
      ENDIF
      IF cMjesec == cMjesecDo
         Rekapld( "PRIM" + tippr->id, cgodina, cmjesec, round2( &cpom, gZaok2 ), 0 )
      ELSE
         Rekapld( "PRIM" + tippr->id, cgodina, cMjesecDo, round2( &cpom, gZaok2 ), 0 )
      ENDIF
      SKIP
      IF Eof() .OR. !Left( id, 1 ) = "9"
         ? m
      ENDIF
   ENDDO


   IF cMjesec == cMjesecDo     // za viçe mjeseci nema prikaza poreza i doprinosa
      IF !lGusto
         ?
      ENDIF
      nBO := 0
      ? "Koef. Bruto osnove (KBO):", Transform( parobr->k3, "999.99999%" )
      ?? Space( 3 ), "BRUTO OSNOVA = NETO OSNOVA*KBO ="
      @ PRow(), PCol() + 1 SAY nBo := round2( parobr->k3 / 100 * nUNetoOsnova, gZaok2 )  PICT gpici
      ?

#ifdef CPOR
      IF cUmPD == "D"
         IF cMjesec == 1
            cGodina2 := cGodina - 1; cMjesec2 := 12
         ELSE
            cGodina2 := cGodina; cMjesec2 := cMjesec - 1
         ENDIF
         SELECT PAROBR
         nParRec := RecNo()
         HSEEK Str( cMjesec2, 2 ) + cObracun
         SELECT LD
         PushWA()
         USE
         SELECT ( F_LDNO ); usex ( KUMPATH + "LDNO" ) ALIAS LD

         PRIVATE cFilt1 := ""
         cFilt1 := ".t." + IF( Empty( cStrSpr ), "", ".and.IDSTRSPR==" + cm2str( cStrSpr ) ) + ;
            IF( !fSvi .OR. Empty( qqRJ ), "", ".and." + aUsl1 )
         cFilt1 := StrTran( cFilt1, ".t..and.", "" )
         IF cFilt1 == ".t."
            SET FILTER TO
         ELSE
            SET FILTER TO &cFilt1
         ENDIF

         IF fSvi // sve radne jedinice
            SET ORDER TO 2
            SEEK Str( cGodina2, 4 ) + Str( cmjesec2, 2 )
         ELSE
            SET ORDER TO 1
            SEEK Str( cGodina2, 4 ) + cidrj + Str( cmjesec2, 2 )
         ENDIF

         nT1 := nT2 := nTPor := nTDopr := 0
         n01 := 0  // van neta plus
         n02 := 0  // van neta minus
         DO WHILE !Eof() .AND.  cgodina2 == godina .AND. cmjesec2 = mjesec .AND. ( fSvi .OR. cidrj == idrj )
            Scatter()
            SELECT radn; hseek _idradn
            SELECT vposla; hseek _idvposla
            SELECT kbenef; hseek vposla->idkbenef
            SELECT ld
            IF ( !Empty( copsst ) .AND. copsst <> radn->idopsst )  .OR. ;
                  ( !Empty( copsrad ) .AND. copsrad <> radn->idopsrad )
               SKIP 1; LOOP
            ENDIF


            // neophodno zbog "po opstinama"
            // *******************************
            SELECT por; GO TOP
            nPor := nPorOl := nUPorOl2 := 0
            DO WHILE !Eof()  // datoteka por
               PozicOps( POR->poopst )
               IF !ImaUOp( "POR", POR->id )
                  SKIP 1; LOOP
               ENDIF
               nPor += round2( Max( dlimit, iznos / 100 * Max( _UNeto, PAROBR->prosld * gPDLimit / 100 ) ), gZaok2 )
               SKIP
            ENDDO
            IF radn->porol <> 0 .AND. gDaPorOl == "D" .AND. !Obr2_9() // poreska olaksica
               IF AllTrim( cVarPorOl ) == "2"
                  nPorOl := RADN->porol
               ELSEIF AllTrim( cVarPorol ) == "1"
                  nPorOl := Round( parobr->prosld * radn->porol / 100, gZaok )
               ELSE
                  nPorOl := &( "_I" + cVarPorol )
               ENDIF
               IF nPorOl > nPor // poreska olaksica ne moze biti veca od poreza
                  nPorOl := nPor
               ENDIF
               nUPorOl2 += nPorOl
            ENDIF

            // **** nafiluj datoteku OPSLD *********************
            _uneto := Max( _uneto, PAROBR->prosld * gPDLimit / 100 )
            SELECT ops; SEEK radn->idopsst
            SELECT opsld
            SEEK "1" + radn->idopsst
            IF Found()
               REPLACE piznos WITH piznos + _uneto, piznos2 WITH piznos2 + nPorOl, pljudi WITH pljudi + 1
            ELSE
               APPEND BLANK
               REPLACE id WITH "1", idops   WITH radn->idopsst, piznos WITH _uneto, ;
                  piznos2 WITH piznos2 + nPorOl, pljudi WITH 1
            ENDIF
            SEEK "3" + ops->idkan  // kanton stanovanja
            IF Found()
               REPLACE piznos WITH piznos + _uneto, piznos2 WITH piznos2 + nPorOl, pljudi WITH pljudi + 1
            ELSE
               APPEND BLANK
               REPLACE id WITH "3", idops   WITH ops->idkan, piznos WITH _uneto, ;
                  piznos2 WITH piznos2 + nPorOl, pljudi WITH 1
            ENDIF
            SEEK "5" + ops->idn0  // entitet stanovanja
            IF Found()
               REPLACE piznos WITH piznos + _uneto, piznos2 WITH piznos2 + nPorOl, pljudi WITH pljudi + 1
            ELSE
               APPEND BLANK
               REPLACE id WITH "5", idops   WITH ops->idn0, piznos WITH _uneto, ;
                  piznos2 WITH piznos2 + nPorOl, pljudi WITH 1
            ENDIF


            SELECT ops; SEEK radn->idopsst
            SELECT opsld
            SEEK "2" + radn->idopsrad
            IF Found()
               REPLACE piznos WITH piznos + _uneto, piznos2 WITH piznos2 + nPorOl, pljudi WITH pljudi + 1
            ELSE
               APPEND BLANK
               REPLACE id WITH "2", idops   WITH radn->idopsrad, piznos WITH _uneto, ;
                  piznos2 WITH piznos2 + nPorOl, pljudi WITH 1
            ENDIF
            SEEK "4" + ops->idkan  // kanton rada
            IF Found()
               REPLACE piznos WITH piznos + _uneto, piznos2 WITH piznos2 + nPorOl, pljudi WITH pljudi + 1
            ELSE
               APPEND BLANK
               REPLACE id WITH "4", idops   WITH ops->idkan, piznos WITH _uneto, ;
                  piznos2 WITH piznos2 + nPorOl, pljudi WITH 1
            ENDIF
            SEEK "6" + ops->idn0  // entitet rada
            IF Found()
               REPLACE piznos WITH piznos + _uneto, piznos2 WITH piznos2 + nPorOl, pljudi WITH pljudi + 1
            ELSE
               APPEND BLANK
               REPLACE id WITH "6", idops   WITH ops->idn0, piznos WITH _uneto, ;
                  piznos2 WITH piznos2 + nPorOl, pljudi WITH 1
            ENDIF
            // *******************************

            SELECT ld
            n01 := 0; n02 := 0
            FOR i := 1 TO cLDPolja
               cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
               SELECT tippr; SEEK cPom; SELECT ld

               IF tippr->( Found() ) .AND. tippr->aktivan == "D"
                  nIznos := _i&cpom
                  IF cpom == "01"
                     n01 += nIznos
                  ELSE
                     n02 += nIznos
                  ENDIF
               ENDIF
            NEXT
            nT1 += n01
            nT2 += n02
            SKIP 1
         ENDDO  // LD
         nUNeto2 := nT1 + nT2
         nBo2 := round2( parobr->k3 / 100 * nUNeto2, gZaok2 )
         // gPDLimit?!
         nPK3 := PAROBR->K3
         USE
         SELECT PAROBR
         GO ( nParRec )
         O_LD
         PopWA()
      ENDIF
#endif



      SELECT por
      GO TOP
      nPom := nPor := nPor2 := nPorOps := nPorOps2 := 0
      nC1 := 20

      m := "----------------------- -------- ----------- -----------"
      IF cUmPD == "D"
         m += " ----------- -----------"
      ENDIF

      IF cUmPD == "D"
         P_12CPI
         ? "----------------------- -------- ----------- ----------- ----------- -----------"
         ? "                                 Obracunska     Porez    Preplaceni     Porez   "
         ? "     Naziv poreza          %      osnovica   po obracunu    porez     za uplatu "
         ? "          (1)             (2)        (3)     (4)=(2)*(3)     (5)     (6)=(4)-(5)"
         ? "----------------------- -------- ----------- ----------- ----------- -----------"
      ENDIF

      DO WHILE !Eof()

         IF PRow() > 55 + gPStranica
            FF
         ENDIF

         ? id, "-", naz
         @ PRow(), PCol() + 1 SAY iznos PICT "99.99%"
         nC1 := PCol() + 1

         IF !Empty( poopst )
            IF poopst == "1"
               ?? " (po opst.stan)"
            ELSEIF poopst == "2"
               ?? " (po opst.stan)"
            ELSEIF poopst == "3"
               ?? " (po kant.stan)"
            ELSEIF poopst == "4"
               ?? " (po kant.rada)"
            ELSEIF poopst == "5"
               ?? " (po ent. stan)"
            ELSEIF poopst == "6"
               ?? " (po ent. rada)"
               ?? " (po opst.rada)"
            ENDIF
            nOOP := 0      // ukupna Osnovica za ObraŸun Poreza za po opçtinama
            nPOLjudi := 0  // ukup.ljudi za po opçtinama
            nPorOps := 0
            nPorOps2 := 0
            SELECT opsld
            SEEK por->poopst
            ? StrTran( m, "-", "=" )
            DO WHILE !Eof() .AND. id == por->poopst   // idopsst
               SELECT ops; hseek opsld->idops; SELECT opsld
               IF !ImaUOp( "POR", POR->id )
                  SKIP 1; LOOP
               ENDIF
               ? idops, ops->naz
               @ PRow(), nc1 SAY iznos PICTURE gpici
               @ PRow(), PCol() + 1 SAY nPom := round2( Max( por->dlimit, por->iznos / 100 * iznos ), gZaok2 ) PICT gpici
               IF cUmPD == "D"
                  // ______  PORLD ______________
                  @ PRow(), PCol() + 1 SAY nPom2 := round2( Max( por->dlimit, por->iznos / 100 * piznos ), gZaok2 ) PICT gpici
                  @ PRow(), PCol() + 1 SAY nPom - nPom2 PICT gpici
                  Rekapld( "POR" + por->id + idops, cgodina, cmjesec, nPom - nPom2, 0, idops, NLjudi() )
                  nPorOps2 += nPom2
               ELSE
                  Rekapld( "POR" + por->id + idops, cgodina, cmjesec, nPom, iznos, idops, NLjudi() )
               ENDIF
               nOOP += iznos
               nPOLjudi += ljudi
               nPorOps += nPom
               SKIP
               IF PRow() > RPT_PAGE_LEN + gPStranica; FF; ENDIF
            ENDDO
            SELECT por
            ? m
            nPor += nPorOps
            nPor2 += nPorOps2
         ENDIF // poopst
         IF !Empty( poopst )
            ? m
            ? "Ukupno:"
            // @ prow(),nc1 SAY nUNeto pict gpici
            @ PRow(), nc1 SAY nOOP PICT gpici
            @ PRow(), PCol() + 1 SAY nPorOps   PICT gpici
            IF cUmPD == "D"
               @ PRow(), PCol() + 1 SAY nPorOps2   PICT gpici
               @ PRow(), PCol() + 1 SAY nPorOps - nPorOps2   PICT gpici
               Rekapld( "POR" + por->id, cgodina, cmjesec, nPorOps - nPorOps2, 0,, NLjudi() )
            ELSE
               // Rekapld("POR"+por->id,cgodina,cmjesec,nPorOps,nUNeto,,NLjudi())
               Rekapld( "POR" + por->id, cgodina, cmjesec, nPorOps, nOOP,, "(" + AllTrim( Str( nPOLjudi ) ) + ")" )
            ENDIF
            ? m
         ELSE
            @ PRow(), nc1 SAY nUNeto PICT gpici
            @ PRow(), PCol() + 1 SAY nPom := round2( Max( dlimit, iznos / 100 * nUNeto ), gZaok2 ) PICT gpici
            IF cUmPD == "D"
               @ PRow(), PCol() + 1 SAY nPom2 := round2( Max( dlimit, iznos / 100 * nUNeto2 ), gZaok2 ) PICT gpici
               @ PRow(), PCol() + 1 SAY nPom - nPom2 PICT gpici
               Rekapld( "POR" + por->id, cgodina, cmjesec, nPom - nPom2, 0 )
               nPor2 += nPom2
            ELSE
               Rekapld( "POR" + por->id, cgodina, cmjesec, nPom, nUNeto,, "(" + AllTrim( Str( nLjudi ) ) + ")" )
            ENDIF
            nPor += nPom
         ENDIF


         SKIP
      ENDDO
      IF round2( nUPorOl, 2 ) <> 0 .AND. gDaPorOl == "D" .AND. !Obr2_9()
         ? "PORESKE OLAKSICE"
         SELECT por; GO TOP
         nPOlOps := 0
         IF !Empty( poopst )
            IF poopst == "1"
               ?? " (po opst.stan)"
            ELSE
               ?? " (po opst.rada)"
            ENDIF
            nPOlOps := 0
            SELECT opsld
            SEEK por->poopst
            DO WHILE !Eof() .AND. id == por->poopst
               IF PRow() > 55 + gPStranica
                  FF
               ENDIF
               SELECT ops; hseek opsld->idops; SELECT opsld
               IF !ImaUOp( "POR", POR->id )
                  SKIP 1; LOOP
               ENDIF
               ? idops, ops->naz
               @ PRow(), nc1 SAY parobr->prosld PICTURE gpici
               @ PRow(), PCol() + 1 SAY round2( iznos2, gZaok2 )    PICTURE gpici
               Rekapld( "POROL" + por->id + opsld->idops, cgodina, cmjesec, round2( iznos2, gZaok2 ), 0, opsld->idops, NLjudi() )
               SKIP
               IF PRow() > RPT_PAGE_LEN + gPStranica; FF; ENDIF
            ENDDO
            SELECT por
            ? m
            ? "UKUPNO POR.OL"
         ENDIF // poopst
         @ PRow(), nC1 SAY parobr->prosld  PICT gpici
         @ PRow(), PCol() + 1 SAY round2( nUPorOl, gZaok2 )    PICT gpici
         Rekapld( "POROL" + por->id, cgodina, cmjesec, round2( nUPorOl, gZaok2 ), 0,, "(" + AllTrim( Str( nLjudi ) ) + ")" )
         IF !Empty( poopst ); ? m; ENDIF

      ENDIF
      ? m
      ? "Ukupno Porez"
      @ PRow(), nC1 SAY Space( Len( gpici ) )
      @ PRow(), PCol() + 1 SAY nPor - nUPorOl PICT gpici
      IF cUmPD == "D"
         @ PRow(), PCol() + 1 SAY nPor2              PICT gpici
         @ PRow(), PCol() + 1 SAY nPor - nUPorOl - nPor2 PICT gpici
      ENDIF
      ? m
      IF !lGusto
         ?
         ?
      ENDIF
      ?
      IF PRow() > 55 + gpStranica
         FF
      ENDIF


      m := "----------------------- -------- ----------- -----------"
      IF cUmPD == "D"
         m += " ----------- -----------"
      ENDIF
      SELECT dopr; GO TOP
      nPom := nDopr := 0
      nPom2 := nDopr2 := 0
      nC1 := 20

      IF cUmPD == "D"
         ? "----------------------- -------- ----------- ----------- ----------- -----------"
         ? "                                 Obracunska   Doprinos   Preplaceni   Doprinos  "
         ? "    Naziv doprinosa        %      osnovica   po obracunu  doprinos    za uplatu "
         ? "          (1)             (2)        (3)     (4)=(2)*(3)     (5)     (6)=(4)-(5)"
         ? "----------------------- -------- ----------- ----------- ----------- -----------"
      ENDIF

      DO WHILE !Eof()
         IF PRow() > 55 + gpStranica; FF; ENDIF

         IF Right( id, 1 ) == "X"
            ? m
         ENDIF
         ? id, "-", naz

         @ PRow(), PCol() + 1 SAY iznos PICT "99.99%"
         nC1 := PCol() + 1

         IF Empty( idkbenef ) // doprinos udara na neto

            IF !Empty( poopst )
               IF poopst == "1"
                  ?? " (po opst.stan)"
               ELSEIF poopst == "2"
                  ?? " (po opst.rada)"
               ELSEIF poopst == "3"
                  ?? " (po kant.stan)"
               ELSEIF poopst == "4"
                  ?? " (po kant.rada)"
               ELSEIF poopst == "5"
                  ?? " (po ent. stan)"
               ELSEIF poopst == "6"
                  ?? " (po ent. rada)"
               ENDIF
               ? StrTran( m, "-", "=" )
               nOOD := 0          // ukup.osnovica za obraŸun doprinosa za po opçtinama
               nPOLjudi := 0      // ukup.ljudi za po opçtinama
               nDoprOps := 0
               nDoprOps2 := 0
               SELECT opsld
               SEEK dopr->poopst
               DO WHILE !Eof() .AND. id == dopr->poopst
                  SELECT ops; hseek opsld->idops; SELECT opsld
                  IF !ImaUOp( "DOPR", DOPR->id )
                     SKIP 1; LOOP
                  ENDIF
                  ? idops, ops->naz
                  nBOOps := round2( iznos * parobr->k3 / 100, gZaok2 )
                  @ PRow(), nc1 SAY nBOOps PICTURE gpici
                  nPom := round2( Max( dopr->dlimit, dopr->iznos / 100 * nBOOps ), gZaok2 )
                  IF cUmPD == "D"
                     nBOOps2 := round2( piznos * nPK3 / 100, gZaok2 )
                     nPom2 := round2( Max( dopr->dlimit, dopr->iznos / 100 * nBOOps2 ), gZaok2 )
                  ENDIF
                  IF Round( dopr->iznos, 4 ) = 0 .AND. dopr->dlimit > 0
                     nPom := dopr->dlimit * opsld->ljudi
                     IF cUmPD == "D"
                        nPom2 := dopr->dlimit * opsld->pljudi
                     ENDIF
                  ENDIF
                  @ PRow(), PCol() + 1 SAY  nPom PICTURE gpici
                  IF cUmPD == "D"
                     @ PRow(), PCol() + 1 SAY  nPom2 PICTURE gpici
                     @ PRow(), PCol() + 1 SAY  nPom - nPom2 PICTURE gpici
                     Rekapld( "DOPR" + dopr->id + idops, cgodina, cmjesec, nPom - nPom2, 0, idops, NLjudi() )
                     nDoprOps2 += nPom2
                     nDoprOps += nPom
                  ELSE
                     Rekapld( "DOPR" + dopr->id + opsld->idops, cgodina, cmjesec, npom, nBOOps, idops, NLjudi() )
                     nDoprOps += nPom
                  ENDIF
                  nOOD += nBOOps
                  nPOLjudi += ljudi
                  SKIP
                  IF PRow() > RPT_PAGE_LEN + gPStranica; FF; ENDIF
               ENDDO // opsld
               SELECT dopr
               ? m
               ? "UKUPNO ", DOPR->ID
               // @ prow(),nC1 SAY nBO pict gpici
               @ PRow(), nC1 SAY nOOD PICT gpici
               @ PRow(), PCol() + 1 SAY nDoprOps PICT gpici
               IF cUmPD == "D"
                  @ PRow(), PCol() + 1 SAY nDoprOps2 PICT gpici
                  @ PRow(), PCol() + 1 SAY nDoprOps - nDoprOps2 PICT gpici
                  Rekapld( "DOPR" + dopr->id, cgodina, cmjesec, nDoprOps - nDoprOps2, 0,, NLjudi() )
                  nPom2 := nDoprOps2
               ELSE
                  IF nDoprOps > 0
                     // Rekapld("DOPR"+dopr->id,cgodina,cmjesec,nDoprOps,nBO,,NLjudi())
                     Rekapld( "DOPR" + dopr->id, cgodina, cmjesec, nDoprOps, nOOD,, "(" + AllTrim( Str( nPOLjudi ) ) + ")" )
                  ENDIF
               ENDIF
               ? m
               nPom := nDoprOps
            ELSE
               // doprinosi nisu po opstinama
               @ PRow(), nC1 SAY nBO PICT gpici
               nPom := round2( Max( dlimit, iznos / 100 * nBO ), gZaok2 )
               IF cUmPD == "D"
                  nPom2 := round2( Max( dlimit, iznos / 100 * nBO2 ), gZaok2 )
               ENDIF
               IF Round( iznos, 4 ) = 0 .AND. dlimit > 0
                  nPom := dlimit * nljudi      // nije po opstinama
                  IF cUmPD == "D"
                     nPom2 := dlimit * nljudi      // nije po opstinama ?!?nLjudi
                  ENDIF
               ENDIF
               @ PRow(), PCol() + 1 SAY nPom PICT gpici
               IF cUmPD == "D"
                  @ PRow(), PCol() + 1 SAY nPom2 PICT gpici
                  @ PRow(), PCol() + 1 SAY nPom - nPom2 PICT gpici
                  Rekapld( "DOPR" + dopr->id, cgodina, cmjesec, nPom - nPom2, 0 )
               ELSE
                  Rekapld( "DOPR" + dopr->id, cgodina, cmjesec, nPom, nBO,, "(" + AllTrim( Str( nLjudi ) ) + ")" )
               ENDIF
            ENDIF // poopst
         ELSE
            // **************** po stopama beneficiranog radnog staza ?? nije testirano
            nPom0 := AScan( aNeta, {| x| x[ 1 ] == idkbenef } )
            IF nPom0 <> 0
               nPom2 := parobr->k3 / 100 * aNeta[ nPom0, 2 ]
            ELSE
               nPom2 := 0
            ENDIF
            IF round2( nPom2, gZaok2 ) <> 0
               @ PRow(), PCol() + 1 SAY nPom2 PICT gpici
               nC1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY nPom := round2( Max( dlimit, iznos / 100 * nPom2 ), gZaok2 ) PICT gpici
            ENDIF
         ENDIF  // ****************  nije testirano

         IF Right( id, 1 ) == "X"
            ? m
            IF !lGusto
               ?
            ENDIF
            nDopr += nPom
            IF cUmPD == "D"
               nDopr2 += nPom2
            ENDIF
         ENDIF

         SKIP
         IF PRow() > 56 + gPStranica; FF; ENDIF
      ENDDO
      ? m
      ? "Ukupno Doprinosi"
      @ PRow(), nc1 SAY Space( Len( gpici ) )
      @ PRow(), PCol() + 1 SAY nDopr  PICT gpici
      IF cUmPD == "D"
         @ PRow(), PCol() + 1 SAY nDopr2  PICT gpici
         @ PRow(), PCol() + 1 SAY nDopr - nDopr2  PICT gpici
      ENDIF
      ? m
      IF cUmPD == "D"
         P_10CPI
      ENDIF
      ?
      ?


      m := "---------------------------------"
      IF PRow() > 49 + gPStranica; FF; ENDIF
      ? m
      ? "     NETO PRIMANJA:"
      @ PRow(), PCol() + 1 SAY nUNeto PICT gpici
      ?? "(za isplatu:"
      @ PRow(), PCol() + 1 SAY nUNeto + nUOdbiciM PICT gpici
      ?? ",Obustave:"
      @ PRow(), PCol() + 1 SAY -nUOdbiciM PICT gpici
      ?? ")"

      ? " PRIMANJA VAN NETA:"
      @ PRow(), PCol() + 1 SAY nUOdbiciP PICT gpici  // dodatna primanja van neta
      ? "            POREZI:"
      IF cUmPD == "D"
         @ PRow(), PCol() + 1 SAY nPor - nUPorOl - nPor2    PICT gpici
      ELSE
         @ PRow(), PCol() + 1 SAY nPor - nUPorOl    PICT gpici
      ENDIF
      ? "         DOPRINOSI:"
      IF cUmPD == "D"
         @ PRow(), PCol() + 1 SAY nDopr - nDopr2    PICT gpici
      ELSE
         @ PRow(), PCol() + 1 SAY nDopr    PICT gpici
      ENDIF
      ? m
      IF cUmPD == "D"
         ? " POTREBNA SREDSTVA:"
         @ PRow(), PCol() + 1 SAY nUNeto + nUOdbiciP + ( nPor - nUPorOl ) + nDopr - nPor2 - nDopr2    PICT gpici
      ELSE
         ? " POTREBNA SREDSTVA:"
         @ PRow(), PCol() + 1 SAY nUNeto + nUOdbiciP + ( nPor - nUPorOl ) + nDopr    PICT gpici
      ENDIF
      ? m

      ?
      ? "Izvrsena obrada na ", Str( nLjudi, 5 ), "radnika"
      ?
      IF nUSati == 0; nUSati := 999999; ENDIF
      ? "Prosjecni neto/satu je", AllTrim( Transform( nUNeto, gpici ) ), "/", AllTrim( Str( nUSati ) ), "=", ;
         AllTrim( Transform( nUNeto / nUsati, gpici ) ), "*", AllTrim( Transform( parobr->k1, "999" ) ), "=", ;
         AllTrim( Transform( nUneto / nUsati * parobr->k1, gpici ) )

   ELSE // cMjesec==cMjesecDo // za viçe mjeseci nema prikaza poreza i doprinosa
      // ali se mo§e dobiti bruto osnova i prosjeŸni neto po satu
      // --------------------------------------------------------
      ASort( aNetoMj,,, {| x, y| x[ 1 ] < y[ 1 ] } )
      ?
      ?     "MJESEC³  UK.NETO  ³UK.SATI³KOEF.BRUTO³FOND SATI³BRUTO OSNOV³PROSJ.NETO "
      ?     " (A)  ³    (B)    ³  (C)  ³   (D)    ³   (E)   ³(B)*(D)/100³(E)*(B)/(C)"
      ? ms := "ÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄ"
      nT1 := nT2 := nT3 := nT4 := nT5 := 0
      FOR i := 1 TO Len( aNetoMj )
         ? Str( aNetoMj[ i, 1 ], 4, 0 ) + ". ³" + ;
            TRANS( aNetoMj[ i, 2 ], gPicI ) + "³" + ;
            Str( aNetoMj[ i, 3 ], 7 ) + "³" + ;
            TRANS( aNetoMj[ i, 4 ], "999.99999%" ) + "³" + ;
            Str( aNetoMj[ i, 5 ], 9 ) + "³" + ;
            TRANS( ROUND2( aNetoMj[ i, 2 ] * aNetoMj[ i, 4 ] / 100, gZaok2 ), gPicI ) + "³" + ;
            TRANS( aNetoMj[ i, 5 ] * aNetoMj[ i, 2 ] / aNetoMj[ i, 3 ], gPicI )
         nT1 += aNetoMj[ i, 2 ]
         nT2 += aNetoMj[ i, 3 ]
         nT3 += aNetoMj[ i, 5 ]
         nT4 += ROUND2( aNetoMj[ i, 2 ] * aNetoMj[ i, 4 ] / 100, gZaok2 )
         nT5 += aNetoMj[ i, 5 ] * aNetoMj[ i, 2 ] / aNetoMj[ i, 3 ]
      NEXT
      nT5 := nT5 / Len( aNetoMj )
      // nT5 := nT3*nT1/nT2
      ? ms
      ?     "UKUPNO³" + ;
         TRANS( nT1, gPicI ) + "³" + ;
         Str( nT2, 7 ) + "³" + ;
         "          " + "³" + ;
         Str( nT3, 9 ) + "³" + ;
         TRANS( nT4, gPicI ) + "³" + ;
         TRANS( nT5, gPicI )

   ENDIF

   ?
   P_10CPI
   IF PRow() < RPT_PAGE_LEN + gPStranica
      nPom := RPT_PAGE_LEN + gPStranica - PRow()
      FOR i := 1 TO nPom
         ?
      NEXT
   ENDIF
   ?  PadC( "     Obradio:                                 Direktor:    ", 80 )
   ?
   ?  PadC( "_____________________                    __________________", 80 )
   ?
   FF
   IF lGusto
      gRPL_Normal()
      gPStranica -= nDSGusto
   ENDIF
   END PRINT
   CLOSERET

FUNCTION RekapLD_OLD( cId, ngodina, nmjesec, nizn1, nizn2, cidpartner, copis, copis2, lObavDodaj )

   // {

   IF lObavDodaj == NIL; lObavDodaj := .F. ; ENDIF

   IF cidpartner = NIL
      cidpartner = ""
   ENDIF

   IF copis = NIL
      copis = ""
   ENDIF
   IF copis2 = NIL
      copis2 = ""
   ENDIF

   pushwa()
   SELECT rekld
   IF lObavDodaj
      APPEND BLANK
   ELSE
      SEEK Str( ngodina, 4 ) + Str( nmjesec, 2 ) + cid + " "
      IF !Found()
         APPEND BLANK
      ENDIF
   ENDIF
   REPLACE godina WITH Str( ngodina, 4 ),  mjesec WITH Str( nmjesec, 2 ), ;
      id    WITH  cid, ;
      iznos1 WITH nizn1, iznos2 WITH nizn2, ;
      idpartner WITH cidpartner, ;
      opis WITH copis,;
      opis2 WITH cOpis2

   popwa()

   RETURN



// -------------------------------------------------------
// kreiranje mtemp tabele
// -------------------------------------------------------
STATIC FUNCTION _create_ld_tmp()

   LOCAL _i, _struct
   LOCAL _table := "_ld"
   LOCAL _ret := .T.

   // pobrisi tabelu
   IF File( my_home() + _table + ".dbf" )
      FErase( my_home() + _table + ".dbf" )
   ENDIF

   _struct := LD->( dbStruct() )

   // ovdje cemo sva numericka polja prosiriti za 4 mjesta
   // (izuzeci su polja GODINA i MJESEC)

   FOR _i := 1 TO Len( _struct )
      IF _struct[ _i, 2 ] == "N" .AND. !( Upper( AllTrim( _struct[ _i, 1 ] ) ) $ "GODINA#MJESEC" )
         _struct[ _i, 3 ] += 4
      ENDIF
   NEXT

   // kreiraj tabelu
   dbCreate( my_home() + _table + ".dbf", _struct )

   IF !File( my_home() + _table + ".dbf" )
      MsgBeep( "Ne postoji " + _table + ".dbf !!!" )
      _ret := .F.
   ENDIF

   RETURN _ret



FUNCTION UKartPl()

   LOCAL nC1 := 20
   LOCAL i

   cIdRadn := Space( _LR_ )
   cIdRj := gRj
   cMjesec := gMjesec
   cMjesec2 := gmjesec
   cGodina := gGodina
   cObracun := gObracun
   cRazdvoji := "N"

   O_LD

   // kreiraj tmp tabelu _ld
   _create_ld_tmp()

   my_use( "_ld" )
   INDEX ON idradn + idrj TAG "1"

   my_close_all_dbf()
   O_PAROBR
   O_LD_RJ
   O_RADN
   O_VPOSLA
   O_RADKR
   O_KRED
   O__LD
   SET ORDER TO TAG "1"

   O_LD

   cIdRadn := Space( _LR_ )
   cSatiVO := "S"

   Box(, 6, 77 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve rj): "  GET cIdRJ VALID Empty( cidrj ) .OR. P_LD_RJ( @cidrj )
   @ m_x + 2, m_y + 2 SAY "od mjeseca: "  GET  cmjesec  PICT "99"
   @ m_x + 2, Col() + 2 SAY "do"  GET  cmjesec2  PICT "99"
   @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici):" GET cIdRadn  VALID Empty( cIdRadn ) .OR. P_Radn( @cIdRadn )
   @ m_x + 5, m_y + 2 SAY "Razdvojiti za radnika po RJ:" GET cRazdvoji PICT "@!";
      WHEN Empty ( cIdRj ) VALID cRazdvoji $ "DN"
   READ
   clvbox()
   ESC_BCR
   IF lViseObr .AND. Empty( cObracun )
      @ m_x + 6, m_y + 2 SAY "Prikaz sati (S-sabrati sve obracune , 1-obracun 1 , 2-obracun 2, ... )" GET cSatiVO VALID cSatiVO $ "S123456789" PICT "@!"
      READ
      ESC_BCR
   ENDIF
   BoxC()

   tipprn_use()

   SELECT LD

   IF lViseObr .AND. !Empty( cObracun )
      SET FILTER TO obr = cObracun
   ENDIF

   cIdRadn := Trim( cidradn )
   IF Empty( cidrj )
      SET ORDER TO tag ( TagVO( "4" ) )
      SEEK Str( cGodina, 4 ) + cIdRadn
      cIdrj := ""
   ELSE
      SET ORDER TO tag ( TagVO( "3" ) )
      SEEK Str( cGodina, 4 ) + cidrj + cIdRadn
   ENDIF
   EOF CRET

   nStrana := 0

   IF cRazdvoji == "N"
      bZagl := {|| ;
         QQOut( "OBRACUN" + iif( lViseObr, IF( Empty( cObracun ), " ' '(SVI)", " '" + cObracun + "'" ), "" ) + Lokal( " PLATE ZA PERIOD" ) + Str( cmjesec, 2 ) + "-" + Str( cmjesec2, 2 ) + "/" + Str( godina, 4 ), " ZA " + Upper( Trim( gTS ) ) + " ", gNFirma ), ;
         QOut( "RJ:", idrj, ld_rj->naz ), ;
         QOut( idradn, "-", RADNIK, "Mat.br:", radn->matbr, " STR.SPR:", IDSTRSPR ), ;
         QOut( Lokal( "Broj knjizice:" ), RADN->brknjiz ), ;
         QOut( "Vrsta posla:", idvposla, vposla->naz, Lokal( "        U radnom odnosu od " ), radn->datod );
         }
   ELSE
      bZagl := {|| ;
         QQOut( Lokal( "OBRACUN" ) + iif( lViseObr, iif( Empty( cObracun ), " ' '(SVI)", " '" + cObracun + "'" ), "" ) + Lokal( " PLATE ZA PERIOD" ) + Str( cmjesec, 2 ) + "-" + Str( cmjesec2, 2 ) + "/" + Str( godina, 4 ), " ZA " + Upper( Trim( gTS ) ) + " ", gNFirma ), ;
         QOut( idradn, "-", RADNIK, "Mat.br:", radn->matbr, " STR.SPR:", IDSTRSPR ), ;
         QOut( "Broj knjizice:", RADN->brknjiz ), ;
         QOut( "Vrsta posla:", idvposla, vposla->naz, Lokal( "        U radnom odnosu od " ), radn->datod );
         }
   ENDIF

   SELECT vposla
   hseek ld->idvposla
   SELECT ld_rj
   hseek ld->idrj
   SELECT ld

   IF PCount() == 4
      START PRINT RET
   ELSE
      START PRINT CRET
   ENDIF

   SELECT ld
   nT1 := nT2 := nT3 := nT4 := 0
   DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. idradn = cIdRadn

      xIdRadn := idradn
      IF cRazdvoji == "N"
         Scatter( "w" )
         FOR i := 1 TO cLDPolja
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
            ws&cPom := 0
            wi&cPom := 0
            wUNeto := wUSati := wUIznos := 0
         NEXT
      ENDIF

      IF cRazdvoji == "N"
         SELECT radn; hseek xidradn
         SELECT vposla; hseek ld->idvposla
         SELECT ld_rj; hseek ld->idrj; SELECT ld
         Eval( bZagl )
      ENDIF
      DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. idradn == xIdRadn

         m := "----------------------- --------  ----------------   ------------------"

         SELECT radn; hseek xidradn; SELECT ld

         IF ( mjesec < cmjesec .OR. mjesec > cmjesec2 )
            skip; LOOP
         ENDIF
         Scatter()
         IF cRazdvoji == "D"
            SELECT _LD
            HSEEK xIdRadn + LD->IdRj
            IF ! Found()
               APPEND BLANK
            ENDIF
            Scatter ( "w" )
            FOR i := 1 TO cLDpolja
               cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
               IF !lViseObr .OR. cSatiVO == "S" .OR. cSatiVO == _obr
                  ws&cPom += _s&cPom
               ENDIF
               wi&cPom += _i&cPom
            NEXT
            wUIznos += _UIznos
            IF !lViseObr .OR. cSatiVO == "S" .OR. cSatiVO == _obr
               wUSati += _USati
            ENDIF
            wUNeto += _UNeto
            wIdRj := _IdRj
            wIdRadn := xIdRadn
            Gather( "w" )
            SELECT LD
            SKIP; LOOP
         ENDIF

         cUneto := "D"
         FOR i := 1 TO cLDPolja
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
            SELECT tippr; SEEK cPom
            IF !lViseObr .OR. cSatiVO == "S" .OR. cSatiVO == _obr
               ws&cPom += _s&cPom
            ENDIF
            wi&cPom += _i&cPom
         NEXT
         SELECT ld
         wUIznos += _UIznos
         IF !lViseObr .OR. cSatiVO == "S" .OR. cSatiVO == _obr
            wUSati += _USati
         ENDIF
         wUNeto += _UNeto
         SKIP
      ENDDO

      IF cRazdvoji == "N"
         ? m
         ? Lokal( " Vrsta                  Opis         sati/iznos             ukupno" )
         ? m
         cUneto := "D"
         FOR i := 1 TO cLDPolja
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
            SELECT tippr; SEEK cPom
            IF tippr->uneto == "N" .AND. cUneto == "D"
               cUneto := "N"
               ? m
               ? Lokal( "UKUPNO NETO:" )
               @ PRow(), nC1 + 8  SAY  wUSati  PICT gpics
               ?? Lokal( " sati" )
               @ PRow(), 60 SAY wUNeto PICT gpici; ?? "", gValuta
               ? m
            ENDIF

            IF tippr->( Found() ) .AND. tippr->aktivan == "D"
               IF wi&cpom <> 0 .OR. ws&cPom <> 0
                  ? tippr->id + "-" + tippr->naz, tippr->opis
                  nC1 := PCol()
                  IF tippr->fiksan $ "DN"
                     @ PRow(), PCol() + 8 SAY ws&cPom  PICT gpics; ?? " s"
                     @ PRow(), 60 SAY wi&cPom        PICT gpici
                  ELSEIF tippr->fiksan == "P"
                     @ PRow(), PCol() + 8 SAY ws&cPom  PICT "999.99%"
                     @ PRow(), 60 SAY wi&cPom        PICT gpici
                  ELSEIF tippr->fiksan == "B"
                     @ PRow(), PCol() + 8 SAY ws&cPom  PICT "999999"; ?? " b"
                     @ PRow(), 60 SAY wi&cPom        PICT gpici
                  ELSEIF tippr->fiksan == "C"
                     @ PRow(), 60 SAY wi&cPom        PICT gpici
                  ENDIF
               ENDIF
            ENDIF
         NEXT
         ? m
         ?  Lokal( "UKUPNO ZA ISPLATU" )
         @ PRow(), 60 SAY wUIznos PICT gpici; ?? "", gValuta
         ? m
         IF PRow() > 31
            FF
         ELSE
            ?
            ?
            ?
            ?
         ENDIF
      ELSE
         SELECT _LD
         GO TOP
         SELECT radn; hseek _LD->idradn
         SELECT vposla; hseek _LD->idvposla
         SELECT _LD
         Eval( bZagl )
         ?
         WHILE ! Eof()
            SELECT ld_rj; hseek _ld->idrj; SELECT _ld
            QOut( "RJ:", idrj, ld_rj->naz )
            ? m
            ? Lokal( " Vrsta                  Opis         sati/iznos             ukupno" )
            ? m
            //
            Scatter( "w" )
            cUneto := "D"
            FOR i := 1 TO cLDPolja
               cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
               SELECT tippr; SEEK cPom
               IF tippr->uneto == "N" .AND. cUneto == "D"
                  cUneto := "N"
                  ? m
                  ? Lokal( "UKUPNO NETO:" )
                  @ PRow(), nC1 + 8  SAY  wUSati  PICT gpics; ?? " sati"
                  @ PRow(), 60 SAY wUNeto PICT gpici; ?? "", gValuta
                  ? m
               ENDIF

               IF tippr->( Found() ) .AND. tippr->aktivan == "D"
                  IF wi&cpom <> 0 .OR. ws&cPom <> 0
                     ? tippr->id + "-" + tippr->naz, tippr->opis
                     nC1 := PCol()
                     IF tippr->fiksan $ "DN"
                        @ PRow(), PCol() + 8 SAY ws&cPom  PICT gpics; ?? " s"
                        @ PRow(), 60 SAY wi&cPom        PICT gpici
                     ELSEIF tippr->fiksan == "P"
                        @ PRow(), PCol() + 8 SAY ws&cPom  PICT "999.99%"
                        @ PRow(), 60 SAY wi&cPom        PICT gpici
                     ELSEIF tippr->fiksan == "B"
                        @ PRow(), PCol() + 8 SAY ws&cPom  PICT "999999"; ?? " b"
                        @ PRow(), 60 SAY wi&cPom        PICT gpici
                     ELSEIF tippr->fiksan == "C"
                        @ PRow(), 60 SAY wi&cPom        PICT gpici
                     ENDIF
                  ENDIF
               ENDIF
            NEXT
            ? m
            ?  "UKUPNO ZA ISPLATU U RJ", _LD->IdRj
            @ PRow(), 60 SAY wUIznos PICT gpici
            ?? "", gValuta
            ? m
            IF PRow() > 60 + gPstranica
               FF
            ELSE
               ?
               ?
            ENDIF
            SELECT _LD
            SKIP
         ENDDO
      ENDIF
      SELECT ld

   ENDDO

   FF
   END PRINT
   closeret


   // *******************************
   // rekapitulacija primanja radnika
   // nedovrseno
   // *******************************

FUNCTION RekapRad()

   LOCAL nC1 := 20, i

   cIdRadn := Space( _LR_ )
   cIdRj := gRj
   cMjesec := gMjesec
   cMjesec2 := gmjesec
   cGodina := gGodina
   cObracun := gObracun

   O_PAROBR
   O_LD_RJ
   O_RADN
   O_VPOSLA
   O_RADKR
   O_KRED
   O_LD

   cIdRadn := Space( _LR_ )

   Box(, 4, 75 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno-sve rj): "  GET cIdRJ VALID Empty( cidrj ) .OR. P_LD_RJ( @cidrj )
   @ m_x + 2, m_y + 2 SAY "od mjeseca: "  GET  cmjesec  PICT "99"
   @ m_x + 2, Col() + 2 SAY "do"  GET  cmjesec2  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): "  GET  cIdRadn  VALID Empty( cIdRadn ) .OR. P_Radn( @cIdRadn )
   read; clvbox(); ESC_BCR
   BoxC()

   tipprn_use()

   SELECT LD

   IF lViseObr .AND. !Empty( cObracun )
      SET FILTER TO obr = cObracun
   ENDIF

   cIdRadn := Trim( cidradn )
   IF Empty( cidrj )
      SET ORDER TO tag ( TagVO( "4" ) )
      SEEK Str( cGodina, 4 ) + cIdRadn
      cIdrj := ""
   ELSE
      SET ORDER TO tag ( TagVO( "3" ) )
      SEEK Str( cGodina, 4 ) + cidrj + cIdRadn
   ENDIF
   EOF CRET

   nStrana := 0
   bZagl := {|| ;
      QQOut( Lokal( "PREGLED PRIMANJA ZA PERIOD " ) + Str( cmjesec, 2 ) + "-" + Str( cmjesec2, 2 ) + IspisObr() + "/" + Str( godina, 4 ), " ZA " + Upper( Trim( gTS ) ) + " ", gNFirma ), ;
      QOut( "RJ:", idrj, ld_rj->naz ), ;
      QOut( idradn, "-", RADNIK, "Mat.br:", radn->matbr, " STR.SPR:", IDSTRSPR ), ;
      QOut( "Vrsta posla:", idvposla, vposla->naz, "        U radnom odnosu od ", radn->datod );
      }

   SELECT vposla
   hseek ld->idvposla
   SELECT ld_rj
   hseek ld->idrj
   SELECT ld

   IF PCount() == 4
      START PRINT RET
   ELSE
      START PRINT CRET
   ENDIF

   // ParObr(cmjesec)
   SELECT ld
   nT1 := nT2 := nT3 := nT4 := 0
   DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. idradn = cIdRadn



      Scatter( "w" )
      xIdRadn := idradn
      FOR i := 1 TO cLDPolja
         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         ws&cPom := 0
         wi&cPom := 0
         wUNeto := wUSati := wUIznos := 0
      NEXT

      SELECT radn; hseek xidradn
      SELECT vposla; hseek ld->idvposla
      SELECT ld_rj; hseek ld->idrj; SELECT ld
      Eval( bZagl )

      // nNeto:=0
      // nBruto:=bruto
      // nBolovanje:=0
      ? Lokal( " Mjesec      Sati    NETO          BRUTO         Doprinosi         Stopa               Iznos            " )

      ? Lokal( "                                                                  dopr.PIO         naknade bolovanje     " )

      DO WHILE !Eof() .AND.  cgodina == godina .AND. idrj = cidrj .AND. idradn == xIdRadn

         m := "----------------------- --------  ----------------   ------------------"

         SELECT radn; hseek xidradn; SELECT ld

         // jedan mjesec mjesec
         Scatter()
         cUneto := "D"
         FOR i := 1 TO cLDPolja
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
            SELECT tippr; SEEK cPom
            ws&cPom += _s&cPom
            wi&cPom += _i&cPom
         NEXT
         SELECT ld
         wUIznos += _UIznos
         wUSati += _USati
         wUNeto += _UNeto
         SKIP
         ? Str( mjesec, 2 )
         @ PRow(), PCol() + 1 SAY _USati PICT gpici
         @ PRow(), PCol() + 1 SAY _UNeto  PICT gpici
      ENDDO
      ? "---"
      ? Str( mjesec, 2 )
      @ PRow(), PCol() + 1 SAY  wUSati  PICT gpici
      @ PRow(), PCol() + 1 SAY  wUNeto  PICT gpici
      ?

      SELECT ld

   ENDDO

   FF
   END PRINT

   CLOSERET


   // ------------------------------
   // ------------------------------

FUNCTION SpecifRasp()

   gnLMarg := 0; gTabela := 1; gOstr := "D"

   cIdRj := gRj; cmjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun

   O_LD_RJ
   O_RADN
   O_LD
   PRIVATE cFormula := PadR( "UNETO", 40 )
   PRIVATE cNaziv := PadR( "UKUPNO NETO", 20 )
   cDod := "N"

   nDo1 := 85; nDo2 := 150; nDo3 := 200; nDo4 := 250; nDo5  := 300
   nDo6 := 0 ; nDo7 := 0  ; nDo8 := 0  ; nDo9 := 0  ; nDo10 := 0
   nDo11 := 0 ; nDo12 := 0  ; nDo13 := 0  ; nDo14 := 0  ; nDo15 := 0
   nDo16 := 0 ; nDo17 := 0  ; nDo18 := 0  ; nDo19 := 0  ; nDo20 := 0

   O_PARAMS
   PRIVATE cSection := "4", cHistory := " ", aHistory := {}

   RPar( "p1", @cNaziv )
   RPar( "p2", @cFormula )
   RPar( "p3", @nDo1 )
   RPar( "p4", @nDo2 )
   RPar( "p5", @nDo3 )
   RPar( "p6", @nDo4 )
   RPar( "p7", @nDo5 )
   RPar( "p8", @nDo6 )
   RPar( "p9", @nDo7 )
   RPar( "r0", @nDo8 )
   RPar( "r1", @nDo9 )
   RPar( "r2", @nDo10 )
   RPar( "r3", @nDo11 )
   RPar( "r4", @nDo12 )
   RPar( "r5", @nDo13 )
   RPar( "r6", @nDo14 )
   RPar( "r7", @nDo15 )
   RPar( "r8", @nDo16 )
   RPar( "r9", @nDo17 )
   RPar( "s0", @nDo18 )
   RPar( "s1", @nDo19 )
   RPar( "s2", @nDo20 )

   Box(, 19, 77 )

   @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cmjesec  PICT "99"
   IF lViseObr
      @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"

   @ m_x + 5, m_y + 2 SAY "Naziv raspona primanja: "  GET cNaziv
   @ m_x + 6, m_y + 2 SAY "Formula primanja      : "  GET cFormula PICT "@S20"

   @ m_x + 8, m_y + 2 SAY "             (0 - raspon se ne prikazuje)"
   @ m_x + 9, m_y + 2 SAY " 1. raspon do " GET nDo1 PICT "99999"
   @ m_x + 10, m_y + 2 SAY " 2. raspon do " GET nDo2 PICT "99999"
   @ m_x + 11, m_y + 2 SAY " 3. raspon do " GET nDo3 PICT "99999"
   @ m_x + 12, m_y + 2 SAY " 4. raspon do " GET nDo4 PICT "99999"
   @ m_x + 13, m_y + 2 SAY " 5. raspon do " GET nDo5 PICT "99999"
   @ m_x + 14, m_y + 2 SAY " 6. raspon do " GET nDo6 PICT "99999"
   @ m_x + 15, m_y + 2 SAY " 7. raspon do " GET nDo7 PICT "99999"
   @ m_x + 16, m_y + 2 SAY " 8. raspon do " GET nDo8 PICT "99999"
   @ m_x + 17, m_y + 2 SAY " 9. raspon do " GET nDo9 PICT "99999"
   @ m_x + 18, m_y + 2 SAY "10. raspon do " GET nDo10 PICT "99999"

   @ m_x + 9, m_y + 25 SAY "11. raspon do " GET nDo11 PICT "99999"
   @ m_x + 10, m_y + 25 SAY "12. raspon do " GET nDo12 PICT "99999"
   @ m_x + 11, m_y + 25 SAY "13. raspon do " GET nDo13 PICT "99999"
   @ m_x + 12, m_y + 25 SAY "14. raspon do " GET nDo14 PICT "99999"
   @ m_x + 13, m_y + 25 SAY "15. raspon do " GET nDo15 PICT "99999"
   @ m_x + 14, m_y + 25 SAY "16. raspon do " GET nDo16 PICT "99999"
   @ m_x + 15, m_y + 25 SAY "17. raspon do " GET nDo17 PICT "99999"
   @ m_x + 16, m_y + 25 SAY "18. raspon do " GET nDo18 PICT "99999"
   @ m_x + 17, m_y + 25 SAY "19. raspon do " GET nDo19 PICT "99999"
   @ m_x + 18, m_y + 25 SAY "20. raspon do " GET nDo20 PICT "99999"

   read; clvbox(); ESC_BCR

   BoxC()

   WPar( "p1", cNaziv )
   WPar( "p2", cFormula )
   WPar( "p3", nDo1 )
   WPar( "p4", nDo2 )
   WPar( "p5", nDo3 )
   WPar( "p6", nDo4 )
   WPar( "p7", nDo5 )
   WPar( "p8", nDo6 )
   WPar( "p9", nDo7 )
   WPar( "r0", nDo8 )
   WPar( "r1", nDo9 )
   WPar( "r2", nDo10 )
   WPar( "r3", nDo11 )
   WPar( "r4", nDo12 )
   WPar( "r5", nDo13 )
   WPar( "r6", nDo14 )
   WPar( "r7", nDo15 )
   WPar( "r8", nDo16 )
   WPar( "r9", nDo17 )
   WPar( "s0", nDo18 )
   WPar( "s1", nDo19 )
   WPar( "s2", nDo20 )

   SELECT params; USE

   tipprn_use()

   aRasponi := { nDo1, nDo2, nDo3, nDo4, nDo5, nDo6, nDo7, nDo8, nDo9,;
      nDo10, nDo11, nDo12, nDo13, nDo14, nDo15, nDo16, nDo17,;
      nDo18, nDo19, nDo20 }

   ASort( aRasponi )

   nLast := 0
   // nKol:=0
   nRed := 0

   // aKol:={ { "" , {|| "BR.RADNIKA"  }, .f., "C", 10, 0, 1, ++nKol } }
   aKol := {}

   aUslRasp := {}
   nSumRasp := {}

   FOR i := 1 TO Len( aRasponi )
      IF aRasponi[ i ] > 0
         ++nRed
         // ++nKol

         AAdd( nSumRasp, 0 )

         // cPomM:="nSumRasp["+ALLTRIM(STR(nKol-1))+"]"
         // AADD( aKol , { ALLTRIM(cNaziv) , {|| STR(&cPomM.,11)  }, .f., "C", 20, 0, 1, nKol } )
         // AADD( aKol , { "OD "+STR(nLast,5)+" DO "+STR(aRasponi[i],5) , {|| "#"  }, .f., "C", 20, 0, 2, nKol } )
         cPomM := "nSumRasp[" + AllTrim( Str( nRed ) ) + "]"

         cPom77 := "{|| 'OD " + Str( nLast, 5 ) + " DO " + Str( aRasponi[ i ], 5 ) + "' }"
         IF nRed == 1
            AAdd( aKol, { AllTrim( cNaziv ), &cPom77., .F., "C", 40, 0, nRed, 1 } )
            AAdd( aKol, { "BROJ RADNIKA", {|| &cPomM.   }, .F., "N", 12, 0, nRed, 2 } )
         ELSE
            AAdd( aKol, { "", &cPom77., .F., "C", 40, 0, nRed, 1 } )
            AAdd( aKol, { "", {|| &cPomM.   }, .F., "N", 12, 0, nRed, 2 } )
         ENDIF

         AAdd( aUslRasp, { nLast, aRasponi[ i ] } )
         nLast := aRasponi[ i ]
      ENDIF
   NEXT

   IF Len( aKol ) < 2; CLOSERET; ENDIF
   ASort( aKol,,, {| x, y| 100 * x[ 8 ] + x[ 7 ] < 100 * y[ 8 ] + y[ 7 ] } )

   SELECT LD

   SET ORDER TO TAG ( TagVO( "1" ) )

   PRIVATE cFilt1 := ""
   cFilt1 := "GODINA==" + cm2str( cGodina ) + ".and.MJESEC==" + cm2str( cMjesec ) + ;
      IF( Empty( cIdRJ ), "", ".and.IDRJ==" + cm2str( cIdRJ ) )
   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF lViseObr .AND. !Empty( cObracun )
      cFilt1 += ( ".and. OBR==" + cm2str( cObracun ) )
   ENDIF

   IF cFilt1 == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilt1
   ENDIF

   GO TOP

   START PRINT CRET

   PRIVATE cIdPartner := "", cNPartnera := "", nUkRoba := 0, nUkIznos := 0

   ?? Space( gnLMarg )
   ?? Lokal( "LD: Izvjestaj na dan" ), Date()
   ? Space( gnLMarg ); IspisFirme( "" )
   ? Space( gnLMarg )
   IF Empty( cidrj )
      ?? Lokal( "Pregled za sve RJ ukupno:" )
   ELSE
      ?? "RJ:", cidrj + " - " + Ocitaj( F_LD_RJ, cIdRj, "naz" )
   ENDIF
   ?? "  Mjesec:", Str( cmjesec, 2 ) + IspisObr()
   ?? "    Godina:", Str( cGodina, 5 )

   StampaTabele( aKol, {|| FSvaki2() },, gTabela,, ;
      , "Specifikacija po rasponima primanja", ;
      {|| FFor2() }, IF( gOstr == "D",, -1 ),,,,, )

   FF
   END PRINT

   CLOSERET

STATIC FUNCTION FFor2()

   DO WHILE !Eof()
      nPrim := &( cFormula )
      FOR i := 1 TO Len( aUslRasp )
         // ? aUslRasp[i,1], nPrim, aUslRasp[i,2]
         IF nPrim > aUslRasp[ i, 1 ] .AND. nPrim <= aUslRasp[ i, 2 ]
            ++nSumRasp[i ]
         ENDIF
      NEXT
      // ?
      SKIP 1
   ENDDO
   SKIP -1

   RETURN .T.


STATIC FUNCTION FSvaki2()
   RETURN


// ---------------------------------
// ---------------------------------
FUNCTION SortPrez( cId )

   LOCAL cVrati := ""
   LOCAL nArr := Select()

   SELECT F_RADN
   IF !Used()
      O_RADN
   ENDIF

   HSEEK cId
   cVrati := naz + ime + imerod + id

   SELECT ( nArr )

   RETURN cVrati


// ---------------------------------
// ---------------------------------
FUNCTION SortIme( cId )

   LOCAL cVrati := ""
   LOCAL nArr := Select()

   SELECT( F_RADN )
   IF !Used()
      reopen_exclusive( "ld_radn" )
   ENDIF
   SET ORDER TO TAG "1"

   HSEEK cId

   cVrati := ime + naz + imerod + id

   SELECT ( nArr )

   RETURN cVrati


// --------------------------------
// --------------------------------
FUNCTION SortVar( cId )

   LOCAL cVrati := ""
   LOCAL nArr := Select()

   O_RADKR
   SEEK cId
   SELECT RJES
   SEEK RADKR->naosnovu + RADKR->idradn
   cVrati := varijanta
   SELECT ( nArr )

   RETURN cVrati



FUNCTION NLjudi()
   RETURN "(" + AllTrim( Str( opsld->ljudi ) ) + ")"


FUNCTION ImaUOp( cPD, cSif )

   LOCAL lVrati := .T.

   IF ops->( FieldPos( "DNE" ) ) <> 0
      IF Upper( cPD ) = "P"
         // porez
         lVrati := ! ( cSif $ OPS->pne )
      ELSE
         // doprinos
         lVrati := ! ( cSif $ OPS->dne )
      ENDIF
   ENDIF

   RETURN lVrati


// ---------------------------
// ---------------------------
FUNCTION PozicOps( cSR )

   LOCAL nArr := Select()
   LOCAL cO := ""

   IF cSR == "1"
      // opstina stanovanja
      cO := radn->idopsst
   ELSEIF cSR == "2"
      // opstina rada
      cO := radn->idopsrad
   ELSE
      // " "
      cO := Chr( 255 )
   ENDIF

   SELECT ( F_OPS )

   IF !Used()
      O_OPS
   ENDIF

   SEEK cO

   SELECT ( nArr )

   RETURN

// ----------------------------------------
// ----------------------------------------
FUNCTION ScatterS( cG, cM, cJ, cR, cPrefix )

   PRIVATE cP7 := cPrefix

   IF cPrefix == NIL
      Scatter()
   ELSE
      Scatter( cPrefix )
   ENDIF
   SKIP 1
   DO WHILE !Eof() .AND. mjesec = cM .AND. godina = cG .AND. idradn = cR .AND. ;
         idrj = cJ
      IF cPrefix == NIL
         FOR i := 1 TO cLDPolja
            cPom    := PadL( AllTrim( Str( i ) ), 2, "0" )
            _i&cPom += i&cPom
         NEXT
         _uneto   += uneto
         _uodbici += uodbici
         _uiznos  += uiznos
      ELSE
         FOR i := 1 TO cLDPolja
            cPom    := PadL( AllTrim( Str( i ) ), 2, "0" )
            &cP7.i&cPom += i&cPom
         NEXT
         &cP7.uneto   += uneto
         &cP7.uodbici += uodbici
         &cP7.uiznos  += uiznos
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   RETURN

// -------------------------------------
// -------------------------------------
FUNCTION IspisObr()

   LOCAL cVrati := ""

   IF lViseObr .AND. !Empty( cObracun )
      cVrati := "/" + cObracun
   ENDIF

   RETURN cVrati


FUNCTION Obr2_9()
   RETURN lViseObr .AND. !Empty( cObracun ) .AND. cObracun <> "1"




FUNCTION SvratiUFajl()

   FErase( PRIVPATH + "xoutf.txt" )
   SET PRINTER TO ( PRIVPATH + "xoutf.txt" )

   RETURN


FUNCTION U2Kolone( nViska )

   LOCAL cImeF, nURed

   IF "U" $ Type( "cLMSK" ); cLMSK := ""; ENDIF
   nSirKol := 80 + Len( cLMSK )
   cImeF := PRIVPATH + "xoutf.txt"
   nURed := BrLinFajla( cImeF )
   aR    := DioFajlaUNiz( cImeF, 1, nURed - nViska, nURed )
   aRPom := DioFajlaUNiz( cImeF, nURed - nViska + 1, nViska, nURed )
   aR[ 1 ] = PadR( aR[ 1 ], nSirKol ) + aR[ 1 ]
   aR[ 2 ] = PadR( aR[ 2 ], nSirKol ) + aR[ 2 ]
   aR[ 3 ] = PadR( aR[ 3 ], nSirKol ) + aR[ 3 ]
   aR[ 4 ] = PadR( aR[ 4 ], nSirKol ) + aR[ 4 ]
   FOR i := 1 TO Len( aRPom )
      aR[ i + 4 ] = PadR( aR[ i + 4 ], nSirKol ) + aRPom[ i ]
   NEXT

   RETURN aR


FUNCTION SetRadnGodObr()
   RETURN

STATIC FUNCTION DioFajlaUNiz( cImeF, nPocRed, nUkRedova, nUkRedUF )

   LOCAL aVrati := {}, nTekRed := 0, nOfset := 0, aPom := {}

   IF nUkRedUF == nil; nUkRedUF := BrLinFajla( cImeF ); ENDIF
   FOR nTekRed := 1 TO nUkRedUF
      aPom := SljedLin( cImeF, nOfset )
      IF nTekRed >= nPocRed .AND. nTekRed < nPocRed + nUkRedova
         AAdd( aVrati, aPom[ 1 ] )
      ENDIF
      IF nTekRed >= nPocRed + nUkRedova - 1
         EXIT
      ENDIF
      nOfset := aPom[ 2 ]
   NEXT

   RETURN aVrati
