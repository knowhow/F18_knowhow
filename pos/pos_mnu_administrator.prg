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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

function pos_main_menu_admin()
local nSetPosPM
private opc := {}
private opcexe:={}
private Izbor:=1

ImportDSql()

AADD(opc, "1. izvjestaji                       ")
AADD(opcexe, {|| Izvj() })
AADD(opc, "2. pregled racuna")   
AADD(opcexe, {|| PromjeniID() })
AADD(opc, "L. lista azuriranih dokumenata")
AADD(opcexe, {|| PrepisDok()})
AADD(opc, "R. robno-materijalno poslovanje")
AADD(opcexe, {|| MenuRobMat() })
AADD(opc, "V. evidencija prometa po vrstama")
AADD(opcexe, {|| FrmPromVp()})    
AADD(opc, "K. prenos realizacije u KALK")
AADD(opcexe, {|| Real2Kalk() })
if IsPlanika()
	AADD(opc, "O. prenos reklamacija u KALK")
	AADD(opcexe, {|| Rek2Kalk() })
endif
AADD(opc, "S. sifrarnici                  ")
AADD(opcexe, {|| MenuSifre() })
AADD(opc, "P. prenos POS <-> POS")
AADD(opcexe, {|| PosDiskete() })
AADD(opc, "A. administracija pos-a")
AADD(opcexe, {|| pos_admin_menu() })

if gVSmjene=="D"
	AADD(opc, "Z. zakljuci radnika")
	AADD(opcexe, {|| Zakljuci() })
	AADD(opc, "O. otvori narednu smjenu")
	AADD(opcexe, {|| OdrediSmjenu() })
endif

if gVrstaRS == "S"
	AADD(opc, "X. preuzmi podatke sa kasa")
	AADD(opcexe, {|| PrebSaKase() })
	AADD(opc, "Y. ponovo prenesi sa kasa ")
	AADD(opcexe, {|| PobPaPren() })
endif

if IsPlanika()
	AADD(opc, "M. poruke")
	AADD(opcexe, {|| Mnu_Poruke()})
endif

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
PrikStatus()
return



function pos_admin_menu()
private opc:={}
private opcexe:={}
private Izbor:=1


AADD(opc,"1. parametri rada programa                        ")
AADD(opcexe, {|| pos_parametri() })

AADD(opc,"2. instalacija db-a")
AADD(opcexe,{|| goModul:oDatabase:install()})

AADD(opc, "3. generisi doks iz POS ")    
AADD(opcexe, {|| pos_generisi_doks_iz_pos() })

AADD(opc, "4. brisi duple sifre")
AADD(opcexe, {|| BrisiDupleSifre()})

AADD(opc, "5. uzmi BARKOD iz sezone ")
AADD(opcexe, {|| UzmiBkIzSez()})

AADD(opc, "6. set pdv cijene na osnovu tarifa iz sezone ")
AADD(opcexe, {|| SetPdvCijene()})

if gStolovi == "D"
	AADD(opc, "7. zakljucivanje postojecih racuna ")
	AADD(opcexe, {|| zak_sve_stolove()})
endif

if gSQL=="D"
	AADD(opc,"Q. sql logovi")
        AADD(opcexe,{|| MenuSQLLogs() })
endif

if gPosModem=="D"
    	AADD(opc,"D. dialup/modem")
	AADD(opcexe, {|| pos_menu_modem() })
endif


if KLevel<L_UPRAVN
	AADD(opc,"T. programiranje tastature ")
	AADD(opcexe,{|| ProgKeyboard() } )
endif

if gSQL=="D"
	AADD(opc,"#. bug - zakrpe")
	AADD(opcexe, {|| Zakrpe() })
	AADD(opc,"I. INTEG testovi")
	AADD(opcexe, {|| Mnu_Integ() })
endif

if (KLevel<L_UPRAVN)
	AADD(opc, "---------------------------")
	AADD(opcexe, nil)
	AADD(opc, "P. prodajno mjesto: "+gIdPos)
	nPosSetPM:=LEN(opc)
	AADD(opcexe, { || SetPm (nPosSetPM) })
endif

AADD(opc, "T. testcase OID ")
AADD(opcexe, { || PlFlexTCases() })

Menu_SC("aadm")
return .f.


