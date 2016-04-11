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


// --------------------------------------
// otvara tabele za unos podataka
// --------------------------------------
FUNCTION o_pk_tbl()

   SELECT F_PK_RADN
   IF !Used()
      O_PK_RADN
   ENDIF

   SELECT F_PK_DATA
   IF !Used()
      O_PK_DATA
   ENDIF

   RETURN



// ------------------------------------------
// brisanje poreske kartice radnika
// ------------------------------------------
FUNCTION pk_delete( cIdRadn )

   LOCAL nTA

   IF Pitanje(, "Izbrisati podatke poreske kartice radnika ?", "N" ) == "N"
      RETURN
   ENDIF

   nTA := Select()
   nCnt := 0

   o_pk_tbl()

   run_sql_query( "BEGIN" )
   f18_lock_tables( { "ld_pk_data", "ld_pk_radn" }, .T. )


   // izbrisi pk_radn
   SELECT pk_radn
   GO TOP
   SEEK cIdRadn

   DO WHILE !Eof() .AND. field->idradn == cIdRadn

      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "ld_pk_radn", _del_rec, 1, "CONT" )

      ++ nCnt
      SKIP

   ENDDO

   // izbrisi pk_data
   SELECT pk_data
   GO TOP
   SEEK cIdRadn

   IF Found()
      _del_rec := dbf_get_rec()
      delete_rec_server_and_dbf( "ld_pk_data", _del_rec, 2, "CONT" )
   ENDIF

   run_sql_query( "COMMIT" )
   f18_unlock_tables( { "ld_pk_data", "ld_pk_radn" } )


   IF nCnt > 0
      MsgBeep( "Izbrisano " + AllTrim( Str( nCnt ) ) + " zapisa !" )
   ENDIF

   RETURN .T.


// ------------------------------------
// vraca novi zahtjev
// ------------------------------------
FUNCTION n_zahtjev()

   LOCAL nRet := 0
   LOCAL nTArea := Select()
   LOCAL nBroj := 9999999

   SELECT pk_radn
   SET ORDER TO TAG "2"

   SEEK nBroj
   SKIP -1

   IF field->zahtjev = 0
      nRet := 1
   ELSE
      nRet := field->zahtjev + 1
   ENDIF

   SET ORDER TO TAG "1"

   SELECT ( nTArea )

   RETURN nRet



// --------------------------------
// vraca srodstvo za "kod"
// --------------------------------
FUNCTION g_srodstvo( nId )

   LOCAL cRet := "???"
   LOCAL aPom
   LOCAL nScan

   // napuni matricu sa srodstvima
   aPom := a_srodstvo()

   nScan := AScan( aPom, {| xVal| xVal[ 1 ] = nId } )

   IF nScan <> 0
      cRet := aPom[ nScan, 2 ]
   ENDIF

   RETURN cRet



// ---------------------------------------------
// vraca matricu popunjenu sa srodstvima
// ---------------------------------------------
FUNCTION a_srodstvo()

   LOCAL aRet := {}

   AAdd( aRet, { 1, "Otac" } )
   AAdd( aRet, { 2, "Majka" } )
   AAdd( aRet, { 3, "Otac supruznika" } )
   AAdd( aRet, { 4, "Majka supruznika" } )
   AAdd( aRet, { 5, "Sin" } )
   AAdd( aRet, { 6, "Kcerka" } )
   AAdd( aRet, { 7, "Unuk" } )
   AAdd( aRet, { 8, "Unuka" } )
   AAdd( aRet, { 9, "Djed" } )
   AAdd( aRet, { 10, "Baka" } )
   AAdd( aRet, { 11, "Djed supruznika" } )
   AAdd( aRet, { 12, "Baka supruznika" } )
   AAdd( aRet, { 13, "Bivsi supruznik" } )
   AAdd( aRet, { 14, "Poocim" } )
   AAdd( aRet, { 15, "Pomajka" } )
   AAdd( aRet, { 16, "Poocim supruznika" } )
   AAdd( aRet, { 17, "Pomajka supruznika" } )
   AAdd( aRet, { 18, "Pocerka" } )
   AAdd( aRet, { 19, "Posinak" } )

   RETURN aRet


// -----------------------------------------
// lista srodstva u GET rezimu na unosu
// odabir srodstva
// -----------------------------------------
FUNCTION sr_list( nSrodstvo )

   LOCAL nXX := m_x
   LOCAL nYY := m_y

   IF nSrodstvo > 0
      RETURN .T.
   ENDIF

   // napuni matricu sa srodstvima
   aSrodstvo := a_srodstvo()

   // odaberi element
   nSrodstvo := _pick_srodstvo( aSrodstvo )

   m_x := nXX
   m_y := nYY

   RETURN .T.

// -----------------------------------------
// uzmi element...
// -----------------------------------------
STATIC FUNCTION _pick_srodstvo( aSr )

   LOCAL nChoice := 1
   LOCAL nRet
   LOCAL i
   LOCAL cPom
   PRIVATE GetList := {}
   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   FOR i := 1 TO Len( aSr )

      cPom := PadL( AllTrim( Str( aSr[ i, 1 ] ) ), 2 ) + ". " + PadR( aSr[ i, 2 ], 20 )

      AAdd( opc, cPom )
      AAdd( opcexe, {|| nChoice := izbor, izbor := 0 } )

   NEXT

   Menu_sc( "izbor" )

   IF LastKey() == K_ESC

      nChoice := 0
      nRet := 0

   ELSE
      nRet := aSr[ nChoice, 1 ]
   ENDIF

   RETURN nRet


// -------------------------------------------------
// vraca odbitak za clanove po identifikatoru
// -------------------------------------------------
FUNCTION lo_clan( cIdent, cIdRadn )

   LOCAL nOdb := 0
   LOCAL nTArea := Select()

   SELECT pk_data
   SET ORDER TO TAG "1"

   SEEK cIdRadn + cIdent

   DO WHILE !Eof() .AND. field->idradn == cIdRadn ;
         .AND. field->ident == cIdent

      nOdb += field->koef
      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN nOdb


// ----------------------------------------------
// setovanje datuma za sve poreske kartice
// ----------------------------------------------
FUNCTION pk_set_date()

   LOCAL nTArea := Select()
   LOCAL dN_date
   LOCAL dT_date
   LOCAL cGrDate
   LOCAL nCnt := 0
   LOCAL _rec

   IF g_date( @dT_date, @dN_date, @cGrDate ) == 0
      RETURN
   ENDIF

   SELECT pk_radn
   SET ORDER TO TAG "1"

   GO TOP

   DO WHILE !Eof()

      IF ( cGrDate == "D" )
         IF ( field->datum <= dT_date )
            _rec := dbf_get_rec()
            _rec[ "datum" ] := dN_date
            update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
            ++ nCnt
         ENDIF
      ELSE
         _rec := dbf_get_rec()
         _rec[ "datum" ] := dN_date
         update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
         ++ nCnt
      ENDIF

      SKIP
   ENDDO

   IF nCnt > 0
      MsgBeep( "izvrsene " + AllTrim( Str( nCnt ) ) + " promjene !!!" )
   ENDIF

   SELECT ( nTArea )

   RETURN


STATIC FUNCTION g_date( dTmp_date, dDate, cGrDate )

   LOCAL nRet := 1
   PRIVATE GetList := {}

   dDate := CToD( "01.01.09" )
   dTmp_date := Date()
   cGrDate := "N"

   Box(, 4, 65 )
   @ m_x + 1, m_y + 2 SAY "postavi tekuci datum na:" GET dDate
   @ m_x + 2, m_y + 2 SAY "gledati granicni datum ?" GET cGrDate ;
      VALID cGrDate $ "DN" PICT "@!"
   READ

   IF cGrDate == "D"
      @ m_x + 3, m_y + 2 SAY "<= od" GET dTmp_Date
      READ
   ENDIF

   BoxC()

   IF LastKey() == K_ESC
      nRet := 0
   ENDIF

   RETURN nRet
