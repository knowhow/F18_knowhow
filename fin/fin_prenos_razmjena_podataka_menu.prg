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



FUNCTION fin_razmjena_podataka_meni()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. fakt->fin                   " )
   AAdd( opcexe, {|| fakt_fin_prenos() } )
   AAdd( opc, "2. ld->fin " )
   AAdd( opcexe, {|| LdFin() } )
   AAdd( opc, "3. import elba " )
   AAdd( opcexe, {|| import_elba() } )
   AAdd( opc, "4. export dbf (svi nalozi) " )
   AAdd( opcexe, {|| st_sv_nal() } )
   AAdd( opc, "6. pos->fin " )
   AAdd( opcexe, {|| PosFin() } )

   f18_menu_sa_priv_vars_opc_opcexe_izbor( "raz" )

   RETURN .T.



/* PosFin()
 *     Prenos prometa pologa
 */
FUNCTION PosFin()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. pos polozi                   " )
   AAdd( opcexe, {|| PromVP2Fin() } )

   f18_menu_sa_priv_vars_opc_opcexe_izbor( "pf" )

   RETURN
