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
#include "hbthread.ch"

static __relogin_opt := .f.

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
local mnu_top := 5
local mnu_bottom := 23
local mnu_right := 65
local _x := 1
local _db_params
local _count := 0
local oBackup := F18Backup():New()

do while .t.

    ++ _count

	clear screen

    _db_params := my_server_params()

    _x := 1

    @ _x, mnu_left + 1 SAY "Tekuca baza: " + ALLTRIM( _db_params["database"] )
    
    ++ _x

    @ _x, mnu_left + 1 SAY "   Korisnik: " + ALLTRIM( _db_params["user"] )

    ++ _x

    @ _x, mnu_left + 1 SAY REPLICATE( "-", 50 )

    // backup okidamo samo na prvom ulasku
    // ili na opciji relogina
    if _count == 1 .or. __relogin_opt
        
        // automatski backup podataka preduzeca
        f18_auto_backup_data(1)
        __relogin_opt := .f.

    endif

	// resetuj...
	menuop := {}
	menuexec := {}

	// setuj odabir
	set_menu_choices( @menuop, @menuexec, p3, p4, p5, p6, p7 )

	// daj mi odabir
    // ubacio sam ACHOICE2 radi meni funkcija stadnardnih...
 	mnu_choice := ACHOICE2( mnu_top, mnu_left, mnu_bottom, mnu_right, menuop, .t., "MenuFunc", 1 )

 	do case
		case mnu_choice == 0

            if !oBackup:locked
    		    exit
            else
                MsgBeep( oBackup:backup_in_progress_info() )
            endif

		case mnu_choice > 0 
			eval( menuexec[ mnu_choice ] )
	endcase

 	loop

enddo

return

// -----------------------------------------------------------------------------
// setuje matricu sa odabirom za meni
// -----------------------------------------------------------------------------
static function set_menu_choices( menuop, menuexec, p3, p4, p5, p6, p7 )
local _count := 0
local _brojac

if f18_use_module( "fin" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". FIN   # finansijsko poslovanje                 " )
	AADD( menuexec, {|| MainFin( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "kalk" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". KALK  # robno-materijalno poslovanje" )
	AADD( menuexec, {|| MainKalk( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "fakt" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". FAKT  # fakturisanje" )
	AADD( menuexec, {|| MainFakt( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "epdv" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". ePDV  # elektronska evidencija PDV-a" )
	AADD( menuexec, {|| MainEpdv( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "ld" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". LD    # obracun plata" )
	AADD( menuexec, {|| MainLd( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "rnal" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". RNAL  # radni nalozi" )
	AADD( menuexec, {|| MainRnal( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "os" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". OS/SII# osnovna sredstva i sitan inventar" )
	AADD( menuexec, {|| MainOs( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "pos" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". POS   # maloprodajna kasa" )
	AADD( menuexec, {|| MainPos( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "mat" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". MAT   # materijalno" )
	AADD( menuexec, {|| MainMat( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "virm" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". VIRM  # virmani" )
	AADD( menuexec, {|| MainVirm( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif

if f18_use_module( "reports" )
	_brojac := PADL( ALLTRIM( STR( ++ _count )), 2 )
	AADD( menuop, _brojac + ". REPORTS  # izvjestajni modul" )
	AADD( menuexec, {|| MainReports( my_user(), "dummy", p3, p4, p5, p6, p7 ) } )
endif


AADD( menuop, "---------------------------------------------" )
AADD( menuexec, {|| NIL } )

// ostale opcije...
AADD( menuop, " B. Backup podataka" )
AADD( menuexec, {|| f18_backup_data() } )
AADD( menuop, " P. Parametri aplikacije" )
AADD( menuexec, {|| f18_app_parameters() } )
AADD( menuop, " R. ReLogin" )
AADD( menuexec, {|| __relogin_opt := relogin(), .t. } )
AADD( menuop, " W. Pregled log-a" )
AADD( menuexec, {|| f18_view_log() } )
AADD( menuop, " X. Erase / full synchro tabela" )
AADD( menuexec, {|| full_table_synchro() } )
AADD( menuop, " V. VPN podrska" )
AADD( menuexec, {|| vpn_support() } )

return


