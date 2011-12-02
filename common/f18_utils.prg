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


// ---------------------------
// ~/.F18/bringout1
// ~/.F18/rg1
// ~/.F18/test
// ---------------------------
function get_f18_home_dir(cDatabase)
local cHome

#ifdef __PLATFORM__WINDOWS
  cHome := hb_DirSepAdd( GetEnv( "USERPROFILE" ) ) 
#else
  cHome := hb_DirSepAdd( GetEnv( "HOME" ) ) 
#endif

cHome := hb_DirSepAdd(cHome + ".f18")

f18_create_dir( cHome )

if cDatabase <> nil
 	
	cHome := hb_DirSepAdd(cHome + cDatabase)

	f18_create_dir( cHome )

endif

return cHome



// --------------------------------------------------
// kreira direktorij ako ne postoji
// --------------------------------------------------
function f18_create_dir( location )
local _len
local _loc
local _create

_loc := location

#ifdef __PLATFORM__WINDOWS
	_loc := '"' + location + '"'
#endif

_len := ADIR( _loc + "*.*" )

if _len == 0

	_create := DIRMAKE( location )

	if _create <> 0
		log_write("problem sa kreiranjem direktorija: " + location )
	endif	

endif

return




function f18_ime_dbf(cImeDbf)
local nPos

cImeDbf:=ToUnix(cImeDbf)
cImeDbf := FILEBASE(cImeDbf)
nPos:=ASCAN(gaDBFs,  { |x|  x[2]==UPPER(cImeDbf)} )

if nPos == 0
   ? "ajjoooj nemas u gaDBFs ovu stavku:", cImeDBF
   //QUIT
endif

cImeDbf := my_home() + gaDBFs[nPos, 3] + ".dbf"

return cImeDbf


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

//IF PCount() < 7
//    help()
//    QUIT
//ENDIF

i := 1

// setuj ulazne parametre
cParams := ""

DO WHILE i <= PCount()

    // ucitaj parametar
    cTok := hb_PValue( i++ )
     
    
    DO CASE

      CASE cTok == "--help"
          f18_help()
          QUIT
      CASE cTok == "-h"
         cHostName := hb_PValue( i++ )
         cParams += SPACE(1) + "hostname=" + cHostName
      CASE cTok == "-y"
         nPort := Val( hb_PValue( i++ ) )
         cParams += SPACE(1) + "port=" + ALLTRIM(STR(nPort))
      CASE cTok == "-d"
         cDataBase := hb_PValue( i++ )
         cParams += SPACE(1) + "database=" + cDatabase
      CASE cTok == "-u"
         cUser := hb_PValue( i++ )
         cParams += SPACE(1) + "user=" + cUser
      CASE cTok == "-p"
         cPassWord := hb_PValue( i++ )
         cParams += SPACE(1) + "password=" + cPassword
      CASE cTok == "-t"
         cDBFDataPath := hb_PValue( i++ )
         cParams += SPACE(1) + "dbf data path=" + cDBFDataPath
      CASE cTok == "-e"
         cSchema := hb_PValue( i++ )
         cParams += SPACE(1) + "schema=" + cSchema
      OTHERWISE
         //help()
         //QUIT
    ENDCASE

ENDDO

// ispisi parametre
? "Ulazni parametri:"
? cParams

return
