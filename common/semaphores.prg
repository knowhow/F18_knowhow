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
function get_semaphore_version(cTable)
LOCAL oTable
LOCAL nResult
LOCAL cTmpQry
LOCAL oServer

oServer:= pg_server()

cTable := "fmk.semaphores_" + cTable

nResult := table_count(oServer, cTable, "user_code=" + _sql_quote(f18_user())) 

if nResult <> 1
  log_write( cTable + " " + f18_user() + "count =" + STR(nResult))
  return -1
endif


cTmpQry := "SELECT version FROM " + cTable + " WHERE user_code=" + _sql_quote(f18_user())
oTable := _sql_query( oServer, cTmpQry )
IF oTable == NIL
      MsgBeep( "problem sa:" + cTmpQry)
      QUIT
ENDIF

nResult := oTable:Fieldget( oTable:Fieldpos("version") )

RETURN nResult

/* ------------------------------------------
  update_semaphore_version( "konto", "hernad" )
  -------------------------------------------
*/
function update_semaphore_version(cTable)
LOCAL oRet
LOCAL nResult
LOCAL cTmpQry
LOCAL cFullTable
LOCAL cUser := f18_user()
LOCAL oServer := pg_server()

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
function table_count(cTable, cCondition)
LOCAL oTable
LOCAL nResult
LOCAL cTmpQry
LOCAL oServer := pg_server()


// provjeri prvo da li postoji uopšte ovaj site zapis
cTmpQry := "SELECT COUNT(*) FROM " + cTable + " WHERE " + cCondition

oTable := _sql_query( oServer, cTmpQry )
IF oTable:NetErr()
      log_write( "problem sa query-jem: " + cTmpQry )
      QUIT
ENDIF

nResult := oTable:Fieldget( oTable:Fieldpos("count") )

RETURN nResult

