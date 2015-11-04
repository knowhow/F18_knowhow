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

#include "fakt.ch"
#include "f18_separator.ch"


STATIC __fiscal_marker := .F.

STATIC __id_firma
STATIC __tip_dok
STATIC __br_dok
STATIC __r_br

STATIC __enter_seq := Chr( K_ENTER ) + Chr( K_ENTER ) + Chr( K_ENTER )

STATIC __redni_broj


FUNCTION fakt_unos_dokumenta()

   LOCAL _i, _x_pos, _y_pos, _x, _y
   LOCAL _sep := BROWSE_COL_SEP
   PRIVATE ImeKol, Kol

   pos_unset_key_handler_ispravka_racuna()

   zadnji_fiscal_z_report_info()

   close_open_fakt_tabele()
   select_fakt_pripr()

   IF field->idtipdok == "IM"
      my_close_all_dbf()
      fakt_unos_inventure()
      RETURN
   ENDIF

   PRIVATE ImeKol := { ;
      { "Red.br",  {|| dbSelectArea( F_FAKT_PRIPR ), Rbr()                   } }, ;
      { "Partner/Roba",  {|| Part1Stavka() + Roba()  } }, ;
      { "Kolicina",  {|| kolicina  } }, ;
      { "Cijena",    {|| Cijena    }, "cijena"    }, ;
      { "Rabat",    {|| Transform(Rabat, "999.99") }, "Rabat"  }, ;
      { "Real.Marza", {|| Transform(get_realizovana_marza( NIL, field->idRoba, field->datDok, field->Cijena*(1-field->Rabat/100) ), "999.99")  } }, ;
      { "Nab.Cj",   {|| Transform(get_nabavna_cijena( NIL, field->idRoba, field->DatDok ), "99999.999") } }, ;
      { "RJ",  {|| idfirma                 }, "idfirma"   }, ;
      { "Serbr",         {|| SerBr                   }, "serbr"     }, ;
      { "Partn",         {|| IdPartner               }, "IdPartner" }, ;
      { "IdTipDok",      {|| IdTipDok                }, "Idtipdok"  }, ;
      { "DinDem",        {|| dindem                  }, "dindem"    }, ;
      { "Brdok",         {|| Brdok                   }, "Brdok"     }, ;
      { "DatDok",        {|| DATDOK                  }, "DATDOK"    } ;
      }

   IF fakt_pripr->( FieldPos( "idrelac" ) ) <> 0
      AAdd( ImeKol, { "ID relac.", {|| idrelac  }, "IDRELAC"  } )
   ENDIF

   Kol := {}
   FOR _i := 1 TO Len( ImeKol )
      AAdd( Kol, _i )
   NEXT

   // inicijalizacija staticki varijabli...
   // marker fiskalnih racuna
   __fiscal_marker := .F.

   // podaci dokumenta
   __id_firma  := field->idfirma
   __tip_dok := field->idtipdok
   __br_dok  := field->brdok
   __r_br := field->rbr

   _x := MAXROWS() - 4
   _y := MAXCOLS() - 3

   Box( , _x, _y )

   _opt_d := ( _y / 4 )

   _opt_row := PadR( "<c+N> Nova stavka", _opt_d ) + _sep
   _opt_row += PadR( "<ENT> Ispravka", _opt_d ) + _sep
   _opt_row += PadR( hb_UTF8ToStr( "<c+T> Briši stavku" ), _opt_d ) + _sep

   @ m_x + _x - 4, m_y + 2 SAY _opt_row

   _opt_row := PadR( "<c+A> Ispravka dok.", _opt_d ) + _sep
   _opt_row += PadR( hb_UTF8ToStr( "<c+P> Štampa (txt)" ), _opt_d ) + _sep
   _opt_row += PadR( "<A> Asistent", _opt_d ) + _sep

   @ m_x + _x - 3, m_y + 2 SAY _opt_row

   _opt_row := PadR( hb_UTF8ToStr( "<a+A> Ažuriranje" ), _opt_d ) + _sep
   _opt_row += PadR( hb_UTF8ToStr( "<c+F9> Briši sve" ), _opt_d ) + _sep
   _opt_row += PadR( "<F5> Kontrola zbira", _opt_d ) + _sep
   _opt_row += "<T> total dokumenta"

   @ m_x + _x - 2, m_y + 2 SAY _opt_row

   _opt_row := PadR( "", _opt_d ) + _sep
   _opt_row += PadR( "", _opt_d ) + _sep
   _opt_row += PadR( "<F10> Ostale opcije", _opt_d ) + _sep
   _opt_row += "<O> Konverzije"

   @ m_x + _x - 1, m_y + 2 SAY _opt_row

   ObjDbedit( "PNal", _x, _y, {|| fakt_pripr_keyhandler() }, "", "Priprema...", , , , , 4 )

   BoxC()

   my_close_all_dbf()

   RETURN



STATIC FUNCTION fakt_pripr_keyhandler()

   LOCAL _rec
   LOCAL _ret
   LOCAL cPom
   LOCAL _fakt_doks := {}
   LOCAL _dev_id := 0
   LOCAL _dev_params
   LOCAL _fiscal_use := fiscal_opt_active()
   LOCAL _params := fakt_params()
   LOCAL _dok := hb_Hash()
   LOCAL oAtrib
   LOCAL _dok_hash

   IF ( Ch == K_ENTER .AND. Empty( field->brdok ) .AND. Empty( field->rbr ) )
      RETURN DE_CONT
   ENDIF

   select_fakt_pripr()

   DO CASE

   CASE __fiscal_marker == .T.

      __fiscal_marker := .F.

      IF !_fiscal_use
         RETURN DE_CONT
      ENDIF

      IF fakt_pripr->( RecCount() ) <> 0
         MsgBeep( "Priprema nije prazna, stampa fisk.racuna nije moguca!" )
         RETURN DE_CONT
      ENDIF

      IF Pitanje(, "Odstampati racun na fiskalni printer ?", "D" ) == "N"
         RETURN DE_CONT
      ENDIF

      _dev_id := odaberi_fiskalni_uredjaj( __tip_dok, .F., .F. )

      IF _dev_id > 0

         _dev_params := get_fiscal_device_params( _dev_id, my_user() )
         IF _dev_params == NIL
            RETURN DE_CONT
         ENDIF

      ELSE
         RETURN DE_CONT
      ENDIF

      IF _dev_params[ "print_fiscal" ] == "N"
         MsgBeep( "Nije Vam dozvoljena opcija za stampu fiskalnih računa !" )
         RETURN DE_CONT
      ENDIF

      MsgO( "stampa na fiskalni printer u toku..." )

      fakt_fiskalni_racun( __id_firma, __tip_dok, __br_dok, .F., _dev_params )

      MsgC()

      select_fakt_pripr()

      IF _dev_params[ "print_a4" ] $ "D#G#X"

         IF _dev_params[ "print_a4" ] $ "D#X" .AND. Pitanje(, "Štampati fakturu ?", "N" ) == "D"
            StampTXT( __id_firma, __tip_dok, __br_dok )
            close_open_fakt_tabele()
            select_fakt_pripr()
         ENDIF

         IF _dev_params[ "print_a4" ] $ "G#X" .AND. Pitanje(, "Štampati LibreOffice fakturu ?", "N" ) == "D"
            stdokodt( __id_firma, __tip_dok, __br_dok )
            close_open_fakt_tabele()
            select_fakt_pripr()
         ENDIF

         RETURN DE_REFRESH

      ENDIF

      RETURN DE_CONT

   CASE Upper( Chr( Ch ) ) == "T"

      _total_dokumenta()
      RETURN DE_REFRESH

   CASE ( Ch == K_CTRL_T )

      IF fakt_brisi_stavku_pripreme() == 1
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE Ch == K_ENTER

      IF fakt_ispravi_dokument( _params )
          RETURN DE_REFRESH
      ELSE
          RETURN DE_CONT
      ENDIF

   CASE Ch == K_CTRL_A

      fakt_prodji_kroz_stavke( _params )
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_N

      fakt_unos_nove_stavke()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_P

      fakt_print_dokument()

#ifdef TEST
      push_test_tag( "FAKT_CTRLP_END" )
#endif

      RETURN DE_REFRESH

   CASE Ch == K_ALT_P

        fakt_set_broj_dokumenta()

        IF !CijeneOK( "Stampanje" )
            RETURN DE_REFRESH
        ENDIF

        StDokOdt( nil, nil, nil )

        close_open_fakt_tabele()

        #ifdef TEST
            push_test_tag("FAKT_ALTP_END")
        #endif

        RETURN DE_REFRESH


   CASE Ch == K_ALT_L

      my_close_all_dbf()
      label_bkod()
      close_open_fakt_tabele()

#ifdef TEST
      push_test_tag( "FAKT_ALTP_END" )
#endif

      RETURN DE_REFRESH

   CASE Ch == K_ALT_A

      fakt_set_broj_dokumenta()

      IF fakt_postoji_li_rupa_u_brojacu( field->idfirma, field->idtipdok, field->brdok ) > 0
         RETURN DE_REFRESH
      ENDIF

      __id_firma  := field->idfirma
      __tip_dok := field->idtipdok
      __br_dok  := field->brdok

      IF !CijeneOK( "Azuriranje" )
         RETURN DE_REFRESH
      ENDIF

      IF !valid_dodaj_taksu_za_gorivo()
         RETURN DE_REFRESH
      ENDIF

      my_close_all_dbf()

      _fakt_doks := azur_fakt()

      close_open_fakt_tabele()

      IF _fiscal_use .AND. __tip_dok $ "10#11" .AND. _fakt_doks <> NIL

         IF Len( _fakt_doks ) > 0

            __id_firma := _fakt_doks[ 1, 1 ]
            __tip_dok := _fakt_doks[ 1, 2 ]
            __br_dok := _fakt_doks[ 1, 3 ]

            __fiscal_marker := .T.

         ENDIF

      ENDIF

      RETURN DE_REFRESH


   CASE Ch == K_CTRL_F9

      fakt_brisanje_pripreme()
      RETURN DE_REFRESH


   CASE Ch == K_F5

      fakt_kzb()
      RETURN DE_CONT


   CASE Upper( Chr( Ch ) ) == "O"

      _t_area := Select()

      IF reccount2() <> 0
         fakt_generisi_racun_iz_pripreme()
      ELSE
         _fakt_doks := FaktDokumenti():New()
         _fakt_doks:pretvori_otpremnice_u_racun()
      ENDIF

      SELECT ( _t_area )
      RETURN DE_REFRESH

   CASE Upper( Chr( Ch ) ) == "A"

      PRIVATE _broj_entera := 30

      FOR _i := 1 TO Int( RecCount2() / 15 ) + 1
         _sekv := Chr( K_CTRL_A )
         FOR _n := 1 TO Min( RecCount2(), 15 ) * 20
            _sekv += __enter_seq
         NEXT
         KEYBOARD _sekv
      NEXT

      RETURN DE_REFRESH


      // ostale opcije nad dokumentom
#ifdef __PLATFORM__DARWIN
   CASE Ch == Asc( "0" )
#else
   CASE Ch == K_F10
#endif

      popup_fakt_unos_dokumenta()
      SetLastKey( K_CTRL_PGDN )
      RETURN DE_REFRESH

   CASE Ch == K_F11

      Pripr9View()
      select_fakt_pripr()
      GO TOP

      RETURN DE_REFRESH


   CASE Ch == K_ALT_N

      fakt_print_narudzbenica_priprema()
      RETURN DE_REFRESH


   CASE Ch == K_ALT_E

      IF Pitanje(, "Exportovati dokument u LibreOffice ?", "D" ) == "D"

         fakt_export_dokument_lo()
         close_open_fakt_tabele()
         select_fakt_pripr()
         GO TOP

      ENDIF

      RETURN DE_CONT

   ENDCASE

   RETURN DE_CONT



// --------------------------------------------------
// prolazak kroz stavke pripreme
// --------------------------------------------------
STATIC FUNCTION fakt_prodji_kroz_stavke( fakt_params )

   LOCAL _dug
   LOCAL _rec_no, _rec
   LOCAL _items_atrib
   LOCAL _item_before

   PushWA()

   select_fakt_pripr()

   Box( "pst", MAXROWS() - 10, MAXCOLS() - 10, .F. )

   _dug := 0

   DO WHILE !Eof()

      SKIP
      _rec_no := RecNo()
      SKIP - 1

      set_global_vars_from_dbf( "_" )

      _item_before := hb_Hash()
      _item_before[ "idfirma" ] := _idfirma
      _item_before[ "idtipdok" ] := _idtipdok
      _item_before[ "brdok" ] := _brdok
      _item_before[ "rbr" ] := _rbr

      _items_atrib := hb_hash()

      IF fakt_params[ "fakt_opis_stavke" ]
         _items_atrib[ "opis" ] := get_fakt_atribut_opis( _item_before, .F. )
      ENDIF

      IF fakt_params[ "ref_lot" ]
         _items_atrib[ "ref" ] := get_fakt_atribut_ref( _item_before, .F. )
         _items_atrib[ "lot" ] := get_fakt_atribut_lot( _item_before, .F. )
      ENDIF

      _podbr := Space( 2 )
      __redni_broj := RbrUnum( _rbr )

      BoxCLS()

      IF edit_fakt_priprema( .F., @_items_atrib ) == 0
         EXIT
      ENDIF

      _dug += Round( _cijena * _kolicina * PrerCij() * ;
         ( 1 - _rabat / 100 ) * ( 1 + _porez / 100 ), ZAOKRUZENJE )

      @ m_x + 23, m_y + 2 SAY "ZBIR DOKUMENTA:"
      @ m_x + 23, Col() + 1 SAY _dug PICT "9 999 999 999.99"

      InkeySc( 10 )

      select_fakt_pripr()

      fakt_dodaj_ispravi_stavku( .F., _item_before, _items_atrib )

      fakt_promjena_cijene_u_sif()

      GO _rec_no

   ENDDO

   PopWA()
   BoxC()

   RETURN


// -------------------------------------------------------------------------------------------------------
// dodaje ili ispravlja stavku u tabeli FAKT_PRIPR
// novi - logički uslov nova stavka .T. ili .F.
// item_hash - hash matrica sa podacima stavke ( idfirma, idtipdok, brdok, rbr ) prije upisivanja u DBF
// items_atrib - hash matrica sa atributima definisanim na stavci kod unosa
// -------------------------------------------------------------------------------------------------------
STATIC FUNCTION fakt_dodaj_ispravi_stavku( novi, item_hash, items_atrib )

   LOCAL oAtrib, _rec, _item_after_hash
   LOCAL new_hash := hb_Hash()

   IF novi == .T.
       APPEND BLANK
   ENDIF

   // dodaj zapis u tabelu FAKT_PRIPR
   _rec := get_dbf_global_memvars( "_" )
   dbf_update_rec( _rec, .F. )

   // hash matrica koja sadrži update-ovan zapis
   new_hash["idfirma"] := fakt_pripr->idfirma
   new_hash["idtipdok"] := fakt_pripr->idtipdok
   new_hash["brdok"] := fakt_pripr->brdok
   new_hash["rbr"] := fakt_pripr->rbr

   // ažuriraj atribute u FAKT_FAKT_ATRIBUTI
   oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )
   oAtrib:dok_hash := new_hash

   IF !novi .AND. ( item_hash["rbr"] <> new_hash["rbr"] )
      oAtrib:dok_hash["update_rbr"] := item_hash["rbr"]
      oAtrib:update_atrib_rbr()
   ENDIF

   oAtrib:atrib_hash_to_dbf( items_atrib )

   fakt_promjena_cijene_u_sif()

   // nešto što mjenja sve stavke dokumenta u pripremi ako se promjeni prva stavka
   // promjena broja dokumenta i slično
   IF __redni_broj == 1 .and. !novi
      izmjeni_sve_stavke_dokumenta( item_hash, new_hash )
   ENDIF

   RETURN



STATIC FUNCTION fakt_ispravi_dokument( fakt_params )

   LOCAL _ret := .T.
   LOCAL _items_atrib := hb_Hash()
   LOCAL _item_before, _item_after

   Box( "ist", MAXROWS() - 10, MAXCOLS() - 10, .F. )

   set_global_vars_from_dbf( "_" )

   _item_before := hb_Hash()
   _item_before[ "idfirma" ] := _idfirma
   _item_before[ "idtipdok" ] := _idtipdok
   _item_before[ "brdok" ] := _brdok
   _item_before[ "rbr" ] := _rbr

   __redni_broj := RbrUnum( _rbr )

   IF fakt_params[ "fakt_opis_stavke" ]
      _items_atrib[ "opis" ] := get_fakt_atribut_opis( _item_before, .F. )
   ENDIF

   IF fakt_params[ "ref_lot" ]
      _items_atrib[ "ref" ] := get_fakt_atribut_ref( _item_before, .F. )
      _items_atrib[ "lot" ] := get_fakt_atribut_lot( _item_before, .F. )
   ENDIF

   IF edit_fakt_priprema( .F., @_items_atrib ) == 0
      _ret := .F.
   ELSE
      fakt_dodaj_ispravi_stavku( .F., _item_before, _items_atrib )
      _ret := .T.
   ENDIF

   BoxC()

   TB:RefreshAll()
   DO WHILE !TB:stable
     Tb:stabilize()
   ENDDO

   RETURN _ret




// -----------------------------------------------------------
// unos novih stavki fakture
// -----------------------------------------------------------
STATIC FUNCTION fakt_unos_nove_stavke()

   LOCAL _items_atrib
   LOCAL _rec
   LOCAL _total := 0
   LOCAL oAtrib, _dok_hash

   GO TOP

   DO WHILE !Eof()
      // kompletan nalog sumiram
      _total += Round( cijena * kolicina * PrerCij() * ( 1 - rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE )
      SKIP
   ENDDO

   GO BOTTOM

   Box( "knjn", MAXROWS() - 10, MAXCOLS() - 10, .F., "Unos nove stavke" )

   DO WHILE .T.

      set_global_vars_from_dbf( "_" )

      // podbr treba skroz ugasiti
      _podbr := Space( 2 )

      IF AllTrim( _podbr ) == "." .AND. Empty( _idroba )

         __redni_broj := RbrUnum( _rbr )
         _podbr := " 1"

      ELSEIF _podbr >= " 1"

         __redni_broj := RbrUnum( _rbr )
         _podbr := Str( Val( _podbr ) + 1, 2, 0 )

      ELSE

         __redni_broj := RbrUnum( _rbr ) + 1
         _podbr := "  "

      ENDIF

      BoxCLS()

      _items_atrib := hb_Hash()

      IF edit_fakt_priprema( .T., @_items_atrib ) == 0
         EXIT
      ENDIF

      _total += Round( _cijena * _kolicina * PrerCij() * ( 1 - _rabat / 100 ) * ( 1 + _porez / 100 ), ZAOKRUZENJE )

      @ m_x + MAXROWS() - 11, m_y + 2 SAY "ZBIR DOKUMENTA:"
      @ m_x + MAXROWS() - 11, Col() + 2 SAY _total PICT "9 999 999 999.99"

      InkeySc( 10 )

      select_fakt_pripr()
      fakt_dodaj_ispravi_stavku( .T., NIL, _items_atrib )

   ENDDO

   BoxC()

   RETURN


// ---------------------------------------------------
// printanje dokumenta
// ---------------------------------------------------
STATIC FUNCTION fakt_print_dokument()

   LOCAL _a_fakt_doks

   fakt_set_broj_dokumenta()

   _a_fakt_doks := fakt_dokumenti_pripreme_u_matricu()

   IF Len( _a_fakt_doks ) == 0
      MsgBeep( "Postojeći dokumenti u pripremi vec postoje !" )
   ENDIF

   F18_DOK_ATRIB():New( "fakt", F_FAKT_ATRIB ):fix_atrib( F_FAKT_PRIPR, _a_fakt_doks )

   close_open_fakt_tabele()

   IF !CijeneOK( "Stampanje" )
      RETURN DE_REFRESH
   ENDIF

   gPtxtC50 := .F.

   StampTXT( nil, nil, nil )
   close_open_fakt_tabele()

   RETURN


// ----------------------------------------------------
// inicijalizuj varijable iz memo polja txt
// ----------------------------------------------------
STATIC FUNCTION _init_vars_from_txt_memo()

   LOCAL _params := fakt_params()
   LOCAL _memo := ParsMemo( _txt )
   LOCAL _len := Len( _memo )

   IF _len > 0
      _txt1 := _memo[ 1 ]
   ENDIF

   IF _len >= 2
      _txt2 := _memo[ 2 ]
   ENDIF

   IF _len >= 9
      _brotp := _memo[ 6 ]
      _datotp := CToD( _memo[ 7 ] )
      _brnar := _memo[ 8 ]
      _datpl := CToD( _memo[ 9 ] )
   ENDIF

   IF _len >= 10 .AND. !Empty( _memo[ 10 ] )
      _vezotpr := _memo[ 10 ]
   ENDIF

   IF _len >= 11
      d2k1 := _memo[ 11 ]
   ENDIF

   IF _len >= 12
      d2k2 := _memo[ 12 ]
   ENDIF

   IF _len >= 13
      d2k3 := _memo[ 13 ]
   ENDIF

   IF _len >= 14
      d2k4 := _memo[ 14 ]
   ENDIF

   IF _len >= 15
      d2k5 := _memo[ 15 ]
   ENDIF

   IF _len >= 16
      d2n1 := _memo[ 16 ]
   ENDIF

   IF _len >= 17
      d2n2 := _memo[ 17 ]
   ENDIF

   IF _params[ "destinacije" ] .AND. _len >= 18
      _destinacija := PadR( AllTrim( _memo[ 18 ] ), 500 )
   ENDIF

   IF _params[ "fakt_dok_veze" ] .AND. _len >= 19
      _dokument_veza := PadR( AllTrim( _memo[ 19 ] ), 500 )
   ENDIF

   IF _params[ "fakt_objekti" ] .AND. _len >= 20
      _objekti := PadR( _memo[ 20 ], 10 )
   ENDIF

   RETURN



// ---------------------------------------------------
// sredji memo txt na osnovnu varijabli
// ---------------------------------------------------
STATIC FUNCTION _set_memo_txt_from_vars()

   LOCAL _tmp
   LOCAL _params := fakt_params()

   // odsjeci na kraju prazne linije
   _txt2 := OdsjPLK( _txt2 )

   IF ! "Racun formiran na osnovu" $ _txt2
      _txt2 += Chr( 13 ) + Chr( 10 ) + _vezotpr
   ENDIF

   _txt := Chr( 16 ) + Trim( _txt1 ) + Chr( 17 )
   _txt += Chr( 16 ) + _txt2 + Chr( 17 )
   _txt += Chr( 16 ) + "" + Chr( 17 )
   _txt += Chr( 16 ) + "" + Chr( 17 )
   _txt += Chr( 16 ) + "" + Chr( 17 )

   // 6 - br otpr
   _txt += Chr( 16 ) + _brotp + Chr( 17 )
   // 7 - dat otpr
   _txt += Chr( 16 ) + DToC( _datotp ) + Chr( 17 )
   // 8 - br nar
   _txt += Chr( 16 ) + _brnar + Chr( 17 )
   // 9 - dat nar
   _txt += Chr( 16 ) + DToC( _datpl ) + Chr( 17 )
   // 10
   _txt += Chr( 16 ) + _vezotpr + Chr( 17 )
   // 11
   _txt += Chr( 16 ) + d2k1 + Chr( 17 )
   // 12
   _txt += Chr( 16 ) + d2k2 + Chr( 17 )
   // 13
   _txt += Chr( 16 ) + d2k3 + Chr( 17 )
   // 14
   _txt += Chr( 16 ) + d2k4 + Chr( 17 )
   // 15
   _txt += Chr( 16 ) + d2k5 + Chr( 17 )
   // 16
   _txt += Chr( 16 ) + d2n1 + Chr( 17 )
   // 17
   _txt += Chr( 16 ) + d2n2 + Chr( 17 )

   IF _params[ "destinacije" ]
      _tmp := _destinacija
   ELSE
      _tmp := ""
   ENDIF

   // 18 - Destinacija
   _txt += Chr( 16 ) + AllTrim( _tmp ) + Chr( 17 )

   // 19 - vezni dokumenti
   IF _params[ "fakt_dok_veze" ]
      _tmp := _dokument_veza
   ELSE
      _tmp := ""
   ENDIF

   _txt += Chr( 16 ) + AllTrim( _dokument_veza ) + Chr( 17 )

   // 20 - objekti
   IF _params[ "fakt_objekti" ]
      _tmp := _objekti
   ELSE
      _tmp := ""
   ENDIF

   _txt += Chr( 16 ) + _tmp + Chr( 17 )

   RETURN


STATIC FUNCTION edit_fakt_priprema( fNovi, items_atrib )

   LOCAL _a_tipdok := {}
   LOCAL _h
   LOCAL _rok_placanja := 0
   LOCAL _avansni_racun
   LOCAL _opis := ""
   LOCAL _n_menu := fakt_tip_dokumenta_default_menu()
   LOCAL _convert := "N"
   LOCAL _x := 1
   LOCAL _odabir_txt := .F.
   LOCAL _lista_uzoraka
   LOCAL _x2, _part_x, _part_y, _tip_cijene
   LOCAL _ref_broj, _lot_broj
   LOCAL _params := fakt_params()

   _a_tipdok := fakt_tip_dok_arr()
   _h := {}
   ASize( _h, Len( _a_tipdok ) )
   AFill( _h, "" )

   IF items_atrib <> NIL

      IF _params[ "fakt_opis_stavke" ]
         IF fNovi
            _opis := PadR( "", 300 )
         ELSE
            _opis := PadR( items_atrib[ "opis" ], 300 )
         ENDIF
      ENDIF

      IF _params[ "ref_lot" ]

         IF fNovi
            _ref_broj := PadR( "", 50 )
            _lot_broj := PadR( "", 50 )
         ELSE
            _ref_broj := PadR( items_atrib[ "ref" ], 50 )
            _lot_broj := PadR( items_atrib[ "lot" ], 50 )
         ENDIF
      ENDIF

   ENDIF

   _txt1 := ""
   _txt2 := ""
   _brotp := Space( 50 )
   _datotp := CToD( "" )
   _brnar := Space( 50 )
   _datpl := CToD( "" )
   _vezotpr := ""
   _destinacija := ""
   _dokument_veza := ""
   _objekti := ""

   d2k1 := Space( 15 )
   d2k2 := Space( 15 )
   d2k3 := Space( 15 )
   d2k4 := Space( 20 )
   d2k5 := Space( 20 )
   d2n1 := Space( 12 )
   d2n2 := Space( 12 )

   SET CURSOR ON

   IF fNovi

      _convert := "D"
      _serbr := Space( Len( field->serbr ) )

      IF _params[ "destinacije" ]
         _destinacija := PadR( "", 500 )
      ENDIF

      IF _params[ "fakt_dok_veze" ]
         _dokument_veza := PadR( "", 500 )
      ENDIF

      IF _params[ "fakt_objekti" ]
         _objekti := Space( 10 )
      ENDIF

      _cijena := 0
      _kolicina := 0

      IF gResetRoba == "D"
         _idRoba := Space( 10 )
      ENDIF

      IF __redni_broj == 1

         _n_menu := iif( Val( gIMenu ) < 1, Asc( gIMenu ) - 55, Val( gIMenu ) )
         _idfirma := gFirma

         IF !Empty( _params[ "def_rj" ] )
            _idfirma := _params[ "def_rj" ]
         ENDIF

         _idtipdok := "10"
         _datdok := Date()
         _zaokr := 2
         _dindem := Left( ValBazna(), 3 )
         _m1 := " "
         _brdok := PadR( Replicate( "0", gNumDio ), 8 )

      ENDIF

   ELSE
      _init_vars_from_txt_memo()
      _n_menu := AScan( _a_tipdok, {| x| _idtipdok == Left( x, 2 ) } )
   ENDIF

   _podbr := Space( 2 )
   _tip_rabat := "%"

   IF ( __redni_broj == 1 .AND. Val( _podbr ) < 1 )

      IF RecCount() == 0
         _idFirma := gFirma
      ENDIF

      IF !Empty( _params[ "def_rj" ] )
         _idfirma := _params[ "def_rj" ]
      ENDIF

      @ m_x + _x, m_y + 2 SAY PadR( gNFirma, 20 )

      @ m_x + _x, Col() + 2 SAY " RJ:" GET _idfirma ;
         PICT "@!" ;
         VALID {|| Empty( _idfirma ) .OR. _idfirma == gFirma ;
         .OR. P_RJ( @_idfirma ) .AND. V_Rj(), _idfirma := Left( _idfirma, 2 ), .T. }

      READ

      __mx := m_x
      __my := m_y

      _old_tip_dok := field->idtipdok

      _n_menu := Menu2( 5, 30, _a_tipdok, _n_menu )

      m_x := __mx
      m_y := __my

      ESC_RETURN 0

      IF _a_tipdok == NIL .OR. Len( _a_tipdok ) == 0
         MsgBeep( "Odabir vrste dokumenta se vrši sa ENTER !" )
         RETURN 0
      ENDIF

      IF _n_menu == NIL .OR. _n_menu > LEN( _a_tipdok ) .OR. _n_menu < 0
         MsgBeep( "Nepostojeća opcija !" )
         RETURN 0
      ENDIF

      _idtipdok := Left( _a_tipdok[ _n_menu ], 2 )

      ++ _x
      @ m_x + _x, m_y + 2 SAY PadR( fakt_naziv_dokumenta( @_a_tipdok, _idtipdok ), 40 )

      IF !fNovi .AND. __redni_broj == 1
         IF _idtipdok <> _old_tip_dok .AND. !Empty( field->brdok ) .AND. AllTrim( field->brdok ) <> "00000"
            MsgBeep( "Vršite promjenu vrste dokumenta. Obratiti pažnju na broj !" )
            IF Pitanje(, "Resetovati broj dokumenta na 00000 (D/N) ?", "D" ) == "D"
               _brdok := PadR( Replicate( "0", gNumDio ), 8 )
            ENDIF
         ENDIF
      ENDIF

      DO WHILE .T.

         _x := 2

         @  m_x + _x, m_y + 45 SAY "Datum:" GET _datdok
         @  m_x + _x, Col() + 1 SAY "Broj:" GET _brdok VALID !Empty( _brdok )

         _x += 2
         @ _part_x := m_x + _x, _part_y := m_y + 2 SAY "Partner:" GET _idpartner ;
            PICT "@!" ;
            VALID {|| P_Firma( @_idpartner ), ;
            IzSifre(), ispisi_partn( _idpartner, _part_x, _part_y + 18 ) }

         _x += 2

         IF _params[ "fakt_dok_veze" ]
            @ m_x + _x, m_y + 2 SAY "Vezni dok.:" GET _dokument_veza ;
               PICT "@S20"
         ENDIF

         ++ _x
         IF _params[ "destinacije" ]
            @ m_x + _x, m_y + 2 SAY "Dest:" GET _destinacija ;
               PICT "@S20"
         ENDIF

         IF ( _params[ "fakt_objekti" ] .AND. _idtipdok $ "10#11#12#13" )
            @ m_x + _x, Col() + 1 SAY "Objekat:" GET _objekti ;
               VALID p_fakt_objekti( @_objekti ) ;
               PICT "@!"
         ENDIF

         _x2 := 4

         IF _idtipdok $ "10#11"

            @ m_x + _x2, m_y + 51 SAY8 "Otpremnica broj:" GET _brotp PICT "@S20" WHEN W_BrOtp( fNovi )

            ++ _x2
            @ m_x + _x2, m_y + 51 SAY8 "          datum:" GET _datotp

            ++ _x2
            @ m_x + _x2, m_y + 51 SAY8 "Ugovor/narudžba:" GET _brnar PICT "@S20"

            IF fNovi .AND. gRokPl > 0
               _rok_placanja := gRokPl
            ENDIF

            ++ _x2
            @ m_x + _x2, m_y + 51 SAY8 "Rok plać.(dana):" GET _rok_placanja PICT "999" ;
               WHEN valid_rok_placanja( @_rok_placanja, "0", fNovi ) VALID valid_rok_placanja( _rok_placanja, "1", fNovi )

            ++ _x2
            @ m_x + _x2, m_y + 51 SAY8 "Datum plaćanja :" GET _datpl VALID valid_rok_placanja( _rok_placanja, "2", fNovi )

            IF _params[ "fakt_vrste_placanja" ]

               ++ _x
               @ m_x + _x, m_y + 2 SAY8 "Način plaćanja" GET _idvrstep PICT "@!" VALID Empty( _idvrstep ) .OR. P_VRSTEP( @_idvrstep, 9, 20 )

            ENDIF


         ELSEIF ( _idtipdok == "06" )

            ++ _x2
            @ m_x + _x2, m_y + 51 SAY "Po ul.fakt.broj:" GET _brotp PICT "@S20" WHEN W_BrOtp( fNovi )

            ++ _x2

            @ m_x + _x2, m_y + 51 SAY "       i UCD-u :" GET _brnar PICT "@S20"

         ELSE

            _datotp := _datdok
            ++ _x2
            @ m_x + _x2,m_y + 51 SAY " datum isporuke:" GET _datotp

         ENDIF

         IF ( fakt_pripr->( FieldPos( "idrelac" ) ) <> 0 .AND. _idtipdok $ "#11#" )
            ++ _x
            @ m_x + _x, m_y + 50  SAY "Relacija   :" GET _idrelac PICT "@S10"
         ENDIF

         _x += 3

         IF _idTipDok $ "10#11#12#19#20#25#26#27"
            @ m_x + _x, m_y + 2 SAY "Valuta ?" GET _dindem PICT "@!"
         ELSE
            @ m_x + _x, m_y + 2 SAY " "
         ENDIF

         IF _idtipdok $ "10"

            _avansni_racun := "N"

            IF _idvrstep == "AV"
               _avansni_racun := "D"
            ENDIF

            @ m_x + _x, Col() + 4 SAY8 "Avansni račun (D/N)?:" GET _avansni_racun PICT "@!" ;
               VALID _avansni_racun $ "DN"

         ENDIF

         IF ( gIspPart == "N" )
            READ
         ENDIF

         ESC_RETURN 0

         select_fakt_pripr()

         EXIT

      ENDDO

   ELSE

      @ m_x + _x, m_y + 2 SAY PadR( gNFirma, 20 )

      ?? "  RJ:", _idfirma

      _x += 2
      @ m_x + _x, m_y + 2 SAY PadR( fakt_naziv_dokumenta( @_a_tipdok, _idtipdok ), 35 )

      @ m_x + _x, m_y + 45 SAY "Datum: "
      ?? _datdok

      @ m_x + _x, Col() + 1 SAY "Broj: "
      ?? _brdok

      _txt2 := ""

   ENDIF


   _x := 13

   @ m_x + _x, m_y + 2 SAY "R.br: " GET __redni_broj PICT "9999"

   _x += 2
   @ m_x + _x, m_y + 2  SAY "Artikal: " GET _IdRoba PICT "@!S10" ;
      WHEN {|| _idroba := PadR( _idroba, Val( gDuzSifIni ) ), W_Roba() } ;
      VALID {|| _idroba := iif( Len( Trim( _idroba ) ) < Val( gDuzSifIni ), ;
      Left( _idroba, Val( gDuzSifIni ) ), _idroba ), ;
      V_Roba(), ;
      artikal_kao_usluga( fnovi ), ;
      NijeDupla( fNovi ), ;
      zadnji_izlazi_info( _idpartner, _idroba, "F" ), ;
      _trenutno_na_stanju_kalk( _idfirma, _idtipdok, _idroba ) ;
      }


   ++ _x
   IF ( gSamokol != "D" .AND. !glDistrib )
      @ m_x + _x, m_y + 2 SAY get_serbr_opis() + " " GET _serbr PICT "@S15" WHEN _podbr <> " ."
   ENDIF

   _tip_cijene := "1"

   IF ( gVarC $ "123" .AND. _idtipdok $ "10#12#20#21#25" )
      @ m_x + _x, m_y + 59 SAY "Cijena (1/2/3):" GET _tip_cijene
   ENDIF

   IF _params[ "fakt_opis_stavke" ]
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Opis:" GET _opis PICT "@S50"
   ENDIF

   IF _params[ "ref_lot" ]
      ++ _x
      @ m_x + _x, m_y + 2 SAY "REF:" GET _ref_broj PICT "@S10"
      @ m_x + _x, m_y + 2 SAY "/ LOT:" GET _lot_broj PICT "@S10"
   ENDIF

   _x += 3
   @ m_x + _x, m_y + 2 SAY8 "Količina "  GET _kolicina PICT pickol VALID V_Kolicina( _tip_cijene )


   IF gSamokol != "D"

      @ m_x + _x, Col() + 2 SAY IF( _idtipdok $ "13#23" .AND. ( gVar13 == "2" .OR. glCij13Mpc ), ;
         "MPC.s.PDV", "Cijena (" + AllTrim( ValDomaca() ) + ")" ) GET _cijena ;
         PICT piccdem ;
         WHEN  _podbr <> " ." ;
         VALID c_cijena( _cijena, _idtipdok, fNovi )


      IF ( PadR( _dindem, 3 ) <> PadR( ValDomaca(), 3 ) )
         @ m_x + _x, Col() + 2 SAY "Pr"  GET _convert ;
            PICT "@!" ;
            VALID v_pretvori( @_convert, _dindem, _datdok, @_cijena )
      ENDIF

      IF !( _idtipdok $ "12#13" ) .OR. ( _idtipdok == "12" .AND. gV12Por == "D" )

         @ m_x + _x, Col() + 2 SAY "Rabat" GET _rabat PICT piccdem ;
            WHEN _podbr <> " ." .AND. ! _idtipdok $ "15"

         @ m_x + _x, Col() + 1 GET _tip_rabat PICT "@!" ;
            WHEN {|| _tip_rabat := "%", ! _idtipdok $ "11#27#15" .AND. _podbr <> " ." } ;
            VALID _tip_rabat $ "% AUCI" .AND. V_Rabat( _tip_rabat )

      ENDIF

   ENDIF

   READ

   IF _avansni_racun == "D"
      _idvrstep := "AV"
   ENDIF

   ESC_RETURN 0

   _odabir_txt := .T.

   IF _IdTipDok $ "13" .OR. gSamoKol == "D"
      _odabir_txt := .F.
   ENDIF

   IF _idtipdok == "12"
      IF IsKomision( _idpartner )
         _odabir_txt := .T.
      ELSE
         _odabir_txt := .F.
      ENDIF
   ENDIF

   IF _odabir_txt
      _lista_uzoraka := g_txt_tipdok( _idtipdok )
      UzorTxt2( _lista_uzoraka, __redni_broj )
   ENDIF

   IF ( _podbr == " ." .OR. roba->tip = "U" .OR. ( __redni_broj == 1 .AND. Val( _podbr ) < 1 ) )
      _set_memo_txt_from_vars()
   ELSE
      _txt := ""
   ENDIF

   _rbr := RedniBroj( __redni_broj )

   IF _params[ "fakt_opis_stavke" ]
      items_atrib[ "opis" ] := _opis
   ENDIF
   IF _params[ "ref_lot" ]
      items_atrib[ "ref" ] := _ref_broj
      items_atrib[ "lot" ] := _lot_broj
   ENDIF

   IF ALLTRIM(_rbr) == "1"
      show_last_racun(_idpartner, _destinacija, _idroba)
   ENDIF

   RETURN 1


STATIC FUNCTION show_last_racun(cIdPartner, cDestinacija, cIdRoba)

cRacun := "00000000"
cDestinacija := ALLTRIM( cDestinacija )
select_fakt_pripr()
PushWa()

GO TOP

Box( , 6, 100)
DO WHILE !EOF()
@ m_x + 1, m_y + 2 SAY "Partner: " + cIdPartner
@ m_x + 2, m_y + 2 SAY "Destinacija: " + cDestinacija
@ m_x + 3, m_y + 2 SAY "Rbr: " + field->rbr
@ m_x + 4, m_y + 2 SAY "Roba: " + field->idroba + " kol: " + ALLTRIM(STR(field->kolicina, 6, 2))
@ m_x + 5, m_y + 2 SAY "Raniji racun: " + fakt_za_destinaciju( cIDPartner, cDestinacija, field->idroba )

INKEY(0)
SKIP
ENDDO
PopWa()
BoxC()
RETURN

FUNCTION fakt_za_destinaciju( cIdPartner, cDestinacija, cIdRoba )

LOCAL cQuery, oRez
LOCAL oServer := pg_server()
LOCAL cBrDok, oRow

cQuery := "SELECT brdok FROM fmk.fakt_fakt" + ;
   " WHERE idtipdok='10' AND kolicina>0  AND txt like '%" + cDestinacija + "%' AND idpartner=" + _sql_quote( cIdPartner )

oRez := _sql_query( oServer, cQuery )

IF oRez == NIL
   RETURN -1
ENDIF

altd()
cBrDok := ""
DO WHILE !oRez:EOF()
   oRow := oRez:getRow()
   cBrDok += oRow:fieldGet(1) + "/"
   oRez:skip()
ENDDO

RETURN cBrDok


STATIC FUNCTION _trenutno_na_stanju_kalk( id_rj, tip_dok, id_roba )

   LOCAL _stanje := NIL
   LOCAL _id_konto := ""
   LOCAL _t_area := Select()
   LOCAL _color := "W/N+"

   SELECT rj
   SET ORDER TO TAG "ID"
   GO TOP
   SEEK id_rj

   select_fakt_pripr()

   IF Empty( rj->konto )
      RETURN .T.
   ENDIF

   _id_konto := rj->konto

   SELECT ( _t_area )

   IF tip_dok $ "10#12"
      _stanje := kalk_kol_stanje_artikla_magacin( _id_konto, id_roba, Date() )
   ELSEIF tip_dok $ "11#13"
      _stanje := kalk_kol_stanje_artikla_prodavnica( _id_konto, id_roba, Date() )
   ENDIF

   IF _stanje <> NIL

      IF _stanje <= 0
         _color := "W/R+"
      ENDIF

      @ m_x + 17, m_y + 28 SAY PadR( "", 60 )
      @ m_x + 17, m_y + 28 SAY "Na stanju konta " + ;
         AllTrim( _id_konto ) + " : "
      @ m_x + 17, Col() + 1 SAY AllTrim( Str( _stanje, 12, 3 ) ) + " " + PadR( roba->jmj, 3 ) COLOR _color
   ENDIF

   RETURN .T.





STATIC FUNCTION _f_idpm( cIdPm )

   cIdPM := Upper( cIdPM )

   RETURN .T.




// ---------------------------------------------
// vraca listu za odredjeni tip dok
// ---------------------------------------------
FUNCTION g_txt_tipdok( cIdTd )

   LOCAL cList := ""
   LOCAL cVal
   PRIVATE cTmptxt

   IF !Empty( cIdTd ) .AND. cIdTD $ "10#11#12#13#15#16#20#21#22#23#25#26#27"

      cTmptxt := "g" + cIdTd + "ftxt"
      cVal := &cTmptxt

      IF !Empty( cVal )
         cList := AllTrim( cVal )
      ENDIF

   ENDIF

   RETURN cList



// -------------------------------------------------
// validacija roka placanja
// -------------------------------------------------
FUNCTION valid_rok_placanja( rok_pl, var, novi )

   LOCAL _rok_pl_nula := .T.

   // ako je dozvoljen rok.placanja samo > 0
   IF gVFRP0 == "D"
      _rok_pl_nula := .F.
   ENDIF

   IF var == "0"

      IF rok_pl < 0
         RETURN .T.
      ENDIF

      IF !novi
         IF Empty( _datpl )
            rok_pl := 0
         ELSE
            rok_pl := _datpl - _datdok
         ENDIF
      ENDIF

   ELSEIF var == "1"

      IF !_rok_pl_nula
         IF rok_pl < 1
            MsgBeep( "Obavezno unjeti broj dana !" )
            RETURN .F.
         ENDIF
      ENDIF

      IF rok_pl < 0
         // moras unijeti pozitivnu vrijednost ili 0
         MsgBeep( "Unijeti broj dana !" )
         RETURN .F.
      ENDIF

      IF rok_pl = 0 .AND. gRokPl < 0
         _datPl := CToD( "" )
      ELSE
         _datPl := _datdok + rok_pl
      ENDIF

   ELSE

      IF Empty( _datpl )
         rok_pl := 0
      ELSE
         rok_pl := _datpl - _datdok
      ENDIF

   ENDIF

   ShowGets()

   RETURN .T.






FUNCTION ArgToStr( xArg )

   IF ( xArg == NIL )
      RETURN "NIL"
   ELSE
      RETURN "'" + xArg + "'"
   ENDIF



   // --------------------------------------------------
   // Prerada cijene
   // Ako je u polje SERBR unesen podatak KJ/KG iznos se
   // dobija kao KOLICINA * CIJENA * PrerCij()
   // varijanta R - Rudnik
   // --------------------------------------------------

FUNCTION PrerCij()

   LOCAL _ser_br := AllTrim( _field->serbr )
   LOCAL _ret := 1

   IF !Empty( _ser_br ) .AND. _ser_br != "*" .AND. is_fakt_ugalj()
      _ret := Val( _ret ) / 1000
   ENDIF

   RETURN _ret





// Stampa dokumenta ugovor o rabatu
FUNCTION StUgRabKup()

   lUgRab := .T.
   lSSIP99 := .F.
   // StDok2()
   lUgRab := .F.

   RETURN



// ----------------------------------
// ----------------------------------
FUNCTION IspisBankeNar( cBanke )

   LOCAL aOpc

   O_BANKE
   aOpc := TokToNiz( cBanke, "," )
   cVrati := ""

   SELECT banke
   SET ORDER TO TAG "ID"
   FOR i := 1 TO Len( aOpc )
      hseek SubStr( aOpc[ i ], 1, 3 )
      IF Found()
         cVrati += AllTrim( banke->naz ) + ", " + AllTrim( banke->adresa ) + ", " + AllTrim( banke->mjesto ) + ", " + AllTrim( aOpc[ i ] ) + "; "
      ELSE
         cVrati += ""
      ENDIF
   NEXT
   SELECT partn

   RETURN cVrati




/*! \fn JeStorno10()
 *  \brief True je distribucija i TipDokumenta=10  i krajnji desni dio broja dokumenta="S"
 */
FUNCTION JeStorno10()
   RETURN glDistrib .AND. _idtipdok == "10" .AND. Upper( Right( Trim( _BrDok ), 1 ) ) == "S"



/*! \fn RabPor10()
 *  \brief
 */

FUNCTION RabPor10()

   LOCAL nArr := Select()

   SELECT FAKT
   SET ORDER TO TAG "1"
   SEEK _idfirma + "10" + Left( _brdok, gNumDio )

   DO WHILE !Eof() .AND. ;
         _idfirma + "10" + Left( _brdok, gNumDio ) == idfirma + idtipdok + Left( brdok, gNumDio ) .AND. ;
         _idroba <> idroba
      SKIP 1
   ENDDO

   IF _idfirma + "10" + Left( _brdok, gNumDio ) == idfirma + idtipdok + Left( brdok, gNumDio )
      _rabat    := rabat
      _porez    := porez
      // i cijenu, sto da ne?
      _cijena   := cijena
   ELSE
      MsgBeep( "Izabrana roba ne postoji u fakturi za storniranje!" )
   ENDIF
   SELECT ( nArr )

   RETURN




// ---------------------------------------------------------------
// ostale opcije u pripremi dokumenta
// ---------------------------------------------------------------
STATIC FUNCTION popup_fakt_unos_dokumenta()

   PRIVATE opc[ 8 ]

   opc[ 1 ] := "1. generacija faktura na osnovu ugovora            "
   opc[ 2 ] := "2. sredjivanje rednih br.stavki dokumenta"
   opc[ 3 ] := "3. ispravka teksta na kraju fakture"
   opc[ 4 ] := "4. svedi protustavkom vrijednost dokumenta na 0"
   opc[ 5 ] := "5. priprema => smece"
   opc[ 6 ] := "6. smece    => priprema"
   opc[ 7 ] := "7. "
   opc[ 8 ] := "8. "

   lKonsig := .F.

   IF lKonsig
      AAdd( opc, "9. generisi konsignacioni racun" )
   ELSE
      AAdd( opc, "-----------------------------------------------" )
   ENDIF

   AAdd( opc, "A. kompletiranje iznosa fakture pomocu usluga" )
   AAdd( opc, "-----------------------------------------------" )
   AAdd( opc, "C. import txt-a" )
   AAdd( opc, "U. stampa ugovora od do " )

   h[ 1 ] := h[ 2 ] := ""

   my_close_all_dbf()
   PRIVATE am_x := m_x, am_y := m_y
   PRIVATE Izbor := 1

   DO WHILE .T.

      Izbor := menu( "prip", opc, Izbor, .F. )

      DO CASE
      CASE Izbor == 0
         EXIT
      CASE izbor == 1
         m_gen_ug()
      CASE izbor == 2
         fakt_sredi_redni_broj_u_pripremi()
      CASE izbor == 3
         O_FAKT_S_PRIPR
         O_FTXT
         select_fakt_pripr()
         GO TOP
         lDoks2 := ( IzFMKINI( "FAKT", "Doks2", "N", KUMPATH ) == "D" )
         IF Val( rbr ) <> 1
            MsgBeep( "U pripremi se ne nalazi dokument" )
         ELSE
            IsprUzorTxt()
         ENDIF
         my_close_all_dbf()
      CASE izbor == 4
         O_ROBA
         O_TARIFA
         O_FAKT_S_PRIPR
         GO TOP
         nDug := 0
         DO WHILE !Eof()
            scatter()
            nDug += Round( _Cijena * _kolicina * ( 1 -_Rabat / 100 ), ZAOKRUZENJE )
            SKIP
         ENDDO

         _idroba := Space( 10 )
         _kolicina := 1
         _rbr := Str( RbrUnum( _Rbr ) + 1, 3, 0 )
         _rabat := 0

         cDN := "D"
         Box(, 4, 60 )
         @ m_x + 1,m_y + 2 SAY "Artikal koji se stvara:" GET _idroba  PICT "@!" VALID P_Roba( @_idroba )
         @ m_x + 2,m_y + 2 SAY "Kolicina" GET _kolicina valid {|| _kolicina <> 0 } PICT pickol
         READ
         IF LastKey() == K_ESC
            boxc()
            my_close_all_dbf()
            RETURN DE_CONT
         ENDIF
         _cijena := nDug / _kolicina
         IF _cijena < 0
            _Cijena := -_cijena
         ELSE
            _kolicina := -_kolicina
         ENDIF
         @ m_x + 3,m_y + 2 SAY "Cijena" GET _cijena  PICT piccdem
         cDN := "D"
         @ m_x + 4,m_y + 2 SAY8 "Staviti cijenu u šifarnik ?" GET cDN VALID cDN $ "DN" PICT "@!"
         READ
         IF cDN == "D"
            SELECT roba
            my_rlock()
            REPLACE vpc WITH _cijena
            my_unlock()
            SELECT fakt_pripr
         ENDIF
         IF LastKey() = K_ESC
            boxc()
            my_close_all_dbf()
            RETURN DE_CONT
         ENDIF
         APPEND BLANK
         Gather()
         BoxC()
      CASE izbor == 5

         azuriraj_smece()

      CASE izbor == 6

         povrat_smece()

      CASE izbor == 7 .OR. izbor == 8
         RETURN DE_CONT

      ENDCASE

   ENDDO

   m_x := am_x
   m_y := am_y

   close_open_fakt_tabele()
   select_fakt_pripr()

   GO BOTTOM

   RETURN



// --------------------------------------------------------------------
// izmjeni sve stavke dokumenta prema tekucoj stavci
// ovo treba da radi samo na stavci broj 1
// --------------------------------------------------------------------
STATIC FUNCTION izmjeni_sve_stavke_dokumenta( old_dok, new_dok )

   LOCAL _old_firma := old_dok[ "idfirma" ]
   LOCAL _old_brdok := old_dok[ "brdok" ]
   LOCAL _old_tipdok := old_dok[ "idtipdok" ]
   LOCAL _rec, _tek_dok, _t_rec
   LOCAL _new_firma := new_dok[ "idfirma" ]
   LOCAL _new_brdok := new_dok[ "brdok" ]
   LOCAL _new_tipdok := new_dok[ "idtipdok" ]
   LOCAL oAtrib

   // treba da imam podatke koja je stavka bila prije korekcije
   // kao i koja je nova
   // misli se na "idfirma + tipdok + brdok"

   select_fakt_pripr()
   GO TOP

   // uzmi podatke sa izmjenjene stavke
   SEEK _new_firma + _new_tipdok + _new_brdok

   IF !Found()
      RETURN .F.
   ENDIF

   _tek_dok := dbf_get_rec()

   // zatim mi pronadji ostale stavke bivseg dokumenta
   GO TOP
   SEEK _old_firma + _old_tipdok + _old_brdok

   IF !Found()
      RETURN .F.
   ENDIF

   DO WHILE !Eof() .AND. field->idfirma + field->idtipdok + field->brdok == ;
         _old_firma + _old_tipdok + _old_brdok

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      // napravi zamjenu podataka
      _rec := dbf_get_rec()
      _rec[ "idfirma" ] := _tek_dok[ "idfirma" ]
      _rec[ "idtipdok" ] := _tek_dok[ "idtipdok" ]
      _rec[ "brdok" ] := _tek_dok[ "brdok" ]
      _rec[ "datdok" ] := _tek_dok[ "datdok" ]
      _rec[ "idpartner" ] := _tek_dok[ "idpartner" ]
      _rec[ "dindem" ] := _tek_dok[ "dindem" ]

      dbf_update_rec( _rec )

      GO ( _t_rec )

   ENDDO
   GO TOP

   oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )
   oAtrib:open_local_table()

   GO TOP

   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      _rec := dbf_get_rec()

      _rec[ "idfirma" ] := _tek_dok[ "idfirma" ]
      _rec[ "idtipdok" ] := _tek_dok[ "idtipdok" ]
      _rec[ "brdok" ] := _tek_dok[ "brdok" ]

      dbf_update_rec( _rec )

      GO ( _t_rec )

   ENDDO
   // zatvori atribute
   USE

   select_fakt_pripr()
   GO TOP

   RETURN .T.



// -----------------------------------------------
// izvuci mi total dokumenta
// -----------------------------------------------
STATIC FUNCTION _total_dokumenta()

   LOCAL _x, _y
   LOCAL __x := 1
   LOCAL _left := 20
   LOCAL _doc_total := hb_Hash()
   LOCAL _doc_total2 := 0
   LOCAL _t_area := Select()
   LOCAL _din_dem

   IF fakt_pripr->( RecCount() ) == 0 .OR. ! ( fakt_pripr->idtipdok $ "10#11#12#20" )
      RETURN
   ENDIF

   _x := MAXROWS() - 20
   _y := MAXCOLS() - 50

   // valuta ?
   _din_dem := fakt_pripr->dindem

   // izvuci mi dokument u temp tabele
   stdokpdv( nil, nil, nil, .T. )

   // sracunaj totale...
   _calc_totals( @_doc_total, _din_dem )

   // prikazi box
   Box(, _x, _y )

   @ m_x + __x, m_y + 2 SAY PadR( "TOTAL DOKUMENTA:", _y - 2 ) COLOR "I"

   ++ __x
   ++ __x

   @ m_x + __x, m_y + 2 SAY PadL( "Osnovica: ", _left ) + Str( _doc_total[ "osn" ], 12, 2 )

   ++ __x

   @ m_x + __x, m_y + 2 SAY PadL( "Popust: ", _left ) + Str( _doc_total[ "pop" ], 12, 2 )

   ++ __x

   @ m_x + __x, m_y + 2 SAY PadL( "Osnovica - popust: ", _left ) + Str( _doc_total[ "osn_pop" ], 12, 2 )

   ++ __x

   @ m_x + __x, m_y + 2 SAY PadL( "PDV: ", _left ) + Str( _doc_total[ "pdv" ], 12, 2 )

   ++ __x

   @ m_x + __x, m_y + 2 SAY Replicate( "=", _left )

   ++ __x

   @ m_x + __x, m_y + 2 SAY PadL( "Ukupno sa PDV (" + AllTrim( _din_dem ) + "): ", _left ) + Str( _doc_total[ "total" ], 12, 2 )

   IF Left( _din_dem, 3 ) <> Left( ValBazna(), 3 )
      ++ __x
      @ m_x + __x, m_y + 2 SAY PadL( "Ukupno sa PDV (" + AllTrim( ValBazna() ) + "): ", _left ) + Str( _doc_total[ "total2" ], 12, 2 )
   ENDIF

   WHILE Inkey( 0.1 ) != K_ESC
   END

   BoxC()

   SELECT ( _t_area )

   RETURN


// ------------------------------------------------
// sracunaj total na osnovu stampe dokumenta
// ------------------------------------------------
STATIC FUNCTION _calc_totals( hash, din_dem )

   LOCAL _t_area := Select()

   hash[ "osn" ] := 0
   hash[ "pop" ] := 0
   hash[ "osn_pop" ] := 0
   hash[ "pdv" ] := 0
   hash[ "total" ] := 0
   hash[ "total2" ] := 0

   SELECT drn
   GO TOP

   IF RecCount() <> 0

      hash[ "osn" ] := field->ukbezpdv
      hash[ "pop" ] := field->ukpopust
      hash[ "osn_pop" ] := field->ukbpdvpop
      hash[ "pdv" ] := field->ukpdv
      hash[ "total" ] := field->ukupno

      IF Left( din_dem, 3 ) <> Left( ValBazna(), 3 )
         hash[ "total2" ] := field->ukupno * OmjerVal( ValBazna(), din_dem, field->datdok )
      ENDIF

   ENDIF

   SELECT ( _t_area )

   RETURN




// ---------------------------------------------------
// kontrola zbira - fakt dokument
//
// ovdje treba promjeniti logiku i uzeti stampanje
// fakture i onda ocitati podatke...
// todo
// ---------------------------------------------------
STATIC FUNCTION fakt_kzb( id_firma, tip_dok, br_dok )

   LOCAL _dug := 0
   LOCAL _rab := 0
   LOCAL _por := 0
   LOCAL _din_dem := field->dindem
   LOCAL _tmp := 1

   Box(, 12, MAXCOLS() - 5 )

   IF _tmp > 9

      WHILE Inkey( 0.1 ) != K_ESC
      END

      @ m_x + 1, m_y + 2 CLEAR TO m_x + 12, MAXCOLS() - 5

      _tmp := 1

      @ m_x, m_y + 2 SAY ""

   ENDIF

   @ m_x + _tmp, m_y + 2 SAY Replicate( "-", MAXCOLS() - 10 )

   @ m_x + _tmp + 1, m_y + 2 SAY PadR( "Ukupno   ", 30 )

   @ m_x + _tmp + 1, Col() + 1 SAY _dug PICT "9999999.99"

   @ m_x + _tmp + 1, Col() + 1 SAY _rab PICT "9999999.99"

   @ m_x + _tmp + 1, Col() + 1 SAY _dug - _rab PICT "9999999.99"

   @ m_x + _tmp + 1, Col() + 1 SAY _por PICT "9999999.99"

   @ m_x + _tmp + 1, Col() + 1 SAY ( _dug - _rab ) + _por PICT "9999999.99"

   @ m_x + _tmp + 1, Col() + 1 SAY "(" + _din_dem + ")"

   WHILE Inkey( 0.1 ) != K_ESC
   END

   BoxC()

   RETURN




FUNCTION select_fakt_pripr()

   SELECT F_FAKT_PRIPR

   IF !Used()
      close_open_fakt_tabele()
      SELECT F_FAKT_PRIPR
   ENDIF

   RETURN
