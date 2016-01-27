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


#include "f18.ch"


// -------------------------------------------
// -------------------------------------------
function epdv_admin_menu()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. install db-a                         ")
AADD(opcexe, {|| goModul:oDatabase:install()})
AADD(opc, "3. renumeracija g_r_br KUF")
AADD(opcexe, {|| rn_gr("KUF")})
AADD(opc, "4. renumeracija g_r_br KIF")
AADD(opcexe, {|| rn_gr("KIF")})

Menu_SC("adm")

return
*}

// ---------------------------------
// ---------------------------------
static function rn_gr(cTblName)

if Pitanje(,"Izvrsiti renumeriranje ? " + cTblName, "N") == "D"
  if SigmaSif("RNGR")
  	rn_g_r_br(cTblName)
  else
  	MsgBeep("Pogresna lozinka, nista od posla ...")
  endif
endif

return
