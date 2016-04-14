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

STATIC __IDRADN := ""


// -------------------------------------------
// prikaz podataka o clanovima
// -------------------------------------------
FUNCTION pk_data( cId, dx, dy )

   LOCAL i
   LOCAL cHeader := ""
   PRIVATE ImeKol
   PRIVATE Kol

   __IDRADN := cID

   cHeader += "Podaci o izdrzavanim clanovima "

   SELECT pk_data
   SET FILTER TO

   // setuj filter
   set_filt( cId )

   // setuj kolone tabele
   set_a_kol( @ImeKol, @Kol )

   PostojiSifra( F_PK_DATA, 1, 10, 77, cHeader, ;
      nil, dx, dy, {| Ch| key_handler( Ch ) } )

   RETURN

// ------------------------------------------
// setuje filter na bazi
// ------------------------------------------
STATIC FUNCTION set_filt( cId )

   LOCAL cFilt := ""

   cFilt := "idradn == " + dbf_quote( cId )
   SET FILTER to &cFilt
   GO TOP

   RETURN


// -----------------------------------------
// setovanje kolona prikaza
// -----------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   LOCAL i

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { "ident.", {|| PadR( s_ident( ident ), 15 ) }, "ident"  } )
   AAdd( aImeKol, { "rbr.", {|| PadR( Str( rbr ), 3 ) }, "rbr"  } )
   AAdd( aImeKol, { "prezime i ime", {|| PadR( ime_pr, 15 ) + "..." }, "ime_pr"  } )
   AAdd( aImeKol, { "JMB", {|| jmb }, "jmb"  } )
   AAdd( aImeKol, { "k.srod", {|| sr_kod }, "sr_kod"  } )
   AAdd( aImeKol, { "naz.srodstva", {|| sr_naz }, "sr_naz"  } )
   AAdd( aImeKol, { "vl.prihod", {|| prihod }, "prihod"  } )
   AAdd( aImeKol, { "udio", {|| udio }, "udio"  } )
   AAdd( aImeKol, { "koef.", {|| koef }, "koef"  } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN


// --------------------------------
// key handler
// --------------------------------
STATIC FUNCTION key_handler( Ch )

   LOCAL GetList := {}
   LOCAL nRec := 0

   DO CASE

   CASE ( Ch == K_F2 )
      // ispravka stavke
      unos_clan( .F. )
      RETURN 7

   CASE ( Ch == K_CTRL_N )

      // nova stavka
      unos_clan( .T. )
      RETURN 7

   ENDCASE

   RETURN DE_CONT



// -----------------------------------
// unos clanova
// -----------------------------------
FUNCTION unos_clan( lNew )

   LOCAL nBoxLen := 10
   LOCAL nX
   LOCAL hParams

   Box(, 12, 70, .F. )

   DO WHILE .T.

      nX := 1

      set_global_memvars_from_dbf()

      IF lNew == .T.
         _idradn := __IDRADN
         _ident := " "
         _rbr := 0
         _ime_pr := PadR( "", Len( _ime_pr ) )
         _jmb := PadR( "", Len( _jmb ) )
         _sr_naz := PadR( "", Len( _sr_naz ) )
         _sr_kod := 0
         _prihod := 0
         _udio := 0
         _koef := 0
      ENDIF

      @ nXX := m_x + nX, nYY := m_y + 2 SAY PadL( "ident.", nBoxLen ) ;
         GET _ident ;
         WHEN lNew ;
         VALID {|| g_ident( @_ident ), ;
         _n_rbr( @_rbr, __IDRADN, _ident ), ;
         p_ident( _ident, nXX, nYY ) }

      ++ nX

      @ m_x + nX, m_y + 2 SAY PadL( "rbr", nBoxLen ) ;
         GET _rbr ;
         WHEN lNew ;
         VALID _g_koef( @_koef, _ident, _rbr ) ;
         PICT "999"

      ++ nX

      @ m_x + nX, m_y + 2 SAY PadL( "prez.i ime", nBoxLen ) ;
         GET _ime_pr ;
         VALID !Empty( _ime_pr )

      ++ nX

      @ m_x + nX, m_y + 2 SAY PadL( "jmb", nBoxLen ) ;
         GET _jmb ;
         VALID !Empty( _jmb )

      ++ nX

      @ m_x + nX, m_y + 2 SAY PadL( "'kod' sr.", nBoxLen ) ;
         GET _sr_kod ;
         WHEN _ident $ "34" ;
         VALID {|| sr_list( @_sr_kod ), ;
         _sr_naz := PadR( g_srodstvo( _sr_kod ), ;
         Len( _sr_naz ) ), .T. } ;
         PICT "99"

      ++ nX

      @ m_x + nX, m_y + 2 SAY PadL( "srodstvo", nBoxLen ) ;
         GET _sr_naz ;
         WHEN _ident $ "34"

      ++ nX

      @ m_x + nX, m_y + 2 SAY PadL( "vl.prihod", nBoxLen ) ;
         GET _prihod PICT "9999999.99"

      ++ nX

      @ m_x + nX, m_y + 2 SAY PadL( "udio", nBoxLen ) ;
         GET _udio PICT "999"

      ++ nX

      @ m_x + nX, m_y + 2 SAY PadL( "koef.", nBoxLen ) ;
         GET _koef PICT "9.999"

      READ


      run_sql_query( "BEGIN" )
      IF !f18_lock_tables( { "ld_pk_data" }, .T. )
         run_sql_query( "ROLLBACK" )
         RETURN .F.
      ENDIF

      IF LastKey() <> K_ESC

         IF lNew == .T.
            APPEND BLANK
         ENDIF

         _vals := get_dbf_global_memvars()
         update_rec_server_and_dbf( "ld_pk_data", _vals, 1, "CONT" )

         IF lNew == .F.
            EXIT
         ENDIF

      ENDIF

      hParams := hb_hash()
      hParams[ "unlock" ] := { "ld_pk_data" }
      run_sql_query( "COMMIT", hParams )

      IF LastKey() == K_ESC
         EXIT
      ENDIF

   ENDDO

   BoxC()

   RETURN 7


// ----------------------------------------------
// novi broj
// ----------------------------------------------
STATIC FUNCTION _n_rbr( nRbr, cIdRadn, cIdent )

   LOCAL nTArea := Select()
   LOCAL nTRec := RecNo()

   SELECT pk_data
   SET ORDER TO TAG "1"

   SEEK cIdRadn + cIdent

   nRbr := 0

   DO WHILE !Eof() .AND. field->idradn == cIdRadn ;
         .AND. field->ident == cIdent

      nRbr := field->rbr + 1

      SKIP
   ENDDO

   IF nRbr = 0
      nRbr := 1
   ENDIF

   GO ( nTRec )
   SELECT ( nTArea )

   RETURN .T.




// -------------------------------------------------
// funkcija vraca listu identifikatora
// -------------------------------------------------
STATIC FUNCTION g_ident( cIdent )

   LOCAL lRet := .F.

   IF cIdent $ "1234"
      lRet := .T.
   ENDIF

   RETURN lRet


// ----------------------------------------
// prikazi identifikator
// ----------------------------------------
STATIC FUNCTION p_ident( cIdent, nX, nY )

   LOCAL cVal := s_ident( cIdent )

   @ nX, nY + 20 SAY PadR( cVal, 20 )

   RETURN .T.


// ------------------------------------------
// daj vrijednost polja
// ------------------------------------------
STATIC FUNCTION s_ident( cIdent )

   LOCAL cVal := "?????"

   DO CASE
   CASE cIdent == "1"
      cVal := "bracni drug"
   CASE cIdent == "2"
      cVal := "izdr.djeca"
   CASE cIdent == "3"
      cVal := "clan porodice"
   CASE cIdent == "4"
      cVal := "clan por.inv."
   ENDCASE

   RETURN cVal



// ----------------------------------------------
// vraca koeficijent za clanove porodice
// ----------------------------------------------
STATIC FUNCTION _g_koef( nKoef, cIdent, nRbr )

   DO CASE
   CASE cIdent == "1"
      // bracni drug
      nKoef := 0.5
   CASE cIdent == "2"
      // djeca
      nKoef := _g_k_dj( nRbr )
   CASE cIdent == "3"
      // uzi clanovi porodice
      nKoef := 0.3
   CASE cIdent == "4"
      // uzi clanovi porodice - invalidi
      nKoef := 0.3
   ENDCASE

   RETURN .T.


// -----------------------------------------
// vraca koeficijent za djecu
// -----------------------------------------
STATIC FUNCTION _g_k_dj( nRbr )

   LOCAL nKoef := 0.5

   DO CASE
   CASE nRbr = 1
      nKoef := 0.5
   CASE nRbr = 2
      nKoef := 0.7
   CASE nRbr >= 3
      nKoef := 0.9
   ENDCASE

   RETURN nKoef
