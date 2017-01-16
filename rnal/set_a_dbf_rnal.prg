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

#include "f18.ch"

FUNCTION set_a_dbf_rnal()

   // kumulativ
   set_a_dbf_rnal_docs()
   set_a_dbf_rnal_doc_it()
   set_a_dbf_rnal_doc_it2()
   set_a_dbf_rnal_doc_ops()
   set_a_dbf_rnal_doc_log()
   set_a_dbf_rnal_doc_lit()

   // sifre
   set_a_dbf_rnal_articles()
   set_a_dbf_rnal_elements()
   set_a_dbf_rnal_e_aops()
   set_a_dbf_rnal_e_att()
   set_a_dbf_rnal_e_groups()
   set_a_dbf_rnal_e_gr_att()
   set_a_dbf_rnal_e_gr_val()
   set_a_dbf_rnal_cust()
   set_a_dbf_rnal_cont()
   set_a_dbf_rnal_objects()
   set_a_dbf_rnal_aops()
   set_a_dbf_rnal_aops_att()
   set_a_dbf_rnal_ral()
   set_a_dbf_rnal_relation()

   // temp fakt tabele - ne idu na server
   set_a_dbf_temp( "rnal__docs",   "_DOCS", F__DOCS   )
   set_a_dbf_temp( "rnal__doc_it",   "_DOC_IT", F__DOC_IT  )
   set_a_dbf_temp( "rnal__doc_it2",   "_DOC_IT2", F__DOC_IT2  )
   set_a_dbf_temp( "rnal__doc_ops",   "_DOC_OPS", F__DOC_OPS  )
   set_a_dbf_temp( "rnal__doc_opst",   "_DOC_OPST", F__DOC_OPST )
   set_a_dbf_temp( "t_docit",   "T_DOCIT", F_T_DOCIT  )
   set_a_dbf_temp( "t_docit2",   "T_DOCIT2", F_T_DOCIT2  )
   set_a_dbf_temp( "t_docop",   "T_DOCOP", F_T_DOCOP  )
   set_a_dbf_temp( "t_pars",   "T_PARS", F_T_PARS  )
   set_a_dbf_temp( "_tmp1",   "_TMP1", F__TMP1  )
   set_a_dbf_temp( "_tmp2",   "_TMP2", F__TMP2  )

   RETURN .T.



FUNCTION set_a_dbf_rnal_docs()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_docs"

   hItem := hb_Hash()

   hItem[ "alias" ] := "DOCS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_DOCS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.

   hItem[ "algoritam" ] := {}
   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "doc_no"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.



FUNCTION set_a_dbf_rnal_doc_it()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_doc_it"

   hItem := hb_Hash()

   hItem[ "alias" ] := "DOC_IT"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_DOC_IT
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 ) + Str( field->doc_it_no, 4 ) + Str( field->art_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 }, { "doc_it_no", 4 }, { "art_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10) || lpad( doc_it_no::char(4),4)  || lpad(art_id::char(10),10) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   // algoritam 2 - nivo dokumenta
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 )  }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "doc_no, doc_it_no, art_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.



FUNCTION set_a_dbf_rnal_doc_it2()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_doc_it2"

   hItem := hb_Hash()

   hItem[ "alias" ] := "DOC_IT2"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_DOC_IT2
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 ) + Str( field->doc_it_no, 4 ) + Str( field->it_no, 4 ) }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 }, { "doc_it_no", 4 }, { "it_no", 4 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10) || lpad( doc_it_no::char(4),4)  || lpad(it_no::char(4),4) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 )  }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "doc_no, doc_it_no, it_no"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.



FUNCTION set_a_dbf_rnal_doc_ops()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_doc_ops"

   hItem := hb_Hash()

   hItem[ "alias" ] := "DOC_OPS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_DOC_OPS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 ) + Str( field->doc_it_no, 4 ) + Str( field->doc_op_no, 4 ) }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 }, { "doc_it_no", 4 }, { "doc_op_no", 4 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10) || lpad( doc_it_no::char(4),4)  || lpad( doc_op_no::char(4),4) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   // algoritam 2 - nivo dokumenta
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 )  }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "doc_no, doc_it_no, doc_op_no"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.



FUNCTION set_a_dbf_rnal_doc_log()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_doc_log"

   hItem := hb_Hash()

   hItem[ "alias" ] := "DOC_LOG"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_DOC_LOG
   hItem[ "temp" ]  := .F.
   hItem[ "sql" ]  := .T.
   hItem[ "sif" ] := .F.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 ) + Str( field->doc_log_no, 10 ) + DToS( field->doc_log_da ) + doc_log_ti }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 }, { "doc_log_no", 10 }, "doc_log_da", "doc_log_ti" }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10 ) || lpad( doc_log_no::char(10), 10 ) || to_char( doc_log_da, 'YYYYMMDD' ) || rpad( doc_log_ti, 8 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "doc_no, doc_log_no, doc_log_da, doc_log_ti"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.





FUNCTION set_a_dbf_rnal_doc_lit()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_doc_lit"

   hItem := hb_Hash()

   hItem[ "alias" ] := "DOC_LIT"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_DOC_LIT
   hItem[ "temp" ]  := .F.
   hItem[ "sql" ]  := .T.
   hItem[ "sif" ] := .F.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 ) + Str( field->doc_log_no, 10 ) + Str( field->doc_lit_no, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 }, { "doc_log_no", 10 }, { "doc_lit_no", 10 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10) || lpad( doc_log_no::char(10),10)  || lpad( doc_lit_no::char(10),10) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   // algoritam 2 - nivo dokumenta
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->doc_no, 10 )  }
   _alg[ "dbf_key_fields" ] := { { "doc_no", 10 } }
   _alg[ "sql_in" ]         := "lpad( doc_no::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "doc_no, doc_log_no, doc_lit_no"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_rnal_articles()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_articles"

   hItem := hb_Hash()

   hItem[ "alias" ] := "ARTICLES"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_ARTICLES
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->art_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "art_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( art_id::char(10), 10 ) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "art_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_rnal_elements()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_elements"

   hItem := hb_Hash()

   hItem[ "alias" ] := "ELEMENTS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_ELEMENTS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->art_id, 10 ) + Str( field->el_no, 4 ) + Str( field->el_id, 10 ) + Str( field->e_gr_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "art_id", 10 }, { "el_no", 4 }, { "el_id", 10 }, { "e_gr_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( art_id::char(10), 10 ) || lpad( el_no::char(4), 4 ) || lpad( el_id::char(10), 10 ) || lpad( e_gr_id::char(10), 10 ) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   // algoritam 2 - brisanje kompletnog artikla
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->art_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "art_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( art_id::char(10), 10 ) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )



   hItem[ "sql_order" ] := "art_id, el_no, el_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_rnal_e_aops()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_e_aops"

   hItem := hb_Hash()

   hItem[ "alias" ] := "E_AOPS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_E_AOPS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->el_id, 10 ) + Str( field->el_op_id, 10 ) + Str( field->aop_id, 10 ) + Str( field->aop_att_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "el_id", 10 }, { "el_op_id", 10 }, { "aop_id", 10 }, { "aop_att_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( el_id::char(10), 10 ) || lpad( el_op_id::char(10), 10 ) || lpad( aop_id::char(10), 10) || lpad( aop_att_id::char(10), 10 ) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "el_id, el_op_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_rnal_e_att()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_e_att"

   hItem := hb_Hash()

   hItem[ "alias" ] := "E_ATT"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_E_ATT
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->el_id, 10 ) + Str( field->el_att_id, 10 ) + Str( field->e_gr_at_id, 10 ) + Str( field->e_gr_vl_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "el_id", 10 }, { "el_att_id", 10 }, { "e_gr_at_id", 10 }, { "e_gr_vl_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( el_id::char(10), 10 ) || lpad( el_att_id::char(10), 10 ) || lpad( e_gr_at_id::char(10), 10 ) || lpad( e_gr_vl_id::char(10), 10 ) "
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "el_id, el_att_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.





FUNCTION set_a_dbf_rnal_e_groups()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_e_groups"

   hItem := hb_Hash()

   hItem[ "alias" ] := "E_GROUPS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_E_GROUPS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->e_gr_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "e_gr_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( e_gr_id::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "e_gr_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.



FUNCTION set_a_dbf_rnal_e_gr_att()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_e_gr_att"

   hItem := hb_Hash()

   hItem[ "alias" ] := "E_GR_ATT"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_E_GR_ATT
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->e_gr_at_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "e_gr_at_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( e_gr_at_id::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "e_gr_at_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.





FUNCTION set_a_dbf_rnal_e_gr_val()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_e_gr_val"

   hItem := hb_Hash()

   hItem[ "alias" ] := "E_GR_VAL"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_E_GR_VAL
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->e_gr_vl_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "e_gr_vl_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( e_gr_vl_id::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "e_gr_vl_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.





FUNCTION set_a_dbf_rnal_cust()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_customs"

   hItem := hb_Hash()

   hItem[ "alias" ] := "CUSTOMS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_CUSTOMS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->cust_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "cust_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( cust_id::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "cust_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_rnal_cont()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_contacts"

   hItem := hb_Hash()

   hItem[ "alias" ] := "CONTACTS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_CONTACTS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->cust_id, 10 ) + Str( field->cont_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "cust_id", 10 }, { "cont_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( cust_id::char(10), 10 ) || lpad( cont_id::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "2"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "cont_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.






FUNCTION set_a_dbf_rnal_objects()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_objects"

   hItem := hb_Hash()

   hItem[ "alias" ] := "OBJECTS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_OBJECTS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->obj_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "obj_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( obj_id::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "obj_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.



FUNCTION set_a_dbf_rnal_aops()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_aops"

   hItem := hb_Hash()

   hItem[ "alias" ] := "AOPS"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_AOPS
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->aop_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "aop_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( aop_id::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "aop_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_rnal_aops_att()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_aops_att"

   hItem := hb_Hash()

   hItem[ "alias" ] := "AOPS_ATT"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_AOPS_ATT
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->aop_att_id, 10 ) }
   _alg[ "dbf_key_fields" ] := { { "aop_att_id", 10 } }
   _alg[ "sql_in" ]         := "lpad( aop_att_id::char(10), 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "aop_att_id"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.


FUNCTION set_a_dbf_rnal_ral()

   LOCAL hItem, _alg, _tbl

   _tbl := "rnal_ral"

   hItem := hb_Hash()

   hItem[ "alias" ] := "RAL"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_RAL
   hItem[ "temp" ]  := .F.
   hItem[ "sql" ]   := .T.
   hItem[ "sif" ] := .T.

   hItem[ "algoritam" ] := {}

   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| Str( field->id, 5 ) + Str( field->gl_tick, 2 ) }
   _alg[ "dbf_key_fields" ] := { { "id", 5 }, { "gl_tick", 2 } }
   _alg[ "sql_in" ]         := "lpad( id::char(5), 5 ) || lpad( gl_tick::char(2), 2 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "id, gl_tick"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.


FUNCTION set_a_dbf_rnal_relation()

   LOCAL hItem, _alg, _tbl

   _tbl := "relation"
   hItem := hb_Hash()

   hItem[ "alias" ] := "RELATION"
   hItem[ "table" ] := _tbl
   hItem[ "wa" ]    := F_RELATION
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.

   hItem[ "algoritam" ] := {}
   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| field->tfrom + field->tto + field->tfromid }
   _alg[ "dbf_key_fields" ] := { "tfrom", "tto", "tfromid" }
   _alg[ "sql_in" ]         := "rpad( tfrom, 10 ) || rpad( tto, 10 ) || rpad( tfromid, 10 )"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], _alg )

   hItem[ "sql_order" ] := "tfrom, tto, tfromid"

   f18_dbfs_add( _tbl, @hItem )

   RETURN .T.
