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


#include "fakt.ch"


// staticke varijable
static __device_id := 0
static __device_params
static __auto := .f.
static __racun_na_email := NIL
static __partn_ino
static __partn_pdv
static __vrsta_pl
static __prikazi_partnera
static __DRV_TREMOL := "TREMOL"
static __DRV_FPRINT := "FPRINT"
static __DRV_FLINK := "FLINK"
static __DRV_HCP := "HCP"
static __DRV_TRING := "TRING"
static __DRV_CURRENT


// --------------------------------------------------------------------------
// param: slati racun na email
// --------------------------------------------------------------------------
function param_racun_na_email(read_par)
if read_par != NIL
    __racun_na_email := fetch_metric( "fakt_dokument_na_email", my_user(), "" )
endif   
return __racun_na_email



// --------------------------------------------------------------------
// centralna funkcija za poziv stampe fiskalnog racuna
// --------------------------------------------------------------------
function fakt_fisc_rn( id_firma, tip_dok, br_dok, auto_print, dev_param )
local _err_level := 0
local _dev_drv
local _storno := .f.
local _items_data, _partn_data
local _cont := "1"

// koriste li se fiskalne opcije uopste ?
if !fiscal_opt_active()
    return _err_level
endif

if ( auto_print == NIL )
    auto_print := .f.
endif

// set automatsko stampanje, bez informacija
if auto_print
    __auto := .t.
endif

if dev_param == NIL
    return _err_level
endif

__device_params := dev_param

// drajver ??
_dev_drv := ALLTRIM( dev_param["drv"] )
__DRV_CURRENT := _dev_drv

// priprema podatak za racun....
select fakt_doks
set filter to
set relation to

select fakt
set filter to
set relation to

select partn
set filter to
set relation to

select fakt_doks

// da li je racun storno ????
_storno := fakt_dok_is_storno( id_firma, tip_dok, br_dok )

if VALTYPE( _storno ) == "N" .and. _storno == -1
	return _err_level
endif

// pripremi matricu sa podacima partnera itd....
_partn_data := fakt_fiscal_head_prepare( id_firma, tip_dok, br_dok, _storno )

if VALTYPE( _partn_data ) == "L"
    // nesto nije dobro, zatvaram opciju
    return _err_level
endif

// pripremi mi matricu sa stavkama racuna
_items_data := fakt_fiscal_items_prepare( id_firma, tip_dok, br_dok, _storno, _partn_data )

// da nije slucajno NIL ???
if VALTYPE( _items_data ) == "L" .or. _items_data == NIL
    return _err_level
endif

do case

    case _dev_drv == "TEST"
        // test uredjaj, propusta opciju fiskalnog racuna
        // azurira racun i prakticno ne uradi nista...
        _err_level := 0

    case _dev_drv == __DRV_FPRINT
        _err_level := fakt_to_fprint( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno )

    case _dev_drv == __DRV_TREMOL
        _cont := "1"
        _err_level := fakt_to_tremol( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno, _cont )

    case _dev_drv == __DRV_HCP
        _err_level := fakt_to_hcp( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno )

    case _dev_drv == __DRV_TRING
        _err_level := fakt_to_tring( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno )

    //case _dev_drv == __DRV_FLINK
      //  _err_level := fakt_to_flink( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno )

endcase

// drugi pokusaj u slucaju greske !
if _err_level > 0
    
    if _dev_drv == __DRV_TREMOL
        
        // posalji drugi put za ponistavanje komande racuna
        // parametar continue = 2
        _cont := "2"
        _err_level := fakt_to_tremol( id_firma, tip_dok, br_dok, _items_data, _partn_data, _storno, _cont )

        if _err_level > 0
            msgbeep("Problem sa stampanjem na fiskalni stampac !!!")
        endif

    endif

endif

return _err_level



// ---------------------------------------------------------------
// box reklamni racun
// ---------------------------------------------------------------
function reklamni_rn_box( rekl_rn )

Box(, 1, 60 )
    @ m_x + 1, m_y + 2 SAY "Reklamiramo fiskalni racun broj:" ;
            GET rekl_rn PICT "999999999" VALID ( rekl_rn > 0 )
    read
BoxC()

if LastKey() == K_ESC .and. rekl_rn == 0
    rekl_rn := -1
endif

return rekl_rn



// --------------------------------------------------------------------
// provjerava da li je racun storno
// --------------------------------------------------------------------
static function fakt_dok_is_storno( id_firma, tip_dok, br_dok )
local _storno := .t.
local _t_rec

select fakt
set order to tag "1"
go top
seek ( id_firma + tip_dok + br_dok )

if !FOUND()
	MsgBeep( "Ne mogu locirati dokument - is storno !" )
	return -1
endif

_t_rec := RECNO()

do while !EOF() .and. field->idfirma == id_firma ;
                .and. field->idtipdok == tip_dok ;
                .and. field->brdok == br_dok

    if field->kolicina > 0
        _storno := .f.
        exit
    endif
    
    skip

enddo

go ( _t_rec )

return _storno



// --------------------------------------------------
// otvaranje potrebnih tabela
// --------------------------------------------------
static function _o_tables()
O_FAKT_DOKS
O_FAKT
O_ROBA
O_SIFK
O_SIFV
return



// -----------------------------------------------------------------------------
// pripremi podatke u matricu
// -----------------------------------------------------------------------------
static function fakt_fiscal_items_prepare( id_firma, tip_dok, br_dok, storno, partn_arr )
local _data := {}
local _n_rn_broj, _rn_iznos, _rn_rabat, _rn_datum, _rekl_rn_broj
local _vrsta_pl, _partn_id, _rn_total, _rn_f_total
local _art_id, _art_plu, _art_naz, _art_jmj, _v_plac
local _art_barkod, _rn_rbr, _memo
local _pop_na_teret_prod := .f.
local _partn_ino := .f.
local _partn_pdv := .t.

// 0 - gotovina
// 3 - ziralno / virman

_v_plac := "0"

if partn_arr <> NIL
    // u ovim clanovima matrice su mi podaci 
    // o partneru
    _v_plac := partn_arr[ 1, 6 ]
    _partn_ino := partn_arr[ 1, 7 ]
    _partn_pdv := partn_arr[ 1, 8 ]
else
    // uzmi na osnovu statickih varijabli
    _v_plac := __vrsta_pl
    _partn_ino := __partn_ino
    _partn_pdv := __partn_pdv
endif

if storno == NIL
    storno := .f.
endif

// otvori mi potrebne tabele
_o_tables()

// nastimaj me na fakt_doks
select fakt_doks
go top
seek ( id_firma + tip_dok + br_dok )

_n_rn_broj := VAL(ALLTRIM(field->brdok))
_rekl_rn_broj := field->fisc_rn

_rn_iznos := field->iznos
_rn_rabat := field->rabat
_rn_datum := field->datdok
_partn_id := field->idpartner

// nastimaj me na fakt_fakt
select fakt
go top
seek ( id_firma + tip_dok + br_dok )

if !FOUND()
    // ovaj racun nema stavki !!!!
    MsgBeep( "Racun ne posjeduje niti jednu stavku#Stampanje onemoguceno !!!" )
    return NIL
endif

// koji je broj racuna koji storniramo
if storno 
    _rekl_rn_broj := reklamni_rn_box( _rekl_rn_broj )
endif

// ESC na unosu veze racuna
if _rekl_rn_broj == -1
    MsgBeep( "Broj veze racuna mora biti setovan" )
    return NIL
endif

// i total sracunaj sa pdv
// upisat cemo ga u svaku stavku matrice
// to je total koji je bitan kod regularnih racuna
// pdv, ne pdv obveznici itd...
_rn_total := _uk_sa_pdv( tip_dok, _partn_id, _rn_iznos )
// total za sracunavanje kod samaranja po stavkama racuna
_rn_f_total := 0

// upisi u matricu stavke
do while !EOF() .and. field->idfirma == id_firma ;
                .and. field->idtipdok == tip_dok ;
                .and. field->brdok == br_dok

    select roba
    seek fakt->idroba
   
    select fakt

    // storno identifikator
    _storno_ident := 0

    if ( field->kolicina < 0 ) .and. !storno
        _storno_ident := 1
    endif
    
    _rn_broj := fakt->brdok
    _rn_rbr := fakt->rbr

    // memo polje    
    _memo := ParsMemo( fakt->txt )

    _art_id := fakt->idroba
    _art_barkod := ALLTRIM( roba->barkod )

    if roba->tip == "U" .and. EMPTY( ALLTRIM( roba->naz ) )

        _memo_opis := ALLTRIM( _memo[1] )

        if EMPTY( _memo_opis )
            _memo_opis := "artikal bez naziva"
        endif

        _art_naz := ALLTRIM( fiscal_art_naz_fix( _memo_opis, __device_params["drv"] ) )
    else
        _art_naz := ALLTRIM( fiscal_art_naz_fix( roba->naz, __device_params["drv"] ) )
    endif

    _art_jmj := ALLTRIM( roba->jmj )

    _art_plu := roba->fisc_plu
    // generisi automatski plu ako treba
    if __device_params["plu_type"] == "D" .and. ;
        ( __device_params["vp_sum"] <> 1 .or. tip_dok $ "11" )
        _art_plu := auto_plu( nil, nil,  __device_params )
    endif

    _cijena := roba->mpc
    // izracunaj cijenu
    if tip_dok == "10"
        // moramo uzeti cijenu sa pdv-om
        _cijena := ABS( _uk_sa_pdv( tip_dok, _partn_id, field->cijena ) )
        _vr_plac := "3"
    else
        _cijena := ABS( field->cijena )
    endif
    
    _kolicina := ABS( field->kolicina )
    
    // ako korisnik nije PDV obveznik
    // i radi se o robi sa zasticenom cijenom
    // rabat preskoci
    if !_partn_ino .and. !_partn_pdv .and. RobaZastCijena( roba->idtarifa )
        _pop_na_teret_prod := .t.
        _rn_rabat := 0
    else
        _rn_rabat := ABS ( field->rabat ) 
    endif

    _tarifa_id := ALLTRIM( roba->idtarifa )

    // ako je za ino kupca onda ide nulta stopa
    // oslobodi ga poreza
    if _partn_ino == .t.
        _tarifa_id := "PDV0"
    endif

    _storno_rn_opis := ""

    if _rekl_rn_broj > 0
        // ovo ce biti racun koji reklamiramo !
        _storno_rn_opis := ALLTRIM( STR( _rekl_rn_broj ))
    endif

    // izracunaj total po stavci 
    // ako se radi o robi sa zasticenom cijenom
    // ovaj total ce se napuniti u matricu

    if field->dindem == LEFT( ValBazna(), 3)
        _rn_f_total += Round( _kolicina * _cijena * PrerCij() * ( 1 - _rn_rabat / 100), ZAOKRUZENJE )
    else
        _rn_f_total += round( _kolicina * _cijena * PrerCij() * ( 1 - _rn_rabat / 100), ZAOKRUZENJE )
    endif

    // 1 - broj racuna
    // 2 - redni broj
    // 3 - id roba
    // 4 - roba naziv
    // 5 - cijena
    // 6 - kolicina
    // 7 - tarifa
    // 8 - broj racuna za storniranje
    // 9 - roba plu
    // 10 - plu cijena
    // 11 - popust
    // 12 - barkod
    // 13 - vrsta placanja
    // 14 - total racuna
    // 15 - datum racuna
    // 16 - roba jmj

    AADD( _data, { _rn_broj , ;
            _rn_rbr, ;
            _art_id, ;
            _art_naz, ;
            _cijena, ;
            _kolicina, ;
            _tarifa_id, ;
            _storno_rn_opis, ;
            _art_plu, ;
            _cijena, ;
            _rn_rabat, ;
            _art_barkod, ;
            _v_plac, ;
            _rn_total, ;
            _rn_datum, ;
            _art_jmj } )

    skip

enddo

// setuj total za pojedine opcije
if _pop_na_teret_prod .or. _partn_ino
    // ako ima popusta na teret prodavaca
    // sredi total, ukljuci i rabat koji je dat
    // uzmi sada onaj nF_total
    for _n := 1 to LEN( _data )
        _data[ _n, 14 ] := _rn_f_total 
    next
endif

// zbirni racun
if tip_dok $ "10"
    set_fiscal_rn_zbirni( @_data )
endif

// provjeri prije stampe stavke kolicina, cijena
_item_level_check := 1

if fiscal_items_check( @_data, storno, _item_level_check, __device_params["drv"] ) < 0
    return NIL    
endif

return _data





// ---------------------------------------------------------------------
// pripremi podatke, partner itd...
// ---------------------------------------------------------------------
static function fakt_fiscal_head_prepare( id_firma, tip_dok, br_dok, storno )
local _head := {}
local _partn_id
local _vrsta_p 
local _v_plac := "0"
local _partn_clan, _partn_jib
local _prikazi_partnera := .t.
local _partn_ino := .f.
local _partn_pdv := .t.

select fakt_doks
set order to tag "1"
go top
seek ( id_firma + tip_dok + br_dok )

_partn_id := field->idpartner
_vrsta_p := field->idvrstep

// head matrica
// =============================
// 1 - id broj kupca
// 2 - naziv
// 3 - adresa
// 4 - ptt
// 5 - grad
// 6 - vrsta placanja
// 7 - ino partner
// 8 - pdv obveznik

if ! ( tip_dok $ "#10#11#" ) .or. EMPTY( _partn_id ) .or. _vrsta_p == "G "
    return NIL
endif

if tip_dok $ "#10#" .or. ( tip_dok == "11" .and. _vrsta_p == "VR" )
    // virmansko placanje
    // tip dokumenta: 10
    // tip dokumenta: 11 i vrsta placanja "VR"
    _v_plac := "3"
endif

// podaci partnera
_partn_jib := ALLTRIM( IzSifK( "PARTN", "REGB", _partn_id, .f. ) )
// oslobadjanje po clanu
_partn_clan := ALLTRIM( IzSifK( "PARTN" , "PDVO", _partn_id, .f. ) )

if tip_dok == "11"
 
    _partn_ino := .f.
    _partn_pdv := .t.

    if _v_plac == "3" 
        _prikazi_partnera := .t.
    else 
        _prikazi_partnera := .f.
    endif

elseif !EMPTY( _partn_jib ) .and. ( LEN( _partn_jib ) < 12 .or. !EMPTY( _partn_clan ) )

    // kod info faktura ne prikazuj partnera
    _partn_ino := .t.
    _prikazi_partnera := .f.

    // ako je samo oslobadjanje po clanu onda prikazi
    if !EMPTY( _partn_clan )
        _prikazi_partnera := .t.
    endif
    
elseif LEN( _partn_jib ) == 12
                
    _partn_ino := .f.
    _partn_pdv := .t.
    _prikazi_partnera := .t.

elseif LEN( _partn_jib ) > 12

    _partn_ino := .f.
    _partn_pdv := .f.
    _prikazi_partnera := .t.

endif

// setuj staticke
__vrsta_pl := _v_plac
__partn_ino := _partn_ino
__partn_pdv := _partn_pdv
__prikazi_partnera := _prikazi_partnera

// ako ga ne treba prikazivti 
// nista nemoj vracati...
if !_prikazi_partnera
    return NIL
endif

select partn
go top
seek _partn_id
      
if !FOUND()
	MsgBeep( "Partnera nisam pronasao u sifrarniku - head prepare !" )
	return .f.
endif
 
// ako je pdv obveznik
// dodaj "4" ispred id broja
if LEN( ALLTRIM( _partn_jib ) ) == 12        
    _partn_jib := "4" + ALLTRIM( _partn_jib )
endif

// provjeri podatke partnera
_ok := .t.
if EMPTY( _partn_jib )
    _ok := .f.
endif
if _ok .and. EMPTY( partn->naz )
    _ok := .f.
endif
if _ok .and. EMPTY( partn->adresa )
    _ok := .f.
endif
if _ok .and. EMPTY( partn->ptt )
    _ok := .f.
endif
if _ok .and. EMPTY( partn->mjesto )
    _ok := .f.
endif     

if !_ok
    MsgBeep("!!! Podaci partnera nisu kompletirani !!!#(id, naziv, adresa, ptt, mjesto)#Prekidam operaciju")
    return .f.
endif

// ubaci u matricu podatke o partneru
AADD( _head, { _partn_jib, partn->naz, partn->adresa, ;
         partn->ptt, partn->mjesto, _v_plac, _partn_ino, _partn_pdv } )

return _head



// -------------------------------------------------------------
// obradi izlaz fiskalnog racuna na FPRINT uredjaj
// -------------------------------------------------------------
static function fakt_to_fprint( id_firma, tip_dok, br_dok, items, head, storno )
local _path := __device_params["out_dir"]
local _filename := __device_params["out_file"]
local _fiscal_no := 0
local _total := items[ 1, 14 ]
local _partn_naz

// pobrisi fajl odgovora
fprint_delete_answer( __device_params )

// posalji fajl prema FPRINT drajveru
fprint_rn( __device_params, items, head, storno )

// procitaj gresku!
_err_level := fprint_read_error( __device_params, @_fiscal_no, storno )

if _err_level = -9
    // nestanak trake ?
    if Pitanje(,"Da li je nestalo trake ?", "N") == "D"
        if Pitanje(,"Ubacite traku i pritisnite 'D'","D") == "D"
            // procitaj gresku opet !
            _err_level := fprint_read_error( __device_params, @_fiscal_no, storno )
        endif
    endif
endif

if _fiscal_no <= 0
    _err_level := 1
endif

if _err_level <> 0

    // pobrisi izlazni fajl ako je ostao !
    fprint_delete_out( _path + _filename )

    _msg := "ERR FISC: stampa racuna err:" + ALLTRIM(STR(_err_level)) + ;
            "##" + _path + _filename

    log_write( _msg, 2 )
    
    MsgBeep( _msg )

    return _err_level

endif

// post operacije....

// racun na email ?    
if !EMPTY( param_racun_na_email() ) .and. tip_dok $ "#11#"
        
    // posalji email...
    // ako se radi o racunu tipa "11"
    _partn_naz := _get_partner_for_email( id_firma, tip_dok, br_dok )
    _snd_eml( _fiscal_no, tip_dok + "-" + ALLTRIM( br_dok ), _partn_naz, nil, _total )
    
endif

// ubaci broj fiskalnog racuna u fakturu
set_fiscal_no_to_fakt_doks( id_firma, tip_dok, br_dok, _fiscal_no, storno )

// samo ako se zadaje direktna stampa ispisi
if __auto = .f.
    MsgBeep( "Kreiran fiskalni racun broj: " + ALLTRIM( STR( _fiscal_no ) ) )
endif

return _err_level


// -----------------------------------------------------------------------
// vrati partnera za email
// -----------------------------------------------------------------------
static function _get_partner_for_email( id_firma, tip_dok, br_dok )
local _ret := ""
local _t_area := SELECT()
local _partn

select fakt_doks
go top
seek id_firma + tip_dok + br_dok

_partn := field->idpartner

select partn
hseek _partn

if FOUND()
    _ret := ALLTRIM( field->naz )
endif

select ( _t_area )
return _ret



// -------------------------------------------------------------
// izdavanje fiskalnog isjecka na TREMOL uredjaj
// -------------------------------------------------------------
static function fakt_to_tremol( id_firma, tip_dok, br_dok, items, head, storno, cont )
local _err_level := 0
local _f_name 
local _fiscal_no := 0

// identifikator CONTINUE
// nesto imamo mogucnost ako racun zapne da kazemo drugi identifikator
// pa on navodno nastavi
if cont == NIL
    cont := "0"
endif

// stampaj racun !
_err_level := tremol_rn( __device_params, items, head, storno, cont )

_f_name := ALLTRIM( fiscal_out_filename( __device_params["out_file"], br_dok ) )

// da li postoji ista na izlazu ?
if tremol_read_out( __device_params, _f_name, __device_params["timeout"] )
    // procitaj sada gresku
    _err_level := tremol_read_error( __device_params, _f_name, @_fiscal_no ) 
        
else
    _err_level := -99
endif

if _err_level = 0 .and. !storno .and. cont <> "2"
    // vrati broj fiskalnog racuna
    if _fiscal_no > 0
        // prikazi poruku samo u direktnoj stampi
        if __auto = .f. 
           msgbeep( "Kreiran fiskalni racun broj: " + ALLTRIM( STR( _fiscal_no ) ) )
        endif

        // ubaci broj fiskalnog racuna u fakturu
        set_fiscal_no_to_fakt_doks( id_firma, tip_dok, br_dok, _fiscal_no )
    
    endif

    FERASE( __device_params["out_dir"] + _f_name )

endif

return _err_level




// -------------------------------------------------------------
// izdavanje fiskalnog isjecka na HCP uredjaj
// -------------------------------------------------------------
static function fakt_to_hcp( id_firma, tip_dok, br_dok, items, head, storno )
local _err_level := 0
local _fiscal_no := 0

_err_level := hcp_rn( __device_params, items, head, storno, items[ 1, 14 ] )

if _err_level = 0

    _fiscal_no := hcp_fisc_no( __device_params, storno )

    if _fiscal_no > 0
    
        // ubaci broj fiskalnog racuna u fakturu
        set_fiscal_no_to_fakt_doks( id_firma, tip_dok, br_dok, _fiscal_no )
    
    endif

endif

return _err_level



// --------------------------------------------------
// napravi zbirni racun ako je potrebno
// --------------------------------------------------
static function set_fiscal_rn_zbirni( data )
local _tmp := {}
local _total := 0
local _kolicina := 1
local _art_naz := ""
local _len := LEN( data )

if __device_params["vp_sum"] < 1 .or. ;
    __device_params["plu_type"] == "P" .or. ;
    ( __device_params["vp_sum"] > 1 .and. __device_params["vp_sum"] < _len )
    // ova opcija se ne koristi
    // ako je iskljucena opcija
    // ili ako je sifra artikla genericki PLU
    // ili ako je zadato da ide iznad neke vrijednosti stavki na racunu
    return
endif

_art_naz := "St.rn."

if __DRV_CURRENT  $ "#FPRINT#HCP#TRING#"
    _art_naz += " " + ALLTRIM( data[1, 1] )
endif

// ukupna vrijednost racuna za sve stavke matrice je ista popunjena
_total := ROUND2( data[1, 14], 2 )

if !EMPTY( data[1, 8] )
    // ako je storno racun
    // napravi korekciju da je iznos pozitivan
    _total := ABS( _total )
endif

// dodaj u _tmp zbirnu stavku...
AADD( _tmp, { data[1, 1] , ;
    data[1, 2], ;
    "", ;
    _art_naz, ;
    _total, ;
    _kolicina, ;
    data[1, 7], ;
    data[1, 8], ;
    auto_plu( nil, nil, __device_params ), ;
    _total, ;
    0, ;
    "", ;
    data[1, 13], ;
    _total, ;
    data[1, 15], ;
    data[1, 16] } )


data := _tmp

return



// -------------------------------------------------------------------
// setovanje broja fiskalnog racuna u dokumentu 
// -------------------------------------------------------------------
static function set_fiscal_no_to_fakt_doks( cFirma, cTD, cBroj, nFiscal, lStorno )
local nTArea := SELECT()
local _rec

if lStorno == nil
    lStorno := .f.
endif

select fakt_doks
set order to tag "1"
seek cFirma + cTD + cBroj

_rec := dbf_get_rec()

// privremeno, dok ne uvedem polje ovo iskljucujem
if lStorno == .t.
    _rec["fisc_st"] := nFiscal
else
    _rec["fisc_rn"] := nFiscal
endif

update_rec_server_and_dbf( "fakt_doks", _rec, 1, "FULL" )

select (nTArea)
return



// -------------------------------------------------------------
// izdavanje fiskalnog isjecka na TFP uredjaj - tring
// -------------------------------------------------------------
static function fakt_to_tring( id_firma, tip_dok, br_dok, items, head, storno )
local _err_level := 0
local _trig := 1
local _fiscal_no := 0

if storno
    trig := 2
endif

// brisi ulazne fajlove, ako postoje
tring_delete_out( __dev_params, trig )

// ispisi racun
tring_rn( __dev_params, items, head, storno )

// procitaj gresku
_err_level := tring_read_error( __dev_params, @_fiscal_no, trig )

if _fiscal_no <= 0
    _err_level := 1
endif

// pobrisi izlazni fajl
tring_delete_out( __dev_params, trig )

if _err_level <> 0
    // ostavit cu answer fajl za svaki slucaj!
    // pobrisi izlazni fajl ako je ostao !
    msgbeep("Postoji greska sa stampanjem !!!")
else
    tring_delete_answer( __dev_params, trig )
    // ubaci broj fiskalnog racuna u fakturu
    set_fiscal_no_to_fakt_doks( id_firma, tip_dok, br_dok, _fiscal_no )
    msgbeep("Kreiran fiskalni racun broj: " + ALLTRIM(STR( _fiscal_no )))
endif

return _err_level



// ------------------------------------------------------
// posalji racun na fiskalni stampac
// ------------------------------------------------------
static function fakt_to_flink( cFirma, cTipDok, cBrDok )
local aItems := {}
local aTxt := {}
local aPla_data := {}
local aSem_data := {}
local lStorno := .t.
local aMemo := {}
local nBrDok
local nReklRn := 0
local cStPatt := "/S"
local GetList := {}

select fakt_doks
seek cFirma + cTipDok + cBrDok

// ako je storno racun ...
if cStPatt $ ALLTRIM(field->brdok)
    nReklRn := VAL( STRTRAN( ALLTRIM(field->brdok), cStPatt, "" ))  
endif

nBrDok := VAL(ALLTRIM(field->brdok))
nTotal := field->iznos
nNRekRn := 0

if nReklRn <> 0
    Box( , 1, 60)
        @ m_x + 1, m_y + 2 SAY "Broj rekl.fiskalnog racuna:" ;
            GET nNRekRn PICT "99999" VALID ( nNRekRn > 0 )
        read
    BoxC()
endif

select fakt
seek cFirma+cTipDok+cBrDok

nTRec := RECNO()

// da li se radi o storno racunu ?
do while !EOF() .and. field->idfirma == cFirma ;
    .and. field->idtipdok == cTipDok ;
    .and. field->brdok == cBrDok

    if field->kolicina > 0
        lStorno := .f.
        exit
    endif
    
    skip

enddo

// nTipRac = 1 - maloprodaja
// nTipRac = 2 - veleprodaja

// nSemCmd = semafor komanda
//           0 - stampa mp racuna
//           1 - stampa storno mp racuna
//           20 - stampa vp racuna
//           21 - stampa storno vp racuna

nSemCmd := 0
nPartnId := 0

if cTipDok $ "10#"

    // veleprodajni racun

    nTipRac := 2
    
    // daj mi partnera za ovu fakturu
    nPartnId := _g_spart( fakt_doks->idpartner )
    
    // stampa vp racuna
    nSemCmd := 20

    if lStorno == .t.
        // stampa storno vp racuna
        nSemCmd := 21
    endif

elseif cTipDok $ "11#"
    
    // maloprodajni racun

    nTipRac := 1

    // nema parnera
    nPartnId := 0

    // stampa mp racuna
    nSemCmd := 0

    if lStorno == .t.
        // stampa storno mp racuna
        nSemCmd := 1
    endif

endif

// vrati se opet na pocetak
go (nTRec)

// upisi u [items] stavke
do while !EOF() .and. field->idfirma == cFirma ;
    .and. field->idtipdok == cTipDok ;
    .and. field->brdok == cBrDok

    // nastimaj se na robu ...
    select roba
    seek fakt->idroba
    
    select fakt

    // storno identifikator
    nSt_Id := 0

    if ( field->kolicina < 0 ) .and. lStorno == .f.
        nSt_id := 1
    endif
    
    nSifRoba := _g_sdob( field->idroba )
    cNazRoba := ALLTRIM( to_xml_encoding( roba->naz ) )
    cBarKod := ALLTRIM( roba->barkod )
    nGrRoba := 1
    nPorStopa := 1
    nR_cijena := ABS( field->cijena )
    nR_kolicina := ABS( field->kolicina )

    AADD( aItems, { nBrDok , ;
            nTipRac, ;
            nSt_id, ;
            nSifRoba, ;
            cNazRoba, ;
            cBarKod, ;
            nGrRoba, ;
            nPorStopa, ;
            nR_cijena, ;
            nR_kolicina } )

    skip
enddo

// tip placanja
// --------------------
// 0 - gotovina
// 1 - cek
// 2 - kartica
// 3 - virman

nTipPla := 0

if lStorno == .f.
    // povrat novca
    nPovrat := 0    
    // uplaceno novca
    nUplaceno := nTotal
else
    // povrat novca
    nPovrat := nTotal   
    // uplaceno novca
    nUplaceno := 0
endif

// upisi u [pla_data] stavke
AADD( aPla_data, { nBrDok, ;
        nTipRac, ;
        nTipPla, ;
        ABS(nUplaceno), ;
        ABS(nTotal), ;
        ABS(nPovrat) })

// RACUN.MEM data
AADD( aTxt, { "fakt: " + cTipDok + "-" + cBrDok } )

// reklamni racun uzmi sa box-a
nReklRn := nNRekRn
// print memo od - do
nPrMemoOd := 1
nPrMemoDo := 1

// upisi stavke za [semafor]
AADD( aSem_data, { nBrDok, ;
        nSemCmd, ;
        nPrMemoOd, ;
        nPrMemoDo, ;
        nPartnId, ;
        nReklRn })


if nTipRac = 2
    
    // veleprodaja
    // posalji na fiskalni stampac...
    
    fisc_v_rn( gFC_path, aItems, aTxt, aPla_data, aSem_data )

elseif nTipRac = 1
    
    // maloprodaja
    // posalji na fiskalni stampac
    
    fisc_m_rn( gFC_path, aItems, aTxt, aPla_data, aSem_data )

endif

return


// --------------------------------------------------------
// vraca broj fiskalnog isjecka
// --------------------------------------------------------
function fisc_isjecak( cFirma, cTipDok, cBrDok )
local nTArea   := SELECT()
local nFisc_no := 0

select fakt_doks
go top
seek cFirma + cTipDok + cBrDok

if  FOUND() 
    // ako postoji broj reklamnog racuna, onda uzmi taj
    if field->fisc_st <> 0
        nFisc_no := field->fisc_st
    else
        nFisc_no := field->fisc_rn
    endif
endif

select (nTArea)
return ALLTRIM( STR( nFisc_no ) )


// ------------------------------------------------------
// posalji email 
// ------------------------------------------------------
static function _snd_eml( fisc_rn, fakt_dok, kupac, eml_file, u_total )
local _subject, _body
local _mail_param
local _to := ALLTRIM( param_racun_na_email() )

_subject := "Racun: "
_subject += ALLTRIM(STR(fisc_rn))
_subject += ", " + fakt_dok 
_subject += ", " + to_xml_encoding( kupac ) 
_subject += ", iznos: " + ALLTRIM(STR(u_total,12,2))
_subject += " KM" 

_body := "podaci kupca i racuna"

_mail_param := f18_email_prepare( _subject, _body, nil, _to )

f18_email_send( _mail_param, nil )

return nil


// ------------------------------------------------
// vraca sifru dobavljaca
// ------------------------------------------------
static function _g_sdob( id_roba )
local _ret := 0
local _t_area := SELECT()
select roba
seek id_roba

if FOUND()
    _ret := VAL( ALLTRIM( field->sifradob ) )
endif

select (_t_area)
return _ret


// ------------------------------------------------
// vraca sifru partnera
// ------------------------------------------------
static function _g_spart( id_partner )
local _ret := 0
local _tmp

_tmp := RIGHT( ALLTRIM( id_partner ), 5 )
_ret := VAL( _tmp )

return _ret



