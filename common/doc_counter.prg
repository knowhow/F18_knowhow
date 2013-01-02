#include "common.ch"
#include "hbclass.ch"

CLASS DocCounter

    DATA       count  INIT 0
    DATA       width  INIT 10
    DATA       prefix INIT ""
    DATA       suffix INIT "/13"
    DATA       fill   INIT "0"

    METHOD     New()
    
    METHOD     inc()
    METHOD     dec()

    METHOD     to_str()

    ASSIGN     counter     METHOD   set_counter
    ACCESS     counter     METHOD   get_counter
ENDCLASS


METHOD DocCounter:New(cnt, width, pref, suf, fill)

DEFAULT width TO 10
DEFAULT cnt   TO 0
DEFAULT pref  TO ""
DEFAULT suf   TO ""
DEFAULT fill  TO "0" 

if hb_isNumeric(cnt) .and. hb_isNumeric(width) .and. hb_isChar(pref) .and. hb_isChar(suf) .and. hb_isChar(fill)
	::count   := cnt
	::width   := width
	::prefix  := pref
	::suffix  := suf
        ::fill    := fill
else
	Alert("parametri nisu dobri")
        QUIT
endif

return SELF


METHOD DocCounter:inc()
  ::count++
return ::count

METHOD DocCounter:dec()
  ::count--
return ::count

METHOD DocCounter:set_counter(cnt)
  ::count := cnt
return ::count


METHOD DocCounter:get_counter()
return ::count


METHOD DocCounter:to_str()
return  ::prefix + PADL(ALLTRIM(STR(::count, ::width)), ::width, ::fill) + ::suffix


RETURN

