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


#include "rnal.ch"
#include "common.ch"

// ------------------------------
// koristi azur_sql
// ------------------------------
function rnal_docs_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "doc_no"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.rnal_docs"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
    algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update rnal_docs: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_DOCS
my_usex ("rnal_docs", "docs", .f., "SEMAPHORE")

_fields := { "doc_no", "doc_date", "doc_dvr_da", "doc_dvr_ti", "doc_ship_p", "cust_id", "cont_id", "cont_add_d", "doc_pay_id", "doc_paid", "doc_pay_de", "doc_priori", ;
    "doc_desc", "doc_status", "operater_i", "doc_sh_des", "doc_time", "doc_in_fmk", "obj_id", "fmk_doc", "doc_llog" }


_sql_fields := sql_fields(_fields)

 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("rnal_docs")
    _qry += " WHERE doc_date >= " + _sql_quote(_dat)
    _key_block := {|| field->doc_date }
  endif

  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("rnal_docs")
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
            _qry += " (doc_no) IN " + _sql_ids
        endif

        _key_block := {|| field->doc_no } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset==0)
        log_write( _tbl + " : synchro full algoritam") 
        ZAP

    CASE algoritam == "DATE"

        log_write("doc_date <> nil date algoritam") 
        // "date" algoritam  - brisi sve vece od zadanog datuma
        SET ORDER TO TAG "D1"
        // tag je "DatDok" nije DTOS(DatDok)
        seek _dat
        do while !eof() .and. eval(_key_block)  >= _dat 
            // otidji korak naprijed
            SKIP
            _rec := RECNO()
            SKIP -1
            DELETE
            GO _rec  
        enddo

    CASE algoritam == "IDS"
        
        // "1", "doc_no"
        SET ORDER TO TAG "1"

        do while .t.
            _fnd := .f.
            for each _tmp_id in _ids
                
                HSEEK _tmp_id
                
                do while !EOF() .and. EVAL(_key_block) == _tmp_id
                    skip
                    _rec := RECNO()
                    skip -1 
                    DELETE
                    go _rec 
                    _fnd := .t.
                enddo
            next
            if ! _fnd 
                exit
            endif
        enddo

  ENDCASE

  // sada je sve izbrisano u lokalnom dbf-u

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

  _counter := 1

  DO WHILE !_qry_obj:Eof()
    
    append blank
        
    for _i := 1 to LEN(_fields)
          _fld := FIELDBLOCK(_fields[_i])
          if VALTYPE(EVAL(_fld)) $ "CM"
              EVAL(_fld, hb_Utf8ToStr(_qry_obj:FieldGet(_i)))
          else
              EVAL(_fld, _qry_obj:FieldGet(_i))
          endif
    next

    _qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO

next

USE

if (gDebug > 5)
    log_write("doc_no synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_rnal_docs_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.rnal_docs"

if record <> nil
    _where := "doc_no=" + STR(record["doc_no"], 10) 
endif

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
                "( doc_no, doc_date, doc_dvr_da, doc_dvr_ti, doc_ship_p, cust_id, cont_id, cont_add_d, doc_pay_id, doc_paid, doc_pay_de, doc_priori, " + ;
                "doc_desc, doc_status, operater_i, doc_sh_des, doc_time, doc_in_fmk, obj_id, fmk_doc, doc_llog ) " + ;
               "VALUES(" + STR( record["doc_no"], 10 )  + "," +;
                            + _sql_quote( record["doc_date"] ) + "," +; 
                            + _sql_quote( record["doc_dvr_da"] ) + "," +; 
                            + _sql_quote( record["doc_dvr_ti"] ) + "," +;
                            + _sql_quote( record["doc_ship_p"] ) + "," +;
                            + STR( record["cust_id"], 10 ) + "," +;
                            + STR( record["cont_id"], 10 ) + "," +;
                            + _sql_quote( record["cont_add_d"] ) + "," +;
                            + STR( record["doc_pay_id"], 4 ) + "," +;
                            + _sql_quote( record["doc_paid"] ) + "," +;
                            + _sql_quote( record["doc_pay_de"] ) + "," +;
                            + STR( record["doc_priori"], 4, 0 ) + "," +;
                            + _sql_quote( record["doc_desc"] ) + "," +;
                            + STR( record["doc_status"], 2, 0 ) + "," +;
                            + STR( record["operater_i"], 3, 0 ) + "," +;
                            + _sql_quote( record["doc_sh_des"] ) + "," +;
                            + _sql_quote( record["doc_time"] ) + "," +;
                            + _sql_quote( record["doc_in_fmk"] ) + "," +;
                            + STR( record["obj_id"], 10, 0 ) + "," +;
                            + _sql_quote( record["fmk_doc"] ) + "," +;
                            + STR( record["doc_llog"], 10, 0 ) + " )"
                          
ENDCASE
   
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
 

