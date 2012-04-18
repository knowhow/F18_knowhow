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
local cRadniNalog
local dDatod, dDatdo
local _tmp := fetch_metric("fakt_unos_vrste_placanja", nil, "N" )
local _vrste_pl := .f.
local lOpcine := .t.

if _tmp == "D"
    _vrste_pl := .t.
endif

private cImekup, cidfirma, qqTipDok, cBrFakDok, qqPartn

if _vrste_pl
    O_VRSTEP
endif

O_OPS

if glRadNal
    O_RNAL
endif

O_FAKT
O_PARTN
O_FAKT_DOKS

if _vrste_pl
    SET RELATION TO idvrstep INTO VRSTEP
endif

SET RELATION TO idpartner INTO PARTN

if glRadNal
    SET RELATION TO idfirma + idtipdok + brdok INTO FAKT
endif

O_VALUTE
O_RJ

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

if glRadNal
    cRadniNalog := SPACE(10)
endif

Box( , 12 + IF( _vrste_pl .or. lOpcine .or. glRadNal, 6, 0 ), 77 )

cIdFirma := fetch_metric("fakt_stampa_liste_id_firma", _curr_user, cIdFirma )
qqTipDok := fetch_metric("fakt_stampa_liste_dokumenti", _curr_user, qqTipDok )
dDatOd := fetch_metric("fakt_stampa_liste_datum_od", _curr_user, dDatOd )
dDatDo := fetch_metric("fakt_stampa_liste_datum_do", _curr_user, dDatDo )
cTabela := fetch_metric("fakt_stampa_liste_tabelarni_pregled", _curr_user, cTabela )
cImeKup := fetch_metric("fakt_stampa_liste_ime_kupca", _curr_user, cImeKup )
qqPartn := fetch_metric("fakt_stampa_liste_partner", _curr_user, qqPartn )
cBrFakDok := fetch_metric("fakt_stampa_liste_broj_dokumenta", _curr_user, cBrFakDok )

cImeKup := padr(cImeKup,20)
qqPartn := padr(qqPartn,20)
qqTipDok := padr(qqTipDok,2)

do while .t.

 if gNW$"DR"
   cIdFirma:=padr(cidfirma,2)
   @ m_x+1,m_y+2 SAY "RJ prazno svi" GET cIdFirma valid {|| empty(cidfirma) .or. cidfirma==gfirma .or. P_RJ(@cIdFirma) }
   read
 else
   @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif

 if !EMPTY(cIdFirma)
    @ m_x+2, m_y + 2 SAY "Tip dokumenta (prazno svi tipovi)" GET qqTipDok pict "@!"
 else
    cIdfirma:=""
    qqtipdok:="  "
 endif

 @ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
 @ m_x+3,col()+1 SAY "do"  get dDatDo
 @ m_x+5,m_y+2 SAY "Ime kupca pocinje sa (prazno svi)"  get cImeKup pict "@!"
 @ m_x+6,m_y+2 SAY "Uslov po sifri kupca (prazno svi)"  get qqPartn pict "@!" ;
    valid {|| aUslSK:=Parsiraj(@qqPartn,"IDPARTNER","C",NIL,F_PARTN), .t.}
 @ m_x+7,m_y+2 SAY "Broj dokumenta (prazno svi)"  get cBrFakDok pict "@!"
 @ m_x+9,m_y+2 SAY "Tabelarni pregled"  get cTabela valid cTabela $ "DN" pict "@!"
 cRTarifa:="N"
 @ m_x+11,m_y+2 SAY "Rekapitulacija po tarifama ?"  get cRTarifa valid cRtarifa $"DN" pict "@!"
 IF _vrste_pl
   @ m_x+12,m_y+2 SAY "----------------------------------------"
   @ m_x+13,m_y+2 SAY "Za fakture (Tip dok.10):"
   @ m_x+14,m_y+2 SAY "Nacin placanja:" GET qqVrsteP
   @ m_x+15,m_y+2 SAY "Datum valutiranja od" GET dDatVal0
   @ m_x+15,col()+2 SAY "do" GET dDatVal1
   @ m_x+16,m_y+2 SAY "----------------------------------------"
 ENDIF
 @ m_x+17,m_y+2 SAY "Opcina (prazno-sve): "  get cOpcina
 if glRadNal
   @ m_x + 18, m_y + 2 SAY "Radni nalog (prazno-svi): "  get cRadniNalog valid EMPTY(cRadniNalog) .or. P_RNal(@cRadniNalog)
 endif
 
 read

 ESC_BCR

 aUslBFD := Parsiraj(cBrFakDok,"BRDOK","C")
 aUslSK := Parsiraj(qqPartn,"IDPARTNER","C")
 aUslVrsteP := Parsiraj(qqVrsteP,"IDVRSTEP","C")
 aUslOpc := Parsiraj(cOpcina,"IDOPS","C")
 if glRadNal
    //aUslRadNal:=
 endif
 if (!lOpcine .or. aUslOpc <> NIL) .and. aUslBFD<>NIL .and. aUslSK<>NIL .and. ( !_vrste_pl .or. aUslVrsteP <> NIL )
    exit
 endif
enddo

qqTipDok := trim(qqTipDok)
qqPartn := trim(qqPartn)

set_metric("fakt_stampa_liste_id_firma", f18_user(), cIdFirma )
set_metric("fakt_stampa_liste_dokumenti", f18_user(), qqTipDok )
set_metric("fakt_stampa_liste_datum_od", f18_user(), dDatOd )
set_metric("fakt_stampa_liste_datum_do", f18_user(), dDatDo )
set_metric("fakt_stampa_liste_tabelarni_pregled", f18_user(), cTabela )
set_metric("fakt_stampa_liste_ime_kupca", f18_user(), cImeKup )
set_metric("fakt_stampa_liste_partner", f18_user(), qqPartn )
set_metric("fakt_stampa_liste_broj_dokumenta", f18_user(), cBrFakDok )

BoxC()

select fakt_doks
set order to tag "1"
go top

Private cFilter:=".t."

IF !EMPTY(dDatVal0) .or. !EMPTY(dDatVal1)
  cFilter+=".and. (!idtipdok='10'.or.datpl>="+cm2str(dDatVal0)+".and. datpl<="+cm2str(dDatVal1)+")"
ENDIF

IF !EMPTY(qqVrsteP)
  cFilter += ".and. (!idtipdok='10'.or."+aUslVrsteP+")"
ENDIF

if !empty(qqTipDok)
   cFilter+=".and. idtipdok=="+cm2str(qqTipDok)
endif
if !empty(dDatOd) .or. !empty(dDatDo)
  cFilter+=".and.  datdok>="+cm2str(dDatOd)+".and. datdok<="+cm2str(dDatDo)
endif

if cTabela == "D"  

  if !empty(cImekup)
    cFilter+=".and. partner="+cm2str(trim(cImeKup))
  endif

  cFilter+=".and. IdFirma="+cm2str(cIdFirma)

  cFilter+=".and. PARTN->("+aUslOpc+")"

endif

// ako je rijec o radnim nalozima postavi filter u tabeli FAKT na polje idrnal
if glRadNal .and. !Empty(cRadniNalog)
    cFilter+=".and. FAKT->idrnal==" + Cm2Str(cRadniNalog)
endif

if !empty(cBrFakDok)
  cFilter+=".and."+aUslBFD
endif

if !empty(qqPartn)
  cFilter+=".and."+aUslSK
endif


if cFilter == ".t..and."
    cFilter := substr(cFilter, 9)
endif

if cFilter==".t."
    set Filter to
else
    set Filter to &cFilter
endif

@ MAXROW() - 4, MAXCOL() - 3 SAY str(rloptlevel(), 2)

qqTipDok := trim(qqTipDok)

seek cIdFirma + qqTipDok

EOF CRET

if cTabela == "D"
  fakt_lista_dokumenata_tabelarni_pregled( _vrste_pl, lOpcine, cFilter )
else
  gaZagFix:={3, 3}
  stampa_liste_dokumenata(dDatOd, dDatDo, qqTipDok, cIdFirma, cRadniNalog, _vrste_pl,  cImeKup, lOpcine, aUslOpc)
endif

close all
return


// ------------------------------------------------------
// vraca osnovicu dokumenta
// ------------------------------------------------------
function _osnovica( cIdTipDok, cPartner, nIznos )
local nRet := 0
local nTArea := SELECT()

if cIdTipDok $ "11#13#23"
    nRet := ( nIznos / 1.17 )
else
    nRet := nIznos
endif

select (nTArea)
return nRet



// -----------------------------------------------------
// vraca pdv dokumenta
// -----------------------------------------------------
function _pdv( cIdTipDok, cPartner, nIznos )
local nRet := 0
local nTArea := SELECT()

if cIdTipDok $ "11#13#23"
    nRet := ( nIznos / 1.17 ) * 0.17
else
    nRet := nIznos * 0.17
endif

select (nTArea)

return nRet


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

if Pitanje(,"Generisati fakturu na osnovu ponude ?", "D") == "N"
    return DE_CONT
endif

select fakt_doks

nTrec := RecNo()

cTipDok := field->idtipdok
cFirma := field->idfirma
cBrFakt := field->brdok
cPart := field->idpartner
dDatFakt := field->datdok
dDatVal := field->datdok
dDatIsp := field->datdok

cNBrFakt := cBrFakt

// uslovi generisanja...
Box(, 7, 55)
    
    @ m_x + 1, m_y + 2 SAY "*** Parametri fakture "  
    
    @ m_x + 3, m_y + 2 SAY "  Datum fakture: " GET dDatFakt VALID !EMPTY(dDatFakt) 
    
    @ m_x + 4, m_y + 2 SAY "   Datum valute: " GET dDatVal VALID !EMPTY(dDatVal) 
    @ m_x + 5, m_y + 2 SAY " Datum isporuke: " GET dDatIsp VALID !EMPTY(dDatIsp) 
    

    @ m_x + 7, m_y + 2 SAY "   Broj fakture: " GET cBrFakt VALID !EMPTY(cBrFakt)

    read

BoxC()

// postavi filter 
set filter to
go top
seek cFirma + "10" + cBrFakt

if FOUND()
    
    msgbeep("dokument vec postoji !!!!")
    
    if pitanje(, "Naci sljedeci broj dokumenta ?", "D") == "N"
        return DE_CONT
    endif

    cNBrFakt := fakt_novi_broj_dokumenta( cFirma, "10" ) 
    
endif

//
// prvo prekopiraj doks podatke
// 
select fakt_doks
go top
seek cFirma + cTipDok + cBrFakt

_rec := dbf_get_rec()

append blank

// tip dokumneta treba da bude 10 jer se radi o fakturi
_rec["idtipdok"] := "10"
_rec["brdok"] := cNBrFakt
_rec["datdok"] := dDatFakt

// update podataka na server
update_rec_server_and_dbf( ALIAS(), _rec )


// 
// sada odradi istu stvar za stavke fakture iz tabele fakt
//

O_FAKT
select fakt
set order to tag "1"
go top
seek cFirma + cTipDok + cBrFakt

do while !EOF() .and. field->idfirma + field->idtipdok + field->brdok == cFirma + cTipDok + cBrFakt

    ++ nCnt
    
    nFRec := RECNO()

    _rec := dbf_get_rec()

    aMemo := ParsMemo( _rec["txt"] )

    append blank
    
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
    
    // upisi podatke u db
    update_rec_server_and_dbf( ALIAS(), _rec )

    go ( nFRec )
    
    skip

enddo


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
            update_rec_server_and_dbf( ALIAS(), _rec )
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
   
msgbeep("Formiran dokument 10-" + cNBrFakt )

return DE_REFRESH





function pr_choice()
*{
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



// ----------------------------------------------------------------
// vraca vezu dokumenta
// ----------------------------------------------------------------
function g_d_veza( cIdFirma, cTipDok, cBrDok, cDok_veza, cTxt )
local _open_fakt := .f.
local cVeza := ""
local lDok_veza := .f.

PushWa()

if cTxt == nil
    cTxt := ""
endif

if fakt_doks->(FIELDPOS("DOK_VEZA")) <> 0
    lDok_veza := .t.
endif

if lDok_veza .and. !EMPTY( cDok_veza )
    // uzmi iz polja dok_veza
    cVeza := ALLTRIM( cDok_veza )
else
    
    if EMPTY( cTxt )
        // uzmi iz fakt->memo polja broj veze
        SELECT F_FAKT
        if !USED()
                _open_fakt := .t.
                O_FAKT
        endif
        SEEK cIdFirma + cTipDok + cBrDok
        cTxt := field->txt

        if _open_fakt 
               USE
        endif

    endif

    aTemp := ParsMemo( cTxt )
    if LEN( aTemp ) >= 19
        cVeza := ALLTRIM( aTemp[19] )
    else
        cVeza := ""
    endif
endif

PopWa()
return cVeza

// ----------------------------------------------------
// prikazuje brojeve veze
// ----------------------------------------------------
static function box_d_veza()
local cTmp := ""
local cPom
local aTmp := {}
local i
local nSelected
private GetList := {}
private Opc:={}
private opcexe:={}
private Izbor

cTmp := g_d_veza( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, ;
    doks->dok_veza )

if EMPTY( cTmp )
    msgbeep("Nema definisanih veznih dokumenata !")
    return
endif

// zamjeni karaktere ako su drugacije definisani
cTmp := STRTRAN( cTmp, ";", "," )

// dodaj u matricu vezne brojeve
aTmp := TokToNiz( cTmp, "," )

for i:=1 to LEN( aTmp )

    cPom := PADR( aTmp[ i ], 10 )
    
    AADD(opc, cPom )
    AADD(opcexe, {|| nSelected := Izbor, Izbor := 0  } )
next

Izbor := 1
// 0 - ako se kaze <ESC>
Menu_SC("o_dvz")

if LastKey() == K_ESC
    nSelected := 0
    Izbor := 0
endif

return nSelected


// -------------------------------------------------
// prikazuje broj fiskalnog racuna
// -------------------------------------------------
static function _veza_fc_rn()
local _fisc_rn
local _rekl_rn
local _total
local _txt := ""

if fakt_doks->(FIELDPOS("FISC_RN")) = 0
    return
endif

_fisc_rn := ALLTRIM( STR( fakt_doks->fisc_rn ) )
_rekl_rn := ALLTRIM( STR( fakt_doks->fisc_st ) )
_total := fakt_doks->iznos

// samo za izlazne dokumente
if fakt_doks->idtipdok $ "10#11"
    
    if _fisc_rn == "0" .or. ( _fisc_rn <> "0" .and. _rekl_rn == "0" .and. _total < 0 )

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
function fakt_tabela_komande(lOpcine, fakt_doks_filt)
local nRet:=DE_CONT
local _rec
local _filter

_filter := fakt_doks_filt


cFilter := DBFilter()

if gFC_use == "D"
    // ispis informacije o fiskalnom racunu
    _veza_fc_rn()
endif

do case
 
  case Ch==K_ENTER 
     refresh_fakt_tbl_dbfs(_filter)
     nRet := pr_pf(lOpcine)

  case Ch==K_ALT_P
     // print odt
     refresh_fakt_tbl_dbfs(_filter)
     nRet := pr_odt(lOpcine)

  case Ch == K_F5

    refresh_fakt_tbl_dbfs(_filter)
    // zatvori tabelu, pa otvori  
    select fakt_doks
    use

    O_FAKT_DOKS
    set filter to &cFilter
    go top

    // refresh tabele
    nRet := DE_REFRESH

  case CH == K_CTRL_V
    
    refresh_fakt_tbl_dbfs(_filter)
    // setovanje broj fiskalnog isjecka
    select fakt_doks
    
    if field->fisc_rn <> 0
        msgbeep("veza: fiskalni racun vec setovana !")
        if Pitanje(,"Promjeniti postojecu vezu (D/N)?", "N") == "N"
            return DE_REFRESH
        endif
    endif
    
    if Pitanje(,"Setovati novu vezu sa fiskalnim racunom (D/N)?") == "N"
        return DE_REFRESH
    endif
    
    nFiscal := field->fisc_rn
    nRekl := field->fisc_st

    Box(, 2, 40)
        @ m_x + 1, m_y + 2 SAY "fiskalni racun:" GET nFiscal ;
            PICT "9999999999"
        @ m_x + 2, m_y + 2 SAY "reklamni racun:" GET nRekl ;
            PICT "9999999999"
        read
    BoxC()
    
    if nFiscal <> field->fisc_rn .or. nRekl <> field->fisc_st
        _rec := dbf_get_rec()
        _rec["fisc_rn"] := nFiscal
        _rec["fisc_st"] := nRekl
        update_rec_server_and_dbf( ALIAS(), _rec )
        return DE_REFRESH
    endif
  
  case chr(Ch) $ "iI"
    
    refresh_fakt_tbl_dbfs(_filter)
    // info dokument
    msgbeep( getfullusername( field->oper_id ) )
    return DE_REFRESH


  case chr(Ch) $ "kK"
    
    refresh_fakt_tbl_dbfs(_filter)
    // korekcija podataka na dokumentu
    if fakt_edit_data( field->idfirma, field->idtipdok, field->brdok ) = .t.
        return DE_REFRESH
    endif

  case chr(Ch) $ "rR"


    refresh_fakt_tbl_dbfs(_filter)
    select fakt_doks

    // stampa fiskalnog racuna
    if field->idtipdok $ "10#11"
        
        if field->fisc_rn > 0
            
            msgbeep("Fiskalni racun vec stampan za ovaj dokument !!!#Ako je potrebna ponovna stampa resetujte broj veze.")
            
            return DE_REFRESH
        
        endif
        
        if Pitanje(,"Stampati fiskalni racun ?", "D") == "D"

            fakt_fisc_rn( field->idfirma, field->idtipdok, field->brdok )
        
            select fakt_doks
            set filter to &cFilter
            
            return DE_REFRESH

        endif

    endif

  case chr(Ch) $ "sS"

     refresh_fakt_tbl_dbfs(_filter)
     // generisi storno dokument
     storno_dok( field->idfirma, field->idtipdok, field->brdok )
     
     if Pitanje(,"Preci u tabelu pripreme ?","D")=="D"
          fUPripremu:=.t.
          nRet:=DE_ABORT
     else
          nRet := DE_REFRESH
     endif
  
  case UPPER(chr(Ch)) == "V"
    
    refresh_fakt_tbl_dbfs(_filter)
    box_d_veza()

    return DE_REFRESH

  case UPPER(chr(Ch)) == "B"
     refresh_fakt_tbl_dbfs(_filter)
     nRet:=pr_rn()  
     
  case chr(Ch) $ "nN"
     refresh_fakt_tbl_dbfs(_filter)
     nRet:=pr_nar(lOpcine)
  
  case chr(Ch) $ "fF"
     refresh_fakt_tbl_dbfs(_filter)
     if idtipdok $ "20"
       nRet:=generisi_fakturu(lOpcine)
     endif
     
  case chr(Ch) $ "vV"

     refresh_fakt_tbl_dbfs(_filter)
     // ispravka valutiranja     
     if ( PADR(dindem, 3) <> PADR(ValDomaca(), 3) ) 
       
       if !SigmaSif("PRVAL")
            MsgBeep("!!! Opcija nedostupna !!!")
            return DE_REFRESH
       endif
      
       if Pitanje(,"Izvrsiti ispravku valutiranja na dokumentu (D/N)?","N") == "N"
          return DE_REFRESH
       endif
       
       O_FAKT 
       seek  fakt_doks->idfirma + fakt_doks->idtipdok + fakt_doks->brdok
       
       nPom1 := 0
       nPom2 := 0
       nPom3 := 0
       nDugD := 0
       nRabD := 0
       
       do while !EOF() .and. fakt->(idfirma+idtipdok+brdok)==fakt_doks->(idfirma+idtipdok+brdok)
         
            nPrCij := fakt->cijena
            
            v_pretvori("D", fakt->DinDem, fakt->DatDok, @nPrCij ) 
            
            replace cijena with nPrCij 
                
            nPom1 := round( kolicina*Cijena*PrerCij() / UBaznuValutu(datdok) * (1-Rabat/100), ZAOKRUZENJE)
            nPom2 := ROUND( kolicina*Cijena*PrerCij()/UBaznuValutu(datdok)*Rabat/100 , ZAOKRUZENJE)
            nPom3 := ROUND( nPom1 * Porez/100, ZAOKRUZENJE)
            nDugD += nPom1 + nPom3
            nRabD += nPom2 
            
            skip
            
      enddo
       
       select fakt_doks
       
       replace iznos with nDugD
       replace rabat with nRabD
      
       nRet := DE_REFRESH
     
     else
       
       MsgBeep("Opcija onemogucena !!! faktura je u domacoj valuti " + ValDomaca() )
       select fakt_doks
       nRet := DE_REFRESH
     
     endif
  
  case chr(Ch) $ "pP"
     
     refresh_fakt_tbl_dbfs(_filter)
     if !(ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
         msgbeep( cZabrana )
         nRet := DE_REFRESH
         return nRet
     endif
     
     select fakt_doks
     nTrec:=recno()
     _cIdFirma:=idfirma
     _cIdTipDok:=idtipdok
     _cBrDok:=brdok
     close all
     nR_tmp := Povrat_fakt_dokumenta(.f., _cidfirma, _cIdTipdok, _cbrdok)
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
     if nR_tmp <> 0 .and. Pitanje(,"Preci u tabelu pripreme ?","D")=="D"
      fUPripremu:=.t.
        nRet:=DE_ABORT
     else
        nRet:=DE_REFRESH
     endif

/*
  case chr(Ch) $ "qQ"

     select fakt_doks
     nTrec      := recno()
     _cIdFirma  := idfirma
     _cIdTipDok := idtipdok
     _cBrDok    := brdok
     close all
     if _cidtipdok$"20#27"
       nR_tmp := Povrat_fakt_dokumenta(.t.,_cidfirma,_cIdTipdok,_cbrdok)
     elseif _cidtipdok $ "01#19"
       O_FAKT_DOKS
       seek _cidfirma+_cidtipdok+_cbrdok
       if rezerv="*"
         cZnak:=""
       else
         cZnak:="*"
       endif
       do while !eof() .and. idfirma+idtipdok+brdok==_cidfirma+_cidtipdok+_cbrdok
          replace rezerv with cZnak
          skip
       enddo
       O_FAKT
       seek  _cidfirma+_cidtipdok+_cbrdok
       do while !eof() .and. idfirma+idtipdok+brdok==_cidfirma+_cidtipdok+_cbrdok
          replace serbr with cznak
          skip
       enddo
       close all
     endif
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
     nRet:=DE_REFRESH

*/

endcase
return nRet


// --------------------------------     
function refresh_fakt_tbl_dbfs(filter)

PushWa()
close all


O_VRSTEP

O_OPS

if glRadNal
    O_RNAL
endif

O_FAKT
O_PARTN
O_FAKT_DOKS

select fakt_doks
set order to tag "1"
go top

SET FILTER TO &filter

SET RELATION TO idvrstep INTO VRSTEP

SET RELATION TO idpartner INTO PARTN

if glRadNal
    SET RELATION TO idfirma + idtipdok + brdok INTO FAKT
endif

O_FAKT_DOKS2
O_VALUTE
O_RJ

PopWa()

return .t.


/*! \fn fakt_vt_porezi()
 *  \brief Smjesta poreze iz tarifa u javne varijable
 */

function fakt_vt_porezi()
*{
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
*}


/*! \fn fakt_real_partnera()
 *  \brief Realizacija po partnerima
 *  \todo Prebaciti u /RPT
 */

function fakt_real_partnera()
*{
O_FAKT_DOKS
O_PARTN
O_VALUTE
O_RJ

cIdfirma:=gFirma
dDatOd:=ctod("")
dDatDo:=date()
qqTipDok:="10;"
Box(,11,77)

O_PARAMS
private cSection:="N",cHistory:=" "; aHistory:={}
//Params1()
RPar("c1",@cIdFirma)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
cTabela:="N"
cBrFakDok:=SPACE(40)
cImeKup:=space(20)
qqPartn:=space(20)
qqOpc:=space(20)
RPar("TA",@cTabela)
RPar("KU",@cImeKup)
RPar("sk",@qqPartn)
RPar("BD",@cBrFakDok)
qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,40)
qqOpc:=padr(qqOpc,20)

do while .t.
    cIdFirma:=padr(cidfirma,2)
    @ m_x+1,m_y+2 SAY "RJ            " GET cIdFirma valid {|| empty(cidfirma) .or. cidfirma==gfirma .or. P_RJ(@cIdFirma) }
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

Params2()
WPar("c1",cIdFirma)
WPar("d1",dDatOd)
WPar("d2",dDatDo)
WPar("TA",cTabela)
WPar("sk",qqPartn)
WPar("BD",cBrFakDok)
select params
use

BoxC()

select fakt_doks

Private cFilter:=".t."

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
    ?? Str(++nC,4)+".", cIdPartner, partn->naz
    nCol1:=pcol()+1
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

