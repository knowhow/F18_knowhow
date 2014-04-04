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


#include "fmk.ch"


// -------------------------------------------------
// ocitaj barkod
// -------------------------------------------------
function roba_ocitaj_barkod( id_roba )
local _t_area := SELECT()
local _bk := ""

if !EMPTY( id_roba )
	select roba
	seek id_roba
	_bk := field->barkod
	select ( _t_area )
endif

return _bk



function DodajBK(cBK)
if empty(cBK) .and. IzFmkIni("BARKOD", "Auto", "N", SIFPATH)=="D" .and. IzFmkIni("BARKOD","Svi","N",SIFPATH)=="D" .and. (Pitanje(,"Formirati Barkod ?","N")=="D")
	cBK:=NoviBK_A()
endif
return .t.



function KaLabelBKod()
local cIBK
local cPrefix
local cSPrefix

private cKomLin

O_SIFK
O_SIFV
O_ROBA
set order to tag "ID"

O_BARKOD
O_KALK_PRIPR

SELECT KALK_PRIPR

private aStampati:=ARRAY(RECCOUNT())

GO TOP

for i:=1 to LEN(aStampati)
	aStampati[i]:="D"
next

ImeKol:={ {"IdRoba",{|| IdRoba}}, {"Kolicina",{|| transform(Kolicina,picv)}} ,{"Stampati?",{|| IF(aStampati[RECNO()]=="D","-> DA <-","      NE")}} }

Kol:={}
for i:=1 to len(ImeKol)
	AADD(Kol, i)
next

Box(,20,50)
ObjDbedit("PLBK",20,50, {|| KaEdPrLBK()},"<SPACE> markiranje             Í<ESC> kraj","Priprema za labeliranje bar-kodova...", .t. , , , ,0)
BoxC()

nRezerva:=0

cLinija2:=padr("Uvoznik:" + gNFirma, 45)

Box(,4,75)
	@ m_x+0, m_y+25 SAY " LABELIRANJE BAR KODOVA "
	@ m_x+2, m_y+ 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva>=0 PICT "99"
	@ m_x+3, m_y+ 2 SAY "Linija 2  :" GET cLinija2
	READ
	ESC_BCR
BoxC()

cPrefix:=IzFmkIni("Barkod","Prefix","", SIFPATH)
cSPrefix:= pitanje(,"Stampati barkodove koji NE pocinju sa +'"+cPrefix+"' ?","N")

SELECT BARKOD
zapp()

SELECT KALK_PRIPR
GO TOP

do while !EOF()
	if aStampati[RECNO()]=="N"
		SKIP 1
		loop
	endif
	SELECT ROBA
	HSEEK KALK_PRIPR->idroba
	if empty(barkod).and.(IzFmkIni("BarKod","Auto","N",SIFPATH)=="D")
		private cPom:=IzFmkIni("BarKod","AutoFormula","ID",SIFPATH)
		// kada je barkod prazan, onda formiraj sam interni barkod
		cIBK:=IzFmkIni("BARKOD","Prefix","",SIFPATH)+&cPom
		if IzFmkIni("BARKOD","EAN","",SIFPATH)=="13"
			cIBK:=NoviBK_A()
		endif
		PushWa()
		set order to tag "BARKOD"
		seek cIBK
		if found()
			PopWa()
			MsgBeep("Prilikom formiranja internog barkoda##vec postoji kod: "+cIBK+"??##"+"Moracete za artikal "+kalk_pripr->idroba+" sami zadati jedinstveni barkod !")
			replace barkod with "????"
		else
			PopWa()
			replace barkod with cIBK
		endif
	endif
	if cSprefix=="N"
		// ne stampaj koji nemaju isti prefix
		if left(barkod,len(cPrefix))!=cPrefix
			select kalk_pripr
			skip
			loop
		endif
	endif

	SELECT BARKOD
	for i:=1 to kalk_pripr->kolicina+IF(kalk_pripr->kolicina>0, nRezerva, 0)
		APPEND BLANK
		REPLACE id WITH kalk_pripr->idRoba
		REPLACE naziv WITH TRIM(ROBA->naz)+" ("+TRIM(ROBA->jmj)+")"
		REPLACE l1 WITH DTOC(kalk_pripr->datdok)+", "+TRIM(kalk_pripr->(idfirma+"-"+idvd+"-"+brdok))
		REPLACE l2 WITH cLinija2
		REPLACE vpc WITH ROBA->vpc
		REPLACE mpc WITH ROBA->mpc
		REPLACE barkod WITH roba->barkod
	next
	SELECT kalk_pripr
	SKIP 1
enddo
my_close_all_dbf()

f18_rtm_print( "barkod", "barkod", "1" )

my_close_all_dbf()
return


/*! \fn KaEdPrLBK()
 *  \brief Obrada dogadjaja u browse-u tabele "Priprema za labeliranje bar-kodova"
 *  \sa KaLabelBKod()
 */

function KaEdPrLBK()
*{
if Ch==ASC(' ')
	if aStampati[recno()]=="N"
		aStampati[recno()] := "D"
	else
		aStampati[recno()] := "N"
	endif
	return DE_REFRESH
endif
return DE_CONT
*}

/*! \fn FaLabelBKod()
 *  \brief Priprema za labeliranje barkodova
 *  \todo Spojiti
 */ 
function FaLabelBKod()
*{
local cIBK , cPrefix, cSPrefix

O_SIFK
O_SIFV

O_ROBA
SET ORDER to TAG "ID"
O_BARKOD
O_FAKT_PRIPR

SELECT fakt_pripr

private aStampati:=ARRAY(RECCOUNT())

GO TOP

for i:=1 to LEN(aStampati)
  	aStampati[i]:="D"
next

ImeKol:={ {"IdRoba",      {|| IdRoba  }      } ,;
    {"Kolicina",    {|| transform(Kolicina,Pickol) }     } ,;
    {"Stampati?",   {|| IF(aStampati[RECNO()]=="D","-> DA <-","      NE") }      } ;
  }

Kol:={}; for i:=1 to len(ImeKol); AADD(Kol,i); next
Box(,20,50)
ObjDbedit("PLBK",20,50,{|| KaEdPrLBK()},"<SPACE> markiranjeÍÍÍÍÍÍÍÍÍÍÍÍÍÍ<ESC> kraj","Priprema za labeliranje bar-kodova...", .t. , , , ,0)
BoxC()

nRezerva:=0

cLinija1:=padr("Proizvoljan tekst",45)
cLinija2:=padr("Uvoznik:"+gNFirma,45)
Box(,4,75)
@ m_x+0, m_y+25 SAY " LABELIRANJE BAR KODOVA "
@ m_x+2, m_y+ 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva>=0 PICT "99"
if IzFmkIni("Barkod","BrDok","D",SIFPATH)=="N"
@ m_x+3, m_y+ 2 SAY "Linija 1  :" GET cLinija1
endif
@ m_x+4, m_y+ 2 SAY "Linija 2  :" GET cLinija2
READ
ESC_BCR
BoxC()

cPrefix:=IzFmkIni("Barkod","Prefix","",SIFPATH)
cSPrefix:= pitanje(,"Stampati barkodove koji NE pocinju sa +'"+cPrefix+"' ?","N")

SELECT BARKOD
zapp()

SELECT fakt_pripr
GO TOP
do while !EOF()


if aStampati[RECNO()]=="N"; SKIP 1; loop; endif
SELECT ROBA
HSEEK fakt_pripr->idroba
if empty(barkod) .and. (  IzFmkIni("BarKod" , "Auto" , "N", SIFPATH) == "D")
private cPom:=IzFmkIni("BarKod","AutoFormula","ID", SIFPATH)
  // kada je barkod prazan, onda formiraj sam interni barkod

cIBK:=IzFmkIni("BARKOD","Prefix","",SIFPATH) +&cPom

if IzFmkIni("BARKOD","EAN","",SIFPATH) == "13"
   cIBK:=NoviBK_A()
endif

PushWa()
set order to tag "BARKOD"
seek cIBK
if found()
     PopWa()
     MsgBeep(;
       "Prilikom formiranja internog barkoda##vec postoji kod: "  + cIBK + "??##" + ;
     "Moracete za artikal "+fakt_pripr->idroba+" sami zadati jedinstveni barkod !" )
     replace barkod with "????"
else
    PopWa()
    replace barkod with cIBK
endif

endif
if cSprefix=="N"
// ne stampaj koji nemaju isti prefix
if left(barkod,len(cPrefix)) != cPrefix
      select fakt_pripr
      skip
      loop
endif
endif


SELECT BARKOD
for  i:=1  to  fakt_pripr->kolicina + IF( fakt_pripr->kolicina > 0 , nRezerva , 0 )

	APPEND BLANK
	REPLACE ID       WITH  KonvZnWin(fakt_pripr->idroba)

	if IzFmkIni("Barkod","BrDok","D",SIFPATH)=="D"
		REPLACE L1 WITH KonvZnWin(DTOC(fakt_pripr->datdok)+", "+TRIM(fakt_pripr->(idfirma+"-"+idtipdok+"-"+brdok)))
	else
		REPLACE L1 WITH KonvZnWin(cLinija1)
	endif

	REPLACE L2 WITH KonvZnWin(cLinija2), VPC WITH ROBA->vpc, MPC WITH ROBA->mpc, BARKOD WITH roba->barkod

	if IzFmkIni("BarKod","JMJ","D",SIFPATH)=="N"
		replace NAZIV WITH  KonvZnWin(TRIM(ROBA->naz))
	else
		replace NAZIV WITH  KonvZnWin(TRIM(ROBA->naz)+" ("+TRIM(ROBA->jmj)+")")
	endif

next
SELECT FAKT_PRIPR
SKIP 1

enddo

my_close_all_dbf()

f18_rtm_print( "barkod", "barkod", "1" )

my_close_all_dbf()
return



/*! \fn FaEdPrLBK()
 *  \brief Priprema barkodova
 */
 
function FaEdPrLBK()
if Ch==ASC(' ')
     aStampati[recno()] := IF( aStampati[recno()]=="N" , "D" , "N" )
     return DE_REFRESH
  endif
return DE_CONT


/*!
 @function    NoviBK_A
 @abstract    Novi Barkod - automatski
 @discussion  Ova fja treba da obezbjedi da program napravi novi interni barkod
              tako sto ce pogledati Barkod/Prefix iz fmk.ini i naci zadnji
              
	      dodjeljen barkod. Njeno ponasanje ovisno je op parametru
              Barkod / EAN ; Za EAN=13 vraca trinaestocifreni EANKOD,
              Kada je EAN<>13 vraca broj duzine DuzSekvenca BEZ PREFIXA
*/
function NoviBK_A(cPrefix)

local cPom , xRet
local nDuzPrefix, nDuzSekvenca, cEAN

PushWA()

nCount:=1

if cPrefix=NIL
   cPrefix:=IzFmkIni("Barkod","Prefix","",SIFPATH)
endif
cPrefix:=trim(cPrefix)
nDuzPrefix:=len(cPrefix)

nDuzSekv:=  val ( IzFmkIni("Barkod","DuzSekvenca","",SIFPATH) )
cEAN:= IzFmkIni("Barkod","EAN","",SIFPATH)

cRez:= padl(  alltrim(str(1))  , nDuzSekv , "0")
if cEAN="13"
   cRez := cPrefix + cRez + KEAN13(cRez)
   //      0387202   000001   6
else
   cRez := cRez
endif

set filter to // pocisti filter
set order to tag "BARKOD"
seek cPrefix+"á" // idi na kraj
skip -1 // lociraj se na zadnji slog iz grupe prefixa
if left(barkod,nDuzPrefix) == cPrefix
 if cEAN=="13"
  cPom:=   alltrim ( str( val (substr( BARKOD, nDuzPrefix + 1, nDuzSekv)) + 1 ))
  cPom:=   padl(cPom,nDuzSekv,"0")
  cRez:=   cPrefix + cPom
  cRez:=   cRez + KEAN13(cRez)
 else
  // interni barkod varijanta planika koristicemo Code128 standard
  cPom:=   alltrim ( str( val (substr( BARKOD, nDuzPrefix + 1, nDuzSekv)) + 1 ))
  cPom:=   padl(cPom,nDuzSekv,"0")
  cRez:=   cPom  // Prefix dio ce dodati glavni alogritam
 endif
endif

PopWa()

return cRez


/*!
 @function   KEAN13 ( ckod)
 @abstract   Uvrdi ean13 kontrolni broj
 @discussion xx
 @param      ckod   kod od dvanaest mjesta
*/
function KEAN13(cKod)

local n2,n4
local n1:= val(substr(cKod,2,1)) + val(substr(cKod,4,1)) + val(substr(ckod,6,1)) + val(substr (ckod,8,1)) + val(substr(ckod,10,1)) + val(substr(ckod,12,1))
local n3:= val(substr(cKod,1,1)) +val(substr(cKod,3,1)) + val(substr(ckod,5,1)) + val(substr (ckod,7,1)) + val(substr(ckod,9,1)) + val(substr(ckod,11,1))
n2:=n1 * 3

n4:= n2 + n3
n4:= n4 % 10
if n4=0
 return  "0"   // n5
else
 return  str( 10 - n4 , 1)   // n5
endif




// --------------------------------------------------------------------------------------
// provjerava i pozicionira sifranik artikala na polje barkod po trazeno uslovu
// --------------------------------------------------------------------------------------
function barkod( cId )
local cIdRoba := ""
local _barkod := ""

gOcitBarCod := .f.

select roba

if !EMPTY( cId )

	set order to tag "BARKOD"
	go top
  	seek cId

  	if FOUND() .and. PADR( cId, 13, "" ) == field->barkod 
    	cId := field->id  
     	gOcitBarCod := .t.
        _barkod := ALLTRIM(field->barkod)
	endif

endif

cId := PADR( cId, 10 )

return _barkod



// -------------------------------------------------------------------------------------
// ova funkcija vraca tezinu na osnovu tezinskog barkod-a
// znaci samo je izracuna
// -------------------------------------------------------------------------------------
function tezinski_barkod_get_tezina( barkod, tezina )
local _tb := param_tezinski_barkod()
local _tb_prefix := ALLTRIM( fetch_metric( "barkod_prefiks_tezinskog_barkoda", nil, "" ) )
local _tb_barkod, _tb_tezina
local _bk_len := fetch_metric( "barkod_tezinski_duzina_barkoda", nil, 0 )
local _tez_len := fetch_metric( "barkod_tezinski_duzina_tezina", nil, 0 )
local _tez_div := fetch_metric( "barkod_tezinski_djelitelj", nil, 10000 )
local _val_tezina := 0
local _a_prefix
local _i

if _tb == "N"
    return .f.
endif

// matrica sa prefiksima...
// "55"
// "21"
// itd...
_a_prefix := TokToNiz( _tb_prefix, ";" )

if ASCAN( _a_prefix, { |var| var == PADR( barkod, LEN( var ) ) } ) == 0
    return .f. 
endif

// odrezi ocitano na 7, tu je barkod koji trebam pretraziti
_tb_barkod := LEFT( barkod, _bk_len )

if LEN( ALLTRIM( _tb_barkod ) ) <> _bk_len
    // ne slaze se sa tezinskim barkodom... ovo je laznjak..
    return .f.
endif

_tb_tezina := PADR( RIGHT( barkod, _tez_len ), _tez_len - 1 )

// sredi mi i tezinu...
if !EMPTY( _tb_tezina )
    _val_tezina := VAL( _tb_tezina )
	tezina := ROUND( ( _val_tezina / _tez_div ), 4 )
    return .t.
endif

return .f.


// --------------------------------------------------------------------------------------
// provjerava tezinski barod
// --------------------------------------------------------------------------------------
function tezinski_barkod( id, tezina, pop_push )
local _ocitao := .f.
local _tb := param_tezinski_barkod()
local _tb_prefix := ALLTRIM( fetch_metric( "barkod_prefiks_tezinskog_barkoda", nil, "" ) )
local _tb_barkod, _tb_tezina
local _bk_len := fetch_metric( "barkod_tezinski_duzina_barkoda", nil, 0 )
local _tez_len := fetch_metric( "barkod_tezinski_duzina_tezina", nil, 0 )
local _tez_div := fetch_metric( "barkod_tezinski_djelitelj", nil, 10000 )
local _val_tezina := 0
local _a_prefix
local _i

if pop_push == NIL
    pop_push := .t.
endif

gOcitBarCod := _ocitao

if _tb == "N" 
	return _ocitao
endif

if EMPTY( id ) 
	return _ocitao
endif

// matrica sa prefiksima...
// "55"
// "21"
// itd...
_a_prefix := TokToNiz( _tb_prefix, ";" )

if ASCAN( _a_prefix, { |var| var == PADR( id, LEN( var ) ) } ) <> 0
    // ovo je ok...
else
    return _ocitao            
endif

// odrezi ocitano na 7, tu je barkod koji trebam pretraziti
_tb_barkod := LEFT( id, _bk_len )
_tb_tezina := PADR( RIGHT( id, _tez_len ), _tez_len - 1 )

if pop_push
    PushWa()
endif

select roba
set order to tag "BARKOD"
seek _tb_barkod
  	
if FOUND() .and. ALLTRIM( _tb_barkod ) == ALLTRIM( field->barkod ) 

    	id := roba->id  
     	_ocitao := .t.

		gOcitBarCod := _ocitao

		// sredi mi i tezinu...
		if !EMPTY( _tb_tezina )

			_val_tezina := VAL( _tb_tezina )
			tezina := ROUND( ( _val_tezina / _tez_div ), 4 )

		endif

endif

id := PADR( id, 10 )

select roba
set order to tag "ID"

if pop_push
    PopWa()
endif

return _ocitao



