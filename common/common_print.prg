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

PtxtSekvence()

if (document_name == nil)
  document_name :=  gModul + '_' + DTOC(DATE()) 
endif

// vraca prazan string u slucaju <ESC>
print_opt :=IzlazPrn(print_opt)

if empty(print_opt) 
   return ""
endif

private GetList:={}

MsgO("Priprema izvjestaja...")

setprc(0, 0)
set console off
	
set printer off
set device to printer

set printer to (f_name)
set printer on
GpIni(document_name)

return print_opt

// ----------------------------------------
// ----------------------------------------
function f18_end_print(f_name, print_opt)

local _cmd

if print_opt == NIL
   print_opt := "V"
endif

set_print_f_name(@f_name)

SET DEVICE TO SCREEN
set printer off
set printer to
set console on

Tone(440, 2)
Tone(440, 2)

MsgC()

DO CASE

   CASE print_opt == "R" 
      // TODO: proslijediti ptxt switch-eve
	  Ptxt(f_name)
	
   OTHERWISE
       // TODO: treba li f18_editor parametrizirati ?!   
       _cmd := "f18_editor " + f_name
       run (_cmd) 

END CASE

return

static function set_print_f_name(f_name)

    if f_name == NIL
       f_name := "outf.txt"

        // jos nije setovan my_home()
        if my_home() == NIL
           f_name := my_home_root() + f_name
        else
           f_name := my_home() + f_name
        endif
    endif
return f_name



// ----------------------------------------
// izbaci ini seqvencu za printer
//  * posalji i docname 
// ----------------------------------------
function GpIni(document_name)

if document_name == nil .or. gPrinter<>"R"
 document_name := ""
endif

Setpxlat()

QQOUT(gPini)

if !empty(document_name)
 qqout("#%DOCNA#" + document_name)
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
Setpxlat()
qqout("#%PIC_F#")
konvtable(.t.)
return ""


// ----------------------------------------
// ---------------------------------------
function gpCOND()
Setpxlat()
qqout(gpCOND)
konvtable(iif(gPrinter="R",.t.,NIL))

return ""

// ----------------------------------------
// ---------------------------------------
function gpCOND2()
Setpxlat()
qqout(gpCOND2)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""

// ----------------------------------------
// ---------------------------------------
function gp10CPI()
Setpxlat()
qqout(gP10CPI)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""

// ----------------------------------------
// ---------------------------------------
function gp12CPI()
Setpxlat()
qqout(gP12CPI)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""

// ----------------------------------------
// ---------------------------------------
function gpB_ON()

Setpxlat()
qqout(gPB_ON)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gpB_OFF()

Setpxlat()
qqout(gPB_OFF)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gpU_ON()

Setpxlat()
qqout(gPU_ON)
konvtable( iif(gPrinter="R",.t.,NIL) )
return ""


// ----------------------------------------
// ---------------------------------------
function gpU_OFF()

Setpxlat()
qqout(gPU_OFF)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gpI_ON()

Setpxlat()
qqout(gPI_ON)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gpI_OFF()

Setpxlat()
qqout(gPI_OFF)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gpReset()

Setpxlat()
qqout(gPReset)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gpNR()

Setpxlat()
qout()
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gPFF()

Setpxlat()
qqout( hb_eol() + gPFF)
setprc(0,0)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gpO_Port()

Setpxlat()
qqout(gPO_Port)
konvtable(iif(gPrinter="R",.t.,NIL))
return ""


// ----------------------------------------
// ---------------------------------------
function gpO_Land()

Setpxlat()
qqout(gPO_Land)
konvtable(iif(gPrinter="R",.t.,NIL))
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
function CurToExtBase(ccExt)
 
LOCAL nArr:=SELECT()
  PRIVATE cFilter:=DBFILTER()
  copy structure extended to struct
  SELECT 0
  create ("TEMP") from struct
  IF !EMPTY(cFilter)
    APPEND FROM (ALIAS(nArr)) FOR &cFilter
  ELSE
    APPEND FROM (ALIAS(nArr))
  ENDIF
  USE
  COPY FILE ("TEMP.DBF") TO (ccExt)
 SELECT (nArr)
return


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



/*! \fn InigEpson()
 *  \brief Inicijaliziraj globalne varijable za Epson stampace (matricne) ESC/P2
 */
function InigEpson()
public gPIni:=""
public gPCond:="P"
public gPCond2:="M"
public gP10CPI:="P"
public gP12CPI:="M"
public gPB_ON:="G"
public gPB_OFF:="H"
public gPI_ON:="4"
public gPI_OFF:="5"
public gPU_ON:="-1"
public gPU_OFF:="-0"
public gPPort:="1"
public gPStranica:=0
public gPPTK:="  "
public gPO_Port:=""
public gPO_Land:=""
public gRPL_Normal := "0"
public gRPL_Gusto  := "3"+CHR(24)
public gPReset:=""
public gPFF:=Chr(12)
  
return


// ----------------------------------------
// ---------------------------------------
function InigHP()
public gPINI:=  Chr(27)+"(17U(s4099T&l66F"
public gPCond:= Chr(27)+"(s4102T(s18H"
public gPCond2:=Chr(27)+"(s4102T(s22H"
public gP10CPI:=Chr(27)+"(s4099T(s10H"
public gP12CPI:=Chr(27)+"(s4099T(s12H"
public gPB_ON:= Chr(27)+"(s3B"
public gPB_OFF:=Chr(27)+"(s0B"
public gPI_ON:=Chr(27)+"(s1S"
public gPI_OFF:=Chr(27)+"(s0S"
public gPU_ON:=Chr(27)+"&d0D"
public gPU_OFF:=Chr(27)+"&d@"

public gPRESET:=""
public gPFF:=CHR(12)

public gPO_Port:= "&l0O"
public gPO_Land:= "&l1O"
public gRPL_Normal:="&l6D&a3L"
public gRPL_Gusto :="&l8D(s12H&a6L"

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
 private cSection:=cs, cHistory:=ch; aHistory:={}
 // ----------------------------------------------------------
 // TODO: cPosebno vazi samo za cSection "1" i cHistory " " ?!
 // ----------------------------------------------------------
 select (F_PARAMS);USE
 O_PARAMS
 RPar("p?",@cPosebno)
 select params; use
 if cPosebno=="D" .and. !file(PRIVPATH+"gparams.dbf")
   cScr:=""; save screen to cscr
   CopySve("gpara*.*",SLASH,PRIVPATH); restore screen from cScr
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
