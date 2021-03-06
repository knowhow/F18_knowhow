/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


/*

// -----------------------------------------------------------------
// kontrola sastavnica
//
// izvjestaj ce dati sljedece:
// 1) uzmi tekuci promet konta 1010 i ubaci u R_EXPORT
// ulaz, izlaz, stanje, cijene...
// 2) zatim se zakaci na fakt i pos te napravi razduzenje za citavu
// godinu po principu razduzenja sastavnica i te stavke stavi u
// tabelu...
// 3) kod povlacenja izvjestaja imamo znaci t.promet, novo stanje
// napraviti cizu i usporedbu +/-
// -----------------------------------------------------------------
FUNCTION r_ct_sast()

   LOCAL cIdFirma
   LOCAL cIdKonto
   LOCAL dD_from
   LOCAL dD_to
   LOCAL cProdKto
   LOCAL cArtfilter
   LOCAL cSezona
   LOCAL cSirovina
   LOCAL cTDokList
   LOCAL nVar := 1

   PRIVATE nRslt := 0
   --PRIVATE lKalkAsistentUToku := .T.

  // o_roba()
  -- o_sifk()
--   o_sifv()

   // uslovi izvjestaja
   IF g_vars( @dD_from, @dD_to, @cIdFirma, @cIdKonto, @cProdKto, ;
         @cArtfilter, @cTDokList, @cSezona, @cSirovina ) == 0
      RETURN .F.
   ENDIF

   // kreiraj pomocnu tabelu

   IF !Empty( cSirovina )
      nVar := 2
   ENDIF

   cre_r_tbl( nVar )

   o_partner()
   o_kalk_pripr()
   -- o_kalk()
   o_kalk_doks()
--   o_roba()
   o_konto()

   IF nVar == 1

      // daj kalk tekuci promet
      _g_kalk_tp( cIdFirma, cIdKonto, dD_from, dD_to )

      MsgO( "uzimam iz kalk_pripreme stanje i dodajem ga u export" )

      // uzmi iz kalk_pripreme ako postoji nesto generisano
      _pr_2_exp( nVar )

      MsgC()

   ENDIF

   // razduzi FAKT promet po sastavnicama
   _g_fakt_pr( cIdKonto, dD_From, dD_to, cTDokList, cSezona, nVar, cSirovina )

   IF nVar == 1
      // razduzi POS promet po sastavnicama
      _g_pos_pr( cIdFirma, cIdKonto, dD_From, dD_to, cProdKto, ;
         cArtFilter, cSezona, nVar, cSirovina )
   ENDIF

   my_close_all_dbf()
--   o_roba()

   o_rxp( nVar )

   // stampaj izvjestaj
   IF nVar == 1
      pr_report()
   ELSE
      pr_rpt2()
   ENDIF

   RETURN

// -----------------------------------------------------
// kreiranje tabele r_exp
// -----------------------------------------------------
STATIC FUNCTION cre_r_tbl( nVar )

   LOCAL aDbf := {}

   IF nVar == 1

      AAdd( aDbf, { "IDROBA", "C", 10, 0 } )
      AAdd( aDbf, { "IDKONTO", "C", 7, 0 } )
      AAdd( aDbf, { "TP_UL", "N", 15, 5 } )
      AAdd( aDbf, { "TP_IZ", "N", 15, 5 } )
      AAdd( aDbf, { "TP_ST", "N", 15, 5 } )
      AAdd( aDbf, { "TP_NVU", "N", 15, 5 } )
      AAdd( aDbf, { "TP_NVI", "N", 15, 5 } )
      AAdd( aDbf, { "TP_NVS", "N", 15, 5 } )
      AAdd( aDbf, { "TP_SNC", "N", 15, 5 } )

      // novo stanje
      AAdd( aDbf, { "NP_UL", "N", 15, 5 } )
      AAdd( aDbf, { "NP_IZ", "N", 15, 5 } )
      AAdd( aDbf, { "NP_ST", "N", 15, 5 } )
      AAdd( aDbf, { "NP_NVU", "N", 15, 5 } )
      AAdd( aDbf, { "NP_NVI", "N", 15, 5 } )
      AAdd( aDbf, { "NP_NVS", "N", 15, 5 } )

   ELSE

      AAdd( aDbf, { "IDSAST", "C", 10, 0 } )
      AAdd( aDbf, { "IDROBA", "C", 10, 0 } )
      AAdd( aDbf, { "R_NAZ", "C", 200, 0 } )
      AAdd( aDbf, { "BRDOK", "C", 20, 0 } )
      AAdd( aDbf, { "RBR", "C", 4, 0 } )
      AAdd( aDbf, { "IDPARTNER", "C", 6, 0 } )
      AAdd( aDbf, { "P_NAZ", "C", 50, 0 } )
      AAdd( aDbf, { "KOLICINA", "N", 15, 5 } )
      AAdd( aDbf, { "KOL_SAST", "N", 15, 5 } )


   ENDIF

   create_dbf_r_export( aDbf )

   o_rxp( nVar )

   RETURN

// ---------------------------------------
// open r_export
// ---------------------------------------
STATIC FUNCTION o_rxp( nVar )

   o_r_export()

   IF nVar == 1
      INDEX ON idroba TAG "1"
      INDEX ON idkonto + idroba TAG "2"
   ELSE
      INDEX ON brdok + rbr TAG "1"
   ENDIF

   RETURN




// --------------------------------------------------------------
// uslovi reporta
// --------------------------------------------------------------
STATIC FUNCTION g_vars( dD_from, dD_to, cIdFirma, cIdKonto, cProdKto, ;
      cArtfilter, cTDokList, cSezona, cSirovina )

   LOCAL nX := 1
   LOCAL nRet := 1

   dD_from := CToD( "01.01.09" )
   dD_to := CToD( "31.12.09" )
   cIdFirma := self_organizacija_id()
   cIdKonto := PadR( "1010;", 150 )
   cTDokList := PadR( "10;11;12;", 20 )
   cArtfilter := PadR( "2;3;", 100 )
   cProdKto := PadR( "1320", 7 )
   cSezona := "RADP"
   cSirovina := Space( 10 )

   Box(, 10, 65 )

   @ box_x_koord() + nX, box_y_koord() + 2 SAY "Datum od" GET dD_from
   @ box_x_koord() + nX, Col() + 1 SAY "do" GET dD_to

   ++ nX

   @ box_x_koord() + nX, box_y_koord() + 2 SAY "Firma:" GET cIdFirma
   @ box_x_koord() + nX, Col() + 3 SAY "sast.iz sezone" GET cSezona

   ++ nX

   @ box_x_koord() + nX, box_y_koord() + 2 SAY "gledaj sirovinu:" GET cSirovina ;
      VALID Empty( cSirovina ) .OR. P_ROBA( @cSirovina )

   ++ nX

   @ box_x_koord() + nX, box_y_koord() + 2 SAY "Mag. konta:" GET cIdKonto PICT "@S40"

   ++ nX
   ++ nX

   @ box_x_koord() + nX, box_y_koord() + 2 SAY "(fakt) lista dokumenata:" GET cTDokList ;
      PICT "@S20"

   ++ nX
   ++ nX

   @ box_x_koord() + nX, box_y_koord() + 2 SAY "(pos) konto prodavnice:" GET cProdKto VALID p_konto( @cProdKto )

   ++ nX

   @ box_x_koord() + nX, box_y_koord() + 2 SAY "(pos) filter za artikle:" GET cArtfilter PICT "@S20"
   READ
   BoxC()

   IF LastKey() == K_ESC
      nRet := 0
   ENDIF

   RETURN nRet


// -------------------------------------------------------------------
// uzmi tekuce stanje artikala kalk-a sa lagera
// -------------------------------------------------------------------
STATIC FUNCTION _g_kalk_tp( cIdFirma, cKto_list, dD_from, dD_to )

   LOCAL cIdKonto
   LOCAL aKto
   LOCAL i

   PRIVATE GetList := {}

   Box(, 1, 70 )

   aKto := TokToNiz( cKto_list, ";" )

   FOR i := 1 TO Len( aKto )

      cIdKonto := PadR( aKto[ i ], 7 )

      IF Empty( cIdKonto )
         LOOP
      ENDIF

      @ box_x_koord() + 1, box_y_koord() + 2 SAY "obradjujem mag. konto: " + cIdKonto




      find_kalk_by_mkonto_idroba( cIdFirma, cIdkonto )
      DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cIdKonto == field->mkonto


         cIdRoba := field->idroba

         nKolicina := 0
         nIzlNV := 0
         // ukupna izlazna nabavna vrijednost
         nUlNV := 0
         nIzlKol := 0
         // ukupna izlazna kolicina
         nUlKol := 0
         // ulazna kolicina

         nKol_poz := 0

         @ box_x_koord() + 1, box_y_koord() + 20 SAY "roba ->" + cIdRoba

         DO WHILE !Eof() .AND. ( ( cIdFirma + cIdKonto + cIdRoba ) == ( idFirma + mkonto + idroba ) )

            // provjeri datum
            IF field->datdok > dD_to .OR. field->datdok < dD_from
               SKIP
               LOOP
            ENDIF

            IF roba->tip $ "TU"
               SKIP
               LOOP
            ENDIF

            IF mu_i == "1"
               IF !( idvd $ "12#22#94" )
                  nKolicina := field->kolicina - field->gkolicina - field->gkolicin2
                  nUlKol += nKolicina
                  // kalk_sumiraj_kolicinu(nKolicina, 0, @nTUlazP, @nTIzlazP)
                  nUlNv += Round( field->nc * ( field->kolicina - field->gkolicina - field->gkolicin2 ), gZaokr )
               ELSE
                  nKolicina := -field->kolicina
                  nIzlKol += nKolicina

                  // kalk_sumiraj_kolicinu(0, nKolicina, @nTUlazP, @nTIzlazP)

                  nIzlNV -= Round( field->nc * field->kolicina, gZaokr )
               ENDIF

            ELSEIF mu_i == "5"

               nKolicina := field->kolicina
               nIzlKol += nKolicina

               // kalk_sumiraj_kolicinu(0, nKolicina, @nTUlazP, @nTIzlazP)

               nIzlNV += Round( field->nc * field->kolicina, gZaokr )

            ELSEIF mu_i == "8"
               nKolicina := -field->kolicina
               nIzlKol += nKolicina
               // kalk_sumiraj_kolicinu(0, nKolicina , @nTUlazP, @nTIzlazP)

               nIzlNV += Round( field->nc * ( -kolicina ), gZaokr )
               nKolicina := -field->kolicina

               nUlKol += nKolicina
               // kalk_sumiraj_kolicinu(nKolicina, 0, @nTUlazP, @nTIzlazP)


               nUlKol += Round( -nc * ( field->kolicina - gkolicina - gkolicin2 ), gZaokr )
            ENDIF

            SELECT kalk
            SKIP

         ENDDO

         nKolicina := ( nUlKol - nIzlKol )

         IF Round( nKolicina, 8 ) == 0
            nSNc := 0
         ELSE
            // srednja nabavna cijena
            nSNc := ( nUlNV - nIzlNV ) / nKolicina
         ENDIF

         nKolicina := Round( nKolicina, 4 )

         IF Round( nKolicina, 8 ) <> 0

            // upisi u r_exp
            SELECT r_export
            APPEND BLANK

            REPLACE idkonto WITH cIdkonto
            REPLACE idroba WITH cIdRoba
            REPLACE tp_ul WITH nUlKol
            REPLACE tp_iz WITH nIzlKol
            REPLACE tp_st WITH ( nUlKol - nIzlKol )
            REPLACE tp_nvu WITH nUlNV
            REPLACE tp_nvi WITH nIzlNV
            REPLACE tp_nvs WITH ( nUlNV - nIzlNv )
            REPLACE tp_snc WITH nSnc

         ENDIF

         SELECT kalk

      ENDDO

   NEXT

   BoxC()

   RETURN


// -------------------------------------------------------------
// uzmi promet fakt-a za godinu dana... po sastavnicama
// -------------------------------------------------------------
STATIC FUNCTION _g_fakt_pr( cIdKonto, dD_From, dD_to, cTDokList, cSezona, ;
      nVar, cSirovina )

   LOCAL nTArea := Select()
   LOCAL cKto := StrTran( cIdKonto, ";", "" )
   LOCAL cRobaUsl := ""
   LOCAL cRobaIncl := "I"

   cKto := PadR( AllTrim( cKto ), 7 )

   MsgO( "generisem pomocnu datoteku razduzenja FAKT...." )

   // prenesi fakt->kalk
   kalk_fakt_kalk_prenos_normativi( dD_from, dD_to, cKto, cTDokList, dD_to, cRobaUsl, ;
      cRobaIncl, cSezona, cSirovina )

   MsgC()

   _pr_2_exp( nVar )

   RETURN


// ------------------------------------------------------------
// uzmi promet pos-a po sastavnicama za godinu
// ------------------------------------------------------------
STATIC FUNCTION _g_pos_pr( cIdFirma, cIdKonto, dD_From, dD_to, ;
      cProdKto, cArtFilter, cSezona, nVar, cSirovina )

   LOCAL nTArea := Select()
   LOCAL cIdTipDok := PadR( "42;", 20 )
   LOCAL cKto := StrTran( cIdKonto, ";", "" )

   cKto := PadR( AllTrim( cKto ), 7 )

   MsgO( "generisem pomocnu datoteku razduzenja TOPS...." )
   // pokreni opciju tops po normativima
   tops_nor_96( cIdFirma, "42;", "", cKto, "", ;
      dD_to, dD_from, dD_to, cArtfilter, cProdKto, cSezona, cSirovina )

   MsgC()

   _pr_2_exp( nVar )

   SELECT ( nTArea )

   RETURN



STATIC FUNCTION _pr_2_exp( nVar )

   IF nVar == 2

      SELECT kalk_pripr
      ZAP

      // sredi robu i partnere
      SELECT r_export
      GO TOP
      my_flock()
      DO WHILE !Eof()
         REPLACE field->r_naz WITH r_naz( field->idroba )
         REPLACE field->p_naz WITH p_naz( field->idpartner )
         SKIP
      ENDDO
      my_unlock()
      RETURN
   ENDIF

   o_rxp( nVar )
   SELECT r_export
   SET ORDER TO TAG "1"

   // dobit ces punu kalk_pripremu
   SELECT kalk_pripr
   GO TOP
   DO WHILE !Eof()

      cIdRoba := field->idroba

      SELECT r_export
      GO TOP
    --  SEEK cIdRoba

      my_flock()

      IF !Found()
         APPEND BLANK
         REPLACE field->idroba WITH cIdRoba
      ENDIF

      REPLACE field->np_iz with ( field->np_iz + kalk_pripr->kolicina )

      REPLACE field->np_st with ( field->tp_ul - ;
         field->np_iz )

      REPLACE field->np_nvi with ( field->np_nvi + ( kalk_pripr->nc * kalk_pripr->kolicina ) )

      REPLACE field->np_nvs with ( field->tp_nvu - ;
         field->np_nvi )

      my_unlock()

      SELECT kalk_pripr

      SKIP
   ENDDO

   MsgC()

   // pobrisi na kraju kalk_pripremu
   SELECT kalk_pripr
   my_dbf_zap()

   RETURN


// -----------------------------------------------
// stampanje izvjestaja
// -----------------------------------------------
STATIC FUNCTION pr_rpt2()

   LOCAL nRbr := 0
   LOCAL cLine
   LOCAL nCol := 2
   LOCAL nT_kol := 0
   LOCAL nT_k2 := 0

   cLine := g_line( 2 )

   START PRINT CRET
   ?

   r_zagl( cLine, 2 )

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      ? PadL( AllTrim( Str( ++nRbr ) ), 4 ) + ")"

      @ PRow(), PCol() + 1 SAY PadR( field->brdok, 20 )

      @ PRow(), PCol() + 1 SAY PadR( AllTrim( field->idroba ) + ;
         " - " + AllTrim( field->r_naz ), 50 )

      @ PRow(), PCol() + 1 SAY field->rbr

      @ PRow(), PCol() + 1 SAY PadR( "(" + AllTrim( field->idpartner ) + ;
         ") " + AllTrim( field->p_naz ), 50 )

      @ PRow(), nCol := PCol() + 1 SAY Str( field->kolicina, 12, 2 )

      @ PRow(), PCol() + 1 SAY Str( field->kol_sast, 12, 2 )

      nT_kol += field->kolicina
      nT_k2 += field->kol_sast

      SKIP
   ENDDO

   ? cLine

   ? "UKUPNO:"

   @ PRow(), nCol SAY Str( nT_kol, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nT_k2, 12, 2 )

   ? cLine

   FF
   ENDPRINT

   RETURN


// -----------------------------------------------
// stampanje izvjestaja
// -----------------------------------------------
STATIC FUNCTION pr_report()

   LOCAL nRbr := 0
   LOCAL cLine
   LOCAL nTp_ul := 0
   LOCAL nTp_iz := 0
   LOCAL nTp_st := 0
   LOCAL nTp_nvu := 0
   LOCAL nTp_nvi := 0
   LOCAL nTp_nvs := 0
   LOCAL nNp_ul := 0
   LOCAL nNp_iz := 0
   LOCAL nNp_st := 0
   LOCAL nNp_nvu := 0
   LOCAL nNp_nvi := 0
   LOCAL nNp_nvs := 0
   LOCAL nCol := 2

   cLine := g_line( 1 )

   START PRINT CRET
   ?

   r_zagl( cLine, 1 )

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      ? PadL( AllTrim( Str( ++nRbr ) ), 4 ) + ")"

      @ PRow(), PCol() + 1 SAY PadR( "(" + AllTrim( field->idroba ) + ") " + ;
         r_naz( field->idroba ), 30 )

      // ulaz
      @ PRow(), nCol := PCol() + 1 SAY Str( field->tp_ul, 12, 2 )
      // tp. izlaz
      @ PRow(), nCol2 := PCol() + 1 SAY Str( field->tp_iz, 12, 2 )
      // tp. stanje
      @ PRow(), PCol() + 1 SAY Str( field->tp_st, 12, 2 )
      // +/- kolicine
      @ PRow(), PCol() + 1 SAY Str( field->tp_st - field->np_st, 12, 2 )
      // nv. ulaz
      @ PRow(), PCol() + 1 SAY Str( field->tp_nvu, 12, 2 )
      // tp. nv izlaz
      @ PRow(), nCol3 := PCol() + 1 SAY Str( field->tp_nvi, 12, 2 )
      // tp. nv stanje
      @ PRow(), PCol() + 1 SAY Str( field->tp_nvs, 12, 2 )
      // +/- stanja
      @ PRow(), PCol() + 1 SAY Str( field->tp_nvs - field->np_nvs, 12, 2 )

      ? " "

      // np. izlaz
      @ PRow(), nCol2 SAY Str( field->np_iz, 12, 2 )
      // np stanje
      @ PRow(), PCol() + 1 SAY Str( field->np_st, 12, 2 )
      // np nv izlaz
      @ PRow(), nCol3 SAY Str( field->np_nvi, 12, 2 )
      // np nv stanje
      @ PRow(), PCol() + 1 SAY Str( field->np_nvs, 12, 2 )

      nTp_ul += field->tp_ul
      nTp_iz += field->tp_iz
      nTp_st += field->tp_st
      nTp_nvu += field->tp_nvu
      nTp_nvi += field->tp_nvi
      nTp_nvs += field->tp_nvs

      nNp_ul += field->np_ul
      nNp_iz += field->np_iz
      nNp_st += field->np_st
      nNp_nvu += field->np_nvu
      nNp_nvi += field->np_nvi
      nNp_nvs += field->np_nvs

      SKIP
   ENDDO

   ? cLine

   ? "UKUPNO:"

   @ PRow(), nCol SAY Str( nTp_ul, 12, 2 )
   @ PRow(), nCol2 := PCol() + 1 SAY Str( nTp_iz, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTp_st, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTp_st - nNp_st, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTp_nvu, 12, 2 )
   @ PRow(), nCol3 := PCol() + 1 SAY Str( nTp_nvi, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTp_nvs, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTp_nvs - nNp_nvs, 12, 2 )

   ? " "
   @ PRow(), nCol2 SAY Str( nNp_iz, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nNp_st, 12, 2 )
   @ PRow(), nCol3 SAY Str( nNp_nvi, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nNp_nvs, 12, 2 )

   ? cLine

   FF
   ENDPRINT

   RETURN

// ---------------------------------------------
// ---------------------------------------------
STATIC FUNCTION r_zagl( cLine, nVar )

   LOCAL cTxt := ""

   IF nVar == 1

      cTxt += PadR( "rbr", 5 )
      cTxt += Space( 1 )
      cTxt += PadR( "roba (id/naziv)", 30 )
      cTxt += Space( 1 )
      cTxt += PadR( "ulaz", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( "tp/np izlaz", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( "tp/np stanje", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( "+/-", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( "NV ulaza", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( "tp/np NV iz.", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( "tp/np NV st.", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( "+/-", 12 )

      ? "Kontrola sastavnica - sta bi bilo kad bi bilo...."
      ? "   - tp = tekuci promet"
      ? "   - np = novi promet"
      ? "   - (+/-) pokazatelj greske"
      ?

   ELSE

      cTxt += PadR( "rbr", 5 )
      cTxt += Space( 1 )
      cTxt += PadR( "broj dok.", 20 )
      cTxt += Space( 1 )
      cTxt += PadR( "roba", 50 )
      cTxt += Space( 1 )
      cTxt += PadR( "st.", 4 )
      cTxt += Space( 1 )
      cTxt += PadR( "partner", 50 )
      cTxt += Space( 1 )
      cTxt += PadR( "kol.roba", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( "kol.sast", 12 )

   ENDIF

   P_COND2

   ? cLine
   ? cTxt
   ? cLine

   RETURN


// ----------------------------------------
// vraca liniju
// ----------------------------------------
STATIC FUNCTION g_line( nVar )

   LOCAL cTxt := ""

   IF nVar == 1

      cTxt += Replicate( "-", 5 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 30 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )

   ELSE

      cTxt += Replicate( "-", 5 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 20 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 50 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 4 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 50 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += Replicate( "-", 12 )

   ENDIF

   RETURN cTxt


// -----------------------------------------
// roba naziv - vraca
// -----------------------------------------
STATIC FUNCTION p_naz( id )

   LOCAL nTArea := Select()
   LOCAL cRet := "nepostojeca sifra"

   SELECT partn
   GO TOP
--   SEEK id

   IF Found()
      cRet := AllTrim( field->naz )
   ENDIF

   SELECT ( nTArea )

   RETURN cRet



// -----------------------------------------
// roba naziv - vraca
// -----------------------------------------
STATIC FUNCTION r_naz( id )

   LOCAL nTArea := Select()
   LOCAL cRet := "nepostojeca sifra"

   SELECT roba
   GO TOP
   SEEK id

   IF Found()
      cRet := AllTrim( field->naz )
   ENDIF

   SELECT ( nTArea )

   RETURN cRet


*/
