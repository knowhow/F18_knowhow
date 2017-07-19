#include "f18.ch"


STATIC s_cF18Verzija
STATIC s_cF18Varijanta

FUNCTION f18_verzija()

   IF s_cF18Verzija == NIL
      s_cF18Verzija := AllTrim( fetch_metric( "F18_verzija", NIL, F18_VERZIJA ) )
   ENDIF

   RETURN s_cF18Verzija



FUNCTION f18_varijanta()

   IF s_cF18Varijanta == NIL
      s_cF18Varijanta := AllTrim( fetch_metric( "F18_varijanta", NIL, F18_VARIJANTA ) )
   ENDIF

   RETURN s_cF18Varijanta


/*
    za Verzija=3 => "https://raw.github.com/knowhow/F18_knowhow/3"
*/

FUNCTION f18_download_url()

   RETURN F18_DOWNLOAD_BASE_URL + "/" + f18_verzija() + "-" + f18_varijanta()
