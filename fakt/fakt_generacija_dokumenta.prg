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


#include "fakt.ch"

// staticke varijable
STATIC __generisati := .F.



FUNCTION GDokInv( cIdRj )

   LOCAL cIdRoba
   LOCAL cBrDok
   LOCAL nUl
   LOCAL nIzl
   LOCAL nRezerv
   LOCAL nRevers
   LOCAL nRbr
   LOCAL lFoundUPripremi

   O_FAKT_DOKS
   O_ROBA
   O_TARIFA
   O_FAKT_PRIPR
   SET ORDER TO TAG "3"

   O_FAKT
   MsgO( "scaniram tabelu fakt" )
   nRbr := 0

   GO TOP
   cBrDok := PadR( Replicate( "0", gNumDio ), 8 )

   DO WHILE !Eof()
      IF ( field->idFirma <> cIdRj )
         SKIP
         LOOP
      ENDIF
      SELECT fakt_pripr
      cIdRoba := fakt->idRoba
      // vidi imali ovo u pripremi; ako ima stavka je obradjena
      SEEK cIdRj + cIdRoba
      lFoundUPripremi := Found()
      SELECT fakt
      PushWa()
      IF !( lFoundUPripremi )
         fakt_stanje_artikla( cIdRj, cIdroba, @nUl, @nIzl, @nRezerv, @nRevers, .T. )
         IF ( nUl - nIzl - nRevers ) <> 0
            SELECT fakt_pripr
            nRbr++
            ShowKorner( nRbr, 10 )
            cRbr := RedniBroj( nRbr )
            ApndInvItem( cIdRj, cIdRoba, cBrDok, nUl - nIzl - nRevers, cRbr )
         ENDIF
      ENDIF
      PopWa()
      SKIP
   ENDDO
   MsgC()

   my_close_all_dbf()

   RETURN




STATIC FUNCTION ApndInvItem( cIdRj, cIdRoba, cBrDok, nKolicina, cRbr )

   APPEND BLANK
   REPLACE idFirma WITH cIdRj
   REPLACE idRoba  WITH cIdRoba
   REPLACE datDok  WITH Date()
   REPLACE idTipDok WITH "IM"
   REPLACE serBr   WITH Str( nKolicina, 15, 4 )
   REPLACE kolicina WITH nKolicina
   REPLACE rBr WITH cRbr

   IF Val( cRbr ) == 1
      cTxt := ""
      AddTxt( @cTxt, "" )
      AddTxt( @cTxt, "" )
      AddTxt( @cTxt, gNFirma )
      AddTxt( @cTxt, "RJ:" + cIdRj )
      AddTxt( @cTxt, gMjStr )
      REPLACE txt WITH cTxt
   ENDIF

   REPLACE brDok WITH cBrDok
   REPLACE dinDem WITH ValDomaca()

   SELECT roba
   SEEK cIdRoba

   SELECT fakt_pripr
   REPLACE cijena WITH roba->vpc

   RETURN


STATIC FUNCTION AddTxt( cTxt, cStr )

   cTxt := cTxt + Chr( 16 ) + cStr + Chr( 17 )

   RETURN NIL





/*! \fn GDokInvManjak(cIdRj, cBrDok)
 *  \param cIdRj - oznaka firme dokumenta IM na osnovu kojeg se generise dok.19
 *  \param cBrDok - broj dokumenta IM na osnovu kojeg se generise dok.19
 *  \brief Generacija dokumenta 19 tj. otpreme iz mag na osnovu dok. IM
 */
FUNCTION GDokInvManjak( cIdRj, cBrDok )

   LOCAL nRBr
   LOCAL nRazlikaKol
   LOCAL cRBr
   LOCAL cNoviBrDok

   nRBr := 0

   O_FAKT
   O_FAKT_PRIPR
   O_ROBA

   cNoviBrDok := PadR( Replicate( "0", gNumDio ), 8 )

   SELECT fakt
   SET ORDER TO TAG "1"
   HSEEK cIdRj + "IM" + cBrDok

   DO WHILE ( !Eof() .AND. cIdRj + "IM" + cBrDok == fakt->( idFirma + idTipDok + brDok ) )
      nRazlikaKol := Val( fakt->serBr ) -fakt->kolicina
      IF ( Round( nRazlikaKol, 5 ) > 0 )
         SELECT roba
         HSEEK fakt->idRoba
         SELECT fakt_pripr
         nRBr++
         cRBr := RedniBroj( nRBr )
         ApndInvMItem( cIdRj, fakt->idRoba, cNoviBrDok, nRazlikaKol, cRBr )
      ENDIF
      SELECT fakt
      SKIP 1
   ENDDO

   IF ( nRBr > 0 )
      MsgBeep( "U pripremu je izgenerisan dokument otpreme manjka " + cIdRj + "-19-" + cNoviBrDok )
   ELSE
      MsgBeep( "Inventurom nije evidentiran manjak pa nije generisan nikakav dokument!" )
   ENDIF

   my_close_all_dbf()

   RETURN




/*! \fn ApndInvMItem(cIdRj, cIdRoba, cBrDok, nKolicina, cRbr)
 *  \param cIdRj - oznaka firme dokumenta
 *  \param cIdRoba - sifra robe
 *  \param cBrDok - broj dokumenta
 *  \param nKolicina - kolicina tj.manjak
 *  \param cRbr - redni broj stavke
 *  \brief Dodavanje stavke dokumenta 19 za evidentiranje manjka po osnovu inventure
 */

STATIC FUNCTION ApndInvMItem( cIdRj, cIdRoba, cBrDok, nKolicina, cRbr )

   APPEND BLANK
   REPLACE idFirma WITH cIdRj
   REPLACE idRoba  WITH cIdRoba
   REPLACE datDok  WITH Date()
   REPLACE idTipDok WITH "19"
   REPLACE serBr   WITH ""
   REPLACE kolicina WITH nKolicina
   REPLACE rBr WITH cRbr

   IF ( Val( cRbr ) == 1 )
      cTxt := ""
      AddTxt( @cTxt, "" )
      AddTxt( @cTxt, "" )
      AddTxt( @cTxt, gNFirma )
      AddTxt( @cTxt, "RJ:" + cIdRj )
      AddTxt( @cTxt, gMjStr )
      REPLACE txt WITH cTxt
   ENDIF

   REPLACE brDok WITH cBrDok
   REPLACE dinDem WITH ValDomaca()
   REPLACE cijena WITH roba->vpc

   RETURN





/*! \fn GDokInvVisak(cIdRj, cBrDok)
 *  \param cIdRj - oznaka firme dokumenta IM na osnovu kojeg se generise dok.19
 *  \param cBrDok - broj dokumenta IM na osnovu kojeg se generise dok.19
 *  \brief Generacija dokumenta 01 tj.primke u magacin na osnovu dok. IM
 */
FUNCTION GDokInvVisak( cIdRj, cBrDok )

   LOCAL nRBr
   LOCAL nRazlikaKol
   LOCAL cRBr
   LOCAL cNoviBrDok

   nRBr := 0

   O_FAKT
   O_FAKT_PRIPR
   O_ROBA

   cNoviBrDok := PadR( Replicate( "0", gNumDio ), 8 )

   SELECT fakt
   SET ORDER TO TAG "1"
   HSEEK cIdRj + "IM" + cBrDok
   DO WHILE ( !Eof() .AND. cIdRj + "IM" + cBrDok == fakt->( idFirma + idTipDok + brDok ) )
      nRazlikaKol := Val( fakt->serBr ) -fakt->kolicina
      IF ( Round( nRazlikaKol, 5 ) < 0 )
         SELECT roba
         HSEEK fakt->idRoba
         SELECT fakt_pripr
         nRBr++
         cRBr := RedniBroj( nRBr )
         ApndInvVItem( cIdRj, fakt->idRoba, cNoviBrDok, -nRazlikaKol, cRBr )
      ENDIF
      SELECT fakt
      SKIP 1
   ENDDO

   IF ( nRBr > 0 )
      MsgBeep( "U pripremu je izgenerisan dokument dopreme viska " + cIdRj + "-01-" + cNoviBrDok )
   ELSE
      MsgBeep( "Inventurom nije evidentiran visak pa nije generisan nikakav dokument!" )
   ENDIF

   my_close_all_dbf()

   RETURN





/*! \fn ApndInvVItem(cIdRj, cIdRoba, cBrDok, nKolicina, cRbr)
 *  \param cIdRj - oznaka firme dokumenta
 *  \param cIdRoba - sifra robe
 *  \param cBrDok - broj dokumenta
 *  \param nKolicina - kolicina tj.visak
 *  \param cRbr - redni broj stavke
 *  \brief Dodavanje stavke dokumenta 01 za evidentiranje viska po osnovu inventure
 */

STATIC FUNCTION ApndInvVItem( cIdRj, cIdRoba, cBrDok, nKolicina, cRbr )

   APPEND BLANK
   REPLACE idFirma WITH cIdRj
   REPLACE idRoba  WITH cIdRoba
   REPLACE datDok  WITH Date()
   REPLACE idTipDok WITH "01"
   REPLACE serBr   WITH ""
   REPLACE kolicina WITH nKolicina
   REPLACE rBr WITH cRbr

   IF ( Val( cRbr ) == 1 )
      cTxt := ""
      AddTxt( @cTxt, "" )
      AddTxt( @cTxt, "" )
      AddTxt( @cTxt, gNFirma )
      AddTxt( @cTxt, "RJ:" + cIdRj )
      AddTxt( @cTxt, gMjStr )
      REPLACE txt WITH cTxt
   ENDIF

   REPLACE brDok WITH cBrDok
   REPLACE dinDem WITH ValDomaca()
   REPLACE cijena WITH roba->vpc

   RETURN





// ----------------------------------------------
// pretvaranje otpremnice u fakturu
// ----------------------------------------------
FUNCTION fakt_generisi_racun_iz_otpremnice()

   LOCAL _id_partner
   LOCAL _suma := 0
   LOCAL _veza_otpr := ""
   LOCAL _datum_max := Date()
   LOCAL _ok
   LOCAL _lock_user := ""
   LOCAL _lock_param := "fakt_otpremnice_lock_user"

   SELECT fakt_pripr
   USE

   O_FAKT_PRIPR
   GO TOP

   // ako je priprema prazna
   IF RecCount2() <> 0
      fakt_generisi_racun_iz_pripreme()
      SELECT fakt_pripr
      RETURN .T.
   ENDIF

   // mogu li koristiti opciju ?
   // radi problema u mrežnom radu... #29996 problem
   _lock_user := AllTrim( fetch_metric( _lock_param, NIL, "" ) )

   IF !Empty( _lock_user )
      MsgBeep( "Opciju pretvaranja koristi (" + _lock_user + "), pokusajte ponovo !!!" )
      SELECT fakt_pripr
      RETURN .T.
   ENDIF

   // setuj parametar da se opcija koristi
   set_metric( _lock_param, NIL, f18_user() )

   SELECT fakt_doks
   SET ORDER TO TAG "2"
   // idfirma+idtipdok+partner

   ImeKol := {}
   // browsuj tip dokumenta
   AAdd( ImeKol, { "TD",     {|| idtipdok }   } )
   AAdd( ImeKol, { "Broj",   {|| brdok }  } )
   AAdd( ImeKol, { "Datdok",  {|| datdok  }  } )
   AAdd( ImeKol, { "Partner", {|| Left( partner, 20 ) }  } )
   AAdd( ImeKol, { "Iznos",   {|| Str( iznos, 11, 2 ) }  } )
   AAdd( ImeKol, { "Marker",  {|| m1 }  } )

   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   _otpr_tip := "12"
   _firma := gFirma
   _suma := 0
   _partn_naz := Space( 20 )

   Box(, 20, 75 )

   @ m_x + 1, m_y + 2 SAY "PREGLED OTPREMNICA:"
   @ m_x + 3, m_y + 2 SAY "Radna jedinica" GET  _firma PICT "@!"
   @ m_x + 3, Col() + 2 SAY "Naziv partnera - kljucni dio:" GET _partn_naz PICT "@!"

   READ

   _partn_naz := Trim( _partn_naz )

   SEEK _firma + _otpr_tip

   IF !f18_lock_tables( { "fakt_doks" }, .F. )

      // ukini lock opcije
      set_metric( _lock_param, NIL, "" )

      close_open_fakt_tabele()
      select_fakt_pripr()
      BoxC()

      MsgBeep( "Neuspješno lokovanje tabele !!!" )

      RETURN .T.

   ENDIF

   sql_table_update( nil, "BEGIN" )

   DO WHILE !Eof() .AND. field->idfirma + field->idtipdok = _firma + _otpr_tip
      IF field->m1 <> "Z"

         _rec := dbf_get_rec()
         _rec[ "m1" ] := " "

         IF !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )

            f18_free_tables( { "fakt_doks" } )
            sql_table_update( nil, "ROLLBACK" )

            set_metric( _lock_param, NIL, "" )

            close_open_fakt_tabele()
            SELECT fakt_pripr

            BoxC()

            MsgBeep( "Ne mogu setovati markere za otpremnice !!!" )

            RETURN .T.

         ENDIF

      ENDIF
      SKIP

   ENDDO

   f18_free_tables( { "fakt_doks" } )
   sql_table_update( nil, "END" )

   SEEK _firma + _otpr_tip

   BrowseKey( m_x + 5, m_y + 1, m_x + 19, m_y + 73, ImeKol, ;
      {| ch| EdOtpr( ch, @_suma ) }, "idfirma+idtipdok = _firma + _otpr_tip", ;
      _firma + _otpr_tip, 2, , , {|| partner = _partn_naz } )

   BoxC()

   IF __generisati .AND. Pitanje(, "Formirati fakturu na osnovu gornjih otpremnica ?", "N" ) == "D"

      _ok := _formiraj_racun( _firma, _otpr_tip, _partn_naz, @_veza_otpr, @_datum_max )

      // ovdje vec smijem ukinuti lock opciju... racun je formiran i nalazi se u priremi
      set_metric( _lock_param, NIL, "" )

      IF _ok
         // ovdje ce se setovati jos i parametri dokumenta...
         // datum otpremnice, datum valute... destinacija itd...
         SELECT fakt_pripr
         renumeracija_fakt_pripr( _veza_otpr, _datum_max )
      ENDIF

      SELECT fakt_doks
      SET ORDER TO TAG "1"

   ELSE
      // ukini lock opcije
      // korisnik je odabrao da nece koristi opcije pretvaranja
      set_metric( _lock_param, NIL, "" )
   ENDIF

   close_open_fakt_tabele()
   SELECT fakt_pripr

   RETURN .T.


// -----------------------------------------------------------
// generise racun na osnovu podataka iz pripreme
// -----------------------------------------------------------
FUNCTION fakt_generisi_racun_iz_pripreme()

   LOCAL _novi_tip, _tip_dok, _br_dok
   LOCAL _t_rec

   IF !( field->idtipdok $ "12#20#13#01#27" )
      Msg( "Ova opcija je za promjenu 20,12,13 -> 10 i 27 -> 11 " )
      RETURN .F.
   ENDIF

   IF field->idtipdok = "27"
      _novi_tip := "11"
   ELSEIF field->idtipdok = "01"
      _novi_tip := "19"
   ELSE
      _novi_tip := "10"
   ENDIF

   IF Pitanje(, "Želite li dokument pretvoriti u " + _novi_tip + " ? (D/N)", "D" ) == "N"
      RETURN .F.
   ENDIF

   Box(, 5, 60 )

   _tip_dok := field->idtipdok
   _br_dok := PadR( Replicate( "0", 5 ), 8 )

   SELECT fakt_pripr
   PushWa()

   GO TOP
   _t_rec := 0

   my_flock()

   DO WHILE !Eof()

      SKIP
      _t_rec := RecNo()
      SKIP -1

      REPLACE field->brdok WITH _br_dok
      REPLACE field->idtipdok WITH _novi_tip
      REPLACE field->datdok WITH Date()

      IF _tip_dok == "12"
         // otpremnica u racun ???
         REPLACE serbr WITH "*"
      ENDIF

      IF _tip_dok == "13"
         REPLACE kolicina WITH -kolicina
      ENDIF

      GO ( _t_rec )
   	
   ENDDO

   my_unlock()

   PopWa()

   BoxC()

   IsprUzorTxt()

   RETURN .T.




FUNCTION EdOtpr( ch, suma )

   LOCAL cDn := "N"
   LOCAL nRet := DE_CONT

   DO CASE

   CASE Ch == Asc( " " ) .OR. Ch == K_ENTER

      IF !f18_lock_tables( { "fakt_doks" }, .F. )
         MsgBeep( "Ne mogu postaviti lock, neko drugi koristi opciju..." )
         RETURN DE_CONT
      ENDIF

      sql_table_update( nil, "BEGIN" )

      Beep( 1 )

      _rec := dbf_get_rec()

      IF field->m1 = " "

         __generisati := .T.

         _rec[ "m1" ] := "*"

         IF !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )
            f18_free_tables( { "fakt_doks" } )
            sql_table_update( nil, "ROLLBACK" )
            MsgBeep( "Nisam uspio setovati marker, neko vec koristi opciju..." )
            RETURN DE_CONT
         ENDIF

         suma += field->iznos

      ELSE

         _rec[ "m1" ] := " "

         IF !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )
            f18_free_tables( { "fakt_doks" } )
            sql_table_update( nil, "ROLLBACK" )
            MsgBeep( "Nisam uspio setovati marker, neko vec koristi opciju..." )
            RETURN DE_CONT
         ENDIF

         suma -= field->iznos

      ENDIF

      @ m_x + 1, m_Y + 55 SAY suma PICT picdem

      nRet := DE_REFRESH

      f18_free_tables( { "fakt_doks" } )
      sql_table_update( nil, "END" )

   ENDCASE

   RETURN nRet



// ------------------------------------------------------
// generacija podataka, forma parametara
// ------------------------------------------------------
STATIC FUNCTION gen_vars( params )

   LOCAL _ok := .T.
   LOCAL _sumiraj := "N"
   LOCAL _tip_rn := 1

   params := hb_Hash()

   Box(, 6, 65 )

   @ m_x + 1, m_y + 2 SAY "Sumirati stavke otpremnica (D/N) ?" GET _sumiraj ;
      VALID _sumiraj $ "DN" ;
      PICT "@!"

   @ m_x + 3, m_y + 2 SAY "Formirati tip racuna: 1 (veleprodaja)"
   @ m_x + 4, m_y + 2 SAY "                      2 (veleprodaja)" GET _tip_rn ;
      VALID ( _tip_rn > 0 .AND. _tip_rn < 3 ) ;
      PICT "9"

   READ

   BoxC()

   IF LastKey() == K_ESC
      _ok := .F.
      RETURN _ok
   ENDIF

   // snimi mi u matricu parametre
   params[ "tip_racuna" ] := _tip_rn
   params[ "sumiraj" ] := _sumiraj

   RETURN _ok


// --------------------------------------------------------------
// formiranje racuna
// --------------------------------------------------------------
STATIC FUNCTION _formiraj_racun( firma, otpr_tip, partn_naz, veza_otpr, datum_max )

   LOCAL _sumirati := .F.
   LOCAL _vp_mp := 1
   LOCAL _n_tip_dok, _dat_max, _t_rec, _t_fakt_rec
   LOCAL _veza_otpremnice, _broj_dokumenta
   LOCAL _id_partner, _rec
   LOCAL _ok := .T.
   LOCAL _gen_params
   LOCAL oAtrib

   _broj_dokumenta := fakt_prazan_broj_dokumenta()

   // parametri generisanja...
   IF !gen_vars( @_gen_params )
      RETURN .F.
   ENDIF

   // uzmi parametre matrice...
   _sumirati := _gen_params[ "sumiraj" ] == "D"
   _vp_mp := _gen_params[ "tip_racuna" ]

   IF _vp_mp == 1
      _n_tip_dok := "10"
   ELSE
      _n_tip_dok := "11"
   ENDIF

   _veza_otpremnice := ""

   SELECT fakt_doks
   SEEK firma + otpr_tip + partn_naz

   _dat_max := CToD( "" )

   IF !f18_lock_tables( { "fakt_doks", "fakt_fakt" }, .F. )
      MsgBeep( "Neuspjesno lokovanje tabela !!!!" )
      RETURN .F.
   ENDIF

   sql_table_update( nil, "BEGIN" )

   DO WHILE !Eof() .AND. field->idfirma + field->idtipdok = firma + otpr_tip ;
         .AND. fakt_doks->partner = partn_naz

      SKIP
      _t_rec := RecNo()
      SKIP -1

      IF field->m1 = "*"

         _id_partner := fakt_doks->idpartner

         IF _dat_max < fakt_doks->datdok
            _dat_max := fakt_doks->datdok
         ENDIF

         _postojeci_iznos := fakt_doks->iznos
         _veza_otpremnice += AllTrim( fakt_doks->brdok ) + ", "

         // promijeni naslov
         // skini zvjezdicu iz browsa
         _rec := dbf_get_rec()

         // postojeci podaci dokumenta
         __post_tip_dok := _rec[ "idtipdok" ]
         __post_id_firma := _rec[ "idfirma" ]
         __post_broj := _rec[ "brdok" ]
         __novi_broj := __post_broj

         // mjenjamo ih u realizovanu otpremnicu
         _rec[ "idtipdok" ] := "22"
         _rec[ "m1" ] := " "

         // novi tip dokumenta
         __novi_tip_dok := _rec[ "idtipdok" ]

         __t_rec := RecNo()

         _postoji := .T.

         DO WHILE _postoji
            // vidi za broj dokumenta da li je ok ?
            IF fakt_doks_exist( __post_id_firma, __novi_tip_dok, __novi_broj )
               __novi_broj := fakt_novi_broj_dokumenta( __post_id_firma, __novi_tip_dok, "" )
            ELSE
               _postoji := .F.
               EXIT
            ENDIF
         ENDDO

         _rec[ "brdok" ] := __novi_broj

         SELECT fakt_doks
         SET ORDER TO TAG "2"
         GO ( __t_rec )

         IF !update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )
            f18_free_tables( { "fakt_doks", "fakt_fakt" } )
            sql_table_update( nil, "ROLLBACK" )
            MsgBeep( "Nisam uspio zavrsiti promjenu na tabeli fakt_doks !!!" )
            RETURN .F.
         ENDIF

         // ovo je novi broj dokumenta
         dxIdFirma := fakt_doks->idfirma
         dxBrDok   := fakt_doks->brdok

         SELECT fakt_doks
         SET ORDER TO TAG "1"

         _params := hb_Hash()
         _params[ "old_firma" ] := dxIdFirma
         _params[ "old_tipdok" ] := "12"
         _params[ "old_brdok" ] := __post_broj
         _params[ "new_firma" ] := dxIdFirma
         _params[ "new_tipdok" ] := "22"
         _params[ "new_brdok" ] := __novi_broj

         oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )

         IF !oAtrib:update_atrib_from_server( _params )
            f18_free_tables( { "fakt_doks", "fakt_fakt" } )
            sql_table_update( nil, "ROLLBACK" )
            MsgBeep( "Nisam uspio napraviti promjene na tabeli fakt_fakt_atributi !!!" )
            RETURN .F.
         ENDIF

         SELECT fakt
         SEEK dxIdFirma + "12" + __post_broj

         DO WHILE !Eof() .AND. ( dxIdFirma + "12" + __post_broj ) == ;
               ( field->idfirma + field->idtipdok + field->brdok )

            SKIP
            _t_fakt_rec := RecNo()
            SKIP -1

            _fakt_rec := dbf_get_rec()
            _fakt_rec[ "idtipdok" ] := "22"
            _fakt_rec[ "brdok" ] := dxBrDok

            IF !update_rec_server_and_dbf( "fakt_fakt", _fakt_rec, 1, "CONT" )
               f18_free_tables( { "fakt_doks", "fakt_fakt" } )
               sql_table_update( nil, "ROLLBACK" )
               MsgBeep( "Nisam uspio zavrsiti promjenu na tabeli fakt_fakt !!!" )
               RETURN .F.
            ENDIF

            _fakt_rec := dbf_get_rec()
            _fakt_rec[ "brdok" ] := _broj_dokumenta
            _fakt_rec[ "datdok" ] := Date()
            _fakt_rec[ "m1" ] := "X"
            _fakt_rec[ "idtipdok" ] := _n_tip_dok

            IF _vp_mp == 2
               // radi se o mp racunu, izracunaj cijenu sa pdv
               _fakt_rec[ "cijena" ] := Round( _uk_sa_pdv( field->idtipdok, field->idpartner, field->cijena ), 2 )
            ENDIF

            SELECT fakt_pripr
            LOCATE FOR idroba == fakt->idroba

            IF Found() .AND. _sumirati == .T. .AND. Round( fakt_pripr->cijena, 2 ) = Round( fakt->cijena, 2 )
               _fakt_rec[ "kolicina" ] := fakt_pripr->kolicina + fakt->kolicina
            ELSE
               APPEND BLANK
            ENDIF

            dbf_update_rec( _fakt_rec )

            SELECT fakt

            GO ( _t_fakt_rec )

         ENDDO

      ENDIF

      SELECT fakt_doks
      SET ORDER TO TAG "2"

      GO ( _t_rec )

   ENDDO

   f18_free_tables( { "fakt_doks", "fakt_fakt" } )
   sql_table_update( nil, "END" )

   IF !Empty( _veza_otpremnice )

      _veza_otpremnice := "Racun formiran na osnovu otpremnica: " + ;
         Left ( _veza_otpremnice, Len ( _veza_otpremnice ) - 2 ) + "."

      veza_otpr := _veza_otpremnice
      datum_max := _dat_max

   ENDIF

   RETURN _ok





FUNCTION Iz22u10()

   LOCAL cIdFirma := gFirma
   LOCAL cVDok := "22"
   LOCAL cBrojDokumenta := Space( 8 )
   LOCAL cPFirma
   LOCAL cPVDok
   LOCAL cPBrDok
   LOCAL nRbr
   LOCAL cEditYN := "N"

   Box(, 5, 60 )
   @ m_x + 1, m_y + 2 SAY "Prebaci iz 22 u 10:"
   @ m_x + 2, m_y + 2 SAY "----------------------------"
   @ m_x + 3, m_y + 2 SAY "Dokument:" GET cIdFirma
   @ m_x + 3, m_y + 14 SAY "-" GET cVDok
   @ m_x + 3, m_y + 19 SAY "-" GET cBrojDokumenta
   @ m_x + 5, m_y + 2 SAY "Pitaj prije ispravke stavke (D/N)" GET cEditYN VALID cEditYN $ "DN" PICT "@!"
   READ
   BoxC()


   IF LastKey() == K_ESC
      RETURN .T.
   ENDIF

   IF ( Empty( cIdFirma ) .OR. Empty( cVDok ) .OR. Empty( cBrojDokumenta ) )
      MsgBeep( "Nisu popunjena sva polja !!!" )
      RETURN .T.
   ENDIF

   SELECT fakt_pripr
   GO BOTTOM
   nRbr := Val( field->rbr ) + 1

   cPFirma := field->idfirma
   cPVDok := field->idtipdok
   cPBrDok := field->brdok
   dDatDok := field->datdok
   cIdPartn := field->idpartner

   O_FAKT
   // prvo pogledaj da li dokument postoji u FAKT
   SELECT fakt
   SET ORDER TO TAG "1"
   SEEK cIdFirma + cVDok + cBrojDokumenta

   IF !Found()
      MsgBeep( "Dokument: " + Trim( cIdFirma ) + "-" + Trim( cPVDok ) + "-" + Trim( cPBrDok ) + " ne postoji!!!" )
      SELECT fakt_pripr
      RETURN .T.
   ELSE
      Box(, 4, 70 )
      // brojaci dodatih i editovanih stavki
      nEdit := 0
      nAdd := 0
      // pocni popunjavati !!!
      DO WHILE !Eof() .AND. field->idfirma = cIdFirma .AND. field->idtipdok = cVDok .AND. field->brdok = cBrojDokumenta
         cIdRoba := field->idroba
         nKolicina := field->kolicina
         @ m_x + 1, m_y + 2 SAY "Trazim artikal: " + Trim( cIdRoba )
         SELECT fakt_pripr
         GO TOP
         SET ORDER TO TAG "3"
         SEEK cIdFirma + cIdRoba
         IF Found()
            IF ( cEditYN == "D" .AND. Pitanje( "Ispraviti kolicinu za artikal " + Trim( cIdRoba ), "D" ) == "N" )
               SELECT fakt
               SKIP
               LOOP
            ENDIF
            @ m_x + 2, m_y + 2 SAY "Status: Ispravljam stavku  "
            Scatter()
            _kolicina += nKolicina
            my_rlock()
            Gather()
            my_unlock()
            nEdit++
            SELECT fakt
            SKIP
         ELSE
            @ m_x + 2, m_y + 2 SAY "Status: Dodajem novu stavku"
            APPEND BLANK
            REPLACE idfirma WITH cPFirma
            REPLACE idtipdok WITH cPVDok
            REPLACE brdok WITH cPBrDok
            REPLACE rbr WITH Right( Str( nRbr ), 3 )
            REPLACE idroba WITH fakt->idroba
            REPLACE dindem WITH fakt->dindem
            REPLACE zaokr WITH fakt->zaokr
            REPLACE kolicina WITH fakt->kolicina
            REPLACE cijena WITH fakt->cijena
            REPLACE rabat WITH fakt->rabat
            REPLACE porez WITH fakt->porez
            REPLACE serbr WITH fakt->serbr
            REPLACE idpartner WITH cIdPartn
            REPLACE datdok WITH dDatdok
            nAdd++
            SELECT fakt
            SKIP
         ENDIF
         @ m_x + 3, m_y + 2 SAY "Ispravio stavki  :" + Str( nEdit )
         @ m_x + 4, m_y + 2 SAY "Dodao novi stavki:" + Str( nAdd )
      ENDDO
      BoxC()
   ENDIF

   MsgBeep( "Dodao: " + Str( nAdd ) + ", ispravio: " + Str( nEdit ) + " stavki" )

   SELECT fakt_pripr

   RETURN .T.
