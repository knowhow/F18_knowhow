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

#include "fmk.ch"
#include "f18_ver.ch"

static __keystrokes := {}
static __test_vars
static __task
static __test_tags := {}

// jedan poziv test_keystroke treba samo jednu sekvencu poslati 
static __keystroke_step 


// --- keystroke lib functions --

// na osnovu ovoga mozemo dva razlicita poziva funkcije Pitanje() razluciti
// a to nam treba kod keystrokes testova
function push_test_tag(tag)

if tag == NIL
  tag := "NIL"
endif

log_write("push_test_tag:" + tag, 3) 
AADD(__test_tags, tag)

return


function pop_test_tag()
if LEN(__test_tags) > 0
  log_write("pop_test_tag:" + get_test_tag(), 3) 
   ADEL(__test_tags, LEN(__test_tags))
endif
return

// posljednji test tag na stacku
function get_test_tag()
if LEN(__test_tags) > 0
   return __test_tags[ LEN(__test_tags) ]
else
   return "XX"
endif


// --------------------------------------
// --------------------------------------
function test_var(key, value)

if __test_vars == NIL
 __test_vars := hb_hash()
endif

if value != NIL
  __test_vars[key] := value
endif

return __test_vars[key]



function stop_keystrokes_task()
   HB_IDLEDEL(__task)
return


// --------------------------------------------
// --------------------------------------------
function test_procedure_with_keystrokes( b_proc, h_keystrokes)
local _task, _var_key, _key_test, _key_tests := {}
local _tmp
local _i := 1
local _cnt := 0


// key sekvenca koju treba izvrsiti
AADD(_key_tests, h_keystrokes)

for each _key_test IN _key_tests 

   __keystrokes := _key_test["keys"]
   __keystroke_step := 1

   CLEAR TYPEAHEAD
   SET CONFIRM ON
   __task := HB_IDLEADD( {|| SetPos(MAXROW()-2, MAXCOL()-10),  DispOut(_cnt++), test_keystrokes()} )

   EVAL(b_proc)

   log_write("uklanjam idleadd task", 3)
   stop_keystrokes_task()


  _i++
next


return

// ----------------------------------
// _a_init := { "WID" }
// to_keystrokes({"99", "<ENTER>2"}, @_a_init)
// ----------------------------------
function to_keystrokes(a_polja, a_init)
local _i, _j, _num
 
for _i := 1 to LEN(a_polja)
   DO CASE
     CASE LEFT(a_polja[_i], 7) == "<ENTER>"
        // <ENTER5> => 5 x enter
        _num := SUBSTR(a_polja[_i], 8)
        if _num == ""
           _num := "1"
        endif

        for _j := 1 TO VAL(_num)
          AADD(a_init, K_ENTER)
        next
 
     CASE LEFT(a_polja[_i], 6) == "<PGDN>"
        _num := SUBSTR(a_polja[_i], 7)
        // <PGDN> => 1 x enter
        if _num == ""
             _num := "1"
        endif

        for _j := 1 TO VAL(_num)
          AADD(a_init, K_PGDN)
        next 
 
     CASE LEFT(a_polja[_i], 6) == "<HOME>"
        _num := SUBSTR(a_polja[_i], 7)
        // <PGDN> => 1 x enter
        if _num == ""
             _num := "1"
        endif

        for _j := 1 TO VAL(_num)
          AADD(a_init, K_HOME)
        next 
 
     CASE LEFT(a_polja[_i], 5) == "<ESC>"
        _num := SUBSTR(a_polja[_i], 6)
        // <ESC> => 1 x escape
        if _num == ""
             _num := "1"
        endif

        for _j := 1 TO VAL(_num)
          AADD(a_init, K_ESC)
        next 

     OTHERWISE
       AADD(a_init, a_polja[_i]) 
  END CASE
next

return a_init

// --------------------------------------
// --------------------------------------
function test_keystrokes()
local _var_name
local _i, _j, _expected_var_name
local _buffer, _current_tag, _tag

log_write("START test_keystrokes: " + ALLTRIM(STR(__keystroke_step)), 3)

for _i := 1 to LEN(__keystrokes)

    // ovo ne kontam
    if (__keystroke_step) <> _i
         log_write("test_keystrokes loop" + ALLTRIM(STR(_i)), 3)

         if _i == LEN(__keystrokes)
               stop_keystrokes_task()
         endif
         loop
    endif 
    
    _expected_var_name := __keystrokes[_i, 1]

    if VALTYPE(_expected_var_name) == "B"
             // npr. { {|| !eof()},  {|| delete_with_rlock()},  {|| log_write("ne treba nista brisati", 2)} }
          
             // izvrsi trazeni izraz
             _ret := EVAL(_expected_var_name)
             if _ret 
                _bl2 := __keystrokes[_i, 2]
            else

                _bl2 := __keystrokes[_i, 3]
             endif

             if (VALTYPE(_bl2) == "B")
                     EVAL(_bl2)

             elseif (VALTYPE(_bl2) == "A")

                    // moze biti array tipki
                    _buffer := {}
                    for _j := 1 TO LEN(_bl2)
                        AADD(_buffer, _bl2[_j])
                    next
                    put_to_keyboard_buffer(_buffer)

              else
                  Alert(" bl 2 mora biti B ili A")   
              endif
 
           
             __keystroke_step ++
             loop
     endif

     if VALTYPE(_expected_var_name) == "C"

           _expected_var_name := UPPER(_expected_var_name)

           if LEFT(_expected_var_name, 1) == "#"

                // gledaj test tagove
                _tag := SUBSTR(_expected_var_name, 2)
                _current_tag := get_test_tag()
                log_write("test tag current" + pp(_current_tag) + " expected tag: " + pp(_tag), 3)
                if _tag != _current_tag
                        log_write("test tag current <> expected", 3)
                        exit
                endif


           elseif  _expected_var_name == "DBEDIT" 
              if  PROCNAME(3) == "OBJDBEDIT"
                 // nalazimo se u objdbeditu
                 // to i zelimo
                 log_write("DBEDIT step: " + ALLTRIM(STR(_i)), 3)
               else
                 log_write("nismo se jos vratili u DBEDIT: " + ALLTRIM(STR(_i)) + "procname 4-1:" + PROCNAME(4) + " / " +  PROCNAME(3) +" / " + PROCNAME(2) + "/" + PROCNAME(1), 3)
                  exit
               endif
           else  
               _var_name := READVAR()
               log_write("READVAR: " + _var_name + " expected_var_name: " + _expected_var_name + "procname 6-3:" + PROCNAME(6) + " / " +  PROCNAME(5) +" / " + PROCNAME(4) + "/" + PROCNAME(3), 3)

               if (_var_name != _expected_var_name)
                        // ako tekuca get varijabla nije identicna ocekivanoj, ne salji keytroke
                        log_write("READVAR<>expected - loop", 3)
                        exit
               endif

           endif
      endif

     _buffer := {}
     for _j := 2 TO LEN(__keystrokes[_i])
           AADD(_buffer, __keystrokes[_i, _j])
     next
     log_write("test step " + pp(_i) + "buffer " + pp(_buffer), 3 )
     put_to_keyboard_buffer(_buffer)

     __keystroke_step ++


next


return .t.


static function put_to_keyboard_buffer(buffer)
local _i

//CLEAR TYPEAHEAD
for _i := 1 to LEN(buffer)

   if VALTYPE(buffer[_i]) == "C" .or.  VALTYPE(buffer[_i]) == "N"
        HB_KEYPUT(buffer[_i])

   elseif VALTYPE(buffer[_i]) == "B"
        // ako je kodni blok izvrsi ga
        EVAL(buffer[_i])
   else
        Alert("buffer tip: "  + VALTYPE(buffer[_i]) + " ?!")
   endif

next

return .t.
