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



// -----------------------------------------------
// pregled / stampa azuriranih dokumenata 
// -----------------------------------------------
function fakt_pregled_liste_dokumenata()
local _curr_user := "<>"
local nCol1:=0
local nul,nizl,nRbr
local m
local _objekat_id
local dDatod, dDatdo
local _params := fakt_params()
local _vrste_pl := _params["fakt_vrste_placanja"]
local _objekti := _params["fakt_objekti"]
local _vezni_dokumenti := _params["fakt_dok_veze"]
local lOpcine := .t.
local valute := SPACE(3)
private cImekup, cIdFirma, qqTipDok, cBrFakDok, qqPartn
private cFilter := ".t."

O_VRSTEP
O_OPS
O_VALUTE
O_RJ
O_FAKT_OBJEKTI
O_FAKT
O_PARTN
O_FAKT_DOKS

// setuj relacije 
SET RELATION TO fakt_doks->idfirma + fakt_doks->idtipdok + fakt_doks->brdok INTO fakt, ;
            TO fakt_doks->idvrstep INTO vrstep, ;
            TO fakt_doks->idpartner INTO partn

qqVrsteP := SPACE(20)
dDatVal0 := dDatVal1 := CTOD("")

cIdfirma := gFirma
dDatOd := ctod("")
dDatDo := date()
qqTipDok := ""
qqPartn := space(20)
cTabela := "N"
cBrFakDok := SPACE(40)
cImeKup := space(20)
cOpcina := SPACE(30)

if _objekti
    _objekat_id := SPACE(10)
endif

Box( , 13 + IF( _vrste_pl .or. lOpcine .or. _objekti, 6, 0 ), 77 )

    cIdFirma := fetch_metric("fakt_stampa_liste_id_firma", _curr_user, cIdFirma )
    qqTipDok := fetch_metric("fakt_stampa_liste_dokumenti", _curr_user, qqTipDok )
    dDatOd := fetch_metric("fakt_stampa_liste_datum_od", _curr_user, dDatOd )
    dDatDo := fetch_metric("fakt_stampa_liste_datum_do", _curr_user, dDatDo )
    cTabela := fetch_metric("fakt_stampa_liste_tabelarni_pregled", _curr_user, cTabela )
    cImeKup := fetch_metric("fakt_stampa_liste_ime_kupca", _curr_user, cImeKup )
    qqPartn := fetch_metric("fakt_stampa_liste_partner", _curr_user, qqPartn )
    cBrFakDok := fetch_metric("fakt_stampa_liste_broj_dokumenta", _curr_user, cBrFakDok )

    cImeKup := PADR( cImeKup, 20 )
    qqPartn := PADR( qqPartn, 20 )
    qqTipDok := PADR( qqTipDok, 2 )

    do while .t.

    if gNW $ "DR"
        cIdFirma := PADR( cIdfirma, 2 )
        @ m_x + 1, m_y + 2 SAY "RJ prazno svi" GET cIdFirma valid {|| empty(cidfirma) .or. cidfirma==gfirma .or. P_RJ(@cIdFirma), cIdFirma := LEFT( cIdFirma, 2 ), .t. }
        read
    else
        @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma), cIdFirma := LEFT(cIdFirma, 2 ), .t. }
    endif

    @ m_x + 2, m_y + 2 SAY "Tip dokumenta (prazno svi tipovi)" GET qqTipDok pict "@!"
    @ m_x + 3, m_y + 2 SAY "Od datuma " GET dDatOd
    @ m_x + 3, col() + 1 SAY "do" GET dDatDo
    @ m_x + 5, m_y + 2 SAY "Ime kupca pocinje sa (prazno svi)" GET cImeKup pict "@!"
    @ m_x + 6, m_y + 2 SAY "Uslov po sifri kupca (prazno svi)" GET qqPartn pict "@!" ;
                VALID {|| aUslSK := Parsiraj( @qqPartn, "IDPARTNER", "C", NIL, F_PARTN ), .t. }
    @ m_x + 7, m_y + 2 SAY "Broj dokumenta (prazno svi)" GET cBrFakDok pict "@!"
    @ m_x + 9, m_y + 2 SAY "Tabelarni pregled" GET cTabela valid cTabela $ "DN" pict "@!"
 
    cRTarifa := "N"

    @ m_x + 11, m_y + 2 SAY "Rekapitulacija po tarifama ?" GET cRTarifa valid cRtarifa $"DN" pict "@!"

    IF _vrste_pl
        @ m_x + 12, m_y + 2 SAY "----------------------------------------"
        @ m_x + 13, m_y + 2 SAY "Za fakture (Tip dok.10):"
        @ m_x + 14, m_y + 2 SAY "Nacin placanja:" GET qqVrsteP
        @ m_x + 15, m_y + 2 SAY "Datum valutiranja od" GET dDatVal0
        @ m_x + 15, col() + 2 SAY "do" GET dDatVal1
        @ m_x + 16, m_y + 2 SAY "----------------------------------------"
    ENDIF

    @ m_x + 17, m_y + 2 SAY "Opcina (prazno-sve): "  get cOpcina
    
    if _objekti
        @ m_x + 18, m_y + 2 SAY "Objekat (prazno-svi): "  get _objekat_id valid EMPTY(_objekat_id) .or. P_fakt_objekti(@_objekat_id)
    endif
        
    @ m_x + 19, m_y + 2 SAY "Valute ( /KM/EUR)"  GET valute 
 
    read

    ESC_BCR

    aUslBFD := Parsiraj( cBrFakDok, "BRDOK", "C" )
    aUslSK := Parsiraj( qqPartn, "IDPARTNER", "C" )
    aUslVrsteP := Parsiraj( qqVrsteP, "IDVRSTEP", "C" )
    aUslOpc := Parsiraj( cOpcina, "IDOPS", "C" )
    
    if (!lOpcine .or. aUslOpc <> NIL) .and. aUslBFD<>NIL .and. aUslSK<>NIL .and. ( !_vrste_pl .or. aUslVrsteP <> NIL )
        exit
    endif

    enddo

    qqTipDok := TRIM( qqTipDok )
    qqPartn := TRIM( qqPartn )

    set_metric( "fakt_stampa_liste_id_firma", f18_user(), cIdFirma )
    set_metric( "fakt_stampa_liste_dokumenti", f18_user(), qqTipDok )
    set_metric( "fakt_stampa_liste_datum_od", f18_user(), dDatOd )
    set_metric( "fakt_stampa_liste_datum_do", f18_user(), dDatDo )
    set_metric( "fakt_stampa_liste_tabelarni_pregled", f18_user(), cTabela )
    set_metric( "fakt_stampa_liste_ime_kupca", f18_user(), cImeKup )
    set_metric( "fakt_stampa_liste_partner", f18_user(), qqPartn )
    set_metric( "fakt_stampa_liste_broj_dokumenta", f18_user(), cBrFakDok )

BoxC()

select fakt_doks
set order to tag "1D"
go top

IF !EMPTY( dDatVal0 ) .or. !EMPTY( dDatVal1 )
    cFilter += ".and. ( !idtipdok='10' .or. datpl>=" + _filter_quote( dDatVal0 ) + ".and. datpl<=" + _filter_quote( dDatVal1 ) + ")"
ENDIF

IF !EMPTY( qqVrsteP )
    cFilter += ".and. (!idtipdok='10' .or. " + aUslVrsteP + ")"
ENDIF

if !EMPTY( qqTipDok )
   cFilter += ".and. idtipdok==" + _filter_quote( qqTipDok )
endif

if !EMPTY( dDatOd ) .or. !EMPTY( dDatDo )
    cFilter += ".and. datdok>=" + _filter_quote( dDatOd ) + ".and. datdok<=" + _filter_quote( dDatDo )
endif

if !EMPTY( cImekup )
    cFilter += ".and. partner=" + _filter_quote( TRIM( cImeKup ) )
endif

if !EMPTY( cIdFirma )
    cFilter += ".and. IdFirma=" + _filter_quote( cIdFirma )
endif

if !EMPTY( cOpcina )
    cFilter += ".and. PARTN->(" + aUslOpc + ")"
endif

if _objekti .and. !Empty(_objekat_id)
    cFilter += ".and. fakt_objekat_id() == " + _filter_quote( _objekat_id )
endif

if !EMPTY( cBrFakDok )
    cFilter += ".and." + aUslBFD
endif

if !EMPTY( qqPartn )
    cFilter += ".and." + aUslSK
endif

if !EMPTY( valute )
    cFilter += ".and. dindem = " + _filter_quote( valute )
endif

if cFilter == ".t. .and."
    cFilter := SUBSTR( cFilter, 9 ) 
endif

if cFilter == ".t."
    set Filter to
else
    set Filter to &cFilter
endif

@ MAXROW() - 4, MAXCOL() - 3 SAY STR( rloptlevel(), 2 )

qqTipDok := TRIM( qqTipDok )

seek cIdFirma + qqTipDok

EOF CRET

if cTabela == "D"
    fakt_lista_dokumenata_tabelarni_pregled( _vrste_pl, lOpcine, cFilter )
else
    gaZagFix := { 3, 3 }
    stampa_liste_dokumenata( dDatOd, dDatDo, qqTipDok, cIdFirma, _objekat_id, cImeKup, lOpcine, aUslOpc, valute )
endif

close all
return



// printaj narudzbenicu
function pr_nar(lOpcine)

select fakt_doks
nTrec:=recno()
_cIdFirma:=idfirma
_cIdTipDok:=idtipdok
_cBrDok:=brdok

close all
o_fakt_edit()
StampTXT(_cidfirma, _cIdTipdok, _cbrdok, .t.)

nar_print(.t.)
select (F_FAKT_DOKS)
use
O_FAKT_DOKS

if lOpcine
    O_PARTN
    select fakt_doks
    set relation to idpartner into PARTN
endif
if cFilter == ".t."
    set Filter to
else
    set Filter to &cFilter
endif
go nTrec

return DE_CONT

// print radni nalog
function pr_rn()

select fakt_doks
nTrec:=recno()
_cIdFirma:=idfirma
_cIdTipDok:=idtipdok
_cBrDok:=brdok
close all
o_fakt_edit()
StampTXT(_cidfirma, _cIdTipdok, _cbrdok, .t.)

// printaj radni nalog
rnal_print(.t.)
select (F_FAKT_DOKS)
use

O_FAKT_DOKS
if lOpcine
    O_PARTN
    select fakt_doks
    set relation to idpartner into PARTN
endif
if cFilter==".t."
    set Filter to
else
    set Filter to &cFilter
endif
go nTrec
return DE_CONT



// stampaj poresku fakturu
function pr_pf(lOpcine)
local nTrec

select fakt_doks
nTrec := recno()

_cIdFirma:=idfirma
_cIdTipDok:=idtipdok
_cBrDok:=brdok

close all

o_fakt_edit()

StampTXT(_cidfirma, _cIdTipdok, _cbrdok)

select (F_FAKT_DOKS)
use

O_FAKT_DOKS
if lOpcine
    O_PARTN
    select fakt_doks
    set relation to idpartner into PARTN
endif
if cFilter == ".t."
    set Filter to
else
    set Filter to &cFilter
endif
go nTrec
    
return DE_CONT


// stampaj poresku fakturu u odt formatu
function pr_odt(lOpcine)
select fakt_doks

nTrec:=recno()
_cIdFirma:=idfirma
_cIdTipDok:=idtipdok
_cBrDok:=brdok
close all

StDokOdt( _cidfirma, _cIdTipdok, _cbrdok )


o_fakt_edit()
select (F_FAKT_DOKS)
use
O_FAKT_DOKS
if lOpcine
    O_PARTN
    select fakt_doks
    set relation to idpartner into PARTN
endif
if cFilter==".t."
    set Filter to
else
    set Filter to &cFilter
endif
go nTrec
    
return DE_CONT



// --------------------------
// generisi fakturu
// --------------------------
function generisi_fakturu( is_opcine )
local cTipDok
local cFirma
local cBrFakt
local nCnt := 0
local dDatFakt
local dDatVal
local dDatIsp
local i
local cPart
local aMemo := {}
local _rec
local _t_area := SELECT()

if Pitanje(,"Generisati fakturu na osnovu ponude ?", "D") == "N"
    return DE_CONT
endif

O_FAKT_PRIPR
O_FAKT

if fakt_pripr->( RECCOUNT() ) <> 0
    MsgBeep( "Priprema mora biti prazna !!!" )
    select ( _t_area )
    return DE_CONT
endif

select fakt_doks

nTrec := RecNo()

cTipDok := field->idtipdok
cFirma := field->idfirma
cBrFakt := field->brdok
cPart := field->idpartner
dDatFakt := DATE()
dDatVal := DATE()
dDatIsp := DATE()

cNBrFakt := fakt_brdok_0(cFirma, cTipDok, dDatFakt)

// uslovi generisanja...
Box(, 5, 55)

    @ m_x + 1, m_y + 2 SAY "*** Parametri fakture "  

    @ m_x + 3, m_y + 2 SAY "  Datum fakture: " GET dDatFakt VALID !EMPTY(dDatFakt) 
    @ m_x + 4, m_y + 2 SAY "   Datum valute: " GET dDatVal VALID !EMPTY(dDatVal) 
    @ m_x + 5, m_y + 2 SAY " Datum isporuke: " GET dDatIsp VALID !EMPTY(dDatIsp) 

    read

BoxC()

// dokument ubaci u pripremu...
select fakt
set order to tag "1"
go top
seek cFirma + cTipDok + cBrFakt

do while !EOF() .and. field->idfirma + field->idtipdok + field->brdok == cFirma + cTipDok + cBrFakt

    ++ nCnt

    _rec := dbf_get_rec()
   
    aMemo := ParsMemo( _rec["txt"] )

    _rec["idtipdok"] := "10"
    _rec["brdok"] := cNBrFakt
    _rec["datdok"] := dDatFakt
    
    // dodaj memo polje, samo prva stavka
    if nCnt = 1
    
        _rec["txt"] := ""
        _rec["txt"] += CHR(16) + aMemo[1] + CHR(17)
        _rec["txt"] += CHR(16) + aMemo[2] + CHR(17)
        _rec["txt"] += CHR(16) + aMemo[3] + CHR(17)
        _rec["txt"] += CHR(16) + aMemo[4] + CHR(17)
        _rec["txt"] += CHR(16) + aMemo[5] + CHR(17)
        _rec["txt"] += CHR(16) + aMemo[6] + CHR(17)
        // datum otpremnice
        _rec["txt"] += CHR(16) + DTOC(dDatIsp) + CHR(17)
        _rec["txt"] += CHR(16) + aMemo[8] + CHR(17)
        // datum narudzbe / amemo[9]
        _rec["txt"] += CHR(16) + DTOC(dDatVal) + CHR(17)
        // datum valute / amemo[10]
        _rec["txt"] += CHR(16) + DTOC(dDatVal) + CHR(17)

        // dodaj i ostala polja

        if LEN(aMemo) > 10
            for i:=11 to LEN(aMemo)
                _rec["txt"] += CHR(16) + aMemo[i] + CHR(17)
            next
        endif

    endif
    
    select fakt_pripr
    append blank
    dbf_update_rec( _rec )

    select fakt
    skip

enddo

if nCnt > 0
    MsgBeep( "Dokument formiran i nalazi se u pripremi. Obradite ga !" )
endif
    
// sada imamo dokument u pripremi...

// mozemo ga automatski azurirati po zelji... 
// ostavljam ovo za sada...

if isugovori()

    if pitanje(,"Setovati datum uplate za partnera ?", "N") == "D"
        
        O_UGOV
        select ugov
        set order to tag "PARTNER"
        go top
        seek cPart

        if FOUND() .and. field->idpartner == cPart
            _rec := dbf_get_rec()
            _rec["dat_l_fakt"] := DATE()
            update_rec_server_and_dbf( "fakt_ugov", _rec, 1, "FULL" )
        endif
        
    endif

endif

select fakt_doks

if is_opcine
    O_PARTN
    select fakt_doks
    set relation to idpartner into PARTN
endif

if cFilter == ".t."
    set Filter to
else
    set Filter to &cFilter
endif

go nTrec
   
return DE_REFRESH


function pr_choice()
local nSelected
private Opc:={}
private opcexe:={}
private Izbor
    
AADD(opc, "   >  stampa dokumenta        " )
AADD(opcexe, {|| nSelected:=Izbor, Izbor:=0  } )
AADD(opc, "   >  stampa narudzbenice     " )
AADD(opcexe, {|| nSelected:=Izbor, Izbor:=0  } )
AADD(opc, "   >  stampa radnog naloga    " )
AADD(opcexe, {|| nSelected:=Izbor, Izbor:=0  } )

Izbor := 1
Menu_SC("pch")

return nSelected


// -------------------------------------------------
// prikazuje broj fiskalnog racuna
// -------------------------------------------------
static function _veza_fc_rn()
local _fisc_rn
local _rekl_rn
local _total
local _txt := ""

_fisc_rn := ALLTRIM( STR( fakt_doks->fisc_rn ) )
_rekl_rn := ALLTRIM( STR( fakt_doks->fisc_st ) )
_total := fakt_doks->iznos

// samo za izlazne dokumente
if fakt_doks->idtipdok $ "10#11"
    
    if _fisc_rn == "0" .and. _rekl_rn == "0"

        _txt := "nema fiskalnog racuna !?!!!"

        @ m_x + 1, m_y + 2 SAY PADR( _txt, 60 ) COLOR "W/R+"
    
    else
        
        _txt := ""

        if _rekl_rn <> "0"
            _txt += "reklamni racun: " + _rekl_rn + ", " 
        endif

        _txt += "fiskalni rn: " + _fisc_rn
               
        @ m_x + 1, m_y + 2 SAY PADR( _txt, 60 ) COLOR "GR+/B"
    endif

else
    @ m_x + 1, m_y + 2 SAY PADR( "", 60 )
endif

return



// -------------------------------------------------------- 
// -------------------------------------------------------- 
function fakt_tabela_komande( lOpcine, fakt_doks_filt )
local nRet := DE_CONT
local _rec
local _filter
local _dev_id, _dev_params
local _refresh
local _t_rec := RECNO()
local _t_area := SELECT()

_filter := DBFilter()

// ispis informacije o fiskalnom racunu
_veza_fc_rn()

_refresh := .f.

do case
 
    // stampa dokumenta
    case Ch == K_ENTER 

        nRet := pr_pf( lOpcine )
        _refresh := .t.

    // odt stampa dokumenta
    case Ch == K_ALT_P
        
        nRet := pr_odt( lOpcine )
        _refresh := .t.
 
    // refresh tabele
    case Ch == K_F5
    
        // zatvori tabelu, pa otvori  
        select fakt_doks
        use
        O_FAKT_DOKS

        // refresh tabele
        nRet := DE_REFRESH
        _refresh := .t.


    // setovanje broja veze fiskalnog racuna
    case CH == K_CTRL_V
    
        // setovanje broj fiskalnog isjecka
        select fakt_doks
    
        if field->fisc_rn <> 0

            msgbeep("veza: fiskalni racun vec setovana !")

            if Pitanje( "FAKT_PROM_VEZU", "Promjeniti postojecu vezu (D/N)?", "N" ) == "N"
                return DE_CONT
            endif

        endif
    
        if Pitanje( "FISC_NVEZA_SET", "Setovati novu vezu sa fiskalnim racunom (D/N)?", "D" ) == "N"
            return DE_CONT
        endif
    
        nFiscal := field->fisc_rn
        nRekl := field->fisc_st
        dFiscal_date := field->fisc_date
        cFiscal_time := PADR( field->fisc_time, 10 )

        Box(, 4, 40)
            @ m_x + 1, m_y + 2 SAY "fiskalni racun:" GET nFiscal PICT "9999999999"
            @ m_x + 2, m_y + 2 SAY "reklamni racun:" GET nRekl PICT "9999999999"
            @ m_x + 3, m_y + 2 SAY "         datum:" GET dFiscal_date
            @ m_x + 4, m_y + 2 SAY "       vrijeme:" GET cFiscal_time PICT "@S10"
            read
        BoxC()
    
        if nFiscal <> field->fisc_rn .or. nRekl <> field->fisc_st

            _rec := dbf_get_rec()
            _rec["fisc_rn"] := nFiscal
            _rec["fisc_st"] := nRekl
            _rec["fisc_time"] := cFiscal_time
            _rec["fisc_date"] := dFiscal_date

            update_rec_server_and_dbf( "fakt_doks", _rec, 1, "FULL" )

            nRet := DE_REFRESH
            _refresh := .t.
        
        endif
   
    // informacije o dokumentu 
    case chr(Ch) $ "iI"
    
        // info dokument
        msgbeep( getfullusername( field->oper_id ) )

    // korekcija podataka dokumenta
    case chr(Ch) $ "kK"
    
        // korekcija podataka na dokumentu
        if fakt_edit_data( field->idfirma, field->idtipdok, field->brdok )
            nRet := DE_REFRESH
            _refresh := .t.
        endif

    // stampanje fiskalnog racuna
    case UPPER( chr( Ch ) ) == "R"

        if !fiscal_opt_active()
            return DE_CONT
        endif

        // stampa fiskalnog racuna
        if field->idtipdok $ "10#11"
        
            if field->fisc_rn > 0
                msgbeep("Fiskalni racun vec stampan za ovaj dokument !!!#Ako je potrebna ponovna stampa resetujte broj veze.")
                return DE_CONT
            endif
        
            if Pitanje( "ST FISK RN5","Stampati fiskalni racun za dokument " + ;
                ALLTRIM( field->idfirma ) + "-" + ;
                ALLTRIM( field->idtipdok ) + "-" + ;
                ALLTRIM( field->brdok ) + " (D/N) ?", "D") == "D"

                _dev_id := get_fiscal_device( my_user(), field->idtipdok )

                if _dev_id > 0

                    _dev_params := get_fiscal_device_params( _dev_id, my_user() )

                    if _dev_params == NIL
                        return DE_CONT
                    endif

                else
                    MsgBeep("Problem sa fiskalnim parametrima !!!")
                    return DE_CONT
                endif

                // da li je korisniku dozvoljeno da stampa racune ?
                if _dev_params["print_fiscal"] == "N"
                    MsgBeep( "Nije Vam dozvoljena opcija za stampu fiskalnih racuna !" )
                    return DE_CONT
                endif
 
                fakt_fisc_rn( field->idfirma, field->idtipdok, field->brdok, .f., _dev_params )

                nRet := DE_REFRESH
                _refresh := .t.

            endif

        endif

    // duplikat dokumenta
    case chr(ch) $ "wW"
        
        fakt_napravi_duplikat( field->idfirma, field->idtipdok, field->brdok )
        select fakt_doks

    // generisanje storno dokumenta
    case chr(Ch) $ "sS"

        // generisi storno dokument
        storno_dok( field->idfirma, field->idtipdok, field->brdok )
     
        if Pitanje(, "Preci u tabelu pripreme ?", "D" ) == "D"
            fUPripremu := .t.
            nRet := DE_ABORT
        else
            nRet := DE_REFRESH
            _refresh := .t.
        endif
  
    // printanje radnog naloga
    case UPPER(chr(Ch)) == "B"

        nRet := pr_rn() 
        _refresh := .t. 
     
    // printanje narudzbenice
    case chr(Ch) $ "nN"
        
        nRet := pr_nar(lOpcine)
        _refresh := .t.
  
    // generisanje fakture na osnovu ponude
    case chr(Ch) $ "fF"
        
        if idtipdok $ "20"
            nRet := generisi_fakturu(lOpcine)
            _refresh := .t.
        endif
     
    // povrat dokumenta u pripremu
    case chr(Ch) $ "pP"
     
        _tmp := povrat_fakt_dokumenta( .f., field->idfirma, field->idtipdok, field->brdok )

        O_FAKT_DOKS

        if _tmp <> 0 .and. Pitanje(, "Preci u tabelu pripreme ?", "D" ) == "D"
            fUPripremu := .t.
            _refresh := .f.
            nRet := DE_ABORT
        else
            nRet := DE_REFRESH
            _refresh := .t.
        endif

endcase

// refresh ako ima potrebe za tim...
if _refresh 

	select fakt_doks
	set order to tag "1D"

    refresh_fakt_tbl_dbfs( _filter )

	go ( _t_rec )

endif

return nRet




function refresh_fakt_tbl_dbfs( tbl_filter )

close all

O_VRSTEP
O_OPS
O_FAKT_DOKS2
O_VALUTE
O_RJ
O_FAKT_OBJEKTI
O_FAKT
O_PARTN
O_FAKT_DOKS

// setuj relacije 
SET RELATION TO fakt_doks->idfirma + fakt_doks->idtipdok + fakt_doks->brdok INTO fakt, ;
            TO fakt_doks->idvrstep INTO vrstep, ;
            TO fakt_doks->idpartner INTO partn


select fakt_doks
set order to tag "1D"
go top

SET FILTER TO &(tbl_filter)

return .t.




function fakt_vt_porezi()
public _ZPP:=0
if roba->tip=="V"
  public _OPP:=0,_PPP:=tarifa->ppp/100
  public _PORVT:=tarifa->opp/100
elseif roba->tip=="K"
  public _OPP:=tarifa->opp/100,_PPP:=tarifa->ppp/100
  public _PORVT:=tarifa->opp/100
else
  public _OPP:=tarifa->opp/100
  public _PPP:=tarifa->ppp/100
  public _ZPP:=tarifa->zpp/100
  public _PORVT:=0
endif
return





function fakt_real_partnera()

O_FAKT_DOKS
O_PARTN
O_VALUTE
O_RJ

cIdfirma := gFirma
dDatOd := CTOD("")
dDatDo := DATE()

qqTipDok := "10;"

Box(,11,77)

cTabela := "N"
cBrFakDok := SPACE(40)
cImeKup := SPACE(20)

qqPartn := SPACE(20)
qqOpc := SPACE(20)

cTabela := fetch_metric("fakt_real_tabela", my_user(), cTabela )
cImeKup := fetch_metric("fakt_real_ime_kupca", my_user(), cImeKup )
qqPartn := fetch_metric("fakt_real_partner", my_user(), qqPartn )
cBrFakDok := fetch_metric("fakt_real_broj_dok", my_user(), cBrFakDok )
cIdFirma := fetch_metric("fakt_real_id_firma", my_user(), cIdFirma )
dDatOd := fetch_metric("fakt_real_datum_od", my_user(), dDatOd )
dDatDo := fetch_metric("fakt_real_datum_do", my_user(), dDatDo )

qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,40)
qqOpc:=padr(qqOpc,20)

do while .t.
    cIdFirma:=padr(cidfirma,2)
    @ m_x+1,m_y+2 SAY "RJ            " GET cIdFirma valid {|| empty(cidfirma) .or. cidfirma==gfirma .or. P_RJ(@cIdFirma), cIdFirma := LEFT( cIdFirma, 2 ), .t. }
    @ m_x+2,m_y+2 SAY "Tip dokumenta " GET qqTipDok pict "@!S20"
    @ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
    @ m_x+3,col()+1 SAY "do"  get dDatDo
    @ m_x+6,m_y+2 SAY "Uslov po nazivu kupca (prazno svi)"  get qqPartn pict "@!"
    @ m_x+7,m_y+2 SAY "Broj dokumenta (prazno svi)"  get cBrFakDok pict "@!"
    @ m_x+9,m_y+2 SAY "Opcina (prazno sve)" get qqOpc pict "@!"
    read
    ESC_BCR
    aUslBFD:=Parsiraj(cBrFakDok,"BRDOK","C")
    //aUslSK:=Parsiraj(qqPartn,"IDPARTNER")
    aUslTD:=Parsiraj(qqTipdok,"IdTipdok","C")
    if aUslBFD<>NIL .and. aUslTD<>NIL
        exit
    endif
enddo

qqTipDok:=trim(qqTipDok)
qqPartn:=trim(qqPartn)

set_metric("fakt_real_tabela", my_user(), cTabela )
set_metric("fakt_real_ime_kupca", my_user(), cImeKup )
set_metric("fakt_real_partner", my_user(), qqPartn )
set_metric("fakt_real_broj_dok", my_user(), cBrFakDok )
set_metric("fakt_real_id_firma", my_user(), cIdFirma )
set_metric("fakt_real_datum_od", my_user(), dDatOd )
set_metric("fakt_real_datum_do", my_user(), dDatDo )

BoxC()

select fakt_doks

private cFilter:=".t."

if !empty(dDatOd) .or. !empty(dDatDo)
    cFilter+=".and.  datdok>="+cm2str(dDatOd)+".and. datdok<="+cm2str(dDatDo)
endif

if cTabela=="D"  // tabel prikaz
    cFilter+=".and. IdFirma="+cm2str(cIdFirma)
endif

if !empty(cBrFakDok)
  cFilter+=".and."+aUslBFD
endif

//if !empty(qqPartn)
//  cFilter+=".and."+aUslSK
//endif

if !empty(qqTipDok)
  cFilter+=".and."+aUslTD
endif

if cFilter=".t..and."
  cFilter:=substr(cFilter,9)
endif

if cFilter==".t."
  set Filter to
else
  set Filter to &cFilter
endif

EOF CRET

//gaZagFix:={3,3}
START PRINT CRET

private nStrana:=0
private m:="---- ------ -------------------------- ------------ ------------ ------------"

fakt_zagl_real_partnera()

set order to tag "6"
//"6","IdFirma+idpartner+idtipdok",KUMPATH+"DOKS"
seek cIdFirma

nC:=0
ncol1:=10
nTIznos:=nTRabat:=0
private cRezerv:=" "
do while !eof() .and. IdFirma=cIdFirma
    // uslov po partneru
    if !Empty(qqPartn)
        if !(fakt_doks->partner=qqPartn)
            skip
            loop
        endif
    endif
    
    nIznos:=0
    nRabat:=0
    cIdPartner:=idpartner
    select partn
    hseek cIdPartner
    select fakt_doks
    
    
    // uslov po opcini
    if !Empty(qqOpc)
        if AT(partn->idops, qqOpc)==0
            skip
            loop
        endif
    endif
    
    do while !eof() .and. IdFirma=cIdFirma .and. idpartner==cIdpartner
        if DinDem==left(ValBazna(),3)
                nIznos+=ROUND(iznos,ZAOKRUZENJE)
                nRabat+=ROUND(Rabat,ZAOKRUZENJE)
            else
                nIznos+=ROUND(iznos*UBaznuValutu(datdok),ZAOKRUZENJE)
                nRabat+=ROUND(Rabat*UBaznuValutu(datdok),ZAOKRUZENJE)
            endif
        skip
    enddo
    if prow()>61
        FF
        fakt_zagl_real_partnera()
    endif

    ? space(gnLMarg)
    ?? Str(++nC,4)+".", cIdPartner, PADR( partn->naz, 25 )
    nCol1 := pcol() + 1
    @ prow(),pcol()+1 SAY str(nIznos+nRabat,12,2)
    @ prow(),pcol()+1 SAY str(nRabat,12,2)
    @ prow(),pcol()+1 SAY str(nIznos,12,2)

    ntIznos+=nIznos
    ntRabat+=nRabat
enddo

if prow()>59
    FF
    fakt_zagl_real_partnera()
endif

? space(gnLMarg)
?? m
? space(gnLMarg)
?? " Ukupno"
@ prow(),nCol1 SAY str(ntIznos+ntRabat,12,2)
@ prow(),pcol()+1 SAY str(ntRabat,12,2)
@ prow(),pcol()+1 SAY str(ntIznos,12,2)
? space(gnLMarg)
?? m

set filter to  // ukini filter

FF
END PRINT

return


// --------------------------------------------------------
// fakt_zagl_real_partnera()
// Zaglavlje izvjestaja realizacije partnera 
// --------------------------------------------------------
function fakt_zagl_real_partnera()

? 
P_12CPI
?? space(gnLMarg)
IspisFirme(cidfirma)
?
set century on
P_12CPI
? space(gnLMarg); ?? "FAKT: Stampa prometa partnera na dan:",date(),space(8),"Strana:",STR(++nStrana,3)
? space(gnLMarg); ?? "      period:",dDatOd,"-",dDatDo
if qqTipDok<>"10;"
 ? space(gnLMarg); ?? "-izvjestaj za tipove dokumenata :",trim(qqTipDok)
endif

set century off
P_12CPI
? space(gnLMarg); ?? m
? space(gnLMarg); ?? " Rbr  Sifra     Partner                  Ukupno        Rabat          UKUPNO"
? space(gnLMarg); ?? "                                           (1)          (2)            (1-2)"
? space(gnLMarg); ?? m

return

