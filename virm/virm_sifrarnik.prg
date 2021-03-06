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


FUNCTION P_VrPrim( cId, dx, dy )

   LOCAL vrati
   PRIVATE ImeKol, Kol

   ImeKol := {}
   Kol := {}

   AAdd( Imekol, { "ID", {|| id }, "id", {|| .T. }, {|| validacija_postoji_sifra( wid ) } } )
   AAdd( Imekol, { "Opis", {|| NAZ              }, "NAZ"      } )
   AAdd( Imekol, { "Pomocni tekst", {|| POM_TXT          }, "POM_TXT"  } )
   AAdd( Imekol, { "Konto ", {|| idkonto          }, "idkonto"  } )
   AAdd( Imekol, { "Partner ", {|| idpartner         }, "idpartner"  } )
   AAdd( Imekol, { "Valuta ( ,1,2)", {|| PadC( NACIN_PL, 14 ) }, "NACIN_PL" } )
   AAdd( Imekol, { "Racun", {|| RACUN           }, "RACUN"   } )
   AAdd( Imekol, { "Unos dobavlj (D/N)", {|| PadC( DOBAV, 13 )   }, "DOBAV"    } )

   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ) ; NEXT

   vrati := p_sifra( F_VRPRIM, 1, 10, 77, "Lista: Vrste primalaca:", @cId, dx, dy )

   RETURN vrati

FUNCTION P_VrPrim2( cId, dx, dy )

   LOCAL vrati
   PRIVATE ImeKol, Kol

   ImeKol := { { "ID", {|| id }, "id", {|| .T. }, {|| validacija_postoji_sifra( wid ) } }, ;
      { "Opis", {|| NAZ  }, "NAZ"      }, ;
      { "Pomocni tekst", {|| POM_TXT   }, "POM_TXT"  }, ;
      { "Konto ", {|| idkonto }, "idkonto"  }, ;
      { "Partner ", {|| idpartner  }, "idpartner"  }, ;
      { "Valuta ( ,1,2)", {|| PadC( NACIN_PL, 14 ) }, "NACIN_PL" }, ;
      { "Racun", {|| Racun  }, "Racun"   }, ;
      { "Unos dobavlj (D/N)", {|| PadC( DOBAV, 13 )   }, "DOBAV"    };
      }
   Kol := { 1, 2, 3, 4, 5, 6, 7, 8 }
   vrati := p_sifra( F_VRPRIM2, 1, 10, 77, "LISTA VRSTA PRIMALACA ZA UPLATNICE:", @cId, dx, dy )

   RETURN vrati



FUNCTION P_LDVIRM( cId, dx, dy )

   LOCAL vrati
   PRIVATE ImeKol, Kol

   ImeKol := { { "ID", {|| id }, "id", {|| .T. }, {|| P_VRPRIM( @wId ), wNaz := Padr( wNaz, 50), .T. } }, ;
      { "Opis", {|| field->naz }, "naz"   }, ;
      { "FORMULA", {|| field->formula }, "formula"  };
      }
   Kol := { 1, 2, 3 }

   vrati := p_sifra( F_LDVIRM, 1, f18_max_rows()-10, f18_max_cols()-20, "LISTA LD->VIRM:", @cId, dx, dy )

   RETURN vrati






FUNCTION P_JPrih( cId, dx, dy )

   LOCAL vrati
   PRIVATE ImeKol, Kol

   ImeKol := {}
   Kol := {}
   AAdd( Imekol, { "Vrsta",   {|| Id },      "Id" } )
   AAdd( Imekol, { "N0",      {|| IdN0 },    "IdN0" } )
   AAdd( Imekol, { "Kan",     {|| IdKan },   "IdKan" } )
   AAdd( Imekol, { "Ops",     {|| IdOps },   "IdOps" } )
   AAdd( Imekol, { "Naziv",   {|| Naz },     "Naz" } )
   AAdd( Imekol, { "Racun",   {|| Racun },   "Racun" } )
   AAdd( Imekol, { "BudzOrg", {|| BudzOrg }, "BudzOrg" } )
   FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   vrati := p_sifra( F_JPRIH, 1, f18_max_rows() - 10, f18_max_cols() - 20, "Lista Javnih prihoda", @cId, dx, dy )

   RETURN vrati
