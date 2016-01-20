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

#include "f18.ch"
#include "f18_ver.ch"
 
// --------------------------------------------------------------
//* nToLongC(nN)
//* Pretvara broj u LONG (C-ovski prikaz long integera)
// --------------------------------------------------------------
function nToLongC(nN)

local cStr:="",i

for i:=1 to 4
nDig:=nN-INT(nN/256)*256
cStr+=CHR(nDig)
nN:=INT(nN/256)
next

return cStr


// --------------------------------------------------------------
// --------------------------------------------------------------
function CLongToN(cLong)

local i,nExp
nRez:=0
for i:=1 to 4
 nExp:=1
 for j:=1 to i-1
   nExp*=256
 next
 nRez+=ASC(SUBSTR(cLong,i,1))*nExp
next
return nRez


// ---------------------------------------
// ---------------------------------------
function Sleep(nSleep)

local nStart, nCh

nStart:=seconds()
do while .t.
 if nSleep < 0.0001
    Exit
 else
    nCh:=inkey(nSleep)

    //if nCh<>0
       //Keyboard chr(nCh)
    //endif
    if (seconds()-nStart) >= nSleep
        Exit
    else
        nSleep:= nSleep - ( seconds()-nStart )
    endif
 endif

enddo

return



// ----------------------------------------
// ----------------------------------------
function NotImp()
MsgBeep("Not implemented ?")
return



// ----------------------------------------
// upisi text u fajl
// ----------------------------------------
function write_2_file(nH, cText, lNoviRed)

local cNRed := CHR(13)+CHR(10)
if lNoviRed
	FWrite(nH, cText + cNRed)
else
	FWrite(nH, cText)
endif

return

// ----------------------------------------------
// kreiranje fajla
// ----------------------------------------------
function create_file(cFilePath, nH)

nH:=FCreate(cFilePath)
if nH == -1
	MsgBeep("Greska pri kreiranju fajla !!!")
	return
endif

return

// -------------------------------------------------
// zatvaranje fajla
// --------------------------------------------------
function close_file(nH)
FClose(nH)

return


// -------------------------------------------------
// -------------------------------------------------
function Run(cmd)

return __Run(cmd)


// ---------------------------------------------------------------
// vraca fajl iz matrice na osnovu direktorija prema filteru
// ---------------------------------------------------------------
function get_file_list_array( cPath, cFilter, cFile, lSilent )
local nPx := m_x
local nPy := m_y

if lSilent == nil
	lSilent := .f.
endif

if EMPTY( cFilter )
	cFilter := "*.*"
endif

OpcF:={}

aFiles := DIRECTORY( cPath + cFilter )

// da li postoje templejti
if LEN( aFiles ) == 0
	log_write( "template list: na lokaciji " + cPath + " ne postoji niti jedan template, po filteru: " + cFilter, 9 )
    MsgBeep("Ne postoji definisan niti jedan template na lokciji:#" + cPath + "#po filteru: " + cFilter )
	return 0
endif

// sortiraj po datumu
ASORT(aFiles,,,{|x,y| x[3]>y[3]})
AEVAL(aFiles,{|elem| AADD(OpcF, PADR(elem[1],15)+" "+dtos(elem[3]))},1)
// sortiraj listu po datumu
ASORT(OpcF,,,{|x,y| RIGHT(x,10)>RIGHT(y,10)})

h:=ARRAY(LEN(OpcF))
for i:=1 to LEN(h)
	h[i]:=""
next

// selekcija fajla
IzbF := 1
lRet := .f.

if LEN( opcF ) > 1
    do while .t. .and. LastKey() != K_ESC
	    IzbF := Menu( "imp", OpcF, IzbF, .f. )
	    if IzbF == 0
        	exit
        else
        	cFile := TRIM( LEFT( OpcF[ IzbF ], 15 ) )
        	if lSilent == .t. .or. (lSilent == .f. .and. Pitanje(,"Koristiti ovaj fajl ?","D")=="D" )
        		IzbF := 0
			    lRet := .t.
		    endif
        endif
    enddo
else
    cFile := TRIM( LEFT( OpcF[ IzbF ], 15 ) )
    lRet := .t.
    IzbF := 0
endif

m_x := nPx
m_y := nPy

if lRet
	return 1
else
	return 0
endif

return 1


// --------------------
// --------------------
function preduzece()
local _t_arr := SELECT()

P_10CPI
B_ON

? ALLTRIM( gTS ) + ": "

if gNW == "D"
    ?? gFirma, "-", ALLTRIM( gNFirma )
else
    select ( F_PARTN )
    if !Used()
        O_PARTN
    endif
    select partn
    HSEEK cIdFirma
    ?? cIdFirma, ALLTRIM( partn->naz ), ALLTRIM( partn->naz2 )
endif

B_OFF
?

select ( _t_arr )
return



function RbrUNum(cRBr)
if left(cRbr, 1) > "9"
   return  (ASC(LEFT(cRbr, 1) ) -65 + 10) * 100  + VAL(substr(cRbr, 2, 2))
else
   return val(cRbr)
endif



function RedniBroj(nRbr)
local nOst
if nRbr > 999
    nOst := nRbr % 100
    return Chr( INT( nRbr / 100 ) - 10 + 65) + PADL(alltrim (str(nOst, 2) ), 2, "0")
else
    return STR(nRbr, 3, 0)
endif


// ------------------------------------------------
// provjera rednog broja u tabeli
// ------------------------------------------------
function provjeri_redni_broj()
local _ok := .t.
local _tmp

do while !EOF()

    _tmp := field->rbr
    
    skip 1

    if _tmp == field->rbr
        _ok := .f.
        return _ok        
    endif

enddo

return _ok



// da li postoji fajl u chk lokaciji, vraca oznaku
// X - nije obradjen
function UChkPostoji()
return "X"



function NazProdObj()
local cVrati:=""

cVrati:=TRIM(cTxt3a)
select fakt_pripr
return cVrati




// -------------------------------------------------
// potpis na dokumentima
// -------------------------------------------------
function dok_potpis( nLen, cPad, cRow1, cRow2 )

if nLen == nil
	nLen := 80
endif

if cPad == nil
	cPad := "L"
endif

if cRow1 == nil
	cRow1 := "Potpis:"
endif

if cRow2 == nil
	cRow2 := "__________________"
endif

if cPad == "L"
	? PADL( cRow1, nLen )
	? PADL( cRow2, nLen )
elseif cPad == "R"
	? PADR( cRow1, nLen )
	? PADR( cRow2, nLen )
else
	? PADL( cRow1, nLen )
	? PADL( cRow2, nLen )
endif

return



// ovo treba ukinuti skroz
function OtkljucajBug()
return


// ----------------------------------------------------
// upisi tekst u fajl
// ----------------------------------------------------
function write2file( nH, cText, lNewRow )
#DEFINE NROW CHR(13) + CHR(10)

if lNewRow == .t.
	FWRITE( nH, cText + NROW )
else
	FWRITE( nH, cText )
endif

return


function printfile()
return


