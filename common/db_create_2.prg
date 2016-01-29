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

FUNCTION OFmkSvi()

   O_KONTO
   O_PARTN
   O_TNAL
   O_TDOK
   O_VALUTE
   O_RJ
   O_BANKE
   O_OPS

   SELECT ( F_SIFK )
   IF !Used()
      O_SIFK
   ENDIF

   SELECT ( F_SIFV )
   IF !Used()
      O_SIFV
   ENDIF

   O_FAKT_OBJEKTI

   RETURN .T.


FUNCTION OSifVindija()

   O_RELAC
   O_VOZILA
   O_KALPOS

   RETURN .T.


FUNCTION OSifFtxt()

   O_FTXT

   RETURN .T.


FUNCTION OSifUgov()

   O_UGOV
   O_RUGOV
   O_DEST
   O_PARTN
   O_ROBA
   O_SIFK
   O_SIFV

   RETURN .T.


// ---------------------------
// dodaje polje match_code
// ---------------------------
FUNCTION add_f_mcode( aDbf )

   AAdd( aDbf, { "MATCH_CODE", "C", 10, 0 } )

   RETURN

// ------------------------------------
// kreiranje indexa matchcode
// ------------------------------------
FUNCTION index_mcode( dummy, alias )

   IF FieldPos( "MATCH_CODE" ) <> 0
      CREATE_INDEX( "MCODE", "match_code", alias )
   ENDIF

   RETURN


// --------------------------------------------
// provjerava da li polje postoji, samo za ops
// --------------------------------------------
FUNCTION PoljeExist( cNazPolja )

   O_OPS

   IF OPS->( FieldPos( cNazPolja ) ) <> 0
      USE
      RETURN .T.
   ELSE
      USE
      RETURN .F.
   ENDIF
