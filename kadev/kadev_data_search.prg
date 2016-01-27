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



static function kadev_search_data_relation()
select kdv_rmj
set order to tag "ID"
select kadev_0
set relation to idRmj into kdv_rmj
select kdv_rj
set order to tag "ID"
select kadev_0
set relation to idRj into kdv_rj additive
select kdv_rjrmj
set order to tag "ID"
select kadev_0
set relation to idRj+idrmj into kdv_rjrmj additive
select strspr
set order to tag "ID"
select kadev_0
set relation to IdStrSpr into strspr additive
select kdv_mz
set order to tag "ID"
select kadev_0
set relation to IdMzSt into kdv_mz additive
select kdv_k1
set order to tag "ID"
select kadev_0
set relation to IdK1 into kdv_k1 additive
select kdv_k2
set order to tag "ID"
select kadev_0
set relation to IdK2 into kdv_k2 additive
select kdv_zanim
set order to tag "ID"
select kadev_0
set relation to IdZanim into kdv_zanim additive
select kdv_nac
set order to tag "ID"
select kadev_0
set relation to Idnac into kdv_nac additive
select kdv_rrasp
set order to tag "ID"
select kadev_0
set relation to IdRRasp into kdv_rrasp additive
select kdv_cin
set order to tag "ID"
select kadev_0
set relation to IdCin into kdv_cin additive
select kdv_ves
set order to tag "ID"
select kadev_0
set relation to IdVEs into kdv_ves additive
select kdv_rjrmj
set order to tag "ID"
select kadev_0
set relation to IdRJ+IDRMJ into kdv_rjrmj additive
select kadev_0
return



function kadev_search()

set epoch to 1910

kadev_o_tables()
kadev_search_data_relation()

select kadev_0

cPic:="@!S30"


 qqPrezime        :=;
 qqImeRod         :=;
 qqIme            :=;
 qqId             :=;
 qqDatRodj        :=;
 qqMjRodj         :=;
 qqBrLK           :=;
 qqMjSt           :=;
 qqIdMZSt         :=;
 qqUlSt           :=;
 qqBrTel1         :=;
 qqIdZanim        :=;
 qqIdStrSpr       :=;
 qqIdRj           :=;
 qqidRMJ          :=;
 qqDatURMJ        :=qqDatUF:=;
 qqDatVRMJ        :=;
 qqStatus         :=;
 qqBrTel2         :=;
 qqBrTel3         :=;
 qqBrDjece        :=;
 qqidK1           :=;
 qqidK2           :=;
 qqKOp1           :=;
 qqKOp2           :=;
 qqIdPromj        :=;
 qqIdK            :=;
 qqRstE           :=;
 qqStBRst         :=;
 qqVSS1           :=;
 qqVSS2           :=;
 qqVSS3           :=;
 qqVSS4           :=;
 qqRstB           :=SPACE(80)

 qqPol            :=SPACE(10)
 qqStan           :=;
 qqBracSt         :=;
 qqKrv            :=SPACE(30)

 qqRRasp          :=;
 qqSlVr           :=;
 qqVrSlVr         :=;
 qqSposVSl        :=;
 qqIdVES          :=;
 qqIdCin          :=;
 qqNazSekr        := SPACE(80)

 qqDatumOd        :=;
 qqDatumDo        :=;
 qqDokument       :=;
 qqOpis           :=;
 qqNadlezan       :=;
 qqIDRj1          :=;
 qqIDRMj1         :=;
 qqnAtr1          :=;
 qqnAtr2          :=;
 qqcAtr1          :=;
 qqcAtr2          := SPACE(80)

 qqBrIzvrs        :=;  // sistematizacija
 qqSSSOd          :=;
 qqSSSDo          :=;
 qqBodova         :=;
 qqSIdK1          :=;
 qqSIdK2          := SPACE(80)


 qqsort1:="A"

//if file(my_home() + "upit1.mem")
//  restore from upit1.mem additive
//endif


Box(,22,75)
set cursor on

do while .t.

nStrana:=1

do while .t.

@ m_x+1,m_y+1 CLEAR TO m_x+22,m_y+75

if nStrana==1
  nR:=pGET1()
elseif nStrana==2
  nR:=pGET2()
elseif nStrana==3
  nR:=pGET3()
elseif nStrana==4
  nR:=pGET4()
elseif nStrana==5
  nR:=pGET5()
endif

if nR==K_ESC
  exit
elseif nR==K_PGUP
  --nStrana
elseif nR==K_PGDN .or. nR==K_ENTER
  ++nStrana
endif

if nStrana==0
   nStrana++
elseif nStrana==6
   exit
endif

enddo


if lastkey()==K_ESC
    BoxC()
    exit
endif

aUsl1:=Parsiraj(  qqPrezime       ,  "Prezime"      ,  "C"  )
aUsl2:=Parsiraj(  qqImeRod        ,  "ImeRod"       ,  "C"  )
aUsl3:=Parsiraj(  qqIme           ,  "Ime"          ,  "C"  )
aUsl4:=Parsiraj(  qqPol           ,  "Pol"          ,  "C"  )
aUsl5:=Parsiraj(  qqId            ,  "Id"           ,  "C"  )
aUsl6:=Parsiraj(  qqDatRodj       ,  "DatRodj"      ,  "D"  )
aUsl7:=Parsiraj(  qqMjRodj        ,  "MjRodj"       ,  "C"  )
aUsl8:=Parsiraj(  qqBrLK          ,  "BrLK"         ,  "C"  )
aUsl9:=Parsiraj(  qqMjSt          ,  "MjSt"         ,  "C"  )
aUsla:=Parsiraj(  qqIdMZSt        ,  "IdMZSt"       ,  "C"  )
aUslb:=Parsiraj(  qqUlSt          ,  "UlSt"         ,  "C"  )
aUslc:=Parsiraj(  qqBrTel1        ,  "BrTel1"       ,  "C"  )
aUsld:=Parsiraj(  qqIdZanim       ,  "IdZanim"      ,  "C"  )
aUsle:=Parsiraj(  qqIdStrSpr      ,  "IdStrSpr"     ,  "C"  )
aUslf:=Parsiraj(  qqIdRj          ,  "IdRj"         ,  "C"  )
aUslg:=Parsiraj(  qqidRMJ         ,  "idRMJ"        ,  "C"  )
aUslh:=Parsiraj(  qqDatURMJ       ,  "DatURMJ"      ,  "D"  )
aUslh2:=Parsiraj(  qqDatUF       ,  "DatUF"      ,  "D"  )
aUsli:=Parsiraj(  qqDatVRMJ       ,  "DatVRMJ"      ,  "D"  )
aUslj:=Parsiraj(  qqStatus        ,  "Status"       ,  "C"  )
aUslk:=Parsiraj(  qqBrTel2        ,  "BrTel2"       ,  "C"  )
aUsll:=Parsiraj(  qqBrTel3        ,  "BrTel3"       ,  "C"  )
aUslm:=Parsiraj(  qqBracSt        ,  "BracSt"       ,  "C"  )
aUsln:=Parsiraj(  qqBrDjece       ,  "BrDjece"      ,  "N"  )
aUslo:=Parsiraj(  qqStan          ,  "Stan"         ,  "C"  )
aUslp:=Parsiraj(  qqidK1          ,  "idK1"         ,  "C"  )
aUslq:=Parsiraj(  qqidK2          ,  "idK2"         ,  "C"  )
aUslr:=Parsiraj(  qqKOp1          ,  "KOp1"         ,  "C"  )
aUsls:=Parsiraj(  qqKOp2          ,  "KOp2"         ,  "C"  )
aUslt:=Parsiraj(  qqRStE          ,  "RadStE"       ,  "N"  )
aUslu:=Parsiraj(  qqRStB          ,  "RadStB"       ,  "N"  )
aUslv:=Parsiraj(  qqKrv           ,  "Krv"          ,  "C"  )
aUslO1:=Parsiraj( qqRRasp         ,   "IdRRasp"      , "C"  )
aUslO2:=Parsiraj( qqSlVr          ,   "SlVr"         , "C"  )
aUslO3:=Parsiraj( qqVrSlVr        ,   "VrSlVr"       , "N"  )
aUslO4:=Parsiraj( qqSposVSl       ,   "SposVSl"      , "C"  )
aUslO5:=Parsiraj( qqIdVES         ,   "IDVES"        , "C"  )
aUslO6:=Parsiraj( qqIdCin         ,   "IDCin"        , "C"  )
aUslO7:=Parsiraj( qqNazSekr       ,   "NazSekr"      , "C"  )

aUslS1:=Parsiraj(  qqBrIzvrs      ,   "kdv_rjrmj->BrIzvrs", "N" )
aUslS2:=Parsiraj(  qqSSSOd        ,   "kdv_rjrmj->IdStrSprOd","C")
aUslS3:=Parsiraj(  qqSSSDo        ,   "kdv_rjrmj->IdStrSprDo","C")
aUslS4:=Parsiraj(  qqBodova       ,   "kdv_rjrmj->Bodova","N")
aUslS5:=Parsiraj(  qqSIdK1        ,   "kdv_rjrmj->idk1","C")
aUslS6:=Parsiraj(  qqSIdK2        ,   "kdv_rjrmj->idk2","C")
aUslS7:=Parsiraj(  qqStBRst     ,      "kdv_rjrmj->SBenefRSt","C")

aUslS8:=Parsiraj(  qqVSS1       ,      "kdv_rjrmj->IdZanim1","C")
aUslS9:=Parsiraj(  qqVSS2       ,      "kdv_rjrmj->IdZanim2","C")
aUslSa:=Parsiraj(  qqVSS3       ,      "kdv_rjrmj->IdZanim3","C")
aUslSb:=Parsiraj(  qqVSS4       ,      "kdv_rjrmj->IdZanim4","C")

aUsl1a:=Parsiraj(  qqIdPromj      ,  "IdPromj"       , "C"  )
aUsl1b:=Parsiraj( qqIdK           ,  "IdK"          ,"C"    )
aUsl1c:=Parsiraj( qqDatumOd       ,  "DatumOd"      ,"D"    )
aUsl1d:=Parsiraj( qqDatumDo       ,  "DatumDo"      ,"D"    )
aUsl1e:=Parsiraj( qqDokument      ,  "Dokument"     ,"C"    )
aUsl1f:=Parsiraj( qqOpis          ,  "Opis"         ,"C"    )
aUsl1g:=Parsiraj( qqNadlezan      ,  "Nadlezan"     ,"C"    )
aUsl1h:=Parsiraj( qqIDRj1         ,  "IDRj1"        ,"C"    )
aUsl1i:=Parsiraj( qqIDRMj1        ,  "IDRMj1"       ,"C"    )
aUsl1j:=Parsiraj( qqnAtr1       ,    "nAtr1"       ,"N"    )
aUsl1k:=Parsiraj( qqnAtr2        ,   "nAtr2"       ,"N"    )
aUsl1l:=Parsiraj( qqcAtr1        ,   "cAtr1"       ,"C"    )
aUsl1m:=Parsiraj( qqcAtr2        ,   "cAtr2"       ,"C"    )



if            aUsl1 ==  NIL  .or. ;
              aUsl2 ==  NIL  .or. ;
              aUsl3 ==  NIL  .or. ;
              aUsl4 ==  NIL  .or. ;
              aUsl5 ==  NIL  .or. ;
              aUsl6 ==  NIL  .or. ;
              aUsl7 ==  NIL  .or. ;
              aUsl8 ==  NIL  .or. ;
              aUsl9 ==  NIL  .or. ;
              aUsla ==  NIL  .or. ;
              aUslb ==  NIL  .or. ;
              aUslc ==  NIL  .or. ;
              aUsld ==  NIL  .or. ;
              aUsle ==  NIL  .or. ;
              aUslf ==  NIL  .or. ;
              aUslg ==  NIL  .or. ;
              aUslh ==  NIL  .or. ;
              aUslh2 ==  NIL  .or. ;
              aUsli ==  NIL  .or. ;
              aUslj ==  NIL  .or. ;
              aUslk ==  NIL  .or. ;
              aUsll ==  NIL  .or. ;
              aUslm ==  NIL  .or. ;
              aUsln ==  NIL  .or. ;
              aUslo ==  NIL  .or. ;
              aUslp ==  NIL  .or. ;
              aUslq ==  NIL  .or. ;
              aUslr ==  NIL  .or. ;
              aUsls ==  NIL  .or. ;
              aUslt ==  NIL  .or. ;
              aUslu ==  NIL  .or. ;
              aUslv ==  NIL  .or. ;
              aUslO1 == NIL  .or. ;
              aUslO2 == NIL  .or. ;
              aUslO3 == NIL  .or. ;
              aUslO4 == NIL  .or. ;
              aUslO5 == NIL  .or. ;
              aUslO6 == NIL  .or. ;
              aUslO7 == NIL  .or. ;
              aUslS1 == NIL  .or. ;
              aUslS2 == NIL  .or. ;
              aUslS3 == NIL  .or. ;
              aUslS4 == NIL  .or. ;
              aUslS5 == NIL  .or. ;
              aUslS6 == NIL  .or. ;
              aUslS7 == NIL  .or. ;
              aUslS8 == NIL  .or. ;
              aUslS9 == NIL  .or. ;
              aUslSa == NIL  .or. ;
              aUslSb == NIL  .or. ;
              aUsl1a==  NIL  .or. ;
              aUsl1b ==  NIL .or. ;
              aUsl1c ==  NIL .or. ;
              aUsl1d ==  NIL .or. ;
              aUsl1e ==  NIL .or. ;
              aUsl1f ==  NIL .or. ;
              aUsl1g ==  NIL .or. ;
              aUsl1h ==  NIL .or. ;
              aUsl1i ==  NIL .or. ;
              aUsl1j ==  NIL .or. ;
              aUsl1k ==  NIL .or. ;
              aUsl1l ==  NIL .or. ;
              aUsl1m ==  NIL

        loop
else
   BoxC()
   exit
endif

enddo

if lastkey()==K_ESC
    my_close_all_dbf()
    return
endif


bInit1:=  {|| dbselectArea(F_KADEV_1),dbseek(kadev_0->id)}
bWhile1:= {|| !EOF().and.kadev_0->id==kadev_1->id}
bSkip1:=  {|| dbskip()}
bEnd1:=   {|| dbselectArea(F_KADEV_0)}


cSort1:=cSort1a:="btoe(prezime+ime)"
cSort1b:="idrj+idrmj+prezime"
cSort1c:="idrj+prezime"
cSort1d:="id+prezime"
cSort1e:="idstrspr+idzanim+prezime"
cSort1f:="id2+prezime"

do case
    case qqsort1=="A"
      csort1:=csort1a
    case qqsort1=="B"
      csort1:=csort1b
    case qqsort1=="C"
      csort1:=csort1c
    case qqsort1=="D"
      csort1:=csort1d
    case qqsort1=="E"
      csort1:=csort1e
    case qqsort1=="F"
      csort1:=csort1f
endcase

aSvUsl:= aUsl1a+".and."+aUsl1b+".and."+;
       aUsl1c+".and."+aUsl1d+".and."+;
       aUsl1e+".and."+aUsl1f+".and."+;
       aUsl1g+".and."+aUsl1h+".and."+;
       aUsl1i+".and."+aUsl1j+".and."+;
       aUsl1k+".and."+aUsl1l+".and."+aUsl1m
aSvUsl:=STRTRAN(aSvUsl,".t..and.","")

cFilt:= aUsl1+".and."+ aUsl2+".and."+;
        aUsl3+".and."+ aUsl4+".and."+ aUsl5+".and."+;
        aUsl6+".and."+ aUsl7+".and."+ aUsl8+".and."+;
        aUsl9+".and."+ aUsla+".and."+ aUslb+".and."+;
        aUslc+".and."+ aUsld+".and."+ aUsle+".and."+;
        aUslf+".and."+ aUslg+".and."+ aUslh+".and."+  aUslh2+".and."+ ;
        aUsli+".and."+ aUslj+".and."+ aUslk+".and."+;
        aUsll+".and."+ aUslm+".and."+ aUsln+".and."+;
        aUslo+".and."+ aUslp+".and."+ aUslq+".and."+;
        aUslr+".and."+ aUsls+".and."+  ;
        aUslt+".and."+ aUslu+".and."+  aUslv+".and."+;
        aUslO1+".and."+ aUslO2+".and."+ aUslO3+".and."+ aUslO4+".and."+;
        aUslO5+".and."+ aUslO6+".and."+ aUslO7+".and."+;
        aUslS1+".and."+ aUslS2+".and."+ aUslS3+".and."+ aUslS4+".and."+;
        aUslS5+".and."+ aUslS6+".and."+ aUSlS7+".and."+;
        aUslS8+".and."+ aUslS9+".and."+ aUSlSa+".and."+ aUSlSb +".and."+;
        IF(UPPER(aSvUsl)=".T.",".t.","TacnoNO(aSvUsl,bInit1,bWhile1,bSkip1,bEnd1)")

  cFilt:=STRTRAN(cFilt,".t..and.","")

  SELECT (F_KADEV_0)
  GO TOP
  Box(,2,40)
  nSlog:=0
  nUkupno:=RECCOUNT2()
  index on (id) TAG "1" TO "TMPKADEV_0"
  index on (id2) TAG "3" TO "TMPKADEV_0"
  INDEX ON &cSort1 TAG "2" TO "TMPKADEV_0" FOR &cFilt EVAL show_progress( nUkupno, cFilt )
  GO TOP
  INKEY(0)
  BoxC()

  nArr:=F_KADEV_0

  ImeKol:={}
  AADD(ImeKol, { PADR("Prezime",20),                {|| (nArr)->prezime}                             })
  AADD(ImeKol, { PADR("Ime Roditelja",15),          {|| (nArr)->ImeRod}                              })
  AADD(ImeKol, { PADR("Ime",15),                    {|| (nArr)->Ime}                                 })
  AADD(ImeKol, {      "Pol",                        {|| ' '+(nArr)->Pol+' '}                         })
  AADD(ImeKol, { PADR("Mat.broj-ID",13),            {|| (nArr)->Id}                                  })
  AADD(ImeKol, { PADR("ID broj/2",11),              {|| (nArr)->Id2}                                 })
  AADD(ImeKol, {      "Dat.Rodj",                   {|| (nArr)->(DTOC(datRodj))}                     })
  AADD(ImeKol, { PADR("Mjesto Rodjenja",30),        {|| (nArr)->mjRodj}                              })
  AADD(ImeKol, { PADR("Broj LK",12),                {|| (nArr)->BrLk}                                })
  AADD(ImeKol, { PADR("Mjesto stanovanja",25),      {|| (nArr)->MjSt}                                })
  AADD(ImeKol, { PADR("Mjesna zajednica",25),       {|| (nArr)->IdMzSt+"-"+kdv_mz->naz}                  })
  AADD(ImeKol, { PADR("Ulica stanovanja",30),       {|| (nArr)->UlSt}                                })
  AADD(ImeKol, { PADR("Br.Tel.st",10),              {|| (nArr)->BrTel1}                              })
  AADD(ImeKol, { "Zanimanje",              {|| kdv_zanim->naz}              })
  AADD(ImeKol, {      "Str.spr.",                   {|| PADC((nArr)->IdStrSpr,8)}                  })
  AADD(ImeKol, {      "Rad.staz EF.",               {|| aRE:=GMJD((nArr)->RadStE),STR(aRE[1],2)+"g."+STR(aRE[2],2)+"m."+STR(aRE[3],2)+"d."}       })
  AADD(ImeKol, {      "Rad.staz BF.",               {|| aRB:=GMJD((nArr)->RadStB),STR(aRB[1],2)+"g."+STR(aRB[2],2)+"m."+STR(aRB[3],2)+"d."}       })
  AADD(ImeKol, {      "Rad.staz UK.",               {|| aRB:=GMJD((nArr)->RadStB),aRE:=GMJD((nArr)->RadStE),aRU:=ADDGMJD(aRE,aRB),STR(aRU[1],2)+"g."+STR(aRU[2],2)+"m."+STR(aRU[3],2)+"d."}       })
  AADD(ImeKol, { PADR("Radna jedinica",25),         {|| kdv_rj->naz}                     })
  AADD(ImeKol, { PADR("Radno mjesto",35),           {|| kdv_rmj->naz}                   })
  AADD(ImeKol, {      "Dat.UF  " ,                  {|| (nArr)->(DTOC(DatUF))}                      })
  AADD(ImeKol, {      "Dat.URMJ" ,                  {|| (nArr)->(DTOC(DatURMJ))}                      })
  AADD(ImeKol, {      "Dat.VRMJ" ,                  {|| (nArr)->(DTOC(DatVRMJ))}                      })
  AADD(ImeKol, {      "Status",                     {|| PADC((nArr)->Status,6)}                       })
  AADD(ImeKol, { PADR("Br.Tel./2",10),              {|| (nArr)->BrTel2}                               })
  AADD(ImeKol, { PADR("Br.Tel./3",10),             {|| (nArr)->BrTel3}                               })
  AADD(ImeKol, {      "Brac.St",                    {|| PADC((nArr)->BracSt,7)}                       })
  AADD(ImeKol, {      "Br.Djece",                   {|| " "+STR((nArr)->BrDjece)+SPACE(5)}            })
  AADD(ImeKol, {      "Stan",                       {|| " "+(nArr)->Stan+"  "}                        })
  AADD(ImeKol, {      "Krv",                        {|| (nArr)->Krv             }                     })
  AADD(ImeKol, { PADR(gDodKar1,23),          {|| (nArr)->IdK1+"-"+kdv_k1->naz}                     })
  AADD(ImeKol, { PADR(gDodKar2,35),          {|| (nArr)->IdK2+"-"+kdv_k2->naz}                     })
  AADD(ImeKol, { PADR("Karakt. Opis /1",30),        {|| (nArr)->KOp1}                                 })
  AADD(ImeKol, { PADR("Karakt. Opis /2",30),        {|| (nArr)->KOp2}                                 })
  AADD(ImeKol, { "Br.izvrs",                        {|| SPACE(3)+STR(kdv_rjrmj->BrIzvrs,2)+SPACE(3)}      })
  AADD(ImeKol, { "Bod ",                            {|| str(kdv_rjrmj->bodova) }                          })
  AADD(ImeKol, { "Tr.SS.od",           {|| PADC(kdv_rjrmj->IdStrSprOd,8)}                   })
  AADD(ImeKol, { "Tr.SS.do",           {|| PADC(kdv_rjrmj->IdStrSprDo,8)}                   })
  AADD(ImeKol, { "St.B.r.st",                {|| PADC(kdv_rjrmj->SBenefRst,9)}                   })
  AADD(ImeKol, { "sistem.-K1",               {|| PADC(kdv_rjrmj->idk1,9)}                         })
  AADD(ImeKol, { "sistem.-K2",               {|| PADC(kdv_rjrmj->idk2,9)}                         })
  AADD(ImeKol, { "sistem.-vr.str.spr.1",     {|| Ocitaj(F_KDV_ZANIM,kdv_rjrmj->idzanim1,"naz")}  })
  AADD(ImeKol, { "sistem.-vr.str.spr.2",     {|| Ocitaj(F_KDV_ZANIM,kdv_rjrmj->idzanim2,"naz")}  })
  AADD(ImeKol, { "sistem.-vr.str.spr.3",     {|| Ocitaj(F_KDV_ZANIM,kdv_rjrmj->idzanim3,"naz")}  })
  AADD(ImeKol, { "sistem.-vr.str.spr.4",     {|| Ocitaj(F_KDV_ZANIM,kdv_rjrmj->idzanim4,"naz")}  })
  AADD(ImeKol, { "sistem. opis        ",     {|| kdv_rjrmj->opis}  })
  Kol:={}
  ASIZE(Kol,LEN(ImeKol))
  AFILL(Kol,0)
  IzborP2(Kol,"kol_0")

  lImaKol:=.f.
  RKol:={}
  FOR i:=1 TO LEN(Kol)
    IF Kol[i]>0
      lImaKol:=.t.
      AADD(RKol,{Kol[i],ImeKol[i,1],"N",LENX(EVAL(ImeKol[i,2]))})
    ENDIF
  NEXT
  IF LASTKEY()!=K_ESC .and. lImaKol
    ASORT(RKol,,,{|x,y| x[1]<y[1]})
    BirajPrelom()
    SELECT (F_KADEV_0)
    go top
    ObjDbEdit('',20,66,{|| EdK_02() },'<Ctrl-T> Brisanje <Enter> Edit','<Ctrl-P> Print pregled,<Ctrl-K> Print Karton,<Ctrl-A> Svi kartoni')
    select kadev_0
    set relation to
  ENDIF

my_close_all_dbf()
return



// ----------------------------------------------------------------
// prikazuje se progres bar kod pretrage
// ----------------------------------------------------------------
static function show_progress( last_rec, filt )

if RECNO() <= last_rec
    @ m_x + 1, m_y + 2 SAY "Filter: " + ALLTRIM( STR ( RECNO() ) ) + " od " + ALLTRIM( STR( last_rec ) )
endif

if &filt
    @ m_x + 2, m_y + 2 SAY "Pronasao: " + ALLTRIM( STR( ++ nSlog ) ) 
endif

return .t.



function EdK_02()
local cBr

// Ch:=Lastkey()

 if Ch==K_CTRL_K
   PushWA()
   TekRec:=kadev_0->(RECNO())
   PRIVATE aRB,aRE,aRU,aVrSlVr
   Karton({|| aVrSlVr:=GMJD((nArr)->VrSlVr),aRE:=GMJD((nArr)->RadStE), aRB:=GMJD((nArr)->RadStB), aRU:=ADDGMJD(aRB,aRE),kadev_0->(recno())==TekRec})
   PopWa()
   return DE_CONT
 elseif Ch==K_CTRL_A
   PushWA()
   go top
   PRIVATE aRB,aRE,ARu,aVrSlVr
   Karton({|| aVrSlVr:=GMJD((nArr)->VrSlVr),aRE:=GMJD((nArr)->RadStE), aRB:=GMJD((nArr)->RadStB),aRU:=ADDGMJD(aRB,aRE),.t.})
   PopWa()
   return DE_CONT
 elseif Ch=K_ENTER
   
    PushWA()
    select kadev_0
    
    set_global_vars_from_dbf()
    
    if ent_K_0()
        _rec := get_dbf_global_memvars()
        update_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )
    endif
    
    PopWa()

    return DE_REFRESH

 elseif Ch=K_CTRL_T

  if Pitanje("p1",(nArr)->("Izbrisati karton: "+trim(prezime)+" "+trim(ime)+" ?"),"N")=="D"
   cBr := broj
   brisi_kadrovski_karton()
   _rec := dbf_get_rec()
   delete_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )
   skip -1
   return DE_REFRESH
  else
   return DE_CONT
  endif
 elseif Ch==K_CTRL_P
   PushWA()
   go top
   PRIVATE aRB,aRE,aRU

   private cdn:="N"
   if Pitanje(,"Prikazati promjene unutar spiska ?","N")=="D"
    cdn:="D"
    // dodati kolonu bez
    IF IzFMKINI("KADEV","SkratiPromjeneUSpisku","N",KUMPATH)=="D"
      cPom77PS := IzFMKINI("PromjeneSkraceno","Formula",'idpromj+", "+DTOC(datumod)+"-"+DTOC(datumdo)',KUMPATH)
      nDuz77PS := VAL(IzFMKINI("PromjeneSkraceno","Duzina","27",KUMPATH))
      AADD(ImeKol, { "P R O M J E N E",  {|| StProm2()}, .f., "P", nDuz77PS , 0  })
    ELSE
      AADD(ImeKol, { "P R O M J E N E",  {|| StProm()}, .f., "P", 70, 0  })
    ENDIF
    AADD(Kol,len(imekol))
   endif

   private cDodKol:="N"
   if Pitanje(,"Prikazati dodatnu kolonu ?","N")=="D"
    c77DP1:=PADR("POL.STR.ISPIT",30)
    c77DP2:=PADR('IF(ImaPromjenu("S2",KADEV_0->id),"DA","")',100)
    c77DP3:="C"; c77DP4:=15; c77DP5:=0
    nObl:=SELECT()
    O_PARAMS
    Private cSection:="2",cHistory:=" ",aHistory:={}
    Params1()
    RPar("c1",@c77DP1); RPar("c2",@c77DP2); RPar("c3",@c77DP3)
    RPar("c4",@c77DP4); RPar("c5",@c77DP5)
    c77DP2:=PADR(c77DP2,100)
    if VarEdit({ {"Naziv kolone","c77DP1","","",""},;
                 {"Formula","c77DP2","","@!S50",""},;
                 {"Tip varijable (C/N/D/P)","c77DP3","c77DP3$'CNDP'","@!",""},;
                 {"Sirina kolone (br.znakova)","c77DP4","c77DP4>0","99",""},;
                 {"Ako je numericki podatak, broj decimala je","c77DP5","","9",""} },;
                 11,1,19,78,"DEFINICIJA DODATNE KOLONE","B1")

      cDodKol:="D"
      // dodati kolonu bez
      AADD(ImeKol, { c77DP1,  {|| StDodKol()}, .f., c77DP3, c77DP4, c77DP5  })
      AADD(Kol,len(imekol))
      if Params2()
       WPar("c1",@c77DP1); WPar("c2",@c77DP2); WPar("c3",@c77DP3)
       WPar("c4",@c77DP4); WPar("c5",@c77DP5)
      endif
      select params; use
    else
      cDodKol:="N"
    endif
    SELECT (nObl)
   endif

   Izlaz("Pregled evidencije na dan "+dtoc(date())+" godine.","pregled",,.f.)

   if cDN=="D"
    ASIZE(ImeKol,len(imekol)-1)
    ASIZE(Kol,len(kol)-1)
   endif

   if cDodKol=="D"
    ASIZE(ImeKol,len(imekol)-1)
    ASIZE(Kol,len(kol)-1)
   endif

    kadev_o_tables()
    kadev_search_data_relation()

    PopWa()

   return DE_CONT
 else
   return DE_CONT
 endif
return

FUNCTION StDodKol()
RETURN &(c77DP2)

FUNCTION ImaPromjenu(cPromjena,cRadnik,lSamoInf)
  LOCAL lIma:=.f., nRec
  IF lSamoInf==NIL; lSamoInf:=.f.; ENDIF
  PushWA()
  SELECT KADEV_1
  IF lSamoInf; nRec:=RECNO(); ENDIF
  SEEK cRadnik
  DO WHILE !EOF() .and. cRadnik==KADEV_1->id
    IF KADEV_1->idpromj == cPromjena
      lIma:=.t.
      EXIT
    ENDIF
    SKIP 1
  ENDDO
  IF lSamoInf; GO (nRec); ENDIF
  PopWA()
RETURN lIma

function StProm()
local cVrati:="",nOblast:=SELECT()
select kadev_1
seek kadev_0->id
do while !eof() .and. kadev_0->id==kadev_1->id
 if Tacno(aUsl1a).and.Tacno(aUsl1b).and.Tacno(aUsl1c).and.;
    Tacno(aUsl1d).and.Tacno(aUsl1e).and.Tacno(aUsl1f).and.Tacno(aUsl1g).and.;
    Tacno(aUsl1h).and.Tacno(aUsl1i).and.Tacno(aUsl1j).and.;
    Tacno(aUsl1k).and.Tacno(aUsl1l).and.Tacno(aUsl1m)
  cVrati:=cVrati+"Promjena:"+idpromj+" Rj-RMJ:"+idrj+"-"+idrmj+" Datum:"+DTOC(datumod)+"-"+DTOC(datumdo)+;
          " K:"+idk+" Atributi(N1,N2,C1,C2):"+STR(nAtr1)+","+STR(nAtr2)+","+catr1+","+catr2+;
          " Dokument:"+dokument+"  Opis:"+opis+" "+REPLICATE("�",69)+" "
 endif
 skip
enddo
select (nOblast)
return cVrati

function StProm2()
local cVrati:="", nOblast:=SELECT()
select kadev_1
seek kadev_0->id
do while !eof() .and. kadev_0->id==kadev_1->id
 if Tacno(aUsl1a).and.Tacno(aUsl1b).and.Tacno(aUsl1c).and.;
    Tacno(aUsl1d).and.Tacno(aUsl1e).and.Tacno(aUsl1f).and.Tacno(aUsl1g).and.;
    Tacno(aUsl1h).and.Tacno(aUsl1i).and.Tacno(aUsl1j).and.;
    Tacno(aUsl1k).and.Tacno(aUsl1l).and.Tacno(aUsl1m)
  cVrati:=cVrati+PADR(&cPom77PS,nDuz77PS-1,".")+" "
 endif
 skip
enddo
select (nOblast)
return cVrati

function pGET1()
@  m_x+1, m_y+2 SAY " 1. Prezime                   "    GET qqPrezime PICTURE cPic
@  m_x+3, m_y+2 SAY " 2. Ime jednog roditelja      "    GET qqImeRod  PICTURE cPic
@  m_x+5, m_y+2 SAY " 3. Ime "  GET qqIme     PICTURE cPic
@  m_x+5, COL()+2 SAY "Pol"    GET qqPol     PICTURE "@!S5"
@  m_x+5, COL()+2 SAY " Krv  "    GET qqKrv     PICTURE "@!S9"
@  m_x+7 ,m_y+2 SAY " 4. Jedinstveni mat.broj      "    GET qqId      PICTURE cPic
@  m_x+9 ,m_y+2 SAY " 5. Datum rodjenja            "    GET qqDatRodj PICTURE cPic
@  m_x+11,m_y+2 SAY " 6. Mjesto rodjenja           "    GET qqMjRodj  PICTURE cPic
@  m_x+13,m_y+2 SAY " 7. Broj Licne karte          "    GET qqBrLK    PICTURE cPic
@  m_x+15,m_y+2 SAY " 8. Adresa stanovanja         "
@  m_x+16,m_y+2 SAY "  a) mjesto                   "    GET qqMjSt    PICTURE cPic
@  m_x+17,m_y+2 SAY "  b) mjesna zajednica         "    GET qqIdMZSt  PICTURE cPic
@  m_x+18,m_y+2 SAY "  c) ulica                    "    GET qqUlSt    PICTURE cPic
@  m_x+19,m_y+2 SAY "  d) broj kucnog telefona     "    GET qqBrTel1  PICTURE cPic
@  m_x+21,m_y+2 SAY " 9. Zanimanje                 "    GET qqIdZanim    PICTURE cPic
@  m_x+22,m_y+2 SAY "9b. Strucna sprema            "    GET qqIdStrSpr   PICTURE cPic
read
return LastKey()

function pGET2()
@  m_x+1, m_y+2 SAY "10. Radna jedinica RJ         "    GET qqIdRj       PICTURE cPic
@  m_x+2, m_y+2 SAY "11. Radno mjesto RMJ          "    GET qqidRMJ      PICTURE cPic
@  m_x+3, m_y+2 SAY "11. Rad.Staz Efekt.           "    GET qqRStE       PICTURE cPic
@  m_x+4, m_y+2 SAY "11. Rad.Staz Benef.           "    GET qqRStB       PICTURE cPic
@  m_x+5, m_y+2 SAY "12. Na radnom mjestu od       "    GET qqDatURMJ    PICTURE cPic
@  m_x+6, m_y+2 SAY "13. Van firme od              "    GET qqDatVRMJ    PICTURE cPic
@  m_x+7, m_y+2 SAY "13. Status ...............    "    GET qqStatus     PICTURE cPic
@  m_x+8, m_y+2 SAY "14. broj telefona /2          "    GET qqBrTel2     PICTURE cPic
@  m_x+9, m_y+2 SAY "15. broj telefona /3          "    GET qqBrTel3     PICTURE cPic

@  m_x+11,m_y+2 SAY "SISTEMATIZACIJA"
@  m_x+12,m_y+2 SAY "a) Broj izvrsilaca            "    GET qqBrIzvrs    PICTURE cPic
@  m_x+13,m_y+2 SAY "b) Strucna sprema od          "    GET qqSSSOd      PICTURE cPic
@  m_x+14,m_y+2 SAY "c) Strucna sprema do          "    GET qqSSSDo      PICTURE cPic
@  m_x+15,m_y+2 SAY "d) Broj bodova                "    GET qqBodova     PICTURE cPic
@  m_x+16,m_y+2 SAY "e) IDK1-karakterist. rmj /1   "    GET qqSIdK1      PICTURE cPic
@  m_x+17,m_y+2 SAY "f) IDK2-karakterist. rmj /2   "    GET qqSIdK2      PICTURE cPic
@  m_x+18,m_y+2 SAY "g) Stopa benef.radnog staza   "    GET qqStBRst     PICTURE cPic
@  m_x+19,m_y+2 SAY "h) Vrsta strucne spreme /1    "    GET qqVSS1       PICTURE cPic
@  m_x+20,m_y+2 SAY "i) Vrsta strucne spreme /2    "    GET qqVSS2       PICTURE cPic
@  m_x+21,m_y+2 SAY "j) Vrsta strucne spreme /3    "    GET qqVSS3       PICTURE cPic
@  m_x+22,m_y+2 SAY "k) Vrsta strucne spreme /4    "    GET qqVSS4       PICTURE cPic




read
return LastKey()

function pGet3()
@  m_x+ 1,m_y+2 SAY "16.PORODICA, OPSTI PODACI"
@  m_x+ 4,m_y+2 SAY "  a) Bracno stanje            "    GET qqBracSt  PICTURE cPic
@  m_x+ 5,m_y+2 SAY "  b) Broj djece               "    GET qqBrDjece PICTURE cPic
@  m_x+ 6,m_y+2 SAY "  c) Stambene prilike         "    GET qqStan    PICTURE cPic
@  m_x+ 7,m_y+2 SAY "  d) "+gDodKar1+"         "    GET qqidK1    PICTURE cPic
@  m_x+ 8,m_y+2 SAY "  e) "+gDodKar2+"         "    GET qqidK2    PICTURE cPic
@  m_x+ 9,m_y+2 SAY "  f) Karakt. (opisno).....    "    GET qqKOp1    PICTURE cPic
@  m_x+10,m_y+2 SAY "  g) Karakt. (opisno).....    "    GET qqKOp2    PICTURE cPic

@  m_x+12,m_y+2 SAY "17. ODBRANA"
@  m_x+14,m_y+2 SAY "  a) Ratni raspored         # "    GET qqRRasp   PICTURE cPic
@  m_x+15,m_y+2 SAY "  b) Sluzio vojni rok (D/N)   "    GET qqSlVr    PICTURE cPic
@  m_x+16,m_y+2 SAY "  c) Vrijeme sluzenja v/r     "    GET qqVrSlVr  PICTURE cPic
@  m_x+17,m_y+2 SAY "  d) "+IF(glBezvoj,"Pozn.rada na racun.(D/N) ","Sposoban za voj.sl.(D/N) ")    GET qqSposVSl PICTURE cPic
@  m_x+18,m_y+2 SAY "  e) "+IF(glBezVoj,"Poznavanje str.jezika ","VES                   ")+" # "    GET qqIdVES   PICTURE cPic
@  m_x+19,m_y+2 SAY "  f) CIN                    # "    GET qqIdCin   PICTURE cPic
@  m_x+20,m_y+2 SAY "  g) "+IF(glBezVoj,"Otisli bi iz firme?      ","Naz.sekretarijata odbr.  ")    GET qqNazSekr PICTURE cPic


read
return LastKey()


function pGET4()
@  m_x+ 1,m_y+2 SAY "******* PROMJENE: *********"
@  m_x+ 3,m_y+2 SAY "Promjena       #"                  GET qqIdPromj    PICTURE cPic
@  m_x+ 4,m_y+2 SAY "Karakteristika  "                  GET qqIdK        PICTURE cPic
@  m_x+ 5,m_y+2 SAY "Datum Od        "                  GET qqDatumOd    PICTURE cPic
@  m_x+ 6,m_y+2 SAY "Datum Do        "                  GET qqDatumDo    PICTURE cPic
@  m_x+ 7,m_y+2 SAY "Dokument        "                  GET qqDokument   PICTURE cPic
@  m_x+ 8,m_y+2 SAY "Opis            "                  GET qqOpis       PICTURE cPic
@  m_x+ 9,m_y+2 SAY "Nadlezan        "                  GET qqNadlezan   PICTURE cPic
@  m_x+10,m_y+2 SAY "RJ             #"                  GET qqIDRj1      PICTURE cPic
@  m_x+11,m_y+2 SAY "RMJ            #"                  GET qqIDRMj1     PICTURE cPic
@  m_x+13,m_y+2 SAY "N.Atribut     /1"                  GET qqnAtr1      PICTURE cPic
@  m_x+14,m_y+2 SAY "N.Atribut     /2"                  GET qqnAtr2      PICTURE cPic
@  m_x+16,m_y+2 SAY "C.Atribut/1 (ratni raspored ili stepen str.spr.)" GET qqcAtr1 PICTURE "@!S20"
@  m_x+17,m_y+2 SAY "C.Atribut/2 (zanimanje)                         " GET qqcAtr2 PICTURE "@!S20"
read
return LastKey()

function pGET5()
@  m_x+ 1,m_y+2 SAY "Nacin sortiranja:"
@  m_x+ 3,m_y+4 SAY "A - Prezime, ImeRoditelja, Ime "
@  m_x+ 4,m_y+4 SAY "B - RJ,RMJ, Prezime"
@  m_x+ 5,m_y+4 SAY "C - RJ, Prezime"
@  m_x+ 6,m_y+4 SAY "D - Maticni-ID broj, Prezime"
@  m_x+ 7,m_y+4 SAY "E - Str.Sprema, Zanimanje, Prezime"
@  m_x+ 8,m_y+4 SAY "F - ID2 (mat.broj 2) ..........................."   GET  qqsort1  ;
                         VALID qqsort1 $ "ABCDEF"  PICTURE  "@!"
read
return LastKey()


// --------------------------------------------
// stampa kartona
// --------------------------------------------
function Karton( bFor ) // nije bas bfor - vise bi odgovaralo bWhile
local cTekst
local nPom:=0

// vidjeti sta je ovo ????!??????
IniRPT()

cImeFajla := ALLTRIM(IzborFajla(my_home()+"*.def"))

IF EMPTY(cImeFajla)
	Ch:=0
  	return nil
ELSE
  	cImefajla := my_home()+cImefajla
  	cTekst:=MEMOREAD(cImeFajla)
  	DO WHILE .t.
   		nPom:=AT("#",cTekst)
   		IF nPom!=0
     			AADD( aTijeloP , Blokovi(SUBSTR(cTekst,nPom+1,2)) )
     			cTekst:=SUBSTR(cTekst,nPom+3)
   		ELSE
     			EXIT
   		ENDIF
  	ENDDO
ENDIF

// init detaila
nCDet1:=0
AADD(aDetInit,{|| nCDet1:=0, PushWA(), dbselectArea(F_KADEV_1),dbseek(kadev_0->id) } )

// uslov detaila
AADD(aDetUsl,{|| id=kadev_0->id})

// calc detaila
AADD(aDetCalc,{|| nCDet1++ } )

// for izraz
AADD(aDetFor, {|| Tacno(aUsl1a) .and. Tacno(aUsl1b) .and. Tacno(aUsl1c) .and.;
                  Tacno(aUsl1d) .and. Tacno(aUsl1f) .and. Tacno(aUsl1g) .and.;
                  Tacno(aUsl1h) .and. Tacno(aUsl1i) .and. Tacno(aUsl1j) .and.;
                  Tacno(aUsl1k) .and. Tacno(aUsl1l) .and. Tacno(aUsl1m) ;
               } )

// kraj detaila
AADD(aDetEnd,{|| PopWa() } )

// polja detail
AADD(aDetP,{ {|| datumOD}, {|| DatumDo}, {|| IdPromj},;
             {|| P_Promj(IdPromj,-2)}, {|| IdK},{|| IdRj}, {|| IdRmj},;
             {|| nAtr1},{|| nAtr2},{|| cAtr1},{|| cAtr2}, ;
             {|| Dokument},{|| Opis}, {|| Nadlezan},;
              ;
           } )

select (F_KADEV_0)

START PRINT RET
IF gPrinter=="L"
	gPO_Land()
ENDIF

R2(cImeFajla,"PRN",bFor,2)

IF gPrinter=="L"
	gPO_Port()
ENDIF

ENDPRINT
select (F_KADEV_0)

return nil



function Blokovi(cIndik)
 LOCAL bVrati
 DO CASE
   CASE cIndik=="01"
      bVrati:={|| (nArr)->prezime}
   CASE cIndik=="02"
      bVrati:={|| (nArr)->ImeRod}
   CASE cIndik=="03"
      bVrati:={|| (nArr)->Ime}
   CASE cIndik=="04"
      bVrati:={|| (nArr)->Pol}
   CASE cIndik=="05"
      bVrati:={|| (nArr)->id}
   CASE cIndik=="06"
      bVrati:={|| (nArr)->id2}
   CASE cIndik=="07"
      bVrati:={|| (nArr)->BrLk}
   CASE cIndik=="08"
      bVrati:={|| (nArr)->DatRodj}
   CASE cIndik=="09"
      bVrati:={|| (nArr)->MjRodj}
   CASE cIndik=="10"
      bVrati:={|| (nArr)->IdNac }
   CASE cIndik=="11"
      bVrati:={||  kdv_nac->naz     }
   CASE cIndik=="12"
      bVrati:={|| (nArr)->IDStrspr}
   CASE cIndik=="13"
      bVrati:={|| strspr->naz}
   CASE cIndik=="14"
      bVrati:={|| STR(aRE[1],2)+"g."+STR(aRE[2],2)+"m."+STR(aRE[3],2)+"d."}
   CASE cIndik=="15"
      bVrati:={|| STR(aRB[1],2)+"g."+STR(aRB[2],2)+"m."+STR(aRB[3],2)+"d."}
   CASE cIndik=="16"
      bVrati:={|| STR(aRU[1],2)+"g."+STR(aRU[2],2)+"m."+STR(aRU[3],2)+"d."}
   CASE cIndik=="17"
      bVrati:={|| (nArr)->Idzanim}
   CASE cIndik=="18"
      bVrati:={|| kdv_zanim->naz}
   CASE cIndik=="19"
      bVrati:={|| (nArr)->idrj}
   CASE cIndik=="20"
      bVrati:={|| kdv_rj->naz}
   CASE cIndik=="21"
      bVrati:={|| (nArr)->idrmj}
   CASE cIndik=="22"
      bVrati:={|| kdv_rmj->naz}
   CASE cIndik=="23"
      bVrati:={|| (nArr)->datUrmj}
   CASE cIndik=="24"
      bVrati:={|| (nArr)->datVRmj}
   CASE cIndik=="25"
      bVrati:={|| (nArr)->mjSt}
   CASE cIndik=="26"
      bVrati:={|| (nArr)->idMzSt}
   CASE cIndik=="27"
      bVrati:={||  kdv_mz->naz}
   CASE cIndik=="28"
      bVrati:={|| (nArr)->UlSt}
   CASE cIndik=="29"
      bVrati:={|| (nArr)->BrTel1}
   CASE cIndik=="30"
      bVrati:={|| (nArr)->BrTel2}
   CASE cIndik=="31"
      bVrati:={|| (nArr)->BrTel3}
   CASE cIndik=="32"
      bVrati:={|| (nArr)->IdK1}
   CASE cIndik=="33"
      bVrati:={|| kdv_k1->naz}
   CASE cIndik=="34"
      bVrati:={|| (nArr)->IdK2}
   CASE cIndik=="35"
      bVrati:={|| kdv_k2->naz}
   CASE cIndik=="36"
      bVrati:={|| (nArr)->kOp1}
   CASE cIndik=="37"
      bVrati:={|| (nArr)->kOp2}
   CASE cIndik=="38"
      bVrati:={|| (nArr)->Status}
   CASE cIndik=="39"
      bVrati:={|| (nArr)->BracSt}
   CASE cIndik=="40"
      bVrati:={|| (nArr)->Stan}
   CASE cIndik=="41"
      bVrati:={|| (nArr)->BrDjece}
   CASE cIndik=="42"
      bVrati:={|| (nArr)->Krv   }
   CASE cIndik=="43"
      bVrati:={|| (nArr)->SposVSl}
   CASE cIndik=="44"
      bVrati:={|| (nArr)->NazSekr}
   CASE cIndik=="45"
      bVrati:={|| (nArr)->SlVr}
   CASE cIndik=="46"
      bVrati:={|| STR(aVrSlVr[1],2)+"g."+STR(aVrSlVr[2],2)+"m."+STR(aVrSlVr[3],2)+"d."}
   CASE cIndik=="47"
      bVrati:={|| (nArr)->IdRRasp}
   CASE cIndik=="48"
      bVrati:={|| kdv_rrasp->naz}
   CASE cIndik=="49"
      bVrati:={|| (nArr)->IdCin}
   CASE cIndik=="50"
      bVrati:={|| kdv_cin->naz}
   CASE cIndik=="51"
      bVrati:={|| (nArr)->IdVes}
   CASE cIndik=="52"
      bVrati:={|| kdv_ves->naz}
   CASE cIndik=="53"
      bVrati:={|| DTOC(Date())}
   CASE cIndik=="54"
      bVrati:={|| (nArr)->(PADC(trim(Prezime)+;
               " ("+trim(imeRod)+") "+trim(ime),35)) }
   CASE cIndik=="55"
      bVrati:={|| kdv_RJRMJ->bodova}
   CASE cIndik=="56"
      bVrati:={|| (nArr)->datuf}
   CASE cIndik=="57"
      bVrati:={|| StrSprPP()}
   CASE cIndik=="58"
      bVrati:={|| IF(ImaPromjenu("S2",(nArr)->id,.t.),"DA","NE") }
 ENDCASE
RETURN bVrati


function TacnoNO(cIzraz,bIni,bWhile,bSkip,bEnd)
 LOCAL i, fRez:=.f.
 PRIVATE cPom

 IF UPPER(cizraz)=".T."; RETURN .T.; ENDIF
 EVAL(bIni)

 DO WHILE EVAL(bWhile)
   fRez:=&cIzraz
   IF fRez; RETURN .T.; ENDIF
   EVAL(bSkip)
 ENDDO

 EVAL(bEnd)
RETURN .F.



PROCEDURE BirajPrelom()
 LOCAL GetList:={}
 Box(,23,77)
  @ m_x+0, m_y+1 SAY "IZABRALI STE KOLONE, SADA PODESITE NJIHOVU SIRINU AKO JE POTREBNO"
  @ m_x+1, m_y+1 SAY PADR("KOLONA",40,".")+"LOMITI..SIRINA PRELOMA"
  FOR i:=1 TO LEN(RKol)
    c77:=ALLTRIM(STR(i))
    PRIVATE cPrelK&c77:=RKol[i,3], nSirK&c77:=RKol[i,4]
    @ m_x+i+1, m_y+1 SAY PADR(RKol[i,2],40,".") GET cPrelK&c77 VALID cPrelK&c77$"DN" PICT "@!"
    @ m_x+i+1, m_y+col()+10 GET nSirK&c77 WHEN cPrelK&c77=="D" PICT "999"
  NEXT
  READ
  IF LASTKEY()!=K_ESC
    FOR i:=1 TO LEN(RKol)
      c77:=ALLTRIM(STR(i))
      RKol[i,3]:=cPrelK&c77
      RKol[i,4]:=nSirK&c77
    NEXT
  ENDIF
 BoxC()
RETURN


// str.sprema predvi�ena pravilnikom
function StrSprPP()
local cV
 cV := "od "+KDV_RJRMJ->IdStrSprOd+" do "+KDV_RJRMJ->IdStrSprDo
 IF !EMPTY(KDV_RJRMJ->idzanim1)
   cV += ", "+TRIM(NazZanim(KDV_RJRMJ->idzanim1))
 ENDIF
 IF !EMPTY(KDV_RJRMJ->idzanim2)
   cV += ", "+TRIM(NazZanim(KDV_RJRMJ->idzanim2))
 ENDIF
 IF !EMPTY(KDV_RJRMJ->idzanim3)
   cV += ", "+TRIM(NazZanim(KDV_RJRMJ->idzanim3))
 ENDIF
 IF !EMPTY(KDV_RJRMJ->idzanim4)
   cV += ", "+TRIM(NazZanim(KDV_RJRMJ->idzanim4))
 ENDIF
RETURN cV



function NazZanim(cId)
local nArr:=SELECT()
local cN:="", nRec

SELECT KDV_ZANIM
nRec:=RECNO()
SEEK cId
cN:=naz
GO (nRec)
SELECT (nArr)
return cN




