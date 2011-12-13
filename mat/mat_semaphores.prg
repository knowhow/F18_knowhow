/* 
 * This file is part of the bring.out ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "mat.ch"
#include "common.ch"

// ------------------------------
// koristi azur_sql
// ------------------------------
function mat_suban_from_sql_server(algoritam)
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

_tbl := "fmk.mat_suban"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
	algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update mat_suban: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_MAT_SUBAN
my_usex ("mat_suban", "mat_suban", .f., "SEMAPHORE")

_fields := { "idfirma", "idroba", "idkonto", "idvn", "brnal", "rbr", ;
	"idtipdok", "brdok", "datdok", "u_i", "kolicina", "d_p", "iznos", "idpartner", ;
	"idzaduz", "iznos2", "datkurs", "k1", "k2", "k3", "k4" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " +	_tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("mat_suban")
	_qry += " WHERE datdok >= " + _sql_quote(_dat)
    _key_block := {|| field->datdok }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore("mat_suban")
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
        	_qry += " (idfirma || idvn || brnal) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idvn + field->brnal } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

	CASE algoritam == "FULL" .and. _offset==0
    	// "full" algoritam
    	log_write("datdok = nil full algoritam") 
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
    	
    	SET ORDER TO TAG "4"

		// CREATE_INDEX("4", "idFirma+IdVn+BrNal+Rbr", "MAT_SUBAN")
    	// pobrisimo sve id-ove koji su drugi izmijenili
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
  // sada je sve izbrisano

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

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

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO

next

USE

if (gDebug > 5)
    log_write("mat_suban synchro cache:" + STR(SECONDS() - _seconds))
endif
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_mat_suban_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.mat_suban"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) 
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
				"( idfirma, idroba, idkonto, idvn, brnal, rbr, idtipdok, brdok, datdok, u_i, kolicina, d_p, " + ;
				"iznos, idpartner, idzaduz, iznos2, datkurs, k1, k2, k3, k4 ) " + ;
               "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_roba"] ) + "," +; 
                            + _sql_quote( record["id_konto"] ) + "," +; 
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +;
                            + _sql_quote( record["r_br"] ) + "," +;
                            + _sql_quote( record["id_tip_dok"] ) + "," +;
                            + _sql_quote( record["br_dok"] ) + "," +;
                            + _sql_quote( record["dat_dok"] ) + "," +;
                            + _sql_quote( record["u_i"] ) + "," +;
                            + STR( record["kolicina"], 10, 3 ) + "," +;
                            + _sql_quote( record["d_p"] ) + "," +;
                            + STR( record["iznos"], 15, 2 ) + "," +;
                            + _sql_quote( record["id_partner"] ) + "," +;
                            + _sql_quote( record["id_zaduz"] ) + "," +;
                            + STR( record["iznos2"], 15, 2 ) + "," +;
                            + _sql_quote( record["dat_kurs"] ) + "," +;
                            + _sql_quote( record["k1"] ) + "," +;
                            + _sql_quote( record["k2"] ) + "," +;
                            + _sql_quote( record["k3"] ) + "," +;
                            + _sql_quote( record["k4"] ) + " )"
                          
ENDCASE
   
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
 


// ------------------------------
// koristi azur_sql
// ------------------------------
function mat_nalog_from_sql_server(algoritam)
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

_tbl := "fmk.mat_nalog"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
	algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update mat_nalog: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_MAT_NALOG
my_usex ("mat_nalog", "mat_nalog", .f., "SEMAPHORE")

_fields := { "idfirma", "idvn", "brnal", "datnal", ;
				"dug", "pot", "dug2", "pot2" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " +	_tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("mat_nalog")
	_qry += " WHERE datnal >= " + _sql_quote(_dat)
    _key_block := {|| field->datnal }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore("mat_nalog")
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
        	_qry += " (idfirma || idvn || brnal) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idvn + field->brnal } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

	CASE algoritam == "FULL" .and. _offset==0
    	// "full" algoritam
    	log_write("datdok = nil full algoritam") 
    	ZAP

	CASE algoritam == "DATE"

    	log_write("datdok <> nil date algoritam") 
    	// "date" algoritam  - brisi sve vece od zadanog datuma
    	SET ORDER TO TAG "2"
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

		// CREATE_INDEX("1", "idFirma+IdVn+BrNal", "MAT_NALOG")
    	// pobrisimo sve id-ove koji su drugi izmijenili
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
  // sada je sve izbrisano

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

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

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO

next

USE

if (gDebug > 5)
    log_write("mat_nalog synchro cache:" + STR(SECONDS() - _seconds))
endif
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_mat_nalog_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.mat_nalog"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) 
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
				"( idfirma, idvn, brnal, datnal, dug, pot, dug2, pot2 ) " + ;
               "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +;
                            + _sql_quote( record["dat_nal"] ) + "," +;
                            + STR( record["dug"], 15, 2 ) + "," +;
                            + STR( record["pot"], 15, 2 ) + "," +;
                            + STR( record["dug2"], 15, 2 ) + "," +;
                            + STR( record["pot2"], 15, 2 ) + " )"
                          
ENDCASE
   
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
 


// ------------------------------
// koristi azur_sql
// ------------------------------
function mat_anal_from_sql_server(algoritam)
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

_tbl := "fmk.mat_anal"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
	algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update mat_anal: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_MAT_ANAL
my_usex ("mat_anal", "mat_anal", .f., "SEMAPHORE")

_fields := { "idfirma", "idkonto", "idvn", "brnal", "datnal", ;
				"rbr", "dug", "pot", "dug2", "pot2" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " +	_tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("mat_anal")
	_qry += " WHERE datnal >= " + _sql_quote(_dat)
    _key_block := {|| field->datnal }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore("mat_anal")
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
        	_qry += " (idfirma || idvn || brnal) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idvn + field->brnal } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

	CASE algoritam == "FULL" .and. _offset==0
    	// "full" algoritam
    	log_write("datdok = nil full algoritam") 
    	ZAP

	CASE algoritam == "DATE"

    	log_write("datdok <> nil date algoritam") 
    	// "date" algoritam  - brisi sve vece od zadanog datuma
    	SET ORDER TO TAG "3"
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
    	
    	SET ORDER TO TAG "2"

		// CREATE_INDEX("2", "idFirma+IdVn+BrNal", "MAT_ANAL")
    	// pobrisimo sve id-ove koji su drugi izmijenili
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
  // sada je sve izbrisano

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

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

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO

next

USE

if (gDebug > 5)
    log_write("mat_anal synchro cache:" + STR(SECONDS() - _seconds))
endif
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_mat_anal_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.mat_anal"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) 
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
				"( idfirma, idkonto, idvn, brnal, rbr, datnal, dug, pot, dug2, pot2 ) " + ;
               "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_konto"] ) + "," +; 
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +;
                            + _sql_quote( record["r_br"] ) + "," +;
                            + _sql_quote( record["dat_nal"] ) + "," +;
                            + STR( record["dug"], 15, 2 ) + "," +;
                            + STR( record["pot"], 15, 2 ) + "," +;
                            + STR( record["dug2"], 15, 2 ) + "," +;
                            + STR( record["pot2"], 15, 2 ) + " )"
                          
ENDCASE
   
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
 
return



// ------------------------------
// koristi azur_sql
// ------------------------------
function mat_sint_from_sql_server(algoritam)
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

_tbl := "fmk.mat_sint"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
	algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update mat_sint: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_MAT_SINT
my_usex ("mat_sint", "mat_sint", .f., "SEMAPHORE")

_fields := { "idfirma", "idkonto", "idvn", "brnal", "datnal", ;
				"rbr", "dug", "pot", "dug2", "pot2" }

_sql_fields := sql_fields(_fields)
 
for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + _sql_fields + " FROM " +	_tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("mat_sint")
	_qry += " WHERE datnal >= " + _sql_quote(_dat)
    _key_block := {|| field->datnal }
  endif

  if algoritam == "IDS"
		_ids := get_ids_from_semaphore("mat_sint")
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
        	_qry += " (idfirma || idvn || brnal) IN " + _sql_ids
     	endif

        _key_block := {|| field->idfirma + field->idvn + field->brnal } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

	CASE algoritam == "FULL" .and. _offset==0
    	// "full" algoritam
    	log_write("datdok = nil full algoritam") 
    	ZAP

	CASE algoritam == "DATE"

    	log_write("datdok <> nil date algoritam") 
    	// "date" algoritam  - brisi sve vece od zadanog datuma
    	SET ORDER TO TAG "3"
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
    	
    	SET ORDER TO TAG "2"

		// CREATE_INDEX("2", "idFirma+IdVn+BrNal", "MAT_SINT")
    	// pobrisimo sve id-ove koji su drugi izmijenili
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
  // sada je sve izbrisano

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

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

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO

next

USE

if (gDebug > 5)
    log_write("mat_sint synchro cache:" + STR(SECONDS() - _seconds))
endif
 
return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_mat_sint_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.mat_sint"

if record <> nil
	_where := "idfirma=" + _sql_quote(record["id_firma"]) + " and idvn=" + _sql_quote( record["id_vn"]) +;
                        " and brnal=" + _sql_quote(record["br_nal"]) 
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
				"( idfirma, idkonto, idvn, brnal, rbr, datnal, dug, pot, dug2, pot2 ) " + ;
               "VALUES(" + _sql_quote( record["id_firma"] )  + "," +;
                            + _sql_quote( record["id_konto"] ) + "," +; 
                            + _sql_quote( record["id_vn"] ) + "," +; 
                            + _sql_quote( record["br_nal"] ) + "," +;
                            + _sql_quote( record["r_br"] ) + "," +;
                            + _sql_quote( record["dat_nal"] ) + "," +;
                            + STR( record["dug"], 15, 2 ) + "," +;
                            + STR( record["pot"], 15, 2 ) + "," +;
                            + STR( record["dug2"], 15, 2 ) + "," +;
                            + STR( record["pot2"], 15, 2 ) + " )"
                          
ENDCASE
   
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
 
return



// -----------------------------------------
// -----------------------------------------
function mat_karkon_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "mat_karkon"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM

	if get_semaphore_status( _tbl ) == "lock"
		Msgbeep( "tabela zakljucana: " + _tbl )
		hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
	else
		lock_semaphore( _tbl, "lock" )
	endif

next

_result := sifrarnik_from_sql_server( _tbl, algoritam, F_KARKON, {"id", "tip_nc", "tip_pc" })

lock_semaphore( _tbl, "free" )

return _result






