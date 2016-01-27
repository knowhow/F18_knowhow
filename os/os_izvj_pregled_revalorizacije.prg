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


function os_pregled_revalorizacije()
local cIdKonto:=qidkonto:=space(7), cidsk:="", ndug:=ndug2:=npot:=npot2:=ndug3:=npot3:=0
local nCol1:=10
local _sr_id

O_KONTO
O_RJ

o_os_sii_promj()
o_os_sii()

cIdrj:=space(4)
cPromj:="2"
cPocinju:="N"
cFiltK1:=SPACE(40)
cON:=" " // novo!

Box(,10,77)
 DO WHILE .t.
  @ m_x+1,m_y+2 SAY "Radna jedinica (prazno - svi):" get cidrj valid empty(cIdRj) .or. p_rj(@cIdrj)
  @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
  @ m_x+2,m_y+2 SAY "Konto (prazno - svi):" get qIdKonto pict "@!" valid empty(qidkonto) .or. P_Konto(@qIdKonto)
  @ m_x+4,m_y+2 SAY "Za sredstvo prikazati vrijednost:"
  @ m_x+5,m_y+2 SAY "1 - bez promjena"
  @ m_x+6,m_y+2 SAY "2 - osnovni iznos + promjene"
  @ m_x+7,m_y+2 SAY "3 - samo promjene           " GET cPromj valid cpromj $ "123"
  @ m_x+8,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  @ m_x+ 9,m_y+2 SAY "Prikaz svih os ( )      /   neotpisanih (N)     / otpisanih   (O) "
  @ m_x+10,m_y+2 SAY "/novonabavljenih   (B) / iz proteklih godina (G)" get cON valid con $ "ONBG " pict "@!"
  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

if empty(qidkonto); qidkonto:=""; endif
if empty(cIdrj); cidrj:=""; endif
if cpocinju=="D"
  cIdRj:=trim(cidrj)
endif

os_rpt_default_valute()

start print cret
private nStr:=0  // strana
select rj
hseek cIdrj
select_os_sii()

if !EMPTY(cFiltK1)
    set filter to &aUsl1
endif

P_10CPI
? gTS+":",gnFirma
if !empty(cidrj)
 ? "Radna jedinica:",cidrj,rj->naz
endif
? "OS: Pregled obracuna revalorizacije po kontima "
?? "",PrikazVal(),"    Datum:",gDatObr
P_COND2

private m:="----- ---------- ---- -------- ------------------------------ --- ------"+REPL(" "+REPL("-",LEN(gPicI)),5)

select_os_sii()

if empty(cidrj)
    set order to tag "4" 
    //"OSi4","idkonto+idrj+id"
    seek qidkonto
else
    set order to tag "3" 
    //"OSi3","idrj+idkonto+id"
    seek cidrj + qidkonto
endif

private nrbr:=0

nDug1:=nDug2:=nPot1:=nPot2:=0

os_zagl_reval()

n1:=0
n2:=0

do while !eof() .and. (idrj=cidrj .or. empty(cidrj))
    
    cIdSK:=left(idkonto,3)
    nDug21:=0
    nDug22:=0
    nPot21:=0
    nPot22:=0
   
    do while !eof() .and. (field->idrj = cIdrj .or. empty(cIdrj)) .and. left(field->idkonto,3) == cIdSK
      
        cIdKonto := field->idkonto
        nDug31 := 0
        nDug32 := 0
        nPot31 := 0
        nPot32 := 0
      
        do while !eof() .and. ( field->idrj = cIdrj .or. empty(cIdrj)) .and. field->idkonto == cIdkonto
         
            if prow()>60
                FF
                os_zagl_reval()
            endif
         
            if !( (cON=="N" .and. empty(field->datotp)) .or.;
               (con=="O" .and. !empty(field->datotp)) .or.;
               (con=="B" .and. year(field->datum)=year(gdatobr)) .or.;
               (con=="G" .and. year(field->datum)<year(gdatobr)) .or.;
                empty(con) )
                skip 1
                loop
            endif
            
            fIma := .t.

            if cPromj == "3"  
                // ako zelim samo promjene vidi ima li za sr.          
                // uopste promjena

                // id sredstva
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

            if fIma
                ? str(++nRbr,4)+".", field->id, field->idrj, field->datum, field->naz, field->jmj, str( field->kolicina, 6, 1 )
                nCol1:=pcol()+1
            endif
            
            if cPromj <> "3"
                @ prow(),ncol1    SAY field->nabvr * nBBK pict gpici
                @ prow(),pcol()+1 SAY field->otpvr * nBBK + field->amp * nBBK pict gpici
                @ prow(),pcol()+1 SAY field->revd * nBBK pict gpici
                @ prow(),pcol()+1 SAY field->revp * nBBK pict gpici
                @ prow(),pcol()+1 SAY field->nabvr * nBBK + field->revd * nBBK - ( field->otpvr + field->amp + field->revp )*nBBK pict gpici
                nDug31+=nabvr
                nPot31+=otpvr+amp
                nDug32+=revd
                nPot32+=revp
            endif
           
            if cPromj $ "23"  
                // prikaz promjena
                
                _sr_id := field->id
                _sr_id_rj := field->idrj

                select_promj()
                hseek os->id

                do while !eof() .and. field->id == _sr_id .and. field->datum <= gDatObr
                    ? space(5),space(len( _sr_id )), space(len( _sr_id_rj )), field->datum, field->opis
                    n1 := 0
                    n2 := field->amp
                    @ prow(),ncol1    SAY nabvr*nBBK pict gpici
                    @ prow(),pcol()+1 SAY otpvr*nBBK+amp*nBBK pict gpici
                    @ prow(),pcol()+1 SAY revd*nBBK pict gpici
                    @ prow(),pcol()+1 SAY revp*nBBK pict gpici
                    @ prow(),pcol()+1 SAY nabvr*nBBK+revd*nBBK-(otpvr+amp+revp)*nBBK pict gpici
                    nDug31+=nabvr
                    nPot31+=otpvr+amp
                    nDug32+=revd
                    nPot32+=revp
                    skip
                enddo
                select_os_sii()
            endif

            skip
        enddo
        
        if prow()>60
            FF
            os_zagl_reval()
        endif
        ? m
        ? " ukupno ", cIdkonto
        @ prow(),ncol1    SAY ndug31*nBBK pict gpici
        @ prow(),pcol()+1 SAY npot31*nBBK pict gpici
        @ prow(),pcol()+1 SAY ndug32*nBBK pict gpici
        @ prow(),pcol()+1 SAY npot32*nBBK pict gpici
        @ prow(),pcol()+1 SAY ndug31*nBBK+nDug32*nBBK-npot31*nBBK-npot32*nBBK pict gpici
        ? m
        nDug21+=nDug31
        nPot21+=nPot31
        nDug22+=nDug32
        nPot22+=nPot32
        if !empty(qidkonto)
            exit
        endif

    enddo

    if !empty(qidkonto)
        exit
    endif
    
    if prow()>60
        FF
        os_zagl_reval()
    endif
    
    ? m
    ? " UKUPNO ", cIdsk
    @ prow(),ncol1    SAY ndug21*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot21*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug22*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot22*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug21*nBBK+nDug22*nBBK-npot21*nBBK-npot22*nBBK pict gpici
    ? m
    nDug1+=nDug21
    nPot1+=nPot21
    nDug2+=nDug22
    nPot2+=nPot22

enddo

if empty(qidkonto)
    if prow()>60
        FF
        os_zagl_reval()
    endif
    ?
    ? m
    ? " U K U P N O :"
    @ prow(),ncol1    SAY ndug1*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot1*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug2*nBBK pict gpici
    @ prow(),pcol()+1 SAY npot2*nBBK pict gpici
    @ prow(),pcol()+1 SAY ndug1*nBBK+nDug2*nBBK-npot1*nBBK-npot2*nBBK pict gpici
    ? m
endif

?
? "Napomena: Kolona 'Otp. vrijednost' prikazuje otpisanu vrijednost sredstva sa uracunatom amortizacijom za ovu godinu"
FF
ENDPRINT

my_close_all_dbf()
return


function os_zagl_reval()
?
P_COND
@ prow(),125 SAY "Str."+str(++nStr,3)
if !EMPTY(cFiltK1); ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"; endif
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
? " Rbr.  Inv.broj   RJ    Datum    Sredstvo                     jmj  kol  "+" "+PADC("NabVr",LEN(gPicI))+" "+PADC("OtpVr",LEN(gPicI))+" "+PADC("Rev.Dug.",LEN(gPicI))+" "+PADC("Rev.Pot.",LEN(gPicI))+" "+PADC("SadVr",LEN(gPicI))
? m

return



