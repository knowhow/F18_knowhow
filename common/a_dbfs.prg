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

STATIC __f18_dbfs := nil


FUNCTION set_a_dbfs()

   LOCAL _dbf_fields, _sql_order
   LOCAL _alg

   PUBLIC gaDbfs := {}

   __f18_dbfs := hb_Hash()

   set_a_dbf_sif()
   set_a_dbf_params()
   set_a_dbf_sifk_sifv()
   set_a_dbf_temporary()

   set_a_dbf_fin()
   set_a_dbf_kalk()
   set_a_dbf_fakt()

   set_a_dbf_ld()
   set_a_dbf_ld_sif()

   set_a_dbf_pos()
   set_a_dbf_epdv()
   set_a_dbf_os()
   set_a_dbf_virm()
   set_a_dbf_rnal()
   set_a_dbf_mat()
   set_a_dbf_kadev()

   RETURN .T.

// ------------------------------------------------
// za sve tabele kreiraj dbf_fields strukturu
// ------------------------------------------------
FUNCTION set_a_dbfs_key_fields()

   LOCAL _key

   FOR EACH _key in __f18_dbfs:Keys

      // nije zadano - ja cu na osnovu strukture dbf-a
      // napraviti dbf_fields
      IF !hb_HHasKey( __f18_dbfs[ _key ], "dbf_fields" )  .OR.  __f18_dbfs[ _key ][ "dbf_fields" ] == NIL
         set_dbf_fields_from_struct( @__f18_dbfs[ _key ] )
      ENDIF

   NEXT

   RETURN .T.


// ------------------------------------
// dodaj stavku u f18_dbfs
// ------------------------------------
FUNCTION f18_dbfs_add( _tbl, _item )

   __f18_dbfs[ _tbl ] := _item

   RETURN .T.



FUNCTION f18_dbfs()
   RETURN __f18_dbfs


// ----------------------------------------
// temp tabele - semafori se ne koriste
// ----------------------------------------
FUNCTION set_a_dbf_temp( table, alias, wa )

   LOCAL _item

   _item := hb_Hash()

   _item[ "alias" ] := alias
   _item[ "table" ] := table
   _item[ "wa" ]    := wa

   _item[ "temp" ]  := .T.
   _item[ "chk0" ]  := .T.

   f18_dbfs_add( table, @_item )

   RETURN .T.


FUNCTION set_a_sql_sifarnik( dbf_table, alias, wa, rec )

   set_a_dbf_sifarnik( dbf_table, alias, wa, rec, .T. )

   RETURN .T.


FUNCTION set_a_dbf_sifarnik( dbf_table, alias, wa, rec, lSql )

   LOCAL _alg, _item

   IF lSql == NIL
      lSql := .F.
   ENDIF

   _item := hb_Hash()

   _item[ "alias" ] := alias
   _item[ "table" ] := dbf_table
   _item[ "wa" ]    := wa

   _item[ "temp" ]  := .F.
   _item[ "sql" ]   :=  lSql
   _item[ "chk0" ]   :=  .F.
   _item[ "algoritam" ] := {}

   _alg := hb_Hash()

   IF rec == NIL
      _alg[ "dbf_key_fields" ] := { "id" }
      _alg[ "dbf_tag" ]        := "ID"
      _alg[ "sql_in" ]        := "id"
      _alg[ "dbf_key_block" ] := {|| field->id }

   ELSE
      _alg[ "dbf_key_fields" ] := rec[ "dbf_key_fields" ]
      _alg[ "dbf_tag" ]        := rec[ "dbf_tag" ]
      _alg[ "sql_in" ]        := rec[ "sql_in" ]
      _alg[ "dbf_key_block" ] := rec[ "dbf_key_block" ]
   ENDIF


   AAdd( _item[ "algoritam" ], _alg )

   f18_dbfs_add( dbf_table, @_item )

   RETURN .T.



// -------------------------------------------------------
// tbl - dbf_table ili alias
//
// _only_basic_params - samo table, alias, wa
// -------------------------------------------------------
FUNCTION get_a_dbf_rec( tbl, _only_basic_params )

   LOCAL _msg, _rec, _keys, _dbf_tbl, _key

   _dbf_tbl := "x"

   IF _only_basic_params == NIL
      _only_basic_params = .F.
   ENDIF

   IF ValType( __f18_dbfs ) <> "H"
      Alert( RECI_GDJE_SAM + " " + tbl + "__f18_dbfs nije inicijalizirana" )
   ENDIF

   IF hb_HHasKey( __f18_dbfs, tbl )
      _dbf_tbl := tbl
   ELSE
      // probaj preko aliasa
      FOR EACH _key IN __f18_dbfs:Keys
         IF ValType( tbl ) == "N"
            // zadana je workarea
            IF __f18_dbfs[ _key ][ "wa" ] == tbl
               _dbf_tbl := _key
            ENDIF
         ELSE
            IF __f18_dbfs[ _key ][ "alias" ] == Upper( tbl )
               _dbf_tbl := _key
            ENDIF
         ENDIF
      NEXT
   ENDIF

   IF _dbf_tbl == "x"
      _msg := "dbf alias " + tbl + " ne postoji u a_dbf_rec ?!"
      RaiseError( _msg )
   ENDIF

   IF hb_HHasKey( __f18_dbfs, _dbf_tbl )
      // preferirani set parametara
      _rec := __f18_dbfs[ _dbf_tbl ]
   ELSE
      _rec := hb_Hash()
      _rec[ "table" ] := _dbf_tbl
      _rec[ "alias" ] := Alias()
      _rec[ "wa" ] := Select()
      _rec[ "temp" ] := .T.
      _rec[ "chk0" ] := .F.
   ENDIF

   IF !hb_HHasKey( _rec, "table" ) .OR. _rec[ "table" ] == NIL
      _msg := RECI_GDJE_SAM + " set_a_dbf nije definisan za table= " + tbl
      Alert( _msg )
      log_write( _msg, 2 )
      RaiseError( _msg )
      QUIT_1
   ENDIF

   // ako nema definisane blackliste, setuj je ali kao NIL
   IF !hb_HHasKey( _rec, "blacklisted" )
      _rec[ "blacklisted" ] := NIL
   ENDIF

   IF !hb_HHasKey( _rec, "sql" )
      _rec[ "sql" ] := .F.
   ENDIF

   IF !hb_HHasKey( _rec, "chk0" )
      _rec[ "chk0" ] := .F.
   ENDIF


   IF _only_basic_params
      RETURN _rec
   ENDIF

   // nije zadano - ja cu na osnovu strukture dbf-a
   // napraviti dbf_fields
   IF !hb_HHasKey( _rec, "dbf_fields" ) .OR. _rec[ "dbf_fields" ] == NIL
      set_dbf_fields_from_struct( @_rec )
   ENDIF

   IF !hb_HHasKey( _rec, "sql_order" )
      IF hb_HHasKey( _rec, "algoritam" )
         // dbf_key_fields stavke su "C" za datumska i char polja, "A" za numericka polja
         // npr: { {"godina", 4, 0}, "datum", "id" }
         _rec[ "sql_order" ] := sql_order_from_key_fields( _rec[ "algoritam" ][ 1 ][ "dbf_key_fields" ] )
      ENDIF
   ENDIF

   RETURN _rec

FUNCTION set_a_dbf_rec_chk0( table )

   __f18_dbfs[ table ][ "chk0" ] := .T.

   RETURN .T.




// ---------------------------------------------------
// da li alias ima semafor ?
// ---------------------------------------------------
FUNCTION dbf_alias_has_semaphore( alias )

   LOCAL _ret := .F.
   LOCAL _msg, _rec, _keys, _dbf_tbl, _key

   // ako nema parametra uzmi tekuci alias na kome se nalazimo
   IF ( alias == NIL )
      alias := Alias()
   ENDIF

   _dbf_tbl := "x"

   FOR EACH _key IN __f18_dbfs:Keys
      IF ValType( alias ) == "N"
         // zadana je workarea
         IF __f18_dbfs[ _key ][ "wa" ] == alias
            _dbf_tbl := _key
            EXIT
         ENDIF
      ELSE
         IF __f18_dbfs[ _key ][ "alias" ] == Upper( alias )
            _dbf_tbl := _key
            EXIT
         ENDIF
      ENDIF
   NEXT

   IF hb_HHasKey( __f18_dbfs, _dbf_tbl )

      _rec := __f18_dbfs[ _dbf_tbl ]
      IF _rec[ "temp" ] == .F.
         // tabela ima semafor
         _ret := .T.
      ENDIF

   ENDIF

   RETURN _ret



// ----------------------------------------------
// setujem "sql_order" hash na osnovu
// gaDBFS[_pos][6]
// rec["dbf_fields"]
// ----------------------------------------------
FUNCTION sql_order_from_key_fields( dbf_key_fields )

   LOCAL _i, _len
   LOCAL _sql_order

   // primjer: dbf_key_fields = {{"godina", 4}, "idrj", {"mjesec", 2}

   _len := Len( dbf_key_fields )

   _sql_order := ""
   FOR _i := 1 TO _len

      IF ValType( dbf_key_fields[ _i ] ) == "A"
         _sql_order += dbf_key_fields[ _i, 1 ]
      ELSE
         _sql_order += dbf_key_fields[ _i ]
      ENDIF

      IF _i < _len
         _sql_order += ","
      ENDIF
   NEXT

   RETURN _sql_order


// ----------------------------------------------
// setujem "dbf_fields" hash na osnovu stukture
// dbf-a
// rec["dbf_fields"]
// ----------------------------------------------
FUNCTION set_dbf_fields_from_struct( rec )

   LOCAL lTabelaOtvorenaOvdje := .F.
   LOCAL _dbf
   LOCAL lSql

   lSql := hb_hHasKey( rec, "sql") .AND. ValType( rec[ "sql" ] ) == "L"  .AND. rec[ "sql" ]

   IF rec[ "temp" ]  // ovi podaci ne trebaju za temp tabele
      RETURN .F.
   ENDIF

   PushWA()

   SELECT ( rec[ "wa" ] )

   IF !Used() .AND. !lSql

      _dbf := my_home() + rec[ "table" ]
      BEGIN SEQUENCE WITH {| err| err:cargo :=  Break( err ) }

         dbUseArea( .F., DBFENGINE, _dbf, rec[ "alias" ], .T., .F. )

      RECOVER using _err

         // tabele ocigledno nema, tako da se struktura ne moze utvrditi
         rec[ "dbf_fields" ]     := NIL
         rec[ "dbf_fields_len" ] := NIL

         _msg := "ERR-DBF: " + _err:description + ": tbl:" + my_home() + rec[ "table" ] + " alias:" + rec[ "alias" ] + " se ne moze otvoriti ?!"
         log_write( _msg, 5 )
         RETURN .T.

      END SEQUENCE
      lTabelaOtvorenaOvdje := .T.
   ENDIF


   IF !USED() .AND. lSql
         rec[ "dbf_fields" ]     := NIL
         rec[ "dbf_fields_len" ] := NIL
   ELSE
         rec[ "dbf_fields" ] := NIL
         set_rec_from_dbstruct( @rec )
   ENDIF

   IF lTabelaOtvorenaOvdje
      USE
   ENDIF

   PopWa()
   RETURN .T.



FUNCTION set_rec_from_dbstruct( rec )

   LOCAL _struct, _i
   LOCAL _fields := {}, _fields_len

   IF rec[ "dbf_fields" ] != NIL
      // dbf_fields, dbf_fields_len su vec popunjena
      RETURN NIL
   ENDIF

   _struct := dbStruct()

   _fields_len := hb_Hash()
   FOR _i := 1 TO Len( _struct )
      AAdd( _fields, Lower( _struct[ _i, 1 ] ) )
      // char(10), num(12,2) => {{"C", 10, 0}, {"N", 12, 2}}

      IF _struct[ _i, 2 ] == "B"

         // double
         _fields_len[ Lower( _struct[ _i, 1 ] ) ] := { _struct[ _i, 2 ], 18, 8 }

      ELSEIF _struct[ _i, 2 ] == "Y" .OR. ( _struct[ _i, 2 ] == "I" .AND. _struct[ _i, 4 ] > 0 )

         // za currency polje stoji I 8 4 - sto znaci currency sa cetiri decimale
         // mislim da se ovdje radi o tome da se u 4 bajta stavlja integer dio, a u ostala 4 decimalni dio
         _fields_len[ Lower( _struct[ _i, 1 ] ) ] := { _struct[ _i, 2 ], 18, _struct[ _i, 4 ] }

      ELSE
         _fields_len[ Lower( _struct[ _i, 1 ] ) ] := { _struct[ _i, 2 ], _struct[ _i, 3 ], _struct[ _i, 4 ] }

      ENDIF
   NEXT

   rec[ "dbf_fields" ]     := _fields
   rec[ "dbf_fields_len" ] := _fields_len

   RETURN NIL



FUNCTION my_close_all_dbf()

   LOCAL nPos := 100

   CLOSE ALL

   WHILE nPos > 0

      // ako je neki dbf ostao otvoren nPos ce vratiti poziciju tog a_dbf_recorda
      nPos := hb_HScan( __f18_dbfs, {| key, rec | zatvori_dbf( rec ) == .F.  } )
      IF nPos > 0
         hb_idleSleep( 0.1 )
      ELSE
         // svi dbf-ovi su zatvoreni
         EXIT
      ENDIF

   ENDDO

   RETURN .T.


FUNCTION is_sql_table( cDbf )

   LOCAL lSql

   IF cDbf == NIL
      cDbf := Alias()
   ENDIF

   IF Empty( cDbf )
      lSql := .F.
   ELSE
      lSql := get_a_dbf_rec( AllTrim( cDbf ) )[ 'sql' ]
   ENDIF

   RETURN lSql




STATIC FUNCTION zatvori_dbf( value )

   SELECT( value[ 'wa' ] )

   IF Used()
      // ostalo je još otvorenih DBF-ova
      USE
      RETURN .F.
   ELSE
      RETURN .T.
   ENDIF
