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


#include "f18.ch"


// -----------------------------------------------------------------
// kontrola sastavnica
// 
// izvjestaj ce dati sljedece:
// 1) uzmi tekuci promet konta 1010 i ubaci u R_EXPORT
//     ulaz, izlaz, stanje, cijene...
// 2) zatim se zakaci na fakt i pos te napravi razduzenje za citavu
//    godinu po principu razduzenja sastavnica i te stavke stavi u 
//    tabelu...
// 3) kod povlacenja izvjestaja imamo znaci t.promet, novo stanje
//    napraviti cizu i usporedbu +/-
// -----------------------------------------------------------------
function r_ct_sast()
local cIdFirma
local cIdKonto
local dD_from
local dD_to
local cProdKto
local cArtfilter
local cSezona
local cSirovina
local cTDokList
local nVar := 1

private nRslt := 0
private lAsistRadi := .t.

O_ROBA
O_SIFK
O_SIFV

// uslovi izvjestaja
if g_vars( @dD_from, @dD_to, @cIdFirma, @cIdKonto, @cProdKto, ;
	@cArtfilter, @cTDokList, @cSezona, @cSirovina ) == 0
	return
endif

// kreiraj pomocnu tabelu

if !EMPTY( cSirovina )
	nVar := 2
endif

cre_r_tbl( nVar )

O_PARTN
O_KALK_PRIPR
O_KALK
O_KALK_DOKS
O_ROBA
O_KONTO

if nVar == 1
	
	// daj kalk tekuci promet
	_g_kalk_tp( cIdFirma, cIdKonto, dD_from, dD_to )

	msgo("uzimam iz kalk_pripreme stanje i dodajem ga u export")
	
	// uzmi iz kalk_pripreme ako postoji nesto generisano
	_pr_2_exp( nVar )
	
	msgc()

endif

// razduzi FAKT promet po sastavnicama
_g_fakt_pr( cIdKonto, dD_From, dD_to, cTDokList, cSezona, nVar, cSirovina )

if nVar == 1
	// razduzi POS promet po sastavnicama
	_g_pos_pr( cIdFirma, cIdKonto, dD_From, dD_to, cProdKto, ;
		cArtFilter, cSezona, nVar, cSirovina )
endif

my_close_all_dbf()
O_ROBA

o_rxp( nVar )

// stampaj izvjestaj
if nVar == 1
	pr_report()
else
	pr_rpt2()
endif

return

// -----------------------------------------------------
// kreiranje tabele r_exp
// -----------------------------------------------------
static function cre_r_tbl( nVar )
local aDbf := {}

if nVar == 1

  AADD(aDbf,{ "IDROBA", "C", 10, 0 })
  AADD(aDbf,{ "IDKONTO", "C", 7, 0 })
  AADD(aDbf,{ "TP_UL", "N", 15, 5 })
  AADD(aDbf,{ "TP_IZ", "N", 15, 5 })
  AADD(aDbf,{ "TP_ST", "N", 15, 5 })
  AADD(aDbf,{ "TP_NVU", "N", 15, 5 })
  AADD(aDbf,{ "TP_NVI", "N", 15, 5 })
  AADD(aDbf,{ "TP_NVS", "N", 15, 5 })
  AADD(aDbf,{ "TP_SNC", "N", 15, 5 })

  // novo stanje
  AADD(aDbf,{ "NP_UL", "N", 15, 5 })
  AADD(aDbf,{ "NP_IZ", "N", 15, 5 })
  AADD(aDbf,{ "NP_ST", "N", 15, 5 })
  AADD(aDbf,{ "NP_NVU", "N", 15, 5 })
  AADD(aDbf,{ "NP_NVI", "N", 15, 5 })
  AADD(aDbf,{ "NP_NVS", "N", 15, 5 })

else

  AADD(aDbf,{ "IDSAST", "C", 10, 0 })
  AADD(aDbf,{ "IDROBA", "C", 10, 0 })
  AADD(aDbf,{ "R_NAZ", "C", 200, 0 })
  AADD(aDbf,{ "BRDOK", "C", 20, 0 })
  AADD(aDbf,{ "RBR", "C", 4, 0 })
  AADD(aDbf,{ "IDPARTNER", "C", 6, 0 })
  AADD(aDbf,{ "P_NAZ", "C", 50, 0 })
  AADD(aDbf,{ "KOLICINA", "N", 15, 5 })
  AADD(aDbf,{ "KOL_SAST", "N", 15, 5 })


endif

t_exp_create( aDbf )

o_rxp( nVar )

return

// ---------------------------------------
// open r_export
// ---------------------------------------
static function o_rxp( nVar )

O_R_EXP

if nVar == 1
	index on idroba tag "1"
	index on idkonto+idroba tag "2"
else
	index on brdok + rbr tag "1"
endif

return




// --------------------------------------------------------------
// uslovi reporta
// --------------------------------------------------------------
static function g_vars( dD_from, dD_to, cIdFirma, cIdKonto, cProdKto, ;
	cArtfilter, cTDokList, cSezona, cSirovina )
local nX := 1
local nRet := 1

dD_from := CTOD( "01.01.09")
dD_to := CTOD( "31.12.09")
cIdFirma := gFirma
cIdKonto := PADR("1010;", 150)
cTDokList := PADR("10;11;12;", 20)
cArtfilter := PADR("2;3;",100)
cProdKto := PADR( "1320", 7 )
cSezona := "RADP"
cSirovina := SPACE(10)

Box(,10, 65 )

	@ m_x + nX, m_y + 2 SAY "Datum od" GET dD_from
	@ m_x + nX, col()+1 SAY "do" GET dD_to

	++ nX

	@ m_x + nX, m_y + 2 SAY "Firma:" GET cIdFirma 
	@ m_x + nX, col() + 3 SAY "sast.iz sezone" GET cSezona

	++ nX

	@ m_x + nX, m_y + 2 SAY "gledaj sirovinu:" GET cSirovina ;
		VALID EMPTY(cSirovina) .or. P_ROBA(@cSirovina)

	++ nX

	@ m_x + nX, m_y + 2 SAY "Mag. konta:" GET cIdKonto PICT "@S40"
	
	++ nX
	++ nX

	@ m_x + nX, m_y + 2 SAY "(fakt) lista dokumenata:" GET cTDokList ;
		PICT "@S20"

	++ nX
	++ nX

	@ m_x + nX, m_y + 2 SAY "(pos) konto prodavnice:" GET cProdKto VALID p_konto(@cProdKto)

	++ nX

	@ m_x + nX, m_y + 2 SAY "(pos) filter za artikle:" GET cArtfilter PICT "@S20"
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet


// -------------------------------------------------------------------
// uzmi tekuce stanje artikala kalk-a sa lagera
// -------------------------------------------------------------------
static function _g_kalk_tp( cIdFirma, cKto_list, dD_from, dD_to )
local cIdKonto
local aKto
local i

private GetList:={}

Box(,1, 70)

aKto := TokToNiz( cKto_list, ";" )

for i := 1 to LEN( aKto )

  cIdKonto := PADR( aKto[i], 7 )

  if EMPTY( cIdKonto )
  	loop
  endif

  @ m_x + 1, m_y + 2 SAY "obradjujem mag. konto: " + cIdKonto

  select kalk
  // mkonto
  set order to tag "3"
  go top

  seek cIdFirma + cIdKonto

  do while !EOF() .and. cIdFirma == field->idfirma ;
	.and. cIdKonto == field->mkonto 
	

	cIdRoba := field->idroba

 	nKolicina := 0
  	nIzlNV:=0   
  	// ukupna izlazna nabavna vrijednost
  	nUlNV:=0
  	nIzlKol:=0   
  	// ukupna izlazna kolicina
 	nUlKol:=0  
  	// ulazna kolicina

	nKol_poz := 0

	@ m_x + 1, m_y + 20 SAY "roba ->" + cIdRoba

	do while !EOF() .and. ((cIdFirma+cIdKonto+cIdRoba) == (idFirma+mkonto+idroba)) 

		// provjeri datum
		if field->datdok > dD_to .or. field->datdok < dD_from
			skip
			loop
		endif

	 	if roba->tip $ "TU"
  			skip
			loop
  	 	endif
  
  	 	if mu_i == "1"
    			if !(idvd $ "12#22#94")
     				nKolicina := field->kolicina - field->gkolicina - field->gkolicin2
    	 			nUlKol += nKolicina
     				//SumirajKolicinu(nKolicina, 0, @nTUlazP, @nTIzlazP)
     				nUlNv += round( field->nc*(field->kolicina-field->gkolicina-field->gkolicin2) , gZaokr)
   			else
     				nKolicina := -field->kolicina
     				nIzlKol += nKolicina
     			
				//SumirajKolicinu(0, nKolicina, @nTUlazP, @nTIzlazP)
     			
     				nIzlNV -= round( field->nc*field->kolicina , gZaokr)
    			endif

  		elseif mu_i=="5"

    			nKolicina := field->kolicina
    			nIzlKol += nKolicina
    		
			//SumirajKolicinu(0, nKolicina, @nTUlazP, @nTIzlazP)

    			nIzlNV += ROUND(field->nc*field->kolicina, gZaokr)

  		elseif mu_i=="8"
     			nKolicina := -field->kolicina
     			nIzlKol += nKolicina
     			//SumirajKolicinu(0, nKolicina , @nTUlazP, @nTIzlazP)
     		
			nIzlNV += ROUND(field->nc*(-kolicina), gZaokr)
   			nKolicina:=-field->kolicina
     		
			nUlKol += nKolicina
     			//SumirajKolicinu(nKolicina, 0, @nTUlazP, @nTIzlazP)
     		
		
			nUlKol +=round(-nc*(field->kolicina-gkolicina-gkolicin2) , gZaokr)
  		endif

	select kalk
	skip

	enddo

	nKolicina := ( nUlKol - nIzlKol )

	if round( nKolicina, 8 ) == 0
 		nSNc := 0
	else
 		// srednja nabavna cijena
 		nSNc := ( nUlNV - nIzlNV ) / nKolicina
	endif

	nKolicina := round( nKolicina, 4 )
        
	if round( nKolicina, 8 ) <> 0
	 
		 // upisi u r_exp
	 	 select r_export
	 	 append blank

	 	 replace idkonto with cIdkonto
	 	 replace idroba with cIdRoba
	 	 replace tp_ul with nUlKol
	 	 replace tp_iz with nIzlKol
	 	 replace tp_st with ( nUlKol - nIzlKol )
	 	 replace tp_nvu with nUlNV
	 	 replace tp_nvi with nIzlNV
	 	 replace tp_nvs with ( nUlNV - nIzlNv )
	 	 replace tp_snc with nSnc
        
	endif

	select kalk
		
  	enddo

next

BoxC()

return


// -------------------------------------------------------------
// uzmi promet fakt-a za godinu dana... po sastavnicama
// -------------------------------------------------------------
static function _g_fakt_pr( cIdKonto, dD_From, dD_to, cTDokList, cSezona, ;
	nVar, cSirovina )
local nTArea := SELECT()
local cKto := STRTRAN( cIdKonto, ";", "" )
local cRobaUsl := ""
local cRobaIncl := "I"

cKto := PADR( ALLTRIM( cKto ), 7 )

msgo("generisem pomocnu datoteku razduzenja FAKT....")

// prenesi fakt->kalk
prenosNo( dD_from, dD_to, cKto, cTDokList, dD_to, cRobaUsl, ;
	cRobaIncl, cSezona, cSirovina )

msgc()

_pr_2_exp( nVar )

return


// ------------------------------------------------------------
// uzmi promet pos-a po sastavnicama za godinu
// ------------------------------------------------------------
static function _g_pos_pr( cIdFirma, cIdKonto, dD_From, dD_to, ;
	cProdKto, cArtFilter, cSezona, nVar, cSirovina )

local nTArea := SELECT()
local cIdTipDok := PADR("42;", 20)
local cKto := STRTRAN( cIdKonto, ";", "" )

cKto := PADR( ALLTRIM( cKto ), 7 )

msgo("generisem pomocnu datoteku razduzenja TOPS....")
// pokreni opciju tops po normativima
tops_nor_96( cIdFirma, "42;", "", cKto, "", ;
	dD_to, dD_from, dD_to, cArtfilter, cProdKto, cSezona, cSirovina )

msgc()

_pr_2_exp( nVar )

select (nTArea)
return



static function _pr_2_exp( nVar )

if nVar == 2
	
	select kalk_pripr
	zap
	
	// sredi robu i partnere
	select r_export
	go top
    my_flock()
	do while !EOF()
		replace field->r_naz with r_naz( field->idroba )
		replace field->p_naz with p_naz( field->idpartner )
		skip
	enddo
    my_unlock()
	return
endif

o_rxp( nVar )
select r_export
set order to tag "1"

// dobit ces punu kalk_pripremu
select kalk_pripr
go top
do while !EOF()
	
	cIdRoba := field->idroba

	select r_export
	go top
	seek cIdRoba

    my_flock()

	if !FOUND()
		append blank
		replace field->idroba with cIdRoba
	endif

	replace field->np_iz with ( field->np_iz + kalk_pripr->kolicina )
	
	replace field->np_st with ( field->tp_ul - ;
		field->np_iz )
	
	replace field->np_nvi with ( field->np_nvi + (kalk_pripr->nc * kalk_pripr->kolicina) )
	
	replace field->np_nvs with ( field->tp_nvu - ;
		field->np_nvi )

    my_unlock()

	select kalk_pripr

	skip
enddo

msgc()

// pobrisi na kraju kalk_pripremu
select kalk_pripr
my_dbf_zap()

return


// -----------------------------------------------
// stampanje izvjestaja
// -----------------------------------------------
static function pr_rpt2()
local nRbr := 0
local cLine
local nCol := 2
local nT_kol := 0
local nT_k2 := 0

cLine := g_line( 2 )

START PRINT CRET
?

r_zagl( cLine, 2 )

select r_export
set order to tag "1"
go top

do while !EOF()
	
	? PADL( ALLTRIM( STR( ++nRbr )), 4 ) + ")"

	@ prow(), pcol()+1 SAY PADR( field->brdok, 20 )
	
	@ prow(), pcol()+1 SAY PADR( ALLTRIM( field->idroba ) + ;
		" - " + ALLTRIM(field->r_naz) , 50 )
	
	@ prow(), pcol()+1 SAY field->rbr
	
	@ prow(), pcol()+1 SAY PADR( "(" + ALLTRIM( field->idpartner ) + ;
		") " + ALLTRIM( field->p_naz ), 50 )
	
	@ prow(), nCol := pcol()+1 SAY STR( field->kolicina, 12, 2 )
	
	@ prow(), pcol()+1 SAY STR( field->kol_sast, 12, 2 )
	
	nT_kol += field->kolicina
	nT_k2 += field->kol_sast
	
	skip
enddo

? cLine

? "UKUPNO:"

@ prow(), nCol SAY STR( nT_kol, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nT_k2, 12, 2 )

? cLine

FF
END PRINT

return


// -----------------------------------------------
// stampanje izvjestaja
// -----------------------------------------------
static function pr_report()
local nRbr := 0
local cLine
local nTp_ul := 0
local nTp_iz := 0
local nTp_st := 0
local nTp_nvu := 0
local nTp_nvi := 0
local nTp_nvs := 0
local nNp_ul := 0
local nNp_iz := 0
local nNp_st := 0
local nNp_nvu := 0
local nNp_nvi := 0
local nNp_nvs := 0
local nCol := 2

cLine := g_line( 1 )

START PRINT CRET
?

r_zagl( cLine, 1 )

select r_export
set order to tag "1"
go top

do while !EOF()
	
	? PADL( ALLTRIM( STR( ++nRbr )), 4 ) + ")"

	@ prow(), pcol() + 1 SAY PADR( "(" + ALLTRIM( field->idroba ) + ") " + ;
		r_naz( field->idroba ), 30 )
	
	// ulaz
	@ prow(), nCol := pcol()+1 SAY STR( field->tp_ul, 12, 2 )
	// tp. izlaz
	@ prow(), nCol2 := pcol()+1 SAY STR( field->tp_iz, 12, 2 )
	// tp. stanje
	@ prow(), pcol()+1 SAY STR( field->tp_st, 12, 2 )
	// +/- kolicine
	@ prow(), pcol()+1 SAY STR( field->tp_st - field->np_st, 12, 2 )
	// nv. ulaz
	@ prow(), pcol()+1 SAY STR( field->tp_nvu, 12, 2 )
	// tp. nv izlaz
	@ prow(), nCol3 := pcol()+1 SAY STR( field->tp_nvi, 12, 2 )
	// tp. nv stanje
	@ prow(), pcol()+1 SAY STR( field->tp_nvs, 12, 2 )
	// +/- stanja
	@ prow(), pcol()+1 SAY STR( field->tp_nvs - field->np_nvs, 12, 2 )

	? " "
	
	// np. izlaz
	@ prow(), nCol2 SAY STR( field->np_iz, 12, 2 )
	// np stanje
	@ prow(), pcol()+1 SAY STR( field->np_st, 12, 2 )
	// np nv izlaz
	@ prow(), nCol3 SAY STR( field->np_nvi, 12, 2 )
	// np nv stanje
	@ prow(), pcol()+1 SAY STR( field->np_nvs, 12, 2 )

	nTp_ul += field->tp_ul
	nTp_iz += field->tp_iz
	nTp_st += field->tp_st
	nTp_nvu += field->tp_nvu
	nTp_nvi += field->tp_nvi
	nTp_nvs += field->tp_nvs
	
	nNp_ul += field->np_ul
	nNp_iz += field->np_iz
	nNp_st += field->np_st
	nNp_nvu += field->np_nvu
	nNp_nvi += field->np_nvi
	nNp_nvs += field->np_nvs

	skip
enddo

? cLine

? "UKUPNO:"

@ prow(), nCol SAY STR( nTp_ul, 12, 2 )
@ prow(), nCol2 := pcol() + 1 SAY STR( nTp_iz, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nTp_st, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nTp_st - nNp_st , 12, 2)
@ prow(), pcol() + 1 SAY STR( nTp_nvu, 12, 2 )
@ prow(), nCol3 := pcol() + 1 SAY STR( nTp_nvi, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nTp_nvs, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nTp_nvs - nNp_nvs, 12, 2 )

? " "
@ prow(), nCol2 SAY STR( nNp_iz, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nNp_st, 12, 2 )
@ prow(), nCol3 SAY STR( nNp_nvi, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nNp_nvs, 12, 2 )

? cLine

FF
END PRINT

return

// ---------------------------------------------
// ---------------------------------------------
static function r_zagl( cLine, nVar )
local cTxt := ""

if nVar == 1

cTxt += PADR( "rbr", 5)
cTxt += SPACE(1)
cTxt += PADR("roba (id/naziv)", 30 )
cTxt += SPACE(1)
cTxt += PADR( "ulaz", 12 )
cTxt += SPACE(1)
cTxt += PADR( "tp/np izlaz", 12 )
cTxt += SPACE(1)
cTxt += PADR( "tp/np stanje", 12 )
cTxt += SPACE(1)
cTxt += PADR("+/-", 12)
cTxt += SPACE(1)
cTxt += PADR( "NV ulaza", 12 )
cTxt += SPACE(1)
cTxt += PADR( "tp/np NV iz.", 12 )
cTxt += SPACE(1)
cTxt += PADR( "tp/np NV st.", 12 )
cTxt += SPACE(1)
cTxt += PADR( "+/-", 12 )

? "Kontrola sastavnica - sta bi bilo kad bi bilo...."
? "   - tp = tekuci promet"
? "   - np = novi promet"
? "   - (+/-) pokazatelj greske"
?

else

cTxt += PADR("rbr", 5 )
cTxt += SPACE(1)
cTxt += PADR( "broj dok.", 20)
cTxt += SPACE(1)
cTxt += PADR( "roba", 50)
cTxt += SPACE(1)
cTxt += PADR("st.", 4 )
cTxt += SPACE(1)
cTxt += PADR( "partner", 50 )
cTxt += SPACE(1)
cTxt += PADR( "kol.roba", 12 )
cTxt += SPACE(1)
cTxt += PADR( "kol.sast", 12 )

endif

P_COND2

? cLine
? cTxt
? cLine

return


// ----------------------------------------
// vraca liniju
// ----------------------------------------
static function g_line( nVar )
local cTxt := ""

if nVar == 1

  cTxt += REPLICATE( "-", 5)
  cTxt += SPACE(1)
  cTxt += REPLICATE("-", 30 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 )
  cTxt += SPACE(1) 
  cTxt += REPLICATE( "-", 12 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 ) 
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 )

else

  cTxt += REPLICATE( "-", 5)
  cTxt += SPACE(1)
  cTxt += REPLICATE("-", 20 )
  cTxt += SPACE(1)
  cTxt += REPLICATE("-", 50 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 4 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 50 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 )
  cTxt += SPACE(1)
  cTxt += REPLICATE( "-", 12 )

endif

return cTxt


// -----------------------------------------
// roba naziv - vraca
// -----------------------------------------
static function p_naz( id )
local nTArea := SELECT()
local cRet := "nepostojeca sifra"
select partn
go top
seek id

if FOUND()
	cRet := ALLTRIM( field->naz )
endif

select (nTArea)
return cRet



// -----------------------------------------
// roba naziv - vraca
// -----------------------------------------
static function r_naz( id )
local nTArea := SELECT()
local cRet := "nepostojeca sifra"
select roba
go top
seek id

if FOUND()
	cRet := ALLTRIM( field->naz )
endif

select (nTArea)
return cRet




