/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"

// pomoćna funkcija za sql query izvršavanje
function _sql_query( oServer, cQuery )
LOCAL oResult
oResult := oServer:Query( cQuery )
IF oResult:NetErr()
      ? oResult:ErrorMsg()
      return NIL
ENDIF
RETURN oResult


// ------------------------
// ------------------------
function _sql_quote(cVar)
xVar := STRTRAN(cVar, "'","''")
return "'" + cVar + "'"

