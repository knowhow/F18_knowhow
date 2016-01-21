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

#include "f18.ch"

/*! \file fmk/fin/razdb/1g/mnu_raz.prg
 *  \brief Menij razmjene podataka
 */
 
/*! \fn MnuRazmjenaPodataka() 
 *  \brief Menij razmjene podataka
 */
function MnuRazmjenaPodataka()

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. fakt->fin                   ")
AADD(opcexe, {|| FaktFin()})
AADD(opc, "2. ld->fin ")
AADD(opcexe, {|| LdFin()})
AADD(opc, "3. import elba ")
AADD(opcexe, {|| _imp_elba_txt() })
AADD(opc, "4. export dbf (svi nalozi) ")
AADD(opcexe, {|| st_sv_nal() })
AADD(opc, "6. pos->fin ")
AADD(opcexe, {|| PosFin()})

Menu_SC("raz")

return



/*! \fn PosFin()
 *  \brief Prenos prometa pologa
 */
function PosFin()

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. pos polozi                   ")
AADD(opcexe, {|| PromVP2Fin()})

Menu_SC("pf")

return




