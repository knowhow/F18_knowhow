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

FUNCTION o_dbf_table( nArea, cTable, cTag )

   LOCAL lUsed := .F.
   LOCAL nCount := 0

   SELECT ( nArea )
   DO WHILE !lUsed .OR. nCount > 7
      IF my_use( cTable )
         lUsed := .T.
         ordSetFocus( cTag )
         IF Empty( ordKey() )
            lUsed := .F.
            ?E "ERR o_pos_table:", cTable, cTag
            USE
         ENDIF
      ELSE
         hb_idleSleep( 1.5 )
         nCount++
      ENDIF

   ENDDO

   RETURN lUsed


/*
   select_o_dbf( "fakt_doks", F_FAKT_DOKS, "fakt_doks", "1" )
*/

FUNCTION select_o_dbf( cAlias, nArea, cTable, cTag )

   IF Select( cAlias ) == 0
      o_dbf_table( nArea, cTable, cTag )
   ENDIF

   Select( nArea )

   RETURN .T.
