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

// ------------------------------------
// set_global_vars_from_dbf("w")
// geerise public vars wId, wNaz ..
// sa vrijednostima dbf polja Id, Naz 
// -------------------------------------
function set_global_memvars_from_dbf(zn)

return set_global_vars_from_dbf(zn)

// --------------------------------------------------
// TODO: ime set_global_vars_from_dbf je legacy
// --------------------------------------------------
function set_global_vars_from_dbf(zn)

local _i, _struct, _field, _var

private cImeP, cVar

if zn == NIL 
  zn := "_"
endif

_struct := DBSTRUCT()

for _i := 1 to LEN(_struct)
   _field := _struct[_i, 1]

    if !("#"+ _field +"#" $ "#BRISANO#_OID_#_COMMIT_#")
        _var := zn + _field
        // kreiram public varijablu sa imenom vrijednosti _var varijable
        __MVPUBLIC(_var)
        EVAL(MEMVARBLOCK(_var), EVAL(FIELDBLOCK(_field))) 

    endif
next

return .t.

function get_dbf_global_memvars( zn, rel, lUtf )
local _ime_polja, _i, _struct
local _ret := hb_hash()

if zn == nil
    zn := "_"
endif

// da li da pobrisem odmah iz memorije...
if rel == NIL
    rel := .t.
endif

if lUtf == NIL
   lUtf := .f.
endif

_struct := DBSTRUCT()

for _i := 1 to len(_struct)

    _ime_polja := _struct[_i, 1]
   
    if !("#"+ _ime_polja + "#" $ "#BRISANO#_OID_#_COMMIT_#")

        // punimo hash matricu sa vrijednostima public varijabli
        // _ret["idfirma"] := wIdFirma, za zn = "w"
        _ret[ LOWER(_ime_polja) ] := EVAL( MEMVARBLOCK( zn + _ime_polja) )
        
        IF ( VALTYPE( _ret[ LOWER(_ime_polja) ] ) == "C" ) .AND.  lUtf 
            _ret[ LOWER(_ime_polja) ] := hb_StrToUtf8 ( _ret[ LOWER(_ime_polja) ]  )
        ENDIF

        if rel
            // oslobadja public ili private varijablu
            __MVXRELEASE( zn + _ime_polja)
        endif

  endif

next

return _ret



// -----------------------------------------
// vratice osnovu naziva tabele
// fakt_fakt -> fakt
// fakt_doks -> fakt
// -----------------------------------------
static function _table_base( a_dbf_rec )
local _table := ""
local _sep := "_"
local _arr


if _sep $ a_dbf_rec["table"]
	_arr := toktoniz( a_dbf_rec["table"], _sep )	
	if LEN( _arr ) > 1
		_table := _arr[1]
	endif
endif

return _table

// ----------------------------------------------------
// ----------------------------------------------------
function iterate_through_active_tables(iterate_block)
local _key
local _f18_dbf
local _temp_tbl
local _sql_tbl := .f.

get_dbf_params_from_config()
_f18_dbfs := f18_dbfs()

for each _key in _f18_dbfs:Keys

    _temp_tbl := _f18_dbfs[_key]["temp"]

    // sql tabela
    if hb_hhaskey( _f18_dbfs[_key], "sql" )
         if _f18_dbfs[_key]["sql"]
               _sql_tbl := .t.
         endif
    endif
         
    if !_temp_tbl .and. !_sql_tbl

		_tbl_base := _table_base( _f18_dbfs[_key] )

		// radi os/sii
		if _tbl_base == "sii"
			_tbl_base := "os"
		endif

                // EMPTY - sifarnici (roba, tarifa itd)
		if  EMPTY( _tbl_base ) .or. f18_use_module( _tbl_base )
			EVAL(iterate_block, _f18_dbfs[_key] )
		endif

    endif

next

return .t.

// ---------------------------------------------------------------
// utvrdjuje da li se tabela koristi
//
// ako je use KALK = N, is_active_dbf_table("kalk_kalk") => .f.
//
// ---------------------------------------------------------------
function is_active_dbf_table(table)
local _key
local _f18_dbf
local _temp_tbl

_f18_dbfs := f18_dbfs()

// tabela sa ovakvim imenom uopste ne postoji
if  !HB_HHASKEY(_f18_dbfs, table)
  return .f.
endif


_temp_tbl := _f18_dbfs[table]["temp"]

  
if !_temp_tbl

		_tbl_base := _table_base( _f18_dbfs[table] )

		// radi os/sii
		if _tbl_base == "sii"
			_tbl_base := "os"
		endif

        // EMPTY - sifarnici (roba, tarifa itd)
		if  EMPTY(_tbl_base) .or. f18_use_module( _tbl_base )
            return .t.
		endif

endif

return .f.



