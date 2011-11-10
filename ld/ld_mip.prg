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


#include "ld.ch"


static __mj
static __god
static __xml := 0
static __ispl_s := 0

// ---------------------------------------------------------
// sortiranje tabele LD
// ---------------------------------------------------------
function mip_sort(cRj, cGod, cMj, cRadnik, cObr )
local cFilter := ""

private cObracun := cObr

if lViseObr
	if !EMPTY(cObr)
		cFilter += "obr == " + cm2str(cObr)
	endif
endif

if !EMPTY(cRj)
	
	if !EMPTY(cFilter)
		cFilter += " .and. "
	endif
	
	cFilter += Parsiraj(cRj,"IDRJ")
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

if EMPTY(cRadnik) 
	INDEX ON str(godina)+str(mjesec)+SortPrez(idradn)+idrj TO "TMPLD"
	go top
	seek str(cGod,4)+str(cMj,2)+cRadnik
else
	set order to tag (TagVO("2"))
	go top
	seek str(cGod,4)+str(cMj,2)+cRadnik
endif

return


// ---------------------------------------------
// upisivanje podatka u pomocnu tabelu za rpt
// ---------------------------------------------
static function _ins_tbl( cRadnik, cIdRj, nGodina, nMjesec, ;
		cTipRada, cVrIspl, cR_ime, cR_jmb, cR_opc, dDatIsplate, ;
		nSati, nSatiB, nSatiT, nStUv, nBruto, nO_prih, nU_opor, ;
		nU_d_pio, nU_d_zdr, nU_d_pms, nU_d_nez, nU_d_iz, ;
		nU_dn_pio, nU_dn_zdr, nU_dn_nez, nU_dn_dz, ;
		nUm_prih, nKLO, nLODB, nOsn_por, nIzn_por, ;
		cR_rmj, lBolPreko )

local nTArea := SELECT()

O_R_EXP
select r_export
append blank

replace idradn with cRadnik
replace idrj with cIdRj
replace godina with nGodina
replace mjesec with nMjesec
replace tiprada with cTipRada
replace vr_ispl with cVrIspl
replace r_ime with cR_ime
replace r_jmb with cR_jmb
replace r_opc with cR_opc
replace d_isp with dDatIsplate
replace r_sati with nSati
replace r_satib with nSatiB
replace r_satit with nSatiT
replace r_stuv with nSTUv
replace bruto with nBruto
replace o_prih with nO_prih
replace u_opor with nU_opor
replace u_d_pio with nU_d_pio
replace u_d_zdr with nU_d_zdr
replace u_d_pms with nU_d_pms
replace u_d_nez with nU_d_nez
replace u_dn_pio with nU_dn_pio
replace u_dn_zdr with nU_dn_zdr
replace u_dn_dz with nU_dn_dz
replace u_dn_nez with nU_dn_nez
replace u_d_iz with nU_d_iz
replace um_prih with nUm_prih
replace r_klo with nKLO
replace l_odb with nLODB
replace osn_por with nOsn_por
replace izn_por with nIzn_por
replace r_rmj with cR_rmj

// bolovanje preko 42 dana ili slicno
if lBolPreko = .t.
	replace bol_preko with "1"
else
	replace bol_preko with "0"
endif

select (nTArea)
return



// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
function mip_tmp_tbl()
local aDbf := {}

AADD(aDbf,{ "IDRADN", "C", 6, 0 })
AADD(aDbf,{ "IDRJ", "C", 2, 0 })
AADD(aDbf,{ "GODINA", "N", 4, 0 })
AADD(aDbf,{ "MJESEC", "N", 2, 0 })
AADD(aDbf,{ "VR_ISPL", "C", 50, 0 })
AADD(aDbf,{ "R_IME", "C", 30, 0 })
AADD(aDbf,{ "R_JMB", "C", 13, 0 })
AADD(aDbf,{ "R_OPC", "C", 20, 0 })
AADD(aDbf,{ "TIPRADA", "C", 1, 0 })
AADD(aDbf,{ "D_ISP", "D", 8, 0 })
AADD(aDbf,{ "R_SATI", "N", 12, 2 })
AADD(aDbf,{ "R_SATIB", "N", 12, 2 })
AADD(aDbf,{ "R_SATIT", "N", 12, 2 })
AADD(aDbf,{ "R_STUV", "N", 12, 2 })
AADD(aDbf,{ "BRUTO", "N", 12, 2 })
AADD(aDbf,{ "O_PRIH", "N", 12, 2 })
AADD(aDbf,{ "U_OPOR", "N", 12, 2 })
AADD(aDbf,{ "U_D_PIO", "N", 12, 2 })
AADD(aDbf,{ "U_D_ZDR", "N", 12, 2 })
AADD(aDbf,{ "U_D_NEZ", "N", 12, 2 })
AADD(aDbf,{ "U_DN_PIO", "N", 12, 2 })
AADD(aDbf,{ "U_DN_ZDR", "N", 12, 2 })
AADD(aDbf,{ "U_DN_DZ", "N", 12, 2 })
AADD(aDbf,{ "U_DN_NEZ", "N", 12, 2 })
AADD(aDbf,{ "U_D_IZ", "N", 12, 2 })
AADD(aDbf,{ "UM_PRIH", "N", 12, 2 })
AADD(aDbf,{ "R_KLO", "N", 5, 2 })
AADD(aDbf,{ "L_ODB", "N", 12, 2 })
AADD(aDbf,{ "OSN_POR", "N", 12, 2 })
AADD(aDbf,{ "IZN_POR", "N", 12, 2 })
AADD(aDbf,{ "R_RMJ", "C", 20, 0 })
AADD(aDbf,{ "U_D_PMS", "N", 12, 2 })
AADD(aDbf,{ "BOL_PREKO", "C", 1, 0 })
AADD(aDbf,{ "PRINT", "C", 1, 0 })

t_exp_create( aDbf )

O_R_EXP
// index on ......
index on idradn + STR(godina,4) + STR(mjesec,2) + vr_ispl tag "1"

return


// ------------------------------------------
// mip obrazac za radnike
// ------------------------------------------
function r_mip_obr()
local nC1:=20
local i
local cTPNaz
local nKrug:=1
local cRj := SPACE(60)
local cRJDef := SPACE(2)
local cRadnik := SPACE(_LR_) 
local cPrimDobra := SPACE(100)
local cIdRj
local cMj_od
local cMj_do
local cGod_od
local cGod_do
local cDopr10 := "10"
local cDopr11 := "11"
local cDopr12 := "12"
local cDopr1X := "1X"
local cDopr20 := "20"
local cDopr21 := "21"
local cDopr22 := "22"
local cDopr2D := SPACE(100)
local cDoprDod := SPACE(100)
local cTP_off := SPACE(100)
local cTP_bol := PADR("18;", 100)
local cBolPreko := PADR("18;24;", 100)
local cObracun := gObracun
local cWinPrint := "E"
local nOper := 1
local cIsplSaberi := "D"
local cNule := "N"
local cMipView := "N"

// kreiraj pomocnu tabelu
mip_tmp_tbl()

cIdRj := gRj
cMj := gMjesec
cGod := gGodina

cPredNaz := SPACE(50)
cPredJMB := SPACE(13)
cPredSDJ := SPACE(20)
dDatPodn := DATE()

nPorGodina := 2011
nBrZahtjeva := 1

// otvori tabele
ol_o_tbl()

select params

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("i1",@cPredNaz)
RPar("x9",@cPredSDJ)  
RPar("x8",@cDoprDod)  
RPar("x7",@cTp_bol)  
RPar("x6",@cBolPreko)  

cPredJMB := IzFmkIni("Specif","MatBr","--",KUMPATH)
cPredJMB := PADR(cPredJMB, 13)


Box("#MIP OBRAZAC ZA RADNIKE", 20, 75)

@ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
@ m_x + 2, m_y + 2 SAY "Za period:" GET cMj pict "99"
@ m_x + 2, col() + 1 SAY "/" GET cGod pict "9999"

if lViseObr
  	@ m_x+2,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif

@ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
	VALID EMPTY(cRadnik) .or. P_RADN(@cRadnik)
@ m_x + 5, m_y + 2 SAY "    Isplate u usl. ili dobrima:" ;
	GET cPrimDobra pict "@S30"
@ m_x + 6, m_y + 2 SAY "Tipovi koji ne ulaze u obrazac:" ;
	GET cTP_off pict "@S30"
@ m_x + 7, m_y + 2 SAY "Izdvojena primanja (bolovanje):" ;
	GET cTP_bol pict "@S30"
@ m_x + 8, m_y + 2 SAY "Sifre bolovanja preko 42 dana:" ;
	GET cBolPreko pict "@S30"

@ m_x + 9, m_y + 2 SAY "   Doprinos iz pio: " GET cDopr10 
@ m_x + 9, col() + 2 SAY "na pio: " GET cDopr20
@ m_x + 10, m_y + 2 SAY "   Doprinos iz zdr: " GET cDopr11
@ m_x + 10, col() + 2 SAY "na zdr: " GET cDopr21
@ m_x + 10, col() + 2 SAY "dod.dopr.na zdr: " GET cDopr2D PICT "@S10"
@ m_x + 11, m_y + 2 SAY "   Doprinos iz nez: " GET cDopr12
@ m_x + 11, col() + 2 SAY "na nez: " GET cDopr22
@ m_x + 12, m_y + 2 SAY "Doprinos iz ukupni: " GET cDopr1X
@ m_x + 13, m_y + 2 SAY " dod.dopr. benef.: " GET cDoprDod PICT "@S30"
@ m_x + 15, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz pict "@S30"
@ m_x + 15, col()+1 SAY "JID: " GET cPredJMB
@ m_x + 16, m_y + 2 SAY "Sifra djelatnosti: " GET cPredSDJ pict "@S20"
@ m_x + 17, m_y + 2 SAY "Def.RJ" GET cRJDef 
@ m_x + 17, col() + 2 SAY "Sabrati isplate za isti mj ?" GET cIsplSaberi ;
	VALID cIsplSaberi $ "DN" PICT "@!"
@ m_x + 17, col() + 2 SAY "obracun 0 ?" GET cNule ;
	VALID cNule $ "DN" PICT "@!"
@ m_x + 17, col() + 2 SAY "pregled ?" GET cMipView ;
	VALID cMipView $ "DN" PICT "@!"
@ m_x + 18, m_y + 2 SAY "Stampa/Export ?" GET cWinPrint PICT "@!" ;
	VALID cWinPrint $ "ES"
read

if cWinPrint == "E"
	@ m_x + 19, m_y + 2 SAY "Datum podnosenja:" GET dDatPodn
read

endif

// period za tekuci mjesec od dana do dana
dD_start := DATE()
dD_end := DATE()
_fix_d_per( cMj, cGod, @dD_start, @dD_end )

dPer := DATE()
// daj period od - do
g_per( cMj, cGod, @dPer )

clvbox()
	
ESC_BCR

BoxC()

if lastkey() == K_ESC
	return
endif

// staticke
__mj := cMj
__god := cGod

if cWinPrint == "S"
	__xml := 1
else
	__xml := 0
endif

// saberi isplate
if cIsplSaberi == "D"
	__ispl_s := 1
endif

// upisi vrijednosti
select params
WPar("i1", cPredNaz)
WPar("x9", cPredSDJ)  
WPar("x8", cDoprDod)  
WPar("x7", cTP_bol)  
WPar("x6", cBolPreko)  

select ld

// sortiraj tabelu i postavi filter
mip_sort( cRj, cGod, cMj, cRadnik, cObracun )

// nafiluj podatke obracuna
mip_fill_data( cRj, cRjDef, cGod, cMj, cRadnik, ;
	cPrimDobra, cTP_off, cTP_bol, cBolPreko, cDopr10, cDopr11, cDopr12, ;
	cDopr1X, cDopr20, cDopr21, cDopr22, cDoprDod, cDopr2D, cObracun, ;
	cNule )

// pregled tabele prije exporta
if cMipView == "D"
	mip_view()
endif

// stampa izvjestaja xml/oo3
if __xml == 1
	_xml_print()
else
	nBrZahtjeva := g_br_zaht()
	_xml_export()
	msgbeep("Obradjeno " + ALLTRIM(STR(nBrZahtjeva)) + " radnika.")
endif

return


// -------------------------------------------------------
// vraca dStart i dEnd za tekuci mjesec
// -------------------------------------------------------
static function _fix_d_per( nMj, nGod, dStart, dEnd )
local cTmp := ""

cTmp := "01"
cTmp += "."
cTmp += PADL( ALLTRIM(STR(nMj)), 2, "0" )
cTmp += "."
cTmp += ALLTRIM( STR(nGod) )

dStart := CTOD( cTmp )

cTmp := g_day( nMj )
cTmp += "."
cTmp += PADL( ALLTRIM(STR(nMj)), 2, "0" )
cTmp += "."
cTmp += ALLTRIM( STR(nGod) )

dEnd := CTOD( cTmp )

return


// ------------------------------------
// header za export
// ------------------------------------
static function _xml_head()
local cStr := '<?xml version="1.0" encoding="UTF-8"?><PaketniUvozObrazaca xmlns="urn:PaketniUvozObrazaca_V1_0.xsd">'

xml_head( .t., cStr )

return


// ----------------------------------------
// export xml-a
// ----------------------------------------
static function _xml_export()
local cMsg

if __xml == 1
	return
endif

// napuni xml fajl
_fill_e_xml()

cMsg := "Export xml datoteke zavrsen. Datoteka se nalazi#"
cMsg += "na lokaciji c:\export.xml#"
cMsg += "Potrebno promjeniti naziv xml fajla u TIN.xml gdje je#"
cMsg += "TIN id broj preduzeca, zatim zipovati fajl u TIN.zip."

msgbeep( cMsg )

return



// --------------------------------------------
// filuje xml fajl sa podacima za export
// --------------------------------------------
static function _fill_e_xml()
local nTArea := SELECT()
local nU_dn_pio
local nU_dn_zdr
local nU_dn_nez
local nU_dn_dz
local nU_prih
local nU_dopr
local nU_lodb
local nU_porez

// otvori xml za upis
open_xml( "c:\export.xml" )

// upisi header
_xml_head()

// ovo ne treba zato sto je u headeru sadrzan ovaj prvi sub-node !!!
// <paketniuvozobrazaca>
//xml_subnode("PaketniUvozObrazaca", .f.)

// <podacioposlodavcu>
xml_subnode("PodaciOPoslodavcu", .f. )

 // naziv firme
 xml_node( "JIBPoslodavca", ALLTRIM(cPredJmb) )
 xml_node( "NazivPoslodavca", strkznutf8( ALLTRIM(cPredNaz), "8" ) )
 xml_node( "BrojZahtjeva", STR( 1 ) )
 xml_node( "DatumPodnosenja", xml_date( dDatPodn ) )

xml_subnode("PodaciOPoslodavcu", .t. )

select r_export
set order to tag "1"
go top

nU_dn_pio := 0
nU_dn_zdr := 0
nU_dn_nez := 0
nU_dn_dz := 0
nU_prih := 0
nU_dopr := 0
nU_lodb := 0
nU_porez := 0


xml_subnode("Obrazac1023", .f.)

// dio1
xml_subnode("Dio1", .f.)
	
  xml_node("JibJmb", ALLTRIM(cPredJmb) )
  xml_node("Naziv", strkzn( ALLTRIM(cPredNaz), "8", "U" ) )
  xml_node("DatumUpisa", xml_date(dDatPodn) )
  xml_node("BrojUposlenih", STR( nBrZahtjeva ) )
  xml_node("PeriodOd", xml_date( dD_start ) )
  xml_node("PeriodDo", xml_date( dD_end ) )
  xml_node("SifraDjelatnosti", ALLTRIM(cPredSDJ) )

xml_subnode("Dio1", .t.)
// dio1

// dio2
xml_subnode("Dio2", .f.)

do while !EOF()
	
	if field->print == "X"
		skip 
		loop
	endif

	// po radniku
	cT_radnik := field->idradn
	
	// pronadji radnika u sifrarniku
	select radn
	seek cT_radnik

	select r_export
		
	nCnt := 0

	nR_sati := 0
	nR_satib := 0
	nR_satit := 0
	nO_prih := 0
	nBruto := 0
	nU_opor := 0
	nU_d_zdr := 0
	nU_d_pio := 0
	nU_d_nez := 0
	nU_d_iz := 0
	nU_d_pms := 0
	nUm_prih := 0
	nR_klo := 0
	nL_odb := 0
	nOsnPor := 0
	nIznPor := 0
	
	do while !EOF() .and. field->idradn == cT_radnik
		
		if field->print == "X"
			skip 
			loop
		endif
	
		cVr_ispl := field->vr_ispl
		cR_jmb := field->r_jmb
		cR_ime := field->r_ime
		dD_ispl := field->d_isp
		
		nR_sati += field->r_sati
		nR_satib += field->r_satib
		nR_satit += field->r_satit
		nBruto += field->bruto
		nO_prih += field->o_prih
		nU_opor += field->u_opor
		nU_d_zdr += field->u_d_zdr
		nU_d_pio += field->u_d_pio
		nU_d_nez += field->u_d_nez
		nU_d_iz += field->u_d_iz
		nU_d_pms += field->u_d_pms
		nUm_prih += field->um_prih
		nR_klo += field->r_klo
		nL_odb += field->l_odb
		nOsnPor += field->osn_por
		nIznPor += field->izn_por
		nR_stuv := field->r_stuv
		cR_rmj := field->r_rmj
		cR_opc := field->r_opc

		nU_dn_pio += field->u_dn_pio
		nU_dn_zdr += field->u_dn_zdr
		nU_dn_nez += field->u_dn_nez
		nU_dn_dz += field->u_dn_dz
		nU_prih += field->u_opor
		nU_dopr += field->u_d_iz
		nU_lodb += field->l_odb
		nU_porez += field->izn_por
		
		// ako je isti radnik kao i ranije
		// i bolovanje preko 42 dana
		// uzmi puni fond sati sa stavke bolovanja
		// bol_preko = "1"
		if field->bol_preko == "1"
			
			nR_sati := field->r_sati
			nR_satib := field->r_satib
			
			if nR_satiT <> 0
				nR_satiT := field->r_sati
			endif

		endif
		
		skip
	enddo

	xml_subnode("PodaciOPrihodima", .f.)

	xml_node("VrstaIsplate", ;
		strkzn( ALLTRIM(cVr_ispl), "8", "U" ))
	xml_node("Jmb", ALLTRIM(cR_jmb) )
	xml_node("ImePrezime", ;
		strkzn( ALLTRIM(cR_ime), "8", "U" ))
	xml_node("DatumIsplate", xml_date(dD_ispl) )
	xml_node("RadniSati", ;
		STR( nR_sati, 12, 2 ) ) 
	xml_node("RadniSatiBolovanje", ;
		STR( nR_satib, 12, 2 ) ) 
	xml_node("BrutoPlaca", STR( nBruto, 12, 2 ) )
	xml_node("KoristiIDrugiOporeziviPrihodi", ;
		STR( nO_prih, 12, 2 ) )
	xml_node("UkupanPrihod", ;
		STR( nU_opor, 12, 2 ) )
	xml_node("IznosPIO", ;
		STR( nU_d_pio, 12, 2 ) )
	xml_node("IznosZO", ;
		STR( nU_d_zdr, 12, 2 ) )
	xml_node("IznosNezaposlenost", ;
		STR( nU_d_nez, 12, 2 ) )
	xml_node("Doprinosi", STR( nU_d_iz , 12, 2 ) )
	xml_node("PrihodUmanjenZaDoprinose", ;
		STR( nUm_prih , 12, 2 ) )
	xml_node("FaktorLicnogOdbitka", ;
		STR( nR_klo, 12, 2 ) )
	xml_node("IznosLicnogOdbitka", STR( nL_odb, 12, 2 ) )
	xml_node("OsnovicaPoreza", STR( nOsnpor, 12, 2 ) )
	xml_node("IznosPoreza", STR( nIznpor, 12, 2 ) )

	cTmp := "false"

	if nR_satit > 0
		cTmp := "true"
	
	   xml_node("RadniSatiUT", STR( nR_satit, 12, 2) )
	   xml_node("StepenUvecanja", STR( nR_stuv, 12, 0 ) )
	   xml_node("SifraRadnogMjestaUT", ALLTRIM( cR_rmj )  )
	   xml_node("DoprinosiPIOMIOzaUT", ;
		STR( nU_d_pms, 12, 2)  )
	
	   // true or false
	   xml_node("BeneficiraniStaz", ALLTRIM( cTmp ) )

	endif		
		
	xml_node("OpcinaPrebivalista", ALLTRIM( cR_opc ) )
	
	xml_subnode("PodaciOPrihodima", .t.)
	
enddo

xml_subnode("Dio2", .t.)
// kraj dio2

// dio3
xml_subnode("Dio3", .f.)
   xml_node("PIO", STR( nU_dn_pio, 12, 2) ) 
   xml_node("ZO", STR( nU_dn_zdr, 12, 2) ) 
   xml_node("OsiguranjeOdNezaposlenosti", STR( nU_dn_nez, 12, 2) ) 
   xml_node("DodatniDoprinosiZO", STR( nU_dn_dz, 12, 2) ) 
   xml_node("Prihod", STR( nU_prih, 12, 2) ) 
   xml_node("Doprinosi", STR( nU_dopr, 12, 2) ) 
   xml_node("LicniOdbici", STR( nU_lodb, 12, 2) ) 
   xml_node("Porez", STR( nU_porez, 12, 2) ) 
xml_subnode("Dio3", .t.)
// dio3

// dio4
xml_subnode("Dio4IzjavaPoslodavca", .f.)
xml_node("JibJmbPoslodavca", ALLTRIM(cPredJmb) )
xml_node("DatumUnosa", xml_date( dDatPodn ) )
xml_node("NazivPoslodavca", strkzn( ALLTRIM(cPredNaz), "8", "U" ) )
xml_subnode("Dio4IzjavaPoslodavca", .t.)
// dio4

cOperacija := "Prijava_od_strane_poreznog_obveznika"
xml_subnode("Dokument", .f.)
  xml_node("Operacija",  cOperacija )
xml_subnode("Dokument", .t.)
	

xml_subnode("Obrazac1023", .t. )

// zatvori <PaketniUvoz...>
xml_subnode("PaketniUvozObrazaca", .t.)

select (nTArea)
return



// --------------------------------------
// vraca period 
// --------------------------------------
static function g_per( cMj, cGod, dPer )
local cTmp := ""

cTmp += PADL( ALLTRIM( STR( cMj) ) , 2, "0" ) + "." 
cTmp += ALLTRIM( STR( cGod ) )

dPer := CTOD( cTmp )

return


// ----------------------------------------
// stampa xml-a
// ----------------------------------------
static function _xml_print()
local cOdtName := ""
local cOutput := "c:\ld_out.odt"
local cJavaStart := ALLTRIM( gJavaStart )

if __xml == 0
	return
endif

if FERASE(cOutput) <> 0
	//
endif

// napuni xml fajl
_fill_xml()

cOdtName := "ld_mip.odt"

save screen to cScreen

clear screen

cJODRep := ALLTRIM( gJODRep )
cT_Path := "C:\"

if !EMPTY( gJODTemplate )
	cT_Path := ALLTRIM( gJODTemplate )
endif

// stampanje labele
cCmdLine := cJavaStart + " " + cJODRep + " " + ;
	cT_Path + cOdtName + " c:\data.xml " + cOutput

run &cCmdLine

clear screen

if !FILE(cOutput)
	msgbeep("greska pri kreiranju izlaznog fajla !")
	return
endif

cOOStart := '"' + ALLTRIM( gOOPath ) + ALLTRIM( gOOWriter ) + '"'
cOOParam := ""

// otvori report
cCmdLine := "start " + cOOStart + " " + cOOParam + " " + cOutput

run &cCmdLine

restore screen from cScreen

return


// --------------------------------------------
// filuje xml fajl sa podacima izvjestaja
// --------------------------------------------
static function _fill_xml()
local nTArea := SELECT()

// otvori xml za upis
open_xml("c:\data.xml")
// upisi header
xml_head()

xml_subnode("mip", .f.)

// naziv firme
xml_node( "p_naz", strkznutf8( ALLTRIM(cPredNaz), "8" ) )
xml_node( "p_jmb", ALLTRIM(cPredJmb) )
xml_node( "p_sdj", ALLTRIM(cPredSDJ) )
xml_node( "p_per", g_por_per() )

nU_prih := 0
nU_dopr := 0
nU_lodb := 0
nU_porez := 0
nU_pd_pio := 0
nU_pd_nez := 0
nU_pd_zdr := 0
nU_pd_dodz := 0
nZaposl := 0

select r_export
set order to tag "1"
go top

// saberi totale...
do while !EOF()
	
	if field->print == "X"
		skip
		loop
	endif

	++ nZaposl
	nU_prih += field->u_opor
	nU_dopr += field->u_d_iz
	nU_lodb += field->l_odb
	nU_porez += field->izn_por
	nU_pd_pio += field->u_dn_pio
	nU_pd_nez += field->u_dn_nez
	nU_pd_zdr += field->u_dn_zdr
	nU_pd_dodz += field->u_dn_dz

	skip
enddo

// totali
xml_node( "p_zaposl", STR(nZaposl) )
xml_node( "u_prih", STR( nU_prih, 12, 2) )
xml_node( "u_dopr", STR( nU_dopr, 12, 2) )
xml_node( "u_lodb", STR( nU_lodb, 12, 2) )
xml_node( "u_porez", STR( nU_porez, 12, 2) )
xml_node( "u_pd_pio", STR( nU_pd_pio, 12, 2) )
xml_node( "u_pd_zdr", STR( nU_pd_zdr, 12, 2) )
xml_node( "u_pd_nez", STR( nU_pd_nez, 12, 2) )
xml_node( "u_pd_dodz", STR( nU_pd_dodz, 12, 2) )

select r_export
set order to tag "1"
go top

nCnt := 0

do while !EOF()
	
	if field->print == "X"
		skip 
		loop
	endif

	// po radniku
	cT_radnik := field->idradn
	
	xml_subnode("radnik", .f.)

	xml_node("rbr", STR( ++nCnt ) )
	xml_node("visp", ALLTRIM(field->vr_ispl) )
	xml_node("r_ime", strkzn( ALLTRIM(field->r_ime), "8", "U" ) ) 
	xml_node("r_jmb", ALLTRIM(field->r_jmb) )
	xml_node("r_opc", strkzn( ALLTRIM(field->r_opc), "8", "U" ) )
	
	nR_sati := 0
	nR_satib := 0
	nR_satit := 0
	cStuv := ""
	nR_StUv := 0
	cR_rmj := ""
	nBruto := 0
	nO_prih := 0
	nU_opor := 0
	nU_d_pio := 0
	nU_d_zdr := 0
	nU_d_pms := 0
	nU_d_nez := 0
	nU_d_iz := 0
	nUm_prih := 0
	nL_odb := 0
	nR_klo := 0
	nOsn_por := 0
	nIzn_por := 0

	// provrti obracune
	do while !EOF() .and. field->idradn == cT_radnik
		
		if field->print == "X"
			skip 
			loop
		endif
	
		// za obrazac i treba zadnja isplata
		dD_isp := field->d_isp
		nR_sati += field->r_sati
		nR_satit += field->r_satit
		nR_satib += field->r_satib
		nR_stuv := field->r_stuv
		cR_rmj := field->r_rmj
		nBruto += field->bruto
		nO_prih += field->o_prih
		nU_opor += field->u_opor
		nU_d_pio += field->u_d_pio
		nU_d_zdr += field->u_d_zdr
		nU_d_nez += field->u_d_nez
		nU_d_iz += field->u_d_iz
		nUm_prih += field->um_prih
		nL_odb += field->l_odb
		nR_klo += field->r_klo
		nOsn_por += field->osn_por
		nIzn_por += field->izn_por
		nU_d_pms += field->u_d_pms

		skip
	enddo
	
	cStUv := ALLTRIM(STR(nR_Stuv,12,0)) + "/12"

	xml_node("d_isp", DTOC(dD_isp) )
	xml_node("r_sati", STR( nR_sati, 12, 2 ) ) 
	xml_node("r_satib", STR( nR_satiB, 12, 2 ) ) 
	xml_node("r_satit", STR( nR_satiT, 12, 2 ) ) 
	xml_node("r_stuv", cStUv ) 
	xml_node("bruto", STR( nBruto, 12, 2 ) )
	xml_node("o_prih", STR( nO_prih, 12, 2 ) ) 
	xml_node("u_opor", STR( nU_opor, 12, 2 ) )
	xml_node("u_d_pio", STR( nU_d_pio, 12, 2 ) )
	xml_node("u_d_nez", STR( nU_d_nez, 12, 2 ) )
	xml_node("u_d_zdr", STR( nU_d_zdr, 12, 2 ) )
	xml_node("u_d_pms", STR( nU_d_pms, 12, 2 ) )
	xml_node("u_d_iz", STR( nU_d_iz, 12, 2 ) )
	xml_node("um_prih", STR( nUm_prih, 12, 2 ) )
	xml_node("r_klo", STR( nR_klo, 5, 2 ) )
	xml_node("l_odb", STR( nL_odb, 12, 2 ) )
	xml_node("osn_por", STR( nOsn_por, 12, 2 ) )
	xml_node("izn_por", STR( nIzn_por, 12, 2 ) )
	xml_node("r_rmj", cR_rmj )
	
	xml_subnode("radnik", .t.)
		
enddo

// zatvori <mip>
xml_subnode("mip", .t.)

select (nTArea)
return


// ----------------------------------------------------------
// vraca string poreznog perioda
// ----------------------------------------------------------
static function g_por_per()

local cRet := ""

cRet += ALLTRIM(STR(__mj)) + "/" + ALLTRIM(STR(__god))  
cRet += " godine"

return cRet



// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
function mip_fill_data( cRj, cRjDef, cGod, cMj, ;
	cRadnik, cPrimDobra, cTP_off, cTP_bol, cBolPreko, cDopr10, ;
	cDopr11, cDopr12, ;
	cDopr1X, cDopr20, cDopr21, cDopr22, cDoprDod, cDopr2D, cObracun, cNule )


local i
local b
local c
local t
local o
local cPom
local nPrDobra
local nTP_off
local nTP_bol
local nTrosk := 0
local lInRS := .f.

lDatIspl := .f.
if obracuni->(fieldpos("DAT_ISPL")) <> 0
	lDatIspl := .t.
endif

select ld

do while !eof() 

	if ld_date( field->godina, field->mjesec ) < ;
		ld_date( cGod, cMj )   
		skip
		loop
	endif
	
	if ld_date( field->godina, field->mjesec ) > ;
		ld_date( cGod, cMj )   
		skip
		loop
	endif

	cT_radnik := field->idradn
	nGodina := field->godina
	nMjesec := field->mjesec

	if !EMPTY(cRadnik)
		if cT_radnik <> cRadnik
			skip
			loop
		endif
	endif
	
	cTipRada := g_tip_rada( ld->idradn, ld->idrj )
	lInRS := in_rs(radn->idopsst, radn->idopsrad) 

	// samo pozicionira bazu PAROBR na odgovarajuci zapis
	ParObr( ld->mjesec, ld->godina, IF(lViseObr, ld->obr,), ld->idrj )

	select radn
	seek cT_radnik
	
	if !( cTipRada $ " #I#N")
		select ld
		skip
		loop
	endif

	select ld

	nSati := 0
	nSatiB := 0
	nSatiT := 0
	nStUv := 0
	nBruto := 0
	nO_prih := 0
	nU_opor := 0
	nU_d_pio := 0
	nU_d_zdr := 0
	nU_dn_dz := 0
	nU_d_nez := 0
	nU_dn_pio := 0
	nU_dn_zdr := 0
	nU_dn_nez := 0
	nU_d_iz := 0
	nUm_prih := 0
	nOsn_por := 0
	nIzn_por := 0
	nU_d_pms := 0

	nTrosk := 0
	nBrDobra := 0
	nNeto := 0
	nPrDobra := 0
	nTP_off := 0
	nTP_bol := 0

	cR_ime := ""
	cR_jmb := ""
	cR_opc := ""
	cR_rmj := ""

	altd()

	do while !EOF() .and. field->idradn == cT_radnik 
	
		if ld_date( field->godina, field->mjesec ) < ;
			ld_date( cGod, cMj ) 
			skip
			loop
		endif
		
		if ld_date( field->godina, field->mjesec ) > ;
			ld_date( cGod, cMj ) 
			skip
			loop
		endif

		// radna jedinica
		cRadJed := ld->idrj
		
		select radn
	
		cR_ime := ALLTRIM(radn->ime) + " " + ALLTRIM(radn->naz)
		cR_jmb := ALLTRIM(radn->matbr)
		cR_opc := g_ops_code( radn->idopsst )
		cR_rmj := ""
		
		select ld

		// uvijek provjeri tip rada, ako ima vise obracuna
		cTipRada := g_tip_rada( ld->idradn, ld->idrj )
		cTrosk := radn->trosk
		lInRS := in_rs(radn->idopsst, radn->idopsrad) 
	
		if !( cTipRada $ " #I#N")
			skip
			loop
		endif

		ParObr( ld->mjesec, ld->godina, IF(lViseObr, ld->obr,), ;
				ld->idrj )
		
		// puni fond sati za ovaj mjesec
		nFondSati := parobr->k1

		nPrDobra := 0
		nTP_off := 0
		nTP_bol := 0

   		if !EMPTY( cPrimDobra ) 
     		   for t:=1 to 60
       			cPom := IF( t>9, STR(t,2), "0"+STR(t,1) )
       			if ld->( FIELDPOS( "I" + cPom ) ) <= 0
         			EXIT
       			endif
       			nPrDobra += IF( cPom $ cPrimDobra, LD->&("I"+cPom), 0 )
     		   next
   		endif
	
		if !EMPTY( cTP_off ) 
     		   for o:=1 to 60
       			cPom := IF( o>9, STR(o,2), "0"+STR(o,1) )
       			if ld->( FIELDPOS( "I" + cPom ) ) <= 0
         			EXIT
       			endif
       			nTP_off += IF( cPom $ cTP_off, LD->&("I"+cPom), 0 )
     		   next
   		endif
		
		if !EMPTY( cTP_bol ) 
     		   for b:=1 to 60
       			cPom := IF( b>9, STR(b,2), "0"+STR(b,1) )
       			if ld->( FIELDPOS( "S" + cPom ) ) <= 0
         			EXIT
       			endif
       			nTP_bol += IF( cPom $ cTP_bol, LD->&("S"+cPom), 0 )
     		   next
   		endif
		
		// provjeri da li ima bolovanja preko 42 dana
		// ili trudnickog bolovanja
		
		lImaBPreko := .f.

		if !EMPTY( cBolPreko ) 
     		   
		   for c:=1 to 60
       			cPom := IF( c>9, STR(c,2), "0"+STR(c,1) )
       			if ld->( FIELDPOS( "S" + cPom ) ) <= 0
         			EXIT
       			endif
       			
			if cPom $ cBolPreko .and. ;
				LD->&("S"+cPom) <> 0
				
				lImaBPreko := .t.
				exit
			endif

     		   next

   		endif
	
		nNeto := field->uneto
		nKLO := g_klo( field->ulicodb )
		nL_odb := field->ulicodb
		nSati := field->usati
		nSatiB := nTP_bol
		
		if lImaBPreko
			// uzmi puni fond sati
			nSati := nFondSati
			nSatiB := nFondSati
		endif
		
		nSatiT := 0
		
		// tipovi primanja koji ne ulaze u bruto osnovicu
		if ( nTP_off > 0 )
			nNeto := ( nNeto - nTP_off )
		endif
		
		nBruto := bruto_osn( nNeto, cTipRada, nL_odb ) 

		nMBruto := nBruto

		// prvo provjeri hoces li racunati mbruto
		if calc_mbruto()
			// minimalni bruto
			nMBruto := min_bruto( nBruto, field->usati )
		endif
		
		// ovo preskoci, nema ovdje GIP-a
		if nMBruto <= 0 .and. cNule == "N"
			select ld
			skip
			loop
		endif

		// bruto primanja u uslugama ili dobrima
		// za njih posebno izracunaj bruto osnovicu
		if nPrDobra > 0
			nBrDobra := bruto_osn( nPrDobra, cTipRada, nL_odb )
		endif
		
		nBr_benef := 0

		// beneficirani radnici
   		if UBenefOsnovu()
 			
			// sati beneficiranog su sati redovnog rada
			nSatiT := nSati

			// benef.stepen
			nStUv := benefstepen()
		
			if radn->(FIELDPOS("BEN_SRMJ")) <> 0
				cR_rmj := ALLTRIM( radn->ben_srmj )
			endif

			// promjeni parametre za benef. primanja
			cFFTmp := gBFForm
			gBFForm := STRTRAN( gBFForm, "_", "" )
 	
			nBr_Benef := bruto_osn( nNeto - ;
				IF(!EMPTY(gBFForm),&gBFForm,0), ;
				cTipRada, nL_odb )
			// vrati parametre
			gBFForm := cFFtmp
   		endif
 
		// ocitaj doprinose, njihove iznose
		nDopr10 := get_dopr( cDopr10, cTipRada )
		nDopr11 := get_dopr( cDopr11, cTipRada )
		nDopr12 := get_dopr( cDopr12, cTipRada )
		nDopr1X := get_dopr( cDopr1X, cTipRada )
		nDopr20 := get_dopr( cDopr20, cTipRada )
		nDopr21 := get_dopr( cDopr21, cTipRada )
		nDopr22 := get_dopr( cDopr22, cTipRada )

		// izracunaj doprinose
		nU_d_pio := ROUND( nMBruto * nDopr10 / 100 , 4 )
		nU_d_zdr := ROUND( nMBruto * nDopr11 / 100, 4 )
		nU_d_nez := ROUND( nMBruto * nDopr12 / 100, 4 )
		
		nU_dn_pio := ROUND( nMBruto * nDopr20 / 100 , 4 )
		nU_dn_zdr := ROUND( nMBruto * nDopr21 / 100, 4 )
		nU_dn_nez := ROUND( nMBruto * nDopr22 / 100, 4 )

		// zbirni je zbir ova tri doprinosa
		nU_d_iz := ROUND( nU_d_pio + nU_d_zdr + nU_d_nez, 4 )
		
		// dodatni doprinosi iz 
		if !EMPTY( cDoprDod )

			aD_Dopr := TokToNiz( cDoprDod, ";" )
			
			for m:=1 to LEN(aD_dopr)
				nDoprTmp := get_dopr( aD_dopr[m], cTipRada )
				if "BENEF" $ dopr->naz
					nU_d_pms += ;
					  ROUND( nBr_benef * nDoprTmp / 100, 4)
			
				else
					nU_d_pms += ;
					  ROUND( nMBruto * nDoprTmp / 100, 4)
				endif

			next
		endif
	
		// dodatni doprinosi na 
		if !EMPTY( cDopr2D )
			
			aD2_Dopr := TokToNiz( cDopr2D, ";" )
			
			for c:=1 to LEN(aD2_dopr)
				nDoprTmp := get_dopr( aD2_dopr[c], cTipRada )
				if "BENEF" $ dopr->naz
					nU_dn_dz += ;
					   ROUND( nBr_benef * nDoprTmp / 100, 4)
				else
					nU_dn_dz += ;
					   ROUND( nMBruto * nDoprTmp / 100, 4)
				endif
			next
		endif

		nUM_prih := ( nBruto - nU_d_iz )

		nPorOsn := ( nBruto - nU_d_iz ) - nL_odb

		// ako je neoporeziv radnik, nema poreza
		if !radn_oporeziv( radn->id, ld->idrj ) .or. ;
			( nBruto - nU_d_iz ) < nL_odb
			nPorOsn := 0
		endif

		// porez je ?
		nPorez := izr_porez( nPorOsn, "B" )

		select ld
	
		// na ruke je
		nNaRuke := ROUND( nBruto - nU_d_iz - nPorez + nTrosk, 2 )

		nIsplata := nNaRuke

		// da li se radi o minimalcu ?
		if cTipRada $ " #I#N#" 
			nIsplata := min_neto( nIsplata , field->usati )
		endif

		nO_prih := nBrDobra
		nU_opor := ( nBruto - nBrDobra )

		cVrstaIspl := ""
		dDatIspl := DATE()
		cObr := " "
		nMjIspl := 0
		cIsplZa := ""
		cVrstaIspl := "1"
		
		if lViseObr
			cObr := field->obr
		endif

		if lDatIspl 
			
			// radna jedinica
			cTmpRj := field->idrj
			if !EMPTY( cRJDef )
				cTmpRj := cRJDef
			endif

			dDatIspl := g_isp_date( cTmpRJ, ;
					field->godina, ;
					field->mjesec, ;
					cObr, @nMjIspl, ;
					@cIsplZa, @cVrstaIspl )
		endif

		// vrstu isplate cu uzeti iz LD->V_ISPL
		if EMPTY( field->v_ispl )
			cVrstaIspl := "1"
		else
			cVrstaIspl := ALLTRIM( field->v_ispl )
		endif

		_ins_tbl( cT_radnik, ;
			cRadJed, ;
			nGodina, ;
			nMjesec, ;
			cTipRada, ;
			cVrstaIspl, ;
			cR_ime, ;
			cR_jmb, ;
			cR_opc, ;
			dDatIspl, ;
			nSati, ;
			nSatiB, ;
			nSatiT, ;
			nStUv, ;
			nBruto, ;
			nO_prih, ;
			nU_opor, ;
			nU_d_pio, ;
			nU_d_zdr, ;
			nU_d_pms, ;
			nU_d_nez, ;
			nU_d_iz, ;
			nU_dn_pio, ;
			nU_dn_zdr, ;
			nU_dn_nez, ;
			nU_dn_dz, ;
			nUm_prih, ;
			nKLO, ;
			nL_odb, ;
			nPorOsn, ;
			nPorez, ;
			cR_rmj, ;
			lImaBPreko )
	
		select ld
		skip

	enddo

enddo

return





