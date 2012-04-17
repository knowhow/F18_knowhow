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
function f18_app_parameters()
local _oo_bin, _oo_writer_exe, _oo_calc_exe
local _java_bin, _java_start
local _jod_bin, _jod_templates
local _x := 1
local _pos_x
local _pos_y
local _left := 20

// fetch parametara
#IFDEF __PLATFORM__WINDOWS
_oo_bin := fetch_metric( "openoffice_bin", my_user(), PADR( "c:\program files\libreoffice 3.4\program", 200 ) )
_oo_writer_exe := fetch_metric( "openoffice_writer", my_user(), PADR( "swriter", 100 ) )
_oo_calc_exe := fetch_metric( "openoffice_calc", my_user(), PADR( "scalc", 100 ) )
_java_bin := fetch_metric( "java_bin", my_user(), PADR("", 200) )
_java_start := fetch_metric( "java_start_cmd", my_user(), PADR( "java -Xmx128m -jar", 200 ) )
_jod_bin := fetch_metric( "jodreports_bin", my_user(), PADR( "c:\knowhowERP\util\jodreports-cli.jar", 200 ) )
_jod_templates := fetch_metric( "jodreports_templates", my_user(), PADR( "", 200 ) )
#ELSE
_oo_bin := fetch_metric( "openoffice_bin", my_user(), PADR( "/Applications/LibreOffice.app/Contents/MacOS/", 200 ) )
_oo_writer_exe := fetch_metric( "openoffice_writer", my_user(), PADR( "swriter", 100 ) )
_oo_calc_exe := fetch_metric( "openoffice_calc", my_user(), PADR( "scalc", 100 ) )
_java_bin := fetch_metric( "java_bin", my_user(), PADR("", 200) )
_java_start := fetch_metric( "java_start_cmd", my_user(), PADR( "java -Xmx128m -jar", 200 ) )
_jod_bin := fetch_metric( "jodreports_bin", my_user(), PADR( "/opt/knowhowERP/util/jodreports-cli.jar", 200 ) )
_jod_templates := fetch_metric( "jodreports_templates", my_user(), PADR( "", 200 ) )
#ENDIF

clear screen

?

_pos_x := 2
_pos_y := 3

// open office parametri
@ _pos_x, _pos_y SAY "OpenOffice parametri ***" COLOR "I"
@ _pos_x + _x, _pos_y SAY PADL( "bin direktorij:", _left )  GET _oo_bin PICT "@S100"
++ _x
@ _pos_x + _x, _pos_y SAY PADL( "writer aplikacija:", _left )  GET _oo_writer_exe PICT "@S100"
++ _x
@ _pos_x + _x, _pos_y SAY PADL( "calc aplikcija:", _left ) GET _oo_calc_exe PICT "@S100"

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
@ _pos_x + _x, _pos_y SAY PADL( "template lokacije:", _left ) GET _jod_templates PICT "@S100"
 
read

IF LastKey() == K_ESC
    return
ENDIF

// snimi parametre u sql/db
set_metric( "openoffice_bin", my_user(), _oo_bin )
set_metric( "openoffice_writer", my_user(), _oo_writer_exe )
set_metric( "openoffice_calc", my_user(), _oo_calc_exe )
set_metric( "java_bin", my_user(), _java_bin )
set_metric( "java_start_cmd", my_user(), _java_start )
set_metric( "jodreports_bin", my_user(), _jod_bin )
set_metric( "jodreports_templates", my_user(), _jod_templates )

return


