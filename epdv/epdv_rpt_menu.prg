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
function epdv_izvjestaji()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. kuf lista dokumenata ")
AADD(opcexe, {|| r_lista("KUF")})
AADD(opc, "2. kuf")
AADD(opcexe, {|| rpt_kuf()})

AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})


AADD(opc, "3. kif lista dokumenata ")
AADD(opcexe, {|| r_lista("KIF")})
AADD(opc, "4. kif")
AADD(opcexe, {|| rpt_kif()})

AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "5. prijava pdv-a")
AADD(opcexe, {|| rpt_p_pdv()})

AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})


Menu_SC("rpt")

return


