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
static cFaktPath
static cSifPath
static cTDSrc
static nZaok
static nZaok2
static cIdTar
static cIdPart
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
static cRazbDan
static cSBrDok

function fakt_kif(dD1, dD2, cSezona)
*{
local nCount
local cIdfirma

if cSezona == nil
	cSezona := ""
endif

dDatOd := dD1
dDatDo := dD2
o_kif(.t.)

SELECT F_SG_KIF
if !used()
	O_SG_KIF
endif

SELECT F_ROBA
if !used()
	O_ROBA
endif

SELECT sg_kif
GO TOP
nCount := 0
do while !eof()

	nCount ++

	if upper(aktivan) == "N"
		skip
		LOOP
	endif
	
	@ m_x + 1, m_y+2 SAY "SG_KIF : " + STR(nCount)
	
	if g_src_modul(src) == "FAKT"
		
		cTdSrc := td_src
		
		// set id tarifu u kif dokumentu
		cIdTar := s_id_tar
		cIdPart := s_id_part
		
		cKatP := kat_p
		cKatP2 := kat_p_2
	
		cOpis := naz
		cRazbDan := razb_dan
		cSBrDok := s_br_dok
		
		PRIVATE cFormBPdv := form_b_pdv
		PRIVATE cFormPdv := form_pdv

		
		PRIVATE cTarFormula := ""
		PRIVATE cTarFilter := ""
		

		if ";" $ id_tar 
			// cDokTar je varijabla koja se dole setuje
			// za tarifu dokumenta
			cTarFilter := Parsiraj(id_tar, "cDokTar")

			cTarFormula := ""
		elseif ( "(" $ id_tar ) .and. ( ")" $ id_tar )
			// zadaje se formula
			cTarFormula := id_tar
			cTarFilter := ""
		else
			cTarFilter := ""
			cTarFormula := ""
		endif
		
		nZaok := zaok
		nZaok2 := zaok2
	
		// za jednu shema gen stavku formiraj kif
		gen_sg_item( cSezona )
		
	endif
	
	SELECT sg_kif
	skip

enddo


// ------------------------------------------
// ------------------------------------------
static function  gen_sg_item( cSezona )
local cPomPath
local cPomSPath

local xDummy
local nCount
local cPom
local cPartRejon
local lPdvObveznik
local lIno
local lOslPoClanu

local lSkip
local lRet
local nCijena

local dDMin
local dDMax

local dDMinD
local dDMaxD

local nF_rabat := 0

// otvori fakt tabelu
// ------------------------------------------

cPomPath :=  AddBs(ALLTRIM(sg_kif->s_path)) + sez_fill(cSezona) + "FAKT"
cPomSPath :=  AddBs(ALLTRIM(sg_kif->s_path_s)) + sez_fill(cSezona) 

select (F_FAKT)
if cPomPath <> cFaktPath
	cFaktPath := cPomPath
	if used()
		use
	endif
	USE (cPomPath)
else
	if !used()
		USE (cFaktPath)
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

SELECT FAKT
PRIVATE cFilter := ""

cFilter :=  cm2str(dDatOd) + " <= datdok .and. " + cm2str(dDatDo) + ">= datdok" 

// setuj tip dokumenta
cFilter :=  cFilter + ".and. IdTipDok == " + cm2str(cTdSrc)


// "1","IdFirma+idtipdok+brdok+rbr+podbr"
SET ORDER TO TAG "1"
SET FILTER TO &cFilter

GO TOP

// prosetajmo kroz fakt tabelu
nCount := 0
do while !eof()

	// napuni P_KIF i setuj mem vars
	// ----------------------------------------------
	SELECT p_kif
	Scatter()
	// ----------------------------------------------
	
	SELECT fakt
	dDMin := datdok
	dDMax := datdok

	// ove var moraju biti private da bi se mogle macro-om evaluirati
	PRIVATE _uk_b_pdv := 0
	PRIVATE _popust := 0
	
	do while !eof() .and.  (datdok == dDMax)

	SELECT fakt

	cBrdok := fakt->brdok
	cIdTipDok := fakt->idtipdok
	cIdFirma := fakt->IdFirma

	// datum kif-a
	_datum := fakt->datdok
	_id_part := fakt->idpartner
	_opis := cOpis

	if !empty(cIdPart)
		_id_part := cIdPart
	endif

	lOslPoClan := IsOslClan(_id_part)
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

	cPom := "FAKT : " + cIdFirma + "-" + cIdTipDok + "-" + cBrDok
	@ m_x+3, m_y+2 SAY cPom 
	
 	cPom :="FAKT cnt : " + STR(nCount, 6)
	@ m_x+4, m_y+2 SAY cPom
	
	// ove var moraju biti private da bi se mogle macro-om evaluirati
	//PRIVATE _uk_b_pdv := 0
	//PRIVATE _popust := 0
	
	// tarifa koja se nalazi unutar dokumenta
	cDokTar := ""
	
	SELECT FAKT
	
	dDMinD := datdok
	dDMaxD := datdok

	nF_rabat := 0

	do while !eof() .and. cBrDok == brdok .and. cIdTipDok == IdTipDok .and. cIdFirma == IdFirma
		
		if lSkip
			SKIP
			LOOP
		endif

		// na nivou dokumenta utvrdi min/max datum
		if dDMinD > datdok
			dDMinD := datdok
		endif

		if dDMaxD < datdok
			dDMaxD := datdok
		endif

		if dDMin > datdok
			dDMin := datdok
		endif

		if dDMax < datdok
			dDMax := datdok
		endif

		// pozicioniraj se na artikal u sifranriku robe
		SELECT ROBA
		seek fakt->idroba
		
		SELECT FAKT
		PUBLIC cDokTar := roba->idTarifa

		if !EMPTY(cTarFilter)
			altd()
			lRet := &(cTarFilter)

			if !lRet
				SKIP
				LOOP
			endif
		endif

		// ako je avansna faktura setuj na PDV7AV
		if ALLTRIM( fakt->idvrstep ) == "AV"
			cDokTar := "PDV7AV"
		endif
		
		// ako je oslobodjen po clanu... PDV0
		if lOslPoClanu == .t.
			cDokTar := "PDV0  "
		endif

		_id_tar := cDokTar
			
		if !empty(cTarFormula)
			// moze sadrzavati varijablu _id_tar
			xDummy := &cTarFormula
		endif
	
		if cTDSrc == "11"
			nCijena := cijena / (1 + g_pdv_stopa(cDokTar)/100 )
		else
			nCijena := cijena
		endif

		// rabat
		nF_rabat := field->rabat

		// da li je roba zasticena cijena
		if RobaZastCijena(roba->idtarifa) .and. !lPdvObveznik
			nF_rabat := 0
		endif

		_uk_b_pdv += round( kolicina * (nCijena * (1 - nF_rabat/100)) , nZaok)
		_popust +=  round( kolicina * ( nCijena *  nF_rabat/100 ) , nZaok)
		
		SELECT FAKT
		skip
	enddo

	if ( cRazbDan == "D" )
		
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
	
	// za datum uzmi ovaj veci
	_datum := dDMax

	if lSkip
		// vrati se gore
		SELECT FAKT
		LOOP
	endif

	if !EMPTY( cSBrDok )
		// broj dokumenta
		_src_br := cSBrDok
		_src_br_2 := cSBrDok
	else
		// broj dokumenta
		_src_br := cBrDok
		_src_br_2 := cBrDok
	endif
	
	_uk_b_pdv := round(_uk_b_pdv, nZaok2)
	_uk_popust := round(_popust, nZaok2)

	if !empty(cIdTar) .and. cDokTar <> "PDV7AV" .and. !lOslPoClanu
		// uzmi iz sg sifrarnika tarifu kojom treba setovati
		_id_tar := cIdTar
	else
		// uzmi iz dokumenta
		_id_tar := cDokTar
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
	SELECT P_KIF
	APPEND BLANK
	Gather()
	

	f_part_f_src(cSifPath, _id_part)
	
	select fakt
enddo



return

