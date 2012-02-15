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

#include "fin.ch"
#include "common.ch"

// --------------------------------------------------------
// fin_suban - sinhronizacija sa servera
// --------------------------------------------------------
function fin_suban_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _orders := {}
local _key_blocks := {} 
local _key_block
local _i, _fld, _fields, _sql_fields
local _sql_in := {}
local _queries
local _tags := {}

// algoritam 1 - default
AADD(_orders, "idfirma, idvn, brnal, rbr")
AADD(_key_blocks, {|| field->idfirma + field->idvn + field->brnal + field->rbr } 
AADD(_tags, "4")
// algoritam 2 - nivo dokumenta
AADD(_orders, "idfirma, idvn, brnal")
AADD(_key_blocks, {|| field->idfirma + field->idvn + field->brnal} 

AADD(_sql_in, "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8) || lpad(rbr, 4)")
AADD(_sql_in, "rpad(idfirma,2) || rpad(idvn, 2) || rpad(brnal, 8)")
AADD(_tags, "4")


_tbl := "fmk.fin_suban"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_SUBAN
my_usex ("suban", "fin_suban", .f., "SEMAPHORE")

_fields := { "idfirma", "idvn", "brnal", "rbr", "datdok", "datval", "opis", "idpartner", "idkonto", "brdok", "d_p", "iznosbhd", "iznosdem", "k1", "k2", "k3", "k4", "m1", "m2", "idrj", "funk", "fond" }

_sql_fields := sql_fields( _fields )

for _offset := 0 to _count STEP _step




  DO CASE

   CASE (algoritam == "FULL") .and. (_offset==0)
    
    // "full" algoritam
    log_write("dat_dok = nil full algoritam") 
    ZAP

   CASE algoritam == "IDS"


    _queries := create_qry_from_ids("fin_suban",  _sql_in, _orders, _step, _offset)
     
    for _i := 1 LEN(_queries)

delete_dbf_ids(tags)

function delete_dbf_ids(tags)

	SET ORDER TO TAG "4"

	// CREATE_INDEX("4", "idFirma+IdVN+BrNal+Rbr", "SUBAN")
    // pobrisimo sve id-ove koji su drugi izmijenili

    _counter := 0

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
               ++ _counter
          enddo
        next
        if !_fnd 
			 exit 
		endif
    enddo

    log_write( "fin_suban local dbf, deleted rec: " + ALLTRIM(STR( _counter )) )
    next

  ENDCASE

  log_write( "fin_suban update query: " + _qry )
  
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

  log_write( "fin_suban update rec: " + ALLTRIM(STR( _counter )) )

next

USE

if (gDebug > 5)
    log_write("fin_suban synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 



// ----------------------------------------------
// fin_suban - update
// ----------------------------------------------
function sql_fin_suban_update( op, record )

LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()


_tbl := "fmk.fin_suban"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) + ;
                        " and brnal=" + _sql_quote(record["br_nal"]) + ;
                        " and rbr=" + _sql_quote(record["r_br"])
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
                "(idfirma, idvn, brnal, rbr, datdok, datval, opis, idpartner, idkonto, d_P, iznosbhd, iznosdem) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +; 
                            + _sql_quote( record["r_br"] ) + "," +; 
                            + _sql_quote( record["dat_dok"] ) + "," +; 
                            + _sql_quote( record["dat_val"] ) + "," +; 
                            + _sql_quote( record["opis"] ) + "," +; 
                            + _sql_quote( record["id_partner"] ) + "," +; 
                            + _sql_quote( record["id_konto"] ) + "," +; 
                            + _sql_quote( record["d_p"] ) + "," +; 
                            + STR( record["iznos_bhd"], 17, 2) + "," + ;
							+ STR( record["iznos_dem"], 17, 2) + ")" 

END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 


// -------------------------------------------------------------------
// fin_anal - sinhronizacija sa servera
// -------------------------------------------------------------------
function fin_anal_from_sql_server( algoritam )
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "idfirma, idvn, brnal, rbr"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.fin_anal"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_ANAL
my_usex ("anal", "fin_anal", .f., "SEMAPHORE")

_fields := { "idfirma", "idvn", "brnal", "rbr", "datnal", "idkonto", ;
        "dugbhd", "potbhd", "dugdem", "potdem" }

_sql_fields := sql_fields( _fields )

for _offset := 0 to _count STEP _step

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl  

  if algoritam == "DATE"
    _dat :=  get_dat_from_semaphore( "fin_anal" )
    _qry += " WHERE datnal >= " + _sql_quote(_dat)
    _key_block := { || field->datnal }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore( "fin_anal" )
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
        	_qry += " ( rpad( idfirma, 2) || rpad( idvn, 2) || rpad( brnal, 8) || lpad( rbr, 3) ) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idvn + field->brnal + field->rbr } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

   CASE algoritam == "FULL" .AND. _offset == 0
    
    // "full" algoritam
    log_write("dat_nal = nil full algoritam") 
    ZAP

   CASE algoritam == "DATE"

    log_write("dat_nal <> nil date algoritam") 
    // "date" algoritam  - brisi sve vece od zadanog datuma
    SET ORDER TO TAG "5"
    // tag je "DatDok" nije DTOS(DatDok)
    seek _dat
    do while !eof() .and. eval( _key_block )  >= _dat 
        // otidji korak naprijed
        SKIP
        _rec := RECNO()
        SKIP -1
        DELETE
        GO _rec  
    enddo

   CASE algoritam == "IDS"

	SET ORDER TO TAG "2"

	// CREATE_INDEX("2", "idFirma+IdVN+BrNal+Rbr", "ANAL")
    // pobrisimo sve id-ove koji su drugi izmijenili

    _counter := 0

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
               ++ _counter
          enddo
        next
        if !_fnd 
			 exit 
		endif
    enddo

    log_write( "fin_anal local dbf, deleted rec: " + ALLTRIM(STR( _counter )) )
  
  ENDCASE

  log_write( "fin_anal update qry: " + _qry )

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

  log_write( "fin_anal update rec: " + ALLTRIM(STR( _counter )) )

next

USE

if (gDebug > 5)
    log_write("fin_anal synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t.


// ----------------------------------------------
// fin_anal - update
// ----------------------------------------------
function sql_fin_anal_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()

_tbl := "fmk.fin_anal"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) + ;
                        " and rbr=" + _sql_quote(record["r_br"]) 
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
                "(idfirma, idvn, brnal, rbr, datnal, idkonto, dugbhd, potbhd, dugdem, potdem) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +; 
                            + _sql_quote( PADL( record["r_br"], 3 ) ) + "," +; 
                            + _sql_quote( record["dat_nal"] ) + "," +; 
                            + _sql_quote( record["id_konto"] ) + "," +; 
                            + STR( record["dug_bhd"], 17, 2 ) + "," +; 
                            + STR( record["pot_bhd"], 17, 2 ) + "," +; 
                            + STR( record["dug_dem"], 15, 2 ) + "," +; 
                            + STR( record["pot_dem"], 15, 2) + ")" 

END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 



// -------------------------------------------------------------------
// fin_sint - sinhronizacija sa servera
// -------------------------------------------------------------------
function fin_sint_from_sql_server( algoritam )
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "idfirma, idvn, brnal, rbr"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.fin_sint"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_SINT
my_usex ("sint", "fin_sint", .f., "SEMAPHORE")

_fields := { "idfirma", "idvn", "brnal", "rbr", "datnal", ;
        "idkonto", "dugbhd", "potbhd", "dugdem", "potdem" }

_sql_fields := sql_fields( _fields )

for _offset := 0 to _count STEP _step

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl  

  if algoritam == "DATE"
    _dat :=  get_dat_from_semaphore( "fin_sint" )
    _qry += " WHERE datnal >= " + _sql_quote(_dat)
    _key_block := { || field->datnal }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore( "fin_sint" )
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
        	_qry += " ( rpad( idfirma, 2 ) || rpad( idvn, 2 ) || rpad( brnal, 8 ) || lpad( rbr, 3 ) ) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idvn + field->brnal + field->rbr } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

   CASE (algoritam == "FULL") .and. (_offset==0)
    
    // "full" algoritam
    log_write("dat_nal = nil full algoritam") 
    ZAP

   CASE algoritam == "DATE"

    log_write("dat_nal <> nil date algoritam") 
    // "date" algoritam  - brisi sve vece od zadanog datuma
    SET ORDER TO TAG "3"
    // tag je "DatDok" nije DTOS(DatDok)
    seek _dat
    do while !eof() .and. eval( _key_block )  >= _dat 
        // otidji korak naprijed
        SKIP
        _rec := RECNO()
        SKIP -1
        DELETE
        GO _rec  
    enddo

   CASE algoritam == "IDS"

	SET ORDER TO TAG "2"

	// CREATE_INDEX("2", "idFirma+IdVN+BrNal+Rbr", "SINT")
    // pobrisimo sve id-ove koji su drugi izmijenili

    _counter := 0

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
               ++ _counter
          enddo
        next
        if !_fnd 
			 exit 
		endif
    enddo

    log_write( "fin_sint local dbf, deleted rec: " + ALLTRIM(STR( _counter )) )

  ENDCASE

  log_write( "fin_sint update qry: " + _qry )

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

  log_write( "fin_sint update rec: " + ALLTRIM(STR( _counter )) )

next

USE

if (gDebug > 5)
    log_write("fin_sint synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t.


// ----------------------------------------------
// fin_sint - update
// ----------------------------------------------
function sql_fin_sint_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()

_tbl := "fmk.fin_sint"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) + ;
                        " and rbr=" + _sql_quote(record["r_br"]) 
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
                "(idfirma, idvn, brnal, rbr, datnal, idkonto, dugbhd, potbhd, dugdem, potdem) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +; 
                            + _sql_quote( PADL( record["r_br"] , 3)) + "," +; 
                            + _sql_quote( record["dat_nal"] ) + "," +; 
                            + _sql_quote( record["id_konto"] ) + "," +; 
                            + STR( record["dug_bhd"], 17, 2 ) + "," +; 
                            + STR( record["pot_bhd"], 17, 2 ) + "," +; 
                            + STR( record["dug_dem"], 15, 2 ) + "," +; 
                            + STR( record["pot_dem"], 15, 2) + ")" 

END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 



// -------------------------------------------------------------------
// fin_nalog - sinhronizacija sa servera
// -------------------------------------------------------------------
function fin_nalog_from_sql_server( algoritam )
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "idfirma, idvn, brnal"
local _key_block
local _i, _fld, _fields, _sql_fields

_tbl := "fmk.fin_nalog"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_NALOG
my_usex ("nalog", "fin_nalog", .f., "SEMAPHORE")

_fields := { "idfirma", "idvn", "brnal", "datnal", "dugbhd", ;
        "potbhd", "dugdem", "potdem" }

_sql_fields := sql_fields( _fields )

for _offset := 0 to _count STEP _step

  _qry :=  "SELECT " + _sql_fields + " FROM " + _tbl  

  if algoritam == "DATE"
    _dat :=  get_dat_from_semaphore( "fin_nalog" )
    _qry += " WHERE datnal >= " + _sql_quote(_dat)
    _key_block := { || field->datnal }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore( "fin_nalog" )
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
        	_qry += " ( rpad( idfirma, 2 ) || rpad( idvn, 2 ) || rpad( brnal, 8 ) ) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idvn + field->brnal } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

   CASE (algoritam == "FULL") .and. (_offset==0)
    
    // "full" algoritam
    log_write("dat_nal = nil full algoritam") 
    ZAP

   CASE algoritam == "DATE"

    log_write("dat_nal <> nil date algoritam") 
    // "date" algoritam  - brisi sve vece od zadanog datuma
    SET ORDER TO TAG "4"
    // tag je "DatDok" nije DTOS(DatDok)
    seek _dat
    do while !eof() .and. eval( _key_block )  >= _dat 
        // otidji korak naprijed
        SKIP
        _rec := RECNO()
        SKIP -1
        DELETE
        GO _rec  
    enddo

   CASE algoritam == "IDS"

	SET ORDER TO TAG "1"

	// CREATE_INDEX("1", "idFirma+IdVN+BrNal", "NALOG")
    // pobrisimo sve id-ove koji su drugi izmijenili

    _counter := 0

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
               ++ _counter
          enddo
        next
        if !_fnd 
			 exit 
		endif
    enddo

    log_write( "fin_nalog local dbf, deleted rec: " + ALLTRIM(STR( _counter )) )

  ENDCASE

  log_write( "fin_nalog update qry: " + _qry )

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

  log_write( "fin_nalog update rec: " + ALLTRIM(STR( _counter )) )

next

USE

if (gDebug > 5)
    log_write("fin_nalog synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t.


// ----------------------------------------------
// fin_nalog - update
// ----------------------------------------------
function sql_fin_nalog_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where
LOCAL _server := pg_server()

_tbl := "fmk.fin_nalog"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
    if gDebug > 7
        log_write("SQL BEGIN: " + _tbl)
    endif

 CASE op == "END"
    _qry := "COMMIT;"
    if gDebug > 7
        log_write("SQL COMMIT: " + _tbl)
    endif

 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
    if gDebug > 7
        log_write("SQL ROLLBACK: " + _tbl)
    endif


 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
                "(idfirma, idvn, brnal, datnal, dugbhd, potbhd, dugdem, potdem) " + ;
                "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +; 
                            + _sql_quote( record["dat_nal"] ) + "," +; 
                            + STR( record["dug_bhd"], 17, 2 ) + "," +; 
                            + STR( record["pot_bhd"], 17, 2 ) + "," +; 
                            + STR( record["dug_dem"], 15, 2 ) + "," +; 
                            + STR( record["pot_dem"], 15, 2) + ")" 

END CASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif

