/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"


// izbaciti StNal

function StNal(lAuto)
return stampa_fin_document(lAuto)


function stampa_fin_document(lAuto)
private dDatNal := date()

  StAnalNal(lAuto)

  SintStav(lAuto)

return



/*! \fn StAnalNal(lAuto)
 *  \brief Stampanje analitickog naloga
 *  \param lAuto
 */
 
function StAnalNal(lAuto)
local _print_opt := "V"
local _izgenerisi := .f.

private aNalozi:={}

if lAuto==NIL
	lAuto:=.f.
ENDIF

O_VRSTEP

O_FIN_PRIPR
O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_PSUBAN

__par_len := LEN(partn->id)

select PSUBAN
ZAP

select fin_pripr
set order to tag "1"

go top

EOF CRET

_izgenerisi:=.f.

if lAuto .or. field->idvn == "00" 
    _izgenerisi := .t.
endif

if lAuto 
   _print_opt := "D"
endif
 

if lAuto
	Box(, 3, 75)
   	@ m_x+0, m_y+2 SAY "PROCES FORMIRANJA SINTETIKE I ANALITIKE"
endif

DO WHILE !EOF()
	cIdFirma:=IdFirma
	cIdVN:=IdVN
	cBrNal:=BrNal
   	if !_izgenerisi
     	Box("",2,50)
       set cursor on
       @ m_x+1, m_y+2 SAY "Nalog broj:"
       if gNW=="D"
           cIdFirma := gFirma
           @ m_x+1, col()+1 SAY cIdFirma
       else
           @ m_x+1, col()+1 GET cIdFirma
       endif
       @ m_x+1, col()+1 SAY "-" GET cIdVn
       @ m_x+1, col()+1 SAY "-" GET cBrNal
       if gDatNal == "D"
        @ m_x+2, m_y+2 SAY "Datum naloga:" GET dDatNal
       endif
       read
       ESC_BCR
     BoxC()
   endif

   HSEEK cIdFirma + cIdVN + cBrNal
   if EOF()
       closeret
   endif

   if !_izgenerisi
     f18_start_print(NIL, @_print_opt)
   endif

   stampa_suban_dokument("1", lAuto)

   if !_izgenerisi
     close all
     f18_end_print(NIL, @_print_opt)
   endif

   IF ASCAN(aNalozi, cIdFirma + cIdVN + cBrNal) == 0
     AADD(aNalozi, cIdFirma + cIdVN + cBrNal)  
     // lista naloga koji su otisli
     IF lAuto
       @ m_x+2, m_y+2 SAY "Formirana sintetika i analitika za nalog:" + cIdFirma + "-" + cIdVN + "-" + cBrNal
     ENDIF
   ENDIF

ENDDO   

if lAuto
  BoxC()
endif

if _izgenerisi .and. !lAuto
   Beep(2)
   Msg("Sve stavke su stavljene na stanje")
endif

CLOSE ALL

return



/*! \fn fin_zagl_11()
 *  \brief Zaglavlje analitickog naloga
 */
 
function fin_zagl_11()

local nArr, lDnevnik:=.f.
if "DNEVNIKN"==PADR(UPPER(PROCNAME(1)),8) .or.;
   "DNEVNIKN"==PADR(UPPER(PROCNAME(2)),8)
   lDnevnik:=.t.
endif

__par_len := LEN(partn->id)

?
if gNW=="N" .and. gVar1=="0"
 P_COND2
else
 P_COND
endif
B_ON
?? UPPER(gTS)+":",gNFirma
?
nArr:=select()
if gNW=="N"
   select partn; hseek cidfirma; select (nArr)
   ? cidfirma,"-",partn->naz
endif
?
IF lDnevnik
  ? "FIN.P:      D N E V N I K    K NJ I Z E NJ A    Z A    "+;
    UPPER(NazMjeseca(MONTH(dDatNal)))+" "+STR(YEAR(dDatNal))+". GODINE"
ELSE
  ? "FIN.P: NALOG ZA KNJIZENJE BROJ :"
  @ prow(),PCOL()+2 SAY cIdFirma+" - "+cIdVn+" - "+cBrNal
ENDIF
B_OFF
if gDatNal=="D" .and. !lDnevnik
 @ prow(),pcol()+4 SAY "DATUM: "
 ?? dDatNal
endif

IF !lDnevnik
  select TNAL; hseek cidvn
  @ prow(),pcol()+4 SAY naz
ENDIF

@ prow(),pcol()+15 SAY "Str:"+str(++nStr,3)

lJerry := ( IzFMKIni("FIN","JednovalutniNalogJerry","N",KUMPATH) == "D" )

P_NRED
?? M
if gNW=="D"
 P_NRED
 ?? IF(lDnevnik,"R.BR. *   BROJ   *DAN*","")+"*R. * KONTO *" + PADC("PART", __par_len) + "*"+IF(gVar1=="1".and.lJerry,"       NAZIV PARTNERA         *                    ","    NAZIV PARTNERA ILI      ")+"*   D  O  K  U  M  E  N  T    *         IZNOS U  "+ValDomaca()+"         *"+IF(gVar1=="1","","    IZNOS U "+ValPomocna()+"    *")
 P_NRED
 ?? IF(lDnevnik,"U DNE-*  NALOGA  *   *","")+"             " + PADC("NER", __par_len) + " "+IF(gVar1=="1".and.lJerry,"            ILI                      O P I S       ","                            ")+" ----------------------------- ------------------------------- "+IF(gVar1=="1","","---------------------")
 P_NRED; ?? IF(lDnevnik,"VNIKU *          *   *","")+"*BR *       *" + REPL(" ", __par_len) + "*"+IF(gVar1=="1".and.lJerry,"        NAZIV KONTA           *                    ","    NAZIV KONTA             ")+"* BROJ VEZE * DATUM  * VALUTA *  DUGUJE "+ValDomaca()+"  * POTRAZUJE "+ValDomaca()+"*"+IF(gVar1=="1",""," DUG. "+ValPomocna()+"* POT."+ValPomocna()+"*")
ELSE
 P_NRED
 ?? IF(lDnevnik,"R.BR. *   BROJ   *DAN*","")+"*R. * KONTO *" + PADC("PART", __par_len) + "*"+IF(gVar1=="1".and.lJerry,"       NAZIV PARTNERA         *                    ","    NAZIV PARTNERA ILI      ")+"*           D  O  K  U  M  E  N  T             *         IZNOS U  "+ValDomaca()+"         *"+IF(gVar1=="1","","    IZNOS U "+ValPomocna()+"    *")
 P_NRED
 ?? IF(lDnevnik,"U DNE-*  NALOGA  *   *","")+"             " + PADC("NER", __par_len) + " "+IF(gVar1=="1".and.lJerry,"            ILI                      O P I S       ","                            ")+" ---------------------------------------------- ------------------------------- "+IF(gVar1=="1","","---------------------")
 P_NRED
 ?? IF(lDnevnik,"VNIKU *          *   *","")+"*BR *       *" + REPL(" ", __par_len)+ "*"+IF(gVar1=="1".and.lJerry,"        NAZIV KONTA           *                    ","    NAZIV KONTA             ")+"*  TIP I NAZIV   * BROJ VEZE * DATUM  * VALUTA *  DUGUJE "+ValDomaca()+"  * POTRAZUJE "+ValDomaca()+"*"+IF(gVar1=="1",""," DUG. "+ValPomocna()+"* POT."+ValPomocna()+"*")
ENDIF
P_NRED
?? M
select(nArr)
return


/*! \fn SintStav(lAuto)
 *  \brief Formiranje sintetickih stavki
 *  \param lAuto
 */
 
function SintStav(lAuto)

if lAuto == NIL
 lAuto := .f.
ENDIF

O_PSUBAN
O_PARTN
O_PANAL
O_PSINT
O_PNALOG
O_KONTO
O_TNAL

select PANAL
zap
select PSINT
zap
select PNALOG
zap

select PSUBAN
set order to tag "2"
go top

if empty(BrNal)
   closeret
endif

A:=0
// svi nalozi
DO WHILE !eof()  

   nStr:=0
   nD1:=nD2:=nP1:=nP2:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal

   DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog

         cIdkonto:=idkonto

         nDugBHD:=nDugDEM:=0
         nPotBHD:=nPotDEM:=0
         IF D_P="1"
               nDugBHD:=IznosBHD; nDugDEM:=IznosDEM
         ELSE
               nPotBHD:=IznosBHD; nPotDEM:=IznosDEM
         ENDIF

         SELECT PANAL     // analitika
         seek cidfirma+cidvn+cbrnal+cidkonto
         fNasao:=.f.
         DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                    .and. IdKonto==cIdKonto
           if gDatNal=="N"
              if month(psuban->datdok)==month(datnal)
                fNasao:=.t.
                exit
              endif
           else  // sintetika se generise na osnovu datuma naloga
              if month(dDatNal)==month(datnal)
                fNasao:=.t.
                exit
              endif
           endif
           skip
         enddo
         if !fNasao
            append blank
         endif

         REPLACE IdFirma WITH cIdFirma,IdKonto WITH cIdKonto,IdVN WITH cIdVN,;
                 BrNal with cBrNal,;
                 DatNal WITH iif(gDatNal=="D",dDatNal,max(psuban->datdok,datnal)),;
                 DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
                 DugDEM WITH DugDEM+nDugDEM, PotDEM WITH PotDEM+nPotDEM


         SELECT PSINT
         seek cidfirma+cidvn+cbrnal+left(cidkonto,3)
         fNasao:=.f.
         DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                   .and. left(cidkonto,3)==idkonto
           if gDatNal=="N"
            if  month(psuban->datdok)==month(datnal)
              fNasao:=.t.
              exit
            endif
           else // sintetika se generise na osnovu dDatNal
              if month(dDatNal)==month(datnal)
                fNasao:=.t.
                exit
              endif
           endif

           skip
         enddo
         if !fNasao
             append blank
         endif

         REPLACE IdFirma WITH cIdFirma,IdKonto WITH left(cIdKonto,3),IdVN WITH cIdVN,;
              BrNal WITH cBrNal,;
              DatNal WITH iif(gDatNal=="D", dDatNal,  max(psuban->datdok,datnal) ),;
              DugBHD WITH DugBHD+nDugBHD,PotBHD WITH PotBHD+nPotBHD,;
              DugDEM WITH DugDEM+nDugDEM,PotDEM WITH PotDEM+nPotDEM

         nD1+=nDugBHD; nD2+=nDugDEM; nP1+=nPotBHD; nP2+=nPotDEM

        SELECT PSUBAN
        skip
   ENDDO  // nalog

   SELECT PNALOG    // datoteka naloga
   APPEND BLANK
   REPLACE IdFirma WITH cIdFirma,IdVN WITH cIdVN,BrNal WITH cBrNal,;
           DatNal WITH iif(gDatNal=="D",dDatNal,date()),;
           DugBHD WITH nD1,PotBHD WITH nP1,;
           DugDEM WITH nD2,PotDEM WITH nP2

   private cDN:="N"
   if !lAuto
     Box(, 2, 58)
       @ m_x+1, m_y+2 SAY "Stampanje analitike/sintetike za nalog " + cIdfirma + "-" + cIdvn + "-" + cBrnal + " ?"  GET cDN pict "@!" valid cDN $ "DN"
       if gDatNal=="D"
        @ m_x+2,m_y+2 SAY "Datum naloga:" GET dDatNal
       endif
       read
     BoxC()
   endif
   if cDN=="D"
     select panal
     seek cIdfirma + cIdvn +cBrnal
     StOSNal(.f.)    // stampa se priprema
   endif
   SELECT PSUBAN

ENDDO  // svi nalozi

select PANAL
go top
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo

select PSINT
go top
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo

close all
return

