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


#include "fakt.ch"
#include "common.ch"

// ------------------------------
// koristi azur_sql
// ------------------------------
function fakt_fakt_from_sql_server(algoritam)
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
local _order := "idfirma, idtipdok, brdok, rbr"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.fakt_fakt"

if algoritam == NIL
    algoritam := "FULL"
endif

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_FAKT
my_usex ("fakt", "fakt_fakt", .f., "SEMAPHORE")

_fields := { "idfirma", "idtipdok", "brdok", "rbr", "datdok", "idpartner", "dindem", "zaokr", "podbr", "idroba", "serbr", "kolicina", "cijena", "rabat", "porez", "txt", "k1", "k2", "m1", "idvrstep", "idpm", "c1", "c2", "c3", "n1", "n2", "opis", "dok_veza" }


_sql_fields := sql_fields(_fields)

 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("fakt_fakt")
    _qry += " WHERE datdok >= " + _sql_quote(_dat)
    _key_block := {|| field->datdok }
  endif

  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("fakt_fakt")
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
            _qry += " (idfirma || idtipdok || brdok) IN " + _sql_ids
        endif

        _key_block := {|| field->idfirma + field->idtipdok + field->brdok } 
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
        SET ORDER TO TAG "8"
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
        
        // "1", "idFirma+Idtipdok+BrDok+Rbr"
        SET ORDER TO TAG "1"

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
                enddo
            next
            if ! _fnd 
                exit
            endif
        enddo

  ENDCASE

  // sada je sve izbrisano u lokalnom dbf-u

  _qry_obj := run_sql_query( _qry, _retry )
  _counter := 1

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

  ENDDO

next

USE

log_write("fakt_fakt synchro cache:" + STR(SECONDS() - _seconds))

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_fakt_fakt_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.fakt_fakt"

if record <> nil
    _where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idtipdok=" + _sql_quote( record["id_tip_dok"]) +;
                        " and brdok=" + _sql_quote(record["br_dok"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
                "( idfirma, idtipdok, brdok, rbr, datdok, idpartner, dindem, zaokr, podbr, idroba, serbr, kolicina, " + ;
                "cijena, rabat, porez, txt, k1, k2, m1, idvrstep, idpm, c1, c2, c3, n1, n2, opis, dok_veza ) " + ;
               "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_tip_dok"] ) + "," +; 
                            + _sql_quote( record["br_dok"] ) + "," +; 
                            + _sql_quote(STR( record["r_br"] , 3)) + "," +; 
                            + _sql_quote( record["dat_dok"] ) + "," +;
                            + _sql_quote( record["id_partner"] ) + "," +;
                            + _sql_quote( record["din_dem"] ) + "," +;
                            + _sql_quote( record["zaokr"] ) + "," +;
                            + _sql_quote(STR( record["pod_br"], 2 )) + "," +;
                            + _sql_quote( record["id_roba"] ) + "," +;
                            + _sql_quote( record["ser_br"] ) + "," +;
                            + STR( record["kolicina"], 14, 5 ) + "," +;
                            + STR( record["cijena"], 14, 5 ) + "," +;
                            + STR( record["rabat"], 8, 5 ) + "," +;
                            + STR( record["porez"], 9, 5 ) + "," +;
                            + _sql_quote( record["txt"] ) + "," +;
                            + _sql_quote( record["k1"] ) + "," +;
                            + _sql_quote( record["k2"] ) + "," +;
                            + _sql_quote( record["m1"] ) + "," +;
                            + _sql_quote( record["id_vrste_p"] ) + "," +;
                            + _sql_quote( record["id_pm"] ) + "," +;
                            + _sql_quote( record["c1"] ) + "," +;
                            + _sql_quote( record["c2"] ) + "," +;
                            + _sql_quote( record["c3"] ) + "," +;
                            + STR( record["n1"], 10, 3 ) + "," +;
                            + STR( record["n2"], 10, 3 ) + "," +;
                            + _sql_quote( record["opis"] ) + "," +;
                            + _sql_quote( record["dok_veza"] ) + " )"
                          
ENDCASE
   
_ret := _sql_query( _server, _qry)

log_write(_qry)
log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 

// ------------------------------
// koristi azur_sql
// ------------------------------
function fakt_doks_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _dat, _ids
local _fnd, _tmp_id
local _tbl
local _count
local _offset
local _step := 15000
local _retry := 3
local _order := "idfirma, idtipdok, brdok"
local _key_block
local _i, _fld, _fields, _sql_fields

if algoritam == NIL
  algoritam := "FULL"
endif

_tbl := "fmk.fakt_doks"

_seconds := SECONDS()

_count := table_count( _tbl, "true" )

_fields := { "idfirma", "idtipdok", "brdok", "partner", "datdok", "dindem", "iznos", "rabat", "rezerv", "m1", "idpartner", "idvrstep", "datpl", "idpm", "dok_veza", "oper_id", "fisc_rn", "dat_isp", "dat_otpr", "dat_val" }
_sql_fields := sql_fields(_fields)

SELECT F_FAKT_DOKS
my_usex ("fakt_doks", "fakt_doks", .f., "SEMAPHORE")

for _offset := 0 to _count STEP _step

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl

  if algoritam == "DATE"
      _dat = get_dat_from_semaphore( "fakt_doks" )
      _qry += " WHERE datdok >= " + _sql_quote(_dat)
      _key_block := { || field->datdok }
  endif

  if algoritam == "IDS"
        _ids := get_ids_from_semaphore( "fakt_doks" )
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
            _qry += " (idfirma || idtipdok || brdok) IN " + _sql_ids
        endif

        _key_block := {|| field->idfirma + field->idtipdok + field->brdok } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset  == 0)
        
        log_write(_tbl  + " : refresh full algoritam") 
        ZAP
    
    CASE algoritam == "DATE"

        log_write("dat_dok <> nil date algoritam") 
        // "date" algoritam  - brisi sve vece od zadanog datuma
        SET ORDER TO TAG "5"
        // tag je "DatDok" nije DTOS(DatDok)
        seek _dat
        do while !eof() .and. EVAL( _key_block ) >= _dat 
            // otidji korak naprijed
            SKIP
            _rec := RECNO()
            SKIP -1
            DELETE
            GO _rec  
        enddo

    CASE algoritam == "IDS"
        
        // "1", "idFirma+IdTipDok+BrDok"
        SET ORDER TO TAG "1"

        do while .t.
            _fnd := .f.
            for each _tmp_id in _ids
                HSEEK _tmp_id
                do while !EOF() .and. EVAL( _key_block ) == _tmp_id 
                    skip
                    _rec := RECNO()
                    skip -1 
                    DELETE
                    go _rec 
                    _fnd := .t.
                enddo
            next
            if ! _fnd 
                exit
            endif
        enddo

  ENDCASE

  _qry_obj := run_sql_query( _qry, _retry )

  _counter := 1

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

    _counter++

  ENDDO

next

USE

log_write("fakt_doks synchro cache:" + STR(SECONDS() - _seconds))

return .t. 

// ----------------------------------------------
// ----------------------------------------------
function sql_fakt_doks_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.fakt_doks"

if record <> nil
    _where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idtipdok=" + _sql_quote( record["id_tip_dok"]) +;
                        " and brdok=" + _sql_quote(record["br_dok"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
                "( idfirma, idtipdok, brdok, partner, datdok, dindem, iznos, rabat, rezerv, m1, idpartner, " + ;
                "idvrstep, datpl, idpm, dok_veza, oper_id, fisc_rn, dat_isp, dat_otpr, dat_val ) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_tip_dok"] ) + "," +; 
                            + _sql_quote( record["br_dok"] ) + "," +; 
                            + _sql_quote( record["partner"] ) + "," +;
                            + _sql_quote( record["dat_dok"] ) + "," +;
                            + _sql_quote( record["din_dem"] ) + "," +;
                            + _sql_quote( STR( record["iznos"], 12, 3 )) + "," +;
                            + _sql_quote( STR( record["rabat"], 12, 3 )) + "," +;
                            + _sql_quote( record["rezerv"] ) + "," +;
                            + _sql_quote( record["m1"] ) + "," +;
                            + _sql_quote( record["id_partner"] ) + "," +;
                            + _sql_quote( record["id_vrste_p"] ) + "," +;
                            + _sql_quote( record["dat_pl"] ) + "," +;
                            + _sql_quote( record["id_pm"] ) + "," +;
                            + _sql_quote( record["dok_veza"] ) + "," +;
                            + _sql_quote( STR( record["oper_id"], 10, 0 ) ) + "," +;
                            + _sql_quote( STR( record["fisc_rn"], 10, 0 ) ) + "," +;
                            + _sql_quote( record["dat_isp"] ) + "," +;
                            + _sql_quote( record["dat_otpr"] ) + "," +;
                            + _sql_quote( record["dat_val"] ) + " )"
                          
END CASE
   
_ret := _sql_query( _server, _qry)

log_write(_qry)
log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 


// ------------------------------
// koristi azur_sql
// ------------------------------
function fakt_doks2_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _dat, _ids
local _fnd, _tmp_id
local _tbl
local _count
local _offset
local _step := 15000
local _retry := 3
local _order := "idfirma, idtipdok, brdok"
local _key_block
local _i, _fld, _fields, _sql_fields

if algoritam == NIL
  algoritam := "FULL"
endif

_tbl := "fmk.fakt_doks2"

_seconds := SECONDS()

_count := table_count( _tbl, "true" )

SELECT F_FAKT_DOKS2
my_usex ("fakt_doks2", "fakt_doks2", .f., "SEMAPHORE")

_fields := { "idfirma", "idtipdok", "brdok", "k1", "k2", "k3", "k4", "k5", "n1", "n2" }
_sql_fields := sql_fields( _fields )

for _offset := 0 to _count STEP _step

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl

  if algoritam == "DATE"
      _dat = get_dat_from_semaphore( "fakt_doks2" )
      _qry += " WHERE datdok >= " + _sql_quote(_dat)
      _key_block := { || field->datdok }
  endif

  if algoritam == "IDS"
        _ids := get_ids_from_semaphore( "fakt_doks2" )
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
            _qry += " (idfirma || idtipdok || brdok) IN " + _sql_ids
        endif

        _key_block := {|| field->idfirma + field->idtipdok + field->brdok } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

    CASE (algoritam == "FULL") .and. (_offset == 0)
        
        // "full" algoritam
        log_write("dat_dok = nil full algoritam") 
        ZAP
    
    CASE algoritam == "DATE"

        log_write("dat_dok <> nil date algoritam") 
        // "date" algoritam  - brisi sve vece od zadanog datuma
        SET ORDER TO TAG "5"
        // tag je "DatDok" nije DTOS(DatDok)
        seek _dat
        do while !eof() .and. EVAL( _key_block ) >= _dat 
            // otidji korak naprijed
            SKIP
            _rec := RECNO()
            SKIP -1
            DELETE
            GO _rec  
        enddo

    CASE algoritam == "IDS"
        
        // "1", "idFirma+IdTipDok+BrDok"
        SET ORDER TO TAG "1"

        do while .t.
            _fnd := .f.
            for each _tmp_id in _ids
                
                HSEEK _tmp_id
                
                do while !EOF() .and. EVAL( _key_block ) == _tmp_id 
                    skip
                    _rec := RECNO()
                    skip -1 
                    DELETE
                    go _rec 
                    _fnd := .t.
                enddo
            next
            if ! _fnd 
                exit
            endif
        enddo

  ENDCASE

  _qry_obj := run_sql_query( _qry, _retry )

  _counter := 1

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

    _counter++

  ENDDO


next

USE
    
log_write("fakt_doks2 synchro cache:" + STR(SECONDS() - _seconds))

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_fakt_doks2_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()


_tbl := "fmk.fakt_doks2"

if record <> nil
    _where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idtipdok=" + _sql_quote( record["id_tip_dok"]) +;
                        " and brdok=" + _sql_quote(record["br_dok"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
                "( idfirma, idtipdok, brdok, k1, k2, k3, k4, k5, n1, n2 ) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_tip_dok"] ) + "," +; 
                            + _sql_quote( record["br_dok"] ) + "," +; 
                            + _sql_quote( record["k1"] ) + "," +;
                            + _sql_quote( record["k2"] ) + "," +;
                            + _sql_quote( record["k3"] ) + "," +;
                            + _sql_quote( record["k4"] ) + "," +;
                            + _sql_quote( record["k5"] ) + "," +;
                            + _sql_quote( STR( record["n1"], 15, 2 )) + "," +;
                            + _sql_quote( STR( record["n2"], 15, 2 )) + ")"
                          
END CASE
   
_ret := _sql_query( _server, _qry)

log_write(_qry)
log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 




