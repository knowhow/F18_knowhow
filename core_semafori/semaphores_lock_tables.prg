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

/*


  koristenje f18_lock_tables( arr ), f18_free_tables( arr )

  if !f18_lock_tables( {"pos_doks", "pos_pos"} )
     -- prekidamo operaciju
  endif

  sql_table_update(nil, "BEGIN")
       update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
       f18_free_tables( {"pos_doks", "pos_pos"} )
  run_sql_query( "COMMIT" )

  ako imamo samo jedan zapis, jednu tabelu, transakcija i lockovanje
  se desavaju unutar funkcije update_rec_server_and_dbf:

       update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )

  na isti nacin se koristi i u kombinaciji sa:

        delete_rec_server_and_dbf()


  sql_table_update(nil, "BEGIN")
     f18_lock_tables( { "rnal_vako", "rnal_nako" }, .T. }
  run_sql_query( "COMMIT" )

*/

FUNCTION f18_lock_tables( a_tables, lAlreadyInTransakcija )

   LOCAL _ok := .T.
   LOCAL _i, _tbl, _dbf_rec

   hb_default( @lAlreadyInTransakcija, .F. )

   IF Len( a_tables ) == NIL
      RETURN .F.
   ENDIF

   //IF  iif( lAlreadyInTransakcija, .T., run_sql_query( "BEGIN" ) )

      FOR _i := 1 TO Len( a_tables )
         _dbf_rec := get_a_dbf_rec( a_tables[ _i ] )
         _tbl := _dbf_rec[ "table" ]
         IF !_dbf_rec[ "sql" ]
            _ok := _ok .AND. lock_semaphore( _tbl, "lock" )
         ENDIF
      NEXT

      IF _ok

         //IF !lAlreadyInTransakcija
         //    run_sql_query( "COMMIT" )
         //ENDIF
         //log_write( "uspjesno izvrsen lock tabela " + pp( a_tables ), 7 )


         FOR _i := 1 TO Len( a_tables )
            _dbf_rec := get_a_dbf_rec( a_tables[ _i ] )
            //IF !_dbf_rec[ "sql" ]
            //   dbf_refresh( _dbf_rec[ "table" ] )  NE U MAIN THREAD!
            //ENDIF
         NEXT

      ELSE
         log_write( "ERROR: nisam uspio napraviti lock tabela " + pp( a_tables ), 2 )
         //IF !lAlreadyInTransakcija
         //  run_sql_query( "ROLLBACK" )
         //ENDIF
         _ok := .F.

      ENDIF

   // ELSE
   //
   //    _ok := .F.
   //    log_write( "ERROR: nisam uspio napraviti lock tabela " + pp( a_tables ), 2 )
  //
   //ENDIF

   RETURN _ok


/*
   unlokovanje tabela:

   f18_free_tables( {"pos_pos", "pos_doks"} )

*/

FUNCTION f18_free_tables( a_tables )

   LOCAL _ok := .T.
   LOCAL _i, _tbl, _dbf_rec
   LOCAL cMsg

   IF Len( a_tables ) == NIL
      RETURN .F.
   ENDIF

   FOR _i := 1 TO Len( a_tables )
      _dbf_rec := get_a_dbf_rec( a_tables[ _i ], .T. )
      _tbl := _dbf_rec[ "table" ]
      IF !_dbf_rec[ "sql" ]
         lock_semaphore( _tbl, "free" )
      ENDIF
   NEXT

   cMsg := "uspjesno izvrseno oslobadjanje tabela " + pp( a_tables )
   log_write( cMsg, 7 )

#ifdef F18_DEBUG
   ?E cMsg
#endif

   RETURN _ok
