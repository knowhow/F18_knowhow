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
#include "common.ch"

// -------------------------------
// -------------------------------
function update_partn_from_sql()
local oQuery
local nCounter
 
//  ? "updateujem partn.dbf from sql stanja"

   oQuery := oServer:Query( "SELECT id, naz FROM fmk.partn" )

   aStruct := oQuery:Struct()

   FOR i := 1 TO Len( aStruct )
      ? aStruct[ i ][ 1 ], aStruct[ i ][ 2 ]
   NEXT

   ? "Fields: ", oQuery:Fcount()

   SELECT PARTN
   ZAP
  
   nCounter := 1
   DO WHILE ! oQuery:Eof()
      append blank
      replace id with oQuery:FieldGet(1), ;
              naz with oQuery:FieldGet(2)

      oQuery:Skip()

      //? nCounter++
   ENDDO

   oQuery:Destroy()

return 


// -------------------------------
// -------------------------------
function update_partn(cId, cNaz)
 update_partn_dbf(cId, cNaz)
 update_partn_sql(cId, cNaz)
return


function update_partn_dbf(cId, cNaz)
 append blank
 replace id with cId, naz with cNaz
return

function update_partn_sql(cId, cNaz)
LOCAL oRet
LOCAL nResult
LOCAL cTmpQry
LOCAL cTable

cTable := "fmk.partn"

nResult := table_count(oServer, cTable, "id=" + _sql_quote(cId)) 

if nResult == 0

   cTmpQry := "INSERT INTO " + cTable + ;
              "(id, naz) " + ;
               "VALUES(" + _sql_quote(cId)  + "," + _sql_quote(cNaz) +  ")"

   oRet := _sql_query( oServer, cTmpQry)

else

    cTmpQry := "UPDATE " + cTable + ;
                " SET naz = " + _sql_quote(cNaz) + ;
                " WHERE id =" + _sql_quote(cId) 


    oRet := _sql_query( oServer, cTmpQry )

endif

cTmpQry := "SELECT count(*) from " + cTable 
oRet := _sql_query( oServer, cTmpQry )

return oRet:Fieldget( oRet:Fieldpos("count") )
