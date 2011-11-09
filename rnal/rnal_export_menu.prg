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


#include "rnal.ch"



// --------------------------------------------------------
// meni exporta
// --------------------------------------------------------
function m_export( nDoc_no, aDocList, lTemp, lWriteRel )
local mX := m_x
local mY := m_y
private opc := {}
private opcexe := {}
private izbor := 1

AADD( opc, "1. rnal -> GPS.opt (Lisec)         ")
AADD( opcexe, {|| exp_2_lisec( nDoc_no, lTemp, lWriteRel ), izbor := 0 } )
AADD( opc, "2. rnal -> FMK    ")
AADD( opcexe, {|| exp_2_fmk( lTemp, nDoc_no, aDocList ), izbor := 0 } )
AADD( opc, "3. rnal -> FMK (zadnja otpremnica) ")
AADD( opcexe, {|| exp_2_fmk( lTemp, nDoc_no, aDocList, .t. ), izbor := 0 } )

Menu_SC("export")

m_x := mX
m_y := mY

return



