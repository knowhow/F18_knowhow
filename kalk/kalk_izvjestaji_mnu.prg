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



function MIzvjestaji()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. izvještaji magacin             ")
AADD(_opcexe, {|| kalk_izvjestaji_magacina()})
AADD(_opc,"2. izvještaji prodavnica")
AADD(_opcexe, {|| kalk_izvjestaji_prodavnice_menu()})
AADD(_opc,"3. izvještaji magacin+prodavnica")
AADD(_opcexe, {|| kalk_izvjestaji_mag_i_pro() } )
AADD(_opc,"4. proizvoljni izvjestaji")
AADD(_opcexe, {|| ProizvKalk()})
AADD(_opc,"5. export dokumenata")
AADD(_opcexe, {|| krpt_export()})

f18_menu( "izvj", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return



 
function kalk_izvjestaji_mag_i_pro()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc, "F. finansijski obrt za period mag+prod")
AADD(_opcexe, {|| ObrtPoMjF()})
AADD(_opc, "N. najprometniji artikli")
AADD(_opcexe, {|| NPArtikli()})
AADD(_opc, "O. stanje artikala po objektima ")
AADD(_opcexe, {|| StanjePoObjektima()})

if IsVindija()
    AADD(_opc, "V. pregled prodaje")
    AADD(_opcexe, {|| PregProdaje()})
endif

f18_menu( "izmp", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return




