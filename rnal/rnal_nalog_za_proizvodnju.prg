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


#include "rnal.ch"


static LEN_IT_NO := 4
static LEN_DESC := 65

static LEN_QTTY := 10
static LEN_DIMENSION := 10
static LEN_VALUE := 10

static PIC_QTTY := "9999999.99"
static PIC_VALUE := "9999999.99"
static PIC_DIMENSION := "9999999.99"

static LEN_PAGE := 58

static RAZMAK := " "

static nPage := 0
static lPrintedTotal := .f.

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0

// ----------------------------------------------
// definicija linije za glavnu tabelu sa stavkama
// nVar - 1 = nalog
//        2 = obracunski list
// ----------------------------------------------
static function g_line( )
local cLine

// linija za naloge
cLine := RAZMAK
cLine += REPLICATE("-", LEN_IT_NO ) 
cLine += " " + REPLICATE("-", LEN_DESC)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_QTTY)

return cLine


// ------------------------------------------------------
// glavna funkcija za poziv stampe naloga za proizvodnju
// lStartPrint - pozovi funkcije stampe START PRINT
// -----------------------------------------------------
function nalpr_print( lStartPrint )
local aGroups := {}
local nCnt := 0
local i

// ako je nil onda je uvijek .t.
if ( lStartPrint == nil )
	lStartPrint := .t.
endif

LEN_QTTY := LEN(PIC_QTTY)
LEN_VALUE := LEN(PIC_VALUE)
LEN_DIMENSION := LEN(PIC_DIMENSION)

RAZMAK := SPACE(1)

t_rpt_open()

select t_docit
set order to tag "2"
go top
nDoc_no := field->doc_no

// izvuci sve grupe....
do while !EOF() .and. field->doc_no == nDoc_no
	
	// grupa dokumenta
	nDoc_gr := field->doc_gr_no
	
	do while !EOF() .and. field->doc_no == nDoc_no .and. ;
			field->doc_gr_no == nDoc_gr
		
		skip		
	enddo
	
	++ nCnt
	
	AADD(aGroups, { nDoc_gr, nCnt })
	
enddo

if !StartPrint(nil, nil)
	close all
	return
endif

for i:=1 to LEN( aGroups )
	
	// stampaj nalog za grupu....
	p_a4_nalpr( .f. , aGroups[i, 1], aGroups[i, 2], LEN(aGroups) )
	
	FF
next

EndPrint()

return


// -----------------------------------
// stampa naloga za proizvodnju
// -----------------------------------
function p_a4_nalpr(lStartPrint, nDoc_gr, nGr_cnt, nGr_total )
local lShow_zagl
local i
local nDocRbr := 0
local nCount := 0
local cDoc_it_type := ""
local cRekPrint
local lRekPrint := .f.

nDuzStrKorekcija := 0
lPrintedTotal := .f.

if lStartPrint

	if !StartPrint(nil, nil)
		close all
		return
	endif

endif

nTTotal := VAL(g_t_pars_opis("N10"))

cRekPrint := ALLTRIM(g_t_pars_opis("N20"))
if cRekPrint == "D"
	lRekPrint := .t.
endif

// zaglavlje naloga za proizvodnju
nalpr_header( nGr_cnt, nGr_total )

// podaci kupac i broj dokumenta itd....
nalpr_kupac()

B_ON

?

cLine := g_line(1)

// setuj len_ukupno
LEN_TOTAL := LEN( cLine )

select t_docit
set order to tag "1"
go top

// kondenzuj font
//P_COND

// stampaj grupu artikala naloga
s_art_group(nDoc_gr)

// print header tabele
s_tbl_header()

select t_docit
set order to tag "2"
nDoc_no := field->doc_no

seek docno_str( nDoc_no ) + STR(nDoc_gr, 2)

nPage := 1
aArt_desc := {}
nArt_id := 0
nArt_tmp := 0

lSh_art_desc := .f.
lSh_it_desc := .f.
cTmpItDesc := ""
cItDesc := ""

nCount := 0

// stampaj podatke 
do while !EOF() .and. field->doc_no == nDoc_no .and. field->doc_gr_no == nDoc_gr
	
	lAops := .f.
	
	//lSh_art_desc := .f.
	
	//nArt_id := field->art_id
	
	//if nArt_tmp <> nArt_id 
		
		//lSh_art_desc := .t.

	//endif

	// dodaj prored samo ako je drugi artikal
	if nCount > 0 .and. !EMPTY( field->art_desc ) //lSh_art_desc == .t.
	
		? cLine
	
	endif

	cDoc_no := docno_str( field->doc_no )
	cDoc_it_no := docit_str( field->doc_it_no )
	cDoc_It_type := field->doc_it_type
	
	// prikazuj naziv artikla
	if !EMPTY( field->art_desc )     //lSh_art_desc == .t.
		cArt_desc := ALLTRIM( field->art_desc )
	else
		cPom := "-//-"
		cArt_desc := PADC( cPom , 10 )
	endif
	
	aArt_desc := SjeciStr( cArt_desc, LEN_DESC )	
	
	// prvi red
	// 1) naziv i sifra artikla
	
	? RAZMAK
	
	// r.br
	?? PADL(ALLTRIM( STR( ++nDocRbr) ) + ")", LEN_IT_NO)
	
	?? " "
	
	// proizvod, naziv robe, jmj
	?? ALLTRIM( aArt_desc[1] ) + " " + REPLICATE(".", (LEN_DESC - 1 ) - LEN(ALLTRIM( aArt_desc[1]) ) )

	// ostatak naziva artikla....
	// drugi red
	
	if LEN(aArt_desc) > 1 
		
		for i:=2 to LEN(aArt_desc)
		
			? RAZMAK
			
			?? PADL("", LEN_IT_NO)
			
			?? " "
			
			?? aArt_desc[i]
	
			
			// provjeri za novu stranicu
			if prow() > LEN_PAGE - DSTR_KOREKCIJA()
				++ nPage
				Nstr_a4(nPage, .t.)
			endif	
		next
		
	endif
	
	// zatim obrade i napomene obrada, operacije
	
	select t_docop
	set order to tag "1"
	go top
	seek docno_str(t_docit->doc_no) + docit_str(t_docit->doc_it_no)

	
	do while !EOF() .and. field->doc_no == t_docit->doc_no ;
			.and. field->doc_it_no == t_docit->doc_it_no

	    // uzmi element
	    nDoc_el_no := field->doc_el_no
	    
	    nElDesc := 1
	    nElCount := 0
	    lSh_op_desc := .f.
	    lSh_oper := .f.
	    cOpTmpDesc := ""
	    cDoc_op_desc := ""
	
	    do while !EOF() .and. field->doc_no == t_docit->doc_no ;
	    		    .and. field->doc_it_no == t_docit->doc_it_no ;
			    .and. field->doc_el_no == nDoc_el_no
		
	 	cDoc_op_desc := ALLTRIM(field->doc_op_desc)
	    	
		// element...
		if nElDesc == 1 
			
			// provjeri za novu stranicu
			if prow() > LEN_PAGE - DSTR_KOREKCIJA()
				++ nPage
				Nstr_a4(nPage, .t.)
			endif			
			
			? RAZMAK
		    	?? PADL("", LEN_IT_NO)
			?? " "
		    	B_ON
			?? "obrada na " + STR( field->doc_el_no, 2 ) + ":" 
			B_OFF
	    		?? " "
	    		?? ALLTRIM( field->doc_el_desc )
			?? ", "
			// prikazi lot broj
			?? show_lot()
			
			// iskljuci ga do daljnjeg
			nElDesc := 0
	
			lAops := .t.
	
		endif
		
		// provjeri za novu stranicu
		if prow() > LEN_PAGE - DSTR_KOREKCIJA()
			++ nPage
			Nstr_a4(nPage, .t.)
		endif
		
		// operacije....
		
		? RAZMAK

		?? PADL("", LEN_IT_NO)

		?? " "
		
		if !EMPTY(field->aop_desc) .and. ALLTRIM(field->aop_desc) <> "?????"
			?? PADL( STR( ++ nElCount, 3), 3) + ")" + SPACE(1) + ALLTRIM(field->aop_desc)
		endif

		if !EMPTY(field->aop_att_desc) .and. ALLTRIM(field->aop_att_desc) <> "?????"
			?? ", "
			?? ALLTRIM(field->aop_att_desc)
			?? ", "
			?? ALLTRIM(field->aop_value)
			
		endif
		
		if !EMPTY(field->doc_op_desc) 
			
			cPom := "- napomene: "
			cPom += ALLTRIM( field->doc_op_desc )
			aPom := SjeciStr( cPom , 70 )
			
			for i:=1 to LEN( aPom )
				
				? RAZMAK
				?? PADR("", LEN_IT_NO)
				?? SPACE(5)
				?? aPom[ i ]
				
			next
			
		endif
		
		select t_docop
		
		skip
	   
	   enddo
	   
	enddo

	select t_docit
	

	// lot broj ako nema operacija itd...
	if lAops == .f. .and. !EMPTY( field->art_desc )
		
		// provjeri za novu stranicu
		if prow() > LEN_PAGE - DSTR_KOREKCIJA()
			
			++ nPage
			Nstr_a4(nPage, .t.)
		
    		endif	
		
		? RAZMAK
		?? PADL("", LEN_IT_NO)
		?? " "
		?? show_lot()
	
		lAops := .t.
	endif
	
		
	// zatim dimenzije 
	
	if lAops == .t.    
	
		// ako postoje obrade u artiklu dodaj tackice
	
		// provjeri za novu stranicu
		if prow() > LEN_PAGE - DSTR_KOREKCIJA()
			
			++ nPage
			Nstr_a4(nPage, .t.)
		
    		endif	
	
		? RAZMAK
		?? PADL("", LEN_IT_NO)
		?? " "
		?? REPLICATE(".", LEN_DESC  )
	
	endif
	
	?? " "
	
	if cDoc_it_type == "R"
	  
	  // prikazi fi
	  ?? PADL( show_fi( field->doc_it_width, field->doc_it_heigh ), 21 )
	
	elseif cDoc_it_type == "S"
		
	  ? RAZMAK
	  
	  ?? PADL( "", LEN_IT_NO )	
	  
	  ?? " "
	  
	  ?? PADR( "", LEN_DESC - 10 )
	  
	  ?? " " 
	  
	  // ovo moram podvuci u drugi red
	  
	  // sirina 1 / 2
	  ?? PADL( show_shape( field->doc_it_width, field->doc_it_w2 ), 15 )
	
	  ?? " "
	  
	  // visina 1 / 2
	  ?? PADL( show_shape( field->doc_it_heigh, field->doc_it_h2), 15 )
	  
	else
	
	  // sirina
	  ?? show_number(field->doc_it_width, nil, -10 )

	  ?? " "

	  // visina
 	  ?? show_number(field->doc_it_heigh, nil, -10 )
	
	endif
	
	?? " "

	// kolicina
	?? show_number(field->doc_it_qtty, nil, -10 )

	
	// napomene za item:
	// - napomene
	// - shema u prilogu

	if !EMPTY( field->doc_it_desc ) ;
		.or. field->doc_it_altt <> 0 ;
		.or. ( field->doc_it_schema == "D" )
	
		cPom := "Napomene: " + ;
			ALLTRIM( field->doc_it_desc )
		
		if field->doc_it_schema == "D"
		
			cPom += " "
			cPom += "(SHEMA U PRILOGU)"
		endif	

		// nadmorska visina
		if field->doc_it_altt <> 0
			
			if !EMPTY( field->doc_acity )
				cPom += "Montaza: "
				cPom += ALLTRIM(field->doc_acity)
			endif
			
			cPom += ", "
			cPom += "nadmorska visina = " + ALLTRIM(STR(field->doc_it_altt, 12, 2)) + " m"
		endif
	
		cItDesc := cPom
		
		lSh_it_desc := .f.
		
		if ALLTRIM(cTmpItDesc) <> ALLTRIM(cItDesc)
			lSh_it_desc := .t.
		endif
	
		if lSh_it_desc == .t.
		
		   aDoc_it_desc := SjeciStr( cItDesc , 100 )
		
		   for i:=1 to LEN(aDoc_it_desc)
						
			? RAZMAK
			?? PADL("", LEN_IT_NO)
			?? " "
			?? aDoc_it_desc[i]
		   
		   next
		
		endif
	endif
	
	select t_docit
	
	// provjeri za novu stranicu
	if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	
		++ nPage
		Nstr_a4(nPage, .t.)
		
    	endif	
	
	select t_docit
	skip

	cTmpItDesc := cItDesc
	
	++ nCount 
	
enddo

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++nPage
	Nstr_a4(nPage, .t.)
endif	

//? cLine

B_OFF

?

s_nal_izdao()

s_nal_footer()

// stampa rekapitulacije
s_nal_rekap( lRekPrint, nDoc_no )

if lStartPrint
	FF
	EndPrint()
endif

return


// ---------------------------------------
// stampa rekapitulacije na dnu naloga
// ---------------------------------------
function s_nal_rekap( lPrint, nDoc_no, lSpecif )
local cTmp
local nDoc

if lSpecif == nil
	lSpecif := .f.
endif

if lPrint == .f.
	return
endif

if nDoc_no == nil
	nDoc_no := 0
endif

select t_docit2

if RECCOUNT2() == 0
	return
endif

P_COND

?
? RAZMAK + "rekapitulacija dodatnog materijala:"
? RAZMAK + "-----------------------------------"

//if prow() > LEN_PAGE - DSTR_KOREKCIJA()
//	++nPage
//	Nstr_a4(nPage, .t.)
//endif	

go top

if nDoc_no > 0
	seek docno_str( nDoc_no )
endif

do while !EOF() 

	if nDoc_no > 0
		if field->doc_no <> nDoc_no
			skip
			loop
		endif
	endif

	nDoc := field->doc_no
	nDoc_it_no := field->doc_it_no

	// da li se treba stampati ?
	select t_docit
	seek docno_str(nDoc) + docit_str(nDoc_it_no)
	
	if field->print == "N"
		select t_docit2
		skip
		loop
	endif
	
	// vrati se
	select t_docit2

	//if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	//	++nPage
	//	Nstr_a4(nPage, .t.)
	//endif	
	
	? RAZMAK + "nalog: " + ALLTRIM(STR(nDoc)) + ;
		", stavka: " + ALLTRIM(STR(nDoc_it_no))
	? RAZMAK + "----------------------------"

	do while !EOF() .and. field->doc_no == nDoc ;
		.and. field->doc_it_no == nDoc_it_no
		
		// sifra i naziv stavke
		cTmp := "("
		cTmp += ALLTRIM(field->art_id)
		cTmp += ")"
		cTmp += " "
		cTmp += ALLTRIM(field->art_desc)
		
		// opis stavke
		cTmp2 := ALLTRIM( field->desc )
		aTmp2 := SjeciStr( cTmp2, 120 )

		//if prow() > LEN_PAGE - DSTR_KOREKCIJA()
		//	++nPage
		//	Nstr_a4(nPage, .t.)
		//endif	

		? RAZMAK
		?? ALLTRIM(STR(field->it_no)) + "."
		?? " "
		?? PADR( cTmp, 40 )
		?? " kol.=", ALLTRIM( STR( field->doc_it_qtty, 12, 2) )
		
		if !EMPTY( cTmp2 )
			
			? RAZMAK + SPACE(2) + "op: "
			
			for i := 1 to LEN( aTmp2 )
				
				if i > 1
					? RAZMAK + SPACE(6)
				endif
				
				?? aTmp2[ i ]

				//if prow() > LEN_PAGE - DSTR_KOREKCIJA()
				//	++nPage
				//	Nstr_a4(nPage, .t.)
				//endif	
			next
		endif

		skip
	enddo

enddo

return


// -----------------------------------------
// vraæa string LOT broja
// -----------------------------------------
static function show_lot()
local cReturn := ""

cReturn += "proizv.: ______________"
cReturn += ","
cReturn += "LOT: _____________"

return cReturn




// --------------------------------------------
// prikaz fi iznosa na nalogu
// --------------------------------------------
static function show_fi( nWidth, nHeigh )
local nFi := nWidth
local nFi2 := nHeigh
local cTmp := ""

if ( nFi + nFi2 ) = 0
	return cTmp
endif

cTmp := "fi= "

if nFi == nFi2
	cTmp += ALLTRIM(STR( nFi, 12, 2 )) 
else
	cTmp += ALLTRIM(STR( nFi, 12, 2)) + ", " + ;
		ALLTRIM(STR( nFi2, 12, 2))
endif

return cTmp




// --------------------------------------------
// prikaz shaped iznosa na nalogu
// --------------------------------------------
static function show_shape( nD1, nD2 )
local cTmp := ""

cTmp := ALLTRIM( STR( nD1, 12, 2 ) )
cTmp += "/"
cTmp += ALLTRIM( STR( nD2, 12, 2 ) )

return cTmp



// ----------------------------------------
// stampanje grupe artikala naloga
// ----------------------------------------
static function s_art_group( nGr )
? RAZMAK + "grupa artikala: (" + ALLTRIM(STR(nGr)) + ") - " + get_art_docgr( nGr )
return



// -------------------------------------------
// stampa potpisa nalog izdao
// -------------------------------------------
static function s_nal_izdao()
local cPom := ""
local cOper := ""

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

// izvuci operatera iz PARS
cOper := g_t_pars_opis("N13")

// nalog izdao
cPom += "Nalog izdao: "
cPom += PADC( cOper, 20 )
cPom += ", stampao: "
cPom += PADC( getfullusername( getUserid( goModul:oDataBase:cUser ) ), 20 )
cPom += " "
cPom += "Vrijeme: "
cPom += PADR( TIME(), 5 )

? PADL(cPom, LEN_TOTAL)

return


// ----------------------------------------
// nalog footer...
// ----------------------------------------
static function s_nal_footer()
local cPom
local cPayDesc := ""
local cPayed := ""
local cPayAddDesc := ""

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

cPayDesc := g_t_pars_opis("N06")
cPayed := g_t_pars_opis("N10")
cPayAddDesc := g_t_pars_opis("N11")

// footer
// vrsta placanja
? RAZMAK + "Vrsta placanja: " + cPayDesc

// placeno D/N
if !EMPTY(cPayed) .and. ALLTRIM(cPayed) <> "-"

	cPom := "Placeno: "
	
	if cPayed == "D"
		cPom += "DA"
	else
		cPom += "NE"
	endif
	
	? RAZMAK + cPom
	
endif

// dodatne napomene placanje
if !EMPTY(cPayAddDesc) .and. ALLTRIM(cPayAddDesc) <> "-"
		
	cPom := "Napomene za placanje: "
	cPom += cPayAddDesc

	? RAZMAK + cPom
		
endif

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

// oznacene pozicije na nalogu
cPom := "Oznacene pozicije:"
cPom += "      "
cPom += "DA  /  NE"

? RAZMAK + cPom

// konacan proizvod
cPom := "Konacan proizvod: "
cPom += "  VALIDAN  "
cPom += "  NIJE VALIDAN  "
cPom += " ovjerio: __________________ "
cPom += ", vrijeme: _____________"

? RAZMAK + cPom

?
?

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
	++ nPage
	Nstr_a4(nPage, .t.)
endif	

// potvrda narudzbe

cPom := "Narucilac potvrdjuje narudzbu:"
cPom += " "
cPom += "_______________"
cPom += " "
cPom += "  Datum:"
cPom += " "
cPom += "_________"

? RAZMAK + cPom

return



// -----------------------------------------
// zaglavlje glavne tabele sa stavkama
// -----------------------------------------
static function s_tbl_header()
local cLine
local cRow1

cLine := g_line(1)

? cLine

cRow1 := RAZMAK 
cRow1 += PADC("r.br", LEN_IT_NO) 
cRow1 += " " + PADR("artikal/naziv/element/operacije/napomene", LEN_DESC)
cRow1 += " " + PADC("sirina(mm)", LEN_DIMENSION)
cRow1 += " " + PADC("visina(mm)", LEN_DIMENSION)
cRow1 += " " + PADC("kol. (kom)", LEN_QTTY)

? cRow1

? cLine

return


// -----------------------------------------
// funkcija za ispis headera
// -----------------------------------------
function nalpr_header( nDocGr, nDocGrTot )
local cDLHead 
local cSLHead 
local cINaziv
local cRazmak := SPACE(2)
local cDoc_no

// broj dokumenta
cDoc_no := g_t_pars_opis("N01")

// naziv
cINaziv := ALLTRIM(gFNaziv)
cINaziv += " : "
cINaziv += "NALOG ZA PROIZVODNJU br."
cINaziv += cDoc_no
cINaziv += " "
cINaziv += "(" 
cINaziv += ALLTRIM(STR(nDocGr)) 
cINaziv += "/" 
cINaziv += ALLTRIM(STR(nDocGrTot)) 
cINaziv += ")"

// double line header
cDLHead := REPLICATE("=", 70)

// single line header
cSLHead := REPLICATE("-", LEN(gFNaziv))

// prvo se pozicioniraj na g.marginu
for i:=1 to gDg_margina
	?
next

p_line(cRazmak + cDlhead, 10, .t.)
p_line(cRazmak + cINaziv, 10, .t.)
p_line(cRazmak + cDlhead, 10, .t.)

?

return



// ----------------------------------------------
// funkcija za ispis podataka o kupcu
// dokument, datumi, hitnost itd..
// ----------------------------------------------
static function nalpr_kupac()
local cDoc_date
local cDoc_time
local cDoc_dvr_date
local cDoc_dvr_time
local cDoc_ship_place
local cPriority
local cCust_desc
local cCust_addr
local cCust_tel
local cContId
local cCont_desc
local cCont_tel
local cContadesc
local cCont_add_desc
local cObjId
local cObj_desc
local cDoc_no
local cRazmak := SPACE(2)
local nLeft := 15
local nRight := 8
local i
local cPom
local aPom

cDoc_date := g_t_pars_opis("N02")
cDoc_time := g_t_pars_opis("N12")
cDoc_dvr_date := g_t_pars_opis("N03")
cDoc_dvr_time := g_t_pars_opis("N04")
cPriority := g_t_pars_opis("N05")
cDoc_ship_place := g_t_pars_opis("N07")
cDoc_add_desc := g_t_pars_opis("N08")

// get/set customer data
cCustId := g_t_pars_opis("P01")
cCust_desc := g_t_pars_opis("P02")
cCust_addr := g_t_pars_opis("P03")
cCust_tel := g_t_pars_opis("P04")

// get/set contacts data
cContId := g_t_pars_opis("P10")
cCont_desc := g_t_pars_opis("P11")
cCont_tel := g_t_pars_opis("P12")
cContadesc := g_t_pars_opis("P13")
cCont_add_desc := g_t_pars_opis("N09")

// get/set objects data
cObjId := g_t_pars_opis("P20")
cObj_desc := g_t_pars_opis("P21")

B_OFF

// doc_date + doc_time + doc_dvr_date + doc_dvr_time
cPom := "Datum/vrijeme naloga: "
cPom += cDoc_date
cPom += " "
cPom += cDoc_time
cPom += ",  "
cPom += "Datum/vrijeme isporuke: "
cPom += cDoc_dvr_date
cPom += " "
cPom += cDoc_dvr_time

p_line(cRazmak + cPom, 12, .f.)


// priority + sh_place
cPom := "Prioritet: "
cPom += cPriority
cPom += ", "
cPom += "Objekat: "
cPom += cObj_desc 
cPom += ", "
cPom += "Mjesto isp.: "
cPom += cDoc_ship_place
	
aPom := SjeciStr( cPom, 100 )

for i:=1 to LEN( aPom )

	p_line(cRazmak + aPom[i], 12, .f.)

next
	
// podaci narucioca
cPom := "Narucioc: "
cPom += ALLTRIM(cCust_desc) 
cPom += ", " 
cPom += ALLTRIM(cCust_addr) 
cPom += ", tel: " 
cPom += ALLTRIM(cCust_tel)

p_line( cRazmak + cPom, 12, .f.)

// podaci kontakta
cPom := "Kontakt: "
cPom += " " + ALLTRIM(cCont_desc) + " (" + ALLTRIM(cContadesc) + "), " + ALLTRIM("tel: " + cCont_tel) + ", " + ALLTRIM(cCont_add_desc)

aPom := SjeciStr( cPom, 100 )

for i:=1 to LEN( aPom )
	
	p_line( cRazmak + aPom[i] , 12, .f. )

next

// ostale napomene naloga...
if !EMPTY( cDoc_add_desc )
	
	cPom := "Ostale napomene: " + ALLTRIM( cDoc_add_desc )
	
	aPom := SjeciStr( cPom, 100 )

	for i:=1 to LEN( aPom )
		p_line( cRazmak + aPom[i] , 12, .f.)
	next

endif

return



// -----------------------------------------
// funkcija za novu stranu
// -----------------------------------------
function NStr_a4(nPage, lShZagl)
local cLine

cLine := g_line(1)

// korekcija duzine je na svako strani razlicita
nDuzStrKorekcija := 0 

//P_COND

? cLine
p_line( " Prenos na sljedecu stranicu", 12, .f. )
? cLine

FF

//P_COND

? cLine
if nPage <> nil
	p_line( "       Strana:" + str(nPage, 3), 12, .f.)
endif
? cLine

return


// --------------------------------
// korekcija za duzinu strane
// --------------------------------
function DSTR_KOREKCIJA()
local nPom

nPom := ROUND(nDuzStrKorekcija, 0)
if ROUND(nDuzStrKorekcija - nPom, 1) > 0.2
	nPom ++
endif

return nPom



