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

// ------------------------------------
// ------------------------------------
function last_semaphore_version(cTable)
local cTmpQry
local oRet
local oServer:= pg_server()

//cTmpQry := "SELECT currval('fmk.sem_ver_" + cTable + "')"

cTmpQry := "SELECT last_trans_version FROM  fmk.semaphores_" + cTable + " WHERE user_code=" + _sql_quote(f18_user())

if gDebug > 5  
  log_write(cTmpQry)
endif
oRet := _sql_query( oServer, cTmpQry )

if VALTYPE(oRet) == "L"
  // ERROR
  // currval of sequence "sem_ver_fin_suban" is not yet defined in this session
  cTmpQry := "SELECT nextval('fmk.sem_ver_" + cTable + "')"
  log_write(cTmpQry)
  oRet := _sql_query( oServer, cTmpQry )
  if VALTYPE(oRet) == "L"
      // ?? opet error ??
      return -1
  else   
      return 1
  endif
endif

return oRet:Fieldget( 1 )

/* ------------------------------------------
  get_semaphore_version( "konto")
  -------------------------------------------
*/
function get_semaphore_version(table)
LOCAL _tbl_obj
LOCAL _result
LOCAL _qry
local _tbl
local _server := pg_server()
local _user := f18_user()

_tbl := "fmk.semaphores_" + table

_result := table_count( _tbl, "user_code=" + _sql_quote(_user)) 

if _result <> 1
  log_write( _tbl + " " + _user + "count =" + STR(_result))
  return -1
endif

_qry := "SELECT version FROM " + _tbl + " WHERE user_code=" + _sql_quote(_user)
_tbl_obj := _sql_query( _server, _qry )
IF _tbl_obj == NIL
      MsgBeep( "problem sa:" + _qry)
      QUIT
ENDIF

_result := _tbl_obj:Fieldget( _tbl_obj:Fieldpos("version") )

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

_tbl := "fmk.semaphores_" + table
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


/* ------------------------------------------
  update_semaphore_version( "konto")
  -------------------------------------------
*/
function update_semaphore_version(table)
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _user := f18_user()
LOCAL _server := pg_server()
LOCAL _last := 0

_tbl := "fmk.semaphores_" + table

_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 

if (_result == 0)
   _qry := "INSERT INTO " + _tbl + ;
              "(user_code, version, last_trans_version) " + ;
               "VALUES(" + _sql_quote(_user)  + ", 1, 1 )"
   _ret := _sql_query( _server, _qry)

else
    _last := get_semaphore_version(table)
    _qry := "UPDATE " + _tbl + ;
                " SET version=" + STR(_last + 1) + ;
                " WHERE user_code =" + _sql_quote(_user) 
    _ret := _sql_query( _server, _qry )

endif

// svim setuj last_trans_version
_qry := "UPDATE " + _tbl + ;
        " SET last_trans_version=" + STR(_last + 1)  
_ret := _sql_query( _server, _qry )

// kod svih usera verzija ne moze biti veca od nLast + 1
_qry := "UPDATE " + _tbl + ;
              " SET version=" + STR(_last + 1) + ;
              " WHERE version > " + STR(_last + 1)
_ret := _sql_query( _server, _qry )

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

if LEN(_ids) < 1
   return .f.
endif

_tbl := "fmk.semaphores_" + table
_result := table_count(_tbl, "user_code=" + _sql_quote(_user)) 

// ARAY['id1', 'id2']
_sql_ids := "ARRAY["
for _i := 1 TO LEN(ids)
 _sql_ids += _sql_quote(_id) 
 if _i < LEN(ids)
    _sql_ids := ","
 endif
next
_sql_ids += "]"


_qry := "UPDATE " + _tbl + ;
              " SET ids = ids || " + _sql_ids + ;
              " WHERE user_code =" + _sql_quote(_user) 
_ret := _sql_query( _server, _qry )

return _ret


//---------------------------------------
// vrati matricu id-ova
//---------------------------------------
function get_ids_from_semaphore( table )
local _server :=  pg_server()
local _tbl
local _tbl_obj
local _qry
local _ids, _num_arr, _arr, _i

_tbl := "fmk.semaphores_" + table

_qry := "SELECT ids FROM " + _tbl + " WHERE user_code=" + _sql_quote(f18_user())
_tbl_obj := _sql_query( _server, _qry )
IF _tbl_obj == NIL
      MsgBeep( "problem sa:" + _qry)
      QUIT
ENDIF

_ids := oTable:Fieldget( oTable:Fieldpos("ids") )

// {id1,id2,id3}
_ids := SUBSTR(_ids, 2, LEN(_ids)-2)

_num_arr := numtoken(_ids, ",")
_arr := {}

for _i := 1 to _num_arr
   AADD(_arr, token(_ids, ",", _i))
next
RETURN _arr


// provjeri prvo da li postoji uopšte ovaj site zapis
_qry := "SELECT COUNT(*) FROM " + _ + " WHERE " + cCondition

oTable := _sql_query( oServer, cTmpQry )
IF oTable:NetErr()
      log_write( "problem sa query-jem: " + cTmpQry )
      QUIT
ENDIF

nResult := oTable:Fieldget( oTable:Fieldpos("count") )

return _ids

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
IF _tbl_obj == NIL
      MsgBeep( "problem sa:" + _qry)
      QUIT
ENDIF

_dat := oTable:Fieldget( oTable:Fieldpos("dat") )

RETURN _dat


// provjeri prvo da li postoji uopšte ovaj site zapis
_qry := "SELECT COUNT(*) FROM " + _ + " WHERE " + cCondition

oTable := _sql_query( oServer, cTmpQry )
IF oTable:NetErr()
      log_write( "problem sa query-jem: " + cTmpQry )
      QUIT
ENDIF

nResult := oTable:Fieldget( oTable:Fieldpos("count") )




/* ------------------------------  
  broj redova za tabelu
  --------------------------------
*/
function table_count(cTable, cCondition)
LOCAL oTable
LOCAL nResult
LOCAL cTmpQry
LOCAL oServer := pg_server()

// provjeri prvo da li postoji uopšte ovaj site zapis
cTmpQry := "SELECT COUNT(*) FROM " + cTable + " WHERE " + cCondition

oTable := _sql_query( oServer, cTmpQry )
IF oTable:NetErr()
      log_write( "problem sa query-jem: " + cTmpQry )
      QUIT
ENDIF

nResult := oTable:Fieldget( oTable:Fieldpos("count") )

RETURN nResult


