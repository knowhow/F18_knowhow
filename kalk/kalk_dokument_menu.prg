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


#include "kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */

/*! \file fmk/kalk/dok/1g/mnu_dok.prg
 *  \brief Meni opcija za stampu i pregled dokumenata
 */

/*! \fn mBrDoks()
 *  \brief Meni opcija za stampu i pregled dokumenata
 */

function mBrDoks()
*{
PRIVATE opc:={}
PRIVATE opcexe:={}

AADD(opc,"1. stampa azuriranog dokumenta              ")
AADD(opcexe, {|| Stkalk(.t.)})
AADD(opc,"2. stampa liste dokumenata")
AADD(opcexe, {|| StDoks()})
AADD(opc,"3. pregled dokumenata po hronologiji obrade")
AADD(opcexe, {|| BrowseHron()})
AADD(opc,"4. pregled dokumenata - tabelarni pregled")
AADD(opcexe, {|| browse_dok()})
AADD(opc,"5. radni nalozi ")
AADD(opcexe, {|| BrowseRn()})
AADD(opc,"6. analiza kartica ")
AADD(opcexe, {|| AnaKart()})
AADD(opc,"7. stampa OLPP-a za azurirani dokument")
AADD(opcexe, {|| StOLPPAz()})

private Izbor:=1
Menu_SC("razp")
CLOSERET
return
*}

/*! \fn MAzurDoks()
 *  \brief Meni - opcija za povrat azuriranog dokumenta
 */

function MAzurDoks()
*{
private Opc:={}
private opcexe:={}
AADD(opc,"1. povrat dokumenta u pripremu")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
	AADD(opcexe, {|| Povrat()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

IF IsPlanika()
	AADD(opc,"2. generacija tabele prodnc")
	if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENPRODNC"))
		AADD(opcexe, {|| GenProdNc()})
	else
		AADD(opcexe, {|| MsgBeep(cZabrana)})
	endif

	AADD(opc,"3. Set roba.idPartner")
	if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","SETIDPARTN"))
		AADD(opcexe, {|| SetIdPartnerRoba()})
	else
		AADD(opcexe, {|| MsgBeep(cZabrana)})
	endif
endif

AADD(opc,"4. pregled smeca ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","SMECEPREGLED"))
	AADD(opcexe, {|| Pripr9View()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif



private Izbor:=1
Menu_SC("mazd")
CLOSERET
return
*}

