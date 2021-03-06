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


FUNCTION virm_sifarnici()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   OSifVirm()

   AAdd( _opc, "1. opci sifarnici          " )
   AAdd( _opcexe, {|| _sif_opc() } )
   AAdd( _opc, "2. specificni sifarnici " )
   AAdd( _opcexe, {|| _sif_spec() } )

   f18_menu( "sif", .F., _izbor, _opc, _opcexe )

   RETURN



STATIC FUNCTION _sif_opc()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. partneri                    " )
   AAdd( _opcexe, {|| p_partner() } )
   AAdd( _opc, "2. valute" )
   AAdd( _opcexe, {|| P_Valuta() } )
   AAdd( _opc, "3. opcine" )
   AAdd( _opcexe, {|| P_Ops() } )
   AAdd( _opc, "4. banke" )
   AAdd( _opcexe, {|| P_Banke() } )
   AAdd( _opc, "5. sifk" )
   AAdd( _opcexe, {|| P_SifK() } )

   f18_menu( "sopc", .F., _izbor, _opc, _opcexe )

   RETURN .T.



STATIC FUNCTION _sif_spec()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. vrste primalaca                          " )
   AAdd( _opcexe, {|| P_VrPrim() } )
   AAdd( _opc, "2. javni prihodi" )
   AAdd( _opcexe, {|| P_JPrih() } )
   AAdd( _opc, "3. ld   -> virm" )
   AAdd( _opcexe, {|| P_LdVirm() } )


   f18_menu( "ssp", .F., _izbor, _opc, _opcexe )

   RETURN .T.



FUNCTION OSifVirm()

  // o_sifk()
  // o_sifv()
  // o_partner()
   o_vrprim()
   o_valute()
   o_ldvirm()
   o_jprih()
   o_banke()
   o_ops()

   RETURN .T.
