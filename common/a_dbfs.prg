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

function f18_dbfs()
return __f18_dbfs

// -------------------------------------------------------
// tbl - dbf_table ili alias
// -------------------------------------------------------
function get_a_dbf_rec(tbl)
local _rec, _keys, _dbf_tbl, _key

_dbf_tbl := "x"

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


// nije zadano - ja cu na osnovu strukture dbf-a
//  napraviti dbf_fields
if !HB_HHASKEY(_rec, "dbf_fields")
   set_dbf_fields_from_struct(@_rec)
endif

return _rec

// ------------------------------------------------
// na osnovu aliasa daj mi WA, dbf table_name
//
// moze se proslijediti: F_SUBAN, "SUBAN", "fin_suban"
//
// ret["wa"] = F_SUBAN, ret["alias"] = "SUBAN", 
// ret["table"] = "fin_suban"
// ---------------------------------------------------
function get_a_dbf_rec_legacy(x_alias)
local _pos
local _ret := hb_hash()


// temporary table nema semafora
_ret["temp"]     := .f.

_ret["dbf_fields"]:= NIL
_ret["sql_order"] := NIL

_ret["wa"]    := NIL
_ret["alias"] := NIL
_ret["table"] := NIL

if VALTYPE(x_alias) == "N"
   // F_SUBAN

   _ret["wa"] := x_alias
   _pos := ASCAN(gaDBFs,  { |x|  x[1] == x_alias} )
 
   if _pos < 1
           Alert("ovo nije smjelo da se desi f18_dbf_alias ?: " + table)
           return _ret
   endif
   
else

   // /home/test/suban.dbf => suban
   _pos := ASCAN(gaDBFs,  { |x|  x[2]==UPPER(FILEBASE(x_alias))} )
   if _pos < 1

       _pos := ASCAN(gaDBFs,  { |x|  x[3]==x_alias} )
        
       if _pos < 1
           Alert("ovo nije smjelo da se desi f18_dbf_alias ?: " + x_alias)
          _ret["wa"]    := NIL
          _ret["alias"] := NIL
          _ret["table"] := NIL
          return _ret
       endif
           
   endif
   
endif

_ret["wa"]             := gaDBFs[_pos,  1]
_ret["alias"]          := gaDBFs[_pos,  2]
_ret["table"]          := gaDBFs[_pos,  3]

if LEN(gaDBFs[_pos]) > 5
   _ret["dbf_key_fields"] := gaDBFs[_pos,  6]
endif

if LEN(gaDBFs[_pos]) > 8
  _ret["dbf_fields"]   := gaDBFs[_pos,  9]
  _ret["sql_order"]    := gaDBFs[_pos, 10]
endif

// nije zadano - ja cu na osnovu strukture dbf-a
//  napraviti dbf_fields
if _ret["dbf_fields"] == NIL
  set_dbf_fields_from_struct(@_ret)
endif

// {id, naz} => "id, naz"
if _ret["sql_order"] == NIL 
   if  LEN(gaDBFs[_pos]) > 5
       _ret["sql_order"] := sql_order_from_key_fields(gaDBFs[_pos, 6])
   else
       // onda moze biti samo tabela sifarnik, bazirana na id-u
       _ret["sql_order"] := "id"
   endif
endif

// moze li ovo ?hernad?
_ret["sql_where_block"] := { |x| sql_where_block( _ret["table"], x) }
 
if LEN(gaDBFs[_pos]) < 4
   _ret["temp"] := .t.
else
   _ret["temp"] := .f.
endif

return _ret

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

SELECT (rec["wa"])

if !used()
    dbUseArea( .f., "DBFCDX", my_home() + rec["table"], rec["alias"], .t. , .f.)
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


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_suban()
local _alg, _tbl 

_tbl := "fin_suban"

__f18_dbfs[_tbl] := hb_hash()

__f18_dbfs[_tbl]["alias"] := "SUBAN"
__f18_dbfs[_tbl]["table"] := _tbl
__f18_dbfs[_tbl]["wa"]    := F_SUBAN

// temporary tabela - nema semafora
__f18_dbfs[_tbl]["temp"]  := .f.



__f18_dbfs[_tbl]["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idvn + field->brnal + field->rbr }
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal", "rbr" } 
_alg["sql_in"]         := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 4)"
_alg["dbf_tag"]        := "4"
AADD(__f18_dbfs[_tbl]["algoritam"], _alg)


// algoritam 2 - dokument
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idvn + field->brnal }
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal" } 
_alg["sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]    := "4"
AADD(__f18_dbfs[_tbl]["algoritam"], _alg)

// za full sinhronizaciju trebamo jedinstveni poredak
__f18_dbfs[_tbl]["sql_order"] := "idfirma, idvn, brnal, rbr"

return .t.

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_anal()
local _alg, _tbl

_tbl := "fin_anal"

__f18_dbfs[_tbl] := hb_hash()

__f18_dbfs[_tbl]["alias"] := "ANAL"
__f18_dbfs[_tbl]["wa"]    := F_ANAL
__f18_dbfs[_tbl]["table"] := _tbl
// temporary tabela - nema semafora
__f18_dbfs[_tbl]["temp"]  := .f.

__f18_dbfs[_tbl]["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"] := {|| field->idfirma + field->idvn + field->brnal + field->rbr } 
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal", "rbr" } 
_alg["sql_in"]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 3)"
_alg["dbf_tag"]   := "2"
AADD(__f18_dbfs[_tbl]["algoritam"], _alg)


// algoritam 2 - dokument
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idvn + field->brnal }
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal" } 
_alg["sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]    := "2"
AADD(__f18_dbfs[_tbl]["algoritam"], _alg)

// za full sinhronizaciju trebamo jedinstveni poredak
__f18_dbfs[_tbl]["sql_order"] := "idfirma, idvn, brnal, rbr"

return .t.

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_sint()
local _alg, _tbl

_tbl := "fin_sint"

__f18_dbfs[_tbl] := hb_hash()

__f18_dbfs[_tbl]["alias"] := "SINT"
__f18_dbfs[_tbl]["table"] := _tbl
__f18_dbfs[_tbl]["wa"]    := F_SINT

// temporary tabela - nema semafora
__f18_dbfs[_tbl]["temp"]  := .f.


__f18_dbfs[_tbl]["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"] := {|| field->idfirma + field->idvn + field->brnal + field->rbr } 
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal", "rbr" } 
_alg["sql_in"]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 3)"
_alg["dbf_tag"]   := "2"
AADD(__f18_dbfs[_tbl]["algoritam"], _alg)


// algoritam 2 - dokument
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"]  := {|| field->idfirma + field->idvn + field->brnal }
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal" } 
_alg["sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]    := "2"
AADD(__f18_dbfs[_tbl]["algoritam"], _alg)

// za full sinhronizaciju trebamo jedinstveni poredak
__f18_dbfs[_tbl]["sql_order"] := "idfirma, idvn, brnal, rbr"

return .t.


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function set_a_dbf_fin_nalog()
local _alg, _tbl

_tbl := "fin_nalog"

__f18_dbfs[_tbl] := hb_hash()

__f18_dbfs[_tbl]["alias"] := "NALOG"
__f18_dbfs[_tbl]["wa"]    := F_NALOG
__f18_dbfs[_tbl]["table"] := _tbl

// temporary tabela - nema semafora
__f18_dbfs[_tbl]["temp"]  := .f.


__f18_dbfs[_tbl]["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block" ] := {|| field->idfirma + field->idvn + field->brnal} 
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal"} 
_alg["sql_in"]         := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]        := "1"
AADD(__f18_dbfs[_tbl]["algoritam"], _alg)

__f18_dbfs[_tbl]["sql_order"] := "idfirma, idvn, brnal"

return .t.



// -------------------------------
// -------------------------------
function set_a_dbfs()
local _dbf_fields, _sql_order

public gaDbfs := {}

__f18_dbfs := hb_hash()

set_a_dbf_fin_suban()
set_a_dbf_fin_anal()
set_a_dbf_fin_sint()
set_a_dbf_fin_nalog()

set_a_dbfs_legacy()


return

