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


STATIC __PIC_KOL := "9999999999.999"
STATIC __PIC_DEM := "99999.999"
STATIC __PIC_IZN := "999999999.99"



FUNCTION fakt_stanje_robe()

   LOCAL fSaberiKol, nKU, nKI
   LOCAL cDDokOtpr
   LOCAL GetList := {}

   PRIVATE cIdFirma
   PRIVATE qqroba, ddatod, ddatdo, nRezerv, nRevers
   PRIVATE nUl, nIzl, nRbr, cRR, nCol1 := 0, nCol0 := 50
   PRIVATE m := ""
   PRIVATE nStr := 0
   PRIVATE cProred := "N"
   PRIVATE qqTipdok := "  "

   lBezUlaza := .F.

   //_o_tables()

   cIdFirma := self_organizacija_id()
   qqRoba := ""
   dDatOd := CToD( "" )
   dDatDo := Date()
   cSaldo0 := "N"
   cDDokOtpr := "D"
   qqPartn := Space( 20 )

   Box(, 13, 66 )

   o_params()
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()
   RPar( "c1", @cIdFirma )
   RPar( "c2", @qqRoba )
   RPar( "d1", @dDatOd )
   RPar( "d2", @dDatDo )
   RPar( "d3", @cDDokOtpr )

   fSaberikol := .F.
   qqRoba := PadR( qqRoba, 60 )
   qqPartn := PadR( qqPartn, 20 )
   qqTipDok := PadR( qqTipDok, 2 )

   cRR := "N"

   PRIVATE cTipVPC := "1"

   cK1 := cK2 := Space( 4 )

   PRIVATE cMink := "N"

   DO WHILE .T.
      // IF gNW $ "DR"
      // @ box_x_koord() + 1, box_y_koord() + 2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. cIdFirma == self_organizacija_id() .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      // ELSE
      // @ box_x_koord() + 1, box_y_koord() + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      // ENDIF
      fakt_getlist_rj_read( box_x_koord() + 1, box_y_koord() + 2, @GetList, @cIdFirma )


      @ box_x_koord() + 2, box_y_koord() + 2 SAY "Roba   "  GET qqRoba   PICT "@!S40"
      @ box_x_koord() + 3, box_y_koord() + 2 SAY "Od datuma "  GET dDatOd
      @ box_x_koord() + 3, Col() + 1 SAY "do"  GET dDatDo
      @ box_x_koord() + 4, box_y_koord() + 2 SAY "gledati datum (D)dok. (O)otpr. (V)value:" GET cDDokOtpr VALID cDDokOtpr $ "DOV" PICT "@!"

      cRR := "N"
      xPos := 5
      @ box_x_koord() + xPos, box_y_koord() + 2 SAY "Prikaz stavki sa stanjem 0 (D/N)    "  GET cSaldo0 PICT "@!" VALID cSaldo0 $ "DN"
      IF gVarC $ "12"
         @ box_x_koord() + xPos + 1, box_y_koord() + 2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  GET cTipVpc PICT "@!" VALID cTipVPC $ "12"
      ENDIF

      IF gDK1 == "D"
         @ box_x_koord() + xPos + 3, box_y_koord() + 2 SAY "K1" GET  cK1 PICT "@!"
         @ box_x_koord() + xPos + 4, box_y_koord() + 2 SAY "K2" GET  cK2 PICT "@!"
      ENDIF

      @ box_x_koord() + xPos + 5, box_y_koord() + 2 SAY8 "Prikaz samo kritičnih zaliha (D/N/O) ?" GET cMinK PICT "@!" VALID cMink $ "DNO"
      @ box_x_koord() + xPos + 7, box_y_koord() + 2 SAY "Napraviti prored (D/N)    "  GET cProred PICT "@!" VALID cProred $ "DN"

      READ

      ESC_BCR

      aUsl1 := Parsiraj( qqRoba, "IdRoba" )

      IF aUsl1 <> NIL
         EXIT
      ENDIF

   ENDDO

   IF cMink == "O"
      cSaldo0 := "D"
   ENDIF

   IF lBezUlaza
      m := "---- ---------- ----------------------------------------" + " ----------- ---"
   ELSE
      m := "---- ---------- ----------------------------------------" + " " + ;
         Replicate( "-", Len( __PIC_KOL ) ) + " --- " + Replicate( "-", Len( __PIC_DEM ) ) + " " + Replicate( "-", Len( __PIC_IZN ) )
   ENDIF
   // endif

   o_params()

   qqRoba := Trim( qqRoba )
   WPar( "c1", cIdFirma )
   WPar( "c2", qqRoba )
   WPar( "c7", qqPartn )
   WPar( "c8", qqTipDok )
   WPar( "d1", dDatOd )
   WPar( "d2", dDatDo )
   WPar( "d3", cDDokOtpr )
   SELECT params
   USE

   BoxC()

   fSMark := .F.
   IF ( Right( qqRoba, 1 ) == "*" )
      fSMark := .T. // izvrsena je markacija robe
   ENDIF

   PRIVATE cFilt := ".t."


   IF aUsl1 <> ".t."
      cFilt += ".and." + aUsl1
   ENDIF

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )

      // sort po datumu dokumenta
      IF cDDokOtpr == "D"
         cFilt += ".and. DatDok>=" + _filter_quote( dDatOd ) + ".and. DatDok<=" + _filter_quote( dDatDo )
      ENDIF

   ENDIF

   seek_fakt_3( cIdFirma )

   IF cFilt == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilt
   ENDIF

   GO TOP
   EOF CRET

   cSintetika := "N"

   nKU := nKI := 0

   START PRINT CRET

   fakt_zagl_stanje_robe()

   _cijena := 0

   nRbr := 0
   nIzn := 0
   nRezerv := nRevers := 0
   qqPartn := Trim( qqPartn )
   cIdFirma := Trim( cIdFirma )

   nH := 0

   DO WHILE !Eof()

      // provjeri datumski valutu, otpremnicu
      IF cDDokOtpr == "O"
         seek_fakt_doks( fakt->idfirma, fakt->idtipdok, fakt->brdok )
         IF fakt_doks->dat_otpr < dDatOd .OR. fakt_doks->dat_otpr > dDatDo

            SKIP
            LOOP
         ENDIF
         SELECT fakt
      ENDIF

      IF cDDokOtpr == "V"
         seek_fakt_doks( fakt->idfirma, fakt->idtipdok, fakt->brdok )
         IF fakt_doks->dat_val < dDatOd .OR. fakt_doks->dat_val > dDatDo
            SELECT fakt
            SKIP
            LOOP
         ENDIF
         SELECT fakt
      ENDIF

      cIdRoba := IdRoba

      nStanjeCR := nUl := nIzl := 0
      nRezerv := nRevers := 0

      DO WHILE !Eof() .AND. cIdRoba == IdRoba

         // provjeri datumski valutu, otpremnicu
         IF cDDokOtpr == "O"
            seek_fakt_doks( fakt->idfirma, fakt->idtipdok, fakt->brdok )
            IF fakt_doks->dat_otpr < dDatOd .OR. fakt_doks->dat_otpr > dDatDo
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            SELECT fakt
         ENDIF

         IF cDDokOtpr == "V"
            seek_fakt_doks( fakt->idfirma, fakt->idtipdok, fakt->brdok )
            IF fakt_doks->dat_val < dDatOd .OR. fakt_doks->dat_val > dDatDo
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            SELECT fakt
         ENDIF

         IF !Empty( qqTipDok )
            IF idtipdok <> qqTipDok
               skip
               LOOP
            ENDIF
         ENDIF

         IF !Empty( cIdFirma )
            IF idfirma <> cIdFirma; skip; loop; ENDIF
         ENDIF

         IF !Empty( qqPartn )
            seek_fakt_doks( fakt->IdFirma, fakt->idtipdok, fakt->brdok )
            SELECT fakt
            IF !( fakt_doks->partner = qqPartn )
               SKIP
               LOOP
            ENDIF
         ENDIF

         IF !Empty( cK1 )
            IF ck1 <> K1
               SKIP
               LOOP
            ENDIF
         ENDIF
         IF !Empty( cK2 )
            IF ck2 <> K2
               SKIP
               LOOP
            ENDIF
         ENDIF

         IF !Empty( cIdRoba )
            IF cRR <> "F"
               IF idtipdok = "0"
                  // ulaz
                  nUl += kolicina
                  IF fSaberikol .AND. !( roba->K2 = 'X' )
                     nKU += kolicina
                  ENDIF
               ELSEIF idtipdok = "1"
                  // izlaz faktura
                  // za fakture na osnovu optpremince ne ra~unaj izlaz
                  IF !( serbr = "*" .AND. idtipdok == "10" )
                     nIzl += kolicina
                     IF fSaberikol .AND. !( roba->K2 = 'X' )
                        nKI += kolicina
                     ENDIF
                  ENDIF
               ELSEIF idtipdok $ "20#27"
                  IF serbr = "*"
                     nRezerv += kolicina
                     IF fSaberikol .AND. !( roba->K2 = 'X' )
                        nKI += kolicina
                     ENDIF
                  ENDIF
               ELSEIF idtipdok == "21"
                  nRevers += kolicina
                  IF fSaberikol .AND. !( roba->K2 = 'X' )
                     nKI += kolicina
                  ENDIF
               ENDIF
            ELSE
               // za fakture na osnovu otpremince ne ra~unaj izlaz
               IF ( serbr = "*" .AND. idtipdok == "10" )
                  nIzl += kolicina
                  IF fSaberikol .AND. !( roba->K2 = 'X' )
                     nKI += kolicina
                  ENDIF
               ENDIF
            ENDIF // crr=="F"
         ENDIF  // empty(
         SKIP
      ENDDO

      IF !Empty( cIdRoba )

         fakt_set_pozicija_sif_roba( cIdRoba, cSintetika == "D" )

         IF ( FieldPos( "MINK" ) ) <> 0
            nMink := roba->mink
         ELSE
            nMink := 0
         ENDIF

         SELECT FAKT

         IF PRow() > 61 - iif( cProred = "D", 1, 0 )
            fakt_zagl_stanje_robe()
         ENDIF

         IF ( cMink <> "D" .AND. ( cSaldo0 == "D" .OR. Round( nUl - nIzl, 4 ) <> 0 ) ) .OR. ; // ne prikazuj stavke 0
               ( cMink == "D" .AND. nMink <> 0 .AND. ( nUl - nIzl - nMink ) < 0 )

            IF cMink == "O" .AND. nMink == 0 .AND. Round( nUl - nIzl, 4 ) == 0
               LOOP
            ENDIF

            IF cProred == "D"
               ? Space( gnLMarg )
               ?? m
            ENDIF

            IF cMink == "O" .AND. nMink <> 0 .AND. ( nUl - nIzl - nMink ) < 0
               B_ON
            ENDIF

            ? Space( gnLMarg ); ?? Str( ++nRbr, 4 ), cIdRoba, PadR( ROBA->naz, 40 )

            nCol0 := PCol() - 11

            IF fSaberiKol .AND. lBezUlaza
               nCol1 := PCol() + 1
            ENDIF

            @ PRow(), PCol() + 1 SAY nUl - nIzl PICT __PIC_KOL
            @ PRow(), PCol() + 1 SAY roba->jmj

            IF cTipVPC == "2"
               _cijena := roba->vpc2
            ELSE
               _cijena := IF ( !Empty( cIdFirma ), fakt_mpc_iz_sifrarnika(), roba->vpc )
            ENDIF

            IF !lBezUlaza
               @ PRow(), PCol() + 1 SAY _cijena PICT __PIC_DEM
               nCol1 := PCol() + 1
               @ PRow(), nCol1 SAY ( nUl - nIzl ) * _cijena PICT __PIC_IZN
            ENDIF

            nIzn += ( nUl - nIzl ) * _cijena

            IF cMink <> "N" .AND. nMink > 0
               ?
               @ PRow(), ncol0    SAY PadR( "min.kolic:", Len( fakt_pic_kolicina() ) )
               @ PRow(), PCol() + 1 SAY nMink  PICT __PIC_KOL
            ENDIF

            IF cMink == "O" .AND. nMink <> 0 .AND. ( nUl - nIzl - nMink ) < 0
               B_OFF
            ENDIF
         ENDIF

      ENDIF

   ENDDO

   IF PRow() > 59
     fakt_zagl_stanje_robe()
   ENDIF

   IF !lBezUlaza
      ? Space( gnLMarg ); ?? m
      ? Space( gnLMarg ); ?? " Ukupno:"
      @ PRow(), nCol1 SAY nIzn  PICT fakt_pic_iznos()
   ENDIF

   ? Space( gnLMarg ); ?? m

   IF fSaberikol
      ? Space( gnLMarg ); ?? " Ukupno (kolicine):"
      @ PRow(), nCol1    SAY nKU - nKI   PICTURE fakt_pic_kolicina()
   ENDIF
   ? Space( gnLMarg ); ?? m
   FF
   ENDPRINT

   my_close_all_dbf()

   RETURN .T.


FUNCTION fakt_zagl_stanje_robe()

   IF nStr > 0
      FF
   ENDIF
   ?
   P_COND
   ? Space( 4 ), "FAKT: "
   ?? "Stanje"
   ?? " robe na dan", Date(), "      za period od", dDatOd, "-", dDatDo, Space( 6 ), "Strana:", Str( ++nStr, 3 )

   ?
   IF cRR == "D"
      P_COND2
   ELSE
      P_COND
   ENDIF

   ? Space( gnLMarg ); IspisFirme( cIdFirma )
   IF !Empty( qqRoba )
      ? Space( gnLMarg )
      ?? "Roba:", qqRoba
   ENDIF

   IF !Empty( cK1 )
      ?
      ? Space( gnlmarg ), "- Roba sa osobinom K1:", ck1
   ENDIF
   IF !Empty( cK2 )
      ?
      ? Space( gnlmarg ), "- Roba sa osobinom K2:", ck2
   ENDIF

   //IF glDistrib .AND. !Empty( cIdDist )
    //  ?
  //    ? Space( gnlmarg ), "- kontrola distributera:", cIdDist
   //ENDIF

   ?
   IF cTipVPC == "2"
      ? Space( gnlmarg )
      ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: " + cTipVPC
   ENDIF
   ?
   ? Space( gnLMarg )
   ?? m
   ? Space( gnLMarg )
   IF lBezUlaza
      ?? "R.br  Sifra       Naziv                                 " + "   Stanje      jmj     "
   ELSE
      ?? "R.br  Sifra       Naziv                                 " + "   Stanje      jmj     Cij.      Iznos"
   ENDIF

   ? Space( gnLMarg )
   ?? m

   RETURN .T.



//STATIC FUNCTION _o_tables()

   // o_fakt_doks_dbf()
   // o_tarifa()
   // o_partner()
   // o_sifk()
   // o_sifv()
   // o_roba()
   // o_rj()
   // o_fakt_dbf()
   //SET ORDER TO TAG "3"

//   RETURN .T.
