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

// ----------------------------------
// puni tabelu za export
// ----------------------------------
FUNCTION fill_ost_tbl( cIntervals, cIdPart, cP_naz, ;
      nTUVal, nTVVal, nTotal, ;
      nUVal1, nUVal2, nUVal3, nUVal4, nUValP, ;
      nVVal1, nVVal2, nVVal3, nVVal4, nVValP )

   LOCAL nArr

   nArr := Select()

   O_R_EXP
   APPEND BLANK
   REPLACE field->idpart WITH cIdPart
   REPLACE field->p_naz WITH cP_naz
   REPLACE field->t_vval WITH nTVVal
   REPLACE field->t_uval WITH nTUVal
   REPLACE field->TOTAL WITH nTotal

   IF cIntervals == "D"
      // u valuti
      REPLACE field->uval_1 WITH nUVal1
      REPLACE field->uval_2 WITH nUVal2
      REPLACE field->uval_3 WITH nUVal3
      REPLACE field->uval_4 WITH nUVal4
      REPLACE field->uvalp WITH nUValP
      // van valute
      REPLACE field->vval_1 WITH nVVal1
      REPLACE field->vval_2 WITH nVVal2
      REPLACE field->vval_3 WITH nVVal3
      REPLACE field->vval_4 WITH nVVal4
      REPLACE field->vvalp WITH nVValP
   ENDIF

   SELECT ( nArr )

   RETURN



// ------------------------------------------
// vraca matricu sa ostav poljima
// cIntervals - da li postoje intervali "DN"
//
// ------------------------------------------
FUNCTION get_ost_fields( cIntervals, nPartLen )

   IF cIntervals == nil
      cIntervals := "N"
   ENDIF

   IF nPartLen == nil
      nPartLen := 6
   ENDIF

   aFields := {}

   AAdd( aFields, { "idpart", "C", nPartLen, 0 } )
   AAdd( aFields, { "p_naz", "C", 40, 0 } )

   IF cIntervals == "D"

      AAdd( aFields, { "UVal_1", "N", 15, 2 } )
      AAdd( aFields, { "UVal_2", "N", 15, 2 } )
      AAdd( aFields, { "UVal_3", "N", 15, 2 } )
      AAdd( aFields, { "UVal_4", "N", 15, 2 } )
      AAdd( aFields, { "UValP", "N", 15, 2 } )
   ENDIF

   AAdd( aFields, { "T_UVal", "N", 15, 2 } )

   IF cIntervals == "D"
      AAdd( aFields, { "VVal_1", "N", 15, 2 } )
      AAdd( aFields, { "VVal_2", "N", 15, 2 } )
      AAdd( aFields, { "VVal_3", "N", 15, 2 } )
      AAdd( aFields, { "VVal_4", "N", 15, 2 } )
      AAdd( aFields, { "VValP", "N", 15, 2 } )
   ENDIF

   AAdd( aFields, { "T_VVal", "N", 15, 2 } )
   AAdd( aFields, { "Total", "N", 15, 2 } )

   RETURN aFields



// -------------------------------
// vraca naz2 iz partnera
// -------------------------------
FUNCTION PN2()
   RETURN ( if( cN2Fin == "D", " " + Trim( PARTN->naz2 ), "" ) )



// ---------------------------------------------
// Rasclanjuje radne jedinice
// ---------------------------------------------
FUNCTION RasclanRJ()

   IF cRasclaniti == "D"
      RETURN cRasclan == suban->( idrj )
      // sasa, 12.02.04
      // return cRasclan==suban->(idrj+funk+fond)
   ELSE
      RETURN .T.
   ENDIF



   // ------------------------------------------
   // prikaz vrijednosti na izvjestaju
   // ------------------------------------------

FUNCTION Pljuc( xVal )

   ? "�"
   ?? xVal
   ?? "�"

   RETURN

// -------------------------------------------
// prikaz vrijednosti na izvjestaju
// -------------------------------------------
FUNCTION PPljuc( xVal )

   ?? xVal
   ?? "�"

   RETURN


// -------------------------------
// ispis rocnosti
// -------------------------------
FUNCTION IspisRoc2( i )

   LOCAL cVrati

   IF i == 1
      cVrati := " DO " + Str( nDoDana1, 3 )
   ELSEIF i == 2
      cVrati := " DO " + Str( nDoDana2, 3 )
   ELSEIF i == 3
      cVrati := " DO " + Str( nDoDana3, 3 )
   ELSEIF i == 4
      cVrati := " DO " + Str( nDoDana4, 3 )
   ELSE
      cVrati := " PR." + Str( nDoDana4, 3 )
   ENDIF

   RETURN cVrati + " DANA"


// -------------------------------------
// ispis rocnosti
// -------------------------------------
FUNCTION RRocnost()

   LOCAL nDana := Abs( IF( Empty( datval ), datdok, datval ) - dNaDan ), nVrati

   IF nDana <= nDoDana1
      nVrati := 1
   ELSEIF nDana <= nDoDana2
      nVrati := 2
   ELSEIF nDana <= nDoDana3
      nVrati := 3
   ELSEIF nDana <= nDoDana4
      nVrati := 4
   ELSE
      nVrati := 5
   ENDIF

   RETURN nVrati


/*! \fn IspisRocnosti()
 *  \brief Ispis rocnosti
 */

FUNCTION IspisRocnosti()

   LOCAL cRocnost := Rocnost(), cVrati

   IF cRocnost == "999"
      cVrati := " PREKO " + Str( nDoDana4, 3 ) + " DANA"
   ELSE
      cVrati := " DO " + cRocnost + " DANA"
   ENDIF

   RETURN cVrati


// --------------------------------
// rocnost
// --------------------------------
FUNCTION Rocnost()

   LOCAL nDana := Abs( IF( Empty( datval ), datdok, datval ) - dNaDan ), cVrati

   IF nDana <= nDoDana1
      cVrati := Str( nDoDana1, 3 )
   ELSEIF nDana <= nDoDana2
      cVrati := Str( nDoDana2, 3 )
   ELSEIF nDana <= nDoDana3
      cVrati := Str( nDoDana3, 3 )
   ELSEIF nDana <= nDoDana4
      cVrati := Str( nDoDana4, 3 )
   ELSE
      cVrati := "999"
   ENDIF

   RETURN cVrati
