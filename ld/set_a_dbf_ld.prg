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


FUNCTION set_a_dbf_ld_sif()

   set_a_dbf_sifarnik( "ld_rj", "LD_RJ", F_LD_RJ      )
   set_a_dbf_sifarnik( "por", "POR", F_POR        )
   set_a_dbf_sifarnik( "tippr", "TIPPR", F_TIPPR      )
   set_a_dbf_sifarnik( "tippr2", "TIPPR2", F_TIPPR2     )
   set_a_dbf_sifarnik( "kred", "KRED", F_KRED       )
   set_a_dbf_sifarnik( "strspr", "STRSPR", F_STRSPR     )
   set_a_dbf_sifarnik( "vposla", "VPOSLA", F_VPOSLA     )
   set_a_dbf_sifarnik( "strspr", "STRSPR", F_STRSPR     )
   set_a_dbf_sifarnik( "kbenef", "KBENEF", F_KBENEF     )

   RETURN .T.


FUNCTION set_a_dbf_ld()

   set_a_dbf_ld_ld()
   set_a_dbf_ld_parobr()
   set_a_dbf_ld_dopr()
   set_a_dbf_ld_radkr()
   set_a_dbf_ld_obracuni()
   set_a_dbf_ld_pk_data()
   set_a_dbf_ld_pk_radn()
   set_a_dbf_ld_radsat()
   set_a_dbf_ld_radsiht()
   set_a_dbf_ld_radn()

   set_a_dbf_temp( "_ld_radkr",   "_RADKR", F__RADKR  )
   set_a_dbf_temp( "_ld_ld",   "_LD", F__LD     )
   set_a_dbf_temp( "_ld_radn",   "_RADN", F__RADN   )
   set_a_dbf_temp( "_ld_kred",   "_KRED", F__KRED   )
   set_a_dbf_temp( "ld_ldsm",   "LDSM", F_LDSM    )
   set_a_dbf_temp( "ld_opsld",   "OPSLD", F_OPSLD   )
   set_a_dbf_temp( "ld_rekld",   "REKLD", F_REKLD   )
   set_a_dbf_temp( "ld_rekldp",   "REKLDP", F_REKLDP   )
   set_a_dbf_temp( "ldt22",   "LDT22", F_LDT22    )
   set_a_dbf_temp( "exp_bank",   "EXP_BANK", F_EXP_BANK  )

   set_a_dbf_sifarnik( "ld_norsiht", "NORSIHT", F_NORSIHT   )
   set_a_dbf_sifarnik( "ld_tprsiht", "TPRSIHT", F_TPRSIHT   )

   RETURN .T.


FUNCTION set_a_dbf_ld_ld()

   LOCAL _alg, _tbl, _item

   _tbl := "ld_ld"

   _item := hb_Hash()

   _item[ "alias" ] := "LD"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_LD
   _item[ "temp" ]  := .F.
   _item[ "sif" ] := .F.
   _item[ "sql" ] := .F.
   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->godina, 4, 0 ) + field->idrj + Str( field->mjesec, 2, 0 ) + field->obr + field->idradn }
   _alg[ "dbf_key_empty_rec" ] := Str( 0, 4, 0 ) + Space( 2 ) + Str( 0, 2, 0 ) + " " + Space( 6 )
   _alg[ "dbf_key_fields" ] := { { "godina", 4 }, "idrj", { "mjesec", 2 }, "obr", "idradn" }
   _alg[ "sql_in" ]         := "lpad(godina::char(4), 4) || rpad(idrj, 2) || lpad(mjesec::char(2),2) || rpad(obr,1) || rpad(idradn,6)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   // algoritam 2 - brisanje
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| Str( field->godina, 4 ) + field->idrj + Str( field->mjesec, 2 ) + field->obr }
   _alg[ "dbf_key_fields" ] := { { "godina", 4 }, "idrj", { "mjesec", 2 }, "obr" }
   _alg[ "sql_in" ]         := "lpad(godina::char(4), 4) || rpad(idrj, 2) || lpad(mjesec::char(2),2) || rpad(obr,1)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "godina, idrj, mjesec, obr"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.


FUNCTION set_a_dbf_ld_radn()

   LOCAL _alg, _tbl, _item

   _tbl := "ld_radn"

   _item := hb_Hash()

   _item[ "alias" ] := "RADN"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_RADN
   _item[ "temp" ]  := .F.
   _item[ "algoritam" ] := {}
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .T.

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->id }
   _alg[ "dbf_key_fields" ] := { "id" }
   _alg[ "sql_in" ]         := "rpad(id, 6)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.


FUNCTION set_a_dbf_ld_parobr()

   LOCAL _alg, _tbl, _item

   _tbl := "ld_parobr"

   _item := hb_Hash()

   _item[ "alias" ] := "PAROBR"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_PAROBR
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .T.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->id + field->godina + field->obr }
   _alg[ "dbf_key_fields" ] := { "id", "godina", "obr" }
   _alg[ "sql_in" ]         := "rpad(id, 2) || rpad(godina, 4) || rpad(obr, 1)"
   _alg[ "dbf_tag" ]        := "ID"
   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.



FUNCTION set_a_dbf_ld_dopr()

   LOCAL _alg, _tbl, _item

   _tbl := "dopr"

   _item := hb_Hash()

   _item[ "alias" ] := "DOPR"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_DOPR
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .T.


   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->id + field->naz + field->tiprada }
   _alg[ "dbf_key_fields" ] := { "id", "naz", "tiprada" }
   _alg[ "sql_in" ]         := "rpad(id, 2) || rpad(naz, 20) || rpad(tiprada, 1)"
   _alg[ "dbf_tag" ]        := "1"

   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.




FUNCTION set_a_dbf_ld_obracuni()

   LOCAL _alg, _tbl

   _tbl := "ld_obracuni"

   _item := hb_Hash()

   _item[ "alias" ] := "OBRACUNI"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_OBRACUNI
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .T.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->rj + Str( field->godina, 4 ) + Str( field->mjesec, 2 ) + field->status + field->obr }
   _alg[ "dbf_key_fields" ] := { "rj", { "godina", 4 }, { "mjesec", 2 }, "status", "obr" }
   _alg[ "sql_in" ]         := "rpad(rj, 2) || lpad(godina::char(4),4) || lpad(mjesec::char(2),2) || rpad(status, 1) || rpad(obr, 1)"
   _alg[ "dbf_tag" ]        := "RJ"
   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN


FUNCTION set_a_dbf_ld_pk_radn()

   LOCAL _alg, _tbl

   _tbl := "ld_pk_radn"

   _item := hb_Hash()

   _item[ "alias" ] := "PK_RADN"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_PK_RADN
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .F.

   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idradn }
   _alg[ "dbf_key_fields" ] := { "idradn" }
   _alg[ "sql_in" ]         := "rpad(idradn, 6)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.



FUNCTION set_a_dbf_ld_pk_data()

   LOCAL _alg, _tbl, _item

   _tbl := "ld_pk_data"

   _item := hb_Hash()

   _item[ "alias" ] := "PK_DATA"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_PK_DATA
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .F.

   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idradn + field->ident + Str( field->rbr, 2 ) }
   _alg[ "dbf_key_fields" ] := { "idradn", "ident", { "rbr", 2 } }
   _alg[ "sql_in" ]         := "rpad(idradn, 6) || rpad(ident, 1) || lpad(rbr::char(2),2)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   // algoritam 2 - brisanje podataka
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idradn }
   _alg[ "dbf_key_fields" ] := { "idradn" }
   _alg[ "sql_in" ]         := "rpad(idradn, 6)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN


FUNCTION set_a_dbf_ld_radsat()

   LOCAL _alg, _tbl, _item

   _tbl := "ld_radsat"

   _item := hb_Hash()

   _item[ "alias" ] := "RADSAT"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_RADSAT
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .F.

   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idradn }
   _alg[ "dbf_key_fields" ] := { "idradn" }
   _alg[ "sql_in" ]         := "rpad(idradn, 6)"
   _alg[ "dbf_tag" ]        := "IDRADN"
   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.



FUNCTION set_a_dbf_ld_radsiht()

   LOCAL _alg, _tbl, _item

   _tbl := "ld_radsiht"

   _item := hb_Hash()

   _item[ "alias" ] := "RADSIHT"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_RADSIHT
   _item[ "temp" ]  := .F.
   _item[ "sql" ] := .F.
   _item[ "sif" ] := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idkonto + Str( field->godina, 4 ) + Str( field->mjesec, 2 ) + field->idradn }
   _alg[ "dbf_key_fields" ] := { "idkonto", { "godina", 4 }, { "mjesec", 2 }, "idradn" }
   _alg[ "sql_in" ]         := "rpad(idkonto, 7) || lpad(godina::char(4),4) || lpad(mjesec::char(2),2) || rpad(idradn, 6)"
   _alg[ "dbf_tag" ]        := "2"
   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.



FUNCTION set_a_dbf_ld_radkr()

   LOCAL _alg, _tbl, _item

   _tbl := "ld_radkr"

   _item := hb_Hash()

   _item[ "alias" ] := "RADKR"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_RADKR
   _item[ "temp" ]  := .F.
   _item[ "algoritam" ] := {}
    _item[ "sql" ] := .F.
    _item[ "sif" ] := .F.

   // algoritam 1
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idradn + field->idkred + field->naosnovu + Str( field->godina, 4, 0 ) + Str( field->mjesec, 2, 0 ) }
   _alg[ "dbf_key_fields" ] := { "idradn", "idkred", "naosnovu", { "godina", 4 }, { "mjesec", 2 } }
   _alg[ "sql_in" ]         := "rpad(idradn,6) || rpad(idkred,6) || rpad(naosnovu, 20) || lpad(godina::char(4),4) || lpad(mjesec::char(2),2)"
   _alg[ "dbf_tag" ]        := "2"
   AAdd( _item[ "algoritam" ], _alg )

   // algoritam 2
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idradn + field->idkred + field->naosnovu }
   _alg[ "dbf_key_fields" ] := { "idradn", "idkred", "naosnovu" }
   _alg[ "sql_in" ]         := "rpad(idradn,6) || rpad(idkred,6) || rpad(naosnovu, 20) "
   _alg[ "dbf_tag" ]        := "2"
   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.
