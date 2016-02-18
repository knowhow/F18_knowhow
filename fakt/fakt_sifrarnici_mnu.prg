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


FUNCTION fakt_sifrarnik()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. opći šifarnici              " )
   AAdd( opcexe, {|| opci_sifarnici() } )

   AAdd( opc, "2. robno-materijalno poslovanje " )
   AAdd( opcexe, {|| sif_roba_tarife_koncij_sast() } )

   AAdd( opc, "3. fakt->txt" )
   AAdd( opcexe, {|| OSifFtxt(), P_FTxt() } )

   AAdd( opc, "U. ugovori" )
   AAdd( opcexe, {|| o_ugov(), SifUgovori() } )

   Menu_SC( "fsif" )

   RETURN .T.
