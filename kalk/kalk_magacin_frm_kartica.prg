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


#include "kalk.ch"



function AnaKart()
O_KONCIJ
O_SIFK
O_SIFV
O_ROBA
O_KALK
if Pitanje(,"Prodji kroz neobradjene stavke","N")="D"
  set order to 
  go top
  MsgO("Prolaz#................")
  nCnt:=0
  do while !eof() .and. IspitajPrekid()

     if empty(mu_i) .and. empty(pu_i)
        @ m_x+2,m_y+4 SAY ++nCnt
        if idvd=="10"
           replace mu_i with "1", mkonto with idkonto
        elseif idvd=="11"
           replace mu_i with "5", mkonto with idkonto2,;
                   pu_i with "1", pkonto with idkonto
        elseif idvd $ "14#96"
           replace mu_i with "5", mkonto with idkonto2
        elseif idvd=="18"
           replace mu_i with "3", mkonto with idkonto
        elseif idvd=="19"
           replace pu_i with "3", pkonto with idkonto
        elseif idvd $ "41#42#43"
           replace pu_i with "5", pkonto with idkonto
        endif
     endif
     skip
  enddo
  Msgc()
endif

set order to tag "3"
//CREATE_INDEX("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")
go top
aDbf:={}
AADD(aDbf, {"ID", "C", 10, 0 } )     // roba
AADD(aDbf, {"stanje", "N", 15, 3 } )
AADD(aDbf, {"VPV", "N", 15, 3 } )
AADD(aDbf, {"NV", "N", 15, 3 } )
AADD(aDbf, {"VPC", "N", 15, 3 } )
AADD(aDbf, {"MPC", "N", 15, 3 } )
AADD(aDbf, {"MPV", "N", 15, 3 } )
AADD(aDbf, {"recno", "N", 6, 0 } )
dbcreate2(PRIVPATH+"LLM",aDbf)

select 70
usex (PRIVPATH+"llm")
index on id tag "ID"
index on brisano tag "BRISAN"
set order to tag "ID"

private cIdFirma:=gFirma
private cMkonto:=padr("1310",gDuzKonto)
Box(,2,50)
  @ m_x+1,m_y+2 SAY "Konto:" GET cMkonto
  read
BoxC()
select kalk
seek cidfirma+cmkonto
do while !eof() .and. IspitajPrekid()
    cIdroba:=idroba
    cmkonto:=mkonto
    cidfirma:=idfirma
    select kalk
    seek cidfirma+cmkonto+cidroba
    nStanje:=nNV:=nVPV:=0
    nReckalk:=0
    do while !eof() .and. idfirma+mkonto+idroba==cidfirma+cmkonto+cidroba .and. IspitajPrekid()
      nRecKalk:=recno()
      cId:=idfirma+idvd+brdok+rbr
      if mu_i=="1"
          nStanje+=kolicina-gkolicina-gkolicin2
          nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
          nNV+=nc*(kolicina-gkolicina-gkolicin2)
       elseif mu_i=="3"
          nVPV+=vpc*kolicina
       elseif mu_i=="5"
          nStanje-=kolicina
          nVPV-=vpc*kolicina
          nNV-=nc*kolicina
       endif
       skip
    enddo    // cidroba

     select llm
     append blank
     replace id with cidroba, stanje with nstanje, vpv with nVPV,;
            recno with nRecKalk
     if nStanje<>0
        replace vpc with nVPV/nStanje
     endif
     select kalk

enddo

select llm

ImeKol:={}
AADD(ImeKol,{ "IdRoba",    {|| id}                         })
AADD(ImeKol,{ "Stanje", {|| llm->stanje} })
AADD(ImeKol,{ "VPC po Kartici", {|| llm->vpc} })
AADD(ImeKol,{ "VPV po kartici", {|| llm->vpv} })


Kol:={}; for i:=1 to len(Imekol); AADD(Kol,i); next

Box(,20,77)
ObjDbedit("anm",20,77,{|| EdLLM()},"","...", , , , ,3)
BoxC()
closeret
return
*}




/*! \fn EdLLM()
 *  \brief Obrada opcija u browse-u tabele LLM
 */

function EdLLM()
*{
local cDn:="N",nTrecDok:=0,nRet:=DE_CONT
do case
  case Ch==K_ENTER
         select kalk; set order to tag "3"
         //CREATE_INDEX("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")
         go llm->recno
         BrowseKart()
         select llm
     nRet:=DE_REFRESH

 case Ch==K_CTRL_P
     nRet:=DE_REFRESH
endcase
return nRet
*}


