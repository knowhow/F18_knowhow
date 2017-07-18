#include "f18.ch"


STATIC s_hClipBoard

PROCEDURE get_clipboard()

   LOCAL cDostupniRegistri, cReg, oGet, cKey, xVarTrenutno, nLen

   IF s_hClipBoard == NIL
      error_bar( "clip", "clipboard prazan" )
      RETURN
   ENDIF

   IF __GetListActive() != NIL
      oGet := __GetListActive():Get()
      xVarTrenutno := oGet:varGet()
      IF ValType( xVarTrenutno ) != "C"
         error_bar( "clip", "clipboard se koristi samo za string varijable" )
         RETURN
      ENDIF
   ELSE
      RETURN
   ENDIF

   cDostupniRegistri := ""
   FOR EACH cKey in s_hClipBoard:keys
      cDostupniRegistri += " " + cKey
   NEXT
   info_bar( "clip", "clipboard dostupni registri: " + cDostupniRegistri )
   error_bar( "clip", "" )

   Inkey( 0 )
   cReg := Chr( LastKey() )
   IF !( cReg $ "0123456789" )
      cReg := "0"
   ENDIF

   IF hb_HHasKey( s_hClipBoard, cReg )
      nLen := LEN( xVarTrenutno )
      oGet:varPut( PADR( s_hClipBoard[ cReg ], nLen ) )
      info_bar( "clip", "clipboard uzeto iz registra " + cReg )
   ELSE
      error_bar( "clip", "clipboard no register " + cReg )
   ENDIF

   RETURN


PROCEDURE set_clipboard()

   LOCAL xVar, cReg

   IF s_hClipBoard == NIL
      s_hClipBoard := hb_Hash()
   ENDIF

   xVar := __GetListActive():Get():varGet()

   info_bar( "clip", "clipboard pohrani u registar 0-9" )

   IF ValType( xVar ) != "C"
      RETURN
   ENDIF

   Inkey( 0 )
   cReg := Chr( LastKey() )

   IF !( cReg $ "0123456789" )
      cReg := "0"
   ENDIF
   s_hClipBoard[ cReg ] := xVar
   info_bar( "clip", "set register " + cReg )

   RETURN
