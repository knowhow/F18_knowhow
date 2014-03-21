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

#include "rnal.ch"



// -----------------------------------------------
// jedinica mjere je metrička
// -----------------------------------------------
function jmj_is_metric( jmj )
local _ok := .f.

jmj := UPPER( jmj )
jmj := STRTRAN( jmj, "'", "" )

if jmj $ "#M  #MM #M' #"
	_ok := .t.
endif

return _ok


// ----------------------------------------------------------------
// preracunavanje količine repromaterijala
// ----------------------------------------------------------------
function preracunaj_kolicinu_repromaterijala( kolicina, duzina, jmj, jmj_art )
local _kolicina

if jmj_is_metric( jmj_art ) .and. jmj == "KOM"

	// imamo potrebu da koristimo i duzinu

	// ukoliko je iz nekog razloga dužina 0
	if ROUND( duzina, 2 ) == 0
		MsgBeep( "Koristi se metrička konverzija a dužina = 0 ?!???" )
		return kolicina
	endif 
	
	do case
		case jmj_art $ "#M' #M  #"
			// varijanta primarne jedince u metrima
			_kolicina := kolicina * ( duzina / 1000 )

		case jmj_art $ "#MM #"
			// varijanta primarne jedince u mm
			_kolicina := ( kolicina * duzina )

		otherwise
			// sve ostalo bi trebala biti greška
			MsgBeep( "Problem sa pretvaranjem [mm] u [" + ALLTRIM( jmj_art ) + ")" )
			_kolicina := kolicina

	endcase

else

	// ili su iste dimenzije, ili su sasvim neke druge vrijednosti
	do case
		
		case jmj == jmj_art
			// količine su iste
			_kolicina := kolicina

		case jmj $ "#M  #M' #" .and. jmj_art $ "#MM #"
			// uneseno M a roba u MM
			_kolicina := kolicina * 1000	

		case _jmj $ "#MM #" .and. jmj_art $ "#M' #M  #"
			// uneseno MM a roba u M
			_kolicina := kolicina / 1000

		otherwise 
			// sve ostalo... greska
			MsgBeep( "Ne mogu pretvoriti [" + ALLTRIM( jmj ) + "]" + ;
						" u [" + ALLTRIM( jmj_art ) + "]" )
			_kolicina := kolicina
	endcase

endif

return _kolicina



// --------------------------------------------------------------------
// validacija ispravnosti unesenih parova jedinica mjere
// --------------------------------------------------------------------
function valid_repro_jmj( jmj, jmj_art )
local _ok := .t.
local _x := m_x
local _y := m_y

if jmj_is_metric( jmj ) .and. !jmj_is_metric( jmj_art )
	// primjer: M -> KG
	_ok := .f.
elseif ( !jmj_is_metric( jmj ) .and. jmj <> "KOM" ) .and. jmj_is_metric( jmj_art )
	// primjer: KG -> M
	_ok := .f.
elseif !jmj_is_metric( jmj ) .and. !jmj_is_metric( jmj_art ) .and. ( jmj <> jmj_art )
	// primjer: KG -> PAK ili KOM -> KG itd...
	_ok := .f.
endif

if !_ok
	MsgBeep( "Ne postoji konverzija [" + ALLTRIM( jmj )  + "] u [" + ALLTRIM( jmj_art ) + "] !" )
	m_x := _x
	m_y := _y
endif

return _ok



