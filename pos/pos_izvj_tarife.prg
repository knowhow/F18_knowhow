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


#include "pos.ch"


FUNCTION pos_rekapitulacija_tarifa( aTarife )

   LOCAL nArr
   LOCAL cLine

   ?
   ? "REKAPITULACIJA POREZA PO TARIFAMA"

   nTotOsn := 0
   nTotPPP := 0
   nTotPPU := 0
   nTotPP := 0
   nPDV := 0

   cLine := Replicate( "-", 12 )
   cLine += " "
   cLine += Replicate( "-", 12 )
   cLine += " "
   cLine += Replicate( "-", 12 )

   ASort ( aTarife,,, {| x, y| x[ 1 ] < y[ 1 ] } )

   ? cLine

   ? "Tarifa (Stopa %)"
   ? PadC( "PV bez PDV", 12 ), PadC( "PDV", 12 ), PadC( "PV sa PDV", 12 )

   ? cLine

   nArr := Select()

   FOR nCnt := 1 TO Len( aTarife )
	
      SELECT tarifa
      hseek aTarife[ nCnt ][ 1 ]
      nPDV := tarifa->opp
		
      ? aTarife[ nCnt ][ 1 ], "(" + Str( nPDV ) + "%)"
      ? Str( aTarife[nCnt ][ 2 ], 12, 2 ), Str ( aTarife[nCnt ][ 3 ], 12, 2 ), Str( Round( aTarife[ nCnt ][ 2 ], 2 ) + Round( aTarife[ nCnt ][ 3 ], 2 ), 12, 2 )
      nTotOsn += Round( aTarife[nCnt ][ 2 ], 2 )
      nTotPPP += Round( aTarife[nCnt ][ 3 ], 2 )
   NEXT

   SELECT ( nArr )

   ? cLine
   ? "UKUPNO"
   ? Str( nTotOsn, 12, 2 ), Str( nTotPPP, 12, 2 ), Str( nTotOsn + nTotPPP, 12, 2 )
   ? cLine
   ?

   RETURN NIL




FUNCTION WhilePTarife( cIdRoba, cIdTarifa, nIzn, aTarife, nPPP, nPPU, nOsn, nPP )

   nArr := Select()

   O_TARIFA

   SELECT ( F_TARIFA )
   SEEK cIdTarifa
   SELECT ( nArr )

   nOsn := nIzn / ( tarifa->zpp / 100 + ( 1 + tarifa->opp / 100 ) * ( 1 + tarifa->ppp / 100 ) )
   nPPP := nOsn * tarifa->opp / 100
   nPP := nOsn * tarifa->zpp / 100
   nPPU := ( nOsn + nPPP ) * tarifa->ppp / 100

   nPoz := AScan ( aTarife, {| x| x[ 1 ] == cIdTarifa } )
   IF nPoz == 0
      AAdd ( aTarife, { cIdTarifa, nOsn, nPPP, nPPU, nPP } )
   ELSE
      aTarife[nPoz ][ 2 ] += nOsn
      aTarife[nPoz ][ 3 ] += nPPP
      aTarife[nPoz ][ 4 ] += nPPU
      aTarife[nPoz ][ 5 ] += nPP
   ENDIF

   RETURN NIL
