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

function ferase_dbf(tbl_name)
local _tmp

tbl_name := f18_ime_dbf(tbl_name)

if FILE(tbl_name)
   if FERASE(tbl_name) != 0
      return .f.
   endif
endif

_tmp := STRTRAN(tbl_name, DBFEXT, INDEXEXT)
if FILE(_tmp)
   if FERASE(_tmp) != 0
        return .f.
   endif
endif

_tmp := STRTRAN(tbl_name, DBFEXT, MEMOEXT)
if FILE(_tmp)
   if FERASE(_tmp) != 0
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
