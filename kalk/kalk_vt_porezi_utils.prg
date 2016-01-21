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



FUNCTION VtPorezi()

   PUBLIC _PDV := tarifa->opp / 100
   PUBLIC _OPP := tarifa->opp / 100
   PUBLIC _PP := 0
   PUBLIC _ZPP := 0
   PUBLIC _PPP := 0
   PUBLIC _ZPP := 0
   PUBLIC _PORVT := 0
   PUBLIC _MPP   := 0
   PUBLIC _DLRUC := 0

   RETURN

