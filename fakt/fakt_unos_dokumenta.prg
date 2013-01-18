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
#include "f18_separator.ch"


static __fiscal_marker := .f.

static __id_firma
static __tip_dok
static __br_dok
static __r_br

static __enter_seq := CHR( K_ENTER ) + CHR( K_ENTER ) + CHR( K_ENTER )

static __redni_broj


// -----------------------------------------------------------------
// glavna funkcija za poziv pripreme i knjizenje fakture
// -----------------------------------------------------------------
function fakt_unos_dokumenta()
local _i, _x_pos, _y_pos, _x, _y
local _sep := BROWSE_COL_SEP
private ImeKol, Kol


o_fakt_edit()

select fakt_pripr

// unos inventure
if field->idtipdok == "IM"
    close all
    FaUnosInv()
    return
endif

private ImeKol := { ;
          {"Red.br"      ,  {|| Rbr()                   } }, ;
          {"Partner/Roba",  {|| Part1Stavka() + Roba()  } }, ;
          {"Kolicina"    ,  {|| kolicina                } }, ;
          {"Cijena"      ,  {|| Cijena                  } , "cijena"    }, ;
          {"Rabat"       ,  {|| Rabat                   } , "Rabat"     }, ;
          {"Porez"       ,  {|| Porez                   } , "porez"     }, ;
          {"RJ"          ,  {|| idfirma                 } , "idfirma"   }, ;
          {"Serbr",         {|| SerBr                   } , "serbr"     }, ;
          {"Partn",         {|| IdPartner               } , "IdPartner" }, ;
          {"IdTipDok",      {|| IdTipDok                } , "Idtipdok"  }, ;
          {"DinDem",        {|| dindem                  } , "dindem"    }, ;
          {"Brdok",         {|| Brdok                   } , "Brdok"     }, ;
          {"DatDok",        {|| DATDOK                  } , "DATDOK"    } ;
        }

if fakt_pripr->(fieldpos("idrelac")) <> 0
    AADD( ImeKol , { "ID relac.", {|| idrelac  }, "IDRELAC"  } )
endif

Kol := {}
for _i := 1 to LEN( ImeKol )
    AADD( Kol, _i )
next

// inicijalizacija staticki varijabli...
// marker fiskalnih racuna
__fiscal_marker := .f.

// podaci dokumenta
__id_firma  := field->idfirma
__tip_dok := field->idtipdok
__br_dok  := field->brdok
__r_br := field->rbr

_x := MAXROWS() - 4
_y := MAXCOLS() - 3

Box( , _x, _y )

	_opt_d := ( _y / 4 ) 
	
	_opt_row := PADR( "<c+N> Nova stavka", _opt_d ) + _sep
	_opt_row += PADR( "<ENT> Ispravka", _opt_d ) + _sep
	_opt_row += PADR( hb_utf8tostr("<c+T> Briši stavku"), _opt_d ) + _sep

	@ m_x + _x - 4, m_y + 2 SAY _opt_row

	_opt_row := PADR( "<c+A> Ispravka dok.", _opt_d ) + _sep
	_opt_row += PADR( hb_utf8tostr("<c+P> Štampa (txt)"), _opt_d ) + _sep
	_opt_row += PADR( "<A> Asistent", _opt_d ) + _sep

	@ m_x + _x - 3, m_y + 2 SAY _opt_row 

	_opt_row := PADR( hb_utf8tostr("<a+A> Ažuriranje"), _opt_d ) + _sep
	_opt_row += PADR( hb_utf8tostr("<c+F9> Briši sve"), _opt_d ) + _sep
	_opt_row += PADR( "<F5> Kontrola zbira", _opt_d ) + _sep
	_opt_row += "<T> total dokumenta"

	@ m_x + _x - 2, m_y + 2 SAY _opt_row

	_opt_row := PADR( "<R> Rezervacija", _opt_d ) + _sep
	_opt_row += PADR( "<X> Prekid rez.", _opt_d ) + _sep
	_opt_row += PADR( "<F10> Ostale opcije", _opt_d ) + _sep
	_opt_row += "<O> Konverzije"

	@ m_x + _x - 1, m_y + 2 SAY _opt_row

	ObjDbedit( "PNal", _x, _y , {|| fakt_pripr_keyhandler() }, "", "Priprema...", , , , , 4 )

BoxC()

close all

return



// ------------------------------------------------------------
// tabela pripreme - key handler
// ------------------------------------------------------------
static function fakt_pripr_keyhandler()
local _rec
local _ret
local cPom
local _fakt_doks := {}
local _dev_id := 0
local _dev_params
local _fiscal_use := fiscal_opt_active()
local _items_atrib := hb_hash()
local _params := fakt_params()
local _dok := hb_hash()

if ( Ch == K_ENTER .and. EMPTY( field->brdok ) .and. EMPTY( field->rbr ) )
    return DE_CONT
endif


select fakt_pripr

do case

    case __fiscal_marker == .t.
    
        __fiscal_marker := .f.

        if !_fiscal_use 
            return DE_CONT
        endif

        if fakt_pripr->(reccount()) <> 0
            // priprema nije prazna, nema stampanja racuna
            MsgBeep("Priprema nije prazna, stampa fisk.racuna nije moguca!")
            return DE_CONT
        endif

        if Pitanje(, "Odstampati racun na fiskalni printer ?", "D" ) == "N"
            return DE_CONT
        endif

        // pronadji mi device_id 
        _dev_id := get_fiscal_device( my_user(), __tip_dok )

        if _dev_id > 0

            // setuj parametre za stampu
            _dev_params := get_fiscal_device_params( _dev_id, my_user() )
            
            // nesto nije ok sa parametrima
            if _dev_params == NIL
                return DE_CONT
            endif

        else
            MsgBeep( "Problem sa citanjem fiskalnih parametara !!!" )
            return DE_CONT
        endif

        // da li je korisniku dozvoljeno da stampa racune ?
        if _dev_params["print_fiscal"] == "N"
            MsgBeep( "Nije Vam dozvoljena opcija za stampu fiskalnih racuna !" )
            return DE_CONT
        endif
        
        MsgO( "stampa na fiskalni printer u toku..." )

        // posalji na fiskalni uredjaj
        fakt_fisc_rn( __id_firma, __tip_dok, __br_dok, .f., _dev_params )

        MsgC()

        select fakt_pripr
    
        if _dev_params["print_a4"] $ "D#G#X"
            
            if _dev_params["print_a4"] $ "D#X" .and. Pitanje(,"Stampati fakturu ?", "N") == "D"
                // stampaj dokument odmah nakon fiskalnog racuna
                StampTXT( __id_firma, __tip_dok, __br_dok )
                close all
                o_fakt_edit()
                select fakt_pripr
            endif
        
            if _dev_params["print_a4"] $ "G#X" .and. Pitanje(,"Stampati graficku fakturu ?", "N") == "D"
                stdokodt( __id_firma, __tip_dok, __br_dok )
                close all 
                o_fakt_edit()
                select fakt_pripr
            endif

            return DE_REFRESH
        
        endif
    
        return DE_CONT
   
    // Total dokumenta
	case UPPER( CHR( Ch ) ) == "T"

		// total dokumenta box
		_total_dokumenta()
		return DE_REFRESH
 
    // brisi stavku iz pripreme
    case ( Ch == K_CTRL_T )

        if fakt_brisi_stavku_pripreme() == 1
            return DE_REFRESH
        else
            return DE_CONT
        endif

    // ispravka stavke
    case Ch == K_ENTER 

        Box( "ist", MAXROWS() - 10, MAXCOLS() - 10, .f. )

        set_global_vars_from_dbf( "_" )
        _dok["idfirma"] := _idfirma
        _dok["idtipdok"] := _idtipdok
        _dok["brdok"] := _brdok
        _dok["rbr"] := _rbr  

        __redni_broj := RbrUnum( _rbr )

        if _params["fakt_opis_stavke"]
            _items_atrib["opis"] := get_fakt_atribut_opis( _dok, .f.)
        endif

        if _params["ref_lot"]
            _items_atrib["ref"] := get_fakt_atribut_ref( _dok, .f. )
            _items_atrib["lot"] := get_fakt_atribut_lot( _dok, .f. )
        endif

        if edit_fakt_priprema( .f., @_items_atrib ) == 0
            _ret := DE_CONT
        else
            
            // ubaci mi atribute u fakt_atribute
            fakt_atrib_hash_to_dbf( _idfirma, _idtipdok, _brdok, _rbr, _items_atrib )
            
            _rec := get_dbf_global_memvars("_")

            dbf_update_rec( _rec, .f. )

            PrCijSif()  

            // izmjeni sve stavke dokumenta na osnovu prve stavke        
            if __redni_broj == 1
                // todo: cim prije i ovo zavrsiti, za sada gasim opciju
                _new_dok := dbf_get_rec()
                izmjeni_sve_stavke_dokumenta( _dok, _new_dok )
            endif

            _ret := DE_REFRESH

        endif

        BoxC()

        return _ret


    // cirkularna ispravka stavki....
    case Ch == K_CTRL_A

        fakt_prodji_kroz_stavke()
        return DE_REFRESH

    // unos nove stavke
    case Ch == K_CTRL_N
   
        fakt_unos_nove_stavke()
        return DE_REFRESH

    // stampanje dokumenta
    case Ch == K_CTRL_P
       
        // prvo setuj broj dokumenta
        fakt_set_broj_dokumenta()
        otpremnica_22_brojac()

        // printaj dokument
        fakt_print_dokument()

        #ifdef TEST
            push_test_tag( "FAKT_CTRLP_END" )  
        #endif
        
        return DE_REFRESH


    // stampanje labela
    case Ch == K_ALT_L
  
          close all
          label_bkod()
          o_fakt_edit()

    // stampa graficke fakture
    case Ch == K_ALT_P
        
        // setuj broj dokumenta u pripremi ako vec nije
        fakt_set_broj_dokumenta()
        otpremnica_22_brojac()

        if !CijeneOK( "Stampanje" )
            return DE_REFRESH
        endif
            
        if field->idtipdok == "13"
            FaktStOLPP()
        else
            StDokOdt( nil, nil, nil )
        endif
            
        o_fakt_edit()
           
        #ifdef TEST
            push_test_tag("FAKT_ALTP_END") 
        #endif
        
        return DE_REFRESH

    // azuriranje dokumenta
    case Ch == K_ALT_A

        // setuj prvo broj dokumenta u pripremi...
        fakt_set_broj_dokumenta()
        otpremnica_22_brojac()
        // setuj podatke za fiskalni racun
        __id_firma  := field->idfirma
        __tip_dok := field->idtipdok
        __br_dok  := field->brdok

        if !CijeneOK( "Azuriranje" )
            return DE_REFRESH
        endif
            
        CLOSE ALL
            
        // funkcija azuriranja vraca matricu sa podacima dokumenta
        _fakt_doks := azur_fakt()
        
        o_fakt_edit() 
        
        if _fiscal_use .and. __tip_dok $ "10#11" .and. _fakt_doks <> NIL
            
            if LEN( _fakt_doks ) > 0

                __id_firma := _fakt_doks[ 1, 1 ] 
                __tip_dok := _fakt_doks[ 1, 2 ] 
                __br_dok := _fakt_doks[ 1, 3 ] 
      
                __fiscal_marker := .t.         
            
            endif
      
        endif
        
        return DE_REFRESH


    // brisanje kompletne pripreme
    case Ch == K_CTRL_F9
        
        fakt_brisanje_pripreme()
        return DE_REFRESH
        

    // kontrola zbira podataka
    case Ch == K_F5

        // ovo treba napraviti kako treba !!!!!            
        fakt_kzb()    
        return DE_CONT
        

    // generisanje racuna na osnovu otpremnice      
    case UPPER( CHR( Ch ) ) == "O"

        _t_area := SELECT()
       
 
        // stari parametar...
        if !_params["fakt_otpr_gen"]
            fakt_generisi_racun_iz_otpremnice() 
        else
            _fakt_doks := FaktDokumenti():New()
            _fakt_doks:pretvori_otpremnice_u_racun()
        endif

        select (_t_area )
        return DE_REFRESH
    
    // asistent 
    case UPPER( CHR( Ch ) ) == "A"

        private _broj_entera := 30

        for _i := 1 to INT(RecCount2()/15)+1
            _sekv := CHR( K_CTRL_A )
            for _n := 1 to MIN(RecCount2(),15)*20
                _sekv += __enter_seq
            next
            keyboard _sekv
        next
        
        return DE_REFRESH
         

    // ostale opcije nad dokumentom
#ifdef __PLATFORM__DARWIN 
    case Ch == ASC("0")
#else
    case Ch == K_F10
#endif

        popup_fakt_unos_dokumenta()
        SETLASTKEY(K_CTRL_PGDN)
        return DE_REFRESH
    

    // pregled smeca
    case Ch == K_F11

        // pregled smeca
        Pripr9View()
        
        select fakt_pripr
        go top
        
        return DE_REFRESH


    // narudzbenica
    case Ch == K_ALT_N
    
        // prvo mi stampaj dokument
        stdokpdv( nil, nil, nil, .t. )

        // pa onda ostalo...       	
        select fakt_pripr
        _t_rec := RECNO()
        GO TOP
        nar_print(.t.)
        o_fakt_edit()
        select fakt_pripr
        GO (_t_rec)
        return DE_CONT


    // radni nalog
    case Ch == K_CTRL_R

        // prvo mi stampaj dokument 
        stdokpdv( nil, nil, nil, .t. )

        // pa onda ostalo
        select fakt_pripr
        _t_rec := RECNO()
        GO TOP
        rnal_print(.t.)
        o_fakt_edit()
        select fakt_pripr
        GO (_t_rec)
        return DE_CONT


    // export dokumenta
    case Ch == K_ALT_E
        
        if Pitanje(,"Exportovati dokument u xls ?", "D" ) == "D"
            
            exp_dok2dbf()
            o_fakt_edit()
   
            select fakt_pripr
            go top

        endif
        
        return DE_CONT

endcase

return DE_CONT


// -----------------------------------------------------------------
// promjeni brojac dokumenta za dokumente tip-a 12
// -----------------------------------------------------------------
static function otpremnica_22_brojac()
local _fakt_params := fakt_params()

if field->idtipdok == "12" .and. _fakt_params["fakt_otpr_22_brojac"]

    _novi_broj := fakt_novi_broj_dokumenta( field->idfirma, "22" )

    do while !EOF()
        _rec := dbf_get_rec()
        _rec["brdok"] := _novi_broj
        dbf_update_rec( _rec )
        skip
    enddo

endif

return .t.



// --------------------------------------------------
// prolazak kroz stavke pripreme
// --------------------------------------------------
static function fakt_prodji_kroz_stavke()
local _dug
local _rec_no, _rec

PushWA()

select fakt_pripr

Box(, 22, 75, .f., "")

_dug := 0

do while !EOF()

    skip
    _rec_no := RECNO()
    skip - 1
        
    set_global_vars_from_dbf( "_" )

    _podbr := SPACE(2)

    __redni_broj := RbrUnum( _rbr )

    BoxCLS()

    if edit_fakt_priprema( .f. ) == 0
        exit
    endif

    _dug += ROUND( _cijena * _kolicina * PrerCij() * ;
            ( 1 - _rabat / 100 ) * ( 1 + _porez / 100), ZAOKRUZENJE )

    @ m_x + 23, m_y + 2 SAY "ZBIR DOKUMENTA:"
    @ m_x + 23, col() + 1 SAY _dug PICT "9 999 999 999.99"

    InkeySc( 10 )

    select fakt_pripr

    _rec := get_dbf_global_memvars("_")
    dbf_update_rec( _rec, .f. )

    // ako treba, promijeni cijenu u sifrarniku
    PrCijSif() 

    go _rec_no

enddo

PopWA()
BoxC()

return



// -----------------------------------------------------------
// unos novih stavki fakture
// -----------------------------------------------------------
static function fakt_unos_nove_stavke()
local _items_atrib
local _rec
local _total := 0

go top

do while !EOF() 
    // kompletan nalog sumiram
    _total += ROUND( cijena * kolicina * PrerCij() * ( 1 - rabat/100 ) * ( 1 + porez/100 ), ZAOKRUZENJE )
    skip
enddo

go bottom

Box( "knjn", MAXROWS() - 10, MAXCOLS() - 10, .f., "Unos nove stavke")

do while .t.

    set_global_vars_from_dbf( "_" )

    // podbr treba skroz ugasiti
    _podbr := SPACE(2)

    if ALLTRIM( _podbr ) == "." .and. EMPTY( _idroba )

        __redni_broj := RbrUnum( _rbr )
        _podbr := " 1"

    elseif _podbr >= " 1"

        __redni_broj := RbrUnum( _rbr )
        _podbr := STR( VAL( _podbr ) + 1, 2, 0)

    else

        __redni_broj := RbrUnum( _rbr ) + 1
        _podbr := "  "

    endif

    BoxCLS()

    _items_atrib := hb_hash()

    if edit_fakt_priprema( .t., @_items_atrib ) == 0
        exit
    endif

    _total += ROUND( _cijena * _kolicina * PrerCij() * ( 1 - _rabat/100 ) * ( 1 + _porez/100 ), ZAOKRUZENJE )
    
    @ m_x + MAXROWS() - 11, m_y + 2 SAY "ZBIR DOKUMENTA:"
    @ m_x + MAXROWS() - 11, col() + 2 SAY _total PICT "9 999 999 999.99"

    InkeySc(10)

    select fakt_pripr
    append blank

    _rec := get_dbf_global_memvars("_")
    dbf_update_rec( _rec, .f. )

    // ubaci mi atribute u fakt_atribute
    fakt_atrib_hash_to_dbf( field->idfirma, ;
                            field->idtipdok, ;
                            field->brdok, ;
                            field->rbr, ;
                            _items_atrib )

    // promijeni cijenu u sifrarniku ako treba
    PrCijSif()      

enddo

BoxC()

return


// ---------------------------------------------------
// printanje dokumenta
// ---------------------------------------------------
static function fakt_print_dokument()

o_fakt_edit() 

if !CijeneOK("Stampanje")
    return DE_REFRESH
endif

gPtxtC50 := .f.

StampTXT( nil, nil, nil )

o_fakt_edit()

return


// ----------------------------------------------------
// inicijalizuj varijable iz memo polja txt
// ----------------------------------------------------
static function _init_vars_from_txt_memo()

local _params := fakt_params()
local _memo := ParsMemo(_txt)
local _len := LEN( _memo )

if _len > 0
    _txt1 := _memo[1]
endif
    
if _len >= 2
    _txt2 := _memo[2]
endif
   
if _len >= 9
    _brotp := _memo[6]
    _datotp := CTOD( _memo[7] )
    _brnar := _memo[8]
    _datpl := CTOD( _memo[9] )
endif
    
if _len >= 10 .and. !EMPTY( _memo[10] )
    _vezotpr := _memo[10]
endif
    
if _len >= 11 
    d2k1 := _memo[11]
endif
            
if _len >= 12
    d2k2 := _memo[12]
endif

if _len >= 13
    d2k3 := _memo[13]
endif

if _len >= 14
    d2k4 := _memo[14]
endif

if _len >= 15
    d2k5 := _memo[15]
endif

if _len >= 16
    d2n1 := _memo[16]
endif

if _len >= 17
    d2n2 := _memo[17]
endif

if _params["destinacije"] .and. _len >= 18
    _destinacija := PADR( ALLTRIM( _memo[18] ), 500 )
endif

if _params["fakt_dok_veze"] .and. _len >= 19
    _dokument_veza := PADR( ALLTRIM( _memo[19] ), 500 )
endif

if _params["fakt_objekti"] .and. _len >= 20
    _objekti := PADR( _memo[20], 10 )
endif

return



// ---------------------------------------------------
// sredji memo txt na osnovnu varijabli
// ---------------------------------------------------
static function _set_memo_txt_from_vars()
local _tmp
local _params := fakt_params()

// odsjeci na kraju prazne linije
_txt2 := OdsjPLK( _txt2 )           

if ! "Racun formiran na osnovu" $ _txt2
    _txt2 += CHR(13) + CHR(10) + _vezotpr
endif
    
_txt := CHR(16) + TRIM( _txt1 ) + CHR(17) 
_txt += CHR(16) + _txt2 + CHR(17)
_txt += CHR(16) + "" + CHR(17) 
_txt += CHR(16) + "" + CHR(17)
_txt += CHR(16) + "" + CHR(17)
    
// 6 - br otpr
_txt += CHR(16) + _brotp + CHR(17)
// 7 - dat otpr
_txt += CHR(16) + DTOC( _datotp) + CHR(17)
// 8 - br nar
_txt += CHR(16) + _brnar + CHR(17)
// 9 - dat nar
_txt += CHR(16) + DTOC( _datpl) + CHR(17)
// 10
_txt += CHR(16) + _vezotpr + CHR(17) 
// 11
_txt += CHR(16) + d2k1 + CHR(17) 
// 12
_txt += CHR(16) + d2k2 + CHR(17) 
// 13
_txt += CHR(16) + d2k3 + CHR(17) 
// 14
_txt += CHR(16) + d2k4 + CHR(17) 
// 15
_txt += CHR(16) + d2k5 + CHR(17) 
// 16
_txt += CHR(16) + d2n1 + CHR(17) 
// 17
_txt += CHR(16) + d2n2 + CHR(17) 

if _params["destinacije"]
   _tmp := _destinacija
else
   _tmp := ""
endif

// 18 - Destinacija
_txt += CHR(16) + ALLTRIM( _tmp ) + CHR(17) 

// 19 - vezni dokumenti
if _params["fakt_dok_veze"]
   _tmp := _dokument_veza
else
   _tmp := ""
endif

_txt += CHR(16) + ALLTRIM( _dokument_veza ) + CHR(17)

// 20 - objekti 
if _params["fakt_objekti"]
   _tmp := _objekti
else
   _tmp := ""
endif

_txt += CHR(16) + _tmp + CHR(17)

return


// --------------------------------------------------------
// hendliranje unosa novih stavki u pripremi
// --------------------------------------------------------
static function edit_fakt_priprema( fNovi, items_atrib )
local _a_tipdok := {}
local _h
local _rok_placanja := 0
local _avansni_racun
local _opis := "" 
local _n_menu := IIF( VAL( gIMenu ) < 1, ASC( gIMenu ) - 55, VAL( gIMenu ) )
local _convert := "N"
local _x := 1
local _odabir_txt := .f.
local _lista_uzoraka
local _x2, _part_x, _part_y, _tip_cijene
local _ref_broj, _lot_broj
local _params := fakt_params() 

// daj mi listu tipova dokumenata
_a_tipdok := fakt_tip_dok_arr()
_h := {}
ASIZE( _h, LEN( _a_tipdok ))
AFILL( _h, "" )

// sredi atribute kod unosa
if items_atrib <> NIL

    // opis fakture
    if _params["fakt_opis_stavke"]
        if fNovi
            _opis := PADR( "", 300 )
        else
            _opis := PADR( items_atrib["opis"], 300 )
        endif
    endif

    // ref/lot brojevi
    if _params["ref_lot"]

        if fNovi
            _ref_broj := PADR( "", 50 )
            _lot_broj := PADR( "", 50 )
        else
            _ref_broj := PADR( items_atrib["ref"], 50 )
            _lot_broj := PADR( items_atrib["lot"], 50 )
        endif
    endif

endif

// dodatne varijable koje ce se koristiti kod unosa
_txt1 := ""
_txt2 := ""   
_brotp := SPACE(50)
_datotp := CTOD("")
_brnar := SPACE(50)
_datpl := CTOD("")
_vezotpr := ""
_destinacija := ""
_dokument_veza := ""
_objekti := ""

// doks2 varijable
d2k1 := SPACE(15)
d2k2 := SPACE(15)
d2k3 := SPACE(15)
d2k4 := SPACE(20)
d2k5 := SPACE(20)
d2n1 := SPACE(12)
d2n2 := SPACE(12)

set cursor on
 
// prva stavka
if fNovi 

    _convert := "D"
    _serbr := SPACE( LEN( field->serbr ) )

    if _params["destinacije"]
       _destinacija := PADR( "", 500 )
    endif

    if _params["fakt_dok_veze"]
         _dokument_veza := PADR( "", 500 )
    endif

    if _params["fakt_objekti"]
        _objekti := SPACE(10)
    endif

    _cijena := 0
    _kolicina := 0

    // ako je ovaj parametar ukljucen ponisti polje roba
    if gResetRoba == "D"
        _idRoba := SPACE(10)
    endif
 
    if __redni_broj == 1

        _n_menu := IIF( VAL( gIMenu ) < 1, ASC( gIMenu ) - 55, VAL( gIMenu ) )
        _idfirma := gFirma

	    if !EMPTY(_params["def_rj"])
		    _idfirma := _params["def_rj"]
	    endif

        _idtipdok := "10"
        _datdok := DATE()
        _zaokr := 2
        _dindem := LEFT( ValBazna(), 3 )
        _m1 := " "  
        // broj dokumenta u pripremi ce biti uvijek 00000
        _brdok := PADR( REPLICATE( "0", gNumDio ), 8 )

    endif

else

    // _txt -> _vars
    _init_vars_from_txt_memo()
    // meni opcija
    _n_menu := ASCAN( _a_tipdok, {|x| _idtipdok == LEFT( x, 2 ) } )

endif

// podbroj
_podbr := SPACE(2)
// tip rabata
_tip_rabat := "%"

// definisanje header-a fakture
// =================================================

if ( __redni_broj == 1 .and. VAL( _podbr ) < 1 )

    if RECCOUNT() == 0
       	_idFirma := gFirma
    endif

	if !EMPTY(_params["def_rj"])
		_idfirma := _params["def_rj"]
	endif

    @ m_x + _x, m_y + 2 SAY PADR( gNFirma, 20 )

    @ m_x + _x, col() + 2 SAY " RJ:" GET _idfirma ;
                        PICT "@!" ;
                        VALID {|| EMPTY( _idfirma ) .or. _idfirma == gFirma ;
                            .or. P_RJ( @_idfirma ) .and. V_Rj(), _idfirma := LEFT( _idfirma, 2 ), .t. }

    read
    
    __mx := m_x
    __my := m_y
    
    // odaberi dokument !
    _n_menu := Menu2( 5, 30, _a_tipdok, _n_menu )
    
    m_x := __mx
    m_y := __my
        
    ESC_RETURN 0
        
    // tip dokumenta je 
    _idtipdok := LEFT( _a_tipdok[ _n_menu ], 2 )

    ++ _x

    @ m_x + _x, m_y + 2 SAY PADR( _a_tipdok[ ASCAN( _a_tipdok, {|x| _idtipdok == LEFT( x, 2 ) } ) ], 40 )
    

    // nesto oko dokumenta tipa "13"
    // koristit ce se partner ili konto ????

    if ( _idtipdok == "13" .and. gVar13 == "2" )

        if gVarNum == "2"
            
            @ m_x + 1, 57 SAY "Prodavn.konto" GET _idpartner VALID P_Konto( @_idpartner )        
            read
            _idpartner := LEFT( _idpartner, 6 )
 
        elseif gVarNum == "1"
            
            _idPartner := IF( EMPTY( _idpartner ), "P1", RJIzKonta( _idpartner + " " ) )
            @ m_x + 1, 57 SAY "RJ - objekat:" GET _idpartner VALID P_RJ( @_idpartner) PICT "@!"
            read
            _idpartner := PADR( KontoIzRJ( _idpartner ), 6 )
       
        endif

    endif

    do while .t.    
        
        _x := 2
        
        // datum, broj dokumenta
        @  m_x + _x, m_y + 45 SAY "Datum:" GET _datdok
        @  m_x + _x, col() + 1 SAY "Broj:" GET _brdok VALID !EMPTY( _brdok ) 
        
        ++ _x
        ++ _x

        // partner
        @ _part_x := m_x + _x, _part_y := m_y + 2 SAY "Partner:" GET _idpartner ;
                PICT "@!" ;
                VALID {|| P_Firma( @_idpartner ), ;
                            IzSifre(), ;
                            ispisi_partn( _idpartner, _part_x, _part_y + 18 ) }
            
        ++ _x
        ++ _x
      
        if _params["fakt_prodajna_mjesta"]
            // prodajno mjesto, PM
            @ m_x + _x, m_y + 2 SAY "P.M.:" GET _idpm ;
                    VALID {|| P_IDPM( @_idpm, _idpartner ) } ;
                    PICT "@S10"
        endif

        if _params["fakt_dok_veze"]
            // veza dokumenti
            @ m_x + _x, col() + 1 SAY "Vezni dok.:" GET _dokument_veza ;
                    PICT "@S20"
        endif

        ++ _x
        if _params["destinacije"]
            // destinacija 
            @ m_x + _x, m_y + 2 SAY "Dest:" GET _destinacija ;
                    PICT "@S20"
        endif

        if ( _params["fakt_objekti"] .and. _idtipdok $ "10#11#12#13" )
            // radni nalog
            @ m_x + _x, col() + 1 SAY "Objekat:" GET _objekti ;
                    VALID p_fakt_objekti( @_objekti ) ;
                    PICT "@!"
        endif

        _x2 := 4
        
        // sada ide desna strana i podaci isporuke...
        if _idtipdok $ "10#11"
            
            @ m_x + _x2, m_y + 51 SAY "Otpremnica broj:" GET _brotp PICT "@S20" WHEN W_BrOtp( fNovi )
                
            ++ _x2

            @ m_x + _x2, m_y + 51 SAY "          datum:" GET _datotp

            ++ _x2     
               
            @ m_x + _x2, m_y + 51 SAY "Ugovor/narudzba:" GET _brnar PICT "@S20"
                
            if fNovi .and. gRokPl > 0
                // uzmi default vrijednost za rok placanja
                _rok_placanja := gRokPl    
            endif

            ++ _x2    

            @ m_x + _x2, m_y + 51 SAY "Rok plac.(dana):" GET _rok_placanja PICT "999" ;
                    WHEN valid_rok_placanja( @_rok_placanja, "0", fNovi ) ;
                    VALID valid_rok_placanja( _rok_placanja, "1", fNovi )

            ++ _x2

            @ m_x + _x2, m_y + 51 SAY "Datum placanja :" GET _datpl ;
                    VALID valid_rok_placanja( _rok_placanja, "2", fNovi )
                
            if _params["fakt_vrste_placanja"]

                ++ _x
                @ m_x + _x, m_y + 2  SAY "Nacin placanja" GET _idvrstep PICT "@!" VALID P_VRSTEP( @_idvrstep, 9, 20 )

            endif
       

        // za dokument tipa "06"
        elseif ( _idtipdok == "06" )
                
            ++ _x2

            @ m_x + _x2, m_y + 51 SAY "Po ul.fakt.broj:" GET _brotp PICT "@S20" WHEN W_BrOtp( fNovi )

            ++ _x2

            @ m_x + _x2, m_y + 51 SAY "       i UCD-u :" GET _brnar PICT "@S20"
        
        else
            
            // dodaj i za ostale dokumente
            _datotp := _datdok
            ++ _x2
            @ m_x + _x2 ,m_y + 51 SAY " datum isporuke:" GET _datotp

        endif

        // relacije .... ovo treba zamjeniti sa novom funkcijom
        if ( fakt_pripr->(FIELDPOS("idrelac") ) <> 0 .and. _idtipdok $ "#11#" )
            ++ _x
            @ m_x + _x, m_y + 50  SAY "Relacija   :" GET _idrelac PICT "@S10"
        endif

        ++ _x
        ++ _x
        ++ _x

        // valuta
        if _idTipDok $ "10#11#12#19#20#25#26#27"
            @ m_x + _x, m_y + 2 SAY "Valuta ?" GET _dindem PICT "@!" 
        else
            @ m_x + _x, m_y + 2 SAY " "
        endif
        
        // avansni racun
        if _idtipdok $ "10"
        
            _avansni_racun := "N"

            if _idvrstep == "AV"
                _avansni_racun := "D"
            endif
            
            @ m_x + _x, col() + 4 SAY "Avansni racun (D/N)?:" GET _avansni_racun PICT "@!" ;
                        VALID _avansni_racun $ "DN"
        
        endif
            
        // ako nije ukljucena opcija ispravke partnera 
        // pri unosu dokumenta
        if ( gIspPart == "N" )
            read
        endif
      
        ESC_RETURN 0

        select fakt_pripr
      
        exit
   
    enddo
   
else

    @ m_x + _x, m_y + 2 SAY PADR( gNFirma, 20 )
    
    ?? "  RJ:", _idfirma
    
    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY PADR( _a_tipdok[ ASCAN( _a_tipdok, { |x| _idtipdok == LEFT( x, 2 ) } ) ], 35 )

    @ m_x + _x, m_y + 45 SAY "Datum: "
    ?? _datdok

    @ m_x + _x, col() + 1 SAY "Broj: "
    ?? _brdok
    
    _txt2 := ""

endif

// unos stavki dokumenta pocinje ovdje
// ================================================

_x := 13

// unos stavki dokumenta
@ m_x + _x, m_y + 2 SAY "R.br: " GET __redni_broj PICT "9999"

++ _x
++ _x

// artikal
@ m_x + _x, m_y + 2  SAY "Artikal: " GET _IdRoba PICT "@!S10" ;
    WHEN {|| _idroba := PADR( _idroba, VAL( gDuzSifIni )), W_Roba() } ;
    VALID {|| _idroba := IIF( LEN( TRIM( _idroba )) < VAL( gDuzSifIni), ;
            LEFT( _idroba, VAL(gDuzSifIni) ), _idroba ), ;
            V_Roba(), ;
            artikal_kao_usluga(fnovi), ;
            NijeDupla(fNovi), ;
            zadnji_izlazi_info( _idpartner, _idroba, "F" ), ; 
            _trenutno_na_stanju_kalk( _idfirma, _idtipdok, _idroba ) ;
         }


++ _x

// serijski broj
if ( gSamokol != "D" .and. !glDistrib )
    @ m_x + _x, m_y + 2 SAY get_serbr_opis() + " " GET _serbr PICT "@S15" WHEN _podbr <> " ."
endif

_tip_cijene := "1"

// tip cijene
if ( gVarC $ "123" .and. _idtipdok $ "10#12#20#21#25" )
    @ m_x + _x, m_y + 59 SAY "Cijena (1/2/3):" GET _tip_cijene
endif

// unos opisa stavke po fakturama
if _params["fakt_opis_stavke"]
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Opis:" GET _opis PICT "@S50"
endif

if _params["ref_lot"]
    ++ _x
    @ m_x + _x, m_y + 2 SAY "REF:" GET _ref_broj PICT "@S10"
    @ m_x + _x, m_y + 2 SAY "/ LOT:" GET _lot_broj PICT "@S10"
endif

++ _x
++ _x    
++ _x

// kolicina
@ m_x + _x, m_y + 2 SAY "Kolicina "  GET _kolicina PICT pickol VALID V_Kolicina( _tip_cijene )
    

if gSamokol != "D"

    // cijena
    @ m_x + _x, col() + 2 SAY IF( _idtipdok $ "13#23" .and. ( gVar13 == "2" .or. glCij13Mpc ), ;
                "MPC.s.PDV", "Cijena (" + ALLTRIM( ValDomaca() ) + ")" ) GET _cijena ;
                PICT piccdem ;
                WHEN  _podbr <> " ." ;
                VALID c_cijena( _cijena, _idtipdok, fNovi )


    // preracunavanje valute
    if ( PADR(_dindem, 3) <> PADR( ValDomaca(), 3) ) 
        @ m_x + _x, col() + 2 SAY "Pr"  GET _convert ;
                PICT "@!" ;
                VALID v_pretvori( @_convert, _dindem, _datdok, @_cijena )
    endif
             
    // rabat
    if !( _idtipdok $ "12#13" ) .or. ( _idtipdok == "12".and. gV12Por == "D" )

        @ m_x + _x, col() + 2 SAY "Rabat" GET _rabat PICT piccdem ;
                 WHEN _podbr <> " ." .and. ! _idtipdok $ "15"
            
        @ m_x + _x, col() + 1 GET _tip_rabat PICT "@!" ;
                 WHEN {|| _tip_rabat := "%", ! _idtipdok$ "11#27#15" .and. _podbr <> " ." } ;
                 VALID _tip_rabat $ "% AUCI" .and. V_Rabat( _tip_rabat ) 
        
    endif
        
endif

read

if _avansni_racun == "D"
    _idvrstep := "AV"
endif

ESC_RETURN 0

// uzorci na fakturi....
_odabir_txt := .t.

if _IdTipDok $ "13" .or. gSamoKol == "D"
    _odabir_txt := .f.
endif

if _idtipdok == "12"
    if IsKomision( _idpartner )
        _odabir_txt := .t.
    else
        _odabir_txt := .f.
    endif
endif

if _odabir_txt
    // uzmi odgovarajucu listu
    _lista_uzoraka := g_txt_tipdok( _idtipdok )
    // unesi tekst
    UzorTxt2( _lista_uzoraka, __redni_broj )
endif

if ( _podbr == " ." .or. roba->tip = "U" .or. ( __redni_broj == 1 .and. val(_podbr)<1) )
    // setuj memo txt na osnovu varijabli
    _set_memo_txt_from_vars()
else
    _txt := ""
endif

_rbr := RedniBroj( __redni_broj )

// snimi atribute u hash matricu....
// opis stavke
if _params["fakt_opis_stavke"]
    items_atrib["opis"] := _opis
endif
// ref/lot brojevi
if _params["ref_lot"]
    items_atrib["ref"] := _ref_broj
    items_atrib["lot"] := _lot_broj
endif

return 1





// ------------------------------------------------------------
// trentno stanje artikla u kalkulacijama
// ------------------------------------------------------------
static function _trenutno_na_stanju_kalk( id_rj, tip_dok, id_roba )
local _stanje := NIL
local _id_konto := ""
local _t_area := SELECT()
local _color := "W/N+"

select rj
set order to tag "ID"
go top
seek id_rj

select fakt_pripr

if EMPTY( rj->konto )
    return .t.
endif

_id_konto := rj->konto

select ( _t_area )

if tip_dok $ "10#12"
    // izvuci mi stanje artikla iz kalk
    // magacinski dokumenti
    _stanje := kalk_kol_stanje_artikla_magacin( _id_konto, id_roba, DATE() )
elseif tip_dok $ "11#13"
    // ovo su prodavnicki dokumenti
    _stanje := kalk_kol_stanje_artikla_prodavnica( _id_konto, id_roba, DATE() )
endif

// ispisi stanje artikla
if _stanje <> NIL

    if _stanje <= 0
        _color := "W/R+"
    endif

	@ m_x + 17, m_y + 28 SAY PADR( "", 60 )
	@ m_x + 17, m_y + 28 SAY "Na stanju konta " + ;
                            ALLTRIM( _id_konto ) + " : "
    @ m_x + 17, col() + 1 SAY ALLTRIM(STR(_stanje, 12, 3)) + " " + PADR( roba->jmj, 3 ) COLOR _color
endif

return .t.





// ------------------------------------------
// ispisi partnera 
// ------------------------------------------
function ispisi_partn( cPartn, nX, nY )
local nTArea := SELECT()
local cDesc := "..."
select partn
seek cPartn

if FOUND()
    cDesc := ALLTRIM( field->naz )
    if LEN( cDesc ) > 13
        cDesc := PADR( cDesc, 12 ) + "..."
    endif
endif

@ nX, nY SAY PADR( cDesc, 15 )

select (nTArea)
return .t.


static function _f_idpm( cIdPm )
cIdPM := UPPER(cIdPM)  
return .t.




// ---------------------------------------------
// vraca listu za odredjeni tip dok
// ---------------------------------------------
function g_txt_tipdok( cIdTd )
local cList := ""
local cVal
private cTmptxt

if !EMPTY( cIdTd ) .and. cIdTD $ "10#11#12#13#15#16#20#21#22#23#25#26#27"
    
    cTmptxt := "g" + cIdTd + "ftxt"
    cVal := &cTmptxt

    if !EMPTY( cVal )
        cList := ALLTRIM( cVal )
    endif

endif

return cList



// -------------------------------------------------
// validacija roka placanja
// -------------------------------------------------
function valid_rok_placanja( rok_pl, var, novi )
local _rok_pl_nula := .t.

// ako je dozvoljen rok.placanja samo > 0
if gVFRP0 == "D"
    _rok_pl_nula := .f.
endif

if var == "0"   

    if rok_pl < 0
        return .t.   
    endif

    if !novi
        if EMPTY( _datpl )
            rok_pl := 0
        else
            rok_pl := _datpl - _datdok
        endif
    endif

elseif var == "1"  

    if !_rok_pl_nula
        if rok_pl < 1
            MsgBeep("Obavezno unjeti broj dana !")
            return .f.
        endif
    endif

    if rok_pl < 0  
        // moras unijeti pozitivnu vrijednost ili 0
        MsgBeep("Unijeti broj dana !")
        return .f.
    endif

    if rok_pl = 0 .and. gRokPl < 0
        _datPl := CTOD("")
    else
        _datPl := _datdok + rok_pl
    endif

else  

    if EMPTY( _datpl )
        rok_pl := 0
    else
        rok_pl := _datpl - _datdok
    endif

endif

ShowGets()

return .t.






function ArgToStr(xArg)
if (xArg==NIL)
    return "NIL"
else
    return "'"+xArg+"'"
endif



// --------------------------------------------------
// Prerada cijene
// Ako je u polje SERBR unesen podatak KJ/KG iznos se 
// dobija kao KOLICINA * CIJENA * PrerCij()  
// varijanta R - Rudnik
// --------------------------------------------------
function PrerCij()
local _ser_br := ALLTRIM( _field->serbr )
local _ret := 1

if !EMPTY( _ser_br ) .and. _ser_br != "*" .and. is_fakt_ugalj()
    _ret := VAL(_ret) / 1000
endif

return _ret





// Stampa dokumenta ugovor o rabatu
function StUgRabKup()
lUgRab:=.t.
lSSIP99:=.f.
//StDok2()
lUgRab:=.f.
return



// ----------------------------------
// ----------------------------------
function IspisBankeNar(cBanke)
local aOpc
O_BANKE
aOpc:=TokToNiz(cBanke,",")
cVrati:=""

select banke
set order to tag "ID"
for i:=1 to LEN(aOpc)
    hseek SUBSTR(aOpc[i], 1, 3)
    if Found()
        cVrati += ALLTRIM(banke->naz) + ", " + ALLTRIM(banke->adresa) + ", " + ALLTRIM(banke->mjesto) + ", " + ALLTRIM(aOpc[i]) + "; "
    else
        cVrati += ""
    endif
next
select partn

return cVrati




/*! \fn JeStorno10()
 *  \brief True je distribucija i TipDokumenta=10  i krajnji desni dio broja dokumenta="S"
 */ 
function JeStorno10()
return glDistrib .and. _idtipdok=="10" .and. UPPER(RIGHT(TRIM(_BrDok),1))=="S"



/*! \fn RabPor10()
 *  \brief
 */
 
function RabPor10()
local nArr:=SELECT()
SELECT FAKT
SET ORDER to TAG "1"
SEEK _idfirma+"10"+left(_brdok,gNumDio)

do while !EOF() .and.;
    _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio).and.;
    _idroba<>idroba
    SKIP 1
enddo

if _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio)
    _rabat    := rabat
    _porez    := porez
    // i cijenu, sto da ne?
    _cijena   := cijena
else
    MsgBeep("Izabrana roba ne postoji u fakturi za storniranje!")
endif
SELECT (nArr)
return




// ---------------------------------------------------------------
// ostale opcije u pripremi dokumenta
// ---------------------------------------------------------------
static function popup_fakt_unos_dokumenta()

private opc[8]

opc[1]:="1. generacija faktura na osnovu ugovora            "
opc[2]:="2. sredjivanje rednih br.stavki dokumenta"
opc[3]:="3. ispravka teksta na kraju fakture"
opc[4]:="4. svedi protustavkom vrijednost dokumenta na 0"
opc[5]:="5. priprema => smece"
opc[6]:="6. smece    => priprema"
opc[7]:="7. "
opc[8]:="8. "

lKonsig := .f.

if lKonsig
    AADD(opc,"9. generisi konsignacioni racun")
else
    AADD(opc,"-----------------------------------------------")
endif

AADD(opc,"A. kompletiranje iznosa fakture pomocu usluga")
AADD(opc,"-----------------------------------------------")
AADD(opc, "C. import txt-a")
AADD(opc, "U. stampa ugovora od do ")

h[1] := h[2] := ""

close all
private am_x:=m_x,am_y:=m_y
private Izbor:=1

do while .t.

  Izbor:=menu("prip",opc,Izbor,.f.)

  do case
    case Izbor==0
    exit
    case izbor == 1
    m_gen_ug()
    case izbor == 2
       SrediRbrFakt()
    case izbor == 3
      O_FAKT_S_PRIPR
      O_FTXT
      select fakt_pripr
      go top
      lDoks2 := ( IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D" )
      if val(rbr)<>1
    MsgBeep("U pripremi se ne nalazi dokument")
      else
    IsprUzorTxt()
      endif
      close all
    case izbor == 4
       O_ROBA
       O_TARIFA
       O_FAKT_S_PRIPR
       go top
       nDug:=0
       do while !eof()
          scatter()
          nDug+=round( _Cijena*_kolicina*(1-_Rabat/100) , ZAOKRUZENJE)
          skip
       enddo

       _idroba:=space(10)
       _kolicina:=1
       _rbr := STR(RbrUnum(_Rbr) + 1, 3, 0)
       _rabat := 0

       cDN := "D"
       Box(,4,60)
      @ m_x+1 ,m_y+2 SAY "Artikal koji se stvara:" GET _idroba  pict "@!" valid P_Roba(@_idroba)
      @ m_x+2 ,m_y+2 SAY "Kolicina" GET _kolicina valid {|| _kolicina<>0 } pict pickol
      read
      if lastkey()==K_ESC
        boxc()
        close all
        return DE_CONT
      endif
      _cijena:=nDug/_kolicina
      if _cijena<0
        _Cijena:=-_cijena
      else
        _kolicina:=-_kolicina
      endif
      @ m_x+3 ,m_y+2 SAY "Cijena" GET _cijena  pict piccdem
      cDN:="D"
      @ m_x+4 ,m_y+2 SAY "Staviti cijenu u sifrarnik ?" GET cDN valid cDN $ "DN" pict "@!"
      read
      if cDN=="D"
         select roba; replace vpc with _cijena; select fakt_pripr
      endif
      if lastkey()=K_ESC
        boxc()
        close all
         return DE_CONT
      endif
      append blank
      Gather()
      BoxC()
    case izbor == 5
          
        azuriraj_smece()

    case izbor == 6

        povrat_smece()

    case izbor == 7 .or. izbor == 8
        return DE_CONT

    case izbor == 9 .and. lKonsig
       GKRacun()

    case izbor == 10
       KomIznosFakt()

    case izbor == 12
        ImportTxt()

    case izbor == 13
        ug_za_period()
  endcase

enddo

m_x:=am_x
m_y:=am_y

o_fakt_edit()

select fakt_pripr
go bottom

return



// --------------------------------------------------------------------
// izmjeni sve stavke dokumenta prema tekucoj stavci
// ovo treba da radi samo na stavci broj 1
// --------------------------------------------------------------------
static function izmjeni_sve_stavke_dokumenta( old_dok, new_dok )
local _old_firma := old_dok["idfirma"]
local _old_brdok := old_dok["brdok"]
local _old_tipdok := old_dok["idtipdok"]
local _rec, _tek_dok, _t_rec
local _new_firma := new_dok["idfirma"]
local _new_brdok := new_dok["brdok"]
local _new_tipdok := new_dok["idtipdok"]

// treba da imam podatke koja je stavka bila prije korekcije
// kao i koja je nova 
// misli se na "idfirma + tipdok + brdok"

select fakt_pripr
go top

// uzmi podatke sa izmjenjene stavke
seek _new_firma + _new_tipdok + _new_brdok

if !FOUND()
    return
endif

_tek_dok := dbf_get_rec()

// zatim mi pronadji ostale stavke bivseg dokumenta
go top
seek _old_firma + _old_tipdok + _old_brdok

if !FOUND()
    return
endif

do while !EOF() .and. field->idfirma + field->idtipdok + field->brdok == ;
        _old_firma + _old_tipdok + _old_brdok 

    skip 1
    _t_rec := RECNO()
    skip -1 

    // napravi zamjenu podataka
    _rec := dbf_get_rec()
    _rec["idfirma"] := _tek_dok["idfirma"]
    _rec["idtipdok"] := _tek_dok["idtipdok"]
    _rec["brdok"] := _tek_dok["brdok"]
    _rec["datdok"] := _tek_dok["datdok"]
    _rec["idpartner"] := _tek_dok["idpartner"]
    _rec["dindem"] := _tek_dok["dindem"]

    dbf_update_rec( _rec )

    go ( _t_rec )

enddo

go top

select ( F_FAKT_ATRIB )
if !Used()
    O_FAKT_ATRIB
endif

go top

do while !EOF()

    skip 1
    _t_rec := RECNO()
    skip -1

    _rec := dbf_get_rec()

    _rec["idfirma"] := _tek_dok["idfirma"]
    _rec["idtipdok"] := _tek_dok["idtipdok"]
    _rec["brdok"] := _tek_dok["brdok"]

    dbf_update_rec( _rec )
 
    go ( _t_rec )

enddo

// zatvori atribute
use

select fakt_pripr

return



// -----------------------------------------------
// izvuci mi total dokumenta
// -----------------------------------------------
static function _total_dokumenta()
local _x, _y
local __x := 1
local _left := 20
local _doc_total := hb_hash()
local _doc_total2 := 0
local _t_area := SELECT()
local _din_dem 

if fakt_pripr->( RECCOUNT() ) == 0 .or. ! ( fakt_pripr->idtipdok $ "10#11#12#20" )
	return
endif

_x := MAXROWS() - 20
_y := MAXCOLS() - 50

// valuta ?
_din_dem := fakt_pripr->dindem

// izvuci mi dokument u temp tabele
stdokpdv( nil, nil, nil, .t. )

// sracunaj totale...
_calc_totals( @_doc_total, _din_dem )

// prikazi box
Box(, _x, _y )

	@ m_x + __x, m_y + 2 SAY PADR( "TOTAL DOKUMENTA:", _y - 2 ) COLOR "I"
	
	++ __x
	++ __x
	
	@ m_x + __x, m_y + 2 SAY PADL( "Osnovica: ", _left ) + STR( _doc_total["osn"], 12, 2 )

	++ __x
	
	@ m_x + __x, m_y + 2 SAY PADL( "Popust: ", _left ) + STR( _doc_total["pop"], 12, 2 )
	
	++ __x
	
	@ m_x + __x, m_y + 2 SAY PADL( "Osnovica - popust: ", _left ) + STR( _doc_total["osn_pop"], 12, 2 )
	
	++ __x
	
	@ m_x + __x, m_y + 2 SAY PADL( "PDV: ", _left ) + STR( _doc_total["pdv"], 12, 2 )
	
	++ __x

	@ m_x + __x, m_y + 2 SAY REPLICATE( "=", _left ) 
	
	++ __x
	
	@ m_x + __x, m_y + 2 SAY PADL( "Ukupno sa PDV (" + ALLTRIM( _din_dem ) + "): ", _left ) + STR( _doc_total["total"], 12, 2 )

    if LEFT( _din_dem, 3 ) <> LEFT( ValBazna(), 3 )
        ++ __x
	    @ m_x + __x, m_y + 2 SAY PADL( "Ukupno sa PDV (" + ALLTRIM( ValBazna() ) + "): ", _left ) + STR( _doc_total["total2"], 12, 2 )
    endif

	while Inkey(0.1) != K_ESC
   	end

BoxC()

select ( _t_area )
return


// ------------------------------------------------
// sracunaj total na osnovu stampe dokumenta
// ------------------------------------------------
static function _calc_totals( hash, din_dem )
local _t_area := SELECT()

hash["osn"] := 0
hash["pop"] := 0
hash["osn_pop"] := 0
hash["pdv"] := 0
hash["total"] := 0
hash["total2"] := 0

select drn
go top

if RECCOUNT() <> 0
	
	hash["osn"] := field->ukbezpdv
	hash["pop"] := field->ukpopust
	hash["osn_pop"] := field->ukbpdvpop
	hash["pdv"] := field->ukpdv
	hash["total"] := field->ukupno

    if LEFT( din_dem, 3 ) <> LEFT( ValBazna(), 3 )
        hash["total2"] := field->ukupno * OmjerVal( ValBazna(), din_dem, field->datdok )
    endif

endif

select ( _t_area )

return




// ---------------------------------------------------
// kontrola zbira - fakt dokument
//
// ovdje treba promjeniti logiku i uzeti stampanje
// fakture i onda ocitati podatke...
// todo
// ---------------------------------------------------
static function fakt_kzb( id_firma, tip_dok, br_dok )
local _dug := 0
local _rab := 0
local _por := 0
local _din_dem := field->dindem
local _tmp := 1

Box(, 12, MAXCOLS() - 5 )

    // stampaj dokument u pomocnu tabelu
    // ...
    // ispisi podatke po stavkama
    // ...
    // saberi i prikazi sve...
 
	if _tmp > 9

	    while Inkey(0.1) != K_ESC
    	end

        @ m_x + 1, m_y + 2 CLEAR TO m_x + 12, MAXCOLS() - 5
                
        _tmp := 1
                
        @ m_x, m_y + 2 SAY ""

    endif
            
    @ m_x + _tmp, m_y + 2 SAY REPLICATE( "-", MAXCOLS() - 10 )

    @ m_x + _tmp + 1, m_y + 2 SAY PADR( "Ukupno   ", 30 )

    @ m_x + _tmp + 1, col() + 1 SAY _dug PICT "9999999.99"

    @ m_x + _tmp + 1, col() + 1 SAY _rab PICT "9999999.99"

    @ m_x + _tmp + 1, col() + 1 SAY _dug - _rab PICT "9999999.99"

    @ m_x + _tmp + 1, col() + 1 SAY _por PICT "9999999.99"

    @ m_x + _tmp + 1, col() + 1 SAY ( _dug - _rab ) + _por PICT "9999999.99"

    @ m_x + _tmp + 1, col() + 1 SAY "(" + _din_dem + ")"
		
	while Inkey(0.1) != K_ESC
    end

BoxC()
    
return





