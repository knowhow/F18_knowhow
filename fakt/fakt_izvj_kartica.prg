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



FUNCTION fakt_kartica()

   LOCAL cIdfirma, nRezerv, nRevers
   LOCAL nul, nizl, nRbr, cRR, nCol1 := 0, cKolona, cBrza := "D"
   LOCAL cPredh := "2"
   LOCAL lpickol := "@Z " + fakt_pic_kolicina()
   LOCAL _params := fakt_params()

   PRIVATE m := ""

   my_close_all_dbf()

   //o_sifk()
   //o_sifv()
   //select_o_partner()
   //select_o_roba()
   //o_tarifa()
   o_rj()

   IF _params[ "fakt_objekti" ]
      o_fakt_objekti()
   ENDIF

   o_fakt_doks()
   o_fakt()

   SELECT fakt
   //IF fId_J
    //  SET ORDER TO TAG "3J"
      // idroba_J+Idroba+dtos(datDok)
   //ELSE
      SET ORDER TO TAG "3"
      // idroba+dtos(datDok)
   //ENDIF

   cIdfirma := self_organizacija_id()
   PRIVATE qqRoba := ""
   PRIVATE dDatOd := CToD( "" )
   PRIVATE dDatDo := Date()
   PRIVATE cPPartn := "N"

   IF _params[ "fakt_objekti" ]
      _objekat_id := Space( 10 )
   ENDIF

   _c1 := _c2 := _c3 := Space( 20 )
   _n1 := _n2 := 0

   Box( "#IZVJEŠTAJ:KARTICA", 17, 63 )

   cPPC := "N"

   cOstran := "N"

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()
   RPar( "c1", @cIdFirma )
   RPar( "d1", @dDatOd )
   RPar( "d2", @dDatDo )
   RPar( "cP", @cPPC )
   RPar( "Cp", @cPPartn )

   cRR := "N"

   PRIVATE cTipVPC := "1"

   PRIVATE ck1 := cK2 := Space( 4 )   // atributi
   PRIVATE qqPartn := Space( 20 )

   qqTarife := ""
   qqNRobe := ""
   // cSort:="S"

   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Brza kartica (D/N)" GET cBrza PICT "@!" VALID cBrza $ "DN"
      READ
      IF gNW $ "DR"
         @ m_x + 2, m_y + 2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. cidfirma == self_organizacija_id() .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      ENDIF

      IF cBrza == "D"
         RPar( "c3", @qqRoba )
         qqRoba := PadR( qqRoba, 10 )
         //IF fID_J
          //  @ m_x + 3, m_y + 2 SAY "Roba " GET qqRoba PICT "@!" valid {|| P_Roba( @qqRoba ), qqRoba := roba->id_j, .T. }
         //ELSE
            @ m_x + 3, m_y + 2 SAY "Roba " GET qqRoba PICT "@!" VALID P_Roba( @qqRoba )
         //ENDIF
      ELSE
         RPar( "c2", @qqRoba )
         qqRoba := PadR( qqRoba, 60 )
         @ m_x + 3, m_y + 2 SAY "Roba " GET qqRoba PICT "@!S40"
      ENDIF

      @ m_x + 4, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 4, Col() + 1 SAY "do"  GET dDatDo
      @ m_x + 5, m_y + 2 SAY "Prikaz rezervacija, reversa (D/N)   "  GET cRR   PICT "@!" VALID cRR $ "DN"
      @ m_x + 6, m_y + 2 SAY "Prethodno stanje (1-BEZ, 2-SA)      "  GET cPredh PICT"9" VALID cPredh $ "12"
      IF gVarC $ "12"
         @ m_x + 7, m_y + 2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  GET cTipVpc PICT "@!" VALID cTipVPC $ "12"
      ENDIF

      @ m_x + 8, m_y + 2 SAY "Naziv partnera (prazno - svi)"  GET qqPartn   PICT "@!"
      IF fakt->( FieldPos( "K1" ) ) <> 0 .AND. gDK1 == "D"
         @ m_x + 9, m_y + 2 SAY "K1" GET  cK1 PICT "@!"
         @ m_x + 10, m_y + 2 SAY "K2" GET  cK2 PICT "@!"
      ENDIF

      @ m_x + 12, m_y + 2 SAY "Prikaz kretanja cijena D/N"  GET cPPC PICT "@!" VALID cPPC $ "DN"
      @ m_x + 13, m_y + 2 SAY8 "Prikaži partnera za svaku stavku"  GET cPPartn PICT "@!" VALID cPPartn $ "DN"

      IF cBrza == "N"
         @ m_x + 15, m_y + 2 SAY "Svaka kartica na novu stranicu? (D/N)"  GET cOstran VALID cOstran $ "DN" PICT "@!"
      ELSE
         cOstran := "N"
      ENDIF

      IF _params[ "fakt_objekti" ]
         @ m_x + 16, m_y + 2 SAY "Uslov po objektima (prazno-svi)" GET _objekat_id VALID Empty( _objekat_id ) .OR. P_fakt_objekti( @_objekat_id )
      ENDIF

      READ

      ESC_BCR

      //IF fID_J .AND. cBrza == "D"
    //     qqRoba := roba->( ID_J + ID )
    //  ENDIF

      cSintetika := "N"
      IF cSintetika == "D" .AND.  IF( cBrza == "D", ROBA->tip == "S", .T. )
         @ m_x + 17, m_y + 2 SAY8 "Sintetički prikaz? (D/N) " GET  cSintetika PICT "@!" VALID cSintetika $ "DN"
      ELSE
         cSintetika := "N"
      ENDIF
      read;ESC_BCR

      IF cBrza == "N"
        // IF fID_J
        //    aUsl1 := Parsiraj( qqRoba, "IdRoba_J" )
        // ELSE
            aUsl1 := Parsiraj( qqRoba, "IdRoba" )
      //   ENDIF
      ENDIF

      IF IIF( cBrza == "N", aUsl1 <> NIL, .T. )
         EXIT
      ENDIF

   ENDDO
   m := "---- ------------------ -------- "
   IF cPPArtn == "D"
      m += Replicate( "-", 20 ) + " "
   ENDIF


   m += "----------- ----------- -----------"
   IF cPPC == "D"
      m += " ----------- ----- -----------"
   ENDIF

   Params2()
   WPar( "c1", cIdFirma )
   WPar( "d1", dDatOd )
   WPar( "d2", dDatDo )
   WPar( "cP", cPPC )
   WPar( "Cp", cPPartn )

   IF cBrza == "D"
      WPar( "c3", Trim( qqRoba ) )
   ELSE
      WPar( "c2", Trim( qqRoba ) )
   ENDIF
   SELECT params
   USE

   BoxC()

   IF cPPArtn == "D"
      o_fakt_doks()
   ENDIF

   SELECT FAKT

   PRIVATE cFilt1 := ""

   cFilt1 := IF( cBrza == "N", aUsl1, ".t." )
   cFilt1 += IF( Empty( dDatOd ), "", ".and. DATDOK >= " + _filter_quote( dDatOd ) )
   cFilt1 += IF( Empty( dDatDo ), "", ".and. DATDOK <= " + _filter_quote( dDatDo ) )

   // hendliranje objekata
   IF _params[ "fakt_objekti" ] .AND. !Empty( _objekat_id )
      cFilt1 += ".and. fakt_objekat_id() == " + _filter_quote( _objekat_id )
   ENDIF

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF cFilt1 == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilt1
   ENDIF

   IF cBrza == "N"
      GO TOP
      EOF CRET
   ELSE
      SEEK qqRoba
   ENDIF

   START PRINT CRET
   ?
   P_12CPI
   ?? Space( gnLMarg ); ?? "FAKT: Kartice artikala na dan", Date(), "      za period od", dDatOd, "-", dDatDo
   ? Space( gnLMarg ); IspisFirme( cidfirma )
   IF !Empty( qqRoba )
      ? Space( gnLMarg )
      IF !Empty( qqRoba ) .AND. cBrza = "N"
         ?? "Uslov za artikal:", qqRoba
      ENDIF
   ENDIF

   IF _params[ "fakt_objekti" ] .AND. !Empty( _objekat_id )
      ? Space( gnLMarg )
      ?? "Uslov za objekat: ", AllTrim( _objekat_id ), fakt_objekat_naz( _objekat_id )
   ENDIF

   ?
   IF cTipVPC == "2" .AND.  roba->( FieldPos( "vpc2" ) <> 0 )
      ? Space( gnlmarg ); ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: " + cTipVPC
   ENDIF
   IF !Empty( cK1 )
      ?
      ? Space( gnlmarg ), "- Roba sa osobinom K1:", ck1
   ENDIF
   IF !Empty( cK2 )
      ?
      ? Space( gnlmarg ), "- Roba sa osobinom K2:", ck2
   ENDIF

   _cijena := 0
   _cijena2 := 0
   nRezerv := nRevers := 0

   qqPartn := Trim( qqPartn )
   IF !Empty( qqPartn )
      ?
      ?U Space( gnlmarg ), "- Prikaz za partnere čiji naziv počinje sa:"

      ? Space( gnlmarg ), " ", qqPartn
      ?
   ENDIF

   P_COND

   nStrana := 1
   lPrviProlaz := .T.

   DO WHILE !Eof()
      IF cBrza == "D"
         IF qqRoba <> IdRoba .AND. ;
               IF( cSintetika == "D", Left( qqRoba, gnDS ) != Left( IdRoba, gnDS ), .T. )
            // tekuci slog nije zeljena kartica
            EXIT
         ENDIF
      ENDIF
    //  IF fId_j
    //     cIdRoba := IdRoba_J + IdRoba
    //  ELSE
         cIdRoba := IdRoba
    //  ENDIF
      nUl := nIzl := 0
      nRezerv := nRevers := 0
      nRbr := 0
      nIzn := 0

    //  IF fId_j
    //     fakt_set_pozicija_sif_roba( SubStr( cIdRoba, 11 ), cSintetika == "D" )
    //  ELSE
         fakt_set_pozicija_sif_roba( cIdRoba, cSintetika == "D" )
    //  ENDIF
      SELECT FAKT

      IF cTipVPC == "2" .AND.  roba->( FieldPos( "vpc2" ) <> 0 )
         _cijena := roba->vpc2
      ELSE
         _cijena := if ( !Empty( cIdFirma ), fakt_mpc_iz_sifrarnika(), roba->vpc )
      ENDIF
      IF gVarC == "4" // uporedo vidi i mpc
         _cijena2 := roba->mpc
      ENDIF

      IF PRow() -dodatni_redovi_po_stranici() > 50; FF; ++nStrana; ENDIF

      ZaglKart( lPrviProlaz )
      lPrviProlaz := .F.

      IF cPredh == "2"     // dakle sa prethodnim stanjem
         PushWA()
         SELECT fakt
         SET FILTER TO
        // IF fID_J
        //    // TODO : pogledati
          //  SEEK cIdFirma + IF( cSintetika == "D" .AND. ROBA->tip == "S", RTrim( ROBA->id ), cIdRoba )
        // ELSE
            SEEK cIdFirma + IF( cSintetika == "D" .AND. ROBA->tip == "S", RTrim( ROBA->id ), cIdRoba )
        // ENDIF
         // DO-WHILE za cPredh=2
         DO WHILE !Eof() .AND. IF( cSintetika == "D" .AND. ROBA->tip == "S", ;
               Left( cIdRoba, gnDS ) == Left( IdROba, gnDS ), ;
               cIdRoba == IdRoba ) .AND. dDatOd > datdok

            IF !Empty( cK1 )
               IF ck1 <> K2 ; skip; loop; ENDIF
            ENDIF
            IF !Empty( cK2 )
               IF ck2 <> K2; skip; loop; ENDIF
            ENDIF
            IF !Empty( cidfirma ); IF idfirma <> cidfirma; skip; loop; end; END
            IF !Empty( qqPartn )
               SELECT fakt_doks; HSEEK fakt->( IdFirma + idtipdok + brdok )
               SELECT fakt; IF !( fakt_doks->partner = qqPartn ); skip; loop; ENDIF
            ENDIF

            IF !Empty( cIdRoba )
               IF idtipdok = "0"  // ulaz
                  nUl += kolicina
               ELSEIF idtipdok = "1"   // izlaz faktura
                  IF !( Left( serbr, 1 ) == "*" .AND. idtipdok == "10" )  // za fakture na osnovu optpremince ne ra~unaj izlaz
                     nIzl += kolicina
                  ENDIF
               ELSEIF idtipdok $ "20#27" .AND. cRR == "D"
                  IF serbr = "*"
                     nRezerv += kolicina
                  ENDIF
               ELSEIF idtipdok == "21" .AND. cRR == "D"
                  nRevers += kolicina
               ENDIF
            ENDIF
            SKIP 1
         ENDDO  // za do-while za cPredh="2"
         ? Space( gnLMarg ); ?? Str( nRbr, 3 ) + ".   " + idfirma + PadR( "  PRETHODNO STANJE", 23 )
         IF cppartn == "D"
            @ PRow(), PCol() + 1 SAY Space( 20 )
         ENDIF
         @ PRow(), PCol() + 1 SAY nUl PICT lpickol
         @ PRow(), PCol() + 1 SAY ( nIzl + nRevers + nRezerv ) PICT lpickol
         @ PRow(), PCol() + 1 SAY nUl - ( nIzl + nRevers + nRezerv ) PICT lpickol
         PopWA()
      ENDIF

      DO WHILE !Eof() .AND. IF( cSintetika == "D" .AND. ROBA->tip == "S", ;
            Left( cIdRoba, gnDS ) == Left( IdRoba, gnDS ), cIdRoba == IdRoba )
         cKolona := "N"

         IF !Empty( cidfirma ); IF idfirma <> cidfirma; skip; loop; end; END
         IF !Empty( cK1 ); IF ck1 <> K1 ; skip; loop; end; END // uslov ck1
         IF !Empty( cK2 ); IF ck2 <> K2; skip; loop; end; END // uslov ck2

         IF !Empty( qqPartn )
            SELECT fakt_doks; HSEEK fakt->( IdFirma + idtipdok + brdok )
            SELECT fakt; IF !( fakt_doks->partner = qqPartn ); skip; loop; ENDIF
         ENDIF

         IF !Empty( cIdRoba )
            IF idtipdok = "0"  // ulaz
               nUl += kolicina
               cKolona := "U"
            ELSEIF idtipdok = "1"   // izlaz faktura
               IF !( Left( serbr, 1 ) == "*" .AND. idtipdok == "10" )  // za fakture na osnovu optpremince ne ra~unaj izlaz
                  nIzl += kolicina
               ENDIF
               cKolona := "I"
            ELSEIF idtipdok $ "20#27" .AND. cRR == "D"
               IF serbr = "*"
                  nRezerv += kolicina
                  cKolona := "R1"
               ENDIF
            ELSEIF idtipdok == "21" .AND. cRR == "D"
               nRevers += kolicina
               cKolona := "R2"
            ENDIF

            IF cKolona != "N"

               IF PRow() -dodatni_redovi_po_stranici() > 55; FF; ++nStrana; ZaglKart(); ENDIF

               ? Space( gnLMarg ); ?? Str( ++nRbr, 3 ) + ".   " + idfirma + "-" + idtipdok + "-" + brdok + Left( serbr, 1 ) + "  " + DToC( datdok )

               IF cPPartn == "D"
                  SELECT fakt_doks
                  HSEEK fakt->( IdFirma + idtipdok + brdok )
                  SELECT fakt
                  @ PRow(), PCol() + 1 SAY PadR( fakt_doks->Partner, 20 )
               ENDIF

               @ PRow(), PCol() + 1 SAY IF( cKolona == "U", kolicina, 0 ) PICT lpickol
               @ PRow(), PCol() + 1 SAY IF( cKolona != "U", kolicina, 0 ) PICT lpickol
               @ PRow(), PCol() + 1 SAY nUl - ( nIzl + nRevers + nRezerv ) PICT lpickol
               IF cPPC == "D"
                  @ PRow(), PCol() + 1 SAY Cijena PICT fakt_pic_iznos()
                  @ PRow(), PCol() + 1 SAY Rabat  PICT "99.99"
                  @ PRow(), PCol() + 1 SAY Cijena * ( 1 -Rabat / 100 ) PICT fakt_pic_iznos()
               ENDIF
            ENDIF

            IF FieldPos( "k1" ) <> 0  .AND. gDK1 == "D"
               @ PRow(), PCol() + 1 SAY k1
            ENDIF
            IF FieldPos( "k2" ) <> 0  .AND. gDK2 == "D"
               @ PRow(), PCol() + 1 SAY k2
            ENDIF

            IF roba->tip = "U"
               aMemo := ParsMemo( txt )
               aTxtR := SjeciStr( aMemo[ 1 ], 60 )   // duzina naziva + serijski broj
               FOR ui = 1 TO Len( aTxtR )
                  ? Space( gNLMarg )
                  @ PRow(), PCol() + 7 SAY aTxtR[ ui ]
               NEXT
            ENDIF

         ENDIF

         SKIP
      ENDDO
      // GLAVNA DO-WHILE

      IF PRow() -dodatni_redovi_po_stranici() > 55; FF; ++nStrana; ZaglKart(); ENDIF

      ? Space( gnLMarg ); ?? m
      ? Space( gnLMarg ) + "CIJENA:            " + Str( _cijena, 12, 3 )
      IF gVarC == "4" // uporedo i mpc
         ? Space( gnLMarg ) + "MPC   :            " + Str( _cijena2, 12, 3 )
      ENDIF
      IF cRR == "D"
         ? Space( gnLMarg ) + "Rezervisano:       " + Str( nRezerv, 12, 3 )
         ? Space( gnLMarg ) + "Na reversu:        " + Str( nRevers, 12, 3 )
      ENDIF
      ? Space( gnLMarg ) + PadR( "STANJE" + IF( cRR == "D", " (OSTALO):", ":" ), 19 ) + Str( nUl - ( nIzl + nRevers + nRezerv ),12, 3 )
      ? Space( gnLMarg ) + "IZNOS:             " + Str( ( nUl - ( nIzl + nRevers + nRezerv ) ) * _cijena, 12, 3 )
      IF gVarC == "4"
         ? Space( gnLMarg ) + "IZNOS MPV:         " + Str( ( nUl - ( nIzl + nRevers + nRezerv ) ) * _cijena2, 12, 3 )
      ENDIF
      ? Space( gnLMarg ); ?? m
      ?
      IF cOstran == "D"    // kraj kartice => zavrsavam stranicu
         FF; ++nStrana
      ENDIF
   ENDDO

   IF cOstran != "D"
      FF
   ENDIF

   ENDPRINT
   my_close_all_dbf()

   RETURN


STATIC FUNCTION ZaglKart( lIniStrana )

   STATIC nZStrana := 0

   IF lIniStrana = NIL; lIniStrana := .F. ; ENDIF
   IF lIniStrana; nZStrana := 0; ENDIF
   B_ON
   IF nStrana > nZStrana
      ?? Space( 66 ) + "Strana: " + AllTrim( Str( nStrana ) )
   ENDIF
   ?
   ? Space( gnLMarg )
   ?? m
   ? Space( gnLMarg )
   ?? "ŠIFRA:"
   //IF fID_J
  //    ?? IF( cSintetika == "D" .AND. ROBA->tip == "S", ROBA->ID_J, Left( cidroba, 10 ) ), PadR( ROBA->naz, 40 ), " (" + ROBA->jmj + ")"
   //ELSE
      ?? IIF( cSintetika == "D" .AND. ROBA->tip == "S", ROBA->id, cidroba ), PadR( ROBA->naz, 40 ), " (" + ROBA->jmj + ")"
  // ENDIF
   ? Space( gnLMarg ); ?? m
   B_OFF
   ? Space( gnLMarg )
   ?? "R.br  RJ Br.dokumenta   Dat.dok."
   IF cPPartn == "D"
      ?? PadC( "Partner", 21 )
   ENDIF
   ?? "     Ulaz       Izlaz      Stanje  "
   IF cPPC == "D"
      ?? "     Cijena   Rab%   C-Rab"
   ENDIF

   ? Space( gnLMarg ); ?? m
   nZStrana = nStrana

   RETURN
