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
function sql_table_update( table, op, record, where_str, silent )
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

if silent == NIL
    silent := .f.
endif

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

log_write( "sql table update, poceo", 9, silent )

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
            log_write( _msg, 2, silent )
            QUIT_1
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
   
_ret := _sql_query( _server, _qry, silent )

log_write( "sql table update, table: " + IF(table == NIL, "NIL", table ) + ", op: " + op + ", qry: " + _qry, 8, silent )
log_write( "sql table update, VALTYPE(_ret): " + VALTYPE(_ret), 9, silent )
log_write( "sql table update, zavrsio", 9, silent )

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
    quit_1
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
            QUIT_1
        endif
    else
        _i := retry + 1
    endif
next

return _qry_obj



// pomoćna funkcija za sql query izvršavanje
function _sql_query( oServer, cQuery, silent )
local oResult, cMsg

if silent == NIL
    silent := .f.
endif

#ifdef NODE
   log_write(cQuery, 1)
#endif

oResult := oServer:Query( cQuery + ";")

IF oResult:NetErr()

    cMsg := oResult:ErrorMsg()

    log_write("ERROR: _sql_query: " + cQuery + "err msg:" + cMsg, 1, silent )

    if !silent 
        MsgBeep( cMsg )
    endif
    
    return .f.

ELSE

    log_write("QRY OK: _sql_query: " + cQuery, 9, silent )

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


// ----------------------------------------
// sql date
// ----------------------------------------
function _sql_date_str( var )
local _out            
_out := DTOS( var )
//1234-56-78
_out := substr( _out, 1, 4) + "-" + substr( _out, 5, 2) + "-" + substr( _out, 7, 2) 
return _out


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
        cOut := "'" + _sql_date_str( xVar ) + "'"
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
       QUIT_1
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
   QUIT_1
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
       QUIT_1
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
   QUIT_1
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
       QUIT_1
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
   QUIT_1
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
       QUIT_1
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
        _ret := "TRUE"
    // samo prvi je prazan
    elseif DTOC(date1) == DTOC(CTOD(""))
        _ret := field_name + " <= " + _sql_quote( date2 )
    // drugi je prazan
    elseif DTOC(date2) == DTOC(CTOD(""))
        _ret := field_name + " >= " + _sql_quote( date1 )
    // imamo dva regularna datuma
    else
        // ako su razliciti datumi
        if DTOC(date1) <> DTOC(date2)
            _ret := field_name + " BETWEEN " + _sql_quote( date1 ) + " AND " + _sql_quote( date2 )
        // ako su identicni, samo nam jedan treba u LIKE klauzuli
        else
            _ret := field_name + "::char(20) LIKE " + _sql_quote( _sql_date_str( date1 ) + "%" )
        endif
    endif

// imamo samo jedan uslov, field_name ili nista
elseif PCOUNT() <= 1
    _ret := "TRUE"    

// samo jedan datumski uslov
else
    _ret := field_name + "::char(20) LIKE " + _sql_quote( _sql_date_str( date1 ) + "%" )
endif

return _ret


// ---------------------------------------------------
// sql parsiranje uslova sa ;
// ---------------------------------------------------
function _sql_cond_parse( field_name, cond, not )
local _ret := ""
local cond_arr := TokToNiz( cond, ";" ) 
local _i, _cond

if not == NIL
    not := .f.
endif

// idkonto LIKE '211%' AND idkonto LIKE '5411%'

for each _cond in cond_arr

    // prazan uslov... preskacem
    if EMPTY( _cond )
        loop
    endif

    _ret += "  OR " + field_name 

    if LEN( cond_arr ) > 1
        // ubaci NOT po potrebi...
        if not
            _ret += " NOT "
        endif

        _ret += " LIKE " + _sql_quote( ALLTRIM( _cond ) + "%" )

    else

        if not
            _ret += " <> "
        else
            _ret += " = "
        endif

        _ret += _sql_quote( _cond )

    endif

next

// skini mi prvi OR iz uslova !
_ret := RIGHT( _ret, LEN( _ret ) - 5 )

return _ret


// --------------------------------------------------------------------
// vraca sve zapise iz tabele po zadatom uslovu
// --------------------------------------------------------------------
function _select_all_from_table( table, fields, where_cond, order_fields )
local _srv := my_server()
local _qry, _data, _i, _n, _o

_qry := "SELECT "

if fields == NIL
    _qry += " * "
else
    for _i := 1 to LEN( fields )
        _qry += fields[ _i ]
        if _i < LEN( fields )
            _qry += ","
        endif
    next
endif

_qry += " FROM " + table

if where_cond <> NIL

    _qry += " WHERE "

    for _n := 1 to LEN( where_cond )
        _qry += where_cond[ _n ]
        if _n < LEN( where_cond )
            _qry += " AND "
        endif    
    next

endif

if order_fields <> NIL

    _qry += " ORDER BY "

    for _o := 1 to LEN( order_fields )
        _qry += order_fields[ _o ]
        if _o < LEN( order_fields )
            _qry += ","
        endif
    next

endif

_data := _sql_query( _srv, _qry )

if VALTYPE( _data ) == "L"
    _data := NIL
endif

return _data



// ------------------------------------------------------
// vraca vrijednost polja po zadatom uslovu
//
//  _sql_get_value( "partn", "naz", { { "id", "1AL001" }, { ... } } )
// ------------------------------------------------------
function _sql_get_value( table_name, field_name, cond )
local _val 
local _qry := ""
local _table
local _server := pg_server()
local _where := ""
local _data := {}
local _i, oRow

if cond == NIL
    cond := {}
endif

if ! ( "." $ table_name )
    table_name := "fmk." + table_name
endif

_qry += "SELECT " + field_name + " FROM " + table_name 

for _i := 1 to LEN( cond )

    if cond[ _i ] <> NIL

        if !EMPTY( _where )
            _where += " AND "
        endif

        if VALTYPE( cond[ _i, 2 ] ) == "N"
            _where += cond[ _i, 1 ] + " = " + STR( cond[ _i, 2 ] )
        else
            _where += cond[ _i, 1 ] + " = " + _sql_quote( cond[ _i, 2 ] )
        endif

    endif

next

if !EMPTY( _where )
    _qry += " WHERE " + _where
endif

_table := _sql_query( _server, _qry )
_table:Refresh()

oRow := _table:GetRow(1)
_val := oRow:FieldGet(1)

// ako nema polja vraca NIL
if VALTYPE( _val ) == "L"
    _val := NIL
endif

if VALTYPE( _val ) == "C"
    _val := hb_utf8tostr( _val )
endif

return _val



// -----------------------------------------------------
// vraca serverski datum 
// -----------------------------------------------------
function _sql_server_date()
local _date
local _pg_server := my_server()
local _qry := "SELECT CURRENT_DATE;"
local _res

_res := _sql_query( _pg_server, _qry )

if VALTYPE( _res ) <> "L"
    _date := _res:FieldGet(1)
else
    _date := NIL
endif

return _date



// -----------------------------------------------------
// vraca strukturu tabele sa servera
// ... klasicno vraca matricu kao ASTRUCT()
// -----------------------------------------------------
function _sql_table_struct( table )
local _struct := {}
local _server := my_server()
local _qry 
local _i
local _data
local _field_name, _field_type, _field_len, _field_dec
local _field_type_short

_qry := "SELECT column_name, data_type, character_maximum_length, numeric_precision, numeric_scale " + ;
        " FROM information_schema.columns " + ;
        " WHERE ( table_schema || '.' || table_name ) = " + _sql_quote( table ) + ;
        " ORDER BY ordinal_position;"

_data := _sql_query( _server, _qry )
_data:refresh()
_data:goto(1)

do while !_data:EOF()

    oRow := _data:GetRow()

    _field_name := oRow:FieldGet( 1 )
    _field_type := oRow:FieldGet( 2 )

    do case

        case "character" $ _field_type

            _field_type_short := "C"
            _field_len := oRow:FieldGet( 3 )
            _field_dec := 0

        case _field_type == "numeric"

            _field_type_short := "N"
            _field_len := oRow:FieldGet( 4 )
            _field_dec := oRow:FieldGet( 5 )

        case _field_type == "text"

            _field_type_short := "M"
            _field_len := 1000
            _field_dec := 0

        case _field_type == "date"

            _field_type_short := "D"
            _field_len := 8
            _field_dec := 0

    endcase

    AADD( _struct, { _field_name, _field_type_short, _field_len, _field_dec } )

    _data:Skip()

enddo

return _struct




// --------------------------------------------------------------------
// sql update 
// --------------------------------------------------------------------
function sql_update_table_from_hash( table, op, hash, where_fields )
local _qry 
local _server := my_server()
local _result

do case
    case op == "ins"
        _qry := _create_insert_qry_from_hash( table, hash )
    case op == "upd"
        _qry := _create_update_qry_from_hash( table, hash, where_fields )
endcase

// odradi qry
_sql_query( _server, "BEGIN;" )

// odradi upit
_result := _sql_query( _server, _qry )

// obradi gresku !
if VALTYPE( _result ) == "L"
    _sql_query( _server, "ROLLBACK;" )
else
    _sql_query( _server, "COMMIT;" )
endif

return _result



// --------------------------------------------------------------------
// kreira insert qry iz hash tabele
// --------------------------------------------------------------------
static function _create_insert_qry_from_hash( table, hash )
local _qry, _key

_qry := "WITH tmp AS ( "
_qry += "INSERT INTO " + table
_qry += " ( "

for each _key in hash:keys
    _qry += _key + ","
next

_qry := PADR( _qry, LEN( _qry ) - 1 )

_qry += " ) VALUES ( "

for each _key in hash:keys

    if VALTYPE( hash[ _key ] ) == "N"
        _qry += STR( hash[ _key ] )
    else
        _qry += _sql_quote( hash[ _key ] )
    endif

    _qry += ","

next

_qry := PADR( _qry, LEN( _qry ) - 1 )

_qry += " ) "

_qry += " RETURNING "

for each _key in hash:keys
    _qry += _key + ","
next

_qry := PADR( _qry, LEN( _qry ) - 1 )

_qry += " ) "
_qry += " SELECT * FROM tmp;"

return _qry


// --------------------------------------------------------------------
// kreira update qry iz hash tabele
// --------------------------------------------------------------------
static function _create_update_qry_from_hash( table, hash, where_key_fields )
local _qry, _key 
local _i

_qry := "WITH tmp AS ( "

_qry += "UPDATE " + table
_qry += " SET "

for each _key in hash:keys
    if VALTYPE( hash[ _key ] ) == "N"
        _qry += _key + " = " + STR( hash[ _key ] )
    else
        _qry += _key + " = " + _sql_quote( hash[ _key ] )
    endif

    _qry += ","
next

// ukini zarez
_qry := PADR( _qry, LEN( _qry ) - 1 )

_qry += " WHERE "

for _i := 1 to LEN( where_key_fields )
    if _i > 1
        _qry += " AND "
    endif
    
    if VALTYPE( hash[ where_key_fields[ _i ] ] ) == "N" 
        _qry += where_key_fields[ _i ] + " = " + STR( hash[ where_key_fields[ _i ] ] )
    else
        _qry += where_key_fields[ _i ] + " = " + _sql_quote( hash[ where_key_fields[ _i ] ] )
    endif

next

_qry += " RETURNING "

for each _key in hash:keys
    _qry += _key + ","
next

_qry := PADR( _qry, LEN( _qry ) - 1 )

_qry += " ) "
_qry += " SELECT * FROM tmp;"

return _qry



