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



FUNCTION set_a_dbf_fakt()

   set_a_dbf_fakt_fakt()

   set_a_fakt_doks_doks2( "fakt_doks", "FAKT_DOKS", F_FAKT_DOKS )
   set_a_fakt_doks_doks2( "fakt_doks2", "FAKT_DOKS2", F_FAKT_DOKS2 )

   set_a_dbf_fakt_ugov()
   set_a_dbf_fakt_rugov()
   set_a_dbf_fakt_dest()
   set_a_dbf_fakt_gen_ug()
   set_a_dbf_fakt_gen_ug_p()

   set_a_dbf_sifarnik( "fakt_ftxt", "FTXT", F_FTXT   )

   set_a_dbf_temp( "fakt_relac",   "RELAC", F_RELAC   )
   set_a_dbf_temp( "fakt_vozila",   "VOZILA", F_VOZILA  )
   set_a_dbf_temp( "fakt_kalpos",   "KALPOS", F_KALPOS  )
   set_a_dbf_temp( "fakt_pripr",   "FAKT_PRIPR", F_FAKT_PRIPR   )
   set_a_dbf_temp( "fakt_pripr2",   "FAKT_PRIPR2", F_FAKT_PRIPR2  )
   set_a_dbf_temp( "fakt_pripr9",   "FAKT_PRIPR9", F_FAKT_PRIPR9  )
   set_a_dbf_temp( "fakt_pormp",   "PORMP", F_PORMP   )
   set_a_dbf_temp( "_fakt_roba",   "_ROBA", F__ROBA   )
   set_a_dbf_temp( "_fakt_partn",   "_PARTN", F__PARTN  )
   set_a_dbf_temp( "fakt_logk",   "LOGK", F_LOGK    )
   set_a_dbf_temp( "fakt_logkd",   "LOGKD", F_LOGKD   )
   set_a_dbf_temp( "barkod",   "BARKOD", F_BARKOD  )
   set_a_dbf_temp( "fakt_upl",   "UPL", F_UPL     )
   set_a_dbf_temp( "fakt_s_pripr",   "FAKT_S_PRIPR", F_FAKT    )
   set_a_dbf_temp( "fakt__fakt",   "_FAKT", F__FAKT   )
   set_a_dbf_temp( "fakt_fapripr",    "FAKT_FAPRIPR", F_FAKT_PRIPR )
   set_a_dbf_temp( "fakt_attr", "FAKT_ATTR", F_FAKT_ATTR )
   set_a_dbf_temp( "labelu", "LABELU", F_LABELU )
   set_a_dbf_temp( "lab2",   "LAB2",   F_LABELU2 )

   // tabele razmjene podataka udaljene lokacije
   set_a_dbf_temp( "e_doks", "E_DOKS", F_TMP_E_DOKS )
   set_a_dbf_temp( "e_doks2", "E_DOKS2", F_TMP_E_DOKS2 )
   set_a_dbf_temp( "e_fakt", "E_FAKT", F_TMP_E_FAKT )
   set_a_dbf_temp( "e_kalk", "E_KALK", F_TMP_E_KALK )
   set_a_dbf_temp( "e_suban", "E_SUBAN", F_TMP_E_SUBAN )
   set_a_dbf_temp( "e_sint", "E_SINT", F_TMP_E_SINT )
   set_a_dbf_temp( "e_nalog", "E_NALOG", F_TMP_E_NALOG )
   set_a_dbf_temp( "e_anal", "E_ANAL", F_TMP_E_ANAL )
   set_a_dbf_temp( "e_roba", "E_ROBA", F_TMP_E_ROBA )
   set_a_dbf_temp( "e_konto", "E_KONTO", F_TMP_E_KONTO )
   set_a_dbf_temp( "e_partn", "E_PARTN", F_TMP_E_PARTN )
   set_a_dbf_temp( "e_sifk", "E_SIFK", F_TMP_E_SIFK )
   set_a_dbf_temp( "e_sifv", "E_SIFV", F_TMP_E_SIFV )

   RETURN


// ----------------------------------------------------------
// ----------------------------------------------------------
FUNCTION set_a_dbf_fakt_ugov()

   LOCAL _item, _alg, _tbl

   _tbl := "fakt_ugov"

   _item := hb_Hash()

   _item[ "alias" ] := "UGOV"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_UGOV

   // temporary tabela - nema semafora
   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()

   _alg[ "dbf_key_block" ]  := {|| field->id + field->idpartner }
   _alg[ "dbf_key_fields" ] := { "id", "idpartner" }
   _alg[ "sql_in" ]         := "rpad(id,10) || rpad(idpartner,6)"
   _alg[ "dbf_tag" ]        := "ID"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "id, idpartner"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.


// -----------------------------------------------------------
// -----------------------------------------------------------
FUNCTION set_a_dbf_fakt_rugov()

   LOCAL _item, _alg, _tbl

   _tbl := "fakt_rugov"

   _item := hb_Hash()

   _item[ "alias" ] := "RUGOV"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_RUGOV

   // temporary tabela - nema semafora
   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()

   // funkcija a_rugov() definise dbf polja
   _alg[ "dbf_key_block" ]  := {|| field->id + field->idroba + field->dest }
   _alg[ "dbf_key_fields" ] := { "id", "idroba", "dest" }
   _alg[ "sql_in" ]         := "rpad(id,10) || rpad(idroba,10) || rpad(dest,6)"
   _alg[ "dbf_tag" ]        := "ID"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "id, idroba, dest"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.



// -----------------------------------------------------------
// -----------------------------------------------------------
FUNCTION set_a_dbf_fakt_dest()

   LOCAL _item, _alg, _tbl

   _tbl := "dest"

   _item := hb_Hash()

   _item[ "alias" ] := "DEST"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_DEST

   // temporary tabela - nema semafora
   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()

   // funkcija a_dest() definise dbf polja
   _alg[ "dbf_key_block" ]  := {|| field->id + field->idpartner }
   _alg[ "dbf_key_fields" ] := { "id", "idpartner" }
   _alg[ "sql_in" ]         := "rpad(id,6) || rpad(idpartner,6)"
   _alg[ "dbf_tag" ]        := "ID"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "id, idpartner"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.






// -----------------------------------
// -----------------------------------
FUNCTION set_a_dbf_fakt_gen_ug()

   LOCAL _item, _alg, _tbl

   _tbl := "fakt_gen_ug"

   _item := hb_Hash()

   _item[ "alias" ] := "GEN_UG"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_GEN_UG

   // temporary tabela - nema semafora
   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()

   // funkcija a_genug() definise dbf polja

   _alg[ "dbf_key_block" ]  := {|| DToS( field->dat_obr ) }
   _alg[ "dbf_key_fields" ] := { "dat_obr" }
   _alg[ "sql_in" ]         := "to_char(dat_obr, 'YYYYMMDD')"
   _alg[ "dbf_tag" ]        := "DAT_OBR"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "dat_obr"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.


// -----------------------------------
// -----------------------------------
FUNCTION set_a_dbf_fakt_gen_ug_p()

   LOCAL _item, _alg, _tbl

   _tbl := "fakt_gen_ug_p"

   _item := hb_Hash()

   _item[ "alias" ] := "GEN_UG_P"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_G_UG_P

   // temporary tabela - nema semafora
   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| DToS( field->dat_obr ) + id_ugov + idpartner }
   _alg[ "dbf_key_fields" ] := { "dat_obr", "id_ugov", "idpartner" }
   _alg[ "sql_in" ]         := "to_char(dat_obr, 'YYYYMMDD') || rpad(id_ugov,10) || rpad(idpartner,6)"

   // CREATE_INDEX("DAT_OBR","DTOS(DAT_OBR)+ID_UGOV+IDPARTNER", "GEN_UG_P")
   _alg[ "dbf_tag" ]        := "DAT_OBR"

   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "dat_obr, id_ugov, idpartner"

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.


// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
FUNCTION set_a_dbf_fakt_fakt()

   LOCAL _item, _alg, _tbl

   _tbl := "fakt_fakt"

   _item := hb_Hash()

   _item[ "alias" ] := "FAKT"
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := F_FAKT

   // temporary tabela - nema semafora
   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idfirma + field->idtipdok + field->brdok + field->rbr }
   _alg[ "dbf_key_fields" ] := { "idfirma", "idtipdok", "brdok", "rbr" }
   _alg[ "sql_in" ]         := "rpad( idfirma,2) || rpad( idtipdok,2)  || rpad(brdok,8) || lpad(rbr,3)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   // algoritam 2 - nivo dokumenta
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idfirma + field->idtipdok + field->brdok }
   _alg[ "dbf_key_fields" ] := { "idfirma", "idtipdok", "brdok" }
   _alg[ "sql_in" ]         := "rpad( idfirma,2) || rpad( idtipdok,2)  || rpad(brdok,8)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "idfirma, idtipdok, brdok, rbr"
   _item[ "blacklisted" ] := { "fisc_rn", "dok_veza", "opis" }

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
FUNCTION set_a_fakt_doks_doks2( tbl, alias, wa )

   LOCAL _item, _alg, _tbl

   _tbl := tbl
   _item := hb_Hash()

   _item[ "alias" ] := alias
   _item[ "table" ] := _tbl
   _item[ "wa" ]    := wa

   // temporary tabela - nema semafora
   _item[ "temp" ]  := .F.

   _item[ "algoritam" ] := {}

   // algoritam 1 - default
   // -------------------------------------------------------------------------------
   _alg := hb_Hash()
   _alg[ "dbf_key_block" ]  := {|| field->idfirma + field->idtipdok + field->brdok }
   _alg[ "dbf_key_fields" ] := { "idfirma", "idtipdok", "brdok" }
   _alg[ "sql_in" ]         := "rpad( idfirma,2) || rpad( idtipdok,2)  || rpad(brdok,8)"
   _alg[ "dbf_tag" ]        := "1"
   AAdd( _item[ "algoritam" ], _alg )

   _item[ "sql_order" ] := "idfirma, idtipdok, brdok"
   _item[ "blacklisted" ] := { "dok_veza" }

   f18_dbfs_add( _tbl, @_item )

   RETURN .T.
