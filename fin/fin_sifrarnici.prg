/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fin.ch"

/*! \file fmk/fin/sif/1g/sif.prg
 *  \brief Sifrarnici
 */


/*! \fn fin_serv_functions()
 *  \brief Servisne funkcije
 */
 
function fin_serv_functions()

Box(,4,60)
  cOdg:="1"
  @ m_x+1,m_y+2 SAY "1. zamjeni u prometu sifru partnera:"
  @ m_x+2,m_y+2 SAY "2. zamjeni u prometu sifru konta   :"
  @ m_x+3,m_y+2 SAY "                                    " GET cOdg valid codg $ "12"
  read
BoxC()

if cOdg=="1"
  Box(,4,60)
    cStSif:=space(6)
    cNSif:=space(6)
    @ m_x+1,m_y+2 SAY "Stara sifra:"  get cStSif valid !empty(cStSif)
    @ m_x+2,m_y+2 SAY "Nova  sifra:"  get cNSif  valid !empty(cStSif)
    read; ESC_BCR
  BoxC()

  O_SUBAN
  select suban

  //CREATE_INDEX("SUBANi2","IdFirma+IdPartner+IdKonto","SUBAN")
  set order to tag "2"
  seek  gFirma+cNSif
  if !found() .or. Pitanje(,"Vec postoji u prometu sifra ?. Nastaviti ??","N")=="D"
    select suban ; set order to 0
    go top
    do while !eof()
       if idpartner==cStSif
          replace idpartner with cNSif
       endif
       skip
    enddo
  endif
endif
closeret
return


/*!
 * \ingroup ini
 * \var FmkIni_ExePath_FIN_PartnerNaziv2
 * \brief Prikaz polja Naz2 u PARTN tabeli 
 * \param D - prikaz polja Naz2 u tabeli partnera
 * \param N - ne prikaz, default vrijednost
 * \sa P_Firma
 */
*string FmkIni_ExePath_FIN_PartnerNaziv2;

/*!
 * \ingroup ini
 * \var FmkIni_ExePath_SifPartn_DZIROR
 * \brief Prikaz polja DZIROR - devizni ziro racun 
 * \param D - prikaz polja
 * \param N - ne prikaz, default vrijednost
 * \sa P_Firma
 */
*string FmkIni_ExePath_SifPartn_DZIROR;


/*!
 * \ingroup ini
 * \var FmkIni_ExePath_SifPartn_Fax
 * \brief Prikaz polja Fax
 * \param D - prikaz Ziro racun
 * \param N - ne prikaz, default vrijednost
 * \sa P_Firma
 */
*string FmkIni_ExePath_SifPartn_Fax;


/*! \fn P_Firma(cId,dx,dy)
 *  \brief Otvara sifrarnik partnera 
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_dummy(cId,dx,dy)
*{
local cN2Fin, i

PRIVATE ImeKol,Kol
ImeKol:={ { PADR("ID",6),   {|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    },;
          { PADR("Naziv",25),  {|| naz},     "naz"      };
        }

cN2Fin:=IzFMkIni('FIN','PartnerNaziv2','N')

if cN2Fin=="D"
 AADD(ImeKol, { PADR("Naziv2",25), {|| naz2},     "naz2"      } )
endif

AADD(ImeKol, { PADR("PTT",5),     {|| PTT},     "ptt"      } )
AADD(ImeKol, { PADR("Mjesto",16), {|| MJESTO},  "mjesto"   } )
AADD(ImeKol, { PADR("Adresa",24), {|| ADRESA},  "adresa"   } )

AADD(ImeKol, { PADR("Ziro R ",22),{|| ZIROR},   "ziror"  ,{|| .t.},{|| .t. }  } )

Kol:={}

if IzFMkIni('SifPartn','DZIROR','N')=="D"
 if partn->(fieldpos("DZIROR"))<>0
   AADD (ImeKol,{ padr("Dev ZR",22 ), {|| DZIROR}, "Dziror" })
 endif
endif

if IzFMKINI('SifPartn','Telefon','D')=="D"
 AADD(Imekol,{ PADR("Telefon",12),  {|| TELEFON}, "telefon"  } )
endif

if IzFMKINI('SifPartn','Fax','D')=="D"
if partn->(fieldpos("FAX"))<>0
  AADD (ImeKol,{ padr("Fax",12 ), {|| fax}, "fax" })
endif
endif

if IzFMKINI('SifPartn','MOBTEL','D')=="D"
if partn->(fieldpos("MOBTEL"))<>0
  AADD (ImeKol,{ padr("MobTel",20 ), {|| mobtel}, "mobtel" })
endif
endif

if partn->(fieldpos("ID2"))<>0
  AADD (ImeKol,{ padr("Id2",6 ), {|| id2}, "id2" })
endif
if partn->(fieldpos("IdOps"))<>0
  AADD (ImeKol,{ padr("Opstina",6 ), {|| idOps}, "idOps" })
endif

FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

PushWa()

select (F_SIFK)
if !used()
  O_SIFK; O_SIFV
endif

select sifk; set order to tag "ID"; seek "PARTN"
do while !eof() .and. ID="PARTN"

 AADD (ImeKol, {  IzSifKNaz("PARTN",SIFK->Oznaka) })
 AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('PARTN','" + sifk->oznaka + "')) }" ) )
 AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 if sifk->edkolona > 0
   for ii:=4 to 9
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
   AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
 else
   for ii:=4 to 10
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
 endif

 // postavi picture za brojeve
 if sifk->Tip="N"
   if f_decimal > 0
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina - sifk->f_decimal-1 )+"."+replicate("9",sifk->f_decimal)
   else
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina )
   endif
 endif

 AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )

 skip
enddo
PopWa()

return PostojiSifra(F_PARTN,1,10,60,"Lista Partnera",@cId,dx,dy,{|Ch| PartnBlok(Ch)},,,,,{"ID"})
*}



/*! \fn PartnBlok(Ch)
 *  \brief Obrada funkcija nad sifrarnikom partnera
 *  \param Ch  - pritisnuti taster
 */
 
function PartnBlok(Ch)
*{
LOCAL cSif:=PARTN->id, cSif2:=""

if Ch==K_CTRL_T .and. gSKSif=="D"
 // provjerimo da li je sifra dupla
 PushWA()
 SET ORDER TO TAG "ID"
 SEEK cSif
 SKIP 1
 cSif2:=PARTN->id
 PopWA()
 IF !(cSif==cSif2)
   // ako nije dupla provjerimo da li postoji u kumulativu
   if ImaUSuban(cSif, "7")
     Beep(1)
     Msg("Stavka partnera se ne moze brisati jer se vec nalazi u knjizenjima!")
     return 7
   endif
 ENDIF
elseif Ch==K_F2 .and. gSKSif=="D"
 if ImaUSuban(cSif,"7")
   return 99
 endif
elseif Ch==K_F5
  IzfUgovor()
  return DE_REFRESH

endif

RETURN DE_CONT

/*! \fn P_KontoFin(cId,dx,dy,lBlag)
 *  \brief Otvara sifrarnik konta spec. za FIN
 *  \param cId
 *  \param dx
 *  \param dy
 *  \param lBlag
 */
function P_KontoFin(cId,dx,dy,lBlag)

private ImeKol:={}
private Kol:={}
ImeKol:={ { PADR("ID",7),  {|| id },     "id"  , {|| .t.}, {|| vpsifra(wid)} },;
          { "Naziv",       {|| naz},     "naz"      };
        }

if KONTO->(FIELDPOS("POZBILS"))<>0
  AADD (ImeKol,{ padr("Poz.u bil.st.",20 ), {|| pozbils}, "pozbils" })
endif
if KONTO->(FIELDPOS("POZBILU"))<>0
  AADD (ImeKol,{ padr("Poz.u bil.usp.",20 ), {|| pozbilu}, "pozbilu" })
endif

if KONTO->(FIELDPOS("OZNAKA"))<>0
  AADD (ImeKol,{ padr("Oznaka",20 ), {|| oznaka}, "oznaka" })
endif

FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

IF lBlag==NIL; lBlag:=.f.; ENDIF

PushWa()
select (F_SIFK)
if !used()
  O_SIFK; O_SIFV
endif

select sifk; set order to tag "ID"; seek "KONTO"
do while !eof() .and. ID="KONTO"

 AADD (ImeKol, {  IzSifKNaz("KONTO",SIFK->Oznaka) })
 AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('KONTO','" + sifk->oznaka + "')) }" ) )
 AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 if sifk->edkolona > 0
   for ii:=4 to 9
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
   AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
 else
   for ii:=4 to 10
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
 endif

 // postavi picture za brojeve
 if sifk->Tip="N"
   if f_decimal > 0
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina - sifk->f_decimal-1 )+"."+replicate("9",sifk->f_decimal)
   else
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina )
   endif
 endif

 AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )

 skip
enddo

IF lBlag .and. !LEFT(cId,1)$"0123456789"
  SELECT KONTO
  // ukini zaostali filter
  SET FILTER TO
  // postavi filter za zadanu vrijednost karakteristike BLOP
  cFilter := "DaUSifV('KONTO','BLOP',ID,"+cm2str(TRIM(cId))+")"
  SET FILTER TO &cFilter
  GO TOP
  cId:=SPACE(LEN(cId))
ENDIF
PopWa()

return PostojiSifra(F_KONTO,1,10,100,"Lista: Konta ",@cId,dx,dy,{|Ch| KontoBlok(Ch)},,,,,{"ID"})




/*! \fn KontoBlok(Ch)
 *  \brief Obradjuje funkcije nad sifrarnikom konta
 *  \param Ch  - pritisnuti taster
 */
 
function KontoBlok(Ch)

LOCAL nRec:=RECNO(), cId:=""
LOCAL cSif:=KONTO->id, cSif2:=""

@ m_x+11,45 SAY "<a-P> - stampa k.plana"

if Ch==K_CTRL_T .and. gSKSif=="D"
 // provjerimo da li je sifra dupla
 PushWA()
 SET ORDER TO TAG "ID"
 SEEK cSif
 SKIP 1
 cSif2:=KONTO->id
 PopWA()
 IF !(cSif==cSif2)
   if ImaUSuban(KONTO->id, "6")
     Beep(1)
     Msg("Stavka konta se ne moze brisati jer se vec nalazi u knjizenjima!")
     return 7
   endif
 ENDIF
elseif Ch==K_F2 .and. gSKSif=="D"
 if ImaUSuban(KONTO->id,"6")
   return 99
 endif
endif

if Ch<>K_ALT_P
 return DE_CONT
endif

PRIVATE cKonto:=SPACE(60)
PRIVATE cSirIs:="0", cOdvKlas:="N", cOstran:="D"

DO WHILE .t.
 IF !VarEdit({{"Konto (prazno-sva)","cKonto",,"@!S30",},;
              {"Sirina ispisa (0 - 10CPI, 1 - 12CPI, 2 - 17CPI, 3 - 20CPI)","cSirIs","cSirIs$'0123'",,},;
              {"Odvajati klase novom stranicom (D - da, N - ne) ?","cOdvKlas","cOdvKlas$'DN'","@!",},;
              {"Ukljuceno ostranicavanje ? (D - da, N - ne) ?","cOstran","cOstran$'DN'","@!",} },;
              10,3,17,76,;
              'POSTAVLJANJE USLOVA ZA PRIKAZ KONTA',;
              "B1")
   return DE_CONT
 ENDIF
 aUsl1:=Parsiraj(cKonto,"id")
 if aUsl1<>NIL
   exit
 else
   MsgBeep ("Kriterij za konto nije korektno postavljen!")
 endif
ENDDO


SET FILTER TO &aUsl1

START PRINT CRET

?
B_ON
? "K O N T N I    P L A N"
? "----------------------"
B_OFF
?

IF cSirIs=="1"
  F12CPI
ELSEIF cSirIs=="2"
  P_COND
ELSEIF cSirIs=="3"
  P_COND2
ENDIF

GO TOP
DO WHILE ! EOF()
 cId:=RTRIM(id)

 ? SPACE(IF(LEN(cId)>3,6,IF(LEN(cId)==3,3,LEN(cId)-1)))
 ?? PADR(cId,15-pcol(),".")
 ?? naz
 SKIP 1
 IF cOdvKlas=="D" .and. LEFT(cId,1)!=LEFT(id,1) .or. cOstran=="D" .and. prow()>60+gPStranica
   FF
   LOOP
 ENDIF
 IF LEN(cId)>3 .and. LEN(RTRIM(id))<4 .or. LEN(cId)==LEN(RTRIM(id)) .and. LEN(cId)<4 .or. LEFT(cId,3)!=LEFT(id,3)
   ?
 ENDIF
ENDDO

FF
END PRINT

SET FILTER TO

GO nRec

return DE_CONT




/*! \fn P_PKonto(cId,dx,dy)
 *  \brief Otvara sifrarnik prenosa konta u novu godinu
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_PKonto(CId,dx,dy)

PRIVATE ImeKol,Kol
ImeKol:={ { "ID  ",  {|| id },   "id"   , {|| .t.}, {|| vpsifra(wid)}    },;
          { PADC("Tip prenosa",25), {|| PADC(TipPkonto(tip),25)},     "tip" ,{|| .t.}, {|| wtip $ "123456"}     };
        }
Kol:={1,2}

return PostojiSifra(F_PKONTO,1,10,60,"Lista: Nacin prenosa konta u novu godinu",@cId,dx,dy)



/*! \fn TipPKonto(cTip)
 *  \brief Tip prenosa konta u novu godinu
 *  \param cTip
 */
 
function TipPKonto(cTip)

if cTip="2"
  return "po saldu partnera"
elseif cTip="1"
  return "po otvorenim stavkama"
elseif cTip="3"
  return "otv.st. bez sabiranja"
elseif cTip="4"
  return "po rj,funk,fond"
elseif cTip="5"
  return "po rj,fond"
elseif cTip="6"
  return "po rj"
else
  return "??????????????"
endif


/*! \fn P_Funk(cId,dx,dy)
 *  \brief Otvara sifranik funkcionalnih klasifikacija 
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Funk(cId,dx,dy)

private imekol,kol

ImeKol:={ { padr("Id",5)    , {|| id}  , "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",50), {||  naz}, "naz" } ;
        }
Kol:={1,2}

return PostojiSifra(F_FUNK,1,10,70,"Lista funkcionalne klasifikacije",@cId,dx,dy)



/*! \fn P_Fond(cId,dx,dy)
 *  \brief Otvara sifrarnik fondova
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Fond(cId,dx,dy)

private imekol,kol

ImeKol:={ { padr("Id",3)    , {|| id}  , "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",50), {||  naz}, "naz" } ;
        }
Kol:={1,2}

return PostojiSifra(F_FOND,1,10,70,"Lista: Fondovi",@cId,dx,dy)



/*! \fn P_BuIz(cId,dx,dy)
 *  \brief Otvara sifrarnik konta-izuzetci
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_BuIz(cId,dx,dy)

private imekol,kol

ImeKol:={ { padr("Konto",10)    , {|| id}  , "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("pretvori u",10), {||  naz}, "naz" } ;
        }
Kol:={1,2}

return PostojiSifra(F_BUIZ,1,10,70,"Lista: konta-izuzeci u sortiranju",@cId,dx,dy)



/*! \fn P_Budzet(cId,dx,dy)
 *  \brief Otvara sifrarnik plana budzeta
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Budzet(cId,dx,dy)

private imekol,kol

ImeKol:={ { "Glava",   {|| idrj}, "idrj",, {|| empty(wIdRj) .or. P_RJ (@wIdRj)}},;
          { "Konto",   {|| Idkonto}, "Idkonto",, {|| gMeniSif:=.f., P_KontoFin (@wIdkonto), gMeniSif:=.t.,.t.}},;
          { "Iznos",   {|| Iznos}, "iznos" },;
          { "Rebalans",{|| rebiznos}, "rebiznos" },;
          { "Fond",   {|| Fond}, "fond" , {|| gMeniSif:=.f.,wfond $ "N1 #N2 #N3 " .or. empty(wFond) .or. P_FOND(@wFond), gMeniSif:=.t.,.t.}  },;
          { "Funk",   {|| Funk}, "funk", {|| gMeniSif:=.f.,empty(wFunk) .or.P_funk(@wFunk), gMeniSif:=.t.,.t.} };
       }
Kol:={1,2,3,4,5,6}

return PostojiSifra(F_BUDZET,1,10,55,"Plan budzeta za tekucu godinu",@cId,dx,dy)




/*! \fn P_ParEK(cId,dx,dy)
 *  \brief Otvara sifrarnik ekonomskih kategorija
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_ParEK(cId,dx,dy)

private imekol,kol

ImeKol:={ { "Partija", {|| IdPartija}, "idpartija",, {|| vpsifra (wIdPartija)}},;
          { "Konto"  , {|| IdKonto}, "Idkonto",, {|| gMeniSif:=.f.,P_KontoFin (@wIdKonto), gMeniSif:=.t.,.t.}};
       }
Kol:={1,2}

return PostojiSifra(F_PAREK,1,10,55,"Partije->Konta" ,@cId,dx,dy)



/*! \fn P_TRFP2(cId,dx,dy)
 *  \brief Otvara sifrarnik parametri prenosa u FP
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_TRFP2(cId,dx,dy)

private imekol,kol
ImeKol:={  ;
           { "VD",  {|| padc(IdVD,4)} ,    "IdVD"                  },;
           { padc("Shema",5),    {|| padc(shema,5)},      "shema"                    },;
           { padc("ID",10),    {|| id },      "id"                    },;
           { padc("Naziv",20), {|| naz},     "naz"                   },;
           { "Konto  ", {|| idkonto},        "Idkonto" , {|| .t.} , {|| ("?" $ widkonto) .or. ("A" $ widkonto) .or. ("B" $ widkonto) .or. ("IDKONT" $ widkonto) .or.  P_kontoFin(@wIdkonto) }   },;
           { "Tarifa", {|| idtarifa},        "IdTarifa"              },;
           { "D/P",   {|| padc(D_P,3)},      "D_P"                   },;
           { "Znak",    {|| padc(Znak,4)},        "ZNAK"                  },;
           { "Dokument", {|| padc(Dokument,8)},   "Dokument"              },;
           { "Partner", {|| padc(Partner,7)},     "Partner"               },;
           { "IDVN",    {|| padc(idvn,4)},        "idvn"                  };
        }
Kol:={1,2,3,4,5,6,7,8,9,10,11}

private cShema:=" ", ckavd:="  "

if Pitanje(,"Zelite li postaviti filter za odredjenu shemu","N")=="D"
  Box(,1,60)
     @ m_x+1,m_y+2 SAY "Odabir sheme:" GET cShema  pict "@!"
     @ m_x+1,col()+2 SAY "vrsta kalkulacije (prazno sve)" GET cKavd pict "@!"
     read
  Boxc()
  select trfp2
  cFiltTRFP2 := "shema="+cm2str(cShema) + IF(!EMPTY(cKaVD),".and.IDVD=="+cm2str(cKaVD),"")
  SET FILTER TO &cFiltTRFP2
  go top
else
  select trfp2
  set filter to
endif
return PostojiSifra(F_TRFP2,1,15,76,"Parametri prenosa u FP",@cId,dx,dy)
select trfp2
set filter to
return




/*! \fn P_TRFP3(cId,dx,dy)
 *  \brief Otvara sifrarnik shema kontiranja obracuna LD
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_TRFP3(cId,dx,dy)

private imekol,kol
ImeKol:={  { padc("Shema",5),    {|| padc(shema,5)},      "shema"     },;
           { padc("Formula/ID",10),    {|| id },      "id"            },;
           { padc("Naziv",20), {|| naz},     "naz"                   },;
           { "Konto  ", {|| idkonto},        "Idkonto" , {|| .t.} , {|| ("?" $ widkonto) .or. ("A" $ widkonto) .or. ("B" $ widkonto) .or. ("IDKONT" $ widkonto) .or.  P_kontoFin(@wIdkonto) }   },;
           { "D/P",   {|| padc(D_P,3)},      "D_P"                   },;
           { "Znak",    {|| padc(Znak,4)},        "ZNAK"                  },;
           { "IDVN",    {|| padc(idvn,4)},        "idvn"                  };
        }
Kol:={1,2,3,4,5,6,7}

private cShema:=" "

if Pitanje(,"Zelite li postaviti filter za odredjenu shemu","N")=="D"
  Box(,1,60)
     @ m_x+1,m_y+2 SAY "Odabir sheme:" GET cShema  pict "@!"
     read
  Boxc()
  select trfp3
  cFiltTRFP3 := "shema="+cm2str(cShema)
  SET FILTER TO &cFiltTRFP3
  go top
else
  select trfp3
  set filter to
endif
return PostojiSifra(F_TRFP3,1,15,76,"Sheme kontiranja obracuna LD",@cId,dx,dy)
select trfp3
set filter to
return



/*! \fn ImaUSuban(cKljuc,cTag)
 *  \brief 
 *  \param cKljuc
 *  \param cTag
 */
 
function ImaUSuban(cKljuc,cTag)

LOCAL lVrati:=.f., lUsed:=.t., nArr:=SELECT()

  SELECT (F_SUBAN)
  IF !USED()
    lUsed:=.f.
    O_SUBAN
  ELSE
    PushWA()
  ENDIF

  SET ORDER TO TAG (cTag)
  SEEK cKljuc
  lVrati:=found()
  IF !lUsed
    USE
  ELSE
    PopWA()
  ENDIF
  select (nArr)
RETURN lVrati

 
function P_Roba_fin(CId,dx,dy)

local cPrikazi

return .t.


/*! \fn P_ULimit(cId,dx,dy)
 *  \brief Otvara sifrarnik limita po ugovorima
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_ULIMIT(cId,dx,dy)

PRIVATE ImeKol,Kol:={}
ImeKol:={ { "ID "        , {|| id       }, "id"       , {|| .t.}, {|| vpsifra(wId)},,"999" },;
          { "ID partnera", {|| idpartner}, "idpartner", {|| .t.}, {|| P_Firma(@wIdPartner)} },;
          { "Limit"      , {|| limit    }, "limit"      };
        }
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_ULIMIT,1,10,55,"Sifrarnik limita po ugovorima",@cid,dx,dy)




/*! \fn DFTParU2(lIni)
 *  \brief Tekuci podaci za nove ugovore
 *  \param lIni
 */
 
function DFTParU2(lIni)

LOCAL GetList:={}
  IF lIni==NIL; lIni:=.f.; ENDIF
  select (F_PARAMS)

  select (F_PARAMS);  use (strtran(PRIVPATH+"params","FIN","FAKT"))  ; set order to tag  "ID"
  private cSection:="2",cHistory:=" "; aHistory:={}

  IF !lIni
    private DFTkolicina:=1
    private DFTidroba:=PADR("ZIPS",10)
    private DFTvrsta:="1"
    private DFTidtipdok:="20"
    //
    private DFTdindem:="KM "
    private DFTidtxt:="10"
    private DFTzaokr:=2
    private DFTiddodtxt:="  "
  ENDIF

  RPar("01",@DFTkolicina)
  RPar("02",@DFTidroba)
  RPar("03",@DFTvrsta   )
  RPar("04",@DFTidtipdok)
  RPar("05",@DFTdindem  )
  RPar("06",@DFTidtxt   )
  RPar("07",@DFTzaokr   )
  RPar("08",@DFTiddodtxt)

  IF !lIni
    Box(,10,75)
     @ m_X+ 0,m_y+23 SAY "TEKUCI PODACI ZA NOVE UGOVORE"
     @ m_X+ 2,m_y+ 2 SAY "Artikal        " GET DFTidroba VALID EMPTY(DFTidroba) .or. P_Roba(@DFTidroba,2,28) PICT "@!"
     @ m_X+ 3,m_y+ 2 SAY "Kolicina       " GET DFTkolicina PICT pickol
     @ m_X+ 4,m_y+ 2 SAY "Tip ug.(1/2)   " GET DFTvrsta    VALID DFTvrsta$"12"
     @ m_X+ 5,m_y+ 2 SAY "Tip dokumenta  " GET DFTidtipdok
     @ m_X+ 6,m_y+ 2 SAY "Valuta (KM/DEM)" GET DFTdindem   PICT "@!"
     @ m_X+ 7,m_y+ 2 SAY "Napomena 1     " GET DFTidtxt    VALID P_FTXT(@DFTidtxt)
     @ m_X+ 8,m_y+ 2 SAY "Napomena 2     " GET DFTiddodtxt VALID P_FTXT(@DFTiddodtxt)
     @ m_X+ 9,m_y+ 2 SAY "Zaokruzenje    " GET DFTzaokr    PICT "9"
     READ
    BoxC()

    IF LASTKEY()!=K_ESC
      WPar("01",DFTkolicina)
      WPar("02",DFTidroba)
      WPar("03",DFTvrsta   )
      WPar("04",DFTidtipdok)
      WPar("05",DFTdindem  )
      WPar("06",DFTidtxt   )
      WPar("07",DFTzaokr   )
      WPar("08",DFTiddodtxt)
    ENDIF
  ENDIF
  USE
RETURN


/*! \fn P_Kuf(cId,dx,dy)
 *  \brief Otvara sifrarnik KUF
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_KUF(cId,dx,dy)

PRIVATE ImeKol:={},Kol:={}
 PRIVATE pbF8:={|| MNNSifru()}
 IF gRJ=="D"
   AADD( ImeKol, { "Sifra RJ"    , {|| idrj     }, "idrj"     , {|| .t.}, {|| P_RJ(@wIdRJ)} } )
   AADD( ImeKol, { "KUF broj"    , {|| id       }, "id"       , {|| .t.}, {|| mvpsifra(wIdRJ+wId)},,"@!" } )
 ELSE
   AADD( ImeKol, { "KUF broj"    , {|| id       }, "id"       , {|| .t.}, {|| vpsifra(wId)},,"@!" } )
 ENDIF
 AADD( ImeKol, { "Opis"        , {|| NAZ      }, "NAZ"          } )
 AADD( ImeKol, { "Dat.prijema" , {|| DATPR    }, "DATPR"        } )
 AADD( ImeKol, { "ID partnera" , {|| idpartn  }, "idpartn"  , {|| .t.}, {|| P_Firma(@wIdPartn)} } )
 AADD( ImeKol, { "Dat.fakture" , {|| DATFAKT  }, "DATFAKT"      } )
 AADD( ImeKol, { "Br.fakture"  , {|| BRFAKT   }, "BRFAKT"       } )
 AADD( ImeKol, { "Iznos"       , {|| IZNOS    }, "IZNOS"        } )
 IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
   AADD( ImeKol , { "Vrsta plac." , {|| IDVRSTEP }, "IDVRSTEP" , {|| .t.}, {|| P_VrsteP(@wIdVrsteP)} } )
 ENDIF
 AADD( ImeKol , { "Rok placanja", {|| DATPL    }, "DATPL"        } )
 AADD( ImeKol , { "Placeno"     , {|| PLACENO  }, "PLACENO"  ,,,,"@!"    } )
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_KUF,IF(gRJ=="D","ID2",1),15,77,"KUF",@cid,dx,dy,{|Ch| KUFBlok(Ch)})




/*! \fn KUFBlok(Ch)
 *  \brief Obradjuje operacije nad sifrarnikom KUF-a
 *  \param Ch - pritisnuti taster
 */
 
function KUFBlok(Ch)

LOCAL nRec:=RECNO()
  @ m_x+16,45 SAY "<a-P> - stampa KUF-a"
  IF Ch<>K_ALT_P
    RETURN DE_CONT
  ENDIF
  START PRINT CRET
  ?

   GO TOP

   // ---------------------------------------------------------------------
   // -?-
  PRIVATE cNPartnera:="", ukPartner:=0
  gTabela:=1; gOstr:="D"
  lLinija:= ( IzFMKIni("KUF","OdvajajRedoveLinijom","N",KUMPATH) == "D" )

  // priprema matrice aKol za f-ju StampaTabele()
  // --------------------------------------------
  aKol:={}
  nKol:=0
  AADD(aKol, { "BR.KUF"           , {|| id           }, .f., "C",  8, 0, 1, ++nKol } )
  AADD(aKol, { "DATUM"            , {|| DATPR        }, .f., "D",  8, 0, 1, ++nKol } )
  AADD(aKol, { "PRIJEMA"          , {|| "#"          }, .f., "C",  8, 0, 2,   nKol } )
  AADD(aKol, { "PARTNER"          , {|| idpartn      }, .f., "C",  7, 0, 1, ++nKol } )
  AADD(aKol, { "NAZIV PARTNERA"   , {|| cNPartnera   }, .f., "C", 40, 0, 1, ++nKol } )
  AADD(aKol, { "DATUM"            , {|| DATFAKT      }, .f., "D",  8, 0, 1, ++nKol } )
  AADD(aKol, { "FAKTURE"          , {|| "#"          }, .f., "C",  8, 0, 2,   nKol } )
  AADD(aKol, { "BROJ FAKTURE"     , {|| BRFAKT       }, .f., "C", 20, 0, 1, ++nKol } )
  AADD(aKol, { "OPIS"             , {|| NAZ          }, .f., "C", 20, 0, 1, ++nKol } )
  AADD(aKol, { "IZNOS"            , {|| IZNOS        }, .t., "N", 15, 2, 1, ++nKol } )
  AADD(aKol, { "VRSTA"            , {|| IDVRSTEP     }, .f., "C",  5, 0, 1, ++nKol } )
  AADD(aKol, { "PLAC."            , {|| "#"          }, .f., "C",  5, 0, 2,   nKol } )
  AADD(aKol, { "ROK"              , {|| DATPL        }, .f., "D",  8, 0, 1, ++nKol } )
  AADD(aKol, { "PLACANJA"         , {|| "#"          }, .f., "C",  8, 0, 2,   nKol } )
  AADD(aKol, { "PLACENO"          , {|| PLACENO      }, .f., "C",  7, 0, 1, ++nKol } )


  // stampanje izvjestaja
  // --------------------

  IF gPrinter=="L"
    gPO_Land()
  ENDIF

  Preduzece()
  ? "FIN: Izvjestaj na dan",date()
  ?
  P_10CPI
  B_ON
   ? "K NJ I G A    U L A Z N I H    F A K T U R A   -   KUF"
   ? "------------------------------------------------------"
  B_OFF
  ?

  StampaTabele(aKol,{|| KUFSvaki1()},,gTabela,,,NIL,;
                               {|| KUFFor1()},IF(gOstr=="D",,-1),,lLinija,,,)
  // Nap.: NIL argument sam stavio tamo gdje ide naslov!

  IF gPrinter=="L"
    gPO_Port()
  ENDIF
   // -?-
   // ---------------------------------------------------------------------

   FF

  END PRINT
  GO nRec
return DE_CONT



/*! \fn KUFFor1()
 *  \brief
 */
 
function KUFFor1()

RETURN .t.



/*! \fn KUFSvaki1()
 *  \brief
 */
 
function KUFSvaki1()

cNPartnera:=Ocitaj(F_PARTN,IDPARTN,"naz")
RETURN




/*! \fn P_Kif(cId,dx,dy)
 *  \brief Otvara sifrarnik KIF-a
 *  \param cId
 *  \param dx
 *  \param dy
 */
function P_KIF(cId,dx,dy)

PRIVATE ImeKol:={},Kol:={}
 PRIVATE pbF8:={|| MNNSifru()}
 IF gRJ=="D"
   AADD( ImeKol, { "Sifra RJ"    , {|| idrj     }, "idrj"     , {|| .t.}, {|| P_RJ(@wIdRJ)} } )
   AADD( ImeKol, { "KIF broj"    , {|| id       }, "id"       , {|| .t.}, {|| mvpsifra(wIdRJ+wId)},,"@!" } )
 ELSE
   AADD( ImeKol, { "KIF broj"    , {|| id       }, "id"       , {|| .t.}, {|| vpsifra(wId)},,"@!" } )
 ENDIF
 AADD( ImeKol, { "Opis"        , {|| NAZ      }, "NAZ"          } )
 AADD( ImeKol, { "Dat.prijema" , {|| DATPR    }, "DATPR"        } )
 AADD( ImeKol, { "ID partnera" , {|| idpartn  }, "idpartn"  , {|| .t.}, {|| P_Firma(@wIdPartn)} } )
 AADD( ImeKol, { "Dat.fakture" , {|| DATFAKT  }, "DATFAKT"      } )
 AADD( ImeKol, { "Br.fakture"  , {|| BRFAKT   }, "BRFAKT"       } )
 AADD( ImeKol, { "Iznos"       , {|| IZNOS    }, "IZNOS"        } )
 IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
   AADD( ImeKol , { "Vrsta plac." , {|| IDVRSTEP }, "IDVRSTEP" , {|| .t.}, {|| P_VrsteP(@wIdVrsteP)} } )
 ENDIF
 AADD( ImeKol , { "Rok placanja", {|| DATPL    }, "DATPL"        } )
 AADD( ImeKol , { "Vrsta prih." , {|| IDVPRIH  }, "IDVPRIH"  , {|| .t.}, {|| P_VPrih(@wIdVPrih)} } )
 AADD( ImeKol , { "Placeno"     , {|| PLACENO  }, "PLACENO"  ,,,,"@!"    } )
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
RETURN PostojiSifra(F_KIF,IF(gRJ=="D","ID2",1),15,77,"KIF",@cid,dx,dy,{|Ch| KIFBlok(Ch)})



/*! \fn KifBlok(Ch)
 *  \brief Obradjuje funkcije nad sifrarnikom KIF-a
 *  \param Ch - pritisnuti taster
 */
 
function KifBlok(Ch)

LOCAL nRec:=RECNO()
  @ m_x+16,45 SAY "<a-P> - stampa KIF-a"
  IF Ch<>K_ALT_P
    RETURN DE_CONT
  ENDIF
  START PRINT CRET
  ?
  GO TOP

   // ---------------------------------------------------------------------
   // -?-
  PRIVATE cNPartnera:="", ukPartner:=0
  gTabela:=1; gOstr:="D"
  lLinija:= ( IzFMKIni("KIF","OdvajajRedoveLinijom","N",KUMPATH) == "D" )

  // priprema matrice aKol za f-ju StampaTabele()
  // --------------------------------------------
  aKol:={}
  nKol:=0
  AADD(aKol, { "BR.KIF"           , {|| id           }, .f., "C",  8, 0, 1, ++nKol } )
  AADD(aKol, { "DATUM"            , {|| DATPR        }, .f., "D",  8, 0, 1, ++nKol } )
  AADD(aKol, { "PRIJEMA"          , {|| "#"          }, .f., "C",  8, 0, 2,   nKol } )
  AADD(aKol, { "PARTNER"          , {|| idpartn      }, .f., "C",  7, 0, 1, ++nKol } )
  AADD(aKol, { "NAZIV PARTNERA"   , {|| cNPartnera   }, .f., "C", 40, 0, 1, ++nKol } )
  AADD(aKol, { "DATUM"            , {|| DATFAKT      }, .f., "D",  8, 0, 1, ++nKol } )
  AADD(aKol, { "FAKTURE"          , {|| "#"          }, .f., "C",  8, 0, 2,   nKol } )
  AADD(aKol, { "BROJ FAKTURE"     , {|| BRFAKT       }, .f., "C", 20, 0, 1, ++nKol } )
  AADD(aKol, { "OPIS"             , {|| NAZ          }, .f., "C", 20, 0, 1, ++nKol } )
  AADD(aKol, { "IZNOS"            , {|| IZNOS        }, .t., "N", 15, 2, 1, ++nKol } )
  AADD(aKol, { "VRSTA"            , {|| IDVRSTEP     }, .f., "C",  5, 0, 1, ++nKol } )
  AADD(aKol, { "PLAC."            , {|| "#"          }, .f., "C",  5, 0, 2,   nKol } )
  AADD(aKol, { "ROK"              , {|| DATPL        }, .f., "D",  8, 0, 1, ++nKol } )
  AADD(aKol, { "PLACANJA"         , {|| "#"          }, .f., "C",  8, 0, 2,   nKol } )
  AADD(aKol, { "PLACENO"          , {|| PLACENO      }, .f., "C",  7, 0, 1, ++nKol } )


  // Átampanje izvjeÁtaja
  // --------------------

  IF gPrinter=="L"
    gPO_Land()
  ENDIF

  Preduzece()
  ? "FIN: Izvjestaj na dan",date()
  ?
  P_10CPI
  B_ON
   ? "K NJ I G A   I Z L A Z N I H   F A K T U R A   -   KIF"
   ? "------------------------------------------------------"
  B_OFF
  ?

  StampaTabele(aKol,{|| KIFSvaki1()},,gTabela,,,NIL,;
                               {|| KIFFor1()},IF(gOstr=="D",,-1),,lLinija,,,)
  // Nap.: NIL argument sam stavio tamo gdje ide naslov!

  IF gPrinter=="L"
    gPO_Port()
  ENDIF
   // -?-
   // ---------------------------------------------------------------------

   FF

  END PRINT
  GO nRec
return DE_CONT



/*! \fn KifFor1()
 *  \brief
 */
 
function KIFFor1()

RETURN .t.


/*! \fn KifSvaki1()
 *  \brief
 */
 
function KIFSvaki1()

cNPartnera:=Ocitaj(F_PARTN,IDPARTN,"naz")
RETURN



/*! \fn P_VPrih(cId,dx,dy)
 *  \brief Otvara sifrarnik vrsta prihoda
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_VPrih(cId,dx,dy)

PRIVATE ImeKol,Kol:={}
ImeKol:={ { "ID ",  {|| id },       "id"  , {|| .t.}, {|| vpsifra(wId)}      },;
          { PADC("Naziv",20), {|| naz},      "naz"       };
        }
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_VPRIH,1,10,55,"Sifrarnik vrsta prihoda",@cid,dx,dy)




/*! \fn Mvpsifra(wId)
 *  \brief Zabranjuje dupli unos sifre
 *  \param wId
 */
 
static function MvpSifra(wId)

local nrec:=recno(), nRet:=.t., nPrevOrd:=INDEXORD()
SET ORDER TO TAG "ID2"
seek wid
if found() .and. Ch==K_CTRL_N
  Beep(3)
  nRet:=.f.
elseif gSKSif=="D" .and. found()   // naÁao na ispravci ili dupliciranju
  if nRec<>RECNO()
    Beep(3)
    nRet:=.f.
  else       // bio isti zapis, idi na drugi
    skip 1
    if !EOF() .and. wid==id
      Beep(3)
      nRet:=.f.
    endif
  endif
endif
ordsetfocus(nPrevOrd)     //vrati order sifranika !!
go nrec
return nRet



/*! \fn MNNSifru()
 *  \brief Nadji novu sifru - radi na pritisak <F8> pri unosu nove sifre
 */
 
function MNNSifru()     
                        
 LOCAL cPom, nDuzSif:=0, nDuzUn:=0, cLast:="¨è¶Ê—", nKor:=0
 LOCAL lKUFKIF:=.f.
 PRIVATE cImeVar:=READVAR()
 cPom:=&(cImeVar)
 lKIFKUF := ( cImeVar=="WID" .and. TRIM(UPPER(PROCNAME(12)))$"P_KUF#P_KIF" )
 // MsgBeep( "PROCNAME(11)="+PROCNAME(11)+;
 //          ", PROCNAME(12)="+PROCNAME(12)+;
 //          ", PROCNAME(13)="+PROCNAME(13) )
 IF !lKIFKUF
  RETURN .f.
 ELSE
  nDuzSif:=LEN(cPom)
  nDuzUn:=LEN(TRIM(cPom))
  cPom:=PADR(RTRIM(cPom),nDuzSif,"Z")
  PushWA()
  set order to tag "ID2"
  GO TOP
   SEEK widrj+cPom
   SKIP -1
   &(cImeVar):=PADR(NovaSifra( IF( EMPTY(id) , id , RTRIM(id) ) ),nDuzSif," ")
  AEVAL(GetList,{|o| o:display()})
  PopWA()
 ENDIF
RETURN .t.


