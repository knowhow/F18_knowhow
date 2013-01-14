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

#include "fmk.ch"

#include "hbclass.ch"
#include "common.ch"

CREATE CLASS FaktDokumentColumn FROM TBColumn

   DATA   browse
   DATA   col_name
   DATA   field_num

   MESSAGE  Block METHOD Block()  

   METHOD   New()

ENDCLASS

CREATE CLASS BrowseFaktDokumenti FROM TBrowse

   DATA     fakt_dokumenti
   DATA     tekuci_item
   DATA     tekuci_red
   
   METHOD   New(top, left, bottom, right, fakt_dokumenti) 
   //METHOD   EditField()             
   METHOD   browse()

   METHOD   default_keyboard_hook(key)      
   METHOD   keyboard_hook(key)      

  PROTECTED:
    METHOD   skipper(s)
ENDCLASS


METHOD FaktDokumentColumn:New(col_name, browse, block)
local _header, _width

SWITCH col_name

    CASE "datdok"
      _header := "Dat.Dok"
      _width := 12
      EXIT
    CASE "neto"
      _header := "Neto vr."
      _width := 28
      EXIT
    CASE "mark"
      _header := "M"
      _width := 1
 
    OTHERWISE
       _header := ""
       _width  := 1

END

::col_name := col_name

super:New(_header, block)
::browse     := browse
::tekuci_red := 1
RETURN Self


METHOD FaktDokumentColumn:Block()
local _val, _item

_item := ::browse:fakt_dokumenti[::browse:tekuci_red]

SWITCH (::col_name)

   CASE  "datdok"
        _val := ::item:info["datdok"]

   CASE  "neto"
        _val := ::item:info["neto_vrijednost"]

   CASE  "broj"
        _val := ::item:broj()

END

// chr(34) je dupli navodnik
_val := Chr(34) + StrTran(_val, Chr(34), Chr(34) + "+Chr(34)+" + Chr(34) ) + Chr(34)

RETURN hb_macroBlock(_val)


METHOD BrowseFaktDokumenti:New(top, left, bottom, right, fakt_dokumenti) 
LOCAL _i, _item, _col


super:New( top, left, bottom, right )

::fakt_dokumenti := fakt_dokumenti

::SkipBlock     := {|n| ::tekuci_item := ::skipper(@n), n }
::GoBottomBlock := {||  ::tekuci_item := ::fakt_dokumenti[::fakt_dokumenti:count], 1 }
::GoTopBlock    := {||  ::tekuci_item := ::fakt_dokumenti[1], 1 }

_col := FaktDokumentColumn():New("datdok", self, NIL)
::AddColumn(_col)

_col := FaktDokumentColumn():New("broj", self, NIL)
::AddColumn(_col)

_col := FaktDokumentColumn():New("neto", self, NIL)
::AddColumn(_col)

RETURN Self


METHOD BrowseFaktDokumenti:skipper(s)

if (s > 0) .and. (s + ::tekuci_red) > ::fakt_dokumenti:count
    s := fakt_dokumenti:count
endif

if (s < 0) .and. (s + ::tekuci_red) <  1
    s := 1 - ::tekuci_red  
endif

RETURN ::fakt_dokumenti[s]

// --------------------------------------------
// --------------------------------------------
METHOD BrowseFaktDokumenti:browse()
local exit_keys, _vrti := .t., _k

IF ! ISARRAY( exit_keys )
   exit_keys := { K_ESC }
ENDIF

DO WHILE _vrti

   DO WHILE !::Stabilize() .AND. NextKey() == 0
   ENDDO

   _k := Inkey(0)

    IF AScan(exit_keys, _k) > 0
       _vrti := .f.
       LOOP
    ENDIF

    ::default_keyboard_hook(_k)
ENDDO

RETURN self

// --------------------------------------------------
// --------------------------------------------------
METHOD BrowseFaktDokumenti:default_keyboard_hook(key)

SWITCH (key)
        CASE K_DOWN
           ::down()

        CASE K_PGDN
           ::pageDown()

        CASE K_CTRL_PGDN
           ::goBottom()

        CASE K_UP
            ::up()

        CASE K_PGUP
            ::pageUp()

        CASE K_CTRL_PGUP
            ::goTop()

        CASE K_RIGHT
             ::right()

        CASE K_LEFT
             ::left()

        CASE  K_HOME
             ::home()

        CASE K_END
             ::end()

        CASE K_CTRL_LEFT
            ::panLeft()

        CASE K_CTRL_RIGHT
            ::panRight()

        CASE K_CTRL_HOME
            ::panHome()

        CASE K_CTRL_END
             ::panEnd()

        OTHERWISE
             ::keyboard_hook(key)
END

RETURN self


METHOD BrowseFaktDokumenti:keyboard_hook(key)
   HB_SYMBOL_UNUSED(key)
RETURN Self



