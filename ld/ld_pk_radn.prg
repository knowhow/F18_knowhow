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

// identifikatori za tabelu clanova
STATIC I_BR_DR := "1"
STATIC I_IZ_DJ := "2"
STATIC I_CL_P := "3"
STATIC I_CL_PI := "4"


/*
FUNCTION p_kartica( cIdRadn )

   LOCAL nZ_id := 0
   LOCAL lNew := .T.
   LOCAL nRet := 0

   o_pk_tbl()

   SELECT pk_radn
   SET ORDER TO TAG "1"
   SEEK cIdRadn

   IF Found() .AND. field->idradn == cIdRadn
      lNew := .F.
   ELSE
      lNew := .T.
   ENDIF

   // pronadji novi zahtjev za radnika...
   IF lNew == .T.
      nZ_id := n_zahtjev()
   ENDIF

   // unos osnovnih podataka
   nRet := unos_osn( lNew, cIdRadn, nZ_id )

   RETURN nRet

// ----------------------------------------------
// unos osnovnih podataka
// ----------------------------------------------
STATIC FUNCTION unos_osn( lNew, cIdRadn, nZ_id )

   LOCAL nX := 1
   LOCAL cClan := "N"
   LOCAL cLoPict := "9.999"
   LOCAL cPkColor := "W+/G+"

   SELECT pk_radn

   set_global_memvars_from_dbf()

   IF lNew == .T.

      cClan := "D"
      _idradn := cIdRadn
      _zahtjev := nZ_id
      _datum := Date()
      _r_ime := PadR( radn->ime, Len( _r_ime ) )
      _r_prez := PadR( radn->naz, Len( _r_prez ) )
      _r_imeoca := PadR( radn->imerod, Len( _r_imeoca ) )
      _r_jmb := PadR( radn->matbr, Len( _r_jmb ) )
      _r_adr := PadR( AllTrim( radn->streetname ) + ;
         " " + AllTrim( radn->streetnum ), Len( _r_adr ) )
      _r_opc := PadR( _g_r_opc( radn->idopsst ), Len( _r_opc ) )
      _r_opckod := PadR( _g_r_kopc( radn->idopsst ), Len( _r_opckod ) )
      _p_zap := "D"
      _p_naziv := PadR( _g_firma(), Len( _p_naziv ) )
      _p_jib := PadR( _g_f_jib(), Len( _p_jib ) )
      _lo_osn := 1
      _lo_izdj := 0
      _lo_brdr := 0
      _lo_clp := 0
      _lo_clpi := 0
      _lo_ufakt := 0
      _r_tel := 0


   ENDIF

   Box(, 22, 77 )

   @ m_x + nX, m_y + 2 SAY PadR( "*** unos osnovnih podataka", 76 ) ;
      COLOR cPkColor

   ++ nX

   @ m_x + nX, m_y + 2 SAY "zahtjev broj:" GET _zahtjev
   @ m_x + nX, Col() + 2 SAY "datum koeficijenta:" GET _datum

   ++ nX

   @ m_x + nX, m_y + 2 SAY "ime" GET _r_ime PICT "@S15"
   @ m_x + nX, Col() + 1 SAY "ime oca" GET _r_imeoca PICT "@S15"
   @ m_x + nX, Col() + 1 SAY "prezime" GET _r_prez PICT "@S20"

   ++ nX

   @ m_x + nX, m_y + 2 SAY "jmb" GET _r_jmb ;
      VALID {|| d_from_jmb( @_r_drodj, _r_jmb ) }

   @ m_x + nX, Col() + 1 SAY "adresa" GET _r_adr PICT "@S30"

   ++ nX

   @ m_x + nX, m_y + 2 SAY "opcina prebivalista" GET _r_opc PICT "@S15"
   @ m_x + nX, Col() + 1 SAY "'kod':" GET _r_opckod PICT "@S10"

   ++ nX

   @ m_x + nX, m_y + 2 SAY "datum rodjenja" GET _r_drodj
   @ m_x + nX, Col() + 1 SAY "telefon" GET _r_tel

   ++ nX
   ++ nX

   @ m_x + nX, m_y + 2 SAY PadR( "*** podaci o poslodavcu", 76 ) ;
      COLOR cPkColor

   ++ nX

   @ m_x + nX, m_y + 2 SAY "poslodavac" GET _p_naziv PICT "@S30"
   @ m_x + nX, Col() + 1 SAY "JIB" GET _p_jib

   ++ nX

   @ m_x + nX, m_y + 2 SAY "zaposlen (D/N)" GET _p_zap ;
      VALID _p_zap $ "DNX" PICT "@!"

   ++ nX
   ++ nX

   @ m_x + nX, m_y + 2 SAY PadR( "*** podaci o clanovima porodice", 76 ) ;
      COLOR cPkColor

   ++ nX

   @ m_x + nX, m_y + 2 SAY "unos podataka o uzdrzavanim clanovima" ;
      GET cClan ;
      VALID cClan $ "DN" PICT "@!"
   READ

   // izadji ako je kraj...
   IF LastKey() == K_ESC
      BoxC()
      RETURN -1
   ENDIF

   IF cClan == "D"

      // unos izdrzavanih clanova
      pk_data( cIdRadn )

      SELECT pk_radn

      // kalkulisi parametre licnih odbitaka
      _lo_brdr := lo_clan( I_BR_DR,  cIdRadn )
      _lo_izdj := lo_clan( I_IZ_DJ,  cIdRadn )
      _lo_clp := lo_clan( I_CL_P, cIdRadn )
      _lo_clpi := lo_clan( I_CL_PI, cIdRadn )

   ENDIF

   // total
   _lo_ufakt := _lo_osn + _lo_brdr + ;
      _lo_izdj + _lo_clp + _lo_clpi

   ++ nX
   ++ nX

   @ m_x + nX, m_y + 2 SAY PadR( "*** podaci o licnim odbicima", 76 ) ;
      COLOR cPkColor

   ++ nX
   @ m_x + nX, m_y + 2 SAY PadL( "osnovni odbitak:", 30 ) GET _lo_osn PICT cLoPict
   ++ nX
   @ m_x + nX, m_y + 2 SAY PadL( "bracni drug:", 30 ) GET _lo_brdr PICT cLoPict
   ++ nX
   @ m_x + nX, m_y + 2 SAY PadL( "izdr.djeca:", 30 ) GET _lo_izdj PICT cLoPict
   ++ nX
   @ m_x + nX, m_y + 2 SAY PadL( "clan.porodice:", 30 ) GET _lo_clp PICT cLoPict
   ++ nX
   @ m_x + nX, m_y + 2 SAY PadL( "clan.porodice inv.:", 30 ) GET _lo_clpi PICT cLoPict
   ++ nX
   @ m_x + nX, m_y + 2 SAY "----------------------------------------"
   ++ nX
   @ m_x + nX, m_y + 2 SAY PadL( "Ukupni faktor:", 30 ) GET _lo_ufakt PICT cLoPict

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN -1
   ENDIF

   IF lNew == .T.
      APPEND BLANK
   ENDIF


   _vals := get_hash_record_from_global_vars()
   update_rec_server_and_dbf( "ld_pk_radn", _vals, 1, "FULL" )

   RETURN field->lo_ufakt

*/


// ---------------------------------------
// vraca naziv firme
// ---------------------------------------
STATIC FUNCTION _g_firma()

   LOCAL cFNaziv := fetch_metric( "org_naziv", nil, PadR( "", 50 ) )
   LOCAL cFAdresa := fetch_metric( "org_adresa", nil, PadR( "", 50 ) )

   RETURN cFNaziv


// ---------------------------------------
// vraca naziv firme
// ---------------------------------------
STATIC FUNCTION _g_f_jib()

   LOCAL cFJmb := fetch_metric( "org_id_broj", nil, PadR( "", 13 ) )

   RETURN cFJMB


// ---------------------------------------
// vraca opcinu stanovanja radnika
// ---------------------------------------
STATIC FUNCTION _g_r_opc( cOpc )

   LOCAL nTArea := Select()
   LOCAL cRet := ""

   o_ops()
   SEEK cOpc

   cRet := field->naz

   SELECT ( nTArea )

   RETURN cRet


// ---------------------------------------
// vraca kod opcine stanovanja radnika
// ---------------------------------------
STATIC FUNCTION _g_r_kopc( cOpc )

   LOCAL nTArea := Select()
   LOCAL cRet := ""

   o_ops()
   SEEK cOpc

   cRet := field->puccity

   SELECT ( nTArea )

   RETURN cRet


// ------------------------------------
// vraca datum iz maticnog broja
// ------------------------------------
STATIC FUNCTION d_from_jmb( dDate, cJmb )

   LOCAL cDay
   LOCAL cMonth
   LOCAL cYear

   IF Empty( cJmb )
      RETURN .T.
   ENDIF

   // jmb: 0305978190028
   // date: 03.05.78

   cDay := SubStr( cJmb, 1, 2 )
   cMonth := SubStr( cJmb, 3, 2 )
   cYear := SubStr( cJmb, 6, 2 )

   dDate := CToD( cDay + "." + cMonth + "." + cYear )

   RETURN .T.
