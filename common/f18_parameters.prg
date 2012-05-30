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
local _oo_bin, _oo_writer_exe, _oo_calc_exe
local _java_bin, _java_start
local _jod_bin, _jod_templates, _jod_convert_bin
local _x := 1
local _pos_x
local _pos_y
local _left := 20
local _modules := hb_hash()

// fetch parametara
#IFDEF __PLATFORM__WINDOWS
	_oo_bin := fetch_metric( "openoffice_bin", my_user(), PADR( "", 200 ) )
	_oo_writer_exe := fetch_metric( "openoffice_writer", my_user(), PADR( "swriter", 100 ) )
	_oo_calc_exe := fetch_metric( "openoffice_calc", my_user(), PADR( "scalc", 100 ) )
	_java_bin := fetch_metric( "java_bin", my_user(), PADR("", 200) )
	_java_start := fetch_metric( "java_start_cmd", my_user(), PADR( "java -Xmx128m -jar", 200 ) )
	_jod_bin := fetch_metric( "jodreports_bin", my_user(), PADR( "c:\knowhowERP\util\jodreports-cli.jar", 200 ) )
	_jod_convert_bin := fetch_metric( "jodconverter_bin", my_user(), PADR( "c:\knowhowERP\util\jodconverter-cli.jar", 200 ) )
	_jod_templates := fetch_metric( "jodreports_templates", my_user(), PADR( "", 200 ) )
#ELSE
	_oo_bin := fetch_metric( "openoffice_bin", my_user(), PADR( "", 200 ) )
	_oo_writer_exe := fetch_metric( "openoffice_writer", my_user(), PADR( "", 100 ) )
	_oo_calc_exe := fetch_metric( "openoffice_calc", my_user(), PADR( "", 100 ) )
	_java_bin := fetch_metric( "java_bin", my_user(), PADR("", 200) )
	_java_start := fetch_metric( "java_start_cmd", my_user(), PADR( "java -Xmx128m -jar", 200 ) )
	_jod_bin := fetch_metric( "jodreports_bin", my_user(), PADR( "/opt/knowhowERP/util/jodreports-cli.jar", 200 ) )
	_jod_convert_bin := fetch_metric( "jodconverter_bin", my_user(), PADR( "/opt/knowhowERP/util/jodconverter-cli.jar", 200 ) )
	_jod_templates := fetch_metric( "jodreports_templates", my_user(), PADR( "", 200 ) )
#ENDIF

// parametri modula koristenih na glavnom meniju...
_modules["fin"] := fetch_metric( "main_menu_fin", my_user(), "D" )
_modules["kalk"] := fetch_metric( "main_menu_kalk", my_user(), "D" )
_modules["fakt"] := fetch_metric( "main_menu_fakt", my_user(), "D" )
_modules["ld"] := fetch_metric( "main_menu_ld", my_user(), "D" )
_modules["epdv"] := fetch_metric( "main_menu_epdv", my_user(), "D" )
_modules["virm"] := fetch_metric( "main_menu_virm", my_user(), "D" )
_modules["os"] := fetch_metric( "main_menu_os", my_user(), "D" )
_modules["rnal"] := fetch_metric( "main_menu_rnal", my_user(), "N" )
_modules["mat"] := fetch_metric( "main_menu_mat", my_user(), "N" )
_modules["pos"] := fetch_metric( "main_menu_pos", my_user(), "N" )

if just_set == nil
	just_set := .f.
endif

if !just_set

	clear screen

	?

	_pos_x := 2
	_pos_y := 3

	@ _pos_x, _pos_y SAY "Odabir modula za glavni menij ***" COLOR "I"

	@ _pos_x + _x, _pos_y SAY SPACE(2) + "FIN:" GET _modules["fin"] PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "KALK:" GET _modules["kalk"] PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "FAKT:" GET _modules["fakt"] PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "ePDV:" GET _modules["epdv"] PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "LD:" GET _modules["ld"] PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "VIRM:" GET _modules["virm"] PICT "@!"
	
	++ _x
	@ _pos_x + _x, _pos_y SAY SPACE(2) + "OS/SII:" GET _modules["os"] PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "POS:" GET _modules["pos"] PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "MAT:" GET _modules["mat"] PICT "@!"
	@ _pos_x + _x, col() + 1 SAY "RNAL:" GET _modules["rnal"] PICT "@!"

	++ _x
	++ _x

	@ _pos_x + _x, _pos_y SAY "Java parametri ***" COLOR "I"
	++ _x
	@ _pos_x + _x, _pos_y SAY PADL( "Java bin:", _left ) GET _java_bin PICT "@S100"
	++ _x
	@ _pos_x + _x, _pos_y SAY PADL( "Java start cmd:", _left ) GET _java_start PICT "@S100"
 
	++ _x
	++ _x

	@ _pos_x + _x, _pos_y SAY "JodReports parametri ***" COLOR "I"
	++ _x
	@ _pos_x + _x, _pos_y SAY PADL( "JodReports lokacija:", _left ) GET _jod_bin PICT "@S100"
	++ _x
	@ _pos_x + _x, _pos_y SAY PADL( "JodConverter lokacija:", _left ) GET _jod_convert_bin PICT "@S100"
 
	read

	if LastKey() == K_ESC
    	return
	endif

endif


// snimi parametre u sql/db
set_metric( "openoffice_bin", my_user(), _oo_bin )
set_metric( "openoffice_writer", my_user(), _oo_writer_exe )
set_metric( "openoffice_calc", my_user(), _oo_calc_exe )
set_metric( "java_bin", my_user(), _java_bin )
set_metric( "java_start_cmd", my_user(), _java_start )
set_metric( "jodreports_bin", my_user(), _jod_bin )
set_metric( "jodconverter_bin", my_user(), _jod_convert_bin )
set_metric( "jodreports_templates", my_user(), _jod_templates )

// parametri modula...
set_metric( "main_menu_fin", my_user(), _modules["fin"] )
set_metric( "main_menu_kalk", my_user(), _modules["kalk"] )
set_metric( "main_menu_fakt", my_user(), _modules["fakt"] )
set_metric( "main_menu_ld", my_user(), _modules["ld"] )
set_metric( "main_menu_virm", my_user(), _modules["virm"] )
set_metric( "main_menu_os", my_user(), _modules["os"] )
set_metric( "main_menu_epdv", my_user(), _modules["epdv"] )
set_metric( "main_menu_rnal", my_user(), _modules["rnal"] )
set_metric( "main_menu_mat", my_user(), _modules["mat"] )
set_metric( "main_menu_pos", my_user(), _modules["pos"] )


return


// ---------------------------------------------------------------------
// koristi se pojedini od modula na osnovu parametara
// ---------------------------------------------------------------------
function f18_use_module( module_name )
local _ret := .f.

if fetch_metric( "main_menu_" + module_name, my_user(), "D" ) == "D"
	_ret := .t.
endif

return _ret



