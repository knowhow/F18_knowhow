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


// ------------------------------------------------
// kreiranje tabela rnal-a
// ------------------------------------------------
function cre_all_rnal( ver )
local aDbf
local _alias, _table_name
local _created

aDbf := a_docs()
_created := .f.
_alias := "DOCS"
_table_name := "rnal_docs"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
			
CREATE_INDEX("1", "STR(doc_no,10)", _alias )
CREATE_INDEX("A", "STR(doc_status,2)+STR(doc_no,10)", _alias )
CREATE_INDEX("2", "STR(doc_priori,4)+DTOS(doc_date)+STR(doc_no,10)", _alias )
CREATE_INDEX("3", "STR(doc_priori,4)+DTOS(doc_dvr_da)+STR(doc_no,10)", _alias )
CREATE_INDEX("D1", "DTOS(doc_date)+STR(doc_no,10)", _alias )
CREATE_INDEX("D2", "DTOS(doc_dvr_da)+STR(doc_no,10)", _alias )

_alias := "_DOCS"
_table_name := "rnal__docs"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

CREATE_INDEX("1", "STR(doc_no,10)", _alias )
CREATE_INDEX("A", "STR(doc_status,2)+STR(doc_no,10)", _alias )
CREATE_INDEX("2", "STR(doc_priori,4)+DTOS(doc_date)+STR(doc_no,10)", _alias )
CREATE_INDEX("3", "STR(doc_priori,4)+DTOS(doc_dvr_da)+STR(doc_no,10)", _alias )
CREATE_INDEX("D1", "DTOS(doc_date)+STR(doc_no,10)", _alias )
CREATE_INDEX("D2", "DTOS(doc_dvr_da)+STR(doc_no,10)", _alias )

aDbf := a_doc_it()
_created := .f.
_alias := "DOC_IT"
_table_name := "rnal_doc_it"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif

CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(art_id,10)", _alias )
CREATE_INDEX("2", "STR(art_id,10)+STR(doc_no,10)+STR(doc_it_no,4)", _alias )
CREATE_INDEX("3", "STR(doc_no,10)+STR(art_id,10)", _alias )
	
_created := .f.
_alias := "_DOC_IT"
_table_name := "rnal__doc_it"
if !FILE(f18_ime_dbf( _alias ))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(art_id,10)", _alias )
CREATE_INDEX("2", "STR(art_id,10)+STR(doc_no,10)+STR(doc_it_no,4)", _alias )
CREATE_INDEX("3", "STR(doc_no,10)+STR(art_id,10)", _alias )
			

aDbf := a_doc_it2()
_created := .f.
_alias := "DOC_IT2"
_table_name := "rnal_doc_it2"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif

CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(it_no,4)", _alias )
CREATE_INDEX("2", "art_id+STR(doc_no,10)+STR(doc_it_no,4)", _alias )
CREATE_INDEX("3", "STR(doc_no,10)+art_id", _alias )
	
_created := .f.
_alias := "_DOC_IT2"
_table_name := "rnal__doc_it2"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(it_no,4)", _alias )
CREATE_INDEX("2", "art_id+STR(doc_no,10)+STR(doc_it_no,4)", _alias )
CREATE_INDEX("3", "STR(doc_no,10)+art_id", _alias )
	
		
aDbf := a_doc_ops()
_created := .f.
_alias := "DOC_OPS"
_table_name := "rnal_doc_ops"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
			
CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_op_no,4)", _alias )
CREATE_INDEX("2", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_it_el_,10)", _alias )
	
_created := .f.
_alias := "_DOC_OPS"
_table_name := "rnal__doc_ops"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_op_no,4)", _alias )
CREATE_INDEX("2", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_it_el_,10)", _alias )
	

aDbf := a_doc_log()
_created := .f.
_alias := "DOC_LOG"
_table_name := "rnal_doc_log"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
	
CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_log_no,10)+DTOS(doc_log_da)+doc_log_ti", _alias )
CREATE_INDEX("2", "STR(doc_no,10)+doc_log_ty+STR(doc_log_no,10)", _alias )
	
aDbf := a_doc_lit()
_created := .f.
_alias := "DOC_LIT"
_table_name := "rnal_doc_lit"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
	
CREATE_INDEX( "1", "STR(doc_no,10)+STR(doc_log_no,10)+STR(doc_lit_no,10)", _alias )

aDbf := a_articles()
_created := .f.
_alias := "ARTICLES"
_table_name := "rnal_articles"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
	
CREATE_INDEX( "1", "STR(art_id,10)", _alias )
CREATE_INDEX( "2", "PADR(art_desc,100)", _alias )
	

aDbf := a_elements()
_created := .f.
_alias := "ELEMENTS"
_table_name := "rnal_elements"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
	
CREATE_INDEX("1", "STR(art_id,10)+STR(el_no,4)+STR(el_id,10)", _alias )
CREATE_INDEX("2", "STR(el_id,10)", _alias )
	
	
aDbf := a_e_aops()
_created := .f.
_alias := "E_AOPS"
_table_name := "rnal_e_aops"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
		
CREATE_INDEX("1", "STR(el_id,10)+STR(el_op_id,10)", _alias )
CREATE_INDEX("2", "STR(el_op_id,10)", _alias )
	

aDbf := a_e_att()
_created := .f.
_alias := "E_ATT"
_table_name := "rnal_e_att"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif

CREATE_INDEX("1", "STR(el_id,10)+STR(el_att_id,10)", _alias )
CREATE_INDEX("2", "STR(el_att_id,10)", _alias )
	

aDbf := a_e_groups()
_created := .f.
_alias := "E_GROUPS"
_table_name := "rnal_e_groups"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
	
CREATE_INDEX("1", "STR(e_gr_id,10)", _alias )
CREATE_INDEX("2", "PADR(e_gr_desc,20)", _alias )
		

aDbf := a_e_gr_att()
_created := .f.
_alias := "E_GR_ATT"
_table_name := "rnal_e_gr_att"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
	
CREATE_INDEX("1","STR(e_gr_at_id,10,0)", _alias )
CREATE_INDEX("2","STR(e_gr_id,10,0)+e_gr_at_re+STR(e_gr_at_id,10)", _alias )
	

aDbf := a_e_gr_val()
_created := .f.
_alias := "E_GR_VAL"
_table_name := "rnal_e_gr_val"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
	
CREATE_INDEX("1","STR(e_gr_vl_id,10,0)", _alias )
CREATE_INDEX("2","STR(e_gr_at_id,10,0)+STR(e_gr_vl_id,10,0)", _alias )
		

			
aDbf := a_customs()
_created := .f.
_alias := "CUSTOMS"
_table_name := "rnal_customs"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
			
CREATE_INDEX("1", "STR(cust_id,10)", _alias )
			


aDbf := a_contacts()
_created := .f.
_alias := "CONTACTS"
_table_name := "rnal_contacts"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
			
CREATE_INDEX("1", "STR(cont_id,10)", _alias )
CREATE_INDEX("2", "STR(cust_id,10)+STR(cont_id,10)", _alias )
CREATE_INDEX("3", "STR(cust_id,10)+cont_desc", _alias )
CREATE_INDEX("4", "cont_desc", _alias )
	

aDbf := a_objects()
_created := .f.
_alias := "OBJECTS"
_table_name := "rnal_objects"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
		
CREATE_INDEX("1", "STR(obj_id,10)", _alias )
CREATE_INDEX("2", "STR(cust_id,10)+STR(obj_id,10)", _alias )
CREATE_INDEX("3", "STR(cust_id,10)+obj_desc", _alias )
CREATE_INDEX("4", "obj_desc", _alias )
	
		
			
aDbf := a_aops()
_created := .f.
_alias := "AOPS"
_table_name := "rnal_aops"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
			
CREATE_INDEX("1", "STR(aop_id,10)", _alias )



aDbf := a_aops_att()
_created := .f.
_alias := "AOPS_ATT"
_table_name := "rnal_aops_att"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
			
CREATE_INDEX("1","STR(aop_att_id,10)", _alias )
CREATE_INDEX("2","STR(aop_id,10)+STR(aop_att_id,10)", _alias )
		

aDbf := a_ral()
_created := .f.
_alias := "RAL"
_table_name := "rnal_ral"
if !FILE(f18_ime_dbf(_alias))
    DBCREATE2( _alias, aDbf )
    _created := .t.
endif

if _created
    reset_semaphore_version(_table_name)
    my_usex(_alias)
    USE
endif
	
CREATE_INDEX("1", "STR(id,5)+STR(gl_tick,2)", _alias )
CREATE_INDEX("2", "descr", _alias )


// kreiraj pravila : RULES
cre_fmkrules( ver )
// kreiraj pravila : RULES cdx files
c_rule_cdx()

// kreiranje tabele pretraga parametri
_cre_fnd_par( ver, .t. )
// kreiraj relacije
cre_relation( ver )

return .t.



// -----------------------------------------------
// kreiranje rules index-a specificnih za rnal
// -----------------------------------------------
static function c_rule_cdx()
local _alias := "FMKRULES"

// ELEMENT CODE
CREATE_INDEX( "ELCODE", "MODUL_NAME+RULE_OBJ+RULE_C3+RULE_C4", _alias )
// ARTICLES NEW
CREATE_INDEX( "RNART1", "MODUL_NAME+RULE_OBJ+RULE_C3+STR(RULE_NO,5)", _alias )
// ITEMS
CREATE_INDEX( "ITEM1", "MODUL_NAME+RULE_OBJ+RULE_C5+STR(RULE_NO,5)", _alias )

return




// --------------------------------------
// kreira tabelu ral
// --------------------------------------
static function a_ral()
local aDbf := {}

AADD( aDbf, { "id", "N", 5, 0 })
AADD( aDbf, { "gl_tick", "N", 2, 0 })
AADD( aDbf, { "descr", "C", 50, 0 })
AADD( aDbf, { "en_desc", "C", 50, 0 })
AADD( aDbf, { "col_1", "N", 8, 0 })
AADD( aDbf, { "col_2", "N", 8, 0 })
AADD( aDbf, { "col_3", "N", 8, 0 })
AADD( aDbf, { "col_4", "N", 8, 0 })
AADD( aDbf, { "colp_1", "N", 12, 5 })
AADD( aDbf, { "colp_2", "N", 12, 5 })
AADD( aDbf, { "colp_3", "N", 12, 5 })
AADD( aDbf, { "colp_4", "N", 12, 5 })

return aDbf


// ----------------------------------------------
// vraca matricu sa strukturom tabele DOCS
//   aDBF := {...}
// ----------------------------------------------
static function a_docs()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_date", "D", 8, 0 })
AADD(aDBf,{ "doc_time", "C", 8, 0 })
AADD(aDBf,{ "doc_dvr_da", "D", 8, 0 })
AADD(aDBf,{ "doc_dvr_ti", "C", 8,  0 })
AADD(aDBf,{ "doc_ship_p", "C", 200, 0 })
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "cont_id", "N", 10, 0 })
AADD(aDBf,{ "obj_id", "N", 10, 0 })
AADD(aDBf,{ "cont_add_d", "C", 200, 0 })
AADD(aDBf,{ "doc_pay_id", "N", 4, 0 })
AADD(aDBf,{ "doc_paid", "C", 1, 0 })
AADD(aDBf,{ "doc_pay_de", "C", 100, 0 })
AADD(aDBf,{ "doc_priori", "N", 4, 0 })
AADD(aDBf,{ "doc_desc", "C", 200, 0 })
AADD(aDBf,{ "doc_sh_des", "C", 100, 0 })
AADD(aDBf,{ "doc_status", "N", 2, 0 })
AADD(aDBf,{ "operater_i", "N", 3, 0 })
AADD(aDBf,{ "doc_in_fmk", "N", 1, 0 })
AADD(aDBf,{ "fmk_doc", "C", 150, 0 })
AADD(aDBf,{ "doc_llog", "N", 10, 0 })

return aDbf



// ----------------------------------------------
// vraca matricu sa strukturom tabele DOC_IT
//   aDBF := {...}
// ----------------------------------------------
static function a_doc_it()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_it_no", "N", 4, 0 })
AADD(aDBf,{ "art_id", "N", 10, 0 })
AADD(aDBf,{ "doc_it_wid", "N", 15,  5 })
AADD(aDBf,{ "doc_it_hei", "N", 15,  5 })
AADD(aDBf,{ "doc_it_qtt",  "N", 15,  5 })
AADD(aDBf,{ "doc_it_alt",  "N", 15,  5 })
AADD(aDBf,{ "doc_acity",  "C", 50,  5 })
AADD(aDBf,{ "doc_it_sch",  "C", 1,  0 })
AADD(aDBf,{ "doc_it_des",  "C", 150,  0 })
AADD(aDBf,{ "doc_it_typ",  "C", 1,  0 })
AADD(aDBf,{ "doc_it_w2", "N", 15,  5 })
AADD(aDBf,{ "doc_it_h2", "N", 15,  5 })
AADD(aDBf,{ "doc_it_pos", "C", 20,  0 })
AADD(aDBf,{ "it_lab_pos", "C", 1,  0 })

return aDbf


// ----------------------------------------------
// vraca matricu sa strukturom tabele DOC_IT2
//   aDBF := {...}
// ----------------------------------------------
static function a_doc_it2()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_it_no", "N", 4, 0 })
AADD(aDBf,{ "it_no", "N", 4, 0 })
AADD(aDBf,{ "art_id", "C", 10, 0 })
AADD(aDBf,{ "doc_it_qtt",  "N", 15,  5 })
AADD(aDBf,{ "doc_it_q2",  "N", 15,  5 })
AADD(aDBf,{ "doc_it_pri", "N", 15,  5 })
AADD(aDBf,{ "sh_desc", "C", 100,  0 })
AADD(aDBf,{ "descr", "C", 200,  0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele DOC_OPS
//   aDBF := {...}
// --------------------------------------------------
static function a_doc_ops()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_it_no", "N", 4, 0 })
AADD(aDBf,{ "doc_it_el_", "N", 10, 0 })
AADD(aDBf,{ "doc_op_no", "N", 4, 0 })
AADD(aDBf,{ "aop_id", "N", 10,  0 })
AADD(aDBf,{ "aop_att_id", "N", 10,  0 })
AADD(aDBf,{ "aop_value", "C", 150,  0 })
AADD(aDBf,{ "doc_op_des", "C", 150,  0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele DOC_LOG
//   aDBF := {...}
// --------------------------------------------------
static function a_doc_log()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_log_no", "N", 10, 0 })
AADD(aDBf,{ "doc_log_da", "D", 8, 0 })
AADD(aDBf,{ "doc_log_ti", "C", 8, 0 })
AADD(aDBf,{ "operater_i", "N", 3,  0 })
AADD(aDBf,{ "doc_log_ty", "C", 3,  0 })
AADD(aDBf,{ "doc_log_de", "C", 100,  0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele DOCS_LOG_ITEMS
//   aDBF := {...}
// --------------------------------------------------
static function a_doc_lit()
local aDbf

aDbf:={}
AADD(aDBf,{ "doc_no", "N", 10, 0 })
AADD(aDBf,{ "doc_log_no", "N", 10, 0 })
AADD(aDBf,{ "doc_lit_no", "N", 4, 0 })
AADD(aDBf,{ "doc_lit_ac", "C", 1, 0 })
AADD(aDBf,{ "art_id", "N", 10, 0 })
AADD(aDBf,{ "char_1", "C", 100,  0 })
AADD(aDBf,{ "char_2", "C", 100,  0 })
AADD(aDBf,{ "char_3", "C", 100,  0 })
AADD(aDBf,{ "num_1", "N", 15,  5 })
AADD(aDBf,{ "num_2", "N", 15,  5 })
AADD(aDBf,{ "num_3", "N", 15,  5 })
AADD(aDBf,{ "int_1", "N", 10,  0 })
AADD(aDBf,{ "int_2", "N", 10,  0 })
AADD(aDBf,{ "int_3", "N", 10,  0 })
AADD(aDBf,{ "int_4", "N", 10,  0 })
AADD(aDBf,{ "int_5", "N", 10,  0 })
AADD(aDBf,{ "date_1", "D", 8,  0 })
AADD(aDBf,{ "date_2", "D", 8,  0 })
AADD(aDBf,{ "date_3", "D", 8,  0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele ARTICLES
//   aDBF := {...}
// --------------------------------------------------
static function a_articles()
local aDbf

aDbf:={}
AADD(aDBf,{ "art_id", "N", 10, 0 })
AADD(aDBf,{ "art_desc", "C", 100, 0 })
AADD(aDBf,{ "art_full_d", "C", 250, 0 })
AADD(aDBf,{ "art_lab_de", "C", 200, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele ELEMENTS
//   aDBF := {...}
// --------------------------------------------------
static function a_elements()
local aDbf

aDbf:={}
AADD(aDBf,{ "el_id", "N", 10, 0 })
AADD(aDBf,{ "el_no", "N", 4, 0 })
AADD(aDBf,{ "art_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_id", "N", 10, 0 })

return aDbf



// --------------------------------------------------
// vraca matricu sa strukturom tabele E_ATT
//   aDBF := {...}
// --------------------------------------------------
static function a_e_att()
local aDbf

aDbf:={}
AADD(aDBf,{ "el_att_id", "N", 10, 0 })
AADD(aDBf,{ "el_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_at_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_vl_id", "N", 10, 0 })

return aDbf



// --------------------------------------------------
// vraca matricu sa strukturom tabele E_AOPS
//   aDBF := {...}
// --------------------------------------------------
static function a_e_aops()
local aDbf

aDbf:={}
AADD(aDBf,{ "el_op_id", "N", 10, 0 })
AADD(aDBf,{ "el_id", "N", 10, 0 })
AADD(aDBf,{ "aop_id", "N", 10, 0 })
AADD(aDBf,{ "aop_att_id", "N", 10, 0 })

return aDbf


// --------------------------------------------------
// vraca matricu sa strukturom tabele E_GROUPS
//   aDBF := {...}
// --------------------------------------------------
static function a_e_groups()
local aDbf

aDbf:={}
AADD(aDBf,{ "e_gr_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_desc", "C", 100, 0 })
AADD(aDBf,{ "e_gr_full_", "C", 100, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf



// --------------------------------------------------
// vraca matricu sa strukturom tabele E_GR_ATT
//   aDBF := {...}
// --------------------------------------------------
static function a_e_gr_att()
local aDbf

aDbf:={}
AADD(aDBf,{ "e_gr_at_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_at_de", "C", 100, 0 })
AADD(aDBf,{ "e_gr_at_re", "C", 1, 0 })
AADD(aDBf,{ "in_art_des", "C", 1, 0 })
AADD(aDBf,{ "e_gr_at_jo", "C", 20, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf



// ------------------------------------------------------
// vraca matricu sa strukturom tabele E_GR_VAL
//   aDBF := {...}
// ------------------------------------------------------
static function a_e_gr_val()
local aDbf

aDbf:={}
AADD(aDBf,{ "e_gr_vl_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_at_id", "N", 10, 0 })
AADD(aDBf,{ "e_gr_vl_de", "C", 100, 0 })
AADD(aDBf,{ "e_gr_vl_fu", "C", 100, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele AOPS
//   aDBF := {...}
// ------------------------------------------------------
static function a_aops()
local aDbf

aDbf:={}
AADD(aDBf,{ "aop_id", "N", 10, 0 })
AADD(aDBf,{ "aop_desc", "C", 100, 0 })
AADD(aDBf,{ "aop_full_d", "C", 100, 0 })
AADD(aDBf,{ "in_art_des", "C", 1, 0 })
AADD(aDBf,{ "aop_joker", "C", 20, 0 })
AADD(aDBf,{ "aop_unit", "C", 10, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele AOPS_ATT
//   aDBF := {...}
// ------------------------------------------------------
static function a_aops_att()
local aDbf

aDbf:={}
AADD(aDBf,{ "aop_att_id", "N", 10, 0 })
AADD(aDBf,{ "aop_id", "N", 10, 0 })
AADD(aDBf,{ "aop_att_de", "C", 100, 0 })
AADD(aDBf,{ "aop_att_fu", "C", 100, 0 })
AADD(aDBf,{ "in_art_des", "C", 1, 0 })
AADD(aDBf,{ "aop_att_jo", "C", 20, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele CUSTOMS
//   aDBF := {...}
// ------------------------------------------------------
static function a_customs()
local aDbf

aDbf:={}
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "cust_desc", "C", 250, 0 })
AADD(aDBf,{ "cust_addr", "C", 50, 0 })
AADD(aDBf,{ "cust_tel", "C", 100, 0 })
AADD(aDBf,{ "cust_ident", "C", 13, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele CONTACTS
//   aDBF := {...}
// ------------------------------------------------------
static function a_contacts()
local aDbf

aDbf:={}
AADD(aDBf,{ "cont_id", "N", 10, 0 })
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "cont_desc", "C", 150, 0 })
AADD(aDBf,{ "cont_tel", "C", 100, 0 })
AADD(aDBf,{ "cont_add_d", "C", 250, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


// ------------------------------------------------------
// vraca matricu sa strukturom tabele OBJECTS
//   aDBF := {...}
// ------------------------------------------------------
static function a_objects()
local aDbf

aDbf:={}
AADD(aDBf,{ "obj_id", "N", 10, 0 })
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "obj_desc", "C", 150, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf


		


