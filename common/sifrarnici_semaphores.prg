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

// ----------------------------------------
// ----------------------------------------
function partn_from_sql_server(algoritam)
local _counter
local _rec
local _qry
local _server := pg_server()
local _seconds
local _x, _y
local _tmp_id, _ids
local _sql_ids
local _i
local _qry_obj

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update partn: " + algoritam
_seconds := SECONDS()
_qry :=  "SELECT id, naz from fmk.partn"

if (algoritam == "IDS")
    _ids := get_ids_from_semaphore("partn")
    _sql_ids := "("
    for _i := 1 to LEN(_ids)
        _sql_ids += _sql_quote(_ids[_i])
        if _i < LEN(_ids)
           _sql_ids += ","
        endif
    next
    _sql_ids := ")"
    _qry += " WHERE ids IN " + _sql_ids
endif

_qry_obj := _server:Query(_qry) 
if _qry_obj:NetErr()
   MsgBeep("ajoj :" + _qry_obj:ErrorMsg())
   QUIT
endif

SELECT F_PARTN
my_use ("partn", "partn", .f., "SEMAPHORE")

if (algoritam == "FULL")
    // "full" algoritam
    log_write("id = nil full algoritam") 
    ZAP
elseif altoritam == "IDS"
    log_write("ids <> nil ids algoritam") 
    // "date" algoritam  - brisi sve vece od zadanog datuma
    SET ORDER TO TAG "ID"

    // pobrisimo sve id-ove koji su drugi izmijenili
    for each _tmp_id in _ids
          SEEK id
          if found()
               DELETE
          endif
    next

endif

@ _x + 4, _y + 2 SAY SECONDS() - _seconds 

_counter := 1
DO WHILE ! _qry_obj:Eof()
    append blank
    replace id with _qry_obj:FieldGet(1), ;
            naz with _qry_obj:FieldGet(2)
    
    _qry_obj:Skip()

    _counter++
    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
ENDDO

USE
_qry_obj:Destroy()

if (gDebug > 5)
    log_write("partn synchro cache:" + STR(SECONDS() - _seconds))
endif

close all
 
return .t. 
 
// ------------------------------------
// ------------------------------------
function konto_from_sql_server(algoritam)
local _counter
local _rec
local _qry
local _server := pg_server()
local _seconds
local _x, _y
local _tmp_id, _ids
local _sql_ids
local _i
local _qry_obj

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update konto: " + algoritam
_seconds := SECONDS()
_qry := "SELECT id,naz FROM fmk.konto"

if (algoritam == "IDS")
    _ids := get_ids_from_semaphore("konto")
    _sql_ids := "("
    for _i := 1 to LEN(_ids)
        _sql_ids += _sql_quote(_ids[_i])
        if _i < LEN(_ids)
           _sql_ids += ","
        endif
    next
    _sql_ids := ")"
    _qry += " WHERE ids IN " + _sql_ids
endif

_qry_obj := _server:Query(_qry)

if _qry_obj:NetErr()
   MsgBeep("ajoj :" + _qry_obj:ErrorMsg())
   QUIT
endif

SELECT F_KONTO
my_use ("konto", "konto", .f., "SEMAPHORE")

if (algoritam == "FULL")
    // "full" algoritam
    log_write("id = nil full algoritam") 
    ZAP
elseif altoritam == "IDS"
    log_write("ids <> nil ids algoritam") 
    // "date" algoritam  - brisi sve vece od zadanog datuma
    SET ORDER TO TAG "ID"

    // pobrisimo sve id-ove koji su drugi izmijenili
    for each _tmp_id in _ids
          SEEK id
          if found()
               DELETE
          endif
    next

endif

@ _x + 4, _y + 2 SAY SECONDS() - _seconds 

_counter := 1
DO WHILE ! _qry_obj:Eof()
    append blank
    replace id with _qry_obj:FieldGet(1), ;
            naz with _qry_obj:FieldGet(2)
    _qry_obj:Skip()

    _counter++
    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
ENDDO

USE
_qry_obj:Destroy()

if (gDebug > 5)
    log_write("konto synchro cache:" + STR(SECONDS() - _seconds))
endif

close all
 
return .t. 

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
