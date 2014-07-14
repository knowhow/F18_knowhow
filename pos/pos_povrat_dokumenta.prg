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

#include "pos.ch"



FUNCTION pos_brisi_dokument( id_pos, id_vd, dat_dok, br_dok )

   LOCAL _ok := .T.
   LOCAL _t_area := Select()
   LOCAL _ret := .F.
   LOCAL _rec

   SELECT pos
   SET FILTER TO
   SET ORDER TO TAG "1"
   GO TOP
   SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

   IF !Found()

      // potrazi i u doks
      SELECT pos_doks
      SET FILTER TO
      SET ORDER TO TAG "1"
      GO TOP
      SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

      // nema ga stvarno !!!
      IF !Found()
         SELECT ( _t_area )
         RETURN _ret
      ENDIF

   ENDIF

   log_write( "F18_DOK_OPER: pos, brisanje racuna broj: " + br_dok + " od " + DToC( dat_dok ), 2 )
	           	
   IF !f18_lock_tables( { "pos_pos", "pos_doks" } )
      SELECT ( _t_area )
      RETURN _ret
   ENDIF

   sql_table_update( nil, "BEGIN" )

   _ret := .T.

   MsgO( "Brisanje dokumenta iz glavne tabele u toku ..." )

   SELECT pos
   GO TOP
   SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

   IF Found()
      _rec := dbf_get_rec()
      delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT" )
   ENDIF

   SELECT pos_doks
   GO TOP
   SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

   IF Found()
      _rec := dbf_get_rec()
      delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
   ENDIF

   f18_free_tables( { "pos_pos", "pos_doks" } )
   sql_table_update( nil, "END" )

   MsgC()

   SELECT ( _t_area )

   RETURN _ret



FUNCTION pos_povrat_rn( cSt_rn, dSt_date )

   LOCAL nTArea := Select()
   LOCAL _rec
   PRIVATE GetList := {}

   IF Empty( cSt_rn )
      SELECT ( nTArea )
      RETURN
   ENDIF

   cSt_rn := PadL( AllTrim( cSt_rn ), 6 )

   SELECT pos
   SEEK gIdPos + "42" + DToS( dSt_date ) + cSt_rn

   msgo( "Povrat dokumenta u pripremu ... " )

   DO WHILE !Eof() .AND. field->idpos == gIdPos ;
         .AND. field->brdok == cSt_rn ;
         .AND. field->idvd == "42"

      cT_roba := field->idroba
      SELECT roba
      SEEK cT_roba

      SELECT pos

      _rec := dbf_get_rec()
      hb_HDel( _rec, "rbr" )

      SELECT _pos_pripr
      APPEND BLANK

      _rec[ "robanaz" ] := roba->naz

      dbf_update_rec( _rec )

      SELECT pos

      SKIP

   ENDDO

   msgC()

   pos_brisi_dokument( gIdPos, VD_RN, dSt_date, cSt_rn )

   SELECT ( nTArea )

   RETURN




STATIC FUNCTION odaberi_opciju_povrata_dokumenta()

   LOCAL _ch := "1"

   Box(, 3, 50 )
   @ m_x + 1, m_y + 2 SAY "Priprema nije prazna, sta dalje ? "
   @ m_x + 2, m_y + 2 SAY " (1) brisati pripremu  "
   @ m_x + 3, m_y + 2 SAY " (2) spojiti na postojeci dokument " GET _ch VALID _ch $ "12"
   READ
   BoxC()

   IF LastKey() == K_ESC
      _ch := "0"
      RETURN _ch
   ENDIF

   RETURN _ch




FUNCTION pos_povrat_dokumenta_u_pripremu()

   LOCAL _rec
   LOCAL _t_area := Select()
   LOCAL _oper := "1"
   LOCAL _exist, _rec2

   O_PRIPRZ
   SELECT priprz

   IF RecCount() <> 0
      _oper := odaberi_opciju_povrata_dokumenta()
   ENDIF

   IF _oper == "1"
      my_dbf_zap()
   ENDIF

   IF _oper == "2"
      _rec2 := dbf_get_rec()
   ENDIF

   MsgO( "Vršim povrat dokumenta u pripremu ..." )

   SELECT pos
   SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

   DO WHILE !Eof() .AND. pos->( IdPos + IdVd + DToS( datum ) + BrDok ) == ;
         pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

      _rec := dbf_get_rec()

      hb_HDel( _rec, "rbr" )

      SELECT roba
      HSEEK _rec[ "idroba" ]

      _rec[ "robanaz" ] := roba->naz
      _rec[ "jmj" ] := roba->jmj
      _rec[ "barkod" ] := roba->barkod

      IF _oper == "2"
         _rec[ "idpos" ] := _rec2[ "idpos" ]
         _rec[ "idvd" ] := _rec2[ "idvd" ]
         _rec[ "brdok" ] := _rec2[ "brdok" ]
      ENDIF

      SELECT priprz

      IF _oper <> "2"
         APPEND BLANK
      ENDIF

      IF _oper == "2"

         SET ORDER TO TAG "1"
         hseek _rec[ "idroba" ]

         IF !Found()
            APPEND BLANK
         ELSE
            _exist := dbf_get_rec()
            _rec[ "kol2" ] := _rec[ "kol2" ] + _exist[ "kol2" ]
         ENDIF

      ENDIF

      dbf_update_rec( _rec )

      SELECT pos
      SKIP

   ENDDO

   MsgC()

   SELECT ( _t_area )

   RETURN



