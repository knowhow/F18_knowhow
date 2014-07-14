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


#include "pos.ch"


// --------------------------------------------------------
// pos : administrativni menij
// --------------------------------------------------------
function pos_main_menu_admin()
local nSetPosPM
private opc := {}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. izvjestaji                       ")
AADD(opcexe, {|| pos_izvjestaji() })
AADD(opc, "2. pregled racuna")   
AADD(opcexe, {|| pos_pregled_racuna_tabela() })
AADD(opc, "L. lista azuriranih dokumenata")
AADD(opcexe, {|| pos_prepis_dokumenta()})
AADD(opc, "R. robno-materijalno poslovanje")
AADD(opcexe, {|| pos_menu_robmat() })
AADD(opc, "K. prenos realizacije u KALK")
AADD(opcexe, {|| pos_prenos_pos_kalk() })
AADD(opc, "S. sifrarnici                  ")
AADD(opcexe, {|| pos_sifrarnici() })
AADD(opc, "A. administracija pos-a")
AADD(opcexe, {|| pos_admin_menu() })

Menu_SC("adm")


function SetPM(nPosSetPM)

local nLen

if gIdPos=="X "
	gIdPos:=gPrevIdPos
else
        gPrevIdPos:=gIdPos
        gIdPos:="X "
endif
nLen:=LEN(opc[nPosSetPM])
opc[nPosSetPM]:=Left(opc[nPosSetPM],nLen-2)+gIdPos
pos_status_traka()
return



function pos_admin_menu()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. parametri rada programa                        ")
AADD(opcexe, {|| pos_parametri() })

AADD(opc, "R. setovanje brojaca dokumenata")
AADD(opcexe, {|| pos_set_param_broj_dokumenta() })

if gStolovi == "D"
	AADD(opc, "7. zakljucivanje postojecih racuna ")
	AADD(opcexe, {|| zak_sve_stolove()})
endif

if ( KLevel < L_UPRAVN )
	
    AADD(opc, "---------------------------")
	AADD(opcexe, nil)
	
    AADD(opc, "P. prodajno mjesto: "+gIdPos)
	nPosSetPM:=LEN(opc)
	AADD(opcexe, { || SetPm (nPosSetPM) })

endif

Menu_SC("aadm")

return .f.


