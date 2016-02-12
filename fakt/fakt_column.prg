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


CREATE CLASS FaktColumn INHERIT TBColumn

   DATA   browse
   DATA   col_name
   DATA   field_num

   MESSAGE  Block METHOD Block()

   METHOD   New()

ENDCLASS

METHOD FaktColumn:New(col_name, browse, block)
local _header, _width

SWITCH col_name

    CASE "datdok"
      _width := 12
      _header := PADC("Dat.dok", _width)
      EXIT

    CASE "neto"
      _width := 18
      _header := PADC("Neto vr.", _width)
      EXIT

    CASE "broj"
       _width := 14
       _header := PADC("Broj dok.", _width)
       EXIT

    CASE "mark"
       _width := 3
       _header := PADC("M", _width)
       EXIT

    OTHERWISE
       _header := "?" + col_name + "?"
       _width  :=  10

END

::width := _width

::col_name := col_name

::super:New(_header, block)
::browse     := browse
RETURN Self


METHOD FaktColumn:Block()
local _val, _item

_item  := ::browse:tekuci_item

if _item == NIL
   _val = ""
else
   SWITCH (::col_name)

	   CASE  "datdok"
		_val := _item:info["datdok"]
                exit
	   CASE  "neto"
		_val := STR(_item:info["neto_vrijednost"], 12, 2)
                exit
	   CASE  "broj"
		_val := _item:broj()
                exit
           CASE  "mark"
                _val := IIF(_item:mark, "*", " ")
                exit
   END
endif

// chr(34) je dupli navodnik
_val := Chr(34) + StrTran(to_str(_val), Chr(34), Chr(34) + "+Chr(34)+" + Chr(34) ) + Chr(34)

RETURN hb_macroBlock(_val)
