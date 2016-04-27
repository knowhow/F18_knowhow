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

STATIC s_hF18Dbfs := nil
STATIC s_mtxMutex

FUNCTION set_a_dbfs()

   LOCAL _dbf_fields, _sql_order
   LOCAL _alg
   LOCAL cDatabase := my_database()

   IF s_hF18Dbfs == NIL
      hb_mutexLock( s_mtxMutex )
      s_hF18Dbfs  := hb_Hash()
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   IF ! hb_HHasKey( s_hF18Dbfs, cDatabase )
      hb_mutexLock( s_mtxMutex )
      s_hF18Dbfs[ cDatabase ] := hb_Hash()
      hb_mutexUnlock( s_mtxMutex )
   ENDIF

   set_a_dbf_sif()
   set_a_dbf_params()
   set_a_dbf_sifk_sifv()
   set_a_dbf_temporary()

   IF f18_use_module( "fin" )
      set_a_dbf_fin()
   ENDIF

   IF f18_use_module( "kalk" )
      set_a_dbf_kalk()
   ENDIF

   IF f18_use_module( "fakt" )
      set_a_dbf_fakt()
   ENDIF

   IF f18_use_module( "ld" )
      set_a_dbf_ld()
      set_a_dbf_ld_sif()
   ENDIF

   IF f18_use_module( "epdv" )
      set_a_dbf_epdv()
   ENDIF

   IF f18_use_module( "os" )
      set_a_dbf_os()
   ENDIF

   IF f18_use_module( "virm" )
      set_a_dbf_virm()
   ENDIF

#ifdef F18_POS
   IF f18_use_module( "pos" )
      set_a_dbf_pos()
   ENDIF
#endif

#ifdef F18_RNAL
   IF f18_use_module( "rnal" )
      set_a_dbf_rnal()
   ENDIF
#endif

#ifdef F18_MAT
   IF f18_use_module( "mat" )
      set_a_dbf_mat()
   ENDIF
#endif

#ifdef F18_KADEV
   IF f18_use_module( "kadev" )
      set_a_dbf_kadev()
   ENDIF
#endif

   RETURN .T.

// ------------------------------------------------
// za sve tabele kreiraj dbf_fields strukturu
// ------------------------------------------------
FUNCTION set_a_dbfs_key_fields()

   LOCAL _key

   FOR EACH _key in s_hF18Dbfs[ my_server_params()[ "database" ] ]:Keys

      // nije zadano - na osnovu strukture dbf-a napraviti dbf_fields
      IF !hb_HHasKey( s_hF18Dbfs[ my_server_params()[ "database" ] ][ _key ], "dbf_fields" )  .OR.  s_hF18Dbfs[ my_server_params()[ "database" ] ][ _key ][ "dbf_fields" ] == NIL
         set_dbf_fields_from_struct( @s_hF18Dbfs[ my_server_params()[ "database" ] ][ _key ] )
      ENDIF

   NEXT

   RETURN .T.


// ------------------------------------
// dodaj stavku u f18_dbfs
// ------------------------------------
FUNCTION f18_dbfs_add( cTable, _item )

   LOCAL cDatabase := my_database()

   hb_mutexLock( s_mtxMutex )
   s_hF18Dbfs[ cDatabase ][ cTable ] := _item
   hb_mutexUnlock( s_mtxMutex )

   RETURN .T.



FUNCTION f18_dbfs()

   LOCAL cDatabase := my_database()

   RETURN s_hF18Dbfs[ cDatabase ]



FUNCTION set_a_dbf_temp( table, alias, wa )

   LOCAL _item

   _item := hb_Hash()

   _item[ "alias" ] := alias
   _item[ "table" ] := table
   _item[ "wa" ]    := wa
   _item[ "temp" ]  := .T.
   _item[ "chk0" ]  := .T.
   _item[ "sql" ] := .F.
   _item[ "sif" ]  := .F.

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
   _item[ "sif" ] := .T.
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
FUNCTION get_a_dbf_rec( cTable, _only_basic_params )

   LOCAL _msg, _rec, _keys, cDbfTable, _key
   LOCAL nI, cMsg, cDatabase := my_database(), hServerParams := my_server_params()

   cDbfTable := "x"

   IF _only_basic_params == NIL
      _only_basic_params = .F.
   ENDIF

   IF !hb_HHasKey( hServerParams, "database" ) .OR. ValType( s_hF18Dbfs[ hServerParams[ "database" ] ] ) <> "H"
      _msg := ""
      LOG_CALL_STACK _msg
      ?E  "get_a_dbf_rec: " + cTable + " s_hF18Dbfs nije inicijalizirana " + _msg
   ENDIF

   IF hb_HHasKey( s_hF18Dbfs[ cDatabase ], cTable )
      cDbfTable := cTable
   ELSE
      // probaj preko aliasa
      FOR EACH _key IN s_hF18Dbfs[ cDatabase ]:Keys
         IF ValType( cTable ) == "N"
            // zadana je workarea
            IF s_hF18Dbfs[ cDatabase ][ _key ][ "wa" ] == cTable
               cDbfTable := _key
               EXIT
            ENDIF
         ELSE
            IF s_hF18Dbfs[ cDatabase ][ _key ][ "alias" ] == Upper( cTable )
               cDbfTable := _key
               EXIT
            ENDIF
         ENDIF
      NEXT
   ENDIF


   IF cDbfTable == "x"
      _msg := "ERROR: x dbf alias " + cTable + " ne postoji u a_dbf_rec ?!"

      _rec := hb_Hash()
      _rec[ "temp" ] := .T.
      _rec[ "table" ] := cTable
      _rec[ "alias" ] := cTable
      _rec[ "sql" ] := .F.
      _rec[ "sif" ] := .F.
      _rec[ "wa" ] := 6000

      LOG_CALL_STACK _msg
      ?E _msg
      RETURN _rec

   ENDIF

   IF hb_HHasKey( s_hF18Dbfs[ cDatabase ], cDbfTable )
      _rec := s_hF18Dbfs[ cDatabase ][ cDbfTable ] // preferirani set parametara
   ELSE
      _rec := hb_Hash()
      _rec[ "table" ] := cDbfTable
      _rec[ "alias" ] := Alias()
      _rec[ "wa" ] := Select()
      _rec[ "temp" ] := .T.
      _rec[ "chk0" ] := .F.
      _rec[ "sql" ] := .F.
      _rec[ "sif" ] := .F.
   ENDIF

   IF !hb_HHasKey( _rec, "table" ) .OR. _rec[ "table" ] == NIL
      _msg := RECI_GDJE_SAM + " set_a_dbf nije definisan za table= " + cTable
      Alert( _msg )
      log_write( _msg, 2 )
      RaiseError( _msg )
      QUIT_1
   ENDIF

   IF !hb_HHasKey( _rec, "blacklisted" ) // ako nema definisane blackliste, setuj je ali kao NIL
      _rec[ "blacklisted" ] := NIL
   ENDIF

   IF !hb_HHasKey( _rec, "sql" )
      _rec[ "sql" ] := .F.
   ENDIF

   IF !hb_HHasKey( _rec, "chk0" )
      _rec[ "chk0" ] := .F.
   ENDIF

   IF !hb_HHasKey( _rec, "sif" )
      _rec[ "sif" ] := .F.
   ENDIF

   IF _only_basic_params
      RETURN _rec
   ENDIF

   // nije zadano - na osnovu strukture dbf-a
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


FUNCTION set_a_dbf_rec_chk0( cTable )

   LOCAL lSet := .F.
   LOCAL cDatabase := my_database()

   IF cDatabase == "?undefined?"
      error_bar( "chk0", "set" + cTable )
      RETURN .F.
   ENDIF

   DO WHILE !lSet
      IF hb_mutexLock( s_mtxMutex )
         s_hF18Dbfs[ cDatabase ][ cTable ][ "chk0" ] := .T.
         lSet := .T.
         hb_mutexUnlock( s_mtxMutex )
      ENDIF
   ENDDO

   RETURN .T.


FUNCTION unset_a_dbf_rec_chk0( cTable )

   LOCAL lSet := .F.
   LOCAL cDatabase := my_database()

   IF cDatabase == "?undefined?"
      error_bar( "chk0", "unset" + cTable )
      RETURN .F.
   ENDIF

   DO WHILE !lSet
      IF hb_mutexLock( s_mtxMutex )
         lSet := .T.
         s_hF18Dbfs[ cDatabase ][ cTable ][ "chk0" ] := .F.
         hb_mutexUnlock( s_mtxMutex )
      ENDIF
   ENDDO

   RETURN .T.


FUNCTION is_chk0( cTable )

   LOCAL cDatabase := my_database()

   IF cDatabase == "?undefined?"
      RETURN .F.
   ENDIF

   RETURN s_hF18Dbfs[ cDatabase ][ cTable ][ "chk0" ]


FUNCTION is_sifarnik( cTable )

   LOCAL cDatabase := my_database()

   IF cDatabase == "?undefined?"
      RETURN .F.
   ENDIF

   RETURN s_hF18Dbfs[ cDatabase ][ cTable ][ "sif" ]


FUNCTION dbf_alias_has_semaphore( alias )

   LOCAL _ret := .F.
   LOCAL _rec, cDbfTable, _key
   LOCAL cDatabase := my_database()

   // ako nema parametra uzmi tekuci alias na kome se nalazimo
   IF ( alias == NIL )
      alias := Alias()
   ENDIF

   IF cDatabase == "?undefined?"
      error_bar( "a_dbfs", "dbf_alias_has_semaphore: " + alias )
      RETURN .F.
   ENDIF

   cDbfTable := "x"

   FOR EACH _key IN s_hF18Dbfs[ cDatabase ]:Keys
      IF ValType( alias ) == "N"
         IF s_hF18Dbfs[ cDatabase ][ _key ][ "wa" ] == ALIAS // zadana je workarea
            cDbfTable := _key
            EXIT
         ENDIF
      ELSE
         IF s_hF18Dbfs[ cDatabase ][ _key ][ "alias" ] == Upper( alias )
            cDbfTable := _key
            EXIT
         ENDIF
      ENDIF
   NEXT

   IF hb_HHasKey( s_hF18Dbfs[ cDatabase ], cDbfTable )

      _rec := s_hF18Dbfs[ cDatabase ][ cDbfTable ]
      IF _rec[ "temp" ] == .F.
         _ret := .T. // tabela ima semafor
      ENDIF

   ENDIF

   RETURN _ret


FUNCTION imaju_unchecked_sifarnici()

   LOCAL cKey, lSql, lSif, lChk0
   LOCAL cDatabase := my_database()

   FOR EACH cKey IN s_hF18Dbfs[ cDatabase ]:Keys

      lSql := .F.
      IF hb_HHasKey( s_hF18Dbfs[ cDatabase ][ cKey ], "sql" )
         lSql := s_hF18Dbfs[ cDatabase ][ cKey ][ "sql" ]
      ENDIF

      lSif := .F.
      IF hb_HHasKey( s_hF18Dbfs[ cDatabase ][ cKey ], "sif" )
         lSif := s_hF18Dbfs[ cDatabase ][ cKey ][ "sif" ]
      ENDIF

      lChk0 := .F.
      IF hb_HHasKey( s_hF18Dbfs[ cDatabase ][ cKey ], "chk0" )
         IF hb_mutexLock( s_mtxMutex )
            lChk0 := s_hF18Dbfs[ cDatabase ][ cKey ][ "chk0" ]
            hb_mutexUnlock( s_mtxMutex )
         ENDIF
      ENDIF

      IF !lSQl .AND. !lChk0 .AND. lSif
#ifdef F18_DEBUG_SYNC
         ?E "UUUUUUUUUUU unchecked sif", cDatabase, cKey, "chk0", lChk0, "sif", lSif, "sql", lSql
#endif
         RETURN .T.
      ENDIF
   NEXT


#ifdef F18_DEBUG_SYNC
   ?E "OOO nema unchecked sif"
#endif

   RETURN .F.


FUNCTION print_a_dbfs()

   LOCAL nCount := 0, cKey
   LOCAL cDatabase := my_database()
   LOCAL nCnt, nDel, nCntSql

   ?E Replicate( "A", 60 )
   FOR EACH cKey IN s_hF18Dbfs[ cDatabase ]:Keys
      ?E ++nCount, s_hF18Dbfs[ cDatabase ][ cKey ][ "table" ]
      IF hb_HHasKey( s_hF18Dbfs[ cDatabase ][ cKey ], "chk0" )
         ??E " chk0", s_hF18Dbfs[ cDatabase ][ cKey ][ "chk0" ]
      ELSE
         ??E " chk0 undefined"
      ENDIF
      IF hb_HHasKey( s_hF18Dbfs[ cDatabase ][ cKey ], "sif" )
         ??E " sif", s_hF18Dbfs[ cDatabase ][ cKey ][ "sif" ]
      ELSE
         ??E " sif undefined!"
      ENDIF
      IF !s_hF18Dbfs[ cDatabase ][ cKey ][ "temp" ]
         nCntSql := table_count( s_hF18Dbfs[ cDatabase ][ cKey ][ "table" ] )
         nCnt := 0
         nDel := 0
         ??E " count: sql", nCntSql
         IF !s_hF18Dbfs[ cDatabase ][ cKey ][ "sql" ]
            IF ! dbf_open_temp_and_count( s_hF18Dbfs[ cDatabase ][ cKey ], @nCntSql, @nCnt, @nDel )
               ??E " dbf open ERROR ! "
            ENDIF
            ??E " dbf cnt/del: ", nCnt, "/", nDel, "dbf cnt-del:", nCnt - nDel
            IF ( nCntSql - nCnt + nDel ) != 0
               ?? " ERR DIFF SQL-DBF: ", ( nCntSql - nCnt + nDel )
            ENDIF
         ENDIF


      ENDIF

   NEXT
   ?E Replicate( "a", 70 )

   RETURN .T.




FUNCTION sql_order_from_key_fields( dbf_key_fields ) // "sql_order" hash na osnovu rec["dbf_fields"]

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
FUNCTION set_dbf_fields_from_struct( xRec )

   LOCAL lTabelaOtvorenaOvdje := .F.
   LOCAL _dbf
   LOCAL _err
   LOCAL cLogMsg

   LOCAL lSql
   LOCAL nI, cMsg
   LOCAL hRec

   IF ValType( xRec ) == "C"
#ifdef F18_DEBUG
      ?E "set_dbf_fields xRec=", xRec
#endif
      IF hb_HHasKey( s_hF18Dbfs[ my_server_params()[ "database" ] ], xRec )
         hRec := s_hF18Dbfs[ my_server_params()[ "database" ] ][ xRec ]
      ELSE
         ?E "set_dbf_fields tabela ", xRec, "nije u a_dbf_rec"
         RETURN .F.
      ENDIF
   ELSE
      hRec := xRec
   ENDIF

   lSql := hb_HHasKey( hRec, "sql" ) .AND. ValType( hRec[ "sql" ] ) == "L"  .AND. hRec[ "sql" ]

   IF hRec[ "temp" ]  // ovi podaci ne trebaju za temp tabele
      RETURN .F.
   ENDIF

   PushWA()
   SELECT ( hRec[ "wa" ] )

   IF !Used() .AND. !lSql

      _dbf := my_home() + hRec[ "table" ]
      IF !File( f18_ime_dbf( hRec ) )
#ifdef F18_DEBUG
         cLogMsg := "NO-DBF : tbl:" + my_home() + hRec[ "table" ] + " alias:" + hRec[ "alias" ] + " ne postoji"
         LOG_CALL_STACK cLogMsg
#endif
         RETURN .F.
      ENDIF

      BEGIN SEQUENCE WITH {| err| err:cargo :=  Break( err ) }

         dbUseArea( .F., DBFENGINE, _dbf, hRec[ "alias" ], .T., .F. )

      RECOVER using _err

         // tabele ocigledno nema, tako da se struktura ne moze utvrditi
         hRec[ "dbf_fields" ]     := NIL
         hRec[ "dbf_fields_len" ] := NIL

         cLogMsg := "ERR-DBF: " + _err:description + ": tbl:" + my_home() + hRec[ "table" ] + " alias:" + hRec[ "alias" ] + " se ne moze otvoriti ?!"
         LOG_CALL_STACK cLogMsg

         log_write( cLogMsg, 5 )
         RETURN .F.

      END SEQUENCE
      lTabelaOtvorenaOvdje := .T.
   ENDIF


   IF !Used() .AND. lSql
      hRec[ "dbf_fields" ]     := NIL
      hRec[ "dbf_fields_len" ] := NIL
   ELSE
      hRec[ "dbf_fields" ] := NIL
      set_rec_from_dbstruct( @hRec )
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
      RETURN NIL // dbf_fields, dbf_fields_len su vec popunjena
   ENDIF

   hb_mutexLock( s_mtxMutex )

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

   hb_mutexUnlock( s_mtxMutex )

   RETURN NIL



FUNCTION my_close_all_dbf()

   LOCAL nPos := 100
   LOCAL hServerParams := my_server_params()

   CLOSE ALL

   IF !hb_HHasKey( hServerParams, "database" )
      RETURN .F.
   ENDIF

   DO WHILE nPos > 0

      // ako je neki dbf ostao otvoren nPos ce vratiti poziciju tog a_dbf_recorda
      nPos := hb_HScan( s_hF18Dbfs[ hServerParams[ "database" ] ], {| key, rec | zatvori_dbf( rec ) == .F.  } )
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

   Select( value[ 'wa' ] )

   IF Used()
      // ostalo je još otvorenih DBF-ova
      USE
      RETURN .F.
   ENDIF

   RETURN .T.


INIT PROCEDURE  init_a_dbfs()

   IF s_mtxMutex == NIL
      s_mtxMutex := hb_mutexCreate()
   ENDIF

   RETURN
