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

 
function SifFmkRoba()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc,"1. roba                               ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","ROBAOPEN"))
    AADD( _opcexe, {|| P_Roba()})
else
    AADD( _opcexe, {|| MsgBeep(F18_SECUR_WARRNING)})
endif

AADD( _opc,"2. tarife")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","TARIFAOPEN"))
    AADD( _opcexe, {|| P_Tarifa()})
else
    AADD( _opcexe, {|| MsgBeep(F18_SECUR_WARRNING)})
endif

AADD( _opc,"3. konta - tipovi cijena")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","KONC1OPEN"))
    AADD( _opcexe, {|| P_Koncij()} )
else
    AADD( _opcexe, {|| MsgBeep(F18_SECUR_WARRNING)})
endif

AADD( _opc,"4. konta - atributi / 2 ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","KONC2OPEN"))
    AADD( _opcexe, {|| P_Koncij2()} )
else
    AADD( _opcexe, {|| MsgBeep(F18_SECUR_WARRNING)})
endif

AADD( _opc,"5. trfp - sheme kontiranja u fin")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","TRFPOPEN"))
    AADD( _opcexe, {|| P_TrFP()} )
else
    AADD( _opcexe, {|| MsgBeep(F18_SECUR_WARRNING)})
endif

AADD( _opc,"6. sastavnice")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SASTOPEN"))
    AADD( _opcexe, {|| P_Sast()} )
else
    AADD( _opcexe, {|| MsgBeep(F18_SECUR_WARRNING) })
endif

AADD( _opc,"8. sifk - karakteristike")  
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SIFKOPEN"))
    AADD( _opcexe, {|| P_SifK()} )
else
    AADD( _opcexe, {|| MsgBeep(F18_SECUR_WARRNING)})
endif

AADD( _opc,"9. strings - karakteristike ")  
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","STROPEN"))
    AADD( _opcexe, {|| p_strings()} )
else
    AADD( _opcexe, {|| MsgBeep(F18_SECUR_WARRNING)})
endif

my_close_all_dbf()
OFmkRoba()

f18_menu( "srob", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return

