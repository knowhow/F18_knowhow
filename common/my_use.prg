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

FUNCTION my_use_temp( xArg1, cFullDbf, lNewArea, lExcl, lOpenIndex )

   LOCAL cAlias, nWa
   LOCAL nCnt, nSelect, aDbfRec
   LOCAL oError

   IF lExcl == NIL
      lExcl := .F.
   ENDIF

   IF lNewArea == NIL
      lNewArea := .F.
   ENDIF

   IF lOpenIndex == NIL
      lOpenIndex := .T.
   ENDIF

   SWITCH ValType( xArg1 )
   CASE "H"
      cFullDbf := xArg1[ 'full_table' ]
      nWa := xArg1[ 'wa' ]
      cAlias := xArg1[ 'alias' ]
      EXIT
   CASE "C"
      cAlias := xArg1
      aDbfRec := get_a_dbf_rec( cAlias, .T. )
      nWa := aDbfRec[ 'wa' ]
      IF cFullDbf == nil
         cFullDbf := my_home() + aDbfRec[ "table" ]
      ENDIF
      EXIT

   OTHERWISE
      cAlias := "TMP"
      EXIT
   ENDSWITCH


   nSelect := Select( cAlias )
   IF nSelect > 0 .AND. ( nSelect <> nWa )
      log_write( "WARNING: " + aDbfRec[ "table" ] + " na WA=" + Str( nSelect ) + " ?", 3 )
      Select( nSelect )
      USE
   ENDIF

   IF !lNewArea
      SELECT ( nWa )
   ENDIF
   IF Used()
      USE
   ENDIF

   nCnt := 0
   DO WHILE nCnt < 3
      BEGIN SEQUENCE WITH {| err | Break( err ) }

         dbUseArea( lNewArea, DBFENGINE, cFullDbf, cAlias, !lExcl, .F. )
         IF lOpenIndex .AND. File( ImeDbfCdx( cFullDbf ) )
            dbSetIndex( ImeDbfCDX( cFullDbf ) )
         ENDIF
         nCnt := 100

      RECOVER USING oError

         my_use_error( cFullDbf, cAlias, oError )
         hb_idleSleep( 1 )

      END SEQUENCE

      ++nCnt
   ENDDO

   IF nCnt < 100
      RaiseError( "ERROR-TMP: my_use_tmp " + cFullDbf + " neusjesno !" )
   ENDIF

   RETURN .T.



FUNCTION my_use( cAlias, cTable, lRefresh )

   LOCAL nCnt, oError, lUspjesno, cFullDbf, cFullIdx
   LOCAL aDbfRec
   LOCAL lExcl := .F.
   LOCAL cRdd := DBFENGINE
   LOCAL nI, cMsg, cLogMsg := ""

   IF PCount() > 3
      LOG_CALL_STACK cLogMsg
      log_write( "my_use ERROR params>3: " + cLogMsg, 1 )
   ENDIF

   hb_default( @lRefresh, .T. )

   IF cTable != NIL
      aDbfRec := get_a_dbf_rec( cTable, .T. ) // my_use( kalk_pripr, kalk_kalk )
   ELSE
      aDbfRec := get_a_dbf_rec( cAlias, .T. )
      cAlias :=  aDbfRec[ 'alias' ]
   ENDIF

   IF lRefresh
      thread_dbfs( hb_threadStart( @thread_dbf_refresh(), aDbfRec[ 'table' ] ) )
   ENDIF

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
   LOG_CALL_STACK _msg
   log_write( _msg, 2 )

   IF oError:description == "Read error" .OR. oError:description == "Corruption detected"

      // Read error se dobije u slucaju ostecenog dbf-a
      IF ferase_dbf( alias, .T. )
         // repair_dbfs()
      ENDIF

   ENDIF

   RETURN .T.
