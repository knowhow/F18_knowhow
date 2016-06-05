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



FUNCTION pos_main_menu_admin()

   LOCAL nSetPosPM
   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. izvještaji                       " )
   AAdd( opcexe, {|| pos_izvjestaji() } )
   AAdd( opc, "2. pregled računa" )
   AAdd( opcexe, {|| pos_pregled_racuna_tabela() } )
   AAdd( opc, "L. lista ažuriranih dokumenata" )
   AAdd( opcexe, {|| pos_lista_azuriranih_dokumenata() } )
   AAdd( opc, "R. robno-materijalno poslovanje" )
   AAdd( opcexe, {|| pos_menu_robmat() } )
   AAdd( opc, "K. prenos realizacije u KALK" )
   AAdd( opcexe, {|| pos_prenos_pos_kalk() } )
   AAdd( opc, "S. šifarnici                  " )
   AAdd( opcexe, {|| pos_sifarnici() } )
   AAdd( opc, "A. administracija pos-a" )
   AAdd( opcexe, {|| pos_admin_menu() } )

   Menu_SC( "adm" )


FUNCTION SetPM( nPosSetPM )

   LOCAL nLen

   IF gIdPos == "X "
      gIdPos := gPrevIdPos
   ELSE
      gPrevIdPos := gIdPos
      gIdPos := "X "
   ENDIF
   nLen := Len( opc[ nPosSetPM ] )
   opc[ nPosSetPM ] := Left( opc[ nPosSetPM ], nLen - 2 ) + gIdPos
   pos_status_traka()

   RETURN .T.



FUNCTION pos_admin_menu()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. parametri rada programa                        " )
   AAdd( opcexe, {|| pos_parametri() } )

   AAdd( opc, "R. setovanje brojaca dokumenata" )
   AAdd( opcexe, {|| pos_set_param_broj_dokumenta() } )

   AAdd( opc, "X. briši nepostojeće dokumente" )
   AAdd( opcexe, {|| pos_brisi_nepostojece_dokumente() } )

   IF gStolovi == "D"
      AAdd( opc, "7. zakljucivanje postojecih racuna " )
      AAdd( opcexe, {|| zak_sve_stolove() } )
   ENDIF

   IF ( KLevel < L_UPRAVN )

      AAdd( opc, "---------------------------" )
      AAdd( opcexe, nil )

      AAdd( opc, "P. prodajno mjesto: " + gIdPos )
      nPosSetPM := Len( opc )
      AAdd( opcexe, {|| SetPm ( nPosSetPM ) } )

   ENDIF

   Menu_SC( "aadm" )

   RETURN .F.
