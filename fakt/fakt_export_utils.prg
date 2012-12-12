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


// ----------------------------------
// export tabele fakt
// ----------------------------------
function fkt_export()
local dD_f
local dD_t
local cId_f
local cId_td

// daj uslove
if _get_vars( @dD_f, @dD_t, @cId_f, @cId_td ) == 0
	return
endif

// kreiraj export tabelu
_cre_tbl()
O_R_EXP
index on idfirma+idtipdok+brdok tag "1" 

_fill_exptbl( dD_f, dD_t, cId_f, cId_td )

return


// ---------------------------------
// kreiranje tabele
// ---------------------------------
static function _cre_tbl()
local aDbf

aDbf := _fld_get()
t_exp_create( aDbf )

return



// ----------------------------------
// vraca potrebna polja tabele
// ----------------------------------
static function _fld_get()
local aRet := {}

AADD( aRet, { "IDFIRMA", "C", 2, 0 })
AADD( aRet, { "IDTIPDOK", "C", 2, 0 })
AADD( aRet, { "BRDOK", "C", FAKT_BRDOK_LENGTH, 0 })
AADD( aRet, { "DATDOK", "D", 8, 0 })
AADD( aRet, { "IDPARTNER", "C", 6, 0 })
AADD( aRet, { "IDROBA", "C", 10, 0 })
AADD( aRet, { "KOLICINA", "N", 20, 5 })
AADD( aRet, { "CIJENA", "N", 20, 5 })
AADD( aRet, { "RABAT", "N", 20, 5 })
AADD( aRet, { "IDREL", "C", 5, 0 })

return aRet


// -----------------------------------
// uslovi povlacenja
// -----------------------------------
static function _get_vars( dD_f, dD_t, cId_f, cId_td )
local nRet := 1
local GetList := {}

dD_f := DATE()-60
dD_t := DATE()
cId_f := PADR( gFirma + ";", 100 )
cId_td := PADR("10;", 100)

Box(, 5, 65)
	@ m_x + 1, m_y + 2 SAY "Datum od" GET dD_f
	@ m_x + 1, col() + 1 SAY "do" GET dD_t
	@ m_x + 2, m_y + 2 SAY "Firma (prazno-sve):" GET cId_f ;
		PICT "@S20"
	@ m_x + 3, m_y + 2 SAY "Tip dokumenta (prazno-svi:)" GET cId_td ;
		PICT "@S20"
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet


// ----------------------------------
// napuni export tabelu
// ----------------------------------
static function _fill_exptbl( dD_f, dD_t, cId_f, cId_td )
local cFilt := ""
local cIdFirma
local cIdTipDok
local cBrDok
local cIdRoba
local nCount := 0

O_R_EXP
O_ROBA
O_FAKT_DOKS
O_FAKT

if !EMPTY( cId_f )
	cFilt += Parsiraj( ALLTRIM(cId_f), "idfirma", "C" )
endif

if !EMPTY( cId_td )
	if !EMPTY( cFilt )
		cFilt += " .and. "
	endif
	cFilt += Parsiraj( ALLTRIM(cId_td), "idtipdok", "C" )
endif



select fakt
set order to tag "1"

if !EMPTY( cFilt )
	set filter to &cFilt
	go top
endif

do while !EOF()

	// provjeri datum
	if ( field->datdok < dD_f .or. field->datdok > dD_t )
		skip
		loop
	endif

	cIdFirma := field->idfirma
	cIdTipDok := field->idtipdok
	cBrDok := field->brdok
	cIdRoba := field->idroba

	// pozicioniraj se na doks
	select fakt_doks
	seek cIdFirma + cIdTipdok + cBrDok

	select r_export
	append blank

	++ nCount

	replace idfirma with fakt->idfirma
	replace idtipdok with fakt->idtipdok
	replace brdok with fakt->brdok
	replace datdok with fakt->datdok
	replace idpartner with fakt_doks->idpartner
	replace idroba with fakt->idroba
	replace kolicina with fakt->kolicina
	replace cijena with fakt->cijena
	replace rabat with fakt->rabat

	if fakt->(FIELDPOS("IDRELAC")) <> 0
		replace idrel with fakt->idrelac
	endif

	select fakt
	skip
enddo

if nCount > 0
	msgbeep("Exportovao " + ALLTRIM(STR(nCount)) + " zapisa u R_EXP.DBF !")
endif


return


