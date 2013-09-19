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

set_hot_keys()

Izbor := 1

gDuzKonto := 7 

gRobaBlock:={|Ch| RobaBlock(Ch)}

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")

// dodaj polja grupe u sifrarnik sifk
set_sifk_roba_group()

::mMenuStandard()

return nil



// -----------------------------------------------
// -----------------------------------------------
method mMenuStandard
local oDb_lock := F18_DB_LOCK():New()
local _db_locked := oDb_lock:is_locked()
private opc:={}
private opcexe:={}

AADD(opc,   "1. unos/ispravka dokumenata                ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","UNOSDOK")) .and. !F18_DB_LOCK():new():is_locked()
	AADD(opcexe,{|| kalk_unos_dokumenta()} )
else
	AADD(opcexe, {|| oDb_lock:warrning() })
endif

AADD(opc,   "2. izvjestaji")
AADD(opcexe, {|| MIzvjestaji()})

AADD(opc,   "3. pregled dokumenata")
AADD(opcexe, {|| kalk_pregled_dokumenata()})

AADD(opc,   "4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK")) .and. !F18_DB_LOCK():new():is_locked()
	AADD(opcexe,{|| kalk_mnu_generacija_dokumenta()})
else
	AADD(opcexe, {|| oDb_lock:warrning() })
endif

AADD(opc,   "5. moduli - razmjena podataka ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","MODULIRAZMJENA")) .and. !F18_DB_LOCK():new():is_locked()
	AADD(opcexe, {|| kalk_razmjena_podataka()})
else
	AADD(opcexe, {|| oDb_lock:warrning() })
endif

AADD(opc,   "6. udaljene lokacije  - razmjena podataka") 
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","PRENOSDISKETE")) .and. !F18_DB_LOCK():new():is_locked()
	AADD(opcexe, {|| kalk_udaljena_razmjena_podataka()})
else
	AADD(opcexe, {|| oDb_lock:warrning() })
endif

AADD(opc,   "7. ostale operacije nad dokumentima")
if !_db_locked
    AADD(opcexe, {|| kalk_ostale_operacije_doks()})
else
	AADD(opcexe, {|| oDb_lock:warrning() })
endif

AADD(opc,"------------------------------------")
AADD(opcexe, nil)

AADD(opc,   "8. sifrarnici")
AADD(opcexe,{|| kalk_sifrarnik()})

AADD(opc,   "9. administriranje baze podataka") 
if (ImaPravoPristupa(goModul:oDataBase:cName,"MAIN","DBADMIN")) .and. !F18_DB_LOCK():new():is_locked()
	AADD(opcexe, {|| MAdminKalk() } )
else
	AADD(opcexe, {|| oDb_lock:warrning() })
endif

AADD(opc,"------------------------------------")
AADD(opcexe, nil)

// najcesece koristenje opcije
AADD(opc,   "A. stampa azuriranog dokumenta")
AADD(opcexe, {|| kalk_centr_stampa_dokumenta(.t.)})

AADD(opc,   "P. povrat dokumenta u pripremu") 
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK")) .and. !F18_DB_LOCK():new():is_locked()
	AADD(opcexe, {|| Povrat_kalk_dokumenta()})
else
	AADD(opcexe, {|| oDb_lock:warrning() })
endif

AADD(opc,"------------------------------------")
AADD(opcexe, nil)

AADD(opc,   "X. parametri")
if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","PARAMETRI"))
	AADD(opcexe, {|| kalk_params()})
else
	AADD(opcexe, {|| oDb_lock:warrning() })
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
local _tmp

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
public gMultiPM := "D"
public gRCRP := "C"
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
public gVarEv:="1"  // 1-sa cijenama   2-bez cijena
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

public gTops := "0 "   
// Koristim TOPS - 0 - ne prenosi se podaci,"1 " - prod mjes 1
public gFakt := "0 "   
// Koristim FAKT - 0 - ne prenosi se podaci,"1 " - prod mjes 1
public gTopsDEST := SPACE( 300 ) 
public gSetForm := "1"

public c10Var:="2"  // 1-stara varijanta izvjestaja, nova varijanta izvj
public g80VRT:="1"
public gCijene:="2" // cijene iz sifrarnika, validnost
public gGen16:="1"
public gNiv14:="1"

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
public gKalks:=.f.
public lPodBugom:=.f.
public gVodiSamoTarife := "N"
public lSyncon47 := .f.
public lKoristitiBK := .f.
public lPrikPRUC := .f.
public gDuzKonto
if VALTYPE(::oDatabase) == "O" .and. !::oDatabase:lAdmin
	O_KALK_PRIPR
	gDuzKonto:=LEN(mkonto)
	use
else
	gDuzKonto:=7
endif

public glZabraniVisakIP
public glBrojacPoKontima := .f.
public glEvidOtpis
public gcSLObrazac

// inicijalizujem ovu varijablu uvijek pri startu
// ona sluzi za automatsku obradu kalkulacija 
// vindija - varazdin
public lAutoObr := .f.

cOdradjeno := "D"

gGlBaza := "KALK.DBF"

c10T1 := fetch_metric("kalk_dokument_10_trosak_1", nil, c10T1)
c10T2 := fetch_metric("kalk_dokument_10_trosak_2", nil, c10T2)
c10T3 := fetch_metric("kalk_dokument_10_trosak_3", nil, c10T3)
c10T4 := fetch_metric("kalk_dokument_10_trosak_4", nil, c10T4)
c10T5 := fetch_metric("kalk_dokument_10_trosak_5", nil, c10T5)

cRNT1 := fetch_metric("kalk_dokument_rn_trosak_1", nil, cRNT1)
cRNT2 := fetch_metric("kalk_dokument_rn_trosak_2", nil, cRNT2)
cRNT3 := fetch_metric("kalk_dokument_rn_trosak_3", nil, cRNT3)
cRNT4 := fetch_metric("kalk_dokument_rn_trosak_4", nil, cRNT4)
cRNT5 := fetch_metric("kalk_dokument_rn_trosak_5", nil, cRNT5)

c24T1 := fetch_metric("kalk_dokument_24_trosak_1", nil, c24T1)
c24T2 := fetch_metric("kalk_dokument_24_trosak_2", nil, c24T2)
c24T3 := fetch_metric("kalk_dokument_24_trosak_3", nil, c24T3)
c24T4 := fetch_metric("kalk_dokument_24_trosak_4", nil, c24T4)
c24T5 := fetch_metric("kalk_dokument_24_trosak_5", nil, c24T5)
c24T6 := fetch_metric("kalk_dokument_24_trosak_6", nil, c24T6)
c24T7 := fetch_metric("kalk_dokument_24_trosak_7", nil, c24T7)
c24T8 := fetch_metric("kalk_dokument_24_trosak_8", nil, c24T8)

gAFin := fetch_metric("kalk_kontiranje_fin", f18_user(), gAFin)
gAMat := fetch_metric("kalk_kontiranje_mat", f18_user(), gAMat)
gAFakt := fetch_metric("kalk_kontiranje_fakt", f18_user(), gAFakt)
gBrojac := fetch_metric("kalk_brojac_kalkulacija", nil, gBrojac)
gMagacin := fetch_metric("kalk_magacin_po_nc", nil, gMagacin)

if IsPDV()
	gPDVMagNab := fetch_metric("kalk_magacin_po_nc_pdv", nil, gPDVMagNab)
endif

gCijene := fetch_metric("kalk_azuriranje_sumnjivih_dokumenata", nil, gCijene)
gTS := fetch_metric("kalk_tip_subjekta", nil, gTS)
gTabela := fetch_metric("kalk_tip_tabele", nil, gTabela)
gSetForm := fetch_metric("kalk_set_formula", nil, gSetForm)
gGen16 := fetch_metric("kalk_generisi_16_nakon_96", f18_user(), gGen16)
gKomFakt := fetch_metric("kalk_oznaka_rj_u_fakt", nil, gKomFakt)
gKomKonto := fetch_metric("kalk_komision_konto", nil, gKomKonto)
gKalo := fetch_metric("kalk_kolicina_kalo", nil, gKalo)
gVodiKalo := fetch_metric("kalk_voditi_kalo", nil, gVodiKalo)
gNiv14 := fetch_metric("kalk_tip_nivelacije_14", nil, gNiv14)
gMetodaNC := fetch_metric("kalk_metoda_nc", nil, gMetodaNC)
gDecKol := fetch_metric("kalk_broj_decimala_za_kolicinu", nil, gDeckol)
gDefNiv := fetch_metric("kalk_promjena_cijena_odgovor", nil, gDefNiv)
gVarEv := fetch_metric("kalk_varijanta_evidencije", nil, gVarEv)
gPicCDem := fetch_metric("kalk_format_prikaza_cijene", nil, gPicCDEM)
gPicProc := fetch_metric("kalk_format_prikaza_procenta", nil, gPicProc)
gPicDem := fetch_metric("kalk_format_prikaza_iznosa", nil, gPicDEM)
gPicKol := fetch_metric("kalk_format_prikaza_kolicine", nil, gPicKol)
gPicNc := fetch_metric("kalk_format_prikaza_nabavne_cijene", nil, gPicNC)
gFPicCDem := fetch_metric("kalk_format_prikaza_cijene_prosirenje", nil, gFPicCDem)
gFPicDem := fetch_metric("kalk_format_prikaza_iznosa_prosirenje", nil, gFPicDem)
gFPicKol := fetch_metric("kalk_format_prikaza_kolicine_prosirenje", nil, gFPicKol)
gPotpis := fetch_metric("kalk_potpis_na_kraju_naloga", nil, gPotpis)
gRCRP := fetch_metric("kalk_varijanta_popusta_na_dokumentima", nil, gRCRP)
gAutoRavn := fetch_metric("kalk_kontiranje_automatska_ravnoteza_naloga", nil, gAutoRavn)
gAutoCjen := fetch_metric("kalk_automatsko_azuriranje_cijena", nil, gAutoCjen)
gRobaTrosk := fetch_metric("PreuzimanjeTroskovaIzSifRoba", nil, gRobaTrosk)
gRobaTr1Tip := fetch_metric("kalk_trosak_1_tip", nil, gRobaTr1Tip)
gRobaTr2Tip := fetch_metric("kalk_trosak_2_tip", nil, gRobaTr2Tip)
gRobaTr3Tip := fetch_metric("kalk_trosak_3_tip", nil, gRobaTr3Tip)
gRobaTr4Tip := fetch_metric("kalk_trosak_4_tip", nil, gRobaTr4Tip)
gRobaTr5Tip := fetch_metric("kalk_trosak_5_tip", nil, gRobaTr5Tip)
gDokKVal := fetch_metric("kalk_konverzija_valute_na_unosu", nil, gDokKVal)

g10Porez := fetch_metric("kalk_dokument_10_prikaz_ukalk_poreza", nil, g10Porez)
c10Var := fetch_metric("kalk_dokument_10_varijanta", nil, c10Var)
g11BezNC := fetch_metric("kalk_dokument_11_bez_nc", nil, g11bezNC)
g80VRT := fetch_metric("kalk_dokument_80_rekap_po_tar", nil, g80VRT)
gVarVP := fetch_metric("kalk_dokument_14_varijanta_poreza", nil, gVarVP)
gVar13u11 := fetch_metric("kalk_varijanta_fakt_13_kalk_11_cijena", nil, gVar13u11)
 
gTops := fetch_metric("kalk_prenos_pos", f18_user(), gTops)
gFakt := fetch_metric("kalk_prenos_fakt", f18_user(), gFakt)
gTopsDest := fetch_metric("kalk_destinacija_topska", f18_user(), gTopsDest)
gMultiPM := fetch_metric("kalk_tops_prenos_vise_prodajnih_mjesta", f18_user(), gMultiPM)
gMPCPomoc := fetch_metric("kalk_pomoc_sa_mpc", nil, gMPCPomoc)
gKolicFakt := fetch_metric("kalk_kolicina_kod_nivelacije_fakt", nil, gKolicFakt)
gPromTar := fetch_metric("kalk_zabrana_promjene_tarifa", nil, gPromTar)
gFunKon1 := fetch_metric("kalk_djoker_f1_kod_kontiranja", nil, gFunKon1)
gFunKon2 := fetch_metric("kalk_djoker_f2_kod_kontiranja", nil, gFunKon2)

gAzurTimeout := fetch_metric("kalk_timeout_kod_azuriranja", nil, gAzurTimeout)
gAzurFinTO := fetch_metric("kalk_timeout_kod_azuriranja_fin_naloga", nil, gAzurFinTO)
gCache := fetch_metric("kalk_cache_tabela", f18_user(), gCache)
gNC_ctrl := fetch_metric("kalk_kontrola_odstupanja_nc", f18_user(), gNC_ctrl)
gnLOst := fetch_metric("kalk_limit_za_otvorene_stavke", f18_user(), gnLOst)
gLenBrKalk := fetch_metric("kalk_duzina_brojaca_dokumenta", nil, gLenBrKalk)
gArtCDX := fetch_metric("kalk_index_za_pretragu_artikla", f18_user(), gArtCDX)

gAImpPrint := fetch_metric("kalk_auto_import_podataka_printanje", f18_user(), gAImpPrint)
gAImpRKonto := fetch_metric("kalk_auto_import_podataka_konto", f18_user(), gAImpRKonto)
gAImpRight := fetch_metric("kalk_auto_import_podataka_karakteri", f18_user(), gAImpRight)

// iz FMK inija...

glEkonomat := fetch_metric("kalk_voditi_samo_ekonomat", nil, glEkonomat)
lPoNarudzbi := fetch_metric("kalk_dokument_10_po_narudzbi", nil, lPoNarudzbi)
gVodiSamoTarife := fetch_metric("kalk_vodi_samo_tarife", nil, gVodiSamoTarife)
lKoristitiBK := fetch_metric("kalk_koristiti_barkod_pri_unosu", my_user(), lKoristitiBK )

if lKoristitiBK
	// ako se koristi barkod onda je duzina robe 13
	gDuzSifIni := "13"
endif

lPrikPRUC := fetch_metric("kalk_prikazi_kolone_pruc", nil, lPrikPRUC)

glZabraniVisakIP := fetch_metric("kalk_zabrani_visak_kod_ip", nil, glZabraniVisakIP)
glBrojacPoKontima := fetch_metric("kalk_brojac_dokumenta_po_kontima", nil, glBrojacPoKontima )

glEvidOtpis := fetch_metric("kalk_evidentiraj_otpis", nil, glEvidOtpis)
gcSlObracun := fetch_metric("kalk_sl_obrazac", nil, gcSLObrazac)

gRobaBlock:={|Ch| RobaBlock(Ch)}

// ne znam zasto, ali ovako je bilo ???
// u svim modulima je "D"
gNW := "X"

return



