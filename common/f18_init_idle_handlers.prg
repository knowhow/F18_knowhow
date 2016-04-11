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
STATIC s_nIdleRefresh := 0 // start idle refresh in seconds()
STATIC s_nIdleDisplayCounter := 0 // counter

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

   IF s_nIdleRefresh > 0

      IF Seconds() - s_nIdleDisplayCounter > 15
         ?E "already in idle dbf refresh", Seconds(), s_nIdleRefresh
         s_nIdleDisplayCounter := Seconds()
      ENDIF
      RETURN

   ELSE

      s_nIdleRefresh := Seconds()
      IF Seconds() - s_nIdleDisplayCounter > 15
         ?E "START in idle dbf refresh", Seconds()
         s_nIdleDisplayCounter := Seconds()
      ENDIF
   ENDIF

   IF is_in_main_thread_sql_transaction()
      s_nIdleRefresh := 0
      RETURN
   ENDIF

   IF my_database() == "?undefined?"
      s_nIdleRefresh := 0
      RETURN
   ENDIF

   IF in_cre_all_dbfs()
      s_nIdleRefresh := 0
      RETURN
   ENDIF


   process_dbf_refresh_queue()

   cAlias := Alias()

   IF Empty( cAlias ) .OR. ( rddName() != DBFENGINE )
      s_nIdleRefresh := 0
      RETURN
   ENDIF

   aDbfRec := get_a_dbf_rec( cAlias, .T. )

   IF we_need_dbf_refresh( aDbfRec[ "table" ] )
      thread_dbfs( hb_threadStart(  @thread_dbf_refresh(), aDbfRec[ "table" ] ) )
#ifdef F18_DEBUG_THREAD
      ?E "alias_dbf_refresh thread start", aDbfRec[ "table" ], "main thread:", main_thread()
#endif
#ifdef F18_DEBUG_THREAD
   ELSE
      ?E "alias_dbf_refresh ne treba", aDbfRec[ "table" ]
#endif

   ENDIF

   s_nIdleRefresh := 0

   RETURN


FUNCTION remove_idle_handlers()

   AEval( aIdleHandlers, {| pHandlerID | hb_idleDel( pHandlerID ) } )
   aIdleHandlers := {}

   RETURN .T.


INIT PROCEDURE idle_init()


   RETURN
