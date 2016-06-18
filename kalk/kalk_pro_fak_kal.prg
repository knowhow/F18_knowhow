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



// ---------------------------------------------
// meni za razmjenu dokumenata proizvodnje
// ---------------------------------------------
FUNCTION FaKaProizvodnja()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. fakt->kalk 96 po normativima za period            " )
   AAdd( _opcexe, {||          PrenosNo()  } )
   AAdd( _opc, "2. fakt->kalk 96 po normativima po fakturama" )
   AAdd( _opcexe, {||          PrenosNoFakt()  } )
   AAdd( _opc, "3. fakt->kalk 10 got.proizv po normativima za period" )
   AAdd( _opcexe, {||          PrenosNo2() } )

   f18_menu( "fkno", .F., _izbor, _opc, _opcexe )

   RETURN


// -------------------------------------------------------
// prenos po normativima za period
// -------------------------------------------------------
FUNCTION PrenosNo( dD_from, dD_to, cIdKonto2, cIdTipDok, dDatKalk, cRobaUsl, ;
      cRobaIncl, cSezona, cSirovina )

   LOCAL lTest := .F.
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )
   LOCAL cIdFirma := gFirma
   LOCAL cIdKonto := PadR( "", 7 )
   LOCAL cIdZaduz2 := Space( 6 )

   IF PCount() == 0
      cIdTipDok := "10;11;12;      "
      cRobaUsl := Space( 100 )
      cRobaIncl := "I"
      dDatKalk := Date()
      cIdKonto2 := PadR( "1310", 7 )
      cSezona := ""
      cSirovina := ""
   ELSE
      lTest := .T.
   ENDIF


   o_tbl_roba( lTest, cSezona )
   o_tables()

   IF !Empty( cSirovina )
      O_R_EXP
   ENDIF

   IF gBrojac == "D" .AND. lTest == .F.
      SELECT kalk
      SET ORDER TO TAG "1"
      SEEK cidfirma + "96X"
      SKIP -1
      IF idvd <> "96"
         cbrkalk := Space( 8 )
      ELSE
         cbrkalk := brdok
      ENDIF
   ENDIF

   IF lTest == .T.
      cBrKalk := "99999"
   ENDIF

   Box(, 15, 60 )

   IF gBrojac == "D" .AND. lTest == .F.
      cbrkalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
   ENDIF

   DO WHILE .T.

      nRBr := 0

      IF lTest == .F.

         @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 96 -" GET cBrKalk PICT "@!"
         @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
         @ m_x + 3, m_y + 2   SAY "Konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
         IF gNW <> "X"
            @ m_x + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. P_Firma( @cIdZaduz2 )
         ENDIF
         @ m_x + 4, m_y + 2   SAY "Konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )

         cFaktFirma := cIdFirma
         dDatFOd := CToD( "" )
         dDatFDo := Date()
         @ m_x + 6, m_y + 2 SAY "RJ u FAKT: " GET  cFaktFirma
         @ m_x + 7, m_Y + 2 SAY "Dokumenti tipa iz fakt:" GET cidtipdok
         @ m_x + 8, m_y + 2 SAY "period od" GET dDAtFOd
         @ m_x + 8, Col() + 2 SAY "do" GET dDAtFDo

         @ m_x + 10, m_y + 2 SAY "Uslov za robu:" GET cRobaUsl PICT "@S40"
         @ m_x + 11, m_y + 2 SAY "Navedeni uslov [U]kljuciti / [I]skljuciti" GET cRobaIncl VALID cRobaIncl $ "UI" PICT "@!"

         READ

         IF LastKey() == K_ESC
            EXIT
         ENDIF

      ENDIF

      IF lTest == .T.
         dDatFOd := dD_from
         dDatFDo := dD_to
         cFaktFirma := "10"
      ENDIF

      SELECT fakt
      SEEK cFaktFirma

      IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + "'==IdFirma", "IDROBA", F_ROBA, "idtipdok $ '" + cIdTipdok + "' .and. dDatFOd<=datdok .and. dDatFDo>=datdok", lTest )

         MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
         LOOP

      ENDIF

      aNotIncl := {}

      DO WHILE !Eof() .AND. cFaktFirma == IdFirma

         IF idtipdok $ cIdTipdok .AND. dDatFOd <= datdok .AND. dDatFDo >= datdok
            // pripada odabranom intervalu

            cFBrDok := fakt->brdok

            SELECT kalk_doks
            SET ORDER TO TAG "V_BRF"
            GO TOP
            SEEK PadR( cFBrDok, 10 ) + "96"

            IF Found() .AND. AllTrim( kalk_doks->brfaktp ) == AllTrim( cFBrDok ) .AND. kalk_doks->idvd == "96"

               cTmp := fakt->idfirma + "-" + ( cFBrDok )
               dTmpDate := fakt->datdok

               SELECT partn
               HSEEK fakt->idpartner

               cTmpPartn := AllTrim( partn->naz )

               SELECT kalk_doks

               nScan := AScan( aNotIncl, {| xVar| xVar[ 1 ] == cTmp } )

               IF nScan == 0
                  AAdd( aNotIncl, { cTmp, dTmpDate, cTmpPartn, kalk_doks->idvd + "-" + kalk_doks->brdok } )
               ENDIF

               SELECT fakt
               SKIP
               LOOP

            ENDIF

            SELECT ROBA
            HSEEK fakt->idroba

            // provjeri prije svega uslov za robu...
            IF !Empty( cRobaUsl )

               cTmp := Parsiraj( cRobaUsl, "idroba" )

               if &cTmp
                  IF cRobaIncl == "I"
                     SELECT fakt
                     SKIP
                     LOOP
                  ENDIF
               ELSE
                  IF cRobaIncl == "U"
                     SELECT fakt
                     SKIP
                     LOOP
                  ENDIF
               ENDIF

            ENDIF

            IF roba->tip = "P"

               // radi se o proizvodu

               SELECT sast
               HSEEK  fakt->idroba

               DO WHILE !Eof() .AND. id == fakt->idroba // setaj kroz sast

                  IF !Empty( cSirovina )
                     IF cSirovina <> sast->id2
                        SKIP
                        LOOP
                     ENDIF
                  ENDIF

                  SELECT roba
                  HSEEK sast->id2

                  SELECT kalk_pripr
                  LOCATE FOR idroba == sast->id2

                  IF Found()

                     RREPLACE kolicina WITH kolicina + fakt->kolicina * sast->kolicina

                  ELSE

                     SELECT kalk_pripr
                     APPEND BLANK
                     REPLACE idfirma WITH cIdFirma, ;
                        rbr     WITH Str( ++nRbr, 3 ), ;
                        idvd WITH "96", ;   // izlazna faktura
                     brdok WITH cBrKalk, ;
                        datdok WITH dDatKalk, ;
                        idtarifa WITH ROBA->idtarifa, ;
                        brfaktp WITH "", ;
                        datfaktp WITH dDatKalk, ;
                        idkonto   WITH cidkonto, ;
                        idkonto2  WITH cidkonto2, ;
                        idzaduz2  WITH cidzaduz2, ;
                        kolicina WITH fakt->kolicina * sast->kolicina, ;
                        idroba WITH sast->id2, ;
                        nc  WITH ROBA->nc, ;
                        vpc WITH fakt->cijena, ;
                        rabatv WITH fakt->rabat, ;
                        mpc WITH fakt->porez


                  ENDIF

                  IF !Empty( cSirovina )

                     SELECT r_export
                     APPEND BLANK

                     REPLACE field->idsast WITH cSirovina
                     REPLACE field->idroba WITH fakt->idroba
                     REPLACE field->r_naz WITH ""
                     REPLACE field->idpartner WITH fakt->idpartner
                     REPLACE field->rbr WITH fakt->rbr
                     REPLACE field->brdok WITH fakt->idtipdok + ;
                        "-" + fakt->brdok
                     REPLACE field->kolicina WITH fakt->kolicina
                     REPLACE field->kol_sast with ;
                        fakt->kolicina * sast->kolicina


                  ENDIF

                  SELECT sast
                  SKIP

               ENDDO

            ENDIF // roba->tip == "P"
         ENDIF  // $ cidtipdok
         SELECT fakt
         SKIP
      ENDDO

      IF lTest == .F.

         IF Len( aNotIncl ) > 0
            rpt_not_incl( aNotIncl )
         ENDIF

         @ m_x + 10, m_y + 2 SAY "Dokumenti su preneseni !!"

         IF gBrojac == "D"
            cbrkalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
         ENDIF

         Inkey( 4 )
         @ m_x + 8, m_y + 2 SAY Space( 30 )

      ELSE
         EXIT
      ENDIF


   ENDDO
   Boxc()
   IF lTest == .F.
      closeret
   ENDIF

   RETURN

// ---------------------------------------------
// prikazi sta nije ukljuceno u prenos
// ---------------------------------------------
STATIC FUNCTION rpt_not_incl( aArr )

   LOCAL i
   LOCAL nCnt := 0

   START PRINT CRET

   ? "----------------------------------------------"
   ? "U prenosu nisu ukljuceni sljedeci dokumenti:"
   ? "----------------------------------------------"

   ?
   ? "---- ----------- ----------- -------- --------------------------------------"
   ? "rbr  br.dok      br.dok       datum   partner"
   ? "     u fakt      u kalk"
   ? "---- ----------- ----------- -------- --------------------------------------"

   FOR i := 1 TO Len( aArr )

      // rbr             brdok f.   brdok k.  datum       partner
      ? Str( ++nCnt, 3 ) + ".", aArr[ i, 1 ], aArr[ i, 4 ], aArr[ i, 2 ], aArr[ i, 3 ]

   NEXT

   ?
   ? "Ovi dokumenti su preneseni opcijom prenosa po"
   ? "broju fakture."

   FF
   ENDPRINT

   RETURN


// -------------------------------------
// otvori tabele za prenos
// -------------------------------------
STATIC FUNCTION o_tables()

   o_kalk_pripr()
   O_KALK
   o_kalk_doks()
   O_KONTO
   O_PARTN
   O_TARIFA
   O_FAKT

   RETURN


// -------------------------------------------
// otvaranje roba - sast
// -------------------------------------------
STATIC FUNCTION o_tbl_roba( lTest, cSezSif )

   LOCAL cSifPath

   IF lTest == .T.
      my_close_all_dbf()

      cSifPath := PadR( SIFPATH, 14 )
      // "c:\sigma\sif1\"

      IF !Empty( cSezSif ) .AND. cSezSif <> "RADP"
         cSifPath += cSezSif + SLASH
      ENDIF

      SELECT ( F_ROBA )
      USE
      SELECT ( F_ROBA )
      USE ( cSifPath + "ROBA" ) ALIAS "ROBA"
      SET ORDER TO TAG "ID"

      SELECT ( F_SAST )
      USE
      SELECT ( F_SAST )
      USE ( cSifPath + "SAST" ) ALIAS "SAST"
      SET ORDER TO TAG "ID"

   ELSE
      O_ROBA
      O_SAST
   ENDIF

   RETURN



// -------------------------------------------------------
// prenos po normativima po broju faktura
// -------------------------------------------------------
FUNCTION PrenosNoFakt()

   LOCAL cIdFirma := gFirma
   LOCAL cIdTipDok := "10"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )
   LOCAL cFaBrDok := Space( 8 )

   // otvori tabele prenosa
   o_tables()

   dDatKalk := Date()
   cIdKonto := PadR( "", 7 )
   cIdKonto2 := PadR( "1310", 7 )
   cIdZaduz2 := Space( 6 )

   cBrkalk := Space( 8 )

   IF gBrojac == "D"
      SELECT kalk
      SET ORDER TO TAG "1"
      SEEK cIdFirma + "96X"
      SKIP -1
      IF idvd <> "96"
         cBrKalk := Space( 8 )
      ELSE
         cBrKalk := brdok
      ENDIF
   ENDIF

   Box(, 15, 60 )

   IF gBrojac == "D"
      cBrKalk := UBrojDok( Val( Left( cBrKalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
   ENDIF

   DO WHILE .T.

      nRBr := 0

      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 96 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2   SAY "Konto razduzuje:" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )

      IF gNW <> "X"
         @ m_x + 3, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. P_Firma( @cIdZaduz2 )
      ENDIF

      @ m_x + 4, m_y + 2   SAY "Konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )

      cFaktFirma := cIdFirma

      @ m_x + 6, m_y + 2 SAY "RJ u FAKT: " GET  cFaktFirma
      @ m_x + 7, m_Y + 2 SAY "Dokument tipa u fakt:" GET cIdTipDok

      @ m_x + 8, m_Y + 2 SAY "Broj dokumenta u fakt:" GET cFaBrDok


      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT fakt
      SEEK cFaktFirma

      IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + "'==IdFirma", "IDROBA", F_ROBA, "idtipdok = '" + cIdTipdok + "' .and. brdok = '" + cFaBrDok + "'" )

         MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
         LOOP
      ENDIF

      DO WHILE !Eof() .AND. cFaktFirma == IdFirma

         IF idtipdok = cIdTipdok .AND. cFaBrDok = brdok

            SELECT ROBA
            HSEEK fakt->idroba
            IF roba->tip = "P"
               // radi se o proizvodu
               SELECT sast
               HSEEK  fakt->idroba
               DO WHILE !Eof() .AND. id == fakt->idroba
                  // setaj kroz sast
                  SELECT roba
                  HSEEK sast->id2
                  SELECT kalk_pripr
                  LOCATE FOR idroba == sast->id2
                  IF Found()
                     RREPLACE kolicina WITH kolicina + fakt->kolicina * sast->kolicina
                  ELSE
                     SELECT kalk_pripr
                     APPEND BLANK
                     REPLACE idfirma WITH cIdFirma, ;
                        rbr     WITH Str( ++nRbr, 3 ), ;
                        idvd WITH "96", ;
                        brdok WITH cBrKalk, ;
                        datdok WITH dDatKalk, ;
                        idtarifa WITH ROBA->idtarifa, ;
                        brfaktp WITH fakt->brdok, ;
                        idpartner WITH fakt->idpartner, ;
                        datfaktp WITH dDatKalk, ;
                        idkonto   WITH cidkonto, ;
                        idkonto2  WITH cidkonto2, ;
                        idzaduz2  WITH cidzaduz2, ;
                        kolicina WITH fakt->kolicina * sast->kolicina, ;
                        idroba WITH sast->id2, ;
                        nc  WITH ROBA->nc, ;
                        vpc WITH fakt->cijena, ;
                        rabatv WITH fakt->rabat, ;
                        mpc WITH fakt->porez
                  ENDIF

                  SELECT sast
                  SKIP
               ENDDO

            ENDIF
         ENDIF

         SELECT fakt
         SKIP
      ENDDO

      @ m_x + 10, m_y + 2 SAY "Dokumenti su preneseni !!"

      IF gBrojac == "D"
         cBrKalk := UBrojDok( Val( Left( cBrKalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
      ENDIF

      cFaBrDok := UBrojDok( Val( Left( cFaBrDok, 5 ) ) + 1, 5, Right( cFaBrDok, 3 ) )

      Inkey( 4 )

      @ m_x + 8, m_y + 2 SAY Space( 30 )

   ENDDO

   Boxc()
   closeret

   RETURN



// ----------------------------------------------------------------------
// Prenos FAKT -> KALK 10 po normativima
// ----------------------------------------------------------------------
FUNCTION PrenosNo2()

   LOCAL cIdFirma := gFirma
   LOCAL cIdTipDok := "10;11;12;      "
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )

   o_kalk_pripr()
   O_KALK
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA
   O_SAST
   O_FAKT

   dDatKalk := Date()
   cIdKonto := PadR( "5100", 7 )
   cIdZaduz2 := Space( 6 )

   IF gBrojac == "D"
      SELECT kalk
      SET ORDER TO TAG "1"
      SEEK cIdFirma + "10X"
      SKIP -1
      IF idvd <> "10"
         cBrKalk := Space( 8 )
      ELSE
         cBrKalk := brdok
      ENDIF
   ENDIF

   Box(, 15, 60 )

   IF gBrojac == "D"
      cBrKalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
   ENDIF

   DO WHILE .T.

      nRBr := 0
      nRbr2 := 900
      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 10 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 4, m_y + 2   SAY "Konto got. proizvoda zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )

      cFaktFirma := cIdFirma
      dDatFOd := CToD( "" )
      dDatFDo := Date()
      @ m_x + 6, m_y + 2 SAY "RJ u FAKT: " GET  cFaktFirma
      @ m_x + 7, m_Y + 2 SAY "Dokumenti tipa iz fakt:" GET cidtipdok
      @ m_x + 8, m_y + 2 SAY "period od" GET dDAtFOd
      @ m_x + 8, Col() + 2 SAY "do" GET dDAtFDo
      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT fakt
      SEEK cFaktFirma
      IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + "'==IdFirma", "IDROBA", F_ROBA, "idtipdok $ '" + cIdTipdok + "' .and. dDatFOd<=datdok .and. dDatFDo>=datdok" )
         MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
         LOOP
      ENDIF

      DO WHILE !Eof() .AND. cFaktFirma == IdFirma

         IF idtipdok $ cIdTipdok .AND. dDatFOd <= datdok .AND. dDatFDo >= datdok // pripada odabranom intervalu

            SELECT roba
            HSEEK fakt->idroba
            IF roba->tip = "P"
               // radi se o proizvodu

               SELECT roba
               HSEEK fakt->idroba

               SELECT kalk_pripr
               LOCATE FOR idroba == fakt->idroba
               IF Found()
                  RREPLACE kolicina WITH kolicina + fakt->kolicina
               ELSE
                  SELECT kalk_pripr
                  APPEND BLANK
                  REPLACE idfirma WITH cIdFirma, ;
                     rbr     WITH Str( ++nRbr, 3 ), ;
                     idvd WITH "10", ;   // izlazna faktura
                  brdok WITH cBrKalk, ;
                     datdok WITH dDatKalk, ;
                     idtarifa WITH ROBA->idtarifa, ;
                     brfaktp WITH "", ;
                     datfaktp WITH dDatKalk, ;
                     idkonto   WITH cidkonto, ;
                     idroba WITH fakt->idroba, ;
                     vpc WITH fakt->cijena, ;
                     rabatv WITH fakt->rabat, ;
                     kolicina WITH fakt->kolicina, ;
                     mpc WITH fakt->porez
               ENDIF

            ENDIF
         ENDIF

         SELECT fakt
         SKIP
      ENDDO

      SELECT kalk_pripr
      GO TOP

      DO WHILE !Eof()
         SELECT sast
         HSEEK  kalk_pripr->idroba
         DO WHILE !Eof() .AND. id == kalk_pripr->idroba
            // setaj kroz sast
            // utvr|ivanje nabavnih cijena po sastavnici !!!!!
            SELECT roba
            HSEEK sast->id2

            SELECT kalk_pripr
            // roba->nc - nabavna cijena sirovine
            // sast->kolicina - kolicina po jedinici mjera
            RREPLACE fcj WITH fcj + ( roba->nc * sast->kolicina )

            SELECT sast
            SKIP
         ENDDO

         SELECT roba
         // nafiluj nabavne cijene proizvoda u sifrarnik robe!!!
         HSEEK kalk_pripr->idroba

         IF Found()
            _rec := dbf_get_rec()
            _rec[ "nc" ] := kalk_pripr->fcj
            update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )
         ENDIF

         SELECT kalk_pripr
         SKIP

      ENDDO

      @ m_x + 10, m_y + 2 SAY "Dokumenti su preneseni !!"

      IF gBrojac == "D"
         cbrkalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
      ENDIF

      Inkey( 4 )
      @ m_x + 8, m_y + 2 SAY Space( 30 )

   ENDDO

   Boxc()

   my_close_all_dbf()

   RETURN
