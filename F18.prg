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

#include "inkey.ch"

#ifndef TEST

function Main(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)

set_f18_params( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )

public gDebug := 9

f18_init_app()
f18_app_parameters( .t. )

set_hot_keys()

module_menu(p3, p4, p5, p6, p7)
log_close()

return

#endif

// ----------------------------
// ----------------------------
function module_menu(p3, p4, p5, p6, p7)
local menuop := {}
local menuexec := {}
local mnu_choice
local mnu_left := 2
local mnu_top := 2
local mnu_bottom := 23
local mnu_right := 65

do while .t.

	clear screen

	// resetuj...
	menuop := {}
	menuexec := {}

	// setuj odabir
	set_menu_choices( @menuop, @menuexec, p3, p4, p5, p6, p7 )

	// daj mi odabir
 	mnu_choice := ACHOICE( mnu_top, mnu_left, mnu_bottom, mnu_right, menuop, .t. )

 	do case

		case mnu_choice == 0
    		exit
		case mnu_choice > 0 
			eval( menuexec[ mnu_choice ] )
	endcase

 	loop

enddo


// -----------------------------------------------------------------------------
// setuje matricu sa odabirom za meni
// -----------------------------------------------------------------------------
static function set_menu_choices( menuop, menuexec, p3, p4, p5, p6, p7 )
local _count := 0
local _brojac

if f18_use_module( "fin" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") FIN   # finansijsko poslovanje                 " )
	AADD( menuexec, {|| MainFin( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "kalk" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") KALK  # robno-materijalno poslovanje" )
	AADD( menuexec, {|| MainKalk( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "fakt" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") FAKT  # fakturisanje" )
	AADD( menuexec, {|| MainFakt( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "epdv" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") ePDV  # elektronska evidencija PDV-a" )
	AADD( menuexec, {|| MainEpdv( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "ld" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") LD    # obracun plata" )
	AADD( menuexec, {|| MainLd( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "rnal" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") RNAL  # radni nalozi" )
	AADD( menuexec, {|| MainRnal( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "os" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") OS/SII# osnovna sredstva i sitan inventar" )
	AADD( menuexec, {|| MainOs( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "pos" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") POS   # maloprodajna kasa" )
	AADD( menuexec, {|| MainPos( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "mat" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") MAT   # materijalno" )
	AADD( menuexec, {|| MainMat( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "virm" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ") VIRM  # virmani" )
	AADD( menuexec, {|| MainVirm( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

AADD( menuop, "---------------------------------------------" )
AADD( menuexec, {|| nil } )

// ostale opcije...
AADD( menuop, " P) Parametri aplikacije" )
AADD( menuexec, {|| f18_app_parameters() } )
AADD( menuop, " R) ReLogin" )
AADD( menuexec, {|| relogin() } )
AADD( menuop, " W) Pregled F18.log-a" )
AADD( menuexec, {|| view_log() } )
AADD( menuop, " X) Erase / full synchro tabela" )
AADD( menuexec, {|| full_table_synchro() } )
AADD( menuop, " V) VPN podrska" )
AADD( menuexec, {|| vpn_support() } )

return
