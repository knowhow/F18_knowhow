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

#include "hbclass.ch"
#include "common.ch"
#include "f18_separator.ch"

// ---------------------------------------
// ---------------------------------------

CREATE CLASS BrowseFaktDokumenti INHERIT TBrowse

   DATA     fakt_dokumenti
   DATA     tekuci_item
   DATA     tekuci_red   INIT 1
   
   METHOD   New(top, left, bottom, right, fakt_dokumenti) 
   METHOD   set_kolone_markiraj_otpremnice()

   METHOD   browse()

   METHOD   default_keyboard_hook(key)      
   METHOD   keyboard_hook(key)      

  PROTECTED:
    METHOD   skipper(s)
ENDCLASS


METHOD BrowseFaktDokumenti:New(top, left, bottom, right, fakt_dokumenti) 
LOCAL _i, _item, _col

::super:New( top, left, bottom, right )

::fakt_dokumenti := fakt_dokumenti

::SkipBlock     := {|n| ::tekuci_item := ::skipper(@n), n }
::GoBottomBlock := {||  ::tekuci_item := IIF(::fakt_dokumenti:count == 0, NIL, ::fakt_dokumenti:items[::fakt_dokumenti:count]), 1 }
::GoTopBlock    := {||  ::tekuci_item := IIF(::fakt_dokumenti:count == 0, NIL, ::fakt_dokumenti:items[1]), 1 }

::headSep := BROWSE_HEAD_SEP 
::colsep :=  BROWSE_COL_SEP
  
RETURN Self


METHOD BrowseFaktDokumenti:set_kolone_markiraj_otpremnice()
local _col

_col := FaktColumn():New("datdok", self, NIL)
::AddColumn(_col)

_col := FaktColumn():New("broj", self, NIL)
::AddColumn(_col)

_col := FaktColumn():New("neto", self, NIL)
::AddColumn(_col)

_col := FaktColumn():New("mark", self, NIL)
::AddColumn(_col)

return .t.

METHOD BrowseFaktDokumenti:skipper(s)

::tekuci_red += s

if ::tekuci_red > ::fakt_dokumenti:count 
   s -= ::tekuci_red - ::fakt_dokumenti:count
   ::tekuci_red := ::fakt_dokumenti:count
endif

if ::tekuci_red < 1
   s +=  1 - ::tekuci_red
   ::tekuci_red := 1
endif

return IIF(::fakt_dokumenti:count == 0, NIL, ::fakt_dokumenti:items[::tekuci_red])


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
    IF ASCAN(exit_keys, _k) > 0
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
           exit
        CASE K_PGDN
           ::pageDown()
           exit
        CASE K_CTRL_PGDN
           ::goBottom()
           exit
        CASE K_UP
            ::up()
            exit
        CASE K_PGUP
            ::pageUp()
            exit
        CASE K_CTRL_PGUP
            ::goTop()
            exit
        CASE K_RIGHT
             ::right()
             exit
        CASE K_LEFT
             ::left()
             exit
        CASE  K_HOME
             ::home()
             exit
        CASE K_END
             ::end()
             exit
        CASE K_CTRL_LEFT
            ::panLeft()
            exit
        CASE K_CTRL_RIGHT
            ::panRight()
            exit
        CASE K_CTRL_HOME
            ::panHome()
            exit
        CASE K_CTRL_END
             ::panEnd()
             exit
        OTHERWISE
             ::keyboard_hook(key)
END

RETURN self


METHOD BrowseFaktDokumenti:keyboard_hook(key)
   
   if Chr(key) == " "
      Beep(1)
      if ::tekuci_item == NIL
         return self
      endif

      if ::tekuci_item:mark
         ::tekuci_item:mark := .f.
      else
         ::tekuci_item:mark := .t.
      endif
      ::RefreshAll()
   endif
     
RETURN self
