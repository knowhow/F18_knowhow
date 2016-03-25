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

STATIC __tezinski_barkod := NIL



FUNCTION param_tezinski_barkod( read_par )

   IF read_par != NIL
      __tezinski_barkod := fetch_metric( "barkod_tezinski_barkod", nil, "N" )
   ENDIF

   RETURN __tezinski_barkod


FUNCTION pos_postoji_roba( cId, dx, dy, barkod )

   LOCAL _zabrane
   LOCAL _i
   LOCAL _barkod := ""
   LOCAL _vrati := .F.
   LOCAL _tezina := 0
   LOCAL _order
   LOCAL _area := Select()
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   sif_uv_naziv( @cId )

   pos_unset_key_handler_ispravka_racuna()

   IF ValType( GetList ) == "A" .AND. Len( GetList ) > 1
      PrevId := GetList[ 1 ]:original
   ENDIF

   AAdd( ImeKol, { "Sifra", {|| id }, "" } )
   AAdd( ImeKol, { PadC( "Naziv", 40 ), {|| PadR( naz, 40 ) }, "" } )
   AAdd( ImeKol, { PadC( "JMJ", 5 ), {|| PadC( jmj, 5 ) }, "" } )
   AAdd( ImeKol, { "Cijena set: " + gSetMPCijena, {|| PadL( AllTrim( Str( pos_get_mpc(), 12, 3 ) ), 12 ) }, "" } )
   AAdd( ImeKol, { "BARKOD", {|| roba->barkod }, "" } )
   AAdd( ImeKol, { "K7", {|| roba->k7 }, "" } )

   FOR _i := 1 TO Len( ImeKol )
      AAdd( Kol, _i )
   NEXT

   IF pos_prodavac()
      _zabrane := { K_CTRL_T, K_CTRL_N, K_F4, K_F2, K_CTRL_F9 }
   ELSE
      _zabrane := {}
   ENDIF

   IF !tezinski_barkod( @cId, @_tezina )
      _barkod := barkod( @cId )
   ELSE
      _barkod := PadR( "T", 13 )
   ENDIF

   SELECT ( _area )

   _vrati := PostojiSifra( F_ROBA, "ID", MAXROWS() - 20, MAXCOLS() - 3, "Roba ( artikli ) ", @cId, NIL, NIL, NIL, NIL, NIL, _zabrane )

   IF LastKey() == K_ESC
      cId := PrevID
      _vrati := .F.
   ELSE

      @ m_x + dx, m_y + dy SAY PadR( AllTrim( roba->naz ) + " (" + AllTrim( roba->jmj ) + ")", 50 )

      IF _tezina <> 0
         _kolicina := _tezina
      ENDIF

      IF roba->tip <> "T"
         _cijena := pos_get_mpc()
      ENDIF

   ENDIF

   IF fetch_metric( "pos_kontrola_cijene_pri_unosu_stavke", nil, "N" ) == "D"
      IF Round( _cijena, 5 ) == 0
         MsgBeep( "Cijena 0.00, ne mogu napraviti račun !!!" )
         _vrati := .F.
      ENDIF
   ENDIF

   pos_set_key_handler_ispravka_racuna()

   barkod := _barkod

   SELECT roba
   SET ORDER TO TAG "ID"

   SELECT ( _area )

   RETURN _vrati




FUNCTION sif_uv_naziv( cId )

   LOCAL nIdLen

   IF gSifUvPoNaz == "N"
      RETURN
   ENDIF
   IF Empty( cId )
      RETURN
   ENDIF
   IF Len( AllTrim( cID ) ) == 10
      RETURN
   ENDIF
   IF Right( AllTrim( cID ), 1 ) == "."
      RETURN
   ENDIF
   cId := PadR( AllTrim( cId ) + ".", 10 )

   RETURN
