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


#include "fmk.ch"

FUNCTION QOutU( ... )
   
   LOCAL i
  
   FOR  i := 1 TO PCount()
        QOUT( hb_Utf8ToStr( hb_PValue( i ) ) )

   NEXT

   RETURN NIL


FUNCTION QQOutU( ... )
   
   LOCAL i
  
   FOR  i := 1 TO PCount()
        QQOUT( hb_Utf8ToStr( hb_PValue( i ) ) )
   NEXT

   RETURN NIL


