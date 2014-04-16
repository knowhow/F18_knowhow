
#include "fmk.ch"
#include "hbclass.ch"

CLASS Unicode

  METHOD set()
  METHOD getString()
  METHOD getCpString()

  DATA lUtf8
  DATA cString

ENDCLASS

METHOD Unicode:New( xVal, lUtf8 )

  ::set( xVal, lUtf8 )

  RETURN

METHOD Unicode:is_utf8()

  RETURN ::lUtf8


METHOD Unicode:getString()

  IF ::lUtf8
    RETURN ::cString
  ELSE
    RETURN hb_StrToUtf8( ::cString )
  ENDIF

 
METHOD Unicode:getCpString()

  IF ::lUtf8
    RETURN ::cString
  ELSE
    RETURN hb_StrToUtf8( ::cString )
  ENDIF

  
METHOD Unicode:set( xVal, lUtf8 )

   IF lUtf8 == NIL
      lUtf8 := .T.
   ENDIF


   SWITCH ValType( xVal )
     CASE "C"
       ::cString := xVal
       ::lUtf8 := lUtf8
       EXIT

     CASE "O"
       ::cString := xVal:get()
       ::lUtf8 := xVal:is_utf8()
       EXIT

     OTHERWISE
       ::cString := NIL
       ::lUtf8 := NIL

   END SWITCH

   RETURN .T.

 
