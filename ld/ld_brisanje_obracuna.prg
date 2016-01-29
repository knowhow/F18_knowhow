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



FUNCTION ld_brisanje_obr()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. brisanje obračuna za jednog radnika       " )
   AAdd( _opcexe, {|| BrisiRadnika() } )
   AAdd( _opc, "2. brisanje obračuna za jedan mjesec   " )
   AAdd( _opcexe, {|| BrisiMjesec() } )
   AAdd( _opc, "3. totalno brisanje radnika iz evidencije" )
   AAdd( _opcexe, {|| TotBrisRadn() } )

   f18_menu( "bris", .F., _izbor, _opc, _opcexe )

   RETURN


FUNCTION BrisiRadnika()

   LOCAL nTrec
   LOCAL cIdRadn
   LOCAL cMjesec
   LOCAL cIdRj
   LOCAL fnovi
   LOCAL _rec

   nUser := 001
   O_RADN
   O_LD


   lLogBrRadn := .F.


   DO WHILE .T.

      cIdRadn := Space( _LR_ )
      cIdRj := gRj
      cMjesec := gMjesec
      cGodina := gGodina
      cObracun := gObracun

      Box(, 4, 60 )
      @ m_x + 1, m_y + 2 SAY "Radna jedinica: "
      QQOUTC( cIdRJ, "N/W" )
      @ m_x + 2, m_y + 2 SAY "Mjesec: "
      QQOUTC( Str( cMjesec, 2 ), "N/W" )
      @ m_x + 2, Col() + 2 SAY "Obracun: "
      QQOUTC( cObracun, "N/W" )
      @ m_x + 3, m_y + 2 SAY "Godina: "
      QQOUTC( Str( cGodina, 4 ), "N/W" )

      @ m_x + 4, m_y + 2 SAY "Radnik" GET cIdRadn valid {|| cIdRadn $ "XXXXXX" .OR. P_Radn( @cIdRadn ), SetPos( m_x + 2, m_y + 20 ), QQOut( Trim( radn->naz ) + " (" + Trim( radn->imerod ) + ") " + radn->ime ), .T. }

      READ
      ESC_BCR
      BoxC()

      IF cIdRadn <> "XXXXXX"

         O_LD
         SELECT ld
         SEEK Str( cGodina, 4 ) + cIdRj + Str( cMjesec, 2 ) + BrojObracuna() + cIdRadn

         IF Found()

            IF Pitanje(, "Sigurno zelite izbrisati ovaj zapis D/N", "N" ) == "D"

               _rec := dbf_get_rec()
               delete_rec_server_and_dbf( "ld_ld", _rec, 1, "FULL" )

               MsgBeep( "Izbrisan obračun za radnika: " + cIdRadn + "  !!!" )


            ENDIF
         ELSE
            Msg( "Podatak ne postoji...", 4 )
         ENDIF

      ELSE
         SELECT ld
         SET ORDER TO 0
         IF FLock()

            GO TOP

            Postotak( 1, RecCount(), "Ukloni 0 zapise" )

            f18_lock_tables( { "ld_ld" } )
            sql_table_update( nil, "BEGIN" )

            DO WHILE !Eof()

               nPom := 0
               _rec := dbf_get_rec()

               FOR i := 1 TO cLDPolja
                  cPom := PadL( AllTrim( Str( i ) ), 2, "0" )
                  nPom += ( Abs( _i&cPom ) + Abs( _s&cPom ) )
                  // ako su sve nule
               NEXT

               IF ( Round( nPom, 5 ) = 0 )
                  delete_rec_server_and_dbf( "ld_ld", _rec, 1, "CONT" )
               ENDIF

               Postotak( 2, RecNo() )

               SKIP

            ENDDO

            Postotak( 0 )

            f18_free_tables( { "ld_ld" } )
            sql_table_update( nil, "END" )

         ELSE
            MsgBeep( "Neko vec koristi datoteku LD !!!" )
         ENDIF
      ENDIF

      SELECT ld
      USE
   ENDDO

   my_close_all_dbf()

   RETURN



FUNCTION BrisiMjesec()

   LOCAL cMjesec
   LOCAL cIdRj
   LOCAL fnovi
   LOCAL _rec

   nUser := 001

   O_RADN

   lLogBrMjesec := .F.


   DO WHILE .T.

      O_LD

      cIdRadn := Space( _LR_ )
      cIdRj := gRj
      cMjesec := gMjesec
      cGodina := gGodina
      cObracun := gObracun

      Box(, 4, 60 )
      @ m_x + 1, m_y + 2 SAY "Radna jedinica: " GET cIdRJ
      @ m_x + 2, m_y + 2 SAY "Mjesec: "  GET cMjesec PICT "99"
      @ m_x + 2, Col() + 2 SAY "Obracun: " GET cObracun WHEN HelpObr( .F., cObracun ) VALID ValObr( .F., cObracun )
      @ m_x + 3, m_y + 2 SAY "Godina: "  GET cGodina PICT "9999"
      READ
      ClvBox()
      ESC_BCR
      BoxC()

      IF Pitanje(, "Sigurno zelite izbrisati sve podatke za RJ za ovaj mjesec !?", "N" ) == "N"
         my_close_all_dbf()
         RETURN
      ENDIF

      MsgO( "Sacekajte, brisem podatke...." )

      SELECT ld

      SEEK Str( cGodina, 4 ) + cIdRj + Str( cMjesec, 2 ) + BrojObracuna()

      IF Found()

         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "ld_ld", _rec, 2, "FULL" )

      ENDIF

      MsgBeep( "Obracun za " + Str( cMjesec, 2 ) + " mjesec izbrisani !!!" )

      MsgC()
      EXIT

   ENDDO

   my_close_all_dbf()

   RETURN
