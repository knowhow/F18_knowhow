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


#include "ld.ch"


function ld_parametri()
local _opc := {}
local _opcexe := {}
local _izbor := 1

O_LD_RJ
O_PARAMS

private cSection:="1"
private cHistory:=" "
private aHistory:={}

AADD(_opc, "1. osnovni podaci organizacione jedinice                        ")
AADD(_opcexe, {|| org_params() })
AADD(_opc, "2. RJ, mjesec, godina...         ")
AADD(_opcexe, {|| ld_set_firma()})
AADD(_opc, "3. postavka zaokruzenja, valute, formata prikaza iznosa...  ")
AADD(_opcexe, {|| ld_set_forma()})
AADD(_opc, "4. postavka nacina obracuna ")
AADD(_opcexe, {|| ld_set_obracun()})
AADD(_opc, "5. postavka formula (uk.prim.,uk.sati,godisnji) i koeficijenata ")
AADD(_opcexe, {|| ld_set_formule()})
AADD(_opc, "6. postavka parametara izgleda dokumenata ")
AADD(_opcexe, {|| ld_set_prikaz()})

f18_menu( "par", .f., _izbor, _opc, _opcexe )

return


