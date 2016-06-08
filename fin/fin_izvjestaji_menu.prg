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


FUNCTION fin_izvjestaji()

   PRIVATE Izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. kartica                      " )
   AAdd( opcexe, {|| fin_kartice_menu() } )
   AAdd( opc, "2. bruto bilansi" )
   AAdd( opcexe, {|| FinBrutoBilans():New():print() } )
   AAdd( opc, "3. specifikacije" )
   AAdd( opcexe, {|| fin_menu_specifikacije() } )
   AAdd( opc, "5. proizvoljni izvještaji" )
   AAdd( opcexe, {|| ProizvFin() } )
   AAdd( opc, "6. dnevnik naloga" )
   AAdd( opcexe, {|| DnevnikNaloga() } )
   AAdd( opc, "7. ostali izvještaji" )
   AAdd( opcexe, {|| fin_izvjestaji_ostali() } )
   AAdd( opc, "8. blagajnicki nalog" )
   AAdd( opcexe, {|| blag_azur() } )

   Menu_SC( "izvj" )

   RETURN .F.
