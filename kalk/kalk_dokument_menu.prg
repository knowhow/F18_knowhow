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


function kalk_pregled_dokumenata()
local _opc:={}
local _opcexe:={}
local _izbor := 1

AADD(_opc,"1. stampa azuriranog dokumenta              ")
AADD(_opcexe, {|| kalk_centr_stampa_dokumenta(.t.)})
AADD(_opc,"2. stampa liste dokumenata")
AADD(_opcexe, {|| StDoks()})
AADD(_opc,"3. pregled dokumenata po hronologiji obrade")
AADD(_opcexe, {|| BrowseHron()})
AADD(_opc,"4. pregled dokumenata - tabelarni pregled")
AADD(_opcexe, {|| browse_kalk_dok()})
AADD(_opc,"5. radni nalozi ")
AADD(_opcexe, {|| BrowseRn()})
AADD(_opc,"6. analiza kartica ")
AADD(_opcexe, {|| AnaKart()})
AADD(_opc,"7. stampa OLPP-a za azurirani dokument")
AADD(_opcexe, {|| StOLPPAz()})
AADD(_opc,"8. kalkulacija cijena")
AADD(_opcexe, {|| kalkulacija_cijena() })

f18_menu( "razp", .f., _izbor, _opc, _opcexe )

close all
return


function kalk_ostale_operacije_doks()
local _opc:={}
local _opcexe:={}
local _izbor := 1

AADD(_opc,"1. povrat dokumenta u pripremu")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
    AADD(_opcexe, {|| Povrat_kalk_dokumenta()})
else
    AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif

IF IsPlanika()
    AADD(_opc,"2. generacija tabele prodnc")
    if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENPRODNC"))
        AADD(_opcexe, {|| GenProdNc()})
    else
        AADD(_opcexe, {|| MsgBeep(cZabrana)})
    endif

    AADD(_opc,"3. Set roba.idPartner")
    if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","SETIDPARTN"))
        AADD(_opcexe, {|| SetIdPartnerRoba()})
    else
        AADD(_opcexe, {|| MsgBeep(cZabrana)})
    endif
endif

AADD(_opc,"4. pregled smeca ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","SMECEPREGLED"))
    AADD(_opcexe, {|| Pripr9View()})
else
    AADD(_opcexe, {|| MsgBeep(cZabrana)})
endif


f18_menu( "mazd", .f., _izbor, _opc, _opcexe )

close all
return

