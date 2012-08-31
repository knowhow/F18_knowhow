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

#ifdef __PLATFORM__WINDOWS
    gFC_path := PADR("c:\fiscal", 150)
#else

    #ifdef __PLATFORM__DARWIN
       gFC_path := PADR("/Volumes/fiscal", 150)
    #else
       gFC_path := PADR("/var/spool/fiscal", 150)
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

endif

return 



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


