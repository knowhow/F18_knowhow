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

function Main( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )
local _arg_v := hb_hash()
public gDebug := 9

cre_arg_v_hash( @_arg_v, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )

set_f18_params( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )

f18_init_app( _arg_v )

return

#endif


// vraca hash matricu sa parametrima
static function cre_arg_v_hash( hash )
local _i := 2
local _param
local _count := 0

hash := hb_hash()
hash["p1"] := NIL
hash["p2"] := NIL
hash["p3"] := NIL
hash["p4"] := NIL
hash["p5"] := NIL
hash["p6"] := NIL
hash["p7"] := NIL
hash["p8"] := NIL
hash["p9"] := NIL
hash["p10"] := NIL
hash["p11"] := NIL

do while _i <= PCount()
    // ucitaj parametar
    _param := hb_PValue( _i++ )
    // p1, p2, p3...
    hash[ "p" + ALLTRIM(STR( ++_count )) ] := _param 
enddo

return



// ----------------------------
// ----------------------------
function module_menu( arg_v )
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
local oDb_lock
local _user_roles := f18_user_roles_info()
local _server_db_version := get_version_str( server_db_version() )
local _lock_db 
local _tmp
local _color := "BG+/B"

if arg_v == NIL
    // napravi NIL parametre
    cre_arg_v_hash( @arg_v )
endif

do while .t.

    ++ _count

	clear screen

    _db_params := my_server_params()

    oDb_lock := F18_DB_LOCK():New()
    _lock_db := oDb_lock:is_locked()
    
    _x := 1

    @ _x, mnu_left + 1 SAY "Tekuca baza: " + ALLTRIM( _db_params["database"] ) + " / db ver: " + _server_db_version

    if _lock_db
        _tmp := "[ srv lock " + oDb_lock:lock_params["server_lock"] + " / cli lock " + oDb_lock:lock_params["client_lock"]  + " ]"
    else
        _tmp := ""
    endif
    
    @ _x, col() + 1 SAY _tmp COLOR _color 
    
    ++ _x

    @ _x, mnu_left + 1 SAY "   Korisnik: " + ALLTRIM( _db_params["user"] ) + "   u grupama " + _user_roles

    ++ _x

    @ _x, mnu_left SAY REPLICATE( "-", 55 )

    // backup okidamo samo na prvom ulasku
    // ili na opciji relogina
    if _count == 1 .or. __relogin_opt
       
        // provjera da li je backup locked ?
        if oBackup:locked( .f. )
            oBackup:unlock()
        endif
 
        // automatski backup podataka preduzeca
        f18_auto_backup_data(1)
        __relogin_opt := .f.

    endif

	// resetuj...
	menuop := {}
	menuexec := {}

	// setuj odabir
	set_menu_choices( @menuop, @menuexec, arg_v["p3"], arg_v["p4"], arg_v["p5"], arg_v["p6"], arg_v["p7"] )

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
AADD( menuop, " F. Forsirana sinhronizacija podataka" )
AADD( menuexec, {|| F18AdminOpts():New():force_synchro_db() } )
AADD( menuop, " L. Zakljucavanje/otkljucavanje baze" )
AADD( menuexec, {|| f18_database_lock_menu() } )
AADD( menuop, " P. Parametri aplikacije" )
AADD( menuexec, {|| f18_app_parameters() } )
AADD( menuop, " W. Pregled log-a" )
AADD( menuexec, {|| f18_view_log() } )
AADD( menuop, " V. VPN podrska" )
AADD( menuexec, {|| vpn_support() } )

return


