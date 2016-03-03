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


FUNCTION TDesktopNew()

   LOCAL oObj

   oObj := TDesktop():new()

   oObj:nRowLen := MAXROWS()
   oObj:nColLen := MAXCOLS()

   oObj:cColTitle := "GR+/N"
   oObj:cColBorder := "GR+/N"
   oObj:cColFont := "W/N  ,R/BG ,,,B/W"

   RETURN oObj


CREATE CLASS TDesktop

   EXPORTED:
   VAR cColShema

   VAR cColTitle
   VAR cColBorder
   VAR cColFont


   // tekuce koordinate
   VAR nRow
   VAR nCol
   VAR nRowLen
   VAR nColLen

   METHOD getRow
   METHOD getCol
   METHOD showLine
   METHOD setColors
   METHOD showSezona
   METHOD showMainScreen

END CLASS

METHOD getRow()
   return ::nRow


METHOD getCol()
   return ::nCol



METHOD showLine( cTekst, cRow )

   LOCAL nCol

   IF cTekst <> NIL
      IF Len( cTekst ) > 80
         nCol := 0
      ELSE
         nCol := Int( ( MAXCOLS() -Len( cTekst ) ) / 2 )
      ENDIF
      @ nRow, 0 SAY Replicate( Chr( 32 ), MAXCOLS() )
      @ nRow, nCol SAY cTekst
   ENDIF

   RETURN .T.


METHOD setColors( cIzbor )

   IF IsColor()
      DO CASE
      CASE cIzbor == "B1"
         ::cColTitle := "GR+/N"
         ::cColBorder  := "GR+/N"
         ::cColFont := "W/N  ,R/BG ,,,B/W"

      CASE cIzbor == "B2"
         ::cColTitle := "N/G"
         ::cColBorder := "N/G"
         ::cColFont := "W+/G ,R/BG ,,,B/W"

      CASE cIzbor == "B3"
         ::cColTitle := "R+/N"
         ::cColBorder := "R+/N"
         ::cColFont  := "N/GR ,R/BG ,,,B/W"

      CASE cIzbor == "B4"
         ::cColTitle := "B/BG"
         ::cColBorder  := "B/W"
         ::cColFont  := "B/W  ,R/BG ,,,B/W"

      CASE cIzbor == "B5"
         ::cColTitle := "B/W"
         ::cColBorder  := "R/W"
         ::cColFont  := "GR+/N,R/BG ,,,B/W"

      CASE cIzbor == "B6"
         ::cColTitle := "B/W"
         ::cColBorder  := "R/W"
         ::cColFont  := "W/N,R/BG ,,,B/W"
      CASE cIzbor == "B7"
         ::cColTitle := "B/W"
         ::cColBorder  := "R/W"
         ::cColFont  := "N/G,R+/N ,,,B/W"
      OTHERWISE
      ENDCASE

   ELSE
      ::cColTitle := "N/W"
      ::cColBorder  := "N/W"
      ::cColFont  := "W/N  ,N/W  ,,,N/W"
   ENDIF
   ::cColShema := cIzbor

   RETURN cIzbor


METHOD showSezona( cSezona )

   @ 3, MAXCOLS() -10 SAY "Sez: " + cSezona COLOR F18_COLOR_INVERT

   RETURN .T.


METHOD showMainScreen( lClear )

   LOCAL _ver_pos := 3

   IF lClear == NIL
      lClear := .F.
   ENDIF

   IF lClear
      CLEAR
   ENDIF

   @ 0, 2 SAY '<ESC> Izlaz' COLOR F18_COLOR_INVERT
   @ 0, Col() + 2 SAY danasnji_datum() COLOR F18_COLOR_INVERT

   DispBox( 2, 0, 4, MAXCOLS() - 1, B_DOUBLE + ' ', F18_COLOR_NORMAL )

   IF lClear
      DispBox( 5, 0, MAXROWS() - 1, MAXCOLS() - 1, B_DOUBLE + "±", F18_COLOR_INVERT  )
   ENDIF

   @ _ver_pos, 1 SAY PadC( gNaslov + ' Ver.' + F18_VER, MAXCOLS() - 8 ) COLOR F18_COLOR_NORMAL

   f18_ispisi_status_log_levela()
   f18_ispisi_status_podrucja( _ver_pos )
   f18_ispisi_status_modula()

   RETURN .T.


FUNCTION f18_ispisi_status_log_levela()

   @ MAXROWS(), 1 SAY "log level: " + AllTrim( Str( log_level() ) )

   RETURN .T.


FUNCTION f18_ispisi_status_podrucja( position )

   LOCAL _database := my_server_params()[ "database" ]
   LOCAL _color := "GR+/B"
   LOCAL _txt := ""
   LOCAL _c_tek_year := AllTrim( Str( Year( Date() ) ) )
   LOCAL _show := .F.

   IF !( _c_tek_year $ _database )
      _show := .T.
      _txt := "! SEZONSKO PODRUČJE: " + Right( AllTrim( _database ), 4 ) + " !"
      _color := "W/R+"
   ENDIF

   IF _show
      @ position, MAXCOLS() - 35 SAY8 PadC( _txt, 30 ) COLOR _color
   ENDIF

   RETURN .T.



FUNCTION f18_ispisi_status_modula()

   LOCAL _module := Lower( goModul:cName )
   LOCAL _in_use := f18_use_module( IF( _module == "tops", "pos", _module ) )
   LOCAL _color := "GR+/B"

   IF !_in_use
      _color := "W/R+"
      @ MAXROWS() -1, 25 SAY "!" COLOR _color
   ELSE
      @ MAXROWS() -1, 25 SAY " " COLOR _color
   ENDIF

   RETURN
