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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/gendok/1g/mnu_gdok.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.4 $
 * $Log: mnu_gdok.prg,v $
 * Revision 1.4  2003/01/03 14:07:00  sasa
 * ispravka pocetnog stanja
 *
 * Revision 1.3  2002/09/28 15:49:48  mirsad
 * prenos pocetnog stanja za evid.uplata dovrsen
 *
 * Revision 1.2  2002/09/26 12:47:05  mirsad
 * no message
 *
 * Revision 1.1  2002/07/03 12:22:48  sasa
 * uvodnjenje novog prg fajla
 *
 * Revision 
 * 
 *
 *
 */
 

/*! \file fmk/fakt/gendok/1g/mnu_gdok.prg
 *  \brief Meni opcija za generisanje dokumenata za modul FAKT
 */

/*! \fn MGenDoks()
 *  \brief Meni opcija za generisanje dokumenata za modul FAKT
 */

function MGenDoks()
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
Lager(.t.)
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


