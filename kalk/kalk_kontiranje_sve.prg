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



// -----------------------------------------
// kontiranje vise naloga od jednom
// -----------------------------------------
function kont_v_kalk()
local dD_f := DATE()-30
local dD_t := DATE()
local cId_td := PADR( "14;", 100 )
local cId_mkto := PADR( "", 100 )
local cId_pkto := PADR( "", 100 )
local cChBrNal := "N"

// uslovi...
Box( , 5, 65 )
	
	@ m_x + 1, m_y + 2 SAY "Datum od:" GET dD_f
	@ m_x + 1, col() + 1 SAY "do:" GET dD_t

	@ m_x + 2, m_y + 2 SAY "tipovi dok. (prazno-svi):" GET cId_td ;
		PICT "@S20"
	
	@ m_x + 3, m_y + 2 SAY "mag.konta (prazno-sva):" GET cId_mkto ;
		PICT "@S20"
	@ m_x + 4, m_y + 2 SAY " pr.konta (prazno-sva):" GET cId_pkto ;
		PICT "@S20"

	@ m_x + 5, m_y + 2 SAY "koriguj broj naloga (D/N)" GET cChBrNal ;
		PICT "@!" VALID cChBrNal $ "DN"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

_kont_doks( dD_f, dD_t, cId_td, cId_mkto, cId_pkto, cChBrNal )

return

// -----------------------------------------------------
// kontiraj dokumente po uslovima
// -----------------------------------------------------
static function _kont_doks( dD_f, dD_t, cId_td, cId_mkto, ;
	cId_pkto, cChBrNal )
local nCount := 0
local nTNRec
local cNalog := ""

// prvo u doks-u nadji dokumente i prema njima onda idi
O_DOKS

cId_td := ALLTRIM( cId_td )
cId_mkto := ALLTRIM( cId_mkto )
cId_pkto := ALLTRIM( cId_pkto )

select doks
go top


do while !EOF()

	if ( field->datdok < dD_f .or. field->datdok > dD_t )
		skip
		loop
	endif

	if !EMPTY( cId_td ) 
		if field->idvd $ cId_td
			// idi dalje...
		else
			skip
			loop
		endif
	endif
	
	// provjeri magacinska konta
	if !EMPTY( cId_mkto ) 
		if ALLTRIM(field->mkonto) $ cId_mkto
			// idi dalje...
		else
			skip
			loop
		endif
	endif
	
	// provjeri prodavnicka konta
	if !EMPTY( cId_pkto ) 
		if ALLTRIM(field->pkonto) $ cId_pkto
			// idi dalje...
		else
			skip
			loop
		endif
	endif

	nTNRec := RECNO()
	cD_firma := field->idfirma
	cD_tipd := field->idvd
	cD_brdok := field->brdok

	// napuni FINMAT
	RekapK( .t., cD_firma, cD_tipd, cD_brdok, .t. )
	
	// uzmi drugi broj naloga
	_br_nal( cChBrNal, cD_brdok, @cNalog )

	// kontiraj
	KontNal( .t., .t., .f., cNalog )

	// azuriraj nalog
	p_fin( .t. )

	++ nCount

	O_DOKS
	select doks
	go (nTNRec)
	skip
enddo

if nCount > 0
	msgbeep( "Kontirao " + ALLTRIM(STR(nCount)) + " dokumenata !" )
endif

return



// --------------------------------------------------------
// uskladi broj naloga sa brojem kalkulacije
// --------------------------------------------------------
static function _br_nal( cChange, cBrKalk, cNalog )

if cChange == "N"
	return
endif

if ( "/" $ cBrKalk )
	// samo ako ima ovaj znak
	cNalog := PADL( ALLTRIM( cBrKalk ), 8, "0" )
endif

return


