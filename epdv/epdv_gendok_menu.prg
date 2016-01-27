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


FUNCTION epdv_generisanje()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _Izbor := 1

   AAdd( _opc, "1. generiši kuf               " )
   AAdd( _opcexe, {|| gen_kuf() } )
   AAdd( _opc, "2. generiši kif" )
   AAdd( _opcexe, {|| gen_kif() } )

   f18_menu( "gen", .F., _izbor, _opc, _opcexe )

   RETURN
