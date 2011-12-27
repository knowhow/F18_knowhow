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

// -----------------------------------------------
// -----------------------------------------------
function get_version_num(major, minor, patch)

if VALTYPE(major) == "C"
   return  VAL(major) * 10000 +  VAL(minor) * 100 + VAL(patch)
else
  return  major * 10000 +  minor * 100 + patch
endif

// ------------------------------
// ------------------------------
function get_version_str(num)
local _prev, _ret := "", _div, _rest

_prev := num
_div := num % 10000
num := _div

_ret += ALLTRIM(STR( ROUND((_prev - _div) / 10000, 0), 0))

_prev := num
_div := num % 100
num := _div
_ret += "." + ALLTRIM(STR( ROUND((_prev - _div) / 100, 0), 0))

_ret += "." + ALLTRIM(STR(num, 0))

return _ret
