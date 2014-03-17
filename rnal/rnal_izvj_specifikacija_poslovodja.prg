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


static __nvar
static __doc_no
static __temp


// ------------------------------------------
// osnovni poziv specifikacije
// ------------------------------------------
function m_get_spec( nVar )
local _params

if nVar == nil
	nVar := 0
endif

__nVar := nVar

// gledaj kumulativne tabele
__temp := .f.

// daj uslove izvjestaja
if _g_vars( @_params ) == 0
	return 
endif

// kreiraj specifikaciju po uslovima
_cre_spec( _params )

// printaj specifikaciju
_p_rpt_spec( _params )

return



// ----------------------------------------
// uslovi izvjestaja specifikacije
// ----------------------------------------
static function _g_vars( params )
local _ret := 1
local _box_x := 18
local _box_y := 70
local _x := 1
local _statusi, _tip_datuma
local _dat_od, _dat_do, _group, _operater

private GetList := {}

_statusi := fetch_metric("rnal_spec_posl_status", NIL, "N" )
_tip_datuma := fetch_metric("rnal_spec_posl_tip_datuma", my_user(), 2 )

_dat_od := DATE()
_dat_do := DATE()
_group := 0
_operater := 0

Box(, _box_x, _box_y )

	@ m_x + _x, m_y + 2 SAY "*** Specifikacija radnih naloga za poslovodje"
	
    ++ _x
    ++ _x
	
	@ m_x + _x, m_y + 2 SAY "Datum od:" GET _dat_od
	@ m_x + _x, col() + 1 SAY "do:" GET _dat_do

	++ _x
    ++ _x
	
	@ m_x + _x, m_y + 2 SAY "Operater (0 - svi op.):" GET _operater VALID {|| _operater == 0  } PICT "9999999999"
	
	++ _x
    ++ _x
	
	@ m_x + _x, m_y + 2 SAY "*** Selekcija grupe artikala "

	++ _x

	@ m_x + _x, m_y + 2 SAY "(1) - rezano          (4) - IZO"
	
	++ _x
	
	@ m_x + _x, m_y + 2 SAY "(2) - kaljeno         (5) - LAMI"
	
	++ _x
	
	@ m_x + _x, m_y + 2 SAY "(3) - bruseno         (6) - emajlirano"
	
	++ _x

	@ m_x + _x, m_y + 2 SAY "Grupa artikala (0 - sve grupe):" GET _group VALID _group >= 0 .and. _group < 7 PICT "9"

    ++ _x
    ++ _x

	@ m_x + _x, m_y + 2 SAY "Gledati statuse 'realizovano' (D/N) ?" GET _statusi VALID _statusi $ "DN" PICT "@!"

    ++ _x

	@ m_x + _x, m_y + 2 SAY "Gledati datum naloga ili datum isporuke (1/2) ?" GET _tip_datuma PICT "9"
	
	read

BoxC()

if LastKey() == K_ESC
	_ret := 0
    return _ret
endif

// snimi parametre
set_metric("rnal_spec_posl_status", NIL, _statusi )
set_metric("rnal_spec_posl_tip_datuma", my_user(), _tip_datuma )

params := hb_hash()
params["datum_od"] := _dat_od
params["datum_do"] := _dat_do
params["tip_datuma"] := _tip_datuma
params["group"] := _group
params["operater"] := _operater
params["gledaj_statuse"] := _statusi

params["idx"] := "D1"

if _tip_datuma == 2
    params["idx"] := "D2"
endif

return _ret



// ----------------------------------------------
// kreiraj specifikaciju
// izvjestaj se primarno puni u _tmp0 tabelu
// ----------------------------------------------
static function _cre_spec( params )
local nDoc_no
local nArt_id
local aArtArr := {}
local nCount := 0
local cCust_desc
local aField
local nScan
local ii
local cAop
local cAopDesc
local aGrCount := {}
local nGr1 
local nGr2
local _glass_count := 0

// kreiraj tmp tabelu
aField := _spec_fields()

cre_tmp1( aField )
o_tmp1()

// otvori potrebne tabele
o_tables( .f. )

_main_filter( params )

Box(, 1, 50 )

do while !EOF()

	nDoc_no := field->doc_no
	__doc_no := nDoc_no
	
	cCust_desc := ALLTRIM( g_cust_desc( docs->cust_id ) )
	
	if "NN" $ cCust_desc
		cCust_desc := cCust_Desc + "/" + ;
			ALLTRIM( g_cont_desc( docs->cont_id ) )
	endif
	
	cDoc_stat := g_doc_status( docs->doc_status )
	
	cDoc_oper := getusername( docs->operater_i )

	cDoc_prior := s_priority( docs->doc_priori )
	
	// get log if exist
	select doc_log
	set order to tag "1"
	go top

	seek docno_str( nDoc_no )

	cLog := ""
	
	do while !EOF() .and. field->doc_no == nDoc_no
		
		cLog := DTOC( field->doc_log_da ) 
		cLog += " / " 
		cLog += ALLTRIM( field->doc_log_ti )
		cLog += " : "
		cLog += ALLTRIM( field->doc_log_de )
		
		skip
	enddo
	
	// samo za log, koji nije inicijalni....
	if "Inicij" $ cLog
		cLog := ""
	endif
	
	select doc_it
	set order to tag "1"
	go top
	seek docno_str( nDoc_no )

	do while !EOF() .and. field->doc_no == nDoc_no
		
		nArt_id := field->art_id
		nDoc_it_no := field->doc_it_no
		nQtty := field->doc_it_qtt
		
		// matrica sa stavkama i elementima artikla
		aArtDesc := {}

		// napuni matricu aArtDesc radi podataka o artiklu !
		_art_set_descr( nArt_id, nil, nil, @aArtDesc, .t. )
      
        // sracunaj broj stakala
        _glass_count := broj_stakala( aArtDesc, nQtty )

		// check group of item
		// "0156" itd...
		cIt_group := set_art_docgr( nArt_id, nDoc_no, nDoc_it_no )
		
		cDiv := ALLTRIM( STR( LEN(cIt_group) ) )
		
		cDoc_div := "(" + cDiv + "/" + cDiv + ")"
	
		// uzmi operaciju za ovu stavku naloga....
		// if exist
		
		cAop := " "
		
		select doc_ops
		set order to tag "1"
		go top
		seek docno_str( nDoc_no ) + docit_str( nDoc_it_no)
		
		aAop := {}

		do while !EOF() .and. field->doc_no == nDoc_no ;
				.and. field->doc_it_no == nDoc_it_no

			cAopDesc := ALLTRIM( g_aop_desc( field->aop_id) )

			nScan := ASCAN( aAop, {|xVal| xVal[1] == cAopDesc } )
			
			if nScan == 0
				
				AADD(aAop, {cAopDesc} )
				
			endif
			
			skip
		
		enddo

		cAop := ""
		
		if LEN(aAop) > 0
		
			for ii := 1 to LEN( aAop )
				
				if ii <> 1
					cAop += "#"
				endif
				
				cAop += aAop[ ii, 1 ] 
			next
		
		endif

		// provjeri da li je artikal LAMI-RG staklo ?
		lIsLami := is_lami( aArtDesc )

		if lIsLami == .t.
			if !EMPTY(cAop)
				cAop += "#"
			endif
			cAop += "lami-rg"
		endif

		select doc_it

		// item description
		cItem := ALLTRIM( g_art_desc( nArt_id ) )
		cItemAop := cAop
		
		nGr1 := VAL( SUBSTR( cIt_group, 1, 1 ) )
	
		_ins_tmp1( nDoc_no, ;
			cCust_desc, ;
			docs->doc_date , ;
			docs->doc_dvr_da, ;
			docs->doc_dvr_ti, ;
			cDoc_stat, ;
			cDoc_prior, ;
			cDoc_div, ;
			docs->doc_desc, ;
			docs->doc_sh_des, ;
			cDoc_oper, ;
			nQtty, ;
            _glass_count, ;
			cItem, ;
			cItemAop, ;
			nGr1, ;
			cLog )

		// ako ima vise grupa...

		if LEN( cIt_group ) > 1 

		    for xx := 1 to LEN( cIt_group )
                       
		       if VAL(SUBSTR(cIt_group, xx, 1)) == nGr1
		       	  loop
		       endif

			_ins_tmp1( nDoc_no, ;
			cCust_desc, ;
			docs->doc_date , ;
			docs->doc_dvr_da, ;
			docs->doc_dvr_ti, ;
			cDoc_stat, ;
			cDoc_prior, ;
			cDoc_div, ;
			docs->doc_desc, ;
			docs->doc_sh_des, ;
			cDoc_oper, ;
			nQtty, ;
            _glass_count, ;
			cItem, ;
			cItemAop, ;
			VAL(SUBSTR(cIt_group, xx, 1)), ;
			cLog )
		    
		    next
		
		endif

		++ nCount
		
		@ m_x + 1, m_y + 2 SAY "datum isp./nalog broj: " + DTOC(docs->doc_dvr_da) + " / " + ALLTRIM( STR(nDoc_no) )
	
		skip
		
	enddo
	
	select docs
	skip
	
enddo

BoxC()


return


static function _main_filter( params )
local _filter := ""
local _date := "doc_date"
local _dat_od := params["datum_od"]
local _dat_do := params["datum_do"]
local _tip_datuma := params["tip_datuma"]
local _group := params["group"]
local _oper := params["operater"]
local _idx := params["idx"]
local _statusi := params["gledaj_statuse"]

if _tip_datuma == 2
    _date := "doc_dvr_da"
else
    _date := "doc_date"
endif

if _statusi == "N"
    // necemo gledati statuse, prikazi sve naloge
    _filter += "( doc_status == 0 .or. doc_status > 2 )"
else
    // gledaju se prakticno stamo otvoreni
    _filter += "( doc_status == 0 .or. doc_status == 4 ) "
endif

_filter += " .and. DTOS( " + _date + " ) >= " + _filter_quote( DTOS( _dat_od ) )
_filter += " .and. DTOS( " + _date + " ) <= " + _filter_quote( DTOS( _dat_do ) )

if _oper <> 0
	_filter += " .and. ALLTRIM( STR( operater_i ) ) == " + cm2str( ALLTRIM( STR( _oper ) ) )
endif

select docs
set order to tag &_idx
set filter to &_filter
go top
	
return





// ------------------------------------------
// stampa specifikacije
// stampa se iz _tmp0 tabele
// ------------------------------------------
static function _p_rpt_spec( params )
local i
local ii
local nScan
local aItemAop
local cPom
local _group := params["group"]

START PRINT CRET

?
P_COND2

// naslov izvjestaja
_rpt_descr()
// info operater, datum
__rpt_info()
// header
_rpt_head()

select _tmp1
go top

do while !EOF()
	
	if _group <> 0
		// preskoci ako filterises po grupi
		if field->it_group <> _group
			skip
			loop			
		endif
	endif

	if _nstr() == .t.
		FF
	endif
	
	// pripremi varijable za ispis...
	nDoc_no := field->doc_no
	
	cCustDesc := field->cust_desc
	
	cDate := DTOC( field->doc_date ) + "/" + ;
		DTOC( field->doc_dvr_d )
	
	cDescr := ALLTRIM( field->doc_prior ) + " - " + ;
		ALLTRIM( field->doc_stat ) + " - " + ;
		ALLTRIM( field->doc_oper ) + " - (" + ;
		ALLTRIM( field->doc_sdesc ) + " )"


	nCount := 0
	
	nTotQtty := 0
    nTotGlQtty := 0
	cItemAop := ""

	aItemAop := {}
	nScan := 0
	
	// sracunaj kolicinu artikala na nalogu
	do while !EOF() .and. field->doc_no == nDoc_no
		
		++ nCount
		
		nTotQtty += field->qtty
	    nTotGlQtty += field->glass_qtty

		// dodatna operacija stavke
		cItemAop := ALLTRIM( field->doc_aop )
		
		if !EMPTY( cItemAop )
			
			// razbij string "brusenje#poliranje#kaljenje#" 
			// -> u matricu
			aPom := TokToNiz( cItemAop, "#" )
			
			for ii:=1 to LEN(aPom)
			
				nScan := ASCAN( aItemAop, ;
					{|xVar| aPom[ii] == xVar[1] })
		
				if nScan = 0
					AADD(aItemAop, { aPom[ii] })
				endif
			next
		endif
		
		// divizor
		cDiv := ALLTRIM( field->doc_div )
		
		// zapamti i log
		cLog := ALLTRIM( field->doc_log ) 
		
		skip
	enddo
	
	// dodaj divizora na veliki opis...
	cDescr := cDiv + " - " + cDescr

	// ispisi prvu stavku

	// broj dokumenta
	? docno_str( nDoc_no )
	
	// partner / naruèioc / kontakt
	@ prow(), pcol() + 1 SAY PADR( cCustDesc, 30 )
	
	// datumi - isporuka
	@ prow(), pcol() + 1 SAY PADR( cDate , 17 ) 
	
	// prioritet, statusi, operater ....
	@ prow(), pcol() + 1 SAY " " + PADR( cDescr , 100 )

	? SPACE(10)
	
	@ prow(), pcol() + 1 SAY "kom.na nalogu: " + ALLTRIM(STR( nTotQtty, 12 )) + ;
                            " broj stakala: " + ALLTRIM( STR( nTotGlQtty, 12 ) )
	
	// dodatne operacije stavke...
	if LEN(aItemAop) > 0
		
		cPom := ""
		
		for i:=1 to LEN(aItemAop)
			if i <> 1
				cPom += ", "
			endif
			cPom += aItemAop[i, 1]
		next
	
		@ prow(), pcol() + 1 SAY ", op.: " + cPom
	
	endif
	
	// upisi i log na kraju ako postoji
	if !EMPTY( cLog )
		
		? SPACE(10)
		
		@ prow(), pcol() + 2 SAY "zadnja promjena: "
		
		@ prow(), pcol() + 1 SAY cLog
		
	endif

	?

enddo

close all

FF
END PRINT

return


// -----------------------------------
// provjerava za novu stranu
// -----------------------------------
static function _nstr()
local lRet := .f.

if prow() > 62
	lRet := .t.
endif

return lRet



// ------------------------------------------------
// ispisi naziv izvjestaja po varijanti
// ------------------------------------------------
static function _rpt_descr()
local cTmp := "rpt: "

do case
	case __nvar == 1
		cTmp += "SPECIFIKACIJA NALOGA ZA POSLOVODJE"

	otherwise
		cTmp += "WITH NO NAME"
endcase

? cTmp

return


// -------------------------------------------------
// header izvjestaja
// -------------------------------------------------
static function _rpt_head()

cLine := REPLICATE("-", 10) 
cLine += SPACE(1)
cLine += REPLICATE("-", 30)
cLine += SPACE(1)
cLine += REPLICATE("-", 17)
cLine += SPACE(1)
cLine += REPLICATE("-", 100)

cTxt := PADR("Nalog br.", 10)
cTxt += SPACE(1)
cTxt += PADR("Partner", 30)
cTxt += SPACE(1)
cTxt += PADR("Termini", 17)
cTxt += SPACE(1)
cTxt += PADR("Ostale info (divizor - prioritet - status - operater - opis)", 100)

? cLine
? cTxt
? cLine

return



// -----------------------------------------------
// vraca strukturu polja tabele _tmp1
// -----------------------------------------------
static function _spec_fields()
local aDbf := {}

AADD( aDbf, { "doc_no", "N", 10, 0 })
AADD( aDbf, { "cust_desc", "C", 50, 0 })
AADD( aDbf, { "doc_date", "D", 8, 0 })
AADD( aDbf, { "doc_dvr_d", "D", 8, 0 })
AADD( aDbf, { "doc_dvr_t", "C", 10, 0 })
AADD( aDbf, { "doc_stat", "C", 30, 0 })
AADD( aDbf, { "doc_prior", "C", 30, 0 })
AADD( aDbf, { "doc_oper", "C", 30, 0 })
AADD( aDbf, { "doc_div", "C", 20, 0 })
AADD( aDbf, { "doc_desc", "C", 100, 0 })
AADD( aDbf, { "doc_sdesc", "C", 100, 0 })
AADD( aDbf, { "doc_item", "C", 250, 0 })
AADD( aDbf, { "doc_aop", "C", 250, 0 })
AADD( aDbf, { "qtty", "N", 15, 5 })
AADD( aDbf, { "glass_qtty", "N", 15, 5 })
AADD( aDbf, { "it_group", "N", 5, 0 })
AADD( aDbf, { "doc_log", "C", 200, 0 })

return aDbf


// -----------------------------------------------------
// insert into _tmp1
// -----------------------------------------------------
static function _ins_tmp1( nDoc_no, cCust_desc, dDoc_date, dDoc_dvr_d, ;
		cDoc_dvr_t, ;
		cDoc_stat, cDoc_prior, ;
		cDoc_div, cDoc_desc, cDoc_sDesc, cDoc_oper, ;
		nQtty, nGl_qtty, cDoc_item, cDoc_aop ,nIt_group, cDoc_log )

local nTArea := SELECT()

select _tmp1
APPEND BLANK

replace field->doc_no with nDoc_no
replace field->cust_desc with cCust_desc
replace field->doc_date with dDoc_date
replace field->doc_dvr_d with dDoc_dvr_d
replace field->doc_dvr_t with cDoc_dvr_t
replace field->doc_stat with cDoc_stat
replace field->doc_prior with cDoc_prior
replace field->doc_oper with cDoc_oper
replace field->doc_div with cDoc_div
replace field->doc_desc with cDoc_desc
replace field->doc_sdesc with cDoc_sdesc
replace field->doc_item with cDoc_item
replace field->doc_aop with cDoc_aop
replace field->qtty with nQtty
replace field->glass_qtty with nGl_qtty
replace field->it_group with nIt_group
replace field->doc_log with cDoc_log

select (nTArea)
return



