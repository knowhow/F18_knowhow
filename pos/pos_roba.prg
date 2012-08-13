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

static __tezinski_barkod := NIL

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
function param_tezinski_barkod(read_par)

if read_par != NIL
   __tezinski_barkod := fetch_metric( "barkod_tezinski_barkod", nil, "N" )
endif   

return __tezinski_barkod


// -------------------------------------- 
// POS postoji artikal
// -------------------------------------- 
function pos_postoji_roba( cId, dx, dy, barkod )
local _zabrane
local _i
local _barkod := ""
local _vrati := .f.
local _tezina := 0
private ImeKol := {}
private Kol := {}

sif_uv_naziv( @cId )

UnSetSpecNar()
 
SETKEY( K_PGDN, bPrevDn )
SETKEY( K_PGUP, bPrevUp )

if VALTYPE(GetList) == "A" .and. LEN(GetList)>1
  PrevId := GetList[1]:original
endif
	
AADD( ImeKol, { "Sifra", {|| id }, "" })
AADD( ImeKol, { PADC( "Naziv", 40 ), {|| PADR( naz, 40 ) }, "" })
AADD( ImeKol, { PADC( "JMJ", 5 ), {|| PADC( jmj, 5 ) }, "" })
AADD( ImeKol, { "Cijena", {|| roba->mpc }, "" })
AADD( ImeKol, { "BARKOD", {|| barkod }, "" })
AADD( ImeKol, { "K7", {|| k7 }, "" })

for _i := 1 to LEN( ImeKol )
	AADD( Kol, _i ) 
next

if KLEVEL == L_PRODAVAC
	_zabrane := { K_CTRL_T, K_CTRL_N, K_F4, K_F2, K_CTRL_F9 }
else
  	_zabrane := {}
endif

// trazi prvo tezinski pa onda regularni barkod
if !tezinski_barkod( @cId, @_tezina )
	_barkod := barkod( @cId )
else
    // da se zna da je ocitan tezinski barkod
    _barkod := PADR("T", 13)
endif

// otvori sifrarnik
_vrati := PostojiSifra( F_ROBA, "ID", MAXROWS() - 20, MAXCOLS() - 3, "Roba ( artikli ) ", @cId, NIL, NIL, NIL, NIL, NIL, _zabrane )

if LASTKEY() == K_ESC
	cId := PrevID
  	_vrati := .f.
else
	@ m_x + dx, m_y + dy SAY PADR (AllTrim (roba->Naz)+" ("+AllTrim (roba->Jmj)+")",50)
  
	if _tezina <> 0
		_kolicina := _tezina
	endif

	if roba->tip <> "T"
    	_cijena := roba->mpc
  	endif

endif

//kontrolisi cijenu pri unosu narudzbe
if fetch_metric( "pos_kontrola_cijene_pri_unosu_stavke", nil, "N" ) == "D"
 	if ROUND(_cijena, 5) == 0
    	MsgBeep( "Cijena 0.00, ne mogu napraviti racun !!!" )
    	_vrati := .f.
  	endif
endif

SETKEY (K_PGDN, {|| DummyProc()})
SETKEY (K_PGUP, {|| DummyProc()})

SetSpecNar()

barkod := _barkod

return _vrati

// ------------------------------------------
// pretraga sifre po nazivu uvijek
// ------------------------------------------
function sif_uv_naziv(cId)
local nIdLen
// prvo prekontrolisati uslove

// parametar
if gSifUvPoNaz == "N"
	return
endif
// ako je uneseno prazno
if Empty(cId)
	return
endif

// ako je unesena puna duzina polja
if LEN(ALLTRIM(cID)) == 10
	return
endif

// ako postoji tacka na kraju
if RIGHT(ALLTRIM(cID),1) == "."
	return
endif

// dodaj tacku
cId := PADR( ALLTRIM(cId) + "." , 10)

return

