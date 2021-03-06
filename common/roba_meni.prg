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

MEMVAR gPregledSifriIzMenija

FUNCTION sif_roba_tarife_koncij_sast()

   LOCAL aOpc := {}
   LOCAL aOpcExe := {}
   LOCAL _izbor := 1
   LOCAL lPrev := gPregledSifriIzMenija

   gPregledSifriIzMenija := .T.

   AAdd( aOpc, "1. roba                               " )
   AAdd( aOpcExe, {|| P_Roba() } )

   AAdd( aOpc, "2. tarife" )
   AAdd( aOpcExe, {|| P_Tarifa() } )

   AAdd( aOpc, "3. konta - tipovi cijena" )
   AAdd( aOpcExe, {|| P_Koncij() } )

   AAdd( aOpc, "4. konta - atributi / 2 " )
   AAdd( aOpcExe, {|| MsgBeep( F18_SECUR_WARRNING ) } )

   AAdd( aOpc, "5. trfp - sheme kontiranja u fin" )
   AAdd( aOpcExe, {|| P_TrFP() } )

   AAdd( aOpc, "6. sastavnice" )
   AAdd( aOpcExe, {|| p_roba_sastavnice() } )


   AAdd( aOpc, "8. sifk - karakteristike" )
   AAdd( aOpcExe, {|| P_SifK() } )

   my_close_all_dbf()
   OFmkRoba()

   f18_menu( "srob", .F., _izbor, aOpc, aOpcExe )

   my_close_all_dbf()

   gPregledSifriIzMenija := lPrev

   RETURN .T.
