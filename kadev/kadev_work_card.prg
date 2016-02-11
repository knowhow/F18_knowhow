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


// ----------------------------------------------
// radna karta
// ----------------------------------------------
function kadev_work_card()

O_KADEV_1
O_KADEV_0
O_KDV_RJRMJ
O_KDV_RJ
O_KDV_RMJ
O_KDV_ZANIM
O_STRSPR

select kadev_1  ; set order to tag "1"
select kadev_0  ; SET order to tag "4"
select kdv_rjrmj; set order to tag "ID"

  SET CURSOR ON

  cOdRJ:=cDoRj:=SPACE(6)

  Box('RKar',7,40,.F.)
  @ m_x+1,m_y+2 SAY 'Od RJ:' GET cOdRJ  PICTURE '@!'
  READ
  IF LastKey()==K_ESC ; BoxC() ; RETURN ; ENDIF

  @ m_x+2,m_y+2 SAY 'Do RJ:' GET cDoRJ;
       PICTURE '@!' VALID cDoRj>=cOdRJ
  READ


  IF LastKey()==K_ESC ; BoxC() ; RETURN ; END IF


  //ImeDat=PADR("RK",8)
  //@ m_x+7,m_y+2 SAY 'Naziv datoteke:' GET ImeDat PICTURE '@! AAAAAAAA';
  //VALID !EMPTY(ImeDat)
  //READ

  BoxC()

  SET CURSOR OFF

  IF LastKey()==K_ESC ; RETURN ; END IF

 start print cret
 //set alternate to &ImeDat
 //SET alternate on
 //set console off

 ? "Pregled sistematizacije mjesta (radna karta) za RJ:",cOdRJ,"-",cDoRJ
 ? SPACE(50),"na Datum:",DATE()
 ? REPLICATE('=',80)
 ?

 SEEK cOdRJ
 crj:=IdRj
 nPopRJ:=0; nPopRJS:=0
 select kdv_rj; HSEEK crj; select kdv_rjrmj
 ? "****",crj,"****", kdv_rj->naz
 ? replicate('-',80)

 //Box('Cnt',1,10,.f.)
 nCnt:=0
 do while idRj <= cDoRJ .and. !eof()

  //@ m_x+1,m_y+2 SAY nCnt++

  cRmj:=IdRmj

  if BrIzvrs=0
    skip
    loop
  endif

  if cRJ<>IdRj
   if nPopRJS<>0
     ?
     ? '************ Popunjeno:',str(nPopRJ/nPopRJS*100,6,2),'% ************'
     ?
     ?
   endif

     cRj:=IdRJ
     nPopRJ:=nPopRJS:=0
     ?
     select kdv_rj; HSEEK crj; select kdv_rjrmj
     ? "****",cRj,"****", kdv_rj->naz
     ? replicate('-',80)
     ?
  endif

  ? REPLICATE("-",78)
  if prow()>62; FF; endif
  select kdv_rmj; HSEEK cRmj
  select strspr; HSEEK kdv_rjrmj->idStrSprod
  select kdv_rjrmj
  ?  cRMJ,'-',kdv_rmj->naz,' Po sist.izvrsilaca:',BrIzvrs,SPACE(2),"K:"+Idk1+";"+Idk2+";"+Idk3+";"+Idk4
  ?  SPACE(6),"Opis:",Opis
  ?  SPACE(6),"S.Spr:",IdStrSprOd,"-",strspr->naz
  select kdv_zanim; HSEEK kdv_rjrmj->idzanim1; select kdv_rjrmj
  ?  SPACE(6),"Vrsta:",Idzanim1,"-",kdv_zanim->naz
  if !empty(Idzanim2)
   select kdv_zanim; HSEEK kdv_rjrmj->idzanim2; select kdv_rjrmj
   ?  SPACE(6),Idzanim2,"-",kdv_zanim->naz
  endif
  if !empty(Idzanim3)
   select kdv_zanim; HSEEK kdv_rjrmj->idzanim3; select kdv_rjrmj
   ?  SPACE(6),Idzanim3,"-",kdv_zanim->naz
  endif
  if !empty(Idzanim4)
   select kdv_zanim; HSEEK kdv_rjrmj->idzanim4; select kdv_rjrmj
   ?  SPACE(6),Idzanim4,"-",kdv_zanim->naz
  endif
  ? REPLICATE("-",78)

          nPopRJS+=BrIzvrs

          select kadev_0
          seek kdv_rjrmj->(IdRJ+IdRMJ)
          nPopunjeno:=0
          do while kdv_rjrmj->(IdRJ+IdRMJ)=IdRJ+IdRMJ
            if (Status == 'X') // van firme
              skip
              loop
            endif
            ? str(++nPopunjeno,5)+'.',trim(prezime)+" ("+trim(ImeRod)+") "+trim(ime)
            select strspr; HSEEK kadev_0->idStrspr; select kadev_0
            ? space(6),IdStrSpr,"-",strspr->naz
            select kdv_zanim; HSEEK kadev_0->idzanim; select kadev_0
            ? space(6),IdZanim,"-",kdv_zanim->naz,SPACE(7),"__________"
            ++nPopRJ
                  ////////// postavljenja radnog staza
                  select kadev_1
                  seek kadev_0->id
                  fProsao:=.f.
                  do while kadev_0->id = kadev_1->id
                   if kadev_1->IdPromj $ "R1#R2"  // Postavljenje, dodavanje rad.st staza
                    if !fProsao
                      ? SPACE(5),"-Radni staz-"
                      fProsao:=.t.
                    endif
                    aRE:=GMJD(nAtr1)
                    ?  SPACE(7),DatumOd,Dokument,Opis,str(aRe[1],2)+"g.",str(aRe[2],2)+"mj.",str(aRe[3],2)+"d."
                   endif
                   skip
                  enddo
                  select kadev_0
                  /////////////////////
                  ////////// strucni ispit
                  select kadev_1
                  seek kadev_0->id
                  fProsao:=.f.
                  do while kadev_0->id = kadev_1->id
                   if kadev_1->IdPromj=="S2"  // S2 - stru~ni ispit
                    if !fProsao
                      ? SPACE(5),"-Strucni ispit-"
                      fProsao:=.t.
                    endif
                    ?  SPACE(7),DatumOd,Dokument,Opis
                   endif
                   skip
                  enddo
                  select kadev_0
                  /////////////////////
            skip
          enddo
          select kdv_rjrmj
          for i:=nPopunjeno+1 to BrIzvrs
           ? str(i,6)+'.',REPLICATE('_',30)
           ? SPACE(7),REPLICATE('_',50)
           ? SPACE(7),REPLICATE('_',50),space(4),"__________"
          next
 skip

 enddo

 if nPopRJS<>0
     ?
     ? '************ Popunjeno:',str(nPopRJ/nPopRJS*100,6,2),'% ************'
     ?
     ?
 endif

 ENDPRINT


my_close_all_dbf()

return


