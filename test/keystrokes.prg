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

#include "f18.ch"
#include "f18_ver.ch"

static __keystrokes := {}
static __test_vars
static __task
static __test_tags := {}

//#define SLOW_TESTS

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

// -----------------------------------------
// posljednji test tag na stacku
// -----------------------------------------
function get_test_tag()
if LEN(__test_tags) > 0
   return __test_tags[ LEN(__test_tags) ]
else
   return "XX"
endif

// -------------------------------------------------
// stavke['keys'] := { { 'A', '<ENTER>' }, {'B', '<PGDN'}
// stavke['get'] := { "VAR_A", "VAR_B" }
// -------------------------------------------------
function gen_test_keystrokes(stavke)
local _ret := hb_hash()
local _kod, _i, _j, _num
local _keys
local _a_new

_keys := {}
for _i := 1 to LEN(stavke['get'])
   _a_new := { stavke['get'][_i] }
   to_keystrokes(stavke['keys'][_i], @_a_new)

   //if VALTYPE(_a_new[1] ) != "C"
   //   Alert(ALLTRIM(STR(_i)) + "/" + pp(_a_new[1]) + " ?!")
   //endif
   AADD(_keys, _a_new)
next

_ret["keys"] := _keys

return _ret


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
local _i, _j, _num, _key
 
for _i := 1 to LEN(a_polja)

   if VALTYPE(a_polja[_i]) == "B"

       AADD(a_init, a_polja[_i])
       loop

   elseif VALTYPE(a_polja[_i]) <> "C"
          _msg := "apolja clanovi moraju biti char" + pp(a_polja[_i])
          Alert(_msg)
          log_write(_msg, 2)
          QUIT
   endif

   DO CASE

     CASE LEFT(a_polja[_i], 8) == "<CTRLF9>"
        _key := LEFT(a_polja[_i], 8)
        _num := SUBSTR(a_polja[_i], 9)

     CASE LEFT(a_polja[_i], 7) == "<ENTER>" .or.;
          LEFT(a_polja[_i], 7) == "<CTRLT>" .or.;
          LEFT(a_polja[_i], 7) == "<CTRLN>" .or.;
          LEFT(a_polja[_i], 7) == "<CTRLP>"

        // <ENTER5> => 5 x enter
        _key := LEFT(a_polja[_i], 7)
        _num := SUBSTR(a_polja[_i], 8)
     CASE LEFT(a_polja[_i], 6) == "<DOWN>" .or. ;
          LEFT(a_polja[_i], 6) == "<PGDN>" .or. ;
          LEFT(a_polja[_i], 6) == "<HOME>" .or. ;
          LEFT(a_polja[_i], 6) == "<ALTA>" .or. ;
          LEFT(a_polja[_i], 6) == "<ALTP>" .or. ;
          LEFT(a_polja[_i], 6) == "<LEFT>"


        _key := LEFT(a_polja[_i], 6)
        _num := SUBSTR(a_polja[_i], 7)


     CASE LEFT(a_polja[_i], 5) == "<ESC>"
        // <ESC> => 1 x escape
        _key := LEFT(a_polja[_i], 5)
        _num := SUBSTR(a_polja[_i], 6)

     OTHERWISE
       AADD(a_init, a_polja[_i])
       loop
  END CASE

  if _num == ""
     _num := "1"
  endif


  for _j := 1 TO VAL(_num)
     do case

         CASE _key == "<CTRLF9>"
               AADD(a_init, K_CTRL_F9)

         CASE _key == "<ESC>"
               AADD(a_init, K_ESC)

         CASE _key == "<ENTER>"
               AADD(a_init, K_ENTER)

         CASE _key == "<LEFT>"
               AADD(a_init, K_LEFT)

         CASE _key == "<ALTA>"
               AADD(a_init, K_ALT_A)

         CASE _key == "<ALTP>"
               AADD(a_init, K_ALT_P)

         CASE _key == "<CTRLN>"
               AADD(a_init, K_CTRL_N)

         CASE _key == "<CTRLT>"
               AADD(a_init, K_CTRL_T)

         CASE _key == "<CTRLP>"
               AADD(a_init, K_CTRL_P)

         CASE _key == "<HOME>"
               AADD(a_init, K_HOME)

         CASE _key == "<PGDN>"
               AADD(a_init, K_PGDN)

         CASE _key == "<DOWN>"
               AADD(a_init, K_DOWN)

      end case
  next


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

   #ifdef SLOW_TESTS
        hb_IdleSleep(0.2)
   #endif
 
next

return .t.
