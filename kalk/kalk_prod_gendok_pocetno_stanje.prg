/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"

FUNCTION PocStProd()

   lager_lista_prodavnica( .T. )
   IF !Empty( goModul:oDataBase:cSezonDir ) .AND. Pitanje(, "Prebaciti dokument u radno područje", "D" ) == "D"
      O_KALK_PRIPRRP
      O_KALK_PRIPR
      IF reccount2() <> 0
         SELECT kalk_priprrp
         APPEND FROM kalk_pripr
         SELECT kalk_pripr
         my_dbf_zap()
         my_close_all_dbf()
      ENDIF
   ENDIF
   my_close_all_dbf()

   RETURN NIL
