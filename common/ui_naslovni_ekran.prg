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



#ifdef __PLATFORM__DARWIN
   SET KEY K_F12 TO show_insert_over_stanje()
#else
   SET KEY K_INS TO show_insert_over_stanje()
#endif

   RETURN NIL



FUNCTION crtaj_naslovni_ekran( fBox )

   LOCAL _max_cols := MAXCOLS()
   LOCAL _max_rows := MAXROWS()

   IF fBox
      CLEAR
   ENDIF

   @ 0, 2 SAY '<ESC> Izlaz' COLOR F18_COLOR_INVERT
   @ 0, Col() + 2 SAY Date() COLOR F18_COLOR_INVERT
   @ _max_rows - 1, _max_cols - 16  SAY f18_lib_ver()

   DispBox( 2, 0, 4, _max_cols - 1, B_DOUBLE + BOX_CHAR_BACKGROUND_HEAD, F18_COLOR_NORMAL )

   IF fBox
      DispBox( 5, 0, _max_rows - 1, _max_cols - 1, B_DOUBLE + BOX_CHAR_BACKGROUND, F18_COLOR_INVERT  )
   ENDIF

   @ 3, 1 SAY PadC( gNaslov, _max_cols - 8 ) COLOR F18_COLOR_NORMAL

   podaci_organizacija()

   @ 4, 5 SAY ""

   show_insert_over_stanje()

   RETURN .T.


STATIC FUNCTION podaci_organizacija()

   @ 0, 15 SAY AllTrim( gTS ) + " : " + AllTrim( gNFirma ) + ", baza (" + my_server_params()[ "database" ] + ")"

   RETURN .T.

FUNCTION show_insert_over_stanje()

   LOCAL nX
   LOCAL nY

   nX := Row()
   nY := Col()

   IF ReadInsert( !ReadInsert() )
      //SetCursor( 1 )
      @ 0, MAXCOLS() - 20 SAY '< OVER >' COLOR F18_COLOR_INVERT
   ELSE
      //SetCursor( 2 )
      @ 0, MAXCOLS() - 20 SAY  '< INS  >' COLOR F18_COLOR_INVERT
   ENDIF

   @ 0, MAXCOLS() - 11 SAY "bring.out" COLOR F18_COLOR_NORMAL

   SetPos( nX, nY )

   RETURN .T.



FUNCTION set_global_screen_vars()

   PUBLIC m_x := 0
   PUBLIC m_y := 0

   RETURN .T.


FUNCTION f18_ispisi_status_log_levela()

   @ MAXROWS(), 1 SAY "log level: " + AllTrim( Str( log_level() ) )

   RETURN .T.


FUNCTION f18_ispisi_status_podrucja( position )

   LOCAL _database := my_server_params()[ "database" ]
   LOCAL _color := F18_COLOR_STATUS
   LOCAL _txt := ""
   LOCAL _c_tek_year := AllTrim( Str( Year( Date() ) ) )
   LOCAL _show := .F.

   IF !( _c_tek_year $ _database )
      _show := .T.
      _txt := "! SEZONSKO PODRUČJE: " + Right( AllTrim( _database ), 4 ) + " !"
      _color := F18_COLOR_POSEBAN_STATUS
   ENDIF

   IF _show
      @ position, MAXCOLS() - 35 SAY8 PadC( _txt, 30 ) COLOR _color
   ENDIF

   RETURN .T.



FUNCTION f18_ispisi_status_modula()

   LOCAL _module := Lower( goModul:cName )
   LOCAL _in_use := f18_use_module( IF( _module == "tops", "pos", _module ) )
   LOCAL _color := F18_COLOR_STATUS

   IF !_in_use
      _color := F18_COLOR_POSEBAN_STATUS
      @ MAXROWS() -1, 25 SAY "!" COLOR _color
   ELSE
      @ MAXROWS() -1, 25 SAY " " COLOR _color
   ENDIF

   RETURN .T.
