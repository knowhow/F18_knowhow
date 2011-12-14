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

#include "fakt.ch"

// ------------------------------------
// stampa ugovora za period
// ------------------------------------
function ug_za_period()
local dDatGen
local cBrOd
local cBrDo
local cTipDok
local cDirPom

cDirPom := gcDirekt
gcDirekt := "B"
// parametri
if ug_st_od_do(@cBrOd, @cBrDo) == 0
	return
endif

// stampa....
cTipDok := "10"
fakt_stampa_azuriranog_period( gFirma, cTipDok, cBrOd, cBrDo )

gcDirekt := cDirPom
close all

return



