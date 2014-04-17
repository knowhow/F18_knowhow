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
  O_SIFK
  O_SIFV
endif

select sifk; set order to tag "ID"; seek "PARTN"
do while !eof() .and. ID="PARTN"

 AADD (ImeKol, {  IzSifKNaz("PARTN", SIFK->Oznaka) })
 AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifkPartn('" + sifk->oznaka + "')) }" ) )
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
local i
local _t_area := SELECT()
private ImeKol := {}
private Kol := {}

O_KONTO

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

for i := 1 to LEN(ImeKol)
      AADD( Kol, i )
next

if lBlag == NIL
      lBlag := .f.
endif

SELECT konto
sif_sifk_fill_kol( "KONTO", @ImeKol, @Kol )

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

SELECT KONTO
SET ORDER TO TAG "ID"

PostojiSifra(F_KONTO, 1, MAXROWS() - 17, MAXCOLS() - 10, "LKTF Lista: Konta ", @cId, dx, dy, {|Ch| KontoBlok(Ch)},,,,,{"ID"})

SELECT ( _t_area )

return .t.




/*! \fn KontoBlok(Ch)
 *  \brief Obradjuje funkcije nad sifrarnikom konta
 *  \param Ch  - pritisnuti taster
 */
 
function KontoBlok(Ch)

LOCAL nRec:=RECNO(), cId:=""
LOCAL cSif:=KONTO->id, cSif2:=""

//@ m_x+11,45 SAY "<a-P> - stampa k.plana"

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

return p_sifra(F_PKONTO, 1, 10, 60, "MatPod: Način prenosa konta u novu godinu",@cId, dx, dy)



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


// -------------------------------------------
// kamatne stope
// -------------------------------------------
function P_KS(cId,dx,dy)
local _i
private imekol := {}
private kol := {}

O_KS

AADD( imekol, { PADR( "ID", 3 ) , {|| id }  , "id", {|| .t.}, {|| vpsifra(wid)} } )
AADD( imekol, { PADR( "Tip", 3 ) , {|| PADC( tip, 3 ) }  , "tip" } )
AADD( imekol, { PADR( "DatOd", 8 ) , {|| datod }  , "datod" } )
AADD( imekol, { PADR( "DatDo", 8 ) , {|| datdo }  , "datdo" } )
AADD( imekol, { PADR( "Rev", 6 ) , {|| strev }  , "strev" } )
AADD( imekol, { PADR( "Kam", 6 ) , {|| stkam }  , "stkam" } )
AADD( imekol, { PADR( "DENOM", 15 ) , {|| den }  , "den" } )
AADD( imekol, { PADR( "Duz.", 4 ) , {|| duz }  , "duz" } )

for _i := 1 to LEN( imekol )
    AADD( kol, _i )
next

return p_sifra( F_KS, 1, MAXROWS()-10, MAXCOLS()-5, "Lista kamatni stopa",@cId,dx,dy)




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
          { "Limit"      , {|| f_limit    }, "f_limit"      };
        }
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_ULIMIT,1,10,55,"Sifrarnik limita po ugovorima",@cid,dx,dy)




