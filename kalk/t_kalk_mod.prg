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
#include "hbclass.ch"


// -----------------------------------------------
// -----------------------------------------------
CLASS TKalkMod FROM TAppMod
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
::oDatabase:=TDbKalk():new()
return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenu()

private Izbor

//say_fmk_ver()

SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

// provjeri da li je read only
CheckROnly(KUMPATH + "\KALK.DBF")

O_KALK_DOKS
select kalk_doks
gDuzKonto:=LEN(mkonto) 
select kalk_doks

// skeniranje prodavnica automatsko...
pl_scan_automatic()
use

gRobaBlock:={|Ch| RobaBlock(Ch)}
@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")

::mMenuStandard()

//::quit()

return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenuStandard

private opc:={}
private opcexe:={}

AADD(opc,   "1. unos/ispravka dokumenata                ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","UNOSDOK"))
	AADD(opcexe,{|| kalk_unos_dokumenta()} )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,   "2. izvjestaji")
AADD(opcexe, {|| MIzvjestaji()})
AADD(opc,   "3. pregled dokumenata")
AADD(opcexe, {|| kalk_pregled_dokumenata()})
AADD(opc,   "4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK"))
	AADD(opcexe,{|| kalk_mnu_generacija_dokumenta()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,   "5. moduli - razmjena podataka ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","MODULIRAZMJENA"))
	AADD(opcexe, {|| kalk_razmjena_podataka()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,   "6. udaljene lokacije  - razmjena podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","PRENOSDISKETE"))
	AADD(opcexe, {|| KalkPrenosDiskete()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,   "7. ostale operacije nad dokumentima")
AADD(opcexe, {|| kalk_ostale_operacije_doks()})
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   "8. sifrarnici")
AADD(opcexe,{|| kalk_sifrarnik()})
AADD(opc,   "9. administriranje baze podataka") 
if (ImaPravoPristupa(goModul:oDataBase:cName,"MAIN","DBADMIN"))
	AADD(opcexe, {|| MAdminKalk()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,"------------------------------------")
AADD(opcexe, nil)

// najcesece koristenje opcije
AADD(opc,   "A. stampa azuriranog dokumenta")
AADD(opcexe, {|| kalk_centr_stampa_dokumenta(.t.)})
AADD(opc,   "P. povrat dokumenta u pripremu") 
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
	AADD(opcexe, {|| Povrat_kalk_dokumenta()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   "X. parametri")
if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","PARAMETRI"))
	AADD(opcexe, {|| kalk_params()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
private Izbor:=1
Menu_SC("gkas", .t. )

return


// -----------------------------------------------
// -----------------------------------------------
method srv()
? "Pokrecem KALK aplikacijski server"
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

local cPPSaMr 
local cBazniDir
local cMrRs
local cOdradjeno
local cSekcija
local cVar,cVal

set_global_vars()
set_roba_global_vars()

public KursLis:="1"
public gMetodaNC:="2"
public gDefNiv:="D"
public gDecKol:=5
public gKalo:="2"
public gMagacin:="2"
public gPDVMagNab:="N"
if IsPDV()
	gPDVMagNab:="D"
endif
public gRCRP := "C"
public gTS:="Preduzece"
public gPotpis:="N"
public g10Porez:="N"
public gDirFin:=""
public gDirMat:=""
public gDirFiK:=""
public gDirMaK:=""
public gDirFakt:=""
public gDirFaKK:=""
public gBrojac:="D"
public gRokTr:="N"
public gVarVP:="1"
public gAFin:="D"
public gAMat:="0"
public gAFakt:="D"
public gVodiKalo:="N"
public gAutoRavn:="N"
public gAutoCjen:="D"
public gLenBrKalk:=5
public gArtCDX:=SPACE(20)

O_PARAMS
private cSection:="K",cHistory:=" "; aHistory:={}

public gNW:="X"  // new vawe
public gVarEv:="1"  // 1-sa cijenama   2-bez cijena
public gBaznaV:="D"
public c24T1:=padr("Tr 1",15)
public c24T2:=padr("Tr 2",15)
public c24T3:=padr("Tr 3",15)
public c24T4:=padr("Tr 4",15)
public c24T5:=padr("Tr 5",15)
public c24T6:=padr("Tr 6",15)
public c24T7:=padr("Tr 7",15)
public c24T8:=padr("Tr 8",15)

public c10T1:="PREVOZ.T"
public c10T2:="AKCIZE  "
public c10T3:="SPED.TR "
public c10T4:="CARIN.TR"
public c10T5:="ZAVIS.TR"

public cRNT1:="        "
public cRNT2:="R.SNAGA "
public cRNT3:="TROSK 3 "
public cRNT4:="TROSK 4 "
public cRNT5:="TROSK 5 "

public gTops:="0 "   // Koristim TOPS - 0 - ne prenosi se podaci,"1 " - prod mjes 1
public gFakt:="0 "   // Koristim FAKT - 0 - ne prenosi se podaci,"1 " - prod mjes 1
public gTopsDEST:=space(20)
public gSetForm:="1"

public c10Var:="2"  // 1-stara varijanta izvjestaja, nova varijanta izvj
public g80VRT:="1"
public gCijene:="2" // cijene iz sifrarnika, validnost
public gGen16:="1"
public gNiv14:="1"

public gModemVeza:="N"
public gTabela := 0
public gPicNC := "999999.99999999"
public gKomFakt:="20"
public gKomKonto:="5611   "     // zakomision definisemo
                                      // konto i posebnu sifru firme u FAKT-u
public gVar13u11:="1"     // varijanta za otpremu u prodavnicu
public gPromTar:="N"
public gFunKon1:=PADR("SUBSTR(FINMAT->IDKONTO,4,2)",80)
public gFunKon2:=PADR("SUBSTR(FINMAT->IDKONTO2,4,2)",80)
public g11bezNC:="N"
public gMpcPomoc:="N"
public gKolicFakt:="N"
public gRobaTrosk:="N"
public gRobaTr1Tip:="%"
public gRobaTr2Tip:="%"
public gRobaTr3Tip:="%"
public gRobaTr4Tip:="%"
public gRobaTr5Tip:="%"

// dokument. koverzija valute
public gDokKVal := "N"
// time out kod azuriranja dokumenta
public gAzurTimeout := 150
// time out kod azuriranja fin dokumenta
public gAzurFinTO := 150

// auto obrada iz cache tabele
public gCache := "N"
// kontrola odstupanja nab.cijene
public gNC_ctrl := 0
// matrica koja sluzi u svrhu kontrole NC
public aNC_ctrl := {}
// limit za otvorene stavke
public gnLOst := -99

public lPoNarudzbi := .f.
public glEkonomat := .f. 

// KALK: auto import
// print dokumenata pri auto importu
public gAImpPrint := "N"
// ravnoteza def.konto
public gAImpRKonto := PADR("1370", 7)
// kod provjere prebacenih dokumenata odrezi sa desne strane broj karaktera
public gAImpRight := 0

gGlBaza := "KALK.DBF"

f18_get_metric("Dokument10Trosak1", @c10T1)
f18_get_metric("Dokument10Trosak2", @c10T2)
f18_get_metric("Dokument10Trosak3", @c10T3)
f18_get_metric("Dokument10Trosak4", @c10T4)
f18_get_metric("Dokument10Trosak5", @c10T5)

f18_get_metric("DokumentRNTrosak1", @cRNT1)
f18_get_metric("DokumentRNTrosak2", @cRNT2)
f18_get_metric("DokumentRNTrosak3", @cRNT3)
f18_get_metric("DokumentRNTrosak4", @cRNT4)
f18_get_metric("DokumentRNTrosak5", @cRNT5)

f18_get_metric("Dokument24Trosak1", @c24T1)
f18_get_metric("Dokument24Trosak2", @c24T2)
f18_get_metric("Dokument24Trosak3", @c24T3)
f18_get_metric("Dokument24Trosak4", @c24T4)
f18_get_metric("Dokument24Trosak5", @c24T5)
f18_get_metric("Dokument24Trosak6", @c24T6)
f18_get_metric("Dokument24Trosak7", @c24T7)
f18_get_metric("Dokument24Trosak8", @c24T8)

f18_get_metric("BaznaValuta", @gBaznaV)

f18_get_metric("KontiranjeFin", @gAFin)
f18_get_metric("KontiranjeMat", @gAMat)
f18_get_metric("KontiranjeFakt", @gAFakt)
f18_get_metric("BrojacKalkulacija", @gBrojac)

f18_get_metric("MagacinPoNC", @gMagacin)

if IsPDV()
	f18_get_metric("MagacinPoNCPDV", @gPDVMagNab)
endif

f18_get_metric("AzuriranjeSumnjivihDokumenata", @gCijene)

/*
// ovo su direktoriji fin, mat, kalk...
// ovo treba izbaciti
f18_get_metric("d3", @gDirFIK)
f18_get_metric("d4", @gDirMaK)
f18_get_metric("d5", @gDirFakK)
f18_get_metric("df", @gDirFIN)
f18_get_metric("dm", @gDirMat)
f18_get_metric("dx", @gDirFakt)
*/

f18_get_metric("TipSubjekta", @gTS)

f18_get_metric("TipTabele", @gTabela)
f18_get_metric("SetFormula", @gSetForm)
f18_get_metric("Generisi16Nakon96", @gGen16)
f18_get_metric("OznakaRjUFakt", @gKomFakt)
f18_get_metric("KomisionKonto", @gKomKonto)
f18_get_metric("KolicinaKalo", @gKalo)
f18_get_metric("VoditiKalo", @gVodiKalo)
f18_get_metric("TipNivelacije14", @gNiv14)
f18_get_metric("MetodaNC", @gMetodaNC)
f18_get_metric("BrojDecimalaZaKolicinu", @gDeckol)
f18_get_metric("PromjenaCijenaOdgovor", @gDefNiv)
f18_get_metric("NoviKorisnickiInterfejs", @gNW)
f18_get_metric("VarijantaEvidencije", @gVarEv)
f18_get_metric("FormatPrikazaCijene", @gPicCDEM)
f18_get_metric("FormatPrikazaProcenta", @gPicProc)
f18_get_metric("FormatPrikazaIznosa", @gPicDEM)
f18_get_metric("FormatPrikazaKolicine", @gPicKol)
f18_get_metric("FormatPrikazaNabavneCijene", @gPicNC)
f18_get_metric("FormatPrikazaCijeneProsirenje", @gFPicCDem)
f18_get_metric("FormatPrikazaIznosaProsirenje", @gFPicDem)
f18_get_metric("FormatPrikazaKolicineProsirenje", @gFPicKol)
f18_get_metric("PotpisNaKrajuNaloga", @gPotpis)
f18_get_metric("VarijantaPopustaNaDokumentima", @gRCRP)
f18_get_metric("RokTrajanja", @gRokTr)
f18_get_metric("KontiranjeAutomatskaRavnotezaNaloga", @gAutoRavn)
f18_get_metric("AutomatskoAzuriranjeCijena", @gAutoCjen)
f18_get_metric("PreuzimanjeTroskovaIzSifRoba", @gRobaTrosk)
f18_get_metric("Trosak1Tip", @gRobaTr1Tip)
f18_get_metric("Trosak2Tip", @gRobaTr2Tip)
f18_get_metric("Trosak3Tip", @gRobaTr3Tip)
f18_get_metric("Trosak4Tip", @gRobaTr4Tip)
f18_get_metric("Trosak5Tip", @gRobaTr5Tip)
f18_get_metric("KonverzijaValuteNaUnosu", @gDokKVal)

f18_get_metric("Dokument10PrikazUkalkPoreza", @g10Porez)
f18_get_metric("Dokument10Varijanta", @c10Var)
f18_get_metric("Dokument11BezNC", @g11bezNC)
f18_get_metric("Dokument80RekapPoTar", @g80VRT)
f18_get_metric("Dokument14VarijantaPoreza", @gVarVP)
f18_get_metric("VarijantaFakt13Kalk11Cijena", @gVar13u11)
 
f18_get_metric("PrenosPOS",@gTops)
f18_get_metric("PrenosFAKT",@gFakt)
f18_get_metric("DestinacijaTOPSKA",@gTopsDest)
f18_get_metric("ModemskaVeza",@gModemVeza)
f18_get_metric("PomocSaMPC",@gMPCPomoc)
f18_get_metric("KolicinaKodNivelacijeFakt",@gKolicFakt)
f18_get_metric("ZabranaPromjeneTarifa",@gPromTar)
f18_get_metric("DjokerF1KodKontiranja",@gFunKon1)
f18_get_metric("DjokerF2KodKontiranja",@gFunKon2)

f18_get_metric("TimeOutKodAzuriranja",@gAzurTimeout)
f18_get_metric("TimeOutKodAzuriranjaFinNaloga",@gAzurFinTO)
f18_get_metric("CacheTabela",@gCache)
f18_get_metric("KontrolaOdstupanjaNC",@gNC_ctrl)
f18_get_metric("LimitZaOtvoreneStavke",@gnLOst)
f18_get_metric("DuzinaBrojacaDokumenta",@gLenBrKalk)
f18_get_metric("IndexZaPretraguArtikla",@gArtCDX)

cOdradjeno:="D"

//if file(EXEPATH+'scshell.ini')
        //cBrojLok:=R_IniRead ( 'TekucaLokacija','Broj',  "",EXEPATH+'scshell.INI' )
  //      cOdradjeno:=R_IniRead ( 'ShemePromjena',alltrim(strtran(strtran(cDirPriv,"\","_"),":","_")),  "N" ,EXEPATH+'scshell.INI' )
    //    R_IniWrite ( 'ShemePromjena',alltrim(strtran(strtran(cDirPriv,"\","_"),":","_")),  "D" ,EXEPATH+'scshell.INI' )
//endif

/*
if ( empty( gDirFin ) .or. ;
	empty( gDirMat ) .or. empty(gDirFiK) .or. ;
	empty(gDirMaK) .or. empty(gDirFaKt) .or. ;
	empty(gDirFakK) ) .or. cOdradjeno="N"

  gDirFin := strtran(cDirPriv,"KALK","FIN")+SLASH
  gDirMat := strtran(cDirPriv,"KALK","MAT")+SLASH
  gDirFiK := strtran(cDirRad,"KALK","FIN")+SLASH
  gDirMaK := strtran(cDirRad,"KALK","MAT")+SLASH
  gDirFakt := strtran(cDirPriv,"KALK","FAKT")+SLASH
  gDirFakK := strtran(cDirRad,"KALK","FAKT")+SLASH
  
  WPar("df",gDirFin)
  WPar("dm",gDirMat)
  WPar("d3",gDirFiK)
  WPar("d4",gDirMaK)

endif


gDirFin:=trim(gDirFin)
gDirMat:=trim(gDirMat)
gDirFiK:=trim(gDirFiK)
gDirMaK:=trim(gDirMaK)
gDirFakt:=trim(gDirFakt)
gDirFakK:=trim(gDirFakK)
*/

// KALK: auto import
private cSection := "7"
f18_get_metric("AutoImportPodatakaPrintanje", @gAImpPrint)
f18_get_metric("AutoImportPodatakaKonto", @gAImpRKonto)
f18_get_metric("AutoImportPodatakaKarakteri", @gAImpRight)

select (F_PARAMS)
use

cSekcija:="SifRoba"
cVar:="PitanjeOpis"
IzFmkIni (cSekcija, cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
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


// iz FMK inija...

f18_get_metric("VoditiSamoEkonomat", @glEkonomat)
f18_get_metric("Dokument10PoNarudzbi", @lPoNarudzbi)

public gKalks:=.f.
public lPodBugom:=.f.
public gVodiSamoTarife
public lSyncon47 := .f.
public lKoristitiBK := .f.
public lPrikPRUC := .f.

f18_get_metric("VodiSamoTarife", @gVodiSamoTarife)
f18_get_metric("KoristitiBarkodPriUnosu", @lKoristitiBK)
f18_get_metric("PrikaziKolonePRUC", @lPrikPRUC)

public gDuzKonto
if !::oDatabase:lAdmin
	O_KALK_PRIPR
	gDuzKonto:=LEN(mkonto)
	use
else
	gDuzKonto:=7
endif

public glZabraniVisakIP
public glBrojacPoKontima
public glEvidOtpis
public gcSLObrazac

f18_get_metric("ZabraniVisakKodIP", @glZabraniVisakIP)
f18_get_metric("BrojacPoKontima", @glBrojacPoKontima)
f18_get_metric("EvidentirajOtpis", @glEvidOtpis)
f18_get_metric("SLObrazac", @gcSLObrazac)

gRobaBlock:={|Ch| RobaBlock(Ch)}

// inicijalizujem ovu varijablu uvijek pri startu
// ona sluzi za automatsku obradu kalkulacija 
// vindija - varazdin
public lAutoObr := .f.

return



