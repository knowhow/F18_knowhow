
#pragma BEGINDUMP

#include "hbapi.h"
#include "hbapierr.h"
#include "hbapigt.h"
#include "hbapiitm.h"
#include "hbapifs.h"

/* TOFIX: The screen buffer handling is not right for all platforms (Windows)
          The output of the launched (MS-DOS?) app is not visible. */

HB_FUNC( __RUN_SYSTEM )
{
   const char * pszCommand = hb_parc( 1 );

   int iResult;

   if( pszCommand && hb_gtSuspend() == HB_SUCCESS )
   {
      char * pszFree = NULL;

      iResult = system( hb_osEncodeCP( pszCommand, &pszFree, NULL ) );

      hb_retni(iResult);

      if( pszFree )
         hb_xfree( pszFree );

      if( hb_gtResume() != HB_SUCCESS )
      {
         /* an error should be generated here !! Something like */
         /* hb_errRT_BASE_Ext1( EG_GTRESUME, 6002, NULL, HB_ERR_FUNCNAME, 0, EF_CANDEFAULT ); */
      }
   }
}


#pragma ENDDUMP

_cmd := "c:\windows\system32\notepad.exe"

_cmd := "start f18_editor.cmd c:\Documents and Settings\hbakir\.f18\bringout_2012\outf.txt"

_cmd := "copy test_run.xprg test_copy.txt"
_cmd := 'echo f18_test2 > "%HOME%\test copy.txt"'

? "run"


_stderr := ""
_stdout := ""


//_ret := hb_processrun(_cmd, @_stderr, @_stdout)

//_ret := (_cmd, NIL, NIL, NIL)
_ret := __run_system(_cmd)



? "stderr", _stderr
? "stdout", _stdout
? _ret

inkey(0)
