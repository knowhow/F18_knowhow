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


FUNCTION kalk_pregled_dokumenata()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. štampa ažuriranog dokumenta              " )
   AAdd( _opcexe, {|| kalk_stampa_dokumenta( .T. ) } )

   AAdd( _opc, "2. štampa liste dokumenata" )
   AAdd( _opcexe, {|| kalk_stampa_liste_dokumenata() } )

/*
   AAdd( _opc, "3. pregled dokumenata po hronologiji obrade" )
   AAdd( _opcexe, {|| kalk_pregled_dokumenata_hronoloski() } )
*/

   AAdd( _opc, "4. pregled dokumenata - tabelarni pregled" )
   AAdd( _opcexe, {|| browse_kalk_dokumenti() } )

/*
   AAdd( _opc, "5. radni nalozi " )
   AAdd( _opcexe, {|| BrowseRn() } )
*/

   AAdd( _opc, "8. kalkulacija cijena" )
   AAdd( _opcexe, {|| kalkulacija_cijena() } )

   f18_menu( "razp", .F., _izbor, _opc, _opcexe )

   //my_close_all_dbf()

   RETURN .T.


FUNCTION kalk_ostale_operacije_doks()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. povrat dokumenta u pripremu" )
   AAdd( _opcexe, {|| kalk_povrat_dokumenta() } )


   AAdd( _opc, "S. pregled smeća " )
   AAdd( _opcexe, {|| kalk_pregled_smece_pripr9() } )


   f18_menu( "mazd", .F., _izbor, _opc, _opcexe )

   //my_close_all_dbf()

   RETURN .T.
