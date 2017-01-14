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


// ------------------------------------------------------------------
// pos, uzimanje novog broja za tops dokument
// ------------------------------------------------------------------
FUNCTION pos_novi_broj_dokumenta( id_pos, tip_dokumenta, dat_dok )

   LOCAL _broj := 0
   LOCAL _broj_doks := 0
   LOCAL _param
   LOCAL _tmp, _rest
   LOCAL _ret := ""
   LOCAL nDbfArea := Select()

   IF dat_dok == NIL
      dat_dok := gDatum
   ENDIF

   _param := "pos" + "/" + id_pos + "/" + tip_dokumenta
   _broj := fetch_metric( _param, nil, _broj )

   o_pos_doks()
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_pos + tip_dokumenta + DToS( dat_dok ) + "Ž"
   SKIP -1

   IF field->idpos == id_pos .AND. field->idvd == tip_dokumenta .AND. DToS( field->datum ) == DToS( dat_dok )
      _broj_doks := Val( field->brdok )
   ELSE
      _broj_doks := 0
   ENDIF

   _broj := Max( _broj, _broj_doks )

   ++_broj

   _ret := PadL( AllTrim( Str( _broj ) ), 6  )

   set_metric( _param, nil, _broj )

   SELECT ( nDbfArea )

   RETURN _ret


FUNCTION pos_set_param_broj_dokumenta()

   LOCAL _param
   LOCAL _broj := 0
   LOCAL _broj_old
   LOCAL _id_pos := gIdPos
   LOCAL _tip_dok := "42"

   Box(, 2, 60 )

   @ m_x + 1, m_y + 2 SAY "Dokument:" GET _id_pos
   @ m_x + 1, Col() + 1 SAY "-" GET _tip_dok

   READ

   IF LastKey() == K_ESC
      BoxC()
      RETURN
   ENDIF

   _param := "pos" + "/" + _id_pos + "/" + _tip_dok
   _broj := fetch_metric( _param, nil, _broj )
   _broj_old := _broj

   @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "999999"

   READ

   BoxC()

   IF LastKey() != K_ESC
      IF _broj <> _broj_old
         set_metric( _param, nil, _broj )
      ENDIF
   ENDIF

   RETURN .T.



FUNCTION pos_reset_broj_dokumenta( id_pos, tip_dok, broj_dok )

   LOCAL _param
   LOCAL _broj := 0

   _param := "pos" + "/" + id_pos + "/" + tip_dok
   _broj := fetch_metric( _param, nil, _broj )

   IF Val( AllTrim( broj_dok ) ) == _broj
      --_broj
      set_metric( _param, nil, _broj )
   ENDIF

   RETURN .T.
