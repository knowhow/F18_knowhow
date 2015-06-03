/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fakt.ch"

// -------------------------------------------------------------------
// -------------------------------------------------------------------
function FaStanje(cIdRj, cIdroba, nUl, nIzl, nRezerv, nRevers, lSilent)

if (lSilent==nil)
	lSilent:=.f.
endif

select fakt

//"3","idroba+dtos(datDok)","FAKT"

set order to tag "3"

if (!lSilent)
	lBezMinusa:=(IzFMKIni("FAKT","NemaIzlazaBezUlaza","N",KUMPATH) == "D" )
endif

if (roba->tip=="U")
	return 0
endif

if (!lSilent)
	MsgO("Izracunavam trenutno stanje ...")
endif

seek cIdRoba

nUl:=0
nIzl:=0
nRezerv:=0
nRevers:=0

do while (!EOF() .and. cIdRoba==field->idRoba)
	if (fakt->idFirma<>cIdRj)
		SKIP
		loop
	endif
	if (LEFT(field->idTipDok,1)=="0")
		// ulaz
		nUl+=kolicina
	elseif (LEFT(field->idTipDok,1)=="1")   
		// izlaz faktura
		if !(left(field->serBr,1)=="*" .and. field->idTipDok=="10")  
			nIzl += field->kolicina
		endif
	elseif (field->idTipDok $ "20#27")
		if (LEFT(field->serBr,1)=="*")
			nRezerv += field->kolicina
		endif
	elseif (field->idTipDok=="21")
			nRevers += field->kolicina
	endif
	skip
enddo

if (!lSilent)
	MsgC()
endif

return


function fakt_mpc_iz_sifrarnika()
local nCV:=0

if rj->( FIELDPOS("tip")) <> 0

    if RJ->tip=="N1"
	    nCV := roba->nc
    elseif RJ->tip=="M1"
	    nCV := roba->mpc
    elseif RJ->tip=="M2"
	    nCV := roba->mpc2
    elseif RJ->tip=="M3"
    	nCV := roba->mpc3
    elseif RJ->tip=="M4"
    	nCV := roba->mpc4
    elseif RJ->tip=="M5"
    	nCV := roba->mpc5
    elseif RJ->tip=="M6"
    	nCV := roba->mpc6
    else
	    if IzFMKINI("FAKT","ZaIzvjestajeDefaultJeMPC","N",KUMPATH)=="D"
      		nCV := roba->mpc
    	else
      		nCV := roba->vpc
    	endif
    endif
else
    nCV := roba->vpc
endif

return nCV


 
function fakt_vpc_iz_sifrarnika()
local nCV:=0

if rj->tip=="V1"
    	nCV := roba->vpc
elseif rj->tip=="V2"
    	nCV := roba->vpc2
else
	if IzFMKINI("FAKT","ZaIzvjestajeDefaultJeMPC","N",KUMPATH)=="D"
      		nCV := roba->mpc
    	else
      		nCV := roba->vpc
    	endif
endif
return nCV


// -------------------------------------------------
// -------------------------------------------------
function IsDocExists(cIdFirma, cIdTipDok, cBrDok)
local nArea
local lRet

lRet:=.f.

PushWa()
nArea:=SELECT()
select fakt_doks
set order to tag "1"
HSEEK cIdFirma+cIdTipDok+cBrDok
if FOUND()
	lRet:=.t.
endif
SELECT(nArea)
PopWa()
return lRet

// -------------------------------------------------
// -------------------------------------------------
function SpeedSkip()

nSeconds:=SECONDS()

nKrugova:=1
Box(,3,50)
	@ m_x+1,m_y+2 SAY "Krugova:" GET nKrugova
	read
BoxC()


O_FAKT
set order to tag "1"

i:=0
for j:=1 to nKrugova
go top

? "krug broj", j
do while !eof()
	i=i+1
	if i % 150 = 0
		? j, i, recno(), idFirma, idTipDok, brDok, "SEC:", SECONDS()-nSeconds
	endif	

	//OL_Yield()
	nKey:=INKEY()
	
	if (nKey==K_ESC)
		CLOSE ALL 
		RETURN
	endif

	SKIP
enddo
next

MsgBeep("Vrijeme izvrsenja:" + STR( SECONDS()-nSeconds ) )

return



// ----------------------------------------------
// napuni sifrarnik sifk  sa poljem za unos 
// podatka o PDV oslobadjanju 
// ---------------------------------------------
function fill_part()
local lFound
local cSeek
local cNaz
local cId
local cOznaka

SELECT (F_SIFK)

if !used()
	O_SIFK
endif

SET ORDER TO TAG "ID"
//id+SORT+naz


cId := PADR("PARTN", 8) 
cNaz := PADR("PDV oslob. ZPDV", LEN(naz))
cRbr := "08"
cOznaka := "PDVO"
add_n_found(cId, cNaz, cRbr, cOznaka, 3)

cId := PADR("PARTN", 8) 
cNaz := PADR("Profil partn.", LEN(naz))
cRbr := "09"
cOznaka := "PROF"
add_n_found(cId, cNaz, cRbr, cOznaka, 25)

return


// -------------------------------------------
// -------------------------------------------
static function add_n_found(cId, cNaz, cRbr, cOznaka, nDuzina)
local cSeek

cSeek :=  cId + cRbr + cNaz
SEEK cSeek   

if !FOUND()
	APPEND BLANK
	replace id with cId ,;
		naz with cNaz ,;
		oznaka with cOznaka ,;
		sort with  cRbr,;
		veza with "1" ,;
		tip with "C" ,;
		duzina with nDuzina,;
		f_decimal with 0
endif

return


// ------------------------------------------------------------
// provjerava da li dokument postoji na strani servera 
// ------------------------------------------------------------
function fakt_doks_exist( firma, tip_dok, br_dok )
local _exist := .f.
local _qry, _qry_ret, _table
local _server := pg_server()

_qry := "SELECT COUNT(*) FROM fmk.fakt_doks WHERE idfirma = " + _sql_quote( firma ) + " AND idtipdok = " + _sql_quote( tip_dok ) + " AND brdok = " + _sql_quote( br_dok )
_table := _sql_query( _server, _qry )
_qry_ret := _table:Fieldget(1)

if _qry_ret > 0
    _exist := .t.
endif

return _exist


