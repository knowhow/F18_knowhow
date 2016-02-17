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


FUNCTION MAdminKALK()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

/*
   AAdd( _opc, "1. sređivanje kartica                                            " )
   AAdd( _opcexe, {|| MenuSK() } )
*/
   AAdd( _opc, "5. kopiraj set cijena iz/u" )
   AAdd( _opcexe, {|| kopiraj_set_cijena() } )

   AAdd( _opc, "8. kontrola maloprodajnih cijena " )
   AAdd( _opcexe, {|| sifre_artikli_provjera_mp_cijena() } )
   AAdd( _opc, "9. kontrola duplih barkodova " )
   AAdd( _opcexe, {|| rpt_dupli_barkod() } )
   AAdd( _opc, "A. formiraj MPC iz VPC " )
   AAdd( _opcexe, {|| roba_setuj_mpc_iz_vpc() } )

   f18_menu( "admk", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN .T.


/* TODO: izbaciti ?
FUNCTION MenuSK()

   PRIVATE Opc := {}
   PRIVATE opcexe := {}



   AAdd( Opc, "1. korekcija prodajne cijene - nivelacija (VPC iz sifr.robe)    " )
   AAdd( opcexe, {|| KorekPC() } )

   AAdd( Opc, "2. ispravka sifre artikla u dokumentima i sifrarniku" )
   AAdd( opcexe, {|| RobaIdSredi() } )
   AAdd( Opc, "3. korekcija nc storniranjem grešaka tipa NC=0   " )

   AAdd( opcexe, {|| KorekNC() } )
   AAdd( Opc, "4. korekcija nc pomoću dok.95 (NC iz sifr.robe)" )
   AAdd( opcexe, {|| KorekNC2() } )
   AAdd( Opc, "5. korekcija prodajne cijene - nivelacija (MPC iz sifr.robe)" )
   AAdd( opcexe, {|| KorekMPC() } )
   AAdd( Opc, "6. postavljanje tarife u dokumentima na vrijednost iz sifrarnika" )
   AAdd( opcexe, {|| KorekTar() } )
   AAdd( Opc, "7. svodjenje artikala na primarno pakovanje" )
   AAdd( opcexe, {|| NaPrimPak() } )

   PRIVATE Izbor := 1
   Menu_SC( "kska" )

   my_close_all_dbf()

   RETURN
*/
