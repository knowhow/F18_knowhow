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


#include "hbclass.ch"


// -----------------------------------------------
// -----------------------------------------------
CLASS TReportsMod FROM TAppMod
	method New
    method setGVars
    method initDb
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
method initdb()
::oDatabase := TDbReports():new()
return nil


// -----------------------------------------------
// -----------------------------------------------
method mMenu()

close all

@ 1,2 SAY padc( gNFirma, 50, "*")
@ 4,5 SAY ""

::mMenuStandard()

return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenuStandard()
private izbor := 1
private opc := {}
private opcexe := {}

AADD( opc, "1. finansijski izvještaji                                  ")
AADD( opcexe, {|| fin_suban_izvjestaji() })
AADD( opc, "2. robni izvjestaji      ")
AADD( opcexe, {|| NIL })


Menu_SC( "grep", .t., .f. )

return



// ---------------------------------------------
// ---------------------------------------------
method setGVars()

set_global_vars()
set_roba_global_vars()

public gModul
public gTema
public gGlBaza

gModul := "REPORTS"
gTema := "OSN_MENI"
gGlBaza := ""

public cZabrana := "Opcija nedostupna za ovaj nivo !!!"

return
