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


#include "kalk.ch"


function GenMag()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc,"1. pocetno stanje SQL                                            ")
AADD( _opcexe, {|| kalk_mag_pocetno_stanje() })
AADD( _opc,"1. pocetno stanje - LEGACY")
AADD( _opcexe, {|| PocStMag()})
AADD( _opc,"2. inventure")
AADD( _opcexe, {|| MnuMInv()})
AADD( _opc,"3. nivelacija po zadatom %")
AADD( _opcexe, {|| MNivPoProc()})
AADD( _opc,"4. preknjizenje tarifa")
AADD( _opcexe, {|| GetPreknM() })
AADD( _opc,"5. pocetno stanje na osnovu preknjizenja tarifa")
AADD( _opcexe, {|| GetPstPreknj()})

f18_menu( "mmg", .f., _izbor, _opc, _opcexe )

return



// menij sa inventurama
function MnuMInv()
private Opc:={}
private opcexe:={}

AADD(Opc,"1. dokument inventure                       ")
AADD(opcexe, {|| IM()})
AADD(Opc,"2. inventura-razlika prema postojecoj IM    ")
AADD(opcexe, {|| gen_im_razlika()})

private Izbor:=1
Menu_SC("mmi")

return
*}


/*! \fn Iz12u97()
 *  \brief Od 11 ili 12 napravi 96 ili 97
 */
 
function Iz12u97()
*{
  o_kalk_edit()

  cIdFirma    := gFirma
  cIdVdU      := "12"
  cIdVdI      := "97"
  cBrDokU     := SPACE(LEN(kalk_pripr->brdok))
  cBrDokI     := ""
  dDatDok     := CTOD("")

  cIdPartner  := SPACE(LEN(kalk_pripr->idpartner))
  dDatFaktP   := CTOD("")

  cPoMetodiNC := "N"
  cKontoSklad := "13103  "

  Box(,9,75)
    @ m_x+0, m_y+5 SAY "FORMIRANJE DOKUMENTA 96/97 NA OSNOVU DOKUMENTA 11/12"
    @ m_x+2, m_y+2 SAY "Dokument: "+cIdFirma+"-"
    @ row(), col() GET cIdVdU VALID cIdVdU $ "11#12"
    @ row(), col() SAY "-" GET cBrDokU VALID postoji_kalk_dok(cIdFirma+cIdVdU+cBrDokU)
    @ m_x+4, m_y+2 SAY "Dokument koji se formira (96/97)" GET cIdVdI VALID cIdVdI $ "96#97"
    @ m_x+5, m_y+2 SAY "Datum dokumenta koji se formira" GET dDatDok VALID !EMPTY(dDatDok)
    @ m_x+7, m_y+2 SAY "Prenijeti na konto (prazno-ne prenositi)" GET cKontoSklad
    READ; ESC_BCR
  BoxC()

  // utvrdimo broj nove kalkulacije
  SELECT KALK_DOKS; SEEK cIdFirma+cIdVdI+CHR(255); SKIP -1
  IF cIdFirma+cIdVdI == IDFIRMA+IDVD
     cBrDokI := brdok
  ELSE
     cBrDokI := space(8)
  ENDIF
  cBrDokI := UBrojDok(val(left(cBrDokI,5))+1,5,right(cBrDokI,3))

  // pocnimo sa generacijom dokumenta
  SELECT KALK
  SEEK cIdFirma+cIdVDU+cBrDokU
  DO WHILE !EOF() .and. cIdFirma+cIdVDU+cBrDokU == IDFIRMA+IDVD+BRDOK
    SELECT kalk_pripr; APPEND BLANK; Scatter()
      _idfirma   := cIdFirma
      _idkonto2  := KALK->idkonto2
      _idkonto   := cKontoSklad
      _idvd      := cIdVDI
      _brdok     := cBrDokI
      _datdok    := dDatDok
      _brfaktp   := KALK->(idkonto+brfaktp)
      _datfaktp  := dDatDok
      _idpartner := cIdPartner

      _fcj       := KALK->nc
      _fcj2      := KALK->nc
      _tprevoz   := "A"
      _tmarza2   := "A"
      _mkonto    := _idkonto2
      _mu_i      := "5"
      _error     := "0"
      _kolicina  := KALK->kolicina*IF(cIdVdU=="12",1,-1)
      _rbr       := KALK->rbr
      _idtarifa  := KALK->idtarifa
      _idroba    := KALK->idroba

      _nc        := KALK->nc
      _vpc       := KALK->vpc

    Gather()
    SELECT KALK
    SKIP 1
  ENDDO

CLOSERET
return
*}




/*! \fn InvManj()
 *  \brief Generise dok.95 za manjak i visak ili 95 za manjak, a 16 u smecu za visak
 */
 
function InvManj()
*{
local nFaktVPC:=0, lOdvojiVisak:=.f., nBrSl:=0

O_KONCIJ
O_KALK_PRIPR
O_KALK_PRIPR2
O_KALK
O_SIFK;O_SIFV
O_ROBA

select kalk_pripr; go top
private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok

if !(cidvd $ "IM")
  closeret
endif
select koncij; seek trim(kalk_pripr->idkonto)

lOdvojiVisak := Pitanje(,"Napraviti poseban dokument za visak?","N")=="D"

private cBrOtp:=SljBroj(cidfirma,"95",8)
IF lOdvojiVisak
  O_KALK_PRIPR9
  private cBrDop:=SljBroj(cidfirma,"16",8)
  DO WHILE .t.
   select kalk_pripr9
   seek cidFirma+"16"+cBrDop
   IF FOUND()
     Beep(1)
     IF Pitanje(,"U smecu vec postoji "+cidfirma+"-16-"+cbrdop+", zelite li ga izbrisati?","D")=="D"
       DO WHILE !EOF() .and. idfirma+idvd+brdok==cIdFirma+"16"+cBrDop
         SKIP 1; nBrSl:=RECNO(); SKIP -1; DELETE; GO (nBrSl)
       ENDDO
       EXIT
     ELSE   // probaj sljedeci broj dokumenta
       cBrDop:=PADR(NovaSifra(TRIM(cBrDop)),8)
     ENDIF
   ELSE
     EXIT
   ENDIF
  ENDDO
ENDIF

select kalk_pripr
go top
private nRBr:=0, nRBr2:=0
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
  scatter()
  select roba; hseek _idroba

  if koncij->naz<>"N1"
   FaktVPC(@nFaktVPC,_idfirma+_idkonto+_idroba)
  endif
  select kalk; set order to tag "1"; select kalk_pripr

  if round(kolicina-gkolicina,3)<>0   // popisana-stvarna=(>0 visak,<0 manjak)
    IF lOdvojiVisak .and. round(kolicina-gkolicina,3) > 0  // visak odvojiti
      private nKolZn:=nKols:=nc1:=nc2:=0,dDatNab:=ctod("")

      SELECT kalk_pripr9
      APPEND BLANK

      _nc:=0; nc1:=0; nc2:=0
      KalkNab(_idfirma,_idroba,_idkonto,0,0,@nc1,@nc2,_datdok)
      if gMetodaNC $ "13"; _nc:=nc1; elseif gMetodaNC=="2"; _nc:=nc2; endif
      SELECT kalk_pripr9

      _idpartner:=""
      _rabat:=prevoz:=prevoz2:=_banktr:=_spedtr:=_zavtr:=_marza:=_marza2:=_mpc:=0
      _kolicina:=kalk_pripr->(kolicina-gkolicina)
      _gkolicina:=_gkolicin2:=_mpc:=0
      _idkonto:=_idkonto
      _Idkonto2:=""
      _VPC:=nFaktVPC
      _rbr:=RedniBroj(++nrbr2)

      _brdok:=cBrDop
      _MKonto:=_Idkonto;_MU_I:="1"     // ulaz
      _PKonto:="";      _PU_I:=""
      _idvd:="16"
      _ERROR:=""
      gather()
    ELSE
      private nKolZn:=nKols:=nc1:=nc2:=0,dDatNab:=ctod("")
      select kalk_pripr2
      append blank

      _idpartner:=""
      _rabat:=prevoz:=prevoz2:=_banktr:=_spedtr:=_zavtr:=_nc:=_marza:=_marza2:=_mpc:=0
      _kolicina:=kalk_pripr->(-kolicina+gkolicina)
      _gkolicina:=_gkolicin2:=_mpc:=0
      _idkonto2:=_idkonto
      _Idkonto:=""
      _VPC:=nFaktVPC
      _rbr:=RedniBroj(++nrbr)

      _brdok:=cBrOtp
      _MKonto:=_Idkonto;_MU_I:="5"     // izlaz
      _PKonto:="";      _PU_I:=""
      _idvd:="95"
      _ERROR:=""
      gather()
    ENDIF
  endif
  select kalk_pripr
  skip
enddo

IF nRBr2>0
  Msg("Visak koji se pojavio evidentiran je u smecu kao dokument#"+cIdFirma+"-16-"+cBrDop+"#Po zavrsetku obrade manjka, vratite ovaj dokument iz smeca i obradite ga!",60)
ENDIF

closeret
return
*}




/*! \fn MNivPoProc()
 *  \brief Nivelacija u magacinu po procentima
 */

function MNivPoProc()
*{
LOCAL nStopa:=0.0, nZaokr:=1

O_KONTO
O_TARIFA
O_SIFK
O_SIFV
O_ROBA
cVarijanta:="3"
Box(,7,60)
cIdFirma:=gFirma
cIdkonto:=padr("1310",7)
dDatDok:=date()
@ m_x+1,m_Y+2 SAY "Magacin    :" GET  cidkonto valid P_Konto(@cidkonto)
@ m_x+2,m_Y+2 SAY "Datum      :" GET  dDatDok
@ m_x+3,m_Y+2 SAY "Cijenu zaokruziti na (br.decimalnih mjesta) :" GET nZaokr PICT "9"
@ m_x+4,m_Y+2 SAY "(1) promjena prema stopama iz polja ROBA->N1"
@ m_x+5,m_Y+2 SAY "(2) promjena prema stopama iz polja ROBA->N2"
@ m_x+6,m_Y+2 SAY "(3) promjena prema jedinstvenoj stopi      ?"  GET cVarijanta valid cVarijanta$"123"
read; ESC_BCR

if cvarijanta=="3"
 @ m_x+7,m_Y+2 SAY "Stopa promjene cijena (- za smanjenje)      :" GET nStopa PICT "999.99%"
 read;ESC_BCR
endif

BoxC()

O_KONCIJ
O_KALK_PRIPR
O_KALK
private cBrDok:=SljBroj(cidfirma,"18",8)

nRbr:=0
set order to tag "3"  //"3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")

MsgO("Generacija dokumenta 18 - "+cbrdok)

select koncij; seek trim(cidkonto)
select kalk
hseek cidfirma+cidkonto
do while !eof() .and. cidfirma+cidkonto==idfirma+mkonto

cIdRoba:=Idroba
nUlaz:=nIzlaz:=0
nVPVU:=nVPVI:=nNVU:=nNVI:=0
nRabat:=0
select roba; hseek cidroba; select kalk
do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+mkonto+idroba

  if ddatdok<datdok  // preskoci
      skip; loop
  endif
  if roba->tip $ "UT"
      skip; loop
  endif

  if mu_i=="1"
    if !(idvd $ "12#22#94")
     nUlaz+=kolicina-gkolicina-gkolicin2
     if koncij->naz=="P2"
      nVPVU+=round(roba->plc*(kolicina-gkolicina-gkolicin2), gZaokr)
     else
      nVPVU+=round( vpc*(kolicina-gkolicina-gkolicin2) , gZaokr)
     endif
     nNVU+=round( nc*(kolicina-gkolicina-gkolicin2) , gZaokr)
   else
     nIzlaz-=kolicina
     if koncij->naz=="P2"
        nVPVI-=round( roba->plc*kolicina , gZaokr)
     else
        nVPVI-=round( vpc*kolicina , gZaokr)
     endif
     nNVI-=round( nc*kolicina , gZaokr)
    endif
  elseif mu_i=="5"
    nIzlaz+=kolicina
    if koncij->naz=="P2"
      nVPVI+=round( roba->plc*kolicina , gZaokr)
    else
      nVPVI+=round( vpc*kolicina , gZaokr)
    endif
    nNVI+=nc*kolicina
  elseif mu_i=="3"    // nivelacija
    nVPVU+=round( vpc*kolicina , gZaokr)
  endif

  skip
enddo

select roba; hseek cidroba; select kalk
if  (cVarijanta="1" .and. roba->n1=0)
     skip; loop
endif
if  (cVarijanta="2" .and. roba->n2=0)
     skip; loop
endif
if (round(nulaz-nizlaz,4)<>0) .or. (round(nvpvu-nvpvi,4)<>0)

 select kalk_pripr
 scatter()
 append ncnl
 _idfirma:=cidfirma; _idkonto:=cidkonto; _mkonto:=cidkonto; _pu_i:=_mu_i:=""
 _idroba:=cidroba; _idtarifa:=roba->idtarifa
 _idvd:="18"; _brdok:=cbrdok
 _rbr:=RedniBroj(++nrbr)
 _kolicina:=nUlaz-nIzlaz
 _datdok:=_DatFaktP:=ddatdok
 _ERROR:=""
 _MPCSAPP:=KoncijVPC()   // stara cijena

 if cVarijanta=="1"  // roba->n1
   _VPC := ROUND( -_mpcsapp*roba->N1/100 , nZaokr )
 elseif cVarijanta=="2"
   _VPC := ROUND( -_mpcsapp*roba->N2/100 , nZaokr )
 else
   _VPC := ROUND( _mpcsapp*nStopa/100 , nZaokr )
 endif
 Gather2()
 select kalk
endif

enddo
MsgC()
CLOSERET
return
*}




/*! \fn KorekPC()
 *  \brief Korekcija prodajne cijene - pravljenje nivelacije za magacin
 */
 
function KorekPC()
*{
 LOCAL dDok:=date(), nPom:=0, nRobaVPC:=0
 PRIVATE cMagac:=padr("1310   ",gDuzKonto)
 O_KONCIJ
 O_KONTO
 private cSravnitiD:="D"
 private cUvijekSif:="D"

 Box(,6,50)
   @ m_x+1,m_y+2 SAY "Magacinski konto" GEt cMagac pict "@!" valid P_konto(@cMagac)
   @ m_x+2,m_y+2 SAY "Sravniti do odredjenog datuma:" GET cSravnitiD valid cSravnitiD $ "DN" pict "@!"
   @ m_x+4,m_y+2 SAY "Uvijek nivelisati na VPC iz sifrarnika:" GET cUvijekSif valid cUvijekSif $ "DN" pict "@!"
   read;ESC_BCR
   @ m_x+6,m_y+2 SAY "Datum do kojeg se sravnjava" GET dDok
   read;ESC_BCR
 BoxC()
 O_ROBA
 O_KALK_PRIPR
 O_KALK

nTUlaz:=nTIzlaz:=0
nTVPVU:=nTVPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
private nRbr:=0

select kalk
cBrNiv:=kalk_sljedeci(gfirma,"18")
select kalk; set order to tag "3"
HSEEK gFirma+cMagac
do while !eof() .and. idfirma+mkonto=gFirma+cMagac

cIdRoba:=Idroba; nUlaz:=nIzlaz:=0; nVPVU:=nVPVI:=nNVU:=nNVI:=0; nRabat:=0
select roba; hseek cidroba; select kalk
if roba->tip $ "TU"; skip; loop; endif

cIdkonto  := mkonto
nUlazVPC  := UzmiVPCSif(cIdKonto,.t.)
nPosljVPC := nUlazVPC
nRobaVPC  := nUlazVPC
do while !eof() .and. gFirma+cidkonto+cidroba==idFirma+mkonto+idroba

  if roba->tip $ "TU"; skip; loop; endif
  if cSravnitiD=="D"
     if datdok>dDok
          skip; loop
     endif
  endif
  if mu_i=="1"
    if !(idvd $ "12#22#94")
     nUlaz+=kolicina-gkolicina-gkolicin2
     nVPVU+=vpc*(kolicina-gkolicina-gkolicin2)
     nNVU+=nc*(kolicina-gkolicina-gkolicin2)
     nUlazVPC:=vpc
     if vpc<>0
       nPosljVPC:=vpc
     endif
   else
     nIzlaz-=kolicina
     nVPVI-=vpc*kolicina
     nNVI-=nc*kolicina
     if vpc<>0; nPosljVPC:=vpc; endif
    endif
  elseif mu_i=="5"
    nIzlaz+=kolicina
    nVPVI+=vpc*kolicina
    nRabat+=vpc*rabatv/100*kolicina
    nNVI+=nc*kolicina
    if vpc<>0; nPosljVPC:=vpc; endif
  elseif mu_i=="3"    // nivelacija
    nVPVU+=vpc*kolicina
    if mpcsapp+vpc<>0; nPosljVPC:=mpcsapp+vpc; endif
  endif
  skip
enddo


  nRazlika:=0
  nStanje:=round(nUlaz-nIzlaz,4)
  nVPV:=round(nVPVU-nVPVI,4)
  select kalk_pripr

  if cUvijekSif=="D" .and. nUlazVPC<>nRobaVPC  ;
                     .and. nPosljVPC<>nRobaVPC
    MsgBeep("Artikal "+cIdRoba+" ima zadnji ulaz ="+str(nUlazVPC,10,3)+"##"+;
            "            Cijena u sifrarniku je ="+str(nRobaVPC,10,3) )
    if Pitanje(,"Nivelisati na stanje iz sifrarnika ?"," ")=="D"
       nUlazVPC := nRobaVPC
    elseif Pitanje(,"Ako to ne zelite, zelite li staviti u sifrarnik cijenu sa ulaza ?"," ")=="D"
       select roba
       ObSetVPC(nUlazVPC)
       select kalk_pripr
    endif
  endif

  if nStanje<>0 .or. nVPV<>0
    if nStanje<>0
       if cUvijekSif=="D" .and. round(nUlazVPC-nVPV/nStanje,4)<>0
          if round(nVPV/nStanje-nRobaVPC,4)<>0
            // knjizno stanje razlicito od cijene u sifrarniku
            nRazlika:=nUlazVPC-nVPV/nStanje
          else
            nRazlika:=0
          endif
       else  // samo ako kartica nije ok
        if round(nPosljVPC-nVPV/nStanje,4)=0  // kartica izgleda ok
          nRazlika:=0
        else
          nRazlika:=nUlazVPC - nVPV/nStanje
          // nova - stara cjena
        endif
       endif
    else
        nRazlika:= nVPV
    endif

    if round(nRazlika,4) <> 0
      ++nRbr
      append blank
      replace idfirma with gFirma, idroba with cIdRoba, idkonto with cIdKonto,;
              datdok with dDok,;
              idtarifa with roba->idtarifa,;
              datfaktp with dDok,;
              kolicina with nStanje,;
              idvd with "18", brdok with cBrNiv ,;
              rbr with STR(nRbr,3),;
              mkonto with cMagac,;
              mu_i with "3"
      if nStanje<>0
           replace   mpcsapp with nVPV/nStanje,;
                     vpc     with nRazlika
      else
           replace   kolicina with 1,;
                     mpcsapp with nRazlika+nUlazVPC,;
                     vpc     with -nRazlika,;
                     Tbanktr with "X"
      endif

    endif  // nRazlika<>0
  endif
  select kalk

enddo

nTArea := SELECT()

if Logirati(goModul:oDataBase:cName,"DOK","GENERACIJA")
    
    select kalk_pripr
    go top
    cOpis := kalk_pripr->idfirma + "-" + ;
        kalk_pripr->idvd + "-" + ;
        kalk_pripr->brdok

    EventLog(nUser,goModul:oDataBase:cName,"DOK","GENERACIJA",;
    nil,nil,nil,nil,;
    cOpis,"","",kalk_pripr->datdok,date(),;
    "","Opcija korekcije prodajnih cijena")
endif

select (nTArea)

close all
return





function Otprema()

O_KONCIJ
O_KALK_PRIPR2
O_KALK_PRIPR
O_KALK
O_SIFK
O_SIFV
O_ROBA

select kalk_pripr
go top

private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok

if !(cidvd $ "96#95")  .or. empty(idkonto)
    closeret
endif

private cBrUlaz:="0"
select kalk
seek cidfirma+"16"+CHR(254)   // doprema
skip -1
if idvd<>"16"
     cBrUlaz:=space(8)
else
     cBrUlaz:=brdok
endif

IF IzFMKIni("KALKSI","EvidentirajOtpis","N",KUMPATH)=="D"
  cBrUlaz:=STRTRAN(cBrUlaz,"-X","  ")
ENDIF
cBrUlaz:=UBrojDok(val(left(cBrUlaz,5))+1,5,right(cBrUlaz,3))

select kalk_pripr
go top
private nRBr:=0
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
  scatter()
  select roba
  hseek _idroba
  select kalk_pripr2
  append blank

  _idpartner:=""
  _rabat:=prevoz:=prevoz2:=_banktr:=_spedtr:=_zavtr:=_nc:=_marza:=_marza2:=_mpc:=0

   _TPrevoz:="%"
   _TCarDaz:="%"
   _TBankTr:="%"
   _TSpedtr:="%"
   _TZavTr:="%"
   _TMarza:="%"
   _TMarza:="A"
   _gkolicina:=_gkolicin2:=_mpc:=0
   select koncij
   seek trim(kalk_pripr->idkonto2)
   if koncij->naz=="N1"  // otprema je izvrsena iz magacina koji se vodi po nc
    select koncij
    seek trim(kalk_pripr->idkonto)
    if koncij->naz<>"N1"     // ulaz u magacin sa vpc
     _VPC:=KoncijVPC()
     _marza:=KoncijVPC() - kalk_pripr->nc
     _tmarza:="A"
    else
     _VPC:=kalk_pripr->vpc
    endif
   else
    _VPC:=kalk_pripr->vpc
   endif
   select kalk_pripr2
   _fcj:=_fcj2:=_nc:=kalk_pripr->nc
   _rbr:=str(++nRbr,3)
   _kolicina:=kalk_pripr->kolicina
   _BrFaktP:=trim(kalk_pripr->idkonto2)+"/"+kalk_pripr->brfaktp
   _idkonto:=kalk_pripr->idkonto
   _idkonto2:=""
   _brdok:=cBrUlaz
   _MKonto:=_Idkonto
   _MU_I:="1"     // ulaz
   _PKonto:=""
   _PU_I:=""
   _idvd:="16"

   _TBankTr:="X"    // izgenerisani dokument
   gather()

  select kalk_pripr
  skip

enddo

close all
return




/*! \fn Iz96u16()
 *  \brief
 */
 
function Iz96u16()

  o_kalk_edit()
  cIdFirma    := gFirma
  cIdVdU      := "96"
  cIdVdI      := "16"
  cBrDokU     := SPACE(LEN(kalk_pripr->brdok))
  cBrDokI     := ""
  dDatDok     := CTOD("")

  cIdPartner  := SPACE(LEN(kalk_pripr->idpartner))
  dDatFaktP   := CTOD("")

  cPoMetodiNC := "N"

  Box(,6,75)
    @ m_x+0, m_y+5 SAY "FORMIRANJE DOKUMENTA 16 NA OSNOVU DOKUMENTA 96"
    @ m_x+2, m_y+2 SAY "Dokument: "+cIdFirma+"-"+cIdVdU+"-"
    @ row(),col() GET cBrDokU VALID postoji_kalk_dok(cIdFirma+cIdVdU+cBrDokU)
    @ m_x+4, m_y+2 SAY "Datum dokumenta koji se formira" GET dDatDok VALID !EMPTY(dDatDok)
    READ; ESC_BCR
  BoxC()

  // utvrdimo broj nove kalkulacije
  SELECT KALK_DOKS; SEEK cIdFirma+cIdVdI+CHR(255); SKIP -1
  IF cIdFirma+cIdVdI == IDFIRMA+IDVD
     cBrDokI := brdok
  ELSE
     cBrDokI := space(8)
  ENDIF
  cBrDokI := UBrojDok(val(left(cBrDokI,5))+1,5,right(cBrDokI,3))

  // pocnimo sa generacijom dokumenta
  SELECT KALK
  SEEK cIdFirma+cIdVDU+cBrDokU
  DO WHILE !EOF() .and. cIdFirma+cIdVDU+cBrDokU == IDFIRMA+IDVD+BRDOK
    PushWA()
    Scatter()
    SELECT kalk_pripr; APPEND BLANK
      _idfirma   := cIdFirma
      _idkonto   := KALK->idkonto2
      _idvd      := cIdVDI
      _brdok     := cBrDokI
      _datdok    := dDatDok
      _brfaktp   := KALK->(idkonto+brfaktp)
      _datfaktp  := dDatDok
      _idpartner := cIdPartner
      _fcj       := KALK->nc
      _fcj2      := KALK->nc
      _tprevoz   := "A"
      _tmarza2   := "A"
      _mkonto    := KALK->idkonto2
      _mu_i      := "1"
      _error     := "0"
    SELECT kalk_pripr; Gather()
    SELECT KALK; PopWA()
    SKIP 1
  ENDDO

CLOSERET
return
*}



/*! \fn Iz16u14()
 *  \brief Od 16 napravi 14
 */
 
function Iz16u14()
*{
  o_kalk_edit()

  cIdFirma    := gFirma
  cIdVdU      := "16"
  cIdVdI      := "14"
  cBrDokU     := SPACE(LEN(kalk_pripr->brdok))
  cBrDokI     := ""
  dDatDok     := CTOD("")

  cIdPartner  := SPACE(LEN(kalk_pripr->idpartner))
  cBrFaktP    := SPACE(LEN(kalk_pripr->brfaktp))
  dDatFaktP   := CTOD("")

  cPoMetodiNC := "N"

  Box(,8,75)
    @ m_x+0, m_y+5 SAY "FORMIRANJE DOKUMENTA 14 NA OSNOVU DOKUMENTA 16"
    @ m_x+2, m_y+2 SAY "Dokument: "+cIdFirma+"-"
    @ row(), col() SAY cIdVdU
    @ row(), col() SAY "-" GET cBrDokU VALID postoji_kalk_dok(cIdFirma+cIdVdU+cBrDokU)
    @ m_x+3, m_y+2 SAY "Datum dokumenta koji se formira" GET dDatDok VALID !EMPTY(dDatDok)
    @ m_x+4, m_y+2 SAY "Broj fakture" GET cBrFaktP
    @ m_x+5, m_y+2 SAY "Datum fakture" GET dDatFaktP
    @ m_x+6, m_y+2 SAY "Kupac" GET cIdPartner VALID P_Firma(@cIdPartner)
    READ; ESC_BCR
  BoxC()

  // utvrdimo broj nove kalkulacije
  SELECT KALK_DOKS; SEEK cIdFirma+cIdVdI+CHR(255); SKIP -1
  IF cIdFirma+cIdVdI == IDFIRMA+IDVD
     cBrDokI := brdok
  ELSE
     cBrDokI := space(8)
  ENDIF
  cBrDokI := UBrojDok(val(left(cBrDokI,5))+1,5,right(cBrDokI,3))

  // pocnimo sa generacijom dokumenta
  SELECT KALK
  SEEK cIdFirma+cIdVDU+cBrDokU
  DO WHILE !EOF() .and. cIdFirma+cIdVDU+cBrDokU == IDFIRMA+IDVD+BRDOK
    SELECT kalk_pripr; APPEND BLANK; Scatter()
      _idfirma   := cIdFirma
      _idkonto2  := KALK->idkonto
      _idvd      := cIdVDI
      _brdok     := cBrDokI
      _datdok    := dDatDok

      _brfaktp   := cBrFaktP
      _datfaktp  := dDatFaktP
      _idpartner := cIdPartner

      _fcj       := KALK->nc
      _fcj2      := KALK->nc
      _tprevoz   := "A"
      _tmarza2   := "A"
      _mkonto    := _idkonto2
      _mu_i      := "5"
      _error     := "0"
      _kolicina  := KALK->kolicina
      _rbr       := KALK->rbr
      _idtarifa  := KALK->idtarifa
      _idroba    := KALK->idroba

      _nc        := KALK->nc
      _vpc       := KALK->vpc

    Gather()
    SELECT KALK
    SKIP 1
  ENDDO

close all
return



