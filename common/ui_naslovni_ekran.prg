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

   PUBLIC gNaslov  := "F18: " + oApp:cName + " (" + f18_dev_period() + ")  Ver: " + f18_ver() + " " + f18_ver_date()

   AFill( h, "" )
   nOldCursor := iif( ReadInsert(), 2, 1 )

   set_standardne_boje()



#ifdef __PLATFORM__DARWIN
   SET KEY K_F12 TO  swap_insert_over_stanje()
#else
   SET KEY K_INS TO  swap_insert_over_stanje()
#endif

   RETURN NIL



FUNCTION crtaj_naslovni_ekran( lClear )

   LOCAL _max_cols := MAXCOLS()
   LOCAL _max_rows := MAXROWS()

   IF lClear
      CLEAR
   ENDIF

   @ 0, 2 SAY '<ESC> Izlaz' COLOR F18_COLOR_INVERT
   @ 0, Col() + 2 SAY Date() COLOR F18_COLOR_INVERT
   @ _max_rows - 1, _max_cols - 16  SAY f18_lib_ver()

   DispBox( 2, 0, 4, _max_cols - 1, B_DOUBLE + BOX_CHAR_BACKGROUND_HEAD, F18_COLOR_NORMAL )

   IF lClear
      DispBox( 5, 0, _max_rows - 1, _max_cols - 1, B_DOUBLE + BOX_CHAR_BACKGROUND, F18_COLOR_INVERT  )
   ENDIF

   @ 3, 1 SAY PadC( gNaslov, _max_cols - 8 ) COLOR F18_COLOR_NORMAL

   show_podaci_organizacija()

   @ 4, 5 SAY ""
   show_dbf_prefix()
   show_insert_over_stanje()

   @ 0, MAXCOLS() - 14 SAY "bring.out" COLOR F18_COLOR_NORMAL

   RETURN .T.


STATIC FUNCTION show_podaci_organizacija()

   @ 0, 15 SAY AllTrim( gTS ) + " :"
   @ Row(), Col() + 2  SAY AllTrim( gNFirma ) + ", baza (" + my_server_params()[ "database" ] + ")" ;
      COLOR iif( in_tekuca_godina(), F18_COLOR_NAGLASENO, F18_COLOR_NAGLASENO_2 )

   RETURN .T.


FUNCTION swap_insert_over_stanje()
   RETURN show_insert_over_stanje( .T. )

FUNCTION show_dbf_prefix()

   LOCAL cPrefix
   IF !Empty( my_dbf_prefix() )
      cPrefix := "[" + Strtran( my_dbf_prefix(), "/", "" ) + "]"
      @ 0, MAXCOLS() - 4 SAY cPrefix COLOR F18_COLOR_NAGLASENO
   ENDIF


   RETURN .T.

FUNCTION show_insert_over_stanje( lSWap )

   LOCAL nX
   LOCAL nY
   LOCAL lNewState := ReadInsert()
   LOCAL cState

   hb_default( @lSwap, .F. )
   nX := Row()
   nY := Col()

   IF lSwap
      lNewState := !ReadInsert()
      ReadInsert( lNewState )
   ENDIF

   IF ReadInsert()
      cState := '< INS  >'
   ELSE
      cState := '< OVER >'
   ENDIF

   @ 0, MAXCOLS() - 23 SAY  cState COLOR F18_COLOR_INVERT

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
   LOCAL _in_use := f18_use_module( iif( _module == "pos", "pos", _module ) )
   LOCAL _color := F18_COLOR_STATUS

   IF !_in_use
      _color := F18_COLOR_POSEBAN_STATUS
      @ MAXROWS() -1, 25 SAY "!" COLOR _color
   ELSE
      @ MAXROWS() -1, 25 SAY " " COLOR _color
   ENDIF

   RETURN .T.
