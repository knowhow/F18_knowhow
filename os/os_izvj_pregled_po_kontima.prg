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


// -------------------------------------------
// pregled sredstava po kontima
// -------------------------------------------
function os_pregled_po_kontima()
local _sr_id, _sr_id_rj, _sr_id_am, _sr_dat_otp, _sr_datum
local cIdKonto:=SPACE(7)
local qIdKonto:=SPACE(7)
local cIdSk:=""
local nDug:=0
local nDug2:=0
local nPot:=0
local nPot2:=0
local nDug3:=0
local nPot3:=0
local nCol1:=10
local nKontoLen:=3
local _mod_name := "OS"

if gOsSii == "S"
    _mod_name := "SII"
endif

O_KONTO
O_RJ

o_os_sii_promj()
o_os_sii()

cIdrj := SPACE(4)
cAmoGr:="N"
cON:="N"
cPromj:="2"
cDodaj:="1"
cPocinju:="N"
dDatOd:=ctod("")
dDatDo:=date()
cDatper:="N"
cIzbUbac:="I"
cFiltSadVr:="0"
cFiltK1:=SPACE(40)
cFiltK3:=SPACE(40)
cRekapKonta:="N"

Box(,20,77)
  DO WHILE .t.
    @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno - svi):" GET cidrj ;
        VALID {|| EMPTY(cIdRj) .or. P_RJ( @cIdrj ), if( !EMPTY(cIdRj), cIdRj := PADR( cIdRj, 4 ), .t. ), .t. }
    @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
    @ m_x+2,m_y+2 SAY "Konto (prazno - svi):" get qIdKonto pict "@!" valid empty(qidkonto) .or. P_Konto(@qIdKonto)
    @ m_x+2,col()+2 SAY "grupisati konto na broj mjesta" get nKontoLen pict "9" valid (nKontoLen > 0 .and. nKontoLen < 8)
    @ m_x+3,m_y+2 SAY "Prikaz svih os ( )      /   neotpisanih (N)     / otpisanih   (O) "
    @ m_x+4,m_y+2 SAY "/novonabavljenih   (B) / iz proteklih godina (G)" get cON valid con $ "ONBG " pict "@!"
    @ m_x+5,m_y+2 SAY "Za sredstvo prikazati vrijednost:"
    @ m_x+6,m_y+2 SAY "1 - bez promjena"
    @ m_x+7,m_y+2 SAY "2 - osnovni iznos + promjene"
    @ m_x+8,m_y+2 SAY "3 - samo promjene           " GET cPromj valid cpromj $ "123"
    @ m_x+10, m_y+2 SAY "1 - prikaz bez uracunate amortizacije i revalor:"
    @ m_x+11,m_y+2 SAY "2 - sa uracunatom amortizacijom i revalor      :"
    @ m_x+12,m_y+2 SAY "3 - samo amortizacije                          :"
    @ m_x+13,m_y+2 SAY "4 - samo revalorizacije                        :"  GET cDodaj valid cDodaj $ "1234"
    @ m_x+14, m_y+2 SAY "Prikazi samo rekapitulaciju konta (D/N)" GET cRekapKonta VALID cRekapKonta$"DN" PICT "@!"
    @ m_x+15,m_y+2 SAY "Pregled za datumski period :" GET cDatPer valid cdatper $ "DN" pict "@!"
    @ m_x+16,m_y+2 SAY "Filter po sadasnjoj vr.(0-sve,1-samo koja je imaju,2-samo koja je nemaju):" GET cFiltSadVr valid cFiltSadVr $ "012" pict "9"
    @ m_x+17,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
    @ m_x+18,m_y+2 SAY "Filter po K3:" GET cFiltK3 pict "@!S10"
    @ m_x+18,m_y+30 SAY "Izbaciti(I) / Ubaciti(U)" GET cIzbUbac PICT "@!" VALID cIzbUbac $ "IU"
    @ m_x+19,m_y+2 SAY "Prikazati kolonu 'amort.grupa'? D/N" get cAmoGr valid cAmoGr $ "DN" pict "@!"
    read
    ESC_BCR
    if cDatPer=="D"
            @ m_x+20,m_y+2 SAY "Od datuma " GET dDatOd
            @ m_x+20,col()+2 Say "do" GET dDatDo
            read
        ESC_BCR
    endif
    aUsl1:=Parsiraj(cFiltK1, "K1")
    aUsl2:=Parsiraj(cFiltK3, "K3")
    if cIzbUbac=="I"
        aUsl2:=StrTran(aUsl2, "=", "<>")
    endif
    if aUsl1<>NIL
        exit
    endif
    if aUsl2<>NIL
        exit
    endif
  ENDDO
BoxC()

// rj na 4 mjesta
cIdRj := PADR( cIdRj, 4 )

if cDatPer == "D"
    select_promj()
    PRIVATE cFilt1 := "DATUM>="+cm2str(dDatOd)+".and.DATUM<="+cm2str(dDatDo)
    set filter to &cFilt1
    select_os_sii()
endif

if !EMPTY(cFiltK1)
    select_os_sii()
    set filter to &aUsl1
endif

if !EMPTY(cFiltK3)
    select_os_sii()
    set filter to &aUsl2
endif

if empty(qIdKonto)
    qIdKonto:=""
endif
if empty(cIdrj)
    cIdRj:=""
endif
if cPocinju=="D"
    cIdRj:=TRIM(cIdRj)
endif

os_rpt_default_valute()

START PRINT CRET

private nStr:=0  
// strana

select rj
hseek cIdRj

select_os_sii()

P_10CPI
? gTS + ":", gnFirma

if !empty(cIdrj)
    ? "Radna jedinica:", cIdRj, rj->naz
endif

P_COND

? _mod_name + ": Pregled sredstava po kontima "

if cDodaj=="1"
    ?? "(BEZ uracunate Am. i Rev.)"
elseif cdodaj=="2"
    ?? "(SA uracunatom Am. i Rev)"
elseif cdodaj=="3"
    ?? "(samo efekata amortizacije)"
elseif cdodaj=="4"
    ?? "(samo efekata revalorizacije)"
endif

?? "", PrikazVal(), "    Datum:", gDatObr

if !EMPTY(cFiltK1)
    ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"
endif
if !EMPTY(cFiltK3)
    ? "Filter grupacija K3 pravljen po uslovu: '"+TRIM(cFiltK3)+"'"
    if cIzbUbac=="U"
        ?? " sve sto sadrzi."
    else
        ?? " sve sto ne sadrzi."
    endif
endif


private m:="----- ---------- ----"+IF(cAmoGr=="D"," "+REPL("-",LEN(field->idam)),"")+" -------- ------------------------------ --- ------"+REPL(" "+REPL("-",LEN(gPicI)),3)

if EMPTY( cIdrj )
    select_os_sii()
    set order to tag "4" 
    // "idkonto+idrj+id"
    seek qIdKonto
else
    select_os_sii()
    set order to tag "3" 
    // "idrj+idkonto+id"
    seek cIdRj+qIdKonto
endif

private nRbr:=0

nDug:=0
nPot:=0

os_zagl_konta()

n1:=0
n2:=0
nUUUKol:=0

do while !eof() .and. (idrj=cIdRj .or. Empty(cIdRj))

    cIdSK := LEFT(idkonto, nKontoLen)
    cNazSKonto := ""
    
    select konto
    hseek cIdSK
   
    if FOUND()
        cNazSKonto := ALLTRIM(konto->naz)
    endif
   
    select_os_sii()

    nDug2:=nPot2:=0
    nUUKol:=0

    do while !eof() .and. (idrj=cIdRj .or. Empty(cIdRj)) .and. LEFT(idkonto, nKontoLen)==cIdSK

        cIdKonto:=idkonto
        cNazKonto := ""

        select konto
        hseek cIdKonto

        if FOUND()
            cNazKonto := ALLTRIM(konto->naz)
        endif
      
        select_os_sii()
        nDug3:=nPot3:=nUKol:=0

        do while !eof() .and. (idrj=cidrj .or. empty(cidrj))  .and. idkonto==cidkonto

            if datum>gDatObr 
                // preskoci sredstva van obracuna
                skip
                loop
            endif

            if prow() > RPT_PAGE_LEN 
                FF
                os_zagl_konta()
            endif

            if (cON=="N" .and. empty(datotp)) .or. ;
                (con=="O"  .and. !empty(datotp)) .or. ;
                (con=="B"  .and. year(datum)=year(gdatobr)) .or.;
                (con=="G"  .and. year(datum)<year(gdatobr)) .or.;
                empty(con)

                fIma:=.t.

                if cDatPer=="D"

                    if datum>=dDatOd .and. datum<=dDatDo
                        fIma:=.t.
                    else
                        fIma:=.f.
                    endif

                    _sr_id := field->id
                    select_promj()  
                    // provjeri promjene unutar datuma
                    hseek _sr_id

                    do while !eof() .and. _sr_id = field->id
                        if datum>=dDatOd .and. datum<=dDatDo
                            fIma:=.t.
                        endif
                        skip
                    enddo
                    select_os_sii()
                endif

                if cpromj=="3"  
                    // ako zelim samo promjene vidi ima li za sr.
                    // uopste promjena
                    _sr_id := field->id
                    _sr_dat_otp := field->datotp
                    _sr_datum := field->datum

                    select_promj()
                    hseek _sr_id
                    fIma:=.f.
                    do while !eof() .and. field->id == _sr_id .and. field->datum <= gDatObr
                        if (cON=="N" .and. empty( _sr_dat_otp )) .or. ;
                            (con="O"  .and. !empty( _sr_dat_otp )) .or. ;
                            (con=="B"  .and. year( _sr_datum ) = year(gdatobr)) .or. ;
                            (con=="G"  .and. year( field->datum ) < year(gdatobr)) .or.;
                            empty(cON)
                            fIma:=.t.
                        endif
                        skip
                    enddo
                    select_os_sii()
                endif

                // ovaj dio nam sad sluzi samo da saznamo ima li sredstvo
                // sadasnju vrijednost
                // ------------------------------------------------------
                lImaSadVr:=.f.

                if cPromj <> "3"
                    if cDatPer="N"  .or. (cDatPer="D" .and. field->datum >= dDatOd .and. field->datum <= dDatDo)
                        if cDodaj=="1"
                            n1:=nabvr
                            n2:=otpvr
                        elseif cDodaj=="2"
                            n1:=nabvr+revd
                            n2:=otpvr+amp+revp
                        elseif cDodaj=="3"
                            n1:=0
                            n2:=amp
                        elseif cDodaj=="4"
                            n1:=revd
                            n2:=revp
                        endif
                        if n1-n2 > 0
                            lImaSadVr:=.t.
                        endif
                    endif 
                    // prikaz za datumski period, a OS ne pripada tom periodu
                endif
                
                if cPromj $ "23"  

                    // prikaz promjena
                    _sr_id := field->id
                    _sr_dat_otp := field->datotp
                    _sr_datum := field->datum

                    select_promj()
                    hseek _sr_id
                    do while !eof() .and. field->id == _sr_id .and. field->datum <= gDatObr
                        if (cON=="N" .and. empty( _sr_dat_otp )) .or. ;
                            (con="O"  .and. !empty( _sr_dat_otp )) .or.;
                            (con=="B"  .and. year( _sr_datum ) = year(gdatobr)) .or. ;
                            (con=="G"  .and. year( field->datum )<year(gdatobr)) .or.;
                            empty(con)
                            if cDodaj=="1"
                                n1:=nabvr
                                n2:=otpvr
                            elseif cDodaj=="2"
                                n1:=nabvr+revd
                                n2:=otpvr+amp+revp
                            elseif cDodaj=="3"
                                n1:=0
                                n2:=amp
                            elseif cDodaj=="4"
                                n1:=revd
                                n2:=revp
                            endif
                            if n1-n2 > 0
                                lImaSadVr:=.t.
                            endif
                        endif
                        skip
                    enddo
                    select_os_sii()
                endif

                // ispis stavki
                // ------------
                if cFiltSadVr=="1" .and. !(lImaSadVr) .or. cFiltSadVr=="2" .and. lImaSadVr
                    skip
                    loop
                else

                    if fIma
                        if cRekapKonta=="N"
                            ? str(++nrbr,4)+".",id,idrj
                        endif
                        IF cRekapKonta=="N" .and. cAmoGr=="D"
                            ?? "",idam
                        ENDIF
                        if cRekapKonta=="N"
                            ?? "",datum,naz,jmj,str(kolicina,6,1)
                        endif
                        nCol1:=pcol()+1
                    endif

                    if cPromj <> "3"
                        if cDatPer="N"  .or. (cDatPer="D" .and. datum>=dDatOd .and. datum<=dDatDo)
                            if cdodaj=="1"
                                n1:=nabvr
                                n2:=otpvr
                            elseif cdodaj=="2"
                                n1:=nabvr+revd
                                n2:=otpvr+amp+revp
                            elseif cdodaj=="3"
                                n1:=0
                                n2:=amp
                            elseif cdodaj=="4"
                                n1:=revd
                                n2:=revp
                            endif
                            if cRekapKonta=="N"
                                @ prow(),pcol()+1 SAY n1*nBBK pict gpici
                                @ prow(),pcol()+1 SAY n2*nBBK pict gpici
                                @ prow(),pcol()+1 SAY n1*nBBK-n2*nBBK pict gpici
                            endif
                            nDug3+=n1
                            nPot3+=n2
                            nUKol+=kolicina
                        endif 
                        // prikaz za datumski period, a OS ne pripada tom periodu
                    endif

                    if cPromj $ "23" 

                        // prikaz promjena
                        _sr_id := field->id
                        _sr_dat_otp := field->datotp
                        _sr_datum := field->datum
                        _sr_id_rj := field->idrj
                        _sr_id_am := field->idam

                        select_promj()
                        hseek _sr_id

                        do while !eof() .and. field->id == _sr_id .and. field->datum <= gDatObr
                            if (cON=="N" .and. empty( _sr_dat_otp )) .or. ;
                                (con="O"  .and. !empty( _sr_dat_otp )) .or.;
                                (con=="B"  .and. year( _sr_datum ) = year(gdatobr)) .or. ;
                                (con=="G"  .and. year( field->datum ) < year(gdatobr)) .or.;
                                empty(con)
                                if cRekapKonta=="N"
                                    ? space(5), space(len( _sr_id )), space(len( _sr_id_rj ))
                                endif
                                IF cRekapKonta=="N" .and. cAmoGr=="D"
                                    ?? "",SPACE(LEN( _sr_id_am ))
                                ENDIF
                                if cRekapKonta=="N"
                                    ?? "",datum,opis
                                endif
                                if cdodaj=="1"
                                    n1:=nabvr
                                    n2:=otpvr
                                elseif cdodaj=="2"
                                    n1:=nabvr+revd
                                    n2:=otpvr+amp+revp
                                elseif cdodaj=="3"
                                    n1:=0
                                    n2:=amp
                                elseif cdodaj=="4"
                                    n1:=revd
                                    n2:=revp
                                endif

                                if cRekapKonta=="N"
                                    @ prow(),nCol1  SAY n1*nBBK  pict gpici
                                    @ prow(),pcol()+1 SAY n2*nBBK  pict gpici
                                    @ prow(),pcol()+1 SAY n1*nBBK-n2*nBBK  pict gpici
                                endif
                                nDug3+=n1
                                nPot3+=n2

                            endif
                            skip

                        enddo
                        select_os_sii()

                    endif

                endif

            endif
            skip
        enddo
        
        if prow() > RPT_PAGE_LEN
            FF
            os_zagl_konta()
        endif
        
        if cRekapKonta=="N"
            ? m
        endif
      
        ? " ukupno ",cIdKonto, PADR( cNazKonto, 40 )
        if cRekapKonta=="D"
            nUUkol+=nUKol
            ?? " "
            @ prow(),pcol()+1 SAY nUKol
            @ prow(),pcol()+1 SAY nDug3*nBBK pict gpici
        else
            @ prow(),nCol1 SAY nDug3*nBBK pict gpici
        endif
        @ prow(),pcol()+1 SAY npot3*nBBK pict gpici
        @ prow(),pcol()+1 SAY ndug3*nBBK-npot3*nBBK pict gpici
        if cRekapKonta=="N"
            ? m
        endif
        nDug2+=nDug3
        nPot2+=nPot3
        if !empty(qidkonto)
            exit
        endif
    
    enddo
    
    if !empty(qidkonto)
        exit
    endif
    
    if prow() > RPT_PAGE_LEN
        FF
        os_zagl_konta()
    endif
    
    ? m
    ? " UKUPNO ", cIdSk, PADR( cNazSKonto, 40 )
    
    if cRekapKonta=="D"
        ?? SPACE(5)
        @ prow(),pcol()+1 SAY nUUKol
        @ prow(),pcol()+1 SAY nDug2*nBBK pict gpici
    else
        @ prow(),nCol1 SAY nDug2*nBBK pict gpici
    endif
     
    @ prow(),pcol()+1 SAY npot2*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug2*nBBK-npot2*nBBK pict gpici
    nUUUKol+=nUUKol
    ? m
    nDug+=nDug2
    nPot+=nPot2
enddo

if empty(qidkonto)

    if prow() > RPT_PAGE_LEN
        FF
        os_zagl_konta()
    endif
    ?
    ? m
    ? " U K U P N O :"
    if cRekapKonta=="D"
        ?? SPACE(44)
        @ prow(),pcol()+1 SAY nUUUKol
        @ prow(),pcol()+1 SAY nDug*nBBK pict gpici
    else
        @ prow(),nCol1 SAY nDug*nBBK pict gpici
    endif
    @ prow(),pcol()+1 SAY npot*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug*nBBK-npot*nBBK pict gpici
    ? m
endif

FF

end print

my_close_all_dbf()
return


// -------------------------------------
// zaglavlje izvjestaja
// -------------------------------------
function os_zagl_konta()
local _t_area := SELECT()

select_os_sii()

?
P_12CPI
if con="N"
    ? "PRIKAZ NEOTPISANIH SREDSTAVA:"
elseif con=="B"
    ? "PRIKAZ NOVONABAVLJENIH SREDSTAVA:"
elseif con=="G"
    ? "PRIKAZ SREDSTAVA IZ PROTEKLIH GODINA:"
elseif con=="O"
    ? "PRIKAZ OTPISANIH SREDSTAVA:"
elseif   con==" "
    ? "PRIKAZ SVIH SREDSTAVA:"
endif

P_COND

@ prow(),125 SAY "Str."+str(++nStr,3)

? m
? " Rbr.  Inv.broj   RJ  "+IF(cAmoGr=="D"," "+PADC("Am.grupa",LEN(field->idam)),"")+"  Datum    Sredstvo                     jmj  kol  "+" "+PADC("NabVr",LEN(gPicI))+" "+PADC("OtpVr",LEN(gPicI))+" "+PADC("SadVr",LEN(gPicI))
? m

select ( _t_area )

return

