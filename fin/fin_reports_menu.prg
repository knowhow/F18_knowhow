/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

/*! \file fmk/fin/rpt/1g/mnu_rpt.prg
 *  \brief Menij izvjestaja
 */

/*! \fn Izvjestaji()
 *  \brief Glavni menij za izbor izvjestaja
 *  \param 
 */
 
function Izvjestaji()

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. kartica                      ")
AADD(opcexe,{|| fin_kartica()})
AADD(opc,"2. bruto bilans")
AADD(opcexe,{|| Bilans()})
AADD(opc,"3. specifikacije")
AADD(opcexe,{|| MnuSpecif()})
AADD(opc,"4. specifikacije po godinama")
AADD(opcexe,{|| MnuSpecGod()})
AADD(opc,"5. proizvoljni izvjestaji")
AADD(opcexe,{|| ProizvFin()})
AADD(opc,"6. dnevnik naloga")
AADD(opcexe,{|| DnevnikNaloga()})
AADD(opc,"7. ostali izvjestaji")
AADD(opcexe,{|| Ostalo()})
AADD(opc,"8. blagajnicki nalog")
AADD(opcexe,{|| blag_azur()})

Menu_SC("izvj")

return .f.


