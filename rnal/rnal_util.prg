#include "f18.ch"

FUNCTION get_broj_stakala( nNalog )

   LOCAL cQuery, oRez
   LOCAL oServer := my_server()

   cQuery := "SELECT sum(doc_it_qtt) FROM " + F18_PSQL_SCHEMA_DOT + "rnal_doc_it" + ;
      " WHERE doc_no = " + docno_str( nNalog )

   oRez := _sql_query( oServer, cQuery )

   IF oRez == NIL
      RETURN -1
   ENDIF

   RETURN oRez:FieldGet( 1 )
