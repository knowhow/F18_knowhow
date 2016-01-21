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
function fin_menu_specifikacije()
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD( _opc, "1. specifikacije (txt)          " )
AADD( _opcexe, { || _txt_specif_mnu() } )
AADD( _opc, "2. specifikacije (odt)          " )
AADD( _opcexe, { || _sql_specif_mnu() } )

f18_menu( "spec", .f., _izbor, _opc, _opcexe )

return


// ------------------------------------------------------
// meni specifikacija sql
// ------------------------------------------------------
static function _sql_specif_mnu()
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD( _opc, "1. specifikacija po subanalitickim kontima          " )
AADD( _opcexe, { || fin_suban_specifikacija_sql() } )

f18_menu( "spsql", .f., _izbor, _opc, _opcexe )

return




static function _txt_specif_mnu()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. partnera na kontu                                        ")
AADD( _opcexe, {|| SpecDPK()} )
AADD( _opc, "2. otvorene stavke preko-do odredjenog broja dana za konto")
AADD( _opcexe, {|| SpecBrDan()} )
AADD( _opc, "3. konta za partnera")
AADD( _opcexe, {|| SpecPop()} )
AADD( _opc, "4. po analitickim kontima")
AADD( _opcexe, {|| SpecPoK()} )
AADD( _opc, "5. po subanalitickim kontima")
AADD( _opcexe, {|| SpecPoKP()} )
AADD( _opc, "6. za subanaliticki konto / 2")
AADD( _opcexe, {|| SpecSubPro()} )
AADD( _opc, "7. za subanaliticki konto/konto2")
AADD( _opcexe, {|| SpecKK2()} )
AADD( _opc, "8. pregled novih dugovanja/potrazivanja")
AADD( _opcexe, {|| PregNDP()} ) 
AADD( _opc, "9. pregled partnera bez prometa")
AADD( _opcexe, {|| PartVanProm()} )

if gRJ=="D" .or. gTroskovi=="D"
	AADD( _opc, "A. izvrsenje budzeta/pregled rashoda")
	AADD( _opcexe, {|| IzvrsBudz()} )
	AADD( _opc, "B. pregled prihoda" )
	AADD( _opcexe, {|| Prihodi()})
endif

AADD( _opc, "C. otvorene stavke po dospijecu - po racunima (kao kartica)")
AADD( _opcexe, {|| SpecPoDosp(.t.)})
AADD( _opc, "D. otvorene stavke po dospijecu - specifikacija partnera")
AADD( _opcexe, {|| SpecPoDosp(.f.)})
AADD( _opc, "F. pregled dugovanja partnera po rocnim intervalima ")
AADD( _opcexe, {|| SpecDugPartnera() } )
AADD( _opc, "S. specifikacija troskova po gradilistima ")
AADD( _opcexe, {|| r_spec_tr() } )

f18_menu( "spct", .f., _izbor, _opc, _opcexe )

return



