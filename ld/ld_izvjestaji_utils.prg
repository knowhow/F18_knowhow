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


#include "ld.ch"


function ShowKreditor(cKreditor)
local nArr
nArr:=SELECT()

O_KRED
select kred
seek cKreditor
// ispis
if !EOF()
	? ALLTRIM(field->id) + "-" + (field->naz)
	? "-" + ALLTRIM(field->fil) + "-"
	? ALLTRIM(field->adresa) + ", " + field->ptt + " " + ALLTRIM(field->mjesto)
else
	? Lokal("...Nema unesenih podataka...za kreditora...")
endif

select (nArr)
return


function ShowPPDef()

? SPACE(5) + Lokal("Obracunski radnik:") + SPACE(35) + Lokal("SEF SLUZBE:")
?
? SPACE(5) + "__________________" + SPACE(35) + "__________________"

return


function ShowPPFakultet()
 
? SPACE(5) + Lokal("Likvidator:       ") + SPACE(35) + Lokal("Dekan fakulteta:  ")
?
? SPACE(5) + "__________________" + SPACE(35) + "__________________"

return


/*! \fn ShiwHiredFromTo(dHiredFrom, dHiredTo)
 *  \brief Prikaz podataka angazovan od, angazovan do na izvjestajima, ako je dHiredTo prazno onda prikazuje Trenutno angazovan...
 *  \param dHiredFrom - angazovan od datum
 *  \param dHiredTo - angazovan do datum
 */
function ShowHiredFromTo(dHiredFrom, dHiredTo, cLM)
*{
cHiredFrom:=DToC(dHiredFrom)
cHiredTo:=DToC(dHiredTo)

? cLM + Lokal("Angazovan od: ") + cHiredFrom
?? ",  " + Lokal("Angazovan do: ")

if !EMPTY(DToS(dHiredTo))
	?? cHiredTo 
else
	?? Lokal("Trenutno angazovan")
endif

return



// ----------------------------------------------
// vraca liniju za doprinose
// ----------------------------------------------
function _gdoprline( cDoprSpace )
local cLine
cLine := cLMSK
cLine += REPLICATE("-", 4)
cLine += SPACE(1)
cLine += REPLICATE("-",23)
cLine += SPACE(1)
cLine += REPLICATE("-",8)
cLine += SPACE(1)
cLine += REPLICATE("-",13)
cLine += SPACE(1)
cLine += REPLICATE("-",13)
return cLine



// -------------------------------------------------
// vraca liniju za podvlacenje tipova primanja
// -------------------------------------------------
function _gtprline()
local cLine
cLine := cLMSK 
cLine += REPLICATE("-", 23)
cLine += SPACE(1)
cLine += REPLICATE("-",8)
cLine += SPACE(2)
cLine += REPLICATE("-",16)
cLine += SPACE(3)
cLine += REPLICATE("-",18)
return cLine


// -------------------------------------------------
// vraca liniju za podvlacenje tipova primanja
// -------------------------------------------------
function _gmainline()
local cLine
cLine := cLMSK 
cLine += REPLICATE("-", 52)
cLine += SPACE(1)
cLine += REPLICATE("-",18)
return cLine



// ----------------------------
// Porezi i Doprinosi Iz Sezone
// ---------------------------------------------------------------------
// Ova procedura ispituje da li je za izracunavanje poreza i doprinosa
// u izvjestaju potrebno koristiti sifrarnike iz sezone. Ako se ustanovi
// da ovi sifrarnici postoje u sezoni 'MMGGGG' podrazumijeva se da njih
// treba koristiti za izvjestaj. U tom slucaju zatvaraju se postojeci
// sifrarnici POR i DOPR iz radnog podrucja, a umjesto njih otvaraju se
// sezonski.
// ---------------------------------------------------------------------
// cG - izvjestajna godina, cM - izvjestajni mjesec
// ---------------------------------------------------------------------
// Ukoliko izvjestaj koristi baze POR i/ili DOPR, one moraju biti
// otvorene prije pokretanje ove procedure.
// Ovu proceduru najbolje je pozivati odmah nakon upita za izvjestajnu
// godinu i mjesec (prije toga nema svrhe), a prije glavne izvjestajne
// petlje.
// ---------------------------------------------------------------------
function PoDoIzSez( cG, cM )
local nArr := SELECT()
local cPath
local aSez
local i
local cPom
local lPor
local lDopr
local cPorDir
local cDoprDir

if ( cG == nil .or. cM == nil )
	return
endif

if VALTYPE(cG) == "N"
	cG := STR(cG, 4, 0)
endif

if VALTYPE(cM) == "N"
	cM := PADL(ALLTRIM(STR(cM)), 2, "0")
endif

altd()

cPath := SIFPATH
aSez := ASezona2( cPath, cG )

if LEN( aSez ) < 1
	return
endif

lPor := .f.
lDopr := .f.
cPorDir := ""
cDoprDir := ""

for i:=1 to LEN(aSez)
	cPom := TRIM(aSez[i, 1])
    	if LEFT(cPom, 2) >= cM
      		if FILE(cpath+cPom+"\POR.DBF")
        		lPor     := .t.
        		cPorDir  := cPom
      		endif
      		if FILE(cpath+cPom+"\DOPR.DBF")
        		lDopr    := .t.
        		cDoprDir := cPom
      		endif
    	else
      		exit
    	endif
next

if lPor
	SELECT (F_POR)
	USE
    	USE (cPath+cPorDir+"\POR")
	SET ORDER TO TAG "ID"
	
	if reccount() = 0
		// ako je sifrarnik prazan, vrati se na 
		// tekuci
		select F_POR
		use
		O_POR
	endif

endif

if lDopr
	SELECT (F_DOPR)
	USE
    	USE (cPath+cDoprDir+"\DOPR") 
	SET ORDER TO TAG "ID"
	if reccount() = 0
		// ako je sifrarnik prazan, vrati se na 
		// tekuci
		select F_DOPR
		use
		O_DOPR
	endif

endif

select (nArr)
return


// ---------------------------------------------
//   Razrijedi (cStr) --> cStrRazr
//     Ubaci u string, izmedju slova, SPACE()
// ---------------------------------------------
function Razrijedi (cStr)
LOCAL cRazrStr, nLenM1, nCnt
cStr := ALLTRIM (cStr)
nLenM1 := LEN (cStr) - 1
cRazrStr := ""
FOR nCnt := 1 TO nLenM1
  cRazrStr += SUBSTR (cStr, nCnt, 1) + " "
NEXT
cRazrStr += RIGHT (cStr, 1)
RETURN (cRazrStr)



function ASezona2( cPath, cG, cFajl)
local aSez
local i
local cPom
  
if cFajl == NIL
	cFajl := ""
endif

aSez := DIRECTORY(cPath+"*.","DV")

for i:=LEN(aSez) to 1 step -1
	if aSez[i,1]=="." .or. aSez[i,1]==".."
      		ADEL(aSez,i)
      		ASIZE(aSez,LEN(aSez)-1)
    	endif
next

for i:=LEN(aSez) to 1 step -1
	cPom := TRIM(aSez[i,1])
    	if LEN(cPom)<>6 .or. RIGHT(cPom,4)<>cG .or.;
       		!EMPTY(cFajl) .and. !FILE(cPath+cPom+"\"+cFajl)
      		ADEL(aSez,i)
      		ASIZE(aSez,LEN(aSez)-1)
    	endif
next
ASORT( aSez ,,, { |x,y| x[1] > y[1] } )
return aSez


function Cijelih(cPic)
 LOCAL nPom := ATTOKEN( ALLTRIM(cPic) , "." , 2 ) - 2
RETURN IF( nPom<1 , LEN(ALLTRIM(cPic)) , nPom )

function Decimala(cPic)
 LOCAL nPom := ATTOKEN( ALLTRIM(cPic) , "." , 2 )
RETURN IF( nPom<1 , 0 ,  LEN( SUBSTR( ALLTRIM(cPic) , nPom ) )  )


// ------------------------------------
// vraca opis tipa primanja
// ------------------------------------
function sh_tp_opis( cIdTipPr, cRadn  )
local cRet

cRet := tippr->opis

if "##" $ cRet
	cRet := _opis_param( cRet, cRadn )	
endif

return cRet


// ---------------------------------------
// vraca opis iz parametra
// ---------------------------------------
static function _opis_param( cRet, cRadn )
local cVal := ""
local nTArea := SELECT()
private cF_Tmp

// opis je ##S9##
// prvo ukini znakove "##"
cF_Tmp := STRTRAN( cRet, "#", "" )

// ako ne postoji polje...
if radn->(FIELDPOS(cF_Tmp)) = 0
	return cVal
endif

select radn
seek cRadn

select (nTArea)

cVal := radn->(&cF_Tmp)

return cVal

