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


FUNCTION InRange( xVar, xPoc, xKraj )

   IF ValType( xVar ) == "D"
      xPoc = CToD( xPoc )
      xKraj := CToD( xKraj )
   ENDIF

   RETURN ( xVar >= xPoc  .AND. xVar <= xKraj )


FUNCTION DInRange( dDat, d1, d2 )
   RETURN  ( dDat >= d1 .AND. dDat <= d2 )



FUNCTION GMJD( nBrdana )

   LOCAL ostatak
   LOCAL godina
   LOCAL mjeseci
   LOCAL dana

   godina := ( nBrDana / 365.125 )
   ostatak := nBrDana % 365.125
   mjeseci := ( ostatak / 30.41 )
   ostatak := ostatak % 30.41
   dana := Round( ostatak, 0 )
   godina := Int( godina )
   mjeseci := Int( mjeseci )

   IF dana == 30
      dana := 0
      mjeseci ++
   ENDIF

   IF mjeseci == 13
      mjeseci := 0
      godina ++
   ENDIF

   RETURN { godina, mjeseci, dana }



FUNCTION GMJD2N( god, mj, dana )
   RETURN ( god * 365.125 ) + ( mj * 30.41 ) + dana


// datum1 - manji datum, datum2 - ve}i datum
FUNCTION GMJD2( dDat1, dDat2 )
   RETURN { Year( dDat1 ) -Year( dDat2 ), Month( dDat1 ) -Month( dDat2 ),  Day( dDat1 ) -Day( dDat2 ) }


FUNCTION ADDGMJD( aRE, aRB )

   LOCAL nPom
   LOCAL aRU := { 0, 0, 0 }

   nPom := aRE[ 3 ] + aRB[ 3 ]

   IF nPom > 30
      aRU[ 3 ] := nPom % 30 // dana
      aRU[ 2 ] += Int( nPom / 30 )
   ELSE
      aRU[ 3 ] := nPom
   ENDIF

   aRU[ 2 ] += aRE[ 2 ] + aRB[ 2 ]

   IF aRU[ 2 ] > 11
      aRU[ 1 ] += Int( aRu[ 2 ] / 12 )
      aRU[ 2 ] := aRU[ 2 ] % 12
   ENDIF

   aRU[ 1 ] += aRE[ 1 ] + aRB[ 1 ]

   RETURN aRU



// konverzija datuma u string
FUNCTION date_to_str( date, format )

   IF format == NIL
      RETURN DToC( date )
   ENDIF

   IF DToC( date ) == DToC( CToD( "" ) )
      RETURN PadR( "0", Len( format ), "0" )
   ENDIF

   format := StrTran( format, "GGGG", AllTrim( Str( Year( date ) ) ) )
   format := StrTran( format, "GG", Right( AllTrim( Str( Year( date ) ) ), 2 ) )
   format := StrTran( format, "MM", PadL( AllTrim( Str( Month( date ) ) ), 2, "0" ) )
   format := StrTran( format, "DD", PadL( AllTrim( Str( Day( date ) ) ), 2, "0" ) )

   RETURN FORMAT
