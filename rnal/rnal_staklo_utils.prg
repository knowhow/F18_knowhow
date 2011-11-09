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

// --------------------------------
// pretvara mm u inch-e
// --------------------------------
function to_inch( nVal )
local nConv := nVal

if nVal <> 0
	nConv := ROUND2(( nVal / 25.4 ), 2)
endif

return nConv


// -----------------------------------------------------
// kalkulise kvadratne metre
// nDim1, nDim2 u mm
// -----------------------------------------------------
function c_ukvadrat(nKol, nDim1, nDim2)
local xRet
xRet := ( nDim1 / 1000 ) * ( nDim2 / 1000 )
xRet := nKol * xRet
return xRet



// -----------------------------------------------------
// kalkulise duzinske metre
// nDim1, nDim2 u mm
// -----------------------------------------------------
function c_duzinski( nKol, nDim1, nDim2, nDim3, nDim4 )
local xRet

if nDim3 == nil .and. nDim4 == nil
	xRet := ( (( nDim1 / 1000 )  * 2 ) + (( nDim2 / 1000 ) * 2 ) )
else
	xRet := ( ( nDim1 / 1000 ) + ( nDim2 / 1000 ) + ;
		( nDim3 / 1000 ) + ( nDim4 / 1000 ) )
endif

xRet := nKol * xRet

return xRet


// ------------------------------------------
// pretvara iznos u cent. u milimetr.
// ------------------------------------------
function cm_2_mm(nVal)
return nVal * 10


// ------------------------------------------
// pretvara iznos iz mm u cm
// ------------------------------------------
function mm_2_cm(nVal)
return nVal / 10


// ------------------------------------------
// pretvara mm u metre
// ------------------------------------------
function mm_2_m(nVal)
return nVal / 1000


// ------------------------------------------
// pretvara m u mm
// ------------------------------------------
function m_2_mm(nVal)
return nVal * 1000


// --------------------------------------------
// uklanjanje jokera iz stringa
// --------------------------------------------
function rem_jokers( cVal )

cVal := STRTRAN( cVal, "#G_CONFIG#", "" )
cVal := STRTRAN( cVal, "#HOLE_CONFIG#", "" )
cVal := STRTRAN( cVal, "#STAMP_CONFIG#", "" )
cVal := STRTRAN( cVal, "#PREP_CONFIG#", "" )
cVal := STRTRAN( cVal, "#RAL_CONFIG#", "" )

return



// ---------------------------------------------------
// ispisuje box sa slikom stakla i odabirom 
// obrade na stranicama
// ---------------------------------------------------
function glass_config( nWidth, nHeigh, ;
			cV1, cV2, cV3, cV4, ;
			nR1, nR2, nR3, nR4 )

local nBoxX := 17
local nBoxY := 56

local nGLen := 40
local nGLeft := 8
local nGTop := 4
local nGBott := 15
local cColSch := "GR+/G+"

private GetList := {}

cV1 := "N"
cV2 := cV1
cV3 := cV1
cV4 := cV1

cD1 := "N"
cD2 := cD1
cD3 := cD1
cD4 := cD1

nR1 := 0
nR2 := nR1
nR3 := nR1
nR4 := nR1

Box(, nBoxX, nBoxY)

	nStX := m_x + 2
	nStY := m_y + 2

	@ m_x + 1, m_y + 2 SAY "##glass_config##  select operations..."

	_show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh ) 
	
	// top
	@ m_x + nGTop - 1, m_y + (nBoxY / 2) - 1 SAY "d1 ?" GET cV1 ;
		PICT "@!" VALID cV1 $ "DN"
	
	// left
	@ m_x + (nBoxX / 2 ) + 1, m_y + (nGLeft - 6 ) SAY "d2 ?" GET cV2 ;
		PICT "@!" VALID cV2 $ "DN"
	
	// right
	@ m_x + (nBoxX / 2 ) + 1, m_y + (nGLeft + nGLen + 3) SAY "d3 ?" GET cV3; 
		PICT "@!" VALID cV3 $ "DN"
	
	// bottom
	@ m_x + nGBott + 1, m_y + (nBoxY / 2) - 1 SAY "d4 ?" GET cV4 ; 
			PICT "@!" VALID cV4 $ "DN"
	
	
	// procitaj prvo stranice
	read
	
	
      if pitanje(, "Definisati radijuse ?", "N") == "D"

	// pobrisi prethodno
	@ nStX, nStY CLEAR TO nStX + nBoxX - 3, nStY + nBoxY - 2


	_show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh ) 
		
	// top left
	@ m_x + nGTop - 1, m_y + ( nGLeft - 4 ) SAY "r1 ?" GET cD1 ;
		PICT "@!" VALID cD1 $ "DN"
	
	@ m_x + nGTop - 1, col() + 1 GET nR1 PICT "99999" ;
		WHEN cD1 == "D" VALID val_radius( nR1, nWidth, nHeigh )
	
	// top right
	@ m_x + nGTop - 1, m_y + ( nGLen + 3 ) SAY "r2 ?" GET cD2 ;
		PICT "@!" VALID cD2 $ "DN"
	
	@ m_x + nGTop - 1, col() + 1 GET nR2 PICT "99999" ;
		WHEN cD2 == "D" VALID val_radius( nR2, nWidth, nHeigh )
	
	// bott. left
	@ m_x + nGBott + 1, m_y + ( nGLeft - 4 ) SAY "r3 ?" GET cD3; 
		PICT "@!" VALID cD3 $ "DN"
	
	@ m_x + nGBott + 1, col() + 1 GET nR3 PICT "99999" ;
		WHEN cD3 == "D" VALID val_radius( nR3, nWidth, nHeigh )
	
	// bott. right
	@ m_x + nGBott + 1, m_y + ( nGLen + 3 ) SAY "r4 ?" GET cD4 ; 
		PICT "@!" VALID cD4 $ "DN"

	@ m_x + nGBott + 1, col() + 1 GET nR4 PICT "99999" ;
		WHEN cD4 == "D" VALID val_radius( nR4, nWidth, nHeigh )

	read
	
	// zatim procitaj radijuse
	
      endif
	
BoxC()

if LastKey() == K_ESC
	return .f.
endif

return .t.



// ---------------------------------------------------
// staklo sa prepustom - konfigurator 
// nove dimenzije stakla
// ---------------------------------------------------
function prepust_config( cJoker, nWidth, nHeigh, ;
			nD1, nD2, nD3, nD4 )

local nBoxX := 17
local nBoxY := 66

local nGLen := 38
local nGLeft := 13
local nGTop := 4
local nGBott := 15
local cColSch := "GR+/G+"

private GetList := {}

nD1 := nWidth
nD2 := nHeigh
nD3 := nD2
nD4 := nD1

Box(, nBoxX, nBoxY)

	nStX := m_x + 2
	nStY := m_y + 2

	@ m_x + 1, m_y + 2 SAY "##glass_config## konfigurisanje prepusta..."

	_show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh ) 
	
	// top
	@ m_x + nGTop - 1, m_y + (nBoxY / 2) - 1 SAY "A:" GET nD1 ;
		PICT pic_dim()
	
	// left
	@ m_x + (nBoxX / 2 ) + 1, m_y + (nGLeft - 10 ) SAY "B:" GET nD2 ;
		PICT pic_dim()
	
	// right
	@ m_x + (nBoxX / 2 ) + 1, m_y + (nGLeft + nGLen + 3) SAY "C:" GET nD3; 
		PICT pic_dim()
	
	// bottom
	@ m_x + nGBott + 1, m_y + (nBoxY / 2) - 1 SAY "D:" GET nD4 ; 
		PICT pic_dim()
	
	read
	
BoxC()

if LastKey() == K_ESC
	return ""
endif

// ako su identicne mjere kao i original staklo
// izadji
if ( nD1 = nWidth .and. nD4 = nWidth ) .and. ;
	( nD2 = nHeigh .and. nD3 = nHeigh )
	return ""
endif

cTmp := ""

// dim. 1
if nD1 > 0 
 	cTmp += "A=" + ALLTRIM(STR(nD1,12,2)) + "#" 
endif
// dim. 2
if nD2 > 0 
	cTmp += "B=" + ALLTRIM(STR(nD2,12,2)) + "#" 
endif
// dim. 3
if nD3 > 0 
	cTmp += "C=" + ALLTRIM(STR(nD3,12,2)) + "#" 
endif
// dim. 4
if nD4 > 0 
	cTmp += "D=" + ALLTRIM(STR(nD4,12,2)) + "#" 
endif

if !EMPTY( cTmp )
	cTmp := "#" + cTmp
endif

// formiraj gotov string
// <A_PREP>:#D1=2#D2=5#
//  dim1 = 2mm
//  dim2 = 5mm itd...

if !EMPTY( cTmp )
	cRet := cJoker + ":" + cTmp
endif

return cRet


// --------------------------------------
// konfigurator busenja
// cJoker - joker operacije
// --------------------------------------
function hole_config( cJoker )
local nBoxX := 12
local nBoxY := 65
local nX := 1
local cRet := ""
local nHole1 := 0
local nHole2 := 0
local nHole3 := 0
local nHole4 := 0
local nHole5 := 0
local nHole6 := 0
local nHole7 := 0
local nHole8 := 0
local nHole9 := 0
local nHole10 := 0
local cTmp := ""
local GetList := {}

// generisi box za definisanje rupa...
Box(, nBoxX, nBoxY)
	
	@ m_x + nX, m_y + 2 SAY "#HOLE_CONFIG#"

	nX += 2

	@ m_x + nX, m_y + 2 SAY "Rupa 1 (fi):" GET nHole1 PICT "999"

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Rupa 2 (fi):" GET nHole2 PICT "999"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Rupa 3 (fi):" GET nHole3 PICT "999"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Rupa 4 (fi):" GET nHole4 PICT "999"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Rupa 5 (fi):" GET nHole5 PICT "999"
	
	read

	if pitanje(,"Da li postoji jos rupa ?", "N" ) == "D"
	
		nX += 1
	
		@ m_x + nX, m_y + 2 SAY "Rupa 6 (fi):" GET nHole6 PICT "999"
		
		nX += 1
	
		@ m_x + nX, m_y + 2 SAY "Rupa 7 (fi):" GET nHole7 PICT "999"

		nX += 1
	
		@ m_x + nX, m_y + 2 SAY "Rupa 8 (fi):" GET nHole8 PICT "999"
		
		nX += 1
	
		@ m_x + nX, m_y + 2 SAY "Rupa 9 (fi):" GET nHole9 PICT "999"
		
		nX += 1
	
		@ m_x + nX, m_y + 2 SAY "Rupa 10 (fi):" GET nHole10 PICT "999"

		read

	endif
BoxC()

cTmp := ""

// rupa 1
if nHole1 <> 0
	cTmp += "H1=" + ALLTRIM(STR(nHole1)) + "#" 
endif

// rupa 2
if nHole2 <> 0
	cTmp += "H2=" + ALLTRIM(STR(nHole2)) + "#" 
endif

// rupa 3
if nHole3 <> 0
	cTmp += "H3=" + ALLTRIM(STR(nHole3)) + "#" 
endif

// rupa 4
if nHole4 <> 0
	cTmp += "H4=" + ALLTRIM(STR(nHole4)) + "#" 
endif

// rupa 5
if nHole5 <> 0
	cTmp += "H5=" + ALLTRIM(STR(nHole5)) + "#" 
endif

// rupa 6
if nHole6 <> 0
	cTmp += "H6=" + ALLTRIM(STR(nHole6)) + "#" 
endif

// rupa 7
if nHole7 <> 0
	cTmp += "H7=" + ALLTRIM(STR(nHole7)) + "#" 
endif

// rupa 8
if nHole8 <> 0
	cTmp += "H8=" + ALLTRIM(STR(nHole8)) + "#" 
endif

// rupa 9
if nHole9 <> 0
	cTmp += "H9=" + ALLTRIM(STR(nHole9)) + "#" 
endif

// rupa 10
if nHole10 <> 0
	cTmp += "H10=" + ALLTRIM(STR(nHole10)) + "#" 
endif


if !EMPTY( cTmp )
	cTmp := "#" + cTmp
endif

// formiraj gotov string
// <A_BU_HOLE>:#H1=2#H2=5#
//  hole1 = 2mm
//  hole2 = 5mm

if !EMPTY( cTmp )
	cRet := cJoker + ":" + cTmp
endif

return cRet



// --------------------------------------------------
// vraæa u stringu ispis rupa i dimenzija rupa
// --------------------------------------------------
function hole_read( cValue )
local cRet := "" 
local aTmp 
local cTmp
local aTmp2
local i
local aHole

// "<A_BU>:#H1=24#H2=55#"
aTmp := TokToNiz( cValue, ":")

if aTmp[1] <> "<A_BU>"
	// ovo nije busenje
	return cRet
endif

cTmp := ALLTRIM( aTmp[2] )

aTmp2 := TokToNiz( cTmp, "#" )

// i sada imamo rupe ...
// H1=24, H2=55

for i := 1 to LEN( aTmp2 )
	
	aHole := {}
	aHole := TokToNiz( aTmp2[i], "=" )

	cHoleTick := ALLTRIM( aHole[ 2 ] )
	
	cRet += "fi=" + cHoleTick + " mm, "
next


return cRet

// --------------------------------------------------
// vraca u stringu ispis dimenzija prepust stakla
// --------------------------------------------------
function prep_read( cValue, nW, nH )
local cRet := "" 
local aTmp 
local cTmp
local aTmp2
local i
local aPrep

// "<A_PREP>:#A=24#B=55#"
aTmp := TokToNiz( cValue, ":")

if aTmp[1] <> "<A_PREP>"
	// ovo nije prepust
	return cRet
endif

cTmp := ALLTRIM( aTmp[2] )

aTmp2 := TokToNiz( cTmp, "#" )

// i sada imamo dimenzije ...
// A=24, B=55, C=...

for i := 1 to LEN( aTmp2 )
	
	aPrep := {}
	aPrep := TokToNiz( aTmp2[i], "=" )

	cPrepPos := ALLTRIM( aPrep[1] )
	cPrepDim := ALLTRIM( aPrep[2] )
	
	if cPrepPos == "A"
		nW := VAL( cPrepDim )
	endif

	if cPrepPos == "B"
		nH := VAL( cPrepDim )
	endif

	cRet += aTmp2[i] + " mm, "
next


return cRet


// ---------------------------------------------
// procitaj vrijednosti...
// ---------------------------------------------
function get_prep_dim( cVal, nW, nH )
return prep_read( cVal, @nW, @nH )


// ---------------------------------------------------
// konfigurator pozicije peèata 
// ---------------------------------------------------
function stamp_config( cJoker, nWidth, nHeigh )

local nBoxX := 17
local nBoxY := 56
local cReturn := ""
local cTmp := ""
local nGLen := 40
local nGLeft := 8
local nGTop := 6
local nGBott := 15
local cColSch := "GR+/G+"

private GetList := {}

// varijable
cStampInfo := "P"
cStampSch := "N"
nX1 := nY1 := 0
nX2 := nY2 := 0
nX3 := nY3 := 0
nX4 := nY4 := 0

Box(, nBoxX, nBoxY)

	do while .t.

	nStX := m_x + 2
	nStY := m_y + 2

	@ m_x + 1, m_y + 2 SAY "##stamp_position##  select position..."

	@ m_x + 2, m_y + 2 SAY "vrsta pecata [P]ositiv / [N]egativ:" GET cStampInfo VALID cStampInfo $ "PN" PICT "@!"
	
	@ m_x + 3, m_y + 2 SAY "pogledati shemu u prilogu (D/N)?" GET cStampSch VALID cStampSch $ "DN" PICT "@!" 

	read
	
	if cStampSch == "N"
	
	  _show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh ) 
	
	  // x1
	  @ m_x + nGTop - 1, m_y + nGLeft GET nX1 PICT "999" ;
		VALID val_stamp( nX1, nWidth, nHeigh )
	  @ m_x + nGTop - 1, col() SAY "mm"
	
	  // x2
	  @ m_x + nGTop - 1, col() + nGLen - 8 GET nX2 PICT "999" ;
		VALID val_stamp( nX2, nWidth, nHeigh )
	  @ m_x + nGTop - 1, col() SAY "mm"
	
	  // y1
	  @ m_x + nGTop + 1, m_y + 2 GET nY1 PICT "999" ;
		VALID val_stamp( nY1, nWidth, nHeigh )
	  @ m_x + nGTop + 1, col() SAY "mm"
	
	  // y2
	  @ m_x + nGTop + 1, col() + ( nGLen  + 4 ) GET nY2 PICT "999" ;
		VALID val_stamp( nY2, nWidth, nHeigh )
	  @ m_x + nGTop + 1, col() SAY "mm"
	
	  // y3
	  @ m_x + nGBott - 2, m_y + 2 GET nY3 PICT "999" ;
		VALID val_stamp( nY3, nWidth, nHeigh )
	  @ m_x + nGBott - 2, col() SAY "mm"
	
	  // y4
	  @ m_x + nGBott - 2, col() + ( nGLen + 4 ) GET nY4 PICT "999" ;
		VALID val_stamp( nY4, nWidth, nHeigh )
	  @ m_x + nGBott - 2, col() SAY "mm"
	
	  // x3
	  @ m_x + nGBott + 1, m_y + nGLeft GET nX3 PICT "999" ;
		VALID val_stamp( nX3, nWidth, nHeigh )
	  @ m_x + nGBott + 1, col() SAY "mm"
	
	  // x4
	  @ m_x + nGBott + 1, col() + ( nGLen - 8 ) GET nX4 PICT "999" ;
		VALID val_stamp( nX4, nWidth, nHeigh )
	  @ m_x + nGBott + 1, col() SAY "mm"

	
	  read
	
	
	  // mora biti unesena pozicija
	  if (nX1 + nX2 + nX3 + nX4 + nY1 + nY2 + nY3 + nY4 ) <> 0
		exit
	  endif

	else
		exit
	endif
	
	
	enddo
BoxC()

if LastKey() == K_ESC
	return cReturn
endif

cTmp := ""

if nX1 <> 0
	cTmp += "X1=" + ALLTRIM(STR(nX1)) + "#"
endif
if nY1 <> 0
	cTmp += "Y1=" + ALLTRIM(STR(nY1)) + "#"
endif
if nX2 <> 0
	cTmp += "X2=" + ALLTRIM(STR(nX2)) + "#"
endif
if nY2 <> 0
	cTmp += "Y2=" + ALLTRIM(STR(nY2)) + "#"
endif
if nX3 <> 0
	cTmp += "X3=" + ALLTRIM(STR(nX3)) + "#"
endif
if nY3 <> 0
	cTmp += "Y3=" + ALLTRIM(STR(nY3)) + "#"
endif
if nX4 <> 0
	cTmp += "X4=" + ALLTRIM(STR(nX4)) + "#"
endif
if nY4 <> 0
	cTmp += "Y4=" + ALLTRIM(STR(nY4)) + "#"
endif

if !EMPTY(cTmp) .or. cStampSch == "D"
	
	// ako je pogledaj shemu
	if cStampSch == "D"
		
		cTmp := cStampSch
		
	endif
	
	// primjer stringa koji se dobije:
	//  STAMP:P#X1=20#Y1=25#
	
	cReturn := "STAMP" + ":" + cStampInfo + "#" + cTmp

endif

return cReturn



// -----------------------------------------------
// citanje pozicije pecata za nalog
// -----------------------------------------------
function stamp_read( cStampStr )
local cRet := ""
local i
local aTmp
local aTmp2
local aTmp3

if EMPTY( cStampStr )
	return cRet
endif

//        string                   1          2
// ex: "<A_K>:P#X1=20#Y1=25" => {<A_K>} {P#X1=20#Y1=25}
aTmp := TokToNiz( cStampStr, ":" )

if aTmp[1] <> "STAMP"

	return cRet

endif


// ex: "P#X1=20#Y1=25" =>  {P} {X1=20} {Y1=25}
aTmp2 := TokToNiz( aTmp[2], "#" )

cRet := "pozicija pecata: "


// pozitiv ili negativ
if aTmp2[1] == "P"
	cRet += "pozitiv, "
elseif aTmp2[1] == "N"
	cRet += "negativ, "
endif

if aTmp2[2] == "D"

	// ako je pozicija pecata, pogledati shemu
	// ex: "P#D" => {P} {D}

	cRet += " (pogledaj shemu u prilogu ) "
	return cRet
	
endif



// x koordinata
aTmp3 := TokToNiz( aTmp2[2], "=" )

// dodaj na ispis
cRet += _stamp_pos( aTmp3[ 1 ] ) 
cRet += " "
cRet += ALLTRIM( aTmp3[2] )
cRet += " mm - "

// y koordinata
aTmp3 := TokToNiz( aTmp2[3], "=" )

// dodaj na ispis i y koordinatu
cRet += _stamp_pos( aTmp3[ 1 ] ) 
cRet += " "
cRet += ALLTRIM( aTmp3[2] )
cRet += " mm"

return cRet


// ----------------------------------------
// pozicija peèata stranice
// ----------------------------------------
static function _stamp_pos( cVar )
local cRet := ""

do case
	case cVar $ "X1#X2"
		cRet := "gore"
	case cVar $ "X3#X4"
		cRet := "dole"
	case cVar $ "Y1#Y3"
		cRet := "lijevo"
	case cVar $ "Y2#Y4"
		cRet := "desno"
endcase

return cRet



// -------------------------
// validacija pecata 
// osnovu dimenzija A i B
// stakla
// -------------------------
function val_stamp( nDim, nA, nB )
local lRet := .t.
// trenutno nas nista ne interesuje....
return lRet




// -------------------------
// validacija radijusa na 
// osnovu dimenzija A i B
// stakla
// -------------------------
function val_radius( nRadius, nA, nB )
local lRet := .t.

if nRadius > ( nA / 2 ) .or. nRadius > ( nB / 2 )
	lRet := .f.
endif

if lRet == .f.
	msgbeep("Radijus ne moze biti veci od pola duzine stranice !")
endif

return lRet


// ----------------------------------------
// prikazuje sliku stakla unutar box-a
// nLenght - duzina stakla
// nTop - vrh stakla
// nBottom - dno stakla
// nLeft - lijeva strana
// cColSch - kolor shema
// ----------------------------------------
static function _show_glass( nLenght, nTop, nBottom, nLeft, cColSch, ;
				nWidth, nHeigh)
local i
local nTmp 
local nDimPos := nBottom - nTop 

// gornja strana
@ m_x + nTop, m_y + nLeft SAY CHR(218) ;
		COLOR cColSch
@ m_x + nTop, m_y + nLeft + 1 SAY REPLICATE( CHR(196), nLenght ) ;
		COLOR cColSch
@ m_x + nTop, m_y + (nLeft + 1 + nLenght ) SAY CHR(191) ;
		COLOR cColSch

nTmp := nTop + 1

// popuna
for i := nTmp to nBottom
	@ m_x + i, m_y + nLeft SAY CHR(179) + ;
		REPLICATE(CHR(176), nLenght) + CHR(179) COLOR cColSch
next

// donja strana
@ m_x + nBottom, m_y + nLeft SAY CHR(192) ;
		COLOR cColSch
@ m_x + nBottom, m_y + nLeft + 1 SAY REPLICATE( CHR(196), nLenght ) ;
		COLOR cColSch
@ m_x + nBottom, m_y + nLeft + 1 + nLenght SAY CHR(217) ;
		COLOR cColSch

// ispisi dimenzije stakla
@ m_x + nDimPos - 1, m_y + 20 SAY "glass dimensions:"
@ m_x + nDimPos, m_y + 20 SAY ALLTRIM(STR(nWidth, 12, 2)) + ;
				" x " + ;
				ALLTRIM(STR(nHeigh, 12, 2)) + " mm" 

return


// ---------------------------------
// glass tickness
// ---------------------------------
function glass_tick( cTick )
local nGlTick := 0
local aTmp := {}
local cTmp := ""
local i

// ovo je slucaj za LAMI staklo...
if "." $ cTick

	// ex: "33.1"
	aTmp := TokToNiz( cTick, "." )
	// ex: "33"
	cTmp := aTmp[1]

	for i:=1 to LEN(cTmp)
		nGlTick += VAL ( SUBSTR( cTmp, i, 1 ) )
	next

	// ex: "33" -> 6
else
	// klasicno staklo...
	nGlTick := VAL( ALLTRIM(cTick) )
endif

return nGlTick



// ---------------------------------------------
// da li se radi o rama-term staklu
// ---------------------------------------------
function is_ramaterm( cArticle )
local lRet := .f.

if "_A" $ cArticle
	lRet := .t.
endif

return lRet


