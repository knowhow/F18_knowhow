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


#include "fakt.ch"


function fakt_mnu_generacija_dokumenta()
*{
private Opc:={}
private opcexe:={}

AADD(opc,"1. pocetno stanje                    ")
AADD(opcexe, {|| GPStanje()})
AADD(opc,"2. dokument inventure     ")
AADD(opcexe, {|| FaUnosInv()})

private Izbor:=1
Menu_SC("mgdok")
CLOSERET
return
*}


/*! \fn GPStanje()
 *  \brief Generisanje dokumenta pocetnog stanja
 */
 
function GPStanje()
*{
local gSezonDir
fakt_lager_lista(.t.)
if !EMPTY(goModul:oDataBase:cSezonDir) .and. Pitanje(,"Prebaciti dokument u radno podrucje","D")=="D"
	O_FAKT_PRIPRRP
        O_FAKT_PRIPR
        select fakt_priprrp
        APPEND FROM pripr
        select fakt_pripr
	ZAP
        close all
	GPSUplata()
	if Pitanje(,"Prebaciti se na rad sa radnim podrucjem ?","D")=="D"
        	URadPodr()
        endif
endif
close all
return
*}


