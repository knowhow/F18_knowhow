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


#include "rnal.ch"


// ------------------------------------------
// sta generisati, uslovi generacije
// ------------------------------------------
static function _export_cond( params )
local _x := 1
local _ok := .t.
local _tip := "V"
local _suma := "N"
local _valuta := PADR( ALLTRIM( ValDomaca() ), 3 )
local _pr_isp := "N"
private GetList := {}


Box(, 8, 65 )

    @ m_x + _x, m_y + 2 SAY "Uslovi prenosa naloga u otpremnicu:"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY " Tip otpremnice: [V] vp (dok 12)"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "                 [M] mp (dok 13)" GET _tip VALID _tip $ "VM" PICT "@!" 

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Sumirati stavke naloga (D/N)" GET _suma VALID _suma $ "DN" PICT "@!"

    ++ _x    

    @ m_x + _x, m_y + 2 SAY "Valuta u koju mjenjamo otpremnicu (KM/EUR)" GET _valuta PICT "@!"
 
    ++ _x    

    @ m_x + _x, m_y + 2 SAY "Promjeniti podatke isporuke naloga (D/N)" GET _pr_isp VALID _pr_isp $ "DN" PICT "@!" 
       
    read

BoxC()

if LastKey() == K_ESC
    _ok := .f.
    return _ok
endif

params := hb_hash()
params["exp_tip"] := _tip
params["exp_suma"] := _suma
params["exp_valuta"] := UPPER( _valuta )
params["exp_isporuka"] := _pr_isp

return _ok



// --------------------------------------------------------
// export u FMK v.2
//
// lTemp - .t. - stampa iz pripreme, .f. - kumulativ
// nDoc_no - broj dokumenta
// aDocList - matrica sa listom naloga za obradu
//            ako je zadata, radit ce na osnovu
//            vise naloga
// lNoGen - nemoj generisati ponovo stavke, vec postoje
// --------------------------------------------------------
function exp_2_fmk( lTemp, nDoc_no, aDocList, lNoGen )
local nTArea := SELECT()
local nADocs := F_DOCS
local nADOC_IT := F_T_DOCIT
local nADOC_IT2 := F_T_DOCIT2
local nADOC_OP := F_T_DOCOP
local cFmkDoc
local nCust_id
local i
local lSumirati
local cVpMp := "V"
local _rec
local _redni_broj
local _exp_params, _isporuka, _valuta

if lNoGen == nil
    lNoGen := .f.
endif

if lNoGen == .f.
    // napuni podatke za prenos
    st_pripr( lTemp, nDoc_no, aDocList )
endif

// uslovi ekporta - raznorazni...
if !_export_cond( @_exp_params )
    select ( nTArea )
    return
endif

// parametri...
lSumirati := _exp_params["exp_suma"] == "D"
cVpMp := _exp_params["exp_tip"]
_isporuka := _exp_params["exp_isporuka"] == "D"
_valuta := _exp_params["exp_valuta"]

if EMPTY( _valuta )
    _valuta := PADR( ValDomaca(), 3 )
endif

if _isporuka
    // selektuj stavke
    sel_items()
endif

// provjeri da li je priprema faktura prazna
if !fakt_priprema_prazna()
    select (nTArea)
    return
endif

select ( F_FAKT_PRIPR )
if !Used()
    O_FAKT_PRIPR
endif

if lTemp == .t.
    nADocs := F__DOCS
endif

t_rpt_open()

// --------------------------------------------
// 1 korak :
// uzmi podatke partnera, dokumenta iz T_PARS
// --------------------------------------------

nCust_id := VAL( g_t_pars_opis( "P01" ) )
nCont_id := VAL( g_t_pars_opis( "P10" ) )

cCust_desc := g_cust_desc( nCust_id )
cCont_desc := g_cont_desc( nCont_id )

dDatDok := CTOD( g_t_pars_opis( "N02" ) )

if ALLTRIM( cCust_desc ) == "NN"
    // ako je NN kupac u RNAL, dodaj ovo kao contacts....
    cPartn := PADR( g_rel_val("1", "CONTACTS", "PARTN", ALLTRIM(STR(nCont_id)) ), 6 )

else
    // dodaj kao customs
    cPartn := PADR( g_rel_val("1", "CUSTOMS", "PARTN", ALLTRIM(STR(nCust_id)) ), 6 )
endif

// ako je partner prazno
if EMPTY( cPartn )

    if ALLTRIM( cCust_desc ) == "NN"
        
        // ako je NN kupac, presvicaj se na CONTACTS
        
        // probaj naci partnera iz PARTN
        if fnd_partn( @cPartn, nCont_id, cCont_desc ) == 1 
        
            add_to_relation( "CONTACTS", "PARTN", ;
                ALLTRIM(STR(nCont_id)) , cPartn )
            
        else
        
            select (F_FAKT_PRIPR)
            use
            
            select (nTArea)
            msgbeep("Operacija prekinuta !!!")
            return
        
        endif

    else
        // probaj naci partnera iz PARTN
        if fnd_partn( @cPartn, nCust_id, cCust_desc ) == 1 
        
            add_to_relation( "CUSTOMS", "PARTN", ;
                ALLTRIM(STR(nCust_id)) , cPartn )
            
        else
        
            select (F_FAKT_PRIPR)
            use
            
            select (nTArea)
            msgbeep("Operacija prekinuta !!!")
            return
        
        endif
    endif
endif


// ----------------------------------------------
// 2. korak 
// prebaci robu iz doc_it2
// ----------------------------------------------

cFirma := "10"

cIdVd := "12"
cCtrlNo := "22"

// ako je MP onda je drugi set
if cVpMp == "M"
    cIdVd := "13"
    cCtrlNo := "23"
endif

// ova funkcija ce vratiti novi broj dokumenta "22"
cBrDok := fakt_novi_broj_dokumenta( cFirma, cCtrlNo )

cFmkDoc := cIdVd + "-" + ALLTRIM(cBrdok)
_redni_broj := 0

select (nADOC_IT2)
set order to tag "2"
go top

do while !EOF()
        
    nDoc_no := field->doc_no
    cArt_id := field->art_id
    nQtty := field->doc_it_qtt
    cDesc := field->descr

    if lSumirati == .t.
        
        nQtty := 0

        do while !EOF() .and. field->art_id == cArt_id
            
            nQtty += field->doc_it_qtt

            skip
        enddo
    endif

    nPrice := field->doc_it_pri

    if EMPTY( cArt_id )
        skip
        loop
    endif

    if nQtty = 0
        skip
        loop
    endif

    select fakt_pripr    
    append blank
    
    scatter()

    _txt := ""
    _rbr := STR( ++_redni_broj, 3 )
    _idpartner := cPartn
    _idfirma := "10"
    _brdok := cBrDok
    _idtipdok := cIdVd
    _datdok := dDatDok
    _idroba := cArt_id
    _cijena := nPrice
    _kolicina := nQtty
    _dindem := _valuta
    _zaokr := 2

    _txt := ""

    // roba tip U - nista
    a_to_txt( "", .t. )
    // dodatni tekst otpremnice - nista
    a_to_txt( "", .t. )
    // naziv partnera
    a_to_txt( _g_pfmk_desc( cPartn ) , .t. )
    // adresa
    a_to_txt( _g_pfmk_addr( cPartn ) , .t. )
    // ptt i mjesto
    a_to_txt( _g_pfmk_place( cPartn ) , .t. )
    // broj otpremnice
    a_to_txt( "" , .t. )
    // datum  otpremnice
    a_to_txt( DTOC( dDatDok ) , .t. )
    
    // broj ugovora - nista
    a_to_txt( "", .t. )
    
    // datum isporuke - nista
    a_to_txt( "", .t. )
    
    // 10. datum valute - nista
    a_to_txt( "", .t. )
    
    // 11. 
    a_to_txt( "", .t. )
    // 12. 
    a_to_txt( "", .t. )
    // 13. 
    a_to_txt( "", .t. )
    // 14. 
    a_to_txt( "", .t. )
    // 15. 
    a_to_txt( "", .t. )
    // 16. 
    a_to_txt( "", .t. )
    // 17. 
    a_to_txt( "", .t. )
    // 18. 
    a_to_txt( "", .t. )
    // 19. 
    a_to_txt( "", .t. )
    // 20.
    a_to_txt( "", .t. )

    gather()

    // ubaci mi atribute u fakt_atribute
    if !EMPTY( cDesc ) 

        _t_area := SELECT()

        _items_atrib := hb_hash()
        _items_atrib["opis"] := cDesc

        fakt_atrib_hash_to_dbf( field->idfirma, field->idtipdok, field->brdok, field->rbr, _items_atrib )

        select ( _t_area )

    endif
 
    select (nADOC_IT2)

    if lSumirati == .f.
        skip
    endif

enddo

// -----------------------------------------------
// 3. korak :
// prebaci sve iz T_DOCIT
// -----------------------------------------------

select (nADOC_IT)
set order to tag "5"
// index: art_sh_desc
go top

do while !EOF() 

    // da li je markirano za prenos
    if field->print == "N"
        skip
        loop
    endif

    nDoc_no := field->doc_no

    nArt_id := field->art_id
    
    // ukupna kvadratura
    nM2 := field->doc_it_tot

    // opis artikla (kratki)
    cArt_sh := field->art_sh_des
    
    cIdRoba := g_rel_val("1", "ARTICLES", "ROBA", ALLTRIM(STR(nArt_id)) )
    
    // uzmi cijenu robe iz sifrarnika robe
    nPrice := g_art_price( cIdRoba )

    // uzmi opis artikla
    cArt_desc := g_art_desc( nArt_id )

    if EMPTY(cIdRoba)
        
        if fnd_roba( @cIdRoba, nArt_id, cArt_desc ) == 1
        
            add_to_relation( "ARTICLES", "ROBA", ;
                ALLTRIM(STR(nArt_id)), cIdRoba )
        
        else
            msgbeep("Neki artikli nemaju definisani u tabeli relacija#Prekidam operaciju !")    
            select (F_FAKT_PRIPR)
            use
            
            select (nTArea)
            return
        endif
    endif

    select (nADOC_IT)
    
    if lSumirati == .t.

        nM2 := 0

        // sracunaj za iste artikle
        do while !EOF() .and. field->art_sh_des == cArt_sh

            if field->print == "D"
                // kolicina
                nM2 += field->doc_it_tot
            endif

            skip

        enddo
    
    endif   
    
    select fakt_pripr
    append blank
    
    scatter()

    _txt := ""
    _rbr := STR( ++_redni_broj, 3 )
    _idpartner := cPartn
    _idfirma := "10"
    _brdok := cBrDok
    _idtipdok := cIdVd
    _datdok := dDatDok
    _idroba := cIdRoba
    _cijena := nPrice
    _kolicina := nM2
    _dindem := _valuta
    _zaokr := 2
        
    _txt := ""

    // roba tip U - nista
    a_to_txt( "", .t. )
    // dodatni tekst otpremnice - nista
    a_to_txt( "", .t. )
    // naziv partnera
    a_to_txt( _g_pfmk_desc( cPartn ) , .t. )
    // adresa
    a_to_txt( _g_pfmk_addr( cPartn ) , .t. )
    // ptt i mjesto
    a_to_txt( _g_pfmk_place( cPartn ) , .t. )
    // broj otpremnice
    a_to_txt( "" , .t. )
    // datum  otpremnice
    a_to_txt( DTOC( dDatDok ) , .t. )
    
    // broj ugovora - nista
    a_to_txt( "", .t. )
    
    // datum isporuke - nista
    a_to_txt( "", .t. )
    
    // 10. datum valute - nista
    a_to_txt( "", .t. )
    
    // 11. 
    a_to_txt( "", .t. )
    // 12. 
    a_to_txt( "", .t. )
    // 13. 
    a_to_txt( "", .t. )
    // 14. 
    a_to_txt( "", .t. )
    // 15. 
    a_to_txt( "", .t. )
    // 16. 
    a_to_txt( "", .t. )
    // 17. 
    a_to_txt( "", .t. )
    // 18. 
    a_to_txt( "", .t. )
    // 19. 
    a_to_txt( "", .t. )
    // 20.
    a_to_txt( "", .t. )

    gather()

    // ubaci mi atribute u fakt_atribute
    if !EMPTY( cArt_sh )

        _t_area := SELECT()

        _items_atrib := hb_hash()
        _items_atrib["opis"] := cArt_sh
        fakt_atrib_hash_to_dbf( field->idfirma, field->idtipdok, field->brdok, field->rbr, _items_atrib )

        select ( _t_area )

    endif
 
    select (nADOC_IT)

    if lSumirati == .f.
        skip
    endif
    
enddo

// ubaci sada brojeve veze
// ======================================

// ubaci prvo u fakt
_ins_x_veza( nADoc_it )

// ubaci brojeve veze u tabelu docs
_ins_veza( nADoc_it, nADocs, cBrDok, lTemp )

// sredi redne brojeve
_fix_rbr()

select ( F_FAKT_PRIPR )
use

msgbeep("export dokumenta zavrsen !")

select (nTArea)

return




// --------------------------------------
// ubaci vezu u tabelu docs
// --------------------------------------
static function _ins_veza( nA_doc_it, nA_docs, cBrfakt, lTemp )
local nDoc_no
local _rec

if !lTemp
    if !f18_lock_tables( { "rnal_docs" } )
        MsgBeep( "Problem sa lokovanjem tabele rnal_docs !" )
        return .f.
    endif
    sql_table_update( NIL, "BEGIN" )
endif

select ( nA_doc_it )
set order to tag "1"
go top

do while !EOF()

    // ovo preskoci
    if field->print == "N"
        skip
        loop
    endif

    nDoc_no := field->doc_no

    // setuj da je dokument prenesen u DOCS
    select (nA_docs)
    seek docno_str(nDoc_no)

    if !FOUND()
        MsgBeep( "Nalog ne postoji u azuriranim dokumentima !" )
        return .f.
    endif

    _rec := dbf_get_rec()
    _rec["doc_in_fmk"] := 1
    _rec["fmk_doc"] := _add_to_field( ALLTRIM( _rec["fmk_doc"] ), ;
        ALLTRIM(cBrfakt) )

    if !lTemp
        if !update_rec_server_and_dbf( "rnal_docs", _rec, 1, "CONT" )
            f18_free_tables( { "rnal_docs" } )
            sql_table_update( NIL, "ROLLBACK" )
            return .f.
        endif
    else
        dbf_update_rec( _rec )
    endif

    select ( nA_doc_it )
    skip

enddo

if !lTemp
    f18_free_tables( { "rnal_docs" } )
    sql_table_update( NIL, "END" )
endif


return .t.


// -----------------------------------
// sredi redne brojeve
// -----------------------------------
static function _fix_rbr()
local nRbr

// sredi redne brojeve pripreme
select fakt_pripr
set order to tag "0"
go top
nRbr := 0
do while !EOF()
    replace field->rbr with STR( ++nRbr, 3 )
    skip
enddo

return


// -----------------------------------
// ubaci broj veze u fakt pripr
// -----------------------------------
static function _ins_x_veza( nArea )
local cTmp := ""
local nDoc_no
local cIns_x := ""

select ( nArea )
set order to tag "1"
go top

do while !EOF()
    
    // treba li ovo ubaciti ?
    if field->print == "N"
        skip
        loop
    endif

    nDoc_no := field->doc_no

    // veza, broj naloga
    cTmp := _add_to_field( cTmp, ALLTRIM(STR( nDoc_No )) )

    skip
enddo

// insertuj u veze ovu vezu
set_fakt_vezni_dokumenti( cTmp )

return .t.


// -----------------------------------------------------
// setuje vezne dokumente za odredjeni dokument
// -----------------------------------------------------
static function set_fakt_vezni_dokumenti( value )
local _ok := .t.
local _memo, _rec
local _t_area := SELECT()

if value == NIL 
    return _ok
endif

select fakt_pripr
go top

_rec := dbf_get_rec()

_memo := ParsMemo( _rec["txt"] )

// setuj 19-ti clan matrice
_memo[19] := value 

// konvertuj mi memo field u txt
// zatim setuj za novu vrijednost polja
_rec["txt"] := fakt_memo_field_to_txt( _memo )

dbf_update_rec( _rec )

select ( _t_area )

return _ok




// --------------------------------------------
// dodaj dokument u listu 
// --------------------------------------------
function _add_to_field( field_value, new_value )
local _ret := ""
local _sep := ";"
local _tmp 
local _a_tmp
local _seek
local _i

_tmp := ALLTRIM( field_value )
_a_tmp := TokToNiz( _tmp, _sep )
_seek := ASCAN( _a_tmp, { | val | val == new_value } )

if _seek = 0
    AADD( _a_tmp, new_value  )
    // sortiraj
    ASORT( _a_tmp )
endif

// zatim daj u listu sve stavke
for _i := 1 to LEN( _a_tmp )
    if !EMPTY( _a_tmp[ _i ] )
        _ret += _a_tmp[ _i ] + _sep
    endif
next

return _ret



// ----------------------------------------------------
// sracunaj kolicinu na osnovu vrijednosti polja
// ----------------------------------------------------
function _g_kol( cValue, cQttyType, nKol, nQtty, ;
        nHeigh1, nWidth1, nHeigh2, nWidth2 )

local nTmp := 0

if nHeigh2 == nil
    nHeigh2 := 0
endif

if nWidth2 == nil
    nWidth2 := 0
endif

// po metru
if UPPER(cQttyType) == "M"  

    // po metru, znaèi uzmi sve stranice stakla
    
    if "#D1#" $ cValue
        nTmp += nWidth1
    endif
    
    if "#D4#" $ cValue
    
        if nWidth2 <> 0
            nTmp += nWidth2
        else
            nTmp += nWidth1
        endif
    
    endif

    if "#D2#" $ cValue
        nTmp += nHeigh1
    endif

    if "#D3#" $ cValue
        if nHeigh2 <> 0
            nTmp += nHeigh2
        else
            nTmp += nHeigh1
        endif
    endif

    // pretvori u metre
    nKol := ( nQtty * nTmp ) / 1000
    
endif

// po m2
if UPPER(cQttyType) == "M2"
    
    nKol := c_ukvadrat( nQtty, nHeigh1, nWidth1 ) 
    
endif

// po komadu
if UPPER(cQttyType) == "KOM"
    
    // busenje
    if "<A_BU>" $ cValue

        // broj rupa za busenje
        cTmp := STRTRAN( ALLTRIM(cValue), "<A_BU>:#" )
        aTmp := TokToNiz( cTmp, "#" )

        nKol := LEN( aTmp )
    
    else
        nKol := nQtty
    endif

endif

if EMPTY( cQttyType )

    nKol := nQtty

endif

return



// ----------------------------------------------------
// pronadji partnera u PARTN
// ----------------------------------------------------
static function fnd_partn( xPartn, nCustId, cDesc  )
local nTArea := SELECT()
private GetList:={}

O_PARTN

xPartn := SPACE(6)

Box(, 5, 70)
    @ m_x + 1, m_y + 2 SAY "Narucioc: " 
    @ m_x + 1, col() + 1 SAY ALLTRIM(STR(nCustId)) COLOR "I"
    @ m_x + 1, col() + 1 SAY " -> " 
    @ m_x + 1, col() + 1 SAY PADR(cDesc, 50) + ".." COLOR "I"
    @ m_x + 2, m_y + 2 SAY "nije definisan u relacijama, pronadjite njegov par !!!!"
    @ m_x + 4, m_y + 2 SAY "sifra u FMK =" GET xPartn VALID p_firma( @xPartn )
    read
BoxC()

select (nTArea)

ESC_RETURN 0
return 1


// ----------------------------------------------------
// pronadji robu u ROBA
// ----------------------------------------------------
static function fnd_roba( xRoba, nArtId, cDesc )
local nTArea := SELECT()
private GetList:={}

O_ROBA
O_SIFK
O_SIFV

xRoba := SPACE(10)

Box(, 5, 70)
    @ m_x + 1, m_y + 2 SAY "Artikal:" 
    @ m_x + 1, col() + 1 SAY ALLTRIM(STR(nArtId)) COLOR "I"
    @ m_x + 1, col() + 1 SAY " -> " 
    @ m_x + 1, col() + 1 SAY PADR(cDesc, 50) + ".." COLOR "I"
    @ m_x + 2, m_y + 2 SAY "nije definisan u tabeli relacija, pronadjite njegov par !!!"
    @ m_x + 4, m_y + 2 SAY "sifra u FMK =" GET xRoba VALID p_roba( @xRoba )
    read
BoxC()

select (nTArea)

ESC_RETURN 0
return 1



// ----------------------------------------
// vraca naziv partnera iz FMK
// ----------------------------------------
static function _g_pfmk_desc( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

if FOUND()
    xRet := ALLTRIM( partn->naz )
endif

select (nTArea)
return xRet


// ----------------------------------------
// vraca adresu partnera iz FMK
// ----------------------------------------
static function _g_pfmk_addr( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

if FOUND()
    xRet := ALLTRIM( partn->adresa )
endif

select (nTArea)
return xRet


// ----------------------------------------
// vraca mjesto i ptt partnera iz FMK
// ----------------------------------------
static function _g_pfmk_place( cPart )
local xRet := ""
local nTArea := SELECT()

O_PARTN
select partn
set order to tag "ID"
seek cPart

if FOUND()
    xRet := ALLTRIM( partn->ptt ) + " " + ALLTRIM( partn->mjesto )
endif

select (nTArea)
return xRet


// -----------------------------------
// dodaj u polje txt tekst
// lVise - vise tekstova
// -----------------------------------
static function a_to_txt( cVal, lEmpty )
local nTArr
nTArr := SELECT()

if lEmpty == nil
    lEmpty := .f.
endif

// ako je prazno nemoj dodavati
if !lEmpty .and. EMPTY(cVal)
    return
endif

_txt += CHR(16) + cVal + CHR(17)

select (nTArr)
return


