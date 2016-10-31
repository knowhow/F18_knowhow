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

   @ 3, MAXCOLS() -10 SAY "Sez: " + cSezona COLOR f18_color_invert()

   RETURN .T.


METHOD showMainScreen( lClear )

   LOCAL _ver_pos := 3

   IF lClear == NIL
      lClear := .F.
   ENDIF

   IF lClear
      CLEAR
   ENDIF

   @ 0, 2 SAY '<ESC> Izlaz' COLOR f18_color_invert()
   @ 0, Col() + 2 SAY danasnji_datum() COLOR f18_color_invert()

   DispBox( 2, 0, 4, MAXCOLS() - 1, B_DOUBLE + ' ', f18_color_normal() )

   IF lClear
      DispBox( 5, 0, MAXROWS() - 1, MAXCOLS() - 1, B_DOUBLE + BOX_CHAR_BACKGROUND, f18_color_invert()  )
   ENDIF

   @ _ver_pos, 1 SAY PadC( gNaslov + ' Ver.' + f18_ver(), MAXCOLS() - 8 ) COLOR f18_color_normal()

   f18_ispisi_status_log_levela()
   f18_ispisi_status_podrucja( _ver_pos )
   f18_ispisi_status_modula()

   RETURN .T.
