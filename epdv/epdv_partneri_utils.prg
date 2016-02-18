/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"


// ----------------------------------------------
// napuni sifrarnik sifk  sa poljem za unos
// podatka o pripadnosti rejonu
// 1 - federacija
// 2 - rs
// 3 - distrikt brcko
// ---------------------------------------------
FUNCTION epdv_set_sif_partneri()

   LOCAL lFound
   LOCAL cSeek
   LOCAL cNaz
   LOCAL cId

   SELECT ( F_SIFK )

   IF !Used()
      O_SIFK
   ENDIF

   SET ORDER TO TAG "ID"
   // id + SORT + naz

   cId := PadR( "PARTN", 8 )
   cNaz := PadR( "1-FED,2-RS 3-DB", Len( naz ) )
   cSeek :=  cId + "09" + cNaz

   SEEK cSeek

   IF !Found()
      APPEND BLANK
      _rec := dbf_get_rec()
      _rec[ "id" ] := cId
      _rec[ "naz" ] := cNaz
      _rec[ "oznaka" ] := "REJO"
      _rec[ "sort" ] := "09"
      _rec[ "tip" ] := "C"
      _rec[ "duzina" ] := 1
      _rec[ "veza" ] := "1"

      IF !update_rec_server_and_dbf( "sifk", _rec, 1, "FULL" )
         delete_with_rlock()
      ENDIF
   ENDIF

   RETURN
