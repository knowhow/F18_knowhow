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
static cPm
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

function tops_kif(dD1, dD2, cSezona)
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
	
	if g_src_modul(src) == "TOPS"
		
		cTdSrc := td_src
		
		// set id tarifu u kif dokumentu
		cIdTar := s_id_tar
		cIdPart := s_id_part
		
		cKatP := kat_p
		cKatP2 := kat_p_2
	
		cOpis := naz
	
		cRazbDan := razb_dan

		if !EMPTY(id_kto)
			cPm := PADR(id_kto, 2)
		endif

		// setuj broj dokumenta
		cSBRdok := s_br_dok

		PRIVATE cFormBPdv := form_b_pdv
		PRIVATE cFormPdv := form_pdv

		
		PRIVATE cTarFormula := ""
		PRIVATE cTarFilter := ""
		

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
		
	
		nZaok := zaok
		nZaok2 := zaok2
	
		// za jednu shema gen stavku formiraj kif
		gen_sg_item(cSezona)
		
	endif
	
	SELECT sg_kif
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

local lSkip
local nCijena

local cIdPos

// otvori pos tabelu
// ------------------------------------------


cPomPath :=  AddBs(ALLTRIM(sg_kif->s_path)) + sez_fill(cSezona) + "POS"
cPomSPath :=  AddBs(ALLTRIM(sg_kif->s_path_s)) + sez_fill(cSezona)

select (F_POS)
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


SELECT POS
PRIVATE cFilter := ""


cFilter :=  cm2str(dDatOd) + " <= datum .and. " + cm2str(dDatDo) + ">= datum" 

// setuj tip dokumenta
cFilter :=  cFilter + ".and. IdVD == " + cm2str(cTdSrc)

if !EMPTY(cTarFilter)
	cFilter += ".and. " + cTarFilter
endif

if !EMPTY(cPm)
	cFilter +=  ".and. IdPos == " + cm2str(cPm)
endif



// "1", "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena"
SET ORDER TO TAG "1"
SET FILTER TO &cFilter

GO TOP

// prosetajmo kroz pos tabelu
nCount := 0
do while !eof()

	// napuni P_KIF i setuj mem vars
	// ----------------------------------------------
	SELECT p_kif
	Scatter()
	// ----------------------------------------------


	SELECT POS
	dDMin := datum
	dDMax := datum

	// ove var moraju biti private da bi se mogle macro-om evaluirati
	PRIVATE _uk_b_pdv := 0
	PRIVATE _popust := 0
	
	do while !eof() .and.  (datum == dDMax)

	SELECT pos

	cBrdok := pos->brdok
	cIdTipDok := pos->idvd
	cIdPos := pos->IdPos

	// datum kif-a
	_datum := pos->datum
	_id_part := ""
	_opis := cOpis

	if !empty(cIdPart)
		_id_part := cIdPart
	endif

	//lIno := IsIno(_id_part)
	//lPdvObveznik := IsPdvObveznik(_id_part)
	
	lIno := .f.
	lPdvObveznik := .f.
	
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

	
	nCount ++

	cPom := "TOPS : " + cIdPos + "-" + cIdTipDok + "-" + cBrDok
	@ m_x+3, m_y+2 SAY cPom 
	
 	cPom :="TOPS cnt : " + STR(nCount, 6)
	@ m_x+4, m_y+2 SAY cPom
	
	
	// tarifa koja se nalazi unutar dokumenta
	cDokTar := ""
	
	SELECT POS

	
	dDMinD := datum
	dDMaxD := datum
	
	do while !eof() .and. cBrDok == brdok .and. cIdTipDok == IdVd .and. cIdPos == IdPos
		if lSkip
			SKIP
			LOOP
		endif

		// na nivou dokumenta utvrdi min max datum
		if dDMinD > datum
			dDMinD := datum
		endif

		if dDMaxD < datum
			dDMaxD := datum
		endif
		
		// na nivou dat opsega utvrdi min max datum
		if dDMin > datum
			dDMinD := datum
		endif

		if dDMax < datum
			dDMax := datum
		endif
		

		// pozicioniraj se na artikal u sifranriku robe
		SELECT ROBA
		seek pos->idroba
		SELECT POS
		
		cDokTar := pos->idTarifa
		_id_tar := pos->idTarifa
		
		nCijena := cijena / (1 + g_pdv_stopa(cDokTar)/100 )
		// u posu se pohranjuje vrijednost u KM popusta
		// u odnosu na cijenu
		
		// vrati popust
		nCPopust := tops_popust()
		
		// izracuna koliko je to bez pdv-a
		nCPopust := nCPopust / (1 + g_pdv_stopa(cDokTar)/100 )

		_uk_b_pdv += round( kolicina * (nCijena - nCPopust) , nZaok)
		_popust +=  round( kolicina * ( nCPopust ) , nZaok)
		
		SELECT POS
		skip
	enddo

	
	if (cRazbDan == "D")
		// razbij po danima
		if dDMinD <> dDMaxD
			MsgBeep("U dokumentu " + cIdPos + "-" + cIdTipDok + "-" + cBrDok + "  se nalaze datumi " + DTOC(dDMaxD) + "-" + DTOC(dDMaxD) + "##" + ;
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
		SELECT POS
		LOOP
	endif
	
	_uk_b_pdv := round(_uk_b_pdv, nZaok2)
	_uk_popust := round(_popust, nZaok2)

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
	SELECT P_KIF
	APPEND BLANK
	Gather()
	

	//f_part_f_src(cSifPath, _id_part)
	
	select POS
enddo


return


// ----------------------------------------
// ----------------------------------------
static function tops_popust()

/*
if right(odj->naz,5)=="#1#0#"
     		nNeplaca+=Kolicina*Cijena - ncijena*Kolicina
elseif right(odj->naz,6)=="#1#50#"
     		nNeplaca+=Kolicina*Cijena/2 - ncijena
endif
*/

/* ovo koristi samo vrijeme zenica za sada ovo necu rjesavati
 if (gPopVar="P" .and. gClanPopust) 
		if !EMPTY(cPartner)
			nNeplaca+=kolicina*NCijena
		endif
 endif
*/
	
return pos->NCijena
	
