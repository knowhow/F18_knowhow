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


#include "rnal.ch"
#include "hbclass.ch"
 

// -----------------------------------------------
// -----------------------------------------------
CLASS TRnalMod FROM TAppMod
	var oSqlLog
	method New
	method setGVars
	method mMenu
	method mStartUp
	method mMenuStandard
	method initdb
	method srv
END CLASS

// -----------------------------------------------
// -----------------------------------------------
method new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
::super:new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
return self


// -----------------------------------------------
// -----------------------------------------------
method initdb()
::oDatabase:=TDbRnal():new()
return nil


// -----------------------------------------------
// -----------------------------------------------
method mMenu()

// security mora biti aktivan
if gSecurity == "N"
	MsgBeep("Security nije aktivan!#Prekidam rad...")
	return
endif

close all

SETKEY(K_SH_F1,{|| Calc()})

CheckROnly(KUMPATH + SLASH + "DOCS.DBF")

O_DOCS
select docs 
use

close all

@ 1,2 SAY padc( gNFirma, 50, "*")
@ 4,5 SAY ""

rnal_set_params()

::mStartUp()
::mMenuStandard()

return nil


// ------------------------------------------
// startup metoda
// ------------------------------------------
method mStartUp()

if is_fmkrules()
	// generisi standarne rnal rules
	gen_rnal_rules()
endif

return nil



method mMenuStandard()

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. unos/dorada naloga za proizvodnju  ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKEDIT"))
	AADD(opcexe, {|| ed_document( .t. )})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


AADD(opc, "2. lista otvorenih naloga ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKLSTO"))
	AADD(opcexe, {|| frm_lst_docs(1)})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. lista zatorenih naloga ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKLSTZ"))
	AADD(opcexe, {|| frm_lst_docs(2)})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. izvjestaji ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DOKRPT"))
	AADD(opcexe, {|| m_rpt() })
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "D. direktna dorada naloga  ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "DIRDORAD"))
	AADD(opcexe, {|| ddor_nal()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "S. stampa azuriranog naloga  ")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "STNAL"))
	AADD(opcexe, {|| prn_nal()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "S. sifrarnici")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "SIF"))
	AADD(opcexe, {|| m_sif()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "9. administracija")
if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "ADMIN"))
	AADD(opcexe, {|| rnal_mnu_admin()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})


AADD(opc, "X. parametri")

if (ImaPravoPristupa(goModul:oDataBase:cName, "MAIN", "PARAMS"))
	AADD(opcexe, {|| m_par()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("grn", .t. )

return


// -------------------------------------------------
// -------------------------------------------------
method srv()
return

// -------------------------------------------------
// -------------------------------------------------
method setGVars()

set_global_vars()
SetFmkRGVars()

private cSection:="1"
private cHistory:=" "
private aHistory:={}

public gFirma := "10"
public gNFirma := SPACE(20)
public gPicVrijednost := "9999999.99"

// rnal - specif params section
// firma podaci
public gFNaziv:=SPACE(40)
public gFAdresa:=SPACE(40)
public gFIdBroj:=SPACE(13)
public gFTelefon:=SPACE(40)
public gFEmail:=SPACE(40)
public gFBanka1:=SPACE(50)
public gFBanka2:=SPACE(50)
public gFBanka3:=SPACE(50)
public gFBanka4:=SPACE(50)
public gFBanka5:=SPACE(50)
public gFPrRed1:=SPACE(50)
public gFPrRed2:=SPACE(50)

// izgled dokumenta
public gDl_margina := 5
public gDd_redovi := 11
public gDg_margina := 0

// ostali parametri
public gFnd_reset := 0
public gMaxHeigh := 3600
public gMaxWidth := 3600
public gDefNVM := 560
public gDefCity := "Sarajevo"

// export parametri
public gExpOutDir := PADR("c:\temp\", 150)
public gExpAlwOvWrite := "N"
public gFaKumDir := PADR( STRTRAN( KUMPATH, "\RNAL\", "\FAKT\" ), 150 )
public gFaPrivDir := PADR( STRTRAN( PRIVPATH, "\RNAL\", "\FAKT\" ), 150 )
public gPoKumDir := PADR( STRTRAN( KUMPATH, "\SIGMA\RNAL\", "\KASE\TOPS\" ), 150 )
public gPoPrivDir := PADR( STRTRAN( PRIVPATH, "\SIGMA\RNAL\", "\KASE\TOPS\" ), 150 )
public gAddToDim := 3

// default joker glass type
public gDefGlType
// default joker glass tick
public gDefGlTick
// default joker glass
public gGlassJoker
// default frame joker
public gFrameJoker
// joker glass LAMI
public gGlLamiJoker

// joker brusenje
public gAopBrusenje
// joker kaljenje
public gAopKaljenje

// timeout kod azuriranja
public gInsTimeOut := 150

// gn.zaok min/max
public gGnMin := 20
public gGnMax := 6000
public gGnStep := 30

::super:setTGVars()

O_KPARAMS

// sekcija "1"
cSection := "1"
Rpar( "ff", @gFirma )
Rpar( "fn", @gNFirma )

// sekcija "5"
cSection := "5"
Rpar( "p1", @gPicVrijednost )
Rpar( "a1", @gFnd_reset )
Rpar( "a3", @gMaxWidth )
Rpar( "a4", @gMaxHeigh )
Rpar( "a5", @gDefNVM )
Rpar( "to", @gInsTimeOut )
Rpar( "g1", @gGnMin )
Rpar( "g2", @gGnMax )
Rpar( "g3", @gGnStep )


// sekcija "E"
cSection := "E"
Rpar( "od", @gExpOutDir )
Rpar( "ao", @gExpAlwOvWrite )
Rpar( "ad", @gAddToDim )
Rpar( "pd", @gFaPrivDir )
Rpar( "kd", @gFaKumDir )
Rpar( "tp", @gPoPrivDir )
Rpar( "tk", @gPoKumDir )

cSection := "1"

if Empty(gNFirma)
	Beep(1)
	Box(,1,50)
		@ m_x+1, m_y+2 SAY "Unesi naziv firme:" GET gNFirma PICT "@!"
		read
	BoxC()
	Wpar("fn", gNFirma)
endif

select (F_PARAMS)

use

public gModul
public gTema
public gGlBaza

gModul:="RNAL"
gTema:="OSN_MENI"
gGlBaza:="DOCS.DBF"

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

// rules block i cols
public aRuleSpec := g_rule_cols_rnal()
public bRuleBlock := g_rule_block_rnal()

return


