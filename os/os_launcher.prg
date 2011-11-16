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

#include "os.ch"

EXTERNAL DESCEND
EXTERNAL RIGHT


function MainOs(cKorisn, cSifra, p3, p4, p5, p6, p7)
local oOs
local cModul

PUBLIC gKonvertPath:="D"

cModul:="OS"
PUBLIC goModul

oOs := TOsMod():new(NIL, cModul, D_OS_VERZIJA, D_OS_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)
goModul:=oOs

oOs:run()

return

