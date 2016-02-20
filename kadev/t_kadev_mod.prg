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



CLASS TKadevMod FROM TAppMod

   METHOD NEW
   METHOD set_module_gvars
   METHOD mMenu
   METHOD mMenuStandard

END CLASS


METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self



METHOD mMenu()

   PRIVATE Izbor
   PRIVATE lPodBugom

   set_hot_keys()

   Izbor := 1

   @ 1, 2 SAY PadC( gTS + ": " + gNFirma, 50, "*" )
   @ 4, 5 SAY ""

   ::mMenuStandard()

   RETURN NIL



// ----------------------------------------
// ----------------------------------------
METHOD mMenuStandard

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. podaci                                 " )
   AAdd( _opcexe, {|| kadev_data() } )
   AAdd( _opc, "2. pretrazivanje" )
   AAdd( _opcexe, {|| kadev_search() } )
   AAdd( _opc, "3. rekalkulacija" )
   AAdd( _opcexe, {|| kadev_recalc() } )
   AAdd( _opc, "4. izvjestaji" )
   AAdd( _opcexe, {|| kadev_rpt_menu() } )
   AAdd( _opc, "5. obrasci" )
   AAdd( _opcexe, {|| kadev_form() } )
   AAdd( _opc, "6. radna karta" )
   AAdd( _opcexe, {|| kadev_work_card() } )
   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "S. sifrarnici" )
   AAdd( _opcexe, {|| kadev_sifre_menu() } )
   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "X. parametri" )
   AAdd( _opcexe, {|| kadev_params_menu() } )

   f18_menu( "kadev", .T., _izbor, _opc, _opcexe )

   RETURN


// ----------------------------------------
// ----------------------------------------
METHOD set_module_gvars()

   kadev_set_global_vars()

   RETURN



FUNCTION kadev_set_global_vars()


   PUBLIC glBezVoj := .T.
   PUBLIC gVojEvid := "N"
   // bez vojne evidencije
   PUBLIC gnLMarg := 1
   // lijeva margina
   PUBLIC gnTMarg := 1
   // top-gornja margina teksta
   PUBLIC gTabela := 1
   // fino crtanje tabele
   PUBLIC gA43 := "4"
   // format papira
   PUBLIC gnRedova := 64
   // za ostranicavanje - broj redova po stranici
   PUBLIC gOstr := "D"
   // ostranicavanje
   PUBLIC gPostotak := "D"
   // prikaz procenta uradjenog posla (znacajno kod
   // dugih cekanja na izvrsenje opcije)
   PUBLIC gDodKar1 := "Karakteristika 1"
   PUBLIC gDodKar2 := "Karakteristika 2"
   PUBLIC gTrPromjena := "KP"
   PUBLIC gCentOn := "N"

   kadev_read_params()

   IF gVojEvid == "D"
      glBezVoj := .F.
   ENDIF

   IF gCentOn == "D"
      SET CENTURY ON
   ELSE
      SET CENTURY OFF
   ENDIF

   RETURN
