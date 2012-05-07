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


#include "ld.ch"


// ------------------------------------------
// da li radnik ide u benef osnovu
// ------------------------------------------
function UBenefOsnovu()
if radn->k4 == "BF"
    return .t.
endif
return .f.




// ----------------------------------------
// vraca benef stepen za radnika
// ----------------------------------------
function BenefStepen()
local nRet := 0
local nTArea := SELECT()
local cTmp

select radn

cTmp := ALLTRIM( radn->k3 )

if EMPTY( cTmp )
    select (nTArea)
    return 0
endif

O_KBENEF
select kbenef
go top
seek cTmp

if FOUND()
    nRet := field->iznos
endif

select (nTArea)

return nRet



function PrikKBOBenef()

if nUBNOsnova == 0
    return
endif

nBO:=0
? Lokal("Koef. Bruto osnove benef.(KBO):"),transform(parobr->k3,"999.99999%")
? space(3),Lokal("BRUTO OSNOVA = NETO OSNOVA.BENEF * KBO =")
@ prow(),pcol()+1 SAY nBo:=round2(parobr->k3/100*nUBNOsnova,gZaok2) pict gpici
?
return




