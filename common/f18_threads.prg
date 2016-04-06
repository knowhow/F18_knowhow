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

STATIC s_nThreadCount := 0
STATIC s_mtxMutex
STATIC s_mainThreadID
STATIC s_aThreads
STATIC s_aEval := {}
STATIC s_aQueueDbfRefresh := {}

PROCEDURE f18_init_threads()

   s_mainThreadID := hb_threadSelf()
   s_mtxMutex := hb_mutexCreate()
   s_aThreads := {}

   RETURN


FUNCTION main_thread()

   RETURN s_mainThreadID


FUNCTION is_in_main_thread()

   RETURN hb_threadSelf() == main_thread()


FUNCTION open_thread( cInfo, lOpenSQLConnection, cTable )

   LOCAL nCounter := 0

   hb_default( @lOpenSQLConnection, .T. )

   DO WHILE s_nThreadCount > MAX_THREAD_COUNT

      ++nCounter

#ifdef F18_DEBUG_THREAD
      ?E Time(), cInfo, "thread count>", MAX_THREAD_COUNT, " (", AllTrim( Str( s_nThreadCount ) ), ")"
      print_threads( "tread_cnt_max" + cInfo )
#endif
      IF nCounter > 1000
         add_to_dbf_refresh_queue( cTable ) // refresh se ne moze trenutno napraviti, staviti u queue
         RETURN .F.
      ELSE
         IF nCounter % 100 == 0
            ?E Time(), "max threads limit reached, waiting ... ", cInfo, "/", nCounter
            hb_idleSleep( 0.2 )
         ENDIF
      ENDIF

   ENDDO

   add_thread( cInfo )

#ifdef F18_DEBUG_THREAD
   ?E ">>>>> START: thread: ", cInfo, " cnt:(", AllTrim( Str( s_nThreadCount ) ), ") in main_thread:", is_in_main_thread(), " <<<<<"
#endif

   IF lOpenSQLConnection
      IF !my_server_login()
         remove_thread( hb_threadSelf(), cInfo )
         error_bar( "thread", "login error: " + cInfo )
         RETURN .F.
      ENDIF
      set_sql_search_path()
      set_f18_home( my_server_params()[ "database" ] )

   ELSE // hernad 06.04.2016: trenutno nema thread-ova bez svojih konekcija
      idle_add_for_eval( "my_home", {||  my_home() } )
      // idle_add_for_eval( "my_server_params", {||  my_server_params() } )
      my_home( idle_get_eval( "my_home" ) ) // my_home iz glavnog thread-a
      // my_server_params( idle_get_eval( "my_server_params" ) )
      my_server_params()

   ENDIF

   init_parameters_cache()

   RETURN .T.




FUNCTION add_to_dbf_refresh_queue( cTable )

   LOCAL nPos

   IF cTable != NIL .AND. hb_mutexLock( s_mtxMutex )
      nPos := AScan( s_aQueueDbfRefresh, {| aItem |  ValType( aItem ) == "A" .AND. aItem[ 1 ] == my_database() .AND. aItem[ 2 ] == cTable } )
      IF nPos == 0
         AAdd( s_aQueueDbfRefresh, { my_database(), cTable } )
         RETURN .T.
      ENDIF
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   RETURN .F.


FUNCTION remove_from_dbf_refresh_queue( cDatabase, cTable )

   LOCAL nPos

   IF cTable != NIL .AND. hb_mutexLock( s_mtxMutex )
      nPos := AScan( s_aQueueDbfRefresh, {| aItem |  ValType( aItem ) == "A" .AND. aItem[ 1 ] == cDatabase .AND. aItem[ 2 ] == cTable } )
      IF nPos > 0
         ADel( s_aQueueDbfRefresh, nPos )
         ASize( s_aQueueDbfRefresh, Len( s_aQueueDbfRefresh ) - 1 )
         RETURN .T.
      ENDIF
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   RETURN .F.


PROCEDURE process_dbf_refresh_queue()

   LOCAL aItem

   FOR EACH aItem IN s_aQueueDbfRefresh
      IF ValType( aItem ) == "A"
         IF aItem[ 1 ] == my_database()
            IF we_need_dbf_refresh( aItem[ 2 ] )
               thread_dbfs( hb_threadStart(  @thread_dbf_refresh(), aItem[ 2 ] ) )
            ENDIF
         ENDIF
         remove_from_dbf_refresh_queue( aItem[ 1 ],  aItem[ 2 ] )

      ENDIF
   NEXT

   RETURN


PROCEDURE close_thread( cInfo )

   remove_thread( hb_threadSelf(), cInfo )

#ifdef F18_DEBUG_THREAD
   ?E "<<<<<< END: thread", cInfo, "thread count:", s_nThreadCount
#endif

   my_server_close()

   RETURN



STATIC FUNCTION add_thread( cInfo )

   LOCAL lSet := .F.

   DO WHILE !lSet
      IF hb_mutexLock( s_mtxMutex )
         lSet := .T.
         s_nThreadCount++
         AAdd( s_aThreads, { hb_threadSelf(), cInfo, Time() } )
#ifdef F18_DEBUG_THREAD
         print_threads( "open_thread:" + cInfo )
#endif
         hb_mutexUnlock( s_mtxMutex )
      ENDIF
   ENDDO

   RETURN lSet


STATIC FUNCTION remove_thread( pThread, cInfo )

   LOCAL lSet := .F., nPos

   DO WHILE !lSet
      IF hb_mutexLock( s_mtxMutex )
#ifdef F18_DEBUG_THREAD
         print_threads( "close_thread:" + cInfo )
#endif
         s_nThreadCount--
         nPos := AScan( s_aThreads, {| aItem | ValType( aItem ) == "A" .AND. aItem[ 1 ] == pThread } )
         IF nPos > 0
            ADel( s_aThreads, nPos )
            ASize( s_aThreads, Len( s_aThreads ) - 1 )
         ELSE
            ? "ERR: thread nije u listi:", hb_threadSelf()
         ENDIF
         lSet := .T.
         hb_mutexUnlock( s_mtxMutex )
      ENDIF
   ENDDO

   RETURN lSet


PROCEDURE print_threads( cInfo )

   LOCAL aThread

   IF hb_mutexLock( s_mtxMutex )
      ?E "THREADS:", cInfo
      ?E Replicate( "-", 80 )
      FOR EACH aThread IN s_aThreads
         IF ValType( aThread ) == "A"
            ?E s_nThreadCount, aThread[ 3 ], aThread[ 1 ], aThread[ 2 ]
         ELSE
            ?E s_nThreadCount,  ValType( aThread ),  aThread
         ENDIF
      NEXT
      ?E Replicate( ".", 80 )
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   RETURN



PROCEDURE idle_add_for_eval( cId, bExpression )

   IF hb_mutexLock( s_mtxMutex )
      AAdd( s_aEval, { "X", cId, bExpression, NIL } )
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   RETURN


/*
    EVAL
*/
PROCEDURE idle_eval()

   LOCAL aItem

   IF hb_mutexLock( s_mtxMutex )

      FOR EACH aItem IN s_aEval
         IF aItem[ 1 ] == "X"
            aItem[ 4 ] := Eval( aItem[ 3 ] )
            aItem[ 1 ] := "OK"
         ENDIF
      NEXT
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   RETURN


/*
      ?E "IDLE ADD EVAL 1+1"
      idle_add_for_eval( "1+1", { || 1 + 1 } )
      ?E "IDLE GET EVAL 1+1:", idle_get_eval( "1+1" )
      idle_add_for_eval( "count konto", {|| table_count( "konto") } )
      info_bar("idle", "IDLE GET EVAL count konto:" +  hb_ValToStr( idle_get_eval( "count konto" ) ) )
*/

FUNCTION idle_get_eval( cId )

   LOCAL nPos := 0, xRet

   DO WHILE nPos == 0

      nPos := AScan( s_aEval, {| aItem | aItem[ 2 ] == cId .AND. aItem[ 1 ] == "OK" } )
      IF nPos > 0

         IF hb_mutexLock( s_mtxMutex )
            xRet := s_aEval[ nPos, 4 ]
            ADel( s_aEval, nPos )
            ASize( s_aEval, Len( s_aEval )  - 1 )
            hb_mutexUnlock( s_mtxMutex )
         ENDIF

      ELSE
         hb_idleSleep( 0.5 )
      ENDIF
   ENDDO

   RETURN xRet
