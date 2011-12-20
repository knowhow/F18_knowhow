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


#include "epdv.ch"

// ------------------------------
// ------------------------------
function epdv_sifrarnici()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. partneri               ")
AADD(opcexe, {|| p_partneri()})
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "5. sheme generacije kuf")
AADD(opcexe, {|| p_sg_kuf()})
AADD(opc, "6. sheme generacije kif")
AADD(opcexe, {|| p_sg_kif()})

AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "8. tarife")
AADD(opcexe, {|| P_Tarifa()})

AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "S. sifk")
AADD(opcexe, {|| P_SifK()})


Menu_SC("sif")

return



