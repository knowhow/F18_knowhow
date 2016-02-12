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

   AAdd( _opc, "1. specifikacije (txt)          " )
   AAdd( _opcexe, {|| _txt_specif_mnu() } )
   AAdd( _opc, "2. specifikacije (odt)          " )
   AAdd( _opcexe, {|| _sql_specif_mnu() } )

   f18_menu( "spec", .F., _izbor, _opc, _opcexe )

   RETURN


// ------------------------------------------------------
// meni specifikacija sql
// ------------------------------------------------------
STATIC FUNCTION _sql_specif_mnu()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   AAdd( _opc, "1. specifikacija po subanalitičkim kontima          " )
   AAdd( _opcexe, {|| fin_suban_specifikacija_sql() } )

   f18_menu( "spsql", .F., _izbor, _opc, _opcexe )

   RETURN .T.




STATIC FUNCTION _txt_specif_mnu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. partnera na kontu                                        " )
   AAdd( _opcexe, {|| SpecDPK() } )
   AAdd( _opc, "2. otvorene stavke preko-do odredjenog broja dana za konto" )
   AAdd( _opcexe, {|| SpecBrDan() } )
   AAdd( _opc, "3. konta za partnera" )
   AAdd( _opcexe, {|| SpecPop() } )
   AAdd( _opc, "4. po analitičkim kontima" )
   AAdd( _opcexe, {|| SpecPoK() } )
   AAdd( _opc, "5. po subanalitičkim kontima" )
   AAdd( _opcexe, {|| fin_spec_po_suban_kontima() } )
   AAdd( _opc, "6. za subanalitički konto / 2" )
   AAdd( _opcexe, {|| SpecSubPro() } )
   AAdd( _opc, "7. za subanalitički konto/konto2" )
   AAdd( _opcexe, {|| SpecKK2() } )
   AAdd( _opc, "8. pregled novih dugovanja/potraživanja" )
   AAdd( _opcexe, {|| PregNDP() } )
   AAdd( _opc, "9. pregled partnera bez prometa" )
   AAdd( _opcexe, {|| PartVanProm() } )

   IF gRJ == "D" .OR. gTroskovi == "D"
      AAdd( _opc, "A. izvrsenje budzeta/pregled rashoda" )
      AAdd( _opcexe, {|| IzvrsBudz() } )
      AAdd( _opc, "B. pregled prihoda" )
      AAdd( _opcexe, {|| Prihodi() } )
   ENDIF

   AAdd( _opc, "C. otvorene stavke po dospijeću - po racunima (kao kartica)" )
   AAdd( _opcexe, {|| SpecPoDosp( .T. ) } )
   AAdd( _opc, "D. otvorene stavke po dospijeću - specifikacija partnera" )
   AAdd( _opcexe, {|| SpecPoDosp( .F. ) } )
   AAdd( _opc, "F. pregled dugovanja partnera po ročnim intervalima " )
   AAdd( _opcexe, {|| SpecDugPartnera() } )
   AAdd( _opc, "S. specifikacija troskova po gradilištima " )
   AAdd( _opcexe, {|| r_spec_tr() } )

   f18_menu( "spct", .F., _izbor, _opc, _opcexe )

   RETURN .T.
