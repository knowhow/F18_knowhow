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

function pornar()


local nPPU:=nPPP:=0,nt1:=nt2:=nt3:=nt4:=nT5:=0,nCol1:=1,nCijena:=0

// obracun poreza na realizaciju

O_PARTN
O_TARIFA
O_MAT_SUBAN
O_KONTO
O_SIFK
O_SIFV
O_ROBA

dDatOd:=ctod("")
dDatDo:=date()

cIdFirma:=gFirma
qqKonto:=SPACE(80)
cNalPr:=padr(gNalPr,20)
Box("pnar",8,60,.f.)
do while .t.
@ m_x+1,m_y+2 SAY "OBRACUN POREZA NA REALIZACIJU"
if gNW$"DR"
  @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+4,m_y+2 SAY "Konto:  " GET qqKonto picture "@S50"
@ m_x+6,m_y+2 SAY "Za period od" GET dDatOd
@ m_x+6,col()+2 SAY "do" GET dDatDo
@ m_x+8,m_y+2 SAY "Nalozi realizacije" GET cNalPr
READ;  ESC_BCR
 aUsl1:=Parsiraj(qqKonto,"IdKonto","C")
 if aUsl1<>NIL; exit; endif
enddo
BoxC()

cNalPr:=trim(cNalPR)

cIdFirma:=left(cIdFirma,2)

aDbf:={ { "IDTARIFA", "C",6,0} ,;
        { "ppp"     , "N", 6,2} ,;
        { "ppu"     , "N", 6,2} ,;
        { "MPV"     , "N",16,3} ,;
        { "MPVSAP"  , "N",16,3} ;
      }
dbcreate2("real", aDbf )
select 95
my_use ( "real" )

//dbcreateind(PRIVPATH+"reali1","d()+idtarifa",{|| d()+idtarifa})

select mat_suban; set filter to Tacno(aUsl1) .and. IdFirma==cIdFirma .and. ;
       idvn $ cNalPr .and. u_i=="2" .and. dDatOd<=datdok .and. dDatDo>=datdok
go top
EOF CRET

START PRINT CRET
P_12CPI

do while !eof()
  select roba; hseek mat_suban->idroba
  select tarifa; hseek roba->idtarifa
  select mat_suban
  if Iznos<>0 .and. Kolicina<>0
     nCijena:=Iznos/Kolicina
  else
     nCijena:=0
  endif
  select real
  seek tarifa->id
  if !found()
     dbappend()
  endif

  replace idtarifa with tarifa->id,;
          ppp with tarifa->opp,;
          ppu with tarifa->ppp,;
          mpvsap with mpvsap+suban->kolicina*ncijena,;
          mpv with mpv+suban->kolicina*ncijena/(1+ppu/100)/(1+ppp/100)
  select mat_suban
  skip
enddo
select real
go top
m:="------- ------ ------- ----------- ----------- ----------- ----------- -----------"
? "MAT: Porez na realizaciju za period",ddatOd,"-",dDatDo
? m
? "Tarifa   PPP     PPU      MPV       Iznos PPP   Iznos PPU   Iznos Por   MPV sa Por"
? m
do while !eof()
  ? idtarifa

  nPPP:=MPV*ppp/100
  nPPU:=MPV*(1+ppp/100)*ppu/100
  @ prow(),pcol()+1 SAY PPP pict "999.99%"
  @ prow(),pcol()+1 SAY PPU pict "999.99%"
  nCol1:=pcol()+1
  @ prow(),pcol()+1 SAY MPV pict picdem
  @ prow(),pcol()+1 SAY nPPP pict picdem
  @ prow(),pcol()+1 SAY nPPU pict picdem
  @ prow(),pcol()+1 SAY nPPP+nPPU pict picdem
  @ prow(),pcol()+1 SAY MPVSap pict picdem
  nT1+=mpv
  nT2+=nPPP
  nT3+=nPPU
  nT4+=nPPU+nPPP
  nT5+=MPVSaP
  skip
enddo
? m
? "Ukupno:"
@ prow(),nCol1 SAY nT1  pict picdem
@ prow(),pcol()+1 SAY nT2  pict picdem
@ prow(),pcol()+1 SAY nT3  pict picdem
@ prow(),pcol()+1 SAY nT4  pict picdem
@ prow(),pcol()+1 SAY nT5  pict picdem
? m
ENDPRINT
closeret
