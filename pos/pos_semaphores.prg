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


#include "pos.ch"
#include "common.ch"




// ------------------------------
// koristi azur_sql
// ------------------------------
function pos_pos_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "idpos, idvd, datum, brdok"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.pos_pos"

if algoritam == NIL
    algoritam := "FULL"
endif

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_POS
my_usex ("pos", "pos_pos", .f., "SEMAPHORE")

_fields := { "brdok", "cijena", "datum", "idcijena", "iddio", "idodj", "idpos", "idradnik", "idroba", "idtarifa", "idvd", "kol2", "kolicina", ;
            "m1", "mu_i", "ncijena", "prebacen", "smjena", "c_1", "c_2", "c_3" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("pos_pos")
    _qry += " WHERE datdok >= " + _sql_quote(_dat)
    _key_block := {|| field->datum }
  endif

  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("pos_pos")
        _qry += " WHERE "
        if LEN(_ids) < 1
            // nema id-ova
            _qry += "false"
        else
            _sql_ids := "("
            for _i := 1 to LEN(_ids)
                _sql_ids += _sql_quote(_ids[_i])
                if _i < LEN(_ids)
                    _sql_ids += ","
                endif
            next
            _sql_ids += ")"
            _qry += " ( rpad( idpos, 2, ' ' ) || rpad( idvd, 2, ' ' ) || datum::char(8) || rpad( brdok, 6, ' ' ) ) IN " + _sql_ids
        endif

        _key_block := {|| field->idpos + field->idvd + DTOS(datum) + field->brdok  } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset==0)
        log_write( _tbl + " : synchro full algoritam") 
        ZAP

    CASE algoritam == "DATE"

        log_write("datdok <> nil date algoritam") 
        // "date" algoritam  - brisi sve vece od zadanog datuma
        SET ORDER TO TAG "6"
        // tag je "DatDok" nije DTOS(DatDok)
        seek _dat
        do while !eof() .and. eval(_key_block)  >= _dat 
            // otidji korak naprijed
            SKIP
            _rec := RECNO()
            SKIP -1
            DELETE
            GO _rec  
        enddo

    CASE algoritam == "IDS"
        
        SET ORDER TO TAG "1"

        _counter := 0

        do while .t.
            _fnd := .f.
            for each _tmp_id in _ids
                
                HSEEK _tmp_id
                
                do while !EOF() .and. EVAL(_key_block) == _tmp_id
                    skip
                    _rec := RECNO()
                    skip -1 
                    DELETE
                    go _rec 
                    _fnd := .t.
                    ++ _counter
                enddo
            next
            if ! _fnd 
                exit
            endif
        enddo

        log_write( "pos_pos local dbf, deleted rec: " + ALLTRIM(STR( _counter )) )

  ENDCASE

  // sada je sve izbrisano u lokalnom dbf-u

  log_write( "pos_pos update, db qry: " + _qry )
  _qry_obj := run_sql_query( _qry, _retry )
  _counter := 0

  DO WHILE !_qry_obj:Eof()
    
    append blank
        
    for _i := 1 to LEN(_fields)
          _fld := FIELDBLOCK(_fields[_i])
          if VALTYPE(EVAL(_fld)) $ "CM"
              EVAL(_fld, hb_Utf8ToStr(_qry_obj:FieldGet(_i)))
          else
              EVAL(_fld, _qry_obj:FieldGet(_i))
          endif
    next

    _qry_obj:Skip()
    ++ _counter

  ENDDO

  log_write( "pos_pos update db rec: " + ALLTRIM( STR( _counter ) ) )

next

USE

return .t. 




// ------------------------------
// koristi azur_sql
// ------------------------------
function pos_doks_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "idpos, idvd, datum, brdok"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.pos_doks"

if algoritam == NIL
    algoritam := "FULL"
endif

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_POS_DOKS
my_usex ("pos_doks", "pos_doks", .f., "SEMAPHORE")

_fields := { "brdok", "datum", "idgost", "idpos", "idradnik", "idvd", "idvrstep", "m1", "placen", "prebacen", "smjena", "sto", "vrijeme", ;
            "sto_br", "zak_br", "fisc_rn", "c_1", "c_2", "c_3" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("pos_doks")
    _qry += " WHERE datdok >= " + _sql_quote(_dat)
    _key_block := {|| field->datum }
  endif

  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("pos_doks")
        _qry += " WHERE "
        if LEN(_ids) < 1
            // nema id-ova
            _qry += "false"
        else
            _sql_ids := "("
            for _i := 1 to LEN(_ids)
                _sql_ids += _sql_quote(_ids[_i])
                if _i < LEN(_ids)
                    _sql_ids += ","
                endif
            next
            _sql_ids += ")"
            _qry += " ( rpad( idpos, 2, ' ' ) || rpad( idvd, 2, ' ' ) || datum::char(8) || rpad( brdok, 6, ' ' ) ) IN " + _sql_ids
        endif

        _key_block := {|| field->idpos + field->idvd + DTOS( field->datum) + field->brdok } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset==0)
        log_write( _tbl + " : synchro full algoritam") 
        ZAP

    CASE algoritam == "DATE"

        log_write("datdok <> nil date algoritam") 
        // "date" algoritam  - brisi sve vece od zadanog datuma
        SET ORDER TO TAG "6"
        // tag je "DatDok" nije DTOS(DatDok)
        seek _dat
        do while !eof() .and. eval(_key_block)  >= _dat 
            // otidji korak naprijed
            SKIP
            _rec := RECNO()
            SKIP -1
            DELETE
            GO _rec  
        enddo

    CASE algoritam == "IDS"
        
        // "1", "IdPos+IdVd+DTOS(datum)+BrDok"

        SET ORDER TO TAG "1"

        _counter := 0

        do while .t.
            _fnd := .f.
            for each _tmp_id in _ids
                
                HSEEK _tmp_id
                
                do while !EOF() .and. EVAL(_key_block) == _tmp_id
                    skip
                    _rec := RECNO()
                    skip -1 
                    DELETE
                    go _rec 
                    _fnd := .t.
                    ++ _counter
                enddo
            next
            if ! _fnd 
                exit
            endif
        enddo

        log_write( "pos_doks local dbf, deleted rec: " + ALLTRIM(STR( _counter )) )

  ENDCASE

  // sada je sve izbrisano u lokalnom dbf-u

  log_write( "pos_doks update, db qry: " + _qry )
  _qry_obj := run_sql_query( _qry, _retry )
  _counter := 0

  DO WHILE !_qry_obj:Eof()
    
    append blank
        
    for _i := 1 to LEN(_fields)
          _fld := FIELDBLOCK(_fields[_i])
          if VALTYPE(EVAL(_fld)) $ "CM"
              EVAL(_fld, hb_Utf8ToStr(_qry_obj:FieldGet(_i)))
          else
              EVAL(_fld, _qry_obj:FieldGet(_i))
          endif
    next

    _qry_obj:Skip()
    ++ _counter

  ENDDO

  log_write( "pos_doks update db rec: " + ALLTRIM( STR( _counter ) ) )

next

USE

return .t. 


// -----------------------------------------
// -----------------------------------------
function pos_promvp_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "pos_promvp"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_PROMVP, {"datum", "polog01", "polog02", "polog03", "polog04", "ukupno" })

return _result




// -----------------------------------------
// -----------------------------------------
function pos_kase_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "pos_kase"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_KASE, {"id", "naz", "ppath" })

return _result


// -----------------------------------------
// -----------------------------------------
function pos_osob_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "pos_osob"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_OSOB, {"id", "naz", "korsif", "status" })

return _result


// -----------------------------------------
// -----------------------------------------
function pos_strad_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "pos_strad"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_STRAD, {"id", "naz", "prioritet" })

return _result



// -----------------------------------------
// -----------------------------------------
function pos_odj_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "pos_odj"

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_ODJ, {"id", "naz", "zaduzuje", "idkonto" })

return _result



