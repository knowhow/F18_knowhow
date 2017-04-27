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

MEMVAR GetList

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




FUNCTION fakt_fiskalni_racun( cIdFirma, cIdTipDok, cBrDok, lAutoPrint, hDeviceParams )

   LOCAL _err_level := 0
   LOCAL _dev_drv
   LOCAL _storno := .F.
   LOCAL aRacunStavkeData, _partn_data
   LOCAL _cont := "1"
   LOCAL lRacunBezgBezPartnera

   IF !fiscal_opt_active()
      RETURN _err_level
   ENDIF

   IF ( lAutoPrint == NIL )
      lAutoPrint := .F.
   ENDIF

   IF lAutoPrint
      __auto := .T.
   ENDIF

   IF hDeviceParams == NIL
      RETURN _err_level
   ENDIF

   __device_params := hDeviceParams

   _dev_drv := AllTrim( hDeviceParams[ "drv" ] )

   lRacunBezgBezPartnera := ( hDeviceParams[ "vp_no_customer" ] == "D" )

   __DRV_CURRENT := _dev_drv

   SELECT fakt_doks
   SET FILTER TO

   SELECT fakt
   SET FILTER TO

   // SELECT partn
   // SET FILTER TO

   SELECT fakt_doks

   IF postoji_fiskalni_racun( cIdFirma, cIdTipDok, cBrDok, _dev_drv )
      MsgBeep( "Za dokument " + cIdTipDok + "-" + AllTrim( cBrDok ) + " već postoji izdat fiskalni račun !" )
      RETURN _err_level
   ENDIF

   _storno := fakt_dok_is_storno( cIdFirma, cIdTipDok, cBrDok )

   IF ValType( _storno ) == "N" .AND. _storno == -1
      RETURN _err_level
   ENDIF

   IF _storno
      IF !fakt_reklamirani_racun_preduslovi( cIdFirma, cIdTipDok, cBrDok, hDeviceParams )
         RETURN _err_level
      ENDIF
   ENDIF

   _partn_data := fakt_fiscal_podaci_partnera( cIdFirma, cIdTipDok, cBrDok, _storno, lRacunBezgBezPartnera )

   IF ValType( _partn_data ) == "L"
      RETURN 1
   ENDIF

   aRacunStavkeData := fakt_fiscal_stavke_racuna( cIdFirma, cIdTipDok, cBrDok, _storno, _partn_data )

   IF ValType( aRacunStavkeData ) == "L"  .OR. aRacunStavkeData == NIL
      RETURN 1
   ENDIF

   DO CASE

   CASE _dev_drv == "TEST"
      _err_level := 0

   CASE _dev_drv == __DRV_FPRINT
      _err_level := fakt_to_fprint( cIdFirma, cIdTipDok, cBrDok, aRacunStavkeData, _partn_data, _storno )

   CASE _dev_drv == __DRV_TREMOL
      _cont := "1"
      _err_level := fakt_to_tremol( cIdFirma, cIdTipDok, cBrDok, aRacunStavkeData, _partn_data, _storno, _cont )

   CASE _dev_drv == __DRV_HCP
      _err_level := fakt_to_hcp( cIdFirma, cIdTipDok, cBrDok, aRacunStavkeData, _partn_data, _storno )

   CASE _dev_drv == __DRV_FLINK
      _err_level := fakt_to_flink( __device_params, cIdFirma, cIdTipDok, cBrDok, aRacunStavkeData, _partn_data, _storno )


   CASE _dev_drv == __DRV_TRING
      _err_level := fakt_to_tring( cIdFirma, cIdTipDok, cBrDok, aRacunStavkeData, _partn_data, _storno )

   ENDCASE

   DirChange( my_home() )

   log_write( "fiskalni racun " + _dev_drv + " za dokument: " + ;
      AllTrim( cIdFirma ) + "-" + AllTrim( cIdTipDok ) + "-" + AllTrim( cBrDok ) + ;
      " err level: " + AllTrim( Str( _err_level ) ) + ;
      " partner: " + iif( _partn_data <> NIL, AllTrim( _partn_data[ 1, 1 ] ) + ;
      " - " + AllTrim( _partn_data[ 1, 2 ] ), "NIL" ), 3 )

   IF _err_level > 0

      IF _dev_drv == __DRV_TREMOL

         _cont := "2"
         _err_level := fakt_to_tremol( cIdFirma, cIdTipDok, cBrDok, aRacunStavkeData, _partn_data, _storno, _cont )

         IF _err_level > 0
            MsgBeep( "Problem sa štampanjem na fiskalni uređaj !" )
         ENDIF

      ENDIF

   ENDIF

   RETURN _err_level



FUNCTION reklamni_rn_box( nBrReklamiraniRacun )

   Box(, 1, 60 )
   @ m_x + 1, m_y + 2 SAY8 "Reklamiramo fiskalni račun broj:" ;
      GET nBrReklamiraniRacun PICT "999999999" VALID ( nBrReklamiraniRacun > 0 )
   READ
   BoxC()

   IF LastKey() == K_ESC .AND. nBrReklamiraniRacun == 0
      nBrReklamiraniRacun := -1
   ENDIF

   RETURN nBrReklamiraniRacun




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

   select_o_roba()

   SELECT ( F_TARIFA )
   IF !Used()
      o_tarifa()
   ENDIF

   cIdPartner := idpartner_sa_fakt_dokumenta( idfirma, idtipdok, brdok )
   aIznosi := get_a_iznos( idfirma, idtipdok, brdok )
   _data_total := fakt_izracunaj_total( aIznosi, cIdPartner, idtipdok )

   nUkupno := _data_total[ "ukupno" ]

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
      MsgBeep( "Želite izdati reklamirani račun.#Prije toga je neophodno da postoji minimalan depozit u uređaju." )
   ENDIF

   IF !lForsirano .AND. Pitanje(, "Da li je potrebno napraviti unos depozita (D/N) ?", " " ) == "N"
      RETURN lRet
   ENDIF

   nDepozit := Abs( fakt_izracunaj_ukupnu_vrijednost_racuna( idfirma, idtipdok, brdok ) )

   nDepozit := Round( nDepozit + 1, 0 )

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

FUNCTION postoji_fiskalni_racun( cIdFirma, cIdTipDok, cBrDok, model )

   LOCAL lRet := .F.
   LOCAL cWhere

   IF model == NIL
      model := fiskalni_uredjaj_model()
   ENDIF

   cWhere := " idfirma = " + sql_quote( cIdFirma )
   cWhere += " AND idtipdok = " + sql_quote( cIdTipDok )
   cWhere += " AND brdok = " + sql_quote( cBrDok )

   IF AllTrim( model ) $ "FPRINT#HCP"
      cWhere += " AND ( ( iznos > 0 AND fisc_rn > 0 ) "
      cWhere += "  OR ( iznos < 0 AND fisc_st > 0 ) ) "
   ELSE
      cWhere += " AND ( iznos > 0 AND fisc_rn > 0 ) "
   ENDIF

   IF table_count( F18_PSQL_SCHEMA_DOT + "fakt_doks", cWhere ) > 0
      lRet := .T.
   ENDIF

   RETURN lRet


STATIC FUNCTION fakt_dok_is_storno( cIdFirma, cIdTipDok, cBrDok )

   LOCAL _storno := .T.
   LOCAL _t_rec

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP
   SEEK ( cIdFirma + cIdTipDok + cBrDok )

   IF !Found()
      MsgBeep( "Ne mogu locirati dokument - is storno !" )
      RETURN -1
   ENDIF

   _t_rec := RecNo()

   DO WHILE !Eof() .AND. field->idfirma == cIdFirma ;
         .AND. field->idtipdok == cIdTipDok ;
         .AND. field->brdok == cBrDok

      IF field->kolicina > 0
         _storno := .F.
         EXIT
      ENDIF

      SKIP

   ENDDO

   GO ( _t_rec )

   RETURN _storno



STATIC FUNCTION fakt_fiscal_o_tables()

   o_tarifa()
   o_fakt_doks()
   o_fakt()
   o_roba()
   o_sifk()
   o_sifv()

   RETURN



// ----------------------------------------------------------
// kalkulise iznose na osnovu datih parametara
// ----------------------------------------------------------
STATIC FUNCTION fakt_izracunaj_total( arr, partner, cIdTipDok )

   LOCAL _calc := hb_Hash()
   LOCAL _tar, nI, _iznos
   LOCAL nDbfArea := Select()

   _calc[ "ukupno" ] := 0
   _calc[ "pdv" ] := 0
   _calc[ "osnovica" ] := 0

   FOR nI := 1 TO Len( arr )

      _tar := PadR( arr[ nI, 1 ], 6 )
      _iznos := arr[ nI, 2 ]

      SELECT tarifa
      HSEEK _tar

      IF cIdTipDok $ "11#13#23"
         IF !IsIno( partner ) .AND. !is_part_pdv_oslob_po_clanu( partner ) .AND. tarifa->opp > 0
            _calc[ "ukupno" ] := _calc[ "ukupno" ] + _iznos
            _calc[ "osnovica" ] := _calc[ "osnovica" ] + ( _iznos / ( 1 + tarifa->opp / 100 ) )
            _calc[ "pdv" ] := _calc[ "pdv" ] + ( ( _iznos / ( 1 + tarifa->opp / 100 ) ) * ( tarifa->opp / 100 ) )
         ELSE
            _calc[ "ukupno" ] := _calc[ "ukupno" ] + _iznos
            _calc[ "osnovica" ] := _calc[ "osnovica" ] + _iznos
         ENDIF
      ELSE
         IF !IsIno( partner ) .AND. !is_part_pdv_oslob_po_clanu( partner ) .AND. tarifa->opp > 0
            _calc[ "ukupno" ] := _calc[ "ukupno" ] + ( _iznos * ( 1 + tarifa->opp / 100 ) )
            _calc[ "osnovica" ] := _calc[ "osnovica" ] + _iznos
            _calc[ "pdv" ] := _calc[ "pdv" ] + ( _iznos * ( tarifa->opp / 100 ) )
         ELSE
            _calc[ "ukupno" ] := _calc[ "ukupno" ] + _iznos
            _calc[ "osnovica" ] := _calc[ "osnovica" ] + _iznos
         ENDIF
      ENDIF

   NEXT

   // svesti na dvije decimale
   _calc[ "ukupno" ] := Round( _calc[ "ukupno" ], 2 )
   _calc[ "osnovica" ] := Round( _calc[ "osnovica" ], 2 )
   _calc[ "pdv" ] := Round( _calc[ "pdv" ], 2 )

   SELECT ( nDbfArea )

   RETURN _calc




STATIC FUNCTION get_a_iznos( idfirma, idtipdok, brdok )

   LOCAL _a_iznos := {}
   LOCAL _tar, cIdRoba, _scan

   SELECT fakt
   GO TOP
   SEEK idfirma + idtipdok + brdok
   DO WHILE !Eof() .AND. field->idfirma == idfirma .AND. field->idtipdok == idtipdok .AND. field->brdok == brdok

      cIdRoba := field->idroba
      nCijena := field->cijena
      _kol := field->kolicina
      _rab := field->rabat

      SELECT roba
      HSEEK cIdRoba

      SELECT tarifa
      HSEEK roba->idtarifa

      _tar := tarifa->id

      SELECT fakt

      IF field->dindem == Left( ValBazna(), 3 )
         _iznos := Round( _kol * nCijena * PrerCij() * ( 1 - _rab / 100 ), ZAOKRUZENJE )
      ELSE
         _iznos := Round( _kol * nCijena * PrerCij() * ( 1 - _rab / 100 ), ZAOKRUZENJE )
      ENDIF

      IF RobaZastCijena( _tar )
         _tar := PadR( "PDV17", 6 )
      ENDIF

      _scan := AScan( _a_iznos, {| VAR | VAR[ 1 ] == _tar } )

      IF _scan == 0
         AAdd( _a_iznos, { PadR( _tar, 6 ), _iznos } )
      ELSE
         _a_iznos[ _scan, 2 ] := _a_iznos[ _scan, 2 ] + _iznos
      ENDIF

      SKIP

   ENDDO

   RETURN _a_iznos



STATIC FUNCTION fakt_fiscal_stavke_racuna( cIdFirma, cIdTipDok, cBrDok, storno, aPartner )

   LOCAL aRacunData := {}
   LOCAL _n_rn_broj, _rn_iznos, _rn_rabat, _rn_datum, _rekl_rn_broj
   LOCAL _vrsta_pl, _partn_id, _rn_total, _rn_f_total
   LOCAL _art_id, _art_plu, cNazivArtikla, _art_jmj, cVrstaPlacanja
   LOCAL cArtikalBarkod, _rn_rbr, _memo
   LOCAL _pop_na_teret_prod := .F.
   LOCAL _partn_ino := .F.
   LOCAL _partn_pdv := .T.
   LOCAL _a_iznosi := {}
   LOCAL _data_item, _data_total, _arr, nStornoIdentifikator, cRacunBroj

   // 0 - gotovina
   // 3 - ziralno / virman

   cVrstaPlacanja := "0"

   IF aPartner <> NIL
      cVrstaPlacanja := aPartner[ 1, 6 ]
      _partn_ino := aPartner[ 1, 7 ]
      _partn_pdv := aPartner[ 1, 8 ]
   ELSE
      cVrstaPlacanja := __vrsta_pl
      _partn_ino := __partn_ino
      _partn_pdv := __partn_pdv
   ENDIF

   IF storno == NIL
      storno := .F.
   ENDIF

   fakt_fiscal_o_tables()

   SELECT fakt_doks
   GO TOP
   SEEK ( cIdFirma + cIdTipDok + cBrDok )

   _n_rn_broj := Val( AllTrim( field->brdok ) )
   _rekl_rn_broj := field->fisc_rn

   _rn_iznos := field->iznos
   _rn_rabat := field->rabat
   _rn_datum := field->datdok
   _partn_id := field->idpartner

   _a_iznosi := get_a_iznos( cIdFirma, cIdTipDok, cBrDok )
   _data_total := fakt_izracunaj_total( _a_iznosi, _partn_id, cIdTipDok )

   SELECT fakt
   GO TOP
   SEEK ( cIdFirma + cIdTipDok + cBrDok )

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
   // _rn_total := _uk_sa_pdv( cIdTipDok, _partn_id, _rn_iznos )

   _rn_total := _data_total[ "ukupno" ]
   _rn_f_total := 0

   DO WHILE !Eof() .AND. field->idfirma == cIdFirma .AND. field->idtipdok == cIdTipDok .AND. field->brdok == cBrDok

      SELECT roba
      SEEK fakt->idroba

      SELECT fakt

      nStornoIdentifikator := 0

      IF ( field->kolicina < 0 ) .AND. !storno
         nStornoIdentifikator := 1
      ENDIF

      cRacunBroj := fakt->brdok
      _rn_rbr := fakt->rbr

      _memo := ParsMemo( fakt->txt )

      _art_id := fakt->idroba
      cArtikalBarkod := AllTrim( roba->barkod )

      IF roba->tip == "U" .AND. Empty( AllTrim( roba->naz ) )

         _memo_opis := AllTrim( _memo[ 1 ] )

         IF Empty( _memo_opis )
            _memo_opis := "artikal bez naziva"
         ENDIF

         cNazivArtikla := AllTrim( fiscal_art_naz_fix( _memo_opis, __device_params[ "drv" ] ) )
      ELSE
         cNazivArtikla := AllTrim( fiscal_art_naz_fix( roba->naz, __device_params[ "drv" ] ) )
      ENDIF

      _art_jmj := AllTrim( roba->jmj )
      _art_plu := roba->fisc_plu

      IF __device_params[ "plu_type" ] == "D" .AND.  ;
            ( __device_params[ "vp_sum" ] <> 1 .OR. cIdTipDok $ "11" .OR. Len( _a_iznosi ) > 1 )

         _art_plu := auto_plu( NIL, NIL,  __device_params )

         IF __DRV_CURRENT == "FPRINT" .AND. _art_plu == 0
            MsgBeep( "PLU artikla = 0, to nije moguce !" )
            RETURN NIL
         ENDIF

      ENDIF

      nCijena := roba->mpc

      cIdTarifa := AllTrim( roba->idtarifa )

      _arr := {}
      AAdd( _arr, { cIdTarifa, field->cijena } )
      _data_item := fakt_izracunaj_total( _arr, _partn_id, cIdTipDok )

      nCijena := _data_item[ "ukupno" ]

      IF cIdTipDok == "10"
         _vr_plac := "3"
      ENDIF

      nKolicina := Abs( field->kolicina )

      IF !_partn_ino .AND. !_partn_pdv .AND. RobaZastCijena( roba->idtarifa )
         _pop_na_teret_prod := .T.
         _rn_rabat := 0
      ELSE
         _rn_rabat := Abs ( field->rabat )
      ENDIF

      IF _partn_ino == .T.
         cIdTarifa := "PDV0"
      ENDIF

      cStornoRacunOpis := ""

      IF _rekl_rn_broj > 0
         cStornoRacunOpis := AllTrim( Str( _rekl_rn_broj ) )
      ENDIF

      IF field->dindem == Left( ValBazna(), 3 )
         _rn_f_total += Round( nKolicina * nCijena * PrerCij() * ( 1 - _rn_rabat / 100 ), ZAOKRUZENJE )
      ELSE
         _rn_f_total += Round( nKolicina * nCijena * PrerCij() * ( 1 - _rn_rabat / 100 ), ZAOKRUZENJE )
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

      AAdd( aRacunData, { cRacunBroj, ;
         _rn_rbr, ;
         _art_id, ;
         cNazivArtikla, ;
         nCijena, ;
         nKolicina, ;
         cIdTarifa, ;
         cStornoRacunOpis, ;
         _art_plu, ;
         nCijena, ;
         _rn_rabat, ;
         cArtikalBarkod, ;
         cVrstaPlacanja, ;
         _rn_total, ;
         _rn_datum, ;
         _art_jmj } )

      SKIP

   ENDDO

   IF _pop_na_teret_prod .OR. _partn_ino
      FOR _n := 1 TO Len( aRacunData )
         aRacunData[ _n, 14 ] := _rn_f_total
      NEXT
   ENDIF

   IF cIdTipDok $ "10" .AND. Len( _a_iznosi ) < 2
      set_fiscal_rn_zbirni( @aRacunData )
   ENDIF

   _item_level_check := 2

   IF provjeri_kolicine_i_cijene_fiskalnog_racuna( @aRacunData, storno, _item_level_check, __device_params[ "drv" ] ) < 0
      RETURN NIL
   ENDIF

   RETURN aRacunData



/*
   Opis: da li je račun bezgotovinski u zavisnosti od tipa dokumenta i vrste plaćanja
*/
STATIC FUNCTION racun_bezgotovinski( cIdTipDok, vrsta_placanja )

   IF cIdTipDok == "10" .AND. vrsta_placanja <> "G "
      RETURN .T.
   ENDIF

   IF cIdTipDok == "11" .AND. vrsta_placanja == "VR"
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
STATIC FUNCTION vrsta_placanja_za_fiskalni_uredjaj( cIdTipDok, vrsta_placanja )

   LOCAL cVrPlac := "0"

   IF ( cIdTipDok $ "#10#" .AND. !vrsta_placanja == "G " ) .OR. ( cIdTipDok == "11" .AND. vrsta_placanja == "VR" )
      cVrPlac := "3"
   ELSEIF ( cIdTipDok == "10" .AND. vrsta_placanja == "G " )
      cVrPlac := "0"
   ENDIF

   IF cIdTipDok $ "#11#" .AND. vrsta_placanja == "KT"
      cVrPlac := "1"
   ENDIF

   RETURN cVrPlac


/*
   Opis: da li se vrsta dokumenta može poslati na fiskalni uređaj
*/
STATIC FUNCTION dokument_se_moze_fiskalizovati( cIdTipDok )

   IF cIdTipDok $ "10#11"
      RETURN .T.
   ENDIF

   RETURN .F.



/*
   Opis: da li su podaci partnera za ispis na fiskalni račun kompletni
         naziv, adresa, ptt, telefon
*/
STATIC FUNCTION is_podaci_partnera_kompletirani( sifra, id_broj )

   LOCAL lRet := .T.

   select_o_partner( sifra )

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

   Usage: fakt_fiscal_podaci_partnera( cIdFirma, cIdTipDok, cBrDok, storno, lRacunBezPartnera )

   Parametri:
      - cIdFirma - fakt_doks->idfirma
      - cIdTipDok - fakt_doks->idtipdok
      - cBrDok - fakt_doks->brdok
      - storno - .T. račun je storno
      - lRacunBezPartnera - .T. bezgotovinski račun je moguć bez partnera

   Return:
      - .F. - podaci partnera nisu kompletirani ili ispravni, ima ID broj, PDV broj, ali fali adresa
      - NIL - podaci partnera ne treba da se uzimaju kod štampe fiskalnog računa
      - {} - podaci partnera { identifikacioni broj, naziv, adresa, telefon, ... }

   Primjer:

      aPartner := fakt_fiscal_podaci_partnera( "10", "10", "00001", .F., .F. )

      IF aPartner == .F.
            => partner ima podešene idbroj, pdv broj ali podaci partnera nisu kompletni, fiskalni račun nije moguće napraviti
      IF aPartner == NIL
            => na fiskalnom račun partner i njegovi podaci će biti ignorisani

*/

STATIC FUNCTION fakt_fiscal_podaci_partnera( cIdFirma, cIdTipDok, cBrDok, storno, lBezgRacunBezPartnera )

   LOCAL _podaci := {}
   LOCAL _partn_id
   LOCAL _vrsta_p
   LOCAL cVrstaPlacanja := "0"
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
   SEEK ( cIdFirma + cIdTipDok + cBrDok )

   _partn_id := field->idpartner
   _vrsta_p := field->idvrstep

   IF Empty( _partn_id )
      MsgBeep( "Šifra partnera ne postoji, izdavanje računa nije moguće !" )
      RETURN .F.
   ENDIF

   _partn_id_broj := AllTrim( firma_id_broj( _partn_id ) )
   __vrsta_pl := vrsta_placanja_za_fiskalni_uredjaj( cIdTipDok, _vrsta_p )
   lPartnClan := is_part_pdv_oslob_po_clanu( _partn_id )

   IF IsIno( _partn_id )
      __partn_ino := .T.
      __partn_pdv := .F.
      RETURN NIL
   ENDIF

   IF !is_idbroj_13cifara( _partn_id_broj )
      __prikazi_partnera := .F.
   ENDIF

   _podaci_kompletirani := is_podaci_partnera_kompletirani( _partn_id, _partn_id_broj )

   IF racun_bezgotovinski( cIdTipDok, _vrsta_p ) .AND. ( !__prikazi_partnera .OR. !_podaci_kompletirani )
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
STATIC FUNCTION fakt_to_fprint( cIdFirma, cIdTipDok, cBrDok, aRacunData, head, storno )

   LOCAL _path := __device_params[ "out_dir" ]
   LOCAL _filename := __device_params[ "out_file" ]
   LOCAL _fiscal_no := 0
   LOCAL _total := aRacunData[ 1, 14 ]
   LOCAL _partn_naz
   LOCAL _err_level

   fprint_delete_answer( __device_params )

   fprint_rn( __device_params, aRacunData, head, storno )

   _err_level := fprint_read_error( __device_params, @_fiscal_no, storno )

   IF _err_level == -9
      IF Pitanje(, "Da li je nestalo trake (D/N) ?", "N" ) == "D"
         IF Pitanje(, "Ubacite traku i pritisnite 'D'", " " ) == "D"
            _err_level := fprint_read_error( __device_params, @_fiscal_no, storno )
         ENDIF
      ENDIF
   ENDIF

   IF _err_level == 2 .AND. storno
      error_bar( "fisc", "FPRINT ERR reklamirani fiskalni račun" )
      IF obrada_greske_na_liniji_55_reklamirani_racun( cIdFirma, cIdTipDok, cBrDok, __device_params )
         MsgBeep( "Ponoviti izdavanje reklamiranog računa na fiskalni uređaj." )
         RETURN 0
      ENDIF
   ENDIF

   IF _fiscal_no <= 0
      _err_level := 1
   ENDIF

   IF _err_level <> 0
      error_bar( "fisc", "FPRINT ERR fiskalni racun" )
      obradi_gresku_izdavanja_fiskalnog_racuna( __device_params, _err_level )
      RETURN _err_level
   ENDIF

   IF !Empty( param_racun_na_email() ) .AND. cIdTipDok $ "#11#"
      _partn_naz := _get_partner_for_email( cIdFirma, cIdTipDok, cBrDok )
      _snd_eml( _fiscal_no, cIdTipDok + "-" + AllTrim( cBrDok ), _partn_naz, NIL, _total )
   ENDIF

   set_fiscal_no_to_fakt_doks( cIdFirma, cIdTipDok, cBrDok, _fiscal_no, storno )

   IF __auto = .F.
      MsgBeep( "Kreiran fiskalni račun broj: " + AllTrim( Str( _fiscal_no ) ) )
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

   RETURN .T.



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
STATIC FUNCTION _get_partner_for_email( cIdFirma, cIdTipDok, cBrDok )

   LOCAL _ret := ""
   LOCAL nDbfArea := Select()
   LOCAL _partn
   LOCAL _id_vrste_p

   SELECT fakt_doks
   GO TOP
   SEEK cIdFirma + cIdTipDok + cBrDok

   _partn := field->idpartner
   _id_vrste_p := field->idvrstep

   SELECT partn
   HSEEK _partn

   IF Found()
      _ret := AllTrim( field->naz )
   ENDIF

   IF !Empty( _id_vrste_p )
      _ret += ", v.pl: " + _id_vrste_p
   ENDIF

   SELECT ( nDbfArea )

   RETURN _ret



/*
   izdavanje fiskalnog isjecka na TREMOL uredjaj
*/

STATIC FUNCTION fakt_to_tremol( cIdFirma, cIdTipDok, cBrDok, aRacunData, head, storno, CONT )

   LOCAL _err_level := 0
   LOCAL _f_name
   LOCAL _fiscal_no := 0

   // identifikator CONTINUE
   // nesto imamo mogucnost ako racun zapne da kazemo drugi identifikator
   // pa on navodno nastavi
   IF CONT == NIL
      CONT := "0"
   ENDIF


   _err_level := tremol_rn( __device_params, aRacunData, head, storno, CONT ) // stampaj racun

   _f_name := AllTrim( fiscal_out_filename( __device_params[ "out_file" ], cBrDok ) )


   IF tremol_read_out( __device_params, _f_name, __device_params[ "timeout" ] ) // da li postoji ista na izlazu ?

      _err_level := tremol_read_error( __device_params, _f_name, @_fiscal_no ) // procitaj sada gresku

   ELSE
      _err_level := -99
   ENDIF

   IF _err_level == 0 .AND. !storno .AND. CONT <> "2"
      // vrati broj fiskalnog racuna
      IF _fiscal_no > 0
         // prikazi poruku samo u direktnoj stampi
         IF __auto = .F.
            MsgBeep( "Kreiran fiskalni račun br: " + AllTrim( Str( _fiscal_no ) ) )
         ENDIF


         set_fiscal_no_to_fakt_doks( cIdFirma, cIdTipDok, cBrDok, _fiscal_no ) // ubaci broj fiskalnog racuna u fakturu

      ENDIF

      FErase( __device_params[ "out_dir" ] + _f_name )

   ENDIF

   RETURN _err_level




// -------------------------------------------------------------
// izdavanje fiskalnog isjecka na HCP uredjaj
// -------------------------------------------------------------
STATIC FUNCTION fakt_to_hcp( cIdFirma, cIdTipDok, cBrDok, aRacunData, head, storno )

   LOCAL _err_level := 0
   LOCAL _fiscal_no := 0

   _err_level := hcp_rn( __device_params, aRacunData, head, storno, aRacunData[ 1, 14 ] )

   IF _err_level = 0

      _fiscal_no := hcp_fisc_no( __device_params, storno )

      IF _fiscal_no > 0

         // ubaci broj fiskalnog racuna u fakturu
         set_fiscal_no_to_fakt_doks( cIdFirma, cIdTipDok, cBrDok, _fiscal_no, storno )

      ENDIF

   ENDIF

   RETURN _err_level



/*
   napravi zbirni racun ako je potrebno
*/

STATIC FUNCTION set_fiscal_rn_zbirni( aRacunData )

   LOCAL aRacunLocal := {}
   LOCAL _total := 0
   LOCAL nKolicina := 1
   LOCAL cNazivArtikla := ""
   LOCAL _len := Len( aRacunData )

   IF __device_params[ "vp_sum" ] < 1 .OR. ;
         __device_params[ "plu_type" ] == "P" .OR. ;
         ( __device_params[ "vp_sum" ] > 1 .AND. __device_params[ "vp_sum" ] < _len )
      // ova opcija se ne koristi
      // ako je iskljucena opcija
      // ili ako je sifra artikla genericki PLU
      // ili ako je zadato da ide iznad neke vrijednosti stavki na racunu
      RETURN .F.
   ENDIF

   cNazivArtikla := "Stav.RN:"

   IF __DRV_CURRENT  $ "#FPRINT#HCP#TRING#"
      cNazivArtikla += " " + AllTrim( aRacunData[ 1, 1 ] )
   ENDIF

   // ukupna vrijednost racuna za sve stavke matrice je ista popunjena
   _total := ROUND2( aRacunData[ 1, 14 ], 2 )

   IF !Empty( aRacunData[ 1, 8 ] )
      // ako je storno racun, napravi korekciju da je iznos pozitivan
      _total := Abs( _total )
   ENDIF

   // dodaj u aRacunLocal zbirnu stavku
   AAdd( aRacunLocal, { aRacunData[ 1, 1 ], ;
      aRacunData[ 1, 2 ], ;
      "", ;
      cNazivArtikla, ;
      _total, ;
      nKolicina, ;
      aRacunData[ 1, 7 ], ;
      aRacunData[ 1, 8 ], ;
      auto_plu( NIL, NIL, __device_params ), ;
      _total, ;
      0, ;
      "", ;
      aRacunData[ 1, 13 ], ;
      _total, ;
      aRacunData[ 1, 15 ], ;
      aRacunData[ 1, 16 ] } )


   aRacunData := aRacunLocal

   RETURN .T.



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

   RETURN .T.



// -------------------------------------------------------------
// izdavanje fiskalnog isjecka na TFP uredjaj - tring
// -------------------------------------------------------------
STATIC FUNCTION fakt_to_tring( cIdFirma, cIdTipDok, cBrDok, aRacunData, head, storno )

   LOCAL _err_level := 0
   LOCAL _trig := 1
   LOCAL _fiscal_no := 0

   IF storno
      _trig := 2
   ENDIF

   // brisi ulazne fajlove, ako postoje
   tring_delete_out( __device_params, _trig )

   // ispisi racun
   tring_rn( __device_params, aRacunData, head, storno )

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
      MsgBeep( "Postoji greska sa stampanjem !" )
   ELSE
      tring_delete_answer( __device_params, _trig )
      // ubaci broj fiskalnog racuna u fakturu
      set_fiscal_no_to_fakt_doks( cIdFirma, cIdTipDok, cBrDok, _fiscal_no )
      MsgBeep( "Kreiran fiskalni racun broj: " + AllTrim( Str( _fiscal_no ) ) )
   ENDIF

   RETURN _err_level




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

   _mail_param := f18_email_prepare( _subject, _body, NIL, _to )

   f18_email_send( _mail_param, NIL )

   RETURN NIL
