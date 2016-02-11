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

STATIC __mj_od
STATIC __mj_do
STATIC __god_od
STATIC __god_do
STATIC __tp1
STATIC __tp2
STATIC __tp3
STATIC __tp4
STATIC __tp5


FUNCTION ld_utrosak_po_sihtaricama()

   LOCAL cRj := Space( 60 )
   LOCAL cRadnik := Space( _LR_ )
   LOCAL cGroup := Space( 7 )
   LOCAL cTipRpt := "1"
   LOCAL cIdRj
   LOCAL cRjDEF := Space( 2 )
   LOCAL cMj_od
   LOCAL cMj_do
   LOCAL cGod_od
   LOCAL cGod_do
   LOCAL cDopr10 := "10"
   LOCAL cDopr11 := "11"
   LOCAL cDopr12 := "12"
   LOCAL cDopr1X := "1X"
   LOCAL cObracun := gObracun
   LOCAL cWinPrint := "N"
   LOCAL cDodPr1 := Space( 2 )
   LOCAL cDodPr2 := Space( 2 )
   LOCAL cDodPr3 := Space( 2 )
   LOCAL cDodPr4 := Space( 2 )
   LOCAL cDodPr5 := Space( 2 )
   LOCAL cPrimDobra := ""

   // kreiraj pomocnu tabelu
   ol_tmp_tbl()

   cIdRj := gRj
   cMj_od := gMjesec
   cMj_do := gMjesec
   cGod_od := gGodina
   cGod_do := gGodina

   // otvori tabele
   ol_o_tbl()

   Box( "#PREGLED TROSKOVA PO SIHTARICAMA", 11, 75 )

   @ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
   @ m_x + 2, m_y + 2 SAY "Period od:" GET cMj_od PICT "99"
   @ m_x + 2, Col() + 1 SAY "/" GET cGod_od PICT "9999"
   @ m_x + 2, Col() + 1 SAY "do:" GET cMj_do PICT "99"
   @ m_x + 2, Col() + 1 SAY "/" GET cGod_do PICT "9999"
   @ m_x + 2, Col() + 2 SAY "Obracun:" GET cObracun WHEN HelpObr( .T., cObracun ) VALID ValObr( .T., cObracun )
   @ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
      VALID Empty( cRadnik ) .OR. p_radn( @cRadnik )

   @ m_x + 5, m_y + 2 SAY "Grupa (prazno-sve): " GET cGroup ;
      VALID Empty( cGroup ) .OR. p_konto( @cGroup )

   @ m_x + 7, m_y + 2 SAY "Dodatna primanja za prikaz (1): " GET cDodPr1 ;
      VALID {|| _show_get_item_value( g_tp_naz( cDodPr1 ), 20 ), .T. }
   @ m_x + 8, m_y + 2 SAY "Dodatna primanja za prikaz (2): " GET cDodPr2 ;
      VALID {|| _show_get_item_value( g_tp_naz( cDodPr2 ), 20 ), .T. }
   @ m_x + 9, m_y + 2 SAY "Dodatna primanja za prikaz (3): " GET cDodPr3 ;
      VALID {|| _show_get_item_value( g_tp_naz( cDodPr3 ), 20 ), .T. }
   @ m_x + 10, m_y + 2 SAY "Dodatna primanja za prikaz (4): " GET cDodPr4 ;
      VALID {|| _show_get_item_value( g_tp_naz( cDodPr4 ), 20 ), .T. }
   @ m_x + 11, m_y + 2 SAY "Dodatna primanja za prikaz (5): " GET cDodPr5 ;
      VALID {|| _show_get_item_value( g_tp_naz( cDodPr5 ), 20 ), .T. }

   READ

   clvbox()

   ESC_BCR

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   // staticke
   __mj_od := cMj_od
   __mj_do := cMj_do
   __god_od := cGod_od
   __god_do := cGod_do
   __tp1 := ""
   __tp2 := ""
   __tp3 := ""

   IF !Empty( cDodPr1 )
      __tp1 := g_tp_naz( cDodPr1 )
   ENDIF
   IF !Empty( cDodPr2 )
      __tp2 := g_tp_naz( cDodPr2 )
   ENDIF
   IF !Empty( cDodPr3 )
      __tp3 := g_tp_naz( cDodPr3 )
   ENDIF
   IF !Empty( cDodPr4 )
      __tp4 := g_tp_naz( cDodPr4 )
   ENDIF
   IF !Empty( cDodPr5 )
      __tp5 := g_tp_naz( cDodPr5 )
   ENDIF

   SELECT ld

   Msgo( "... podaci plata ... molimo sacekajte" )
   // sortiraj tabelu i postavi filter
   ol_sort( cRj, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, cTipRpt, cObracun )

   // nafiluj podatke obracuna
   ol_fill_data( cRj, cRjDef, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, ;
      cPrimDobra, "", ;
      cDopr10, cDopr11, cDopr12, cDopr1X, cTipRpt, cObracun, ;
      cDodPr1, cDodPr2, cDodPr3, cDodPr4, cDodPr5 )

   msgc()

   // podatke iz tabele pohrani u matricu
   // to su obracuni
   aObr := {}
   _obr_2_arr( @aObr )

   msgo( "... generisem izvjestaj ...." )

   // generisi report
   _gen_rpt( cGod_od, cMj_od, cRadnik, cGroup, aObr )

   msgc()

   // stampa reporta
   _print_rpt()

   my_close_all_dbf()

   RETURN


// ----------------------------------------------
// nafiluj matricu iz tabele r_export
// ----------------------------------------------
STATIC FUNCTION _obr_2_arr( aArr )

   SELECT r_export
   GO TOP

   DO WHILE !Eof()

      AAdd( aArr, { field->godina, ;
         field->mjesec, ;
         field->idradn, ;
         field->naziv, ;
         field->sati, ;
         field->prihod, ;
         field->bruto, ;
         field->neto, ;
         field->dop_pio, ;
         field->dop_zdr, ;
         field->dop_nez, ;
         field->dop_uk, ;
         field->osn_por, ;
         field->izn_por, ;
         field->tp_1, ;
         field->tp_2, ;
         field->tp_3, ;
         field->tp_4, ;
         field->tp_5 } )

      SKIP
   ENDDO

   RETURN


// -----------------------------
// otvori tabele
// -----------------------------
STATIC FUNCTION o_tables()

   O_LD
   O_RADN
   O_KONTO
   O_RADSIHT
   O_DOPR
   O_POR

   RETURN


// ------------------------------------------------------------
// generisanje reporta
// ------------------------------------------------------------
STATIC FUNCTION _gen_rpt( nGod_od, nMj_od, cRadnik, cGroup, aObr )

   // kreiraj r_export tabelu
   cre_tmp_tbl()

   o_tables()

   SELECT radsiht

   // sortiraj sihtarice
   sort_siht( nGod_od, nMj_od, cRadnik, cGroup )
   SET ORDER TO TAG "1"
   GO TOP


   DO WHILE !Eof()

      cGr_siht := field->idkonto
      cGr_naz := g_gr_naz( cGr_siht )
      cRa_siht := field->idradn
      // ovo su sati po sihtarici
      nSiht_sati := field->izvrseno
      nRa_mj := field->mjesec
      nRa_god := field->godina

      // pronadji radnika u matrici
      nTmp := AScan( aObr, {|xVal| xVal[ 1 ] == nRa_god .AND. ;
         xVal[ 2 ] == nRa_mj .AND. xVal[ 3 ] == cRa_siht } )

      IF nTmp == 0
         // nisam nasao
         SKIP
         LOOP
      ENDIF

      cRa_naz := aObr[ nTmp, 4 ]
      nSati := aObr[ nTmp, 5 ]
      nPrih := aObr[ nTmp, 6 ]
      nBruto := aObr[ nTmp, 7 ]
      nNeto := aObr[ nTmp, 8 ]
      nDop_pio := aObr[ nTmp, 9 ]
      nDop_zdr := aObr[ nTmp, 10 ]
      nDop_nez := aObr[ nTmp, 11 ]
      nDop_uk := aObr[ nTmp, 12 ]
      nOsn_por := aObr[ nTmp, 13 ]
      nIzn_por := aObr[ nTmp, 14 ]
      nTp_1 := aObr[ nTmp, 15 ]
      nTp_2 := aObr[ nTmp, 16 ]
      nTp_3 := aObr[ nTmp, 17 ]
      nTp_4 := aObr[ nTmp, 18 ]
      nTp_5 := aObr[ nTmp, 19 ]

      SELECT r_export
      APPEND BLANK

      REPLACE field->mjesec WITH nRa_mj
      REPLACE field->godina WITH nRa_god
      REPLACE field->idradn WITH cRa_siht
      REPLACE field->r_naz WITH _rad_ime( cRa_siht )
      REPLACE field->naziv WITH cRa_naz
      REPLACE field->group WITH cGr_siht
      REPLACE field->gr_naz WITH cGr_naz
      REPLACE field->sati WITH nSiht_sati
      REPLACE field->prihod WITH _calc_val( nPrih, nSati, nSiht_sati )
      REPLACE field->bruto WITH _calc_val( nBruto, nSati, nSiht_sati )
      REPLACE field->neto WITH _calc_val( nNeto, nSati, nSiht_sati )
      REPLACE field->dop_pio WITH _calc_val( nDop_pio, nSati, nSiht_sati )
      REPLACE field->dop_zdr WITH _calc_val( nDop_zdr, nSati, nSiht_sati )
      REPLACE field->dop_nez WITH _calc_val( nDop_nez, nSati, nSiht_sati )
      REPLACE field->dop_uk WITH _calc_val( nDop_uk, nSati, nSiht_sati )
      REPLACE field->osn_por WITH _calc_val( nOsn_por, nSati, nSiht_sati )
      REPLACE field->izn_por WITH _calc_val( nIzn_por, nSati, nSiht_sati )
      REPLACE field->tp_1 WITH _calc_val( nTp_1, nSati, nSiht_sati )
      REPLACE field->tp_2 WITH _calc_val( nTp_2, nSati, nSiht_sati )
      REPLACE field->tp_3 WITH _calc_val( nTp_3, nSati, nSiht_sati )
      REPLACE field->tp_4 WITH _calc_val( nTp_4, nSati, nSiht_sati )
      REPLACE field->tp_5 WITH _calc_val( nTp_5, nSati, nSiht_sati )

      SELECT radsiht
      SKIP

   ENDDO

   RETURN


// -------------------------------------------------------
// kalkulisi iznos po novoj satnici
// -------------------------------------------------------
STATIC FUNCTION _calc_val( nVal, nSati, nNSati )

   LOCAL nRet := 0

   nRet := ( nNSati / nSati ) * nVal

   RETURN nRet


// -------------------------------------------
// vraca linije i header
// -------------------------------------------
STATIC FUNCTION _g_line( cLine )

   cLine := Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 30 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 8 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )

   cTxt := PadR( "R.br", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "Ime i prezime radnika", 30 )
   cTxt += Space( 1 )
   cTxt += PadR( "Sati", 8 )
   cTxt += Space( 1 )
   cTxt += PadR( "Bruto", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "Neto", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "Dopr.PIO", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "Dopr.ZDR", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "Dopr.NEZ", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "Porez", 12 )

   IF !Empty( __tp1 )
      cLine += Space( 1 )
      cLine += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( __tp1, 12 )
   ENDIF
   IF !Empty( __tp2 )
      cLine += Space( 1 )
      cLine += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( __tp2, 12 )
   ENDIF
   IF !Empty( __tp3 )
      cLine += Space( 1 )
      cLine += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( __tp3, 12 )
   ENDIF
   IF !Empty( __tp4 )
      cLine += Space( 1 )
      cLine += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( __tp4, 12 )
   ENDIF
   IF !Empty( __tp5 )
      cLine += Space( 1 )
      cLine += Replicate( "-", 12 )
      cTxt += Space( 1 )
      cTxt += PadR( __tp5, 12 )
   ENDIF

   ? cLine
   ? cTxt
   ? cLine

   RETURN




// ----------------------------------------------------------
// printanje reporta
// ----------------------------------------------------------
STATIC FUNCTION _print_rpt()

   LOCAL cLine
   LOCAL nU_sati := 0
   LOCAL nU_bruto := 0
   LOCAL nU_neto := 0
   LOCAL nU_d_pio := 0
   LOCAL nU_d_nez := 0
   LOCAL nU_d_zdr := 0
   LOCAL nU_i_por := 0
   LOCAL nU_o_por := 0
   LOCAL nU_tp_1 := 0
   LOCAL nU_tp_2 := 0
   LOCAL nU_tp_3 := 0
   LOCAL nU_tp_4 := 0
   LOCAL nU_tp_5 := 0
   LOCAL nT_sati := 0
   LOCAL nT_bruto := 0
   LOCAL nT_neto := 0
   LOCAL nT_d_pio := 0
   LOCAL nT_d_nez := 0
   LOCAL nT_d_zdr := 0
   LOCAL nT_i_por := 0
   LOCAL nT_o_por := 0
   LOCAL nT_tp_1 := 0
   LOCAL nT_tp_2 := 0
   LOCAL nT_tp_3 := 0
   LOCAL nT_tp_4 := 0
   LOCAL nT_tp_5 := 0
   LOCAL nCol := 15

   SELECT r_export
   SET ORDER TO TAG "1"
   GO TOP

   START PRINT CRET

   ?
   ? "Pregled utroska po objektima za: ", Str( __mj_od ) + "/" + Str( __god_od )
   ?

   P_COND2

   _g_line( @cLine )

   nCnt := 0
   DO WHILE !Eof()

      // n.str
      // if prow() > 64
      // FF
      // endif

      cGr_id := field->group

      nU_sati := 0
      nU_bruto := 0
      nU_neto := 0
      nU_d_pio := 0
      nU_d_nez := 0
      nU_d_zdr := 0
      nU_i_por := 0
      nU_o_por := 0
      nU_tp_1 := 0
      nU_tp_2 := 0
      nU_tp_3 := 0
      nU_tp_4 := 0
      nU_tp_5 := 0

      ? Space( 1 ), "Objekat: ", ;
         "(" + cGr_id + ")", ;
         PadR( g_gr_naz( cGr_id ), 30 )

      DO WHILE !Eof() .AND. field->group == cGr_id

         // n.str
         // if prow() > 64
         // FF
         // endif

         ? PadL( AllTrim( Str( ++nCnt ) ) + ".", 5 )
         @ PRow(), PCol() + 1 SAY PadR( _rad_ime( field->idradn ), 30 )
         @ PRow(), nCol := PCol() + 1 SAY Str( field->sati, 8, 2 )
         @ PRow(), PCol() + 1 SAY Str( field->bruto, 12, 2 )
         @ PRow(), PCol() + 1 SAY Str( field->neto, 12, 2 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_pio, 12, 2 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_zdr, 12, 2 )
         @ PRow(), PCol() + 1 SAY Str( field->dop_nez, 12, 2 )
         @ PRow(), PCol() + 1 SAY Str( field->izn_por, 12, 2 )

         IF !Empty( __tp1 )
            @ PRow(), PCol() + 1 SAY Str( field->tp_1, 12, 2 )
         ENDIF
         IF !Empty( __tp2 )
            @ PRow(), PCol() + 1 SAY Str( field->tp_2, 12, 2 )
         ENDIF
         IF !Empty( __tp3 )
            @ PRow(), PCol() + 1 SAY Str( field->tp_3, 12, 2 )
         ENDIF
         IF !Empty( __tp4 )
            @ PRow(), PCol() + 1 SAY Str( field->tp_4, 12, 2 )
         ENDIF
         IF !Empty( __tp5 )
            @ PRow(), PCol() + 1 SAY Str( field->tp_5, 12, 2 )
         ENDIF

         nU_sati += field->sati
         nU_bruto += field->bruto
         nU_neto += field->neto
         nU_d_pio += field->dop_pio
         nU_d_nez += field->dop_nez
         nU_d_zdr += field->dop_zdr
         nU_i_por += field->izn_por
         nU_o_por += field->osn_por
         nU_tp_1 += field->tp_1
         nU_tp_2 += field->tp_2
         nU_tp_3 += field->tp_3
         nU_tp_4 += field->tp_4
         nU_tp_5 += field->tp_5

         nT_sati += field->sati
         nT_bruto += field->bruto
         nT_neto += field->neto
         nT_d_pio += field->dop_pio
         nT_d_nez += field->dop_nez
         nT_d_zdr += field->dop_zdr
         nT_i_por += field->izn_por
         nT_o_por += field->osn_por
         nT_tp_1 += field->tp_1
         nT_tp_2 += field->tp_2
         nT_tp_3 += field->tp_3
         nT_tp_4 += field->tp_4
         nT_tp_5 += field->tp_5

         SKIP
      ENDDO

      // total po grupi....
      ? cLine
      ? PadL( "Ukupno " + cGr_id + ":", 25 )
      @ PRow(), nCol SAY Str( nU_sati, 8, 2 )
      @ PRow(), PCol() + 1 SAY Str( nU_bruto, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nU_neto, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nU_d_pio, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nU_d_zdr, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nU_d_nez, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nU_i_por, 12, 2 )

      IF !Empty( __tp1 )
         @ PRow(), PCol() + 1 SAY Str( nU_tp_1, 12, 2 )
      ENDIF
      IF !Empty( __tp2 )
         @ PRow(), PCol() + 1 SAY Str( nU_tp_2, 12, 2 )
      ENDIF
      IF !Empty( __tp3 )
         @ PRow(), PCol() + 1 SAY Str( nU_tp_3, 12, 2 )
      ENDIF
      IF !Empty( __tp4 )
         @ PRow(), PCol() + 1 SAY Str( nU_tp_4, 12, 2 )
      ENDIF
      IF !Empty( __tp5 )
         @ PRow(), PCol() + 1 SAY Str( nU_tp_5, 12, 2 )
      ENDIF

      ?

   ENDDO

   // total za sve....
   ? cLine
   ? "UKUPNO: "
   @ PRow(), nCol SAY Str( nT_sati, 8, 2 )
   @ PRow(), PCol() + 1 SAY Str( nT_bruto, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nT_neto, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nT_d_pio, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nT_d_zdr, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nT_d_nez, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nT_i_por, 12, 2 )

   IF !Empty( __tp1 )
      @ PRow(), PCol() + 1 SAY Str( nT_tp_1, 12, 2 )
   ENDIF
   IF !Empty( __tp2 )
      @ PRow(), PCol() + 1 SAY Str( nT_tp_2, 12, 2 )
   ENDIF
   IF !Empty( __tp3 )
      @ PRow(), PCol() + 1 SAY Str( nT_tp_3, 12, 2 )
   ENDIF
   IF !Empty( __tp4 )
      @ PRow(), PCol() + 1 SAY Str( nT_tp_4, 12, 2 )
   ENDIF
   IF !Empty( __tp5 )
      @ PRow(), PCol() + 1 SAY Str( nT_tp_5, 12, 2 )
   ENDIF

   ? cLine

   FF
   ENDPRINT

   RETURN


// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
STATIC FUNCTION cre_tmp_tbl()

   LOCAL aDbf := {}

   AAdd( aDbf, { "IDRADN", "C", 6, 0 } )
   AAdd( aDbf, { "R_NAZ", "C", 30, 0 } )
   AAdd( aDbf, { "GROUP", "C", 7, 0 } )
   AAdd( aDbf, { "GR_NAZ", "C", 50, 0 } )
   AAdd( aDbf, { "NAZIV", "C", 15, 0 } )
   AAdd( aDbf, { "MJESEC", "N", 2, 0 } )
   AAdd( aDbf, { "GODINA", "N", 4, 0 } )
   AAdd( aDbf, { "TP_1", "N", 12, 2 } )
   AAdd( aDbf, { "TP_2", "N", 12, 2 } )
   AAdd( aDbf, { "TP_3", "N", 12, 2 } )
   AAdd( aDbf, { "TP_4", "N", 12, 2 } )
   AAdd( aDbf, { "TP_5", "N", 12, 2 } )
   AAdd( aDbf, { "SATI", "N", 12, 2 } )
   AAdd( aDbf, { "PRIHOD", "N", 12, 2 } )
   AAdd( aDbf, { "BRUTO", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_PIO", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_ZDR", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_NEZ", "N", 12, 2 } )
   AAdd( aDbf, { "DOP_UK", "N", 12, 2 } )
   AAdd( aDbf, { "NETO", "N", 12, 2 } )
   AAdd( aDbf, { "OSN_POR", "N", 12, 2 } )
   AAdd( aDbf, { "IZN_POR", "N", 12, 2 } )
   AAdd( aDbf, { "UKUPNO", "N", 12, 2 } )

   t_exp_create( aDbf )

   O_R_EXP

   // index on ......
   INDEX ON group + idradn + Str( godina, 4 ) + Str( mjesec, 2 ) TAG "1"

   RETURN
