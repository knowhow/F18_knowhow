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

FUNCTION cre_sif_konto( ver )

   LOCAL _created
   LOCAL _table_name
   LOCAL _alias
   LOCAL aDbf

/*
   _alias := "KONTO"
   _table_name := "konto"

   aDbf := {}
   AAdd( aDBf, { 'ID', 'C',   7,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C',  57,  0 } )
   AAdd( aDBf, { "POZBILU", "C",   3,  0 } )
   AAdd( aDBf, { "POZBILS", "C",   3,  0 } )

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "naz", _alias )
   index_mcode( my_home(), _alias )

   AFTER_CREATE_INDEX
*/

   RETURN .T.
