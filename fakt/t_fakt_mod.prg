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

#include "fakt.ch"
#include "hbclass.ch"



// -----------------------------------------------
// -----------------------------------------------
CLASS TFaktMod FROM TAppMod
	var nDuzinaSifre 
	var cTekVpc
	var lOpcine
	var lDoks2
	var lId_J
	var lCRoba
	var cRoba_Rj
	var lOpresaStampa
	method New
	method setGVars
	method mMenu
	method mMenuStandard
	method initdb
	method srv
END CLASS



// -----------------------------------------------
// -----------------------------------------------
method new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
::super:new(p1, p2, p3, p4, p5, p6, p7, p8, p9)
return self


// -----------------------------------------------
// -----------------------------------------------
method initdb()
::oDatabase:=TDbFakt():new()
return nil


// -----------------------------------------------
// -----------------------------------------------
method mMenu()

private Izbor

SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

CheckROnly(KUMPATH + "\FAKT.DBF")

// setuj parametre pri pokretanju modula
fakt_set_params()

@ 1,2 SAY padc( gTS + ": "+ gNFirma, 50, "*" )

::mMenuStandard()

return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenuStandard

local _opc    :={}
local _opcexe :={}
local _izbor  := 1

AADD(_opc,"1. unos/ispravka dokumenta             ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","UNOSDOK"))
	AADD(_opcexe,{|| fakt_unos_dokumenta()})
else
	AADD(_opcexe,{|| MsgBeep(cZabrana)})
endif

AADD(_opc,"2. izvjestaji")
AADD(_opcexe,{|| fakt_izvjestaji()})
AADD(_opc,"3. pregled dokumenata")
AADD(_opcexe,{|| fakt_pregled_dokumenata()})

AADD(_opc,"4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK"))
	AADD(_opcexe,{|| fakt_mnu_generacija_dokumenta()})
else
	AADD(_opcexe,{|| MsgBeep(cZabrana)})
endif

AADD(_opc,"5. moduli - razmjena podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","MODULIRAZMJENA"))
	AADD(_opcexe,{|| fakt_razmjena_podataka()})
else
	AADD(_opcexe,{|| MsgBeep(cZabrana)})
endif

AADD(_opc,"6. udaljene lokacije - razmjena")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","UDLOKRAZMJENA"))
	AADD(_opcexe,{|| faktprenosdiskete()})
else
	AADD(_opcexe,{|| MsgBeep(cZabrana)})
endif

AADD(_opc,"7. ostale operacije nad dokumentima")
AADD(_opcexe,{|| fakt_ostale_operacije_doks()})
AADD(_opc,"------------------------------------")
AADD(_opcexe,{|| nil})
AADD(_opc,"8. sifrarnici")
AADD(_opcexe,{|| fakt_sifrarnik()})

AADD(_opc,"9. uplate")
AADD(_opcexe, {|| mnu_fakt_uplate()} )

AADD(_opc,"------------------------------------")
AADD(_opcexe,{|| nil})
AADD(_opc,"A. stampa azuriranog dokumenta")
AADD(_opcexe,{|| fakt_stampa_azuriranog()})
AADD(_opc,"P. povrat dokumenta u pripremu")

if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
	AADD(_opcexe,{|| Povrat_fakt_dokumenta()})
else
	AADD(_opcexe,{|| MsgBeep(cZabrana)})
endif

AADD(_opc,"------------------------------------")
AADD(_opcexe,{|| nil})

AADD(_opc,"X. parametri")
if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","PARAMETRI"))
	AADD(_opcexe,{|| mnu_fakt_params()})
else
	AADD(_opcexe,{|| MsgBeep(cZabrana)})
endif

f18_menu("fmai", .t., _izbor, _opc, _opcexe)

return .f.



// -----------------------------------------------
// -----------------------------------------------
method srv()
? "Pokrecem FAKT aplikacijski server"
if (MPar37("/KONVERT", goModul))
	if LEFT(self:cP5,3)=="/S="
		cKonvSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cKonvSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cKonvSez)
		endif
	endif
	goModul:oDataBase:KonvZN()
	goModul:quit(.f.)
endif

return


// -----------------------------------------------
// -----------------------------------------------
method setGVars()
local cSekcija
local cVar
local cVal

set_global_vars()
set_roba_global_vars()

::nDuzinaSifre:=VAL(IzFMKINI('SifRoba','DuzSifra','10', SIFPATH))
::cTekVpc:=IzFmkIni("FAKT","TekVpc","1",SIFPATH)
public gFiltNov:=""
public gVarNum:="1"
public gProtu13:="N"

public gFPzag:=0
public gZnPrec:="="
public gNW:="D"  // new vawe
public gNovine:="N"        // novine/stampa u asortimanu
public gnDS:=5             // duzina sifre artikla - sinteticki
public gFaktFakt:="N"
public gBaznaV:="D"
public Kurslis:="1"
public PicCdem:="99999999.99"
public Picdem:="99999999.99"
public Pickol:="9999999.999"
public gnLMarg:=6  // lijeva margina teksta
public gnLMargA5:=6  // lijeva margina teksta
public gnTMarg:=11 // gornja margina
public gnTMarg2:=3 // vertik.pomj. stavki u fakturi var.9
public gnTMarg3:=0 // vertik.pomj. totala fakture var.9
public gnTMarg4:=0 // vertik.pomj. za donji dio fakture var.9
public gMjStr:="Zenica"
public gMjRJ:="N"
public gDK1:="N"
public gDK2:="N"
public gIspPart:="N" // ispravka partnera u unosu novog dokumenta
public gResetRoba:="D" // resetuj uvijek artikal, pri unosu stavki dokumenta 

public g10Str:=HB_UTF8TOSTR("RAČUN/OTPREMNICA br.")
public g10Str2T:="              Predao                  Odobrio                  Preuzeo"
public g10Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g16Str:=HB_UTF8TOSTR("KONSIGNAC.RAČUN br.")
public g16Str2T:="              Predao                  Odobrio                  Preuzeo"
public g16Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g06Str:= HB_UTF8TOSTR("ZADUŽ.KONS.SKLAD.br.")
public g06Str2T:="              Predao                  Odobrio                  Preuzeo"
public g06Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g20Str:=HB_UTF8TOSTR("PREDRAČUN br.")
public g20Str2T:="                                                               Direktor"
public g20Str2R:="\tab \tab \tab Direktor:"

public g11Str:=HB_UTF8TOSTR("RAČUN MP br.")
public g11Str2T:="              Predao                  Odobrio                  Preuzeo"
public g11Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g15Str:=HB_UTF8TOSTR("RAČUN br.")
public g15Str2T:="              Predao                  Odobrio                  Preuzeo"
public g15Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g12Str:=HB_UTF8TOSTR("OTPREMNICA br.")
public g12Str2T:="              Predao                  Odobrio                  Preuzeo"
public g12Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g13Str:="OTPREMNICA U MP br."
public g13Str2T:="              Predao                  Odobrio                  Preuzeo"
public g13Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g21Str:="REVERS br."
public g21Str2T:="              Predao                  Odobrio                  Preuzeo"
public g21Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g22Str:="ZAKLJ.OTPREMNICA br."
public g22Str2T:="              Predao                  Odobrio                  Preuzeo"
public g22Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g23Str:="ZAKLJ.OTPR.MP    br."
public g23Str2T:="              Predao                  Odobrio                  Preuzeo"
public g23Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g25Str:=HB_UTF8TOSTR("KNJIŽNA OBAVIJEST br.")
public g25Str2T:="              Predao                  Odobrio                  Preuzeo"
public g25Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g26Str:=HB_UTF8TOSTR("NARUDŽBA SA IZJAVOM br.")
public g26Str2T:="                                      Potpis:"
public g26Str2R:="\tab \tab Potpis:"

public g27Str:=HB_UTF8TOSTR("PREDRAČUN MP br.")
public g27Str2T:="                                                               Direktor"
public g27Str2R:="\tab \tab \tab Direktor:"
public gNazPotStr:=SPACE(69)
// lista kod dodatnog teksta
public g10ftxt := PADR("", 100)
public g11ftxt := PADR("", 100)
public g12ftxt := PADR("", 100)
public g13ftxt := PADR("", 100)
public g15ftxt := PADR("", 100)
public g16ftxt := PADR("", 100)
public g20ftxt := PADR("", 100)
public g21ftxt := PADR("", 100)
public g22ftxt := PADR("", 100)
public g23ftxt := PADR("", 100)
public g25ftxt := PADR("", 100)
public g26ftxt := PADR("", 100)
public g27ftxt := PADR("", 100)

public gDodPar:="2"
public gDatVal:="N"

// artikal sort - cdx
public gArtCDX := SPACE(20)
public gEmailInfo := "N"

public gTipF:="2"
public gVarF:="2"
public gVarRF:=" "
public gKriz:=0
public gKrizA5:=2
public gERedova:=9 // extra redova
public gVlZagl:=space(12)   // naziv fajla vlastitog zaglavlja
public gPratiK:="N"
public gPratiC:="N"
public gFZaok:=2
public gImeF:="N"
public gKomlin:=""
public gNumDio:=5
public gDetPromRj:="N"
public gVarC:=" "
public gMP:="1"
public gTabela:=1
public gZagl:="2"
public gBold:="2"
public gRekTar:="N"
public gHLinija:="N"
public gRabProc:="D"

// default MP cijena za 13-ku
public g13dcij:="1"
public gVar13:="1"
public gFormatA5:="0"
public gMreznoNum:="N"
public gIMenu:="3"
public gOdvT2:=0
public gV12Por:="N"

public gVFU:="1"
public gModemVeza:="N"
public gFPZagA5:=0
public gnTMarg2A5:=3
public gnTMarg3A5:=-4
public gnTMarg4A5:=0
public gVFRP0:="N"

public gFNar:=PADR("NAR.TXT",12)
public gFUgRab:=PADR("UGRAB.TXT",12)

public gSamokol:="N"
public gRokPl:=0
public gRabIzRobe := "N"

public gKarC1:="N"
public gKarC2:="N"
public gKarC3:="N"
public gKarN1:="N"
public gKarN2:="N"
public gPSamoKol:="N"
public gcRabDef := SPACE(10)
public gcRabIDef := "1"
public gcRabDok := SPACE(30)

public gShSld := "N"
public gFinKtoDug := PADR("2120", 7)
public gFinKtoPot := PADR("5430", 7)
public gShSldVar := 1
// roba group na fakturi
public glRGrPrn := "N"
// brisanje dokumenta -> ide u smece
public gcF9USmece := "N"
// time-out kod azuriranja
public gAzurTimeOut := 150

// parametri fiskalnog uredjaja
public gFc_type, gFc_device, gFc_use, gFc_path, gFc_path2, gFc_name, gFc_answ, gFc_pitanje, gFc_error
public gFc_fisc_print, gFc_operater, gFc_oper_pwd, gFc_tout, gIosa, gFc_alen, gFc_nftxt, gFc_acd, gFc_pdv
public gFc_pinit, gFc_chk, gFc_faktura, gFc_zbir, gFc_dlist, gFc_pauto, gFc_serial, gFc_restart

// stmpa na traku
public gMpPrint := "N"
public gMPLocPort := "1"
public gMPRedTraka := "2"
public gMPArtikal := "D"
public gMPCjenPDV := "2"

// zaokruzenje 5pf
public gZ_5pf := "N"

// prebacio iz fakt.ch define komande
public zaokruzenje := 2
public i_id := 1
public nl := hb_eol()

// firma naziv
public gFNaziv:=SPACE(250) 
// firma dodatni opis
public gFPNaziv:=SPACE(250) 
// firma adresa
public gFAdresa:=SPACE(35) 
// firma id broj
public gFIdBroj:=SPACE(13)
// telefoni
public gFTelefon:=SPACE(72) 
// web
public gFEmailWeb:=SPACE(72)
// banka 1
public gFBanka1:=SPACE(50)
// banka 2
public gFBanka2:=SPACE(50)
// banka 3
public gFBanka3:=SPACE(50)
// banka 4
public gFBanka4:=SPACE(50)
// banka 5
public gFBanka5:=SPACE(50)
// proizv.text 1
public gFText1:=SPACE(72)
// proizv.text 2
public gFText2:=SPACE(72)
// proizv.text 3
public gFText3:=SPACE(72)
// stampati zaglavlje
public gStZagl:="D" 

// picture header rows
public gFPicHRow:=0
public gFPicFRow:=0

// citaj parametre sa db servera

// fiskalni parametri
fiscal_params_read()

// parametri zaglavlja
gFNaziv := fetch_metric( "org_naziv", nil, gFNaziv )
gFPNaziv := fetch_metric( "org_naziv_dodatno", nil, gFPNaziv )
gFAdresa := fetch_metric( "org_adresa", nil, gFAdresa )
gFIdBroj := fetch_metric( "org_pdv_broj", nil, gFIdBroj )
gFBanka1 := fetch_metric( "fakt_zagl_banka_1", nil, gFBanka1 )
gFBanka2 := fetch_metric( "fakt_zagl_banka_2", nil, gFBanka2 )
gFBanka3 := fetch_metric( "fakt_zagl_banka_3", nil, gFBanka3 )
gFBanka4 := fetch_metric( "fakt_zagl_banka_4", nil, gFBanka4 )
gFBanka5 := fetch_metric( "fakt_zagl_banka_5", nil, gFBanka5 )
gFTelefon := fetch_metric( "fakt_zagl_telefon", nil, gFTelefon )
gFEmailWeb := fetch_metric( "fakt_zagl_email", nil, gFEmailWeb )
gFText1 := fetch_metric( "fakt_zagl_dtxt_1", nil, gFText1 )
gFText2 := fetch_metric( "fakt_zagl_dtxt_2", nil, gFText2 )
gFText3 := fetch_metric( "fakt_zagl_dtxt_3", nil, gFText3 )
gStZagl := fetch_metric( "fakt_zagl_koristiti_txt", nil, gStZagl )
gFPicHRow := fetch_metric( "fakt_zagl_pic_header", nil, gFPicHRow )
gFPicFRow := fetch_metric( "fakt_zagl_pic_footer", nil, gFPicFRow )

O_PARAMS
private cSection:="1"
public cHistory:=" "
public aHistory:={}

// varijanta cijene
RPar("50",@gVarC)      
// prvenstveno za win 95
RPar("95",@gKomLin)       

RPar("cr",@gZnPrec)
RPar("d1",@gnTMarg2)
RPar("d2",@gnTMarg3)
RPar("d3",@gnTMarg4)
RPar("dc",@g13dcij)
// dodatni parametri fakture broj otpremnice itd
RPar("dp",@gDodPar)   
RPar("dv",@gDatVal)
RPar("er",@gERedova)
RPar("fp",@gFPzag)
RPar("fz",@gFZaok)
RPar("if",@gImeF)
RPar("im",@gIMenu)
RPar("k1",@gDK1)
RPar("k2",@gDK2)
// varijanta maloprodajne cijene
RPar("mp",@gMP)       
RPar("mr",@gMjRJ)
RPar("nd",@gNumdio)
RPar("PR",@gDetPromRj)
Rpar("ff",@gFaktFakt)
Rpar("nw",@gNW)
Rpar("NF",@gFNar)
Rpar("UF",@gFUgRab)
Rpar("sk",@gSamoKol)
Rpar("rP",@gRokPl)
Rpar("rR",@gRabIzRobe)
Rpar("no",@gNovine)
Rpar("ds",@gnDS)
Rpar("ot",@gOdvT2)
RPar("p0",@PicCDem)
RPar("p1",@PicDem)
RPar("p2",@PicKol)
RPar("pk",@gPratik)
RPar("pc",@gPratiC)
RPar("pr",@gnLMarg)
RPar("56",@gnLMargA5)
RPar("pt",@gnTMarg)
RPar("r1",@g10Str2R)
RPar("r2",@g16Str2R)
RPar("r5",@g06Str2R)

RPar("s1",@g10Str)
RPar("s9",@g16Str)
RPar("r3",@g06Str)
RPar("s2",@g11Str)
RPar("xl",@g15Str)
RPar("s3",@g20Str)
RPar("s4",@g10Str2T)
RPar("s8",@g16Str2T)
RPar("r4",@g06Str2T)
RPar("s5",@g11Str2T)
RPar("xm",@g15Str2T)
RPar("s6",@g20Str2T)
RPar("uc",@gNazPotStr)
RPar("s7",@gMjStr)
RPar("tb",@gTabela)
RPar("tf",@gTipF)
RPar("vf",@gVarF)
RPar("v0",@gVFRP0)
RPar("kr",@gKriz)
RPar("55",@gKrizA5)
RPar("51",@gFPzagA5)
RPar("52",@gnTMarg2A5)
RPar("53",@gnTMarg3A5)
RPar("54",@gnTMarg4A5)
RPar("vp",@gV12Por)
RPar("vu",@gVFU)
RPar("vr",@gVarRF)
RPar("vo",@gVar13)
RPar("vn",@gVarNum)
RPar("vz",@gVlZagl)
RPar("x1",@g11Str2R)
RPar("xn",@g15Str2R)
RPar("x2",@g20Str2R)
RPar("x3",@g12Str)
RPar("x4",@g12Str2T)
RPar("x5",@g12Str2R)
RPar("x6",@g13Str)
RPar("x7",@g13Str2T)
RPar("x8",@g13Str2R)
RPar("x9",@g21Str)
RPar("xa",@g21Str2T)
RPar("xb",@g21Str2R)
RPar("xc",@g22Str)
RPar("xd",@g22Str2T)
RPar("xe",@g22Str2R)
RPar("xC",@g23Str)
RPar("xD",@g23Str2T)
RPar("xE",@g23Str2R)
RPar("xf",@g25Str)
RPar("xg",@g25Str2T)
RPar("xh",@g25Str2R)
RPar("xi",@g26Str)
RPar("xj",@g26Str2T)
RPar("xk",@g26Str2R)
RPar("xo",@g27Str)
RPar("xp",@g27Str2T)
RPar("xr",@g27Str2R)

// lista dodatni tekst
RPar("ya",@g10ftxt)
RPar("yb",@g11ftxt)
RPar("yc",@g12ftxt)
RPar("yd",@g13ftxt)
RPar("ye",@g15ftxt)
RPar("yf",@g16ftxt)
RPar("yg",@g20ftxt)
RPar("yh",@g21ftxt)
RPar("yi",@g22ftxt)
RPar("yI",@g23ftxt)
RPar("yj",@g25ftxt)
RPar("yk",@g26ftxt)
RPar("yl",@g27ftxt)

// stmapa mp - traka
RPar("mP",@gMpPrint)
RPar("mL",@gMpLocPort)
RPar("mT",@gMpRedTraka)
RPar("mA",@gMpArtikal)
RPar("mC",@gMpCjenPDV)

// zaokruzenje 5 pf
RPar("mZ",@gZ_5pf)

// dodatni parametri fakture broj otpremnice itd
RPar("za",@gZagl)   
RPar("zb",@gbold)
RPar("RT",@gRekTar)
RPar("HL",@gHLinija)
RPar("rp",@gRabProc)
RPar("pd",@gProtu13)
RPar("a5",@gFormatA5)
RPar("mn",@gMreznoNum)
RPar("g1",@gKarC1)
RPar("g2",@gKarC2)
RPar("g3",@gKarC3)
RPar("g4",@gKarN1)
RPar("g5",@gKarN2)
RPar("g6",@gPSamoKol)
RPar("gC",@gArtCDX)
RPar("gE",@gEmailInfo)
RPar("rs",@gcRabDef)
RPar("ir",@gcRabIDef)
RPar("id",@gcRabDok)
RPar("Fi",@gIspPart)
RPar("Fr",@gResetRoba)
RPar("Fx",@gcF9usmece)
RPar("Fz",@gAzurTimeOut)
RPar("F5",@glRGrPrn)

cSection := "2"
RPar("s1", @gShSld)
RPar("s2", @gFinKtoDug)
RPar("s3", @gFinKtoPot)
RPar("s4", @gShSldVar)

cSection := "1"
// varijable PDV
// DelphiRB - pdv faktura
public gPdvDRb := "N"
public gPdvDokVar := "1"

Rpar("H1",@gPdvDrb)
Rpar("H2",@gPdvDokVar)

if valtype(gtabela)<>"N"
	gTabela:=1
endif

select params
use
cSekcija:="SifRoba"
cVar:="PitanjeOpis"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="ID_J"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'N') , SIFPATH)
cSekcija:="SifRoba"; cVar:="VPC2"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="MPC2"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="MPC3"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="PrikId"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'ID') , SIFPATH)
cSekcija:="SifRoba"; cVar:="DuzSifra"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'10') , SIFPATH)

cSekcija:="BarKod"; cVar:="Auto"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'N') , SIFPATH)
cSekcija:="BarKod"; cVar:="AutoFormula"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'ID') , SIFPATH)
cSekcija:="BarKod"; cVar:="Prefix"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'') , SIFPATH)
cSekcija:="BarKod"; cVar:="NazRTM"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'barkod') , SIFPATH)

public glDistrib := .f.
//(IzFmkIni("FAKT","Distribucija","N",KUMPATH)=="D")
public gDest := .f.
//(IzFmkIni("FAKT","Destinacija", "N", KUMPATH)=="D")
public gPovDob := "0"
//IzFmkIni("FAKT_TipDok01","StampaPovrataDobavljacu_DefaultOdgovor","0",KUMPATH)

public gUVarPP := IzFMKINI("POREZI","PPUgostKaoPPU","M")
cPom := IzFMKINI("POREZI","PPUgostKaoPPU","-",KUMPATH)
IF cPom <> "-"
  gUVarPP:=cPom
ENDIF
gSQL:=IzFmkIni("Svi","SQLLog","N",KUMPATH)

if IzFmkIni("FAKT","ReadOnly","N", PRIVPATH)=="D"
   gReadOnly:=.t.
   @ 22,65 SAY "ReadOnly rezim"
endif

if IzFmkIni("FMK","TerminalServer","N")=="D"
   PUBLIC gTerminalServer
   gTerminalServer:=.t.
endif

public lPoNarudzbi := .f.
//lPoNarudzbi:= ( IzFMKINI("FAKT","10PoNarudzbi","N",KUMPATH)=="D" )

public lSpecifZips := .f. 
//lSpecifZips:= ( IzFmkIni("FAKT_Specif","ZIPS","N")=="D" )

public gModul:="FAKT"
gGlBaza:="FAKT.DBF"

gRobaBlock:={|Ch| FaRobaBlock(Ch)}
gPartnBlock:={|Ch| FaPartnBlock(Ch)}

public glCij13Mpc:=(IzFmkIni("FAKT","Cijena13MPC","D", KUMPATH)=="D")

public gcLabKomLin:=IzFmkIni("FAKT","PozivZaLabeliranje","labelira labelu",KUMPATH)
public gNovine:=(IzFmkIni("STAMPA","Opresa","N",KUMPATH))

public glRadNal := .f.
glRadNal:=(IzFmkIni("FAKT","RadniNalozi","N",KUMPATH)=="D")

public gKonvZnWin
gKonvZnWin:=IzFmkIni("DelphiRB","Konverzija","3",EXEPATH)

::lOpcine:=IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"

::lDoks2:=IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D"

::lId_J:=IzFmkIni("SifRoba", "ID_J", "N", SIFPATH)=="D"

::lCRoba:=(IzFmkIni('CROBA','GledajFakt','N',KUMPATH)=='D')

::cRoba_Rj:=IzFmkIni('CROBA','CROBA_RJ','10#20',KUMPATH)

::lOpresaStampa:=IzFmkIni('Opresa','Remitenda','N',PRIVPATH)=="D"

if !(goModul:oDatabase:lAdmin)
	MsgO("Pakujem pripremu")
		O_FAKT_PRIPR
		__dbPack()
		USE
	MsgC()
endif

return


