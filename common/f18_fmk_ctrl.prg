/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


// -----------------------------------------
// provjera podataka za migraciju f18
// -----------------------------------------
FUNCTION fmk_provjera_za_migraciju_f18()

   LOCAL _a_sif := {}
   LOCAL _a_data := {}
   LOCAL _a_ctrl := {}
   LOCAL _chk_sif := .F.
   LOCAL _c_sif := "N"
   LOCAL _c_fin := "D"
   LOCAL _c_kalk := "D"
   LOCAL _c_fakt := "D"
   LOCAL _c_ld := "D"
   LOCAL _c_pdv := "D"
   LOCAL _c_pos := "D"

   Box(, 10, 50 )

   @ m_x + 1, m_y + 2 SAY "Provjeri sifrarnik ?" GET _c_sif VALID _c_sif $ "DN" PICT "@!"
   @ m_x + 2, m_y + 2 SAY "      Provjeri fin ?" GET _c_fin VALID _c_fin $ "DN" PICT "@!"
   @ m_x + 3, m_y + 2 SAY "     Provjeri fakt ?" GET _c_fakt VALID _c_fakt $ "DN" PICT "@!"
   @ m_x + 4, m_y + 2 SAY "     Provjeri kalk ?" GET _c_kalk VALID _c_kalk $ "DN" PICT "@!"
   @ m_x + 5, m_y + 2 SAY "       Provjeri ld ?" GET _c_ld VALID _c_ld $ "DN" PICT "@!"
   @ m_x + 6, m_y + 2 SAY "     Provjeri epdv ?" GET _c_pdv VALID _c_pdv $ "DN" PICT "@!"
   @ m_x + 7, m_y + 2 SAY "      Provjeri pos ?" GET _c_pos VALID _c_pos $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // provjeri sifrarnik
   IF _c_sif == "D"
      f18_sif_data( @_a_sif, @_a_ctrl )
   ENDIF

   // provjeri fin
   IF _c_fin == "D"
      f18_fin_data( @_a_data, @_a_ctrl )
   ENDIF

   // provjeri kalk
   IF _c_kalk == "D"
      f18_kalk_data( @_a_data, @_a_ctrl )
   ENDIF

   // provjeri fakt
   IF _c_fakt == "D"
      f18_fakt_data( @_a_data, @_a_ctrl )
   ENDIF

   // provjeri ld
   IF _c_ld == "D"
      f18_ld_data( @_a_data, @_a_ctrl )
   ENDIF

   // provjeri epdv
   IF _c_pdv == "D"
      f18_epdv_data( @_a_data, @_a_ctrl )
   ENDIF

   // provjeri pos
   IF _c_pos == "D"
      f18_pos_data( @_a_data, @_a_ctrl )
   ENDIF

   // prikazi rezultat testa
   f18_pr_rezultat( _a_ctrl, _a_data, _a_sif )

   RETURN .T.


// -----------------------------------------
// provjera suban, anal, sint
// -----------------------------------------
STATIC FUNCTION f18_fin_data( data, checksum )

   LOCAL _n_c_iznos := 0
   LOCAL _n_c_stavke := 0
   LOCAL _scan

   O_SUBAN

   Box(, 2, 60 )

   SELECT suban
   SET ORDER TO TAG "4"
   GO TOP

   DO WHILE !Eof()

      IF Empty( field->idfirma )
         SKIP
         LOOP
      ENDIF

      _dok := field->idfirma + "-" + field->idvn + "-" + AllTrim( field->brnal )

      @ m_x + 1, m_y + 2 SAY "fin dokument: " + _dok

      // kontrolni broj
      ++ _n_c_stavke
      _n_c_iznos += ( field->iznosbhd )

      SKIP

   ENDDO

   BoxC()

   IF _n_c_stavke > 0
      AAdd( checksum, { "fin data", _n_c_stavke, _n_c_iznos } )
   ENDIF

   RETURN



// -----------------------------------------
// provjera fakt
// -----------------------------------------
STATIC FUNCTION f18_fakt_data( data, checksum )

   LOCAL _n_c_iznos := 0
   LOCAL _n_c_stavke := 0

   O_FAKT

   Box(, 2, 60 )

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      IF Empty( field->idfirma )
         SKIP
         LOOP
      ENDIF

      _dok := field->idfirma + "-" + field->idtipdok + "-" + AllTrim( field->brdok )

      @ m_x + 1, m_y + 2 SAY "fakt dokument: " + _dok

      // kontrolni broj
      ++ _n_c_stavke
      _n_c_iznos += ( field->kolicina + field->cijena + field->rabat )

      SKIP

   ENDDO

   BoxC()

   IF _n_c_stavke > 0
      AAdd( checksum, { "fakt data", _n_c_stavke, _n_c_iznos } )
   ENDIF

   RETURN .T.


// -----------------------------------------
// provjera pos
// -----------------------------------------
STATIC FUNCTION f18_pos_data( data, checksum )

   LOCAL _n_c_iznos := 0
   LOCAL _n_c_stavke := 0
   LOCAL _dok

   o_pos_pos()

   Box(, 2, 60 )

   SELECT pos
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      IF Empty( field->idpos )
         SKIP
         LOOP
      ENDIF

      _dok := field->idpos + "-" + field->idvd + "-" + AllTrim( field->brdok ) + ", " + DToC( field->datum )

      @ m_x + 1, m_y + 2 SAY "pos dokument: " + _dok

      // kontrolni broj
      ++ _n_c_stavke
      _n_c_iznos += ( field->kolicina + field->cijena + field->ncijena )

      SKIP

   ENDDO

   BoxC()

   IF _n_c_stavke > 0
      AAdd( checksum, { "pos data", _n_c_stavke, _n_c_iznos } )
   ENDIF

   RETURN




// -----------------------------------------
// provjera ld
// -----------------------------------------
STATIC FUNCTION f18_ld_data( data, checksum )

   LOCAL _n_c_iznos := 0
   LOCAL _n_c_stavke := 0

   O_LD

   Box(, 2, 60 )

   SELECT ld
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      IF Empty( field->idrj )
         SKIP
         LOOP
      ENDIF

      _dok := field->idrj + ", " + Str( field->godina, 4 ) + ", " + Str( field->mjesec, 2 ) + ", " + field->idradn

      @ m_x + 1, m_y + 2 SAY "ld stavka: " + _dok

      // kontrolni broj
      ++ _n_c_stavke
      _n_c_iznos += ( field->uneto + field->i01 )

      SKIP

   ENDDO

   BoxC()

   IF _n_c_stavke > 0
      AAdd( checksum, { "ld data", _n_c_stavke, _n_c_iznos } )
   ENDIF

   RETURN


// -----------------------------------------
// provjera epdv
// -----------------------------------------
STATIC FUNCTION f18_epdv_data( data, checksum )

   LOCAL _n_c_iznos := 0
   LOCAL _n_c_stavke := 0

   O_KIF
   O_KUF

   Box(, 2, 60 )

   SELECT kuf
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      IF Empty( Str( field->br_dok, 10 ) )
         SKIP
         LOOP
      ENDIF

      _dok := Str( field->br_dok, 10 )

      @ m_x + 1, m_y + 2 SAY "kuf dokument: " + _dok

      // kontrolni broj
      ++ _n_c_stavke
      _n_c_iznos += ( field->i_b_pdv + field->i_pdv )

      SKIP

   ENDDO

   BoxC()

   IF _n_c_stavke > 0
      AAdd( checksum, { "kuf data", _n_c_stavke, _n_c_iznos } )
   ENDIF

   _n_c_stavke := 0
   _n_c_iznos := 0

   Box(, 2, 60 )

   SELECT kif
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      IF Empty( Str( field->br_dok, 10 ) )
         SKIP
         LOOP
      ENDIF

      _dok := Str( field->br_dok, 10 )

      @ m_x + 1, m_y + 2 SAY "kif dokument: " + _dok

      // kontrolni broj
      ++ _n_c_stavke
      _n_c_iznos += ( field->i_b_pdv + field->i_pdv )

      SKIP

   ENDDO

   BoxC()

   IF _n_c_stavke > 0
      AAdd( checksum, { "kif data", _n_c_stavke, _n_c_iznos } )
   ENDIF

   RETURN







// -----------------------------------------
// provjera kalk
// -----------------------------------------
STATIC FUNCTION f18_kalk_data( data, checksum )

   LOCAL _n_c_iznos := 0
   LOCAL _n_c_stavke := 0

   o_kalk()

   Box(, 2, 60 )

   SELECT kalk
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      IF Empty( field->idfirma )
         SKIP
         LOOP
      ENDIF

      _dok := field->idfirma + "-" + field->idvd + "-" + AllTrim( field->brdok )

      @ m_x + 1, m_y + 2 SAY "kalk dokument: " + _dok

      // kontrolni broj
      ++ _n_c_stavke
      _n_c_iznos += ( field->kolicina + field->nc + field->vpc )

      SKIP

   ENDDO

   BoxC()

   IF _n_c_stavke > 0
      AAdd( checksum, { "kalk data", _n_c_stavke, _n_c_iznos } )
   ENDIF

   RETURN






// ------------------------------------------
// prikazi rezultat
// ------------------------------------------
STATIC FUNCTION f18_pr_rezultat( a_ctrl, a_data, a_sif )

   LOCAL i, d, s

   START PRINT CRET
   ?
   P_COND

   ? "F18 rezultati testa:", DToC( Date() )
   ? "================================"
   ?
   ? "1) Kontrolni podaci:"
   ? "-------------- --------------- ---------------"
   ? "objekat        broj zapisa     kontrolni broj"
   ? "-------------- --------------- ---------------"
   // prvo mi ispisi kontrolne zapise
   FOR i := 1 TO Len( a_ctrl )
      ? PadR( a_ctrl[ i, 1 ], 14 )
      @ PRow(), PCol() + 1 SAY Str( a_ctrl[ i, 2 ], 15, 0 )
      @ PRow(), PCol() + 1 SAY Str( a_ctrl[ i, 3 ], 15, 2 )
   NEXT

   ?

   FF
   ENDPRINT

   RETURN .T.


// -----------------------------------------
// provjera sifrarnika
// -----------------------------------------
FUNCTION f18_sif_data( data, checksum )

   O_ROBA
   O_RADN
   O_PARTN
   O_KONTO
   O_TRFP
   O_OPS
   O_VALUTE
   o_koncij()

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   f18_sif_check( @data, @checksum )

   SELECT partn
   SET ORDER TO TAG "ID"
   GO TOP

   f18_sif_check( @data, @checksum )

   SELECT konto
   SET ORDER TO TAG "ID"
   GO TOP

   f18_sif_check( @data, @checksum )

   SELECT ops
   SET ORDER TO TAG "ID"
   GO TOP

   f18_sif_check( @data, @checksum )

   SELECT radn
   SET ORDER TO TAG "ID"
   GO TOP

   f18_sif_check( @data, @checksum )

   RETURN


// ------------------------------------------
// provjera sifrarnika
// ------------------------------------------
STATIC FUNCTION f18_sif_check( data, checksum )

   LOCAL _chk := "x-x"
   LOCAL _scan
   LOCAL _stavke := 0

   DO WHILE !Eof()

      IF Empty( field->id )
         SKIP
         LOOP
      ENDIF

      ++ _stavke

      SKIP

   ENDDO

   IF _stavke > 0
      AAdd( checksum, { "sif. " + Alias(), _stavke, 0 } )
   ENDIF

   RETURN
