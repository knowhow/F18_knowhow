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


#include "f18.ch"


FUNCTION epdv_sifarnici()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. partneri               " )
   AAdd( opcexe, {|| p_partneri() } )
   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )

   AAdd( opc, "5. sheme generacije kuf" )
   AAdd( opcexe, {|| p_sg_kuf() } )
   AAdd( opc, "6. sheme generacije kif" )
   AAdd( opcexe, {|| p_sg_kif() } )

   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )

   AAdd( opc, "8. tarife" )
   AAdd( opcexe, {|| P_Tarifa() } )

   AAdd( opc, "-------------------------" )
   AAdd( opcexe, {|| nil } )

   AAdd( opc, "S. sifk" )
   AAdd( opcexe, {|| P_SifK() } )


   Menu_SC( "sif" )

   RETURN
