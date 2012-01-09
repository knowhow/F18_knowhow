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
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. stampa azuriranog dokumenta              ")
AADD(opcexe, {|| fakt_stampa_azuriranog()})
AADD(opc,"2. pregled liste dokumenata")
AADD(opcexe, {|| fakt_pregled_liste_dokumenata()})
AADD(opc,"3. stampa dokumenata od broja do broja      ")
AADD(opcexe, {|| fakt_stampa_azuriranog_period()})
AADD(opc,"4. stampa narudzbenice")
AADD(opcexe,{|| Mnu_Narudzba()})

if IsUgovori()
	AADD(opc,"U. stampa fakt.na osnovu ugovora od-do")
	AADD(opcexe, {|| ug_za_period()})
endif

// ako koristimo fiskalne funkcije
if gFc_use == "D"
	AADD(opc,"F. stampa fiskalnih racuna od-do")
	AADD(opcexe, {|| st_fisc_per()})
endif

Menu_SC("stfak")

CLOSERET

return .f.

/*! \fn fakt_ostale_operacije_doks()
 *  \brief Ostale operacije nad podacima
 */
 
function fakt_ostale_operacije_doks()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. povrat dokumenta u pripremu       ")
AADD(opcexe,{|| Povrat_fakt_dokumenta()})
AADD(opc,"2. povrat dokumenata prema kriteriju ")
AADD(opcexe,{|| if(SigmaSif(), Povrat_fakt_po_kriteriju(), nil)})
AADD(opc,"3. prekid rezervacije")
AADD(opcexe,{|| Povrat_fakt_dokumenta(.t.)})

Menu_SC("ostop")
return .f.
*}
