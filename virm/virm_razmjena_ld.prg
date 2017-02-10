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

MEMVAR _mjesec, _godina, nBrojRadnikaPrivateVar, gVirmFirma


FUNCTION virm_prenos_ld( lPrenosLDVirm )

   LOCAL _poziv_na_broj
   LOCAL _dat_virm := Date()
   LOCAL _bez_nula := fetch_metric( "virm_generisanje_nule", my_user(), "D" )
   LOCAL _ispl_posebno := fetch_metric( "virm_isplate_za_radnike_posebno", my_user(), "N" )
   LOCAL _dod_opis1 := "D"
   LOCAL _racun_upl
   LOCAL _per_od, _per_do
   LOCAL _id_banka, _dod_opis
   LOCAL nRBr, _firma


   PRIVATE _mjesec, _godina, nBrojRadnikaPrivateVar

   IF lPrenosLDVirm == NIL
      lPrenosLDVirm := .F.
   ENDIF

   IF !File( f18_ime_dbf( "ld_rekld" ) )
      MsgBeep( "pokrenuti opciju rekapitulacija plata#prije korištenja ove opcije" )
      RETURN .F.
   ENDIF

   virm_o_tables()

   SELECT virm_pripr
   IF reccount2() > 0 .AND. Pitanje(, "Izbrisati virmane u pripremi?", "N" ) == "D"
      my_dbf_zap()
   ENDIF

   // uzmi parametre iz sql/db
   _godina := fetch_metric( "virm_godina", my_user(), Year( Date() ) )
   _mjesec := fetch_metric( "virm_mjesec", my_user(), Month( Date() ) )
   _poziv_na_broj := fetch_metric( "virm_poziv_na_broj", my_user(), PadR( "", 10 ) )
   _racun_upl := fetch_metric( "virm_zr_uplatioca", my_user(), Space( 16 ) )
   _firma := PadR( fetch_metric( "virm_org_id", NIL, "" ), 6 )

   gVirmFirma := _firma

   // period od-do
   _per_od := CToD( "" )
   _per_do := _per_od

   Box(, 10, 70 )

   @ form_x_koord() + 1, form_y_koord() + 2 SAY8 "GENERISANJE VIRMANA NA OSNOVU OBRAČUNA PLATE"

   _id_banka := PadR( _racun_upl, 3 )

   @ form_x_koord() + 2, form_y_koord() + 2 SAY "Posiljaoc (sifra banke):       " GET _id_banka VALID virm_odredi_ziro_racun( _firma, @_id_banka )
   READ

   _racun_upl := _id_banka

   SELECT virm_pripr

   @ form_x_koord() + 3, form_y_koord() + 2 SAY "Poziv na broj " GET _poziv_na_broj
   @ form_x_koord() + 4, form_y_koord() + 2 SAY "godina" GET _godina PICT "9999"
   @ form_x_koord() + 5, form_y_koord() + 2 SAY "mjesec" GET _mjesec  PICT "99"
   @ form_x_koord() + 7, form_y_koord() + 2 SAY "Datum" GET _dat_virm
   @ form_x_koord() + 8, form_y_koord() + 2 SAY "Porezni period od" GET _per_od
   @ form_x_koord() + 8, Col() + 2 SAY "do" GET _per_do
   @ form_x_koord() + 9, form_y_koord() + 2 SAY8 "Isplate prebaciti pojedinačno za svakog radnika (D/N)?" GET _ispl_posebno VALID _ispl_posebno $ "DN" PICT "@!"
   @ form_x_koord() + 10, form_y_koord() + 2 SAY8 "Formirati samo stavke sa iznosima većim od 0 (D/N)?" GET _bez_nula VALID _bez_nula $ "DN" PICT "@!"

   READ

   ESC_BCR

   BoxC()

   set_metric( "virm_zr_uplatioca", my_user(), _racun_upl )
   set_metric( "virm_godina", my_user(), _godina )
   set_metric( "virm_mjesec", my_user(), _mjesec )
   set_metric( "virm_poziv_na_broj", my_user(), _poziv_na_broj )
   set_metric( "virm_generisanje_nule", my_user(), _bez_nula )
   set_metric( "virm_isplate_za_radnike_posebno", my_user(), _ispl_posebno )

   _dod_opis := ", za " + Str( _mjesec, 2 ) + "." + Str( _godina, 4 )
   nRBr := 0

   virm_ld_obrada( _godina, _mjesec, _dat_virm, @nRBr, _dod_opis, _per_od, _per_do )
   ld_virm_generacija_krediti( _godina, _mjesec, _dat_virm, @nRBr, _dod_opis )
   virm_ld_isplata_radniku_na_tekuci_racun( _godina, _mjesec, _dat_virm, @nRBr, _dod_opis )
   popuni_javne_prihode()

   my_close_all_dbf()

   RETURN .T.

// ---------------------------------------------------------------------------------------------
// obrada podataka za isplate na tekuci racun
// ---------------------------------------------------------------------------------------------
STATIC FUNCTION virm_ld_isplata_radniku_na_tekuci_racun( nGodina, nMjesec, dDatVirm, r_br, dod_opis )

   LOCAL cOznakaIsplatePrefix := "IS_"
   LOCAL cIdKreditor, hRec
   LOCAL _formula, _izr_formula
   LOCAL _svrha_placanja
   LOCAL _racun_upl := fetch_metric( "virm_zr_uplatioca", my_user(), Space( 16 ) )
   LOCAL _bez_nula := fetch_metric( "virm_generisanje_nule", my_user(), "N" )
   LOCAL _ispl_posebno := fetch_metric( "virm_isplate_za_radnike_posebno", my_user(), "N" )
   LOCAL _isplata_opis := ""

   SELECT rekld
   GO TOP
   SEEK Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 ) + cOznakaIsplatePrefix

   DO WHILE !Eof() .AND. Left( field->id,  Len( cOznakaIsplatePrefix ) ) == cOznakaIsplatePrefix

      cIdKreditor := SubStr( field->id, 4 )   // sifra banke
      pozicioniraj_rec_kreditor_partner( cIdKreditor )
      pozicioniraj_rec_vrprim_sifra_is()   // pozicioniraj se na vrprim za isplatu

      SELECT vrprim

      _svrha_placanja := field->id

      select_o_partner( cIdKreditor )

      _u_korist := field->id
      _kome_txt := field->naz
      _kome_sjed := field->mjesto
      _nacin_pl := "1"

      _KOME_ZR := Space( 16 )
      virm_odredi_ziro_racun( _u_korist, @_KOME_ZR, .F. )

      SELECT virm_pripr
      GO TOP


      _ko_txt := field->ko_txt   // uzmi podatke iz prve stavke
      _ko_zr := field->ko_zr

      select_o_partner( gVirmFirma )

      _total := 0
      _kredit := 0

      SELECT rekld
      _sk_sifra := field->idpartner // SK=sifra kreditora/banke


      IF _ispl_posebno == "N"     // isplate za jednu banku - sumirati

         DO WHILE !Eof() .AND. Left( field->id,  Len( cOznakaIsplatePrefix ) ) == cOznakaIsplatePrefix .AND. field->idpartner = _sk_sifra
            ++_kredit
            _total += rekld->iznos1
            _isplata_opis := "obuhvaceno " + AllTrim( Str( _kredit ) ) + " radnika"
            SKIP 1
         ENDDO
         SKIP -1

      ELSE

         // svaka isplata ce se tretirati posebno
         _kredit := 1
         _total := rekld->iznos1
         _isplata_opis := AllTrim( field->opis2 )

      ENDIF

      SELECT virm_pripr

      IF _bez_nula == "N" .OR. _total > 0

         APPEND BLANK

         REPLACE field->rbr WITH ++r_br
         REPLACE field->mjesto WITH gmjesto
         REPLACE field->svrha_pl WITH "IS"
         REPLACE field->iznos WITH _total
         REPLACE field->na_teret WITH gVirmFirma
         REPLACE field->kome_txt WITH _kome_txt
         REPLACE field->ko_txt WITH _ko_txt
         REPLACE field->ko_zr WITH _ko_zr
         REPLACE field->kome_sj WITH _kome_sjed
         REPLACE field->kome_zr WITH _KOME_ZR
         REPLACE field->dat_upl WITH dDatVirm
         REPLACE field->svrha_doz WITH AllTrim( vrprim->pom_txt ) + " " + AllTrim( dod_opis ) + " " + _isplata_opis
         REPLACE field->u_korist WITH cIdKreditor

         IF _ispl_posebno == "D"  // jedan radnik
            REPLACE field->svrha_doz WITH Trim( svrha_doz ) + ", tekuci rn:" + Trim( rekld->opis )
         ENDIF

      ENDIF

      SELECT rekld
      SKIP

   ENDDO

   RETURN .T.



// ----------------------------------------------------------------------------------------------------
// obrada virmana za regularnu isplatu plata, doprinosi, porezi itd...
// ----------------------------------------------------------------------------------------------------
STATIC FUNCTION virm_ld_obrada( nGodina, nMjesec, dDatVirm, r_br, dod_opis, per_od, per_do )

   LOCAL _broj_radnika
   LOCAL _formula, _izr_formula
   LOCAL _svrha_placanja
   LOCAL _poziv_na_broj := fetch_metric( "virm_poziv_na_broj", my_user(), PadR( "", 10 ) )
   LOCAL _racun_upl := fetch_metric( "virm_zr_uplatioca", my_user(), Space( 16 ) )
   LOCAL _bez_nula := fetch_metric( "virm_generisanje_nule", my_user(), "N" )

   PRIVATE _KOME_ZR := ""
   PRIVATE _kome_txt := ""
   PRIVATE _budzorg := ""
   PRIVATE _idjprih := ""

   select_o_partner( gVirmFirma )

   _ko_txt := Trim( partn->naz ) + ", " +  Trim( partn->mjesto ) + ", " +  Trim( partn->adresa ) + ", " +  Trim( partn->telefon )

   _broj_radnika := ""

   SELECT ldvirm
   GO TOP

   DO WHILE !Eof()

      _formula := field->formula
      IF Empty( _formula )
         SKIP
         LOOP
      ENDIF

      _svrha_placanja := AllTrim( field->id )

      o_vrprim( ldvirm->id )

      select_o_partner( gVirmFirma )

      SELECT virm_pripr

      _izr_formula := &_formula // npr. RLD("DOPR1XZE01")

      SELECT virm_pripr

      IF _bez_nula == "N" .OR. _izr_formula > 0

         APPEND BLANK

         REPLACE field->rbr WITH ++r_br
         REPLACE field->mjesto WITH gMjesto
         REPLACE field->svrha_pl WITH _svrha_placanja
         REPLACE field->iznos WITH _izr_formula
         REPLACE field->vupl WITH "0"

         // posaljioc
         REPLACE field->na_teret WITH gVirmFirma
         REPLACE field->ko_txt WITH _ko_txt
         REPLACE field->ko_zr WITH _racun_upl
         REPLACE field->kome_txt WITH vrprim->naz

         IF PadR( vrprim->idpartner, 2 ) == "JP"
            REPLACE field->pnabr WITH _poziv_na_broj
         ENDIF

         _tmp_opis := Trim( vrprim->pom_txt ) +  iif( !Empty( dod_opis ), " " + AllTrim( dod_opis ), "" ) +  iif( !Empty( nBrojRadnikaPrivateVar ), " " + nBrojRadnikaPrivateVar, "" )


         _KOME_ZR := ""  // resetuj varijable
         _kome_txt := ""
         _budzorg := ""

         IF PadR( vrprim->idpartner, 2 ) == "JP"

            set_jprih_globalne_varijable()   // javni prihodi, setuj varijable _KOME_ZR, _kome_txt , _budzorg

            _cKomeZiroRacun := _KOME_ZR
            __kome_txt := _kome_txt
            __budz_org := _budzorg
            __org_jed := gOrgJed
            __id_jprih := _idjprih

         ELSE

            IF vrprim->dobav == "D"

               _KOME_ZR := PadR( _KOME_ZR, 3 )

               select_o_partner( vrprim->idpartner )
               SELECT virm_pripr

               MsgBeep( "Odrediti racun za partnera :" + vrprim->idpartner )
               virm_odredi_ziro_racun( vrprim->idpartner, @_KOME_ZR )

            ELSE
               _KOME_ZR := vrprim->racun
            ENDIF

            _cKomeZiroRacun := _KOME_ZR
            __budz_org := ""
            __org_jed := ""
            __id_jprih := ""
            _per_od := CToD( "" )
            _per_do := CToD( "" )

         ENDIF

         REPLACE field->kome_zr WITH _cKomeZiroRacun
         REPLACE field->dat_upl WITH dDatVirm
         REPLACE field->svrha_doz WITH _tmp_opis
         REPLACE field->pod WITH per_od
         REPLACE field->pdo WITH per_do
         REPLACE field->budzorg WITH __budz_org
         REPLACE field->bpo WITH __org_jed
         REPLACE field->idjprih WITH __id_jprih

      ENDIF

      SELECT ldvirm
      SKIP 1

   ENDDO

   RETURN .T.



STATIC FUNCTION pozicioniraj_rec_vrprim_sifra_kr()

   LOCAL hRec

   o_vrprim( PadR( "KR", 4 ) )

   IF !Found()

      APPEND BLANK
      hRec := dbf_get_rec()
      hRec[ "id" ] := "KR"
      hRec[ "naz" ] := "Kredit"
      hRec[ "pom_txt" ] := "Kredit"
      hRec[ "nacin_pl" ] := "1"
      hRec[ "dobav" ] := "D"

      update_rec_server_and_dbf( "vrprim", hRec, 1, "FULL" )

   ENDIF

   RETURN .T.



STATIC FUNCTION pozicioniraj_rec_vrprim_sifra_is()

   LOCAL hRec

   o_vrprim( PadR( "IS", 4 ) ) // vrprim.id c(4)

   IF !Found()

      APPEND BLANK
      hRec := dbf_get_rec()
      hRec[ "id" ] := "IS"
      hRec[ "naz" ] := "Isplata na tekuci racun"
      hRec[ "pom_txt" ] := "Plata"
      hRec[ "nacin_pl" ] := "1"
      hRec[ "dobav" ] := "D"

      update_rec_server_and_dbf( "vrprim", hRec, 1, "FULL" )

   ENDIF

   RETURN .T.


STATIC FUNCTION pozicioniraj_rec_kreditor_partner( cIdKreditor )

   LOCAL hRec

   o_kred( PadR( cIdKreditor, 6 ) ) // kred.id char(6)

   select_o_partner( PadR( cIdKreditor, LEN_PARTNER_ID ) )
   IF Eof()

      APPEND BLANK     // dodaj kreditora u listu partnera
      hRec := dbf_get_rec()
      hRec[ "id" ] := kred->id
      hRec[ "naz" ] := kred->naz
      hRec[ "ziror" ] := kred->ziro
      update_rec_server_and_dbf( "partn", hRec, 1, "FULL" )

   ENDIF

   RETURN .T.


// --------------------------------------------------------------------------------------
// obrada virmana za kredite
// --------------------------------------------------------------------------------------
STATIC FUNCTION ld_virm_generacija_krediti( nGodina, nMjesec, dDatVirm, r_br, dod_opis, bez_nula )

   LOCAL cOznakaIsplatePrefix := "KRED"
   LOCAL cIdKreditor, hRec
   LOCAL _svrha_placanja, _u_korist
   LOCAL _kome_txt, _KOME_ZR, _kome_sjed, _nacin_pl
   LOCAL _ko_zr, _ko_txt
   LOCAL _bez_nula := fetch_metric( "virm_generisanje_nule", my_user(), "N" )
   LOCAL _total, _kredit, _sk_sifra
   LOCAL _kred_opis := ""

   SELECT rekld
   GO TOP
   SEEK Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 ) + cOznakaIsplatePrefix // u rekld pronaci kredite

   DO WHILE !Eof() .AND. Left( field->id, Len( cOznakaIsplatePrefix ) ) == cOznakaIsplatePrefix


      cIdKreditor := PadR( SubStr( field->id, 5 ), LEN_PARTNER_ID )      // sifra kreditora KREDBBI001 -> BBI001
      pozicioniraj_rec_kreditor_partner( cIdKreditor )     // nastimaj kreditora i dodaj po potrebi
      pozicioniraj_rec_vrprim_sifra_kr()     // vrsta primanja - kredit

      SELECT vrprim
      _svrha_placanja := field->id

      select_o_partner( cIdKreditor )
      _u_korist := field->id
      _kome_txt := field->naz
      _kome_sjed := field->mjesto
      _nacin_pl := "1"
      _KOME_ZR := Space( 16 )

      virm_odredi_ziro_racun( _u_korist, @_KOME_ZR, .F. )

      SELECT virm_pripr
      GO TOP

      // uzmi podatke iz prve stavke
      _ko_txt := field->ko_txt
      _ko_zr := field->ko_zr

      select_o_partner( gVirmFirma )

      _total := 0
      _kredit := 0

      SELECT rekld
      _sk_sifra := field->idpartner
      // SK = sifra kreditora

      DO WHILE !Eof() .AND. field->id = "KRED" .AND. field->idpartner = _sk_sifra
         ++_kredit
         _total += rekld->iznos1
         _kred_opis := AllTrim( field->opis ) + ", " + AllTrim( field->opis2 )
         SKIP 1
      ENDDO

      // ako je vise kredita... opis treba promjeniti
      IF _kredit > 1
         _kredit_opis := "Krediti za " + PadL( Str( nMjesec, 2 ), "0" ) + "/" + Str( nGodina, 4 ) + ", partija: " + AllTrim( kred->zirod )
      ENDIF

      SKIP -1

      SELECT virm_pripr

      IF _bez_nula == "N" .OR. _total > 0

         APPEND BLANK

         REPLACE field->rbr WITH ++r_br
         REPLACE field->mjesto WITH gMjesto
         REPLACE field->svrha_pl WITH "KR"
         REPLACE field->iznos WITH _total
         REPLACE field->na_teret WITH gVirmFirma
         REPLACE field->kome_txt WITH _kome_txt
         REPLACE field->ko_txt WITH _ko_txt
         REPLACE field->ko_zr WITH _ko_zr
         REPLACE field->kome_sj WITH _kome_sjed
         REPLACE field->kome_zr WITH _KOME_ZR
         REPLACE field->dat_upl WITH dDatVirm
         REPLACE field->svrha_doz WITH AllTrim( vrprim->pom_txt ) + IF( !Empty( vrprim->pom_txt ), " ", "" ) + AllTrim( dod_opis ) + IF( !Empty( dod_opis ), " ", "" ) + AllTrim( _kred_opis )
         REPLACE field->u_korist WITH cIdKreditor

      ENDIF

      SELECT rekld
      SKIP

   ENDDO

   RETURN .T.



// --------------------------------------------
// RLD, funkcija koju zadajemo
// kao formulu pri prenosu...
// --------------------------------------------
FUNCTION RLD( cId, nIz12, qqPartn, br_dok )

   LOCAL nPom1 := 0
   LOCAL nPom2 := 0

   IF nIz12 == NIL
      nIz12 := 1
   ENDIF

   virm_rekap_ld( cId, _godina, _mjesec, @nPom1, @nPom2, , @nBrojRadnikaPrivateVar, qqPartn ) // prolazim kroz rekld i trazim npr DOPR1XSA01

   IF ValType( nIz12 ) == "N" .AND. nIz12 == 1
      RETURN nPom1
   ELSE
      RETURN nPom2
   ENDIF

   RETURN 0




// --------------------------------------
// Rekapitulacija LD-a
// --------------------------------------
STATIC FUNCTION virm_rekap_ld( cId, ;
      nGodina, ;
      nMjesec, ;
      nIzn1, ;
      nIzn2, ;
      cIdPartner, ;
      cOpis, ;
      qqPartn )

   LOCAL lGroup := .F.

   PushWA()

   IF cIdPartner == NIL
      cIdPartner := ""
   ENDIF

   IF cOpis == NIL
      cOpis := ""
   ENDIF

   // ima li marker "*"
   IF "**" $ cId
      lGroup := .T.
      // izbaci zvjezdice..
      cId := StrTran( cId, "**", "" )
   ENDIF

   SELECT rekld
   GO TOP

   IF qqPartn == NIL

      HSEEK Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 ) + cId

      IF lGroup == .T.

         DO WHILE !Eof() .AND. Str( nGodina, 4, 0 ) == field->nGodina .AND. Str( nMjesec, 2, 0 ) == field->nMjesec  .AND. id = cId

            nIzn1 += field->iznos1
            nIzn2 += field->iznos2

            SKIP
         ENDDO

      ELSE

         nIzn1 := field->iznos1
         nIzn2 := field->iznos2

      ENDIF

      cIdPartner := field->idpartner
      cOpis := field->opis

   ELSE

      nIzn1 := 0
      nIzn2 := 0
      nRadnika := 0
      aUslP := Parsiraj( qqPartn, "IDPARTNER" )

      SEEK Str( nGodina, 4, 0 ) + Str( nMjesec, 2, 0 ) + cId

      DO WHILE !Eof() .AND. field->nGodina + field->nMjesec + field->id = Str( nGodina, 4, 0 ) + Str( nMjesec, 2 ) + cId

         IF &aUslP

            nIzn1 += field->iznos1
            nIzn2 += field->iznos2

            IF Left( field->opis, 1 ) == "("

               cOpis := field->opis
               cOpis := StrTran( cOpis, "(", "" )
               cOpis := AllTrim( StrTran( cOpis, ")", "" ) )
               nRadnika += Val( cOpis )

            ENDIF

         ENDIF

         SKIP 1

      ENDDO

      cIdPartner := ""

      IF nRadnika > 0
         cOpis := "(" + AllTrim( Str( nRadnika ) ) + ")"
      ELSE
         cOpis := ""
      ENDIF

   ENDIF

   PopWA()

   RETURN .T.


STATIC FUNCTION virm_o_tables()

   o_banke()
   select_o_jprih()

   select_o_sifk()
   select_o_sifv()

   o_kred()

   select_o_rekld()
   select_o_partner()

   o_ldvirm()
   select_o_virm_pripr()

   RETURN .T.
