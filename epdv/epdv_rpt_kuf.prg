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
static lSvakaHeader := .t.

// tekuca linija reporta
static nCurrLine:=0

static cRptNaziv := "Izvjestaj KUF na dan "

static cTbl := "KUF"

static cTar := ""
static cPart := ""

static cRptBrDok := 0

// -------------------------------------------
// kuf izvjestaj
// -------------------------------------------
function rpt_kuf(nBrDok, cIdTarifa)
local cHeader
local cPom
local cPom11
local cPom12
local cPom21
local cPom22
local nLenIzn

// 1 - red.br / ili br.dok
// 2 - br.dok / ili r.br
// 3 - dat dok
// 4 - tarifna kategorija
// 5 - dobavljac (naziv + id)
// 6 - brdok dobavljaca
// 7 - opis
// 8 - izn bez pdv
// 9 - izn  pdv
// 10 - izn sa pdv


nLenIzn := LEN(PIC_IZN())
aZaglLen:={8, 8, 8, 8, 65, 12, 80,  nLenIzn, nLenIzn, nLenIzn, nLenIzn }


if nBrDok == nil
	// izvjestaj se ne pravi za jedan dokument
	nBrDok := -999
	
endif
nRptBrDok := nBrDok


if cIdTarifa == nil
	// sve tarife
	cTar := ""
else
	cTar := cIdTarifa
endif

cPart := ""

aDInt := rpt_d_interval (DATE())

dDate := DATE()

dDatOd := aDInt[1]
dDatDo := aDInt[2]


if (nBrDok == -999)

// treba zadati parametre izvjestaja

cTar := PADR(cTar, 6)
cPart := PADR(cPart, 6)

nX:=1
Box(, 11, 60)

  // izvjestaj za period
  @ m_x+nX, m_y+2 SAY "Period"
  nX++
  
  @ m_x+nX, m_y+2 SAY "od " GET dDatOd
  @ m_x+nX, col()+2 SAY "do " GET dDatDo
  
  nX += 2
  
  @ m_x+nX, m_y+2 SAY "Tarifa (prazno svi) ?  " GET cTar ;
  	VALID { || empty(cTar) .or. P_Tarifa(@cTar) } ;
	PICT "@!"
  nX += 1
  
  @ m_x+nX, m_y+2 SAY "Partner (prazno svi) ? " GET cPart ;
  	VALID { || empty(cPart) .or. P_Part(@cPart) } ;
	PICT "@!"

  nX += 2
  
  @ m_x+nX, m_y+2 SAY REPLICATE("-", 30) 
  nX++
  
  READ
BoxC()

if LastKey()==K_ESC
	closeret
endif

endif

aHeader := {}

if (nBrDok == -999)
 	cHeader :=  cRptNaziv +  DTOC(dDate) + ", za period :" + DTOC(dDatOd) + "-" + DTOC(dDatDo)  

else
	if nBrDok == 0
		cPom := "PRIPREMA"
	else
		cPom := STR(nBrDok, 6, 0)
	endif
  	cHeader :=  "Dokument KUF: " + cPom + ", na dan " + DTOC(DATE())
endif

AADD(aHeader, "Preduzece: " + my_firma() )


AADD(aHeader, cHeader )

if !empty(cTar)
	cPom := "Prikaz kategorije : " + s_tarifa(cTar)
	AADD(aHeader, cPom)
endif
	

aZagl:={}

cPom1:= ""
cPom2:= ""

if (nBrDok == -999)
	// kuf za period - globalni redni broj je prva stavka
	cPom11 := "Red."
	cPom12 := "br."

	cPom21 := "Broj"
	cPom22 := "dok"
else
	// prikaz jednog dokumenta
	// prvo brojdokumenta
	cPom11 := "Broj"
	cPom12 := "dok"
	
	// pa redni broj
	cPom21 := "Red"
	cPom22 := "br."

endif

AADD(aZagl, { cPom11,  cPom21, "Datum", "Tar.",  "Dobavljac", "Broj",  "Opis",  "iznos" , "izn.",    "izn. 2", "iznos" })
AADD(aZagl, { cPom12,  cPom22,  "",     "kat.",      "(naziv, ident. broj)",      "RN",     "",    "bez PDV", "PDV", "PDV NP", "sa PDV"})
AADD(aZagl, { "(1)",   "(2)",  "(3)",   "(4)",   "(5)",  "(6)",     "(7)", "(8)" , "(9)" ,  "(10)",  "(11) = (8+9+10)" })


fill_rpt( nBrDok )
show_rpt(  .f.,  .f.)

return

// -----------------------------------
// polja reporta
// -----------------------------------
static function get_r_fields(aArr)

AADD(aArr, {"r_br",   "N",  8, 0})
AADD(aArr, {"br_dok",   "N",  6, 0})
AADD(aArr, {"datum",   "D",  8, 0})

AADD(aArr, {"id_tar",   "C",  6, 0})
AADD(aArr, {"id_part",   "C",  6, 0})

AADD(aArr, {"dob_rn",   "C",  12, 0})
AADD(aArr, {"dob_naz",   "C",  80, 0})
AADD(aArr, {"opis",   "C",  80, 0})

AADD(aArr, {"i_b_pdv",   "N",  18, 2})
AADD(aArr, {"i_pdv",   "N",  18, 2})

return
*}

static function cre_r_tbl()
*{

local aArr:={}

close all

ferase ( PRIVPATH + "R_" +  cTbl + ".CDX" )
ferase ( PRIVPATH + "R_" +  cTbl + ".DBF" )

get_r_fields(@aArr)

// kreiraj tabelu
dbcreate2(PRIVPATH + "R_" + cTbl + ".DBF", aArr)

// kreiraj indexe
CREATE_INDEX("br_dok", "br_dok", PRIVPATH + "R_" +  cTbl, .t.)

return
*}

// ------------------------------------------
// napuni r_kuf
// ------------------------------------------
static function fill_rpt(nBrDok)
local nIzArea
local nBPdv
local nPdv 
local nRbr
local dDatum 
local cDobRn 
local cDobNaz
local cIdTar
local cOpis
local cIdPart



cre_r_tbl()


O_R_KUF

if (nBrDok == 0)
	// tabela pripreme
	
	nIzArea := F_P_KUF
	
	SELECT (F_P_KUF)
	if !used()
		O_P_KUF
	endif
	SET ORDER TO TAG "br_dok"

else
	// kumulativ

	nIzArea := F_KUF
	
	SELECT (F_KUF)
	if !used()
		O_KUF
	endif
	SET ORDER TO TAG "g_r_br"


endif



SELECT (nIzArea)

PRIVATE cFilter := ""

if (nBrdok == - 999)
	// datumski period
       cFilter := cm2str(dDatOd) + " <= datum .and. " + cm2str(dDatDo) + ">= datum" 
endif

if !empty(cTar)
	if !empty(cFilter)
		cFilter += " .and. "
	endif
	cFilter += "id_tar == "+cm2str(cTar)
endif

if !empty(cPart)
	if !empty(cFilter)
		cFilter += " .and. "
	endif
	cFilter += "id_part == "+cm2str(cPart)
endif



#ifdef PROBA
MsgBeep(cFilter)
#endif

SET FILTER TO &cFilter

GO TOP


Box(,3, 60)

nCount := 0


do while !eof()

++nCount


@ m_x+2, m_y+2 SAY STR(nCount, 6, 0)

nBrDok := br_dok
nBPdv := i_b_pdv
nPdv := i_pdv

if (nRptBrDok == -999)
	// za vise dokumenata
	nRbr := g_r_br
else
	// za jedan dokument
	nRbr := r_br
endif

dDatum := datum
cDobRn := src_br_2
cDobNaz := s_partner(id_part)
cIdTar := id_tar
cIdPart := id_part
cOpis := opis

SELECT r_kuf   
APPEND BLANK


replace id_part with cIdPart
replace br_dok with nBrDok
replace r_br with nRbr
replace id_tar with cIdTar
replace datum with dDatum
replace dob_rn with cDobRn
replace dob_naz with cDobNaz
replace opis with cOpis

replace i_b_pdv with nBPdv
replace i_pdv with nPdv

SELECT (nIzArea)

SKIP

enddo

BoxC()

// skini filter
SELECT (nIzArea)
SET FILTER TO


return
*}

// ---------------------------------------
// ---------------------------------------
static function show_rpt()
local nLenUk
local nPom1
local nPom2
local nPdv
local nPdv2

nCurrLine := 0

START PRINT CRET

//nPageLimit := 65
nPageLimit := 40
? "#%LANDS#"

P_COND
nRow := 0

r_zagl()

SELECT r_kuf
SET ORDER TO TAG "1"
go top
nRbr := 0

nUBPdv := 0
nUPdv :=  0
nUPdv2 :=  0
do while !eof()
  
   ++ nCurrLine

// 3 - dat dok
// 4 - tarifna kategorija
// 5 - dobavljac (naziv + id)
// 6 - brdok dobavljaca
// 7 - opis
// 8 - izn bez pdv
// 9 - izn  pdv
// 10 - izn sa pdv


   if nRptBrDok == -999
   	nPom1 := r_br
	nPom2 := br_dok
   else
   	nPom1 := br_dok
	nPom2 := r_br
   endif
   
   ?
   // 1. broj dokumenta
   ?? TRANSFORM( nPom1, REPLICATE("9", aZaglLen[1]) )
   ?? " "
   
   // 2. r.br
   ?? TRANSFORM( nPom2, REPLICATE("9", aZaglLen[2]) )
   ?? " "
  
   
   // 3. datum
   ?? PADR( datum, aZaglLen[3])
   ?? " "
  
   // 4. tarifa
   ?? PADR( id_tar, aZaglLen[4])
   ?? " "
   
   
   // 5. dobavljac naziv
   ?? PADR( dob_naz, aZaglLen[5])
   ?? " "
   
   // 6. dobavljac rn
   ?? PADR( dob_rn, aZaglLen[6])
   ?? " "

   // 7. opis
   ?? PADR( opis, aZaglLen[7])
   ?? " "

   // 8. bez pdv
   ?? TRANSFORM( i_b_pdv,  PIC_IZN() )
   ?? " "


   if t_u_n_poup(id_tar)
  	nPdv := 0
	nPdv2 := i_pdv
   else
	nPdv := i_pdv
	nPdv2 := 0
   endif

   // 9. standardni pdv
   ?? TRANSFORM( nPdv,  PIC_IZN() )
   ?? " "
	
   // bez prava na odbitak
   // 10. pdv NP  - neposlovne svrhe
   ?? TRANSFORM( nPdv2,  PIC_IZN() )
   ?? " "
  
   // 10. sa pdv
   ?? TRANSFORM( i_b_pdv + i_pdv,  PIC_IZN() )
   ?? " "


   nUBPdv += i_b_pdv
   nUPdv += nPdv 
   nUPdv2 += nPdv2
   
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
cPom := "   U K U P N O :  "

nLenUk := 0
for i:=1 to 7
	nLenUk += aZaglLen[i] + 1
next
nLenUk -= 1

?? PADR( cPom , nLenUk )
?? " "
?? TRANSFORM( nUBPdv  , PIC_IZN() )
?? " "

?? TRANSFORM( nUPdv  , PIC_IZN() )
?? " "

?? TRANSFORM( nUPdv2 , PIC_IZN() )
?? " "

?? TRANSFORM( nUBPdv + nUPdv + nUPdv2  , PIC_IZN() )
  
r_linija()
  

FF
END PRINT
return
*}

// ----------------------------
// ----------------------------
static function r_zagl()

// header
P_COND
B_ON
for i:=1 to LEN(aHeader)
 ? aHeader[i]
 ++nCurrLine
next
B_OFF

P_COND2

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

