/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

FUNCTION fin_kartice_menu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   PRIVATE picDEM := FormPicL( gPicDEM, 12 )
   PRIVATE picBHD := FormPicL( gPicBHD, 16 )

   AAdd( _opc, "1. subanalitika                           " )
   AAdd( _opcexe, {|| fin_suban_kartica() } )
   AAdd( _opc, "2. analitika" )
   AAdd( _opcexe, {|| fin_anal_kartica() } )
   AAdd( _opc, "3. sintetika" )
   AAdd( _opcexe, {|| fin_sint_kartica() } )
   AAdd( _opc, "4. sintetika - po mjesecima" )
   AAdd( _opcexe, {|| fin_sint_kart_po_mjesecima() } )

   f18_menu( "fin_kart", .F., _izbor, _opc, _opcexe )

   RETURN .T.
