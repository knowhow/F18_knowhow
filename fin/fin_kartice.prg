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
   AAdd( _opcexe, {|| subKartMnu() } )
   AAdd( _opc, "2. analitika" )
   AAdd( _opcexe, {|| AnKart() } )
   AAdd( _opc, "3. sintetika" )
   AAdd( _opcexe, {|| SinKart() } )
   AAdd( _opc, "4. sintetika - po mjesecima" )
   AAdd( _opcexe, {|| SinKart2() } )

   f18_menu( "fin_kart", .F., _izbor, _opc, _opcexe )

   RETURN


// ------------------------------------------------------------
// subanaliticka kartica - menu
// ------------------------------------------------------------
STATIC FUNCTION subkartmnu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1


   AAdd( _opc, "1. subanalitička kartica (txt) " )
   AAdd( _opcexe, {|| SubKart() } )
   AAdd( _opc, "2. subanalitička kartica (odt)           " )
   AAdd( _opcexe, {|| fin_suban_kartica_sql( NIL ) } )
   f18_menu( "fin_subkart", .F., _izbor, _opc, _opcexe )

   RETURN



