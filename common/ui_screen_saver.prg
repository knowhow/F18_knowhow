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

FUNCTION ScreenSaver()

   LOCAL nBroji3
   LOCAL i, nRow, nCol, x := 0, y := 0, nSek, xs := 0, ys := 0, cTXT
   LOCAL cOC := Set( _SET_COLOR )

   nRow := Row()
   nCol := Col()

   cScr := SaveScreen()
   SET COLOR TO "W/N"
   SET CURSOR OFF
   nSek := Seconds()
   cTXT := "bring.out Sarajevo"
   nBroji3 := Seconds()
   DO WHILE NextKey() == 0
      IF GwStaMai( @nBroji3 ) $ "CB_KRAJ#CB_IDLE"

         // callback funkcija trazi kraj
         EXIT
      ENDIF
      IF Seconds() -nSek >= 1.2
         CLS
         nSek := Seconds()
         xs := x
         ys := y
         DO WHILE x = xs .OR. y = ys
            x := RANDOM() % 25
            y := RANDOM() % ( 80 -Len( cTXT ) )
         ENDDO
         VuciULin( xs, ys, x, y, cTXT )
      ENDIF
   ENDDO
   SET CURSOR ON
   cls
   Set( _SET_COLOR, cOC )
   RESTORE SCREEN FROM cScr

   // pozicioniraj kursor tamo gdje je i bio !
   @ nRow, nCol SAY ""

   RETURN


// ---------------------------------------
// ---------------------------------------
FUNCTION VuciULin( xs, ys, x, y, cTXT )

   LOCAL a, b, i, j, is := 99

   IF y == ys .OR. x == xs
      RETURN
   ENDIF
   a := ( y - ys ) / ( x - xs )
   b := y - a * x
   FOR j := ys TO y STEP IF( ys > y, -1, 1 )
      i := Round( ( j - b ) / a, 0 )
      IF is == 99 .OR. is <> i
         @ i, j  SAY cTxt
         is := i
      ENDIF
   NEXT

   RETURN

// -------------------------------------------------------
// -------------------------------------------------------
FUNCTION WaitScrSav( lKeyb )

   LOCAL cTmp
   LOCAL nBroji, nBroji2, nChar, nCekaj

   RETURN Inkey( 0 )

IF lKeyb == NIL
lKeyb := .F.
ENDIF

nBroji := Seconds()
nBroji2 := Seconds()

nCekaj := gCekaScreenSaver

WHILE ( nChar := Inkey() ) == 0
cTmp := CekaHandler( @nBroji2 )

IF ( Seconds() -nBroji ) / 60 >= nCekaj
screensaver()
nBroji := Seconds()
IF !lKeyb
CistiTipke()
ENDIF
ENDIF
ENDDO

IF lKeyb
KEYBOARD Chr( nChar )
ENDIF

   RETURN nChar
