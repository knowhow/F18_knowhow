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


#include "fmk.ch"

// ---------------------------------
// otvaranje tabele REFER
// ---------------------------------
FUNCTION p_refer( cId, dx, dy )

   LOCAL nArr
   LOCAL _ret

   PRIVATE ImeKol
   PRIVATE Kol

   nArr := Select()
   O_REFER

   ImeKol := {}
   Kol := {}

   AAdd( ImeKol, { PadR( "Id", 2 ), {|| id }, "id", {|| .T. }, {|| sifra_postoji( wid ) } } )
   AAdd( ImeKol, { PadR( "idops", 5 ), {|| idops }, "idops", {|| .T. }, {|| p_ops( widops ) } } )
   AAdd( ImeKol, { PadR( "Naziv", 40 ), {|| naz }, "naz" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ( nArr )

   RETURN PostojiSifra( F_REFER, 1, 10, 65, "Lista referenata", @cId, dx, dy )



// ------------------------------------------------
// vraca naziv referenta iz tabele REFER
// ------------------------------------------------
FUNCTION g_refer( cReferId )

   LOCAL cNaz := ""
   LOCAL nTarea := Select()

   O_REFER
   SEEK cReferId
   IF Found() .AND. refer->id == cReferId
      cNaz := AllTrim( refer->naz )
   ENDIF
   SELECT ( nTarea )

   RETURN cNaz
