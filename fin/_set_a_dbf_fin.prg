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


FUNCTION set_a_dbf_fin()

   set_a_dbf_fin_suban()
   set_a_dbf_fin_anal()
   set_a_dbf_fin_sint()
   set_a_dbf_fin_nalog()

   //set_a_dbf_fin_parek()
   //set_a_dbf_fin_koliz()
   //set_a_dbf_fin_koniz()
   //set_a_dbf_fin_izvje()
   //set_a_dbf_fin_zagli()
   //set_a_dbf_fin_budzet()

//   set_a_dbf_sifarnik( "fin_funk", "FUNK",       F_FUNK       )
//   set_a_dbf_sifarnik( "fin_fond", "FOND",       F_FOND       )
//   set_a_dbf_sifarnik( "fin_buiz", "BUIZ",       F_BUIZ       )
//   set_a_dbf_sifarnik( "fin_ulimit", "ULIMIT",       F_ULIMIT     )

   set_a_sql_sifarnik( "ks", "KS",       F_KS         )

   set_a_dbf_temp( "fin_konto", "_KONTO",       F__KONTO   )
   set_a_dbf_temp( "fin_partn", "_PARTN",       F__PARTN   )
   set_a_dbf_temp( "fin_pripr", "FIN_PRIPR", F_FIN_PRIPR  )
   set_a_dbf_temp( "fin_psuban", "PSUBAN",       F_PSUBAN     )
   set_a_dbf_temp( "fin_panal", "PANAL",       F_PANAL      )
   set_a_dbf_temp( "fin_psint", "PSINT",       F_PSINT      )
   set_a_dbf_temp( "fin_pnalog", "PNALOG",       F_PNALOG     )

   set_a_dbf_temp( "fin_bbklas", "BBKLAS",       F_BBKLAS       )
   set_a_dbf_temp( "fin_ios", "IOS",       F_IOS    )
   set_a_dbf_temp( "fin_ostav", "OSTAV",       F_OSTAV     )
   set_a_dbf_temp( "fin_osuban", "OSUBAN",       F_OSUBAN    )
   set_a_dbf_temp( "fin_komp_dug", "KOMP_DUG",       F_FIN_KOMP_DUG     )
   set_a_dbf_temp( "fin_komp_pot", "KOMP_POT",       F_FIN_KOMP_POT     )
   set_a_dbf_temp( "kam_pripr", "KAM_PRIPR", F_KAMPRIPR  )
   set_a_dbf_temp( "kam_kamat", "KAM_KAMAT", F_KAMAT )

   RETURN .T.



FUNCTION set_a_dbf_fin_suban()

   LOCAL hAlgoritam, cTable, hItem

   cTable := "fin_suban"

   hItem := hb_Hash()

   hItem[ "alias" ] := "SUBAN"
   hItem[ "table" ] := cTable
   hItem[ "wa" ]    := F_SUBAN
   hItem[ "temp" ]  := .F.
   hItem[ "algoritam" ] := {}
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .T.

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ]  := {|| field->idfirma + field->idvn + field->brnal + STR(field->rbr,5,0) }
   hAlgoritam[ "dbf_key_fields" ] := { "idfirma", "idvn", "brnal", {"rbr",5} }
   hAlgoritam[ "sql_in" ]         := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr::char(5),5)"
   hAlgoritam[ "dbf_tag" ]        := "4"
   AAdd( hItem[ "algoritam" ], hAlgoritam )


   // algoritam 2 - dokument
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ]  := {|| field->idfirma + field->idvn + field->brnal }
   hAlgoritam[ "dbf_key_fields" ] := { "idfirma", "idvn", "brnal" }
   hAlgoritam[ "sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
   hAlgoritam[ "dbf_tag" ]    := "4"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   // za full sinhronizaciju trebamo jedinstveni poredak
   hItem[ "sql_order" ] := "idfirma, idvn, brnal, rbr"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.


FUNCTION set_a_dbf_fin_anal()

   LOCAL hItem
   LOCAL hAlgoritam, cTable

   cTable := "fin_anal"

   hItem := hb_Hash()

   hItem[ "alias" ] := "ANAL"
   hItem[ "wa" ]    := F_ANAL
   hItem[ "table" ] := cTable
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .T.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->idfirma + field->idvn + field->brnal + field->rbr }
   hAlgoritam[ "dbf_key_fields" ] := { "idfirma", "idvn", "brnal", "rbr" }
   hAlgoritam[ "sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 3)"
   hAlgoritam[ "dbf_tag" ]   := "2"
   AAdd( hItem[ "algoritam" ], hAlgoritam )


   // algoritam 2 - dokument
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ]  := {|| field->idfirma + field->idvn + field->brnal }
   hAlgoritam[ "dbf_key_fields" ] := { "idfirma", "idvn", "brnal" }
   hAlgoritam[ "sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
   hAlgoritam[ "dbf_tag" ]    := "2"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   // za full sinhronizaciju trebamo jedinstveni poredak
   hItem[ "sql_order" ] := "idfirma, idvn, brnal, rbr"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.



FUNCTION set_a_dbf_fin_sint()

   LOCAL hAlgoritam, cTable, hItem

   cTable := "fin_sint"

   hItem := hb_Hash()

   hItem[ "alias" ] := "SINT"
   hItem[ "table" ] := cTable
   hItem[ "wa" ]    := F_SINT
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .T.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->idfirma + field->idvn + field->brnal + field->rbr }
   hAlgoritam[ "dbf_key_fields" ] := { "idfirma", "idvn", "brnal", "rbr" }
   hAlgoritam[ "sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 3)"
   hAlgoritam[ "dbf_tag" ]   := "2"
   AAdd( hItem[ "algoritam" ], hAlgoritam )


   // algoritam 2 - dokument
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ]  := {|| field->idfirma + field->idvn + field->brnal }
   hAlgoritam[ "dbf_key_fields" ] := { "idfirma", "idvn", "brnal" }
   hAlgoritam[ "sql_in" ]    := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
   hAlgoritam[ "dbf_tag" ]    := "2"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   // za full sinhronizaciju trebamo jedinstveni poredak
   hItem[ "sql_order" ] := "idfirma, idvn, brnal, rbr"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_fin_nalog()

   LOCAL hAlgoritam, cTable, hItem


   cTable := "fin_nalog"

   hItem := hb_Hash()

   hItem[ "alias" ] := "NALOG"
   hItem[ "wa" ]    := F_NALOG
   hItem[ "table" ] := cTable
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .T.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->idfirma + field->idvn + field->brnal }
   hAlgoritam[ "dbf_key_fields" ] := { "idfirma", "idvn", "brnal" }
   hAlgoritam[ "sql_in" ]         := "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)"
   hAlgoritam[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   hItem[ "sql_order" ] := "idfirma, idvn, brnal"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.


/*
FUNCTION set_a_dbf_fin_parek()

   LOCAL hAlgoritam, cTable, hItem
   LOCAL _itm

   cTable := "fin_parek"

   hItem := hb_Hash()

   hItem[ "alias" ] := "PAREK"
   hItem[ "wa" ]    := F_PAREK
   hItem[ "table" ] := cTable
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .F.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->idpartija }
   hAlgoritam[ "dbf_key_fields" ] := { "idpartija" }
   hAlgoritam[ "sql_in" ]         := "rpad(idpartija,6)"
   hAlgoritam[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   hItem[ "sql_order" ] := "idpartija"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.


FUNCTION set_a_dbf_fin_koliz()

   LOCAL hAlgoritam, cTable, hItem
   LOCAL _itm

   cTable := "fin_koliz"

   hItem := hb_Hash()

   hItem[ "alias" ] := "KOLIZ"
   hItem[ "wa" ]    := F_KOLIZ
   hItem[ "table" ] := cTable
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .F.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->id }
   hAlgoritam[ "dbf_key_fields" ] := { "id" }
   hAlgoritam[ "sql_in" ]         := "rpad(id,2)"
   hAlgoritam[ "dbf_tag" ]        := "ID"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   hItem[ "sql_order" ] := "id"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_fin_koniz()

   LOCAL hAlgoritam, cTable, hItem
   LOCAL _itm

   cTable := "fin_koniz"

   hItem := hb_Hash()

   hItem[ "alias" ] := "KONIZ"
   hItem[ "wa" ]    := F_KONIZ
   hItem[ "table" ] := cTable
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .F.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->id }
   hAlgoritam[ "dbf_key_fields" ] := { "id" }
   hAlgoritam[ "sql_in" ]         := "rpad(id,20)"
   hAlgoritam[ "dbf_tag" ]        := "ID"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   hItem[ "sql_order" ] := "id"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.




FUNCTION set_a_dbf_fin_zagli()

   LOCAL hAlgoritam, cTable, hItem
   LOCAL _itm

   cTable := "fin_zagli"

   hItem := hb_Hash()
   hItem[ "alias" ] := "ZAGLI"
   hItem[ "wa" ]    := F_ZAGLI
   hItem[ "table" ] := cTable
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .F.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->id }
   hAlgoritam[ "dbf_key_fields" ] := { "id" }
   hAlgoritam[ "sql_in" ]         := "rpad(id,2)"
   hAlgoritam[ "dbf_tag" ]        := "ID"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   hItem[ "sql_order" ] := "id"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.


FUNCTION set_a_dbf_fin_izvje()

   LOCAL hAlgoritam, cTable, hItem
   LOCAL _itm

   cTable := "fin_izvje"

   hItem := hb_Hash()

   hItem[ "alias" ] := "IZVJE"
   hItem[ "wa" ]    := F_IZVJE
   hItem[ "table" ] := cTable
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .F.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->id }
   hAlgoritam[ "dbf_key_fields" ] := { "id" }
   hAlgoritam[ "sql_in" ]         := "rpad(id,2)"
   hAlgoritam[ "dbf_tag" ]        := "ID"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   hItem[ "sql_order" ] := "id"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.


FUNCTION set_a_dbf_fin_budzet()

   LOCAL hAlgoritam, cTable, hItem
   LOCAL _itm

   cTable := "fin_budzet"

   hItem := hb_Hash()

   hItem[ "alias" ] := "BUDZET"
   hItem[ "wa" ]    := F_BUDZET
   hItem[ "table" ] := cTable
   hItem[ "temp" ]  := .F.
   hItem[ "sif" ] := .F.
   hItem[ "sql" ] := .F.

   hItem[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   hAlgoritam := hb_Hash()
   hAlgoritam[ "dbf_key_block" ] := {|| field->idrj + field->idkonto }
   hAlgoritam[ "dbf_key_fields" ] := { "idrj", "idkonto" }
   hAlgoritam[ "sql_in" ]         := "rpad( idrj, 6 ) || rpad( idkonto, 7 )"
   hAlgoritam[ "dbf_tag" ]        := "1"
   AAdd( hItem[ "algoritam" ], hAlgoritam )

   hItem[ "sql_order" ] := "idrj, idkonto"

   f18_dbfs_add( cTable, @hItem )

   RETURN .T.
*/
