#include "common.ch"
#include "hbclass.ch"
#include "f18.ch"

CLASS DocCounter

    // prefix = "A1/", suffix="/13", prefix0="PP-", suffix0="-SS", count = 122, fill=0
    // "A1/PP-01000-SS/13 "
    //  ------------------ 
    //  width=18

    DATA       year
    DATA       prefix   INIT ""
    DATA       suffix   INIT "/13"
    DATA       prefix0  INIT ""
    DATA       suffix0  INIT ""
    DATA       fill     INIT "0"

    //         numeric_with <= width
    //         eg: 000921/13___ - numeric_width = 6, width = 10, sufix = "<G2>"
    DATA       width            INIT 12
    DATA       numeric_width    INIT  6

    METHOD     New
    
    ASSIGN     a_server_param          METHOD set_a_server_param
    ACCESS     a_server_param          INLINE ::a_s_param
    ACCESS     server_counter          METHOD get_server_counter
    ASSIGN     server_counter          METHOD set_server_counter
 
    METHOD     inc()
    METHOD     dec()
    ASSIGN     counter              METHOD  set_counter
    ACCESS     counter              METHOD  get_counter

    METHOD     new_document_number()

    ACCESS     document_counter     METHOD  get_counter_from_documents

    METHOD     to_str()
    METHOD     decode(str, change_counter)
    METHOD     rewind(dok_str)

    ACCESS     decoded_before_num   INLINE  ::decode_prefix0
    ACCESS     decoded_after_num    INLINE  ::decode_suffix0
    
    ACCESS     is_decoded          INLINE   ::decode_success
    ACCESS     error_message       INLINE   ::error_msg

    ACCESS     document_date       INLINE   ::doc_date
    ASSIGN     document_date       METHOD   set_document_date

    METHOD     validate

  PROTECTED:

    DATA       doc_date         INIT DATE()    
    DATA       count            INIT 0
    DATA       server_count     INIT 0
    DATA       c_document_count INIT ""
    DATA       document_count   

    DATA       decode_prefix0 
    DATA       decode_suffix0
    DATA       decode_count 

    // fakt/10/20 - RJ=10, TipDokumenta=00 
    DATA       a_s_param        
    DATA       c_s_param
 
    DATA       decode_success  INIT .t.
    DATA       decode_str      INIT ""
    DATA       decode_error    INIT ""
    DATA       error_msg       INIT "err"

    DATA       c_sql_get    
    METHOD     set_c_server_param
    METHOD     set_sql_get
   
    METHOD     transfer_decode_to_main_counter()
ENDCLASS

#ifdef TEST

// --------------------------------
// global var _TEST_CURRENT_YEAR
// --------------------------------
function get_current_year()
     // TODO: sa servera
     return _TEST_CURRENT_YEAR
return

#else
// --------------------------------
// --------------------------------
function get_current_year()
     // TODO: sa servera
     return YEAR(DATE())
return
#endif

// --------------------------------
// 2013 -> "13"
// --------------------------------
function year_2str(year)
     return RIGHT(ALLTRIM(STR(year)), 2)
return

METHOD DocCounter:validate(str)
local _msg

if ::year == NIL
   Alert("Klasa nije inicijalizirana kako treba! Npr: FactCounter() umjesto sa FaktCounter():New(..)")
   QUIT_1
endif

if ::year < 2013
    // svaki format je prihvatljiv
   return .t.
endif

::decode(str)

if (! ::is_decoded())
    _msg := "ERR validate DocNum: " + ::c_s_param + ", decode_str:" + ::decode_str + " error" + ::decode_error
    log_write(_msg, 3)
    ::error_msg := _msg
    return .f.
endif

return .t.

METHOD DocCounter:new_document_number()
local _doc_cnt, _s_cnt
 
_doc_cnt := ::document_counter
_s_cnt   := ::server_counter   

::count :=  MAX(_doc_cnt, _s_cnt)
::inc()
return ::count


// -----------------------------------
// -----------------------------------
METHOD DocCounter:rewind(dok_str)
local _doc_cnt, _s_cnt, _msg

if ::decode(dok_str, .t.)
   _doc_cnt := ::document_counter
   _s_cnt   := ::server_counter
else
    _msg := "DOC_CNT decode ERR: " + dok_str 
    log_write(_msg, 2)
    MsgBeep(_msg)
endif

// server counter > document counter AND tekuci counter == server counter
if (_s_cnt > _doc_cnt) .and. (::count == _s_cnt)
    ::dec()
    ::server_counter := ::count 
endif

// --------------------------------------
// c_s_param = fakt/10/20/13
// --------------------------------------
METHOD DocCounter:set_c_server_param()
local _i

::c_s_param := "" 
FOR _i := 1 TO LEN(::a_s_param)
   if _i > 1
      ::c_s_param += "/"
   endif
   ::c_s_param += ::a_s_param[_i]
NEXT
::c_s_param += ::suffix

return ::c_s_param

// --------------------------------------
// --------------------------------------
METHOD DocCounter:set_a_server_param(a_val)

::a_s_param := ACLONE(a_val)
::set_c_server_param()

return ::a_s_param

// --------------------------------------
// --------------------------------------
METHOD DocCounter:get_counter_from_documents()
local _qry, _c_qry, _c_cnt

// setuj na osnovu ::a_s_param
::set_sql_get()

_c_qry := ::c_sql_get
_qry   := run_sql_query(_c_qry)
_c_cnt := _qry:FieldGet(1)

if hb_isChar(_c_cnt)
   ::c_document_count := _c_cnt

   // dekodiraj dobijeni string, ali nemoj prebacivati u ::count rezultat
   // neka stoji u ::decode_count
   ::decode(_c_cnt, .f.)
   if ::is_decoded
      ::document_count   := ::decode_count
   else
      ::document_count   := 0
   endif
else
   ::c_document_count := ""
   ::document_count   := 0
endif

return ::document_count

// ------------------------------------------------------
// ::decode_count => ::count, isto za prefix0, suffix0   
// ------------------------------------------------------
METHOD DocCounter:transfer_decode_to_main_counter()

::count   := ::decode_count
::prefix0 := ::decode_prefix0
::suffix0 := ::decode_suffix0

return .t.

// --------------------------------------
// --------------------------------------
METHOD DocCounter:set_sql_get()

// uzmi brdok iz fakt_doks za zadatu firmu, tip dokumenta, i dokumente iz zadane godine
::c_sql_get := "select brdok from fmk.fakt_doks where idfirma=" + _sql_quote(::a_s_param[2]) + ;
               " AND idtipdok=" + _sql_quote(::a_s_param[3]) + ;
               " AND EXTRACT(YEAR FROM datdok)=" + ALLTRIM(STR(::year)) + ;
               " ORDER BY (datdok, brdok) DESC LIMIT 1"

return .t.

METHOD DocCounter:get_server_counter()
::server_count := fetch_metric(::c_s_param, NIL, ::server_count)
return ::server_count

METHOD DocCounter:set_server_counter(cnt)
::server_count := cnt
set_metric(::c_s_param, NIL, cnt)
return 


METHOD DocCounter:set_document_date(date)

::doc_date := date
::year     := YEAR(date) 
::suffix := "/" + year_2str(::year)

return .t.
 
// --------------------------------
// --------------------------------
METHOD DocCounter:New(cnt, width, numeric_width, pref, suf, fill, a_s_param, doc_date)

DEFAULT width TO 12
DEFAULT cnt   TO 0
DEFAULT pref  TO ""
DEFAULT suf   TO ""
DEFAULT fill  TO "0" 

if hb_isNumeric(cnt) .and. hb_isNumeric(width) .and. hb_isNumeric(numeric_width) .and. hb_isChar(pref) .and. hb_isChar(suf) .and. hb_isChar(fill)
	::count   := cnt
	::width   := width
        ::numeric_width := numeric_width 
	::prefix  := pref
	::suffix  := suf
        ::fill    := fill
else
	Alert("DocCounter parametri nisu dobri")
        QUIT
endif

if (::suffix == "<G2>")
    ::suffix := "/" + year_2str(get_current_year())
endif

if (a_s_param != NIL)
   ::a_server_param := a_s_param
endif

if (doc_date != NIL)
   ::document_date := doc_date
endif
  
return SELF

// --------------------------------
// --------------------------------
METHOD DocCounter:inc()
  ::count++
return ::count

// --------------------------------
// --------------------------------
METHOD DocCounter:dec()
  ::count--
return ::count

// --------------------------------
// --------------------------------
METHOD DocCounter:set_counter(cnt)
  ::count := cnt
return ::count


// --------------------------------
// --------------------------------
METHOD DocCounter:get_counter()
return ::count

// --------------------------------
// --------------------------------
static function str_regex(str)
  str := STRTRAN(str, "\", "\\") 
  str := STRTRAN(str, "/", "\/")
return str 

// --------------------------------
// --------------------------------
METHOD DocCounter:to_str()
local _w := ::numeric_width
return  PADR(::prefix + ::prefix0 + PADL(ALLTRIM(STR(::count, _w)), _w, ::fill) + ::suffix0 + ::suffix, ::width)

// -------------------------------------------
// -------------------------------------------
METHOD DocCounter:decode(str, change_counter)
local _a
//local _sep := "[#\/\\-]*"
local _re_str := str_regex(::prefix) + "(.*?)([" + ::fill + "]*)" +  "([0-9]{4," + ALLTRIM(STR(::width)) +"})(.*)" + str_regex(::suffix)
local _re_brdok := hb_regexComp( _re_str)

if change_counter == NIL
   change_counter := .t.
endif

::decode_str := str

if !hb_isString(str)
   ::decode_success := .f.
   ::decode_str := to_str(str)
   ::decode_error := "decode arg is not string ?!"
   ::error_msg := ::decode_error
   return .f.
endif

str := TRIM(str)

::decode_count := 0

if !hb_isRegex(_re_brdok)
  ::decode_success := .f.
  ::decode_error := "cannot compile: " + _re_str
  ::error_msg := ::decode_error
  return .f.
endif

if !hb_regexMatch(_re_brdok, str)
  ::decode_success := .f.
  ::decode_error := "no match"
   ::error_msg := ::decode_error
  return .f.
endif

_a := hb_regex(_re_brdok, str)

IF !hb_isArray(_a)
   ::decode_success := .f.
   ::decode_error := "no match/2"
   ::error_msg := ::decode_error
   return .f.
endif

::decode_prefix0 := _a[2]
::decode_suffix0 := _a[5]

if EMPTY(_a[4])
   ::decode_success := .f.
   ::decode_error := "no number ?!"
   ::error_msg := ::decode_error
   return .f.
else
   ::decode_count := VAL(_a[4])
endif

if change_counter
   ::transfer_decode_to_main_counter()
endif

::decode_success := .t.
return .t.
