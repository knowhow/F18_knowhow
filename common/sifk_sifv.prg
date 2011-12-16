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
	
	@ m_x+1,m_y+2 SAY PADL("Polje iz kojeg kopiramo (polje 1)", 40) GET cFldFrom VALID !EMPTY(cFldFrom) .and. val_fld(cFldFrom)
	@ m_x+2,m_y+2 SAY PADL("SifK polje u koje kopiramo (polje 2)", 40) GET cFldTo VALID g_sk_flist(@cFldTo)
	
	@ m_x+4,m_y+2 SAY "Brisati vrijednost (polje 1) nakon kopiranja ?" GET cEraseFld VALID cEraseFld $ "DN" PICT "@!"
	
	@ m_x+6,m_y+2 SAY "*** izvrsiti zamjenu ?" GET cRepl VALID cRepl $ "DN" PICT "@!"
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


/*!
 *\fn IzSifk
 *\brief Izvlaci vrijednost iz tabele SIFK
 *\param cDBF ime DBF-a
 *\param cOznaka oznaka BARK , GR1 itd
 *\param cIDSif  interna sifra, npr  000000232  ,
 *               ili "00000232,XXX1233233" pri pretrazivanju
 *\param fNil    NIL - vrati nil za nedefinisanu vrijednost,
 *               .f. - vrati "" za nedefinisanu vrijednost
 *\fpretrazivanje
 *
 * Vrsi se analiza postojanaja
 * Pretpostavke:
 * Otvorene tabele SIFK, SIFV
 *
 */
function IzSifk(cDBF,cOznaka, cIdSif, fNiL, fPretrazivanje)

local cJedanod:=""
local xRet:=""
local nTr1, nTr2 , xVal
private cPom:=""

if cIdSif=NIL
  cIdSif:=(cDBF)->id
endif


if numtoken(cOznaka,",")=2
     cJedanod:=token( cOznaka,",",2)
     cOznaka :=token( cOznaka,",",1)
endif

PushWa()

cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)

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
SEEK cDBF+cOznaka


xVal:=nil

if found()
  // da li uopste traziti
  cPom:=Uslov   
  if !empty(cPom)
     xVal=&cPom
  endif

  if empty(cPom) .or. xVal
    select sifv
    if len(cIdSif)>15  // ADRES.DBF
      cIdSif:=left(cIdSif,15)
    endif
    hseek cDBf+cOznaka+cIdSif
    xRet:=UVSifv()
    // pokupi sve vrijednosti
    if sifk->veza="N" .and. fpretrazivanje<>NIL // radi se o artiklu sa vezom 1->N
      // ova varijanta poziva desava se samo pri pretrazivanju
      seek cDbf+cOznaka+padr(cIdSif,len(idsif))+cJedanod
      if found()
         xRet:=cJedanod
      else
         xRet:=""+cJedanod+""
      endif

    elseif sifk->veza="N"
     skip
     do while !eof() .and.  ((id+oznaka+idsif) = (cDBf+cOznaka+cIdSif))
      xRet+=","+ToStr(UvSifv()) //kalemi u jedan string
      skip
     enddo
     xRet:=padr(xRet,190)
    endif

  else   // daj praznu vrijednost
    if xVal  .or. (fNil<>NIL)
       if sifk->tip=="C"
          xRet:= padr("",sifk->duzina)
       elseif sifk->tip=="N"
          xRet:=  val( str(0,sifk->duzina,sifk->f_decimal) )
       elseif sifk->tip=="D"
          xRet:= ctod("")
       else
          xRet:= "NEPTIP"
       endif
    else
     // ne koristi se
     xRet:=nil
    endif
  endif

endif

PopWa()

return xRet


static function UVSifv()

local xRet
if sifk->tip=="C"
   xRet:= padr(naz,sifk->duzina)
elseif sifk->tip=="N"
   xRet:= val(alltrim(naz))
elseif sifk->tip=="D"
   xRet:= STOD(trim(naz))
else
   xRet:= "NEPTIP"
endif
return xRet


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

function USifk(cDBF, cOznaka, cIdSif, xValue)
local _i
local ntrec, numtok
private cPom:=""

SELECT F_SIFV
if !used()
   O_SIFV
endif

SELECT F_SIFK
if !used()
     O_SIFK
endif

cDBF := padr(cDBF, 8)
cOznaka:=padr(cOznaka, 4)

PushWa()

select sifk
set order to tag "ID2"
seek cDBF + cOznaka
// karakteristika ovo postoji u tabeli SIFK

// ADRES.DBF ?
if LEN(cIdSif) > 15   
  cIdSif := LEFT(cIdSif, 15)
endif

if !FOUND()
   PopWa()
   return .f.
endif  

if sifk->veza == "N" 
   update_sifv_n_relation(cDbf, cOznaka, cIdSif, xValue) 
else
   update_sifv_1_relation(cDbf, cOznaka, cIdSif, xValue)
endif

return .t.


// -------------------------------------------------------------------
// -------------------------------------------------------------------
static function update_sifv_n_relation(cDbf, cOznaka, cIdSif, xValue) 
local _i, _numtok

// veza 1->N posebno se tretira !!
SELECT sifv

brisi_sifv_item(cDbf, cOznaka, cIdSif)

_numtok := NUMTOKEN(xValue, ",")

for _i := 1 to _numtok

    APPEND BLANK
    replace Id with cDbf, oznaka with cOznaka, IdSif with cIdSif

	Scatter()
    xValue_i := TOKEN(xValue, "," , _i)
    replace_sifv_naz(xValue_i)

next
 
return

// -------------------------------------------------------------------
// -------------------------------------------------------------------
static function update_sifv_1_relation(cDbf, cOznaka, cIdSif, xValue)

if xValue == NIL
  return .f.
endif

// veza 1-1
SELECT  sifv
SEEK cDBf + cOznaka + cIdSif

// do sada nije bilo te vrijednosti
if !FOUND()
     if !EMPTY( ToStr(xValue) )
           APPEND BLANK
           replace Id with cDbf, oznaka with cOznaka, IdSif with cIdSif
     else    
           // ne dodaji prazne vrijednosti
           PopWa()
           return .t.
     endif
endif

Scatter()
replace_sifv_naz(xValue)

return .t.


// -----------------------------------------------------
// -----------------------------------------------------
static function brisi_sifv_item(cDbf, cOznaka, cIdSif)
local _rec
SELECT sifv
seek cDBf + cOznaka + cIdSif
 
//izbrisi stare vrijednost !!!
do while !eof() .and. ( (field->id + field->oznaka + field->idsif) == (cDBf + cOznaka + cIdSif) )
     skip
     _rec:=recno()
     skip -1
     delete
     go _rec
enddo

return

// ----------------------------------------
// ----------------------------------------
static function replace_sifv_naz(xValue_i)
do case 

   CASE sifk->tip=="C"
        replace naz with xValue_i
   CASE sifk->tip=="N"
        replace naz with str(xValue_i, sifk->duzina, sifk->f_decimal)
   CASE sifk->tip=="D"
     	replace naz with DTOS(xValue_i)
   OTHERWISE
        return .f.
end case
return .t.





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
function GatherSifk(cTip, lNovi)
local i
local _alias
local _field_b

if lNovi
  if IzFmkIni('Svi','SifAuto','N')=='D'
    Scatter()
    replace ID with NoviID_A()
  endif
endif

_alias := ALIAS()
for i:=1 to len(ImeKol)
   if left(ImeKol[i,3], 6) == "SIFK->"
     _field_b := MEMVARBLOCK( cTip + "Sifk_" + substr(ImeKol[i,3], 7))

     if IzSifk( _alias, substr(ImeKol[i,3],7), (_alias)->id) <> NIL
       // koristi se
       USifk( _alias, substr(ImeKol[i,3], 7), (_alias)->id, EVAL(_field_b) )
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


