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



/*
 *     Racuna iznos PPP
    *   param: nMpcBp Maloprodajna cijena bez poreza
    *   param: aPorezi Matrica poreza
    *   param: aPoreziIzn Matrica izracunatih poreza
    *   param: nMpcSaP Maloprodajna cijena sa porezom
*/

FUNCTION kalk_porezi_maloprodaja( nMpcBp, aPorezi, nMpcSaP )

   LOCAL nPom
   LOCAL nUkPor

   IF nMpcBp == NIL // zadate je cijena sa porezom, utvrdi cijenu bez poreza
      nUkPor := aPorezi[ POR_PPP ] // POR_PPP - PDV
      nMpcBp := nMpcSaP / ( nUkPor / 100 + 1 )
   ENDIF

   nPom := nMpcBP * aPorezi[ POR_PPP ] / 100

   RETURN nPom



/*
    *   Filovanje matrice aPorezi sa porezima
    *   param: aPorezi Matrica poreza, aPorezi:={PPP,PP,PPU,PRUC,PRUCMP,DLRUC}

*/
FUNCTION set_pdv_array( aPorezi )

   IF ( aPorezi == nil )
      aPorezi := {}
   ENDIF
   IF ( Len( aPorezi ) == 0 )
      // inicijaliziraj poreze
      aPorezi := { 0, 0, 0, 0, 0, 0, 0 }
   ENDIF
   aPorezi[ POR_PPP ] := tarifa->opp


   // aPorezi[ POR_PP ] := tarifa->zpp
   // aPorezi[ POR_PPU ] := tarifa->ppp
   // aPorezi[ POR_PRUC ]  := tarifa->vpp

   IF tarifa->( FieldPos( "mpp" ) ) <> 0
      aPorezi[ POR_PRUCMP ] := tarifa->mpp
   ELSE
      aPorezi[ POR_PRUCMP ] := 0
   ENDIF

   RETURN NIL


FUNCTION set_pdv_public_vars()

   PUBLIC _PDV := tarifa->opp / 100
   PUBLIC _OPP := tarifa->opp / 100
   PUBLIC _PP := 0
   PUBLIC _ZPP := 0
   PUBLIC _PPP := 0
   PUBLIC _ZPP := 0
   PUBLIC _PORVT := 0
   PUBLIC _MPP   := 0
   PUBLIC _DLRUC := 0

   RETURN .T.
