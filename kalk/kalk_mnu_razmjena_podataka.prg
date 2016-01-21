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


function kalk_razmjena_podataka()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD(_opc,"1. generisi FIN,FAKT dokumente (kontiraj)      ")
AADD(_opcexe, {|| Rekapk(.t.)})
AADD(_opc,"2. iz FAKT generisi KALK dokumente")
AADD(_opcexe, {|| Faktkalk()})
AADD(_opc,"3. iz TOPS generisi KALK dokumente")
AADD(_opcexe, {|| mnu_prenos_tops_u_kalk()})
AADD(_opc,"4. iz KALK generisi TOPS dokumente")
AADD(_opcexe, {|| mnu_prenos_kalk_u_tops()} )
AADD(_opc,"5. import txt")
AADD(_opcexe, {|| MnuImpTxt()} )
AADD(_opc,"6. import csv fajl ")
AADD(_opcexe, {|| MnuImpCSV()} )
AADD(_opc,"-----------------------------------")
AADD(_opcexe, nil )
AADD(_opc,"A. kontiraj dokumente za period - u pripremu")
AADD(_opcexe, {|| KontVise()} )
AADD(_opc,"B. kontiraj automatski kalkulacije za period")
AADD(_opcexe, {|| kont_v_kalk()} )

f18_menu( "rmod", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()

return



static function mnu_prenos_tops_u_kalk()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. prenos podataka pos->kalk                        ")
AADD( _opcexe, {|| kalk_preuzmi_tops_dokumente() } )
AADD( _opc, "2. prenos podataka pos->kalk (razduzi automatski)")
AADD( _opcexe, {|| kalk_preuzmi_tops_dokumente_auto() } )
AADD( _opc, "3. pos->kalk 96 po normativima za period ")
AADD( _opcexe, {|| tops_nor_96() } )

f18_menu( "rpka", .f., _izbor, _opc, _opcexe )

return



