/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "epdv.ch"


EXTERNAL DESCEND
EXTERNAL RIGHT


function MainEpdv(cKorisn, cSifra, p3, p4, p5, p6, p7)
local oEpdv
local cModul

PUBLIC gKonvertPath:="D"

cModul:="EPDV"
PUBLIC goModul

oEpdv := TEpdvMod():new(NIL, cModul, F18_VER, F18_VER_DATE, cKorisn, cSifra, p3, p4, p5, p6, p7)
goModul:=oEpdv

oEpdv:run()

return
