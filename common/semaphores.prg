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

// ----------------------------------------------------------------
// semaphore_param se prosjedjuje eval funkciji ..from_sql_server
// ----------------------------------------------------------------
function my_use(alias, table, new_area, _rdd, semaphore_param)
local _pos
local _version
local _area

if new_area == NIL
   new_area := .f.
endif

/*
{ F_PRIPR  ,  "PRIPR"   , "fin_pripr"  },;
...
*/

if VALTYPE(alias) <> "C"
   // F_SUBAN
   _pos := ASCAN(gaDBFs,  { |x|  x[1]==alias} )
   alias := gaDBFs[_pos, 2]
else
   // /home/test/suban.dbf => suban
   alias := FILEBASE(alias)
endif

// pozicija gdje je npr. SUBAN
_pos := ASCAN(gaDBFs,  { |x|  x[2]==UPPER(alias)} )
_area := gaDBFs[_pos, 1] 

if table == NIL
   // "fin_suban"
   table := gaDBFs[_pos, 3]
endif

if len(gADBFs[_pos]) > 3
 lock_semaphore(table, "lock")
endif

if _rdd == NIL
  _rdd = "DBFCDX"
endif

// mi otvaramo ovu tabelu ~/.F18/bringout/fin_pripr
//if gDebug > 9
// log_write( "LEN gaDBFs[" + STR(nPos) + "]" + STR(LEN(gADBFs[nPos])) + " USE (" + my_home() + gaDBFs[nPos, 3]  + " ALIAS (" + cAlias + ") VIA (" + _rdd + ") EXCLUSIVE")
//endif

if  LEN(gaDBFs[_pos])>3 

   if (_rdd != "SEMAPHORE")
        //if gDebug > 9
        //    log_write("F18TBL =" + cF18Tbl)
        //endif
        _version :=  get_semaphore_version(table)
        if gDebug > 9
          log_write("Tabela:" + table + " semaphore _version=" + STR(_version) + " last_semaphore_version=" + STR(last_semaphore_version(table)))
        endif

        if (_version == -1)
          // semafor je resetovan
          EVAL( gaDBFs[_pos, 4], "FULL")
          update_semaphore_version(table, .f.)

        else
            // moramo osvjeziti cache
           if _version < last_semaphore_version(table)
             if (semaphore_param == NIL) .and. LEN(gaDBFs[_pos]) > 4
                 semaphore_param:= gaDBFs[_pos, 5]
             endif
             EVAL( gaDBFs[_pos, 4], semaphore_param )
             update_semaphore_version(table, .f.)
           endif
        endif
        lock_semaphore(table, "free")
   else
      // poziv is update from sql server procedure
      _rdd := "DBFCDX" 
   endif

endif

if new_area
   SELECT NEW
else
   SELECT (_area)
   use
endif
USE (my_home() + table) ALIAS (alias) VIA (_rdd) EXCLUSIVE

return

// ---------------------------
// status = "lock", "free"
// ---------------------------
function lock_semaphore(table, status)
local _qry
local _ret
local _server:= pg_server()
local _user := f18_user()

// svi useri su lockovani
_qry := "UPDATE fmk.semaphores_" + table + " SET algorithm=" + _sql_quote(status) 

if gDebug > 5  
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
  // ERROR
  log_write("error :" + _qry)
  ? "error:", _qry
  QUIT
endif

return .t.

// -----------------------------------
// -----------------------------------
function get_semaphore_status(table)
local _qry
local _ret
local _server := pg_server()
local _user := f18_user()

_qry := "SELECT algorithm FROM  fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote(_user)

if gDebug > 5  
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
   log_write("error :" + _qry)
  ? "error:", _qry
  QUIT
endif

return _ret:Fieldget( 1 )


// ------------------------------------
function last_semaphore_version(table)
local _qry
local _ret
local _server:= pg_server()

_qry := "SELECT last_trans_version FROM  fmk.semaphores_" + table + " WHERE user_code=" + _sql_quote(f18_user())

if gDebug > 5  
  log_write(_qry)
endif
_ret := _sql_query( _server, _qry )

if VALTYPE(_ret) == "L"
  // ERROR
  // currval of sequence "sem_ver_fin_suban" is not yet defined in this session
  _qry := "SELECT nextval('fmk.sem_ver_" + table + "')"
  log_write(_qry)
  _ret := _sql_query( _server, _qry )
  if VALTYPE(_ret) == "L"
      // ?? opet error ??
      return -1
  else   
      return 1
  endif
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

_result := _tbl_obj:Fieldget( _tbl_obj:Fieldpos( iif(last, "last_version", "version")) )

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
   _qry := "INSERT INTO " + _tbl + ;
              "(user_code, version) " + ;
               "VALUES(" + _sql_quote(_user)  + ", -1 )"
else
    _qry := "UPDATE " + _tbl + ;
            " SET version=-1" + ;
            " WHERE user_code =" + _sql_quote(_user) 
endif
_ret := _sql_query( _server, _qry )

_qry := "SELECT version from " + _tbl + ;
           " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret:Fieldget( _ret:Fieldpos("version") )


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
LOCAL _ver_user, _last_ver

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
   _qry := "INSERT INTO " + _tbl + ;
              "(user_code, version, last_trans_version) " + ;
               "VALUES(" + _sql_quote(_user)  + ", " + STR(_ver_user) + " , "+ STR(_ver_user) + ")"
   _ret := _sql_query( _server, _qry)

else
    _qry := "UPDATE " + _tbl + ;
                " SET version=" + STR(_ver_user) + "," +;
                " ids=NULL , dat=NULL " + ;
                " WHERE user_code =" + _sql_quote(_user) 
    _ret := _sql_query( _server, _qry )

endif

if increment
    // svim setuj last_trans_version
    _qry := "UPDATE " + _tbl + ;
            " SET last_trans_version=" + STR(_last_ver + 1)  
    _ret := _sql_query( _server, _qry )

    // kod svih usera verzija ne moze biti veca od nLast + 1
    _qry := "UPDATE " + _tbl + ;
                " SET version=" + STR(_last_ver + 1) + ;
                " WHERE version > " + STR(_last_ver + 1)
    _ret := _sql_query( _server, _qry )
endif

_qry := "SELECT version from " + _tbl + ;
           " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret:Fieldget( _ret:Fieldpos("version") )

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

_tbl := "fmk.semaphores_" + LOWER(table)

// treba dodati id za sve DRUGE korisnike
_result := table_count(_tbl, "user_code <> " + _sql_quote(_user)) 

if _result < 1
   // jedan korisnik
   return .t.
endif

// ARAY['id1', 'id2']
_sql_ids := "ARRAY["
for _i:=1 TO LEN(ids)
 _sql_ids += _sql_quote(hb_StrToUtf8(ids[_i])) 
 if _i < LEN(ids)
    _sql_ids += ","
 endif
next
_sql_ids += "]"


_qry := "UPDATE " + _tbl + ;
              " SET ids = ids || " + _sql_ids + ;
              " WHERE user_code <> " + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret


//---------------------------------------
// vrati matricu id-ova
//---------------------------------------
function get_ids_from_semaphore( table )
//local _server :=  pg_server()
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

_ids := _tbl_obj:Fieldget( _tbl_obj:Fieldpos("ids") )

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
local _user := f18_user()
local _ret
local _qry
local _sql_ids
local _i
LOCAL _server := pg_server()

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

_dat := oTable:Fieldget( oTable:Fieldpos("dat") )

RETURN _dat


/* ------------------------------  
  broj redova za tabelu
  --------------------------------
*/
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

_result := _table_obj:Fieldget( _table_obj:Fieldpos("count") )

RETURN _result
