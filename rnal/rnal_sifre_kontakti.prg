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

#include "f18.ch"

STATIC __cust_id


FUNCTION s_contacts( cId, nCust_id, cContDesc, dx, dy )

   LOCAL cHeader
   LOCAL cTag := "4"
   LOCAL cRet
   PRIVATE ImeKol
   PRIVATE Kol


   IF nCust_id == nil
      nCust_id := -1
   ENDIF

   IF cContDesc == nil
      cContDesc := ""
   ENDIF

   __cust_id := nCust_id

   PushWa()

   O_CONTACTS

   cHeader := "Kontakti /"

   SELECT contacts

   IF cID == nil
      cTag := "4"
   ELSE
      cTag := "3"
   ENDIF

   rnal_sifra_bez_tacke( @cContDesc )

   set_a_kol( @ImeKol, @Kol, nCust_id )

   IF ValType( cId ) == "C"

      rnal_sifra_bez_tacke( @cId )

      IF Val( cId ) <> 0
         cId := Val( cId )
         nCust_id := -1
         cContDesc := ""
         cTag := "1"
      ENDIF
   ENDIF

   SET ORDER TO TAG cTag
   SET FILTER TO

   cust_filter( nCust_id, cContDesc, @cId )

   cRet := p_sifra( F_CONTACTS, cTag, f18_max_rows() - 10, f18_max_cols() - 10, cHeader, @cId, dx, dy, {|| key_handler( Ch ) } )

   IF LastKey() == K_ESC
      cId := 0
   ENDIF

   PopWa()

   RETURN cRet



STATIC FUNCTION key_handler()

   LOCAL nRet := DE_CONT

   DO CASE
   CASE Ch == K_F3
      nRet := rnal_wid_edit( "CONT_ID" )
   ENDCASE

   RETURN nRet



// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol, nCust_id )

   LOCAL i

   aKol := {}
   aImeKol := {}

   AAdd( aImeKol, { "ID/MC", {|| sif_idmc( cont_id, .F., 20 ) }, "cont_id", {|| rnal_uvecaj_id( @wCont_id, "CONT_ID" ), .F. }, {|| .T. } } )
   AAdd( aImeKol, { _u( "Naručioc" ), {|| g_cust_desc( cust_id ) }, "cust_id", {|| set_cust_id( @wCust_id ) }, {|| s_customers( @wCust_id ), show_it( g_cust_desc( wcust_id ) ) } } )
   AAdd( aImeKol, { "Ime i prezime", {|| PadR( cont_desc, 20 ) }, "cont_desc", {|| .T. }, {|| val_cont_name( wcont_desc ) } } )
   AAdd( aImeKol, { "Telefon", {|| PadR( cont_tel, 20 ) }, "cont_tel" } )
   AAdd( aImeKol, { "Dodatni opis", {|| PadR( cont_add_d, 20 ) }, "cont_add_d", {|| set_cont_mc( @wMatch_code, @wCont_desc ) }, {|| rnal_chk_id( @wCont_id, "CONT_ID" ) } } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN .T.



// ---------------------------------------------
// validacija imena i prezimena
// ---------------------------------------------
STATIC FUNCTION val_cont_name( cCont_desc )

   LOCAL aPom := {}

   aPom := TokToNiz( AllTrim( cCont_desc ), " " )

   DO CASE
   CASE Len( aPom ) == 1

      MsgBeep( "Format unosa je IME + PREZIME#Ako je prezime nepoznato unosi se IME + NN !" )
      RETURN .F.

   CASE Empty( cCont_desc )

      MsgBeep( "Unos imena i prezimena je obavezan !!!" )

      RETURN .F.

   ENDCASE

   RETURN .T.



// ----------------------------------------------
// setuje cust_id pri unosu automatski
// ----------------------------------------------
STATIC FUNCTION set_cust_id( nCust_id )

   IF __cust_id > 0
      nCust_id := __cust_id
      RETURN .F.
   ELSE
      RETURN .T.
   ENDIF

   RETURN .T.



// --------------------------------------------------
// generisi match code za contakt...
// --------------------------------------------------
STATIC FUNCTION set_cont_mc( m_code, cont_desc )

   LOCAL aPom := TokToNiz( AllTrim( cont_desc ), " " )
   LOCAL i

   IF !Empty( m_code )
      RETURN .T.
   ENDIF

   m_code := ""

   FOR i := 1 TO Len( aPom )
      m_code += Upper( Left( aPom[ i ], 2 ) )
   NEXT

   m_code := PadR( m_code, 10 )

   RETURN .T.




// -------------------------------------------
// filter po cust_id
// nCust_id - id customer
// -------------------------------------------
STATIC FUNCTION cust_filter( nCust_id, cContDesc, cId )

   LOCAL cFilter := ""

   IF nCust_id > 0
      cFilter += "cust_id == " + custid_str( nCust_id )
   ENDIF

   IF !Empty( cContDesc )

      IF !Empty( cFilter )
         cFilter += " .and. "
      ENDIF

      cContDesc := AllTrim( cContDesc )

      IF Right( cContDesc ) == "$"
         // pretrazi po dijelu naziva

         // vrati uslov u normalno stanje...
         cContDesc := Left( cContDesc, Len( cContDesc ) - 1 )
         // setuj i id u normalno stanje
         cId := cContDesc
         // setuj filter
         cFilter += _filter_quote( Upper( cContDesc ) ) + " $ ALLTRIM(UPPER(cont_desc))"
      ELSE
         cFilter += " ALLTRIM(UPPER(cont_desc)) = " + dbf_quote( Upper( cContDesc ) )
      ENDIF

   ENDIF

   IF !Empty( cFilter )
      SET FILTER to &cFilter
      GO TOP
   ENDIF

   RETURN



// -------------------------------
// convert cont_id to string
// -------------------------------
FUNCTION contid_str( nId )
   RETURN Str( nId, 10 )



// -------------------------------
// get cont_id_desc by cont_id
// -------------------------------
FUNCTION g_cont_desc( nCont_id, lEmpty )

   LOCAL cContDesc := "?????"
   LOCAL nTArea := Select()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   IF lEmpty == .T.
      cContDesc := ""
   ENDIF

   O_CONTACTS
   SELECT contacts
   SET ORDER TO TAG "1"
   GO TOP
   SEEK contid_str( nCont_id )

   IF Found()
      IF !Empty( field->cont_desc )
         cContDesc := AllTrim( field->cont_desc )
      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN cContDesc


// -------------------------------
// get cont_tel by cont_id
// -------------------------------
FUNCTION g_cont_tel( nCont_id, lEmpty )

   LOCAL cContTel := "?????"
   LOCAL nTArea := Select()

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   IF lEmpty == .T.
      cContTel := ""
   ENDIF

   O_CONTACTS
   SELECT contacts
   SET ORDER TO TAG "1"
   GO TOP
   SEEK contid_str( nCont_id )

   IF Found()
      IF !Empty( field->cont_tel )
         cContTel := AllTrim( field->cont_tel )
      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN cContTel
