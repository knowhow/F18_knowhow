#include "f18.ch"


STATIC s_cF18Verzija
STATIC s_cF18Varijanta
STATIC s_cF18VerzijaKanal

FUNCTION f18_verzija()

   IF s_cF18Verzija == NIL
      s_cF18Verzija := AllTrim( fetch_metric( "F18_verzija", NIL, F18_VERZIJA ) )
   ENDIF

   RETURN s_cF18Verzija

/*
   S - standard
   E - edge
   X - experiment
*/

FUNCTION f18_verzija_kanal()

   IF s_cF18VerzijaKanal == NIL
      s_cF18VerzijaKanal := AllTrim( fetch_metric( "F18_verzija_kanal", my_user(), "S" ) )
   ENDIF

   RETURN s_cF18VerzijaKanal



FUNCTION f18_varijanta()

   IF s_cF18Varijanta == NIL
      s_cF18Varijanta := AllTrim( fetch_metric( "F18_varijanta", NIL, F18_VARIJANTA ) )
   ENDIF

   RETURN s_cF18Varijanta


FUNCTION f18_varijanta_builtin()

   RETURN F18_VARIJANTA


/*
    za Verzija=3 => "https://raw.github.com/knowhow/F18_knowhow/3"
*/

FUNCTION f18_download_url()

   RETURN F18_DOWNLOAD_BASE_URL + "/" + f18_verzija() + "-" + f18_varijanta()


/*
   github/knowhow/F18_knowhow/branch/VERSION - stabilna Verzija
   github/knowhow/F18_knowhow/branch/VERSION_E - posljednja (edge) verzija
   github/knowhow/F18_knowhow/branch/VERSION_X - eXperimentalna verzija

*/

FUNCTION f18_version_file()

   LOCAL cFile := "VERSION"

   IF f18_verzija_kanal() $ "E X"
      cFile := cFile + "_" + f18_verzija_kanal()
   ENDIF

   RETURN cFile
