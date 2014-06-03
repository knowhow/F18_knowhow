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

STATIC DUZ_STRANA := 70
STATIC __radni_sati := "N"



FUNCTION ld_kartica_plate_redovan_rad( cIdRj, cMjesec, cGodina, cIdRadn, cObrac, aNeta )

   LOCAL nKRedova
   LOCAL cDoprSpace := Space( 3 )
   LOCAL cTprLine
   LOCAL cDoprLine
   LOCAL cMainLine
   LOCAL _radni_sati := fetch_metric( "ld_radni_sati", nil, "N" )
   LOCAL _a_benef := {}
   PRIVATE cLMSK := ""

   __radni_sati := _radni_sati

   cTprLine := _gtprline()
   cDoprLine := _gdoprline( cDoprSpace )
   cMainLine := _gmainline()

   // koliko redova ima kartica
   nKRedova := kart_redova()

   Eval( bZagl )

   IF gTipObr == "2" .AND. parobr->k1 <> 0
      ?? Lokal( "        Bod-sat:" )
      @ PRow(), PCol() + 1 SAY parobr->vrbod / parobr->k1 * brbod PICT "99999.99999"
   ENDIF

   IF l2kolone
	
      P_COND2
      // aRCPos  := { PROW() , PCOL() }
      cDefDev := Set( _SET_PRINTFILE )
      SvratiUFajl()
      // SETPRC(0,0)
   ENDIF

   cUneto := "D"
   nRRsati := 0
   nOsnNeto := 0
   nOsnOstalo := 0
   nOstPoz := 0
   nOstNeg := 0
   // nLicOdbitak := g_licni_odb( radn->id )
   nLicOdbitak := ld->ulicodb
   nKoefOdbitka := g_klo( nLicOdbitak )
   cRTipRada := g_tip_rada( ld->idradn, ld->idrj )

   ? cTprLine
   IF gPrBruto == "X"
      ? cLMSK + Lokal( " Vrsta                  Opis         sati/iznos            ukupno bruto" )
   ELSE
      ? cLMSK + Lokal( " Vrsta                  Opis         sati/iznos             ukupno" )
   ENDIF

   ? cTprLine

   FOR i := 1 TO cLDPolja
	
      cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
	
      SELECT tippr
      SEEK cPom
	
      IF tippr->uneto == "N" .AND. cUneto == "D"
		
         cUneto := "N"
		
         ? cTprLine
         ? cLMSK + Lokal( "Ukupno:" )

         @ PRow(), nC1 + 8  SAY  _USati  PICT gpics
         ?? Space( 1 ) + Lokal( "sati" )
         nPom := _calc_tpr( _UNeto, .T. )
         @ PRow(), 60 + Len( cLMSK ) SAY nPom PICT gpici
         ?? "", gValuta
         ? cTprLine
	
      ENDIF
	
      IF tippr->( Found() ) .AND. tippr->aktivan == "D"

         IF _i&cpom <> 0 .OR. _s&cPom <> 0
			
            // uvodi se djoker # : Primjer:
            // Naziv tipa primanja
            // je: REDOVAN RAD BOD #RADN->N1 -> naci RADN->N1
            // i ispisati REDOVAN RAD BOD 12.0
			
            nDJ := At( "#", tippr->naz )
            cDJ := Right( AllTrim( tippr->naz ), nDJ + 1 )
            cTPNaz := tippr->naz
			
            // NEPOTREBNO, ALI IPAK OSTAVLJAM 'KOD'

            // if nDJ <> 0
				
            // RSati:=_s&cPom
				
            // nRSTmp := bruto_osn( _i&cPom, cRTipRada, ;
            // nLicOdbitak )

            // @ prow(),60+LEN(cLMSK) SAY nRsTmp pict gpici
            // @ prow()+1,0 SAY Lokal("Odbici od bruta: ")
				
            // @ prow(), pcol()+48 SAY "-" + ;
            // ALLTRIM(STR(( nRSTmp -_i&cPom)))

            // if type( cDJ ) = "C"
            // cTPNaz := LEFT( tippr->naz, nDJ-1 ) + ;
            // &cDJ
            // elseif type( cDJ ) = "N"
            // cTPNAZ := LEFT( tippr->naz, nDJ-1 ) + ;
            // alltrim(str( &cDJ ))
            // endif
            // endif
			
            ? cLMSK + tippr->id + "-" + ;
               PadR( cTPNAZ, Len( tippr->naz ) ), sh_tp_opis( tippr->id, radn->id )
            nC1 := PCol()
			
            IF tippr->fiksan $ "DN"
				
               @ PRow(), PCol() + 8 SAY _s&cPom PICT gpics
               ?? " s"
				
               nPom := _calc_tpr( _i&cPom )
               @ PRow(), 60 + Len( cLMSK ) SAY nPom PICT gpici

				
               IF tippr->id == "01" .AND. __radni_sati == "D"
					
                  nRRSati := _s&cPom
				
               ENDIF

               // UKIDA SE, ALI OSTAVLJAM 'KOD'

               // nRSTmp := bruto_osn( _i&cPom, ;
               // cRTipRada, ;
               // nLicOdbitak )
	
               // @ prow(),60+LEN(cLMSK) SAY nRSTmp pict gpici
               // @ prow()+1,0 SAY Lokal("Odbici od bruta: ")
               // @ prow(), pcol()+48 SAY "-" + ;
               // ALLTRIM(STR(nRSTmp - _i&cPom))
               // else
					
               // nPom := _calc_tpr( _i&cPom )
					
               // @ prow(),60+LEN(cLMSK) say nPom pict gpici
               // endif
			
            ELSEIF tippr->fiksan == "P"
               nPom := _calc_tpr( _i&cPom )
               @ PRow(), PCol() + 8 SAY _s&cPom  PICT "999.99%"
               @ PRow(), 60 + Len( cLMSK ) SAY nPom  PICT gpici

            ELSEIF tippr->fiksan == "B"
               nPom := _calc_tpr( _i&cPom )
               @ PRow(), PCol() + 8 SAY _s&cPom  PICT "999999"; ?? " b"
               @ PRow(), 60 + Len( cLMSK ) SAY nPom PICT gpici

            ELSEIF tippr->fiksan == "C"
               nPom := _calc_tpr( _i&cPom )
               @ PRow(), 60 + Len( cLMSK ) SAY nPom PICT gpici
            ENDIF
	
            // suma iz prethodnih obracuna !
            IF "_K" == Right( AllTrim( tippr->opis ), 2 )

               nKumPrim := KumPrim( _IdRadn, cPom )

               IF SubStr( AllTrim( tippr->opis ), 2, 1 ) == "1"
                  nKumPrim := nKumPrim + radn->n1
               ELSEIF SubStr( AllTrim( tippr->opis ), 2, 1 ) == "2"
                  nKumPrim := nKumPrim + radn->n2
               ELSEIF SubStr( AllTrim( tippr->opis ), 2, 1 ) == "3"
                  nKumPrim := nKumPrim + radn->n3
               ENDIF

               IF tippr->uneto == "N"
                  nKumPrim := Abs( nKumPrim )
               ENDIF
    			
               ? cLPom := cLMSK + "   ----------------------------- ----------------------------"
               ? cLMSK + "    SUMA IZ PRETHODNIH OBRA¬UNA   UKUPNO (SA OVIM OBRA¬UNOM)"
               ? cLPom
               ? cLMSK + "   " + PadC( Str( nKumPrim - Abs( _i&cPom ) ), 29 ) + " " + PadC( Str( nKumPrim ), 28 )
               ? cLPom
            ENDIF
		
            IF tippr->( FieldPos( "TPR_TIP" ) ) <> 0
               // uzmi osnovice
               IF tippr->tpr_tip == "N"
                  nOsnNeto += _i&cPom
               ELSEIF tippr->tpr_tip == "2"
                  nOsnOstalo += _i&cPom
                  IF _i&cPom > 0
                     nOstPoz += _i&cPom
                  ELSE
                     nOstNeg += _i&cPom
                  ENDIF
               ELSEIF tippr->tpr_tip == " "
                  // standardni tekuci sistem
                  IF tippr->uneto == "D"
                     nOsnNeto += _i&cPom
                  ELSE
                     nOsnOstalo += _i&cPom
                     IF _i&cPom > 0
                        nOstPoz += _i&cPom
                     ELSE
                        nOstNeg += _i&cPom
                     ENDIF

                  ENDIF

               ENDIF

            ELSE
               // standardni tekuci sistem
               IF tippr->uneto == "D"
                  nOsnNeto += _i&cPom
               ELSE
                  nOsnOstalo += _i&cPom
                  IF _i&cPom > 0
                     nOstPoz += _i&cPom
                  ELSE
                     nOstNeg += _i&cPom
                  ENDIF
               ENDIF
            ENDIF
			
            IF "SUMKREDITA" $ tippr->formula .AND. gReKrKP == "1"
				
               IF l2kolone
                  P_COND2
               ELSE
                  P_COND
               ENDIF
				
               ? cTprLine
               ? cLMSK + "  ", Lokal( "Od toga pojedinacni krediti:" )
               SELECT radkr
               SET ORDER TO 1
               SEEK Str( _godina, 4 ) + Str( _mjesec, 2 ) + _idradn
               DO WHILE !Eof() .AND. _godina == godina .AND. _mjesec = mjesec .AND. idradn == _idradn
                  SELECT kred
                  hseek radkr->idkred
                  SELECT radkr
                  ? cLMSK + "  ", idkred, Left( kred->naz, 22 ), naosnovu
                  @ PRow(), 58 + Len( cLMSK ) SAY iznos PICT "(" + gpici + ")"
                  SKIP 1
               ENDDO
				
               ? cTprLine
				
               IF l2kolone
                  P_COND2
               ELSE
                  P_12CPI
               ENDIF
				
               SELECT ld
				
            ELSEIF "SUMKREDITA" $ tippr->formula
				
               SELECT radkr
               SET ORDER TO 1
               SEEK Str( _godina, 4 ) + Str( _mjesec, 2 ) + _idradn
               ukredita := 0
				
               IF l2kolone
                  P_COND2
               ELSE
                  P_COND
               ENDIF
				
               ? m2 := cLMSK + "   ------------------------------------------------  --------- --------- -------"
               ?     cLMSK + Lokal( "        Kreditor      /              na osnovu         Ukupno    Ostalo   Rata" )
               ? m2
				
               DO WHILE !Eof() .AND. _godina == godina .AND. _mjesec = mjesec .AND. idradn == _idradn
                  SELECT kred
                  hseek radkr->idkred
                  SELECT radkr
                  aIznosi := OKreditu( idradn, idkred, naosnovu, _mjesec, _godina )
                  ? cLMSK + " ", idkred, Left( kred->naz, 22 ), PadR( naosnovu, 20 )
                  @ PRow(), PCol() + 1 SAY aIznosi[ 1 ] PICT "999999.99" // ukupno
                  @ PRow(), PCol() + 1 SAY aIznosi[ 1 ] -aIznosi[ 2 ] PICT "999999.99"// ukupno-placeno
                  @ PRow(), PCol() + 1 SAY iznos PICT "9999.99"
                  ukredita += iznos
                  SKIP 1
               ENDDO
				
               IF l2kolone
                  P_COND2
               ELSE
                  P_12CPI
               ENDIF
				
               IF !lSkrivena .AND. PRow() > 55 + gPStranica
                  FF
               ENDIF

               SELECT ld
            ENDIF
         ENDIF
      ENDIF
   NEXT

   IF cVarijanta == "5"

      // select ldsm
	
      SELECT ld
      PushWA()
      SET ORDER TO TAG "2"
      hseek Str( _godina, 4 ) + Str( _mjesec, 2 ) + "1" + _idradn + _idrj
      // hseek "1"+str(_godina,4)+str(_mjesec,2)+_idradn+_idrj
      ?
      ? cLMSK + Lokal( "Od toga 1. dio:" )
      @ PRow(), 60 + Len( cLMSK ) SAY UIznos PICT gpici
      ? cTprLine
      hseek Str( _godina, 4 ) + Str( _mjesec, 2 ) + "2" + _idradn + _idrj
      // hseek "2"+str(_godina,4)+str(_mjesec,2)+_idradn+_idrj
      ? cLMSK + Lokal( "Od toga 2. dio:" )
      @ PRow(), 60 + Len( cLMSK ) SAY UIznos PICT gpici
      ? cTprLine
      SELECT ld
      PopWA()
   ENDIF

   IF __radni_sati == "D"
      ? Lokal( "NAPOMENA: Ostaje da se plati iz preraspodjele radnog vremena " )
      ?? AllTrim( Str( ( ld->radsat ) - nRRSati ) )  + Lokal( " sati." )
      ? Lokal( "          Ostatak predhodnih obracuna: " ) + GetStatusRSati( ld->idradn ) + Space( 1 ) + Lokal( "sati" )
      ?
   ENDIF

   IF gSihtGroup == "D"
      // sihtarice po grupama
      // izbaci satinicu za radnika
      nTmp := get_siht( .T., cGodina, cMjesec, ld->idradn, "" )
      IF ld->usati < nTmp
         ? "Greska: sati po sihtarici veci od uk.sati place !"
      ENDIF
   ENDIF

   IF gPrBruto $ "D#X"
	
      // prikaz bruto iznosa
	
      SELECT ( F_POR )
	
      IF !Used()
         O_POR
      ENDIF
	
      SELECT ( F_DOPR )
	
      IF !Used()
         O_DOPR
      ENDIF
	
      SELECT ( F_KBENEF )
      IF !Used()
         O_KBENEF
      ENDIF

      nBO := 0
      nBFO := 0
	
      nOsnZaBr := nOsnNeto
	
      nBo := bruto_osn( nOsnZaBr, cRTipRada, nLicOdbitak )

      IF UBenefOsnovu()
		
         nTmp2 := nOsnZaBr - IF( !Empty( gBFForm ),  &( gBFForm ), 0 )
         nBFo := bruto_osn( nTmp2, cRTipRada, nLicOdbitak )

         _benef_st := BenefStepen()
         add_to_a_benef( @_a_benef, AllTrim( radn->k3 ), _benef_st, nBFO )

      ENDIF

      nBoMin := nBo

      IF cRTipRada $ " #I#N"
         IF calc_mbruto()
            // minimalni bruto
            nBoMin := min_bruto( nBo, ld->usati )
         ENDIF
      ENDIF

      // bruto placa iz neta...

      ? cMainLine
	
      IF gPrBruto == "X"
         ? cLMSK + "1. BRUTO PLATA :  "
      ELSE
         ? cLMSK + "1. BRUTO PLATA :  ", bruto_isp( nOsnZaBr, cRTipRada, nLicOdbitak )
      ENDIF

      IF cRTipRada == "I"
         ?
      ENDIF

      @ PRow(), 60 + Len( cLMSK ) SAY nBo PICT gpici
	
      ? cMainLine
	
      IF lSkrivena
         ? cMainLine
      ENDIF
	
      // razrada doprinosa ....
	
      ? cLmSK + Lokal( "Obracun doprinosa: " )
	
      IF ( nBo < nBoMin )
		
         ??  Lokal( "minimalna bruto satnica * sati" )

         @ PRow(), 60 + Len( cLMSK ) SAY nBoMin PICT gpici

         ? cLmSk + cDoprLine
      ENDIF

      SELECT dopr
      GO TOP
	
      nPom := 0
      nDopr := 0
      nUkDoprIz := 0
      nC1 := 20 + Len( cLMSK )
	
      DO WHILE !Eof()
	
         IF cRTipRada $ tr_list() .AND. Empty( dopr->tiprada )
            // ovo je uredu...
         ELSEIF dopr->tiprada <> cRTipRada
            SKIP
            LOOP
         ENDIF

         IF dopr->( FieldPos( "DOP_TIP" ) ) <> 0
			
            IF dopr->dop_tip == "N" .OR. dopr->dop_tip == " "
               nOsn := nOsnNeto
            ELSEIF dopr->dop_tip == "2"
               nOsn := nOsnOstalo
            ELSEIF dopr->dop_tip == "P"
               nOsn := nOsnNeto + nOsnOstalo
            ENDIF
		
         ENDIF
		
         PozicOps( DOPR->poopst )
			
         // preskoci zbirne doprinose
         // ako je tako navedeno u parametrima
         IF gKarSDop == "N" .AND. Left( dopr->id, 1 ) <> "1"
            SKIP
            LOOP
         ENDIF

         IF !ImaUOp( "DOPR", DOPR->id ) .OR. !lPrikSveDopr .AND. !DOPR->ID $ cPrikDopr
            SKIP 1
            LOOP
         ENDIF
		
         IF Right( id, 1 ) == "X"
            ? cDoprLine
         ENDIF
		
         IF dopr->id == "1X"
            ? cLMSK + "2. " + id, "-", naz
         ELSE
            ? cLMSK + cDoprSpace + id, "-", naz
         ENDIF

         @ PRow(), PCol() + 1 SAY iznos PICT "99.99%"
		
         IF Empty( idkbenef )
            // doprinos udara na neto
            @ PRow(), PCol() + 1 SAY nBoMin PICT gpici
            nC1 := PCol() + 1
            @ PRow(), PCol() + 1 SAY nPom := Max( dlimit, Round( iznos / 100 * nBOMin, gZaok2 ) ) PICT gpici
			
            IF dopr->id == "1X"
               nUkDoprIz += nPom
            ENDIF

         ELSE
            nPom0 := AScan( _a_benef, {| x| x[ 1 ] == idkbenef } )
            IF nPom0 <> 0
               nPom2 := _a_benef[ nPom0, 3 ]
            ELSE
               nPom2 := 0
            ENDIF
            IF Round( nPom2, gZaok2 ) <> 0
               @ PRow(), PCol() + 1 SAY nPom2 PICT gpici
               nC1 := PCol() + 1
               nPom := Max( dlimit, Round( iznos / 100 * nPom2, gZaok2 ) )
               @ PRow(), PCol() + 1 SAY nPom PICT gpici
            ENDIF
         ENDIF
		
         IF Right( id, 1 ) == "X"
			
            ? cDoprLine
            nDopr += nPom
		
         ENDIF
		
         IF !lSkrivena .AND. PRow() > 64 + gPStranica
            FF
         ENDIF
		
         SKIP 1
		
      ENDDO

      // oporezivi dohodak
      nOporDoh := nBO - nUkDoprIz

      // oporezivi dohodak
      ? cLMSK + Lokal( "3. BRUTO - DOPRINOSI IZ PLATE (1-2)" )
      @ PRow(), 60 + Len( cLMSK ) SAY nOporDoh PICT gpici
	
      ? cMainLine

      // razrada licnog odbitka ....
	
      IF nLicOdbitak > 0

         ? cLMSK + Lokal( "4. LICNI ODBITAK" ), Space( 14 ) + ;
            AllTrim( Str( gOsnLOdb ) ) + " * koef. " + ;
            AllTrim( Str( nKoefOdbitka ) ) + " = "
         @ PRow(), 60 + Len( cLMSK ) SAY nLicOdbitak PICT gpici
	
      ELSE
	
         ? cLMSK + Lokal( "4. LICNI ODBITAK" )
         @ PRow(), 60 + Len( cLMSK ) SAY nLicOdbitak PICT gpici
	
      ENDIF

      ? cMainLine

      nPorOsnovica := ( nBO - nUkDoprIz - nLicOdbitak )
	
      // ako je negativna onda je 0
      IF nPorOsnovica < 0 .OR. !radn_oporeziv( radn->id, ld->idrj )
         nPorOsnovica := 0
      ENDIF

      ?  cLMSK + Lokal( "5. OSNOVICA ZA POREZ NA PLATU (1-2-4)" )
      @ PRow(), 60 + Len( cLMSK ) SAY nPorOsnovica PICT gpici

      ? cMainLine

      // razrada poreza na platu ....
      // u ovom dijelu idu samo porezi na bruto TIP = "B"

      ? cLMSK + Lokal( "6. POREZ NA PLATU" )

      SELECT por
      GO TOP
	
      nPom := 0
      nPor := 0
      nC1 := 30 + Len( cLMSK )
      nPorOl := 0
	
      DO WHILE !Eof()
	
         // vrati algoritam poreza
         cAlgoritam := get_algoritam()
		
         PozicOps( POR->poopst )
		
         IF !ImaUOp( "POR", POR->id )
            SKIP 1
            LOOP
         ENDIF
		
         // sracunaj samo poreze na bruto
         IF por->por_tip <> "B"
            SKIP
            LOOP
         ENDIF
	
         // obracunaj porez
         aPor := obr_por( por->id, nPorOsnovica, 0 )
		
         // ispisi porez
         nPor += isp_por( aPor, cAlgoritam, cLMSK, .T., .T. )
		
         SKIP 1
      ENDDO

      @ PRow(), 60 + Len( cLMSK ) SAY nPor PICT gpici

      // neto na ruke
      nUkIspl := ROUND2( nBO - nUkDoprIz - nPor, gZaok2 )

      nMUkIspl := nUkIspl

      IF cRTipRada $ " #I#N"
         // minimalna neto isplata
         nMUkIspl := min_neto( nUkIspl, ld->usati )
      ENDIF

      ? cMainLine
	
      IF nUkIspl < nMUkIspl
         ? cLMSK + Lokal( "7. Minimalna neto isplata : min.neto satnica * sati" )
      ELSE
         ? cLMSK + Lokal( "7. NETO PLATA (1-2-6)" )
      ENDIF

      @ PRow(), 60 + Len( cLMSK ) SAY nMUkIspl PICT gpici


      // ostala primanja
      ? cMainLine
      ? cLMSK + Lokal( "8. NEOPOREZIVE NAKNADE I ODBICI (preb.stanje)" )

      @ PRow(), 60 + Len( cLMSK ) SAY nOsnOstalo PICT gpici

      ? cLMSK + Lokal( "  - naknade (+ primanja): " )
      @ PRow(), 60 + Len( cLMSK ) SAY nOstPoz PICT gPICI

      ? cLMSK + Lokal( "  -  odbici (- primanja): " )
      @ PRow(), 60 + Len( cLMSK ) SAY nOstNeg PICT gPICI

      // ukupno za isplatu ....
      nZaIsplatu := ROUND2( nMUkIspl + nOsnOstalo, gZaok2 )
	
      ? cMainLine
      ?  cLMSK + Lokal( "UKUPNO ZA ISPLATU SA NAKNADAMA I ODBICIMA (7+8)" )
      @ PRow(), 60 + Len( cLMSK ) SAY nZaIsplatu PICT gpici

      ? cMainLine

      IF !lSkrivena .AND. PRow() > 64 + gPStranica
         FF
      ENDIF

      ?
	
      // if prow()>31
      IF gPotp <> "D"
         IF PCount() == 0
            FF
         ENDIF
      ENDIF
	
   ENDIF

   IF l2kolone
      SET PRINTER TO ( cDefDev ) ADDITIVE
      // SETPRC(aRCPos[1],aRCPos[2])
      IF PRow() + 2 + nDMSK > nKRSK * ( 2 -( nRBrKart % 2 ) )
         aTekst := U2Kolone( PRow() + 2 + nDMSK - nKRSK * ( 2 -( nRBrKart % 2 ) ) )
         FOR i := 1 TO Len( aTekst )
            IF i == 1
               ?? aTekst[ i ]
            ELSE
               ? aTekst[ i ]
            ENDIF
         NEXT
         SetPRC( nKRSK * ( 2 -( nRBrKart % 2 ) ) -2 -nDMSK, PCol() )
      ELSE
         PRINTFILE( PRIVPATH + "xoutf.txt" )
      ENDIF
   ENDIF

   // potpis na kartici
   kart_potpis()

   // obrada sekvence za kraj papira

   // skrivena kartica
   IF lSkrivena
      IF PRow() < nKRSK + 5
         nPom := nKRSK - PRow()
         FOR i := 1 TO nPom
            ?
         NEXT
      ELSE
         FF
      ENDIF
      // 2 kartice na jedan list N - obavezno FF
   ELSEIF c2K1L == "N"
      FF
      // ako je prikaz bruto D obavezno FF
   ELSEIF gPrBruto $ "D#X"
      FF
      // nova kartica novi list - obavezno FF
   ELSEIF lNKNS
      FF
      // druga kartica takodjer FF
   ELSEIF ( nRBRKart % 2 == 0 )
      FF
      // prva kartica, ali druga ne moze stati
   ELSEIF ( nRBRKart % 2 <> 0 ) .AND. ( DUZ_STRANA - PRow() < nKRedova )
      --nRBRKart
      FF
   ENDIF

   RETURN
