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


#include "fmk.ch"

function browse_tdok(cId, dx, dy)

local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_TDOK

AADD(ImeKol, { "ID",    {|| field->id }, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { "Naziv", {|| PADR( ToStrU( field->naz ), 35 ) }, "naz" })

for i := 1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
return p_sifra_2(F_TDOK, 1, MAX(maxrows() - 20, 10), MAX(maxcols() - 30, 35), "OsnPod: Vrste dokumenata", @cId, dx, dy)


function P_TipDok(cId, dx, dy)
return browse_tdok(cId, dx, dy)
