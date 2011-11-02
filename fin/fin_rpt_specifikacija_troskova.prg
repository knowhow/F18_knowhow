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


#include "fin.ch"


// ---------------------------------------------
// izvjestaj specifikacija troskova
// fuelboss - specifican
// ---------------------------------------------
function r_spec_tr()
local dD_from
local dD_to
local cKtoList
local cKtoListZ
local cSp_ld
local cGroup
local cKonto
local cTxt
local cLine
private nLD_ras := 0
private nLD_pri := 0
private nLD_bruto := 0
private nFIN_ras := 0
private nFIN_pri := 0
private nKALK_pri := 0
private nKALK_ras := 0

O_KONTO
O_RJ

// uslovi izvjestaja
if g_vars( @dD_from, @dD_to, @cGroup, @cKtoListZ, @cKtoList, @cSp_ld ) == 0
	return
endif

START PRINT CRET

__r_head( dD_from, dD_to )


? "1) stavke koje ne uticu na rekapitulaciju:"
?

// prvo uzmi podatke iz fin-a samo za pregled
__gen2_fin( dD_from, dD_to, cGroup, cKtoList )

?
? "2) stavke koje uticu na rekapitulaciju:"
?

// zatim uzmi podatke iz fin-a koji uticu na zbir
__gen_fin( dD_from, dD_to, cGroup, cKtoListZ )

? 

// daj konto za kalk
cKonto := _g_gr_kto( cGroup )

// uzmi podatke kalk-a
__gen_kalk( dD_from, dD_to, cKonto )

?

if cSp_ld == "D"
	__get_ld( dD_from, cGroup )
endif

cLine := ""
cTxt := ""

cLine += REPLICATE( "-", 20 )
cLine += SPACE(1)
cLine += REPLICATE( "-", 12 )
cLine += SPACE(1)
cLine += REPLICATE( "-", 12 )
cLine += SPACE(1)
cLine += REPLICATE( "-", 12 )

cTxt += PADR( "SEKCIJA", 20 )
cTxt += SPACE(1)
cTxt += PADL( "PRIHOD", 12 )
cTxt += SPACE(1)
cTxt += PADL( "RASHOD", 12 )
cTxt += SPACE(1)
cTxt += PADL( "UKUPNO", 12 )

P_10CPI

?
? "------------------------"
? "REKAPITULACIJA TROSKOVA:"
? cLine 
? cTxt
? cLine

? PADR( "1) place", 20 )
? PADL( "bruto:", 20 )
@ prow(), pcol()+1 SAY STR(0,12,2)
@ prow(), pcol()+1 SAY STR(nLD_bruto,12,2)
@ prow(), pcol()+1 SAY STR(0 - nLD_bruto,12,2)
? PADL( "10.5% od bruta:", 20 )
nTmpBr := ( nLD_bruto * 0.105 )
@ prow(), pcol()+1 SAY STR(0,12,2)
@ prow(), pcol()+1 SAY STR(nTmpBr,12,2)
@ prow(), pcol()+1 SAY STR(0 - nTmpBr,12,2)
? PADL( "ostali troskovi:", 20 )
@ prow(), pcol()+1 SAY STR(0,12,2)
@ prow(), pcol()+1 SAY STR(nLD_ras,12,2)
@ prow(), pcol()+1 SAY STR(0 - nLD_ras,12,2)


? PADR( "2) roba - materijal", 20 )
@ prow(), pcol()+1 SAY STR(nKALK_pri,12,2)
@ prow(), pcol()+1 SAY STR(nKALK_ras,12,2)
@ prow(), pcol()+1 SAY STR(nKALK_pri-nKALK_ras,12,2)

? PADR( "3) finansije", 20 )
@ prow(), pcol()+1 SAY STR(nFIN_pri,12,2)
@ prow(), pcol()+1 SAY STR(nFIN_ras,12,2)
@ prow(), pcol()+1 SAY STR(nFIN_pri-nFIN_ras,12,2)

? cLine

? PADR( "UKUPNO:", 20 )

nTO_prih := ( nLD_pri + nKALK_pri + nFIN_pri )
nTO_rash := ( nLD_ras + nTmpBr + nLD_bruto + nKALK_ras + nFIN_ras )

// prihodi total
@ prow(), pcol()+1 SAY STR( nTO_prih , 12, 2 )
// rashodi total
@ prow(), pcol()+1 SAY STR( nTO_rash , 12, 2 ) 
// ukupno prihodi - rashodi
@ prow(), pcol()+1 SAY STR( nTO_prih - nTO_rash , 12, 2 )

? cLine

FF
END PRINT

return


// ---------------------------------------------
// vraca konto grupe
// ---------------------------------------------
static function _g_gr_kto( cId )
local xRet := ""
local nTArea := SELECT()

O_RJ
select rj
seek cId

if FOUND()
	xRet := field->konto
endif

select (nTArea)
return xRet


// ---------------------------------------------
// vraca konto grupe
// ---------------------------------------------
static function _g_gr_naz( cId )
local xRet := ""
local nTArea := SELECT()

O_RJ
select rj
seek cId

if FOUND()
	xRet := ALLTRIM( field->naz )
endif

select (nTArea)
return xRet


// ---------------------------------------------
// vraca naziv konta
// ---------------------------------------------
static function _g_kt_naz( cId )
local xRet := ""
local nTArea := SELECT()

O_KONTO
select konto
seek cId

if FOUND()
	xRet := ALLTRIM( field->naz )
endif

select (nTArea)
return xRet


// ---------------------------------------------
// vraca naziv partnera
// ---------------------------------------------
static function _g_pt_naz( cId )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
seek cId

if FOUND()
	xRet := ALLTRIM( field->naz )
endif

select (nTArea)
return xRet



// ---------------------------------------------
// header izvjestaja
// ---------------------------------------------
static function __r_head( dD_from, dD_to )
?
? "PREGLED TROSKOVA PO OBJEKTIMA ZA PERIOD: " + DTOC( dD_from ) + ;
	"-" + DTOC(dD_to)
?
return


// --------------------------------------------------
// generisi podatke iz fin-a
// --------------------------------------------------
static function __gen_fin( dD_from, dD_to, cGroup, cKtoList )
local cFilter := ""
local cIdFirma := gFirma
local cIdKonto
local cIdPartner

// partner dug/pot/saldo
local nP_dug := 0
local nP_pot := 0
local nP_saldo := 0

// konto dug/pot/saldo
local nK_dug := 0
local nK_pot := 0
local nK_saldo := 0

// total dug/pot/saldo
local nT_dug := 0
local nT_pot := 0
local nT_saldo := 0

local nRbr := 0
local nP_col := 50
local nK_col := 30

local cTxt := ""
local cLine := ""

cTxt += PADR( "r.br", 5 )
cTxt += SPACE(1)
cTxt += PADR( "konto", 7 )
cTxt += SPACE(1)
cTxt += PADR( "part.", 6 )
cTxt += SPACE(1)
cTxt += PADR( "naziv", 40 )
cTxt += SPACE(1)
cTxt += PADR( "duguje", 12 )
cTxt += SPACE(1)
cTxt += PADR( "potrazuje", 12 )
cTxt += SPACE(1)
cTxt += PADR( "saldo", 12 )

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 7)
cLine += SPACE(1)
cLine += REPLICATE("-", 6)
cLine += SPACE(1)
cLine += REPLICATE("-", 40)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)

? "FIN :: stanje objekta " + cGroup + ;
	" od " + DTOC( dD_from ) + " do " + DTOC( dD_to )

P_COND

? cLine
? cTxt
? cLine

O_SUBAN
select suban
set order to tag "1"
go top

// radna jedinica
cFilter += "idrj=" + cm2str( cGroup )

// datumski period
cFilter += ".and. datdok >= CTOD('" + ;
	DTOC( dD_from ) + ;
	"') .and. datdok <= CTOD('" + ;
	DTOC( dD_to )+ ;
	"')"

if !EMPTY( ALLTRIM( cKtoList ) )
	cFilter += ".and." + PARSIRAJ( ALLTRIM( cKtoList ), "idkonto" )
endif

set filter to &cFilter
go top
hseek cIdFirma

do while !EOF() .and. field->idfirma == cIdFirma   

  cIdKonto := field->idkonto
  nK_dug := 0
  nK_pot := 0
  nK_saldo := 0

  do while !EOF() .and. field->idfirma == cIdFirma ;
		.and. field->idkonto == cIdKonto 
	    
	cIdPartner := field->idpartner
            
	nP_dug := 0
	nP_pot := 0
	nP_saldo := 0
            
	do while !EOF() .and. field->idfirma == cIdFirma ;
	    	.and. field->idkonto == cIdKonto ;
		.and. field->idpartner == cIdPartner 
	      
	      	// duguje/potrazuje
        	if field->d_p == "1"
			nP_dug += field->IznosBHD
		else
			nP_pot += field->IznosBHD
		endif
              
              	skip
	
	enddo

	nP_saldo := ( nP_dug - nP_pot ) 

	if prow() > 61 + gpStranica
		FF
	endif

	// ne prikazuj podatke ako su 0
	if ROUND( nP_saldo, 2) == 0
		loop
	endif

	? PADL( ALLTRIM( STR( ++ nRbr, 4 )) + ".", 5 )

       	@ prow(), pcol()+1 SAY cIdKonto
      	@ prow(), pcol()+1 SAY cIdPartner       

        if EMPTY( cIdPartner )
		@ prow(), nK_col := pcol()+1 SAY PADR( _g_kt_naz( cIdKonto ) , 40 )  
	else
		@ prow(), nK_col := pcol()+1 SAY PADR( _g_pt_naz( cIdPartner ) , 40 )  
	endif
	
	// duguje
	@ prow(), nP_col := pcol()+1 SAY STR(nP_dug,12,2)
	// potrazuje
        @ prow(), pcol()+1 SAY STR(nP_pot,12,2)
	// saldo
        @ prow(), pcol()+1 SAY STR(nP_saldo,12,2)
       
        // saldo po kontu
	nK_dug += nP_dug
	nK_pot += nP_pot
	nK_saldo += nP_saldo

	// total ...
	nT_dug += nP_dug
	nT_pot += nP_pot
	nT_saldo += nP_saldo

	if LEFT( cIdKonto, 1 ) == "6"
		// prihod je na 6-ci
		nFIN_pri += ABS( nP_saldo )
	else
		// ovo je rashod
		nFIN_ras += nP_saldo
	endif

  enddo

  ? cLine
  ? "ukupno konto " + cIdKonto
  @ prow(), nK_col SAY PADR( _g_kt_naz( cIdKonto ), 40)
  @ prow(), nP_col SAY STR( nK_dug, 12, 2 )
  @ prow(), pcol()+1 SAY STR( nK_pot, 12, 2 )
  @ prow(), pcol()+1 SAY STR( nK_saldo, 12, 2 )
  ? cLine

enddo

// ispisi total...

? "UKUPNO:"
@ prow(), nP_col SAY STR( nT_dug, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_pot, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_saldo, 12, 2 )

? cLine
	 

return


// --------------------------------------------------
// generisi podatke iz fin-a unakrsno
// --------------------------------------------------
static function __gen2_fin( dD_from, dD_to, cGroup, cKtoList )
local cFilter := ""
local cIdFirma := gFirma
local cIdKonto
local cIdPartner

// partner dug/pot/saldo
local nP_dug := 0
local nP_pot := 0
local nP_saldo := 0

// konto dug/pot/saldo
local nK_dug := 0
local nK_pot := 0
local nK_saldo := 0

// total dug/pot/saldo
local nT_dug := 0
local nT_pot := 0
local nT_saldo := 0

local nRbr := 0
local nP_col := 50
local nK_col := 30

local cTxt := ""
local cLine := ""

cTxt += PADR( "r.br", 5 )
cTxt += SPACE(1)
cTxt += PADR( "konto", 7 )
cTxt += SPACE(1)
cTxt += PADR( "part.", 6 )
cTxt += SPACE(1)
cTxt += PADR( "naziv", 40 )
cTxt += SPACE(1)
cTxt += PADR( "duguje", 12 )
cTxt += SPACE(1)
cTxt += PADR( "potrazuje", 12 )
cTxt += SPACE(1)
cTxt += PADR( "saldo", 12 )

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 7)
cLine += SPACE(1)
cLine += REPLICATE("-", 6)
cLine += SPACE(1)
cLine += REPLICATE("-", 40)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)

? "FIN :: stanje po objektu " + cGroup + ;
	" od " + DTOC( dD_from ) + " do " + DTOC( dD_to )

P_COND

? cLine
? cTxt
? cLine

O_SUBAN
select suban
set order to tag "2"
// idfirma+idpartner+idkonto

// radna jedinica
cFilter += "idrj=" + cm2str( cGroup )

// datumski period
cFilter += ".and. datdok >= CTOD('" + ;
	DTOC( dD_from ) + ;
	"') .and. datdok <= CTOD('" + ;
	DTOC( dD_to )+ ;
	"')"

if !EMPTY( ALLTRIM( cKtoList ) )
	cFilter += ".and." + PARSIRAJ( ALLTRIM( cKtoList ), "idkonto" )
endif

set filter to &cFilter
go top
hseek cIdFirma

do while !EOF() .and. field->idfirma == cIdFirma   

  cIdPartner := field->idpartner
            
  nP_dug := 0
  nP_pot := 0
  nP_saldo := 0
 
  do while !EOF() .and. field->idfirma == cIdFirma ;
		.and. field->idpartner == cIdPartner 
	    
 	cIdKonto := field->idkonto
  	nK_dug := 0
  	nK_pot := 0
  	nK_saldo := 0
    
	do while !EOF() .and. field->idfirma == cIdFirma ;
	    	.and. field->idkonto == cIdKonto ;
		.and. field->idpartner == cIdPartner 
	      
	      	// duguje/potrazuje
        	if field->d_p == "1"
			nK_dug += field->IznosBHD
		else
			nK_pot += field->IznosBHD
		endif
              
              	skip
	
	enddo

	nK_saldo := ( nK_dug - nK_pot ) 

	if prow() > 61 + gpStranica
		FF
	endif

	// ne prikazuj podatke ako su 0
	if ROUND( nK_saldo, 2) == 0
		loop
	endif

	? PADL( ALLTRIM( STR( ++ nRbr, 4 )) + ".", 5 )

       	@ prow(), pcol()+1 SAY cIdKonto
      	@ prow(), pcol()+1 SAY cIdPartner       

        if EMPTY( cIdPartner )
		@ prow(), nK_col := pcol()+1 SAY PADR( _g_kt_naz( cIdKonto ) , 40 )  
	else
		@ prow(), nK_col := pcol()+1 SAY PADR( _g_pt_naz( cIdPartner ) , 40 )  
	endif
	
	// duguje
	@ prow(), nP_col := pcol()+1 SAY STR(nK_dug,12,2)
	// potrazuje
        @ prow(), pcol()+1 SAY STR(nK_pot,12,2)
	// saldo
        @ prow(), pcol()+1 SAY STR(nK_saldo,12,2)
       
        // saldo po kontu
	nP_dug += nK_dug
	nP_pot += nK_pot
	nP_saldo += nK_saldo

	// total ...
	nT_dug += nK_dug
	nT_pot += nK_pot
	nT_saldo += nK_saldo

  enddo

  //? cLine
  //? "ukupno partner " + cIdPartner
  //@ prow(), nK_col SAY PADR( _g_pt_naz( cIdPartner ), 40)
  //@ prow(), nP_col SAY STR( nP_dug, 12, 2 )
  //@ prow(), pcol()+1 SAY STR( nP_pot, 12, 2 )
  //@ prow(), pcol()+1 SAY STR( nP_saldo, 12, 2 )
  //? cLine

enddo

// ispisi total...

? cLine
? "UKUPNO:"
@ prow(), nP_col SAY STR( nT_dug, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_pot, 12, 2 )
@ prow(), pcol()+1 SAY STR( nT_saldo, 12, 2 )

? cLine

return



// --------------------------------------------------
// generisi podatke iz kalk-a
// --------------------------------------------------
static function __gen_kalk( dD_from, dD_to, cKto )
local cPath := STRTRAN( KUMPATH, "FIN", "KALK" )
local cIdFirma := gFirma
local cLine
local cTxt
local nIzlNV
local nUlNV
local nUlKol
local nIzKol
local nKolicina

select (102)
use ( cPath + SLASH + "kalk" ) alias "ka_exp"

select ka_exp
// mkonto
set order to tag "3"
go top

seek cIdFirma + cKto

nIzlNV := 0   
nUlNV := 0
nUlKol := 0
nIzKol := 0
nKolicina := 0

// prodji kroz KALK za ovaj konto...

do while !EOF() .and. field->idfirma == cIdFirma ;
	.and. field->mkonto == cKto	
	
	// provjeri datum
	if field->datdok > dD_to .or. field->datdok < dD_from
		skip
		loop
	endif
  
 	if field->mu_i == "1"

		if !(field->idvd $ "12#22#94")
			nKolicina := field->kolicina - field->gkolicina - field->gkolicin2
 			nUlKol += nKolicina
			nUlNv += round( field->nc*(field->kolicina-field->gkolicina-field->gkolicin2) , gZaokr)
		else
			nKolicina := -field->kolicina
			nIzlKol += nKolicina
     			nIzlNV -= round( field->nc*field->kolicina , gZaokr)
    		endif

  	elseif field->mu_i=="5"

    		nKolicina := field->kolicina
    		nIzlKol += nKolicina
    		nIzlNV += ROUND(field->nc*field->kolicina, gZaokr)

  	elseif field->mu_i=="8"
     		
		nKolicina := -field->kolicina
     		nIzlKol += nKolicina
		nIzlNV += ROUND(field->nc*(-kolicina), gZaokr)
   		nKolicina := -field->kolicina
		nUlKol += nKolicina	
		nUlKol += round(-nc*(field->kolicina-gkolicina-gkolicin2) , gZaokr)
  	endif

	//select kalk
	skip

enddo

// sada imam podatke, ispisi ih...

cLine := ""
cTxt := ""

cLine += REPLICATE( "-", 7 )
cLine += SPACE(1)
cLine += REPLICATE( "-", 60 )
cLine += SPACE(1)
cLine += REPLICATE( "-", 12 )
cLine += SPACE(1)
cLine += REPLICATE( "-", 12 )
cLine += SPACE(1)
cLine += REPLICATE( "-", 12 )

cTxt += PADR( "objekat", 7 )
cTxt += SPACE(1)
cTxt += PADR( "naziv", 60 )
cTxt += SPACE(1)
cTxt += PADR( "NV ulaz", 12 )
cTxt += SPACE(1)
cTxt += PADR( "NV izlaz", 12 )
cTxt += SPACE(1)
cTxt += PADR( "NV stanje", 12 )

P_10CPI

? "KALK :: stanje objekta", cKto, "od " + DTOC(dD_from) + ;
	" do " + DTOC( dD_to )

P_COND

// ispisi zaglavlje
? cLine
? cTxt
? cLine

? cKto
@ prow(), pcol()+1 SAY PADR( _g_kt_naz( cKto ), 60)
@ prow(), pcol()+1 SAY STR(nUlNV,12,2)
@ prow(), pcol()+1 SAY STR(nIzlNV,12,2)
@ prow(), pcol()+1 SAY STR(nUlNV-nIzlNV,12,2)
? cLine

nKALK_ras += ( nUlNv - nIzlNV)

return




// -------------------------------------------
// vraca linije i header
// -------------------------------------------
static function _g_ld_line( cLine )

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

if ld_exp->tp_1 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-1", 12 )
endif
if ld_exp->tp_2 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-2", 12 )
endif
if ld_exp->tp_3 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-3", 12 )
endif
if ld_exp->tp_4 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-4", 12 )
endif
if ld_exp->tp_5 <> 0
	cLine += SPACE(1)
	cLine += REPLICATE("-", 12)
	cTxt += SPACE(1)
	cTxt += PADR( "dp-5", 12 )
endif

? cLine
? cTxt
? cLine

return


// ----------------------------------------------------------
// printanje reporta iz ld-a
// ----------------------------------------------------------
static function __get_ld( dD_from, cGroup )
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
local cPath := STRTRAN( PRIVPATH, "FIN", "LD" )

select (101)
use ( cPath + SLASH + "r_export" ) alias "ld_exp"
index on group + idradn + STR(godina,4) + STR(mjesec,2) tag "1"
select ld_exp
set order to tag "1"
go top

P_10CPI

? "LD :: pregled utroska za grupu:", cGroup, STR(MONTH(dD_from)) ;
	+ "/" + STR(YEAR(dD_from))

P_COND2

_g_ld_line( @cLine ) 

nCnt := 0
do while !EOF()

	// n.str
	if prow() > 64 
		FF
	endif
	
	cGr_id := field->group
	cGr_naz := field->gr_naz

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
		PADR( cGr_naz, 30 )

	do while !EOF() .and. field->group == cGr_id

		// n.str
		if prow() > 64 
			FF
		endif

		? PADL( ALLTRIM(STR(++nCnt)) + ".", 5 )
		@ prow(), pcol()+1 SAY PADR( field->r_naz, 30 )
		@ prow(), nCol:=pcol()+1 SAY STR(field->sati, 8, 2)
		@ prow(), pcol()+1 SAY STR(field->bruto, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->neto, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_pio, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_zdr, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->dop_nez, 12, 2)
		@ prow(), pcol()+1 SAY STR(field->izn_por, 12, 2)

		if field->tp_1 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_1, 12, 2)
		endif
		if field->tp_2 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_2, 12, 2)
		endif
		if field->tp_3 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_3, 12, 2)
		endif
		if field->tp_4 <> 0
			@ prow(), pcol()+1 SAY STR(field->tp_4, 12, 2)
		endif
		if field->tp_5 <> 0
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
	
	if nU_tp_1 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_1, 12, 2 )
	endif
	if nU_tp_2 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_2, 12, 2 )
	endif
	if nU_tp_3 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_3, 12, 2 )
	endif
	if nU_tp_4 <> 0
		@ prow(), pcol()+1 SAY STR( nU_tp_4, 12, 2 )
	endif
	if nU_tp_5 <> 0
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
	
if nT_tp_1 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_1, 12, 2 )
endif
if nT_tp_2 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_2, 12, 2 )
endif
if nT_tp_3 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_3, 12, 2 )
endif
if nT_tp_4 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_4, 12, 2 )
endif
if nT_tp_5 <> 0
	@ prow(), pcol()+1 SAY STR( nT_tp_5, 12, 2 )
endif
	
? cLine

// ukalkulisi u rashod

nLD_bruto += nT_bruto
nLD_ras += ( nT_tp_1 + nT_tp_2 + nT_tp_3 + nT_tp_4 + nT_tp_5 )
 
return


// -------------------------------------------------------
// uslovi reporta
// -------------------------------------------------------
static function g_vars( dD_from, dD_to, cGroup, cKtoListZ, cKtoList, ;
	cSpecLd )
local nRet := 1
local nBoxX := 10
local nBoxY := 65
local nX := 1
local nTArea := SELECT()

dD_from := DATE()-30
dD_to := DATE()
cSpecLD := "D"
cKtoList := SPACE(200)
cKtoListZ := SPACE(200)
cGroup := SPACE(6)

O_PARAMS
private cSection := "S"
private cHistory := " "
private aHistory := {}

RPar("d1", @dD_from)
RPar("d2", @dD_to)
RPar("ld", @cSpecLD)
RPar("kl", @cKtoList)
RPar("kz", @cKtoListZ)
RPar("gr", @cGroup)

Box(, nBoxX, nBoxY )
		
	@ m_x + nX, m_y + 2 SAY "Za period od:" GET dD_From
	@ m_x + nX, col() + 1 SAY "do:" GET dD_to

	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Grupa:" GET cGroup ;
		VALID p_rj( @cGroup )

	++ nX

	@ m_x + nX, m_y + 2 SAY "Specifikacija LD (D/N)?" GET cSpecLd ;
		VALID cSpecLd $ "DN" PICT "@!"
	
	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "FIN konta   - lista    (uticu na zbir):" ;
		GET cKtoListZ ;
		PICT "@S20"
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "FIN konta   - lista (ne uticu na zbir):" ;
		GET cKtoList ;
		PICT "@S20"
	

	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
	return nRet
endif

// write params
WPar("d1", dD_from)
WPar("d2", dD_to)
WPar("ld", cSpecLD)
WPar("kl", cKtoList)
WPar("kz", cKtoListZ)
WPar("gr", cGroup)

select params
use

select (nTArea)
return nRet



