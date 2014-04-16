
#include "fmk.ch"
#include "hbclass.ch"

CLASS Unicode

  METHOD New()
  METHOD set()
  METHOD getString()
  METHOD getCpString()
  METHOD PadR()
  DATA lUtf8
  DATA cString

ENDCLASS

METHOD Unicode:New( xVal, lUtf8 )

  ::lUtF8 := .T.

  ::set( xVal, lUtf8 )

  RETURN Self

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
    RETURN hb_Utf8ToStr( ::cString )
  ELSE
    RETURN ::cString
  ENDIF
 
METHOD Unicode:PadR( nNum )

  LOCAL cStr := ::getCpString()

  // pretvori u CP string, pa ga PadR-aj, pa ga vrati kao UTF-8
  RETURN hb_StrToUtf8( PadR( cStr, nNum ) )

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
       ::cString := xVal:getString()
       ::lUtf8 := .T.
       EXIT

     OTHERWISE
       ::cString := NIL

   END SWITCH

   RETURN .T.

 
