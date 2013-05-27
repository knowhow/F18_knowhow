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


#include "kadev.ch"


function kadev_sifre_menu()
local _izbor := 1
local _opc := {}
local _opcexe := {}

kadev_o_tables()

AADD( _opc, "1. radna jedinica                       ")
AADD( _opcexe, {|| p_kadev_rj() })
AADD( _opc, "2. radno mjesto ")
AADD( _opcexe, {|| p_rmj() })
AADD( _opc, "3. zanimanje")
AADD( _opcexe, {|| p_zanim() })
AADD( _opc, "4. strucna sprema ")
AADD( _opcexe, {|| p_strspr() })
AADD( _opc, "5. promjene ")
AADD( _opcexe, {|| p_promj() })
AADD( _opc, "6. mjesna zajednica ")
AADD( _opcexe, {|| p_mz() })
AADD( _opc, "7. " + gDodKar1 )
AADD( _opcexe, {|| p_k1() })
AADD( _opc, "8. " + gDodKar2 )
AADD( _opcexe, {|| p_k2() })
AADD( _opc, "9. nacija ")
AADD( _opcexe, {|| p_nac() })
AADD( _opc, "A. ratni raspored ")
AADD( _opcexe, {|| p_rrasp() })
AADD( _opc, "B. cin ")
AADD( _opcexe, {|| p_cin() })
AADD( _opc, "C. " + if(glBezVoj, "poznavanje stranog jezika", "ves") )
AADD( _opcexe, {|| p_ves() })
AADD( _opc, "D. sistematizacija ")
AADD( _opcexe, {|| p_rjrmj() })
AADD( _opc, "E. stope benef.r.st ")
AADD( _opcexe, {|| p_kbenrst() })
AADD( _opc, "F. neradni dani ")
AADD( _opcexe, {|| p_nerdan() })
AADD( _opc, "--------------------------- ")
AADD( _opcexe, {|| nil })
AADD( _opc, "R. rjesenja ")
AADD( _opcexe, {|| p_rjes() })

f18_menu("kdsif", .f., _izbor, _opc, _opcexe )

return



function kadev_rpt_menu()
local _opc := {}
local _opcexe := {}
local _izbor := 2

AADD( _opc, STRKZN("1. pregled godiçnjih odmora             ", "8", gKodnaS ) )
AADD( _opcexe, {|| gododmori() })
AADD( _opc, STRKZN("2. pregled sta§a u firmi", "8", gKodnaS ) )
AADD( _opcexe, {|| stazufirmi() })

f18_menu( "izvjestaji", .f., _izbor, _opc, _opcexe )
return


