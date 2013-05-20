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

// ----------------------------------------
// meni krediti
// ----------------------------------------
function ld_krediti()
local _izbor:=1
local _opc:={}
local _opcexe:={}
local _priv := f18_privgranted( "ld_obrada_kredita" )
local _priv_pr := f18_privgranted( "ld_pregled_podataka" )

AADD( _opc, "1. novi kredit                        ")
if _priv
	AADD( _opcexe, {|| NoviKredit()})
else
	AADD( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) })
endif

AADD( _opc, "2. pregled/ispravka kredita")
if _priv
	AADD( _opcexe, {|| EditKredit()})
else
	AADD( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) })
endif

AADD( _opc, "3. lista kredita za jednog kreditora")
if _priv_pr
    AADD( _opcexe, {|| ListaKredita()})
else
	AADD( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) })
endif

AADD( _opc, "4. brisanje kredita")
if _priv
	AADD( _opcexe, {|| BrisiKredit()})
else
	AADD( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) })
endif

AADD( _opc, "5. specifikacija kredita po kreditorima")
if _priv_pr
    AADD( _opcexe, {|| ld_kred_specifikacija() } )
else
	AADD( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) })
endif

f18_menu( "kred", .f., _izbor, _opc, _opcexe )

return




