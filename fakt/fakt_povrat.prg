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


FUNCTION povrat_fakt_dokumenta( rezerv, id_firma, id_tip_dok, br_dok, test )

   LOCAL _vars := hb_Hash()
   LOCAL lBrisatiKumulativ := .T.
   LOCAL hRec, _del_rec
   LOCAL _field_ids, _where_block
   LOCAL nTrec
   LOCAL oFaktAttr, _hAttrId
   LOCAL _ok := .T.
   LOCAL nRet := 0
   LOCAL hParams

   IF test == nil
      test := .F.
   ENDIF

   IF ( PCount() == 0 )
      _vars[ "idfirma" ]  := self_organizacija_id()
      _vars[ "idtipdok" ] := Space( 2 )
      _vars[ "brdok" ]    := Space( 8 )
   ELSE
      _vars[ "idfirma" ]  := id_firma
      _vars[ "idtipdok" ] := id_tip_dok
      _vars[ "brdok" ]    := br_dok
   ENDIF

   o_fakt_dbf()
   o_fakt_pripr()
   o_fakt_doks2_dbf()
   o_fakt_doks_dbf()

   SELECT fakt
   SET FILTER TO

   SET ORDER TO TAG "1"

   IF PCount() == 0
      IF !uslovi_za_povrat_dokumenta( @_vars )
         my_close_all_dbf()
         RETURN nRet
      ENDIF
   ENDIF

   IF !dokument_se_moze_vratiti_u_pripremu( _vars )
      my_close_all_dbf()
      RETURN nRet
   ENDIF

   id_firma   := _vars[ "idfirma" ]
   id_tip_dok := _vars[ "idtipdok" ]
   br_dok     := _vars[ "brdok" ]

   IF Pitanje( "FAKT_POV_DOK", "Dokument " + id_firma + "-" + id_tip_dok + "-" + br_dok + " vratiti u pripremu (D/N) ?", "D" ) == "N"
      my_close_all_dbf()
      RETURN nRet
   ENDIF

   SELECT fakt
   HSEEK id_firma + id_tip_dok + br_dok

   IF !Found()
      MsgBeep( "Traženi dokument ne postoji ažuriran u bazi !" )
   ENDIF

   IF ( fakt->m1 == "X" )
      MsgBeep( "Radi se o izgenerisanom dokumentu !" )
      IF Pitanje( "IZGEN_CONT", "Želite li nastaviti (D/N) ?", "N" ) == "N"
         my_close_all_dbf()
         RETURN nRet
      ENDIF
   ENDIF

   kopiraj_dokument_u_tabelu_pripreme( id_firma, id_tip_dok, br_dok )

   _hAttrId := hb_Hash()
   _hAttrId[ "idfirma" ] := id_firma
   _hAttrId[ "idtipdok" ] := id_tip_dok
   _hAttrId[ "brdok" ] := br_dok

   oFaktAttr := DokAttr():New( "fakt", F_FAKT_ATTR )
   oFaktAttr:hAttrId := _hAttrId
   oFaktAttr:get_attr_from_server_to_dbf()

   IF test == .T.
      lBrisatiKumulativ := .T.
   ELSE
      lBrisatiKumulativ := Pitanje( "FAKT_POV_KUM", "Želite li izbrisati dokument iz datoteke kumulativa (D/N) ?", "N" ) == "D"
   ENDIF

   IF !lBrisatiKumulativ
      resetuj_markere_generisanog_dokumenta( id_firma, id_tip_dok, br_dok )
   ENDIF

   IF lBrisatiKumulativ

      run_sql_query( "BEGIN" )

      IF !f18_lock_tables( { "fakt_fakt", "fakt_doks", "fakt_doks2" }, .T. )
         run_sql_query( "ROLLBACK" )
         MsgBeep( "Ne mogu zaključati fakt tablele.#Prekidam operaciju." )
         RETURN nRet
      ENDIF

      Box(, 5, 70 )

      @ m_x + 4, m_y + 2 SAY "brisanje : fakt_fakt_atributi"
      _ok := oFaktAttr:delete_attr_from_server()

      IF _ok
         _tbl := "fakt_fakt"
         @ m_x + 1, m_y + 2 SAY "brisanje : " + _tbl
         SELECT fakt
         _ok := delete_rec_server_and_dbf( _tbl, _vars, 2, "CONT" )
      ENDIF

      IF _ok
         _tbl := "fakt_doks"
         @ m_x + 2, m_y + 2 SAY "brisanje : " + _tbl
         SELECT fakt_doks
         _ok := delete_rec_server_and_dbf( _tbl, _vars, 1, "CONT" )
      ENDIF

      IF _ok
         _tbl := "fakt_doks2"
         @ m_x + 3, m_y + 2 SAY "brisanje : " + _tbl
         SELECT fakt_doks2
         _ok := delete_rec_server_and_dbf( _tbl, _vars, 1, "CONT" )
      ENDIF

      BoxC()

      IF _ok

         nRet := 1
         hParams := hb_Hash()
         hParams[ "unlock" ] := { "fakt_fakt", "fakt_doks", "fakt_doks2" }
         run_sql_query( "COMMIT", hParams )

         log_write( "F18_DOK_OPER: fakt povrat dokumenta u pripremu: " + id_firma + "-" + id_tip_dok + "-" + br_dok, 2 )

      ELSE

         run_sql_query( "ROLLBACK" )
         log_write( "F18_DOK_OPER: greška kod povrata dokumenta u pripremu: " + id_firma + "-" + id_tip_dok + "-" + br_dok, 2 )
         MsgBeep( "Greška kod povrata dokumenta u pripremu.#Operacija prekinuta." )

      ENDIF

   ENDIF

   my_close_all_dbf()

   RETURN nRet



/*
    Opis: resetuje markere generisanog dokumenta u pripremi nakon povrata dokumenta
 */

STATIC FUNCTION resetuj_markere_generisanog_dokumenta( cIdFirma, cIdTipDok, cBrDok )

   LOCAL hRec

   SELECT fakt_pripr
   SET ORDER TO TAG "1"
   HSEEK cIdFirma + cIdTipDok + cBrDok

   DO WHILE !Eof() .AND. fakt_pripr->( field->idfirma + field->idtipdok + field->brdok ) ==  cIdFirma + cIdTipDok + cBrDok
      IF fakt_pripr->m1 == "X"
         hRec := dbf_get_rec()
         hRec[ "m1" ] := Space( 1 )
         dbf_update_rec( hRec )
      ENDIF
      SKIP
   ENDDO

   RETURN .T.





STATIC FUNCTION kopiraj_dokument_u_tabelu_pripreme( cIdFirma, cIdTipDok, cBrDok )

   LOCAL hRec

   SELECT fakt

   DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cIdTipDok == field->idtipdok .AND. cBrDok == field->brdok

      SELECT fakt

      hRec := dbf_get_rec()

      SELECT fakt_pripr
      APPEND BLANK

      dbf_update_rec( hRec )

      SELECT fakt
      SKIP

   ENDDO

   RETURN .T.





FUNCTION fakt_povrat_po_kriteriju( br_dok, dat_dok, tip_dok, firma )

   LOCAL nRec
   LOCAL nTrec
   LOCAL _vars := hb_Hash()
   LOCAL _filter
   LOCAL _id_firma
   LOCAL _br_dok
   LOCAL _id_tip_dok
   LOCAL _del_rec
   LOCAL _ok := .T.
   LOCAL hParams

   IF PCount() <> 0

      _vars[ "br_dok" ] := PadR( br_dok, 200 )

      IF dat_dok == NIL
         dat_dok := CToD( "" )
      ENDIF

      _vars[ "datumi" ] := PadR( DToC( dat_dok ), 200 )

      IF tip_dok == NIL
         tip_dok := ";"
      ENDIF

      _vars[ "tip_dok" ] := PadR( tip_dok, 200 )
      _vars[ "rj" ] := self_organizacija_id()

   ELSE

      _vars[ "br_dok" ] := Space( 200 )
      _vars[ "datumi" ] := Space( 200 )
      _vars[ "tip_dok" ] := Space( 200 )
      _vars[ "rj" ] := self_organizacija_id()

   ENDIF

   o_fakt_dbf()
   o_fakt_pripr()
   o_fakt_doks_dbf()
   o_fakt_doks2_dbf()

   SELECT fakt_doks
   SET ORDER TO TAG "1"

   IF !uslovi_za_povrat_prema_kriteriju( @_vars )
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   Beep( 6 )

   IF Pitanje( "", "Da li ste sigurni da želite vratiti sve dokumente prema kriteriju (D/N) ?", "N" ) == "N"
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   _filter := _vars[ "uslov_dokumenti" ]

   IF !Empty( _vars[ "uslov_datumi" ] )
      _filter += " .and. " + _vars[ "uslov_datumi" ]
   ENDIF

   _filter += " .and. " + _vars[ "uslov_tipovi" ]

   IF !Empty( _vars[ "rj" ] )
      _filter += " .and. idfirma==" + dbf_quote( _vars[ "rj" ] )
   ENDIF

   _filter := StrTran( _filter, ".t..and.", "" )

   IF _filter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &_filter
   ENDIF

   GO TOP

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fakt_doks", "fakt_doks2", "fakt_fakt" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabele.#Prekidam operaciju." )
      RETURN .F.
   ENDIF

   DO WHILE !Eof()

      SKIP 1
      nTrec := RecNo()
      SKIP -1

      _id_firma := field->idfirma
      _id_tip_dok := field->idtipdok
      _br_dok := field->brdok

      SELECT fakt
      SEEK _id_firma + _id_tip_dok + _br_dok

      IF !Found()
         SELECT fakt_doks
         SKIP
         LOOP
      ENDIF

      kopiraj_dokument_u_tabelu_pripreme( _id_firma, _id_tip_dok, _br_dok )

      MsgO( "Brišem dokumente iz kumulativa: " + _id_firma + "-" + _id_tip_dok + "-" + PadR( _br_dok, 10 ) )

      SELECT fakt
      GO TOP
      SEEK _id_firma + _id_tip_dok + _br_dok

      IF Found()

         _del_rec := dbf_get_rec()
         _ok := delete_rec_server_and_dbf( "fakt_fakt", _del_rec, 2, "CONT" )

         IF _ok
            SELECT fakt_doks
            GO TOP
            SEEK _id_firma + _id_tip_dok + _br_dok

            IF Found()
               _del_rec := dbf_get_rec()
               _ok := delete_rec_server_and_dbf( "fakt_doks", _del_rec, 1, "CONT" )
            ENDIF
         ENDIF

         IF _ok
            SELECT fakt_doks2
            GO TOP
            SEEK _id_firma + _id_tip_dok + _br_dok

            IF Found()
               _del_rec := dbf_get_rec()
               _ok := delete_rec_server_and_dbf( "fakt_doks2", _del_rec, 1, "CONT" )
            ENDIF
         ENDIF

         IF _ok
            log_write( "F18_DOK_OPER: fakt povrat dokumenta prema kriteriju: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok, 2 )
         ENDIF

         IF !_ok
            EXIT
         ENDIF

      ENDIF

      MsgC()

      SELECT fakt_doks
      GO ( nTrec )

   ENDDO

   IF _ok
      hParams := hb_Hash()
      hParams[ "unlock" ] := { "fakt_doks", "fakt_doks2", "fakt_fakt" }
      run_sql_query( "COMMIT", hParams )

   ELSE
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Problem sa povratom dokumenta u pripremu.#Poništavam operaciju." )
   ENDIF

   my_close_all_dbf()

   RETURN _ok



STATIC FUNCTION uslovi_za_povrat_prema_kriteriju( hVars )

   LOCAL _tip_dok := hVars[ "tip_dok" ]
   LOCAL _br_dok := hVars[ "br_dok" ]
   LOCAL _datumi := hVars[ "datumi" ]
   LOCAL _rj := hVars[ "rj" ]
   LOCAL _ret := .T.

   Box(, 4, 60 )
   @ m_x + 1, m_y + 2 SAY "Rj               "  GET _rj PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Vrste dokumenata "  GET _tip_dok PICT "@S40"
   @ m_x + 3, m_y + 2 SAY "Broj dokumenata  "  GET _br_dok PICT "@S40"
   @ m_x + 4, m_y + 2 SAY "Datumi           "  GET _datumi PICT "@S40"
   READ
   Boxc()

   IF Pitanje( "FAKT_POV_KRITER", "Dokumente sa zadanim kriterijumom vratiti u pripremu (D/N) ?", "N" ) == "N"
      _ret := .F.
      RETURN _ret
   ENDIF

   hVars[ "rj" ] := _rj
   hVars[ "tip_dok" ] := _tip_dok
   hVars[ "br_dok" ] := _br_dok
   hVars[ "datumi" ] := _datumi
   hVars[ "uslov_dokumenti" ] := Parsiraj( _br_dok, "brdok", "C" )
   hVars[ "uslov_datumi" ] := Parsiraj( _datumi, "datdok", "D" )
   hVars[ "uslov_tipovi" ] := Parsiraj( _tip_dok, "idtipdok", "C" )

   RETURN _ret




STATIC FUNCTION dokument_se_moze_vratiti_u_pripremu( hVars )

   LOCAL _ret := .T.

   IF hVars[ "idtipdok" ] $ "10#11"
      IF postoji_fiskalni_racun( hVars[ "idfirma" ], hVars[ "idtipdok" ], hVars[ "brdok" ], fiskalni_uredjaj_model() )
         MsgBeep( "Za ovaj dokument je izdat fiskalni račun.#Opcija povrata je onemogućena !!!" )
         _ret := .F.
         RETURN _ret
      ENDIF
   ENDIF

   RETURN _ret


STATIC FUNCTION uslovi_za_povrat_dokumenta( hVars )

   LOCAL _firma   := hVars[ "idfirma" ]
   LOCAL _tip_dok := hVars[ "idtipdok" ]
   LOCAL _br_dok  := hVars[ "brdok" ]
   LOCAL _ret     := .T.

   Box( "", 1, 35 )

   @ m_x + 1, m_y + 2 SAY "Dokument:"
   @ m_x + 1, Col() + 1 GET _firma

   @ m_x + 1, Col() + 1 SAY "-"
   @ m_x + 1, Col() + 1 GET _tip_dok

   @ m_x + 1, Col() + 1 SAY "-" GET _br_dok

   READ

   BoxC()

   IF LastKey() == K_ESC
      _ret := .F.
      RETURN _ret
   ENDIF

   hVars[ "idfirma" ]  := _firma
   hVars[ "idtipdok" ] := _tip_dok
   hVars[ "brdok" ]    := _br_dok

   RETURN _ret




FUNCTION fakt_napravi_duplikat( id_firma, id_tip_dok, br_dok )

   LOCAL _qry, _field
   LOCAL _table, oRow
   LOCAL _count := 0

   IF Pitanje(, "Napraviti duplikat dokumenta u tablu pripreme (D/N) ? ", "D" ) == "N"
      RETURN .T.
   ENDIF

   SELECT ( F_FAKT_PRIPR )
   IF !Used()
      o_fakt_pripr()
   ENDIF

   _qry := "SELECT * FROM " + F18_PSQL_SCHEMA_DOT + "fakt_fakt " + ;
      " WHERE idfirma = " + sql_quote( id_firma ) + ;
      " AND idtipdok = " + sql_quote( id_tip_dok ) + ;
      " AND brdok = " + sql_quote( br_dok ) + ;
      " ORDER BY idfirma, idtipdok, brdok, rbr "

   _table := run_sql_query( _qry )

   IF _table:LastRec() == 0
      MsgBeep( "Traženog dokumenta nema!" )
      RETURN .T.
   ENDIF

   DO WHILE !_table:Eof()

      oRow := _table:GetRow()

      SELECT fakt_pripr
      APPEND BLANK
      hRec := dbf_get_rec()

      FOR EACH _field in hRec:keys
         hRec[ _field ] := oRow:FieldGet( oRow:FieldPos( _field ) )
         IF ValType( hRec[ _field ] ) == "C"
            hRec[ _field ] := hb_UTF8ToStr( hRec[ _field ] )
         ENDIF
      NEXT

      hRec[ "brdok" ] := fakt_prazan_broj_dokumenta()
      hRec[ "datdok" ] := Date()

      dbf_update_rec( hRec )

      _table:skip()

      ++_count

   ENDDO

   SELECT fakt_pripr
   USE

   IF _count > 0
      MsgBeep( "Novoformirani dokument se nalazi u pripremi !" )
   ENDIF

   RETURN .T.
