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


 
function VTPOREZI()
public _ZPP:=0
public _OPP:=tarifa->opp/100
public _PPP:=tarifa->ppp/100
public _ZPP:=tarifa->zpp/100
public _PORVT := 0
public _MPP   := 0
public _DLRUC := 0

if !IsPdv()

    if tarifa->(FIELDPOS("MPP")<>0)
	    public _MPP   := tarifa->mpp/100
	    public _DLRUC := tarifa->dlRuc/100
    else
	    public _MPP   := 0
	    public _DLRUC := 0
    endif

endif

return


function SetStPor_()
public _ZPP:=0

// ovo je stopa PDV-a
public _PDV:=tarifa->opp/100
// posebni porez na potrosnju
public _PP:=tarifa->zpp/100

//ovo dole se ne koristi ali ako negdje trazi ove stare varijable ostaviti
public _OPP:=tarifa->opp/100
public _PPP:=tarifa->ppp/100
public _ZPP:=tarifa->zpp/100
public _PORVT :=0
public _MPP   := 0
public _DLRUC := 0

return


