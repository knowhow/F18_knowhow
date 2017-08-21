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

STATIC picBHD
STATIC picDEM



STATIC FUNCTION _get_vars( vars )

   LOCAL _id_firma := self_organizacija_id()
   LOCAL _dat_od := CToD( "" )
   LOCAL _dat_do := CToD( "" )
   LOCAL cIdKonto := PadR( "", 7 )
   LOCAL cIdKonto2 := PadR( "", 7 )
   LOCAL cIdPartner := PadR( "", 6 )
   LOCAL _sa_datumom := "D"
   LOCAL cSabratiPoBrojevimaVeze := "D"
   LOCAL _prelom := "N"
   LOCAL _x := 1
   LOCAL _ret := .T.
   LOCAL GetList := {}

   cIdKonto := fetch_metric( "fin_komen_konto", my_user(), cIdKonto )
   cIdKonto2 := fetch_metric( "fin_komen_konto_2", my_user(), cIdKonto2 )
   cIdPartner := fetch_metric( "fin_komen_partn", my_user(), cIdPartner )
   _dat_od := fetch_metric( "fin_komen_datum_od", my_user(), _dat_od )
   _dat_do := fetch_metric( "fin_komen_datum_do", my_user(), _dat_do )
   cSabratiPoBrojevimaVeze := fetch_metric( "fin_komen_po_vezi", my_user(), cSabratiPoBrojevimaVeze )
   _prelom := fetch_metric( "fin_komen_prelomljeno", my_user(), _prelom )
   _sa_datumom := fetch_metric( "fin_komen_br_racuna_sa_datumom", my_user(), _sa_datumom )

   Box( "", 18, 65 )

   SET CURSOR ON

   @ box_x_koord() + _x, box_y_koord() + 2 SAY 'KREIRANJE OBRASCA "IZJAVA O KOMPENZACIJI"'

   _x := _x + 4

   DO WHILE .T.

      IF gNW == "D"
         @ box_x_koord() + _x, box_y_koord() + 2 SAY "Firma "
         ?? self_organizacija_id(), "-", PadR( self_organizacija_naziv(), 30 )
      ELSE
         @ box_x_koord() + _x, box_y_koord() + 2 SAY "Firma: " GET _id_firma VALID {|| p_partner( @_id_firma ), _id_firma := Left( _id_firma, 2 ), .T. }
      ENDIF

      ++_x
      @ box_x_koord() + _x, box_y_koord() + 2 SAY "Konto duguje   " GET cIdKonto  VALID p_konto( @cIdKonto )
      ++_x
      @ box_x_koord() + _x, box_y_koord() + 2 SAY8 "Konto potražuje" GET cIdKonto2  VALID p_konto( @cIdKonto2 ) .AND. cIdKonto2 > cIdKonto
      ++_x
      @ box_x_koord() + _x, box_y_koord() + 2 SAY8 "Partner-dužnik " GET cIdPartner VALID p_partner( @cIdPartner )  PICT "@!"
      ++_x
      @ box_x_koord() + _x, box_y_koord() + 2 SAY8 "Datum dokumenta od:" GET _dat_od
      @ box_x_koord() + _x, Col() + 2 SAY "do" GET _dat_do   VALID _dat_od <= _dat_do

      ++_x
      ++_x

      @ box_x_koord() + _x, box_y_koord() + 2 SAY "Sabrati po brojevima veze D/N ?"  GET cSabratiPoBrojevimaVeze VALID cSabratiPoBrojevimaVeze $ "DN" PICT "@!"
      @ box_x_koord() + _x, Col() + 2 SAY "Prikaz prebijenog stanja " GET _prelom VALID _prelom $ "DN" PICT "@!"

      ++_x

      @ box_x_koord() + _x, box_y_koord() + 2 SAY8 "Prikaz datuma sa brojem računa (D/N) ?"  GET _sa_datumom VALID _sa_datumom $ "DN" PICT "@!"

      READ
      ESC_BCR

      EXIT

   ENDDO

   BoxC()

   IF LastKey() == K_ESC
      _ret := .F.
      RETURN _ret
   ENDIF

   set_metric( "fin_komen_konto", my_user(), cIdKonto )
   set_metric( "fin_komen_konto_2", my_user(), cIdKonto2 )
   set_metric( "fin_komen_partn", my_user(), cIdPartner )
   set_metric( "fin_komen_datum_od", my_user(), _dat_od )
   set_metric( "fin_komen_datum_do", my_user(), _dat_do )
   set_metric( "fin_komen_po_vezi", my_user(), cSabratiPoBrojevimaVeze )
   set_metric( "fin_komen_prelomljeno", my_user(), _prelom )
   set_metric( "fin_komen_br_racuna_sa_datumom", my_user(), _sa_datumom )

   vars[ "konto" ] := cIdKonto
   vars[ "konto2" ] := cIdKonto2
   vars[ "partn" ] := cIdPartner
   vars[ "dat_od" ] := _dat_od
   vars[ "dat_do" ] := _dat_do
   vars[ "po_vezi" ] := cSabratiPoBrojevimaVeze
   vars[ "prelom" ] := _prelom
   vars[ "firma" ] := _id_firma
   vars[ "sa_datumom" ] := _sa_datumom

   RETURN _ret


FUNCTION kompenzacija()

   LOCAL _is_gen := .F.
   LOCAL _vars := hb_Hash()
   LOCAL nI, _n
   LOCAL _row := f18_max_rows() - 10
   LOCAL _col := f18_max_cols() - 6
   LOCAL cIdKonto, cIdKonto2

   picBHD := FormPicL( gPicBHD, 16 )
   picDEM := FormPicL( pic_iznos_eur(), 12 )

   _o_tables()

   _vars[ "konto" ] := ""
   _vars[ "konto2" ] := ""
   _vars[ "partn" ] := ""
   _vars[ "dat_od" ] := Date()
   _vars[ "dat_do" ] := Date()
   _vars[ "po_vezi" ] := "D"
   _vars[ "prelom" ] := "N"
   _vars[ "firma" ] := self_organizacija_id()

   IF Pitanje(, "Izgenerisati stavke za kompenzaciju (D/N) ?", "N" ) == "D"

      _is_gen := .T.

      IF !_get_vars( @_vars )
         RETURN .F.
      ENDIF

      cIdKonto := _vars[ "konto" ]
      cIdKonto2 := _vars[ "konto2" ]

   ELSE

      cIdKonto := PadR( "", 7 )
      cIdKonto2 := cIdKonto

   ENDIF

   IF _is_gen
      _gen_kompen( _vars )
   ENDIF

   ImeKol := { ;
      { "Br.racuna", {|| PadR( brdok, 10 )    }, "brdok"    }, ;
      { "Iznos",     {|| iznosbhd }, "iznosbhd" }, ;
      { "Marker",    {|| marker }, "marker" } ;
      }

   Kol := {}
   FOR nI := 1 TO Len( ImeKol )
      AAdd( Kol, nI )
   NEXT

   Box(, _row, _col )

   @ box_x_koord(), box_y_koord() + 30 SAY ' KREIRANJE OBRASCA "IZJAVA O KOMPENZACIJI" '

   @ box_x_koord() + _row - 4, box_y_koord() + 1 SAY Replicate( "=", _col )
   @ box_x_koord() + _row - 3, box_y_koord() + 1 SAY8 "  <K> izaberi/ukini račun za kompenzaciju"
   @ box_x_koord() + _row - 2, box_y_koord() + 1 SAY8 "<c+P> štampanje kompenzacije                  <T> promijeni tabelu"
   @ box_x_koord() + _row - 1, box_y_koord() + 1 SAY8 "<c+N> nova stavka                           <c+T> brisanje                 <ENTER> ispravka stavke "

   FOR _n := 1 TO ( _row - 4 )
      @ box_x_koord() + _n, box_y_koord() + ( _col / 2 ) SAY "|"
   NEXT

   SELECT komp_pot
   GO TOP

   SELECT komp_dug
   GO TOP

   box_y_koord( box_y_koord() + ( _col / 2 ) + 1 )

   DO WHILE .T.

      IF Alias() == "KOMP_DUG"
         box_y_koord( box_y_koord() - ( _col / 2 ) + 1 )
      ELSEIF Alias() == "KOMP_POT"
         box_y_koord( box_y_koord() + ( _col / 2 ) + 1 )
      ENDIF

      my_browse( "komp1", _row - 7, ( _col / 2 ) - 1, {|| key_handler( _vars ) }, "", if( Alias() == "KOMP_DUG", "DUGUJE " + cIdKonto, "POTRAZUJE " + cIdKonto2 ), , , , , 1 )

      IF LastKey() == K_ESC
         EXIT
      ENDIF

   ENDDO

   BoxC()

   my_close_all_dbf()

   RETURN .T.


STATIC FUNCTION zap_tabele_kompenzacije()

   SELECT komp_dug
   my_dbf_zap()

   SELECT komp_pot
   my_dbf_zap()

   RETURN .T.



STATIC FUNCTION _gen_kompen( vars )

   LOCAL cIdKonto := vars[ "konto" ]
   LOCAL cIdKonto2 := vars[ "konto2" ]
   LOCAL cIdPartner := vars[ "partn" ]
   LOCAL _dat_od := vars[ "dat_od" ]
   LOCAL _dat_do := vars[ "dat_do" ]
   LOCAL cSabratiPoBrojevimaVeze := vars[ "po_vezi" ]
   LOCAL _sa_datumom := vars[ "sa_datumom" ]
   LOCAL _prelom := vars[ "prelom" ]
   LOCAL _id_firma := vars[ "firma" ]
   LOCAL cFilter, __opis_br_dok
   LOCAL _id_konto, _id_partner, _prolaz, _prosao
   LOCAL _otv_st, _t_id_konto
   LOCAL _br_dok
   LOCAL _d_bhd, _p_bhd, _d_dem, _p_dem
   LOCAL _pr_d_bhd, _pr_p_bhd, _pr_d_dem, _pr_p_dem
   LOCAL _dug_bhd, _pot_bhd, _dug_dem, _pot_dem
   LOCAL _kon_d, _kon_p, _kon_d2, _kon_p2
   LOCAL _svi_d, _svi_p, _svi_d2, _svi_p2
   LOCAL cOrderBy

   zap_tabele_kompenzacije()

   // o_suban()
   //o_tdok()

   // SELECT SUBAN


   cFilter := ".t."

   IF !Empty( _dat_od )
      cFilter += " .and. DATDOK >= " + dbf_quote( _dat_od )
   ENDIF

   IF !Empty( _dat_do )
      cFilter += " .and. DATDOK <= " + dbf_quote( _dat_do )
   ENDIF

   cOrderBy := "IdFirma,IdKonto,IdPartner,brdok,datdok"

   // IF cSabratiPoBrojevimaVeze == "D"
   // SET ORDER TO TAG "3"
   // cOrderBy := "idfirma,idvn,brnal"
   // ENDIF

   // IF !find_suban_by_konto_partner( _id_firma, cIdKonto, cIdPartner, NIL, cOrderBy )
   // find_suban_by_konto_partner( _id_firma, cIdKonto2, cIdPartner, NIL, cOrderBy )
   // ENDIF
   find_suban_by_konto_partner( _id_firma, cIdKonto + ";" + cIdKonto2 + ";", cIdPartner, NIL, cOrderBy, .T. ) // lIndex = .T.


   MsgO( "setujem filter... " )
   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &( cFilter )
   ENDIF
   MsgC()

   GO TOP
   EOF CRET

   _svi_d := 0
   _svi_p := 0
   _svi_d2 := 0
   _svi_p2 := 0
   _kon_d := 0
   _kon_p := 0
   _kon_d2 := 0
   _kon_p2 := 0

   _id_konto := field->idkonto

   _prolaz := 0
   IF Empty( cIdPartner )
      _prolaz := 1
      HSEEK _id_firma + cIdKonto
      IF Eof()
         _prolaz := 2
         HSEEK _id_firma + cIdKonto2
      ENDIF
   ENDIF

   Box(, 2, 50 )

   _cnt := 0

   DO WHILE .T.

      IF !Eof() .AND. field->idfirma == _id_firma .AND. ;
            ( ( _prolaz == 0 .AND. ( field->idkonto == cIdKonto .OR. field->idkonto == cIdKonto2 ) ) .OR. ;
            ( _prolaz == 1 .AND. field->idkonto = cIdKonto ) .OR. ;
            ( _prolaz == 2 .AND. field->idkonto = cIdKonto2 ) )
      ELSE
         EXIT
      ENDIF

      _d_bhd := 0
      _p_bhd := 0
      _d_dem := 0
      _p_dem := 0
      _pr_d_bhd := 0
      _pr_p_bhd := 0
      _pr_d_dem := 0
      _pr_p_dem := 0
      _dug_bhd := 0
      _pot_bhd := 0
      _dug_dem := 0
      _pot_dem := 0

      _id_partner := field->idpartner
      _prosao := .F.

      DO WHILE !Eof() .AND. field->IdFirma == _id_firma .AND. field->idpartner == _id_partner .AND. ( field->idkonto == cIdKonto .OR. field->idkonto == cIdKonto2 )

         _id_konto := field->idkonto
         _otv_st := field->otvst

         IF !( _otv_st == "9" )

            _prosao := .T.

            SELECT suban
            IF _id_konto == cIdKonto
               SELECT komp_dug
            ELSE
               SELECT komp_pot
            ENDIF

            my_flock()

            APPEND BLANK

            __opis_br_dok := AllTrim( suban->brdok )

            IF Empty( __opis_br_dok )
               __opis_br_dok := "??????"
            ENDIF

            IF _sa_datumom == "D"
               __opis_br_dok += " od " + DToC( suban->datdok )
            ENDIF

            REPLACE field->brdok WITH __opis_br_dok

            my_unlock()

            _t_id_konto := _id_konto
            SELECT suban

         ENDIF

         @ box_x_koord() + 1, box_y_koord() + 2 SAY "konto: " + PadR( _id_konto, 7 ) + " partner: " + _id_partner

         _d_bhd := 0
         _p_bhd := 0
         _d_dem := 0
         _p_dem := 0

         IF cSabratiPoBrojevimaVeze == "D"

            _br_dok := field->brdok

            DO WHILE !Eof() .AND. field->IdFirma == _id_firma .AND. field->idpartner == _id_partner ;
                  .AND. ( field->idkonto == cIdKonto .OR. field->idkonto == cIdKonto2 ) .AND. field->brdok == _br_dok
               IF field->d_p == "1"
                  _d_bhd += field->iznosbhd
                  _d_dem += field->iznosdem
               ELSE
                  _p_bhd += field->iznosbhd
                  _p_dem += field->iznosdem
               ENDIF

               SKIP

            ENDDO

            IF _prelom == "D"
               Prelomi( @_d_bhd, @_p_bhd )
               Prelomi( @_d_dem, @_p_dem )
            ENDIF

         ELSE

            IF field->d_p == "1"
               _d_bhd += field->iznosbhd
               _d_dem += field->iznosdem
            ELSE
               _p_bhd += field->iznosbhd
               _p_dem += field->iznosdem
            ENDIF

         ENDIF

         @ box_x_koord() + 2, box_y_koord() + 2 SAY "cnt:" + AllTrim( Str( ++_cnt ) ) + " suban cnt: " + AllTrim( Str( RecNo() ) )

         IF _otv_st == "9"
            _dug_bhd += _d_bhd
            _pot_bhd += _p_bhd
         ELSE

            // otvorena stavka
            IF _t_id_konto == cIdKonto
               SELECT komp_dug
               IF _d_bhd > 0
                  RREPLACE field->iznosbhd WITH _d_bhd
                  IF _p_bhd > 0
                     _rec := dbf_get_rec()
                     APPEND BLANK
                     dbf_update_rec( _rec )
                     RREPLACE field->iznosbhd WITH -_p_bhd
                  ENDIF
               ELSE
                  RREPLACE field->iznosbhd WITH -_p_bhd
               ENDIF
            ELSE

               SELECT komp_pot
               IF _p_bhd > 0
                  RREPLACE field->iznosbhd WITH _p_bhd
                  IF _d_bhd > 0
                     _rec := dbf_get_rec()
                     APPEND BLANK
                     dbf_update_rec( _rec )
                     RREPLACE field->iznosbhd WITH -_d_bhd
                  ENDIF
               ELSE
                  RREPLACE field->iznosbhd WITH -_d_bhd
               ENDIF
            ENDIF

            SELECT SUBAN

            _dug_bhd += _d_bhd
            _pot_bhd += _p_bhd

         ENDIF

         IF cSabratiPoBrojevimaVeze <> "D"
            SKIP
         ENDIF

         IF _prolaz == 0 .OR. _prolaz == 1
            IF ( field->idkonto <> _id_konto .OR. field->idpartner <> _id_partner ) .AND. _id_konto == cIdKonto
               HSEEK _id_firma + cIdKonto2 + _id_partner
            ENDIF
         ENDIF

      ENDDO

      _kon_d += _dug_bhd
      _kon_p += _pot_bhd
      _kon_d2 += _dug_dem
      _kon_p2 += _pot_dem

      IF _prolaz == 0
         EXIT
      ELSEIF _prolaz == 1
         SEEK _id_firma + cIdKonto + _id_partner + Chr( 255 )
         IF cIdKonto <> field->idkonto
            _prolaz := 2
            SEEK _id_firma + cIdKonto2
            _id_partner := Replicate( "", Len( field->idpartner ) )
            IF !Found()
               EXIT
            ENDIF
         ENDIF
      ENDIF

      IF nprolaz == 2
         DO WHILE .T.
            SEEK _id_firma + cIdKonto2 + _id_partner + Chr( 255 )
            nTrec := RecNo()
            IF field->idkonto == cIdKonto2
               _id_partner := field->idpartner
               HSEEK _id_firma + cIdKonto + _id_partner
               IF !Found()
                  GO ( nTrec )
                  EXIT
               ELSE
                  LOOP
               ENDIF
            ENDIF
            EXIT
         ENDDO
      ENDIF

   ENDDO

   BoxC()

   RETURN .T.


STATIC FUNCTION key_handler( vars )

   LOCAL nTr2
   LOCAL GetList := {}
   LOCAL nRec := RecNo()
   LOCAL nX := box_x_koord()
   LOCAL nY := box_y_koord()
   LOCAL nVrati := DE_CONT
   LOCAL _area

   IF !( ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. reccount2() == 0 )

      DO CASE

      CASE Ch == Asc( "K" ) .OR. Ch == Asc( "k" )

         RREPLACE field->marker WITH if( field->marker == "K", " ", "K" )
         nVrati := DE_REFRESH

      CASE Ch == K_CTRL_P

         _area := Select()

         print_kompen( vars )

         SELECT ( _area )
         nVrati := DE_CONT

      CASE Ch == K_CTRL_N

         GO BOTTOM
         SKIP 1
         Scatter()
         Box(, 5, 70 )
         @ box_x_koord() + 2, box_y_koord() + 2 SAY8 "Br.računa " GET _brdok
         @ box_x_koord() + 3, box_y_koord() + 2 SAY8 "Iznos     " GET _iznosbhd
         READ
         BoxC()
         IF LastKey() == K_ESC
            GO ( nRec )
         ELSE
            APPEND BLANK
            Gather()
            nVrati := DE_REFRESH
         ENDIF

      CASE Ch == K_CTRL_T

         nVrati := browse_brisi_stavku()

      CASE Ch == K_ENTER

         Scatter()

         Box(, 5, 70 )
         @ box_x_koord() + 2, box_y_koord() + 2 SAY8 "Br.računa " GET _brdok
         @ box_x_koord() + 3, box_y_koord() + 2 SAY8 "Iznos     " GET _iznosbhd
         READ
         BoxC()

         IF LastKey() == K_ESC
            GO ( nRec )
         ELSE
            my_rlock()
            Gather()
            my_unlock()
            nVrati := DE_REFRESH
         ENDIF

      CASE Ch == Asc( "T" ) .OR. Ch == Asc( "t" )

         IF Alias() == "KOMP_DUG"
            SELECT komp_pot
            GO TOP
         ELSEIF Alias() == "KOMP_POT"
            SELECT komp_dug
            GO TOP
         ENDIF

         nVrati := DE_ABORT

      ENDCASE

   ENDIF

   box_x_koord( nX )
   box_y_koord( nY )

   RETURN nVrati


STATIC FUNCTION print_kompen( vars )

   LOCAL _id_pov := Space( 6 )
   LOCAL _id_partn := Space( 6 )
   LOCAL _br_komp := Space( 10 )
   LOCAL _x := 1
   LOCAL _dat_komp := Date()
   LOCAL _rok_pl := 7
   LOCAL _valuta := "D"
   LOCAL _saldo
   LOCAL _ret := .T.
   LOCAL cFilter := "komp*.odt"
   LOCAL _template := ""
   LOCAL _templates_path := f18_template_location()
   LOCAL _xml_file := my_home() + "data.xml"

   IF !Empty( vars[ "partn" ] )
      _id_partn := vars[ "partn" ]
   ENDIF

   download_template( "komp_01.odt", "7623ca44a8f2a0126dbb73540943e974f2e860cf884189ea9c5c67294cd87bc4" )

   _id_pov := fetch_metric( "fin_kompen_id_povjerioca", my_home(), _id_pov )
   _br_komp := fetch_metric( "fin_kompen_broj", my_home(), _br_komp )
   _rok_pl := fetch_metric( "fin_kompen_rok_placanja", my_home(), _rok_pl )
   _valuta := fetch_metric( "fin_kompen_valuta", my_home(), _valuta )

   Box(, 10, 50 )
   ++_x
   @ box_x_koord() + _x, box_y_koord() + 2 SAY "Datum kompenzacije: " GET _dat_komp

   ++_x
   @ box_x_koord() + _x, box_y_koord() + 2 SAY8 "Rok plaćanja (dana): " GET _rok_pl VALID _rok_pl >= 0 PICT "999"

   ++_x
   @ box_x_koord() + _x, box_y_koord() + 2 SAY "Valuta kompenzacije (D/P): " GET _valuta  VALID _valuta $ "DP"  PICT "!@"

   ++_x
   @ box_x_koord() + _x, box_y_koord() + 2 SAY "Broj kompenzacije: " GET _br_komp

   ++_x
   @ box_x_koord() + _x, box_y_koord() + 2 SAY8 "Šifra (ID) povjerioca: " GET _id_pov VALID p_partner( @_id_pov ) PICT "@!"

   ++_x
   @ box_x_koord() + _x, box_y_koord() + 2 SAY8 "   Šifra (ID) dužnika: " GET _id_partn VALID p_partner( @_id_partn ) PICT "@!"
   READ
   BoxC()

   IF LastKey() == K_ESC
      _ret := .F.
      RETURN _ret
   ENDIF

   set_metric( "fin_kompen_id_povjerioca", my_home(), _id_pov )
   set_metric( "fin_kompen_broj", my_home(), _br_komp )
   set_metric( "fin_kompen_rok_placanja", my_home(), _rok_pl )
   set_metric( "fin_kompen_valuta", my_home(), _valuta )

   vars[ "id_pov" ] := _id_pov
   vars[ "komp_broj" ] := _br_komp
   vars[ "rok_pl" ] := _rok_pl
   vars[ "valuta" ] := _valuta
   vars[ "datum" ] := _dat_komp

   IF Empty( vars[ "partn" ] )
      vars[ "partn" ] := _id_partn
   ENDIF

   IF !_gen_xml( vars, _xml_file )
      _ret := .F.
      RETURN _ret
   ENDIF

   IF get_file_list_array( _templates_path, cFilter, @_template, .T. ) == 0
      RETURN .F.
   ENDIF

   IF generisi_odt_iz_xml( _template, _xml_file )
      prikazi_odt()
   ENDIF

   RETURN _ret


STATIC FUNCTION _gen_xml( vars, xml_file )

   LOCAL _ret := .T.
   LOCAL _id_pov, _br_komp, _rok_pl, _valuta
   LOCAL _dat_od, _dat_do, _partner
   LOCAL _temp_duz := .T.
   LOCAL _temp_pov := .T.
   LOCAL _br_st := 0
   LOCAL _ukupno_duz := 0
   LOCAL _ukupno_pov := 0
   LOCAL _broj_dok_duz, _broj_dok_pov
   LOCAL _iznos_duz, _iznos_pov
   LOCAL _dat_komp

   _id_pov := vars[ "id_pov" ]
   _br_komp := vars[ "komp_broj" ]
   _rok_pl := vars[ "rok_pl" ]
   _valuta := vars[ "valuta" ]
   _partner := vars[ "partn" ]
   _dat_od := vars[ "dat_od" ]
   _dat_do := vars[ "dat_do" ]
   _dat_komp := vars[ "datum" ]

   create_xml( xml_file )

   xml_head()

   xml_subnode( "kompen", .F. )

   // povjerioc
   IF !_fill_partn( _id_pov, "pov" )
      RETURN .F.
   ENDIF

   // duznik
   IF !_fill_partn( _partner, "duz" )
      RETURN .F.
   ENDIF

   SELECT komp_dug
   GO TOP
   SELECT komp_pot
   GO TOP

   _skip_t_marker( @_temp_duz, @_temp_pov )

   xml_subnode( "tabela", .F. )

   SELECT komp_pot

   DO WHILE _temp_duz .OR. _temp_pov

      ++_br_st

      xml_subnode( "item", .F. )

      _broj_stavke := AllTrim( Str( _br_st ) )

      _iznos_pov := 0
      _iznos_duz := 0

      _broj_dok_duz := ""
      _broj_dok_pov := ""

      IF _temp_pov
         _broj_dok_pov := AllTrim( field->brdok )
         _iznos_pov := field->iznosbhd
      ENDIF

      xml_node( "rbr", _broj_stavke )
      xml_node( "dok_pov", to_xml_encoding( _broj_dok_pov ) )
      xml_node( "izn_pov", AllTrim( Str( _iznos_pov, 17, 2 ) ) )

      SELECT komp_dug

      IF _temp_duz
         _broj_dok_duz := AllTrim( field->brdok )
         _iznos_duz := field->iznosbhd
      ENDIF

      xml_node( "dok_duz", to_xml_encoding( _broj_dok_duz  ) )
      xml_node( "izn_duz", AllTrim( Str( _iznos_duz, 17, 2 ) ) )

      xml_subnode( "item", .T. )

      _ukupno_duz += _iznos_duz
      _ukupno_pov += _iznos_pov

      SKIP 1

      SELECT komp_pot
      SKIP 1

      _skip_t_marker( @_temp_duz, @_temp_pov )

   ENDDO

   xml_subnode( "tabela", .T. )

   // totali
   xml_node( "total_duz", AllTrim( Str( _ukupno_duz, 17, 2 ) ) )
   xml_node( "total_pov", AllTrim( Str( _ukupno_pov, 17, 2 ) ) )
   xml_node( "total_komp", AllTrim( Str( Min( Abs( _ukupno_duz ), Abs( _ukupno_pov ) ), 17, 2 ) ) )
   xml_node( "saldo", AllTrim( Str( Abs( _ukupno_duz - _ukupno_pov ), 17, 2 ) ) )

   // generalni podaci kompenzacije
   xml_node( "broj", to_xml_encoding( AllTrim( _br_komp ) ) )
   xml_node( "rok_pl", to_xml_encoding( AllTrim( Str( _rok_pl ) ) ) )
   xml_node( "valuta", AllTrim( _valuta ) )
   xml_node( "per_od", DToC( _dat_od ) )
   xml_node( "per_do", DToC( _dat_do ) )
   xml_node( "datum", DToC( _dat_komp ) )

   xml_subnode( "kompen", .T. )

   close_xml()

   RETURN _ret


STATIC FUNCTION _fill_partn( part_id, node_name )

   LOCAL _ret := .T.

   IF node_name == NIL
      node_name := "pov"
   ENDIF

   select_o_partner( part_id )

   IF !Found()
      MsgBeep( "Partner " + part_id + " ne postoji u sifrarniku !" )
      RETURN .F.
   ENDIF

   xml_subnode( node_name, .F. )

   // podaci povjerioca
   //
   // <pov>
   // <id>-</id>
   // <....
   // </pov>

   xml_node( "id", to_xml_encoding( AllTrim( field->id ) ) )
   xml_node( "naz", to_xml_encoding( AllTrim( field->naz ) ) )
   xml_node( "naz2", to_xml_encoding( AllTrim( field->naz2 ) ) )
   xml_node( "mjesto", to_xml_encoding( AllTrim( field->mjesto ) ) )
   xml_node( "d_ziror", to_xml_encoding( AllTrim( field->ziror ) ) )
   xml_node( "s_ziror", to_xml_encoding( AllTrim( field->dziror ) ) )
   xml_node( "tel", AllTrim( field->telefon ) )
   xml_node( "fax", AllTrim( field->fax ) )
   xml_node( "adr", to_xml_encoding ( AllTrim( field->adresa ) ) )
   xml_node( "ptt", AllTrim( field->ptt ) )

   xml_node( "id_broj", AllTrim( firma_pdv_broj( part_id ) ) )
   //xml_node( "por_broj", AllTrim( get_partn_sifk_sifv( "PORB", part_id, .F. ) ) )

   xml_subnode( node_name, .T. )

   RETURN _ret


STATIC FUNCTION _skip_t_marker( _mark_12, _mark_60 )

   LOCAL _t_arr := Select()

   SELECT komp_dug
   DO WHILE field->marker != "K" .AND. !Eof()
      SKIP 1
   ENDDO
   IF Eof()
      _mark_12 := .F.
   ENDIF

   SELECT komp_pot
   DO WHILE field->marker != "K" .AND. !Eof()
      SKIP 1
   ENDDO
   IF Eof()
      _mark_60 := .F.
   ENDIF

   SELECT ( _t_arr )

   RETURN NIL



STATIC FUNCTION _o_tables()

   O_KOMP_POT
   O_KOMP_DUG
   //o_konto()
   // o_partner()

   RETURN .T.
