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
#include "common.ch"

thread static __my_use_semaphore := .t.

// --------------------------------------
// iskljuci logiku provjere semafora
// neophodno u procedurama azuriranja
// 
// if azur_sql()
//       my_use_semaphore_off()
//       otvori_dbfs()
//       azur_dbf()
//       my_use_semaphore_on()
// endif
//
// --------------------------------------
function my_use_semaphore_off()
__my_use_semaphore := .f.
return

function my_use_semaphore_on()
__my_use_semaphore := .t.
return

function my_use_semaphore()
return __my_use_semaphore


// --------------------------------------------------------------
// --------------------------------------------------------------
function my_usex(alias, table, new_area, _rdd, semaphore_param)

return my_use(alias, table, new_area, _rdd, semaphore_param, .t.)


// ----------------------------------------------------------------
// semaphore_param se prosjedjuje eval funkciji ..from_sql_server
// ----------------------------------------------------------------
function my_use(alias, table, new_area, _rdd, semaphore_param, excl)
local _msg
local _err
local _pos
local _version, _last_version
local _area

if new_area == NIL
   new_area := .f.
endif

if excl == NIL
  excl := .f.
endif

if table == NIL
  _a_dbf_rec := get_a_dbf_rec(alias)
else
  _a_dbf_rec := get_a_dbf_rec(table)
endif

table := _a_dbf_rec["table"]
alias := _a_dbf_rec["alias"]

if valtype(table) != "C"
   _msg := PROCNAME(2) + "(" + ALLTRIM(STR(PROCLINE(2))) + ") table name VALTYPE = " + VALTYPE(type)
   Alert(_msg)
   log_write(_msg)
   QUIT
endif



if _rdd == NIL
  _rdd = "DBFCDX"
endif

if !_a_dbf_rec["temp"] 


   // tabela je pokrivena semaforom
   if (_rdd != "SEMAPHORE") .and. my_use_semaphore()
        _version :=  get_semaphore_version(table)
     
        if (_version == -1)

          // semafor je resetovan
          // lockuj da drugi korisnici ne bi mijenjali tablelu dok je ucitavam
          if lock_semaphore(table, "lock")
             update_dbf_from_server(table, "FULL")
             update_semaphore_version(table, .f.)
             lock_semaphore(table, "free")
          endif

        else

            _last_version := last_semaphore_version(table)
            // moramo osvjeziti cache
            if _version < _last_version

               log_write("my_use " + table + " osvjeziti dbf cache: ver: " + ALLTRIM(STR(_version, 10)) + " last_ver: " + ALLTRIM(STR(_last_version, 10))) 
               if lock_semaphore(table, "lock")
                  update_dbf_from_server(table, "IDS")
                  update_semaphore_version(table, .f.)
                  lock_semaphore(table, "free")
               endif

            endif

             // sada bi lokalni cache morao biti ok, idemo to provjeriti
             check_after_synchro(table)

        endif

   else
     // rdd = "SEMAPHORE" poziv is update from sql server procedure
     // samo otvori tabelu
     if gDebug > 5
          log_write("my_use table:" + table + " / rdd: " +  _rdd + " alias: " + alias + " exclusive: " + hb_ValToStr(excl) + " new: " + hb_ValToStr(new_area))
     endif
     _rdd := "DBFCDX" 
   endif

endif

if USED()
   use
endif

begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }
          dbUseArea( new_area, _rdd, my_home() + table, alias, !excl, .f.)
 
recover using _err
          _msg := "ERR: " + _err:description + ": tbl:" + my_home() + table + " alias:" + alias + " se ne moze otvoriti ?!"
          Alert(_msg)
               
          ferase_dbf(table)

          repair_dbfs()
          QUIT

end sequence


return

// ------------------------------------------
// status = "lock" (locked_by_me), "free"
// ------------------------------------------
function lock_semaphore(table, status)
local _qry
local _ret
local _i
local _err_msg
local _server := pg_server()
local _user   := f18_user()


// status se moze mijenjati samo ako neko drugi nije lock-ovao tabelu

_i := 0
while .t.

    _i++
	if get_semaphore_status(table) == "lock"
        _err_msg := ToStr(Time()) + " : table locked : " + table + " retry : " + STR(_i, 2) + "/" + STR(SEMAPHORE_LOCK_RETRY_NUM, 2)
		MsgO(_err_msg)
         log_write(_err_msg)
         hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
        MsgC()
    else
        if _i > 1
           _err_msg := ToStr(Time()) + " : table unlocked : " + table + " retry : " + STR(_i, 2) + "/" + STR(SEMAPHORE_LOCK_RETRY_NUM, 2)
           log_write(_err_msg)
        endif
        exit
    endif

    if (_i >= SEMAPHORE_LOCK_RETRY_NUM)
          _err_msg := "table " + table + " ostala lockovana nakon " + STR(SEMAPHORE_LOCK_RETRY_NUM, 2) + " pokusaja ?!"
          MsgBeep(_err_msg)
          log_write(_err_msg)
          return .f.
    endif
enddo

// svi useri su lockovani
_qry := "UPDATE fmk.semaphores_" + table + " SET algorithm=" + _sql_quote(status) + ", last_trans_user_code=" + _sql_quote(_user) + "; "

if status == "lock"
   _qry += "UPDATE fmk.semaphores_" + table + " SET algorithm='locked_by_me' WHERE user_code=" + _sql_quote(_user) + ";" 
endif

if gDebug > 9 
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
  // ERROR
  log_write("error :" + _qry)
  QUIT
endif

return .t.

// -----------------------------------
// -----------------------------------
function get_semaphore_status(table)
local _qry
local _ret
local _server := pg_server()
local _user   := f18_user()

_qry := "SELECT algorithm FROM  fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote(_user)

if gDebug > 10 
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
   log_write("error :" + _qry)
  QUIT
endif

return _ret:Fieldget( 1 )


// ------------------------------------
// ------------------------------------
function last_semaphore_version(table)
local _qry
local _ret
local _server:= pg_server()

_qry := "SELECT last_trans_version FROM  fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote(f18_user())

if gDebug > 9 
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
  return -1
endif

return _ret:Fieldget( 1 )

/* ------------------------------------------
  get_semaphore_version( "konto", last = .t. => last_version)
  -------------------------------------------
*/
function get_semaphore_version(table, last)
LOCAL _tbl_obj
LOCAL _result
LOCAL _qry
local _tbl
local _server := pg_server()
local _user := f18_user()

// trebam last_version
if last == NIL
   last := .f.
endif

_tbl := "fmk.semaphores_" + LOWER(table)

_result := table_count( _tbl, "user_code=" + _sql_quote(_user)) 

if _result <> 1
  log_write( _tbl + " " + _user + "count =" + STR(_result))
  return -1
endif

_qry := "SELECT "
if last
  _qry +=  "MAX(last_trans_version) AS last_version"
else
  _qry += "version"
endif
_qry += " FROM " + _tbl + " WHERE user_code=" + _sql_quote(_user)

_tbl_obj := _sql_query( _server, _qry )

if VALTYPE(_tbl_obj) == "L" 
      MsgBeep( "problem sa:" + _qry)
      QUIT
endif

_result := _tbl_obj:Fieldget(1)

RETURN _result

/* ------------------------------------------
  reset_semaphore_version( "konto")
  set version to -1
  -------------------------------------------
*/
function reset_semaphore_version(table)
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _user := f18_user()
LOCAL _server := pg_server()

_tbl := "fmk.semaphores_" + LOWER(table)
_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 

if (_result == 0)
   _qry := "INSERT INTO " + _tbl + "(user_code, version) " + ;
               "VALUES(" + _sql_quote(_user)  + ", -1 )"
else
    _qry := "UPDATE " + _tbl + " SET version=-1 WHERE user_code =" + _sql_quote(_user) 
endif
_ret := _sql_query( _server, _qry )

_qry := "SELECT version from " + _tbl + ;
           " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret:Fieldget(1)


/*
  ------------------------------------------
  update_semaphore_version( "konto")
  -------------------------------------------
*/
function update_semaphore_version(table, increment)
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _user := f18_user()
LOCAL _last
LOCAL _server := pg_server()
LOCAL _ver_user, _last_ver, _id_full

_tbl := "fmk.semaphores_" + LOWER(table)

_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 

_last_ver := get_semaphore_version(table, .t.)

if increment == NIL
   increment := .t.
endif

if _last_ver < 0
  _last_ver := 1
endif

_ver_user := _last_ver
if increment
   _ver_user++
endif

if (_result == 0)
   _id_full := "ARRAY[" + _sql_quote("<FULL>/") + "]"

   _qry := "INSERT INTO " + _tbl + "(user_code, version, last_trans_version, ids) " + ;
               "VALUES(" + _sql_quote(_user)  + ", " + STR(_ver_user) + ", (select max(last_trans_version) from " +  _tbl + "), " + _id_full + ")"
   _ret := _sql_query( _server, _qry)

else
    _qry := "UPDATE " + _tbl + ;
                " SET version=" + STR(_ver_user) + ", ids=NULL , dat=NULL WHERE user_code =" + _sql_quote(_user) 
    _ret := _sql_query( _server, _qry )

endif

if increment
    // svim setuj last_trans_version
    _qry := "UPDATE " + _tbl + " SET last_trans_version=" + STR(_last_ver + 1)  
    _ret := _sql_query( _server, _qry )

    // kod svih usera verzija ne moze biti veca od nLast + 1
    _qry := "UPDATE " + _tbl + " SET version=" + STR(_last_ver + 1) + ;
            " WHERE version > " + STR(_last_ver + 1)
    _ret := _sql_query( _server, _qry )
endif

_qry := "SELECT version from " + _tbl + " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret:Fieldget(1)

//-------------------------------------------------
//-------------------------------------------------
function push_ids_to_semaphore( table, ids )
local _tbl
local _result
local _user := f18_user()
local _ret
local _qry
local _sql_ids
local _i
LOCAL _server := pg_server()

if LEN(ids) < 1
   return .f.
endif

log_write( "push ids: " + table + " / " + pp(ids) )

_tbl := "fmk.semaphores_" + LOWER(table)

// treba dodati id za sve DRUGE korisnike
_result := table_count(_tbl, "user_code <> " + _sql_quote(_user)) 

if _result < 1
   // jedan korisnik
   return .t.
endif

_qry := ""

for _i := 1 TO LEN(ids)

    _sql_ids := "ARRAY[" + _sql_quote(ids[_i]) + "]"

    _qry += "UPDATE " + _tbl + " SET ids = ids || " + _sql_ids + ;
            " WHERE user_code <> " + _sql_quote(_user) + " AND ((ids IS NULL) OR NOT (" + _sql_ids + " <@ ids)) ;"

next

log_write( "push ids qry: " + _qry )

_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "O"
  return .t.
else
  return .f.
endif


//---------------------------------------
// vrati matricu id-ova
//---------------------------------------
function get_ids_from_semaphore( table )
local _tbl
local _tbl_obj
local _qry
local _ids, _num_arr, _arr, _i
LOCAL _server := pg_server()
local _user := f18_user()
local _tok

_tbl := "fmk.semaphores_" + LOWER(table)

_qry := "SELECT ids FROM " + _tbl + " WHERE user_code=" + _sql_quote(_user)
_tbl_obj := _sql_query( _server, _qry )
IF _tbl_obj == NIL
      MsgBeep( "problem sa:" + _qry)
      QUIT
ENDIF

_ids := _tbl_obj:Fieldget(1)

_arr := {}
if _ids == NIL
    return _arr
endif

_ids := hb_Utf8ToStr(_ids)

// {id1,id2,id3}
_ids := SUBSTR(_ids, 2, LEN(_ids)-2)

_num_arr := numtoken(_ids, ",")

for _i := 1 to _num_arr
   _tok := token(_ids, ",", _i)
   if LEFT(_tok, 1) == '"' .and. RIGHT(_tok, 1) == '"'
     // odsjeci duple navodnike "..."
     _tok := SUBSTR(_tok, 2, LEN(_tok) -2)
   endif
   AADD(_arr, _tok)
next
RETURN _arr

//---------------------------------------
// date algoritam
//---------------------------------------
function push_dat_to_semaphore( table, date )
local _tbl
local _result
local _ret
local _qry
local _sql_ids
local _i
local _user := f18_user()
local _server := pg_server()

_tbl := "fmk.semaphores_" + table
_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 

_qry := "UPDATE " + _tbl + ;
              " SET dat=" + _sql_quote(date) + ;
              " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret

//---------------------------------------
// vrati date za DATE algoritam
//---------------------------------------
function get_dat_from_semaphore(table)
local _server :=  pg_server()
local _tbl
local _tbl_obj
local _qry
local _dat

_tbl := "fmk.semaphores_" + table

_qry := "SELECT dat FROM " + _tbl + " WHERE user_code=" + _sql_quote(f18_user())
_tbl_obj := _sql_query( _server, _qry )
IF VALTYPE(_tbl_obj) == "L" 
      MsgBeep( "problem sa:" + _qry)
      QUIT
ENDIF

_dat := oTable:Fieldget(1)

RETURN _dat


// ------------------------------  
//  broj redova za tabelu
//  --------------------------------
function table_count(table, condition)
LOCAL _table_obj
LOCAL _result
LOCAL _qry
LOCAL _server := pg_server()
// provjeri prvo da li postoji uopšte ovaj site zapis
_qry := "SELECT COUNT(*) FROM " + table 

if condition != NIL
  _qry += " WHERE " + condition
endif

_table_obj := _sql_query( _server, _qry )
IF VALTYPE(_table_obj) == "L" 
    log_write( "problem sa query-jem: " + _qry )
    QUIT
ENDIF

_result := _table_obj:Fieldget(1)

RETURN _result


// ----------------------------------------------------------------
// sql_fields := { "id", "naz" }
// sql_in     := "id"
// dbf_tbl    := "konto"
// sql_tbl    := "fmk.konto"
// ----------------------------------------------------------------
function create_queries_from_ids(dbf_tbl)
local _a_dbf_rec, _msg
local _qry_1, _qry_2
local _queries     := {}
local _ids, _ids_2 := {}
local _sql_ids := {}
local _i, _id
local _ret := hb_hash()
local _sql_fields
local _algoritam, _alg

_a_dbf_rec := get_a_dbf_rec(dbf_tbl)

_sql_fields := sql_fields(_a_dbf_rec["dbf_fields"])
_alg := _a_dbf_rec["algoritam"]


_sql_tbl := "fmk." + dbf_tbl

for _i := 1 to LEN(_alg)
   AADD(_queries, "SELECT " + _sql_fields + " FROM " + _sql_tbl + " WHERE ")
   AADD(_sql_ids, NIL)
   AADD(_ids_2, NIL)
next
 
_ids := get_ids_from_semaphore( dbf_tbl )

// primjer
// suban 00-11-2222 rbr 1, rbr 2 
// kompletan nalog (#2) 00-11-3333
// Full synchro (#F)
// _ids := { "00112222 1", "00112222 2", "#200113333", "#F" }

for each _id in _ids

    if LEFT(_id, 1) == "#"
       // algoritam "#2" => algoritam 2
       _algoritam := VAL(SUBSTR( _id, 2, 1))
       _id := SUBSTR(_id, 3)
    else
       _algoritam := 1
    endif

    // ne moze biti "#3" a da tabela ima definisana samo dva algoritma
    if _algoritam > LEN(_alg)
            _msg := "nasao sam ids " + _id + ". Ovaj algoritam nije podrzan za " + dbf_tbl
            Alert(_msg)
            log_write(_msg)
            QUIT
    endif


    if _sql_ids[_algoritam] == NIL
        _sql_ids[_algoritam] := "("
        _ids_2[_algoritam] := {}
    endif

    _sql_ids[_algoritam] += _sql_quote(_id) + ","
    AADD(_ids_2[_algoritam], _id)
 
next


for _i := 1 to LEN(_alg)

    if _sql_ids[_i] != NIL
       // odsjeci zarez na kraju
       _sql_ids[_i] := LEFT(_sql_ids[_i], LEN(_sql_ids[_i]) - 1)
       _sql_ids[_i] += ")"
       _queries[_i] +=  "(" + _alg[_i]["sql_in"]  + ") IN " + _sql_ids[_i]
  
    else
       _queries[_i] := NIL
    endif

next

log_write("ret[qry]=" + pp(_queries))
log_write("ret[ids]=" + pp(_ids_2))
_ret["qry"] := _queries
_ret["ids"] := _ids_2

return _ret


// ------------------------------------------------------
// sve ids-ove pobrisi iz dbf-a
// ids       := {"#20011", "#2012"}
// algoritam := 2
// ------------------------------------------------------
function delete_dbf_ids(dbf_table, ids, algoritam)
local _a_dbf_rec, _alg
local _counter
local _fnd, _tmp_id, _rec
local _dbf_alias
local _dbf_tag
local _key_block


_a_dbf_rec := get_a_dbf_rec(dbf_table)
_alg := _a_dbf_rec["algoritam"]

_dbf_alias := _a_dbf_rec["alias"]
_dbf_tag := _alg[algoritam]["dbf_tag"]

_key_block := _alg[algoritam]["dbf_key_block"]

// pobrisimo sve id-ove koji su drugi izmijenili
SET ORDER TO TAG (_dbf_tag)

_counter := 0

if VALTYPE(ids) != "A"
   Alert("ids type ? " + VALTYPE(ids))
endif

do while .t.
    _fnd := .f.
    for each _tmp_id in ids
        HSEEK _tmp_id
        do while !EOF() .and. EVAL(_key_block) == _tmp_id

            skip
            _rec := RECNO()
            skip -1 
            DELETE
            go _rec
 
            _fnd := .t.
            ++ _counter
        enddo
    next

    if !_fnd 
            exit 
    endif
enddo

log_write( "delete_dbf_ids: " + dbf_table + "/ dbf_tag =" + _dbf_tag + " from local dbf, deleted rec cnt: " + ALLTRIM(STR( _counter )) )

return

// -----------------------------------------------  
// napuni dbf tabelu sa podacima sa servera
// dbf_tabela mora biti otvorena i u tekucoj WA
// -----------------------------------------------  
function fill_dbf_from_server(dbf_table, sql_query)
local _counter := 0
local _i, _fld
local _server := pg_server()
local _qry_obj
local _retry := 3
local _a_dbf_rec
local _dbf_alias, _dbf_fields

_a_dbf_rec := get_a_dbf_rec(dbf_table)
_dbf_alias := _a_dbf_rec["alias"]
_dbf_fields := _a_dbf_rec["dbf_fields"]

_qry_obj := run_sql_query(sql_query, _retry ) 

 
if !USED() .or. ( _dbf_alias != ALIAS() )
   Alert(PROCNAME(1) + "(" + ALLTRIM(STR(PROCLINE(1))) + ") " + dbf_table + " dbf mora biti otvoren !")
   log_write( "ERR - tekuci dbf alias je " + ALIAS() + " a treba biti " + _dbf_alias)
   QUIT 
endif

DO WHILE !_qry_obj:EOF()

append blank

for _i := 1 to LEN(_dbf_fields)
    _fld := FIELDBLOCK(_dbf_fields[_i])
    if VALTYPE(EVAL(_fld)) $ "CM"
        EVAL(_fld, hb_Utf8ToStr(_qry_obj:FieldGet(_i)))
    else
        EVAL(_fld, _qry_obj:FieldGet(_i))
    endif
next 

_qry_obj:Skip()

++ _counter

ENDDO

log_write( dbf_table +  " updated from sql server rec_cnt: " + ALLTRIM(STR( _counter )) )

return


// -----------------------------------------------------------------------------------------------------
// synchro na osnovu ids-ova
// sql_in = { 'idfirma || td || brnal || rbr ', 'idfirma || td || brnal'} 
// -----------------------------------------------------------------------------------------------------
function ids_synchro(dbf_table)
local _i, _ids_queries

_ids_queries := create_queries_from_ids(dbf_table)

//  _ids_queries["ids"] = {  {"00113333 1", "0011333 2"}, {"00224444"}  }
//  _ids_queries["qry"] = {  "select .... in ... rpad('0011333  1') ...", "select .. in ... rpad("0022444")" }

log_write("ids_synchro - ids_queries: " + pp(_ids_queries))

for _i := 1 TO LEN(_ids_queries["ids"])
 
   // ako nema id-ova po algoritmu _i, onda je NIL ova varijabla
   if _ids_queries["ids"][_i] != NIL

     // pobrisi dbf
     delete_dbf_ids( dbf_table, _ids_queries["ids"][_i], _i)

     // dodaj sa servera
     fill_dbf_from_server( dbf_table, _ids_queries["qry"][_i])

   endif
next

return


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

_sql_table  := "fmk." + dbf_table
_a_dbf_rec  := get_a_dbf_rec(dbf_table) 
_sql_fields := sql_fields(_a_dbf_rec["dbf_fields"])
_sql_order  := _a_dbf_rec["sql_order"]

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

return .t.


// ----------------------------------------------------------
// dbf_fields - {"id", {"iznos", 12, 2} }
// values - { "01", 15.5 }
//
// => "01       15.50"
// ----------------------------------------------------------
function set_dbf_id_from_dbf_fields(dbf_fields, values)
local _t_field, _t_field_dec
local _full_id := ""

for each _field in dbf_fields

    if VALTYPE( _field ) == "A"    
        _t_field := _field[1]
        _t_field_dec := _field[2]
        _full_id += STR( values[ _t_field ], _t_field_dec )
    else
        _t_field := _field
        if VALTYPE( values[ _t_field ] ) == "D"
            _full_id += DTOS( values[ _t_field ] )
        else
            _full_id += values[ _t_field ]
        endif
    endif

next

return _full_id


