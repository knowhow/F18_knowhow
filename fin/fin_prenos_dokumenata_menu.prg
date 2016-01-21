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
 

function MnuGenDok()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. generacija dokumenta pocetnog stanja                          ")
AADD( _opcexe, {|| fin_pocetno_stanje_sql() })
AADD( _opc, "2. generacija dokumenta pocetnog stanja (stara opcija/legacy)" )
AADD( _opcexe, {|| GenPocStanja() })
AADD( _opc, "3. generisanje storna naloga " )
AADD( _opcexe, {|| StornoNaloga() })

f18_menu( "gdk", .f., _izbor, _opc, _opcexe )

return


