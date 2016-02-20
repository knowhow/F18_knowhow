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


function StKalk41()
local nCol0:=nCol1:=nCol2:=0
local nPom:=0

if IsPDV()
    StKalk41PDV()
    return
endif

Private nMarza,nMarza2,nPRUC,aPorezi
nMarza:=nMarza2:=nPRUC:=0
aPorezi:={}

lVoSaTa := ( my_get_from_ini("KALK","VodiSamoTarife","N",PRIVPATH)=="D" )

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP

cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
Naslov4x()

select kalk_pripr

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
if cidvd<>'47' .and. !lVoSaTa
    m+=" ---------- ---------- ---------- ----------"
    IF lPrikPRUC
            m += " ----------"
    ENDIF
endif

? m

if cIdVd='47' .or. lVoSaTa
    ? "*R * ROBA     * Kolicina *    MPC   *   PPP %  *   PPU%   *   PP%    *  MPC     *"
    ? "*BR*          *          *          *   PPU    *   PPU    *   PP     *  SA Por  *"
    ? "*  *          *          *    sum   *    sum   *   sum    *          *   sum    *"
else
    IF lPrikPRUC
        ? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  * POREZ NA *    MPC   *   PPP %  *   PPU%   *   PP%    *MPC sa por*          *  MPC     *"
        ? "*BR*          *          *   U MP   *         *  MARZU   *          *   PPP    *   PPU    *   PP     * -Popust  *  Popust  *  SA Por  *"
        ? "*  *          *          *   sum    *         *    sum   *    sum   *    sum   *   sum    *          *   sum    *   sum    *   sum    *"
    ELSE
        ? "*R * ROBA     * Kolicina *  NAB.CJ  *  MARZA  *    MPC   *   PPP %  *   PPU%   *   PP%    *MPC sa por*          *  MPC     *"
        ? "*BR*          *          *   U MP   *         *          *   PPP    *   PPU    *   PP     * -Popust  *  Popust  *  SA Por  *"
        ? "*  *          *          *   sum    *         *    sum   *    sum   *   sum    *          *   sum    *   sum    *   sum    *"
    ENDIF
endif

? m

nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=0
nTot4a:=0

IF lVoSaTa
  private cIdd:=idpartner+idkonto+idkonto2
ELSE
  private cIdd:=idpartner+brfaktp+idkonto+idkonto2
ENDIF

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

/*
    IF lVoSaTa .and. idpartner+idkonto+idkonto2<>cidd .or.;
       !lVoSaTa .and. idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    ENDIF
*/

    // formiraj varijable _....
    Scatter()
    RptSeekRT()

    // izracunaj nMarza2
    Marza2R()
    KTroskovi()

Tarifa(pkonto, idRoba, @aPorezi)
aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)
nPor1:=aIPor[1]
nPor2:=aIPor[2]
nPor3:=aIPor[3]
nPRUC:=nPor2
// nMarza2:=nMarza2-nPRUC // ?!

    VTPorezi()

    DokNovaStrana(125, @nStr, 2)

    nTot3+=  (nU3:= IF(ROBA->tip="U",0,NC)*kolicina )
    nTot4+=  (nU4:= nMarza2*Kolicina )
    nTot4a+=  (nU4a:= nPRUC*Kolicina )
    nTot5+=  (nU5:= MPC*Kolicina )

    nTot6+=  (nU6:=(nPor1+nPor2+nPor3)*Kolicina)
    nTot7+=  (nU7:= MPcSaPP*Kolicina )

    nTot8+=  (nU8:= (MPcSaPP-RabatV)*Kolicina )
    nTot9+=  (nU9:= RabatV*Kolicina )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""
    ?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"
    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina PICTURE PicKol

    nCol0:=pcol()

    @ prow(),nCol0 SAY ""
    IF IDVD<>'47' .and. !lVoSaTa
     IF ROBA->tip="U"
       @ prow(),pcol()+1 SAY 0                   PICTURE PicCDEM
     ELSE
       @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
     ENDIF
     @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
     IF lPrikPRUC
       @ prow(),pcol()+1 SAY nPRUC             PICTURE PicCDEM
     ENDIF
    ENDIF
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY aPorezi[POR_PPP]      PICTURE PicProc
    @ prow(),pcol()+1 SAY PrPPUMP()             PICTURE PicProc
    @ prow(),pcol()+1 SAY aPorezi[POR_PP]     PICTURE PicProc
    if IDVD<>"47" .and. !lVoSaTa
     @ prow(),pcol()+1 SAY MPCSAPP-RabatV       PICTURE PicCDEM
     @ prow(),pcol()+1 SAY RabatV               PICTURE PicCDEM
    endif
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    @ prow()+1,4 SAY idTarifa
    @ prow(), nCol0 SAY ""
    IF cIDVD<>'47' .and. !lVoSaTa
     IF ROBA->tip="U"
       @ prow(), pcol()+1  SAY  0                picture picdem
     ELSE
       @ prow(), pcol()+1  SAY  nc*kolicina      picture picdem
     ENDIF
     @ prow(), pcol()+1  SAY  nmarza2*kolicina      picture picdem
     IF lPrikPRUC
       @ prow(),pcol()+1 SAY nPRUC*kolicina       PICTURE PicDEM
     ENDIF
    ENDIF
    @ prow(), pcol()+1 SAY  mpc*kolicina      picture picdem

    @ prow(),nCol1    SAY  nPor1*kolicina    picture piccdem
    @ prow(),pcol()+1 SAY  nPor2*kolicina    picture piccdem
    @ prow(),pcol()+1 SAY  nPor3*kolicina   PICTURE PiccDEM
    if IDVD<>"47" .and. !lVoSaTa
    @ prow(),pcol()+1 SAY  (mpcsapp-RabatV)*kolicina   picture picdem
    @ prow(),pcol()+1 SAY  RabatV*kolicina   picture picdem
    endif
    @ prow(),pcol()+1 SAY  mpcsapp*kolicina   picture picdem

    skip 1

enddo


DokNovaStrana(125, @nStr, 3)
? m
@ prow()+1,0        SAY "Ukupno:"

@ prow(),nCol0  say  ""
IF cIDVD<>'47' .and. !lVoSaTa
 @ prow(),pcol()+1      SAY  nTot3        picture       PicDEM
 @ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
 IF lPrikPRUC
   @ prow(),pcol()+1   SAY  nTot4a        picture       PicDEM
 ENDIF
endif
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
if cIDVD<>"47" .and. !lVoSaTa
    @ prow(),pcol()+1   SAY  nTot8        picture        PicDEM
    @ prow(),pcol()+1   SAY  nTot9        picture        PicDEM
endif
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

// Rekapitulacija tarifa

DokNovaStrana(125, @nStr, 10)
nRec:=recno()

RekTar41(cIdFirma, cIdVd, cBrDok, @nStr)

set order to tag "1"
go nRec
return
*}


/*
 * Rekapitulacija tarifa - nova fja
 */
function RekTar41(cIdFirma, cIdVd, cBrDok, nStr)
*{
local nTot1
local nTot2
local nTot3
local nTot4
local nTot5
local nTotP
local aPorezi

select kalk_pripr
set order to tag "2"
seek cIdfirma+cIdvd+cBrdok

m:="------ ---------- ---------- ----------  ---------- ---------- ---------- ---------- ---------- ----------"
? m
? "* Tar *  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *   PP     *  Popust * MPVSAPP *"
? m
nTot1:=0
nTot2:=0
nTot3:=0
nTot4:=0
nTot5:=0
nTot6:=0
nTot7:=0
nTot8:=0
// popust
nTotP:=0

aPorezi:={}
do while !eof() .and. cIdfirma+cIdvd+cBrDok==idfirma+idvd+brdok
  cIdTarifa:=idtarifa
  nU1:=0
  nU2:=0
  nU2b:=0
  nU3:=0
  nU4:=0
  nU5:=0
  nUp:=0
  select tarifa
  HSEEK cIdtarifa

  Tarifa(kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi)

  select kalk_pripr
  fVTV:=.f.
  do while !eof() .and. cIdfirma+cIdVd+cBrDok==idFirma+idVd+brDok .and. idTarifa==cIdTarifa

    select roba
    HSEEK kalk_pripr->idroba
    select kalk_pripr
    VtPorezi()

    Tarifa(kalk_pripr->pkonto, kalk_pripr->idRoba, @aPorezi)

        // mpc bez poreza
    nU1+=kalk_pripr->mpc*kolicina

    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

        // porez na promet
        nU2+=aIPor[1]*kolicina
        nU3+=aIPor[2]*kolicina
        nU4+=aIPor[3]*kolicina

    nU5+= kalk_pripr->MpcSaPP * kolicina
        nUP+= rabatv*kolicina

    nTot6 += (kalk_pripr->mpc - kalk_pripr->nc ) * kolicina

        skip
  enddo

  nTot1+=nU1
  nTot2+=nU2
  nTot3+=nU3
  nTot4+=nU4
  nTot5+=nU5
  nTotP+=nUP

  ? cIdtarifa

  @ prow(),pcol()+1   SAY aPorezi[POR_PPP] pict picproc
  @ prow(),pcol()+1   SAY PrPPUMP() pict picproc
  @ prow(),pcol()+1   SAY aPorezi[POR_PP] pict picproc

  nCol1:=pcol()
  @ prow(),nCol1 +1   SAY nU1 pict picdem
  @ prow(),pcol()+1   SAY nU2 pict picdem
  @ prow(),pcol()+1   SAY nU3 pict picdem
  @ prow(),pcol()+1   SAY nU4 pict picdem
  @ prow(),pcol()+1   SAY nUp pict picdem
  @ prow(),pcol()+1   SAY nU5 pict picdem
enddo

DokNovaStrana(125, @nStr, 4)
? m
? "UKUPNO"
@ prow(),nCol1+1    SAY nTot1 pict picdem
@ prow(),pcol()+1   SAY nTot2 pict picdem
@ prow(),pcol()+1   SAY nTot3 pict picdem
@ prow(),pcol()+1   SAY nTot4 pict picdem
// popust
@ prow(),pcol()+1   SAY nTotP pict picdem
@ prow(),pcol()+1   SAY nTot5 pict picdem
? m
if cIdVd<>"47" .and. !lVoSaTa
    ? "RUC:"
    @ prow(),pcol()+1 SAY nTot6 pict picdem
? m
endif

return
*}




function Naslov4x()
local cSvediDatFakt

B_ON

IF CIDVD=="41"
        ?? "IZLAZ IZ PRODAVNICE - KUPAC"
ELSEIF CIDVD=="49"
    ?? "IZLAZ IZ PRODAVNICE PO OSTALIM OSNOVAMA"
ELSEIF cIdVd=="43"
    ?? "IZLAZ IZ PRODAVNICE - KOMISIONA - PARAGON BLOK"
ELSEIF cIdVd=="47"
    ?? "PREGLED PRODAJE"
ELSE
    ?? "IZLAZ IZ PRODAVNICE - PARAGON BLOK"
ENDIF

B_OFF

P_COND

?

?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)

select PARTN
HSEEK cIdPartner

if cIdVd == "41"
        ?  "KUPAC:", cIdPartner, "-", PADR( naz, 20 ), SPACE(5), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP
    elseif cidvd=="43"
        ?  "DOBAVLJAC KOMIS.ROBE:",cIdPartner,"-", PADR( naz, 20 )
endif

select KONTO
HSEEK cIdKonto
?  "Prodavnicki konto razduzuje:",cIdKonto,"-", PADR( naz, 60 )
return nil
