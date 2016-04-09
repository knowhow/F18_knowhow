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
THREAD STATIC s_nIdleSeconds := 0
STATIC s_mtxMutex
STATIC s_lInIdleRefresh := .F.

FUNCTION add_idle_handlers()

   AAdd( aIdleHandlers, hb_idleAdd( {||  hb_DispOutAt( maxrows(),  maxcols() - 8, Time(), F18_COLOR_INFO_PANEL ) } ) )
   AAdd( aIdleHandlers, hb_idleAdd( {||  hb_DispOutAt( maxrows(),  maxcols() - 8 - 8 - 1, "< CALC >", F18_COLOR_INFO_PANEL ), ;
      iif( !in_calc() .AND. MINRECT( maxrows(), maxcols() - 8 - 8 - 1, maxrows(), maxcols() - 8 - 1 ), Calc(), NIL ) } ) )

   RETURN .T.


/*
    1) procesiranje dbf_refresh_queue-a
    2) dbf refresh tekuce tabele, na osnovu aliasa
*/

PROCEDURE on_idle_dbf_refresh()

   LOCAL cAlias, aDBfRec

#ifdef F18_DEBUG_THREAD

   ?E Seconds(), "on idle dbf refresh"
#endif

   IF s_lInIdleRefresh
      ?E "already in idle dbf refresh"
      RETURN
   ENDIF

   IF !is_in_main_thread() // samo glavni thread okida idle evente
      RETURN
   ENDIF

   IF ( Seconds() - s_nIdleSeconds ) < MIN_LAST_REFRESH_SEC
      RETURN
   ENDIF

   s_nIdleSeconds := Seconds()


   IF my_database() == "?undefined?"
      RETURN
   ENDIF

   IF in_cre_all_dbfs()
      RETURN
   ENDIF

   IF hb_mutexLock( s_mtxMutex )
      s_lInIdleRefresh := .T.
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   process_dbf_refresh_queue()

   cAlias := Alias()

   IF Empty( cAlias ) .OR. ( rddName() != DBFENGINE )
      RETURN
   ENDIF

   aDbfRec := get_a_dbf_rec( cAlias, .T. )

   IF  we_need_dbf_refresh( aDbfRec[ "table" ] )
      thread_dbfs( hb_threadStart(  @thread_dbf_refresh(), aDbfRec[ "table" ] ) )
#ifdef F18_DEBUG_THREAD
      ?E "alias_dbf_refresh thread start", aDbfRec[ "table" ], "main thread:", main_thread()
#endif
#ifdef F18_DEBUG_THREAD
   ELSE
      ?E "alias_dbf_refresh ne treba", aDbfRec[ "table" ]
#endif

   ENDIF

   s_nIdleSeconds := Seconds()
   IF hb_mutexLock( s_mtxMutex )
      s_lInIdleRefresh := .F.
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   RETURN


FUNCTION remove_idle_handlers()

   AEval( aIdleHandlers, {| pHandlerID | hb_idleDel( pHandlerID ) } )
   aIdleHandlers := {}

   RETURN .T.


INIT PROCEDURE idle_init()

   IF s_mtxMutex == NIL
      s_mtxMutex := hb_mutexCreate()
   ENDIF

   RETURN
