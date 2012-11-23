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
function ids_synchro(dbf_table)
local _i, _ids_queries
local _zap

_ids_queries := create_queries_from_ids(dbf_table)


//  _ids_queries["ids"] = {  {"00113333 1", "0011333 2"}, {"00224444"}  }
//  _ids_queries["qry"] = {  "select .... in ... rpad('0011333  1') ...", "select .. in ... rpad("0022444")" }

log_write( "START ids_synchro", 9 )

log_write( "ids_synchro ids_queries: " + pp(_ids_queries), 7 )

do while .t.

  // ovo je posebni query koji se pojavi ako se nadje ids '#F'
  _zap := ASCAN(_ids_queries["qry"], "UZMI_STANJE_SA_SERVERA")

  if _zap <> 0

   // postoji zahtjev za full synchro
   full_synchro(dbf_table, 50000, .f.)   

   // otvoricu tabelu ponovo ... ekskluzivno, ne bi to trebalo biti problem
   reopen_shared(dbf_table, .t.)

   ADEL(_zap, _ids_queries["qry"])

   // ponovo kreiraj _ids_queries u slucaju da je bilo jos azuriranja
   _ids_queries := create_queries_from_ids(dbf_table)
  
  else
     exit
  endif

enddo

for _i := 1 TO LEN(_ids_queries["ids"])

    log_write( "ids_synchro ids_queries/2: " + pp( _ids_queries["ids"][_i]  ), 9 )
    // ako nema id-ova po algoritmu _i, onda je NIL ova varijabla
    if _ids_queries["ids"][_i] != NIL

        // pobrisi u dbf-u id-ove koji su u semaforu tabele
        delete_ids_in_dbf( dbf_table, _ids_queries["ids"][_i], _i)

        // dodaj sa servera
        fill_dbf_from_server( dbf_table, _ids_queries["qry"][_i])

    endif
next


log_write( "END ids_synchro", 9 )

return .t.

//-------------------------------------------------
// stavi id-ove za dbf tabelu na server
//-------------------------------------------------
function push_ids_to_semaphore( table, ids )
local _tbl
local _result
local _user := f18_user()
local _ret
local _qry
local _sql_ids
local _i
local _set_1, _set_2
LOCAL _server := pg_server()

if LEN(ids) < 1
   return .f.
endif

log_write( "START push_ids_to_semaphore", 9 )
log_write( "push ids: " + table + " / " + pp(ids), 5 )

_tbl := "fmk.semaphores_" + LOWER(table)

// treba dodati id za sve DRUGE korisnike
_result := table_count(_tbl, "user_code <> " + _sql_quote(_user)) 

if _result < 1
    // jedan korisnik
    log_write( "push_ids_to_semaphore(), samo je jedan korsnik, nista nije pushirano", 9 )
    return .t.
endif

_qry := ""    

for _i := 1 TO LEN(ids)

    _sql_ids := "ARRAY[" + _sql_quote(ids[_i]) + "]"

    // full synchro
    if ids[_i] == "#F"
            // svi raniji id-ovi su nebitni
            // brisemo kompletnu tabelu - radimo full synchro
            _set_1 := "set ids = "
            _set_2 := ""
    else
            // dodajemo postojece
            _set_1 := "SET ids = ids || "
            _set_2 := " AND ((ids IS NULL) OR NOT ( (" + _sql_ids + " <@ ids) OR ids = ARRAY['#F'] ) )"
    endif

    _qry += "UPDATE " + _tbl + " " + _set_1 + _sql_ids + " WHERE user_code <> " + _sql_quote(_user) + _set_2 + ";"

next

// ako id sadrzi vise od 1000 stavki, korisnik je dugo neaktivan, pokreni full sync
_qry += "UPDATE " + _tbl + " SET ids = ARRAY['#F']  WHERE user_code <> " + _sql_quote(_user) + " AND ids IS NOT NULL AND array_length(ids,1) > 1000"
_ret := _sql_query( _server, _qry )

// ova komanda svakako treba da ide u log, jer je to kljucna stvar kod otklanjanja kvarova
//log_write( "tabela: " + _tbl + ", ids: " + _sql_ids + ", user: " + _user, 3 )

log_write( "END push_ids_to_semaphore", 9 )

// na kraju uradi update verzije semafora, push operacija
update_semaphore_version_after_push(table)

if VALTYPE(_ret) == "O"
    return .t.
else
    return .f.
endif



//---------------------------------------
// vrati matricu id-ova za dbf tabelu
//---------------------------------------
function get_ids_from_semaphore( table )
local _tbl
local _tbl_obj, _update_obj
local _qry
local _ids, _num_arr, _arr, _i
local _server := pg_server()
local _user := f18_user()
local _tok, _versions, _tmp
local _log_level := log_level()

log_write( "START get_ids_from_semaphore", 7)

_tbl := "fmk.semaphores_" + LOWER(table)

run_sql_query("BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")
//sql_table_update(nil, "BEGIN")

if _log_level > 6

    // uzmi verziju i stanje iz semafora prije pocetka
    _versions := get_semaphore_version_h( LOWER(table) )

    _tmp := "prije SELECT, tabela: " + LOWER(table)  
    _tmp += " version: " + ALLTRIM( STR( _versions["version"] ) )
    _tmp += " last version: " + ALLTRIM( STR( _versions["last_version"] ) )

    log_write( _tmp  , 7 )

endif

_qry := "SELECT ids FROM " + _tbl + " WHERE user_code=" + _sql_quote(_user)
_tbl_obj := _sql_query( _server, _qry )


_qry := "UPDATE " + _tbl + " SET  ids=NULL , dat=NULL, version=last_trans_version"
_qry += " WHERE user_code =" + _sql_quote(_user) 
_update_obj := _sql_query( _server, _qry )


IF (_tbl_obj == NIL) .or. (_update_obj == NIL)
      MsgBeep( "problem sa:" + _qry)
      sql_table_update(nill, "ROLLBACK")
      QUIT
ENDIF

if _log_level > 6

    // uzmi verziju i stanje verzija na kraju transakcije
    _versions := get_semaphore_version_h( LOWER(table) )

    _tmp := "nakon UPDATE, tabela: " + LOWER( table )
    _tmp += " version: " + ALLTRIM( STR( _versions["version"] ) )
    _tmp += " last version: " + ALLTRIM( STR( _versions["last_version"] ) )

    log_write( _tmp  , 7 )

endif

sql_table_update(nil, "END")

_ids := _tbl_obj:Fieldget(1)

_arr := {}
if _ids == NIL
    return _arr
endif

_ids := hb_Utf8ToStr(_ids)

// {id1,id2,id3}
_ids := SUBSTR(_ids, 2, LEN(_ids)-2)

_num_arr := numtoken(_ids, ",")

for _i := 1 to _num_arr
   _tok := token(_ids, ",", _i)
   if LEFT(_tok, 1) == '"' .and. RIGHT(_tok, 1) == '"'
     // odsjeci duple navodnike "..."
     _tok := SUBSTR(_tok, 2, LEN(_tok) -2)
   endif
   AADD(_arr, _tok)
next

log_write( "END get_ids_from_semaphore", 7)

RETURN _arr



// ---------------------------------------------------------------------------------------------------------
// napraviti array qry, za sve dostupne ids algoritme
//
//  ret["qry"] := { "select .... where .. uslov za podsifra ..", "select ... where ... uslov za sifra .." }
//  ret["ids"] := { "01/1", "01/2" }, {"03", "04"}
//
//  u gornjem primjeru imamo dva algoritma i dva seta ids-ova - prvi na nivou sifra/podsifra ("01/1", "01/2")
//  a drugi na nivou sifre "01", "04"
//
//  algoritmi se nalaze u hash varijabli koju nam vraca funkcija f18_dbfs()
//  set_a_dbf... funkcije definišu tu hash varijablu
//
// ova util funkcija daje nam id-ove i sql queries potrebne da 
// sinhroniziramo dbf sa promjenama koje su napravili drugi korisnici
// -------------------------------------------------------------------------------------------------------------
function create_queries_from_ids(table)
local _a_dbf_rec, _msg
local _qry_1, _qry_2
local _queries     := {}
local _ids, _ids_2 := {}
local _sql_ids := {}
local _i, _id
local _ret := hb_hash()
local _sql_fields
local _algoritam, _alg

_a_dbf_rec := get_a_dbf_rec(table)

_sql_fields := sql_fields(_a_dbf_rec["dbf_fields"])
_alg := _a_dbf_rec["algoritam"]

_sql_tbl := "fmk." + table

for _i := 1 to LEN(_alg)
    AADD(_queries, "SELECT " + _sql_fields + " FROM " + _sql_tbl + " WHERE ")
    AADD(_sql_ids, NIL)
    AADD(_ids_2, NIL)
next

_ids := get_ids_from_semaphore( table )
nuliraj_ids_and_update_my_semaphore_ver(table)


log_write("create_queries..(), poceo", 9 )

// primjer
// suban 00-11-2222 rbr 1, rbr 2 
// kompletan nalog (#2) 00-11-3333
// Full synchro (#F)
// _ids := { "00112222 1", "00112222 2", "#200113333", "#F" }

for each _id in _ids

    if LEFT(_id, 1) == "#"

        if SUBSTR(_id, 2, 1) == "F"
            // full sinchro
            _algoritam := 99
            _id := "X"
        else
            // algoritam "#2" => algoritam 2
            _algoritam := VAL(SUBSTR( _id, 2, 1))
            _id := SUBSTR(_id, 3)
        endif

    else
        _algoritam := 1
    endif

    if _algoritam == 99
        // full sync zahtjev
        AADD(_queries, "UZMI_STANJE_SA_SERVERA")
        AADD(_sql_ids, NIL)
    else
        // ne moze biti "#3" a da tabela ima definisana samo dva algoritma
        if _algoritam > LEN(_alg)
            _msg := "nasao sam ids " + _id + ". Ovaj algoritam nije podrzan za " + table
            Alert(_msg)
            log_write( "create_queries..(), " + _msg, 5 )
            RaiseError(_msg)
            QUIT
        endif

        if _sql_ids[_algoritam] == NIL
            _sql_ids[_algoritam] := "("
            _ids_2[_algoritam] := {}
        endif

        _sql_ids[_algoritam] += _sql_quote(_id) + ","
        AADD(_ids_2[_algoritam], _id)

     endif 
next

for _i := 1 to LEN(_alg)

    if _sql_ids[_i] != NIL
        // odsjeci zarez na kraju
        _sql_ids[_i] := LEFT(_sql_ids[_i], LEN(_sql_ids[_i]) - 1)
        _sql_ids[_i] += ")"
        _queries[_i] +=  "(" + _alg[_i]["sql_in"]  + ") IN " + _sql_ids[_i]
    else
        _queries[_i] := NIL
    endif

next

log_write("create_queries..(), ret[qry]=" + pp(_queries), 9 )
log_write("create_queries..(), ret[ids]=" + pp(_ids_2), 9 )
log_write("create_queries..(), zavrsio", 9 )
_ret["qry"] := _queries
_ret["ids"] := _ids_2

return _ret




// ------------------------------------------------------
// sve ids-ove pobrisi iz dbf-a
// ids       := {"#20011", "#2012"}
// algoritam := 2
// ------------------------------------------------------
function delete_ids_in_dbf(dbf_table, ids, algoritam)
local _a_dbf_rec, _alg
local _counter, _msg
local _fnd, _tmp_id, _rec
local _dbf_alias
local _dbf_tag
local _key_block
local _i

log_write( "delete_ids_in_dbf(), poceo", 9 )

_a_dbf_rec := get_a_dbf_rec(dbf_table)
_alg := _a_dbf_rec["algoritam"]

_dbf_alias := _a_dbf_rec["alias"]
_dbf_tag := _alg[algoritam]["dbf_tag"]

_key_block := _alg[algoritam]["dbf_key_block"]

// pobrisimo sve dbf zapise na kojima su drugi radili
SET ORDER TO TAG (_dbf_tag)

_counter := 0

if VALTYPE(ids) != "A"
    Alert("ids type ? " + VALTYPE(ids))
endif

do while .t.
    
    _fnd := .f.
    
    for each _tmp_id in ids
        
        HSEEK _tmp_id
        
        do while !EOF() .and. EVAL(_key_block) == _tmp_id

            _msg := ToStr(Time()) + " : sync del : " + dbf_table + " : " + _tmp_id
            @ maxrows() - 1, maxcols() - 70 SAY PADR( _msg, 53 )
 
            skip
            _rec := RECNO()
            skip -1 
            delete_with_rlock()            
            go _rec
 
            _fnd := .t.
            ++ _counter
 
       enddo
    next

    if !_fnd 
        exit 
    endif
enddo

log_write( "delete_ids_in_dbf(), table: " + dbf_table + "/ dbf_tag =" + _dbf_tag + " pobrisao iz lokalnog dbf-a zapisa = " + ALLTRIM(STR( _counter )), 5 )

log_write( "delete_ids_in_dbf(), zavrsio", 9 )

return


// ----------------------------------------------------------
// util funkcija za ids algoritam kreira dbf kljuc potreban
// za brisanje zapisa koje su drugi mijenjali
// 
// dbf_fields - {"id", {"iznos", 12, 2} }
// rec - { "01", 15.5 }
//
// => "01       15.50"
// ----------------------------------------------------------
function get_dbf_rec_primary_key(dbf_key_fields, rec)
local _field, _t_field, _t_field_dec
local _full_id := ""

for each _field in dbf_key_fields

    if VALTYPE( _field ) == "A"    
        _t_field := _field[1]
        _t_field_dec := _field[2]
        _full_id += STR( rec[ _t_field ], _t_field_dec )
    else
        _t_field := _field
        if VALTYPE( rec[ _t_field ] ) == "D"
            _full_id += DTOS( rec[ _t_field ] )
        else
            _full_id += rec[ _t_field ]
        endif
    endif

next

return _full_id



