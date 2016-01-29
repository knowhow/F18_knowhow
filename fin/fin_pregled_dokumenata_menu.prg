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

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. kontrola zbira datoteka                     " )
   AAdd( opcexe, {|| KontrZb() } )

   AAdd( opc, "2. štampanje ažuriranog dokumenta" )

      AAdd( opcexe, {|| fin_stampa_azur_naloga_menu() } )


   AAdd( opc, "3. stampa liste dokumenata" )
   AAdd( opcexe, {|| fin_stampa_liste_naloga() } )

   AAdd( opc, "4. kontrola zbira datoteka za period" )
   AAdd( opcexe, {|| KontrZb( .T. ) } )

   Menu_SC( "pgl" )

   RETURN .T.
