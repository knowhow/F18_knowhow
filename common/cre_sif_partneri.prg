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

MEMVAR ImeKol, Kol
MEMVAR wIdrefer, wId, wIdops
FIELD ziror, id, naz, dziror


FUNCTION cre_sif_partn( ver )

   LOCAL aDbf := {}
   LOCAL _created, _table_name, _alias

/*
   AAdd( aDBf, { 'ID', 'C',   6,  0 } )
   add_f_mcode( @aDbf )
   AAdd( aDBf, { 'NAZ', 'C', 250,  0 } )
   AAdd( aDBf, { 'NAZ2', 'C',  25,  0 } )
   AAdd( aDBf, { '_KUP', 'C',   1,  0 } )
   AAdd( aDBf, { '_DOB', 'C',   1,  0 } )
   AAdd( aDBf, { '_BANKA', 'C',   1,  0 } )
   AAdd( aDBf, { '_RADNIK', 'C',   1,  0 } )
   AAdd( aDBf, { 'PTT', 'C',   5,  0 } )
   AAdd( aDBf, { 'MJESTO', 'C',  16,  0 } )
   AAdd( aDBf, { 'ADRESA', 'C',  24,  0 } )
   AAdd( aDBf, { 'ZIROR', 'C',  22,  0 } )
   AAdd( aDBf, { 'DZIROR', 'C',  22,  0 } )
   AAdd( aDBf, { 'TELEFON', 'C',  12,  0 } )
   AAdd( aDBf, { 'FAX', 'C',  12,  0 } )
   AAdd( aDBf, { 'MOBTEL', 'C',  20,  0 } )
   AAdd( aDBf, { 'IDREFER', 'C',  10,  0 } )
   AAdd( aDBf, { 'IDOPS', 'C',   4,  0 } )

   _alias := "PARTN"
   _table_name := "partn"

   IF_NOT_FILE_DBF_CREATE

   // 0.4.2
   IF ver[ "current" ] > 0 .AND. ver[ "current" ] < 00402
      modstru( { "*" + _table_name, "A IDREFER C 10 0", "A IDOPS C 4 0" } )
   ENDIF


   CREATE_INDEX( "ID", "id", _alias )
   CREATE_INDEX( "NAZ", "NAZ", _alias )
   index_mcode( "", _alias )
   AFTER_CREATE_INDEX
*/

/*
   _alias := "_PARTN"
   _table_name := "_partn"

   IF_NOT_FILE_DBF_CREATE

   CREATE_INDEX( "ID", "id", _alias )
*/

   RETURN .T.


/*
   cId := "00001"
   p_partner( @cId, 10, 5 ) => provjera šifre, ako ne postoji prikaze šifarnik
                                ako postoji prikaže na m_x + 10, m_y + 5 naziv

   lEmptIdOk := .F.  // default je .T.

   p_partner( @cId, 10, 5, lEmptyIdOk ) => ako je cId == "    ",
                                 lEmptyIdOk == .T. - prihvata cId to kao validnu sifru,
                                 lEmptyIdOk == .F. - ne prihvata kao validnu sifru

   funkcija vraća .T. kada šifra postoji

*/

FUNCTION p_partner( cId, dx, dy, lEmptyIdOk )

   LOCAL cN2Fin
   LOCAL nI
   LOCAL xRet

   PRIVATE ImeKol
   PRIVATE Kol

   IF lEmptyIdOk == NIL
      lEmptyIdOk := .T.
   ENDIF

   IF lEmptyIdOk .AND. ( ValType( cId ) == "C" .AND. Empty( cId ) )
      RETURN .T.
   ENDIF

   PushWA()
   select_o_partner()

   ImeKol := {}

   AAdd( ImeKol, { PadR( "ID", 6 ),   {|| id },  "id", {|| .T. }, {|| sifra_postoji( wId ) }    } )
   AAdd( ImeKol, { PadR( "Naziv", 35 ),  {|| PadR( naz, 35 ) },  "naz" } )

   AAdd( ImeKol, { PadR( "PTT", 5 ),      {|| PTT },     "ptt"      } )
   AAdd( ImeKol, { PadR( "Mjesto", 16 ),  {|| MJESTO },  "mjesto"   } )
   AAdd( ImeKol, { PadR( "Adresa", 24 ),  {|| ADRESA },  "adresa"   } )

   AAdd( ImeKol, { _u( "Žiro Račun"), {|| ZIROR },   "ziror", {|| .T. }, {|| .T. }  } )

   Kol := {}

   AAdd ( ImeKol, { PadR( "Dev ZR", 22 ), {|| DZIROR }, "Dziror" } )
   AAdd( Imekol, { PadR( "Telefon", 12 ),  {|| TELEFON }, "telefon"  } )
   AAdd ( ImeKol, { PadR( "Fax", 12 ), {|| fax }, "fax" } )
   AAdd ( ImeKol, { PadR( "MobTel", 20 ), {|| mobtel }, "mobtel" } )
   AAdd ( ImeKol, { PadR( ToStrU( "Općina" ), 6 ), {|| idOps }, "idops", {|| .T. }, {|| p_ops( @wIdops ) } } )

   AAdd ( ImeKol, { PadR( "Referent", 10 ), {|| field->idrefer }, "idrefer", {|| .T. }, {|| EMPTY(wIdrefer) .OR. p_refer( @wIdrefer ) } } )
   AAdd( ImeKol, { "kup?", {|| _kup }, "_kup", {|| .T. }, {|| _v_dn( w_kup ) } } )
   AAdd( ImeKol, { "dob?", {|| " " + _dob + " " }, "_dob", {|| .T. }, {|| _v_dn( w_dob ) }, nil, nil, nil, nil, 20 } )
   AAdd( ImeKol, { "banka?", {|| " " + _banka + " " }, "_banka", {|| .T. }, {|| _v_dn( w_banka ) }, nil, nil, nil, nil, 30 } )
   AAdd( ImeKol, { "radnik?", {|| " " + _radnik + " " }, "_radnik", {|| .T. }, {|| _v_dn( w_radnik ) }, nil, nil, nil, nil, 40 } )

   FOR nI := 1 TO Len( ImeKol )
      AAdd( Kol, nI )
   NEXT

   SELECT PARTN
   sifk_fill_ImeKol( "PARTN", @ImeKol, @Kol )


   xRet := p_sifra( F_PARTN, 1, maxrows() - 15, maxcols() - 15, "Lista Partnera", @cId, dx, dy, {| Ch| partn_k_handler( Ch ) },,,,, { "ID" } )

   PopWa()

   RETURN xRet



STATIC FUNCTION partn_k_handler( Ch )

   LOCAL cSif := PARTN->id, cSif2 := ""

   IF Ch == K_CTRL_T .AND. gSKSif == "D"

      PushWA()
      SET ORDER TO TAG "ID"
      SEEK cSif
      SKIP 1
      cSif2 := PARTN->id
      PopWA()

   ENDIF

   RETURN DE_CONT



// -------------------------------------
// validacija polja P_TIP
// -------------------------------------
STATIC FUNCTION _v_dn( cDn )

   LOCAL lRet := .F.

   IF Upper( cDN ) $ " DN"
      lRet := .T.
   ENDIF

   IF lRet == .F.
      MsgBeep( "Unjeti D ili N" )
   ENDIF

   RETURN lRet


// --------------------------------------------------------
// funkcija vraca .t. ako je definisana grupa partnera
// --------------------------------------------------------
FUNCTION p_group()

   LOCAL lRet := .F.

   o_sifk()
   SELECT sifk
   SET ORDER TO TAG "ID"
   GO TOP
   SEEK "PARTN"
   DO WHILE !Eof() .AND. ID = "PARTN"
      IF field->oznaka == "GRUP"
         lRet := .T.
         EXIT
      ENDIF
      SKIP
   ENDDO

   RETURN lRet



FUNCTION p_set_group( set_field )

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1
   LOCAL _m_x, _m_y

   _m_x := m_x
   _m_y := m_y

   AAdd( _Opc, "VP  - veleprodaja          " )
   AAdd( _opcexe, {|| set_field := "VP ", _izbor := 0 } )
   AAdd( _Opc, "AMB - ambulantna dostava  " )
   AAdd( _opcexe, {|| set_field := "AMB", _izbor := 0 } )
   AAdd( _Opc, "SIS - sistemska kuća      " )
   AAdd( _opcexe, {|| set_field := "SIS", _izbor := 0 } )
   AAdd( _Opc, "OST - ostali      " )
   AAdd( _opcexe, {|| set_field := "OST", _izbor := 0 } )

   f18_menu( "pgr", .F., @_izbor, _opc, _opcexe )

   m_x := _m_x
   m_y := _m_y

   RETURN .T.


FUNCTION gr_opis( cGroup )

   LOCAL cRet

   DO CASE
   CASE cGroup == "AMB"
      cRet := "ambulantna dostava"
   CASE cGroup == "SIS"
      cRet := "sistemska obrada"
   CASE cGroup == "VP "
      cRet := "veleprodaja"
   CASE cGroup == "OST"
      cRet := "ostali"
   OTHERWISE
      cRet := ""
   ENDCASE

   RETURN cRet


FUNCTION p_gr( xVal, nX, nY )

   LOCAL cRet := ""
   LOCAL cPrn := ""

   cRet := gr_opis( xVal )
   cPrn := Space( 2 ) + "-" + Space( 1 ) + cRet

   @ nX, nY + 25 SAY Space( 40 )
   @ nX, nY + 25 SAY cPrn

   RETURN .T.


// da li partner 'cPartn' pripada grupi 'cGroup'
FUNCTION p_in_group( cPartn, cGroup )

   LOCAL cSifKVal

   cSifKVal := IzSifKPARTN( "GRUP", cPartn, .F. )

   IF cSifKVal == cGroup
      RETURN .T.
   ENDIF

   RETURN .F.

// -----------------------------
// get partner fax
// -----------------------------
FUNCTION g_part_fax( cIdPartner )

   LOCAL cFax

   PushWA()

   SELECT F_PARTN
   IF !Used()
      o_partner()
   ENDIF
   SEEK cIdPartner
   IF !Found()
      cFax := "!NOFAX!"
   ELSE
      cFax := fax
   ENDIF

   PopWa()

   RETURN cFax

// -----------------------------
// get partner naziv + mjesto
// -----------------------------
FUNCTION g_part_name( cIdPartner )

   LOCAL cRet

   PushWA()

   SELECT F_PARTN
   IF !Used()
      o_partner()
   ENDIF
   SEEK cIdPartner
   IF !Found()
      cRet := "!NOPARTN!"
   ELSE
      cRet := Trim( Left( naz, 25 ) ) + " " + Trim( mjesto )
   ENDIF

   PopWa()

   RETURN cRet


FUNCTION is_kupac( cId )

   LOCAL cFld := "_KUP"

   IF _ck_status( cId, cFld )
      RETURN .T.
   ENDIF

   RETURN .F.


FUNCTION is_dobavljac( cId )

   LOCAL cFld := "_DOB"

   IF _ck_status( cId, cFld )
      RETURN .T.
   ENDIF

   RETURN .F.



FUNCTION is_banka( cId )

   LOCAL cFld := "_BANKA"

   IF _ck_status( cId, cFld )
      RETURN .T.
   ENDIF

   RETURN .F.


FUNCTION is_radnik( cId )

   LOCAL cFld := "_RADNIK"

   IF _ck_status( cId, cFld )
      RETURN .T.
   ENDIF

   RETURN .F.


/*

   Usage: _ck_status( "01", "_RADNIK" )
   Ako je: partn->_RADNIK == "dD" => .T.

*/
STATIC FUNCTION _ck_status( cId, cFld )

   LOCAL lRet := .F.
   LOCAL nSelect := Select()

   o_partner()
   SELECT partn
   SEEK cId

   IF partn->( FieldPos( cFld ) ) <> 0
      if &cFld $ "Dd"
         lRet := .T.
      ENDIF
   ELSE
      lRet := .T.
   ENDIF

   SELECT ( nSelect )

   RETURN lRet


FUNCTION set_sifk_partn_bank()

   LOCAL lFound
   LOCAL cSeek
   LOCAL cNaz
   LOCAL cId
   LOCAL hRec

   SELECT ( F_SIFK )
   o_sifk()

   SET ORDER TO TAG "ID"
   // id + SORT + naz

   cId := PadR( "PARTN", SIFK_LEN_DBF )
   cNaz := PadR( "Banke", Len( field->naz ) )
   cSeek :=  cId + "05" + cNaz

   SEEK cSeek

   IF !Found()

      APPEND BLANK

      hRec := dbf_get_rec()
      hRec[ "id" ] := cId
      hRec[ "naz" ] := cNaz
      hRec[ "oznaka" ] := "BANK"
      hRec[ "sort" ] := "05"
      hRec[ "tip" ] := "C"
      hRec[ "duzina" ] := 16
      hRec[ "veza" ] := "N"

      IF !update_rec_server_and_dbf( "sifk", hRec, 1, "FULL" )
         delete_with_rlock()
      ENDIF

   ENDIF

   RETURN .T.



FUNCTION ispisi_partn( cPartn, nX, nY )

   LOCAL nTArea := Select()
   LOCAL cDesc := "<??>"

   SELECT partn
   SET ORDER TO TAG "ID"
   SEEK cPartn

   IF Found()
      cDesc := AllTrim( field->naz )
      IF Len( cDesc ) > 13
         cDesc := PadR( cDesc, 12 ) + "..."
      ENDIF
   ENDIF

   @ nX, nY SAY PadR( cDesc, 15 )

   SELECT ( nTArea )

   RETURN .T.



FUNCTION is_postoji_partner( sifra )

   LOCAL nCount
   LOCAL cWhere

   cWhere := "id = " + sql_quote( sifra )
   nCount := table_count( F18_PSQL_SCHEMA_DOT + "partn", cWhere )

   IF nCount > 0
      RETURN .T.
   ENDIF

   RETURN .F.
