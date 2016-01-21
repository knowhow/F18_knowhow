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


function StKalk81(fzatops)
local nCol1:=nCol2:=0,npom:=0
local _is_rok, _dok_hash

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,nPRUC,aPorezi

nMarza:=nMarza2:=nPRUC:=0
aPorezi:={}

// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP

cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

if fzaTops==NIL
 fzaTops:=.f.
endif

_is_rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"

P_COND2

?? "KALK: KALKULACIJA BR:", cIdFirma + "-" + cIdVD + "-" + cBrDok, SPACE(2), P_TipDok(cIdVD,-2), SPACE(2), "Datum:", DatDok

@ prow(),125 SAY "Str:" + STR( ++nStr, 3 )

select PARTN
HSEEK cIdPartner

? "DOBAVLJAC:", cIdPartner, "-", PADR(naz,20), SPACE(5), "DOKUMENT Broj:", ALLTRIM( cBrFaktP ), "Datum:", dDatFaktP

select KONTO
HSEEK cIdKonto

?  "KONTO zaduzuje :",cIdKonto,"-", ALLTRIM( naz )

if !fZaTops

 m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

if IsPDV()
 m+=" -----------"
endif

 IF lPrikPRUC
   m += " ----------"
   ? m
   ? "*R * ROBA     *  FCJ     * TRKALO   * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     * MARZA.   * POREZ NA *   MPC    * MPCSaPP *"
   ? "*BR* TARIFA   *  KOLICINA* OST.KALO * SKONTO   *          *          *          *          *          *          *          *   MARZU  *          *         *"
   ? "*  *          *          *          *          *          *          *          *          *          *          *          *          *          *         *"
 ELSE
   if !IsPDV()
     ? m
     ? "*R * ROBA     *  FCJ     * TRKALO   * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     * MARZA.   *   MPC    * MPCSaPP *"
     ? "*BR* TARIFA   *  KOLICINA* OST.KALO * SKONTO   *          *          *          *          *          *          *          *          *         *"
     ? "*  *          *          *          *          *          *          *          *          *          *          *          *          *         *"
   else
      ? m
     ? "*R * ROBA     *  FCJ     * TRKALO   * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     * MARZA.   *    PC    *   PDV(%) *   PC     *"
     ? "*BR* TARIFA   *  KOLICINA* OST.KALO * SKONTO   *          *          *          *          *          *          *          *  bez PDV *   PDV    *  sa PDV  *"
     ? "*  *          *          *          *          *          *          *          *          *          *          *          *           *         *          *"
   endif
 ENDIF
 ? m

else

 m:="--- ---------- ---------- ---------- ----------"

 ? m
if !IsPDV()
 ? "*R * ROBA     * Kolicina *   MPC    * MPCSaPP *"
else
 ? "*R * ROBA     * Kolicina *    PC    *PC sa PDV*"
endif
 ? "*BR* TARIFA   *          *          *         *"
 ? "*  *          *          *          *         *"
 ? m

endif

nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=nTotb:=nTotC:=0
nTot9a:=0
nUC:=0

select kalk_pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

/*
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    endif
*/

    KTroskovi()

    select ROBA
    HSEEK kalk_pripr->IdRoba
    select TARIFA
    HSEEK kalk_pripr->IdTarifa

    select kalk_pripr

    Tarifa(field->pkonto,field->idRoba,@aPorezi)
    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    nPor1:=aIPor[1]

    IF lPrikPRUC
      nPRUC:=aIPor[2]
      nMarza2:=nMarza2-nPRUC
    ENDIF

    if prow() > ( RPT_PAGE_LEN + gPStranica ) - 4
        FF
        @ prow(), 125 SAY "Str:"+str(++nStr,3)
    endif

    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nTot+=  (nU:=FCj*Kolicina)
    if gKalo=="1"
        nTot1+= (nU1:=FCj2*(GKolicina+GKolicin2))
    else
        nTot1+= (nU1:=NC*(GKolicina+GKolicin2))
    endif
    nTot2+= (nU2:=-Rabat/100*FCJ*Kolicina)
    nTot3+= (nU3:=nPrevoz*SKol)
    nTot4+= (nU4:=nBankTr*SKol)
    nTot5+= (nU5:=nSpedTr*SKol)
    nTot6+= (nU6:=nCarDaz*SKol)
    nTot7+= (nU7:=nZavTr* SKol)
    nTot8+= (nU8:=NC *    (Kolicina-Gkolicina-GKolicin2) )
    nTot9+= (nU9:=nMarza2* (Kolicina-Gkolicina-GKolicin2) )
    IF lPrikPRUC
      nTot9a+= (nU9a:=nPRUC* (Kolicina-Gkolicina-GKolicin2) )
    ENDIF
    nTotA+= (nUA:=MPC   * (Kolicina-Gkolicina-GKolicin2) )
    nTotB+= (nUB:=MPCSAPP* (Kolicina-Gkolicina-GKolicin2) )
    nTotC+= (nUC:=nPor1 * (Kolicina-Gkolicina-GKolicin2) )

    // prvi red
    @ prow()+1,0 SAY rbr PICT "999"
    @ prow(),4 SAY ""
	?? TRIM(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"

	if lKoristitiBK .and. !EMPTY( roba->barkod )
		?? ", BK: " + ROBA->barkod
	endif

    if _is_rok
        _dok_hash := hb_hash()
        _dok_hash["idfirma"] := field->idfirma
        _dok_hash["idtipdok"] := field->idvd
        _dok_hash["brdok"] := field->brdok
        _dok_hash["rbr"] := field->rbr
        _item_istek_roka := CTOD( get_kalk_atribut_rok( _dok_hash, .t. ) )
        if DTOC( _item_istek_roka ) <> DTOC( CTOD("") )
            ?? " datum isteka roka:", _item_istek_roka
        endif
    endif

	@ prow()+1,4 SAY IdRoba
    nCol1:=pcol()+1
    if !fZaTops
     @ prow(),pcol()+1 SAY FCJ                   PICTURE PicCDEM
     @ prow(),pcol()+1 SAY GKolicina             PICTURE PicKol
     @ prow(),pcol()+1 SAY -Rabat                PICTURE PicProc
     @ prow(),pcol()+1 SAY nPrevoz/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nBankTr/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nSpedTr/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nCarDaz/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nZavTr/FCJ2*100       PICTURE PicProc
     @ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nMarza2/NC*100        PICTURE PicProc
     IF lPrikPRUC
       @ prow(),pcol()+1 SAY aPorezi[POR_PRUCMP] PICTURE PicProc
     ENDIF
    else
     @ prow(),pcol()+1 SAY Kolicina             PICTURE PicCDEM
    endif
    @ prow(),pcol()+1 SAY MPC                   PICTURE PicCDEM
    if IsPDV()
       @ prow(),pcol()+1 SAY aPorezi[POR_PPP] PICTURE PicProc
    endif
    @ prow(),pcol()+1 SAY MPCSaPP               PICTURE PicCDEM

    // drugi red
    @ prow()+1,4 SAY IdTarifa
    if !fzatops
     @ prow(),nCol1    SAY Kolicina             PICTURE PicCDEM
     @ prow(),pcol()+1 SAY GKolicin2            PICTURE PicKol
     @ prow(),pcol()+1 SAY -Rabat/100*FCJ       PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nPrevoz              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nBankTr              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nSpedTr              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nCarDaz              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nZavTr               PICTURE PicCDEM
     @ prow(),pcol()+1 SAY space(len(picdem))
     @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
     IF lPrikPRUC
       @ prow(),pcol()+1 SAY nPRUC                PICTURE PicCDEM
     else
       @ prow(),pcol()+1 SAY SPACE(LEN(PicCDEM))
     ENDIF
     if IsPDV()
       @ prow(),pcol()+1 SAY nPor1 PICTURE PicCDEM
     endif
    endif

    // treci red
    if !fzatops
     @ prow()+1,nCol1   SAY nU          picture         PICDEM
     @ prow(),pcol()+1  SAY nU1         picture         PICDEM
     @ prow(),pcol()+1  SAY nU2         picture         PICDEM
     @ prow(),pcol()+1  SAY nU3         picture         PICDEM
     @ prow(),pcol()+1  SAY nU4         picture         PICDEM
     @ prow(),pcol()+1  SAY nU5         picture         PICDEM
     @ prow(),pcol()+1  SAY nU6         picture         PICDEM
     @ prow(),pcol()+1  SAY nU7         picture         PICDEM
     @ prow(),pcol()+1  SAY nU8         picture         PICDEM
     @ prow(),pcol()+1  SAY nU9         picture         PICDEM
     IF lPrikPRUC
       @ prow(),pcol()+1  SAY nU9a        picture         PICDEM
     ENDIF
    else
     @ prow()+1,nCol1-1   SAY space(len(picdem))
    endif
    @ prow(),pcol()+1  SAY nUA         picture         PICDEM
    if IsPDV()
    	@ prow(),pcol()+1  SAY nUC  picture PICDEM
    endif
    @ prow(),pcol()+1  SAY nUB         picture         PICDEM
  skip
enddo

if prow() > ( RPT_PAGE_LEN + gPStranica ) - 3
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

? m

@ prow() + 1, 0        SAY "Ukupno:"
*************************** magacin *****************************
if !fzatops
  @ prow(),nCol1     SAY nTot          picture         PICDEM
  @ prow(),pcol()+1  SAY nTot1         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot2         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot3         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot4         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot5         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot6         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot7         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot8         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot9         picture         PICDEM
  IF lPrikPRUC
    @ prow(),pcol()+1  SAY nTot9a        picture         PICDEM
  ENDIF
else
  @ prow()+1,nCol1-1   SAY space(len(picdem))
endif
  @ prow(),pcol()+1  SAY nTotA         picture         PICDEM
  if IsPDV()
  	@ prow(),pcol()+1 SAY nTotC picture PICDEM
  endif
  @ prow(),pcol()+1  SAY nTotB         picture         PICDEM

? m

nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0

RekTarife()

if !fZaTops
	? "RUC:";  @ prow(),pcol()+1 SAY nTot6 pict picdem
endif

? m

// potpis na dokumentu
dok_potpis( 90, "L", nil, nil )

return





/*! \fn StKalk81_2()
 *  \brief Stampa kalkulacije 81 - direktno zaduzenje prodavnice
 */

function StKalk81_2()
local _dok_hash, _is_rok
local nCol1:=nCol2:=0,npom:=0
private aPorezi

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,nPRUC
nMarza:=nMarza2:=nPRUC:=0
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

_is_rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"

P_10CPI
?? "ULAZ U PRODAVNICU DIREKTNO OD DOBAVLJACA"
P_COND
?
?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

?  "DOBAVLJAC:",cIdPartner,"-",PADR( naz, 20 ),SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO
HSEEK cIdKonto

?  "KONTO zaduzuje :", cIdKonto, "-", ALLTRIM( naz )

 m:="---- ---------- ---------- ---------- ---------- ---------- ---------- ----------"+;
    IF(lPrikPRUC," ----------","")+" ---------- -----------"

if IsPDV()
 m+= " ----------"
endif

 ? m

if !IsPDV()
 IF lPrikPRUC
   ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   * POREZ NA *   MPC    * MPCSaPP  *"
   ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *   MARZU  *          *          *"
   ? "*  *          *    �     *   �      *     �     *          *          *    �     *    �     *    �     *    �     *"
 ELSE
   ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   *   MPC    * MPCSaPP  *"
   ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *          *          *"
   ? "*  *          *    �     *   �      *     �     *          *          *    �     *    �     *    �     *"
 ENDIF
else
 IF lPrikPRUC
   ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   * POREZ NA *   MPC    * MPCSaPDV *"
   ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *   MARZU  *          *          *"
   ? "*  *          *    �     *   �      *     �     *          *          *    �     *    �     *    �     *    �     *"
 ELSE
   ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   *    PC    *  PDV(%)  *    PC    *"
   ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *  BEZ PDV *  PDV     *  SA PDV  *"
   ? "*  *          *    �     *   �      *     �     *          *          *    �     *    �     *    �     *          *"
 ENDIF

endif

 ? m
 nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=nTotb:=0
 nTot9a:=0
 nTotC:=nUC:=0
 nPor1:=0

select kalk_pripr

aPorezi:={}
private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

/*
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     	set device to screen
     	Beep(2)
     	Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
    	set device to printer
    endif
*/

    KTroskovi()
    Tarifa(field->pkonto, field->idRoba, @aPorezi)

    select ROBA
    HSEEK kalk_pripr->IdRoba
    select TARIFA
    HSEEK kalk_pripr->IdTarifa
    select kalk_pripr

    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    nPor1:=aIPor[1]

    IF lPrikPRUC
      	nPRUC:=aIPor[2]
      	nMarza2:=nMarza2-nPRUC
    ENDIF

    if prow() > ( RPT_PAGE_LEN + gPStranica )
    	FF
	    @ prow(),125 SAY "Str:"+str(++nStr,3)
    endif

    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nTot+=  (nU:=FCj*Kolicina)
    if gKalo=="1"
        nTot1+= (nU1:=FCj2*(GKolicina+GKolicin2))
    else
        nTot1+= (nU1:=NC*(GKolicina+GKolicin2))
    endif
    nTot2+= (nU2:=-Rabat/100*FCJ*Kolicina)
    nTot3+= (nU3:=nPrevoz*SKol)
    nTot4+= (nU4:=nBankTr*SKol)
    nTot5+= (nU5:=nSpedTr*SKol)
    nTot6+= (nU6:=nCarDaz*SKol)
    nTot7+= (nU7:=nZavTr* SKol)
    nTot8+= (nU8:=NC *    (Kolicina-Gkolicina-GKolicin2) )
    nTot9+= (nU9:=nMarza2* (Kolicina-Gkolicina-GKolicin2) )
    IF lPrikPRUC
      nTot9a+= (nU9a:=nPRUC* (Kolicina-Gkolicina-GKolicin2) )
    ENDIF
    nTotA+= (nUA:=MPC   * (Kolicina-Gkolicina-GKolicin2) )
    nTotB+= (nUB:=MPCSAPP* (Kolicina-Gkolicina-GKolicin2) )
    nTotC+= (nUC:=nPor1 * (Kolicina-Gkolicina-GKolicin2) )

    // prvi red
    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"

	if lKoristitiBK .and. !EMPTY( roba->barkod )
		?? ", BK: " + roba->barkod
	endif

    if _is_rok
        _dok_hash := hb_hash()
        _dok_hash["idfirma"] := field->idfirma
        _dok_hash["idtipdok"] := field->idvd
        _dok_hash["brdok"] := field->brdok
        _dok_hash["rbr"] := field->rbr
        _item_istek_roka := CTOD( get_kalk_atribut_rok( _dok_hash, .t. ) )
        if DTOC( _item_istek_roka ) <> DTOC( CTOD("") )
            ?? " datum isteka roka:", _item_istek_roka
        endif
    endif

    @ prow()+1,4 SAY IdRoba
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY FCJ                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY -Rabat                PICTURE PicProc
    @ prow(),pcol()+1 SAY fcj*(1-Rabat/100)     picture piccdem
    @ prow(),pcol()+1 SAY (nPrevoz+nBankTr+nSpedtr+nCarDaz+nZavTr)/FCJ2*100       PICTURE PicProc
    @ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nMarza2/NC*100        PICTURE PicProc
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY aPorezi[POR_PRUCMP] PICTURE PicProc
    ENDIF
    @ prow(),pcol()+1 SAY MPC                   PICTURE PicCDEM
    if IsPDV()
    	@ prow(),pcol()+1 SAY aPorezi[POR_PPP] PICTURE PicProc
    endif
    @ prow(),pcol()+1 SAY MPCSaPP               PICTURE PicCDEM

    // drugi red
    @ prow()+1,4 SAY IdTarifa
    @ prow(),nCol1    SAY Kolicina             PICTURE PicCDEM
    @ prow(),pcol()+1 SAY -Rabat/100*FCJ       PICTURE PicCDEM
    @ prow(),pcol()+1 SAY space(len(piccdem))
    @ prow(),pcol()+1 SAY (nPrevoz+nBankTr+nSpedtr+nCarDaz+nZavTr)   PICTURE Piccdem
    @ prow(),pcol()+1 SAY space(len(picdem))
    @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY nPRUC              PICTURE PicCDEM
    ENDIF
    if IsPDV()
      @ prow(),pcol()+1 SAY SPACE(LEN(picdem))
      @ prow(),pcol()+1 SAY nPor1  PICTURE PicCDEM
    endif
    // treci red
    @ prow()+1,nCol1   SAY nU          picture         PICDEM
    @ prow(),pcol()+1  SAY nU2         picture         PICDEM
    @ prow(),pcol()+1  SAY nu+nU2         picture         PICDEM
    @ prow(),pcol()+1  SAY nu3+nu4+nu5+nu6+nU7         picture  PICDEM
    @ prow(),pcol()+1  SAY nU8         picture         PICDEM
    @ prow(),pcol()+1  SAY nU9         picture         PICDEM
    IF lPrikPRUC
      	@ prow(),pcol()+1  SAY nU9a         picture         PICDEM
    ENDIF
    @ prow(),pcol()+1  SAY nUA         picture         PICDEM
    if IsPDV()
      	@ prow(),pcol()+1 SAY nUC  picture  PICDEM
    endif
    @ prow(),pcol()+1  SAY nUB         picture         PICDEM

  skip
enddo

if prow() > ( RPT_PAGE_LEN + gPStranica )
    FF
    @ prow(),125 SAY "Str:"+str(++nStr,3)
endif
? m
@ prow()+1,0        SAY "Ukupno:"
  @ prow(),nCol1     SAY nTot          picture         PICDEM
  @ prow(),pcol()+1  SAY nTot2         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot+nTot2         picture         PICDEM
  @ prow(),pcol()+1  SAY ntot3+ntot4+ntot5+ntot6+nTot7         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot8         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot9         picture         PICDEM
  IF lPrikPRUC
    @ prow(),pcol()+1  SAY nTot9a        picture         PICDEM
  ENDIF
  @ prow(),pcol()+1  SAY nTotA         picture         PICDEM

  if IsPDV()
    @ prow(),pcol()+1  SAY nTotC  picture         PICDEM
  endif

  @ prow(),pcol()+1  SAY nTotB         picture         PICDEM

? m

if prow() > ( RPT_PAGE_LEN + gPStranica )
    FF
    @ prow(),125 SAY "Str:"+str(++nStr,3)
endif
?
if  round(ntot3+ntot4+ntot5+ntot6+ntot7,2) <>0
?  m
?  "Troskovi (analiticki):"
?  c10T1,":"
@ prow(),30 SAY  ntot3 pict picdem
?  c10T2,":"
@ prow(),30 SAY  ntot4 pict picdem
?  c10T3,":"
@ prow(),30 SAY  ntot5 pict picdem
?  c10T4,":"
@ prow(),30 SAY  ntot6 pict picdem
?  c10T5,":"
@ prow(),30 SAY  ntot7 pict picdem
? m
? "Ukupno troskova:"
@ prow(),30 SAY  ntot3+ntot4+ntot5+ntot6+ntot7 pict picdem
? m
endif

nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
RekTarife()

? "RUC:";  @ prow(),pcol()+1 SAY nTot6 pict picdem
? m
return
