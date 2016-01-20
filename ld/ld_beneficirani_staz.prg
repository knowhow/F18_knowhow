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

select F_KBENEF
if !used()
    O_KBENEF
endif

select kbenef
go top
seek cTmp

if FOUND()
    nRet := field->iznos
endif

select (nTArea)

return nRet


// --------------------------------------------------------------
// vraca iznos doprinosa, osnovice za beneficirani staž
// --------------------------------------------------------------
function get_benef_osnovica( a_benef, benef_id )
local _iznos := 0
local _scan

if a_benef == NIL .or. LEN( a_benef ) == 0
    return _iznos
endif

_scan := ASCAN( a_benef, {|var| var[1] == benef_id } )

if _scan <> 0 .and. a_benef[ _scan, 3 ] <> 0
    _iznos := a_benef[ _scan, 3 ]
endif

return _iznos



// --------------------------------------------------------------
// dodaj u matricu benef
// --------------------------------------------------------------
function add_to_a_benef( a_benef, benef_id, benef_st, osnovica )
local _scan

// a_benef[1] = benef_id
// a_benef[2] = benef_stepen
// a_benef[3] = osnova

_scan := ASCAN( a_benef, { | var | var[1] == benef_id } )

if _scan == 0
    AADD( a_benef, { benef_id, benef_st, osnovica } )
else
    a_benef[ _scan, 3 ] := a_benef[ _scan, 3 ] + osnovica
endif

return




function PrikKBOBenef( a_benef )
local _i
local _ben_osn := 0

if a_benef == NIL .or. LEN( a_benef ) == 0
    return
endif

for _i := 1 to LEN( a_benef )
    _ben_osn += a_benef[ _i, 3 ]
next

nBO := 0

? Lokal("Koef. Bruto osnove benef.(KBO):"), transform( parobr->k3 ,"999.99999%" )
? space(3), Lokal("BRUTO OSNOVA = NETO OSNOVA.BENEF * KBO =")
@ prow(), pcol() + 1 SAY nBo := ROUND2( parobr->k3 / 100 * _ben_osn, gZaok2 ) pict gpici
?

return




