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


#include "pos.ch"



function pos_main_menu_upravnik()

if gVrstaRS=="A"                          
	MMenuUpA()
elseif gVrstaRS=="K"
	MMenuUpK()
else
	MMenuUpS()
endif
return



function MMenuUpA()
private opc:={}
private opcexe:={}
private Izbor:=1

// Vrsta kase "A" - samostalna kasa

AADD(opc, "1. izvjestaji                        ")
AADD(opcexe, {|| pos_izvjestaji() })    
AADD(opc,"L. lista azuriranih dokumenata")
AADD(opcexe, {|| pos_prepis_dokumenta()})

AADD(opc, "V. evidencija prometa po vrstama")
AADD(opcexe, {|| FrmPromVp()})    

AADD(opc, "R. prenos realizacije u KALK")
AADD(opcexe, {|| pos_prenos_pos_kalk() })

AADD(opc, "D. unos dokumenata")
AADD(opcexe, {|| pos_menu_dokumenti()})    

AADD(opc, "R. robno-materijalno poslovanje")
AADD(opcexe, {|| pos_menu_robmat() })

AADD(opc, "--------------")
AADD(opcexe, nil)
AADD(opc, "S. sifrarnici")
AADD(opcexe, {|| pos_sifrarnici() })
AADD(opc, "W. administracija pos-a")
AADD(opcexe, {|| pos_admin_menu() })
AADD(opc, "P. promjena seta cijena")
AADD(opcexe, {|| PromIDCijena()})

Menu_SC("upra")

closeret
return .f.



function MMenuUpK()
private opc:={}
private opcexe:={}
private Izbor:=1

// Vrsta kase "K" - radna stanica

AADD(opc, "1. izvjestaji             ")
AADD(opcexe,{|| pos_izvjestaji()})
AADD(opc, "--------------------------")
AADD(opcexe,nil)
AADD(opc, "S. sifrarnici")
AADD(opcexe,{|| pos_sifrarnici()})
AADD(opc, "A. administracija pos-a")
AADD(opcexe, {|| pos_admin_menu() })

Menu_SC("uprk")
return .f.



function MMenuUpS()
private opc:={}
private opcexe:={}
private Izbor:=1

// Vrsta kase "S" - server kasa

AADD(opc, "1. izvjestaji             ")
AADD(opcexe,{|| pos_izvjestaji()})
AADD(opc, "2. unos dokumenata")
AADD(opcexe,{|| pos_menu_dokumenti()})
AADD(opc, "S. sifrarnici")
AADD(opcexe,{|| pos_sifrarnici()})

Menu_SC("uprs")
closeret
return .f.


function pos_menu_dokumenti()
private Izbor
private opc:={}
private opcexe:={}

Izbor:=1

AADD(opc, "Z. zaduzenje                       ")
AADD(opcexe, {|| Zaduzenje() })
AADD(opc, "I. inventura")
AADD(opcexe, {|| InventNivel(.t.) })
AADD(opc, "N. nivelacija")
AADD(opcexe, {|| InventNivel(.f.)})
AADD(opc, "P. predispozicija")
AADD(opcexe, {|| Zaduzenje("PD") })
AADD(opc, "R. reklamacija-povrat u magacin")
AADD(opcexe, {|| Zaduzenje(VD_REK) })

Menu_SC("pzdo")

return



