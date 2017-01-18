#include "f18.ch"

#ifdef __PLATFORM__UNIX
#define INI_FNAME "f18_config.ini"
#else
#define INI_FNAME ".f18_config.ini"
#endif

FUNCTION f18_ini_config_read( sect, ini, global )

   LOCAL tmp_ini_section
   LOCAL tmp_key
   LOCAL ini_file
   LOCAL ini_read

   IF ( global == NIL ) .OR. ( global == .F. )
      ini_file := my_home() + INI_FNAME
   ELSE
      ini_file := my_home_root() + INI_FNAME
   ENDIF

   IF !File( ini_file )
      error_bar( "ini", "ini ne postoji: " + ini_file )
      RETURN .F.
   ELSE
      ini_read := hb_iniRead( ini_file )
   ENDIF


   IF Empty( ini_read )
      log_write( "Fajl je prazan: " + ini_file )

   ELSE
      IF hb_HHasKey( ini_read, sect )

         tmp_ini_section := ini_read[ sect ]
         FOR EACH tmp_key in ini:Keys
            // napuni ini sa onim sto si procitao
            IF hb_HHasKey( tmp_ini_section, tmp_key )
               ini[ tmp_key ] := tmp_ini_section[ tmp_key ]
            ENDIF
         NEXT

      ENDIF
   ENDIF

   RETURN .T.


FUNCTION f18_ini_config_write( sect, ini, global )

   LOCAL tmp_key
   LOCAL ini_file
   LOCAL ini_read

   IF ( global == NIL ) .OR. ( global == .F. )
      ini_file := my_home() + INI_FNAME
   ELSE
      ini_file := my_home_root() + INI_FNAME
   ENDIF

   ini_read := hb_iniRead( ini_file )

   IF Empty( ini_read )
      ini_read := hb_Hash()
   ENDIF

   IF !hb_HHasKey( ini_read, sect )
      ini_read[ sect ] := hb_Hash()
   ENDIF

   // napuni ini_read sa vrijednostima iz ini matrice
   FOR EACH tmp_key in ini:Keys
      ini_read[ sect ][ tmp_key ] := ini[ tmp_key ]
   NEXT


   IF !hb_iniWrite( ini_file, ini_read, "#F18 config", "#end of config" )
      log_write( "Ne mogu snimiti ini fajl "  + ini_file )
      RETURN .F.
   ENDIF

   RETURN .T.
