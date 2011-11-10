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
static cKalkPath
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

function kalk_kuf(dD1, dD2, cSezona)
*{
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
	
	if g_src_modul(src) == "KALK"
		
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
local nCijena

// otvori kalk tabelu
// ------------------------------------------


cPomPath :=  AddBs(ALLTRIM(sg_kuf->s_path)) + sez_fill(cSezona) + "KALK"
cPomSPath :=  AddBs(ALLTRIM(sg_kuf->s_path_s)) + sez_fill(cSezona)

select (F_KALK)
if cPomPath <> cKalkPath
	cKalkPath := cPomPath
	if used()
		use
	endif
	USE (cPomPath)
else
	if !used()
		USE (cKalkPath)
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
	
	SELECT F_ROBA
	if used()
		use
	endif
	USE (cSifPath + "ROBA")
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


	
SELECT KALK
PRIVATE cFilter := ""

cFilter :=  cm2str(dDatOd) + " <= datdok .and. " + cm2str(dDatDo) + ">= datdok" 

// setuj tip dokumenta
cFilter :=  cFilter + ".and. IdVD == " + cm2str(cTdSrc)

if !EMPTY(cTarFilter)
	cFilter += ".and. " + cTarFilter
endif

if !EMPTY(cKtoFilter)
	cFilter +=  ".and. " + cKtoFilter
endif



// "1","IdFirma+idtipdok+brdok+rbr+podbr"
SET ORDER TO TAG "1"
SET FILTER TO &cFilter

GO TOP

// prosetajmo kroz kalk tabelu
nCount := 0
do while !eof()

	// napuni P_KUF i setuj mem vars
	// ----------------------------------------------
	SELECT p_kuf
	Scatter()
	// ----------------------------------------------
	
	SELECT KALK

	dDMin := datdok
	dDMax := datdok
	
	// ove var moraju biti private da bi se mogle macro-om evaluirati
	PRIVATE _uk_b_pdv := 0
	PRIVATE _popust := 0
	PRIVATE _z_tr_1 := 0
	PRIVATE _z_tr_2 := 0
	PRIVATE _z_tr_3 := 0
	PRIVATE _z_tr_4 := 0
	PRIVATE _z_tr_5 := 0

	// datumski period
	do while !eof() .and.  (datdok == dDMax)

	SELECT kalk

	cBrdok := kalk->brdok
	cIdTipDok := kalk->idvd
	cIdFirma := kalk->IdFirma

	// datum kuf-a
	_datum := kalk->datdok
	_id_part := kalk->idpartner
	_opis := cOpis

	if !empty(cIdPart)
		_id_part := cIdPart
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

	cPom := "KALK : " + cIdFirma + "-" + cIdTipDok + "-" + cBrDok
	@ m_x+3, m_y+2 SAY cPom 
	
 	cPom :="KALK cnt : " + STR(nCount, 6)
	@ m_x+4, m_y+2 SAY cPom
	
	
	
	// tarifa koja se nalazi unutar dokumenta
	cDokTar := ""
	
	
	dDMinD := datdok
	dDMaxD := datdok
	
	do while !eof() .and. cBrDok == brdok .and. cIdTipDok == IdVd .and. cIdFirma == IdFirma
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
		

		// pozicioniraj se na artikal u sifranriku robe
		SELECT ROBA
		seek kalk->idroba
		SELECT KALK
		cDokTar := roba->idTarifa
		
		_id_tar := kalk->idTarifa
		
	



	
		if cTDSrc $ "10#81"
			nCijena := kalk->nc
		endif
			
		_uk_b_pdv += round( kalk->kolicina * nCijena, nZaok)
		zav_tr(@nZ1, @nZ2, @nZ3, @nZ4, @nZ5)
		
		// mozda nam podaci o zavisnim troskovima trebaju trebaju
	        _z_tr_1 += nZ1
                _z_tr_2 += nZ2
	        _z_tr_3 += nZ3
	        _z_tr_4 += nZ4
	        _z_tr_5 += nZ5

		SELECT KALK
		skip
	enddo

	
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
	
	if lSkip
		// vrati se gore
		SELECT KALK
		LOOP
	endif
	
	
	_uk_b_pdv := round(_uk_b_pdv, nZaok2)
	
	_z_tr_1 := round(_z_tr_1, nZaok2)
	_z_tr_2 := round(_z_tr_2, nZaok2)
	_z_tr_3 := round(_z_tr_3, nZaok2)
	_z_tr_4 := round(_z_tr_4, nZaok2)
	_z_tr_5 := round(_z_tr_5, nZaok2)
	

	if !empty(cIdTar)
		// uzmi iz sg sifrarnika tarifu kojom treba setovati
		_id_tar := cIdTar
	else
		// uzmi iz dokumenta
		_id_tar := cDokTar
	endif

	if !EMPTY(cSBrDok)
		_src_br := cSBrDok
		_src_br_2 := cSBrDok
	else
	
		// broj dokumenta
		_src_br := cBrDok
		_src_br_2 := cBrDok
	endif
	
	PRIVATE _uk_pdv :=  _uk_b_pdv * (  g_pdv_stopa(_id_tar) / 100 )
	
	if !EMPTY(cFormBPDV)
		_i_b_pdv := &cFormBPdv
	else
		// nema formule koristi ukupan iznos bez pdv-a
		_i_b_pdv := _uk_b_pdv
	endif
	_i_b_pdv := round(_i_b_pdv, nZaok)
	
	if !EMPTY(cFormPDV)
		_i_pdv := &cFormPdv
	else
		// nema formule koristi ukupan iznos bez pdv-a
		_i_pdv :=  _uk_pdv
	endif
	_i_pdv := round(_i_pdv, nZaok)

	// snimi gornje podatke
	SELECT P_KUF
	APPEND BLANK
	Gather()
	

	f_part_f_src(cSifPath, _id_part)
	
	select KALK
enddo


return


// ----------------------------------------------
// ----------------------------------------------
static function zav_tr(nZ1, nZ2, nZ3, nZ4, nZ5)
local Skol:=0
local nPPP:=0
local gKalo:="0"

SELECT KALK

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

