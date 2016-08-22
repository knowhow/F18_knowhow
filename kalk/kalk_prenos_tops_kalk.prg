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

#define D_MAX_FILES     150


FUNCTION kalk_preuzmi_tops_dokumente( sync_file, auto_razd, ch_barkod, mag_konto )

   LOCAL _auto_razduzenje := "N"
   LOCAL _br_kalk, _idvd_pos
   LOCAL _id_konto2 := ""
   LOCAL _bk_replace
   LOCAL _br_dok, _id_konto, _r_br
   LOCAL _bk_tmp
   LOCAL _app_rec
   LOCAL _imp_file := ""
   LOCAL _roba_data := {}
   LOCAL _count := 0
   LOCAL _razd_type := "1"

   // opcija za automatko svodjeje prodavnice na 0
   // ---------------------------------------------
   // prenese se tops promet u dokument 11
   // pa se prenese tops promet u dokument 42
   IF auto_razd <> NIL
      _auto_razduzenje := "D"
   ELSE
      _auto_razduzenje := fetch_metric( "kalk_tops_prenos_auto_razduzenje", my_user(), _auto_razduzenje )
   ENDIF


   tops_kalk_o_import_tabele() // otvori tabele bitne za import podataka

   IF sync_file <> NIL
      // zadano je parametrom
      _imp_file := sync_file
   ELSE

      IF !get_import_file( @_imp_file )   // fajl za import
         my_close_all_dbf()
         RETURN .F.
      ENDIF
   ENDIF


   SELECT ( F_TMP_TOPSKA )  // otvori temp tabelu
   my_use_temp( "TOPSKA", _imp_file )

   GO BOTTOM

   // utvrditi broj kalkulacije
   _br_kalk := Left( StrTran( DToC( field->datum ), ".", "" ), 4 ) + "/" + AllTrim( field->idpos )
   _idvd_pos := field->idvd

   // provjeri da li postoji podesenje za ovaj fajl importa
   SELECT koncij
   LOCATE FOR idprodmjes == topska->idpos

   IF !Found()
      MsgBeep( "U sifrarniku KONTA-TIPOVI CIJENA nije postavljeno#nigdje prodajno mjesto :" + field->idprodmjes + "#Prenos nije izvrsen." )
      my_close_all_dbf()
      RETURN
   ENDIF

   // SELECT kalk

   IF ( _idvd_pos == "42" .AND. _auto_razduzenje == "D" )
      _br_kalk  := kalk_get_next_broj_v5( gFirma, "11", NIL )
   ELSE


      IF find_kalk_doks_by_broj_dokumenta( gFirma, _idvd_pos, _br_kalk )
         Msg( "Vec postoji dokument pod brojem " + gFirma + "-" + _idvd_pos + "-" + _br_kalk + "#Prenos nece biti izvrsen" )
         my_close_all_dbf()
         RETURN .F.
      ENDIF

   ENDIF

   SELECT topska
   GO TOP

   // nacin zamjene barkod-ova
   // 0 - ne mjenjaj
   // 1 - ubaci samo nove
   // 2 - zamjeni sve

   IF ch_barkod <> NIL
      _bk_replace := ch_barkod
   ELSE
      _bk_replace := _bk_replace()
   ENDIF

   // konto magacina za razduzenje
   IF ( _idvd_pos == "42" .AND. _auto_razduzenje == "D" ) .OR. ( _idvd_pos == "12" )
      IF mag_konto <> NIL
         _id_konto2 := mag_konto
      ELSE
         _id_konto2 := _box_konto()
      ENDIF
   ENDIF

   // konacno idemo na import

   IF _auto_razduzenje == "D"

      _razd_type := auto_razd // razduziti kao 11 ili kao 42
   ENDIF

   _r_br := "0"

   MsgO( "Prenos stavki POS -> KALK priprema ... sacekajte !" )

   DO WHILE !Eof()

      _br_dok := _br_kalk
      _id_konto := koncij->id

      _n_rbr := RbrUNum( _r_br ) + 1
      _r_br := RedniBroj( _n_rbr )

      // provjeri da li roba postoji u sifraniku
      // ako ne postoji, dodaj...
      // dodaj u kontrolnu matricu ove informacije

      kalk_import_roba( @_roba_data, AllTrim( koncij->naz ) )

      IF ( _idvd_pos == "42" .OR. _idvd_pos == "12" )

         IF _auto_razduzenje == "D" .AND. _razd_type == "2"
            // formiraj stavku 11
            import_row_11( _br_dok, _id_konto, _id_konto2, _r_br )
         ELSE
            // formiraj stavku 42
            import_row_42( _br_dok, _id_konto, _id_konto2, _r_br )
         ENDIF

      ELSEIF ( _idvd_pos == "IN" )


         import_row_ip( _br_dok, _id_konto, _id_konto2, _r_br )  // inventura

      ENDIF

      // zamjena barkod-a ako postoji
      IF _bk_replace > 0

         SELECT roba
         SET ORDER TO TAG "ID"
         SEEK topska->idroba

         IF Found()

            _bk_tmp := roba->barkod

            IF _bk_replace == 2 .OR. ( _bk_replace == 1 .AND. !Empty( topska->barkod ) .AND. topska->barkod <> _bk_tmp )

               _app_rec := dbf_get_rec()
               _app_rec[ "barkod" ] := topska->barkod

               update_rec_server_and_dbf( "roba", _app_rec, 1, "FULL" )

            ENDIF

         ENDIF

      ENDIF

      ++ _count

      SELECT topska
      SKIP

   ENDDO

   MsgC()

   my_close_all_dbf()


   _show_report_roba( _roba_data )  // prikazi report

   IF ( _count > 0 .AND. _auto_razduzenje == "N" )

      IF FErase( _imp_file ) == -1 // pobrisi fajlove
         MsgBeep( "Problem sa brisanjem fajla !" )
      ENDIF
      FErase( StrTran( _imp_file, ".dbf", ".txt" ) )
   ENDIF

   RETURN .T.




// --------------------------------------------------------
// upit za tip prenosa
// --------------------------------------------------------
STATIC FUNCTION _get_razd_type()

   LOCAL _type := "1"
   PRIVATE GetList := {}

   Box(, 5, 60 )
   @ m_x + 1, m_y + 2 SAY "Tip razduzenja ***"
   @ m_x + 3, m_y + 2 SAY "  [1] dok. 42"
   @ m_x + 4, m_y + 2 SAY "  [2] dok. 11"
   @ m_x + 6, m_y + 2 SAY "          odabir:" GET _type VALID _type $ "12"
   READ
   BoxC()

   RETURN _type



// ----------------------------------------------------------------
// nacin zamjene barkod-ova prilikom importa
// ----------------------------------------------------------------
STATIC FUNCTION _bk_replace()

   LOCAL _ret := 0
   LOCAL _x := 1

   Box(, 7, 60 )

   @ m_x + _x, m_y + 2 SAY "Zamjena barkod-ova"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "0 - bez zamjene"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "1 - ubaci samo nove"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "2 - zamjeni sve"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY Space( 15 ) + "=> odabir" GET _ret PICT "9"

   READ

   BoxC()

   RETURN _ret


// parametri auto prenosa
STATIC FUNCTION kalk_tops_get_parametri_prenosa( params )

   LOCAL _ok := .F.
   LOCAL _d_od := Date()
   LOCAL _d_do := Date()
   LOCAL _x := 1
   LOCAL _id_pm := PadR( fetch_metric( "IDPos", NIL, "1 " ), 2 )
   LOCAL _mag_konto := PadR( "1320", 7 )
   LOCAL _type := "1"
   PRIVATE GetList := {}

   Box(, 8, 70 )

   @ m_x + _x, m_y + 2 SAY "*** Automatsko razduzenje prodavnice ***" COLOR F18_COLOR_I
   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Za datum od:" GET _d_od
   @ m_x + _x, Col() + 1 SAY "do:" GET _d_do

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Prodajno mjesto:" GET _id_pm VALID !Empty( _id_pm )

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Formiraj: [1] kalk.42, [2] kalk.11" GET _type VALID _type $ "12"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Kod 11-ke konto magacina:" GET _mag_konto

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   _ok := .T.
   params := hb_Hash()
   params[ "datum_od" ] := _d_od
   params[ "datum_do" ] := _d_do
   params[ "id_pm" ] := _id_pm
   params[ "tip_prenosa" ] := _type
   params[ "barkod_zamjena" ] := 0
   params[ "konto_magacin" ] := _mag_konto

   gIdPos := _id_pm

   RETURN _ok



// -----------------------------------------------------------
// automatsko preuzimanje fajla iz modula TOPS
// -----------------------------------------------------------
FUNCTION kalk_preuzmi_tops_dokumente_auto()

   LOCAL _file := my_home() + "tk_auto.dbf"
   LOCAL _tip_prenosa
   LOCAL _datum_od, _datum_do
   LOCAL _id_vd_pos := "42"
   LOCAL _id_pm
   LOCAL _barkod_zamjena
   LOCAL _params
   LOCAL _mag_konto


   PRIVATE gIdPos // incijalizacija radi TOPS funkcija

   IF !kalk_tops_get_parametri_prenosa( @_params )
      RETURN .F.
   ENDIF

   _datum_od := _params[ "datum_od" ]
   _datum_do := _params[ "datum_do" ]
   _id_pm := _params[ "id_pm" ]
   _tip_prenosa := _params[ "tip_prenosa" ]
   _barkod_zamjena := _params[ "barkod_zamjena" ]
   _mag_konto := _params[ "konto_magacin" ]

   MsgO( "Formiranje fajla prenosa u toku... " )

   // obrisi neki postojeci
   FileDelete( _file )
   FileDelete( StrTran( _file, ".dbf", ".txt" ) )

#ifdef POS_PRENOS_POS_KALK
   pos_prenos_pos_kalk( _datum_od, _datum_do, _id_vd_pos, _id_pm ) // 1)  napraviti prenos u POS-u...
#endif

   FileCopy( my_home() + "pom.dbf", _file ) // 2) kopiraj fajl u potrebni...

   IF !File( _file )
      MsgC()
      MsgBeep( "Neki problem !?" )
      RETURN .F.
   ENDIF


   kalk_preuzmi_tops_dokumente( _file, _tip_prenosa, _barkod_zamjena, _mag_konto ) // 3) pa zatim isti preuzmi iz POS-a

   MsgC()

   // 4) nakon preuzimanja pobrisi fajl razmjene
   FileDelete( _file )
   FileDelete( StrTran( _file, ".dbf", ".txt" ) )

   o_kalk_pripr()
   IF RecCount() <> 0
      MsgBeep( "Prenos dokumenata uspjesan, nalazi se u pripremi !" )
   ENDIF

   my_close_all_dbf()

   RETURN .T.

STATIC FUNCTION _box_konto()

   LOCAL _konto := PadR( "1320", 7 )
   LOCAL _t_area := Select()

   O_KONTO
   SELECT konto

   Box(, 3, 60 )
   @ m_x + 2, m_y + 2 SAY "Magacinski konto:" GET _konto VALID P_Konto( @_konto )
   READ
   BoxC()

   SELECT ( _t_area )

   RETURN _konto




STATIC FUNCTION _show_report_roba( data )

   LOCAL _i
   LOCAL _razlika := 0

   START PRINT CRET
   ?
   P_COND2

   ? "Razlike u cijenama:"
   ? "-------------------"
   ? PadR( "R.br", 5 ), PadR( "ID", 10 ), PadR( "naziv", 40 ), PadR( "POS cijena", 12 ), PadR( "KALK cijena", 12 )
   ? Replicate( "-", 80 )

   FOR _i := 1 TO Len( data )

      ? PadR( AllTrim( Str( _i, 4 ) ) + ".", 5 ), ;
         DATA[ _i, 1 ], ;
         PadR( DATA[ _i, 2 ], 40 ), ;
         Str( DATA[ _i, 3 ], 12, 2 ), ;
         Str( DATA[ _i, 4 ], 12, 2 )

      _razlika += DATA[ _i, 3 ] - DATA[ _i, 4 ]

   NEXT

   ? Replicate( "-", 80 )
   ? "Ukupno razlika:", AllTrim( Str( _razlika, 12, 2 ) )

   FF
   ENDPRINT

   RETURN

// --------------------------------------------
// import robe u sifrarnik robe
// --------------------------------------------
STATIC FUNCTION kalk_import_roba( a_roba, tip_cijene, update_roba )

   LOCAL _t_area := Select()
   LOCAL _rec, _mpc_naz

   // ako nema ovog polja, nista ne radi !
   IF topska->( FieldPos( "robanaz" ) ) == 0
      RETURN .F.
   ENDIF

   IF update_roba == NIL
      update_roba := .F.
   ENDIF

   SELECT roba
   HSEEK topska->idroba

   IF !Found()

      APPEND BLANK
      _rec := dbf_get_rec()

      _rec[ "id" ] := topska->idroba
      _rec[ "naz" ] := topska->robanaz
      _rec[ "idtarifa" ] := topska->idtarifa
      _rec[ "barkod" ] := topska->barkod

      IF topska->( FieldPos( "jmj" ) ) <> 0
         _rec[ "jmj" ] := topska->jmj
      ENDIF

      IF AllTrim( tip_cijene ) == "M1" .OR. Empty( tip_cijene )
         _rec[ "mpc" ] := topska->mpc
      ELSE
         // M3 -> mpc3
         _mpc_naz := StrTran( tip_cijene, "M", "mpc" )
         _rec[ _mpc_naz ] := topska->mpc
      ENDIF

      update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )

      // dodaj u kontrolnu matricu
      AAdd( a_roba, { topska->idroba, topska->robanaz, topska->mpc, 0 } )

   ELSE

      _rec := dbf_get_rec()

      IF AllTrim( tip_cijene ) == "M1" .OR. Empty( tip_cijene )
         _mpc_naz := "mpc"
      ELSE
         // M3 -> mpc3
         _mpc_naz := StrTran( tip_cijene, "M", "mpc" )
      ENDIF

      IF Round( _rec[ _mpc_naz ], 2 ) <> Round( topska->mpc, 2 )

         AAdd( a_roba, { topska->idroba, topska->robanaz, topska->mpc, _rec[ _mpc_naz ] } )

         _rec[ _mpc_naz ] := topska->mpc

         IF update_roba
            update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )
         ENDIF

      ENDIF

   ENDIF

   SELECT ( _t_area )

   RETURN


// ---------------------------------------------------------
// formiraj stavku inventure prodavnice
// ---------------------------------------------------------
STATIC FUNCTION import_row_ip( broj_dok, id_konto, id_konto2, r_br )

   LOCAL _tip_dok := "IP"
   LOCAL _t_area := Select()
   LOCAL _kolicina := 0
   LOCAL _nc := 0
   LOCAL _fc := 0
   LOCAL _mpcsapp := 0
   LOCAL _marzap := 50

   IF ( topska->kol2 == 0 )
      RETURN .F.
   ENDIF

   // sracunaj za ovu stavku stanje inventurno u kalk-u
   kalk_ip_roba( id_konto, topska->idroba, topska->datum, @_kolicina, @_nc, @_fc, @_mpcsapp )

   IF _kolicina == 0

      // nema ga na stanju...
      // morat cemo preci na rucni rad racunice

      _mpcsapp := topska->mpc
      _nc := Round( _mpcsapp * ( _marzap / 100 ), 2 )

   ENDIF

   // uvijek uzmi iz topska ovu cijenu pri prenosu
   _mpcsapp := topska->mpc

   SELECT kalk_pripr

   my_flock()

   LOCATE FOR field->idroba == topska->idroba

   IF !Found()

      APPEND BLANK

      REPLACE field->idfirma WITH gFirma
      REPLACE field->idvd WITH _tip_dok
      REPLACE field->brdok WITH broj_dok
      REPLACE field->datdok WITH topska->datum
      REPLACE field->datfaktp WITH topska->datum
      REPLACE field->kolicina WITH topska->kol2
      REPLACE field->gkolicina WITH _kolicina
      REPLACE field->gkolicin2 with ( gkolicina - kolicina )
      REPLACE field->idkonto WITH id_konto
      REPLACE field->idkonto2 WITH id_konto
      REPLACE field->pkonto WITH id_konto
      REPLACE field->idroba WITH topska->idroba
      REPLACE field->rbr WITH r_br
      REPLACE field->idtarifa WITH topska->idtarifa
      REPLACE field->mpcsapp WITH _mpcsapp
      REPLACE field->nc WITH _nc
      REPLACE field->fcj WITH _fc
      REPLACE field->pu_i WITH "I"
      REPLACE field->error WITH "0"

   ELSE

      // samo appenduj kolicinu
      REPLACE field->kolicina WITH field->kolicina + topska->kol2
      REPLACE field->gkolicin2 with ( gkolicina - kolicina )

   ENDIF

   my_unlock()

   SELECT ( _t_area )

   RETURN .T.




// ---------------------------------------------------------
// formiraj stavku razduzenja magacina
// ---------------------------------------------------------
STATIC FUNCTION import_row_11( broj_dok, id_konto, id_konto2, r_br )

   LOCAL _tip_dok := "11"
   LOCAL _t_area := Select()

   IF ( topska->kolicina == 0 )
      RETURN .F.
   ENDIF

   SELECT kalk_pripr

   my_flock()

   APPEND BLANK

   REPLACE field->idfirma WITH gFirma
   REPLACE field->idvd WITH _tip_dok
   REPLACE field->brdok WITH broj_dok
   REPLACE field->datdok WITH topska->datum
   REPLACE field->datfaktp WITH topska->datum
   REPLACE field->kolicina WITH topska->kolicina
   REPLACE field->idkonto WITH id_konto
   REPLACE field->idkonto2 WITH id_konto2
   REPLACE field->idroba WITH topska->idroba
   REPLACE field->rbr WITH r_br
   REPLACE field->tmarza2 WITH "%"
   REPLACE field->idtarifa WITH topska->idtarifa
   REPLACE field->mpcsapp WITH topska->( mpc - stmpc )
   REPLACE field->tprevoz WITH "R"

   my_unlock()

   SELECT ( _t_area )

   RETURN .T.


// ---------------------------------------------------------
// formiraj stavku razduzenja prodavnice
// ---------------------------------------------------------
STATIC FUNCTION import_row_42( broj_dok, id_konto, id_konto2, r_br )

   LOCAL _t_area := Select()
   LOCAL _opp

   IF ( topska->kolicina == 0 )
      RETURN
   ENDIF

   SELECT tarifa
   HSEEK topska->idtarifa
   _opp := tarifa->opp

   SELECT kalk_pripr

   my_flock()

   APPEND BLANK

   REPLACE field->idfirma WITH gFirma
   REPLACE field->idvd WITH topska->idvd
   REPLACE field->brdok WITH broj_dok
   REPLACE field->datdok WITH topska->datum
   REPLACE field->datfaktp WITH topska->datum
   REPLACE field->kolicina WITH topska->kolicina
   REPLACE field->idkonto WITH id_konto
   REPLACE field->idroba WITH topska->idroba
   REPLACE field->rbr WITH r_br
   REPLACE field->tmarza2 WITH "%"
   REPLACE field->idtarifa WITH topska->idtarifa
   REPLACE field->mpcsapp WITH topska->mpc

   IF Round( topska->stmpc, 2 ) <> 0
      IF _opp > 0
         // izbijamo PDV iz ove stavke ako je tarifa PDV17
         REPLACE field->rabatv with ( topska->stmpc / ( 1 + ( _opp / 100 ) ) )
      ELSE
         // tarifa nije PDV17
         REPLACE field->rabatv WITH topska->stmpc
      ENDIF
   ENDIF

   my_unlock()

   SELECT ( _t_area )

   RETURN




// ----------------------------------------------------------
// daj mi sva prodajna mjesta iz koncija
// ----------------------------------------------------------
STATIC FUNCTION _prodajna_mjesta_iz_koncij()

   LOCAL _a_pm := {}
   LOCAL _scan

   SELECT koncij
   GO TOP

   DO WHILE !Eof()
      // ako nije prazno
      // ako je maloprodaja
      IF !Empty( field->idprodmjes ) .AND. Left( field->naz, 1 ) == "M"
         _scan := AScan( _a_pm, {| x| AllTrim( x ) == AllTrim( field->idprodmjes ) } )
         IF _scan == 0
            AAdd( _a_pm, AllTrim( field->idprodmjes ) )
         ENDIF
      ENDIF
      SKIP
   ENDDO

   RETURN _a_pm


// ----------------------------------------------------------
// selekcija fajla za import podataka
// ----------------------------------------------------------
STATIC FUNCTION get_import_file( import_file )

   LOCAL _opc := {}
   LOCAL _pos_kum_path
   LOCAL _prod_mjesta
   LOCAL _ret := .T.
   LOCAL _i, _imp_files, _opt, _h, _n
   LOCAL _imp_patt := "t*.dbf"
   LOCAL _prenesi, _izbor, _a_tmp1, _a_tmp2
   LOCAL cTopsDest := kalk_destinacija_topska()

   _prod_mjesta := _prodajna_mjesta_iz_koncij() // sva prodajna mjesta iz tabele koncij

   IF Len( _prod_mjesta ) == 0
      MsgBeep( "U tabeli koncij nisu definisana prodajna mjesta !" ) // imamo problem, nema prodajnih mjesta
      _ret := .F.
      RETURN _ret
   ENDIF

   FOR _i := 1 TO Len( _prod_mjesta )


      _pos_kum_path := cTopsDest + AllTrim( _prod_mjesta[ _i ] ) + SLASH  // putanja koju cu koristiti

      BrisiSFajlove( _pos_kum_path ) // brisi sve fajlove starije od 28 dana

      _imp_files := Directory( _pos_kum_path + _imp_patt ) // fajlove u matricu po pattern-u

      ASort( _imp_files,,, {| x, y| DToS( x[ 3 ] ) + x[ 4 ] > DToS( y[ 3 ] ) + y[ 4 ] } )

      // dodaj u matricu za odabir
      AEval( _imp_files, {| elem| AAdd( _opc, PadR( AllTrim( _prod_mjesta[ _i ] ) + ;
         SLASH + Trim( elem[ 1 ] ), 20 ) + " " + ;
         UChkPostoji() + " " + DToC( elem[ 3 ] ) + " " + elem[ 4 ] ;
         ) }, 1, D_MAX_FILES )


   NEXT


   ASort( _opc,,, {| x, y| Right( x, 19 ) > Right( y, 19 ) } ) // R/X + datum + vrijeme

   _h := Array( Len( _opc ) )

   FOR _n := 1 TO Len( _h )
      _h[ _n ] := ""
   NEXT


   IF Len( _opc ) == 0 // ima li stavki za preuzimanje ?

      MsgBeep( "U direktoriju za prenos nema podataka /2" )
      _ret := .F.
      RETURN _ret

   ENDIF

   _izbor := 1
   _prenesi := .F.

   DO WHILE .T.

      _izbor := Menu( "izdat", _opc, _izbor, .F. )

      IF _izbor == 0
         EXIT
      ELSE

         import_file := cTopsDest + AllTrim( Left( _opc[ _izbor ], 20 ) )

         IF Pitanje(, "Zelite li izvrsiti prenos ?", "D" ) == "D"
            _prenesi := .T.
            _izbor := 0
         ELSE
            LOOP
         ENDIF
      ENDIF
   ENDDO

   IF !_prenesi
      _ret := .F.
      RETURN _ret
   ENDIF

   RETURN _ret


STATIC FUNCTION tops_kalk_o_import_tabele()

   SELECT ( F_ROBA )
   IF !Used()
      O_ROBA
   ENDIF

   SELECT ( F_TARIFA )
   IF !Used()
      O_TARIFA
   ENDIF

   SELECT ( F_KALK_PRIPR )
   IF !Used()
      o_kalk_pripr()
   ENDIF

   SELECT ( F_KONCIJ )
   IF !Used()
      o_koncij()
   ENDIF

   RETURN .T.
