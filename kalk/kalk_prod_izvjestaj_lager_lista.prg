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

STATIC cTblKontrola := ""
STATIC aPorezi := {}
STATIC __line
STATIC __txt1
STATIC __txt2
STATIC __txt3


FUNCTION lager_lista_prodavnica()

   PARAMETERS lPocStanje

   // indikator gresaka
   LOCAL lImaGresaka := .F.
   LOCAL cKontrolnaTabela
   LOCAL cPicKol := gPicKol
   LOCAL cPicCDEm := gPicCDem
   LOCAL cPicDem := gPicDem
   LOCAL cSrKolNula := "0"
   LOCAL _curr_user := "<>"
   LOCAL cMpcIzSif := "N"
   LOCAL cMinK := "N"
   LOCAL _is_rok := .F.
   LOCAL _istek_roka := CToD( "" )
   LOCAL _item_istek_roka, _dok_hash, _sh_item_istek_roka
   LOCAL _print := "1"

   _is_rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"

   gPicCDEM := Replicate( "9", Val( gFPicCDem ) ) + gPicCDEM
   gPicDEM := Replicate( "9", Val( gFPicDem ) ) + gPicDem
   gPicKol := Replicate( "9", Val( gFPicKol ) ) + gPicKol

   cIdFirma := gFirma
   cIdKonto := PadR( "1320", gDuzKonto )
   O_SIFK
   O_SIFV
   O_ROBA
   O_KONTO
   O_PARTN

   cKontrolnaTabela := "N"

   IF ( lPocStanje == nil )
      lPocStanje := .F.
   ELSE
      lPocStanje := .T.
      O_KALK_PRIPR
      cBrPSt := "00001   "
      Box(, 2, 60 )
      @ m_x + 1, m_y + 2 SAY "Generacija poc. stanja  - broj dokumenta 80 -" GET cBrPSt
      READ
      BoxC()
   ENDIF

   cNula := "D"
   cK9 := Space( 3 )
   dDatOd := Date()
   dDatDo := Date()
   qqRoba := Space( 60 )
   qqTarifa := Space( 60 )
   qqidvd := Space( 60 )
   qqIdPartn := Space( 60 )
   PRIVATE cPNab := "N"
   PRIVATE cNula := "D"
   PRIVATE cTU := "N"
   PRIVATE cSredCij := "N"
   PRIVATE cPrikazDob := "N"
   PRIVATE cPlVrsta := Space( 1 )
   PRIVATE cPrikK2 := "N"
   PRIVATE aPorezi

   Box(, 18, 68 )

   cGrupacija := Space( 4 )
   cPredhStanje := "N"

   IF !lPocStanje
      cIdKonto := fetch_metric( "kalk_lager_lista_prod_id_konto", _curr_user, cIdKonto )
      cPNab := fetch_metric( "kalk_lager_lista_prod_po_nabavnoj", _curr_user, cPNab )
      cNula := fetch_metric( "kalk_lager_lista_prod_prikaz_nula", _curr_user, cNula )
      dDatOd := fetch_metric( "kalk_lager_lista_prod_datum_od", _curr_user, dDatOd )
      dDatDo := fetch_metric( "kalk_lager_lista_prod_datum_do", _curr_user, dDatDo )
      _print := fetch_metric( "kalk_lager_lista_prod_print", _curr_user, _print )
   ENDIF

   DO WHILE .T.
      IF gNW $ "DX"
         @ m_x + 1, m_y + 2 SAY "Firma "
         ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma  " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 2, m_y + 2 SAY "Konto   " GET cIdKonto VALID P_Konto( @cIdKonto )
      @ m_x + 3, m_y + 2 SAY "Artikli " GET qqRoba PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Tarife  " GET qqTarifa PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Partneri" GET qqIdPartn PICT "@!S50"
      @ m_x + 6, m_y + 2 SAY "Vrste dokumenata  " GET qqIDVD PICT "@!S30"
      @ m_x + 7, m_y + 2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  VALID cpnab $ "DN" PICT "@!"
      @ m_x + 7, Col() + 1 SAY "MPC iz sifrarnika D/N" GET cMpcIzSif VALID cMpcIzSif $ "DN" PICT "@!"
      @ m_x + 8, m_y + 2 SAY "Prikaz stavki kojima je MPV 0 D/N" GET cNula  VALID cNula $ "DN" PICT "@!"
      @ m_x + 9, m_y + 2 SAY "Datum od " GET dDatOd
      @ m_x + 9, Col() + 2 SAY "do" GET dDatDo

      IF _is_rok
         @ m_x + 9, Col() + 1 SAY "Datum isteka roka:" GET _istek_roka
      ENDIF
	
      @ m_x + 10, m_y + 2 SAY "Varijanta stampe TXT/ODT (1/2)" GET _print VALID _print $ "12" PICT "@!"

      IF lPocStanje
         @ m_x + 11, m_y + 2 SAY "sredi kol=0, nv<>0 (0/1/2)" GET cSrKolNula ;
            VALID cSrKolNula $ "012" PICT "@!"
      ENDIF

      @ m_x + 12, m_y + 2 SAY "Prikaz robe tipa T/U  (D/N)" GET cTU VALID cTU $ "DN" PICT "@!"
      @ m_x + 12, Col() + 2 SAY " generisati kontrolnu tabelu ? " GET cKontrolnaTabela VALID cKontrolnaTabela $ "DN" PICT "@!"
      @ m_x + 13, m_y + 2 SAY "Odabir grupacije (prazno-svi) GET" GET cGrupacija PICT "@!"
      @ m_x + 14, m_y + 2 SAY "Prikaz prethodnog stanja" GET cPredhStanje PICT "@!" VALID cPredhStanje $ "DN"
      @ m_x + 14, Col() + 2 SAY "Prik. samo kriticnih zaliha (D/N/O) ?" GET cMinK PICT "@!" VALID cMink $ "DNO"

      IF IsVindija()
         cGr := Space( 10 )
         cPSPDN := "N"
         @ m_x + 16, m_y + 2 SAY "Grupa " GET cGr
         @ m_x + 17, m_y + 2 SAY "Pregled samo prodaje (D/N) " GET cPSPDN VALID !Empty( cPSPDN ) .AND. cPSPDN $ "DN"  PICT "@!"
      ENDIF

      READ
      ESC_BCR
      PRIVATE aUsl1 := Parsiraj( qqRoba, "IdRoba" )
      PRIVATE aUsl2 := Parsiraj( qqTarifa, "IdTarifa" )
      PRIVATE aUsl3 := Parsiraj( qqIDVD, "idvd" )
      PRIVATE aUsl4 := Parsiraj( qqIdPartn, "IdPartner" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. aUsl3 <> NIL
         EXIT
      ENDIF
      IF aUsl4 <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   IF !lPocStanje
      set_metric( "kalk_lager_lista_prod_id_konto", _curr_user, cIdKonto )
      set_metric( "kalk_lager_lista_prod_po_nabavnoj", _curr_user, cPNab )
      set_metric( "kalk_lager_lista_prod_prikaz_nula", _curr_user, cNula )
      set_metric( "kalk_lager_lista_prod_datum_od", _curr_user, dDatOd )
      set_metric( "kalk_lager_lista_prod_datum_do", _curr_user, dDatDo )
      set_metric( "kalk_lager_lista_prod_print", _curr_user, _print )
   ENDIF

   my_close_all_dbf()

   IF ( cKontrolnaTabela == "D" )
      CreTblKontrola()
   ENDIF

   IF lPocStanje
      O_KALK_PRIPR
   ENDIF
   lPrikK2 := .F.
   IF cPrikK2 == "D"
      lPrikK2 := .T.
   ENDIF

   O_SIFK
   O_SIFV
   O_ROBA
   O_TARIFA
   O_KONTO
   O_PARTN
   O_KONCIJ
   O_KALKREP

   PRIVATE lSMark := .F.
   IF Right( Trim( qqRoba ), 1 ) = "*"
      lSMark := .T.
   ENDIF

   PRIVATE cFilter := ".t."

   IF aUsl1 <> ".t."
      cFilter += ".and." + aUsl1   // roba
   ENDIF
   IF aUsl2 <> ".t."
      cFilter += ".and." + aUsl2   // tarifa
   ENDIF
   IF aUsl3 <> ".t."
      cFilter += ".and." + aUsl3   // idvd
   ENDIF
   IF aUsl4 <> ".t."
      cFilter += ".and." + aUsl4   // partner
   ENDIF

   SELECT KALK

   SET ORDER TO TAG "4"

   SET FILTER to &cFilter
   // "4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")

   HSEEK cIdfirma + cIdkonto
   EOF CRET

   IF _print == "2"
      // odt stampa
      _params := hb_Hash()
      _params[ "idfirma" ] := gFirma
      _params[ "idkonto" ] := cIdKonto
      _params[ "nule" ] := cNula == "D"
      _params[ "datum_od" ] := dDatOd
      _params[ "datum_do" ] := dDatDo
      kalk_prodavnica_llp_odt( _params )
      RETURN
   ENDIF


   nLen := 1

   m := "----- ---------- -------------------- ---"
   nPom := Len( gPicKol )
   m += " " + REPL( "-", nPom )
   m += " " + REPL( "-", nPom )
   m += " " + REPL( "-", nPom )
   nPom := Len( gPicDem )
   m += " " + REPL( "-", nPom )
   m += " " + REPL( "-", nPom )
   m += " " + REPL( "-", nPom )
   m += " " + REPL( "-", nPom )

   IF cPredhstanje == "D"
      nPom := Len( gPicKol ) - 2
      m += " " + REPL( "-", nPom )
   ENDIF
   IF cSredCij == "D"
      nPom := Len( gPicCDem )
      m += " " + REPL( "-", nLen )
   ENDIF

   __line := m

   start PRINT cret
   ?
   SELECT konto
   HSEEK cIdKonto
   SELECT KALK

   PRIVATE nTStrana := 0

   PRIVATE bZagl := {|| ZaglLLP() }

   nTUlaz := 0
   nTIzlaz := 0
   nTPKol := 0
   nTMpv := 0
   nTMPVU := 0
   nTMPVI := 0
   nTNVU := 0
   nTNVI := 0
   // predhodna vrijednost
   nTPMPV := 0
   nTPNV := 0
   nTRabat := 0
   nCol1 := 50
   nCol0 := 50
   nRbr := 0

   Eval( bZagl )

   DO WHILE !Eof() .AND. cIdFirma + cIdKonto == field->idfirma + field->pkonto .AND. IspitajPrekid()
	
      cIdRoba := field->Idroba
	
      IF lSMark .AND. SkLoNMark( "ROBA", cIdroba )
         SKIP
         LOOP
      ENDIF

      SELECT roba
      HSEEK cIdRoba
	
      nMink := roba->mink

      IF IsVindija()
         IF !Empty( cGr )
            IF AllTrim( cGr ) <> AllTrim( IzSifKRoba( "GR1", cIdRoba, .F. ) )
               SELECT kalk
               SKIP
               LOOP
            ENDIF
         ENDIF
		
         IF ( cPSPDN == "D" )
            SELECT kalk
            IF !( kalk->idvd $ "41#42#43" ) .AND. !( kalk->pu_i == "5" )
               SKIP
               LOOP
            ENDIF
            SELECT roba
         ENDIF
      ENDIF
	
      SELECT KALK

      nPKol := 0
      nPNV := 0
      nPMPV := 0
      nUlaz := 0
      nIzlaz := 0
      nMPVU := 0
      nMPVI := 0
      nNVU := 0
      nNVI := 0
      nRabat := 0

      IF cTU == "N" .AND. roba->tip $ "TU"
         SKIP
         LOOP
      ENDIF

      DO WHILE !Eof() .AND. cIdfirma + cIdkonto + cIdroba == field->idFirma + field->pkonto + field->idroba .AND. IspitajPrekid()
	
         IF lSMark .AND. SkLoNMark( "ROBA", cIdroba )
            SKIP
            LOOP
         ENDIF

         // provjeri mi i datum isteka roka kod artikala
         IF _is_rok

            IF !Empty( _istek_roka )

               _dok_hash := hb_Hash()
               _dok_hash[ "idfirma" ] := field->idfirma
               _dok_hash[ "idtipdok" ] := field->idvd
               _dok_hash[ "brdok" ] := field->brdok
               _dok_hash[ "rbr" ] := field->rbr

               _item_istek_roka := CToD( get_kalk_atribut_rok( _dok_hash, .T. ) )

               IF DToC( _item_istek_roka ) == DToC( CToD( "" ) ) .OR. _item_istek_roka > _istek_roka
                  SELECT kalk
                  SKIP
                  LOOP
               ELSE
                  _sh_item_istek_roka := _item_istek_roka
               ENDIF

            ENDIF

         ENDIF

         IF cPredhStanje == "D"
            IF field->datdok < dDatOd
               IF field->pu_i == "1"

                  SumirajKolicinu( field->kolicina, 0, @nPKol, 0, lPocStanje, lPrikK2 )
                  nPMPV += field->mpcsapp * field->kolicina
                  nPNV += field->nc * ( field->kolicina )

               ELSEIF field->pu_i == "5"

                  aPorezi := {}
                  Tarifa( field->pkonto, field->idroba, @aPorezi, field->idtarifa )
                  aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
                  nPor1 := aIPor[ 1 ]
                  VtPorezi()

                  SumirajKolicinu( -( field->kolicina ), 0, @nPKol, 0, lPocStanje, lPrikK2 )

                  // vrijednost sa popustom
                  // nPMPV -= ( field->mpc + nPor1 ) * field->kolicina

                  nPMPV -= field->mpcsapp * field->kolicina
                  nPNV -= field->nc * field->kolicina

               ELSEIF field->pu_i == "3"
                  // nivelacija
                  nPMPV += field->mpcsapp * field->kolicina
               ELSEIF pu_i == "I"
                  SumirajKolicinu( -( field->gKolicin2 ), 0, @nPKol, 0, lPocStanje, lPrikK2 )
                  nPMPV -= field->mpcsapp * field->gkolicin2
                  nPNV -= field->nc * field->gkolicin2
               ENDIF
            ENDIF
         ELSE
            IF field->datdok < dDatod .OR. field->datdok > dDatdo
               SKIP
               LOOP
            ENDIF
         ENDIF

         IF cTU == "N" .AND. roba->tip $ "TU"
            SKIP
            LOOP
         ENDIF

         IF !Empty( cGrupacija )
            IF cGrupacija <> roba->k1
               SKIP
               LOOP
            ENDIF
         ENDIF

         IF field->DatDok >= dDatOd
            // nisu predhodni podaci
            IF field->pu_i == "1"
               SumirajKolicinu( field->kolicina, 0, @nUlaz, 0, lPocStanje, lPrikK2 )
               nCol1 := PCol() + 1
               nMPVU += field->mpcsapp * field->kolicina
               nNVU += field->nc * ( field->kolicina )
            ELSEIF field->pu_i == "5"

               aPorezi := {}
               Tarifa( field->pkonto, field->idroba, @aPorezi, field->idtarifa )
               aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
               nPor1 := aIPor[ 1 ]
               VtPorezi()

               IF idvd $ "12#13"
                  SumirajKolicinu( -( field->kolicina ), 0, @nUlaz, 0, lPocStanje, lPrikK2 )
                  nMPVU -= field->mpcsapp * field->kolicina
                  nNVU -= field->nc * field->kolicina
               ELSE
                  SumirajKolicinu( 0, field->kolicina, 0, @nIzlaz, lPocStanje, lPrikK2 )
                  // vrijednost sa popustom
                  // nMPVI += ( field->mpc + nPor1 ) * field->kolicina
                  nMPVI += field->mpcsapp * field->kolicina
                  nNVI += field->nc * field->kolicina
               ENDIF

            ELSEIF field->pu_i == "3"
               // nivelacija
               nMPVU += field->mpcsapp * field->kolicina
            ELSEIF field->pu_i == "I"
               SumirajKolicinu( 0, field->gkolicin2, 0, @nIzlaz, lPocStanje, lPrikK2 )
               nMPVI += field->mpcsapp * field->gkolicin2
               nNVI += field->nc * field->gkolicin2
            ENDIF
         ENDIF
         SKIP
      ENDDO
	
      IF cMinK == "D" .AND. ( nUlaz - nIzlaz - nMink ) > 0
         LOOP
      ENDIF

      // ne prikazuj stavke 0
      IF cNula == "D" .OR. Round( nMPVU - nMPVI + nPMPV, 2 ) <> 0
	
         IF PRow() > page_length()
            FF
            Eval( bZagl )
         ENDIF
		
         SELECT roba
         HSEEK cIdRoba
		
         SELECT kalk
         aNaz := Sjecistr( roba->naz, 20 )

         ? Str( ++nRbr, 4 ) + ".", cIdRoba

         nCr := PCol() + 1

         @ PRow(), PCol() + 1 SAY aNaz[ 1 ]
         @ PRow(), PCol() + 1 SAY roba->jmj

         nCol0 := PCol() + 1
		
         IF cPredhStanje == "D"
            @ PRow(), PCol() + 1 SAY nPKol PICT gpickol
         ENDIF
		
         @ PRow(), PCol() + 1 SAY nUlaz PICT gpickol
         @ PRow(), PCol() + 1 SAY nIzlaz PICT gpickol
         @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz + nPkol PICT gpickol
		
         IF lPocStanje
  			
            SELECT kalk_pripr
  			
            IF Round( nUlaz - nIzlaz, 4 ) <> 0 .AND. cSrKolNula $ "01"
     				
               APPEND BLANK
     				
               REPLACE idFirma WITH cIdfirma
               REPLACE idroba WITH cIdRoba
               REPLACE idkonto WITH cIdKonto
               REPLACE datdok WITH dDatDo + 1
               REPLACE idTarifa WITH Tarifa( cIdKonto, cIdRoba, @aPorezi )
               REPLACE datfaktp WITH dDatDo + 1
               REPLACE kolicina WITH nulaz - nizlaz
               REPLACE idvd WITH "80"
               REPLACE brdok WITH cBRPST
               REPLACE nc WITH ( nNVU - nNVI + nPNV ) / ( nulaz - nizlaz + nPKol )
               REPLACE mpcsapp WITH ( nMPVU - nMPVI + nPMPV ) / ( nulaz - nizlaz + nPKol )
               REPLACE TMarza2 WITH "A"
				
               IF koncij->NAZ == "N1"
                  REPLACE vpc WITH nc
               ENDIF
			
            ELSEIF cSrKolNula $ "12" .AND. Round( nUlaz - nIzlaz, 4 ) = 0
				
               IF ( nMPVU - nMPVI + nPMPV ) <> 0
					
                  // 1 stavka (minus)
                  APPEND BLANK
     				
                  REPLACE idFirma WITH cIdfirma
                  REPLACE idroba WITH cIdRoba
                  REPLACE idkonto WITH cIdKonto
                  REPLACE datdok WITH dDatDo + 1
                  REPLACE idTarifa WITH Tarifa( cIdKonto, cIdRoba, @aPorezi )
                  REPLACE datfaktp WITH dDatDo + 1
                  REPLACE kolicina WITH -1
                  REPLACE idvd WITH "80"
                  REPLACE brdok WITH cBRPST
                  REPLACE brfaktp WITH "#KOREK"
                  REPLACE nc WITH 0
                  REPLACE mpcsapp WITH 0
                  REPLACE TMarza2 WITH "A"
				
                  IF koncij->NAZ == "N1"
                     REPLACE vpc WITH nc
                  ENDIF
					
                  // 2 stavka (plus i razlika mpv)
                  APPEND BLANK
     				
                  REPLACE idFirma WITH cIdfirma
                  REPLACE idroba WITH cIdRoba
                  REPLACE idkonto WITH cIdKonto
                  REPLACE datdok WITH dDatDo + 1
                  REPLACE idTarifa WITH Tarifa( cIdKonto, cIdRoba, @aPorezi )
                  REPLACE datfaktp WITH dDatDo + 1
                  REPLACE kolicina WITH 1
                  REPLACE idvd WITH "80"
                  REPLACE brdok WITH cBRPST
                  REPLACE brfaktp WITH "#KOREK"
                  REPLACE nc WITH 0
                  REPLACE mpcsapp with ;
                     ( nMPVU - nMPVI + nPMPV )
                  REPLACE TMarza2 WITH "A"
				
                  IF koncij->NAZ == "N1"
                     REPLACE vpc WITH nc
                  ENDIF
			
               ENDIF

            ENDIF
  			
            SELECT KALK

         ENDIF

         nCol1 := PCol() + 1

         @ PRow(), PCol() + 1 SAY nMPVU PICT gPicDem
         @ PRow(), PCol() + 1 SAY nMPVI PICT gPicDem
         @ PRow(), PCol() + 1 SAY nMPVU - nMPVI + nPMPV PICT gPicDem

         SELECT koncij
         SEEK Trim( cIdKonto )

         SELECT roba
         HSEEK cIdRoba

         _mpc := UzmiMPCSif()

         SELECT kalk

         IF Round( nUlaz - nIzlaz + nPKOL, 2 ) <> 0

            // if cMpcIzSif == "D"
            // @ prow(), pcol() + 1 SAY _mpc pict gpiccdem
            // nTMpv += ( ( nUlaz - nIzlaz + nPKOL ) * _mpc )
            // else
            // mpcsapdv
            @ PRow(), PCol() + 1 SAY ( nMPVU - nMPVI + nPMPV ) / ( nUlaz - nIzlaz + nPKol ) PICT gpiccdem

            // if ROUND(( nMPVU - nMPVI + nPMPV ) / ( nUlaz - nIzlaz + nPKol ), 2) <> ROUND( _mpc, 2 )
            // ?? " ERR MPC =", ALLTRIM( STR( _mpc, 12, 2 )  )
            // endif
            // endif

         ELSE

            // stanje artikla je 0
            @ PRow(), PCol() + 1 SAY 0 PICT gpicdem

            IF Round( ( nMPVU - nMPVI + nPMPV ), 4 ) <> 0
               ?? " ERR"
               lImaGresaka := .T.
            ENDIF

         ENDIF

         IF cSredCij == "D"
            @ PRow(), PCol() + 1 SAY ( nNVU - nNVI + nPNV + nMPVU - nMPVI + nPMPV ) / ( nUlaz - nIzlaz + nPKol ) / 2 PICT "9999999.99"
         ENDIF

         IF Len( aNaz ) > 1 .OR. cPredhStanje == "D" .OR. cPNab == "D"
            @ PRow() + 1, 0 SAY ""
            IF Len( aNaz ) > 1
               @ PRow(), nCR  SAY aNaz[ 2 ]
            ENDIF
            @ PRow(), nCol0 - 1 SAY ""
         ENDIF

         IF ( cKontrolnaTabela == "D" )
            AzurKontrolnaTabela( cIdRoba, nUlaz - nIzlaz + nPkol, nMpvU - nMpvI + nPMpv )
         ENDIF

         IF cPredhStanje == "D"
            @ PRow(), PCol() + 1 SAY nPMPV PICT gpicdem
         ENDIF

         IF cPNab == "D"

            @ PRow(), PCol() + 1 SAY Space( Len( gpickol ) )
            @ PRow(), PCol() + 1 SAY Space( Len( gpickol ) )

            IF Round( nUlaz - nIzlaz + nPKol, 4 ) <> 0
               @ PRow(), PCol() + 1 SAY ( nNVU - nNVI + nPNV ) / ( nUlaz - nIzlaz + nPKol ) PICT gpicdem
            ELSE
               @ PRow(), PCol() + 1 SAY Space( Len( gpicdem ) )
            ENDIF

            @ PRow(), nCol1 SAY nNVU PICT gpicdem
            // @ prow(),pcol()+1 SAY space(len(gpicdem))
            @ PRow(), PCol() + 1 SAY nNVI PICT gpicdem
            @ PRow(), PCol() + 1 SAY nNVU - nNVI + nPNV PICT gpicdem
            @ PRow(), PCol() + 1 SAY _mpc PICT gpiccdem

         ENDIF


         nTULaz += nUlaz
         nTIzlaz += nIzlaz

         nTPKol += nPKol

         nTMPVU += nMPVU
         nTMPVI += nMPVI

         nTNVU += nNVU
         nTNVI += nNVI

         nTRabat += nRabat

         nTPMPV += nPMPV
         nTPNV += nPNV

         IF lKoristitiBK
            ? Space( 6 ) + roba->barkod
         ENDIF

         IF _is_rok .AND. !Empty( _istek_roka ) .AND. !Empty( _sh_item_istek_roka )
            IF !lKoristitiBK
               ? Space( 6 )
            ENDIF
            ?? " rok istice:", DToC( _sh_item_istek_roka ), " dana:", AllTrim( Str( _sh_item_istek_roka - Date() ) )
         ENDIF
		
      ENDIF

   ENDDO

   ? __line
   ? "UKUPNO:"

   @ PRow(), nCol0 - 1 SAY ""

   IF cPredhStanje == "D"
      @ PRow(), PCol() + 1 SAY nTPMPV PICT gpickol
   ENDIF

   @ PRow(), PCol() + 1 SAY nTUlaz PICT gpickol
   @ PRow(), PCol() + 1 SAY nTIzlaz PICT gpickol
   @ PRow(), PCol() + 1 SAY nTUlaz - nTIzlaz + nTPKol PICT gpickol

   nCol1 := PCol() + 1

   @ PRow(), PCol() + 1 SAY nTMPVU PICT gpicdem
   @ PRow(), PCol() + 1 SAY nTMPVI PICT gpicdem

   @ PRow(), PCol() + 1 SAY nTMPVU - nTMPVI + nTPMPV PICT gpicdem
   @ PRow(), PCol() + 1 SAY nTMpv PICT gpicdem

   IF cPNab == "D"
      @ PRow() + 1, nCol0 - 1 SAY ""
      IF cPredhStanje == "D"
         @ PRow(), PCol() + 1 SAY nTPNV PICT gpickol
      ENDIF
      @ PRow(), PCol() + 1 SAY Space( Len( gpicdem ) )
      @ PRow(), PCol() + 1 SAY Space( Len( gpicdem ) )
      @ PRow(), PCol() + 1 SAY Space( Len( gpicdem ) )
      @ PRow(), PCol() + 1 SAY nTNVU PICT gpicdem
      @ PRow(), PCol() + 1 SAY nTNVI PICT gpicdem
      @ PRow(), PCol() + 1 SAY nTNVU - nTNVI + nTPNV PICT gpicdem
   ENDIF

   ? __line

   FF
   ENDPRINT

   IF lImaGresaka
      MsgBeep( "Pogledajte artikle za koje je u izvjestaju stavljena oznaka ERR - GRESKA" )
   ENDIF

   IF lPocStanje
      IF lImaGresaka .AND. Pitanje(, "Nulirati pripremu (radi ponavljanja procedure) ?", "D" ) == "D"
         SELECT kalk_pripr
         ZAP
      ELSE
         renumeracija_kalk_pripr( cBrPSt, "80" )
      ENDIF
   ENDIF

   gPicDem := cPicDem
   gPicKol := cPicKol
   gPicCDem := cPicCDem

   my_close_all_dbf()

   RETURN



// zaglavlje llp
FUNCTION ZaglLLP( lSint )

   IF lSint == NIL
      lSint := .F.
   ENDIF

   Preduzece()
   P_COND
   ?? "KALK: LAGER LISTA  PRODAVNICA ZA PERIOD", dDatOd, "-", dDatDo, " NA DAN "
   ?? Date(), Space( 12 ), "Str:", Str( ++nTStrana, 3 )

   IF !lSint .AND. !Empty( qqIdPartn )
      ? "Obuhvaceni sljedeci partneri:", Trim( qqIdPartn )
   ENDIF

   IF lSint
      ? "Kriterij za prodavnice:", qqKonto
   ELSE
      SELECT konto
      HSEEK cidkonto
      ? "Prodavnica:", cIdKonto, "-", konto->naz
   ENDIF

   cSC1 := ""
   cSC2 := ""

   SELECT kalk
   ?U __line

   IF cPredhStanje == "D"
	
      IF IsPDV()
		
         cTmp := " R.  * Artikal  *   Naziv            *jmj*"
         nPom := Len( gPicKol )
         cTmp += PadC( "Predh.st", nPom ) + "*"
         cTmp += PadC( "ulaz", nPom ) + " " + PadC( "izlaz", nPom ) + "*"
         cTmp += PadC( "STANJE", nPom ) + "*"
         nPom := Len( gPicDem )
         cTmp += PadC( "PV.Dug.", nPom ) + "*"
         cTmp += PadC( "PV.Pot.", nPom ) + "*"
         cTmp += PadC( "PV", nPom ) + "*"
         nPom := Len( gPicCDem )
         cTmp += PadC( "PC.SA PDV", nPom ) + "*"
         cTmp += cSC1
  		
         ?U cTmp
		
      ELSE
		
         cTmp := " R.  * Artikal  *   Naziv            *jmj*"
         nPom := Len( gPicKol )
         cTmp += PadC( "Predh.st", nPom ) + "*"
         cTmp += PadC( "ulaz", nPom ) + " " + PadC( "izlaz", nPom ) + "*"
         cTmp += PadC( "STANJE", nPom ) + "*"
         nPom := Len( gPicDem )
         cTmp += PadC( "MPV.Dug.", nPom ) + "*"
         cTmp += PadC( "MPV.Pot.", nPom ) + "*"
         cTmp += PadC( "MPV", nPom ) + "*"
         nPom := Len( gPicCDem )
         cTmp += PadC( "MPC sa PP", nPom ) + "*"
         cTmp += cSC1
  	
         ?U cTmp

      ENDIF
	
      cTmp := " br. *          *                    *   *"
      nPom := Len( gPicKol )
      cTmp += PadC( "Kol/MPV", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + " " + REPL( " ", nPom ) + "*"
      nPom := Len( gPicDem )
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += cSC2
	
      ?U cTmp
	
      IF cPNab == "D"
  		
         cTmp := "     *          *                    *   *"
         nPom := Len( gPicKol )
         cTmp += REPL( " ", nPom ) + "*"
         cTmp += REPL( " ", nPom ) + " " + REPL( " ", nPom ) + "*"
         nPom := Len( gPicDem )
         cTmp += PadC( "SR.NAB.C", nPom ) + "*"
         cTmp += PadC( "NV.Dug.", nPom ) + "*"
         cTmp += PadC( "NV.Pot", nPom ) + "*"
         cTmp += PadC( "NV", nPom ) + "*"
         cTmp += REPL( " ", nPom ) + "*"
         cTmp += cSC2
		
         ?U cTmp
      ENDIF
   ELSE
      cTmp := " R.  * Artikal  *   Naziv            *jmj*"
      nPom := Len( gPicKol )
      cTmp += PadC( "ulaz", nPom ) + " " + PadC( "izlaz", nPom ) + "*"
      cTmp += PadC( "STANJE", nPom ) + "*"
      nPom := Len( gPicDem )
      cTmp += PadC( "PV.Dug.", nPom ) + "*"
      cTmp += PadC( "PV.Pot.", nPom ) + "*"
      cTmp += PadC( "PV", nPom ) + "*"
      cTmp += PadC( "PC.SA PDV", nPom ) + "*"
      cTmp += cSC1
      ?U cTmp
  	
      cTmp := " br. *          *                    *   *"
      nPom := Len( gPicKol )
      cTmp += REPL( " ", nPom ) + " " + REPL( " ", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + "*"
      nPom := Len( gPicDem )
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += REPL( " ", nPom ) + "*"
      cTmp += cSC2
	
      ?U cTmp
	
      IF cPNab == "D"
  		
         cTmp := "     *          *                    *   *"
         nPom := Len( gPicKol )
         cTmp += REPL( " ", nPom ) + " " + REPL( " ", nPom ) + "*"
         nPom := Len( gPicDem )
         cTmp += PadC( "SR.NAB.C", nPom ) + "*"
         cTmp += PadC( "NV.Dug.", nPom ) + "*"
         cTmp += PadC( "NV.Pot", nPom ) + "*"
         cTmp += PadC( "NV", nPom ) + "*"
         cTmp += REPL( " ", nPom ) + "*"
         cTmp += cSC2
	
         ?U cTmp
		
      ENDIF
   ENDIF

   IF cPredhStanje == "D"
	
      cTmp := "     *    1     *        2           * 3 *"
      nPom := Len( gPicKol )
      cTmp += PadC( "4", nPom ) + "*"
      cTmp += PadC( "5", nPom ) + "*"
      cTmp += PadC( "6", nPom ) + "*"
      cTmp += PadC( "5 - 6", nPom ) + "*"
      nPom := Len( gPicDem )
      cTmp += PadC( "7", nPom ) + "*"
      cTmp += PadC( "8", nPom ) + "*"
      cTmp += PadC( "7 - 8", nPom ) + "*"
      cTmp += PadC( "9", nPom ) + "*"
      cTmp += cSC2
  	
      ?U cTmp
	
   ELSE
	
      cTmp := "     *    1     *        2           * 3 *"
      nPom := Len( gPicKol )
      cTmp += PadC( "4", nPom ) + "*"
      cTmp += PadC( "5", nPom ) + "*"
      cTmp += PadC( "4 - 5", nPom ) + "*"
      nPom := Len( gPicDem )
      cTmp += PadC( "6", nPom ) + "*"
      cTmp += PadC( "7", nPom ) + "*"
      cTmp += PadC( "6 - 7", nPom ) + "*"
      cTmp += PadC( "8", nPom ) + "*"
      cTmp += cSC2
	
      ?U cTmp
	
   ENDIF

   ?U __line

   RETURN


// kreiranje kontrolne tabele
STATIC FUNCTION CreTblKontrola()

   LOCAL aDbf
   LOCAL cCdx

   aDbf := {}
   cTblKontrola := my_home() + "kontrola.dbf"

   AAdd( aDbf, { "ID", "C", 10, 0 } )
   AAdd( aDbf, { "kolicina", "N", 12, 2 } )
   AAdd( aDbf, { "Mpv", "N", 10, 2 } )

   dbCreate( cTblKontrola, aDbf )
   my_use_temp( "KONTROLA", cTblKontrola, .F., .T. )
   INDEX ON id TAG "ID"

   RETURN


// azuriranje kontrolne tabele
STATIC FUNCTION AzurKontrolnaTabela( cIdRoba, nStanje, nMpv )

   LOCAL nArea

   nArea := Select()

   SELECT ( F_TMP_1 )

   IF !Used()
      USE ( cTblKontrola )
   ENDIF

   SELECT kontrola
   APPEND BLANK
   REPLACE id WITH cIdRoba
   REPLACE kolicina WITH nStanje
   REPLACE Mpv WITH nMpv

   SELECT( nArea )

   RETURN



STATIC FUNCTION kalk_prodavnica_llp_odt( params )

   IF !_gen_xml( params )
      MsgBeep( "Problem sa generisanjem podataka ili nema podataka !" )
      RETURN
   ENDIF

   IF generisi_odt_iz_xml( "kalk_llp.odt", my_home() + "data.xml" )
      prikazi_odt()
   ENDIF

   RETURN



// -----------------------------------------------------
// generisanje xml fajla
// -----------------------------------------------------
STATIC FUNCTION _gen_xml( params )

   LOCAL _idfirma := params[ "idfirma" ]
   LOCAL _idkonto := params[ "idkonto" ]
   LOCAL _idroba, _mpc, _mpcs
   LOCAL _ulaz, _izlaz, _nv_u, _nv_i, _mpv_u, _mpv_i, _rabat
   LOCAL _t_ulaz, _t_izlaz, _t_nv_u, _t_nv_i, _t_mpv_u, _t_mpv_i, _t_rabat
   LOCAL _rbr := 0

   PRIVATE aPorezi

   SELECT konto
   HSEEK params[ "idkonto" ]

   _t_ulaz := _t_izlaz := _t_nv_u := _t_nv_i := 0
   _t_mpv_u := _t_mpv_i := _t_rabat := 0

   open_xml( my_home() + "data.xml" )
   xml_head()

   xml_subnode( "ll", .F. )

   xml_node( "dat_od", DToC( params[ "datum_od" ] ) )
   xml_node( "dat_do", DToC( params[ "datum_do" ] ) )
   xml_node( "dat", DToC( Date() ) )
   xml_node( "tip", "PRODAVNICA" )
   xml_node( "fid", to_xml_encoding( gFirma ) )
   xml_node( "fnaz", to_xml_encoding( gNFirma ) )
   xml_node( "kid", to_xml_encoding( params[ "idkonto" ] ) )
   xml_node( "knaz", to_xml_encoding( AllTrim( konto->naz ) ) )

   SELECT kalk

   DO WHILE !Eof() .AND. _idfirma + _idkonto == field->idfirma + field->pkonto .AND. IspitajPrekid()
	
      _idroba := field->Idroba
	
      SELECT roba
      HSEEK _idroba

      SELECT kalk

      _ulaz := 0
      _izlaz := 0
      _nv_u := 0
      _nv_i := 0
      _mpv_u := 0
      _mpv_i := 0
      _rabat := 0

      DO WHILE !Eof() .AND. _idfirma + _idkonto + _idroba == field->idfirma + field->pkonto + field->idroba .AND. IspitajPrekid()
	
         IF field->datdok < params[ "datum_od" ] .OR. field->datdok > params[ "datum_do" ]
            SKIP
            LOOP
         ENDIF

         IF field->datdok >= params[ "datum_od" ]
            // nisu predhodni podaci
            IF field->pu_i == "1"
               SumirajKolicinu( field->kolicina, 0, @_ulaz, 0, .F., .F. )
               _mpv_u += field->mpcsapp * field->kolicina
               _nv_u += field->nc * ( field->kolicina )
            ELSEIF field->pu_i == "5"
               aPorezi := {}
               Tarifa( field->pkonto, field->idroba, @aPorezi, field->idtarifa )
               aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
               nPor1 := aIPor[ 1 ]
               VtPorezi()
               IF field->idvd $ "12#13"
                  SumirajKolicinu( -( field->kolicina ), 0, @_ulaz, 0, .F., .F. )
                  _mpv_u -= field->mpcsapp * field->kolicina
                  _nv_u -= field->nc * field->kolicina
               ELSE
                  SumirajKolicinu( 0, field->kolicina, 0, @_izlaz, .F., .F. )
                  _mpv_i += field->mpcsapp * field->kolicina
                  _nv_i += field->nc * field->kolicina
               ENDIF

            ELSEIF field->pu_i == "3"
               // nivelacija
               _mpv_u += field->mpcsapp * field->kolicina
            ELSEIF field->pu_i == "I"
               SumirajKolicinu( 0, field->gkolicin2, 0, @_izlaz, .F., .F. )
               _mpv_i += field->mpcsapp * field->gkolicin2
               _nv_i += field->nc * field->gkolicin2
            ENDIF

         ENDIF

         SKIP

      ENDDO
	
      // ne prikazuj stavke 0
      IF params[ "nule" ] .OR. Round( _mpv_u - _mpv_i, 2 ) <> 0
			
         SELECT koncij
         SEEK _idkonto

         SELECT roba
         HSEEK _idroba

         _mpcs := UzmiMPCSif()

         SELECT kalk

         xml_subnode( "items", .F. )

         xml_node( "rbr", AllTrim( Str( ++_rbr ) ) )
         xml_node( "id", to_xml_encoding( _idroba ) )
         xml_node( "naz", to_xml_encoding( AllTrim( roba->naz ) ) )
         xml_node( "barkod", to_xml_encoding( AllTrim( roba->barkod ) ) )
         xml_node( "tar", to_xml_encoding( AllTrim( roba->idtarifa ) ) )
         xml_node( "jmj", to_xml_encoding( AllTrim( roba->jmj ) ) )

         xml_node( "ulaz", Str( _ulaz, 12, 3 ) )
         xml_node( "izlaz", Str( _izlaz, 12, 3 ) )
         xml_node( "stanje", Str( _ulaz - _izlaz, 12, 3 ) )

         xml_node( "nvu", Str( _nv_u, 12, 3 ) )
         xml_node( "nvi", Str( _nv_i, 12, 3 ) )
         xml_node( "nv", Str( _nv_u - _nv_i, 12, 3 ) )

         xml_node( "mpvu", Str( _mpv_u, 12, 3 ) )
         xml_node( "mpvi", Str( _mpv_i, 12, 3 ) )
         xml_node( "mpv", Str( _mpv_u - _mpv_i, 12, 3 ) )

         xml_node( "rabat", Str( _rabat, 12, 3 ) )

         xml_node( "mpcs", Str( _mpcs, 12, 3 ) )

         IF Round( _ulaz - _izlaz, 3 ) <> 0
            _mpc := Round( ( _mpv_u - _mpv_i ) / ( _ulaz - _izlaz ), 3 )
            _nc := Round( ( _nv_u - _nv_i ) / ( _ulaz - _izlaz ), 3 )
         ELSE
            _mpc := 0
            _nc := 0
         ENDIF

         xml_node( "mpc", Str( Round( _mpc, 3 ), 12, 3 ) )
         xml_node( "nc", Str( Round( _nc, 3 ), 12, 3 ) )

         IF ( _mpcs <> _mpc )
            xml_node( "err", "ERR" )
         ELSE
            xml_node( "err", "" )
         ENDIF

         _t_ulaz += _ulaz
         _t_izlaz += _izlaz

         _t_mpv_u += _mpv_u
         _t_mpv_i += _mpv_i

         _t_nv_u += _nv_u
         _t_nv_i += _nv_i

         _t_rabat += _rabat

         xml_subnode( "items", .T. )

      ENDIF

   ENDDO

   xml_node( "ulaz", Str( _t_ulaz, 12, 3 ) )
   xml_node( "izlaz", Str( _t_izlaz, 12, 3 ) )
   xml_node( "stanje", Str( _t_ulaz - _t_izlaz, 12, 3 ) )

   xml_node( "nvu", Str( _t_nv_u, 12, 3 ) )
   xml_node( "nvi", Str( _t_nv_i, 12, 3 ) )
   xml_node( "nv", Str( _t_nv_u - _t_nv_i, 12, 3 ) )

   xml_node( "mpvu", Str( _t_mpv_u, 12, 3 ) )
   xml_node( "mpvi", Str( _t_mpv_i, 12, 3 ) )
   xml_node( "mpv", Str( _t_mpv_u - _t_mpv_i, 12, 3 ) )
   xml_node( "rabat", Str( _t_rabat, 12, 3 ) )

   xml_subnode( "ll", .T. )

   close_xml()
   my_close_all_dbf()

   IF _rbr > 0
      _ok := .T.
   ENDIF

   RETURN _ok
