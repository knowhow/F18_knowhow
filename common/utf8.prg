include "hbclass.ch"

CLASS String

  METHOD getUtf()

  DATA lUtf8
  DATA cString

END CLASS

METHOD String:New( xVal )

  :lUtf8 := .T

  SWITCH ValType( xVal )

   CASE "C"
       cString := xVal
       EXIT
   CASE "O"
       cString := xVal:getUtf()
       EXIT

   OTHERWISE
       cString := NIL

  END SWITCH
  ::cString := cString

  RETURN

METHOD String:is_utf()

  RETURN lUtf8
