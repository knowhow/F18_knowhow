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


// id partner
STATIC __partn
STATIC __ugov
STATIC __dest_len
STATIC _x_pos
STATIC _y_pos

// ----------------------------------
// pregled destinacije
// ----------------------------------
FUNCTION p_dest_2( cId, cPartId, dx, dy )

   LOCAL nArr := Select()
   LOCAL cHeader := ""
   LOCAL cFooter := ""
   LOCAL xRet
   PRIVATE ImeKol
   PRIVATE Kol

   _x_pos := MAXROWS() - 15
   _y_pos := MAXCOLS() - 5

   cHeader += "Destinacije za: "
   cHeader += cPartId
   cHeader += "-"
   cHeader += PadR( Ocitaj( F_PARTN, cPartId, "naz" ), 20 ) + ".."

   SELECT dest
   SET ORDER TO TAG "IDDEST"

   IF !Empty( cPartId )
      __partn := cPartId
   ELSE
      __partn := Space( 6 )
   ENDIF

   __ugov := ugov->id
   __dest_len := 6

   // postavi filter
   set_f_tbl( cPartId )

   // setuj kolone
   set_a_kol( @ImeKol, @Kol )

   xRet := PostojiSifra( F_DEST, "IDDEST", _x_pos, _y_pos, cHeader, @cId, dx, dy, {| Ch| key_handler( Ch ) } )

   SET FILTER TO

   SELECT ( nArr )

   RETURN xRet


// setovanje filtera na tabeli destinacija
STATIC FUNCTION set_f_tbl( cPart )

   LOCAL cFilt := ".t."

   IF cPart <> NIL .AND. !Empty( cPart )
      cFilt += ".and. idpartner == " + dbf_quote( cPart )
   ENDIF

   IF cFilt == ".t."
      cFilt := ""
   ENDIF

   IF !Empty( cFilt )
      SET FILTER to &cFilt
   ELSE
      SET FILTER TO
   ENDIF

   GO TOP

   RETURN .T.


// ----------------------------------------------------
// setovanje kolona tabele
// ----------------------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   LOCAL i

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { "Naziv", {|| PadR( AllTrim( naziv ) + "/" + AllTrim( naziv2 ), 50 ) }, "naziv" } )
   AAdd( aImeKol, { "Mjesto", {|| PadR( AllTrim( mjesto ) + "/" + AllTrim( adresa ), 20 ) }, "mjesto" } )
   AAdd( aImeKol, { "Telefon", {|| PadR( telefon, 10 ) }, "telefon" } )
   AAdd( aImeKol, { "Fax", {|| PadR( fax, 10 ) }, "fax" } )
   AAdd( aImeKol, { "Mobitel", {|| PadR( mobitel, 10 ) }, "mobitel" } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN



// --------------------------------
// key handler
// --------------------------------
STATIC FUNCTION key_handler( Ch )

   @ m_x + 17, 6 SAY "<S> setuj kao def.destin.za fakturisanje"

   DO CASE
   CASE Ch == K_CTRL_N

      edit_dest( .T. )
      RETURN 7

   CASE Ch == K_F2

      edit_dest( .F. )
      RETURN 7

   CASE Upper( Chr( Ch ) ) == "S"

      // set as default...
      set_as_default( __ugov, id )

   ENDCASE

   RETURN DE_CONT


// ----------------------------------------------------
// vraca novi broj destinacije
// ----------------------------------------------------
STATIC FUNCTION n_dest_id()

   LOCAL xRet := "  1"
   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()
   LOCAL cTBFilter := dbFilter()

   SELECT dest
   SET FILTER TO
   SET ORDER TO TAG "IDDEST"
   GO BOTTOM

   xRet := PadL( AllTrim( Str( Val( field->id ) + 1 ) ), __dest_len, "0" )

   SET ORDER TO TAG "ID"

   SELECT ( nTArea )
   SET FILTER to &cTbFilter
   GO ( nTRec )

   RETURN xRet



// -----------------------------------
// edit destinacije
// -----------------------------------
STATIC FUNCTION edit_dest( lNova )

   LOCAL nRec
   LOCAL nBoxLen := 20
   LOCAL nX := 1
   LOCAL _rec
   PRIVATE GetList := {}

   IF lNova
      nRec := RecNo()
      GO BOTTOM
      SKIP 1
   ENDIF

   // bivsi scatter()
   set_global_memvars_from_dbf()

   IF lNova

      _idpartner := __partn
      // uvecaj id automatski
      _id := n_dest_id()
      _mjesto := Space( Len( _mjesto ) )
      _adresa := Space( Len( _adresa ) )
      _naziv := Space( Len( _naziv ) )
      _naziv2 := Space( Len( _naziv2 ) )
      _telefon := Space( Len( _telefon ) )
      _fax := Space( Len( _fax ) )
      _mobitel := Space( Len( _mobitel ) )
      _ptt := Space( Len( _mobitel ) )

   ENDIF

   Box(, 16, 75 )

   IF lNova
      @ m_x + nX, m_y + 2 SAY PadL( "*** Unos nove destinacije", 65 )
   ELSE

      @ m_x + nX, m_y + 2 SAY PadL( "*** Ispravka destinacije", 65 )
   ENDIF

   ++nX

   @ m_x + nX, m_y + 2 SAY PadR( "Partner: " + AllTrim( _idpartner ) + " , dest.rbr: " + AllTrim( _id ), 70 )

   nX += 2

   @ m_x + nX, m_y + 2 SAY PadL( "Naziv:", nBoxLen ) GET _naziv

   ++ nX

   @ m_x + nX, m_y + 2 SAY PadL( "Naziv 2:", nBoxLen ) GET _naziv2

   ++ nX

   @ m_x + nX, m_y + 2 SAY PadL( "Mjesto:", nBoxLen ) GET _mjesto

   ++ nX

   @ m_x + nX, m_y + 2 SAY PadL( "Adresa:", nBoxLen ) GET _adresa

   ++ nX

   @ m_x + nX, m_y + 2 SAY PadL( "PTT:", nBoxLen ) GET _ptt

   ++ nX

   @ m_x + nX, m_y + 2 SAY PadL( "Telefon:", nBoxLen ) GET _telefon

   ++ nX

   @ m_x + nX, m_y + 2 SAY PadL( "Fax:", nBoxLen ) GET _fax

   ++ nX

   @ m_x + nX, m_y + 2 SAY PadL( "Mobitel:", nBoxLen ) GET _mobitel

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN DE_CONT
   ENDIF

   IF lNova
      APPEND BLANK
   ENDIF

   // bivsi gather()
   _rec := get_hash_record_from_global_vars()
   update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )

   IF lNova
      GO ( nRec )
   ENDIF

   RETURN 7


// --------------------------------------------
// vraca info o destinaciji
// --------------------------------------------
FUNCTION get_dest_info( cPartn, cDest, nLen )

   LOCAL xRet := "---"
   LOCAL nTArea := Select()

   IF nLen == nil
      nLen := 15
   ENDIF

   SELECT dest
   SET ORDER TO TAG "ID"
   HSEEK cPartn + cDest

   IF Found()
      IF cPartn == field->idpartner .AND. cDest == field->id
         xRet := AllTrim( field->naziv ) + ":" + AllTrim( field->naziv2 ) + ":" + AllTrim( field->adresa )
      ENDIF
   ENDIF

   xRet := PadR( xRet, nLen )

   SELECT ( nTArea )

   RETURN xRet


// --------------------------------------------
// vraca box info o destinaciji
// --------------------------------------------
FUNCTION get_dest_binfo( nX, nY, cPartn, cDest )

   LOCAL xRet := "---"
   LOCAL nTArea := Select()
   LOCAL _len := 65

   nX := nX + 3
   SELECT dest
   SET ORDER TO TAG "ID"
   GO TOP
   HSEEK cPartn + cDest

   IF Found()
      IF cPartn == field->idpartner .AND. cDest == field->id

         cPom := AllTrim( field->naziv ) + ", " + AllTrim( field->naziv2 )

         @ nX, 2 SAY Space( _len ) COLOR F18_COLOR_I
         @ nX, 2 SAY PadR( cPom, _len ) COLOR F18_COLOR_I

         cPom := AllTrim( field->adresa ) + ", " + AllTrim( field->telefon )

         @ nX + 1, 2 SAY Space( _len ) COLOR F18_COLOR_I
         @ nX + 1, 2 SAY PadR( cPom, _len ) COLOR F18_COLOR_I

      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN


// ----------------------------------------
// set default destinacija
// ----------------------------------------
FUNCTION set_as_default( cUgovId, cDest )

   LOCAL nTArea := Select()
   LOCAL nRec
   LOCAL _rec

   IF Pitanje(, "Setovati kao glavnu destinaciju fakturisanja (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   SELECT ugov
   SET ORDER TO TAG "ID"
   nRec := RecNo()
   SEEK cUgovId

   IF Found()
      _rec := dbf_get_rec()
      _rec[ "def_dest" ] := cDest
      update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
      MsgBeep( "Destinacija '" + AllTrim( cDest ) + "' setovana#za ugovor " + cUgovId + " !!!" )
   ENDIF

   SELECT ugov
   GO ( nRec )

   SELECT ( nTArea )

   RETURN
