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

static PIC_IZN := "999999999.99"
static _NUM := 12
static _DEC := 2
static _ZAOK := 2
static _FNUM := 15
static _FDEC := 4

// --------------------------------------------
// realizacija maloprodaje fakt
// --------------------------------------------
function fakt_real_maloprodaje()
local nOperater
local cFirma
local dD_from
local dD_to
local cDocType
local nVar
local nT_uk := 0
local nT_pdv := 0
local nT_osn := 0
local _params

// uslovi izvjestaja
if g_vars( @_params ) == 0
	return
endif

// generisi pomocnu tabelu
_cre_tbl()

// generisi promet u pomocnu tabelu
_gen_rek( _params )

// ima li podataka za prikaz ?
select r_export
if reccount2() == 0
	
	msgbeep("Nema podataka za prikaz !")
	close all
	return

endif

START PRINT CRET

?
? "REALIZACIJA PRODAJE na dan: " + DTOC( DATE() )
? "-----------------------------------------------"
? "Period od:" + DTOC( _params["datum_od"] ) + " do:" + DTOC( _params["datum_do"] )
?

P_COND

// uzmi totale
_st_mp_dok( @nT_osn, @nT_pdv, @nT_uk, .t. )

// stampaj po operateru
_st_mp_oper()

// stampaj po vrsti placanja
_st_mp_vrstap()

// rasclaniti...
if _params["tip_partnera"] == "D"
    // stampaj po tipu partnera
    ?
    _st_mp_tip_partnera()
endif

?

if _params["varijanta"] = 1
	// odstampaj po robi
	_st_mp_roba()
elseif _params["varijanta"] = 2
	// odstampaj po dokumentima
	_st_mp_dok()
endif

?

// rekapitulacija
P_10CPI

? "REKAPITULACIJA:"
? "---------------------------"
? "1) ukupno bez pdv-a:"
@ prow(), pcol()+1 SAY STR( nT_osn, _NUM, _DEC ) PICT PIC_IZN
? "2) vrijednost pdv-a:"
@ prow(), pcol()+1 SAY STR( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
? "3)    ukupno sa pdv:"
@ prow(), pcol()+1 SAY STR( nT_uk, _NUM, _DEC ) PICT PIC_IZN

FF
END PRINT

return


// --------------------------------------------
// uslovi izvjestaja
// --------------------------------------------
static function g_vars( params )
local _ret := 1
local _x := 1
local _tip_partnera, _id_firma, _d_from, _d_to, _dok_tip, _operater, _varijanta
local _partner, _vrsta_p

_id_firma := PADR( fetch_metric( "fakt_real_mp_firma", my_user(), "" ), 100 )
_d_from := fetch_metric( "fakt_real_mp_datum_od", my_user(), DATE() )
_d_to := fetch_metric( "fakt_real_mp_datum_do", my_user(), DATE() )
_dok_tip := PADR( fetch_metric( "fakt_real_mp_tip_dok", my_user(), "11;" ), 100 )
_operater := fetch_metric( "fakt_real_mp_operater", my_user(), 0 )
_vrsta_p := fetch_metric( "fakt_real_mp_vrsta_p", my_user(), SPACE(2) )
_varijanta := fetch_metric( "fakt_real_mp_varijanta", my_user(), 1 )
_tip_partnera := fetch_metric( "fakt_real_mp_tip_partnera", my_user(), "D" )
_partner := PADR( fetch_metric( "fakt_real_mp_partner", my_user(), "" ), 200 )

Box( , 14, 66)

	@ m_x + _x, m_y + 2 SAY "**** REALIZACIJA PRODAJE ****"

	++ _x
	++ _x
	
	@ m_x + _x, m_y + 2 SAY "Firma (prazno-sve):" GET _id_firma PICT "@S20"
	
	++ _x

	@ m_x + _x, m_y + 2 SAY "Obuhvatiti period od:" GET _d_from
	@ m_x + _x, col() + 1 SAY "do:" GET _d_to

	++ _x

	@ m_x + _x, m_y + 2 SAY "Vrste dokumenata:" GET _dok_tip PICT "@S30"

	++ _x

	@ m_x + _x, m_y + 2 SAY "Partner (prazno-svi):" GET _partner PICT "@S40"

	++ _x

	@ m_x + _x, m_y + 2 SAY "Vrsta placanja (prazno-svi):" GET _vrsta_p VALID EMPTY( _vrsta_p ) .or. P_VRSTEP( @_vrsta_p ) 

	++ _x

	@ m_x + _x, m_y + 2 SAY "Operater (0-svi):" GET _operater ;
		PICT "9999999999" ;
        VALID {|| _operater == 0 , IIF( _operater == -99, choose_f18_user_from_list( @_operater ), .t. ) }

	++ _x
	++ _x

	@ m_x + _x, m_y + 2 SAY "Razvrstati po tipu partnera (D/N)?" GET _tip_partnera ;
                    VALID _tip_partnera $ "DN" PICT "@!" 
	
	++ _x
    ++ _x

	@ m_x + _x, m_y + 2 SAY "Varijanta prikaza 1-po robi 2-po dokumentima" 
	
	++ _x

	@ m_x + _x, m_y + 2 SAY "                  3-samo total" GET _varijanta PICT "9"

	read
BoxC()

if LastKey() == K_ESC
    return _ret
endif

set_metric( "fakt_real_mp_firma", my_user(), ALLTRIM( _id_firma ) )
set_metric( "fakt_real_mp_datum_od", my_user(), _d_from )
set_metric( "fakt_real_mp_datum_do", my_user(), _d_to )
set_metric( "fakt_real_mp_tip_dok", my_user(), ALLTRIM( _dok_tip ) )
set_metric( "fakt_real_mp_operater", my_user(), _operater )
set_metric( "fakt_real_mp_vrsta_p", my_user(), _vrsta_p )
set_metric( "fakt_real_mp_varijanta", my_user(), _varijanta )
set_metric( "fakt_real_mp_tip_partnera", my_user(), _tip_partnera )
set_metric( "fakt_real_mp_partner", my_user(), ALLTRIM( _partner ) )

// snimi parametre i matricu
params := hb_hash()
params["datum_od"] := _d_from
params["datum_do"] := _d_to
params["varijanta"] := _varijanta
params["tip_dok"] := ALLTRIM( _dok_tip )
params["operater"] := _operater
params["firma"] := ALLTRIM( _id_firma )
params["tip_partnera"] := _tip_partnera
params["partner"] := _partner
params["vrstap"] := _vrsta_p

_ret := 1

return _ret


// --------------------------------------------------
// generisi u pomocnu tabelu podatke iz FAKT-a
// --------------------------------------------------
static function _gen_rek( params )
local _filter
local cF_firma 
local cF_tipdok
local cF_brdok
local nUkupno
local _tip_partnera := "1"
local _id_broj := ""
local _pdv_clan := ""
local _d_do, _d_od, _varijanta, _tip_dok, _operater, _id_firma, _rasclaniti
local _vrsta_p

O_FAKT_DOKS
O_FAKT
O_ROBA
O_SIFV
O_SIFK
O_VRSTEP
O_TARIFA
O_PARTN

// parametri
_d_od := params["datum_od"]
_d_do := params["datum_do"]
_varijanta := params["varijanta"]
_tip_dok := params["tip_dok"]
_operater := params["operater"]
_id_firma := params["firma"]
_rasclaniti := params["tip_partnera"] == "D"
_partner := params["partner"]
_vrsta_p := params["vrstap"]

_filter := ""

if !EMPTY( _id_firma )
	_filter += Parsiraj( ALLTRIM( _id_firma ), "idfirma" )
endif

// vrsta placanja...
if !EMPTY( _vrsta_p )
    if !EMPTY( _filter )
        _filter += ".and."
    endif
    _filter += "idvrstep = " + _filter_quote( _vrsta_p )
endif

// operater
if _operater <> 0
	if !EMPTY( _filter )
		_filter += ".and."
	endif
	_filter += "oper_id = " + _filter_quote( _operater )
endif

// tipovi dokumenata
if !EMPTY( _tip_dok )
	if !EMPTY( _filter )
		_filter += ".and."
	endif
	_filter += Parsiraj( ALLTRIM( _tip_dok ), "idtipdok" )
endif

// partner
if !EMPTY( _partner )
	if !EMPTY( _filter )
		_filter += ".and."
	endif
	_filter += Parsiraj( ALLTRIM( _partner ), "idpartner" )
endif

// datumi od-do
if !EMPTY( DTOS(_d_od) )
	if !EMPTY( _filter )
		_filter += ".and."
	endif
	_filter += "datdok >=" + _filter_quote( _d_od )
endif

if !EMPTY( DTOS(_d_do) )
	if !EMPTY( _filter )
		_filter += ".and."
	endif
	_filter += "datdok <=" + _filter_quote( _d_do )
endif

msgo("generisem podatke ...")

select fakt_doks
set filter to &_filter
go top

do while !EOF()

	cF_firma := field->idfirma
	cF_tipdok := field->idtipdok
	cF_brdok := field->brdok
	nUkupno := field->iznos

	_oper_id := field->oper_id

	select fakt
	go top
	seek cF_firma + cF_tipdok + cF_brdok

	do while !EOF() .and. field->idfirma == cF_firma ;
		.and. field->idtipdok == cF_tipdok ;
		.and. field->brdok == cF_brdok
		
		cRoba_id := field->idroba
		cPart_id := field->idpartner
	
        // fizicka lica
        _tip_partnera := "1"
        
        if _rasclaniti

            // odredi tip partnera
            _id_broj := IzSifK( "PARTN", "REGB", cPart_id )
            _pdv_clan := IzSifK( "PARTN", "REG0", cPart_id )

            if !EMPTY( _id_broj ) 
                // pravna lica
                _tip_partnera := "2"
            endif

        endif

		select roba
		seek cRoba_id

		select tarifa
		seek roba->idtarifa

		select partn
		seek cPart_id

		select fakt

		nCjPDV := 0
		nCj2PDV := 0
		nCjBPDV := 0
		nCj2BPDV := 0
		nVPopust := 0
	
		// procenat pdv-a
		nPPDV := tarifa->opp

		// kolicina
		nKol := field->kolicina
		nRCijen := field->cijena

	
		if LEFT(field->dindem, 3) <> LEFT(ValBazna(), 3) 
			// preracunaj u EUR
			// omjer EUR / KM
      			nRCijen := nRCijen / OmjerVal( ValBazna(), ;
				field->dindem, field->datdok )
			nRCijen := ROUND( nRCijen, DEC_CIJENA() )
   		endif

	    	// rabat - popust
	    	nPopust := field->rabat
	
		// ako je 13-ka ili 27-ca
		// cijena bez pdv se utvrdjuje unazad 
		if ( field->idtipdok == "13" .and. glCij13Mpc ) .or. ;
			(field->idtipdok $ "11#27" .and. gMP $ "1234567") 
			// cjena bez pdv-a
			nCjPDV := nRCijen	
			nCjBPDV := (nRCijen / (1 + nPPDV/100))
		else
			// cjena bez pdv-a
			nCjBPDV := nRCijen
			nCjPDV := (nRCijen * (1 + nPPDV/100))
		endif
	
		// izracunaj vrijednost popusta
		if Round(nPopust,4) <> 0
			// vrijednost popusta
			nVPopust := (nCjBPDV * (nPopust/100))
		endif
	
		// cijena sa popustom bez pdv-a
		nCj2BPDV := (nCjBPDV - nVPopust)
		
		// izracuna PDV na cijenu sa popustom
		nCj2PDV := (nCj2BPDV * (1 + nPPDV/100))
		
		// preracunaj VPDV sa popustom
		nVPDV := (nCj2BPDV * (nPPDV/100))

		select r_export
		append blank

        replace field->tip with _tip_partnera
		replace field->idfirma with fakt->idfirma
		replace field->idtipdok with fakt->idtipdok
		replace field->brdok with fakt->brdok
		replace field->datdok with fakt->datdok
		replace field->operater with _oper_id
        replace field->vrstap with _g_vrsta_p( fakt->idtipdok, fakt->idvrstep )
		replace field->part_id with fakt->idpartner
		replace field->part_naz with ALLTRIM( partn->naz )
		replace field->roba_id with fakt->idroba
		replace field->roba_naz with ALLTRIM( roba->naz )
		replace field->kolicina with nKol
		replace field->s_pdv with nPPDV
		replace field->popust with nVPopust
		replace field->c_bpdv with nCj2BPdv
		replace field->pdv with nVPDV
		replace field->c_pdv with nCj2PDV
		replace field->uk_fakt with nUkupno

		select fakt
		skip

	enddo

	select fakt_doks
	skip

enddo

msgc()

return


static function _g_vrsta_p( tip_dok, vrsta_p )
local _ret := "MP GOTOVINA"

do case 

    // maloprodaja
    case tip_dok == "11"

        if !EMPTY( vrsta_p )
            if vrsta_p == "KT"
                _ret := "MP KARTICA"
            elseif vrsta_p == "AV"
                _ret := "MP AVANSNA FAKTURA"
            elseif vrsta_p == "VR"
                _ret := "MP VIRMANSKO PLACANJE"
            endif
        endif        

    // vp
    case tip_dok == "10"
        _ret := "VP VIRMANSKO PLACANJE"
        if !EMPTY( vrsta_p )
            if vrsta_p == "G "
                _ret := "VP GOTOVINA"
            elseif vrsta_p == "KT"
                _ret := "VP KARTICA"
            elseif vrsta_p == "AV"
                _ret := "VP AVANSNA FAKTURA"
            endif
        endif

endcase

return _ret


// -------------------------------------------
// kreiranje pomocne tabele izvjestaja
// -------------------------------------------
static function _cre_tbl()
local aDbf := {}

AADD( aDbf, { "tip", "C", 1, 0 } )
AADD( aDbf, { "idfirma", "C", 2, 0 } )
AADD( aDbf, { "idtipdok", "C", 2, 0 } )
AADD( aDbf, { "brdok", "C", 10, 0 } )
AADD( aDbf, { "datdok", "D", 8, 0 } )
AADD( aDbf, { "operater", "N", 10, 0 } )
AADD( aDbf, { "vrstap", "C", 40, 0 } )
AADD( aDbf, { "part_id", "C", 6, 0 } )
AADD( aDbf, { "part_naz", "C", 100, 0 } )
AADD( aDbf, { "roba_id", "C", 10, 0 } )
AADD( aDbf, { "roba_naz", "C", 100, 0 } )
AADD( aDbf, { "kolicina", "N", 15, 5 } )
AADD( aDbf, { "popust", "N", 15, 5 } )
AADD( aDbf, { "s_pdv", "N", 12, 2 } )
AADD( aDbf, { "c_bpdv", "N", _FNUM, _FDEC } )
AADD( aDbf, { "pdv", "N", _FNUM, _FDEC } )
AADD( aDbf, { "c_pdv", "N", _FNUM, _FDEC } )
AADD( aDbf, { "uk_fakt", "N", _FNUM, _FDEC } )

t_exp_create( aDbf )
O_R_EXP

index on idfirma + idtipdok + brdok tag "1"
index on roba_id tag "2"
index on STR( operater, 10 ) + idfirma + idtipdok + brdok tag "3"
index on tip tag "4"
index on vrstap tag "5"

return



// ---------------------------------------------
// stampa rekapitulacije
// varijanta po dokumentima
// ---------------------------------------------
static function _st_mp_dok( nT_osnovica, nT_pdv, nT_ukupno, lCalc )
local nOsnovica
local nPDV
local nUkupno
local nRbr := 0
local nRow := 35
local cLine := ""
local nOperater
local cOper_Naz := ""

if lCalc == nil
	lCalc := .f.
endif

nT_osnovica := 0
nT_pdv := 0
nT_ukupno := 0

if lCalc == .f.
	// vraca liniju
	g_l_mpdok( @cLine )

	// zaglavlje pregled po robi
	s_z_mpdok( cLine )
endif

select r_export
// po dokumentima
set order to tag "1"
go top

do while !EOF()

	cIdFirma := field->idfirma
	cIdTipDok := field->idtipdok
	cBrDok := field->brdok
	cPart_id := field->part_id
	cPart_naz := field->part_naz
	nOperater := field->operater
	cOper_naz := GetFullUserName( nOperater )
	
	nOsnovica := 0
	nPDV := 0
	nUkupno := 0
	nS_pdv := 0
	nUk_fakt := 0

	do while !EOF() .and. field->idfirma + field->idtipdok + ;
		field->brdok == cIdFirma + cIdTipDok + cBrDok
		
		nOsnovica += field->kolicina * field->c_bpdv
		nPDV += field->kolicina * field->pdv
		nS_pdv := field->s_pdv
		nUk_fakt := field->uk_fakt

		skip
	enddo

	// zaokruzi
	nOsnovica := ROUND( ( nUk_fakt / ( 1 + ( nS_pdv/100 )) ), ;
		ZAO_VRIJEDNOST() )
	nPDV := ROUND( ( nUk_fakt / ( 1 + ( nS_pdv/100 ) ) * ;
		(nS_pdv/100)) , ZAO_VRIJEDNOST() )
	nUkupno := ROUND( nUk_fakt , ZAO_VRIJEDNOST() )

	if lCalc == .f.
		// pa ispisi tu stavku

		// rbr
		? PADL( ALLTRIM( STR( ++nRbr ) ), 4 ) + "."

		// dokument
		@ prow(), pcol()+1 SAY PADR( ALLTRIM( cIdFirma + "-" + ;
			cIdTipDok + "-" + cBrDok ), 16 )

		// partner
		@ prow(), pcol()+1 SAY PADR( ALLTRIM( cPart_id ) + "-" + ;
			ALLTRIM( cPart_naz ), 40 )
	
		// osnovica
		@ prow(), nRow := pcol()+1 SAY STR( nOsnovica, _NUM, _DEC ) ;
			PICT PIC_IZN

		// pdv
		@ prow(), pcol()+1 SAY STR( nPDV, _NUM, _DEC ) PICT PIC_IZN

		// ukupno
		@ prow(), pcol()+1 SAY STR( nUkupno, _NUM, _DEC ) PICT PIC_IZN
		
		// operater
		@ prow(), pcol()+1 SAY PADR( ALLTRIM( cOper_naz ), 20 )

	endif

	// dodaj na total

	nT_ukupno += nUkupno
	nT_osnovica += nOsnovica
	nT_pdv += nPDV

enddo

if lCalc == .f.
	
	// ispisi sada total
	? cLine

	? "UKUPNO:"
	@ prow(), nRow SAY STR( nT_osnovica, _NUM, _DEC ) PICT PIC_IZN
	@ prow(), pcol()+1 SAY STR( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
	@ prow(), pcol()+1 SAY STR( nT_ukupno, _NUM, _DEC ) PICT PIC_IZN

	? cLine
endif

return


// ---------------------------------------------
// stampa rekapitulacije
// varijanta po tipu partnera
// ---------------------------------------------
static function _st_mp_tip_partnera( nT_osnovica, nT_pdv, nT_ukupno )
local nOsnovica
local nPDV
local nUkupno
local nRbr := 0
local nRow := 35
local cLine := ""
local cF_tipdok
local cF_firma
local cF_brdok
local _tip_partnera, _opis
local __osn, __pdv, __total

// 1 - nepdv
// 2 - pdv
// 3 - ino

nT_osnovica := 0
nT_pdv := 0
nT_ukupno := 0

g_l_mptip( @cLine )

s_z_mptip( cLine )

select r_export
// po operaterima
set order to tag "4"
go top

do while !EOF()

    _tip_partnera := field->tip

    // iznosi...
    __osn := 0
    __pdv := 0
    __total := 0

    do while !EOF() .and. field->tip == _tip_partnera

        _tip_partnera := field->tip
        
        _id_firma := field->idfirma
        _tip_dok := field->idtipdok
        _br_dok := field->brdok

	    nOsnovica := 0
	    nPDV := 0
	    nUkupno := 0
    	nS_pdv := 0
	    nUk_fakt := 0

	    do while !EOF() .and. _tip_partnera == field->tip .and. field->idfirma + field->idtipdok + ;
		    field->brdok == _id_firma + _tip_dok + _br_dok
		
		    nS_pdv := field->s_pdv
		    nUk_fakt := field->uk_fakt

		    skip

	    enddo

	    // zaokruzi
	    nOsnovica := ROUND( ( nUk_fakt / ( 1 + ( nS_pdv/100 )) ), ;
		        ZAO_VRIJEDNOST() )
    	nPDV := ROUND( ( nUk_fakt / ( 1 + ( nS_pdv/100 ) ) * ;
		        (nS_pdv/100)) , ZAO_VRIJEDNOST() )
	    nUkupno := ROUND( nUk_fakt , ZAO_VRIJEDNOST() )

        __osn += nOsnovica
        __pdv += nPDV
        __total += nUkupno

    enddo

	// pa ispisi tu stavku

	// rbr
	? PADL( ALLTRIM( STR( ++nRbr ) ), 4 ) + "."

    _opis := "Fizicka lica"

    if _tip_partnera == "2"
        _opis := "Pravna lica"
    endif

	// tip partnera
	@ prow(), pcol()+1 SAY PADR( _opis, 40 )
	
	// total
	@ prow(), nRow := pcol()+1 SAY STR( __osn, _NUM, _DEC ) ;
		PICT PIC_IZN 

	// pdv
	@ prow(), pcol()+1 SAY STR( __pdv, _NUM, _DEC ) PICT PIC_IZN

	// osnovica
	@ prow(), pcol()+1 SAY STR( __total, _NUM, _DEC ) PICT PIC_IZN 

	// dodaj na total

	nT_ukupno += __total
	nT_osnovica += __osn
	nT_pdv += __pdv

enddo

// ispisi sada total
? cLine

? "UKUPNO:"

@ prow(), nRow SAY STR( nT_osnovica, _NUM, _DEC ) PICT PIC_IZN
@ prow(), pcol()+1 SAY STR( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
@ prow(), pcol()+1 SAY STR( nT_ukupno, _NUM, _DEC ) PICT PIC_IZN

? cLine

return



// ---------------------------------------------
// stampa rekapitulacije
// varijanta po vrsti placanja
// ---------------------------------------------
static function _st_mp_vrstap( nT_osnovica, nT_pdv, nT_ukupno )
local nOsnovica
local nPDV
local nUkupno
local nRbr := 0
local nRow := 35
local cLine := ""
local cF_tipdok
local cF_firma
local cF_brdok
local _vrsta_p, _vrsta_p_naz

nT_osnovica := 0
nT_pdv := 0
nT_ukupno := 0

// vraca liniju
g_l_mpop( @cLine )

// zaglavlje pregled po robi
s_z_mpvrstap( cLine )

select r_export
// po operaterima
set order to tag "5"
go top

do while !EOF()

	_vrsta_p := field->vrstap

	nOsnovica := 0
	nPDV := 0
	nUkupno := 0
	nS_pdv := 0
	nU_fakt := 0
	nUU_fakt := 0

	do while !EOF() .and. field->vrstap == _vrsta_p
	
		cF_brdok := field->brdok
		cF_tipdok := field->idtipdok
		cF_firma := field->idfirma

		do while !EOF() .and. field->vrstap == _vrsta_p .and. ;
			cF_firma + cF_tipdok + cF_brdok == field->idfirma + ;
				field->idtipdok + field->brdok
		
			nU_fakt := field->uk_fakt
			nS_pdv := field->s_pdv
			nOsnovica += field->kolicina * field->c_bpdv
			nPDV += field->kolicina * field->pdv

			skip
		enddo

		nUU_fakt += nU_fakt

	enddo

	// zaokruzi
	nOsnovica := ROUND( ( nUU_fakt / ( 1 + ( nS_pdv/100 )) ), ;
		ZAO_VRIJEDNOST() )
	nPDV := ROUND( ( nUU_fakt / ( 1 + ( nS_pdv/100 ) ) * ;
		(nS_pdv/100)) , ZAO_VRIJEDNOST() )
	nUkupno := ROUND( nUU_fakt , ZAO_VRIJEDNOST() )


	// pa ispisi tu stavku

	// rbr
	? PADL( ALLTRIM( STR( ++nRbr ) ), 4 ) + "."

	// operater
	@ prow(), pcol()+1 SAY PADR( ALLTRIM( _vrsta_p ), 40 )
	
	// total
	@ prow(), nRow := pcol()+1 SAY STR( nUkupno, _NUM, _DEC ) ;
		PICT PIC_IZN 

	// dodaj na total

	nT_ukupno += nUkupno
	nT_osnovica += nOsnovica
	nT_pdv += nPDV

enddo

// ispisi sada total
? cLine

? "UKUPNO:"
@ prow(), nRow SAY STR( nT_Ukupno, _NUM, _DEC ) PICT PIC_IZN

? cLine

return




// ---------------------------------------------
// stampa rekapitulacije
// varijanta po operaterima
// ---------------------------------------------
static function _st_mp_oper( nT_osnovica, nT_pdv, nT_ukupno )
local nOperater
local cOper_naz
local nOsnovica
local nPDV
local nUkupno
local nRbr := 0
local nRow := 35
local cLine := ""
local cF_tipdok
local cF_firma
local cF_brdok

nT_osnovica := 0
nT_pdv := 0
nT_ukupno := 0

// vraca liniju
g_l_mpop( @cLine )

// zaglavlje pregled po robi
s_z_mpop( cLine )

select r_export
// po operaterima
set order to tag "3"
go top

do while !EOF()

	nOperater := field->operater
	cOper_naz := ""

	// ako postoji operater
	if nOperater <> 0

		nTArea := SELECT()

		cOper_naz := GetFullUserName( nOperater )
		cOper_naz := "(" + ALLTRIM( STR( nOperater ) ) + ") " + ;
			cOper_naz

		select (nTArea)
	endif

	nOsnovica := 0
	nPDV := 0
	nUkupno := 0
	nS_pdv := 0
	nU_fakt := 0
	nUU_fakt := 0

	do while !EOF() .and. field->operater == nOperater 
	
		cF_brdok := field->brdok
		cF_tipdok := field->idtipdok
		cF_firma := field->idfirma

		do while !EOF() .and. field->operater == nOperater .and. ;
			cF_firma + cF_tipdok + cF_brdok == field->idfirma + ;
				field->idtipdok + field->brdok
		
			nU_fakt := field->uk_fakt
			nS_pdv := field->s_pdv
			nOsnovica += field->kolicina * field->c_bpdv
			nPDV += field->kolicina * field->pdv

			skip
		enddo

		nUU_fakt += nU_fakt

	enddo

	// zaokruzi
	nOsnovica := ROUND( ( nUU_fakt / ( 1 + ( nS_pdv/100 )) ), ;
		ZAO_VRIJEDNOST() )
	nPDV := ROUND( ( nUU_fakt / ( 1 + ( nS_pdv/100 ) ) * ;
		(nS_pdv/100)) , ZAO_VRIJEDNOST() )
	nUkupno := ROUND( nUU_fakt , ZAO_VRIJEDNOST() )


	// pa ispisi tu stavku

	// rbr
	? PADL( ALLTRIM( STR( ++nRbr ) ), 4 ) + "."

	// operater
	@ prow(), pcol()+1 SAY PADR( ALLTRIM( cOper_naz ), 40 )
	
	// total
	@ prow(), nRow := pcol()+1 SAY STR( nUkupno, _NUM, _DEC ) ;
		PICT PIC_IZN 

	// pdv
	//@ prow(), pcol()+1 SAY STR( nPDV, _NUM, _DEC ) PICT PIC_IZN

	// osnovica
	//@ prow(), pcol()+1 SAY STR( nOsnovica, _NUM, _DEC ) PICT PIC_IZN 

	// dodaj na total

	nT_ukupno += nUkupno
	nT_osnovica += nOsnovica
	nT_pdv += nPDV

enddo

// ispisi sada total
? cLine

? "UKUPNO:"
@ prow(), nRow SAY STR( nT_Ukupno, _NUM, _DEC ) PICT PIC_IZN
//@ prow(), pcol()+1 SAY STR( nT_pdv, _NUM, _DEC ) PICT PIC_IZN
//@ prow(), pcol()+1 SAY STR( nT_ukupno, _NUM, _DEC ) PICT PIC_IZN

? cLine

return


// ---------------------------------------------
// stampa rekapitulacije
// varijanta po robama
// ---------------------------------------------
static function _st_mp_roba()
local cRoba_id 
local nOsnovica
local nPDV
local nUkupno
local nKolicina
local nT_kolicina := 0
local nRbr := 0
local nRow := 35
local cLine := ""
local nT_osnovica := 0
local nT_pdv := 0
local nT_ukupno := 0

// vraca liniju
g_l_mproba( @cLine )

// zaglavlje pregled po robi
s_z_mproba( cLine )

select r_export
set order to tag "2"
go top

do while !EOF()

	cRoba_id := field->roba_id
	cRoba_naz := field->roba_naz

	nOsnovica := 0
	nPDV := 0
	nS_pdv := 0
	nUkupno := 0
	nKolicina := 0

	do while !EOF() .and. field->roba_id == cRoba_id
		
		nS_pdv := field->s_pdv
		nOsnovica += field->kolicina * field->c_bpdv
		nPDV += field->kolicina * field->pdv
		nKolicina += field->kolicina

		skip
	enddo

	// zaokruzi
	nOsnovica := ROUND(nOsnovica, ZAO_VRIJEDNOST() )
	nPDV := ROUND( (nOsnovica * (nS_pdv/100)) , ZAO_VRIJEDNOST() + _ZAOK )
	nUkupno := ROUND( nOsnovica + nPDV , ZAO_VRIJEDNOST() )


	// pa ispisi tu stavku

	? PADL( ALLTRIM( STR( ++nRbr ) ), 4 ) + "."

	@ prow(), pcol()+1 SAY PADR( ALLTRIM( cRoba_id ) + ;
		"-" + ALLTRIM( cRoba_naz ), 50 )
	
	@ prow(), nRow := pcol()+1 SAY STR( nKolicina, 12, 2 )

	
	// dodaj na total

	nT_kolicina += nKolicina

enddo

// ispisi sada total
? cLine

? "UKUPNO:"
@ prow(), nRow SAY STR( nT_kolicina, 12, 2 )

? cLine

return


// -----------------------------------------
// vraca liniju za pregled po robi
// -----------------------------------------
static function g_l_mproba( cLine )

cLine := ""

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)

return


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
static function s_z_mproba( cLine )

cTxt := ""

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("roba (id/naziv)", 50)
cTxt += SPACE(1)
cTxt += PADR("kolicina", 12)
//cTxt += SPACE(1)
//cTxt += PADR("osnovica", 12)
//cTxt += SPACE(1)
//cTxt += PADR("pdv", 12)
//cTxt += SPACE(1)
//cTxt += PADR("ukupno", 12)

? "Realizacija po robi:"
? cLine
? cTxt
? cLine

return

// -----------------------------------------
// vraca liniju za pregled po robi
// -----------------------------------------
static function g_l_mptip( cLine )

cLine := ""

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 40)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)

return




// -----------------------------------------
// vraca liniju za pregled po robi
// -----------------------------------------
static function g_l_mpop( cLine )

cLine := ""

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 40)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)
//cLine += SPACE(1)
//cLine += REPLICATE("-", 12)

return


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
static function s_z_mptip( cLine )

cTxt := ""

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("Tip partnera", 40)
cTxt += SPACE(1)
cTxt += PADR("osnovica", 12)
cTxt += SPACE(1)
cTxt += PADR("pdv", 12)
cTxt += SPACE(1)
cTxt += PADR("ukupno", 12)

? "Realizacija po tipu partnera:"
? cLine
? cTxt
? cLine

return



// -----------------------------------------
// zaglavlje za pregled po vrsti placanja
// -----------------------------------------
static function s_z_mpvrstap( cLine )

cTxt := ""

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("vrsta placanja (id/naziv)", 40)
cTxt += SPACE(1)
cTxt += PADR("ukupno", 12)

?
? "Realizacija po vrstama placanja:"
? cLine
? cTxt
? cLine

return




// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
static function s_z_mpop( cLine )

cTxt := ""

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("operater (id/naziv)", 40)
cTxt += SPACE(1)
cTxt += PADR("ukupno", 12)
//cTxt += SPACE(1)
//cTxt += PADR("pdv", 12)
//cTxt += SPACE(1)
//cTxt += PADR("ukupno", 12)

? "Realizacija po opearterima:"
? cLine
? cTxt
? cLine

return


// -----------------------------------------
// vraca liniju za pregled po dokumentima
// -----------------------------------------
static function g_l_mpdok( cLine )

cLine := ""

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 16)
cLine += SPACE(1)
cLine += REPLICATE("-", 40)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 20)

return


// -----------------------------------------
// zaglavlje za pregled po robama
// -----------------------------------------
static function s_z_mpdok( cLine )

cTxt := ""

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("dokument", 16)
cTxt += SPACE(1)
cTxt += PADR("partner (id/naziv)", 40)
cTxt += SPACE(1)
cTxt += PADR("osnovica", 12)
cTxt += SPACE(1)
cTxt += PADR("pdv", 12)
cTxt += SPACE(1)
cTxt += PADR("ukupno", 12)
cTxt += SPACE(1)
cTxt += PADR("operater", 20)

? "Realizacija po dokumentima:"
? cLine
? cTxt
? cLine

return



