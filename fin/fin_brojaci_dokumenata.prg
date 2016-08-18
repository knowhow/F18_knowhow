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


FUNCTION fin_novi_broj_dokumenta( firma, tip_dokumenta )

   LOCAL _broj := 0
   LOCAL _broj_nalog := 0
   LOCAL _len_broj := 8
   LOCAL _param
   LOCAL _tmp, _rest
   LOCAL _ret := ""
   LOCAL _t_area := Select()

   // obratiti paznju na gBrojacFinNaloga... 1 ili 2
   // 1 - idfirma + idvn + brnal
   // 2 - idfirma + brnal

   // param: fin/10/10
   _param := "fin" + "/" + firma + "/" + tip_dokumenta

   IF gBrojacFinNaloga == "2"
      _param := "fin" + "/" + firma
   ENDIF

   _broj := fetch_metric( _param, nil, _broj )

   // konsultuj i doks uporedo
   IF gBrojacFinNaloga == "2" // Brojac naloga: 1 - (firma,vn,brnal), 2 - (firma,brnal)
      find_nalog_by_broj_dokumenta( firma, tip_dokumenta, NIL, "idfirma,brnal" )
   ELSE
      find_nalog_by_broj_dokumenta( firma, tip_dokumenta )

   ENDIF
   GO BOTTOM

   IF field->idfirma == firma .AND. iif( gBrojacFinNaloga == "1", field->idvn == tip_dokumenta, .T. )
      _broj_nalog := Val( field->brnal )
   ELSE
      _broj_nalog := 0
   ENDIF


   _broj := Max( _broj, _broj_nalog ) // uzmi sta je vece, nalog broj ili globalni brojac
   ++ _broj

   _ret := PadL( AllTrim( Str( _broj ) ), _len_broj, "0" ) // ovo ce napraviti string prave duzine

   set_metric( _param, nil, _broj ) // upisi ga u globalni parametar

   SELECT ( _t_area )

   RETURN _ret



FUNCTION fin_set_broj_dokumenta()

   LOCAL _broj_dokumenta
   LOCAL _t_rec, _rec
   LOCAL _firma, _td, _null_brdok
   LOCAL _len_broj := 8

   PushWA()

   SELECT fin_pripr
   GO TOP

   _null_brdok := fin_prazan_broj_naloga()

   IF field->brnal <> _null_brdok
      // nemam sta raditi, broj je vec setovan
      PopWa()
      RETURN .F.
   ENDIF

   _firma := field->idfirma
   _td := field->idvn

   // daj mi novi broj dokumenta
   _broj_dokumenta := fin_novi_broj_dokumenta( _firma, _td )

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      IF field->idfirma == _firma .AND. field->idvn == _td .AND. field->brnal == _null_brdok
         _rec := dbf_get_rec()
         _rec[ "brnal" ] := _broj_dokumenta
         dbf_update_rec( _rec )
      ENDIF

      GO ( _t_rec )

   ENDDO

   PopWa()

   RETURN .T.





// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
FUNCTION fin_set_param_broj_dokumenta()

   LOCAL _param
   LOCAL _broj := 0
   LOCAL _broj_old
   LOCAL _firma := gFirma
   LOCAL _tip_dok := "10"

   Box(, 2, 60 )

   @ m_x + 1, m_y + 2 SAY "Nalog:" GET _firma

   IF gBrojacFinNaloga == "1"
      @ m_x + 1, Col() + 1 SAY "-" GET _tip_dok
   ENDIF

   READ

   IF LastKey() == K_ESC
      BoxC()
      RETURN
   ENDIF

   // param: fin/10/10
   IF gBrojacFinNaloga == "1"
      _param := "fin" + "/" + _firma + "/" + _tip_dok
   ELSE
      _param := "fin" + "/" + _firma
   ENDIF

   _broj := fetch_metric( _param, nil, _broj )
   _broj_old := _broj

   @ m_x + 2, m_y + 2 SAY "Zadnji broj naloga:" GET _broj PICT "99999999"

   READ

   BoxC()

   IF LastKey() != K_ESC
      // snimi broj u globalni brojac
      IF _broj <> _broj_old
         set_metric( _param, nil, _broj )
      ENDIF
   ENDIF

   RETURN .T.
