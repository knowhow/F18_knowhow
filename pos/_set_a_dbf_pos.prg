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



FUNCTION set_a_dbf_pos()

   set_a_dbf_pos_pos()
   set_a_dbf_pos_doks()
   set_a_dbf_pos_promvp()
   set_a_dbf_pos_dokspf()

   // tabele sa strukturom sifarnika (id je primarni ključ)
   set_a_dbf_sifarnik( "pos_strad", "STRAD", F_STRAD   )
   set_a_dbf_sifarnik( "pos_osob", "OSOB", F_OSOB   )
   set_a_dbf_sifarnik( "pos_kase", "KASE", F_KASE  )
   set_a_dbf_sifarnik( "pos_odj", "ODJ", F_ODJ  )


   // temp fakt tabele - ne idu na server
   set_a_dbf_temp( "_pos_pos",   "_POS", F__POS  )
   set_a_dbf_temp( "_pos_posp",   "_POSP", F__POSP  )
   set_a_dbf_temp( "_pos_pripr",   "_POS_PRIPR", F__PRIPR  )
   set_a_dbf_temp( "pos_priprg",   "PRIPRG", F_PRIPRG  )
   set_a_dbf_temp( "pos_priprz",   "PRIPRZ", F_PRIPRZ  )
   set_a_dbf_temp( "pos_k2c",   "K2C", F_K2C  )
   set_a_dbf_temp( "pos_mjtrur",   "MJTRUR", F_MJTRUR  )
   set_a_dbf_temp( "pos_robaiz",   "ROBAIZ", F_ROBAIZ  )
   set_a_dbf_temp( "pos_razdr",   "RAZDR", F_RAZDR  )
   set_a_dbf_temp( "pos_uredj",   "UREDJ", F_UREDJ  )
   //set_a_dbf_temp( "pos_dio",   "DIO", F_DIO  )
   set_a_dbf_temp( "pos_mars",   "MARS", F_MARS  )


   RETURN .T.



FUNCTION set_a_dbf_pos_pos()

   LOCAL _item, _alg, _tbl

   _tbl := "pos_pos"

   _item := hb_Hash()

   _item[ "alias" ] := "POS"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_POS
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .F.

   _item[ "algoritam" ] := {}


   // algoritam 1 - default
   // CREATE_INDEX ("IDS_SEM", "IdPos+IdVd+dtos(datum)+BrDok+rbr", _alias )
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idpos + field->idvd + DToS( field->datum ) + field->brdok + field->rbr }
   _alg[ "dbf_key_empty_rec" ] := SPACE( 2 ) + SPACE( 2 ) + DToS( CTOD("") ) + SPACE( FIELD_LEN_POS_BRDOK ) + SPACE( FIELD_LEN_POS_RBR )

   _alg[ "dbf_key_fields" ] := { "idpos", "idvd", "datum", "brdok", "rbr" }
   _alg[ "sql_in" ]         := "rpad( idpos,2) || rpad( idvd,2)  || to_char(datum, 'YYYYMMDD') || rpad(brdok,6) || lpad(rbr,5)"
   _alg[ "dbf_tag" ]        := "IDS_SEM"
   AAdd( _item[ "algoritam" ], _alg )

   // algoritam 2 - dokument
   // CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok+idroba", _alias )
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idpos + field->idvd + DToS( field->datum ) + field->brdok }
   _alg[ "dbf_key_fields" ] := { "idpos", "idvd", "datum", "brdok" }
   _alg[ "sql_in" ]    := "rpad(idpos,2) || rpad(idvd, 2) || to_char(datum, 'YYYYMMDD') || rpad(brdok, 6)"
   _alg[ "dbf_tag" ]    := "1"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "idpos, idvd, datum, brdok, rbr"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.



FUNCTION set_a_dbf_pos_doks()

   LOCAL _item, _alg, _tbl

   _tbl := "pos_doks"

   _item := hb_Hash()

   _item[ "alias" ] := "POS_DOKS"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_POS_DOKS
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .F.

   _item[ "algoritam" ] := {}

   // CREATE_INDEX ("1", "IdPos+IdVd+dtos(datum)+BrDok", _alias )

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idpos + field->idvd + DToS( field->datum ) + field->brdok }
   _alg[ "dbf_key_empty_rec" ] := SPACE( 2 ) + SPACE( 2 ) + DToS( CTOD("") ) + SPACE( FIELD_LEN_POS_BRDOK )

   _alg[ "dbf_key_fields" ] := { "idpos", "idvd", "datum", "brdok" }
   _alg[ "sql_in" ]         := "rpad( idpos,2) || rpad( idvd,2)  || to_char(datum, 'YYYYMMDD') || rpad(brdok,6)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "idpos, idvd, datum, brdok"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.




FUNCTION set_a_dbf_pos_promvp()

   LOCAL _item, _alg, _tbl

   _tbl := "pos_promvp"

   _item := hb_Hash()

   _item[ "alias" ] := "PROMVP"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_PROMVP
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| DToS( field->datum ) }
   _alg[ "dbf_key_fields" ] := { "datum" }
   _alg[ "sql_in" ]         := "to_char(datum,'YYYYMMDD')"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "datum"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.



FUNCTION set_a_dbf_pos_dokspf()

   LOCAL _item, _alg, _tbl

   _tbl := "pos_dokspf"

   _item := hb_Hash()

   _item[ "alias" ] := "DOKSPF"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_DOKSPF
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // CREATE_INDEX( "1", "idpos+idvd+DToS(datum)+brdok", _alias )
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idpos + field->idvd + DToS( field->datum ) + field->brdok }
   _alg[ "dbf_key_fields" ] := { "idpos", "idvd", "datum", "brdok" }
   _alg[ "sql_in" ]         := "rpad( idpos,2) || rpad( idvd,2)  || to_char(datum, 'YYYYMMDD') || rpad(brdok,6)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   // algoritam 2
   // CREATE_INDEX( "2", "knaz", _alias )
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->knaz }
   _alg[ "dbf_key_fields" ] := { "knaz" }
   _alg[ "sql_in" ]         := "rpad( knaz, 35 )"
   _alg[ "dbf_tag" ]        := "2"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "idpos, idvd, datum, brdok"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.
