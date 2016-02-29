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



// -------------------------------------------------------
// izvjestaj stanje robe
// -------------------------------------------------------
FUNCTION fakt_stanje_robe()

   LOCAL fSaberiKol, nKU, nKI
   LOCAL cDDokOtpr
   PRIVATE cIdFirma
   PRIVATE qqroba, ddatod, ddatdo, nRezerv, nRevers
   PRIVATE nUl, nIzl, nRbr, cRR, nCol1 := 0, nCol0 := 50
   PRIVATE m := ""
   PRIVATE nStr := 0
   PRIVATE cProred := "N"
   PRIVATE qqTipdok := "  "

   lBezUlaza := .F.

   _o_tables()

   cIdfirma := gFirma
   qqRoba := ""
   dDatOd := CToD( "" )
   dDatDo := Date()
   cSaldo0 := "N"
   cDDokOtpr := "D"
   qqPartn := Space( 20 )

   Box(, 13, 66 )

   O_PARAMS
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
      IF gNW $ "DR"
         @ m_x + 1, m_y + 2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. cidfirma == gFirma .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF

      @ m_x + 2, m_y + 2 SAY "Roba   "  GET qqRoba   PICT "@!S40"
      @ m_x + 3, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 3, Col() + 1 SAY "do"  GET dDatDo
      @ m_x + 4, m_y + 2 SAY "gledati datum (D)dok. (O)otpr. (V)value:" GET cDDokOtpr ;
         VALID cDDokOtpr $ "DOV" PICT "@!"

      cRR := "N"
      xPos := 5
      @ m_x + xPos, m_y + 2 SAY "Prikaz stavki sa stanjem 0 (D/N)    "  GET cSaldo0 PICT "@!" VALID cSaldo0 $ "DN"
      IF gVarC $ "12"
         @ m_x + xPos + 1, m_y + 2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  GET cTipVpc PICT "@!" VALID cTipVPC $ "12"
      ENDIF

      IF fakt->( FieldPos( "K1" ) ) <> 0 .AND. gDK1 == "D"
         @ m_x + xPos + 3, m_y + 2 SAY "K1" GET  cK1 PICT "@!"
         @ m_x + xPos + 4, m_y + 2 SAY "K2" GET  cK2 PICT "@!"
      ENDIF

      @ m_x + xPos + 5, m_y + 2 SAY8 "Prikaz samo kritičnih zaliha (D/N/O) ?" GET cMinK PICT "@!" VALID cMink $ "DNO"
      @ m_x + xPos + 7, m_y + 2 SAY "Napraviti prored (D/N)    "  GET cProred PICT "@!" VALID cProred $ "DN"

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

   SELECT PARAMS
   Params2()
   qqRoba := Trim( qqRoba )
   WPar( "c1", cIdFirma )
   WPar( "c2", qqRoba )
   WPar( "c7", qqPartn )
   WPar( "c8", qqTipDok )
   WPar( "d1", dDatOd )
   WPar( "d2", dDatDo )
   WPar( "d3", cDDokOtpr )
   SELECT params; USE

   BoxC()

   fSMark := .F.
   IF ( Right( qqRoba, 1 ) == "*" )
      // izvrsena je markacija robe ..
      fSMark := .T.
   ENDIF

   // ako ne postoji polje datuma isporuke
   // uvijek gledaj dokumente
   IF fakt_doks->( FieldPos( "DAT_ISP" ) ) = 0
      cDDokOtpr := "D"
   ENDIF

   SELECT FAKT

   PRIVATE cFilt := ".t."


   IF aUsl1 <> ".t."
      cFilt += ".and." + aUsl1
   ENDIF

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )

      // sort po datumu dokumenta
      IF cDDokOtpr == "D"
         cFilt += ".and. DatDok>=" + _filter_quote( dDatOd ) + ;
            ".and. DatDok<=" + _filter_quote( dDatDo )
      ENDIF

   ENDIF

   IF cFilt == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilt
   ENDIF

   GO TOP
   EOF CRET

   cSintetika := "N"

   nKU := nKI := 0

   START PRINT CRET

   ZaglSrobe()

   _cijena := 0

   nRbr := 0
   nIzn := 0
   nRezerv := nRevers := 0
   qqPartn := Trim( qqPartn )
   cidfirma := Trim( cidfirma )

   nH := 0

   DO WHILE !Eof()

      // provjeri datumski valutu, otpremnicu
      IF cDDokOtpr == "O"
         SELECT fakt_doks
         SEEK fakt->idfirma + fakt->idtipdok + fakt->brdok
         IF fakt_doks->dat_otpr < dDatOd .OR. fakt_doks->dat_otpr > dDatDo
            SELECT fakt
            SKIP
            LOOP
         ENDIF
         SELECT fakt
      ENDIF

      IF cDDokOtpr == "V"
         SELECT fakt_doks
         SEEK fakt->idfirma + fakt->idtipdok + fakt->brdok
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

      DO WHILE !Eof()  .AND. cIdRoba == IdRoba

         // provjeri datumski valutu, otpremnicu
         IF cDDokOtpr == "O"
            SELECT fakt_doks
            SEEK fakt->idfirma + fakt->idtipdok + fakt->brdok
            IF fakt_doks->dat_otpr < dDatOd .OR. fakt_doks->dat_otpr > dDatDo
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            SELECT fakt
         ENDIF

         IF cDDokOtpr == "V"
            SELECT fakt_doks
            SEEK fakt->idfirma + fakt->idtipdok + fakt->brdok
            IF fakt_doks->dat_val < dDatOd .OR. fakt_doks->dat_val > dDatDo
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            SELECT fakt
         ENDIF

         IF !Empty( qqTipDok )
            IF idtipdok <> qqTipDok
               skip; LOOP
            ENDIF
         ENDIF

         IF !Empty( cidfirma )
            IF idfirma <> cidfirma; skip; loop; ENDIF
         ENDIF

         IF !Empty( qqPartn )
            SELECT fakt_doks
            HSEEK fakt->( IdFirma + idtipdok + brdok )
            SELECT fakt
            IF !( fakt_doks->partner = qqPartn )
               SKIP
               LOOP
            ENDIF
         ENDIF

         // atributi!!!!!!!!!!!!!
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

         NSRNPIdRoba( cIdRoba, cSintetika == "D" )

         SELECT ROBA

         IF ( FieldPos( "MINK" ) ) <> 0
            nMink := roba->mink
         ELSE
            nMink := 0
         ENDIF

         SELECT FAKT

         IF PRow() > 61 - iif( cProred = "D", 1, 0 )
            ZaglSRobe()
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

            ? Space( gnLMarg ); ?? Str( ++nRbr, 4 ), cidroba, PadR( ROBA->naz, 40 )

            nCol0 := PCol() -11

            IF fSaberiKol .AND. lBezUlaza
               nCol1 := PCol() + 1
            ENDIF

            @ PRow(), PCol() + 1 SAY nUl - nIzl PICT __PIC_KOL
            @ PRow(), PCol() + 1 SAY roba->jmj

            IF cTipVPC == "2" .AND.  roba->( FieldPos( "vpc2" ) <> 0 )
               _cijena := roba->vpc2
            ELSE
               _cijena := if ( !Empty( cIdFirma ), fakt_mpc_iz_sifrarnika(), roba->vpc )
            ENDIF

            IF !lBezUlaza
               @ PRow(), PCol() + 1 SAY _cijena PICT __PIC_DEM
               nCol1 := PCol() + 1
               @ PRow(), nCol1 SAY ( nUl - nIzl ) * _cijena PICT __PIC_IZN
            ENDIF

            nIzn += ( nUl - nIzl ) * _cijena

            IF cMink <> "N" .AND. nMink > 0
               ?
               @ PRow(), ncol0    SAY PadR( "min.kolic:", Len( pickol ) )
               @ PRow(), PCol() + 1 SAY nMink  PICT __PIC_KOL
            ENDIF

            IF cMink == "O" .AND. nMink <> 0 .AND. ( nUl - nIzl - nMink ) < 0
               B_OFF
            ENDIF
         ENDIF

      ENDIF

   ENDDO

   IF PRow() > 59; ZaglSRobe(); ENDIF

   IF !lBezUlaza
      ? Space( gnLMarg ); ?? m
      ? Space( gnLMarg ); ?? " Ukupno:"
      @ PRow(), nCol1 SAY nIzn  PICT picdem
   ENDIF

   ? Space( gnLMarg ); ?? m

   IF fSaberikol
      ? Space( gnLMarg ); ?? " Ukupno (kolicine):"
      @ PRow(), nCol1    SAY nKU - nKI   PICTURE pickol
   ENDIF
   ? Space( gnLMarg ); ?? m
   FF
   ENDPRINT

   my_close_all_dbf()

   RETURN


FUNCTION ZaglSRobe()

   LOCAL _rj_tip := ""

   IF rj->( FieldPos( "tip" ) ) <> 0
      _rj_tip := rj->tip
   ENDIF

   IF nstr > 0
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

   ? Space( gnLMarg ); IspisFirme( cidfirma )
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

   IF glDistrib .AND. !Empty( cIdDist )
      ?
      ? Space( gnlmarg ), "- kontrola distributera:", cIdDist
   ENDIF

   ?
   IF cTipVPC == "2" .AND.  roba->( FieldPos( "vpc2" ) <> 0 )
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
      ?? "R.br  Sifra       Naziv                                 " + "   Stanje      jmj     " + IF( _rj_tip $ "M1#M2" .AND. !Empty( cIdFirma ), "Cij.", if( IsPDV(), " PC ", "VPC " ) ) + "      Iznos"
   ENDIF

   ? Space( gnLMarg )
   ?? m

   RETURN .T.



STATIC FUNCTION _o_tables()

   O_FAKT_DOKS
   O_TARIFA
   O_PARTN
   O_SIFK
   O_SIFV
   O_ROBA
   O_RJ
   O_FAKT
   SET ORDER TO TAG "3"

   RETURN .T.
