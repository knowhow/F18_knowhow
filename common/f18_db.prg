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

#include "fmk.ch"


// ----------------------------------------------------------------------------------------------------------
// update podataka za jedan dbf zapis na serveru
//
// mijenja zapis na serveru, pa ako je sve ok onda uradi update dbf-a 
//
// update_rec_server_and_dbf( table, values, 1, "FULL") - zapocni/zavrsi transakciju unutar funkcije 
// -----------------------------------------------------------------------------------------------------------
function update_rec_server_and_dbf( table, values, algoritam, transaction, lock )
local _ids := {}
local _pos
local _full_id_dbf, _full_id_mem
local _dbf_pkey_search
local _field
local _where_str, _where_str_dbf
local _t_field, _t_field_dec
local _a_dbf_rec, _alg
local _msg
local _values_dbf
local _alg_tag := ""
local _ret

_ret := .t.

if lock == NIL
  if transaction == "FULL" 
     my_use_semaphore_off()
     lock := .t.
  else
     lock := .f.
  endif
endif

// trebamo where str za values rec
set_table_values_algoritam_vars(@table, @values, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str, @_alg_tag)

if ALIAS() <> _a_dbf_rec["alias"]
    _msg := "ERR "  + RECI_GDJE_SAM0 + " ALIAS() = " + ALIAS() + " <> " + _a_dbf_rec["alias"]
    log_write( _msg, 2 )
    Alert(_msg)
    QUIT_1
endif

log_write( "START: update_rec_server_and_dbf " + table, 9 )

_values_dbf := dbf_get_rec()

// trebamo where str za stanje dbf-a
set_table_values_algoritam_vars(@table, @_values_dbf, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str_dbf, @_alg_tag)

if lock
    lock_semaphore(table, "lock")
endif

if transaction $ "FULL#BEGIN"
    sql_table_update(table, "BEGIN")
endif


// izbrisi sa servera stare vrijednosti za values
if !sql_table_update(table, "del", nil, _where_str)

    sql_table_update(table, "ROLLBACK")
    _msg := "ERROR: sql delete " + table +  " , ROLLBACK, where: " + _where_str
    log_write( _msg, 1 )
    Alert(_msg)

    _ret := .f.
endif

if _ret .and.  (_where_str_dbf != _where_str)

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
    if !sql_table_update(table, "del", nil, _where_str_dbf)

        sql_table_update(table, "ROLLBACK")
        _msg := "ERROR: sql delete " + table +  " , ROLLBACK, where: " + _where_str_dbf
        log_write( _msg, 1 )
        Alert(_msg)

        return .f.
    endif

endif

// dodaj nove
if _ret .and. !sql_table_update(table, "ins", values)
    sql_table_update(table, "ROLLBACK")
    _msg := RECI_GDJE_SAM + "ERRORY: sql_insert: " + table + " , ROLLBACK values: " + pp( values )
    log_write( _msg, 1 )
    RaiseError(_msg)
    return .f.
endif

// stanje u dbf-u (_values_dbf)
_full_id_dbf := get_dbf_rec_primary_key(_alg["dbf_key_fields"], _values_dbf)
// stanje podataka u mem rec varijabli values
_full_id_mem := get_dbf_rec_primary_key(_alg["dbf_key_fields"], values)

// stavi id-ove na server
AADD(_ids, _alg_tag + _full_id_mem)
if ( _full_id_dbf <> _full_id_mem ) .and. !EMPTY( _full_id_dbf )
    AADD(_ids, _alg_tag + _full_id_dbf)
endif

if !push_ids_to_semaphore(table, _ids)
    sql_table_update(table, "ROLLBACK")
    _msg := "ERR " + RECI_GDJE_SAM0 + "push_ids_to_semaphore " + table + "/ ids=" + _alg_tag + _ids  + " ! ROLLBACK"
    log_write( _msg, 1 )
    Alert( _msg )
    _ret := .f.
endif

if _ret
    // na kraju, azuriraj lokalni dbf
    if  dbf_update_rec(values)
        if transaction $ "FULL#END"
            sql_table_update(table, "END")
        endif

        _ret := .t. 
    else
        sql_table_update(table, "ROLLBACK")
        _msg := "ERR: " + RECI_GDJE_SAM0 + "dbf_update_rec " + table +  " ! ROLLBACK"
        log_write( _msg, 1 )
        Alert(_msg)
        _ret := .f.
    endif
endif

if lock
    lock_semaphore(table, "free")
    my_use_semaphore_on()
endif

log_write( "END update_rec_server_and_dbf " + table, 9 )

return _ret


// ----------------------------------------------------------------------
// algoritam = 1 - nivo zapisa, 2 - dokument ...
// ----------------------------------------------------------------------
function delete_rec_server_and_dbf(table, values, algoritam, transaction, lock)
local _ids := {}
local _pos
local _full_id
local _dbf_pkey_search
local _field, _count
local _where_str
local _t_field, _t_field_dec
local _a_dbf_rec, _alg
local _msg
local _alg_tag := ""
local _ret
local lIndex := .T.

if lock == NIL
  if transaction == "FULL"
     my_use_semaphore_off() 
     lock := .t.
  else
     lock := .f.
  endif
endif

_ret := .t.

set_table_values_algoritam_vars(@table, @values, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str, @_alg_tag)

if ALIAS() <> _a_dbf_rec["alias"]
   _msg := "ERR "  + RECI_GDJE_SAM0 + " ALIAS() = " + ALIAS() + " <> " + _a_dbf_rec["alias"]
   log_write( _msg, 1 )
   Alert(_msg)
   RaiseError(_msg) 
   QUIT_1
endif

log_write( "delete rec server, poceo", 9 )

if lock
    lock_semaphore(table, "lock")
endif

if transaction $ "FULL#BEGIN"
    sql_table_update(table, "BEGIN")
endif

if sql_table_update(table, "del", nil, _where_str) 

    _full_id := get_dbf_rec_primary_key(_alg["dbf_key_fields"], values)
    
    AADD(_ids, _alg_tag + _full_id)
    push_ids_to_semaphore( table, _ids )

    SELECT (_a_dbf_rec["wa"])
    
    if index_tag_num(_alg["dbf_tag"]) < 1
          if !_a_dbf_rec["sql"] 
             _msg := "ERR : " + RECI_GDJE_SAM0 + " DBF_TAG " + _alg["dbf_tag"]
             Alert(_msg)
             log_write( _msg, 1 )
             RaiseError(_msg)
             lock_semaphore(table, "free")
             QUIT_1
          else
             lIndex := .F.
          endif
    else
          lIndex := .T.
          SET ORDER TO TAG (_alg["dbf_tag"])
    endif

    if my_flock()
        
        _count := 0

        IF lIndex
           SEEK _full_id

           while FOUND()
              ++ _count
              DELETE
              // sve dok budes nalazio pod ovim kljucem brisi
              SEEK _full_id
           enddo
        else
          IF ALIAS() != "SIFV"
            DELETE
          ENDIF
        endif

        my_unlock()

        log_write( "table: " + table + ", pobrisano iz lokalnog dbf-a broj zapisa = " + ALLTRIM( STR( _count ) ), 7 ) 

        if transaction $ "FULL#END"
            sql_table_update(table, "END")
        endif

        _ret := .t.

    else

        sql_table_update( table, "ROLLBACK" )

        _msg := "delete rec server " + table + " nije lockovana !!! ROLLBACK"
        log_write( _msg, 1 )
        Alert(_msg)

        _ret := .f.
    endif

else

   _msg := "delete rec server, " + table + " transakcija neuspjesna ! ROLLBACK"
   Alert(_msg)
   log_write(_msg, 1)

   sql_table_update(table, "ROLLBACK")

   _ret :=.f.

endif

if lock
    lock_semaphore(table, "free")
    my_use_semaphore_on()
endif

log_write( "delete rec server, zavrsio", 9 )

return _ret



// ---------------------------------------
// --------------------------------------
function delete_all_dbf_and_server(table)
local _ids := {}
local _pos
local _field
local _where_str
local _a_dbf_rec
local _msg
local _rec

_a_dbf_rec := get_a_dbf_rec(table)
reopen_exclusive(_a_dbf_rec["table"])

lock_semaphore(table, "lock")
sql_table_update( table, "BEGIN" )

_rec := hb_hash()
_rec["id"] := NIL
// ostala polja su nevazna za brisanje


if sql_table_update( table, "del", _rec, "true")

   push_ids_to_semaphore( table, {"#F"} )

   sql_table_update( table, "END")

   // zapujemo dbf
   my_dbf_zap()

   return .t.

else

   _msg := table + "transakcija neuspjesna ! ROLLBACK"
    Alert(_msg)
   log_write(_msg, 1 )

   sql_table_update( table, "ROLLBACK")
   return .f.

endif

lock_semaphore(_tbl_suban, "free")
return .t.


// --------------------------------------------------------------------------------------------------------------
// inicijalizacija varijabli koje koriste update and delete_from_server_and_dbf  funkcije
// ---------------------------------------------------------------------------------------------------------------
static function set_table_values_algoritam_vars(table, values, algoritam, transaction, a_dbf_rec, alg, where_str, alg_tag)
local _key
local _count := 0
local _use_tag := .f.
local _alias
local lSqlTable

if table == NIL
   table := ALIAS()
endif

a_dbf_rec := get_a_dbf_rec(table)

// ako je alias proslijedjen kao ulazni parametar, prebaci se na dbf_table
table := a_dbf_rec["table"]


if values == NIL
  _alias := ALIAS()
  values := dbf_get_rec()

  if (a_dbf_rec["alias"] != _alias)
     RaiseError("values matrica razlicita od tabele ALIAS():" + _alias + " table=" + table)
  endif

endif

if algoritam == NIL
   algoritam = 1
endif

// nema zapoceta transakcija
if transaction == NIL
   // pocni i zavrsi trasakciju
   transaction := "FULL"
endif


alg := a_dbf_rec["algoritam"][algoritam]
lSqlTable := a_dbf_rec[ "sql" ]

for each _key in alg["dbf_key_fields"]

    ++ _count
    if VALTYPE(_key) == "C"

        // ne gledaj numericke kljuceve, koji su array stavke
        if !HB_HHASKEY(values, _key)
             _msg := RECI_GDJE_SAM + "# tabela:" + table + "#bug - nepostojeci kljuc:" + _key +  "#values:" + pp(values)
             log_write(_msg, 1)
             MsgBeep(_msg)
             QUIT_1
        endif

        if VALTYPE(values[_key]) == "C"
            // ako je dbf_fields_len['id'][2] = 6
            // karakterna polja se moraju PADR-ovati
            // values['id'] = '0' => '0     '
            set_rec_from_dbstruct(@a_dbf_rec)
            values[_key] := PADR(values[_key], a_dbf_rec["dbf_fields_len"][_key][2])
            // provjeri prvi dio kljuca
            // ako je # onda obavezno setuj tag
            if _count == 1
                if PADR( values[_key], 1 ) == "#"
                    _use_tag := .t.
                endif
            endif    

        endif

   endif

next

BEGIN SEQUENCE with { |err| err:cargo := { "var",  "values", values }, GlobalErrorHandler( err ) }
   where_str := sql_where_from_dbf_key_fields(alg["dbf_key_fields"], values, lSqlTable )
END SEQUENCE

if algoritam > 1 .or. _use_tag == .t.
  alg_tag := "#" + ALLTRIM(STR(algoritam))
endif

return


