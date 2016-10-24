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


// ------------------------------------------------------
// meni specifikacija
// ------------------------------------------------------
FUNCTION fin_menu_specifikacije()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   AAdd( _opc, "1. fin specifikacije (txt)          " )
   AAdd( _opcexe, {|| fin_izvj_specif_txt_menu() } )
   AAdd( _opc, "2. fin specifikacije / 2          " )
   AAdd( _opcexe, {|| fin_izvjestaji_specif_2_menu() } )
   AAdd( _opc, "3. kupci pregled dugovanja" )
   AAdd( _opcexe, {|| fin_kupci_pregled_dugovanja() } )

   f18_menu( "spec", .F., _izbor, _opc, _opcexe )

   RETURN .T.


// ------------------------------------------------------
// meni specifikacija sql
// ------------------------------------------------------
STATIC FUNCTION fin_izvjestaji_specif_2_menu()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   AAdd( _opc, "1. specifikacija po subanalitičkim kontima-2          " )
   AAdd( _opcexe, {|| fin_suban_specifikacija_sql() } )


   f18_menu( "spsql", .F., _izbor, _opc, _opcexe )

   RETURN .T.




STATIC FUNCTION fin_izvj_specif_txt_menu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. partnera na kontu                                        " )
   AAdd( _opcexe, {|| fin_spec_partnera_na_kontu() } )
   AAdd( _opc, "2. otvorene stavke preko-do odredjenog broja dana za konto" )
   AAdd( _opcexe, {|| fin_spec_otv_stavke_preko_dana() } )
   AAdd( _opc, "3. konta za partnera" )
   AAdd( _opcexe, {|| SpecPop() } )
   AAdd( _opc, "4. po analitičkim kontima" )
   AAdd( _opcexe, {|| SpecPoK() } )
   AAdd( _opc, "5. po subanalitičkim kontima" )
   AAdd( _opcexe, {|| fin_specifikacija_suban() } )
   AAdd( _opc, "6. za subanalitički konto / 2" )
   AAdd( _opcexe, {|| SpecSubPro() } )
   AAdd( _opc, "7. za subanalitički konto/konto2" )
   AAdd( _opcexe, {|| SpecKK2() } )
   AAdd( _opc, "8. pregled novih dugovanja/potraživanja" )
   AAdd( _opcexe, {|| PregNDP() } )
   AAdd( _opc, "9. pregled partnera bez prometa" )
   AAdd( _opcexe, {|| PartVanProm() } )

   IF gFinRj == "D" .OR. gTroskovi == "D"
      AAdd( _opc, "A. izvrsenje budzeta/pregled rashoda" )
      AAdd( _opcexe, {|| IzvrsBudz() } )
      AAdd( _opc, "B. pregled prihoda" )
      AAdd( _opcexe, {|| Prihodi() } )
   ENDIF



   AAdd( _opc, "S. specifikacija troskova po gradilištima " )
   AAdd( _opcexe, {|| r_spec_tr() } )

   f18_menu( "spct", .F., _izbor, _opc, _opcexe )

   RETURN .T.
