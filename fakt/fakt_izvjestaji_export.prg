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


//------------------------------------------------
// export dokumenta u dbf/xls
//------------------------------------------------
function exp_dok2dbf()
local cLaunch
local aDbf := {}

aDbf := _g_fields()

t_exp_create( aDbf )

// dokument prebaci u dbf
_exp_dok()


// pozovi export....
cLaunch := exp_report()
tbl_export( cLaunch )

return


// ---------------------------------------------
// ubaci u exp dbf stavke iz tabele
// ---------------------------------------------
static function _exp_dok()
local nTArea := SELECT()

local cParNaz
local cParRegb

// pripremi fakturu za stampu, samo napuni tabele...
stdokpdv( nil, nil, nil, .t. )

O_R_EXP
O_DRN
O_DRNTEXT
O_RN

// #format partnera: naziv + adresa + ptt + mjesto
cParNaz := ALLTRIM( get_dtxt_opis("K01") ) + ;
		" " + ;
		ALLTRIM( get_dtxt_opis("K02") ) + ;
		" " + ;
		ALLTRIM( get_dtxt_opis("K10") ) + ;
		" " + ;
		ALLTRIM( get_dtxt_opis("K11") )
		
cParRegb := get_dtxt_opis("K03")

// te tabele iskoristi za export
select drn
go top

select rn
go top

do while !EOF()

	select r_export
	append blank
	
	replace brdok with drn->brdok
	replace rbr with rn->rbr
	replace art_id with rn->idroba
	replace art_naz with rn->robanaz
	replace art_jmj with rn->jmj

	replace dat_dok with drn->datdok
	replace par_naz with cParNaz
	replace par_regb with cParRegb
	
	replace i_kol with rn->kolicina
	replace i_bpdv with rn->cjenbpdv
	replace i_popust with rn->popust
	replace i_bpdvp with rn->cjen2bpdv
	replace i_ukupno with (rn->kolicina * rn->cjen2bpdv)
	
	select rn
	skip

enddo

select r_export

// totali....
replace t_bpdv with drn->ukbezpdv
replace t_popust with drn->ukpopust
replace t_bpdvp with drn->ukbpdvpop
replace t_pdv with drn->ukpdv
replace t_ukupno with drn->ukupno

select (nTArea)

return


// --------------------------------------------
// struktura export tabele
// --------------------------------------------
static function _g_fields()
local aDbf := {}

AADD( aDbf, { "brdok", "C", 8, 0 })
AADD( aDbf, { "rbr", "C", 3, 0 })
AADD( aDbf, { "art_id", "C", 10, 0 })
AADD( aDbf, { "art_naz", "C", 160, 0 })
AADD( aDbf, { "art_jmj", "C", 3, 0 })
AADD( aDbf, { "par_naz", "C", 80, 0 })
AADD( aDbf, { "par_regb", "C", 13, 0 })
AADD( aDbf, { "dat_dok", "D", 8, 0 })
AADD( aDbf, { "i_kol", "N", 15, 5 })
AADD( aDbf, { "i_bpdv", "N", 15, 5 })
AADD( aDbf, { "i_popust", "N", 15, 5 })
AADD( aDbf, { "i_bpdvp", "N", 15, 5 })
AADD( aDbf, { "i_ukupno", "N", 15, 5 })
AADD( aDbf, { "t_bpdv", "N", 15, 5 })
AADD( aDbf, { "t_popust", "N", 15, 5 })
AADD( aDbf, { "t_bpdvp", "N", 15, 5 })
AADD( aDbf, { "t_pdv", "N", 15, 5 })
AADD( aDbf, { "t_ukupno", "N", 15, 5 })

return aDbf




