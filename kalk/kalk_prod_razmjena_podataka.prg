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


FUNCTION prenos_fakt_kalk_prodavnica()

   PRIVATE Opc := {}
   PRIVATE opcexe := {}

   AAdd( Opc, "1. fakt 13 -> kalk 11 otpremnica maloprodaje        " )
   AAdd( opcexe, {||  fakt_13_kalk_11() } )

   AAdd( Opc, "2. fakt 11 -> kalk 41 racun maloprodaje" )
   AAdd( opcexe, {||  fakt_11_kalk_41()  } )

   AAdd( Opc, "3. fakt 11 -> kalk 42 paragon" )
   AAdd( opcexe, {||  fakt_11_kalk_42()  } )

   AAdd( Opc, "4. fakt 11 -> kalk 11 zaduzenje diskonta" )
   AAdd( opcexe, {||  fakt_11_kalk_prenos_11()  } )

   AAdd( Opc, "5. fakt 01 -> kalk 81 doprema u prod" )
   AAdd( opcexe, {||  fakt_01_kalk_81() } )

   AAdd( Opc, "6. fakt 13 -> kalk 80 prenos iz cmag. u prodavnicu" )
   AAdd( opcexe, {||  fakt_13_kalk_80()  } )
   // AAdd( Opc, "7. fakt 15 -> kalk 15 izlaz iz MP putem VP" )
   // AAdd( opcexe, {||  fakt_15_kalk_15() } )
   PRIVATE Izbor := 1
   f18_menu_sa_priv_vars_opc_opcexe_izbor( "fkpr" )
   my_close_all_dbf()

   RETURN .T.



FUNCTION fakt_11_kalk_prenos_11()

   LOCAL cIdFirma := self_organizacija_id()
   LOCAL cIdTipDok := "11"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )
   LOCAL dFaktOd := Date() - 10
   LOCAL dFaktDo := Date()
   LOCAL cArtPocinju := Space( 10 )
   LOCAL nLeftArt := 0
   LOCAL dDatKalk, cIdKonto, cIdKonto2, cIdZaduz, cIdZaduz2, cSabirati, cCjenSif
   LOCAL nX
   LOCAL cFaktBrDokumenti := Space( 150 ), cFilterBrDok
   LOCAL nPos, aDokumenti
   LOCAL aGetList := {}

   o_kalk_pripr()
   // o_koncij()
   // o_kalk()
   // o_roba()
   // o_konto()
   // o_partner()
   // o_tarifa()

   // o_fakt()
   // SET ORDER TO TAG "7" // idfirma + DTOS(datdok)
   // seek_fakt_7()

   dDatKalk := Date()

   cIdKonto := PadR( "1330", 7 )
   cIdKonto2 := PadR( "1320", 7 )

   cIdZaduz2 := Space( 6 )
   cIdZaduz := Space( 6 )

   cSabirati := gAutoCjen
   cCjenSif := "N"

   kalk_set_brkalk_za_idvd( "11", @cBrKalk )

   Box(, 15, 70 )


   DO WHILE .T.

      nRBr := 0
      nX := 1

      @ form_x_koord() + nX++, form_y_koord() + 2   SAY "Broj kalkulacije 11 -" GET cBrKalk PICT "@!"
      @ form_x_koord() + nX++, Col() + 2 SAY "Datum:" GET dDatKalk
      @ form_x_koord() + nX++, form_y_koord() + 2  SAY8 "            Magacinski konto razdužuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      @ form_x_koord() + nX++, form_y_koord() + 2  SAY8 "Prodavnički konto (diskonto) zadužuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )

      cFaktFirma := cIdFirma

      nX++

      @ form_x_koord() + nX++, form_y_koord() + 2 SAY "Brojevi dokumenata (BRDOK1;BRDOK2;)" GET cFaktBrDokumenti PICT "@!S20"
      READ
      IF LastKey() == K_ESC
         EXIT
      ENDIF


      IF Empty( cFaktBrDokumenti )
         @ form_x_koord() + nX, form_y_koord() + 2 SAY "Fakture tipa 11 u periodu od" GET dFaktOd
         @ form_x_koord() + nX++, Col() + 1 SAY "do" GET dFaktDo
      ENDIF

      @ form_x_koord() + nX++, form_y_koord() + 2 SAY8 "Uzimati MPC iz šifarnika (D/N) ?" GET cCjenSif VALID cCjenSif $ "DN" PICT "@!"
      @ form_x_koord() + nX++, form_y_koord() + 2 SAY8 "Sabirati iste artikle (D/N) ?" GET cSabirati VALID cSabirati $ "DN" PICT "@!"
      @ form_x_koord() + nX++, form_y_koord() + 2 SAY8 "Uslov za artikle koji počinju sa:" GET cArtPocinju

      READ
      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT fakt
      SET ORDER TO TAG "1"
      GO TOP

      cArtPocinju := Trim( cArtPocinju )
      nLeftArt := Len( cArtPocinju )

      IF !Empty( cFaktBrDokumenti )
         cFilterBrDok := Parsiraj( cFaktBrDokumenti, "BRDOK" )
         SET FILTER TO &cFilterBrDok
         GO TOP
      ELSE
         cFilterBrDok := ".t."
      ENDIF


      SEEK cFaktFirma + cIdTipDok

      MsgO( "Generacija podataka: " + cFaktFirma + "-" + cIdTipDok )


      aDokumenti := {}

      DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok == field->IdFirma + field->IdTipDok


         IF cFilterBrDok == ".t."
            IF fakt->datdok < dFaktOd .OR. fakt->datdok > dFaktDo // datumska provjera
               SKIP
               LOOP
            ENDIF
         ENDIF


         IF nLeftArt > 0 .AND. Left( fakt->idroba, nLeftArt ) != cArtPocinju
            SKIP
            LOOP
         ENDIF

         nPos := AScan( aDokumenti, {| cBrDok | cBrDok == fakt->brdok } )
         IF nPos == 0
            AAdd( aDokumenti, fakt->brdok )
         ENDIF

         IF AllTrim( fakt->podbr ) == "."  .OR. fakt->idroba == "U" // usluge ne prenosi takodjer
            SKIP
            LOOP
         ENDIF

         cIdRoba := fakt->idroba
         SELECT ROBA
         HSEEK cIdRoba

         cIdTar := roba->idtarifa

         SELECT tarifa
         HSEEK cIdTar

         SELECT koncij
         SEEK Trim( cIdKonto )

         PRIVATE aPorezi := {}

         cPKonto := cIdKonto

         SELECT kalk_pripr

         IF cSabirati == "D"
            SET ORDER TO TAG "4"
            SEEK cIdFirma + "11" + cIdRoba
         ELSE
            SET ORDER TO TAG "5"
            SEEK cIdFirma + "11" + cIdRoba + Str( fakt->cijena, 12, 2 )
         ENDIF

         IF !Found()

            APPEND BLANK
            REPLACE idfirma WITH cIdFirma, ;
               rbr WITH Str( ++nRbr, 3 ), ;
               idvd WITH "11", ;
               brdok WITH cBrKalk, ;
               datdok WITH dDatKalk, ;
               idtarifa WITH get_tarifa_by_koncij_region_roba_idtarifa_2_3( cPKonto, fakt->idroba, @aPorezi ), ;
               brfaktp WITH "", ;
               datfaktp WITH fakt->datdok, ;
               idkonto   WITH cPKonto, ;
               idzaduz  WITH cidzaduz, ;
               idkonto2  WITH cidkonto2, ;
               idzaduz2  WITH cidzaduz2, ;
               idroba WITH fakt->idroba, ;
               nc  WITH ROBA->nc, ;
               vpc WITH fakt->cijena, ;
               rabatv WITH fakt->rabat, ;
               mpc WITH fakt->porez, ;
               tmarza2 WITH "A", ;
               tprevoz WITH "A"

            IF cCjenSif == "D"
               REPLACE mpcsapp WITH kalk_get_mpc_by_koncij_pravilo()
            ELSE
               REPLACE mpcsapp WITH fakt->cijena
            ENDIF

         ENDIF

         my_rlock() // saberi kolicine za jedan artikal
         REPLACE kolicina WITH ( kolicina + fakt->kolicina ) // kalk_pripr

         SELECT fakt
         SKIP

      ENDDO

      MsgC()

      SELECT kalk_pripr
      SET ORDER TO TAG "1"
      GO TOP


      DO WHILE !Eof() // brisi stavke koje su kolicina = 0
         IF field->kolicina = 0
            my_rlock()
            DELETE
            my_unlock()
         ENDIF
         SKIP
      ENDDO
      GO TOP

      SELECT fakt

      @ form_x_koord() + 10, form_y_koord() + 2 SAY "KALK Dokument izgenerisan !"

      kalk_fix_brdok_add_1( @cBrKalk )
      Inkey( 4 )

      @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
      @ form_x_koord() + 10, form_y_koord() + 2 SAY Space( 40 )

      MsgBeep( "Prenos dokumenata (broj): " + AllTrim( Str( Len( aDokumenti ) ) ) )
   ENDDO

   Boxc()

   my_close_all_dbf()

   RETURN .T.




FUNCTION fakt_13_kalk_11()

   LOCAL cIdFirma := self_organizacija_id()
   LOCAL cIdTipDok := "13"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )

   o_kalk_pripr()
   // o_koncij()
   // o_kalk()
   // o_roba()
   // o_konto()
   // o_partner()
   // o_tarifa()

   // o_fakt()

   dDatKalk := Date()
   cIdKonto := PadR( "1320", 7 )
   cIdKonto2 := PadR( "1310", 7 )
   cIdZaduz2 := cIdZaduz := Space( 6 )

   cBrkalk := Space( 8 )

   kalk_set_brkalk_za_idvd( "11", @cBrKalk )


   Box(, 15, 60 )


   DO WHILE .T.

      nRBr := 0
      @ form_x_koord() + 1, form_y_koord() + 2   SAY "Broj kalkulacije 11 -" GET cBrKalk PICT "@!"
      @ form_x_koord() + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ form_x_koord() + 3, form_y_koord() + 2   SAY "Magac. konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      // IF gNW <> "X"
      // @ form_x_koord() + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. p_partner( @cIdZaduz2 )
      // ENDIF

      IF gVar13u11 == "1"
         @ form_x_koord() + 4, form_y_koord() + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      ENDIF

      // IF gNW <> "X"
      // @ form_x_koord() + 4, Col() + 2 SAY "Zaduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. p_partner( @cIdZaduz )
      // ENDIF

      cFaktFirma := cIdFirma
      @ form_x_koord() + 6, form_y_koord() + 2 SAY "Broj otpremnice u MP: " GET cFaktFirma
      @ form_x_koord() + 6, Col() + 1 SAY "- " + cidtipdok
      @ form_x_koord() + 6, Col() + 1 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF


      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )

         SELECT kalk_pripr
         LOCATE FOR BrFaktP == cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
            LOOP
         ENDIF
         IF gVar13u11 == "2"  .AND. Empty( fakt->idpartner )
            @ form_x_koord() + 10, form_y_koord() + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
            READ
         ENDIF
         GO BOTTOM
         IF brdok == cBrKalk; nRbr := Val( Rbr ); ENDIF
         SELECT fakt
         IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF
         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok
            select_o_roba( fakt->idroba )
            select_o_tarifa( roba->idtarifa )
            select_o_koncij( cIdkonto )

            SELECT fakt
            IF AllTrim( podbr ) == "."  .OR. idroba = "U"
               SKIP
               LOOP
            ENDIF

            SELECT kalk_pripr
            APPEND BLANK
            cPKonto := IF( gVar13u11 == "1", cidkonto, fakt->idpartner )
            PRIVATE aPorezi := {}
            REPLACE idfirma WITH cIdFirma, ;
               rbr     WITH Str( ++nRbr, 3 ), ;
               idvd WITH "11", ;   // izlazna faktura
               brdok WITH cBrKalk, ;
               datdok WITH dDatKalk, ;
               idtarifa WITH get_tarifa_by_koncij_region_roba_idtarifa_2_3( cPKonto, fakt->idroba, @aPorezi ), ;
               brfaktp WITH fakt->brdok, ;
               datfaktp WITH fakt->datdok, ;
               idkonto   WITH cPKonto, ;
               idzaduz  WITH cidzaduz, ;
               idkonto2  WITH cidkonto2, ;
               idzaduz2  WITH cidzaduz2, ;
               kolicina WITH fakt->kolicina, ;
               idroba WITH fakt->idroba, ;
               nc  WITH ROBA->nc, ;
               vpc WITH IF( gVar13u11 == "1", fakt->cijena, KoncijVPC() ), ;
               rabatv WITH fakt->rabat, ;
               mpc WITH fakt->porez, ;
               tmarza2 WITH "A", ;
               tprevoz WITH "A", ;
               mpcsapp WITH IF( gVar13u11 == "1", roba->mpc, fakt->cijena )

            IF gVar13u11 == "1"
               REPLACE mpcsapp WITH kalk_get_mpc_by_koncij_pravilo()
            ENDIF
            IF gVar13u11 == "2" .AND. Empty( fakt->idpartner )
               REPLACE idkonto WITH cidkonto
            ENDIF

            SELECT fakt
            SKIP
         ENDDO
         @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je prenesen !"

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )
         @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
         @ form_x_koord() + 10, form_y_koord() + 2 SAY Space( 40 )
      ENDIF

   ENDDO
   Boxc()
   my_close_all_dbf()

   RETURN .T.



/*
 *     Prenos maloprodajnih kalkulacija FAKT->KALK (11->41)
 */

FUNCTION fakt_11_kalk_41()

   PRIVATE cIdFirma := self_organizacija_id()
   PRIVATE cIdTipDok := "11"
   PRIVATE cBrDok := Space( 8 )
   PRIVATE cBrKalk := Space( 8 )
   PRIVATE cFaktFirma

   o_kalk_pripr()
   // o_kalk()
   // o_roba()
   // o_konto()
   // o_partner()
   // o_tarifa()

   // o_fakt()

   dDatKalk := Date()
   cIdKonto := PadR( "1330", 7 )
   cIdZaduz := Space( 6 )
   cBrkalk := Space( 8 )
   cZbirno := "N"
   cNac_rab := "P"

   kalk_set_brkalk_za_idvd( "41", @cBrKalk )

   Box(, 15, 60 )

   DO WHILE .T.
      nRBr := 0
      @ form_x_koord() + 1, form_y_koord() + 2 SAY "Broj kalkulacije 41 -" GET cBrKalk PICT "@!"
      @ form_x_koord() + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Konto razduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      // IF gNW <> "X"
      // @ form_x_koord() + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. p_partner( @cIdZaduz )
      // ENDIF
      @ form_x_koord() + 5, form_y_koord() + 2 SAY "Napraviti zbirnu kalkulaciju (D/N): " GET cZbirno VALID cZbirno $ "DN" PICT "@!"
      READ

      IF cZbirno == "N"

         cFaktFirma := cIdFirma

         @ form_x_koord() + 6, form_y_koord() + 2 SAY "Broj fakture: " GET cFaktFirma
         @ form_x_koord() + 6, Col() + 2 SAY "- " + cIdTipDok
         @ form_x_koord() + 6, Col() + 2 SAY "-" GET cBrDok

         READ

         IF ( LastKey() == K_ESC )
            EXIT
         ENDIF

         SELECT fakt
         SEEK cFaktFirma + cIdTipDok + cBrDok

         IF !Found()
            Beep( 4 )
            @ form_x_koord() + 14, form_y_koord() + 2 SAY "Ne postoji ovaj dokument !!"
            Inkey( 4 )
            @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 30 )
            LOOP
         ELSE

            aMemo := parsmemo( txt )

            IF Len( aMemo ) >= 5
               @ form_x_koord() + 10, form_y_koord() + 2 SAY PadR( Trim( aMemo[ 3 ] ), 30 )
               @ form_x_koord() + 11, form_y_koord() + 2 SAY PadR( Trim( aMemo[ 4 ] ), 30 )
               @ form_x_koord() + 12, form_y_koord() + 2 SAY PadR( Trim( aMemo[ 5 ] ), 30 )
            ELSE
               cTxt := ""
            ENDIF

            IF ( LastKey() == K_ESC )
               EXIT
            ENDIF

            cIdPartner := IdPartner

            @ form_x_koord() + 14, form_y_koord() + 2 SAY "Sifra partnera:" GET cIdpartner PICT "@!" VALID p_partner( @cIdPartner )

            READ

            SELECT kalk_pripr
            LOCATE FOR BrFaktP = cBrDok

            IF Found() // da li je faktura vec prenesena
               Beep( 4 )
               @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je vec prenesen !"
               Inkey( 4 )
               @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
               LOOP
            ENDIF
            GO BOTTOM
            IF brdok == cBrKalk
               nRbr := Val( Rbr )
            ENDIF
            SELECT fakt
            IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
               MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
               LOOP
            ENDIF
            DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok
               select_o_roba( fakt->idroba )
               select_o_tarifa( roba->idtarifa )

               SELECT fakt
               IF AllTrim( podbr ) == "."
                  SKIP
                  LOOP
               ENDIF

               SELECT kalk_pripr

               PRIVATE aPorezi := {}

               get_tarifa_by_koncij_region_roba_idtarifa_2_3( cIdKonto, fakt->idRoba, @aPorezi )

               nMPVBP := MpcBezPor( fakt->( kolicina * cijena ), aPorezi )

               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, ;
                  rbr WITH Str( ++nRbr, 3 ), ;
                  idvd WITH "41", ;
                  brdok WITH cBrKalk, ;
                  datdok WITH dDatKalk, ;
                  idpartner WITH cIdPartner, ;
                  idtarifa WITH ROBA->idtarifa, ;
                  brfaktp WITH fakt->brdok, ;
                  datfaktp WITH fakt->datdok, ;
                  idkonto WITH cidkonto, ;
                  idzaduz WITH cidzaduz, ;
                  kolicina WITH fakt->kolicina, ;
                  idroba WITH fakt->idroba, ;
                  mpcsapp WITH fakt->cijena, ;
                  tmarza2 WITH "%"

               REPLACE rabatv WITH ;
                  ( nMPVBP * fakt->rabat / ( fakt->kolicina * 100 ) ) // * 1.17

               SELECT fakt
               SKIP
            ENDDO

         ENDIF
      ELSE

         cFaktFirma := cIdFirma
         cIdTipDok := "11"
         dOdDatFakt := Date()
         dDoDatFakt := Date()

         @ form_x_koord() + 7, form_y_koord() + 2 SAY "ID firma FAKT: " GET cFaktFirma
         @ form_x_koord() + 8, form_y_koord() + 2 SAY "Datum fakture: "
         @ form_x_koord() + 8, Col() + 2 SAY "od " GET dOdDatFakt
         @ form_x_koord() + 8, Col() + 2 SAY "do " GET dDoDatFakt

         READ

         IF ( LastKey() == K_ESC )
            EXIT
         ENDIF

         SELECT fakt
         GO TOP

         DO WHILE !Eof()

            IF ( idfirma == cFaktFirma .AND. ;
                  idtipdok == cIdTipDok .AND. ;
                  datdok >= dOdDatFakt .AND. ;
                  datdok <= dDoDatFakt )

               cIdPartner := IdPartner

               @ form_x_koord() + 14, form_y_koord() + 2 SAY "Sifra partnera:" GET cIdpartner PICT "@!" VALID p_partner( @cIdPartner )

               READ

               SELECT kalk_pripr
               GO BOTTOM

               IF brdok == cBrKalk
                  nRbr := Val( Rbr )
               ENDIF

               SELECT fakt

               IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + "'==IdFirma+IdTipDok", "IDROBA", F_ROBA )
                  MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
                  LOOP
               ENDIF

               SELECT kalk_pripr

               PRIVATE aPorezi := {}

               get_tarifa_by_koncij_region_roba_idtarifa_2_3( cIdKonto, fakt->idRoba, @aPorezi )

               nMPVBP := MpcBezPor( fakt->( kolicina * cijena ), aPorezi )

               APPEND BLANK

               REPLACE idfirma WITH cIdFirma
               REPLACE rbr WITH Str( ++nRbr, 3 )
               REPLACE idvd WITH "41"
               REPLACE brdok WITH cBrKalk
               REPLACE datdok WITH dDatKalk
               REPLACE idpartner WITH cIdPartner
               REPLACE idtarifa WITH ROBA->idtarifa
               REPLACE brfaktp WITH fakt->brdok
               REPLACE datfaktp WITH fakt->datdok
               REPLACE idkonto WITH cIdKonto
               REPLACE idzaduz WITH cIdZaduz
               REPLACE kolicina WITH fakt->kolicina
               REPLACE idroba WITH fakt->idroba
               REPLACE mpcsapp WITH fakt->cijena
               REPLACE tmarza2 WITH "%"
               REPLACE rabatv WITH ;
                  ( nMPVBP * fakt->rabat / ( fakt->kolicina * 100 ) ) // * 1.17

               SELECT fakt
               SKIP
               LOOP
            ELSE
               SKIP
               LOOP
            ENDIF
         ENDDO
      ENDIF

      @ form_x_koord() + 10, form_y_koord() + 2 SAY "Dokument je prenesen !"
      @ form_x_koord() + 11, form_y_koord() + 2 SAY "Obavezno pokrenuti asistenta <opcija A> !"

      kalk_fix_brdok_add_1( @cBrKalk )

      Inkey( 0 )

      @ form_x_koord() + 10, form_y_koord() + 2 SAY Space( 30 )
      @ form_x_koord() + 11, form_y_koord() + 2 SAY Space( 40 )

   ENDDO
   Boxc()

   my_close_all_dbf()

   RETURN .T.


/*
 *     Prenos FAKT->KALK (01->81)
 */

FUNCTION fakt_01_kalk_81()

   LOCAL cIdFirma := self_organizacija_id(), cIdTipDok := "01", cBrDok := cBrKalk := Space( 8 )

   o_kalk_pripr()
   // o_kalk()
   // o_roba()
   // o_konto()
   // o_partner()
   // o_tarifa()

   // o_fakt()

   dDatKalk := Date()
   cIdKonto := PadR( "1320", 7 )
   cIdZaduz := Space( 6 )

   cBrkalk := Space( 8 )

   kalk_set_brkalk_za_idvd( "81", @cBrKalk )

   Box(, 15, 60 )


   DO WHILE .T.

      nRBr := 0
      @ form_x_koord() + 1, form_y_koord() + 2   SAY "Broj kalkulacije 81 -" GET cBrKalk PICT "@!"
      @ form_x_koord() + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ form_x_koord() + 3, form_y_koord() + 2   SAY "Konto razduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      // IF gNW <> "X"
      // @ form_x_koord() + 3, Col() + 2 SAY "Zaduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. p_partner( @cIdZaduz )
      // ENDIF

      cFaktFirma := cIdFirma
      @ form_x_koord() + 6, form_y_koord() + 2 SAY "Broj fakture: " GET cFaktFirma
      @ form_x_koord() + 6, Col() + 2 SAY "- " + cidtipdok
      @ form_x_koord() + 6, Col() + 2 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF


      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )
         IF Len( aMemo ) >= 5
            @ form_x_koord() + 10, form_y_koord() + 2 SAY PadR( Trim( amemo[ 3 ] ), 30 )
            @ form_x_koord() + 11, form_y_koord() + 2 SAY PadR( Trim( amemo[ 4 ] ), 30 )
            @ form_x_koord() + 12, form_y_koord() + 2 SAY PadR( Trim( amemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF
         cIdPartner := IdPartner
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID p_partner( @cIdPartner )
         READ

         SELECT kalk_pripr
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
            LOOP
         ENDIF
         GO BOTTOM
         IF brdok == cBrKalk; nRbr := Val( Rbr ); ENDIF
         SELECT fakt
         IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF
         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok

            select_o_roba( fakt->idroba )
            select_o_tarifa( roba->idtarifa )

            SELECT fakt
            IF AllTrim( podbr ) == "."
               skip; LOOP
            ENDIF

            SELECT kalk_pripr
            APPEND BLANK
            REPLACE idfirma WITH cIdFirma, ;
               rbr     WITH Str( ++nRbr, 3 ), ;
               idvd WITH "81", ;   // izlazna faktura
               brdok WITH cBrKalk, ;
               datdok WITH dDatKalk, ;
               idpartner WITH cIdPartner, ;
               idtarifa WITH ROBA->idtarifa, ;
               brfaktp WITH fakt->brdok, ;
               datfaktp WITH fakt->datdok, ;
               idkonto   WITH cidkonto, ;
               idzaduz  WITH cidzaduz, ;
               kolicina WITH fakt->kolicina, ;
               idroba WITH fakt->idroba, ;
               mpcsapp WITH fakt->cijena, ;
               fcj WITH fakt->cijena / ( 1 + tarifa->opp / 100 ) / ( 1 + tarifa->ppp / 100 ), ;
               tmarza2 WITH "%"

            SELECT fakt
            SKIP
         ENDDO
         @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je prenesen !"

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )
         @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
      ENDIF

   ENDDO
   Boxc()
   my_close_all_dbf()

   RETURN .T.





/*
 *     Otprema u mp->kalk (13->80) prebaci u prodajni objekt
 */

FUNCTION fakt_13_kalk_80()

   LOCAL cIdFirma := self_organizacija_id(), cIdTipDok := "13", cBrDok := cBrKalk := Space( 8 )

   o_kalk_pripr()
   // o_koncij()
   // o_kalk()
   // o_roba()
   // o_konto()
   // o_partner()
   // o_tarifa()

   // o_fakt()

   dDatKalk := Date()
   cIdKonto := PadR( "1320999", 7 )
   cIdKonto2 := PadR( "1320", 7 )
   cIdZaduz2 := cIdZaduz := Space( 6 )

   cBrkalk := Space( 8 )
   kalk_set_brkalk_za_idvd( "80", @cBrKalk )

   Box(, 15, 60 )


   DO WHILE .T.

      nRBr := 0
      @ form_x_koord() + 1, form_y_koord() + 2   SAY "Broj kalkulacije 80 -" GET cBrKalk PICT "@!"
      @ form_x_koord() + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ form_x_koord() + 3, form_y_koord() + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      // IF gNW <> "X"
      // @ form_x_koord() + 3, Col() + 2 SAY "Zaduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. p_partner( @cIdZaduz )
      // ENDIF
      @ form_x_koord() + 4, form_y_koord() + 2   SAY "CM. konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      // IF gNW <> "X"
      // @ form_x_koord() + 4, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. p_partner( @cIdZaduz2 )
      // ENDIF

      cFaktFirma := cIdFirma
      @ form_x_koord() + 6, form_y_koord() + 2 SAY "Broj otpremnice u MP: " GET cFaktFirma
      @ form_x_koord() + 6, Col() + 1 SAY "- " + cidtipdok
      @ form_x_koord() + 6, Col() + 1 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF


      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )


         SELECT kalk_pripr
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
            LOOP
         ENDIF
         IF gVar13u11 == "2"  .AND. Empty( fakt->idpartner )
            @ form_x_koord() + 10, form_y_koord() + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
            READ
         ENDIF
         GO BOTTOM
         IF brdok == cBrKalk; nRbr := Val( Rbr ); ENDIF
         SELECT fakt
         IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF
         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok

            select_o_roba( fakt->idroba )
            select_o_tarifa( roba->idtarifa )
            select_o_koncij( cIdkonto )

            SELECT fakt
            IF AllTrim( podbr ) == "."  .OR. idroba = "U"
               SKIP
               LOOP
            ENDIF

            cPKonto := cIdKonto
            PRIVATE aPorezi := {}
            cIdTarifa := get_tarifa_by_koncij_region_roba_idtarifa_2_3( cPKonto, fakt->idroba, @aPorezi )
            SELECT kalk_pripr
            APPEND BLANK
            REPLACE idfirma WITH cIdFirma, ;
               rbr     WITH Str( ++nRbr, 3 ), ;
               idvd WITH "80", ;   // izlazna faktura
               brdok WITH cBrKalk, ;
               datdok WITH dDatKalk, ;
               idtarifa WITH cIdTarifa, ;
               brfaktp WITH fakt->brdok, ;
               datfaktp WITH fakt->datdok, ;
               idkonto   WITH cidkonto2, ;
               idzaduz  WITH cidzaduz2, ;
               idkonto2  WITH cidkonto, ;
               idzaduz2  WITH cidzaduz, ;
               kolicina WITH -fakt->kolicina, ;
               idroba WITH fakt->idroba, ;
               nc WITH fakt->cijena / ( 1 + tarifa->opp / 100 ) / ( 1 + tarifa->ppp / 100 ), ;
               mpc WITH 0, ;
               tmarza2 WITH "A", ;
               tprevoz WITH "A", ;
               mpcsapp WITH fakt->cijena

            APPEND BLANK // protustavka
            REPLACE idfirma WITH cIdFirma, ;
               rbr     WITH Str( nRbr, 3 ), ;
               idvd WITH "80", ;   // izlazna faktura
               brdok WITH cBrKalk, ;
               datdok WITH dDatKalk, ;
               idtarifa WITH cIdTarifa, ;
               brfaktp WITH fakt->brdok, ;
               datfaktp WITH fakt->datdok, ;
               idkonto   WITH cidkonto, ;
               idzaduz  WITH cidzaduz, ;
               idkonto2  WITH "XXX", ;
               idzaduz2  WITH "", ;
               kolicina WITH fakt->kolicina, ;
               idroba WITH fakt->idroba, ;
               nc WITH fakt->cijena / ( 1 + tarifa->opp / 100 ) / ( 1 + tarifa->ppp / 100 ), ;
               mpc WITH 0, ;
               tmarza2 WITH "A", ;
               tprevoz WITH "A", ;
               mpcsapp WITH fakt->cijena


            SELECT fakt
            SKIP
         ENDDO
         @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je prenesen !"

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )
         @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
         @ form_x_koord() + 10, form_y_koord() + 2 SAY Space( 40 )
      ENDIF

   ENDDO
   Boxc()
   my_close_all_dbf()

   RETURN .T.





/*
 *     Izlaz iz MP putem VP, FAKT15->KALK15


FUNCTION fakt_15_kalk_15()

   LOCAL cIdFirma := self_organizacija_id(), cIdTipDok := "15", cBrDok := cBrKalk := Space( 8 )
   LOCAL dDatPl := CToD( "" )
   LOCAL fDoks2 := .F.

   o_kalk_pripr()
   o_koncij()
   o_kalk()
   IF File( KUMPATH + "DOKS2.DBF" ); fDoks2 := .T. ; o_kalk_doks2(); ENDIF
   o_roba()
   o_konto()
   o_partner()
   o_tarifa()

   o_fakt()

   dDatKalk := Date()
   cIdKonto := PadR( "1320", 7 )
   cIdKonto2 := PadR( "1310", 7 )
   cIdZaduz2 := cIdZaduz := Space( 6 )

   cBrkalk := Space( 8 )
   kalk_set_brkalk_za_idvd( "15", @cBrKalk )

   Box(, 15, 60 )



   DO WHILE .T.

      nRBr := 0
      @ form_x_koord() + 1, form_y_koord() + 2   SAY "Broj kalkulacije 15 -" GET cBrKalk PICT "@!"
      @ form_x_koord() + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ form_x_koord() + 3, form_y_koord() + 2   SAY "Magac. konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      // IF gNW <> "X"
      // @ form_x_koord() + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. p_partner( @cIdZaduz2 )
      // ENDIF
      @ form_x_koord() + 4, form_y_koord() + 2   SAY "Prodavn. konto razduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      // IF gNW <> "X"
      // @ form_x_koord() + 4, Col() + 2 SAY "Zaduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. p_partner( @cIdZaduz )
      // ENDIF

      cFaktFirma := cIdFirma
      @ form_x_koord() + 6, form_y_koord() + 2 SAY "Broj fakture: " GET cFaktFirma
      @ form_x_koord() + 6, Col() + 1 SAY "- " + cidtipdok
      @ form_x_koord() + 6, Col() + 1 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF

      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ form_x_koord() + 14, form_y_koord() + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )
         IF Len( aMemo ) >= 5
            @ form_x_koord() + 10, form_y_koord() + 2 SAY PadR( Trim( amemo[ 3 ] ), 30 )
            @ form_x_koord() + 11, form_y_koord() + 2 SAY PadR( Trim( amemo[ 4 ] ), 30 )
            @ form_x_koord() + 12, form_y_koord() + 2 SAY PadR( Trim( amemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF
         IF Len( aMemo ) >= 9
            dDatPl := CToD( aMemo[ 9 ] )
         ENDIF

         cIdPartner := Space( 6 )
         IF !Empty( idpartner )
            cIdPartner := idpartner
         ENDIF
         PRIVATE cBeze := " "
         @ form_x_koord() + 14, form_y_koord() + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID p_partner( @cIdPartner )
         @ form_x_koord() + 15, form_y_koord() + 2 SAY "<ENTER> - prenos" GET cBeze
         READ; ESC_BCR

         SELECT kalk_pripr
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
            LOOP
         ENDIF

         GO BOTTOM
         IF brdok == cBrKalk; nRbr := Val( Rbr ); ENDIF

         SELECT fakt
         IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF

         IF fdoks2
            SELECT kalk_doks2; HSEEK cidfirma + "14" + cbrkalk
            IF !Found()
               APPEND BLANK
               REPLACE idvd WITH "14", ;   // izlazna faktura
               brdok WITH cBrKalk, ;
                  idfirma WITH cidfirma
            ENDIF
            my_rlock()
            REPLACE DatVal WITH dDatPl
            my_unlock()
            SELECT fakt
         ENDIF

         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok
        --    SELECT ROBA; HSEEK fakt->idroba

        --    SELECT tarifa; HSEEK roba->idtarifa
            SELECT koncij; SEEK Trim( cidkonto )

            SELECT fakt
            IF AllTrim( podbr ) == "."  .OR. idroba = "U"
               SKIP
               LOOP
            ENDIF

            SELECT kalk_pripr
            APPEND BLANK
            REPLACE idfirma   WITH cIdFirma, ;
               rbr       WITH Str( ++nRbr, 3 ), ;
               idvd      WITH "15", ;   // izlaz iz MP putem VP
            brdok     WITH cBrKalk, ;
               datdok    WITH dDatKalk, ;
               idtarifa  WITH ROBA->idtarifa, ;
               brfaktp   WITH fakt->brdok, ;
               datfaktp  WITH fakt->datdok, ;
               idkonto   WITH cidkonto, ;
               pkonto    WITH cIdKonto, ;
               pu_i      WITH "1", ;
               idzaduz   WITH cidzaduz, ;
               idkonto2  WITH cidkonto2, ;
               mkonto    WITH cIdKonto2, ;
               mu_i      WITH "8", ;
               idzaduz2  WITH cidzaduz2, ;
               kolicina  WITH -fakt->kolicina, ;
               idroba    WITH fakt->idroba, ;
               nc        WITH ROBA->nc, ;
               vpc       WITH KoncijVPC(), ;
               rabatv    WITH fakt->rabat, ;
               mpc       WITH fakt->porez, ;
               tmarza2   WITH "A", ;
               tprevoz   WITH "R", ;
               idpartner WITH cIdPartner, ;
               mpcsapp   WITH fakt->cijena

            SELECT fakt
            SKIP
         ENDDO
         @ form_x_koord() + 8, form_y_koord() + 2 SAY "Dokument je prenesen !"

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )
         @ form_x_koord() + 8, form_y_koord() + 2 SAY Space( 30 )
         @ form_x_koord() + 10, form_y_koord() + 2 SAY Space( 40 )
      ENDIF

   ENDDO
   Boxc()
   my_close_all_dbf()

   RETURN .T.

 */


/*
   prenos fakt->kalk dokumenti tipa 11 u paragon blok kalk->42
*/

FUNCTION fakt_11_kalk_42()

   LOCAL _razl_cijene := "D"
   LOCAL _kalk_tip_dok := "42"
   LOCAL _auto_razd := 2
   LOCAL nX := 1
   LOCAL _x_dok_info := 16
   LOCAL _zbirni_prenos := "D"
   LOCAL _dat_kalk := Date()

   PRIVATE cIdFirma := self_organizacija_id()
   PRIVATE cIdTipDok := "11"
   PRIVATE cBrDok := Space( 8 )
   PRIVATE cBrKalk := Space( 8 )
   PRIVATE cFaktFirma

   cIdKonto := PadR( "1330", 7 )
   cIdKtoZad := PadR( "1330", 7 )
   cIdZaduz := Space( 6 )
   cBrkalk := Space( 8 )


   _o_prenos_tbls()

   Box(, 15, 60 )

   DO WHILE .T.

      nRBr := 0

      nX := 1

      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Generisati kalk dokument (1) 11 (2) 42 ?" GET _auto_razd PICT "9"

      READ

      IF _auto_razd == 1
         _kalk_tip_dok := "11"
      ELSE
         _kalk_tip_dok := "42"
      ENDIF

      kalk_set_brkalk_za_idvd( _kalk_tip_dok, @cBrKalk )

      ++nX
      ++nX

      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Broj kalkulacije " + _kalk_tip_dok + " -" GET cBrKalk PICT "@!"
      @ form_x_koord() + nX, Col() + 2 SAY "Datum:" GET _dat_kalk

      ++nX
      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Konto razduzuje:" GET cIdKonto ;
         PICT "@!"  VALID P_Konto( @cIdKonto )

      IF _auto_razd == 1
         @ form_x_koord() + nX, Col() + 1 SAY "zaduzuje:" GET cIdKtoZad  PICT "@!" VALID P_Konto( @cIdKtoZad )
      ENDIF

      // IF gNW <> "X"
      // @ form_x_koord() + nX, Col() + 2 SAY "Partner razduzuje:" GET cIdZaduz ;
      // PICT "@!" ;
      // VALID Empty( cIdZaduz ) .OR. p_partner( @cIdZaduz )
      // ENDIF

      ++nX
      ++nX

      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Napraviti zbirnu kalkulaciju (D/N): " ;
         GET _zbirni_prenos  VALID _zbirni_prenos $ "DN"  PICT "@!"

      ++nX

      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Razdvoji artikle razlicitih cijena (D/N): " ;
         GET _razl_cijene VALID _razl_cijene $ "DN"  PICT "@!"

      READ

      ++nX

      IF _zbirni_prenos == "N"

         cFaktFirma := cIdFirma

         @ form_x_koord() + nX, form_y_koord() + 2 SAY "Broj fakture: " GET cFaktFirma
         @ form_x_koord() + nX, Col() + 2 SAY "- " + cIdTipDok
         @ form_x_koord() + nX, Col() + 2 SAY "-" GET cBrDok

         READ

         IF ( LastKey() == K_ESC )
            EXIT
         ENDIF

         SELECT fakt
         SEEK cFaktFirma + cIdTipDok + cBrDok

         IF !Found()
            Beep( 4 )
            @ form_x_koord() + 15, form_y_koord() + 2 SAY "Ne postoji ovaj dokument !!"
            Inkey( 4 )
            @ form_x_koord() + 15, form_y_koord() + 2 SAY Space( 30 )
            LOOP
         ELSE

            aMemo := parsmemo( txt )

            IF Len( aMemo ) >= 5
               @ form_x_koord() + _x_dok_info, form_y_koord() + 2 SAY PadR( Trim( aMemo[ 3 ] ), 30 )
               @ form_x_koord() + 1 + _x_dok_info, form_y_koord() + 2 SAY PadR( Trim( aMemo[ 4 ] ), 30 )
               @ form_x_koord() + 2 + _x_dok_info, form_y_koord() + 2 SAY PadR( Trim( aMemo[ 5 ] ), 30 )
            ELSE
               cTxt := ""
            ENDIF

            IF ( LastKey() == K_ESC )
               EXIT
            ENDIF

            cIdPartner := ""

            SELECT kalk_pripr
            LOCATE FOR BrFaktP = cBrDok

            // da li je faktura vec prenesena
            IF Found()
               Beep( 4 )
               @ form_x_koord() + 15, form_y_koord() + 2 SAY "Dokument je vec prenesen !!"
               Inkey( 4 )
               @ form_x_koord() + 15, form_y_koord() + 2 SAY Space( 30 )
               LOOP
            ENDIF

            GO BOTTOM

            IF brdok == cBrKalk
               nRbr := Val( Rbr )
            ENDIF

            SELECT fakt
            IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
               MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifarniku!#Prenos nije izvrsen!" )
               LOOP
            ENDIF


            DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok

               select_o_roba( fakt->idroba )
               select_o_tarifa( roba->idtarifa )

               SELECT fakt

               IF AllTrim( podbr ) == "."
                  SKIP
                  LOOP
               ENDIF

               SELECT kalk_pripr

               PRIVATE aPorezi := {}
               get_tarifa_by_koncij_region_roba_idtarifa_2_3( cIdKonto, fakt->idRoba, @aPorezi )
               nMPVBP := MpcBezPor( fakt->( kolicina * cijena ), aPorezi )

               APPEND BLANK

               REPLACE idfirma WITH cIdFirma
               REPLACE rbr WITH Str( ++nRbr, 3 )
               REPLACE idvd WITH _kalk_tip_dok
               REPLACE brdok WITH cBrKalk
               REPLACE datdok WITH _dat_kalk
               REPLACE idpartner WITH cIdPartner
               REPLACE idtarifa WITH ROBA->idtarifa
               REPLACE brfaktp WITH fakt->brdok
               REPLACE datfaktp WITH fakt->datdok
               REPLACE idkonto WITH cidkonto
               REPLACE idzaduz WITH cidzaduz
               REPLACE kolicina WITH fakt->kolicina
               REPLACE idroba WITH fakt->idroba
               REPLACE mpcsapp WITH fakt->cijena
               REPLACE tmarza2 WITH "%"
               REPLACE rabatv WITH nMPVBP * fakt->rabat / ( fakt->kolicina * 100 )

               SELECT fakt
               SKIP

            ENDDO

         ENDIF

      ELSE

         cFaktFirma := cIdFirma
         cIdTipDok := "11"
         dOdDatFakt := Date()
         dDoDatFakt := Date()

         @ form_x_koord() + nX, form_y_koord() + 2 SAY "ID firma FAKT: " GET cFaktFirma

         ++nX

         @ form_x_koord() + nX, form_y_koord() + 2 SAY "Datum fakture: "
         @ form_x_koord() + nX, Col() + 2 SAY "od " GET dOdDatFakt
         @ form_x_koord() + nX, Col() + 2 SAY "do " GET dDoDatFakt

         READ

         IF ( LastKey() == K_ESC )
            EXIT
         ENDIF

         SELECT fakt
         GO TOP

         DO WHILE !Eof()

            IF ( field->idfirma == cFaktFirma .AND. ;
                  field->idtipdok == cIdTipDok .AND. ;
                  field->datdok >= dOdDatFakt .AND. ;
                  field->datdok <= dDoDatFakt )

               cIdPartner := ""

               SELECT kalk_pripr
               GO BOTTOM

               IF field->brdok == cBrKalk
                  nRbr := Val( Rbr )
               ENDIF

               SELECT fakt

               IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + "'==IdFirma+IdTipDok", "IDROBA", F_ROBA )
                  MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
                  LOOP
               ENDIF

               SELECT kalk_pripr
               LOCATE FOR idroba == fakt->idroba

               IF Found() .AND. ;
                     ( Round( fakt->rabat, 2 ) == 0 .AND. Round( field->rabatv, 2 ) == 0 ) .AND. ;
                     ( _razl_cijene == "N" .OR. ( _razl_cijene == "D" .AND. mpcsapp == fakt->cijena ) )

                  RREPLACE field->kolicina WITH field->kolicina + fakt->kolicina

               ELSE

                  PRIVATE aPorezi := {}

                  get_tarifa_by_koncij_region_roba_idtarifa_2_3( cIdKonto, fakt->idRoba, @aPorezi )

                  nMPVBP := MpcBezPor( fakt->( kolicina * cijena ), aPorezi )

                  APPEND BLANK

                  REPLACE idfirma WITH cIdFirma
                  REPLACE rbr WITH Str( ++nRbr, 3 )
                  REPLACE idvd WITH _kalk_tip_dok
                  REPLACE brdok WITH cBrKalk
                  REPLACE datdok WITH _dat_kalk
                  REPLACE idpartner WITH cIdPartner
                  REPLACE idtarifa WITH ROBA->idtarifa
                  REPLACE brfaktp WITH fakt->brdok
                  REPLACE datfaktp WITH fakt->datdok

                  IF _auto_razd == 1
                     REPLACE idkonto WITH cIdKtoZad
                     REPLACE idkonto2 WITH cIdKonto
                  ELSE
                     REPLACE idkonto WITH cIdKonto
                  ENDIF

                  REPLACE idzaduz WITH cIdZaduz
                  REPLACE kolicina WITH fakt->kolicina
                  REPLACE idroba WITH fakt->idroba
                  REPLACE mpcsapp WITH fakt->cijena

                  IF _auto_razd == 1
                     REPLACE tprevoz WITH "R"
                     REPLACE tmarza2 WITH "A"
                  ELSE
                     REPLACE tmarza2 WITH "%"
                  ENDIF

                  REPLACE rabatv WITH nMPVBP * fakt->rabat / ( fakt->kolicina * 100 )

               ENDIF

               SELECT fakt
               SKIP
               LOOP
            ELSE
               SKIP
               LOOP
            ENDIF
         ENDDO
      ENDIF

      @ form_x_koord() + 10, form_y_koord() + 2 SAY "Dokument je prenesen !"
      @ form_x_koord() + 11, form_y_koord() + 2 SAY "Obavezno pokrenuti asistenta <opcija A>!"

      kalk_fix_brdok_add_1( @cBrKalk )

      Inkey( 4 )

      @ form_x_koord() + 10, form_y_koord() + 2 SAY Space( 30 )
      @ form_x_koord() + 11, form_y_koord() + 2 SAY Space( 40 )

   ENDDO

   Boxc()

   my_close_all_dbf()

   RETURN .T.



// ------------------------------------------------------
// otvori tabele potrebne za prenos dokumenata
// ------------------------------------------------------
STATIC FUNCTION _o_prenos_tbls()

   o_kalk_pripr()
   // o_kalk()
   // o_roba()
   // o_konto()
   // o_partner()
   // o_tarifa()
   // o_fakt()

   RETURN .T.
