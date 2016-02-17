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



FUNCTION kalk_meni_mag_izvjestaji()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. izvještaji magacin             " )
   AAdd( _opcexe, {|| kalk_izvjestaji_magacina() } )
   AAdd( _opc, "2. izvještaji prodavnica" )
   AAdd( _opcexe, {|| kalk_izvjestaji_prodavnice_menu() } )
   AAdd( _opc, "3. izvještaji magacin+prodavnica" )
   AAdd( _opcexe, {|| kalk_izvjestaji_mag_i_pro() } )
   AAdd( _opc, "4. proizvoljni izvještaji" )
   AAdd( _opcexe, {|| ProizvKalk() } )
   AAdd( _opc, "5. export dokumenata" )
   AAdd( _opcexe, {|| krpt_export() } )

   f18_menu( "izvj", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN




FUNCTION kalk_izvjestaji_mag_i_pro()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "F. finansijski obrt za period mag+prod" )
   AAdd( _opcexe, {|| ObrtPoMjF() } )
   AAdd( _opc, "N. najprometniji artikli" )
   AAdd( _opcexe, {|| NPArtikli() } )
   AAdd( _opc, "O. stanje artikala po objektima " )
   AAdd( _opcexe, {|| kalk_izvj_stanje_po_objektima() } )

   IF IsVindija()
      AAdd( _opc, "V. pregled prodaje" )
      AAdd( _opcexe, {|| PregProdaje() } )
   ENDIF

   f18_menu( "izmp", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN
