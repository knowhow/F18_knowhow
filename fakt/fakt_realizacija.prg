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


#include "fakt.ch"

static PIC_IZN := "999999999.99"
static _NUM := 12
static _DEC := 2
static _ZAOK := 2
static _FNUM := 15
static _FDEC := 4

// --------------------------------------------
// realizacija maloprodaje fakt
// --------------------------------------------
function fakt_real_maloprodaje()
local nOperater
local cFirma
local dD_from
local dD_to
local cDocType
local nVar
local nT_uk := 0
local nT_pdv := 0
local nT_osn := 0

// uslovi izvjestaja
if g_vars( @cFirma, @dD_from, @dD_to, @cDocType, @nOperater, @nVar ) == 0
	return
endif

// generisi pomocnu tabelu
_cre_tbl()

// generisi promet u pomocnu tabelu
_gen_rek( cFirma, dD_from, dD_to, cDocType, nOperater )

// ima li podataka za prikaz ?
select r_export
if reccount2() == 0
	
	msgbeep("Nema podataka za prikaz !")
	close all
	return

endif

START PRINT CRET

?
? "REALIZACIJA PRODAJE na dan: " + DTOC( dD_to )
? "-----------------------------------------------"
? "Period od:" + DTOC( dD_from ) + " do:" + DTOC( dD_to )
?

P_COND

// uzmi totale
_st_mp_dok( @nT_osn, @nT_pdv, @nT_uk, .t. )

// stampaj po operateru
_st_mp_oper()

?

if nVar = 1
	// odstampaj po robi
	_st_mp_roba()
elseif nVar = 2
	// odstampaj po dokumentima
	_st_mp_dok()
endif

?

// rekapitulacija
P_10CPI

? "REKAPITULACIJA:"
? "---------------------------"
? "1) ukupno bez pdv-a:"
@ prow(), pcol()+1 SAY STR( nT_osn, _NUM, _DEC ) PICT PIC_IZN
? "2) vrijednost pdv-a:"
@ prow(), pcol()+1 SAY STR( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
? "3)    ukupno sa pdv:"
@ prow(), pcol()+1 SAY STR( nT_uk, _NUM, _DEC ) PICT PIC_IZN

FF
END PRINT

return


// --------------------------------------------
// uslovi izvjestaja
// --------------------------------------------
static function g_vars( cFirma, dD_from, dD_to, cDokType, nOperater, nVar )
local nRet := 1
local nX := 1

cFirma := SPACE(50)
dD_from := DATE()
dD_to := DATE()
cDokType := PADR( "11;", 50 )
nOperater := 0
nVar := 1

Box( , 10, 66)

	@ m_x + nX, m_y + 2 SAY "**** REALIZACIJA PRODAJE ****"

	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Firma (prazno-sve):" GET cFirma ;
		PICT "@S20"
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "Obuhvatiti period od:" GET dD_from
	@ m_x + nX, col() + 1 SAY "do:" GET dD_to

	++ nX

	@ m_x + nX, m_y + 2 SAY "Vrste dokumenata:" GET cDokType ;
		PICT "@S30"

	++ nX

	@ m_x + nX, m_y + 2 SAY "Operater (0-svi):" GET nOperater ;
		PICT "999" VALID nOperater = 0

	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Varijanta prikaza 1-po robi 2-po dokumentima" 
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "                  3-samo total" GET nVar ;
		PICT "9"

	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet


// --------------------------------------------------
// generisi u pomocnu tabelu podatke iz FAKT-a
// --------------------------------------------------
static function _gen_rek( cFirma, dD_from, dD_to, cDocType, nOperater )
// prenesi sve iz FAKT u pomocnu tabelu

local cFilter := ""
local cF_firma 
local cF_tipdok
local cF_brdok
local nUkupno

O_FAKT_DOKS
O_FAKT
O_ROBA
O_SIFV
O_SIFK
O_TARIFA
O_PARTN

if !EMPTY( cFirma )
	cFilter += Parsiraj( ALLTRIM( cFirma ), "idfirma" )
endif

if nOperater <> 0
	
	if !EMPTY( cFilter )
		cFilter += ".and."
	endif
	
	cFilter += "oper_id = " + cm2str( nOperater )
endif

if !EMPTY( cDocType )
	
	if !EMPTY( cFilter )
		cFilter += ".and."
	endif

	cFilter += Parsiraj( ALLTRIM( cDocType ), "idtipdok" )
endif


if !EMPTY( DTOS(dD_from) )
	
	if !EMPTY( cFilter )
		cFilter += ".and."
	endif

	cFilter += "datdok >=" + cm2str( dD_from )
endif

if !EMPTY( DTOS(dD_from) )
	
	if !EMPTY( cFilter )
		cFilter += ".and."
	endif

	cFilter += "datdok <=" + cm2str( dD_to )
endif

msgo("generisem podatke ...")

select fakt_doks
set filter to &cFilter
go top

do while !EOF()

	cF_firma := field->idfirma
	cF_tipdok := field->idtipdok
	cF_brdok := field->brdok
	nUkupno := field->iznos

	nOperater := 0

	if doks->(FIELDPOS( "oper_id" )) <> 0
		nOperater := field->oper_id
	endif

	select fakt
	go top
	seek cF_firma + cF_tipdok + cF_brdok

	do while !EOF() .and. field->idfirma == cF_firma ;
		.and. field->idtipdok == cF_tipdok ;
		.and. field->brdok == cF_brdok
		
		cRoba_id := field->idroba
		cPart_id := field->idpartner
		
		select roba
		seek cRoba_id

		select tarifa
		seek roba->idtarifa

		select partn
		seek cPart_id

		select fakt

		nCjPDV := 0
		nCj2PDV := 0
		nCjBPDV := 0
		nCj2BPDV := 0
		nVPopust := 0
	
		// procenat pdv-a
		nPPDV := tarifa->opp

		// kolicina
		nKol := field->kolicina
		nRCijen := field->cijena

	
		if LEFT(field->dindem, 3) <> LEFT(ValBazna(), 3) 
			// preracunaj u EUR
			// omjer EUR / KM
      			nRCijen := nRCijen / OmjerVal( ValBazna(), ;
				field->dindem, field->datdok )
			nRCijen := ROUND( nRCijen, DEC_CIJENA() )
   		endif

	    	// rabat - popust
	    	nPopust := field->rabat
	
		// ako je 13-ka ili 27-ca
		// cijena bez pdv se utvrdjuje unazad 
		if ( field->idtipdok == "13" .and. glCij13Mpc ) .or. ;
			(field->idtipdok $ "11#27" .and. gMP $ "1234567") 
			// cjena bez pdv-a
			nCjPDV := nRCijen	
			nCjBPDV := (nRCijen / (1 + nPPDV/100))
		else
			// cjena bez pdv-a
			nCjBPDV := nRCijen
			nCjPDV := (nRCijen * (1 + nPPDV/100))
		endif
	
		// izracunaj vrijednost popusta
		if Round(nPopust,4) <> 0
			// vrijednost popusta
			nVPopust := (nCjBPDV * (nPopust/100))
		endif
	
		// cijena sa popustom bez pdv-a
		nCj2BPDV := (nCjBPDV - nVPopust)
		
		// izracuna PDV na cijenu sa popustom
		nCj2PDV := (nCj2BPDV * (1 + nPPDV/100))
		
		// preracunaj VPDV sa popustom
		nVPDV := (nCj2BPDV * (nPPDV/100))

		select r_export
		append blank

		replace field->idfirma with fakt->idfirma
		replace field->idtipdok with fakt->idtipdok
		replace field->brdok with fakt->brdok
		replace field->datdok with fakt->datdok
		replace field->operater with nOperater
		replace field->part_id with fakt->idpartner
		replace field->part_naz with ALLTRIM( partn->naz )
		replace field->roba_id with fakt->idroba
		replace field->roba_naz with ALLTRIM( roba->naz )
		replace field->kolicina with nKol
		replace field->s_pdv with nPPDV
		replace field->popust with nVPopust
		replace field->c_bpdv with nCj2BPdv
		replace field->pdv with nVPDV
		replace field->c_pdv with nCj2PDV
		replace field->uk_fakt with nUkupno

		select fakt
		skip
	enddo

	select fakt_doks
	skip

enddo

msgc()

return


// -------------------------------------------
// kreiranje pomocne tabele izvjestaja
// -------------------------------------------
static function _cre_tbl()
local aDbf := {}

AADD( aDbf, { "idfirma", "C", 2, 0 } )
AADD( aDbf, { "idtipdok", "C", 2, 0 } )
AADD( aDbf, { "brdok", "C", 10, 0 } )
AADD( aDbf, { "datdok", "D", 8, 0 } )
AADD( aDbf, { "operater", "N", 3, 0 } )
AADD( aDbf, { "part_id", "C", 6, 0 } )
AADD( aDbf, { "part_naz", "C", 100, 0 } )
AADD( aDbf, { "roba_id", "C", 10, 0 } )
AADD( aDbf, { "roba_naz", "C", 100, 0 } )
AADD( aDbf, { "kolicina", "N", 15, 5 } )
AADD( aDbf, { "popust", "N", 15, 5 } )
AADD( aDbf, { "s_pdv", "N", 12, 2 } )
AADD( aDbf, { "c_bpdv", "N", _FNUM, _FDEC } )
AADD( aDbf, { "pdv", "N", _FNUM, _FDEC } )
AADD( aDbf, { "c_pdv", "N", _FNUM, _FDEC } )
AADD( aDbf, { "uk_fakt", "N", _FNUM, _FDEC } )

t_exp_create( aDbf )
O_R_EXP

index on idfirma + idtipdok + brdok tag "1"
index on roba_id tag "2"
index on STR( operater, 3 ) + idfirma + idtipdok + brdok tag "3"

return



// ---------------------------------------------
// stampa rekapitulacije
// varijanta po dokumentima
// ---------------------------------------------
static function _st_mp_dok( nT_osnovica, nT_pdv, nT_ukupno, lCalc )
local nOsnovica
local nPDV
local nUkupno
local nRbr := 0
local nRow := 35
local cLine := ""
local nOperater
local cOper_Naz := ""

if lCalc == nil
	lCalc := .f.
endif

nT_osnovica := 0
nT_pdv := 0
nT_ukupno := 0

if lCalc == .f.
	// vraca liniju
	g_l_mpdok( @cLine )

	// zaglavlje pregled po robi
	s_z_mpdok( cLine )
endif

select r_export
// po dokumentima
set order to tag "1"
go top

do while !EOF()

	cIdFirma := field->idfirma
	cIdTipDok := field->idtipdok
	cBrDok := field->brdok
	cPart_id := field->part_id
	cPart_naz := field->part_naz
	nOperater := field->operater
	cOper_naz := GetFullUserName( nOperater )
	
	nOsnovica := 0
	nPDV := 0
	nUkupno := 0
	nS_pdv := 0
	nUk_fakt := 0

	do while !EOF() .and. field->idfirma + field->idtipdok + ;
		field->brdok == cIdFirma + cIdTipDok + cBrDok
		
		nOsnovica += field->kolicina * field->c_bpdv
		nPDV += field->kolicina * field->pdv
		nS_pdv := field->s_pdv
		nUk_fakt := field->uk_fakt

		skip
	enddo

	// zaokruzi
	nOsnovica := ROUND( ( nUk_fakt / ( 1 + ( nS_pdv/100 )) ), ;
		ZAO_VRIJEDNOST() )
	nPDV := ROUND( ( nUk_fakt / ( 1 + ( nS_pdv/100 ) ) * ;
		(nS_pdv/100)) , ZAO_VRIJEDNOST() )
	nUkupno := ROUND( nUk_fakt , ZAO_VRIJEDNOST() )

	if lCalc == .f.
		// pa ispisi tu stavku

		// rbr
		? PADL( ALLTRIM( STR( ++nRbr ) ), 4 ) + "."

		// dokument
		@ prow(), pcol()+1 SAY PADR( ALLTRIM( cIdFirma + "-" + ;
			cIdTipDok + "-" + cBrDok ), 16 )

		// partner
		@ prow(), pcol()+1 SAY PADR( ALLTRIM( cPart_id ) + "-" + ;
			ALLTRIM( cPart_naz ), 40 )
	
		// osnovica
		@ prow(), nRow := pcol()+1 SAY STR( nOsnovica, _NUM, _DEC ) ;
			PICT PIC_IZN

		// pdv
		@ prow(), pcol()+1 SAY STR( nPDV, _NUM, _DEC ) PICT PIC_IZN

		// ukupno
		@ prow(), pcol()+1 SAY STR( nUkupno, _NUM, _DEC ) PICT PIC_IZN
		
		// operater
		@ prow(), pcol()+1 SAY PADR( ALLTRIM( cOper_naz ), 20 )

	endif

	// dodaj na total

	nT_ukupno += nUkupno
	nT_osnovica += nOsnovica
	nT_pdv += nPDV

enddo

if lCalc == .f.
	
	// ispisi sada total
	? cLine

	? "UKUPNO:"
	@ prow(), nRow SAY STR( nT_osnovica, _NUM, _DEC ) PICT PIC_IZN
	@ prow(), pcol()+1 SAY STR( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
	@ prow(), pcol()+1 SAY STR( nT_ukupno, _NUM, _DEC ) PICT PIC_IZN

	? cLine
endif

return


// ---------------------------------------------
// stampa rekapitulacije
// varijanta po operaterima
// ---------------------------------------------
static function _st_mp_oper( nT_osnovica, nT_pdv, nT_ukupno )
local nOperater
local cOper_naz
local nOsnovica
local nPDV
local nUkupno
local nRbr := 0
local nRow := 35
local cLine := ""
local cF_tipdok
local cF_firma
local cF_brdok

nT_osnovica := 0
nT_pdv := 0
nT_ukupno := 0

// vraca liniju
g_l_mpop( @cLine )

// zaglavlje pregled po robi
s_z_mpop( cLine )

select r_export
// po operaterima
set order to tag "3"
go top

do while !EOF()

	nOperater := field->operater
	cOper_naz := ""

	// ako postoji operater
	if nOperater <> 0

		nTArea := SELECT()

		cOper_naz := GetFullUserName( nOperater )
		cOper_naz := "(" + ALLTRIM( STR( nOperater ) ) + ") " + ;
			cOper_naz

		select (nTArea)
	endif

	nOsnovica := 0
	nPDV := 0
	nUkupno := 0
	nS_pdv := 0
	nU_fakt := 0
	nUU_fakt := 0

	do while !EOF() .and. field->operater == nOperater 
	
		cF_brdok := field->brdok
		cF_tipdok := field->idtipdok
		cF_firma := field->idfirma

		do while !EOF() .and. field->operater == nOperater .and. ;
			cF_firma + cF_tipdok + cF_brdok == field->idfirma + ;
				field->idtipdok + field->brdok
		
			nU_fakt := field->uk_fakt
			nS_pdv := field->s_pdv
			nOsnovica += field->kolicina * field->c_bpdv
			nPDV += field->kolicina * field->pdv

			skip
		enddo

		nUU_fakt += nU_fakt

	enddo

	// zaokruzi
	nOsnovica := ROUND( ( nUU_fakt / ( 1 + ( nS_pdv/100 )) ), ;
		ZAO_VRIJEDNOST() )
	nPDV := ROUND( ( nUU_fakt / ( 1 + ( nS_pdv/100 ) ) * ;
		(nS_pdv/100)) , ZAO_VRIJEDNOST() )
	nUkupno := ROUND( nUU_fakt , ZAO_VRIJEDNOST() )


	// pa ispisi tu stavku

	// rbr
	? PADL( ALLTRIM( STR( ++nRbr ) ), 4 ) + "."

	// operater
	@ prow(), pcol()+1 SAY PADR( ALLTRIM( cOper_naz ), 40 )
	
	// total
	@ prow(), nRow := pcol()+1 SAY STR( nUkupno, _NUM, _DEC ) ;
		PICT PIC_IZN 

	// pdv
	//@ prow(), pcol()+1 SAY STR( nPDV, _NUM, _DEC ) PICT PIC_IZN

	// osnovica
	//@ prow(), pcol()+1 SAY STR( nOsnovica, _NUM, _DEC ) PICT PIC_IZN 

	// dodaj na total

	nT_ukupno += nUkupno
	nT_osnovica += nOsnovica
	nT_pdv += nPDV

enddo

// ispisi sada total
? cLine

? "UKUPNO:"
@ prow(), nRow SAY STR( nT_Ukupno, _NUM, _DEC ) PICT PIC_IZN
//@ prow(), pcol()+1 SAY STR( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
//@ prow(), pcol()+1 SAY STR( nT_ukupno, _NUM, _DEC ) PICT PIC_IZN

? cLine

return


// ---------------------------------------------
// stampa rekapitulacije
// varijanta po robama
// ---------------------------------------------
static function _st_mp_roba()
local cRoba_id 
local nOsnovica
local nPDV
local nUkupno
local nKolicina
local nT_kolicina := 0
local nRbr := 0
local nRow := 35
local cLine := ""
local nT_osnovica := 0
local nT_pdv := 0
local nT_ukupno := 0

// vraca liniju
g_l_mproba( @cLine )

// zaglavlje pregled po robi
s_z_mproba( cLine )

select r_export
set order to tag "2"
go top

do while !EOF()

	cRoba_id := field->roba_id
	cRoba_naz := field->roba_naz

	nOsnovica := 0
	nPDV := 0
	nS_pdv := 0
	nUkupno := 0
	nKolicina := 0

	do while !EOF() .and. field->roba_id == cRoba_id
		
		nS_pdv := field->s_pdv
		nOsnovica += field->kolicina * field->c_bpdv
		nPDV += field->kolicina * field->pdv
		nKolicina += field->kolicina

		skip
	enddo

	// zaokruzi
	nOsnovica := ROUND(nOsnovica, ZAO_VRIJEDNOST() )
	nPDV := ROUND( (nOsnovica * (nS_pdv/100)) , ZAO_VRIJEDNOST() + _ZAOK )
	nUkupno := ROUND( nOsnovica + nPDV , ZAO_VRIJEDNOST() )


	// pa ispisi tu stavku

	? PADL( ALLTRIM( STR( ++nRbr ) ), 4 ) + "."

	@ prow(), pcol()+1 SAY PADR( ALLTRIM( cRoba_id ) + ;
		"-" + ALLTRIM( cRoba_naz ), 50 )
	
	@ prow(), nRow := pcol()+1 SAY STR( nKolicina, 12, 2 )

	
	// dodaj na total

	nT_kolicina += nKolicina

enddo

// ispisi sada total
? cLine

? "UKUPNO:"
@ prow(), nRow SAY STR( nT_kolicina, 12, 2 )

? cLine

return


// -----------------------------------------
// vraca liniju za pregled po robi
// -----------------------------------------
static function g_l_mproba( cLine )

cLine := ""

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)

return


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
static function s_z_mproba( cLine )

cTxt := ""

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("roba (id/naziv)", 50)
cTxt += SPACE(1)
cTxt += PADR("kolicina", 12)
//cTxt += SPACE(1)
//cTxt += PADR("osnovica", 12)
//cTxt += SPACE(1)
//cTxt += PADR("pdv", 12)
//cTxt += SPACE(1)
//cTxt += PADR("ukupno", 12)

? "Realizacija po robi:"
? cLine
? cTxt
? cLine

return

// -----------------------------------------
// vraca liniju za pregled po robi
// -----------------------------------------
static function g_l_mpop( cLine )

cLine := ""

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 40)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)

return


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
static function s_z_mpop( cLine )

cTxt := ""

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("operater (id/naziv)", 40)
cTxt += SPACE(1)
cTxt += PADR("ukupno", 12)
//cTxt += SPACE(1)
//cTxt += PADR("pdv", 12)
//cTxt += SPACE(1)
//cTxt += PADR("ukupno", 12)

? "Realizacija po opearterima:"
? cLine
? cTxt
? cLine

return


// -----------------------------------------
// vraca liniju za pregled po dokumentima
// -----------------------------------------
static function g_l_mpdok( cLine )

cLine := ""

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 16)
cLine += SPACE(1)
cLine += REPLICATE("-", 40)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 20)

return


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
static function s_z_mpdok( cLine )

cTxt := ""

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("dokument", 16)
cTxt += SPACE(1)
cTxt += PADR("partner (id/naziv)", 40)
cTxt += SPACE(1)
cTxt += PADR("osnovica", 12)
cTxt += SPACE(1)
cTxt += PADR("pdv", 12)
cTxt += SPACE(1)
cTxt += PADR("ukupno", 12)
cTxt += SPACE(1)
cTxt += PADR("operater", 20)

? "Realizacija po dokumentima:"
? cLine
? cTxt
? cLine

return



