/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"


FUNCTION _sql_query( oServer, cQuery, silent )
   RETURN run_sql_query( cQuery, 10 )


FUNCTION run_sql_query( qry, retry )

   LOCAL _i, _qry_obj, lMsg := .F.
   LOCAL cErrorMsg
   LOCAL _server := my_server()
   LOCAL lRestorePoint := .F.
   LOCAL cSavePointName := f18_user() + "_save_point"

   IF retry == NIL
      retry := 10
   ENDIF

   IF ValType( qry ) != "C"
      _msg := "qry ne valja VALTYPE(qry) =" + ValType( qry )
      log_write( _msg, 2 )
      MsgBeep( _msg )
      quit_1
   ENDIF

   //IF _server:TransactionStatus() > 0
     // lRestorePoint := .T.
   //ENDIF

   FOR _i := 1 TO retry

      IF _i > 1
         MsgO( "Pokušavam izvršiti SQL upit: " + qry + " pokušaj: " + ALLTRIM( STR( _i ) ) )
         lMsg := .T.
      ENDIF
       
      BEGIN SEQUENCE WITH {| err| Break( err ) }

         //IF lRestorePoint
           // _qry_obj := _server:Query( "SAVEPOINT " + cSavePointName + ";" )
         //ENDIF

         _qry_obj := _server:Query( qry + ";" )

      RECOVER 

         hb_idleSleep( 1 )

      END SEQUENCE

      IF _qry_obj:NetErr() 

         cErrorMsg := "ERROR RUN_SQL_QRY: " + _qry_obj:ErrorMsg() + " QRY:" + qry

         //IF lRestorePoint
           // _qry_obj := _server:Query( "ROLLBACK TO " + cSavePointName + ";" )
         //ENDIF

         IF _i == retry
            MsgC()
            //notify_podrska( cErrorMsg )
            RETURN .F.
         ENDIF

      ELSE
         _i := retry + 1
      ENDIF

      IIF( lMsg, MsgC(), NIL )

   NEXT

   RETURN _qry_obj



FUNCTION _sql_query_orig( oServer, cQuery, silent )

   LOCAL oQuery, cMsg

   IF silent == NIL
      silent := .F.
   ENDIF

#ifdef NODE
   log_write( cQuery, 1 )
#endif

   oQuery := oServer:Query( cQuery + ";" )

   IF oQuery:lError

      cMsg := oQuery:cError

      IF !Empty( cMsg )
         log_write( "ERROR: _sql_query: " + cQuery + "err msg:" + cMsg, 1, silent )

         IF !silent
            Alert( cQuery + " : " + cMsg )
         ENDIF
      ENDIF

      RETURN .F.

   ELSE

      log_write( "QRY OK: _sql_query: " + cQuery, 9, silent )

   ENDIF

   RETURN oQuery



FUNCTION is_var_objekat_tpquery( xVar )
   RETURN is_var_objekat_tipa( xVar, "TPQuery" )



FUNCTION is_var_objekat_tipa( xVar, cClassName )

   IF ValType( xVar ) == "O" .AND. xVar:ClassName() != cClassName
      RETURN .T.
   ENDIF

   RETURN .F.



