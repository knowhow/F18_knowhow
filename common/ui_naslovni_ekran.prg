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



FUNCTION pripremi_naslovni_ekran( oApp )

   set_global_screen_vars()

   PUBLIC gNaslov  := "F18: " + oApp:cName + " (" + F18_DEV_PERIOD + ")  Ver: " + F18_VER + " " + F18_VER_DATE

   AFill( h, "" )
   nOldCursor := iif( ReadInsert(), 2, 1 )

   set_standardne_boje()

   SET KEY K_INS TO show_insert_over_stanje()

#ifdef __PLATFORM__DARWIN
   SET KEY K_F12 TO show_insert_over_stanje()
#endif

   RETURN NIL



FUNCTION crtaj_naslovni_ekran( fBox )

   LOCAL _max_cols := MAXCOLS()
   LOCAL _max_rows := MAXROWS()

   IF fBox
      CLEAR
   ENDIF

   @ 0, 2 SAY '<ESC> Izlaz' COLOR gColorInvert
   @ 0, Col() + 2 SAY Date() COLOR gColorInvert
   @ _max_rows - 1, _max_cols - 16  SAY f18_lib_ver()

   DispBox( 2, 0, 4, _max_cols - 1, B_DOUBLE + BOX_CHAR_BACKGROUND_HEAD, NORMAL )

   IF fBox
      DispBox( 5, 0, _max_rows - 1, _max_cols - 1, B_DOUBLE + BOX_CHAR_BACKGROUND, gColorInvert  )
   ENDIF

   @ 3, 1 SAY PadC( gNaslov, _max_cols - 8 ) COLOR NORMAL

   podaci_organizacija()

   @ 4, 5 SAY ""

   RETURN .T.


STATIC FUNCTION podaci_organizacija()

   @ 0, 15 SAY AllTrim( gTS ) + " : " + AllTrim( gNFirma ) + ", baza (" + my_server_params()[ "database" ] + ")"

   RETURN .T.

FUNCTION show_insert_over_stanje()

   LOCAL nx
   LOCAL ny

   nx := Row()
   ny := Col()

   IF ReadInsert( !ReadInsert() )
      SetCursor( 1 )
      @ 0, MAXCOLS() - 20 SAY '< OVER >' COLOR gColorInvert
   ELSE
      SetCursor( 2 )
      @ 0, MAXCOLS() - 20 SAY  '< INS  >' COLOR gColorInvert
   ENDIF

   @ 0, MAXCOLS() - 11 SAY "bring.out" COLOR "GR+/B"

   SetPos( nx, ny )

   RETURN .T.



FUNCTION set_global_screen_vars()

   PUBLIC m_x := 0
   PUBLIC m_y := 0


   PUBLIC gColorInvert    := .T.
   PUBLIC Normal   := "GR+/B,R/N+,,,N/W"

   RETURN .T.
