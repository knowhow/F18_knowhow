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

#include "fin.ch"


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

f18_menu( "sp", .f., _izbor, _opc, _opcexe )

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
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. partnera na kontu                                        ")
AADD(opcexe, {|| SpecDPK()})
AADD(opc, "2. otvorene stavke preko-do odredjenog broja dana za konto")
AADD(opcexe, {|| SpecBrDan()})
AADD(opc, "3. konta za partnera")
AADD(opcexe, {|| SpecPop()})
AADD(opc, "4. po analitickim kontima")
AADD(opcexe, {|| SpecPoK()})
AADD(opc, "5. po subanalitickim kontima")
AADD(opcexe, {|| SpecPoKP()})
AADD(opc, "6. za subanaliticki konto / 2")
AADD(opcexe, {|| SpecSubPro()})
AADD(opc, "7. za subanaliticki konto/konto2")
AADD(opcexe, {|| SpecKK2()})
AADD(opc, "8. pregled novih dugovanja/potrazivanja")
AADD(opcexe, {|| PregNDP()})
AADD(opc, "9. pregled partnera bez prometa")
AADD(opcexe, {|| PartVanProm()})

if gRJ=="D" .or. gTroskovi=="D"
	AADD(opc, "A. izvrsenje budzeta/pregled rashoda")
	AADD(opcexe, {|| IzvrsBudz()})
	AADD(opc, "B. pregled prihoda")
	AADD(opcexe, {|| Prihodi()})
endif

AADD(opc, "C. otvorene stavke po dospijecu - po racunima (kao kartica)")
AADD(opcexe, {|| SpecPoDosp(.t.)})
AADD(opc, "D. otvorene stavke po dospijecu - specifikacija partnera")
AADD(opcexe, {|| SpecPoDosp(.f.)})
AADD(opc, "E. rekapitulacija partnera po poslovnim godinama")
AADD(opcexe, {|| RPPG()})
AADD(opc, "F. pregled dugovanja partnera po rocnim intervalima ")
AADD(opcexe, {|| SpecDugPartnera()})
AADD(opc, "S. specifikacija troskova po gradilistima ")
AADD(opcexe, {|| r_spec_tr()})

Menu_SC("spc")

return




// --------------------------------------------------
// specifikacije po godinama
// --------------------------------------------------
function MnuSpecGod()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. po analitickim kontima                   ")
AADD(opcexe, {|| spec_an()})
AADD(opc, "2. po subanalitickim kontima")
AADD(opcexe, {|| spec_sub()})

Menu_SC("spg")
return



