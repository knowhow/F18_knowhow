#include "f18.ch"

FUNCTION o_doks_pf()

   SELECT ( F_DOKSPF )
   my_use ( "dokspf" )
   SET ORDER TO TAG "1"

   RETURN .T.
