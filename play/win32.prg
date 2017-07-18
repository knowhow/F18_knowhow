
#ifdef __PLATFORM__WINDOWS
#pragma BEGINDUMP

#include "hbapi.h"
#include "hbapierr.h"
#include "hbapigt.h"
#include "hbapiitm.h"
#include "hbapifs.h"
#include "windows.h"

/* TOFIX: The screen buffer handling is not right for all platforms (Windows)
          The output of the launched (MS-DOS?) app is not visible. */

HB_FUNC( __WIN32_SYSTEM )
{
   const char * pszCommand = hb_parc( 1 );
   const char * pszArguments = hb_parc( 2 );
   int iResult;

   if( pszCommand && hb_gtSuspend() == HB_SUCCESS )
   {
      char * pszFree = NULL;


      STARTUPINFO si;
      PROCESS_INFORMATION pi;

      ZeroMemory( &si, sizeof(si) );
      si.cb = sizeof(si);
      ZeroMemory( &pi, sizeof(pi) );

     // CreateProcess https://msdn.microsoft.com/en-us/library/windows/desktop/ms682512(v=vs.85).aspx
    // https://stackoverflow.com/questions/780465/winapi-createprocess-but-hide-the-process-window
    // create no window 0x08000000

     // https://msdn.microsoft.com/en-us/library/bb762153(VS.85).aspx SW_HIDE = 0, SW_SHOWNORMAL (1), SW_SHOWMINNOACTIVE (7)

      //iResult =  ShellExecute(NULL, "open", pszCommand, pszArguments, NULL, 7);

      // https://msdn.microsoft.com/en-us/library/windows/desktop/ms684863(v=vs.85).aspx

      // https://msdn.microsoft.com/en-us/library/windows/desktop/ms684863(v=vs.85).aspx
      // Process Creation Flags 0x080000 - CREATE_NO_WINODOW

      si.wShowWindow = SW_SHOW;
      si.dwFlags = STARTF_USESHOWWINDOW;
      si.lpTitle = "my_process_console";

      //CreateProcess(NULL, pszCommand, NULL, null,null,false,CREATE_NEW__CONSOLE,null,null,&si,&pi);

    //CreateProcess(null,"notepad.exe",null,null,false,CREATE_NEW__CONSOLE,null,null,&si,&pi);

    // CreateProcess(NULL, pszCommand, NULL, NULL, FALSE,
      //        CREATE_NO_WINDOW, NULL, &si, &pi);

CreateProcess(null,"my.exe",null,null,false,CREATE_NEW__CONSOLE,null,null,&si,&pi);

      HWND console_name = FindWindow(null,"my_process_console");
      if(console_name){
                ShowWindow(console_name, SW_SHOW);
      }

      iResult = 1;


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


__win32_system(  "notepad" )

#endif


