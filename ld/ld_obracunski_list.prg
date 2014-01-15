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


static __mj_od
static __mj_do
static __god_od
static __god_do
static __xml := 0

// ---------------------------------------
// otvara potrebne tabele
// ---------------------------------------
function ol_o_tbl()

O_OBRACUNI
O_PAROBR
O_PARAMS
O_LD_RJ
O_RADN
O_KBENEF
O_VPOSLA
O_TIPPR
O_KRED
O_DOPR
O_POR
O_LD

return

// ---------------------------------------------------------
// sortiranje tabele LD
// ---------------------------------------------------------
function ol_sort(cRj, cGod_od, cGod_do, cMj_od, cMj_do, ;
			cRadnik, cTipRpt, cObr )
local cFilter := ""
private cObracun := cObr

if !EMPTY(cObr)
	cFilter += "obr == " + cm2str(cObr)
endif

if !EMPTY( cRj )	
	if !EMPTY( cFilter )
		cFilter += " .and. "
	endif
	cFilter += Parsiraj( cRj, "IDRJ" )
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

if EMPTY(cRadnik) 
	if cTipRpt $ "1#2"
		INDEX ON SortPrez(idradn) + STR(godina) + STR(mjesec) + idrj TO "tmpld"
	   	go top
	else
		INDEX ON STR(godina) + STR(mjesec) + SortPrez(idradn) + idrj TO "tmpld"
		go top
		seek STR( cGod_od, 4 ) + STR( cMj_od, 2 ) + cRadnik
	endif
else
	set order to tag ( TagVO("2") )
	go top
	seek STR( cGod_od, 4 ) + STR( cMj_od, 2 ) + cObracun + cRadnik
endif

return


// ---------------------------------------------
// upisivanje podatka u pomocnu tabelu za rpt
// ---------------------------------------------
static function _ins_tbl( cRadnik, cIdRj, cTipRada, cNazIspl, dDatIsplate, ;
		nMjesec, nMjisp, cIsplZa, cVrsta, ;
		nGodina, nPrihod, ;
		nPrihOst, nBruto, nMBruto, nTrosk, nDop_u_st, nDopPio, ;
		nDopZdr, nDopNez, nDop_uk, nNeto, nKLO, ;
		nLOdb, nOsn_por, nIzn_por, nUk, nUSati, nIzn1, nIzn2, ;
		nIzn3, nIzn4, nIzn5 )

local nTArea := SELECT()

O_R_EXP
select r_export
append blank

replace tiprada with cTipRada
replace idrj with cIdRj
replace idradn with cRadnik
replace naziv with cNazIspl
replace mjesec with nMjesec
replace mj_opis with ld_naziv_mjeseca( nMjIspl, nGodina, .f., .t. )
replace mj_naz with ld_naziv_mjeseca( nMjIspl, nGodina, .f., .f. )
replace mj_ispl with nMjIspl
replace ispl_za with cIsplZa
replace vr_ispl with cVrsta
replace godina with nGodina
replace datispl with dDatIsplate
replace prihod with nPrihod
replace prihost with nPrihOst
replace bruto with nBruto
replace mbruto with nMBruto
replace trosk with nTrosk
replace dop_u_st with nDop_u_st
replace dop_pio with nDopPio
replace dop_zdr with nDopZdr
replace dop_nez with nDopNez
replace dop_uk with nDop_uk
replace neto with nNeto
replace klo with nKlo
replace l_odb with nLOdb
replace osn_por with nOsn_Por
replace izn_por with nIzn_Por
replace ukupno with nUk
replace sati with nUSati

if nIzn1 <> nil
	replace tp_1 with nIzn1
endif
if nIzn2 <> nil
	replace tp_2 with nIzn2
endif
if nIzn3 <> nil
	replace tp_3 with nIzn3
endif
if nIzn4 <> nil
	replace tp_4 with nIzn4
endif
if nIzn5 <> nil
	replace tp_5 with nIzn5
endif


select (nTArea)
return



// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
function ol_tmp_tbl()
local aDbf := {}

AADD(aDbf,{ "IDRADN", "C", 6, 0 })
AADD(aDbf,{ "IDRJ", "C", 2, 0 })
AADD(aDbf,{ "TIPRADA", "C", 1, 0 })
AADD(aDbf,{ "NAZIV", "C", 15, 0 })
AADD(aDbf,{ "DATISPL", "D", 8, 0 })
AADD(aDbf,{ "MJESEC", "N", 2, 0 })
AADD(aDbf,{ "MJ_NAZ", "C", 15, 0 })
AADD(aDbf,{ "MJ_OPIS", "C", 15, 0 })
AADD(aDbf,{ "MJ_ISPL", "N", 2, 0 })
AADD(aDbf,{ "ISPL_ZA", "C", 50, 0 })
AADD(aDbf,{ "VR_ISPL", "C", 50, 0 })
AADD(aDbf,{ "GODINA", "N", 4, 0 })
AADD(aDbf,{ "PRIHOD", "N", 12, 2 })
AADD(aDbf,{ "PRIHOST", "N", 12, 2 })
AADD(aDbf,{ "BRUTO", "N", 12, 2 })
AADD(aDbf,{ "MBRUTO", "N", 12, 2 })
AADD(aDbf,{ "TROSK", "N", 12, 2 })
AADD(aDbf,{ "DOP_U_ST", "N", 12, 2 })
AADD(aDbf,{ "DOP_PIO", "N", 12, 2 })
AADD(aDbf,{ "DOP_ZDR", "N", 12, 2 })
AADD(aDbf,{ "DOP_NEZ", "N", 12, 2 })
AADD(aDbf,{ "DOP_UK", "N", 12, 4 })
AADD(aDbf,{ "NETO", "N", 12, 2 })
AADD(aDbf,{ "KLO", "N", 5, 2 })
AADD(aDbf,{ "L_ODB", "N", 12, 2 })
AADD(aDbf,{ "OSN_POR", "N", 12, 2 })
AADD(aDbf,{ "IZN_POR", "N", 12, 2 })
AADD(aDbf,{ "UKUPNO", "N", 12, 2 })
AADD(aDbf,{ "SATI", "N", 12, 2 })
AADD(aDbf,{ "TP_1", "N", 12, 2 })
AADD(aDbf,{ "TP_2", "N", 12, 2 })
AADD(aDbf,{ "TP_3", "N", 12, 2 })
AADD(aDbf,{ "TP_4", "N", 12, 2 })
AADD(aDbf,{ "TP_5", "N", 12, 2 })

t_exp_create( aDbf )

O_R_EXP
// index on ......
index on idradn + STR(godina,4) + STR(mjesec,2) tag "1"

return


// ------------------------------------------
// obracunski list radnika
// ------------------------------------------
function r_obr_list()
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
local cTipRpt := "1"
local cTP_off := SPACE(100)
local cObracun := gObracun
local cWinPrint := "E"
local nOper := 1

// kreiraj pomocnu tabelu
ol_tmp_tbl()

cIdRj := gRj
cMj_od := gMjesec
cMj_do := gMjesec
cGod_od := gGodina
cGod_do := gGodina

cPredNaz := SPACE(50)
cPredAdr := SPACE(50)
cPredJMB := SPACE(13)

nPorGodina := 2009
cOperacija := "Novi"
dDatUnosa := DATE()
dDatPodnosenja := DATE()
nBrZahtjeva := 1

// otvori tabele
ol_o_tbl()

// upisi parametre...
cPredNaz := PADR( fetch_metric( "obracun_plata_preduzece_naziv", NIL, cPredNaz ), 100 )
cPredAdr := PADR( fetch_metric( "obracun_plata_preduzece_adresa", NIL, cPredAdr ), 100 )
cPredJMB := PADR( fetch_metric( "obracun_plata_preduzece_id_broj", NIL, cPredJMB ), 13 )

Box("#OBRACUNSKI LISTOVI RADNIKA", 17, 75)

@ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
@ m_x + 2, m_y + 2 SAY "Period od:" GET cMj_od pict "99"
@ m_x + 2, col() + 1 SAY "/" GET cGod_od pict "9999"
@ m_x + 2, col() + 1 SAY "do:" GET cMj_do pict "99" 
@ m_x + 2, col() + 1 SAY "/" GET cGod_do pict "9999"

if lViseObr
  	@ m_x+2,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif

@ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
	VALID EMPTY(cRadnik) .or. P_RADN(@cRadnik)
@ m_x + 5, m_y + 2 SAY "    Isplate u usl. ili dobrima:" ;
	GET cPrimDobra pict "@S30"
@ m_x + 6, m_y + 2 SAY "Tipovi koji ne ulaze u obrazac:" ;
	GET cTP_off pict "@S30"
@ m_x + 7, m_y + 2 SAY "   Doprinos iz pio: " GET cDopr10 
@ m_x + 8, m_y + 2 SAY "   Doprinos iz zdr: " GET cDopr11
@ m_x + 9, m_y + 2 SAY "   Doprinos iz nez: " GET cDopr12
@ m_x + 10, m_y + 2 SAY "Doprinos iz ukupni: " GET cDopr1X

@ m_x + 12, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz pict "@S30"
@ m_x + 12, col()+1 SAY "JID: " GET cPredJMB
@ m_x + 13, m_y + 2 SAY "Adresa: " GET cPredAdr pict "@S30"

@ m_x + 15, m_y + 2 SAY "(1) OLP-1021 / (2) GIP-1022 / (3,4) AOP:" GET cTipRpt ;
	VALID cTipRpt $ "1234" 

@ m_x + 15, col() + 2 SAY "def.rj" GET cRJDef 

@ m_x + 15, col() + 2 SAY "st./exp.(S/E)?" GET cWinPrint ;
	VALID cWinPrint $ "SE" PICT "@!" 

read

dPerOd := DATE()
dPerDo := DATE()

// daj period od - do
g_per_oddo( cMj_od, cGod_od, cMj_do, cGod_do, @dPerOd, @dPerDo )

if cWinPrint == "E"
	
	nPorGodina := cGod_do

	@ m_x + 16, m_y + 2 SAY "P.godina" GET nPorGodina ;
		PICT "9999"
	@ m_x + 16, col() + 2 SAY "Dat.podnos." GET dDatPodnosenja 
	@ m_x + 16, col() + 2 SAY "Dat.unosa" GET dDatUnosa 

	@ m_x + 17, m_y + 2 SAY "operacija: 1 (novi) 2 (izmjena) 3 (brisanje)" ;
		GET nOper PICT "9"
	
	read
endif

cOperacija := g_operacija( nOper )

clvbox()
	
ESC_BCR

BoxC()

if lastkey() == K_ESC
	return
endif

// staticke
__mj_od := cMj_od
__mj_do := cMj_do
__god_od := cGod_od
__god_do := cGod_do

if cWinPrint == "S"
	__xml := 1
else
	__xml := 0
endif

// upisi parametre...
set_metric( "obracun_plata_preduzece_naziv", NIL, ALLTRIM( cPredNaz ) )
set_metric( "obracun_plata_preduzece_adresa", NIL, ALLTRIM( cPredAdr ) )
set_metric( "obracun_plata_preduzece_id_broj", NIL, cPredJMB )

select ld

// sortiraj tabelu i postavi filter
ol_sort( cRj, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, cTipRpt, cObracun )

// nafiluj podatke obracuna
ol_fill_data( cRj, cRjDef, cGod_od, cGod_do, cMj_od, cMj_do, cRadnik, ;
	cPrimDobra, cTP_off, cDopr10, cDopr11, cDopr12, cDopr1X, cTipRpt, ;
	cObracun )

// stampa izvjestaja xml/oo3

if __xml == 1
	_xml_print( cTipRpt )
else
	nBrZahtjeva := g_br_zaht()
	_xml_export( cTipRpt, cMj_od, cGod_od )
	msgbeep("Obradjeno " + ALLTRIM(STR(nBrZahtjeva)) + " zahtjeva.")
endif

return


// --------------------------------------
// vraca period od-do
// --------------------------------------
static function g_per_oddo( cMj_od, cGod_od, cMj_do, cGod_do, ;
	dPerOd, dPerDo )
local cTmp := ""

cTmp += "01" + "."
cTmp += PADL( ALLTRIM( STR( cMj_od) ) , 2, "0" ) + "." 
cTmp += ALLTRIM( STR( cGod_od ) )

dPerOd := CTOD( cTmp )

cTmp := g_day( cMj_do ) + "."
cTmp += PADL( ALLTRIM( STR( cMj_do ) ) , 2, "0" ) + "." 
cTmp += ALLTRIM( STR( cGod_do ) )

dPerDo := CTOD( cTmp )

return

// ------------------------------------------
// vraca koliko dana ima u mjesecu
// ------------------------------------------
function g_day( nMonth )
local cDay := "31"
do case
	case nMonth = 1
		cDay := "31"
	case nMonth = 2
		cDay := "28"
	case nMonth = 3
		cDay := "31"
	case nMonth = 4
		cDay := "30"
	case nMonth = 5
		cDay := "31"
	case nMonth = 6
		cDay := "30"
	case nMonth = 7
		cDay := "31"
	case nMonth = 8
		cDay := "31"
	case nMonth = 9
		cDay := "30"
	case nMonth = 10
		cDay := "31"
	case nMonth = 11
		cDay := "30"
	case nMonth = 12
		cDay := "31"

endcase

return cDay



// -------------------------------------
// vraca vrstu isplate
// -------------------------------------
function g_v_ispl( cId )
local cIspl := "Plata"

if cId == "1"
	cIspl := "Plata"
elseif cId == "2"
	cIspl := "Plata + ostalo"
endif

return cIspl



static function g_operacija( nOper )
local cOperacija := ""

if nOper = 1
	cOperacija := "Novi"
elseif nOper = 2
	cOperacija := "Izmjena"
elseif nOper = 3
	cOperacija := "Brisanje"
else
	cOperacija := "Novi"
endif

return cOperacija 


// -----------------------------------------------
// vraca broj zahtjeva
// -----------------------------------------------
function g_br_zaht()
local nTArea := SELECT()
local cT_radnik 
local nCnt
local nRet := 0

select r_export
set order to tag "1"
go top

do while !EOF()
	
	cT_radnik := field->idradn
	nCnt := 0

	do while !EOF() .and. field->idradn == cT_radnik
		nCnt := 1
		skip
	enddo
	
	nRet += nCnt

enddo

select (nTArea)
return nRet



// ----------------------------------------
// export xml-a
// ----------------------------------------
static function _xml_export( cTip, mjesec, godina )
local cMsg
local _id_br, _naziv, _adresa, _mjesto
local _lokacija, _cre, _error, _a_files
local _output_file := ""

if __xml == 1
	return
endif

if cTip == "1"
	return
endif

_id_br  := fetch_metric( "org_id_broj", NIL, PADR( "<POPUNI>", 13 ))
_naziv  := fetch_metric( "org_naziv", NIL, PADR( "<POPUNI naziv>", 100 ))
_adresa := fetch_metric( "org_adresa", NIL, PADR( "<POPUNI adresu>", 100 ))
_mjesto   := fetch_metric( "org_mjesto", NIL, PADR( "<POPUNI mjesto>", 100 ))

Box(, 6, 70)
  @ m_x + 1, m_y + 2 SAY " - Firma/Organizacija - "
  @ m_x + 3, m_y + 2 SAY " Id broj: " GET _id_br
  @ m_x + 4, m_y + 2 SAY "   Naziv: " GET _naziv PICT "@S50"
  @ m_x + 5, m_y + 2 SAY "  Adresa: " GET _adresa PICT "@S50"
  @ m_x + 6, m_y + 2 SAY "  Mjesto: " GET _mjesto PICT "@S50"
  READ 
BoxC()

set_metric( "org_id_broj", NIL, _id_br)
set_metric( "org_naziv", NIL, _naziv)
set_metric( "org_adresa", NIL, _adresa)
set_metric( "org_mjesto", NIL, _mjesto)

if LASTKEY() == K_ESC
   return .f.
endif

_id_br := ALLTRIM(_id_br)

_lokacija := _path_quote( my_home() + "export" + SLASH )

if DirChange(_lokacija) != 0

   _cre := MakeDir (_lokacija)
   if _cre != 0
       MsgBeep("kreiranje " + _lokacija + " neuspjesno ?!")
       log_write("dircreate err:" + _lokacija, 6)
       return .f.
   endif

endif

DirChange(_lokacija)

// napuni xml fajl
_fill_e_xml( _id_br + ".xml" )

cMsg := "Generacija obrasca završena.#"
cMsg += "Fajl se nalazi na desktopu u folderu F18_dokumenti"

MsgBeep(cMsg)

DirChange(my_home())

close all

_output_file := "gip_" + ALLTRIM( my_server_params()["database"] ) + "_" + ALLTRIM( STR( mjesec ) ) + "_" + ALLTRIM( STR( godina ) ) + ".xml" 

// kopiraj fajl na desktop
f18_copy_to_desktop( _lokacija, _id_br + ".xml", _output_file )

return


// ----------------------------------------
// stampa xml-a
// ----------------------------------------
static function _xml_print( tip )
local _template
local _xml_file := my_home() + "data.xml"

if __xml == 0
	return
endif

// napuni xml fajl
_fill_xml( tip, _xml_file )

do case
	case tip == "1"
		_template := "ld_olp.odt"
	case tip == "2"
		_template := "ld_gip.odt"
	case tip == "3"
		_template := "ld_aop.odt"
	case tip == "4"
		_template := "ld_aop2.odt"
endcase

// generisi report
if f18_odt_generate( _template, _xml_file )
    f18_odt_print()
endif


return


// ------------------------------------
// header za export
// ------------------------------------
static function _xml_head()
local cStr := '<?xml version="1.0" encoding="UTF-8"?><PaketniUvozObrazaca xmlns="urn:PaketniUvozObrazaca_V1_0.xsd">'

xml_head( .t., cStr )

return



// --------------------------------------------
// filuje xml fajl sa podacima za export
// --------------------------------------------
static function _fill_e_xml( file_name )
local nTArea := SELECT()
local nT_prih := 0
local nT_pros := 0
local nT_bruto := 0
local nT_neto := 0
local nT_poro := 0
local nT_pori := 0
local nT_dop_s := 0
local nT_dop_u := 0
local nT_d_zdr := 0
local nT_d_pio := 0
local nT_d_nez := 0
local nT_bbd := 0
local nT_klo := 0
local nT_lodb := 0

// otvori xml za upis
open_xml( file_name )

// upisi header
_xml_head()

// ovo ne treba zato sto je u headeru sadrzan ovaj prvi sub-node !!!
// <paketniuvozobrazaca>
//xml_subnode("PaketniUvozObrazaca", .f.)

// <podacioposlodavcu>
xml_subnode("PodaciOPoslodavcu", .f. )

 // naziv firme
 xml_node( "JIBPoslodavca", ALLTRIM(cPredJmb) )
 xml_node( "NazivPoslodavca", to_xml_encoding( ALLTRIM(cPredNaz) ) )
 xml_node( "BrojZahtjeva", STR( nBrZahtjeva ) )
 xml_node( "DatumPodnosenja", xml_date( dDatPodnosenja ) )

xml_subnode("PodaciOPoslodavcu", .t. )

select r_export
set order to tag "1"
go top

do while !EOF()
	
	// po radniku
	cT_radnik := field->idradn
	
	// pronadji radnika u sifrarniku
	select radn
	seek cT_radnik

	select r_export

	xml_subnode("Obrazac1022", .f.)

	xml_subnode("Dio1PodaciOPoslodavcuIPoreznomObvezniku", .f.)
	
	 xml_node("JIBJMBPoslodavca", ALLTRIM(cPredJmb) )
 	 xml_node("Naziv", to_xml_encoding( ALLTRIM(cPredNaz) ) )
 	 xml_node("AdresaSjedista", to_xml_encoding( ALLTRIM( cPredAdr ) ) )
 	 xml_node("JMBZaposlenika", ALLTRIM( radn->matbr ) )
 	 xml_node("ImeIPrezime", to_xml_encoding( ALLTRIM(radn->ime) + " " + ;
	 	ALLTRIM(radn->naz) ) )
	 xml_node("AdresaPrebivalista", to_xml_encoding( ALLTRIM(radn->streetname) + ;
		" " + ALLTRIM(radn->streetnum) ) )
	 xml_node("PoreznaGodina", STR( nPorGodina ) )
	 
	 xml_node("PeriodOd", xml_date( dPerOd ) )
	 xml_node("PeriodDo", xml_date( dPerDo ) )

	xml_subnode("Dio1PodaciOPoslodavcuIPoreznomObvezniku", .t.)
	
	xml_subnode("Dio2PodaciOPrihodimaDoprinosimaIPorezu", .f.)
	
	nT_prih := 0
	nT_pros := 0
	nT_bruto := 0
	nT_neto := 0
	nT_poro := 0
	nT_pori := 0
	nT_dop_s := 0
	nT_dop_u := 0
	nT_d_zdr := 0
	nT_d_pio := 0
	nT_d_nez := 0
	nT_bbd := 0
	nT_klo := 0
	nT_lodb := 0
		
	nCnt := 0

	do while !EOF() .and. field->idradn == cT_radnik
		
		// ukupni doprinosi
		replace field->dop_uk with field->dop_pio + ;
			field->dop_nez + field->dop_zdr

		replace field->osn_por with ( field->bruto - field->dop_uk ) - ;
			field->l_odb
	
		// ako je neoporeziv radnik, nema poreza
		if !radn_oporeziv( field->idradn, field->idrj ) .or. ;
			field->osn_por < 0 
			replace field->osn_por with 0
		endif

		if field->osn_por > 0
			replace field->izn_por with field->osn_por * 0.10
		else
			replace field->izn_por with 0
		endif

		replace field->neto with (field->bruto - field->dop_uk) - ;
			field->izn_por
	
		if field->tiprada $ " #I#N#" 
			replace field->neto with ;
				min_neto( field->neto , field->sati )
		endif

		
		xml_subnode("PodaciOPrihodimaDoprinosimaIPorezu", .f.)

		xml_node("Mjesec", STR( field->mj_ispl ) )
		xml_node("IsplataZaMjesecIGodinu", ;
			to_xml_encoding( ALLTRIM(field->ispl_za) ) )
		xml_node("VrstaIsplate", ;
			to_xml_encoding( ALLTRIM(field->vr_ispl) ))
		xml_node("IznosPrihodaUNovcu", ;
			STR( field->prihod, 12, 2 ) ) 
		xml_node("IznosPrihodaUStvarimaUslugama", ;
			STR( field->prihost, 12, 2 ) )
		xml_node("BrutoPlaca", STR( field->bruto, 12, 2 ) )
		xml_node("IznosZaPenzijskoInvalidskoOsiguranje", ;
			STR( field->dop_pio, 12, 2 ) )
		xml_node("IznosZaZdravstvenoOsiguranje", ;
			STR( field->dop_zdr, 12, 2 ) )
		xml_node("IznosZaOsiguranjeOdNezaposlenosti", ;
			STR( field->dop_nez, 12, 2 ) )
		xml_node("UkupniDoprinosi", STR( field->dop_uk , 12, 2 ) )
		xml_node("PlacaBezDoprinosa", ;
			STR( field->bruto - field->dop_uk , 12, 2 ) )
		
		xml_node("FaktorLicnihOdbitakaPremaPoreznojKartici", ;
			STR( field->klo, 12, 2 ) )
		
		xml_node("IznosLicnogOdbitka", STR( field->l_odb, 12, 2 ) )
		
		xml_node("OsnovicaPoreza", STR( field->osn_por, 12, 2 ) )
		xml_node("IznosUplacenogPoreza", STR( field->izn_por, 12, 2 ) )
		
		xml_node("NetoPlaca", STR( field->neto, 12, 2 ) )
		xml_node("DatumUplate", xml_date( field->datispl ) )
		
		//xml_node("opis", to_xml_encoding( ALLTRIM( field->naziv ) ) )
		//xml_node("uk", STR( field->ukupno, 12, 2 ) )

		xml_subnode("PodaciOPrihodimaDoprinosimaIPorezu", .t.)
		
		nT_prih += field->prihod
		nT_pros += field->prihost
		nT_bruto += field->bruto
		nT_neto += field->neto
		nT_poro += field->osn_por
		nT_pori += field->izn_por
		nT_dop_s += field->dop_u_st
		nT_dop_u += field->dop_uk
		nT_d_zdr += field->dop_zdr
		nT_d_pio += field->dop_pio
		nT_d_nez += field->dop_nez
		nT_bbd += ( field->bruto - field->dop_uk )
		nT_klo += field->klo
		nT_lodb += field->l_odb

		skip
	enddo

	xml_subnode("Ukupno", .f.)

	xml_node("IznosPrihodaUNovcu", STR( nT_prih, 12, 2 ) )
	xml_node("IznosPrihodaUStvarimaUslugama", ;
		STR( nT_pros, 12, 2 ) )

	xml_node("BrutoPlaca", STR( nT_bruto, 12, 2 ) )
	xml_node("IznosZaPenzijskoInvalidskoOsiguranje", ;
		STR( nT_d_pio, 12, 2 ) )

	xml_node("IznosZaZdravstvenoOsiguranje", ;
		STR( nT_d_zdr, 12, 2 ) )

	xml_node("IznosZaOsiguranjeOdNezaposlenosti", ;
		STR( nT_d_nez, 12, 2 ) )

	xml_node("UkupniDoprinosi", STR( nT_dop_u, 12, 2 ) )
	xml_node("PlacaBezDoprinosa", STR( nT_bbd, 12, 2 ) )
	xml_node("IznosLicnogOdbitka", STR( nT_lodb, 12, 2 ) )
	xml_node("OsnovicaPoreza", STR( nT_poro, 12, 2 ) )
	xml_node("IznosUplacenogPoreza", STR( nT_pori, 12, 2 ) )
	xml_node("NetoPlaca", STR( nT_neto, 12, 2 ) )

	xml_subnode("Ukupno", .t.)

	xml_subnode("Dio2PodaciOPrihodimaDoprinosimaIPorezu", .t.)

	xml_subnode("Dio3IzjavaPoslodavcaIsplatioca", .f.)
	 xml_node("JIBJMBPoslodavca", ALLTRIM(cPredJmb) )
 	 xml_node("DatumUnosa", xml_date( dDatUnosa ) )
 	 xml_node("NazivPoslodavca", to_xml_encoding( ALLTRIM(cPredNaz) ) )
	xml_subnode("Dio3IzjavaPoslodavcaIsplatioca", .t.)

	xml_subnode("Dokument", .f.)
	  xml_node("Operacija", cOperacija )
	xml_subnode("Dokument", .t.)
	

	xml_subnode("Obrazac1022", .t. )

enddo

// zatvori <PaketniUvoz...>
xml_subnode("PaketniUvozObrazaca", .t.)

// zatvori xml fajl
close_xml()

select (nTArea)
return



// --------------------------------------------
// filuje xml fajl sa podacima izvjestaja
// --------------------------------------------
static function _fill_xml( cTip, xml_file )
local nTArea := SELECT()
local nT_prih := 0
local nT_pros := 0
local nT_bruto := 0
local nT_mbruto := 0
local nT_trosk := 0
local nT_bbtr := 0
local nT_bbd := 0
local nT_neto := 0
local nT_poro := 0
local nT_pori := 0
local nT_dop_s := 0
local nT_dop_u := 0
local nT_d_zdr := 0
local nT_d_pio := 0
local nT_d_nez := 0
local nT_klo := 0
local nT_lodb := 0

// otvori xml za upis
open_xml( xml_file )
// upisi header
xml_head()

xml_subnode("rpt", .f.)

// naziv firme
xml_node( "p_naz", to_xml_encoding( ALLTRIM(cPredNaz) ) )
xml_node( "p_adr", to_xml_encoding( ALLTRIM(cPredAdr) ) )
xml_node( "p_jmb", ALLTRIM(cPredJmb) )
xml_node( "p_per", g_por_per() )

select r_export
set order to tag "1"
go top

do while !EOF()
	
	// po radniku
	cT_radnik := field->idradn
	
	// pronadji radnika u sifrarniku
	select radn
	seek cT_radnik

	select r_export

	xml_subnode("radnik", .f.)

	xml_node("ime", to_xml_encoding( ALLTRIM(radn->ime) + ;
		" (" + ALLTRIM(radn->imerod) + ;
		") " + ALLTRIM(radn->naz) ) )

	xml_node("mb", ALLTRIM(radn->matbr) )
	
	xml_node("adr", to_xml_encoding( ALLTRIM(radn->streetname) + ;
		" " + ALLTRIM(radn->streetnum) ) )

	nT_prih := 0
	nT_pros := 0
	nT_bruto := 0
	nT_mbruto := 0
	nT_trosk := 0
	nT_bbtr := 0
	nT_bbd := 0
	nT_neto := 0
	nT_poro := 0
	nT_pori := 0
	nT_dop_s := 0
	nT_dop_u := 0
	nT_d_zdr := 0
	nT_d_pio := 0
	nT_d_nez := 0
	nT_klo := 0
	nT_lodb := 0
		
	nCnt := 0

	do while !EOF() .and. field->idradn == cT_radnik

		// ukupni doprinosi
		replace field->dop_uk with field->dop_pio + ;
			field->dop_nez + field->dop_zdr

		if cTip $ "3#4"
			replace field->osn_por with ;
				( field->mbruto - field->dop_zdr )
		else
			replace field->osn_por with ;
				( field->bruto - field->dop_uk ) - ;
				field->l_odb
		endif

		// ako je neoporeziv radnik, nema poreza
		if !radn_oporeziv( field->idradn, field->idrj ) .or. ;
			field->osn_por < 0 
			replace field->osn_por with 0
		endif

		if field->osn_por > 0
			replace field->izn_por with field->osn_por * 0.10
		else
			replace field->izn_por with 0
		endif

		if cTip $ "3#4"
			replace field->neto with ;
				((field->mbruto - field->dop_zdr) - ;
				field->izn_por ) + field->trosk
		else
			replace field->neto with ;
				(field->bruto - field->dop_uk) - ;
				field->izn_por
		endif
	
		if (cTip <> "3" .or. cTip <> "4" ) .and. ;
			field->tiprada $ " #I#N#" 
			replace field->neto with ;
				min_neto( field->neto , field->sati )
		endif

		xml_subnode("obracun", .f.)

		xml_node("rbr", STR( ++nCnt ) )
		xml_node("pl_opis", to_xml_encoding( ALLTRIM( field->mj_opis ) ) )
		xml_node("mjesec", STR( field->mj_ispl ) )
		xml_node("godina", STR( field->godina ) )
		xml_node("isp_m", to_xml_encoding( ALLTRIM(field->mj_naz) ) )
		xml_node("isp_z", to_xml_encoding( ALLTRIM(field->ispl_za) ) )
		xml_node("isp_v", to_xml_encoding( g_v_ispl(ALLTRIM(field->vr_ispl))))
		xml_node("prihod", STR( field->prihod, 12, 2 ) ) 
		xml_node("prih_o", STR( field->prihost, 12, 2 ) )
		xml_node("bruto", STR( field->bruto, 12, 2 ) )
		xml_node("trosk", STR( field->trosk, 12, 2 ) )
		xml_node("bbtr", STR( field->bruto - field->trosk, 12, 2 ) )
		xml_node("do_us", STR( field->dop_u_st, 12, 2 ) )
		xml_node("do_uk", STR( field->dop_uk, 12, 2 ) )
		xml_node("do_pio", STR( field->dop_pio, 12, 2 ) )
		xml_node("do_zdr", STR( field->dop_zdr, 12, 2 ) )
		xml_node("do_nez", STR( field->dop_nez, 12, 2 ) )
		xml_node("bbd", STR( field->bruto - field->dop_uk, 12, 2 ) )
		xml_node("neto", STR( field->neto, 12, 2 ) )
		xml_node("klo", STR( field->klo, 12, 2 ) )
		xml_node("l_odb", STR( field->l_odb, 12, 2 ) )
		xml_node("p_osn", STR( field->osn_por, 12, 2 ) )
		xml_node("p_izn", STR( field->izn_por, 12, 2 ) )
		xml_node("uk", STR( field->ukupno, 12, 2 ) )
		xml_node("d_isp", DTOC( field->datispl ) )
		xml_node("opis", to_xml_encoding( ALLTRIM( field->naziv ) ) )

		xml_subnode("obracun", .t.)
		
		nT_prih += field->prihod
		nT_pros += field->prihost
		nT_bruto += field->bruto
		nT_trosk += field->trosk
		nT_bbtr += ( field->bruto - field->trosk )
		nT_bbd += ( field->bruto - field->dop_uk )
		nT_neto += field->neto
		nT_poro += field->osn_por
		nT_pori += field->izn_por
		nT_dop_s += field->dop_u_st
		nT_dop_u += field->dop_uk
		nT_d_zdr += field->dop_zdr
		nT_d_pio += field->dop_pio
		nT_d_nez += field->dop_nez
		nT_klo += field->klo
		nT_lodb += field->l_odb

		skip
	enddo

	// upisi totale za radnika
	xml_subnode("total", .f.)

	xml_node("prihod", STR( nT_prih, 12, 2 ) )
	xml_node("prih_o", STR( nT_pros, 12, 2 ) )
	xml_node("bruto", STR( nT_bruto, 12, 2 ) )
	xml_node("trosk", STR( nT_trosk, 12, 2 ) )
	xml_node("bbtr", STR( nT_bbtr, 12, 2 ) )
	xml_node("bbd", STR( nT_bbd, 12, 2 ) )
	xml_node("neto", STR( nT_neto, 12, 2 ) )
	xml_node("p_izn", STR( nT_pori, 12, 2 ) )
	xml_node("p_osn", STR( nT_poro, 12, 2 ) )
	xml_node("do_st", STR( nT_dop_s, 12, 2 ) )
	xml_node("do_uk", STR( nT_dop_u, 12, 2 ) )
	xml_node("do_pio", STR( nT_d_pio, 12, 2 ) )
	xml_node("do_zdr", STR( nT_d_zdr, 12, 2 ) )
	xml_node("do_nez", STR( nT_d_nez, 12, 2 ) )
	xml_node("klo", STR( nT_klo, 12, 2 ) )
	xml_node("l_odb", STR( nT_lodb, 12, 2 ) )

	xml_subnode("total", .t.)
	
	// zatvori radnika
	xml_subnode("radnik", .t.)

enddo

// zatvori <rpt>
xml_subnode("rpt", .t.)

select (nTArea)

// zatvori xml fajl za upis
close_xml()

return


// ----------------------------------------------------------
// vraca string poreznog perioda
// ----------------------------------------------------------
static function g_por_per()

local cRet := ""

cRet += ALLTRIM(STR(__mj_od)) + "/" + ALLTRIM(STR(__god_od))  
cRet += " - "
cRet += ALLTRIM(STR(__mj_do)) + "/" + ALLTRIM(STR(__god_do))
cRet += " godine"

return cRet



// -------------------------------------------
// vraca string sa datumom uslovskim
// -------------------------------------------
function ld_date( nGod, nMj )
local cRet

cRet := PADR( ALLTRIM( STR( nGod ) ), 4 ) + ;
	PADL( ALLTRIM( STR( nMj ) ) , 2, "0" )

return cRet



// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
function ol_fill_data( cRj, cRjDef, cGod_od, cGod_do, cMj_od, cMj_do, ;
	cRadnik, cPrimDobra, cTP_off, cDopr10, cDopr11, cDopr12, cDopr1X, ;
	cRptTip, cObracun, cTp1, cTp2, cTp3, cTp4, cTp5 )
local i
local cPom
local nPrDobra
local nTP_off
local nTp1 := 0
local nTp2 := 0
local nTp3 := 0
local nTp4 := 0
local nTp5 := 0
local nTrosk := 0
local nIDopr10 := 0000.00000
local nIDopr11 := 0000.00000
local nIDopr12 := 0000.00000
local nIDopr1X := 0000.00000 
local lInRS := .f.

// dodatni tipovi primanja
if cTp1 == nil
	cTp1 := ""
endif
if cTp2 == nil
	cTp2 := ""
endif
if cTp3 == nil
	cTp3 := ""
endif
if cTp4 == nil
	cTp4 := ""
endif
if cTp5 == nil
	cTp5 := ""
endif

lDatIspl := .f.
if obracuni->(fieldpos("DAT_ISPL")) <> 0
	lDatIspl := .t.
endif

select ld

do while !eof() 

	if ld_date( field->godina, field->mjesec ) < ;
		ld_date( cGod_od, cMj_od )   
		skip
		loop
	endif

	if ld_date( field->godina, field->mjesec ) > ;
		ld_date( cGod_do, cMj_do )
		skip
		loop
	endif

	cT_radnik := field->idradn

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
	
	if cRptTip $ "3#4"
		if ( cTipRada $ " #I#N")
			select ld
			skip
			loop
		endif
	else
		if !( cTipRada $ " #I#N")
			select ld
			skip
			loop
		endif
	endif

	select ld

	nBruto := 0
	nTrosk := 0
	nBrDobra := 0
	nDoprStU := 0
	nDopPio := 0
	nDopZdr := 0
	nDopNez := 0
	nDopUk := 0
	nNeto := 0
	nPrDobra := 0
	nTP_off := 0
	nTp1 := 0
	nTp2 := 0
	nTp3 := 0
	nTp4 := 0
	nTp5 := 0

	do while !EOF() .and. field->idradn == cT_radnik 
	
		if ld_date( field->godina, field->mjesec ) < ;
			ld_date( cGod_od, cMj_od ) 
			skip
			loop
		endif

		if ld_date( field->godina, field->mjesec ) > ;
			ld_date( cGod_do, cMj_do )
			skip
			loop
		endif
	
		// radna jedinica
		cRadJed := ld->idrj

		// uvijek provjeri tip rada, ako ima vise obracuna
		cTipRada := g_tip_rada( ld->idradn, ld->idrj )
		cTrosk := radn->trosk
		lInRS := in_rs(radn->idopsst, radn->idopsrad) 
	
		if cRptTip $ "3#4"
			if ( cTipRada $ " #I#N")
				skip
				loop
			endif
		else
			if !( cTipRada $ " #I#N")
				skip
				loop
			endif
		endif

		ParObr( ld->mjesec, ld->godina, IF(lViseObr, ld->obr,), ;
				ld->idrj )
		
		nPrDobra := 0
		nTP_off := 0

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
	
		// ostali tipovi primanja
		if !EMPTY( cTp1 )
			nTp1 := LD->&( "I" + cTp1 )
		endif
		if !EMPTY( cTp2 )
			nTp2 := LD->&( "I" + cTp2 )
		endif
		if !EMPTY( cTp3 )
			nTp3 := LD->&( "I" + cTp3 )
		endif
		if !EMPTY( cTp4 )
			nTp4 := LD->&( "I" + cTp4 )
		endif
		if !EMPTY( cTp5 )
			nTp5 := LD->&( "I" + cTp5 )
		endif


		nNeto := field->uneto
		nKLO := g_klo( field->ulicodb )
		nL_odb := field->ulicodb
		
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
		
		// ugovori o djelu
		if cTipRada == "U" .and. cTrosk <> "N"
			
			nTrosk := ROUND2( nMBruto * (gUgTrosk / 100), gZaok2 )
			
			if lInRs == .t.
				nTrosk := 0
			endif
			
		endif

		// autorski honorar
		if cTipRada == "A" .and. cTrosk <> "N"
			
			nTrosk := ROUND2( nMBruto * (gAhTrosk / 100), gZaok2 )
			
			if lInRs == .t.
				nTrosk := 0
			endif
			
		endif

		if cRptTip $ "3#4"
			// ovo je bruto iznos
			nMBruto := ( nBruto - nTrosk )
		endif

		// ovo preskoci, nema ovdje GIP-a
		if nMBruto <= 0
			select ld
			skip
			loop
		endif

		// bruto primanja u uslugama ili dobrima
		// za njih posebno izracunaj bruto osnovicu
		if nPrDobra > 0
			nBrDobra := bruto_osn( nPrDobra, cTipRada, nL_odb )
		endif
		
		// ocitaj doprinose, njihove iznose
		nDopr10 := get_dopr( cDopr10, cTipRada )
		nDopr11 := get_dopr( cDopr11, cTipRada )
		nDopr12 := get_dopr( cDopr12, cTipRada )
		nDopr1X := get_dopr( cDopr1X, cTipRada )

		// izracunaj doprinose
		nIDopr10 := ROUND( nMBruto * nDopr10 / 100 , 4 )
		nIDopr11 := ROUND( nMBruto * nDopr11 / 100, 4 )
		nIDopr12 := ROUND( nMBruto * nDopr12 / 100, 4 )

		// zbirni je zbir ova tri doprinosa
		nIDopr1X := ROUND( nIDopr10 + nIDopr11 + nIDopr12, 4 )
		
		// ukupno dopr iz 31%
		//nDoprIz := u_dopr_iz( nMBruto, cTipRada )
		
		// osnovica za porez
		if cRptTip $ "3#4"
			nPorOsn := ( nMBruto - nIDopr1X ) - nL_odb
		else
			nPorOsn := ( nBruto - nIDopr1X ) - nL_odb
		endif

		// ako je neoporeziv radnik, nema poreza
		if !radn_oporeziv( radn->id, ld->idrj ) .or. ;
			( nBruto - nIDopr1X ) < nL_odb
			nPorOsn := 0
		endif

		// porez je ?
		nPorez := izr_porez( nPorOsn, "B" )

		select ld
	
		// na ruke je
		if cRptTip $ "3#4"
			nNaRuke := ROUND( (nMBruto - nIDopr1X - nPorez) ;
				+ nTrosk, 2 ) 
		else
			nNaRuke := ROUND( nBruto - nIDopr1X - nPorez, 2 ) 
		endif

		nIsplata := nNaRuke

		// da li se radi o minimalcu ?
		if cTipRada $ " #I#N#" 
			nIsplata := min_neto( nIsplata , field->usati )
		endif

		nMjIspl := 0
		cIsplZa := ""
		cVrstaIspl := ""
		dDatIspl := DATE()
		cObr := " "
		
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


		// ubaci u tabelu podatke
		_ins_tbl( cT_radnik, ;
				cRadJed, ;
				cTipRada, ;
				"placa", ;
				dDatIspl, ;
				ld->mjesec, ;
				nMjIspl, ;
				cIsplZa, ;
				cVrstaIspl, ;
				ld->godina, ;
				nBruto - nBrDobra, ;
				nBrDobra, ;
				nBruto, ;
				nMBruto, ;
				nTrosk, ;
				nDopr1X,;
				nIDopr10, ;
				nIDopr11, ;
				nIDopr12, ;
				nIDopr1X, ;
				nNaRuke, ;
				nKLO, ;
				nL_Odb, ;
				nPorOsn, ;
				nPorez, ;
				nIsplata, ;
				ld->usati, ;
				nTp1, ;
				nTp2, ;
				nTp3, ;
				nTp4, ;
				nTp5 )
				
		select ld
		skip

	enddo

enddo

return


