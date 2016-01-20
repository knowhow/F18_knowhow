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


STATIC __device_id := 0
STATIC __device_params
STATIC __auto := .F.
STATIC __racun_na_email := NIL
STATIC __partn_ino
STATIC __partn_pdv
STATIC __vrsta_pl
STATIC __prikazi_partnera
STATIC __DRV_TREMOL := "TREMOL"
STATIC __DRV_FPRINT := "FPRINT"
STATIC __DRV_FLINK := "FLINK"
STATIC __DRV_HCP := "HCP"
STATIC __DRV_TRING := "TRING"
STATIC __DRV_CURRENT


FUNCTION param_racun_na_email( read_par )

   IF read_par != NIL
      __racun_na_email := fetch_metric( "fakt_dokument_na_email", my_user(), "" )
   ENDIF

   RETURN __racun_na_email




FUNCTION fakt_fiskalni_racun( id_firma, tip_dok, br_dok, auto_print, dev_param )

   LOCAL _err_level := 0
   LOCAL _dev_drv
   LOCAL _storno := .F.
   LOCAL _items_data, _partn_data
   LOCAL _cont := "1"
   LOCAL lRacunBezgBezPartnera

   IF !fiscal_opt_active()
      RETURN _err_level
   ENDIF

   IF ( auto_print == NIL )
      auto_print := .F.
   ENDIF

   IF auto_print
      __auto := .T.
   ENDIF

   IF dev_param == NIL
      RETURN _err_level
   ENDIF

   __device_params := dev_param

   _dev_drv := AllTrim( dev_param[ "drv" ] )

   lRacunBezgBezPartnera := ( dev_param["vp_no_customer"] == "D" )

   __DRV_CURRENT := _dev_drv

   SELECT fakt_doks
   SET FILTER TO

   SELECT fakt
   SET FILTER TO

   SELECT partn
   SET FILTER TO

   SELECT fakt_doks

   IF postoji_fiskalni_racun( id_firma, tip_dok, br_dok, _dev_drv )
      MsgBeep( "Za dokument " + tip_dok + "-" + ALLTRIM(br_dok) + " već postoji izdat fiskalni račun !" )
      RETURN _err_level
   ENDIF

   _storno := fakt_dok_is_storno( id_firma, tip_dok, br_dok )

   IF ValType( _storno ) == "N" .AND. _storno == -1
      RETURN _err_level
   ENDIF

   IF _storno
      IF !fakt_reklamirani_racun_preduslovi( id_firma, tip_dok, br_dok, dev_param )
         RETURN _err_level
      ENDIF
   ENDIF

   _partn_data := fakt_fiscal_podaci_partnera( id_firma, tip_dok, br_dok, _storno, lRacunBezgBezPartnera )

   IF ValType( _partn_data ) == "L"
      RETURN 1
   ENDIF

   _items_data := fakt_fiscal_stavke_racuna( id_firma, tip_dok, br_dok, _storno, _partn_data )

   IF ValType( _items_data ) == "L" .OR. _items_data == NIL
      RETURN 1
   ENDIF

   DO CASE

   CASE _dev_drv == "TEST"
      _err_level := 0

   CASE _dev_drv == __DRV_FPRINT
      _err_level := fakt_to_fprint( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno )

   CASE _dev_drv == __DRV_TREMOL
      _cont := "1"
      _err_level := fakt_to_tremol( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno, _cont )

   CASE _dev_drv == __DRV_HCP
      _err_level := fakt_to_hcp( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno )

   CASE _dev_drv == __DRV_TRING
      _err_level := fakt_to_tring( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno )

   ENDCASE

   DirChange( my_home() )

   log_write( "fiskalni racun " + _dev_drv + " za dokument: " + ;
      AllTrim( id_firma ) + "-" + AllTrim( tip_dok ) + "-" + AllTrim( br_dok ) + ;
      " err level: " + AllTrim( Str( _err_level ) ) + ;
      " partner: " + IF( _partn_data <> NIL, AllTrim( _partn_data[ 1, 1 ] ) + ;
      " - " + AllTrim( _partn_data[ 1, 2 ] ), "NIL" ), 3 )

   IF _err_level > 0

      IF _dev_drv == __DRV_TREMOL

         _cont := "2"
         _err_level := fakt_to_tremol( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno, _cont )

         IF _err_level > 0
            MsgBeep( "Problem sa štampanjem na fiskalni uređaj !" )
         ENDIF

      ENDIF

   ENDIF

   RETURN _err_level



FUNCTION reklamni_rn_box( rekl_rn )

   Box(, 1, 60 )
   @ m_x + 1, m_y + 2 SAY8 "Reklamiramo fiskalni račun broj:" ;
      GET rekl_rn PICT "999999999" VALID ( rekl_rn > 0 )
   READ
   BoxC()

   IF LastKey() == K_ESC .AND. rekl_rn == 0
      rekl_rn := -1
   ENDIF

   RETURN rekl_rn




STATIC FUNCTION idpartner_sa_fakt_dokumenta( idfirma, idtipdok, brdok )

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP

   SEEK idfirma + idtipdok + brdok

   cIdPartner := fakt_doks->idpartner

   RETURN cIdPartner



STATIC FUNCTION fakt_izracunaj_ukupnu_vrijednost_racuna( idfirma, idtipdok, brdok )

   LOCAL nUkupno := 0
   LOCAL aIznosi, _data_total
   LOCAL cIdPartner := ""

   SELECT ( F_ROBA )
   IF !Used()
      O_ROBA
   ENDIF

   SELECT ( F_TARIFA )
   IF !Used()
      O_TARIFA
   ENDIF

   cIdPartner := idpartner_sa_fakt_dokumenta( idfirma, idtipdok, brdok )
   aIznosi := get_a_iznos( idfirma, idtipdok, brdok )
   _data_total := fakt_izracunaj_total( aIznosi, cIdPartner, idtipdok )

   nUkupno := _data_total["ukupno"]

   RETURN nUkupno



STATIC FUNCTION fakt_reklamirani_racun_preduslovi( idfirma, idtipdok, brdok, device_params, lForsirano )

   LOCAL lRet := .T.
   LOCAL nDepozit := 0
   LOCAL nErr := 0
   LOCAL aIznosi, _data_total

   // #34537
   IF AllTrim( device_params[ "drv" ] ) <> "FPRINT"
      RETURN lRet
   ENDIF

   IF lForsirano == NIL
      lForsirano := .F.
   ENDIF

   IF !lForsirano
      MsgBeep( "Želite izdati reklamirani račun.#Prije toga je neophodno da postoji minimalan depozit u uređaju.")
   ENDIF

   IF !lForsirano .AND. Pitanje(, "Da li je potrebno napraviti unos depozita (D/N) ?", " " ) == "N"
       RETURN lRet
   ENDIF

   nDepozit := ABS( fakt_izracunaj_ukupnu_vrijednost_racuna( idfirma, idtipdok, brdok ) )

   nDepozit := ROUND( nDepozit + 1, 0 )

   fprint_delete_answer( device_params )

   fprint_polog( device_params, nDepozit, .T. )

   nErr := fprint_read_error( device_params, 0 )

   IF nErr <> 0
      lRet := .F.
      MsgBeep( "Neuspješan unosa depozita u uređaj !" )
      RETURN lRet
   ENDIF

   RETURN lRet




/*

 Opis: ispituje da li je za dokument napravljen fiskalni račun

 Usage: postoji_fiskalni_racun( idfirma, idtipdok, brdok, model ) -> SQL upit se šalje prema serveru 

   Parameters: 
     - idfirma 
     - idtipdok
     - brdok
     - model - model uređaja, proslijeđuje se rezultat funkcije fiskalni_uredjaj_model()

   Retrun: 
    .T. ako postoji fiskalni račun, .F. ako ne

*/

FUNCTION postoji_fiskalni_racun( id_firma, tip_dok, br_dok, model )

   LOCAL lRet := .F.
   LOCAL cWhere

   IF model == NIL
      model := fiskalni_uredjaj_model()
   ENDIF

   cWhere := " idfirma = " + _sql_quote( id_firma )
   cWhere += " AND idtipdok = " + _sql_quote( tip_dok )
   cWhere += " AND brdok = " + _sql_quote( br_dok )

   IF ALLTRIM( model ) $ "FPRINT#HCP"
      cWhere += " AND ( ( iznos > 0 AND fisc_rn > 0 ) "
      cWhere += "  OR ( iznos < 0 AND fisc_st > 0 ) ) "
   ELSE
      cWhere += " AND ( iznos > 0 AND fisc_rn > 0 ) "
   ENDIF

   IF table_count( "fmk.fakt_doks", cWhere ) > 0
      lRet := .T.
   ENDIF
 
   RETURN lRet


STATIC FUNCTION fakt_dok_is_storno( id_firma, tip_dok, br_dok )

   LOCAL _storno := .T.
   LOCAL _t_rec

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP
   SEEK ( id_firma + tip_dok + br_dok )

   IF !Found()
      MsgBeep( "Ne mogu locirati dokument - is storno !" )
      RETURN -1
   ENDIF

   _t_rec := RecNo()

   DO WHILE !Eof() .AND. field->idfirma == id_firma ;
         .AND. field->idtipdok == tip_dok ;
         .AND. field->brdok == br_dok

      IF field->kolicina > 0
         _storno := .F.
         EXIT
      ENDIF

      SKIP

   ENDDO

   GO ( _t_rec )

   RETURN _storno



STATIC FUNCTION fakt_fiscal_o_tables()

   O_TARIFA
   O_FAKT_DOKS
   O_FAKT
   O_ROBA
   O_SIFK
   O_SIFV

   RETURN



// ----------------------------------------------------------
// kalkulise iznose na osnovu datih parametara
// ----------------------------------------------------------
STATIC FUNCTION fakt_izracunaj_total( arr, partner, tip_dok )

   LOCAL _calc := hb_Hash()
   LOCAL _tar, _i, _iznos
   LOCAL _t_area := Select()

   _calc[ "ukupno" ] := 0
   _calc[ "pdv" ] := 0
   _calc[ "osnovica" ] := 0

   FOR _i := 1 TO Len( arr )

      _tar := PadR( arr[ _i, 1 ], 6 )
      _iznos := arr[ _i, 2 ]

      SELECT tarifa
      hseek _tar

      IF tip_dok $ "11#13#23"
         IF !IsIno( partner ) .AND. !IsOslClan( partner ) .AND. tarifa->opp > 0
            _calc[ "ukupno" ] := _calc[ "ukupno" ] + _iznos
            _calc[ "osnovica" ] := _calc[ "osnovica" ] + ( _iznos / ( 1 + tarifa->opp / 100 ) )
            _calc[ "pdv" ] := _calc[ "pdv" ] + ( ( _iznos / ( 1 + tarifa->opp / 100 ) ) * ( tarifa->opp / 100 ) )
         ELSE
            _calc[ "ukupno" ] := _calc[ "ukupno" ] + _iznos
            _calc[ "osnovica" ] := _calc[ "osnovica" ] + _iznos
         ENDIF
      ELSE
         IF !IsIno( partner ) .AND. !IsOslClan( partner ) .AND. tarifa->opp > 0
            _calc[ "ukupno" ] := _calc[ "ukupno" ] + ( _iznos * ( 1 + tarifa->opp / 100 ) )
            _calc[ "osnovica" ] := _calc[ "osnovica" ] + _iznos
            _calc[ "pdv" ] := _calc[ "pdv" ] + ( _iznos * ( tarifa->opp / 100 ) )
         ELSE
            _calc[ "ukupno" ] := _calc[ "ukupno" ] + _iznos
            _calc[ "osnovica" ] := _calc[ "osnovica" ] + _iznos
         ENDIF
      ENDIF

   NEXT

   SELECT ( _t_area )

   RETURN _calc




STATIC FUNCTION get_a_iznos( idfirma, idtipdok, brdok )

   LOCAL _a_iznos := {}
   LOCAL _tar, _roba, _scan

   SELECT fakt
   GO TOP
   SEEK idfirma + idtipdok + brdok
   DO WHILE !Eof() .AND. field->idfirma == idfirma .AND. field->idtipdok == idtipdok .AND. field->brdok == brdok

      _roba := field->idroba
      _cijena := field->cijena
      _kol := field->kolicina
      _rab := field->rabat

      SELECT roba
      hseek _roba

      SELECT tarifa
      hseek roba->idtarifa

      _tar := tarifa->id

      SELECT fakt

      IF field->dindem == Left( ValBazna(), 3 )
         _iznos := Round( _kol * _cijena * PrerCij() * ( 1 - _rab / 100 ), ZAOKRUZENJE )
      ELSE
         _iznos := Round( _kol * _cijena * PrerCij() * ( 1 - _rab / 100 ), ZAOKRUZENJE )
      ENDIF

      IF RobaZastCijena( _tar )
         _tar := PadR( "PDV17", 6 )
      ENDIF

      _scan := AScan( _a_iznos, {|var| VAR[ 1 ] == _tar } )

      IF _scan == 0
         AAdd( _a_iznos, { PadR( _tar, 6 ), _iznos } )
      ELSE
         _a_iznos[ _scan, 2 ] := _a_iznos[ _scan, 2 ] + _iznos
      ENDIF

      SKIP

   ENDDO

   RETURN _a_iznos



STATIC FUNCTION fakt_fiscal_stavke_racuna( id_firma, tip_dok, br_dok, storno, partn_arr )

   LOCAL _data := {}
   LOCAL _n_rn_broj, _rn_iznos, _rn_rabat, _rn_datum, _rekl_rn_broj
   LOCAL _vrsta_pl, _partn_id, _rn_total, _rn_f_total
   LOCAL _art_id, _art_plu, _art_naz, _art_jmj, _v_plac
   LOCAL _art_barkod, _rn_rbr, _memo
   LOCAL _pop_na_teret_prod := .F.
   LOCAL _partn_ino := .F.
   LOCAL _partn_pdv := .T.
   LOCAL _a_iznosi := {}
   LOCAL _data_item, _data_total, _arr

   // 0 - gotovina
   // 3 - ziralno / virman

   _v_plac := "0"

   IF partn_arr <> NIL
      _v_plac := partn_arr[ 1, 6 ]
      _partn_ino := partn_arr[ 1, 7 ]
      _partn_pdv := partn_arr[ 1, 8 ]
   ELSE
      _v_plac := __vrsta_pl
      _partn_ino := __partn_ino
      _partn_pdv := __partn_pdv
   ENDIF

   IF storno == NIL
      storno := .F.
   ENDIF

   fakt_fiscal_o_tables()

   SELECT fakt_doks
   GO TOP
   SEEK ( id_firma + tip_dok + br_dok )

   _n_rn_broj := Val( AllTrim( field->brdok ) )
   _rekl_rn_broj := field->fisc_rn

   _rn_iznos := field->iznos
   _rn_rabat := field->rabat
   _rn_datum := field->datdok
   _partn_id := field->idpartner

   _a_iznosi := get_a_iznos( id_firma, tip_dok, br_dok )
   _data_total := fakt_izracunaj_total( _a_iznosi, _partn_id, tip_dok )

   SELECT fakt
   GO TOP
   SEEK ( id_firma + tip_dok + br_dok )

   IF !Found()
      MsgBeep( "Račun ne posjeduje niti jednu stavku#Štampanje onemogućeno !" )
      RETURN NIL
   ENDIF

   IF storno
      _rekl_rn_broj := reklamni_rn_box( _rekl_rn_broj )
   ENDIF

   IF _rekl_rn_broj == -1
      MsgBeep( "Broj veze računa mora biti setovan" )
      RETURN NIL
   ENDIF

   // i total sracunaj sa pdv
   // upisat cemo ga u svaku stavku matrice
   // to je total koji je bitan kod regularnih racuna
   // pdv, ne pdv obveznici itd...
   // _rn_total := _uk_sa_pdv( tip_dok, _partn_id, _rn_iznos )

   _rn_total := _data_total[ "ukupno" ]
   _rn_f_total := 0

   DO WHILE !Eof() .AND. field->idfirma == id_firma ;
         .AND. field->idtipdok == tip_dok ;
         .AND. field->brdok == br_dok

      SELECT roba
      SEEK fakt->idroba

      SELECT fakt

      _storno_ident := 0

      IF ( field->kolicina < 0 ) .AND. !storno
         _storno_ident := 1
      ENDIF

      _rn_broj := fakt->brdok
      _rn_rbr := fakt->rbr

      _memo := ParsMemo( fakt->txt )

      _art_id := fakt->idroba
      _art_barkod := AllTrim( roba->barkod )

      IF roba->tip == "U" .AND. Empty( AllTrim( roba->naz ) )

         _memo_opis := AllTrim( _memo[ 1 ] )

         IF Empty( _memo_opis )
            _memo_opis := "artikal bez naziva"
         ENDIF

         _art_naz := AllTrim( fiscal_art_naz_fix( _memo_opis, __device_params[ "drv" ] ) )
      ELSE
         _art_naz := AllTrim( fiscal_art_naz_fix( roba->naz, __device_params[ "drv" ] ) )
      ENDIF

      _art_jmj := AllTrim( roba->jmj )
      _art_plu := roba->fisc_plu

      IF __device_params[ "plu_type" ] == "D" .AND. ;
            ( __device_params[ "vp_sum" ] <> 1 .OR. tip_dok $ "11" .OR. Len( _a_iznosi ) > 1 )

         _art_plu := auto_plu( nil, nil,  __device_params )

         IF __DRV_CURRENT == "FPRINT" .AND. _art_plu == 0
            MsgBeep( "PLU artikla = 0, to nije moguce !" )
            RETURN NIL
         ENDIF

      ENDIF

      _cijena := roba->mpc

      _tarifa_id := AllTrim( roba->idtarifa )

      _arr := {}
      AAdd( _arr, { _tarifa_id, field->cijena } )
      _data_item := fakt_izracunaj_total( _arr, _partn_id, tip_dok )

      _cijena := _data_item[ "ukupno" ]

      IF tip_dok == "10"
         _vr_plac := "3"
      ENDIF

      _kolicina := Abs( field->kolicina )

      IF !_partn_ino .AND. !_partn_pdv .AND. RobaZastCijena( roba->idtarifa )
         _pop_na_teret_prod := .T.
         _rn_rabat := 0
      ELSE
         _rn_rabat := Abs ( field->rabat )
      ENDIF

      IF _partn_ino == .T.
         _tarifa_id := "PDV0"
      ENDIF

      _storno_rn_opis := ""

      IF _rekl_rn_broj > 0
         _storno_rn_opis := AllTrim( Str( _rekl_rn_broj ) )
      ENDIF

      IF field->dindem == Left( ValBazna(), 3 )
         _rn_f_total += Round( _kolicina * _cijena * PrerCij() * ( 1 - _rn_rabat / 100 ), ZAOKRUZENJE )
      ELSE
         _rn_f_total += Round( _kolicina * _cijena * PrerCij() * ( 1 - _rn_rabat / 100 ), ZAOKRUZENJE )
      ENDIF

      // 1 - broj racuna
      // 2 - redni broj
      // 3 - id roba
      // 4 - roba naziv
      // 5 - cijena
      // 6 - kolicina
      // 7 - tarifa
      // 8 - broj racuna za storniranje
      // 9 - roba plu
      // 10 - plu cijena
      // 11 - popust
      // 12 - barkod
      // 13 - vrsta placanja
      // 14 - total racuna
      // 15 - datum racuna
      // 16 - roba jmj

      AAdd( _data, { _rn_broj, ;
         _rn_rbr, ;
         _art_id, ;
         _art_naz, ;
         _cijena, ;
         _kolicina, ;
         _tarifa_id, ;
         _storno_rn_opis, ;
         _art_plu, ;
         _cijena, ;
         _rn_rabat, ;
         _art_barkod, ;
         _v_plac, ;
         _rn_total, ;
         _rn_datum, ;
         _art_jmj } )

      SKIP

   ENDDO

   IF _pop_na_teret_prod .OR. _partn_ino
      FOR _n := 1 TO Len( _data )
         _data[ _n, 14 ] := _rn_f_total
      NEXT
   ENDIF

   IF tip_dok $ "10" .AND. Len( _a_iznosi ) < 2
      set_fiscal_rn_zbirni( @_data )
   ENDIF

   _item_level_check := 2

   IF provjeri_kolicine_i_cijene_fiskalnog_racuna( @_data, storno, _item_level_check, __device_params[ "drv" ] ) < 0
      RETURN NIL
   ENDIF

   RETURN _data



/*
   Opis: da li je račun bezgotovinski u zavisnosti od tipa dokumenta i vrste plaćanja
*/
STATIC FUNCTION racun_bezgotovinski( tip_dok, vrsta_placanja )

   IF tip_dok == "10" .AND. vrsta_placanja <> "G "
      RETURN .T.
   ENDIF

   IF tip_dok == "11" .AND. vrsta_placanja == "VR"
      RETURN .T.
   ENDIF

   RETURN .F.





/*
   Opis: vraća "kod" vrste plaćanja za fiskalni uređaj u zavisnosti od vrste dokumenta i vrste plaćanja

   Return:
     - "0" - gotovina
     - "1" - kartica
     - "3" - virman
*/
STATIC FUNCTION vrsta_placanja_za_fiskalni_uredjaj( tip_dok, vrsta_placanja )

   LOCAL cVrPlac := "0"

   IF ( tip_dok $ "#10#" .AND. !vrsta_placanja == "G " ) .OR. ( tip_dok == "11" .AND. vrsta_placanja == "VR" )
      cVrPlac := "3"
   ELSEIF ( tip_dok == "10" .AND. vrsta_placanja == "G " )
      cVrPlac := "0"
   ENDIF

   IF tip_dok $ "#11#" .AND. vrsta_placanja == "KT"
      cVrPlac := "1"
   ENDIF

   RETURN cVrPlac


/*
   Opis: da li se vrsta dokumenta može poslati na fiskalni uređaj
*/ 
STATIC FUNCTION dokument_se_moze_fiskalizovati( tip_dok )

   IF tip_dok $ "10#11"
       RETURN .T.
   ENDIF

   RETURN .F.



/*
   Opis: da li su podaci partnera za ispis na fiskalni račun kompletni
         naziv, adresa, ptt, telefon
*/
STATIC FUNCTION is_podaci_partnera_kompletirani( sifra, id_broj )

   LOCAL lRet := .T.

   SELECT partn
   GO TOP
   SEEK sifra

   IF !Found()
      lRet := .F.
      RETURN lRet
   ENDIF

   IF Empty( id_broj )
      lRet := .F.
   ENDIF

   IF lRet .AND. Empty( partn->naz )
      lRet := .F.
   ENDIF

   IF lRet .AND. Empty( partn->adresa )
      lRet := .F.
   ENDIF

   IF lRet .AND. Empty( partn->ptt )
      lRet := .F.
   ENDIF

   IF lRet .AND. Empty( partn->mjesto )
      lRet := .F.
   ENDIF

   RETURN lRet


STATIC FUNCTION racun_bezgotovinski_bez_partnera_pitanje()
 
   IF Pitanje(, "Račun je bezgotovinski, podaci partnera nisu kompletirani. Želite nastaviti (D/N) ?", "N" ) == "D"
      IF Pitanje(, "Sigurno želite štampati fiskalni račun bez podataka kupca (D/N) ?", "N" ) == "D"
         RETURN .T.
      ENDIF
   ENDIF

   RETURN .F.



/*
   Opis: vraća matricu napunjenu sa podacima partnera kao i informacije o vrsti plaćanja, da li partner pdv obveznik
         na osnovu ažuriranog fakt dokumenta

   Usage: fakt_fiscal_podaci_partnera( id_firma, tip_dok, br_dok, storno, lRacunBezPartnera )

   Parametri:
      - id_firma - fakt_doks->idfirma 
      - tip_dok - fakt_doks->idtipdok
      - br_dok - fakt_doks->brdok
      - storno - .T. račun je storno
      - lRacunBezPartnera - .T. bezgotovinski račun je moguć bez partnera

   Return:
      - .F. - podaci partnera nisu kompletirani ili ispravni, ima ID broj, PDV broj, ali fali adresa
      - NIL - podaci partnera ne treba da se uzimaju kod štampe fiskalnog računa
      - {} - podaci partnera { identifikacioni broj, naziv, adresa, telefon, ... }

   Primjer:

      partn_arr := fakt_fiscal_podaci_partnera( "10", "10", "00001", .F., .F. )

      IF partn_arr == .F.
            => partner ima podešene idbroj, pdv broj ali podaci partnera nisu kompletni, fiskalni račun nije moguće napraviti
      IF partn_arr == NIL
            => na fiskalnom račun partner i njegovi podaci će biti ignorisani

*/

STATIC FUNCTION fakt_fiscal_podaci_partnera( id_firma, tip_dok, br_dok, storno, lBezgRacunBezPartnera )

   LOCAL _podaci := {}
   LOCAL _partn_id
   LOCAL _vrsta_p
   LOCAL _v_plac := "0"
   LOCAL _partn_id_broj
   LOCAL lPartnClan
   LOCAL _podaci_kompletirani

   IF lBezgRacunBezPartnera == NIL
      lBezgRacunBezPartnera := .F.
   ENDIF

   __prikazi_partnera := .T.
   __partn_ino := .F.
   __partn_pdv := .T.

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP
   SEEK ( id_firma + tip_dok + br_dok )

   _partn_id := field->idpartner
   _vrsta_p := field->idvrstep

   IF EMPTY( _partn_id )
      MsgBeep( "Šifra partnera ne postoji, izdavanje računa nije moguće !" )
      RETURN .F.
   ENDIF

   _partn_id_broj := AllTrim( firma_id_broj( _partn_id ) )
   __vrsta_pl := vrsta_placanja_za_fiskalni_uredjaj( tip_dok, _vrsta_p )
   lPartnClan := IsOslClan( _partn_id )

   IF IsIno( _partn_id )
      __partn_ino := .T.
      __partn_pdv := .F.
      RETURN NIL
   ENDIF

   IF !is_idbroj_13cifara( _partn_id_broj )
      __prikazi_partnera := .F.
   ENDIF

   _podaci_kompletirani := is_podaci_partnera_kompletirani( _partn_id, _partn_id_broj )

   IF racun_bezgotovinski( tip_dok, _vrsta_p ) .AND. ( !__prikazi_partnera .OR. !_podaci_kompletirani )
      IF lBezgRacunBezPartnera .AND. racun_bezgotovinski_bez_partnera_pitanje()
         __prikazi_partnera := .F.
      ELSE
         MsgBeep( "Podaci partnera nisu kompletirani#Operacija štampe zaustavljena !" )
         RETURN .F.
      ENDIF
   ENDIF

   IF __prikazi_partnera .AND. !_podaci_kompletirani
      __prikazi_partnera := .F.
   ENDIF

   IF lPartnClan
      __partn_ino := .T.
      __partn_pdv := .F.
   ELSEIF IsPdvObveznik( _partn_id )
      __partn_ino := .F.
      __partn_pdv := .T.
   ELSE
      __partn_ino := .F.
      __partn_pdv := .F.
   ENDIF

   IF !__prikazi_partnera
      RETURN NIL
   ENDIF

   AAdd( _podaci, { _partn_id_broj, partn->naz, partn->adresa, ;
      partn->ptt, partn->mjesto, __vrsta_pl, __partn_ino, __partn_pdv } )

   RETURN _podaci



// -------------------------------------------------------------
// obradi izlaz fiskalnog racuna na FPRINT uredjaj
// -------------------------------------------------------------
STATIC FUNCTION fakt_to_fprint( id_firma, tip_dok, br_dok, items, head, storno )

   LOCAL _path := __device_params[ "out_dir" ]
   LOCAL _filename := __device_params[ "out_file" ]
   LOCAL _fiscal_no := 0
   LOCAL _total := items[ 1, 14 ]
   LOCAL _partn_naz

   fprint_delete_answer( __device_params )

   fprint_rn( __device_params, items, head, storno )

   _err_level := fprint_read_error( __device_params, @_fiscal_no, storno )

   IF _err_level = -9
      IF Pitanje(, "Da li je nestalo trake (D/N) ?", "N" ) == "D"
         IF Pitanje(, "Ubacite traku i pritisnite 'D'", " " ) == "D"
            _err_level := fprint_read_error( __device_params, @_fiscal_no, storno )
         ENDIF
      ENDIF
   ENDIF

   IF _err_level = 2 .AND. storno
      notify_podrska( "Greška sa izdavanjem reklamiranog računa !" ) 
      IF obrada_greske_na_liniji_55_reklamirani_racun( id_firma, tip_dok, br_dok, __device_params )
         MsgBeep( "Sada možete ponoviti izdavanje reklamiranog računa na fiskalni uređaj." )
         RETURN 0        
      ENDIF
   ENDIF

   IF _fiscal_no <= 0
      _err_level := 1
   ENDIF

   IF _err_level <> 0
      notify_podrska( "Greška sa izdavanjem fiskalnog računa !" )
      obradi_gresku_izdavanja_fiskalnog_racuna( __device_params, _err_level )
      RETURN _err_level
   ENDIF

   IF !Empty( param_racun_na_email() ) .AND. tip_dok $ "#11#"
      _partn_naz := _get_partner_for_email( id_firma, tip_dok, br_dok )
      _snd_eml( _fiscal_no, tip_dok + "-" + AllTrim( br_dok ), _partn_naz, nil, _total )
   ENDIF

   set_fiscal_no_to_fakt_doks( id_firma, tip_dok, br_dok, _fiscal_no, storno )

   IF __auto = .F.
      MsgBeep( "Kreiran fiskalni racun broj: " + AllTrim( Str( _fiscal_no ) ) )
   ENDIF

   RETURN _err_level




STATIC FUNCTION obradi_gresku_izdavanja_fiskalnog_racuna( device_params, error_level )

   LOCAL cPath := device_params[ "out_dir" ]
   LOCAL cFilename := device_params[ "out_file" ]
   LOCAL cMsg 

   fprint_delete_out( cPath + cFilename )

   cMsg := "ERR FISC: stampa racuna err:" + AllTrim( Str( error_level ) ) + ;
         "##" + cPath + cFilename

   log_write( cMsg, 2 )

   MsgBeep( cMsg )

   RETURN 



/*
   Opis: obrada kod greške na liniji 55
*/
STATIC FUNCTION obrada_greske_na_liniji_55_reklamirani_racun( idfirma, idtipdok, brdok, device_params )

   LOCAL lRet := .T. 
   LOCAL nErr
   LOCAL lForsirano := .T.

   MsgBeep( "Greška se desila kod izdavanja reklamiranog računa.#Mogući uzrok je nedostatak depozita u uređaju." )

   IF Pitanje(, "Želite li otkloniti uzrok dodavanjem depozita (D/N) ?", " " ) == "N"
       RETURN lRet
   ENDIF

   fprint_delete_answer( device_params )

   fprint_komanda_301_zatvori_racun( device_params )

   nErr := fprint_read_error( device_params, 0 )

   IF nErr <> 0
      lRet := .F.
      MsgBeep( "Neuspješan pokušaj poništavanja računa. Pozovite servis bring.out !" )
      RETURN lRet
   ENDIF

   IF !fakt_reklamirani_racun_preduslovi( idfirma, idtipdok, brdok, device_params, lForsirano )
      lRet := .F.
      RETURN lRet
   ENDIF

   RETURN lRet



// -----------------------------------------------------------------------
// vrati partnera za email
// -----------------------------------------------------------------------
STATIC FUNCTION _get_partner_for_email( id_firma, tip_dok, br_dok )

   LOCAL _ret := ""
   LOCAL _t_area := Select()
   LOCAL _partn

   SELECT fakt_doks
   GO TOP
   SEEK id_firma + tip_dok + br_dok

   _partn := field->idpartner
   _id_vrste_p := field->idvrstep

   SELECT partn
   hseek _partn

   IF Found()
      _ret := AllTrim( field->naz )
   ENDIF

   IF !Empty( _id_vrste_p )
      _ret += ", v.pl: " + _id_vrste_p
   ENDIF

   SELECT ( _t_area )

   RETURN _ret



// -------------------------------------------------------------
// izdavanje fiskalnog isjecka na TREMOL uredjaj
// -------------------------------------------------------------
STATIC FUNCTION fakt_to_tremol( id_firma, tip_dok, br_dok, items, head, storno, cont )

   LOCAL _err_level := 0
   LOCAL _f_name
   LOCAL _fiscal_no := 0

   // identifikator CONTINUE
   // nesto imamo mogucnost ako racun zapne da kazemo drugi identifikator
   // pa on navodno nastavi
   IF cont == NIL
      cont := "0"
   ENDIF

   // stampaj racun !
   _err_level := tremol_rn( __device_params, items, head, storno, cont )

   _f_name := AllTrim( fiscal_out_filename( __device_params[ "out_file" ], br_dok ) )

   // da li postoji ista na izlazu ?
   IF tremol_read_out( __device_params, _f_name, __device_params[ "timeout" ] )
      // procitaj sada gresku
      _err_level := tremol_read_error( __device_params, _f_name, @_fiscal_no )

   ELSE
      _err_level := -99
   ENDIF

   IF _err_level = 0 .AND. !storno .AND. cont <> "2"
      // vrati broj fiskalnog racuna
      IF _fiscal_no > 0
         // prikazi poruku samo u direktnoj stampi
         IF __auto = .F.
            msgbeep( "Kreiran fiskalni racun broj: " + AllTrim( Str( _fiscal_no ) ) )
         ENDIF

         // ubaci broj fiskalnog racuna u fakturu
         set_fiscal_no_to_fakt_doks( id_firma, tip_dok, br_dok, _fiscal_no )

      ENDIF

      FErase( __device_params[ "out_dir" ] + _f_name )

   ENDIF

   RETURN _err_level




// -------------------------------------------------------------
// izdavanje fiskalnog isjecka na HCP uredjaj
// -------------------------------------------------------------
STATIC FUNCTION fakt_to_hcp( id_firma, tip_dok, br_dok, items, head, storno )

   LOCAL _err_level := 0
   LOCAL _fiscal_no := 0

   _err_level := hcp_rn( __device_params, items, head, storno, items[ 1, 14 ] )

   IF _err_level = 0

      _fiscal_no := hcp_fisc_no( __device_params, storno )

      IF _fiscal_no > 0

         // ubaci broj fiskalnog racuna u fakturu
         set_fiscal_no_to_fakt_doks( id_firma, tip_dok, br_dok, _fiscal_no, storno )

      ENDIF

   ENDIF

   RETURN _err_level



// --------------------------------------------------
// napravi zbirni racun ako je potrebno
// --------------------------------------------------
STATIC FUNCTION set_fiscal_rn_zbirni( data )

   LOCAL _tmp := {}
   LOCAL _total := 0
   LOCAL _kolicina := 1
   LOCAL _art_naz := ""
   LOCAL _len := Len( data )

   IF __device_params[ "vp_sum" ] < 1 .OR. ;
         __device_params[ "plu_type" ] == "P" .OR. ;
         ( __device_params[ "vp_sum" ] > 1 .AND. __device_params[ "vp_sum" ] < _len )
      // ova opcija se ne koristi
      // ako je iskljucena opcija
      // ili ako je sifra artikla genericki PLU
      // ili ako je zadato da ide iznad neke vrijednosti stavki na racunu
      RETURN
   ENDIF

   _art_naz := "St.rn."

   IF __DRV_CURRENT  $ "#FPRINT#HCP#TRING#"
      _art_naz += " " + AllTrim( DATA[ 1, 1 ] )
   ENDIF

   // ukupna vrijednost racuna za sve stavke matrice je ista popunjena
   _total := ROUND2( DATA[ 1, 14 ], 2 )

   IF !Empty( DATA[ 1, 8 ] )
      // ako je storno racun
      // napravi korekciju da je iznos pozitivan
      _total := Abs( _total )
   ENDIF

   // dodaj u _tmp zbirnu stavku...
   AAdd( _tmp, { DATA[ 1, 1 ], ;
      DATA[ 1, 2 ], ;
      "", ;
      _art_naz, ;
      _total, ;
      _kolicina, ;
      DATA[ 1, 7 ], ;
      DATA[ 1, 8 ], ;
      auto_plu( nil, nil, __device_params ), ;
      _total, ;
      0, ;
      "", ;
      DATA[ 1, 13 ], ;
      _total, ;
      DATA[ 1, 15 ], ;
      DATA[ 1, 16 ] } )


   data := _tmp

   RETURN



// -------------------------------------------------------------------
// setovanje broja fiskalnog racuna u dokumentu
// -------------------------------------------------------------------
STATIC FUNCTION set_fiscal_no_to_fakt_doks( cFirma, cTD, cBroj, nFiscal, lStorno )

   LOCAL nTArea := Select()
   LOCAL _rec

   IF lStorno == nil
      lStorno := .F.
   ENDIF

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   SEEK cFirma + cTD + cBroj

   _rec := dbf_get_rec()

   // privremeno, dok ne uvedem polje ovo iskljucujem
   IF lStorno == .T.
      _rec[ "fisc_st" ] := nFiscal
   ELSE
      _rec[ "fisc_rn" ] := nFiscal
   ENDIF

   // datum i vrijeme...
   _rec[ "fisc_date" ] := Date()
   _rec[ "fisc_time" ] := PadR( Time(), 10 )

   IF !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "FULL" )
      MsgBeep( "Problem setovanja veze fiskalnog računa#Operacija prekinuta." )
   ENDIF

   SELECT ( nTArea )

   RETURN



// -------------------------------------------------------------
// izdavanje fiskalnog isjecka na TFP uredjaj - tring
// -------------------------------------------------------------
STATIC FUNCTION fakt_to_tring( id_firma, tip_dok, br_dok, items, head, storno )

   LOCAL _err_level := 0
   LOCAL _trig := 1
   LOCAL _fiscal_no := 0

   IF storno
      _trig := 2
   ENDIF

   // brisi ulazne fajlove, ako postoje
   tring_delete_out( __device_params, _trig )

   // ispisi racun
   tring_rn( __device_params, items, head, storno )

   // procitaj gresku
   _err_level := tring_read_error( __device_params, @_fiscal_no, _trig )

   IF _fiscal_no <= 0
      _err_level := 1
   ENDIF

   // pobrisi izlazni fajl
   tring_delete_out( __device_params, _trig )

   IF _err_level <> 0
      // ostavit cu answer fajl za svaki slucaj!
      // pobrisi izlazni fajl ako je ostao !
      msgbeep( "Postoji greska sa stampanjem !!!" )
   ELSE
      tring_delete_answer( __device_params, _trig )
      // ubaci broj fiskalnog racuna u fakturu
      set_fiscal_no_to_fakt_doks( id_firma, tip_dok, br_dok, _fiscal_no )
      msgbeep( "Kreiran fiskalni racun broj: " + AllTrim( Str( _fiscal_no ) ) )
   ENDIF

   RETURN _err_level



// ------------------------------------------------------
// posalji racun na fiskalni stampac
// ------------------------------------------------------
STATIC FUNCTION fakt_to_flink( cFirma, cTipDok, cBrDok )

   LOCAL aItems := {}
   LOCAL aTxt := {}
   LOCAL aPla_data := {}
   LOCAL aSem_data := {}
   LOCAL lStorno := .T.
   LOCAL aMemo := {}
   LOCAL nBrDok
   LOCAL nReklRn := 0
   LOCAL cStPatt := "/S"
   LOCAL GetList := {}

   SELECT fakt_doks
   SEEK cFirma + cTipDok + cBrDok

   // ako je storno racun ...
   IF cStPatt $ AllTrim( field->brdok )
      nReklRn := Val( StrTran( AllTrim( field->brdok ), cStPatt, "" ) )
   ENDIF

   nBrDok := Val( AllTrim( field->brdok ) )
   nTotal := field->iznos
   nNRekRn := 0

   IF nReklRn <> 0
      Box( , 1, 60 )
      @ m_x + 1, m_y + 2 SAY "Broj rekl.fiskalnog racuna:" ;
         GET nNRekRn PICT "99999" VALID ( nNRekRn > 0 )
      READ
      BoxC()
   ENDIF

   SELECT fakt
   SEEK cFirma + cTipDok + cBrDok

   nTRec := RecNo()

   // da li se radi o storno racunu ?
   DO WHILE !Eof() .AND. field->idfirma == cFirma ;
         .AND. field->idtipdok == cTipDok ;
         .AND. field->brdok == cBrDok

      IF field->kolicina > 0
         lStorno := .F.
         EXIT
      ENDIF

      SKIP

   ENDDO

   // nTipRac = 1 - maloprodaja
   // nTipRac = 2 - veleprodaja

   // nSemCmd = semafor komanda
   // 0 - stampa mp racuna
   // 1 - stampa storno mp racuna
   // 20 - stampa vp racuna
   // 21 - stampa storno vp racuna

   nSemCmd := 0
   nPartnId := 0

   IF cTipDok $ "10#"

      // veleprodajni racun

      nTipRac := 2

      // daj mi partnera za ovu fakturu
      nPartnId := _g_spart( fakt_doks->idpartner )

      // stampa vp racuna
      nSemCmd := 20

      IF lStorno == .T.
         // stampa storno vp racuna
         nSemCmd := 21
      ENDIF

   ELSEIF cTipDok $ "11#"

      // maloprodajni racun

      nTipRac := 1

      // nema parnera
      nPartnId := 0

      // stampa mp racuna
      nSemCmd := 0

      IF lStorno == .T.
         // stampa storno mp racuna
         nSemCmd := 1
      ENDIF

   ENDIF

   // vrati se opet na pocetak
   GO ( nTRec )

   // upisi u [items] stavke
   DO WHILE !Eof() .AND. field->idfirma == cFirma ;
         .AND. field->idtipdok == cTipDok ;
         .AND. field->brdok == cBrDok

      // nastimaj se na robu ...
      SELECT roba
      SEEK fakt->idroba

      SELECT fakt

      // storno identifikator
      nSt_Id := 0

      IF ( field->kolicina < 0 ) .AND. lStorno == .F.
         nSt_id := 1
      ENDIF

      nSifRoba := _g_sdob( field->idroba )
      cNazRoba := AllTrim( to_xml_encoding( roba->naz ) )
      cBarKod := AllTrim( roba->barkod )
      nGrRoba := 1
      nPorStopa := 1
      nR_cijena := Abs( field->cijena )
      nR_kolicina := Abs( field->kolicina )

      AAdd( aItems, { nBrDok, ;
         nTipRac, ;
         nSt_id, ;
         nSifRoba, ;
         cNazRoba, ;
         cBarKod, ;
         nGrRoba, ;
         nPorStopa, ;
         nR_cijena, ;
         nR_kolicina } )

      SKIP
   ENDDO

   // tip placanja
   // --------------------
   // 0 - gotovina
   // 1 - cek
   // 2 - kartica
   // 3 - virman

   nTipPla := 0

   IF lStorno == .F.
      // povrat novca
      nPovrat := 0
      // uplaceno novca
      nUplaceno := nTotal
   ELSE
      // povrat novca
      nPovrat := nTotal
      // uplaceno novca
      nUplaceno := 0
   ENDIF

   // upisi u [pla_data] stavke
   AAdd( aPla_data, { nBrDok, ;
      nTipRac, ;
      nTipPla, ;
      Abs( nUplaceno ), ;
      Abs( nTotal ), ;
      Abs( nPovrat ) } )

   // RACUN.MEM data
   AAdd( aTxt, { "fakt: " + cTipDok + "-" + cBrDok } )

   // reklamni racun uzmi sa box-a
   nReklRn := nNRekRn
   // print memo od - do
   nPrMemoOd := 1
   nPrMemoDo := 1

   // upisi stavke za [semafor]
   AAdd( aSem_data, { nBrDok, ;
      nSemCmd, ;
      nPrMemoOd, ;
      nPrMemoDo, ;
      nPartnId, ;
      nReklRn } )


   IF nTipRac = 2

      // veleprodaja
      // posalji na fiskalni stampac...

      fisc_v_rn( gFC_path, aItems, aTxt, aPla_data, aSem_data )

   ELSEIF nTipRac = 1

      // maloprodaja
      // posalji na fiskalni stampac

      fisc_m_rn( gFC_path, aItems, aTxt, aPla_data, aSem_data )

   ENDIF

   RETURN


// --------------------------------------------------------
// vraca broj fiskalnog isjecka
// --------------------------------------------------------
FUNCTION fisc_isjecak( cFirma, cTipDok, cBrDok )

   LOCAL nTArea   := Select()
   LOCAL nFisc_no := 0

   SELECT fakt_doks
   GO TOP
   SEEK cFirma + cTipDok + cBrDok

   IF  Found()
      // ako postoji broj reklamnog racuna, onda uzmi taj
      IF field->fisc_st <> 0
         nFisc_no := field->fisc_st
      ELSE
         nFisc_no := field->fisc_rn
      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN AllTrim( Str( nFisc_no ) )


// ------------------------------------------------------
// posalji email
// ------------------------------------------------------
STATIC FUNCTION _snd_eml( fisc_rn, fakt_dok, kupac, eml_file, u_total )

   LOCAL _subject, _body
   LOCAL _mail_param
   LOCAL _to := AllTrim( param_racun_na_email() )

   _subject := "Racun: "
   _subject += AllTrim( Str( fisc_rn ) )
   _subject += ", " + fakt_dok
   _subject += ", " + to_xml_encoding( kupac )
   _subject += ", iznos: " + AllTrim( Str( u_total, 12, 2 ) )
   _subject += " KM"

   _body := "podaci kupca i racuna"

   _mail_param := f18_email_prepare( _subject, _body, nil, _to )

   f18_email_send( _mail_param, nil )

   RETURN NIL


// ------------------------------------------------
// vraca sifru dobavljaca
// ------------------------------------------------
STATIC FUNCTION _g_sdob( id_roba )

   LOCAL _ret := 0
   LOCAL _t_area := Select()

   SELECT roba
   SEEK id_roba

   IF Found()
      _ret := Val( AllTrim( field->sifradob ) )
   ENDIF

   SELECT ( _t_area )

   RETURN _ret


// ------------------------------------------------
// vraca sifru partnera
// ------------------------------------------------
STATIC FUNCTION _g_spart( id_partner )

   LOCAL _ret := 0
   LOCAL _tmp

   _tmp := Right( AllTrim( id_partner ), 5 )
   _ret := Val( _tmp )

   RETURN _ret
