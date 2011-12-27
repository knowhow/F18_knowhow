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

function pp(x)
local _key, _i
local _tmp
local _type

_tmp := ""

altd()

_type := VALTYPE(x)

if _type == "H"
  FOR EACH _key in x
      _tmp +=  pprint(_key) + "/ " + pprint(x[_key]) + ";" + hb_eol()
  NEXT
  return _tmp
endif

if _type  == "A"
  FOR _i := 1 to LEN(x)
      _tmp +=  ALLTRIM(pprint(_i)) + ": " + pprint(x[_i]) + ";" + hb_eol()
  NEXT
  return _tmp
endif

if _type $ "CLDN"
   return hb_ValToStr()
endif

return "?" + _type + "?"
