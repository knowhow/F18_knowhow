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


function os_pregled_po_rj()
local lPartner
local _export_dn := "N"
local _po_amort := "N"
local _export := .f.
local _start_cmd 

O_RJ
o_os_sii()

cIdrj := SPACE( LEN(field->idrj) )

lPartner := os_fld_partn_exist()

cON:="N"
cKolP:="N"
cPocinju:="N"

cBrojSobe:=space(6)
lBrojSobe:=.f.
cFiltK1:=SPACE(40)
cFiltDob:=SPACE(40)
cOpis:="N"

Box(, 12, 77 )
    DO WHILE .t.
        @ m_x + 1, m_y + 2 SAY "Radna jedinica:" GET cIdRj VALID {|| P_RJ( @cIdrj ), if ( !EMPTY(cIdRj), cIdRj := PADR( cIdRj, 4), .t. ), .t. }
        @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
        @ m_x+2,m_y+2 SAY "Prikaz svih neotpisanih (N) / otpisanih(O) /"
        @ m_x+3,m_y+2 SAY "samo novonabavljenih (B)    / iz proteklih godina (G)"   get cON pict "@!" valid con $ "ONBG"
        @ m_x+4,m_y+2 SAY "Prikazati kolicine na popisnoj listi D/N" GET cKolP valid cKolP $ "DN" pict "@!"
        @ m_x+5,m_y+2 SAY "Prikazati kolonu 'opis' ? (D/N)" GET cOpis valid cOpis $ "DN" pict "@!"

        if os_postoji_polje("brsoba")
            lBrojSobe:=.t.
            @ m_x+6,m_y+2 SAY "Broj sobe (prazno sve) " GET cBrojSobe  pict "@!"
        endif

        @ m_x+7,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
        @ m_x+8,m_y+2 SAY "Filter po dobavljacima:" GET cFiltDob pict "@!S20"

        @ m_x + 10, m_y + 2 SAY "Pregled po amortizacionim stopama (D/N) ?" GET _po_amort PICT "@!" VALID _po_amort $ "DN"

        @ m_x + 12, m_y + 2 SAY "Export izvjestaja (D/N) ?" GET _export_dn PICT "@!" VALID _export_dn $ "DN"

        READ
        ESC_BCR

        aUsl1:=Parsiraj(cFiltK1,"K1")
        aUsl2:=Parsiraj(cFiltDob,"idPartner")

        if aUsl1<>nil .and. aUsl2<>nil
            exit
        endif

    ENDDO
BoxC()

cIdRj := PADR( cIdRj, 4 )

if _export_dn == "D"

    _export := .t.
	t_exp_create( _g_exp_flds() )
    
    // otvori ponovo tabele...    
    O_RJ
    o_os_sii()

endif

if lBrojSobe .and. EMPTY( cBrojSobe )
    lBrojSobe := ( Pitanje(,"Zelite li da bude prikazan broj sobe? (D/N)","N") == "D" )
endif

lPoKontima := .f.
lPoAmortStopama := .f.
if _po_amort == "D"
    lPoAmortStopama := .t.
endif

if cPocinju == "D"
    cIdRj := TRIM( cIdrj )
endif

START PRINT CRET

m := "----- ---------- ----------------------------"+IF(cOpis=="D"," "+REPL("-",LEN(field->opis)),"")+"  ---- ------- -------------"

if lPoAmortStopama

    select_os_sii()

    if cIdRj == ""
        set order to tag "5" 
        // idam+idrj+id
    else
        INDEX ON idrj + idam + id TO "TMPOS"
    endif

elseif lBrojSobe .and. EMPTY(cBrojSobe)

    m:="----- ------ ---------- ----------------------------"+IF(cOpis=="D"," "+REPL("-",LEN(field->opis)),"")+"  ---- ------- -------------"

    select_os_sii()
    set order to tag "2" 
    //idrj+id+dtos(datum)
    INDEX ON idrj + brsoba + id + DTOS( datum ) TO "TMPOS"

elseif lPoKontima

    select_os_sii()
    INDEX ON idkonto + id TO "TMPOS"

elseif cIdRj==""

    select_os_sii()
    set order to tag "1" 
    // id+idam+dtos(datum)

else

    select_os_sii()
    set order to tag "2" 
    //idrj+id+dtos(datum)

endif

if !EMPTY(cFiltK1) .or. !EMPTY(cFiltDob)
    cFilter := aUsl1 + ".and." + aUsl2
    select_os_sii()
    set filter to &cFilter
endif

go top
cIdRj := PADR( cIdRj, LEN( field->idrj ) )

ZglPrj()

if !lPoKontima
    seek cIdrj
endif

private nRbr := 0
cLastKonto := ""

do while !eof() .and. ( field->idrj = cIdrj .or. lPoKontima )

    if lPoKontima .and. !( field->idrj = cidrj)
        skip
        loop
    endif

    if (cON="B" .and. year(gdatobr)<>year(field->datum))  
        // nije novonabavljeno
        skip 
        loop                                  
        // prikazi samo novonabavlj.
    endif

    if (cON="G" .and. year(gdatobr)=year(field->datum))  
        // iz protekle godine
        skip
        loop                                   
        // prikazi samo novonabavlj.
    endif

    if (!empty(datotp) .and. year(datotp)<=year(gdatobr)) .and. cON $ "NB"
        // otpisano sredstvo , a zelim prikaz neotpisanih
        skip 
        loop
    endif
    
    if (empty(datotp) .and. year(datotp)<year(gdatobr)) .and. cON=="O"
        // neotpisano, a zelim prikaz otpisanih
        skip 
        loop
    endif

    if !empty(cBrojsobe)
        if cbrojsobe <> field->brsoba
            skip
            loop
        endif
    endif

    if lPoKontima .and. ( nRbr = 0 .or. cLastKonto <> idkonto )  

        // prvo sredstvo,
        // ispisi zaglavlje

        if nrbr>0
            ? m
            ?
        endif

        if prow() > RPT_PAGE_LEN
            FF
            ZglPrj()
        endif

        ?
        ? "KONTO:",idkonto
        ? REPL("-",14)
        nRbr:=0

    endif

    if prow() > RPT_PAGE_LEN
        FF
        ZglPrj()
    endif
 
    if lBrojSobe .and. EMPTY(cBrojSobe)
        ? str(++nRbr,4)+".", field->brsoba, field->id, field->naz
    else
        ? str(++nRbr,4)+".", field->id, field->naz
    endif
 
    IF cOpis=="D"
        ?? "", field->opis
    ENDIF

    ?? "", field->jmj

    if cKolP=="D"
        @  prow(),pcol()+1 SAY field->kolicina pict "9999.99"
    else
        @  prow(),pcol()+1 SAY SPACE(7)
    endif

    cLastKonto := field->idkonto

    @ prow(),pcol()+1 SAY " ____________"
    
    if _export 
        _a_to_exp( ALLTRIM( STR( nRbr, 4 ) ), field->id, field->naz, field->jmj, field->kolicina, field->datum )
    endif

    skip

enddo

? m

if prow() > RPT_PAGE_LEN
    FF
    ZglPrj()
endif

?
? "     Zaduzeno lice:                                     Clanovi komisije:"
?
? "     _______________                                  1.___________________"
?
? "                                                      2.___________________"
?
? "                                                      3.___________________"

FF
END PRINT

if _export
	tbl_export()
endif

my_close_all_dbf()
return



// ---------------------------------------------------
// vraca polja za tabelu exporta...
// ---------------------------------------------------
static function _g_exp_flds()
local _dbf := {}

AADD( _dbf, { "rbr", "C", 4, 0 } )
AADD( _dbf, { "sredstvo", "C", 10, 0 } )
AADD( _dbf, { "naziv", "C", 100, 0 } )
AADD( _dbf, { "jmj", "C", 3, 0 } )
AADD( _dbf, { "datum", "D", 8, 0 } )
AADD( _dbf, { "kolicina", "N", 15, 2 } )

return _dbf


// -------------------------------------------
// dodaj u tabelu export-a
// -------------------------------------------
static function _a_to_exp( r_br, sredstvo, naziv_sredstva, jmj_sredstva, trenutna_kolicina, datum_nabavke )
local _t_area := SELECT()

O_R_EXP
append blank
replace field->rbr with r_br
replace field->sredstvo with sredstvo
replace field->naziv with naziv_sredstva
replace field->jmj with jmj_sredstva
replace field->kolicina with trenutna_kolicina
replace field->datum with datum_nabavke

select ( _t_area )
return



function ZglPrj()
local _mod_name := "OS"
local nArr := SELECT()

if gOsSii == "S"
    _mod_name := "SII"
endif

P_10CPI
?? UPPER(gTS)+":",gNFirma
?
? _mod_name + ": Pregled "

if cON=="N"
   ?? "sredstava u upotrebi"
elseif cON=="B"
   ?? "novonabavljenih sredstava u toku godine"
else
   ?? "sredstava otpisanih u toku godine"
endif

select rj
seek cidrj

select (nArr)

?? "     Datum:", gDatObr

? "Radna jedinica:", cIdrj, rj->naz

if cpocinju=="D"
  ?? space(6),"(SVEUKUPNO)"
endif

if !EMPTY(cFiltK1)
  ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"
endif

if !EMPTY(cFiltDob)
  ? "Filter za dobavljace pravljen po uslovu: '"+TRIM(cFiltDob)+"'"
endif

if !empty(cBrojSobe)
  ?
  ? "Prikaz za sobu br:", cBrojSobe
  ?
endif

IF cOpis=="D"
  P_COND
ENDIF

? m
if lBrojSobe .and. EMPTY(cBrojSobe)
 ? " Rbr. Br.sobe Inv.broj        Sredstvo               "+IF(cOpis=="D",PADC("Opis",1+LEN(field->opis)),"")+" jmj  kol  "
else
 ? " Rbr.  Inv.broj        Sredstvo              "+IF(cOpis=="D",PADC("Opis",1+LEN(field->opis)),"")+"  jmj  kol  "
endif
? m

return


