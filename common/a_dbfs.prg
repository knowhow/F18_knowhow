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

if HB_HHASKEY(__f18_dbfs, tbl)
    // preferirani set parametara
    _rec := f18_dbfs()[tbl]
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
_ret["dbf_key_fields"] := gaDBFs[_pos, 6]
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

_len := LEN(key_fields)

_sql_order := ""
for _i := 1 to _len
   _sql_order += key_fields[_i]

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

// temporary tabela - nema semafora
__f18_dbfs[_tbl]["temp"]  := .f.


__f18_dbfs[_tbl]["algoritam"] := {}

// algoritam 1 - default
// -------------------------------------------------------------------------------
_alg := hb_hash()
_alg["dbf_key_block"] := {|| field->idfirma + field->idvn + field->brnal + field->rbr } 
_alg["dbf_key_fields"] := { "idfirma", "idvn", "brnal", "rbr" } 
_alg["sql_in"]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
_alg["dbf_tag"]   := "1"
AADD(__f18_dbfs[_tbl]["algoritam"], _alg)

__f18_dbfs[_tbl]["sql_order"] := "idfirma, idvn, brnal"

return .t.



// ------------------
// legacy !!!!
// ------------------
function set_a_dbfs()
local _dbf_fields, _sql_order

public gaDbfs := {}

__f18_dbfs := hb_hash()

set_a_dbf_fin_suban()
set_a_dbf_fin_anal()
set_a_dbf_fin_sint()
set_a_dbf_fin_nalog()


// ---- legacy 

_dbf_fields := NIL

/*
//{ "idfirma", "idvn", "brnal", "rbr", "datdok", "datval", "opis", "idpartner", "idkonto", "brdok", "d_p", "iznosbhd", "iznosdem", "k1", "k2", "k3", "k4", "m1", "m2", "idrj", "funk", "fond", "otvst", "idtipdok" }
_sql_order := "idfirma, idvn, brnal, rbr"

AADD( gaDbfs, { F_SUBAN  ,  "SUBAN"   , "fin_suban" ,;  // 1, 2, 3
   {|alg| fin_suban_from_sql_server(alg) }, "IDS" , ;   // 4, 5
   {"idfirma", "idvn", "brnal", "rbr" }, { |x| sql_where_block("fin_suban", x) }, "4", ; // 6, 7, 8
   _dbf_fields, _sql_order  ; // 9, 10
})


// fin_anal: TAG "2", "idFirma+IdVN+BrNal+Rbr"
AADD( gaDbfs, { F_ANAL   ,  "ANAL"    , "fin_anal",   ;
      {|alg| fin_anal_from_sql_server(alg)  }, "IDS", ;
      {"idfirma", "idvn", "brnal", "rbr"}, {|x| sql_where_block("fin_anal", x) }, "2" ;
      })


// fin_sint: TAG "2", "idFirma+IdVN+BrNal+Rbr"

AADD( gaDbfs, { F_SINT   ,  "SINT"    , "fin_sint",    {|alg| fin_sint_from_sql_server(alg)  }, "IDS",  {"idfirma", "idvn", "brnal", "rbr"}, {|x| sql_where_block("fin_sint", x) }, "2" }  )
// fin_nalog: tag "1", "IdFirma+IdVn+BrNal"


AADD( gaDbfs, { F_NALOG  ,  "NALOG"   , "fin_nalog",   {|alg| fin_nalog_from_sql_server(alg) }, "IDS",  { "idfirma", "idvn", "brnal" }, {|x| sql_where_block("fin_nalog", x) }, "1" })

*/


// fin sifrarnici
AADD( gaDbfs, { F_OPS      , "OPS"       , "ops"       , { |param| opstine_from_sql_server( param )   }  , "IDS" } )
AADD( gaDbfs, { F_BANKE    , "BANKE"     , "banke"     , { |param| banke_from_sql_server( param )     }  , "IDS" } )
AADD( gaDbfs, { F_FMKRULES , "FMKRULES"  , "f18_rules" , { |param| f18_rules_from_sql_server( param ) }  , "IDS" } )


AADD( gaDbfs, { F_FIN_PRIPR  ,  "FIN_PRIPR"   , "fin_pripr"  } )
AADD( gaDbfs, { F_FIN_FIPRIPR , "FIN_PRIPR"   , "fin_pripr"  } )
AADD( gaDbfs, { F_BBKLAS ,  "BBKLAS"  , "fin_bblkas"  } )
AADD( gaDbfs, { F_IOS    ,  "IOS"     , "fin_ios"  } )
AADD( gaDbfs, { F_OSTAV    ,  "ostav"     , "fin_ostav"  } )
AADD( gaDbfs, { F_PNALOG ,  "PNALOG"  , "fin_pnalog"  } )
AADD( gaDbfs, { F_PSUBAN ,  "PSUBAN"  , "fin_psuban"  } )
AADD( gaDbfs, { F_PANAL  ,  "PANAL"   , "fin_panal"  } )
AADD( gaDbfs, { F_PSINT  ,  "PSINT"   , "fin_psint"  } )
AADD( gaDbfs, { F_FIN_PRIPRRP,  "FIN_PRIPRRP" , "fin_priprrp"  } )
AADD( gaDbfs, { F_OSTAV  ,  "OSTAV"   , "fin_ostav"   } )
AADD( gaDbfs, { F_OSUBAN ,  "OSUBAN"  , "fin_osuban"  } )
AADD( gaDbfs, { F__KONTO ,  "_KONTO"  , "fin__konto"  } )
AADD( gaDbfs, { F__PARTN ,  "_PARTN"  , "fin__partn"  } )
AADD( gaDbfs, { F_KUF    ,  "FIN_KUF" , "fin_kuf"     } )
AADD( gaDbfs, { F_KIF    ,  "FIN_KIF" , "fin_kif"     } )
AADD( gaDbfs, { F_TEMP12 ,  "TEMP12" , "temp12"     } )
AADD( gaDbfs, { F_TEMP60 ,  "TEMP60" , "temp60"     } )


AADD( gaDbfs, { F_FUNK   ,  "FUNK"    , "fin_funk"    } )
AADD( gaDbfs, { F_BUDZET ,  "BUDZET"  , "fin_budzet"  } )
AADD( gaDbfs, { F_PAREK  ,  "PAREK"   , "fin_parek"   } )
AADD( gaDbfs, { F_FOND   ,  "FOND"    , "fin_fond"    } )
AADD( gaDbfs, { F_KONIZ  ,  "KONIZ"   , "fin_koniz"   } )
AADD( gaDbfs, { F_IZVJE  ,  "IZVJE"   , "fin_izvje"   } )
AADD( gaDbfs, { F_ZAGLI  ,  "ZAGLI"   , "fin_zagli"   } )
AADD( gaDbfs, { F_KOLIZ  ,  "KOLIZ"   , "fin_koliz"   } )
AADD( gaDbfs, { F_BUIZ   ,  "BUIZ"    , "fin_buiz"    } )

// parametri
AADD( gaDbfs, { F_PARAMS  ,  "PARAMS"   , "params"  } )
AADD( gaDbfs, { F_GPARAMS , "GPARAMS"  , "gparams"  } )
AADD( gaDbfs, { F_KPARAMS , "KPARAMS"  , "kparams"  } )
AADD( gaDbfs, { F_SECUR  , "SECUR"  , "secur"  } )

// pomocne tabele
AADD( gaDbfs, {  F_POM       , "POM"    , "pom"  } )
AADD( gaDbfs, {  F_POM2      , "POM2"   , "pom2"  } )

// sifrarnici
AADD( gaDbfs, { F_TOKVAL  , "TOKVAL"  , "tokval"  } )

AADD( gaDbfs, { F_SIFK  , "SIFK"  , "sifk", { |param| sifk_from_sql_server(param) }, "IDS", {"id", "oznaka"}, { |x| sql_where_block( "sifk", x ) }, "id2" } )
AADD( gaDbfs, { F_SIFV , "SIFV"  , "sifv", { | param | sifv_from_sql_server( param ) }, "IDS", {"id", "oznaka", "idsif", "naz"}, { |x| sql_where_block("sifv", x) }, "id" })
  
// ROBA
AADD( gaDbfs, { F_ROBA     ,  "ROBA"    , "roba"    ,     ;  // 1 2 3
      { | param | roba_from_sql_server(param)   }  , "IDS";  // 4 5
    })

AADD( gaDbfs, { F_SAST     ,  "SAST"    , "sast"    , { | param | sast_from_sql_server(param)    }  , "IDS", {"id", "id2"}, { |x|  sql_where_block( "sast", x ) }, "idrbr" } )
AADD( gaDbfs, { F_TARIFA   ,  "TARIFA"  , "tarifa"  , { | param | tarifa_from_sql_server(param)  }  , "IDS" } )
AADD( gaDbfs, { F_KONCIJ   ,  "KONCIJ"  , "koncij"  , { | param | koncij_from_sql_server(param)  }  , "IDS" } )

AADD( gaDbfs, { F_BARKOD   , "BARKOD"  , "barkod"  } )



AADD( gaDbfs, { F_STRINGS  , "STRINGS"  , "strings"  } )
AADD( gaDbfs, { F_RNAL     , "RNAL"  , "rnal"  } )

// ? koje funkcije ovo koriste
AADD( gaDbfs, { F_DEST     , "DEST"    , "dest", { | param | dest_from_sql_server( param ) }, "IDS" } )

// ?
AADD( gaDbfs, { F_LOKAL    , "LOKAL"  , "lokal", { | param | lokal_from_sql_server( param ) }, "IDS" } )

AADD( gaDbfs, { F_DOKSRC   , "DOKSRC"  , "doksrc"  } )
AADD( gaDbfs, { F_P_DOKSRC , "P_DOKSRC"  , "p_doksrc"  } )
AADD( gaDbfs, { F_RELATION , "RELATION"  , "relation"  } )
AADD( gaDbfs, { F_RULES , "RULES"  , "rules"  } )
AADD( gaDbfs, { F_P_UPDATE , "P_UPDATE"  , "p_update"  } )
AADD( gaDbfs, { F__ROBA , "_ROBA"  , "_roba"  } )

AADD( gaDbfs, { F_VRSTEP , "VRSTEP"  , "vrstep", {| param | vrstep_from_sql_server( param ) }, "IDS"  } )
AADD( gaDbfs, { F_RJ     ,  "RJ"      , "rj", { | param | rj_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_TDOK   ,  "TDOK"    , "tdok", { | param | tdok_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_KONTO  ,  "KONTO"   , "konto", {| param | konto_from_sql_server(param) }, "IDS" } )
AADD( gaDbfs, { F_VPRIH  ,  "VPRIH"   , "vpprih"   } )

AADD( gaDbfs, { F_PARTN  ,  "PARTN"   , "partn", {| param | partn_from_sql_server(param) }, "IDS" } )

AADD( gaDbfs, { F_TNAL   ,  "TNAL"    , "tnal", { | param | tnal_from_sql_server( param ) }, "IDS" } )



AADD( gaDbfs, { F_PKONTO ,  "PKONTO"  , "pkonto", { | param | pkonto_from_sql_server(param) }, "IDS" } )
AADD( gaDbfs, { F_VALUTE ,  "VALUTE"  , "valute", { | param | valute_from_sql_server( param ) }, "IDS" } )

AADD( gaDbfs, { F_TRFP2  ,  "TRFP2"   , "trfp2", { | param | trfp2_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_TRFP3  ,  "TRFP3"   , "trfp3", { | param | trfp3_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_VKSG   ,  "VKSG"    , "vksg"   } )
AADD( gaDbfs, { F_ULIMIT ,  "ULIMIT"  , "ulimit"  } )

// r_export
AADD( gaDbfs, { F_R_EXP ,  "R_EXPORT"  , "r_export"  } )

// finmat
AADD( gaDbfs, { F_FINMAT ,  "FINMAT"  , "fin_mat"  } )

//modul KALK
AADD( gaDbfs, { F_KALK        , "KALK"         , "kalk_kalk" , {|alg| kalk_kalk_from_sql_server(alg) }, "IDS", {"idfirma", "idvd", "brdok", "rbr"}, {|x| sql_where_block("kalk_kalk", x) }, "1" })
AADD( gaDbfs, { F_KALK_DOKS   , "KALK_DOKS"    , "kalk_doks" , {|alg| kalk_doks_from_sql_server(alg) }, "IDS", {"idfirma", "idvd", "brdok"}, {|x| sql_where_block("kalk_doks", x) }, "1" })
AADD( gaDbfs, { F_KALK_DOKS2  , "KALK_DOKS2"   , "kalk_doks2", { |alg| kalk_doks2_from_sql_server(alg) }, "IDS", {"idfirma", "idvd", "brdok"}, {|x| sql_where_block("kalk_doks2", x) }, "1" })

// KALK sifrarnik
AADD( gaDbfs, { F_TRFP ,       "TRFP"  , "trfp",   { | param | trfp_from_sql_server( param ) }, "IDS" } )

AADD( gaDbfs, { F_KALKS  ,"KALKS" , "kalk_kalks"    } )
AADD( gaDbfs, { F__KALK  ,"_KALK" , "_kalk_kalk"    } )
AADD( gaDbfs, { F_KALK_PRIPR  ,"KALK_PRIPR"   , "kalk_pripr"    } )
AADD( gaDbfs, { F_KALK_PRIPR2  ,"KALK_PRIPR2"  , "kalk_pripr2"   } )
AADD( gaDbfs, { F_KALK_PRIPR9  ,"KALK_PRIPR9"  , "kalk_pripr9"   } )
AADD( gaDbfs, { F_PORMP       ,"PORMP"        , "kalk_pormp"     } )

AADD( gaDbfs, { F_DOKSRC      , "KALK_DOKSRC"  , "kalk_doksrc"    } )
AADD( gaDbfs, { F_P_DOKSRC    , "P_KALK_DOKSRC", "p_kalk_doksrc"   } )
AADD( gaDbfs, { F_PPPROD      , "PPPROD"  , "kalk_ppprod"    } )
AADD( gaDbfs, { F_OBJEKTI     , "OBJEKTI" , "kalk_objekti"     } )
AADD( gaDbfs, { F_POBJEKTI    , "POBJEKTI" , "kalk_pobjekti"     } )
AADD( gaDbfs, { F_PRODNC      , "PRODNC"  , "kalk_prodnc"     } )
AADD( gaDbfs, { F_RVRSTA      , "RVRSTA"  , "kalk_rvrsta"     } )
AADD( gaDbfs, { F_CACHE       , "CACHE"      , "kalk_cache"     } )
AADD( gaDbfs, { F_PRIPT       , "PRIPT"      , "kalk_pript"     } )
AADD( gaDbfs, { F_REKAP1      , "REKAP1"      , "kalk_rekap1"     } )
AADD( gaDbfs, { F_REKAP2      , "REKAP2"      , "kalk_rekap2"     } )
AADD( gaDbfs, { F_REKA22      , "REKA22"      , "kalk_reka22"     } )
AADD( gaDbfs, { F_R_UIO       , "R_UIO"       , "kalk_r_uio"     } )
AADD( gaDbfs, { F_RPT_TMP     , "RPT_TMP"     , "kalk_rpt_tmp"     } )

// modul FAKT
AADD( gaDbfs, { F_PRIPR       , "FAKT_PRIPR"    , "fakt_pripr"     } )
AADD( gaDbfs, { F_PRIPR2      , "FAKT_PRIPR2"   , "fakt_pripr2"    } )
AADD( gaDbfs, { F_PRIPR2      , "FAKT_PRIPR9"   , "fakt_pripr9"    } )
AADD( gaDbfs, { F_FDEVICE     , "FDEVICE"       , "fiscal_fdevice" } )
AADD( gaDbfs, { F_PORMP       , "PORMP"         , "fakt_pormp"     } )
AADD( gaDbfs, { F__ROBA       , "_ROBA"         , "_fakt_roba"     } )
AADD( gaDbfs, { F__PARTN      , "_PARTN"        , "_fakt_partn"    } )
AADD( gaDbfs, { F_LOGK        , "LOGK"          , "fakt_logk"      } )
AADD( gaDbfs, { F_LOGKD       , "LOGKD"         , "fakt_logkd"     } )
AADD( gaDbfs, { F_BARKOD      , "BARKOD"        , "fakt_barkod"    } )
AADD( gaDbfs, { F_RJ          , "RJ"            , "fakt_rj"        } )
AADD( gaDbfs, { F_UPL         , "UPL"           , "fakt_upl"       } )
AADD( gaDbfs, { F_REFER       , "REFER"         , "refer", {|alg| refer_from_sql_server(alg)}, "IDS" } )

AADD( gaDbfs, { F_FAKT        , "FAKT"          , "fakt_fakt"      , { |alg| fakt_fakt_from_sql_server(alg) }  , "IDS", {"idfirma", "idtipdok", "brdok", "rbr"}, {|x| sql_where_block("fakt_fakt", x) }, "1" } )

AADD( gaDbfs, { F_FAKT_DOKS   , "FAKT_DOKS"     , "fakt_doks"      , { |alg| fakt_doks_from_sql_server(alg) }  , "IDS", {"idfirma", "idtipdok", "brdok"}, {|x| sql_where_block("fakt_doks", x) }, "1" } )

AADD( gaDbfs, { F_FAKT_DOKS2  , "FAKT_DOKS2"    , "fakt_doks2"     , { |alg| fakt_doks2_from_sql_server(alg) } , "IDS", {"idfirma", "idtipdok", "brdok"}, {|x| sql_where_block("fakt_doks2", x) }, "1" } )

AADD( gaDbfs, { F_FTXT        , "FTXT"          , "fakt_ftxt"      , { |alg| ftxt_from_sql_server(alg) } , "IDS", {"id"}, {|x| sql_where_block("fakt_ftxt", x)}, "ID" } )
AADD( gaDbfs, { F_FAKT   ,"FAKT_S_PRIPR", "fakt_pripr"     } )
AADD( gaDbfs, { F__FAKT  ,"_FAKT"   , "_fakt_fakt"    } )
AADD( gaDbfs, { F_FAPRIPR,"FAKT_faPRIPR"   , "fakt_fapripr"    } )
AADD( gaDbfs, { F_UGOV   ,"UGOV"    , "fakt_ugov", { | alg | ugov_from_sql_server( alg ) }, "IDS", {"id", "idpartner"}, {|x| sql_where_block("fakt_ugov", x)}, "ID" } )
AADD( gaDbfs, { F_RUGOV  ,"RUGOV"   , "fakt_rugov", { | alg | rugov_from_sql_server( alg ) }, "IDS", {"id", "idroba"}, {|x| sql_where_block("fakt_rugov", x)}, "ID" } )
AADD( gaDbfs, { F_GEN_UG ,"GEN_UG"  , "fakt_gen_ug", { | alg | gen_ug_from_sql_server( alg ) }, "IDS", {"dat_obr"}, {|x| sql_where_block("fakt_gen_ug", x)}, "DAT_OBR" } )
AADD( gaDbfs, { F_G_UG_P, "GEN_UG_P", "fakt_gen_ug_p", { | alg | gen_ug_p_from_sql_server( alg ) }, "IDS", {"dat_obr", "idpartner", "id_ugov"}, {|x| sql_where_block("fakt_gen_ug_p", x)}, "DAT_OBR" } )
AADD( gaDbfs, { F_RELAC  ,"RELAC"   , "fakt_relac"     } ) 
AADD( gaDbfs, { F_VOZILA ,"VOZILA"  , "fakt_vozila"     } )
AADD( gaDbfs, { F_KALPOS ,"KALPOS"  , "fakt_kalpos"     } )
AADD( gaDbfs, { F_DRN ,   "DRN"     , "dracun"     } )
AADD( gaDbfs, { F_RN ,   "RN"     , "racun"     } )
AADD( gaDbfs, { F_DRNTEXT ,   "DRNTEXT"     , "dracuntext"     } )

// modul RNAL
AADD(gaDBFs, { F__DOCS, "_DOCS", "_rnal_docs"  } )
AADD(gaDBFs, { F__DOC_IT, "_DOC_IT", "_rnal_doc_it"  } )
AADD(gaDBFs, { F__DOC_IT2, "_DOC_IT2", "_rnal_doc_it2"  } )
AADD(gaDBFs, { F__DOC_OPS, "_DOC_OPS", "_rnal_doc_ops"  } )
AADD(gaDBFs, { F__FND_PAR, "_FND_PAR", "_fnd_par" } )

AADD(gaDBFs, { F_T_DOCIT, "T_DOCIT", "rnal_t_docit"  } )
AADD(gaDBFs, { F_T_DOCIT2, "T_DOCIT2", "rnal_t_docit2"  } )
AADD(gaDBFs, { F_T_DOCOP, "T_DOCOP", "rnal_t_docop"  } )
AADD(gaDBFs, { F_T_PARS, "T_PARS", "rnal_t_pars"  } )

AADD(gaDBFs, { F_DOCS, "DOCS", "rnal_docs", {|alg| rnal_docs_from_sql_server( alg ) }, "IDS" } )
AADD(gaDBFs, { F_DOC_IT, "DOC_IT", "rnal_doc_it", {|alg| rnal_doc_it_from_sql_server(alg) }, "IDS" } )
AADD(gaDBFs, { F_DOC_IT2, "DOC_IT2", "rnal_doc_it2", {|alg| rnal_doc_it2_from_sql_server(alg) }, "IDS"  } )
AADD(gaDBFs, { F_DOC_OPS, "DOC_OPS", "rnal_doc_ops", {|alg| rnal_doc_ops_from_sql_server(alg) }, "IDS"  } )
AADD(gaDBFs, { F_DOC_LOG, "DOC_LOG", "rnal_doc_log", {|alg| rnal_doc_ops_from_sql_server(alg) }, "IDS"  } )
AADD(gaDBFs, { F_DOC_LIT, "DOC_LIT", "rnal_doc_lit", {|alg| rnal_doc_lit_from_sql_server(alg) }, "IDS"  } )

AADD(gaDBFs, { F_AOPS, "AOPS", "rnal_aops", {|alg| rnal_aops_from_sql_server(alg) }, "IDS", { {"aop_id", 10} }, {|x| "AOP_ID=" + STR(x["aop_id"], 10)  }, "1" } )
AADD(gaDBFs, { F_AOPS_ATT, "AOPS_ATT", "rnal_aops_att", {|alg| rnal_aops_att_from_sql_server(alg) }, "IDS", { {"aop_id", 10}, {"aop_att_id", 10} }, {|x| "AOP_ID=" + STR(x["aop_id"], 10) + " AND AOP_ATT_ID=" + STR( x["aop_att_id"], 10) }, "2" } )
AADD(gaDBFs, { F_E_GROUPS, "E_GROUPS", "rnal_e_groups", {|alg| rnal_e_groups_from_sql_server(alg) }, "IDS", { { "e_gr_id", 10 } }, {|x| "E_GR_ID=" + STR( x["e_gr_id"], 10) }, "1" } )
AADD(gaDBFs, { F_E_GR_ATT, "E_GR_ATT", "rnal_e_gr_att", {|alg| rnal_e_gr_att_from_sql_server(alg) }, "IDS", { { "e_gr_id", 10 }, "e_gr_at_re", { "e_gr_at_id", 10 } }, {|x| "E_GR_ID=" + STR( x["e_gr_id"], 10) + " AND E_GR_AT_RE=" + _sql_quote( x["e_gr_at_re"])  + " AND E_GR_AT_ID=" + STR( x["e_gr_at_id"], 10) }, "2" } )
AADD(gaDBFs, { F_E_GR_VAL, "E_GR_VAL", "rnal_e_gr_val", {|alg| rnal_e_gr_val_from_sql_server(alg) }, "IDS", { { "e_gr_at_id", 10 }, { "e_gr_vl_id", 10 } }, {|x| "E_GR_AT_ID=" + STR( x["e_gr_at_id"], 10) + " AND E_GR_VL_ID=" + STR( x["e_gr_vl_id"], 10) }, "2" } )
AADD(gaDBFs, { F_ARTICLES, "ARTICLES", "rnal_articles", {|alg| rnal_articles_from_sql_server(alg) }, "IDS", { {"art_id", 10} }, {|x| "ART_ID=" + STR( x["art_id"], 10) }, "1" } )
AADD(gaDBFs, { F_ELEMENTS, "ELEMENTS", "rnal_elements", {|alg| rnal_elements_from_sql_server(alg) }, "IDS", { {"art_id", 10}, {"el_no", 4}, {"el_id", 10}, {"e_gr_id", 10} }, {|x| "ART_ID=" + STR( x["art_id"], 10) + " AND EL_NO=" + STR( x["el_no"], 4) + " AND EL_ID=" + STR( x["el_id"], 10) + " AND E_GR_ID=" + STR( x["e_gr_id"], 10 )  }, "1"  } )
AADD(gaDBFs, { F_E_AOPS, "E_AOPS", "rnal_e_aops", {|alg| rnal_e_aops_from_sql_server(alg) }, "IDS", { {"el_id", 10}, {"el_op_id", 10} }, {|x| "EL_ID=" + STR( x["el_id"], 10) + " ANDL EL_OP_ID=" + STR( x["el_op_id"], 10) }, "1" } )
AADD(gaDBFs, { F_E_ATT, "E_ATT", "rnal_e_att", {|alg| rnal_e_att_from_sql_server(alg) }, "IDS", { {"el_id", 10}, {"el_att_id", 10} }, {|x| "EL_ID=" + STR( x["el_id"], 10) + " AND EL_ATT_ID=" + STR( x["el_att_id"], 10) }, "1" } )
AADD(gaDBFs, { F_CUSTOMS, "CUSTOMS", "rnal_customs", {|alg| rnal_customs_from_sql_server(alg) }, "IDS", { {"cust_id", 10} }, {|x| "CUST_ID=" + STR(x["cust_id"], 10) }, "1" } )
AADD(gaDBFs, { F_CONTACTS, "CONTACTS", "rnal_contacts", {|alg| rnal_contacts_from_sql_server(alg) }, "IDS", { {"cust_id", 10}, {"cont_id", 10} }, {|x| "CUST_ID=" + STR( x["cust_id"], 10) + " AND CONT_ID=" + STR( x["cont_id"], 10)}, "2" } )
AADD(gaDBFs, { F_OBJECTS, "OBJECTS", "rnal_objects", {|alg| rnal_objects_from_sql_server(alg) }, "IDS", { {"obj_id", 10} }, {|x| "OBJ_ID=" + STR( x["obj_id"], 10) }, "1" } )
AADD(gaDBFs, { F_RAL, "RAL", "rnal_ral", {|alg| rnal_ral_from_sql_server(alg) }, "IDS", { {"id", 5}, {"gl_tick", 2} }, {|x| "ID=" + STR( x["id"], 10 ) + " AND GL_TICK=" + STR(x["gl_tick"], 2) }, "1" } )

// modul EPDV
AADD(gaDBFs, { F_P_KIF, "P_KIF", "p_epdv_kif"  } )
AADD(gaDBFs, { F_P_KUF, "P_KUF", "p_epdv_kuf"  } )
AADD(gaDBFs, { F_KUF, "KUF", "epdv_kuf", {|alg| epdv_kuf_from_sql_server(alg)}, "IDS", {"br_dok"}, {|x| sql_where_block("epdv_kuf", x) }, "BR_DOK" } )
AADD(gaDBFs, { F_KIF, "KIF", "epdv_kif", {|alg| epdv_kif_from_sql_server(alg)}, "IDS", {"br_dok"}, {|x| sql_where_block("epdv_kif", x) }, "BR_DOK" } )
AADD(gaDBFs, { F_PDV, "PDV", "epdv_pdv", {|alg| epdv_pdv_from_sql_server(alg)}, "IDS"  } )
AADD(gaDBFs, { F_SG_KIF, "SG_KIF", "epdv_sg_kif", {|alg| epdv_sg_kif_from_sql_server(alg)}, "IDS" } )
AADD(gaDBFs, { F_SG_KUF, "SG_KUF", "epdv_sg_kuf", {|alg| epdv_sg_kuf_from_sql_server(alg)}, "IDS" } )
AADD(gaDBFs, { F_R_KIF, "R_KIF", "epdv_r_kif"  } )
AADD(gaDBFs, { F_R_KUF, "R_KUF", "epdv_r_kuf"  } )
AADD(gaDBFs, { F_R_PDV, "R_PDV", "epdv_r_pdv"  } )
AADD(gaDBFs, { F_ANAL, "SUBAN_2", "suban_2"  } )

// modul LD

// "1","str(godina)+idrj+str(mjesec)+obr+idradn"
AADD(gaDBFs, { F_LD      , "LD"      , "ld_ld",    { |alg| ld_ld_from_sql_server(alg) }, "IDS", {{"godina", 4}, "idrj", {"mjesec", 2}, "obr", "idradn" },  { |x| sql_where_block("ld_ld", x) }, "1"})

// "2", "idradn + idkred + naosnovu + str(godina) + str(mjesec)"
AADD(gaDBFs, { F_RADKR  , "RADKR"   , "ld_radkr", { |alg| ld_radkr_from_sql_server(alg) }, "IDS", { "idradn", "idkred", "naosnovu", {"godina", 4}, {"mjesec", 2 }}, { |x| sql_where_block("ld_radkr", x) }, "2" })


//IF  lViseObr => TAG = "ID", index = "id+godina+obr" ;  !lViseObr => "ID", "id+godina"
AADD(gaDBFs, { F_PAROBR ,  "PAROBR"  , "ld_parobr",   { |alg| ld_parobr_from_sql_server(alg) }, "IDS", { "id", "godina"}, {|x| sql_where_block("ld_parobr", x)}, "ID" })

// "RJ" - "rj+STR(godina)+STR(mjesec)+status+obr"
AADD(gaDBFs, { F_OBRACUNI, "OBRACUNI", "ld_obracuni", { |alg| ld_obracuni_from_sql_server(alg) } , "IDS", { "rj", {"godina", 4}, {"mjesec", 2}, "status", "obr" } , {|x| sql_where_block("ld_obracuni", x) }, "RJ" })

// ld_pk_radn TAG "1", "idradn"
AADD(gaDBFs, { F_PK_RADN,  "PK_RADN" , "ld_pk_radn",  { |alg| ld_pk_radn_from_sql_server(alg) } , "IDS", {"idradn"}, { |x| sql_where_block("ld_pk_radn", x)}, "1" })

// ld_pk_data "1", "idradn+ident+STR(rbr, 2)"
AADD(gaDBFs, { F_PK_DATA,  "PK_DATA" , "ld_pk_data",  { |alg| ld_pk_data_from_sql_server(alg) } , "IDS", {"idradn", "ident", {"rbr", 2}}, {|x| sql_where_block("ld_pk_data", x) }, "1" })

// ld_radsat, tag "IDRADN", index: "idradn"
AADD(gaDBFs, { F_RADSAT ,  "RADSAT"  , "ld_radsat",   { |alg| ld_radsat_from_sql_server(alg)  } , "IDS",  {"idradn"}, {|x| sql_where_block("ld_radsat", x) }, "IDRADN" })


// ID bazirani sifrarnici
AADD(gaDBFs, { F_RADN   ,  "RADN"    , "ld_radn"  ,     { |alg| ld_radn_from_sql_server(alg)  } , "IDS" } )
AADD(gaDBFs, { F_LD_RJ  ,  "LD_RJ"   , "ld_rj"    ,     { |alg| ld_rj_from_sql_server(alg)    } , "IDS" } )
AADD(gaDBFs, { F_POR    ,  "POR"     , "por"      ,     { |alg| por_from_sql_server(alg)      } , "IDS" } )
AADD(gaDBFs, { F_DOPR   ,  "DOPR"    , "dopr"     ,     { |alg| dopr_from_sql_server(alg)     } , "IDS" } )
AADD(gaDBFs, { F_TIPPR  ,  "TIPPR"   , "tippr"    ,     { |alg| tippr_from_sql_server(alg)    } , "IDS" } )
AADD(gaDBFs, { F_TIPPR2 ,  "TIPPR2"  , "tippr2"   ,     { |alg| tippr2_from_sql_server(alg)   } , "IDS" } )
AADD(gaDBFs, { F_KRED   ,  "KRED"    , "kred"     ,     { |alg| kred_from_sql_server(alg)     } , "IDS" } )
AADD(gaDBFs, { F_STRSPR ,  "STRSPR"  , "strspr"   ,     { |alg| strspr_from_sql_server(alg)   } , "IDS" } )
AADD(gaDBFs, { F_KBENEF ,  "KBENEF"  , "kbenef"   ,     { |alg| kbenef_from_sql_server(alg)   } , "IDS" } )
AADD(gaDBFs, { F_VPOSLA ,  "VPOSLA"  , "vposla"   ,     { |alg| vposla_from_sql_server(alg)   } , "IDS" } )

AADD(gaDBFs, { F_RADSIHT,  "RADSIHT" , "ld_radsiht",  { |alg| ld_radsiht_from_sql_server(alg) } , "IDS", { "idkonto", {"godina", 4}, {"mjesec", 2}, "idradn" }, { |x| sql_where_block("ld_radsiht", x) }, "2" } )

AADD(gaDBFs, { F_NORSIHT,  "NORSIHT" , "ld_norsiht",  { |alg| ld_norsiht_from_sql_server(alg) } , "IDS" } )
AADD(gaDBFs, { F_TPRSIHT,  "TPRSIHT" , "ld_tprsiht",  { |alg| ld_tprsiht_from_sql_server(alg) } , "IDS" } )


AADD(gaDBFs, { F__RADKR  , "_RADKR"  , "_ld_radkr"  } )
AADD(gaDBFs, { F__RADN   , "_RADN"   , "_ld_radn"   } )
AADD(gaDBFs, { F_LDSM    , "LDSM"    , "ld_ldsm"    } )

// koristi se u reportima
AADD(gaDBFs, { F_OPSLD   , "OPSLD"   , "ld_opsld"   } )

AADD(gaDBFs, { F__LD     , "_LD"     , "_ld_ld"     } )
AADD(gaDBFs, { F_REKLD   , "REKLD"   , "ld_rekld"   } )
AADD(gaDBFs, { F_REKLDP  , "REKLDP"  , "ld_rekldp"  } )

AADD(gaDBFs, { F_KRED    , "_KRED"   , "_ld_kred"   } )
AADD(gaDBFs, { F_LDT22   , "LDT22"   , "ldt22"      } )


// modul OS:
// -----------------
// OS tabele
AADD( gaDbfs, { F_OS    , "OS"    , "os_os", { |alg| os_os_from_sql_server(alg) }, "IDS", {"id"}, {|x| sql_where_block("os_os", x) }, "1" } )
AADD( gaDbfs, { F_PROMJ , "PROMJ" , "os_promj", { |alg| os_promj_from_sql_server(alg) }, "IDS", {"id"}, {|x| sql_where_block("os_promj", x) }, "1" } )
// SII tabele
AADD( gaDbfs, { F_SII    , "SII"    , "sii_sii", { |alg| sii_sii_from_sql_server(alg) }, "IDS", {"id"}, {|x| sql_where_block("sii_sii", x) }, "1" } )
AADD( gaDbfs, { F_SII_PROMJ , "SII_PROMJ" , "sii_promj", { |alg| sii_promj_from_sql_server(alg) }, "IDS", {"id"}, {|x| sql_where_block("sii_promj", x) }, "1" } )
AADD( gaDbfs, { F_INVENT, "INVENT", "os_invent" } )
AADD( gaDbfs, { F_K1    , "K1"    , "os_k1", { |alg| os_k1_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_AMORT , "AMORT" , "os_amort", { |alg| os_amort_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_REVAL , "REVAL" , "os_reval", { |alg| os_reval_from_sql_server(alg) }, "IDS" } )

// modul POS
AADD( gaDbfs, {  F_POS_DOKS  , "POS_DOKS", "pos_doks", { |alg| pos_doks_from_sql_server(alg) }, "IDS", { "idpos", "idvd", "datum", "brdok" }, { |x| sql_where_block("pos_doks", x) }, "1" } )
AADD( gaDbfs, {  F_POS       , "POS",      "pos_pos", { |alg| pos_pos_from_sql_server(alg) }, "IDS", {"idpos", "idvd", "datum", "brdok", "rbr" }, {|x| sql_where_block("pos_pos", x) }, "IDS_SEM" } )
AADD( gaDbfs, {  F_RNGPLA    , "RNGPLA",   "pos_rngpla"   } )
AADD( gaDbfs, {  F__POS      , "_POS", 	   "_pos_pos" } )
AADD( gaDbfs, {  F__PRIPR    , "_POS_PRIPR",  "_pos_pripr" } )
AADD( gaDbfs, {  F__POSP     , "_POSP",    "_pos_posp" } )
AADD( gaDbfs, {  F__POSP     , "_POS_DOKSP",  "_pos_doksp" } )
AADD( gaDbfs, {  F_PRIPRZ    , "PRIPRZ", "pos_priprz" } )
AADD( gaDbfs, {  F_PRIPRG    , "PRIPRG", "pos_priprg" } )
AADD( gaDbfs, {  F_K2C       , "K2C", "pos_k2c" } )
AADD( gaDbfs, {  F_MJTRUR    , "MJTRUR", "pos_mjtrur" } )
AADD( gaDbfs, {  F_ROBAIZ    , "ROBAIZ", "pos_robaiz" } )
AADD( gaDbfs, {  F_RAZDR     , "RAZDR",  "pos_razdr" } )
AADD( gaDbfs, {  F_STRAD     , "STRAD",  "pos_strad", { |alg| pos_strad_from_sql_server( alg) }, "IDS" } )
AADD( gaDbfs, {  F_OSOB      , "OSOB",   "pos_osob", { |alg| pos_osob_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, {  F_KASE      , "KASE",   "pos_kase", { |alg| pos_kase_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, {  F_ODJ       , "ODJ",    "pos_odj", { |alg| pos_odj_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, {  F_UREDJ     , "UREDJ",  "pos_uredj" } )
AADD( gaDbfs, {  F_DIO       , "DIO",    "pos_dio" } )
AADD( gaDbfs, {  F_MARS      , "MARS",   "pos_mars" } )
AADD( gaDbfs, {  F_DINTEG1   , "DINTEG1", "pos_dinteg1" } )
AADD( gaDbfs, {  F_DINTEG2   , "DINTEG2", "pos_dinteg2" } )
AADD( gaDbfs, {  F_INTEG1    , "INTEG1" , "pos_integ1" } )
AADD( gaDbfs, {  F_INTEG2    , "INTEG2" , "pos_integ2" } )
AADD( gaDbfs, {  F_DOKSPF    , "DOKSPF" , "pos_dokspf" } )
AADD( gaDbfs, {  F_PROMVP    , "PROMVP" , "pos_promvp", {|alg| pos_promvp_from_sql_server(alg) }, "IDS" } )


// modul MAT
AADD(gaDBFs, { F_MAT_PRIPR,   "MAT_PRIPR",   "mat_pripr"   } )
AADD(gaDBFs, { F_MAT_INVENT,  "MAT_INVENT",  "mat_invent"  } )
AADD(gaDBFs, { F_MAT_PSUBAN,  "MAT_PSUBAN",  "mat_psuban"  } )
AADD(gaDBFs, { F_MAT_PSINT,   "MAT_PSINT",   "mat_psint"   } )
AADD(gaDBFs, { F_MAT_PANAL,   "MAT_PANAL",   "mat_panal"   } )
AADD(gaDBFs, { F_MAT_PNALOG,  "MAT_PNALOG",  "mat_pnalog"  } )
AADD(gaDBFs, { F_MAT_SUBAN,   "MAT_SUBAN",   "mat_suban", { |alg| mat_suban_from_sql_server(alg) }, "IDS" } )
AADD(gaDBFs, { F_MAT_ANAL,    "MAT_ANAL",    "mat_anal" , { |alg| mat_anal_from_sql_server(alg) }, "IDS" } )
AADD(gaDBFs, { F_MAT_SINT,    "MAT_SINT",    "mat_sint" , { |alg| mat_sint_from_sql_server(alg) }, "IDS" } )
AADD(gaDBFs, { F_MAT_NALOG,   "MAT_NALOG",   "mat_nalog", { |alg| mat_nalog_from_sql_server(alg) }, "IDS" } )
AADD(gaDBFs, { F_KARKON,      "KARKON",      "mat_karkon", { |alg| mat_karkon_from_sql_server(alg) }, "IDS" } )

// modul VIRM
AADD(gaDBFs, { F_VIPRIPR,  "VIRM_PRIPR"   , "virm_pripr" } )
AADD(gaDBFs, { F_IZLAZ  ,  "IZLAZ"   , "izlaz" } )
AADD(gaDBFs, { F_VRPRIM ,  "VRPRIM"  , "vrprim", {|alg| vrprim_from_sql_server(alg)}, "IDS" } )
AADD(gaDBFs, { F_VRPRIM2,  "VRPRIM2" , "vrprim2" } )
AADD(gaDBFs, { F_JPRIH  ,  "JPRIH"   , "jprih", { |alg| jprih_from_sql_server(alg) }, "IDS" } )
AADD(gaDBFs, { F_LDVIRM ,  "LDVIRM"  , "ldvirm", { |alg| ldvirm_from_sql_server( alg ) }, "IDS" } )
AADD(gaDBFs, { F_KALVIR ,  "KALVIR"  , "kalvir", { |alg| kalvir_from_sql_server(alg) }, "IDS" } )


return

