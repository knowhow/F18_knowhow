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

   AAdd( aIdleHandlers, hb_idleAdd( {||  hb_DispOutAt( maxrows(),  maxcols() - 8, Time(), F18_COLOR_INFO_PANEL ) } ) )
   AAdd( aIdleHandlers, hb_idleAdd( {||  hb_DispOutAt( maxrows(),  maxcols() - 8 - 8 - 1, "< CALC >", F18_COLOR_INFO_PANEL ), ;
      iif( !in_calc() .AND. MINRECT( maxrows(), maxcols() - 8 - 8 - 1, maxrows(), maxcols() - 8 - 1 ), Calc(), NIL ) } ) )
   AAdd( aIdleHandlers, hb_idleAdd( {|| alias_dbf_refresh() } ) )


   RETURN .T.

STATIC PROCEDURE alias_dbf_refresh()

   LOCAL cAlias, aDBfRec

   IF in_cre_all_dbfs()
      RETURN
   ENDIF

   cAlias := Alias()

   IF Empty( cAlias ) .OR. ( rddName() != DBFENGINE )
      RETURN
   ENDIF

   aDbfRec := get_a_dbf_rec( cAlias )

   IF !skip_semaphore_sync( aDbfRec[ 'table' ] ) .AND. ;
         !in_dbf_refresh( aDbfRec[ 'table' ] ) .AND.  ;
         !is_last_refresh_before( aDbfRec[ 'table' ], 7 )
      thread_dbfs( hb_threadStart(  @thread_dbf_refresh(), cAlias ) )
#ifdef F18_DEBUG_THREAD
      ?E "alias_dbf_refresh thread start", cAlias, "main thread:", main_thread()
#endif
#ifdef F18_DEBUG_THREAD
   ELSE

      ?E "alias_dbf_refresh ne treba", cAlias
#endif
   ENDIF

   RETURN


FUNCTION remove_idle_handlers()

   AEval( aIdleHandlers, {| pHandlerID | hb_idleDel( pHandlerID ) } )
   aIdleHandlers := {}

   RETURN .T.
