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

// ------------------------------------
// ------------------------------------
function last_semaphore_version(cTable)
local cTmpQry
local oRet

cTmpQry := "SELECT currval('fmk.sem_ver_" + cTable + "') as val"
oRet := _sql_query( oServer, cTmpQry )

return oRet:Fieldget( oRet:Fieldpos("val") )


/* ------------------------------------------
  get_semaphore_version( "konto", "hernad" )
  -------------------------------------------
*/
function get_semaphore_version(cTable, cUser)
LOCAL oTable
LOCAL nResult
LOCAL cTmpQry

cTable := "fmk.semaphores_" + cTable

nResult := table_count(oServer, cTable, "user_code=" + _sql_quote(cUser)) 

if nResult <> 1
  ? cTable, cUser, "count =", nResult
  return -1
endif


cTmpQry := "SELECT version FROM " + cTable + " WHERE user_code=" + _sql_quote(cUser)
oTable := _sql_query( oServer, cTmpQry )
IF oTable == NIL
      ? "problem sa:", cTmpQry
      QUIT
ENDIF

nResult := oTable:Fieldget( oTable:Fieldpos("version") )

RETURN nResult

/* ------------------------------------------
  update_semaphore_version( "konto", "hernad" )
  -------------------------------------------
*/
function update_semaphore_version(cTable, cUser)
LOCAL oRet
LOCAL nResult
LOCAL cTmpQry
LOCAL cFullTable

cFullTable := "fmk.semaphores_" + cTable
? "table=", cTable

nResult := table_count(oServer, cFullTable, "user_code=" + _sql_quote(cUser)) 

if nResult == 0

   cTmpQry := "INSERT INTO " + cFullTable + ;
              "(user_code, version) " + ;
               "VALUES(" + _sql_quote(cUser)  + ", nextval('fmk.sem_ver_"+ cTable + "') )"

   oRet := _sql_query( oServer, cTmpQry)

else

cTmpQry := "UPDATE " + cFullTable + ;
              " SET version=nextval('fmk.sem_ver_"+ cTable + "') " + ;
              " WHERE user_code =" + _sql_quote(cUser) 


oRet := _sql_query( oServer, cTmpQry )

endif

cTmpQry := "SELECT version from " + cFullTable + ;
           " WHERE user_code =" + _sql_quote(cUser) 
oRet := _sql_query( oServer, cTmpQry )

return oRet:Fieldget( oRet:Fieldpos("version") )



/* ------------------------------  
  broj redova za tabelu
  --------------------------------
*/
function table_count( oServer, cTable, cCondition)
LOCAL oTable
LOCAL nResult
LOCAL cTmpQry

// provjeri prvo da li postoji uopšte ovaj site zapis
cTmpQry := "SELECT COUNT(*) FROM " + cTable + " WHERE " + cCondition

oTable := _sql_query( oServer, cTmpQry )
IF oTable:NetErr()
      ? "problem sa query-jem: " + cTmpQry 
      QUIT
ENDIF

nResult := oTable:Fieldget( oTable:Fieldpos("count") )

RETURN nResult

