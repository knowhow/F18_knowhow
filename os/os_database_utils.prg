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


// -----------------------------------------------------
// provjerava da li postoji polje u tabelama os/sii
// -----------------------------------------------------
FUNCTION os_postoji_polje( naziv_polja )

   LOCAL _ret := .F.

   IF gOsSii == "O"
      IF os->( FieldPos( naziv_polja ) ) <> 0
         _ret := .T.
      ENDIF
   ELSE
      IF sii->( FieldPos( naziv_polja ) ) <> 0
         _ret := .T.
      ENDIF
   ENDIF

   RETURN _ret


// ----------------------------------------
// selektuje potrebnu tabelu
// ----------------------------------------
FUNCTION select_os_sii()

   IF gOsSii == "O"
      SELECT os
   ELSE
      SELECT sii
   ENDIF

   RETURN .T.


// ----------------------------------------
// selektuje potrebnu tabelu
// ----------------------------------------
FUNCTION select_promj()

   IF gOsSii == "O"
      SELECT promj
   ELSE
      SELECT sii_promj
   ENDIF

   RETURN

// ----------------------------------------
// otvara potrebnu tabelu
// ----------------------------------------
FUNCTION o_os_sii()

   IF gOsSii == "O"
      O_OS
   ELSE
      O_SII
   ENDIF

   RETURN


// ----------------------------------------
// otvara potrebnu tabelu
// ----------------------------------------
FUNCTION o_os_sii_promj()

   IF gOsSii == "O"
      O_PROMJ
   ELSE
      O_SII_PROMJ
   ENDIF

   RETURN


// -----------------------------------------
// vraca naziv tabele na osnovu alias-a
// -----------------------------------------
FUNCTION get_os_table_name( alias )

   LOCAL _ret := "os_os"

   IF Upper( alias ) == "OS"
      _ret := "os_os"
   ELSE
      _ret := "sii_sii"
   ENDIF

   RETURN _ret



// -----------------------------------------
// vraca naziv tabele na osnovu alias-a
// -----------------------------------------
FUNCTION get_promj_table_name( alias )

   LOCAL _ret := "os_promj"

   IF Upper( alias ) == "PROMJ"
      _ret := "os_promj"
   ELSE
      _ret := "sii_promj"
   ENDIF

   RETURN _ret





// -----------------------------------------
// unificiraj invent. brojeve
// -----------------------------------------
FUNCTION Unifid()

   LOCAL nTrec, nTSRec
   LOCAL nIsti
   LOCAL _rec

   o_os_sii()

   SET ORDER TO TAG "1"

   DO WHILE !Eof()

      cId := field->id
      nIsti := 0

      DO WHILE !Eof() .AND. field->id == cId
         ++ nIsti
         SKIP
      ENDDO

      IF nIsti > 1
         // ima duplih slogova
         SEEK cId
         // prvi u redu
         nProlaz := 0
         DO WHILE !Eof() .AND. field->id == cId
            SKIP
            ++nProlaz
            nTrec := RecNo()   // sljedeci
            SKIP -1
            nTSRec := RecNo()
            cNovi := ""
            IF Len( Trim( cid ) ) <= 8
               cNovi := Trim( id ) + idrj
            ELSE
               cNovi := Trim( id ) + Chr( 48 + nProlaz )
            ENDIF
            SEEK cnovi
            IF Found()
               MsgBeep( "vec postoji " + cid )
            ELSE
               GO nTSRec
               _rec := dbf_get_rec()
               _rec[ "id" ] := cNovi
               update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
            ENDIF
            GO nTrec
         ENDDO
      ENDIF

   ENDDO

   RETURN



FUNCTION RazdvojiDupleInvBr()

   IF spec_funkcije_sifra( "UNIF" )
      IF pitanje(, "Razdvojiti duple inv.brojeve ?", "N" ) == "D"
         UnifId()
      ENDIF
   ENDIF

   RETURN
