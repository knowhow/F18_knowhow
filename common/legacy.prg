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

STATIC cPrinter := "D"
STATIC nZagrada := 0
STATIC cKom := ""
STATIC nSekundi := 0
STATIC cTekprinter := ""
STATIC cFName


/*!  PreuzSezSPK(cSif)
 *  \brief Preuzimanje sifre iz sezone
 *  \param cSif
 */

FUNCTION PreuzSezSPK( cSif )

   STATIC cSezNS := "1998"
   LOCAL nObl := Select()

   Box(, 3, 70 )
   cSezNS := PadR( cSezNS, 4 )
   @ m_x + 1, m_y + 2 SAY "Sezona:" GET cSezNS PICT "9999"
   READ
   cSezNS := AllTrim( cSezNS )
   BoxC()
   IF cSif == "P"
      USE ( Trim( cDirSif ) + SLASH + cSezNS + "\PARTN" ) ALIAS PARTN2 NEW
      SELECT PARTN2
      SET ORDER TO TAG "ID"
      GO TOP
      HSEEK PSUBAN->idpartner
      IF Found()
         SELECT PARTN
         APPEND BLANK
         REPLACE id WITH PARTN2->id, ;
            naz WITH PARTN2->naz, ;
            mjesto WITH PARTN2->mjesto
      ELSE
         SELECT PARTN
         APPEND BLANK
         REPLACE id WITH PSUBAN->idpartner
      ENDIF
      SELECT PARTN2; USE
   ELSE
      USE ( Trim( cDirSif ) + SLASH + cSezNS + "\KONTO" ) ALIAS KONTO2 NEW
      SELECT KONTO2
      SET ORDER TO TAG "ID"
      GO TOP
      HSEEK PSUBAN->idkonto
      IF Found()
         SELECT KONTO
         APPEND BLANK
         REPLACE id WITH KONTO2->id, naz WITH KONTO2->naz
      ELSE
         SELECT KONTO
         APPEND BLANK
         REPLACE id WITH PSUBAN->idkonto
      ENDIF
      SELECT KONTO2; USE
   ENDIF
   SELECT ( nObl )

   RETURN .T.




/*! \fn OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
 */
FUNCTION OKumul( nArea, cStaza, cIme, nIndexa, cDefault )

   SELECT ( nArea )

   my_use ( cIme )

   RETURN NIL


FUNCTION Gather( cZn )

   LOCAL i, aStruct
   LOCAL _field_b
   LOCAL _ime_p
   LOCAL cVar

   IF cZn == nil
      cZn := "_"
   ENDIF
   aStruct := dbStruct()

   FOR i := 1 TO Len( aStruct )
      _field_b := FieldBlock( _ime_p := aStruct[ i, 1 ] )

      // cImeP - privatna var
      cVar := cZn + _ime_p

      // rlock()
      // IF "U" $ TYPE(cVar)
      // MsgBeep2("Neuskladj.strukt.baza! F-ja: GATHER(), Alias: " + ALIAS() + ", Polje: " + _ime_p)
      // ELSE
      Eval( _field_b, Eval( MemVarBlock( cVar ) ) )
      // ENDIF

      // dbunlock()
   NEXT

   RETURN NIL
