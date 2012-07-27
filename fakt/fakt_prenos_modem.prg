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


#include "fakt.ch"


function fakt_prenos_modem(fSif)
local nRec

if gModemVeza $ "SK" .and. Pitanje(,"Izvrsiti prenos za modem ?","D")=="D"
 
if fSif==NIL;  fSif:=.f.; endif

if fSif; O_FAKT_PRIPR; endif

select fakt_pripr
copy structure extended to struct
use

select (F__FAKT)
create (PRIVPATH+"_fakt") from struct
use

O__FAKT
zap


if !fsif // iz pripreme -> fakt

select (F_ROBA)
if !used(); use (SIFPATH+"roba"); endif

select fakt_pripr; go top
do while !eof()
  select _fakt; scatter()
  select fakt_pripr; scatter()
  NSRNPIdRoba()
  select roba
  _MPC:=roba->mpc;  _MPC2:=roba->mpc2
  if roba->(fieldpos("MPC3"))<>0
    _MPC3:=roba->mpc3
  endif
  if roba->(fieldpos("VPC2"))<>0
    _VPC2:=roba->vpc2
  endif
  _VPC:=roba->vpc
  _Robnaz:=roba->naz; _jmj:=roba->jmj
  _idtarifa:=roba->idtarifa
  select _fakt
  dbappend();  gather()
  select fakt_pripr; skip
enddo

endif // !fsif

select _fakt; use

select fakt_pripr; go top
if fsif
  cDestMod:=right(dtos(date()),4)  // 1998 1105  - 11 mjesec, 05 dan
else
  cDestMod:=right(dtos(pripr->datdok),4)  // 1998 1105  - 11 mjesec, 05 dan
endif
cDestMod:="PRENOS\"+gmodemveza+"F"+cDestMod  // PRENOS\SF1205

dirmak2(KUMPATH+"PRENOS") // napravi direktorij prenos !!!

usex (PRIVPATH+"_FAKT.DBF", "nFAKT")
fIzadji:=.f.
// donja for-next pelja otvara baze i , ako postoje, gleda da li je
// u njih pohranjen isti dokument
for i:=1 to 25

   bErr:=ERRORBLOCK({|o| MyErrH(o)})
   begin sequence
     usex ( KUMPATH+cDestMod+chr(64+i), "NEW" )
     // OD A-C
     if nFAKT->(idfirma+idtipdok+brdok)==oFAKT->(idfirma+idtipdok+brdok)
       fIzadji:=.t.
     endif
     use
   recover
     fizadji:=.t.
     // ako ne prodje use onda je prazno
   end sequence
   bErr:=ERRORBLOCK(bErr)
   if fizadji; exit; endif
next
cDestMod:=cDestMod+chr(64+i)
select nFAKT; use
cDestMod:=KUMPATH+cDestMod+".DBF"


filecopy(PRIVPATH+"_FAKT.DBF",cDestMod)
filecopy(strtran(PRIVPATH+"_FAKT.DBF",".DBF",".FPT"), strtran(cDestMod,".DBF",".FPT"))

cDestMod:=strtran(cDestMod,".DBF",".TXT")
filecopy(PRIVPATH+"outf.txt",cDestMod)

cDestMod:=strtran(cDestMod,".TXT",".DBF")
MsgBeep("Datoteka "+cDestMod+"je izgenerisana")


endif
return nil


/*! \fn PovModem()
 *  \brief
 */
 
function PovModem()
*{
local nRec, cPath

if gmodemveza=="N"
  MsgBeep("Nije podesena modemska veza!")
  return .f.
endif

cPath:=KUMPATH+"PRENOS\"

// modemska veza ide u odabir dokumenta
OPCF:={}
private H

aFiles:=DIRECTORY(cPath+iif(gModemVeza=="S","K","S")+"F*.dbf")

ASORT(aFiles,,,{|x,y| x[3]>y[3] })      // datum
BrisiSFajlove(cPath)
BrisiSFajlove(strtran(cPath,":\",":\CHK\"))

//  KT0512.DBF = elem[1]
AEVAL(aFiles,  {|elem| AADD(opcF,PADR(elem[1],15)+iif(UChkPostoji(trim(cPath)+trim(elem[1])),"R","X")+" "+dtos(elem[3]))},1,20)   // samo 20 najnovijih
ASORT(OPCF,,,{|x,y| right(x,10)>right(y,10)})  // datumi

h:=ARRAY(LEN(OPCF))
for i:=1 to len(h)
  h[i]:=""
next
// elem 3 - datum
// elem 4 - time
if len(opcf)==0
  MsgBeep("U direktoriju za prenos nema podataka")
  close all
  return .f.
endif

// CITANJE
Izb3:=1
fPrenesi:=.f.
do while .t.
 Izb3:=Menu("k2p",opcF,Izb3,.f.)

 if Izb3==0
   exit
 else
   cPrenosDBF:=trim(cPath)+trim(left(opcf[izb3],15))
   save screen to cS
   Vidifajl(strtran(cPrenosDBF,".DBF",".TXT"))  // vidi TK1109.TXT
   restore screen from cS
   if Pitanje(,"Zelite li izvrsiti prenos ?","D")=="D"
       fPrenesi:=.t.
       Izb3:=0
   endif
 endif
enddo
if !fprenesi
  return .f.
endif

SELECT (F_FAKT_PRIPR)
if !used(); O_FAKT_PRIPR; endif

select (F_ROBA)
if !used(); O_ROBA; endif


usex (cPrenosDBF, "NEW")

if !eof() .and. empty(idtipdok+brdok)
   MsgBeep("Osvjezenje sifrarnika")
endif

do while !eof()
  select _fakt; scatter()
  if !empty(_idtipdok+_brdok)  // radi se o prenosu nekog dokumenta
    select fakt_pripr
    dbappend()
    gather()
  endif

  select _fakt
  if gmodemveza=="K"  // znaci, radi se o korisniku, osvjezi sifrarnik robe
     NSRNPIdRoba(_FAKT->IDROBA)
     select roba
     if !found()
       append blank
       replace id with _fakt->idroba
     endif
     REPLACE MPC WITH _FAKT->MPC, MPC2 WITH _FAKT->MPC2, VPC WITH _FAKT->VPC,;
             naz with _fakt->robnaz, jmj with _fakt->jmj, idtarifa with _Fakt->idtarifa
     if fieldpos("MPC3")<>0
        replace MPC3 WITH _FAKT->MPC3
     endif
     if fieldpos("VPC2")<>0
        replace VPC2 WITH _FAKT->VPC2
     endif
  endif
  select _fakt; skip
enddo

if gModemVeza $ "KS" .and. fprenesi
  select _fakt; use
  dirmak2(strtran(KUMPATH+"PRENOS\",":\",":\chk\"))
  filecopy(cPrenosDBF,strtran(trim(cPrenosDbf),":\",":\chk\"))
  // odradjeno-postavi kopiraj u chk direktorij
  // npr c:\fakt\prenos\2\x.dbf  -> npr c:\CHK\fakt\prenos\2\x.dbf
endif

closeret
*}




