/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


FUNCTION set_a_dbf_kalk()

   set_a_sql_kalk_kalk()

   set_a_sql_kalk_doks_doks2( "kalk_doks", "KALK_DOKS", F_KALK_DOKS  )
   set_a_sql_kalk_doks_doks2( "kalk_doks2", "KALK_DOKS2", F_KALK_DOKS2 )
   set_a_sql_trfp( "trfp", "TRFP", F_TRFP )
   set_a_sql_trfp( "trfp2", "TRFP2", F_TRFP2 )

  // set_a_sql_sifarnik( "trfp3", "TRFP3", F_TRFP3      )
   set_a_sql_sifarnik( "objekti", "OBJEKTI", F_OBJEKTI    )

   set_a_dbf_temp( "kalk_imp_temp", "KALK_IMP_TEMP", F_KALK_IMP_TEMP )
   set_a_dbf_temp( "_kalk_kalk", "_KALK", F__KALK        )
   set_a_dbf_temp( "kalk_pripr", "KALK_PRIPR", F_KALK_PRIPR   )
   set_a_dbf_temp( "kalk_pripr2", "KALK_PRIPR2", F_KALK_PRIPR2  )
   set_a_dbf_temp( "kalk_pripr9", "KALK_PRIPR9", F_KALK_PRIPR9  )
   set_a_dbf_temp( "kalk_pript", "PRIPT", F_PRIPT       )

   set_a_dbf_temp( "kalk_pormp", "PORMP", F_PORMP        )

/*
   --set_a_dbf_temp( "kalk_doksrc", "KALK_DOKSRC", F_DOKSRC       )
   --set_a_dbf_temp( "p_kalk_doksrc", "P_KALK_DOKSRC", F_P_DOKSRC     )
*/

   set_a_dbf_temp( "kalk_ppprod", "PPPROD", F_PPPROD        )
   set_a_dbf_temp( "prodaja", "PRODAJA", F_PRODAJA        )

   set_a_dbf_temp( "kalk_pobjekti", "POBJEKTI", F_POBJEKTI      )
   set_a_dbf_temp( "kalk_prodnc", "PRODNC", F_PRODNC        )
   set_a_dbf_temp( "kalk_rvrsta", "RVRSTA", F_RVRSTA        )
   set_a_dbf_temp( "cache", "CACHE", F_CACHE         )

   set_a_dbf_temp( "kalk_rekap1", "REKAP1", F_REKAP1        )
   set_a_dbf_temp( "kalk_rekap2", "REKAP2", F_REKAP2        )
   set_a_dbf_temp( "kalk_reka22", "REKA22", F_REKA22        )

   set_a_dbf_temp( "kalk_r_uio", "R_UIO", F_R_UIO         )
   set_a_dbf_temp( "kalk_rpt_tmp", "RPT_TMP", F_RPT_TMP       )
   set_a_dbf_temp( "kalk_attr", "KALK_ATTR", F_KALK_ATTR )

   set_a_dbf_temp( "kalk_kartica", "KALK_KARTICA", F_KALK_KARTICA )

   set_a_dbf_temp( "topska", "TOPSKA", F_TMP_TOPSKA )
   set_a_dbf_temp( "katops", "KATOPS", F_TMP_KATOPS )

   RETURN .T.



FUNCTION set_a_sql_kalk_kalk()

   LOCAL _item, _alg, _tbl

   _tbl := "kalk_kalk"
   _item := hb_Hash()

   _item[ "alias" ] := "KALK"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_KALK
   _item[ "temp" ]  := .F.
   _item[ "sif" ] := .F.
   _item[ "sql" ] := .T.
   // _item[ "sql" ] := .T.  BUG_CPU100
   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // t_kalk_db.prg
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idfirma + field->idvd + field->brdok + field->rbr }
   _alg[ "dbf_key_empty_rec" ] := SPACE( 2 ) + SPACE( 2 ) + SPACE( FIELD_LEN_KALK_BRDOK ) + SPACE( FIELD_LEN_KALK_RBR )
   _alg[ "dbf_key_fields" ] := { "idfirma", "idvd", "brdok", "rbr" }
   _alg[ "sql_in" ]         := "rpad( idfirma,2) || rpad( idvd,2)  || rpad(brdok,8) || lpad(rbr,3)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   // algoritam 2
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idfirma + field->idvd + field->brdok }
   _alg[ "dbf_key_fields" ] := { "idfirma", "idvd", "brdok" }
   _alg[ "sql_in" ]         := "rpad( idfirma,2) || rpad( idvd,2)  || rpad(brdok,8)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "idfirma, idvd, brdok, rbr"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.

FUNCTION set_a_sql_kalk_doks_doks2( table, alias, wa )

   LOCAL _item, _alg, _tbl

   _tbl := table

   _item := hb_Hash()

   _item[ "alias" ] := alias
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := wa
   _item[ "temp" ]  := .F.
   _item[ "sif" ] := .F.
   _item[ "sql" ] := .T.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // t_kalk_db.prg
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idfirma + field->idvd + field->brdok }
   _alg[ "dbf_key_empty_rec" ] := SPACE( 2 ) + SPACE( 2 ) + SPACE( FIELD_LEN_KALK_BRDOK )
   _alg[ "dbf_key_fields" ] := { "idfirma", "idvd", "brdok" }
   _alg[ "sql_in" ]         := "rpad( idfirma,2) || rpad( idvd,2)  || rpad(brdok,8)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "idfirma, idvd, brdok"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.


FUNCTION set_a_sql_trfp( table, alias, wa )

   LOCAL _item, _alg, _tbl

   _tbl := table

   _item := hb_Hash()

   _item[ "alias" ] := alias
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := wa
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .T.
   _item[ "sif" ] := .F.
   _item[ "chk0" ] := .F.
   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idvd + field->shema + field->idkonto + field->id + field->idtarifa + field->idvn + field->naz }
   _alg[ "dbf_key_fields" ] := { "idvd", "shema", "idkonto", "id", "idtarifa", "idvn", "naz" }
   _alg[ "sql_in" ]         := " rpad( idvd,2) || rpad( shema,1)  || rpad(idkonto,8) || rpad(id,60) || rpad(idtarifa,6) || rpad(idvn,2) || rpad(naz,20) "
   _alg[ "dbf_tag" ]        := "ID"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "idvd, shema, idkonto, id, idtarifa"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.
