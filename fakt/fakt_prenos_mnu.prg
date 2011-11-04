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


#include "fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */
 

/*! \file fmk/fakt/razdb/1g/mnu_raz.prg
 *  \brief Centralni meni opcija za prenos podataka FAKT<->ostali moduli
 */


/*! \fn ModRazmjena()
 *  \brief Centralni meni opcija za prenos podataka FAKT<->ostali moduli
 */

function ModRazmjena()
*{
private Opc:={}
private opcexe:={}

AADD(opc,"1. kalk <-> fakt                  ")
AADD(opcexe,{|| KaFak()})
AADD(opc,"2. kalk->fakt (modem)")
AADD(opcexe,{|| PovModem()})
AADD(opc,"3. import barkod terminal")
AADD(opcexe,{|| imp_bterm()})
AADD(opc,"4. export barkod terminal")
AADD(opcexe,{|| exp_bterm()})


private Izbor:=1
Menu_SC("rpod")

CLOSERET

return
*}
