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

FUNCTION GetLozinka( nSiflen )

   LOCAL cKorsif

   cKorsif := ""
   Box(, 2, 30 )
   @ m_x + 2, m_y + 2 SAY "Lozinka..... "

   DO WHILE .T.

      nChar := WaitScrSav()

      IF nChar == K_ESC
         cKorsif := ""

      ELSEIF ( nChar == 0 ) .OR. ( nChar > 128 )
         LOOP

      ELSEIF ( nChar == K_ENTER )
         EXIT

      ELSEIF ( nChar == K_BS )
         cKorSif := Left( ckorsif, Len( cKorsif ) -1 )

      ELSE


         IF Len( cKorsif ) >= nSifLen // max 15 znakova
            Beep( 1 )
         ENDIF

         IF ( nChar > 1 )
            cKorsif := cKorSif + Chr( nChar )
         ENDIF

      ENDIF

      @ m_x + 2, m_y + 15 SAY PadR( Replicate( "*", Len( cKorSif ) ), nSifLen )
      IF ( nChar == K_ESC )
         LOOP
      ENDIF

   ENDDO

   BoxC()

   SET CURSOR ON

   RETURN PadR( cKorSif, nSifLen )
