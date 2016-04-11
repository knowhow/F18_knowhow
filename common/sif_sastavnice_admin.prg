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


FUNCTION sast_repl_all() // zamjena sastavnice u svim proizvodima

   LOCAL lOk := .T.
   LOCAL cOldS
   LOCAL cNewS
   LOCAL nKolic
   LOCAL _rec

   cOldS := Space( 10 )
   cNewS := Space( 10 )
   nKolic := 0

   Box(, 6, 70 )
   @ m_x + 1, m_y + 2 SAY "'Stara' sirovina :" GET cOldS PICT "@!" VALID P_Roba( @cOldS )
   @ m_x + 2, m_y + 2 SAY "'Nova'  sirovina :" GET cNewS PICT "@!" VALID cNewS <> cOldS .AND. P_Roba( @cNewS )
   @ m_x + 4, m_y + 2 SAY "Kolicina u normama (0 - zamjeni bez obzira na kolicinu)" GET nKolic PICT "999999.99999"
   READ
   BoxC()

   IF ( LastKey() <> K_ESC )

      run_sql_query( "BEGIN" )
      IF !f18_lock_tables( { "sast" }, .T. )
         run_sql_query( "COMMIT" )
         MsgBeep( "Greska sa lock-om tabele sast !" )
         RETURN .F.
      ENDIF

      SELECT sast
      SET ORDER TO
      GO TOP

      DO WHILE !Eof()
         IF id2 == cOldS
            IF ( nKolic = 0 .OR. Round( nKolic - kolicina, 5 ) = 0 )
               _rec := dbf_get_rec()
               _rec[ "id2" ] := cNewS
               lOk := update_rec_server_and_dbf( "sast", _rec, 1, "CONT" )
            ENDIF
         ENDIF
         IF !lOk
            EXIT
         ENDIF
         SKIP
      ENDDO

      IF lOk
         run_sql_query( "COMMIT" )
         f18_unlock_tables( { "sast" } )
      ELSE
         run_sql_query( "ROLLBACK" )
      ENDIF

      SET ORDER TO TAG "idrbr"

   ENDIF

   RETURN .T.


FUNCTION pr_uces_sast() // promjena ucesca

   LOCAL lOk := .T.
   LOCAL cOldS
   LOCAL cNewS
   LOCAL nKolic
   LOCAL nKolic2
   LOCAL _rec

   cOldS := Space( 10 )
   cNewS := Space( 10 )
   nKolic := 0
   nKolic2 := 0

   Box(, 6, 65 )
   @ m_x + 1, m_y + 2 SAY "Sirovina :" GET cOldS PICT "@!" VALID P_Roba( @cOldS )
   @ m_x + 4, m_y + 2 SAY "postojeca kolicina u normama " GET nKolic PICT "999999.99999"
   @ m_x + 5, m_y + 2 SAY "nova kolicina u normama      " GET nKolic2 PICT "999999.99999"   VALID nKolic <> nKolic2
   READ
   BoxC()

   IF ( LastKey() <> K_ESC )

      run_sql_query( "BEGIN" )
      IF !f18_lock_tables( { "sast" }, .T. )
         run_sql_query( "COMMIT" )
         MsgBeep( "Greska sa lock-om tabele sast !" )
         RETURN
      ENDIF

      SELECT sast
      SET ORDER TO
      GO TOP

      DO WHILE !Eof()

         IF PadR( field->id2, 10 ) == PadR( cOldS, 10 )
            IF Round( nKolic - field->kolicina, 5 ) = 0
               _rec := dbf_get_rec()
               _rec[ "kolicina" ] := nKolic2
               lOk := update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )
            ENDIF
         ENDIF

         IF !lOk
            EXIT
         ENDIF

         SKIP

      ENDDO

      IF lOk
         run_sql_query( "COMMIT" )
         f18_unlock_tables( { "sast" } )
      ELSE
         run_sql_query( "ROLLBACK" )
      ENDIF

      SET ORDER TO TAG "idrbr"
   ENDIF

   RETURN .T.
