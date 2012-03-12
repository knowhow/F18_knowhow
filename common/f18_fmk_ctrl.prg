/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"


// -----------------------------------------
// provjera podataka za migraciju f18
// -----------------------------------------
function f18_test_data()
local _a_sif := {}
local _a_data := {}
local _a_ctrl := {} 
local _chk_sif := .f.

if Pitanje(, "Provjera sifrarnika (D/N) ?", "N") == "D"
	_chk_sif := .t.
endif

// provjeri sifrarnik
if _chk_sif == .t.
	f18_sif_data( @_a_sif, @_a_ctrl )
endif

// provjeri fin
f18_fin_data( @_a_data, @_a_ctrl )
// provjeri kalk
f18_kalk_data( @_a_data, @_a_ctrl )
// provjeri fakt
f18_fakt_data( @_a_data, @_a_ctrl )

// prikazi rezultat testa
f18_pr_rezultat( _a_ctrl, _a_data, _a_sif )

return


// -----------------------------------------
// provjera suban, anal, sint
// -----------------------------------------
static function f18_fin_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0
local _scan 

O_SUBAN

Box(, 2, 60 )

select suban
set order to tag "4"
go top

do while !EOF()
	
	_dok := field->idfirma + "-" + field->idvn + "-" + ALLTRIM( field->brnal )
	
	@ m_x + 1, m_y + 2 SAY "dokument: " + _dok

	// kontrolni broj
	++ _n_c_stavke
	_n_c_iznos += ( field->iznosbhd )

    skip

enddo

BoxC()

if _n_c_stavke > 0
	AADD( checksum, { "fin data", _n_c_stavke, _n_c_iznos } )
endif

return

// -----------------------------------------
// provjera fakt
// -----------------------------------------
static function f18_fakt_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0

O_FAKT

Box(, 2, 60 )

select fakt
set order to tag "1"
go top

do while !EOF()
	
	_dok := field->idfirma + "-" + field->idtipdok + "-" + ALLTRIM( field->brdok )
	
	@ m_x + 1, m_y + 2 SAY "dokument: " + _dok

	// kontrolni broj
	++ _n_c_stavke
	_n_c_iznos += ( field->kolicina + field->iznos )

    skip

enddo

BoxC()

if _n_c_stavke > 0
	AADD( checksum, { "fakt data", _n_c_stavke, _n_c_iznos } )
endif

return

// -----------------------------------------
// provjera kalk
// -----------------------------------------
static function f18_kalk_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0

O_KALK

Box(, 2, 60 )

select kalk
set order to tag "1"
go top

do while !EOF()
	
	_dok := field->idfirma + "-" + field->idvd + "-" + ALLTRIM( field->brdok )
	
	@ m_x + 1, m_y + 2 SAY "dokument: " + _dok

	// kontrolni broj
	++ _n_c_stavke
	_n_c_iznos += ( field->kolicina + field->nc + field->vpc )

    skip

enddo

BoxC()

if _n_c_stavke > 0
	AADD( checksum, { "kalk data", _n_c_stavke, _n_c_iznos } )
endif

return






// ------------------------------------------
// prikazi rezultat
// ------------------------------------------
static function f18_pr_rezultat( a_ctrl, a_data, a_sif )
local i, d, s

START PRINT CRET
?
P_COND

? "Rezultati testa:", DTOC( DATE() )
? "================================"
?
? "1) Kontrolni podaci:"
? "-------------- --------------- ---------------"
? "objekat        broj zapisa     kontrolni broj"
? "-------------- --------------- ---------------"
// prvo mi ispisi kontrolne zapise
for i := 1 to LEN( a_ctrl )
	? PADR( a_ctrl[ i, 1 ], 14 )
	@ prow(), pcol() + 1 SAY STR( a_ctrl[ i, 2 ], 15, 0 )
	@ prow(), pcol() + 1 SAY STR( a_ctrl[ i, 3 ], 15, 2 )
next

?

FF
END PRINT

return


// -----------------------------------------
// provjera sifrarnika
// -----------------------------------------
function f18_sif_data( data, checksum )

O_ROBA
O_PARTN
O_KONTO
O_TRFP
O_OPS
O_VALUTE
O_KONCIJ

select roba
set order to tag "1"
go top

f18_sif_check( @data, @checksum )

select partn
set order to tag "1"
go top

f18_sif_check( @data, @checksum )

select konto
set order to tag "1"
go top

f18_sif_check( @data, @checksum )

select ops
set order to tag "1"
go top

f18_sif_check( @data, @checksum )


return


// ------------------------------------------
// provjera sifrarnika 
// ------------------------------------------
static function f18_sif_check( data, checksum )
local _chk := "x-x"
local _scan
local _stavke := 0

do while !EOF()
	
	if EMPTY( _sif_id )
		skip
		loop
	endif

	++ _stavke

	skip

enddo

if _stavke > 0
	AADD( checksum, { "sif. " + ALIAS(), _stavke, 0 } )
endif

return


 
 

