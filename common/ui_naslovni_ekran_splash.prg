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

MEMVAR m_x, m_y


FUNCTION naslovni_ekran_splash_screen( cNaslov, cVer )

   LOCAL lInvert
   LOCAL nWin

   lInvert := .F.

   //Alert( F18_COLOR_INVERT )

   //@ MAXROWS() / 2 - 10, MAXCOLS() / 2 - 30 SAY ""

   main_window( WOpen( 0, 0, MAXROW(), MAXCOL() ) )


   WSetShadow( 1 % 8 )
   nWin := WOpen( 5, 10, 5 + 20, 10 + 70 )
   WBox()
   WSelect( nWin )
   //WBoard( 5, 5, 20, 75 )
   //WMode( .T., .T., .T., .T. )
   //WSetShadow( 7 )
   //SetClearA( 10 * 16 + 14 )
   //SetClearB( 35 )
   SetColor( F18_COLOR_INVERT )
   DispBox( 0, 0, MaxRow(), MaxCol(), Replicate( " ", 9 ) )
   SetPos( 0, 0 )

   //Box( , 12, 60, lInvert )
   SET CURSOR OFF

   @  2, 2 SAY PadC( cNaslov, 60 )
   @  3, 2 SAY PadC( "Verzija: " + cVer, 60 )
   @  5, 2 SAY PadC( "bring.out d.o.o. Sarajevo (" + F18_DEV_PERIOD + ")", 60 )
   @  7, 2 SAY PadC( "Juraja Najtharta 3, Sarajevo, BiH", 60 )
   @  8, 2 SAY PadC( "tel: 033/269-291, fax: 033/269-292", 60 )
   @  9, 2 SAY PadC( "web: http://bring.out.ba", 60 )
   @ 10, 2 SAY PadC( "email: podrska@bring.out.ba", 60)

  Inkey( 5 )

  WSelect( main_window() )

#ifdef F18_DEBUG
   Alert( "maxrow: " + hb_valToStr(MaxRow()) + " maxcol: " + hb_valToStr(MaxCol()) )
#endif
   //BoxC()

   RETURN .T.