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


// -----------------------------------------------------
// prenos dokumenata
// -----------------------------------------------------
FUNCTION PrenosFin()

   LOCAL cStranaBitna
   LOCAL lStranaBitna
   PRIVATE fK1 := fk2 := fk3 := fk4 := "N"

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

   PRIVATE cK1 := cK2 := "9"
   PRIVATE cK3 := cK4 := "99"

   IF my_get_from_ini( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
      ck3 := "999"
   ENDIF

   O_PKONTO
   P_PKonto()

   cStranaBitna := "N"
   cKlDuguje := fetch_metric( "fin_klasa_duguje", NIL, "2" )
   cKlPotraz := fetch_metric( "fin_klasa_potrazuje", NIL, "5" )

   Box(, 12, 60 )
   nMjesta := 3
   ddatDo := Date()

   @ m_x + 1, m_y + 2 SAY "Navedite koje grupacije konta se isto ponasaju:"
   @ m_x + 3, m_y + 2 SAY "Grupisem konte na (broj mjesta)" GET nMjesta PICT "9"
   @ m_x + 5, m_y + 2 SAY "Datum do kojeg se promet prenosi" GET dDatDo

   IF fk1 == "D"; @ m_x + 7, m_y + 2   SAY "K1 (9 svi) :" GET cK1; ENDIF
   IF fk2 == "D"; @ m_x + 7, Col() + 2 SAY "K2 (9 svi) :" GET cK2; ENDIF
   IF fk3 == "D"; @ m_x + 8, m_y + 2   SAY "K3 (" + ck3 + " svi):" GET cK3; ENDIF
   IF fk4 == "D"; @ m_x + 8, Col() + 1 SAY "K4 (99 svi):" GET cK4; ENDIF

   @ m_x + 9, m_y + 2 SAY "Klasa konta duguje " GET cKlDuguje PICT "9"
   @ m_x + 10, m_y + 2 SAY "Klasa konta potraz " GET cKlPotraz PICT "9"

   @ m_x + 12, m_y + 2 SAY "Saldo strane valute je bitan ?" GET cStranaBitna ;
      PICT "@!" ;
      VALID cStranaBitna $ "DN"

   READ
   ESC_BCR

   BoxC()

   // snimi parametre
   set_metric( "fin_klasa_duguje", NIL, cKlDuguje )
   set_metric( "fin_klasa_potrazuje", NIL, cKlPotraz )

   lStranaBitna := ( cStranaBitna == "D" )

   IF ck1 == "9"
      ck1 := ""
   ENDIF
   IF ck2 == "9"
      ck2 := ""
   ENDIF
   IF ck3 == REPL( "9", Len( ck3 ) )
      ck3 := ""
   ELSE
      ck3 := k3u256( ck3 )
   ENDIF
   IF ck4 == "99"
      ck4 := ""
   ENDIF

   lPrenos4 := lPrenos5 := lPrenos6 := .F.

   SELECT ( F_PKONTO )
   GO TOP

   DO WHILE !Eof()
      IF tip == "4"
         lPrenos4 := .T.
      ENDIF
      IF tip == "5"
         lPrenos5 := .T.
      ENDIF
      IF tip == "6"
         lPrenos6 := .T.
      ENDIF
      SKIP 1
   ENDDO

   cFilter := ".t."

   IF fk1 == "D" .AND. Len( ck1 ) <> 0
      cFilter += " .and. k1='" + ck1 + "'"
   ENDIF

   IF fk2 == "D" .AND. Len( ck2 ) <> 0
      cFilter += " .and. k2='" + ck2 + "'"
   ENDIF

   IF fk3 == "D" .AND. Len( ck3 ) <> 0
      cFilter += " .and. k3='" + ck3 + "'"
   ENDIF

   IF fk4 == "D" .AND. Len( ck4 ) <> 0
      cFilter += " .and. k4='" + ck4 + "'"
   ENDIF

   IF lPrenos4 .OR. lPrenos5 .OR. lPrenos6
      // SELECT ( F_SUBAN )
      // usex ( "suban" )
      find_suban_by_broj_dokumenta( gFirma )
      IF lPrenos4
         INDEX ON idfirma + idkonto + idpartner + idrj + funk + fond TO SUBSUB
      ENDIF
      IF lPrenos5
         INDEX ON idfirma + idkonto + idpartner + idrj + fond TO SUBSUB5
      ENDIF
      IF lPrenos6
         INDEX ON idfirma + idkonto + idpartner + idrj TO SUBSUB6
      ENDIF
      // USE
      // SELECT ( F_SUBAN )
      // usex ( "suban" )
      IF lPrenos4
         SET INDEX TO SUBSUB
         SET ORDER TO TAG "SUBSUB"
      ENDIF
      IF lPrenos5
         SET INDEX TO SUBSUB5
         SET ORDER TO TAG "SUBSUB5"
      ENDIF
      IF lPrenos6
         SET INDEX TO SUBSUB6
         SET ORDER TO TAG "SUBSUB6"
      ENDIF
   ELSE

      find_suban_by_konto_partner( gFirma )

      // SELECT ( F_SUBAN )
      // usex ( "suban" )
      // SET ORDER TO TAG "3" - IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)"
   ENDIF

   IF !( cFilter == ".t." )
      SELECT ( F_SUBAN )
      SET FILTER TO &( cFilter )
   ENDIF

   // SELECT ( F_PKONTO )
   // use ( "pkonto" )
   // SET ORDER TO TAG "ID"
   O_PKONTO

   O_FIN_PRIPR

   IF reccount2() <> 0
      MsgBeep( "Priprema mora biti prazna" )
      my_close_all_dbf()
   ENDIF

   my_dbf_zap()
   SET ORDER TO 0

   start_print()

   ?
   ? "Prolazim kroz bazu...."

   SELECT suban
   GO TOP

   lVodeSeRJ := FieldPos( "IDRJ" ) > 0

   Postotak( 1, RECCOUNT2(), "Generacija pocetnog stanja" )

   nProslo := 0

   GO TOP
   // idfirma, idkonto, idpartner, datdok

   dDatVal := CToD( "" )

   // ----------------------------------- petlja 1
   DO WHILE !Eof()

      nRbr := ZadnjiRBR()
      cIdFirma := idfirma

      // ----------------------------------- petlja 2
      DO WHILE !Eof() .AND. cIdFirma == IdFirma

         cIdKonto := IdKonto
         cTipPr := "0" // tip prenosa
         SELECT pkonto
         SEEK Left( cIdKonto, nMjesta )
         IF Found()        // 1 - otvorene stavke, 2 - saldo partnera,
            cTipPr := tip     // 3 - otv.st.bez sabiranja,
         ENDIF             // 4 - salda po konto+partner+rj+funkcija+fond
         // 5 - salda po konto+partner+rj+fond
         // 6 - salda po konto+partner+rj
         SELECT suban

         IF cTipPr == "4"    // mijenjam sort za ovu varijantu
            SET ORDER TO TAG "SUBSUB"
            SEEK cIdFirma + cIdKonto
         ELSEIF cTipPr == "5"    // mijenjam sort za ovu varijantu
            SET ORDER TO TAG "SUBSUB5"
            SEEK cIdFirma + cIdKonto
         ELSEIF cTipPr == "6"    // mijenjam sort za ovu varijantu
            SET ORDER TO TAG "SUBSUB6"
            SEEK cIdFirma + cIdKonto
         ELSEIF lPrenos4 .OR. lPrenos5 .OR. lPrenos6   // standardni sort
            SET ORDER TO TAG "3"
            SEEK cIdFirma + cIdKonto
         ENDIF

         nDin := nDem := 0
         // KONTO....pocinje

         // ----------------------------------- petlja 3
         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto

            cIdPartner := IdPartner
            ? "Konto:", cidkonto, "    Partner:", cidpartner
            IF cTipPr $ "2"    // sabirem po konto+partner
               nDin := 0
               nDem := 0
            ENDIF

            IF ctippr == "3"
               cSUBk1 := k1
               cSUBk2 := k2
               cSUBk3 := k3
               cSUBk4 := k4

               IF Otvst == " "
                  Scatter()
                  SELECT fin_pripr
                  APPEND BLANK
                  Gather()
                  RREPLACE rbr WITH  ++nRbr, ;
                     idvn WITH "00", ;
                     brnal WITH "00000001"

                  SELECT suban
               ENDIF

               Postotak( 2, ++nProslo )
               SKIP 1

            ELSE // tipppr=="3#

               cSUBk1 := k1
               cSUBk2 := k2
               cSUBk3 := k3
               cSUBk4 := k4

               // ----------------------------------- petlja 4
               DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner

                  cSUBk1 := k1
                  cSUBk2 := k2
                  cSUBk3 := k3
                  cSUBk4 := k4

                  // tip prenosa otvorene stavke - "1"

                  IF cTipPr == "1"
                     cBrDok := Brdok
                     nDin := 0
                     nDem := 0
                     cOtvSt := otvSt
                     // pretpostavlja se da sve stavke jednog
                     // dokumenta imaju isti znak - otvoren ili zatvoren
                     cTekucaRJ := ""
                     // ----------------------------------- petlja 5
                     dDatVal := CToD( "" )

                     DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. ;
                           IdPartner == cIdPartner .AND. BrDok == cBrDok

                        IF Empty( dDatVal )

                           // konto kupaca
                           IF ( Left( IdKonto, 1 ) == cKlDuguje ) .AND. ( d_p == "1" )
                              IF IsVindija()
                                 IF Empty( DatVal ) .AND. !( IsVindija() .AND. idvn == "09" )
                                    dDatVal := datdok
                                 ELSE
                                    dDatVal := fix_dat_var( datval, .T. )
                                 ENDIF
                              ELSE
                                 IF Empty( fix_dat_var( DatVal, .T. ) )
                                    dDatVal := datdok
                                 ELSE
                                    dDatVal := datval
                                 ENDIF
                              ENDIF
                           ENDIF

                           // konto dobavljaca
                           IF ( Left( IdKonto, 1 ) == cKlPotraz ) .AND. ( d_p == "2" )
                              IF Empty( DatVal )
                                 dDatVal := datdok
                              ELSE
                                 dDatVal := datval
                              ENDIF
                           ENDIF

                        ENDIF

                        nDin += iif( d_p == "1", iznosbhd, -iznosbhd )
                        nDem += iif( d_p == "1", iznosdem, -iznosdem )

                        IF lVodeSeRJ .AND. Empty( cTekucaRJ )
                           cTekucaRJ := IDRJ
                        ENDIF
                        Postotak( 2, ++nProslo )
                        SKIP 1

                     ENDDO // brdok
                     // ----------------------------------- petlja 5

                     // if cOtvSt=="9"
                     IF Round( nDin, 3 ) <> 0  // ako saldo nije 0
                        SELECT fin_pripr
                        APPEND BLANK
                        REPLACE  idfirma WITH cidfirma, ;
                           idvn WITH "00", ;
                           brnal WITH "00000001", ;
                           rbr WITH ++nRbr, ;
                           idkonto WITH cIdkonto, ;
                           idpartner WITH cidpartner, ;
                           brdok  WITH cBrDok, ;
                           datdok WITH dDatDo + 1, ;
                           datval WITH dDatVal

                        IF !( cFilter == ".t." )
                           REPLACE  k1 WITH cSUBk1, ;
                              k2 WITH cSUBk2, ;
                              k3 WITH cSUBk3, ;
                              k4 WITH cSUBk4
                        ENDIF

                        IF cTipPr == "1"
                           IF Left( IdKonto, 1 ) == cKlPotraz
                              // konto dobavljaca
                              REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                           ELSE
                              // konto kupca
                              REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                           ENDIF

                        ELSE
                           // cTipPr <> "1"
                           IF nDin >= 0
                              REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                           ELSE
                              REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                           ENDIF
                        ENDIF

                        IF lVodeSeRj
                           REPLACE IDRJ WITH cTekucaRJ
                        ENDIF
                        SELECT suban
                     ENDIF  // limit
                     // endif // cotvst=="9"

                  ENDIF  // cTipPr=="1"

                  IF cTipPr == "4"
                     cIDRJ := IDRJ
                     cFunk := FUNK
                     cFond := FOND
                     nDin := 0; nDem := 0

                     // ----------------------------------- petlja 6
                     DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner ;
                           .AND. cIDRJ == IDRJ .AND. cFunk == FUNK .AND. cFond == FOND

                        nDin += iif( d_p == "1", iznosbhd, -iznosbhd )
                        nDem += iif( d_p == "1", iznosdem, -iznosdem )
                        Postotak( 2, ++nProslo )
                        SKIP 1

                     ENDDO // brdok
                     // ----------------------------------- petlja 6

                     IF Round( nDin, 3 ) <> 0  // ako saldo nije 0
                        SELECT fin_pripr
                        APPEND BLANK
                        REPLACE  idfirma WITH cidfirma, ;
                           idvn WITH "00", ;
                           brnal WITH "00000001", ;
                           rbr WITH ++nRbr, ;
                           idkonto WITH cIdkonto, ;
                           idpartner WITH cidpartner, ;
                           idrj WITH cIDRJ, ;
                           funk WITH cFunk, ;
                           fond WITH cFond, ;
                           datdok WITH dDatDo + 1

                        IF !( cFilter == ".t." )
                           REPLACE  k1 WITH cSUBk1, ;
                              k2 WITH cSUBk2, ;
                              k3 WITH cSUBk3, ;
                              k4 WITH cSUBk4
                        ENDIF
                        IF nDin >= 0
                           REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                        ELSE
                           REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                        ENDIF // ndin
                        SELECT suban
                     ENDIF  // limit

                  ENDIF  // cTipPr=="4"

                  IF cTipPr == "5"
                     cIDRJ := IDRJ
                     cFond := FOND
                     nDin := 0; nDem := 0

                     // ----------------------------------- petlja 6
                     DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner ;
                           .AND. cIDRJ == IDRJ .AND. cFond == FOND

                        nDin += iif( d_p == "1", iznosbhd, -iznosbhd )
                        nDem += iif( d_p == "1", iznosdem, -iznosdem )
                        Postotak( 2, ++nProslo )
                        SKIP 1

                     ENDDO // brdok
                     // ----------------------------------- petlja 6

                     IF Round( nDin, 3 ) <> 0  // ako saldo nije 0
                        SELECT fin_pripr
                        APPEND BLANK
                        REPLACE  idfirma WITH cidfirma, ;
                           idvn WITH "00", ;
                           brnal WITH "00000001", ;
                           rbr WITH ++nRbr, ;
                           idkonto WITH cIdkonto, ;
                           idpartner WITH cidpartner, ;
                           idrj WITH cIDRJ, ;
                           fond WITH cFond, ;
                           datdok WITH dDatDo + 1
                        IF !( cFilter == ".t." )
                           REPLACE  k1 WITH cSUBk1, ;
                              k2 WITH cSUBk2, ;
                              k3 WITH cSUBk3, ;
                              k4 WITH cSUBk4
                        ENDIF
                        IF nDin >= 0
                           REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                        ELSE
                           REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                        ENDIF // ndin
                        SELECT suban
                     ENDIF  // limit

                  ENDIF  // cTipPr=="5"

                  IF cTipPr == "6"
                     cIDRJ := IDRJ
                     nDin := 0; nDem := 0

                     // ----------------------------------- petlja 6
                     DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner ;
                           .AND. cIDRJ == IDRJ

                        nDin += iif( d_p == "1", iznosbhd, -iznosbhd )
                        nDem += iif( d_p == "1", iznosdem, -iznosdem )
                        Postotak( 2, ++nProslo )
                        SKIP 1

                     ENDDO // brdok
                     // ----------------------------------- petlja 6

                     IF Round( nDin, 3 ) <> 0  // ako saldo nije 0
                        SELECT fin_pripr
                        APPEND BLANK
                        REPLACE  idfirma WITH cidfirma, ;
                           idvn WITH "00", ;
                           brnal WITH "00000001", ;
                           rbr WITH ++nRbr, ;
                           idkonto WITH cIdkonto, ;
                           idpartner WITH cidpartner, ;
                           idrj WITH cIDRJ, ;
                           datdok WITH dDatDo + 1
                        IF !( cFilter == ".t." )
                           REPLACE  k1 WITH cSUBk1, ;
                              k2 WITH cSUBk2, ;
                              k3 WITH cSUBk3, ;
                              k4 WITH cSUBk4
                        ENDIF
                        IF nDin >= 0
                           REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                        ELSE
                           REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                        ENDIF // ndin
                        SELECT suban
                     ENDIF  // limit

                  ENDIF  // cTipPr=="6"

                  IF cTipPr $ "02"
                     IF d_p == "1"
                        nDin += iznosbhd
                        nDem += IznosDEM
                     ENDIF
                     IF d_p == "2"
                        nDin -= iznosbhd
                        nDem -= IznosDEM
                     ENDIF
                     SKIP 1
                     Postotak( 2, ++nProslo )
                  ENDIF

               ENDDO // konto, partner
               // ----------------------------------- petlja 4

            ENDIF    // tippr=="3"

            IF cTipPr == "2"  // sabirem po konto+partner
               IF ( Round( nDin, 2 ) <> 0 ) .OR. ( ( Round( nDem, 2 ) <> 0 ) .AND. lStranaBitna )
                  SELECT fin_pripr
                  APPEND BLANK
                  REPLACE rbr WITH  Str( ++nRbr, 5 ), ;
                     idkonto WITH cIdkonto, ;
                     idpartner WITH cidpartner, ;
                     datdok WITH dDatDo + 1, ;
                     idfirma WITH cidfirma, ;
                     idvn WITH "00", idtipdok WITH "00", ;
                     brnal WITH "00000001"
                  IF !( cFilter == ".t." )
                     REPLACE  k1 WITH cSUBk1, ;
                        k2 WITH cSUBk2, ;
                        k3 WITH cSUBk3, ;
                        k4 WITH cSUBk4
                  ENDIF

                  IF nDin >= 0
                     REPLACE d_p WITH "1", ;
                        iznosbhd WITH nDin, ;
                        iznosdem WITH nDem
                  ELSE
                     REPLACE d_p WITH "2", ;
                        iznosbhd WITH -nDin, ;
                        iznosdem WITH -nDem
                  ENDIF // ndin

                  SELECT suban
               ENDIF // <> 0
            ENDIF

         ENDDO // konto
         // ----------------------------------- petlja 3

         IF cTipPr == "0"  // sabirem po konto bez obzira na partnera
            IF ( Round( nDin, 2 ) <> 0 ) .OR. ( Round( nDem, 2 ) <> 0  .AND. lStranaBitna )
               SELECT fin_pripr
               APPEND BLANK
               REPLACE rbr WITH  Str( ++nRbr, 5 ), ;
                  idkonto WITH cIdkonto, ;
                  datdok WITH dDatDo + 1, ;
                  idfirma WITH cidfirma, ;
                  idvn WITH "00", idtipdok WITH "00", ;
                  brnal WITH "00000001"
               IF !( cFilter == ".t." )
                  REPLACE  k1 WITH cSUBk1, ;
                     k2 WITH cSUBk2, ;
                     k3 WITH cSUBk3, ;
                     k4 WITH cSUBk4
               ENDIF
               IF nDin >= 0
                  REPLACE d_p WITH "1", ;
                     iznosbhd WITH nDin, ;
                     iznosdem WITH nDem
               ELSE
                  REPLACE d_p WITH "2", ;
                     iznosbhd WITH -nDin, ;
                     iznosdem WITH -nDem
               ENDIF // ndin
               SELECT suban
            ENDIF // <> 0
         ENDIF

      ENDDO // firma
      // ----------------------------------- petlja 2

   ENDDO // eof
   // ----------------------------------- petlja 1

   Postotak( 0 )

   end_print()

   my_close_all_dbf()

   RETURN



// ----------------------------------------------------------------
// kreiranje pomocne tabele temp77
// ----------------------------------------------------------------
STATIC FUNCTION _cre_temp77()

   LOCAL _table := "temp77"
   LOCAL _ret := .T.
   LOCAL _dbf

   IF !File( my_home() + my_dbf_prefix() + _table + ".dbf" )

      _dbf := dbStruct()

      AAdd( _dbf, { "KONTO2", "C", 7, 0 } )
      AAdd( _dbf, { "PART2", "C", 6, 0 } )
      AAdd( _dbf, { "NSLOG", "N", 10, 0 } )

      dbCreate( my_home() + my_dbf_prefix() + _table + ".dbf", _dbf )

   ENDIF

   my_use_temp( "TEMP77", my_home() + my_dbf_prefix() + _table, .F., .T. )

   my_dbf_zap()

   RETURN .T.


// ---------------------------------------------------------------
// prebacivanje kartica
// ---------------------------------------------------------------
FUNCTION fin_prekart()

   LOCAL _arr := {}
   LOCAL _usl_kto, _usl_part, _tmp_dbf
   PRIVATE _id_konto := fetch_metric( "fin_preb_kart_id_konto", my_user(), Space( 60 ) )
   PRIVATE _id_partner := fetch_metric( "fin_preb_kart_id_partner", my_user(), Space( 60 ) )
   PRIVATE _dat_od := fetch_metric( "fin_preb_kart_dat_od", my_user(), CToD( "" ) )
   PRIVATE _dat_do := fetch_metric( "fin_preb_kart_dat_do", my_user(), CToD( "" ) )
   PRIVATE _id_firma := gFirma

   Msg( "Ova opcija omogucava prebacivanje svih ili dijela stavki sa#" + ;
      "postojeceg na drugi konto. Zeljeni konto je u tabeli prikazan#" + ;
      "u koloni sa zaglavljem 'Novi konto'. POSLJEDICA OVIH PROMJENA#" + ;
      "JE DA CE NALOZI KOJI SADRZE IZMIJENJENE STAVKE BITI RAZLICITI#" + ;
      "OD ODSTAMPANIH, PA SE PREPORUCUJE PONOVNA STAMPA TIH NALOGA." )

   AAdd ( _arr, { "Firma (prazno-sve)", "_id_firma",,, } )
   AAdd ( _arr, { "Konto (prazno-sva)", "_id_konto",, "@!S30", } )
   AAdd ( _arr, { "Partner (prazno-svi)", "_id_partner",, "@!S30", } )
   AAdd ( _arr, { "Za period od datuma", "_dat_od",,, } )
   AAdd ( _arr, { "          do datuma", "_dat_do",,, } )

   DO WHILE .T.

      IF !VarEdit( _arr, 9, 5, 17, 74, ;
            'POSTAVLJANJE USLOVA ZA IZDVAJANJE SUBANALITICKIH STAVKI', ;
            "B1" )
         my_close_all_dbf()
         RETURN
      ENDIF

      _usl_kto := Parsiraj( _id_konto, "idkonto" )
      _usl_part := Parsiraj( _id_partner, "idpartner" )

      IF _usl_kto <> NIL .AND. _usl_part <> NIL
         EXIT
      ELSEIF _usl_part <> NIL
         MsgBeep ( "Kriterij za partnera nije korektno postavljen!" )
      ELSEIF _usl_kto <> NIL
         MsgBeep ( "Kriterij za konto nije korektno postavljen!" )
      ELSE
         MsgBeep ( "Kriteriji za konto i partnera nisu korektno postavljeni!" )
      ENDIF

   ENDDO

   O_KONTO
   O_PARTN
   o_sint()
   SET ORDER TO TAG "2"
   o_anal()
   SET ORDER TO TAG "2"
   o_suban()

   _cre_temp77()

   SELECT ( F_SUBAN )

   _filter := ".t." + IF( !Empty( _id_firma ), ".and.IDFIRMA==" + dbf_quote( _id_firma ), "" ) + iif( !Empty( _dat_od ), ".and.DATDOK>=" + dbf_quote( _dat_do ), "" ) + ;
      IF( !Empty( _dat_do ), ".and.DATDOK<=" + dbf_quote( _dat_do ), "" ) + ".and." + _usl_kto + ".and." + _usl_part

   _filter := StrTran( _filter, ".t..and.", "" )

   IF !( _filter == ".t." )
      SET FILTER TO &( _filter )
   ENDIF

   GO TOP
   DO WHILE !Eof()

      _rec := dbf_get_rec()
      _rec[ "konto2" ] := _rec[ "idkonto" ]
      _rec[ "part2" ] := _rec[ "idpartner" ]
      _rec[ "nslog" ] := RecNo()

      SELECT TEMP77
      APPEND BLANK

      dbf_update_rec( _rec )

      SELECT F_SUBAN
      SKIP 1

   ENDDO

   SELECT TEMP77
   GO TOP

   ImeKol := { ;
      { "F.",            {|| IdFirma }, "IdFirma" }, ;
      { "VN",            {|| IdVN    }, "IdVN" }, ;
      { "Br.",           {|| BrNal   }, "BrNal" }, ;
      { "R.br",          {|| RBr     }, "rbr", {|| wRbr() }, {|| .T. } }, ;
      { "Konto",         {|| IdKonto }, "IdKonto", {|| .T. }, {|| P_Konto( @_IdKonto ), .T. } }, ;
      { "Novi konto",    {|| konto2  }, "konto2", {|| .T. }, {|| P_Konto( @_konto2 ), .T. } }, ;
      { "Partner",       {|| IdPartner }, "IdPartner", {|| .T. }, {|| P_Firma( @_idpartner ), .T. } }, ;
      { "Novi partner",  {|| part2  }, "part2", {|| .T. }, {|| P_Firma( @_part2 ), .T. } }, ;
      { "Br.veze ",      {|| BrDok   }, "BrDok" }, ;
      { "Datum",         {|| DatDok  }, "DatDok" }, ;
      { "D/P",           {|| D_P     }, "D_P" }, ;
      { ValDomaca(),     {|| Transform( IznosBHD, FormPicL( gPicBHD, 15 ) ) }, "iznos " + AllTrim( ValDomaca() ) }, ;
      { ValPomocna(),    {|| Transform( IznosDEM, FormPicL( gPicDEM, 10 ) ) }, "iznos " + AllTrim( ValPomocna() ) }, ;
      { "Opis",          {|| Opis      }, "OPIS" }, ;
      { "K1",            {|| k1      }, "k1" }, ;
      { "K2",            {|| k2      }, "k2" }, ;
      { "K3",            {|| k3iz256( k3 )      }, "k3" }, ;
      { "K4",            {|| k4      }, "k4" } ;
      }

   Kol := {}
   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   DO WHILE .T.

      Box(, 20, 77 )
      @ m_x + 19, m_y + 2 SAY "                         �                        �                   "
      @ m_x + 20, m_y + 2 SAY " <c-T>  Brisi stavku     � <ENTER>  Ispravi konto � <a-A> Azuriraj    "
      my_db_edit( "PPK", 20, 77, {|| EPPK() }, "", "Priprema za prebacivanje stavki", , , , , 2 )
      BoxC()

      IF RECCOUNT2() > 0
         i := KudaDalje( "ZAVRSAVATE SA PRIPREMOM PODATAKA. STA RADITI SA URADJENIM?", ;
            { "AZURIRATI PODATKE", ;
            "IZBRISATI PODATKE", ;
            "VRATIMO SE U PRIPREMU" } )
         DO CASE
         CASE i == 1
            AzurPPK()
            EXIT
         CASE i == 2
            EXIT
         CASE i == 3
            GO TOP
         ENDCASE
      ELSE
         EXIT
      ENDIF
   ENDDO

   my_close_all_dbf()

   RETURN ( NIL )



STATIC FUNCTION EPPK()

   LOCAL nTr2

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. reccount2() == 0
      RETURN DE_CONT
   ENDIF

   SELECT temp77

   DO CASE

   CASE Ch == K_CTRL_T

      IF Pitanje( "p01", "Zelite izbrisati ovu stavku ?", "D" ) == "D"
         my_delete()
         RETURN DE_REFRESH
      ENDIF

      RETURN DE_CONT

   CASE Ch == K_ENTER
      Scatter()
      IF !VarEdit( { { "Konto", "_konto2", "P_Konto(@_konto2)",, } }, 9, 5, 17, 74, ;
            'POSTAVLJANJE NOVOG KONTA', ;
            "B1" )
         RETURN DE_CONT
      ELSE
         my_rlock()
         Gather()
         my_unlock()
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_ALT_A
      AzurPPK()
      RETURN DE_REFRESH

   ENDCASE

   RETURN DE_CONT




STATIC FUNCTION AzurPPK()

   LOCAL lIndik1 := .F., lIndik2 := .F., nZapisa := 0, nSlog := 0, cStavka := "   "
   LOCAL hParams := hb_Hash()

   SELECT SUBAN
   SET FILTER TO
   GO TOP

   SELECT TEMP77

   Postotak( 1, RECCOUNT2(), "Azuriranje promjena na subanalitici",,, .T. )

   GO TOP

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_suban", "fin_anal", "fin_sint" }, .T. )
      run_sql_query( "ROLLBACK" )
      RETURN .F.
   ENDIF

   DO WHILE !Eof()

      // azuriraj subanalitiku
      IF ( TEMP77->idkonto != TEMP77->konto2 )
         SELECT SUBAN
         GO TEMP77->NSLOG
         _rec := dbf_get_rec()
         _rec[ "idkonto" ] := temp77->konto2
         update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
      ENDIF

      IF ( TEMP77->idpartner != TEMP77->part2 )
         SELECT SUBAN
         GO TEMP77->NSLOG
         _rec := dbf_get_rec()
         _rec[ "idpartner" ] := temp77->part2
         update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
      ENDIF

      // azuriraj analitiku
      IF TEMP77->idkonto != TEMP77->konto2

         SELECT ANAL
         GO TOP
         SEEK TEMP77->( idfirma + idvn + brnal )

         lIndik1 := .F.
         lIndik2 := .F.

         DO WHILE !Eof() .AND. idfirma + idvn + brnal == TEMP77->( idfirma + idvn + brnal )

            IF idkonto == TEMP77->idkonto .AND. !lIndik1

               lIndik1 := .T.

               _rec := dbf_get_rec()

               IF TEMP77->d_p == "1"
                  _rec[ "dugbhd" ] := _rec[ "dugbhd" ] - TEMP77->iznosbhd
                  _rec[ "dugdem" ] := _rec[ "dugdem" ] - TEMP77->iznosdem
               ELSE
                  _rec[ "potbhd" ] := _rec[ "potbhd" ] - TEMP77->iznosbhd
                  _rec[ "potdem" ] := _rec[ "potdem" ] - TEMP77->iznosdem
               ENDIF

               update_rec_server_and_dbf( "fin_anal", _rec, 1, "CONT" )

            ELSEIF idkonto == TEMP77->konto2 .AND. !lIndik2

               lIndik2 := .T.

               _rec := dbf_get_rec()

               IF TEMP77->d_p == "1"
                  _rec[ "dugbhd" ] := _rec[ "dugbhd" ] + TEMP77->iznosbhd
                  _rec[ "dugdem" ] := _rec[ "dugdem" ] + TEMP77->iznosdem
               ELSE
                  _rec[ "potbhd" ] := _rec[ "potbhd" ] + TEMP77->iznosbhd
                  _rec[ "potdem" ] := _rec[ "potdem" ] + TEMP77->iznosdem
               ENDIF

               update_rec_server_and_dbf( "fin_anal", _rec, 1, "CONT" )

            ENDIF

            SKIP 1

         ENDDO

         SKIP -1

         IF !lIndik2

            _rec := dbf_get_rec()

            _rec[ "idkonto" ] := TEMP77->konto2
            _rec[ "rbr" ] := NovaSifra( _rec[ "rbr" ] )

            IF gDatNal == "N"
               _rec[ "datnal" ] := TEMP77->datdok
            ENDIF

            _rec[ "dugbhd" ] := IF( TEMP77->d_p == "1", TEMP77->iznosbhd, 0 )
            _rec[ "potbhd" ] := IF( TEMP77->d_p == "2", TEMP77->iznosbhd, 0 )
            _rec[ "dugdem" ] := IF( TEMP77->d_p == "1", TEMP77->iznosdem, 0 )
            _rec[ "potdem" ] := IF( TEMP77->d_p == "2", TEMP77->iznosdem, 0 )

            APPEND BLANK

            update_rec_server_and_dbf( "fin_anal", _rec, 1, "CONT" )

         ENDIF

      ENDIF

      // azuriraj sintetiku
      IF Left( TEMP77->idkonto, 3 ) != Left( TEMP77->konto2, 3 )

         SELECT SINT
         GO TOP
         SEEK TEMP77->( idfirma + idvn + brnal )

         lIndik1 := .F.
         lIndik2 := .F.

         DO WHILE !Eof() .AND. idfirma + idvn + brnal == TEMP77->( idfirma + idvn + brnal )

            IF idkonto == Left( TEMP77->idkonto, 3 ) .AND. !lIndik1

               lIndik1 := .T.

               _rec := dbf_get_rec()

               IF TEMP77->d_p == "1"
                  _rec[ "dugbhd" ] := _rec[ "dugbhd" ] + TEMP77->iznosbhd
                  _rec[ "dugdem" ] := _rec[ "dugdem" ] + TEMP77->iznosdem
               ELSE
                  _rec[ "potbhd" ] := _rec[ "potbhd" ] + TEMP77->iznosbhd
                  _rec[ "potdem" ] := _rec[ "potdem" ] + TEMP77->iznosdem
               ENDIF

               update_rec_server_and_dbf( "fin_sint", _rec, 1, "CONT" )

            ELSEIF idkonto == Left( TEMP77->konto2, 3 ) .AND. !lIndik2

               lIndik2 := .T.

               _rec := dbf_get_rec()

               IF TEMP77->d_p == "1"
                  _rec[ "dugbhd" ] := _rec[ "dugbhd" ] + TEMP77->iznosbhd
                  _rec[ "dugdem" ] := _rec[ "dugdem" ] + TEMP77->iznosdem
               ELSE
                  _rec[ "potbhd" ] := _rec[ "potbhd" ] + TEMP77->iznosbhd
                  _rec[ "potdem" ] := _rec[ "potdem" ] + TEMP77->iznosdem
               ENDIF

               update_rec_server_and_dbf( "fin_sint", _rec, 1, "CONT" )

            ENDIF

            SKIP 1

         ENDDO

         SKIP -1

         IF !lIndik2

            _rec := dbf_get_rec()

            _rec[ "idkonto" ] := Left( TEMP77->konto2, 3 )
            _rec[ "rbr" ] := NovaSifra( _rec[ "rbr" ] )

            IF gDatNal == "N"
               _rec[ "datnal" ] := TEMP77->datdok
            ENDIF

            _rec[ "dugbhd" ] := IF( TEMP77->d_p == "1", TEMP77->iznosbhd, 0 )
            _rec[ "potbhd" ] := IF( TEMP77->d_p == "2", TEMP77->iznosbhd, 0 )
            _rec[ "dugdem" ] := IF( TEMP77->d_p == "1", TEMP77->iznosdem, 0 )
            _rec[ "potdem" ] := IF( TEMP77->d_p == "2", TEMP77->iznosdem, 0 )

            APPEND BLANK

            update_rec_server_and_dbf( "fin_sint", _rec, 1, "CONT" )

         ENDIF

      ENDIF

      SELECT TEMP77
      SKIP 1

      Postotak( 2, ++nZapisa,,,, .F. )

   ENDDO

   Postotak( -1,,,,, .F. )

   SELECT TEMP77
   my_dbf_zap()

   SELECT ANAL
   nZapisa := 0

   Postotak( 1, RECCOUNT2(), "Azuriranje promjena na analitici",,, .F. )

   GO TOP

   DO WHILE !Eof()
      IF dugbhd == 0 .AND. potbhd == 0 .AND. dugdem == 0 .AND. potdem == 0
         SKIP 1
         nSlog := RecNo()
         SKIP -1
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "fin_anal", _rec, 1, "CONT" )
         GO nSlog
      ELSE
         SKIP 1
      ENDIF
      Postotak( 2, ++nZapisa,,,, .F. )
   ENDDO

   Postotak( -1,,,,, .F. )

   SELECT SINT
   nZapisa := 0

   Postotak( 1, RECCOUNT2(), "Azuriranje promjena na sintetici",,, .F. )

   GO TOP

   DO WHILE !Eof()

      IF dugbhd == 0 .AND. potbhd == 0 .AND. dugdem == 0 .AND. potdem == 0
         SKIP 1
         nSlog := RecNo()
         SKIP -1
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "fin_sint", _rec, 1, "CONT" )
         GO nSlog
      ELSE
         SKIP 1
      ENDIF
      Postotak( 2, ++nZapisa,,,, .F. )
   ENDDO

   Postotak( -1,,,,, .T. )

   hParams[ "unlock" ] := { "fin_suban", "fin_anal", "fin_sint" }
   run_sql_query( "COMMIT", hParams )


   SELECT TEMP77
   USE

   RETURN .T.



/*
 *  brief Vraca zadnji redni broj
 */

FUNCTION ZadnjiRBR()

   LOCAL nZRBR := 0
   LOCAL nObl := Select()

   O_FIN_PRIPR
   GO BOTTOM
   nZRBR := Val( rbr )
   SELECT ( nObl )

   RETURN ( nZRBR )
