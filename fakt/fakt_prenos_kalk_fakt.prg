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



// ------------------------------------------------
// kalkulacija -> faktura : prenos
// ------------------------------------------------
FUNCTION kalk_fakt()

   LOCAL izb := 1
   PUBLIC gDirKalk := ""

   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. prenos kalk -> fakt            " )
   AAdd( opcexe, {|| kalk_2_fakt() } )
   AAdd( opc, "2. prenos kalk->fakt za partnera  " )
   AAdd( opcexe, {|| kalkp_2_fakt() } )
   AAdd( opc, "3. parametri prenosa" )
   AAdd( opcexe, {|| _params() } )

   f18_menu_sa_priv_vars_opc_opcexe_izbor( "prenosfakt" )

   RETURN .T.


// ---------------------------------------
// parametri prenosa
// ---------------------------------------
STATIC FUNCTION _params()

   o_params()

   PRIVATE cSection := "T"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   Box(, 3, 70 )
   @ form_x_koord() + 1, form_y_koord() + 2 SAY "Radni direktorij KALK (KALK.DBF):" GET gDirKalk PICT "@S30"
   READ
   BoxC()

   gDirKalk := Trim( gDirKalk )

   IF LastKey() <> K_ESC
      WPar( "dk", gDirKalk )
   ENDIF

   SELECT params
   USE

   RETURN .T.


// -----------------------------------------
// prenos kalk u fakt
// -----------------------------------------
FUNCTION kalk_2_fakt()

   LOCAL cIdFirma := self_organizacija_id()
   LOCAL cIdTipDok := "10"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrFakt
   LOCAL cDir := Space( 25 )
   LOCAL lToRacun := .F.
   LOCAL cFaktPartn := Space( 6 )
   LOCAL lFirst

   _o_tables()

   SELECT kalk
   SET ORDER TO TAG "1"

   Box(, 15, 60 )

   DO WHILE .T.

      cIdTipDok := "10"
      cBrDok := Space( 8 )

      @ form_x_koord() + 2, form_y_koord() + 2 SAY "Broj KALK dokumenta:"

      IF gNW == "N"
         @ form_x_koord() + 2, Col() + 1 GET cIdFirma PICT "@!"
      ELSE
         @ form_x_koord() + 2, Col() + 1 SAY cIdFirma PICT "@!"
      ENDIF

      @ form_x_koord() + 2, Col() + 1 SAY "- " GET cIdTipDok
      @ form_x_koord() + 2, Col() + 1 SAY "-" GET cBrDok

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF


      cTipFakt := _g_fakt_type( cIdTipDok ) // vrati tip dokumenta za fakturisanje

      cBrFakt := cBrDok
      cIdRj := cIdFirma

      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Broj dokumenta u modulu FAKT: "
      @ form_x_koord() + 3, Col() + 1 GET cIdRJ PICT "@!"
      @ form_x_koord() + 3, Col() + 2 SAY "-" GET cTipFakt
      @ form_x_koord() + 3, Col() + 2 SAY "-" GET cBrFakt ;
         WHEN _set_brdok( cIdRj, cTipFakt, @cBrFakt )

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF


      IF cTipFakt == "10" .AND. cIdTipDok == "10" // ako je kalk 10 i fakt 10 onda je to fakt racun
         lToRacun := .T.
      ENDIF

      // partner kojem se fakturise.....
      IF lToRacun == .T.
         @ form_x_koord() + 4, form_y_koord() + 2 SAY "Partner kojem se fakturise:" GET cFaktPartn VALID p_partner( @cFaktPartn )

         READ

         IF LastKey() == K_ESC
            EXIT
         ENDIF
      ENDIF

      IF find_fakt_dokument( cIdRj, cTipFakt, cBrFakt )
         Beep( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "U FAKT vec postoji ovaj dokument !!"
         Inkey( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 37 )
         LOOP
      ENDIF
      seek_fakt( cIdRj, cTipFakt, cBrFakt )

      IF !find_kalk_doks_by_broj_dokumenta( cIdFirma , cIdTipDok, cBrDok )
         Beep( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Ne postoji ovaj dokument !"
         Inkey( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 30 )
         LOOP

      ENDIF
      find_kalk_by_broj_dokumenta( cIdFirma , cIdTipDok, cBrDok )

      select_o_rj( cIdRj )

      SELECT KALK
      lFirst := .T.


      nRokPl := 0 // rok placanja

      dDatPl := kalk->datdok
      dDatDok := kalk->datdok

      DO WHILE !Eof() .AND. cIdFirma + cIdTipDok + cBrDok == IdFirma + IdVD + BrDok

         select_o_roba( kalk->idroba )

         SELECT kalk
         IF lFirst == .T.

            IF lToRacun == .T.

               select_o_partner( cFaktPartn )
               nRokPl := IzSifKPartn( "ROKP", cFaktPartn, .F. )
               IF ValType( nRokPl ) == "N" .AND. nRokPl > 0
                  dDatPl := dDatDok + nRokPl
               ELSE
                  nRokPl := 0
               ENDIF

            ELSE
               select_o_partner( KALK->idpartner )
            ENDIF

            cTxta := PadR( partn->naz, 30 )
            cTxtb := PadR( partn->naz2, 30 )
            cTxtc := PadR( partn->mjesto, 30 )

            @ form_x_koord() + 10, m_Y + 2 SAY "Partner " GET cTxta
            @ form_x_koord() + 11, m_Y + 2 SAY "        " GET cTxtb
            @ form_x_koord() + 12, m_Y + 2 SAY "Mjesto  " GET cTxtc

            IF nRokPl > 0
               @ form_x_koord() + 14, form_y_koord() + 2 SAY "Rok placanja: " + AllTrim( Str( nRokPl ) ) + " dana"
            ENDIF

            READ

            cTxt := Chr( 16 ) + " " + Chr( 17 ) + ;
               Chr( 16 ) + " " + Chr( 17 ) + ;
               Chr( 16 ) + cTxta + Chr( 17 ) + ;
               Chr( 16 ) + cTxtb + Chr( 17 ) + ;
               Chr( 16 ) + cTxtc + Chr( 17 )

            IF lToRacun == .T.

               cTxt += Chr( 16 ) + "" + Chr( 17 ) + ;
                  Chr( 16 ) + DToC( dDatDok ) + Chr( 17 ) + ;
                  Chr( 16 ) + "" + Chr( 17 ) + ;
                  Chr( 16 ) + DToC( dDatPl ) + Chr( 17 )

            ENDIF

            lFirst := .F.

            SELECT fakt_pripr
            APPEND BLANK

            REPLACE txt WITH cTxt
            REPLACE idpartner WITH kalk->idpartner

            IF lToRacun == .T.
               REPLACE idpartner WITH cFaktPartn
            ENDIF

         ELSE
            SELECT fakt_pripr
            APPEND BLANK
         ENDIF

         PRIVATE nKolicina := kalk->kolicina

         IF kalk->idvd == "11" .AND. cTipFakt = "0"
            nKolicina := -nKolicina
         ENDIF

         REPLACE idfirma WITH cIdRj
         REPLACE rbr WITH KALK->Rbr
         REPLACE idtipdok WITH cTipFakt
         REPLACE brdok WITH cBrFakt
         REPLACE datdok WITH kalk->datdok
         REPLACE kolicina WITH nKolicina
         REPLACE idroba WITH kalk->idroba
         REPLACE cijena WITH kalk->fcj
         REPLACE rabat WITH kalk->rabat
         REPLACE dindem WITH "KM"
         REPLACE idpartner WITH kalk->idpartner

         IF lToRacun == .T.
            REPLACE cijena WITH _g_fakt_cijena()
            REPLACE idpartner WITH cFaktPartn
         ENDIF

         SELECT KALK
         SKIP
      ENDDO

      @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je prenesen !"

      Inkey( 4 )

      @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )

   ENDDO

   BoxC()

   //my_close_all_dbf()

   RETURN .T.



// --------------------------------
// otvara tabele prenosa
// --------------------------------
STATIC FUNCTION _o_tables()

   //o_fakt_doks()
   //o_roba()
   //o_rj()
   // o_kalk()
   //o_fakt()
   select_o_fakt_pripr()
   o_sifk()
   o_sifv()
   //o_partner()

   RETURN .T.



// -------------------------------------
// vraca cijenu za fakturu
// -------------------------------------
STATIC FUNCTION _g_fakt_cijena()

   LOCAL nCijena := kalk->fcj

   IF rj->tip == "V1"
      nCijena := roba->vpc
   ELSEIF rj->tip == "V2"
      nCijena := roba->vpc2
   ELSEIF rj->tip == "M1"
      nCijena := roba->mpc
   ELSEIF rj->tip == "M2"
      nCijena := roba->mpc2
   ELSEIF rj->tip == "M3"
      nCijena := roba->mpc3
   ELSE
      nCijena := roba->vpc
   ENDIF

   RETURN nCijena


// --------------------------------------------------
// setuje broj fakture
// --------------------------------------------------
STATIC FUNCTION _set_brdok( cIdRj, cTip, cBroj )

   // daj novi broj fakture....
   cBroj := PadR( Replicate( "0", gNumDio ), 8 )

   RETURN .T.



// ----------------------------------------------------
// vraca tip dokumenta fakt na osnovu kalk tipa
// ----------------------------------------------------
STATIC FUNCTION _g_fakt_type( cKalkType )

   LOCAL xType := "01"

   DO CASE
   CASE cKalkType == "10"
      xType := "01"
   CASE cKalkType == "11"
      xType := "12"
   CASE cKalkType == "14"
      xType := "10"
   ENDCASE

   RETURN xType




// -------------------------------------------------
// prenos kalk -> fakt period
// -------------------------------------------------
FUNCTION kalkp_2_fakt()

   LOCAL lFirst
   LOCAL cFaktPartn

   _o_tables()

   SELECT fakt_pripr
   SET ORDER TO TAG "3"
   // idfirma+idroba+rbr

   cIdFirma   := self_organizacija_id()
   dOd := Date()
   dDo := Date()
   dDatPl := Date()
   cIdPartner := Space( LEN_PARTNER_ID )
   cFaktPartn := cIdPartner
   qqIdVd     := PadR( "41;", 40 )
   cIdTipDok  := "11"

   // SELECT kalk
   // SET ORDER TO TAG "7" //  "7", "idroba+idvd"

   Box( "#KALK->FAKT za partnera", 17, 75 )

   DO WHILE .T.

      @ form_x_koord() + 1, form_y_koord() + 2 SAY "Firma/RJ:"

      IF gNW == "N"
         @ form_x_koord() + 1, Col() + 1 GET cIdFirma PICT "@!"
      ELSE
         @ form_x_koord() + 1, Col() + 1 SAY cIdFirma PICT "@!"
      ENDIF

      @ form_x_koord() + 2, form_y_koord() + 2 SAY "Kalk partner" GET cIdPartner  VALID p_partner( @cIdPartner )
      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Vrste KALK dokumenata" GET qqIdVd PICT "@!S30"
      @ form_x_koord() + 4, form_y_koord() + 2 SAY "Za period od" GET dOd
      @ form_x_koord() + 4, Col() + 1 SAY "do" GET dDo

      cTipFakt := cIdTipDok
      cBrFakt  := Space( 8 )
      cIdRj    := cIdFirma

      @ form_x_koord() + 6, form_y_koord() + 2 SAY "Broj dokumenta u modulu FAKT: "
      @ form_x_koord() + 6, Col() + 1 GET cIdRJ PICT "@!"
      @ form_x_koord() + 6, Col() + 2 SAY "-" GET cTipFakt
      @ form_x_koord() + 6, Col() + 2 SAY "-" GET cBrFakt WHEN SljedBrFakt()

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      lToRacun := .F.

      IF ( cTipFakt == "10" ) .AND. ( "10" $ qqIdVd )
         lToRacun := .T.
      ENDIF

      IF lToRacun == .T.
         @ form_x_koord() + 8, form_y_koord() + 2 SAY "Fakturisati partneru" GET cFaktPartn VALID p_partner( @cFaktPartn )
         READ
         IF LastKey() == K_ESC
            EXIT
         ENDIF
      ENDIF

      IF ( aUsl1 := Parsiraj( qqIdVd, "IDVD" ) ) == NIL
         LOOP
      ENDIF

      IF find_fakt_dokument( cIdRj, cTipFakt, cBrFakt )
         Beep( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "U FAKT vec postoji ovaj dokument !"
         Inkey( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 37 )
         LOOP
      ENDIF
      seek_fakt( cIdRj, cTipFakt, cBrFakt )

/*
      SELECT KALK

      cFilter := "idfirma == cIdFirma"
      cFilter += ".and."
      cFilter += "datdok >= dOd"
      cFilter += ".and."
      cFilter += "datdok <= dDo"
      cFilter += ".and."
      cFilter += "idpartner == cIdPartner"

      IF !Empty( qqIdVd )
         cFilter += ".and." + aUsl1
      ENDIF

      SET FILTER TO &cFilter
      GO TOP
*/

      find_kalk_za_period( cIdFirma, NIL, cIdPartner, NIL, dOd, dDo )
      cFilter := "idfirma == cIdFirma"
      IF !Empty( qqIdVd )
         cFilter += ".and." + aUsl1
      ENDIF
      SET FILTER TO &cFilter
      GO TOP

      IF Eof()
         Beep( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Trazeno ne postoji u KALK-u !"
         Inkey( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 30 )
         LOOP
      ELSE

         IF lToRacun == .T.
            select_o_partner( cFaktPartn )
         ELSE
            select_o_partner( cIdPartner )
         ENDIF

         nRokPl := 0

         IF lToRacun == .T.
            nRokPl := IzSifKPartn( "ROKP", cFaktPartn, .F. )
         ELSE
            nRokPl := IzSifKPartn( "ROKP", cIdPartner, .F. )
         ENDIF

         IF ValType( nRokPl ) == "N"
            dDatPl := dDo + nRokPl
         ELSE
            nRokPl := 0
         ENDIF

         // imamo filterisan KALK, slijedi generacija FAKT iz KALK
         SELECT KALK

         lFirst := .T.

         DO WHILE !Eof()

            nKalkCijena := IF( cTipFakt $ "00#01", KALK->nc, ;
               IF( cTipFakt $ "11#27", KALK->mpcsapp, KALK->vpc ) )

            nKalkRabat := IF( cTipFakt $ "00#01", 0, KALK->rabatv )

            PRIVATE nKolicina := kalk->kolicina

            IF kalk->idvd == "11" .AND. cTipFakt = "0"
               nKolicina := -nKolicina
            ENDIF

            cArtikal := idroba
            SKIP 1

            DO WHILE !Eof() .AND. cArtikal == idroba
               nK2KalkCijena := iif( cTipFakt $ "00#01", KALK->nc, ;
                  iif( cTipFakt $ "11#27", KALK->mpcsapp, KALK->vpc ) )
               nK2KalkRabat := IF( cTipFakt $ "00#01", 0, KALK->rabatv )
               nK2Kolicina := kalk->kolicina
               IF kalk->idvd == "11" .AND. cTipFakt = "0"
                  nK2Kolicina := -nK2Kolicina
               ENDIF
               IF nKalkCijena <> nK2KalkCijena .OR. nKalkRabat <> nK2KalkRabat
                  EXIT
               ENDIF
               nKolicina += ( nK2Kolicina )
               SKIP 1
            ENDDO

            SKIP -1

            IF lFirst

               nRBr := 1


               IF lToRacun == .T.
                  select_o_partner( cFaktPartn )
               ELSE
                  select_o_partner( cIdPartner )
               ENDIF

               _Txt3a := PadR( cIdPartner + ".", 30 )
               _txt3b := _txt3c := ""
               IzSifre( .T. )

               cTxta := _txt3a
               cTxtb := _txt3b
               cTxtc := _txt3c

               @ form_x_koord() + 10, m_Y + 2 SAY "Partner " GET cTxta
               @ form_x_koord() + 11, m_Y + 2 SAY "        " GET cTxtb
               @ form_x_koord() + 12, m_Y + 2 SAY "Mjesto  " GET cTxtc

               IF nRokPl > 0
                  @ form_x_koord() + 13, m_Y + 2 SAY "Rok placanja " + AllTrim( Str( nRokPl ) ) + " dana"
               ENDIF

               READ

               cTxt := Chr( 16 ) + " " + Chr( 17 ) + ;
                  Chr( 16 ) + " " + Chr( 17 ) + ;
                  Chr( 16 ) + cTxta + Chr( 17 ) + ;
                  Chr( 16 ) + cTxtb + Chr( 17 ) + ;
                  Chr( 16 ) + cTxtc + Chr( 17 )

               cTxt += Chr( 16 ) + "" + Chr( 17 )
               cTxt += Chr( 16 ) + DToC( dDo ) + Chr( 17 )
               cTxt += Chr( 16 ) + "" + Chr( 17 )
               cTxt += Chr( 16 ) + DToC( dDatPl ) + Chr( 17 )


               lFirst := .F.

               SELECT fakt_pripr
               APPEND BLANK
               REPLACE txt WITH cTxt

            ELSE

               SELECT fakt_pripr
               HSEEK cIdFirma + KALK->idroba // fakt_pripr

               IF Found() .AND. Round( nKalkCijena - cijena, 5 ) == 0 .AND. ( cTipFakt = "0" .OR. Round( nKalkRabat - rabat, 5 ) == 0 )
                  Scatter()
                  _kolicina += nKolicina
                  my_rlock()
                  Gather()
                  my_unlock()
                  SELECT KALK
                  SKIP 1
                  LOOP
               ELSE
                  ++nRBr
                  APPEND BLANK
               ENDIF
            ENDIF

            REPLACE idfirma WITH cIdRj
            REPLACE rbr WITH Str( nRBr, 3 )
            REPLACE idtipdok WITH cTipFakt
            REPLACE brdok WITH cBrFakt
            REPLACE datdok WITH dDo
            IF lToRacun == .T.
               REPLACE idpartner WITH cFaktPartn
            ELSE
               REPLACE idpartner WITH cIdPartner
            ENDIF
            REPLACE kolicina WITH nKolicina
            REPLACE idroba WITH KALK->idroba
            REPLACE cijena WITH nKalkCijena
            REPLACE rabat WITH nKalkRabat
            REPLACE dindem WITH "KM"

            SELECT KALK
            SKIP 1

         ENDDO

         @ form_x_koord() + 15, form_y_koord() + 2 SAY "Dokument je prenesen !"
         Inkey( 4 )
         @ form_x_koord() + 15, form_y_koord() + 2 SAY Space( 30 )

         o_params()
         PRIVATE cSection := "K"
         PRIVATE cHistory := " "
         PRIVATE aHistory := {}

         WPar( "c1", cDir )
         WPar( "p1", dOd )
         WPar( "p2", dDo )
         WPar( "p3", cIdPartner )
         WPar( "p4", qqIdVd )
         WPar( "p5", cIdTipDok )

         SELECT params
         USE
         SELECT KALK
      ENDIF
   ENDDO
   Boxc()

   my_close_all_dbf()

   RETURN .T.



// -----------------------------------------
// naredni broj fakture
// -----------------------------------------
STATIC FUNCTION SljedBrFakt()

   LOCAL nArr := Select()

   IF Empty( cBrFakt )
      _datdok := dDo
      _idpartner := cIdPartner
      cBrFakt := fakt_novi_broj_dokumenta( cIdRJ, cTipFakt )
      SELECT ( nArr )
   ENDIF

   RETURN .T.
