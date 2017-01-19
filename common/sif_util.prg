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



FUNCTION sif_ispisi_naziv( nDbf, dx, dy )

   LOCAL cTmp  := ""

   IF ( nDbf )->( FieldPos( "naz" ) ) <> 0
      cTmp := Trim( ( nDbf )->naz  )
   ENDIF

   IF ( nDbf )->( FieldPos( "naziv" ) ) <> 0
      cTmp := Trim( ( nDbf )->naziv  )
   ENDIF

   //IF ( nDbf )->( rddName() ) == "SQLMIX" // sql data utf-8
      //cTmp := _u( cTmp )
   //ENDIF

   IF dx <> NIL .AND. dy <> nil

      IF ( nDbf )->( FieldPos( "naz" ) ) <> 0
         @ m_x + dx, m_y + dy SAY PadR( cTmp, 70 - dy )
      ENDIF

      IF ( nDbf )->( FieldPos( "naziv" ) ) <> 0
         @ m_x + dx, m_y + dy SAY PadR( cTmp, 70 - dy )
      ENDIF

   ELSEIF dx <> NIL .AND. dx > 0 .AND. dx < 25
      CentrTxt( cTmp, dx )
   ENDIF

   RETURN .T.


FUNCTION sifk_fill_ImeKol( cDbf, ImeKol, Kol )

   LOCAL _rec, _recs, ii

   use_sql_sifk( cDbf, NIL )
   use_sql_sifv()

   cDbf := PADR( cDbf, SIFK_LEN_DBF )

   SELECT sifk
   _recs := {}
   GO TOP
   DO WHILE !Eof() .AND. field->ID == cDbf
      _rec := dbf_get_rec()
      IF _rec[ "edkolona" ] == NIL
         _rec[ "edkolona" ] := 0
      ENDIF
      AAdd( _recs, _rec )
      SKIP
   ENDDO

   FOR EACH _rec in _recs

      AAdd ( ImeKol, {  get_sifk_naz( cDbf, _rec[ "oznaka" ] ) } )
      AAdd ( ImeKol[ Len( ImeKol ) ], &( "{|| ToStr( IzSifkPartn('" + _rec[ "oznaka" ] + "')) }" ) )
      AAdd ( ImeKol[ Len( ImeKol ) ], "SIFK->" + _rec[ "oznaka" ] )

      IF _rec[ "edkolona" ] > 0
         FOR ii := 4 TO 9
            AAdd( ImeKol[ Len( ImeKol ) ], NIL  )
         NEXT
         AAdd( ImeKol[ Len( ImeKol ) ], _rec[ "edkolona" ]  )
      ELSE
         FOR ii := 4 TO 10
            AAdd( ImeKol[ Len( ImeKol ) ], NIL  )
         NEXT
      ENDIF

      // postavi PICT za brojeve
      IF _rec[ "tip" ] == "N"
         IF f_decimal > 0
            ImeKol[ Len( ImeKol ), 7 ] := Replicate( "9", _rec[ "duzina" ] - _rec[ "f_decimal" ] -1 ) + "." + Replicate( "9", _rec[ "f_decimal" ] )
         ELSE
            ImeKol[ Len( ImeKol ), 7 ] := Replicate( "9", _rec[ "duzina" ] )
         ENDIF
      ENDIF

      AAdd  ( Kol, iif( _rec[ "ubrowsu" ] == '1', ++i, 0 ) )

   NEXT

   RETURN .T.
