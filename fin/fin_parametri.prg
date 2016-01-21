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

#include "f18.ch"

static __fin_params := NIL

// -----------------------------------
// meni parametara
// -----------------------------------
function mnu_fin_params()
local _opc := {}
local _opcexe := {}
local _izbor := 1

fin_read_params()

AADD(_opc, "1. osnovni parametri                        ")
AADD(_opcexe, {|| org_params() })
AADD(_opc, "2. parametri rada ")
AADD(_opcexe, {|| par_obrada() })
AADD(_opc, "3. parametri izgleda ")
AADD(_opcexe, {|| par_izgled() })

f18_menu( "fin_param", .f., _izbor, _opc, _opcexe )

return



// ---------------------------------------
// parametri obrade naloga
// ---------------------------------------
static function par_obrada()
local nX := 1
local _k1 := fin_k1(), _k2 := fin_k2(), _k3 := fin_k3(), _k4 := fin_k4()
local _tip_dok := fin_tip_dokumenta()

Box(, 24, 70 )

	set cursor on
 	
 	@ m_x + nX, m_y + 2 SAY "*********************** Unos naloga:"

	nX := nX + 2
	
 	@ m_x + nX, m_y + 2 SAY "Unos datuma naloga? (D/N):" GET gDatNal valid gDatNal $ "DN" pict "@!"

	@ m_x + nX, col() + 2 SAY "Unos datuma valute? (D/N):" GET gDatVal valid gDatVal $ "DN" pict "@!"
	++ nX

	@ m_x + nX, m_y + 2 SAY "Unos radnih jedinica ? (D/N)" GET gRJ valid gRj $ "DN" pict "@!"
	@ m_x + nX, col() + 1 SAY "Unos tipa dokumenta ? (D/N)" GET _tip_dok valid _tip_dok $ "DN" pict "@!"
	++ nX
	
 	@ m_x + nX, m_y + 2 SAY "Unos ekonomskih kategorija? (D/N)" GET gTroskovi valid gTroskovi $ "DN" pict "@!"
	++ nX

 	@ m_x + nX, m_y + 2 SAY "Unos polja K1 - K4 ? (D/N)"
 	++ nX
	
    read_dn_parametar("K1", m_x + nX, m_y + 2, @_k1)
    read_dn_parametar("K2", m_x + nX, col() + 2, @_k2)
    read_dn_parametar("K3", m_x + nX, col() + 2, @_k3)
    read_dn_parametar("K4", m_x + nX, col() + 2, @_k4)

	nX := nX + 2

	@ m_x + nX, m_y + 2 SAY "Brojac naloga: 1 - (firma,vn,brnal), 2 - (firma,brnal)" GET gBrojac valid gbrojac $ "12"
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Limit za unos konta? (D/N):" GET gKtoLimit pict "@!" valid gKtoLimit $ "DN"
 	
	@ m_x + nX, col() + 2 SAY "-> vrijednost limita:" GET gnKtoLimit pict "9" WHEN gKtoLimit == "D"
	

	nX := nX + 2
	
	@ m_x + nX, m_y + 2 SAY "********************** Obrada naloga:"

	nX := nX + 2
	
	@ m_x + nX, m_y + 2 SAY "Neophodna ravoteza naloga? (D/N):" GET gRavnot valid gRavnot $ "DN" pict "@!"
	
 	++ nX
	
 	@ m_x + nX, m_y + 2 SAY "Onemoguciti povrat azuriranog naloga u pripremu? (D/N)" GET gBezVracanja VALID gBezVracanja $ "DN" pict "@!"
 		
	++ nX

 	@ m_x + nX, m_y + 2  SAY "Limit za otvorene stavke ("+ValDomaca()+")" GET gnLOst pict "99999.99"
	
	++ nX 
	
	@ m_x + nX, m_y + 2 SAY "Koristiti konta-izuzetke u FIN-BUDZET-u? (D/N)" GET gBuIz VALID gBuIz$"DN" PICT "@!"

	++ nX 
	
	@ m_x + nX, m_y + 2 SAY "Pri pomoci asistenta provjeri i spoji duple uplate za partn.? (D/N)" GET gOAsDuPartn VALID gOAsDuPartn $ "DN" PICT "@!"

	++ nX

	@ m_x + nX, m_y + 2 SAY "Timeout kod azuriranja naloga (sec.):" ;
		GET gAzurTimeout PICT "99999"
  	
	nX := nX + 2

	@ m_x + nX, m_y + 2 SAY "********************** Ostalo:"
	
  	nX := nX + 2
	
 	@ m_x + nX, m_y + 2 SAY "Automatski pozovi kontrolu zbira datoteke svakih" GET gnKZBDana PICT "999" valid (gnKZBDana <= 999 .and. gnKZBDana >= 0)

	@ m_x + nX, col() + 1 SAY "dana"

    ++ nX

 	@ m_x + nX, m_y + 2 SAY "Prikaz stanja konta kod knjizenja naloga" GET g_knjiz_help PICT "@!" ;
            VALID g_knjiz_help $ "DN"

	read

BoxC()

if LastKey() <> K_ESC

	fin_write_params()
    fin_k1(_k1)
    fin_k2(_k2)
    fin_k3(_k3)
    fin_k4(_k4)
    fin_tip_dokumenta( _tip_dok )

endif

return




// ---------------------------------------
// parametri izgleda dokumenata itd...
// ---------------------------------------
static function par_izgled()
local nX := 1

Box(, 15,70)

	set cursor on

 	@ m_x + nX, m_y + 2 SAY "*************** Varijante izgleda i prikaza:"

	nX := nX + 2
	
 	@ m_x + nX, m_y + 2 SAY "Potpis na kraju naloga? (D/N):" GET gPotpis valid gPotpis $ "DN"  pict "@!"
 	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Varijanta izvjestaja 0-dvovalutno 1-jednovalutno " GET gVar1 VALID gVar1 $ "01"
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "Prikaz iznosa u " + ValPomocna() GET gPicDEM
 	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Prikaz iznosa u " + ValDomaca() GET gPicBHD

	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Sintetika i analitika se kreiraju u izvjestajima? (D/N)" GET gSAKrIz valid gSAKrIz $ "DN" PICT "@!"
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "U subanalitici prikazati nazive i konta i partnera? (D/N)" GET gVSubOp valid gVSubOp$"DN" PICTURE "@!"
 	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Razmak izmedju kartica - br.redova (99-uvijek nova stranica): " GET gnRazRed PICTURE "99"
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Dugi uslov za firmu i RJ u suban.specif.? (D/N)" GET gDUFRJ valid gDUFRJ $ "DN" pict "@!"
 	
	read
BoxC()

if LastKey() <> K_ESC
	fin_write_params()
endif

return


// ----------------------------------
// citanje parametara 
// ----------------------------------
function fin_read_params()

// globalni parmetri


gDatval := fetch_metric( "fin_evidencija_datum_valute", nil, gDatVal )
gDatnal := fetch_metric( "fin_evidencija_datum_naloga", nil, gDatNal )
gRj := fetch_metric( "fin_evidencija_radne_jedinice", nil, gRj )
gTroskovi := fetch_metric( "fin_evidencija_ekonomske_kategorije", nil, gTroskovi )
gRavnot := fetch_metric( "fin_unos_ravnoteza_naloga", nil, gRavnot )
gBrojac := fetch_metric( "fin_vrsta_brojaca_naloga", nil, gBrojac )
gnLOst := fetch_metric( "fin_limit_otvorene_stavke", nil, gnLOst )
gDUFRJ := fetch_metric( "fin_dugi_uslov_za_rj", nil, gDUFRJ )
gBezVracanja := fetch_metric("fin_zabrana_povrata_naloga", nil, gBezVracanja )
gBuIz := fetch_metric("fin_budzet_konta_izuzeci", nil, gBuIz )
gPicDem := fetch_metric("fin_picdem", nil, gPicDEM )
gPicBHD := fetch_metric("fin_picbhd", nil, gPicBHD )
gVar1 := fetch_metric("fin_izvjestaji_jednovalutno", nil, gVar1 )
gSaKrIz := fetch_metric("fin_kreiranje_sintetike", nil, gSaKrIz )
gnRazRed := fetch_metric("fin_razmak_izmedju_kartica", nil, gnRazRed )
gVSubOp := fetch_metric("fin_subanalitika_prikaz_naziv_konto_partner", nil, gVSubOp )
gOAsDuPartn := fetch_metric("fin_asistent_spoji_duple_uplate", nil, gOAsDuPartn )
gAzurTimeOut := fetch_metric("fin_azuriranje_timeout", nil, gAzurTimeOut )

// po user-u parametri
gPotpis := fetch_metric( "fin_potpis_na_kraju_naloga", my_user(), gPotpis )
gnKZBDana := fetch_metric("fin_automatska_kontrola_zbira", my_user(), gnKZBDana )
gnLMONI := fetch_metric( "fin_kosuljice_lijeva_margina", my_user(), gnLMONI )
gKtoLimit := fetch_metric("fin_unos_limit_konto", my_user(), gKtoLimit )
gnKtoLimit := fetch_metric("fin_unos_limit_konto_iznos", my_user(), gnKtoLimit )
g_knjiz_help := fetch_metric("fin_pomoc_sa_unosom", my_user(), g_knjiz_help )

fin_params(.t.)

gVar1 := PADR( gVar1, 1 )

return


// -------------------------------
// snimanje parametara
// -------------------------------
function fin_write_params()

// globalni parametri
set_metric( "fin_evidencija_datum_valute", nil, gDatVal )
set_metric( "fin_evidencija_datum_naloga", nil, gDatNal )
set_metric( "fin_evidencija_radne_jedinice", nil, gRj )
set_metric( "fin_evidencija_ekonomske_kategorije", nil, gTroskovi )
set_metric( "fin_unos_ravnoteza_naloga", nil, gRavnot )
set_metric( "fin_vrsta_brojaca_naloga", nil, gBrojac )
set_metric( "fin_limit_otvorene_stavke", nil, gnLOst )
set_metric( "fin_dugi_uslov_za_rj", nil, gDUFRJ )
set_metric( "fin_zabrana_povrata_naloga", nil, gBezVracanja )
set_metric( "fin_budzet_konta_izuzeci", nil, gBuIz )
set_metric( "fin_picdem", nil, gPicDEM )
set_metric( "fin_picbhd", nil, gPicBHD )
set_metric( "fin_izvjestaji_jednovalutno", nil, gVar1 )
set_metric( "fin_kreiranje_sintetike", nil, gSaKrIz )
set_metric( "fin_razmak_izmedju_kartica", nil, gnRazRed )
set_metric( "fin_subanalitika_prikaz_naziv_konto_partner", nil, gVSubOp )
set_metric( "fin_asistent_spoji_duple_uplate", nil, gOAsDuPartn )
set_metric( "fin_azuriranje_timeout", nil, gAzurTimeOut )

// po user-u
set_metric( "fin_unos_limit_konto", my_user(), gKtoLimit )
set_metric( "fin_unos_limit_konto_iznos", my_user(), gnKtoLimit )
set_metric( "fin_automatska_kontrola_zbira", my_user(), gnKZBDana )
set_metric( "fin_potpis_na_kraju_naloga", my_user(), gPotpis )
set_metric( "fin_kosuljice_lijeva_margina", my_user(), gnLMONI )
set_metric( "fin_pomoc_sa_unosom", my_user(), g_knjiz_help )

return


// ---------------------------------------
// ---------------------------------------
function fin_params(read)

if read == NIL
  read := .f.
endif


if read .or. __fin_params == NIL

    __fin_params := hb_hash()
    __fin_params["fin_k1"] := IIF(fin_k1() == "D", .t., .f.)
    __fin_params["fin_k2"] := IIF(fin_k2() == "D", .t., .f.)
    __fin_params["fin_k3"] := IIF(fin_k3() == "D", .t., .f.)
    __fin_params["fin_k4"] := IIF(fin_k4() == "D", .t., .f.)
    __fin_params["fin_tip_dokumenta"] := IIF(fin_tip_dokumenta() == "D", .t., .f. )

endif

return __fin_params



// ----------------------------------------------
// k1, k2, k3, k4
// ----------------------------------------------
function fin_k1(value)
get_set_global_param("fin_unos_k1", value, "N")

function fin_k2(value)
get_set_global_param("fin_unos_k2", value, "N")

function fin_k3(value)
get_set_global_param("fin_unos_k3", value, "N")

function fin_k4(value)
get_set_global_param("fin_unos_k4", value, "N")

function fin_tip_dokumenta(value)
get_set_global_param("fin_unos_naloga_tip_dokumenta", value, "N" )

