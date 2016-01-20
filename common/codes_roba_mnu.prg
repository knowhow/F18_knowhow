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


FUNCTION SifFmkRoba()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. roba                               " )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "ROBAOPEN" ) )
      AAdd( _opcexe, {|| P_Roba() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )
   ENDIF

   AAdd( _opc, "2. tarife" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "TARIFAOPEN" ) )
      AAdd( _opcexe, {|| P_Tarifa() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )
   ENDIF

   AAdd( _opc, "3. konta - tipovi cijena" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "KONC1OPEN" ) )
      AAdd( _opcexe, {|| P_Koncij() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )
   ENDIF

   AAdd( _opc, "4. konta - atributi / 2 " )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "KONC2OPEN" ) )
      AAdd( _opcexe, {|| P_Koncij2() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )
   ENDIF

   AAdd( _opc, "5. trfp - sheme kontiranja u fin" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "TRFPOPEN" ) )
      AAdd( _opcexe, {|| P_TrFP() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )
   ENDIF

   AAdd( _opc, "6. sastavnice" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "SASTOPEN" ) )
      AAdd( _opcexe, {|| P_Sast() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )
   ENDIF

   AAdd( _opc, "8. sifk - karakteristike" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "SIFKOPEN" ) )
      AAdd( _opcexe, {|| P_SifK() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )
   ENDIF

   AAdd( _opc, "9. strings - karakteristike " )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "STROPEN" ) )
      AAdd( _opcexe, {|| p_strings() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( F18_SECUR_WARRNING ) } )
   ENDIF

   my_close_all_dbf()
   OFmkRoba()

   f18_menu( "srob", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN
