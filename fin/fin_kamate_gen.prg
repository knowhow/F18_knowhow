/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


// ------------------------------------------
// prenos podataka iz fin u kam
// ------------------------------------------
FUNCTION prenos_fin_kam()

   LOCAL _id_konto := PadR( "2110", 7 )
   LOCAL _dat_obr := Date()
   LOCAL _limit_dana := 0
   LOCAL _zatvorene := "D"
   LOCAL _dodaj_dana := 30
   LOCAL _partneri := Space( 100 )
   LOCAL _usl, _rec
   LOCAL _filter := ""

   O_KAM_PRIPR
   O_KONTO
   O_PARTN

   Box( "#PRENOS RACUNA ZA OBRACUN FIN->KAM", 8, 65 )

   @ m_x + 1, m_y + 2 SAY "Konto:         " GET _id_konto VALID P_Konto( @_id_konto )
   @ m_x + 2, m_y + 2 SAY "Datum obracuna:" GET _dat_obr
   @ m_x + 3, m_y + 2 SAY "Uzeti u obzir samo racune cije je"
   @ m_x + 4, m_y + 2 SAY "valutiranje starije od (br.dana)" GET _limit_dana PICT "9999999"
   @ m_x + 5, m_y + 2 SAY "Uzeti u obzir stavke koje su zatvorene? (D/N)" GET _zatvorene PICT "@!" VALID _zatvorene $ "DN"
   @ m_x + 6, m_y + 2 SAY "Ukoliko nije naveden datum valutiranja"
   @ m_x + 7, m_y + 2 SAY "na datum dokumenta dodaj (br.dana)    " GET _dodaj_dana PICT "99"
   @ m_x + 8, m_y + 2 SAY "Partneri" GET _partneri PICT "@!S50"

   DO WHILE .T.

      READ
      ESC_BCR

      _usl := Parsiraj( _partneri, "IdPartner", "C" )

      IF _usl <> NIL
         EXIT
      ENDIF

   ENDDO

   BoxC()

   o_suban()

   IF !Empty( _usl )
      _filter := _usl
      SET FILTER to &_filter
   ELSE
      SET FILTER TO
   ENDIF

   find_suban_by_konto_partner( gFirma, _id_konto )

   DO WHILE !Eof() .AND. field->idkonto == _id_konto .AND. field->idfirma == gFirma

      _id_partner := field->idpartner
      // osnovni dug
      _osn_dug := 0

      DO WHILE !Eof() .AND. field->idkonto == _id_konto .AND. field->idpartner == _id_partner .AND. field->idfirma == gFirma

         _br_dok := field->brdok

         _duguje := 0
         _potrazuje := 0
         _dat_pocetka := CToD( "" )

         _tmp := "XYZYXYYXXX"

         DO WHILE !Eof() .AND. field->idkonto == _id_konto .AND. field->idpartner == _id_partner ;
               .AND. field->brdok == _br_dok  .AND. field->idfirma == gFirma

            IF field->brdok == _tmp .OR. field->datdok > _dat_obr
               SKIP
               LOOP
            ENDIF

            IF field->otvst = "9" .AND. _zatvorene == "N"
               // samo otvorene stavke
               IF field->d_p == "1"
                  _osn_dug += field->iznosbhd
               ELSE
                  _osn_dug -= field->iznosbhd
               ENDIF
               SKIP
               LOOP
            ENDIF

            IF field->d_p == "1"

               IF Empty( _dat_pocetka )
                  IF Empty( fix_dat_var( field->datval, .T. ) )
                     _dat_pocetka := field->datdok + _dodaj_dana
                  ELSE
                     // datum valutiranja
                     _dat_pocetka := fix_dat_var( field->datval, .T. )
                  ENDIF
               ENDIF

               _duguje += field->iznosbhd
               _osn_dug += field->iznosbhd

            ELSE

               IF !Empty( _dat_pocetka )
                  // vec je nastalo dugovanje!!
                  _dat_pocetka := field->datdok
               ENDIF

               _potrazuje += field->iznosbhd
               _osn_dug -= field->iznosbhd

            ENDIF

            IF !Empty( _dat_pocetka )

               SELECT kam_pripr

               IF ( field->idpartner + field->idkonto + field->brdok == _id_partner + _id_konto + _br_dok )
                  // vec postoji prosli dio racuna
                  // njega zatvori sa
                  // predhodnim danom
                  IF field->datod >= _dat_pocetka
                     // slijedeca promjena na isti datum
                     RREPLACE field->osnovica WITH field->osnovica + suban->( iif( d_p == "1", iznosbhd, -iznosbhd ) )
                     SELECT suban
                     SKIP
                     LOOP
                  ELSE
                     RREPLACE field->datdo WITH _dat_pocetka - 1
                  ENDIF
               ENDIF

               IF ( field->idpartner + field->idkonto + field->brdok <> _id_partner + _id_konto + _br_dok ) ;
                     .AND. ( _dat_obr - _limit_dana < _dat_pocetka )
                  // onda ne pohranjuj
                  _tmp := _br_dok
               ELSE

                  APPEND BLANK
                  RREPLACE idpartner WITH _id_partner, idkonto WITH _id_konto, osnovica WITH _duguje - _potrazuje, brdok WITH _br_dok, datod WITH _dat_pocetka, datdo WITH _dat_obr
               ENDIF
            ENDIF

            SELECT suban
            SKIP

         ENDDO

      ENDDO

      SELECT kam_pripr
      _t_rec := RecNo()
      SEEK _id_partner

      my_flock()

      DO WHILE !Eof() .AND. _id_partner == field->idpartner
         REPLACE field->osndug WITH _osn_dug
         // nafiluj osnovni dug
         SKIP
      ENDDO

      my_unlock()

      GO _t_rec
      SELECT suban

   ENDDO

   SELECT kam_pripr
   SET ORDER TO TAG "1"
   GO TOP

   _tmp := "XYZXYZSC"

   DO WHILE !Eof()
      SKIP
      _t_rec := RecNo()
      SKIP -1
      IF field->datod <= field->datdo .AND. _tmp == field->brdok .AND. field->osndug = 0
         // ako se radi o zadnjoj uplati vec postojeceg racuna
         // ne brisi !
         SKIP
         LOOP
      ENDIF

      IF field->datod >= field->datdo .OR. field->osndug <= 0
         my_delete()
      ELSE
         _tmp := field->brdok
      ENDIF

      GO _t_rec

   ENDDO

   GO TOP

   my_dbf_pack()

   my_close_all_dbf()

   RETURN
