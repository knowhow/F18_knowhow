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

#include "fin.ch"
#include "common.ch"

/*
// -------------------------------------------------------------------------------------------
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
*/

/* -----------------------------
 puni sql bazu fmk.fin_suban
 ------------------------------ */
function sql_fin_suban_update(cIdFirma, cIdVn, cBrNal, nRbr, dDatDok, dDatVal, cOpis, cIdPartner, cKonto, cDP, nIznos)
LOCAL oRet
LOCAL nResult
LOCAL cTmpQry
LOCAL cTable
LOCAL cWhere
LOCAL oServer := pg_server()

if cIdFirma == "BEGIN"
    cTmpQry := "BEGIN;"
elseif cIdFirma == "END"
    cTmpQry := "COMMIT;"
elseif cIdFirma == "ROLLBACK"
    cTmpQry := "ROLLBACK;"
else
    cWhere := "idfirma=" + _sql_quote(cIdFirma) + " and idvn=" + _sql_quote(cIdVn) +;
                        " and brnal=" + _sql_quote(cBrNal) +;
                        " and rbr=" + _sql_quote(STR(nRbr,4)); 

    cTable := "fmk.fin_suban"

    cTmpQry := "INSERT INTO " + cTable + ;
                "(idfirma, idvn, brnal, rbr, datdok, datval, opis, idpartner, idkonto, d_P, iznosbhd) " + ;
                "VALUES(" + _sql_quote(cIdFirma)  + "," +;
                            + _sql_quote(cIdVn) + "," +; 
                            + _sql_quote(cBrNal) + "," +; 
                            + _sql_quote(STR(nRbr, 4)) + "," +; 
                            + _sql_quote(dDatDok) + "," +; 
                            + _sql_quote(dDatVal) + "," +; 
                            + _sql_quote(cOpis) + "," +; 
                            + _sql_quote(cIdPartner) + "," +; 
                            + _sql_quote(cKonto) + "," +; 
                            + _sql_quote(cDP) + "," +; 
                            + STR(nIznos, 17, 2) + ")" 

endif
   
oRet := _sql_query( oServer, cTmpQry)

if (gDebug > 5)
   log_write(cTmpQry)
   log_write("_sql_query VALTYPE(oRet) = " + VALTYPE(oRet))
endif

/* 
cTmpQry := "SELECT count(*) from " + cTable + " WHERE " + cWhere
oRet := _sql_query( oServer, cTmpQry )

return oRet:Fieldget( oRet:Fieldpos("count") )
*/

if VALTYPE(oRet) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return oRet
else
   return .t.
endif

 
// ------------------------------
// koristi azur_sql
// ------------------------------
function fin_suban_from_sql_server(dDatDok)
local oQuery
local nCounter
local nRec
local cQuery
local oServer := pg_server()
local nSeconds

   //Box("SQ", 10, 60)

   //@ m_x+1, m_y+2 SAY "updateujem fin_suban from SQL, algoritam: " + iif( dDatDok == NIL, "FULL", "DATE")
   nSeconds := SECONDS()
   cQuery :=  "SELECT idfirma, idvn, brnal, rbr, datdok, datval, opis, idpartner, idkonto, d_p, iznosbhd FROM fmk.fin_suban"  
   if dDatDok != NIL
      cQuery += " WHERE datdok>=" + _sql_quote(dDatDok)
   endif
 
   oQuery := oServer:Query(cQuery) 
   
   SELECT F_SUBAN
   my_use ("suban", "fin_suban", .f., "SEMAPHORE")

   if dDatDok == NIL
      // "full" algoritam
      log_write("dDatDok = nil full algoritam") 
      ZAP
   else
      log_write("dDatDok <> ni date algoritam") 
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

   //@ m_x+4, m_y+2 SAY SECONDS() - nSeconds 

   nCounter := 1
   DO WHILE !oQuery:Eof()
      append blank
      //cQuery :=  "SELECT idfirma, idvn, brnal, rbr, datdok, datval, opis, idpartn, idkonto, d_p, iznosbhd FROM fmk.fin_suban"  
      replace idfirma with oQuery:FieldGet(1), ;
              idvn with oQuery:FieldGet(2), ;
              brnal with oQuery:FieldGet(3), ;
              rbr with oQuery:FieldGet(4), ;
              datdok with oQuery:FieldGet(5), ;
              datval with oQuery:FieldGet(6), ;
              opis with oQuery:FieldGet(7), ;
              idpartner with oQuery:FieldGet(8), ;
              idkonto with oQuery:FieldGet(9), ;
              d_p with oQuery:FieldGet(10), ;
              iznosbhd with oQuery:FieldGet(11)

      oQuery:Skip()

      nCounter++

      if nCounter % 5000 == 0
         //@ m_x+4, m_y+2 SAY SECONDS() - nSeconds
      endif 
   ENDDO

   USE
   oQuery:Destroy()

   if (gDebug > 5)
     log_write("fin_suban synchro cache:" + STR(SECONDS() - nSeconds))
   endif

   //BoxC()
close all
 
return .t. 
