/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

/*
  update podataka za jedan dbf zapis na serveru
  mijenja zapis na serveru, pa ako je sve ok onda uradi update dbf-a

 update_rec_server_and_dbf( table, values, 1, "FULL") - zapocni/zavrsi transakciju unutar funkcije
*/

FUNCTION update_rec_server_and_dbf( table, values, algoritam, transaction, lock )

   LOCAL _ids := {}
   LOCAL _pos
   LOCAL _full_id_dbf, _full_id_mem
   LOCAL _dbf_pkey_search
   LOCAL _field
   LOCAL _where_str, _where_str_dbf
   LOCAL _t_field, _t_field_dec
   LOCAL _a_dbf_rec, _alg
   LOCAL _msg
   LOCAL _values_dbf
   LOCAL _alg_tag := ""
   LOCAL _ret

   _ret := .T.

   IF lock == NIL
      IF transaction == "FULL"
         lock := .T.
      ELSE
         lock := .F.
      ENDIF
   ENDIF

   // trebamo where str za values rec
   set_table_values_algoritam_vars( @table, @values, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str, @_alg_tag )

   IF Alias() <> _a_dbf_rec[ "alias" ]
      _msg := "ERR "  + RECI_GDJE_SAM0 + " ALIAS() = " + Alias() + " <> " + _a_dbf_rec[ "alias" ]
      log_write( _msg, 2 )
      Alert( _msg )
      QUIT_1
   ENDIF

   log_write( "START: update_rec_server_and_dbf " + table, 9 )

   _values_dbf := dbf_get_rec()

   // trebamo where str za stanje dbf-a
   set_table_values_algoritam_vars( @table, @_values_dbf, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str_dbf, @_alg_tag )

   IF lock
      lock_semaphore( table, "lock" )
   ENDIF

   IF transaction $ "FULL#BEGIN"
      sql_table_update( table, "BEGIN" )
   ENDIF

   // izbrisi sa servera stare vrijednosti za values
   IF !sql_table_update( table, "del", nil, _where_str )

      IF transaction == "FULL"
         sql_table_update( table, "ROLLBACK" )
      ENDIF

      _msg := "ERROR: sql delete " + table +  " , ROLLBACK, where: " + _where_str
      log_write( _msg, 1 )
      Alert( _msg )

      _ret := .F.

   ENDIF

   IF _ret .AND.  ( _where_str_dbf != _where_str )

      // izbrisi i stare vrijednosti za _values_dbf
      // ovo nam treba ako se uradi npr. ispravku ID-a sifre
      // id je u dbf = ID=id_stari, NAZ=stari
      //
      // ispravljamo i id, i naz, pa u values imamo
      // id je bio ID=id_novi.  NAZ=naz_novi
      //
      // nije dovoljno da uradimo delete where id=id_novi
      // trebamo uraditi i delete id=id_stari
      // to radimo upravo u sljedecoj sekvenci
      //
      IF !sql_table_update( table, "del", nil, _where_str_dbf )

         IF transaction == "FULL"
            sql_table_update( table, "ROLLBACK" )
         ENDIF

         _msg := "ERROR: sql delete " + table +  " , ROLLBACK, where: " + _where_str_dbf
         log_write( _msg, 1 )
         Alert( _msg )

         RETURN .F.

      ENDIF

   ENDIF

   IF _ret .AND. !sql_table_update( table, "ins", values )

      IF transaction == "FULL"
         sql_table_update( table, "ROLLBACK" )
      ENDIF

      _msg := RECI_GDJE_SAM + "ERRORY: sql_insert: " + table + " , ROLLBACK values: " + pp( values )
      log_write( _msg, 1 )
      Alert( _msg )

      RETURN .F.

   ENDIF

   // stanje u dbf-u (_values_dbf)
   _full_id_dbf := get_dbf_rec_primary_key( _alg[ "dbf_key_fields" ], _values_dbf )
   // stanje podataka u mem rec varijabli values
   _full_id_mem := get_dbf_rec_primary_key( _alg[ "dbf_key_fields" ], values )

   // stavi id-ove na server
   AAdd( _ids, _alg_tag + _full_id_mem )
   IF ( _full_id_dbf <> _full_id_mem ) .AND. !Empty( _full_id_dbf )
      AAdd( _ids, _alg_tag + _full_id_dbf )
   ENDIF

   IF !push_ids_to_semaphore( table, _ids )

      IF transaction == "FULL"
         sql_table_update( table, "ROLLBACK" )
      ENDIF

      _msg := "ERR " + RECI_GDJE_SAM0 + "push_ids_to_semaphore " + table + "/ ids=" + _alg_tag + _ids  + " ! ROLLBACK"
      log_write( _msg, 1 )
      Alert( _msg )

      _ret := .F.

   ENDIF

   IF _ret

      IF dbf_update_rec( values )

         IF transaction $ "FULL#END"
            sql_table_update( table, "END" )
         ENDIF

         _ret := .T.

      ELSE

         IF transaction == "FULL"
            sql_table_update( table, "ROLLBACK" )
         ENDIF

         _msg := "ERR: " + RECI_GDJE_SAM0 + "dbf_update_rec " + table +  " ! ROLLBACK"
         log_write( _msg, 1 )
         Alert( _msg )

         _ret := .F.

      ENDIF

   ENDIF

   IF lock
      lock_semaphore( table, "free" )
   ENDIF

   log_write( "END update_rec_server_and_dbf " + table, 9 )

   RETURN _ret


// ----------------------------------------------------------------------
// algoritam = 1 - nivo zapisa, 2 - dokument ...
// ----------------------------------------------------------------------
FUNCTION delete_rec_server_and_dbf( table, values, algoritam, transaction, lock )

   LOCAL _ids := {}
   LOCAL _pos
   LOCAL _full_id
   LOCAL _dbf_pkey_search
   LOCAL _field, _count
   LOCAL _where_str
   LOCAL _t_field, _t_field_dec
   LOCAL _a_dbf_rec, _alg
   LOCAL _msg
   LOCAL _alg_tag := ""
   LOCAL _ret
   LOCAL lIndex := .T.

   IF lock == NIL
      IF transaction == "FULL"
         lock := .T.
      ELSE
         lock := .F.
      ENDIF
   ENDIF

   _ret := .T.

   set_table_values_algoritam_vars( @table, @values, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str, @_alg_tag )

   IF Alias() <> _a_dbf_rec[ "alias" ]
      _msg := "ERR "  + RECI_GDJE_SAM0 + " ALIAS() = " + Alias() + " <> " + _a_dbf_rec[ "alias" ]
      log_write( _msg, 1 )
      Alert( _msg )
      RaiseError( _msg )
      QUIT_1
   ENDIF

   log_write( "delete rec server, poceo", 9 )

   IF lock
      lock_semaphore( table, "lock" )
   ENDIF

   IF transaction $ "FULL#BEGIN"
      sql_table_update( table, "BEGIN" )
   ENDIF

   IF sql_table_update( table, "del", nil, _where_str )

      _full_id := get_dbf_rec_primary_key( _alg[ "dbf_key_fields" ], values )

      AAdd( _ids, _alg_tag + _full_id )
      push_ids_to_semaphore( table, _ids )

      SELECT ( _a_dbf_rec[ "wa" ] )
      IF !USED()
           my_use( _a_dbf_rec[ "table" ] )
      ENDIF

      IF index_tag_num( _alg[ "dbf_tag" ] ) < 1
         IF !_a_dbf_rec[ "sql" ]

            lock_semaphore( table, "free" )

            IF transaction == "FULL"
               sql_table_update( table, "ROLLBACK" )
            ENDIF

            _msg := "ERROR: " + RECI_GDJE_SAM0 + " tabela: " + table + " DBF_TAG " + _alg[ "dbf_tag" ]
            Alert( _msg )
            log_write( _msg, 1 )
            RaiseError( _msg )
            QUIT_1
         ELSE
            lIndex := .F.
         ENDIF
      ELSE
         lIndex := .T.
         SET ORDER TO TAG ( _alg[ "dbf_tag" ] )
      ENDIF

      IF my_flock()

         _count := 0

         IF lIndex
            SEEK _full_id

            WHILE Found()
               ++ _count
               DELETE
               // sve dok budes nalazio pod ovim kljucem brisi
               SEEK _full_id
            ENDDO
         ELSE
            IF Alias() != "SIFV"
               DELETE
            ENDIF
         ENDIF

         my_unlock()

         log_write( "table: " + table + ", pobrisano iz lokalnog dbf-a broj zapisa = " + AllTrim( Str( _count ) ), 7 )

         IF transaction $ "FULL#END"
            sql_table_update( table, "END" )
         ENDIF

         _ret := .T.

      ELSE

         IF transaction == "FULL"
            sql_table_update( table, "ROLLBACK" )
         ENDIF

         _msg := "delete rec server " + table + " nije lockovana !!! ROLLBACK"
         log_write( _msg, 1 )
         Alert( _msg )

         _ret := .F.

      ENDIF

   ELSE

      IF transaction == "FULL"
         sql_table_update( table, "ROLLBACK" )
      ENDIF

      _msg := "delete rec server, " + table + " transakcija neuspjesna ! ROLLBACK"
      Alert( _msg )
      log_write( _msg, 1 )

      _ret := .F.

   ENDIF

   IF lock
      lock_semaphore( table, "free" )
   ENDIF

   log_write( "delete rec server, zavrsio", 9 )

   RETURN _ret




FUNCTION delete_all_dbf_and_server( table )

   LOCAL _ids := {}
   LOCAL _pos
   LOCAL _field
   LOCAL _where_str
   LOCAL _a_dbf_rec
   LOCAL _msg
   LOCAL _rec

   _a_dbf_rec := get_a_dbf_rec( table )
   reopen_exclusive( _a_dbf_rec[ "table" ] )

   lock_semaphore( table, "lock" )
   sql_table_update( table, "BEGIN" )

   _rec := hb_Hash()
   _rec[ "id" ] := NIL


   IF sql_table_update( table, "del", _rec, "true" )

      push_ids_to_semaphore( table, { "#F" } )
      sql_table_update( table, "END" )
      my_dbf_zap( table )

      RETURN .T.

   ELSE

      _msg := table + "transakcija neuspjesna ! ROLLBACK"
      Alert( _msg )
      log_write( _msg, 1 )

      sql_table_update( table, "ROLLBACK" )
      RETURN .F.

   ENDIF

   lock_semaphore( _tbl_suban, "free" )

   RETURN .T.


// --------------------------------------------------------------------------------------------------------------
// inicijalizacija varijabli koje koriste update and delete_from_server_and_dbf  funkcije
// ---------------------------------------------------------------------------------------------------------------
STATIC FUNCTION set_table_values_algoritam_vars( table, values, algoritam, transaction, a_dbf_rec, alg, where_str, alg_tag )

   LOCAL _key
   LOCAL _count := 0
   LOCAL _use_tag := .F.
   LOCAL _alias
   LOCAL lSqlTable, uValue

   IF table == NIL
      table := Alias()
   ENDIF

   a_dbf_rec := get_a_dbf_rec( table )

   // ako je alias proslijedjen kao ulazni parametar, prebaci se na dbf_table
   table := a_dbf_rec[ "table" ]


   IF values == NIL
      _alias := Alias()
      values := dbf_get_rec()

      IF ( a_dbf_rec[ "alias" ] != _alias )
         RaiseError( "values matrica razlicita od tabele ALIAS():" + _alias + " table=" + table )
      ENDIF

   ENDIF

   IF algoritam == NIL
      algoritam = 1
   ENDIF

   // nema zapoceta transakcija
   IF transaction == NIL
      // pocni i zavrsi trasakciju
      transaction := "FULL"
   ENDIF


   alg := a_dbf_rec[ "algoritam" ][ algoritam ]
   lSqlTable := a_dbf_rec[ "sql" ]

   FOR EACH _key in alg[ "dbf_key_fields" ]

      ++ _count
      IF ValType( _key ) == "C"

         // ne gledaj numericke kljuceve, koji su array stavke
         IF !hb_HHasKey( values, _key )
            _msg := RECI_GDJE_SAM + "# tabela:" + table + "#bug - nepostojeći kljuc:" + _key +  "#values:" + pp( values )
            log_write( _msg, 1 )
            MsgBeep( _msg )
            QUIT_1
         ENDIF

         IF ValType( values[ _key ] ) == "C"

            // ako je dbf_fields_len['id'][2] = 6
            // karakterna polja se moraju PADR-ovati
            // values['id'] = '0' => '0     '
            set_rec_from_dbstruct( @a_dbf_rec )

            uValue := Unicode():New( values[ _key ], lSqlTable )
            values[ _key ] := uValue:padr( a_dbf_rec[ "dbf_fields_len" ][ _key ][ 2 ] )
            IF !lSqlTable
               // DBFCDX tabela mora sadržati CP 852 string
               values[ _key ] := hb_Utf8ToStr( values[ _key ] )
            ENDIF

            // provjeri prvi dio kljuca
            // ako je # onda obavezno setuj tag
            IF _count == 1
               IF PadR( values[ _key ], 1 ) == "#"
                  _use_tag := .T.
               ENDIF
            ENDIF

         ENDIF

      ENDIF

   NEXT

   BEGIN SEQUENCE WITH {|err| err:cargo := { "var",  "values", values }, GlobalErrorHandler( err ) }
      where_str := sql_where_from_dbf_key_fields( alg[ "dbf_key_fields" ], values, lSqlTable )
   END SEQUENCE

   IF algoritam > 1 .OR. _use_tag == .T.
      alg_tag := "#" + AllTrim( Str( algoritam ) )
   ENDIF

   RETURN
