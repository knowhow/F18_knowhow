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

#include "fmk.ch"


// ---------------------------------------------------------
// napuni tablu sa servera
// ---------------------------------------------------------
function full_synchro(dbf_table, step_size)
local _seconds
local _count
local _offset
local _qry
local _sql_table, _sql_fields
local _a_dbf_rec
local _sql_order
local _opened

if step_size == NIL
  step_size := 15000
endif

_sql_table  := "fmk." + dbf_table
_a_dbf_rec  := get_a_dbf_rec(dbf_table) 
_sql_fields := sql_fields(_a_dbf_rec["dbf_fields"])
_sql_order  := _a_dbf_rec["sql_order"]

altd()
reopen_exclusive(_a_dbf_rec["table"])

Box(, 5, 70)

@ m_x + 1, m_y + 2 SAY "full synchro: " + _sql_table + " => " + dbf_table

_count := table_count( _sql_table, "true" ) 
_seconds := SECONDS()

ZAP

if _sql_fields == NIL
   MsgBeep("sql_fields za " + _sql_table + " nije setovan ... sinhro nije moguć")
   QUIT
endif

@ m_x + 3, m_y + 2 SAY _count

for _offset := 0 to _count STEP step_size

  _qry :=  "SELECT " + _sql_fields + " FROM " +	_sql_table
 
  _qry += " ORDER BY " + _sql_order
  _qry += " LIMIT " + STR(step_size) + " OFFSET " + STR(_offset) 

  fill_dbf_from_server(dbf_table, _qry)

  @ m_x + 4, m_y + 2 SAY _offset
  @ row(), col() + 2 SAY "/"
  @ row(), col() + 2 SAY _count
next

BoxC()

//close all

return .t.



