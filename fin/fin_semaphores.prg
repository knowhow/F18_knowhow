/* 
 * This file is part of the bring.out ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"
#include "common.ch"

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
local x, y

x := maxrows() - 15
y := maxcols() - 20

@ x+1, y+2 SAY "update fin_suban: " + iif( dDatDok == NIL, "FULL", "DATE")
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

@ x+4, y+2 SAY SECONDS() - nSeconds 

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
        @ x+4, y+2 SAY SECONDS() - nSeconds
    endif 
ENDDO

USE
oQuery:Destroy()

if (gDebug > 5)
    log_write("fin_suban synchro cache:" + STR(SECONDS() - nSeconds))
endif

close all
 
return .t. 

// ----------------------------------------------
// ----------------------------------------------
function sql_fin_suban_update( op, record )

LOCAL oRet
LOCAL nResult
LOCAL cTmpQry
LOCAL cTable
LOCAL cWhere
LOCAL oServer := pg_server()

if op == "BEGIN"
    cTmpQry := "BEGIN;"
elseif op == "END"
    cTmpQry := "COMMIT;"
elseif op == "ROLLBACK"
    cTmpQry := "ROLLBACK;"
else
    cWhere := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) +;
                        " and rbr=" + _sql_quote(STR(record["r_br"], 4)); 

    cTable := "fmk.fin_suban"

    cTmpQry := "INSERT INTO " + cTable + ;
                "(idfirma, idvn, brnal, rbr, datdok, datval, opis, idpartner, idkonto, d_P, iznosbhd) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +; 
                            + _sql_quote(STR( record["r_br"] , 4)) + "," +; 
                            + _sql_quote( record["dat_dok"] ) + "," +; 
                            + _sql_quote( record["dat_val"] ) + "," +; 
                            + _sql_quote( record["opis"] ) + "," +; 
                            + _sql_quote( record["id_partner"] ) + "," +; 
                            + _sql_quote( record["id_konto"] ) + "," +; 
                            + _sql_quote( record["d_p"] ) + "," +; 
                            + STR( record["iznos"], 17, 2) + ")" 

endif
   
oRet := _sql_query( oServer, cTmpQry)

if (gDebug > 5)
   log_write(cTmpQry)
   log_write("_sql_query VALTYPE(oRet) = " + VALTYPE(oRet))
endif

if VALTYPE(oRet) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return oRet
else
   return .t.
endif
 
function fin_anal_from_sql_server()

return

function fin_sint_from_sql_server()

return

function fin_nalog_from_sql_server()

return


