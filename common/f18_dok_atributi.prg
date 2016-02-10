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


CLASS F18_DOK_ATRIB

   DATA modul
   DATA from_dbf
   DATA dok_hash
   DATA atrib
   DATA workarea

   METHOD New()
   METHOD get_atrib()
   METHOD set_atrib()
   METHOD delete_atrib()
   METHOD update_atrib_rbr()
   METHOD create_local_atrib_table()
   METHOD fix_atrib()
   METHOD zapp_local_table()
   METHOD atrib_dbf_to_server()
   METHOD atrib_server_to_dbf()
   METHOD atrib_hash_to_dbf()
   METHOD update_atrib_from_server()
   METHOD delete_atrib_from_server()
   METHOD open_local_table()

   PROTECTED:

   VAR table_name_server
   VAR table_name_local
   VAR ALIAS

   METHOD get_atrib_from_server()
   METHOD get_atrib_from_dbf()
   METHOD get_atrib_list_from_server()
   METHOD set_table_name()
   METHOD set_dbf_alias()
   METHOD atrib_delete_duplicate()
   METHOD atrib_delete_rest()

ENDCLASS



// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:New( _modul_, _wa_ )

   ::dok_hash := hb_Hash()

   IF _modul_ <> NIL
      ::modul := _modul_
   ENDIF

   IF _wa_ <> NIL
      ::workarea := _wa_
   ENDIF

   RETURN SELF




// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:set_dbf_alias()

   ::alias := AllTrim( Lower( ::modul ) ) + "_atrib"

   RETURN SELF




// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:open_local_table()

   LOCAL _alias

   // setuj naziv tabele
   ::set_table_name()
   // setuj alijas
   ::set_dbf_alias()

   SELECT ( ::workarea )

   my_use( ::table_name_local )

   SET ORDER TO TAG "1"

   RETURN SELF





// ----------------------------------------------------------------
// kreira se pomocna tabela atributa...
// ----------------------------------------------------------------
METHOD F18_DOK_ATRIB:create_local_atrib_table( force )

   LOCAL _dbf := {}
   LOCAL _ind_key := "idfirma + idtipdok + brdok + rbr + atribut"
   LOCAL _ind_uniq := ".t."

   IF force == NIL
      force := .F.
   ENDIF

   AAdd( _dbf, { 'IDFIRMA', 'C',   2,  0 } )
   AAdd( _dbf, { 'IDTIPDOK', 'C',   2,  0 } )
   AAdd( _dbf, { 'BRDOK', 'C',   8,  0 } )
   AAdd( _dbf, { 'RBR', 'C',   3,  0 } )
   AAdd( _dbf, { 'ATRIBUT', 'C',  50,  0 } )
   AAdd( _dbf, { 'VALUE', 'C', 250,  0 } )

   ::set_table_name()

   IF force .OR. !File( my_home() + ::table_name_local + ".dbf" )
      dbCreate( my_home() + ::table_name_local + ".dbf", _dbf )
   ENDIF

   // otvori tabelu...
   ::open_local_table()

   // INDEX ON &cKljucIz  TAG (cTag)  TO (cImeCdx) FOR &cFilter UNIQUE
   INDEX ON &_ind_key TAG "1" FOR &_ind_uniq UNIQUE

   SELECT ( ::workarea )
   USE

   RETURN SELF



// --------------------------------------------------
// --------------------------------------------------
METHOD F18_DOK_ATRIB:set_table_name()

   IF !Empty( ::modul )
      ::table_name_local := AllTrim( Lower( ::modul ) ) + "_pripr_atrib"
      ::table_name_server := "fmk." + AllTrim( Lower( ::modul ) ) + "_" + ;
         AllTrim( Lower( ::modul ) ) + "_atributi"
   ELSE
      MsgBeep( "DATA:modul nije setovano !" )
   ENDIF

   RETURN SELF


// ----------------------------------------------------------------------
// vraca atribut
// ----------------------------------------------------------------------
METHOD F18_DOK_ATRIB:get_atrib( _dok, _atribut )

   LOCAL _ret

   // postoji mogucnost i setovanja kroz poziv metode
   IF PCount() > 0

      IF _dok <> NIL
         ::dok_hash := _dok
      ENDIF

      IF _atribut <> NIL
         ::atrib := _atribut
      ENDIF

   ENDIF

   // setuj naziv tabele
   ::set_table_name()

   IF !::from_dbf
      _ret := ::get_atrib_from_server()
   ELSE
      _ret := ::get_atrib_from_dbf()
   ENDIF

   RETURN _ret



// --------------------------------------------------------------------
// vraca atribut iz pomocne tabele
// --------------------------------------------------------------------
METHOD F18_DOK_ATRIB:get_atrib_from_dbf()

   LOCAL _ret := ""
   LOCAL _t_area := Select()

   // otvori mi tabelu atributa...
   ::open_local_table()

   SET ORDER TO TAG "1"
   GO TOP

   SEEK ( ::dok_hash[ "idfirma" ] + ::dok_hash[ "idtipdok" ] + ::dok_hash[ "brdok" ] + ::dok_hash[ "rbr" ] + ::atrib )

   IF Found()
      _ret := AllTrim( field->value )
   ENDIF

   USE

   SELECT ( _t_area )

   RETURN _ret



// -------------------------------------------------------------------------
// vraca odredjeni atribut sa servera
// -------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:get_atrib_from_server()

   LOCAL _val := ""
   LOCAL _attr := ::get_atrib_list_from_server()

   IF _attr != NIL .AND. Len( _attr ) <> 0
      _val := _attr[ 1, 3 ]
   ENDIF

   RETURN _val


// ----------------------------------------------------------------------------
// vraca listu atributa sa servera za pojedini dokument
//
// ako zadamo id_firma + tip_dok + br_dok -> dobijamo sve za taj dokument
// ako zadamo id_firma + tip_dok + br_dok + r_br -> dobijamo za tu stavku
// ako zadamo id_firma + tip_dok + br_dok + r_br + atribut -> dobijamo
// samo trazeni atribut
//
// vraca se matrica { "rbr", "value", "atribut" }
// ----------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:get_atrib_list_from_server()

   LOCAL _a_atrib := {}
   LOCAL _qry, _table, oItem
   LOCAL _idfirma, _idtipdok, _brdok, _rbr, _atrib
   LOCAL _where

   _idfirma := ::dok_hash[ "idfirma" ]
   _idtipdok := ::dok_hash[ "idtipdok" ]
   _brdok := ::dok_hash[ "brdok" ]

   if ::atrib == NIL
      _atrib := ""
   ELSE
      _atrib := ::atrib
   ENDIF

   IF hb_HHasKey( ::dok_hash, "rbr" )
      if ::dok_hash[ "rbr" ] == NIL
         _rbr := ""
      ELSE
         _rbr := ::dok_hash[ "rbr" ]
      ENDIF
   ELSE
      _rbr := ""
   ENDIF

   _where := "idfirma = " + _sql_quote( _idfirma )
   _where += " AND "
   _where += "brdok = " + _sql_quote( _brdok )
   _where += " AND "
   _where += "idtipdok = " + _sql_quote( _idtipdok )

   IF !Empty( _rbr )
      _where += " AND rbr = " + _sql_quote( _rbr )
   ENDIF

   IF !Empty( _atrib )
      _where += " AND atribut = " + _sql_quote( _atrib )
   ENDIF

   _table := select_all_records_from_table( ::table_name_server, NIL, { _where }, { "atribut" } )

   IF _table == NIL
      RETURN NIL
   ENDIF

   _table:GoTo( 1 )

   DO WHILE !_table:Eof()
      oItem := _table:GetRow()
      AAdd( _a_atrib, { oItem:FieldGet( oItem:FieldPos( "rbr" ) ), ;
         oItem:FieldGet( oItem:FieldPos( "atribut" ) ), ;
         hb_UTF8ToStr( oItem:FieldGet( oItem:FieldPos( "value" ) ) ) } )
      _table:Skip()
   ENDDO

   RETURN _a_atrib





// ---------------------------------------------------------------------------
// setovanje atributa u pomocnu tabelu
// ---------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:set_atrib( atrib_key, value )

   LOCAL _ok := .T.
   LOCAL _rec, _t_area

   _t_area := Select()

   ::open_local_table()

   SET ORDER TO TAG "1"
   GO TOP
   SEEK ( ::dok_hash[ "idfirma" ] + ::dok_hash[ "idtipdok" ] + ::dok_hash[ "brdok" ] + ::dok_hash[ "rbr" ] + atrib_key )

   IF !Found()

      IF Empty( value )
         USE
         SELECT ( _t_area )
         RETURN _ok
      ENDIF

      APPEND BLANK

      _rec := dbf_get_rec()

      _rec[ "idfirma" ] := ::dok_hash[ "idfirma" ]
      _rec[ "idtipdok" ] := ::dok_hash[ "idtipdok" ]
      _rec[ "brdok" ] := ::dok_hash[ "brdok" ]
      _rec[ "rbr" ] := ::dok_hash[ "rbr" ]
      _rec[ "atribut" ] := atrib_key
      _rec[ "value" ] := value

      dbf_update_rec( _rec )

   ELSE

      _rec := dbf_get_rec()
      _rec[ "value" ] := value
      dbf_update_rec( _rec )

   ENDIF

   USE

   SELECT ( _t_area )

   RETURN _ok



// --------------------------------------------------------------------------
// ubaci atribute iz hash matrice u dbf atribute
// --------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_hash_to_dbf( hash )

   LOCAL _rec, _key

   // prodji kroz atribute i napuni dbf
   FOR EACH _key in hash:keys()
      ::set_atrib( _key, hash[ _key ] )
   NEXT

   RETURN




// ---------------------------------------------------------
// zapuje fakt atribute
// ---------------------------------------------------------
METHOD F18_DOK_ATRIB:zapp_local_table()

   LOCAL _t_area := Select()

   ::open_local_table()

   reopen_exclusive_and_zap( Alias(), .T. )
   USE

   SELECT ( _t_area )

   RETURN



// ---------------------------------------------------------------------------
// brisanje atributa iz lokalnog dbf-a
// ---------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:delete_atrib()

   LOCAL _ok := .T.
   LOCAL _t_area := Select()
   LOCAL _idfirma, _idtipdok, _brdok, _rbr, _atribut

   _idfirma := ::dok_hash[ "idfirma" ]
   _idtipdok := ::dok_hash[ "idtipdok" ]
   _brdok := ::dok_hash[ "brdok" ]
   _rbr := ::dok_hash[ "rbr" ]

   IF hb_HHasKey( ::dok_hash, "atribut" )
      _atribut := ::dok_hash[ "atribut" ]
   ELSE
      _atribut := NIL
   ENDIF

   IF _rbr == NIL
      _rbr := ""
   ENDIF

   IF _atribut == NIL
      _atribut := ""
   ENDIF

   ::open_local_table()

   my_flock()

   GO TOP
   SEEK ( _idfirma + _idtipdok + _brdok + _rbr + _atribut )

   DO WHILE !Eof() .AND. field->idfirma == _idfirma .AND. field->idtipdok == _idtipdok ;
         .AND. field->brdok == _brdok ;
         .AND. IF( !Empty( _rbr ), field->rbr == _rbr, .T. ) ;
         .AND. IF( !Empty( _atribut ), field->atribut == _atribut, .T. )
      DELETE
      SKIP
   ENDDO

   my_unlock()

   my_dbf_pack()

   USE

   SELECT ( _t_area )

   RETURN _ok



METHOD F18_DOK_ATRIB:update_atrib_rbr()

   LOCAL _ok := .T.
   LOCAL _t_area := Select()
   LOCAL _idfirma, _idtipdok, _brdok, _rbr, _atribut, _update_rbr
   LOCAL _rec, _t_rec

   IF !hb_HHasKey( ::dok_hash, "update_rbr" )
      RETURN .F.
   ENDIF

   _idfirma := ::dok_hash[ "idfirma" ]
   _idtipdok := ::dok_hash[ "idtipdok" ]
   _brdok := ::dok_hash[ "brdok" ]
   _rbr := ::dok_hash[ "rbr" ]
   _update_rbr := ::dok_hash[ "update_rbr" ]

   ::open_local_table()

   GO TOP
   SEEK ( _idfirma + _idtipdok + _brdok + _update_rbr )

   DO WHILE !Eof() .AND. field->idfirma == _idfirma .AND. field->idtipdok == _idtipdok ;
         .AND. field->brdok == _brdok ;
         .AND. field->rbr == _update_rbr

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      _rec := dbf_get_rec()
      _rec[ "rbr" ] := _rbr
      dbf_update_rec( _rec )

      GO ( _t_rec )

   ENDDO

   USE

   SELECT ( _t_area )

   RETURN _ok



// ------------------------------------------------------------------------
// update atributa na serveru
// ------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:update_atrib_from_server( params )

   LOCAL _ok := .T.
   LOCAL _qry
   LOCAL _server := pg_server()
   LOCAL _old_firma := params[ "old_firma" ]
   LOCAL _old_tipdok := params[ "old_tipdok" ]
   LOCAL _old_brdok := params[ "old_brdok" ]
   LOCAL _new_firma := params[ "new_firma" ]
   LOCAL _new_tipdok := params[ "new_tipdok" ]
   LOCAL _new_brdok := params[ "new_brdok" ]

   // prvo pobrisi sa servera
   _qry := "UPDATE " + ::table_name_server + " "
   _qry += "SET "
   _qry += "idfirma = " + _sql_quote( _new_firma )
   _qry += ", idtipdok = " + _sql_quote( _new_tipdok )
   _qry += ", brdok = " + _sql_quote( _new_brdok )
   _qry += " WHERE "
   _qry += " idfirma = " + _sql_quote( _old_firma )
   _qry += " AND idtipdok = " + _sql_quote( _old_tipdok )
   _qry += " AND brdok = " + _sql_quote( _old_brdok )

   _ret := _sql_query( _server, _qry )

   IF ValType( _ret ) == "L"
      _ok := .F.
   ENDIF

   RETURN _ok



// ------------------------------------------------------------------------
// brisanje atributa sa servera
// ------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:delete_atrib_from_server()

   LOCAL _ok := .T.
   LOCAL _qry
   LOCAL _server := pg_server()

   ::set_table_name()

   _qry := "DELETE FROM " + ::table_name_server
   _qry += " WHERE "
   _qry += "idfirma = " + _sql_quote( ::dok_hash[ "idfirma" ] )
   _qry += " AND idtipdok = " + _sql_quote( ::dok_hash[ "idtipdok" ] )
   _qry += " AND brdok = " + _sql_quote( ::dok_hash[ "brdok" ] )

   _ret := _sql_query( _server, _qry )

   IF ValType( _ret ) == "L"
      _ok := .F.
   ENDIF

   RETURN _ok



// -------------------------------------------------------------------------
// pusiranje atributa na server
// -------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_dbf_to_server()

   LOCAL _ok := .T.
   LOCAL _t_area := Select()
   LOCAL _qry, _table
   LOCAL _server := pg_server()
   LOCAL _res

   ::open_local_table()

   IF RecCount() == 0
      USE
      SELECT ( _t_area )
      RETURN _ok
   ENDIF

   IF !::delete_atrib_from_server()
      USE
      _ok := .F.
      SELECT ( _t_area )
      RETURN _ok
   ENDIF

   SELECT Alias( ::workarea )
   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      IF Empty( field->value )
         SKIP
         LOOP
      ENDIF

      IF ( ::dok_hash[ "idfirma" ] != field->idfirma ) .OR. ;
            ( ::dok_hash[ "idtipdok" ] != field->idtipdok ) .OR. ;
            ( ::dok_hash[ "brdok" ] != field->brdok )
         SKIP
         LOOP
      ENDIF

      _qry := "INSERT INTO " + ::table_name_server + " "
      _qry += "( idfirma, idtipdok, brdok, rbr, atribut, value ) "
      _qry += "VALUES ("
      _qry += _sql_quote( ::dok_hash[ "idfirma" ] ) + ", "
      _qry += _sql_quote( ::dok_hash[ "idtipdok" ] ) + ", "
      _qry += _sql_quote( ::dok_hash[ "brdok" ] ) + ", "
      _qry += _sql_quote( field->rbr ) + ", "
      _qry += _sql_quote( field->atribut ) + ", "
      _qry += _sql_quote( field->value )
      _qry += ")"

      _res := _sql_query( _server, _qry )

      IF ValType( _res ) == "L"
         _ok := .F.
         EXIT
      ENDIF

      SKIP

   ENDDO

   SELECT Alias( ::workarea )
   USE

   SELECT ( _t_area )

   RETURN _ok




// ------------------------------------------------------------------------
// puni lokalni dbf sa podacima iz matrice
// ------------------------------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_server_to_dbf()

   LOCAL _atrib
   LOCAL _i, _rec
   LOCAL _t_area := Select()

   ::set_table_name()

   _atrib := ::get_atrib_list_from_server()

   IF _atrib == NIL
      RETURN .F.
   ENDIF

   ::open_local_table()
   GO TOP

   FOR _i := 1 TO Len( _atrib )

      APPEND BLANK

      _rec := dbf_get_rec()
      _rec[ "idfirma" ] := ::dok_hash[ "idfirma" ]
      _rec[ "idtipdok" ] := ::dok_hash[ "idtipdok" ]
      _rec[ "brdok" ] := ::dok_hash[ "brdok" ]
      _rec[ "rbr" ] := _atrib[ _i, 1 ]
      _rec[ "atribut" ] := _atrib[ _i, 2 ]
      _rec[ "value" ] := _atrib[ _i, 3 ]

      dbf_update_rec( _rec )

   NEXT

   SELECT ( ::workarea )
   USE

   SELECT ( _t_area )

   RETURN .T.


// -----------------------------------------------------
// ova funkcija treba da uradi:
// - provjeri ima li viska atributa
// - provjeri ima li duplih atributa
// -----------------------------------------------------
METHOD F18_DOK_ATRIB:fix_atrib( area, dok_arr )

   LOCAL _dok_params
   LOCAL _i

   ::set_table_name()

   FOR _i := 1 TO Len( dok_arr )

      _dok_params := hb_Hash()
      _dok_params[ "idfirma" ] := dok_arr[ _i, 1 ]
      _dok_params[ "idtipdok" ] := dok_arr[ _i, 2 ]
      _dok_params[ "brdok" ] := dok_arr[ _i, 3 ]

      ::atrib_delete_duplicate( _dok_params )

   NEXT

   ::atrib_delete_rest( area )

   RETURN


// -----------------------------------------------------
// brisi visak atributa ako postoji
// -----------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_delete_rest( area )

   LOCAL _id_firma, _tip_dok, _br_dok
   LOCAL _t_area := Select()
   LOCAL _ok := .T.
   LOCAL _deleted := .F.
   LOCAL _alias := ::alias
   LOCAL _tmp := AllTrim( Lower( ::modul ) ) + "_pripr"

   SELECT Alias( area )
   SET ORDER TO TAG "1"

   ::open_local_table()

   my_flock()

   SET ORDER TO TAG "1"
   GO TOP

   DO WHILE !Eof()

      SKIP 1
      _t_rec := RecNo()
      SKIP -1

      SELECT Alias( area )

      seek &( _alias )->idfirma + &( _alias )->idtipdok + &( _alias )->brdok + &( _alias )->rbr

      IF !Found()
         SELECT Alias( ::workarea )
         DELETE
         _deleted := .T.
      ELSE
         SELECT Alias( ::workarea )
      ENDIF

      GO ( _t_rec )

   ENDDO
   my_unlock()

   IF _deleted
      my_dbf_pack()
   ENDIF

   USE

   SELECT ( _t_area )

   RETURN _ok





// -----------------------------------------------------
// provjera ispravnosti atributa za dokument
// -----------------------------------------------------
METHOD F18_DOK_ATRIB:atrib_delete_duplicate( param )

   LOCAL _id_firma, _tip_dok, _br_dok, _b1
   LOCAL _t_area := Select()
   LOCAL _ok := .T.
   LOCAL _r_br, _atrib, _r_br_2, _atrib_2, _eof := .F.
   LOCAL _deleted := .F.

   _id_firma := PARAM[ "idfirma" ]
   _tip_dok := PARAM[ "idtipdok" ]
   _br_dok := PARAM[ "brdok" ]

   ::open_local_table()

   my_flock()

   SET ORDER TO TAG "1"
   GO TOP
   SEEK _id_firma + _tip_dok + _br_dok

   _b1 := {|| field->idfirma == _id_firma .AND. field->idtipdok == _tip_dok .AND. field->brdok == _br_dok }

   DO WHILE !Eof() .AND. Eval( _b1 )

      _r_br := field->rbr
      _atrib := field->atribut
      SKIP 1
      _t_rec := RecNo()
      _r_br_2 := field->rbr
      _atrib_2 := field->atribut

      IF Eof()
         _eof := .T.
      ELSE
         _eof := .F.
      ENDIF

      IF !_eof .AND. Eval( _b1 ) .AND. ( _r_br_2 == _r_br ) .AND. ( _atrib_2 == _atrib )
         DELETE
         _deleted := .T.
      ENDIF

      IF _eof
         EXIT
      ENDIF

      GO _t_rec
   ENDDO

   my_unlock()

   IF _deleted
      my_dbf_pack( .F. )
   ENDIF

   USE

   SELECT ( _t_area )

   RETURN _ok
