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

#include "fakt.ch"



FUNCTION fakt_tip_dokumenta_default_menu()

   LOCAL nRet
  
   // gIMenu := "3" 
   nRet := VAL( gIMenu )
   IF nRet < 1
       nRet := 1
   ENDIF

   RETURN nRet   



FUNCTION fakt_naziv_dokumenta( aTipDok, cIdtipDok)

   LOCAL nPos, cRet

   nPos := AScan( aTipDok, { | x | cIdTipDok == Left( x, 2 ) } )
 
   IF nPos > 0
       cRet := aTipDok[ nPos ]
   ELSE
       cRet := ""
   ENDIF


   RETURN cRet