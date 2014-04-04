/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

static __table := "r_export"
static cij_decimala:=3
static izn_decimala:=2
static kol_decimala:=3
static lZaokruziti := .t.
static cLauncher1 := '"C:\Program Files\LibreOffice 3.4\program\scalc.exe"'
// zamjeniti tarabu sa brojem
static cLauncher2 := ""
static cLauncher := "oo"
// 4 : 852 => US ASCII
static cKonverzija := "4"



// kreiraj tabelu u home direktoriju
function t_exp_create( field_list )

my_close_all_dbf()

ferase( my_home() + __table + ".dbf" )

// kreiraj tabelu
dbcreate2( my_home() + __table, field_list )

return


// export tabele
function tbl_export( launch )
local _cmd

my_close_all_dbf()

_cmd := ALLTRIM( launch )
_cmd += " "
_cmd += __table + ".dbf"

log_write( "Export " + __table + " cmd: " + _cmd, 9 )

MsgBeep("Tabela " + my_home() + __table + ".dbf" + "je formirana##" +;
        "Sa opcijom Open file se ova tabela ubacuje u excel #" +;
    "Nakon importa uradite Save as, i odaberite format fajla XLS ! ##" +;
    "Tako dobijeni xls fajl mozete mijenjati #"+;
    "prema svojim potrebama ...")
    
if Pitanje(, "Odmah pokrenuti spreadsheet aplikaciju ?", "D") == "D"    
    DirChange( my_home() )
    if f18_run( _cmd ) <> 0
        MsgBeep( "Problem sa pokretanjem ?!!!" )
    endif
endif

return


// -----------------------------------------------------
// setovanje pokretaca za dbf tabelu
// -----------------------------------------------------
function set_launcher( launch )
local _tmp

_tmp = UPPER(ALLTRIM( launch ))

if ( _tmp == "OO" ) .or.  ( _tmp == "OOO" ) .or.  ( _tmp == "OPENOFFICE" )
	launch := cLauncher1
    return .f.
    
elseif ( LEFT( _tmp, 6 ) == "OFFICE" )
    // OFFICEXP, OFFICE97, OFFICE2003
    launch := msoff_start( SUBSTR( _tmp, 7 ))
    return .f.
elseif (LEFT( _tmp, 5 ) == "EXCEL") 
    // EXCELXP, EXCEL97 
    launch := msoff_start(SUBSTR( _tmp, 6))
    return .f.
endif

return .t.




static function msoff_start( ver )
local _tmp :=  '"C:\Program Files\Microsoft Office\Office#\excel.exe"'

if (ver == "XP")
  // office XP
  return STRTRAN(_tmp,  "#", "10")
elseif (ver == "2000")
  // office 2000
  return STRTRAN(_tmp, "#", "9")
elseif (EMPTY(ver))
  // instalacija office u /office/ direktoriju
  return STRTRAN(_tmp, "#", "")
elseif (ver == "2003")
  // office 2003
  return STRTRAN(_tmp, "#", "11")
elseif (ver == "97")
  // office 97
  return STRTRAN(_tmp, "#", "8")
else
  // office najnoviji 2005?2006
  return STRTRAN(_tmp, "#", "12")
endif

return




// export funkcija
function exp_report()
local nTArea := SELECT()

cKonverzija := fetch_metric("export_dbf_konverzija", my_user(), cKonverzija)
cLauncher := fetch_metric("export_dbf_launcher", my_user(), cLauncher)
cLauncher := PADR(cLauncher, 70)

Box(, 10, 70)
    @ m_x+1, m_y+2 SAY "Parametri exporta:" COLOR "I"
    
    @ m_x+2, m_y+2  SAY "Konverzija slova (0-8) " GET cKonverzija PICT "9"
    
    @ m_x+3, m_y+2 SAY "Pokreni oo/office97/officexp/office2003 ?" GET cLauncher PICT "@S26" VALID set_launcher(@cLauncher)
  
    read
BoxC()

if LastKey()==K_ESC
    select (nTArea)
    closeret
endif

// snimi parametre
set_metric("export_dbf_konverzija", my_user(), cKonverzija)
set_metric("export_dbf_launcher", my_user(), cLauncher)

select (nTArea)
return cLauncher


