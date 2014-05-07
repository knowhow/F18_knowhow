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


#include "rnal.ch"


function m_sif()
local opc:={}
local opcexe:={}
local Izbor:=1

rnal_o_sif_tables()

AADD(opc, "1. narucioci                      ")
AADD(opcexe, {|| s_customers() })
AADD(opc, "2. kontakti")
AADD(opcexe, {|| s_contacts() })
AADD(opc, "3. objekti")
AADD(opcexe, {|| s_objects() })
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "5. artikli")
AADD(opcexe, {|| s_articles() })
AADD(opc, "6. elementi, grupe ")
AADD(opcexe, {|| s_e_groups() })
AADD(opc, "7. elementi atributi grupe")
AADD(opcexe, {|| s_e_gr_val() })
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "8. dodatne operacije")
AADD(opcexe, {|| s_aops() })
AADD(opc, "9. dodatne operacije, atributi")
AADD(opcexe, {|| s_aops_att() })
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "10. export, relacije")
AADD(opcexe, {|| p_relation() })
AADD(opc, "11. RAL definicije")
AADD(opcexe, {|| sif_ral() })

Izbor := 1

f18_menu("m_sif", .F., izbor, opc, opcexe )

return



