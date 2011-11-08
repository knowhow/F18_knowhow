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

static cij_decimala:=3
static izn_decimala:=2
static kol_decimala:=3
static lZaokruziti := .t.
static PDV_STOPA:=17

static cLauncher1 := 'start "C:\Program Files\OpenOffice.org 2.0\program\scalc.exe"'
// zamjeniti tarabu sa brojem
static cLauncher2 := ""

static cLauncher := "officexp"

// 4 : 852 => US ASCII
static cKonverzija := "4"

// tekuca linija reporta
static nCurrLine:=0


function krpt_export()

local lAkciznaRoba := .f.
local lZasticeneCijene := .f.

cIdFirma := gFirma
cBrDok := PADR("00000", 8)
cIdVd := "80"
cLauncher := PADR(cLauncher, 70)
cZaokruziti := "D"

Box(, 14, 70)

  @ m_x+1, m_y+2 SAY "Dokument "
  @ m_x+2, m_y+2 SAY gFirma + " - " GET  cIdVd
  @ m_x+2, col()+2 SAY " - " GET cBrDok 
  
  
  @ m_x+4, m_y+2 SAY PADR("-", 30, "-")
  @ m_x+5, m_y+2 SAY "Izvrsiti zaokruzenja ? " GET cZaokruziti PICT "@!" VALID cZaokruziti $ "DN"
  READ

  lZaokruziti := (cZaokruziti == "D")

  if lZaokruziti
    @ m_x+5, m_y+2 SAY PADR(" ", 57)
    @ m_x+5, m_y+2 SAY "Broj decimala cijena " GET cij_decimala PICT "9"
    @ m_x+6, m_y+2 SAY "               iznos " GET izn_decimala PICT "9"
    @ m_x+7, m_y+2 SAY "            kolicina " GET kol_decimala PICT "9"
    READ
  endif
  
  if cIdVd $ "IP#11#12#13#19#80#41#42"
  	cMpcCij := "D"
	cVpcCij := "N"
  else
  	cMpcCij := "N"
	cVpcCij := "D"
  endif
  
  @ m_x+8, m_y+2 SAY PADR("-", 30, "-")
  @ m_x+9, m_y+2 SAY "Trebate mpc cijene ? " GET cMpcCij PICT "@!" VALID cMpcCij $ "DN"
  @ m_x+10, m_y+2 SAY "Trebate vpc cijene ? " GET cVpcCij PICT "@!" VALID cVpcCij $ "DN"
  
  @ m_x+11, m_y+2 SAY PADR("-", 30, "-")
  @ m_x+12, m_y+2 SAY "Konverzija slova (0-8) " GET cKonverzija PICT "9"
  @ m_x+13, m_y+2 SAY "Pokreni oo/office97/officexp/office2003 ?" GET cLauncher PICT "@S26" VALID set_launcher(@cLauncher)
  
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

fill_exp(cIdFirma, cIdVd, cBrDok, (cVpcCij == "D") , (cMpcCij == "D") )

close all
*}


static function set_launcher(cLauncher)
local cPom

cPom = UPPER(ALLTRIM(cLauncher))


if (cPom == "OO") .or.  (cPom == "OOO") .or.  (cPom == "OPENOFFICE")
	cLauncher := cLauncher1
	return .f.
	
elseif (LEFT(cPom,6) == "OFFICE" )
        // OFFICEXP, OFFICE97, OFFICE2003
	cLauncher := msoff_start(SUBSTR(cPom, 7))
	return .f.
elseif (LEFT(cPom,5) == "EXCEL") 
        // EXCELXP, EXCEL97 
	cLauncher := msoff_start(SUBSTR(cPom, 6))
	return .f.
endif

return .t.

/*! \fn get_uio_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
static function get_exp_fields(aArr, cIdVd, lVpcCij, lMpcCij)
*{


if lZaokruziti
   nCijDec := cij_decimala
   nKolDec := kol_decimala
   nIznDec := izn_decimala
else
   nCijDec := 4
   nKolDec := 4
   nIznDec := 3
endif

AADD(aArr, {"rbr",   "N",  5, 0})
AADD(aArr, {"id_roba",   "C",  10, 0})
AADD(aArr, {"naziv_roba",   "C",  40, 0})

AADD(aArr, {"jmj",  "C",  3, 0})

AADD(aArr, {"id_tarifa",   "C",  6, 0})

// stopa
AADD(aArr, {"st_tarifa",   "N",  10, 4})

// preracunata stopa
AADD(aArr, {"pst_tarifa",   "N",  10, 4})


AADD(aArr, {"kol",  "N",  15, nKolDec})

if (cIdVD == "IP") .or. (cIdVD == "IM")
  AADD(aArr, {"kol_knjiz",  "N",  15, nKolDec})
endif

if lVpcCij
	AADD(aArr, {"cij_vpc_d",  "N",  10, nCijDec})
	AADD(aArr, {"cij_vpc_1",  "N",  10, nCijDec})
	AADD(aArr, {"cij_vpc_2",  "N",  10, nCijDec})
endif


if lMpcCij
	AADD(aArr, {"cij_mpc_d",  "N",  10, nCijDec})
	AADD(aArr, {"cij_mpc_1",  "N",  10, nCijDec})
	AADD(aArr, {"cij_mpc_2",  "N",  10, nCijDec})
endif


AADD(aArr, {"cij_nab_d",  "N",  10, nCijDec})
AADD(aArr, {"cij_nab",  "N",  10, nCijDec})

AADD(aArr, {"cij_nov_1",  "N",  10, nCijDec})
AADD(aArr, {"cij_nov_2",  "N",  10, nCijDec})


return
*}


function kt_exp_create(cIdVd, lVpcCij, lMpcCij)
*{
local cExpTbl := "R_EXPORT.DBF"
local aArr:={}

close all

//ferase ( PRIVPATH + "R_EXPORT.CDX" )

get_exp_fields(@aArr, cIdVd, lVpcCij, lMpcCij)
// kreiraj tabelu
dbcreate2(PRIVPATH + cExpTbl, aArr)

// kreiraj indexe
//CREATE_INDEX("ROB", "idRoba", PRIVPATH +  cExpTbl, .t.)
//CREATE_INDEX("TAR", "idTarifa+idRoba", PRIVPATH +  cExpTbl, .t.)

return
*}



// napuni r_uio
static function fill_exp( cIdFirma, cIdVd,  cBrDok, lVpcCij, lMpcCij )
*{
local cPom1
local cPom2
local cKomShow

private cKom

// + stavka preknjizenja = pdv
// - stavka = ppp

kt_exp_create(cIdVd, lVpcCij, lMpcCij)

O_R_EXP
//set ORDER to TAG "ROB"

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

// redni broj  u export tabeli
nRbr := 0

for nKrug:=1 to 1

SEEK cIdFirma + cIdVd + cBrDok
do while !eof() .and. (IdFirma == cIdFirma) .and. (IdVd == cIdVd)  .and. (BrDok == cBrdok)

++nCount


cIdTarifa := idTarifa
cIdRoba := IdRoba

@ m_x+1, m_y+2 SAY "Krug " + STR(nKrug,1) + " " + STR(nCount, 6)
@ m_x+2, m_y+2 SAY cIdRoba + "/" + cIdTarifa
SELECT r_export

//SEEK cIdRoba
//if !found()

	++nRbr
	APPEND BLANK
	replace rbr WITH nRbr, id_tarifa with cIdTarifa, id_roba with cIdRoba

	SELECT roba
	SEEK cIdRoba
	
	SELECT tarifa
	SEEK cIdTarifa

	cPom1 := KonvznWin(LEFT(roba->naz,40), cKonverzija)
	cPom2 := KonvznWin(roba->jmj, cKonverzija)
	
	SELECT r_export
	replace jmj WITH cPom2, ;
	        naziv_roba WITH cPom1 ,;
	        pst_tarifa WITH (1-1/(1+tarifa->opp/100))*100, ;
	        st_tarifa WITH tarifa->opp

	replace cij_nab_d WITH kalk->nc ,;
		cij_nab WITH roba->nc 

	if lMpcCij
		replace cij_mpc_d WITH kalk->mpcsapp, ;
			cij_mpc_1 WITH roba->mpc, ;
		        cij_mpc_2 WITH roba->mpc2 
	endif

	if lVpcCij
		replace cij_vpc_d WITH kalk->vpc, ;
			cij_vpc_1 WITH roba->vpc, ;
			cij_vpc_2 WITH roba->vpc2
	endif

	if roba->(FIELDPOS("zanivel")<>0)
           replace cij_nov_1 WITH roba->zanivel ,;
	        cij_nov_2 WITH roba->zaniv2
	endif
	
	replace kol WITH kalk->kolicina
	
	if (cIdVD == "IP") .or. (cIdVd == "IM")
		replace kol_knjiz WITH kalk->gkolicina
	endif

SELECT KALK
skip

enddo
// krugovi
next

BoxC()

close all

cLauncher := ALLTRIM(cLauncher)
if (cLauncher == "start")
   cKom := cLauncher + " " + PRIVPATH
else
   cKom := cLauncher + " " + PRIVPATH + "r_export.dbf"
endif

MsgBeep("Tabela " + PRIVPATH + "R_EXPORT.DBF je formirana, i ima:"+ STR(nRbr, 5) + "stavki##" +;
        "Sa opcijom Open file se ova tabela ubacuje u excel #" +;
	"Nakon importa uradite Save as, i odaberite format fajla XLS ! ##" +;
	"Tako dobijeni xls fajl mozete mijenjati #"+;
	"prema svojim potrebama ...")
	
if Pitanje(, "Odmah pokrenuti spreadsheet aplikaciju ?", "D") == "D"	
 RUN &cKom
endif

return
*}


static function msoff_start(cVersion)

local cPom :=  'start "C:\Program Files\Microsoft Office\Office#\excel.exe"'

if (cVersion == "XP")
  // office XP
  return STRTRAN(cPom,  "#", "10")
elseif (cVersion == "2000")
  // office 2000
  return STRTRAN(cPom, "#", "9")
elseif (cVersion == "2003")
  // office 2003
  return STRTRAN(cPom, "#", "11")
elseif (cVersion == "97")
  // office 97
  return STRTRAN(cPom, "#", "8")
else
  // office najnoviji 2005?2006
  return STRTRAN(cPom, "#", "12")
endif

