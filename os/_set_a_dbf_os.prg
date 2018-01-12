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


FUNCTION set_a_dbf_os()

   LOCAL hAlgoritam

   // kumulativne tabele
   set_a_dbf_os_sii_promj( "os_promj", "PROMJ", F_PROMJ )
   set_a_dbf_os_sii_promj( "sii_promj", "SII_PROMJ", F_SII_PROMJ )

   // tabele sa strukturom sifarnika (id je primarni ključ)
   // u našem slučaju to su i os i sii (glavne tabele)

   // OS CREATE_INDEX("1", "id+idam+dtos(datum)", _alias )
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_fields" ] := { "id" }
   hAlgoritam[ "dbf_tag" ]        := "1"
   hAlgoritam[ "sql_in" ]        := "ID"
   hAlgoritam[ "dbf_key_block" ] := {|| field->id }


   set_a_sql_sifarnik( "os_os", "OS", F_OS, hAlgoritam )
   set_a_sql_sifarnik( "sii_sii", "SII", F_SII, hAlgoritam )

   set_a_sql_sifarnik( "os_k1", "K1", F_K1 )
   set_a_sql_sifarnik( "os_amort", "AMORT", F_AMORT )
   set_a_sql_sifarnik( "os_reval", "REVAL", F_REVAL )

   // temp epdv tabele - ne idu na server
   //set_a_dbf_temp( "os_invent", "INVENT", F_INVENT )

   RETURN .T.




STATIC FUNCTION set_a_dbf_os_sii_promj( table, alias, area )

   LOCAL _item, hAlgoritam, _tbl

   _tbl := table
   _item := hb_Hash()

   _item[ "alias" ] := alias
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := area

   // temporary tabela - nema semafora
   _item[ "temp" ]  := .F.
   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ]  := {|| field->id + field->tip + DToS( field->datum ) + field->opis }
   hAlgoritam[ "dbf_key_fields" ] := { "id", "tip", "datum", "opis" }
   hAlgoritam[ "sql_in" ]         := " rpad(id, 10) || rpad(tip, 2) || to_char(datum, 'YYYYMMDD') || rpad(opis, 30)"
   hAlgoritam[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], hAlgoritam )

   _item[ "sql_order" ] := "id, tip, datum, opis"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.
