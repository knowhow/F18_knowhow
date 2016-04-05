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


STATIC __max_kolicina := NIL
STATIC __kalk_konto := NIL


FUNCTION max_kolicina_kod_unosa( read_par )

   IF read_par != NIL
      __max_kolicina := fetch_metric( "pos_maksimalna_kolicina_na_unosu", my_user(), 0 )
   ENDIF

   RETURN __max_kolicina


FUNCTION kalk_konto_za_stanje_pos( read_par )

   IF read_par != NIL
      __kalk_konto := fetch_metric( "pos_stanje_sa_kalk_konta", my_user(), "" )
   ENDIF

   RETURN __kalk_konto



FUNCTION pos_unos_racuna()

   PARAMETERS cBrojRn, cSto

   LOCAL _max_cols := MAXCOLS()
   LOCAL _max_rows := MAXROWS()
   LOCAL _read_barkod
   LOCAL _stanje_robe := 0
   LOCAL _stanje_art_id, _stanje_art_jmj

   PRIVATE ImeKol := {}
   PRIVATE Kol := {}
   PRIVATE nRowPos
   PRIVATE oBrowse
   PRIVATE nPopust := 0
   PRIVATE nIznNar := 0
   PRIVATE aUnosMsg := {}
   PRIVATE GetList := {}

   o_pos_tables()

   SELECT _pos_pripr

   aRabat := {}

   IF ( cBrojRn == nil )
      cBrojRn := ""
   ENDIF

   IF ( cSto == nil )
      cSto := ""
   ENDIF

   AAdd( ImeKol, { PadR( "Artikal", 10 ), {|| idroba } } )
   AAdd( ImeKol, { PadC( "Naziv", 50 ), {|| PadR( robanaz, 50 ) } } )
   AAdd( ImeKol, { "JMJ", {|| jmj } } )
   AAdd( ImeKol, { "Kolicina", {|| Str( kolicina, 8, 3 ) } } )
   AAdd( ImeKol, { "Cijena", {|| Str( cijena, 8, 2 ) } } )
   AAdd( ImeKol, { "Ukupno", {|| Str( kolicina * cijena, 10, 2 ) } } )
   AAdd( ImeKol, { "Tarifa", {|| idtarifa } } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   AAdd( aUnosMsg, "<*> - Ispravka stavke" )
   AAdd( aUnosMsg, "<F8> storno" )
   AAdd( aUnosMsg, "<F9> fiskalne funkcije" )

   Box(, _max_rows - 3, _max_cols - 3, , aUnosMsg )

   @ m_x, m_y + 23 SAY8 PadC ( "RAČUN BR: " + AllTrim( cBrojRn ), 40 ) COLOR F18_COLOR_INVERT

   oBrowse := FormBrowse( m_x + 7, m_y + 1, m_x + _max_rows - 12, m_y + _max_cols - 2, ;
      ImeKol, Kol, { BROWSE_PODVUCI_2, BROWSE_PODVUCI, BROWSE_COL_SEP }, 0 )

   oBrowse:autolite := .F.

   SetKey( K_F6, {|| f7_pf_traka() } )

   SetKey( K_F7, {|| pos_storno_fisc_no(), _refresh_total() } )
   SetKey( K_F8, {|| pos_storno_rn(), _refresh_total() } )
   SetKey( K_F9, {|| fiskalni_izvjestaji_komande( .T., .T.  ) } )

   pos_set_key_handler_ispravka_racuna()

   @ m_x + 3, m_y + ( _max_cols - 30 ) SAY "UKUPNO:"
   @ m_x + 4, m_y + ( _max_cols - 30 ) SAY "POPUST:"
   @ m_x + 5, m_y + ( _max_cols - 30 ) SAY " TOTAL:"

   ispisi_iznos_veliki_brojevi( 0, m_x + ( _max_rows - 12 ), _max_cols - 2 )

   nIznNar := 0
   nPopust := 0

   _calc_current_total( @nIznNar, @nPopust )

   SELECT _pos_pripr
   SET ORDER TO
   GO TOP

   scatter()

   gDatum := Date()
   _idpos := gIdPos
   _idvd  := VD_RN
   _brdok := cBrojRn
   _datum := gDatum
   _sto   := cSto
   _smjena := gSmjena
   _idradnik := gIdRadnik
   _idcijena := gIdCijena
   _prebacen := OBR_NIJE
   _mu_i := R_I

   IF gStolovi == "D"
      _sto_br := Val( cSto )
   ENDIF

   DO WHILE .T.

      SET CONFIRM ON
      _show_total( nIznNar, nPopust, m_x + 2 )

      @ m_x + 3, m_y + 15 SAY Space( 10 )

      ispisi_iznos_veliki_brojevi( ( nIznNar - nPopust ), m_x + ( _max_rows - 12 ), _max_cols - 2 )

      DO WHILE !oBrowse:stable
         oBrowse:Stabilize()
      ENDDO

      DO WHILE !oBrowse:Stabilize() .AND. ( ( Ch := Inkey() ) == 0 )
      ENDDO

      _idroba := Space( Len( _idroba ) )
      _kolicina := 0

      @ m_x + 2, m_y + 25 SAY Space ( 40 )
      SET CURSOR ON

      IF gDuzSifre > 0
         cDSFINI := AllTrim( Str( gDuzSifre ) )
      ELSE
         cDSFINI := "10"
      ENDIF

      @ m_x + 2, m_y + 5 SAY " Artikal:" GET _idroba ;
         PICT PICT_POS_ARTIKAL ;
         WHEN {|| _idroba := PadR( _idroba, Val( cDSFINI ) ), .T. } ;
         VALID valid_pos_racun_artikal( @_kolicina )

      @ m_x + 3, m_y + 5 SAY "  Cijena:" GET _Cijena PICT "99999.999"  ;
         WHEN ( roba->tip == "T" .OR. gPopZcj == "D" )

      @ m_x + 4, m_y + 5 SAY8 "Količina:" GET _kolicina ;
         PICT "999999.999" ;
         WHEN when_pos_kolicina( @_kolicina ) ;
         VALID valid_pos_kolicina( @_kolicina, _cijena )


      nRowPos := 5

      READ

      @ m_x + 4, m_y + 25 SAY Space ( 11 )

      IF LastKey() == K_ESC

         IF valid_dodaj_taksu_za_gorivo()
            EXIT
         ELSE

            _calc_current_total( @nIznNar, @nPopust )

            oBrowse:goBottom()
            oBrowse:refreshAll()
            oBrowse:dehilite()

            LOOP

         ENDIF

      ENDIF

      SELECT _pos_pripr
      APPEND BLANK

      _robanaz := roba->naz
      _jmj := roba->jmj
      _idtarifa := roba->idtarifa
      _idodj := Space( 2 )

      IF !( roba->tip == "T" )
         _cijena := pos_get_mpc()
      ENDIF

      Gather()

      IF !Empty( AllTrim( __kalk_konto ) )
         IF PadR( __kalk_konto, 3 ) == "132"
            _stanje_robe := kalk_kol_stanje_artikla_magacin( PadR( __kalk_konto, 7 ), field->idroba, Date() )
         ELSE
            _stanje_robe := kalk_kol_stanje_artikla_prodavnica( PadR( __kalk_konto, 7 ), field->idroba, Date() )
         ENDIF
      ELSE
         _stanje_robe := pos_stanje_artikla( field->idpos, field->idroba )
      ENDIF

      _stanje_art_id := field->idroba
      _stanje_art_jmj := field->jmj

      nIznNar += cijena * kolicina
      nPopust += ncijena * kolicina
      oBrowse:goBottom()
      oBrowse:refreshAll()
      oBrowse:dehilite()

      _tmp := "STANJE ARTIKLA " + AllTrim( _stanje_art_id ) + ": " + AllTrim( Str( _stanje_robe, 12, 2 ) ) + " " + _stanje_art_jmj
      ispisi_donji_dio_forme_unosa( _tmp, 1 )

   ENDDO

   SetKey( K_F6, NIL )
   SetKey( K_F7, NIL )
   SetKey( K_F8, NIL )
   SetKey( K_F9, NIL )

#ifdef F18_POS
   pos_unset_key_handler_ispravka_racuna()
#endif

   BoxC()

   RETURN ( .T. )



FUNCTION Popust( nx, ny )

   LOCAL nC1 := 0
   LOCAL nC2 := 0

   FrmGetRabat( aRabat, _cijena )
   ShowRabatOnForm( nx, ny )

   RETURN


STATIC FUNCTION valid_pos_racun_artikal( kolicina )

   LOCAL _ok, _read_barkod

   _ok := pos_postoji_roba( @_idroba, 2, 27, @_read_barkod ) .AND. NarProvDuple( _idroba )

   IF gOcitBarCod
      hb_keyPut( K_ENTER )
   ENDIF

   RETURN _ok


STATIC FUNCTION when_pos_kolicina( kolicina )

   Popust( m_x + 4, m_y + 28 )

   IF gOcitBarCod
      IF param_tezinski_barkod() == "D" .AND. kolicina <> 0
      ELSE
         kolicina := 1
      ENDIF
   ENDIF

   RETURN .T.



STATIC FUNCTION valid_pos_kolicina( kolicina, cijena )
   RETURN KolicinaOK( kolicina ) .AND. pos_check_qtty( @kolicina ) .AND. cijena_ok( cijena )




STATIC FUNCTION _refresh_total()

   LOCAL _iznos := 0
   LOCAL _popust := 0

   _calc_current_total( @_iznos, @_popust )

   nIznNar := _iznos
   nPopust := _popust

   ispisi_iznos_veliki_brojevi( ( _iznos - _popust ), m_x + ( MAXROWS() - 12 ), MAXCOLS() - 2 )

   _show_total( _iznos, _popust, m_x + 2 )

   SELECT _pos_pripr
   GO TOP

   RETURN .T.


STATIC FUNCTION _calc_current_total( iznos, popust )

   LOCAL _t_area := Select()
   LOCAL _iznos := 0
   LOCAL _popust := 0

   SELECT _pos_pripr
   GO TOP

   DO WHILE !Eof()
      _iznos += _pos_pripr->( kolicina * cijena )
      _popust += _pos_pripr->( kolicina * ncijena )
      SKIP
   ENDDO

   GO TOP

   iznos := _iznos
   popust := _popust

   SELECT ( _t_area )

   RETURN


FUNCTION pos_check_qtty( qtty )

   LOCAL _max_qtty

   _max_qtty := max_kolicina_kod_unosa()

   IF _max_qtty == 0
      _max_qtty := 99999
   ENDIF

   IF _max_qtty == 0
      RETURN .T.
   ENDIF

   IF qtty > _max_qtty
      IF Pitanje(, "Da li je ovo ispravna količina (D/N) ?: " + AllTrim( Str( qtty ) ), "N" ) == "D"
         RETURN .T.
      ELSE
         qtty := 0
         RETURN .F.
      ENDIF
   ELSE
      RETURN .T.
   ENDIF





FUNCTION pos_set_key_handler_ispravka_racuna()
   SetKey( Asc( "*" ), {|| pos_ispravi_racun() } )
   RETURN .T.



FUNCTION pos_unset_key_handler_ispravka_racuna()
   SetKey( Asc ( "*" ), NIL )
   RETURN .F.



STATIC FUNCTION cijena_ok( cijena )

   LOCAL _ret := .T.

   IF LastKey() == K_UP
      RETURN _ret
   ENDIF

   IF cijena == 0
      MsgBeep( "Nepravilan unos cijene, cijena mora biti <> 0 !!!" )
      _ret := .F.
   ENDIF

   RETURN _ret


STATIC FUNCTION KolicinaOK( kolicina )

   LOCAL _ok := .F.
   LOCAL _msg
   LOCAL _stanje_robe

   IF LastKey() == K_UP
      _ok := .T.
      RETURN _ok
   ENDIF

   IF ( kolicina == 0 )
      MsgBeep( "Nepravilan unos količine! Ponovite unos!", 15 )
      RETURN _ok
   ENDIF

   IF gPratiStanje == "N" .OR. roba->tip $ "TU"
      _ok := .T.
      RETURN _ok
   ENDIF

   _stanje_robe := pos_stanje_artikla( _idpos, _idroba )

   _ok := .T.

   IF ( kolicina > _stanje_robe )

      _msg := "Artikal: " + _idroba + " Trenutno na stanju: " + Str( _stanje_robe, 12, 2 )

      IF gPratiStanje = "!"
         _msg += "#Unos artikla onemogućen !!!"
         _ok := .F.
      ENDIF

      MsgBeep( _msg )

   ENDIF

   RETURN _ok



STATIC FUNCTION NarProvDuple()

   LOCAL nPrevRec
   LOCAL lFlag := .T.

   IF gDupliArt == "D" .AND. gDupliUpoz == "N"
      RETURN .T.
   ENDIF

   SELECT _pos_pripr
   nPrevRec := RecNo()

   IF _idroba = PadR( "PLDUG", 7 ) .AND. reccount2() <> 0
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "1"
   SEEK PadR( "PLDUG", 7 )

   IF Found()
      MsgBeep( 'PLDUG mora biti jedina stavka !' )
      SET ORDER TO
      GO ( nPrevRec )
      RETURN .F.
   ELSE
      SET ORDER TO TAG "1"
      HSEEK _IdRoba
   ENDIF

   IF Found()
      IF _IdRoba = 'PLDUG'
         MsgBeep( 'Pri plaćanju duga ne možete navoditi artikal' )
      ENDIF
      IF gDupliArt == "N"
         MsgBeep ( "Na računu se već nalazi ista roba!#" + "U slucaju potrebe ispravite stavku računa!", 20 )
         lFlag := .F.
      ELSEIF gDupliUpoz == "D"
         MsgBeep ( "Na računu se već nalazi ista roba!" )
      ENDIF
   ENDIF
   SET ORDER TO
   GO ( nPrevRec )

   RETURN ( lFlag )



FUNCTION pos_ispravi_racun()

   LOCAL cGetId
   LOCAL nGetKol
   LOCAL aConds
   LOCAL aProcs

   pos_unset_key_handler_ispravka_racuna()

   OpcTipke( { "<Enter>-Ispravi stavku", hb_utf8tostr( "<B>-Briši stavku" ), hb_utf8tostr( "<Esc>-Završi" ) } )

   oBrowse:autolite := .T.
   oBrowse:configure()

   cGetId := _idroba
   nGetKol := _Kolicina

   aConds := { {| Ch| Upper( Chr( Ch ) ) == "B" }, {| Ch| Ch == K_ENTER } }
   aProcs := { {|| pos_brisi_stavku_racuna( oBrowse ) }, {|| pos_ispravi_stavku_racuna( oBrowse ) } }

   ShowBrowse( oBrowse, aConds, aProcs )

   oBrowse:autolite := .F.
   oBrowse:dehilite()
   oBrowse:stabilize()

   Prozor0()

   _idroba := cGetId
   _kolicina := nGetKol

   pos_set_key_handler_ispravka_racuna()

   RETURN


STATIC FUNCTION _show_total( iznos, popust, row )

   @ m_x + row + 0, m_y + ( MAXCOLS() - 12 ) SAY iznos PICT "99999.99" COLOR F18_COLOR_INVERT
   @ m_x + row + 1, m_y + ( MAXCOLS() - 12 ) SAY popust PICT "99999.99" COLOR F18_COLOR_INVERT
   @ m_x + row + 2, m_y + ( MAXCOLS() - 12 ) SAY iznos - popust PICT "99999.99" COLOR F18_COLOR_INVERT

   RETURN



FUNCTION pos_brisi_stavku_racuna( oBrowse )

   SELECT _pos_pripr

   IF RecCount2() == 0
      MsgBeep ( "Priprema računa je prazna !!!#Brisanje nije moguće !", 20 )
      RETURN ( DE_REFRESH )
   ENDIF

   Beep ( 2 )

   nIznNar -= _pos_pripr->( kolicina * cijena )
   nPopust -= _pos_pripr->( kolicina * ncijena )

   _show_total( nIznNar, nPopust, m_x + 2 )
   ispisi_iznos_veliki_brojevi( ( nIznNar - nPopust ), m_x + ( MAXROWS() - 12 ), MAXCOLS() - 2 )

   my_delete()

   oBrowse:refreshAll()

   DO WHILE !oBrowse:stable
      oBrowse:Stabilize()
   ENDDO

   RETURN ( DE_REFRESH )




FUNCTION pos_ispravi_stavku_racuna()

   PRIVATE GetList := {}

   SELECT _pos_pripr

   IF RecCount2() == 0
      MsgBeep ( "Račun ne sadrži niti jednu stavku!#Ispravka nije moguća!", 20 )
      RETURN ( DE_CONT )
   ENDIF

   Scatter()

   SET CURSOR ON

   Box (, 3, 75 )

   @ m_x + 1, m_y + 4 SAY "    Artikal:" GET _idroba PICTURE PICT_POS_ARTIKAL VALID pos_postoji_roba( @_idroba, 1, 27 ) .AND. ( _IdRoba == _pos_pripr->IdRoba .OR. NarProvDuple () )
   @ m_x + 2, m_y + 3 SAY "     Cijena:" GET _Cijena  PICTURE "99999.999" WHEN roba->tip == "T"
   @ m_x + 3, m_y + 3 SAY "   kolicina:" GET _Kolicina VALID KolicinaOK ( _Kolicina )

   READ

   SELECT _pos_pripr
   @ m_x + 3, m_Y + 25 SAY Space(11)

   IF LastKey() <> K_ESC

      IF ( _pos_pripr->IdRoba <> _IdRoba ) .OR. roba->tip == "T"

         _robanaz := roba->naz
         _jmj := roba->jmj

         IF !( roba->tip == "T" )
            _cijena := pos_get_mpc()
         ENDIF

         _idtarifa := roba->idtarifa
         _idodj := Space( 2 )

         nIznNar += ( _cijena * _kolicina ) -cijena * kolicina
         nPopust += ( _ncijena * _kolicina )  - ncijena * kolicina

         my_rlock()
         Gather()
         my_unlock()

      ENDIF

      IF ( _pos_pripr->Kolicina <> _Kolicina )
         nIznNar += ( _cijena * _kolicina ) - cijena * kolicina
         nPopust += ( _ncijena * _kolicina ) - ncijena * kolicina
         RREPLACE Kolicina WITH _Kolicina
      ENDIF

   ENDIF

   BoxC()

   _show_total( nIznNar, nPopust, m_x + 2 )
   ispisi_iznos_veliki_brojevi( ( nIznNar - nPopust ), m_x + ( MAXROWS() - 12 ), MAXCOLS() - 2 )

   oBrowse:refreshCurrent()

   DO WHILE !oBrowse:stable
      oBrowse:Stabilize()
   ENDDO

   RETURN ( DE_CONT )




FUNCTION GetReader2( oGet, GetList, oMenu, aMsg )

   LOCAL nKey
   LOCAL nRow
   LOCAL nCol

   IF ( GetPreValSC( oGet, aMsg ) )
      oGet:setFocus()
      DO WHILE ( oGet:exitState == GE_NOEXIT )
         IF ( gOcitBarcod .AND. gEntBarCod == "D" )
            oGet:exitState := GE_ENTER
            EXIT
         ENDIF
         IF ( oGet:typeOut )
            oGet:exitState := GE_ENTER
         ENDIF

         DO WHILE ( oGet:exitState == GE_NOEXIT )
            nKey := Inkey( 0 )
            GetApplyKey( oGet, nKey, GetList, oMenu, aMsg )
            nRow := Row()
            nCol := Col()
            DevPos( nRow, nCol )
         ENDDO

         IF ( !GetPstValSC( oGet, aMsg ) )
            oGet:exitState := GE_NOEXIT
         ENDIF
      ENDDO
      oGet:killFocus()
   ENDIF

   RETURN
