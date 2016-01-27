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



function os_pregled_amortizacije()
local _sr_id, _sr_id_rj, _sr_id_am, _sr_dat_otp, _sr_datum
local cIdKonto:=qidkonto:=space(7), cidsk:="", ndug:=ndug2:=npot:=npot2:=ndug3:=npot3:=0
local nCol1:=10
local _mod_name := "OS"
local _t_nab, _t_otp, _t_amp
local _sanacija := .f.

if gOsSii == "S"
    _mod_name := "SII"
endif

O_KONTO
O_RJ

o_os_sii_promj()
o_os_sii()

cIdrj:=SPACE(4)
cPromj:="2"
cPocinju:="N"
cKPocinju:="N"
cFiltSadVr:="0"
cFiltK1:=SPACE(40)
cON:=" " // novo!

cBrojSobe:=space(6)
lBrojSobe:=.f.

cPotpis:="N"

Box(,13,77)
 DO WHILE .t.
  @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno - svi):" GET cidrj ;
        VALID {|| EMPTY(cIdRj) .or. P_RJ( @cIdrj ), if( !EMPTY(cIdRj), cIdRj := PADR( cIdRj, 4 ), .t. ), .t. }
 
  @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
  @ m_x+2,m_y+2 SAY "Konto (prazno - svi):" get qIdKonto pict "@!" valid empty(qidkonto) .or. P_Konto(@qIdKonto)
  @ m_x+2,col()+2 SAY "sva koja pocinju " get cKpocinju valid cKpocinju $ "DN" pict "@!"
  @ m_x+4,m_y+2 SAY "Za sredstvo prikazati vrijednost:"
  @ m_x+5,m_y+2 SAY "1 - bez promjena"
  @ m_x+6,m_y+2 SAY "2 - osnovni iznos + promjene"
  @ m_x+7,m_y+2 SAY "3 - samo promjene           " GET cPromj valid cpromj $ "123"
  @ m_x+8,m_y+2 SAY "Filter po sadasnjoj vr.(0-sve,1-samo koja je imaju,2-samo koja je nemaju):" GET cFiltSadVr valid cFiltSadVr $ "012" pict "9"
  @ m_x+9,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  if os_postoji_polje("brsoba")
   lBrojSobe:=.t.
   @ m_x+10,m_y+2 SAY "Broj sobe (prazno sve) " GET cBrojSobe  pict "@!"
  endif
  @ m_x+11,m_y+2 SAY "Prikaz svih os ( )      /   neotpisanih (N)     / otpisanih   (O) "
  @ m_x+12,m_y+2 SAY "/novonabavljenih   (B) / iz proteklih godina (G)" get cON valid con $ "ONBG " pict "@!"
  @ m_x+13,m_y+2 SAY "Prikazati mjesta za potpis na kraju pregleda? (D/N)" get cPotpis valid cPotpis $ "DN" pict "@!"
  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

cIdRj := PADR( cIdRj, 4 )

if empty(qidkonto); qidkonto:=""; endif
IF cKPocinju=="D"
  qIdKonto:=TRIM(qIdKonto)
ENDIF

if empty(cIdrj); cidrj:=""; endif
if cpocinju=="D"
  cIdRj:=trim(cidrj)
endif

os_rpt_default_valute()

START PRINT CRET

private nStr:=0  
// strana

select rj
hseek cIdrj
select_os_sii()

P_10CPI
? gTS + ":", gnFirma

if !empty( cIdrj )
    ? "Radna jedinica:", cIdrj, rj->naz
endif

? _mod_name + ": Pregled obracuna amortizacije po kontima "

?? "", PrikazVal(), "    Datum:", gDatObr

if !EMPTY(cFiltK1)
    ? "Filter grupacija K1 pravljen po uslovu: '" + TRIM(cFiltK1) + "'"
endif

P_COND2

private m:="----- ---------- ---- -------- ------------------------------ --- ------"+REPL(" "+REPL("-",LEN(gPicI)),5)

cFilter:=".t."

if !EMPTY(cFiltK1)
  cFilter += ".and."+aUsl1
endif

if cPocinju=="D" .and. !EMPTY(qIdKonto)
    cFilter += ".and. idkonto=qIdKonto .and. idrj=cIdRj"
endif

if lBrojSobe .and. !EMPTY(cBrojSobe)
    cFilter += ".and. brsoba==cBrojSobe"
endif

IF !cFilter==".t."
    select_os_sii()
    SET FILTER TO &cFilter
ENDIF

if empty(cidrj) .or. cPocinju=="D"
    select_os_sii()
    set order to tag "4" 
    //"OSi4","idkonto+idrj+id"
    seek qidkonto
else
    select_os_sii()
    set order to tag "3" 
    //"OSi3","idrj+idkonto+id"
    seek cidrj+qidkonto
endif

private nRbr := 0

nDug:=nPot1:=nPot2:=0

os_zagl_amort()

n1:=0
n2:=0

do while !eof() .and. ( field->idrj = cIdrj .or. empty(cidrj))

    cIdSK:=left(idkonto,3)
    nDug2:=nPot21:=nPot22:=0
    _t_nab := _t_otp := _t_amp := 0
    _sanacija := .f.

    do while !eof() .and. (idrj=cidrj .or. empty(cidrj))  .and. left(idkonto,3)==cidsk

        cIdKonto:=idkonto
        nDug3:=nPot31:=nPot32:=0
        _t_nab := _t_otp := _t_amp := 0

        do while !eof() .and. (idrj=cidrj .or. empty(cidrj))  .and. idkonto==cidkonto

            if prow() > RPT_PAGE_LEN
                FF
                os_zagl_amort()
            endif

            if !( (cON=="N" .and. empty(datotp)) .or.;
               (con=="O" .and. !empty(datotp)) .or.;
               (con=="B" .and. year(datum)=year(gdatobr)) .or.;
               (con=="G" .and. year(datum)<year(gdatobr)) .or.;
                empty(con) )
                skip 1
                loop
            endif

            fIma:=.t.
            
            if cPromj=="3"  
                // ako zelim samo promjene vidi ima li za sr.
                // uopste promjena
                _sr_id := field->id
                select_promj()
                hseek _sr_id
                fIma:=.f.
                do while !eof() .and. field->id == _sr_id .and. field->datum <= gDatObr
                    fIma:=.t.
                    skip
                enddo
                select_os_sii()
            endif

            // utvrdjivanje da li sredstvo ima sada�nju vrijednost
            // --------------------------------------------------

            lImaSadVr:=.f.

            if cPromj <> "3"
                if nabvr-otpvr-amp>0
                    lImaSadVr:=.t.
                endif
            endif

            if cPromj $ "23"  
                // prikaz promjena
                _sr_id := field->id
                select_promj()
                hseek _sr_id
                do while !EOF() .and. field->id == _sr_id .and. field->datum <= gDatObr
                    n1 := 0
                    n2 := amp
                    if nabvr - otpvr - amp > 0
                        lImaSadVr := .t.
                    endif
                    skip
                enddo
                select_os_sii()
            endif

            // ispis stavki
            // ------------
            if cFiltSadVr=="1" .and. !(lImaSadVr) .or.;
              cFiltSadVr=="2" .and. lImaSadVr
                skip
                loop
            else
                if fIma
                    ? str(++nrbr,4)+".",id,idrj,datum,naz,jmj,str(kolicina,6,1)
                    nCol1:=pcol()+1
                endif
                if cPromj <> "3"
                    @ prow(),ncol1    SAY nabvr*nBBK pict gpici
                    @ prow(),pcol()+1 SAY otpvr*nBBK pict gpici
                    @ prow(),pcol()+1 SAY amp*nBBK pict gpici
                    @ prow(),pcol()+1 SAY otpvr*nBBK+amp*nBBK pict gpici
                    @ prow(),pcol()+1 SAY nabvr*nBBK-otpvr*nBBK-amp*nBBK pict gpici
                    nDug3+=nabvr
                    nPot31+=otpvr
                    nPot32+=amp
                    _t_nab += nabvr
                    _t_otp += otpvr
                    _t_amp += amp
                endif
                if cPromj $ "23"  // prikaz promjena
                    _sr_id := field->id
                    _sr_id_rj := field->idrj
                    select_promj()
                    hseek _sr_id
                    do while !eof() .and. field->id == _sr_id .and. field->datum <= gDatObr

                        ? space(5),space(len(id)),space(len( _sr_id_rj )),datum,opis

                        n1 := 0
                        n2 := amp

                        if LEFT( field->opis, 2 ) == "#S"
                            _sanacija := .t.
                            _t_amp += amp
                            _t_otp += otpvr
                            _t_nab += nabvr
                        endif
                        
                        @ prow(),ncol1    SAY nabvr*nBBK pict gpici
                        @ prow(),pcol()+1 SAY otpvr*nBBK pict gpici
                        
                        if !_sanacija
                            @ prow(),pcol()+1 SAY amp*nBBK pict gpici
                            @ prow(),pcol()+1 SAY otpvr*nBBK+amp*nBBK pict gpici
                            @ prow(),pcol()+1 SAY nabvr*nBBK-amp*nBBK-otpvr*nBBK pict gpici
                        endif

                        nDug3+=nabvr; nPot31+=otpvr
                        nPot32+=amp
                        skip
                    enddo

                    select_os_sii()

                endif

            endif

            skip

            if _sanacija 
                // ispisati stanje sanacija ako treba....
                ? SPACE(20) + REPLICATE("-", 88 )
                ? PADL( "Ukupni obracun sanacija:", nCol1 )
                @ prow(), nCol1 SAY _t_nab PICT gPicI
                @ prow(), pcol() + 1 SAY _t_otp PICT gPicI
                @ prow(), pcol() + 1 SAY _t_amp PICT gPicI
                ?
                _sanacija := .f.
            endif

        enddo

        if prow() > RPT_PAGE_LEN
            FF
            os_zagl_amort()
        endif
        
        nTArea := SELECT()
        select konto
        hseek cIdKonto
        select (nTArea)
        ? m
        ? " ukupno ", cIdKonto, PADR( konto->naz, 50 )
        @ prow(),ncol1    SAY ndug3*nBBK pict gpici
        @ prow(),pcol()+1 SAY npot31*nBBK pict gpici
        @ prow(),pcol()+1 SAY npot32*nBBK pict gpici
        @ prow(),pcol()+1 SAY npot31*nBBK+npot32*nBBK pict gpici
        @ prow(),pcol()+1 SAY ndug3*nBBK-npot31*nBBK-npot32*nBBK pict gpici
        ? m
        nDug2+=nDug3; nPot21+=nPot31; nPot22+=nPot32
        if !empty(qidkonto) .and. cKPocinju=="N"
            exit
        endif
    enddo
    if !empty(qidkonto) .and. cKPocinju=="N"
        exit
    endif
    if prow() > RPT_PAGE_LEN; FF; os_zagl_amort(); endif
    ? m
    nTArea := SELECT()
    select konto
    hseek cIdSK
    select (nTArea)
    ? " UKUPNO ",cIdSK, PADR( konto->naz, 50 )
    @ prow(),ncol1    SAY ndug2*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot21*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot22*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot21*nBBK+npot22*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug2*nBBK-npot21*nBBK-npot22*nBBK pict gpici
    ? m
    nDug+=nDug2; nPot1+=nPot21; nPot2+=nPot22

enddo

if empty(qidkonto) .or. cKPocinju=="D"
    if prow() > RPT_PAGE_LEN
        FF  
        os_zagl_amort()
    endif
    ?
    ? m
    ? " U K U P N O :"
    @ prow(),ncol1    SAY ndug*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot1*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot2*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot1*nBBK+npot2*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug*nBBK-npot1*nBBK-npot2*nBBK pict gpici
    ? m
    ?
    ?
    if cPotpis=="D"
	    ? " Zaduzeno lice:"
	    ? " _______________________"
	    ? SPACE(95)+"Clanovi komisije:"
	    ? SPACE(95)+"_____________________"
	    ? SPACE(95)+"_____________________"
	    ? SPACE(95)+"_____________________"
    endif
endif

FF
END PRINT

my_close_all_dbf()
return


function os_zagl_amort()
?
@ prow(),125 SAY "Str."+str(++nStr,3)
if lBrojSobe .and. !empty(cBrojSobe)
  ?
  ? "Prikaz za sobu br:", cBrojSobe
  ?
endif
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
? m
? " Rbr.  Inv.broj   RJ    Datum    Sredstvo                     jmj  kol  "+" "+PADC("NabVr",LEN(gPicI))+" "+PADC("OtpVr",LEN(gPicI))+" "+PADC("Amort.",LEN(gPicI))+" "+PADC("O+Am",LEN(gPicI))+" "+PADC("SadVr",LEN(gPicI))
? m

return


