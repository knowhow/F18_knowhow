#include "f18.ch"

/*! \fn SpecSubPro()
 *  \brief Specifikacija subanalitike po proizvoljnom sortiranju, verzija C52
 */

function SpecSubPro()
local _fin_params := fin_params()
local _fakt_params := fakt_params()

private fK1 := _fin_params["fin_k1"]
private fK2 := _fin_params["fin_k2"]
private fK3 := _fin_params["fin_k3"]
private fK4 := _fin_params["fin_k4"]

private cSk := "N"
private cSkVar := "N"

cIdFirma := gFirma
picBHD := FormPicL("9 "+gPicBHD,20)

O_KONTO
O_PARTN
__par_len := LEN(partn->id)

dDatOd := dDatDo := CTOD("")
qqkonto := space(7)
qqPartner := space(60)
qqTel := space(60)
cTip := "1"
qqBrDok := ""

Box( "", 20, 65 )

set cursor on

private cSort := "1"

cK1:=cK2:="9"
cK3:=cK4:="99"
cIdRj:="999999"
cFunk:="99999"
cFond:="9999"

private nC:=65

do while .t.
    @ m_x+1,m_y+6 SAY "SPECIFIKACIJA SUBANALITIKA - PROIZV.SORT."
    if gNW=="D"
        @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
    else
        @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
    endif
    @ m_x+4,m_y+2 SAY "Konto   " GET qqkonto  pict "@!" valid P_KontoFin(@qqkonto)
    @ m_x+5,m_y+2 SAY "Partner " GET qqPartner pict "@!S50"
    @ m_x+6,m_y+2 SAY "Datum dokumenta od" GET dDatOd
    @ m_x+6,col()+2 SAY "do" GET dDatDo
    IF gVar1=="0"
        @ m_x+7,m_y+2 SAY "Obracun za "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+"/"+ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())+" (1/2/3):" GET cTip valid ctip $ "123"
    ENDIF

    @ m_x+9,m_y+2 SAY "Kriterij za telefon" get qqTel pict "@!S30"
    @ m_x+11,m_y+2 SAY "Sortirati po: konto+telefon+partn (1)" get cSort valid csort $ "12"

    @ m_x+15,m_y+2 SAY ""

    if fk1
        @ m_x+15,m_y+2 SAY "K1 (9 svi) :" GET cK1
    endif
    if fk2
        @ m_x+15,col()+2 SAY "K2 (9 svi) :" GET cK2
    endif
    if fk3
        @ m_x+15,col()+2 SAY "K3 ("+cK3+" svi):" GET cK3
    endif
    if fk4
        @ m_x+15,col()+2 SAY "K4 (99 svi):" GET cK4
    endif

    READ
    ESC_BCR

    aUsl2 := Parsiraj( qqPartner, "IdPartner" )
    aUsl5 := Parsiraj( qqTel, "partn->telefon" )

    if aUsl5 <> NIL .and. aUsl2 <> NIL
        exit
    endif

enddo

BoxC()

cIdFirma := LEFT( cIdFirma, 2 )

nTmpArr := 0
nArr := 0
cImeTmp := ""

O_SUBAN
SET RELATION TO suban->idpartner INTO partn

if cK1 == "9"
    cK1 := ""
endif
if cK2 == "9"
    cK2 := ""
endif
if cK3 == REPL("9",LEN(cK3))
    cK3 := ""
else
    cK3 := k3u256(cK3)
endif
if cK4 == "99"
    cK4 := ""
endif

select SUBAN
set order to tag "1"

if cSort == "1"
    cSort1 := "idfirma + idkonto + partn->telefon + idpartner"
endif

private cFilt1 := "idfirma == " + _filter_quote( cIdFirma ) + " .and. idkonto == '" + qqkonto + "'"

if !(empty(dDatOd) .and. empty(dDatDo))
    cFilt1 += iif(empty(cFilt1),"",".and.")+ ;
            "dDatOd<=DatDok  .and. dDatDo>=DatDok"
endif

if ( fk1 .and. fk2 .and. fk3 .and. fk4 )
    cFilt1+= if( empty(cFilt1), "", ".and." ) + ;
           "(k1=ck1 .and. k2=ck2 .and. k3=ck3 .and. k4=ck4)"
endif

if aUsl2 <> ".t."
    cFilt1 += ".and.(" + aUsl2 +")"
endif
if aUsl5<>".t."
    cFilt1+= ".and.(" + aUsl5 +")"
endif

Box(,1,30)

INDEX ON &cSort1 to "TMPSP2" FOR &cFilt1

BoxC()

Pic:=PicBhd

START PRINT CRET

if cTip=="3"
   m:="------  " + REPLICATE("-", __par_len) + " ------------------------------------------------- --------------------- --------------------"
else
   m:="------  " + REPLICATE("-", __par_len) + " ------------------------------------------------- --------------------- -------------------- --------------------"
endif
nStr:=0

nud:=nup:=0      // DIN
nud2:=nup2:=0    // DEM

DO WHILE !eof()

 select suban
 nkd:=nkp:=0
 nkd2:=nkp2:=0
 cIdkonto:=idkonto
 if cSort=="1"
     cBrTel:=partn->telefon
     bUslov:={|| cbrtel==partn->telefon}
     cNaslov:=partn->telefon+"-"+partn->mjesto
 endif


 DO WHILE !eof() .and. idfirma==cidfirma .and. idkonto==cidkonto .and. eval(bUslov)
     nd:=np:=0;nd2:=np2:=0
     if prow()==0; fin_specif_zagl6(cSkVar); endif
     cIdPartner:=IdPartner
     cNazPartn:=PADR(partn->naz, 25)
     DO WHILE !eof() .and. idfirma==cidfirma .and. idkonto==cidkonto .and. eval(bUslov) .and. IdPartner==cIdPartner
         if d_P=="1"
           nd+=iznosbhd; nd2+=iznosdem
         else
           np+=iznosbhd; np2+=iznosdem
         endif
       select suban
       SKIP
     enddo

   if prow()>60+dodatni_redovi_po_stranici(); FF; fin_specif_zagl6(cSkVar); endif
   ? cidkonto,cIdPartner,""
   if !empty(cIdPartner)
     ?? padr(cNazPARTN,50-DifIdp(cIdPartner))
   else
     select KONTO; HSEEK cidkonto; select SUBAN
     ?? padr(KONTO->naz,50)
   endif

   nC:=pcol()+1
   if cTip=="1"
    @ prow(),pcol()+1 SAY nd pict pic
    @ prow(),pcol()+1 SAY np pict pic
    @ prow(),pcol()+1 SAY nd-np pict pic
   elseif cTip=="2"
    @ prow(),pcol()+1 SAY nd2 pict pic
    @ prow(),pcol()+1 SAY np2 pict pic
    @ prow(),pcol()+1 SAY nd2-np2 pict pic
   else
    @ prow(),pcol()+1 SAY nd-np pict pic
    @ prow(),pcol()+1 SAY nd2-np2 pict pic
   endif
   nkd+=nd; nkp+=np  // ukupno  za klasu
   nkd2+=nd2; nkp2+=np2  // ukupno  za klasu
 enddo  // csort

 if prow()>60+dodatni_redovi_po_stranici(); FF; fin_specif_zagl6(cSkVar); endif
  ? m
  if cSort=="1"
   ?  "Ukupno za:",cNaslov,":"
  endif
  if cTip=="1"
   @ prow(),nC       SAY nKd pict pic
   @ prow(),pcol()+1 SAY nKp pict pic
   @ prow(),pcol()+1 SAY nKd-nKp pict pic
  elseif cTip=="2"
   @ prow(),nC       SAY nKd2 pict pic
   @ prow(),pcol()+1 SAY nKp2 pict pic
   @ prow(),pcol()+1 SAY nKd2-nKp2 pict pic
  else
   @ prow(),nC       SAY nKd-nKP pict pic
   @ prow(),pcol()+1 SAY nKd2-nKP2 pict pic
  endif
  ? m
 nUd+=nKd; nUp+=nKp   // ukupno za sve
 nUd2+=nKd2; nUp2+=nKp2   // ukupno za sve
enddo
if prow()>60+dodatni_redovi_po_stranici(); FF; fin_specif_zagl6(cSkVar); endif
? m
? " UKUPNO:"
if cTip=="1"
  @ prow(),nC       SAY nUd pict pic
  @ prow(),pcol()+1 SAY nUp pict pic
  @ prow(),pcol()+1 SAY nUd-nUp pict pic
elseif cTip=="2"
  @ prow(),nC       SAY nUd2 pict pic
  @ prow(),pcol()+1 SAY nUp2 pict pic
  @ prow(),pcol()+1 SAY nUd2-nUp2 pict pic
else
  @ prow(),nC       SAY nUd-nUP pict pic
  @ prow(),pcol()+1 SAY nUd2-nUP2 pict pic
endif
? m
FF
ENDPRINT

closeret

return




