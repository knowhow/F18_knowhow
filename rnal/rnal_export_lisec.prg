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


// static variables
static __REL_VER
static __REL
static __ORD
static __POS
static __PO2
static __GLX
static __FRX
static __TXT
static __TX2
static __TX3
static __SPACE



// --------------------------------------------
// setovanje i definicija kljucnih rijeci
// setovanje statickih varijabli
// --------------------------------------------
function set_keywords()

__REL_VER := "02.60"
__REL := "<REL>"
__ORD := "<ORD>"
__POS := "<POS>"
__PO2 := "<PO2>"
__TXT := "<TXT>"
__TX2 := "<TX2>"
__TX3 := "<TX3>"
__GLX := "<GLx>"
__FRX := "<FRx>"
__SPACE := SPACE(1)

return


// ---------------------------------------------
// <REL>
// Transfer file release version (file version)
// ---------------------------------------------

// ------------------------------
// dodaj u record <REL>
// ------------------------------
function add_rel( cRelAddInfo )
local aRel := {}

set_keywords()

if EMPTY(cRelAddInfo) .or. cRelAddInfo == nil
	cRelAddInfo := ""
endif

AADD( aRel, __REL )
AADD( aRel, __REL_VER )
AADD( aRel, cRelAddInfo )

return aRel




// -----------------------------------------------
// vraca specifikaciju recorda <REL>
// -----------------------------------------------
function _get_rel()
local aRelSpec := {}

set_keywords()

AADD(aRelSpec, { __REL,     "C", 5 } )
AADD(aRelSpec, { "REL_NUM", "N", 2.2 } )
AADD(aRelSpec, { "REL_INFO", "C", 40 } )

return aRelSpec



// ---------------------------------------------
// <ORD>
// Order record
// ---------------------------------------------

// ------------------------------
// dodaj u record <ORD>
// ------------------------------
function add_ord( nOrd_no, ;
		nCust_id, ;
		cCust_name, ;
		cText1, ;
		cText2, ;
		cText3, ;
		cText4, ;
		cText5, ;
		dDoc_date, ;
		dDoc_dvr_date, ;
		cDvr_ship )

local aOrd := {}

set_keywords()

AADD( aOrd, __ORD )
AADD( aOrd, nOrd_no )
AADD( aOrd, ALLTRIM(STR(nCust_id)) )
AADD( aOrd, cCust_name )
AADD( aOrd, cText1 )
AADD( aOrd, cText2 )
AADD( aOrd, cText3 )
AADD( aOrd, cText4 )
AADD( aOrd, cText5 )
AADD( aOrd, conv_date( dDoc_date ) )
AADD( aOrd, conv_date( dDoc_dvr_date ) )
AADD( aOrd, cDvr_ship )

return aOrd



// -----------------------------------------------
// vraca specifikaciju recorda <ORD>
// -----------------------------------------------
function _get_ord()
local aOrdSpec := {}

set_keywords()

AADD(aOrdSpec, { __ORD,      "C",    5 } )
AADD(aOrdSpec, { "ORD",      "N",   10 } )
AADD(aOrdSpec, { "CUST_NUM", "C",   10 } )
AADD(aOrdSpec, { "CUST_NAM", "C",   40 } )
AADD(aOrdSpec, { "TEXT1",    "C",   40 } )
AADD(aOrdSpec, { "TEXT2",    "C",   40 } )
AADD(aOrdSpec, { "TEXT3",    "C",   40 } )
AADD(aOrdSpec, { "TEXT4",    "C",   40 } )
AADD(aOrdSpec, { "TEXT5",    "C",   40 } )
AADD(aOrdSpec, { "PRD_DATE", "C",   10 } )
AADD(aOrdSpec, { "DEL_DATE", "C",   10 } )
AADD(aOrdSpec, { "DEL_AREA", "C",   10 } )

return aOrdSpec



// ------------------------------------
// konverzija datuma
// 01.01.2007 => 01/01/2007
// #format = "DD/MM/YYYY"
// ------------------------------------
static function conv_date( dDate )
local cDate

cDate := ""
cDate += PADL( ALLTRIM(STR(DAY(dDate))), 2, "0" )
cDate += "/"
cDate += PADL( ALLTRIM(STR(MONTH(dDate))), 2, "0" )
cDate += "/"
cDate += STR( YEAR(dDate) , 4 )

return cDate


// ---------------------------------------------
// <POS>
// Item record
// ---------------------------------------------

// ------------------------------
// dodaj u record <POS>
// ------------------------------
function add_pos( nItem_no, ;
		cId_no, ;
		nBarCode, ;
		nQty, ;
		nWidth, ;
		nHeight, ;
		cGlass1, ;
		cFrame1, ;
		cGlass2, ;
		cFrame2, ;
		cGlass3, ;
		nInset, ;
		nFrame_txt, ;
		nGas_code1, ;
		nGas_code2, ;
		nSeal_type, ;
		nFrah_type, ;
		nFrah_hoe, ;
		nPattDir )

local aPos := {}

set_keywords()

AADD( aPos, __POS )
AADD( aPos, nItem_no )
AADD( aPos, cId_no )
AADD( aPos, nBarcode )
AADD( aPos, nQty )
AADD( aPos, calc_dim(nWidth) )
AADD( aPos, calc_dim(nHeight) )
AADD( aPos, cGlass1 )
AADD( aPos, cFrame1 )
AADD( aPos, cGlass2 )
AADD( aPos, cFrame2 )
AADD( aPos, cGlass3 )
AADD( aPos, nInset )
AADD( aPos, nFrame_txt )
AADD( aPos, nGas_code1 )
AADD( aPos, nGas_code2 )
AADD( aPos, nSeal_type )
AADD( aPos, nFrah_type )
AADD( aPos, nFrah_hoe )
AADD( aPos, nPattdir )

return aPos



// -----------------------------------------------
// vraca specifikaciju recorda <POS>
// -----------------------------------------------
function _get_pos()
local aPosSpec := {}

set_keywords()

AADD(aPosSpec, { __POS,      "C",    5 } )
AADD(aPosSpec, { "ITEM_NUM", "N",    5 } )
AADD(aPosSpec, { "ID_NUM",   "C",    8 } )
AADD(aPosSpec, { "BARCODE",  "N",    4 } )
AADD(aPosSpec, { "QTY",      "N",    5 } )
AADD(aPosSpec, { "WIDTH",    "N",    5 } )
AADD(aPosSpec, { "HEIGHT",   "N",    5 } )
AADD(aPosSpec, { "GLASS1",   "C",    5 } )
AADD(aPosSpec, { "FRAME1",   "C",    3 } )
AADD(aPosSpec, { "GLASS2",   "C",    5 } )
AADD(aPosSpec, { "FRAME2",   "C",    3 } )
AADD(aPosSpec, { "GLASS3",   "C",    5 } )
AADD(aPosSpec, { "INSET",    "N",    3 } )
AADD(aPosSpec, { "FRAME_TXT",  "N",    2 } )
AADD(aPosSpec, { "GAS_CODE1",  "N",    2 } )
AADD(aPosSpec, { "GAS_CODE2",  "N",    2 } )
AADD(aPosSpec, { "SEAL_TYPE",  "N",    1 } )
AADD(aPosSpec, { "FRAH_TYPE",  "N",    1 } )
AADD(aPosSpec, { "FRAH_HOE",  "N",    5 } )
AADD(aPosSpec, { "PATT_DIR",  "N",    1 } )

return aPosSpec



// ----------------------------------------
// kalkulisi dimenziju
// n/10 mm je u GPS.opt uzima
// dakle moram svoju dim. pomnoziti sa 10
// ----------------------------------------
static function calc_dim( nDim )
local xRet := 0

if nDim = 0
	xRet := nDim
endif

xRet := nDim * 10

return xRet



// ---------------------------------------------
// <PO2>
// Additional record information
// ---------------------------------------------

// ------------------------------
// dodaj u record <PO2>
// -----------------------------
function add_po2( cIdCode, ;
		nW1, nH1, ;
		nG1_bott, nG1_rig, nG1_top, nG1_left, ;
		nS1_bott, nS1_rig, nS1_top, nS1_left, ;
		nW2, nH2, ;
		nG2_bott, nG2_rig, nG2_top, nG2_left, ;
		nS2_bott, nS2_rig, nS2_top, nS2_left, ;
		nOff2x, nOff2y, ;
		nW3, nH3, ;
		nG3_bott, nG3_rig, nG3_top, nG3_left, ;
		nS3_bott, nS3_rig, nS3_top, nS3_left, ;
		nOff3x, nOff3y )

local aPo2 := {}

set_keywords()

AADD( aPo2, __PO2 )
AADD( aPo2, cIdCode )
AADD( aPo2, calc_dim(nW1) )
AADD( aPo2, calc_dim(nH1) )
AADD( aPo2, calc_dim( nG1_bott ) )
AADD( aPo2, calc_dim(nG1_rig) )
AADD( aPo2, calc_dim(nG1_top) )
AADD( aPo2, calc_dim(nG1_left) )
AADD( aPo2, calc_dim(nS1_bott) )
AADD( aPo2, calc_dim(nS1_rig) )
AADD( aPo2, calc_dim(nS1_top) )
AADD( aPo2, calc_dim(nS1_left) )
AADD( aPo2, calc_dim(nW2) )
AADD( aPo2, calc_dim(nH2) )
AADD( aPo2, calc_dim(nG2_bott) )
AADD( aPo2, calc_dim(nG2_rig) )
AADD( aPo2, calc_dim(nG2_top) )
AADD( aPo2, calc_dim(nG2_left) )
AADD( aPo2, calc_dim(nS2_bott) )
AADD( aPo2, calc_dim(nS2_rig) )
AADD( aPo2, calc_dim(nS2_top) )
AADD( aPo2, calc_dim(nS2_left) )
AADD( aPo2, calc_dim(nOff2x) )
AADD( aPo2, calc_dim(nOff2y) )
AADD( aPo2, calc_dim(nW3) )
AADD( aPo2, calc_dim(nH3) )
AADD( aPo2, calc_dim(nG3_bott) )
AADD( aPo2, calc_dim(nG3_rig) )
AADD( aPo2, calc_dim(nG3_top) )
AADD( aPo2, calc_dim(nG3_left) )
AADD( aPo2, calc_dim(nS3_bott) )
AADD( aPo2, calc_dim(nS3_rig) )
AADD( aPo2, calc_dim(nS3_top) )
AADD( aPo2, calc_dim(nS3_left) )
AADD( aPo2, calc_dim(nOff3x) )
AADD( aPo2, calc_dim(nOff3y) )

return aPo2


// -----------------------------------------------
// vraca specifikaciju recorda <PO2>
// dodatne informacije na samom rekord-u iz <POS>
// -----------------------------------------------
function _get_po2()
local aPO2Spec := {}

set_keywords()

AADD(aPO2Spec, { __PO2,        "C",    5 } )
AADD(aPO2Spec, { "ID_CODE",    "C",   40 } )
AADD(aPO2Spec, { "WIDTH1",     "N",    5 } )
AADD(aPO2Spec, { "HEIGHT1",    "N",    5 } )
AADD(aPO2Spec, { "GA1_BOTT",   "N",    4 } )
AADD(aPO2Spec, { "GA1_RIGHT",  "N",    4 } )
AADD(aPO2Spec, { "GA1_TOP",    "N",    4 } )
AADD(aPO2Spec, { "GA1_LEFT",   "N",    4 } )
AADD(aPO2Spec, { "ST1_BOTT",   "N",    5 } )
AADD(aPO2Spec, { "ST1_RIGHT",  "N",    5 } )
AADD(aPO2Spec, { "ST1_TOP",    "N",    5 } )
AADD(aPO2Spec, { "ST1_LEFT",   "N",    5 } )
AADD(aPO2Spec, { "WIDTH2",     "N",    5 } )
AADD(aPO2Spec, { "HEIGHT2",    "N",    5 } )
AADD(aPO2Spec, { "GA2_BOTT",   "N",    4 } )
AADD(aPO2Spec, { "GA2_RIGHT",  "N",    4 } )
AADD(aPO2Spec, { "GA2_TOP",    "N",    4 } )
AADD(aPO2Spec, { "GA2_LEFT",   "N",    4 } )
AADD(aPO2Spec, { "ST2_BOTT",   "N",    5 } )
AADD(aPO2Spec, { "ST2_RIGHT",  "N",    5 } )
AADD(aPO2Spec, { "ST2_TOP",    "N",    5 } )
AADD(aPO2Spec, { "ST2_LEFT",   "N",    5 } )
AADD(aPO2Spec, { "OFFS2_X",    "N",    5 } )
AADD(aPO2Spec, { "OFFS2_Y",    "N",    5 } )
AADD(aPO2Spec, { "WIDTH3",     "N",    5 } )
AADD(aPO2Spec, { "HEIGHT3",    "N",    5 } )
AADD(aPO2Spec, { "GA3_BOTT",   "N",    4 } )
AADD(aPO2Spec, { "GA3_RIGHT",  "N",    4 } )
AADD(aPO2Spec, { "GA3_TOP",    "N",    4 } )
AADD(aPO2Spec, { "GA3_LEFT",   "N",    4 } )
AADD(aPO2Spec, { "ST3_BOTT",   "N",    5 } )
AADD(aPO2Spec, { "ST3_RIGHT",  "N",    5 } )
AADD(aPO2Spec, { "ST3_TOP",    "N",    5 } )
AADD(aPO2Spec, { "ST3_LEFT",   "N",    5 } )
AADD(aPO2Spec, { "OFFS3_X",    "N",    5 } )
AADD(aPO2Spec, { "OFFS3_Y",    "N",    5 } )

return aPO2Spec



// ---------------------------------------------
// <GLx>
// Glass record information
// ---------------------------------------------

// ------------------------------
// dodaj u record <GLx>
// -----------------------------
function add_glx( cGlassNo, cIdCode )
local aGLx := {}

set_keywords()

AADD( aGLx, STRTRAN( __GLX, "x", cGlassNo ) )
AADD( aGLx, cIdCode )

return aGLx


// -----------------------------------------------
// vraca specifikaciju recorda <GLx>
// -----------------------------------------------
function _get_glx()
local aGLxSpec := {}

set_keywords()

AADD(aGLxSpec, { __GLX,      "C",    5 } )
AADD(aGLxSpec, { "DESCRIPT", "C",   40 } )
AADD(aGLxSpec, { "TYPE",     "N",    1 } )
AADD(aGLxSpec, { "THICKNESS",  "N",  5 } )
AADD(aGLxSpec, { "FACE_SIDE",  "N",  1 } )
AADD(aGLxSpec, { "IDENT",      "C", 10 } )
AADD(aGLxSpec, { "PATT_DIR",   "N",  1 } )

return aGLxSpec


// ---------------------------------------------
// <FRx>
// Frame record information
// ---------------------------------------------

// ------------------------------
// dodaj u record <FRx>
// -----------------------------
function add_frx( cFrameNo, cIdCode )
local aFrx := {}

set_keywords()

AADD( aFRx, STRTRAN( __FRX, "x", cFrameNo ) )
AADD( aFRx, cIdCode )

return aFRx


// -----------------------------------------------
// vraca specifikaciju recorda <FRx>
// -----------------------------------------------
function _get_frx()
local aFRxSpec := {}

set_keywords()

AADD(aFRxSpec, { __FRX,      "C",    5 } )
AADD(aFRxSpec, { "DESCRIPT", "C",   40 } )
AADD(aFRxSpec, { "TYPE",     "N",    1 } )
AADD(aFRxSpec, { "WIDTH",    "N",    5 } )
AADD(aFRxSpec, { "HEIGHT",   "N",    5 } )
AADD(aFRxSpec, { "IDENT",    "C",   10 } )

return aFRxSpec



// ---------------------------------------------
// <TXT>
// Additional record information
// ---------------------------------------------

// ------------------------------
// dodaj u record <TXT>
// -----------------------------
function add_txt( nVar, cT1, cT2, cT3, cT4, cT5, cT6, cT7, cT8, cT9, cT10 )
local aTxt := {}

set_keywords()

if nVar == nil
	nVar := 1
endif

if nVar == 1
	AADD( aTxt, __TXT )
endif

if nVar == 2
	AADD( aTxt, __TX2 )
endif

if nVar == 3
	AADD( aTxt, __TX3 )
endif

AADD( aTxt, cT1 )
AADD( aTxt, cT2 )
AADD( aTxt, cT3 )
AADD( aTxt, cT4 )
AADD( aTxt, cT5 )
AADD( aTxt, cT6 )
AADD( aTxt, cT7 )
AADD( aTxt, cT8 )
AADD( aTxt, cT9 )
AADD( aTxt, cT10 )

return aTxt


// -----------------------------------------------
// vraca specifikaciju recorda <TXT>
// -----------------------------------------------
function _get_txt( nVar )
local aTxtSpec := {}

set_keywords()

if nVar == nil
	nVar := 1
endif

if nVar == 1
	AADD(aTxtSpec, { __TXT,      "C",    5 } )
endif

if nVar == 2
	AADD(aTxtSpec, { __TX2,      "C",    5 } )
endif

if nVar == 3
	AADD(aTxtSpec, { __TX3,      "C",    5 } )
endif

AADD(aTxtSpec, { "TEXT1",  "C",   40 } )
AADD(aTxtSpec, { "TEXT2",  "C",   40 } )
AADD(aTxtSpec, { "TEXT3",  "C",   40 } )
AADD(aTxtSpec, { "TEXT4",  "C",   40 } )
AADD(aTxtSpec, { "TEXT5",  "C",   40 } )
AADD(aTxtSpec, { "TEXT6",  "C",   40 } )
AADD(aTxtSpec, { "TEXT7",  "C",   40 } )
AADD(aTxtSpec, { "TEXT8",  "C",   40 } )
AADD(aTxtSpec, { "TEXT9",  "C",   40 } )
AADD(aTxtSpec, { "TEXT10",  "C",   40 } )

return aTxtSpec




// --------------------------------------------------
//
//
// FUNKCIJE ZA UPISIVANJE TEKSTA U TRF FAJL
//
//
// --------------------------------------------------




// ----------------------------------------
// ispisi vrijednosti recorda
// na osnovu aRec podataka 
// i na osnovu aSpec - specifikacije polja
// ----------------------------------------
function write_rec( nH, aRec, aSpec )
local i
local nI
local nII
local cTmp := ""
local cType 
local nLen 
local xVal
local nVal1
local nVal2
local cTrans
local aPom

set_keywords()

for i := 1 to LEN( aRec )
	
	// dodaj space, ali ne na prvoj
	if i <> 1
	
		cTmp += __SPACE
		
	endif
	
	xVal := aRec[ i ]
	cType := aSpec[ i, 2 ]
	nLen := aSpec[ i, 3 ]
	
	if xVal == nil .or. EMPTY(xVal)
		xVal := " "
	endif
	
	// karakterni tip
	if cType == "C"
	
		cTmp += PADR( xVal , nLen, " " )
	
	endif

	// numericki tip
	if cType == "N"
	
		aPom := TokToNiz( ALLTRIM(STR(nLen)), "." )
		nVal1 := 0
		nVal2 := 0
		
		for nI := 1 to LEN( aPom )
		
			if nI == 1
				nVal1 := VAL( aPom[nI] )
			endif
			
			if nI == 2
				nVal2 := VAL( aPom[nI] )
			endif
			
		next
		
		cTrans := REPLICATE( "9", nVal1 )
			
		if nVal2 > 0
			cTrans += "." + REPLICATE( "9", nVal2 )
		endif
		
		nTmpLen := LEN( cTrans )
		
		if VALTYPE(xVal) == "N"
			
			cTmp += PADL( ALLTRIM( STR(xVal, nVal1, nVal2 ) ), nTmpLen, "0" )
		
		endif
		
		if VALTYPE(xVal) == "C"
		
			if xVal == " "
				xVal := 0
			endif
			
			
			cTmp += PADL ( ALLTRIM( TRANSFORM( xVal, cTrans )), nTmpLen, "0" )
			
		endif

	endif

next

// upisi u fajl
write2file( nH, cTmp, .t. )

return

// -------------------------------------------
// konverzija windows
// -------------------------------------------
static function win_txt_conv( cTxt )

cTxt := STRTRAN(cTxt, "È", "¬" )

return


