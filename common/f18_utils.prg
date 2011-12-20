/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"

function usex(cTable)
return my_use(cTable)


// --------------------------------------------------
// kreira direktorij ako ne postoji
// --------------------------------------------------
function f18_create_dir( location )
local _len
local _loc
local _create

_loc := location + "*.*"

#ifdef __PLATFORM__WINDOWS
	_loc := '"' + location + "*.*" + '"'
#endif

_len := ADIR( _loc )

if _len == 0

	_create := DIRMAKE( location )

	if _create <> 0
		log_write("problem sa kreiranjem direktorija: " + location )
	endif	

endif

return

// -------------------------
// -------------------------
function f18_ime_dbf(alias)
local _pos

alias := FILEBASE(alias)
_pos:=ASCAN(gaDBFs,  { |x|  x[2]==UPPER(alias)} )

if _pos == 0
   ? "ajjoooj nemas u gaDBFs ovu stavku:", alias
   ? "pretisni, al' ne pretis lonac"
   inkey(0)
   inkey(0)
   quit
endif

alias := my_home() + gaDBFs[_pos, 3] + "." + DBFEXT

return alias


// ---------------------------------------
// ---------------------------------------
function f18_help()
   
   ? "F18 parametri"
   ? "parametri"
   ? "-h hostname (default: localhost)"
   ? "-y port (default: 5432)"
   ? "-u user (default: root)"
   ? "-p password (default no password)"
   ? "-d name of database to use"
   ? "-e schema (default: public)"
   ? "-t fmk tables path"
   ? ""

RETURN

/* --------------------------
 setup ulazne parametre F18
 -------------------------- */

function set_f18_params()
local _i := 1

// setuj ulazne parametre
cParams := ""

DO WHILE _i <= PCount()

    // ucitaj parametar
    cTok := hb_PValue( _i++ )
     
    
    DO CASE

      CASE cTok == "--test"
           test_mode(.t.)
           
      CASE cTok == "--help"
          f18_help()
          QUIT

      CASE cTok == "-h"
         cHostName := hb_PValue( _i++ )
         cParams += SPACE(1) + "hostname=" + cHostName

      CASE cTok == "-y"
         nPort := Val( hb_PValue( _i++ ) )
         cParams += SPACE(1) + "port=" + ALLTRIM(STR(nPort))

      CASE cTok == "-d"
         cDataBase := hb_PValue( _i++ )
         cParams += SPACE(1) + "database=" + cDatabase

      CASE cTok == "-u"
         cUser := hb_PValue( _i++ )
         cParams += SPACE(1) + "user=" + cUser

      CASE cTok == "-p"
         cPassWord := hb_PValue( _i++ )
         cParams += SPACE(1) + "password=" + cPassword

      CASE cTok == "-t"
         cDBFDataPath := hb_PValue( _i++ )
         cParams += SPACE(1) + "dbf data path=" + cDBFDataPath

      CASE cTok == "-e"
         cSchema := hb_PValue( _i++ )
         cParams += SPACE(1) + "schema=" + cSchema
    ENDCASE

ENDDO

return
