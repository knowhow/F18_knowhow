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


#include "f18.ch"

static picBHD
static picDEM
static R1
static R2
static __ios_clan := ""


// -----------------------------------------------
// izvjestaj otvorenih stavki
// -----------------------------------------------
function ios()
local _izbor := 1
local _opc := {}
local _opcexe := {}

picBHD := "@Z " + ( R1 := FormPicL( "9 " + gPicBHD, 16 ) )
picDEM := "@Z " + ( R2 := FormPicL( "9 " + gPicDEM, 12 ) )
R1 := R1 + " " + ValDomaca()
R2 := R2 + " " + ValPomocna()

AADD( _opc, "1. specifikacija IOS-a (pregled podataka prije stampe) " )
AADD( _opcexe, { || ios_specifikacija() } )
AADD( _opc, "2. stampa IOS-a" )
AADD( _opcexe, { || mnu_ios_print() } )
AADD( _opc, "3. generisanje podataka za stampu IOS-a" )
AADD( _opcexe, { || ios_generacija_podataka() } )
AADD( _opc, "4. podesenje clan-a" )
AADD( _opcexe, { || ios_clan_setup() } )


f18_menu( "ios", .f., _izbor, _opc, _opcexe )

return


// --------------------------------------------------
// podesenje clan-a za stampu IOS-a
// --------------------------------------------------
static function ios_clan_setup( setup_box )
local _txt := ""
local _clan

if setup_box == NIL
    setup_box := .t.
endif

// ovo je tekuci defaultni clan
_txt := "Prema clanu 28. stav 4. Zakona o racunovodstvu i reviziji u FBIH (Sl.novine FBIH, broj 83/09) " 
_txt += "na ovu nasu konfirmaciju ste duzni odgovoriti u roku od osam dana. "
_txt += "Ukoliko u tom roku ne primimo potvrdu ili osporavanje iskazanog stanja, smatracemo da je "
_txt += "usaglasavanje izvrseno i da je stanje isto."

_clan := PADR( fetch_metric( "ios_clan_txt", NIL, _txt ), 500 )

if setup_box
    Box(, 2, 70 )
        @ m_x + 1, m_y + 2 SAY "Definisanje clan-a na IOS-u:"
        @ m_x + 2, m_y + 2 SAY ":" GET _clan PICT "@S65"
        read
    BoxC()

    if LastKey() == K_ESC
        return
    endif
endif

// snimi parametar
set_metric( "ios_clan_txt", NIL, ALLTRIM( _clan ) )
__ios_clan := ALLTRIM( _clan )

return




// ---------------------------------------------------------
// linija za specifikaciju iosa
// ---------------------------------------------------------
static function _ios_spec_get_line()
local _line
local _space := SPACE(1)

_line := "-----"
_line += _space
_line += "------" 
_line += _space 
_line += "------------------------------------"
_line += _space 
_line += "-----"
_line += _space 
_line += "-----------------"
_line += _space 
_line += "---------------"
_line += _space 
_line += "----------------"
_line += _space 
_line += "----------------"
_line += _space 
_line += "----------------"

if gVar1 == "0"
    _line += _space 
    _line += "------------"
    _line += _space 
    _line += "------------"
    _line += _space 
    _line += "------------"
    _line += _space 
    _line += "------------"
endif

return _line




// ----------------------------------------------------------
// uslovi izvjestaja IOS specifikacija
// ----------------------------------------------------------
static function _ios_spec_vars( params )
local _id_firma := gFirma
local _id_konto := fetch_metric( "ios_spec_id_konto", my_user(), SPACE(7) )
local _saldo_nula := "D"
local _datum_do := DATE()

O_KONTO

Box( "", 6, 60 )
    @ m_x + 1, m_y + 6 SAY "SPECIFIKACIJA IOS-a"
    @ m_x + 3, m_y + 2 SAY "Firma "
    ?? gFirma, "-", gNFirma
    @ m_x + 4, m_y + 2 SAY "Konto: " GET _id_konto VALID P_Konto( @_id_konto )
    @ m_x + 5, m_y + 2 SAY "Datum do kojeg se generise  :" GET _datum_do
    @ m_x + 6, m_y + 2 SAY "Prikaz partnera sa saldom 0 :" GET _saldo_nula ;
            VALID _saldo_nula $ "DN" PICT "@!"
    read
BoxC()

select konto
use

if LastKey() == K_ESC
    return .f.
endif

// snimi parametre
set_metric( "ios_spec_id_konto", my_user(), _id_konto )
_id_firma := LEFT( _id_firma, 2 )

// napuni matricu sa parametrima
params["id_konto"] := _id_konto
params["id_firma"] := _id_firma
params["saldo_nula"] := _saldo_nula
params["datum_do"] := _datum_do

return .t.





// -------------------------------------------------------
// specifikacija IOS-a
// -------------------------------------------------------
static function ios_specifikacija( params )
local _datum_do, _id_firma, _id_konto, _saldo_nula
local _line 
local _id_partner, _rbr
local _auto := .f.

if params == NIL
    params := hb_hash()
else
    _auto := .t.
endif

// uslovi izvjestaja
if !_auto .and. !_ios_spec_vars( @params )
    return 
endif

// iz parametara uzmi uslove...
_id_firma := params["id_firma"]
_id_konto := params["id_konto"]
_datum_do := params["datum_do"]
_saldo_nula := params["saldo_nula"]

_line := _ios_spec_get_line()

O_PARTN
O_KONTO
O_SUBAN

select suban
set order to tag "1"

seek _id_firma + _id_konto 
EOF CRET

START PRINT CRET
?

_rbr := 0

nDugBHD := nUkDugBHD := nDugDEM := nUkDugDEM := 0
nPotBHD := nUkPotBHD := nPotDEM := nUkPotDEM := 0
nUkBHDDS := nUkBHDPS := 0
nUkDEMDS := nUkDEMPS := 0

do while !EOF() .and. _id_firma == field->idfirma .and. _id_konto == field->idkonto

    _id_partner := field->idpartner

    do while !EOF() .and. _id_firma == field->idfirma ;
                    .and. _id_konto == field->idkonto ;
                    .and. _id_partner == field->idpartner
      
        // ako je datum veci od datuma do kojeg generisem
        // preskoci
        if field->datdok > _datum_do
            skip
            loop
        endif
      
        if field->otvst == " "
            if field->d_p == "1"
                nDugBHD += field->iznosbhd
                nUkDugBHD += field->Iznosbhd
                nDugDEM += field->Iznosdem
                nUkDugDEM += field->Iznosdem
            else
                nPotBHD += field->IznosBHD
                nUkPotBHD += field->IznosBHD
                nPotDEM += field->IznosDEM
                nUkPotDEM += field->IznosDEM
            endif
        endif
        skip
    enddo 

    nSaldoBHD := nDugBHD - nPotBHD
    nSaldoDEM := nDugDEM - nPotDEM

    if _saldo_nula == "D" .or. ROUND( nSaldoBHD, 2 ) <> 0  
        // ako je iznos <> 0

        // daj mi prvi put zaglavlje
        if _rbr == 0
            _spec_zaglavlje( _id_firma, _id_partner, _line )
        endif

        if prow() > 61 + gPStranica
            FF  
            _spec_zaglavlje( _id_firma, _id_partner, _line )
        endif

        @ prow() + 1, 0 SAY ++ _rbr PICT "9999"
        @ prow(), 5 SAY _id_partner

        SELECT PARTN
        HSEEK _id_partner

        @ prow(), 12 SAY PADR( ALLTRIM( partn->naz ), 20 )
        @ prow(), 37 SAY ALLTRIM( partn->naz2 ) PICT 'XXXXXXXXXXXX'
        @ prow(), 50 SAY partn->PTT
        @ prow(), 56 SAY partn->Mjesto

        // BHD
        @ prow(), 73 SAY nDugBHD PICT picBHD
        @ prow(), pcol() + 1 SAY nPotBHD PICT picBHD

    endif 
   
    select suban

    if nSaldoBHD >= 0
        @ prow(), pcol() + 1 SAY nSaldoBHD PICT picBHD
        @ prow(), pcol() + 1 SAY 0 PICT picBHD
        nUkBHDDS += nSaldoBHD
    else
        @ prow(), pcol() + 1 SAY 0 PICT picBHD
        @ prow(), pcol() + 1 SAY -nSaldoBHD PICT picBHD
        nUkBHDPS += -nSaldoBHD
    endif

    // strana valuta
    if gVar1 == "0"

        @ prow(), pcol() + 1 SAY nDugDEM PICTURE picDEM
        @ prow(), pcol() + 1 SAY nPotDEM PICTURE picDEM

        if nSaldoDEM >= 0
            @ prow(), pcol() + 1 SAY nSaldoDEM PICTURE picDEM
            @ prow(), pcol() + 1 SAY 0 PICTURE picDEM
            nUkDEMDS += nSaldoDEM
        else
            @ prow(), pcol() + 1 SAY 0 PICTURE picDEM
            @ prow(), pcol() + 1 SAY -nSaldoDEM PICTURE picDEM
            nUkDEMPS += -nSaldoDEM
        endif
    endif

   nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
   _id_partner := field->IdPartner

enddo 

if prow() > 61 + gPStranica
    FF
    _spec_zaglavlje( _id_firma, _id_partner, _line )
endif

@ prow() + 1, 0 SAY _line
@ prow() + 1, 0 SAY "UKUPNO ZA KONTO:"
@ prow(), 73 SAY nUkDugBHD PICTURE picBHD
@ prow(), pcol() + 1 SAY nUkPotBHD PICTURE picBHD

nS := nUkBHDDS - nUkBHDPS
@ prow(), pcol() + 1 SAY iif(nS>=0,nS,0) PICTURE picBHD
@ prow(), pcol() + 1 SAY iif(nS<=0,nS,0) PICTURE picBHD

if gVar1 == "0"
    
    @ prow(), pcol() + 1 SAY nUkDugDEM PICTURE picDEM
    @ prow(), pcol() + 1 SAY nUkPotDEM PICTURE picDEM

    nS:=nUkDEMDS-nUkDEMPS

    @ prow(), pcol() + 1 SAY iif(nS>=0,nS,0) PICTURE picDEM
    @ prow(), pcol() + 1 SAY iif(nS<=0,nS,0) PICTURE picDEM

endif

@ prow() + 1, 0 SAY _line

FF
END PRINT

my_close_all_dbf()
return





// -----------------------------------------------------------------
// zaglavlje specifikacije
// -----------------------------------------------------------------
static function _spec_zaglavlje( id_firma, id_partner, line )
P_COND

??  "FIN: SPECIFIKACIJA IOS-a     NA DAN "
?? DATE()
? "FIRMA:"
@ prow(), pcol() + 1 SAY id_firma

select partn
hseek id_partner

@ prow(),pcol()+1 SAY ALLTRIM(naz)
@ prow(),pcol()+1 SAY ALLTRIM(naz2)

? line

? "*RED.* �IFRA*      NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *   KUMULATIVNI PROMET  U  "+ValDomaca()+"  *    S A L D O   U   "+ValDomaca()+"         "+IF(gVar1=="0","*  KUMULAT. PROMET U "+ValPomocna()+" *  S A L D O   U   "+ValPomocna()+"  ","")+"*"
? "                                                                          ________________________________ _________________________________"+IF(gVar1=="0","*_________________________ ________________________","")+"_"
? "*BROJ*      *                                    * BROJ*                 *    DUGUJE     *   POTRAZUJE    *    DUGUJE      *   POTRAZUJE    "+IF(gVar1=="0","*    DUGUJE  * POTRAZUJE  *   DUGUJE   * POTRAZUJE ","")+"*"
? line

select suban
return





// -------------------------------------------------------
// specifikacija IOS-a
// -------------------------------------------------------
static function ios_generacija_podataka( params )
local _datum_do, _id_firma, _id_konto, _saldo_nula
local _id_partner, _rec, _cnt
local _auto := .f.
local _dug_1, _dug_2, _u_dug_1, _u_dug_2
local _pot_1, _pot_2, _u_pot_1, _u_pot_2
local _saldo_1, _saldo_2

if params == NIL
    MsgBeep( "Napomena: ova opcija puni pomocnu tabelu na osnovu koje se#stampaju IOS obrasci" )
    params := hb_hash()
else
    _auto := .t.
endif

// uslovi izvjestaja
if !_auto .and. !_ios_spec_vars( @params )
    return 
endif

// iz parametara uzmi uslove...
_id_firma := params["id_firma"]
_id_konto := params["id_konto"]
_datum_do := params["datum_do"]
_saldo_nula := params["saldo_nula"]

O_PARTN
O_KONTO
O_SUBAN
O_IOS

// reset tabele IOS
select ios
my_dbf_zap()

select suban
set order to tag "1"

seek _id_firma + _id_konto 

EOF CRET

_cnt := 0

Box(, 3, 65 )

@ m_x + 1, m_y + 2 SAY "sacekajte trenutak... generisem podatke u pomocnu tabelu"

do while !EOF() .and. _id_firma == field->idfirma .and. _id_konto == field->idkonto

    _id_partner := field->idpartner

    _dug_1 := 0
    _u_dug_1 := 0
    _dug_2 := 0
    _u_dug_2 := 0
    _pot_1 := 0
    _u_pot_1 := 0
    _pot_2 := 0
    _u_pot_2 := 0
    _saldo_1 := 0
    _saldo_2 := 0

    do while !EOF() .and. _id_firma == field->idfirma ;
                    .and. _id_konto == field->idkonto ;
                    .and. _id_partner == field->idpartner
      
        // ako je datum veci od datuma do kojeg generisem
        if field->datdok > _datum_do
            skip
            loop
        endif
      
        if field->otvst == " "
            if field->d_p == "1"
                _dug_1 += field->iznosbhd
                _u_dug_1 += field->Iznosbhd
                _dug_2 += field->Iznosdem
                _u_dug_2 += field->Iznosdem
            else
                _pot_1 += field->IznosBHD
                _u_pot_1 += field->IznosBHD
                _pot_2 += field->IznosDEM
                _u_pot_2 += field->IznosDEM
            endif
        endif

        skip

    enddo 

    _saldo_1 := _dug_1 - _pot_1
    _saldo_2 := _dug_2 - _pot_2

    if _saldo_nula == "D" .or. ROUND( _saldo_1, 2 ) <> 0  

        select ios
        append blank

        _rec := dbf_get_rec()

        _rec["idfirma"] := _id_firma
        _rec["idkonto"] := _id_konto
        _rec["idpartner"] := _id_partner
        _rec["iznosbhd"] := _saldo_1
        _rec["iznosdem"] := _saldo_2

        dbf_update_rec( _rec )

        @ m_x + 3, m_y + 2 SAY PADR( "Partner: " + _id_partner + ", saldo: " + ALLTRIM(STR( _saldo_1, 12, 2 )), 60 )

        ++ _cnt

    endif 
   
    select suban

enddo 

BoxC()

return _cnt





// ----------------------------------------------------------------
// IOS print menu
// ----------------------------------------------------------------
static function mnu_ios_print()
local _datum_do := DATE()
local _params := hb_hash()
local _gen_par := hb_hash()
local _id_firma := gFirma
local _id_konto := fetch_metric( "ios_print_id_konto", my_user(), SPACE(7) )
local _id_partner := fetch_metric( "ios_print_id_partner", my_user(), SPACE(6) )
local _din_dem := "1"
local _kao_kartica := fetch_metric( "ios_print_kartica", my_user(), "D" )
local _prelomljeno := fetch_metric( "ios_print_prelom", my_user(), "N" )
local _export_dbf := "N"
local _print_tip := fetch_metric( "ios_print_tip", my_user(), "2" )
local _auto_gen := fetch_metric( "ios_auto_gen", my_user(), "D" )
local _ios_date := DATE()
local _x := 1
local _launch, _exp_fields
local _xml_file := my_home() + "data.xml"
local _template := "ios.odt"


O_KONTO
O_PARTN

Box(, 16, 65, .f. )

    @ m_x + _x, m_y + 2 SAY " Stampa IOS-a **** "

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "       Datum IOS-a:" GET _ios_date

    ++ _x

    @ m_x + _x, m_y + 2 SAY " Gledati period do:" GET _datum_do

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Firma "
    ?? gFirma, "-", gNFirma

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Konto       :" GET _id_konto VALID P_Konto( @_id_konto )
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Partner     :" GET _id_partner ;
            VALID EMPTY( _id_partner ) .or.  P_Firma( @_id_partner ) PICT "@!"

    if gVar1 == "0"
        ++ _x
        @ m_x + _x, m_y + 2 SAY "Prikaz " + ;
                ALLTRIM( ValDomaca() ) + "/" + ;
                ALLTRIM( ValPomocna() ) + " (1/2)" ;
                GET _din_dem VALID _din_dem $ "12"
    endif

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Prikaz prebijenog stanja " GET _prelomljeno ;
            VALID _prelomljeno $ "DN" PICT "@!"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Prikaz identicno kartici " GET _kao_kartica ;
            VALID _kao_kartica $ "DN" PICT "@!"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Eksport podataka u dbf (D/N) ?" GET _export_dbf ;
            VALID _export_dbf $ "DN" PICT "@!"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Nacin stampe ODT/TXT (1/2) ?" GET _print_tip ;
            VALID _print_tip $ "12"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Generisi podatke IOS-a automatski kod pokretanja (D/N) ?" GET _auto_gen ;
            VALID _auto_gen $ "DN" PICT "@!"


    read

    ESC_BCR

BoxC()

set_metric( "ios_print_id_konto", my_user(), _id_konto )
set_metric( "ios_print_id_partner", my_user(), _id_partner )
set_metric( "ios_print_kartica", my_user(), _kao_kartica )
set_metric( "ios_print_prelom", my_user(), _prelomljeno )
set_metric( "ios_print_tip", my_user(), _print_tip )

_id_firma := LEFT( _id_firma, 2 )

// definisi clan i setuj staticku varijablu
ios_clan_setup( .f. )

// generisi podatke u tabelu prije same stampe
if _auto_gen == "D"

    _gen_par := hb_hash()
    _gen_par["id_konto"] := _id_konto
    _gen_par["id_firma"] := _id_firma
    _gen_par["saldo_nula"] := "D"
    _gen_par["datum_do"] := _datum_do

    // generisi podatke u IOS tabelu
    ios_generacija_podataka( _gen_par )

endif

// eksport podataka u dbf tabelu
if _export_dbf == "D"
    _exp_fields := g_exp_fields()
    t_exp_create( _exp_fields )
endif

// otvori mi tabele
O_KONTO
O_PARTN
O_SUBAN
O_TNAL
O_SUBAN
O_IOS

select ios
go top

seek _id_firma + _id_konto 

NFOUND CRET

// txt forma
if _print_tip == "2"

    START PRINT CRET

else

    // pripremi mi za xml
    open_xml( _xml_file )
    // standardni header
    xml_head()
    xml_subnode( "ios", .f. )

endif

select ios

do while !EOF() .and. _id_firma == field->idfirma ;
                .and. _id_konto == field->idkonto

    _partn_id := field->idpartner

    // pronadji za partnera...
    if !EMPTY( _id_partner )
        if _partn_id <> _id_partner
            skip
            loop
        endif
    endif

    // spremi mi _params matricu
    _params := hb_hash()
    _params["id_partner"] := _partn_id
    _params["id_konto"] := _id_konto
    _params["id_firma"] := _id_firma
    _params["din_dem"] := _din_dem
    _params["datum_do"] := _datum_do
    _params["ios_datum"] := _ios_date
    _params["export_dbf"] := _export_dbf
    _params["iznos_bhd"] := ios->iznosbhd
    _params["iznos_dem"] := ios->iznosdem
    _params["kartica"] := _kao_kartica
    _params["prelom"] := _prelomljeno

    if _print_tip == "2"
        print_ios_txt( _params )
    else
        print_ios_xml( _params )
    endif

    skip

enddo

if _print_tip == "2"
    END PRINT
else

    xml_subnode( "ios", .t. )
    close_xml()

endif

if _print_tip == "2" .and. _export_dbf == "D"
    f18_open_mime_document( my_home() + "r_export.dbf" )
endif

my_close_all_dbf()

if _print_tip == "1"
    
    if EMPTY( _id_partner )
        _template := "ios_2.odt"
    endif

    if generisi_odt_iz_xml( _template, _xml_file )
        prikazi_odt()
    endif

endif

return


// ------------------------------------------------------
// upisi u xml fajl podatke partnera
// u odredjeni subnode
// ------------------------------------------------------
static function _xml_partner( subnode, id_partner )
local _ret := .t.
local _jib, cPdvBroj, cIdBroj

select partn
go top
seek id_partner

if !FOUND() .and. !EMPTY( id_partner )
    _ret := .f.
    return _ret
endif

// upisi u xml
xml_subnode( subnode, .f. )

    if EMPTY( id_partner )
        // nema partnera...
        xml_node( "id", to_xml_encoding("-") )
        xml_node( "naz", to_xml_encoding( "-" ) )
        xml_node( "naz2", to_xml_encoding( "-" ) )
        xml_node( "mjesto", to_xml_encoding( "-" ) )
        xml_node( "adresa", to_xml_encoding( "-" ) )
        xml_node( "ptt", to_xml_encoding( "-" ) )
        xml_node( "ziror", to_xml_encoding( "-" ) )
        xml_node( "tel", to_xml_encoding( "-" ) )
        xml_node( "jib", "-" )
    else
        // ima partnera
        xml_node( "id", to_xml_encoding( id_partner) )
        xml_node( "naz", to_xml_encoding( partn->naz ) )
        xml_node( "naz2", to_xml_encoding( partn->naz2 ) )
        xml_node( "mjesto", to_xml_encoding( partn->mjesto ) )
        xml_node( "adresa", to_xml_encoding( partn->adresa ) )
        xml_node( "ptt", to_xml_encoding( partn->ptt ) )
        xml_node( "ziror", to_xml_encoding( partn->ziror ) )
        xml_node( "tel", to_xml_encoding( partn->telefon ) )

        _jib := firma_pdv_broj( id_partner )

        cPdvBroj := _jib
        cIdBroj := firma_id_broj( id_partner )

        xml_node( "jib", _jib )
        xml_node( "pdvbr", cPdvBroj )
        xml_node( "idbbr", cIdBroj )
    endif

xml_subnode( subnode, .t. )

return _ret


// -----------------------------------------
// ispivanje stavki IOS-a u XML formatu
// -----------------------------------------
static function print_ios_xml( params )
local _rbr
local _id_firma := params["id_firma"]
local _id_konto := params["id_konto"]
local _id_partner := params["id_partner"]
local _iznos_bhd := params["iznos_bhd"]
local _iznos_dem := params["iznos_dem"]
local _din_dem := params["din_dem"]
local _datum_do := params["datum_do"]
local _ios_date := params["ios_datum"]
local _kao_kartica := params["kartica"]
local _prelomljeno := params["prelom"]
local _saldo_1, _saldo_2, __saldo_1, __saldo_2
local _dug_1, _dug_2, _u_dug_1, _u_dug_2, _u_dug_1z, _u_dug_2z
local _pot_1, _pot_2, _u_pot_1, _u_pot_2, _u_pot_1z, _u_pot_2z

// <ios_item>
//
//    <firma>
//      <id>10</id>
//      <naz>...</naz>
//      .....
//    </firma>
//
//    <partner>
//       <id>1231</id>
//       <naz>PARTNER XZX</naz>
//       .....   
//    </partner>
//   
//    <ios_datum></ios_datum>
// 
//
//
// </ios_item>

xml_subnode( "ios_item", .f. )

// maticna firma
if !_xml_partner( "firma", _id_firma )
endif

// partner
if !_xml_partner( "partner", _id_partner )
endif

xml_node( "ios_datum", DTOC( _ios_date ) )
xml_node( "id_konto", to_xml_encoding( _id_konto ) )
xml_node( "id_partner", to_xml_encoding( _id_partner ) )

_total_bhd := _iznos_bhd
_total_dem := _iznos_dem

if _iznos_bhd < 0
    _total_bhd := -_iznos_bhd
endif
if _iznos_dem < 0
   _total_dem := -_iznos_dem
endif

if _din_dem == "1"
    xml_node( "total", ALLTRIM( STR( _total_bhd, 12, 2 ) ) )
    xml_node( "valuta", to_xml_encoding ( ValDomaca() ) )
else
    xml_node( "total", ALLTRIM( STR( _total_dem, 12, 2 ) ) )
    xml_node( "valuta", to_xml_encoding ( ValPomocna() ) )
endif

if _iznos_bhd > 0
    xml_node( "dp", "1" )
else
    xml_node( "dp", "2" )
endif

select suban

if _kao_kartica == "D"
    set order to tag "1"
else
    set order to tag "3"
endif

seek _id_firma + _id_konto + _id_partner

_u_dug_1 := 0
_u_dug_2 := 0
_u_pot_1 := 0
_u_pot_2 := 0
_u_dug_1z := 0
_u_dug_2z := 0
_u_pot_1z := 0
_u_pot_2z := 0

// ako je kartica, onda nikad ne prelamaj
if _kao_kartica == "D"
    _prelomljeno := "N"
endif

_rbr := 0

do while !EOF() .and. _id_firma == field->IdFirma ;
                .and. _id_konto == field->IdKonto ;
                .and. _id_partner == field->IdPartner
     
    __br_dok := field->brdok
    __dat_dok := field->datdok
    __opis := ALLTRIM( field->opis )
    __dat_val := field->datval
    _dug_1 := 0
    _pot_1 := 0
    _dug_2 := 0
    _pot_2 := 0
    __otv_st := field->otvst
 
    do while !EOF() .and. _id_firma == field->IdFirma ;
                    .and. _id_konto == field->IdKonto ;
                    .and. _id_partner == field->IdPartner ;
                    .and. ( _kao_kartica == "D" .or. field->brdok == __br_dok )
         
        if field->datdok > _datum_do
            skip
            loop
        endif
        
        if field->otvst = " "
            
            if _kao_kartica == "D"
               
                // krece subnode...
                xml_subnode( "data_kartica", .f. )

                xml_node( "rbr", ALLTRIM( STR( ++ _rbr ) ) )
                xml_node( "brdok", to_xml_encoding( field->brdok ) )
                xml_node( "opis", to_xml_encoding( field->opis ) )
                xml_node( "datdok", DTOC( field->datdok ) )
                xml_node( "datval", DTOC( field->datval) )

                if _din_dem == "1"
                    xml_node( "dug", ALLTRIM( STR( IIF( field->d_p == "1", field->iznosbhd, 0 ) , 12, 2 ) ) )
                    xml_node( "pot", ALLTRIM( STR( IIF( field->d_p == "2", field->iznosbhd, 0 ) , 12, 2 ) ) )
                else
                    xml_node( "dug", ALLTRIM( STR( IIF( field->d_p == "1", field->iznosdem, 0 ) , 12, 2 ) ) )
                    xml_node( "pot", ALLTRIM( STR( IIF( field->d_p == "2", field->iznosdem, 0 ) , 12, 2 ) ) )
                endif

                // zatvori subnode....
                xml_subnode( "data_kartica", .t. )
          
            endif
            
            if field->d_p = "1"
                _dug_1 += field->IznosBHD
                _dug_2 += field->IznosDEM
            else
                _pot_1 += field->IznosBHD
                _pot_2 += field->IznosDEM
            endif
            
            __otv_st := " "
        
        else
  
            // zatvorene stavke
            if field->d_p == "1"
                _u_dug_1z += field->IznosBHD
                _u_dug_2z += field->IznosDEM
            else
                _u_pot_1z += field->IznosBHD
                _u_pot_2z += field->IznosDEM
            endif
        
        endif

        skip
     
    enddo
 
    if __otv_st == " "
      
        if _prelomljeno == "D"
                
            if _din_dem == "1"                 
                // domaca valuta
                if ( _dug_1 - _pot_1 ) > 0
                    _dug_1 := ( _dug_1 - _pot_1 )
                    _pot_1 := 0
                else
                    _pot_1 := ( _pot_1 - _dug_1 )
                    _dug_1 := 0
                endif
            else
                // strana valuta
                if ( _dug_2 - _pot_2 ) > 0
                    _dug_2 := ( _dug_2 - _pot_2 )
                    _pot_2 := 0
                else
                    _pot_2 := ( _pot_2 - _dug_2 )
                    _dug_2 := 0
                endif
 
            endif
                
        endif
          
        if _kao_kartica == "N"

            // ispisi mi ove stavke ako dug i pot <> 0
            if !( ROUND( _dug_1, 2 ) == 0 .and. ROUND( _pot_1, 2 ) == 0 )

                xml_subnode( "data_kartica", .f. )

                xml_node( "rbr", ALLTRIM( STR( ++_rbr ) ) )
                xml_node( "brdok", to_xml_encoding( __br_dok ) )
                xml_node( "opis", to_xml_encoding( __opis ) )
                xml_node( "datdok", DTOC( __dat_dok ) )
                xml_node( "datval", DTOC( __dat_val ) )
                xml_node( "dug", ALLTRIM( STR( _dug_1 , 12, 2 ) ) )
                xml_node( "pot", ALLTRIM( STR( _pot_1 , 12, 2 ) ) )

                // zatvori mi subnode
                xml_subnode( "data_kartica", .t. )

            endif

        endif

        _u_dug_1 += _dug_1
        _u_pot_1 += _pot_1
        _u_dug_2 += _dug_2
        _u_pot_2 += _pot_2
     
    endif
     
enddo

// saldo
_saldo_1 := ( _u_dug_1 - _u_pot_1 )
_saldo_2 := ( _u_dug_2 - _u_pot_2 )
 
if _din_dem == "1"

    xml_node( "u_dug", ALLTRIM(STR( _u_dug_1, 12, 2 )) )
    xml_node( "u_pot", ALLTRIM(STR( _u_pot_1, 12, 2 )) )

    if ROUND( _u_dug_1z - _u_pot_1z, 4 ) <> 0
        xml_node( "greska", ALLTRIM( STR( _u_dug_1z - _u_pot_1z, 12, 2  ) )  )
    else
        xml_node( "greska", ""  )
    endif

    if _saldo_1 >= 0
        xml_node( "saldo", ALLTRIM( STR( _saldo_1, 12, 2 ) ) )
    else
        _saldo_1 := -_saldo_1
        xml_node( "saldo", ALLTRIM( STR( _saldo_1, 12, 2 ) ) )
    endif

else

    xml_node( "u_dug", ALLTRIM(STR( _u_dug_2, 12, 2 )) )
    xml_node( "u_pot", ALLTRIM(STR( _u_pot_2, 12, 2 )) )

    if ROUND( _u_dug_2z - _u_pot_2z, 4 ) <> 0
        xml_node( "greska", ALLTRIM( STR( _u_dug_2z - _u_pot_2z, 12, 2  ) )  )
    else
        xml_node( "greska", ""  )
    endif

    if _saldo_2 >= 0
        xml_node( "saldo", ALLTRIM( STR( _saldo_2, 12, 2 ) ) )
    else
        _saldo_2 := -_saldo_2
        xml_node( "saldo", ALLTRIM( STR( _saldo_2, 12, 2 ) ) )
    endif

endif

xml_node( "mjesto", to_xml_encoding( ALLTRIM( gMjStr ) ) )
xml_node( "datum", DTOC( DATE() ) )

// izvuci mi clan
_clan_txt := __ios_clan 
  
xml_node( "clan", to_xml_encoding( _clan_txt ) )

// zatvori mi subnode
xml_subnode( "ios_item", .t. ) 

select ios

return






// -----------------------------------------
// ispivanje stavki IOS-a u TXT formatu
// -----------------------------------------
static function print_ios_txt( params )
local _rbr
local _n_opis := 0
local _id_firma := params["id_firma"]
local _id_konto := params["id_konto"]
local _id_partner := params["id_partner"]
local _iznos_bhd := params["iznos_bhd"]
local _iznos_dem := params["iznos_dem"]
local _din_dem := params["din_dem"]
local _datum_do := params["datum_do"]
local _ios_date := params["ios_datum"]
local _export_dbf := params["export_dbf"]
local _kao_kartica := params["kartica"]
local _prelomljeno := params["prelom"]
local _naz_partner

?

@ prow(), 58 SAY "OBRAZAC: I O S"
@ prow() + 1, 1 SAY _id_firma

select partn
hseek _id_firma

@ prow(), 5 SAY ALLTRIM( partn->naz )
@ prow(), pcol() + 1 SAY ALLTRIM( partn->naz2 )
@ prow()+1,5 SAY partn->Mjesto
@ prow()+1,5 SAY partn->Adresa
@ prow()+1,5 SAY partn->ptt
@ prow()+1,5 SAY partn->ZiroR
@ prow()+1,5 SAY firma_pdv_broj( _id_firma )

?

SELECT PARTN
HSEEK _id_partner

@ prow(),45 SAY _id_partner
?? " -", ALLTRIM( partn->naz )
@ prow()+1,45 SAY partn->mjesto
@ prow()+1,45 SAY partn->adresa
@ prow()+1,45 SAY partn->ptt
@ prow()+1,45 SAY partn->ziror

if !empty( partn->telefon)
  @ prow()+1,45 SAY "Telefon: " + partn->telefon
endif

@ prow()+1,45 SAY firma_pdv_broj( _id_partner )

_naz_partner := naz

?
?
@ prow(), 6 SAY "IZVOD OTVORENIH STAVKI NA DAN :"
@ prow(), pcol() + 2 SAY _ios_date
@ prow(),pcol()+1 SAY "GODINE"
?
?
@ prow(),0 SAY "VA�E STANJE NA KONTU" ; @ prow(),pcol()+1 SAY _id_konto
@ prow(),pcol()+1 SAY " - "+ _id_partner
@ prow()+1,0 SAY "PREMA NA�IM POSLOVNIM KNJIGAMA NA DAN:"
@ prow(),39 SAY _ios_date
@ prow(),48 SAY "GODINE"
?
?
@ prow(),0 SAY "POKAZUJE SALDO:"

qqIznosBHD := _iznos_bhd
qqIznosDEM := _iznos_dem

if _iznos_bhd < 0
    qqIznosBHD := -_iznos_bhd
endif

IF _iznos_dem < 0
   qqIznosDEM := -_iznos_dem
ENDIF

if _din_dem == "1"
    @ prow(), 16 SAY qqIznosBHD PICT R1
else
    @ prow(), 16 SAY qqIznosDEM PICT R2
endif

?
?

@ prow(), 0 SAY "U"

IF _iznos_bhd > 0
    @ prow(), pcol() + 1 SAY "NA�U"
ELSE
    @ prow(), pcol() + 1 SAY "VA�U"
ENDIF

@ prow(), pcol() + 1 SAY "KORIST I SASTOJI SE IZ SLIJEDE�IH OTVORENIH STAVKI:"

P_COND

m := "       ---- ---------- -------------------- -------- -------- ---------------- ----------------"

? m
? "       *R. *   BROJ   *    OPIS            * DATUM  * VALUTA *       IZNOS  U  "+iif( _din_dem =="1", ValDomaca(), ValPomocna() ) + "            *"
? "       *Br.*          *                    *                 * --------------------------------"
? "       *   *  RA�UNA  *                    * RA�UNA * RA�UNA *     DUGUJE     *   POTRA�UJE   *"
? m

nCol1 := 62

select suban

if _kao_kartica == "D"
    set order to tag "1"
else
    set order to tag "3"
endif

SEEK _id_firma + _id_konto + _id_partner

nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
nDugBHDZ:=nPotBHDZ:=nDugDEMZ:=nPotDEMZ:=0
_rbr := 0

// ako je kartica, onda nikad ne prelamaj
if _kao_kartica == "D"
    _prelomljeno := "N"
endif

do while !EOF() .and. _id_firma == field->IdFirma ;
                .and. _id_konto == field->IdKonto ;
                .and. _id_partner == field->IdPartner
     
    cBrDok := field->brdok
    dDatdok := field->datdok
    cOpis := ALLTRIM( field->opis )
    dDatVal := field->datval
    nDBHD:=0
    nPBHD:=0
    nDDEM:=0
    nPDEM:=0
    cOtvSt := field->otvst
     
    do while !EOF() .and. _id_firma == field->IdFirma ;
                    .and. _id_konto == field->IdKonto ;
                    .and. _id_partner == field->IdPartner ;
                    .and. ( _kao_kartica == "D" .or. field->brdok == cBrdok )
         
        if field->datdok > _datum_do
            skip
            loop
        endif
        
        if field->otvst = " "
            
            if _kao_kartica == "D"
               
                if prow() > 61 + gPStranica
                    FF
                endif      
               
                @ prow() + 1, 8 SAY ++ _rbr PICT '999'
                @ prow(), pcol() + 1 SAY field->BrDok
                _n_opis := pcol() + 1
                @ prow(), _n_opis SAY PADR( field->Opis, 20 )
                @ prow(), pcol() + 1 SAY field->DatDok
                @ prow(), pcol() + 1 SAY field->DatVal
               
                if _din_dem == "1"
                    @ prow(), nCol1 SAY IIF( field->D_P == "1", field->iznosbhd, 0 ) PICT picBHD
                    @ prow(), pcol() + 1 SAY IIF( field->D_P == "2", field->iznosbhd, 0 ) PICT picBHD
                else
                    @ prow(), nCol1 SAY IIF( field->D_P == "1", field->iznosdem, 0 ) PICT picBHD
                    @ prow(), pcol() + 1 SAY IIF( field->D_P == "2", field->iznosdem, 0 ) PICT picBHD
                endif

                if _export_dbf == "D"
                    fill_exp_tbl( _id_partner, ;
                                    _naz_partner, ;
                                    field->brdok, ;
                                    field->opis, ;
                                    field->datdok, ;
                                    field->datval, ;
                                    IIF( field->d_p == "1", field->iznosbhd, 0), ;
                                    IIF( field->d_p == "2", field->iznosbhd, 0) )
                endif
           
            endif
            
            if field->d_p = "1"
                nDBHD += field->IznosBHD
                nDDEM += field->IznosDEM
            ELSE
                nPBHD += field->IznosBHD
                nPDEM += field->IznosDEM
            ENDIF
            
            cOtvSt := " "
        
        else  
            // zatvorene stavke
            
            IF field->D_P == "1"
                nDugBHDZ += field->IznosBHD
                nDugDEMZ += field->IznosDEM
            ELSE
                nPotBHDZ += field->IznosBHD
                nPotDEMZ += field->IznosDEM
            ENDIF
        
        endif
    
        skip
     
    enddo
     
    if cOtvSt == " "
      
        if _kao_kartica == "N"
       
            if prow() > 61 + gPStranica
                FF
            endif
            
            @ prow() + 1, 8 SAY ++ _rbr PICT "999"
            @ prow(), pcol() + 1  SAY cBrDok
            _n_opis := pcol() + 1
            @ prow(), _n_opis SAY PADR( cOpis, 20 )
            @ prow(),pcol()+1 SAY dDatDok
            @ prow(),pcol()+1 SAY dDatVal
      
        endif
      
        if _din_dem == "1"
        
            if _prelomljeno == "D"
                        
                if ( nDBHD - nPBHD ) > 0
                    nDBHD := ( nDBHD - nPBHD )
                    nPBHD := 0
                else
                    nPBHD := ( nPBHD - nDBHD )
                    nDBHD := 0
                endif
                
            endif
          
            if _kao_kartica == "N"
           
                @ prow(), nCol1 SAY nDBHD PICT picBHD
                @ prow(), pcol() + 1 SAY nPBhD PICT picBHD
            
                if _export_dbf == "D"
                    fill_exp_tbl( _id_partner, ;
                            _naz_partner, ;
                            cBrDok, ;
                            cOpis, ;
                            dDatdok, ;
                            dDatval, ;
                            nDBHD, ;
                            nPBHD )
                endif
                
            endif

        else
            if _prelomljeno == "D"
                if ( nDDEM - nPDEM ) > 0
                    nDDEM := ( nDDEM - nPDEM )
                    nPBHD := 0
                else
                    nPDEM := ( nPDEM - nDDEM )
                    nDDEM := 0
                endif
            endif
                
            if _kao_kartica == "N"
                    
                @ prow(), nCol1 SAY nDDEM PICT picBHD
                @ prow(), pcol() + 1 SAY nPDEM PICT picBHD
               
                if _export_dbf == "D"
                    fill_exp_tbl( _id_partner, ;
                        _naz_partner, ;
                        cBrdok, ;
                        cOpis, ;
                        dDatdok, ;
                        dDatval, ;
                        nDDEM, ;
                        nPDEM )
                endif
      
            endif
        endif
     
        nDugBHD += nDBHD
        nPotBHD += nPBHD
        nDugDem += nDDem
        nPotDem += nPDem
     
    endif
     
    OstatakOpisa( cOpis, _n_opis )
   
enddo

if prow() > 61 + gPStranica
    FF
endif
   
@ prow()+1,0 SAY m
@ prow()+1,8 SAY "UKUPNO:"
   
if _din_dem == "1"
    @ prow(), nCol1 SAY nDugBHD PICTURE picBHD
    @ prow(), pcol() + 1 SAY nPotBHD PICTURE picBHD
else
    @ prow(), nCol1 SAY nDugBHD PICTURE picBHD
    @ prow(), pcol() + 1 SAY nPotBHD PICTURE picBHD
endif

// ako je promet zatvorenih stavki <> 0  prikazi ga ????
if _din_dem == "1"
    if ROUND( nDugBHDZ - nPOTBHDZ, 4 ) <> 0
        @ prow() + 1, 0 SAY m
        @ prow() + 1, 8 SAY "ZATVORENE STAVKE"
        @ prow(), nCol1 SAY ( nDugBHDZ - nPOTBHDZ ) PICT picBHD
        @ prow(), pcol() + 1 SAY  " GRE�KA !!"
    endif
else
    if ROUND( nDugDEMZ - nPOTDEMZ, 4 ) <> 0
        @ prow() + 1, 0 SAY m
        @ prow() + 1, 8 SAY "ZATVORENE STAVKE"
        @ prow(), nCol1 SAY ( nDugDEMZ - nPOTDEMZ ) PICT picBHD
        @ prow(), pcol() + 1 SAY " GRE�KA !!"
    endif
endif

@ prow() + 1, 0 SAY m
@ prow() + 1, 8 SAY "SALDO:"
   
nSaldoBHD := ( nDugBHD - nPotBHD )
nSaldoDEM := ( nDugDEM - nPotDEM )
   
if _din_dem == "1"
    if nSaldoBHD >= 0
        @ prow(), nCol1 SAY nSaldoBHD PICT picBHD
        @ prow(), pcol() + 1 SAY 0 PICT picBHD
    else
        nSaldoBHD := -nSaldoBHD
        nSaldoDEM := -nSaldoDEM
        @ prow(), nCol1 SAY 0 PICT picBHD
        @ prow(), pcol() + 1 SAY nSaldoBHD PICT picBHD
    endif
else
    if nSaldoDEM >= 0
        @ prow(), nCol1 SAY nSaldoDEM PICT picBHD
        @ prow(), pcol() + 1 SAY 0 PICT picBHD
    else
        nSaldoDEM := -nSaldoDEM
        @ prow(), nCol1 SAY 0 PICT picBHD
        @ prow(), pcol() + 1 SAY nSaldoDEM PICT picBHD
    endif
endif
   
? m
   
F10CPI

?

if prow() > 61 + gPStranica
    FF
endif

?
?

F12CPI

@ prow(), 13 SAY "PO�ILJALAC IZVODA:"
@ prow(), 53 SAY "POTVR�UJEMO SAGLASNOST"
@ prow() + 1, 50 SAY "OTVORENIH STAVKI:"

?
?

@ prow(), 10 SAY "__________________"
@ prow(), 50 SAY "______________________"

if prow() > 58 + gPStranica
    FF
endif

?
?

@ prow(), 10 SAY "__________________ M.P."
@ prow(), 50 SAY "______________________ M.P."

?
?

@ prow(), 10 SAY TRIM( gMjStr )+", " + DTOC( DATE() )
@ prow(), 52 SAY "( MJESTO I DATUM )"

if prow() > 52 + gPStranica
    FF
endif

?
?

@ prow(), 0 SAY "Prema clanu 28. stav 4. Zakona o racunovodstvu i reviziji u FBIH (Sl.novine FBIH, broj 83/09)" 
@ prow() + 1, 0 SAY "na ovu nasu konfirmaciju ste duzni odgovoriti u roku od osam dana."
@ prow() + 1, 0 SAY "Ukoliko u tom roku ne primimo potvrdu ili osporavanje iskazanog stanja, smatracemo da je"
@ prow() + 1, 0 SAY "usaglasavanje izvrseno i da je stanje isto."

?
?

@ prow(), 0 SAY "NAPOMENA: OSPORAVAMO ISKAZANO STANJE U CJELINI _______________ DJELIMI�NO"
@ prow() + 1, 0 SAY "ZA IZNOS OD  "+ValDomaca()+"= _______________ IZ SLIJEDE�IH RAZLOGA:"
@ prow() + 1, 0 SAY "_________________________________________________________________________"

?
?

@ prow(), 0 SAY "_________________________________________________________________________"
?
?
@ prow(), 48 SAY "DU�NIK:"
@ prow() + 1, 40 SAY "_______________________ M.P."
@ prow() + 1, 44 SAY "( MJESTO I DATUM )"

select ios

return




// ------------------------------------------
// vraca strukturu tabele za export
// ------------------------------------------
static function g_exp_fields()
local _dbf := {}
AADD( _dbf, {"idpartner", "C", 10, 0 } )
AADD( _dbf, {"partner", "C", 40, 0 } )
AADD( _dbf, {"brrn", "C", 10, 0 } )
AADD( _dbf, {"opis", "C", 40, 0 } )
AADD( _dbf, {"datum", "D", 8, 0 } )
AADD( _dbf, {"valuta", "D", 8, 0 } )
AADD( _dbf, {"duguje", "N", 15, 5 } )
AADD( _dbf, {"potrazuje", "N", 15, 5 } )
return _dbf





// ---------------------------------------------------------
// filovanje tabele sa podacima
// ---------------------------------------------------------
static function fill_exp_tbl( cIdPart, cNazPart, ;
            cBrRn, cOpis, dDatum, dValuta, ;
            nDug, nPot )
local _t_area := SELECT()

O_R_EXP
append blank

replace field->idpartner with cIdPart
replace field->partner with cNazPart
replace field->brrn with cBrRn
replace field->opis with cOpis
replace field->datum with dDatum
replace field->valuta with dValuta
replace field->duguje with nDug
replace field->potrazuje with nPot

select ( _t_area )

return



