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


FUNCTION kalk_cre_cache()

   LOCAL aFld := {}
   LOCAL cTbl := "cache.dbf"

   AAdd( aFld, { "idkonto", "C", 7, 0 } )
   AAdd( aFld, { "idroba", "C", 10, 0 } )
   AAdd( aFld, { "ulaz", "N", 18, 8 } )
   AAdd( aFld, { "izlaz", "N", 18, 8 } )
   AAdd( aFld, { "stanje", "N", 18, 8 } )
   AAdd( aFld, { "nvu", "N", 18, 8 } )
   AAdd( aFld, { "nvi", "N", 18, 8 } )
   AAdd( aFld, { "nv", "N", 18, 8 } )
   AAdd( aFld, { "z_nv", "N", 18, 8 } )
   AAdd( aFld, { "odst", "N", 18, 8 } )

   IF !kalk_if_cache_exists()
      DBCreate2( cTbl, aFld )
      create_index( "1", "idkonto+idroba", cTbl )
   ENDIF

   RETURN .T.


// -------------------------------
// ima li cache tabele
// -------------------------------
FUNCTION kalk_if_cache_exists()

   LOCAL lRet := .F.

   IF File( f18_ime_dbf( "cache" ) )
      lRet := .T.
   ENDIF

   RETURN lRet




FUNCTION knab_cache( cC_Kto, cC_Roba, nC_Ulaz, nC_Izlaz, nC_Stanje, nC_NVU, nC_NVI, nC_NV )

   LOCAL nTArea := Select()
   LOCAL nZC_nv := 0

   IF !kalk_if_cache_exists() .OR. gCache == "N"
      RETURN 0
   ENDIF

   cC_Kto := PadR( cC_Kto, 7 )
   cC_Roba := PadR( cC_Roba, 10 )

   nC_ulaz := 0
   nC_izlaz := 0
   nC_stanje := 0
   nC_nvu := 0
   nC_nvi := 0
   nC_nv := 0

   O_CACHE
   SELECT cache
   SET ORDER TO TAG "1"
   GO TOP

   SEEK cC_Kto + cC_Roba

   IF Found() .AND. ( cC_kto == field->idkonto .AND. cC_roba == field->idroba )
      nC_Ulaz := field->ulaz
      nC_Izlaz := field->izlaz
      nC_Stanje := field->stanje
      nC_NVU := field->nvu
      nC_NVI := field->nvi
      nC_Nv := field->nv
      nZC_nv := field->z_nv
   ENDIF


   IF prag_odstupanja_nc_sumnjiv() > 0 .AND. nC_nv <> 0 .AND. nZC_nv <> 0

      nTmp := Round( nC_nv, 4 ) - Round( nZC_nv, 4 )
      nOdst := ( nTmp / Round( nZC_nv, 4 ) ) * 100

      IF Abs( nOdst ) > prag_odstupanja_nc_sumnjiv()

         Beep( 4 )
         CLEAR TYPEAHEAD // zaustavi asistenta

         MsgBeep( "Odstupanje u odnosu na zadnji ulaz je#" + AllTrim( Str( Abs( nOdst ) ) ) + " %" + "#" + ;
            "artikal: " + AllTrim( cC_roba ) + " " + PadR( roba->naz, 15 ) + " nc:" + AllTrim( Str( nC_nv, 12, 2 ) ) )

         // a_nc_ctrl( @aNC_ctrl, field->idroba, field->stanje, ;
         // field->nv, field->z_nv )

         IF Pitanje(, "Napraviti korekciju NC (D/N)?", "D" ) == "D"

            nTmp_n_stanje := ( nC_stanje - _kolicina )
            nTmp_n_nv := ( nTmp_n_stanje * nZC_nv )
            nTmp_s_nv := ( nC_stanje * nC_nv )

            nC_nv := ( ( nTmp_s_nv - nTmp_n_nv ) / _kolicina )

         ENDIF

         IF Pitanje(, "Upisati u CACHE novu NC (D/N)?", "D" ) == "D"

            RREPLACE field->nv WITH field->z_nv, field->odst WITH 0

         ENDIF

      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN 1


// ------------------------------------------------------------
// lista konta
// ------------------------------------------------------------
STATIC FUNCTION _g_kto( cMList, cPList, dDatGen, cAppendSif, nT_kol, nT_ncproc )

   LOCAL GetList := {}
   LOCAL nTArea := Select()

   cMList := PadR( "1310;13101;", 250 )
   cPList := PadR( "1320;", 250 )
   dDatGen := Date()
   cAppendSif := "D"
   nT_kol := 100.00
   nT_ncproc := 17.00

   cMList := fetch_metric( "kalk_import_txt_magacin_konta", my_user(), cMList )
   cPList := fetch_metric( "kalk_import_txt_prodavnica_konta", my_user(), cPList )
   cAppendSif := fetch_metric( "kalk_import_txt_dodaj_sifru", my_user(), cAppendSif )
   nT_ncproc := fetch_metric( "kalk_import_txt_def_procenat", my_user(), nT_ncproc )
   nT_kol := fetch_metric( "kalk_import_txt_def_kolicina", my_user(), nT_kol )
   dDatGen := fetch_metric( "kalk_import_txt_datum", my_user(), dDatgen )

   cMList := PadR( cMList, 250 )
   cPList := PadR( cPList, 250 )

   Box(, 6, 60 )

   @ m_x + 1, m_y + 2 SAY "Mag. konta:" GET cMList PICT "@S40"
   @ m_x + 2, m_y + 2 SAY "Pro. konta:" GET cPList PICT "@S40"
   @ m_x + 3, m_y + 2 SAY "Datum do:" GET dDatGen
   @ m_x + 4, m_y + 2 SAY "Dodaj nepost.stavke iz sifrarnika (D/N):" GET cAppendSif

   READ

   IF cAppendSif == "D"

      @ m_x + 5, m_y + 2 SAY " -         default stanje:" ;
         GET nT_kol VALID nT_kol > 0 PICT "999999.99"
      @ m_x + 6, m_y + 2 SAY " - default procenat za nc:" ;
         GET nT_ncproc PICT "9999999.99"

      READ
   ENDIF
   BoxC()

   IF LastKey() == K_ESC
      SELECT ( nTArea )
      RETURN 0
   ENDIF

   set_metric( "kalk_import_txt_magacin_konta", my_user(), cMList )
   set_metric( "kalk_import_txt_prodavnica_konta", my_user(), cPList )
   set_metric( "kalk_import_txt_dodaj_sifru", my_user(), cAppendSif )
   set_metric( "kalk_import_txt_def_procenat", my_user(), nT_ncproc )
   set_metric( "kalk_import_txt_def_kolicina", my_user(), nT_kol )
   set_metric( "kalk_import_txt_datum", my_user(), dDatgen )

   SELECT ( nTArea )

   RETURN 1



// --------------------------------------------------
// generisi cache tabelu
// --------------------------------------------------
FUNCTION gen_cache()

   LOCAL nIzlNV
   LOCAL nIzlKol
   LOCAL nUlNV
   LOCAL nUlKol
   LOCAL nKolNeto
   LOCAL cIdKonto
   LOCAL cIdFirma := gFirma
   LOCAL cIdRoba
   LOCAL cMKtoLst
   LOCAL cPKtoLst
   LOCAL dDatGen
   LOCAL cAppFSif
   LOCAL nT_kol
   LOCAL nT_ncproc
   LOCAL GetList := {}
   LOCAL i

   // posljednje pozitivno stanje
   LOCAL nKol_poz := 0
   LOCAL nUVr_poz, nIVr_poz
   LOCAL nUKol_poz, nIKol_poz
   LOCAL nZadnjaNC := 0
   LOCAL nOdstup := 0
   LOCAL _korek_dok := .F.

   IF _g_kto( @cMKtoLst, @cPKtoLst, @dDatGen, @cAppFSif, @nT_kol, @nT_ncproc ) == 0
      RETURN .F.
   ENDIF

   kalk_cre_cache()

   O_CACHE

   SELECT cache
   my_dbf_zap()
   my_flock()


   //o_kalk_doks()
   //o_kalk()

   Box(, 1, 70 )

   aKto := TokToNiz( cMKtoLst, ";" )

   FOR i := 1 TO Len( aKto )

      cIdKonto := PadR( aKto[ i ], 7 )

      IF Empty( cIdKonto )
         LOOP
      ENDIF

      @ m_x + 1, m_y + 2 SAY "mag. konto: " + cIdKonto

/*
      SELECT kalk
      // mkonto
      --SET ORDER TO TAG "3"
      GO TOP

      SEEK cIdFirma + cIdKonto
*/
      find_kalk_by_mkonto_idroba( cIdFirma, cIdKonto )
      GO TOP

      DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cIdKonto == field->mkonto


         cIdRoba := field->idroba

         nKolicina := 0
         nIzlNV := 0

         nUlNV := 0 // ukupna izlazna nabavna vrijednost
         nIzlKol := 0
         // ukupna izlazna kolicina
         nUlKol := 0
         // ulazna kolicina

         nKol_poz := 0
         nZadnjaNC := 0
         nOdstup := 0

         @ m_x + 1, m_y + 20 SAY cIdRoba

         DO WHILE !Eof() .AND. ( ( cIdFirma + cIdKonto + cIdRoba ) == ( idFirma + mkonto + idroba ) )


            IF field->datdok > dDatGen // provjeri datum
               SKIP
               LOOP
            ENDIF

            find_kalk_doks_by_broj_dokumenta( kalk->idfirma, kalk->idvd, kalk->brdok )
            SELECT kalk


            IF Left( kalk_doks->brfaktp, 6 ) == "#KOREK" // provjera postojanja dokumenta korekcije
               _korek_dok := .T.
            ELSE
               _korek_dok := .F.
            ENDIF

            IF field->mu_i == "1" .OR. field->mu_i == "5"

               IF idvd == "10"
                  nKolNeto := Abs( kolicina - gkolicina - gkolicin2 )
               ELSE
                  nKolNeto := Abs( kolicina )
               ENDIF

               IF ( field->mu_i == "1" .AND. field->kolicina > 0 ) ;
                     .OR. ( field->mu_i == "5" .AND. field->kolicina < 0 )

                  nKolicina += nKolNeto
                  nUlKol += nKolNeto
                  nUlNV += ( nKolNeto * field->nc )

                  IF idvd $ "10#16#96" .AND. !_korek_dok // zadnja nabavna cijena ulaza
                     nZadnjaNC := field->nc
                  ENDIF

               ELSE

                  nKolicina -= nKolNeto
                  nIzlKol += nKolNeto
                  nIzlNV += ( nKolNeto * field->nc )


                  IF idvd == "16" .AND. _korek_dok // zadnja nabavna cijena ulaza
                     nZadnjaNC := field->nc
                  ENDIF

               ENDIF


               IF Round( nKolicina, 8 ) > 0 // ako je stanje pozitivno zapamti ga
                  nKol_poz := nKolicina

                  nUKol_poz := nUlKol
                  nIKol_poz := nIzlKol

                  nUVr_poz := nUlNv
                  nIVr_poz := nIzlNv
               ENDIF

            ENDIF

            SKIP

         ENDDO


         IF Round( nKol_poz, 8 ) == 0 // utvrdi srednju nabavnu cijenu na osnovu posljednjeg pozitivnog stanja
            nSNc := 0
         ELSE
            nSNc := ( nUVr_poz - nIVr_poz ) / nKol_poz // srednja nabavna cijena
         ENDIF

         nKolicina := Round( nKolicina, 4 )

         IF Round( nKol_poz, 8 ) <> 0


            SELECT cache

            APPEND BLANK

            REPLACE idkonto WITH cIdKonto
            REPLACE idroba WITH cIdRoba
            REPLACE ulaz WITH nUKol_poz + nT_kol
            REPLACE izlaz WITH nIKol_poz
            REPLACE stanje WITH nKol_poz + nT_kol
            REPLACE nvu WITH nUVr_poz
            REPLACE nvi WITH nIVr_poz
            REPLACE nv WITH nSnc
            REPLACE z_nv WITH nZadnjaNC

            IF nSNC <> 0 .AND. nZadnjaNC <> 0
               nTmp := ( Round( nSNC, 4 ) - Round( nZadnjaNC, 4 ) )
               nOdst := ( nTmp / Round( nZadnjaNC, 4 ) ) * 100

               REPLACE odst WITH Round( nOdst, 2 )
            ELSE
               REPLACE odst WITH 0
            ENDIF



         ENDIF

         SELECT kalk

      ENDDO

   NEXT

   i := 1

   // a sada prodavnice

   aKto := TokToNiz( cPKtoLst, ";" )

   FOR i := 1 TO Len( aKto )

      cIdKonto := PadR( aKto[ i ], 7 )

      IF Empty( cIdKonto )
         LOOP
      ENDIF

      @ m_x + 1, m_y + 2 SAY "prod.konto: " + cIdKonto

/*
      SELECT kalk
      // pkonto
      SET ORDER TO TAG "4"
      GO TOP

      SEEK cIdFirma + cIdKonto
*/
      find_kalk_by_pkonto_idroba( cIdFirma, cIdKonto )

      DO WHILE !Eof() .AND. cIdFirma == field->idfirma  .AND. cIdKonto == field->pkonto

         cIdRoba := field->idroba

         nKolicina := 0
         nIzlNV := 0
         // ukupna izlazna nabavna vrijednost
         nUlNV := 0
         nIzlKol := 0
         // ukupna izlazna kolicina
         nUlKol := 0
         // ulazna kolicina

         @ m_x + 1, m_y + 20 SAY cIdRoba

         DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdRoba == idFirma + pkonto + idroba

            // provjeri datum
            IF field->datdok > dDatGen
               SKIP
               LOOP
            ENDIF


            find_kalk_doks_by_broj_dokumenta( kalk->idfirma, kalk->idvd, kalk->brdok )

            SELECT kalk

            // provjera postojanja dokumenta korekcije
            IF Left( kalk_doks->brfaktp, 6 ) == "#KOREK"
               _korek_dok := .T.
            ELSE
               _korek_dok := .F.
            ENDIF

            IF field->pu_i == "1" .OR. field->pu_i == "5"

               IF ( field->pu_i == "1" .AND. field->kolicina > 0 ) .OR. ;
                  ( field->pu_i == "5" .AND. field->kolicina < 0 )
                  nKolicina += Abs( field->kolicina )
                  nUlKol    += Abs( field->kolicina )
                  nUlNV     += ( Abs( field->kolicina ) * field->nc )
               ELSE
                  nKolicina -= Abs( field->kolicina )
                  nIzlKol   += Abs( field->kolicina )
                  nIzlNV    += ( Abs( field->kolicina ) * field->nc )
               ENDIF

            ELSEIF field->pu_i == "I"
               nKolicina -= field->gkolicin2
               nIzlKol += field->gkolicin2
               nIzlNV += field->nc * field->gkolicin2
            ENDIF
            SKIP

         ENDDO

         IF Round( nKolicina, 5 ) == 0
            nSNC := 0
         ELSE
            nSNC := ( nUlNV - nIzlNV ) / nKolicina
         ENDIF

         nKolicina := Round( nKolicina, 4 )

         IF nKolicina <> 0

            // upisi u cache
            SELECT cache


            APPEND BLANK

            REPLACE idkonto WITH cIdKonto
            REPLACE idroba WITH cIdRoba
            REPLACE ulaz WITH nUlKol + nT_kol
            REPLACE izlaz WITH nIzlkol
            REPLACE stanje WITH nKolicina + nT_kol
            REPLACE nvu WITH nUlNv
            REPLACE nvi WITH nIzlNv
            REPLACE nv WITH nSnc
            REPLACE z_nv WITH 0


         ENDIF

         SELECT kalk

      ENDDO

   NEXT


   BoxC()
   SELECT cache
   my_unlock()
   SELECT kalk

   IF cAppFSif == "D"
      // dodaj stavke iz sifrarnika robe koje ne postoje
      add_to_cache_stavke_iz_sifarnika( cMKtoLst, cPKtoLst, nT_kol, nT_ncproc )
   ENDIF

   RETURN .T.


// ---------------------------------------------------------------
// dodaj u cache tabelu stavke iz sifrarnika koje ne postoje
// u cache
// ---------------------------------------------------------------
STATIC FUNCTION add_to_cache_stavke_iz_sifarnika( cM_list, cP_list, nT_kol, nT_ncproc )

   LOCAL nTArea := Select()
   LOCAL aKto := {}
   LOCAL i

   PRIVATE GetList := {}

   IF nT_kol = NIL .OR. nT_kol <= 0
      MsgBeep( "Default kolicina setovana na 0. Kako je to moguce :)" )
      RETURN .F.
   ENDIF

   IF nT_ncproc = NIL .OR. nT_ncproc <= 0
      MsgBeep( "Default procenat nc setovan na <= 0. Kako je to moguce :)" )
      RETURN .F.
   ENDIF

   Box(, 3, 60 )

   IF !Empty( cM_list )
      // odradi magacine...
      aKto := TokToNiz( cM_list, ";" )
      i := 1

      FOR i := 1 TO Len( aKto )
         // magacin je aKto[i]
         @ m_x + 1, m_y + 2 SAY PadR( "radim magacin: " + aKto[ i ], 60 )
         _app_for_kto( aKto[ i ], nT_kol, nT_ncproc )
      NEXT
   ENDIF

   IF !Empty( cP_list )
      // odradi prodavnice...
      aKto := TokToNiz( cP_list, ";" )
      i := 1

      FOR i := 1 TO Len( aKto )
         // magacin je aKto[i]
         @ m_x + 1, m_y + 2 SAY PadR( "radim prodavnicu: " + aKto[ i ], 60 )
         _app_for_kto( aKto[ i ], nT_kol, nT_ncproc )
      NEXT
   ENDIF

   BoxC()

   SELECT ( nTArea )

   RETURN .T.


// ------------------------------------------------
// dodaj u cache tabelu robu za konto
// ------------------------------------------------
STATIC FUNCTION _app_for_kto( cKto, nKol, nNcProc, lSilent )

   LOCAL cRoba
   LOCAL cRobaNaz
   LOCAL nVPC

   IF Empty( cKto )
      RETURN .F.
   ENDIF

   cKto := PadR( cKto, 7 )

   IF nKol = nil
      nKol := 100
   ENDIF

   IF nNcProc = nil
      nNcProc := 17.00
   ENDIF

   IF lSilent == nil
      lSilent := .F.
   ENDIF

   O_ROBA
   GO TOP

   DO WHILE !Eof()


      IF Empty( field->sifradob ) .OR. field->vpc == 0 // ako nema sifre dobavljaca, preskoci
         SKIP
         LOOP
      ENDIF

      cRoba := field->id
      cRobaNaz := field->naz
      nVPC := field->vpc

      // provjeri ima li u cache tabeli
      SELECT cache
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cKto + cRoba

      IF !Found()

         // nisam nasao upisi u cache

         IF !lSilent
            @ m_x + 2, m_y + 2 SAY "roba: " + PadR( cRoba, 10 ) ;
               + "-" + PadR( cRobaNaz, 40 )
         ENDIF

         APPEND BLANK
         REPLACE idkonto WITH cKto
         REPLACE idroba WITH cRoba
         REPLACE ulaz WITH nKol
         REPLACE izlaz WITH 0
         REPLACE stanje WITH nKol
         REPLACE nv WITH nVPC / ( ( nNcProc / 100 ) + 1 )
         REPLACE nvu WITH nv * nKol
         REPLACE nvi WITH 0
         REPLACE z_nv WITH nv
         REPLACE odst WITH 0

      ENDIF

      SELECT roba
      SKIP
   ENDDO

   RETURN


// -------------------------------------------------------
// konvertuje numericko polje u karakterno za prikaz
// -------------------------------------------------------
STATIC FUNCTION s_num( nNum )

   LOCAL cNum := Str( nNum, 12, 2 )

   RETURN cNum


// ----------------------------------------
// browsanje tabele cache
// ----------------------------------------
FUNCTION brow_cache()

   PRIVATE ImeKol
   PRIVATE Kol

   O_CACHE
   SET ORDER TO TAG "1"

   ImeKol := { { PadR( "Konto", 15 ), {|| PadR( AllTrim( IdKonto ) + ;
      "-" + AllTrim( IDROBA ), 13 ) }, "IdKonto" }, ;
      { PadR( "Stanje", 10 ), {|| s_num( Stanje ) }, "Stanje" }, ;
      { PadR( "NC", 10 ), {|| s_num( NV ) }, "Nab.cijena" }, ;
      { PadR( "Z_NC", 10 ), {|| s_num( Z_NV ) }, "Zadnja NC" }, ;
      { PadR( "odst", 10 ), {|| s_num( ODST ) }, "Odstupanje" } }

   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, 20, 77 )
   @ m_x + 17, m_y + 2 SAY "<c+N> novi zapis   <F2>  ispravka  <c+T> brisi stavku"
   @ m_x + 18, m_y + 2 SAY "<F>   filter odstupanja"
   @ m_x + 19, m_y + 2 SAY " "
   @ m_x + 20, m_y + 2 SAY " "

   my_db_edit( "CACHE", 20, 77, {|| key_handler() }, "", "pregled cache tabele", , , , , 4 )

   BoxC()

   RETURN


// ---------------------------------------
// handler key event
// ---------------------------------------
STATIC FUNCTION key_handler()

   LOCAL nOdst := 0
   LOCAL cT_filter := dbFilter()

   DO CASE
   CASE ch == K_F2
      IF edit_item() == 1

         IF !Empty( cT_filter )
            SET FILTER to &cT_filter
            GO TOP
         ENDIF

         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE ch == K_CTRL_N

      // dodaj novu stavku u tabelu
      IF edit_item( .T. ) == 1

         IF !Empty( cT_filter )
            SET FILTER to &cT_filter
            GO TOP
         ENDIF

         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE ch == K_CTRL_T

      RETURN browse_brisi_stavku()

   CASE Upper( Chr( ch ) ) == "F"

      cSign := ">="

      // filter
      Box(, 1, 22 )
      @ m_x + 1, m_y + 2 SAY "Odstupanje" GET cSign ;
         PICT "@S2"
      @ m_x + 1, Col() + 1 GET nOdst ;
         PICT "9999.99"
      READ
      BoxC()

      IF nOdst <> 0

         PRIVATE cFilter := "odst " + AllTrim( cSign ) ;
            + _filter_quote( nOdst )
         SET FILTER to &cFilter
         GO TOP

         cT_filter := dbFilter()

         RETURN DE_REFRESH
      ENDIF

   ENDCASE

   RETURN DE_CONT


// -------------------------------------
// korekcija stavke
// -------------------------------------
STATIC FUNCTION edit_item( lNew )

   LOCAL GetList := {}
   LOCAL nTmp
   LOCAL nOdst
   LOCAL nL_nv
   LOCAL nL_znv

   IF lNew == nil
      lNew := .F.
   ENDIF

   Scatter()

   // uzmi ovo radi daljnjeg analiziranja - postojece stanje
   nL_nv := _nv
   nL_znv := _z_nv

   IF lNew

      // resetuj varijable
      _idroba := Space( Len( _idroba ) )
      _ulaz := 0
      _izlaz := 0
      _stanje := 0
      _nvu := 0
      _nvi := 0
      _nv := 0
      _z_nv := 0

      APPEND BLANK

   ENDIF

   Box(, 5, 60 )

   IF lNew

      @ m_x + 1, m_y + 2 SAY "Id konto:" GET _idkonto
      @ m_x + 1, Col() + 2 SAY "Id roba:" GET _idroba

      @ m_x + 2, m_y + 2 SAY "ulaz:" GET _ulaz
      @ m_x + 2, Col() + 1 SAY "izlaz:" GET _izlaz
      @ m_x + 2, Col() + 1 SAY "stanje:" GET _stanje

      @ m_x + 3, m_y + 2 SAY "NV ulaz:" GET _nvu
      @ m_x + 3, Col() + 1 SAY "NV izlaz:" GET _nvi

   ENDIF

   @ m_x + 4, m_y + 2 SAY "Srednja NC:" GET _nv
   @ m_x + 4, Col() + 2 SAY " Zadnja NC:" GET _z_nv

   IF lNew
      @ m_x + 5, m_y + 2 SAY "odstupanje:" GET _odst
   ENDIF

   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   my_rlock()
   Gather()
   my_unlock()

   // izadji ako je dodavanje novog zapisa...
   IF lNew
      RETURN 1
   ENDIF

   // kalkulisi odstupanje automatski ako su cijene promjenjene

   IF ( nL_nv <> field->nv ) .OR. ( nL_znv <> field->z_nv )

      nTmp := Round( field->nv, 4 ) - Round( field->z_nv, 4 )
      nOdst := ( nTmp / Round( field->z_nv, 4 ) ) * 100

      my_rlock()
      REPLACE field->odst WITH Round( nOdst, 2 )
      my_unlock()

   ENDIF

   RETURN 1
