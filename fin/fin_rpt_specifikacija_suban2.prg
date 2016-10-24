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

STATIC __rj_len := 4


// ---------------------------------------------------
// kreira export tabelu
// ---------------------------------------------------
STATIC FUNCTION cre_tmp( cPath )

   LOCAL aFields

   aFields := {}

   AAdd( aFields, { "idfirma", "C", 2, 0 } )
   AAdd( aFields, { "idkonto", "C", 7, 0 } )
   AAdd( aFields, { "idpartner", "C", FIELD_PARTNER_ID_LENGTH, 0 } )
   AAdd( aFields, { "kto_opis", "C", 50, 0 } )
   AAdd( aFields, { "par_opis", "C", 50, 0 } )
   AAdd( aFields, { "par_mjesto", "C", 50, 0 } )
   AAdd( aFields, { "idrj", "C", __rj_len, 0 } )
   AAdd( aFields, { "rj_opis", "C", 50, 0 } )
   AAdd( aFields, { "dug", "N", 15, 2 } )
   AAdd( aFields, { "pot", "N", 15, 2 } )
   AAdd( aFields, { "saldo", "N", 15, 2 } )
   AAdd( aFields, { "dug2", "N", 15, 2 } )
   AAdd( aFields, { "pot2", "N", 15, 2 } )
   AAdd( aFields, { "saldo2", "N", 15, 2 } )

   create_dbf_r_export( aFields )

   o_tmp( cPath )

   RETURN



// -----------------------------------------------
// otvori i indeksiraj pomocnu tabelu
// -----------------------------------------------
STATIC FUNCTION o_tmp( cPath )

   // select (248)
   // use ( cPath + "r_export" ) alias "r_export"
   O_R_EXP
   INDEX ON idkonto + idpartner + idrj TAG "1"

   RETURN


// ---------------------------------------------------
// Specifikacija subanalitickih konta v.2
// ---------------------------------------------------
FUNCTION spec_sub()

   LOCAL cSK := "N"
   LOCAL cLDrugi := ""
   LOCAL cPom := ""
   LOCAL nCOpis := 0
   LOCAL cLTreci := ""
   LOCAL cIzr1
   LOCAL cIzr2
   LOCAL cExpRptDN := "N"
   LOCAL cOpcine := Space( 20 )
   LOCAL cVN := Space( 20 )
   LOCAL cP_Path := PRIVPATH
   LOCAL cT_sez := tekuca_sezona()
   LOCAL i
   LOCAL nYearFrom
   LOCAL nYearTo
   LOCAL lSilent
   LOCAL lWriteKParam
   LOCAL lInSez
   LOCAL cDok_izb := ""

   PRIVATE cSkVar := "N"
   PRIVATE fK1 := fk2 := fk3 := fk4 := "N"
   PRIVATE cRasclaniti := "N"

   cN2Fin := my_get_from_ini( 'FIN', 'PartnerNaziv2', 'N' )

   O_PARTN
   o_suban()
   __rj_len := Len( suban->idrj )

   // kreiraj tabelu exporta
   cre_tmp( cP_Path )

   nC := 50
   O_PARTN
   O_PARAMS

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "k1", @fk1 )
   RPar( "k2", @fk2 )
   RPar( "k3", @fk3 )
   RPar( "k4", @fk4 )

   SELECT params
   USE

   cIdFirma := gFirma
   picBHD := FormPicL( "9 " + gPicBHD, 20 )

   qqKonto := Space( 100 )
   qqPartner := Space( 100 )
   dDatOd := CToD( "" )
   dDatDo := CToD( "" )
   cDok_izb := Space( 150 )

   O_PARAMS

   PRIVATE cSection := "S"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "qK", @qqKonto )
   RPar( "qP", @qqPartner )
   RPar( "d1", @dDatoD )
   RPar( "d2", @dDatDo )

   qqkonto := PadR( qqKonto, 100 )
   qqPartner := PadR( qqPartner, 100 )
   qqBrDok := Space( 40 )

   SELECT params
   USE

   cTip := "1"

   Box( "", 20, 65 )

   SET CURSOR ON

   PRIVATE cK1 := "9"
   PRIVATE cK2 := "9"
   PRIVATE cK3 := "99"
   PRIVATE cK4 := "99"

   IF my_get_from_ini( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
      cK3 := "999"
   ENDIF

   IF gDUFRJ == "D"
      cIdRj := Space( 60 )
   ELSE
      cIdRj := "999999"
   ENDIF

   cFunk := "99999"
   cFond := "9999"
   cNula := "N"

   DO WHILE .T.

      @ m_x + 1, m_y + 6 SAY "SPECIFIKACIJA SUBANALITICKIH KONTA"

      IF gDUFRJ == "D"
         cIdFirma := PadR( gFirma + ";", 30 )
         @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma PICT "@!S20"
      ELSE
         IF gNW == "D"
            @ m_x + 3, m_y + 2 SAY "Firma "
            ?? gFirma, "-", gNFirma
         ELSE
            @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma ;
               VALID {|| IF( !Empty( cIdFirma ), ;
               P_Firma( @cIdFirma ), ), ;
               cIdFirma := Left( cIdFirma, 2 ), ;
               .T. }
         ENDIF
      ENDIF

      @ m_x + 4, m_y + 2 SAY "Konto   " GET qqKonto  PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Partner " GET qqPartner PICT "@!S50"
      @ m_x + 6, m_y + 2 SAY "Datum dokumenta od" GET dDatOd
      @ m_x + 6, Col() + 2 SAY "do" GET dDatDo

      IF fin_dvovalutno()
         @ m_x + 7, m_y + 2 SAY "Obracun za " + ;
            AllTrim( ValDomaca() ) + "/" + ;
            AllTrim( ValPomocna() ) + "/" + ;
            AllTrim( ValDomaca() ) + "-" + ;
            AllTrim( ValPomocna() ) + " (1/2/3):" ;
            GET cTip ;
            VALID cTip $ "123"
      ELSE
         cTip := "1"
      ENDIF

      @ m_x + 8, m_y + 2 SAY "Prikaz sintetickih konta (D/N) ?" ;
         GET cSK PICT "@!" VALID csk $ "DN"
      @ m_x + 9, m_y + 2 SAY "Prikaz stavki sa saldom 0 D/N" ;
         GET cNula PICT "@!" VALID cNula  $ "DN"
      @ m_x + 10, m_y + 2 SAY "Skracena varijanta (D/N) ?" ;
         GET cSkVar PICT "@!" VALID cSkVar $ "DN"
      @ m_x + 11, m_y + 2 SAY "Uslov za broj veze (prazno-svi) " ;
         GET qqBrDok PICT "@!S20"
      @ m_x + 12, m_y + 2 SAY "Uslov za vrstu naloga (prazno-svi) " ;
         GET cVN PICT "@!S20"
      @ m_x + 13, m_y + 2 SAY "Izbaciti dokumente: " ;
         GET cDok_izb PICT "@!S30"


      cRasclaniti := "N"

      IF gFinRj == "D"
         @ m_x + 14, m_y + 2 SAY "Rasclaniti po RJ (D/N) " ;
            GET cRasclaniti PICT "@!" ;
            VALID cRasclaniti $ "DN"

      ENDIF

      @ m_x + 16, m_y + 2 SAY "Opcina (prazno-sve):" GET cOpcine

      UpitK1k4( 15 )

      @ m_x + 20, m_y + 2 SAY "Export izvjestaja u dbf (D/N) ?" ;
         GET cExpRptDN PICT "@!" ;
         VALID cExpRptDN $ "DN"

      READ

      ESC_BCR

      O_PARAMS
      PRIVATE cSection := "S"
      PRIVATE cHistory := " "
      PRIVATE aHistory := {}

      WPar( "qK", qqKonto )
      WPar( "qP", qqPartner )
      WPar( "d1", dDatoD )
      WPar( "d2", dDatDo )

      SELECT params
      USE

      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      aUsl2 := Parsiraj( qqPartner, "IdPartner" )

      IF gDUFRJ == "D"
         aUsl3 := Parsiraj( cIdFirma, "IdFirma" )
         aUsl4 := Parsiraj( cIdRJ, "IdRj" )
      ENDIF

      aBV := Parsiraj( qqBrDok, "UPPER(BRDOK)", "C" )
      aVN := Parsiraj( cVN, "IDVN", "C" )

      IF aBV <> NIL .AND. aVN <> NIL .AND. ;
            aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. ;
            IF( gDUFRJ == "D", aUsl3 <> NIL .AND. aUsl4 <> NIL, .T. )
         EXIT
      ENDIF
   ENDDO
   BoxC()

   // godina od - do
   nYearFrom := Year( dDatOd )
   nYearTo := Year( dDatDo )
   lInSez := .F.

   IF ( nYearTo - nYearFrom ) <> 0
      // ima vise godina, prodji kroz sezone
      lInSez := .T.
   ENDIF

   // export izvjestaja u dbf
   lExpRpt := ( cExpRptDN == "D" )

   IF gDUFRJ != "D"
      cIdFirma := Left( cIdFirma, 2 )
   ENDIF

   o_suban()
   CistiK1k4()

   // prodji po godinama i azuriraj u tbl_export

   lSilent := .T.
   lWriteKParam := .T.

   FOR i := nYearFrom TO nYearTo

/*
TODO: izbaciti
      IF lInSez == .T.
         // logiraj se u godinu
         goModul:oDataBase:logAgain( AllTrim( Str( i ) ), lSilent, lWriteKParam )
         // otvori export tabelu u tekucoj sezoni
         o_tmp( cP_Path )
      ENDIF
*/

      O_RJ
      O_PARTN
      O_KONTO
      o_suban()

      SELECT suban

      IF !Empty( cIdFirma ) .AND. gDUFRJ != "D"
         IF cRasclaniti == "D"
            INDEX ON idfirma + idkonto + idpartner + idrj + DToS( datdok ) ;
               TO SUBSUB
            SET ORDER TO TAG "SUBSUB"
         ELSE
            // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr
            SET ORDER TO 1
         ENDIF
      ELSE
         IF cRasclaniti == "D"
            INDEX ON idkonto + idpartner + idrj + DToS( datdok ) ;
               TO SUBSUB
            SET ORDER TO TAG "SUBSUB"
         ELSE
            cIdFirma := ""
            INDEX ON IdKonto + IdPartner + DToS( DatDok ) + ;
               BrNal + RBr TO SVESUB
            SET ORDER TO TAG "SVESUB"
         ENDIF
      ENDIF

      IF gDUFRJ == "D"
         cFilter := aUsl3
      ELSE
         cFilter := "IdFirma=" + dbf_quote( cidfirma )
      ENDIF

      IF !Empty( cVN )
         cFilter += ( ".and. " + aVN )
      ENDIF

      IF !Empty( qqBrDok )
         cFilter += ( ".and." + aBV )
      ENDIF

      IF aUsl1 <> ".t."
         cFilter += ( ".and." + aUsl1 )
      ENDIF

      IF aUsl2 <> ".t."
         cFilter += ( ".and." + aUsl2 )
      ENDIF

      IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
         cFilter += ( ".and. DATDOK>=" + ;
            dbf_quote( dDatOd ) + ".and. DATDOK<=" + dbf_quote( dDatDo ) )
      ENDIF

      IF fk1 == "D" .AND. Len( ck1 ) <> 0
         cFilter += ( ".and. k1='" + ck1 + "'" )
      ENDIF

      IF fk2 == "D" .AND. Len( ck2 ) <> 0
         cFilter += ( ".and. k2='" + ck2 + "'" )
      ENDIF

      IF fk3 == "D" .AND. Len( ck3 ) <> 0
         cFilter += ( ".and. k3='" + ck3 + "'" )
      ENDIF

      IF fk4 == "D" .AND. Len( ck4 ) <> 0
         cFilter += ( ".and. k4='" + ck4 + "'" )
      ENDIF

      IF gFinRj == "D" .AND. Len( cIdrj ) <> 0
         IF gDUFRJ == "D"
            cFilter += ( ".and." + aUsl4 )
         ELSE
            cFilter += ( ".and. idrj='" + cidrj + "'" )
         ENDIF
      ENDIF

      IF gTroskovi == "D" .AND. Len( cFunk ) <> 0
         cFilter += ( ".and. Funk='" + cFunk + "'" )
      ENDIF

      IF gTroskovi == "D" .AND. Len( cFond ) <> 0
         cFilter += ( ".and. Fond='" + cFond + "'" )
      ENDIF

      SET FILTER to &cFilter
      GO TOP

      // prodji kroz podatke

      DO WHILE !Eof()

         cIdKonto := field->idkonto
         cIdPartner := field->idpartner

         nTArea := Select()

         // uslov po opcinama
         IF !Empty( cOpcine )

            SELECT partn
            SEEK cIdPartner

            IF AllTrim( field->idops ) $ cOpcine
               // to je taj partner...
            ELSE
               // posto nije to taj preskoci...
               SELECT ( nTArea )
               SKIP
               LOOP
            ENDIF

         ENDIF

         cRasclan := ""

         IF cRasclaniti == "D"
            cRasclan := field->idrj
         ENDIF

         SELECT ( nTArea )

         nD := 0
         nP := 0
         nD2 := 0
         nP2 := 0

         DO WHILE !Eof() .AND. cIdKonto == field->idkonto ;
               .AND. field->idpartner == cIdPartner ;
               .AND. RasclanRJ()

            // ima li dokumenata za izbaciti ?
            IF !Empty( cDok_izb )
               IF field->idvn $ cDok_izb
                  // preskoci na sljedeci zapis
                  SKIP
                  LOOP
               ENDIF
            ENDIF

            IF lInSez == .T.
               // ako su sezone,
               // preskaci pocetna stanja
               IF field->idvn == "00"
                  SKIP
                  LOOP
               ENDIF
            ENDIF

            // racuna duguje/potrazuje
            IF field->d_p == "1"
               nD += field->iznosbhd
               nD2 += field->iznosdem
            ELSE
               nP += field->iznosbhd
               nP2 += field->iznosdem
            ENDIF

            SKIP 1

         ENDDO

         // pronadji opis rj
         SELECT rj
         GO TOP
         SEEK cRasclan
         IF !Found()
            cRj_naz := ""
         ELSE
            cRj_naz := field->naz
         ENDIF

         // pronadji opis konta
         SELECT konto
         HSEEK cIdKonto

         // pronadji opis partnera
         SELECT partn
         HSEEK cIdPartner

         SELECT suban

         // ubaci u tbl_export
         IF cNula == "D" .OR. Round( nD - nP, 3 ) <> 0

            SELECT r_export
            GO TOP
            SEEK cIdKonto + cIdPartner + cRasclan

            my_flock()

            IF !Found()

               APPEND BLANK
               REPLACE field->idfirma WITH cIdFirma
               REPLACE field->idkonto WITH cIdKonto
               REPLACE field->idpartner WITH cIdPartner
               REPLACE field->kto_opis WITH konto->naz
               REPLACE field->par_opis WITH partn->naz
               REPLACE field->par_mjesto WITH partn->mjesto
               REPLACE field->idrj WITH cRasclan
               REPLACE field->rj_opis WITH cRj_naz

            ENDIF

            REPLACE field->dug WITH field->dug + nD
            REPLACE field->pot WITH field->pot + nP
            REPLACE field->saldo with ;
               field->saldo + ( nD - nP )

            REPLACE field->dug2 WITH field->dug2 + nD2
            REPLACE field->pot2 WITH field->pot2 + nP2
            REPLACE field->saldo2 with ;
               field->saldo2 + ( nD2 - nP2 )

            my_unlock()

            SELECT suban

         ENDIF
      ENDDO
   NEXT

/* TODO: izbaciti
   // uvijek se vrati u radno podrucje
   IF lInSez == .T.
      goModul:oDataBase:logAgain( cT_sez, lSilent, lWriteKParam )
      o_tmp( cP_Path )
   ENDIF
*/

   // ako je export izvjestaja onda ne pozivaj stampu !
   IF lExpRpt
      open_r_export_table()
      my_close_all_dbf()
      RETURN
   ENDIF

   // poziva se izvjestaj

   Pic := PicBhd


   IF !start_print()
      RETURN .F.
   ENDIF

   IF cSkVar == "D"
      nDOpis := 25
      IF FIELD_PARTNER_ID_LENGTH > 6
         // nDOpis += 2
      ENDIF
      nDIznos := 12
      pic := Right( picbhd, nDIznos )
   ELSE
      nDOpis := 50
      IF FIELD_PARTNER_ID_LENGTH > 6
         // nDOpis += 2
      ENDIF
      nDIznos := 20
   ENDIF

   IF cTip == "3"
      m := "------- " + Replicate( "-", FIELD_PARTNER_ID_LENGTH ) + " " + REPL( "-", nDOpis ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos )
   ELSE
      m := "------- " + Replicate( "-", FIELD_PARTNER_ID_LENGTH ) + " " + REPL( "-", nDOpis ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos ) + " " + REPL( "-", nDIznos )
   ENDIF

   nStr := 0

   nud := 0
   nup := 0
   nud2 := 0
   nup2 := 0

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      cSin := Left( field->idkonto, 3 )

      nKd := 0
      nKp := 0
      nKd2 := 0
      nKp2 := 0

      DO WHILE !Eof() .AND.  cSin == Left( field->idkonto, 3 )

         cIdKonto := field->idkonto
         cIdPartner := field->idpartner

         IF cRasclaniti == "D"
            cRasclan := field->idrj
         ELSE
            cRasclan := ""
         ENDIF

         // ispis headera
         IF PRow() == 0
            Header( cSkVar )
         ENDIF

         IF PRow() > 63 + dodatni_redovi_po_stranici()
            FF
            Header( cSkVar )
         ENDIF

         IF cNula == "D" .OR. ( Round( field->saldo, 3 ) <> 0 ;
               .AND. cTip $ "13" )

            ? cIdKonto, cIdPartner, ""

            IF cRasclaniti == "D"

               IF !Empty( cRasclan )

                  cLTreci := "RJ:" + cRasclan + "-" + ;
                     Trim( field->rj_opis )
               ENDIF

            ENDIF

            nCOpis := PCol()

            // ispis partnera
            IF !Empty( cIdPartner )
               IF gVSubOp == "D"
                  cPom := AllTrim( field->kto_opis ) + ;
                     " (" + ;
                     AllTrim( AllTrim( field->par_opis ) + ;
                     PN2() ) + ;
                     ")"

                  ?? PadR( cPom, nDOpis - DifIdP( cIdPartner ) )

                  IF Len( cPom ) > nDOpis - DifIdP( cidpartner )
                     cLDrugi := SubStr( cPom, nDOpis + 1 )
                  ENDIF
               ELSE
                  cPom := AllTrim( field->par_opis ) + PN2()

                  IF !Empty( field->par_mjesto )
                     IF Right( Trim( Upper( field->par_opis ) ), ;
                           Len( Trim( field->par_mjesto ) ) ) != ;
                           Trim( Upper( field->par_mjesto ) )
                        cPom := Trim( AllTrim( field->par_opis ) + ;
                           PN2() ) + " " + ;
                           Trim( field->par_mjesto )

                        aTxt := Sjecistr( cPom, nDOpis )
                        cPom := aTxt[ 1 ]

                        IF Len( aTxt ) > 1
                           cLDrugi := aTxt[ 2 ]
                        ENDIF

                     ENDIF
                  ENDIF

                  ?? PadR( cPom, nDOpis )
               ENDIF

            ELSE
               ?? PadR( field->kto_opis, nDOpis )
            ENDIF

            nC := PCol() + 1

            // ispis duguje/potrazuje/saldo
            IF cTip == "1"
               @ PRow(), PCol() + 1 SAY field->dug PICT pic
               @ PRow(), PCol() + 1 SAY field->pot PICT pic
               @ PRow(), PCol() + 1 SAY field->saldo PICT pic
            ELSEIF cTip == "2"
               @ PRow(), PCol() + 1 SAY field->dug2 PICT pic
               @ PRow(), PCol() + 1 SAY field->pot2 PICT pic
               @ PRow(), PCol() + 1 SAY field->saldo2 PICT pic
            ELSE
               @ PRow(), PCol() + 1 SAY field->saldo PICT pic
               @ PRow(), PCol() + 1 SAY field->saldo2 PICT pic
            ENDIF

            nKd += field->dug
            nKp += field->pot
            nKd2 += field->dug2
            nKp2 += field->pot2

         ENDIF

         IF Len( cLDrugi ) > 0
            @ PRow() + 1, nCOpis SAY cLDrugi
            cLDrugi := ""
         ENDIF
         IF Len( cLTreci ) > 0
            @ PRow() + 1, nCOpis SAY cLTreci
            cLTreci := ""
         ENDIF

         SKIP

      ENDDO

      IF PRow() > 61 + dodatni_redovi_po_stranici()
         FF
         Header( cSkVar )
      ENDIF

      IF cSK == "D"

         SELECT rj
         HSEEK cSin

         SELECT r_export

         ? m

         ?  "SINT.K.", cSin, ": ", AllTrim( konto->naz )

         IF cTip == "1"
            @ PRow(), nC SAY nKd PICT pic
            @ PRow(), PCol() + 1 SAY nKp PICT pic
            @ PRow(), PCol() + 1 SAY nKd - nKp PICT pic
         ELSEIF cTip == "2"
            @ PRow(), nC SAY nKd2 PICT pic
            @ PRow(), PCol() + 1 SAY nKp2 PICT pic
            @ PRow(), PCol() + 1 SAY nKd2 - nKp2 PICT pic
         ELSE
            @ PRow(), nC SAY nKd - nKP PICT pic
            @ PRow(), PCol() + 1 SAY nKd2 - nKP2 PICT pic
         ENDIF

         ? m
      ENDIF

      nUd += nKd
      nUp += nKp
      nUd2 += nKd2
      nUp2 += nKp2
   ENDDO

   IF PRow() > 61 + dodatni_redovi_po_stranici()
      FF
      Header( cSkVar )
   ENDIF

   ? m
   ? " UKUPNO:"
   IF cTip == "1"
      @ PRow(), nC       SAY nUd PICT pic
      @ PRow(), PCol() + 1 SAY nUp PICT pic
      @ PRow(), PCol() + 1 SAY nUd - nUp PICT pic
   ELSEIF cTip == "2"
      @ PRow(), nC       SAY nUd2 PICT pic
      @ PRow(), PCol() + 1 SAY nUp2 PICT pic
      @ PRow(), PCol() + 1 SAY nUd2 - nUp2 PICT pic
   ELSE
      @ PRow(), nC       SAY nUd - nUP PICT pic
      @ PRow(), PCol() + 1 SAY nUd2 - nUP2 PICT pic
   ENDIF

   ? m

   FF
   end_print()

   closeret

   RETURN


// -------------------------------------------------------------
// header izvjestaja specifikacija po suban kontima
// -------------------------------------------------------------
STATIC FUNCTION Header( cSkVar )

   ?
   B_ON
   P_COND

   ?? "FIN: SPECIFIKACIJA SUBANALITICKIH KONTA  ZA "

   IF cTip == "1"
      ?? ValDomaca()
   ELSEIF cTip == "2"
      ?? ValPomocna()
   ELSE
      ?? AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() )
   ENDIF
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "  ZA DOKUMENTE U PERIODU ", dDatOd, "-", dDatDo
   ENDIF
   ?? " NA DAN: "; ?? Date()
   IF !Empty( qqBrDok )
      ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '" + Trim( qqBrDok ) + "'"
   ENDIF
   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
   B_OFF

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      IF Empty( cIdFirma )
         ? "Firma:", gNFirma, "(SVE RJ)"
      ELSE
         SELECT PARTN; HSEEK cIdFirma
         ? "Firma:", cidfirma, PadR( partn->naz, 25 ), partn->naz2
      ENDIF
   ENDIF
   ?
   prikaz_k1_k4_rj()

   SELECT r_export

   IF cSkVar == "D"
      F12CPI
      ? m
   ELSE
      P_COND
      ? m
   ENDIF
   IF cTip $ "12"
      IF cSkVar != "D"
         ? "KONTO   " + PadC( "PARTN.", FIELD_PARTNER_ID_LENGTH ) + " NAZIV KONTA / PARTNERA                                          duguje            potra�uje                saldo"
      ELSE
         ? "KONTO   " + PadC( "PARTN", FIELD_PARTNER_ID_LENGTH ) + " " +  PadR( "NAZIV KONTA / PARTNERA", nDOpis ) + " " + PadC( "duguje", nDIznos ) + " " + PadC( "potra�uje", nDIznos ) + " " + PadC( "saldo", nDIznos )
      ENDIF
   ELSE
      IF cSkVar != "D"
         ? "KONTO   " + PadC( "PARTN.", FIELD_PARTNER_ID_LENGTH ) + " NAZIV KONTA / PARTNERA                                       saldo " + ValDomaca() + "           saldo " + AllTrim( ValPomocna() )
      ELSE
         ? "KONTO   " + PadC( "PARTN.", FIELD_PARTNER_ID_LENGTH ) + " " + PadR( "NAZIV KONTA / PARTNERA", nDOpis ) + " " + PadC( "saldo " + ValDomaca(), nDIznos ) + " " + PadC( "saldo " + AllTrim( ValPomocna() ), nDIznos )
      ENDIF
   ENDIF

   ? m

   RETURN
