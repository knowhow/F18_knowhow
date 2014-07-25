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


#include "kalk.ch"

FUNCTION kalk_izvjestaji_prodavnice_menu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _Opc, "1. kartica - prodavnica                          " )
   AAdd( _opcexe, {|| kalk_kartica_prodavnica() } )
   AAdd( _Opc, "2. lager lista - prodavnica" )
   AAdd( _opcexe, {|| lager_lista_prodavnica() } )
   AAdd( _Opc, "3. finansijsko stanje prodavnice" )
   AAdd( _opcexe, {|| FLLP() } )
   AAdd( _Opc, "4. trgovačka knjiga na malo" )
   AAdd( _opcexe, {|| kalk_tkm() } )
   AAdd( _Opc, "5. pregled asortimana za dobavljača" )
   AAdd( _opcexe, {|| asortiman_dobavljac_mp() } )
   AAdd( _Opc,  "---------------------------------" )
   AAdd( _opcexe, NIL )
   AAdd( _Opc,  "P. porezi" )
   AAdd( _opcexe, {|| PoreziProd() } )
   AAdd( _Opc,  "---------------------------------" )
   AAdd( _opcexe, NIL )
   AAdd( _Opc,  "V. pregled za više objekata" )
   AAdd( _opcexe, {|| RekProd() } )

   f18_menu( "izp", .F., _izbor, _opc, _opcexe )

   RETURN NIL


/*
   porezi - prodavnica
*/

FUNCTION PoreziProd()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _Opc, "1. ukalkulisani porezi           " )
   AAdd( _opcexe, {|| RekKPor() } )
   AAdd( _Opc, "2. realizovani porezi" )
   AAdd( _opcexe, {|| RekRPor() } )

   f18_menu( "porp", .F., _izbor, _opc, _opcexe )

   RETURN NIL


/*
 pregledi za vise objekata
*/

FUNCTION RekProd()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   AAdd( _opc, "1. sintetička lager lista                  " )
   AAdd( _opcexe, {|| LLPS() } )
   AAdd( _opc, "2. rekapitulacija fin stanja po objektima" )
   AAdd( _opcexe, {|| RFLLP() } )
   AAdd( _opc, "3. dnevni promet za sve objekte" )
   AAdd( _opcexe, {|| DnevProm() } )
   AAdd( _opc, "4. pregled prometa prodavnica za period" )
   AAdd( _opcexe, {|| PPProd() } )
   AAdd( _opc, "5. (vise)dnevni promet za sve objekte" )
   AAdd( _opcexe, {|| PromPeriod() } )

   f18_menu( "prsi", .F., _izbor, _opc, _opcexe )

   RETURN NIL
