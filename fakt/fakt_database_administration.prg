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


#include "fakt.ch"


FUNCTION fakt_admin_menu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. podesavanje brojaca dokumenta " )
   AAdd( _opcexe, {|| fakt_set_param_broj_dokumenta() } )
   AAdd( _opc, "2. fakt export (r_exp) " )
   AAdd( _opcexe, {|| fkt_export() } )

   f18_menu( "fain", .F., _izbor, _opc, _opcexe )

   RETURN



// -------------------------------------------------
// ispravka podataka dokumenta
// -------------------------------------------------
FUNCTION fakt_edit_data( id_firma, tip_dok, br_dok )

   LOCAL _t_area := Select()
   LOCAL _ret := .F.
   LOCAL _x := 1
   LOCAL _cnt
   LOCAL __idpartn
   LOCAL __br_otpr
   LOCAL __br_nar
   LOCAL __dat_otpr
   LOCAL __dat_pl
   LOCAL __txt
   LOCAL __id_vrsta_p
   LOCAL __p_tmp
   LOCAL _t_txt

   __idpartn := field->idpartner
   __id_vrsta_p := field->idvrstep

   SELECT ( F_FAKT )
   IF !Used()
      O_FAKT
   ENDIF

   SELECT ( F_PARTN )
   IF !Used()
      O_PARTN
   ENDIF

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + tip_dok + br_dok

   IF !Found()
      SELECT ( _t_area )
      RETURN _ret
   ENDIF

   _t_txt := parsmemo( field->txt )

   __br_otpr := _t_txt[ 6 ]
   __br_nar := _t_txt[ 8 ]
   __dat_otpr := CToD( _t_txt[ 7 ] )
   __dat_pl := CToD( _t_txt[ 9 ] )

   Box(, 12, 65 )

   @ m_x + _x, m_y + 2 SAY "*** korekcija podataka dokumenta"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Partner:" GET __idpartn ;
      VALID p_firma( @__idpartn )

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Datum otpremnice:" GET __dat_otpr

   ++ _x
   @ m_x + _x, m_y + 2 SAY " Broj otpremnice:" GET __br_otpr PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "  Datum placanja:" GET __dat_pl

   ++ _x
   @ m_x + _x, m_y + 2 SAY "        Narudzba:" GET __br_nar PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "  Vrsta placanja:" GET __id_vrsta_p VALID Empty( __id_vrsta_p ) .OR. P_VRSTEP( @__id_vrsta_p )


   READ

   BoxC()

   IF LastKey() == K_ESC
      SELECT ( _t_area )
      RETURN _ret
   ENDIF

   IF Pitanje(, "Izvrsiti zamjenu podataka ? (D/N)", "D" ) == "N"
      SELECT ( _t_area )
      RETURN _ret
   ENDIF

   IF !f18_lock_tables( { "fakt_fakt", "fakt_doks" } )
      MsgBeep( "Problem sa lokovanjem tabela !!!" )
      SELECT ( _t_area )
      RETURN _ret
   ENDIF

   sql_table_update( nil, "BEGIN" )

   // mjenjamo podatke
   _ret := .T.

   // pronadji nam partnera
   SELECT partn
   SEEK __idpartn

   __p_tmp := AllTrim( field->naz ) + ;
      "," + AllTrim( field->ptt ) + ;
      " " + AllTrim( field->mjesto )

   // vrati se na doks
   SELECT fakt_doks
   SEEK id_firma + tip_dok + br_dok

   IF !Found()
      msgbeep( "Nisam nista promjenio !!!" )
      RETURN .F.
   ENDIF

   // napravi zamjenu u doks tabeli
   _rec := dbf_get_rec()
   _rec[ "idpartner" ] := __idpartn
   _rec[ "partner" ] := __p_tmp
   _rec[ "idvrstep" ] := __id_vrsta_p

   update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )

   // prodji kroz fakt stavke
   SELECT fakt
   GO TOP
   SEEK id_firma + tip_dok + br_dok

   _cnt := 1

   DO WHILE !Eof() .AND. field->idfirma == id_firma ;
         .AND. field->idtipdok == tip_dok ;
         .AND. field->brdok == br_dok

      _rec := dbf_get_rec()
      _rec[ "idpartner" ] := __idpartn
      _rec[ "idvrstep" ] := __id_vrsta_p

      IF _cnt == 1

         // roba tip U
         __txt := Chr( 16 ) + _t_txt[ 1 ] + Chr( 17 )
         // dodatni tekst fakture
         __txt += Chr( 16 ) + _t_txt[ 2 ] + Chr( 17 )
         // naziv partnera
         __txt += Chr( 16 ) + AllTrim( partn->naz ) + Chr( 17 )
         // partner 2 podaci
         __txt += Chr( 16 ) + AllTrim( partn->adresa ) + ", Tel:" + AllTrim( partn->telefon ) + Chr( 17 )
         // partner 3 podaci
         __txt += Chr( 16 ) + AllTrim( partn->ptt ) + " " + AllTrim( partn->mjesto ) + Chr( 17 )
         // broj otpremnice
         __txt += Chr( 16 ) + __br_otpr + Chr( 17 )
         // datum otpremnice
         __txt += Chr( 16 ) + DToC( __dat_otpr ) + Chr( 17 )
         // broj narudzbenice
         __txt += Chr( 16 ) + __br_nar + Chr( 17 )
         // datum placanja
         __txt += Chr( 16 ) + DToC( __dat_pl ) + Chr( 17 )

         IF Len( _t_txt ) > 9
            FOR _i := 10 TO Len( _t_txt )
               __txt += Chr( 16 ) + _t_txt[ _i ] + Chr( 17 )
            NEXT
         ENDIF

         _rec[ "txt" ] := __txt

      ENDIF

      update_rec_server_and_dbf( "fakt_fakt", _rec, 1, "CONT" )

      ++ _cnt

      SKIP

   ENDDO

   sql_table_update( nil, "END" )
   f18_free_tables( { "fakt_fakt", "fakt_doks" } )

   SELECT ( _t_area )

   RETURN _ret

