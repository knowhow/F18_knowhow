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


#include "f18.ch"

 
function PrintParovno(nKolUlaz, nKolIzlaz)
?
?
? REPLICATE("=",80)
? "PAROVNO:"
@ prow(),pcol()+1  SAY  "Ulaz:"
@ prow(),pcol()+1  SAY  nKolUlaz  PICT "9,999,999"
@ prow(),pcol()+1  SAY  "Izlaz:"
@ prow(),pcol()+1  SAY  nKolIzlaz PICT "9,999,999"
@ prow(),pcol()+1  SAY  "Stanje:"
@ prow(),pcol()+1  SAY  nKolUlaz-nKolIzlaz PICT "9,999,999"
? REPLICATE("=",80)

return

// -------------------------------------------
// vraca naziv prodavnice iz tabele OBJEKTI
// -------------------------------------------
function get_prod_naz(cIdKonto)
local nTArea := SELECT()
local cNaz := "???"

O_OBJEKTI
select objekti
set order to tag "idobj"
go top
seek cIdKonto

if FOUND()
	cNaz := ALLTRIM(field->naz)
endif

select (nTArea)
return cNaz


