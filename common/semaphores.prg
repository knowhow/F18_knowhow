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

//--------------------------
//       update_fin_suban("10", "10", "00000008", 1, DATE(), "4300", "2", 1500)
function update_fin_suban(cIdFirma, cIdVn, cBrNal, nRbr, dDatDok, cKonto, cDP, nIznos)

update_fin_suban_dbf(cIdFirma, cIdVn, cBrNal, nRbr, dDatDok, cKonto, cDP, nIznos)
update_fin_suban_sql(cIdFirma, cIdVn, cBrNal, nRbr, dDatDok, cKonto, cDP, nIznos)

return


function update_fin_suban_dbf(cIdFirma, cIdVn, cBrNal, nRbr, dDatDok, cKonto, cDP, nIznos)
 ? nIznos
 append blank
 replace IdFirma with cIdFirma,;
         IdVn with cIdVn,;
         BrNal with cBrNal,;
         rbr with STR(nRbr, 4),;
         IdKonto with cKonto,;
         D_P with cDP, ;
         IZNOSBHD  with nIznos
return

function update_fin_suban_sql(cIdFirma, cIdVn, cBrNal, nRbr, dDatDok, cKonto, cDP, nIznos)
LOCAL oRet
LOCAL nResult
LOCAL cTmpQry
LOCAL cTable
LOCAL cWhere


cWhere := "idfirma=" + _sql_quote(cIdFirma) + " and idvn=" + _sql_quote(cIdVn) +;
                      " and brnal=" + _sql_quote(cBrNal) +;
                      " and rbr=" + _sql_quote(STR(nRbr,4)); 

cTable := "fmk.fin_suban"

//nResult := table_count(oServer, cTable, "idfirma=" + _sql_quote(cIdFirma) + " and idvn=" + _sql_quite(cIdVn) + " and brnal=" + _sql_quote(cBrNal) ) 

//if nResult == 0

   cTmpQry := "INSERT INTO " + cTable + ;
              "(idfirma, idvn, brnal, rbr, datdok, idkonto, d_P, iznosbhd) " + ;
               "VALUES(" + _sql_quote(cIdFirma)  + "," +;
                         + _sql_quote(cIdVn) + "," +; 
                         + _sql_quote(cBrNal) + "," +; 
                         + _sql_quote(STR(nRbr, 4)) + "," +; 
                         + _sql_quote(DTOS(dDatDok)) + "," +; 
                         + _sql_quote(cKonto) + "," +; 
                         + _sql_quote(cDP) + "," +; 
                         + STR(nIznos, 17, 2) + ")" 


   oRet := _sql_query( oServer, cTmpQry)

//else

//cTmpQry := "UPDATE " + cTable + ;
//              " SET naz = " + _sql_quote(cNaz) + ;
//              " WHERE id =" + _sql_quote(cId) 


/// oRet := _sql_query( oServer, cTmpQry )

//endif

cTmpQry := "SELECT count(*) from " + cTable + " WHERE " + cWhere
oRet := _sql_query( oServer, cTmpQry )

return oRet:Fieldget( oRet:Fieldpos("count") )





// ------------------------------
// ------------------------------
function update_fin_suban_from_sql(dDatDok)
local oQuery
local nCounter
local nRec
local cQuery

   ? "updateujem fin_suban.dbf from sql stanja"

   cQuery :=  "SELECT idfirma, idvn, brnal, rbr, datdok, idkonto, d_p, iznosbhd FROM fmk.fin_suban"  
   if dDatDok != NIL
      cQuery += " WHERE datdok>=" + _sql_quote(DTOS(dDatDok))
   endif
 
   oQuery := oServer:Query(cQuery) 
   
   ? "Fields: ", oQuery:Fcount()

   USE (cHome + "fin_suban") NEW
   SELECT fin_suban

   if dDatDok == NIL
      // "full" algoritam
      ZAP 

   else
      // "date" algoritam  - brisi sve vece od zadanog datuma
      SET ORDER TO TAG "8"
      // tag je "DatDok" nije DTOS(DatDok)
      seek dDatDok
      do while !eof() .and. (datDok >= dDatDok) 
          // otidji korak naprijed
          SKIP
          nRec := RECNO()
          SKIP -1
          DELETE
          GO nRec  
      enddo
 
    endif


   nCounter := 1
   DO WHILE ! oQuery:Eof()
      append blank
      //cQuery :=  "SELECT idfirma, idvn, brnal, rbr, datdok, idkonto, d_p, iznosbhd FROM fmk.fin_suban"  
      replace idfirma with oQuery:FieldGet(1), ;
              idvn with oQuery:FieldGet(2), ;
              brnal with oQuery:FieldGet(3), ;
              rbr with oQuery:FieldGet(4), ;
              datdok with oQuery:FieldGet(5), ;
              idkonto with oQuery:FieldGet(6), ;
              d_p with oQuery:FieldGet(7), ;
              iznosbhd with oQuery:FieldGet(8)

      oQuery:Skip()

      //? nCounter++
   ENDDO

   USE
   oQuery:Destroy()

return 



function update_partn_from_sql()
local oQuery
local nCounter
   ? "updateujem partn.dbf from sql stanja"

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

 
return


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

