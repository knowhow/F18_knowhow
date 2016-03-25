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

PROCEDURE f18_init_threads()

   s_mainThreadID := hb_threadSelf()
   s_hMutex := hb_mutexCreate()
   s_aThreads := {}

   RETURN


FUNCTION main_thread()

   RETURN s_mainThreadID


FUNCTION is_in_main_thread()

   RETURN hb_threadSelf() == main_thread()


FUNCTION open_thread( cInfo )

   LOCAL lSet, nCounter := 0

   DO WHILE s_nThreadCount > 7
      nCounter++
      IF nCounter > 100
         ?E Time(), "thread count>7 (", AllTrim( Str( s_nThreadCount ) ), "), sacekati:", cInfo
         print_threads( "tread_cnt_max" + cInfo )
         RETURN .F.
      ENDIF
#ifdef F18_DEBUG_THREAD
      ?E hb_threadSelf(), "init thread sleep 2"
#endif
      hb_idleSleep( 2 )
   ENDDO

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
   ?E ">>>>> START: thread: ", cInfo, " cnt:(", AllTrim( Str( s_nThreadCount ) ), "in main_thread:", is_in_main_thread(), ") <<<<<"
#endif

   my_server()
   set_f18_home( my_server_params()[ "database" ] )
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

   my_server_close()
#ifdef F18_DEBUG_THREAD
   ?E "<<<<<< END: thread", cInfo, "thread count:", s_nThreadCount
#endif

   RETURN


PROCEDURE print_threads( cInfo )

   LOCAL aThread

   ?E "THREADS:", cInfo
   ?E REPLICATE( "-", 80 )
   FOR EACH aThread IN s_aThreads
      IF ValType( aThread ) == "A"
         ?E s_nThreadCount, aThread[ 3 ], aThread[ 1 ], aThread[ 2 ]
      ELSE
         ?E s_nThreadCount,  ValType( aThread ),  aThread
      ENDIF
   NEXT
   ?E REPLICATE( ".", 80 )

   RETURN
