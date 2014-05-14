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

#include "pos.ch"
#include "getexit.ch"
#include "f18_separator.ch"

STATIC __max_kolicina := NIL
STATIC __kalk_konto := NIL


// ----------------------------------------------------------
// maksimalna kolicina na unosu racuna
// ----------------------------------------------------------
FUNCTION max_kolicina_kod_unosa( read_par )

   IF read_par != NIL
      __max_kolicina := fetch_metric( "pos_maksimalna_kolicina_na_unosu", my_user(), 0 )
   ENDIF

   RETURN __max_kolicina


// ----------------------------------------------------------
// kalk konto za stanje artikla
// ----------------------------------------------------------
FUNCTION kalk_konto_za_stanje_pos( read_par )

   IF read_par != NIL
      __kalk_konto := fetch_metric( "pos_stanje_sa_kalk_konta", my_user(), "" )
   ENDIF

   RETURN __kalk_konto



FUNCTION UnesiNarudzbu()

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
   PRIVATE aAutoKeys := {}
   PRIVATE nPopust := 0
   PRIVATE nIznNar := 0
   PRIVATE bPrevZv
   PRIVATE bPrevKroz
   PRIVATE aUnosMsg := {}
   PRIVATE bPrevUp
   PRIVATE bPrevDn
   PRIVATE GetList := {}

   o_pos_tables()

   SELECT _pos

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
   // AADD( aUnosMsg, "Storno - neg.kolicina")
   AAdd( aUnosMsg, "<F8> storno" )
   AAdd( aUnosMsg, "<F9> fiskalne funkcije" )

   Box(, _max_rows - 3, _max_cols - 3, , aUnosMsg )

   @ m_x, m_y + 23 SAY PadC ( "RACUN BR: " + AllTrim( cBrojRn ), 40 ) COLOR Invert

   oBrowse := FormBrowse( m_x + 7, m_y + 1, m_x + _max_rows - 12, m_y + _max_cols - 2, ;
      ImeKol, Kol, { BROWSE_PODVUCI_2, BROWSE_PODVUCI, BROWSE_COL_SEP }, 0 )

   oBrowse:autolite := .F.
   aAutoKeys := HangKeys()
   bPrevDn := SetKey( K_PGDN, {|| DummyProc() } )
   bPrevUp := SetKey( K_PGUP, {|| DummyProc() } )

   SetKey( K_F6, {|| f7_pf_traka() } )

   // storno racuna
   SetKey( K_F7, {|| pos_storno_fisc_no(), _refresh_total() } )
   SetKey( K_F8, {|| pos_storno_rn(), _refresh_total() } )
   SetKey( K_F9, {|| fisc_rpt( .T., .T.  ) } )

   // <*> - ispravka tekuce narudzbe
   // (ukljucujuci brisanje i ispravku vrijednosti)
   // </> - pregled racuna - kod HOPSa

   SetSpecNar()

   @ m_x + 3, m_y + ( _max_cols - 30 ) SAY "UKUPNO:"
   @ m_x + 4, m_y + ( _max_cols - 30 ) SAY "POPUST:"
   @ m_x + 5, m_y + ( _max_cols - 30 ) SAY " TOTAL:"

   // ispis velikim brojevima iznosa racuna
   // na dnu forme...
   ispisi_iznos_veliki_brojevi( 0, m_x + ( _max_rows - 12 ), _max_cols - 2 )

   SELECT _pos
   SET ORDER TO TAG "1"

   nIznNar := 0
   nPopust := 0

   _calc_current_total( @nIznNar, @nPopust )

   SELECT _pos_pripr
   SET ORDER TO
   GO TOP

   // uzmi varijable _pos_pripr
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

      // brisi staru cijenu
      @ m_x + 3, m_y + 15 SAY Space( 10 )

      // ispisi i iznos velikim brojevima na dnu...
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

      // duzina naziva robe na unosu...
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

      @ m_x + 4, m_y + 5 SAY "Kolicina:" GET _kolicina ;
         PICT "999999.999" ;
         WHEN when_pos_kolicina( @_kolicina ) ;
         VALID valid_pos_kolicina( @_kolicina, _cijena )


      nRowPos := 5

      READ

      @ m_x + 4, m_y + 25 SAY Space ( 11 )

      // zakljuci racun
      IF LastKey() == K_ESC
         EXIT
      ENDIF

      // dodaj stavku racuna
      SELECT _pos_pripr
      APPEND BLANK

      _robanaz := roba->naz
      _jmj := roba->jmj
      _idtarifa := roba->idtarifa
      _idodj := Space( 2 )

      IF !( roba->tip == "T" )
         _cijena := pos_get_mpc()
         // roba->mpc
      ENDIF

      // _pos_pripr
      Gather()

      // gledati iz KALK ili iz POS ?
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

      // utvrdi stanje racuna
      nIznNar += cijena * kolicina
      nPopust += ncijena * kolicina
      oBrowse:goBottom()
      oBrowse:refreshAll()
      oBrowse:dehilite()

      // prikazi stanje artikla u dnu ekrana
      _tmp := "STANJE ARTIKLA " + AllTrim( _stanje_art_id ) + ": " + AllTrim( Str( _stanje_robe, 12, 2 ) ) + " " + _stanje_art_jmj
      ispisi_donji_dio_forme_unosa( _tmp, 1 )

   ENDDO

   CancelKeys( aAutoKeys )
   SetKey( K_PGDN, bPrevDn )
   SetKey( K_PGUP, bPrevUp )

   SetKey( K_F6, NIL )
   SetKey( K_F7, NIL )
   SetKey( K_F8, NIL )
   SetKey( K_F9, NIL )

   UnSetSpecNar()

   BoxC()

   RETURN ( .T. )



// ----------------------------------------------
// obrada popusta
// ----------------------------------------------
FUNCTION Popust( nx, ny )

   LOCAL nC1 := 0
   LOCAL nC2 := 0

   FrmGetRabat( aRabat, _cijena )
   ShowRabatOnForm( nx, ny )

   RETURN


// ----------------------------------------------
// validacija artikla na racunu
// ----------------------------------------------
STATIC FUNCTION valid_pos_racun_artikal( kolicina )

   LOCAL _ok, _read_barkod

   _ok := pos_postoji_roba( @_idroba, 2, 27, @_read_barkod ) .AND. NarProvDuple( _idroba )

   IF gOcitBarCod
      hb_keyPut( K_ENTER )
   ENDIF

   RETURN _ok


// ---------------------------------------------
// ---------------------------------------------
STATIC FUNCTION when_pos_kolicina( kolicina )

   Popust( m_x + 4, m_y + 28 )

   IF gOcitBarCod
      IF param_tezinski_barkod() == "D" .AND. kolicina <> 0
         // _kolicina vec setovana
      ELSE
         // ako je sifra ocitana po barcodu, onda ponudi kolicinu 1
         kolicina := 1
      ENDIF
   ENDIF

   RETURN .T.



// ----------------------------------------------------------------
// ----------------------------------------------------------------
STATIC FUNCTION valid_pos_kolicina( kolicina, cijena )
   RETURN KolicinaOK( kolicina ) .AND. pos_check_qtty( @kolicina ) .AND. cijena_ok( cijena )




// ----------------------------------------------
//
// ----------------------------------------------
STATIC FUNCTION _refresh_total()

   LOCAL _iznos := 0
   LOCAL _popust := 0

   // izracunaj trenutni total...
   _calc_current_total( @_iznos, @_popust )

   nIznNar := _iznos
   nPopust := _popust

   // ispisi i iznos velikim brojevima na dnu...
   ispisi_iznos_veliki_brojevi( ( _iznos - _popust ), m_x + ( MAXROWS() - 12 ), MAXCOLS() - 2 )

   // ispisi i na gornjem totalu...
   _show_total( _iznos, _popust, m_x + 2 )

   SELECT _pos_pripr
   GO TOP

   RETURN .T.


// --------------------------------------------------------------
// izracunava trenutni total u pripremi
// --------------------------------------------------------------
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

   iznos := _iznos
   popust := _popust

   SELECT ( _t_area )

   RETURN


// ----------------------------------------------------
// provjera kolicine na unosu racuna
// ----------------------------------------------------
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
      IF Pitanje(, "Da li je ovo ispravna kolicina: " + AllTrim( Str( qtty ) ), "N" ) == "D"
         RETURN .T.
      ELSE
         // resetuj na 0
         qtty := 0
         RETURN .F.
      ENDIF
   ELSE
      RETURN .T.
   ENDIF



/*! \fn HangKeys()
 *  \brief Nabacuje SETKEYa kako je tastatura programirana
 */

FUNCTION HangKeys()

   LOCAL aKeysProcs := {}
   LOCAL bPrevSet

   SELECT K2C
   GO TOP

   DO WHILE !Eof()
      bPrevSet := SetKey( KeyCode, {|| AutoKeys () } )
      AAdd ( aKeysProcs, { KeyCode, bPrevSet } )
      SKIP
   ENDDO

   RETURN ( aKeysProcs )



/*! \fn CancelKeys(aPrevSets)
 *  \brief Ukida SETKEYs koji se postave i HANGKEYs
 *  \param aPrevSets
 */

FUNCTION CancelKeys( aPrevSets )

   LOCAL i := 1

   nPrev := Select()

   SELECT K2C
   GoTop2()
   DO WHILE !Eof()
      SetKey( KeyCode, aPrevSets[ i++ ] )
      SKIP
   ENDDO
   SELECT ( nPrev )

   RETURN



FUNCTION SetSpecNar()

   bPrevZv := SetKey( Asc( "*" ), {|| IspraviNarudzbu() } )

   RETURN .T.


FUNCTION UnSetSpecNar()

   SetKey( Asc ( "*" ), bPrevZv )

   RETURN .F.


// --------------------------------------------
// provjera cijene
// --------------------------------------------
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


// --------------------------------------------------------
// provjerava trenutnu kolicinu artikla u kasi...
// --------------------------------------------------------
STATIC FUNCTION KolicinaOK( kolicina )

   LOCAL _ok := .F.
   LOCAL _msg
   LOCAL _stanje_robe

   IF LastKey() == K_UP
      _ok := .T.
      RETURN _ok
   ENDIF

   IF ( kolicina == 0 )
      MsgBeep( "Nepravilan unos kolicine robe! Ponovite unos!", 15 )
      RETURN _ok
   ENDIF

   IF gPratiStanje == "N" .OR. roba->tip $ "TU"
      _ok := .T.
      RETURN _ok
   ENDIF

   // izvuci stanje robe
   _stanje_robe := pos_stanje_artikla( _idpos, _idroba )

   _ok := .T.

   IF ( kolicina > _stanje_robe )

      _msg := "Artikal: " + _idroba + " Trenutno na stanju: " + Str( _stanje_robe, 12, 2 )

      IF gPratiStanje = "!"
         _msg += "#Unos artikla onemogucen !!!"
         _ok := .F.
      ENDIF

      MsgBeep( _msg )

   ENDIF

   RETURN _ok



STATIC FUNCTION NarProvDuple()

   LOCAL nPrevRec
   LOCAL lFlag := .T.

   IF gDupliArt == "D" .AND. gDupliUpoz == "N"
      // mogu dupli i nema upozorenja
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
         MsgBeep( 'Pri placanju duga ne mozete navoditi robu' )
      ENDIF
      IF gDupliArt == "N"
         MsgBeep ( "Na narudzbi se vec nalazi ista roba!#" + "U slucaju potrebe ispravite stavku narudzbe!", 20 )
         lFlag := .F.
      ELSEIF gDupliUpoz == "D"
         MsgBeep ( "Na narudzbi se vec nalazi ista roba!" )
      ENDIF
   ENDIF
   SET ORDER TO
   GO ( nPrevRec )

   RETURN ( lFlag )



FUNCTION IspraviNarudzbu()

   // Koristi privatnu varijablu oBrowse iz UNESINARUDZBU
   LOCAL cGetId
   LOCAL nGetKol
   LOCAL aConds
   LOCAL aProcs

   UnSetSpecNar()

   OpcTipke( { "<Enter>-Ispravi stavku", "<B>-Brisi stavku", "<Esc>-Zavrsi" } )

   oBrowse:autolite := .T.
   oBrowse:configure()

   // spasi ono sto je bilo u GET-u
   cGetId := _idroba
   nGetKol := _Kolicina

   aConds := { {| Ch| Upper( Chr( Ch ) ) == "B" }, {| Ch| Ch == K_ENTER } }
   aProcs := { {|| BrisStavNar( oBrowse ) }, {|| EditStavNar ( oBrowse ) } }

   ShowBrowse( oBrowse, aConds, aProcs )

   oBrowse:autolite := .F.
   oBrowse:dehilite()
   oBrowse:stabilize()

   // vrati stari meni
   Prozor0()

   // OpcTipke (aUnosMsg)
   // vrati sto je bilo u GET-u
   _idroba := cGetId
   _kolicina := nGetKol

   SetSpecNar()

   RETURN


// ---------------------------------------------------------------------
// ispisuje total na vrhu prozora unosa racuna
// ---------------------------------------------------------------------
STATIC FUNCTION _show_total( iznos, popust, row )

   // osvjezi cijene
   @ m_x + row + 0, m_y + ( MAXCOLS() - 12 ) SAY iznos PICT "99999.99" COLOR Invert
   @ m_x + row + 1, m_y + ( MAXCOLS() - 12 ) SAY popust PICT "99999.99" COLOR Invert
   @ m_x + row + 2, m_y + ( MAXCOLS() - 12 ) SAY iznos - popust PICT "99999.99" COLOR Invert

   RETURN



FUNCTION BrisStavNar( oBrowse )

   // Brise stavku narudzbe
   // Koristi privatni parametar OBROWSE iz SHOWBROWSE
   SELECT _pos_pripr

   IF RecCount2() == 0
      MsgBeep ( "Priprema racuna je prazna !!!#Brisanje nije moguce!", 20 )
      RETURN ( DE_REFRESH )
   ENDIF

   Beep ( 2 )

   // ponovo izracunaj ukupno
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




FUNCTION EditStavNar()

   // Vrsi editovanje stavke narudzbe, i to samo artikla ili samo kolicine
   // Koristi privatni parametar OBROWSE iz SHOWBROWSE
   PRIVATE GetList := {}

   SELECT _pos_pripr
   IF RecCount2() == 0
      MsgBeep ( "Narudzba nema nijednu stavku!#Ispravka nije moguca!", 20 )
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
   @ m_x + 3, m_Y + 25  SAY Space( 11 )

   IF LastKey() <> K_ESC
      IF ( _pos_pripr->IdRoba <> _IdRoba ) .OR. roba->tip == "T"
         SELECT ODJ
         HSEEK ROBA->IdOdj
         // LOCATE FOR IdTipMT == ROBA->IdTreb
         IF Found()
            SELECT _pos_pripr
            _RobaNaz := ROBA->Naz
            _JMJ := ROBA->JMJ
            IF !( roba->tip == "T" )
               _Cijena := &( "ROBA->Cijena" + gIdCijena )
            ENDIF
            _IdTarifa := ROBA->IdTarifa
            IF gVodiOdj == "D"
               _IdOdj := ROBA->IdOdj
            ELSE
               _IdOdj := Space( 2 )
            ENDIF

            nIznNar += ( _cijena * _kolicina ) -cijena * kolicina
            nPopust += ( _ncijena * _kolicina )  - ncijena * kolicina
            my_rlock()
            Gather ()
            my_unlock()
         ELSE
            MsgBeep ( "Za robu " + AllTrim ( _IdRoba ) + " nije odredjeno odjeljenje!#" + "Narucivanje nije moguce!!!", 15 )
            SELECT _pos_pripr
            RETURN ( DE_CONT )
         ENDIF
      ENDIF

      IF ( _pos_pripr->Kolicina <> _Kolicina )
         // azuriraj narudzbu
         nIznNar += ( _cijena * _kolicina ) - cijena * kolicina
         nPopust += ( _ncijena * _kolicina ) - ncijena * kolicina
         my_rlock()
         REPLACE Kolicina WITH _Kolicina
         my_unlock()
      ENDIF

   ENDIF

   BoxC()

   // ispisi totale...
   _show_total( nIznNar, nPopust, m_x + 2 )
   ispisi_iznos_veliki_brojevi( ( nIznNar - nPopust ), m_x + ( MAXROWS() - 12 ), MAXCOLS() - 2 )

   oBrowse:refreshCurrent()

   DO WHILE !oBrowse:stable
      oBrowse:Stabilize()
   ENDDO

   RETURN ( DE_CONT )



/*! \fn GetReader2(oGet,GetList,oMenu,aMsg)
 *  \param oGet
 *  \param GetList
 *  \param oMenu
 *  \param aMsg
 */

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
      // De-activate the GET
      oGet:killFocus()
   ENDIF

   RETURN
