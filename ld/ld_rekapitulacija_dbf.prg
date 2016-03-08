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

STATIC __var_obr


FUNCTION ld_rekapitulacija( lSvi )

   LOCAL _a_benef := {}
   PRIVATE nC1 := 20
   PRIVATE i
   PRIVATE cTPNaz
   PRIVATE cUmPD := "N"
   PRIVATE nKrug := 1
   PRIVATE nUPorOl := 0
   PRIVATE cFilt1 := ""
   PRIVATE cNaslovRekap := Lokal( "LD: Rekapitulacija primanja" )
   PRIVATE aUsl1, aUsl2
   PRIVATE aNetoMj
   PRIVATE cDoprSpace := ""
   PRIVATE cLmSk := ""

   cTpLine := _gtprline()
   cDoprLine := _gdoprline( cDoprSpace )
   cMainLine := _gmainline()
   cMainLine := Replicate( "-", 2 ) + cMainLine

   lPorNaRekap := my_get_from_ini( "LD", "PoreziNaRekapitulaciji", "N", KUMPATH ) == "D"

   cIdRadn := Space( _LR_ )
   cIdRj := gRj
   cMjesec := gMjesec
   cGodina := gGodina
   cObracun := gObracun
   cMjesecDo := cMjesec
   nStrana := 0
   aUkTr := {}
   nBO := 0
   cRTipRada := " "
   nKoefLO := 0

   IF lSvi == NIL
      lSvi := .F.
   ENDIF

   ORekap()

   cIdRadn := Space( 6 )
   cStrSpr := Space( 3 )
   cOpsSt := Space( 4 )
   cOpsRad := Space( 4 )
   cK4 := "S"

   IF lSvi
      qqRJ := Space( 60 )
      BoxRekSvi()
      IF ( LastKey() == K_ESC )
         RETURN
      ENDIF
   ELSE
      qqRJ := Space( 2 )
      BoxRekJ()
      IF ( LastKey() == K_ESC )
         RETURN
      ENDIF
   ENDIF

   SELECT ld

   cObracun := Trim( cObracun )

   IF lSvi
      SET ORDER TO tag ( TagVO( "2" ) )
   ELSE
      SET ORDER TO tag ( TagVO( "1" ) )
   ENDIF

   IF lSvi

      cFilt1 := ".t." + ;
         IF( Empty( cStrSpr ), "", ".and.IDSTRSPR == " + dbf_quote( cStrSpr ) ) + ;
         IF( Empty( qqRJ ), "", ".and." + aUsl1 )

      IF cMjesec != cMjesecDo
         cFilt1 := cFilt1 + ".and. mjesec >= " + dbf_quote( cMjesec ) + ;
            ".and. mjesec <= " + dbf_quote( cMjesecDo ) + ".and. godina = " + dbf_quote( cGodina )
      ENDIF

      GO TOP

   ELSE

      cFilt1 := ".t." + ;
         IF( Empty( cStrSpr ), "", ".and. IDSTRSPR == " + dbf_quote( cStrSpr ) )
      IF cMjesec != cMjesecDo
         cFilt1 := cFilt1 + ".and. mjesec >= " + dbf_quote( cMjesec ) + ;
            ".and. mjesec <= " + dbf_quote( cMjesecDo ) + ".and. godina = " + dbf_quote( cGodina )
      ENDIF

   ENDIF

   cFilt1 += ".and. obr = " + dbf_quote( cObracun )
   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF cFilt1 == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilt1
   ENDIF

   IF !lSvi
      SEEK Str( cGodina, 4 ) + cIdRj + Str( cMjesec, 2 ) + cObracun
      EOF CRET
   ELSE
      SEEK Str( cGodina, 4 ) + Str( cMjesec, 2 ) + cObracun
      EOF CRET
   ENDIF

   PoDoIzSez( cGodina, cMjesecDo )

   CreOpsLD()
   CreRekLD()

   O_REKLD
   O_OPSLD

   SELECT ld

   START PRINT CRET
   ?
   P_12CPI

   IF my_get_from_ini( "LD", "RekapitulacijaGustoPoVisini", "N", KUMPATH ) == "D"
      lGusto := .T.
      gRPL_Gusto()
      nDSGusto := Val( my_get_from_ini( "RekapGustoPoVisini", "DodatnihRedovaNaStranici", "11", KUMPATH ) )
      gPStranica += nDSGusto
   ELSE
      lGusto := .F.
      nDSGusto := 0
   ENDIF

   // samo pozicionira bazu PAROBR na odgovarajuci zapis
   ParObr( cMjesec, cGodina, cObracun, iif( !lSvi, cIdRj, ) )

   PRIVATE aRekap[ cLDPolja, 2 ]

   FOR i := 1 TO cLDPolja
      aRekap[ i, 1 ] := 0
      aRekap[ i, 2 ] := 0
   NEXT

   nT1 := 0
   nT2 := 0
   nT3 := 0
   nT4 := 0
   nUNeto := 0
   nUNetoOsnova := 0
   nDoprOsnova := 0
   nDoprOsnOst := 0
   nPorOsnova := 0
   nPorNROsnova := 0
   nUPorNROsnova := 0
   nURadn_bo := 0
   nUMRadn_bo := 0
   nURadn_bbo := 0
   nUPorOsnova := 0
   nULOdbitak := 0
   nUBNOsnova := 0
   nUDoprIz := 0
   nURadn_diz := 0
   nUIznos := 0
   nUSati := 0
   nUOdbici := 0
   nUOdbiciP := 0
   nUOdbiciM := 0
   nLjudi := 0
   nUBBTrosk := 0
   nURTrosk := 0

   PRIVATE aNeta := {}

   SELECT ld

   IF cMjesec != cMjesecDo
      IF lSvi
         GO TOP
         PRIVATE bUslov := {|| godina == cGodina .AND. mjesec >= cMjesec .AND. mjesec <= cMjesecDo .AND. obr = cObracun }
      ELSE
         PRIVATE bUslov := {|| godina == cGodina .AND. idrj == cIdRj .AND. mjesec >= cMjesec .AND. mjesec <= cMjesecDo .AND. obr = cObracun }
      ENDIF
   ELSE
      IF lSvi
         PRIVATE bUslov := {|| cgodina == godina .AND. cmjesec = mjesec .AND. obr = cObracun }
      ELSE
         PRIVATE bUslov := {|| cgodina == godina .AND. cidrj == idrj .AND. cmjesec = mjesec .AND. obr = cObracun }
      ENDIF
   ENDIF

   _calc_totals( lSvi, @_a_benef )

   IF nLjudi == 0
      nLjudi := 9999999
   ENDIF

   B_ON
   ?? cNaslovRekap
   B_OFF

   IF !Empty( cstrspr )
      ??U Space( 1 ) + "za radnike stručne spreme" + Space( 1 ), cStrSpr
   ENDIF

   IF !Empty( cOpsSt )
      ?U "Općina stanovanja:", cOpsSt
   ENDIF

   IF !Empty( cOpsRad )
      ?U "Općina rada:", cOpsRad
   ENDIF

   IF lSvi
      ZaglSvi()
   ELSE
      ZaglJ()
   ENDIF

   ? cTpLine

   cLinija := cTpLine

   IspisTP( lSvi )

   ? cTpLine

   nPosY := 60
   IF lPorNaRekap
      nPosY := 42
   ENDIF

   ? "Ukupno (primanja sa obustavama):"
   @ PRow(), nPosY SAY nUNeto + nUOdbiciP + nUOdbici PICT gpici
   ?? "", gValuta

   ? cTpLine

   IF !lGusto
      ?
   ENDIF

   ProizvTP()

   IF cRTipRada $ "A#U"

      ? cMainLine
      ?U "a) UKUPNI BRUTO SA TROŠKOVIMA "
      @ PRow(), 60 SAY nUBBTrosk PICT gPicI
      ?U "b) UKUPNI TROŠKOVI "
      @ PRow(), 60 SAY nURTrosk PICT gPici

   ENDIF


   // 1. BRUTO IZNOS
   // setuje se varijabla nBO
   get_bruto( nURadn_bo )

   // 2. DOPRINOSI
   PRIVATE nDopr
   PRIVATE nDopr2

   ?U "2. OBRAČUN DOPRINOSA:"

   // bruto osnova minimalca
   IF nURadn_bo < nUMRadn_bo

      ?? " min.bruto satnica * sati"
      @ PRow(), 60 SAY nUMRadn_bo PICT gPici

   ENDIF

   ? cMainLine

   cLinija := cDoprLine

   obr_doprinos( cGodina, cMjesec, @nDopr, @nDopr2, cRTipRada, _a_benef)

   nTOporDoh := nURadn_bo - nUDoprIz

   ? cMainLine
   ? "3. UKUPNO BRUTO - DOPRINOSI IZ PLATE"
   @ PRow(), 60 SAY nTOporDoh PICT gPici

   ? cMainLine
   ?U "4. LIČNI ODBICI UKUPNO"
   @ PRow(), 60 SAY nULOdbitak PICT gPici


   nPorOsn := nURadn_bo - nUDoprIz - nULOdbitak

   ? cMainLine
   ?U "5. OSNOVICA ZA OBRAČUN POREZA NA PLATU (1-2-4)"
   @ PRow(), 60 SAY nPorOsn PICT gPici
   ? cMainLine


   PRIVATE nPor
   PRIVATE nPor2
   PRIVATE nPorOps
   PRIVATE nPorOps2
   PRIVATE nUZaIspl

   nUZaIspl := 0
   nPorez1 := 0
   nPorez2 := 0
   nPorOp1 := 0
   nPorOp2 := 0
   nPorOl1 := 0
   nTOsnova := 0
   nPorB := 0
   nPorR := 0

   // obracunaj porez na bruto
   nTOsnova := obr_porez( cGodina, cMjesec, @nPor, @nPor2, @nPorOps, @nPorOps2, @nUPorOl, "B" )

   nPorB := nPor

   // ako je stvarna osnova veca od ove BRUTO - DOPRIZ - ODBICI
   // rijec je o radnicima koji nemaju poreza
   IF Round( nTOsnova, 2 ) > Round( nPorOsn, 2 )
      ?U Lokal( "! razlika osnovice poreza (radi radnika bez poreza):" )
      @ PRow(), 60 SAY nPorOsn - nTOsnova PICT gpici
      ?
   ENDIF

   nPorez1 += nPor
   nPorez2 += nPor2
   nPorOp1 += nPorOps
   nPorOp2 += nPorOps2
   nPorOl1 += nUPorOl

   nNetoIspl := nUPorNROsnova
   nUZaIspl := ( nNetoIspl ) + nUOdbiciM + nUOdbiciP

   ? cMainLine
   ? "6. UKUPNA NETO PLATA"
   @ PRow(), 60 SAY nNetoIspl PICT gpici

   ? cMainLine
   ?U "7. OSNOVICA ZA OBRAČUN OSTALIH NAKNADA (6)"
   @ PRow(), 60 SAY nNetoIspl PICT gpici
   ? cMainLine

   obr_porez( cGodina, cMjesec, @nPor, @nPor2, @nPorOps, @nPorOps2, @nUPorOl, "R" )

   nPorR := nPor
   nPorez1 += nPor
   nPorez2 += nPor2
   nPorOp1 += nPorOps
   nPorOp2 += nPorOps2
   nPorOl1 += nUPorOl

   ? cMainLine
   ? "8. UKUPNO ODBICI/NAKNADE IZ PLATE:"
   ? "             ODBICI:"
   @ PRow(), 60 SAY nUOdbiciM PICT gpici
   ? "     OSTALE NAKNADE:"
   @ PRow(), 60 SAY nUOdbiciP PICT gpici
   ? cMainLine

   ? cMainLine
   IF cRTipRada $ "A#U"
      ?U "9. UKUPNO ZA ISPLATU (bruto-dopr-porez+troškovi):"
   ELSE
      ?U "9. UKUPNO ZA ISPLATU (bruto-dopr-porez+odbici+naknade):"
   ENDIF
   @ PRow(), 60 SAY nUZaIspl PICT gpici
   ? cMainLine

   ?

   cLinija := "-----------------------------------------------------------"

   ? cLinija
   ? "OPOREZIVA PRIMANJA:"
   @ PRow(), PCol() + 1 SAY nUNeto PICT gpici
   ?? "(" + "za isplatu:"
   @ PRow(), PCol() + 1 SAY nUZaIspl PICT gpici
   ?? "," + "Obustave:"
   @ PRow(), PCol() + 1 SAY -nUOdbiciM PICT gpici
   ?? ")"
   ? "    " + "OSTALE NAKNADE:"
   @ PRow(), PCol() + 1 SAY nUOdbiciP PICT gpici  // dodatna primanja van neta
   ? cLinija
   ? " " + "OPOREZIVI DOHODAK (1):"
   @ PRow(), PCol() + 1 SAY nURadn_bo - nUDoprIz PICT gpici
   ? "         " + "POREZ 10% (2):"
   IF cUmPD == "D"
      @ PRow(), PCol() + 1 SAY nPorB - nPorOl1 - nPorez2    PICT gpici
   ELSE
      @ PRow(), PCol() + 1 SAY nPorB - nPorOl1    PICT gpici
   ENDIF
   ? "     " + "OSTALI POREZI (3):"
   @ PRow(), PCol() + 1 SAY nPorR PICT gpici
   ? "         " + "DOPRINOSI (4):"
   IF cUmPD == "D"
      @ PRow(), PCol() + 1 SAY nDopr - nDopr2    PICT gpici
   ELSE
      @ PRow(), PCol() + 1 SAY nDopr    PICT gpici
   ENDIF

   ? cLinija

   IF cUmPD == "D"
      ? " POTREBNA SREDSTVA (1 + 3 + 4):"
      @ PRow(), PCol() + 1 SAY ( nURadn_Bo - nUDoprIz ) + ( nPorR ) + nDopr - nPorez2 - nDopr2    PICT gpici
   ELSE
      ? " POTREBNA SREDSTVA (1 + 3 + 4 + ost.nakn.):"
      @ PRow(), PCol() + 1 SAY ( nURadn_Bo - nUDoprIz ) + ( nPorR ) + nDopr + nUOdbiciP PICT gpici
   ENDIF

   ? cLinija
   ?
   ?U "Izvršena obrada na ", Str( nLjudi, 5 ), "radnika"
   ?

   IF nUSati == 0
      nUSati := 999999
   ENDIF

   ?U "Prosječni neto/satu je ", AllTrim( Transform( nNetoIspl, gpici ) ), "/", AllTrim( Str( nUSati ) ), "=", AllTrim( Transform( nNetoIspl / nUsati, gpici ) ), "*", AllTrim( Transform( parobr->k1, "999" ) ), "=", AllTrim( Transform( nNetoIspl / nUsati * parobr->k1, gpici ) )


   P_12CPI
   ?
   ?
   ?  PadC( "     " + "Obradio:" + "                                 " + "Direktor:" + "    ", 80 )
   ?
   ?  PadC( "_____________________                    __________________", 80 )
   ?
   FF

   IF lGusto
      gRPL_Normal()
      gPStranica -= nDSGusto
   ENDIF

   my_close_all_dbf()

   END PRINT

   IF f18_use_module( "virm" ) .AND. Pitanje(, "Generisati virmane za ovaj obračun plate ? (D/N)", "N" ) == "D"
      virm_set_global_vars()
      set_metric( "virm_godina", my_user(), cGodina )
      set_metric( "virm_mjesec", my_user(), cMjesec )
      virm_prenos_ld( .T. )
      unos_virmana()
      my_close_all_dbf()
   ENDIF

   RETURN


STATIC FUNCTION nstr()

   IF PRow() > 64 + gpStranica
      FF
   ENDIF

   RETURN


STATIC FUNCTION _calc_totals( lSvi, a_benef )

   LOCAL i
   LOCAL cTpr
   LOCAL _benef_st

   nPorol := 0
   nRadn_bo := 0
   nRadn_bbo := 0
   nMRadn_bo := 0
   nPor := 0
   aNetoMj := {}

   DO WHILE !Eof() .AND. Eval( bUSlov )

      IF lViseObr .AND. Empty( cObracun )
         ScatterS( godina, mjesec, idrj, idradn )
      ELSE
         Scatter()
      ENDIF

      SELECT radn
      hseek _idradn

      SELECT vposla
      hseek _idvposla

      ParObr( ld->mjesec, ld->godina, cObracun, ld->idrj )

      SELECT ld

      cTipRada := g_tip_rada( ld->idradn, ld->idrj )

      // provjeri tip rada
      IF cTipRada $ tr_list() .AND. Empty( cRTipRada )
         // ovo je u redu...
      ELSEIF ( cRTipRada <> cTipRada )
         SELECT ld
         SKIP 1
         LOOP
      ENDIF

      IF ( ( !Empty( cOpsSt ) .AND. cOpsSt <> radn->idopsst ) ) ;
            .OR. ( ( !Empty( cOpsRad ) .AND. cOpsRad <> radn->idopsrad ) )

         SELECT ld
         SKIP 1
         LOOP

      ENDIF

      IF ( IsRamaGlas() .AND. cK4 <> "S" )

         IF ( cK4 = "P" .AND. !radn->k4 = "P" .OR. cK4 = "N" .AND. radn->k4 = "P" )
            SELECT ld
            SKIP 1
            LOOP
         ENDIF
      ENDIF

      _ouneto := Max( _uneto, PAROBR->prosld * gPDLimit / 100 )
      _oosnneto := 0
      _oosnostalo := 0

      nRadn_lod := _ulicodb

      nKoefLO := nRadn_lod

      cTrosk := radn->trosk

      lInRS := radnik_iz_rs( radn->idopsst, radn->idopsrad ) .AND. cTipRada $ "A#U"

      FOR i := 1 TO cLDPolja

         cTprField := PadL( AllTrim( Str( i ) ), 2, "0" )
         cTpr := "_I" + cTprField

         if &cTpr == 0
            LOOP
         ENDIF

         SELECT tippr
         SEEK cTprField
         SELECT ld

         IF tippr->( FieldPos( "TPR_TIP" ) ) <> 0
            IF tippr->tpr_tip == "N"

               // osnovica neto
               _oosnneto += &cTpr

            ELSEIF tippr->tpr_tip == "2"

               // osnovica ostalo
               _oosnostalo += &cTpr

            ELSEIF tippr->tpr_tip == " "

               IF tippr->uneto == "D"

                  // osnovica ostalo
                  _oosnneto += &cTpr

               ELSEIF tippr->uneto == "N"

                  // osnovica ostalo
                  _oosnostalo += &cTpr

               ENDIF
            ENDIF
         ELSE
            IF tippr->uneto == "D"
               // osnovica ostalo
               _oosnneto += &cTpr
            ELSEIF tippr->uneto == "N"
               // osnovica ostalo
               _oosnostalo += &cTpr
            ENDIF
         ENDIF
      NEXT

      nRSpr_koef := 0
      IF cTipRada == "S"
         nRSpr_koef := radn->sp_koef
      ENDIF

      // br.osn za radnika
      nRadn_bo := bruto_osn( _oosnneto, cTipRada, nKoefLO, nRSpr_koef, cTrosk )
      nTrosk := 0

      IF cTipRada $ "A#U"
         IF cTrosk <> "N"
            IF cTipRada == "A"
               nTrosk := gAHTrosk
            ELSEIF cTipRada == "U"
               nTrosk := gUgTrosk
            ENDIF
            // ako je u rs-u
            IF lInRS == .T.
               nTrosk := 0
            ENDIF
         ENDIF
      ENDIF

      // troskovi za ugovore i honorare
      nRTrosk := nRadn_bo * ( nTrosk / 100 )
      // ukupno bez troskova
      nUBBTrosk += nRadn_bo
      // ukupno troskovi
      nURTrosk += nRTrosk

      // troskove uzmi ako postoje, i to je osnovica
      nRadn_bo := nRadn_bo - nRTrosk

      IF cTipRada $ " #I#N"

         nMRadn_bo := nRadn_bo

         IF calc_mbruto()
            // minimalna bruto osnova
            nMRadn_bo := min_bruto( nRadn_bo, _usati )
         ENDIF

         // ukupno minimalna bruto osnova
         nUMRadn_bo += nMRadn_bo

      ELSE
         nMRadn_bo := nRadn_bo
         nUMRadn_bo += nRadn_bo
      ENDIF

      // ukupno bruto osnova
      nURadn_bo += nRadn_bo

      IF UBenefOsnovu()

         // beneficirani staz za radnika
         nRadn_bbo := bruto_osn( _oosnneto - if( !Empty( gBFForm ), &gBFForm, 0 ), cTipRada, nKoefLO, nRSpr_koef )
         nURadn_bbo += nRadn_bbo

         // uzmi stepen za radnika koji je ?
         _benef_st := BenefStepen()
         // upisi osnovicu...
         add_to_a_benef( @a_benef, AllTrim( radn->k3 ), _benef_st, nRadn_bbo )

      ENDIF

      // da bi dobio osnovicu za poreze
      // moram vidjeti i koliko su doprinosi IZ
      nRadn_diz := u_dopr_iz( nMRadn_bo, cTipRada )

      IF lInRS == .T.
         nRadn_diz := 0
      ENDIF

      // ukupni doprinosi iz
      nURadn_diz += nRadn_diz

      // osnovica za poreze
      nRadn_posn := ROUND2( ( nRadn_bo - nRadn_diz ) - nRadn_lod, gZaok2 )

      IF lInRS == .T.
         nRadn_posn := 0
      ENDIF

      // ovo je total poreske osnove za radnika
      nPorOsnova := nRadn_posn

      IF nPorOsnova < 0 .OR. !radn_oporeziv( ld->idradn, ld->idrj )
         nPorOsnova := 0
      ENDIF

      // ovo je total poreske osnove
      nUPorOsnova += nPorOsnova

      // obradi poreze....

      SELECT por
      GO TOP

      nPor := 0
      nPorOl := 0

      DO WHILE !Eof()

         cAlgoritam := get_algoritam()

         PozicOps( POR->poopst )

         IF !ImaUOp( "POR", POR->id )
            SKIP 1
            LOOP
         ENDIF

         IF por->por_tip == "B"
            aPor := obr_por( por->id, nPorOsnova, 0 )
         ELSE
            aPor := obr_por( por->id, _oosnneto, _oosnostalo )
         ENDIF

         // samo izracunaj total, ne ispisuj porez

         nTmpP := isp_por( aPor, cAlgoritam, "", .F. )

         IF nTmpP < 0
            nTmpP := 0
         ENDIF

         IF por->por_tip == "B"
            nPor += nTmpP
         ENDIF

         IF cAlgoritam == "S"
            PopuniOpsLd( cAlgoritam, por->id, aPor )
         ENDIF

         SELECT por

         SKIP

      ENDDO

      // neto na ruke osnova
      // BRUTO - DOPR_IZ - POREZ
      nPorNROsnova := ROUND2 ( ( nRadn_bo - nRadn_diz ) - nPor, gZaok2 )

      // minimalna neto osnova
      nPorNrOsnova := min_neto( nPorNROsnova, _usati )

      if cTipRada $ "A#U"
          // poreska osnova ugovori o djelu cine i troskovi
          nPorNROsnova += nRTrosk
      endif

      IF lInRS == .T.
         nPorNROsnova := 0
      ENDIF

      nUPorNROsnova += nPorNROsnova


      nPom := AScan( aNeta, {| x| x[ 1 ] == vposla->idkbenef } )

      IF nPom == 0
         AAdd( aNeta, { vposla->idkbenef, _oUNeto } )
      ELSE
         aNeta[ nPom, 2 ] += _oUNeto
      ENDIF

      FOR i := 1 TO cLDPolja

         cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
         SELECT tippr
         SEEK cPom
         SELECT ld
         aRekap[ i, 1 ] += _s&cPom  // sati
         nIznos := _i&cPom

         aRekap[ i, 2 ] += nIznos  // iznos

         IF tippr->uneto == "N" .AND. nIznos <> 0

            IF nIznos > 0
               nUOdbiciP += nIznos
            ELSE
               nUOdbiciM += nIznos
            ENDIF

         ENDIF
      NEXT

      ++ nLjudi

      nUSati += _USati
      // ukupno sati

      nUNeto += _UNeto
      // ukupno neto iznos

      nULOdbitak += nRadn_lod

      nUNetoOsnova += _oUNeto
      // ukupno neto osnova

      IF UBenefOsnovu()
         nUBNOsnova += _oUNeto - if( !Empty( gBFForm ), &gBFForm, 0 )
      ENDIF

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
            ParObr( mjesec, godina, IF( lViseObr, cObracun, ), IF( !lSvi, cIdRj, ) )
            // samo pozicionira bazu PAROBR na odgovarajui zapis
            AAdd( aNetoMj, { mjesec, _uneto, _usati, PAROBR->k3, PAROBR->k1 } )
            SELECT PAROBR
            GO ( nTRec )
            SELECT ( nTObl )
         ENDIF
      ENDIF

      // napuni opsld sa ovim porezom
      PopuniOpsLD()

      IF RADN->isplata == "TR"  // isplata na tekuci racun
         Rekapld( "IS_" + RADN->idbanka, cGodina, cMjesecDo,_UIznos, 0, RADN->idbanka, RADN->brtekr, RADNIK, .T. )
      ENDIF

      SELECT ld
      SKIP
   ENDDO

   RETURN


// ----------------------------------------------------------
// ispisuje i vraca bruto osnovicu za daljnji obracun
// ----------------------------------------------------------
STATIC FUNCTION get_bruto( nIznos )

   nBO := nIznos

   ? cMainLine
   IF cRTiprada $ "A#U"
      ? Lokal( "1. BRUTO PLATA (bruto sa troskovima - troskovi):" )
   ELSE
      ? Lokal( "1. BRUTO PLATA UKUPNO:" )
   ENDIF
   @ PRow(), 60 SAY nBO PICT gpici
   ? cMainLine

   RETURN