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


#include "mat.ch"


function mat_inventura()


local opc[5],Izbor

private PicDEM:="99999999.99"
private PicBHD:="9999999999.99"
private PicKol:="9999999.99"

opc[1]:="1. unos,ispravka stvarnih kolicina  "
opc[2]:="2. pregled unesenih kolicina"
opc[3]:="3. obracun inventure"
opc[4]:="4. mat_nalog sravnjenja"
opc[5]:="5. inventura - obrac r.por"

h[1]:="Unos, ispravka, brisanje stvarnih kolicina sa popisnih lista..."
Izbor:=1
DO WHILE .T.
   Izbor:=Menu("invnt",opc,Izbor,.f.)
   do case
      case izbor == 0
         exit
      case izbor == 1
         UnosPopL()
      case izbor == 2
         PreglUnKol()
      case izbor == 3
         ObracInv()
      case izbor == 4
         NalInv()
      case izbor == 5
         matpormp()
   endcase
enddo
closeret

***************************
***************************
function UnosPopL()
private opc[3],Izbor
opc[1]:="1. ispravka stvarnih kolicina sa popisnih lista"
opc[2]:="2. automatsko formiranje datoteke"
opc[3]:="3. popisna lista za inventarisanje  "
Izbor:=1
DO WHILE .T.
   Izbor:=Menu("bedpl",opc,Izbor,.f.)
   do case
      case izbor==0
         exit
      case izbor == 2
         AutFDat()
      case izbor == 1
         UnEdStvKol()
      case izbor==3
         PopL()
   endcase
enddo
closeret

*****************************
*****************************
function AutFDat()

cIdF:=gFirma
cIdK:=SPACE(7)
cIdD:=date()
if file(PRIVPATH+"invent.mem")
     restore from (PRIVPATH+"invent.mem") additive
endif

O_KONTO
O_PARTN

Box("",4,60,.f.)
@ m_x+1,m_y+2 SAY "AUTOMATSKO FORMIRANJE DATOTEKE"
if gNW$"DR"
  @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdF valid {|| P_Firma(@cIdF),cidf:=left(cidf,2),.t.}
endif
@ m_x+3,m_y+2 SAY "Konto " GET cIdK valid P_Konto(@cIdK)
@ m_x+4,m_y+2 SAY "Datum " GET cIdD
READ; ESC_BCR
BoxC()
cIdF:=left(cIdF,2)
save to  (PRIVPATH+"invent.mem") all like cId?

O_INVENT
O_MAT_SUBAN

select INVENT; ZAP

nRBr:=nKolicina:=nIznos:=nCijena:=0
SELECT mat_suban
#ifndef C50
set order to tag "3"
#else
set order to 3
#endif
set filter to DatDok<=cIdD
SEEK cIdF+cIdK
NFOUND CRET

DO WHILE !eof() .AND. cIdF=IdFirma .and. cIdK==Idkonto

   cIdRoba:=IdRoba
   nKolicina:=nIznos:=nIznos2:=0
   DO WHILE !eof() .AND. cIdF==IdFirma .AND. cIdK==IdKonto .and. cIdRoba==IdRoba
      IF D_P="1"
         nKolicina+=Kolicina
      ELSE
         nKolicina-=Kolicina
      ENDIF
      IF D_P="1"
         nIznos+=Iznos
         nIznos2+=Iznos2
      ELSE
         nIznos-=Iznos
         nIznos2-=Iznos2
      ENDIF
    SKIP
   ENDDO
   IF round(nKolicina,4) <> 0 // nKolicina<>0
      nCijena:=nIznos/nKolicina
      select INVENT
      APPEND BLANK
      REPLACE ;  //     IdFirma WITH cIdF,IdOrgJed WITH cIdOrgJed,;
           IdRoba WITH cIdRoba,;
           RBr with str(++nRBr,4),Kolicina WITH nKolicina,;
           Cijena WITH nCijena,;
           Iznos with nIznos, Iznos2 with nIznos2
   ELSEIF round(nIznos,4) <> 0 // Postoji finansijsko stanje -  kalo itd
      nCijena:=0
      select INVENT
      APPEND BLANK
      REPLACE ;  //     IdFirma WITH cIdF,IdOrgJed WITH cIdOrgJed,;
           IdRoba WITH cIdRoba,;
           RBr with str(++nRBr,4),Kolicina WITH nKolicina,;
           Cijena WITH nCijena,;
           Iznos with nIznos, Iznos2 with nIznos2
   ENDIF
   SELECT mat_suban
ENDDO
closeret

******************************
******************************
Function UnEdStvKol()

O_INVENT
O_ROBA
O_SIFV
O_SIFK
O_PARTN

SELECT INVENT; GO TOP
#ifndef C50
set order to tag "1"
#else
set order to 1
#endif

ImeKol:={ ;
          {"R.br",{|| rbr}          },;
          {"Roba",{|| idroba}       },;
          {"Cijena",{|| Cijena}     },;
          {"Kolicina",{|| Kolicina} },;
          {"Iznos "+ValPomocna(),{|| iznos}      },;
          {"Iznos "+ValDomaca(),{|| iznos2}      };
        }

Kol:={}; for i:=1 to 5; AADD(Kol,i); next
ObjDbedit("USKSP",20,77,{|| EdPopList()},"³<c-T> BriSt³<ENT> IsprSt³<c-A> IsprSvih³<c-N> NoveSt³<c-Z> BrisiSve³","Pregled popisne liste...")
closeret

**************************
**************************
function EdPopList()

do case
  case Ch==K_ENTER .or. Ch==K_CTRL_N
     fNew:=.f.; if Ch==K_CTRL_N; append blank; endif
     Scatter()
     Box("edpopl",6,70,.f.,"Stavka popisne liste")
     set cursor on
     nRbr:=VAL(_Rbr)
     GetPL()
     READ
     _Rbr:=STR(nRbr,4)
   BoxC()
   if lastkey()==K_ESC
     if Ch==K_CTRL_N; delete; endif
     return DE_CONT
   endif
   Gather()
   return DE_REFRESH

 case Ch==K_CTRL_A
   go top
   Box("edpopl",6,70,.f.,"Ispravka popisne liste..")
   do while !eof()
     Scatter()
     set cursor on
     nRbr:=VAL(_Rbr)
     GetPL()
     READ
     _Rbr:=STR(nRbr,4)
     if lastkey()==K_ESC
       BoxC(); return DE_REFRESH
     endif
     Gather()
     if lastkey()==K_PGUP
       skip -1
     else
       skip
     endif
   enddo
   BoxC()
   skip -1
   return DE_REFRESH
 case Ch==K_CTRL_T
   if Pitanje("ppl","Zelite izbrisati ovu stavku (D/N) ?","N")=="D"
     delete; return DE_REFRESH
   endif
   return DE_CONT
 case Ch==K_CTRL_Z
   if Pitanje("ppl","Zelite sve stavke (D/N) !!!!????","N")=="D"
     zap;go top; return DE_REFRESH
   endif
   return DE_CONT

endcase
return DE_CONT

***********************
***********************   
function GETPL()
@ m_x+1,m_y+2 SAY "Red.br:  " GET nRBr  PICTURE "9999"
@ m_x+3,m_y+2 SAY "Roba:    " GET _IdRoba valid P_Roba(@_IdRoba,3,24)
@ m_x+4,m_y+2 SAY "Cijena:  " GET _Cijena  PICTURE PicDEM
@ m_x+5,m_y+2 SAY "Kolicina:" GET _Kolicina PICTURE PicKol ;
   VALID {|| _Iznos:=_Cijena*_Kolicina, qqout("  Iznos:",TRANSFORM(_iznos,PicDEM)),Inkey(5),.t.}
return


**************************
**************************
function PreglUnKol()

O_INVENT
O_ROBA
O_SIFV
O_SIFK
O_KONTO
O_PARTN

cIdF:=gFirma
cIdK:=SPACE(7)
cIdD:=date()
if file(PRIVPATH+"invent.mem")
     restore from (PRIVPATH+"invent.mem") additive
endif
Box("",4,60,.f.)
@ m_x+1,m_y+6 SAY  "PREGLED UNESENIH KOLICINA"
if gNW$"DR"
  @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdF valid {|| P_Firma(@cIdF),cidf:=left(cidf,2),.t.}
endif
@ m_x+3,m_y+2 SAY "Konto " GET cIdK valid P_Konto(@cIdK)
@ m_x+4,m_y+2 SAY "Datum " GET cIdD
READ
BoxC(); ESC_RETURN 0
cIdF:=left(cIdF,2)
save to  (PRIVPATH+"invent.mem") all like cId?

SELECT INVENT
#ifndef C50
set order to tag "1"
#else
set order to 1
#endif
GO TOP

START PRINT  CRET

nRBr:=0

m:="---- ---------- ---------------------------------------- --- ---------- ------------ -------------"

ZPrUnKol()
nU:=0
nC1:=60
DO WHILE !eof()

      if prow()>62; EJECTA0; ZPrUnKol(); ENDIF

      select ROBA; HSEEK INVENT->IdRoba; select invent

      @ prow()+1,0 SAY ++nRBr PICTURE '9999'
      @ prow(),pcol()+1 SAY IdRoba
      @ prow(),pcol()+1 SAY roba->naz
      @ prow(),pcol()+1 SAY roba->jmj
      @ prow(),pcol()+1 SAY Kolicina PICTURE '999999.999'
      @ prow(),pcol()+1 SAY Cijena PICTURE '99999999.999'
      nC1:=pcol()+1
      @ prow(),pcol()+1 SAY nIznos:=Cijena*kolicina PICTURE '999999999.99'
      nU+=nIznos
      SKIP
ENDDO
if prow()>60; EJECTA0; ZPrUnKol(); ENDIF
? m
? "UKUPNO:"
@ prow(),nC1 SAY nU PICTURE '999999999.99'
? m
EJECTA0
END  PRINT
closeret
****************************
****************************
function ZPrUnKol()
P_COND
@ prow(),0 SAY "MAT.P: PREGLED UNESENIH KOLICINA NA DAN:"; @ prow(),pcol()+1 SAY cIdD
@ prow()+1,0 SAY "Firma:"; @ prow(),pcol()+1 SAY cIdF
SELECT PARTN; HSEEK cIdF
@ prow(),pcol()+1 SAY naz; @ prow(),pcol()+1 SAY naz2

select KONTO; HSEEK cIdK
? "Konto: ",cIdK, naz

SELECT INVENT
? m
? "*R. *  SIFRA   *         NAZIV ARTIKLA                  *J. * KOLICINA *   CIJENA   *   IZNOS    *"
? "*B. * ARTIKLA  *                                        *MJ.*          *            *            *"
? m



*******************************************
*******************************************
function ObracInv()

cIdF:=gFirma
cIdK:=SPACE(7)
cIdD:=date()
if file(PRIVPATH+"invent.mem")
     restore from (PRIVPATH+"invent.mem") additive
endif
cIdF:=left(cIdF,2)

O_PARTN; O_KONTO
Box("",4,60)
@ m_x+1,m_y+6 SAY "OBRACUN INVENTURE"
if gNW$"DR"
  @ m_x+2,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+2,m_y+2 SAY "Firma: " GET cIdF valid {|| P_Firma(@cIdF),cidf:=left(cidf,2),.t.}
endif
@ m_x+3,m_y+2 SAY "Konto  " GET cIdK valid P_Konto(@cIdK)
@ m_x+4,m_y+2 SAY "Datum  " GET cIdD
READ; ESC_BCR
BoxC()
save to  (PRIVPATH+"invent.mem") all like cId?

picD:='@Z 99999999999.99'
picD1:='@Z 99999999.99'
picK:='@Z 99999.99'

O_INVENT
O_ROBA
O_SIFV
O_SIFK
O_MAT_SUBAN
#ifndef C50
set order to tag "3"
#else
set order to 3
#endif
set filter to DatDok<=cIdD

SELECT INVENT; go top

START PRINT CRET

A:=0

nRBr:=0
SK:=SV:=0
KK:=KV:=0
VK:=VV:=MK:=MV:=0

SV1:=KV1:=0
VV1:=MV1:=0

DO WHILE !eof()

   IF A==0
      P_COND
      @ A,0 SAY "MAT.P:INVENTURNA LISTA NA DAN:"; @ A,pcol()+1 SAY cIdD
      @ ++A,0 SAY "Firma:"
      @ A,pcol()+1 SAY cIdF
      SELECT PARTN; HSEEK cIdF
      @ A,pcol()+1 SAY naz; @ A,pcol()+1 SAY naz2

      @ ++A,0 SAY "KONTO:"
      @ A,pcol()+1 SAY cIdK
      SELECT KONTO; HSEEK cIdK
      @ A,pcol()+1 SAY naz
      select INVENT
      A+=2
      @ ++A,0 SAY "---- ---------- -------------------- --- ---------- -------------------- -------------------- -------------------- ---------------------"
      @ ++A,0 SAY "*R. *  SIFRA   *  NAZIV ARTIKLA     *J. *  CIJENA  *   STVARNO STANJE   *   KNJIZNO STANJE   *   RAZLIKA VISAK    *   RAZLIKA MANJAK   *"
      @ ++A,0 SAY "                                                    -------------------- -------------------- -------------------- ---------------------"
      @ ++A,0 SAY "*B. * ARTIKLA  *                    *MJ.*          *KOLICINA*   IZNOS   *KOLICINA*   IZNOS   *KOLICINA*   IZNOS   *KOLICINA*   IZNOS   *"
      @ ++A,0 SAY "---- ---------- -------------------- --- ---------- -------- ----------- -------- ----------- -------- ----------- -------- ------------"
   ENDIF

   IF A>63; EJECTA0;  ENDIF

   SK:=Kolicina; SV:=Iznos

   cIdRoba:=IdRoba
   select mat_suban
   SEEK cIdF+cIdK+cIdRoba
   kK:=kV:=0         // KK - knjizena kolicina, KV - knjizena vrijednost
   DO WHILE !eof() .AND. cIdF=IdFirma .AND. cIdK=IdKonto .AND. cIdRoba=IdRoba
      IF D_P="1"; kK+=Kolicina; ELSE; kK-=Kolicina; ENDIF
      IF D_P="1"; kV+=Iznos; ELSE; kV-=Iznos; ENDIF
     SKIP
   ENDDO



   RK:=SK-KK
   RV:=SV-KV

   VK:=MK:=0
   If RK>=0; VK:=RK; ELSE; MK:=-RK; ENDIF
   VV:=MV:=0
   If RV>=0; VV:=RV; ELSE; MV:=-RV; ENDIF


   @ ++A,0 SAY ++nRBr PICTURE "9999"
   @ A,5 SAY cIdRoba
   select ROBA; HSEEK cIdRoba
   @ A,16 SAY Naz PICTURE replicate ("X",20)
   @ A,37 SAY jmj
   select INVENT
   @ A,40       SAY  Cijena PICTURE picD1
   @ A,pcol()+1 SAY  round(SK,2) PICTURE picK
   @ A,pcol()+1 SAY  round(SV,2) PICTURE picD1
   @ A,pcol()+1 SAY  round(KK,2)  PICTURE picK
   @ A,pcol()+1 SAY  round(KV,2) PICTURE picD1
   @ A,pcol()+1 SAY  round(VK,2) PICTURE picK
   @ A,pcol()+1 SAY  round(VV,2) PICTURE picD1
   @ A,pcol()+1 SAY  round(MK,2) PICTURE picK
   @ A,pcol()+1 SAY  round(MV,2) PICTURE picD1

   SKIP
   SV1+=SV; KV1+=KV
   VV1+=VV; MV1+=MV

ENDDO

@ ++A,0 SAY "---- ---------- -------------------- --- ---------- -------- ----------- -------- ----------- -------- ----------- -------- ------------"
@ ++A,0 SAY "UKUPNO:"
@ a,40       SAY 0 PICTURE PicD1
@ A,pcol()+1 SAY 0 PICTURE picK
@ A,pcol()+1 SAY round(SV1,2) PICTURE picD1
@ A,pcol()+1 SAY 0 PICTURE PicK
@ A,pcol()+1 SAY round(KV1,2) PICTURE picD1
@ A,pcol()+1 SAY 0 PICTURE PicK
@ A,pcol()+1 SAY round(VV1,2) PICTURE picD1
@ A,pcol()+1 SAY 0 PICTURE PicK
@ A,pcol()+1 SAY round(MV1,2) PICTURE picD1
@ ++A,0 SAY "---- ---------- -------------------- --- ---------- -------- ----------- -------- ----------- -------- ----------- -------- ------------"

EJECTNA0
END PRINT
closeret


*******************************************
*******************************************
function NalInv()

cIdF:=gFirma
cIdK:=SPACE(7)
cIdD:=date()
if file(PRIVPATH+"invent.mem")
     restore from (PRIVPATH+"invent.mem") additive
endif
cIdF:=left(cIdF,2)
cIdZaduz:=space(6)
cidvn:="  "; cBrNal:=space(4)
cIdTipDok:="09"
O_PARTN; O_KONTO
Box("",7,60)
@ m_x+1,m_y+6 SAY "FORMIRANJE mat_nalogA IZLAZA - USAGLASAVANJE"
@ m_x+2,m_y+6 SAY "KNJIZNOG I STVARNOG STANJA"
@ m_x+4,m_y+2 SAY "Nalog  " GET cIdF
@ m_x+4,col()+2 SAY "-" GET cIdVN
@ m_x+4,col()+2 SAY "-" GET cBrNal
@ m_x+4,col()+4 SAY "Datum  " GET cIdD
@ m_x+5,m_y+2 SAY "Tip dokumenta" GET cIdTipDok
@ m_x+6,m_y+2 SAY "Konto  " GET cIdK valid P_Konto(@cIdK)
@ m_x+7,m_y+2 SAY "Zaduzuje" GET cIdZaduz valid empty(@cIdZaduz) .or. P_Firma(@cIdZaduz)
READ; ESC_BCR

BoxC()
save to  (PRIVPATH+"invent.mem") all like cId?

picD:='@Z 99999999999.99'
picD1:='@Z 99999999.99'
picK:='@Z 99999.99'

O_VALUTE
O_MAT_PRIPR
O_INVENT
O_ROBA
O_SIFV
O_SIFK
O_MAT_SUBAN
#ifndef C50
set order to tag "3"
#else
set order to 3
#endif
set filter to DatDok<=cIdD

SELECT INVENT; go top


A:=0

nRBr:=0
SK:=SV:=0
KK:=KV:=0
VK:=VV:=MK:=MV:=0

SV1:=KV1:=0
VV1:=MV1:=0

nRbr:=0
KursLis:="1"

DO WHILE !eof()


   SK:=Kolicina; SV:=Iznos

   cIdRoba:=IdRoba
   select mat_suban
   SEEK cIdF+cIdK+cIdRoba
   kK:=kV:=0         // KK - knjizena kolicina, KV - knjizena vrijednost
   DO WHILE !eof() .AND. cIdF=IdFirma .AND. cIdK=IdKonto .AND. cIdRoba=IdRoba
      IF D_P="1"; kK+=Kolicina; ELSE; kK-=Kolicina; ENDIF
      IF D_P="1"; kV+=Iznos; ELSE; kV-=Iznos; ENDIF
     SKIP
   ENDDO



   RK:=KK-SK
   RV:=KV-SV
   nCj:=0
   if round(rk,3)<>0; nCj:=rv/rk;endif

   if round(rk,3)<>0 .or. round(rv,3)<>0
    select mat_pripr
    append blank
    replace idfirma with cidf, idvn with cidvn, brnal with cbrnal,;
            idkonto with cidk, rbr with str(++nRbr,3), ;
            idzaduz with cidzaduz,;
            idroba with cidroba, u_i with "2", d_p with "2",;
            kolicina with rk, cijena with nCj, iznos with rv,;
            iznos2 with iznos*Kurs(cIdD),;
            datdok with cidD, datkurs with cidd,;
            idtipdok with cIdTipDok

   endif

   select INVENT
   skip
ENDDO

closeret


*******************************************
* prenos iz materijalnog u obracun  poreza
*******************************************
function matpormp()
local cIdDir

cIdF:=gFirma
cIdK:=SPACE(7)
cIdD:=date()
cIdX:=space(35)
if file(PRIVPATH+"invent.mem")
     restore from (PRIVPATH+"invent.mem") additive
endif
cIdF:=left(cIdF,2)
cIdX:=padr(cIdX,35)
cIdZaduz:=space(6)
cidvn:="  "; cBrNal:=space(4)
cIdTipDok:="09"
O_TARIFA; O_KONTO
O_INVENT
O_SIFV
O_SIFK
O_ROBA
nMjes:=month(cIdD)
Box("",7,60)
@ m_x+1,m_y+6 SAY "PRENOS INV. STANJA U OBRACUN POREZA MP"
@ m_x+5,m_y+2 SAY "Mjesec " GET  nMjes pict "99"
@ m_x+6,m_y+2 SAY "Konto  " GET cIdK valid P_Konto(@cIdK)
READ; ESC_BCR
BoxC()

save to  (PRIVPATH+"invent.mem") all like cId?

cIdDir:=gDirPor

use (ciddir+"pormp") new index (ciddir+"pormpi1"), (ciddir+"pormpi2"), (ciddir+"pormpi3")
set order to 3           // str(mjesec,2)+idkonto+idtarifa+id

SELECT INVENT; go top

DO WHILE !eof()

   select roba; hseek invent->idroba; select tarifa; hseek roba->idtarifa
   select invent
   nMPVSAPP:=kolicina*cijena
   if nMPVSAPP==0; skip; loop; endif
   nMPV:=nMPVSAPP/(1+tarifa->ppp/100)/(1+tarifa->opp/100)
   select pormp
   seek str(nmjes,2)+cidk+roba->idtarifa+"3. SAD.INVENT"
   if !found()
        append blank
   endif
   replace id with "3. SAD.INVENT",;
           mjesec  with nmjes,;
           idkonto with cIDK,;
           idtarifa with roba->IdTarifa,;
           znak with "-",;
           MPV      with MPV-nMPV,;
           MPVSaPP  with MPVSaPP-nMPVSAPP
   seek str(nmjes+1,2)+cidk+roba->idtarifa+"1. PREDH INV."   // sljedeci mjesec
   if !found()
        append blank
   endif
   replace id with "1. PREDH INV.",;
           mjesec  with nmjes+1,;
           idkonto with cIDK,;
           idtarifa with roba->IdTarifa,;
           znak with "+",;
           MPV      with MPV+nMPV,;
           MPVSaPP  with MPVSaPP+nMPVSAPP


   select INVENT
   skip
ENDDO

closeret

*****************************
*****************************
function PopL()
I:=K:=C:=0
*
m:="---- ---------- ----------------------------------- --- ------------ ---------"
*
cIdF:="  "
cIdK:=SPACE(7)
cIdD:=date()
if file(PRIVPATH+"invent.mem")
     restore from (PRIVPATH+"invent.mem") additive
endif
cIdF:=left(cIdF,2)
O_KONTO; O_PARTN
Box("",4,60)
@ m_x+1,m_y+6 SAY "OBRACUN INVENTURE - POPISNA LISTA"
@ m_x+2,m_y+2 SAY "Firma  " GET cIdF valid P_Firma(@cIdF)
@ m_x+3,m_y+2 SAY "Konto  " GET cIdK valid P_Konto(@cIdK)
@ m_x+4,m_y+2 SAY "Datum inventure " GET cIdD
READ; ESC_BCR
BoxC()
save to  (PRIVPATH+"invent.mem") all like cId?
*
O_MAT_SUBAN
O_SIFV
O_SIFK
O_ROBA

SELECT mat_suban
#ifndef C50
set order to tag "3"
#else
set order to 3
#endif
set filter to DatDok<=cIdD
SEEK cIdF+cIdK
NFOUND CRET

START PRINT CRET

A:=B:=0
DO WHILE !eof() .AND. cIdF=IdFirma .and. cIdK==IdKonto
   IF A==0
      @ A,0 SAY "MAT.P: POPISNA LISTA ZA INVENTARISANJE NA DAN:"; @ A,pcol()+1 SAY cIdD
      @ ++A,0 SAY "FIRMA:"; @ A,pcol()+1 SAY cIdF
      SELECT PARTN; HSEEK cIdF
      @ A,pcol()+2 SAY naz; @ A,pcol()+2 SAY naz2

      @ ++A,0 SAY "KONTO:"; @ A,pcol()+1 SAY cIdK
      SELECT KONTO; HSEEK cIdK
      @ A,pcol()+2 SAY naz
      @ ++A,0 SAY m
      @ ++A,0 SAY "*R. *  SIFRA   *          NAZIV ARTIKLA            *J. *   CIJENA   *KOLICINA*"
      @ ++A,0 SAY "*BR.* ARTIKLA  *                                   *MJ.*            *        *"
      @ ++A,0 SAY m
   ENDIF
   IF A>62; EJECTA0; ENDIF

   SELECT mat_suban
   cIdRoba:=IdRoba
   nIznos:=nIznos2:=nStanje:=nCijena:=0
   DO WHILE !eof() .AND. cIdF==IdFirma .and. cIdK==IdKonto .and. cIdRoba==IdRoba
    // saberi za jednu robu
      IF U_I="1"
         nStanje+=Kolicina
      ELSE
         nStanje-=Kolicina
      ENDIF
      IF D_P="1"
         nIznos+=Iznos
         nIznos2+=Iznos2
      ELSE
         nIznos-=Iznos
         nIznos2-=Iznos2
      ENDIF
    SKIP
   ENDDO

  if round(nStanje,4)<>0 .or. round(nIznos,4)<>0  // uzimaj samo one koji su na stanju  <> 0
   SELECT ROBA; HSEEK cIdRoba
   @ ++A,0 SAY ++B PICTURE '9999'
   @ A,5 SAY Id
   @ A,16 SAY naz PICTURE replicate ("X",35)
   @ A,52 SAY jmj
   IF round(nStanje,4) <> 0
      nCijena:=nIznos/nStanje
   else
      nCijena:=0
   ENDIF
   @ A,57 SAY nCijena PICTURE PicDEM
   @ A,70 SAY "________"

   SELECT mat_suban
  endif
ENDDO

If A>56; EJECTA0; endif
@ ++A,0 say m
A+=3
@ A,10 SAY "ODGOVORNO LICE:"
@ A,50 SAY "CLANOVI KOMISIJE:"
A+=2
@ A,5 SAY "_________________________"
@ A,45 SAY "1.________________________"
A+=2
@ A,45 SAY "2.________________________"
A+=2
@ A,45 SAY "3.________________________"

EJECTNA0
END PRINT
closeret
