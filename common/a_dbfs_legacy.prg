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
AADD( gaDbfs, { F_DOKSRC   , "DOKSRC"  , "doksrc"  } )
AADD( gaDbfs, { F_P_DOKSRC , "P_DOKSRC"  , "p_doksrc"  } )
AADD( gaDbfs, { F_RELATION , "RELATION"  , "relation"  } )
AADD( gaDbfs, { F_P_UPDATE , "P_UPDATE"  , "p_update"  } )
AADD( gaDbfs, { F__ROBA , "_ROBA"  , "_roba"  } )

AADD( gaDbfs, { F_VRSTEP , "VRSTEP"  , "vrstep", {| param | vrstep_from_sql_server( param ) }, "IDS"  } )
AADD( gaDbfs, { F_RJ     ,  "RJ"      , "rj", { | param | rj_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_TDOK   ,  "TDOK"    , "tdok", { | param | tdok_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_KONTO  ,  "KONTO"   , "konto", {| param | konto_from_sql_server(param) }, "IDS" } )
AADD( gaDbfs, { F_VPRIH  ,  "VPRIH"   , "vpprih"   } )

AADD( gaDbfs, { F_PKONTO ,  "PKONTO"  , "pkonto", { | param | pkonto_from_sql_server(param) }, "IDS" } )
AADD( gaDbfs, { F_VALUTE ,  "VALUTE"  , "valute", { | param | valute_from_sql_server( param ) }, "IDS" } )

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

AADD(gaDBFs, { F_R_KIF, "R_KIF", "epdv_r_kif"  } )
AADD(gaDBFs, { F_R_KUF, "R_KUF", "epdv_r_kuf"  } )
AADD(gaDBFs, { F_R_PDV, "R_PDV", "epdv_r_pdv"  } )
AADD(gaDBFs, { F_ANAL, "SUBAN_2", "suban_2"  } )

// modul LD

// "1","str(godina)+idrj+str(mjesec)+obr+idradn"
AADD(gaDBFs, { F_LD      , "LD"      , "ld_ld",    { |alg| ld_ld_from_sql_server(alg) }, "IDS", {{"godina", 4}, "idrj", {"mjesec", 2}, "obr", "idradn" },  { |x| sql_where_block("ld_ld", x) }, "1"})

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


