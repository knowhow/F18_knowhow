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

STATIC aIdleHandlers := {}

FUNCTION add_idle_handlers()

   AAdd( aIdleHandlers, hb_idleAdd( {||  hb_DispOutAt( maxrows(),  maxcols() - 8, Time() ) } ) )
   AAdd( aIdleHandlers, hb_idleAdd( {||  hb_DispOutAt( maxrows(),  maxcols() - 8 - 8 - 1, "< CALC >" ), ;
      iif( !in_calc() .AND. MINRECT( maxrows(), maxcols() - 8 - 8 - 1, maxrows(), maxcols() - 8 - 1 ), Calc(), NIL ) } ) )

   AAdd( aIdleHandlers, hb_idleAdd( {|| iif( in_cre_all_dbfs(), .T., dbf_refresh() ) } ) )

   RETURN .T.


FUNCTION remove_idle_handlers()

   AltD()
   AEval( aIdleHandlers, {| pHandlerID | hb_idleDel( pHandlerID ) } )
   aIdleHandlers := {}

   RETURN .T.
