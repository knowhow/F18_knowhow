/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


FUNCTION pos_main_menu_upravnik()

   //IF gVrstaRS == "A"
      MMenuUpA()
   //ELSEIF gVrstaRS == "K"
    //  MMenuUpK()
   //ELSE
    //  MMenuUpS()
   //ENDIF

   RETURN .T.



FUNCTION MMenuUpA()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. izvještaji                        " )
   AAdd( opcexe, {|| pos_izvjestaji() } )
   AAdd( opc, "L. lista ažuriranih dokumenata" )
   AAdd( opcexe, {|| pos_lista_azuriranih_dokumenata() } )

   AAdd( opc, "R. prenos realizacije u KALK" )
   AAdd( opcexe, {|| pos_kalk_prenos_realizacije() } )

   AAdd( opc, "D. unos dokumenata" )
   AAdd( opcexe, {|| pos_menu_dokumenti() } )

   AAdd( opc, "R. robno-materijalno poslovanje" )
   AAdd( opcexe, {|| pos_menu_robmat() } )

   AAdd( opc, "--------------" )
   AAdd( opcexe, nil )
   AAdd( opc, "S. šifarnici" )
   AAdd( opcexe, {|| pos_sifarnici() } )
   AAdd( opc, "W. administracija pos-a" )
   AAdd( opcexe, {|| pos_admin_menu() } )
   //AAdd( opc, "P. promjena seta cijena" )
   //AAdd( opcexe, {|| PromIDCijena() } )

   f18_menu_sa_priv_vars_opc_opcexe_izbor( "upra" )

   closeret

   RETURN .F.


/*
FUNCTION MMenuUpK()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   // Vrsta kase "K" - radna stanica

   AAdd( opc, "1. izvjestaji             " )
   AAdd( opcexe, {|| pos_izvjestaji() } )
   AAdd( opc, "--------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc, "S. sifarnici" )
   AAdd( opcexe, {|| pos_sifarnici() } )
   AAdd( opc, "A. administracija pos-a" )
   AAdd( opcexe, {|| pos_admin_menu() } )

   f18_menu_sa_priv_vars_opc_opcexe_izbor( "uprk" )

   RETURN .F.



FUNCTION MMenuUpS()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   // Vrsta kase "S" - server kasa

   AAdd( opc, "1. izvještaji             " )
   AAdd( opcexe, {|| pos_izvjestaji() } )
   AAdd( opc, "2. unos dokumenata" )
   AAdd( opcexe, {|| pos_menu_dokumenti() } )
   AAdd( opc, "S. šifarnici" )
   AAdd( opcexe, {|| pos_sifarnici() } )

   f18_menu_sa_priv_vars_opc_opcexe_izbor( "uprs" )
   closeret

   RETURN .F.
*/

FUNCTION pos_menu_dokumenti()

   PRIVATE Izbor
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   Izbor := 1

   AAdd( opc, "Z. zaduzenje                       " )
   AAdd( opcexe, {|| Zaduzenje() } )
   AAdd( opc, "I. inventura" )
   AAdd( opcexe, {|| pos_inventura_nivelacija( .T. ) } )
   AAdd( opc, "N. nivelacija" )
   AAdd( opcexe, {|| pos_inventura_nivelacija( .F. ) } )
   AAdd( opc, "P. predispozicija" )
   AAdd( opcexe, {|| Zaduzenje( "PD" ) } )
   AAdd( opc, "R. reklamacija-povrat u magacin" )
   AAdd( opcexe, {|| Zaduzenje( VD_REK ) } )

   f18_menu_sa_priv_vars_opc_opcexe_izbor( "pzdo" )

   RETURN
