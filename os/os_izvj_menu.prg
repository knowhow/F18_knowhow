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


function os_izvjestaji()
local _izbor := 1
local _opc := {}
local _opcexe := {}

cTip := IF( gDrugaVal == "D", ValDomaca(), "" )
cBBV := cTip
nBBK := 1

AADD(_opc, "1. pregled sredstava za rj                          ")
AADD(_opcexe, {|| os_pregled_po_rj()})
AADD(_opc, "2. pregled sredstava po kontima")
AADD(_opcexe, {|| os_pregled_po_kontima()})
AADD(_opc, "3. amortizacija po kontima")
AADD(_opcexe, {|| os_pregled_amortizacije() } )
AADD(_opc, "4. revalorizacija po kontima")
AADD(_opcexe, {|| os_pregled_revalorizacije()})
AADD(_opc, "5. rekapitulacija kolicina po grupacijama - k1")
AADD(_opcexe, {|| os_rekapitulacija_po_k1()})
AADD(_opc, "6. amortizacija po grupama amortizacionih stopa")
AADD(_opcexe, {|| os_amortizacija_po_stopama()})
AADD(_opc, "7. amortizacija po kontima i po grupama amort.stopa")
AADD(_opcexe, {|| os_amortizacija_po_kontima()})

AADD(_opc, "8. popisna lista")
AADD(_opcexe, {|| os_popisna_lista() } )

f18_menu( "izv", .f., _izbor, _opc, _opcexe )

return


