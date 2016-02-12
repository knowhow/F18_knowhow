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
#include "common.ch"



FUNCTION my_usex( alias, table, new_area )

/*
   IF PCount() > 3
      Alert( "my_usex error > 3" )
   ENDIF
*/
   RETURN my_use_temp( alias, table, new_area, .T. )


/*
 uopste ne koristi logiku semafora, koristiti za temp tabele
 kod opcija exporta importa
*/

FUNCTION my_use_temp( alias, table, new_area, excl )

   LOCAL nCnt, nSelect, _a_dbf_rec, _tmp
   LOCAL oError

   IF excl == NIL
      excl := .F.
   ENDIF

   IF new_area == NIL
      new_area := .F.
   ENDIF

   // prvo pokušati iskoristiti alias
   IF alias == NIL
      _tmp := table
   ELSE
      _tmp := alias
   ENDIF

   BEGIN SEQUENCE WITH {| err| Break( err ) }

      _a_dbf_rec := get_a_dbf_rec( _tmp, .T. )

      IF table == nil
         table := my_home() + _a_dbf_rec[ "table" ]
      ENDIF

      nSelect := Select( _a_dbf_rec[ "alias" ] )
      IF nSelect > 0 .AND. ( nSelect <> _a_dbf_rec[ "wa" ] )
         log_write( "WARNING: " + _a_dbf_rec[ "table" ] + " na WA=" + Str( nSelect ) + " ?", 3 )
         Select( nSelect )
         USE
      ENDIF

      IF !new_area
         SELECT ( _a_dbf_rec[ "wa" ] )
      ENDIF

   RECOVER
      log_write( "ERROR: " + _tmp + " nema a_dbf_rec !", 2 )
   END SEQUENCE


   IF Used()
      USE
   ENDIF

   nCnt := 0
   DO WHILE nCnt < 3
      BEGIN SEQUENCE WITH {| err | Break( err ) }

         dbUseArea( new_area, DBFENGINE, table, alias, !excl, .F. )
         IF File( ImeDbfCdx( table ) )
            dbSetIndex( ImeDbfCDX( table ) )
         ENDIF
         nCnt := 100

      RECOVER USING oError

         my_use_error( table, alias, oError )
         hb_idleSleep( 1 )

      END SEQUENCE

      ++nCnt
   ENDDO

   IF nCnt < 100
      RaiseError( "ERROR: my_use " + table + " neusjesno !" )
   ENDIF

   RETURN .T.


// ----------------------------------------------------------------
// semaphore_param se prosjedjuje eval funkciji ..from_sql_server
// ----------------------------------------------------------------
FUNCTION my_use( alias, table, new_area, _rdd, semaphore_param, excl, select_wa )

   LOCAL nCnt
   LOCAL _msg
   LOCAL _err
   LOCAL _pos
   LOCAL _version, _last_version
   LOCAL _area
   LOCAL _force_erase := .F.
   LOCAL _dbf
   LOCAL _tmp
   LOCAL nSelect
   LOCAL lOdradioFullSynchro := .F.
   LOCAL lUspjesno
   LOCAL oError
   LOCAL _a_dbf_rec
   LOCAL nI, cMsg, cStack := ""

   IF PCount() <= 2
      RETURN my_use_simple( alias, table )
   ENDIF

   // todo: my_use legacy

#ifdef F18_DEBUG
   MsgBeep( "my_use legacy sekvenca - out " )
   LOG_CALL_STACK cStack .F.
   Alert( cStack )
#endif
   AltD() // legacy stop

   IF excl == NIL
      excl := .F.
   ENDIF

   IF select_wa == NIL
      select_wa = .T.
   ENDIF

   IF table == NIL
      _tmp := alias
   ELSE
      _tmp := table
   ENDIF

   // trebam samo osnovne parametre
   _a_dbf_rec := get_a_dbf_rec( _tmp, .T. )

   IF new_area == NIL
      new_area := .F.
   ENDIF

   nSelect := Select( _a_dbf_rec[ "alias" ] )
   IF nSelect > 0 .AND. ( nSelect <> _a_dbf_rec[ "wa" ] )
      log_write( "WARNING: " + _a_dbf_rec[ "table" ] + " na WA=" + Str( nSelect ) + " ?", 3 )
      Select( nSelect )
      USE
   ENDIF
   // pozicioniraj se na WA rezervisanu za ovu tabelu
   IF select_wa
      SELECT ( _a_dbf_rec[ "wa" ] )
   ENDIF

   IF ( alias == NIL ) .OR. ( table == NIL )
      // za specificne primjene kada "varamo" sa aliasom
      // my_use("fakt_pripr", "fakt_fakt")
      // tada ne diramo alias
      alias := _a_dbf_rec[ "alias" ]
   ENDIF

   table := _a_dbf_rec[ "table" ]

   IF ValType( table ) != "C"
      _msg := ProcName( 2 ) + "(" + AllTrim( Str( ProcLine( 2 ) ) ) + ") table name VALTYPE = " + ValType( table )
      Alert( _msg )
      log_write( _msg, 5 )
      QUIT_1
   ENDIF

   IF _rdd == NIL
      _rdd = DBFENGINE
   ENDIF

   IF !( _a_dbf_rec[ "temp" ] )

      IF ( _rdd != "SEMAPHORE" )

         dbf_semaphore_synchro( table, @lOdradioFullSynchro )

         IF lOdradioFullSynchro
            set_a_dbf_rec_chk0( _a_dbf_rec[ "table" ] )
         ENDIF

         IF !_a_dbf_rec[ "chk0" ]
            // nije nikada uradjena inicijalna kontrola ove tabele
            refresh_me_izbaciti( _a_dbf_rec, .T., .T. )
         ENDIF

      ELSE
         // rdd = "SEMAPHORE" poziv is update from sql server procedure
         // samo otvori tabelu
         log_write( "my_use table:" + table + " / rdd: " +  _rdd + " alias: " + alias + " exclusive: " + hb_ValToStr( excl ) + " new: " + hb_ValToStr( new_area ), 8 )
         _rdd := DBFENGINE
      ENDIF

   ENDIF

   IF Used()
      USE
   ENDIF

   _dbf := my_home() + table

   nCnt := 0

   lUspjesno := .F.
   DO WHILE ( !lUspjesno ) .AND. ( nCnt < 10 )

      BEGIN SEQUENCE WITH {| err| Break( err ) }

         dbUseArea( new_area, _rdd, _dbf, alias, !excl, .F. )
         IF File( ImeDbfCdx( _dbf ) )
            dbSetIndex( ImeDbfCDX( _dbf ) )
         ENDIF
         lUspjesno := .T.

      RECOVER USING oError

         my_use_error( table, alias, oError )
         hb_idleSleep( 1 )

      END SEQUENCE

      nCnt ++

   ENDDO

   IF !lUspjesno
      RaiseError( "ERROR: my_use " + table + " neusjesno !" )
   ENDIF

   RETURN .T.



FUNCTION my_use_simple( cAlias, cTable )

   LOCAL nCnt, oError, lUspjesno, cFullDbf, cFullIdx
   LOCAL aDbfRec
   LOCAL lExcl := .F.
   LOCAL cRdd := DBFENGINE

   IF cTable != NIL
      // my_use( kalk_pripr, kalk_kalk )
      aDbfRec := get_a_dbf_rec( cTable, .T. )
   ELSE
      aDbfRec := get_a_dbf_rec( cAlias, .T. )
      cAlias :=  aDbfRec[ 'alias' ]
   ENDIF

   dbf_refresh( aDbfRec[ 'table' ] )

   cFullDbf := my_home() + aDbfRec[ 'table' ]
   cFullIdx := ImeDbfCdx( cFullDbf )

   nCnt := 0

   lUspjesno := .F.
   DO WHILE ( !lUspjesno ) .AND. ( nCnt < 5 )

      BEGIN SEQUENCE WITH {| err| Break( err ) }

         IF nCnt > 0
            log_write( "use_cnt=" + AllTrim( Str( nCnt ) ) + " t: " + aDbfRec[ 'table' ] + " a: " + cAlias, 5 )
         ENDIF

         SELECT ( aDbfRec[ "wa" ] )
         IF Select( cAlias ) > 0
            USE
         ENDIF

         dbUseArea( .F., cRdd, cFullDbf, cAlias, !lExcl, .F. )
         IF File(  cFullIdx )
            dbSetIndex( cFullIdx )
         ENDIF


         lUspjesno := .T.

      RECOVER USING oError
         my_use_error( aDbfRec[ 'table' ], cAlias, oError )
         hb_idleSleep( 1 )

      END SEQUENCE

      nCnt ++

   ENDDO

   IF !lUspjesno
      RaiseError( "ERROR: my_use " + aDbfRec[ 'table' ] + " neusjesno !" )
   ENDIF

   RETURN .T.


/*
   desio se error kod pokusaja otvaranja tabele
*/

FUNCTION my_use_error( table, alias, oError )

   LOCAL _msg, nI, cMsg

   _msg := "ERROR: my_use_error " + oError:description + ": tbl:" + my_home() + table + " alias:" + alias + " se ne moze otvoriti ?!"
   LOG_CALL_STACK _msg .F.
   log_write( _msg, 2 )

   IF oError:description == "Read error" .OR. oError:description == "Corruption detected"

      // Read error se dobije u slucaju ostecenog dbf-a
      IF ferase_dbf( alias, .T. )
         repair_dbfs()
      ENDIF

   ENDIF

   RETURN .T.



FUNCTION dbf_semaphore_synchro( table, lFullSynchro )

   LOCAL lRet := .T.
   LOCAL hVersion

   lFullSynchro := .F.

   log_write( "START dbf_semaphore_synchro", 9 )

   hVersion :=  get_semaphore_version_h( table )

   IF ( hVersion[ 'version' ] == -1 )
      log_write( "full synchro version semaphore version -1", 7 )
      lFullSynchro := .T.
      update_dbf_from_server( table, "FULL" )
   ELSE

      IF ( hVersion[ 'version' ] < hVersion[ 'last_version' ] )
         log_write( "dbf_semaphore_synchro/1, my_use" + table + " osvjeziti dbf cache: ver: " + ;
            AllTrim( Str( hVersion[ 'version' ], 10 ) ) + " last_ver: " + AllTrim( Str( hVersion[ 'last_version' ], 10 ) ), 5 )
         update_dbf_from_server( table, "IDS" )
      ENDIF
   ENDIF

   log_write( "END dbf_semaphore_synchro", 9 )

   RETURN lRet
