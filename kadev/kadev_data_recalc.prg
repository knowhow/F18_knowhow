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




#include "kadev.ch"


function kadev_recalc()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. rekalkulacija statusa                       " )
AADD( _opcexe, {|| kadev_rekstatall() } )
AADD( _opc, "2. rekalkulacija radnog staza  " )
AADD( _opcexe, {|| kadev_rekrstall() } )

f18_menu( "recl", .f., _izbor, _opc, _opcexe )

close all

return



function kadev_rekstatall()
local nOldArr

PushWa()
nOldArr:=SELECT()

O_KADEV_1
O_KADEV_PROMJ
O_KDV_RJRMJ
O_KDV_RRASP


select kadev_1    ; set order to tag "1"
select kadev_promj  ; set order to tag "ID"
select kdv_rjrmj  ; set order to tag "ID"
select kdv_rrasp  ; set order to tag "ID"

select kadev_1
set relation to idpromj into kadev_promj
set relation to idrj+idrmj into kdv_rjrmj addi

select kadev_0
set relation to idrrasp into kdv_rrasp


dDoDat:=DATE()
Box("b0XX", 1, 65,.f.)
 set cursor on
 @ m_x+1,m_y+2 SAY "Kalkulacija do datuma:" GET dDoDat
 read
BoxC()
if lastkey()==K_ESC
    close all
    return
endif

select(nOldArr)

IF gPostotak=="D"
  Postotak(1,RECCOUNT2(),"Rekalkulisanje statusa")
ELSE
  Box("b0XY",1,55,.f.)
ENDIF
n1:=0
go top
do while !eof()
  IF gPostotak!="D"
    @ m_x+1,m_y+2 SAY kadev_0->(id+": "+prezime+" "+ime)
  ELSE
    Postotak(2,++n1)
  ENDIF
  select kadev_1
  seek kadev_0->id
  RekalkStatus(dDoDat)
  select(nOldArr)
  skip
enddo
IF gPostotak=="D"
 Postotak(0)
ELSE
 BoxC()
ENDIF

PopWa()

close all
return


function RekalkStatus(dDoDat)
local cIntStat:=" "     // intervalni status (kod nezavrsenih interv.promjena)
replace kadev_0->status with ""          ,;
        kadev_0->IdRJ    with ""         ,;
        kadev_0->IdRMJ   with ""         ,;
        kadev_0->DatURmj with CTOD("")   ,;
        kadev_0->DatVRmj with CTOD("")   ,;
        kadev_0->IdRRASP with ""         ,;
        kadev_0->SlVr    with ""         ,;
        kadev_0->VrSlVr with 0           ,;
        kadev_0->IdStrSpr with ""        ,;
        kadev_0->DatUF with CTOD("")     ,;
        kadev_0->IdZanim with ""

do while id=kadev_0->id .and. (DatumOd<dDoDat)

   if kdv_promj->tip<>"X"
     IF EMPTY(cIntStat)                           // MS 18.9.00.
       replace kadev_0->status with kdv_promj->status
     ELSE                                         // MS 18.9.00.
       replace kadev_0->status with cIntStat          // MS 18.9.00.
     ENDIF                                        // MS 18.9.00.
   endif

   if kadev_promj->srmj=="1"  // SRMJ=="1" - promjena radnog mjesta
       replace kadev_0->idRj with IdRj
       replace kadev_0->idRMJ with IdRMJ
       replace kadev_0->DatURMJ with DatumOd
       replace kadev_0->DatURMJ with DatumOd
       if empty(kadev_0->DatUF)
         replace kadev_0->DatUF with DatumOd
       endif
       replace kadev_0->DatVRmj with CTOD("")
   else
       replace kadev_1->idRj with kadev_0->IdRj
       replace kadev_1->idRMJ with kadev_0->IdRMJ
   endif

   if kdv_promj->urrasp=="1" // setovanje ratnog rasporeda
      replace kadev_0->IdRRasp with cAtr1
   endif

   if kdv_promj->ustrspr=="1" // setovanje ratnog rasporeda
      replace kadev_0->IdStrSpr with cAtr1
      replace kadev_0->IdZanim  with cAtr2
   endif

   if kdv_promj->uradst=" " .and. promj->tip=" " // fiksna promjena koja
      replace kadev_1->IdRMJ with ""            //  - ne ulazi u rst -
      replace kadev_1->IdRJ with ""
      replace kadev_0->DatVRMJ with DatumOd
   endif

   if kdv_promj->tip=="I"  // intervalna promjena

     if !(empty(DatumDo) .or. (DatumDo>dDoDat)) // zatvorena
       if kdv_promj->status="M" .and. kdv_rrasp->catr="V" // catr="V" -> sluzenje vojnog roka
         replace kadev_0->SlVr with "D"
         replace kadev_0->VrSlVr with kadev_0->VrSlVr + (DatumDo-DatumOd)
       endif
     endif

     if empty(DatumDo) .or. (DatumDo>dDoDat)
       replace kadev_0->DatVRMJ with DatumOd
       cIntStat := kdv_promj->status                  // MS 18.9.00.
     else   // vrsi se zatvaranje promjene
       if kdv_promj->uRrasp="1"  // ako je intervalna promjena setovala RRasp
          replace kadev_0->IdRRasp with ""
       endif
       replace kadev_0->status with "A" // promjena je zatvorena
     endif
   endif
   skip
enddo
RETURN (NIL)


***********************************************************************
// lPom=.t. -> radni staz u firmi zapisuj u POM.DBF, a ne diraj KADEV_0.DBF
***********************************************************************
function kadev_rekrstall(lPom)
local nOldArr

IF lPom==NIL; lPom:=.f.; ENDIF

PushWa()
nOldArr:=SELECT()

O_KADEV_1
O_KADEV_PROMJ
O_KDV_RJRMJ
O_KDV_RRASP
// O_KBENRST

select kadev_1    ; set order to tag "1"
select kadev_promj  ; set order to tag "ID"
select kdv_rjrmj  ; set order to tag "ID"
select kdv_rrasp  ; set order to tag "ID"

select kadev_1
set relation to IdPromj into kdv_promj
set relation to IdRj+IdRmj into kdv_rjrmj addi

select kdv_rjrmj
set relation to sbenefrst into kbenrst

select kadev_0
set relation to idRrasp into kdv_rrasp

IF lPom
  dDoDat:=DATE()      // ?
ELSE
  dDoDat:=DATE()
  Box("b0XX",1,65,.f.)
   set cursor on
   @ m_x+1,m_y+2 SAY "Kalkulacija do datuma:" GET dDoDat
   read
  BoxC()
  if lastkey()==K_ESC
    close all
    return
  endif
endif

select(nOldArr)

IF gPostotak=="D"
  Postotak(1,RECCOUNT2(),"Rekalkulisanje radnog staza")
ELSE
  Box("b0XY",1,55,.f.)
ENDIF
n1:=0
go top
do while !eof() 

  IF gPostotak!="D"
    @ m_x+1,m_y+2 SAY kadev_0->(id+": "+prezime+" "+ime)
  ELSE
    Postotak(2,++n1)
  ENDIF
  select kadev_1
  seek kadev_0->id
  RekalkRSt(dDoDat,lPom)
  select(nOldArr)
  skip
enddo

IF gPostotak=="D"
  IF lPom
    Postotak(-1)
  ELSE
    Postotak(0)
  ENDIF
ELSE
  BoxC()
ENDIF

PopWa()
close all
return


***********************************************************************
// lPom=.t. -> radni staz u firmi zapisuj u POM.DBF, a ne diraj KADEV_0.DBF
***********************************************************************
function RekalkRst(dDoDat,lPom)
 LOCAL nArr:=0, nRStUFe:=0, nRStUFb:=0
  IF lPom==NIL; lPom:=.f.; ENDIF
  nRstE:=0
  nRstB:=0
  KBfR:=0
  dOdDat:=CTOD("")
  fOtvoreno:=.f.
  do while id=kadev_0->id .and. (DatumOd<dDoDat)
    if kadev_promj->Tip="X" .and. kadev_promj->URadSt = "="
      nRstE   := nAtr1
      nRstB   := nAtr2
      nRstUFe := nAtr1
      nRstUFb := nAtr2
    endif
    if kadev_promj->Tip="X" .and. kadev_promj->URadSt = "+"
      nRstE   += nAtr1
      nRstB   += nAtr2
      nRstUFe += nAtr1
      nRstUFb += nAtr2
    endif
    if kadev_promj->Tip="X" .and. kadev_promj->URadSt = "-"
        nRstE-=nAtr1
        nRstB-=nAtr2
    endif
    if kadev_promj->Tip="X" .and. kadev_promj->URadSt = "A"
        nRstE:=(nRstE+nAtr1)/2
        nRstB:=(nRstB+nAtr2)/2
    endif
    if kadev_promj->Tip="X" .and. kadev_promj->URadSt = "*"
        nRstE:=nRstE*nAtr1
        nRstB:=nRstB*nAtr2
    endif
    if kadev_promj->Tip=="X" // ignorisi ovu promjenu
       skip
       loop
    endif
    if fOtvoreno
          nPom:=(DatumOd-dOdDat)
          nPom2:=nPom*kBfR/100
          if nPom<0 .and. kadev_promj->tip=="I"      // .and. ... dodao MS 18.9.00.
            MsgO("Neispravne promjene kod "+kadev_0->prezime+" "+kadev_0->ime)
            Inkey(0)
            MsgC()
//            MsgBeep( "nPom="+STR(nPom)+", DatumOd="+;
//                     DTOC(DatumOd)+", dOdDat="+DTOC(dOdDat) )
            return
          else
            nRstE+=nPom
            nRstB+=nPom2
          endif
    endif
    if kadev_promj->Tip==" " .and. kadev_promj->URadSt $ "12" //postavljenja,....
      dOdDat:=DatumOd          // otpocinje proces kalkulacije
      if kadev_promj->URadSt=="1"
       KBfR := kbenrst->vrijednost
      else   // za URadSt = 2 ne obracunava se beneficirani r.st.
       KBfR:=0
      endif
      fOtvoreno:=.t.     // Otvaram pocetak trajanja promjene ....
    else
      fOtvoreno:=.f.
    endif
    if kadev_promj->Tip=="I" .and. kadev_promj->URadSt==" "
      if empty(DatumDo)  // otvorena intervalna promjena koja se ne uracunava
        fOtvoreno:=.f.   // u radni staz - znaci nema vise
      else
        fOtvoreno:=.t.
        dOdDat:=iif(DatumDo>dDoDat,dDoDat,DatumDo) // ako je DatumDo unutar
        // promjene veci od Datuma kalkulacije onda koristi dDoDat
        KBfR:=kbenrst->vrijednost
      endif
    endif
    if kadev_promj->Tip=="I" .and. kadev_promj->URadSt $ "12"
      nPom:=iif(empty(DatumDo),dDoDat,if(DatumDo>dDoDat,dDoDat,DatumDo))-DatumOd
      if kadev_promj->URadSt=="1"
        nPom2:=nPom*kbenrst->vrijednost/100
      else   // za URadSt = 2 ne obracunava se beneficirani r.st.
        nPom2:=0
      endif
      if nPom<0
        MsgO("Neispravne intervalne promjene kod "+kadev_0->prezime+" "+kadev_0->ime)
        Inkey(0)
        MsgC()
        BoxC()
        return
      else
        nRstE+=nPom
        nRstB+=nPom2
        fOtvoreno:=.t.
        dOdDat:=iif(empty(DatumDo),dDoDat,iif(DatumDo>dDoDat,dDoDat,DatumDo))
        KBfR:=kbenrst->vrijednost
      endif
    endif
    skip
  enddo
  if fOtvoreno
    nPom:=(dDoDat-dOdDat)
    nPom2:=nPom*kBfR/100
    if nPom<0
      MsgO("Neispravne promjene ili dat. kalkul. za "+kadev_0->prezime+" "+kadev_0->ime)
      Inkey(0)
      MsgC()
      BoxC()
      return
    else
      nRstE+=nPom
      nRstB+=nPom2
    endif
  endif

  if lPom
    nArr:=SELECT()
    SELECT (F_POM)
     APPEND BLANK
       REPLACE ID     WITH KADEV_0->ID        ,;
               RADSTE WITH nRstE-nRStUFe  ,;
               RADSTB WITH nRstB-nRStUFb  ,;
               STATUS WITH KADEV_0->STATUS
    SELECT (nArr)
  else
    replace kadev_0->RadStE with nRStE
    replace kadev_0->RadStB with nRStB
  endif
RETURN (NIL)

