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


#include "kalk.ch"



function MGenDoks()
*{
private Opc:={}
private opcexe:={}
AADD(opc,"1. magacin - generacija dokumenata    ")
AADD(opcexe, {|| GenMag()})
AADD(opc,"2. prodavnica - generacija dokumenata")
AADD(opcexe, {|| GenProd()})
AADD(opc,"3. proizvodnja - generacija dokumenata")
AADD(opcexe, {|| GenProizvodnja()})
AADD(opc,"4. storno dokument")
AADD(opcexe, {|| StornoDok()})
private Izbor:=1
Menu_SC("mgend")
CLOSERET
return
*}
