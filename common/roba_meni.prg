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

MEMVAR gMeniSif

FUNCTION sif_roba_tarife_koncij_sast()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1
   LOCAL lPrev := gMeniSif

   gMeniSif := .T.

   AAdd( _opc, "1. roba                               " )
   AAdd( _opcexe, {|| P_Roba() } )

   AAdd( _opc, "2. tarife" )
   AAdd( _opcexe, {|| P_Tarifa() } )

   AAdd( _opc, "3. konta - tipovi cijena" )
   AAdd( _opcexe, {|| P_Koncij() } )

   AAdd( _opc, "4. konta - atributi / 2 " )
   AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )

   AAdd( _opc, "5. trfp - sheme kontiranja u fin" )
   AAdd( _opcexe, {|| P_TrFP() } )

   AAdd( _opc, "6. sastavnice" )
   AAdd( _opcexe, {|| P_Sast() } )


   AAdd( _opc, "8. sifk - karakteristike" )
   AAdd( _opcexe, {|| P_SifK() } )



   my_close_all_dbf()
   OFmkRoba()

   f18_menu( "srob", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   gMeniSif := lPrev

   RETURN .T.
