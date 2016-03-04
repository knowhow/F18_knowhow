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

// ------------------------------------------
// sta generisati, uslovi generacije
// ------------------------------------------
STATIC FUNCTION _export_cond( params )

   LOCAL _x := 1
   LOCAL _ok := .T.
   LOCAL _tip := "V"
   LOCAL _suma := "N"
   LOCAL _valuta := PadR( AllTrim( ValDomaca() ), 3 )
   LOCAL _pr_isp := "N"
   PRIVATE GetList := {}

   Box(, 8, 65 )

   @ m_x + _x, m_y + 2 SAY "Uslovi prenosa naloga u otpremnicu:"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY " Tip otpremnice: [V] vp (dok 12)"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "                 [M] mp (dok 13)" GET _tip VALID _tip $ "VM" PICT "@!"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Sumirati stavke naloga (D/N)" GET _suma VALID _suma $ "DN" PICT "@!"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Valuta u koju mjenjamo otpremnicu (KM/EUR)" GET _valuta PICT "@!"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Promjeniti podatke isporuke naloga (D/N)" GET _pr_isp VALID _pr_isp $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      _ok := .F.
      RETURN _ok
   ENDIF

   params := hb_Hash()
   params[ "exp_tip" ] := _tip
   params[ "exp_suma" ] := _suma
   params[ "exp_valuta" ] := Upper( _valuta )
   params[ "exp_isporuka" ] := _pr_isp

   RETURN _ok



// --------------------------------------------------------
// export u FMK v.2
//
// lTemp - .t. - stampa iz pripreme, .f. - kumulativ
// nDoc_no - broj dokumenta
// aDocList - matrica sa listom naloga za obradu
// ako je zadata, radit ce na osnovu
// vise naloga
// lNoGen - nemoj generisati ponovo stavke, vec postoje
// --------------------------------------------------------
FUNCTION exp_2_fmk( lTemp, nDoc_no, aDocList, lNoGen )

   LOCAL nTArea := Select()
   LOCAL nADocs := F_DOCS
   LOCAL nADOC_IT := F_T_DOCIT
   LOCAL nADOC_IT2 := F_T_DOCIT2
   LOCAL nADOC_OP := F_T_DOCOP
   LOCAL cFmkDoc
   LOCAL nCust_id
   LOCAL i
   LOCAL lSumirati
   LOCAL cVpMp := "V"
   LOCAL _rec
   LOCAL _redni_broj
   LOCAL _exp_params, _isporuka, _valuta

   IF lNoGen == nil
      lNoGen := .F.
   ENDIF

   IF lNoGen == .F.
      // napuni podatke za prenos
      st_pripr( lTemp, nDoc_no, aDocList )
   ENDIF

   // uslovi ekporta - raznorazni...
   IF !_export_cond( @_exp_params )
      SELECT ( nTArea )
      RETURN
   ENDIF

   lSumirati := _exp_params[ "exp_suma" ] == "D"
   cVpMp := _exp_params[ "exp_tip" ]
   _isporuka := _exp_params[ "exp_isporuka" ] == "D"
   _valuta := _exp_params[ "exp_valuta" ]

   IF Empty( _valuta )
      _valuta := PadR( ValDomaca(), 3 )
   ENDIF

   IF _isporuka
      rnal_print_odabir_stavki( lTemp )
   ENDIF

   IF !fakt_priprema_prazna()
      SELECT ( nTArea )
      RETURN
   ENDIF

   SELECT ( F_FAKT_PRIPR )
   IF !Used()
      O_FAKT_PRIPR
   ENDIF

   IF lTemp == .T.
      nADocs := F__DOCS
   ENDIF

   t_rpt_open()

   // --------------------------------------------
   // 1 korak :
   // uzmi podatke partnera, dokumenta iz T_PARS
   // --------------------------------------------

   nCust_id := Val( g_t_pars_opis( "P01" ) )
   nCont_id := Val( g_t_pars_opis( "P10" ) )

   cCust_desc := g_cust_desc( nCust_id )
   cCont_desc := g_cont_desc( nCont_id )

   dDatDok := CToD( g_t_pars_opis( "N02" ) )

   IF AllTrim( cCust_desc ) == "NN"
      // ako je NN kupac u RNAL, dodaj ovo kao contacts....
      cPartn := PadR( g_rel_val( "1", "CONTACTS", "PARTN", AllTrim( Str( nCont_id ) ) ), 6 )

   ELSE
      // dodaj kao customs
      cPartn := PadR( g_rel_val( "1", "CUSTOMS", "PARTN", AllTrim( Str( nCust_id ) ) ), 6 )
   ENDIF

   // ako je partner prazno
   IF Empty( cPartn )

      IF AllTrim( cCust_desc ) == "NN"

         // ako je NN kupac, presvicaj se na CONTACTS

         // probaj naci partnera iz PARTN
         IF fnd_partn( @cPartn, nCont_id, cCont_desc ) == 1

            add_to_relation( "CONTACTS", "PARTN", ;
               AllTrim( Str( nCont_id ) ), cPartn )

         ELSE

            SELECT ( F_FAKT_PRIPR )
            USE

            SELECT ( nTArea )
            MsgBeep( "Operacija prekinuta !!!" )
            RETURN

         ENDIF

      ELSE
         // probaj naci partnera iz PARTN
         IF fnd_partn( @cPartn, nCust_id, cCust_desc ) == 1

            add_to_relation( "CUSTOMS", "PARTN", ;
               AllTrim( Str( nCust_id ) ), cPartn )

         ELSE

            SELECT ( F_FAKT_PRIPR )
            USE

            SELECT ( nTArea )
            MsgBeep( "Operacija prekinuta !!!" )
            RETURN

         ENDIF
      ENDIF
   ENDIF


   // ----------------------------------------------
   // 2. korak
   // prebaci robu iz doc_it2
   // ----------------------------------------------

   cFirma := "10"

   cIdVd := "12"
   cCtrlNo := "22"

   // ako je MP onda je drugi set
   IF cVpMp == "M"
      cIdVd := "13"
      cCtrlNo := "23"
   ENDIF

   // ova funkcija ce vratiti novi broj dokumenta "22"
   cBrDok := fakt_novi_broj_dokumenta( cFirma, cCtrlNo )

   cFmkDoc := cIdVd + "-" + AllTrim( cBrdok )
   _redni_broj := 0

   SELECT ( nADOC_IT2 )
   SET ORDER TO TAG "2"
   GO TOP

   DO WHILE !Eof()

      nDoc_no := field->doc_no
      cArt_id := field->art_id
      // vrsi se preracunavanje kolicine
      nQtty := preracunaj_kolicinu_repromaterijala( field->doc_it_qtt, ;
         field->doc_it_q2, ;
         field->jmj, ;
         field->jmj_art )
      cDesc := field->descr

      IF lSumirati == .T.
         nQtty := 0
         DO WHILE !Eof() .AND. field->art_id == cArt_id
            nQtty += preracunaj_kolicinu_repromaterijala( field->doc_it_qtt, ;
               field->doc_it_q2, ;
               field->jmj, ;
               field->jmj_art )
            SKIP
         ENDDO
      ENDIF

      nPrice := field->doc_it_pri

      IF Empty( cArt_id )
         SKIP
         LOOP
      ENDIF

      IF nQtty = 0
         SKIP
         LOOP
      ENDIF

      SELECT fakt_pripr
      APPEND BLANK

      scatter()

      _txt := ""
      _rbr := Str( ++_redni_broj, 3 )
      _idpartner := cPartn
      _idfirma := "10"
      _brdok := cBrDok
      _idtipdok := cIdVd
      _datdok := dDatDok
      _idroba := cArt_id
      _cijena := nPrice
      _kolicina := nQtty
      _dindem := _valuta
      _zaokr := 2

      _txt := ""

      // roba tip U - nista
      a_to_txt( "", .T. )
      // dodatni tekst otpremnice - nista
      a_to_txt( "", .T. )
      // naziv partnera
      a_to_txt( _g_pfmk_desc( cPartn ), .T. )
      // adresa
      a_to_txt( _g_pfmk_addr( cPartn ), .T. )
      // ptt i mjesto
      a_to_txt( _g_pfmk_place( cPartn ), .T. )
      // broj otpremnice
      a_to_txt( "", .T. )
      // datum  otpremnice
      a_to_txt( DToC( dDatDok ), .T. )

      // broj ugovora - nista
      a_to_txt( "", .T. )

      // datum isporuke - nista
      a_to_txt( "", .T. )

      // 10. datum valute - nista
      a_to_txt( "", .T. )

      // 11.
      a_to_txt( "", .T. )
      // 12.
      a_to_txt( "", .T. )
      // 13.
      a_to_txt( "", .T. )
      // 14.
      a_to_txt( "", .T. )
      // 15.
      a_to_txt( "", .T. )
      // 16.
      a_to_txt( "", .T. )
      // 17.
      a_to_txt( "", .T. )
      // 18.
      a_to_txt( "", .T. )
      // 19.
      a_to_txt( "", .T. )
      // 20.
      a_to_txt( "", .T. )

      gather()

      IF !Empty( cDesc )

         _t_area := Select()

         _items_atrib := hb_Hash()
         _items_atrib[ "opis" ] := cDesc

         oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )
         oAtrib:dok_hash := hb_Hash()
         oAtrib:dok_hash[ "idfirma" ] := field->idfirma
         oAtrib:dok_hash[ "idtipdok" ] := field->idtipdok
         oAtrib:dok_hash[ "brdok" ] := field->brdok
         oAtrib:dok_hash[ "rbr" ] := field->rbr

         oAtrib:atrib_hash_to_dbf( _items_atrib )

         SELECT ( _t_area )

      ENDIF

      SELECT ( nADOC_IT2 )

      IF lSumirati == .F.
         SKIP
      ENDIF

   ENDDO

   // -----------------------------------------------
   // 3. korak :
   // prebaci sve iz T_DOCIT
   // -----------------------------------------------

   SELECT ( nADOC_IT )
   SET ORDER TO TAG "5"
   // index: art_sh_desc
   GO TOP

   DO WHILE !Eof()

      // da li je markirano za prenos
      IF field->print == "N"
         SKIP
         LOOP
      ENDIF

      nDoc_no := field->doc_no

      nArt_id := field->art_id

      // ukupna kvadratura
      nM2 := field->doc_it_tot

      // opis artikla (kratki)
      cArt_sh := field->art_sh_des

      cIdRoba := g_rel_val( "1", "ARTICLES", "ROBA", AllTrim( Str( nArt_id ) ) )

      // uzmi cijenu robe iz sifrarnika robe
      nPrice := g_art_price( cIdRoba )

      // uzmi opis artikla
      cArt_desc := g_art_desc( nArt_id )

      IF Empty( cIdRoba )

         IF fnd_roba( @cIdRoba, nArt_id, cArt_desc ) == 1

            add_to_relation( "ARTICLES", "ROBA", ;
               AllTrim( Str( nArt_id ) ), cIdRoba )

         ELSE
            MsgBeep( "Neki artikli nemaju definisani u tabeli relacija#Prekidam operaciju !" )
            SELECT ( F_FAKT_PRIPR )
            USE

            SELECT ( nTArea )
            RETURN
         ENDIF
      ENDIF

      SELECT ( nADOC_IT )

      IF lSumirati == .T.

         nM2 := 0

         // sracunaj za iste artikle
         DO WHILE !Eof() .AND. field->art_sh_des == cArt_sh

            IF field->print == "D"
               // kolicina
               nM2 += field->doc_it_tot
            ENDIF

            SKIP

         ENDDO

      ENDIF

      SELECT fakt_pripr
      APPEND BLANK

      scatter()

      _txt := ""
      _rbr := Str( ++_redni_broj, 3 )
      _idpartner := cPartn
      _idfirma := "10"
      _brdok := cBrDok
      _idtipdok := cIdVd
      _datdok := dDatDok
      _idroba := cIdRoba
      _cijena := nPrice
      _kolicina := nM2
      _dindem := _valuta
      _zaokr := 2

      _txt := ""

      // roba tip U - nista
      a_to_txt( "", .T. )
      // dodatni tekst otpremnice - nista
      a_to_txt( "", .T. )
      // naziv partnera
      a_to_txt( _g_pfmk_desc( cPartn ), .T. )
      // adresa
      a_to_txt( _g_pfmk_addr( cPartn ), .T. )
      // ptt i mjesto
      a_to_txt( _g_pfmk_place( cPartn ), .T. )
      // broj otpremnice
      a_to_txt( "", .T. )
      // datum  otpremnice
      a_to_txt( DToC( dDatDok ), .T. )

      // broj ugovora - nista
      a_to_txt( "", .T. )

      // datum isporuke - nista
      a_to_txt( "", .T. )

      // 10. datum valute - nista
      a_to_txt( "", .T. )

      // 11.
      a_to_txt( "", .T. )
      // 12.
      a_to_txt( "", .T. )
      // 13.
      a_to_txt( "", .T. )
      // 14.
      a_to_txt( "", .T. )
      // 15.
      a_to_txt( "", .T. )
      // 16.
      a_to_txt( "", .T. )
      // 17.
      a_to_txt( "", .T. )
      // 18.
      a_to_txt( "", .T. )
      // 19.
      a_to_txt( "", .T. )
      // 20.
      a_to_txt( "", .T. )

      gather()

      // ubaci mi atribute u fakt_atribute
      IF !Empty( cArt_sh )

         _t_area := Select()

         _items_atrib := hb_Hash()
         _items_atrib[ "opis" ] := cArt_sh

         oAtrib := F18_DOK_ATRIB():new( "fakt" )
         oAtrib:dok_hash := hb_Hash()
         oAtrib:dok_hash[ "idfirma" ] := field->idfirma
         oAtrib:dok_hash[ "idtipdok" ] := field->idtipdok
         oAtrib:dok_hash[ "brdok" ] := field->brdok
         oAtrib:dok_hash[ "rbr" ] := field->rbr

         oAtrib:atrib_hash_to_dbf( _items_atrib )

         SELECT ( _t_area )

      ENDIF

      SELECT ( nADOC_IT )

      IF lSumirati == .F.
         SKIP
      ENDIF

   ENDDO

   // ubaci sada brojeve veze
   // ======================================

   // ubaci prvo u fakt
   _ins_x_veza( nADoc_it )

   // ubaci brojeve veze u tabelu docs
   _ins_veza( nADoc_it, nADocs, cBrDok, lTemp )

   // sredi redne brojeve
   _fix_rbr()

   SELECT ( F_FAKT_PRIPR )
   USE

   MsgBeep( "export dokumenta zavrsen !" )

   SELECT ( nTArea )

   RETURN




// --------------------------------------
// ubaci vezu u tabelu docs
// --------------------------------------
STATIC FUNCTION _ins_veza( nA_doc_it, nA_docs, cBrfakt, lTemp )

   LOCAL nDoc_no
   LOCAL _rec

   IF !lTemp
      sql_table_update( NIL, "BEGIN" )
      IF !f18_lock_tables( { "rnal_docs" }, .T. )
         sql_table_update( NIL, "END" )
         MsgBeep( "Ne mogu zaključati tabelu !#Operacija prekinuta." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT ( nA_doc_it )
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      IF field->print == "N"
         SKIP
         LOOP
      ENDIF

      nDoc_no := field->doc_no

      SELECT ( nA_docs )
      SEEK docno_str( nDoc_no )

      IF !Found()
         IF !lTemp
            f18_free_tables( { "rnal_docs" } )
            sql_table_update( NIL, "END" )
         ENDIF
         MsgBeep( "Traženi nalog ne postoji u ažuriranim dokumentima !" )
         RETURN .F.
      ENDIF

      _rec := dbf_get_rec()
      _rec[ "doc_in_fmk" ] := 1
      _rec[ "fmk_doc" ] := _add_to_field( AllTrim( _rec[ "fmk_doc" ] ), ;
         AllTrim( cBrfakt ) )

      IF !lTemp
         IF !update_rec_server_and_dbf( "rnal_docs", _rec, 1, "CONT" )
            sql_table_update( NIL, "ROLLBACK" )
            RETURN .F.
         ENDIF
      ELSE
         dbf_update_rec( _rec )
      ENDIF

      SELECT ( nA_doc_it )
      SKIP

   ENDDO

   IF !lTemp
      f18_free_tables( { "rnal_docs" } )
      sql_table_update( NIL, "END" )
   ENDIF

   RETURN .T.



// -----------------------------------
// sredi redne brojeve
// -----------------------------------
STATIC FUNCTION _fix_rbr()

   LOCAL nRbr, _rec

   // sredi redne brojeve pripreme
   SELECT fakt_pripr
   SET ORDER TO TAG "0"
   GO TOP
   nRbr := 0

   DO WHILE !Eof()
      _rec := dbf_get_rec()
      _rec[ "rbr" ] := Str( ++nRbr, 3 )
      dbf_update_rec( _rec )
      SKIP
   ENDDO

   RETURN


// -----------------------------------
// ubaci broj veze u fakt pripr
// -----------------------------------
STATIC FUNCTION _ins_x_veza( nArea )

   LOCAL cTmp := ""
   LOCAL nDoc_no
   LOCAL cIns_x := ""

   SELECT ( nArea )
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      // treba li ovo ubaciti ?
      IF field->print == "N"
         SKIP
         LOOP
      ENDIF

      nDoc_no := field->doc_no

      // veza, broj naloga
      cTmp := _add_to_field( cTmp, AllTrim( Str( nDoc_No ) ) )

      SKIP
   ENDDO

   // insertuj u veze ovu vezu
   set_fakt_vezni_dokumenti( cTmp )

   RETURN .T.


// -----------------------------------------------------
// setuje vezne dokumente za odredjeni dokument
// -----------------------------------------------------
STATIC FUNCTION set_fakt_vezni_dokumenti( value )

   LOCAL _ok := .T.
   LOCAL _memo, _rec
   LOCAL _t_area := Select()

   IF value == NIL
      RETURN _ok
   ENDIF

   SELECT fakt_pripr
   GO TOP

   _rec := dbf_get_rec()

   _memo := ParsMemo( _rec[ "txt" ] )

   // setuj 19-ti clan matrice
   _memo[ 19 ] := value

   // konvertuj mi memo field u txt
   // zatim setuj za novu vrijednost polja
   _rec[ "txt" ] := fakt_memo_field_to_txt( _memo )

   dbf_update_rec( _rec )

   SELECT ( _t_area )

   RETURN _ok




// --------------------------------------------
// dodaj dokument u listu
// --------------------------------------------
FUNCTION _add_to_field( field_value, new_value )

   LOCAL _ret := ""
   LOCAL _sep := ";"
   LOCAL _tmp
   LOCAL _a_tmp
   LOCAL _seek
   LOCAL _i

   _tmp := AllTrim( field_value )
   _a_tmp := TokToNiz( _tmp, _sep )
   _seek := AScan( _a_tmp, {| val | val == new_value } )

   IF _seek = 0
      AAdd( _a_tmp, new_value  )
      // sortiraj
      ASort( _a_tmp )
   ENDIF

   // zatim daj u listu sve stavke
   FOR _i := 1 TO Len( _a_tmp )
      IF !Empty( _a_tmp[ _i ] )
         _ret += _a_tmp[ _i ] + _sep
      ENDIF
   NEXT

   RETURN _ret





// ----------------------------------------------------
// pronadji partnera u PARTN
// ----------------------------------------------------
STATIC FUNCTION fnd_partn( xPartn, nCustId, cDesc  )

   LOCAL nTArea := Select()
   PRIVATE GetList := {}

   O_PARTN

   xPartn := Space( 6 )

   Box(, 5, 70 )
   @ m_x + 1, m_y + 2 SAY8 "Naručioc: "
   @ m_x + 1, Col() + 1 SAY AllTrim( Str( nCustId ) ) COLOR F18_COLOR_I
   @ m_x + 1, Col() + 1 SAY " -> "
   @ m_x + 1, Col() + 1 SAY PadR( cDesc, 50 ) + ".." COLOR F18_COLOR_I
   @ m_x + 2, m_y + 2 SAY8 "nije definisan u relacijama, pronađite njegov par !"
   @ m_x + 4, m_y + 2 SAY8 "šifra u knjigovodstvu: " GET xPartn VALID p_firma( @xPartn )
   READ
   BoxC()

   SELECT ( nTArea )

   ESC_RETURN 0

   RETURN 1


// ----------------------------------------------------
// pronadji robu u ROBA
// ----------------------------------------------------
STATIC FUNCTION fnd_roba( xRoba, nArtId, cDesc )

   LOCAL nTArea := Select()
   PRIVATE GetList := {}

   O_ROBA
   O_SIFK
   O_SIFV

   xRoba := Space( 10 )

   Box(, 5, 70 )
   @ m_x + 1, m_y + 2 SAY "Artikal:"
   @ m_x + 1, Col() + 1 SAY AllTrim( Str( nArtId ) ) COLOR F18_COLOR_I
   @ m_x + 1, Col() + 1 SAY " -> "
   @ m_x + 1, Col() + 1 SAY PadR( cDesc, 50 ) + ".." COLOR F18_COLOR_I
   @ m_x + 2, m_y + 2 SAY "nije definisan u tabeli relacija, pronadjite njegov par !!!"
   @ m_x + 4, m_y + 2 SAY "sifra u FMK =" GET xRoba VALID p_roba( @xRoba )
   READ
   BoxC()

   SELECT ( nTArea )

   ESC_RETURN 0

   RETURN 1



// ----------------------------------------
// vraca naziv partnera iz FMK
// ----------------------------------------
STATIC FUNCTION _g_pfmk_desc( cPart )

   LOCAL xRet := ""
   LOCAL nTArea := Select()

   O_PARTN
   SELECT partn
   SET ORDER TO TAG "ID"
   SEEK cPart

   IF Found()
      xRet := AllTrim( partn->naz )
   ENDIF

   SELECT ( nTArea )

   RETURN xRet


// ----------------------------------------
// vraca adresu partnera iz FMK
// ----------------------------------------
STATIC FUNCTION _g_pfmk_addr( cPart )

   LOCAL xRet := ""
   LOCAL nTArea := Select()

   O_PARTN
   SELECT partn
   SET ORDER TO TAG "ID"
   SEEK cPart

   IF Found()
      xRet := AllTrim( partn->adresa )
   ENDIF

   SELECT ( nTArea )

   RETURN xRet


// ----------------------------------------
// vraca mjesto i ptt partnera iz FMK
// ----------------------------------------
STATIC FUNCTION _g_pfmk_place( cPart )

   LOCAL xRet := ""
   LOCAL nTArea := Select()

   O_PARTN
   SELECT partn
   SET ORDER TO TAG "ID"
   SEEK cPart

   IF Found()
      xRet := AllTrim( partn->ptt ) + " " + AllTrim( partn->mjesto )
   ENDIF

   SELECT ( nTArea )

   RETURN xRet


// -----------------------------------
// dodaj u polje txt tekst
// lVise - vise tekstova
// -----------------------------------
STATIC FUNCTION a_to_txt( cVal, lEmpty )

   LOCAL nTArr

   nTArr := Select()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   // ako je prazno nemoj dodavati
   IF !lEmpty .AND. Empty( cVal )
      RETURN
   ENDIF

   _txt += Chr( 16 ) + cVal + Chr( 17 )

   SELECT ( nTArr )

   RETURN
