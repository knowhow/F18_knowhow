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


PROCEDURE init_thread( cInfo )


   DO WHILE .T.
      IF s_nThreadCount > 7
         ?E "thread count>7 sacekati", s_nThreadCount
         hb_idleSleep( 1.5 )
         LOOP
      ELSE
         EXIT
      ENDIF
   ENDDO

   s_nThreadCount++

#ifdef F18_DEBUG
   ?E ">>>>> START: thread", cInfo, "thread count:", s_nThreadCount, "<<<<<"
#endif

   set_f18_home( my_server_params()[ "database" ] )
   init_parameters_cache()

   RETURN


PROCEDURE close_thread( cInfo )

   my_server_close()
   s_nThreadCount--


#ifdef F18_DEBUG
   ?E "<<<<<< END: thread", cInfo, "thread count:", s_nThreadCount
#endif

   RETURN
