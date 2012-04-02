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
// update_rec_server_and_dbf( table, values, 1, "FULL") 
// -----------------------------------------------------------------------------------------------------------
function update_rec_server_and_dbf(table, values, algoritam, transaction)
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

// trbamo where str za values rec
set_table_values_algoritam_vars(@table, @values, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str, @_alg_tag)


_values_dbf := dbf_get_rec()
// trebmo where str za stanje dbf-a
set_table_values_algoritam_vars(@table, @_values_dbf, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str_dbf, @_alg_tag)

if transaction $ "FULL#BEGIN"
   sql_table_update(table, "BEGIN")
endif


// izbrisi sa servera stare vrijednosti za values
if !sql_table_update(table, "del", nil, _where_str)
 
   sql_table_update(table, "ROLLBACK")
   _msg := RECI_GDJE_SAM + "sql delete " + table +  " neuspjesno !"
   log_write(_msg)
   Alert(_msg)

   return .f.
endif

if _where_str_dbf != _where_str

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
        _msg := RECI_GDJE_SAM + "sql delete " + table +  " neuspjesno !"
        log_write(_msg)
        Alert(_msg)

        return .f.
    endif

endif

// dodaj nove
if !sql_table_update(table, "ins", values)
   sql_table_update(table, "ROLLBACK")

   _msg := RECI_GDJE_SAM + "sql ins " + table + " neuspjesno !"
   RaiseError(_msg)

   return .f.
endif

// pripremiti semaphore ids-ove

// stanje u dbf-u (_values_dbf)
_full_id_dbf := ""

// stanje podataka u mem rec varijabli values
_full_id_mem := ""

_full_id_dbf := get_dbf_rec_primary_key(_alg["dbf_key_fields"], _values_dbf)
_full_id_mem := get_dbf_rec_primary_key(_alg["dbf_key_fields"], values)


// stavi id-ove na server
AADD(_ids, _alg_tag + _full_id_mem)
if _full_id_dbf != _full_id_mem
  AADD(_ids, _alg_tag + _full_id_dbf)
endif

if !push_ids_to_semaphore(table, _ids)
     sql_table_update(table, "ROLLBACK")

    _msg := RECI_GDJE_SAM + "push_ids_to_semaphore " + table + "/ ids=" + _alg_tag + _ids  + " !"
    Alert(_msg)
    log_write(_msg)

    return .f.
endif

// azuriraj verziju semafora za tabelu
if update_semaphore_version(table, .t.) < 0
   sql_table_update(table, "ROLLBACK")

   _msg := RECI_GDJE_SAM + "update semaphore " + table +  " !"
   log_write(_msg)
   Alert(_msg)

   return .f.
endif


// na kraju, azuriraj lokalni dbf
if dbf_update_rec(values)
    if transaction $ "FULL#END"
       sql_table_update(table, "END")
    endif
 
    return .t.
else
    sql_table_update(table, "ROLLBACK")

    _msg := RECI_GDJE_SAM + "dbf_update_rec " + table +  " !"
    Alert(_msg)
    log_write(_msg)

    return .f.
endif

return .t.


// ----------------------------------------------------------------------
// algoritam = 1 - nivo zapisa, 2 - dokument ...
// ----------------------------------------------------------------------
function delete_rec_server_and_dbf(table, values, algoritam, transaction)
local _ids := {}
local _pos
local _full_id
local _dbf_pkey_search
local _field
local _where_str
local _t_field, _t_field_dec
local _a_dbf_rec, _alg
local _msg
local _alg_tag := ""


set_table_values_algoritam_vars(@table, @values, @algoritam, @transaction, @_a_dbf_rec, @_alg, @_where_str, @_alg_tag)

if transaction $ "FULL#BEGIN"
   sql_table_update(table, "BEGIN")
endif


if sql_table_update(table, "del", nil, _where_str) 

   
    _full_id := get_dbf_rec_primary_key(_alg["dbf_key_fields"], values)
    
    AADD(_ids, _alg_tag + _full_id)
    push_ids_to_semaphore( table, _ids )

    SELECT (_a_dbf_rec["alias"])
    SET ORDER TO TAG (_alg["dbf_tag"])

    if FLOCK()
        SEEK _full_id
        while FOUND()
            DELETE
            // sve dok budes nalazio pod ovim kljucem brisi
            SEEK _full_id
        enddo
    else
        sql_table_update(table, "ROLLBACK")

        _msg := table + "transakcija neuspjesna !"
         Alert(_msg)
        log_write(_msg)

        return .f.
    endif
    DBUNLOCKALL() 

    update_semaphore_version(table, .t.)

    if transaction $ "FULL#END"
       sql_table_update(table, "END")
    endif
    return .t.

endif

_msg := table + "transakcija neuspjesna !"
Alert(_msg)
log_write(_msg)

sql_table_update(table, "ROLLBACK")
return .f.



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

sql_table_update( table, "BEGIN" )

_rec := hb_hash()
_rec["id"] := NIL
// ostala polja su nevazna za brisanje


if sql_table_update( table, "del", _rec, "true")

   push_ids_to_semaphore( table, {"#F"} )

   update_semaphore_version( table, .t.)
   sql_table_update( table, "END")

   // zapujemo dbf
   ZAP

   return .t.

else

   _msg := table + "transakcija neuspjesna !"
    Alert(_msg)
   log_write(_msg)

   sql_table_update( table, "ROLLBACK")
   return .f.
endif

return .t.

// --------------------------------------------------------------------------------------------------------------
// inicijalizacija varijabli koje koriste update and delete_from_server_and_dbf  funkcije
// ---------------------------------------------------------------------------------------------------------------
static function set_table_values_algoritam_vars(table, values, algoritam, transaction, a_dbf_rec, alg, where_str, alg_tag)

if table == NIL
   table := ALIAS()
endif

if values == NIL
  values := dbf_get_rec()
endif

if algoritam == NIL
   algoritam = 1
endif

// nema zapoceta transakcija
if transaction == NIL
  // pocni i zavrsi trasakciju
  transaction := "FULL"
endif

a_dbf_rec := get_a_dbf_rec(table)

// ako je alias proslijedjen kao ulazni parametar, prebaci se na dbf_table
table := a_dbf_rec["table"]

alg := a_dbf_rec["algoritam"][algoritam]

BEGIN SEQUENCE with { |err| err:cargo := { "var",  "values", values }, GlobalErrorHandler( err ) }
   where_str := sql_where_from_dbf_key_fields(alg["dbf_key_fields"], values)
END SEQUENCE

if algoritam > 1
  alg_tag := "#" + ALLTRIM(STR(algoritam))
endif


return


