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


function fetch_metric(sect, user, default_value)
local _temp_qry
local _table
local _server := pg_server()
local _ret := ""

if default_value == NIL
  default_value := ""
endif

if user != NIL
   if user == "<>"
      sect += "/" + f18_user()
   else
      sect += "/" + user
   endif
endif

_temp_qry := "SELECT fetchmetrictext(" + _sql_quote(sect)  + ")"

_table := _sql_query( _server, _temp_qry )

IF VALTYPE(_table) != "O"
   return default_value
ENDIF

_ret := _table:Fieldget(1)

if _ret == "!!notfound!!"
   return default_value
else
   return str_to_val(_ret, default_value)
endif



// --------------------------------------------------------------
// setuj parametre u metric tabelu
// --------------------------------------------------------------
function set_metric(sect, user, value)
local _table
local _temp_qry
local _server := pg_server()
local _val

if user != NIL
   if user == "<>"
      sect += "/" + f18_user()
   else
      sect += "/" + user
   endif
endif

SET CENTURY ON
_val := hb_ValToStr(value)
SET CENTURY OFF

_temp_qry := "SELECT fmk.setmetric(" + _sql_quote(sect) + "," + _sql_quote(_val) +  ")"
_table := _sql_query( _server, _temp_qry )
if _table == NIL
	MsgBeep( "problem sa:" + _temp_qry )
    return .f.
endif

return _table:Fieldget( _table:Fieldpos("setmetric") )

// --------------------------------------------------------------
// --------------------------------------------------------------------
static function str_to_val(str_val, default_value)
local _val_type := VALTYPE(default_value)

do case
	case _val_type == "C"
		return HB_UTF8TOSTR( str_val )
	case _val_type == "N"
		return VAL(str_val)
	case _val_type == "D"
		return CTOD(str_val)
	case _val_type == "L"
		if LOWER(str_val) == ".t."
			return .t.
		else
			return .f.
		endif
end case

return NIL


// ----------------------------------------------------------
// set/get globalne parametre F18
// ----------------------------------------------------------
function get_set_global_param(param_name, value, def_value)
local _ret

if value == NIL
   _ret := fetch_metric(param_name, NIL, def_value)
else
   set_metric(param_name, NIL, value)
   _ret := value
endif

return _ret

// ----------------------------------------------------------
// set/get user parametre F18
// ----------------------------------------------------------
function get_set_user_param(param_name, value, def_value)
local _ret

if value == NIL
   _ret := fetch_metric(param_name, my_user(), def_value)
else
   set_metric(param_name, my_user(), value)
   _ret := value
endif

return _ret
