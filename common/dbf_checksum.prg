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

// ------------------------------------------
// param full synchro - uradi full synchro
// ------------------------------------------
FUNCTION check_recno_and_fix( dbf_alias, cnt_sql, cnt_dbf, full_synchro )

   LOCAL nSelect
   LOCAL _a_dbf_rec
   LOCAL _sql_table
   LOCAL _dbf, _udbf
   LOCAL cErrMsg
   LOCAL cAliasCheck
   LOCAL _err

   IF full_synchro == NIL
      full_synchro := .F.
   ENDIF

   _a_dbf_rec :=  get_a_dbf_rec( dbf_alias )
   _sql_table :=  my_server_params()[ "schema" ] + "." + _a_dbf_rec[ "table" ]

   cAliasCheck := "CHECK__" + _a_dbf_rec[ "alias" ]

   PushWa()

   _udbf := my_home() + _a_dbf_rec[ "table" ]

   IF cnt_dbf == NIL

      BEGIN SEQUENCE WITH {| err| Break( err ) }

         SELECT ( _a_dbf_rec[ "wa" ] + 3000 )
         USE ( _udbf ) ALIAS ( cAliasCheck ) SHARE

         // reccount() se ne moze iskoristiti jer prikazuje i deleted zapise
         // count je vremenski skupa operacija za velike tabele !
         COUNT TO cnt_dbf
         USE

         log_write( "DBF recs " + _a_dbf_rec[ "alias" ] + ": " + AllTrim( Str( cnt_dbf, 10 ) ) + " / sql recs " + _sql_table + ": " + AllTrim( Str( cnt_sql, 10 ) ), 7 )

      RECOVER USING _err

         log_write( "ERROR: check_recno dbUseArea " + _udbf + " MSG: " +  _err:Description, 2 )

      END SEQUENCE

   ENDIF

   IF cnt_sql <> cnt_dbf

      cErrMsg := "full synchro, ERROR: "
      cErrMsg += "broj zapisa DBF tabele " + _a_dbf_rec[ "alias" ] + ": " + AllTrim( Str( cnt_dbf, 10 ) ) + " "
      cErrMsg += "broj zapisa SQL tabele " + _sql_table + ": " + AllTrim( Str( cnt_sql, 10 ) )

      log_write( cErrMsg )

      IF full_synchro

         IF cnt_dbf > 0
            notify_podrska( cErrMsg )
         ENDIF

         full_synchro( _a_dbf_rec[ "table" ], 50000 )

      ENDIF

   ENDIF

   PopWa()

   RETURN .T.
