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


static __device_id := 0
static __device_params
static __DRV_TREMOL := "TREMOL"
static __DRV_FPRINT := "FPRINT"
static __DRV_FLINK := "FLINK"
static __DRV_HCP := "HCP"
static __DRV_TRING := "TRING"
static __DRV_CURRENT


// --------------------------------------
// stampa fiskalnog racuna
// --------------------------------------
function pos_fisc_rn( id_pos, datum, rn_broj, dev_params, uplaceni_iznos )
local _err_level := 0
local _dev_drv
local _storno
local _items, _head, _cont

if uplaceni_iznos == NIL
    uplaceni_iznos := 0
endif

if dev_params == NIL
    return _err_level
endif

// setuj parametre za dati uredjaj
__device_id := dev_params["id"]
__device_params := dev_params

// drajver ??
_dev_drv := __device_params["drv"]
__DRV_CURRENT := _dev_drv

_o_tables()

// priprema podataka

// da li je racun storno ?
_storno := pos_dok_is_storno( id_pos, "42", datum, rn_broj )
// spremi mi stavke racuna
_items := pos_items_prepare( id_pos, "42", datum, rn_broj, _storno, uplaceni_iznos )

if _items == NIL
    return _err_level
endif

do case

    // TEST uredjaj, prolazi fiskalna operacija
    case _dev_drv == "TEST"
        _err_level := 0
	
    case _dev_drv == __DRV_FPRINT
	    _err_level := pos_to_fprint( id_pos, "42", datum, rn_broj, _items, _storno )

    case _dev_drv == __DRV_FLINK
	    _err_level := pos_to_flink( id_pos, "42", datum, rn_broj, _items, _storno )

	case _dev_drv == __DRV_TRING
	    _err_level := pos_to_tring( id_pos, "42", datum, rn_broj, _items, _storno )

	case _dev_drv == __DRV_HCP
	    _err_level := pos_to_hcp( id_pos, "42", datum, rn_broj, _items, _storno, uplaceni_iznos )

	case _dev_drv == __DRV_TREMOL
        _cont := NIL
	    _err_level := pos_to_tremol( id_pos, "42", datum, rn_broj, _items, _storno, _cont )

endcase

if _err_level > 0
	
	if _dev_drv == __DRV_TREMOL
		
        _cont := "2"
	    _err_level := pos_to_tremol( id_pos, "42", datum, rn_broj, _items, _storno, _cont )

		if _err_level > 0
			msgbeep("Problem sa stampanjem na fiskalni stampac !!!")
		endif
	else
		// ima greska
		msgbeep("Problem sa stampanjem na fiskalni stampac !!!")
	endif
endif

return _err_level


// -----------------------------------------------
// otvori potrebne tabele
// -----------------------------------------------
static function _o_tables()
return



// ------------------------------------------------------------------
// da li je racun storno
// ------------------------------------------------------------------
static function pos_dok_is_storno( id_pos, tip_dok, datum, rn_broj )
local _storno := .f.

select pos
set order to tag "1"
go top
seek id_pos + tip_dok + DTOS( datum ) + rn_broj

do while !EOF() .and. field->idpos == id_pos ;
		.and. field->idvd == tip_dok ;
		.and. DTOS(field->datum) == DTOS( datum ) ;
		.and. field->brdok == rn_broj

	if !EMPTY( ALLTRIM( field->c_1 ) )
		_storno := .t.
        exit
	endif

    skip

enddo

return _storno



// ------------------------------------------------------------------
// priprema podataka racuna za ispis na fiskalni uredjaj
// ------------------------------------------------------------------
static function pos_items_prepare( id_pos, tip_dok, datum, rn_broj, storno, uplaceni_iznos )
local _items := {}
local _plu
local _reklamni_racun
local _rabat, _cijena
local _art_barkod, _art_id, _art_naz, _art_jmj
local _rbr := 0
local _rn_total
local _vr_plac
local _level

if uplaceni_iznos == NIL
    uplaceni_iznos := 0
endif

// pozicioniraj se na pos_doks
select pos_doks
set order to tag "1"
go top
seek id_pos + tip_dok + DTOS( datum ) + rn_broj

if !FOUND()
    return NIL
endif

// vrsta placanja
_vr_plac := pos_get_vr_plac( field->idvrstep )

// ako je vrsta placanja <> gotovina
if _vr_plac <> "0"
	// vrati mi iznos racuna
	_rn_total := pos_iznos_racuna( id_pos, tip_dok, datum, rn_broj )
endif

// ako postoji iznos uplate, onda je to total
// koji ce biti proslijedjen txt fajlu
if uplaceni_iznos > 0
    _rn_total := uplaceni_iznos
endif

// pronadji u bazi racun
select pos
set order to tag "1"
go top
seek id_pos + tip_dok + DTOS( datum ) + rn_broj

if !FOUND()
    return NIL
endif

do while !EOF() .and. field->idpos == id_pos ;
		.and. field->idvd == tip_dok ;
		.and. DTOS(field->datum) == DTOS( datum ) ;
		.and. field->brdok == rn_broj

	_reklamni_racun := ""
	_rabat := 0
	_plu := 0
	_cijena := 0
	_art_barkod := ""

	// ovo je broj racuna koji se stornira 
	_reklamni_racun := field->c_1

	_art_id := field->idroba

	select roba
	seek _art_id

	_plu := roba->fisc_plu

	if __device_params["plu_type"] == "D"
		// generisi PLU iz parametara
		_plu := auto_plu(nil, nil, __device_params )
	endif

	_cijena := pos_get_mpc()
	_art_barkod := roba->barkod
	_art_jmj := roba->jmj

	select pos

	if field->ncijena > 0
		_rabat := ( field->ncijena / field->cijena ) * 100
	endif

	// kolicina uvijek ide apsolutna vrijednost
	// storno racun fiskalni stampac tretira kao regularni unos

	_art_naz := fiscal_art_naz_fix( roba->naz, __device_params["drv"] )

	AADD( _items, { rn_broj, ;
		ALLTRIM( STR( ++ _rbr ) ), ;
		_art_id, ;
		_art_naz, ;
		field->cijena, ;
		ABS( field->kolicina ), ;
		field->idtarifa, ;
		_reklamni_racun, ;
		_plu, ;
		field->cijena, ;
		_rabat, ;
		_art_barkod, ;
		_vr_plac, ;
		_rn_total, ;
		datum, ;
		_art_jmj } )

	skip

enddo

if LEN( _items ) == 0
	msgbeep( "fiskal: nema stavki za stampu !!!" )
	return NIL
endif

_level := 1
// provjeri stavke racuna, kolicine, cijene
if fiscal_items_check( @_items, storno, _level, __device_params["drv"] ) < 0
	return NIL
endif

return _items




// -------------------------------------
// stampa fiskalnog racuna FPRINT
// -------------------------------------
static function pos_to_fprint( id_pos, tip_dok, datum, rn_broj, items, storno )
local _err_level := 0
local _fiscal_no := 0

// pobrisi answer fajl
fprint_delete_answer( __device_params )

// idemo sada na upis rn u fiskalni fajl
fprint_rn( __device_params, items, NIL, storno )

// iscitaj error
_err_level := fprint_read_error( __device_params, @_fiscal_no )

if _err_level = -9
	// nema answer fajla, da nije do trake ?
	if Pitanje(, "Da li je nestalo trake ?", "N" ) == "D"
		if Pitanje(,"Zamjenite traku i pritisnite 'D'","D") == "D"
			// iscitaj error
			_err_level := fprint_read_error( __device_params, @_fiscal_no )
		endif
	endif
endif

// fiskalni racun ne moze biti 0
if _fiscal_no <= 0
	_err_level := 1
endif

if _err_level <> 0
	// pobrisati out fajl obavezno
	// da ne bi otisao greskom na uredjaj kad proradi
	fprint_delete_out( __device_params )
	msgbeep("Postoji greska !!!")
else
    if _fiscal_no <> 0
		pos_doks_update_fisc_rn( id_pos, tip_dok, datum, rn_broj, _fiscal_no )
    	msgo( "Kreiran fiskalni racun broj: " + ALLTRIM( STR( _fiscal_no ) ) )
	    sleep(2)
        msgc()
	endif
endif

return _err_level




// -------------------------------------
// stampa fiskalnog racuna FLINK
// -------------------------------------
static function pos_to_flink( id_pos, tip_dok, datum, rn_broj, items, storno )
local _err_level := 0
// idemo sada na upis rn u fiskalni fajl
_err_level := fc_pos_rn( __device_params, items, storno )
return _err_level




// --------------------------------------------
// stampa fiskalnog racuna TREMOL 
// --------------------------------------------
static function pos_to_tremol( id_pos, tip_dok, datum, rn_broj, items, storno, cont )
local _err_level := 0
local _f_name 
local _fiscal_no := 0

if cont == NIL
    cont := "0"
endif
	
// idemo sada na upis rn u fiskalni fajl
_err_level := tremol_rn( __device_params, items, NIL, storno, cont )

if cont <> "2"
	
    // naziv fajla
    _f_name := fiscal_out_filename( __device_params["out_file"], rn_broj )

	if tremol_read_out( __device_params, _f_name )
		
		// procitaj poruku greske
		_err_level := tremol_read_error( __device_params, _f_name, @_fiscal_no ) 

		if _err_level = 0 .and. !storno .and. _fiscal_no > 0

            pos_doks_update_fisc_rn( id_pos, tip_dok, datum, rn_broj, _fiscal_no )	

			msgbeep( "Kreiran fiskalni racun: " + ALLTRIM( STR( _fiscal_no ) ) )
			
		endif
	
	endif
	
	// obrisi fajl
	// da ne bi ostao kada server proradi ako je greska
	FERASE( __device_params["out_dir"] + _f_name )

endif

return _err_level




// --------------------------------------------
// stampa fiskalnog racuna HCP
// --------------------------------------------
static function pos_to_hcp( id_pos, tip_dok, datum, rn_broj, items, storno, uplaceni_iznos )
local _err_level := 0
local _fiscal_no := 0

if uplaceni_iznos == NIL
    uplaceni_iznos := 0
endif

_err_level := hcp_rn( __device_params, items, NIL, storno, uplaceni_iznos )

if _err_level = 0
	
	// vrati broj racuna
	_fiscal_no := hcp_fisc_no( __device_params, storno )
	
    if _fiscal_no > 0
        pos_doks_update_fisc_rn( id_pos, tip_dok, datum, rn_broj, _fiscal_no )
    endif

endif

return _err_level


// ------------------------------------------------
// update broj fiskalnog racuna
// ------------------------------------------------
static function pos_doks_update_fisc_rn( id_pos, tip_dok, datum, rn_broj, fisc_no )
local _rec

select pos_doks
set order to tag "1"
go top

seek id_pos + tip_dok + DTOS( datum ) + rn_broj

if !FOUND()
    return
endif

_rec := dbf_get_rec()
_rec["fisc_rn"] := fisc_no

update_rec_server_and_dbf( "pos_doks", _rec, 1, "FULL" )

return



// --------------------------------------------
// vrati vrstu placanja
// --------------------------------------------
static function pos_get_vr_plac( id_vr_pl )
local _ret := "0"
local _t_area := SELECT()
local _naz := ""

if EMPTY( id_vr_pl ) .or. id_vr_pl == "01"
	// ovo je gotovina
	return _naz
endif

O_VRSTEP
select vrstep
set order to tag "ID"
seek id_vr_pl

_naz := ALLTRIM( vrstep->naz )

do case 
	case "KARTICA" $ _naz
		_ret := "1"
	case "CEK" $ _naz
		_ret := "2"
	case "VAUCER" $ _naz
		_ret := "3"
    case "VIRMAN" $ _naz
        _ret := "3"
	otherwise
		_ret := "0"
endcase 

select ( _t_area )

return _ret



// --------------------------------------------
// stampa fiskalnog racuna TRING (www.kase.ba)
// --------------------------------------------
static function pos_to_tring( id_pos, tip_dok, datum, rn_broj, items, storno )
local _err_level := 0
_err_level := tring_rn( __device_params, items, NIL, storno )
return _err_level




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
	
endcase

return





