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


FUNCTION check_recno_and_fix( cDbfAlias, nCntSql, nCntDbf )

   LOCAL _a_dbf_rec
   LOCAL _sql_table
   LOCAL cErrMsg

   _a_dbf_rec :=  get_a_dbf_rec( cDbfAlias )
   _sql_table :=  my_server_params()[ "schema" ] + "." + _a_dbf_rec[ "table" ]

   IF nCntSql <> nCntDbf

      cErrMsg := "full synchro ERROR: "
      cErrMsg += "broj zapisa DBF tabele " + _a_dbf_rec[ "alias" ] + ": " + AllTrim( Str( nCntDbf, 10, 0) ) + " "
      cErrMsg += "broj zapisa SQL tabele " + _sql_table + ": " + AllTrim( Str( nCntSql, 10 ) )

#ifdef F18_DEBUG
      IF ABS(nCntDbf - nCntSql) < 2
          Alert( "jedan zapis razlike ?!")
          QUIT_1
      ENDIF
#endif
      log_write( cErrMsg, 3 )

      IF nCntDbf > 0
         notify_podrska( cErrMsg )
      ENDIF

      full_synchro( _a_dbf_rec[ "table" ], 50000, "dbf_cnt_before: " + AllTrim( Str( nCntDbf, 10, 0) ) )

   ENDIF

   RETURN .T.
