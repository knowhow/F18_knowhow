/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

function MnuOstOperacije()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. povrat dokumenta u pripremu                " )
AADD( _opcexe, {|| povrat_fin_naloga() })
AADD( _opc, "2. preknjizenje     ")
AADD( _opcexe, {|| Preknjizenje()})
AADD( _opc, "3. prebacivanje kartica")
AADD( _opcexe, {|| Prebfin_kartica()})
AADD( _opc, "4. otvorene stavke")
AADD( _opcexe, { || OStav() } )
AADD( _opc, "5. obrada kamata ")
AADD( _opcexe, {|| fin_kamate_menu() })

f18_menu( "oop", .f., _izbor, _opc, _opcexe )

return



