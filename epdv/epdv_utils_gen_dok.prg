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


#include "epdv.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

// -------------------------------------------
// sezonski direktorij
// -------------------------------------------
function sez_fill(cSezona)
local cRet := ""
if !EMPTY(cSezona)
	cRet := cSezona + "\"
endif
return cRet


// ----------------------------------
// ----------------------------------
function g_src_modul(cSrc, lShow)
local cPom := ""

// 1 - FIN
// 2 - KALK
// 3 - FAKT
// 4 - OS
// 5 - SII
// 6 - TOPS

if lShow == nil
	lShow := .f.
endif

do case
	case cSrc == "1"
		cPom := "FIN"
	case cSrc == "2"
		cPom := "KALK"
	case cSrc == "3"
		cPom := "FAKT"
	case cSrc == "4"
		cPom := "OS"
	case cSrc == "5"
		cPom := "SII"
	case cSrc == "6"
		cPom := "TOPS"

	otherwise
		if lShow
			MsgBeep("odaberite: 1-FIN, 2-KALK,#" + ;
			   "3-FAKT, 4-OS, 5-SII, 6-TOPS")
		endif
endcase

if lShow
	MsgBeep("Source = " + cPom)
endif

return cPom

// ---------------------------------
// ---------------------------------
function g_kat_p(cKat, lShow)
local cPom := ""

if lShow == nil
	lShow := .f.
endif

// kategorija partnera
// 1-pdv obveznik
// 2-ne pdv obvezink
// 3-ino partner

do case
	case cKat == "1"
		cPom := "PDV Obveznik"
	case cKat == "2"
		cPom := "Ne-PDV obvezik"
	case cKat == "3"
		cPom := "Ino partner"
	otherwise
		cPom := "Sve kategorije"
endcase
if lShow
	MsgBeep("Partner kat. = " + cPom)
endif


return cPom

// ----------------------------------
// ----------------------------------
function g_kat_p_2(cKat, lShow)
local cPom

cPom := ""

if lShow == nil
	lShow := .f.
endif

do case
	case cKat == "1"
		cPom := "Federacija"
	case cKat == "2"
		cPom := "Republika Srpska"
	case cKat == "3"
		cPom := "Distrikt Brcko"
	otherwise
		cPom := "Sve kategorije"

endcase

if lShow
	MsgBeep("Partner kat.2 = " + cPom)
endif

return cPom

