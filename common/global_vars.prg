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
FUNCTION org_params( set_params )

   LOCAL _x := 1
   LOCAL _left := 20

   IF ( set_params == nil )
      set_params := .T.
   ENDIF

   gZaokr := fetch_metric( "zaokruzenje", nil, gZaokr )
   gFirma := fetch_metric( "org_id", nil, gFirma )
   gNFirma := PadR( fetch_metric( "org_naziv", nil, gNFirma ), 50 )
   gMjStr := fetch_metric( "org_mjesto", nil, gMjStr )
   gTS := fetch_metric( "tip_subjekta", nil, gTS )
   gTabela := fetch_metric( "tip_tabele", nil, gTabela )
   gBaznaV := fetch_metric( "bazna_valuta", nil, gBaznaV )
   gPDV := fetch_metric( "pdv_global", nil, gPDV )

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

   RETURN .T.



FUNCTION set_global_vars()


   SetSpecifVars()
   SetValuta()

   PUBLIC gFirma := "10"
   PUBLIC gTS := PadR( "Preduzece", 20 )
   PUBLIC gNFirma := PadR( "", 50 )
   PUBLIC gBaznaV := "D"
   PUBLIC gZaokr := 2
   PUBLIC gTabela := 0
   PUBLIC gPDV := "D"
   PUBLIC gMjStr := PadR( "Sarajevo", 30 )
   PUBLIC gModemVeza := "N"
   PUBLIC gNW := "D"

   // setuj podatke ako ne postoje
   org_params( .F. )

   PUBLIC gPartnBlock
   gPartnBlock := nil

   PUBLIC gSecurity := "D"
   PUBLIC gnDebug := 0
   PUBLIC gOpSist := "-"

   PUBLIC cZabrana := "Opcija nedostupna za ovaj nivo !!!"

   SetPDVBoje()

   RETURN


FUNCTION SetPDVBoje()

   IF ValType( goModul:oDesktop ) != "O"
      RETURN .F.
   ENDIF

   IF IsPDV()
      PDVBoje()
      goModul:oDesktop:showMainScreen()
      StandardBoje()
   ELSE
      StandardBoje()
      goModul:oDesktop:showMainScreen()
      StandardBoje()
   ENDIF

   RETURN .T.



FUNCTION SetValuta()

   PUBLIC gOznVal := "KM"

   RETURN .T.


FUNCTION IsPDV()

   IF gPDV == "D"
      RETURN .T.
   ENDIF

   RETURN .F.
