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


// otvori tabele za stampu racuna
function o_dracun()
O_DRN
O_RN
O_DRNTEXT
return


// delete rn dbf's
function del_rndbf()

close all

// drn.dbf
FErase( my_home() + "drn.dbf" )
FErase( my_home() + "drn.cdx" )

// rn.dbf
FErase( my_home() + "rn.dbf" )
FErase( my_home() + "rn.cdx" )

// drntext.dbf
FErase( my_home() + "drntext.dbf" )
FErase( my_home() + "drntext.cdx" )

return 1


function drn_create()

local cDRnName := "drn"
local cRnName := "rn"
local cDRTxtName := "drntext"
local aDRnField:={}
local aRnField:={}
local aDRTxtField:={}

if del_rndbf() == 0
	MsgBeep("Greska: brisanje pomocnih tabela !!!")
	return
endif

if !FILE(f18_ime_dbf(cDRnName))
	// drn specifikacija polja
	get_drn_fields(@aDRnField)
        // kreiraj tabelu
	dbcreate2(cDRnName, aDRnField)
endif

if !FILE(f18_ime_dbf(cRnName))
	// rn specifikacija polja
	get_rn_fields(@aRnField)
        // kreiraj tabelu
	dbcreate2(cRnName, aRnField)
endif

if !FILE(f18_ime_dbf(cDRTxtName))
	// rn specifikacija polja
	get_dtxt_fields(@aDRTxtField)
        // kreiraj tabelu
	dbcreate2(cDRTxtName, aDRTxtField)
endif

// kreiraj indexe
CREATE_INDEX("1", "brdok+DToS(datdok)", "drn")

CREATE_INDEX("1", "brdok+rbr+podbr", "rn")
CREATE_INDEX("IDROBA", "idroba", "rn")

CREATE_INDEX("1", "tip", "drntext")

return


function get_drn_fields(aArr)

AADD(aArr, {"BRDOK",   "C",  12, 0})
AADD(aArr, {"DATDOK",  "D",  8, 0})
AADD(aArr, {"DATVAL",  "D",  8, 0})
AADD(aArr, {"DATISP",  "D",  8, 0})
AADD(aArr, {"VRIJEME", "C",  5, 0})
AADD(aArr, {"ZAOKR",   "N", 10, 5})

// ukupno za stavku
AADD(aArr, {"UKBEZPDV","N", 15, 5})
AADD(aArr, {"UKPOPUST","N", 15, 5})
AADD(aArr, {"UKPOPTP", "N", 15, 5})
AADD(aArr, {"UKBPDVPOP","N",15, 5})
AADD(aArr, {"UKPDV",   "N", 15, 5})
AADD(aArr, {"UKUPNO",  "N", 15, 5})
AADD(aArr, {"UKKOL",   "N", 14, 2})


AADD(aArr, {"CSUMRN",  "N",  6, 0})
if glUgost
  // stopa poreza na potrosnju 1
  AADD(aArr, {"STPP1",  "N",  6, 1})
  // ukupno porez na potrosnju 1
  AADD(aArr, {"UKPP1",  "N", 14, 2})
  // moguce 4 stope poreza na potrosnju
  AADD(aArr, {"STPP2",  "N",  6, 1})
  AADD(aArr, {"UKPP2",  "N", 14, 2})
  AADD(aArr, {"STPP3",  "N",  6, 1})
  AADD(aArr, {"UKPP3",  "N", 14, 2})
  AADD(aArr, {"STPP4",  "N",  6, 1})
  AADD(aArr, {"UKPP4",  "N", 14, 2})
  AADD(aArr, {"STPP5",  "N",  6, 1})
  AADD(aArr, {"UKPP5",  "N", 14, 2})
endif

return


function get_rn_fields(aArr)

AADD(aArr, {"BRDOK",   "C",  12, 0})
AADD(aArr, {"RBR",     "C",  3, 0})
AADD(aArr, {"PODBR",   "C",  2, 0})
AADD(aArr, {"IDROBA",  "C", 10, 0})
AADD(aArr, {"ROBANAZ", "C", 200, 0})
AADD(aArr, {"JMJ",     "C",  3, 0})
AADD(aArr, {"KOLICINA","N", 15, 5})
AADD(aArr, {"CJENPDV", "N", 15, 5})
AADD(aArr, {"CJENBPDV", "N", 15, 5})
AADD(aArr, {"CJEN2PDV", "N", 15, 5})
AADD(aArr, {"CJEN2BPDV", "N", 15, 5})
AADD(aArr, {"POPUST",   "N", 8, 3})
AADD(aArr, {"PPDV",     "N", 8, 3})
AADD(aArr, {"VPDV",     "N", 15, 5})
AADD(aArr, {"UKUPNO",    "N", 15, 5})
AADD(aArr, {"POPTP",   "N", 8, 3})
AADD(aArr, {"VPOPTP",   "N", 15, 5})
AADD(aArr, {"C1",   "C", 100, 0})
AADD(aArr, {"C2",   "C", 100, 0})
AADD(aArr, {"C3",   "C", 100, 0})
AADD(aArr, {"OPIS",   "C", 200, 0})

return



function get_dtxt_fields(aArr)
AADD(aArr, {"TIP",   "C",   3, 0})
AADD(aArr, {"OPIS",  "C", 200, 0})
return


function add_drntext(cTip, cOpis)
local lFound
if !USED(F_DRNTEXT)
	O_DRNTEXT
	SET ORDER TO TAG "ID"
endif

select drntext
GO TOP


SEEK cTip

if !FOUND()
  append blank
endif

replace tip with cTip
replace opis with cOpis

return


// dodaj u drn.dbf
function add_drn(cBrDok, dDatDok, dDatVal, dDatIsp, cTime, nUBPDV, nUPopust, nUBPDVPopust, nUPDV, nUkupno, nCSum, nUPopTp, nZaokr, nUkkol)
local cnt1

if !USED(F_DRN)
	O_DRN
endif

select drn
append blank

replace brdok with cBrDok
replace datdok with dDatDok
if (dDatVal <> nil)
	replace datval with dDatVal
endif
if (dDatIsp <> nil)
	replace datisp with dDatIsp
endif
replace vrijeme with cTime
replace ukbezpdv with nUBPDV
replace ukpopust with nUPopust
replace ukbpdvpop with nUBPDVPopust
replace ukpdv with nUPDV
replace ukupno with nUkupno
replace csumrn with nCSum
replace zaokr with nZaokr
replace ukkol with nUkKol

if fieldpos("UKPOPTP") <> 0
	// popust na teret prodavca
	replace ukpoptp with nUPopTp
endif

if glUgost

 // poseban porez na potrosnju
 if (aPP <> nil) 
     // primjer matrice za 3 stope poreza 5%, 7%, 10%
     //
     // aPP := { { 5, 7, 10}  , { 333.22, 15.19, 200.3 } }
    for cnt1 := 1 to LEN(aPP[1])
        
        if cnt1 == 1 
           replace stpp1 with aPP[1,1] ,;
               ukpp1 with aPP[2,1]
	endif
	if cnt1 == 2
           replace stpp2 with aPP[1,2] ,;
               ukpp2 with aPP[2,2]
	endif
        if cnt1 == 3 
            replace stpp3 with aPP[1,3] ,;
               ukpp3 with aPP[2,3]
	endif
        if cnt1 == 4
           replace stpp4 with aPP[1,4] ,;
               ukpp4 with aPP[2,4]
	endif
	if cnt1 == 5
           replace stpp5 with aPP[1,5] ,;
               ukpp5 with aPP[2,5]
	endif

    next

 endif

endif

return

function add_drn_di(dDatIsp)

if !USED(F_DRN)
	O_DRN
endif


SELECT DRN
if EMPTY(brdok)
	APPEND BLANK
endif

if FIELDPOS("datisp")<>0
	replace datisp with dDatIsp
else
	MsgBeep("DATISP ne postoji u drn.dbf (add_drn_di) #Izvrsiti modstru " + goModul:oDatabase:cName + ".CHS !")
endif

return


// get datum isporuka
function get_drn_di()
local xRet

PushWa()

if !USED(F_DRN)
	O_DRN
endif

SELECT drn
if EMPTY(drn->BrDok)
	xRet:=nil
else

	if FIELDPOS("datisp")<>0
		if EMPTY(datisp)
			xRet := datdok
		else
			xRet := datisp
		endif
	else
		MsgBeep("DATISP ne postoji u drn.dbf (get_drn_di)#Izvrsiti modstru " + ;
			goModul:oDataBase:cName + ".CHS !")
		xRet := nil
	endif
endif

PopWa()
return xRet



// ---------------------------------
// dodaj u rn.dbf
// ---------------------------------
function add_rn(cBrDok, cRbr, cPodBr, cIdRoba, cRobaNaz, cJmj, nKol, nCjenPdv, nCjenBPdv, nCjen2Pdv, nCjen2BPdv, nPopust, nPPdv, nVPdv, nUkupno, nPopNaTeretProdavca, nVPopNaTeretProdavca, cC1, cC2, cC3, cOpis)

O_RN

if cC1 == nil
	cC1 := ""
endif
if cC2 == nil
	cC2 := ""
endif
if cC3 == nil
	cC3 := ""
endif
if cOpis == nil
	cOpis := ""
endif

select rn
append blank

replace brdok with cBrDok
replace rbr with cRbr
replace podbr with cPodBr
replace idroba with cIdRoba
replace robanaz with cRobaNaz
replace jmj with cJmj
replace c1 with cC1
replace c2 with cC2
replace c3 with cC3
replace opis with cOpis
replace kolicina with nKol
replace cjenpdv with nCjenPdv
replace cjenbpdv with nCjenBPdv
replace cjen2pdv with nCjen2Pdv
replace cjen2bpdv with nCjen2BPdv
replace popust with nPopust
replace ppdv with nPPdv
replace vpdv with nVPdv
replace ukupno with nUkupno 

if ( ROUND(nPopNaTeretProdavca, 4) <> 0 )
	// popust na teret prodavca
	if FIELDPOS("poptp") <> 0
		replace poptp with nPopNaTeretProdavca
  		replace vpoptp with nVPopNaTeretProdavca
	else
  		MsgBeep("Tabela RN ne sadrzi POPTP - popust na teret prodavca")
	endif
endif

return


// isprazni drn tabele
function drn_empty()
O_DRN
select drn
zapp()

O_RN
select rn
zapp()

O_DRNTEXT
select drntext
zapp()

return


// otvori rn tabele
function drn_open()
O_DRN
O_DRNTEXT
O_RN
return


// provjera checksum-a
function drn_csum()
local nCSum
local nRNSum

// uzmi csumrn iz DRN
select drn
go top
nCSum := field->csumrn

// uzmi broj zapisa iz RN
select rn
nRNSum := RecCount2()

if nRNSum == nCSum
	return .t.
endif

return .f.


// vrati vrijednost polja opis iz tabele drntext.dbf po id kljucu
function get_dtxt_opis(cTip)
local cRet

O_DRNTEXT
select drntext
set order to tag "1"
hseek cTip

if !Found()
	return "-"
endif
cRet := RTRIM(opis)

return cRet

// ---------------------------------------------
// azuriranje podataka o kupcu
// ---------------------------------------------
function AzurKupData(cIdPos)
local cKNaziv
local cKAdres
local cKIdBroj
local _rec
local _ok
local _tbl := "pos_dokspf"

O_DRN
O_DRNTEXT

cKNaziv := get_dtxt_opis("K01")
cKAdres := get_dtxt_opis("K02")
cKIdBroj := get_dtxt_opis("K03")
dDatIsp := get_drn_di()

// nema poreske fakture
if cKNaziv == "???"
	return
endif

O_DOKSPF

if !f18_lock_tables({_tbl})
    MsgBeep("Ne mogu lock-ovati dokspf tabelu !!!")
endif

sql_table_update( nil, "BEGIN" )

select drn
go top

select dokspf
SEEK cIdPos + "42" + DTOS(drn->datdok) + drn->brdok

if !FOUND()
    append blank
endif

_rec := dbf_get_rec()
_rec["idpos"] := cIdPos
_rec["idvd"] := "42"
_rec["brdok"] := drn->brdok
_rec["datum"] := drn->datdok

if hb_hhaskey( _rec, "datisp" )
	if dDatIsp <> nil
        _rec["datisp"] := dDatIsp
	endif
endif

_rec["knaz"] := cKNaziv
_rec["kadr"] := cKAdres
_rec["kidbr"] := cKIdBroj

update_rec_server_and_dbf( _tbl, _rec, 1, "CONT" )

f18_free_tables({_tbl})
sql_table_update( nil, "END" )

return

// pretrazi tabelu kupaca i napuni matricu
function fnd_kup_data(cKupac)
local aRet:={}
local nArr
local cFilter:=""
local cPartData
local cTmp

if RIGHT(ALLTRIM(cKupac), 2) <> ".."
	return aRet
endif

// prvo ukini tacku sa kupca
cKupac := STRTRAN(ALLTRIM(cKupac), "..", ";")

nArr := SELECT()

O_DOKSPF
select dokspf

cFilter := Parsiraj(LOWER(cKupac), "lower(knaz)")

set filter to &cFilter
set order to tag "2"
go top

cTmp := "XXX"

if !EOF()
	do while !EOF()
		
		cPartData := field->knaz + field->kadr + field->kidbr
		
		if cPartData == cTmp
			skip
			loop
		endif
		
		AADD(aRet, {field->knaz, field->kadr, field->kidbr})
		
		cTmp := cPartData
		
		skip
	enddo
endif

set filter to

select (nArr)

return aRet



