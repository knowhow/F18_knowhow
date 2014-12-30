/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"

function delete_with_rlock()

if rlock()
   DELETE
   dbrunlock()
   return .t.
else
   return .f.
endif

// --------------------------------------------
// --------------------------------------------
function ferase_dbf(tbl_name, _silent)
local _tmp, _odg

if _silent == NIL
  _silent := .f.
endif

if !_silent

    _odg := Pitanje(, "Izbrisati dbf tabelu " + tbl_name + " (L-quit) ?!", "N")

    if _odg == "L"
       log_write( "ferase_dbf quit: " + tbl_name, 3 )
       QUIT_1
    endif

    if _odg == "N"
       return .f.
    endif

endif

log_write( "ferase_dbf : " + tbl_name, 3 )
tbl_name := f18_ime_dbf(tbl_name)


if FILE(tbl_name)
   if FERASE(tbl_name) != 0
      log_write("ferase_dbf : " + tbl_name + "neuspjesno !", 3 )
      return .f.
   endif
endif

_tmp := STRTRAN(tbl_name, DBFEXT, INDEXEXT)
if FILE(_tmp)
   log_write("ferase_dbf, brisem: " + _tmp, 3 )
   if FERASE(_tmp) != 0
        log_write("ferase_dbf : " + _tmp + "neuspjesno !", 3 )
        return .f.
   endif
endif

_tmp := STRTRAN(tbl_name, DBFEXT, MEMOEXT)
if FILE(_tmp)
   log_write("ferase, brisem: " + _tmp, 3 )
   if FERASE(_tmp) != 0
        log_write("ferase_dbf : " + _tmp + "neuspjesno !", 3 )
        return .f.
   endif
endif

return .t.


/*!
 @function    NoviID_A
 @abstract    Novi ID - automatski
 @discussion  Za one koji ne pocinju iz pocetak, ID-ovi su dosadasnje sifre
              Program (radi prometnih datoteka) ove sifre ne smije dirati)
              Zato ce se nove sifre davati po kljucu Chr(246)+Chr(246) + sekvencijalni dio
*/
function NoviID_A()

local cPom , xRet

PushWA()

nCount:=1
do while .t.

set filter to
// pocisti filter
set order to tag "ID"
go bottom
if id>"99"
   seek chr(246)+chr(246)+chr(246)
   // chr(246) pokusaj
   skip -1
   if id < chr(246) + chr(246) + "9"
      cPom:=   str( val(substr(id,4))+nCount , len(id)-2 )
      xRet:= chr(246)+chr(246) + padl(  cPom , len(id)-2 ,"0")
   endif
else
  cPom:= str( val(id) + nCount , len(id) )
  xRet:= cPom
endif

++nCount
SEEK xRet
if !found()
  exit
endif

if nCount>100
  MsgBeep("Ne mogu da dodijelim sifru automatski ????")
  xRet:=""
  exit
endif

enddo

PopWa()

return xRet


function full_table_synchro()
local _sifra := SPACE(6), _full_table_name, _alias := PADR("PAROBR", 30)


Box( , 3, 60)
  @ m_x + 1, m_y + 2 SAY " Admin sifra :" GET  _sifra PICT "@!"
  @ m_x + 2, m_y + 2 SAY "Table alias  :"  GET _alias PICTURE "@S20"
  READ
BoxC()

if (LASTKEY() == K_ESC) .or. (UPPER(ALLTRIM(_sifra)) != "F18AD")
  MsgBeep("nista od ovog posla !")
  return .f.
endif

_alias := ALLTRIM(UPPER(_alias))

close all
_full_table_name := f18_ime_dbf(_alias)

if FILE(_full_table_name)
   ferase_dbf(_alias)
else
   MsgBeep("ove dbf tabele nema: " + _full_table_name)
endif

post_login()

return .t.


// ------------------------------------------------------
// open exclusive, open_index - otvoriti index
// ------------------------------------------------------
function reopen_shared(dbf_table, open_index)
return reopen_dbf(.f., dbf_table, open_index)

function reopen_exclusive(dbf_table, open_index)
return reopen_dbf(.t., dbf_table, open_index)

// ----------------------------------------------------
// ----------------------------------------------------
function reopen_dbf(excl, dbf_table, open_index)
local _a_dbf_rec
local _dbf

if open_index == NIL
  open_index := .t.
endif

_a_dbf_rec  := get_a_dbf_rec(dbf_table)

SELECT (_a_dbf_rec["wa"])
USE

_dbf := my_home() + _a_dbf_rec["table"]

// finalno otvaranje tabele
SELECT (_a_dbf_rec["wa"])
USE
dbUseArea( .f., DBFENGINE, _dbf, _a_dbf_rec["alias"], IIF(excl, .f., .t.) , .f.)

if open_index

   if FILE(ImeDbfCdx(_dbf))
       dbSetIndex(ImeDbfCDX(_dbf))
       return .t.
   endif
endif

return .t.

// ------------------------------------------------------
// zap, then open shared, open_index - otvori index
// ------------------------------------------------------
function reopen_exclusive_and_zap(dbf_table, open_index)
local _a_dbf_rec
local _dbf
local _idx


if open_index == NIL
  open_index := .t.
endif

_a_dbf_rec  := get_a_dbf_rec(dbf_table)

SELECT (_a_dbf_rec["wa"])
USE

_dbf := my_home() + _a_dbf_rec["table"]
_idx := ImeDbfCdx(_dbf)

// otvori ekskluzivno - 5 parametar .t. kada zelimo shared otvaranje
SET AUTOPEN OFF
dbUseArea( .f., DBFENGINE, _dbf, _a_dbf_rec["alias"], .f. , .f.)
// kod prvog otvaranja uvijek otvori index da i njega nuliram

if FILE(_idx)
  dbSetIndex(_idx)
endif

__dbZap()

return .t.
