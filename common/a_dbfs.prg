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

// ------------------
// ------------------
function set_a_dbfs()

public gaDbfs := {}

// parametri
AADD( gaDbfs, { F_PARAMS  ,  "PARAMS"   , "params"  } )
AADD( gaDbfs, { F_GPARAMS , "GPARAMS"  , "gparams"  } )
AADD( gaDbfs, { F_KPARAMS , "KPARAMS"  , "kparams"  } )
AADD( gaDbfs, { F_SECUR  , "SECUR"  , "secur"  } )

// sifrarnici
AADD( gaDbfs, { F_TOKVAL  , "TOKVAL"  , "tokval"  } )
AADD( gaDbfs, { F_SIFK  , "SIFK"  , "sifk", { |param| sifk_from_sql_server(param) }, "IDS", {"id", "oznaka"}, { |x| "ID=" + _sql_quote(x["id"]) + " AND OZNAKA=" + _sql_quote(x["oznaka"]) }, "ID2" })
AADD( gaDbfs, { F_SIFV , "SIFV"  , "sifv", { | param | sifv_from_sql_server( param ) }, "IDS", {"id", "oznaka", "idsif", "naz"}, { |x| "ID=" + _sql_quote(x["id"]) + " AND OZNAKA=" + _sql_quote(x["oznaka"]) + " AND IDSIF=" + _sql_quote(x["idsif"] + " AND NAZ=" + _sql_quote(x["naz"])) }, "ID" })
  
AADD( gaDbfs, { F_OPS , "OPS"  , "ops", { | param | opstine_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_BANKE , "BANKE"  , "banke", { | param | banke_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_BARKOD , "BARKOD"  , "barkod"  } )
AADD( gaDbfs, { F_STRINGS , "STRINGS"  , "strings"  } )
AADD( gaDbfs, { F_RNAL , "RNAL"  , "rnal"  } )
AADD( gaDbfs, { F_DEST   ,"DEST"    , "dest", { | param | dest_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_LOKAL , "LOKAL"  , "lokal", { | param | lokal_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_DOKSRC , "DOKSRC"  , "doksrc"  } )
AADD( gaDbfs, { F_P_DOKSRC , "P_DOKSRC"  , "p_doksrc"  } )
AADD( gaDbfs, { F_RELATION , "RELATION"  , "relation"  } )
AADD( gaDbfs, { F_FMKRULES , "FMKRULES"  , "f18_rules", { | param | f18_rules_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_RULES , "RULES"  , "rules"  } )
AADD( gaDbfs, { F_P_UPDATE , "P_UPDATE"  , "p_update"  } )
AADD( gaDbfs, { F__ROBA , "_ROBA"  , "_roba"  } )
AADD( gaDbfs, { F_TRFP , "TRFP"  , "trfp", { | param | trfp_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_SAST , "SAST"  , "sast", { | param | sast_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_VRSTEP , "VRSTEP"  , "vrstep"  } )
AADD( gaDbfs, { F_RJ     ,  "RJ"      , "rj", { | param | rj_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_TDOK   ,  "TDOK"    , "tdok", { | param | tdok_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_KONTO  ,  "KONTO"   , "konto", {| param | konto_from_sql_server(param) }, "IDS" } )
AADD( gaDbfs, { F_VPRIH  ,  "VPRIH"   , "vpprih"   } )
AADD( gaDbfs, { F_PARTN  ,  "PARTN"   , "partn", {| param | partn_from_sql_server(param) }, "IDS" } )
AADD( gaDbfs, { F_TNAL   ,  "TNAL"    , "tnal", { | param | tnal_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_PKONTO ,  "PKONTO"  , "pkonto"   } )
AADD( gaDbfs, { F_VALUTE ,  "VALUTE"  , "valute", { | param | valute_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_ROBA   ,  "ROBA"    , "roba", { | param | roba_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_TARIFA ,  "TARIFA"  , "tarifa", { | param | tarifa_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_KONCIJ ,  "KONCIJ"  , "koncij", { | param | koncij_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_TRFP2  ,  "TRFP2"   , "trfp2", { | param | trfp2_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_TRFP3  ,  "TRFP3"   , "trfp3", { | param | trfp3_from_sql_server( param ) }, "IDS" } )
AADD( gaDbfs, { F_VKSG   ,  "VKSG"    , "vksg"   } )
AADD( gaDbfs, { F_ULIMIT ,  "ULIMIT"  , "ulimit"  } )

// r_export
AADD( gaDbfs, { F_R_EXP ,  "R_EXPORT"  , "r_export"  } )

// finmat
AADD( gaDbfs, { F_FINMAT ,  "FINMAT"  , "fin_mat"  } )

// modul FIN
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
AADD( gaDbfs, { F_OSTAV  ,  "OSTAV"   , "fin_ostav"  } )
AADD( gaDbfs, { F_OSUBAN ,  "OSUBAN"  , "fin_osuban"  } )
AADD( gaDbfs, { F__KONTO ,  "_KONTO"  , "fin__konto"  } )
AADD( gaDbfs, { F__PARTN ,  "_PARTN"  , "fin__partn"  } )
AADD( gaDbfs, { F_POM    ,  "POM"     , "fin_pom"  } )
AADD( gaDbfs, { F_POM2   ,  "POM2"    , "fin_pom2"  } )
AADD( gaDbfs, { F_KUF    ,  "FIN_KUF" , "fin_kuf"   } )
AADD( gaDbfs, { F_KIF    ,  "FIN_KIF" , "fin_kif"   } )
AADD( gaDbfs, { F_SUBAN  ,  "SUBAN"   , "fin_suban" ,  {|alg| fin_suban_from_sql_server(alg) }, "IDS" , {"idfirma", "idvn", "brnal", "rbr" }, {|x| "idfirma=" + _sql_quote(x["idfirma"]) + " AND idvn=" + _sql_quote(x["idvn"]) + " AND brnal=" + _sql_quote(x["brnal"]) + " AND rbr=" + _sql_quote(x["rbr"]) }, "4" })
AADD( gaDbfs, { F_ANAL   ,  "ANAL"    , "fin_anal",    {|alg| fin_anal_from_sql_server(alg)  }, "IDS" } )
AADD( gaDbfs, { F_SINT   ,  "SINT"    , "fin_sint",    {|alg| fin_sint_from_sql_server(alg)  }, "IDS" } )
AADD( gaDbfs, { F_NALOG  ,  "NALOG"   , "fin_nalog",   {|alg| fin_nalog_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_FUNK   ,  "FUNK"    , "fin_funk"  } )
AADD( gaDbfs, { F_BUDZET ,  "BUDZET"  , "fin_budzet"  } )
AADD( gaDbfs, { F_PAREK  ,  "PAREK"   , "fin_parek"   } )
AADD( gaDbfs, { F_FOND   ,  "FOND"    , "fin_fond"   } )
AADD( gaDbfs, { F_KONIZ  ,  "KONIZ"   , "fin_koniz"   } )
AADD( gaDbfs, { F_IZVJE  ,  "IZVJE"   , "fin_izvje"   } )
AADD( gaDbfs, { F_ZAGLI  ,  "ZAGLI"   , "fin_zagli"   } )
AADD( gaDbfs, { F_KOLIZ  ,  "KOLIZ"   , "fin_koliz"   } )
AADD( gaDbfs, { F_BUIZ   ,  "BUIZ"    , "fin_buiz"   } )

//modul KALK
AADD( gaDbfs, { F_KALK  ,"KALK" , "kalk_kalk" , {|alg| kalk_kalk_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_KALK_DOKS  ,"KALK_DOKS", "kalk_doks", {|alg| kalk_doks_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_KALK_DOKS2  ,"KALK_DOKS2"   , "kalk_doks2"    } )
AADD( gaDbfs, { F_KALKS  ,"KALKS" , "kalk_kalks"    } )
AADD( gaDbfs, { F__KALK  ,"_KALK" , "_kalk_kalk"    } )
AADD( gaDbfs, { F_KALK_PRIPR  ,"KALK_PRIPR"   , "kalk_pripr"    } )
AADD( gaDbfs, { F_KALK_PRIPR2  ,"KALK_PRIPR2"  , "kalk_pripr2"   } )
AADD( gaDbfs, { F_KALK_PRIPR9  ,"KALK_PRIPR9"  , "kalk_pripr9"   } )
AADD( gaDbfs, { F_PORMP  ,"PORMP"        , "kalk_pormp"     } )
AADD( gaDbfs, { F_TRFP   ,"TRFP"         , "kalk_trfp"      } )
AADD( gaDbfs, { F_DOKSRC ,"KALK_DOKSRC"  , "kalk_doksrc"    } )
AADD( gaDbfs, { F_P_DOKSRC,"P_KALK_DOKSRC", "p_kalk_doksrc"   } )
AADD( gaDbfs, { F_PPPROD ,"PPPROD"  , "kalk_ppprod"    } )
AADD( gaDbfs, { F_OBJEKTI,"OBJEKTI" , "kalk_objekti"     } )
AADD( gaDbfs, { F_OBJEKTI,"POBJEKTI" , "kalk_pobjekti"     } )
AADD( gaDbfs, { F_PRODNC, "PRODNC"  , "kalk_prodnc"     } )
AADD( gaDbfs, { F_RVRSTA, "RVRSTA"  , "kalk_rvrsta"     } )
AADD( gaDbfs, { F_CACHE     ,"CACHE"      , "kalk_cache"     } )
AADD( gaDbfs, { F_PRIPT     ,"PRIPT"      , "kalk_pript"     } )
AADD( gaDbfs, { F_REKAP1     ,"REKAP1"      , "kalk_rekap1"     } )
AADD( gaDbfs, { F_REKAP2     ,"REKAP2"      , "kalk_rekap2"     } )
AADD( gaDbfs, { F_REKA22     ,"REKA22"      , "kalk_reka22"     } )
AADD( gaDbfs, { F_R_UIO     ,"R_UIO"       , "kalk_r_uio"     } )
AADD( gaDbfs, { F_RPT_TMP     ,"RPT_TMP"     , "kalk_rpt_tmp"     } )


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

AADD( gaDbfs, { F_FAKT        , "FAKT"          , "fakt_fakt"      , { |alg| fakt_fakt_from_sql_server(alg) }  , "IDS" } )
AADD( gaDbfs, { F_FAKT_DOKS   , "FAKT_DOKS"     , "fakt_doks"      , { |alg| fakt_doks_from_sql_server(alg) }  , "IDS" } )
AADD( gaDbfs, { F_FAKT_DOKS2  , "FAKT_DOKS2"    , "fakt_doks2"     , { |alg| fakt_doks2_from_sql_server(alg) } , "IDS" } )
AADD( gaDbfs, { F_FTXT        , "FTXT"          , "fakt_ftxt"      , { |alg| ftxt_from_sql_server(alg) }       , "IDS"} )

AADD( gaDbfs, { F_FAKT   ,"FAKT_S_PRIPR", "fakt_pripr"     } )
AADD( gaDbfs, { F__FAKT  ,"_FAKT"   , "_fakt_fakt"    } )
AADD( gaDbfs, { F_FAPRIPR,"FAKT_faPRIPR"   , "fakt_fapripr"    } )
AADD( gaDbfs, { F_UGOV   ,"UGOV"    , "fakt_ugov", { | alg | ugov_from_sql_server( alg ) }, "IDS" } )
AADD( gaDbfs, { F_RUGOV  ,"RUGOV"   , "fakt_rugov", { | alg | rugov_from_sql_server( alg ) }, "IDS" } )
AADD( gaDbfs, { F_GEN_UG ,"GEN_UG"  , "fakt_gen_ug", { | alg | gen_ug_from_sql_server( alg ) }, "IDS" } )
AADD( gaDbfs, { F_G_UG_P, "GEN_UG_P", "fakt_gen_ug_p", { | alg | gen_ug_p_from_sql_server( alg ) }, "IDS" } )
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
AADD(gaDBFs, { F_KUF, "KUF", "epdv_kuf", {|alg| epdv_kuf_from_sql_server(alg)}, "IDS" } )
AADD(gaDBFs, { F_KIF, "KIF", "epdv_kif", {|alg| epdv_kif_from_sql_server(alg)}, "IDS" } )
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
AADD(gaDBFs, { F_RADSAT ,  "RADSAT"  , "ld_radsat",   { |alg| ld_radsat_from_sql_server(alg)  } , "IDS",  {"idradn"}, {|x| sql_where_block("ld_pk_data", x) }, "IDRADN"})


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

AADD(gaDBFs, { F_RADSIHT,  "RADSIHT" , "ld_radsiht",  { |alg| ld_radsiht_from_sql_server(alg) } , "IDS" } )

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


// modul OS
AADD( gaDbfs, { F_INVENT, "INVENT", "os_invent" } )
AADD( gaDbfs, { F_OS    , "OS"    , "os_os", { |alg| os_os_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_PROMJ , "PROMJ" , "os_promj", { |alg| os_promj_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_K1    , "K1"    , "os_k1", { |alg| os_k1_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_AMORT , "AMORT" , "os_amort", { |alg| os_amort_from_sql_server(alg) }, "IDS" } )
AADD( gaDbfs, { F_REVAL , "REVAL" , "os_reval", { |alg| os_reval_from_sql_server(alg) }, "IDS" } )

// modul POS
AADD( gaDbfs, {  F_POS_DOKS  , "POS_DOKS", "pos_doks" } )
AADD( gaDbfs, {  F_POS       , "POS",      "pos_pos"      } )
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
AADD( gaDbfs, {  F_STRAD     , "STRAD",  "pos_strad" } )
AADD( gaDbfs, {  F_OSOB      , "OSOB",   "pos_osob" } )
AADD( gaDbfs, {  F_KASE      , "KASE",   "pos_kase" } )
AADD( gaDbfs, {  F_ODJ       , "ODJ",    "pos_odj" } )
AADD( gaDbfs, {  F_UREDJ     , "UREDJ",  "pos_uredj" } )
AADD( gaDbfs, {  F_DIO       , "DIO",    "pos_dio" } )
AADD( gaDbfs, {  F_MARS      , "MARS",   "pos_mars" } )
AADD( gaDbfs, {  F_DINTEG1   , "DINTEG1", "pos_dinteg1" } )
AADD( gaDbfs, {  F_DINTEG2   , "DINTEG2", "pos_dinteg2" } )
AADD( gaDbfs, {  F_INTEG1    , "INTEG1" , "pos_integ1" } )
AADD( gaDbfs, {  F_INTEG2    , "INTEG2" , "pos_integ2" } )
AADD( gaDbfs, {  F_DOKSPF    , "DOKSPF" , "pos_dokspf" } )
AADD( gaDbfs, {  F_PROMVP    , "PROMVP" , "pos_promvp" } )
AADD( gaDbfs, {  F_POM       , "POM"    , "pos_pom"  } )


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



return

