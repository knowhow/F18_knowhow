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

// --------------------------------------------------
// centralna funkcija za azuriranje fakture
// --------------------------------------------------
FUNCTION azur_fakt( lSilent )

   LOCAL _a_fakt_doks := {}
   LOCAL _id_firma
   LOCAL _br_dok
   LOCAL _id_tip_dok
   LOCAL _ok
   LOCAL _tbl_fakt  := "fakt_fakt"
   LOCAL _tbl_doks  := "fakt_doks"
   LOCAL _tbl_doks2 := "fakt_doks2"
   LOCAL _msg
   LOCAL oAtrib

   IF ( lSilent == nil )
      lSilent := .F.
   ENDIF

   close_open_fakt_tabele()

   IF ( !lSilent .AND. Pitanje( "FAKT_AZUR", "Sigurno želite izvršiti ažuriranje (D/N) ?", "N" ) == "N" )
      RETURN _a_fakt_doks
   ENDIF

   SELECT fakt_pripr
   USE

   O_FAKT_PRIPR
   GO TOP

   // ubaci mi matricu sve dokumente iz pripreme
   _a_fakt_doks := fakt_dokumenti_u_pripremi()

   IF Len( _a_fakt_doks ) == 0
      MsgBeep( "Postojeci dokumenti u pripremi vec postoje azurirani u bazi !" )
      RETURN _a_fakt_doks
   ENDIF

   // ako je samo jedan dokument provjeri njegove redne brojeve
   IF Len( _a_fakt_doks ) == 1
      SELECT fakt_pripr
      GO TOP
      // provjeri redne brojeve dokumenta
      IF !provjeri_redni_broj()
         MsgBeep( "Redni brojevi u dokumentu nisu ispravni !!!" )
         RETURN _a_fakt_doks
      ENDIF
   ENDIF

   // fiksiranje tabele atributa
   F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB ):fix_atrib( F_FAKT_PRIPR, _a_fakt_doks )

   _ok := .T.

   MsgO( "Azuriranje dokumenata u toku ..." )

   // prodji kroz matricu sa dokumentima i azuriraj ih
   FOR _i := 1 TO Len( _a_fakt_doks )

      _id_firma   := _a_fakt_doks[ _i, 1 ]
      _id_tip_dok := _a_fakt_doks[ _i, 2 ]
      _br_dok     := _a_fakt_doks[ _i, 3 ]

      // provjeri da li postoji vec identican broj azuriran u bazi ?
      IF fakt_doks_exist( _id_firma, _id_tip_dok, _br_dok )
         MsgBeep( "Dokument " + _id_firma + "-" + _id_tip_dok + "-" + AllTrim( _br_dok ) + " vec postoji azuriran u bazi !" )
         _ok := .F.
      ENDIF

      IF _ok .AND. fakt_azur_sql( _id_firma, _id_tip_dok, _br_dok  )

         IF _ok .AND. !fakt_azur_dbf( _id_firma, _id_tip_dok, _br_dok )
            _msg := "ERROR DBF: Neuspjesno FAKT/DBF azuriranje: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok
            log_write( _msg, 1 )
            MsgBeep( _msg )
            _ok := .F.
         ELSE
            log_write( "F18_DOK_OPER: azuriranje fakt dokumenta: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok, 2 )
         ENDIF

      ELSE
         _msg := "ERROR SQL: Neuspjesno SQL azuriranje: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok
         log_write( _msg, 1 )
         MsgBeep( _msg )
         _ok := .F.
      ENDIF

   NEXT

   MsgC()

   IF !_ok
      RETURN _a_fakt_doks
   ENDIF

   SELECT fakt_pripr

   MsgO( "brisem pripremu...." )

   SELECT fakt_pripr
   my_dbf_zap()

   // pobrisi mi fakt_atribute takodjer
   F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB ):zapp_local_table()

   MsgC()

   my_close_all_dbf()

   RETURN _a_fakt_doks


// -----------------------------------------------------------------
// seek dokumenta u pripremi
// -----------------------------------------------------------------
STATIC FUNCTION _seek_pripr_dok( idfirma, idtipdok, brdok )

   LOCAL _ret := .F.

   O_FAKT_PRIPR

   SELECT fakt_pripr
   SET ORDER TO TAG "1"
   GO TOP
   SEEK idfirma + idtipdok + brdok

   IF Found()
      _ret := .T.
   ENDIF

   RETURN _ret



// --------------------------------------------------------------
// azuriranje u sql tabele
// --------------------------------------------------------------
STATIC FUNCTION fakt_azur_sql( id_firma, id_tip_dok, br_dok )

   LOCAL _ok
   LOCAL _tbl_fakt, _tbl_doks, _tbl_doks2
   LOCAL _i, _n
   LOCAL _tmp_id, _tmp_doc
   LOCAL _ids := {}
   LOCAL _ids_tmp := {}
   LOCAL _ids_doc := {}
   LOCAL _fakt_doks_data
   LOCAL _fakt_doks2_data
   LOCAL _fakt_totals
   LOCAL _record
   LOCAL _msg
   LOCAL _ids_fakt  := {}
   LOCAL _ids_doks  := {}
   LOCAL _ids_doks2 := {}
   LOCAL oAtrib

   my_close_all_dbf()

   _tbl_fakt  := "fakt_fakt"
   _tbl_doks  := "fakt_doks"
   _tbl_doks2 := "fakt_doks2"

   Box(, 5, 60 )

   _ok := .T.

   O_FAKT_PRIPR

   // vidi ima li tog dokumenta u pripremi !
   // svakako mi se nastimaj na taj record
   IF !_seek_pripr_dok( id_firma, id_tip_dok, br_dok )
      Alert( "ne kontam u fakt_pripr nema: " + id_firma + "-" + id_tip_dok + "-" + br_dok )
      RETURN .F.
   ENDIF

   // lokuj prvo tabele
   IF !f18_lock_tables( { "fakt_fakt", "fakt_doks", "fakt_doks2" } )
      RETURN .F.
   ENDIF


   close_open_fakt_tabele()
   // opet se vrati na ovaj slog koji mi treba
   _seek_pripr_dok( id_firma, id_tip_dok, br_dok )

   // -----------------------------------------------------------------------------------------------------
   sql_table_update( nil, "BEGIN" )

   // uzmi potrebni record
   _record := dbf_get_rec()

   // algoritam 2 - dokument nivo
   _tmp_id := _record[ "idfirma" ] + _record[ "idtipdok" ] + _record[ "brdok" ]
   AAdd( _ids_fakt, "#2" + _tmp_id )

   @ m_x + 1, m_y + 2 SAY "fakt_fakt -> server: " + _tmp_id

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idtipdok == id_tip_dok .AND. field->brdok == br_dok
      _record := dbf_get_rec()
      IF !sql_table_update( "fakt_fakt", "ins", _record )
         _ok := .F.
         EXIT
      ENDIF
      SKIP
   ENDDO

   MsgO( "FAKT - ažuriranje stavki 30sec" )
   sleep(30)

   IF _ok == .T.
      @ m_x + 2, m_y + 2 SAY "fakt_doks -> server: " + _tmp_id
      AAdd( _ids_doks, _tmp_id )
      SELECT fakt_pripr
      _record := get_fakt_doks_data( id_firma, id_tip_dok, br_dok )
      IF !sql_table_update( "fakt_doks", "ins", _record )
         _ok := .F.
      ENDIF
   ENDIF

   IF _ok == .T.
      @ m_x + 3, m_y + 2 SAY "fakt_doks2 -> server: " + _tmp_id
      AAdd( _ids_doks2, _tmp_id )
      _record := get_fakt_doks2_data( id_firma, id_tip_dok, br_dok )
      SELECT fakt_pripr
      IF !sql_table_update( "fakt_doks2", "ins", _record )
         _ok := .F.
      ENDIF
   ENDIF

   IF _ok == .T.
      @ m_x + 4, m_y + 2 SAY "fakt_atributi -> server "
      oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )
      oAtrib:dok_hash[ "idfirma" ] := id_firma
      oAtrib:dok_hash[ "idtipdok" ] := id_tip_dok
      oAtrib:dok_hash[ "brdok" ] := br_dok
      _ok := oAtrib:atrib_dbf_to_server()
   ENDIF

   IF !_ok
      _msg := "FAKT sql azuriranje, trasakcija " + _tmp_id + " neuspjesna ?!"
      log_write( _msg, 2 )
      MsgBeep( _msg )
      // transakcija neuspjesna
      // server nije azuriran
      sql_table_update( nil, "ROLLBACK" )

      // ako je transakcja neuspjesna, svejedno trebas osloboditi tabele
      f18_free_tables( { "fakt_fakt", "fakt_doks", "fakt_doks2" } )

   ELSE

      @ m_x + 4, m_y + 2 SAY "push ids to semaphore: " + _tmp_id

      push_ids_to_semaphore( _tbl_fakt, _ids_fakt   )
      push_ids_to_semaphore( _tbl_doks, _ids_doks   )
      push_ids_to_semaphore( _tbl_doks2, _ids_doks2  )

      f18_free_tables( { "fakt_fakt", "fakt_doks", "fakt_doks2" } )
      sql_table_update( nil, "END" )

   ENDIF

   BoxC()

   RETURN _ok




// -------------------------------------------------------------------
// azuriranje u dbf tabele
// -------------------------------------------------------------------
STATIC FUNCTION fakt_azur_dbf( id_firma, id_tip_dok, br_dok, lSilent )

   LOCAL _a_memo
   LOCAL _rec
   LOCAL _fakt_totals
   LOCAL _fakt_doks_data
   LOCAL _fakt_doks2_data

   close_open_fakt_tabele()

   Box( "#Proces ažuriranja dbf-a u toku", 3, 60 )

   @ m_x + 1, m_y + 2 SAY "fakt_pripr -> fakt_fakt"

   _seek_pripr_dok( id_firma, id_tip_dok, br_dok )

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idtipdok == id_tip_dok .AND. field->brdok == br_dok

      SELECT fakt_pripr
      _rec := dbf_get_rec()

      SELECT fakt
      APPEND BLANK
      dbf_update_rec( _rec, .T. )

      SELECT fakt_pripr
      SKIP

   ENDDO

   @ m_x + 2, m_y + 2 SAY "fakt_doks " + id_firma + id_tip_dok + br_dok

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_tip_dok + br_dok

   IF !Found()

      _rec := get_fakt_doks_data( id_firma, id_tip_dok, br_dok )

      // pobrisi sljedece clanove...
      hb_HDel( _rec, "brisano" )
      hb_HDel( _rec, "sifra" )

      SELECT fakt_doks
      APPEND BLANK

      dbf_update_rec( _rec, .T. )

   ELSE

      _msg := "ERR: " + RECI_GDJE_SAM0 + " postoji zapis u fakt_doks : " + id_firma + id_tip_dok + br_dok
      Alert( _msg )
      log_write( _msg, 5 )

   ENDIF


   @ m_x + 3, m_y + 2 SAY "fakt_doks2 " + id_firma + id_tip_dok + br_dok

   SELECT fakt_doks2
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_tip_dok + br_dok

   IF !Found()

      _rec := get_fakt_doks2_data( id_firma, id_tip_dok, br_dok )

      SELECT fakt_doks2
      APPEND BLANK

      dbf_update_rec( _rec, .T. )

   ELSE
      _msg := "ERR: " + RECI_GDJE_SAM0 + " postoji zapis u fakt_doks2 : " + id_firma + id_tip_dok + br_dok
      Alert( _msg )
      log_write( _msg, 5 )
   ENDIF

   BoxC()

   // opet seekuj pripremu
   _seek_pripr_dok( id_firma, id_tip_dok, br_dok )

   RETURN .T.


STATIC FUNCTION _fakt_partner_naziv( id_partner )

   LOCAL _return := ""
   LOCAL _t_area := Select()

   SELECT ( F_PARTN )
   IF !Used()
      O_PARTN
   ENDIF

   SELECT partn
   GO TOP
   hseek id_partner

   // priprema podatke za upis u polje "doks->partner"
   _return := AllTrim( partn->naz )
   _return += " "
   _return += AllTrim( partn->adresa )
   _return += ","
   _return += AllTrim( partn->ptt )
   _return += " "
   _return += AllTrim( partn->mjesto )

   _return := PadR( _return, FAKT_DOKS_PARTNER_LENGTH )

   SELECT ( _t_area )

   RETURN _return


// -------------------------------------------------------------
// vraca hash matricu za fakt_doks2
// -------------------------------------------------------------
FUNCTION get_fakt_doks2_data( id_firma, id_tip_dok, br_dok )

   LOCAL _fakt_data := hb_Hash()
   LOCAL _memo

   O_FAKT_PRIPR
   SELECT fakt_pripr
   GO TOP
   SEEK id_firma + id_tip_dok + br_dok

   _fakt_data[ "idfirma" ]  := field->idfirma
   _fakt_data[ "brdok" ]    := field->brdok
   _fakt_data[ "idtipdok" ] := field->idtipdok

   _memo := ParsMemo( field->txt )

   _fakt_data[ "k1" ] := if( Len( _memo ) >= 11, _memo[ 11 ], "" )
   _fakt_data[ "k2" ] := if( Len( _memo ) >= 12, _memo[ 12 ], "" )
   _fakt_data[ "k3" ] := if( Len( _memo ) >= 13, _memo[ 13 ], "" )
   _fakt_data[ "k4" ] := if( Len( _memo ) >= 14, _memo[ 14 ], "" )
   _fakt_data[ "k5" ] := if( Len( _memo ) >= 15, _memo[ 15 ], "" )
   _fakt_data[ "n1" ] := if( Len( _memo ) >= 16, Val( AllTrim( _memo[ 16 ] ) ), 0 )
   _fakt_data[ "n2" ] := if( Len( _memo ) >= 17, Val( AllTrim( _memo[ 17 ] ) ), 0 )

   RETURN _fakt_data


// -------------------------------------------------------------
// -------------------------------------------------------------
FUNCTION get_fakt_doks_data( id_firma, id_tip_dok, br_dok )

   LOCAL _fakt_totals
   LOCAL _fakt_data
   LOCAL _memo

   // definiši matricu za fakt_doks zapis
   _fakt_data := hb_Hash()
   _fakt_data[ "idfirma" ]  := id_firma
   _fakt_data[ "idtipdok" ] := id_tip_dok
   _fakt_data[ "brdok" ]    := br_dok

   O_FAKT_PRIPR
   // sljedeća polja ću uzeti iz pripreme
   SELECT fakt_pripr
   HSEEK id_firma + id_tip_dok + br_dok

   _memo := ParsMemo( field->txt )

   _fakt_data[ "datdok" ]  := field->datdok
   _fakt_data[ "dindem" ]  := field->dindem
   _fakt_data[ "rezerv" ] := " "
   _fakt_data[ "m1" ] := field->m1
   _fakt_data[ "idpartner" ] := field->idpartner
   _fakt_data[ "partner" ] := _fakt_partner_naziv( field->idpartner )
   _fakt_data[ "oper_id" ] := getUserId()
   _fakt_data[ "sifra" ] := Space( 6 )
   _fakt_data[ "brisano" ] := Space( 1 )
   _fakt_data[ "idvrstep" ] := field->idvrstep
   _fakt_data[ "datpl" ] := field->datdok
   _fakt_data[ "idpm" ] := field->idpm
   _fakt_data[ "dat_isp" ]  := iif( Len( _memo ) >= 7, CToD( _memo[ 7 ] ), CToD( "" ) )
   _fakt_data[ "dat_otpr" ] := iif( Len( _memo ) >= 7, CToD( _memo[ 7 ] ), CToD( "" ) )
   _fakt_data[ "dat_val" ]  := iif( Len( _memo ) >= 9, CToD( _memo[ 9 ] ), CToD( "" ) )

   // ovo nema nikakvog smisla. fisc_rn uvijek postoji u F18
   // takođe mi mije jasno zašto se ne uzmu oba polja onakva kakva jesu ?
   // ovdje uopšte mi nije jasna ova zbrka koja se pravi sa fisc_rn i fisc_st poljima
   // non stop se nešto gleda bez ikakve potrebe
   // u fisc_rn treba biti broj fiskalnog račun.

   // ako se radi o reklamoranom (storno računu) onda sadržan treba biti
   // fisc_rn - originalni račun koji se reklamira, fisc_st - broj reklamiranog računa

   _fakt_data[ "fisc_rn" ] := field->fisc_rn
   _fakt_data[ "fisc_st" ] := 0
   _fakt_data[ "fisc_date" ] := CToD( "" )
   _fakt_data[ "fisc_time" ] := PadR( "", 10 )

   // izracunaj totale za fakturu
   _fakt_totals := calculate_fakt_total( id_firma, id_tip_dok, br_dok )

   // ubaci u fakt_doks totale
   _fakt_data[ "iznos" ] := _fakt_totals[ "iznos" ]
   _fakt_data[ "rabat" ] := _fakt_totals[ "rabat" ]

   RETURN _fakt_data



// ----------------------------------------------------------
// kalkulise ukupno za fakturu
// ----------------------------------------------------------
FUNCTION calculate_fakt_total( id_firma, id_tipdok, br_dok )

   LOCAL _fakt_total := hb_Hash()
   LOCAL _cij_sa_por := 0
   LOCAL _rabat := 0
   LOCAL _uk_sa_rab := 0
   LOCAL _uk_rabat := 0
   LOCAL _dod_por := 0
   LOCAL _din_dem

   SELECT fakt_pripr
   GO TOP
   SEEK id_firma + id_tipdok + br_dok

   _din_dem := field->dindem

   DO WHILE !Eof() .AND. field->idfirma == id_firma .AND. field->idtipdok == id_tipdok .AND. field->brdok == br_dok

      IF _din_dem == Left( ValBazna(), 3 )

         _cij_sa_por := Round( field->kolicina * field->cijena * PrerCij() * ( 1 - field->rabat / 100 ), ZAOKRUZENJE )
         _rabat := Round( field->kolicina * field->cijena * PrerCij() * field->rabat / 100, ZAOKRUZENJE )
         _dod_por := Round( _cij_sa_por * field->porez / 100, ZAOKRUZENJE )

      ELSE

         _cij_sa_por := Round( field->kolicina * field->cijena * ;
            PrerCij() * ( 1 - field->Rabat / 100 ), ZAOKRUZENJE )

         _rabat := Round( field->kolicina * field->cijena * ;
            PrerCij() * field->rabat / 100, ZAOKRUZENJE )

         _dod_por := Round( _cij_sa_por * field->porez / 100, ZAOKRUZENJE )

      ENDIF

      _uk_sa_rab += _cij_sa_por + _dod_por
      _uk_rabat += _rabat

      SKIP

   ENDDO

   _fakt_total[ "iznos" ] := _uk_sa_rab
   _fakt_total[ "rabat" ] := _uk_rabat

   RETURN _fakt_total



// -----------------------------------
// vise dokumenata u pripremi
// ----------------------------------
FUNCTION fakt_dokumenti_u_pripremi()

   LOCAL _fakt_doks := {}
   LOCAL _id_firma
   LOCAL _id_tip_dok
   LOCAL _br_dok

   SELECT fakt_pripr
   GO TOP

   DO WHILE !Eof()

      _id_firma := field->idfirma
      _id_tip_dok := field->idtipdok
      _br_dok := field->brdok

      DO WHILE !Eof() .AND. ( field->idfirma + field->idtipdok + field->brdok ) == ;
            ( _id_firma + _id_tip_dok + _br_dok )
         // preskoci sve stavke
         SKIP
      ENDDO

      // provjeri da li postoji vec identican broj azuriran u bazi ?
      IF !fakt_doks_exist( _id_firma, _id_tip_dok, _br_dok )
         AAdd( _fakt_doks, { _id_firma, _id_tip_dok, _br_dok } )
      ENDIF

      SELECT fakt_pripr

   ENDDO

   RETURN _fakt_doks


FUNCTION close_open_fakt_tabele( lOpenFaktAsPripr )

   my_close_all_dbf()

   IF lOpenFaktAsPripr == NIL
      lOpenFaktAsPripr := .F.
   ENDIF

   SELECT ( F_FAKT_OBJEKTI )
   IF !Used()
      O_FAKT_OBJEKTI
   ENDIF

   IF glDistrib = .T.
      SELECT F_RELAC
      IF !Used()
         O_RELAC
         O_VOZILA
         O_KALPOS
      ENDIF
   ENDIF

   O_VRSTEP
   O_OPS
   O_KONTO
   O_SAST
   O_PARTN
   O_ROBA
   O_FTXT
   O_TARIFA
   O_VALUTE
   O_FAKT_DOKS2
   O_FAKT_DOKS
   O_RJ
   O_SIFK
   O_SIFV

   IF lOpenFaktAsPripr == .T.

      SELECT F_FAKT
      IF !Used()
         O_PFAKT
      ENDIF

   ELSE
      O_FAKT_PRIPR
      O_FAKT
   ENDIF

   SELECT fakt_pripr
   SET ORDER TO TAG "1"
   GO TOP

   RETURN NIL




FUNCTION SrediRbrFakt()

   LOCAL _t_rec, _rec
   LOCAL _firma, _broj, _tdok
   LOCAL _cnt

   O_FAKT_PRIPR
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()
	
      _firma := field->idfirma
      _tdok  := field->idtipdok
      _broj  := field->brdok
      _cnt   := 0

      DO WHILE !Eof() .AND. field->idfirma == _firma .AND. field->idtipdok == _tdok .AND. field->brdok == _broj
					
         SKIP 1
		
         _t_rec := RecNo()

         SKIP -1

         _rec := dbf_get_rec()
         _rec[ "rbr" ] := PadL( AllTrim( Str( ++_cnt ) ), 3, 0 )
         dbf_update_rec( _rec )

         GO ( _t_rec )
	
      ENDDO

   ENDDO

   RETURN 0






// ------------------------------------------------
// ------------------------------------------------
FUNCTION fakt_brisanje_pripreme()

   LOCAL _id_firma, _tip_dok, _br_dok
   LOCAL oAtrib

   IF !( ImaPravoPristupa( goModul:oDataBase:cName, "DOK", "BRISANJE" ) )
      MsgBeep( cZabrana )
      RETURN DE_CONT
   ENDIF

   IF Pitanje(, "Želite li izbrisati pripremu !!????", "N" ) == "D"

      SELECT fakt_pripr
      GO TOP

      _id_firma := IdFirma
      _tip_dok := IdTipDok
      _br_dok := BrDok

      oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )
      oAtrib:dok_hash[ "idfirma" ] := _id_firma
      oAtrib:dok_hash[ "idtipdok" ] := _tip_dok
      oAtrib:dok_hash[ "brdok" ] := _br_dok

      IF gcF9usmece == "D"

         // pobrisi i atribute...
         oAtrib:delete_atrib()

         // azuriraj dokument u smece
         azuriraj_smece( .T. )

         log_write( "F18_DOK_OPER: fakt, prenosa dokumenta iz pripreme u smece: " + _id_firma + "-" + _tip_dok + "-" + _br_dok, 2 )

         SELECT fakt_pripr

      ELSE

         // ponisti pripremu...
         my_dbf_zap()
         // ponisti i atribut        // ponisti i atributee
         oAtrib:zapp_local_table()

         log_write( "F18_DOK_OPER: fakt, brisanje dokumenta iz pripreme: " + _id_firma + "-" + _tip_dok + "-" + _br_dok, 2 )

         // potreba za resetom brojaca ?
         fakt_reset_broj_dokumenta( _id_firma, _tip_dok, _br_dok )

      ENDIF

   ENDIF

   RETURN


// ---------------------------------------------------
// generisi storno dokument u pripremi
// ---------------------------------------------------
FUNCTION storno_dok( id_firma, id_tip_dok, br_dok )

   LOCAL _novi_br_dok
   LOCAL _rec
   LOCAL _count
   LOCAL _fiscal_no
   LOCAL _fiscal_use := fiscal_opt_active()

   IF Pitanje( "FORM_STORNO", "Formirati storno dokument ?", "D" ) == "N"
      RETURN
   ENDIF

   O_FAKT_PRIPR
   SELECT fakt_pripr

   IF fakt_pripr->( RECCOUNT2() ) <> 0
      msgbeep( "Priprema nije prazna !!!" )
      RETURN
   ENDIF

   O_FAKT
   O_FAKT_DOKS
   O_ROBA
   O_PARTN

   _novi_br_dok := AllTrim( br_dok ) + "/S"

   IF Len( AllTrim( _novi_br_dok ) ) > 8

      // otkini prva dva karaktera
      // da moze stati "/S"
      _novi_br_dok := Right( AllTrim( br_dok ), 6 ) + "/S"

   ENDIF

   _count := 0

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_tip_dok + br_dok

   _fiscal_no := 0

   IF _fiscal_use
      _fiscal_no := field->fisc_rn
   ENDIF

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + id_tip_dok + br_dok

   DO WHILE !Eof() .AND. field->idfirma == id_firma  .AND. field->idtipdok == id_tip_dok .AND. field->brdok == br_dok

      _rec := dbf_get_rec()

      SELECT fakt_pripr
      APPEND BLANK

      _rec[ "kolicina" ] := ( _rec[ "kolicina" ] * -1 )
      _rec[ "brdok" ] := _novi_br_dok
      _rec[ "datdok" ] := Date()

      // obavezno resetuj vrstu placanja na gotovina...
      _rec[ "idvrstep" ] := ""

      IF _fiscal_use
         _rec[ "fisc_rn" ] := _fiscal_no
      ENDIF

      dbf_update_rec( _rec )

      SELECT fakt
      SKIP

      ++ _count

   ENDDO

   IF _count > 0
      msgbeep( "Formiran je dokument " + id_firma + "-" + ;
         id_tip_dok + "-" + AllTrim( _novi_br_dok ) + ;
         " u pripremi !" )
   ENDIF

   RETURN
