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
#include "f18_rabat.ch"

/*! \fn CreRabDB()
 *  \brief Kreira tabelu rabat u SIFPATH
 */
 
function CreRabDB()
*{
// RABAT.DBF
aDbf:={}
AADD(aDbf,{"IDRABAT"      , "C", 10, 0})
AADD(aDbf,{"TIPRABAT"     , "C", 10, 0})
AADD(aDbf,{"DATUM"        , "D",  8, 0})
AADD(aDbf,{"DANA"         , "N",  5, 0})
AADD(aDbf,{"IDROBA"       , "C", 10, 0})
AADD(aDbf,{"IZNOS1"       , "N",  8, 2})
AADD(aDbf,{"IZNOS2"       , "N",  8, 2})
AADD(aDbf,{"IZNOS3"       , "N",  8, 2})
AADD(aDbf,{"IZNOS4"       , "N",  8, 2})
AADD(aDbf,{"IZNOS5"       , "N",  8, 2})
AADD(aDbf,{"SKONTO"       , "N",  8, 2})

if !File(f18_ime_dbf("rabat"))
	DbCreate2(SIFPATH + "rabat.dbf", aDbf)
endif

CREATE_INDEX("1", "IDRABAT+TIPRABAT+IDROBA", SIFPATH + "rabat.dbf", .t.)
CREATE_INDEX("2", "IDRABAT+TIPRABAT+DTOS(DATUM)", SIFPATH + "rabat.dbf", .t.)

return
*}


/*! \fn GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIznos)
 *  \brief Vraca iznos rabata za dati artikal
 *  \param cIdRab - id rabat
 *  \param nTekIznos - tekuce polje iznosa
 *  \param cTipRab - tip rabata
 *  \param cIdRoba - id roba
 *  \return nRet - vrijednost rabata
 */
function GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIznos)
*{
local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)

O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab + cIdRoba

// vrati iznos rabata za tekucu vriijednost polja IZNOSn
nRet:=GetRabIznos(nTekIznos)

select (nArr)

return nRet
*}


/*! \fn GetDaysForRabat(cIdRab, cTipRab)
 *  \brief Vraca broj dana (rok placanja) za odredjeni tip rabata
 *  \param cIdRab - id rabat
 *  \param cTipRab - tip rabata
 *  \return nRet - vrijednost dana
 */
function GetDaysForRabat(cIdRab, cTipRab)
*{
local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)

O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab
nRet:=field->dana
select (nArr)

return nRet
*}


/*! \fn GetRabIznos(cTekIzn)
 *  \brief Vraca iznos rabata za zadati cTekIznos (vrijednost polja)
 *  \param cTekIzn - tekuce polje koje se uzima
 */
function GetRabIznos(cTekIzn)
*{
if (cTekIzn == nil)
	cTekIzn := "1"
endif

// primjer: "iznos" + cTekIzn
//           iznos1 ili iznos3
cField := "iznos" + ALLTRIM(cTekIzn)
// izvrsi macro evaluaciju
nRet := field->&cField
return nRet
*}


/*! \fn GetSkontoArticle(cIdRab, cTipRab, cIdRoba)
 *  \brief Vraca iznos skonto za dati artikal
 *  \param cIdRab - id rabat
 *  \param cTipRab - tip rabata
 *  \param cIdRoba - id roba
 *  \return nRet - vrijednost skonto
 */
function GetSkontoArticle(cIdRab, cTipRab, cIdRoba)
*{
local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)
O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab + cIdRoba
nRet:=field->skonto
select (nArr)

return nRet
*}


// ------------------------------------
// dodaj match_code u browse
// ------------------------------------
function add_mcode(aKolona)
if fieldpos("MATCH_CODE") <> 0
	AADD(aKolona, { PADC("MATCH CODE",10), {|| match_code}, "match_code" })
endif
return


// --------------------------------------------------
// sifrarnik uredjaja za fiskalizaciju
// --------------------------------------------------
function P_FDevice(cId,dx,dy)
local nTArea
private ImeKol
private Kol

if gFc_use == "N"
	return .t.
endif

ImeKol := {}
Kol := {}

nTArea := SELECT()


O_FDEVICE

AADD(ImeKol, { PADC("id",3), {|| id}, "id", {|| .t. }, {|| .t. } })
AADD(ImeKol, { PADC("tip",10), {|| tip}, "tip" })
AADD(ImeKol, { PADC("oznaka",10), {|| oznaka}, "oznaka" })
AADD(ImeKol, { PADC("iosa",16), {|| iosa}, "iosa" })
AADD(ImeKol, { PADC("serial",16), {|| serial}, "serial" })
AADD(ImeKol, { PADC("pdv korisn.",16), {|| pdv}, "pdv" })
AADD(ImeKol, { PADC("vrsta",5), {|| vrsta}, "vrsta" })
AADD(ImeKol, { PADC("path",20), {|| path}, "path" })
AADD(ImeKol, { PADC("path2",20), {|| path2}, "path2" })
AADD(ImeKol, { PADC("output",10), {|| output}, "output" })
AADD(ImeKol, { PADC("odgovor",10), {|| answer}, "answer" })
AADD(ImeKol, { PADC("duz.roba",8), {|| duz_roba}, "duz_roba" })
AADD(ImeKol, { PADC("prov.greske",10), {|| error}, "error" })
AADD(ImeKol, { PADC("timeout",7), {|| timeout}, "timeout" })
AADD(ImeKol, { PADC("zbirni rn.",10), {|| zbirni}, "zbirni" })
AADD(ImeKol, { PADC("pitanje st.",10), {|| st_pitanje}, "st_pitanje" })
AADD(ImeKol, { PADC("st_brrb",10), {|| st_brrb}, "st_brrb" })
AADD(ImeKol, { PADC("stampa rac.",10), {|| st_rac}, "st_rac" })
AADD(ImeKol, { PADC("provjera",10), {|| check}, "check" })
AADD(ImeKol, { PADC("vr.sifre",11), {|| art_code}, "art_code" })
AADD(ImeKol, { PADC("init plu",10), {|| init_plu}, "init_plu" })
AADD(ImeKol, { PADC("auto polog",10), {|| auto_p}, "auto_p" })
AADD(ImeKol, { PADC("opis",30), {|| opis}, "opis" })
AADD(ImeKol, { PADC("dokument",10), {|| dokumenti}, "dokumenti" })
AADD(ImeKol, { PADC("aktivan",10), {|| aktivan}, "aktivan" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_FDEVICE,1,10,65,"Lista fiskalnih uredjaja",@cId,dx,dy)
