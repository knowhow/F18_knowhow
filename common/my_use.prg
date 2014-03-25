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

#include "fmk.ch"
#include "common.ch"


THREAD STATIC __my_use_semaphore := .T.

// --------------------------------------
// iskljuci logiku provjere semafora
// neophodno u procedurama azuriranja
//
// if azur_sql()
// my_use_semaphore_off()
// otvori_dbfs()
// azur_dbf()
// my_use_semaphore_on()
// endif
//
// --------------------------------------
FUNCTION my_use_semaphore_off()

   __my_use_semaphore := .F.
   log_write( "stanje semafora : OFF", 6 )

   RETURN

FUNCTION my_use_semaphore_on()

   __my_use_semaphore := .T.
   log_write( "stanje semafora : ON", 6 )

   RETURN

FUNCTION my_use_semaphore()
   RETURN __my_use_semaphore



// --------------------------------------------------------------
// --------------------------------------------------------------
FUNCTION my_usex( alias, table, new_area, _rdd, semaphore_param )
   RETURN my_use( alias, table, new_area, _rdd, semaphore_param, .T. )


// ---------------------------------------------------------------
// uopste ne koristi logiku semafora, koristiti za temp tabele
// kod opcija exporta importa
// ---------------------------------------------------------------
FUNCTION my_use_temp( alias, table, new_area, excl )

   LOCAL _force_erase
   LOCAL _err

   IF excl == NIL
      excl := .T.
   ENDIF

   IF new_area == NIL
      new_area := .F.
   ENDIF


   IF Used()
      USE
   ENDIF

   BEGIN SEQUENCE WITH {|err| err:cargo := { ProcName( 1 ), ProcName( 2 ), ProcLine( 1 ), ProcLine( 2 ) }, Break( err ) }

      dbUseArea( new_area, DBFENGINE, table, alias, !excl, .F. )
      IF File( ImeDbfCdx( table ) )
         dbSetIndex( ImeDbfCDX( table ) )
      ENDIF

   recover using _err

      _msg := "ERR-MYUTMP: " + _err:description + ": tbl:" + table + " alias:" + alias + " se ne moze otvoriti ?!"
      Alert( _msg )
      log_write( _msg, 2 )

      IF _err:description == "Read error"
         _force_erase := .T.
      ENDIF

      // ovo trazi a_dbf_rec definisan za tabelu pa iskljucujem
      // ferase_dbf(alias, _force_erase)

      RaiseError( _msg )
      QUIT_1

   END SEQUENCE

   RETURN

// ----------------------------------------------------------------
// semaphore_param se prosjedjuje eval funkciji ..from_sql_server
// ----------------------------------------------------------------
FUNCTION my_use( alias, table, new_area, _rdd, semaphore_param, excl, select_wa )

   LOCAL _msg
   LOCAL _err
   LOCAL _pos
   LOCAL _version, _last_version
   LOCAL _area
   LOCAL _force_erase := .F.
   LOCAL _dbf
   LOCAL _tmp
   LOCAL _lock

   IF excl == NIL
      excl := .F.
   ENDIF

   IF select_wa == NIL
      select_wa = .F.
   ENDIF

   IF table == NIL
      _tmp := alias
   ELSE
      // uvijek atribute utvrdjujemo prema table atributu
      _tmp := table
   ENDIF

   // trebam samo osnovne parametre
   _a_dbf_rec := get_a_dbf_rec( _tmp, .T. )


   IF new_area == NIL
      new_area := .F.
   ENDIF

   // pozicioniraj se na WA rezervisanu za ovu tabelu
   IF select_wa
      SELECT ( _a_dbf_rec[ "wa" ] )
   ENDIF


   IF ( alias == NIL ) .OR. ( table == NIL )
      // za specificne primjene kada "varamo" sa aliasom
      // my_use("fakt_pripr", "fakt_fakt")
      // tada ne diramo alias
      alias := _a_dbf_rec[ "alias" ]
   ENDIF

   table := _a_dbf_rec[ "table" ]

   IF ValType( table ) != "C"
      _msg := ProcName( 2 ) + "(" + AllTrim( Str( ProcLine( 2 ) ) ) + ") table name VALTYPE = " + ValType( type )
      Alert( _msg )
      log_write( _msg, 5 )
      QUIT_1
   ENDIF


   IF _rdd == NIL
      _rdd = DBFENGINE
   ENDIF

   IF !( _a_dbf_rec[ "temp" ] )

      _lock := F18_DB_LOCK():New()
      IF ( _rdd != "SEMAPHORE" ) .AND. ;
            ( !_lock:is_locked() .OR. ( _lock:is_locked() .AND. _lock:run_synchro() ) ) .AND. my_use_semaphore()
         dbf_semaphore_synchro( table )
      ELSE
         // rdd = "SEMAPHORE" poziv is update from sql server procedure
         // samo otvori tabelu
         log_write( "my_use table:" + table + " / rdd: " +  _rdd + " alias: " + alias + " exclusive: " + hb_ValToStr( excl ) + " new: " + hb_ValToStr( new_area ), 8 )
         _rdd := DBFENGINE
      ENDIF

   ENDIF

   IF Used()
      USE
   ENDIF

   // nije nikada uradjena inicijalna kontrola ove tabele
   IF !_a_dbf_rec[ "chk0" ] .AND. my_use_semaphore() .and. !_a_dbf_rec[ "temp" ]
      refresh_me( _a_dbf_rec, .T., .T. )
   ENDIF

   _dbf := my_home() + table

   BEGIN SEQUENCE WITH {|err| err:cargo := { ProcName( 1 ), ProcName( 2 ), ProcLine( 1 ), ProcLine( 2 ) }, Break( err ) }
      dbUseArea( new_area, _rdd, _dbf, alias, !excl, .F. )
      IF File( ImeDbfCdx( _dbf ) )
         dbSetIndex( ImeDbfCDX( _dbf ) )
      ENDIF

   recover using _err

      _msg := "ERR-MYUSE: " + _err:description + ": tbl:" + my_home() + table + " alias:" + alias + " se ne moze otvoriti ?!"
      log_write( _msg, 2 )
      Alert( _msg )

      IF _err:description == "Read error"
         _force_erase := .T.
      ENDIF

      ferase_dbf( alias, _force_erase )

      repair_dbfs()
      QUIT_1

   END SEQUENCE

   RETURN

// -----------------------------------------------------
// -----------------------------------------------------
FUNCTION dbf_semaphore_synchro( table )

   LOCAL _version, _last_version

   log_write( "START dbf_semaphore_synchro", 9 )

   // uzmimo od tabele stanje svog semafora
   _version :=  get_semaphore_version( table )

   DO WHILE .T.

      IF ( _version == -1 )
         log_write( "full synchro version semaphore version -1", 7 )
         // odradi full sinhro i setuj vesion = last_trans_version
         update_dbf_from_server( table, "FULL" )
      ELSE

         _last_version := last_semaphore_version( table )
         // moramo osvjeziti cache
         IF ( _version < _last_version )
            log_write( "dbf_semaphore_synchro/1, my_use" + table + " osvjeziti dbf cache: ver: " + AllTrim( Str( _version, 10 ) ) + " last_ver: " + AllTrim( Str( _last_version, 10 ) ), 5 )
            update_dbf_from_server( table, "IDS" )
         ENDIF
      ENDIF

      // posljednja provjera ... mozda je neko
      // u medjuvremenu mjenjao semafor
      _last_version := last_semaphore_version( table )
      _version      := get_semaphore_version( table )

      IF _version >= _last_version
         EXIT
      ENDIF

      log_write( "dbf_semaphore_synchro/2, _last_version: " + Str( _last_version ) + " _version: " + Str( _version ), 5 )

   ENDDO

   log_write( "END dbf_semaphore_synchro", 9 )

   RETURN .T.
