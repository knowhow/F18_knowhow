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

AADD(_opc,"1. izvjestaji magacin             ")
AADD(_opcexe, {|| kalk_izvjestaji_magacina()})
AADD(_opc,"2. izvjestaji prodavnica")
AADD(_opcexe, {|| kalk_izvjestaji_prodavnice()})
AADD(_opc,"3. izvjestaji magacin+prodavnica")
AADD(_opcexe, {|| kalk_izvjestaji_mag_i_pro() } )
AADD(_opc,"4. proizvoljni izvjestaji")
AADD(_opcexe, {|| ProizvKalk()})
AADD(_opc,"5. export dokumenata")
AADD(_opcexe, {|| krpt_export()})

f18_menu( "izvj", .f., _izbor, _opc, _opcexe )

close all
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

if IsPlanika()
    AADD(_opc, "Z. pregled kretanja zaliha mag/prod     ")
    AADD(_opcexe, {|| PreglKret()})
    AADD(_opc, "M. mjesecni iskazi prodavnice/magacin")
    AADD(_opcexe, {|| ObrazInv()})
endif

if IsVindija()
    AADD(_opc, "V. pregled prodaje")
    AADD(_opcexe, {|| PregProdaje()})
endif

f18_menu( "izmp", .f., _izbor, _opc, _opcexe )

close all
return




