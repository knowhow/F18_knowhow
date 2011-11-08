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


#include "kalk.ch"

 
function KaSifPlanika()
private opc:={}
private opcexe:={}
private Izbor

O_K1
O_OBJEKTI
O_RVRSTA

AADD(opc,"1. k1 - grupe dobavljaca            ")
AADD(opcexe, {|| P_K1()})
AADD(opc,"2. objekti (prodavnice i magacini")
AADD(opcexe, {|| P_Objekti()})
AADD(opc,"3. planika vrste artikala")
AADD(opcexe, {|| P_RVrsta()})
AADD(opc,"4. popuni planika - polje vrsta")
AADD(opcexe, {|| PlFill_Vrsta()})
AADD(opc,"5. popuni planika - polje sezona")
AADD(opcexe, {|| PlFill_Sezona()})

Izbor:=1
Menu_SC("spla")

return




