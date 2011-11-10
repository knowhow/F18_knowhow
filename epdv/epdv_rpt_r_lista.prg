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


#include "epdv.ch"

static aHeader:={}
static aZaglLen:={}

static aZagl:={}
static lSvakaHeader := .f.

// datumski opseg
static dDatOd 
static dDatDo

// report area
static nRArea

// kumulativ area
static nKArea

// bez path-a npr: R_KUF
static cTbl

// tekuca linija reporta
static nCurrLine:=0

static cRptNaziv := "Lista dokumenata na dan "

// -------------------------------------------
// Lista KUF/KIF
// -------------------------------------------
function r_lista(cTName)
local aDInt

aZaglLen:={8, 8, 8, 8, LEN(PIC_IZN()), LEN(PIC_IZN()), LEN(PIC_IZN()) }

if cTName == "KUF"
	nRArea := F_R_KUF
	nKArea := F_KUF
	cTbl := "R_KUF"
else
	nRArea := F_R_KIF
	nKArea := F_KIF
	cTbl := "R_KIF"
endif

aDInt := rpt_d_interval (DATE())

dDate := DATE()

dDatOd := aDInt[1]
dDatDo := DATE()


nX:=1
Box(, 8, 60)
  @ m_x+nX, m_y+2 SAY "Period"
  nX++
  
  @ m_x+nX, m_y+2 SAY "od " GET dDatOd
  @ m_x+nX, col()+2 SAY "do " GET dDatDo
  
  nX += 2
  
  @ m_x+nX, m_y+2 SAY REPLICATE("-", 30) 
  nX++
  
  READ
BoxC()

if LastKey()==K_ESC
	closeret
endif


aHeader := {}
AADD(aHeader, "Preduzece: " + gNFirma)
AADD(aHeader, cTName + " : " + cRptNaziv +  DTOC(dDate) + ", za period :" + DTOC(dDatOd) + "-" + DTOC(dDatDo) )

aZagl:={}
AADD(aZagl, { "Broj" ,  "Datum",  "Dat.d", "Dat.d",    "iznos" , "iznos",    "iznos" })
AADD(aZagl, { "dok.",  "azur.",    "min",  "max",  "bez PDV", "PDV", "sa PDV"})
AADD(aZagl, { "(1)",     "(2)",      "(3)",  "(4)",  "(5)",  "(6)", "(7)" })


fill_rpt()
show_rpt(  .f.,  .f.)

close all
*}

// ----------------------------------------------
// ----------------------------------------------
static function get_r_fields(aArr)
AADD(aArr, {"br_dok",   "N",  6, 0})
AADD(aArr, {"dat_az",   "D",  8, 0})
// datum dokumenta min - max
AADD(aArr, {"d_d_min",   "D",  8, 0})
AADD(aArr, {"d_d_max",   "D",  8, 0})
AADD(aArr, {"i_b_pdv",   "N",  18, 2})
AADD(aArr, {"i_pdv",   "N",  18, 2})

return

// ----------------------------------------
// ----------------------------------------
static function cre_r_tbl()

local aArr:={}

close all

ferase ( PRIVPATH + cTbl + ".CDX" )

get_r_fields(@aArr)

// kreiraj tabelu
dbcreate2(PRIVPATH + cTbl + ".DBF", aArr)

// kreiraj indexe
CREATE_INDEX("br_dok", "br_dok", PRIVPATH +  cTbl, .t.)

return
*}

// --------------------------------------------------------
// napuni r_kuf
// --------------------------------------------------------
static function fill_rpt()
*{

// + stavka preknjizenja = pdv
// - stavka = ppp

cre_r_tbl()


if (nRArea == F_R_KUF)
	O_R_KUF
	
	SELECT (F_KUF)
	if !used()
		O_KUF
	endif
	SET ORDER TO TAG "br_dok"

else
	O_R_KIF

	SELECT (F_KIF)
	if !used()
		O_KIF
	endif
	SET ORDER TO TAG "br_dok"

endif



SELECT (nKArea)
// datum azuriranja

PRIVATE cFilter := cm2str(dDatOd) + " <= datum_2 .and. " + cm2str(dDatDo) + ">= datum_2" 

#ifdef PROBA
MsgBeep(cFilter)
#endif

SET FILTER TO &cFilter

GO TOP


Box(,3, 60)

nCount := 0

altd()

do while !eof()

++nCount


@ m_x+2, m_y+2 SAY STR(nCount, 6, 0)

cBrDok := br_dok
nBPdv := 0
nPdv := 0
dDatAz := CTOD("")
dDMin := DATE() + 100
dDMax := CTOD("")

do while !eof() .and. br_dok == cBrDok

	// datum je manji od trenutnog min datuma
	if dDMin > datum
		dDmin := datum
	endif

	// datum veci od trenutnog max datuma
	if dDMax < datum
		dDMax := datum
	endif
	
	nBPdv += i_b_pdv
	nPdv += i_pdv
	dDatAz := datum_2
	
	skip
enddo

SELECT (nRArea)
APPEND BLANK
replace br_dok with cBrDok

replace dat_az with dDatAz
replace d_d_min with dDMin
replace d_d_max with dDMax

replace i_b_pdv with nBPdv
replace i_pdv with nPdv

SELECT (nKArea)

enddo

BoxC()

// skini filter
SELECT (nKArea)
SET FILTER TO


return
*}


static function show_rpt()
*{

nCurrLine := 0


START PRINT CRET
?

nPageLimit := 65
nRow := 0

r_zagl()

SELECT (nRArea)
SET ORDER TO TAG "1"
go top
nRbr := 0

nBPdv := 0
nPdv :=  0
do while !eof()
  
   ++ nCurrLine

   ?
   // broj dokumenta
   ?? PADL( br_dok, aZaglLen[1]) 
   ?? " "
   
   // datum azuriranja
   ?? PADL( dat_az, aZaglLen[2])
   ?? " "
   
   // datum dokumenta min
   ?? PADL( d_d_min, aZaglLen[3])
   ?? " "
   
   // datum dokumenta max
   ?? PADL( d_d_max, aZaglLen[3])
   ?? " "
  
   // bez pdv
   ?? TRANSFORM( i_b_pdv,  PIC_IZN() )
   ?? " "
   
   // pdv
   ?? TRANSFORM( i_pdv,  PIC_IZN() )
   ?? " "
   
   // sa pdv
   ?? TRANSFORM( i_b_pdv + i_pdv,  PIC_IZN() )
   ?? " "


   nBPdv += i_b_pdv
   nPdv += i_pdv
   
   if nCurrLine > nPageLimit
   	FF
	nCurrLine:=0
	if lSvakaHeader
		r_zagl()
	endif
		
   endif
   
   SKIP
   
enddo

if (nCurrLine+3) > nPageLimit 
  FF
  nCurrLine:=0
  if lSvakaHeader
	r_zagl()
  endif
endif


// ukupno izvjestaj
r_linija()
?
cPom := "U K U P N O :"
?? PADR( cPom , aZaglLen[1] + 3*8 + 3 )
?? " "
?? TRANSFORM( nBPdv  , PIC_IZN() )
?? " "

?? TRANSFORM( nPdv  , PIC_IZN() )
?? " "

?? TRANSFORM( nBPdv + nPdv  , PIC_IZN() )
  
r_linija()
  

FF
END PRINT
return
*}

// ----------------------------
// ----------------------------
static function r_zagl()

// header
P_12CPI
B_ON
for i:=1 to LEN(aHeader)
 ? aHeader[i]
 ++nCurrLine
next
B_OFF

P_12CPI

r_linija()

for i:=1 to LEN(aZagl)
 ++nCurrLine
 ?
 for nCol:=1 to LEN(aZaglLen)
  	// mergirana kolona ovako izgleda
	// "#3 Zauzimam tri kolone"
 	if LEFT(aZagl[i, nCol],1) = "#" 
	  
	  nMergirano := VAL( SUBSTR(aZagl[i, nCol], 2, 1 ) )
	  cPom := SUBSTR(aZagl[i,nCol], 3, LEN(aZagl[i,nCol])-2)
	  nMrgWidth := 0
	  for nMrg:=1 to nMergirano 
	  	nMrgWidth += aZaglLen[nCol+nMrg-1] 
		nMrgWidth ++
	  next
	  ?? PADC(cPom, nMrgWidth)
	  ?? " "
	  nCol += (nMergirano - 1)
	 else
 	  ?? PADC(aZagl[i, nCol], aZaglLen[nCol])
	  ?? " "
	 endif
 next
next
r_linija()

return


// -------------------------------
// --------------------------------
static function r_linija()
*{
++nCurrLine
?
for i=1 to LEN(aZaglLen)
   ?? PADR("-", aZaglLen[i], "-" )
   ?? " "
next

return
*}

