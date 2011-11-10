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


#include "epdv.ch"

/*
* ----------------------------------------------------------------
*                           Copyright Sigma-com software 2006
* ----------------------------------------------------------------
*/

function s_tarifa(cIdTar)
local cPom := ""

PushWa()

SELECT (F_TARIFA)

if !used()
	O_TARIFA
endif
SET ORDER TO TAG "ID"

seek cIdTar

if !found()
	cPom := "-NEP.TAR- ?!"
else
	cPom := ALLTRIM(naz) 
endif

PopWa()
return cPom


// -----------------------------
// get stopu za tarifu
// -----------------------------
function g_pdv_stopa(cIdTar)
local nStopa

PushWa()

SELECT (F_TARIFA)

if !used()
	O_TARIFA
endif
SET ORDER TO TAG "ID"

seek PADR(cIdTar, 6)

if !found()
	nStopa := -999
else
	nStopa := tarifa->opp
endif

PopWa()
return nStopa


