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


#include "kalk.ch"

static aHeader:={}
static aZaglLen:={5, 50, 5, 12, 15, 15, 10, 10, 15, ;
                  10, 10, 10, 15, 15, 15}
static aZagl:={}
static cij_decimala:=2
static izn_decimala:=2
static kol_decimala:=3
static za_mpc_ppp:=3
static za_mpc_pdv:=3
static PDV_STOPA:=17

// tekuca linija reporta
static nCurrLine:=0

function rpt_uio()

local lAkciznaRoba := .f.
local lZasticeneCijene := .f.

cIdFirma := gFirma
cBrDok := PADR("00010", 8)
cIdVd := "80"
cLandscape := "D"
cSvakaHeader := "N"

dDate := CTOD("31.12.05")
Box(, 14, 60)
  @ m_x+1, m_y+2 SAY "Dokument "
  @ m_x+2, m_y+2 SAY gFirma + " - " + cIdVd + " " GET cBrDok 
  @ m_x+3, m_y+2 SAY "Datum " GET dDate
  @ m_x+4, m_y+2 SAY PADR("-", 30, "-")
  @ m_x+5, m_y+2 SAY "Broj decimala cijena  " GET cij_decimala PICT "9"
  @ m_x+6, m_y+2 SAY "                iznos " GET izn_decimala PICT "9"
  @ m_x+7, m_y+2 SAY "             kolicina " GET kol_decimala PICT "9"
  
  @ m_x+9,  m_y+2 SAY " zaokruz. prod.cj ppp " GET za_mpc_ppp PICT "9"
  @ m_x+10, m_y+2 SAY " zaokruz. prod.cj pdv " GET za_mpc_pdv PICT "9"
  
  @ m_x+12, m_y+2 SAY "Landscape format " GET cLandscape PICT "@!" VALID cLandscape $ "DN"
  @ m_x+13, m_y+2 SAY "Zagl. na svaku stranu " GET cSvakaHeader PICT "@!" VALID cSvakaHeader $ "DN"

  READ
BoxC()

if LastKey()==K_ESC
	closeret
endif

O_KALK
SET ORDER TO TAG "1"
seek cIdFirma + cIdVd + cBrDok 

O_ROBA
O_KONTO
O_KONCIJ
O_TARIFA

SELECT KONTO
SEEK kalk->PKonto

aHeader := {}
AADD(aHeader, "Preduzece: " + gNFirma)
AADD(aHeader, "Popis zaliha na dan :" +  DTOC(dDate) + ", Prodavnica :" + konto->naz + " sa obracunom PDV-a na isti dan" )

aZagl:={}
AADD(aZagl, { "R." , "Vrsta robe", "jed" , "kolic", "cijena", "zaduz", "#3Porez na promet proizvoda", "", "", "Cijena", "#2 Cijena od 1.1.2006", "", "Ukupni", "Ukupno", "Razlika" } )
AADD(aZagl, { "br.", "", " mj", "", "", "(3 x 4)", "Prer.st", "u cijeni", "Ukupno", "bez poreza", "PDV 17%", "Cijena sa PDV", "PDV", "zad 1.1.06", ""  })
AADD(aZagl, { "(1)"  , "(2)" , "(3)", "(4)", "(5)", "(6)=(4x5)", "7", "8=(5x7)", "9=(8x4)" , "10=(5-8)", "11=(10x17%)", "12=(10+11)", "13=(4x11)", "14=(4x12)", "15=(6-14)"  })


fill_uio(cIdFirma, cIdVd, cBrDok, lAkciznaRoba, lZasticeneCijene)
show_uio( (cLandscape=="D"), (cSvakaHeader=="D"), lAkciznaRoba, lZasticeneCijene )

close all
*}

/*! \fn get_uio_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
static function get_uio_fields(aArr)
*{
AADD(aArr, {"IdTarifa",   "C",  6, 0})
AADD(aArr, {"Tarifa",   "N",  10, 2})
AADD(aArr, {"IdRoba",   "C",  10, 0})
AADD(aArr, {"NazivR",   "C",  40, 0})
AADD(aArr, {"jmj",  "C",  3, 0})
AADD(aArr, {"kol",  "N",  15, 5})
AADD(aArr, {"cij_ppp",  "N",  15, 5})
AADD(aArr, {"zad_ppp", "N",  17, 2})
AADD(aArr, {"ppp_pstopa", "N", 8, 3})
AADD(aArr, {"ppp_ucj" , "N", 15, 5})
AADD(aArr, {"uk_ppp",  "N",  17, 3})
AADD(aArr, {"cij_b_pdv", "N", 9, 3})
AADD(aArr, {"izn_pdv", "N", 9, 3})
AADD(aArr, {"cij_sa_pdv", "N", 9, 3})
AADD(aArr, {"uk_pdv", "N", 17, 3})
AADD(aArr, {"zad_pdv", "N", 17, 2})
AADD(aArr, {"razlika", "N", 17, 3})

return
*}

function t_uio_create()
*{
local cUioTbl := "R_UIO.DBF"
local aArr:={}

close all

ferase ( PRIVPATH + "R_UIO.CDX" )

get_uio_fields(@aArr)
// kreiraj tabelu
dbcreate2(PRIVPATH + cUioTbl, aArr)

// kreiraj indexe
CREATE_INDEX("ROB", "idRoba", PRIVPATH +  cUioTbl, .t.)
CREATE_INDEX("TAR", "idTarifa+idRoba", PRIVPATH +  cUioTbl, .t.)

return
*}



// napuni r_uio
function fill_uio( cIdFirma, cIdVd,  cBrDok, lAkciznaRoba, lZasticeneCijene)
*{

// + stavka preknjizenja = pdv
// - stavka = ppp

t_uio_create()


O_R_UIO
set ORDER to TAG "ROB"

SELECT (F_KALK)
if !used()
	O_KALK
endif

SELECT (F_ROBA)
if !used()
	O_ROBA
endif

SELECT (F_TARIFA)
if !used()
	O_TARIFA
endif


SELECT KALK
//"1","idFirma+IdVD+BrDok+RBr
SET ORDER TO TAG "1"

// prvo gledam ppp stavke - negativne stavke 
// u drugom krugu gledam pdv - pozitivne stavke

Box(,3, 60)


nCount := 0

for nKrug:=1 to 2

SEEK cIdFirma + cIdVd + cBrDok
do while !eof() .and. (IdFirma == cIdFirma) .and. (IdVd == cIdVd)  .and. (BrDok == cBrdok)

++nCount


cIdTarifa := idTarifa
cIdRoba := IdRoba

@ m_x+1, m_y+2 SAY "Krug " + STR(nKrug,1) + " " + STR(nCount, 6)
@ m_x+2, m_y+2 SAY cIdRoba + "/" + cIdTarifa
SELECT r_uio
SEEK cIdRoba
if !found()
	APPEND BLANK
	replace idtarifa with cIdTarifa, idRoba with cIdRoba
	SELECT roba
	SEEK cIdRoba
	SELECT tarifa
	SEEK cIdTarifa
	SELECT r_uio
	replace jmj WITH roba->jmj ,;
	        nazivR WITH LEFT(roba->naz,40)
	replace ppp_pstopa WITH (1-1/(1+tarifa->opp/100))*100
endif

// stavka PPP
// 1 krug gledam samo negativne stavke
if (nKrug == 1) .and. (kalk->kolicina < 0)
       replace kol with ABS(kalk->kolicina),;
               cij_ppp with ROUND(kalk->mpcsapp, za_mpc_ppp),;
	       zad_ppp with kalk->mpcsapp * ABS(kalk->kolicina)
       replace ppp_ucj with cij_ppp * (1-1/(1+tarifa->opp/100))
       replace uk_ppp with kol * ppp_ucj
       
endif

// pdv stavka
// 2 krug gledam samo pozitivne stavke
if (nKrug == 2)  .and. (kalk->kolicina > 0)
	replace cij_b_pdv WITH cij_ppp - ppp_ucj
	replace izn_pdv with cij_b_pdv * PDV_STOPA / 100
	replace cij_sa_pdv WITH ROUND(cij_b_pdv * ( 1 + PDV_STOPA / 100 ), za_mpc_pdv)
	replace uk_pdv with kol * izn_pdv
	replace zad_pdv with kol * cij_sa_pdv
	replace razlika with zad_ppp - zad_pdv
endif


SELECT KALK
skip

enddo
// krugovi
next

BoxC()

return
*}


function show_uio(lLandscape, lSvakaHeader, lAkciznaRoba, lZasticenaRoba)
*{

nCurrLine := 0

SELECT (F_R_UIO)

if !used()
	O_R_UIO
endif

SELECT (F_TARIFA)
if !used()
   O_TARIFA
endif

START PRINT CRET
?

P_COND2

if lLandscape
 nPageLimit := 40
  ?? "#%LANDS#"
else
 nPageLimit := 65
endif
nRow := 0

uio_zagl()

SELECT r_uio
SET ORDER TO TAG "TAR"
go top
nRbr := 0

nUk6:=0
nUk9:=0
nUk13:=0
nUk14:=0
nUk15:=0

do while !eof()
  
  cIdTarifa := idTarifa
  
  nT6:=0
  nT9:=0
  nT13:=0
  nT14:=0
  nT15:=0
  
  ++ nCurrLine
  ? "   Tarifni broj: "
  SELECT TARIFA
  seek cIdTarifa
  ?? cIdTarifa
  ?? " "
  ?? " stopa: " 
  ?? ALLTRIM(STR(tarifa->opp, 10)) + "%"
  SELECT r_uio
  
  r_linija()
  do while !eof() .and. (idTarifa == cIdTarifa)
   
   ++nCurrLine
   if nCurrLine > nPageLimit
   	FF
	nCurrLine:=0
	if lSvakaHeader
		uio_zagl()
	endif
		
   endif
   
   nRbr ++
   ?
   cPom := ALLTRIM( STR(nRbr,5) )
   ?? PADL(cPom, aZaglLen[1]) 
   ?? " "
   cPom := ALLTRIM( ALLTRIM(idroba) + "-" + NazivR  )
   ?? PADR( cPom , aZaglLen[2])
   ?? " "
   ?? PADR(jmj, aZaglLen[3])
   ?? " "
   cPom:= ALLTRIM( STR(kol, 10, kol_decimala) )
   ?? PADL(cPom, aZaglLen[4])
   ?? " "
   cPom:= ALLTRIM( STR(cij_ppp, 17, cij_decimala) )
   ?? PADL(cPom, aZaglLen[5])
   ?? " "

   cPom:=ALLTRIM( STR(zad_ppp, 17, izn_decimala) )
   ?? PADL( cPom, aZaglLen[6])
   ?? " "
  
   // preracunata stopa
   cPom:= ALLTRIM( STR(ppp_pstopa, 10, cij_decimala))
   ?? PADL(cPom,  aZaglLen[7])
   ?? " "
   
   cPom:= ALLTRIM( STR(ppp_ucj, 10, cij_decimala))
   ?? PADL(cPom,  aZaglLen[8])
   ?? " "

   cPom:= ALLTRIM( STR(uk_ppp, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[9])
   ?? " "
 
   cPom:= ALLTRIM( STR(cij_b_pdv, 10, cij_decimala))
   ?? PADL(cPom,  aZaglLen[10])
   ?? " "

   cPom:= ALLTRIM( STR(izn_pdv, 10, cij_decimala))
   ?? PADL(cPom,  aZaglLen[11])
   ?? " "
   
   cPom:= ALLTRIM( STR(cij_sa_pdv, 10, cij_decimala))
   ?? PADL(cPom,  aZaglLen[12])
   ?? " "

   cPom:= ALLTRIM( STR(uk_pdv, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[13])
   ?? " "
 
   cPom:= ALLTRIM( STR(zad_pdv, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[14])
   ?? " "

   cPom:= ALLTRIM( STR(razlika, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[15])
   ?? " "


   nT6 += zad_ppp
   nT9 += uk_ppp

   nT13 += uk_pdv
   nT14 += zad_pdv
   nT15 += razlika
   
   SKIP
  enddo

  if (nCurrLine+3) > nPageLimit 
  	FF
	nCurrLine:=0
	if lSvakaHeader
		uio_zagl()
	endif
  endif
  
  r_linija()
   
  // ukupno tarifa

   ?
   ?? PADL("", aZaglLen[1]) 
   ?? " "
   cPom := "Ukupno tarifa " + cIdTarifa + " :"
   ?? PADR( cPom , aZaglLen[2])
   ?? " "
   ?? PADR("", aZaglLen[3])
   ?? " "
   ?? PADR("", aZaglLen[4])
   ?? " "
   cPom:= ""
   ?? PADL(cPom, aZaglLen[5])
   ?? " "
   cPom:=ALLTRIM( STR(nT6, 17, izn_decimala) )
   ?? PADL( cPom, aZaglLen[6])
   ?? " "
  
   // preracunata stopa
   cPom:= ""
   ?? PADL(cPom,  aZaglLen[7])
   ?? " "
   
   cPom:= ""
   ?? PADL(cPom,  aZaglLen[8])
   ?? " "

   cPom:= ALLTRIM( STR(nT9, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[9])
   ?? " "
 
   cPom:= ""
   ?? PADL(cPom,  aZaglLen[10])
   ?? " "

   cPom:= ""
   ?? PADL(cPom,  aZaglLen[11])
   ?? " "
   
   cPom:= ""
   ?? PADL(cPom,  aZaglLen[12])
   ?? " "

   cPom:= ALLTRIM( STR(nT13, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[13])
   ?? " "
 
   cPom:= ALLTRIM( STR(nT14, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[14])
   ?? " "

   cPom:= ALLTRIM( STR(nT15, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[15])
   ?? " "



  // end ukupno tarifa
  
  r_linija()
  
  nUk6 += nT6
  nUk9 += nT9

  nUk13 += nT13 
  nUk14 += nT14
  nUk15 += nT15 

enddo

if (nCurrLine+3) > nPageLimit 
  FF
  nCurrLine:=0
  if lSvakaHeader
	uio_zagl()
  endif
endif

// ukupno sve tarife
?
?? PADL("", aZaglLen[1]) 
?? " "
cPom := "U K U P N O :"
?? PADR( cPom , aZaglLen[2])
?? " "
?? PADR("", aZaglLen[3])
?? " "
?? PADR("", aZaglLen[4])
?? " "
cPom:= ""
?? PADL(cPom, aZaglLen[5])
?? " "
cPom:=ALLTRIM( STR(nUk6, 17, izn_decimala) )
?? PADL( cPom, aZaglLen[6])
?? " "
  
// preracunata stopa
cPom:= ""
?? PADL(cPom,  aZaglLen[7])
?? " "
   
cPom:= ""
?? PADL(cPom,  aZaglLen[8])
?? " "

cPom:= ALLTRIM( STR(nUk9, 15, izn_decimala))
?? PADL(cPom,  aZaglLen[9])
?? " "
 
cPom:= ""
?? PADL(cPom,  aZaglLen[10])
?? " "

cPom:= ""
?? PADL(cPom,  aZaglLen[11])
?? " "
   
cPom:= ""
?? PADL(cPom,  aZaglLen[12])
?? " "

cPom:= ALLTRIM( STR(nUk13, 15, izn_decimala))
?? PADL(cPom,  aZaglLen[13])
?? " "
 
cPom:= ALLTRIM( STR(nUk14, 15, izn_decimala))
?? PADL(cPom,  aZaglLen[14])
?? " "

cPom:= ALLTRIM( STR(nUk15, 15, izn_decimala))
?? PADL(cPom,  aZaglLen[15])
?? " "

// end ukupno sve tarife
  
r_linija()
  

FF
END PRINT
return
*}


static function uio_zagl()

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
