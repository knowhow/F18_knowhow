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

static PicDEM:="@Z 9999999.99"
static PicBHD:="@Z 999999999.99"
static PicKol:="@Z 999999.999"


function mat_stampa_naloga()
local _izbor := 1
local _opc := {}
local _opcexe := {}

AADD( _opc, "1. subanalitika     " )
AADD( _opcexe, {|| mat_st_anal_nalog( .f. ) } )
AADD( _opc, "2. analitika" )
AADD( _opcexe, {|| mat_st_sint_nalog() } )

f18_menu("onal", .f., _izbor, _opc, _opcexe )

return



function mat_st_sint_nalog(fnovi)

if pcount()==0
 fnovi:=.f.
endif

O_KONTO
O_TNAL
if fnovi
 O_MAT_PANAL2
 cIdFirma:=idFirma
 cIdVN:=idvn
 cBrNal:=brnal
else
 O_MAT_ANAL
 select mat_anal
 set order to tag "2"
 cIdFirma:=gFirma
 cIdVN:=space(2)
 cBrNal:=space(4)
endif


if !fnovi
Box("",1,35)
 @ m_x+1,m_y+2 SAY "Nalog:"
 if gNW$"DR"
   @ m_x+1,col()+1 SAY cIdFirma
 else
   @ m_x+1,col()+1 GET cIdFirma
 endif
 @ m_x+1,col()+1 SAY "-" GET cIdVN
 @ m_x+1,col()+1 SAY "-" GET cBrNal
 read; ESC_BCR
BoxC()
endif

seek cidfirma+cidvn+cbrNal
NFOUND CRET

nStr:=0

START PRINT CRET
?

A:=0
if gkonto=="N"  .and. g2Valute=="D"
M:="--- -------- ------- --------------------------------------------------------- ---------- ---------- ------------ ------------"
else
M:="--- -------- ------- --------------------------------------------------------- ------------ ------------"
endif

   nStr:=0

   b1:={|| !eof()}
   b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
   IF a<>0;EJECTA0; Zagl12(); ENDIF

   nRbr2:=0
   nDug11:=nPot11:=nDug22:=nPot22:=0
   DO WHILE eval(b1) .and. eval(b2)     // jedan nalog

      cSinKon:=LEFT(IdKonto,3)
      b3:={|| cSinKon==LEFT(IdKonto,3)}

      nDug1:=0;nPot1:=0
      nDug2:=0;nPot2:=0
      nRbr:=0
      DO WHILE  eval(b1) .and. eval(b2) .and. eval(b3)  // mat_sinteticki konto
         cIdKonto:=IdKonto
         select KONTO; HSEEK cIdKonto
         select mat_anal

         if A==0; Zagl12(); endif
         if A>63; EJECTA0; Zagl12(); endif

         @ ++A,0 SAY ++nRBr PICTURE '999'
         @ A,pcol()+1 SAY datnal
         @ A,pcol()+1 SAY cIdKonto
         @ A,pcol()+1 SAY konto->naz
         nCI:=pcol()+1
          @ A,pcol()+1 SAY Dug PICTURE gPicDEM()
          @ A,pcol()+1 SAY Pot PICTURE gPicDEM()
         if gkonto=="N" .and. g2Valute=="D"
          @ A,pcol()+1 SAY Dug2 PICTURE gPicdin
          @ A,pcol()+1 SAY Pot2 PICTURE gPicdin
         endif
         nDug1+=Dug; nPot1+=Pot
         nDug2+=Dug2;nPot2+=Pot2
         SKIP

      ENDDO  // mat_sinteticki konto
      if A>61; EJECTA0; Zagl12(); endif
      @ ++A,0 SAY M
      @ ++A,2 SAY ++nRBr2 PICTURE '999'
      @ A,13 SAY cSinKon
      SELECT KONTO; HSEEK cSinKon
      @ A,pcol()+5 SAY naz
      select mat_anal

      @ a,ncI-1 SAY ""
      @ A,pcol()+1 SAY nDug1 PICTURE gPicDEM()
      @ A,pcol()+1 SAY nPot1 PICTURE gPicDEM()
      if gkonto=="N" .and. g2Valute=="D"
       @ A,pcol()+1 SAY nDug2 PICTURE gPicdin
       @ A,pcol()+1 SAY nPot2 PICTURE gPicdin
      endif
      @ ++A,0 SAY M

      nDug11+=nDug1; nPot11+=nPot1
      nDug22+=nDug2; nPot22+=nPot2
   ENDDO  // nalog

   if A>61; EJECTA0; Zagl12(); endif
   @ ++A,0 SAY M
   @ ++A,0 SAY "ZBIR NALOGA:"
   @ a,ncI-1 SAY ""
   @ A,pcol()+1  SAY nDug11  PICTURE  gPicDEM()
   @ A,pcol()+1  SAY nPot11  PICTURE  gPicDEM()
   if gkonto=="N" .and. g2Valute=="D"
    @ A,pcol()+1  SAY nDug22 PICTURE  gPicdin
    @ A,pcol()+1  SAY nPot22 PICTURE  gpicdin
   endif
   @ ++A,0 SAY M


//   FF


EJECTA0

ENDPRINT

my_close_all_dbf()
return

static function Zagl12()
local nArr
?
P_COND
@ A,0 SAY "MAT.P: ANALITICKI NALOG ZA KNJIZENJE BROJ :"
@ A,PCOL()+2 SAY cIdFirma+" - "+cIdVn+" - "+cBrNal
nArr:=select()
SELECT TNAL; HSEEK cIDVN; @ A,90 SAY naz; select(nArr)
@ a,pcol()+3 SAY "Str "+str(++nStr,3)
@ ++A,0 SAY M
if gkonto=="N" .and. g2Valute=="D"
 @ ++A,0 SAY "*R.*  Datum  *         K O N T O                                              *  I Z N O S   "+ValDomaca()+"   *   I Z N O S   "+ValPomocna()+"     *"
 @ ++A,0 SAY "*Br*                                                                           --------------------- -------------------------"
 @ ++A,0 SAY "*  *         *                                                                *   DUG    *    POT   *    DUG     *    POT    *"
else
 @ ++A,0 SAY "*R.*  Datum  *         K O N T O                                              *   I Z N O S   "+ValDomaca()+"     *"
 @ ++A,0 SAY "*Br*                                                                           -------------------------"
 @ ++A,0 SAY "*  *         *                                                                *    DUG     *    POT    *"
endif
@ ++A,0 SAY M
return

function gPicDEM()
return iif(g2Valute=="N",gPicDin,gPicDEM)
