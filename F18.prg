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

function Main(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
local menuop := {}
local mnu_choice
local mnu_left := 2
local mnu_top := 2
local mnu_bottom := 23
local mnu_right := 65
local _server

set_f18_params( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11 )

public gDebug := 7

f18_init_app()

// menu opcije...
AADD( menuop, " 1) FIN   # finansijsko poslovanje" )
AADD( menuop, " 2) KALK  # robno-materijalno poslovanje")
AADD( menuop, " 3) FAKT  # fakturisanje")
AADD( menuop, " 4) ePDV  # elektronska evidencija PDV-a")
AADD( menuop, " 5) LD    # obracun plata")
AADD( menuop, " 6) RNAL  # radni nalozi")
AADD( menuop, " 7) OS    # osnovna sredstva")
AADD( menuop, " 8) SII   # sitan inventar")
AADD( menuop, " 9) POS   # maloprodajna kasa")
AADD( menuop, "10) MAT   # materijalno")
AADD( menuop, "11) VIRM  # virmani")
AADD( menuop, "--------------------------")
AADD( menuop, " P) Parametri aplikacije")
AADD( menuop, " R) ReLogin")
AADD( menuop, " W) Pregled F18.log-a")
AADD( menuop, " X) Erase / full synchro tabela")

do while .t.

	clear screen
 	mnu_choice := ACHOICE( mnu_top, mnu_left, mnu_bottom, mnu_right, menuop, .t. )

 	do case
		case mnu_choice == 0
    		exit
		case mnu_choice == 1
			MainFin(my_user(), "dummy", p3, p4, p5, p6, p7)
		case mnu_choice == 2
			MainKalk(my_user(), "dummy", p3, p4, p5, p6, p7)
		case mnu_choice == 3
			MainFakt(my_user(), "dummy", p3, p4, p5, p6, p7)
		case mnu_choice == 4
			MainEPdv(my_user(), "dummy", p3, p4, p5, p6, p7)
		case mnu_choice == 5
			MainLd(my_user(), "dummy", p3, p4, p5, p6, p7)
		case mnu_choice == 6
			MainRnal(my_user(), "dummy", p3, p4, p5, p6, p7)
		case mnu_choice == 7
			MainOs(my_user(), "dummy", p3, p4, p5, p6, p7)
		case mnu_choice == 8
			//MainSii(my_user(), "dummy", p3, p4, p5, p6, p7)
		case mnu_choice == 9
			MainPos(my_user(), "dummy", p3, p4, p5, p6, p7)
 		case mnu_choice == 10
			MainMat(my_user(), "dummy", p3, p4, p5, p6, p7)
       	case mnu_choice == 11
			MainVirm(my_user(), "dummy", p3, p4, p5, p6, p7)
        case mnu_choice == 13
            f18_app_parameters()
        case mnu_choice == 14
            relogin()
	 	case mnu_choice == 15
            view_log()
	 	case mnu_choice == 16
            full_table_synchro()
	endcase
 	loop
enddo

log_close()

return
