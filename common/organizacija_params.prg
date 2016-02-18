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


// ----------------------------------------------------
// setovanje podataka organizacione jedinice
// ----------------------------------------------------
FUNCTION parametri_organizacije( set_params )

   LOCAL _x := 1
   LOCAL _left := 20

   info_bar( "init", "parametri organizacije - start" )
   IF ( set_params == nil )
      set_params := .T.
   ENDIF

   PUBLIC gZaokr := fetch_metric( "zaokruzenje", nil, gZaokr )
   PUBLIC gFirma := fetch_metric( "org_id", nil, gFirma )
   PUBLIC gNFirma := PadR( fetch_metric( "org_naziv", nil, gNFirma ), 50 )
   PUBLIC gMjStr := fetch_metric( "org_mjesto", nil, gMjStr )
   PUBLIC gTS := fetch_metric( "tip_subjekta", nil, gTS )
   PUBLIC gTabela := fetch_metric( "tip_tabele", nil, gTabela )
   PUBLIC gBaznaV := fetch_metric( "bazna_valuta", nil, gBaznaV )
   PUBLIC gPDV := fetch_metric( "pdv_global", nil, gPDV )

   IF Empty( AllTrim( gNFirma ) )
      gNFirma := PadR( "", 50 )
      set_params := .T.
   ENDIF

   // setovati parametre org.jedinice
   IF set_params == .T.

      Box(, 10, 70 )

      @ m_x + _x, m_y + 2 SAY "Inicijalna podesenja organizacije ***" COLOR "I"

      ++ _x
      ++ _x
      @ m_x + _x, m_y + 2 SAY PadL( "Oznaka firme:", _left ) GET gFirma
      @ m_x + _x, Col() + 2 SAY "naziv:" GET gNFirma PICT "@S35"

      ++ _x
      @ m_x + _x, m_y + 2 SAY PadL( "Grad:", _left ) GET gMjStr PICT "@S20"

      ++ _x
      @ m_x + _x, m_y + 2 SAY PadL( "Tip subjekta:", _left ) GET gTS PICT "@S10"
      @ m_x + _x, Col() + 1 SAY "U sistemu pdv-a (D/N) ?" GET gPDV VALID gPDV $ "DN" PICT "@!"

      ++ _x
      ++ _x
      @ m_x + _x, m_y + 2 SAY PadL( "Bazna valuta (D/P):", _left ) GET gBaznaV PICT "@!" VALID gBaznaV $ "DPO"

      ++ _x
      @ m_x + _x, m_y + 2 SAY PadL( "Zaokruzenje:", _left ) GET gZaokr

      READ

      BoxC()

      // snimi parametre...
      IF LastKey() <> K_ESC
         set_metric( "org_id", nil, gFirma )
         set_metric( "zaokruzenje", nil, gZaokr )
         set_metric( "tip_subjekta", nil, gTS )
         set_metric( "org_naziv", nil, gNFirma )
         set_metric( "bazna_valuta", nil, gBaznaV )
         set_metric( "pdv_global", nil, gPDV )
         set_metric( "org_mjesto", nil, gMjStr )
      ENDIF

   ENDIF

   info_bar( "init", "parametri organizacije - end" )

   RETURN .T.



FUNCTION SetPDVBoje()

   IF ValType( goModul:oDesktop ) != "O"
      RETURN .F.
   ENDIF

      PDVBoje()
      goModul:oDesktop:showMainScreen()
      StandardBoje()

   RETURN .T.


FUNCTION SetValuta()

   PUBLIC gOznVal := "KM"

   RETURN .T.


FUNCTION IsPDV()

   RETURN .T.
