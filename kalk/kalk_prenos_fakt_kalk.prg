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

FUNCTION fakt_kalk()

   PRIVATE Opc := {}
   PRIVATE opcexe := {}

   AAdd( Opc, "1. magacin fakt->kalk         " )
   AAdd( opcexe, {|| prenos_fakt_kalk_magacin() } )
   AAdd( Opc, "2. prodavnica fakt->kalk" )
   AAdd( opcexe, {||  prenos_fakt_kalk_prodavnica()  } )

   AAdd( Opc, "3. proizvodnja fakt->kalk" )
   AAdd( opcexe, {||  menu_fakt_kalk_prenos_normativi() } )


   PRIVATE Izbor := 1
   f18_menu_sa_priv_vars_opc_opcexe_izbor( "faka" )
   CLOSERET

   RETURN .T.



/* provjerisif_izbaciti_ovu_funkciju(clDok,cImePoljaID,nOblSif,clFor)
 *     Provjera postojanja sifara
 *   param: clDok - "while" uslov za obuhvatanje slogova tekuce baze
 *   param: cImePoljaID - ime polja tekuce baze u kojem su sifre za ispitivanje
 *   param: nOblSif - oblast baze sifrarnika
 *   param: clFor - "for" uslov za obuhvatanje slogova tekuce baze


-- FUNCTION provjerisif_izbaciti_ovu_funkciju( clDok, cImePoljaID, nOblSif, clFor, lTest )

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

// TODO izbaciti ovu funkciju

IF .T.
       RETURN .T.
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
                  IF !start_print()
                     RETURN .F.
                  ENDIF
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
                  hRec := dbf_get_rec()
                  hRec[ "id" ] := fakt->idroba
                  hRec[ "naz" ] :=  "!!! KONTROLOM UTVRDJENO"
                  update_rec_server_and_dbf( "roba", hRec, 1, "FULL" )
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
      end_print()
   ENDIF

   RETURN lVrati
 */
