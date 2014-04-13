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

#include "fmk.ch"


FUNCTION print_radni_nalog( cIdFirma, cIdTipDok, cBrDok )

   PushWa()
   close_open_fakt_tabele()
   StampTXT( cIdFirma, cIdTipdok, cBrDok, .T. )

   rnal_print( .T. )
   SELECT ( F_FAKT_DOKS )
   USE

   O_PARTN
   O_FAKT_DOKS

   PopWa()

   RETURN NIL

