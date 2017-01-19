#include "f18.ch"

#ifdef __PLATFORM__UNIX
#define INI_FNAME "f18_config.hIniParams"
#else
#define INI_FNAME ".f18_config.hIniParams"
#endif

FUNCTION f18_ini_config_read( cSection, hIniParams, lGlobalno )

   LOCAL cTmpIniSection
   LOCAL cTmpKey
   LOCAL cIniFile
   LOCAL ini_read

   IF ( lGlobalno == NIL ) .OR. ( lGlobalno == .F. )
      cIniFile := my_home() + INI_FNAME
   ELSE
      cIniFile := my_home_root() + INI_FNAME
   ENDIF

   IF !File( cIniFile )
      error_bar( "ini", "ini ne postoji: " + cIniFile )
      RETURN .F.
   ELSE
      ini_read := hb_iniRead( cIniFile )
   ENDIF


   IF Empty( ini_read )
      log_write( "Fajl je prazan: " + cIniFile )

   ELSE
      IF hb_HHasKey( ini_read, cSection )

         cTmpIniSection := ini_read[ cSection ]
         FOR EACH cTmpKey in hIniParams:Keys
            // napuni ini sa onim sto si procitao
            IF hb_HHasKey( cTmpIniSection, cTmpKey )
               hIniParams[ cTmpKey ] := cTmpIniSection[ cTmpKey ]
            ENDIF
         NEXT

      ENDIF
   ENDIF

   RETURN .T.


FUNCTION f18_ini_config_write( cSection, hIniParams, lGlobalno )

   LOCAL cTmpKey
   LOCAL cIniFile
   LOCAL ini_read

   IF ( lGlobalno == NIL ) .OR. ( lGlobalno == .F. )
      cIniFile := my_home() + INI_FNAME
   ELSE
      cIniFile := my_home_root() + INI_FNAME
   ENDIF

   ini_read := hb_iniRead( cIniFile )

   IF Empty( ini_read )
      ini_read := hb_Hash()
   ENDIF

   IF !hb_HHasKey( ini_read, cSection )
      ini_read[ cSection ] := hb_Hash()
   ENDIF

   // napuni ini_read sa vrijednostima iz ini matrice
   FOR EACH cTmpKey in hIniParams:Keys
      ini_read[ cSection ][ cTmpKey ] := hIniParams[ cTmpKey ]
   NEXT


   IF !hb_iniWrite( cIniFile, ini_read, "#F18 config", "#end of config" )
      log_write( "Ne mogu snimiti ini fajl "  + cIniFile )
      RETURN .F.
   ENDIF

   RETURN .T.
