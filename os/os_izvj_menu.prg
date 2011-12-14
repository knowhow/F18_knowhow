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


#include "os.ch"


function os_izvjestaji()
private Izbor:=1
private opc:={}
private opcexe:={}

cTip:=IF(gDrugaVal=="D",ValDomaca(),"")
cBBV:=cTip; nBBK:=1

AADD(opc, "1. pregled sredstava za rj                          ")
AADD(opcexe, {|| os_pregled_po_rj()})
AADD(opc, "2. pregled sredstava po kontima")
AADD(opcexe, {|| os_pregled_po_kontima()})
AADD(opc, "3. amortizacija po kontima")
AADD(opcexe, {|| os_pregled_amortizacije() } )
AADD(opc, "4. revalorizacija po kontima")
AADD(opcexe, {|| os_pregled_revalorizacije()})
AADD(opc, "5. rekapitulacija kolicina po grupacijama - k1")
AADD(opcexe, {|| os_rekapitulacija_po_k1()})
AADD(opc, "6. amortizacija po grupama amortizacionih stopa")
AADD(opcexe, {|| os_amortizacija_po_stopama()})
AADD(opc, "7. amortizacija po kontima i po grupama amort.stopa")
AADD(opcexe, {|| os_amortizacija_po_kontima()})
AADD(opc, "8. kartica sredstva")
AADD(opcexe, {|| os_kartica_sredstva()})
AADD(opc, "9. lista sredstava uvedenih u tekucoj godini")
AADD(opcexe, {|| NovaSredstva()})
AADD(opc, "A. lista sredstava izbrisanih u tekucoj godini")
AADD(opcexe, {|| IzbrisanaSredstva()})


Menu_SC("izv")

return
