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


#include "kadev.ch"



// otvaranje tabela modula "KADEV"
function kadev_o_tables()

O_KADEV_0
O_KADEV_1
O_KADEV_PROMJ
O_KDV_RJES
O_KDV_DEFRJES
O_KDV_RJ
O_KDV_RMJ
O_KDV_RJRMJ
O_KDV_MZ
O_KDV_K1
O_KDV_K2
O_KDV_ZANIM
O_KDV_RRASP
O_KDV_CIN
O_KDV_VES
O_KDV_NERDAN
O_KDV_NAC
O_KDV_OBRAZDEF
O_KDV_USLOVI
O_KDV_GLOBUSL

O_KBENEF
O_STRSPR

return



function kadev_set_relations()

select kdv_rmj
set order to tag "ID"
select kadev_0
set relation to idrmj into kdv_rmj

select kdv_rj
set order to tag "ID"
select kadev_0
set relation to idrj into kdv_rj additive

select kdv_rjrmj
set order to tag "ID"
select kadev_0
set relation to idrj+idrmj into kdv_rjrmj additive

select strspr
set order to tag "ID"
select kadev_0
set relation to idstrspr into strspr additive

select kdv_mz
set order to tag "ID"
select kadev_0
set relation to idmzst into kdv_mz additive

select kdv_k1
set order to tag "ID"
select kadev_0
set relation to idk1 into kdv_k1 additive

select kdv_k2
set order to tag "ID"
select kadev_0
set relation to idk2 into kdv_k2 additive

select kdv_zanim
set order to tag "ID"
select kadev_0
set relation to idzanim into kdv_zanim additive

select kdv_nac
set order to tag "ID"
select kadev_0
set relation to idnac into kdv_nac additive

select kdv_rrasp
set order to tag "ID"
select kadev_0
set relation to idrrasp into kdv_rrasp additive

select kdv_cin
set order to tag "ID"
select kadev_0
set relation to idcin into kdv_cin additive

select kdv_ves
set order to tag "ID"
select kadev_0
set relation to idves into kdv_ves additive

select kdv_rjrmj
set order to tag "ID"
select kadev_0
set relation to idrj+idrmj into kdv_rjrmj additive

return




function MUPPER(cInput)
 IF gKodnaS=="7"
   cInput:=STRTRAN(cInput,"{","[")
   cInput:=STRTRAN(cInput,"|","\")
   cInput:=STRTRAN(cInput,"~","^")
   cInput:=STRTRAN(cInput,"}","]")
   cInput:=STRTRAN(cInput,"`","@")
 ELSE  // "8"
   cInput:=STRTRAN(cInput,"�","�")
   cInput:=STRTRAN(cInput,"�","�")
   cInput:=STRTRAN(cInput,"�","�")
   cInput:=STRTRAN(cInput,"�","�")
   cInput:=STRTRAN(cInput,"�","�")
 ENDIF
return UPPER(cInput)


function MLOWER(cInput)
 IF gKodnaS=="7"
   cInput:=STRTRAN(cInput,"[","{")
   cInput:=STRTRAN(cInput,"\","|")
   cInput:=STRTRAN(cInput,"^","~")
   cInput:=STRTRAN(cInput,"]","}")
   cInput:=STRTRAN(cInput,"@","`")
 ELSE  // "8"
   cInput:=STRTRAN(cInput,"�","�")
   cInput:=STRTRAN(cInput,"�","�")
   cInput:=STRTRAN(cInput,"�","�")
   cInput:=STRTRAN(cInput,"�","�")
   cInput:=STRTRAN(cInput,"�","�")
 ENDIF
return LOWER(cInput)


FUNCTION BtoE(cInput)
 IF gKodnaS=="7"
   cInput:=STRTRAN(cInput,"[","S"+CHR(255))
   cInput:=STRTRAN(cInput,"\","D"+CHR(255))
   cInput:=STRTRAN(cInput,"^","C"+CHR(254))
   cInput:=STRTRAN(cInput,"]","C"+CHR(255))
   cInput:=STRTRAN(cInput,"@@","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"{","s"+CHR(255))
   cInput:=STRTRAN(cInput,"|","d"+CHR(255))
   cInput:=STRTRAN(cInput,"~","c"+CHR(254))
   cInput:=STRTRAN(cInput,"}","c"+CHR(255))
   cInput:=STRTRAN(cInput,"`","z"+CHR(255))
 ELSE  // "8"
   cInput:=STRTRAN(cInput,"�","S"+CHR(255))
   cInput:=STRTRAN(cInput,"�","D"+CHR(255))
   cInput:=STRTRAN(cInput,"�","C"+CHR(254))
   cInput:=STRTRAN(cInput,"�","C"+CHR(255))
   cInput:=STRTRAN(cInput,"�","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"�","s"+CHR(255))
   cInput:=STRTRAN(cInput,"�","d"+CHR(255))
   cInput:=STRTRAN(cInput,"�","c"+CHR(254))
   cInput:=STRTRAN(cInput,"�","c"+CHR(255))
   cInput:=STRTRAN(cInput,"�","z"+CHR(255))
 ENDIF
RETURN PADR(cInput,100)


function MsgPPromj()
 Box(,22,34)
  @ m_x+ 1,m_y+2 SAY "Vazeca polja su:                "
  @ m_x+ 2,m_y+2 SAY "��������������������������������"
  @ m_x+ 3,m_y+2 SAY " DATUMOD- dat.pocetka promjene  "
  @ m_x+ 4,m_y+2 SAY " DATUMDO- dat.kraja promjene    "
  @ m_x+ 5,m_y+2 SAY "   NATR1- numer.karakteristika 1"
  @ m_x+ 6,m_y+2 SAY "   NATR2- numer.karakteristika 2"
  @ m_x+ 7,m_y+2 SAY "   NATR3- numer.karakteristika 3"
  @ m_x+ 8,m_y+2 SAY "   NATR4- numer.karakteristika 4"
  @ m_x+ 9,m_y+2 SAY "   NATR5- numer.karakteristika 5"
  @ m_x+10,m_y+2 SAY "   NATR6- numer.karakteristika 6"
  @ m_x+11,m_y+2 SAY "   NATR7- numer.karakteristika 7"
  @ m_x+12,m_y+2 SAY "   NATR8- numer.karakteristika 8"
  @ m_x+13,m_y+2 SAY "   NATR9- numer.karakteristika 9"
  @ m_x+14,m_y+2 SAY "   CATR1- karakteristika 1      "
  @ m_x+15,m_y+2 SAY "   CATR2- karakteristika 2      "
  @ m_x+16,m_y+2 SAY "     IDK- sifra karakteristike  "
  @ m_x+17,m_y+2 SAY "DOKUMENT- broj dokumenta        "
  @ m_x+18,m_y+2 SAY "    OPIS- opis nastanka promjene"
  @ m_x+19,m_y+2 SAY "NADLEZAN- nadlezno lice         "
  @ m_x+20,m_y+2 SAY "    IDRJ- sifra radne jedinice  "
  @ m_x+21,m_y+2 SAY "   IDRMJ- sifra radnog mjesta   "
  inkey(0)
 BoxC()
return .f.



function OSVAL(aIDDef,cIzraz)
 LOCAL i:=0, nArr:=SELECT()
 IF cIzraz==NIL
   cIzraz77:=".t."
 ELSE
   cIzraz77:=cIzraz
 ENDIF
 SELECT KDV_DEFRJES
  FOR i:=1 TO LEN(aIDDef)
    cIDDef:="ID"+aIDDef[i]
    SEEK KDV_RJES->id+aIDDef[i]
    IF FOUND()      
        cDRIzraz:=ALLTRIM(izraz)
        &cIdDef:=&cDRIzraz
    ENDIF
  NEXT
  RefreshGets()
 SELECT(nArr)
RETURN &cIzraz77


function GS()
 LOCAL aRstE,aRstB,aRStU
  aRstE:=GMJD(KADEV_0->RadStE)
  aRstB:=GMJD(KADEV_0->RadStB)
  aRStU:=ADDGMJD(aRStE,aRStB)
RETURN aRStU[1]


function DC(xVr,aRadi)
 LOCAL i:=0, xVrati:=0
 
  FOR i:=1 TO LEN(aRadi)
    IF xVr>=aRadi[i,1] .and. xVr<aRadi[i,2]
      xVrati:=aRadi[i,3]
      EXIT
    ENDIF
  NEXT
RETURN xVrati



function GenNerDan()

aDani:={0,0,0,0,0,0,0}
//      N P U S C P S
//      1 2 3 4 5 6 7
cGodina:="2000"
cSubote   := "1"   
// 1-samo prva radna
cNedjelje := "0"   
// 0-sve neradne

IF !VarEdit({ {"Za godinu"                                                ,"cGodina"   ,""                ,"9999" ,""},;
               {"SUBOTE   (0-sve neradne/1-prva u mjes.radna/9-sve radne)" ,"cSubote"   ,"cSubote$'019'"   ,"9"    ,""},;
               {"NEDJELJE (0-sve neradne/1-prva u mjes.radna/9-sve radne)" ,"cNedjelje" ,"cNedjelje$'019'" ,"9"    ,""} },;
               7,1,20,78,"USLOV ZA NERADNE SUBOTE I NEDJELJE","B1")
   return
ENDIF

dLastD:=CTOD("01.01."+cGodina)
dDatum:=CTOD("01.01."+cGodina)

DO WHILE YEAR(dDatum)==VAL(cGodina)
   IF MONTH(dDatum)<>MONTH(dLastD); aDani:={0,0,0,0,0,0,0}; ENDIF
   IF DOW(dDatum)==1        // nedjelja
     IF cNedjelje=="0" .or. cNedjelje=="1".and.aDani[1] > 0
       APPEND BLANK
       _rec := dbf_get_rec()
       _rec["id"]    := cGodina
       _rec["naz"]   := "NEDJELJA"
       _rec["datum"] := dDatum
       update_rec_server_and_dbf( "kadev_nerdan", _rec, 1, "FULL" )
     ENDIF
   ELSEIF DOW(dDatum)==7    // subota
     IF cSubote=="0" .or. cSubote=="1".and.aDani[7] > 0
       APPEND BLANK
       _rec := dbf_get_rec()
       _rec["id"]    := cGodina
       _rec["naz"]   := "NERADNA SUBOTA"
       _rec["datum"] := dDatum
       update_rec_server_and_dbf( "kadev_nerdan", _rec, 1, "FULL" )
     ENDIF
   ENDIF
   ++aDani[DOW(dDatum)]
   dLastD:=dDatum
   dDatum:=dDatum+1
ENDDO

return


function ZadDanGO(dPDanGO,nDanaGO)
  LOCAL nArr:=SELECT(), nSubota:=0
  IF EMPTY(dPDanGO).or.nDanaGO==0; RETURN (CTOD("")); ENDIF
  SELECT (F_KDV_NERDAN); IF !USED(); O_KDV_NERDAN; ENDIF
  SET ORDER TO TAG "DAT"
  DO WHILE nDanaGO>0
    IF DOW(dPDanGO)==7; ++nSubota; ENDIF
    SEEK dPDanGO
    IF !FOUND()  // zna�i radni je dan
      --nDanaGO      // smanjujemo preostali broj dana GO
    ENDIF
    IF nDanaGO>0; ++dPDanGO; ENDIF
  ENDDO
  SELECT (nArr)
RETURN (dPDanGO)


function DatVrGO(dZDanGO)
  LOCAL nArr:=SELECT()
  IF EMPTY(dZDanGO); RETURN (CTOD("")); ENDIF
  SELECT (F_KDV_NERDAN); IF !USED(); O_KDV_NERDAN; ENDIF
  SET ORDER TO TAG "DAT"
  DO WHILE .t.
    ++dZDanGO
    SEEK dZDanGO
    IF !FOUND()      // zna�i radni je dan
      EXIT
    ENDIF
  ENDDO
  SELECT (nArr)
RETURN (dZDanGO)


function ImaRDana(dOd,dDo)
 LOCAL nDana:=0, i:=0, nSubota:=0
 LOCAL nArr:=SELECT()
 SELECT (F_KDV_NERDAN); IF !USED(); O_KDV_NERDAN; ENDIF
 SET ORDER TO TAG "DAT"
 FOR i:=0 TO IF(dDo-dOd==0,0,dDo-dOd)
   IF DOW(dOd+i)==7; ++nSubota; ENDIF
   SEEK dOd+i
   IF !FOUND(); ++nDana; ENDIF
 NEXT
 SELECT (nArr)
RETURN nDana




function IzborFajla(cPutanja,cAtrib)
 PRIVATE opc:={},Izb:=1,h:={}
 opc:=ListaFajlova(cPutanja,cAtrib)
 AEVAL(opc,{|x| AADD(h,IscitajZF(SUBSTR(x,4)))})
 IF LEN(opc)<1
   MsgBeep("'"+cPutanja+"': ne postoji nijedan trazeni fajl!##Obratite se servisu bring.out-a")
   Izb:=0    // <- ovo mo�da i ne treba
   RETURN ""
 ENDIF
 Izb:=meni_0("",opc,Izb,.t.,"1-1")
 IF Izb>0; meni_0("",opc,0,.f.); ENDIF
return IF( Izb==0 , "" , SUBSTR(opc[izb],4) )



function ListaFajlova(cPutanja,cAtrib)
 LOCAL aNiz:=DIRECTORY(cPutanja,cAtrib)
 LOCAL i:=0,aVrati:={}
 ASORT(aNiz,,,{|x,y| x[1]<y[1]})
 AEVAL(aNiz,{|x| ++i, AADD(aVrati,IF(i<10,STR(i,1),CHR(55+i))+". "+x[1])} )
return aVrati


function IscitajZF(cFajl)
 LOCAL nP1:=0,nP2:=0,nH:=0,cVrati:=""
 nH:=FOPEN(cFajl,2)
 FSEEK(nH,0); cVrati:=FREADSTR(nH,80)
 nP1:=AT('"',cVrati); nP2:=RAT('"',cVrati)
 FCLOSE(nH)
return IF( nP1<nP2, SUBSTR(cVrati,nP1+1,nP2-nP1-1), "")



