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


// ------------------------------
// fields := { "id, "naz" }
// => "id, naz"
//
function sql_fields(fields)
local  _i, _sql_fields := ""    

if fields == NIL
   return NIL
endif

for _i:=1 to LEN(fields)
   _sql_fields += fields[_i]
   if _i < LEN(fields)
      _sql_fields +=  ","
   endif
next

return _sql_fields

 

//-------------------------------------------------
// -------------------------------------------------
function sql_table_update(table, op, record, where_str )
local _i, _tmp, _tmp_2, _msg
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()
local _key
local _pos
local _dec
local _len
local _a_dbf_rec, _alg
local _dbf_fields, _sql_fields, _sql_order, _dbf_wa, _dbf_alias, _sql_tbl


if op $ "ins#del"

    if table == NIL
       table := ALIAS()
    endif

    _a_dbf_rec := get_a_dbf_rec(table)

    _dbf_fields := _a_dbf_rec["dbf_fields"]
    _sql_fields := sql_fields( _dbf_fields )

    _sql_order  := _a_dbf_rec["sql_order"]

    _dbf_wa    := _a_dbf_rec["wa"]
    _dbf_alias := _a_dbf_rec["alias"]

    _sql_tbl   := "fmk." + table

    // uvijek je algoritam 1 nivo recorda
    _alg := _a_dbf_rec["algoritam"][1]

    if where_str == NIL
        if record <> NIL
            where_str := sql_where_from_dbf_key_fields(_alg["dbf_key_fields"], record)
        endif
    endif

endif

log_write( "sql table update, poceo", 9 )

DO CASE

    CASE op == "BEGIN"
        _qry := "BEGIN"

    CASE (op == "END") .or. (op == "COMMIT")
        _qry := "COMMIT" 

    CASE op == "ROLLBACK"
        _qry := "ROLLBACK"

    CASE op == "del"

        if (where_str == NIL) .and. (record == NIL .or. (record["id"] == NIL))
            // brisi kompletnu tabel
            _msg := RECI_GDJE_SAM + " nedozvoljeno stanje, postavit eksplicitno where na 'true' !!"
            Alert(_msg)
            log_write( _msg, 2 )
            QUIT
        endif
        _qry := "DELETE FROM " + _sql_tbl + " WHERE " + where_str 
        
   CASE op == "ins"

        _qry := "INSERT INTO " + _sql_tbl +  "("  
        for _i := 1 to LEN(_a_dbf_rec["dbf_fields"])

            _qry += _a_dbf_rec["dbf_fields"][_i]

            if _i < LEN(_a_dbf_rec["dbf_fields"])
                _qry += ","
            endif

        next

        _qry += ")  VALUES (" 
        for _i := 1 to LEN(_a_dbf_rec["dbf_fields"])

            _tmp := _a_dbf_rec["dbf_fields"][_i]

            if !HB_HHASKEY(record, _tmp)
                   _msg := "record " + op + " ne sadrzi " + _tmp + " field !?## pogledaj log !"
                   log_write(_msg + " " + pp(record), 2)
                   MsgBeep(_msg)
                   RaiseError(_msg + " " + pp(record) )
            endif

            if VALTYPE(record[_tmp]) == "N"

                   _tmp_2 := STR(record[_tmp], _a_dbf_rec["dbf_fields_len"][_tmp][2], _a_dbf_rec["dbf_fields_len"][_tmp][3])
                   

                   if LEFT(_tmp_2, 1) == "*"
                      _msg := "err_num_width - field: " + _tmp + "  value:" + ALLTRIM(STR(record[_tmp])) + " / width: " +  ALLTRIM(STR(_a_dbf_rec["dbf_fields_len"][_tmp][2])) + " : " +  ALLTRIM(STR(_a_dbf_rec["dbf_fields_len"][_tmp][3]))
                      log_write( _msg, 2 )
                      RaiseError(_msg)
                   else
                      _qry += _tmp_2
                   endif
            else
                _qry += _sql_quote(record[_tmp])
            endif

            if _i < LEN(_a_dbf_rec["dbf_fields"])
                _qry += ","
            endif

        next
        
        _qry += ")"

END CASE
   
_ret := _sql_query( _server, _qry)

log_write( "sql table update, table: " + IF(table == NIL, "NIL", table ) + ", op: " + op + ", qry: " + _qry, 8 )
log_write( "sql table update, VALTYPE(_ret): " + VALTYPE(_ret), 9 )
log_write( "sql table update, zavrsio", 9 )

if VALTYPE(_ret) == "L"
    // u slucaju ERROR-a _sql_query vraca  .f.
    return _ret
else
    return .t.
endif


// ----------------------------------------
// ----------------------------------------
function run_sql_query(qry, retry) 
local _i, _qry_obj

local _server := my_server()

if retry == NIL
  retry := 1
endif

if VALTYPE(qry) != "C"
    _msg := "qry ne valja VALTYPE(qry) =" + VALTYPE(qry)
    log_write( _msg, 2 )
    MsgBeep(_msg)
    quit
endif

log_write( "QRY OK: run_sql_query: " + qry, 9 )

for _i := 1 to retry

    begin sequence with {|err| Break(err)}
        _qry_obj := _server:Query(qry + ";")
    recove
        log_write( "run_sql_query(), ajoj ajoj: qry ne radi !?!", 2 )
        my_server_logout()
        hb_IdleSleep(0.5)
        if my_server_login()
            _server := my_server()
        endif
    end sequence

    if _qry_obj:NetErr()

        log_write( "run_sql_query(), ajoj: " + _qry_obj:ErrorMsg(), 2 )
        log_write( "run_sql_query(), error na sljedecem upitu: " + qry, 2 )

        my_server_logout()
        hb_IdleSleep(0.5)

        if my_server_login()
            _server := my_server()
        endif

        if _i == retry
            MsgBeep("neuspjesno nakon " + to_str(retry) + "pokusaja !?")
            QUIT
        endif
    else
        _i := retry + 1
    endif
next

return _qry_obj



// pomoćna funkcija za sql query izvršavanje
function _sql_query( oServer, cQuery )
local oResult, cMsg

oResult := oServer:Query( cQuery + ";")

IF oResult:NetErr()

      cMsg := oResult:ErrorMsg()
      log_write("ERROR: _sql_query: " + cQuery + "err msg:" + cMsg, 3 )
      MsgBeep( cMsg )
      return .f.

ELSE

      log_write("QRY OK: _sql_query: " + cQuery, 9 )

ENDIF

RETURN oResult


// -------------------------------------
// setovanje sql schema path-a
// -----------------------------------
function set_sql_search_path()
local _server := my_server()
local _path := my_server_search_path()

local _qry := "SET search_path TO " + _path + ";"
local _result
local _msg

_result := _server:Query( _qry )
IF _result:NetErr()
    _msg := _result:ErrorMsg()
    log_write( _qry, 2 )
    log_write( _msg, 2 )
    MsgBeep( _msg )
    return .f.
ELSE
    log_write( "sql() set search path ok", 9 )
ENDIF

RETURN _result


// ------------------------
// ------------------------
function _sql_quote(xVar)
local cOut

if VALTYPE(xVar) == "C"
    cOut := STRTRAN(xVar, "'","''")
    cOut := "'" + hb_strtoutf8(cOut) + "'"
elseif VALTYPE(xVar) == "D"
    if xVar == CTOD("")
            cOut := "NULL"
    else
            cOut:=DTOS(xVar)
            if EMPTY(cOut)
                cPom:=replicate('0',8)
            endif
            //1234-56-78
            cOut := "'" + substr(cOut, 1, 4) + "-" + substr(cOut, 5, 2) + "-" + substr(cOut, 7, 2) + "'"
    endif
else
    cOut := "NULL"
endif

return cOut

// ---------------------------------------
// ---------------------------------------
function sql_where_from_dbf_key_fields(dbf_key_fields, rec)
local _ret, _pos, _item, _key

// npr dbf_key_fields := {{"godina", 4}, "idrj", {"mjesec", 2}, "obr", "idradn" }
_ret := ""
for each _item in dbf_key_fields

   if !EMPTY(_ret)
       _ret += " AND "
   endif

   if VALTYPE(_item) == "A"
      // numeric
      _key := LOWER(_item[1])
      check_hash_key(rec, _key)              
      _ret += _item[1] + "=" + STR(rec[_key], _item[2])

   elseif VALTYPE(_item) == "C"
      _key := LOWER(_item)
      check_hash_key(rec, _key)              
      _ret += _item + "=" + _sql_quote(rec[_key])
 
   else
       MsgBeep(PROCNAME(1) + "valtype _item ?!")
       QUIT
   endif

next

return _ret



// ---------------------------------------
// hernad izbaciti iz upotrebe !
// koristiti gornju funkciju
// ---------------------------------------
function sql_where_block(table_name, x)
local _ret, _pos, _fields, _item, _key

_pos := ASCAN(gaDBFS, {|x| x[3] == table_name })

if _pos == 0
   MsgBeep(PROCLINE(1) + "sql_where_block tbl ne postoji" + table_name)
   log_write("ERR sql_where: " + table_name)
   QUIT
endif

// npr. _fields := {{"godina", 4}, "idrj", {"mjesec", 2}, "obr", "idradn" }
_fields := gaDBFS[_pos, 6]

_ret := ""
for each _item in _fields

   if !EMPTY(_ret)
       _ret += " AND "
   endif

   if VALTYPE(_item) == "A"
      // numeric
      _key := LOWER(_item[1])
      _ret += _item[1] + "=" + STR(x[_key], _item[2])

   elseif VALTYPE(_item) == "C"
      _key := LOWER(_item)
      _ret += _item + "=" + _sql_quote(x[_key])
 
   else
       MsgBeep(PROCNAME(1) + "valtype _item ?!")
       QUIT
   endif

next

return _ret

// ---------------------------------------
// ---------------------------------------
function sql_concat_ids(table_name)
local _ret, _pos, _fields, _item

_pos := ASCAN(gaDBFS, {|x| x[3] == table_name })

if _pos == 0
   MsgBeep(PROCLINE(1) + "sql tbl ne postoji in gaDBFs " + table_name)
   QUIT
endif

// npr. _fields := {{"godina", 4}, "idrj", {"mjesec", 2}, "obr", "idradn" }
_fields := gaDBFS[_pos, 6]

_ret := ""

for each _item in _fields

   if !EMPTY(_ret)
       _ret += " || "
   endif

   if VALTYPE(_item) == "A"
      // numeric
      // to_char(godina, '9999') 
      _ret += "to_char(" + _item[1] + ",'" + REPLICATE("9", _item[2]) + "')"

   elseif VALTYPE(_item) == "C"
      _ret += _item
 
   else
       MsgBeep(PROCNAME(1) + "valtype _item ?!")
       QUIT
   endif

next

return _ret

// ---------------------------------------
// ---------------------------------------
function sql_primary_key(table_name)
local _ret, _pos, _fields, _i, _item

_pos := ASCAN(gaDBFS, {|x| x[3] == LOWER(table_name) })

if _pos == 0
   MsgBeep(PROCLINE(1) + "sql tbl ne postoji in gaDBFs " + table_name)
   QUIT
endif

// npr. _fields := {{"godina", 4}, "idrj", {"mjesec", 2}, "obr", "idradn" }
_fields := gaDBFS[_pos, 6]

_ret := "(org_id, b_year, b_seasson"

for each _item in _fields

   _ret += ", "
   if VALTYPE(_item) == "A"
      // numericko polje
      _ret += _item[1]

   elseif VALTYPE(_item) == "C"
      _ret += _item
 
   else
       MsgBeep(PROCNAME(1) + " valtype _item ?!")
       QUIT
   endif

next

_ret += ")"

return _ret


// -----------------------------------------------------
// parsiranje datuma u sql izrazu
// -----------------------------------------------------
function _sql_date_parse( field_name, date1, date2 )
local _ret := ""

// datdok BETWEEN '2012-02-01' AND '2012-05-01'

// dva su datuma
if PCOUNT() > 2

    // oba su prazna
    if DTOC(date1) == DTOC(CTOD("")) .and. DTOC(date2) == DTOC(CTOD(""))
        _ret := ""
    // samo prvi je prazan
    elseif DTOC(date1) == DTOC(CTOD(""))
        _ret := field_name + " <= " + _sql_quote( date2 )

    // imamo dva regularna datuma
    else
        _ret := field_name + " BETWEEN " + _sql_quote( date1 ) + " AND " + _sql_quote( date2 )
    endif

// imamo samo jedan uslov, field_name ili nista
elseif PCOUNT() <= 1
    _ret := ""    

// pcount() je 2
else

    // samo jedan datumski uslov
    _ret := field_name + " BETWEEN " + _sql_quote( date1 ) + " AND " + _sql_quote( date1 )

endif

return _ret


// ---------------------------------------------------
// sql parsiranje uslova sa ;
// ---------------------------------------------------
function _sql_cond_parse( field_name, cond )
local _ret := ""
local cond_arr := TokToNiz( cond, ";" ) 
local _i, _cond

// idkonto LIKE '211%' AND idkonto LIKE '5411%'

for each _cond in cond_arr

    _ret += " AND " + field_name 

    if LEN( cond_arr ) > 1
        _ret += " LIKE " + _sql_quote( ALLTRIM( _cond ) + "%" )
    else
        _ret += " = " + _sql_quote( _cond )
    endif

next

// skini mi prvi AND iz uslova !
_ret := RIGHT( _ret, LEN( _ret ) - 5 )

return _ret


// ------------------------------------------------------
// vraca vrijednost polja po zadatom uslovu
//
//  _sql_get_value( "partn", "naz", { "id", "1AL001" } )
// ------------------------------------------------------
function _sql_get_value( table_name, field_name, cond )
local _val 
local _qry := ""
local _table
local _server := pg_server()
local _data := {}
local _i, oRow

_qry += "SELECT " + field_name + " FROM fmk." + table_name 
_qry += " WHERE " + cond[1] + " = " + _sql_quote( cond[2] )

_table := _sql_query( _server, _qry )
_table:Refresh()

oRow := _table:GetRow( 1 )

_val := oRow:FieldGet( oRow:FieldPos( field_name ))

// ako nema polja vraca NIL
if VALTYPE( _val ) == "L"
    _val := NIL
endif

return _val





