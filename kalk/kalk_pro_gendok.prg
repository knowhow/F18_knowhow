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


function GenProizvodnja()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. generisi 96 na osnovu 47 po normativima")
AADD( _opcexe, { || Iz47u96Norm() })

f18_menu( "kkno", .f.,  _izbor, _opc, _opcexe )

my_close_all_dbf()
return




function Iz47u96Norm()
local cIdFirma:=gFirma, cBrDok:=cBrKalk:=space(8)
O_KALK_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_SAST
#xcommand XO_KALK  => select (F_FAKT);  my_use ("kalk2", "kalk_kalk" ) ; set order to tag "1"
XO_KALK

dDatKalk:=date()
cIdKonto:=padr("",7)
cIdKonto2:=padr("1010",7)
cIdZaduz2:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
    select kalk
    set order to tag "1"
    seek cidfirma+"96X"
    skip -1
    if idvd<>"96"
        cbrkalk:=space(8)
    else
        cbrkalk:=brdok
    endif
endif

Box(,15,60)

if gBrojac=="D"
    cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 96 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif
  @ m_x+4,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid empty(cIdKonto) .or. P_Konto(@cIdKonto)

  cBrDok47:=space(8)
  @ m_x+7,m_Y+2 SAY "Broj dokumenta 47:" GET cBrDok47
  read
  if lastkey()==K_ESC; exit; endif

  select kalk2
  seek cIDFirma+'47'+cBrDok47
  dDatKalk:=datdok
  IF !ProvjeriSif("!eof() .and. '"+cIDFirma+"47"+cBrDok47+"'==IdFirma+IdVD+BrDok","IDROBA",F_ROBA)
    MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
    LOOP
  ENDIF
  do while !eof() .and. cIDFirma+'47'+cBrDok47 == idfirma+idvd+brdok

       select ROBA; HSEEK kalk2->idroba

          select sast
          HSEEK  kalk2->idroba
          do while !eof() .and. id==kalk2->idroba // setaj kroz sast
            select roba; HSEEK sast->id2
            select kalk_pripr
            locate for idroba==sast->id2
            if found()
              RREPLACE kolicina with kolicina + kalk2->kolicina*sast->kolicina
            else
              select kalk_pripr
              append blank
              replace idfirma with cIdFirma,;
                      rbr     with str(++nRbr,3),;
                      idvd with "96",;   // izlazna faktura
                      brdok with cBrKalk,;
                      datdok with dDatKalk,;
                      idtarifa with ROBA->idtarifa,;
                      brfaktp with "",;
                      datfaktp with dDatKalk,;
                      idkonto   with cidkonto,;
                      idkonto2  with cidkonto2,;
                      idzaduz2  with cidzaduz2,;
                      kolicina with kalk2->kolicina*sast->kolicina,;
                      idroba with sast->id2,;
                      nc  with ROBA->nc
            endif
            select sast
            skip
          enddo

    select kalk2
    skip
  enddo

  @ m_x+10,m_y+2 SAY "Dokument je prenesen !!"
  if gBrojac=="D"
   cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
  endif
  inkey(4)
  @ m_x+8,m_y+2 SAY space(30)

enddo
Boxc()
select kalk2; use
closeret
return
*}


