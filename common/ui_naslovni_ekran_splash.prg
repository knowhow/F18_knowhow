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

   lInvert := .F.

   Box( "por", 11, 60, lInvert )
   SET CURSOR OFF

   @ m_x + 2, m_y + 2 SAY PadC( cNaslov, 60 )
   @ m_x + 3, m_y + 2 SAY PadC( "Ver. " + cVer, 60 )
   @ m_x + 5, m_y + 2 SAY PadC( "bring.out d.o.o. Sarajevo (" + F18_DEV_PERIOD + ")", 60 )
   @ m_x + 7, m_y + 2 SAY PadC( "Juraja Najtharta 3, Sarajevo, BiH", 60 )
   @ m_x + 8, m_y + 2 SAY PadC( "tel: 033/269-291, fax: 033/269-292", 60 )
   @ m_x + 9, m_y + 2 SAY PadC( "web: http://bring.out.ba", 60 )
   @ m_x + 10, m_y + 2 SAY PadC( "email: podrska@bring.out.ba", 60 )

   Inkey( 5 )

   BoxC()

   RETURN .T.
