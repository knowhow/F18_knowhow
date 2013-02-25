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


// ---------------------------------------------
// stampa dokumenta kalkulacija cijena vp (odt)
// ---------------------------------------------
function kalkulacija_cijena( azurirana )
local _vars
local _template
local _tip := "V"
local _predisp := .f.

if azurirana == NIL
    azurirana := .t.
endif

// otvori sve potrebne tabele
o_tables( azurirana )

// uslovi
if azurirana .and. !get_vars( @_vars )
    return
endif

if !azurirana
    // podatke uzmi odmah iz pripreme
    _vars := hb_hash()
    _vars["id_firma"] := kalk_pripr->idfirma
    _vars["tip_dok"] := kalk_pripr->idvd
    _vars["br_dok"] := kalk_pripr->brdok
endif 

// utvrdi o kojoj se radi kalkulaciji ?
// provjeri da li dokument moze da se stampa
if ! (_vars["tip_dok"] $ "10#81#80" )
    return
endif

if _vars["tip_dok"] $ "10"

    _tip := "V"
    _template := "kalk_vp.odt"

elseif _vars["tip_dok"] $ "80#81"

    _tip := "M"
    _template := "kalk_mp.odt"

	if mp_predispozicija( _vars["id_firma"], _vars["tip_dok"], _vars["br_dok"] )
		_template := "kalk_mp_pred.odt"
		_predisp := .t.
	endif

endif

// ima li template fajla ?
if !FILE( F18_TEMPLATE_LOCATION + _template )
    MsgBeep( "Template fajl ne postoji: " + F18_TEMPLATE_LOCATION + _template )
    return
endif

// pretrazi mi dokument u bazi
if !seek_dokument( _vars, azurirana )
    // ako ga nema, sta drugo nego da izadjes !!
    return
endif        

// sta raditi ?
do case

	case _predisp == .t.
		
        // generisi i stampaj kalkulaciju predispoziciju
        if gen_kalk_predispozicija_xml( _vars ) > 0
            st_kalkulacija_cijena_odt( _template )
        endif

    case _tip == "M"
        
        // generisi i stampaj kalkulaciju mp
        if gen_kalk_mp_xml( _vars ) > 0
            st_kalkulacija_cijena_odt( _template )
        endif

    case _tip == "V"
    
        // generisi i stampaj kalkulaciju vp
        if gen_kalk_vp_xml( _vars ) > 0
            st_kalkulacija_cijena_odt( _template )
        endif

endcase

return


// da li se radi o dokumentu predispozicije
function mp_predispozicija( firma, tip_dok, br_dok )
local _ret := .f.
local _t_area := SELECT()
local _rec

if tip_dok <> "80"
	return _ret
endif

select kalk_pripr
go top
seek firma + tip_dok + br_dok

_rec := RECNO()

do while !EOF() .and. field->idfirma + field->idvd + field->brdok == firma + tip_dok + br_dok
	if field->idkonto2 = "XXX"
		_ret := .t.
		exit	
	endif
	skip
enddo

select ( _t_area )
return _ret



// ----------------------------------------------
// stampaj odt dokument
// ----------------------------------------------
static function st_kalkulacija_cijena_odt( template_file )

if f18_odt_generate( template_file )
    f18_odt_print()
endif

return


// ----------------------------------------------
// otvara potrebne tabele za stampu
// ----------------------------------------------
static function o_tables( azurirana )

select F_KONCIJ
if !USED()
    O_KONCIJ
endif

select F_ROBA
if !USED()
    O_ROBA
endif

select F_TARIFA
if !USED()
    O_TARIFA
endif

select F_PARTN
if !USED()
    O_PARTN
endif

select F_KONTO
if !USED()
    O_KONTO
endif

select F_TDOK
if !USED()
    O_TDOK
endif

// azurirana otvara kalk, ali kao alijas kalk_pripr
if azurirana
    O_SKALK   
else
    O_KALK_PRIPR
endif

// pozicioniraj se odmah na prvi zapis
select kalk_pripr
set order to tag "1"
go top

return


// ---------------------------------------------
// uslovi za dokument
// ---------------------------------------------
static function get_vars( vars )
local _firma := gFirma
local _tip := "10"
local _broj := SPACE(8)
local _ret := .f.

Box(,1,40)
    @ m_x + 1, m_y + 2 SAY "Broj dokumenta:" 
    @ m_x + 1, col() + 1 GET _firma 
    @ m_x + 1, col() + 1 SAY "-" GET _tip VALID !EMPTY( _tip )
    @ m_x + 1, col() + 1 SAY "-" GET _broj VALID !EMPTY( _broj )
    read
BoxC()

if LastKey() == K_ESC
    return _ret
endif

vars := hb_hash()
vars["id_firma"] := _firma
vars["tip_dok"] := _tip
vars["br_dok"] := _broj

return .t.


// ---------------------------------------------------
// pretrazi dokument u bazi
// ---------------------------------------------------
static function seek_dokument( vars, azurirani )
local _firma := vars["id_firma"]
local _tip_dok := vars["tip_dok"]
local _br_dok := vars["br_dok"]

select kalk_pripr
set order to tag "1"
go top

// samo ako je azurirani
// ako je u pripremi bitno je samo pozicionirati se na pocetak

if azurirani

    seek _firma + _tip_dok + _br_dok

    if !FOUND()
        MsgBeep( "Trazeni dokument " + _firma + "-" + _tip_dok + "-" + ALLTRIM(_br_dok) + " ne postoji !" )
        return .f.
    endif

endif

return .t.

// ---------------------------------------------
// generisanje xml fajla za kalk_mp_pred
// ---------------------------------------------
static function gen_kalk_predispozicija_xml( vars )
local _firma := vars["id_firma"]
local _tip_dok := vars["tip_dok"]
local _br_dok := vars["br_dok"]
local _generated := 0
local _xml_file := my_home() + "data.xml"
local _t_rec
local _redni_broj := 0
local _porezna_stopa, _porez
local _s_kolicina, _tmp, _a_porezi
local _u_porez, _t_porez, _u_pv, _t_pv, _u_pv_porez, _t_pv_porez, _t_kol
local _razd_id, _razd_naz
local _zad_id, _zad_naz
local _dio

private nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2
private aPorezi := {}

// seek-uj i ostale bitne tabele
select konto
hseek kalk_pripr->pkonto

_razd_id := kalk_pripr->pkonto
_razd_naz := konto->naz

go top
hseek kalk_pripr->idkonto2

_zad_id := kalk_pripr->idkonto2
_zad_naz := konto->naz

select tdok
hseek kalk_pripr->idvd

select kalk_pripr

// zapamti prvi zapis
_t_rec := RECNO()

// napuni mi xml fajl...
open_xml( _xml_file )
// upisi standardni xml header
xml_head()

// <kalkulacija>
xml_subnode("kalk", .f. )

// osnovni podaci organizacije
xml_node( "org_id", ALLTRIM( gFirma ) )
xml_node( "org_naziv", to_xml_encoding( ALLTRIM( gNFirma ) ) )

// podaci dokumenta
xml_node( "dok_naziv", to_xml_encoding( ALLTRIM( tdok->naz ) ) )
xml_node( "dok_tip", field->idvd )
xml_node( "dok_broj", to_xml_encoding( ALLTRIM( _br_dok ) ) )
xml_node( "dok_datum", DTOC( field->datdok ) )

// podaci o kontima / zaduzuje
xml_node( "zad_id", to_xml_encoding( ALLTRIM( _zad_id ) ) )
xml_node( "zad_naz", to_xml_encoding( ALLTRIM( _zad_naz ) ) )

// podaci o kontima / razduzuje
xml_node( "razd_id", to_xml_encoding( ALLTRIM( _razd_id ) ) )
xml_node( "razd_naz", to_xml_encoding( ALLTRIM( _razd_naz ) ) )

xml_node( "rn_broj", to_xml_encoding( ALLTRIM( field->brfaktp ) ) )
xml_node( "rn_datum", DTOC( field->datfaktp ) )

// 2 dijela predispozicije
for _dio := 1 to 2

	if _dio == 1
		xml_subnode( "razd", .f. )
	else
		xml_subnode( "zad", .f. )
	endif
	
	// resetuj redni broj
	_redni_broj := 0

	// opet se vrati na pocetak dokumenta
	select kalk_pripr
	go top
	seek _firma + _tip_dok + _br_dok

	_u_nv := _t_nv := _u_marza := _t_marza := 0
	_u_porez := _t_porez := 0
	_u_pv := _t_pv := _u_pv_porez := _t_pv_porez := 0
	_t_kol := 0

	// prodji kroz dokument...
	do while !EOF() .and. _firma == field->idfirma .and. _tip_dok == field->idvd .and. _br_dok == field->brdok 
  
		if _dio == 1
			if field->idkonto2 = "XXX"
				skip
				loop
			endif
		else
			if field->idkonto2 <> "XXX"
				skip
				loop
			endif
		endif

    	++ _generated 

    	// kalkulisi troskove
   	 	KTroskovi()
    	// pozicioniraj se na robu, tarifu itd...
    	RptSeekRT()
    	// porezna stopa
    	_porezna_stopa := tarifa->opp
    	// napuni matricu sa porezima
    	Tarifa( field->pkonto, field->idroba, @aPorezi )
    	// racunaj poreze...
    	_a_porezi := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
    	// iznos poreza
   	 	_porez := _a_porezi[ 1 ]

    	_s_kolicina := field->kolicina - field->gkolicina - field->gkolicin2
    	_t_kol += _s_kolicina

		// nabavna vrijednost
    	_u_nv := ROUND( field->nc * _s_kolicina, gZaokr )
    	_t_nv += _u_nv

    	// marza
    	_u_marza := ROUND( nMarza2 * _s_kolicina, gZaokr )
    	_t_marza += _u_marza

    	// prodajna cijena
    	_u_pv := ROUND( field->mpc * _s_kolicina, gZaokr )
   	 	_t_pv += _u_pv

    	// total porez
    	_u_porez := ( _porez * field->kolicina )
    	_t_porez += _u_porez

    	// prodajna vrijednost sa porezom
    	_u_pv_porez := ( field->mpcsapp * field->kolicina )
    	_t_pv_porez += _u_pv_porez

    	xml_subnode("stavka", .f. )

    	// podaci artikla
    	xml_node( "art_id", to_xml_encoding( ALLTRIM( field->idroba ) ) )
    	xml_node( "art_naz", to_xml_encoding( ALLTRIM( roba->naz ) ) + IIF( lKoristitiBK, ", BK: " + roba->barkod , "" ) )
    	xml_node( "art_jmj", to_xml_encoding( ALLTRIM( roba->jmj ) ) )
    	xml_node( "tarifa", to_xml_encoding( ALLTRIM( field->idtarifa ) ) )
    	xml_node( "rbr", PADL( ALLTRIM( STR( ++_redni_broj ) ), 4 ) + "." )

    	// kolicine
    	xml_node( "kol", STR( field->kolicina, 12, 2 ) )
    	xml_node( "g_kol", STR( field->gkolicina, 12, 2 ) )
    	xml_node( "g_kol2", STR( field->gkolicin2, 12, 2 ) )
    	xml_node( "skol", STR( _s_kolicina, 12, 2 ) )
    
    	// jedinicne cijene itd...
    
    	xml_node( "nc", STR( field->nc, 12, 2 ) )
    	xml_node( "marzap", STR( nMarza2 / field->nc * 100, 12, 2 ) )
    	xml_node( "marza", STR( nMarza2, 12, 2 ) )
    	xml_node( "pc", STR( field->mpc, 12, 2 ) )
    	xml_node( "por_st", STR( _porezna_stopa, 12, 2 ) )
    	xml_node( "porez", STR( _porez, 12, 2 ) )
    	xml_node( "pcsap", STR( field->mpcsapp, 12, 2 ) )

    	// ukupne ostale cijene ...
    	xml_node( "unv", STR( _u_nv, 12, 2 ) )
    	xml_node( "umarza", STR( _u_marza, 12, 2 ) )
    	xml_node( "upv", STR( _u_pv, 12, 2 ) )
    	xml_node( "upor", STR( _u_porez, 12, 2 ) )
    	xml_node( "upvp", STR( _u_pv_porez, 12, 2 ) )

    	xml_subnode("stavka", .t. )

    	skip

	enddo

	// ukupne vrijednosti za dokument
	xml_node( "tkol", STR( _t_kol, 12, 2 ) )
	xml_node( "tnv", STR( _t_nv, 12, 2 ) )
	xml_node( "tmarza", STR( _t_marza, 12, 2 ) )
	xml_node( "tpv", STR( _t_pv, 12, 2 ) )
	xml_node( "tpor", STR( _t_porez, 12, 2 ) )
	xml_node( "tpvp", STR( _t_pv_porez, 12, 2 ) )

	if _dio == 1
		xml_subnode( "razd", .t. )
	else
		xml_subnode( "zad", .t. )
	endif

next

// zatvori subnode...
xml_subnode("kalk", .t. )

// zatvori xml fajl
close_xml()

return _generated






// ---------------------------------------------
// generisanje xml fajla za kalk_mp
// ---------------------------------------------
static function gen_kalk_mp_xml( vars )
local _firma := vars["id_firma"]
local _tip_dok := vars["tip_dok"]
local _br_dok := vars["br_dok"]
local _generated := 0
local _xml_file := my_home() + "data.xml"
local _t_rec
local _redni_broj := 0
local _porezna_stopa, _porez
local _s_kolicina, _tmp, _a_porezi
local _u_fv, _t_fv, _u_fv_r, _t_fv_r, _u_tr_prevoz, _u_tr_bank, _u_tr_carina, _u_tr_zavisni, _u_tr_sped, _u_tr_svi
local _t_tr_prevoz, _t_tr_bank, _t_tr_carina, _t_tr_zavisni, _t_tr_sped, _t_tr_svi, _u_nv, _t_nv, _u_marza, _t_marza
local _u_porez, _t_porez, _u_pv, _t_pv, _u_pv_porez, _t_pv_porez, _t_kol, _u_rabat, _t_rabat

private nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2
private aPorezi := {}

// seek-uj i ostale bitne tabele
select konto
hseek kalk_pripr->pkonto

select partn
hseek kalk_pripr->idpartner

select tdok
hseek kalk_pripr->idvd

select kalk_pripr

// zapamti prvi zapis
_t_rec := RECNO()

// napuni mi xml fajl...
open_xml( _xml_file )
// upisi standardni xml header
xml_head()

// <kalkulacija>
xml_subnode("kalk", .f. )

// osnovni podaci organizacije
xml_node( "org_id", ALLTRIM( gFirma ) )
xml_node( "org_naziv", to_xml_encoding( ALLTRIM( gNFirma ) ) )

// podaci dokumenta
xml_node( "dok_naziv", to_xml_encoding( ALLTRIM( tdok->naz ) ) )
xml_node( "dok_tip", field->idvd )
xml_node( "dok_broj", to_xml_encoding( ALLTRIM( _br_dok ) ) )
xml_node( "dok_datum", DTOC( field->datdok ) )

// podaci o kontima
xml_node( "zad_id", to_xml_encoding( ALLTRIM( field->pkonto ) ) )
xml_node( "zad_naz", to_xml_encoding( ALLTRIM( konto->naz ) ) )

// podaci o dobavljacu i veznom racunu
xml_node( "dob_id", to_xml_encoding( ALLTRIM( field->idpartner ) ) )
xml_node( "dob_naziv", to_xml_encoding( ALLTRIM( partn->naz ) ) )
xml_node( "rn_broj", to_xml_encoding( ALLTRIM( field->brfaktp ) ) )
xml_node( "rn_datum", DTOC( field->datfaktp ) )

_u_fv := _t_fv := 0
_u_fv_r := _t_fv_r := 0
_u_tr_prevoz := _u_tr_bank := _u_tr_carina := _u_tr_zavisni := _u_tr_sped := _u_tr_svi := 0
_t_tr_prevoz := _t_tr_bank := _t_tr_carina := _t_tr_zavisni := _t_tr_sped := _t_tr_svi := 0
_u_nv := _t_nv := _u_marza := _t_marza := 0
_u_porez := _t_porez := 0
_u_pv := _t_pv := _u_pv_porez := _t_pv_porez := 0
_t_kol := 0
_u_rabat := _t_rabat := 0

// prodji kroz dokument...
do while !EOF() .and. _firma == field->idfirma .and. _tip_dok == field->idvd .and. _br_dok == field->brdok 
  
    ++ _generated 

    // kalkulisi troskove
    KTroskovi()
    // pozicioniraj se na robu, tarifu itd...
    RptSeekRT()
    // porezna stopa
    _porezna_stopa := tarifa->opp
    // napuni matricu sa porezima
    Tarifa( field->pkonto, field->idroba, @aPorezi )
    // racunaj poreze...
    _a_porezi := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
    // iznos poreza
    _porez := _a_porezi[ 1 ]

    _s_kolicina := field->kolicina - field->gkolicina - field->gkolicin2
    _t_kol += _s_kolicina

    // fakturna cijena vrijednost
    _u_fv := ROUND( field->fcj * field->kolicina, gZaokr )
    _u_fv += ROUND( field->fcj2 * ( field->gkolicina + field->gkolicin2 ), gZaokr )
    _t_fv += _u_fv

    // rabati
    _u_rabat := ROUND( -field->rabat, gZaokr )
    _t_rabat += _u_rabat
    
    _u_fv_r := ROUND( -field->rabat / 100 * field->fcj * field->kolicina, gZaokr )
    _t_fv_r += _u_fv_r

    // troskovi
    _u_tr_prevoz := ROUND( nPrevoz * _s_kolicina, gZaokr )
    _u_tr_bank := ROUND( nBankTr * _s_kolicina, gZaokr )
    _u_tr_sped := ROUND( nSpedTr * _s_kolicina, gZaokr )
    _u_tr_carina := ROUND( nCarDaz * _s_kolicina, gZaokr )
    _u_tr_zavisni := ROUND( nZavTr* _s_kolicina, gZaokr )
    // svi troskovi zajedno
    _u_tr_svi := ( _u_tr_prevoz + _u_tr_bank + _u_tr_sped + _u_tr_carina + _u_tr_zavisni )

    _t_tr_prevoz += _u_tr_prevoz
    _t_tr_bank += _u_tr_bank
    _t_tr_sped += _u_tr_sped
    _t_tr_carina += _u_tr_carina
    _t_tr_zavisni += _u_tr_zavisni
    _t_tr_svi += _u_tr_svi

    // nabavna vrijednost
    _u_nv := ROUND( field->nc * _s_kolicina, gZaokr )
    _t_nv += _u_nv

    // marza
    _u_marza := ROUND( nMarza2 * _s_kolicina, gZaokr )
    _t_marza += _u_marza

    // prodajna cijena
    _u_pv := ROUND( field->mpc * _s_kolicina, gZaokr )
    _t_pv += _u_pv

    // total porez
    _u_porez := ( _porez * field->kolicina )
    _t_porez += _u_porez

    // prodajna vrijednost sa porezom
    _u_pv_porez := ( field->mpcsapp * field->kolicina )
    _t_pv_porez += _u_pv_porez

    xml_subnode("stavka", .f. )

    // podaci artikla
    xml_node( "art_id", to_xml_encoding( ALLTRIM( field->idroba ) ) )
    xml_node( "art_naz", to_xml_encoding( ALLTRIM( roba->naz ) ) + IIF( lKoristitiBK, ", BK: " + roba->barkod , "" ) )
    xml_node( "art_jmj", to_xml_encoding( ALLTRIM( roba->jmj ) ) )
    xml_node( "tarifa", to_xml_encoding( ALLTRIM( field->idtarifa ) ) )
    xml_node( "rbr", PADL( ALLTRIM( STR( ++_redni_broj ) ), 4 ) + "." )

    // kolicine
    xml_node( "kol", STR( field->kolicina, 12, 2 ) )
    xml_node( "g_kol", STR( field->gkolicina, 12, 2 ) )
    xml_node( "g_kol2", STR( field->gkolicin2, 12, 2 ) )
    xml_node( "skol", STR( _s_kolicina, 12, 2 ) )
    
    // jedinicne cijene itd...
    
    xml_node( "fcj", STR( field->fcj, 12, 2 ) )
    xml_node( "rabat", STR( -field->rabat, 12, 2 ) )
    xml_node( "fcjr", STR( -field->rabat/100 * field->fcj, 12, 2 ) )
    xml_node( "nc", STR( field->nc, 12, 2 ) )
    xml_node( "marzap", STR( nMarza2 / field->nc * 100, 12, 2 ) )
    xml_node( "marza", STR( nMarza2, 12, 2 ) )
    xml_node( "pc", STR( field->mpc, 12, 2 ) )
    xml_node( "por_st", STR( _porezna_stopa, 12, 2 ) )
    xml_node( "porez", STR( _porez, 12, 2 ) )
    xml_node( "pcsap", STR( field->mpcsapp, 12, 2 ) )

    // troskovi
    _pr_tr_prev := if( nPrevoz <> 0, nPrevoz / field->fcj2 * 100, 0 )
    _pr_tr_bank := if( nBankTr <> 0, nBankTr / field->fcj2 * 100, 0 )
    _pr_tr_sped := if( nSpedTr <> 0, nSpedTr / field->fcj2 * 100, 0 )
    _pr_tr_car := if( nCarDaz <> 0, nCarDaz / field->fcj2 * 100, 0 )
    _pr_tr_zav := if( nZavTr <> 0, nZavTr / field->fcj2 * 100, 0 )
    _pr_tr_svi := ( _pr_tr_prev + _pr_tr_bank + _pr_tr_sped + _pr_tr_car + _pr_tr_zav )
 
    // procenti troskova
    xml_node( "tr1p", STR( _pr_tr_prev, 12, 2 ) )
    xml_node( "tr2p", STR( _pr_tr_bank, 12, 2 ) )
    xml_node( "tr3p", STR( _pr_tr_sped, 12, 2 ) )
    xml_node( "tr4p", STR( _pr_tr_car, 12, 2 ) )
    xml_node( "tr5p", STR( _pr_tr_zav, 12, 2 ) )
    xml_node( "trsp", STR( _pr_tr_svi, 12, 2 ) )
    
    // iznosi troskova
    _tmp := nPrevoz + nBankTr + nSpedTr + nCarDaz + nZavTr
    xml_node( "tr1", STR( nPrevoz, 12, 2 ) )
    xml_node( "tr2", STR( nBankTr, 12, 2 ) )
    xml_node( "tr3", STR( nSpedTr, 12, 2 ) )
    xml_node( "tr4", STR( nCarDaz, 12, 2 ) )
    xml_node( "tr5", STR( nZavTr, 12, 2 ) )
    xml_node( "trs", STR( _tmp, 12, 2 ) )

    // ukupne vrijednosti po stavkama
    xml_node( "ufv", STR( _u_fv, 12, 2 ) )
    xml_node( "ufvr", STR( _u_fv_r, 12, 2 ) )
    // ukupni troskovi    
    xml_node( "utr1", STR( _u_tr_prevoz, 12, 2 ) )
    xml_node( "utr2", STR( _u_tr_bank, 12, 2 ) )
    xml_node( "utr3", STR( _u_tr_sped, 12, 2 ) )
    xml_node( "utr4", STR( _u_tr_carina, 12, 2 ) )
    xml_node( "utr5", STR( _u_tr_zavisni, 12, 2 ) )
    xml_node( "utrs", STR( _u_tr_svi, 12, 2 ) )
    // ukupne ostale cijene ...
    xml_node( "unv", STR( _u_nv, 12, 2 ) )
    xml_node( "umarza", STR( _u_marza, 12, 2 ) )
    xml_node( "upv", STR( _u_pv, 12, 2 ) )
    xml_node( "upor", STR( _u_porez, 12, 2 ) )
    xml_node( "upvp", STR( _u_pv_porez, 12, 2 ) )

    xml_subnode("stavka", .t. )

    skip

enddo

// ukupne vrijednosti za dokument
xml_node( "tkol", STR( _t_kol, 12, 2 ) )
xml_node( "tfv", STR( _t_fv, 12, 2 ) )
xml_node( "tfvr", STR( _t_fv_r, 12, 2 ) )
xml_node( "ttr1", STR( _t_tr_prevoz, 12, 2 ) )
xml_node( "ttr2", STR( _t_tr_bank, 12, 2 ) )
xml_node( "ttr3", STR( _t_tr_sped, 12, 2 ) )
xml_node( "ttr4", STR( _t_tr_carina, 12, 2 ) )
xml_node( "ttr5", STR( _t_tr_zavisni, 12, 2 ) )
xml_node( "ttrs", STR( _t_tr_svi, 12, 2 ) )
xml_node( "tnv", STR( _t_nv, 12, 2 ) )
xml_node( "tmarza", STR( _t_marza, 12, 2 ) )
xml_node( "tpv", STR( _t_pv, 12, 2 ) )
xml_node( "tpor", STR( _t_porez, 12, 2 ) )
xml_node( "tpvp", STR( _t_pv_porez, 12, 2 ) )

// zatvori subnode...
xml_subnode("kalk", .t. )

// zatvori xml fajl
close_xml()

return _generated




// ---------------------------------------------
// generisanje xml fajla za kalk_vp
// ---------------------------------------------
static function gen_kalk_vp_xml( vars )
local _firma := vars["id_firma"]
local _tip_dok := vars["tip_dok"]
local _br_dok := vars["br_dok"]
local _generated := 0
local _xml_file := my_home() + "data.xml"
local _t_rec
local _redni_broj := 0
local _porezna_stopa, _porez
local _s_kolicina, _tmp
local _u_fv, _t_fv, _u_fv_r, _t_fv_r, _u_tr_prevoz, _u_tr_bank, _u_tr_carina, _u_tr_zavisni, _u_tr_sped, _u_tr_svi
local _t_tr_prevoz, _t_tr_bank, _t_tr_carina, _t_tr_zavisni, _t_tr_sped, _t_tr_svi, _u_nv, _t_nv, _u_marza, _t_marza
local _u_porez, _t_porez, _u_pv, _t_pv, _u_pv_porez, _t_pv_porez, _t_kol, _u_rabat, _t_rabat
local _ima_mpcsapp := .f.

private nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

// seek-uj i ostale bitne tabele
select konto
hseek kalk_pripr->mkonto

select partn
hseek kalk_pripr->idpartner

select tdok
hseek kalk_pripr->idvd

select kalk_pripr

// zapamti prvi zapis
_t_rec := RECNO()

// napuni mi xml fajl...
open_xml( _xml_file )
// upisi standardni xml header
xml_head()

// <kalkulacija>
xml_subnode("kalk", .f. )

// osnovni podaci organizacije
xml_node( "org_id", ALLTRIM( gFirma ) )
xml_node( "org_naziv", to_xml_encoding( ALLTRIM( gNFirma ) ) )

// podaci dokumenta
xml_node( "dok_naziv", to_xml_encoding( ALLTRIM( tdok->naz ) ) )
xml_node( "dok_tip", field->idvd )
xml_node( "dok_broj", to_xml_encoding( ALLTRIM( _br_dok ) ) )
xml_node( "dok_datum", DTOC( field->datdok ) )

// podaci o kontima
xml_node( "zad_id", to_xml_encoding( ALLTRIM( field->mkonto ) ) )
xml_node( "zad_naz", to_xml_encoding( ALLTRIM( konto->naz ) ) )

// podaci o dobavljacu i veznom racunu
xml_node( "dob_id", to_xml_encoding( ALLTRIM( field->idpartner ) ) )
xml_node( "dob_naziv", to_xml_encoding( ALLTRIM( partn->naz ) ) )
xml_node( "rn_broj", to_xml_encoding( ALLTRIM( field->brfaktp ) ) )
xml_node( "rn_datum", DTOC( field->datfaktp ) )

_u_fv := _t_fv := 0
_u_fv_r := _t_fv_r := 0
_u_tr_prevoz := _u_tr_bank := _u_tr_carina := _u_tr_zavisni := _u_tr_sped := _u_tr_svi := 0
_t_tr_prevoz := _t_tr_bank := _t_tr_carina := _t_tr_zavisni := _t_tr_sped := _t_tr_svi := 0
_u_nv := _t_nv := _u_marza := _t_marza := 0
_u_porez := _t_porez := 0
_u_pv := _t_pv := _u_pv_porez := _t_pv_porez := 0
_t_kol := 0
_u_rabat := _t_rabat := 0

// prodji kroz dokument...
do while !EOF() .and. _firma == field->idfirma .and. _tip_dok == field->idvd .and. _br_dok == field->brdok 
  
    ++ _generated 

    // seek-uje robu 
    RptSeekRT()

    // selektuje troskove
    KTroskovi()
    
    _porezna_stopa := tarifa->opp

    _ima_mpcsapp := .f.

    // sta ako ima poreza, sta ako nema poreza
    if ROUND( field->mpcsapp, 2 ) == 0
        // ako ga nema, koristi na osnovu VPC
        _porez := field->vpc * ( _porezna_stopa / 100 )
    else
        // ako ima, koristi polje MPCSAPP
        _porez := field->mpcsapp / ( 1 + ( _porezna_stopa / 100 ) ) * ( _porezna_stopa / 100 )
        _ima_mpcsapp := .t.
    endif

    _s_kolicina := field->kolicina - field->gkolicina - field->gkolicin2
    _t_kol += _s_kolicina

    // fakturna cijena vrijednost
    _u_fv := ROUND( field->fcj * field->kolicina, gZaokr )
    _u_fv += ROUND( field->fcj2 * ( field->gkolicina + field->gkolicin2 ), gZaokr )
    _t_fv += _u_fv

    // rabati
    _u_rabat := ROUND( -field->rabat, gZaokr )
    _t_rabat += _u_rabat

    _u_fv_r := ROUND( -field->rabat / 100 * field->fcj * field->kolicina, gZaokr )
    _t_fv_r += _u_fv_r

    // troskovi
    _u_tr_prevoz := ROUND( nPrevoz * _s_kolicina, gZaokr )
    _u_tr_bank := ROUND( nBankTr * _s_kolicina, gZaokr )
    _u_tr_sped := ROUND( nSpedTr * _s_kolicina, gZaokr )
    _u_tr_carina := ROUND( nCarDaz * _s_kolicina, gZaokr )
    _u_tr_zavisni := ROUND( nZavTr* _s_kolicina, gZaokr )
    // svi troskovi zajedno
    _u_tr_svi := ( _u_tr_prevoz + _u_tr_bank + _u_tr_sped + _u_tr_carina + _u_tr_zavisni )

    _t_tr_prevoz += _u_tr_prevoz
    _t_tr_bank += _u_tr_bank
    _t_tr_sped += _u_tr_sped
    _t_tr_carina += _u_tr_carina
    _t_tr_zavisni += _u_tr_zavisni
    _t_tr_svi += _u_tr_svi

    // nabavna vrijednost
    _u_nv := ROUND( field->nc * _s_kolicina, gZaokr )
    _t_nv += _u_nv

    // marza
    _u_marza := ROUND( nMarza * _s_kolicina, gZaokr )
    _t_marza += _u_marza

    // prodajna cijena
    _u_pv := ROUND( field->vpc * _s_kolicina, gZaokr )
    _t_pv += _u_pv

    // total porez
    _u_porez := ( _porez * field->kolicina )
    _t_porez += _u_porez

    // prodajna vrijednost sa porezom
    if _ima_mpcsapp
        // ako postoji u bazi mpcsapp koristi nju
        _u_pv_porez := ( field->mpcsapp * field->kolicina )
    else
        // koristi racunicu na osnovu vpc i poreza
        _u_pv_porez := _u_pv + _u_porez
    endif
    _t_pv_porez += _u_pv_porez

    xml_subnode("stavka", .f. )

    // podaci artikla
    xml_node( "art_id", to_xml_encoding( ALLTRIM( field->idroba ) ) )
    xml_node( "art_naz", to_xml_encoding( ALLTRIM( roba->naz ) ) )
    xml_node( "art_jmj", to_xml_encoding( ALLTRIM( roba->jmj ) ) )
    xml_node( "tarifa", to_xml_encoding( ALLTRIM( field->idtarifa ) ) )
    xml_node( "rbr", PADL( ALLTRIM( STR( ++_redni_broj ) ), 4 ) + "." )

    // kolicine
    xml_node( "kol", STR( field->kolicina, 12, 2 ) )
    xml_node( "g_kol", STR( field->gkolicina, 12, 2 ) )
    xml_node( "g_kol2", STR( field->gkolicin2, 12, 2 ) )
    xml_node( "skol", STR( _s_kolicina, 12, 2 ) )
    
    // jedinicne cijene itd...
    
    xml_node( "fcj", STR( field->fcj, 12, 2 ) )
    xml_node( "rabat", STR( -field->rabat, 12, 2 ) )
    xml_node( "fcjr", STR( -field->rabat/100 * field->fcj, 12, 2 ) )
    xml_node( "nc", STR( field->nc, 12, 2 ) )
    xml_node( "marzap", STR( nMarza / field->nc * 100, 12, 2 ) )
    xml_node( "marza", STR( nMarza, 12, 2 ) )
    xml_node( "pc", STR( field->vpc, 12, 2 ) )
    xml_node( "por_st", STR( _porezna_stopa, 12, 2 ) )
    xml_node( "porez", STR( _porez, 12, 2 ) )

    if _ima_mpcsapp
        xml_node( "pcsap", STR( field->mpcsapp, 12, 2 ) )
    else
        xml_node( "pcsap", STR( field->vpc + _porez, 12, 2 ) )
    endif

    // troskovi
    _pr_tr_prev := nPrevoz / field->fcj2 * 100
    _pr_tr_bank := nBankTr / field->fcj2 * 100
    _pr_tr_sped := nSpedTr / field->fcj2 * 100
    _pr_tr_car := nCarDaz / field->fcj2 * 100
    _pr_tr_zav := nZavTr / field->fcj2 * 100
    _pr_tr_svi := ( _pr_tr_prev + _pr_tr_bank + _pr_tr_sped + _pr_tr_car + _pr_tr_zav )
 
    // procenti troskova
    xml_node( "tr1p", STR( _pr_tr_prev, 12, 2 ) )
    xml_node( "tr2p", STR( _pr_tr_bank, 12, 2 ) )
    xml_node( "tr3p", STR( _pr_tr_sped, 12, 2 ) )
    xml_node( "tr4p", STR( _pr_tr_car, 12, 2 ) )
    xml_node( "tr5p", STR( _pr_tr_zav, 12, 2 ) )
    xml_node( "trsp", STR( _pr_tr_svi, 12, 2 ) )
    
    // iznosi troskova
    _tmp := nPrevoz + nBankTr + nSpedTr + nCarDaz + nZavTr
    xml_node( "tr1", STR( nPrevoz, 12, 2 ) )
    xml_node( "tr2", STR( nBankTr, 12, 2 ) )
    xml_node( "tr3", STR( nSpedTr, 12, 2 ) )
    xml_node( "tr4", STR( nCarDaz, 12, 2 ) )
    xml_node( "tr5", STR( nZavTr, 12, 2 ) )
    xml_node( "trs", STR( _tmp, 12, 2 ) )

    // ukupne vrijednosti po stavkama
    xml_node( "ufv", STR( _u_fv, 12, 2 ) )
    xml_node( "ufvr", STR( _u_fv_r, 12, 2 ) )
    // ukupni troskovi    
    xml_node( "utr1", STR( _u_tr_prevoz, 12, 2 ) )
    xml_node( "utr2", STR( _u_tr_bank, 12, 2 ) )
    xml_node( "utr3", STR( _u_tr_sped, 12, 2 ) )
    xml_node( "utr4", STR( _u_tr_carina, 12, 2 ) )
    xml_node( "utr5", STR( _u_tr_zavisni, 12, 2 ) )
    xml_node( "utrs", STR( _u_tr_svi, 12, 2 ) )
    // ukupne ostale cijene ...
    xml_node( "unv", STR( _u_nv, 12, 2 ) )
    xml_node( "umarza", STR( _u_marza, 12, 2 ) )
    xml_node( "upv", STR( _u_pv, 12, 2 ) )
    xml_node( "upor", STR( _u_porez, 12, 2 ) )
    xml_node( "upvp", STR( _u_pv_porez, 12, 2 ) )

    xml_subnode("stavka", .t. )

    skip

enddo

// ukupne vrijednosti za dokument
xml_node( "tkol", STR( _t_kol, 12, 2 ) )
xml_node( "tfv", STR( _t_fv, 12, 2 ) )
xml_node( "trab", STR( _t_rabat, 12, 2 ) )
xml_node( "tfvr", STR( _t_fv_r, 12, 2 ) )
xml_node( "ttr1", STR( _t_tr_prevoz, 12, 2 ) )
xml_node( "ttr2", STR( _t_tr_bank, 12, 2 ) )
xml_node( "ttr3", STR( _t_tr_sped, 12, 2 ) )
xml_node( "ttr4", STR( _t_tr_carina, 12, 2 ) )
xml_node( "ttr5", STR( _t_tr_zavisni, 12, 2 ) )
xml_node( "ttrs", STR( _t_tr_svi, 12, 2 ) )
xml_node( "tnv", STR( _t_nv, 12, 2 ) )
xml_node( "tmarza", STR( _t_marza, 12, 2 ) )
xml_node( "tpv", STR( _t_pv, 12, 2 ) )
xml_node( "tpor", STR( _t_porez, 12, 2 ) )
xml_node( "tpvp", STR( _t_pv_porez, 12, 2 ) )

// zatvori subnode...
xml_subnode("kalk", .t. )

// zatvori xml fajl
close_xml()

return _generated



