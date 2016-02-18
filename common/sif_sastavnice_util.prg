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

MEMVAR m_x, m_y

FUNCTION copy_sast()

   LOCAL lOk := .T.
   LOCAL nTRobaRec
   LOCAL cNoviProizvod
   LOCAL cIdTek
   LOCAL nTRec
   LOCAL nCnt := 0
   LOCAL _rec

   nTRobaRec := RecNo()

   IF Pitanje(, "Kopirati postojeće sastavnice u novi proizvod", "N" ) == "D"

      cNoviProizvod := Space( 10 )
      cIdTek := field->id

      Box(, 2, 60 )
      @ m_x + 1, m_y + 2 SAY "Kopirati u proizvod:" GET cNoviProizvod VALID cNoviProizvod <> cIdTek .AND. p_roba( @cNoviProizvod ) .AND. roba->tip == "P"
      READ
      BoxC()

      IF ( LastKey() <> K_ESC )

         sql_table_update( nil, "BEGIN" )
         IF !f18_lock_tables( { "sast" }, .T. )
            sql_table_update( nil, "END" )
            MsgBeep( "lock sast neuspjesno !" )
            RETURN .F.
         ENDIF

         SELECT sast
         SET ORDER TO TAG "idrbr"
         SEEK cIdTek
         nCnt := 0


         DO WHILE !Eof() .AND. ( id == cIdTek )
            ++ nCnt
            nTRec := RecNo()
            _rec := dbf_get_rec()
            _rec[ "id" ] := cNoviProizvod
            APPEND BLANK

            lOk := update_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

            IF !lOk
               EXIT
            ENDIF

            GO ( nTrec )
            SKIP

         ENDDO

         IF lOk
            f18_free_tables( { "sast" } )
            sql_table_update( nil, "END" )
         ELSE
            sql_table_update( nil, "ROLLBACK" )
         ENDIF

         SELECT roba
         SET ORDER TO TAG "idun"

      ENDIF
   ENDIF

   GO ( nTrobaRec )

   IF ( nCnt > 0 )
      MsgBeep( "Kopirano sastavnica: " + AllTrim( Str( nCnt ) ) )
   ELSE
      MsgBeep( "Ne postoje sastavnice na uzorku za kopiranje!" )
   ENDIF

   RETURN .T.



FUNCTION bris_sast()

   LOCAL lOk := .T.
   LOCAL _d_n
   LOCAL _t_rec
   LOCAL _rec

   _d_n := "0"

   Box(, 5, 40 )
   @ m_x + 1, m_Y + 2 SAY8 "Odaberite željenu opciju:"
   @ m_x + 3, m_Y + 2 SAY8 "0. Ništa !"
   @ m_x + 4, m_Y + 2 SAY "1. Izbrisati samo sastavnice ?"
   @ m_x + 5, m_Y + 2 SAY "2. Izbrisati i artikle i sastavnice "
   @ m_x + 5, Col() + 2 GET _d_n VALID _d_n $ "012"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN 7
   ENDIF

   sql_table_update( nil, "BEGIN" )
   IF !f18_lock_tables( { "roba", "sast" }, .T. )
      sql_table_update( nil, "END" )
      MsgBeep( "lock roba, sast neuspjeno !" )
      RETURN 7
   ENDIF .T.


   IF _d_n $ "12" .AND. Pitanje(, "Sigurno želite izbrisati definisane sastavnice (D/N) ?", "N" ) == "D"

      SELECT sast
      DO WHILE !Eof()
         SKIP 1
         _t_rec := RecNo()
         SKIP -1
         _rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )
         IF !lOk
            EXIT
         ENDIF
         GO ( _t_rec )
      ENDDO

   ENDIF

   IF lOk .AND. _d_n $ "2" .AND. Pitanje(, "Sigurno želite izbrisati proizvode (D/N) ?", "N" ) == "D"

      SELECT roba

      DO WHILE !Eof()
         SKIP
         _t_rec := RecNo()
         SKIP -1

         _rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( Alias(), _rec, 1, "CONT" )

         IF !lOk
            EXIT
         ENDIF

         GO ( _t_rec )

      ENDDO

   ENDIF

   IF lOk
      f18_free_tables( { "roba", "sast" } )
      sql_table_update( nil, "END" )
   ELSE
      sql_table_update( nil, "ROLLBACK" )
   ENDIF

   RETURN .T.


FUNCTION show_sast()

   LOCAL nTRobaRec
   PRIVATE cIdTek
   PRIVATE ImeKol
   PRIVATE Kol

   // roba->id
   cIdTek := field->id
   nTRobaRec := RecNo()

   SELECT sast
   SET ORDER TO TAG "idrbr"
   SET FILTER TO field->id == cIdTek
   GO TOP

   // setuj kolone sastavnice tabele
   sast_a_kol( @ImeKol, @Kolm )

   PostojiSifra( F_SAST, "IDRBR", MAXROWS() - 18, 80, cIdTek + "-" + Left( roba->naz, 40 ),,,, {| Char| EdSastBlok( Char ) },,,, .F. )

   // ukini filter
   SET FILTER TO

   SELECT roba
   SET ORDER TO TAG "idun"

   GO nTrobaRec

   RETURN .T.
