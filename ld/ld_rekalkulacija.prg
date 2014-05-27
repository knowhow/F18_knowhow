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


FUNCTION ld_rekalkulacija()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   IF GetObrStatus( gRj, gGodina, gMjesec ) $ "ZX"
      MsgBeep( "Obracun zakljucen! Ne mozete vrsiti ispravku podataka!!!" )
      RETURN
   ELSEIF GetObrStatus( gRj, gGodina, gMjesec ) == "N"
      MsgBeep( "Nema otvorenog obracuna za " + AllTrim( Str( gMjesec ) ) + "." + AllTrim( Str( gGodina ) ) )
      RETURN
   ENDIF

   AAdd( _opc, "1. rekalkulacija satnica i primanja               " )
   AAdd( _opcexe, {|| RekalkPrimanja() } )
   AAdd( _opc, "2. ponovo izracunaj neto sati/neto iznos/odbici" )
   AAdd( _opcexe, {|| RekalkSve() } )
   AAdd( _opc, "3. rekalkulacija odredjenog primanja za procenat" )
   AAdd( _opcexe, {|| RekalkProcenat() } )
   AAdd( _opc, "4. rekalkulacija odredjenog primanja po formuli" )
   AAdd( _opcexe, {|| RekalkFormula() } )

   f18_menu( "rklk", .F., _izbor, _opc, _opcexe )

   RETURN


FUNCTION RekalkPrimanja()

   LOCAL i
   LOCAL nArrm
   LOCAL nLjudi

   IF Logirati( goModul:oDataBase:cName, "DOK", "REKALKPRIMANJA" )
      lLogRekPrimanja := .T.
   ELSE
      lLogRekPrimanja := .F.
   ENDIF

   Box(, 4, 60 )
   @ m_x + 1, m_y + 2 SAY "Ova opcija vrsi preracunavanja onih stavki  primanja koja"
   @ m_x + 2, m_y + 2 SAY "u svojoj formuli proracuna sadrze paramtre obracuna."
   @ m_x + 4, m_y + 2 SAY "               <ESC> Izlaz"
   Inkey( 0 )
   BoxC()

   IF ( LastKey() == K_ESC )
      closeret
      RETURN
   ENDIF

   cIdRj := gRj
   cMjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun

   O_LD_RJ
   O_POR
   O_DOPR
   O_RADN
   O_PAROBR
   O_LD

   cIdRadn := Space( _LR_ )
   cStrSpr := Space( 3 )

   nDimenzija := 0

   IF lViseObr
      nDimenzija := 1
   ELSE
      nDimenzija := 0
   ENDIF

   Box(, 3 + nDimenzija, 50 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica: "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cMjesec  PICT "99"
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   IF lViseObr
      @ m_x + 4, m_y + 2 SAY "Obracun:"  GET  cObracun WHEN HelpObr( .F., cObracun ) VALID ValObr( .F., cObracun )
   ENDIF
   READ
   ClvBox()
   ESC_BCR
   BoxC()

   tipprn_use()

   SELECT ld
   SEEK Str( cGodina, 4 ) + cIdRj + Str( cMjesec, 2 ) + BrojObracuna()

   EOF CRET

   PRIVATE cPom := ""
   PRIVATE lRekalk := .T.

   nLjudi := 0

   Box(, 1, 12 )
   DO WHILE !Eof() .AND. cGodina == godina .AND. cIdRj == idrj .AND. cMjesec = mjesec .AND. if( lViseObr, cObracun == obr, .T. )

      set_global_memvars_from_dbf()

      ParObr( _mjesec, _godina, IF( lViseObr, _obr, ), cIdRj )  // podesi parametre obra~una za ovaj mjesec

      SELECT radn
      hseek _idradn
      SELECT ld

      FOR i := 1 TO cLDPolja
         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         SELECT tippr; SEEK cPom; SELECT ld
         IF tippr->( Found() ) .AND. tippr->aktivan == "D" .AND. "PAROBR" $ Upper( tippr->formula )

            _UIznos := _UIznos - _i&cPom
            IF tippr->uneto == "D"           // izbij ovu stavku
               _Uneto := _UNeto - _i&cPom      // ..
            ELSE                           // ..
               _UOdbici := _UOdbici - _i&cPom  // .
            ENDIF                          // ..

            Izracunaj( @_i&cPom )            // preracunaj ovu stavku

            // cPom je privatna, varijabla koja je Ÿesto koriçtena i to gotovo
            // uvijek kao privatna varijabla. Jednostavno, sada †u rijeçiti problem
            // ponovnim dodjeljivanjem vrijednosti, a za ovaj problem inaŸe smatram
            // da bi trebalo uvesti konvenciju davanja naziva ovakvim varijablama
            // --------------------------------------------------------------------
            cPom := PadL( AllTrim( Str( i ) ), 2, "0" ) // MS 23.03.01.

            _UIznos += _i&cPom               // dodaj je nakon preracuna
            IF tippr->uneto == "D"           //
               _Uneto += _i&cPom             //
            ELSE                           //
               _UOdbici += _i&cPom           //
            ENDIF

         ENDIF

      NEXT

      // test verzija
      _usati := 0
      FOR i := 1 TO cLDPolja
         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         SELECT tippr; SEEK cPom
         IF tippr->( Found() ) .AND. tippr->aktivan == "D"
            IF tippr->ufs == "D"
               _USati += _s&cPom
            ENDIF
         ENDIF
      NEXT

      // ako je nova varijanta obraèuna i ovo treba uvrstiti...
      IF gVarObracun == "2"

         nKLO := radn->klo
         cTipRada := g_tip_rada( _idradn, _idrj )
         nSPr_koef := 0
         nTrosk := 0
         nBrOsn := 0
         cOpor := " "
         cTrosk := " "

         // koristi troskove ?
         IF radn->( FieldPos( "trosk" ) ) <> 0
            cTrosk := radn->trosk
         ENDIF

         // samostalni djelatnik
         IF cTipRada == "S"
            IF radn->( FieldPos( "SP_KOEF" ) ) <> 0
               nSPr_koef := radn->sp_koef
            ENDIF
         ENDIF

         // ako su ovi tipovi primanja - nema odbitka !
         IF cTipRada $ "A#U#P#S"
            _ULicOdb := 0
         ENDIF

         // bruto osnova
         _UBruto := bruto_osn( _UNeto, cTipRada, _ULicOdb, nSPr_koef, cTrosk )

         // ugovor o djelu
         IF cTipRada == "U" .AND. cTrosk <> "N"
            nTrosk := ROUND2( _UBruto * ( gUgTrosk / 100 ), gZaok2 )
            IF lInRS == .T.
               nTrosk := 0
            ENDIF
            _UBruto := _UBruto - nTrosk
         ENDIF

         // autorski honorar
         IF cTipRada == "A" .AND. cTrosk <> "N"
            nTrosk := ROUND2( _UBruto * ( gAhTrosk / 100 ), gZaok2 )
            IF lInRS == .T.
               nTrosk := 0
            ENDIF
            _UBruto := _UBruto - nTrosk
         ENDIF

         nMinBO := _UBruto
         IF cTipRada $ " #I#N"
            IF _I01 = 0
               // ne racunaj bruto osnovu
            ELSE
               nMinBO := min_bruto( _Ubruto, _Usati )
            ENDIF
         ENDIF

         // uiznos je sada sa uracunatim brutom i ostalim

         // ukupno doprinosi IZ place
         nUDoprIZ := u_dopr_iz( nMinBO, cTipRada )
         _UDopr := nUDoprIZ
         _UDop_St := 31.0

         // poreska osnovica
         nPorOsnovica := ( ( _UBruto - _Udopr ) - _ulicodb )

         IF nPorOsnovica < 0 .OR. !radn_oporeziv( _idradn, _idrj )
            nPorOsnovica := 0
         ENDIF

         // porez
         _UPorez := izr_porez( nPorOsnovica, "B" )
         _UPor_st := 10.0

         // nema poreza
         IF !radn_oporeziv( _idradn, _idrj )
            _uporez := 0
            _upor_st := 0
         ENDIF

         // neto plata
         _uneto2 := ROUND2( ( _ubruto - _udopr ) - _uporez, gZaok2 )

         IF cTipRada $ " #I#N"
            _uneto2 := min_neto( _uneto2, _usati )
         ENDIF

         _uiznos := ROUND2( _uneto2 + _UOdbici, gZaok2 )

         IF cTipRada $ "U#A" .AND. cTrosk <> "N"
            // kod ovih vrsta dodaj i troskove
            _uIznos := ROUND2( _uiznos + nTrosk, gZaok2 )
         ENDIF

         IF cTipRada $ "S"
            // neto je za isplatu
            _uIznos := _UNeto
         ENDIF

      ENDIF

      SELECT ld

      // obracun snimiti u sql bazu
      _vals := get_dbf_global_memvars()
      update_rec_server_and_dbf( "ld_ld", _vals, 1, "FULL" )

      @ m_x + 1, m_y + 2 SAY ++nLjudi PICT "99999"

      SKIP

   ENDDO

   IF lLogRekPrimanja
      EventLog( nUser, goModul:oDataBase:cName, "DOK", "REKALKPRIMANJA", nljudi, nil, nil, nil, cIdRj, Str( cMjesec, 2 ), Str( cGodina, 4 ), Date(), Date(), "", "Rekalkulacija satnica i primanja" )
   ENDIF

   Beep( 1 )
   Inkey( 1 )
   BoxC()
   lRekalk := .F.
   closeret

   RETURN



FUNCTION RekalkProcenat()

   LOCAL i, nArrm, nLjudi

   IF Logirati( goModul:oDataBase:cName, "DOK", "REKALKPROCENAT" )
      lLogRekProcenat := .T.
   ELSE
      lLogRekProcenat := .F.
   ENDIF

   Box(, 4, 60 )
   @ m_x + 1, m_y + 2 SAY "Ova opcija vrsi preracunavanje iznosa odredjenog primanja"
   @ m_x + 4, m_y + 2 SAY "               <ESC> Izlaz"
   Inkey( 0 )
   BoxC()

   IF LastKey() == K_ESC
      closeret
      RETURN
   ENDIF

   cIdRj    := gRj
   cMjesec  := gMjesec
   cGodina  := gGodina
   cObracun := gObracun

   O_RADN
   O_PAROBR
   O_TIPPR
   O_TIPPR2
   O_LD

   cIdRadn := Space( _LR_ )
   cStrSpr := Space( 3 )
   nProcPrim := 0
   cTipPP := "  "
   cDN := "N"
   Box(, 7, 50 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica: "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cMjesec  PICT "99"
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   IF lViseObr
      @ m_x + 4, m_y + 2 SAY "Obracun:"  GET  cObracun WHEN HelpObr( .F., cObracun ) VALID ValObr( .F., cObracun )
   ENDIF
   @ m_x + 5, m_y + 2 SAY "Sifra tipa primanja " GET  cTipPP VALID if( lViseObr .AND. cObracun <> "1", P_Tippr2( @cTipPP ), P_Tippr( @cTipPP ) ) .AND. !Empty( cTipPP )
   @ m_x + 6, m_y + 2 SAY "Procenat za koji se vrsi promjena " GET  nProcPrim PICT "999999.999"
   @ m_x + 7, m_y + 2 SAY "Sigurno zelite nastaviti   (D/N) ?" GET  cDN PICT "@!" VALID cDN $ "DN"
   read; clvbox(); ESC_BCR
   BoxC()

   IF cDN == "N"
      RETURN
   ENDIF

   tipprn_use()

   SELECT LD

   SEEK Str( cGodina, 4 ) + cidrj + Str( cMjesec, 2 ) + IF( lViseObr, cObracun, "" )
   EOF CRET

   PRIVATE cpom := ""
   nLjudi := 0
   Box(, 1, 12 )

   nStariIznos := nNoviIznos := 0

   DO WHILE !Eof() .AND.  cgodina == godina .AND. cidrj == idrj .AND. ;
         cmjesec = mjesec .AND. IF( lViseObr, cObracun == obr, .T. )


      set_global_vars_from_dbf()

      ParObr( _mjesec, _godina, IF( lViseObr, _obr, ), cIdRj )  // podesi parametre obra~una za ovaj mjesec

      SELECT radn; hseek _idradn
      SELECT ld

      FOR i := 1 TO cLDPolja
         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         IF cPom == cTipPP .AND. _i&cPom <> 0  // to je to primanje
            SELECT tippr; SEEK cPom; SELECT ld

            nStariIznos := _i&cPom

            _UIznos := _UIznos - nStariIznos
            IF tippr->uneto == "D"                    // izbij ovu stavku
               _Uneto := _UNeto - nStariIznos           // ..
            ELSE                                    // ..
               _UOdbici := _UOdbici - nStariIznos       // .
            ENDIF                                   // ..

            nNoviIznos := _i&cPom := Round( nStariIznos * ( 1 + nProcPrim / 100 ), gZaok )

            IF tippr->fiksan == "P"
               // preraŸunaj i procenat
               _s&cPom :=  Round( _s&cPom * nNoviIznos / nStariIznos, 2 )
               IF _s&cPom = 0
                  MsgBeep( "Istopio se postotak kod radnika:'" + _idradn + "' !" )
               ENDIF
               // ponovo izracunaj iznos radi zaokru§enja
               Izracunaj( @_i&cPom )

               cPom := PadL( AllTrim( Str( i ) ), 2, "0" )  // MS 23.03.01.

               nNoviIznos := _i&cPom
            ENDIF

            _UIznos += nNoviIznos            // dodaj je nakon preracuna
            IF tippr->uneto == "D"           //
               _Uneto += nNoviIznos          //
            ELSE                           //
               _UOdbici += nNoviIznos        //
            ENDIF

         ENDIF

      NEXT

      // test verzija
      _usati := 0
      FOR i := 1 TO cLDPolja
         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         SELECT tippr; SEEK cPom
         IF tippr->( Found() ) .AND. tippr->aktivan == "D"
            IF tippr->ufs == "D"
               _USati += _s&cPom
            ENDIF
         ENDIF
      NEXT
      SELECT ld

      // obracun snimiti u sql bazu
      _vals := get_dbf_global_memvars()
      update_rec_server_and_dbf( "ld_ld", _vals, 1, "FULL" )

      @ m_x + 1, m_y + 2 SAY ++nljudi PICT "99999"
      SKIP
   ENDDO

   IF lLogRekProcenat
      EventLog( nUser, goModul:oDataBase:cName, "DOK", "REKALKPROCENAT", nljudi, nil, nil, nil, cIdRj, Str( cMjesec, 2 ), Str( cGodina, 4 ), Date(), Date(), "", "Rekalkulacija primanja po zadatom procentu" )
   ENDIF


   Beep( 1 ); Inkey( 1 )
   BoxC()
   closeret

   RETURN




FUNCTION RekalkFormula()

   LOCAL i, nArrm, nLjudi

   IF Logirati( goModul:oDataBase:cName, "DOK", "REKALKFORMULA" )
      lLogRekFormula := .T.
   ELSE
      lLogRekFormula := .F.
   ENDIF


   Box(, 4, 60 )
   @ m_x + 1, m_y + 2 SAY "Ova opcija vrsi preracunavanje odredjenog primanja"
   @ m_x + 4, m_y + 2 SAY "               <ESC> Izlaz"
   Inkey( 0 )
   BoxC()
   IF LastKey() == K_ESC
      closeret
      RETURN
   ENDIF

   cIdRj    := gRj
   cMjesec  := gMjesec
   cGodina  := gGodina
   cObracun := gObracun

   O_RADN
   O_PAROBR
   O_TIPPR
   O_TIPPR2
   O_LD

   cIdRadn := Space( _LR_ )
   cStrSpr := Space( 3 )
   nProcPrim := 0
   cTipPP := "  "
   cDN := "N"
   Box(, 7, 50 )
   @ m_x + 1, m_y + 2 SAY "Radna jedinica: "  GET cIdRJ
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cMjesec  PICT "99"
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   IF lViseObr
      @ m_x + 4, m_y + 2 SAY "Obracun:"  GET  cObracun WHEN HelpObr( .F., cObracun ) VALID ValObr( .F., cObracun )
   ENDIF
   @ m_x + 5, m_y + 2 SAY "Sifra tipa primanja " GET  cTipPP VALID if( lViseObr .AND. cObracun <> "1", P_Tippr2( @cTipPP ), P_Tippr( @cTipPP ) ) .AND. !Empty( cTipPP )
   @ m_x + 7, m_y + 2 SAY "Sigurno zelite nastaviti   (D/N) ?" GET  cDN PICT "@!" VALID cDN $ "DN"
   read; clvbox(); ESC_BCR
   BoxC()

   IF cDN == "N"
      RETURN
   ENDIF

   tipprn_use()

   SELECT LD

   SEEK Str( cGodina, 4 ) + cidrj + Str( cMjesec, 2 ) + IF( lViseObr, cObracun, "" )
   EOF CRET

   PRIVATE cpom := ""
   nLjudi := 0
   Box(, 1, 12 )
   DO WHILE !Eof() .AND.  cgodina == godina .AND. cidrj == idrj .AND. ;
         cmjesec = mjesec .AND. IF( lViseObr, cObracun == obr, .T. )

      set_global_vars_from_dbf()

      ParObr( _mjesec, _godina, IF( lViseObr, _obr, ), cIdRj )  // podesi parametre obra~una za ovaj mjesec

      SELECT radn; hseek _idradn
      SELECT ld

      FOR i := 1 TO cLDPolja
         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         IF cPom == cTipPP  // to je to primanje
            SELECT tippr; SEEK cPom; SELECT ld
            _UIznos := _UIznos - _i&cPom
            IF tippr->uneto == "D"           // izbij ovu stavku
               _Uneto := _UNeto - _i&cPom      // ..
            ELSE                           // ..
               _UOdbici := _UOdbici - _i&cPom  // .
            ENDIF                          // ..


            // _i&cPom:=round(_i&cPom*(1+nProcPrim/100),gZaok)
            Izracunaj( @_i&cPom )

            cPom := PadL( AllTrim( Str( i ) ), 2, "0" )  // MS 23.03.01.

            // /*******Izracunaj(@_i&cPom)            //  preracunaj ovu stavku


            _UIznos += _i&cPom               // dodaj je nakon preracuna
            IF tippr->uneto == "D"           //
               _Uneto += _i&cPom             //
            ELSE                           //
               _UOdbici += _i&cPom           //
            ENDIF

         ENDIF

      NEXT

      // test verzija
      _usati := 0
      FOR i := 1 TO cLDPolja
         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         SELECT tippr; SEEK cPom
         IF tippr->( Found() ) .AND. tippr->aktivan == "D"
            IF tippr->ufs == "D"
               _USati += _s&cPom
            ENDIF
         ENDIF
      NEXT
      SELECT ld

      // obracun snimiti u sql bazu
      _vals := get_dbf_global_memvars()

      // hernad: zadnji do koje sam stigao
      update_rec_server_and_dbf( "ld_ld", _vals, 1, "FULL" )

      @ m_x + 1, m_y + 2 SAY ++nljudi PICT "99999"
      SKIP
   ENDDO

   IF lLogRekFormula
      EventLog( nUser, goModul:oDataBase:cName, "DOK", "REKALKFORMULA", nljudi, nil, nil, nil, cIdRj, Str( cMjesec, 2 ), Str( cGodina, 4 ), Date(), Date(), "", "Rekalkulacija primanja po zadatoj formuli" )
   ENDIF


   Beep( 1 )
   Inkey( 1 )
   BoxC()

   closeret

   RETURN




FUNCTION RekalkSve()

   LOCAL i, nArrm, nLjudi

   IF Logirati( goModul:oDataBase:cName, "DOK", "REKALKSVE" )
      lLogRekSve := .T.
   ELSE
      lLogRekSve := .F.
   ENDIF


   Box(, 4, 60 )
   @ m_x + 1, m_y + 2 SAY "Ova opcija vrsi preracunavanja:                        "
   @ m_x + 2, m_y + 2 SAY "NETO SATI, NETO IZNOS, UKUPNO ZA ISPLATU, UKUPNO ODBICI"
   @ m_x + 4, m_y + 2 SAY "               <ESC> Izlaz"
   Inkey( 0 )
   BoxC()
   IF LastKey() == K_ESC
      closeret
      RETURN
   ENDIF

   cMjesec  := gMjesec
   cGodina  := gGodina
   cObracun := gObracun

   O_RADN
   O_PAROBR
   O_LD

   cIdRadn := Space( _LR_ )
   cStrSpr := Space( 3 )

   Box(, 3 + IF( lViseObr, 1, 0 ), 50 )
   @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET  cMjesec  PICT "99"
   @ m_x + 3, m_y + 2 SAY "Godina: "  GET  cGodina  PICT "9999"
   IF lViseObr
      @ m_x + 4, m_y + 2 SAY "Obracun:"  GET  cObracun WHEN HelpObr( .F., cObracun ) VALID ValObr( .F., cObracun )
   ENDIF
   read; clvbox(); ESC_BCR
   BoxC()

   tipprn_use()

   SELECT LD
   SET ORDER TO TAG "2"
   SEEK Str( cGodina, 4 ) + Str( cMjesec, 2 ) + IF( lViseObr, cObracun, "" )

   EOF CRET

   PRIVATE cpom := ""
   nLjudi := 0
   Box(, 1, 12 )
   DO WHILE !Eof() .AND.  cGodina == godina .AND.  cmjesec = mjesec .AND. ;
         IF( lViseObr, cObracun == obr, .T. )

      set_global_vars_from_dbf()

      ParObr( _mjesec, _godina, IF( lViseObr, _obr, ), _idrj )  // podesi parametre obra~una za ovaj mjesec

      SELECT radn; hseek _idradn
      SELECT ld


      _USati := 0
      _UNeto := 0
      _UOdbici := 0

      // filuje _USati,_UNeto,_UOdbici
      UkRadnik()
      _UIznos := _UNeto + _UOdbici

      _vals := get_dbf_global_memvars()
      update_rec_server_and_dbf( "ld_ld", _vals, 1, "FULL" )

      @ m_x + 1, m_y + 2 SAY ++nljudi PICT "99999"
      SKIP
   ENDDO

   IF lLogRekSve
      EventLog( nUser, goModul:oDataBase:cName, "DOK", "REKALKSVE", nljudi, nil, nil, nil, nil, Str( cMjesec, 2 ), Str( cGodina, 4 ), Date(), Date(), "", "Rekalkulacija neto sati neto primanja" )
   ENDIF


   Beep( 1 )
   Inkey( 1 )
   BoxC()

   closeret

   RETURN
