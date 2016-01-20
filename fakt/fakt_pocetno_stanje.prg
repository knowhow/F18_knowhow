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


#include "fakt.ch"



FUNCTION fakt_pocetno_stanje()

   LOCAL _param := hb_Hash()
   LOCAL _data := NIL
   LOCAL _ps := .T.
   LOCAL _n_br_dok
   LOCAL _count := 0
   LOCAL _ulaz, _izlaz, _stanje
   LOCAL _txt := ""
   LOCAL _partn_id := PadR( "10", 6 )

   IF fakt_lager_lista_vars( @_param, _ps ) == 0
      RETURN
   ENDIF

   MsgO( "Formiranje lager liste sql query u toku..." )

   _data := fakt_lager_lista_sql( _param, _ps )

   MsgC()

   IF _data == NIL
      MsgBeep( "Ne postoje traženi podaci !" )
      RETURN
   ENDIF

   MsgC()

   O_ROBA
   O_PARTN
   O_SIFK
   O_SIFV
   O_FAKT_PRIPR

   _n_br_dok := PadR( "00000", 8 )

   MsgO( "Formiranje dokumenta početnog stanja u toku... " )

   DO WHILE !_data:Eof()

      _row := _data:GetRow()

      _id_roba := hb_UTF8ToStr( _row:FieldGet( _row:FieldPos( "idroba" ) ) )
      _ulaz := _row:FieldGet( _row:FieldPos( "ulaz" ) )
      _izlaz := _row:FieldGet( _row:FieldPos( "izlaz" ) )
      _stanje := ( _ulaz - _izlaz )

      SELECT roba
      hseek _id_roba

      IF roba->tip == "U" .OR. Round( _stanje, 2 ) == 0
         _data:Skip()
         LOOP
      ENDIF

      SELECT partn
      hseek _partn_id

      SELECT fakt_pripr
      APPEND BLANK

      _rec := dbf_get_rec()

      _memo := ParsMemo( _rec[ "txt" ] )

      _rec[ "idfirma" ] := _param[ "id_firma" ]
      _rec[ "idtipdok" ] := "00"
      _rec[ "brdok" ] := _n_br_dok
      _rec[ "rbr" ] := RedniBroj( ++_count )
      _rec[ "datdok" ] := _param[ "datum_ps" ]
      _rec[ "dindem" ] := "KM "
      _rec[ "idpartner" ] := _partn_id
      _memo[ 2 ] := AllTrim( partn->naz ) + ", " + AllTrim( partn->mjesto )
      _memo[ 3 ] := "Početno stanje"
      _rec[ "txt" ] := fakt_memo_field_to_txt( _memo )
      _rec[ "idroba" ] := _id_roba
      _rec[ "kolicina" ] := _stanje
      _rec[ "cijena" ] := roba->vpc

      dbf_update_rec( _rec )

      _data:Skip()

   ENDDO

   MsgC()

   IF _count > 0
      MsgBeep( "Formiran dokument početnog stanja i nalazi se u pripremi !!!" )
   ENDIF

   RETURN