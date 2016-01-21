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


#include "f18.ch"



function kalk_mnu_generacija_dokumenta()
local _Opc:={}
local _opcexe:={}
local _Izbor:=1

AADD(_opc,"1. magacin - generacija dokumenata    ")
AADD(_opcexe, {|| GenMag()})
AADD(_opc,"2. prodavnica - generacija dokumenata")
AADD(_opcexe, {|| GenProd()})
AADD(_opc,"3. proizvodnja - generacija dokumenata")
AADD(_opcexe, {|| GenProizvodnja()})
AADD(_opc,"4. storno dokument")
AADD(_opcexe, {|| storno_kalk_dokument()})

f18_menu( "mgend", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return


