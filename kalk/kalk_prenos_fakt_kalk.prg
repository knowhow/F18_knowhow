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

FUNCTION FaktKalk()

   PRIVATE Opc := {}
   PRIVATE opcexe := {}

   AAdd( Opc, "1. magacin fakt->kalk         " )
   AAdd( opcexe, {|| prenos_fakt_kalk_magacin() } )
   AAdd( Opc, "2. prodavnica fakt->kalk" )
   AAdd( opcexe, {||  prenos_fakt_kalk_prodavnica()  } )
   AAdd( Opc, "3. proizvodnja fakt->kalk" )
   AAdd( opcexe, {||  FaKaProizvodnja() } )
   AAdd( Opc, "4. konsignacija fakt->kalk" )
   AAdd( opcexe, {|| FaktKonsig() } )
   PRIVATE Izbor := 1
   Menu_SC( "faka" )
   CLOSERET

   RETURN



/* ProvjeriSif(clDok,cImePoljaID,nOblSif,clFor)
 *     Provjera postojanja sifara
 *   param: clDok - "while" uslov za obuhvatanje slogova tekuce baze
 *   param: cImePoljaID - ime polja tekuce baze u kojem su sifre za ispitivanje
 *   param: nOblSif - oblast baze sifrarnika
 *   param: clFor - "for" uslov za obuhvatanje slogova tekuce baze
 */

FUNCTION ProvjeriSif( clDok, cImePoljaID, nOblSif, clFor, lTest )

   LOCAL lVrati := .T.
   LOCAL nArr := Select()
   LOCAL nRec := RecNo()
   LOCAL lStartPrint := .F.
   LOCAL cPom3 := ""
   LOCAL nR := 0

   IF lTest == nil
      lTest := .F.
   ENDIF

   IF clFor == NIL
      clFor := ".t."
   ENDIF

   PRIVATE cPom := clDok
   PRIVATE cPom2 := cImePoljaID
   PRIVATE cPom4 := clFor

   DO while &cPom
      if &cPom4
         SELECT ( nOblSif )
         cPom3 := ( nArr )->( &cPom2 )
         SEEK cPom3
         IF !Found()  .AND.  !(  fakt->( AllTrim( podbr ) == "." )  .AND. Empty( fakt->idroba ) )
            // ovo je kada se ide 1.  1.1 1.2
            ++nR
            lVrati := .F.
            IF lTest == .F.
               IF !lStartPrint
                  lStartPrint := .T.
                  StartPrint()
                  ? "NEPOSTOJECE SIFRE:"
                  ? "------------------"
               ENDIF
               ? Str( nR ) + ") SIFRA '" + cPom3 + "'"
            ELSE

               nTArea := Select()

               SELECT roba
               GO TOP
               SEEK fakt->idroba

               IF !Found()
                  APPEND BLANK
                  _rec := dbf_get_rec()
                  _rec[ "id" ] := fakt->idroba
                  _rec[ "naz" ] :=  "!!! KONTROLOM UTVRDJENO"
                  update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )
               ENDIF
               SELECT ( nTArea )

            ENDIF
         ENDIF
      ENDIF
      SELECT ( nArr )
      SKIP 1
   ENDDO

   GO ( nRec )
   IF lStartPrint
      ?
      EndPrint()
   ENDIF

   RETURN lVrati
