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


// ------------------------------
// meni sifranika
// ------------------------------
function m_sif()
private opc:={}
private opcexe:={}
private Izbor:=1

gTBDir := "N"

o_sif_tables()

AADD(opc, "1. narucioci                      ")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "CUSTOMERS")
	AADD(opcexe, {|| s_customers() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "2. kontakti")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "CONTACTS")
	AADD(opcexe, {|| s_contacts() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "3. objekti")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "OBJECTS")
	AADD(opcexe, {|| s_objects() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "5. artikli")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "ARTICLES")
	AADD(opcexe, {|| s_articles() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "6. elementi, grupe ")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "E_GROUPS")
	AADD(opcexe, {|| s_e_groups() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "7. elementi atributi grupe")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "E_GR_ATT")
	AADD(opcexe, {|| s_e_gr_val() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "8. dodatne operacije")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "AOPS")
	AADD(opcexe, {|| s_aops() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "9. dodatne operacije, atributi")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "AOPS_ATT")
	AADD(opcexe, {|| s_aops_att() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "10. export, relacije")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "RELATION")
	AADD(opcexe, {|| p_relation() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif

AADD(opc, "11. RAL definicije")
if ImaPravoPristupa(goModul:oDataBase:cName, "SIF", "RAL")
	AADD(opcexe, {|| sif_ral() })
else
	AADD(opcexe, {|| msgbeep( cZabrana ) })
endif


Izbor := 1

Menu_SC("m_sif")

return



