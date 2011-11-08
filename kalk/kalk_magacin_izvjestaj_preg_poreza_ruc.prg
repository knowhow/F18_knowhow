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


// pregled poreza na RUC
function RekPorMag()
*{
local nT1:=nT4:=nT5:=nT6:=nT7:=0
local nTT1:=nTT4:=nTT5:=nTT6:=nTT7:=0
local n1:=n4:=n5:=n6:=n7:=0
local nCol1:=0
local PicCDEM:=REPLICATE("9", VAL(gFPicCDem)) + gPicCDem
local PicProc:=gPicProc   
local PicDEM:=REPLICATE("9", VAL(gFPicDem)) + gPicDem    
local Pickol:=gPicKol

dDat1:=dDat2:=ctod("")
qqKonto:=padr("1310;",60)
qqPartn:=qqRoba:=space(60)
cNRUC:="N"
Box(,5,75)
 set cursor on
 do while .t.
  @ m_x+1,m_y+2 SAY "Magacinski konto " GET qqKonto pict "@!S50"
  @ m_x+2,m_y+2 SAY "Artikli          " GET qqRoba  pict "@!S50"
  @ m_x+3,m_y+2 SAY "Kupci            " GET qqPartn pict "@!S50"
  @ m_x+4,m_y+2 SAY "Kalkulacije (14,15,94) od datuma:" GET dDat1
  @ m_x+4,col()+1 SAY "do" GET dDat2
  @ m_x+5,m_y+2 SAY "U izvjestaj ulaze dokum. sa negativnom RUC D/N ?" GET cNRUC valid cnruc $"DN" pict "@!"
  read;ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"MKonto")
  aUsl2:=Parsiraj(qqRoba,"IdRoba")
  aUsl3:=Parsiraj(qqPartn,"IdPartner")
  if aUsl1<>NIL
      exit
  endif
 enddo
BoxC()

set softseek off
O_SIFK
O_SIFV
O_ROBA
O_TARIFA
O_KALK
set order to 6

private cFilt1:=""

cFilt1 := ".t."+IF(EMPTY(dDat1),"",".and.DATDOK>="+cm2str(dDat1))+;
                IF(EMPTY(dDat2),"",".and.DATDOK<="+cm2str(dDat2))+;
                ".and."+aUsl1+".and."+aUsl2+".and."+aUsl3+;
                ".and.(IDVD $ '14#15#94')"

cFilt1:=STRTRAN(cFilt1,".t..and.","")

IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

go top
 
aMRUP:={}
AADD(aMRUP, {15, " TARIF", " BROJ"})
AADD(aMRUP, {LEN(PicDem), " NV", ""})
AADD(aMRUP, {LEN(PicDem), " VPV - RAB", ""})
if gVarVP == "1"
	AADD(aMRUP, {LEN(PicDem), " VPV - NV", " (RUC)"})
endif
AADD(aMRUP, {LEN(PicProc), " POREZ", " %"})
if gVarVP <> "1"
	AADD(aMRUP, {LEN(PicDem), " RUC", ""})
endif
AADD(aMRUP, {LEN(PicDem), " POREZ", " (PRUC)"})
AADD(aMRUP, {LEN(PicDem), if(gVarVP=="1", " RUC-PRUC", " RUC + PRUC"), ""})
AADD(aMRUP, {LEN(PicDem), " VPV", if(gVarVP=="1"," SA Por.", "")})
cLine:=SetRptLineAndText(aMRUP, 0)
cText1:=SetRptLineAndText(aMRUP, 1, "*")
cText2:=SetRptLineAndText(aMRUP, 2, "*")

START PRINT CRET
?

n1:=n2:=n3:=n5:=n5b:=n6:=0

cVT:=.f.

DO WHILE !EOF() .and. IspitajPrekid()
  B:=0
  cIdFirma:=KALK->IdFirma
  Preduzece()
  P_COND
  ? "KALK: PREGLED POREZA NA RUC PO TARIFNIM BROJEVIMA ZA PERIOD OD",dDat1,"DO",dDAt2,"      NA DAN:",DATE()

  aUsl2:=Parsiraj(qqRoba,"IdRoba")
  aUsl3:=Parsiraj(qqPartn,"IdPartner")
  if len(aUsl2)>0
    ? "Kriterij za Artikle:",trim(qqRoba)
  endif
  if len(aUsl3)>0
    ? "Kriterij za Kupce:",trim(qqPartn)
  endif

  ?
  ? cLine
  ? cText1
  ? cText2
  ? cLine
  
  nT1:=nT2:=nT3:=nT5:=nT5B:=nT6:=0
  DO WHILE !EOF() .AND. cIdFirma==KALK->IdFirma .and. IspitajPrekid()
     cIdKonto:=IdKonto
     cIdTarifa:=IdTarifa
     select tarifa; hseek cidtarifa
     select kalk
     nVPP:=TARIFA->VPP
     nVPV:=nNV:=0
     nVPVN:=nNVN:=0
     DO WHILE !EOF() .AND. cIdFirma==IdFirma .and. cIdtarifa==IdTarifa .and. IspitajPrekid()
        select KALK
        select roba; hseek kalk->idroba; select kalk
        VtPorezi()
        if _PORVT<>0
           cVT:=.t.
        endif

        if VPC/(1+_PORVT)*(1-RabatV/100)-NC>=0 .or. cNRUC=="D"     // u osnovicu ulazi pozitivna marza!!!
          if idvd=="14"
            nNV+=NC*(Kolicina)
            nVPV+=VPC/(1+_PORVT)*(1-RabatV/100)*(Kolicina)
          elseif idvd=="15"
            nNV+=NC*(-Kolicina)
            nVPV+=VPC/(1+_PORVT)*(1-RabatV/100)*(-Kolicina)
          else
            nNV-=NC*(Kolicina)
            nVPV-=VPC/(1+_PORVT)*(1-RabatV/100)*(Kolicina)
          endif
        endif

        skip
     ENDDO // tarifa

     if prow()>61+gPStranica; FF; endif
     if gVarVP=="1"
       nPorez:=(nVPV-nNV)*nVPP/100
     else
       nPorez:=(nVPV-nNV)*nVPP/100/(1+nVPP/100)
     endif
     @ prow()+1,0        SAY space(6)+cIdTarifa
     nCol1:=pcol()+4
      @ prow(),pcol()+4 SAY n1:=nNV PICT PicDEM
      @ prow(),pcol()+1 SAY n2:=nVPV PICT PicDEM
     if gVarVP=="1"
      @ prow(),pcol()+1   SAY n3:=nVPV-nNV    PICT   PicDEM
      @ prow(),pcol()+1   SAY nVPP            PICT   PicProc
      @ prow(),pcol()+1   SAY n5:=nPorez      PICT   PicDEM
      @ prow(),pcol()+1   SAY n5b:=nVPV-nNV-nPorez      PICT   PicDEM
      @ prow(),pcol()+1   SAY n6:=nVPV+nPorez PICTURE   PicDEM
     else
      @ prow(),pcol()+1   SAY nVPP            PICT   PicProc
      @ prow(),pcol()+1   SAY n5b:=nVPV-nNV-nPorez    PICT   PicDEM
      @ prow(),pcol()+1   SAY n5:=nPorez      PICT   PicDEM
      @ prow(),pcol()+1   SAY n3:=nVPV-nNV    PICT   PicDEM
      @ prow(),pcol()+1   SAY n6:=nVPV PICTURE   PicDEM
     endif
     nT1+=n1;  nT2+=n2;  nT3+=n3;  nT5+=n5; nT5b+=n5b
     nT6+=n6
  ENDDO // konto

  if prow()>60+gPStranica; FF; endif
  ? cLine
  ? "UKUPNO:"
  @ prow(),nCol1     SAY  nT1     pict picdem
  @ prow(),pcol()+1  SAY  nT2     pict picdem
  if gVarVP=="1"
    @ prow(),pcol()+1  SAY  nT3     pict picdem
    @ prow(),pcol()+1  SAY  SPACE(LEN(PICPROC))
    @ prow(),pcol()+1  SAY  nT5     pict picdem
    @ prow(),pcol()+1  SAY  nT5b    pict picdem
    @ prow(),pcol()+1  SAY  nT6     pict picdem
  else
    @ prow(),pcol()+1  SAY  SPACE(LEN(PICPROC))
    @ prow(),pcol()+1  SAY  nT5b    pict picdem
    @ prow(),pcol()+1  SAY  nT5     pict picdem
    @ prow(),pcol()+1  SAY  nT3     pict picdem
    @ prow(),pcol()+1  SAY  nT2     pict picdem
  endif
  ? cLine

ENDDO // eof

if cVT
  ?
  ? "Napomena: Za robu visoke tarife VPV je prikazana umanjena za iznos poreza"
  ? "koji je ukalkulisan u cijenu ( jer ta umanjena vrijednost odredjuje osnovicu)"
endif
?
FF

END PRINT

set softseek on
closeret
return
*}
