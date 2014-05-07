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


#include "fin.ch"
 
function fin_bb_analitika_b( params )

private A1,D4PS,P4PS,D4TP,P4TP,D4KP,P4KP,D4S,P4S

cIdFirma:=gFirma

O_KONTO
O_PARTN

qqKonto:=space(100)
dDatOd:=dDatDo:=ctod("")
private cFormat:="2",cPodKlas:="N"
Box("",8,60)
 set cursor on
do while .t.
 @ m_x+1,m_y+2 SAY "ANALITICKI BRUTO BILANS"
 if gNW=="D"
   @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| EMPTY(cIdFirma).or.P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+3,m_y+2 SAY "Konto " GET qqKonto PICT "@!S50"
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
BoxC()

cidfirma:=trim(cidfirma)

if cIdRj=="999999"; cidrj:=""; endif
if gRJ=="D" .and. gSAKrIz=="D" .and. "." $ cidrj
  cidrj:=trim(strtran(cidrj,".",""))
  // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
endif

IF cFormat=="1"
 M1:= "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M2:= "*REDNI*   KONTO   *                NAZIV ANALITICKOG KONTA                  *        PO¬ETNO STANJE         *         TEKUI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
 M3:= "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M4:= "*BROJ *           *                                                         *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE  *"
 M5:= "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
ELSE
 M1:= "------ ----------- ---------------------------------------- ------------------------------- ------------------------------- -------------------------------"
 M2:= "*REDNI*   KONTO   *         NAZIV ANALITICKOG KONTA        *        PO¬ETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
 M3:= "                                                            ------------------------------- ------------------------------- -------------------------------"
 M4:= "*BROJ *           *                                        *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE   *    DUGUJE     *   POTRA¦UJE  *"
 M5:= "------ ----------- ---------------------------------------- --------------- --------------- --------------- --------------- --------------- ---------------"
ENDIF

O_BBKLAS
IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  SintFilt(.f.,"IDRJ='"+cIdRJ+"'")
ELSE
  O_ANAL
ENDIF

select BBKLAS; zap

select ANAL

cFilter:=""

if !(empty(qqkonto))
  if !(empty(dDatOd) .and. empty(dDatDo))
    cFilter += ( iif(empty(cFilter),"",".and.") +;
     aUsl1+".and. DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo) )
  else
    cFilter += ( iif(empty(cFilter),"",".and.") + aUsl1 )
  endif
elseif !(empty(dDatOd) .and. empty(dDatDo))
   cFilter += ( iif(empty(cFilter),"",".and.") +;
     "DATNAL>="+cm2str(dDatOd)+" .and. DATNAL<="+cm2str(dDatDo) )
endif

if LEN(cIdFirma)<2
  SELECT ANAL
  Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cFilt := IF( EMPTY(cFilter) , "IDFIRMA="+cm2str(cIdFirma) , cFilter+".and.IDFIRMA="+cm2str(cIdFirma) )
  cSort1:="IdKonto+dtos(DatNal)"
  INDEX ON &cSort1 TO "ANATMP" FOR &cFilt EVAL(fin_tek_rec_2()) EVERY 1
  GO TOP
  BoxC()
else
  SET FILTER TO &cFilter
  HSEEK cIdFirma
endif

EOF CRET

nStr:=0

BBMnoziSaK()

START PRINT CRET

B:=0

D1S:=D2S:=D3S:=D4S:=P1S:=P2S:=P3S:=P4S:=0

D4PS:=P4PS:=D4TP:=P4TP:=D4KP:=P4KP:=D4S:=P4S:=0

nCol1:=50

DO WHILESC !EOF() .AND. IdFirma=cIdFirma

   IF prow()==0; BrBil_21(); ENDIF

   cKlKonto:=left(IdKonto,1)
   D3PS:=P3PS:=D3TP:=P3TP:=D3KP:=P3KP:=D3S:=P3S:=0
   DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cKlKonto==left(IdKonto,1) // kl konto

      cSinKonto:=LEFT(idkonto,3)
      D2PS:=P2PS:=D2TP:=P2TP:=D2KP:=P2KP:=D2S:=P2S:=0
      DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cSinKonto==LEFT(idkonto,3) // sin konto

         cIdKonto:=IdKonto

         D1PS:=P1PS:=D1TP:=P1TP:=D1KP:=P1KP:=D1S:=P1S:=0
         DO WHILESC !EOF() .AND. IdFirma=cIdFirma .AND. cIdKonto==IdKonto // konto
            if cTip==ValDomaca(); Dug:=DugBHD*nBBK; Pot:=PotBHD*nBBK; else; Dug:=DUGDEM; Pot:=POTDEM; endif
            D1KP=D1KP+Dug
            P1KP=P1KP+Pot
            IF IdVN="00"
               D1PS+=Dug; P1PS+=Pot
            ELSE
               D1TP+=Dug; P1TP+=Pot
            ENDIF
            SKIP
         ENDDO   // konto

        @ prow()+1,1 SAY ++B PICTURE '9999';?? "."
        @ prow(),10 SAY cIdKonto

        SELECT KONTO
        HSEEK cIdKonto
        IF cFormat=="1"
         @ prow(),19 SAY naz
        ELSE
         @ prow(),19 SAY PADR(naz,40)
        ENDIF
        select ANAL

        nCol1:=pcol()+1
        @ prow(),pcol()+1 SAY D1PS PICTURE PicD
        @ PROW(),pcol()+1 SAY P1PS PICTURE PicD
        IF cFormat=="1"
         @ PROW(),pcol()+1 SAY D1TP PICTURE PicD
         @ PROW(),pcol()+1 SAY P1TP PICTURE PicD
        ENDIF
        @ PROW(),pcol()+1 SAY D1KP PICTURE PicD
        @ PROW(),pcol()+1 SAY P1KP PICTURE PicD

        D1S=D1KP-P1KP
        IF D1S>=0
           P1S:=0
           D2S+=D1S; D3S+=D1S; D4S+=D1S
        ELSE
           P1S:=-D1S; D1S:=0
           P1S:=P1KP-D1KP
           P2S+=P1S
           P3S+=P1S; P4S+=P1S
        ENDIF
        @ prow(),pcol()+1 SAY D1S PICTURE PicD
        @ prow(),pcol()+1 SAY P1S PICTURE PicD

        D2PS=D2PS+D1PS
        P2PS=P2PS+P1PS
        D2TP=D2TP+D1TP
        P2TP=P2TP+P1TP
        D2KP=D2KP+D1KP
        P2KP=P2KP+P1KP
        IF prow()>65+gpStranica; FF;BrBil_21(); ENDIF

      ENDDO  // sinteticki konto
      IF prow()>61+gpStranica; FF; BrBil_21(); ENDIF

      ? M5
      @ prow()+1,10 SAY cSinKonto
      @ prow(),nCol1    SAY D2PS PICTURE PicD
      @ PROW(),pcol()+1 SAY P2PS PICTURE PicD
      IF cFormat=="1"
       @ PROW(),pcol()+1 SAY D2TP PICTURE PicD
       @ PROW(),pcol()+1 SAY P2TP PICTURE PicD
      ENDIF
      @ PROW(),pcol()+1 SAY D2KP PICTURE PicD
      @ PROW(),pcol()+1 SAY P2KP PICTURE PicD
      @ PROW(),pcol()+1 SAY D2S PICTURE PicD
      @ PROW(),pcol()+1 SAY P2S PICTURE PicD
      ? M5

      D3PS=D3PS+D2PS; P3PS=P3PS+P2PS
      D3TP=D3TP+D2TP; P3TP=P3TP+P2TP
      D3KP=D3KP+D2KP; P3KP=P3KP+P2KP

   ENDDO  // klasa konto

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

   SELECT ANAL

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

IF prow()>61+gpStranica; FF ; BrBil_21(); ENDIF
? M5
? "UKUPNO:"
@ prow(),nCol1    SAY D4PS PICTURE PicD
@ PROW(),pcol()+1 SAY P4PS PICTURE PicD
IF cFormat=="1"
 @ PROW(),pcol()+1 SAY D4TP PICTURE PicD
 @ PROW(),pcol()+1 SAY P4TP PICTURE PicD
ENDIF
@ PROW(),pcol()+1 SAY D4KP PICTURE PicD
@ PROW(),pcol()+1 SAY P4KP PICTURE PicD
@ PROW(),pcol()+1 SAY D4S PICTURE PicD
@ PROW(),pcol()+1 SAY P4S PICTURE PicD
? M5

if prow()>55+gpStranica; FF; else; ?;?; endif

?? "REKAPITULACIJA PO KLASAMA NA DAN: ";?? DATE()
?  M6
?  M7
?  M8
?  M9
?  M10

select BBKLAS; go top


nPocDug:=nPocPot:=nTekPDug:=nTekPPot:=nKumPDug:=nKumPPot:=nSalPDug:=nSalPPot:=0

DO WHILESC !EOF()
   @ prow()+1,4   SAY IdKlasa
   @ prow(),10       SAY PocDug               PICTURE PicD
   @ PROW(),pcol()+1 SAY PocPot               PICTURE PicD
   @ PROW(),pcol()+1 SAY TekPDug              PICTURE PicD
   @ PROW(),pcol()+1 SAY TekPPot              PICTURE PicD
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

? M10
? "UKUPNO:"
@ prow(),10       SAY  nPocDug    PICTURE PicD
@ PROW(),pcol()+1 SAY  nPocPot    PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nTekPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nKumPPot   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPDug   PICTURE PicD
@ PROW(),pcol()+1 SAY  nSalPPot   PICTURE PicD
? M10

FF

END PRINT

closeret
return


/*! \fn BrBil_21()
 *  \brief Zaglavlje analitickog bruto bilansa
 */
 
function BrBil_21()
?
P_COND2
?? "FIN: ANALITI¬KI BRUTO BILANS U VALUTI '"+TRIM(cBBV)+"'"
if !(empty(dDatod) .and. empty(dDatDo))
    ?? " ZA PERIOD OD",dDatOd,"-",dDatDo
endif
?? " NA DAN: "; ?? DATE()
@ prow(), IF(cFormat=="1",220,142) SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 select PARTN
 HSEEK  cIdFirma
 ? "Firma:",cIdFirma,partn->naz,partn->naz2
endif

IF gRJ=="D" .and. gSAKrIz=="D" .and. LEN(cIdRJ)<>0
  ? "Radna jedinica ='"+cIdRj+"'"
ENDIF

select ANAL

? M1
? M2
? M3
? M4
? M5
RETURN


