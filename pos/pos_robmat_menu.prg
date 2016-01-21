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
#include "setcurs.ch"

// --------------------------------------------
// menij robno-materijalno poslovanje
// --------------------------------------------
function pos_menu_robmat()
private Opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. unos dokumenata        ")
AADD(opcexe, {|| pos_menu_dokumenti() })
AADD(opc, "2. generacija dokumenata")
AADD(opcexe, {|| pos_menu_gendok() })

Menu_SC("mrbm")
return



// --------------------------------------------
// menij generacije dokumenata
// --------------------------------------------
function pos_menu_gendok()
private Opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. generacija dokumenta pocetnog stanja     ")
AADD(opcexe, {|| p_poc_stanje() })
AADD(opc, "2. import sifrarnika ROBA iz fmk-tops     ")
AADD(opcexe, {|| pos_import_fmk_roba() })


Izbor:=1
Menu_SC("gdok")

return



