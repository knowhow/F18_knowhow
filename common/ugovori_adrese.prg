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


FUNCTION kreiraj_adrese_iz_ugovora()

   LOCAL _id_roba, _partner, _ptt, _mjesto
   LOCAL _n_sort, _dat_do, _g_dat
   LOCAL _filter := ""
   LOCAL _index_sort := ""
   LOCAL _rec, _usl_partner, _usl_mjesto, _usl_ptt
   LOCAL _ima_destinacija
   LOCAL _count := 0
   LOCAL _total_kolicina := 0

   PushWA()

   _open_tables()

   _id_roba := PadR( fetch_metric( "ugovori_naljepnice_idroba", my_user(), Space( 10 ) ), 10 )
   _partner := PadR( fetch_metric( "ugovori_naljepnice_partner", my_user(), Space( 300 ) ), 300 )
   _ptt := PadR( fetch_metric( "ugovori_naljepnice_ptt", my_user(), Space( 300 ) ), 300 )
   _mjesto := PadR( fetch_metric( "ugovori_naljepnice_mjesto", my_user(), Space( 300 ) ), 300 )
   _n_sort := fetch_metric( "ugovori_naljepnice_sort", my_user(), "4" )

   _dat_do := Date()
   _g_dat := "N"

   Box(, 15, 77 )

   DO WHILE .T.

      @ m_x + 0, m_y + 5 SAY "POSTAVLJENJE USLOVA ZA PRAVLJENJE LABELA"
      @ m_x + 2, m_y + 2 SAY "Artikal  :" GET _id_roba VALID P_Roba( @_id_roba ) PICT "@!"
      @ m_x + 3, m_y + 2 SAY "Partner  :" GET _partner PICT "@S50!"
      @ m_x + 4, m_y + 2 SAY "Mjesto   :" GET _mjesto PICT "@S50!"
      @ m_x + 5, m_y + 2 SAY "PTT      :" GET _ptt PICT "@S50!"
      @ m_x + 6, m_y + 2 SAY "Gledati tekuci datum (D/N):" GET _g_dat ;
         VALID _g_dat $ "DN" PICT "@!"
      @ m_x + 7, m_y + 2 SAY "**** Nacin sortiranja podataka u pregledu: "
      @ m_x + 8, m_y + 2 SAY " 1 - kolicina + mjesto + naziv"
      @ m_x + 9, m_y + 2 SAY " 2 - mjesto + naziv + kolicina"
      @ m_x + 10, m_y + 2 SAY " 3 - PTT + mjesto + naziv + kolicina"
      @ m_x + 11, m_y + 2 SAY " 4 - kolicina + PTT + mjesto + naziv"
      @ m_x + 12, m_y + 2 SAY " 5 - idpartner"
      @ m_x + 13, m_y + 2 SAY " 6 - kolicina"
      @ m_x + 14, m_y + 2 SAY "odabrana vrijednost:" GET _n_sort VALID _n_sort $ "1234567" PICT "9"
      READ

      IF LastKey() == K_ESC
         BoxC()
         RETURN
      ENDIF

      _usl_partner := Parsiraj( _partner, "IDPARTNER" )
      _usl_ptt  := Parsiraj( _ptt, "PTT"       )
      _usl_mjesto := Parsiraj( _mjesto, "MJESTO" )

      IF _usl_partner <> NIL .AND. _usl_mjesto <> NIL .AND. _usl_ptt <> NIL
         EXIT
      ENDIF

   ENDDO

   BoxC()

   set_metric( "ugovori_naljepnice_idroba", my_user(), _id_roba )
   set_metric( "ugovori_naljepnice_partner", my_user(), AllTrim( _partner ) )
   set_metric( "ugovori_naljepnice_ptt", my_user(), AllTrim( _ptt ) )
   set_metric( "ugovori_naljepnice_mjesto", my_user(), AllTrim( _mjesto ) )
   set_metric( "ugovori_naljepnice_sort", my_user(), _n_sort )

   _index_sort := _index_sort + AllTrim( _n_sort )

   _create_labelu_dbf()

   IF is_dest()
      SELECT dest
      SET FILTER TO
   ENDIF

   SELECT ugov
   SET FILTER TO

   SELECT rugov
   SET FILTER TO

   IF !Empty( _id_roba )
      SET FILTER TO idroba == _id_roba
   ENDIF

   GO TOP

   Box(, 3, 60 )

   DO WHILE !Eof()

      SELECT ugov
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK rugov->id

      @ m_x + 1, m_y + 2 SAY "Ugovor ID: " + PadR( rugov->id, 10 )
      @ m_x + 2, m_y + 2 SAY PadR( "", 60 )
      @ m_x + 3, m_y + 2 SAY PadR( "", 60 )

      IF !Found()
         MsgBeep( "Ugovor " + rugov->id + " ne postoji !!! Preskacem..." )
         SELECT rugov
         SKIP
         LOOP
      ENDIF

      IF field->aktivan == "N"
         SELECT rugov
         SKIP
         LOOP
      ENDIF

      IF field->lab_prn == "N"
         SELECT rugov
         SKIP
         LOOP
      ENDIF

      IF _g_dat == "D" .AND. ( _dat_do > ugov->datdo )
         SELECT rugov
         SKIP
         LOOP
      ENDIF

      IF !Empty( _partner )
         IF !( &_usl_partner )
            SELECT rugov
            SKIP
            LOOP
         ENDIF
      ENDIF

      SELECT partn
      SEEK ugov->idpartner

      IF !Found()
         Msgbeep( "Partner " + ugov->idpartner + " ne postoji, preskacem !!!" )
         SELECT rugov
         SKIP
         LOOP
      ENDIF

      IF !Empty( _ptt )
         IF !( &_usl_ptt )
            SELECT rugov
            SKIP
            LOOP
         ENDIF
      ENDIF

      IF !Empty( _mjesto )
         IF !( &_usl_mjesto )
            SELECT rugov
            SKIP
            LOOP
         ENDIF
      ENDIF

      SELECT labelu
      APPEND BLANK

      _rec := dbf_get_rec()

      _rec[ "idpartner" ] := ugov->idpartner
      _rec[ "kolicina" ] := rugov->kolicina
      _rec[ "idroba" ] := rugov->idroba
      _rec[ "kol_c" ] := PadL( AllTrim( Str( rugov->kolicina, 12, 0 ) ), 5, "0" )

      _total_kolicina += rugov->kolicina

      @ m_x + 2, m_y + 2 SAY "Partner: " + ugov->idpartner

      _ima_destinacija := .F.

      IF is_dest() .AND. !Empty( rugov->dest )

         SELECT dest
         SET ORDER TO TAG "ID"
         GO TOP
         SEEK ( ugov->idpartner + rugov->dest )

         IF Found()
            _ima_destinacija := .T.
         ENDIF

      ENDIF

      SELECT labelu

      IF _ima_destinacija

         _rec[ "destin" ] := dest->id
         _rec[ "naz" ] := dest->naziv
         _rec[ "naz2" ] := dest->naziv2
         _rec[ "ptt" ] := Upper( dest->ptt )
         _rec[ "mjesto" ] := Upper( dest->mjesto )
         _rec[ "telefon" ] := dest->telefon
         _rec[ "fax" ] := dest->fax
         _rec[ "adresa" ] := dest->adresa

      ELSE

         _rec[ "destin" ] := ""
         _rec[ "naz" ] := partn->naz
         _rec[ "naz2" ] := partn->naz2
         _rec[ "ptt" ] := Upper( partn->ptt )
         _rec[ "mjesto" ] := Upper( partn->mjesto )
         _rec[ "telefon" ] := partn->telefon
         _rec[ "fax" ] := partn->fax
         _rec[ "adresa" ] := partn->adresa

      ENDIF

      dbf_update_rec( _rec )

      @ m_x + 3, m_y + 2 SAY "Ukupno prebaceno: " + AllTrim( Str( ++_count ) )

      SELECT rugov
      SKIP

   ENDDO

   BoxC()

   IF _count == 0
      MsgBeep( "Nema generisanih adresa !!!" )
      SELECT ugov
      RETURN
   ENDIF

   label_to_lab2( _index_sort )

   MsgBeep( "Ukupno generisano " + AllTrim( Str( _count ) ) + ;
      " naljepnica, kolicina: " + AllTrim( Str( _total_kolicina, 12, 0 ) ) )

   stampa_pregleda_naljepnica( _index_sort )

   f18_rtm_print( "labelu", "lab2", "1", NIL, "labeliranje" )

   _open_tables()

   PopWA()

   RETURN


STATIC FUNCTION label_to_lab2( index_sort )

   LOCAL _rec
   LOCAL _count := 0

   SELECT labelu
   SET ORDER TO tag &index_sort
   GO TOP

   DO WHILE !Eof()

      _rec := dbf_get_rec()

      SELECT lab2
      APPEND BLANK

      _rec[ "idx" ] := ++_count

      dbf_update_rec( _rec )

      SELECT labelu
      SKIP

   ENDDO

   SELECT lab2
   USE

   RETURN .T.



STATIC FUNCTION stampa_pregleda_naljepnica( index_sort )

   LOCAL _table_type := 1
   PRIVATE _index := index_sort

   SELECT labelu
   SET ORDER TO tag &_index
   GO TOP

   aKol := {}

   AAdd( aKol, { "Artikal", {|| IDROBA       }, .F., "C", 10, 0, 1, 1 } )
   AAdd( aKol, { "Partner", {|| IdPartner    }, .F., "C",  6, 0, 1, 2 } )
   AAdd( aKol, { "Dest.", {|| Destin       }, .F., "C",  6, 0, 1, 3 } )
   AAdd( aKol, { "Kolicina", {|| Kolicina     }, .T., "N", 12, 0, 1, 4 } )
   AAdd( aKol, { "PTT", {|| PTT          }, .F., "C",  5, 0, 1, 5 } )
   AAdd( aKol, { "Mjesto", {|| MJESTO       }, .F., "C", 16, 0, 1, 6 } )
   AAdd( aKol, { "Naziv", {|| PadR( AllTrim( naz ) + ", " + AllTrim( naz2 ), 60 ) }, .F., "C", 60, 0, 1, 7 } )
   AAdd( aKol, { "Adresa", {|| ADRESA       }, .F., "C", 40, 0, 1, 8 } )
   AAdd( aKol, { "Telefon", {|| TELEFON      }, .F., "C", 12, 0, 1, 9 } )
   AAdd( aKol, { "Fax", {|| FAX          }, .F., "C", 12, 0, 1, 10 } )

   START PRINT CRET

   StampaTabele( aKol, NIL, NIL, _table_type, NIL, NIL, "PREGLED BAZE PRIPREMLJENIH NALJEPNICA", , , , , )

   ENDPRINT

   my_close_all_dbf()

   RETURN


STATIC FUNCTION _open_tables()

   O_UGOV
   O_RUGOV
   O_DEST
   O_PARTN
   O_ROBA
   O_SIFK
   O_SIFV

   SELECT ugov

   RETURN



STATIC FUNCTION _create_labelu_dbf()

   LOCAL _dbf := {}
   LOCAL _table_label := "labelu"
   LOCAL _table_label_2 := "lab2"

   AAdd ( _dbf, { "idroba",    "C",     10, 0 } )
   AAdd ( _dbf, { "idpartner", "C",      6, 0 } )
   AAdd ( _dbf, { "destin",  "C",      6, 0 } )
   AAdd ( _dbf, { "kol_c",     "C",      5, 0 } )
   AAdd ( _dbf, { "naz",      "C",     50, 0 } )
   AAdd ( _dbf, { "naz2",      "C",     50, 0 } )
   AAdd ( _dbf, { "ptt",      "C",    10, 0 } )
   AAdd ( _dbf, { "mjesto",   "C",    20, 0 } )
   AAdd ( _dbf, { "adresa",   "C",    50, 0 } )
   AAdd ( _dbf, { "telefon",   "C",    20, 0 } )
   AAdd ( _dbf, { "fax",   "C",    20, 0 } )
   AAdd ( _dbf, { "kolicina",  "N",     12, 0 } )
   AAdd ( _dbf, { "idx",       "N",     12, 0 } )

   SELECT ( F_LABELU )
   USE

   FErase( my_home() + _table_label + ".dbf" )
   FErase( my_home() + _table_label + ".cdx" )

   dbCreate( my_home() + _table_label + ".dbf", _dbf )

   SELECT ( F_LABELU )
   USE
   my_use_temp( "labelu", my_home() + _table_label + ".dbf", .F., .F. )

   INDEX on ( kol_c + mjesto + naz ) TAG "1"
   INDEX on ( mjesto + naz + kol_c ) TAG "2"
   INDEX on ( ptt + mjesto + naz + kol_c ) TAG "3"
   INDEX on ( kol_c + ptt + mjesto + naz ) TAG "4"
   INDEX on ( idpartner ) TAG "5"
   INDEX on ( kol_c ) TAG "6"

   FErase( my_home() + _table_label_2 + ".dbf" )
   FErase( my_home() + _table_label_2 + ".cdx" )

   SELECT ( F_LABELU2 )
   USE

   dbCreate( my_home() + _table_label_2 + ".dbf", _dbf )

   SELECT ( F_LABELU2 )
   USE
   my_use_temp( "lab2", my_home() + _table_label_2 + ".dbf", .F., .F. )

   INDEX on ( Str( idx, 12, 0 ) ) TAG "1"

   RETURN


