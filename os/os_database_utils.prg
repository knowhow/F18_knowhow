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

#include "os.ch"


// ------------------------------------------------------
// ------------------------------------------------------
function PrenosOs()
local _t_rec
local _rec, _r_br

// nalazim se u tekucoj godini, zelim "slijepiti" promjene i izbrisati
// otpisana sredstva u protekloj godini

Beep(4)

if Pitanje(,"Brisanje otpisanih sredstva i promjena u toku protekle godine ! Nastaviti ?", "N" ) = "N"
    close all
    return
endif

if !sigmaSif("OSGEN")
    close all
    return
endif

START PRINT CRET

O_OS
O_PROMJ

? "Prolazim kroz bazu OS...."

select os
go top

do while !eof()

    _r_br := 0
    skip
    _t_rec := recno()
    skip -1

    //Scatter("w")  
    // za os
    
    _rec := dbf_get_rec()    

    // ispisi id, naz
    ? _rec["id"], _rec["naz"]
    
    _rec["nabvr"] := _rec["nabvr"] + _rec["revd"]
    _rec["otpvr"] := _rec["otpvr"] + _rec["revp"] + _rec["amp"]
    
    // brisi sta je otpisano
    IF !EMPTY( _rec["datotp"] )
        ?? "  brisem, otpisano"
        delete_rec_server_and_dbf( ALIAS(), _rec )
        go _t_rec
        LOOP
    ENDIF

    select promj
    hseek os->id

    do while !eof() .and. field->id == os->id
        _rec["nabvr"] += field->nabvr + field->revd
        _rec["otpvr"] += field->otpvr + field->revp + field->amp
        skip
    enddo

    select os

    _rec["amp"] := 0
    _rec["amd"] := 0
    _rec["revd"] := 0
    _rec["revp"] := 0

    update_rec_server_and_dbf( ALIAS(), _rec )

    go _t_rec

enddo 

// pobrisi sve promjene...
select promj
do while !EOF()
    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( ALIAS(), _rec )
    skip
enddo

close all

END PRINT

return


// -------------------------------------------
// -------------------------------------------
function RegenPS()

MsgBeep("Ova opcija je onemogucena #25358 !")
return

// regeneracija nabavne i otpisane vrijednosti za stara sredstva

Beep(4)

if Pitanje(,"Ponovo generisati nab.i otpisanu vrijednost sredstava iz prosle godine ?","N")="N"
  closeret
endif

if !sigmaSif("OSREGEN")
  closeret
endif

O_OSX

// naÐimo sve postojee sezone
// ---------------------------
aSezone := ASezona(KUMPATH)
cTekSez := goModul:oDatabase:cSezona
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
ASORT(aSezone,,,{|x,y| x[1]>y[1]})

IF LEN(aSezone)<1
  MsgBeep("Nema proçlih sezona!")
  CLOSERET
ENDIF

// interesuje me samo posljednja od svih postojeih proçlih sezona
cOldSez:=aSezone[1,1]

USE (KUMPATH+cOldSez+"\OS")    NEW ALIAS ("OS"+cOldSez)
  SET ORDER TO TAG "1"
USE (KUMPATH+cOldSez+"\PROMJ") NEW ALIAS ("PROMJ"+cOldSez)
  SET ORDER TO TAG "1"

START PRINT CRET

cMP:="9999999.99"

? "Prikaz razlika nastalih ponovnom generacijom nabavne i otp.vrijednosti"
?
? "R.broj³ Inv.broj ³       Naziv sredstva         ³Stara NabV³Stara OtpV³Nova NabV ³Nova OtpV ³Razlika NV³Razlika OV"
? " (1)  ³    (2)   ³            (3)               ³   (4)    ³   (5)    ³    (6)   ³    (7)   ³  (6)-(4) ³  (7)-(5) "
m:="------ ---------- ------------------------------ ---------- ---------- ---------- ---------- ---------- ----------"
? m
SELECT OS; GO TOP

nRbr:=0
nT1:=nT2:=nT3:=nT4:=nT5:=nT6:=0
DO WHILE !EOF()
  SKIP; nTRec:=RECNO(); SKIP -1
  cInvBr:=id    // OS->id
  SELECT ("OS"+cOldSez)
   HSEEK cInvBr
   lIma:=lImaP:=.f.
   IF FOUND()
     lIma:=.t.
     SELECT ("PROMJ"+cOldSez)
      HSEEK cInvBr
      IF FOUND()
        lImaP:=.t.
      ENDIF
   ENDIF
  SELECT OS
  IF lIma
    // promijeni NABVR i OTPVR
    ++nRBr
    Scatter("w")
     ? STR(nRBr,5)+".", wid, naz, TRANS(wNabVr,cMP), TRANS(wOtpVr,cMP)
     nDifNV:=-wNabVr; nDifOV:=-wOtpVr
      nT1+=wNabVr; nT2+=wOtpVr
     wNabVr:=("OS"+cOldSez)->(Nabvr+revd); wOtpVr:=("OS"+cOldSez)->(Otpvr+revp+Amp)
     IF lImaP
       SELECT ("PROMJ"+cOldSez)
       DO WHILE !EOF() .AND. id==cInvBr
         wNabVr+=nabvr+revd
         wOtpVr+=otpvr+revp+amp
         SKIP 1
       ENDDO
       SELECT OS
     ENDIF
      nT3+=wNabVr; nT4+=wOtpVr
     nDifNV+=wNabVr; nDifOV+=wOtpVr
      nT5+=nDifNV; nT6+=nDifOV
     ?? "", TRANS(wNabVr,cMP), TRANS(wOtpVr,cMP), TRANS(nDifNV,cMP),;
        TRANS(nDifOV,cMP)
     wAmp:=wAmd:=0
     wRevD:=wRevP:=0
    Gather("w")
  ENDIF
  SELECT OS
  GO nTrec
ENDDO // EOF
? m
? PADL("UKUPNO",LEN(id+naz)+8), TRANS(nT1,cMP), TRANS(nT2,cMP),;
  TRANS(nT3,cMP), TRANS(nT4,cMP), TRANS(nT5,cMP), TRANS(nT6,cMP)

close all

END PRINT
RETURN


// -----------------------------------------------------------
// vraca niz poddirektorija koji nemaju ekstenziju u nazivu
// a nalaze se u direktoriju cPath (npr. "c:\sigma\fin\kum1\")
// -----------------------------------------------------------
static function ASezona(cPath)
 LOCAL aSezone
  aSezone := DIRECTORY(cPath+"*.","DV")
  FOR i:=LEN(aSezone) TO 1 STEP -1
    IF aSezone[i,1]=="." .or. aSezone[i,1]==".."
      ADEL(aSezone,i)
      ASIZE(aSezone,LEN(aSezone)-1)
    ENDIF
  NEXT
RETURN aSezone



// -----------------------------------------
// -----------------------------------------
function Unifid()
// unificiraj invent. brojeve
local nTrec, nTSRec
local nIsti
O_OS
set order to tag "1"
do while !eof()
  cId:=id
  nIsti:=0
  do while !eof() .and. id==cid
    ++nIsti
    skip
  enddo
  if nisti>1  // ima duplih slogova
    seek cid // prvi u redu
    nProlaz:=0
    do while !eof() .and. id==cid
      skip
      ++nProlaz
      nTrec:=recno()   // sljedeci
      skip -1
      nTSRec:=recno()
      cNovi:=""
      if len(trim(cid))<=8
        cNovi:=trim(id)+idrj
      else
        cNovi:=trim(id)+chr(48+nProlaz)
      endif
      seek cnovi
      if found()
        msgbeep("vec postoji "+cid)
      else
        go nTSRec
        replace id with cnovi
      endif
      go nTrec
    enddo
  endif

enddo
return


function NovaSredstva()
// daje listu sredstava kojih nema u prethodnoj sezoni
local lSamoStara:=.f.

if Pitanje(,"Prikazati samo sredstva iz proteklih godina? (D/N)","D")=="D"
    lSamoStara:=.t.
endif

O_OSX

// nadjimo sve postojece sezone
// ----------------------------
aSezone := ASezona(KUMPATH)
cTekSez := goModul:oDatabase:cSezona
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
ASORT(aSezone,,,{|x,y| x[1]>y[1]})

IF LEN(aSezone)<1
  MsgBeep("Nema proslih sezona!")
  CLOSERET
ENDIF

// interesuje me samo posljednja od svih postojecih proslih sezona
cOldSez:=aSezone[1,1]

USE (KUMPATH+cOldSez+"\OS")    NEW ALIAS ("OS"+cOldSez)
  SET ORDER TO TAG "1"
USE (KUMPATH+cOldSez+"\PROMJ") NEW ALIAS ("PROMJ"+cOldSez)
  SET ORDER TO TAG "1"

START PRINT CRET

cMP:="9999999.99"

? "Prikaz sredstava iz tekuce sezone kojih nema u prethodnoj sezoni"
?
SELECT OS; GO TOP

nRbr:=0
nT1:=nT2:=nT3:=nT4:=nT5:=nT6:=0
? "Inv.broj     Datum     Nab.vr.    Otp.vr."
DO WHILE !EOF()
  if (lSamoStara .and. YEAR(field->datum)>=VAL(cTekSez))
    skip 1
    loop
  endif
  cInvBr:=id    // OS->id
  SELECT ("OS"+cOldSez)
   HSEEK cInvBr
   IF !FOUND()
     ? OS->id, os->datum, TRANSFORM(os->nabVr,cMP), TRANSFORM(os->otpVr,cMP)
     nT1+=os->nabVr
     nT2+=os->otpVr
   ENDIF
  SELECT OS
  skip 1
ENDDO // EOF
?
? PADR("UKUPNO",LEN(field->id)+9), TRANSFORM(nT1,cMP), TRANSFORM(nT2,cMP)
close all

END PRINT
RETURN


function IzbrisanaSredstva()
// daje listu sredstava kojih nema u novoj sezoni

O_OSX

// nadjimo sve postojece sezone
// ----------------------------
aSezone := ASezona(KUMPATH)
cTekSez := goModul:oDatabase:cSezona
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
ASORT(aSezone,,,{|x,y| x[1]>y[1]})

IF LEN(aSezone)<1
  MsgBeep("Nema proslih sezona!")
  CLOSERET
ENDIF

// interesuje me samo posljednja od svih postojecih proslih sezona
cOldSez:=aSezone[1,1]

USE (KUMPATH+cOldSez+"\OS")    NEW ALIAS ("OS"+cOldSez)
  SET ORDER TO TAG "1"
USE (KUMPATH+cOldSez+"\PROMJ") NEW ALIAS ("PROMJ"+cOldSez)
  SET ORDER TO TAG "1"

START PRINT CRET

cMP:="9999999.99"

? "Prikaz sredstava iz prethodne sezone kojih nema u tekucoj sezoni"
?
SELECT ("OS"+cOldSez)
GO TOP

nRbr:=0
nT1:=nT2:=nT3:=nT4:=nT5:=nT6:=0
? "Inv.broj     Datum     Nab.vr.    Otp.vr.     Amort."
DO WHILE !EOF()
  cInvBr:=id    // OS->id
  SELECT OS
   HSEEK cInvBr
   IF !FOUND()
     SELECT ("OS"+cOldSez)
     ? field->id, field->datum, TRANSFORM(field->nabVr,cMP), TRANSFORM(field->otpVr,cMP), TRANSFORM(field->amP,cMP)
     nT1+=field->nabVr
     nT2+=field->otpVr
     nT3+=field->amP
   ENDIF
  SELECT ("OS"+cOldSez)
  skip 1
ENDDO // EOF
?
? PADR("UKUPNO",LEN(field->id)+9), TRANSFORM(nT1,cMP), TRANSFORM(nT2,cMP), TRANSFORM(nT3,cMP)
close all

END PRINT
RETURN


function RazdvojiDupleInvBr()
if sigmasif("UNIF")
    if pitanje(,"Razdvojiti duple inv.brojeve ?","N")=="D"
        UnifId()
    endif
endif
return


function GenerisanjePodatakaZaNovuSezonu()
PrenosOs()
return


function RegenerisanjePocStanja()
RegenPS()
return



