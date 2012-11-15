/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

static __use_fiscal_opt := .f.


// ----------------------------------------------------------
// vraca ili setuje fiskalni parametar
// ----------------------------------------------------------
function fiscal_opt_active()
local _opt := fetch_metric( "fiscal_opt_active", NIL, "N" )

if _opt == "N"
    __use_fiscal_opt := .f.
else
    __use_fiscal_opt := .t.
endif

return __use_fiscal_opt



// ----------------------------------------------
// citanje i setovanje fiskalnih parametara
// ----------------------------------------------
function fiscal_params_read()

// opcija pretpostavlja da su vec setovane pubic varijable...
// fiskalni stampac

set_defaults()

// imamo ovdje podjelu parametara koji treba da budu globalni
// i oni koji to nisu...

gFc_use := fetch_metric( "fiskalne_opcije", my_user(), gfc_use )
gFc_type := fetch_metric( "fiskalne_opcije_tip", my_user(), gfc_type )
gFc_dlist := fetch_metric( "fiskalne_opcije_lista_uredjaja", my_user(), gfc_dlist )
gFc_pdv := fetch_metric( "fisk_pdv_korisnik", my_user(), gfc_pdv )
gFc_device := fetch_metric( "fisk_vrsta_uredjaja", my_user(), gfc_device )
gFc_dev_id := fetch_metric( "fisk_broj_uredjaja", my_user(), gfc_dev_id )
gFc_tout := fetch_metric( "fisk_timeout_komande", my_user(), gfc_tout )
gIosa := fetch_metric( "fisk_iosa_broj_uredjaja", my_user(), giosa )
gFc_serial := fetch_metric( "fisk_serijski_broj_uredjaja", my_user(), gfc_serial )
gFc_error := fetch_metric( "fisk_citaj_odgovor", my_user(), gfc_error )
gFc_pitanje := fetch_metric( "fisk_pitanje_prije_stampe", my_user(), gfc_pitanje )
gFc_alen := fetch_metric( "fisk_duzina_naziva_artikla", my_user(), gfc_alen )
gFc_zbir := fetch_metric( "fisk_zbirni_vp_racuni", my_user(), gfc_zbir )
gFc_pauto := fetch_metric( "fisk_automatski_polog", my_user(), gfc_pauto )
gFc_chk := fetch_metric( "fisk_provjera_kolicine", my_user(), gfc_chk )
gFc_operater := fetch_metric( "fisk_operater_naziv", my_user(), gfc_operater )
gFc_oper_pwd := fetch_metric( "fisk_operater_pwd", my_user(), gfc_oper_pwd )
gFc_acd := fetch_metric( "fisk_vrsta_plu_koda", my_user(), gfc_acd )
gFc_pinit := fetch_metric( "fisk_inicijalni_plu_kod", my_user(), gfc_pinit )
gFc_path := fetch_metric( "fisk_direktorij", my_user(), gfc_path )
gFc_path2 := fetch_metric( "fisk_direktorij_2", my_user(), gfc_path2 )
gFc_name := fetch_metric( "fisk_naziv_izlaznog_fajla", my_user(), gfc_name ) 
gFc_answ := fetch_metric( "fisk_naziv_fajla_odgovora", my_user(), gfc_answ )
gFc_nftxt := fetch_metric( "fisk_stampa_broja_veze", my_user(), gfc_nftxt )
gFc_faktura := fetch_metric( "fisk_stampa_txt_racuna", my_user(), gfc_faktura )
gFc_fisc_print := fetch_metric( "fisk_stampa_fiskalnih_racuna", my_user(), gfc_fisc_print )
gFc_kusur := fetch_metric( "fisk_obrada_kusura", my_user(), gfc_kusur )
gFc_convert := fetch_metric( "fisk_konverzija_852", my_user(), gfc_convert )

return


// -------------------------------------------------------
// defaultne vrijednosti fiskalnih parametara...
// -------------------------------------------------------
static function set_defaults()

gFC_pdv := "D"
gFC_type := PADR( "FPRINT", 20 )
gFC_device := "P"
gFc_dev_id := 0
gFc_use := "N"

// hernad: kod definisanja direktorija kao parametra 
// logicno je NE navoditi posljednji slash, ali je to u kodu 
// stalno pretpostavljano pa cu i ja ostaviti

#ifdef __PLATFORM__WINDOWS
    gFC_path := PADR("c:\fiscal\", 150)
#else

    #ifdef __PLATFORM__DARWIN
       gFC_path := PADR("/Volumes/fiscal/", 150)
    #else
       gFC_path := PADR("/var/spool/fiscal/", 150)
    #endif
#endif

gFC_path2 := PADR("", 150)
gFC_name := PADR("out.txt", 150 ) 
gFC_answ := PADR("",40)
gFC_pitanje := "D"
gFC_error := "D"
gFC_fisc_print := "D"
gFC_operater := PADR("1", 20)
gFc_oper_pwd := PADR("000000", 20)
gFC_tout := 300
gIosa := PADR("1234567890123456", 16)
gFC_alen := 32
gFC_nftxt := "N"
gFC_acd := "D"
gFC_pinit := 10
gFC_chk := "1"
gFC_faktura := "N"
gFC_zbir := 1
gFc_dlist := "N"
gFc_pauto := 0
gFc_serial := PADR("010000", 15)
gFc_restart := "N"
gFc_kusur := "N"
gFc_convert := "D"

return


// -----------------------------------------------------
// centralna forma za setovanje parametara...
// -----------------------------------------------------
function fiscal_params_set()
local _x := 1
local _box_x := 6
local _box_y := 60
local _set_param := "D"

// procitaj trenutne vrijednosti...
fiscal_params_read()

Box(, _box_x, _box_y )

    @ m_x + _x, m_y + 2 SAY "Koristiti fiskalne funkcije (D/N) ?" GET gFc_use VALID gFc_use $ "DN" PICT "@!"

    read

    if LastKey() != K_ESC
        set_metric( "fiskalne_opcije", my_user(), gfc_use )
    endif

    if gFc_use == "D"
        
        ++ _x
        ++ _x
   
        // idemo dalje...
        @ m_x + _x, m_y + 2 SAY "Koristi se lista uredjaja (D/N) ?" GET gFc_dlist VALID gFc_dlist $ "DN" PICT "@!"
        
		++ _x

        @ m_x + _x, m_y + 2 SAY "Broj uredjaja:" GET gFc_dev_id PICT "999"

        read

        if LastKey() != K_ESC
            set_metric( "fiskalne_opcije_lista_uredjaja", my_user(), gfc_dlist )
			set_metric( "fisk_broj_uredjaja", my_user(), gFc_dev_id )
        endif

        if gFc_dlist == "N"
             
            ++ _x
            ++ _x
   
            @ m_x + _x, m_y + 2 SAY "Podesiti parametre fiskalnog uredjaja (D/N) ?" GET _set_param VALID _set_param $ "DN" PICT "@!"
        
            read

            if _set_param == "D"
                // setuj parametre
                _params_set()
            endif

        endif

    endif

BoxC()

return




// ----------------------------------------------
// setovanje fiskalnih parametara
// ----------------------------------------------
static function _params_set()
local _x := 1
local _box_x := MAXROWS()-6
local _box_y := MAXCOLS()-5

// procitaj mi trenutne fiskalne parametre...
fiscal_params_read()

Box(, _box_x, _box_y )

    @ m_x + _x, m_y + 2 SAY PADR( "***** Osnovni parametri fiskalnog uredjaja", MAXCOLS() - 6 ) COLOR "I"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Korisnik je u fiskalnom sistemu PDV obveznik (D/N):" GET gFC_pdv VALID gFC_pdv $ "DN" PICT "@!"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Koristiti fiskalne funkcije za tip:" GET gFC_type VALID !EMPTY(gFC_type)
    @ m_x + _x, col() + 1 SAY "IOSA broj:" GET gIOSA 
    @ m_x + _x, col() + 1 SAY "Tip [K] kasa-printer [P] printer ?" GET gFC_device VALID gFC_device $ "KP" PICT "@!"
        
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Serijski broj uredjaja:" GET gFC_serial PICT "@S10"
    @ m_x + _x, col() + 1 SAY "Operater, sifra:" GET gFC_operater PICT "@S10"
    @ m_x + _x, col() + 2 SAY "lozinka:" GET gFC_oper_pwd PICT "@S10"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Izl.dir:" GET gFC_path VALID _valid_fiscal_path( gFC_path ) PICT "@S60"
    @ m_x + _x, col() + 1 SAY "Izl.fajl:" GET gFC_name VALID !EMPTY(gFC_name) PICT "@S30"
        
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Sek.dir:" GET gFC_path2 PICT "@S60"
    @ m_x + _x, col() + 1 SAY "Fajl odgovora:" GET gFC_answ PICT "@S30"
    
    ++ _x
    ++ _x
    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY PADR( "***** Parametri artikla", MAXCOLS() - 6 ) COLOR "I"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Duzina naziva:" GET gFC_alen PICT "999"

    @ m_x + _x, col() + 1 SAY "kao 'kod' koristi [P/D]Plu (staticki/dinamicki), [I]Id, [B]Barkod:" GET gFC_acd VALID gFC_acd $ "PIBD" PICT "@!"

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "(dinamicki kodovi) inicijalni PLU" GET gFC_pinit PICT "99999"

    ++ _x
    ++ _x
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( "***** Parametri rada sa fiskalnim uredjajem", MAXCOLS() - 6 ) COLOR "I"
    
    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Citanje fajla odgovora, provjera gresaka (D/N) ?" GET gFC_error VALID gFC_error $ "DN" PICT "@!"
    @ m_x + _x, col() + 2 SAY "Timeout fiskalnih operacija (def. 300):" GET gFC_tout PICT "9999"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Stampa fiskalnog racuna na upit (D/N) ?" GET gFC_Pitanje VALID gFC_pitanje $ "DN" PICT "@!"
    @ m_x + _x, col() + 2 SAY "Stampanje zbirnog racuna u VP (0/1/...)" GET gFC_zbir VALID gFC_zbir >= 0 PICT "999"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Stampa broja veze na fiskalnom racunu (D/N) ?" GET gFC_nftxt VALID gFC_nftxt $ "DN" PICT "@!"
    @ m_x + _x, col() + 2 SAY "Konverzija znakova u 852 (D/N) ?" GET gFC_convert VALID gFC_convert $ "DN" PICT "@!"
    
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Stampati A4 racun nakon stampe fiskalnog racuna (D/N) ?" GET gFC_faktura VALID gFC_faktura $ "DNGX" PICT "@!"
    @ m_x + _x, col() + 2 SAY "Unos kompletne uplate racuna (D/N) ?" GET gFC_kusur VALID gFC_kusur $ "DN" PICT "@!"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Provjera kolicine i cijene (1/2)" GET gFC_chk VALID gFC_chk $ "12" PICT "@!"
    @ m_x + _x, col() + 1 SAY "Automatski polog:" GET gFC_pauto PICT "999999.99"

    ++ _x
 
    @ m_x + _x, m_y + 2 SAY "Provjera i restart fiskalnog servisa (D/N) ?" GET gFC_restart VALID gFc_restart $ "DN" PICT "@!"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Korisnik moze da stampa fiskalne racune (D/N) ?" GET gFc_fisc_print VALID gFc_fisc_print $ "DN" PICT "@!"

    read

BoxC()

// upisi parametre u bazu
if ( LastKey() != K_ESC )

    // imamo ovdje podjelu parametara koji treba da budu globalni
    // i oni koji to nisu...

    set_metric( "fiskalne_opcije_tip", my_user(), gfc_type )
    set_metric( "fisk_pdv_korisnik", my_user(), gfc_pdv )
    set_metric( "fisk_vrsta_uredjaja", my_user(), gfc_device )
    set_metric( "fisk_timeout_komande", my_user(), gfc_tout )
    set_metric( "fisk_iosa_broj_uredjaja", my_user(), giosa )
    set_metric( "fisk_serijski_broj_uredjaja", my_user(), gfc_serial )
    set_metric( "fisk_citaj_odgovor", my_user(), gfc_error )
    set_metric( "fisk_pitanje_prije_stampe", my_user(), gfc_pitanje )
    set_metric( "fisk_duzina_naziva_artikla", my_user(), gfc_alen )
    set_metric( "fisk_zbirni_vp_racuni", my_user(), gfc_zbir )
    set_metric( "fisk_automatski_polog", my_user(), gfc_pauto )
    set_metric( "fisk_provjera_kolicine", my_user(), gfc_chk )
    set_metric( "fisk_operater_naziv", my_user(), gfc_operater )
    set_metric( "fisk_operater_pwd", my_user(), gfc_oper_pwd )
    set_metric( "fisk_vrsta_plu_koda", my_user(), gfc_acd )
    set_metric( "fisk_inicijalni_plu_kod", my_user(), gfc_pinit )
    set_metric( "fisk_direktorij", my_user(), gfc_path )
    set_metric( "fisk_direktorij_2", my_user(), gfc_path2 )
    set_metric( "fisk_naziv_izlaznog_fajla", my_user(), gfc_name )
    set_metric( "fisk_naziv_fajla_odgovora", my_user(), gfc_answ )
    set_metric( "fisk_stampa_broja_veze", my_user(), gfc_nftxt )
    set_metric( "fisk_stampa_txt_racuna", my_user(), gfc_faktura )
    set_metric( "fisk_stampa_fiskalnih_racuna", my_user(), gfc_fisc_print )
    set_metric( "fisk_obrada_kusura", my_user(), gfc_kusur )
    set_metric( "fisk_konverzija_852", my_user(), gfc_convert )

endif

return 






// ---------------------------------------------------------------
// ---------------------------------------------------------------
// NOVI FISKALNI PARAMETRI !!!
// ---------------------------------------------------------------
// ---------------------------------------------------------------

function f18_fiscal_params_menu()
local _opc := {}
local _opc_exe := {}
local _izbor := 1

// setuj mi glavnu varijablu
fiscal_opt_active()

AADD( _opc, "1. globalni parametri fiskalizacije        " )
AADD( _opc_exe, { || set_global_fiscal_params() })
AADD( _opc, "2. glavni parametri fiskalnih uredjaja" )
AADD( _opc_exe, { || set_main_fiscal_params() })
AADD( _opc, "3. korisnicki parametri fiskalnih uredjaja" )
AADD( _opc_exe, { || set_user_fiscal_params() })
AADD( _opc, "4. pregled parametara" )
AADD( _opc_exe, { || print_fiscal_params() })

f18_menu( "fiscal", .f., _izbor, _opc, _opc_exe )

return



// ---------------------------------------------
// init fiscal params
// 
//    setuju se init vrijednosti u parametrima:
//
//    fiscal_device_01_id, active, name...
//    fiscal_device_02_id, active, name...
//
// ---------------------------------------------
function set_init_fiscal_params()
local _devices := 10
local _i
local _tmp, _dev_param
local _dev_id

for _i := 1 to _devices

    // "01", "02", ...
    _dev_id := PADL( ALLTRIM(STR(_i)), 2, "0" )
    _dev_param := "fiscal_device_" + _dev_id

    // fiscal_device_01_id
    _tmp := fetch_metric( _dev_param + "_id", NIL, 0  )

    if _tmp == 0

        // setuj mi device_id parametar
        set_metric( _dev_param + "_id", NIL, _i )
        set_metric( _dev_param + "_active", NIL, "N" )
        set_metric( _dev_param + "_drv", NIL, "FPRINT" )
        set_metric( _dev_param + "_name", NIL, "Fiskalni uredjaj " + _dev_id )

    endif

next

return .t.




// --------------------------------------------------------------
// vraca naziv fiskalnog uredjaja 
// --------------------------------------------------------------
static function get_fiscal_device_name( device_id )
local _tmp := PADL( ALLTRIM(STR( device_id )), 2, "0" )
return fetch_metric( "fiscal_device_" + _tmp + "_name", NIL, "" )



// ---------------------------------------------------------------------
// setovanje globalnih fiskalnih parametara
// ---------------------------------------------------------------------
function set_global_fiscal_params()
local _x := 1
local _fiscal := fetch_metric( "fiscal_opt_active", NIL, "N" )

Box(, 3, 60 )

    @ m_x + _x, m_y + 2 SAY "Koristiti fiskalne opcije (D/N) ?" GET _fiscal ;
        PICT "@!" ;
        VALID _fiscal $ "DN"

    read

BoxC()

if LastKey() == K_ESC
    return .f.
endif

// snimi parametre
set_metric( "fiscal_opt_active", NIL, _fiscal )

// setuj glavni parametar
fiscal_opt_active()

return .t.




// ---------------------------------------------
// set global fiscal params
// ---------------------------------------------
function set_main_fiscal_params()
local _device_id := 1
local _max_id := 10
local _min_id := 1
local _x := 1
local _dev_tmp
local _dev_name, _dev_act, _dev_type, _dev_drv
local _dev_iosa, _dev_serial, _dev_plu, _dev_pdv, _dev_init_plu
local _dev_avans, _dev_timeout, _dev_vp_sum

if !__use_fiscal_opt 
    MsgBeep( "Fiskalne opcije moraju biti ukljucene !!!" )
    return .f.
endif

Box(, 20, 80 )

    @ m_x + _x, m_y + 2 SAY "Uredjaj ID:" GET _device_id ;
        PICT "99" ;
        VALID ( _device_id >= _min_id .and. _device_id <= _max_id )

    read

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( "**** Podesenje uredjaja", 60 ) COLOR "I"

    // iscitaj mi sada kada imam parametar tekuce postavke uredjaja

    _dev_tmp := PADL( ALLTRIM(STR( _device_id )), 2, "0" )
    _dev_name := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_name", NIL, "" ), 100 )
    _dev_act := fetch_metric( "fiscal_device_" + _dev_tmp + "_active", NIL, "N" )
    _dev_drv := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_drv", NIL, "" ), 20 )
    _dev_type := fetch_metric( "fiscal_device_" + _dev_tmp + "_type", NIL, "P" )
    _dev_pdv := fetch_metric( "fiscal_device_" + _dev_tmp + "_pdv", NIL, "D" )
    _dev_iosa := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_iosa", NIL, "1234567890123456" ), 16 )
    _dev_serial := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_serial", NIL, "000000" ), 20 )
    _dev_plu := fetch_metric( "fiscal_device_" + _dev_tmp + "_plu_type", NIL, "D" )
    _dev_init_plu := fetch_metric( "fiscal_device_" + _dev_tmp + "_plu_init", NIL, 10 )
    _dev_avans := fetch_metric( "fiscal_device_" + _dev_tmp + "_auto_avans", NIL, 0 )
    _dev_timeout := fetch_metric( "fiscal_device_" + _dev_tmp + "_time_out", NIL, 300 )
    _dev_vp_sum := fetch_metric( "fiscal_device_" + _dev_tmp + "_vp_sum", NIL, 1 )

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Naziv uredjaja:" GET _dev_name ;
        PICT "@S40"

    @ m_x + _x, col() + 1 SAY "Aktivan (D/N):" GET _dev_act ;
        PICT "@!" ;
        VALID _dev_act $ "DN"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Drajver (FPRINT/HCP/TREMOL/TRING/...):" GET _dev_drv ;
        PICT "@S20" ;
        VALID !EMPTY( _dev_drv )

    read

    if LastKey() == K_ESC
        return .f.
    endif

    if ALLTRIM( _dev_drv ) == "FPRINT"

        ++ _x

        @ m_x + _x, m_y + 2 SAY "IOSA broj:" GET _dev_iosa ;
            PICT "@S16" ;
            VALID !EMPTY( _dev_iosa )

        @ m_x + _x, col() + 1 SAY "Serijski broj:" GET _dev_serial ;
            PICT "@S20" ;
            VALID !EMPTY( _dev_serial )

    endif

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Uredjaj je u sistemu PDV-a (D/N):" GET _dev_pdv ;
        PICT "@!" ;
        VALID _dev_pdv $ "DN"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Tip uredjaja (K - kasa, P - printer):" GET _dev_type ;
        PICT "@!" ;
        VALID _dev_type $ "KP"

    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY PADR( "**** Parametri artikla", 60 ) COLOR "I"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Za artikal koristiti plu [D/P] (stat./dinam.) [I] id, [B] barkod:" GET _dev_plu ;
        PICT "@!" ;
        VALID _dev_plu $ "DPIB"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "(dinamicki) inicijalni PLU kod:" GET _dev_init_plu PICT "999999"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( "**** Parametri rada sa uredjajem", 60 ) COLOR "I"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Automatski polog u uredjaj:" GET _dev_avans PICT "999999.99"
    @ m_x + _x, col() + 1 SAY "Timeout fiskalnih operacija:" GET _dev_timeout PICT "999"

    ++ _x    

    @ m_x + _x, m_y + 2 SAY "Zbirni racun u VP (0/1/...):" GET _dev_vp_sum PICT "999"

    read

BoxC()

if LastKey() == K_ESC
    return .f.
endif

// snimi mi parametre uredjaja
set_metric( "fiscal_device_" + _dev_tmp + "_name", NIL, ALLTRIM( _dev_name ) )
set_metric( "fiscal_device_" + _dev_tmp + "_active", NIL, _dev_act )
set_metric( "fiscal_device_" + _dev_tmp + "_drv", NIL, ALLTRIM( _dev_drv ) )
set_metric( "fiscal_device_" + _dev_tmp + "_type", NIL, _dev_type )
set_metric( "fiscal_device_" + _dev_tmp + "_pdv", NIL, _dev_pdv )
set_metric( "fiscal_device_" + _dev_tmp + "_iosa", NIL, ALLTRIM( _dev_iosa ) )
set_metric( "fiscal_device_" + _dev_tmp + "_serial", NIL, ALLTRIM( _dev_serial ) )
set_metric( "fiscal_device_" + _dev_tmp + "_plu_type", NIL, _dev_plu )
set_metric( "fiscal_device_" + _dev_tmp + "_plu_init", NIL, _dev_init_plu )
set_metric( "fiscal_device_" + _dev_tmp + "_auto_avans", NIL, _dev_avans )
set_metric( "fiscal_device_" + _dev_tmp + "_time_out", NIL, _dev_timeout )
set_metric( "fiscal_device_" + _dev_tmp + "_vp_sum", NIL, _dev_vp_sum )

return .t.





// ---------------------------------------------
// ---------------------------------------------
function set_user_fiscal_params()
local _user_name := my_user()
local _user_id := GetUserId( _user_name )
local _device_id := 1
local _max_id := 10
local _min_id := 1
local _x := 1
local _dev_drv, _dev_tmp
local _out_dir, _out_file, _ans_file, _print_a4
local _op_id, _op_pwd, _print_fiscal

if !__use_fiscal_opt 
    MsgBeep( "Fiskalne opcije moraju biti ukljucene !!!" )
    return .f.
endif

Box(, 20, 80 )

    // to-do, napraviti da se ispisu uredjaj i korisnik... pored GET polja

    @ m_x + _x, m_y + 2 SAY PADL( "Uredjaj ID:", 15 ) GET _device_id ;
        PICT "99" ;
        VALID {|| ( _device_id >= _min_id .and. _device_id <= _max_id ), ;
                show_it( get_fiscal_device_name( _device_id, 30 ) ), .t. }

    ++ _x

    @ m_x + _x, m_y + 2 SAY PADL( "Korisnik:", 15 ) GET _user_id ;
        PICT "99999999" ;
        VALID { || IIF( _user_id == 0, choose_f18_user_from_list( @_user_id ), .t. ), ;
            show_it( GetFullUserName( _user_id ), 30 ), .t.  }

    read

    // korisnik ce biti na osnovu izbora
    _user_name := ALLTRIM( GetUserName( _user_id ) )

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( "*** podesenja rada sa uredjajem", 60 ) COLOR "I"

    ++ _x

    // iscitaj mi sada kada imam parametar tekuce postavke uredjaja za korisnika
    _dev_tmp := PADL( ALLTRIM(STR( _device_id )), 2, "0" )
    // drajver uredjaja
    _dev_drv := ALLTRIM( fetch_metric( "fiscal_device_" + _dev_tmp + "_drv", NIL, "" ) )

    // ---------------------------
    // korisnicki parametri
    // ---------------------------
    _out_dir := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_out_dir", _user_name, out_dir_op_sys( _dev_drv ) ), 300 )
    _out_file := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_out_file", _user_name, out_file_op_sys( _dev_drv ) ), 50 )
    _out_answer := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_out_answer", _user_name, "" ), 50 )

    _op_id := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_op_id", _user_name, "1" ), 10 )
    _op_pwd := PADR( fetch_metric( "fiscal_device_" + _dev_tmp + "_op_pwd", _user_name, "000000" ), 10 )
    _print_a4 := fetch_metric( "fiscal_device_" + _dev_tmp + "_print_a4", _user_name, "N" )
    _print_fiscal := fetch_metric( "fiscal_device_" + _dev_tmp + "_print_fiscal", _user_name, "D" )
    
    @ m_x + _x, m_y + 2 SAY "Direktorij izlaznih fajlova:" GET _out_dir PICT "@S50" VALID _valid_fiscal_path( _out_dir )

    ++ _x

    @ m_x + _x, m_y + 2 SAY "       Naziv izlaznog fajla:" GET _out_file PICT "@S20" VALID !EMPTY( _out_file )

    ++ _x

    @ m_x + _x, m_y + 2 SAY "       Naziv fajla odgovora:" GET _out_answer PICT "@S20"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Operater, ID:" GET _op_id PICT "@S10"
    @ m_x + _x, col() + 1 SAY "lozinka:" GET _op_pwd PICT "@S10"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Stampati A4 racun nakon fiskalnog (D/N/G):" GET _print_a4 ;
        PICT "@!" VALID _print_a4 $ "DNG"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Korisnik moze printati fiskalne racune (D/N):" GET _print_fiscal ;
        PICT "@!" VALID _print_fiscal $ "DN"
    
    read

BoxC()

if LastKey() == K_ESC
    return .f.
endif

// snimi mi parametre uredjaja
set_metric( "fiscal_device_" + _dev_tmp + "_out_dir", _user_name, ALLTRIM( _out_dir ) )
set_metric( "fiscal_device_" + _dev_tmp + "_out_file", _user_name, ALLTRIM( _out_file ) )
set_metric( "fiscal_device_" + _dev_tmp + "_out_answer", _user_name, ALLTRIM( _out_answer ) )
set_metric( "fiscal_device_" + _dev_tmp + "_op_id", _user_name, ALLTRIM( _op_id ) )
set_metric( "fiscal_device_" + _dev_tmp + "_op_pwd", _user_name, ALLTRIM( _op_pwd ) )
set_metric( "fiscal_device_" + _dev_tmp + "_print_a4", _user_name, _print_a4 )
set_metric( "fiscal_device_" + _dev_tmp + "_print_fiscal", _user_name, _print_fiscal )
 
return .t.







// ---------------------------------------------------------------------
// izlazni direktorij za fiskalne funkcije
// ---------------------------------------------------------------------
static function out_dir_op_sys( dev_type )
local _path := ""

do case
    case dev_type == "FPRINT" .or. dev_type == "TREMOL"
        #ifdef __PLATFORM__WINDOWS
            _path := "C:" + SLASH + "fiscal" + SLASH
        #else
            _path := SLASH + "home" + SLASH + "bringout" + SLASH + "fiscal"
        #endif
    case dev_type == "HCP"
        #ifdef __PLATFORM__WINDOWS
            _path := "C:" + SLASH + "hcp" + SLASH
        #else
            _path := SLASH + "home" + SLASH + "bringout" + SLASH + "hcp"
        #endif
endcase

return _path


// ---------------------------------------------------------------------
// izlazni fajl za fiskalne opcije
// ---------------------------------------------------------------------
static function out_file_op_sys( dev_type )
local _file := ""

do case
    case dev_type == "FPRINT"
        _file := "out.txt"
    case dev_type == "HCP"
        _file := "tr$01.xml"
    case dev_type == "TREMOL"
        _file := "01.xml"
endcase

return _file




// -------------------------------------------------------
// validacija path-a izlaznih fajlova
// -------------------------------------------------------
static function _valid_fiscal_path( fiscal_path )
local _ok := .t.
local _cre

fiscal_path := ALLTRIM( fiscal_path )

if EMPTY( fiscal_path )
    MsgBeep( "Izlazni direktorij mora biti definisan ?!!!" )
    _ok := .f.
    return _ok
endif

if DirChange( fiscal_path ) != 0
    // probaj kreirati direktorij...
    _cre := MakeDir( fiscal_path )
    if _cre != 0
        MsgBeep( "kreiranje " + fiscal_path + " neuspjesno ?!" )
        _ok := .f.
    endif
endif

return _ok



// ---------------------------------------------------------------
// vraca odabrani fiskalni uredjaj
// ---------------------------------------------------------------
function get_fiscal_device( user )
local _device_id := 0
local _dev_arr

if !__use_fiscal_opt 
    return _device_id
endif

_dev_arr := get_fiscal_devices_list( user )

if LEN( _dev_arr ) == 0
    return _device_id
endif

if LEN( _dev_arr ) > 1
    // prikazi mi listu uredjaja...
    _device_id := arr_fiscal_choice( _dev_arr )
else
    // samo je jedan uredjaj u listi, ovo je njegov ID
    _device_id := _dev_arr[ 1, 1 ]
endif

return _device_id



// -----------------------------------------------------
// vraca listu fiskalnih uredjaja kroz matricu
// -----------------------------------------------------
function get_fiscal_devices_list( user )
local _arr := {}
local _i
local _dev_max := 10
local _dev_tmp
local _usr_dev_list := ""

// ako je zadan user, provjeri njegova lokalna podesenja
if user == NIL
    user := my_user()
endif

// ovo je lista koja se setuje kod korisnika...
_usr_dev_list := fetch_metric( "fiscal_devices_list", user, "" )

for _i := 1 to _dev_max
    
    _dev_tmp := PADL( ALLTRIM( STR( _i) ), 2, "0" )

    _dev_id := fetch_metric( "fiscal_device_" + _dev_tmp + "_id", NIL, 0 )

    if ( _dev_id <> 0 ) .and. ( fetch_metric( "fiscal_device_" + _dev_tmp + "_active", NIL, "N" ) == "D" ) ;
        .and. IF( !EMPTY( _usr_dev_list ), ALLTRIM(STR( _dev_id ) ) + "," $ _usr_dev_list, .t. ) 

        // ubaci u matricu: dev_id, dev_name
        AADD( _arr, { _dev_id, fetch_metric( "fiscal_device_" + _dev_tmp + "_name", NIL, "" ) } )

    endif

next

if LEN( _arr ) == 0
    MsgBeep( "Nema podesen niti jedan fiskalni uredjaj !!!" )
endif

return _arr



// -------------------------------------------------------
// array choice
// -------------------------------------------------------
static function arr_fiscal_choice( arr )
local _ret := 0
local _i, _n
local _tmp
local _izbor := 1
local _opc := {}
local _opcexe := {}
local _m_x := m_x
local _m_y := m_y

for _i := 1 to LEN( arr )

    _tmp := ""
    _tmp += PADL( ALLTRIM(STR( _i )) + ")", 3 )
    _tmp += " uredjaj " + PADL( ALLTRIM( STR( arr[ _i, 1 ] ) ) , 2, "0" )
    _tmp += " : " + PADR( arr[ _i, 2 ], 40 )

    AADD( _opc, _tmp )
    AADD( _opcexe, {|| "" })
    
next

do while .t. .and. LastKey() != K_ESC
    _izbor := Menu( "choice", _opc, _izbor, .f. )
	if _izbor == 0
        exit
    else
        _ret := arr[ _izbor, 1 ]
        _izbor := 0
    endif
enddo

m_x := _m_x
m_y := _m_y

return _ret




// --------------------------------------------------------------
// vraca hash matricu sa postavkama fiskalnog uredjaja
// --------------------------------------------------------------
function get_fiscal_device_params( device_id, user_name )
local _param := hb_hash()
local _dev_tmp := PADL( ALLTRIM(STR( device_id )), 2, "0" )
local _dev_param
local _user_name := my_user()
local _out_dir

if !__use_fiscal_opt 
    return NIL
endif

// pretpostavlja da ce se koristiti tekuci user
// ali mozemo zadati i nekog drugog korisnika
if user_name <> NIL
    _user_name := user_name
endif

_dev_param := "fiscal_device_" + _dev_tmp

_dev_id := fetch_metric( _dev_param + "_id", NIL, 0 )

// nema tog fiskalnog uredjaja
if _dev_id == 0
    return NIL
endif

// napuni mi hash matricu sa podacima uredjaja...

// globalni parametri
_param["id"] := _dev_id
_param["name"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_name", NIL, "" )
_param["active"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_active", NIL, "" ) 
_param["drv"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_drv", NIL, "" )
_param["type"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_type", NIL, "P" )
_param["pdv"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_pdv", NIL, "D" )
_param["iosa"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_iosa", NIL, "" ) 
_param["serial"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_serial", NIL, "" )
_param["plu_type"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_plu_type", NIL, "D" )
_param["plu_init"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_plu_init", NIL, 10 )
_param["auto_avans"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_auto_avans", NIL, 0 )
_param["timeout"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_time_out", NIL, 300 )
_param["vp_sum"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_vp_sum", NIL, 1 )

// user parametri
_out_dir := fetch_metric( "fiscal_device_" + _dev_tmp + "_out_dir", _user_name, "" )

// ako nema podesen output dir, onda znamo i da user nije setovan...
if EMPTY( _out_dir )
    return NIL
endif

_param["out_dir"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_out_dir", _user_name, "" )
_param["out_file"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_out_file", _user_name, "" )
_param["out_answer"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_out_answer", _user_name, "" )
_param["op_id"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_op_id", _user_name, "" ) 
_param["op_pwd"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_op_pwd", _user_name, "" )
_param["print_a4"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_print_a4", _user_name, "N" )
_param["print_fiscal"] := fetch_metric( "fiscal_device_" + _dev_tmp + "_print_fiscal", _user_name, "D" )
 
return _param



// ----------------------------------------------------------
// prikazi fiskalne parametre
// ----------------------------------------------------------
function print_fiscal_params()
local _dev_arr
local _usr_count, _dev_param
local _user := my_user()
local _usr_cnt, _user_id, _user_name
local _dev_cnt, _dev_id, _dev_name, _dev_act

if !__use_fiscal_opt 
    MsgBeep( "Fiskalne opcije moraju biti ukljucene !!!" )
    return .f.
endif

_usr_arr := get_list_f18_users()

START PRINT CRET
?
? "Prikaz fiskalnih parametara:"
?

for _usr_cnt := 1 to LEN( _usr_arr )

    _user_id := _usr_arr[ _usr_cnt, 1 ]
    _user_name := _usr_arr[ _usr_cnt, 2 ]

    // izvuci mi listu za pojedinog korisnika...
    _dev_arr := get_fiscal_devices_list( _user_name )

    ? 
    ? "Korisnik:", GetFullUserName( _user_id )
    ? REPLICATE( "=", 80 ) 

    for _dev_cnt := 1 to LEN( _dev_arr )

        _dev_id := _dev_arr[ _dev_cnt, 1 ]
        _dev_name := _dev_arr[ _dev_cnt, 2 ]

        ? SPACE(3), "Uredjaj id:", _dev_id, "naziv:", _dev_name
        ? SPACE(3), REPLICATE( "-", 70 )

        // sada imamo parametre za pojedini stampac

        _dev_param := get_fiscal_device_params( _dev_id, _user_name )

        if _dev_param == NIL
            ? SPACE(3), "nema podesenih parametara !!!"
        else
            _print_param( _dev_param )
        endif

    next

next

FF
END PRINT

return

// ------------------------------------------------------
// printanje parametra
// ------------------------------------------------------
static function _print_param( param )

? SPACE(3), "Drajver:", param["drv"], "IOSA:", param["iosa"], "serijski broj:", param["serial"] 
? SPACE(3), "Izlazni direktorij:", param["out_dir"]
? SPACE(3), "       naziv fajla:", param["out_file"]
? SPACE(3), "    naziv odgovora:", param["out_answer"]

return


