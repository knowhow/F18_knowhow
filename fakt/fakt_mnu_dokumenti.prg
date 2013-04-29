/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fakt.ch"

// ---------------------------------
// ---------------------------------
function fakt_pregled_dokumenata()
local _opc:={}
local _opcexe:={}
local _izbor:=1

AADD(_opc,"1. stampa azuriranog dokumenta                               ")
AADD(_opcexe, {|| fakt_stampa_azuriranog()})
AADD(_opc,"2. pregled liste dokumenata")
AADD(_opcexe, {|| fakt_pregled_liste_dokumenata()})
AADD(_opc,"3. stampa txt dokumenata od broja do broja      ")
AADD(_opcexe, {|| fakt_stampa_azuriranog_period()})
AADD(_opc,"4. stampa/export odt dokumenata po zadanom uslovu")
AADD(_opcexe, {|| stdokodt_grupno() })
AADD(_opc,"5. stampa narudzbenice")
AADD(_opcexe,{|| Mnu_Narudzba()})

if IsUgovori()
	AADD(_opc,"U. stampa fakt.na osnovu ugovora od-do")
	AADD(_opcexe, {|| ug_za_period()})
endif

// ako koristimo fiskalne funkcije
if fiscal_opt_active()
	AADD( _opc,"F. stampa fiskalnih racuna od-do" )
	AADD( _opcexe, {|| st_fisc_per()})
endif

f18_menu("stfak", .f., _izbor, _opc, _opcexe )

close all

return .f.

 
function fakt_ostale_operacije_doks()
local _opc:={}
local _opcexe:={}
local _izbor:=1

AADD(_opc,"1. povrat dokumenta u pripremu       ")
AADD(_opcexe,{|| Povrat_fakt_dokumenta()})

AADD(_opc,"2. povrat dokumenata prema kriteriju ")
AADD(_opcexe,{|| if(SigmaSif(), Povrat_fakt_po_kriteriju(), nil)})

AADD(_opc,"3. prekid rezervacije")
AADD(_opcexe,{|| Povrat_fakt_dokumenta(.t.)})

AADD( _opc, "A. administrativne opcije ")
AADD( _opcexe, { || fakt_admin_menu() } )

AADD(_opc,"B. podesenje brojaca dokumenta")
AADD(_opcexe,{|| fakt_set_param_broj_dokumenta()})

f18_menu("ostop", .f., _izbor, _opc, _opcexe )

return .f.

