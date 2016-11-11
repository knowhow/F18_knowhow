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

 update_rec_server_and_dbf( cTabela, hRecord, 1, "FULL") - zapocni/zavrsi transakciju unutar funkcije
*/

FUNCTION update_rec_server_and_dbf( cTabela, hRecord, algoritam, cTransaction )

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
   LOCAL lLock
   LOCAL hParams

   _ret := .T.


   IF cTransaction == "FULL"
      lLock := .T.
   ELSE
      lLock := .F.
   ENDIF


   // trebamo where str za hRecord rec
   set_table_values_algoritam_vars( @cTabela, @hRecord, @algoritam, @cTransaction, @_a_dbf_rec, @_alg, @_where_str, @_alg_tag )

   IF Alias() <> _a_dbf_rec[ "alias" ]
      _msg := "ERR "  + RECI_GDJE_SAM0 + " ALIAS() = " + Alias() + " <> " + _a_dbf_rec[ "alias" ]
      log_write( _msg, 2 )
      Alert( _msg )
      error_bar( "update", _msg )
      RETURN .F.
   ENDIF

   // log_write( "START: update_rec_server_and_dbf " + cTabela, 9 )
   _values_dbf := dbf_get_rec()

   // trebamo where str za stanje dbf-a
   set_table_values_algoritam_vars( @cTabela, @_values_dbf, @algoritam, @cTransaction, @_a_dbf_rec, @_alg, @_where_str_dbf, @_alg_tag )

   IF cTransaction $ "FULL#BEGIN"
      run_sql_query( "BEGIN" )
      unlock_semaphore( cTabela )
      lock_semaphore( cTabela )
   ENDIF

   IF !sql_table_update( cTabela, "del", nil, _where_str ) // izbrisi sa servera stare vrijednosti za hRecord

      IF cTransaction == "FULL"
         run_sql_query( "ROLLBACK" )
      ENDIF

      _msg := "ERROR: sql delete " + cTabela +  " , ROLLBACK, where: " + _where_str
      log_write( _msg, 1 )
      Alert( _msg )

      _ret := .F.

   ENDIF

   IF _ret .AND.  ( _where_str_dbf != _where_str )

      // izbrisi i stare vrijednosti za _values_dbf
      // ovo nam treba ako se uradi npr. ispravku ID-a sifre
      // id je u dbf = ID=id_stari, NAZ=stari
      //
      // ispravljamo i id, i naz, pa u hRecord imamo
      // id je bio ID=id_novi.  NAZ=naz_novi
      //
      // nije dovoljno da uradimo delete where id=id_novi
      // trebamo uraditi i delete id=id_stari
      // to radimo upravo u sljedecoj sekvenci
      //
      IF !sql_table_update( cTabela, "del", nil, _where_str_dbf )

         IF cTransaction == "FULL"
            run_sql_query( "ROLLBACK" )
         ENDIF

         _msg := "ERROR: sql delete " + cTabela +  " , ROLLBACK, where: " + _where_str_dbf
         ?E _msg
         error_bar( "sql_table", _msg )

         RETURN .F.

      ENDIF

   ENDIF

   IF _ret .AND. !sql_table_update( cTabela, "ins", hRecord )

      IF cTransaction == "FULL"
         run_sql_query( "ROLLBACK" )
         // unlock_semaphore( cTabela )
      ENDIF

      _msg := RECI_GDJE_SAM + "ERRORY: sql_insert: " + cTabela + " , ROLLBACK hRecord: " + pp( hRecord )
      log_write( _msg, 1 )
      Alert( _msg )

      RETURN .F.

   ENDIF


   _full_id_dbf := get_dbf_rec_primary_key( _alg[ "dbf_key_fields" ], _values_dbf ) // stanje u dbf-u (_values_dbf)
   _full_id_mem := get_dbf_rec_primary_key( _alg[ "dbf_key_fields" ], hRecord ) // stanje podataka u mem rec varijabli hRecord


   AAdd( _ids, _alg_tag + _full_id_mem ) // stavi id-ove na server
   IF ( _full_id_dbf <> _full_id_mem ) .AND. !Empty( _full_id_dbf )
      AAdd( _ids, _alg_tag + _full_id_dbf )
   ENDIF

   IF !push_ids_to_semaphore( cTabela, _ids )

      IF cTransaction == "FULL"
         run_sql_query( "ROLLBACK" )
         ?E "ERR ", RECI_GDJE_SAM0, + "push_ids_to_semaphore " + cTabela + "/ ids=", _alg_tag, _ids, " ! ROLLBACK"
      ENDIF

      // log_write( _msg, 1 )
      // Alert( _msg )
      _ret := .F.

   ENDIF

   IF _ret

      IF dbf_update_rec( hRecord )

         IF cTransaction $ "FULL#END"
            hParams := hb_Hash()
            hParams[ "unlock" ] := { cTabela }
            run_sql_query( "COMMIT" )
         ENDIF
         _ret := .T.

      ELSE

         IF cTransaction == "FULL"
            run_sql_query( "ROLLBACK" )
         ENDIF

         _msg := "ERR: " + RECI_GDJE_SAM0 + "dbf_update_rec " + cTabela +  " ! ROLLBACK"
         log_write( _msg, 1 )
         Alert( _msg )

         _ret := .F.

      ENDIF

   ENDIF

   // log_write( "END update_rec_server_and_dbf " + cTabela, 9 )

   RETURN _ret


/*
   algoritam = 1 - nivo zapisa, 2 - dokument ...
*/

FUNCTION delete_rec_server_and_dbf( cTabela, hRecord, algoritam, cTransaction )

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
   LOCAL lLock
   LOCAL hParams

   IF cTransaction == "FULL"
      lLock := .T.
   ELSE
      lLock := .F.
   ENDIF

   _ret := .T.

   set_table_values_algoritam_vars( @cTabela, @hRecord, @algoritam, @cTransaction, @_a_dbf_rec, @_alg, @_where_str, @_alg_tag )

   IF Alias() <> _a_dbf_rec[ "alias" ]
      _msg := "ERR "  + RECI_GDJE_SAM0 + " ALIAS() = " + Alias() + " <> " + _a_dbf_rec[ "alias" ]
      log_write( _msg, 1 )
      error_bar( "del_rec", _msg )
      RaiseError( _msg )
   ENDIF

   // log_write( "delete rec server, poceo", 9 )

   IF cTransaction $ "FULL#BEGIN"
      run_sql_query( "BEGIN" )
      unlock_semaphore( cTabela )
      lock_semaphore( cTabela )
   ENDIF


   IF sql_table_update( cTabela, "del", nil, _where_str )

      IF !_a_dbf_rec[ "sql" ]
         _full_id := get_dbf_rec_primary_key( _alg[ "dbf_key_fields" ], hRecord )
         AAdd( _ids, _alg_tag + _full_id )
         push_ids_to_semaphore( cTabela, _ids )

         SELECT ( _a_dbf_rec[ "wa" ] )
         IF !Used()
            my_use( _a_dbf_rec[ "table" ] )
         ENDIF
      ENDIF


      IF index_tag_num( _alg[ "dbf_tag" ] ) < 1
         IF !_a_dbf_rec[ "sql" ]

            IF cTransaction == "FULL"
               run_sql_query( "ROLLBACK" )
               // unlock_semaphore( cTabela )
            ENDIF

            _msg := "ERROR: " + RECI_GDJE_SAM0 + " tabela: " + cTabela + " DBF_TAG " + _alg[ "dbf_tag" ]
            error_bar( "del_rec", _msg )
            ?E _msg
            RaiseError( _msg )
            RETURN .F.
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

#ifdef F18_DEBUG_SYNC
         ?E "cTabela: " + cTabela + ", pobrisano iz lokalnog dbf-a broj zapisa = " + AllTrim( Str( _count ) )
#endif

         IF cTransaction $ "FULL#END"
            hParams := hb_Hash()
            hParams[ "unlock" ] := { cTabela }
            run_sql_query( "COMMIT", hParams )
         ENDIF

         _ret := .T.

      ELSE

         IF cTransaction == "FULL"
            run_sql_query( "ROLLBACK" )
            _msg := "delete rec server " + cTabela + " nije lockovana ! ROLLBACK"
            ?E _msg
            Alert( _msg )
         ENDIF


         _ret := .F.

      ENDIF

   ELSE

      IF cTransaction == "FULL"
         run_sql_query( "ROLLBACK" )
         _msg := "delete rec server, " + cTabela + " transakcija neuspjesna ! ROLLBACK"
         Alert( _msg )
         ?E _msg
      ENDIF
      _ret := .F.

   ENDIF

   // log_write( "delete rec server, zavrsio", 9 )

   RETURN _ret




FUNCTION delete_all_dbf_and_server( cTabela )

   LOCAL _ids := {}
   LOCAL _pos
   LOCAL _field
   LOCAL _where_str
   LOCAL _a_dbf_rec
   LOCAL _msg
   LOCAL _rec

   _a_dbf_rec := get_a_dbf_rec( cTabela, .T. )
   reopen_exclusive( _a_dbf_rec[ "table" ] )

   unlock_semaphore(  _a_dbf_rec[ "table" ] )
   IF !lock_semaphore( _a_dbf_rec[ "table" ] )
      RETURN .F.
   ENDIF
   run_sql_query( "BEGIN" )

   _rec := hb_Hash()
   _rec[ "id" ] := NIL


   IF sql_table_update( _a_dbf_rec[ "table" ], "del", _rec, "true" )

      push_ids_to_semaphore( _a_dbf_rec[ "table" ], { "#F" } )
      run_sql_query( "COMMIT" )
      unlock_semaphore( _a_dbf_rec[ "table" ] )
      my_dbf_zap( _a_dbf_rec[ "table" ] )

      RETURN .T.

   ELSE

      _msg := cTabela + "transakcija neuspjesna ! ROLLBACK"
      Alert( _msg )
      log_write( _msg, 1 )

      run_sql_query( "ROLLBACK" )
      RETURN .F.

   ENDIF

   RETURN .T.


// --------------------------------------------------------------------------------------------------------------
// inicijalizacija varijabli koje koriste update and delete_from_server_and_dbf  funkcije
// ---------------------------------------------------------------------------------------------------------------
STATIC FUNCTION set_table_values_algoritam_vars( cTabela, hRecord, algoritam, cTransaction, a_dbf_rec, alg, where_str, alg_tag )

   LOCAL _key
   LOCAL _count := 0
   LOCAL _use_tag := .F.
   LOCAL _alias
   LOCAL lSqlTable, uValue
   LOCAL _msg

   IF cTabela == NIL
      cTabela := Alias()
   ENDIF

   a_dbf_rec := get_a_dbf_rec( cTabela )

   // ako je alias proslijedjen kao ulazni parametar, prebaci se na dbf_table
   cTabela := a_dbf_rec[ "table" ]


   IF hRecord == NIL
      _alias := Alias()
      hRecord := dbf_get_rec()

      IF ( a_dbf_rec[ "alias" ] != _alias )
         RaiseError( "hRecord matrica razlicita od tabele ALIAS():" + _alias + " cTabela=" + cTabela )
      ENDIF

   ENDIF

   IF algoritam == NIL
      algoritam = 1
   ENDIF

   // nema zapoceta transakcija
   IF cTransaction == NIL
      // pocni i zavrsi trasakciju
      cTransaction := "FULL"
   ENDIF


   alg := a_dbf_rec[ "algoritam" ][ algoritam ]
   lSqlTable := a_dbf_rec[ "sql" ]

   FOR EACH _key in alg[ "dbf_key_fields" ]

      ++ _count
      IF ValType( _key ) == "C"

         // ne gledaj numericke kljuceve, koji su array stavke
         IF !hb_HHasKey( hRecord, _key )
            _msg := RECI_GDJE_SAM + "# tabela:" + cTabela + "#bug - nepostojeći kljuc:" + _key +  "#hRecord:" + pp( hRecord )
            log_write( _msg, 1 )
            MsgBeep( _msg )
            error_bar( "set_t_alg", _msg )
            RETURN .F.
         ENDIF

         IF ValType( hRecord[ _key ] ) == "C"

            // ako je dbf_fields_len['id'][2] = 6
            // karakterna polja se moraju PADR-ovati
            // hRecord['id'] = '0' => '0     '
            set_rec_from_dbstruct( @a_dbf_rec )


/* uvijek je  hRecord db_get_rec()  uvijek cp852 enkodiran
            uValue := Unicode():New( hRecord[ _key ], lSqlTable ) // unicode value

            hRecord[ _key ] := uValue:PadR( a_dbf_rec[ "dbf_fields_len" ][ _key ][ 2 ] )
            IF !lSqlTable
               // DBFCDX tabela mora sadržati CP 852 string
               hRecord[ _key ] := hb_UTF8ToStr( hRecord[ _key ] )
            ENDIF
*/

            // provjeri prvi dio kljuca
            // ako je # onda obavezno setuj tag
            IF _count == 1
               IF PadR( hRecord[ _key ], 1 ) == "#"
                  _use_tag := .T.
               ENDIF
            ENDIF

         ENDIF

      ENDIF

   NEXT

   BEGIN SEQUENCE WITH {| err| err:cargo := { "var",  "hRecord", hRecord }, GlobalErrorHandler( err ) }
      where_str := sql_where_from_dbf_key_fields( alg[ "dbf_key_fields" ], hRecord, lSqlTable )
   END SEQUENCE

   IF algoritam > 1 .OR. _use_tag == .T.
      alg_tag := "#" + AllTrim( Str( algoritam ) )
   ENDIF

   RETURN .T.
