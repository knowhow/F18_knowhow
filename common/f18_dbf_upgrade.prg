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
#include "f18_ver.ch"

function dbf_update()
local _ini_params
local _current_dbf_ver, _new_dbf_ver
local _ini_section := "DBF_version"

// ucitaj parametre iz inija, ako postoje ...
_ini_params := hb_hash()
_ini_params["major"] := "0"
_ini_params["minor"] := "0"
_ini_params["patch"] := "0"

if !f18_ini_read(_ini_section, @_ini_params, .f.)
   MsgBeep("problem sa ini_params " + _ini_section)
endif
_current_dbf_ver := get_version_num(_ini_params["major"], _ini_params["minor"], _ini_params["patch"])
_new_dbf_ver := get_version_num( F18_DBF_VER_MAJOR, F18_DBF_VER_MINOR, F18_DBF_VER_PATCH)

log_write("current dbf version:" + STR(_current_dbf_ver))
log_write("    F18 dbf version:" + STR(_new_dbf_ver))

// 0.2.1
if _current_dbf_ver < 00201
   modstru({"*roba", "A IDKONTO C 7 0"})
endif

// 0.3.0
if _current_dbf_ver < 0300
   modstru({"*fin_suban", "A IDRJ C 6 0", "A FUNK C 5 0", "A FOND C 4 0" })
endif

_ini_params["major"] := F18_DBF_VER_MAJOR
_ini_params["minor"] := F18_DBF_VER_MINOR
_ini_params["patch"] := F18_DBF_VER_PATCH

if !f18_ini_write(_ini_section, @_ini_params, .f.) 
   MsgBeep("problem write params" + _ini_params)
endif

return

