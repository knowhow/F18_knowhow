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


FUNCTION pos_sifarnici()

   tops_sifarnici()

   RETURN .T.






FUNCTION SifreHOpc()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := {}

   AAdd( opc, "1. vrste placanja                   " )
   AAdd( opcexe, {|| P_VrsteP() } )
   AAdd( opc, "2. valute" )
   AAdd( opcexe, {|| P_Valuta(), SetNazDVal() } )
   AAdd( opc, "3. partneri" )
   AAdd( opcexe, {|| P_Firma() } )
   AAdd( opc, "4. sifk" )
   AAdd( opcexe, {|| P_SifK() } )
   AAdd( opc, "5. uredjaji za stampu" )
   AAdd( opcexe, {|| P_Uredj() } )

   IF gVrstaRS == "K"
      // metalurg ...
      AAdd ( opc, "6. uredjaji-odjeljenja" )
      AAdd( opcexe, {|| NotImp() } )
      AAdd ( opc, "7. robe-iznimci" )
      AAdd( opcexe, {|| NotImp() } )
   ENDIF

   Izbor := 1
   f18_menu_sa_priv_vars_opc_opcexe_izbor( "sifo" )

   RETURN


FUNCTION SifreHSpec()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := {}

   AAdd( opc, "1. robe/artikli                     " )
   AAdd( opcexe, {|| P_Roba() } )
   AAdd( opc, "2. -------" )
   AAdd( opcexe, {|| nil } )
   AAdd( opc, "3. tarife" )
   AAdd( opcexe, {|| P_Tarifa() } )
   AAdd( opc, "4. odjeljenja" )
   AAdd( opcexe, {|| P_Odj() } )
   AAdd( opc, "5. dijelovi objekta" )
   AAdd( opcexe, {|| P_Dio() } )
   AAdd( opc, "6. kase (prodajna mjesta)" )
   AAdd( opcexe, {|| P_Kase() } )
   AAdd( opc, "7. normativi" )
   AAdd( opcexe, {|| P_Sast() } )
   AAdd( opc, "8. stampa normativa" )
   AAdd( opcexe, {|| ISast() } )

   IF pos_admin()
      AAdd ( opc, "9. statusi radnika" )
      AAdd( opcexe, {|| P_StRad() } )
      AAdd ( opc, "10. osoblje" )
      AAdd( opcexe, {|| P_Osob() } )
   ENDIF

   Izbor := 1
   f18_menu_sa_priv_vars_opc_opcexe_izbor( "sifs" )

   RETURN




FUNCTION tops_sifarnici()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := {}

   AAdd( opc, "1. robe/artikli                " )
   AAdd( opcexe, {|| P_Roba() } )
   AAdd( opc, "2. tarife" )
   AAdd( opcexe, {|| P_Tarifa() } )
   AAdd( opc, "3. vrste placanja" )
   AAdd( opcexe, {|| P_VrsteP() } )
   AAdd( opc, "4. valute" )
   AAdd( opcexe, {|| P_Valuta(), SetNazDVal() } )
   AAdd( opc, "5. partneri" )
   AAdd( opcexe, {|| P_Firma() } )
   AAdd( opc, "6. odjeljenja" )
   AAdd( opcexe, {|| P_Odj() } )
   AAdd( opc, "7. kase (prodajna mjesta)" )
   AAdd( opcexe, {|| P_Kase() } )
   AAdd( opc, "8. sifk" )
   AAdd( opcexe, {|| P_SifK() } )
   AAdd( opc, "9. uređi za štampu" )
   AAdd( opcexe, {|| P_Uredj() } )

   IF pos_admin()
      AAdd( opc, "A. statusi radnika" )
      AAdd( opcexe, {|| P_StRad() } )
      AAdd( opc, "B. osoblje" )
      AAdd( opcexe, {|| P_Osob() } )
   ENDIF

   o_pos_sifre()

   Izbor := 1
   f18_menu_sa_priv_vars_opc_opcexe_izbor( "sift" )

   RETURN
