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

#include "fin.ch"


/*! \fn StSubNal(cInd,lAuto)
 *  \brief Stapmanje subanalitickog naloga
 *  \param cInd  - "1"-stampa pripreme, "2"-stampa azuriranog, "3"-stampa dnevnika
 *  \param lAuto
 */

function stampa_suban_dokument(cInd, lAuto)

local nArr:=SELECT()
local aRez:={}
local aOpis:={}
local _vrste_placanja, lJerry

IF lAuto = NIL
	lAuto := .f.
ENDIF

O_PARTN
__par_len := LEN(partn->id)
select (nArr)

lJerry := .f.

PicBHD := "@Z "+FormPicL(gPicBHD,15)
PicDEM := "@Z "+FormPicL(gPicDEM,10)

IF gNW=="N"
     M := IIF(cInd=="3","------ ---------- --- ","")+"---- ------- " + REPL("-", __par_len) + " ----------------------------" + IIF(gVar1=="1" .and. lJerry, "-- " + REPL("-",20),"")+" -- ------------- ----------- -------- -------- --------------- ---------------"+IF(gVar1=="1","-"," ---------- ----------")
ELSE
     M := IIF(cInd=="3","------ ---------- --- ","")+"---- ------- " + REPL("-", __par_len) + " ----------------------------"+IF(gVar1=="1".and.lJerry,"-- "+REPL("-",20),"")+" ----------- -------- -------- --------------- ---------------"+IF(gVar1=="1","-"," ---------- ----------")
ENDIF

IF cInd $ "1#2"
     nUkDugBHD:=nUkPotBHD:=nUkDugDEM:=nUkPotDEM:=0
     nStr:=0
ENDIF

b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
cIdFirma:=IdFirma
cIdVN:=IdVN
cBrNal:=BrNal

IF cInd $ "1#2" .and. !lAuto
     fin_zagl_11()
ENDIF

DO WHILE !eof() .and. eval(b2)
      if !lAuto
       if prow() > 61 + IIF(cInd=="3",-7,0) + gPStranica
         if cInd=="3"
           PrenosDNal()
         else
           FF
         endif
         fin_zagl_11()
       endif
       P_NRED

       IF cInd=="3"
         @ prow(),0 SAY STR(++nRBrDN,6)
         @ prow(),pcol()+1 SAY cIdFirma+"-"+cIdVN+"-"+cBrNal
         @ prow(),pcol()+1 SAY " "+LEFT(DTOC(dDatNal),2)
         @ prow(),pcol()+1 SAY RBr
       ELSE
         @ prow(),0 SAY RBr
       ENDIF

       @ prow(),pcol()+1 SAY IdKonto

       if !empty(IdPartner)
         if gVSubOp=="D"
           select KONTO; hseek (nArr)->idkonto
           select PARTN; hseek (nArr)->idpartner
           cStr:=TRIM(KONTO->naz)+" ("+TRIM(trim(naz)+" "+trim(naz2))+")"
         else
           select PARTN; hseek (nArr)->idpartner
           cStr:=trim(naz)+" "+trim(naz2)
         endif
       else
         select KONTO;  hseek (nArr)->idkonto
         cStr:=naz
       endif
       select (nArr)

       IF gVar1=="1" .and. lJerry
         aRez := {PADR(cStr,30)}
         cStr := opis
         aOpis := SjeciStr( cStr, 20 )
       ELSE
         aRez := SjeciStr( cStr, 28 )
         cStr := opis
         aOpis := SjeciStr( cStr, 20 )
       ENDIF

       @ prow(),pcol()+1 SAY Idpartner(idpartner)

       nColStr:=PCOL()+1

       @  prow(),pcol()+1 SAY padr(aRez[1],28+IF(gVar1=="1".and.lJerry,2,0))
       //-DifIdP(idpartner)) // dole cu nastaviti

       nColDok:=PCOL()+1

       IF gVar1=="1" .and. lJerry
         @ prow(),pcol()+1 SAY aOpis[1]
       ENDIF

       if gNW=="N"
         @ prow(),pcol()+1 SAY IdTipDok
         select TDOK;  hseek (nArr)->idtipdok
         @ prow(),pcol()+1 SAY naz
         select (nArr)
         @ prow(),pcol()+1 SAY padr(BrDok,11)
       else
         @ prow(),pcol()+1 SAY padr(BrDok,11)
       endif
       @ prow(),pcol()+1 SAY DatDok
       if cDatVal=="D"
         @ prow(),pcol()+1 SAY DatVal
       else
         @ prow(),pcol()+1 SAY space(8)
       endif
       nColIzn:=pcol()+1
      endif

      IF D_P=="1"
         if !lAuto
           @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
           @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
         endif
         nUkDugBHD+=IznosBHD
         IF cInd=="3"
           nTSDugBHD+=IznosBHD
         ENDIF
      ELSE
         if !lAuto
           @ prow(),pcol()+1 SAY 0 PICTURE PicBHD
           @ prow(),pcol()+1 SAY IznosBHD PICTURE PicBHD
         endif
         nUkPotBHD+=IznosBHD
         IF cInd=="3"
           nTSPotBHD+=IznosBHD
         ENDIF
      ENDIF

      IF gVar1!="1"
        if D_P=="1"
           if !lAuto
             @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
             @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
           endif
           nUkDugDEM+=IznosDEM
           IF cInd=="3"
             nTSDugDEM+=IznosDEM
           ENDIF
        else
           if !lAuto
             @ prow(),pcol()+1 SAY 0 PICTURE PicDEM
             @ prow(),pcol()+1 SAY IznosDEM PICTURE PicDEM
           endif
           nUkPotDEM+=IznosDEM
           IF cInd=="3"
             nTSPotDEM+=IznosDEM
           ENDIF
        endif
      ENDIF

      if !lAuto
        Pok:=0
        for i:=2 to max(len(aRez),len(aOpis)+IF(gVar1=="1".and.lJerry,0,1))
          if i<=len(aRez)
            @ prow()+1,nColStr say aRez[i]
          else
            pok:=1
          endif
          IF gVar1=="1" .and. lJerry
            @ prow()+pok,nColDok say IF( i<=len(aOpis) , aOpis[i] , SPACE(20) )
          ELSE
            @ prow()+pok,nColDok say IF( i-1<=len(aOpis) , aOpis[i-1] , SPACE(20) )
          ENDIF
          if i==2 .and. ( !Empty(k1+k2+k3+k4) .or. grj=="D" .or. gtroskovi=="D" )
            ?? " " + k1 + "-" + k2 + "-" + K3Iz256(k3) + "-" + k4
            if _vrste_placanja
              ?? "(" + Ocitaj(F_VRSTEP, k4, "naz" ) + ")"
            endif
            if gRj=="D"
	    	?? " RJ:",idrj
	    endif
            if gTroskovi=="D"
              ?? "    Funk:",Funk
              ?? "    Fond:",Fond
            endif
          endif
        next
      endif

      IF cInd=="1" .and. ASCAN(aNalozi,cIdFirma+cIdVN+cBrNal)==0  // samo ako se ne nalazi u psuban
        select PSUBAN
        Scatter()
        select (nArr)
        Scatter()
        SELECT PSUBAN
        APPEND BLANK
        Gather()  
      ENDIF
      select (nArr)
      SKIP 1
   ENDDO

   IF cInd $ "1#2" .and. !lAuto
     IF prow() > 58 + gPStranica
          FF
          fin_zagl_11()
     endif
     P_NRED
     ?? M
     P_NRED
     ?? "Z B I R   N A L O G A:"
     @ prow(),nColIzn  SAY nUkDugBHD PICTURE picBHD
     @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
     IF gVar1!="1"
       @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
       @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM
     ENDIF
     P_NRED
     ?? M
     nUkDugBHD:=nUKPotBHD:=nUkDugDEM:=nUKPotDEM:=0

     if gPotpis=="D"
       IF prow()>58+gPStranica; FF; fin_zagl_11();  endif
       P_NRED
       P_NRED
       F12CPI
       P_NRED
       @ prow(),55 SAY "Obrada AOP "; ?? replicate("_",20)
       P_NRED
       @ prow(),55 SAY "Kontirao   "; ?? replicate("_",20)
     endif
     FF

   ELSEIF cInd=="3"
      if prow()>54+gPStranica
        PrenosDNal()
      endif
   ENDIF


RETURN


/*! \fn PrenosDNal()
 *  \brief Ispis prenos na sljedecu stranicu
 */
 
function PrenosDNal()
? m
  ? PADR("UKUPNO NA STRANI "+ALLTRIM(STR(nStr)),30)+":"
   @ prow(),nColIzn  SAY nTSDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nTSPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nTSDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nTSPotDEM PICTURE picDEM
   ENDIF
  ? m
  ? PADR("DONOS SA PRETHODNE STRANE",30)+":"
   @ prow(),nColIzn  SAY nUkDugBHD-nTSDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nUkPotBHD-nTSPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nUkDugDEM-nTSDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nUkPotDEM-nTSPotDEM PICTURE picDEM
   ENDIF
  ? m
  ? PADR("PRENOS NA NAREDNU STRANU",30)+":"
   @ prow(),nColIzn  SAY nUkDugBHD PICTURE picBHD
   @ prow(),pcol()+1 SAY nUkPotBHD PICTURE picBHD
   IF gVar1!="1"
     @ prow(),pcol()+1 SAY nUkDugDEM PICTURE picDEM
     @ prow(),pcol()+1 SAY nUkPotDEM PICTURE picDEM
   ENDIF
  ? m
  FF
  nTSDugBHD:=nTSPotBHD:=nTSDugDEM:=nTSPotDEM:=0   // tekuca strana
RETURN


