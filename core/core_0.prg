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


FUNCTION harbour_init()

   rddSetDefault( RDDENGINE )
   Set( _SET_AUTOPEN, .F.  )

   SET CENTURY OFF
   SET EPOCH TO 1980  // 81 - 1981,  79-2079
   SET DATE TO GERMAN

   f18_init_threads()


   Set( _SET_OSCODEPAGE, hb_cdpOS() )

// ? SET( _SET_OSCODEPAGE )


   hb_cdpSelect( "SL852" )
   // hb_SetTermCP( "SLISO" )



   SET DELETED ON

   SetCancel( .F. )

   Set( _SET_EVENTMASK, INKEY_ALL )
   MSetCursor( .T. )

   SET DATE GERMAN
   SET SCOREBOARD OFF
   Set( _SET_CONFIRM, .T. )
   SET WRAP ON
   SET ESCAPE ON
   SET SOFTSEEK ON

   SetColor( f18_color_normal() )

   // Set( _SET_IDLEREPEAT, .F. ) // .T. default
   hb_idleAdd( {|| on_idle_dbf_refresh() } )  // BUG_CPU100
   // hb_idleAdd( {|| idle_eval() } ) - izaziva erore

   RETURN .T.


FUNCTION f18_ver_show( lShort )

   hb_default( @lShort, .T. )

   RETURN f18_ver() + + "/" + f18_lib_ver() + iif( lShort, "", " " + f18_ver_date() )


FUNCTION f18_ver_info( lShort )

   RETURN "v(" + f18_ver( lShort ) + ")"


FUNCTION browse_dbf( cDbf )

   LOCAL cScr

   SAVE SCREEN TO cScr

   PushWA()
   SET SCOREBOARD ON
   my_dbSelectArea( cDbf )
   dbEdit()
   PopWA()
   RESTORE SCREEN FROM cScr

   RETURN Alias()


FUNCTION k_ctrl_f9()

   IF is_mac()
      RETURN hb_keyCode( "9" )
   ENDIF

   RETURN K_CTRL_F9

/*
    download_file( "http://download/test.zip", NIL ) => /home/bringout/.f18/wget_232X66.tmp

    ako je Error
*/

FUNCTION download_file( cUrl, cDestFile )

   LOCAL hFile
   LOCAL cFileName, lRet := .F.

   Box( "#Download: " + Alltrim( Right( cUrl, 60) ), 2, 75 )
   hFile := hb_vfTempFile( @cFileName, my_home_root(), "wget_", ".tmp" )
   hb_vfClose( hFile )

   @ m_x + 1, m_y + 2 SAY Left( cUrl, 72 )

   lRet := F18Admin():wget_download( cUrl, "", cFileName )

   BoxC()

   IF lRet
      IF cDestFile != NIL
         COPY FILE ( cFileName ) TO ( cDestFile )
         RETURN cDestFile
      ELSE
         RETURN cFileName
      ENDIF
   ELSE
      RETURN ""
   ENDIF

   RETURN ""


FUNCTION ExePath()

   RETURN hb_FNameDir( hb_ProgName() )
