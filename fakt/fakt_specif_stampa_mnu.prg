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
 */


/*! \file fmk/fakt/stampa/1g/mnu_izvj.prg
 *  \brief Izvjestaji vezani za opresu stampa
 */

/*! \fn MnuStampa()
 *  \brief Menij izvjestaja za opresu stampa
 */
 
function MnuStampa()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. vrijednost robe po partnerima i opstinama")
AADD(opcexe,{|| VRobPoPar()})
AADD(opc,"2. vrijednost robe po izdanjima i izdavacima")
AADD(opcexe,{|| VRobPoIzd()})
AADD(opc,"3. porezi po tarifama i opstinama")
AADD(opcexe,{|| PorPoOps()})

Menu_SC("stizv")
return
*}

