/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

static cHostName := "localhost"
static nPort := 5433
static cUser := ""
static cPassWord := ""
static cDataBase := ""
static cDBFDataPath := ""
static cSchema := "fmk"
static cF18HomeDir := NIL
static cF18HomeRoot := NIL
static nLogHandle := NIL
static oServer := NIL
static cIniHomeRoot := NIL
static cIniHome := NIL
static cIniConfig := ".f18_config.ini"

function Main(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
local menuop := {}
local mnu_choice
local mnu_left := 2
local mnu_top := 2
local mnu_bottom := 23
local mnu_right := 65
local params

cHostName :=  ""
cSchema := ""
cDatabase := ""
cUser := ""
cPassWord := ""

set_f18_params( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )

public gDebug := 10
IF ( nLogHandle :=  FCREATE("F18.log") ) == -1
    ? "Cannot create log file: F18.log"
    QUIT
ENDIF

// ~/.F18/
cF18HomeRoot := get_f18_home_dir()

// konektuj se na server
oServer := init_f18_app(cHostName, cDatabase, cUser, cPassword, nPort, cSchema)

// ove parametre iscitaj iz INI-ja, oni mi trebaju za nastavak rada aplikacije...
params := hb_hash()
params["database"] := nil
params["user_name"] := nil

f18_ini_read("F18_server", @params, .t.)

cDatabase := params["database"]
cUser := params["user_name"]

// ~/.F18/empty38/
cF18HomeDir := get_f18_home_dir( cDatabase )

// menu opcije...
AADD( menuop, "1) FIN   # finansijsko poslovanje" )
AADD( menuop, "2) KALK  # robno-materijalno poslovanje")
AADD( menuop, "3) FAKT  # fakturisanje")
AADD( menuop, "4) ePDV  # elektronska evidencija PDV-a")
AADD( menuop, "5) LD    # obracun plata")
AADD( menuop, "6) RNAL  # radni nalozi")
AADD( menuop, "7) OS    # osnovna sredstva")
AADD( menuop, "8) SII   # sitan inventar")
AADD( menuop, "9) POS   # maloprodajna kasa")

do while .t.

	clear screen
 	mnu_choice := achoice( mnu_top, mnu_left, mnu_bottom, mnu_right, menuop, .t. )

 	do case
		case mnu_choice == 0
    		exit
		case mnu_choice == 1
			MainFin(cUser, cPassWord, p3, p4, p5, p6, p7)
		case mnu_choice == 2
			MainKalk(cUser, cPassWord, p3, p4, p5, p6, p7)
		case mnu_choice == 3
			MainFakt(cUser, cPassWord, p3, p4, p5, p6, p7)
		case mnu_choice == 4
			MainEPdv(cUser, cPassWord, p3, p4, p5, p6, p7)
		case mnu_choice == 5
			MainLd(cUser, cPassWord, p3, p4, p5, p6, p7)
		case mnu_choice == 6
			MainRnal(cUser, cPassWord, p3, p4, p5, p6, p7)
		case mnu_choice == 7
			MainOs(cUser, cPassWord, p3, p4, p5, p6, p7)
		case mnu_choice == 8
			//MainSii(cUser, cPassWord, p3, p4, p5, p6, p7)
		case mnu_choice == 9
			MainPos(cUser, cPassWord, p3, p4, p5, p6, p7)
 	endcase
 	loop
enddo

FCLOSE(nLogHandle)

return


// ---------------
// ~/.F18/
// ---------------
function my_home()
return cF18HomeDir

// root home dirketorij
function my_home_root()
return cF18HomeRoot

function pg_server()
return oServer

function pg_search_path()
local cPath := "fmk,public"
return cPath

function f18_user()
return cUser

function log_write(cMsg)
FWRITE(nLogHandle, cMsg + hb_eol())
return



