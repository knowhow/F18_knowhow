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

FUNCTION QOutU( ... )

   LOCAL nI, cTmp

   IF PCount() == 0
      QOut()
      RETURN NIL
   ENDIF

   QOut( hb_UTF8ToStr( hb_PValue( 1 ) ) )
   FOR  nI := 2 TO PCount()

      QQOut( " " )
      cTmp := hb_PValue( nI )
      IF ValType( cTmp ) != "C"
         QQOut( cTmp )
      ELSE
         QQOut( hb_UTF8ToStr( cTmp ) )
      ENDIF
   NEXT

   RETURN NIL


FUNCTION QQOutU( ... )

   LOCAL nI, cTmp

   FOR  nI := 1 TO PCount()
      cTmp := hb_PValue( nI )
      IF ValType( cTmp ) != "C"
         QQOut( cTmp )
      ELSE
         QQOut( hb_UTF8ToStr( cTmp ) )
      ENDIF
      IF nI > 1 .AND. nI < PCount()
         QQOut( " " )
      ENDIF
   NEXT

   RETURN NIL




/*
     cVarijanta 1 - SL852 -> SLWIN
                2 - UTF8 -> SLWIN
*/

FUNCTION QOutPdF( cVarijanta, ... )

   LOCAL nI, cTmp
   LOCAL cCodePageIn := CODE_PAGE_TERMINAL, cCodePageOut := CODE_PAGE_PDF

   IF PCount() == 0
      QOut()
      RETURN NIL
   ENDIF

   IF cVarijanta == "2"
      cCodePageIn := "UTF8"
   ENDIF

   QOut( hb_Translate( hb_PValue( 2 ), cCodePageIn, cCodePageOut ) )
   FOR  nI := 3 TO PCount()

      QQOut( " " )
      cTmp := hb_PValue( nI )
      IF ValType( cTmp ) != "C"
         QQOut( cTmp )
      ELSE
         QQOut( hb_Translate( cTmp,  cCodePageIn, cCodePageOut ) )
      ENDIF
   NEXT

   RETURN NIL


FUNCTION QQOutPDF( cVarijanta, ... )

   LOCAL nI, cTmp
   LOCAL cCodePageIn := CODE_PAGE_TERMINAL, cCodePageOut := CODE_PAGE_PDF

   IF cVarijanta == "2"
      cCodePageIn := "UTF8"
   ENDIF

   FOR  nI := 2 TO PCount()
      cTmp := hb_PValue( nI )
      IF ValType( cTmp ) != "C"
         QQOut( cTmp )
      ELSE
         QQOut( hb_Translate( cTmp, cCodePageIn, cCodePageOut ) )
      ENDIF
      IF nI > 2 .AND. nI < PCount()
         QQOut( " " )
      ENDIF
   NEXT

   RETURN NIL
