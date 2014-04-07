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


#include "ld.ch"

static __mj_od
static __mj_do
static __god_od
static __god_do
static __tp1
static __tp2
static __tp3
static __tp4
static __tp5

// -----------------------------------------------
// rpt: sihtarice po grupama
// -----------------------------------------------
function r_sh_print()
local cRj := SPACE(60)
local cRadnik := SPACE(_LR_) 
local cGroup := SPACE(7)
local cTipRpt := "1"
local cIdRj
local cRjDEF := SPACE(2)
local cMj_od
local cMj_do
local cGod_od
local cGod_do
local cDopr10 := "10"
local cDopr11 := "11"
local cDopr12 := "12"
local cDopr1X := "1X"
local cObracun := gObracun
local cWinPrint := "N"
local cDodPr1 := SPACE(2)
local cDodPr2 := SPACE(2)
local cDodPr3 := SPACE(2)
local cDodPr4 := SPACE(2)
local cDodPr5 := SPACE(2)
local cPrimDobra := ""

// kreiraj pomocnu tabelu
ol_tmp_tbl()

cIdRj := gRj
cMj_od := gMjesec
cMj_do := gMjesec
cGod_od := gGodina
cGod_do := gGodina

// otvori tabele
ol_o_tbl()

Box( "#PREGLED TROSKOVA PO SIHTARICAMA", 11, 75 )

@ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
@ m_x + 2, m_y + 2 SAY "Period od:" GET cMj_od pict "99"
@ m_x + 2, col() + 1 SAY "/" GET cGod_od pict "9999"
@ m_x + 2, col() + 1 SAY "do:" GET cMj_do pict "99" 
@ m_x + 2, col() + 1 SAY "/" GET cGod_do pict "9999"
@ m_x+2,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
@ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
	VALID EMPTY(cRadnik) .or. p_radn(@cRadnik)

@ m_x + 5, m_y + 2 SAY "Grupa (prazno-sve): " GET cGroup ;
	VALID EMPTY(cGroup) .or. p_konto(@cGroup)

@ m_x + 7, m_y + 2 SAY "Dodatna primanja za prikaz (1): " GET cDodPr1 ;
	VALID { || _show_get_item_value( g_tp_naz( cDodPr1), 20 ), .t. }
@ m_x + 8, m_y + 2 SAY "Dodatna primanja za prikaz (2): " GET cDodPr2 ;
	VALID { || _show_get_item_value( g_tp_naz( cDodPr2), 20 ), .t. }
@ m_x + 9, m_y + 2 SAY "Dodatna primanja za prikaz (3): " GET cDodPr3 ; 
	VALID { || _show_get_item_value( g_tp_naz( cDodPr3), 20 ), .t. }
@ m_x + 10, m_y + 2 SAY "Dodatna primanja za prikaz (4): " GET cDodPr4 ;
	VALID { || _show_get_item_value( g_tp_naz( cDodPr4), 20 ), .t. }
@ m_x + 11, m_y + 2 SAY "Dodatna primanja za prikaz (5): " GET cDodPr5 ;
	VALID { || _show_get_item_value( g_tp_naz( cDodPr5), 20 ), .t. }

read
	
clvbox()
	
ESC_BCR

BoxC()

if lastkey() == K_ESC
	return
endif

// staticke
__mj_od := cMj_od
__mj_do := cMj_do
__god_od := cGod_od
__god_do := cGod_do
__tp1 := ""
__tp2 := ""
__tp3 := ""

if !EMPTY( cDodPr1 )
	__tp1 := g_tp_naz( cDodPr1 )
endif
if !EMPTY( cDodPr2 )
	__tp2 := g_tp_naz( cDodPr2 )
endif
if !EMPTY( cDodPr3 )
	__tp3 := g_tp_naz( cDodPr3 )
endif
if !EMPTY( cDodPr4 )
	__tp4 := g_tp_naz( cDodPr4 )
endif
if !EMPTY( cDodPr5 )
	__tp5 := g_tp_naz( cDodPr5 )
endif

select ld

msgo("... podaci plata ... molimo sacekajte")
// sortiraj tabelu i postavi filter
ol_sort( cRj, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, cTipRpt, cObracun )

// nafiluj podatke obracuna
ol_fill_data( cRj, cRjDef, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, ;
	cPrimDobra, "", ;
	cDopr10, cDopr11, cDopr12, cDopr1X, cTipRpt, cObracun, ;
	cDodPr1, cDodPr2, cDodPr3, cDodPr4, cDodPr5 )

msgc()

// podatke iz tabele pohrani u matricu
// to su obracuni
aObr := {}
_obr_2_arr( @aObr )

msgo("... generisem izvjestaj ....")

// generisi report
_gen_rpt( cGod_od, cMj_od, cRadnik, cGroup, aObr )

msgc()

// stampa reporta
_print_rpt()

my_close_all_dbf()

return


// ----------------------------------------------
// nafiluj matricu iz tabele r_export
// ----------------------------------------------
static function _obr_2_arr( aArr )
select r_export
go top

do while !EOF()
	
	AADD( aArr, { field->godina, ;
		field->mjesec, ;
		field->idradn, ;
		field->naziv, ;
		field->sati, ;
		field->prihod, ;
		field->bruto, ;
		field->neto, ;
		field->dop_pio, ;
		field->dop_zdr, ;
		field->dop_nez, ;
		field->dop_uk, ;
		field->osn_por, ;
		field->izn_por, ;
		field->tp_1, ;
		field->tp_2, ;
		field->tp_3, ;
		field->tp_4, ;
		field->tp_5 } )

	skip
enddo

return


// -----------------------------
// otvori tabele
// -----------------------------
static function o_tables()
O_LD
O_RADN
O_KONTO
O_RADSIHT
O_DOPR
O_POR
return


// ------------------------------------------------------------
// generisanje reporta
// ------------------------------------------------------------
static function _gen_rpt( nGod_od, nMj_od, cRadnik, cGroup, aObr )

// kreiraj r_export tabelu
cre_tmp_tbl()

o_tables()

select radsiht

// sortiraj sihtarice
sort_siht( nGod_od, nMj_od, cRadnik, cGroup )
set order to tag "1"
go top


do while !EOF()
	
	cGr_siht := field->idkonto
	cGr_naz := g_gr_naz( cGr_siht )
	cRa_siht := field->idradn
	// ovo su sati po sihtarici
	nSiht_sati := field->izvrseno
	nRa_mj := field->mjesec
	nRa_god := field->godina

	// pronadji radnika u matrici
	nTmp := ASCAN( aObr, { |xVal| xVal[1] == nRa_god .and. ;
		xVal[2] == nRa_mj .and. xVal[3] == cRa_siht } )

	if nTmp == 0
		// nisam nasao
		skip
		loop
	endif
	
	cRa_naz := aObr[ nTmp, 4 ]
	nSati := aObr[ nTmp, 5 ]
	nPrih := aObr[ nTmp, 6 ]
	nBruto := aObr[ nTmp, 7 ]
	nNeto := aObr[ nTmp, 8 ]
	nDop_pio := aObr[ nTmp, 9 ]
	nDop_zdr := aObr[ nTmp, 10 ]
	nDop_nez := aObr[ nTmp, 11 ]
	nDop_uk := aObr[ nTmp, 12 ]
	nOsn_por := aObr[ nTmp, 13 ]
	nIzn_por := aObr[ nTmp, 14 ]
	nTp_1 := aObr[ nTmp, 15 ]
	nTp_2 := aObr[ nTmp, 16 ]
	nTp_3 := aObr[ nTmp, 17 ]
	nTp_4 := aObr[ nTmp, 18 ]
	nTp_5 := aObr[ nTmp, 19 ]

	select r_export
	append blank
	
	replace field->mjesec with nRa_mj
	replace field->godina with nRa_god
	replace field->idradn with cRa_siht
	replace field->r_naz with _rad_ime( cRa_siht )
	replace field->naziv with cRa_naz
	replace field->group with cGr_siht
	replace field->gr_naz with cGr_naz
	replace field->sati with nSiht_sati
	replace field->prihod with _calc_val( nPrih, nSati, nSiht_sati ) 
	replace field->bruto with _calc_val( nBruto, nSati, nSiht_sati )
	replace field->neto with _calc_val( nNeto, nSati, nSiht_sati )
	replace field->dop_pio with _calc_val( nDop_pio, nSati, nSiht_sati )
	replace field->dop_zdr with _calc_val( nDop_zdr, nSati, nSiht_sati )
	replace field->dop_nez with _calc_val( nDop_nez, nSati, nSiht_sati )
	replace field->dop_uk with _calc_val( nDop_uk, nSati, nSiht_sati )
	replace field->osn_por with _calc_val( nOsn_por, nSati, nSiht_sati )
	replace field->izn_por with _calc_val( nIzn_por, nSati, nSiht_sati )
	replace field->tp_1 with _calc_val( nTp_1, nSati, nSiht_sati )
	replace field->tp_2 with _calc_val( nTp_2, nSati, nSiht_sati )
	replace field->tp_3 with _calc_val( nTp_3, nSati, nSiht_sati )
	replace field->tp_4 with _calc_val( nTp_4, nSati, nSiht_sati )
	replace field->tp_5 with _calc_val( nTp_5, nSati, nSiht_sati )

	select radsiht	
	skip

enddo

return


// -------------------------------------------------------
// kalkulisi iznos po novoj satnici
// -------------------------------------------------------
static function _calc_val( nVal, nSati, nNSati )
local nRet := 0

nRet := ( nNSati / nSati ) * nVal

return nRet


// -------------------------------------------
// vraca linije i header
// -------------------------------------------
static function _g_line( cLine )

cLine := REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 8)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)

cTxt := PADR("R.br", 5)
cTxt += SPACE(1)
cTxt += PADR("Ime i prezime radnika", 30)
cTxt += SPACE(1)
cTxt += PADR("Sati", 8)
cTxt += SPACE(1)
cTxt += PADR("Bruto", 12)
cTxt += SPACE(1)
cTxt += PADR("Neto", 12)
cTxt += SPACE(1)
cTxt += PADR("Dopr.PIO", 12)
cTxt += SPACE(1)
cTxt += PADR("Dopr.ZDR", 12)
cTxt += SPACE(1)
cTxt += PADR("Dopr.NEZ", 12)
cTxt += SPACE(1)
cTxt += PADR("Porez", 12)

if !EMPTY( __tp1 )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( __tp1, 12 )
endif
if !EMPTY( __tp2 )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( __tp2, 12 )
endif
if !EMPTY( __tp3 )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( __tp3, 12 )
endif
if !EMPTY( __tp4 )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( __tp4, 12 )
endif
if !EMPTY( __tp5 )
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( __tp5, 12 )
endif

? cLine
? cTxt
? cLine

return




// ----------------------------------------------------------
// printanje reporta
// ----------------------------------------------------------
static function _print_rpt( )
local cLine
local nU_sati := 0
local nU_bruto := 0 
local nU_neto := 0
local nU_d_pio := 0
local nU_d_nez := 0
local nU_d_zdr := 0
local nU_i_por := 0
local nU_o_por := 0
local nU_tp_1 := 0
local nU_tp_2 := 0
local nU_tp_3 := 0
local nU_tp_4 := 0
local nU_tp_5 := 0
local nT_sati := 0
local nT_bruto := 0 
local nT_neto := 0
local nT_d_pio := 0
local nT_d_nez := 0
local nT_d_zdr := 0
local nT_i_por := 0
local nT_o_por := 0
local nT_tp_1 := 0
local nT_tp_2 := 0
local nT_tp_3 := 0
local nT_tp_4 := 0
local nT_tp_5 := 0
local nCol := 15

select r_export
set order to tag "1"
go top

START PRINT CRET

?
? "Pregled utroska po objektima za: ", STR(__mj_od) + "/" + STR(__god_od)
?

P_COND2

_g_line( @cLine ) 

nCnt := 0
do while !EOF()

	// n.str
	//if prow() > 64 
	//	FF
	//endif
	
	cGr_id := field->group

	nU_sati := 0
	nU_bruto := 0 
	nU_neto := 0
	nU_d_pio := 0
	nU_d_nez := 0
	nU_d_zdr := 0
	nU_i_por := 0
	nU_o_por := 0
	nU_tp_1 := 0
	nU_tp_2 := 0
	nU_tp_3 := 0
	nU_tp_4 := 0
	nU_tp_5 := 0

	? SPACE(1), "Objekat: ", ;
		"(" + cGr_id + ")", ;
		PADR( g_gr_naz( cGr_id ), 30 )

	do while !EOF() .and. field->group == cGr_id

		// n.str
		//if prow() > 64 
		//	FF
		//endif

		? PADL( ALLTRIM(STR(++nCnt)) + ".", 5 )
		@ prow(), pcol()+1 SAY PADR( _rad_ime(field->idradn), 30 )
		@ prow(), nCol:=pcol()+1 SAY STR(field->sati, 8, 2)
		@ prow(), pcol()+1 SAY STR(field->bruto, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->neto, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_pio, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_zdr, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_nez, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->izn_por, 12, 2)

		if !EMPTY( __tp1 )
			@ prow(), pcol()+1 SAY STR(field->tp_1, 12, 2)
		endif
		if !EMPTY( __tp2 )
			@ prow(), pcol()+1 SAY STR(field->tp_2, 12, 2)
		endif
		if !EMPTY( __tp3 )
			@ prow(), pcol()+1 SAY STR(field->tp_3, 12, 2)
		endif
		if !EMPTY( __tp4 )
			@ prow(), pcol()+1 SAY STR(field->tp_4, 12, 2)
		endif
		if !EMPTY( __tp5 )
			@ prow(), pcol()+1 SAY STR(field->tp_5, 12, 2)
		endif

		nU_sati += field->sati
		nU_bruto += field->bruto
		nU_neto += field->neto
		nU_d_pio += field->dop_pio
		nU_d_nez += field->dop_nez
		nU_d_zdr += field->dop_zdr
		nU_i_por += field->izn_por
		nU_o_por += field->osn_por
		nU_tp_1 += field->tp_1
		nU_tp_2 += field->tp_2
		nU_tp_3 += field->tp_3
		nU_tp_4 += field->tp_4
		nU_tp_5 += field->tp_5
		
		nT_sati += field->sati
		nT_bruto += field->bruto
		nT_neto += field->neto
		nT_d_pio += field->dop_pio
		nT_d_nez += field->dop_nez
		nT_d_zdr += field->dop_zdr
		nT_i_por += field->izn_por
		nT_o_por += field->osn_por
		nT_tp_1 += field->tp_1
		nT_tp_2 += field->tp_2
		nT_tp_3 += field->tp_3
		nT_tp_4 += field->tp_4
		nT_tp_5 += field->tp_5

		skip
	enddo

	// total po grupi....
	? cLine
	? PADL( "Ukupno " + cGr_id + ":", 25 )
	@ prow(), nCol SAY STR( nU_sati, 8, 2 )
	@ prow(), pcol()+1 SAY STR( nU_bruto, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_neto, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_d_pio, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_d_zdr, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_d_nez, 12, 2 )
	@ prow(), pcol()+1 SAY STR( nU_i_por, 12, 2 )
	
	if !EMPTY( __tp1 )
		@ prow(), pcol()+1 SAY STR( nU_tp_1, 12, 2 )
	endif
	if !EMPTY( __tp2 )
		@ prow(), pcol()+1 SAY STR( nU_tp_2, 12, 2 )
	endif
	if !EMPTY( __tp3 )
		@ prow(), pcol()+1 SAY STR( nU_tp_3, 12, 2 )
	endif
	if !EMPTY( __tp4 )
		@ prow(), pcol()+1 SAY STR( nU_tp_4, 12, 2 )
	endif
	if !EMPTY( __tp5 )
		@ prow(), pcol()+1 SAY STR( nU_tp_5, 12, 2 )
	endif
	
	? 

enddo

// total za sve....
? cLine
? "UKUPNO: "
@ prow(), nCol SAY STR( nT_sati, 8, 2 )
@ prow(), pcol()+1 SAY STR( nT_bruto, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_neto, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_d_pio, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_d_zdr, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_d_nez, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_i_por, 12, 2 )
	
if !EMPTY( __tp1 )
	@ prow(), pcol()+1 SAY STR( nT_tp_1, 12, 2 )
endif
if !EMPTY( __tp2 )
	@ prow(), pcol()+1 SAY STR( nT_tp_2, 12, 2 )
endif
if !EMPTY( __tp3 )
	@ prow(), pcol()+1 SAY STR( nT_tp_3, 12, 2 )
endif
if !EMPTY( __tp4 )
	@ prow(), pcol()+1 SAY STR( nT_tp_4, 12, 2 )
endif
if !EMPTY( __tp5 )
	@ prow(), pcol()+1 SAY STR( nT_tp_5, 12, 2 )
endif
	
? cLine

FF
END PRINT

return


// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
static function cre_tmp_tbl()
local aDbf := {}

AADD(aDbf,{ "IDRADN", "C", 6, 0 })
AADD(aDbf,{ "R_NAZ", "C", 30, 0 })
AADD(aDbf,{ "GROUP", "C", 7, 0 })
AADD(aDbf,{ "GR_NAZ", "C", 50, 0 })
AADD(aDbf,{ "NAZIV", "C", 15, 0 })
AADD(aDbf,{ "MJESEC", "N", 2, 0 })
AADD(aDbf,{ "GODINA", "N", 4, 0 })
AADD(aDbf,{ "TP_1", "N", 12, 2 })
AADD(aDbf,{ "TP_2", "N", 12, 2 })
AADD(aDbf,{ "TP_3", "N", 12, 2 })
AADD(aDbf,{ "TP_4", "N", 12, 2 })
AADD(aDbf,{ "TP_5", "N", 12, 2 })
AADD(aDbf,{ "SATI", "N", 12, 2 })
AADD(aDbf,{ "PRIHOD", "N", 12, 2 })
AADD(aDbf,{ "BRUTO", "N", 12, 2 })
AADD(aDbf,{ "DOP_PIO", "N", 12, 2 })
AADD(aDbf,{ "DOP_ZDR", "N", 12, 2 })
AADD(aDbf,{ "DOP_NEZ", "N", 12, 2 })
AADD(aDbf,{ "DOP_UK", "N", 12, 2 })
AADD(aDbf,{ "NETO", "N", 12, 2 })
AADD(aDbf,{ "OSN_POR", "N", 12, 2 })
AADD(aDbf,{ "IZN_POR", "N", 12, 2 })
AADD(aDbf,{ "UKUPNO", "N", 12, 2 })

t_exp_create( aDbf )

O_R_EXP

// index on ......
index on group + idradn + STR(godina,4) + STR(mjesec,2) tag "1"

return



