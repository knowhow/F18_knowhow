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


FUNCTION prenos_fakt_kalk_magacin()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. fakt->kalk (10->14) račun veleprodaje               " )
   AAdd( _opcexe, {||  fakt_kalk_prenos_10_14() } )
   AAdd( _opc, "2. fakt->kalk (12->96) otpremnica" )
   AAdd( _opcexe, {||  fakt_kalk_prenos()  } )
   AAdd( _opc, "3. fakt->kalk (19->96) izlazi po ostalim osnovama" )
   AAdd( _opcexe, {||  fakt_kalk_prenos( "19" ) } )
   AAdd( _opc, "4. fakt->kalk (01->10) ulaz od dobavljača" )
   AAdd( _opcexe, {||  fakt_kalk_prenos( "01_10" ) } )
   AAdd( _opc, "5. fakt->kalk (0x->16) doprema u magacin" )
   AAdd( _opcexe, {||  fakt_kalk_prenos( "0x" ) } )
   AAdd( _opc, "6. fakt->kalk, prenos otpremnica za period" )
   AAdd( _opcexe, {||  kalk_fakt_prenos_period() } )

   f18_menu( "fkma", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN .T.



/* fakt_kalk_prenos_10_14()
 *     Prenos FAKT 10 -> KALK 14 (veleprodajni racun)
 */

FUNCTION fakt_kalk_prenos_10_14()

   LOCAL nRabat := 0
   LOCAL cIdFirma := self_organizacija_id()
   LOCAL cIdTipDok := "10"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )
   LOCAL cFaktFirma := self_organizacija_id()
   LOCAL dDatPl := CToD( "" )
   LOCAL _params := fakt_params()

   // PRIVATE lVrsteP := _params[ "fakt_vrste_placanja" ]

   o_koncij()
   o_kalk_pripr()
   // o_kalk()
   // o_kalk_doks()
   // o_kalk_doks2()
  // o_roba()
   o_konto()
   o_partner()
   o_tarifa()
   o_fakt()

   dDatKalk := fetch_metric( "kalk_fakt_prenos_10_14_datum", my_user(), Date() )
   cIdKonto := fetch_metric( "kalk_fakt_prenos_10_14_konto_1", my_user(), PadR( "1200", 7 ) )
   cIdKonto2 := fetch_metric( "kalk_fakt_prenos_10_14_konto_2", my_user(), PadR( "1310", 7 ) )
   cIdZaduz2 := Space( 6 )


   IF glBrojacPoKontima
      Box( "#FAKT->KALK", 3, 70 )
      @ m_x + 2, m_y + 2 SAY "Konto razduzuje" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      READ
      BoxC()
   ENDIF
   cBrKalk :=  kalk_get_next_broj_v5( cIdFirma, "14", cIdKonto2 )


   Box(, 15, 60 )

   DO WHILE .T.

      nRBr := 0
      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 14 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 4, m_y + 2   SAY "Konto razduzuje:" GET cIdKonto2 PICT "@!" WHEN !glBrojacPoKontima VALID P_Konto( @cIdKonto2 )

      // IF gNW <> "X"
      // @ m_x + 4, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. p_partner( @cIdZaduz2 )
      // ENDIF

      cFaktFirma := iif( cIdKonto2 == gKomKonto, gKomFakt, cIdFirma )
      @ m_x + 6, m_y + 2 SAY "Broj fakture: " GET cFaktFirma
      @ m_x + 6, Col() + 2 SAY "- " + cidtipdok
      @ m_x + 6, Col() + 2 SAY "-" GET cBrDok

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok

      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE

         // IF lVrsteP
         // cIdVrsteP := idvrstep
         // ENDIF

         aMemo := ParsMemo( fakt->txt )

         IF Len( aMemo ) >= 5
            @ m_x + 10, m_y + 2 SAY PadR( Trim( aMemo[ 3 ] ), 30 )
            @ m_x + 11, m_y + 2 SAY PadR( Trim( aMemo[ 4 ] ), 30 )
            @ m_x + 12, m_y + 2 SAY PadR( Trim( aMemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF

         IF Len( aMemo ) >= 9
            dDatPl := CToD( aMemo[ 9 ] )
         ENDIF

         cIdPartner := Space( 6 )


         IF !Empty( fakt->idpartner )
            cIdPartner := fakt->idpartner
         ENDIF

         PRIVATE cBeze := " "

         @ m_x + 14, m_y + 2 SAY8 "Šifra partnera:"  GET cIdpartner PICT "@!" VALID p_partner( @cIdPartner )
         @ m_x + 15, m_y + 2 SAY8 "<ENTER> - prenos" GET cBeze

         READ
         ESC_BCR

         SELECT kalk_pripr
         LOCATE FOR BrFaktP == cBrDok


         IF Found() // faktura je vec prenesena
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
            LOOP
         ENDIF

         GO BOTTOM
         IF kalk_pripr->brdok == cBrKalk
            nRbr := Val( Rbr )
         ENDIF

         //SELECT fakt
         //IF !provjerisif_izbaciti_ovu_funkciju( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
        //    MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u šifarniku!#Prenos nije izvršen!" )
          //  LOOP
         //ENDIF

         find_kalk_doks2_by_broj_dokumenta( cIdFirma, "14", cBrKalk )

         // SELECT kalk_doks2
         // HSEEK cIdfirma + "14" + cBrkalk

         IF !Found()
            APPEND BLANK
            hRec := dbf_get_rec()
            hRec[ "idvd" ] := "14"
            hRec[ "idfirma" ] := cIdFirma
            hRec[ "brdok" ] := cBrKalk
         ELSE
            hRec := dbf_get_rec()
         ENDIF

         hRec[ "datval" ] := dDatPl

         // IF lVrsteP
         // hRec[ "k2" ] := cIdVrsteP
         // ENDIF

         update_rec_server_and_dbf( "kalk_doks2", hRec, 1, "FULL" )


         SELECT fakt
         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok

            select_o_roba(  fakt->idroba )
            select_o_tarifa( roba->idtarifa )

            IF ( RobaZastCijena( roba->idTarifa ) .AND. !IsPdvObveznik( cIdPartner ) )
               // nije pdv obveznik
               // roba ima zasticenu cijenu
               nRabat := 0
            ELSE
               nRabat := fakt->rabat
            ENDIF

            SELECT fakt
            IF AllTrim( podbr ) == "."  .OR. roba->tip $ "UY"
               SKIP
               LOOP
            ENDIF

            SELECT kalk_pripr
            APPEND BLANK
            REPLACE idfirma WITH cIdFirma, ;
               rbr     WITH Str( ++nRbr, 3 ), ;
               idvd WITH "14", ;   // izlazna faktura
            brdok WITH cBrKalk, ;
               datdok WITH dDatKalk, ;
               idpartner WITH cIdPartner, ;
               idtarifa WITH ROBA->idtarifa, ;
               brfaktp WITH fakt->brdok, ;
               datfaktp WITH fakt->datdok, ;
               idkonto   WITH cidkonto, ;
               idkonto2  WITH cidkonto2, ;
               idzaduz2  WITH cidzaduz2, ;
               kolicina WITH fakt->kolicina, ;
               idroba WITH fakt->idroba, ;
               nc  WITH ROBA->nc, ;
               vpc WITH fakt->cijena, ;
               rabatv WITH nRabat, ;
               mpc WITH fakt->porez

            SELECT fakt
            SKIP
         ENDDO

         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !"

         set_metric( "kalk_fakt_prenos_10_14_datum", my_user(), dDatKalk )
         set_metric( "kalk_fakt_prenos_10_14_konto_1", my_user(), cIdKonto )
         set_metric( "kalk_fakt_prenos_10_14_konto_2", my_user(), cIdKonto2 )

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )

         @ m_x + 8, m_y + 2 SAY Space( 30 )

      ENDIF

   ENDDO

   BoxC()

   my_close_all_dbf()

   RETURN .T.



FUNCTION fakt_kalk_prenos( cIndik )

   LOCAL cIdFirma := self_organizacija_id()
   LOCAL cIdTipDok := "12"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )
   LOCAL cTipKalk := "96"
   LOCAL cFaktDob := Space( 10 )
   LOCAL dDatKalk, cIdZaduz2, cIdKonto, cIdKonto2
   LOCAL cSufix
   LOCAL hRec
   LOCAL cIdPartner := Space( 6 ), cBeze

   IF cIndik != NIL .AND. cIndik == "19"
      cIdTipDok := "19"
   ENDIF

   IF cIndik != NIL .AND. cIndik == "0x"
      cIdTipDok := "0x"
   ENDIF

   IF cIndik = "01_10"
      cTipKalk := "10"
      cIdtipdok := "01"
   ELSEIF cIndik = "0x"
      cTipKalk := "16"
   ENDIF

   _o_prenos_tbls()

   dDatKalk := Date()

   IF cIdTipDok == "01"
      cIdKonto := PadR( "1320", 7 )
      cIdKonto2 := PadR( "", 7 )
   ELSEIF cIdTipDok == "0x"
      cIdKonto := PadR( "1320", 7 )
      cIdKonto2 := PadR( "", 7 )
   ELSE
      cIdKonto := PadR( "", 7 )
      cIdKonto2 := PadR( "1320", 7 )
   ENDIF

   cIdKonto := fetch_metric( "kalk_fakt_prenos_otpr_konto_1", my_user(), cIdKonto )
   cIdKonto2 := fetch_metric( "kalk_fakt_prenos_otpr_konto_2", my_user(), cIdKonto2 )
   cIdZaduz2 := Space( 6 )

   IF glBrojacPoKontima

      Box( "#FAKT->KALK", 3, 70 )
      @ m_x + 2, m_y + 2 SAY "Konto zaduzuje" GET cIdKonto PICT "@!" VALID P_Konto( @cIdKonto )
      READ
      BoxC()

   ENDIF

   cBrKalk := kalk_get_next_broj_v5( cIdFirma, cTipKalk, cIdKonto )

   Box(, 15, 60 )

   DO WHILE .T.

      nRBr := 0

      @ m_x + 1, m_y + 2 SAY "Broj kalkulacije " + cTipKalk + " -" GET cBrKalk PICT "@!"

      @ m_x + 3, m_y + 2 SAY "Konto zaduzuje :" GET cIdKonto  PICT "@!" WHEN !glBrojacPoKontima VALID P_Konto( @cIdKonto )
      @ m_x + 4, m_y + 2 SAY "Konto razduzuje:" GET cIdKonto2 PICT "@!" VALID Empty( cidkonto2 ) .OR. P_Konto( @cIdKonto2 )
      // IF gNW <> "X"
      // @ m_x + 4, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. p_partner( @cIdZaduz2 )
      // ENDIF

      cFaktFirma := cIdFirma


      @ m_x + 6, m_y + 2 SAY Space( 60 )
      @ m_x + 6, m_y + 2 SAY "Broj dokumenta u FAKT: " GET cFaktFirma
      @ m_x + 6, Col() + 1 SAY "-" GET cIdTipDok VALID cIdTipDok $ "00#01#10#12#19#16"
      @ m_x + 6, Col() + 1 SAY "-" GET cBrDok

      READ

      IF cIDTipDok == "10" .AND. cTipKalk == "10"
         @ m_x + 7, m_y + 2 SAY8 "Faktura dobavljača: " GET cFaktDob
      ELSE
         cFaktDob := cBrDok
      ENDIF

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok

      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE


         aMemo := ParsMemo( fakt->txt )  // iscupaj podatke iz memo polja

         IF Len( aMemo ) >= 5
            @ m_x + 10, m_y + 2 SAY PadR( Trim( aMemo[ 3 ] ), 30 )
            @ m_x + 11, m_y + 2 SAY PadR( Trim( aMemo[ 4 ] ), 30 )
            @ m_x + 12, m_y + 2 SAY PadR( Trim( aMemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF

         cIdPartner := fakt->idpartner // uzmi i partnera za prebaciti
         cBeze := " "

         dDatKalk := fakt->datdok
         @ m_x + 13, m_y + 2 SAY "Datum kalk:" GET dDatKalk


         IF cTipKalk $ "10"

            @ m_x + 14, m_y + 2 SAY8 "Šifra partnera:"  GET cIdpartner PICT "@!" VALID p_partner( @cIdPartner )
            @ m_x + 15, m_y + 2 SAY8 "<ENTER> - prenos" GET cBeze

            READ

         ENDIF

         SELECT kalk_pripr
         LOCATE FOR brfaktp == cBrDok

         IF Found() // da li je faktura je vec prenesena ?
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
            LOOP
         ENDIF

         GO BOTTOM

         IF field->brdok == cBrKalk
            nRbr := Val( field->rbr )
         ENDIF

         select_o_koncij( cIdKonto )

         SELECT fakt

         IF !provjerisif_izbaciti_ovu_funkciju( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF

         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == field->IdFirma + field->IdTipDok + field->BrDok

            select_o_roba( fakt->idroba )
            select_o_tarifa( roba->idtarifa )

            SELECT fakt
            IF AllTrim( podbr ) == "."  .OR. roba->tip $ "UY"
               SKIP
               LOOP
            ENDIF

            SELECT kalk_pripr
            APPEND BLANK

            hRec := dbf_get_rec()
            hRec[ "idfirma" ] := cIdFirma
            hRec[ "rbr" ] := Str( ++nRbr, 3 )
            hRec[ "idvd" ] := cTipKalk
            hRec[ "brdok" ] := cBrKalk
            hRec[ "datdok" ] := dDatKalk
            hRec[ "idpartner" ] := cIdPartner
            hRec[ "idtarifa" ] := roba->idtarifa
            hRec[ "brfaktp" ] := cFaktDob
            hRec[ "datfaktp" ] := fakt->datdok
            hRec[ "idkonto" ] := cIdKonto
            hRec[ "idkonto2" ] := cIdKonto2
            hRec[ "idzaduz2" ] := cIdZaduz2
            hRec[ "kolicina" ] := fakt->kolicina
            hRec[ "idroba" ] := fakt->idroba
            hRec[ "nc" ] := fakt->cijena
            hRec[ "fcj" ] := fakt->cijena
            hRec[ "vpc" ] := fakt->cijena
            hRec[ "rabat" ] := fakt->rabat
            hRec[ "trabat" ] := "%"
            hRec[ "mpc" ] := fakt->porez

            IF cTipKalk $ "10#16"
               // kod ulaza puni sa cijenama iz sifanika
               // replace vpc with roba->vpc
               hRec[ "vpc" ] := KoncijVPC()
            ENDIF

            IF cTipKalk $ "96"  // veza radni nalog !
               _tmp := aMemo[ 20 ]
               IF !Empty( _tmp )
                  hRec[ "idzaduz2" ] := _tmp
               ENDIF
            ENDIF

            dbf_update_rec( hRec )

            SELECT fakt
            SKIP

         ENDDO

         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !"

         set_metric( "kalk_fakt_prenos_otpr_konto_1", my_user(), cIdKonto )
         set_metric( "kalk_fakt_prenos_otpr_konto_2", my_user(), cIdKonto2 )

         kalk_fix_brdok_add_1( @cBrKalk )

         Inkey( 4 )

         @ m_x + 8, m_y + 2 SAY Space( 30 )

      ENDIF

   ENDDO

   BoxC()

   my_close_all_dbf()

   RETURN .T.



/*
    magacin: fakt->kalk prenos otpremnica za period
*/

FUNCTION kalk_fakt_prenos_period()

   LOCAL _id_firma := self_organizacija_id()
   LOCAL _fakt_id_firma := self_organizacija_id()
   LOCAL _tip_dok_fakt := PadR( "12;", 150 )
   LOCAL _dat_fakt_od, _dat_fakt_do
   LOCAL _br_kalk_dok := Space( 8 )
   LOCAL _tip_kalk := "96"
   LOCAL _dat_kalk
   LOCAL _id_konto
   LOCAL _id_konto_2
   LOCAL _sufix, _r_br, _razduzuje
   LOCAL _fakt_dobavljac := Space( 10 )
   LOCAL _artikli := Space( 150 )
   LOCAL _usl_roba

   _o_prenos_tbls()

   _dat_kalk := Date()
   _id_konto := PadR( "", 7 )
   _id_konto_2 := PadR( "1010", 7 )
   _razduzuje := Space( 6 )
   _dat_fakt_od := Date()
   _dat_fakt_do := Date()
   _br_kalk_dok := kalk_get_next_kalk_doc_uvecaj( _id_firma, _tip_kalk )

   _id_konto := fetch_metric( "kalk_fakt_prenos_otpr_konto_1", my_user(), _id_konto )
   _id_konto_2 := fetch_metric( "kalk_fakt_prenos_otpr_konto_2", my_user(), _id_konto_2 )

   Box(, 15, 70 )

   DO WHILE .T.

      _r_br := 0

      @ m_x + 1, m_y + 2 SAY "Broj kalkulacije " + _tip_kalk + " -" GET _br_kalk_dok PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET _dat_kalk
      @ m_x + 3, m_y + 2 SAY "Konto zaduzuje :" GET _id_konto PICT "@!" VALID Empty( _id_konto ) .OR. P_Konto( @_id_konto )
      @ m_x + 4, m_y + 2 SAY "Konto razduzuje:" GET _id_konto_2 PICT "@!" VALID Empty( _id_konto_2 ) .OR. P_Konto( @_id_konto_2 )

      // IF gNW <> "X"
      // @ m_x + 4, Col() + 2 SAY "Razduzuje:" GET _razduzuje PICT "@!" VALID Empty( _razduzuje ) .OR. p_partner( @_razduzuje )
      // ENDIF

      _fakt_id_firma := _id_firma

      // postavi uslove za period
      @ m_x + 6, m_y + 2 SAY "FAKT: id firma:" GET _fakt_id_firma
      @ m_x + 7, m_y + 2 SAY "Vrste dokumenata:" GET _tip_dok_fakt PICT "@S30"
      @ m_x + 8, m_y + 2 SAY "Dokumenti u periodu od" GET _dat_fakt_od
      @ m_x + 8, Col() + 1 SAY "do" GET _dat_fakt_do

      // uslov za sifre artikla
      @ m_x + 10, m_y + 2 SAY "Uslov po artiklima:" GET _artikli PICT "@S30"

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT fakt
      SET ORDER TO TAG "1"
      SEEK _fakt_id_firma

      DO WHILE !Eof() .AND. field->idfirma == _fakt_id_firma

         // provjeri po vrsti dokumenta
         IF !( field->idtipdok $ _tip_dok_fakt )
            SKIP
            LOOP
         ENDIF

         // provjeri po datumskom uslovu
         IF field->datdok < _dat_fakt_od .OR. field->datdok > _dat_fakt_do
            SKIP
            LOOP
         ENDIF


         IF !Empty( _artikli )  // provjera po robama

            _usl_roba := Parsiraj( _artikli, "idroba" )

            IF !( &_usl_roba )
               SKIP
               LOOP
            ENDIF

         ENDIF

         select_o_koncij( _id_konto )

         SELECT fakt

         // provjeri sifru u sifarniku
         IF !provjerisif_izbaciti_ovu_funkciju( "!eof() .and. '" + fakt->idfirma + fakt->idtipdok + fakt->brdok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF

         select_o_roba( fakt->idroba )
         select_o_tarifa( roba->idtarifa )

         SELECT fakt

         IF AllTrim( podbr ) == "." .OR. roba->tip $ "UY" // preskoci ako su usluge ili podbroj stavke
            SKIP
            LOOP
         ENDIF

         // dobro, sada imam prave dokumente koje treba da prebacujem
         SELECT kalk_pripr
         GO BOTTOM

         LOCATE FOR idroba == fakt->idroba // provjeri da li već postoji artikal prenesen, pa ga saberi sa prethodnim

         IF Found()

            RREPLACE kolicina WITH kolicina + fakt->kolicina // saberi ga sa prethodnim u pripremi

         ELSE

            APPEND BLANK // nema artikla, dodaj novi

            REPLACE idfirma WITH _id_firma, ;
               rbr WITH Str( ++_r_br, 3 ), ;
               idvd WITH _tip_kalk, ;
               brdok WITH _br_kalk_dok, ;
               datdok WITH _dat_kalk, ;
               idpartner WITH "", ;
               idtarifa WITH ROBA->idtarifa, ;
               brfaktp WITH _fakt_dobavljac, ;
               datfaktp WITH fakt->datdok, ;
               idkonto   WITH _id_konto, ;
               idkonto2  WITH _id_konto_2, ;
               idzaduz2  WITH _razduzuje, ;
               kolicina WITH fakt->kolicina, ;
               idroba WITH fakt->idroba, ;
               nc  WITH ROBA->nc, ;
               vpc WITH fakt->cijena, ;
               rabatv WITH fakt->rabat, ;
               mpc WITH fakt->porez

            IF _tip_kalk $ "96" .AND. fakt->( FieldPos( "idrnal" ) ) <> 0
               REPLACE idzaduz2 WITH fakt->idRNal
            ENDIF

            IF _tip_kalk $ "10"
               REPLACE idzaduz2 WITH fakt->rabat
            ENDIF

         ENDIF

         SELECT fakt
         SKIP

      ENDDO

      @ m_x + 14, m_y + 2 SAY "Dokument je generisan !"

      set_metric( "kalk_fakt_prenos_otpr_konto_1", my_user(), _id_konto )
      set_metric( "kalk_fakt_prenos_otpr_konto_2", my_user(), _id_konto_2 )

      Inkey( 4 )

      @ m_x + 14, m_y + 2 SAY Space( 30 )

   ENDDO

   BoxC()

   my_close_all_dbf()

   RETURN .T.



STATIC FUNCTION _o_prenos_tbls()

   o_koncij()
   o_kalk_pripr()
  // o_roba()
   o_konto()
   o_partner()
   o_tarifa()
   o_fakt()

   RETURN .T.


FUNCTION IsNumeric( cString )

   LOCAL lResult

   IF At( cString, "0123456789" ) <> 0
      lResult := .T.
   ELSE
      lResult := .F.
   ENDIF

   RETURN lResult
