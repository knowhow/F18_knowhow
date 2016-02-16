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

FUNCTION MnuPregledDokumenata()

   LOCAL aOpc := {}
   LOCAL aOpcexe := {}
   LOCAL nIzbor := 1

   AAdd( aOpc, "1. kontrola zbira datoteka                     " )
   AAdd( aOpcexe, {|| fin_kontrola_zbira() } )

   AAdd( aOpc, "2. štampanje ažuriranog dokumenta" )
   AAdd( aOpcexe, {|| fin_stampa_azur_naloga_menu() } )

   AAdd( aOpc, "3. stampa liste dokumenata" )
   AAdd( aOpcexe, {|| fin_stampa_liste_naloga() } )

   AAdd( aOpc, "4. kontrola zbira datoteka za period" )
   AAdd( aOpcexe, {|| fin_kontrola_zbira( .T. ) } )

   f18_menu( "pgl", .F., @nIzbor, aOpc, aOpcExe )

   RETURN .T.
