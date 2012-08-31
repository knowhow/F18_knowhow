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


#include "pos.ch"


static __device := 0

// --------------------------------------
// stampa fiskalnog racuna
// --------------------------------------
function pos_fisc_rn( cIdPos, dDat, cBrRn )
local nErr := 0

if gFc_use == "N"
	return
endif

do case
	case ALLTRIM(gFc_type) == "FLINK"
		nErr := _flink_rn( cIdPos, dDat, cBrRn )
	case ALLTRIM(gFc_type) == "TRING"
		nErr := _tring_rn( cIdPos, dDat, cBrRn )
	case ALLTRIM(gFc_type) == "FPRINT"
		nErr := _fprint_rn( cIdPos, dDat, cBrRn )
	case ALLTRIM(gFc_type) == "HCP"
		nErr := _hcp_rn( cIdPos, dDat, cBrRn )
	case ALLTRIM(gFc_type) == "TREMOL"
		nErr := _trm_rn( cIdPos, dDat, cBrRn )

endcase

if gFC_error == "D" .and. nErr > 0
	
	if ALLTRIM( gFc_type ) == "TREMOL"
		
		nErr := _trm_rn( cIdPos, dDat, cBrRn, "2" )

		if nErr > 0
			msgbeep("Problem sa stampanjem na fiskalni stampac !!!")
		endif
	else
		// ima greska
		msgbeep("Problem sa stampanjem na fiskalni stampac !!!")
	endif
endif

// ako ne provjeravamo greske uvijek vrati 0
if gFC_error == "N"
	nErr := 0
endif

return nErr



// -----------------------------------------------
// box za unos ukupno uplacene sume
// -----------------------------------------------
function unesi_ukupno_uplacenu_sumu()
local _iznos := 0
private getlist := {}

Box(, 1, 60 )
    @ m_x + 1, m_y + 2 SAY "Ukupno uplaceno:" GET _iznos PICT "99999999.99"
    read
BoxC()

if LastKey() == K_ESC
    _iznos := 0
endif

return _iznos



// -------------------------------------
// stampa fiskalnog racuna FPRINT
// -------------------------------------
function _fprint_rn( cIdPos, dDat, cBrRn )
local aRn := {}
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0
local lStorno := .t.
local nErr := 0
local nPLU := 0
local nPopust := 0
local nPLU_price := 0
local nFisc_no := 0
local aKupac := {}
local cPartner := ""
local nTotal := 0
local nNF_txt := ALLTRIM( cIdPos ) + "-" + ALLTRIM( cBrRn )
local cVr_placanja := "0"

select pos_doks
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

// ovo je partner
cPartner := field->idgost
cVr_placanja := _get_vr_pl( field->idvrstep )

// ako je vrsta placanja <> gotovina
if cVr_placanja <> "0"
	// vrati mi iznos racuna
	nTotal := pos_iznos_racuna( cIdPos, "42", dDat, cBrRn )
endif

// unesi ukupno uplacen iznos za racun
// samo vrijedi kod gotovine
if cVr_placanja == "0" .and. gFc_kusur == "D"
    nTotal := unesi_ukupno_uplacenu_sumu()
endif

if !EMPTY( cPartner )
	
	// imamo partnera, moramo ga dodati u matricu za racun
	
	O_PARTN
	select partn
	go top
	seek cPartner

endif

// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->idvd == "42" ;
		.and. DTOS(field->datum) == DTOS(dDat) ;
		.and. field->brdok == cBrRn

	if field->kolicina > 0
		lStorno := .f.
	endif

	cT_c_1 := ""
	nPopust := 0
	nPLU := 0
	nPLU_price := 0
	cPLU_bk := ""

	if pos->(FIELDPOS("C_1")) <> 0
		// ovo je broj racuna koji se stornira 
		cT_c_1 := field->c_1
	endif

	cArtikal := field->idroba

	select roba
	seek cArtikal

	nPLU := roba->fisc_plu

	if gFC_acd == "D"
		// generisi PLU iz parametara
		nPLU := auto_plu(nil, nil, __device)
	endif

	nPLU_price := roba->mpc
	cPLU_bk := roba->barkod
	cPLU_jmj := roba->jmj

	select pos

	if field->ncijena > 0
		nPopust := ( field->ncijena / field->cijena ) * 100
	endif

	++ nCtrl

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	cRobaNaz := fp_f_naz( roba->naz )
	// _fix_naz( roba->naz, @cRobaNaz )

	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR(++nRbr)), ;
		field->idroba, ;
		cRobaNaz, ;
		field->cijena, ;
		ABS( field->kolicina ), ;
		field->idtarifa, ;
		cT_c_1, ;
		nPLU, ;
		field->cijena, ;
		nPopust, ;
		cPLU_bk, ;
		cVr_placanja, ;
		nTotal, ;
		dDat, ;
		cPlu_JMJ } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskal: nema stavki za stampu !!!")
	nErr := 1
	return nErr
endif

// provjeri stavke racuna, kolicine, cijene
if fp_check( @aRn ) < 0
	return 1
endif

// pobrisi answer fajl
fp_d_answer( ALLTRIM(gFc_path), ALLTRIM(gFc_name) )

// idemo sada na upis rn u fiskalni fajl
fp_pos_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), aRn, aKupac, ;
	lStorno, gFc_error )

// iscitaj error
nErr := fp_r_error( ALLTRIM(gFc_path), ;
		ALLTRIM(gFc_name), gFc_tout, @nFisc_no )

if nErr = -9
	// nema answer fajla, da nije do trake ?
	if Pitanje(,"Da li je nestalo trake ?","N") == "D"
		if Pitanje(,"Zamjenite traku i pritisnite 'D'","D") == "D"
			// iscitaj error
			nErr := fp_r_error( ALLTRIM(gFc_path), ;
				ALLTRIM(gFc_path), ;
				gFc_tout, @nFisc_no )
		endif
	endif
endif

// fiskalni racun ne moze biti 0
if nFisc_no <= 0
	nErr := 1
endif

if nErr <> 0

	// pobrisati out fajl obavezno
	// da ne bi otisao greskom na uredjaj kad proradi

	fp_d_out( ALLTRIM(gFc_path) + ALLTRIM(gFc_name) )

	msgbeep("Postoji greska !!!")

else
	
    if gFC_nftxt == "D"
		// printaj non-fiscal tekst
		// u ovom slucaju broj racuna
		fp_nf_txt( ALLTRIM( gFC_path), ALLTRIM( gFC_name), cNF_txt )
	endif
	
    if nFisc_no <> 0
		_update_fisc_rn( nFisc_no )
    	msgo( "Kreiran fiskalni racun broj: " + ALLTRIM( STR( nFisc_no ) ) )
	    sleep(2)
        msgc()
	endif

endif

return nErr


// -------------------------------------
// stampa fiskalnog racuna FLINK
// -------------------------------------
function _flink_rn( cIdPos, dDat, cBrRn )
local aRn := {}
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0
local lStorno := .t.
local nErr := 0
local nPLU := 0
local cVr_placanja := "0"
local nTotal := 0

// 0 - gotovina
// 1 - kredit
// 2 - cek
// 3 - virman

select pos_doks
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

// vrsta placanja
cVr_placanja := _fl_vr_pl( field->idvrstep )

if cVr_placanja <> "0"
	// uzmi total
	nTotal := pos_iznos_racuna( cIdPos, "42", dDat, cBrRn )
endif

// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->idvd == "42" ;
		.and. DTOS(field->datum) == DTOS(dDat) ;
		.and. field->brdok == cBrRn

	
	if field->kolicina > 0
		lStorno := .f.
	endif

	cT_c_1 := ""

	if pos->(FIELDPOS("C_1")) <> 0
		// ovo je broj racuna koji se stornira 
		cT_c_1 := field->c_1
	endif

	cArtikal := field->idroba

	select roba
	seek cArtikal
	
	nPLU := roba->fisc_plu

	select pos

	++ nCtrl

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	cRobaNaz := ""
	_fix_naz( roba->naz, @cRobaNaz )

	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR(++nRbr)), ;
		field->idroba, ;
		cRobaNaz, ;
		field->cijena, ;
		ABS( field->kolicina ), ;
		_g_tar(field->idtarifa), ;
		cT_c_1, ; 
        nPLU, ;
        cVr_placanja, ;
        nTotal } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskal: nema stavki za stampu !!!")
	nErr := 1
	return nErr
endif

// idemo sada na upis rn u fiskalni fajl
nErr := fc_pos_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), aRn, lStorno, gFc_error )

return nErr



// --------------------------------------------
// vrati vrstu placanja
// --------------------------------------------
static function _fl_vr_pl( cIdVrsta )
local cVrsta := "0"
local nTArea := SELECT()
local cVrstaNaz := ""

if EMPTY(cIdVrsta) .or. cIdVrsta == "01"
	// ovo je gotovina
	return cVrsta
endif

O_VRSTEP
select vrstep
set order to tag "ID"
seek cIdVrsta

cVrstaNaz := ALLTRIM( vrstep->naz )

do case 
	case "KARTICA" $ cVrstaNaz
		cVrsta := "1"
	case "CEK" $ cVrstaNaz
		cVrsta := "2"
	case "VIRMAN" $ cVrstaNaz
		cVrsta := "3"
	otherwise
		cVrsta := "0"
endcase 

select (nTArea)

return cVrsta




// --------------------------------------------
// stampa fiskalnog racuna TREMOL 
// --------------------------------------------
function _trm_rn( cIdPos, dDat, cBrRn, cContinue )
local aRn := {}
local aKupac := nil
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0
local lStorno := .t.
local nErr := 0
local nPLU := 0
local nPLU_price := 0
local nPopust := 0
local cPLU_bk := ""
local nTotal := 0
local cPartner := ""
local nFisc_no := 0

if cContinue == nil
	cContinue := "0"
endif

select pos_doks
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn
// ovo je partner
cPartner := field->idgost

if !EMPTY( cPartner )
	
	// imamo partnera, moramo ga dodati u matricu za racun
	
	O_PARTN
	select partn
	go top
	seek cPartner
	
	aKupac := {}

	//if !EMPTY( partn->jib )
	  // AADD( aKupac, { partn->jib, partn->naz, ;
		//partn->adresa, partn->ptt, partn->mjesto } )
	//endif

endif


// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->idvd == "42" ;
		.and. DTOS(field->datum) == DTOS(dDat) ;
		.and. field->brdok == cBrRn
	
	if field->kolicina > 0
		lStorno := .f.
	endif

	cT_c_1 := ""
	nPopust := 0
	nPLU_price := 0

	if pos->(FIELDPOS("C_1")) <> 0
		// ovo je broj racuna koji se stornira 
		cT_c_1 := field->c_1
	endif

	cArtikal := field->idroba

	select roba
	seek cArtikal

	nPLU := roba->fisc_plu
	nPLU_price := roba->mpc
	cPLU_bk := roba->barkod
	cPLU_jmj := roba->jmj

	select pos
	
	if field->ncijena > 0
		nPopust := ( field->ncijena / field->cijena ) * 100
	endif

	++ nCtrl

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	cRobaNaz := ""
	_fix_naz( roba->naz, @cRobaNaz )
	
	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR( ++nRbr )), ;
		field->idroba, ;
		cRobaNaz, ;
		field->cijena, ;
		ABS( field->kolicina ), ;
		field->idtarifa, ;
		cT_c_1, ;
		nPLU, ;
		nPLU_price, ;
		nPopust, ;
		cPLU_bk, ;
		"0", ;
		nTotal, ;
		dDat, ;
		cPLU_jmj } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskal: nema stavki za stampu !!!")
	nErr := 1
	return nErr
endif

// idemo sada na upis rn u fiskalni fajl
nErr := fc_trm_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), ;
	aRn, aKupac, lStorno, gFc_error, cContinue )


if gFc_error == "D" .and. cContinue <> "2"
	
	// naziv fajla
	cFName := trm_filename( cBrRn )

	if trm_read_out( ALLTRIM(gFc_path), cFName )
		
		// procitaj poruku greske
		nErr := trm_r_error( ALLTRIM(gFc_path), ALLTRIM(cFName), ;
			gFc_tout, @nFisc_no ) 

	
		if nErr = 0 .and. !lStorno .and. nFisc_no > 0

			msgbeep("Kreiran fiskalni racun: " + ;
				ALLTRIM(STR( nFisc_no )))
			
            _update_fisc_rn( nFisc_no )	

		endif
	
	endif
	
	// obrisi fajl
	// da ne bi ostao kada server proradi ako je greska
	FERASE( ALLTRIM(gFc_path) + ALLTRIM(cFName) )
endif

return nErr




// --------------------------------------------
// stampa fiskalnog racuna HCP
// --------------------------------------------
function _hcp_rn( cIdPos, dDat, cBrRn )
local aRn := {}
local aKupac := nil
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0
local lStorno := .t.
local nErr := 0
local nPLU := 0
local nPLU_price := 0
local nPopust := 0
local cPLU_bk := ""
local nTotal := 0
local cPartner := ""
local cVrsta_pl := "0"

select pos_doks
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn
// ovo je partner
cPartner := field->idgost
cVrsta_pl := _get_vr_pl( field->idvrstep )

if !EMPTY( cPartner )
	
	// imamo partnera, moramo ga dodati u matricu za racun
	
	O_PARTN
	select partn
	go top
	seek cPartner

	aKupac := {}

	//if !EMPTY( partn->jib )
	  // AADD( aKupac, { partn->jib, partn->naz, ;
		//partn->adresa, partn->ptt, partn->mjesto } )
	//endif

endif

// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->idvd == "42" ;
		.and. DTOS(field->datum) == DTOS(dDat) ;
		.and. field->brdok == cBrRn
	
	if field->kolicina > 0
		lStorno := .f.
	endif

	cT_c_1 := ""
	nPopust := 0
	nPLU_price := 0

	if pos->(FIELDPOS("C_1")) <> 0
		// ovo je broj racuna koji se stornira 
		cT_c_1 := field->c_1
	endif

	cArtikal := field->idroba

	select roba
	seek cArtikal

	nPLU := 0

	if roba->(FIELDPOS("BARKOD")) <> 0
		nPLU := roba->fisc_plu
	endif

	if gFc_acd == "D"
		nPLU := auto_plu( nil, nil, __device )
	endif

	nPLU_price := roba->mpc
	cPLU_bk := roba->barkod
	cPLU_jmj := roba->jmj

	select pos
	
	if field->ncijena > 0
		nPopust := ( field->ncijena / field->cijena ) * 100
	endif

	++ nCtrl

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	cRobaNaz := ""
	_fix_naz( roba->naz, @cRobaNaz )
	
	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR( ++nRbr )), ;
		field->idroba, ;
		cRobaNaz, ;
		field->cijena, ;
		ABS( field->kolicina ), ;
		field->idtarifa, ;
		cT_c_1, ;
		nPLU, ;
		nPLU_price, ;
		nPopust, ;
		cPLU_bk, ;
		cVrsta_pl, ;
		nTotal, ;
		dDat, ;
		cPLU_jmj } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskal: nema stavki za stampu !!!")
	nErr := 1
	return nErr
endif

// idemo sada na upis rn u fiskalni fajl
nErr := fc_hcp_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), ;
	aRn, aKupac, lStorno, gFc_error, nTotal )

if nErr = 0
	
	// vrati broj racuna
	nFisc_no := hcp_fisc_no( ALLTRIM(gFc_path), ALLTRIM(gFc_name), ;
			gFc_error, lStorno )
	
    if nFisc_no > 0
        _update_fisc_rn( nFisc_no )
    endif

endif


return nErr




// ------------------------------------------------
// update broj fiskalnog racuna
static function _update_fisc_rn( nFisc_no )
local _rec

select pos_doks

_rec := dbf_get_rec()
_rec["fisc_rn"] := nFisc_no

if !f18_lock_tables({"pos_pos", "pos_doks"})
    return
endif

update_rec_server_and_dbf( "pos_doks", _rec, 1, "FULL" )

return



// --------------------------------------------
// vrati vrstu placanja
// --------------------------------------------
static function _get_vr_pl( cIdVrsta )
local cVrsta := "0"
local nTArea := SELECT()
local cVrstaNaz := ""

if EMPTY( cIdVrsta ) .or. cIdVrsta == "01"
	// ovo je gotovina
	return cVrsta
endif

O_VRSTEP
select vrstep
set order to tag "ID"
seek cIdVrsta

cVrstaNaz := ALLTRIM( vrstep->naz )

do case 
	case "KARTICA" $ cVrstaNaz
		cVrsta := "1"
	case "CEK" $ cVrstaNaz
		cVrsta := "2"
	case "VAUCER" $ cVrstaNaz
		cVrsta := "3"
    case "VIRMAN" $ cVrstaNaz
        cVrsta := "3"
	otherwise
		cVrsta := "0"
endcase 

select (nTArea)

return cVrsta



// --------------------------------------------
// stampa fiskalnog racuna TRING (www.kase.ba)
// --------------------------------------------
function _tring_rn( cIdPos, dDat, cBrRn )
local aRn := {}
local aKupac := nil
local nTArea := SELECT()
local nRbr := 1
local nCtrl := 0
local lStorno := .t.
local nErr := 0
local nPLU := 0

// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek cIdPos + "42" + DTOS(dDat) + cBrRn

do while !EOF() .and. field->idpos == cIdPos ;
		.and. field->idvd == "42" ;
		.and. DTOS(field->datum) == DTOS(dDat) ;
		.and. field->brdok == cBrRn

	if field->kolicina > 0
		lStorno := .f.
	endif

	cT_c_1 := ""

	if pos->(FIELDPOS("C_1")) <> 0
		// ovo je broj racuna koji se stornira 
		cT_c_1 := field->c_1
	endif

	cArtikal := field->idroba

	select roba
	seek cArtikal

	nPLU := roba->fisc_plu

	select pos

	++ nCtrl

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	cRobaNaz := ""
	_fix_naz( roba->naz, @cRobaNaz )
	
	AADD( aRn, { cBrRn, ;
		ALLTRIM(STR( ++nRbr )), ;
		field->idroba, ;
		cRobaNaz, ;
		field->cijena, ;
		field->ncijena, ;
		ABS( field->kolicina ), ;
		_g_tar(field->idtarifa), ;
		cT_c_1, ;
		field->datum, ;
		roba->jmj, ;
		nPLU } )

	skip
enddo

select (nTArea)

if nCtrl = 0
	msgbeep("fiskal: nema stavki za stampu !!!")
	nErr := 1
	return nErr
endif

// idemo sada na upis rn u fiskalni fajl
nErr := fc_trng_rn( ALLTRIM(gFc_path), ALLTRIM(gFc_name), ;
	aRn, aKupac, lStorno, gFc_error )

return nErr




// -------------------------------------------
// popravlja naziv artikla
// -------------------------------------------
static function _fix_naz( cR_naz, cNaziv )

// prvo ga srezi na LEN(30)
cNaziv := PADR( cR_naz, 30 )

do case

	case ALLTRIM(gFc_type) == "FLINK"
	
		// napravi konverziju karaktera 852 -> eng
		cNaziv := StrKzn( cNaziv, "8", "E" )

		// konvertuj naziv na LOWERCASE()
		// time rjesavamo i veliko slovo "V" prvo
		cNaziv := LOWER( cNaziv )

		// zamjeni sve zareze u nazivu sa tackom
		cNaziv := STRTRAN( cNaziv, ",", "." )

	case ALLTRIM(gFc_type) == "FPRINT"
		
		// napravi konverziju karaktera 852 -> win
		cNaziv := to_xml_encoding( cNaziv )
		
endcase

return


// ------------------------------------------
// vraca tarifu za fiskalni stampac
// ------------------------------------------
static function _g_tar( cIdTar )
cF_tar := "E"
do case
	case UPPER(cIdTar) = "PDV17"
		cF_tar := "E"
endcase
return cF_tar



// ------------------------------------------
// izvrsi fiskalnu komandu, ako postoji
// ------------------------------------------
static function _fc_cmd()
private cFcCmd := ""

if EMPTY( ALLTRIM( gFc_cmd ) )
	return
endif

cFcCmd := ALLTRIM( gFc_cmd )
cFcCmd := STRTRAN( cFcCmd, "$1", ALLTRIM(gFc_cp1) )
cFcCmd := STRTRAN( cFcCmd, "$2", ALLTRIM(gFc_cp2) )
cFcCmd := STRTRAN( cFcCmd, "$3", ALLTRIM(gFc_cp3) )
cFcCmd := STRTRAN( cFcCmd, "$4", ALLTRIM(gFc_cp4) )
cFcCmd := STRTRAN( cFcCmd, "$5", ALLTRIM(gFc_cp5) )

run &cFcCmd

return


