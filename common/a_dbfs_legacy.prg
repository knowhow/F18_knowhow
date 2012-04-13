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

// ------------------------------------
// ------------------------------------
function set_a_dbfs_legacy()
// ---- legacy 

_dbf_fields := NIL

/*

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

*/

return


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
           RaiseError("f18_dbf_alias ?: " + x_alias)
           QUIT
   endif
   
else

   // /home/test/suban.dbf => suban
   _pos := ASCAN(gaDBFs,  { |x|  x[2]==UPPER(FILEBASE(x_alias))} )
   if _pos < 1

       _pos := ASCAN(gaDBFs,  { |x|  x[3]==x_alias} )
        
       if _pos < 1
          _ret["wa"]    := NIL
          _ret["alias"] := NIL
          _ret["table"] := NIL
          RaiseError("f18_dbf_alias ?: " + x_alias)
          QUIT
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


