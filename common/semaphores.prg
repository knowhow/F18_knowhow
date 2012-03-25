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

function my_usex(alias, table, new_area, _rdd, semaphore_param)

return my_use(alias, table, new_area, _rdd, semaphore_param, .t.)


// ----------------------------------------------------------------
// semaphore_param se prosjedjuje eval funkciji ..from_sql_server
// ----------------------------------------------------------------
function my_use(alias, table, new_area, _rdd, semaphore_param, excl)
local _err
local _pos
local _version
local _area

if new_area == NIL
   new_area := .f.
endif

if excl == NIL
  excl := .f.
endif

if VALTYPE(alias) == "N"
   // F_SUBAN
   _pos := ASCAN(gaDBFs,  { |x|  x[1]==alias} )
   alias := gaDBFs[_pos, 2]
else
   // /home/test/suban.dbf => suban
   alias := UPPER(FILEBASE(alias))
   
   if table != NIL
        // ako je naveden alias i ime tabele, onda je ime tabele "glavna" vrijednost
       table := FILEBASE(table)
       _pos := ASCAN(gaDBFs,  { |x|  x[3]==table} )
   else
       _pos := ASCAN(gaDBFs,  { |x|  x[2]==UPPER(alias)} )
   endif
endif

// pozicija gdje je npr. SUBAN
_area := gaDBFs[_pos, 1] 

if table == NIL
   // "fin_suban"
   table := gaDBFs[_pos, 3]
endif

if _rdd == NIL
  _rdd = "DBFCDX"
endif

if (LEN(gaDBFs[_pos]) > 3) 

   // tabela je pokrivena semaforom
   if (_rdd != "SEMAPHORE")
        _version :=  get_semaphore_version(table)
     
        if (_version == -1)
          // semafor je resetovan
          // lockuj da drugi korisnici ne bi mijenjali tablelu dok je ucitavam
          if lock_semaphore(table, "lock")
             EVAL( gaDBFs[_pos, 4], "FULL")
             update_semaphore_version(table, .f.)
             lock_semaphore(table, "free")
          endif

        else
            // moramo osvjeziti cache
           if _version < last_semaphore_version(table)
             if lock_semaphore(table, "lock")
                 if (semaphore_param == NIL) .and. LEN(gaDBFs[_pos]) > 4
                    semaphore_param:= gaDBFs[_pos, 5]
                 endif
                 EVAL( gaDBFs[_pos, 4], semaphore_param )
                 update_semaphore_version(table, .f.)
                 lock_semaphore(table, "free")
              endif
           endif
        endif
   else
      // rdd = "SEMAPHORE" poziv is update from sql server procedure
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
          log_write("err:" + _err:description + ":" + my_home() + table + " se ne moze otvoriti ?!")
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

//---------------------------------------
//---------------------------------------
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
_qry := "SELECT COUNT(*) FROM " + table + " WHERE " + condition

_table_obj := _sql_query( _server, _qry )
IF VALTYPE(_table_obj) == "L" 
      log_write( "problem sa query-jem: " + _qry )
      QUIT
ENDIF

_result := _table_obj:Fieldget(1)

RETURN _result
