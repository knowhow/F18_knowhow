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


#include "kadev.ch"



CLASS TKadevMod FROM TAppMod
	method New
	method setGVars
	method mMenu
	method mMenuStandard
END CLASS

// -----------------------------------------------
// -----------------------------------------------
method new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
::super:new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
return self




// -----------------------------------------------
// -----------------------------------------------
method mMenu()
private Izbor
private lPodBugom
public gSQL := "N"

set_hot_keys()

Izbor:=1

@ 1,2 SAY PADC( gTS + ": " + gNFirma, 50, "*" )
@ 4,5 SAY ""

::mMenuStandard()

return nil



// ----------------------------------------
// ----------------------------------------
method mMenuStandard
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. podaci                                 ")
AADD( _opcexe, {|| kadev_data() })
AADD( _opc, "2. pretrazivanje" )
AADD( _opcexe, {|| kadev_search() })
AADD( _opc, "3. rekalkulacija" )
AADD( _opcexe, {|| kadev_recalc() })
AADD( _opc, "4. izvjestaji")
AADD( _opcexe, {|| kadev_rpt_menu() })
AADD( _opc, "5. obrasci")
AADD( _opcexe, {|| kadev_form() })
AADD( _opc, "6. radna karta")
AADD( _opcexe, {|| kadev_work_card() })
AADD( _opc, "------------------------------------")
AADD( _opcexe, {|| nil })
AADD( _opc, "S. sifrarnici" )
AADD( _opcexe, {|| kadev_sifre_menu() })
AADD( _opc, "------------------------------------")
AADD( _opcexe, {|| nil })
AADD( _opc, "X. parametri" )
AADD( _opcexe, {|| kadev_params_menu() } )

f18_menu( "kadev", .t., _izbor, _opc, _opcexe )

return


// ----------------------------------------
// ----------------------------------------
method setGVars()
kadev_set_global_vars()
return




function kadev_set_global_vars()

set_global_vars()

public glBezVoj := .t.
public gVojEvid := "N"
// bez vojne evidencije
public gnLMarg := 1
// lijeva margina
public gnTMarg := 1
// top-gornja margina teksta
public gTabela := 1
// fino crtanje tabele
public gA43 := "4"
// format papira
public gnRedova := 64
// za ostranicavanje - broj redova po stranici
public gOstr := "D"
// ostranicavanje
public gPostotak := "D"
// prikaz procenta uradjenog posla (znacajno kod
// dugih cekanja na izvrsenje opcije)
public gDodKar1 := "Karakteristika 1"
public gDodKar2 := "Karakteristika 2"
public gTrPromjena := "KP"
public gCentOn := "N"

kadev_read_params()

if gVojEvid == "D"
	glBezVoj := .f.
endif

if gCentOn == "D"
	SET CENTURY ON
else
  	SET CENTURY OFF
endif

return
