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

#include "fmk.ch"

// ----------------------------------------------------------
// kopiranje vrijednosti nekog polja u neko SIFK polje
// ----------------------------------------------------------
function copy_to_sifk()

local cTable := ALIAS()
local cFldFrom := SPACE(8)
local cFldTo := SPACE(4)
local cEraseFld := "D"
local cRepl := "D"
local nTekX 
local nTekY

Box(, 6, 65, .f.)
	
	private GetList:={}
	set cursor on
	
	nTekX := m_x
	nTekY := m_y
	
	@ m_x+1, m_y+2 SAY PADL("Polje iz kojeg kopiramo (polje 1)", 40) GET cFldFrom VALID !EMPTY(cFldFrom) .and. val_fld(cFldFrom)
	@ m_x+2, m_y+2 SAY PADL("SifK polje u koje kopiramo (polje 2)", 40) GET cFldTo VALID g_sk_flist(@cFldTo)
	
	@ m_x+4, m_y+2 SAY "Brisati vrijednost (polje 1) nakon kopiranja ?" GET cEraseFld VALID cEraseFld $ "DN" PICT "@!"
	
	@ m_x+6, m_y+2 SAY "*** izvrsiti zamjenu ?" GET cRepl VALID cRepl $ "DN" PICT "@!"
	read
 
BoxC()

if cRepl == "N"
	return 0
endif

if LastKey()==K_ESC
	return 0
endif

nTRec := RecNo()
go top

do while !EOF()
	
	skip
	nRec := RECNO()
	skip -1
	
	cCpVal := (ALIAS())->&cFldFrom
	if !EMPTY( cCpval)
		USifK( ALIAS(), cFldTo, (ALIAS())->id, cCpVal)
	endif
	
	if cEraseFld == "D"
		replace (ALIAS())->&cFldFrom with ""
	endif
	
	go (nRec)
enddo

go (nTRec)

return 0


// --------------------------------------------------
// zamjena vrijednosti sifk polja
// --------------------------------------------------
function repl_sifk_item()

local cTable := ALIAS()
local cField := SPACE(4)
local cOldVal
local cNewVal
local cCurrVal
local cPtnField

Box(,3,60, .f.)
	private GetList:={}
	set cursor on
	
	nTekX := m_x
	nTekY := m_y
	
	@ m_x+1,m_y+2 SAY " SifK polje:" GET cField VALID g_sk_flist(@cField)
	read
	
	cCurrVal:= "wSifk_" + cField
	&cCurrVal:= IzSifk(ALIAS(), cField)
	cOldVal := &cCurrVal
	cNewVal := SPACE(LEN(cOldVal))
	
	m_x := nTekX
	m_y := nTekY
	
	@ m_x+2,m_y+2 SAY "      Trazi:" GET cOldVal
    @ m_x+3,m_y+2 SAY "Zamijeni sa:" GET cNewVal
	
    read 
BoxC()

if LastKey()==K_ESC
	return 0
endif

if Pitanje(,"Izvrsiti zamjenu polja? (D/N)","D") == "N"
	return 0
endif

nTRec := RecNo()

do while !EOF()
	&cCurrVal := IzSifK(ALIAS(), cField)
	if &cCurrVal == cOldVal
		USifK(ALIAS(), cField, (ALIAS())->id, cNewVal)
	endif
	skip
enddo

go (nTRec)

return 0



function g_sk_flist(cField)

local aFields:={}
local cCurrAlias := ALIAS()
local nArr
local nField

nArr := SELECT()

select sifk
set order to tag "ID"
cCurrAlias := PADR(cCurrAlias,8)
seek cCurrAlias

do while !EOF() .and. field->id == cCurrAlias
	AADD(aFields, {field->oznaka, field->naz})
	skip
enddo

select (nArr)

if !EMPTY(cField) .and. ASCAN(aFields, {|xVal| xVal[1] == cField}) > 0
	return .t.
endif

if LEN(aFields) > 0
	private Izbor:=1
	private opc:={}
	private opcexe:={}
	private GetList:={}
	
	for i:=1 to LEN(aFields)
		AADD(opc, PADR(aFields[i, 1] + " - " + aFields[i, 2], 40))
		AADD(opcexe, {|| nField := Izbor, Izbor:=0})
	next
	
	Izbor:=1
	Menu_SC("skf")
endif

cField := aFields[nField, 1]

return .t.


// -----------------------------------------------------------
// IzSifk
// Izvlaci vrijednost iz tabele SIFK
// param cDBF ime DBF-a
// param cOznaka oznaka BARK , GR1 itd
// param cIDSif  interna sifra, npr  000000232  ,
//               ili "00000232,XXX1233233" pri pretrazivanju
// param fNil    NIL - vrati nil za nedefinisanu vrijednost,
//               .f. - vrati "" za nedefinisanu vrijednost
// fpretrazivanje
//
// -----------------------------------------------------------
function IzSifk (dbf_name, ozna, id_sif, return_nil)

local _ret := ""
local _sifk_tip, _sifk_duzina, _sifk_veza

SELECT F_SIFK
if !used()
   O_SIFK
endif

SELECT F_SIFV
if !used()
  O_SIFV
endif

// ID default polje
if id_sif == NIL
  id_sif:=(dbf_name)->ID
endif


PushWa()

dbf_name := PADR(dbf_name, SIFK_LEN_DBF )
ozna     := PADR(ozna, SIFK_LEN_OZNAKA )
id_sif   := PADR(id_sif, SIFK_LEN_IDSIF)

// ako tabela sifk, sifv nije otvorena - otvoriti
SELECT(F_SIFK)
if (!USED())
	O_SIFK	
endif

SELECT(F_SIFV)
if (!USED())
	O_SIFV	
endif

SELECT sifk
SET ORDER TO TAG "ID2"
SEEK dbf_name + ozna

_ret := NIL

if !FOUND()
   // uopste ne postoji takva karakteristika
   if return_nil <> NIL
        _ret := get_sifv_value("X", "")
    else
        _ret := NIL
    endif
    PopWa()
    return _ret
endif

_sifk_duzina := sifk->duzina
_sifk_tip    := sifk->tip
_sifk_veza   := sifk->veza

SELECT sifv
SET ORDER TO TAG "ID"
DBSEEK(dbf_name + ozna + id_sif, .t.)

if !FOUND()
   PopWa()
   _ret := get_sifv_value(_sifk_tip, _sifk_duzina, "")
   return _ret
endif

_ret := get_sifv_value(_sifk_tip, _sifk_duzina, sifv->naz)

if _sifk_veza == "N"
    _ret := ToStr(_ret)
    skip
    do while !EOF() .and.  ((id + oznaka + idsif) == (dbf_name + ozna + id_sif))
        _ret += "," + ToStr(get_sifv_value(_sifk_tip, _sifk_duzina, sifv->naz)) 
        skip
    enddo
    //_ret := padr(_ret, 190)
endif

PopWa()
return _ret

// --------------------------------------
// --------------------------------------
static function get_sifv_value(sifk_tip, sifk_duzina, naz_value)
local _ret


DO CASE
  CASE sifk_tip =="C"
      _ret := PADR(naz_value, sifk_duzina)

  CASE sifk_tip =="N"
      _ret := VAL(ALLTRIM(naz_value))

  CASE sifk_tip =="D"
      _ret:= STOD(TRIM(naz_value))
  OTHERWISE
      _ret:= "?NEPTIP?"

END DO

return _ret

function IzSifkNaz(cDBF,cOznaka)

local xRet:="", nArea

PushWA()
cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)
select sifk; set order to tag "ID2"
seek cDBF+cOznaka
xRet:=sifk->Naz
PopWA()
return xRet

// ------------------------------------------
// ------------------------------------------
function IzSifkWV
parameters cDBF, cOznaka, cWhen, cValid

local xRet:=""

PushWa()

cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)
select sifk
set order to tag "ID2"
seek cDBF+cOznaka

cWhen:=sifk->KWHEN
cValid:=sifk->KVALID

PopWa()
return NIL

// -------------------------------------------------------
// USifk
// Postavlja vrijednost u tabel SIFK
// cDBF ime DBF-a
// cOznaka oznaka xxxx
// cIdSif  Id u sifrarniku npr. 2MON0001
// xValue  vrijednost (moze biti tipa C,N,D)
//
//  veza: 1
//	USifK("PARTN", "ROKP", temp->idpartner, temp->rokpl)
//	USifK("PARTN", "PORB", temp->idpartner, temp->porbr)

//  veza: N
//  USifK( "PARTN", "BANK", cPartn, "1400000000001,131111111111112" )
//  iz ovoga se vidi da je "," nedozvoljen znak u ID-u
// ------------------------------------------------------------------

function USifk(dbf_name, ozna, id_sif, val)
local _i
local ntrec, numtok
local _sifk_rec

SELECT F_SIFV
if !used()
   O_SIFV
endif

SELECT F_SIFK
if !used()
     O_SIFK
endif

if val == NIL
   return .f.
endif

dbf_name := PADR(dbf_name, SIFK_LEN_DBF )
ozna     := PADR(ozna, SIFK_LEN_OZNAKA )

PushWa()

SELECT SIFK
set order to tag "ID2"
seek dbf_name + ozna

if !FOUND() .or. !(sifk->tip $ "CDN")
    PopWa()
    return .f.
endif

_sifk_rec := dbf_get_rec()
id_sif := PADR(id_sif, SIFK_LEN_IDSIF)

if sifk->veza == "N" 
   if !update_sifv_n_relation(_sifk_rec, id_sif, val) 
      return .f.
   endif
else
   if !update_sifv_1_relation(_sifk_rec, id_sif, val)
      return .f.
   endif
endif

PopWa()
return .t.


// -------------------------------------------------------------------
// -------------------------------------------------------------------
static function update_sifv_n_relation(sifk_rec, id_sif, vals) 
local _i, _numtok, _tmp, _naz, _values
local _sifv_rec

_sifv_rec := hb_hash()           
_sifv_rec["id"] := sifk_rec["id"]
_sifv_rec["oznaka"] := sifk_rec["oznaka"]
_sifv_rec["idsif"] := id_sif

// veza 1->N posebno se tretira !!
SELECT sifv
SET ORDER TO TAG "ID"

brisi_sifv_item(sifk_rec["id"], sifk_rec["oznaka"], id_sif)

_numtok := NUMTOKEN(vals, ",")

for _i := 1 to _numtok

    _tmp := TOKEN(vals, "," , _i)    
    APPEND BLANK

    _sifv_rec["naz"] := get_sifv_naz(_tmp, sifk_rec) 
    update_rec_server_and_dbf("sifv", _sifv_rec)
next
 
return .t.

// -------------------------------------------------------------------
// -------------------------------------------------------------------
static function update_sifv_1_relation(sifk_rec, id_sif, value)
local _sifv_rec

_sifv_rec := hb_hash()           
_sifv_rec["id"] := sifk_rec["id"]
_sifv_rec["oznaka"] := sifk_rec["oznaka"]
_sifv_rec["idsif"] := id_sif

value := PADR(value, sifk_rec["duzina"])

// veza 1-1
SELECT  SIFV
SET ORDER TO TAG "ID"

brisi_sifv_item(sifk_rec["id"], sifk_rec["oznaka"], id_sif)

APPEND BLANK
_sifv_rec["naz"] := get_sifv_naz(value, sifk_rec)
update_rec_server_and_dbf("sifv", _sifv_rec)

return .t.


// -----------------------------------------------------
// -----------------------------------------------------
static function brisi_sifv_item(dbf_name, ozn, id_sif)
local _sifv_rec := hb_hash()

_sifv_rec["id"] := dbf_name
_sifv_rec["oznaka"] := ozn
_sifv_rec["idsif"] := id_sif
return delete_rec_server_and_dbf("sifv", _sifv_rec, {"id", "oznaka", "idsif"}, { |x| "ID=" + _sql_quote(x["id"]) + " AND OZNAKA=" + _sql_quote(x["oznaka"]) + " AND IDSIF=" + _sql_quote(x["idsif"]) }, "ID" )

// ----------------------------------------
// ----------------------------------------
static function get_sifv_naz(val, sifk_rec)
do case 
   CASE sifk_rec["tip"] == "C"
        return PADR(val, sifk_rec["duzina"])
   case sifk_rec["tip"] == "N"
        return val
   CASE sifk_rec["tip"] == "D"
     	return DTOS(val)
end case



/*!
 @function ImauSifv
 @abstract Povjerava ima li u sifv vrijednost ...
 @discussion - poziv ImaUSifv("ROBA","BARK","BK0002030300303",@cIdSif)
 @param cDBF ime DBF-a
 @param cOznaka oznaka BARK , GR1 itd
 @param cVOznaka oznaka BARK003030301
 @param cIDSif   00000232 - interna sifra
*/
function ImaUSifv(cDBF,cOznaka,cVOznaka, cIdSif)

local cJedanod:=""
local xRet:=""
local nTr1, nTr2 , xVal
private cPom:=""

PushWa()
cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)

xVal:=NIL

select sifv
PushWa() 
set order to tag "NAZ"
hseek cDbf + cOznaka + cVOznaka
if found()
   cIdSif:=IdSif
endif
PopWa()

PopWa()
return


/*
 @function   GatherSifk
 @abstract
 @discussion Popunjava ID_J (uz pomoc fje NoviId_A()),
             te puni SIFV (na osnovu ImeKol)
 @param cTip  prefix varijabli sa kojima se tabela puni
 @param lNovi .t. - radi se o novom slogu

*/
function update_sifk_na_osnovu_ime_kol_from_global_var(ime_kol, var_prefix, novi)
local _i
local _alias
local _field_b

_alias := ALIAS()

for _i := 1 to len(ime_kol)
   if LEFT(ime_kol[i, 3], 6) == "SIFK->"
     _field_b :=  MEMVARBLOCK( var_prefix + "Sifk_" + SUBSTR(ime_kol[i,3], 7))

     if IzSifk( _alias, SUBSTR(ime_kol[_i, 3], 7), (_alias)->id) <> NIL
         USifk( _alias, SUBSTR(ImeKol[_i, 3], 7), (_alias)->id, EVAL(_field_b) )
     endif
   endif
next

return


// --------------------------------------------
// validacija da li polje postoji
// --------------------------------------------
static function val_fld(cField)
local lRet := .t.
if (ALIAS())->(FieldPOS(cField)) == 0
	lRet := .f.
endif

if lRet == .f.
	msgbeep("Polje ne postoji !!!")
endif

return lRet


