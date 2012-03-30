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

static __f18_dbfs := nil

// -------------------------------
// -------------------------------
function set_a_dbfs()
local _dbf_fields, _sql_order
local _alg

public gaDbfs := {}

__f18_dbfs := hb_hash()


set_a_dbf_fin()
set_a_dbf_fakt()
set_a_dbf_ld()
set_a_dbf_epdv()

set_a_dbf_sifk_sifv()
set_a_dbf_sifarnici()

set_a_dbfs_legacy()

return


// ----------------------------------
// ----------------------------------
function set_a_dbfs_key_fields()
local _key

for each _key in __f18_dbfs:Keys

  // nije zadano - ja cu na osnovu strukture dbf-a
  //  napraviti dbf_fields
  if !HB_HHASKEY(__f18_dbfs[_key], "dbf_fields")
      set_dbf_fields_from_struct(@__f18_dbfs[_key])
  endif

next

return .t.


// -------------------------------------------------------------
// -------------------------------------------------------------
function set_a_dbf_sifarnici()

 set_a_dbf_sifarnik("f18_rules"  , "FMKRULES"  , F_FMKRULES   )
 set_a_dbf_sifarnik("ops"        , "OPS"       , F_OPS        )
 set_a_dbf_sifarnik("banke"      , "BANKE"     , F_BANKE      )
 set_a_dbf_sifarnik("refer"      , "REFER"     , F_REFER      )
 set_a_dbf_sifarnik("partn"      , "PARTN"     , F_PARTN      )
 set_a_dbf_sifarnik("tnal"       , "TNAL"      , F_TNAL       )
 set_a_dbf_sifarnik("trfp"       , "TRFP"      , F_TRFP       )
 set_a_dbf_sifarnik("trfp2"      , "TRFP2"     , F_TRFP2      )
 set_a_dbf_sifarnik("trfp3"      , "TRFP3"     , F_TRFP3      )

 set_a_dbf_sifarnik("ld_radn"    , "RADN"      , F_RADN       )
 set_a_dbf_sifarnik("ld_rj"      , "LD_RJ"     , F_LD_RJ      )
 set_a_dbf_sifarnik("por"        , "POR"       , F_POR        )
 set_a_dbf_sifarnik("dopr"       , "DOPR"      , F_DOPR       )
 set_a_dbf_sifarnik("tippr"      , "TIPPR"     , F_TIPPR      )
 set_a_dbf_sifarnik("tippr2"     , "TIPPR2"    , F_TIPPR2     )
 set_a_dbf_sifarnik("kred"       , "KRED"      , F_KRED       )
 set_a_dbf_sifarnik("strspr"     , "STRSPR"    , F_STRSPR     )
 set_a_dbf_sifarnik("vposla"     , "VPOSLA"    , F_VPOSLA     )
 set_a_dbf_sifarnik("strspr"     , "STRSPR"    , F_STRSPR     )
 set_a_dbf_sifarnik("kbenef"     , "KBENEF"    , F_KBENEF     )
 set_a_dbf_sifarnik("rj"         , "RJ"        , F_RJ         )


return


// ------------------------------------
// dodaj stavku u f18_dbfs
// ------------------------------------
function f18_dbfs_add(_tbl, _item)

__f18_dbfs[_tbl] := _item

return .t.



function f18_dbfs()
return __f18_dbfs


// ----------------------------------------
// temp tabele - semafori se ne koriste
// ----------------------------------------
function set_a_dbf_temp(table, alias, wa)
local _item

_item := hb_hash()

_item["alias"] := alias
_item["table"] := table
_item["wa"]    := wa

_item["temp"]  := .t.

f18_dbfs_add(table, @_item)
return .t.


// ----------------------------------------------------
// sifarnici su svi na isti fol
// ----------------------------------------------------
function set_a_dbf_sifarnik(dbf_table, alias, wa, rec)
local _alg, _item

_item := hb_hash()

_item["alias"] := alias
_item["table"] := dbf_table
_item["wa"]    := wa

_item["temp"]  := .f.

_item["algoritam"] := {}

_alg := hb_hash()

if rec == NIL
   _alg["dbf_key_fields"] := {"id"}
   _alg["dbf_tag"]        := "ID"
   _alg["sql_in" ]        := "id"
   _alg["dbf_key_block" ] := {|| field->id }

else
   _alg["dbf_key_fields"] := rec["dbf_key_fields"]
   _alg["dbf_tag"]        := rec["dbf_tag"]
   _alg["sql_in" ]        := rec["sql_in"]
   _alg["dbf_key_block" ] := rec["dbf_key_block"]
endif


AADD(_item["algoritam"], _alg)

   
f18_dbfs_add(dbf_table, @_item)
return .t.


// -------------------------------------------------------
// tbl - dbf_table ili alias
//
// _only_basic_params - samo table, alias, wa
// -------------------------------------------------------
function get_a_dbf_rec(tbl, _only_basic_params)
local _rec, _keys, _dbf_tbl, _key

_dbf_tbl := "x"

if _only_basic_params == NIL
   _only_basic_params = .f.
endif

if VALTYPE(__f18_dbfs) <> "H"
   Alert(RECI_GDJE_SAM + " " + tbl + "__f18_dbfs nije inicijalizirana")
endif

if HB_HHASKEY(__f18_dbfs, tbl)
   _dbf_tbl := tbl

else
   // probaj preko aliasa
   for each _key IN __f18_dbfs:Keys
      if VALTYPE(tbl) == "N"

        // zadana je workarea
        if __f18_dbfs[_key]["wa"] == tbl
            _dbf_tbl := _key
        endif

      else 

        if __f18_dbfs[_key]["alias"] == UPPER(tbl)
            _dbf_tbl := _key
        endif

      endif    
   next 
endif

if HB_HHASKEY(__f18_dbfs, _dbf_tbl)
    // preferirani set parametara
    _rec := __f18_dbfs[_dbf_tbl]
else
    // legacy
    _rec := get_a_dbf_rec_legacy(tbl)
endif


if _only_basic_params
   return _rec
endif

// nije zadano - ja cu na osnovu strukture dbf-a
//  napraviti dbf_fields
if !HB_HHASKEY(_rec, "dbf_fields")
   set_dbf_fields_from_struct(@_rec)
endif

if !HB_HHASKEY(_rec, "sql_order")
    if HB_HHASKEY(_rec, "algoritam") 
         _rec["sql_order"] := sql_order_from_key_fields(_rec["algoritam"][1]["dbf_key_fields"])
    endif
endif



return _rec

// ----------------------------------------------
// setujem "sql_order" hash na osnovu 
// gaDBFS[_pos][6]
// rec["dbf_fields"]
// ----------------------------------------------
function sql_order_from_key_fields(key_fields)
local _i, _len
local _sql_order

// primjer: key_fields = {{"godina", 4}, "idrj", {"mjesec", 2}

_len := LEN(key_fields)

_sql_order := ""
for _i := 1 to _len

   if VALTYPE(key_fields[_i]) == "A"
      _sql_order += key_fields[_i, 1]
   else
      _sql_order += key_fields[_i]
   endif

   if _i < _len
      _sql_order += ","
   endif
next
   
return _sql_order    
   

// ----------------------------------------------
// setujem "dbf_fields" hash na osnovu stukture
// dbf-a 
// rec["dbf_fields"]
// ----------------------------------------------
function set_dbf_fields_from_struct(rec)
local _struct, _i
local _opened := .t.
local _fields :={}

if rec["temp"]
   // ovi mi podaci ne trebaju za temp tabele
   return .f.
endif

SELECT (rec["wa"])

if !used()

    begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }
            dbUseArea( .f., "DBFCDX", my_home() + rec["table"], rec["alias"], .t. , .f.)
    
    recover using _err

            _msg := "ERR-1: " + _err:description + ": tbl:" + my_home() + rec["table"] + " alias:" + rec["alias"] + " se ne moze otvoriti ?!"
            Alert(_msg)
                
            rec["dbf_fields"] := NIL
            return
    end sequence
    _opened := .t.
endif

_struct := DBSTRUCT()

for _i := 1 to LEN(_struct)
   AADD(_fields, LOWER(_struct[_i, 1]))
next

rec["dbf_fields"] := _fields

if _opened
   USE
endif

return .t.


