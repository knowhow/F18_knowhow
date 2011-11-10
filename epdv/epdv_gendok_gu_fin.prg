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


#include "epdv.ch"

/*
* ----------------------------------------------------------------
*                              Copyright Sigma-com software 2006
* ----------------------------------------------------------------
*/

static dDatOd
static dDatDo
static cFinPath
static cSifPath
static cTDSrc
static nZaok
static nZaok2
static cIdTar
static cIdPart
// setuj broj dokumenta
static cSBRdok 
static cOpis

// kategorija partnera
// 1-pdv obv
// 2-ne pdv obvz
static cKatP

// kategorija partnera 2
// 1-fed
// 2-rs
// 3-bd
static cKatP2

// razbij po danima
static cRazbDan

// --------------------------------------
// --------------------------------------
function fin_kuf(dD1, dD2, cSezona)
local nCount
local cIdfirma

if cSezona == nil
	cSezona := ""
endif

dDatOd := dD1
dDatDo := dD2
o_kuf(.t.)

SELECT F_SG_KUF
if !used()
	O_SG_KUF
endif

SELECT F_ROBA
if !used()
	O_ROBA
endif

SELECT sg_kuf
GO TOP
nCount := 0
do while !eof()

	nCount ++

	if upper(aktivan) == "N"
		skip
		LOOP
	endif
	
	@ m_x + 1, m_y+2 SAY "SG_KUF : " + STR(nCount)
	
	if g_src_modul(src) == "FIN"
		
		cTdSrc := td_src
		
		// set id tarifu u kuf dokumentu
		cIdTar := s_id_tar
		cIdPart := s_id_part
		
		cKatP := kat_p
		cKatP2 := kat_p_2
	
		cOpis := naz
	
		cRazbDan := razb_dan

		// setuj broj dokumenta
		cSBRdok := s_br_dok

		PRIVATE cFormBPdv := form_b_pdv
		PRIVATE cFormPdv := form_pdv

		
		PRIVATE cTarFormula := ""
		PRIVATE cTarFilter := ""
		
		PRIVATE cKtoFormula := ""
		PRIVATE cKtoFilter := ""
	

		if ";" $ id_tar 
			cTarFilter := Parsiraj(id_tar, "IdTarifa")
			cTarFormula := ""
			
		elseif ( "(" $ id_tar ) .and. ( ")" $ id_tar )
			// zadaje se formula
			cTarFormula := id_tar
			cTarFilter := ""
		else
			cTarFilter := ""
			cTarFormula := ""
		endif
		
		if ";" $ id_kto
			cKtoFilter := Parsiraj(id_kto, ALLTRIM(id_kto_naz))
			cKtoFormula := ""
			
		elseif ( "(" $ id_kto ) .and. ( ")" $ id_kto )
			// zadaje se formula
			cKtoFormula := id_kto
			cKtoFilter := ""
		else
			cKtoFilter := ""
			cKtoFormula := ""
		endif
	
		nZaok := zaok
		nZaok2 := zaok2
	
		// za jednu shema gen stavku formiraj kuf
		gen_sg_item(cSezona)
		
	endif
	
	SELECT sg_kuf
	skip

enddo


// ------------------------------------------
// ------------------------------------------
static function  gen_sg_item(cSezona)
local cPomPath
local cPomSPath

local cDokTar
local xDummy
local nCount
local cPom
local cPartRejon
local lPdvObveznik
local lIno
local dDMin
local dDMax

// za jedan dokument
local dDMinD
local dDMaxD


// zavisni troskovi
local nZ1
local nZ2
local nZ3
local nZ4
local nZ5

local lSkip
local lSkip2
local nIznos

local cOpisSuban
local nRecNoSuban

// otvori suban tabelu
// ------------------------------------------


cPomPath :=  AddBs(ALLTRIM(sg_kuf->s_path)) + sez_fill(cSezona) + "SUBAN"
cPomSPath :=  AddBs(ALLTRIM(sg_kuf->s_path_s)) + sez_fill(cSezona)

select (F_SUBAN)
if cPomPath <> cFinPath
	cFinPath := cPomPath
	if used()
		use
	endif
	USE (cPomPath)
else
	if !used()
		USE (cFinPath)
	endif
endif

// radno podrucje analitike cu koristiti za
// suban_2 tabelu
// suban_2 tabelu koristicu za pretragu naloga
select (F_ANAL)
if cPomPath <> cFinPath
	cFinPath := cPomPath
	if used()
		use
	endif
	USE (cPomPath)
else
	if !used()
		USE (cFinPath) alias suban_2
		// "4","idFirma+IdVN+BrNal+Rbr
		SET ORDER TO TAG "4"
	endif
endif

if !(cPomSPath == cSifPath)

	cSifPath := cPomSPath
	
	SELECT F_PARTN
	if used()
		use
	endif
	USE (cSifPath + "PARTN")
	SET ORDER TO TAG "ID"
	

	SELECT F_TARIFA
	if used()
		use
	endif
	USE (cSifPath + "TARIFA")
	SET ORDER TO TAG "ID"

	SELECT F_SIFK
	if used()
		use
	endif
	USE (cSifPath + "SIFK")
	SET ORDER TO TAG "ID"

	SELECT F_SIFV
	if used()
		use
	endif
	USE (cSifPath + "SIFV")
	SET ORDER TO TAG "ID"

endif


	
SELECT SUBAN
PRIVATE cFilter := ""

cFilter :=  cm2str(dDatOd) + " <= datdok .and. " + cm2str(dDatDo) + ">= datdok" 

// setuj tip dokumenta
if !empty(cTdSrc)
	if LEN(TRIM(cTdSrc)) == 1
		// ako se stavi "B " onda se uzimaju svi nalozi koji pocinju
		// sa B
		cFilter :=  cFilter + ".and. IdVN = " + cm2str(TRIM(cTdSrc))
	else
		cFilter :=  cFilter + ".and. IdVN == " + cm2str(cTdSrc)
	endif
endif

if !EMPTY(cTarFilter)
	cFilter += ".and. " + cTarFilter
endif

if !EMPTY(cKtoFilter)
	cFilter +=  ".and. " + cKtoFilter
endif




// "4","idFirma+IdVN+BrNal+Rbr",KUMPATH+"SUBAN"
SET ORDER TO TAG "4"
SET FILTER TO &cFilter

GO TOP

// prosetajmo kroz suban tabelu
nCount := 0
do while !eof()

	// napuni P_KUF i setuj mem vars
	// ----------------------------------------------
	SELECT p_kuf
	Scatter()
	// ----------------------------------------------
	
	SELECT SUBAN

	dDMin := datdok
	dDMax := datdok
	
	// ove var moraju biti private da bi se mogle macro-om evaluirati
	PRIVATE _iznos := 0

	// datumski period
	do while !eof() .and.  (datdok == dDMax)

	SELECT suban

	cBrdok := suban->brnal
	cIdTipDok := suban->IdVn
	cIdFirma := suban->IdFirma

	nRecnoSuban := suban->(recno())
	// datum kuf-a
	_datum := suban->datdok
	_id_part := suban->idpartner
	_opis := cOpis
	
	// ##opis## je djoker - zamjenjuje se sa opisom koji se nalazi u 
	// stavci
	cOpisSuban:= ALLTRIM(suban->opis) 
	_opis := STRTRAN(_opis, "##opis##", cOpisSuban )
	
	if !empty(cIdPart)
		if (ALLTRIM(UPPER(cIdPart)) == "#TD#")
			// trazi dobavljaca
			_id_part := trazi_dob (suban->(recno()), ;
			        suban->idfirma, suban->idvn, suban->brnal, ;
				suban->brdok, suban->rbr)
		else
			_id_part := cIdPart
		endif
	endif

	lIno := IsIno(_id_part)
	lPdvObveznik := IsPdvObveznik(_id_part)
	
	lSkip := .f.
	do case
	
	  case cKatP == "1" 
	  
	  	// samo pdv obveznici
		if lIno
			lSkip := .t.
		endif

		if !lPdvObveznik
			lSkip := .t.
		endif
		
	  case cKatP == "2"
	
		if lPdvObveznik
			lSkip := .t.
		endif
  
	  	// samo ne-pdv obveznici, ako je ino preskoci
		if lIno
			lSkip := .t.
		endif
		
	  case cKatP == "3"
	  	// ino
		if !lIno
			lSkip := .t.
		endif

	endcase

	cPartRejon := part_rejon(_id_part)
	
	do case
	
		case cKatP2 == "1"
			// samo federacija
			if !((cPartRejon == " ") .or. (cPartRejon == "1"))
				lSkip :=.t.
			endif
				
		case cKatP2 == "2"
			// nije rs, preskoci
			if !(cPartRejon == "2")
				lSkip := .t.
			endif
			
		case cKatP2 == "3"
			// nije bd, preskoci
			if !(cPartRejon == "3")
				lSkip := .t.
			endif
	endcase
		
			
	

	
	
	nCount ++

	cPom := "SUBAN : " + cIdFirma + "-" + cIdTipDok + "-" + cBrDok
	@ m_x+3, m_y+2 SAY cPom 
	
 	cPom :="SUBAN cnt : " + STR(nCount, 6)
	@ m_x+4, m_y+2 SAY cPom
	
	
	
	// tarifa koja se nalazi unutar dokumenta
	cDokTar := ""
	
	dDMinD := datdok
	dDMaxD := datdok
	
	//do while !eof() .and. cBrDok == brnal .and. cIdTipDok == IdVN .and. cIdFirma == IdFirma

		// zadaje se formula za tarifu
		lSkip2 := .f.
		if !EMPTY(cTarFormula)
			if ! &(cTarFormula)
				// npr. ABS(trazi_kto("5431")>0)
				lSkip2 := .t.
				SKIP 
				LOOP
			endif
			
		endif

		if lSkip
			SKIP
			LOOP
		endif

		// na nivou dokumenta utvrdi min max datum
		if dDMinD > datdok
			dDMinD := datdok
		endif

		if dDMaxD < datdok
			dDMaxD := datdok
		endif
		
		// na nivou dat opsega utvrdi min max datum
		if dDMin > datdok
			dDMinD := datdok
		endif

		if dDMax < datdok
			dDMax := datdok
		endif
		

		if d_p=="1"
			nIznos := iznosbhd
		else
			nIznos := -iznosbhd
		endif
		
		// broj veze
		cBrDok := brdok
		
		_iznos += nIznos 

		SELECT SUBAN
		skip
		
	//enddo

	
	if (cRazbDan == "D")
		// razbij po danima
		if dDMinD <> dDMaxD
			MsgBeep("U dokumentu " + cIdFirma + "-" + cIdTipDok + "-" + cBrDok + "  se nalaze datumi " + DTOC(dDMaxD) + "-" + DTOC(dDMaxD) + "##" + ;
			"To nije uredu je se promet razbija po danima !!!")
		endif
		
	endif

	if cRazbDan <> "D"
		// nije po danima
		// za jedan dokument se uzima 
		exit
		// ako pak jeste "D" onda se vrti u petlji
	endif

	// datumski interval
	enddo

	// za datum uzmi datum dokumenta ili najveci datum gore pronadjen
	_datum := dDMax
	
	if lSkip .or. lSkip2
		// vrati se gore
		SELECT SUBAN
		LOOP
	endif
	
	PRIVATE _uk_pdv :=  0
	PushWa()
	// --------------------------------------------------------------
	SELECT SUBAN
	go (nRecNoSuban)

	_iznos := round(_iznos, nZaok2)
	
	if !empty(cIdTar)
		// uzmi iz sg sifrarnika tarifu kojom treba setovati
		_id_tar := cIdTar
	else
		// uzmi iz dokumenta
		_id_tar := cDokTar
	endif

	do case
	   case ALLTRIM(cSBrDok) == "#EXT#"
	   	// extractuj ako je empty cBrDok
		if EMPTY(cBrDok)
			// ako nije stavljen broj dokumenta
			// izvuci oznaku iz opisa
			_src_br := extract_oznaka(cOpisSuban)
			_src_br_2 := _src_br
		else
			_src_br := cBrDok
			_src_br_2 := cBrDok
		endif
	   	
	   case !EMPTY(cSBrDok)
		_src_br := cSBrDok
		_src_br_2 := cSBrDok
	   otherwise
	
		// broj dokumenta
		_src_br := cBrDok
		_src_br_2 := cBrDok
	endcase

	
	if !EMPTY(cFormBPDV)
		_i_b_pdv := &cFormBPdv
	else
		// nema formule koristi ukupan iznos bez pdv-a
		_i_b_pdv := _iznos/1.17
	endif
	_i_b_pdv := round(_i_b_pdv, nZaok)
	
	if !EMPTY(cFormPDV)
		_i_pdv := &cFormPdv
	else
		// nema formule koristi ukupan iznos bez pdv-a
		_i_pdv :=  _iznos/1.17*0.17
	endif
	_i_pdv := round(_i_pdv, nZaok)
	// ----------------------------------------------------------
	PopWa()
	
	// snimi gornje podatke
	SELECT P_KUF
	APPEND BLANK
	Gather()
	

	f_part_f_src(cSifPath, _id_part)
	
	select SUBAN
enddo


return


// ----------------------------------------------
// ----------------------------------------------
static function zav_tr(nZ1, nZ2, nZ3, nZ4, nZ5)
local Skol:=0
local nPPP:=0
local gKalo:="0"

SELECT SUBAN

if gKalo=="1"
  Skol:=Kolicina-GKolicina-GKolicin2
else
  Skol:=Kolicina
endif

nPPP:=1

if TPrevoz=="%"
  nPrevoz:=Prevoz/100*FCj2
elseif TPrevoz=="A"
  nPrevoz:=Prevoz
elseif TPrevoz=="U"
  if skol<>0
   nPrevoz:=Prevoz/SKol
  else
   nPrevoz:=0
  endif
else
  nPrevoz:=0
endif
nZ1 := nPrevoz

if TCarDaz=="%"
  nCarDaz:=CarDaz/100*FCj2
elseif TCarDaz=="A"
  nCarDaz:=CarDaz
elseif TCarDaz=="U"
  if skol<>0
   nCarDaz:=CarDaz/SKol
  else
   nCarDaz:=0
  endif
else
  nCarDaz:=0
endif
nZ2 := nCarDaz

if TZavTr=="%"
  nZavTr:=ZavTr/100*FCj2
elseif TZavTr=="A"
  nZavTr:=ZavTr
elseif TZavTr=="U"
  if skol<>0
   nZavTr:=ZavTr/SKol
  else
   nZavTr:=0
  endif
else
  nZavTr:=0
endif
nZ3 := nZavTr


if TBankTr=="%"
  nBankTr:=BankTr/100*FCj2
elseif TBankTr=="A"
  nBankTr:=BankTr
elseif TBankTr=="U"
  if skol<>0
   nBankTr:=BankTr/SKol
  else
   nBankTr:=0
  endif
else
  nBankTr:=0
endif
nZ4 := nBankTr

if TSpedTr=="%"
  nSpedTr:=SpedTr/100*FCj2
elseif TSpedTr=="A"
  nSpedTr:=SpedTr
elseif TSpedTr=="U"
  if skol<>0
   nSpedTr:=SpedTr/SKol
  else
   nSpedTr:=0
  endif
else
  nSpedTr:=0
endif
nZ5 := nSpedTr

return

// -----------------------------------------------------------
// trazi dobavljaca za trosak - mora biti u blizini - iznad ili
// ispod samog troska
// -----------------------------------------------------------
static function trazi_dob(nRecNo, cIdFirma, cIdVn, cBrNal, cBrDok, nRbr)
local i

PushWa()

select suban_2

for i:=-3 to 3

//idi na zadati slog ...
GO (nRecNo)
// pa onda skoci dva unazad i dva unaprijed ...
SKIP i


cKto := LEFT(idkonto, 3 ) 

if (cKto $ ALLTRIM(gL_kto_dob)) .and. (IdFirma ==  cIdFirma) .and. (IdVn == cIdVn) .and. (BrNal == cBrNal) .and. (BrDok == cBrDok)
	// dobavljac
	// ili kreditor
	cIdPartner := idpartner

	PopWa()
	return cIdPartner
endif

next

// nema nista - nisam nista nasao
PopWa()
return ""

// -----------------------------------------------------------
// trazi pdv za odredjenu fakturu dobavljaca
// ispod samog troska
// -----------------------------------------------------------
function traz_pdv_dob(nRecNo, cIdFirma, cIdVn, cBrNal, cBrDok, nRbr, cOpis)
local nPdvIznos 
local i

if nRecno == nil
	nRecno := suban->(recno())
	cIdFirma := suban->IdFirma
	cIdVn := suban->IdVn
	cBrNal := suban->brNal
	cBrDok := suban->BrDok
	nRbr := suban->Rbr
	cOpis := suban->opis
endif

PushWa()

select suban_2

nPdvIznos := 0

for i:=-15 to 15

//idi na zadati slog ...
GO (nRecNo)
// pa onda skoci dva unazad i dva unaprijed ...
SKIP i


cKto := LEFT(idkonto, 3 ) 

// 543 i 260 moraju imati identicnu oznaku broja dokumenta
// ili u samom broju ili u opisu 

if cKto $ ALLTRIM(gKt_updv) .and. (IdFirma ==  cIdFirma) .and. (IdVn == cIdVn) .and. (BrNal == cBrNal) .and. ;
  ( (!empty(BrDok) .and. (BrDok == cBrDok)) .or. opis_i_oznaka(cOpis, opis) )

	altd()
	if d_p == "1"
		// nasao sam stavku pdv-a koja se veze za dobavljaca
		nPdvIznos := iznosbhd
	else
		//
		nPdvIznos := -iznosbhd
	endif
	
	PopWa()
	return nPdvIznos
endif

next

// nema nista - nisam nista nasao
PopWa()
return nPdvIznos


// ----------------------------
// opis ista oznaka
// pretpostavlja se ovaj format
// opis: "neki_tekst<SEPARATOR>oznaka"
// oznaka slova brojeve
// <SEPARATOR> = ".", SPACE
// ----------------------------
function opis_i_oznaka(cOpis1, cOpis2)
local cOzn1, cOzn2

cOzn1 := extract_oznaka(cOpis1)
cOzn2 := extract_oznaka(cOpis2)

if EMPTY(cOzn1) .or. EMPTY(cOzn2) 
	return .f.
endif

return (cOzn1 == cOzn2)

// ---------------------------------
// ekstraktuje oznaku koja se nalazi
// na kraju stringa
// "SPEDITER 16/06 => "16/06"
// "FAKT.DOB.16/06 => "16/06"
// ---------------------------------
static function extract_oznaka(cOpis)
local i, nLen, cPom, cChar

cPom:=""

cOpis := TRIM(cOpis)
nLen := LEN(cOpis)
for i:=nLen to 1 step -1
   cChar := SUBSTR(cOpis, i, 1)
   if cChar $ " ."
   	exit
   else
   	cPom := cChar + cPom 
   endif
next

return cPom


// -----------------------------------------------------------
// trazi odredjeni konto unutar tekuceg naloga
// -----------------------------------------------------------
function trazi_kto(cIdKonto, nRecNo, cIdFirma, cIdVn, cBrNal, cBrDok, nRbr, cOpis)
local nIznos := 0
local i

cIdKonto := PADR(cIdKonto, LEN(suban->IdKonto))
if nRecno == nil
	nRecno := suban->(recno())
	cIdFirma := suban->IdFirma
	cIdVn := suban->IdVn
	cBrNal := suban->brNal
	cBrDok := suban->BrDok
	nRbr := suban->Rbr
	cOpis := suban->opis
endif

PushWa()

select suban_2

for i:=-15 to 15

//idi na zadati slog ...
GO (nRecNo)
// pa onda skoci dva unazad i dva unaprijed ...
SKIP i


if (cIdKonto == IdKonto ) .and. (IdFirma ==  cIdFirma) .and. (IdVn == cIdVn) .and. (BrNal == cBrNal) .and. (BrDok == cBrDok)

	if (d_p == "1")
		// nasao sam stavku koja je isti konto 
		nIznos := iznosbhd
	else
		//
		nIznos := -iznosbhd
	endif
	
	PopWa()
	return nIznos
endif

next

// nema nista - nisam nista nasao
PopWa()
return nIznos


