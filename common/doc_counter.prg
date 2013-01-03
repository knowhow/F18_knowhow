#include "common.ch"
#include "hbclass.ch"

CLASS DocCounter

    // prefix = "A1/", suffix="/13", prefix0="PP-", suffix0="-SS", count = 122, fill=0
    // A1/PP-0100-SS/13
    //    ---------- 
    //     width=10 =  len(prefix0)+ len(numeric_width) + len(suffix0)

    DATA       count    INIT 0
    DATA       prefix   INIT ""
    DATA       suffix   INIT "/13"
    DATA       prefix0  INIT ""
    DATA       suffix0  INIT ""
    DATA       fill     INIT "0"

    //         numeric_with <= width
    //         eg: 000921/13___ - numeric_width = 6, width = 10, sufix = "<G2>"
    DATA       width         INIT 10
    DATA       numeric_width INIT  6

    METHOD     New()
    
    METHOD     inc()
    METHOD     dec()
    ASSIGN     counter              METHOD  set_counter
    ACCESS     counter              METHOD  get_counter

    METHOD     to_str()
    METHOD     decode(str)

    ACCESS     decoded_before_num   INLINE  ::prefix0
    ACCESS     decoded_after_num    INLINE  ::suffix0
    
    ACCESS     decoded             INLINE   ::decode_success
    ACCESS     error_message       INLINE   ::decode_error

  PROTECTED:
    DATA       decode_success INIT .t.
    DATA       decode_str INIT ""
    DATA       decode_error INIT ""

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




// --------------------------------
// --------------------------------
METHOD DocCounter:New(cnt, width, numeric_width, pref, suf, fill)

DEFAULT width TO 10
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
return  ::prefix + ::prefix0 + PADL(ALLTRIM(STR(::count, _w)), _w, ::fill) + ::suffix0 + ::suffix

// --------------------------------
// --------------------------------
METHOD DocCounter:decode(str)
local _a
//local _sep := "[#\/\\-]*"
local _re_str := str_regex(::prefix) + "(.*?)([" + ::fill + "]*)" +  "([0-9]{4," + ALLTRIM(STR(::width)) +"})(.*)" + str_regex(::suffix)
local _re_brdok := hb_regexComp( _re_str)

::decode_str := str

if !hb_isRegex(_re_brdok)
  ::decode_success := .f.
  ::decode_error := "cannot compile: " + _re_str
  return .f.
endif

if !hb_regexMatch(_re_brdok, str)
  ::decode_success := .f.
  ::decode_error := "no match"
  return .f.
endif

_a := hb_regex(_re_brdok, str)

IF !hb_isArray(_a)
   ::decode_success := .f.
   ::decode_error := "no match ?!"
   return .f.
endif

::prefix0 := _a[2]
::suffix0 := _a[5]

if EMPTY(_a[4])
   ::decode_success := .f.
   ::decode_error := "no number ?!"
   return .f.
else
   ::count   := VAL(_a[4])
endif

::decode_success := .t.
return .t.
