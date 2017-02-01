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

FUNCTION ld_pregled_plata_za_period()

   LOCAL nC1 := 20
   LOCAL i
   LOCAL cTPNaz
   LOCAL cRj := Space( 60 )
   LOCAL cRadnik := fetch_metric( "ld_izvj_radnik", my_user(), Space( LEN_IDRADNIK ) )
   LOCAL cIdRj
   LOCAL nMjesec
   LOCAL cMjesecDo
   LOCAL nGodina
   LOCAL cOpcStan := Space( 200 )
   LOCAL cKanton := Space( 200 )
   LOCAL cDoprPio := "70"
   LOCAL cDoprZdr := "80"
   LOCAL cDoprNez := "90"
   LOCAL cDoprD4 := cDoprD5 := cDoprD6 := Space( 2 )
   LOCAL cObracun := gObracun
   LOCAL cM4TipoviIzdvojitiPrimanja := fetch_metric( "ld_m4_izdvojena_primanja", NIL, Space( 100 ) )
   LOCAL nCount

   LOCAL cTotal := "N"

   napravi_pomocnu_tabelu()

   cIdRj := gLDRadnaJedinica
   nMjesec := fetch_metric( "ld_izv_mjesec_od", my_user(), gMjesec )
   nGodina := fetch_metric( "ld_izv_godina", my_user(), gGodina )
   cMjesecDo := fetch_metric( "ld_izv_mjesec_do", my_user(), nMjesec )

   otvori_tabele()

   Box( "#PREGLED PLATA ZA PERIOD", 20, 75 )

   @ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
   @ m_x + 2, m_y + 2 SAY "Za mjesece od:" GET nMjesec PICT "99"
   @ m_x + 2, Col() + 2 SAY "do:" GET cMjesecDo PICT "99" VALID cMjesecDo >= nMjesec
   @ m_x + 3, m_y + 2 SAY "Godina: " GET nGodina PICT "9999"

   IF ld_vise_obracuna()
      @ m_x + 3, Col() + 2 SAY8 "Obračun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   ENDIF

   @ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
      VALID Empty( cRadnik ) .OR. P_RADN( @cRadnik )

   @ m_x + 6, m_y + 2 SAY8 "    Općina (prazno-sve):" GET cOpcStan PICT "@S30" WHEN Empty( cRadnik )
   @ m_x + 7, m_y + 2 SAY8 "    Kanton (prazno-sve):" GET cKanton PICT "@S30" WHEN Empty( cRadnik )

   @ m_x + 9, m_y + 2 SAY8 "Dodatni doprinosi za prikaz na izvještaju: "
   @ m_x + 10, m_y + 2 SAY8 " Šifra dodatnog doprinosa 1 : " GET cDoprPio
   @ m_x + 11, m_y + 2 SAY8 " Šifra dodatnog doprinosa 2 : " GET cDoprZdr
   @ m_x + 12, m_y + 2 SAY8 " Šifra dodatnog doprinosa 3 : " GET cDoprNez
   @ m_x + 13, m_y + 2 SAY8 " Šifra dodatnog doprinosa 4 : " GET cDoprD4
   @ m_x + 14, m_y + 2 SAY8 " Šifra dodatnog doprinosa 5 : " GET cDoprD5
   @ m_x + 15, m_y + 2 SAY8 " Šifra dodatnog doprinosa 6 : " GET cDoprD6

   @ m_x + 17, m_y + 2 SAY8 "Izdvojena primanja (bolovanje, neplaceno) za M4:" GET cM4TipoviIzdvojitiPrimanja PICT "@S20"

   @ m_x + 19, m_y + 2 SAY8 "Prikazati ukupno za sve mjesece (D/N)" GET cTotal PICT "@!" VALID cTotal $ "DN"

   READ

   clvbox()

   ESC_BCR

   BoxC()


   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "ld_izvj_radnik", my_user(), cRadnik )
   set_metric( "ld_m4_izdvojena_primanja", NIL, cM4TipoviIzdvojitiPrimanja )
   set_metric( "ld_izv_mjesec_od", my_user(), nMjesec )
   set_metric( "ld_izv_godina", my_user(), nGodina )
   set_metric( "ld_izv_mjesec_do", my_user(), cMjesecDo )

   SELECT ld

   sortiraj_tabelu_ld( cRj, nGodina, nMjesec, cMjesecDo, cRadnik, cObracun )

   napuni_podatke( cRj, nGodina, nMjesec, cMjesecDo, cRadnik, ;
      cDoprPio, cDoprZdr, cDoprNez, cObracun, cDoprD4, cDoprD5, cDoprD6, ;
      cM4TipoviIzdvojitiPrimanja, cTotal, cOpcStan, cKanton )

   IF cTotal == "N"
      prikazi_pregled( cRj, nGodina, nMjesec, cMjesecDo, cRadnik, ;
         cDoprPio, cDoprZdr, cDoprNez, cDoprD4, cDoprD5, cDoprD6, cOpcStan, cKanton )
   ELSE
      prikazi_pregled_ukupno( cRj, nGodina, nMjesec, cMjesecDo, cRadnik, ;
         cDoprPio, cDoprZdr, cDoprNez, cDoprD4, cDoprD5, cDoprD6, cOpcStan, cKanton )
   ENDIF

   RETURN .T.


STATIC FUNCTION napuni_podatke( cRj, nGodina, nMjesec, cMjesecDo, ;
      cRadnik, cDoprPio, cDoprZdr, cDoprNez, cObracun, cDop4, cDop5, cDop6, ;
      cM4TipoviIzdvojitiPrimanja, cTotal, cOpcStan, cKanton )

   LOCAL i
   LOCAL cPom
   LOCAL lInRS := .F.
   LOCAL nNetoBP := 0
   LOCAL nUNetobp := 0
   LOCAL nPrimanje
   LOCAL nRadSatiM4
   LOCAL nRadIznosM4
   LOCAL nBolovanjeSatiM4
   LOCAL nBolovanjeIznosM4

   IF cTotal == nil
      cTotal := "N"
   ENDIF

   SELECT ld

   DO WHILE !Eof()

      IF !filter_opcina_kanton( ld->idradn, cOpcStan, cKanton )
         SKIP
         LOOP
      ENDIF

      IF ld_date( ld->godina, ld->mjesec ) < ld_date( nGodina, nMjesec )
         SKIP
         LOOP
      ENDIF

      IF ld_date( ld->godina, ld->mjesec ) > ld_date( nGodina, cMjesecdo )
         SKIP
         LOOP
      ENDIF

      cT_radnik := field->idradn

      lInRS := radnik_iz_rs( radn->idopsst, radn->idopsrad )

      IF !Empty( cRadnik )
         IF cT_radnik <> cRadnik
            SKIP
            LOOP
         ENDIF
      ENDIF

      cTipRada := get_ld_rj_tip_rada( ld->idradn, ld->idrj )
      cOpor := g_oporeziv( ld->idradn, ld->idrj )

      // samo pozicionira bazu PAROBR na odgovarajuci zapis
      ParObr( ld->mjesec, ld->godina, IF( ld_vise_obracuna(), ld->obr, ), ld->idrj )

      select_o_radn( cT_radnik )

      cT_rnaziv := AllTrim( radn->ime ) + " " + AllTrim( radn->naz )

      SELECT ld

      nSati := 0
      nR_sati := 0
      nB_sati := 0
      nNeto := 0
      nR_neto := 0
      nB_neto := 0
      nUNeto := 0
      nPrim := 0
      nBruto := 0
      nUDopIz := 0
      nIDoprPio := 0
      nIDoprZdr := 0
      nIDoprNez := 0
      nIDoprD4 := 0
      nIDoprD5 := 0
      nIDoprD6 := 0
      nOdbici := 0
      nL_odb := 0
      nPorez := 0
      nIsplata := 0
      nUNetobp := 0
      nRadSatiM4 := 0
      nRadIznosM4 := 0
      nBolovanjeSatiM4 := 0
      nBolovanjeIznosM4 := 0
      nURad_izn := 0
      nUBol_izn := 0
      nUkRadnihSati := 0
      nUkBolovanjeSati := 0

      DO WHILE !Eof() .AND. field->idradn == cT_radnik

         IF !filter_opcina_kanton( ld->idradn, cOpcStan, cKanton )
            SKIP
            LOOP
         ENDIF

         IF ld_date( field->godina, field->mjesec ) < ;
               ld_date( nGodina, nMjesec )
            SKIP
            LOOP
         ENDIF

         IF ld_date( field->godina, field->mjesec ) > ;
               ld_date( nGodina, cMjesecdo )
            SKIP
            LOOP
         ENDIF

         nF_mj := field->mjesec
         nF_god := field->godina

         cObr_za := AllTrim( Str( ld->mjesec ) ) + "/" + AllTrim( Str( ld->godina ) )

         cId_rj := ld->idrj


         cTipRada := get_ld_rj_tip_rada( ld->idradn, ld->idrj ) // uvijek provjeri tip rada, ako ima vise obracuna
         cTrosk := radn->trosk

         ParObr( ld->mjesec, ld->godina, iif( ld_vise_obracuna(), ld->obr, ), ld->idrj )

         nPrKoef := 0


         IF cTipRada == "S" // propisani koeficijent
            nPrKoef := radn->sp_koef
         ENDIF


         nBolovanjeIznosM4 := 0 // bolovanje iznosi, sati
         nBolovanjeSatiM4 := 0

         nRadIznosM4 := 0 // redovan rad iznos, sati
         nRadSatiM4 := 0

         sum_primanja_za_tipove_primanja( cM4TipoviIzdvojitiPrimanja, @nBolovanjeIznosM4, @nBolovanjeSatiM4 )


         nPrim += field->uneto // primanja
         nOdbici += field->uodbici // odbici
         nSati += field->usati
         nIsplata += field->uiznos // isplata
         nLOdbitak := field->ulicodb // licni odbitak
         nL_odb += nLOdbitak


         IF ( nBolovanjeIznosM4 != 0 ) .OR. ( nBolovanjeSatiM4 != 0 )  // radni sati ukupni
            nRadSatiM4 := ( field->usati - nBolovanjeSatiM4 )
            nRadIznosM4 := ( field->uneto - nBolovanjeIznosM4 )
         ELSE
            nRadSatiM4 := ( field->usati )
            nRadIznosM4 := ( field->uneto )
         ENDIF


         nUkRadnihSati += nRadSatiM4 // totali za bolovanje i radne sate
         nUkBolovanjeSati += nBolovanjeSatiM4


         nBrutoST := bruto_osn( ld->uneto, cTipRada, ld->ulicodb, nPrKoef, cTrosk ) // bruto sa troskovima
         nBr_bol := bruto_osn( nBolovanjeIznosM4, cTipRada, ld->ulicodb, nPrKoef, cTrosk ) // bruto bolovanja
         nBr_rad := bruto_osn( nRadIznosM4, cTipRada, ld->ulicodb, nPrKoef, cTrosk )  // bruto rada

         nTrosk := 0


         IF cTipRada == "U" .AND. cTrosk <> "N" // ugovori o djelu

            nTrosk := ROUND2( nBrutoST * ( gUgTrosk / 100 ), gZaok2 )

            IF lInRs == .T.
               nTrosk := 0
            ENDIF

         ENDIF


         IF cTipRada == "A" .AND. cTrosk <> "N" // autorski honorar

            nTrosk := ROUND2( nBrutoST * ( gAhTrosk / 100 ), gZaok2 )

            IF lInRs == .T.
               nTrosk := 0
            ENDIF

         ENDIF


         nBrPoj := nBrutoST - nTrosk // bruto pojedinacno za radnika

         nMBrutoST := nBrPoj

         IF calc_mbruto() // minimalni bruto
            nMBrutoST := min_bruto( nBrPoj, ld->usati )
         ENDIF

         nBruto += nBrPoj // ukupni bruto


         nDoprIz := u_dopr_iz( nMBrutoST, cTipRada ) // ukupno dopr iz 31%
         nUDopIz += nDoprIz


         nDop_rad := u_dopr_iz( nBr_rad, cTipRada ) // doprinos za bol i rad
         nDop_bol := u_dopr_iz( nBr_bol, cTipRada )

         nURad_izn += ( nBr_rad - nDop_rad )
         nUBol_izn += ( nBr_bol - nDop_bol )


         nPorOsnP := ( nBrPoj - nDoprIz ) - nLOdbitak // osnovica za porez

         IF nPorOsnP < 0 .OR. !radn_oporeziv( ld->idradn, ld->idrj )
            nPorOsnP := 0
         ENDIF


         nPorPoj := izr_porez( nPorOsnP, "B" ) // porez je
         nPorez += nPorPoj


         nNetoBp := ( nBrPoj - nDoprIz ) // neto bez poreza
         nNeto := ( nBrPoj - nDoprIz - nPorPoj ) // neto isplata
         nNeto := min_neto( nNeto, ld->usati )  // minimalni neto uslov

         nUNeto += nNeto
         nUNetobp += nNetoBp


         IF !Empty( cDoprPio ) // ocitaj doprinose, njihove iznose
            nDoprPIO := get_dopr( cDoprPIO, cTipRada )
            nIDoprPIO += round2( nMBrutoST * nDoprPIO / 100, gZaok2 )
         ENDIF

         IF !Empty( cDoprZdr )
            nDoprZDR := get_dopr( cDoprZDR, cTipRada )
            nIDoprZDR += round2( nMBrutoST * nDoprZDR / 100, gZaok2 )
         ENDIF

         IF !Empty( cDoprNez )
            nDoprNEZ := get_dopr( cDoprNEZ, cTipRada )
            nIDoprNEZ += round2( nMBrutoST * nDoprNEZ / 100, gZaok2 )
         ENDIF

         IF !Empty( cDop4 )
            nDoprD4 := get_dopr( cDop4, cTipRada )
            nIDoprD4 += round2( nMBrutoST * nDoprD4 / 100, gZaok2 )
         ENDIF
         IF !Empty( cDop4 )
            nDoprD5 := get_dopr( cDop5, cTipRada )
            nIDoprD5 += round2( nMBrutoST * nDoprD5 / 100, gZaok2 )
         ENDIF
         IF !Empty( cDop4 )
            nDoprD6 := get_dopr( cDop6, cTipRada )
            nIDoprD6 += round2( nMBrutoST * nDoprD6 / 100, gZaok2 )
         ENDIF

         IF cTotal == "N"
            dodaj_u_pomocnu_tabelu( nF_god, ;
               nF_mj, ;
               cT_radnik, ;
               cId_rj, ;
               cObr_za, ;
               cT_rnaziv, ;
               nSati, ;
               nUkRadnihSati, ;
               nUkBolovanjeSati, ;
               nPrim, ;
               nBruto, ;
               nUDopIZ, ;
               nIDoprPIO, ;
               nIDoprZDR, ;
               nIDoprNEZ, ;
               0, ;
               nL_Odb, ;
               nPorez, ;
               nUNetobp, ;
               nUNeto, ;
               nURad_izn, ;
               nUBol_izn, ;
               nOdbici, ;
               nIsplata, ;
               nIDoprD4, ;
               nIDoprD5, ;
               nIDoprD6 )

            // resetuj varijable
            nSati := 0
            nR_sati := 0
            nB_sati := 0
            nNeto := 0
            nR_neto := 0
            nB_neto := 0
            nUNeto := 0
            nPrim := 0
            nBruto := 0
            nUDopIz := 0
            nIDoprPio := 0
            nIDoprZdr := 0
            nIDoprNez := 0
            nIDoprD4 := 0
            nIDoprD5 := 0
            nIDoprD6 := 0
            nOdbici := 0
            nL_odb := 0
            nPorez := 0
            nIsplata := 0
            nUNetobp := 0
            nRadSatiM4 := 0
            nRadIznosM4 := 0
            nBolovanjeSatiM4 := 0
            nBolovanjeIznosM4 := 0
            nURad_izn := 0
            nUBol_izn := 0
            nUkRadnihSati := 0
            nUkBolovanjeSati := 0

         ENDIF

         SELECT ld
         SKIP

      ENDDO

      IF cTotal == "D"
         dodaj_u_pomocnu_tabelu( 0, 0, cT_radnik, ;
            cId_rj, ;
            cObr_za, ;
            cT_rnaziv, ;
            nSati, ;
            nUkRadnihSati, ;
            nUkBolovanjeSati, ;
            nPrim, ;
            nBruto, ;
            nUDopIZ, ;
            nIDoprPIO, ;
            nIDoprZDR, ;
            nIDoprNEZ, ;
            0, ;
            nL_Odb, ;
            nPorez, ;
            nUNetobp, ;
            nUNeto, ;
            nURad_izn, ;
            nUBol_izn, ;
            nOdbici, ;
            nIsplata, ;
            nIDoprD4, ;
            nIDoprD5, ;
            nIDoprD6 )
      ENDIF

   ENDDO

   RETURN .T.


FUNCTION sum_primanja_za_tipove_primanja( cM4TipoviIzdvojitiPrimanja, nBolovanjeIznosM4, nBolovanjeSatiM4 )

   LOCAL nPrimanje, cPom

   IF !Empty( cM4TipoviIzdvojitiPrimanja )
      FOR nPrimanje := 1 TO 60
         cPom := PadL( AllTrim( Str( nPrimanje ) ), 2, "0" )
         IF cPom $ cM4TipoviIzdvojitiPrimanja .AND. ( ld->( FieldPos( "I" + cPom ) ) != 0 )
            nBolovanjeIznosM4 += iif( cPom $ cM4TipoviIzdvojitiPrimanja, LD->&( "I" + cPom ), 0 )
            nBolovanjeSatiM4 += iif( cPom $ cM4TipoviIzdvojitiPrimanja, LD->&( "S" + cPom ), 0 )
         ENDIF
      NEXT
   ENDIF

   RETURN .T.


STATIC FUNCTION prikazi_pregled( cRj, nGodina, cMjOd, cMjDo, cRadnik, ;
      cDop1, cDop2, cDop3, cDop4, cDop5, cDop6, cOpcina, cKanton )

   LOCAL cT_radnik := ""
   LOCAL cLine := ""

   O_R_EXP
   SELECT r_export
   GO TOP

   START PRINT CRET
   ?
   ? "#%LANDS#"
   P_COND2

   pregled_zaglavlje( cRj, nGodina, cMjOd, cMjDo, cRadnik, cOpcina, cKanton )

   cLine := pregled_header( cRadnik, cDop1, cDop2, cDop3, cDop4, cDop5, cDop6 )

   nUSati := 0
   nUNeto := 0
   nUNetoBP := 0
   nUPrim := 0
   nUBruto := 0
   nUDoprPio := 0
   nUDoprZdr := 0
   nUDoprNez := 0
   nUDoprD4 := 0
   nUDoprD5 := 0
   nUDoprD6 := 0
   nUDoprIZ := 0
   nUPorez := 0
   nUOdbici := 0
   nULicOdb := 0
   nUIsplata := 0
   nUkRadnihSati := 0
   nUkRadIznos := 0
   nUkBolovanjeSati := 0
   nUkBolovanjeIznos := 0

   nRbr := 0
   nPoc := 10
   nCount := 0

   DO WHILE !Eof()

      ? Str( ++nRbr, 4 ) + "."

      IF !Empty( cRadnik )
         @ PRow(), PCol() + 1 SAY PadR( field->obr_za, 7 )
      ELSE
         @ PRow(), PCol() + 1 SAY PadR( field->idradn, 7 )
      ENDIF

      @ PRow(), PCol() + 1 SAY field->naziv

      @ PRow(), nPoc := PCol() + 1 SAY Str( field->sati, 12, 2 )
      nUSati += field->sati

      @ PRow(), PCol() + 1 SAY Str( field->prim, 12, 2 )
      nUPrim += field->prim

      @ PRow(), PCol() + 1 SAY Str( bruto, 12, 2 )
      nUBruto += field->bruto

      @ PRow(), PCol() + 1 SAY Str( field->dop_iz, 12, 2 )
      nUDoprIz += field->dop_iz

      @ PRow(), PCol() + 1 SAY Str( field->l_odb, 12, 2 )
      nULicOdb += field->l_odb

      @ PRow(), PCol() + 1 SAY Str( field->izn_por, 12, 2 )
      nUPorez += field->izn_por

      @ PRow(), nNBP_pt := PCol() + 1 SAY Str( field->netobp, 12, 2 )
      nUNetobp += field->netobp

      @ PRow(), PCol() + 1 SAY Str( field->neto, 12, 2 )
      nUNeto += field->neto

      @ PRow(), PCol() + 1 SAY Str( field->odbici, 12, 2 )
      nUOdbici += field->odbici

      @ PRow(), PCol() + 1 SAY Str( field->isplata, 12, 2 )
      nUIsplata += field->isplata

      IF !Empty( cDop1 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_pio, 12, 2 )
         nUDoprPio += field->dop_pio
      ENDIF

      IF !Empty( cDop2 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_zdr, 12, 2 )
         nUDoprZdr += field->dop_zdr
      ENDIF

      IF !Empty( cDop3 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_nez, 12, 2 )
         nUDoprNez += field->dop_nez
      ENDIF

      IF !Empty( cDop4 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_4, 12, 2 )
         nUDoprD4 += field->dop_4
      ENDIF

      IF !Empty( cDop5 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_5, 12, 2 )
         nUDoprD5 += field->dop_5
      ENDIF

      IF !Empty( cDop6 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_6, 12, 2 )
         nUDoprD6 += field->dop_6
      ENDIF

      IF ( field->b_neto != 0 .OR. field->b_sati != 0 ) // ovo je za drugi red izvjestaja, redovan rad
         ?
         @ PRow(), nPoc - 3 SAY "r: " + Str( field->r_sati, 12, 2 )
         @ PRow(), nNBP_pt SAY Str( field->r_neto, 12, 2 )

         nUkRadnihSati += field->r_sati
         nUkRadIznos += field->r_neto


         ?
         @ PRow(), nPoc - 3 SAY "b: " + Str( field->b_sati, 12, 2 ) // bolovanja
         @ PRow(), nNBP_pt SAY Str( field->b_neto, 12, 2 )

         nUkBolovanjeSati += field->b_sati
         nUkBolovanjeIznos += field->b_neto

      ELSE
         nUkRadnihSati += field->sati
         nUkRadIznos += field->netobp
      ENDIF

      ++nCount

      SKIP
   ENDDO

   ? cLine

   ? "UKUPNO:"
   @ PRow(), nPoc SAY Str( nUSati, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nUPrim, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nUBruto, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nUDoprIz, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nULicOdb, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nUPorez, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nUNetoBP, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nUNeto, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nUOdbici, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nUIsplata, 12, 2 )

   IF !Empty( cDop1 )
      @ PRow(), PCol() + 1 SAY Str( nUDoprPio, 12, 2 )
   ENDIF

   IF !Empty( cDop2 )
      @ PRow(), PCol() + 1 SAY Str( nUDoprZdr, 12, 2 )
   ENDIF

   IF !Empty( cDop3 )
      @ PRow(), PCol() + 1 SAY Str( nUDoprNez, 12, 2 )
   ENDIF

   IF !Empty( cDop4 )
      @ PRow(), PCol() + 1 SAY Str( nUDoprD4, 12, 2 )
   ENDIF

   IF !Empty( cDop5 )
      @ PRow(), PCol() + 1 SAY Str( nUDoprD5, 12, 2 )
   ENDIF

   IF !Empty( cDop6 )
      @ PRow(), PCol() + 1 SAY Str( nUDoprD6, 12, 2 )
   ENDIF


   IF ( nUkBolovanjeIznos <> 0 ) // ako ima bolovanja

      // redovan rad
      ?
      @ PRow(), nPoc - 3 SAY "r: " + Str( nUkRadnihSati, 12, 2 )
      @ PRow(), nNBP_pt SAY Str( nUkRadIznos, 12, 2 )

      // bolovanja
      ?
      @ PRow(), nPoc - 3 SAY "b: " + Str( nUkBolovanjeSati, 12, 2 )
      @ PRow(), nNBP_pt SAY Str( nUkBolovanjeIznos, 12, 2 )

   ENDIF

   ? cLine

   FF
   ENDPRINT

   RETURN .T.



STATIC FUNCTION prikazi_pregled_ukupno( cRj, nGodina, cMjOd, cMjDo, cRadnik, ;
      cDop1, cDop2, cDop3, cDop4, cDop5, cDop6, cOpcina, cKanton )

   LOCAL cT_radnik := ""
   LOCAL cLine := ""

   O_R_EXP
   SELECT r_export
   INDEX ON Str( godina, 4 ) + Str( mjesec, 2 ) TO "1"
   GO TOP

   START PRINT CRET
   ?
   ? "#%LANDS#"
   P_COND2

   pregled_zaglavlje( cRj, nGodina, cMjOd, cMjDo, cRadnik, cOpcina, cKanton )

   cLine := pregled_header( cRadnik, cDop1, cDop2, cDop3, cDop4, cDop5, cDop6 )

   nUSati := 0
   nUNeto := 0
   nUNetoBP := 0
   nUPrim := 0
   nUBruto := 0
   nUDoprPio := 0
   nUDoprZdr := 0
   nUDoprNez := 0
   nUDoprD4 := 0
   nUDoprD5 := 0
   nUDoprD6 := 0
   nUDoprIZ := 0
   nUPorez := 0
   nUOdbici := 0
   nULicOdb := 0
   nUIsplata := 0
   nUkRadnihSati := 0
   nUkRadIznos := 0
   nUkBolovanjeSati := 0
   nUkBolovanjeIznos := 0

   nTUSati := 0
   nTUNeto := 0
   nTUNetoBP := 0
   nTUPrim := 0
   nTUBruto := 0
   nTUDoprPio := 0
   nTUDoprZdr := 0
   nTUDoprNez := 0
   nTUDoprD4 := 0
   nTUDoprD5 := 0
   nTUDoprD6 := 0
   nTUDoprIZ := 0
   nTUPorez := 0
   nTUOdbici := 0
   nTULicOdb := 0
   nTUIsplata := 0
   nTUR_sati := 0
   nTUR_izn := 0
   nTUB_sati := 0
   nTUB_izn := 0

   nRbr := 0
   nPoc := 10
   nCount := 0

   DO WHILE !Eof()

      nSeek_god := field->godina
      nSeek_mj := field->mjesec

      nUSati := 0
      nUPrim := 0
      nUBruto := 0
      nUDoprIz := 0
      nULicOdb := 0
      nUPorez := 0
      nUNetobp := 0
      nUNeto := 0
      nUOdbici := 0
      nUIsplata := 0
      nUDoprPio := 0
      nUDoprZdr := 0
      nUDoprNez := 0
      nUDoprD4 := 0
      nUDoprD5 := 0
      nUDoprD6 := 0
      nUkRadnihSati := 0
      nUkRadIznos := 0
      nUkBolovanjeSati := 0
      nUkBolovanjeIznos := 0

      DO WHILE !Eof() .AND. field->godina = nSeek_god .AND. field->mjesec = nSeek_mj

         nUSati += sati
         nUPrim += prim
         nUBruto += bruto
         nUDoprIz += dop_iz
         nULicOdb += l_odb
         nUPorez += izn_por
         nUNetobp += netobp
         nUNeto += neto
         nUOdbici += odbici
         nUIsplata += isplata
         nUDoprPio += dop_pio
         nUDoprZdr += dop_zdr
         nUDoprNez += dop_nez
         nUDoprD4 += dop_4
         nUDoprD5 += dop_5
         nUDoprD6 += dop_6

         IF ( field->b_neto <> 0 )
            nUkRadnihSati += field->r_sati
            nUkRadIznos += field->r_neto
            nUkBolovanjeSati += field->b_sati
            nUkBolovanjeIznos += field->b_neto

         ELSE
            nUkRadnihSati += field->sati
            nUkRadIznos += field->netobp
         ENDIF

         SKIP
      ENDDO

      ? Str( ++nRbr, 4 ) + "."

      @ PRow(), PCol() + 1 SAY PadR( AllTrim( Str( nSeek_god, 4 ) ), 7 )

      @ PRow(), PCol() + 1 SAY PadR( ld_naziv_mjeseca( nSeek_mj, nSeek_god, .F., .T. ), 20 )

      @ PRow(), nPoc := PCol() + 1 SAY Str( nUSati, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( nUPrim, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( nUBruto, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( nUDopriz, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( nULicOdb, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( nUPorez, 12, 2 )

      @ PRow(), nNBP_pt := PCol() + 1 SAY Str( nUNetobp, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( nUNeto, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( nUOdbici, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( nUIsplata, 12, 2 )

      IF !Empty( cDop1 )
         @ PRow(), PCol() + 1 SAY Str( nUDoprPio, 12, 2 )
      ENDIF

      IF !Empty( cDop2 )
         @ PRow(), PCol() + 1 SAY Str( nUDoprZdr, 12, 2 )
      ENDIF

      IF !Empty( cDop3 )
         @ PRow(), PCol() + 1 SAY Str( nUDoprNez, 12, 2 )
      ENDIF

      IF !Empty( cDop4 )
         @ PRow(), PCol() + 1 SAY Str( nUDoprD4, 12, 2 )
      ENDIF

      IF !Empty( cDop5 )
         @ PRow(), PCol() + 1 SAY Str( nUDoprD5, 12, 2 )
      ENDIF

      IF !Empty( cDop6 )
         @ PRow(), PCol() + 1 SAY Str( nUDoprD6, 12, 2 )
      ENDIF

      nTUSati += nUsati
      nTUPrim += nUprim
      nTUBruto += nUbruto
      nTUDoprIz += nUdopriz
      nTULicOdb += nULicOdb
      nTUPorez += nUPorez
      nTUNetobp += nUNetobp
      nTUNeto += nUneto
      nTUOdbici += nUodbici
      nTUIsplata += nUisplata
      nTUDoprPio += nUDoprpio
      nTUDoprZdr += nUDoprzdr
      nTUDoprNez += nUDoprnez
      nTUDoprD4 += nUDoprD4
      nTUDoprD5 += nUDoprD5
      nTUDoprD6 += nUDoprD6

      IF ( nUkBolovanjeIznos <> 0 )

         ?
         @ PRow(), nPoc - 3 SAY "r: " + Str( nUkRadnihSati, 12, 2 )
         @ PRow(), nNBP_pt SAY Str( nUkRadIznos, 12, 2 )

         nTUR_sati += nUkRadnihSati
         nTUR_izn += nUkRadIznos

         ?
         @ PRow(), nPoc - 3 SAY "b: " + Str( nUkBolovanjeSati, 12, 2 )
         @ PRow(), nNBP_pt SAY Str( nUkBolovanjeIznos, 12, 2 )

         nTUB_sati += nUkBolovanjeSati
         nTUB_izn += nUkBolovanjeIznos

      ELSE
         nTUR_sati += nUSati
         nTUR_izn += nUNetobp
      ENDIF

      ++nCount

   ENDDO

   ? cLine

   ? "UKUPNO:"
   @ PRow(), nPoc SAY Str( nTUSati, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUPrim, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUBruto, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUDoprIz, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTULicOdb, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUPorez, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUNetoBP, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUNeto, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUOdbici, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTUIsplata, 12, 2 )

   IF !Empty( cDop1 )
      @ PRow(), PCol() + 1 SAY Str( nTUDoprPio, 12, 2 )
   ENDIF

   IF !Empty( cDop2 )
      @ PRow(), PCol() + 1 SAY Str( nTUDoprZdr, 12, 2 )
   ENDIF

   IF !Empty( cDop3 )
      @ PRow(), PCol() + 1 SAY Str( nTUDoprNez, 12, 2 )
   ENDIF

   IF !Empty( cDop4 )
      @ PRow(), PCol() + 1 SAY Str( nTUDoprD4, 12, 2 )
   ENDIF

   IF !Empty( cDop5 )
      @ PRow(), PCol() + 1 SAY Str( nTUDoprD5, 12, 2 )
   ENDIF

   IF !Empty( cDop6 )
      @ PRow(), PCol() + 1 SAY Str( nTUDoprD6, 12, 2 )
   ENDIF

   IF ( nTUB_izn <> 0 )
      ?
      @ PRow(), nPoc - 3 SAY "r: " + Str( nTUR_sati, 12, 2 )
      @ PRow(), nNBP_pt SAY Str( nTUR_izn, 12, 2 )
      ?
      @ PRow(), nPoc - 3 SAY "b: " + Str( nTUB_sati, 12, 2 )
      @ PRow(), nNBP_pt SAY Str( nTUB_izn, 12, 2 )
   ENDIF

   ? cLine

   FF
   ENDPRINT

   RETURN .T.





STATIC FUNCTION pregled_header( cRadnik, cDop1, cDop2, cDop3, cDop4, cDop5, cDop6 )

   LOCAL aLines := {}
   LOCAL aTxt := {}
   LOCAL i
   LOCAL cLine := ""
   LOCAL cTxt1 := ""
   LOCAL cTxt2 := ""
   LOCAL cTxt3 := ""
   LOCAL cTxt4 := ""
   LOCAL nTxtLen

   AAdd( aLines, { Replicate( "-", 5 ) } )
   AAdd( aLines, { Replicate( "-", 7 ) } )
   AAdd( aLines, { Replicate( "-", 20 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )
   AAdd( aLines, { Replicate( "-", 12 ) } )

   IF !Empty( cDop1 )
      AAdd( aLines, { Replicate( "-", 12 ) } )
   ENDIF
   IF !Empty( cDop2 )
      AAdd( aLines, { Replicate( "-", 12 ) } )
   ENDIF
   IF !Empty( cDop3 )
      AAdd( aLines, { Replicate( "-", 12 ) } )
   ENDIF
   IF !Empty( cDop4 )
      AAdd( aLines, { Replicate( "-", 12 ) } )
   ENDIF
   IF !Empty( cDop5 )
      AAdd( aLines, { Replicate( "-", 12 ) } )
   ENDIF
   IF !Empty( cDop6 )
      AAdd( aLines, { Replicate( "-", 12 ) } )
   ENDIF

   AAdd( aTxt, { "Red.", "br", "", "1" } )
   IF !Empty( cRadnik )
      AAdd( aTxt, { "Obr.", "za mj", "", "2" } )
   ELSE
      AAdd( aTxt, { "Šifra", "radn.", "", "2" } )
   ENDIF
   AAdd( aTxt, { "Naziv", "radnika", "", "3" } )
   AAdd( aTxt, { "Sati", "", "", "4" } )
   AAdd( aTxt, { "Primanja", "", "", "5" } )
   AAdd( aTxt, { "Bruto plata", "(5 x koef.)", "", "6" } )
   AAdd( aTxt, { "Doprinos", "iz plaće", "( 31% )", "7" } )
   AAdd( aTxt, { "Lični odbici", "", "", "8" } )
   AAdd( aTxt, { "Porez", "na dohodak", "10%", "9" } )
   AAdd( aTxt, { "Neto", "plata", "(6-7)", "10" } )
   AAdd( aTxt, { "Na", "ruke", "(6-7-9)", "11" } )
   AAdd( aTxt, { "Odbici", "", "", "12" } )
   AAdd( aTxt, { "Za isplatu", "", "(11+12)", "13" } )
   IF !Empty( cDop1 )
      AAdd( aTxt, { "Doprinos", "1", procenat_doprinosa( cDop1 ), "14" } )
   ENDIF
   IF !Empty( cDop2 )
      AAdd( aTxt, { "Doprinos", "2", procenat_doprinosa( cDop2 ), "15" } )
   ENDIF
   IF !Empty( cDop3 )
      AAdd( aTxt, { "Doprinos", "3", procenat_doprinosa( cDop3 ), "16" } )
   ENDIF
   IF !Empty( cDop4 )
      AAdd( aTxt, { "Doprinos", "4", procenat_doprinosa( cDop4 ), "17" } )
   ENDIF
   IF !Empty( cDop5 )
      AAdd( aTxt, { "Doprinos", "5", procenat_doprinosa( cDop5 ), "18" } )
   ENDIF
   IF !Empty( cDop6 )
      AAdd( aTxt, { "Doprinos", "6", procenat_doprinosa( cDop6 ), "19" } )
   ENDIF

   FOR i := 1 TO Len( aLines )
      cLine += aLines[ i, 1 ] + Space( 1 )
   NEXT

   FOR i := 1 TO Len( aTxt )
      nTxtLen := Len( aLines[ i, 1 ] )
      cTxt1 += PadC( "(" + aTxt[ i, 4 ] + ")", nTxtLen ) + Space( 1 )
      cTxt2 += PadC( aTxt[ i, 1 ], nTxtLen ) + Space( 1 )
      cTxt3 += PadC( aTxt[ i, 2 ], nTxtLen ) + Space( 1 )
      cTxt4 += PadC( aTxt[ i, 3 ], nTxtLen ) + Space( 1 )
   NEXT

   ?U cLine
   ?U cTxt1
   ?U cTxt2
   ?U cTxt3
   ?U cTxt4
   ?U cLine

   RETURN cLine



STATIC FUNCTION procenat_doprinosa( cDop )

   LOCAL cProc := ""
   LOCAL nTmp
   LOCAL nTArea := Select()

   nTmp := get_dopr( cDop, " " ) // daj za tip rada " "

   IF nTmp <> 0
      cProc := AllTrim( Str( nTmp ) ) + " %"
   ENDIF

   SELECT ( nTArea )

   RETURN cProc


STATIC FUNCTION pregled_zaglavlje( cRj, nGodina, cMjOd, cMjDo, cRadnik, cOpcina, cKanton )

   ? Upper( tip_organizacije() ) + ":", self_organizacija_naziv()
   ?

   IF Empty( cRj )
      ? "Pregled za sve RJ:"
   ELSE
      ?  "RJ:", cRj
   ENDIF

   IF !Empty( cOpcina )
      ?U "Općina:", AllTrim( cOpcina )
   ENDIF

   IF !Empty( cKanton )
      ?U "Kanton:", AllTrim( cKanton )
   ENDIF

   ?? Space( 2 ) + "Mjesec od:", Str( cMjOd, 2 ), "do:", Str( cMjDo, 2 )
   ?? Space( 4 ) + "Godina:", Str( nGodina, 5 )

   IF !Empty( cRadnik )
      ? "Radnik: " + cRadnik
   ENDIF

   RETURN .T.



STATIC FUNCTION filter_opcina_kanton( id_radn, opcina, kanton )

   LOCAL lOk := .T.
   LOCAL nTArea := Select()
   LOCAL cKant

   select_o_radn( id_radn )

   IF !Empty( opcina ) .AND. !( radn->idopsst $ opcina )
      lOk := .F.
   ENDIF

   IF !Empty( kanton )

      select_o_ops( radn->idopsst )

      IF Eof() .AND. !( ops->idkan $ kanton )
         lOk := .F.
      ENDIF

   ENDIF

   SELECT ( nTArea )

   RETURN lOk





STATIC FUNCTION sortiraj_tabelu_ld( cRj, nGodina, nMjesec, cMjesecDo, cRadnik, cObr )

   LOCAL cFilter := ""
   PRIVATE cObracun := cObr

   IF !Empty( cObracun )
      cFilter += "obr == " + _filter_quote( cObracun )
   ENDIF

   IF !Empty( cRj )

      IF !Empty( cFilter )
         cFilter += " .and. "
      ENDIF

      cFilter += Parsiraj( cRj, "IDRJ" )

   ENDIF

   IF !Empty( cFilter )
      SET FILTER TO &cFilter
      GO TOP
   ENDIF

   IF Empty( cRadnik )
      INDEX ON Str( godina ) + SortPrez( idradn ) + Str( mjesec ) + idrj TO "tmpld"
      GO TOP
      SEEK Str( nGodina, 4 )
   ELSE
      SET ORDER TO TAG ( ld_index_tag_vise_obracuna( "2" ) )
      GO TOP
      SEEK Str( nGodina, 4 ) + Str( nMjesec, 2 ) + cObracun + cRadnik
   ENDIF

   RETURN .T.


STATIC FUNCTION dodaj_u_pomocnu_tabelu( nGodina, nMjesec, cRadnik, cIdRj, cObrZa, cIme, ;
      nSati, nR_sati, ;
      nB_sati, nPrim, nBruto, nDoprIz, nDopPio, ;
      nDopZdr, nDopNez, nOporDoh, nLOdb, nPorez, nNetoBp, nNeto, ;
      nR_neto, nB_neto, ;
      nOdbici, nIsplata, nDop4, nDop5, nDop6 )

   LOCAL nTArea := Select()

   O_R_EXP
   SELECT r_export
   APPEND BLANK

   REPLACE godina WITH nGodina
   REPLACE mjesec WITH nMjesec
   REPLACE idrj WITH cIdRj
   REPLACE idradn WITH cRadnik
   REPLACE obr_za WITH cObrZa
   REPLACE naziv WITH cIme
   REPLACE sati WITH nSati
   REPLACE b_sati WITH nB_Sati
   REPLACE r_sati WITH nR_Sati
   REPLACE neto WITH nNeto
   REPLACE b_neto WITH nB_Neto
   REPLACE r_neto WITH nR_Neto
   REPLACE netobp WITH nNetoBp
   REPLACE prim WITH nPrim
   REPLACE bruto WITH nBruto
   REPLACE dop_iz WITH nDoprIz
   REPLACE dop_pio WITH nDopPio
   REPLACE dop_zdr WITH nDopZdr
   REPLACE dop_nez WITH nDopNez
   REPLACE dop_4 WITH nDop4
   REPLACE dop_5 WITH nDop5
   REPLACE dop_6 WITH nDop6
   REPLACE l_odb WITH nLOdb
   REPLACE izn_por WITH nPorez
   REPLACE opordoh WITH nOporDoh
   REPLACE odbici WITH nOdbici
   REPLACE isplata WITH nIsplata

   SELECT ( nTArea )

   RETURN .T.



STATIC FUNCTION napravi_pomocnu_tabelu()

   LOCAL aDbf := {}

   AAdd( aDbf, { "IDRJ", "C", 2, 0 } )
   AAdd( aDbf, { "GODINA", "N", 4, 0 } )
   AAdd( aDbf, { "MJESEC", "N", 2, 0 } )
   AAdd( aDbf, { "IDRADN", "C", 6, 0 } )
   AAdd( aDbf, { "OBR_ZA", "C", 15, 0 } )
   AAdd( aDbf, { "NAZIV", "C", 20, 0 } )
   AAdd( aDbf, { "SATI", "N", 12, 2 } )
   AAdd( aDbf, { "R_SATI", "N", 12, 2 } )
   AAdd( aDbf, { "B_SATI", "N", 12, 2 } )
   AAdd( aDbf, { "PRIM", "N", 12, 2 } )
   AAdd( aDbf, { "NETO", "N", 12, 2 } )
   AAdd( aDbf, { "R_NETO", "N", 12, 2 } )
   AAdd( aDbf, { "B_NETO", "N", 12, 2 } )
   AAdd( aDbf, { "NETOBP", "N", 12, 2 } )
   AAdd( aDbf, { "BRUTO", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_IZ", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_PIO", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_ZDR", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_NEZ", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_4", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_5", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_6", "N", 12, 2 } )
   AAdd( aDbf, { "IZN_POR", "N", 12, 2 } )
   AAdd( aDbf, { "OPORDOH", "N", 12, 2 } )
   AAdd( aDbf, { "L_ODB", "N", 12, 2 } )
   AAdd( aDbf, { "ODBICI", "N", 12, 2 } )
   AAdd( aDbf, { "ISPLATA", "N", 12, 2 } )

   create_dbf_r_export( aDbf )

   RETURN .T.


STATIC FUNCTION otvori_tabele()

   o_ld_obracuni()
   o_ld_parametri_obracuna()
   O_PARAMS
   o_ld_rj()
   o_ld_radn()
   o_koef_beneficiranog_radnog_staza()
   o_ld_vrste_posla()
   //o_tippr()
   o_kred()
   o_dopr()
   o_por()
   select_o_ld()

   RETURN .T.
