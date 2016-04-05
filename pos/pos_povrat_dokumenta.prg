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


FUNCTION pos_brisi_dokument( id_pos, id_vd, dat_dok, br_dok )

   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL _rec
   LOCAL nTArea := Select()
   LOCAL cDokument

   IF !pos_dokument_postoji( id_pos, id_vd, dat_dok, br_dok )
      RETURN lRet
   ENDIF

   sql_table_update( nil, "BEGIN" )
   IF !f18_lock_tables( { "pos_pos", "pos_doks" }, .T. )
      sql_table_update( nil, "END" )
      SELECT ( _t_area )
      RETURN _ret
   ENDIF

   MsgO( "Brisanje dokumenta iz glavne tabele u toku ..." )

   cDokument := ALLTRIM( id_pos ) + "-" + id_vd + "-" + ALLTRIM( br_dok ) + " " + DTOC( dat_dok )

   SELECT pos
   SET ORDER TO TAG "1"
   GO TOP

   SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

   IF Found()
      _rec := dbf_get_rec()
      lOk := delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT" )
   ENDIF

   IF lOk
      SELECT pos_doks
      SET ORDER TO TAG "1"
      GO TOP
      SEEK id_pos + id_vd + DToS( dat_dok ) + br_dok

      IF Found()
         _rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
      ENDIF
   ENDIF

   MsgC()

   IF lOk
      lRet := .T.
      f18_free_tables( { "pos_pos", "pos_doks" } )
      sql_table_update( nil, "END" )
      log_write( "F18_DOK_OPER, izbrisan pos dokument: " + cDokument, 2 )
   ELSE
      sql_table_update( nil, "ROLLBACK" )
      log_write( "F18_DOK_OPER, greška sa brisanjem pos dokumenta: " + cDokument, 2 )
   ENDIF

   SELECT ( nTArea )

   RETURN lRet





FUNCTION pos_dokument_postoji( cIdPos, cIdvd, dDatum, cBroj )

   LOCAL lRet := .F.
   LOCAL cWhere

   cWhere := "idpos = " + sql_quote( cIdPos )
   cWhere += " AND idvd = " + sql_quote( cIdVd )
   cWhere += " AND datum = " + sql_quote( dDatum )
   cWhere += " AND brdok = " + sql_quote( cBroj )

   IF table_count( F18_PSQL_SCHEMA_DOT + "pos_doks", cWhere ) > 0
      lRet := .T.
   ENDIF

   IF !lRet
      IF table_count( F18_PSQL_SCHEMA_DOT + "pos_pos", cWhere ) > 0
         lRet := .T.
      ENDIF
   ENDIF

   RETURN lRet





FUNCTION pos_povrat_rn( cSt_rn, dSt_date )

   LOCAL nTArea := Select()
   LOCAL _rec
   LOCAL nCount := 0
   PRIVATE GetList := {}

   IF Empty( cSt_rn )
      SELECT ( nTArea )
      RETURN
   ENDIF

   cSt_rn := PadL( AllTrim( cSt_rn ), 6 )

   SELECT pos
   SEEK gIdPos + "42" + DToS( dSt_date ) + cSt_rn

   MsgO( "Povrat dokumenta u pripremu ... " )

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

      ++ nCount

      SELECT pos

      SKIP

   ENDDO

   msgC()

   IF nCount > 0
      log_write( "F18_DOK_OPER, povrat dokumenta u pripremu: " + ;
             ALLTRIM( gIdPos ) + "-" + VD_RN + "-" + ALLTRIM( cSt_rn ) + " " + DTOC( dSt_date), 2 )
   ENDIF

   pos_brisi_dokument( gIdPos, VD_RN, dSt_date, cSt_rn )

   SELECT ( nTArea )

   RETURN




STATIC FUNCTION odaberi_opciju_povrata_dokumenta()

   LOCAL _ch := "1"

   Box(, 3, 50 )
   @ m_x + 1, m_y + 2 SAY8 "Priprema nije prazna, šta dalje ? "
   @ m_x + 2, m_y + 2 SAY " (1) brisati pripremu  "
   @ m_x + 3, m_y + 2 SAY8 " (2) spojiti na postojeći dokument " GET _ch VALID _ch $ "12"
   READ
   BoxC()

   IF LastKey() == K_ESC
      _ch := "0"
      RETURN _ch
   ENDIF

   RETURN _ch




FUNCTION pos_povrat_dokumenta_u_pripremu()

   LOCAL cDokument
   LOCAL nCount := 0
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

   cDokument := ALLTRIM( pos_doks->idpos ) + "-" + pos_doks->idvd + "-" + ALLTRIM( pos_doks->brdok ) + " " + DToC( pos_doks->datum )

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
         HSEEK _rec[ "idroba" ]

         IF !Found()
            APPEND BLANK
         ELSE
            _exist := dbf_get_rec()
            _rec[ "kol2" ] := _rec[ "kol2" ] + _exist[ "kol2" ]
         ENDIF

      ENDIF

      dbf_update_rec( _rec )

      ++ nCount

      SELECT pos
      SKIP

   ENDDO

   MsgC()

   SELECT ( _t_area )

   IF nCount > 0
      log_write( "F18_DOK_OPER: povrat dokumenta u pripremu: " + cDokument, 2 )
   ENDIF

   RETURN
