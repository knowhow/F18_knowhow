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

static cLinija


/*! \fn DnevProm()
 *  \brief Izvjestaj dnevnog prometa
 *  \todo Ovaj izvjestaj nije dobro uradjen - formira se matrica, koja ce puci na velikom broju artikala
 */
function DnevProm()
local i
local cOldIni
local dDan
local cTops
local cPodvuci
local aR
private cFilter

gPINI:=""
dDan:=DATE()
cTops:="D"
cPodvuci:="N"
cFilterDn:="D"

cLinija:="----- ---------- ---------------------------------------- --- ---------- -------------"

cFilter:=IzFmkIni("KALK","UslovPoRobiZaDnevniPromet","(IDROBA=01)", KUMPATH)

if GetVars(@dDan, @cTops, @cPodvuci, @cFilterDn, @cFilter)==0
	return
endif

aR:={}
if (cTops=="D")
	if ScanTops(dDan, @aR)==0
		return
	endif
else
	if ScanKalk(dDan, @aR)==0
		return
	endif
endif

cOldIni:=gPINI
StartPrint(.t.)
nStr:=1
Header(dDan, @nStr)

nUk:=0
nUkKol:=0
for i:=1 TO LEN(aR)
	? STR(i,4)+"."
	?? "", PADR(aR[i, 1], 10)
	?? "", PADR(aR[i, 2], 40)
	?? "", PADR(aR[i, 3], 3)
	?? "", TRANS(aR[i, 4], "999999999")
	?? "", TRANS(aR[i, 5], "9999999999.99")
	if (cPodvuci=="D")
		?  cLinija
	endif
	
	nUkKol+=aR[i, 4]
	nUk+=aR[i, 6]
next
Footer(cPodvuci, nUk, nUkKol)
EndPrint()
  
gPINI:=cOldIni
CopyZaSlanje(dDan)

CLOSERET
return
*}


/*! \fn PromPeriod()
 *  \brief (Vise)dnevni promet za period
 */
function PromPeriod()
*{
local i
local cOldIni
local dDan
local dDatDo
local aUslPKto
local cTops
local cPodvuci
local aR

private cFilter

gPINI:=""
dDan:=DATE()
cTops:="D"
cPodvuci:="N"
cFilterDn:="D"
aUslPKto:=SPACE(100)
dDatDo:=DATE()

cLinija:="----- ---------- ---------------------------------------- --- ---------- -------------"

cFilter:=IzFmkIni("KALK","UslovPoRobiZaDnevniPromet","(IDROBA=01)", KUMPATH)

if GetVars(@dDan, @cTops, @cPodvuci, @cFilterDn, @cFilter, @dDatDo, @aUslPKto)==0
	return
endif

aR:={}
if (cTops=="D")
	if ScanTops(dDan, @aR, dDatDo, aUslPKto)==0
		return
	endif
else
	if ScanKalk(dDan, @aR, dDatDo, aUslPKto)==0
		return
	endif
endif

cOldIni:=gPINI
StartPrint(.t.)
nStr:=1
Header(dDan, @nStr)

nUkKol:=0
nUk:=0
for i:=1 TO LEN(aR)
	? STR(i,4)+"."
	?? "", PADR(aR[i, 1], 10)
	?? "", PADR(aR[i, 2], 40)
	?? "", PADR(aR[i, 3], 3)
	?? "", TRANS(aR[i, 4], "999999999")
	?? "", TRANS(aR[i, 5], "9999999999.99")
	if (cPodvuci=="D")
		?  cLinija
	endif
	nUkKol+=aR[i, 4]
	nUk+=aR[i, 6]
next
Footer(cPodvuci, nUk, nUkKol)
EndPrint()
  
gPINI:=cOldIni
CopyZaSlanje(dDan)

CLOSERET
return
*}


/*! \fn ScanTops(dDan, aR, dDatDo, cPKto)
 *  \brief Skenira tabele kasa i kupi promet
 */
static function ScanTops(dDan, aR, dDatDo, cPKto)
*{
local cTSifP
local nSifP
local cTKumP
local nMpcBp

O_TARIFA
O_KONCIJ

if FIELDPOS("KUMTOPS")=0
	MsgBeep("Prvo izvrsite modifikaciju struktura pomocu KALK.CHS !")
	CLOSE ALL
	return 0
endif
GO TOP

do while (!EOF())
	cTSifP:=TRIM(SIFTOPS)
	cTKumP:=TRIM(KUMTOPS)
	if EMPTY(cTSifP) .or. EMPTY(cTKumP)
		SKIP 1
		loop
	endif
	
	if (cPKto <> nil) .and. !Empty(cPKto)
		if !(ALLTRIM(field->id) $ ALLTRIM(cPKto))
			SKIP 1
			loop
		endif
	endif
	
	AddBs(@cTKumP)
	AddBs(@cTKumP)
	AddBs(@cTSifP)
	
	if (!FILE(cTKumP+"POS.DBF") .or. !FILE(cTKumP+"POS.CDX"))
		SKIP 1
		loop
	endif
	
	SELECT 0
	if !FILE(cTSifP+"ROBA.DBF") .or. !FILE(cTSifP+"ROBA.CDX")
		use (SIFPATH+"ROBA")
		set order to tag "ID"
	else
		use (cTSifP+"ROBA")
		set order to tag "ID"
	endif
	
	SELECT 0
	use (cTKumP+"POS")
	// dtos(datum)
	SET ORDER TO TAG "4" 

	SEEK dtos(dDan)

	if (dDatDo <> nil)
		bDatCond := {|| DToS(datum)>=DToS(dDan) .and. DToS(datum)<=DToS(dDatDo)} 
	else
		bDatCond := {|| DToS(datum)==DToS(dDan)} 
	endif
	
	do while !EOF() .and. EVAL(bDatCond)
		if field->idvd<>"42"
			skip
			loop
		endif
		if (cFilterDn=="D")
			if .not. &cFilter 
				SKIP 1
				loop
			endif
		endif

		SELECT roba
		SEEK pos->idroba
		SELECT tarifa
		SEEK roba->idtarifa
		SELECT POS

		nMpcBP:=ROUND(cijena/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100),2)
		SELECT POS
		if !LEN(aR)>0 .or. !((nPom:=ASCAN(aR,{|x| x[1]==idroba}))>0)
			AADD(aR,{idroba,LEFT(ROBA->naz,40),ROBA->jmj,kolicina, nMpCBP , cijena*kolicina})
		else
			aR[nPom,4] += kolicina
			aR[nPom,6] += nMpCBP*kolicina
		endif
		SKIP 1
	enddo

	SELECT roba
	USE
	SELECT pos
	USE
	SELECT koncij
	SKIP 1
enddo

ASORT(aR,,,{|x,y|x[1]<y[1]})

return 1
*}


/*! \fn ScanKalk(dDan, aR, dDatDo, cPKto)
 *  \brief Skenira tabelu kalk i kupi promet prodavnica
 */
static function ScanKalk(dDan, aR, dDatDo, cPKto)
*{

O_ROBA
O_KALK
// idFirma+dtos(datdok)+podbr+idvd+brdok
SET ORDER TO TAG "5"      

SEEK gFirma+dtos(dDan)

if (dDatDo <> nil)
	bDatCond := {|| DToS(datdok) >= DToS(dDan) .and. DToS(datdok) <= DToS(dDatDo)}
else
	bDatCond := {|| DToS(datdok) == DToS(dDan)}
endif

do while !EOF() .and. EVAL(bDatCond)
	if (cPKto <> nil)
		if !Empty(cPKto)
			if !(ALLTRIM(field->pkonto) $ ALLTRIM(cPKto))
				SKIP 1
				loop
			endif
		endif
	else
		if !(field->pkonto="132" .and. LEFT(field->idVd,1)=="4")
			SKIP 1
			loop
		endif
	endif
	
	if !LEN(aR)>0 .or. !((nPom:=ASCAN(aR,{|x| x[1]==idroba}))>0)
		AADD(aR,{ field->idRoba,"","", field->kolicina, field->mpc , field->mpc* field->kolicina})
	else
		aR[nPom,4] += field->kolicina
		aR[nPom,6] += field->mpc*field->kolicina
	endif
	SKIP 1
enddo

ASORT(aR,,,{|x,y|x[1]<y[1]})
SELECT ROBA
for i:=1 to LEN(aR)
	HSEEK aR[i,1]
	aR[i,2] := LEFT(field->naz,40)
	aR[i,3] := field->jmj
next

return 1
*}

static function GetVars(dDan, cTops, cPodvuci, cFilterDn, cFilter, dDatDo, aUslPKto)
*{
local cIspraviFilter

cIspraviFilter:="N"
cFilterDn:="N"
Box("#DNEVNI PROMET", 9, 60)

@ m_x+2, m_y+2 SAY "Za datum od" GET dDan
if (dDatDo <> nil)
	@ m_x+2, m_y+27 SAY "do" GET dDatDo
endif
@ m_x+3, m_y+2 SAY "Izvor podataka su kase tj. TOPS (D/N) ?" GET cTops VALID cTops $ "DN" PICT "@!"
@ m_x+4, m_y+2 SAY "Linija ispod svakog reda (D/N) ?" GET cPodvuci VALID cPodvuci $ "DN" PICT "@!"
@ m_x+5, m_y+2 SAY "Uzeti u obzir filter (D/N) ?" GET cFilterDn VALID cFilterDn $ "DN" PICT "@!"

if (aUslPKto <> nil)
	@ m_x+7, m_y+2 SAY "Prodavnicka konta" GET aUslPKto PICT "@S40"
endif

READ

if (cFilterDn=="D")
	@ m_x+7, m_y+2 SAY "Pregled, ispravka filtera " GET cIspraviFilterDn VALID cIspraviFilter $ "DN" PICTURE "@!"
	READ
	cFilter:=PADR(cFilter,200)
	if (cIspraviFilter=="D")
		@ m_x+8, m_y+2 SAY "Filter " GET cFilter PICTURE "@S30"
		READ
	endif
	cFilter:=TRIM(cFilter)
endif

if (LASTKEY()==K_ESC)
	BoxC()
	return 0
endif

BoxC()

return 1
*}


static function Header(dDan, nStr)
*{
local b1
local b2
local b3

b1 := {|| QOUT( "KALK: EVIDENCIJA DNEVNOG PROMETA U MALOPRODAJI NA DAN "+dtoc(dDan),"    Str."+LTRIM(STR(nStr))  ) }

b2 := {|| QOUT( "ID PM:",IzFMKIni("ZaglavljeDnevnogPrometa","IDPM" ,"01    - Planika Flex BiH",EXEPATH)          ) }

b3 := {|| QOUT( "KONTO:",IzFMKIni("ZaglavljeDnevnogPrometa","KONTO","132   - ROBA U PRODAVNICI",EXEPATH)         ) }

EVAL(b1)
EVAL(b2)
EVAL(b3)

? cLinija
? " R.  *  SIFRA   *      N A Z I V    A R T I K L A        *JMJ* KOLICINA *   MPC-PPP  *"
? " BR. * ARTIKLA  *                                        *   *          *            *"
? cLinija
return
*}

static function Footer(cPodvuci, nUk, nUkKol)
*{
? cLinija
? PADR("UKUPNO:",60), TRANS(nUkKol, "9999999999"), SPACE(1), TRANS(nUk,"999999999.99")
? cLinija

return
*}

static function CopyZaSlanje(dDan)
*{
local cS
local cLokS
local cNf
local cDirDest

private cPom

cNF:="FL"+STRTRAN(DTOC(dDan),".","")+".TXT"

if Pitanje(,"Zelite li snimiti dokument radi slanja ?","N")=="N"
	return 0
endif

SAVE SCREEN TO cS
CLS

cDirDest:=ToUnix("C:"+SLASH+"SIGMA"+SLASH+"SALJI"+SLASH)
cLokS:=IzFMKIni("FMK", "LokacijaZaSlanje", cDirDest , EXEPATH)
cPom:="copy "+PRIVPATH+"OUTF.TXT "+cLokS+cNf

RUN &cPom

RESTORE SCREEN FROM cS
if FILE(cLokS+cNf)
	MsgBeep("Kopiranje dokumenta zavrseno!")
else
	MsgBeep("KOPIRANJE FAJLA-IZVJESTAJA NIJE USPJELO!")
endif

return
*}

