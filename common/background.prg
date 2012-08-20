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
#include "hbthread.ch"

thread static _log_db_handle := NIL
thread static _db_thread_id := NIL

function db_trehad_id()
return _db_thread_id

// -----------------------
// -----------------------
function init_threads()
local _main_thread

_main_thread   :=  hb_threadSelf()
_db_thread_id  :=  hb_threadStart(  HB_BITOR( HB_THREAD_INHERIT_PUBLIC, HB_THREAD_MEMVARS_COPY ), @_db_thread_fn() )
// --------------


return

// SELECT F_PARTN
// if used()
/*
  hb_detach( , {|| refresh_partn() }}

    //hb_dbRequest( [<cAlias>], [<lFreeArea>], [<@xCargo>], [<lWait>] )
   hb_dbRequest( , , @_result, .t. )
   ? "work area atached, used() =>", used(), alias()

   ? "query result:", eval( _result )
   close
   return
*/
// endif

// ---------------------
// ---------------------
function _db_thread_fn()
local _query_b
local _result
local _i
local _area, _alias
local _arr
local _used

IF ( _log_db_handle :=  FCREATE("F18_2.log") ) == -1
    ? "Cannot create log file: F18_2.log"
    QUIT
ENDIF


_arr := gADBFs
// a_dbfs()

log_write_db( my_home() )

do while .t.

//? "thread_db begin", VALTYPE(_arr)

//if hb_dbRequest(  , , @_query_b, .t.)

    for _i := 1 to LEN(_arr)
        _area := _arr[_i, 1]
        _alias := _arr[_i, 2]

        SELECT (_area)
  
        begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }
          _used := .f. 
          if used()
            log_write_db("_db_thread USED!:" + to_str(TIME()) + " / " + to_str(_i) + " : "  + to_str(_area) + " : " + to_str( _alias ))
          else
              log_write_db("_db_thread :" + to_str(TIME()) + " / " + to_str(_i) + " : "  + to_str(_area) + " : " + to_str( _alias ))
              my_use(_alias)
              use
          endif
        recover using _err
          log_write_db("belaj: " + to_str(_alias) + " :" +  to_str(_err:cargo[1]) + " / " + to_str(_err:cargo[3]))
          log_write_db("     : " + to_str(_alias) + " :" +  to_str(_err:cargo[2]) + " / " + to_str(_err:cargo[4]))
        end sequence
    next

    //hb_dbDetach( , {|| _result})
    //endif
    //? "thread_db end"

hb_IdleSleep(5)

enddo

return

// ----------------------------
// ----------------------------
static function refresh_partn()

/*
SELECT (F_PARTN)
use
return  my_use("partn")
*/

return .t.


function log_write_db(cMsg)
FWRITE( _log_db_handle, cMsg + hb_eol() )
return


