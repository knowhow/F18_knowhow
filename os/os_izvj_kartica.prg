/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"


function os_rpt_default_valute()
local nArr:=SELECT()
if (gDrugaVal=="D" .and. cTip==ValDomaca())
    Box(,5,70)
        @ m_x+2, m_y+2 SAY "Pomocna valuta      " GET cBBV pict "@!" valid ImaUSifVal(cBBV)
        @ m_x+3, m_y+2 SAY "Omjer pomocna/domaca" GET nBBK WHEN {|| nBBK:=OmjerVal(cBBV,cTip),.t.} PICT "999999999.999999999"
        read
    BoxC()
else
    cBBV:=cTip
    nBBK:=1
endif
select (nArr)
return


function PrikazVal()
return ( IF( gDrugaVal=="D" , " VALUTA:'"+TRIM(cBBV)+"'" , "" ) )


// -------------------------------------------
// -------------------------------------------
function os_kartica_sredstva()
  
o_os_sii_promj()
o_os_sii()

  cId:=SPACE(LEN(id))

  cPicSif:=IF(gPicSif="V","@!","")

  // zadajmo jedno ili sva sredstva
  // ------------------------------
  Box("#PREGLED KARTICE SREDSTVA",4,77)
   @ m_x+2,m_y+2 SAY "Inventurni broj (prazno-sva sredstva)" get cid valid empty(cId) .or. p_os(@cId) PICT cPicSif
   read
   ESC_BCR
  BoxC()

  // nadjimo sve postojece sezone
  // ----------------------------
  aSezone := ASezona(KUMPATH)
  cTekSez := STR (Year(Date()),4)
  FOR i:=LEN(aSezone) TO 1 STEP -1
    IF aSezone[i,1]>cTekSez .or. aSezone[i,1]<"1995" .or.;
       !FILE(KUMPATH+aSezone[i,1]+"\OS.DBF") .or.;
       !FILE(KUMPATH+aSezone[i,1]+"\OS.CDX") .or.;
       !FILE(KUMPATH+aSezone[i,1]+"\PROMJ.DBF") .or.;
       !FILE(KUMPATH+aSezone[i,1]+"\PROMJ.CDX")
      ADEL(aSezone,i)
      ASIZE(aSezone,LEN(aSezone)-1)
    ENDIF
  NEXT
  ASORT(aSezone,,,{|x,y| x[1]<y[1]})

  IF LEN(aSezone)<1
    MsgBeep("Nema proslih sezona pa kartice nisu potrebne!")
    CLOSERET
  ENDIF

  // pootvarajmo baze OS i PROMJ iz svih postojecih sezona
  // -----------------------------------------------------
  FOR i:=1 TO LEN(aSezone)
    USE (KUMPATH+aSezone[i,1]+"\OS")    NEW ALIAS ("OS"+aSezone[i,1])
    SET ORDER TO TAG "1"
    USE (KUMPATH+aSezone[i,1]+"\PROMJ") NEW ALIAS ("PROMJ"+aSezone[i,1])
    SET ORDER TO TAG "1"
  NEXT

  select_os_sii()
  IF EMPTY(cId)
    // sve kartice
    GO TOP
  ELSE
    // jedna kartica
    HSEEK cId
  ENDIF

  IF EOF()
    MsgBeep("U radnom podrucju nema nijednog sredstva!")
    CLOSERET
  ENDIF

  START PRINT CRET
  P_COND2

  DO WHILE !EOF()
    cInvBr:=id
    aPom:=aPom2:={}
    nLastNV:=nLastOV:=0
    FOR i:=1 TO LEN(aSezone)
      cSez:=aSezone[i,1]
      SELECT ("OS"+cSez); HSEEK cInvBr
      IF FOUND()
        aPom2:={}
        SELECT ("PROMJ"+cSez); HSEEK cInvBr
        IF FOUND()
          DO WHILE !EOF() .and. id==cInvBr
            //IF otpvr==0
              // nabavka - prvo evidentiranje
              AADD(aPom2,{datum,nabvr,0,0,otpvr,0,0})
              AADD(aPom2,{CTOD("31.12."+cSez),0,revd,0,amp,revp,0})
            //ELSE
              //AADD(aPom2,{CTOD("31.12."+cSez),0,revd,0,amp,revp,0})
            //ENDIF
            SKIP 1
          ENDDO
        ENDIF
        SELECT ("OS"+cSez)
        IF LEN(aPom)>0
          AADD(aPom,{CTOD("31.12."+cSez),0,revd,0,amp,revp,0})
          IF ROUND(nabvr,2)<>ROUND(nLastNV,2)
            // denominacija ili greska !
            // ( greska je ako nisu preneseni efekti am.i rev. u slj.godinu
            //   ili ako je posljednji pokrenuti obracun prethodne godine
            //   razlicit od konacnog )
            nKD  := IF(nLastNV=0,0,nabvr/nLastNV)
            nKD2 := IF(nLastOV=0,0,otpvr/nLastOV)
            AADD(aPom,{CTOD("01.01."+cSez),0,0,nKD,0,0,nKD2})
          ENDIF
        ELSE
          // nabavka - prvo evidentiranje
          AADD(aPom,{datum,nabvr,0,0,otpvr,0,0})
          AADD(aPom,{CTOD("31.12."+cSez),0,revd,0,amp,revp,0})
        ENDIF
        nLastNV := nabvr+revd
        nLastOV := otpvr+revp+amp
        FOR j:=1 TO LEN(aPom2)
          nLastNV += (aPom2[j,2]+aPom2[j,3])
          nLastOV += (aPom2[j,5]+aPom2[j,6])
          AADD(aPom,aPom2[j])
        NEXT
      ENDIF
    NEXT
    select_os_sii()

    IF LEN(aPom)>0
      ASORT(aPom,,,{|x,y| x[1]<y[1]})
      IF LEN(aPom)+11+PROW() > 64+gPStranica
        FF
      ENDIF
      ?
      ? "INVENTURNI BROJ:",cInvBr
      ? "NAZIV          :",naz
      ? "OPIS           :",opis,IF(!EMPTY(datotp),"OTPIS: "+TRIM(opisotp)+" "+DTOC(datotp)+" !","")
      ? "��������������������������������������������������������������������������������������������������������������������������������Ŀ"
      ? "�        �       N A B A V N A    V R I J E D N O S T         �       O T P I S A N A    V R I J E D N O S T       �             �"
      ? "� DATUM  ���������������������������������������������������������������������������������������������������������Ĵ   SADASNJA  �"
      ? "�        �PRVA/DODATNA�REVALORIZAC.�KOEF.DENOM. � U K U P N A �AMORTIZACIJA�REVALORIZAC.�KOEF.DENOM. � U K U P N A �  VRIJEDNOST �"
      ? "��������������������������������������������������������������������������������������������������������������������������������Ĵ"
      cK:="�"
      cT:="999999999.99"
      cTU:="9999999999.99"
      nNV:=nOV:=0
      FOR i:=1 TO LEN(aPom)
        nNV += (aPom[i,2]+aPom[i,3])
        nOV += (aPom[i,5]+aPom[i,6])
        IF aPom[i,4]<>0
          nNV := aPom[i,4]*nNV
        ENDIF
        IF aPom[i,7]<>0
          nOV := aPom[i,7]*nOV
        ENDIF
        lErr:=.f.
        IF ROUND(aPom[i,4],2)<>ROUND(aPom[i,7],2)
          lErr:=.t.
        ENDIF
        ? cK
        ?? aPom[i,1]          ; ?? cK
        ?? TRANSMN(aPom[i,2],cT); ?? cK
        ?? TRANSMN(aPom[i,3],cT); ?? cK
        ?? TRANSMN(aPom[i,4],cT); ?? cK
        ?? TRANS(nNV,cTU)     ; ?? cK
        ?? TRANSMN(aPom[i,5],cT); ?? cK
        ?? TRANSMN(aPom[i,6],cT); ?? cK
        ?? TRANSMN(aPom[i,7],cT); ?? cK
        ?? TRANS(nOV,cTU)     ; ?? cK
        ?? TRANS(nNV-nOV,cTU) ; ?? cK
        IF lErr; ?? " ERR?!"; ENDIF
      NEXT
      ? "����������������������������������������������������������������������������������������������������������������������������������"
      ?
    ENDIF

    IF !EMPTY(cId)
      EXIT
    ELSE
      SKIP 1
    ENDIF
  ENDDO

  FF
  ENDPRINT

CLOSERET
return
*}



// -----------------------------------------------------------
// vraca niz poddirektorija koji nemaju ekstenziju u nazivu
// a nalaze se u direktoriju cPath (npr. "c:\sigma\fin\kum1\")
// -----------------------------------------------------------
static function ASezona(cPath)
*{
local aSezone
aSezone:=DIRECTORY(cPath+"*.","DV")
for i:=LEN(aSezone) to 1 step -1
    if (aSezone[i,1]=="." .or. aSezone[i,1]=="..")
        ADEL(aSezone,i)
        ASIZE(aSezone,LEN(aSezone)-1)
    endif
next
return aSezone
*}



function TranSMN(x,cT)
*{
return IF(x==0,SPACE(LEN(TRANS(x,cT))),TRANS(x,cT))
*}

