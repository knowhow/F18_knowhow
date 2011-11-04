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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

function MnuAdmin()
private opc
private opcexe
private Izbor

opc:={}
opcexe:={}
Izbor:=1

AADD(opc, "1. instalacija db-a                   ")
AADD(opcexe, {|| goModul:oDatabase:install()}) 
AADD(opc, "2. skip speed db-a")
AADD(opcexe, {|| SpeedSkip()}) 
AADD(opc, "3. security")
AADD(opcexe, {|| MnuSecMain()})
AADD(opc, "4. regeneracija fakt memo polja")
AADD(opcexe, {|| fa_memo_regen()})
AADD(opc, "5. regeneracija polja fakt->rbr")
AADD(opcexe, {|| fa_rbr_regen()})
AADD(opc, "6. regeneracija polja idpartner")
AADD(opcexe, {|| fa_part_regen()})
AADD(opc, "7. generisanja datuma otpr. isp.")
AADD(opcexe, {|| gen_dotpr()})
AADD(opc, "8. regeneracija doks iznos ukupno")
AADD(opcexe, {|| do_uk_regen()})
AADD(opc, "9. kontrola duplih partnera")
AADD(opcexe, {|| chk_dpartn()})
AADD(opc, "E. fakt export (r_exp) ")
AADD(opcexe, {|| fkt_export()})

Menu_SC("fain")

return

// regeneracija rednih brojeva u tabeli fakt
function fa_rbr_regen()
local nCounter
local cOldRbr
local cNewRbr
local nTotRecord

if !SigmaSif("RBRREG")
	return
endif

if Pitanje(,"Izvrsiti regeneraciju rednih brojeva (D/N)","N") == "N"
	return
endif

O_FAKT

select fakt
set order to tag 0

Box(,3,60)
@ m_x+1, m_y+2 SAY "Vrsim regeneraciju rednih brojeva fakt..."

nCounter := 0
nTotRecord := RecCount()

@ m_x+2, m_y+2 SAY "ukupni broj zapisa: " + ALLTRIM(STR(nTotRecord)) 

do while !EOF()

	cOldRbr := field->rbr
	cNewRbr := PADL(ALLTRIM(cOldRbr), 3)

	Scatter()
	_rbr := cNewRbr
	Gather()

	++nCounter

	@ m_x+3, m_y+2 SAY "obradjeno zapisa: " + ALLTRIM(STR(nCounter))
	
	skip
enddo

BoxC()

return


// --------------------------------------------------
// regeneracija polja ukupno u tabeli doks
// --------------------------------------------------
function do_uk_regen()
local cD_firma
local cD_tdok
local cD_brdok
local nCounter
local nCnt
local i
local aTest := {}
local nTotal
local nRabat
local nStavka
local nStRabat
local nStPorez

O_FAKT
O_FAKT_DOKS

if !SigmaSif("REGEN")
	return 
endif

if Pitanje(,"Izvrsiti regeneraciju (D/N)?","N") == "N"
	return
endif

select fakt_doks
set order to tag "1"
go top

nCounter := 0

Box(,3, 60)

@ 1 + m_x, 2 + m_y SAY "popunjavanje polja u toku..."

do while !EOF()
	
	cD_firma := field->idfirma
	cD_tdok := field->idtipdok
	cD_brdok := field->brdok

	// trenutno nam treba samo za dokumente "20"
	if cD_tdok <> "20" .and. cD_tdok <> "10"
		skip
		loop
	endif

	select fakt
	set order to tag "1"
	go top
	seek ( cD_firma + cD_tdok + cD_brdok )

	nTotal := 0
	nRabat := 0
	nStavka := 0
	nStPorez := 0
	nStRabat := 0

	do while !EOF() .and. field->idfirma + field->idtipdok + ;
		field->brdok == cD_firma + cD_tdok + cD_brdok
	
		// ukini polje poreza
		if field->porez <> 0
			replace field->porez with 0
		endif

    		if field->dindem == LEFT(ValBazna(), 3)
        		
			nStavka := Round( field->kolicina * ;
				field->cijena * PrerCij() * ;
				(1 - field->Rabat/100), ZAOKRUZENJE )
        	
			// rabat
        		nStRabat := ROUND( field->kolicina * ;
				field->cijena * PrerCij() * ;
				(field->rabat / 100), ZAOKRUZENJE)
        		
			// porez
        		nStPorez := ROUND( nStavka * (field->porez / 100), ;
				ZAOKRUZENJE )

			nTotal += nStavka + nStPorez
			nRabat += nStRabat
    		else
        		
			nStavka := round( field->kolicina * ;
				field->cijena * ;
				(PrerCij() / UBaznuValutu(datdok)) * ;
				(1-field->Rabat/100), ZAOKRUZENJE)
        		
			// rabat
        		nStRabat := ROUND( field->kolicina * ;
				field->cijena * ;
				( PrerCij() / UBaznuValutu(datdok)) * ;
				(field->Rabat/100), ZAOKRUZENJE)
        		// porez
        		nStPorez := ROUND(nStavka * ;
				(field->porez/100), ZAOKRUZENJE)
        		
			nTotal += nStavka + nStPorez
        		nRabat += nStRabat

    		endif
    		skip
  	enddo
  
	select fakt_doks

	// ubaci u tabelu doks ako je iznos razlicit
	if ROUND(field->iznos, ZAOKRUZENJE) <> ROUND(nTotal, ZAOKRUZENJE)
		// dodaj u kontrolnu matricu
		AADD( aTest, { field->idfirma + "-" + ;
				field->idtipdok + "-" + ;
				ALLTRIM(field->brdok), ;
				field->iznos, ;
				nTotal } )

		replace field->iznos with nTotal
		replace field->rabat with nRabat
	endif

	++nCounter

	@ 3+m_x, 2+m_y SAY "odradjeno zapisa " + ALLTRIM(STR(nCounter)) 

	skip

enddo

BoxC()

if LEN( aTest ) > 0
	// daj mi info o zamjenjenim iznosima
	START PRINT CRET
	
	? "Iznosi zamjenjeni na sljedecim dokumentima:"
	? "--------------------------------------------------------"
	
	nCnt := 1

	for i := 1 to LEN( aTest )
		? PADL( ALLTRIM( STR(nCnt) ), 5) + ".", ;
			aTest[i, 1], ;
			ROUND( aTest[i, 2], ZAOKRUZENJE), ;
			"=>", ;
			ROUND( aTest[i, 3], ZAOKRUZENJE)
		++ nCnt
	next

	FF
	END PRINT
endif

return



// --------------------------------------------------
// generisanje podataka za polja dat_isp, dat_otpr
// --------------------------------------------------
function gen_dotpr()
local cRbr
local aMemo
local cD_firma
local cD_tdok
local cD_brdok
local nCounter

O_FAKT
O_FAKT_DOKS

if doks->(FIELDPOS("dat_isp")) = 0
	msgbeep("potrebna modifikacija struktura !")
	return
endif

if !SigmaSif("REGEN")
	return 
endif

if Pitanje(,"Izvrsiti regeneraciju (D/N)?","N") == "N"
	return
endif

select fakt_doks
set order to tag "1"
go top

nCounter := 0

Box(,3, 60)

@ 1 + m_x, 2 + m_y SAY "popunjavanje polja u toku..."

do while !EOF()
	
	cD_firma := field->idfirma
	cD_tdok := field->idtipdok
	cD_brdok := field->brdok

	select fakt
	set order to tag "1"
	go top
	seek ( cD_firma + cD_tdok + cD_brdok )
 	
	aMemo := ParsMemo( field->txt )
	
	select fakt_doks
	
	replace field->dat_otpr with IF(LEN(aMemo)>=7, CTOD(aMemo[7]), CTOD(""))
	replace field->dat_isp with IF(LEN(aMemo)>=7, CTOD(aMemo[7]), CTOD(""))
	replace field->dat_val with IF(LEN(aMemo)>=9, CTOD(aMemo[9]), CTOD(""))

	++nCounter

	@ 3+m_x, 2+m_y SAY "odradjeno zapisa " + ALLTRIM(STR(nCounter)) 

	skip

enddo

BoxC()

return




// ---------------------------------------
// regeneracija polja FAKT-TXT
// ---------------------------------------
function fa_memo_regen()
local cRbr
local cPartn
local dDatPl

if !SigmaSif("MEMREG")
	return 
endif

if Pitanje(,"Izvrsiti regeneraciju (D/N)?","N") == "N"
	return
endif

O_FAKT
O_FAKT_DOKS
O_PARTN

select fakt
set order to tag "1"
go top

// interesuju nas samo prvi zapisi pod rbr = '  1'
cRbr := PADL("1", 3)
nCounter:=0

Box(,3, 60)
@ 1+m_x, 2+m_y SAY "regeneracija memo polja u toku..."

do while !EOF()
	
	// provjeri prvo polje rbr
	if ( field->rbr <> cRbr )
		skip
		loop
	endif
	
	// provjeri i LEN txt polja, ako je > 10 onda je ok
	if LEN(field->txt) > 10
		skip
		loop
	endif
	
	cPartn := fakt->idpartner
	dDatDok := fakt->datdok
	
	// pozicioniraj se na partnera
	select partn
	hseek cPartn

	// prebaci se na doks radi datuma placanja
	select fakt_doks
	set order to tag "1"
	hseek fakt->idfirma + fakt->idtipdok + fakt->brdok
	dDatPl := doks->datpl
	
	select fakt
	
	// odradi regeneraciju polja
	Scatter()

	// roba // ovo je za roba U
	_txt := Chr(16) + Chr(17)
        // dodatni tekst fakture // nemamo ga
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + ALLTRIM(partn->naz) + Chr(17)
	_txt += Chr(16) + ALLTRIM(partn->adresa) + ", Tel:" + ALLTRIM(partn->telefon) + Chr(17) 
	_txt += Chr(16) + ALLTRIM(partn->ptt) + " " + ALLTRIM(partn->mjesto) + Chr(17)
        // broj otpremnice - nemamo ga
	_txt += Chr(16) + Chr(17) 
        // datum otpremnice
	_txt += Chr(16) + DToC(dDatDok) + Chr(17)
        // broj narudzbenice - nemamo ga
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + DToC(dDatPl) + Chr(17)
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + Chr(17)
	_txt += Chr(16) + Chr(17)
	
	Gather()
	
	++nCounter

	@ 3+m_x, 2+m_y SAY "odradjeno zapisa " + ALLTRIM(STR(nCounter)) 

	skip

enddo

BoxC()

return


// ------------------------------------------------------------
// regeneracija / popunjavanje polja idpartner u tabeli fakt
// ------------------------------------------------------------
function fa_part_regen()
local nCount
local cIdFirma
local cIdTipDok
local cBrDok
local cPartn
local cMsg
local lFaktOverwrite := .f.

if !SigmaSif("PARREG")
	return
endif

cMsg := "Prije pokretanja ove opcije#!!! OBAVEZNO !!! napraviti backup podataka"

msgbeep(cMsg)

if Pitanje(,"Izvrsiti popunjavanje partnera u dokumentima (D/N)","N") == "N"
	return
endif


if Pitanje(,"Prepisati vrijednosti u tabeli FAKT (D/N)", "N") == "D"
	lFaktOverwrite := .t.
endif

O_FAKT_DOKS
O_FAKT

select fakt
set order to tag "1"
go top

Box(,3,60)

@ m_x+1, m_y+2 SAY "Vrsim popunjavanje partnera..."

nCount := 0

do while !EOF()
	
	cIdFirma := field->idfirma
	cIdTipDok := field->idtipdok
	cBrDok := field->brdok
	cPartn := field->idpartner

	if lFaktOverwrite == .t. .or. EMPTY( cPartn )
		
		// pokusaj naci u DOKS
		select fakt_doks
		set order to tag "1"
		seek cIdFirma + cIdTipDok + cBrDok

		if FOUND()
			if !EMPTY( field->idpartner )
				
				cPartn := field->idpartner
			
				@ m_x+2, m_y+2 SAY "*** uzeo iz DOKS -> " + cPartn
	
			endif
		endif
			
		select fakt
			
	endif

	do while !EOF() .and. field->idfirma == cIdFirma ;
			.and. field->idtipdok == cIdTipDok ;
			.and. field->brdok == cBrDok
	
		
		if (lFaktOverwrite == .t. .or. EMPTY( field->idpartner )) .and. !EMPTY( cPartn )
		
			++ nCount
			
			// upisi partnera
			replace idpartner with cPartn

			@ m_x+3, m_y+2 SAY "dok-> " + cIdFirma + "-" + ;
				cIdTipDok + "-" + ALLTRIM(cBrDok)
	
		endif
		
		skip
	enddo
	
enddo

BoxC()

if nCount > 0
	msgbeep("Odradjeno " + ALLTRIM(STR(nCount)) + " zapisa !")
endif

return


// ----------------------------------------
// regeneracija partnera
// ----------------------------------------
function fa_p_regen()
local nPrefiks := 2
local nLenMod := 4
local cInsChar := "0"
local lSilent := .t. 

/*
msgo("konverzija - tabela PARTN...")
O_PARTN
mod_f_val( "ID", "0", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()

msgo("konverzija - tabela UGOV...")
O_UGOV
mod_f_val( "ID", "0", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()
msgo("konverzija - tabela UGOV...")
mod_f_val( "IDPARTNER", "0", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()

msgo("konverzija - tabela RUGOV...")
O_RUGOV
mod_f_val( "ID", "0", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()

msgo("konverzija - tabela GEN_UG_P...")
O_G_UG_P
mod_f_val( "ID_UGOV", "0", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()

msgo("konverzija - tabela GEN_UG_P...")
O_G_UG_P
mod_f_val( "IDPARTNER", "0", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()

msgo("konverzija - tabela DOKS...")
O_FAKT_DOKS
mod_f_val( "IDPARTNER", "1", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()

msgo("konverzija - tabela FAKT...")
O_FAKT
mod_f_val( "IDPARTNER", "1", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()
*/

if pitanje(,"konvertovati partnere", "N") == "N"
	return
endif

/*
msgo("konverzija - tabela DEST...")
O_DEST
mod_f_val( "IDPARTNER", "1", cInsChar, nLenMod, nPrefiks, lSilent )
msgc()

msgo("konverzija - tabela SIFV...")

O_SIFV
cFilter := "ALLTRIM(id) == 'PARTN'"
set filter to &cFilter
go top

mod_f_val( "IDSIF", "0", cInsChar, nLenMod, nPrefiks, lSilent )

set filter to
msgc()

msgbeep("konverzija zavrsena !!!")
*/

return


// -----------------------------------------------------
// provjera duplih partnera u sifrarniku partnera
// -----------------------------------------------------
function chk_dpartn()
local cId
local cPNaz
local aPartn := {}

O_FAKT_DOKS
O_PARTN
select partn
go top

Box(,1,50)

do while !EOF()
		
	cId := field->id
	cPNaz := field->naz
	nCnt := 0
	
	@ m_x + 1, m_y + 2 SAY "partner: " + cId + " " + ;
		PADR( cPNaz, 15 ) + " ..."

	do while !EOF() .and. field->id == cId
		++ nCnt
		skip
	enddo
	
	if nCnt > 1
		
		select fakt_doks
		go top
		
		do while !EOF()
			
			if field->idpartner == cId
				
				AADD( aPartn, { cId, PADR( cPNaz, 25), ;
					doks->idfirma + ;
					"-" + doks->idtipdok + ;
					"-" + doks->brdok } )
			endif
			
			skip
		
		enddo

		select partn
	else
		select partn
		skip
	endif

enddo

BoxC()

if LEN( aPartn ) > 0

	START PRINT CRET
	P_COND

	?
	? "-------------------------------------------------"
	? " partner (id/naz)                   dokument "
	? "-------------------------------------------------"
	?

	for i:=1 to LEN( aPartn )
		
		// id partnera
		? aPartn[i, 1]
		// naziv partnera
		@ prow(), pcol()+1 SAY aPartn[i, 2]
		// dokument na kojem se pojavljuje
		@ prow(), pcol()+1 SAY aPartn[i, 3]
	next

	END PRINT
endif

return



