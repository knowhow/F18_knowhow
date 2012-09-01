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


#include "fmk.ch"

function f18_start_print(f_name, print_opt, document_name)

if print_opt == NIL
    print_opt := "V"
endif

set_print_f_name(@f_name)

read_printer_params()

PtxtSekvence()

if (document_name == nil)
    document_name :=  gModul + '_' + DTOC(DATE()) 
endif

if print_opt != "D"

    // D - dummy
    // vraca prazan string u slucaju <ESC>
    print_opt := print_dialog_box( print_opt )

endif

if EMPTY( print_opt ) 
    return ""
endif

// setuj print kodove
set_print_codes( print_opt )

private GetList := {}

MsgO("Priprema izvjestaja...")

setprc(0, 0)
set console off
	
set printer off
set device to printer

set printer to (f_name)
set printer on

GpIni( document_name )

return print_opt


// --------------------------------------------------------
// setuje ispravne print kodove kod stampe dokumenta
// --------------------------------------------------------
static function set_print_codes( print_opt )

do case

    case print_opt $ "E#F#G"

        gPrinter := "E"
        set_epson_print_codes()

    otherwise

        gPrinter := "R"
        PtxtSekvence()

endcase

return



// ----------------------------------------
// ----------------------------------------
function f18_end_print( f_name, print_opt )
local _cmd := ""
local _port := get_printer_port( print_opt )

if print_opt == NIL
    print_opt := "V"
endif

set_print_f_name( @f_name )

SET DEVICE TO SCREEN
set printer off
set printer to
set console on

Tone(440, 2)
Tone(440, 2)

MsgC()

DO CASE
    
    CASE print_opt == "D"
        // dummy ne printaj nista

    CASE print_opt $ "E#F#G"

        // printanje direktno na lpt port
        // sa epson kodovima

        #ifdef __PLATFORM__WINDOWS
            direct_print_windows( f_name, _port )
        #else
            direct_print_unix( f_name, _port )        
        #endif

    OTHERWISE

        // TODO: treba li f18_editor parametrizirati ?!   
        _cmd := "f18_editor " + f_name

        // #27234
        #ifdef __PLATFORM__UNIX
            close all
        #endif

// u test rezimu se ne pokrece editor
#ifndef TEST
        hb_run (_cmd) 
#endif

END CASE

return

// ----------------------------------------------
// vraca port na koji ce se stampati
// ----------------------------------------------
static function get_printer_port( print_opt )
local _port := "1"

do case
    case print_opt == "E"
        _port := "1"
    case print_opt == "F"
        _port := "2"
    case print_opt == "G"
        _port := "3"
endcase

return _port

// --------------------------------------------------------------
// direktna stampa na unix-u
// --------------------------------------------------------------
static function direct_print_unix( f_name, port_number )
local _cmd
local _printer := "epson"
local _printer_name
local _err
            
if port_number == NIL
    port_number := "1"
endif

_printer_name := _printer + "_" + port_number

// ispitaj da li printer postoji
// lpq -P epson_1 | grep epson_1 
_cmd := "lpq -P " + _printer_name + " | grep " + _printer_name

_err := hb_run( _cmd )
if _err <> 0
    MsgBeep( "Printer " + _printer_name + " nije podesen !!!" )
    return
endif

// stampaj
_cmd := "lpr -P " 
_cmd += _printer_name + " "
_cmd += f_name

_err := hb_run( _cmd )

if _err <> 0
    MsgBeep( "Greska sa direktnom stampom !!!" )
endif

return


// --------------------------------------------------------------
// direktna stampa na windows-u
// --------------------------------------------------------------
static function direct_print_windows( f_name, port_number )
local _cmd
local _err
            
if port_number == NIL
    port_number := "1"
endif

_cmd := "copy " + f_name + " > LPT" + port_number 

_err := hb_run( _cmd )

if _err <> 0
    MsgBeep( "Greska sa direktnom stampom !!!" )
endif

return


static function set_print_f_name(f_name)

if f_name == NIL
    f_name := OUTF_FILE

    // jos nije setovan my_home()
    if my_home() == NIL
        f_name := my_home_root() + f_name
    else
        f_name := my_home() + f_name
    endif
endif

return f_name



// -----------------------------------------------------------
// procitaj parametre za stampac
// -----------------------------------------------------------
static function read_printer_params()
// read params
gPStranica := fetch_metric( "print_dodatni_redovi_po_stranici", nil, 0 )

return


// ----------------------------------------
// izbaci ini seqvencu za printer
//  * posalji i docname 
// ----------------------------------------
function GpIni( document_name )

if document_name == nil .or. gPrinter <> "R"
    document_name := ""
endif

Setpxlat()

QQOUT( gPini )

if !EMPTY(document_name)
    QQOUT( "#%DOCNA#" + document_name )
endif

return 


// ----------------------------------------
// pic header
// ----------------------------------------
function gpPicH( nRows )
local cPom

if nRows == nil
	nRows := 7
endif

if nRows > 0
	cPom := PADL( ALLTRIM(STR(nRows)), 2, "0" )
	Setpxlat()
	qqout("#%PH0" + cPom + "#")
	konvtable(.t.)
endif

return ""


// ----------------------------------------
// pic footer
// ----------------------------------------
function gpPicF()
qqout("#%PIC_F#")
return ""


// ----------------------------------------
// ---------------------------------------
function gpCOND()
qqout(gpCOND)

return ""

// ----------------------------------------
// ---------------------------------------
function gpCOND2()
qqout(gpCOND2)
return ""

// ----------------------------------------
// ---------------------------------------
function gp10CPI()
qqout(gP10CPI)
return ""

// ----------------------------------------
// ---------------------------------------
function gp12CPI()
qqout(gP12CPI)
return ""

// ----------------------------------------
// ---------------------------------------
function gpB_ON()
qqout(gPB_ON)
return ""


// ----------------------------------------
// ---------------------------------------
function gpB_OFF()
qqout(gPB_OFF)
return ""


// ----------------------------------------
// ---------------------------------------
function gpU_ON()
qqout(gPU_ON)
return ""


// ----------------------------------------
// ---------------------------------------
function gpU_OFF()
qqout(gPU_OFF)
return ""


// ----------------------------------------
// ---------------------------------------
function gpI_ON()
qqout(gPI_ON)
return ""


// ----------------------------------------
// ---------------------------------------
function gpI_OFF()
qqout(gPI_OFF)
return ""


// ----------------------------------------
// ---------------------------------------
function gpReset()
qqout(gPReset)
return ""


// ----------------------------------------
// ---------------------------------------
function gpNR()
qout()
return ""


// ----------------------------------------
// ---------------------------------------
function gPFF()
qqout( hb_eol() + gPFF)
setprc(0,0)
return ""


// ----------------------------------------
// ---------------------------------------
function gpO_Port()
qqout(gPO_Port)
return ""


// ----------------------------------------
// ---------------------------------------
function gpO_Land()
qqout(gPO_Land)
return ""


// ----------------------------------------
// ---------------------------------------
function gRPL_Normal()
Setpxlat()
qqout(gRPL_Normal)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gRPL_Gusto()
Setpxlat()
qqout(gRPL_Gusto)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function RPar_Printer()
RPAR("01",@gPINI)
RPAR("02",@gPCOND)
RPAR("03",@gPCOND2)
RPAR("04",@gP10CPI)
RPAR("05",@gP12CPI)
RPAR("06",@gPB_ON)
RPAR("07",@gPB_OFF)
RPAR("08",@gPI_ON)
RPAR("09",@gPI_OFF)
RPAR("10",@gPRESET)
RPAR("11",@gPFF)
RPAR("12",@gPU_ON)
RPAR("13",@gPU_OFF)
RPAR("14",@gPO_Port)
RPAR("15",@gPO_Land)
RPAR("16",@gRPL_Normal)
RPAR("17",@gRPL_Gusto)
RPAR("PP",@gPPort)
if empty(gPPort)
	gPPort:="1"
endif
RPar("r-",@gPStranica)
RPar("pt",@gPPTK)
return


// ----------------------------------------
// ---------------------------------------
function WPar_Printer()
WPAR("01",gPINI)
WPAR("02",gPCOND)
WPAR("03",gPCOND2)
WPAR("04",gP10CPI)
WPAR("05",gP12CPI)
WPAR("06",gPB_ON)
WPAR("07",gPB_OFF)
WPAR("08",gPI_ON)
WPAR("09",gPI_OFF)
WPAR("10",gPRESET)
WPAR("11",gPFF)
WPAR("12",gPU_ON)
WPAR("13",gPU_OFF)
WPAR("14",gPO_Port)
WPAR("15",gPO_Land)
WPAR("16",gRPL_Normal)
WPAR("17",gRPL_Gusto)
WPAR("PP",gPPort)
WPar("r-",gPStranica)
WPar("pt",gPPTK)
return



// ------------------------------------------
// incijalizacija print varijabli
// ------------------------------------------
function init_print_variables()
public gPIni := ""
public gPCond
public gPCond2
public gP10CPI
public gP12CPI
public gPB_ON
public gPB_OFF
public gPI_ON
public gPI_OFF
public gPU_ON
public gPU_OFF
public gPPort := "1"
public gPStranica := 0
public gPPTK
public gPO_Port 
public gPO_Land 
public gRPL_Normal
public gRPL_Gusto
public gPReset := ""
public gPFF
return



// ----------------------------------------------------------------------------
// Inicijaliziraj globalne varijable za Epson stampace (matricne) ESC/P2
// ----------------------------------------------------------------------------
function set_epson_print_codes()
gPIni := ""
gPCond := "P"
gPCond2 := "M"
gP10CPI := "P"
gP12CPI := "M"
gPB_ON := "G"
gPB_OFF := "H"
gPI_ON := "4"
gPI_OFF := "5"
gPU_ON := "-1"
gPU_OFF := "-0"
gPPort := "1"
gPStranica := 0
gPPTK := "  "
gPO_Port := ""
gPO_Land := ""
gRPL_Normal := "0"
gRPL_Gusto := "3" + CHR(24)
gPReset := ""
gPFF := Chr(12)  
return


// ----------------------------------------
// ---------------------------------------
function InigHP()
public gPINI := Chr(27)+"(17U(s4099T&l66F"
public gPCond := Chr(27)+"(s4102T(s18H"
public gPCond2 := Chr(27)+"(s4102T(s22H"
public gP10CPI := Chr(27)+"(s4099T(s10H"
public gP12CPI := Chr(27)+"(s4099T(s12H"
public gPB_ON := Chr(27)+"(s3B"
public gPB_OFF := Chr(27)+"(s0B"
public gPI_ON := Chr(27)+"(s1S"
public gPI_OFF := Chr(27)+"(s0S"
public gPU_ON := Chr(27)+"&d0D"
public gPU_OFF := Chr(27)+"&d@"
public gPRESET := ""
public gPFF := CHR(12)
public gPO_Port := "&l0O"
public gPO_Land := "&l1O"
public gRPL_Normal := "&l6D&a3L"
public gRPL_Gusto := "&l8D(s12H&a6L"
return


// ----------------------------------------
// ---------------------------------------
function All_GetPstr()
gPINI       := GetPStr( gPINI   )
gPCond      := GetPStr( gPCond  )
gPCond2     := GetPStr( gPCond2 )
gP10cpi     := GetPStr( gP10CPI )
gP12cpi     := GetPStr( gP12CPI )
gPB_ON      := GetPStr( gPB_ON   )
gPB_OFF     := GetPStr( gPB_OFF  )
gPI_ON      := GetPStr( gPI_ON   )
gPI_OFF     := GetPStr( gPI_OFF  )
gPU_ON      := GetPStr( gPU_ON   )
gPU_OFF     := GetPStr( gPU_OFF  )
gPRESET     := GetPStr( gPRESET )
gPFF        := GetPStr( gPFF    )
gPO_Port    := GetPStr( gPO_Port    )
gPO_Land    := GetPStr( gPO_Land    )
gRPL_Normal := GetPStr( gRPL_Normal )
gRPL_Gusto  := GetPStr( gRPL_Gusto  )
return


// ----------------------------------------
// ----------------------------------------
function SetGParams(cs ,ch ,cid ,cvar     ,cval)
local cPosebno:="N"
private GetList:={}

PushWa()
 
private cSection := cs
private cHistory := ch
private aHistory := {}

// ----------------------------------------------------------
// TODO: cPosebno vazi samo za cSection "1" i cHistory " " ?!
// ----------------------------------------------------------
select (F_PARAMS)
USE
O_PARAMS
RPar("p?",@cPosebno)
select params
use
 
if cPosebno=="D" .and. !file( my_home() + "gparams.dbf" )
    cScr := ""
    save screen to cscr
    CopySve( "gpara*.*", SLASH, my_home() )
    restore screen from cScr
endif
 
if cPosebno=="D"
    select (F_GPARAMSP)
    use
    O_GPARAMSP
else
    select (F_GPARAMS)
    use
    O_GPARAMS
endif
 
&cVar:=cVal
Wpar(cId,&cVar)
KonvTable()
select gparams
use
PopWa()
return


