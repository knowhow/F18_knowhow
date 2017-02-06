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

FUNCTION fakt_stanje_artikla( cIdRj, cIdroba, nUl, nIzl, nRezerv, nRevers, lSilent )

   IF ( lSilent == nil )
      lSilent := .F.
   ENDIF

   SELECT fakt
   SET ORDER TO TAG "3"

   IF ( !lSilent )
      lBezMinusa := .F.
   ENDIF

   IF ( roba->tip == "U" )
      RETURN 0
   ENDIF

   IF ( !lSilent )
      MsgO( "Izračunavam trenutno stanje artikla ..." )
   ENDIF

   SEEK cIdRoba

   nUl := 0
   nIzl := 0
   nRezerv := 0
   nRevers := 0

   DO WHILE ( !Eof() .AND. cIdRoba == field->idRoba )
      IF ( fakt->idFirma <> cIdRj )
         SKIP
         LOOP
      ENDIF
      IF ( Left( field->idTipDok, 1 ) == "0" )
         // ulaz
         nUl += kolicina
      ELSEIF ( Left( field->idTipDok, 1 ) == "1" )
         // izlaz faktura
         IF !( Left( field->serBr, 1 ) == "*" .AND. field->idTipDok == "10" )
            nIzl += field->kolicina
         ENDIF
      ELSEIF ( field->idTipDok $ "20#27" )
         IF ( Left( field->serBr, 1 ) == "*" )
            nRezerv += field->kolicina
         ENDIF
      ELSEIF ( field->idTipDok == "21" )
         nRevers += field->kolicina
      ENDIF
      SKIP
   ENDDO

   IF ( !lSilent )
      MsgC()
   ENDIF

   RETURN


FUNCTION fakt_mpc_iz_sifrarnika()

   LOCAL nCV := 0

   IF rj->( FieldPos( "tip" ) ) <> 0

      IF RJ->tip == "N1"
         nCV := roba->nc
      ELSEIF RJ->tip == "M1"
         nCV := roba->mpc
      ELSEIF RJ->tip == "M2"
         nCV := roba->mpc2
      ELSEIF RJ->tip == "M3"
         nCV := roba->mpc3
      ELSEIF RJ->tip == "M4"
         nCV := roba->mpc4
         // ELSEIF RJ->tip == "M5"
         // nCV := roba->mpc5
         // ELSEIF RJ->tip == "M6"
         // nCV := roba->mpc6
      ELSE
         nCV := roba->vpc
      ENDIF
   ELSE
      nCV := roba->vpc
   ENDIF

   RETURN nCV



FUNCTION fakt_vpc_iz_sifrarnika()

   LOCAL nCV := 0

   IF rj->tip == "V1"
      nCV := roba->vpc
   ELSEIF rj->tip == "V2"
      nCV := roba->vpc2
   ELSE
      nCV := roba->vpc
   ENDIF

   RETURN nCV



// ----------------------------------------------
// napuni sifrarnik sifk  sa poljem za unos
// podatka o PDV oslobadjanju
// ---------------------------------------------
FUNCTION fill_part()

   LOCAL lFound
   LOCAL cSeek
   LOCAL cNaz
   LOCAL cId
   LOCAL cOznaka

   SELECT ( F_SIFK )
   o_sifk()
   SET ORDER TO TAG "ID"
   cId := PadR( "PARTN", 8 )
   cNaz := PadR( "PDV oslob. ZPDV", Len( naz ) )
   cRbr := "08"
   cOznaka := "PDVO"
   add_n_found( cId, cNaz, cRbr, cOznaka, 3 )

   SELECT ( F_SIFK )
   o_sifk()
   SET ORDER TO TAG "ID"
   cId := PadR( "PARTN", 8 )
   cNaz := PadR( "Profil partn.", Len( naz ) )
   cRbr := "09"
   cOznaka := "PROF"
   add_n_found( cId, cNaz, cRbr, cOznaka, 25 )

   RETURN


// -------------------------------------------
// -------------------------------------------
STATIC FUNCTION add_n_found( cId, cNaz, cRbr, cOznaka, nDuzina )

   LOCAL cSeek, _rec

   cSeek :=  cId + cRbr + cNaz
   SEEK cSeek

   IF !Found()
      APPEND BLANK
      REPLACE id WITH cId, ;
         naz WITH cNaz, ;
         oznaka WITH cOznaka, ;
         SORT WITH  cRbr, ;
         veza WITH "1", ;
         tip WITH "C", ;
         duzina WITH nDuzina, ;
         f_decimal WITH 0
      _rec := dbf_get_rec()
      update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
      RETURN .T.
   ENDIF

   RETURN .F.


// ----------------------------------------------------------
// vraca numericki dio za broj dokumenta iz parametra
// ----------------------------------------------------------
FUNCTION fakt_brdok_numdio()
   RETURN fetch_metric( "fakt_numericki_dio_dokumenta", NIL, 5 )


// ------------------------------------------------------------
// resetuje brojač dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
FUNCTION fakt_reset_broj_dokumenta( cIdFirma, cIdTipDok, broj_dokumenta )

   LOCAL _param
   LOCAL _broj := 0

   // param: fakt/10/10
   _param := "fakt" + "/" + cIdFirma + "/" + cIdTipDok
   _broj := fetch_metric( _param, nil, _broj )

   IF Val( PadR( broj_dokumenta, fakt_brdok_numdio() ) ) == _broj
      -- _broj
      // smanji globalni brojac za 1
      set_metric( _param, nil, _broj )
   ENDIF

   RETURN .T.



// ---------------------------------------------------------------
// vraca prazan broj dokumenta
// ---------------------------------------------------------------
FUNCTION fakt_prazan_broj_dokumenta()
   RETURN PadR( PadL( AllTrim( Str( 0 ) ), fakt_brdok_numdio(), "0" ), 8 )



// ------------------------------------------------------------------
// fakt, uzimanje novog broja za fakt dokument
// ------------------------------------------------------------------
FUNCTION fakt_novi_broj_dokumenta( cIdFirma, cIdTipDok, sufiks )

   LOCAL _broj := 0
   LOCAL _broj_doks := 0
   LOCAL _param
   LOCAL _tmp, _rest
   LOCAL _ret := ""
   LOCAL nDbfArea := Select()
   LOCAL _num_dio := fakt_brdok_numdio()

   IF sufiks == nil
      sufiks := ""
   ENDIF

   // param: fakt/10/10
   _param := "fakt" + "/" + cIdFirma + "/" + cIdTipDok
   _broj := fetch_metric( _param, nil, _broj )

   // konsultuj i doks uporedo
   seek_fakt_doks( cIdFirma, cIdTipDok )
   //o_fakt_doks()
   //SET ORDER TO TAG "1"
   //GO TOP
   //SEEK cIdFirma + cIdTipDok + "Ž"
   //SKIP -1
   GO BOTTOM

   IF field->idfirma == cIdFirma .AND. field->idtipdok == cIdTipDok
      _broj_doks := Val( PadR( field->brdok, _num_dio ) )
   ELSE
      _broj_doks := 0
   ENDIF


   _broj := Max( _broj, _broj_doks ) // uzmi sta je vece, doks broj ili globalni brojac
   ++ _broj // uvecaj broj

   // ovo ce napraviti string prave duzine...
   _ret := PadL( AllTrim( Str( _broj ) ), _num_dio, "0" )

   IF !Empty( sufiks )
      _ret := _ret + sufiks
   ENDIF

   _ret := PadR( _ret, 8 )
   set_metric( _param, nil, _broj ) // upisi ga u globalni parametar

   SELECT ( nDbfArea )

   RETURN _ret


// ------------------------------------------------------------
// setuj broj dokumenta u pripremi ako treba !
// ------------------------------------------------------------
FUNCTION fakt_set_broj_dokumenta()

   LOCAL _broj_dokumenta
   LOCAL _t_rec
   LOCAL _firma, _td, _null_brdok
   LOCAL _fakt_params := fakt_params()
   LOCAL oAttr

   PushWA()

   SELECT fakt_pripr
   GO TOP

   _null_brdok := PadR( Replicate( "0", fakt_brdok_numdio() ), 8 )
   _firma := field->idfirma
   _td := field->idtipdok

   // brojaci otpremnica po tip-u "22"
   IF _td == "12" .AND. _fakt_params[ "fakt_otpr_22_brojac" ]
      _tip_srch := "22"
   ELSE
      _tip_srch := _td
   ENDIF

   IF field->brdok <> _null_brdok
      // nemam sta raditi, broj je vec setovan
      PopWa()
      RETURN .F.
   ENDIF

   // daj mi novi broj dokumenta
   _broj_dokumenta := fakt_novi_broj_dokumenta( _firma, _tip_srch )

   SELECT fakt_pripr
   SET ORDER TO TAG "1"
   GO TOP

   my_flock()
   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      IF field->idfirma == _firma .AND. field->idtipdok == _td .AND. field->brdok == _null_brdok
         REPLACE field->brdok WITH _broj_dokumenta
      ENDIF

      GO ( _t_rec )

   ENDDO
   my_unlock()

   oAttr := DokAttr():new( "fakt", F_FAKT_ATTR )
   oAttr:open_attr_dbf()

   SET ORDER TO TAG "1"
   GO TOP

   my_flock()
   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      IF field->idfirma == _firma .AND. field->idtipdok == _td .AND. field->brdok == _null_brdok
         REPLACE field->brdok WITH _broj_dokumenta
      ENDIF

      GO ( _t_rec )

   ENDDO
   my_unlock()

   USE

   PopWa()

   RETURN .T.


// -----------------------------------------------------------
// provjerava postoji li rupa u brojacu dokumenata
// -----------------------------------------------------------
FUNCTION fakt_postoji_li_rupa_u_brojacu( id_firma, id_tip_dok, priprema_broj )

   LOCAL _ret := 0
   LOCAL _qry, _table
   LOCAL _max_dok, _par_dok, _param
   LOCAL _params := fakt_params()
   LOCAL _tip_srch, _tmp
   LOCAL _inc_error

   // .... parametar ako treba
   IF !_params[ "kontrola_brojaca" ]
      RETURN _ret
   ENDIF

   // brojaci otpremnica po tip-u "22"
   IF id_tip_dok == "12" .AND. _params[ "fakt_otpr_22_brojac" ]
      _tip_srch := "22"
   ELSE
      _tip_srch := id_tip_dok
   ENDIF

   _qry := " SELECT MAX( brdok ) FROM " + F18_PSQL_SCHEMA_DOT + "fakt_doks " + ;
      " WHERE idfirma = " + sql_quote( id_firma ) + ;
      " AND idtipdok = " + sql_quote( _tip_srch )


   _table := run_sql_query( _qry )
   _dok := _table:FieldGet( 1 )
   _tmp := TokToNiz( _dok, "/" )
   _max_dok := Val( AllTrim( _tmp[ 1 ] ) )

   // ovo je iz parametara...
   // param: fakt/10/10
   _param := "fakt" + "/" + id_firma + "/" + _tip_srch
   _par_dok := fetch_metric( _param, nil, 0 )

   // provjera brojaca server dokument <> server param
   _inc_error := _par_dok - _max_dok

   IF _inc_error > 30

      // eto greske !!!!
      MsgBeep( "Postoji greska sa brojacem dokumenta#Dokumenti: " + AllTrim( Str( _max_dok ) ) + ;
         ", parametri: " + AllTrim( Str( _par_dok ) ) + "#" + ;
         "Provjerite brojac" )
      _ret := 1
      RETURN _ret

   ENDIF

   // provjera priprema <> server
   _tmp := TokToNiz( priprema_broj, "/" )
   _inc_error := Abs( _max_dok - Val( AllTrim( _tmp[ 1 ] ) ) )

   IF _inc_error > 30

      MsgBeep( "Postoji greška sa brojačem dokumenta#Priprema: " + AllTrim( priprema_broj ) + ;
         ", server dokument: " + AllTrim( Str( _max_dok ) ) + "#" + ;
         "Provjerite brojač" )
      _ret := 1
      RETURN _ret

   ENDIF

   RETURN _ret



FUNCTION fakt_dokument_postoji( cFirma, cTipDok, cBroj )

   LOCAL lExist := .F.
   LOCAL cWhere

   cWhere := " idfirma = " + sql_quote( cFirma )
   cWhere += " AND idtipdok = " + sql_quote( cTipDok )
   cWhere += " AND brdok = " + sql_quote( cBroj )

   IF table_count( F18_PSQL_SCHEMA_DOT + "fakt_doks", cWhere ) > 0
      lExist := .T.
   ENDIF

   IF !lExist
      IF table_count( F18_PSQL_SCHEMA_DOT + "fakt_fakt", cWhere ) > 0
         lExist := .T.
      ENDIF
   ENDIF

   RETURN lExist


FUNCTION fakt_set_param_broj_dokumenta()

   LOCAL _param
   LOCAL _broj := 0
   LOCAL _broj_old
   LOCAL _firma := self_organizacija_id()
   LOCAL _tip_dok := "10"

   Box(, 2, 60 )

   @ m_x + 1, m_y + 2 SAY "Dokument:" GET _firma
   @ m_x + 1, Col() + 1 SAY "-" GET _tip_dok

   READ

   IF LastKey() == K_ESC
      BoxC()
      RETURN
   ENDIF

   // param: fakt/10/10
   _param := "fakt" + "/" + _firma + "/" + _tip_dok
   _broj := fetch_metric( _param, nil, _broj )
   _broj_old := _broj

   @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "999999"

   READ

   BoxC()

   IF LastKey() != K_ESC
      // snimi broj u globalni brojac
      IF _broj <> _broj_old
         set_metric( _param, nil, _broj )
      ENDIF
   ENDIF

   RETURN



FUNCTION fakt_admin_menu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. podesavanje brojaca dokumenta " )
   AAdd( _opcexe, {|| fakt_set_param_broj_dokumenta() } )
   AAdd( _opc, "2. fakt export (r_exp) " )
   AAdd( _opcexe, {|| fakt_export_tbl_fakt() } )

   f18_menu( "fain", .F., _izbor, _opc, _opcexe )

   RETURN .T.



FUNCTION fakt_ispravka_podataka_azuriranog_dokumenta( id_firma, tip_dok, br_dok )

   LOCAL nDbfArea := Select()
   LOCAL lRet := .F.
   LOCAL _x := 1
   LOCAL _cnt
   LOCAL __idpartn
   LOCAL __br_otpr
   LOCAL __br_nar
   LOCAL __dat_otpr
   LOCAL __dat_pl
   LOCAL __txt
   LOCAL __id_vrsta_p
   LOCAL __p_tmp
   LOCAL _t_txt
   LOCAL lOk := .T.
   LOCAL hParams

   __idpartn := field->idpartner
   __id_vrsta_p := field->idvrstep

   SELECT ( F_FAKT )
   IF !Used()
      o_fakt()
   ENDIF

   SELECT ( F_PARTN )
   IF !Used()
      o_partner()
   ENDIF

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_firma + tip_dok + br_dok

   IF !Found()
      SELECT ( nDbfArea )
      RETURN lRet
   ENDIF

   _t_txt := parsmemo( field->txt )

   __br_otpr := _t_txt[ 6 ]
   __br_nar := _t_txt[ 8 ]
   __dat_otpr := CToD( _t_txt[ 7 ] )
   __dat_pl := CToD( _t_txt[ 9 ] )

   Box(, 12, 65 )

   @ m_x + _x, m_y + 2 SAY "*** korekcija podataka dokumenta"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Partner:" GET __idpartn VALID p_partner( @__idpartn )

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Datum otpremnice:" GET __dat_otpr

   ++ _x
   @ m_x + _x, m_y + 2 SAY " Broj otpremnice:" GET __br_otpr PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "  Datum plaćanja:" GET __dat_pl

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "        Narudžba:" GET __br_nar PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "  Vrsta plaćanja:" GET __id_vrsta_p VALID Empty( __id_vrsta_p ) .OR. P_VRSTEP( @__id_vrsta_p )


   READ

   BoxC()

   IF LastKey() == K_ESC
      SELECT ( nDbfArea )
      RETURN lRet
   ENDIF

   IF Pitanje(, "Izvršiti zamjenu podataka ? (D/N)", "D" ) == "N"
      SELECT ( nDbfArea )
      RETURN lRet
   ENDIF

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fakt_fakt", "fakt_doks" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu napraviti zaključavanje tabela.#Prekidam operaciju." )
      SELECT ( nDbfArea )
      RETURN lRet
   ENDIF

   SELECT partn
   SEEK __idpartn

   __p_tmp := AllTrim( field->naz ) + ;
      "," + AllTrim( field->ptt ) + ;
      " " + AllTrim( field->mjesto )

   SELECT fakt_doks
   SEEK id_firma + tip_dok + br_dok

   IF !Found()

      hParams := hb_Hash()
      hParams[ "unlock" ] := { "fakt_fakt", "fakt_doks" }
      run_sql_query( "COMMIT", hParams )

      MsgBeep( "Dokument ne postoji, nije ništa zamjenjeno !" )
      RETURN lRet
   ENDIF

   _rec := dbf_get_rec()
   _rec[ "idpartner" ] := __idpartn
   _rec[ "partner" ] := __p_tmp
   _rec[ "idvrstep" ] := __id_vrsta_p

   lOk := update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )

   IF !lOk
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Postoji problem sa zamjenom podataka#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   SELECT fakt
   GO TOP
   SEEK id_firma + tip_dok + br_dok

   _cnt := 1

   DO WHILE !Eof() .AND. field->idfirma == id_firma ;
         .AND. field->idtipdok == tip_dok ;
         .AND. field->brdok == br_dok

      _rec := dbf_get_rec()
      _rec[ "idpartner" ] := __idpartn
      _rec[ "idvrstep" ] := __id_vrsta_p

      IF _cnt == 1

         // roba tip U
         __txt := Chr( 16 ) + _t_txt[ 1 ] + Chr( 17 )
         // dodatni tekst fakture
         __txt += Chr( 16 ) + _t_txt[ 2 ] + Chr( 17 )
         // naziv partnera
         __txt += Chr( 16 ) + AllTrim( partn->naz ) + Chr( 17 )
         // partner 2 podaci
         __txt += Chr( 16 ) + AllTrim( partn->adresa ) + ", Tel:" + AllTrim( partn->telefon ) + Chr( 17 )
         // partner 3 podaci
         __txt += Chr( 16 ) + AllTrim( partn->ptt ) + " " + AllTrim( partn->mjesto ) + Chr( 17 )
         // broj otpremnice
         __txt += Chr( 16 ) + __br_otpr + Chr( 17 )
         // datum otpremnice
         __txt += Chr( 16 ) + DToC( __dat_otpr ) + Chr( 17 )
         // broj narudzbenice
         __txt += Chr( 16 ) + __br_nar + Chr( 17 )
         // datum placanja
         __txt += Chr( 16 ) + DToC( __dat_pl ) + Chr( 17 )

         IF Len( _t_txt ) > 9
            FOR nI := 10 TO Len( _t_txt )
               __txt += Chr( 16 ) + _t_txt[ nI ] + Chr( 17 )
            NEXT
         ENDIF

         _rec[ "txt" ] := __txt

      ENDIF

      lOk := update_rec_server_and_dbf( "fakt_fakt", _rec, 1, "CONT" )

      IF !lOk
         EXIT
      ENDIF

      ++ _cnt

      SKIP

   ENDDO

   IF lOk
      lRet := .T.
      hParams := hb_Hash()
      hParams[ "unlock" ] := { "fakt_fakt", "fakt_doks" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
      lRet := .F.
   ENDIF

   SELECT ( nDbfArea )

   RETURN lRet
