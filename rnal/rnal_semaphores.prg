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

if algoritam == "IDS"
    _offset := 1
    _step := 1
    _count := 1
endif

SELECT F_DOCS
my_usex ("docs", "rnal_docs", .f., "SEMAPHORE")

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

  if algoritam <> "IDS"
    _qry += " ORDER BY " + _order
    _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 
  endif

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
 
return


// ------------------------------
// koristi azur_sql
// ------------------------------
function rnal_doc_it_from_sql_server(algoritam)
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
local _order := "doc_no, doc_it_no"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.rnal_doc_it"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
    algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update rnal_doc_it: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

if algoritam == "IDS"
    _offset := 1
    _step := 1
    _count := 1
endif

SELECT F_DOC_IT
my_usex ("doc_it", "rnal_doc_it", .f., "SEMAPHORE")

_fields := { "doc_no", "doc_it_no", "art_id", "doc_it_wid", "doc_it_hei", "doc_it_qtt", "doc_it_alt", "doc_acity", "doc_it_sch", "doc_it_des", "doc_it_typ", "doc_it_w2", "doc_it_h2", "doc_it_pos", "it_lab_pos" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("rnal_doc_it")
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
            _qry += " (doc_no || doc_it_no ) IN " + _sql_ids
        endif

        _key_block := {|| STR( field->doc_no, 10 ) + STR( field->doc_it_no, 4 )  } 
  endif

  if algoritam <> "IDS"
    _qry += " ORDER BY " + _order
    _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 
  endif

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset==0)
        log_write( _tbl + " : synchro full algoritam") 
        ZAP
    
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
    log_write("doc_it synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_rnal_doc_it_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.rnal_doc_it"

if record <> nil
    _where := "doc_no=" + STR(record["doc_no"], 10) + " AND doc_it_no=" + STR(record["doc_it_no"], 4)
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
                "( doc_no, doc_it_no, art_id, doc_it_wid, doc_it_hei, doc_it_qtt, doc_it_alt, doc_acity, doc_it_sch, doc_it_des, doc_it_typ, doc_it_w2, doc_it_h2, doc_it_pos, it_lab_pos ) " + ;
               "VALUES(" + STR( record["doc_no"], 10 )  + "," +;
                            + STR( record["doc_it_no"], 4 ) + "," +; 
                            + STR( record["art_id"], 10 ) + "," +; 
                            + STR( record["doc_it_wid"], 15, 5 ) + "," +;
                            + STR( record["doc_it_hei"], 15, 5 ) + "," +;
                            + STR( record["doc_it_qtt"], 15, 5 ) + "," +;
                            + STR( record["doc_it_alt"], 15, 5 ) + "," +;
                            + _sql_quote( record["doc_acity"] ) + "," +;
                            + _sql_quote( record["doc_it_sch"] ) + "," +;
                            + _sql_quote( record["doc_it_des"] ) + "," +;
                            + _sql_quote( record["doc_it_typ"] ) + "," +;
                            + STR( record["doc_it_w2"], 15, 5 ) + "," +;
                            + STR( record["doc_it_h2"], 15, 5 ) + "," +;
                            + _sql_quote( record["doc_it_pos"] ) + "," + ;
                            + _sql_quote( record["it_lab_pos"] ) + " )"
                          
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
 
return


// ------------------------------
// koristi azur_sql
// ------------------------------
function rnal_doc_it2_from_sql_server(algoritam)
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
local _order := "doc_no, doc_it_no, it_no"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.rnal_doc_it2"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
    algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update rnal_doc_it2: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

if algoritam == "IDS"
    _offset := 1
    _step := 1
    _count := 1
endif

SELECT F_DOC_IT2
my_usex ("doc_it2", "rnal_doc_it2", .f., "SEMAPHORE")

_fields := { "doc_no", "doc_it_no", "it_no", "art_id", "doc_it_qtt", "doc_it_q2", "doc_it_pri", "sh_desc", "descr" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("rnal_doc_it2")
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
            _qry += " (doc_no || doc_it_no || it_no ) IN " + _sql_ids
        endif

        _key_block := {|| STR( field->doc_no, 10 ) + STR( field->doc_it_no, 4 ) + STR( field->it_no, 4 )  } 
  endif

  if algoritam <> "IDS"
    _qry += " ORDER BY " + _order
    _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 
  endif

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset==0)
        log_write( _tbl + " : synchro full algoritam") 
        ZAP
    
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
    log_write("doc_it2 synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_rnal_doc_it2_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.rnal_doc_it2"

if record <> nil
    _where := "doc_no=" + STR(record["doc_no"], 10) + " AND doc_it_no=" + STR(record["doc_it_no"], 4) + " AND it_no=" + STR( record["it_no"], 4 )
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
                "( doc_no, doc_it_no, it_no, art_id, doc_it_qtt, doc_it_q2, doc_it_pri, sh_desc, descr ) " + ;
               "VALUES(" + STR( record["doc_no"], 10 )  + "," +;
                            + STR( record["doc_it_no"], 4 ) + "," +; 
                            + STR( record["it_no"], 4 ) + "," +; 
                            + STR( record["art_id"], 10 ) + "," +; 
                            + STR( record["doc_it_qtt"], 15, 5 ) + "," +;
                            + STR( record["doc_it_q2"], 15, 5 ) + "," +;
                            + STR( record["doc_it_pri"], 15, 5 ) + "," +;
                            + _sql_quote( record["sh_desc"] ) + "," +;
                            + _sql_quote( record["descr"] ) + " )"
                          
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
 
return


// ------------------------------
// koristi azur_sql
// ------------------------------
function rnal_doc_log_from_sql_server(algoritam)
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
local _order := "doc_no, doc_log_no"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.rnal_doc_log"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
    algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update rnal_doc_log: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

if algoritam == "IDS"
    _count := 1
    _step := 1
    _offset := 1
endif

SELECT F_DOC_LOG
my_usex ("doc_log", "rnal_doc_log", .f., "SEMAPHORE")

_fields := { "doc_no", "doc_log_no", "doc_log_da", "doc_log_ti", "operater_i", "doc_log_ty", "doc_log_de" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("rnal_doc_log")
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
            _qry += " (doc_no || doc_log_no ) IN " + _sql_ids
        endif

        _key_block := {|| STR( field->doc_no, 10 ) + STR( field->doc_log_no, 10 ) } 
  endif

  if algoritam <> "IDS"
    _qry += " ORDER BY " + _order
    _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 
  endif

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset==0)
        log_write( _tbl + " : synchro full algoritam") 
        ZAP
    
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
    log_write("doc_log synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_rnal_doc_log_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.rnal_doc_log"

if record <> nil
    _where := "doc_no=" + STR(record["doc_no"], 10) + " AND doc_log_no=" + STR(record["doc_log_no"], 10 ) 
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
                "( doc_no, doc_log_no, doc_log_da, doc_log_ti, operater_i, doc_log_ty, doc_log_de ) " + ;
               "VALUES(" + STR( record["doc_no"], 10 )  + "," +;
                            + STR( record["doc_log_no"], 10 ) + "," +; 
                            + _sql_quote( record["doc_log_da"] ) + "," +;
                            + _sql_quote( record["doc_log_ti"] ) + "," +;
                            + STR( record["operater_i"], 3 ) + "," +; 
                            + _sql_quote( record["doc_log_ty"] ) + "," +;
                            + _sql_quote( record["doc_log_de"] ) + " )"
                          
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
 
return

// ------------------------------
// koristi azur_sql
// ------------------------------
function rnal_doc_lit_from_sql_server(algoritam)
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
local _order := "doc_no, doc_log_no, doc_lit_no"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.rnal_doc_lit"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
    algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update rnal_doc_lit: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

if algoritam == "IDS"
    _offset := 1
    _step := 1
    _count := 1
endif

SELECT F_DOC_LIT
my_usex ("doc_lit", "rnal_doc_lit", .f., "SEMAPHORE")

_fields := { "doc_no", "doc_log_no", "doc_lit_no", "doc_lit_ac", "art_id", "char_1", "char_2", "char_3", "num_1", "num_2", "num_3", "int_1", "int_2", "int_3", "int_4", "int_5", "date_1", "date_2", "date_3" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("rnal_doc_lit")
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
            _qry += " (doc_no || doc_log_no || doc_lit_no ) IN " + _sql_ids
        endif

        _key_block := {|| STR( field->doc_no, 10 ) + STR( field->doc_log_no, 10 ) + STR( field->doc_lit_no, 4 ) } 
  endif

  if algoritam <> "IDS"
    _qry += " ORDER BY " + _order
    _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 
  endif

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset==0)
        log_write( _tbl + " : synchro full algoritam") 
        ZAP
    
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
    log_write("doc_lit synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_rnal_doc_lit_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.rnal_doc_lit"

if record <> nil
    _where := "doc_no=" + STR(record["doc_no"], 10) + " AND doc_log_no=" + STR(record["doc_log_no"], 10 ) + " AND DOC_LIT_NO=" + STR(record["doc_lit_no"], 4)
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
                "( doc_no, doc_log_no, doc_lit_no, doc_lit_ac, art_id, char_1, char_2, char_3, num_1, num_2, num_3, int_1, int_2, int_3, int_4, int_5, date_1, date_2, date_3 ) " + ;
               "VALUES(" + STR( record["doc_no"], 10 )  + "," +;
                            + STR( record["doc_log_no"], 10 ) + "," +; 
                            + STR( record["doc_lit_no"], 4 ) + "," +; 
                            + _sql_quote( record["doc_lit_ac"] ) + "," +;
                            + STR( record["art_id"], 10 ) + "," +; 
                            + _sql_quote( record["char_1"] ) + "," +;
                            + _sql_quote( record["char_2"] ) + "," +;
                            + _sql_quote( record["char_3"] ) + "," +;
                            + STR( record["num_1"], 15, 5 ) + "," +; 
                            + STR( record["num_2"], 15, 5 ) + "," +; 
                            + STR( record["num_3"], 15, 5 ) + "," +; 
                            + STR( record["int_1"], 10, 0 ) + "," +; 
                            + STR( record["int_2"], 10, 0 ) + "," +; 
                            + STR( record["int_3"], 10, 0 ) + "," +; 
                            + STR( record["int_4"], 10, 0 ) + "," +; 
                            + STR( record["int_5"], 10, 0 ) + "," +; 
                            + _sql_quote( record["date_1"] ) + "," +;
                            + _sql_quote( record["date_2"] ) + "," +;
                            + _sql_quote( record["date_3"] ) + " )"
                          
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
 
return


// ------------------------------
// koristi azur_sql
// ------------------------------
function rnal_doc_ops_from_sql_server(algoritam)
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
local _order := "doc_no, doc_it_no, doc_it_el_, doc_op_no"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.rnal_doc_ops"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
    algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update rnal_doc_ops: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

if algoritam == "IDS"
    _step := 1
    _offset := 1
    _count := 1
endif

SELECT F_DOC_OPS
my_usex ("doc_ops", "rnal_doc_ops", .f., "SEMAPHORE")

_fields := { "doc_no", "doc_it_no", "doc_it_el_", "doc_op_no", "aop_id", "aop_att_id", "doc_op_des", "aop_value" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("rnal_doc_ops")
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
            _qry += " (doc_no || doc_it_no || doc_it_el_ || doc_op_no ) IN " + _sql_ids
        endif

        _key_block := {|| STR( field->doc_no, 10 ) + STR( field->doc_it_no, 4 ) + STR( field->doc_it_el_, 10 ) + STR( field->doc_op_no, 4 ) } 
  endif

  if algoritam <> "IDS"
    _qry += " ORDER BY " + _order
    _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 
  endif

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset==0)
        log_write( _tbl + " : synchro full algoritam") 
        ZAP
    
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
    log_write("doc_ops synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_rnal_doc_ops_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.rnal_doc_ops"

if record <> nil
    _where := "doc_no=" + STR(record["doc_no"], 10) + " AND doc_it_no=" + STR(record["doc_it_no"], 4 ) + " AND DOC_IT_EL_=" + STR(record["doc_it_el_"], 10 ) + " AND DOC_OP_NO=" + STR(record["doc_op_no"], 4)
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
                "( doc_no, doc_it_no, doc_it_el_, doc_op_no, aop_id, aop_att_id, doc_op_des, aop_value ) " + ;
               "VALUES(" + STR( record["doc_no"], 10 )  + "," +;
                            + STR( record["doc_it_no"], 4 ) + "," +; 
                            + STR( record["doc_it_el_"], 10 ) + "," +; 
                            + STR( record["doc_op_no"], 4 ) + "," +; 
                            + STR( record["aop_id"], 10 ) + "," +; 
                            + STR( record["aop_att_id"], 10 ) + "," +; 
                            + _sql_quote( record["doc_op_des"] ) + "," +;
                            + _sql_quote( record["aop_value"] ) + " )"
                          
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
 
return


// -----------------------------------------
// -----------------------------------------
function rnal_aops_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_aops"
local _index_tag := "1"
local _field_tag := "aop_id::char(10)"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_AOPS, { "aop_id", "aop_desc", "aop_full_d", "in_art_des", "aop_joker", "aop_unit", "match_code" }, _index_tag, _field_tag )

return _result


// -----------------------------------------
// -----------------------------------------
function rnal_aops_att_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_aops_att"
local _index_tag := "2"
local _field_tag := "aop_id::char(10) || aop_att_id::char(10)"


_result := sifrarnik_from_sql_server( _tbl, algoritam, F_AOPS_ATT, { "aop_att_id", "aop_id", "aop_att_de", "aop_att_fu", "aop_att_jo", "in_art_des", "match_code" }, _index_tag, _field_tag )

return _result



// -----------------------------------------
// -----------------------------------------
function rnal_articles_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_articles"
local _index_tag := "1"
local _field_tag := "art_id::char(10)"


_result := sifrarnik_from_sql_server( _tbl, algoritam, F_ARTICLES, { "art_id", "art_desc", "art_full_d", "art_lab_de", "match_code" }, _index_tag, _field_tag )

return _result



// -----------------------------------------
// -----------------------------------------
function rnal_elements_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_elements"
local _index_tag := "1"
local _field_tag := "art_id::char(10) || el_no::char(4) || el_id::char(10) || e_gr_id::char(10)"


_result := sifrarnik_from_sql_server( _tbl, algoritam, F_ELEMENTS, { "art_id", "el_no", "el_id", "e_gr_id" }, _index_tag, _field_tag )

return _result


// -----------------------------------------
// -----------------------------------------
function rnal_e_groups_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_e_groups"
local _index_tag := "1"
local _field_tag := "e_gr_id::char(10)"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_E_GROUPS, { "e_gr_id", "e_gr_desc", "e_gr_full_" }, _index_tag, _field_tag )

return _result


// -----------------------------------------
// -----------------------------------------
function rnal_e_gr_att_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_e_gr_att"
local _index_tag := "1"
local _field_tag := "e_gr_at_id::char(10) || e_gr_id::char(10)"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_E_GR_ATT, { "e_gr_at_id", "e_gr_id", "e_gr_at_de", "e_gr_at_re", "in_art_des", "e_gr_at_jo", "match_code" }, _index_tag, _field_tag )

return _result



// -----------------------------------------
// -----------------------------------------
function rnal_e_gr_val_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_e_gr_val"
local _index_tag := "1"
local _field_tag := "e_gr_vl_id::char(10) || e_gr_at_id::char(10)"


_result := sifrarnik_from_sql_server( _tbl, algoritam, F_E_GR_VAL, { "e_gr_vl_id", "e_gr_at_id", "e_gr_vl_de", "e_gr_vl_fu", "match_code" }, _index_tag, _field_tag )

return _result



// -----------------------------------------
// -----------------------------------------
function rnal_objects_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_objects"
local _index_tag := "1"
local _field_tag := "obj_id::char(10)"


_result := sifrarnik_from_sql_server( _tbl, algoritam, F_OBJECTS, { "obj_id", "cust_id", "obj_desc", "match_code" }, _index_tag, _field_tag )

return _result




// -----------------------------------------
// -----------------------------------------
function rnal_ral_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_ral"
local _index_tag := "1"
local _field_tag := "id::char(5), gl_tick::char(2)"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_RAL, { "id", "gl_tick", "descr", "en_desc", "col_1", "col_2", "col_3", "col_4", "colp_1", "colp_2", "colp_3", "colp_4" }, _index_tag, _field_tag )

return _result



// -----------------------------------------
// -----------------------------------------
function rnal_e_att_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_e_att"
local _index_tag := "1"
local _field_tag := "el_att_id::char(10) || el_id::char(10) || e_gr_at_id::char(10) || e_gr_vl_id::char(10)"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_E_ATT, { "el_att_id", "el_id", "e_gr_at_id", "e_gr_vl_id" }, _index_tag, _field_tag )

return _result



// -----------------------------------------
// -----------------------------------------
function rnal_e_aops_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_e_aops"
local _index_tag := "1"
local _field_tag := "el_op_id::char(10) || el_id::char(10) || aop_id::char(10) || aop_att_id::char(10)"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_E_AOPS, { "el_op_id", "el_id", "aop_id", "aop_att_id" }, _index_tag, _field_tag )

return _result



// -----------------------------------------
// -----------------------------------------
function rnal_customs_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_customs"
local _index_tag := "1"
local _field_tag := "cust_id::char(10)"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_CUSTOMS, { "cust_id", "cust_desc", "cust_addr", "cust_tel", "cust_ident", "match_code" }, _index_tag, _field_tag )

return _result


// -----------------------------------------
// -----------------------------------------
function rnal_contacts_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "rnal_contacts"
local _index_tag := "1"
local _field_tag := "cust_id::char(10) || cont_id::char(10)"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_CONTACTS, { "cont_id", "cust_id", "cont_desc", "cont_tel", "cont_add_d", "match_code" }, _index_tag, _field_tag )

return _result



