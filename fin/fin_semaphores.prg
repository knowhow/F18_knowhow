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
function fin_suban_from_sql_server(dat_dok)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y

_x := maxrows() - 15
_y := maxcols() - 20

@ _x + 1, _y + 2 SAY "update fin_suban: " + iif( dat_dok == NIL, "FULL", "DATE")
_seconds := SECONDS()

_qry :=  "SELECT idfirma, idvn, brnal, rbr, datdok, datval, opis, idpartner, idkonto, d_p, iznosbhd FROM fmk.fin_suban"  
if dat_dok != NIL
    _qry += " WHERE datdok>=" + _sql_quote(dat_dok)
endif

_qry_obj := _server:Query(_qry) 
if _qry_obj:NetErr()
   MsgBeep("ajoj :" + _qry_obj:ErrorMsg())
   QUIT
endif

SELECT F_SUBAN
my_use ("suban", "fin_suban", .f., "SEMAPHORE")

if dat_dok == NIL
    // "full" algoritam
    log_write("dat_dok = nil full algoritam") 
    ZAP
else
    log_write("dat_dok <> ni date algoritam") 
    // "date" algoritam  - brisi sve vece od zadanog datuma
    SET ORDER TO TAG "8"
    // tag je "DatDok" nije DTOS(DatDok)
    seek dat_dok
    do while !eof() .and. (field->datDok >= dat_dok) 
        // otidji korak naprijed
        SKIP
        _rec := RECNO()
        SKIP -1
        DELETE
        GO _rec  
    enddo

endif

@ _x + 4, _y + 2 SAY SECONDS() - _seconds 

_counter := 1

DO WHILE !_qry_obj:Eof()
    append blank
    //cQuery :=  "SELECT idfirma, idvn, brnal, rbr, datdok, datval, opis, idpartn, idkonto, d_p, iznosbhd FROM fmk.fin_suban"  
    replace idfirma with _qry_obj:FieldGet(1), ;
            idvn with _qry_obj:FieldGet(2), ;
            brnal with _qry_obj:FieldGet(3), ;
            rbr with _qry_obj:FieldGet(4), ;
            datdok with _qry_obj:FieldGet(5), ;
            datval with _qry_obj:FieldGet(6), ;
            opis with _qry_obj:FieldGet(7), ;
            idpartner with _qry_obj:FieldGet(8), ;
            idkonto with _qry_obj:FieldGet(9), ;
            d_p with _qry_obj:FieldGet(10), ;
            iznosbhd with _qry_obj:FieldGet(11)

    _qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
ENDDO

USE
_qry_obj:Destroy()

if (gDebug > 5)
    log_write("fin_suban synchro cache:" + STR(SECONDS() - _seconds))
endif

close all
 
return .t. 

// ----------------------------------------------
// ----------------------------------------------
function sql_fin_suban_update( op, record )

LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()


_tbl := "fmk.fin_suban"
_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) 

//                        " and rbr=" + _sql_quote(STR(record["r_br"], 4)); 
 
DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
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

END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 
function fin_anal_from_sql_server()

return

function fin_sint_from_sql_server()

return

function fin_nalog_from_sql_server()

return


