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
// resetuje brojač dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
function fakt_reset_broj_dokumenta( firma, tip_dokumenta, broj_dokumenta )
local _param
local _broj := 0

// param: fakt/10/10
_param := "fakt" + "/" + firma + "/" + tip_dokumenta 
_broj := fetch_metric( _param, nil, _broj )

if VAL( PADR( broj_dokumenta, gNumDio ) ) == _broj
    -- _broj
    // smanji globalni brojac za 1
    set_metric( _param, nil, _broj )
endif

return



// ---------------------------------------------------------------
// vraca prazan broj dokumenta
// ---------------------------------------------------------------
function fakt_prazan_broj_dokumenta()
return PADR( PADL( ALLTRIM( STR( 0 ) ), gNumDio, "0" ), 8 )



// ------------------------------------------------------------------
// fakt, uzimanje novog broja za fakt dokument
// ------------------------------------------------------------------
function fakt_novi_broj_dokumenta( firma, tip_dokumenta, sufiks )
local _broj := 0
local _broj_doks := 0
local _param
local _tmp, _rest
local _ret := ""
local _t_area := SELECT()

if sufiks == nil
    sufiks := ""
endif

// param: fakt/10/10
_param := "fakt" + "/" + firma + "/" + tip_dokumenta 
_broj := fetch_metric( _param, nil, _broj )

// konsultuj i doks uporedo
O_FAKT_DOKS
set order to tag "1"
go top
seek firma + tip_dokumenta + "Ž"
skip -1

if field->idfirma == firma .and. field->idtipdok == tip_dokumenta
    _broj_doks := VAL( PADR( field->brdok, gNumDio ) )
else
    _broj_doks := 0
endif

// uzmi sta je vece, doks broj ili globalni brojac
_broj := MAX( _broj, _broj_doks )

// uvecaj broj
++ _broj

// ovo ce napraviti string prave duzine...
_ret := PADL( ALLTRIM( STR( _broj ) ), gNumDio, "0" )

if !EMPTY( sufiks )
    _ret := _ret + sufiks
endif

_ret := PADR( _ret, 8 )

// upisi ga u globalni parametar
set_metric( _param, nil, _broj )

select ( _t_area )
return _ret


// ------------------------------------------------------------
// setuj broj dokumenta u pripremi ako treba !
// ------------------------------------------------------------
function fakt_set_broj_dokumenta()
local _broj_dokumenta
local _t_rec
local _firma, _td, _null_brdok
local _fakt_params := fakt_params()
local oAtrib

PushWa()

select fakt_pripr
go top

_null_brdok := PADR( REPLICATE( "0", gNumDio ), 8 )
_firma := field->idfirma
_td := field->idtipdok
       
// brojaci otpremnica po tip-u "22"
if _td == "12" .and. _fakt_params["fakt_otpr_22_brojac"]
    _tip_srch := "22"
else    
    _tip_srch := _td
endif

if field->brdok <> _null_brdok 
    // nemam sta raditi, broj je vec setovan
    PopWa()
    return .f.
endif

// daj mi novi broj dokumenta
_broj_dokumenta := fakt_novi_broj_dokumenta( _firma, _tip_srch )

select fakt_pripr
set order to tag "1"
go top

do while !EOF()

    skip 1
    _t_rec := RECNO()
    skip -1

    if field->idfirma == _firma .and. field->idtipdok == _td .and. field->brdok == _null_brdok
        replace field->brdok with _broj_dokumenta
    endif

    go (_t_rec)

enddo

oAtrib := F18_DOK_ATRIB():new("fakt")
oAtrib:open_local_table()

// promjeni mi i u fakt_atributi
set order to tag "1"
go top

do while !EOF()

    skip 1
    _t_rec := RECNO()
    skip -1

    if field->idfirma == _firma .and. field->idtipdok == _td .and. field->brdok == _null_brdok
        replace field->brdok with _broj_dokumenta
    endif

    go ( _t_rec )

enddo

// zatvori mi atribute
use

PopWa()
 
return .t.


// -----------------------------------------------------------
// provjerava postoji li rupa u brojacu dokumenata
// -----------------------------------------------------------
function fakt_postoji_li_rupa_u_brojacu( id_firma, id_tip_dok, priprema_broj )
local _ret := 0
local _qry, _table
local _server := pg_server()
local _max_dok, _par_dok, _param
local _params := fakt_params()
local _tip_srch, _tmp
local _inc_error

// .... parametar ako treba
if !_params["kontrola_brojaca"]
    return _ret
endif

// brojaci otpremnica po tip-u "22"
if id_tip_dok == "12" .and. _params["fakt_otpr_22_brojac"]
    _tip_srch := "22"
else    
    _tip_srch := id_tip_dok
endif

_qry := " SELECT MAX( brdok ) FROM fmk.fakt_doks " + ;
        " WHERE idfirma = " + _sql_quote( id_firma ) + ;
        " AND idtipdok = " + _sql_quote( _tip_srch )

// ovo je tabela
_table := _sql_query( _server, _qry )
_dok := _table:Fieldget(1)
_tmp := TokToNiz( _dok, "/" )
_max_dok := VAL( ALLTRIM( _tmp[1] ) )

// ovo je iz parametara...
// param: fakt/10/10
_param := "fakt" + "/" + id_firma + "/" + _tip_srch
_par_dok := fetch_metric( _param, nil, 0 )

// provjera brojaca server dokument <> server param 
_inc_error := _par_dok - _max_dok

if _inc_error > 30

    // eto greske !!!!
    MsgBeep( "Postoji greska sa brojacem dokumenta#Dokumenti: " + ALLTRIM( STR( _max_dok ) ) + ;
                ", parametri: " + ALLTRIM( STR( _par_dok ) ) + "#" + ;
                "Provjerite brojac" )
    _ret := 1
    return _ret

endif

// provjera priprema <> server
_tmp := TokToNiz( priprema_broj, "/" )
_inc_error := ABS( _max_dok - VAL( ALLTRIM( _tmp[1] ) ) )

if _inc_error > 30

    // eto greske !!!!
    MsgBeep( "Postoji greska sa brojacem dokumenta#Priprema: " + ALLTRIM( priprema_broj ) + ;
                ", server dokument: " + ALLTRIM( STR( _max_dok ) ) + "#" + ;
                "Provjerite brojac" )
    _ret := 1
    return _ret

endif

return _ret



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


// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
function fakt_set_param_broj_dokumenta()
local _param
local _broj := 0
local _broj_old
local _firma := gFirma
local _tip_dok := "10"

Box(, 2, 60 )

    @ m_x + 1, m_y + 2 SAY "Dokument:" GET _firma
    @ m_x + 1, col() + 1 SAY "-" GET _tip_dok

    read

    if LastKey() == K_ESC
        BoxC()
        return
    endif

    // param: fakt/10/10
    _param := "fakt" + "/" + _firma + "/" + _tip_dok
    _broj := fetch_metric( _param, nil, _broj )
    _broj_old := _broj

    @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "999999"

    read

BoxC()

if LastKey() != K_ESC
    // snimi broj u globalni brojac
    if _broj <> _broj_old
        set_metric( _param, nil, _broj )
    endif
endif

return


