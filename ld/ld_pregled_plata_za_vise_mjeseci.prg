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

// ---------------------------------------
// otvara potrebne tabele
// ---------------------------------------
static function o_tables()

O_OBRACUNI
O_PAROBR
O_PARAMS
O_LD_RJ
O_RADN
O_KBENEF
O_VPOSLA
O_TIPPR
O_KRED
O_DOPR
O_POR
O_LD

return

// ---------------------------------------------------------
// sortiranje tabele LD
// ---------------------------------------------------------
static function ld_sort( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, cObr )
local cFilter := ""
private cObracun := cObr

if !EMPTY( cObracun )
	cFilter += "obr == " + _filter_quote( cObracun )
endif

if !EMPTY( cRj )

	if !EMPTY( cFilter )
		cFilter += " .and. "
	endif
	
	cFilter += Parsiraj( cRj, "IDRJ" )

endif

if !EMPTY( cFilter )
	set filter to &cFilter
	go top
endif

if EMPTY( cRadnik ) 
	INDEX ON STR(godina) + SortPrez(idradn) + STR(mjesec) + idrj TO "tmpld"
	go top
	seek STR( cGodina, 4 )
else
	set order to tag ( TagVO( "2" ) )
	go top
	seek STR( cGodina, 4 ) + STR( cMjesec, 2 ) + cObracun + cRadnik
endif

return


// ---------------------------------------------
// upisivanje podatka u pomocnu tabelu za rpt
// ---------------------------------------------
static function _ins_tbl( nGodina, nMjesec, cRadnik, cIdRj, cObrZa, cIme, ;
		nSati, nR_sati, ;
		nB_sati, nPrim, nBruto, nDoprIz, nDopPio, ;
		nDopZdr, nDopNez, nOporDoh, nLOdb, nPorez, nNetoBp, nNeto, ;
		nR_neto, nB_neto, ;
		nOdbici, nIsplata, nDop4, nDop5, nDop6 )

local nTArea := SELECT()

O_R_EXP
select r_export
append blank

replace godina with nGodina
replace mjesec with nMjesec
replace idrj with cIdRj
replace idradn with cRadnik
replace obr_za with cObrZa
replace naziv with cIme
replace sati with nSati
replace b_sati with nB_Sati
replace r_sati with nR_Sati
replace neto with nNeto
replace b_neto with nB_Neto
replace r_neto with nR_Neto
replace netobp with nNetoBp
replace prim with nPrim
replace bruto with nBruto
replace dop_iz with nDoprIz
replace dop_pio with nDopPio
replace dop_zdr with nDopZdr
replace dop_nez with nDopNez
replace dop_4 with nDop4
replace dop_5 with nDop5
replace dop_6 with nDop6
replace l_odb with nLOdb
replace izn_por with nPorez
replace opordoh with nOporDoh
replace odbici with nOdbici
replace isplata with nIsplata

select (nTArea)
return



// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
static function cre_tmp_tbl()
local aDbf := {}

AADD(aDbf,{ "IDRJ", "C", 2, 0 })
AADD(aDbf,{ "GODINA", "N", 4, 0 })
AADD(aDbf,{ "MJESEC", "N", 2, 0 })
AADD(aDbf,{ "IDRADN", "C", 6, 0 })
AADD(aDbf,{ "OBR_ZA", "C", 15, 0 })
AADD(aDbf,{ "NAZIV", "C", 20, 0 })
AADD(aDbf,{ "SATI", "N", 12, 2 })
AADD(aDbf,{ "R_SATI", "N", 12, 2 })
AADD(aDbf,{ "B_SATI", "N", 12, 2 })
AADD(aDbf,{ "PRIM", "N", 12, 2 })
AADD(aDbf,{ "NETO", "N", 12, 2 })
AADD(aDbf,{ "R_NETO", "N", 12, 2 })
AADD(aDbf,{ "B_NETO", "N", 12, 2 })
AADD(aDbf,{ "NETOBP", "N", 12, 2 })
AADD(aDbf,{ "BRUTO", "N", 12, 2 })
AADD(aDbf,{ "DOP_IZ", "N", 12, 2 })
AADD(aDbf,{ "DOP_PIO", "N", 12, 2 })
AADD(aDbf,{ "DOP_ZDR", "N", 12, 2 })
AADD(aDbf,{ "DOP_NEZ", "N", 12, 2 })
AADD(aDbf,{ "DOP_4", "N", 12, 2 })
AADD(aDbf,{ "DOP_5", "N", 12, 2 })
AADD(aDbf,{ "DOP_6", "N", 12, 2 })
AADD(aDbf,{ "IZN_POR", "N", 12, 2 })
AADD(aDbf,{ "OPORDOH", "N", 12, 2 })
AADD(aDbf,{ "L_ODB", "N", 12, 2 })
AADD(aDbf,{ "ODBICI", "N", 12, 2 })
AADD(aDbf,{ "ISPLATA", "N", 12, 2 })

t_exp_create( aDbf )

return


// ------------------------------------------
// obracunski list radnika
// ------------------------------------------
function ppl_vise()
local nC1:=20
local i
local cTPNaz
local cRj := SPACE(60)
local cRadnik := SPACE(_LR_) 
local cIdRj
local cMjesec
local cMjesecDo
local cGodina
local cDoprPio := "70"
local cDoprZdr := "80"
local cDoprNez := "90"
local cDoprD4 := cDoprD5 := cDoprD6 := SPACE(2)
local cObracun := gObracun
local cM4_prim := SPACE(100)
local cTotal := "N"

// kreiraj pomocnu tabelu
cre_tmp_tbl()

cIdRj := gRj
cMjesec := gMjesec
cGodina := gGodina
cMjesecDo := cMjesec

// otvori tabele
o_tables()

Box("#PREGLED PLATA ZA VISE MJESECI (M4)", 16, 75)

@ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
@ m_x + 2, m_y + 2 SAY "Za mjesece od:" GET cMjesec pict "99"
@ m_x + 2, col() + 2 SAY "do:" GET cMjesecDo pict "99" ;
	VALID cMjesecDo >= cMjesec
@ m_x + 3, m_y + 2 SAY "Godina: " GET cGodina pict "9999"

if lViseObr
  	@ m_x+3,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif

@ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
	VALID EMPTY(cRadnik) .or. P_RADN(@cRadnik)
@ m_x + 6, m_y + 2 SAY "Dodatni doprinosi za prikaz na izvjestaju: " 
@ m_x + 7, m_y + 2 SAY " Sifra dodatnog doprinosa 1 : " GET cDoprPio 
@ m_x + 8, m_y + 2 SAY " Sifra dodatnog doprinosa 2 : " GET cDoprZdr
@ m_x + 9, m_y + 2 SAY " Sifra dodatnog doprinosa 3 : " GET cDoprNez
@ m_x + 10, m_y + 2 SAY " Sifra dodatnog doprinosa 4 : " GET cDoprD4 
@ m_x + 11, m_y + 2 SAY " Sifra dodatnog doprinosa 5 : " GET cDoprD5
@ m_x + 12, m_y + 2 SAY " Sifra dodatnog doprinosa 6 : " GET cDoprD6

@ m_x + 14, m_y + 2 SAY "Izdvojena primanja za M4 (npr. 18;24;):" ;
	GET cM4_prim PICT "@S20"

@ m_x + 16, m_y + 2 SAY "Prikazati ukupno za sve mjesece (D/N)" ;
	GET cTotal PICT "@!" VALID cTotal $ "DN"

read
	
clvbox()
	
ESC_BCR

BoxC()

if lastkey() == K_ESC
	return
endif

select ld

// sortiraj tabelu i postavi filter
ld_sort( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, cObracun )

// nafiluj podatke obracuna
fill_data( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, ;
	cDoprPio, cDoprZdr, cDoprNez, cObracun, cDoprD4, cDoprD5, cDoprD6, ;
	cM4_prim, cTotal )

if cTotal == "N"
	// printaj izvjestaj
	ppv_print( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, ;
		cDoprPio, cDoprZdr, cDoprNez, cDoprD4, cDoprD5, cDoprD6 )
else
	// printaj izvjestaj
	ppv_total( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, ;
		cDoprPio, cDoprZdr, cDoprNez, cDoprD4, cDoprD5, cDoprD6 )
endif

return



// ----------------------------------------------
// stampa pregleda plata za vise mjeseci - total
// ----------------------------------------------
static function ppv_total( cRj, cGodina, cMjOd, cMjDo, cRadnik, ;
	cDop1, cDop2, cDop3, cDop4, cDop5, cDop6 )

local cT_radnik := ""
local cLine := ""

O_R_EXP
select r_export
index on STR(godina,4) + STR(mjesec,2) to "1" 
go top

START PRINT CRET
?
? "#%LANDS#"
P_COND2

ppv_zaglavlje(cRj, cGodina, cMjOd, cMjDo, cRadnik )

cLine := ppv_header( cRadnik, cDop1, cDop2, cDop3, cDop4, cDop5, cDop6 )

nUSati := 0
nUNeto := 0
nUNetoBP := 0
nUPrim := 0
nUBruto := 0
nUDoprPio := 0
nUDoprZdr := 0
nUDoprNez := 0
nUDoprD4 := 0
nUDoprD5 := 0
nUDoprD6 := 0
nUDoprIZ := 0
nUPorez := 0
nUOdbici := 0
nULicOdb := 0
nUIsplata := 0
nUR_sati := 0
nUR_izn := 0
nUB_sati := 0
nUB_izn := 0

nTUSati := 0
nTUNeto := 0
nTUNetoBP := 0
nTUPrim := 0
nTUBruto := 0
nTUDoprPio := 0
nTUDoprZdr := 0
nTUDoprNez := 0
nTUDoprD4 := 0
nTUDoprD5 := 0
nTUDoprD6 := 0
nTUDoprIZ := 0
nTUPorez := 0
nTUOdbici := 0
nTULicOdb := 0
nTUIsplata := 0
nTUR_sati := 0
nTUR_izn := 0
nTUB_sati := 0
nTUB_izn := 0

nRbr := 0
nPoc := 10
nCount := 0

do while !EOF()

	nSeek_god := field->godina
	nSeek_mj := field->mjesec

	nUSati := 0
	nUPrim := 0
	nUBruto := 0
	nUDoprIz := 0
	nULicOdb := 0
	nUPorez := 0
	nUNetobp := 0
	nUNeto := 0
	nUOdbici := 0
	nUIsplata := 0
	nUDoprPio := 0
	nUDoprZdr := 0
	nUDoprNez := 0
	nUDoprD4 := 0
	nUDoprD5 := 0
	nUDoprD6 := 0
	nUR_sati := 0
	nUR_izn := 0
	nUB_sati := 0
	nUB_izn := 0

	do while !EOF() .and. field->godina = nSeek_god .and. ;
		field->mjesec = nSeek_mj

		// saberi sve za jedan mjesec
		// svi radnici, sve radne jedinice

		nUSati += sati
		nUPrim += prim
		nUBruto += bruto
		nUDoprIz += dop_iz
		nULicOdb += l_odb
		nUPorez += izn_por
		nUNetobp += netobp
		nUNeto += neto
		nUOdbici += odbici
		nUIsplata += isplata
		nUDoprPio += dop_pio
		nUDoprZdr += dop_zdr
		nUDoprNez += dop_nez
		nUDoprD4 += dop_4
		nUDoprD5 += dop_5
		nUDoprD6 += dop_6
		
		if ( field->b_neto <> 0 )
			nUR_sati += field->r_sati
			nUR_izn += field->r_neto
			nUB_sati += field->b_sati
			nUB_izn += field->b_neto

		else
			nUR_sati += field->sati
			nUR_izn += field->netobp
		endif
	
		skip
	enddo
	
	? STR(++nRbr, 4) + "."

	@ prow(), pcol()+1 SAY PADR( ALLTRIM(STR(nSeek_god, 4)), 7)

	@ prow(), pcol()+1 SAY PADR( ld_naziv_mjeseca(nSeek_mj, nSeek_god, ;
		.f., .t. ), 20 )

	@ prow(), nPoc:=pcol()+1 SAY STR(nUSati,12,2)

	@ prow(), pcol()+1 SAY STR(nUPrim,12,2) 
	
	@ prow(), pcol()+1 SAY STR(nUBruto,12,2)

	@ prow(), pcol()+1 SAY STR(nUDopriz,12,2)

	@ prow(), pcol()+1 SAY STR(nULicOdb,12,2)

	@ prow(), pcol()+1 SAY STR(nUPorez,12,2)
	
	@ prow(), nNBP_pt := pcol()+1 SAY STR(nUNetobp,12,2)

	@ prow(), pcol()+1 SAY STR(nUNeto,12,2)

	@ prow(), pcol()+1 SAY STR(nUOdbici,12,2)

	@ prow(), pcol()+1 SAY STR(nUIsplata,12,2)
	
	if !EMPTY(cDop1)
		@ prow(), pcol()+1 SAY STR(nUDoprPio,12,2)
	endif

	if !EMPTY(cDop2)
		@ prow(), pcol()+1 SAY STR(nUDoprZdr,12,2)
	endif

	if !EMPTY(cDop3)
		@ prow(), pcol()+1 SAY STR(nUDoprNez,12,2)
	endif
	
	if !EMPTY( cDop4 )
		@ prow(), pcol()+1 SAY STR(nUDoprD4,12,2)
	endif
	
	if !EMPTY( cDop5 )
		@ prow(), pcol()+1 SAY STR(nUDoprD5,12,2)
	endif
	
	if !EMPTY( cDop6 )
		@ prow(), pcol()+1 SAY STR(nUDoprD6,12,2)
	endif

	nTUSati += nUsati
	nTUPrim += nUprim
	nTUBruto += nUbruto
	nTUDoprIz += nUdopriz
	nTULicOdb += nULicOdb
	nTUPorez += nUPorez
	nTUNetobp += nUNetobp
	nTUNeto += nUneto
	nTUOdbici += nUodbici
	nTUIsplata += nUisplata
	nTUDoprPio += nUDoprpio
	nTUDoprZdr += nUDoprzdr
	nTUDoprNez += nUDoprnez
	nTUDoprD4 += nUDoprD4
	nTUDoprD5 += nUDoprD5
	nTUDoprD6 += nUDoprD6
		
	if ( nUb_izn <> 0 )

		// ovo je za drugi red izvjestaja...
		// redovan rad
		?
		@ prow(), nPoc - 3 SAY "r: " + STR(nUR_sati,12,2)
		@ prow(), nNBP_pt SAY STR(nUR_izn,12,2)
	
		nTUR_sati += nUR_sati
		nTUR_izn += nUR_izn

		// bolovanja ...
		?
		@ prow(), nPoc -3 SAY "b: " + STR(nUb_sati,12,2)
		@ prow(), nNBP_pt SAY STR(nUb_izn,12,2)
		
		nTUB_sati += nUb_sati
		nTUB_izn += nUb_izn

	else
		nTUR_sati += nUSati
		nTUR_izn += nUNetobp
	endif

	++nCount

enddo

? cLine

? "UKUPNO:"
@ prow(), nPoc SAY STR(nTUSati,12,2)
@ prow(), pcol()+1 SAY STR(nTUPrim,12,2)
@ prow(), pcol()+1 SAY STR(nTUBruto,12,2)
@ prow(), pcol()+1 SAY STR(nTUDoprIz,12,2)
@ prow(), pcol()+1 SAY STR(nTULicOdb,12,2)
@ prow(), pcol()+1 SAY STR(nTUPorez,12,2)
@ prow(), pcol()+1 SAY STR(nTUNetoBP,12,2)
@ prow(), pcol()+1 SAY STR(nTUNeto,12,2)
@ prow(), pcol()+1 SAY STR(nTUOdbici,12,2)
@ prow(), pcol()+1 SAY STR(nTUIsplata,12,2)

if !EMPTY(cDop1)
	@ prow(), pcol()+1 SAY STR(nTUDoprPio,12,2)
endif

if !EMPTY(cDop2)
	@ prow(), pcol()+1 SAY STR(nTUDoprZdr,12,2)
endif

if !EMPTY(cDop3)
	@ prow(), pcol()+1 SAY STR(nTUDoprNez,12,2)
endif

if !EMPTY(cDop4)
	@ prow(), pcol()+1 SAY STR(nTUDoprD4,12,2)
endif

if !EMPTY(cDop5)
	@ prow(), pcol()+1 SAY STR(nTUDoprD5,12,2)
endif

if !EMPTY(cDop6)
	@ prow(), pcol()+1 SAY STR(nTUDoprD6,12,2)
endif

// ako ima bolovanja itd...
if ( nTUB_izn <> 0 )

	// redovan rad
	? 
	@ prow(), nPoc - 3 SAY "r: " + STR( nTUR_sati , 12, 2 )
	@ prow(), nNBP_pt SAY STR( nTUR_izn , 12, 2 )
	
	// bolovanja
	? 
	@ prow(), nPoc - 3 SAY "b: " + STR( nTUB_sati , 12, 2 )
	@ prow(), nNBP_pt SAY STR( nTUB_izn , 12, 2 )

endif

? cLine

FF
END PRINT

return


// ----------------------------------------------
// stampa pregleda plata za vise mjeseci
// ----------------------------------------------
static function ppv_print( cRj, cGodina, cMjOd, cMjDo, cRadnik, ;
	cDop1, cDop2, cDop3, cDop4, cDop5, cDop6 )

local cT_radnik := ""
local cLine := ""

O_R_EXP
select r_export
go top

START PRINT CRET
?
? "#%LANDS#"
P_COND2

ppv_zaglavlje(cRj, cGodina, cMjOd, cMjDo, cRadnik )

cLine := ppv_header( cRadnik, cDop1, cDop2, cDop3, cDop4, cDop5, cDop6 )

nUSati := 0
nUNeto := 0
nUNetoBP := 0
nUPrim := 0
nUBruto := 0
nUDoprPio := 0
nUDoprZdr := 0
nUDoprNez := 0
nUDoprD4 := 0
nUDoprD5 := 0
nUDoprD6 := 0
nUDoprIZ := 0
nUPorez := 0
nUOdbici := 0
nULicOdb := 0
nUIsplata := 0
nUR_sati := 0
nUR_izn := 0
nUB_sati := 0
nUB_izn := 0

nRbr := 0
nPoc := 10
nCount := 0

do while !EOF()
	
	? STR(++nRbr, 4) + "."

	if !EMPTY( cRadnik )
		@ prow(), pcol()+1 SAY PADR( obr_za, 7 )
	else
		@ prow(), pcol()+1 SAY PADR( idradn, 7 )
	endif

	@ prow(), pcol()+1 SAY naziv

	@ prow(), nPoc:=pcol()+1 SAY STR(sati,12,2)
	nUSati += sati

	@ prow(), pcol()+1 SAY STR(prim,12,2) 
	nUPrim += prim
	
	@ prow(), pcol()+1 SAY STR(bruto,12,2)
	nUBruto += bruto

	@ prow(), pcol()+1 SAY STR(dop_iz,12,2)
	nUDoprIz += dop_iz

	@ prow(), pcol()+1 SAY STR(l_odb,12,2)
	nULicOdb += l_odb

	@ prow(), pcol()+1 SAY STR(izn_por,12,2)
	nUPorez += izn_por
	
	@ prow(), nNBP_pt := pcol()+1 SAY STR(netobp,12,2)
	nUNetobp += netobp

	@ prow(), pcol()+1 SAY STR(neto,12,2)
	nUNeto += neto

	@ prow(), pcol()+1 SAY STR(odbici,12,2)
	nUOdbici += odbici

	@ prow(), pcol()+1 SAY STR(isplata,12,2)
	nUIsplata += isplata
	
	if !EMPTY(cDop1)
		@ prow(), pcol()+1 SAY STR(dop_pio,12,2)
		nUDoprPio += dop_pio
	endif

	if !EMPTY(cDop2)
		@ prow(), pcol()+1 SAY STR(dop_zdr,12,2)
		nUDoprZdr += dop_zdr
	endif

	if !EMPTY(cDop3)
		@ prow(), pcol()+1 SAY STR(dop_nez,12,2)
		nUDoprNez += dop_nez
	endif
	
	if !EMPTY( cDop4 )
		@ prow(), pcol()+1 SAY STR(dop_4,12,2)
		nUDoprD4 += dop_4
	endif
	
	if !EMPTY( cDop5 )
		@ prow(), pcol()+1 SAY STR(dop_5,12,2)
		nUDoprD5 += dop_5
	endif
	
	if !EMPTY( cDop6 )
		@ prow(), pcol()+1 SAY STR(dop_6,12,2)
		nUDoprD6 += dop_6
	endif

	if ( field->b_neto <> 0 )

		// ovo je za drugi red izvjestaja...
		// redovan rad
		?
		@ prow(), nPoc - 3 SAY "r: " + STR(field->r_sati,12,2)
		@ prow(), nNBP_pt SAY STR(field->r_neto,12,2)
	
		nUR_sati += field->r_sati
		nUR_izn += field->r_neto

		// bolovanja ...
		?
		@ prow(), nPoc -3 SAY "b: " + STR(field->b_sati,12,2)
		@ prow(), nNBP_pt SAY STR(field->b_neto,12,2)
		
		nUB_sati += field->b_sati
		nUB_izn += field->b_neto

	else
		nUR_sati += field->sati
		nUR_izn += field->netobp
	endif

	++nCount

	skip
enddo

? cLine

? "UKUPNO:"
@ prow(), nPoc SAY STR(nUSati,12,2)
@ prow(), pcol()+1 SAY STR(nUPrim,12,2)
@ prow(), pcol()+1 SAY STR(nUBruto,12,2)
@ prow(), pcol()+1 SAY STR(nUDoprIz,12,2)
@ prow(), pcol()+1 SAY STR(nULicOdb,12,2)
@ prow(), pcol()+1 SAY STR(nUPorez,12,2)
@ prow(), pcol()+1 SAY STR(nUNetoBP,12,2)
@ prow(), pcol()+1 SAY STR(nUNeto,12,2)
@ prow(), pcol()+1 SAY STR(nUOdbici,12,2)
@ prow(), pcol()+1 SAY STR(nUIsplata,12,2)

if !EMPTY(cDop1)
	@ prow(), pcol()+1 SAY STR(nUDoprPio,12,2)
endif

if !EMPTY(cDop2)
	@ prow(), pcol()+1 SAY STR(nUDoprZdr,12,2)
endif

if !EMPTY(cDop3)
	@ prow(), pcol()+1 SAY STR(nUDoprNez,12,2)
endif

if !EMPTY(cDop4)
	@ prow(), pcol()+1 SAY STR(nUDoprD4,12,2)
endif

if !EMPTY(cDop5)
	@ prow(), pcol()+1 SAY STR(nUDoprD5,12,2)
endif

if !EMPTY(cDop6)
	@ prow(), pcol()+1 SAY STR(nUDoprD6,12,2)
endif

// ako ima bolovanja itd...
if ( nUB_izn <> 0 )

	// redovan rad
	? 
	@ prow(), nPoc - 3 SAY "r: " + STR( nUR_sati , 12, 2 )
	@ prow(), nNBP_pt SAY STR( nUR_izn , 12, 2 )
	
	// bolovanja
	? 
	@ prow(), nPoc - 3 SAY "b: " + STR( nUB_sati , 12, 2 )
	@ prow(), nNBP_pt SAY STR( nUB_izn , 12, 2 )

endif

? cLine

FF
END PRINT

return


// ----------------------------------------
// stampa headera tabele
// ----------------------------------------
static function ppv_header( cRadnik, cDop1, cDop2, cDop3, ;
	cDop4, cDop5, cDop6 )
local aLines := {}
local aTxt := {}
local i 
local cLine := ""
local cTxt1 := ""
local cTxt2 := ""
local cTxt3 := ""
local cTxt4 := ""

AADD( aLines, { REPLICATE("-", 5) } )
AADD( aLines, { REPLICATE("-", 7) } )
AADD( aLines, { REPLICATE("-", 20) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )

if !EMPTY(cDop1)
	AADD( aLines, { REPLICATE("-", 12) } )
endif
if !EMPTY(cDop2)
	AADD( aLines, { REPLICATE("-", 12) } )
endif
if !EMPTY(cDop3)
	AADD( aLines, { REPLICATE("-", 12) } )
endif
if !EMPTY(cDop4)
	AADD( aLines, { REPLICATE("-", 12) } )
endif
if !EMPTY(cDop5)
	AADD( aLines, { REPLICATE("-", 12) } )
endif
if !EMPTY(cDop6)
	AADD( aLines, { REPLICATE("-", 12) } )
endif

AADD( aTxt, { "Red.", "br", "", "1" })
if !EMPTY( cRadnik )
	AADD( aTxt, { "Obr.", "za mj", "", "2" })
else
	AADD( aTxt, { "Sifra", "radn.", "", "2" })
endif
AADD( aTxt, { "Naziv", "radnika", "", "3" })
AADD( aTxt, { "Sati", "", "", "4" })
AADD( aTxt, { "Primanja", "", "", "5" })
AADD( aTxt, { "Bruto plata", "(5 x koef.)", "", "6" })
AADD( aTxt, { "Doprinos", "iz place", "( 31% )", "7" })
AADD( aTxt, { "Licni odbici", "", "", "8" })
AADD( aTxt, { "Porez", "na dohodak", "10%", "9" })
AADD( aTxt, { "Neto", "plata", "(6-7)", "10" })
AADD( aTxt, { "Na", "ruke", "(6-7-9)", "11" })
AADD( aTxt, { "Odbici", "", "", "12" })
AADD( aTxt, { "Za isplatu", "", "(11+12)", "13" })
if !EMPTY(cDop1)
	AADD( aTxt, { "Doprinos", "1", get_d_proc(cDop1), "14" })
endif
if !EMPTY(cDop2)
	AADD( aTxt, { "Doprinos", "2", get_d_proc(cDop2), "15" })
endif
if !EMPTY(cDop3)
	AADD( aTxt, { "Doprinos", "3", get_d_proc(cDop3), "16" })
endif
if !EMPTY(cDop4)
	AADD( aTxt, { "Doprinos", "4", get_d_proc(cDop4), "17" })
endif
if !EMPTY(cDop5)
	AADD( aTxt, { "Doprinos", "5", get_d_proc(cDop5), "18" })
endif
if !EMPTY(cDop6)
	AADD( aTxt, { "Doprinos", "6", get_d_proc(cDop6), "19" })
endif

for i := 1 to LEN( aLines )
	cLine += aLines[ i, 1 ] + SPACE(1)
next

for i := 1 to LEN( aTxt )
	
	// koliko je sirok tekst ?
	nTxtLen := LEN( aLines[i, 1] )

	// prvi red
	cTxt1 += PADC( "(" + aTxt[i, 4] + ")", nTxtLen ) + SPACE(1)
	cTxt2 += PADC( aTxt[i, 1], nTxtLen ) + SPACE(1)
	cTxt3 += PADC( aTxt[i, 2], nTxtLen ) + SPACE(1)
	cTxt4 += PADC( aTxt[i, 3], nTxtLen ) + SPACE(1)

next

// ispisi zaglavlje tabele
? cLine
? cTxt1
? cTxt2
? cTxt3
? cTxt4
? cLine

return cLine


// --------------------------------------
// vraca procenat doprinosa
// --------------------------------------
static function get_d_proc( cDop )
local cProc := ""
local nTmp
local nTArea := SELECT()

// daj za tip rada " "
nTmp := get_dopr( cDop, " " ) 

if nTmp <> 0
	cProc := ALLTRIM(STR(nTmp)) + " %"
endif

select (nTArea)

return cProc


// ----------------------------------------
// stampa zaglavlja izvjestaja
// ----------------------------------------
static function ppv_zaglavlje( cRj, cGodina, cMjOd, cMjDo, cRadnik )

? UPPER(gTS) + ":", gnFirma
?

if EMPTY(cRj)
	? Lokal("Pregled za sve RJ:")
else
	? Lokal("RJ:"), cRj
endif

?? SPACE(2) + Lokal("Mjesec od:"),str(cMjOd,2),"do:",str(cMjDo,2)
?? SPACE(4) + Lokal("Godina:"),str(cGodina,5)

if !EMPTY( cRadnik )
	? "Radnik: " + cRadnik
endif

return


// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
static function fill_data( cRj, cGodina, cMjesec, cMjesecDo, ;
	cRadnik, cDoprPio, cDoprZdr, cDoprNez, cObracun, cDop4, cDop5, cDop6, ;
	cM4_prim, cTotal )
local i
local cPom
local lInRS := .f.
local nNetoBP := 0
local nUNetobp := 0
local o
local nR_s_off
local nR_i_off
local nB_s_off
local nB_i_off

if cTotal == nil
	cTotal := "N"
endif

select ld

do while !eof()

	if ld_date( ld->godina, ld->mjesec ) < ld_date( cGodina, cMjesec )  
		skip
		loop
	endif

	if ld_date( ld->godina, ld->mjesec ) > ld_date( cGodina, cMjesecdo )
		skip
		loop
	endif

	cT_radnik := field->idradn

	lInRS := radnik_iz_rs(radn->idopsst, radn->idopsrad) 
	
	if !EMPTY(cRadnik)
		if cT_radnik <> cRadnik
			skip
			loop
		endif
	endif
	
	cTipRada := g_tip_rada( ld->idradn, ld->idrj )
	cOpor := g_oporeziv( ld->idradn, ld->idrj ) 

	// samo pozicionira bazu PAROBR na odgovarajuci zapis
	ParObr( ld->mjesec, ld->godina, IF(lViseObr, ld->obr,), ld->idrj )

	select radn
	seek cT_radnik
	
	cT_rnaziv := ALLTRIM( radn->ime ) + " " + ALLTRIM( radn->naz )

	select ld

	nSati := 0
	nR_sati := 0
	nB_sati := 0
	nNeto := 0
	nR_neto := 0
	nB_neto := 0
	nUNeto := 0
	nPrim := 0
	nBruto := 0
	nUDopIz := 0
	nIDoprPio := 0
	nIDoprZdr := 0
	nIDoprNez := 0
	nIDoprD4 := 0
	nIDoprD5 := 0
	nIDoprD6 := 0
	nOdbici := 0
	nL_odb := 0
	nPorez := 0
	nIsplata := 0
	nUNetobp := 0
	nR_s_off := 0
	nR_i_off := 0
	nB_s_off := 0
	nB_i_off := 0
	nURad_izn := 0
	nUBol_izn := 0
	nUR_sati := 0
	nUB_sati := 0

	do while !eof() .and. field->idradn == cT_radnik

		if ld_date( field->godina, field->mjesec ) < ;
			ld_date( cGodina, cMjesec )  
			skip
			loop
		endif

		if ld_date( field->godina, field->mjesec ) > ;
			ld_date( cGodina, cMjesecdo )
			skip
			loop
		endif
	
		nF_mj := field->mjesec
		nF_god := field->godina

		cObr_za := ALLTRIM(STR(ld->mjesec)) + "/" + ;
			ALLTRIM(STR(ld->godina))

		cId_rj := ld->idrj

		// uvijek provjeri tip rada, ako ima vise obracuna
		cTipRada := g_tip_rada( ld->idradn, ld->idrj )
		cTrosk := radn->trosk
		
		ParObr( ld->mjesec, ld->godina, ;
			IF(lViseObr, ld->obr,), ld->idrj )

		nPrKoef := 0
		
		// proisani koeficijent
		if cTipRada == "S"
			nPrKoef := radn->sp_koef
		endif
		
		// bolovanje i redovan rad, sati, iznosi
		nB_i_off := 0
		nB_s_off := 0
		nR_i_off := 0
		nR_s_off := 0

		if !EMPTY( cM4_prim ) 
     		   for o:=1 to 60
       			cPom := IF( o>9, STR(o,2), "0"+STR(o,1) )
       			if ld->( FIELDPOS( "I" + cPom ) ) <= 0
         			EXIT
       			endif
       			nB_i_off += IF( cPom $ cM4_prim, LD->&("I"+cPom), 0 )
       			nB_s_off += IF( cPom $ cM4_prim, LD->&("S"+cPom), 0 )
     		   next
   		endif

		// primanja ?
		nPrim += field->uneto
		
		// odbici ?
		nOdbici += field->uodbici

		// sati ?
		nSati += field->usati
		
		// isplata ?
		nIsplata += field->uiznos

		// licni odbitak ?
		nLOdbitak := field->ulicodb
		nL_odb += nLOdbitak

		// radni sati ukupni
		if nB_i_off <> 0
			nR_s_off := ( field->usati - nB_s_off )
			nR_i_off := ( field->uneto - nB_i_off )
		else
			nR_s_off := ( field->usati )
			nR_i_off := ( field->uneto )
		endif

		// totali za bolovanje i radne sate
		nUR_sati += nR_s_off
		nUB_sati += nB_s_off

		// bruto sa troskovima 
		nBrutoST := bruto_osn( ld->uneto, cTipRada, ld->ulicodb, nPrKoef, cTrosk ) 
		

		// bruto bolovanja
		nBr_bol := bruto_osn( nB_i_off, cTipRada, ;
			ld->ulicodb, nPrKoef, cTrosk )
		// bruto rada
		nBr_rad := bruto_osn( nR_i_off, cTipRada, ;
			ld->ulicodb, nPrKoef, cTrosk )

		nTrosk := 0

		// ugovori o djelu
		if cTipRada == "U" .and. cTrosk <> "N"
			
			nTrosk := ROUND2( nBrutoST * (gUgTrosk / 100), gZaok2 )
			
			if lInRs == .t.
				nTrosk := 0
			endif
			
		endif

		// autorski honorar
		if cTipRada == "A" .and. cTrosk <> "N"
			
			nTrosk := ROUND2( nBrutoST * (gAhTrosk / 100), gZaok2 )
			
			if lInRs == .t.
				nTrosk := 0
			endif
			
		endif

		// bruto pojedinacno za radnika
		nBrPoj := nBrutoST - nTrosk

		nMBrutoST := nBrPoj

		if calc_mbruto()
			// minimalni bruto
			nMBrutoST := min_bruto( nBrPoj, ld->usati )
		endif
		
		// ukupni bruto
		nBruto += nBrPoj
		
		// ukupno dopr iz 31%
		nDoprIz := u_dopr_iz( nMBrutoST , cTipRada )
		nUDopIz += nDoprIz

		// doprinos za bol i rad...
		nDop_rad := u_dopr_iz( nBr_rad, cTipRada )
		nDop_bol := u_dopr_iz( nBr_bol, cTipRada )

		nURad_izn += ( nBr_rad - nDop_rad )
		nUBol_izn += ( nBr_bol - nDop_bol )

		// osnovica za porez
		nPorOsnP := ( nBrPoj - nDoprIz ) - nLOdbitak
		
		if nPorOsnP < 0 .or. !radn_oporeziv( ld->idradn, ld->idrj )
			nPorOsnP := 0
		endif
		
		// porez je ?
		nPorPoj := izr_porez( nPorOsnP, "B" )
		nPorez += nPorPoj
		
		// neto bez poreza
		nNetoBp := ( nBrPoj - nDoprIz )

		// neto isplata
		nNeto := ( nBrPoj - nDoprIz - nPorPoj )
		
		// minimalni neto uslov
		nNeto := min_neto( nNeto, ld->usati )
		
		nUNeto += nNeto
		nUNetobp += nNetoBp

		// ocitaj doprinose, njihove iznose
		if !EMPTY(cDoprPio)
			nDoprPIO := get_dopr( cDoprPIO, cTipRada ) 
			nIDoprPIO += round2(nMBrutoST * nDoprPIO / 100, gZaok2)
		endif

		if !EMPTY( cDoprZdr )
			nDoprZDR := get_dopr( cDoprZDR, cTipRada ) 
			nIDoprZDR += round2(nMBrutoST * nDoprZDR / 100, gZaok2)
		endif

		if !EMPTY( cDoprNez )
			nDoprNEZ := get_dopr( cDoprNEZ, cTipRada ) 
			nIDoprNEZ += round2(nMBrutoST * nDoprNEZ / 100, gZaok2)
		endif

		if !EMPTY( cDop4 )
			nDoprD4 := get_dopr( cDop4, cTipRada ) 
			nIDoprD4 += round2(nMBrutoST * nDoprD4 / 100, gZaok2)
		endif
		if !EMPTY( cDop4 )
			nDoprD5 := get_dopr( cDop5, cTipRada ) 
			nIDoprD5 += round2(nMBrutoST * nDoprD5 / 100, gZaok2)
		endif
		if !EMPTY( cDop4 )
			nDoprD6 := get_dopr( cDop6, cTipRada ) 
			nIDoprD6 += round2(nMBrutoST * nDoprD6 / 100, gZaok2)
		endif

		if cTotal == "D"
			// ubaci u tabelu podatke
			_ins_tbl( nF_god, ;
				nF_mj, ;
				cT_radnik, ;
				cId_rj, ;
				cObr_za, ;
				cT_rnaziv, ;
				nSati, ;
				nUR_sati, ;
				nUB_sati, ;
				nPrim, ;
				nBruto, ;
				nUDopIZ,;
				nIDoprPIO, ;
				nIDoprZDR, ;
				nIDoprNEZ, ;
				0, ;
				nL_Odb, ;
				nPorez, ;
				nUNetobp, ;
				nUNeto, ;
				nURad_izn, ;
				nUBol_izn, ;
				nOdbici, ;
				nIsplata, ;
				nIDoprD4, ;
				nIDoprD5, ;
				nIDoprD6 )
		
			// resetuj varijable
			nSati := 0
			nR_sati := 0
			nB_sati := 0
			nNeto := 0
			nR_neto := 0
			nB_neto := 0
			nUNeto := 0
			nPrim := 0
			nBruto := 0
			nUDopIz := 0
			nIDoprPio := 0
			nIDoprZdr := 0
			nIDoprNez := 0
			nIDoprD4 := 0
			nIDoprD5 := 0
			nIDoprD6 := 0
			nOdbici := 0
			nL_odb := 0
			nPorez := 0
			nIsplata := 0
			nUNetobp := 0
			nR_s_off := 0
			nR_i_off := 0
			nB_s_off := 0
			nB_i_off := 0
			nURad_izn := 0
			nUBol_izn := 0
			nUR_sati := 0
			nUB_sati := 0

		endif

		select ld
		skip

	enddo

	if cTotal == "N"
	   // ubaci u tabelu podatke
	   _ins_tbl( 0, 0, cT_radnik, ;
		cId_rj, ;
		cObr_za, ;
		cT_rnaziv, ;
		nSati, ;
		nUR_sati, ;
		nUB_sati, ;
		nPrim, ;
		nBruto, ;
		nUDopIZ,;
		nIDoprPIO, ;
		nIDoprZDR, ;
		nIDoprNEZ, ;
		0, ;
		nL_Odb, ;
		nPorez, ;
		nUNetobp, ;
		nUNeto, ;
		nURad_izn, ;
		nUBol_izn, ;
		nOdbici, ;
		nIsplata, ;
		nIDoprD4, ;
		nIDoprD5, ;
		nIDoprD6 )
	endif

enddo

return


