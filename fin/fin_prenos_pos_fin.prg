/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

#define F_T_PROMVP		245

/*! \fn GetPrVPParams(cProdId, dDatOd, dDatDo, dDatDok, cTipNal, cShema)
 *  \brief Setuj parametre prenosa
 *  \param cProdId - id prodavnice
 *  \param dDatOd - datum prenosa od
 *  \param dDatDo - datum prenosa do
 *  \param dDatDok - datum dokumenta
 */
function GetPrVPParams(cProdId, dDatOd, dDatDo, dDatDok, cTipNal, cShema)

dDatOd:=DATE()-30
dDatDo:=DATE()
dDatDok:=DATE()
cProdId:=SPACE(2)
cTipNal:="  "
cShema:=" "

Box("#Kontiranje evidencije vrsta placanja",7,60)
	@ m_x+2, m_y+2 SAY "TOPS - prodajno mjesto:" GET cProdId VALID !Empty(cProdId)
	@ m_x+3, m_y+2 SAY "Datum od" GET dDatOd VALID !Empty(dDatOd)
	@ m_x+3, m_y+20 SAY "do" GET dDatDo VALID !Empty(dDatDo)
	
	@ m_x+5, m_y+2 SAY "Vrsta naloga:" GET cTipNal VALID !Empty(cTipNal)
	@ m_x+6, m_y+2 SAY "Datum knjizenja:" GET dDatDok VALID !Empty(dDatDok)
	@ m_x+7, m_y+2 SAY "Shema:" GET cShema
	read
BoxC()

if LastKey()=K_ESC
	return .f.
else
	return .t.
endif

return



/*! \fn PromVP2Fin()
 *  \brief Centralna funkcija za prenos PROMVP u FIN
 */
function PromVP2Fin()

private cProdId
private dDatOd
private dDatDo
private dDatDok
private KursLis:="1"
private cTKPath:=""
private cProdKonto:=""
private cTipNal
private cShema

// otvori potrebne tabele
O_PrVP_DB()

// setuj parametre prenosa
if !GetPrVPParams(@cProdId, @dDatOd, @dDatDo, @dDatDok, @cTipNal, @cShema)
	return
endif

// daj TOPS.KUMPATH i prodavnicki konto iz KONCIJ
if !GetTopsParams(@cTKPath, @cProdKonto)
	return
endif

AddBS(@cTKPath)

// selektuj PROMVP kao F_T_PROMVP
if file(cTKPath + "PROMVP.DBF")
	SELECT (F_T_PROMVP)
	USE (cTKPath + "PROMVP")
	set order to tag "1"
else
	MsgBeep("Ne postoji fajl PROMVP.DBF!")
	return
endif

// predji na shemu kontiranja
select trfp2
// selektuj shemu "P" - polog pazara
set filter to idvd=cTipNal .and. shema=cShema
go top

if (trfp2->idvd <> cTipNal)
	MsgBeep("Ne postoji definisana shema kontiranja!")
	return
endif

MsgO("Kontiram nalog ...")
// daj naredni broj naloga
private cBrNal:=fin_novi_broj_dokumenta( gFirma, cTipNal )
private nRBr:=0
private nIznos:=0
private nIznDEM:=0
private cBrDok:=""
private nCounter:=0
private cIdKonto:=""
private nIzn:=0

do while !eof()
	private cPom:=trfp2->id
	
	cIdKonto:=trfp2->idkonto
	cIdkonto:=STRTRAN(cIdKonto,"A1",Right(trim(cProdKonto),1))
	cIdkonto:=STRTRAN(cIdKonto,"A2",Right(trim(cProdKonto),2))

	if "NaDan" $ cPom
		nCounter := &cPom
		skip 1
	else
		nIznos:=GetVrPlIznos(cPom)
		nIznDem:=nIznos*Kurs(dDatDok, "D", "P")
		Azur2Pripr(cBrNal, dDatDok)
		skip 1
	endif
enddo

MsgC()

select fin_pripr
go top

if RecCount() > 0
	MsgBeep("Nalog izgenerisan u pripremu...")
endif

return



/*! \fn Azur2Pripr(cBrojNal, dDatNal)
 *  \brief Azuriranje stavke u pripremu
 *  \param cBrojNal - broj naloga
 *  \param dDatNal - datum naloga
 */
static function Azur2Pripr(cBrojNal, dDatNal)

local nArr
nArr:=SELECT()

select fin_pripr
append blank
replace idvn with trfp2->idvn
replace	idfirma with gFirma
replace	brnal with cBrojNal
replace	rbr with STR(++nRBr,4)
replace datdok with dDatNal
replace	idkonto with cIdKonto
replace	d_p with trfp2->d_p
replace	iznosbhd with nIznos
replace	iznosdem with nIznDEM
replace	brdok with cBrDok
replace	opis with TRIM(trfp2->naz)

select (nArr)
return




/*! \fn NaDan(cField)
 *  \brief Vraca ukupan iznos pologa (cField) za datumski period
 *  \param cField - polje, npr "POLOG01"
 */
function NaDan(cField)

local nArr
nArr:=SELECT()
select F_T_PROMVP
set order to tag "1"
go top

nIznos:=0
do while !EOF() 
	if (field->pm <> cProdId)
		skip
		loop
	endif
	if (field->datum > dDatDo .or. field->datum < dDatOd)
		skip
		loop
	endif
	nIznos:=field->&cField
	nIznDem:=nIznos*Kurs(dDatDok, "D", "P")
	Azur2Pripr(cBrNal, field->datum)
	skip 1
enddo

select (nArr)

return 1



/*! \fn GetVrPlIznos(cField)
 *  \brief Vraca iznos pologa za datumski period
 *  \param cField - polje, npr "POLOG01"
 */
static function GetVrPlIznos(cField)

local nArr
nArr:=SELECT()
select F_T_PROMVP
set order to tag "1"
go top

nIzn:=0
do while !EOF() 
	if (field->pm <> cProdId)
		skip
		loop
	endif
	if (field->datum > dDatDo .or. field->datum < dDatOd)
		skip
		loop
	endif
	nIzn+=field->&cField
	skip
enddo

select (nArr)

return nIzn




/*! \fn O_PrVP_DB()
 *  \brief Otvaranje neophodnih tabela 
 */
static function O_PrVP_DB()

O_KONCIJ
O_PARTN
O_SUBAN
O_KONTO
O_FAKT_OBJEKTI
O_NALOG
O_FIN_PRIPR
O_TRFP2

return



/*! \fn GetTopsParams(cTKPath, cProdKonto)
 *  \brief Setuje TOPS kumpath i idkonto 
 *  \param cTKPath - kumpath tops
 *  \param cProdKonto - prodavnicki konto
 */
static function GetTopsParams(cTKPath, cProdKonto)

O_KONCIJ
select koncij
// setuj filter po cProdId
set filter to idprodmjes=cProdId
go top
if field->idprodmjes<>cProdId
	MsgBeep("Ne postoji prodajno mjesto:" + cProdId + "##Prekidam operaciju!")
	return .f.
endif

cTKPath:=ALLTRIM(koncij->kumtops)
cProdKonto:=koncij->id

// vrati filter
set filter to

if EMPTY(cTKPath)
	MsgBeep("Nije podesen kumpath TOPS-a u tabeli KONCIJ!")
	return .f.
endif
if EMPTY(cProdKonto)
	MsgBeep("Ne postoji prodavnicki konto!")
	return .f.
endif

return .t.



