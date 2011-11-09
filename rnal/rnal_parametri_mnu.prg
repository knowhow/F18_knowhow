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
/*
* ----------------------------------------------------------------
*                                     Copyright Sigma-com software 
* ----------------------------------------------------------------
*/


// ------------------------------
// meni parametara
// ------------------------------
function m_par()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. podaci firme - zaglavlje            ")
AADD(opcexe, {|| ed_fi_params() })
AADD(opc, "2. izgled dokumenta  ")
AADD(opcexe, {|| ed_doc_params() } )
AADD(opc, "3. zaokruzenja, format prikaza  ")
AADD(opcexe, {|| ed_zf_params() } )
AADD(opc, "4. parametri exporta  ")
AADD(opcexe, {|| ed_ex_params() } )
AADD(opc, "5. parametri elemenata i atributa  ")
AADD(opcexe, {|| ed_elat_params() } )
AADD(opc, "---------------------------------")
AADD(opcexe, {|| nil } )
AADD(opc, "O. ostalo  ")
AADD(opcexe, {|| ed_ost_params() } )

Menu_SC("par")

return

