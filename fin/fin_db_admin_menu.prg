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

#include "fin.ch"

// ----------------------------------------------
// ----------------------------------------------
function MnuAdminDB()
private opc:={}
private opcexe:={}
private Izbor:=1


AADD(opc, "1. provjera integriteta tabela - ima u suban nema u nalog ")
AADD(opcexe, {|| ImaUSubanNemaUNalog()})

AADD(opc, "2. pregled datumskih gresaka u nalozima")
AADD(opcexe, {|| daterr_rpt() })

AADD(opc, "3. regeneracija broja naloga u kumulativu")
AADD(opcexe, {|| regen_tbl() })

AADD(opc, "4. kontrola podataka nakon importa iz FMK")
AADD(opcexe, {|| f18_test_data() })

AADD(opc, "------------------------------------------------------")
AADD(opcexe, {|| NIL })

AADD(opc, "B. podesenje brojaca naloga")
AADD(opcexe, {|| fin_set_param_broj_dokumenta() })

AADD(opc, "------------------------------------------------------")
AADD(opcexe, {|| NIL })
AADD(opc, "R. fmk pravila - rules ")
AADD(opcexe, {|| p_fmkrules(,,, aRuleCols, bRuleBlock ) })


Menu_SC("adm")

return

