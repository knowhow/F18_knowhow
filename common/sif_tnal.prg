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


#include "fmk.ch"

// ------------------------------------
// ------------------------------------
function browse_tnal(CId, dx, dy)

local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()

O_TNAL_SQL

AADD(ImeKol, { "ID", {|| id}, "id", {|| .t.}, {|| sifra_postoji(wId)} })
AADD(ImeKol, { "Naziv", {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
return p_sifra_2(F_TNAL, 1, 10, 60, "Lista: Vrste naloga", @cId, dx, dy)


