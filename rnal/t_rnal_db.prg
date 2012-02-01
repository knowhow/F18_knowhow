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


#include "rnal.ch"
#include "hbclass.ch"

// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbRnal INHERIT TDB 
	method New
    method skloniSezonu	
	method setgaDBFs	
	method install	
	method ostalef	
	method obaza	
	method kreiraj	
	method konvZn
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::cName:="RNAL"
 ::lAdmin:=.f.

 ::kreiraj()

return self



// --------------------------------------------
// --------------------------------------------
method skloniSezonu(cSezona, finverse, fda, lNulirati, fRS)
local cScr

save screen to cScr

if fda==nil
	fDA:=.f.
endif
if finverse==nil
  	finverse:=.f.
endif
if lNulirati==nil
  	lNulirati:=.f.
endif
if fRS==nil
  	// mrezna radna stanica , sezona je otvorena
  	fRS:=.f.
endif

if fRS // radna stanica
  	if file(ToUnix(PRIVPATH+cSezona+"\P_RNAL.DBF"))
      		return
  	endif
  	aFilesK:={}
  	aFilesS:={}
  	aFilesP:={}
endif

if KLevel<>"0"
	MsgBeep("Nemate pravo na koristenje ove opcije")
endif

cls

if fRS
	// mrezna radna stanica
	? "Formiranje DBF-ova u privatnom direktoriju, RS ...."
endif

?

if finverse
 	? "Prenos iz  sezonskih direktorija u radne podatke"
else
	? "Prenos radnih podataka u sezonske direktorije"
endif
?

// privatni
fNul:=.f.
Skloni(PRIVPATH,"_DOCS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_IT.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_IT2.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FMK.INI",cSezona,finverse,fda,fnul)

if fRS
	// mrezna radna stanica!!! , baci samo privatne direktorije
 	?
 	?
 	?
 	Beep(4)
 	? "pritisni nesto za nastavak.."

 	restore screen from cScr
 	return
endif

if lNulirati
	fnul:=.t.
else
	fnul:=.f.
endif  

// kumulativ
Skloni(KUMPATH,"DOCS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_IT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_IT2.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_LOG.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_LIT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)

fnul := .f.

// prenesi ali ne prazni, ovo su parametri...
Skloni(KUMPATH,"KPARAMS.DBF",cSezona,finverse,fda,fnul)

// sifrarnik
Skloni(SIFPATH,"AOPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"AOPS_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ARTICLES.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ELEMENTS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_AOPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GROUPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GR_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GR_VAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"CUSTOMS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"OBJECTS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"RAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"CONTACTS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

?
?
?

Beep(4)

? "pritisni nesto za nastavak.."

restore screen from cScr
return


// --------------------------------------------
// --------------------------------------------
method setgaDBFs()
// prebaceno u f18_utils.prg
return


// ----------------------------------------
// ----------------------------------------
method install()
  install_start(goModul,.f.)
return


// ----------------------------------------
// ----------------------------------------
method kreiraj(nArea)

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea == nil)
	nArea:=-1
endif

Beep(1)

if (nArea <> -1)
	CreSystemDb( nArea )
endif

cre_tbls(nArea, "docs")
cre_tbls(nArea, "_docs")
cre_tbls(nArea, "doc_it")
cre_tbls(nArea, "_doc_it")
cre_tbls(nArea, "doc_ops")
cre_tbls(nArea, "_doc_ops")
cre_tbls(nArea, "doc_it2")
cre_tbls(nArea, "_doc_it2")
cre_tbls(nArea, "doc_log")
cre_tbls(nArea, "doc_lit")
cre_tbls(nArea, "articles")
cre_tbls(nArea, "elements")
cre_tbls(nArea, "e_aops")
cre_tbls(nArea, "e_att")
cre_tbls(nArea, "e_groups")
cre_tbls(nArea, "e_gr_att")
cre_tbls(nArea, "e_gr_val")
cre_tbls(nArea, "aops")
cre_tbls(nArea, "aops_att")
cre_tbls(nArea, "customs")
cre_tbls(nArea, "contacts")
cre_tbls(nArea, "objects")

// kreiranje tabele pretraga parametri
_cre_fnd_par()

// kreiraj relacije
cre_relation()

// kreiraj pravila : RULES
cre_fmkrules()

// kreiraj pravila : RULES cdx files
c_rule_cdx()

// kreiraj tabelu "RAL"
c_tbl_ral()

return

// ----------------------------------------------
// vraca matricu sa strukturom tabele DOCS
//   aDBF := {...}
// ----------------------------------------------
function a_docs()
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
function a_doc_it()
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
function a_doc_it2()
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
function a_doc_ops()
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
function a_doc_log()
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
function a_doc_lit()
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
function a_articles()
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
function a_elements()
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
function a_e_att()
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
function a_e_aops()
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
function a_e_groups()
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
function a_e_gr_att()
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
function a_e_gr_val()
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
function a_aops()
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
function a_aops_att()
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
function a_customs()
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
function a_contacts()
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
function a_objects()
local aDbf

aDbf:={}
AADD(aDBf,{ "obj_id", "N", 10, 0 })
AADD(aDBf,{ "cust_id", "N", 10, 0 })
AADD(aDBf,{ "obj_desc", "C", 150, 0 })
AADD(aDBf,{ "match_code", "C", 10, 0 })

return aDbf



// ------------------------------------------------
// kreiranje tabela
//  nArea - podrucje
//  cTable - naziv tabele
// ------------------------------------------------
static function cre_tbls(nArea, cTable)
local nArea2 := 0
local aDbf
local cPath := KUMPATH

do case 
	case cTable == "docs"
		nArea2 := F_DOCS
	case cTable == "_docs"
		nArea2 := F__DOCS
	case cTable == "doc_it"
		nArea2 := F_DOC_IT
	case cTable == "_doc_it"
		nArea2 := F__DOC_IT
	case cTable == "doc_it2"
		nArea2 := F_DOC_IT2
	case cTable == "_doc_it2"
		nArea2 := F__DOC_IT2
	case cTable == "doc_ops"
		nArea2 := F_DOC_OPS
	case cTable == "_doc_ops"
		nArea2 := F__DOC_OPS
	case cTable == "doc_log"
		nArea2 := F_DOC_LOG
	case cTable == "doc_lit"
		nArea2 := F_DOC_LIT
	case cTable == "e_groups"
		nArea2 := F_E_GROUPS
	case cTable == "e_gr_att"
		nArea2 := F_E_GR_ATT
	case cTable == "e_gr_val"
		nArea2 := F_E_GR_VAL
	case cTable == "aops"
		nArea2 := F_AOPS
	case cTable == "aops_att"
		nArea2 := F_AOPS_ATT
	case cTable == "articles"
		nArea2 := F_ARTICLES
	case cTable == "elements"
		nArea2 := F_ELEMENTS
	case cTable == "e_aops"
		nArea2 := F_E_AOPS
	case cTable == "e_att"
		nArea2 := F_E_ATT
	case cTable == "customs"
		nArea2 := F_CUSTOMS
	case cTable == "contacts"
		nArea2 := F_CONTACTS
	case cTable == "objects"
		nArea2 := F_OBJECTS
endcase

if (nArea==-1 .or. nArea == nArea2)
	do case 
		case cTable == "docs" 
			aDbf := a_docs()
			cPath := KUMPATH
			
		case cTable == "_docs"
			aDbf := a_docs()
			cPath := PRIVPATH
			
		case cTable == "doc_it" 
			aDbf := a_doc_it()
			cPath := KUMPATH
			
		case cTable == "_doc_it"
			aDbf := a_doc_it()
			cPath := PRIVPATH
		
		case cTable == "doc_it2"
			aDbf := a_doc_it2()
			cPath := KUMPATH

		case cTable == "_doc_it2"
			aDbf := a_doc_it2()
			cPath := PRIVPATH
		
		case cTable == "doc_ops" 
			aDbf := a_doc_ops()
			cPath := KUMPATH
			
		case cTable == "_doc_ops"
			aDbf := a_doc_ops()
			cPath := PRIVPATH
			
		case cTable == "doc_log"
			aDbf := a_doc_log()
			cPath := KUMPATH
			
		case cTable == "doc_lit"
			aDbf := a_doc_lit()
			cPath := KUMPATH
			
		case cTable == "articles"
			aDbf := a_articles()
			cPath := SIFPATH
			
		case cTable == "elements"
			aDbf := a_elements()
			cPath := SIFPATH
			
		case cTable == "e_aops"
			aDbf := a_e_aops()
			cPath := SIFPATH
			
		case cTable == "e_att"
			aDbf := a_e_att()
			cPath := SIFPATH
			
		case cTable == "e_groups"
			aDbf := a_e_groups()
			cPath := SIFPATH
			
		case cTable == "e_gr_att"
			aDbf := a_e_gr_att()
			cPath := SIFPATH
			
		case cTable == "e_gr_val"
			aDbf := a_e_gr_val()
			cPath := SIFPATH
			
		case cTable == "customs"
			aDbf := a_customs()
			cPath := SIFPATH
			
		case cTable == "contacts"
			aDbf := a_contacts()
			cPath := SIFPATH
			
		case cTable == "objects"
			aDbf := a_objects()
			cPath := SIFPATH
			
		case cTable == "aops"
			aDbf := a_aops()
			cPath := SIFPATH
			
		case cTable == "aops_att"
			aDbf := a_aops_att()
			cPath := SIFPATH
			
	endcase
	
	if !FILE(f18_ime_dbf( cTable ))
		DBcreate2( cTable + ".DBF", aDbf )
	endif

	do case 
		case (nArea2 == F_DOCS) .or. (nArea2 == F__DOCS)
			CREATE_INDEX("1", "STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("A", "STR(doc_status,2)+STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(doc_priori,4)+DTOS(doc_date)+STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(doc_priori,4)+DTOS(doc_dvr_da)+STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("D1", "DTOS(doc_date)+STR(doc_no,10)", cPath + cTable, .t.)
			CREATE_INDEX("D2", "DTOS(doc_dvr_da)+STR(doc_no,10)", cPath + cTable, .t.)
		case (nArea2 == F_DOC_IT) .or. (nArea2 == F__DOC_IT)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(art_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(art_id,10)+STR(doc_no,10)+STR(doc_it_no,4)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(doc_no,10)+STR(art_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_DOC_IT2) .or. (nArea2 == F__DOC_IT2)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(it_no,4)", cPath + cTable, .t.)
			CREATE_INDEX("2", "art_id+STR(doc_no,10)+STR(doc_it_no,4)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(doc_no,10)+art_id", cPath + cTable, .t.)
	
		case (nArea2 == F_DOC_OPS) .or. (nArea2 == F__DOC_OPS)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_op_no,4)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_it_el_,10)", cPath + cTable, .t.)
		case (nArea2 == F_DOC_LOG)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_log_no,10)+DTOS(doc_log_da)+doc_log_ti", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(doc_no,10)+doc_log_ty+STR(doc_log_no,10)", cPath + cTable, .t.)
		case (nArea2 == F_DOC_LIT)
			CREATE_INDEX("1", "STR(doc_no,10)+STR(doc_log_no,10)+STR(doc_lit_no,10)", cPath + cTable, .t.)
		case (nArea2 == F_ARTICLES)
			CREATE_INDEX("1", "STR(art_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "PADR(art_desc,100)", cPath + cTable, .t.)
		case (nArea2 == F_ELEMENTS)
			CREATE_INDEX("1", "STR(art_id,10)+STR(el_no,4)+STR(el_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(el_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_E_AOPS)
			CREATE_INDEX("1", "STR(el_id,10)+STR(el_op_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(el_op_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_E_ATT)
		  	CREATE_INDEX("1", "STR(el_id,10)+STR(el_att_id,10)", cPath + cTable, .t.)
		  	CREATE_INDEX("2", "STR(el_att_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_E_GROUPS)
		  	CREATE_INDEX("1", "STR(e_gr_id,10)", cPath + cTable, .t.)
		  	CREATE_INDEX("2", "PADR(e_gr_desc,20)", cPath + cTable, .t.)
		
		case (nArea2 == F_CUSTOMS)
			CREATE_INDEX("1", "STR(cust_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_CONTACTS)
			CREATE_INDEX("1", "STR(cont_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(cust_id,10)+STR(cont_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(cust_id,10)+cont_desc", cPath + cTable, .t.)
			CREATE_INDEX("4", "cont_desc", cPath + cTable, .t.)
		
		case (nArea2 == F_OBJECTS)
			CREATE_INDEX("1", "STR(obj_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2", "STR(cust_id,10)+STR(obj_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("3", "STR(cust_id,10)+obj_desc", cPath + cTable, .t.)
			CREATE_INDEX("4", "obj_desc", cPath + cTable, .t.)
	
		case (nArea2 == F_AOPS)
			CREATE_INDEX("1", "STR(aop_id,10)", cPath + cTable, .t.)
		case (nArea2 == F_AOPS_ATT)
			CREATE_INDEX("1","STR(aop_att_id,10)", cPath + cTable, .t.)
			CREATE_INDEX("2","STR(aop_id,10)+STR(aop_att_id,10)", cPath + cTable, .t.)
		
		case (nArea2 == F_E_GR_ATT)
			CREATE_INDEX("1","STR(e_gr_at_id,10,0)", cPath + cTable, .t.)
			CREATE_INDEX("2","STR(e_gr_id,10,0)+e_gr_at_re+STR(e_gr_at_id,10)", cPath + cTable, .t.)
		
		case (nArea2 == F_E_GR_VAL)
			CREATE_INDEX("1","STR(e_gr_vl_id,10,0)", cPath + cTable, .t.)
			CREATE_INDEX("2","STR(e_gr_at_id,10,0)+STR(e_gr_vl_id,10,0)", cPath + cTable, .t.)
		
	endcase

endif
return 



method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_DOCS .or. i==F__DOCS
	lIdiDalje:=.t.
endif

if i==F_DOC_IT .or. i==F__DOC_IT
	lIdiDalje:=.t.
endif

if i==F_DOC_IT2 .or. i==F__DOC_IT2
	lIdiDalje:=.t.
endif

if i==F_DOC_OPS .or. i==F__DOC_OPS
	lIdiDalje:=.t.
endif

if i==F_DOC_LOG .or. i==F_DOC_LIT
	lIdiDalje:=.t.
endif

if i==F_ARTICLES .or. i==F_ELEMENTS .or. i==F_E_AOPS .or. i==F_E_ATT
	lIdiDalje:=.t.
endif

if i==F_E_GROUPS .or. i==F_E_GR_ATT .or. i==F_E_GR_VAL
	lIdiDalje:=.t.
endif

if i==F_CUSTOMS .or. i==F_CONTACTS .or. i==F_OBJECTS
	lIdiDalje:=.t.
endif

if i==F_AOPS .or. i==F_AOPS_ATT
	lIdiDalje:=.t.
endif


if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	if gAppSrv 
		? "OPEN: " + cDbfName + ".DBF"
		if !File(cDbfName + ".DBF")
			? "Fajl " + cDbfName + ".dbf ne postoji!!!"
			use
			return
		endif
	endif
	select(i)
	usex(cDbfName)
else
	use
	return
endif

return


method ostalef()
close all
return



method konvZn()
local cIz:="7"
local cU:="8"
local aPriv:={}
local aKum:={}
local aSif:={}
local GetList:={}
local cSif:="D"
local cKum:="D"
local cPriv:="D"

if !gAppSrv
	IF !SigmaSif("KZ      ")
   		RETURN
 	ENDIF
	Box(,8,50)
  	@ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  	@ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  	@ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  	@ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  	@ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  	READ
  	IF LASTKEY()==K_ESC
		BoxC()
		RETURN
	ENDIF
  	IF Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    		BoxC()
		RETURN
  	ENDIF
 	BoxC()
else
	?
	cKonvertTo:=IzFmkIni("FMK","KonvertTo","78",EXEPATH)
	
	if cKonvertTo=="78"
		cIz:="7"
		cU:="8"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU 
	elseif cKonvertTo=="87"
		cIz:="8"
		cU:="7"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU 
	else // pitaj
		?
		@ 10, 2 SAY "Trenutni standard (7/8)        " GET cIz VALID cIz$"78" PICT "9"
		?
		@ 11, 2 SAY "Konvertovati u standard (7/8/A)" GET cU VALID cU$"78A" PICT "@!"
		read
	endif
	cSif:="D"
	cKum:="D"
	cPriv:="D"
endif
 
aKum  := { F_DOCS, F_DOC_IT, F_DOC_OPS, F_DOC_LOG, F_DOC_LIT }
aPriv := { F__DOCS, F__DOC_IT, F__DOC_OPS }
aSif  := { F_AOPS, F_AOPS_ATT, F_E_GROUPS, F_E_GR_ATT, F_E_GR_VAL, F_ARTICLES, F_ELEMENTS, F_E_AOPS, F_E_ATT, F_OBJECTS, F_CUSTOMS, F_CONTACTS }

if cSif == "N"
	aSif := {}
endif
if cKum == "N"
	aKum := {}
endif
if cPriv == "N"
	aPriv := {}
endif

KZNbaza(aPriv,aKum,aSif,cIz,cU)
return


method scan
return



