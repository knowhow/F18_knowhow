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
   oObj:cColFont := "W/N,R/BG ,,,B/W"

   RETURN oObj


CREATE CLASS TDesktop

   EXPORTED:
   VAR cColShema

   VAR cColTitle
   VAR cColBorder
   VAR cColFont


   VAR nRow
   VAR nCol
   VAR nRowLen
   VAR nColLen

   METHOD getRow
   METHOD getCol
   METHOD showLine
   METHOD showSezona
   METHOD showMainScreen

ENDCLASS


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
      DispBox( 5, 0, MAXROWS() - 1, MAXCOLS() - 1, B_DOUBLE + BOX_CHAR_BACKGROUND, F18_COLOR_INVERT  )
   ENDIF

   @ _ver_pos, 1 SAY PadC( gNaslov + ' Ver.' + f18_ver(), MAXCOLS() - 8 ) COLOR F18_COLOR_NORMAL

   f18_ispisi_status_log_levela()
   f18_ispisi_status_podrucja( _ver_pos )
   f18_ispisi_status_modula()

   RETURN .T.
