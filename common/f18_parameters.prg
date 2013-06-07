/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"


// parametri aplikacije
function f18_app_parameters( just_set )
local _x := 1
local _pos_x
local _pos_y
local _left := 20
local _fin, _kalk, _fakt, _epdv, _virm, _ld, _os, _rnal, _mat, _reports, _kadev
local _pos
local _email_server, _email_port, _email_username, _email_userpass, _email_from
local _email_to, _email_cc
local _proper_name, _params
local _log_delete_interval
local _backup_company, _backup_server
local _backup_removable, _backup_ping_time

// parametri modula koristenih na glavnom meniju...
_fin := fetch_metric( "main_menu_fin", my_user(), "D" )
_kalk := fetch_metric( "main_menu_kalk", my_user(), "D" )
_fakt := fetch_metric( "main_menu_fakt", my_user(), "D" )
_ld := fetch_metric( "main_menu_ld", my_user(), "N" )
_epdv := fetch_metric( "main_menu_epdv", my_user(), "N" )
_virm := fetch_metric( "main_menu_virm", my_user(), "N" )
_os := fetch_metric( "main_menu_os", my_user(), "N" )
_rnal := fetch_metric( "main_menu_rnal", my_user(), "N" )
_mat := fetch_metric( "main_menu_mat", my_user(), "N" )
_pos := fetch_metric( "main_menu_pos", my_user(), "N" )
_reports := fetch_metric( "main_menu_reports", my_user(), "N" )
_kadev := fetch_metric( "main_menu_kadev", my_user(), "N" )

// email parametri
_email_server := PADR( fetch_metric( "email_server", my_user(), "" ), 100 )
_email_port := fetch_metric( "email_port", my_user(), 25 )
_email_username := PADR( fetch_metric( "email_user_name", my_user(), "" ), 100 )
_email_userpass := PADR( fetch_metric( "email_user_pass", my_user(), "" ), 50 )
_email_from := PADR( fetch_metric( "email_from", my_user(), "" ), 100 )
_email_to := PADR( fetch_metric( "email_to_default", my_user(), "" ), 500 )
_email_cc := PADR( fetch_metric( "email_cc_default", my_user(), "" ), 500 )

// maticni podaci
_proper_name := PADR( fetch_metric( "my_proper_name", my_user(), "" ), 50 )

// log podaci
_log_delete_interval := fetch_metric( "log_delete_level", NIL, 30 )

// backup podaci
_backup_company := fetch_metric( "backup_company_interval", my_user(), 0 )
_backup_server := fetch_metric( "backup_server_interval", my_user(), 0 )
_backup_removable := PADR( fetch_metric( "backup_removable_drive", my_user(), "" ), 300 )

#ifdef __PLATFORM__WINDOWS
    // samo za windows interesantno
    _backup_ping_time := fetch_metric( "backup_windows_ping_time", my_user(), 0 )
#else
    _backup_ping_time := 0
#endif

if just_set == nil
	just_set := .f.
endif

if !just_set

	clear screen
	_pos_x := 2
	_pos_y := 3

	@ _pos_x, _pos_y SAY "Odabir modula za glavni meni ***" COLOR "I"

	@ _pos_x + _x, _pos_y SAY SPACE(2) + "FIN:" GET _fin PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "KALK:" GET _kalk PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "FAKT:" GET _fakt PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "ePDV:" GET _epdv PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "LD:" GET _ld PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "VIRM:" GET _virm PICT "@!"
	
	++ _x
	@ _pos_x + _x, _pos_y SAY SPACE(2) + "OS/SII:" GET _os PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "POS:" GET _pos PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "MAT:" GET _mat PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "RNAL:" GET _rnal PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "KADEV:" GET _kadev PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "REPORTS:" GET _reports PICT "@!"

	++ _x
	++ _x

	@ _pos_x + _x, _pos_y SAY "Maticni podaci korisnika ***" COLOR "I"

    ++ _x
    ++ _x

	@ _pos_x + _x, _pos_y SAY PADL( "Puno ime i prezime:", _left ) GET _proper_name PICT "@S30"

    ++ _x
    ++ _x

	@ _pos_x + _x, _pos_y SAY "Email parametri ***" COLOR "I"

	++ _x

	@ _pos_x + _x, _pos_y SAY PADL( "email server:", _left ) GET _email_server PICT "@S30"
	@ _pos_x + _x, col() + 1 SAY "port:" GET _email_port PICT "9999"
 	++ _x
	@ _pos_x + _x, _pos_y SAY PADL( "username:", _left ) GET _email_username PICT "@S30"
	@ _pos_x + _x, col() + 1 SAY "password:" GET _email_userpass PICT "@S30" COLOR "BG/BG"
	++ _x
	@ _pos_x + _x, _pos_y SAY PADL( "moja email adresa:", _left ) GET _email_from PICT "@S40"
	++ _x
	@ _pos_x + _x, _pos_y SAY PADL( "slati postu na adrese:", _left ) GET _email_to PICT "@S70"
	++ _x
	@ _pos_x + _x, _pos_y SAY PADL( "cc adrese:", _left ) GET _email_cc PICT "@S70"

    ++ _x
    ++ _x

	@ _pos_x + _x, _pos_y SAY "Parametri log-a ***" COLOR "I"

	++ _x

	@ _pos_x + _x, _pos_y SAY "Brisi stavke log tabele starije od broja dana (def. 30):" GET _log_delete_interval PICT "9999"
	
    ++ _x
    ++ _x

	@ _pos_x + _x, _pos_y SAY "Backup parametri ***" COLOR "I"

	++ _x

	@ _pos_x + _x, _pos_y SAY "Automatski backup podataka preduzeca (interval dana 0 - ne radi nista):" GET _backup_company PICT "999"
	
	++ _x

	@ _pos_x + _x, _pos_y SAY "Automatski backup podataka servera (interval 0 - ne radi nista):" GET _backup_server PICT "999"

	++ _x

	@ _pos_x + _x, _pos_y SAY "Remote backup lokacija:" GET _backup_removable PICT "@S60"

    #ifdef __PLATFORM__WINDOWS
	    
        ++ _x
	    @ _pos_x + _x, _pos_y SAY "Ping time kod backup komande:" GET _backup_ping_time PICT "99"

    #endif


	read

	if LastKey() == K_ESC
    	return
	endif

endif

// parametri modula...
set_metric( "main_menu_fin", my_user(), _fin )
set_metric( "main_menu_kalk", my_user(), _kalk )
set_metric( "main_menu_fakt", my_user(), _fakt )
set_metric( "main_menu_ld", my_user(), _ld )
set_metric( "main_menu_virm", my_user(), _virm )
set_metric( "main_menu_os", my_user(), _os )
set_metric( "main_menu_epdv", my_user(), _epdv )
set_metric( "main_menu_rnal", my_user(), _rnal )
set_metric( "main_menu_mat", my_user(), _mat )
set_metric( "main_menu_pos", my_user(), _pos )
set_metric( "main_menu_kadev", my_user(), _kadev )
set_metric( "main_menu_reports", my_user(), _reports )

// email parametri
set_metric( "email_server", my_user(), ALLTRIM( _email_server ) )
set_metric( "email_port", my_user(), _email_port )
set_metric( "email_user_name", my_user(), ALLTRIM( _email_username ) )
set_metric( "email_user_pass", my_user(), ALLTRIM( _email_userpass ) ) 
set_metric( "email_from", my_user(), ALLTRIM( _email_from ) )
set_metric( "email_to_default", my_user(), ALLTRIM( _email_to ) )
set_metric( "email_cc_default", my_user(), ALLTRIM( _email_cc ) )

// maticni podaci
set_metric( "my_proper_name", my_user(), ALLTRIM( _proper_name ) )

// log podaci
set_metric( "log_delete_level", NIL, _log_delete_interval )

// backup podaci
set_metric( "backup_company_interval", my_user(), _backup_company )
set_metric( "backup_server_interval", my_user(), _backup_server )
set_metric( "backup_removable_drive", my_user(), ALLTRIM( _backup_removable ) )

#ifdef __PLATFORM__WINDOWS
    set_metric( "backup_windows_ping_time", my_user(), _backup_ping_time )
#endif

return


// ---------------------------------------------------------------------
// koristi se pojedini od modula na osnovu parametara
// ---------------------------------------------------------------------
function f18_use_module( module_name )
local _ret := .f.
local _default := "N"

// reports modul treba biti po defaultu dozvoljen
if module_name $ "fin#kalk#fakt"
    _default := "D"
endif

// default odgovor za sve module je "N"
if fetch_metric( "main_menu_" + module_name, my_user(), _default ) == "D"
	_ret := .t.
endif

return _ret



// ------------------------------------------------------------------------
// podesenje aktivnih modula kod startanja aplikacije po prvi put
// ------------------------------------------------------------------------
function f18_set_active_modules()
local _ok := .f.
local _fin, _kalk, _fakt, _ld, _epdv, _virm, _os, _rnal, _pos, _mat, _reports, _kadev
local _pos_x, _pos_y
local _x := 1
local _len := 8
local _corr := "D"
private GetList := {}

// parametri modula koristenih na glavnom meniju...
_fin := fetch_metric( "main_menu_fin", my_user(), "D" )
_kalk := fetch_metric( "main_menu_kalk", my_user(), "D" )
_fakt := fetch_metric( "main_menu_fakt", my_user(), "D" )
_ld := fetch_metric( "main_menu_ld", my_user(), "N" )
_epdv := fetch_metric( "main_menu_epdv", my_user(), "N" )
_virm := fetch_metric( "main_menu_virm", my_user(), "N" )
_os := fetch_metric( "main_menu_os", my_user(), "N" )
_rnal := fetch_metric( "main_menu_rnal", my_user(), "N" )
_mat := fetch_metric( "main_menu_mat", my_user(), "N" )
_pos := fetch_metric( "main_menu_pos", my_user(), "N" )
_kadev := fetch_metric( "main_menu_kadev", my_user(), "N" )
_reports := fetch_metric( "main_menu_reports", my_user(), "N" )

Box(, 10, 70 )

    // 1
	@ m_x + _x, m_y + 2 SAY "*** Odabir modula za glavni meni ***" COLOR "I"

    ++ _x
    ++ _x

    // 3
    @ m_x + _x, m_y + 2 SAY hb_utf8tostr( "Prvi put pokrećete aplikaciju, potrebno odabrati module" )

    ++ _x

    // 4
    @ m_x + _x, m_y + 2 SAY hb_utf8tostr( "koji će se nakon sinhronizacije pojaviti na meniju" )

    ++ _x
    ++ _x

    // 6
	@ m_x + _x, m_y + 2 SAY PADL( "FIN:", _len ) GET _fin PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "KALK:", _len ) GET _kalk PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "FAKT:", _len ) GET _fakt PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "ePDV:", _len ) GET _epdv PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "LD:", _len ) GET _ld PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "VIRM:", _len ) GET _virm PICT "@!"
	
	++ _x
    ++ _x

    // 8
	@ m_x + _x, m_y + 2 SAY PADL( "OS/SII:", _len ) GET _os PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "POS:", _len ) GET _pos PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "MAT:", _len ) GET _mat PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "RNAL:", _len ) GET _rnal PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "KADEV:", _len ) GET _kadev PICT "@!"
	@ m_x + _x, col() + 1 SAY PADL( "REPORTS:", _len ) GET _reports PICT "@!"

    // 10

    ++ _x
    ++ _x
	@ m_x + _x, m_y + 2 SAY "Odabir korektan (D/N) ?" GET _corr VALID _corr $ "DN" PICT "@!"

    read

BoxC()

if LastKey() == K_ESC .or. _corr == "N"
    return _ok
endif

// snimi parametre...
set_metric( "main_menu_fin", my_user(), _fin )
set_metric( "main_menu_kalk", my_user(), _kalk )
set_metric( "main_menu_fakt", my_user(), _fakt )
set_metric( "main_menu_ld", my_user(), _ld )
set_metric( "main_menu_virm", my_user(), _virm )
set_metric( "main_menu_os", my_user(), _os )
set_metric( "main_menu_epdv", my_user(), _epdv )
set_metric( "main_menu_rnal", my_user(), _rnal )
set_metric( "main_menu_mat", my_user(), _mat )
set_metric( "main_menu_pos", my_user(), _pos )
set_metric( "main_menu_kadev", my_user(), _kadev )
set_metric( "main_menu_reports", my_user(), _reports )

return _ok






