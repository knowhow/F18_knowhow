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

// stampa liste dokumenata koji se nalaze u pripremi
FUNCTION StPripr()

   m := "-------------- -------- ----------"
   O_KALK_PRIPR

   START PRINT CRET

   ?? m
   ? "   Dokument     Datum  Broj stavki"
   ? m
   DO WHILE !Eof()
      cIdFirma := IdFirma; cIdVd := idvd; cBrDok := BrDok
      dDatDok := datdok
      nStavki := 0
      DO WHILE !Eof() .AND. cIdFirma == idfirma .AND. cIdVd == idvd .AND. cbrdok == brdok
         ++nStavki
         SKIP
      ENDDO
      ? cIdFirma + "-" + cIdVd + "-" + cBrDok, dDatDok, Str( nStavki, 4 ), Space( 2 ), "__"
   ENDDO
   ? m
   ENDPRINT
   closeret

   RETURN
