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



FUNCTION get_fakt_atribut_opis( dok, from_server )

   LOCAL oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )

   oAtrib:from_dbf := ( from_server == .F. )
   oAtrib:atrib := "opis"
   oAtrib:dok_hash := dok

   RETURN oAtrib:get_atrib()

FUNCTION get_fakt_atribut_ref( dok, from_server )

   LOCAL oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )

   oAtrib:from_dbf := ( from_server == .F. )
   oAtrib:atrib := "ref"
   oAtrib:dok_hash := dok

   RETURN oAtrib:get_atrib()


FUNCTION get_fakt_atribut_lot( dok, from_server )

   LOCAL oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )

   oAtrib:from_dbf := ( from_server == .F. )
   oAtrib:atrib := "lot"
   oAtrib:dok_hash := dok

   RETURN oAtrib:get_atrib()
