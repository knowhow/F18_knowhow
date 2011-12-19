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


#include "mat.ch"


static PicDEM := "99999999.99"
static PicBHD := "9999999999.99"
static PicKol := "9999999.99"


function mat_sint_specifikacija()

O_ROBA
O_SIFV
O_SIFK
O_MAT_SUBAN
O_PARTN

cIdFirma:=gFirma
qqKonto:=qqRoba:=SPACE(60)
dDATOD=dDatDO:=CTOD("")
//cDN:="D"
cFmt:="2"
Box("Spe2",7,65,.f.)

cFmt:="2"
if cFmt=="2"
 cFmt:="1"
 @ m_x+2,m_y+2 SAY "Iznos u "+ValPomocna()+"/"+ValDomaca()+"(1/2) ?" GET cFmt VALID cFmt $ "12"
 read
 if cFmt=="1"; cFmt:="2"; else; cFmt:="3"; endif
endif
if gNW$"DR"
  @ m_x+4,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
else
  @ m_x+4,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif
@ m_x+5,m_y+2 SAY KonSeks("Konta  ")+" : " GET qqKonto  PICTURE "@S50"
@ m_x+6,m_y+2 SAY "Artikli : " GET qqRoba   PICTURE "@S50"
@ m_x+7,m_y+2 SAY "Datum dokumenta - od:"    GET dDatOd
@ m_x+7,col()+1 SAY "do:"    GET dDatDo valid dDatDo>=dDatOd

do while .t.
READ; ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"IdKonto","C")
  aUsl2:=Parsiraj(qqRoba,"IdRoba","C")
  if aUsl1<>NIL .and. aUsl2<>NIL; exit; endif
enddo

BoxC(); ESC_RETURN 0

cIdFirma:=left(cIdFirma,2)

SELECT mat_suban   
// ("SUBANi1","IdFirma+IdRoba+dtos(DatDok)","SUBAN")
set order to tag "1"

if !empty(dDatOd) .or. !empty(dDatDo)
 set filter to cIdFirma==IdFirma .and. Tacno(aUsl1) .and. Tacno(aUsl2) ;
               .and. dDatOd<=DatDok .and. dDatDo>=DatDok
else
  set filter to cIdFirma==IdFirma .and. Tacno(aUsl1) .and. Tacno(aUsl2)
endif

go top
EOF CRET

if cFmt=="1" // A3
 m:="---- ---------- ---------------------------------------- --- ---------- ---------- ---------- ---------- ---------- ---------- ----------- ----------- ----------- ------------ ------------ ------------"
elseif cFmt=="2"
 m:="---- ---------- ---------------------------------------- --- ---------- ---------- ---------- ----------- ----------- -----------"
else
 m:="---- ---------- ---------------------------------------- --- ---------- ---------- ---------- ------------ ------------ ------------"
endif

START PRINT CRET


nCDI:=0

IF prow()==0
   P_COND
   @prow(),0 SAY "MAT.P: SPECIFIKACIJA ROBE (U "
   if cFmt=="1"
    ?? ValPomocna()+"/"+ValDomaca()+") "
   elseif cFmt=="2"
    ?? ValPomocna()+") "
   else
    ?? ValDomaca()+") "
   endif
   if !empty(dDatOd) .or. !empty(dDatDo)
     ?? "ZA PERIOD OD",dDatOd,"-",dDatDo
   endif
   ?? "      NA DAN:"
   @ prow(),pcol()+1 SAY DATE()
   @ prow()+1,0 SAY "FIRMA:"
   @ prow(),pcol()+1 SAY cIdFirma
   SELECT PARTN; HSEEK cIdFirma
   @ prow(),pcol()+1 SAY naz; @ prow(),pcol()+1 SAY naz2
   ? "Kriterij za "+KonSeks("konta")+":", trim(qqkonto)
   select mat_suban
   ?  m
   if cFmt=="2"
    ? "*R. *  SIFRA   *       N A Z I V                        *J. *       K O L I C I N A          *     V R I J E D N O S T          *"
    ? "*Br.*                                                       -------------------------------- ------------------------------------"
    ? "*   *          *                                        *MJ.*   ULAZ   *  IZLAZ   *  STANJE  *  DUGUJE   * POTRAZUJE *  SALDO   *"
   elseif cFmt=="3"
    ? "*R. *  SIFRA   *       N A Z I V                        *J. *       K O L I C I N A          *        V R I J E D N O S T          *"
    ? "*Br.*                                                       -------------------------------- ---------------------------------------"
    ? "*   *          *                                        *MJ.*   ULAZ   *  IZLAZ   *  STANJE  *  DUGUJE    *  POTRAZUJE *  SALDO    *"
   endif
    ?  m
ENDIF
B:=0
nUkDugI:=nUkPotI:=0
nUkDugI2:=nUkPotI2:=0

do while  !eof()

       IF prow()>63; FF; ENDIF

      SELECT mat_suban
      cIdRoba:=IdRoba
      nDugI:=nPotI:=nUlazK:=nIzlazK:=0
      nDugI2:=nPotI2:=nUlazK2:=nIzlazK2:=0
      DO WHILE !eof() .AND. cIdRoba=IdRoba
          IF U_I="1"
             nUlazK+=Kolicina
          ELSE
             nIzlazK+=Kolicina
          ENDIF
          IF D_P="1"
             nDugI+=Iznos
             nDugI2+=Iznos2
          ELSE
             nPotI+=Iznos
             nPotI2+=Iznos2
          ENDIF
       SKIP
      ENDDO // IdRoba

      SELECT ROBA
      HSEEK cIdRoba
      cRoba := PADR( field->naz, 40 )
      cJmj := field->jmj

      nSaldoK:=nUlazK-nIzlazK
      nSaldoI:=nDugI-nPotI
      nSaldoK2:=nUlazK2-nIzlazK2
      nSaldoI2:=nDugI2-nPotI2
      @ prow()+1,0 SAY ++B PICTURE '9999'
      @ prow(),pcol()+1 SAY cIdRoba
      @ prow(),pcol()+1 SAY cRoba
      @ prow(),pcol()+1 SAY cjmj
      if cFmt=="1"
        @ prow(),pcol()+1 SAY NC   picture "999999.999"
        @ prow(),pcol()+1 SAY VPC  picture "999999.999"
        @ prow(),pcol()+1 SAY MPC  picture "999999.999"
      endif
      @ prow(),pcol()+1 SAY nUlazK PICTURE picKol
      @ prow(),pcol()+1 SAY nIzlazK PICTURE picKol
      @ prow(),pcol()+1 SAY nSaldoK PICTURE picKol
      nCDI:=pcol()
     if cFmt $ "12"
      @ prow(),pcol()+1 SAY nDugI PICTURE PicDEM
      @ prow(),pcol()+1 SAY nPotI PICTURE PicDEM
      @ prow(),pcol()+1 SAY nSaldoI PICTURE PicDEM
     endif
     if cFmt $ "13"
      @ prow(),pcol()+1 SAY nDugI2 PICTURE PicBHD
      @ prow(),pcol()+1 SAY nPotI2 PICTURE PicBHD
      @ prow(),pcol()+1 SAY nSaldoI2 PICTURE PicBHD
     endif


      nUkDugI+=nDugI
      nUkPotI+=nPotI
      nUkDugI2+=nDugI2
      nUkPotI2+=nPotI2
      nDugI:=nPotI:=nUlazK:=nIzlazK:=0
      nDugI2:=nPotI2:=nUlazK2:=nIzlazK2:=0

      select mat_suban

enddo

?  m
?  "UKUPNO :"
@  prow(),nCDI SAY ""
if cFmt $ "12"
 @ prow(),pcol()+1 SAY nUkDugI PICTURE PicDEM
 @ prow(),pcol()+1 SAY nUkPotI PICTURE PicDEM
 @ prow(),pcol()+1 SAY nUkDugI-nUkPotI PICTURE PicDEM
endif
if cFmt $ "13"
 @ prow(),pcol()+1 SAY nUkDugI2          PICTURE PicBHD
 @ prow(),pcol()+1 SAY nUkPotI2          PICTURE PicBHD
 @ prow(),pcol()+1 SAY nUkDugI2-nUkPotI2 PICTURE PicBHD
endif
? m

FF

END PRINT
close all

return





