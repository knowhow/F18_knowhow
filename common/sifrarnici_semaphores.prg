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

// -----------------------------------------
// -----------------------------------------
function partn_from_sql_server(algoritam)

return sifrarnik_from_sql_server("partn", algoritam, F_PARTN, {"id", "naz"})


// -----------------------------------------
// -----------------------------------------
function konto_from_sql_server(algoritam)

return sifrarnik_from_sql_server("konto", algoritam, F_PARTN, {"id", "naz"})


// ----------------------------------------
// ----------------------------------------
function sifrarnik_from_sql_server(table, algoritam, area, fields)
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
local _field_b
local _fnd


_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update " + table + " : " + algoritam
_seconds := SECONDS()
_qry :=  "SELECT " 

for _i := 1 to LEN(fields)
  _qry += fields[_i]
  if _i < LEN(fields)
      _qry += ","
  endif
next
_qry += " FROM fmk." + table

if (algoritam == "IDS") 
    _ids := get_ids_from_semaphore(table)

    _qry += " WHERE "
    if LEN(_ids) < 1
       // nema id-ova
       _qry += "false"
    else
        _sql_ids := "("
        for _i := 1 to LEN(_ids)
            _sql_ids += _sql_quote(_ids[_i])
            if _i < LEN(_ids)
            _sql_ids += ","
            endif
        next
        _sql_ids += ")"
        _qry += " ID IN " + _sql_ids
     endif
endif

_qry_obj := _server:Query(_qry) 
if _qry_obj:NetErr()
   MsgBeep("ajoj :" + _qry_obj:ErrorMsg())
   QUIT
endif

SELECT (area)

my_use (table, NIL, .f., "SEMAPHORE", algoritam)

if (algoritam == "FULL")
    // "full" algoritam
    log_write("id = nil full algoritam") 
    ZAP
elseif algoritam == "IDS"
    log_write("ids <> nil ids algoritam") 
    // "date" algoritam  - brisi sve vece od zadanog datuma
    SET ORDER TO TAG "ID"

    // pobrisimo sve id-ove koji su drugi izmijenili
    do while .t.
       _fnd := .f.
       for each _tmp_id in _ids
          HSEEK _tmp_id
          if found()
               _fnd := .t.
               DELETE
          endif
        next
        if ! _fnd ; exit ; endif
    enddo
endif

@ _x + 4, _y + 2 SAY SECONDS() - _seconds 

_counter := 1
DO WHILE ! _qry_obj:Eof()
    append blank
    for _i:=1 to LEN(fields)
       _field_b := FIELDBLOCK( fields[_i])
       // replace dbf field
       EVAL(_field_b, _qry_obj:FieldGet(_i)) 
    next
    _qry_obj:Skip()

    _counter++
    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
ENDDO

USE
_qry_obj:Destroy()

if (gDebug > 5)
    log_write(table + "synchro cache:" + STR(SECONDS() - _seconds))
endif

close all
 
return .t. 
