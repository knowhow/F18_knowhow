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


CLASS TEpdvMod FROM TAppMod

   METHOD NEW
   METHOD setGVars
   METHOD mMenu
   METHOD mMenuStandard


END CLASS

METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self




METHOD mMenu()

   my_close_all_dbf()

   set_hot_keys()

   @ 1, 2 SAY PadC( gNFirma, 50, "*" )
   @ 4, 5 SAY ""

   ::mMenuStandard()

   RETURN NIL


METHOD mMenuStandard()

   PRIVATE Izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. KUF unos/ispravka           " )
   AAdd( opcexe, {|| epdv_edit_kuf() } )
   AAdd( opc, "2. KIF unos/ispravka" )
   AAdd( opcexe, {|| epdv_edit_kif() } )
   AAdd( opc, "3. generacija dokumenata" )
   AAdd( opcexe, {|| epdv_generisanje() } )
   AAdd( opc, "4. izvještaji" )
   AAdd( opcexe, {|| epdv_izvjestaji() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "S. šifarnici" )
   AAdd( opcexe, {|| epdv_sifrarnici() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "9. administracija baze podataka" )
   AAdd( opcexe, {|| epdv_admin_menu() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "X. parametri" )
   AAdd( opcexe, {|| epdv_parametri() } )

   Menu_SC( "gpdv", .T., .F. )

   RETURN .T.




METHOD setGVars()

   set_global_vars()
   set_roba_global_vars()

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   PUBLIC gPicVrijednost := "9999999.99"
   PUBLIC gL_kto_dob := PadR( "541;", 100 )
   PUBLIC gL_kto_kup := PadR( "211;", 100 )
   PUBLIC gKt_updv := PadR( "260;", 100 )
   PUBLIC gKt_ipdv := PadR( "560;", 100 )

   epdv_set_params()

   O_PARAMS
   Rpar( "p1", @gPicVrijednost )

   SELECT ( F_PARAMS )
   USE

   PUBLIC gModul
   PUBLIC gTema
   PUBLIC gGlBaza

   gModul := "EPDV"
   gTema := "OSN_MENI"
   gGlBaza := "PDV.DBF"

   PUBLIC cZabrana := "Opcija nedostupna za ovaj nivo !!!"

   RETURN
