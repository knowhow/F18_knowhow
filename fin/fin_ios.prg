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
STATIC R1
STATIC R2
STATIC __ios_clan := ""



FUNCTION ios()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   picBHD := "@Z " + ( R1 := FormPicL( "9 " + gPicBHD, 16 ) )
   picDEM := "@Z " + ( R2 := FormPicL( "9 " + gPicDEM, 12 ) )
   R1 := R1 + " " + ValDomaca()
   R2 := R2 + " " + ValPomocna()

   //AAdd( _opc, "1. specifikacija IOS-a (pregled podataka prije štampe) " )
   //AAdd( _opcexe, {|| ios_specifikacija() } )
   AAdd( _opc, "1. štampa IOS-a" )
   AAdd( _opcexe, {|| mnu_ios_print() } )
   //AAdd( _opc, "3. generisanje podataka za štampu IOS-a" )
   //AAdd( _opcexe, {|| ios_generacija_podataka() } )
   AAdd( _opc, "2. podešenje član-a" )
   AAdd( _opcexe, {|| ios_clan_setup() } )


   f18_menu( "ios", .F., _izbor, _opc, _opcexe )

   RETURN .T.





STATIC FUNCTION mnu_ios_print()

   LOCAL _datum_do := Date()
   LOCAL _params := hb_Hash()
   LOCAL _gen_par := hb_Hash()
   LOCAL cIdFirma := gFirma
   LOCAL cIdKonto := fetch_metric( "ios_print_id_konto", my_user(), Space( 7 ) )
   LOCAL _id_partner := fetch_metric( "ios_print_id_partner", my_user(), Space( 6 ) )
   LOCAL _din_dem := "1"
   LOCAL _kao_kartica := fetch_metric( "ios_print_kartica", my_user(), "D" )
   LOCAL _prelomljeno := fetch_metric( "ios_print_prelom", my_user(), "N" )
   LOCAL _export_dbf := "N"
   LOCAL _print_tip := fetch_metric( "ios_print_tip", my_user(), "2" )
   LOCAL _auto_gen := fetch_metric( "ios_auto_gen", my_user(), "D" )
   LOCAL _ios_date := Date()
   LOCAL _x := 1
   LOCAL _launch, _exp_fields
   LOCAL _xml_file := my_home() + "data.xml"
   LOCAL _template := "ios.odt"

   O_KONTO
   O_PARTN

   Box(, 16, 65, .F. )

   @ m_x + _x, m_y + 2 SAY " Stampa IOS-a **** "

   ++_x
   ++_x
   @ m_x + _x, m_y + 2 SAY "       Datum IOS-a:" GET _ios_date

   ++_x

   @ m_x + _x, m_y + 2 SAY " Gledati period do:" GET _datum_do

   ++_x
   ++_x
   @ m_x + _x, m_y + 2 SAY "Firma "
   ?? gFirma, "-", gNFirma

   ++_x
   @ m_x + _x, m_y + 2 SAY "Konto       :" GET cIdKonto VALID P_Konto( @cIdKonto )
   ++_x
   @ m_x + _x, m_y + 2 SAY "Partner     :" GET _id_partner ;
      VALID Empty( _id_partner ) .OR.  p_partner( @_id_partner ) PICT "@!"

   IF fin_dvovalutno()
      ++_x
      @ m_x + _x, m_y + 2 SAY "Prikaz " + ;
         AllTrim( ValDomaca() ) + "/" + ;
         AllTrim( ValPomocna() ) + " (1/2)" ;
         GET _din_dem VALID _din_dem $ "12"
   ENDIF

   ++_x
   ++_x
   @ m_x + _x, m_y + 2 SAY "Prikaz prebijenog stanja " GET _prelomljeno ;
      VALID _prelomljeno $ "DN" PICT "@!"

   ++_x
   @ m_x + _x, m_y + 2 SAY "Prikaz identicno kartici " GET _kao_kartica ;
      VALID _kao_kartica $ "DN" PICT "@!"

   ++_x
   ++_x
   @ m_x + _x, m_y + 2 SAY "Eksport podataka u dbf (D/N) ?" GET _export_dbf ;
      VALID _export_dbf $ "DN" PICT "@!"

   ++_x

   @ m_x + _x, m_y + 2 SAY "Nacin stampe ODT/TXT (1/2) ?" GET _print_tip ;
      VALID _print_tip $ "12"

   ++_x

   @ m_x + _x, m_y + 2 SAY "Generisi podatke IOS-a automatski kod pokretanja (D/N) ?" GET _auto_gen ;
      VALID _auto_gen $ "DN" PICT "@!"


   READ

   ESC_BCR

   BoxC()

   set_metric( "ios_print_id_konto", my_user(), cIdKonto )
   set_metric( "ios_print_id_partner", my_user(), _id_partner )
   set_metric( "ios_print_kartica", my_user(), _kao_kartica )
   set_metric( "ios_print_prelom", my_user(), _prelomljeno )
   set_metric( "ios_print_tip", my_user(), _print_tip )

   cIdFirma := Left( cIdFirma, 2 )

   ios_clan_setup( .F. )    // definisi clan i setuj staticku varijablu

   IF _auto_gen == "D"    // generisi podatke u tabelu prije same stampe

      _gen_par := hb_Hash()
      _gen_par[ "id_konto" ] := cIdKonto
      _gen_par[ "id_firma" ] := cIdFirma
      _gen_par[ "saldo_nula" ] := "D"
      _gen_par[ "datum_do" ] := _datum_do
      //ios_generacija_podataka( _gen_par )     // generisi podatke u IOS tabelu

   ENDIF


   IF _export_dbf == "D"    // eksport podataka u dbf tabelu
      _exp_fields := g_exp_fields()
      create_dbf_r_export( _exp_fields )
   ENDIF


   O_KONTO
   O_PARTN
   o_suban()
   O_TNAL
   o_suban()
   O_IOS

   SELECT ios
   GO TOP

   SEEK cIdFirma + cIdKonto

   NFOUND CRET


   IF _print_tip == "2" // txt forma
      IF !start_print()
         RETURN .F.
      ENDIF
   ELSE
      create_xml( _xml_file )
      xml_head()
      xml_subnode( "ios", .F. )
   ENDIF

altd()
   SELECT ios

   DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cIdKonto == field->idkonto

      cIdPartner := field->idpartner


      IF !Empty( _id_partner )       // pronadji za partnera
         IF cIdPartner <> _id_partner
            SKIP
            LOOP
         ENDIF
      ENDIF

      _params := hb_Hash()
      _params[ "id_partner" ] := cIdPartner
      _params[ "id_konto" ] := cIdKonto
      _params[ "id_firma" ] := cIdFirma
      _params[ "din_dem" ] := _din_dem
      _params[ "datum_do" ] := _datum_do
      _params[ "ios_datum" ] := _ios_date
      _params[ "export_dbf" ] := _export_dbf
      _params[ "iznos_bhd" ] := ios->iznosbhd
      _params[ "iznos_dem" ] := ios->iznosdem
      _params[ "kartica" ] := _kao_kartica
      _params[ "prelom" ] := _prelomljeno

      IF _print_tip == "2"
         print_ios_txt( _params )
      ELSE
         print_ios_xml( _params )
      ENDIF

      SKIP

   ENDDO

   IF _print_tip == "2"
      end_print()
   ELSE

      xml_subnode( "ios", .T. )
      close_xml()

   ENDIF

   IF _print_tip == "2" .AND. _export_dbf == "D"
      f18_open_mime_document( my_home() + my_dbf_prefix() + "r_export.dbf" )
   ENDIF

   my_close_all_dbf()

   IF _print_tip == "1"

      IF Empty( _id_partner )
         _template := "ios_2.odt"
      ENDIF

      IF generisi_odt_iz_xml( _template, _xml_file )
         prikazi_odt()
      ENDIF

   ENDIF

   RETURN .T.


STATIC FUNCTION print_ios_xml( params )

   LOCAL _rbr
   LOCAL cIdFirma := params[ "id_firma" ]
   LOCAL cIdKonto := params[ "id_konto" ]
   LOCAL _id_partner := params[ "id_partner" ]
   LOCAL _iznos_bhd := params[ "iznos_bhd" ]
   LOCAL _iznos_dem := params[ "iznos_dem" ]
   LOCAL _din_dem := params[ "din_dem" ]
   LOCAL _datum_do := params[ "datum_do" ]
   LOCAL _ios_date := params[ "ios_datum" ]
   LOCAL _kao_kartica := params[ "kartica" ]
   LOCAL _prelomljeno := params[ "prelom" ]
   LOCAL _saldo_1, _saldo_2, __saldo_1, __saldo_2
   LOCAL _dug_1, _dug_2, _u_dug_1, _u_dug_2, _u_dug_1z, _u_dug_2z
   LOCAL _pot_1, _pot_2, _u_pot_1, _u_pot_2, _u_pot_1z, _u_pot_2z

   // <ios_item>
   //
   // <firma>
   // <id>10</id>
   // <naz>...</naz>
   // .....
   // </firma>
   //
   // <partner>
   // <id>1231</id>
   // <naz>PARTNER XZX</naz>
   // .....
   // </partner>
   //
   // <ios_datum></ios_datum>
   //
   //
   //
   // </ios_item>

   xml_subnode( "ios_item", .F. )


   // IF !_xml_partner( "firma", cIdFirma )    // maticna firma
   // ENDIF


   // IF !_xml_partner( "partner", _id_partner )    // partner
   // ENDIF

   xml_node( "ios_datum", DToC( _ios_date ) )
   xml_node( "id_konto", to_xml_encoding( cIdKonto ) )
   xml_node( "id_partner", to_xml_encoding( _id_partner ) )

   _total_bhd := _iznos_bhd
   _total_dem := _iznos_dem

   IF _iznos_bhd < 0
      _total_bhd := -_iznos_bhd
   ENDIF
   IF _iznos_dem < 0
      _total_dem := -_iznos_dem
   ENDIF

   IF _din_dem == "1"
      xml_node( "total", AllTrim( Str( _total_bhd, 12, 2 ) ) )
      xml_node( "valuta", to_xml_encoding ( ValDomaca() ) )
   ELSE
      xml_node( "total", AllTrim( Str( _total_dem, 12, 2 ) ) )
      xml_node( "valuta", to_xml_encoding ( ValPomocna() ) )
   ENDIF

   IF _iznos_bhd > 0
      xml_node( "dp", "1" )
   ELSE
      xml_node( "dp", "2" )
   ENDIF

   SELECT suban

   IF _kao_kartica == "D"
      // SET ORDER TO TAG "1"
      find_suban_by_konto_partner( cIdFirma, cIdKonto, _id_partner, NIL, "idfirma,idvn,brnal" )
   ELSE
      // SET ORDER TO TAG "3"
      find_suban_by_konto_partner( cIdFirma, cIdKonto, _id_partner, NIL, "IdFirma,IdKonto,IdPartner,brdok" )
   ENDIF


   _u_dug_1 := 0
   _u_dug_2 := 0
   _u_pot_1 := 0
   _u_pot_2 := 0
   _u_dug_1z := 0
   _u_dug_2z := 0
   _u_pot_1z := 0
   _u_pot_2z := 0


   IF _kao_kartica == "D" // ako je kartica, onda nikad ne prelamaj
      _prelomljeno := "N"
   ENDIF

   _rbr := 0

   DO WHILE !Eof() .AND. cIdFirma == field->IdFirma ;
         .AND. cIdKonto == field->IdKonto ;
         .AND. _id_partner == field->IdPartner

      __br_dok := field->brdok
      __dat_dok := field->datdok
      __opis := AllTrim( field->opis )
      __dat_val := fix_dat_var( field->datval )
      _dug_1 := 0
      _pot_1 := 0
      _dug_2 := 0
      _pot_2 := 0
      __otv_st := field->otvst

      DO WHILE !Eof() .AND. cIdFirma == field->IdFirma ;
            .AND. cIdKonto == field->IdKonto ;
            .AND. _id_partner == field->IdPartner ;
            .AND. ( _kao_kartica == "D" .OR. field->brdok == __br_dok )

         IF field->datdok > _datum_do
            SKIP
            LOOP
         ENDIF

         IF field->otvst = " "

            IF _kao_kartica == "D"


               xml_subnode( "data_kartica", .F. )

               xml_node( "rbr", AllTrim( Str( ++_rbr ) ) )
               xml_node( "brdok", to_xml_encoding( field->brdok ) )
               xml_node( "opis", to_xml_encoding( field->opis ) )
               xml_node( "datdok", DToC( field->datdok ) )
               xml_node( "datval", DToC( fix_dat_var( field->datval ) ) )

               IF _din_dem == "1"
                  xml_node( "dug", AllTrim( Str( iif( field->d_p == "1", field->iznosbhd, 0 ), 12, 2 ) ) )
                  xml_node( "pot", AllTrim( Str( iif( field->d_p == "2", field->iznosbhd, 0 ), 12, 2 ) ) )
               ELSE
                  xml_node( "dug", AllTrim( Str( iif( field->d_p == "1", field->iznosdem, 0 ), 12, 2 ) ) )
                  xml_node( "pot", AllTrim( Str( iif( field->d_p == "2", field->iznosdem, 0 ), 12, 2 ) ) )
               ENDIF

               xml_subnode( "data_kartica", .T. )

            ENDIF

            IF field->d_p = "1"
               _dug_1 += field->IznosBHD
               _dug_2 += field->IznosDEM
            ELSE
               _pot_1 += field->IznosBHD
               _pot_2 += field->IznosDEM
            ENDIF

            __otv_st := " "

         ELSE

            // zatvorene stavke
            IF field->d_p == "1"
               _u_dug_1z += field->IznosBHD
               _u_dug_2z += field->IznosDEM
            ELSE
               _u_pot_1z += field->IznosBHD
               _u_pot_2z += field->IznosDEM
            ENDIF

         ENDIF

         SKIP

      ENDDO

      IF __otv_st == " "

         IF _prelomljeno == "D"

            IF _din_dem == "1"

               IF ( _dug_1 - _pot_1 ) > 0    // domaca valuta
                  _dug_1 := ( _dug_1 - _pot_1 )
                  _pot_1 := 0
               ELSE
                  _pot_1 := ( _pot_1 - _dug_1 )
                  _dug_1 := 0
               ENDIF
            ELSE
               IF ( _dug_2 - _pot_2 ) > 0  // strana valuta
                  _dug_2 := ( _dug_2 - _pot_2 )
                  _pot_2 := 0
               ELSE
                  _pot_2 := ( _pot_2 - _dug_2 )
                  _dug_2 := 0
               ENDIF

            ENDIF

         ENDIF

         IF _kao_kartica == "N"


            IF !( Round( _dug_1, 2 ) == 0 .AND. Round( _pot_1, 2 ) == 0 ) // ispisi ove stavke ako dug i pot <> 0

               xml_subnode( "data_kartica", .F. )

               xml_node( "rbr", AllTrim( Str( ++_rbr ) ) )
               xml_node( "brdok", to_xml_encoding( __br_dok ) )
               xml_node( "opis", to_xml_encoding( __opis ) )
               xml_node( "datdok", DToC( fix_dat_var( __dat_dok ) ) )
               xml_node( "datval", DToC( fix_dat_var( __dat_val ) ) )
               xml_node( "dug", AllTrim( Str( _dug_1, 12, 2 ) ) )
               xml_node( "pot", AllTrim( Str( _pot_1, 12, 2 ) ) )

               xml_subnode( "data_kartica", .T. )

            ENDIF

         ENDIF

         _u_dug_1 += _dug_1
         _u_pot_1 += _pot_1
         _u_dug_2 += _dug_2
         _u_pot_2 += _pot_2

      ENDIF

   ENDDO


   _saldo_1 := ( _u_dug_1 - _u_pot_1 ) // saldo
   _saldo_2 := ( _u_dug_2 - _u_pot_2 )

   IF _din_dem == "1"

      xml_node( "u_dug", AllTrim( Str( _u_dug_1, 12, 2 ) ) )
      xml_node( "u_pot", AllTrim( Str( _u_pot_1, 12, 2 ) ) )

      IF Round( _u_dug_1z - _u_pot_1z, 4 ) <> 0
         xml_node( "greska", AllTrim( Str( _u_dug_1z - _u_pot_1z, 12, 2  ) )  )
      ELSE
         xml_node( "greska", ""  )
      ENDIF

      IF _saldo_1 >= 0
         xml_node( "saldo", AllTrim( Str( _saldo_1, 12, 2 ) ) )
      ELSE
         _saldo_1 := -_saldo_1
         xml_node( "saldo", AllTrim( Str( _saldo_1, 12, 2 ) ) )
      ENDIF

   ELSE

      xml_node( "u_dug", AllTrim( Str( _u_dug_2, 12, 2 ) ) )
      xml_node( "u_pot", AllTrim( Str( _u_pot_2, 12, 2 ) ) )

      IF Round( _u_dug_2z - _u_pot_2z, 4 ) <> 0
         xml_node( "greska", AllTrim( Str( _u_dug_2z - _u_pot_2z, 12, 2  ) )  )
      ELSE
         xml_node( "greska", ""  )
      ENDIF

      IF _saldo_2 >= 0
         xml_node( "saldo", AllTrim( Str( _saldo_2, 12, 2 ) ) )
      ELSE
         _saldo_2 := -_saldo_2
         xml_node( "saldo", AllTrim( Str( _saldo_2, 12, 2 ) ) )
      ENDIF

   ENDIF

   xml_node( "mjesto", to_xml_encoding( AllTrim( gMjStr ) ) )
   xml_node( "datum", DToC( Date() ) )

   _clan_txt := __ios_clan

   xml_node( "clan", to_xml_encoding( _clan_txt ) )

   xml_subnode( "ios_item", .T. )

   SELECT ios

   RETURN .T.






// --------------------------------------------------
// podesenje clan-a za stampu IOS-a
// --------------------------------------------------
STATIC FUNCTION ios_clan_setup( setup_box )

   LOCAL _txt := ""
   LOCAL _clan

   IF setup_box == NIL
      setup_box := .T.
   ENDIF

   // ovo je tekuci defaultni clan
   _txt := "Prema clanu 28. stav 4. Zakona o racunovodstvu i reviziji u FBIH (Sl.novine FBIH, broj 83/09) "
   _txt += "na ovu nasu konfirmaciju ste duzni odgovoriti u roku od osam dana. "
   _txt += "Ukoliko u tom roku ne primimo potvrdu ili osporavanje iskazanog stanja, smatracemo da je "
   _txt += "usaglasavanje izvrseno i da je stanje isto."

   _clan := PadR( fetch_metric( "ios_clan_txt", NIL, _txt ), 500 )

   IF setup_box
      Box(, 2, 70 )
      @ m_x + 1, m_y + 2 SAY "Definisanje clan-a na IOS-u:"
      @ m_x + 2, m_y + 2 SAY ":" GET _clan PICT "@S65"
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN .F.
      ENDIF
   ENDIF

   // snimi parametar
   set_metric( "ios_clan_txt", NIL, AllTrim( _clan ) )
   __ios_clan := AllTrim( _clan )

   RETURN .T.




// ---------------------------------------------------------
// linija za specifikaciju iosa
// ---------------------------------------------------------
STATIC FUNCTION _ios_spec_get_line()

   LOCAL _line
   LOCAL _space := Space( 1 )

   _line := "-----"
   _line += _space
   _line += "------"
   _line += _space
   _line += "------------------------------------"
   _line += _space
   _line += "-----"
   _line += _space
   _line += "-----------------"
   _line += _space
   _line += "---------------"
   _line += _space
   _line += "----------------"
   _line += _space
   _line += "----------------"
   _line += _space
   _line += "----------------"

   IF fin_dvovalutno()
      _line += _space
      _line += "------------"
      _line += _space
      _line += "------------"
      _line += _space
      _line += "------------"
      _line += _space
      _line += "------------"
   ENDIF

   RETURN _line




// ----------------------------------------------------------
// uslovi izvjestaja IOS specifikacija
// ----------------------------------------------------------
STATIC FUNCTION _ios_spec_vars( params )

   LOCAL cIdFirma := gFirma
   LOCAL cIdKonto := fetch_metric( "ios_spec_id_konto", my_user(), Space( 7 ) )
   LOCAL _saldo_nula := "D"
   LOCAL _datum_do := Date()

   O_KONTO

   Box( "", 6, 60 )
   @ m_x + 1, m_y + 6 SAY "SPECIFIKACIJA IOS-a"
   @ m_x + 3, m_y + 2 SAY "Firma "
   ?? gFirma, "-", gNFirma
   @ m_x + 4, m_y + 2 SAY "Konto: " GET cIdKonto VALID P_Konto( @cIdKonto )
   @ m_x + 5, m_y + 2 SAY "Datum do kojeg se generise  :" GET _datum_do
   @ m_x + 6, m_y + 2 SAY "Prikaz partnera sa saldom 0 :" GET _saldo_nula ;
      VALID _saldo_nula $ "DN" PICT "@!"
   READ
   BoxC()

   SELECT konto
   USE

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF


   set_metric( "ios_spec_id_konto", my_user(), cIdKonto )
   cIdFirma := Left( cIdFirma, 2 )

   // napuni matricu sa parametrima
   params[ "id_konto" ] := cIdKonto
   params[ "id_firma" ] := cIdFirma
   params[ "saldo_nula" ] := _saldo_nula
   params[ "datum_do" ] := _datum_do

   RETURN .T.




/*
STATIC FUNCTION ios_specifikacija( params )

   LOCAL _datum_do, cIdFirma, cIdKonto, _saldo_nula
   LOCAL _line
   LOCAL _id_partner, _rbr
   LOCAL _auto := .F.

   IF params == NIL
      params := hb_Hash()
   ELSE
      _auto := .T.
   ENDIF

   // uslovi izvjestaja
   IF !_auto .AND. !_ios_spec_vars( @params )
      RETURN .F.
   ENDIF

   // iz parametara uzmi uslove
   cIdFirma := params[ "id_firma" ]
   cIdKonto := params[ "id_konto" ]
   _datum_do := params[ "datum_do" ]
   _saldo_nula := params[ "saldo_nula" ]

   _line := _ios_spec_get_line()

   O_PARTN
   O_KONTO

   find_suban_by_broj_dokumenta(  cIdFirma, cIdKonto )

   EOF CRET


   IF !start_print()
      RETURN .F.
   ENDIF
   ?

   _rbr := 0

   nDugBHD := nUkDugBHD := nDugDEM := nUkDugDEM := 0
   nPotBHD := nUkPotBHD := nPotDEM := nUkPotDEM := 0
   nUkBHDDS := nUkBHDPS := 0
   nUkDEMDS := nUkDEMPS := 0

   DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cIdKonto == field->idkonto

      _id_partner := field->idpartner

      DO WHILE !Eof() .AND. cIdFirma == field->idfirma ;
            .AND. cIdKonto == field->idkonto ;
            .AND. _id_partner == field->idpartner

         // ako je datum veci od datuma do kojeg generisem
         // preskoci
         IF field->datdok > _datum_do
            SKIP
            LOOP
         ENDIF

         IF field->otvst == " "
            IF field->d_p == "1"
               nDugBHD += field->iznosbhd
               nUkDugBHD += field->Iznosbhd
               nDugDEM += field->Iznosdem
               nUkDugDEM += field->Iznosdem
            ELSE
               nPotBHD += field->IznosBHD
               nUkPotBHD += field->IznosBHD
               nPotDEM += field->IznosDEM
               nUkPotDEM += field->IznosDEM
            ENDIF
         ENDIF
         SKIP
      ENDDO

      nSaldoBHD := nDugBHD - nPotBHD
      nSaldoDEM := nDugDEM - nPotDEM

      IF _saldo_nula == "D" .OR. Round( nSaldoBHD, 2 ) <> 0
         // ako je iznos <> 0

         // daj mi prvi put zaglavlje
         IF _rbr == 0
            _spec_zaglavlje( cIdFirma, _id_partner, _line )
         ENDIF

         IF PRow() > 61 + dodatni_redovi_po_stranici()
            FF
            _spec_zaglavlje( cIdFirma, _id_partner, _line )
         ENDIF

         @ PRow() + 1, 0 SAY + + _rbr PICT "9999"
         @ PRow(), 5 SAY _id_partner

         SELECT PARTN
         HSEEK _id_partner

         @ PRow(), 12 SAY PadR( AllTrim( partn->naz ), 20 )
         @ PRow(), 37 SAY AllTrim( partn->naz2 ) PICT 'XXXXXXXXXXXX'
         @ PRow(), 50 SAY partn->PTT
         @ PRow(), 56 SAY partn->Mjesto

         // BHD
         @ PRow(), 73 SAY nDugBHD PICT picBHD
         @ PRow(), PCol() + 1 SAY nPotBHD PICT picBHD

      ENDIF

      SELECT suban

      IF nSaldoBHD >= 0
         @ PRow(), PCol() + 1 SAY nSaldoBHD PICT picBHD
         @ PRow(), PCol() + 1 SAY 0 PICT picBHD
         nUkBHDDS += nSaldoBHD
      ELSE
         @ PRow(), PCol() + 1 SAY 0 PICT picBHD
         @ PRow(), PCol() + 1 SAY -nSaldoBHD PICT picBHD
         nUkBHDPS += -nSaldoBHD
      ENDIF

      // strana valuta
      IF fin_dvovalutno()

         @ PRow(), PCol() + 1 SAY nDugDEM PICTURE picDEM
         @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picDEM

         IF nSaldoDEM >= 0
            @ PRow(), PCol() + 1 SAY nSaldoDEM PICTURE picDEM
            @ PRow(), PCol() + 1 SAY 0 PICTURE picDEM
            nUkDEMDS += nSaldoDEM
         ELSE
            @ PRow(), PCol() + 1 SAY 0 PICTURE picDEM
            @ PRow(), PCol() + 1 SAY -nSaldoDEM PICTURE picDEM
            nUkDEMPS += -nSaldoDEM
         ENDIF
      ENDIF

      nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
      _id_partner := field->IdPartner

   ENDDO

   IF PRow() > 61 + dodatni_redovi_po_stranici()
      FF
      _spec_zaglavlje( cIdFirma, _id_partner, _line )
   ENDIF

   @ PRow() + 1, 0 SAY _line
   @ PRow() + 1, 0 SAY "UKUPNO ZA KONTO:"
   @ PRow(), 73 SAY nUkDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nUkPotBHD PICTURE picBHD

   nS := nUkBHDDS - nUkBHDPS
   @ PRow(), PCol() + 1 SAY iif( nS >= 0, nS, 0 ) PICTURE picBHD
   @ PRow(), PCol() + 1 SAY iif( nS <= 0, nS, 0 ) PICTURE picBHD

   IF fin_dvovalutno()

      @ PRow(), PCol() + 1 SAY nUkDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nUkPotDEM PICTURE picDEM

      nS := nUkDEMDS - nUkDEMPS

      @ PRow(), PCol() + 1 SAY iif( nS >= 0, nS, 0 ) PICTURE picDEM
      @ PRow(), PCol() + 1 SAY iif( nS <= 0, nS, 0 ) PICTURE picDEM

   ENDIF

   @ PRow() + 1, 0 SAY _line

   FF
   end_print()

   my_close_all_dbf()

   RETURN





// -----------------------------------------------------------------
// zaglavlje specifikacije
// -----------------------------------------------------------------
STATIC FUNCTION _spec_zaglavlje( id_firma, id_partner, line )

   P_COND

   ??  "FIN: SPECIFIKACIJA IOS-a     NA DAN "
   ?? Date()
   ? "FIRMA:"
   @ PRow(), PCol() + 1 SAY id_firma

   SELECT partn
   HSEEK id_partner

   @ PRow(), PCol() + 1 SAY AllTrim( naz )
   @ PRow(), PCol() + 1 SAY AllTrim( naz2 )

   ? line

   ?U "*RED.* ŠIFRA*      NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *   KUMULATIVNI PROMET  U  " + ValDomaca() + "  *    S A L D O   U   " + ValDomaca() + "         " + IF( fin_dvovalutno(), "*  KUMULAT. PROMET U " + ValPomocna() + " *  S A L D O   U   " + ValPomocna() + "  ", "" ) + "*"
   ?U "                                                                          ________________________________ _________________________________" + IF( fin_dvovalutno(), "*_________________________ ________________________", "" ) + "_"
   ? "*BROJ*      *                                    * BROJ*                 *    DUGUJE     *   POTRAZUJE    *    DUGUJE      *   POTRAZUJE    " + IF( fin_dvovalutno(), "*    DUGUJE  * POTRAZUJE  *   DUGUJE   * POTRAZUJE ", "" ) + "*"
   ?U line

   SELECT suban

   RETURN .T.

*/



/*
STATIC FUNCTION ios_generacija_podataka( params )

   LOCAL _datum_do, cIdFirma, cIdKonto, _saldo_nula
   LOCAL _id_partner, _rec, _cnt
   LOCAL _auto := .F.
   LOCAL _dug_1, _dug_2, _u_dug_1, _u_dug_2
   LOCAL _pot_1, _pot_2, _u_pot_1, _u_pot_2
   LOCAL _saldo_1, _saldo_2

   IF params == NIL
      MsgBeep( "Napomena: ova opcija puni pomocnu tabelu na osnovu koje se#stampaju IOS obrasci" )
      params := hb_Hash()
   ELSE
      _auto := .T.
   ENDIF

   // uslovi izvjestaja
   IF !_auto .AND. !_ios_spec_vars( @params )
      RETURN
   ENDIF

   // iz parametara uzmi uslove...
   cIdFirma := params[ "id_firma" ]
   cIdKonto := params[ "id_konto" ]
   _datum_do := params[ "datum_do" ]
   _saldo_nula := params[ "saldo_nula" ]

   O_PARTN
   O_KONTO
   o_suban()
   O_IOS

   // reset tabele IOS
   SELECT ios
   my_dbf_zap()

   // SELECT suban
   // SET ORDER TO TAG "1"
   // SEEK cIdFirma + cIdKonto
   find_suban_by_konto_partner( cIdFirma, cIdKonto )

   EOF CRET

   _cnt := 0

   Box(, 3, 65 )

   @ m_x + 1, m_y + 2 SAY "sacekajte trenutak... generisem podatke u pomocnu tabelu"

   DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cIdKonto == field->idkonto

      _id_partner := field->idpartner

      _dug_1 := 0
      _u_dug_1 := 0
      _dug_2 := 0
      _u_dug_2 := 0
      _pot_1 := 0
      _u_pot_1 := 0
      _pot_2 := 0
      _u_pot_2 := 0
      _saldo_1 := 0
      _saldo_2 := 0

      DO WHILE !Eof() .AND. cIdFirma == field->idfirma ;
            .AND. cIdKonto == field->idkonto ;
            .AND. _id_partner == field->idpartner

         // ako je datum veci od datuma do kojeg generisem
         IF field->datdok > _datum_do
            SKIP
            LOOP
         ENDIF

         IF field->otvst == " "
            IF field->d_p == "1"
               _dug_1 += field->iznosbhd
               _u_dug_1 += field->Iznosbhd
               _dug_2 += field->Iznosdem
               _u_dug_2 += field->Iznosdem
            ELSE
               _pot_1 += field->IznosBHD
               _u_pot_1 += field->IznosBHD
               _pot_2 += field->IznosDEM
               _u_pot_2 += field->IznosDEM
            ENDIF
         ENDIF

         SKIP

      ENDDO

      _saldo_1 := _dug_1 - _pot_1
      _saldo_2 := _dug_2 - _pot_2

      IF _saldo_nula == "D" .OR. Round( _saldo_1, 2 ) <> 0

         SELECT ios
         APPEND BLANK

         _rec := dbf_get_rec()

         _rec[ "idfirma" ] := cIdFirma
         _rec[ "idkonto" ] := cIdKonto
         _rec[ "idpartner" ] := _id_partner
         _rec[ "iznosbhd" ] := _saldo_1
         _rec[ "iznosdem" ] := _saldo_2

         dbf_update_rec( _rec )

         @ m_x + 3, m_y + 2 SAY PadR( "Partner: " + _id_partner + ", saldo: " + AllTrim( Str( _saldo_1, 12, 2 ) ), 60 )

         ++_cnt

      ENDIF

      SELECT suban

   ENDDO

   BoxC()

   RETURN _cnt

*/




// ------------------------------------------------------
// upisi u xml fajl podatke partnera
// u odredjeni subnode
// ------------------------------------------------------
STATIC FUNCTION _xml_partner( subnode, id_partner )

   LOCAL _ret := .T.
   LOCAL _jib, cPdvBroj, cIdBroj

   SELECT partn
   GO TOP
   SEEK id_partner

   IF !Found() .AND. !Empty( id_partner )
      _ret := .F.
      RETURN _ret
   ENDIF

   // upisi u xml
   xml_subnode( subnode, .F. )

   IF Empty( id_partner )
      // nema partnera...
      xml_node( "id", to_xml_encoding( "-" ) )
      xml_node( "naz", to_xml_encoding( "-" ) )
      xml_node( "naz2", to_xml_encoding( "-" ) )
      xml_node( "mjesto", to_xml_encoding( "-" ) )
      xml_node( "adresa", to_xml_encoding( "-" ) )
      xml_node( "ptt", to_xml_encoding( "-" ) )
      xml_node( "ziror", to_xml_encoding( "-" ) )
      xml_node( "tel", to_xml_encoding( "-" ) )
      xml_node( "jib", "-" )
   ELSE
      // ima partnera
      xml_node( "id", to_xml_encoding( id_partner ) )
      xml_node( "naz", to_xml_encoding( partn->naz ) )
      xml_node( "naz2", to_xml_encoding( partn->naz2 ) )
      xml_node( "mjesto", to_xml_encoding( partn->mjesto ) )
      xml_node( "adresa", to_xml_encoding( partn->adresa ) )
      xml_node( "ptt", to_xml_encoding( partn->ptt ) )
      xml_node( "ziror", to_xml_encoding( partn->ziror ) )
      xml_node( "tel", to_xml_encoding( partn->telefon ) )

      _jib := firma_pdv_broj( id_partner )

      cPdvBroj := _jib
      cIdBroj := firma_id_broj( id_partner )

      xml_node( "jib", _jib )
      xml_node( "pdvbr", cPdvBroj )
      xml_node( "idbbr", cIdBroj )
   ENDIF

   xml_subnode( subnode, .T. )

   RETURN _ret




// -----------------------------------------
// ispivanje stavki IOS-a u TXT formatu
// -----------------------------------------
STATIC FUNCTION print_ios_txt( params )

   LOCAL _rbr
   LOCAL _n_opis := 0
   LOCAL cIdFirma := params[ "id_firma" ]
   LOCAL cIdKonto := params[ "id_konto" ]
   LOCAL _id_partner := params[ "id_partner" ]
   LOCAL _iznos_bhd := params[ "iznos_bhd" ]
   LOCAL _iznos_dem := params[ "iznos_dem" ]
   LOCAL _din_dem := params[ "din_dem" ]
   LOCAL _datum_do := params[ "datum_do" ]
   LOCAL _ios_date := params[ "ios_datum" ]
   LOCAL _export_dbf := params[ "export_dbf" ]
   LOCAL _kao_kartica := params[ "kartica" ]
   LOCAL _prelomljeno := params[ "prelom" ]
   LOCAL _naz_partner

   ?

   @ PRow(), 58 SAY "OBRAZAC: I O S"
   @ PRow() + 1, 1 SAY cIdFirma

   SELECT partn
   HSEEK cIdFirma

   @ PRow(), 5 SAY AllTrim( partn->naz )
   @ PRow(), PCol() + 1 SAY AllTrim( partn->naz2 )
   @ PRow() + 1, 5 SAY partn->Mjesto
   @ PRow() + 1, 5 SAY partn->Adresa
   @ PRow() + 1, 5 SAY partn->ptt
   @ PRow() + 1, 5 SAY partn->ZiroR
   @ PRow() + 1, 5 SAY firma_pdv_broj( cIdFirma )

   ?

   SELECT PARTN
   HSEEK _id_partner

   @ PRow(), 45 SAY _id_partner
   ?? " -", AllTrim( partn->naz )
   @ PRow() + 1, 45 SAY partn->mjesto
   @ PRow() + 1, 45 SAY partn->adresa
   @ PRow() + 1, 45 SAY partn->ptt
   @ PRow() + 1, 45 SAY partn->ziror

   IF !Empty( partn->telefon )
      @ PRow() + 1, 45 SAY "Telefon: " + partn->telefon
   ENDIF

   @ PRow() + 1, 45 SAY firma_pdv_broj( _id_partner )

   _naz_partner := naz

   ?
   ?
   @ PRow(), 6 SAY "IZVOD OTVORENIH STAVKI NA DAN :"
   @ PRow(), PCol() + 2 SAY _ios_date
   @ PRow(), PCol() + 1 SAY "GODINE"
   ?
   ?
   @ PRow(), 0 SAY "VA�E STANJE NA KONTU" ; @ PRow(), PCol() + 1 SAY cIdKonto
   @ PRow(), PCol() + 1 SAY " - " + _id_partner
   @ PRow() + 1, 0 SAY "PREMA NA�IM POSLOVNIM KNJIGAMA NA DAN:"
   @ PRow(), 39 SAY _ios_date
   @ PRow(), 48 SAY "GODINE"
   ?
   ?
   @ PRow(), 0 SAY "POKAZUJE SALDO:"

   qqIznosBHD := _iznos_bhd
   qqIznosDEM := _iznos_dem

   IF _iznos_bhd < 0
      qqIznosBHD := -_iznos_bhd
   ENDIF

   IF _iznos_dem < 0
      qqIznosDEM := -_iznos_dem
   ENDIF

   IF _din_dem == "1"
      @ PRow(), 16 SAY qqIznosBHD PICT R1
   ELSE
      @ PRow(), 16 SAY qqIznosDEM PICT R2
   ENDIF

   ?
   ?

   @ PRow(), 0 SAY "U"

   IF _iznos_bhd > 0
      @ PRow(), PCol() + 1 SAY "NA�U"
   ELSE
      @ PRow(), PCol() + 1 SAY "VA�U"
   ENDIF

   @ PRow(), PCol() + 1 SAY "KORIST I SASTOJI SE IZ SLIJEDECIH OTVORENIH STAVKI:"

   P_COND

   m := "       ---- ---------- -------------------- -------- -------- ---------------- ----------------"

   ? m
   ? "       *R. *   BROJ   *    OPIS            * DATUM  * VALUTA *       IZNOS  U  " + iif( _din_dem == "1", ValDomaca(), ValPomocna() ) + "            *"
   ? "       *Br.*          *                    *                 * --------------------------------"
   ? "       *   *  RA�UNA  *                    * RA�UNA * RA�UNA *     DUGUJE     *   POTRA�UJE   *"
   ? m

   nCol1 := 62

   IF _kao_kartica == "D"
      // SET ORDER TO TAG "1"
      find_suban_by_konto_partner( cIdFirma, cIdKonto, _id_partner, NIL, "idfirma,idvn,brnal" )
   ELSE
      // SET ORDER TO TAG "3"
      find_suban_by_konto_partner( cIdFirma, cIdKonto, _id_partner, NIL, "IdFirma,IdKonto,IdPartner,brdok" )
   ENDIF


   nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
   nDugBHDZ := nPotBHDZ := nDugDEMZ := nPotDEMZ := 0
   _rbr := 0

   // ako je kartica, onda nikad ne prelamaj
   IF _kao_kartica == "D"
      _prelomljeno := "N"
   ENDIF

   DO WHILE !Eof() .AND. cIdFirma == field->IdFirma ;
         .AND. cIdKonto == field->IdKonto ;
         .AND. _id_partner == field->IdPartner

      cBrDok := field->brdok
      dDatdok := field->datdok
      cOpis := AllTrim( field->opis )
      dDatVal := fix_dat_var( field->datval )
      nDBHD := 0
      nPBHD := 0
      nDDEM := 0
      nPDEM := 0
      cOtvSt := field->otvst

      DO WHILE !Eof() .AND. cIdFirma == field->IdFirma ;
            .AND. cIdKonto == field->IdKonto ;
            .AND. _id_partner == field->IdPartner ;
            .AND. ( _kao_kartica == "D" .OR. field->brdok == cBrdok )

         IF field->datdok > _datum_do
            SKIP
            LOOP
         ENDIF

         IF field->otvst = " "

            IF _kao_kartica == "D"

               IF PRow() > 61 + dodatni_redovi_po_stranici()
                  FF
               ENDIF

               @ PRow() + 1, 8 SAY + + _rbr PICT '999'
               @ PRow(), PCol() + 1 SAY field->BrDok
               _n_opis := PCol() + 1
               @ PRow(), _n_opis SAY PadR( field->Opis, 20 )
               @ PRow(), PCol() + 1 SAY field->DatDok
               @ PRow(), PCol() + 1 SAY fix_dat_var( field->DatVal )

               IF _din_dem == "1"
                  @ PRow(), nCol1 SAY iif( field->D_P == "1", field->iznosbhd, 0 ) PICT picBHD
                  @ PRow(), PCol() + 1 SAY iif( field->D_P == "2", field->iznosbhd, 0 ) PICT picBHD
               ELSE
                  @ PRow(), nCol1 SAY iif( field->D_P == "1", field->iznosdem, 0 ) PICT picBHD
                  @ PRow(), PCol() + 1 SAY iif( field->D_P == "2", field->iznosdem, 0 ) PICT picBHD
               ENDIF

               IF _export_dbf == "D"
                  fill_exp_tbl( _id_partner, ;
                     _naz_partner, ;
                     field->brdok, ;
                     field->opis, ;
                     field->datdok, ;
                     fix_dat_var( field->datval ), ;
                     iif( field->d_p == "1", field->iznosbhd, 0 ), ;
                     iif( field->d_p == "2", field->iznosbhd, 0 ) )
               ENDIF

            ENDIF

            IF field->d_p = "1"
               nDBHD += field->IznosBHD
               nDDEM += field->IznosDEM
            ELSE
               nPBHD += field->IznosBHD
               nPDEM += field->IznosDEM
            ENDIF

            cOtvSt := " "

         ELSE
            // zatvorene stavke

            IF field->D_P == "1"
               nDugBHDZ += field->IznosBHD
               nDugDEMZ += field->IznosDEM
            ELSE
               nPotBHDZ += field->IznosBHD
               nPotDEMZ += field->IznosDEM
            ENDIF

         ENDIF

         SKIP

      ENDDO

      IF cOtvSt == " "

         IF _kao_kartica == "N"

            IF PRow() > 61 + dodatni_redovi_po_stranici()
               FF
            ENDIF

            @ PRow() + 1, 8 SAY + + _rbr PICT "999"
            @ PRow(), PCol() + 1  SAY cBrDok
            _n_opis := PCol() + 1
            @ PRow(), _n_opis SAY PadR( cOpis, 20 )
            @ PRow(), PCol() + 1 SAY dDatDok
            @ PRow(), PCol() + 1 SAY fix_dat_var( dDatVal, .T. )

         ENDIF

         IF _din_dem == "1"

            IF _prelomljeno == "D"

               IF ( nDBHD - nPBHD ) > 0
                  nDBHD := ( nDBHD - nPBHD )
                  nPBHD := 0
               ELSE
                  nPBHD := ( nPBHD - nDBHD )
                  nDBHD := 0
               ENDIF

            ENDIF

            IF _kao_kartica == "N"

               @ PRow(), nCol1 SAY nDBHD PICT picBHD
               @ PRow(), PCol() + 1 SAY nPBhD PICT picBHD

               IF _export_dbf == "D"
                  fill_exp_tbl( _id_partner, ;
                     _naz_partner, ;
                     cBrDok, ;
                     cOpis, ;
                     dDatdok, ;
                     fix_dat_var( dDatval, .T. ), ;
                     nDBHD, ;
                     nPBHD )
               ENDIF

            ENDIF

         ELSE
            IF _prelomljeno == "D"
               IF ( nDDEM - nPDEM ) > 0
                  nDDEM := ( nDDEM - nPDEM )
                  nPBHD := 0
               ELSE
                  nPDEM := ( nPDEM - nDDEM )
                  nDDEM := 0
               ENDIF
            ENDIF

            IF _kao_kartica == "N"

               @ PRow(), nCol1 SAY nDDEM PICT picBHD
               @ PRow(), PCol() + 1 SAY nPDEM PICT picBHD

               IF _export_dbf == "D"
                  fill_exp_tbl( _id_partner, ;
                     _naz_partner, ;
                     cBrdok, ;
                     cOpis, ;
                     dDatdok, ;
                     fix_dat_var( dDatval, .T. ), ;
                     nDDEM, ;
                     nPDEM )
               ENDIF

            ENDIF
         ENDIF

         nDugBHD += nDBHD
         nPotBHD += nPBHD
         nDugDem += nDDem
         nPotDem += nPDem

      ENDIF

      fin_print_ostatak_opisa( cOpis, _n_opis )

   ENDDO

   IF PRow() > 61 + dodatni_redovi_po_stranici()
      FF
   ENDIF

   @ PRow() + 1, 0 SAY m
   @ PRow() + 1, 8 SAY "UKUPNO:"

   IF _din_dem == "1"
      @ PRow(), nCol1 SAY nDugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
   ELSE
      @ PRow(), nCol1 SAY nDugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
   ENDIF

   // ako je promet zatvorenih stavki <> 0  prikazi ga ????
   IF _din_dem == "1"
      IF Round( nDugBHDZ - nPOTBHDZ, 4 ) <> 0
         @ PRow() + 1, 0 SAY m
         @ PRow() + 1, 8 SAY "ZATVORENE STAVKE"
         @ PRow(), nCol1 SAY ( nDugBHDZ - nPOTBHDZ ) PICT picBHD
         @ PRow(), PCol() + 1 SAY  " GRE�KA !!"
      ENDIF
   ELSE
      IF Round( nDugDEMZ - nPOTDEMZ, 4 ) <> 0
         @ PRow() + 1, 0 SAY m
         @ PRow() + 1, 8 SAY "ZATVORENE STAVKE"
         @ PRow(), nCol1 SAY ( nDugDEMZ - nPOTDEMZ ) PICT picBHD
         @ PRow(), PCol() + 1 SAY " GRE�KA !!"
      ENDIF
   ENDIF

   @ PRow() + 1, 0 SAY m
   @ PRow() + 1, 8 SAY "SALDO:"

   nSaldoBHD := ( nDugBHD - nPotBHD )
   nSaldoDEM := ( nDugDEM - nPotDEM )

   IF _din_dem == "1"
      IF nSaldoBHD >= 0
         @ PRow(), nCol1 SAY nSaldoBHD PICT picBHD
         @ PRow(), PCol() + 1 SAY 0 PICT picBHD
      ELSE
         nSaldoBHD := -nSaldoBHD
         nSaldoDEM := -nSaldoDEM
         @ PRow(), nCol1 SAY 0 PICT picBHD
         @ PRow(), PCol() + 1 SAY nSaldoBHD PICT picBHD
      ENDIF
   ELSE
      IF nSaldoDEM >= 0
         @ PRow(), nCol1 SAY nSaldoDEM PICT picBHD
         @ PRow(), PCol() + 1 SAY 0 PICT picBHD
      ELSE
         nSaldoDEM := -nSaldoDEM
         @ PRow(), nCol1 SAY 0 PICT picBHD
         @ PRow(), PCol() + 1 SAY nSaldoDEM PICT picBHD
      ENDIF
   ENDIF

   ? m

   F10CPI

   ?

   IF PRow() > 61 + dodatni_redovi_po_stranici()
      FF
   ENDIF

   ?
   ?

   F12CPI

   @ PRow(), 13 SAY "PO�ILJALAC IZVODA:"
   @ PRow(), 53 SAY "POTVR�UJEMO SAGLASNOST"
   @ PRow() + 1, 50 SAY "OTVORENIH STAVKI:"

   ?
   ?

   @ PRow(), 10 SAY "__________________"
   @ PRow(), 50 SAY "______________________"

   IF PRow() > 58 + dodatni_redovi_po_stranici()
      FF
   ENDIF

   ?
   ?

   @ PRow(), 10 SAY "__________________ M.P."
   @ PRow(), 50 SAY "______________________ M.P."

   ?
   ?

   @ PRow(), 10 SAY Trim( gMjStr ) + ", " + DToC( Date() )
   @ PRow(), 52 SAY "( MJESTO I DATUM )"

   IF PRow() > 52 + dodatni_redovi_po_stranici()
      FF
   ENDIF

   ?
   ?

   @ PRow(), 0 SAY "Prema clanu 28. stav 4. Zakona o racunovodstvu i reviziji u FBIH (Sl.novine FBIH, broj 83/09)"
   @ PRow() + 1, 0 SAY "na ovu nasu konfirmaciju ste duzni odgovoriti u roku od osam dana."
   @ PRow() + 1, 0 SAY "Ukoliko u tom roku ne primimo potvrdu ili osporavanje iskazanog stanja, smatracemo da je"
   @ PRow() + 1, 0 SAY "usaglasavanje izvrseno i da je stanje isto."

   ?
   ?

   @ PRow(), 0 SAY "NAPOMENA: OSPORAVAMO ISKAZANO STANJE U CJELINI _______________ DJELIMI�NO"
   @ PRow() + 1, 0 SAY "ZA IZNOS OD  " + ValDomaca() + "= _______________ IZ SLIJEDE�IH RAZLOGA:"
   @ PRow() + 1, 0 SAY "_________________________________________________________________________"

   ?
   ?

   @ PRow(), 0 SAY "_________________________________________________________________________"
   ?
   ?
   @ PRow(), 48 SAY "DU�NIK:"
   @ PRow() + 1, 40 SAY "_______________________ M.P."
   @ PRow() + 1, 44 SAY "( MJESTO I DATUM )"

   SELECT ios

   RETURN




// ------------------------------------------
// vraca strukturu tabele za export
// ------------------------------------------
STATIC FUNCTION g_exp_fields()

   LOCAL _dbf := {}

   AAdd( _dbf, { "idpartner", "C", 10, 0 } )
   AAdd( _dbf, { "partner", "C", 40, 0 } )
   AAdd( _dbf, { "brrn", "C", 10, 0 } )
   AAdd( _dbf, { "opis", "C", 40, 0 } )
   AAdd( _dbf, { "datum", "D", 8, 0 } )
   AAdd( _dbf, { "valuta", "D", 8, 0 } )
   AAdd( _dbf, { "duguje", "N", 15, 5 } )
   AAdd( _dbf, { "potrazuje", "N", 15, 5 } )

   RETURN _dbf





// ---------------------------------------------------------
// filovanje tabele sa podacima
// ---------------------------------------------------------
STATIC FUNCTION fill_exp_tbl( cIdPart, cNazPart, ;
      cBrRn, cOpis, dDatum, dValuta, ;
      nDug, nPot )

   LOCAL _t_area := Select()

   O_R_EXP
   APPEND BLANK

   REPLACE field->idpartner WITH cIdPart
   REPLACE field->partner WITH cNazPart
   REPLACE field->brrn WITH cBrRn
   REPLACE field->opis WITH cOpis
   REPLACE field->datum WITH dDatum
   REPLACE field->valuta WITH dValuta
   REPLACE field->duguje WITH nDug
   REPLACE field->potrazuje WITH nPot

   SELECT ( _t_area )

   RETURN
