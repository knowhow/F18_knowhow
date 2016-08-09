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


STATIC __MAX_QT := 99999.999
STATIC __MIN_QT := 0.001
STATIC __MAX_PRICE := 999999.99
STATIC __MIN_PRICE := 0.01
STATIC __MAX_PERC := 99.99
STATIC __MIN_PERC := -99.99



/*
 fajl za fiskalni stampac
*/

FUNCTION fiscal_out_filename( file_name, rn_broj, trig )

   LOCAL _ret, _rn
   LOCAL _f_name := AllTrim( file_name )

   IF trig == nil
      trig := ""
   ENDIF

   trig := AllTrim( trig )

   DO CASE


   CASE "$rn" $ _f_name // po broju racuna ( TREMOL )

      IF Empty( rn_broj )
         _ret := StrTran( _f_name, "$rn", "0000" )
      ELSE
         // broj racuna.xml
         _rn := PadL( AllTrim( rn_broj ), 8, "0" )
         // ukini znak "/" ako postoji
         _rn := StrTran( _rn, "/", "" )
         _ret := StrTran( _f_name, "$rn", _rn )
      ENDIF

      _ret := Upper( _ret )


   CASE "TR$" $ _f_name // po trigeru ( HCP, TRING )

      // odredjuje PLU ili CLI ili RCP na osnovu trigera
      _ret := StrTran( _f_name, "TR$", trig )
      _ret := Upper( _ret )

      IF ".XML" $ Upper( trig )
         _ret := trig
      ENDIF


   OTHERWISE  // ostale verijante
      _ret := _f_name

   ENDCASE

   RETURN _ret


// ---------------------------------------------------
// ispravi naziv artikla
// ---------------------------------------------------
FUNCTION fiscal_art_naz_fix( naz, drv )

   LOCAL _ret := ""

   DO CASE
   CASE drv == "FPRINT"
      _ret := StrTran( naz, ";", "" )
   OTHERWISE
      _ret := naz
   ENDCASE

   RETURN _ret



FUNCTION posljednji_plu_artikla()

   LOCAL nPlu := 0
   LOCAL cSql, oQuery

   cSql := "SELECT MAX( fisc_plu ) AS last_plu FROM " + F18_PSQL_SCHEMA_DOT + "roba"
   oQuery := run_sql_query( cSql )

   nPlu := query_row( oQuery, "last_plu" )

   RETURN nPlu



// -------------------------------------------------
// generise novi plu kod za sifru
// -------------------------------------------------
FUNCTION gen_plu( nVal )

   LOCAL nPlu := 0

   IF ( ( Ch == K_CTRL_N ) .OR. ( Ch == K_F4 ) )

      IF LastKey() == K_ESC
         RETURN .F.
      ENDIF

      nVal := posljednji_plu_artikla() + 1

   ENDIF

   RETURN .T.


// -------------------------------------------------------
// generisi PLU kodove za postojece stavke sifraranika
// -------------------------------------------------------
FUNCTION gen_all_plu( lSilent )

   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL nPLU := 0
   LOCAL lReset := .F.
   LOCAL nP_PLU := 0
   LOCAL nCnt
   LOCAL _rec
   LOCAL hParams

   IF lSilent == nil
      lSilent := .F.
   ENDIF

   IF lSilent == .F. .AND. !spec_funkcije_sifra( "GENPLU" )
      MsgBeep( "Neispravnan unos lozinke !" )
      RETURN .F.
   ENDIF

   IF lSilent == .F. .AND. Pitanje(, "Resetovati postojeće PLU", "N" ) == "D"
      lReset := .T.
   ENDIF

   IF lSilent == .T.
      lReset := .F.
   ENDIF

   run_sql_query( "BEGIN" )
   IF !f18_lock_tables( { "roba" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati ROBA !#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   O_ROBA
   SELECT ROBA
   GO TOP

   // prvo mi nadji zadnji PLU kod
   SELECT roba
   SET ORDER TO TAG "PLU"
   GO TOP
   SEEK Str( 9999999999, 10 )
   SKIP -1
   nP_PLU := field->fisc_plu
   nCnt := 0

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   Box(, 1, 50 )
   DO WHILE !Eof()

      IF lReset == .F.
         // preskoci ako vec postoji PLU i
         // neces RESET
         IF field->fisc_plu <> 0
            SKIP
            LOOP
         ENDIF
      ENDIF

      ++ nCnt
      ++ nP_PLU

      _rec := dbf_get_rec()
      _rec[ "fisc_plu" ] := nP_PLU

      lOk := update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

      IF !lOk
         EXIT
      ENDIF

      @ m_x + 1, m_y + 2 SAY PadR( "idroba: " + field->id + ;
         " -> PLU: " + AllTrim( Str( nP_PLU ) ), 30 )

      SKIP

   ENDDO

   BoxC()

   IF lOk
      lRet := .T.
      hParams := hb_Hash()
      hParams[ "unlock" ] :=  { "roba" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
   ENDIF

   IF nCnt > 0
      IF !lSilent
         MsgBeep( "Generisao " + AllTrim( Str( nCnt ) ) + " PLU kodova." )
      ENDIF
   ENDIF

   RETURN lRet




// --------------------------------------------------
// vraca iz parametara zadnji PLU broj
// --------------------------------------------------
FUNCTION last_plu( device_id )

   LOCAL _plu := 0
   LOCAL _param_name := _get_auto_plu_param_name( device_id )

   _plu := fetch_metric( _param_name, nil, _plu )

   RETURN _plu




// --------------------------------------------------
// generisanje novog plug kod-a inkrementalno
// --------------------------------------------------
FUNCTION auto_plu( reset_plu, silent_mode, dev_params )

   LOCAL _plu := 0
   LOCAL _t_area := Select()
   LOCAL _param_name := _get_auto_plu_param_name( dev_params[ "id" ] )

   IF reset_plu == nil
      reset_plu := .F.
   ENDIF

   IF silent_mode == nil
      silent_mode := .F.
   ENDIF

   IF reset_plu = .T.
      // uzmi inicijalni plu iz parametara
      _plu := dev_params[ "plu_init" ]
   ELSE
      _plu := fetch_metric( _param_name, nil, _plu )
      // prvi put pokrecemo opciju, uzmi init vrijednost !
      IF _plu == 0
         _plu := dev_params[ "plu_init" ]
      ENDIF
      // uvecaj za 1
      ++ _plu
   ENDIF

   IF reset_plu = .T. .AND. !silent_mode
      IF !spec_funkcije_sifra( "RESET" )
         MsgBeep( "Unesena pogrešna šifra !" )
         SELECT ( _t_area )
         RETURN _plu
      ENDIF
   ENDIF

   // upisi u sql/db
   set_metric( _param_name, nil, _plu )

   IF reset_plu = .T. .AND. !silent_mode
      MsgBeep( "Setovan početni PLU na: " + AllTrim( Str( _plu ) ) )
   ENDIF

   SELECT ( _t_area )

   RETURN _plu


// -----------------------------------------------------------------
// "auto_plu_dev_1" - auto plu device 1
// "auto_plu_dev_2" - auto plu device 2
// -----------------------------------------------------------------
STATIC FUNCTION _get_auto_plu_param_name( device_id )

   LOCAL _tmp := "auto_plu"
   LOCAL _ret

   _ret := _tmp + "_dev_" + AllTrim( Str( device_id ) )

   RETURN _ret



FUNCTION fiscal_txt_get_tarifa( tarifa_id, pdv, drv )

   LOCAL _tar := "2"
   LOCAL _tmp

   // PDV17 -> PDV1 ili PDV7NP -> PDV7 ili PDV0IZ -> PDV0 ili PDVM
   _tmp := Left( Upper( AllTrim( tarifa_id ) ), 4 )

   DO CASE

   CASE ( _tmp == "PDV1" .OR. _tmp == "PDV7" ) .AND. pdv == "D"

      // PDV je tarifna skupina "E"

      IF drv == "TRING"
         _tar := "E"
      ELSEIF drv == "FPRINT"
         _tar := "2"
      ELSEIF drv == "HCP"
         _tar := "1"
      ELSEIF drv == "TREMOL"
         _tar := "2"
      ENDIF

   CASE _tmp == "PDV0" .AND. pdv == "D"

      // bez PDV-a je tarifna skupina "K"

      IF drv == "TRING"
         _tar := "K"
      ELSEIF drv == "FPRINT"
         _tar := "4"
      ELSEIF drv == "HCP"
         _tar := "3"
      ELSEIF drv == "TREMOL"
         _tar := "1"
      ENDIF

   CASE _tmp == "PDVM"

      IF drv == "FPRINT"
         _tar := "5"
      ELSEIF drv == "TRING"
         _tar := "M"
      ENDIF

   CASE pdv == "N"

      // ne-pdv obveznik, skupina "A"
      IF drv == "TRING"
         _tar := "A"
      ELSEIF drv == "FPRINT"
         _tar := "1"
      ELSEIF drv == "HCP"
         _tar := "0"
      ELSEIF drv == "TREMOL"
         _tar := "3"
      ENDIF

   OTHERWISE

      MsgBeep( "Greška sa tarifom !!!" )

   ENDCASE

   RETURN _tar


FUNCTION fiscal_txt_get_vr_plac( id_plac, drv )

   LOCAL _ret := ""

   DO CASE

   CASE id_plac == "0"

      IF drv == "TRING"
         _ret := "Gotovina"
      ELSEIF drv $ "#HCP#FPRINT#"
         _ret := id_plac
      ELSEIF drv == "TREMOL"
         _ret := "Gotovina"
      ENDIF

   CASE id_plac == "1"

      IF drv == "TRING"
         _ret := "Cek"
      ELSEIF drv $ "#HCP#FPRINT#"
         _ret := id_plac
      ELSEIF drv == "TREMOL"
         _ret := "Cek"
      ENDIF

   CASE id_plac == "2"

      IF drv == "TRING"
         _ret := "Virman"
      ELSEIF drv $ "#HCP#FPRINT#"
         _ret := id_plac
      ELSEIF drv == "TREMOL"
         _ret := "Kartica"
      ENDIF

   CASE id_plac == "3"

      IF drv == "TRING"
         _ret := "Kartica"
      ELSEIF drv $ "#HCP#FPRINT#"
         _ret := id_plac
      ELSEIF drv == "TREMOL"
         _ret := "Virman"
      ENDIF

   ENDCASE

   RETURN _ret



FUNCTION provjeri_kolicine_i_cijene_fiskalnog_racuna( items, storno, nLevel, drv )

   LOCAL _i, _cijena, _plu_cijena, _kolicina, _naziv
   LOCAL _fix := 0
   LOCAL _ret := 0
   LOCAL lImaGreska := .F.

   IF drv == NIL
      drv := "FPRINT"
   ENDIF

   // aData[4] - naziv
   // aData[5] - cijena
   // aData[6] - kolicina

   set_min_max_values( drv )

   IF storno == NIL
      storno := .F.
   ENDIF

   FOR _i := 1 TO Len( items )

      lImaGreska := .F.

      _cijena := Round( items[ _i, 5 ], 4 )
      _plu_cijena := Round( items[ _i, 10 ], 4 )
      _kolicina := Round( items[ _i, 6 ], 4 )
      _naziv := items[ _i, 4 ]

      IF ( !is_ispravna_kolicina( _naziv, _kolicina ) .OR. !is_ispravna_cijena( _naziv, _cijena ) ) .OR. !is_ispravna_cijena( _naziv, _plu_cijena )

         lImaGreska := .T.

         IF ( nLevel > 1 .AND. _kolicina > 1 )

            prepakuj_vrijednosti_na_100_komada( @_kolicina, @_cijena, @_plu_cijena, @_naziv )

            items[ _i, 5 ] := _cijena
            items[ _i, 10 ] := _plu_cijena
            items[ _i, 6 ] := _kolicina
            items[ _i, 4 ] := _naziv

            lImaGreska := .F.
            ++ _fix

         ENDIF

         IF lImaGreska
            EXIT
         ENDIF

      ENDIF

   NEXT

   IF _fix > 0 .AND. nLevel > 1

      MsgBeep( "Pojedini artikli na računu su prepakovani na 100 kom !" )

   ELSEIF ( _fix > 0 .AND. nLevel == 1 ) .OR. lImaGreska

      _ret := -99

      MsgBeep ( "Pojedinim artiklima je količina/cijena van dozvoljenog ranga#Prekidam operaciju !" )

      IF storno
         _ret := 0
      ENDIF

   ENDIF

   RETURN _ret



STATIC FUNCTION set_min_max_values( drv )

   DO CASE

   CASE drv $ "FPRINT#TRING"

      __MAX_QT := 99999.999
      __MIN_QT := 0.001
      __MAX_PRICE := 999999.99
      __MIN_PRICE := 0.01
      __MAX_PERC := 99.99
      __MIN_PERC := -99.99

   CASE drv $ "HCP#TREMOL"

      __MAX_QT := 99999.999
      __MIN_QT := 0.001
      __MAX_PRICE := 999999.99
      __MIN_PRICE := 0.01
      __MAX_PERC := 99.99
      __MIN_PERC := -99.99

   ENDCASE

   RETURN .T.




STATIC FUNCTION is_ispravna_kolicina( cNaziv, nKolicina )
   RETURN validator_vrijednosti( "kol_" + cNaziv, nKolicina, __MIN_QT, __MAX_QT, 3 )



STATIC FUNCTION is_ispravna_cijena( cNaziv, nCijena )
   RETURN validator_vrijednosti( "cij_" + cNaziv, nCijena, __MIN_PRICE, __MAX_PRICE, 2 )



STATIC FUNCTION validator_vrijednosti( cNaziv, nValue, nMinValue, nMaxValue, nDec )

   LOCAL cMsg

   IF nValue > nMaxValue .OR. nValue < nMinValue
      cMsg := cNaziv + " / val: " + AllTrim( Str( nValue ) ) + " min: " + AllTrim( Str( nMinValue ) ) + " max: " +  AllTrim( Str( nMaxValue ) )
      error_bar( "fisk", cMsg )
      RETURN .F.
   ENDIF


   IF nDec <> NIL .AND. ( Abs( nValue ) - Abs( Round( nValue, nDec ) ) <> 0 )
      cMsg := cNaziv + " / val: " + AllTrim( Str( nValue ) ) + " dec max: " + AllTrim( Str( nDec ) )
      error_bar( "fisk", cMsg )

      RETURN .F.
   ENDIF

   RETURN .T.



STATIC FUNCTION prepakuj_vrijednosti_na_100_komada( nQtty, nPrice, nPPrice, cName )

   nQtty := nQtty / 100
   nPrice := nPrice * 100
   nPPrice := nPPrice * 100
   cName := Left( AllTrim( cName ), 5 ) + " x100"

   RETURN



FUNCTION zadnji_fiscal_z_report_info( cre_rpt )

   LOCAL _param_date := "zadnji_Z_izvjestaj_datum"
   LOCAL _param_time := "zadnji_Z_izvjestaj_vrijeme"
   LOCAL _z_date := fetch_metric( _param_date, NIL, CToD( "" ) )
   LOCAL _z_time := fetch_metric( _param_time, NIL, "" )
   LOCAL _warr := fetch_metric( "fiscal_opt_usr_daily_warrning", my_user(), "N" )
   LOCAL _fiscal_use := fiscal_opt_active()

   IF cre_rpt == NIL
      cre_rpt := .F.
   ENDIF

   IF !_fiscal_use
      RETURN
   ENDIF

   IF _warr == "N"
      RETURN
   ENDIF

   IF DToC( Date() ) + AllTrim( Time() ) > DToC( _z_date ) + AllTrim( _z_time )

      MsgBeep( "Zadnji dnevni izvještaj rađen " + DToC( _z_date ) + " u " + _z_time + "#" + ;
         "Potrebno napraviti dnevni izvještaj#" + ;
         "prije izdavanja novih računa !" )

      IF cre_rpt
         IF Pitanje(, "Napraviti dnevni izvještaj (D/N) ?", "N" ) == "D"
         ENDIF
      ENDIF

   ENDIF

   RETURN
