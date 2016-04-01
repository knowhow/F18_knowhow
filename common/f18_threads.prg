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
STATIC s_hMutex
STATIC s_mainThreadID
STATIC s_aThreads
STATIC s_aEval := {}

PROCEDURE f18_init_threads()

   s_mainThreadID := hb_threadSelf()
   s_hMutex := hb_mutexCreate()
   s_aThreads := {}

   RETURN


FUNCTION main_thread()

   RETURN s_mainThreadID


FUNCTION is_in_main_thread()

   RETURN hb_threadSelf() == main_thread()


FUNCTION open_thread( cInfo, lOpenSQLConnection )

   LOCAL lSet, nCounter := 0

   hb_default( @lOpenSQLConnection, .T. )

   IF s_nThreadCount > 7
      ?E Time(), cInfo, "thread count>7 (", AllTrim( Str( s_nThreadCount ) ), ")"
      print_threads( "tread_cnt_max" + cInfo )
      RETURN .F.
   ENDIF

   lSet := .F.
   DO WHILE !lSet
      IF hb_mutexLock( s_hMutex )
         lSet := .T.
         s_nThreadCount++
         AAdd( s_aThreads, { hb_threadSelf(), cInfo, Time() } )
#ifdef F18_DEBUG_THREAD
         print_threads( "open_thread:" + cInfo )
#endif
         hb_mutexUnlock( s_hMutex )
      ENDIF
   ENDDO

#ifdef F18_DEBUG_THREAD
   ?E ">>>>> START: thread: ", cInfo, " cnt:(", AllTrim( Str( s_nThreadCount ) ), ") in main_thread:", is_in_main_thread(), " <<<<<"
#endif

   IF lOpenSQLConnection
      IF !my_server_login()
         error_bar( "thread", "login error: " + cInfo )
         RETURN .F.
      ENDIF
      set_sql_search_path()
      set_f18_home( my_server_params()[ "database" ] )

   ELSE
      idle_add_for_eval( "my_home", {||  my_home() } )
      // idle_add_for_eval( "my_server_params", {||  my_server_params() } )
      my_home( idle_get_eval( "my_home" ) ) // my_home iz glavnog thread-a
      // my_server_params( idle_get_eval( "my_server_params" ) )
      my_server_params()

   ENDIF

   init_parameters_cache()

   RETURN .T.



PROCEDURE close_thread( cInfo )

   LOCAL lSet := .F.
   LOCAL nPos, aThread

   DO WHILE !lSet
      IF hb_mutexLock( s_hMutex )
#ifdef F18_DEBUG_THREAD
         print_threads( "close_thread:" + cInfo )
#endif
         s_nThreadCount--
         nPos := AScan( s_aThreads, {| aItem | aItem[ 1 ] == hb_threadSelf() } )
         IF nPos > 0
            ADel( s_aThreads, nPos )
            ASize( s_aThreads, Len( s_aThreads ) - 1 )
         ELSE
            ? "ERR: thread nije u listi:", hb_threadSelf()
         ENDIF
         lSet := .T.
         hb_mutexUnlock( s_hMutex )
      ENDIF
   ENDDO

#ifdef F18_DEBUG_THREAD
   ?E "<<<<<< END: thread", cInfo, "thread count:", s_nThreadCount
#endif

   my_server_close()


   RETURN


PROCEDURE print_threads( cInfo )

   LOCAL aThread

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

   RETURN



PROCEDURE idle_add_for_eval( cId, bExpression )

   IF hb_mutexLock( s_hMutex )
      AAdd( s_aEval, { "X", cId, bExpression, NIL } )
      hb_mutexUnlock( s_hMutex )
   ENDIF

   RETURN


/*
    EVAL
*/
PROCEDURE idle_eval()

   LOCAL aItem

   IF hb_mutexLock( s_hMutex )

      FOR EACH aItem IN s_aEval
         IF aItem[ 1 ] == "X"
            aItem[ 4 ] := Eval( aItem[ 3 ] )
            aItem[ 1 ] := "OK"
         ENDIF
      NEXT
      hb_mutexUnlock( s_hMutex )
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

         IF hb_mutexLock( s_hMutex )
            xRet := s_aEval[ nPos, 4 ]
            ADel( s_aEval, nPos )
            ASize( s_aEval, Len( s_aEval )  - 1 )
            hb_mutexUnlock( s_hMutex )
         ENDIF

      ELSE
         hb_idleSleep( 0.5 )
      ENDIF
   ENDDO

   RETURN xRet
