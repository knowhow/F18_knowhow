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

MEMVAR m_x, m_y, gcF9usmece

FUNCTION fakt_azuriraj_dokumente_u_pripremi( lSilent )

   LOCAL _a_fakt_doks := {}
   LOCAL _id_firma
   LOCAL _br_dok
   LOCAL _id_tip_dok
   LOCAL _ok
   LOCAL _msg
   LOCAL nI

   IF ( lSilent == nil )
      lSilent := .F.
   ENDIF

   close_open_fakt_tabele()

   IF ( !lSilent .AND. Pitanje( "FAKT_AZUR", "Sigurno želite izvršiti ažuriranje (D/N) ?", "N" ) == "N" )
      RETURN _a_fakt_doks
   ENDIF

   SELECT fakt_pripr
   USE

   o_fakt_pripr()
   GO TOP

   _a_fakt_doks := fakt_dokumenti_pripreme_u_matricu()

   IF Len( _a_fakt_doks ) == 0
      MsgBeep( "Postojeći dokumenti u pripremi već postoje ažurirani u bazi !" )
      RETURN _a_fakt_doks
   ENDIF

   IF Len( _a_fakt_doks ) == 1
      SELECT fakt_pripr
      GO TOP
      IF !provjeri_redni_broj()
         MsgBeep( "Redni brojevi u dokumentu nisu ispravni !" )
         RETURN _a_fakt_doks
      ENDIF
   ENDIF

   DokAttr():New( "fakt", F_FAKT_ATTR ):cleanup_attrs( F_FAKT_PRIPR, _a_fakt_doks )

   _ok := .T.

   MsgO( "Ažuriranje dokumenata u toku ..." )

   FOR nI := 1 TO Len( _a_fakt_doks )

      _id_firma   := _a_fakt_doks[ nI, 1 ]
      _id_tip_dok := _a_fakt_doks[ nI, 2 ]
      _br_dok     := _a_fakt_doks[ nI, 3 ]

      IF fakt_dokument_postoji( _id_firma, _id_tip_dok, _br_dok )
         MsgBeep( "Dokument " + _id_firma + "-" + _id_tip_dok + "-" + AllTrim( _br_dok ) + " već postoji ažuriran u bazi !" )
         _ok := .F.
      ENDIF

      IF _ok .AND. fakt_azur_sql( _id_firma, _id_tip_dok, _br_dok  )

         IF _ok .AND. !fakt_azur_dbf( _id_firma, _id_tip_dok, _br_dok )
            _msg := "Neuspješno DBF ažuriranje dokumenta: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok
            log_write( _msg, 1 )
            MsgBeep( _msg )
            _ok := .F.
         ELSE
            log_write( "F18_DOK_OPER: azuriranje fakt dokumenta: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok, 2 )
         ENDIF

      ELSE
         _msg := "Neuspješno SQL ažuriranje dokumenta: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok
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

   MsgO( "brišem tabele pripreme ..." )

   SELECT fakt_pripr
   my_dbf_zap()
   DokAttr():New( "fakt", F_FAKT_ATTR ):zap_attr_dbf()

   MsgC()

   //my_close_all_dbf()

   RETURN _a_fakt_doks



STATIC FUNCTION _seek_pripr_dok( idfirma, idtipdok, brdok )

   LOCAL _ret := .F.

   o_fakt_pripr()

   SELECT fakt_pripr
   SET ORDER TO TAG "1"
   GO TOP
   SEEK idfirma + idtipdok + brdok

   IF Found()
      _ret := .T.
   ENDIF

   RETURN _ret



STATIC FUNCTION fakt_azur_sql( id_firma, id_tip_dok, br_dok )

   LOCAL _ok
   LOCAL _tbl_fakt, _tbl_doks, _tbl_doks2
   LOCAL _tmp_id
   LOCAL _record
   LOCAL _ids_fakt  := {}
   LOCAL _ids_doks  := {}
   LOCAL _ids_doks2 := {}
   LOCAL oAttr
   LOCAL hParams

   //my_close_all_dbf()

   _tbl_fakt  := "fakt_fakt"
   _tbl_doks  := "fakt_doks"
   _tbl_doks2 := "fakt_doks2"

   Box(, 5, 60 )

   _ok := .T.

   o_fakt_pripr()

   IF !_seek_pripr_dok( id_firma, id_tip_dok, br_dok )
      Alert( "U tabeli pripreme ne postoji dokument: " + id_firma + "-" + id_tip_dok + "-" + br_dok )
      RETURN .F.
   ENDIF


   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fakt_fakt", "fakt_doks", "fakt_doks2" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele.#Prekidam operaciju." )
      RETURN .F.
   ENDIF

   close_open_fakt_tabele()
   _seek_pripr_dok( id_firma, id_tip_dok, br_dok )

   _record := dbf_get_rec()

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
      oAttr := DokAttr():New( "fakt", F_FAKT_ATTR )
      oAttr:hAttrId[ "idfirma" ] := id_firma
      oAttr:hAttrId[ "idtipdok" ] := id_tip_dok
      oAttr:hAttrId[ "brdok" ] := br_dok
      _ok := oAttr:push_attr_from_dbf_to_server()
   ENDIF

   IF !_ok
      run_sql_query( "ROLLBACK" )
   ELSE

      @ m_x + 4, m_y + 2 SAY "push ids to semaphore: " + _tmp_id
      push_ids_to_semaphore( _tbl_fakt, _ids_fakt   )
      push_ids_to_semaphore( _tbl_doks, _ids_doks   )
      push_ids_to_semaphore( _tbl_doks2, _ids_doks2  )

      hParams := hb_Hash()
      hParams[ "unlock" ] :=  { "fakt_fakt", "fakt_doks", "fakt_doks2" }
      run_sql_query( "COMMIT", hParams )


   ENDIF

   BoxC()

   RETURN _ok



STATIC FUNCTION fakt_azur_dbf( id_firma, id_tip_dok, br_dok, lSilent )

   LOCAL _a_memo
   LOCAL _rec
   LOCAL _fakt_totals
   LOCAL _fakt_doks_data
   LOCAL _fakt_doks2_data
   LOCAL _msg

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
   SEEK id_firma + id_tip_dok + br_dok

   IF !Found()

      _rec := get_fakt_doks_data( id_firma, id_tip_dok, br_dok )

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

   _seek_pripr_dok( id_firma, id_tip_dok, br_dok )

   RETURN .T.


/*
   Opis: formira string naziva partnera za tabelu FAKT_DOKS polje "partner"

   Format: naziv adresa, ptt mjesto

   Primjer: "bring.out" d.o.o. Juraja Najtharta 3, 71000 Sarajevo
*/

STATIC FUNCTION naziv_partnera_za_tabelu_doks( cId_partner )

   LOCAL cRet := ""
   LOCAL nDbfArea := Select()

   SELECT ( F_PARTN )
   IF !Used()
      o_partner()
   ENDIF

   select_o_partner( cId_partner )

   cRet := AllTrim( partn->naz )
   cRet += " "
   cRet += AllTrim( partn->adresa )
   cRet += ","
   cRet += AllTrim( partn->ptt )
   cRet += " "
   cRet += AllTrim( partn->mjesto )

   cRet := PadR( cRet, FAKT_DOKS_PARTNER_LENGTH )

   SELECT ( nDbfArea )

   RETURN cRet


/*
   Opis: formira hash string podataka za tabelu FAKT_DOKS2 kod ažuriranja dokumenta
*/

FUNCTION get_fakt_doks2_data( id_firma, id_tip_dok, br_dok )

   LOCAL _fakt_data := hb_Hash()
   LOCAL aMemo

   o_fakt_pripr()
   SELECT fakt_pripr
   GO TOP
   SEEK id_firma + id_tip_dok + br_dok

   _fakt_data[ "idfirma" ]  := field->idfirma
   _fakt_data[ "brdok" ]    := field->brdok
   _fakt_data[ "idtipdok" ] := field->idtipdok

   aMemo := fakt_ftxt_decode( field->txt )

   _fakt_data[ "k1" ] := if( Len( aMemo ) >= 11, aMemo[ 11 ], "" )
   _fakt_data[ "k2" ] := if( Len( aMemo ) >= 12, aMemo[ 12 ], "" )
   _fakt_data[ "k3" ] := if( Len( aMemo ) >= 13, aMemo[ 13 ], "" )
   _fakt_data[ "k4" ] := if( Len( aMemo ) >= 14, aMemo[ 14 ], "" )
   _fakt_data[ "k5" ] := if( Len( aMemo ) >= 15, aMemo[ 15 ], "" )
   _fakt_data[ "n1" ] := if( Len( aMemo ) >= 16, Val( AllTrim( aMemo[ 16 ] ) ), 0 )
   _fakt_data[ "n2" ] := if( Len( aMemo ) >= 17, Val( AllTrim( aMemo[ 17 ] ) ), 0 )

   RETURN _fakt_data


/*
   Opis: formira hash string podataka za tabelu FAKT_DOKS kod ažuriranja dokumenta
*/

FUNCTION get_fakt_doks_data( id_firma, id_tip_dok, br_dok )

   LOCAL _fakt_totals
   LOCAL _fakt_data
   LOCAL aMemo

   _fakt_data := hb_Hash()
   _fakt_data[ "idfirma" ]  := id_firma
   _fakt_data[ "idtipdok" ] := id_tip_dok
   _fakt_data[ "brdok" ]    := br_dok

   o_fakt_pripr()
   SELECT fakt_pripr
   HSEEK id_firma + id_tip_dok + br_dok

   aMemo := fakt_ftxt_decode( field->txt )

   _fakt_data[ "datdok" ]  := field->datdok
   _fakt_data[ "dindem" ]  := field->dindem
   _fakt_data[ "rezerv" ] := " "
   _fakt_data[ "m1" ] := field->m1
   _fakt_data[ "idpartner" ] := field->idpartner
   _fakt_data[ "partner" ] := naziv_partnera_za_tabelu_doks( field->idpartner )
   _fakt_data[ "oper_id" ] := getUserId()
   _fakt_data[ "sifra" ] := Space( 6 )
   _fakt_data[ "brisano" ] := Space( 1 )
   _fakt_data[ "idvrstep" ] := field->idvrstep
   _fakt_data[ "datpl" ] := field->datdok
   _fakt_data[ "idpm" ] := field->idpm
   _fakt_data[ "dat_isp" ]  := iif( Len( aMemo ) >= 7, CToD( aMemo[ 7 ] ), CToD( "" ) )
   _fakt_data[ "dat_otpr" ] := iif( Len( aMemo ) >= 7, CToD( aMemo[ 7 ] ), CToD( "" ) )
   _fakt_data[ "dat_val" ]  := iif( Len( aMemo ) >= 9, CToD( aMemo[ 9 ] ), CToD( "" ) )
   _fakt_data[ "fisc_rn" ] := field->fisc_rn
   _fakt_data[ "fisc_st" ] := 0
   _fakt_data[ "fisc_date" ] := CToD( "" )
   _fakt_data[ "fisc_time" ] := PadR( "", 10 )

   _fakt_totals := izracunaj_ukupni_iznos_dokumenta_iz_pripreme( id_firma, id_tip_dok, br_dok )

   _fakt_data[ "iznos" ] := _fakt_totals[ "iznos" ]
   _fakt_data[ "rabat" ] := _fakt_totals[ "rabat" ]

   RETURN _fakt_data



/*
   Opis: izračunava vrijednost dokumenta iz tabele pripreme FAKT_PRIPR za polja
           FAKT_DOKS->IZNOS
           FAKT_DOKS->RABAT

   Returns:
       hash matrica sljedećih članova
              _fakt_total["iznos"]
              _fakt_total["rabat"]
*/

FUNCTION izracunaj_ukupni_iznos_dokumenta_iz_pripreme( id_firma, id_tipdok, br_dok )

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


/*
   Opis: vraća dokumente iz pripreme u matricu u formatu:

        array[ idfirma, idtipdok, brdok ]

   Napomena: u pripremi može biti više dokumenata
*/

FUNCTION fakt_dokumenti_pripreme_u_matricu()

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
         SKIP
      ENDDO

      IF !fakt_dokument_postoji( _id_firma, _id_tip_dok, _br_dok )
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


  select_o_fakt_objekti()


   IF glDistrib = .T.
      //SELECT F_RELAC
      IF !Used()
         //o_relac()
        // O_VOZILA
         //O_KALPOS
      ENDIF
   ENDIF

   o_vrstep()
   o_ops()
   //select_o_konto()
   o_sastavnica()
   //select_o_partner()
   //select_o_roba()
   o_fakt_txt()
   //o_tarifa()
   o_valute()
   o_fakt_doks2()
   o_fakt_doks()
   //o_rj()
   //o_sifk()
   //o_sifv()

   IF lOpenFaktAsPripr == .T.

      SELECT F_FAKT
      IF !Used()
         O_PFAKT
      ENDIF

   ELSE
      o_fakt_pripr()
      o_fakt()
   ENDIF

   SELECT fakt_pripr
   SET ORDER TO TAG "1"
   GO TOP

   RETURN NIL




FUNCTION fakt_sredi_redni_broj_u_pripremi()

   LOCAL _t_rec, _rec
   LOCAL _firma, _broj, _tdok
   LOCAL _cnt

   o_fakt_pripr()
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






FUNCTION fakt_brisanje_pripreme()

   LOCAL _id_firma, _tip_dok, _br_dok
   LOCAL oAttr

   IF Pitanje(, D_ZELITE_LI_IZBRISATI_PRIPREMU, "N" ) == "D"

      SELECT fakt_pripr
      GO TOP

      _id_firma := field->IdFirma
      _tip_dok := field->IdTipDok
      _br_dok := field->BrDok

      oAttr := DokAttr():new( "fakt", F_FAKT_ATTR )
      oAttr:hAttrId[ "idfirma" ] := _id_firma
      oAttr:hAttrId[ "idtipdok" ] := _tip_dok
      oAttr:hAttrId[ "brdok" ] := _br_dok

      IF gcF9usmece == "D"
         oAttr:delete_attr_from_dbf()
         azuriraj_smece( .T. )
         log_write( "F18_DOK_OPER: fakt, prenosa dokumenta iz pripreme u smece: " + _id_firma + "-" + _tip_dok + "-" + _br_dok, 2 )
         SELECT fakt_pripr
      ELSE
         my_dbf_zap()
         oAttr:zap_attr_dbf()
         log_write( "F18_DOK_OPER: fakt, brisanje dokumenta iz pripreme: " + _id_firma + "-" + _tip_dok + "-" + _br_dok, 2 )
         fakt_reset_broj_dokumenta( _id_firma, _tip_dok, _br_dok )
      ENDIF

   ENDIF

   RETURN .T.


FUNCTION fakt_generisi_storno_dokument( id_firma, id_tip_dok, br_dok )

   LOCAL _novi_br_dok
   LOCAL _rec
   LOCAL _count
   LOCAL _fiscal_no
   LOCAL _fiscal_use := fiscal_opt_active()

   IF Pitanje( "FORM_STORNO", "Formirati storno dokument (D/N) ?", "D" ) == "N"
      RETURN .F.
   ENDIF

   o_fakt_pripr()
   SELECT fakt_pripr

   IF fakt_pripr->( RECCOUNT2() ) <> 0
      MsgBeep( "Priprema nije prazna !" )
      RETURN .F.
   ENDIF

   o_fakt()
   o_fakt_doks()
   o_roba()
   o_partner()

   _novi_br_dok := AllTrim( br_dok ) + "/S"

   IF Len( AllTrim( _novi_br_dok ) ) > 8
      _novi_br_dok := Right( AllTrim( br_dok ), 6 ) + "/S"
   ENDIF

   _count := 0

   SELECT fakt_doks
   SET ORDER TO TAG "1"
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
      MsgBeep( "Formiran je dokument " + id_firma + "-" + ;
         id_tip_dok + "-" + AllTrim( _novi_br_dok ) + ;
         " u pripremi !" )
   ENDIF

   RETURN .T.
