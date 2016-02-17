/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"

FUNCTION SetMarza10()

   IF !spec_funkcije_sifra( "XYZ" )
      RETURN
   ENDIF

   nMarza := 2

   Box(, 3, 60 )
   @ m_x + 1, m_y + 2 SAY "Iznos marze " GET nMarza PICT "999999.99"
   READ
   BoxC()

   O_KALK_PRIPR
   GO TOP

   IF !( IDVD == "10" )
      RETURN
   ENDIF

   nDif := 0
   nVPC := 0

   my_flock()
   DO WHILE !Eof()
      nVPC := ( kalk_pripr->NC + nMarza )
      nDif := nVPC - Round( nVPC, 0 )
      REPLACE TMarza WITH "A", Marza WITH nMarza - nDif, VPC WITH kalk_pripr->NC + nMarza - nDif
      SKIP
   ENDDO
   my_unlock()

   RETURN .T.
