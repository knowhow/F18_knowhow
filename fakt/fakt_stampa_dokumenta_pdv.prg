/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fakt.ch"


// konto duguje
static __KTO_DUG
// konto potrazuje
static __KTO_POT
// fin kumpath
static __FIN_KUM
// show saldo varijanta
static __SH_SLD_VAR

// ----------------------------------------------------
// lJFill - samo se pune rn, drn pomocne tabele
// ----------------------------------------------------
function StdokPDV(cIdFirma, cIdTipDok, cBrDok, lJFill)
local cFax
local lPrepisDok := .f.
local _dok := hb_hash(), _fill_params := hb_hash()
local _fakt_params := fakt_params() 
// samo kolicine
local lSamoKol:=.f. 

if lJFill == NIL
	lJFill := .f.
endif

drn_create()
drn_open()
drn_empty()

// otvori tabele
if PCount() == 4 .and. ( cIdtipdok <> nil )
    lPrepisDok := .t.
    _fill_params["from_server"] := .t.
    o_fakt_edit(.t.)
else
    _fill_params["from_server"] := .f.
    o_fakt_edit(.f.)
endif

// otvori pomocne tabele racuna
o_dracun()

select fakt_pripr

// barkod artikla
private lPBarkod := .f.

if _fakt_params["barkod"] $ "12"  // pitanje, default "N"
	lPBarkod := ( Pitanje( ,"Zelite li ispis barkodova ?", IIF( _fakt_params["barkod"] == "1", "N", "D" ) ) == "D" )
endif

if PCount() == 0 .or. ( cIdTipDok == nil .and. lJFill == .t. )
 	cIdTipdok := field->idtipdok
	cIdFirma := field->IdFirma
	cBrDok := field->BrDok
endif

seek cIdFirma + cIdTipDok + cBrDok
NFOUND CRET

if PCount() <= 1 .or. ( cIdTipDok == NIL .and. lJFill == .t. )
	select fakt_pripr
endif

//napuni podatke za stampu
_dok["idfirma"] := field->IdFirma
_dok["idtipdok"] := field->IdTipDok
_dok["brdok"] := field->BrDok 
_dok["datdok"] := field->DatDok 

cDocumentName := doc_name( _dok, fakt_pripr->IdPartner )

// prikaz samo kolicine
if cIdTipDok $ "01#00#12#13#19#21#22#23#26"
	if ((gPSamoKol == "0" .and. Pitanje(,"Prikazati samo kolicine (D/N)", "N") == "D")) ;
	    .or. gPSamoKol == "D"
		lSamoKol:=.t.
	endif
endif

if VAL(podbr)=0 .and. VAL(rbr)==1
else
	Beep(2)
  	Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  	return
endif

__FIN_KUM := STRTRAN( KUMPATH, "FAKT", "FIN" )

_fill_params["barkod"] := lPBarkod
_fill_params["samo_kolicine"] := lSamoKol
 
// ako nije nesto uredu! izadji...
if !fill_porfakt_data( _dok, _fill_params )
    // izadji ....
    return
endif

if lJFill
	return
endif

if cIdTipDok $ "13#23"
	// stampa 13-ke
	omp_print()
else

  if cIdTipDok == "11" .and. gMPPrint $ "DXT"
	
	if gMPPrint == "D" .or. ( gMpPrint == "X" .and. Pitanje(,"Stampati na traku (D/N)?","D") == "D" ) .or. gMPPrint == "T"
	
		// stampa na traku
		gLocPort := "LPT" + ALLTRIM( gMpLocPort )

		lStartPrint := .t.
		
		cPrn := gPrinter
		gPrinter := "0"

		if gMPPrint == "T"
			// test mode
			gPrinter := "R"
		endif
	
		st_rb_traka( lStartPrint, lPrepisDok )

		gPrinter := cPrn

	else
		pf_a4_print(nil, cDocumentName)
	endif
  
  else
	pf_a4_print(nil, cDocumentName)
  endif

endif

return


// ----------------------------------------------------------------------
// puni  pomocne tabele rn drn
// ----------------------------------------------------------------------
static function fill_porfakt_data(dok, params)
local cTxt1,cTxt2,cTxt3,cTxt4,cTxt5
local cIdPartner
local dDatDok
local cDestinacija
local dDatVal
local dDatIsp
local aMemo
local cIdRoba := ""
local cRobaNaz := ""
local cRbr := ""
local cPodBr := ""
local cJmj:=""
local i
local nTmp
local nKol:=0
local nCjPDV:=0
local nCjBPDV:=0
local nPopust:=0 // proc popusta
local nPopNaTeretProdavca:=0
local nVPDV:=0
local nCj2PDV:=0
local nCj2BPDV:=0
local nPPDV:=0
local nRCijen:=0
local nCSum:= 0
local nTotal:= 0
local nUkBPDV:= 0
local nUkBPDVPop:=0
local nUkVPop:=0
local nVPopust:=0
local nVPopNaTeretProdavca:=0
local nUkPDV:=0
local nUkPopNaTeretProdavca:=0
local cTime:=""
local cDinDem
local nRec
local nZaokr
local nFZaokr:=0
local nDrnZaokr:=0
local cDokNaz
local nUkKol:=0
local lIno:=.f.
local cPdvOslobadjanje:=""
local nPom1
local nPom2
local nPom3
local nPom4
local nPom5
local cOpis := ""
local _a_tmp, _tmp

// ako je kupac pdv obveznik, ova varijable je .t.
local lPdvObveznik := .f.
local lKomisionar := .f.

local nDx1 := 0
local nDx2 := 0
local nDx3 := 0
local nSw1 := 72
local nSw2 := 1
local nSw3 := 72
local nSw4 := 31
local nSw5 := 1
local nSw6 := 1
local nSw7 := 0

local _fakt_params := fakt_params()

// radi citanja parametara
private cSection:="F"
private cHistory:=" "
private aHistory:={}

SELECT F_PARAMS
if !used()
	O_PARAMS
endif
RPar("x1", @nDx1)
RPar("x2", @nDx2)
RPar("x3", @nDx3)

RPar("x4", @nSw1)
RPar("x5", @nSw2)
RPar("x6", @nSw3)
RPar("x7", @nSw4)
// ovaj switch se koristi za poziv ptxt-a ... u principu
// ovdje mi i ne treba
RPar("x8", @nSw5)
// narudzbenice - samo kolicine 0, cijene 1
RPar("x9", @nSw6)
RPar("y1", @nSw7)

// napuni firmine podatke
fill_firm_data()

select fakt_pripr

// napuni podatke partnera

lPdvObveznik := .f.
fill_part_data( field->idpartner, @lPdvObveznik )

// popuni ostale podatke, radni nalog i slicno
fill_other()

select fakt_pripr

// vrati naziv dokumenta
get_dok_naz( @cDokNaz, field->idtipdok, field->idvrstep, params["samo_kolicine"] )

select fakt_pripr

dDatDok := dok["datdok"]

dDatVal := dDatDok
dDatIsp := dDatDok
cDinDem := dindem

nRec:=RecNO()

// ukupna kolicina
nUkKol := 0

DEC_CIJENA(ZAO_CIJENA())
DEC_VRIJEDNOST(ZAO_VRIJEDNOST())

lIno:=.f.
do while !EOF() .and. field->idfirma == dok["idfirma"] .and. ;
                    field->idtipdok == dok["idtipdok"] .and. ;
                    field->brdok == dok["brdok"]

	// Nastimaj (hseek) Sifr.Robe Na fakt_pripr->IdRoba
	//NSRNPIdRoba()
    select roba
    set order to tag "ID"
    go top
    seek fakt_pripr->idroba   

    if !FOUND()
        Msgbeep( "Artikal " + fakt_pripr->idroba + " ne postoji u sifrarniku !!!" )
        return .f.
    endif

	// nastimaj i tarifu
	select tarifa
    set order to tag "ID"
    go top
	seek roba->idtarifa

    if !FOUND()
        MsgBeep( "Tarifa " + roba->idtarifa + " ne postoji u sifraniku !!!" )
        return .f.
    endif

	select fakt_pripr

    aMemo := ParsMemo( field->txt )
	cIdRoba := field->idroba
	
	if roba->tip == "U"
		cRobaNaz := aMemo[1]
	else
		cRobaNaz := ALLTRIM( roba->naz )
		if params["barkod"]
			cRobaNaz := cRobaNaz + " (BK: " + roba->barkod + ")"
		endif
	endif

	// ako je roba grupa:
	if glRGrPrn == "D"
		cPom := _op_gr( roba->id, "GR1") + ": " + _val_gr(roba->id, "GR1") + ;
			", " + _op_gr(roba->id, "GR2") + ": " + _val_gr(roba->id, "GR2")
		
		cRobaNaz += " "
		cRobaNaz += cPom
        select fakt_pripr
	endif

	// dodaj i vrijednost iz polja SERBR
	if !EMPTY(ALLTRIM(fakt_pripr->serbr))
		cRobaNaz := cRobaNaz + ", " + ALLTRIM(fakt_pripr->serbr) 
	endif

	//resetuj varijable sa cijenama
	nCjPDV := 0
	nCj2PDV := 0
	nCjBPDV := 0
	nCj2BPDV := 0
	nVPopust := 0
    nPPDV := 0
	
	cRbr := field->rbr
	cPodBr := field->podbr
	cJmj := roba->jmj

	// procenat pdv-a
	nPPDV := tarifa->opp
	
	cIdPartner := field->idpartner

    if EMPTY( cIdPartner )
        MsgBeep( "Partner na fakturi - prazno - nesto nije ok !????" )
        return .f.
    endif

    if _fakt_params["fakt_opis_stavke"]
        dok["rbr"] := rbr
        cOpis := get_fakt_atribut_opis( dok, params["from_server"])
        select fakt_pripr
    else
        cOpis := ""
    endif

	// rn Veleprodaje
	if dok["idtipdok"] $ "10#11#12#13#20#22#25"
		
        // ino faktura
		if IsIno(cIdPartner)
			nPPDV := 0
			lIno := .t.
		endif

		// ako je po nekom clanu PDV-a partner oslobodjenj
		// placanja PDV-a
		cPdvOslobadjanje := PdvOslobadjanje( cIdPartner )
		if !EMPTY(cPdvOslobadjanje)
			nPPDV := 0
		endif

	endif

	if dok["idtipdok"] == "12"
		if IsProfil(cIdPartner, "KMS")
			// radi se o komisionaru
			lKomisionar := .t.
			nPPDV := 0
		endif
	endif

	// kolicina
	nKol := field->kolicina
	nRCijen := field->cijena

	if LEFT(fakt_pripr->DINDEM, 3) <> LEFT(ValBazna(), 3) 
		// preracunaj u EUR
		// omjer EUR / KM
      	nRCijen:= nRCijen / OmjerVal( ValBazna(), fakt_pripr->DINDEM, fakt_pripr->datdok)
		nRCijen:=ROUND(nRCijen, DEC_CIJENA() )
   	endif

	// resetuj prije eventualnog setovanja
	nPopNaTeretProdavca := 0

	// zasticena cijena, za krajnjeg kupca
	if RobaZastCijena(tarifa->id)  .and. !lPdvObveznik
		// krajnji potrosac
	   	// roba sa zasticenom cijenom
	   	nPopNaTeretProdavca := field->rabat
	   	nPopust := 0
	else
	    // rabat - popust
	    nPopust := field->rabat
	    nPopNaTeretProdavca := 0
	endif
	
	// ako je 13-ka ili 27-ca
	// cijena bez pdv se utvrdjuje unazad 
	if (field->idtipdok == "13" .and. glCij13Mpc) .or. (field->idtipdok $ "11#27" .and. gMP $ "1234567") 
		// cjena bez pdv-a
		nCjPDV:= nRCijen	
		nCjBPDV := (nRCijen / (1 + nPPDV/100))
	else
		// cjena bez pdv-a
		nCjBPDV:= nRCijen
		nCjPDV := (nRCijen * (1 + nPPDV/100))
	endif

	nVPopust := 0

	// izracunaj vrijednost popusta
	if Round(nPopust,4) <> 0
		// vrijednost popusta
		nVPopust := (nCjBPDV * (nPopust/100))
	endif
	
	// resetuj prije eventualnog setovanja
	nVPopNaTeretProdavca := 0
	
	// izacunaj vrijednost popusta na teret prodavca
	if Round(nPopNaTeretProdavca, 4) <> 0
		// vrijednost popusta
		nVPopNaTeretProdavca := (nCjBPDV * (nPopNaTeretProdavca/100))
	endif

	
	// cijena sa popustom bez pdv-a
	nCj2BPDV := (nCjBPDV - nVPopust)
	// izracuna PDV na cijenu sa popustom
	nCj2PDV := (nCj2BPDV * (1 + nPPDV/100))
	
	// ukupno stavka
	nUkStavka := nKol * nCj2PDV
	nUkStavke := ROUND(nUkStavka, ZAO_VRIJEDNOST() + IIF(idtipdok$"11#13", 4, 0) )

	nPom1 := nKol * nCjBPDV 
	nPom1 := ROUND(nPom1, ZAO_VRIJEDNOST() + IIF(idtipdok$"11#13", 4, 0) )
	// ukupno bez pdv
	nUkBPDV += nPom1 
	

	// ukupno popusta za stavku
	nPom2 := nKol * nVPopust
	nPom2 := ROUND(nPom2, ZAO_VRIJEDNOST() + IIF(idtipdok$"11#13", 4, 0) )
	nUkVPop += nPom2

	// preracunaj VPDV sa popustom
	nVPDV := (nCj2BPDV * (nPPDV/100))


	//  ukupno vrijednost bez pdva sa uracunatim poputstom
	nPom3 := nPom1 - nPom2 
	nPom3 := ROUND(nPom3, ZAO_VRIJEDNOST() + IIF(idtipdok$"11#13", 4, 0))
	nUkBPDVPop += nPom3
	

	// ukupno PDV za stavku = (ukupno bez pdv - ukupno popust) * stopa
	nPom4 := nPom3 * nPPDV/100
	// povecaj preciznost
	nPom4 := ROUND(nPom4, ZAO_VRIJEDNOST() + IIF(idtipdok$"11#13", 4, 2))
	nUkPDV += nPom4
	
	// ukupno za stavku sa pdv-om
	nTotal +=  nPom3 + nPom4

	nPom5 := nKol * nVPopNaTeretProdavca
	nPom5 := ROUND(nPom5, ZAO_VRIJEDNOST())
	nUkPopNaTeretProdavca += nPom5

	++ nCSum
	
    nUkKol += nKol
	
	add_rn( dok["brdok"], cRbr, cPodBr, cIdRoba, cRobaNaz, cJmj, nKol, nCjPDV, nCjBPDV, nCj2PDV, nCj2BPDV, nPopust, nPPDV, nVPDV, nUkStavka, nPopNaTeretProdavca, nVPopNaTeretProdavca, "", "", "", cOpis )

	select fakt_pripr
	skip

enddo	

// zaokruzi pdv na zao_vrijednost()
nUkPDV := ROUND( nUkPDV, ZAO_VRIJEDNOST() ) 

nTotal := ( nUkBPDVPop + nUkPDV )

if goModul:oDataBase:cSezona >= "2011" 
	nFZaokr := zaokr_5pf( nTotal )
	if gZ_5pf == "N"
		nFZaokr := 0		
	endif
else
	nFZaokr := ROUND(nTotal, ZAO_VRIJEDNOST()) - ROUND2(ROUND(nTotal, ZAO_VRIJEDNOST()), gFZaok)
endif

if (gFZaok <> 9 .and. ROUND(nFZaokr, 4) <> 0)
	nDrnZaokr := nFZaokr
endif

nTotal := ROUND(nTotal - nDrnZaokr, ZAO_VRIJEDNOST())

nUkPopNaTeretProdavca := ROUND(nUkPopNaTeretProdavca, ZAO_VRIJEDNOST())
nUkBPDV := ROUND( nUkBPDV, ZAO_VRIJEDNOST() )
nUkVPop := ROUND( nUkVPop, ZAO_VRIJEDNOST() )

select fakt_pripr
go (nRec)

// nafiluj ostale podatke vazne za sam dokument
aMemo := ParsMemo(txt)
dDatDok := datdok

if LEN(aMemo) <= 5
	dDatVal := dDatDok
	dDatIsp := dDatDok
	cBrOtpr := ""
	cBrNar  := ""
else
	dDatVal := CToD(aMemo[9])
	dDatIsp := CToD(aMemo[7])
	cBrOtpr := aMemo[6]
	cBrNar  := aMemo[8]
endif

// destinacija na fakturi
if LEN(aMemo) >= 18
	cDestinacija := aMemo[18]
else
	cDestinacija := ""
endif

// dokument_veza
if LEN(aMemo) >= 19
	cM_d_veza := aMemo[19]
else
	cM_d_veza := ""
endif

if LEN( aMemo ) >= 20
    cObjekti := aMemo[20]
else
    cObjekti := ""
endif

// mjesto
add_drntext("D01", gMjStr)
// naziv dokumenta
add_drntext("D02", cDokNaz )

// slovima iznos fakture
add_drntext("D04", Slovima( nTotal - nUkPopNaTeretProdavca , cDinDem))

// broj otpremnice
add_drntext("D05", cBrOtpr)

// broj narudzbenice
add_drntext("D06", cBrNar)

// DM/EURO
add_drntext("D07", cDinDem)

// Destinacija
add_drntext("D08", cDestinacija)

// objekakt
if !EMPTY( cObjekti )
    add_drntext("O01", cObjekti )
    add_drntext("O02", fakt_objekat_naz( cObjekti ) )
endif

// tip dokumenta
add_drntext("D09", dok["idtipdok"])

// radna jedinica
add_drntext("D10", dok["idfirma"])

// dokument veza
cTmp := cM_d_veza

aTmp := SjeciStr( cTmp, 200 )
nTmp := 30

// koliko ima redova
add_drntext("D30", ALLTRIM( STR(LEN(aTmp)) ) )
for i := 1 to LEN( aTmp )
	add_drntext("D" + ALLTRIM(STR( nTmp + i )), aTmp[i] )
next

// tekst na kraju fakture F04, F05, F06
fill_dod_text( aMemo[2], fakt_pripr->idpartner )

// potpis na kraju
fill_potpis(dok["idtipdok"])

// parametri generalni za stampu dokuemnta
// lijeva margina
add_drntext("P01", ALLTRIM(STR(gnLMarg)) )

// zaglavlje na svakoj stranici
add_drntext("P04", if(gZagl == "1", "D", "N"))

// prikaz dodatnih podataka 
add_drntext("P05", if(gDodPar == "1", "D", "N"))
// dodati redovi po listu 

add_drntext("P06", ALLTRIM(STR(gERedova)) )

// gornja margina
add_drntext("P07", ALLTRIM(STR(gnTMarg)) )

// da li se formira automatsko zaglavlje
add_drntext("P10", gStZagl )

do case

 case dok["idtipdok"] == "12" .and. lKomisionar
 	add_drntext("P11", "KOMISION")

 case lIno
 	// ino faktura
 	add_drntext("P11", "INO" )

 case !EMPTY(cPdvOslobadjanje)
 	add_drntext("P11", cPdvOslobadjanje)
	
 otherwise
 	// domaca faktura
 	add_drntext("P11", "DOMACA" )

endcase

// redova iznad "kupac"
add_drntext("X01", STR( nDx1, 2, 0) )
// redova ispod "kupac"
add_drntext("X02", STR( nDx2, 2, 0) )
// redova izmedju broja narudbze i tabele
add_drntext("X03", STR( nDx3, 2, 0) )


add_drntext("X04", STR( nSw1, 2, 0) )
add_drntext("X05", STR( nSw2, 2, 0) )
add_drntext("X06", STR( nSw3, 2, 0) )
add_drntext("X07", STR( nSw4, 2, 0) )
add_drntext("X08", STR( nSw5, 2, 0) )
add_drntext("X09", STR( nSw6, 1, 0) )
add_drntext("X10", STR( nSw7, 1, 0) )

// header i footer - broj redova
if gPDFPrint == "D"
	add_drntext("X11", STR( gFPicHRow, 2, 0) )
	add_drntext("X12", STR( gFPicFRow, 1, 0) )
else
	// ako nije pdf stampa - nema parametara....
	add_drntext("X11", STR(0) )
	add_drntext("X12", STR(0) )
endif

// fakturu stampaj u ne-compatibility modu
gPtxtC50 := .f.
do case
	case nSw5 == 0
		gPtxtSw := "/noline /s /l /p"
	case nSw5 == 1
		gPtxtSw := "/p"
		
	otherwise
		// citaj ini fajl
		gPtxtSw := nil
endcase


// dodaj total u DRN
add_drn( dok["brdok"], dok["datdok"], dDatVal, dDatIsp, cTime, nUkBPDV, nUkVPop, nUkBPDVPop, nUkPDV, nTotal, nCSum, nUkPopNaTeretProdavca, nDrnZaokr, nUkKol)

if ( dok["idtipdok"] $ "10#11" ) .and. ROUND( nUkPDV, 2 ) == 0
    if Pitanje(, "Faktura je bez iznosa PDV-a! Da li je to uredu (D/N)", "D" ) == "N"
        return .f.
    endif
endif

return .t.


// -------------------------------------
// vraca opis grupe iz sifK
// -------------------------------------
static function _op_gr( cId, cSifK )
local nTArea := SELECT()
local cRet := ""

O_SIFK
select sifk
set order to tag "ID2"
go top
seek PADR("ROBA", 8) + PADR( cSifK, 4 )

if FOUND()
	cRet := ALLTRIM( field->naz )
endif

select (nTArea)
return cRet


// -------------------------------------
// vraca vrijednost grupe iz sifK
// -------------------------------------
static function _val_gr( cId, cSifK )
local cRet := ""
cRet := IzSifK( "ROBA", cSifK, cId, .f. )
if cRet == nil
	cRet := ""
endif
return ALLTRIM( cRet )


// ----------------------------------
// ----------------------------------
static function fill_potpis(cIdVD)
local cPom
local cPotpis

if (cIdVd $ "01#00") 
	cPotpis := REPLICATE(" ", 12) + "Odobrio" + REPLICATE(" ", 25) + "Primio"

elseif cIdVd $ "19"
	cPotpis := REPLICATE(" ", 12) + "Odobrio" + REPLICATE(" ", 25) + "Predao"
else
   	cPom:="G"+cIdVD+"STR2T"
   	cPotpis := &cPom
endif

// potpis 
add_drntext("F10", cPotpis)

return


// -----------------------------------------------
// popunjavanje ostalih podataka fakture
// -----------------------------------------------
static function fill_other()

// broj fiskalnog isjecka
add_drntext("O10", fisc_isjecak( fakt_pripr->idfirma, fakt_pripr->idtipdok, ;
	fakt_pripr->brdok ) )

// traka - ispis, cjene bez pdv, sa pdv (1) bez pdv, (2) sa pdv
cPom := gMPCjenPDV
add_drntext( "P20", cPom )

// stampa id roba na racunu D/N
cPom := gMPArtikal
add_drntext( "P21", cPom )

// redukcija trake 0/1/2
cPom := gMpRedTraka
add_drntext( "P22", cPom )

// ispis kupca na racunu
cPom := "D"
add_drntext( "P23", cPom )

// mjesto
cPom := gMjStr
add_drntext( "R01", cPom )

if gSecurity == "D"
	// naziv operatera
	cPom := getfullusername( getuserid() )
	add_drntext( "R02", cPom )
endif

// smjena
cPom := "1"
add_drntext( "R03", cPom )

// vrsta placanja
cPom := "GOTOVINA"
add_drntext( "R05", cPom )

// dodatni tekst racuna
cPom := ""
add_drntext( "R06", cPom )
add_drntext( "R07", cPom )
add_drntext( "R08", cPom )

// broj linija za odcjep.trake
cPom := "8"
add_drntext( "P12", cPom )

// sekv.otvaranje ladice
cPom := ""
add_drntext( "P13", cPom )

// sekv.cjepanje trake
cPom := ""
add_drntext( "P14", cPom )

// prodajno mjesto
cPom := "prod. 1"
add_drntext( "I04", cPom )

return


// --------------------------------------------------------------
// daj naziv dokumenta iz parametara
// --------------------------------------------------------------
function get_dok_naz(cNaz, cIdVd, cVP, lSamoKol)
local cPom
local cSamoKol

if (cIdVd == "01")
	cNaz := "Prijem robe u magacin br."
elseif (cIdVd == "00")
	cNaz := "Pocetno stanje br."
elseif (cIdVD == "19")
	cNaz := "Izlaz po ostalim osnovama br."
elseif (cIdVD == "10" .and. cVP == "AV")
	cNaz := "Avansna faktura br."
else
 	cPom:="G" + cIdVd + "STR"
 	cNaz := &cPom
endif

// ako je lSamoKol := .t. onda je prikaz samo kolicina
cSamoKol := "N"
if lSamoKol
	cSamoKol := "D"
endif

add_drntext("P03", cSamoKol)

return

// -----------------------------------------------
// filovanje dodatnog teksta
// cTxt - dodatni tekst
// cPartn - id partner
// -----------------------------------------------
static function fill_dod_text( cTxt, cPartn )
local aLines // matrica sa linijama teksta
local nFId // polje Fnn counter od 20 pa nadalje
local nCnt // counter upisa u DRNTEXT

// obradi djokere...
_txt_djokeri( @cTxt, cPartn )

// slobodni tekst se upisuje u DRNTEXT od F20 -- F50
cTxt := STRTRAN(cTxt, "" + Chr(10), "")
// daj mi matricu sa tekstom line1, line2 itd...
aLines := TokToNiz(cTxt, Chr(13) + Chr(10)) 

nFId := 20
nCnt := 0
for i:=1 to LEN(aLines)
	add_drntext("F" + ALLTRIM(STR(nFId)), aLines[i])
	++ nFId
	++ nCnt
next

// dodaj i parametar koliko ima linija texta
add_drntext("P02", ALLTRIM(STR(nCnt)))

return
*}



// ----------------------------------------
// obradi djokere
// cTxt - txt polje
// cPartn - id partner
// ----------------------------------------
function _txt_djokeri( cTxt, cPartn )
local cPom
local cPom2
local nSaldoKup
local nSaldoDob
local dPUplKup
local dPPromKup
local dPPromDob

// strings
local cStrSlKup := "#SALDO_KUP#"
local cStrSlDob := "#SALDO_DOB#"
local cStrSlKD := "#SALDO_KUP_DOB#"
local cStrDUpKup := "#D_P_UPLATA_KUP#"
local cStrDPrKup := "#D_P_PROMJENA_KUP#"
local cStrDPrDob := "#D_P_PROMJENA_DOB#"

private gFinKPath

if gShSld == "N"
	return
endif

gFinKPath := __FIN_KUM

if gFinKtoDug <> nil

	__KTO_DUG := gFinKtoDug
	__KTO_POT := gFinKtoPot

endif

// varijanta prikaza salda... 1 ili 2
__SH_SLD_VAR := gShSldVar

// saldo kupca
nSaldoKup := get_fin_partner_saldo( cPartn, __KTO_DUG, gFirma )
		
// saldo dobavljaca
nSaldoDob := get_fin_partner_saldo( cPartn, __KTO_POT, gFirma )

// datum zadnje uplate kupca
dPUplKup := g_dpupl_part( cPartn, __KTO_DUG, gFirma )

// datum zadnje promjene kupac
dPPromKup := g_dpprom_part( cPartn, __KTO_DUG, gFirma )

// datum zadnje promjene dobavljac
dPPromDob := g_dpprom_part( cPartn, __KTO_POT, gFirma )


// -------------------------------------------------------
// SALDO KUPCA
// -------------------------------------------------------
if AT( cStrSlKup, cTxt ) <> 0
		
	if gShSld == "D"

		cPom := ALLTRIM(STR( ROUND( nSaldoKup, 2 ) )) + " KM" 
		cPom2 := ""
		
		if __SH_SLD_VAR == 2
			cPom2 := "Va posljednji saldo iznosi: "
		endif
	else
	
		cPom := ""
		cPom2 := ""
	
	endif
	
	cTxt := STRTRAN(cTxt, cStrSlKup, cPom2 + " " + cPom )
endif


// -------------------------------------------------------
// SALDO DOBAVLJACA
// -------------------------------------------------------
if AT( cStrSlDob, cTxt ) <> 0
		
	if gShSld == "D"

		cPom := ALLTRIM(STR( ROUND( nSaldoDob, 2 ) )) + " KM" 
		cPom2 := ""
		
		if __SH_SLD_VAR == 2
			cPom2 := "Na posljednji saldo iznosi: "
		endif
	else
	
		cPom := ""
		cPom2 := ""
	
	endif
	
	cTxt := STRTRAN(cTxt, cStrSlDob, cPom2 + " " + cPom )
endif

// -------------------------------------------------------
// SALDO KUPCA/DOBAVLJACA prebijeno
// -------------------------------------------------------
if AT( cStrSlKD, cTxt ) <> 0
		
	if gShSld == "D"

		cPom := ALLTRIM(STR( ROUND( nSaldoKup, 2 ) - ROUND( nSaldoDob, 2) )) + " KM" 
		cPom2 := ""
		
		if __SH_SLD_VAR == 2
			cPom2 := "Prebijeno stanje kupac/dobavljac : "
		endif
	else
	
		cPom := ""
		cPom2 := ""
	
	endif
	
	cTxt := STRTRAN(cTxt, cStrSlKD, cPom2 + " " + cPom )
endif


// -------------------------------------------------------
// DATUM POSLJEDNJE UPLATE KUPCA/DOBAVLJACA
// -------------------------------------------------------
if AT( cStrDUpKup, cTxt ) <> 0
	
	if gShSld == "D"
		

		// datum posljednje uplate kupca
		cPom := DToC(dPUplKup)
		cPom2 := ""
		if __SH_SLD_VAR == 2
			cPom2 := "Datum posljednje uplate: "
		endif
	else

		cPom := ""
		cPom2 := ""
	
	endif
	
	cTxt := STRTRAN(cTxt, cStrDUpKup, cPom2 + " " + cPom)

endif	

// -------------------------------------------------------
// DATUM POSLJEDNJE PROMJENE NA KONTU KUPCA
// -------------------------------------------------------
if AT( cStrDPrKup, cTxt ) <> 0
	
	if gShSld == "D"
	
		// datum posljednje promjene kupac
		cPom := DToC(dPPromKup)
		cPom2 := ""
		if __SH_SLD_VAR == 2
			cPom2 := "Datum posljednje promjene na kontu kupca: "
		endif
	
	else
	
		cPom := ""
		cPom2 := ""

	endif
	
	cTxt := STRTRAN(cTxt, cStrDPrKup, cPom2 + " " + cPom)

endif	

// -------------------------------------------------------
// DATUM POSLJEDNJE PROMJENE NA KONTU DOBAVLJACA
// -------------------------------------------------------
if AT( cStrDPrDob, cTxt ) <> 0
	
	if gShSld == "D"
	
	
		// datum posljednje promjene dobavljac
		cPom := DToC(dPPromDob)
		cPom2 := ""
		if __SH_SLD_VAR == 2
			cPom2 := "Datum posljednje promjene na kontu dobavljaca: "
		endif

	else
	
		cPom := ""
		cPom2 := ""
	
	endif
	
	cTxt := STRTRAN(cTxt, cStrDPrDob, cPom2 + " " + cPom)

endif

return



// -------------------------------------------
// filovanje podataka partnera
// -------------------------------------------
static function fill_part_data(cId, lPdvObveznik)
local cIdBroj:=""
local cPorBroj:=""
local cBrRjes:=""
local cBrUpisa:=""
local cPartNaziv:=""
local cPartAdres:=""
local cPartMjesto:=""
local cPartTel:=""
local cPartFax:=""
local cPartPTT:=""
local aMemo:={}
local lFromMemo:=.f.
local _t_area := SELECT()

if Empty(ALLTRIM(cID))
	// ako je prazan partner uzmi iz memo polja
	aMemo:=ParsMemo(txt)
	lFromMemo := .t.
else
	O_PARTN
	select partn
	set order to tag "ID"
	hseek cId
endif

if !lFromMemo .and. partn->id == cId
	// uzmi podatke iz SIFK
	cIdBroj := IzSifK( "PARTN", "REGB", cId, .f. )
	cPorBroj := IzSifK( "PARTN", "PORB", cId, .f. )
	cBrRjes := IzSifK( "PARTN", "BRJS", cId, .f. )
	cBrUpisa := IzSifK( "PARTN", "BRUP", cId, .f. )
	cPartNaziv := partn->naz
	cPartAdres := partn->adresa
	cPartMjesto := partn->mjesto
	cPartPtt := partn->ptt
	cPartTel := partn->telefon
	cPartFax := partn->fax
else
	if LEN(aMemo) == 0
		cPartNaziv := ""
		cPartAdres := ""
		cPartMjesto := ""
	else
		cPartNaziv := aMemo[3]
		cPartAdres := aMemo[4]
		cPartMjesto := aMemo[5]
	endif
endif

// naziv
add_drntext("K01", cPartNaziv)
// adresa
add_drntext("K02", cPartAdres)
// mjesto
add_drntext("K10", cPartMjesto)
// ptt
add_drntext("K11", cPartPTT)
// idbroj
add_drntext("K03", cIdBroj)
// porbroj
add_drntext("K05", cPorBroj)

// tel
add_drntext("K13", cPartTel)
// fax
add_drntext("K14", cPartFax)

if !EMPTY(cIdBroj) 
	if LEN(ALLTRIM(cIdBroj)) == 12
		lPdvObveznik := .t.
	else
		lPdvObveznik := .f.
	endif
else
	lPdvObveznik := .f.
endif
	
// brrjes
add_drntext("K06", cBrRjes)
// brupisa
add_drntext("K07", cBrUpisa)

select ( _t_area )

return


static function fill_firm_data()
local i
local cBanke
local cPom
local lPrazno
local _t_area := SELECT()

// opci podaci
add_drntext("I01", gFNaziv)
add_drntext("I20", gFPNaziv)
add_drntext("I02", gFAdresa)
add_drntext("I03", gFIdBroj)
// 4. se koristi za id prod.mjesto u pos
// telefon pos = I05
add_drntext("I05", ALLTRIM( gFTelefon ) )
add_drntext("I10", ALLTRIM( gFTelefon ) )
add_drntext("I11", ALLTRIM( gFEmailWeb ) )

// banke
cBanke:=""
lPrazno:=.t.

for i:=1 to 5
  if i==1
    cPom:=ALLTRIM(gFBanka1)
  elseif i==2
    cPom:=ALLTRIM(gFBanka2)
  elseif i==3
    cPom:=ALLTRIM(gFBanka3)
  elseif i==4
    cPom:=ALLTRIM(gFBanka4)
  elseif i==5
    cPom:=ALLTRIM(gFBanka5)
  endif
  if !empty(cPom)
	if !lPrazno
		cBanke += ", "
	endif
	cBanke += cPom
	lPrazno := .f.
  endif
next


add_drntext("I09", cBanke )

// dodatni redovi
add_drntext("I12", ALLTRIM(gFText1))
add_drntext("I13", ALLTRIM(gFText2))
add_drntext("I14", ALLTRIM(gFText3))

select ( _t_area )

return


// ------------------------------------
// ------------------------------------
function ZAO_VRIJEDNOST()
local nPos
local nLen

// 999.99
nPos := AT(".", PicDem)
// = 4
nLen := LEN(PicDEM) 
// = 6

if nPos == 0
	nPos := nLen
endif

return nLen - nPos


// ------------------------------------
// ------------------------------------
function ZAO_CIJENA()
local nPos
local nLen

// 999.99
nPos := AT(".", PicCDem)
// = 4
nLen := LEN(PicDEM) 
// = 6

if nPos == 0
	nPos := nLen
endif

return nLen - nPos


// -------------------------------------------
// cDocName
// -------------------------------------------
static function doc_name(dok, partner)
local cFax
local cPartner
local cDocumentName

// primjer cDocumentName = FAKT_DOK_10-10-00050_planika-flex-sarajevo_29.05.06_FAX:032440173
cDocumentName := gModul + "_DOK_" + dok["idfirma"]  + "-" + dok["idtipdok"] + "-" + TRIM(dok["brdok"]) + "-" + TRIM(partner) + "_" + DTOC(DatDok)

cPartner := ALLTRIM(g_part_name(partner))

cPartner := STRTRAN(cPartner, " ","-")
cPartner := STRTRAN(cPartner, '"',"")
cPartner := STRTRAN(cPartner, "'","")
cPartner := STRTRAN(cPartner, '/',"-")

cDocumentName += "_" + cPartner

// 032/440-170 => 032440170
cFax := STRTRAN(g_part_fax(partner), "-", "")
cFax := STRTRAN(cFax, "/", "")
cFax := STRTRAN(cFax, " ", "")

cDocumentName += "_FAX-" + cFax

cDocumentName := KonvZnWin(cDocumentName, "4")
return cDocumentName
