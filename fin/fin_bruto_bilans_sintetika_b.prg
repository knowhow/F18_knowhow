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



function SintBB()

local nPom

cIdFirma:=gFirma

O_PARTN
Box("",8,60)
set cursor on
qqKonto:=space(100)
dDatOd:=dDatDo:=ctod("")
private cFormat:="2",cPodKlas:="N"

do while .t.
 @ m_x+1,m_y+2 SAY "SINTETICKI BRUTO BILANS"
 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma " GET cIdFirma valid {|| empty(cIdFirma) .or. P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Konto " GET qqKonto    pict "@!S50"
 @ m_x+4,m_y+2 SAY "Od datuma :" get dDatOD
 @ m_x+4,col()+2 SAY "do" GET dDatDo
 @ m_x+6,m_y+2 SAY "Format izvjestaja A3/A4 (1/2)" GET cFormat
 @ m_x+7,m_y+2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas$"DN" PICT "@!"
 cIdRJ:=""
 IF gRJ=="D" .and. gSAKrIz=="D"
   cIdRJ:="999999"
   @ m_x+8,m_y+2 SAY "Radna jedinica (999999-sve): " GET cIdRj
 ENDIF
 READ; ESC_BCR
 aUsl1:=Parsiraj(qqKonto,"IdKonto")
 if aUsl1<>NIL; exit; endif
enddo

cidfirma:=trim(cidfirma)

BoxC()

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

if cFormat=="1"
 M1:= "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M2:= "*REDNI*   KONTO   *                  NAZIV SINTETICKOG KONTA                *        PO¬ETNO STANJE         *         TEKUI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
 M3:= "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M4:= "*BROJ *           *                                                         *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE  *"
 M5:= "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
else
 M1:= "---- ------------------------------ ------------------------------- ------------------------------- -------------------------------"
 M2:= "    *                              *        PO¬ETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
 M3:= "    *    SINTETI¬KI KONTO           ------------------------------- ------------------------------- -------------------------------"
 M4:= "    *                              *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE  *"
 M5:= "---- ------------------------------ --------------- --------------- --------------- --------------- --------------- ---------------"
endif


O_KONTO
O_BBKLAS

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  SintFilt(.t.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_SINT
ENDIF

select BBKLAS; ZAP
select SINT
cFilter:=""
if !(empty(qqkonto))
  if !(empty(dDatOd) .and. empty(dDatDo))
    cFilter:=aUsl1+".and. DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
  else
    cFilter:=aUsl1
  endif
elseif !(empty(dDatOd) .and. empty(dDatDo))
  cFilter:="DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo)
endif

if LEN(cIdFirma)<2
  SELECT SINT
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
  cSort1:="IdKonto+dtos(DatNal)"
  INDEX ON &cSort1 TO "SINTMP" FOR &cFilt EVAL(fin_tek_rec_2()) EVERY 1
  GO TOP
  BoxC()
else
  IF !EMPTY(cFilter)
    SET FILTER TO &cFilter
  ENDIF
  HSEEK cIdFirma
endif

EOF CRET


nStr:=0

BBMnoziSaK()

START PRINT CRET

B:=1

D1S:=D2S:=D3S:=D4S:=P1S:=P2S:=P3S:=P4S:=0


D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=D4S:=P4S:=0
nStr:=0

nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma

   IF prow()==0; BrBil_31(); ENDIF

   cKlKonto:=left(IdKonto,1)

   D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
   DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1)

      cIdKonto:=IdKonto
      D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
      DO WHILESC !eof() .and. IdFirma=cIdFirma .AND. cIdKonto==left(IdKonto,3)
         if cTip==ValDomaca(); Dug:=DugBHD*nBBK; Pot:=PotBHD*nBBK; else; Dug:=DUGDEM; Pot:=POTDEM; endif
         D1KP+=Dug
         P1KP+=Pot
         IF IdVN="00"
            D1PS+=Dug; P1PS+=Pot
         ELSE
            D1TP+=Dug; P1TP+=Pot
         ENDIF
         SKIP
      ENDDO // konto

      IF prow()>63+gpStranica; FF ; BrBil_31(); endif

      if cFormat=="1"
       @ prow()+1,1 SAY B PICTURE '9999'; ?? "."
       @ prow(),10 SAY cIdKonto
       select KONTO
       HSEEK cIdKonto
       @ prow(),19 SAY naz
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY D1PS PICTURE PicD
       @ prow(),pcol()+1 SAY P1PS PICTURE PicD
       @ prow(),pcol()+1 SAY D1TP PICTURE PicD
       @ prow(),pcol()+1 SAY P1TP PICTURE PicD
       @ prow(),pcol()+1 SAY D1KP PICTURE PicD
       @ prow(),pcol()+1 SAY P1KP PICTURE PicD
       D1S:=D1KP-P1KP
       IF D1S>=0
         P1S:=0; D3S+=D1S; D4S+=D1S
       ELSE
         P1S:=-D1S; D1S:=0
         P3S+=P1S; P4S+=P1S
       ENDIF
       @ prow(),pcol()+1 SAY D1S PICTURE PicD
       @ prow(),pcol()+1 SAY P1S PICTURE PicD

      else  // cformat=="2" - A4

       @ prow()+1,1 SAY cIdKonto
       select KONTO
       HSEEK cIdKonto

       private aRez:=SjeciStr(naz,30)
       private nColNaz:=pcol()+1
       @ prow(),pcol()+1 SAY padr(aRez[1],30)
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY D1PS PICTURE PicD
       @ prow(),pcol()+1 SAY P1PS PICTURE PicD
       @ prow(),pcol()+1 SAY D1KP PICTURE PicD
       @ prow(),pcol()+1 SAY P1KP PICTURE PicD
       D1S:=D1KP-P1KP
       IF D1S>=0
         P1S:=0; D3S+=D1S; D4S+=D1S
       ELSE
         P1S:=-D1S; D1S:=0
         P3S+=P1S; P4S+=P1S
       ENDIF
       @ prow(),pcol()+1 SAY D1S PICTURE PicD
       @ prow(),pcol()+1 SAY P1S PICTURE PicD

       if len(aRez)==2
        @ prow()+1,nColNaz SAY padr(aRez[2],30)
       endif
      endif // cformat

      SELECT SINT
      D3PS+=D1PS; P3PS+=P1PS; D3TP+=D1TP; P3TP+=P1TP; D3KP+=D1KP; P3KP+=P1KP

      ++B


   ENDDO // klasa konto

   SELECT BBKLAS
   APPEND BLANK
   REPLACE IdKlasa WITH cKlKonto,;
           PocDug  WITH D3PS,;
           PocPot  WITH P3PS,;
           TekPDug WITH D3TP,;
           TekPPot WITH P3TP,;
           KumPDug WITH D3KP,;
           KumPPot WITH P3KP,;
           SalPDug WITH D3S,;
           SalPPot WITH P3S

   SELECT SINT

   IF cPodKlas=="D"
    ? M5
    ? "UKUPNO KLASA "+cklkonto
    @ prow(),nCol1    SAY D3PS PICTURE PicD
    @ PROW(),pcol()+1 SAY P3PS PICTURE PicD
    if cFormat=="1"
      @ PROW(),pcol()+1 SAY D3TP PICTURE PicD
      @ PROW(),pcol()+1 SAY P3TP PICTURE PicD
    endif
    @ PROW(),pcol()+1 SAY D3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY P3KP PICTURE PicD
    @ PROW(),pcol()+1 SAY D3S PICTURE PicD
    @ PROW(),pcol()+1 SAY P3S PICTURE PicD
    ? M5
   ENDIF
   D4PS+=D3PS; P4PS+=P3PS; D4TP+=D3TP; P4TP+=P3TP; D4KP+=D3KP; P4KP+=P3KP

ENDDO

IF prow()>58+gpStranica; FF ; BrBil_31(); endif
? M5
? "UKUPNO:"
@ prow(),nCol1    SAY D4PS PICTURE PicD
@ PROW(),pcol()+1 SAY P4PS PICTURE PicD
if cFormat=="1"
 @ PROW(),pcol()+1 SAY D4TP PICTURE PicD
 @ PROW(),pcol()+1 SAY P4TP PICTURE PicD
endif
@ PROW(),pcol()+1 SAY D4KP PICTURE PicD
@ PROW(),pcol()+1 SAY P4KP PICTURE PicD
@ PROW(),pcol()+1 SAY D4S PICTURE PicD
@ PROW(),pcol()+1 SAY P4S PICTURE PicD
? M5
nPom:=d4ps-p4ps
@ prow()+1,nCol1   SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD

nPom:=d4tp-p4tp
if cFormat=="1"
 @ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
 @ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
endif

nPom:=d4kp-p4kp
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
nPom:=d4s-p4s
@ PROW(),pcol()+1 SAY iif(nPom>0,nPom,0) PICTURE PicD
@ PROW(),pcol()+1 SAY iif(nPom<0,-nPom,0) PICTURE PicD
? M5

FF

?? "REKAPITULACIJA PO KLASAMA NA DAN: "; ?? DATE()
? IF(cFormat=="1", M6, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")
? IF(cFormat=="1", M7, "*        *          PO¬ETNO STANJE       *        KUMULATIVNI PROMET     *            SALDO             *")
? IF(cFormat=="1", M8, "  KLASA   ------------------------------- ------------------------------- -------------------------------")
? IF(cFormat=="1", M9, "*        *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *     DUGUJE    *    POTRA¦UJE *")
? IF(cFormat=="1",M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")

select BBKLAS; go top


nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()
   @ prow()+1,4      SAY IdKlasa
   @ prow(),10       SAY PocDug               PICTURE PicD
   @ PROW(),pcol()+1 SAY PocPot               PICTURE PicD
   if cFormat=="1"
    @ PROW(),pcol()+1 SAY TekPDug              PICTURE PicD
    @ PROW(),pcol()+1 SAY TekPPot              PICTURE PicD
   endif
   @ PROW(),pcol()+1 SAY KumPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY KumPPot              PICTURE PicD
   @ PROW(),pcol()+1 SAY SalPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY SalPPot              PICTURE PicD

   nPocDug   += PocDug
   nPocPot   += PocPot
   nTekPDug  += TekPDug
   nTekPPot  += TekPPot
   nKumPDug  += KumPDug
   nKumPPot  += KumPPot
   nSalPDug  += SalPDug
   nSalPPot  += SalPPot
   SKIP
ENDDO

? IF(cFormat=="1",M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")
? "UKUPNO:"
@ prow(),10       SAY  nPocDug    PICTURE PicD
@ PROW(),pcol()+1 SAY  nPocPot    PICTURE PicD
if cFormat=="1"
 @ PROW(),pcol()+1 SAY  nTekPDug   PICTURE PicD
 @ PROW(),pcol()+1 SAY  nTekPPot   PICTURE PicD
endif
@ PROW(),pcol()+1 SAY  nKumPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPPot   PICTURE PicD
? IF(cFormat=="1",M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------")

FF

END PRINT
closeret
return




/*! \fn BrBil_31()
 *  \brief Zaglavlje sintetickog bruto bilansa
 */

function BrBil_31()
?
P_COND2
?? "FIN: SINTETICKI BRUTO BILANS U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? "  NA DAN: "; ?? DATE()
@ prow(),125 SAY "Str."+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

select SINT
? M1
? M2
? M3
? M4
? M5
RETURN


