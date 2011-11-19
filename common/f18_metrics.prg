#include "fmk.ch"



// funkcije za setovanje i iscitavanje parametara iz knowhow database-a
// koriste se pqsql funkcije fetchmetrictext() i setmetrictext()

// primjer koristenja:
//
// (citanje)
// local gFc_use := "N"
// f18_get_metric("KoristitiFiskalneFunkcije", @gFc_use )
//
// (upisivanje)
// f18_set_metric("KoristitiFiskalneFunkcije", gFc_use )
//
// ako zelimo da nas parametar bude privatan, tj. za pojedinog korisnika
// zadajemo ga ovako, postavljamo treci uslov na .t.
//
// f18_get_metric("Koristiti...", @gFc_use, .t. ) 
//
// -------------------------------------------------------------
// vrati parametar iz metric tabele
// -------------------------------------------------------------
function f18_get_metric( param, value, par_private )
local _temp_qry
local _table
local _server := pg_server()
local _temp_res := ""

if par_private == nil
	par_private := .f.
endif

_temp_qry := "SELECT fetchmetrictext(" + _sql_quote( __param_name(param, par_private) ) + ")"
_table := _sql_query( _server, _temp_qry )
if _table == NIL
	MsgBeep( "problem sa: " + _temp_qry )
    return .f.
endif

_temp_res := _table:Fieldget( _table:Fieldpos("fetchmetrictext") )

if EMPTY( _temp_res )
	f18_set_metric( param, value, par_private )
else
	value := __get_param_value( value, _temp_res )
endif

return .t.



// --------------------------------------------------------------
// setuj parametre u metric tabelu
// --------------------------------------------------------------
function f18_set_metric( param, value, par_priv )
local _temp_qry
local _table
local _server := pg_server()

if par_priv == nil
	par_priv := .f.
endif

_temp_qry := "SELECT setmetric(" + _sql_quote( __param_name(param, par_priv) ) + "," + _sql_quote( __set_param_value( value ) ) +  ")"
_table := _sql_query( _server, _temp_qry )
if _table == NIL
	MsgBeep( "problem sa:" + _temp_qry )
    return .f.
endif

return _table:Fieldget( _table:Fieldpos("setmetric") )




// -------------------------------------------------------------
// vraca naziv parametra
// 
// struktura parametra ce biti 
//    za priv_param = .t.    F18/ime_usera/FIN/naziv_parametra
//    za priv_param = .f.    F18/FIN/naziv_parametra
// -------------------------------------------------------------
static function __param_name( param, priv_param )
local __ret := ""

__ret += "F18/"

if priv_param = .t.
	__ret += f18_user() + "/" 
endif

__ret += goModul:oDataBase:cName + "/"

__ret += param

return __ret


// vraca vrijednost varijable iz baze na osnovu originalne 
// vrijednosti
// iz baze će nam sve izaći kao "string" pa moramo napraviti konverziju
static function __get_param_value( _orig_value, _string )
local __val_type := valtype( _orig_value )

do case
	case __val_type == "C"
		// ovo je string
		return _string
	case __val_type == "N"
		// ovo je numeric
		return val( _string )
	case __val_type == "D"
		// ovo je date
		return ctod( _string )
	case __val_type == "L"
		// ovo je bool
		if _string = ".t."
			return .t.
		else
			return .f.
		endif
endcase

return



// setuje varijable i pri tome konvertuje kao string
static function __set_param_value( value )
local __val_type := valtype( value )

do case
	case __val_type == "C"
		// ovo je string
		return value
	case __val_type == "N"
		// ovo je numeric
		return str( value )
	case __val_type == "D"
		// ovo je date
		return dtoc( value )
	case __val_type == "L"
		// ovo je bool
		if value = .t.
			return "TRUE"
		else
			return "FALSE"
		endif
endcase

return


