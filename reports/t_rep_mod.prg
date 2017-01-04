/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


CLASS TReportsMod FROM TAppMod

   METHOD NEW
   METHOD set_module_gvars

   METHOD mMenu
   METHOD programski_modul_osnovni_meni

ENDCLASS



METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self




// -----------------------------------------------
// -----------------------------------------------
METHOD mMenu()

   CLOSE ALL

   @ 1, 2 SAY PadC( self_organizacija_naziv(), 50, "*" )
   @ 4, 5 SAY ""

   ::programski_modul_osnovni_meni()

   RETURN NIL



METHOD programski_modul_osnovni_meni()

   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. finansijski izvještaji                                  " )
   AAdd( opcexe, {|| fin_suban_izvjestaji() } )
   AAdd( opc, "2. robni izvjestaji      " )
   AAdd( opcexe, {|| NIL } )


   f18_menu_sa_priv_vars_opc_opcexe_izbor( "grep", .T., .F. )

   RETURN




METHOD set_module_gvars()

   gModul := "REPORTS"

   RETURN .T.
