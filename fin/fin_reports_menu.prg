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

#include "f18.ch"


function Izvjestaji()
private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. kartica                      ")
AADD(opcexe,{|| fin_kartice_menu()})
AADD(opc,"2. bruto bilansi")
AADD(opcexe,{|| FinBrutoBilans():New():print() })
AADD(opc,"3. specifikacije")
AADD(opcexe,{|| fin_menu_specifikacije()})
AADD(opc,"5. proizvoljni izvjestaji")
AADD(opcexe,{|| ProizvFin()})
AADD(opc,"6. dnevnik naloga")
AADD(opcexe,{|| DnevnikNaloga()})
AADD(opc,"7. ostali izvještaji")
AADD(opcexe,{|| fin_izvjestaji_ostali()})
AADD(opc,"8. blagajnicki nalog")
AADD(opcexe,{|| blag_azur()})

Menu_SC("izvj")

return .f.


