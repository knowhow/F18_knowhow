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

static cHostName := "localhost"
static nPort := 5433
static cUser := "admin"
static cPassWord := "admin"
static cDataBase := "demo_db1"
static cDBFDataPath := ""
static cSchema := "fmk"
static oServer := NIL
static cF18Home := NIL
static nLogHandle := NIL

function Main(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
local menuop := {}
local mnu_choice
local mnu_left := 2
local mnu_top := 2
local mnu_bottom := 23
local mnu_right := 65

? "hernad settings"
cHostName :=  "localhost"
nPort := 5432
cSchema := "fmk"
//cDatabase := "quick38"
cDatabase := "demo38"
cUser := "admin"
cPassWord := "admin"
? "------ brisi ovo na drugom racunaru !!!! ----"

set_f18_params( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )

public gDebug := 10
IF ( nLogHandle :=  FCREATE("F18.log") ) == -1
    ? "Cannot create log file: F18.log"
    QUIT
ENDIF

oServer := init_f18_app(cHostName, cDatabase, cUser, cPassword, nPort, cSchema)

// ~/.F18/
cF18HomeDir := get_f18_home_dir(cDatabase)


/*
PUBLIC gTabele:={ ;
  { F_SUBAN, "fin_suban"  ,  "fmk.fin_suban", "fmk.sem_ver_fin_suban"},;
  { F_KONTO, "konto"  ,  "fmk.konto", "fmk.sem_ver__konto"},;
  { F_PARTN, "partn"  ,  "fmk.partn", "fmk_sem_ver__partn"};
}
*/

clear screen

AADD( menuop, "1) FIN - finansijsko poslovanje")
AADD( menuop, "2) KALK - robno-materijalno poslovanje")
AADD( menuop, "3) FAKT - fakturisanje")
AADD( menuop, "4) ePDV - elektronska evidencija PDV-a")
AADD( menuop, "5) LD - obracun plata")

mnu_choice := achoice( mnu_top, mnu_left, mnu_bottom, mnu_right, menuop, .t. )

do case
	case mnu_choice == 0
		quit
	case mnu_choice == 1
		MainFin(cUser, cPassWord, p3, p4, p5, p6, p7)
endcase

FCLOSE(nLogHandle)

return

// ---------------
// ~/.F18/
// ---------------
function my_home()
return cF18HomeDir

function pg_server()
return oServer

function f18_user()
return cUser

function log_write(cMsg)
FWRITE(nLogHandle, cMsg + hb_eol())
return
