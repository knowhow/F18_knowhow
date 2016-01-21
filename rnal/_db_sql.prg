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

FUNCTION use_sql_rnal_ral()

   LOCAL cSql
   LOCAL aDbf := rnal_a_ral()
   LOCAL cTable := "rnal_ral"

   cSql := "SELECT "
   cSql += sql_from_adbf( @aDbf )
   cSql += " FROM fmk." + cTable + " ORDER BY id"


   SELECT F_RAL
   use_sql( cTable, cSql, "RAL" )

   INDEX ON "STR(id,5)+STR(gl_tick,2)" TAG "1" TO (cTable)
   INDEX ON "descr" TAG "2" TO (cTable)

   SET ORDER TO TAG "1"

   RETURN .T.

FUNCTION sql_from_adbf( aDbf )

   LOCAL i
   LOCAL cRet := ""

   FOR i := 1 TO LEN( aDbf )

     DO CASE
     CASE aDbf[i, 2] == "C"
         // naz2::char(4)
         cRet += aDbf[i, 1] + "::char(" + ALLTRIM( STR(aDbf[i, 3])) + ")"

     CASE aDbf[i, 2] == "N"
         // COALESCE(kurs1,0)::numeric(18,8) AS kurs1
         cRet += "COALESCE(" + aDbf[i, 1] + ",0)::numeric(" +;
         ALLTRIM( STR(aDbf[i, 3])) + "," + ALLTRIM( STR(aDbf[i, 4])) + ")"

     CASE aDbf[i, 2] == "D"
             // (CASE WHEN datum IS NULL THEN '1960-01-01'::date ELSE datum END) AS datum
             cRet += "(CASE WHEN " + aDbf[i, 1] + "IS NULL THEN '1960-01-01'::date ELSE " + aDbf[i,1] +;
             " END)"

     OTHERWISE
          MsgBeep( "ERROR sql_from_adbf field type !")
          RETURN NIL
     ENDCASE
     cRet += " AS " + aDbf[i,1]

     IF i < LEN(aDbf)
       cRet += ","
     ENDIF

   NEXT

   RETURN cRet
