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

#include "fakt.ch"

// ------------------------------------------------------
// povrat dokumenta u pripremu
// ------------------------------------------------------
FUNCTION povrat_fakt_dokumenta( rezerv, id_firma, id_tip_dok, br_dok, test )

   LOCAL _vars := hb_Hash()
   LOCAL _brisi_kum := "D"
   LOCAL _rec, _del_rec, _ok
   LOCAL _field_ids, _where_block
   LOCAL _t_rec
   LOCAL oAtrib, _dok_hash

   IF test == nil
      test := .F.
   ENDIF

   IF ( PCount() == 0 )
      _vars[ "idfirma" ]  := gFirma
      _vars[ "idtipdok" ] := Space( 2 )
      _vars[ "brdok" ]    := Space( 8 )
   ELSE
      _vars[ "idfirma" ]  := id_firma
      _vars[ "idtipdok" ] := id_tip_dok
      _vars[ "brdok" ]    := br_dok
   ENDIF

   O_FAKT
   O_FAKT_PRIPR
   O_FAKT_DOKS2
   O_FAKT_DOKS

   SELECT fakt
   SET FILTER TO

   SET ORDER TO TAG "1"

   IF PCount() == 0
      // daj mi uslove za povrat dokumenta, nemam navedeno
      IF !_get_povrat_vars( @_vars )
         my_close_all_dbf()
         RETURN 0
      ENDIF
   ENDIF

   // provjeri zabrane povrata itd...
   IF !_chk_povrat_zabrana( _vars )
      my_close_all_dbf()
      RETURN 0
   ENDIF

   // ovo su parametri dokumenta
   id_firma   := _vars[ "idfirma" ]
   id_tip_dok := _vars[ "idtipdok" ]
   br_dok     := _vars[ "brdok" ]

   IF Pitanje( "FAKT_POV_DOK", "Dokument " + id_firma + "-" + id_tip_dok + "-" + br_dok + " povuci u pripremu (D/N) ?", "D" ) == "N"
      my_close_all_dbf()
      RETURN 0
   ENDIF

   SELECT fakt
   HSEEK id_firma + id_tip_dok + br_dok

   // da li dokument uopste postoji ?
   IF !Found()
      MsgBeep( "Trazeni dokument u fakt_fakt ne postoji !" )
   ENDIF

   IF ( fakt->m1 == "X" )
      MsgBeep( "Radi se o izgenerisanom dokumentu!!!" )
      IF Pitanje( "IZGEN_CONT", "Želite li nastaviti?!", "N" ) == "N"
         my_close_all_dbf()
         RETURN 0
      ENDIF
   ENDIF

   // vrati dokument u pripremu
   DO WHILE !Eof() .AND. id_firma == field->idfirma .AND. id_tip_dok == field->idtipdok .AND. br_dok == field->brdok

      SELECT fakt

      _rec := dbf_get_rec()

      SELECT fakt_pripr
      APPEND BLANK

      dbf_update_rec( _rec )

      SELECT fakt
      SKIP

   ENDDO

   // fakt atributi....
   _dok_hash := hb_Hash()
   _dok_hash[ "idfirma" ] := id_firma
   _dok_hash[ "idtipdok" ] := id_tip_dok
   _dok_hash[ "brdok" ] := br_dok

   oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )
   oAtrib:dok_hash := _dok_hash
   oAtrib:atrib_server_to_dbf()

   IF test == .T.
      _brisi_kum := "D"
   ELSE
      _brisi_kum := Pitanje( "FAKT_POV_KUM", "Želite li izbrisati dokument iz datoteke kumulativa (D/N)?", "N" )
   ENDIF

   IF ( _brisi_kum == "D" )

      IF !f18_lock_tables( { "fakt_fakt", "fakt_doks", "fakt_doks2" } )
         MsgBeep( "Ne mogu zaključati fakt tablele !?" )
         RETURN .F.
      ENDIF

      Box(, 5, 70 )

      _ok := .T.
      sql_table_update( nil, "BEGIN" )

      // FOREIGN key trazi da se prvo brisu fakt atributi...
      @ m_x + 4, m_y + 2 SAY "delete fakt_fakt_atributi"
      // pobrisi ih sa servera...
      _ok := _ok .AND. oAtrib:delete_atrib_from_server()


      _tbl := "fakt_fakt"
      @ m_x + 1, m_y + 2 SAY "delete " + _tbl

      // algoritam 2  - nivo dokumenta
      SELECT fakt
      _ok := _ok .AND. delete_rec_server_and_dbf( _tbl, _vars, 2, "CONT" )
      log_write( "povrat u pripremu fakt_fakt"  + " : " + id_firma + "-" + id_tip_dok + "-" + br_dok, 2 )

      _tbl := "fakt_doks"
      @ m_x + 2, m_y + 2 SAY "delete " + _tbl
      SELECT fakt_doks
      _ok := _ok .AND. delete_rec_server_and_dbf( _tbl, _vars, 1, "CONT" )

      _tbl := "fakt_doks2"
      @ m_x + 3, m_y + 2 SAY "delete " + _tbl
      SELECT fakt_doks2
      _ok := _ok .AND. delete_rec_server_and_dbf( _tbl, _vars, 1, "CONT" )

      f18_free_tables( { "fakt_fakt", "fakt_doks", "fakt_doks2" } )
      sql_table_update( nil, "END" )

      // logiraj operaciju
      log_write( "F18_DOK_OPER: fakt povrat dokumenta u pripremu: " + id_firma + "-" + id_tip_dok + "-" + br_dok, 2 )

      BoxC()

   ENDIF

   IF ( _brisi_kum == "N" )
      // u PRIPR resetujem flagove generacije, jer mi je dokument ostao u kumul.
      SELECT fakt_pripr
      SET ORDER TO TAG "1"
      HSEEK id_firma + id_tip_dok + br_dok

      DO WHILE !Eof() .AND. fakt_pripr->( field->idfirma + field->idtipdok + field->brdok ) == ( id_firma + id_tip_dok + br_dok )
         IF ( fakt_pripr->m1 == "X" )
            _rec := dbf_get_rec()
            _rec[ "m1" ] := Space( 1 )
            dbf_update_rec( _rec )
         ENDIF
         SKIP
      ENDDO
   ENDIF

   my_close_all_dbf()

   RETURN 1


// -----------------------------------------------------
// box - uslovi za povrat dokumenta prema kriteriju
// -----------------------------------------------------
STATIC FUNCTION _get_vars( vars )

   LOCAL _tip_dok := vars[ "tip_dok" ]
   LOCAL _br_dok := vars[ "br_dok" ]
   LOCAL _datumi := vars[ "datumi" ]
   LOCAL _rj := vars[ "rj" ]
   LOCAL _ret := .T.

   Box(, 4, 60 )
   @ m_x + 1, m_y + 2 SAY "Rj               "  GET _rj PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Vrste dokumenata "  GET _tip_dok PICT "@S40"
   @ m_x + 3, m_y + 2 SAY "Broj dokumenata  "  GET _br_dok PICT "@S40"
   @ m_x + 4, m_y + 2 SAY "Datumi           "  GET _datumi PICT "@S40"
   READ
   Boxc()

   IF Pitanje( "FAKT_POV_KRITER", "Dokumente sa zadanim kriterijumom vratiti u pripremu ???", "N" ) == "N"
      _ret := .F.
      RETURN _ret
   ENDIF

   // setuj varijable hash matrice
   vars[ "rj" ] := _rj
   vars[ "tip_dok" ] := _tip_dok
   vars[ "br_dok" ] := _br_dok
   vars[ "datumi" ] := _datumi
   vars[ "uslov_dokumenti" ] := Parsiraj( _br_dok, "brdok", "C" )
   vars[ "uslov_datumi" ] := Parsiraj( _datumi, "datdok", "D" )
   vars[ "uslov_tipovi" ] := Parsiraj( _tip_dok, "idtipdok", "C" )

   RETURN _ret




// ----------------------------------------------------------------------------
// povrat dokumenta prema kriteriju
// ----------------------------------------------------------------------------
FUNCTION povrat_fakt_po_kriteriju( br_dok, dat_dok, tip_dok, firma )

   LOCAL nRec
   LOCAL _t_rec
   LOCAL _vars := hb_Hash()
   LOCAL _filter
   LOCAL _id_firma
   LOCAL _br_dok
   LOCAL _id_tip_dok
   LOCAL _del_rec, _ok

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

      _vars[ "rj" ] := gFirma

   ELSE

      _vars[ "br_dok" ] := Space( 200 )
      _vars[ "datumi" ] := Space( 200 )
      _vars[ "tip_dok" ] := Space( 200 )
      _vars[ "rj" ] := gFirma

   ENDIF

   O_FAKT
   O_FAKT_PRIPR
   O_FAKT_DOKS
   O_FAKT_DOKS2

   SELECT fakt_doks
   SET ORDER TO TAG "1"

   // daj uslove za povrat dokumenta
   IF !_get_vars( @_vars )
      my_close_all_dbf()
      RETURN
   ENDIF

   Beep( 6 )

   IF Pitanje( "", "Jeste li sigurni ???", "N" ) == "N"
      my_close_all_dbf()
      RETURN
   ENDIF

   // setuj filter
   _filter := _vars[ "uslov_dokumenti" ]

   IF !Empty( _vars[ "uslov_datumi" ] )
      _filter += " .and. " + _vars[ "uslov_datumi" ]
   ENDIF

   _filter += " .and. " + _vars[ "uslov_tipovi" ]

   IF !Empty( _vars[ "rj" ] )
      _filter += " .and. idfirma==" + cm2str( _vars[ "rj" ] )
   ENDIF

   _filter := StrTran( _filter, ".t..and.", "" )

   IF _filter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &_filter
   ENDIF

   GO TOP

   f18_lock_tables( { "fakt_doks", "fakt_doks2", "fakt_fakt" } )
   sql_table_update( nil, "BEGIN" )

   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
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

      // prebaci u pripremu...
      DO WHILE !Eof() .AND. _id_firma == field->idfirma .AND. ;
            _id_tip_dok == field->idtipdok .AND. _br_dok == field->brdok

         _rec := dbf_get_rec()

         SELECT fakt_pripr
         APPEND BLANK

         dbf_update_rec( _rec )

         SELECT fakt
         SKIP

      ENDDO

      // sada pobrisi iz kumulativa...
      MsgO( "Brisem dokumente iz kumulativa: " + _id_firma + "-" + _id_tip_dok + "-" + PadR( _br_dok, 10 ) )

      SELECT fakt
      GO TOP
      SEEK _id_firma + _id_tip_dok + _br_dok

      IF Found()

         // brisi fakt....
         _del_rec := dbf_get_rec()
         delete_rec_server_and_dbf( "fakt_fakt", _del_rec, 2, "CONT" )

         // brisi fakt_doks
         SELECT fakt_doks
         GO TOP
         SEEK _id_firma + _id_tip_dok + _br_dok

         IF Found()
            _del_rec := dbf_get_rec()
            delete_rec_server_and_dbf( "fakt_doks", _del_rec, 1, "CONT" )
         ENDIF

         SELECT fakt_doks2
         GO TOP
         SEEK _id_firma + _id_tip_dok + _br_dok

         IF Found()
            _del_rec := dbf_get_rec()
            delete_rec_server_and_dbf( "fakt_doks2", _del_rec, 1, "CONT" )
         ENDIF

         log_write( "F18_DOK_OPER: fakt povrat dokumenta prema kriteriju: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok, 2 )

      ENDIF

      MsgC()

      SELECT fakt_doks
      GO ( _t_rec )

   ENDDO

   f18_free_tables( { "fakt_doks", "fakt_doks2", "fakt_fakt" } )
   sql_table_update( nil, "END" )

   my_close_all_dbf()

   RETURN


// ------------------------------------------
// provjeri status zabrane povrata
// ------------------------------------------
STATIC FUNCTION _chk_povrat_zabrana( vars )

   LOCAL _area
   LOCAL _ret := .T.

   // fiscal zabrana
   // ako je fiskalni racun u vezi, ovo nema potrebe vracati
   // samo uz lozinku

   IF fiscal_opt_active() .AND. vars[ "idtipdok" ] $ "10#11"

      _area := Select()

      SELECT fakt_doks
      hseek vars[ "idfirma" ] + vars[ "idtipdok" ] + vars[ "brdok" ]

      IF Found()
         IF ( fakt_doks->fisc_rn <> 0 .AND. fakt_doks->iznos > 0 ) .OR. ;
               ( fakt_doks->fisc_rn <> 0 .AND. fakt_doks->fisc_st <> 0 .AND. fakt_doks->iznos < 0 )

            // veza sa fisc_rn postoji
            msgbeep( "Za ovaj dokument je izdat fiskalni racun.#Opcija povrata je onemogucena !!!" )
            _ret := .F.

            SELECT ( _area )
            RETURN _ret

         ENDIF
      ENDIF

      SELECT ( _area )

   ENDIF

   RETURN _ret


// -----------------------------------------------------
// vraca box sa uslovima povrata dokumenta
// -----------------------------------------------------
STATIC FUNCTION _get_povrat_vars( vars )

   LOCAL _firma   := vars[ "idfirma" ]
   LOCAL _tip_dok := vars[ "idtipdok" ]
   LOCAL _br_dok  := vars[ "brdok" ]
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

   // setuj varijable hash matrice
   vars[ "idfirma" ]  := _firma
   vars[ "idtipdok" ] := _tip_dok
   vars[ "brdok" ]    := _br_dok

   RETURN _ret




// ---------------------------------------------------------
// pravi duplikat dokumenta u pripremi...
// ---------------------------------------------------------
FUNCTION fakt_napravi_duplikat( id_firma, id_tip_dok, br_dok )

   LOCAL _server := pg_server()
   LOCAL _qry, _field
   LOCAL _table, oRow
   LOCAL _count := 0

   IF Pitanje(, "Napraviti duplikat dokumenta u pripremi (D/N) ? ", "D" ) == "N"
      RETURN .T.
   ENDIF

   SELECT ( F_FAKT_PRIPR )
   IF !Used()
      O_FAKT_PRIPR
   ENDIF

   _qry := "SELECT * FROM fmk.fakt_fakt " + ;
      " WHERE idfirma = " + _sql_quote( id_firma ) + ;
      " AND idtipdok = " + _sql_quote( id_tip_dok ) + ;
      " AND brdok = " + _sql_quote( br_dok ) + ;
      " ORDER BY idfirma, idtipdok, brdok, rbr "

   _table := _sql_query( _server, _qry )
   _table:Refresh()

   IF _table:LastRec() == 0
      MsgBeep( "Trazeni dokument nisam pronasao !" )
      RETURN .T.
   ENDIF

   DO WHILE !_table:Eof()

      oRow := _table:GetRow()

      SELECT fakt_pripr
      APPEND BLANK
      _rec := dbf_get_rec()

      FOR EACH _field in _rec:keys
         _rec[ _field ] := oRow:FieldGet( oRow:FieldPos( _field ) )
         IF ValType( _rec[ _field ] ) == "C"
            _rec[ _field ] := hb_UTF8ToStr( _rec[ _field ] )
         ENDIF
      NEXT

      // ako ima koje pride polje obradi ga !!!
      _rec[ "brdok" ] := fakt_prazan_broj_dokumenta()
      _rec[ "datdok" ] := Date()

      dbf_update_rec( _rec )

      _table:skip()

      ++ _count

   ENDDO

   SELECT fakt_pripr
   USE

   IF _count > 0
      MsgBeep( "Novoformirani dokument se nalazi u pripremi !" )
   ENDIF

   RETURN .T.
