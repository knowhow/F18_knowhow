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

   AAdd( Opc, "1. fakt->kalk (13->11) otpremnica maloprodaje        " )
   AAdd( opcexe, {||  prod_fa_ka_prenos_otpr() } )

   AAdd( Opc, "2. fakt->kalk (11->41) racun maloprodaje" )
   AAdd( opcexe, {||  FaKaPrenosRacunMP()  } )

   AAdd( Opc, "3. fakt->kalk (11->42) paragon" )
   AAdd( opcexe, {||  FaKaPrenosRacunMPParagon()  } )

   AAdd( Opc, "4. fakt->kalk (11->11) racun mp u razduzenje mag." )
   AAdd( opcexe, {||  fakt_kalk_prenos_11_11()  } )

   AAdd( Opc, "5. fakt->kalk (01->81) doprema u prod" )
   AAdd( opcexe, {||  FaKaPrenos_01_doprema() } )
   AAdd( Opc, "6. fakt->kalk (13->80) prenos iz c.m. u prodavnicu" )
   AAdd( opcexe, {||  FaKaPrenos_cm_u_prodavnicu()  } )
   AAdd( Opc, "7. fakt->kalk (15->15) izlaz iz MP putem VP" )
   AAdd( opcexe, {||  FaKaPrenos_izlaz_putem_vp() } )
   PRIVATE Izbor := 1
   f18_menu_sa_priv_vars_opc_opcexe_izbor( "fkpr" )
   my_close_all_dbf()

   RETURN .T.



FUNCTION fakt_kalk_prenos_11_11()

   LOCAL cIdFirma := gFirma
   LOCAL cIdTipDok := "11"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )
   LOCAL dFaktOd := Date() - 10
   LOCAL dFaktDo := Date()
   LOCAL cArtPocinju := Space( 10 )
   LOCAL nLeftArt := 0

   o_kalk_pripr()
   o_koncij()
   // o_kalk()
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   O_FAKT

   SET ORDER TO TAG "7" // idfirma + DTOS(datdok)

   dDatKalk := Date()

   cIdKonto := PadR( "1330", 7 )
   cIdKonto2 := PadR( "1320", 7 )

   cIdZaduz2 := Space( 6 )
   cIdZaduz := Space( 6 )

   cSabirati := gAutoCjen
   cCjenSif := "N"


   kalk_set_brkalk_za_idvd( "11", @cBrKalk )

   Box(, 15, 60 )


   DO WHILE .T.

      nRBr := 0

      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 11 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2   SAY "Magac. konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      @ m_x + 4, m_y + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )

      cFaktFirma := cIdFirma

      @ m_x + 6, m_y + 2 SAY "Fakture tipa 11 u periodu od" GET dFaktOd
      @ m_x + 6, Col() + 1 SAY "do" GET dFaktDo

      @ m_x + 7, m_y + 2 SAY "Uzimati MPC iz sifrarnika (D/N) ?" GET cCjenSif VALID cCjenSif $ "DN" PICT "@!"

      @ m_x + 8, m_y + 2 SAY "Sabirati iste artikle (D/N) ?" GET cSabirati VALID cSabirati $ "DN" PICT "@!"

      @ m_x + 9, m_y + 2 SAY "Uslov za artikle koji pocinju sa:" GET cArtPocinju

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT fakt
      SET ORDER TO TAG "1"
      GO TOP

      cArtPocinju := Trim( cArtPocinju )
      nLeftArt := Len( cArtPocinju )

      SEEK cFaktFirma + cIdTipDok

      MsgO( "Generacija podataka: " + cFaktFirma + "-" + cIdTipDok )

      DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok == IdFirma + IdTipDok


         IF fakt->datdok < dFaktOd .OR. fakt->datdok > dFaktDo // datumska provjera
            SKIP
            LOOP
         ENDIF

         IF nLeftArt > 0 .AND. Left( idroba, nLeftArt ) != cArtPocinju
            SKIP
            LOOP
         ENDIF


         IF AllTrim( podbr ) == "."  .OR. idroba = "U" // usluge ne prenosi takodjer
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

            REPLACE idfirma WITH cIdFirma
            REPLACE rbr WITH Str( ++nRbr, 3 )
            REPLACE idvd WITH "11"
            REPLACE brdok WITH cBrKalk
            REPLACE datdok WITH dDatKalk
            REPLACE idtarifa WITH get_tarifa_by_koncij_region_roba_idtarifa_2_3( cPKonto, fakt->idroba, @aPorezi )
            REPLACE brfaktp WITH ""
            REPLACE datfaktp WITH fakt->datdok
            REPLACE idkonto   WITH cPKonto
            REPLACE idzaduz  WITH cidzaduz
            REPLACE idkonto2  WITH cidkonto2
            REPLACE idzaduz2  WITH cidzaduz2
            REPLACE idroba WITH fakt->idroba
            REPLACE nc  WITH ROBA->nc
            REPLACE vpc WITH fakt->cijena
            REPLACE rabatv WITH fakt->rabat
            REPLACE mpc WITH fakt->porez
            REPLACE tmarza2 WITH "A"
            REPLACE tprevoz WITH "A"

            IF cCjenSif == "D"
               REPLACE mpcsapp WITH kalk_get_mpc_by_koncij_pravilo()
            ELSE
               REPLACE mpcsapp WITH fakt->cijena
            ENDIF

         ENDIF

         my_rlock() // saberi kolicine za jedan artikal
         REPLACE kolicina WITH ( kolicina + fakt->kolicina )


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

      @ m_x + 10, m_y + 2 SAY "Dokument je prenesen !"

      kalk_fix_brdok_add_1( @cBrKalk )

      Inkey( 4 )

      @ m_x + 8, m_y + 2 SAY Space( 30 )
      @ m_x + 10, m_y + 2 SAY Space( 40 )

   ENDDO

   Boxc()
   my_close_all_dbf()

   RETURN .T.



// -----------------------------------------
// prenos 13->11
// -----------------------------------------
FUNCTION prod_fa_ka_prenos_otpr()

   LOCAL cIdFirma := gFirma
   LOCAL cIdTipDok := "13"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )

   o_kalk_pripr()
   o_koncij()
   // o_kalk()
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   O_FAKT

   dDatKalk := Date()
   cIdKonto := PadR( "1320", 7 )
   cIdKonto2 := PadR( "1310", 7 )
   cIdZaduz2 := cIdZaduz := Space( 6 )

   cBrkalk := Space( 8 )

   kalk_set_brkalk_za_idvd( "11", @cBrKalk )


   Box(, 15, 60 )


   DO WHILE .T.

      nRBr := 0
      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 11 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2   SAY "Magac. konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      //IF gNW <> "X"
        // @ m_x + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. P_Firma( @cIdZaduz2 )
      //ENDIF

      IF gVar13u11 == "1"
         @ m_x + 4, m_y + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      ENDIF

      //IF gNW <> "X"
        // @ m_x + 4, Col() + 2 SAY "Zaduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. P_Firma( @cIdZaduz )
      //ENDIF

      cFaktFirma := cIdFirma
      @ m_x + 6, m_y + 2 SAY "Broj otpremnice u MP: " GET cFaktFirma
      @ m_x + 6, Col() + 1 SAY "- " + cidtipdok
      @ m_x + 6, Col() + 1 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF


      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )

         SELECT kalk_pripr
         LOCATE FOR BrFaktP == cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
            LOOP
         ENDIF
         IF gVar13u11 == "2"  .AND. Empty( fakt->idpartner )
            @ m_x + 10, m_y + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
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
            SELECT ROBA
            HSEEK fakt->idroba

            SELECT tarifa
            HSEEK roba->idtarifa
            SELECT koncij
            SEEK Trim( cidkonto )

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
         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !"

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )
         @ m_x + 8, m_y + 2 SAY Space( 30 )
         @ m_x + 10, m_y + 2 SAY Space( 40 )
      ENDIF

   ENDDO
   Boxc()
   my_close_all_dbf()

   RETURN .T.



/* FaKaPrenosRacunMP()
 *     Prenos maloprodajnih kalkulacija FAKT->KALK (11->41)
 */

FUNCTION FaKaPrenosRacunMP()

   PRIVATE cIdFirma := gFirma
   PRIVATE cIdTipDok := "11"
   PRIVATE cBrDok := Space( 8 )
   PRIVATE cBrKalk := Space( 8 )
   PRIVATE cFaktFirma

   o_kalk_pripr()
   o_kalk()
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   O_FAKT

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
      @ m_x + 1, m_y + 2 SAY "Broj kalkulacije 41 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2 SAY "Konto razduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      //IF gNW <> "X"
        // @ m_x + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. P_Firma( @cIdZaduz )
      //ENDIF
      @ m_x + 5, m_y + 2 SAY "Napraviti zbirnu kalkulaciju (D/N): " GET cZbirno VALID cZbirno $ "DN" PICT "@!"
      READ

      IF cZbirno == "N"

         cFaktFirma := cIdFirma

         @ m_x + 6, m_y + 2 SAY "Broj fakture: " GET cFaktFirma
         @ m_x + 6, Col() + 2 SAY "- " + cIdTipDok
         @ m_x + 6, Col() + 2 SAY "-" GET cBrDok

         READ

         IF ( LastKey() == K_ESC )
            EXIT
         ENDIF

         SELECT fakt
         SEEK cFaktFirma + cIdTipDok + cBrDok

         IF !Found()
            Beep( 4 )
            @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
            Inkey( 4 )
            @ m_x + 14, m_y + 2 SAY Space( 30 )
            LOOP
         ELSE

            aMemo := parsmemo( txt )

            IF Len( aMemo ) >= 5
               @ m_x + 10, m_y + 2 SAY PadR( Trim( aMemo[ 3 ] ), 30 )
               @ m_x + 11, m_y + 2 SAY PadR( Trim( aMemo[ 4 ] ), 30 )
               @ m_x + 12, m_y + 2 SAY PadR( Trim( aMemo[ 5 ] ), 30 )
            ELSE
               cTxt := ""
            ENDIF

            IF ( LastKey() == K_ESC )
               EXIT
            ENDIF

            cIdPartner := IdPartner

            @ m_x + 14, m_y + 2 SAY "Sifra partnera:" GET cIdpartner PICT "@!" VALID P_Firma( @cIdPartner )

            READ

            SELECT kalk_pripr
            LOCATE FOR BrFaktP = cBrDok
            // da li je faktura vec prenesena
            IF Found()
               Beep( 4 )
               @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
               Inkey( 4 )
               @ m_x + 8, m_y + 2 SAY Space( 30 )
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
               SELECT ROBA
               HSEEK fakt->idroba
               SELECT tarifa
               HSEEK roba->idtarifa
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

               REPLACE rabatv with ;
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

         @ m_x + 7, m_y + 2 SAY "ID firma FAKT: " GET cFaktFirma
         @ m_x + 8, m_y + 2 SAY "Datum fakture: "
         @ m_x + 8, Col() + 2 SAY "od " GET dOdDatFakt
         @ m_x + 8, Col() + 2 SAY "do " GET dDoDatFakt

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

               @ m_x + 14, m_y + 2 SAY "Sifra partnera:" GET cIdpartner PICT "@!" VALID P_Firma( @cIdPartner )

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
               REPLACE rabatv with ;
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

      @ m_x + 10, m_y + 2 SAY "Dokument je prenesen !"
      @ m_x + 11, m_y + 2 SAY "Obavezno pokrenuti asistenta <opcija A> !"

      kalk_fix_brdok_add_1( @cBrKalk )

      Inkey( 0 )

      @ m_x + 10, m_y + 2 SAY Space( 30 )
      @ m_x + 11, m_y + 2 SAY Space( 40 )

   ENDDO
   Boxc()

   my_close_all_dbf()

   RETURN .T.


/* FaKaPrenos_01_doprema()
 *     Prenos FAKT->KALK (01->81)
 */

FUNCTION FaKaPrenos_01_doprema()

   // {
   LOCAL cIdFirma := gFirma, cIdTipDok := "01", cBrDok := cBrKalk := Space( 8 )
   o_kalk_pripr()
   o_kalk()
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   O_FAKT

   dDatKalk := Date()
   cIdKonto := PadR( "1320", 7 )
   cIdZaduz := Space( 6 )

   cBrkalk := Space( 8 )

   kalk_set_brkalk_za_idvd( "81", @cBrKalk )

   Box(, 15, 60 )


   DO WHILE .T.

      nRBr := 0
      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 81 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2   SAY "Konto razduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      //IF gNW <> "X"
      //   @ m_x + 3, Col() + 2 SAY "Zaduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. P_Firma( @cIdZaduz )
      //ENDIF

      cFaktFirma := cIdFirma
      @ m_x + 6, m_y + 2 SAY "Broj fakture: " GET cFaktFirma
      @ m_x + 6, Col() + 2 SAY "- " + cidtipdok
      @ m_x + 6, Col() + 2 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF


      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )
         IF Len( aMemo ) >= 5
            @ m_x + 10, m_y + 2 SAY PadR( Trim( amemo[ 3 ] ), 30 )
            @ m_x + 11, m_y + 2 SAY PadR( Trim( amemo[ 4 ] ), 30 )
            @ m_x + 12, m_y + 2 SAY PadR( Trim( amemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF
         cIdPartner := IdPartner
         @ m_x + 14, m_y + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID P_Firma( @cIdPartner )
         READ

         SELECT kalk_pripr
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
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
            SELECT ROBA; HSEEK fakt->idroba
            SELECT tarifa; HSEEK roba->idtarifa

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
         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !"

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )
         @ m_x + 8, m_y + 2 SAY Space( 30 )
      ENDIF

   ENDDO
   Boxc()
   my_close_all_dbf()

   RETURN .T.





/* FaKaPrenos_cm_u_prodavnicu()
 *     Otprema u mp->kalk (13->80) prebaci u prodajni objekt
 */

FUNCTION FaKaPrenos_cm_u_prodavnicu()

   // {
   LOCAL cIdFirma := gFirma, cIdTipDok := "13", cBrDok := cBrKalk := Space( 8 )

   o_kalk_pripr()
   o_koncij()
   o_kalk()
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   O_FAKT

   dDatKalk := Date()
   cIdKonto := PadR( "1320999", 7 )
   cIdKonto2 := PadR( "1320", 7 )
   cIdZaduz2 := cIdZaduz := Space( 6 )

   cBrkalk := Space( 8 )
   kalk_set_brkalk_za_idvd( "80", @cBrKalk )

   Box(, 15, 60 )


   DO WHILE .T.

      nRBr := 0
      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 80 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      //IF gNW <> "X"
      //   @ m_x + 3, Col() + 2 SAY "Zaduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. P_Firma( @cIdZaduz )
      //ENDIF
      @ m_x + 4, m_y + 2   SAY "CM. konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      //IF gNW <> "X"
      //   @ m_x + 4, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. P_Firma( @cIdZaduz2 )
      //ENDIF

      cFaktFirma := cIdFirma
      @ m_x + 6, m_y + 2 SAY "Broj otpremnice u MP: " GET cFaktFirma
      @ m_x + 6, Col() + 1 SAY "- " + cidtipdok
      @ m_x + 6, Col() + 1 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF


      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )


         SELECT kalk_pripr
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
            LOOP
         ENDIF
         IF gVar13u11 == "2"  .AND. Empty( fakt->idpartner )
            @ m_x + 10, m_y + 2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
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
            SELECT ROBA; HSEEK fakt->idroba

            SELECT tarifa; HSEEK roba->idtarifa
            SELECT koncij; SEEK Trim( cidkonto )

            SELECT fakt
            IF AllTrim( podbr ) == "."  .OR. idroba = "U"
               skip; LOOP
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
         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !"

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )
         @ m_x + 8, m_y + 2 SAY Space( 30 )
         @ m_x + 10, m_y + 2 SAY Space( 40 )
      ENDIF

   ENDDO
   Boxc()
   my_close_all_dbf()

   RETURN .T.





/* FaKaPrenos_izlaz_putem_vp()
 *     Izlaz iz MP putem VP, FAKT15->KALK15
 */

FUNCTION FaKaPrenos_izlaz_putem_vp()

   // {
   LOCAL cIdFirma := gFirma, cIdTipDok := "15", cBrDok := cBrKalk := Space( 8 )
   LOCAL dDatPl := CToD( "" )
   LOCAL fDoks2 := .F.

   o_kalk_pripr()
   o_koncij()
   o_kalk()
   IF File( KUMPATH + "DOKS2.DBF" ); fDoks2 := .T. ; o_kalk_doks2(); ENDIF
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   O_FAKT

   dDatKalk := Date()
   cIdKonto := PadR( "1320", 7 )
   cIdKonto2 := PadR( "1310", 7 )
   cIdZaduz2 := cIdZaduz := Space( 6 )

   cBrkalk := Space( 8 )
   kalk_set_brkalk_za_idvd( "15", @cBrKalk )

   Box(, 15, 60 )



   DO WHILE .T.

      nRBr := 0
      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 15 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2   SAY "Magac. konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      //IF gNW <> "X"
      //   @ m_x + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. P_Firma( @cIdZaduz2 )
      //ENDIF
      @ m_x + 4, m_y + 2   SAY "Prodavn. konto razduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      //IF gNW <> "X"
    //     @ m_x + 4, Col() + 2 SAY "Zaduzuje:" GET cIdZaduz  PICT "@!"      VALID Empty( cidzaduz ) .OR. P_Firma( @cIdZaduz )
      //ENDIF

      cFaktFirma := cIdFirma
      @ m_x + 6, m_y + 2 SAY "Broj fakture: " GET cFaktFirma
      @ m_x + 6, Col() + 1 SAY "- " + cidtipdok
      @ m_x + 6, Col() + 1 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF

      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )
         IF Len( aMemo ) >= 5
            @ m_x + 10, m_y + 2 SAY PadR( Trim( amemo[ 3 ] ), 30 )
            @ m_x + 11, m_y + 2 SAY PadR( Trim( amemo[ 4 ] ), 30 )
            @ m_x + 12, m_y + 2 SAY PadR( Trim( amemo[ 5 ] ), 30 )
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
         @ m_x + 14, m_y + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID P_Firma( @cIdPartner )
         @ m_x + 15, m_y + 2 SAY "<ENTER> - prenos" GET cBeze
         READ; ESC_BCR

         SELECT kalk_pripr
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
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
            SELECT ROBA; HSEEK fakt->idroba

            SELECT tarifa; HSEEK roba->idtarifa
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
         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !"

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )
         @ m_x + 8, m_y + 2 SAY Space( 30 )
         @ m_x + 10, m_y + 2 SAY Space( 40 )
      ENDIF

   ENDDO
   Boxc()
   my_close_all_dbf()

   RETURN .T.


// ------------------------------------------------------
// otvori tabele potrebne za prenos dokumenata
// ------------------------------------------------------
STATIC FUNCTION _o_prenos_tbls()

   o_kalk_pripr()
   o_kalk()
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA
   O_FAKT

   RETURN


// ------------------------------------------------------------------------
// prenos fakt->kalk dokumenti tipa 11 u paragon blok kalk->42
// ------------------------------------------------------------------------
FUNCTION FaKaPrenosRacunMPParagon()

   LOCAL _razl_cijene := "D"
   LOCAL _kalk_tip_dok := "42"
   LOCAL _auto_razd := 2
   LOCAL _x := 1
   LOCAL _x_dok_info := 16
   LOCAL _zbirni_prenos := "D"
   LOCAL _dat_kalk := Date()

   PRIVATE cIdFirma := gFirma
   PRIVATE cIdTipDok := "11"
   PRIVATE cBrDok := Space( 8 )
   PRIVATE cBrKalk := Space( 8 )
   PRIVATE cFaktFirma

   cIdKonto := PadR( "1330", 7 )
   cIdKtoZad := PadR( "1330", 7 )
   cIdZaduz := Space( 6 )
   cBrkalk := Space( 8 )

   // otvori tabele za prenos...
   _o_prenos_tbls()

   Box(, 15, 60 )

   DO WHILE .T.

      nRBr := 0

      _x := 1

      @ m_x + _x, m_y + 2 SAY "Generisati kalk dokument (1) 11 (2) 42 ?" GET _auto_razd PICT "9"

      READ

      IF _auto_razd == 1
         _kalk_tip_dok := "11"
      ELSE
         _kalk_tip_dok := "42"
      ENDIF

      kalk_set_brkalk_za_idvd( _kalk_tip_dok, @cBrKalk )

      ++ _x
      ++ _x

      @ m_x + _x, m_y + 2 SAY "Broj kalkulacije " + _kalk_tip_dok + " -" GET cBrKalk PICT "@!"
      @ m_x + _x, Col() + 2 SAY "Datum:" GET _dat_kalk

      ++ _x
      @ m_x + _x, m_y + 2 SAY "Konto razduzuje:" GET cIdKonto ;
         PICT "@!" ;
         VALID P_Konto( @cIdKonto )

      IF _auto_razd == 1
         @ m_x + _x, Col() + 1 SAY "zaduzuje:" GET cIdKtoZad ;
            PICT "@!" ;
            VALID P_Konto( @cIdKtoZad )
      ENDIF

      //IF gNW <> "X"
      //   @ m_x + _x, Col() + 2 SAY "Partner razduzuje:" GET cIdZaduz ;
      //      PICT "@!" ;
      //      VALID Empty( cIdZaduz ) .OR. P_Firma( @cIdZaduz )
      //ENDIF

      ++ _x
      ++ _x

      @ m_x + _x, m_y + 2 SAY "Napraviti zbirnu kalkulaciju (D/N): " ;
         GET _zbirni_prenos ;
         VALID _zbirni_prenos $ "DN" ;
         PICT "@!"

      ++ _x

      @ m_x + _x, m_y + 2 SAY "Razdvoji artikle razlicitih cijena (D/N): " ;
         GET _razl_cijene ;
         VALID _razl_cijene $ "DN" ;
         PICT "@!"

      READ

      ++ _x

      IF _zbirni_prenos == "N"

         cFaktFirma := cIdFirma

         @ m_x + _x, m_y + 2 SAY "Broj fakture: " GET cFaktFirma
         @ m_x + _x, Col() + 2 SAY "- " + cIdTipDok
         @ m_x + _x, Col() + 2 SAY "-" GET cBrDok

         READ

         IF ( LastKey() == K_ESC )
            EXIT
         ENDIF

         SELECT fakt
         SEEK cFaktFirma + cIdTipDok + cBrDok

         IF !Found()
            Beep( 4 )
            @ m_x + 15, m_y + 2 SAY "Ne postoji ovaj dokument !!"
            Inkey( 4 )
            @ m_x + 15, m_y + 2 SAY Space( 30 )
            LOOP
         ELSE

            aMemo := parsmemo( txt )

            IF Len( aMemo ) >= 5
               @ m_x + _x_dok_info, m_y + 2 SAY PadR( Trim( aMemo[ 3 ] ), 30 )
               @ m_x + 1 + _x_dok_info, m_y + 2 SAY PadR( Trim( aMemo[ 4 ] ), 30 )
               @ m_x + 2 + _x_dok_info, m_y + 2 SAY PadR( Trim( aMemo[ 5 ] ), 30 )
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
               @ m_x + 15, m_y + 2 SAY "Dokument je vec prenesen !!"
               Inkey( 4 )
               @ m_x + 15, m_y + 2 SAY Space( 30 )
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

               SELECT ROBA
               HSEEK fakt->idroba

               SELECT tarifa
               HSEEK roba->idtarifa

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

         @ m_x + _x, m_y + 2 SAY "ID firma FAKT: " GET cFaktFirma

         ++ _x

         @ m_x + _x, m_y + 2 SAY "Datum fakture: "
         @ m_x + _x, Col() + 2 SAY "od " GET dOdDatFakt
         @ m_x + _x, Col() + 2 SAY "do " GET dDoDatFakt

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

      @ m_x + 10, m_y + 2 SAY "Dokument je prenesen !"
      @ m_x + 11, m_y + 2 SAY "Obavezno pokrenuti asistenta <opcija A>!"

      kalk_fix_brdok_add_1( @cBrKalk )

      Inkey( 4 )

      @ m_x + 10, m_y + 2 SAY Space( 30 )
      @ m_x + 11, m_y + 2 SAY Space( 40 )

   ENDDO

   Boxc()

   my_close_all_dbf()

   RETURN .T.
