/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"



// -----------------------------------------------------------------------------------------------------
// synchro dbf tabele na osnovu id-ova koje su poslali drugi
// -----------------------------------------------------------------------------------------------------
FUNCTION ids_synchro( dbf_table )

   LOCAL _i, _ids_queries
   LOCAL _zap

   _ids_queries := create_queries_from_ids( dbf_table )


   // _ids_queries["ids"] = {  {"00113333 1", "0011333 2"}, {"00224444"}  }
   // _ids_queries["qry"] = {  "select .... in ... rpad('0011333  1') ...", "select .. in ... rpad("0022444")" }

   log_write( "START ids_synchro", 9 )

   log_write( "ids_synchro ids_queries: " + pp( _ids_queries ), 7 )

   DO WHILE .T.

      // ovo je posebni query koji se pojavi ako se nadje ids '#F'
      _zap := AScan( _ids_queries[ "qry" ], "UZMI_STANJE_SA_SERVERA" )

      IF _zap <> 0

         // postoji zahtjev za full synchro
         full_synchro( dbf_table, 50000, .F. )

         // otvoricu tabelu ponovo ... ekskluzivno, ne bi to trebalo biti problem
         reopen_shared( dbf_table, .T. )

         ADel( _zap, _ids_queries[ "qry" ] )

         // ponovo kreiraj _ids_queries u slucaju da je bilo jos azuriranja
         _ids_queries := create_queries_from_ids( dbf_table )

      ELSE
         EXIT
      ENDIF

   ENDDO

   FOR _i := 1 TO Len( _ids_queries[ "ids" ] )

      log_write( "ids_synchro ids_queries/2: " + pp( _ids_queries[ "ids" ][ _i ]  ), 9 )
      // ako nema id-ova po algoritmu _i, onda je NIL ova varijabla
      IF _ids_queries[ "ids" ][ _i ] != NIL

         // pobrisi u dbf-u id-ove koji su u semaforu tabele
         delete_ids_in_dbf( dbf_table, _ids_queries[ "ids" ][ _i ], _i )

         // dodaj sa servera
         fill_dbf_from_server( dbf_table, _ids_queries[ "qry" ][ _i ] )

      ENDIF
   NEXT


   log_write( "END ids_synchro", 9 )

   RETURN .T.



// -------------------------------------------------
// stavi id-ove za dbf tabelu na server
// -------------------------------------------------
FUNCTION push_ids_to_semaphore( table, ids, to_myself )

   LOCAL _tbl
   LOCAL _result
   LOCAL _user := f18_user()
   LOCAL _ret
   LOCAL _qry
   LOCAL _sql_ids
   LOCAL _i
   LOCAL _set_1, _set_2
   LOCAL _server := my_server()

   IF Len( ids ) < 1
      RETURN .F.
   ENDIF

   // stavi semafor i samom sebi
   IF to_myself == NIL
      to_myself := .F.
   ENDIF

   log_write( "START push_ids_to_semaphore", 9 )
   log_write( "push ids: " + table + " / " + pp( ids ), 5 )

   _tbl := "fmk.semaphores_" + Lower( table )

   // treba dodati id za sve DRUGE korisnike
   _result := table_count( _tbl, iif( to_myself, NIL, "user_code <> " + _sql_quote( _user ) ) )

   IF _result < 1
      // jedan korisnik
      log_write( "push_ids_to_semaphore(), samo je jedan korsnik, nista nije pushirano", 9 )
      RETURN .T.
   ENDIF

   _qry := ""

   FOR _i := 1 TO Len( ids )

      _sql_ids := "ARRAY[" + _sql_quote( ids[ _i ] ) + "]"

      // full synchro
      IF ids[ _i ] == "#F"
         // svi raniji id-ovi su nebitni
         // brisemo kompletnu tabelu - radimo full synchro
         _set_1 := "set ids = "
         _set_2 := ""
      ELSE
         // dodajemo postojece
         _set_1 := "SET ids = ids || "
         _set_2 := " AND ((ids IS NULL) OR NOT ( (" + _sql_ids + " <@ ids) OR ids = ARRAY['#F'] ) )"
      ENDIF

      _qry += "UPDATE " + _tbl + " " + _set_1 + _sql_ids + " WHERE "
      IF !to_myself
         _qry += "user_code <> " + _sql_quote( _user )
      ELSE
         _qry += "true"
      ENDIF
      _qry +=  _set_2 + ";"

   NEXT

   // ako id sadrzi vise od 2000 stavki, korisnik je dugo neaktivan, pokreni full sync
   _qry += "UPDATE " + _tbl + " SET ids = ARRAY['#F']  WHERE "
   IF !to_myself
      _qry += "user_code <> " + _sql_quote( _user ) + " AND "
   ENDIF
   _qry += "ids IS NOT NULL AND array_length(ids,1) > 2000"
   _ret := _sql_query( _server, _qry )

   log_write( "END push_ids_to_semaphore", 9 )

   // na kraju uradi update verzije semafora, push operacija
   update_semaphore_version_after_push( table, to_myself )

   IF ValType( _ret ) == "O"
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF


/*
  vrati matricu id-ova za dbf tabelu
*/
FUNCTION get_ids_from_semaphore( table )

   LOCAL _tbl
   LOCAL _tbl_obj, _update_obj
   LOCAL _qry
   LOCAL _ids, _num_arr, _arr, _i
   LOCAL _server := pg_server()
   LOCAL _user := f18_user()
   LOCAL _tok, _versions, _tmp
   LOCAL _log_level := log_level()
   LOCAL lAllreadyInTransaction := .F.

   IF _server:TransactionStatus() > 0
      lAllreadyInTransaction := .T.
   ENDIF

   log_write( "START get_ids_from_semaphore", 7 )

   _tbl := "fmk.semaphores_" + Lower( table )

   IF !lAllreadyInTransaction
      run_sql_query( "BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE" )
   ENDIF

   IF _log_level > 6

      // uzmi verziju i stanje iz semafora prije pocetka
      _versions := get_semaphore_version_h( Lower( table ) )

      _tmp := "prije SELECT, tabela: " + Lower( table )
      _tmp += " version: " + AllTrim( Str( _versions[ "version" ] ) )
      _tmp += " last version: " + AllTrim( Str( _versions[ "last_version" ] ) )

      log_write( _tmp, 7 )

   ENDIF

   _qry := "SELECT ids FROM " + _tbl + " WHERE user_code=" + _sql_quote( _user )
   _tbl_obj := _sql_query( _server, _qry )

   _qry := "UPDATE " + _tbl + " SET  ids=NULL , dat=NULL, version=last_trans_version"
   _qry += " WHERE user_code =" + _sql_quote( _user )
   _update_obj := _sql_query( _server, _qry, .T. )


   IF ( _tbl_obj == NIL ) .OR. ( _update_obj == NIL ) .OR. ( ValType( _update_obj ) == "L" .AND. _update_obj == .F. )

      IF !lAllreadyInTransaction
         sql_table_update( nil, "ROLLBACK", nil, nil, .T. )
      ENDIF

      log_write( "transakcija neuspjesna #29667 ISOLATION LEVEL !", 1, .T. )

      // retry !
      RETURN get_ids_from_semaphore( table )

   ENDIF

   IF _log_level > 6

      // uzmi verziju i stanje verzija na kraju transakcije
      _versions := get_semaphore_version_h( Lower( table ) )

      _tmp := "nakon UPDATE, tabela: " + Lower( table )
      _tmp += " version: " + AllTrim( Str( _versions[ "version" ] ) )
      _tmp += " last version: " + AllTrim( Str( _versions[ "last_version" ] ) )

      log_write( _tmp, 7 )

   ENDIF

   IF !lAllreadyInTransaction
      sql_table_update( nil, "END" )
   ENDIF

   _ids := _tbl_obj:FieldGet( 1 )

   _arr := {}
   IF _ids == NIL
      RETURN _arr
   ENDIF

   _ids := hb_UTF8ToStr( _ids )

   // {id1,id2,id3}
   _ids := SubStr( _ids, 2, Len( _ids ) -2 )

   _num_arr := NumToken( _ids, "," )

   FOR _i := 1 TO _num_arr
      _tok := Token( _ids, ",", _i )
      IF Left( _tok, 1 ) == '"' .AND. Right( _tok, 1 ) == '"'
         // odsjeci duple navodnike "..."
         _tok := SubStr( _tok, 2, Len( _tok ) -2 )
      ENDIF
      AAdd( _arr, _tok )
   NEXT

   log_write( "END get_ids_from_semaphore", 7 )

   RETURN _arr



// ---------------------------------------------------------------------------------------------------------
// napraviti array qry, za sve dostupne ids algoritme
//
// ret["qry"] := { "select .... where .. uslov za podsifra ..", "select ... where ... uslov za sifra .." }
// ret["ids"] := { "01/1", "01/2" }, {"03", "04"}
//
// u gornjem primjeru imamo dva algoritma i dva seta ids-ova - prvi na nivou sifra/podsifra ("01/1", "01/2")
// a drugi na nivou sifre "01", "04"
//
// algoritmi se nalaze u hash varijabli koju nam vraca funkcija f18_dbfs()
// set_a_dbf... funkcije definišu tu hash varijablu
//
// ova util funkcija daje nam id-ove i sql queries potrebne da
// sinhroniziramo dbf sa promjenama koje su napravili drugi korisnici
// -------------------------------------------------------------------------------------------------------------
FUNCTION create_queries_from_ids( table )

   LOCAL _a_dbf_rec, _msg
   LOCAL _qry_1, _qry_2
   LOCAL _queries     := {}
   LOCAL _ids, _ids_2 := {}
   LOCAL _sql_ids := {}
   LOCAL _i, _id
   LOCAL _ret := hb_Hash()
   LOCAL _sql_fields
   LOCAL _algoritam, _alg

   _a_dbf_rec := get_a_dbf_rec( table )

   _sql_fields := sql_fields( _a_dbf_rec[ "dbf_fields" ] )
   _alg := _a_dbf_rec[ "algoritam" ]

   _sql_tbl := "fmk." + table

   FOR _i := 1 TO Len( _alg )
      AAdd( _queries, "SELECT " + _sql_fields + " FROM " + _sql_tbl + " WHERE " )
      AAdd( _sql_ids, NIL )
      AAdd( _ids_2, NIL )
   NEXT

   _ids := get_ids_from_semaphore( table )
   // nuliraj_ids_and_update_my_semaphore_ver(table)

   log_write( "create_queries..(), poceo", 9 )

   // primjer
   // suban 00-11-2222 rbr 1, rbr 2
   // kompletan nalog (#2) 00-11-3333
   // Full synchro (#F)
   // _ids := { "00112222 1", "00112222 2", "#200113333", "#F" }

   FOR EACH _id in _ids

      IF Left( _id, 1 ) == "#"

         IF SubStr( _id, 2, 1 ) == "F"
            // full sinchro
            _algoritam := 99
            _id := "X"
         ELSE
            // algoritam "#2" => algoritam 2
            _algoritam := Val( SubStr( _id, 2, 1 ) )
            _id := SubStr( _id, 3 )
         ENDIF

      ELSE
         _algoritam := 1
      ENDIF

      IF _algoritam == 99
         // full sync zahtjev
         AAdd( _queries, "UZMI_STANJE_SA_SERVERA" )
         AAdd( _sql_ids, NIL )
      ELSE
         // ne moze biti "#3" a da tabela ima definisana samo dva algoritma
         IF _algoritam > Len( _alg )
            _msg := "nasao sam ids " + _id + ". Ovaj algoritam nije podrzan za " + table
            Alert( _msg )
            log_write( "create_queries..(), " + _msg, 5 )
            RaiseError( _msg )
            QUIT_1
         ENDIF

         IF _sql_ids[ _algoritam ] == NIL
            _sql_ids[ _algoritam ] := "("
            _ids_2[ _algoritam ] := {}
         ENDIF

         _sql_ids[ _algoritam ] += _sql_quote( _id ) + ","
         AAdd( _ids_2[ _algoritam ], _id )

      ENDIF
   NEXT

   FOR _i := 1 TO Len( _alg )

      IF _sql_ids[ _i ] != NIL
         // odsjeci zarez na kraju
         _sql_ids[ _i ] := Left( _sql_ids[ _i ], Len( _sql_ids[ _i ] ) - 1 )
         _sql_ids[ _i ] += ")"
         _queries[ _i ] +=  "(" + _alg[ _i ][ "sql_in" ]  + ") IN " + _sql_ids[ _i ]
      ELSE
         _queries[ _i ] := NIL
      ENDIF

   NEXT

   log_write( "create_queries..(), ret[qry]=" + pp( _queries ), 9 )
   log_write( "create_queries..(), ret[ids]=" + pp( _ids_2 ), 9 )
   log_write( "create_queries..(), zavrsio", 9 )
   _ret[ "qry" ] := _queries
   _ret[ "ids" ] := _ids_2

   RETURN _ret




// ------------------------------------------------------
// sve ids-ove pobrisi iz dbf-a
// ids       := {"#20011", "#2012"}
// algoritam := 2
// ------------------------------------------------------
FUNCTION delete_ids_in_dbf( dbf_table, ids, algoritam )

   LOCAL _a_dbf_rec, _alg
   LOCAL _counter, _msg
   LOCAL _fnd, _tmp_id, _rec
   LOCAL _dbf_alias
   LOCAL _dbf_tag
   LOCAL _key_block
   LOCAL _i

   log_write( "delete_ids_in_dbf(), poceo", 9 )

   _a_dbf_rec := get_a_dbf_rec( dbf_table )
   _alg := _a_dbf_rec[ "algoritam" ]

   _dbf_alias := _a_dbf_rec[ "alias" ]
   _dbf_tag := _alg[ algoritam ][ "dbf_tag" ]

   _key_block := _alg[ algoritam ][ "dbf_key_block" ]

   // pobrisimo sve dbf zapise na kojima su drugi radili
   SET ORDER TO TAG ( _dbf_tag )

   _counter := 0

   IF ValType( ids ) != "A"
      Alert( "ids type ? " + ValType( ids ) )
   ENDIF

   DO WHILE .T.

      _fnd := .F.

      FOR EACH _tmp_id in ids

         HSEEK _tmp_id

         DO WHILE !Eof() .AND. Eval( _key_block ) == _tmp_id
            SKIP
            _rec := RecNo()
            SKIP -1
            delete_with_rlock()
            GO _rec

            _fnd := .T.
            ++ _counter
         ENDDO
      NEXT

      IF !_fnd
         EXIT
      ENDIF
   ENDDO

   log_write( "delete_ids_in_dbf(), table: " + dbf_table + "/ dbf_tag =" + _dbf_tag + " pobrisao iz lokalnog dbf-a zapisa = " + AllTrim( Str( _counter ) ), 5 )

   log_write( "delete_ids_in_dbf(), zavrsio", 9 )

   RETURN


// ----------------------------------------------------------
// util funkcija za ids algoritam kreira dbf kljuc potreban
// za brisanje zapisa koje su drugi mijenjali
//
// dbf_fields - {"id", {"iznos", 12, 2} }
// rec - { "01", 15.5 }
//
// => "01       15.50"
// ----------------------------------------------------------
FUNCTION get_dbf_rec_primary_key( dbf_key_fields, rec )

   LOCAL _field, _t_field, _t_field_dec
   LOCAL _full_id := ""

   FOR EACH _field in dbf_key_fields

      IF ValType( _field ) == "A"
         _t_field := _field[ 1 ]
         _t_field_dec := _field[ 2 ]
         _full_id += Str( rec[ _t_field ], _t_field_dec )
      ELSE
         _t_field := _field
         IF ValType( rec[ _t_field ] ) == "D"
            _full_id += DToS( rec[ _t_field ] )
         ELSE
            _full_id += rec[ _t_field ]
         ENDIF
      ENDIF

   NEXT

   RETURN _full_id
