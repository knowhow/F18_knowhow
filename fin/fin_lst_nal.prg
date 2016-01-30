/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

// -----------------------------------------
// stampa svih naloga - export u DBF
// -----------------------------------------
FUNCTION st_sv_nal()

   aFields := get_exp_fields()
   t_exp_create( aFields )

   O_SUBAN
   O_KONTO
   O_PARTN

   SELECT suban
   SET ORDER TO TAG "4"
   GO TOP
   // "4", "idFirma+IdVN+BrNal+Rbr"

   Box(, 4, 60 )

   @ m_x + 1, m_y + 2 SAY "Exportujem naloge......"

   DO WHILE !Eof() .AND. gFirma == idfirma

      SELECT partn
      SEEK suban->idpartner

      cPartNaz := partn->naz

      IF Empty( suban->idpartner )
         cPartNaz := ""
      ENDIF

      SELECT suban

      fill_export( field->idfirma, field->idvn, field->brnal, ;
         field->rbr, field->idkonto, field->idpartner, cPartNaz, ;
         field->d_p, field->iznosbhd, field->datdok, ;
         field->datval, field->brdok, field->opis )

      @ m_x + 3, m_y + 2 SAY "nalog-> " + idvn + "-" + brnal

      SKIP
   ENDDO

   BoxC()

   tbl_export()

   RETURN .T.


// ---------------------------------------------
// vraca definiciju polja tabele exporta
// ---------------------------------------------
STATIC FUNCTION get_exp_fields()

   LOCAL aDBF := {}

   AAdd( aDBF, { "IDVN", "C", 2, 0 } )
   AAdd( aDBF, { "BRNAL", "C", 4, 0 } )
   AAdd( aDBF, { "RBR", "C", 4, 0 } )
   AAdd( aDBF, { "IDKONTO", "C", 7, 0 } )
   AAdd( aDBF, { "IDPARTN", "C", 6, 0 } )
   AAdd( aDBF, { "NAZPART", "C", 40, 0 } )
   AAdd( aDBF, { "DUG", "N", 18, 8 } )
   AAdd( aDBF, { "POT", "N", 18, 8 } )
   AAdd( aDBF, { "DATUM", "D", 8, 0 } )
   AAdd( aDBF, { "DATVAL", "D", 8, 0 } )
   AAdd( aDBF, { "VEZA", "C", 10, 0 } )
   AAdd( aDBF, { "OPIS",  "C", 40, 0 } )

   RETURN aDBF



// ----------------------------------------------------------------
// napuni tabelu exporta
// ----------------------------------------------------------------
STATIC FUNCTION fill_export( cIdF, cIdVn, cBrNal, cRbr, cIdKto, ;
      cIdPart, cPartNaz, cD_P, nIznos, dDatum, ;
      dValuta, cVeza, cOpis )

   LOCAL nArr := Select()

   O_R_EXP

   APPEND BLANK
   REPLACE idvn WITH cIdVn
   REPLACE brnal WITH cBrNal
   REPLACE rbr WITH cRbr
   REPLACE idkonto WITH cIdKto
   REPLACE idpartn WITH cIdPart
   REPLACE nazpart WITH cPartNaz

   IF cD_P == "1"
      REPLACE dug WITH nIznos
      REPLACE pot WITH 0
   ELSE
      REPLACE dug WITH 0
      REPLACE pot WITH nIznos
   ENDIF

   REPLACE datum WITH dDatum
   REPLACE datval WITH dValuta
   REPLACE veza WITH cVeza
   REPLACE opis WITH cOpis


   SELECT ( nArr )

   RETURN
