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


#include "fakt.ch"


// ------------------------------------------------------------------------
// P_KalPos(cId,dx,dy)
// Otvara sifranik kalendar posjeta ako se u uslovu zada ID koji ne postoji
// ------------------------------------------------------------------------
function P_KalPos(cId,dx,dy)

PRIVATE ImeKol,Kol:={}
ImeKol:={ ;
          { "DATUM"         , {|| datum}   , "datum"    },;
          { "Relacija"      , {|| idrelac} , "idrelac"  , {|| .t.}, {|| P_Relac(@widrelac)  } },;
          { "Distributer"   , {|| iddist } , "iddist"   , {|| .t.}, {|| P_Firma(@widdist)   } },;
          { "Vozilo"        , {|| idvozila}, "idvozila" , {|| .t.}, {|| P_Vozila(@widvozila)} },;
          { "Realizovano"   , {|| realiz  }, "realiz"   };
        }
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

return PostojiSifra(F_KALPOS, 1, 10, 75, "Kalendar posjeta", @cId, dx, dy)




// ---------------------------------------------
// P_Relac(cId,dx,dy)
// Otvara sifranik relacija
// ---------------------------------------------
function P_Relac(cId,dx,dy)
PRIVATE ImeKol,Kol:={}
ImeKol:={ ;
          { "ID"                 , {|| id },       "id"  , {|| .t.}, {|| .t.}     },;
          { "Naziv i sort(r.br.)", {|| naz},       "naz"       },;
          { "Sifra kupca"        , {|| idpartner}, "idpartner" , {|| .t.}, {|| P_Firma(@widpartner)} },;
          { "Prodajno mjesto"    , {|| idpm}     , "idpm"      , {|| .t.}, {|| P_IDPM(@widpm,widpartner)} };
        }
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

return PostojiSifra(F_RELAC, 1, 10, 75, "Lista: Relacije",@cId,dx,dy)



/*! \fn P_Vozila(cId,dx,dy)
 *  \brief Otvara sifrarnik Vozila
 *  \param cId
 *  \param dx
 *  \param dy
 */
 
function P_Vozila(cId,dx,dy)

PRIVATE ImeKol,Kol:={}
ImeKol:={ ;
          { "ID"     , {|| id },     "id"  , {|| .t.}, {|| vpsifra(wId)}     },;
          { "Naziv"  , {|| naz},     "naz"      },;
          { "Tablice", {|| tablice}, "tablice"  };
        }
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

return PostojiSifra(F_VOZILA, 1, 10, 75,"Lista: Vozila",@cId,dx,dy)


/*! \fn FaPartnBlock(Ch)
 *  \brief
 *  \param 
 */
function FaPartnBlock(Ch)

LOCAL cSif:=PARTN->id, cSif2:=""

if Ch==K_F5
  	IzfUgovor()
  	return DE_REFRESH
endif

return DE_CONT



// -----------------------------------------------
// otvaranje tabele fakt_objekti
// -----------------------------------------------
function p_fakt_objekti(cId,dx,dy)
local _t_area := SELECT()
private ImeKol
private Kol

ImeKol := {}
Kol := {}

O_FAKT_OBJEKTI

AADD(ImeKol, { PADC("Id",10), {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { PADC("Naziv",60), {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select ( _t_area )

return PostojiSifra( F_FAKT_OBJEKTI, 1, MAXROWS() - 15, MAXCOLS() - 20 ,"Lista objekata", @cId, dx, dy )






/*! \fn RobaBlok(Ch)
 *  \brief 
 *  \param Ch 
 */
 
function FaRobaBlock(Ch)

LOCAL cSif:=ROBA->id, cSif2:=""
LOCAL nArr:=SELECT()


if UPPER(Chr(Ch)) == "K"
    return 6  

elseif upper(Chr(Ch)) == "D"
    // prikaz detalja sifre
    roba_opis_edit( .t. )
    return 6  

elseif upper(Chr(Ch))=="S"
    TB:Stabilize()  
    PushWa()
    FaktStanje(roba->id)
    PopWa()
    return 6  

elseif upper(CHR(ch)) == "P"
    
    if gen_all_plu()
        return DE_REFRESH
    endif

elseif Ch == K_CTRL_T .and. gSKSif=="D"
    // provjerimo da li je sifra dupla
    PushWA()
    SET ORDER TO TAG "ID"
    SEEK cSif
    SKIP 1
    cSif2:=ROBA->id
    PopWA()
    IF !(cSif==cSif2)
        // ako nije dupla provjerimo da li postoji u kumulativu
        if ima_u_fakt_kumulativ(cSif,"3")
            Beep(1)
            Msg("Stavka artikla/robe se ne moze brisati jer se vec nalazi u dokumentima!")
            return 7
        endif
    ENDIF

elseif Ch==K_F2 .and. gSKSif=="D"
    if ima_u_fakt_kumulativ(cSif,"3")
        return 99
    endif

else // nista od magicnih tipki
    return DE_CONT
endif

RETURN DE_CONT



/*! \fn FaktStanje(cIdRoba)
 *  \brief Stanje robe fakt-a
 *  \param cIdRoba
 */
 
function FaktStanje(cIdRoba)

local nUl,nIzl,nRezerv,nRevers,fOtv:=.f.,nIOrd,nFRec, aStanje
select roba
select (F_FAKT)
if !used()
   O_FAKT; fOtv:=.t.
else
  nIOrd:=indexord()
  nFRec:=recno()
endif
// "3","Idroba+dtos(datDok)","FAKT")  // za karticu, specifikaciju
set order to tag "3"
SEEK cIdRoba

aStanje:={}
//{idfirma, nUl,nIzl,nRevers,nRezerv }
nUl:=nIzl:=nRezerv:=nRevers:=0
do while !eof()  .and. cIdRoba==IdRoba
   nPos:=ASCAN (aStanje, {|x| x[1]==FAKT->IdFirma})
   if nPos==0
     AADD (aStanje, {IdFirma, 0, 0, 0, 0})
     nPos := LEN (aStanje)
   endif
   if idtipdok="0"  // ulaz
      aStanje[nPos][2] += kolicina
   elseif idtipdok="1"   // izlaz faktura
       if !(left(serbr,1)=="*" .and. idtipdok=="10")  // za fakture na osnovu optpremince ne ra~unaj izlaz
         aStanje[nPos][3] += kolicina
       endif
   elseif idtipdok$"20#27"
      if serbr="*"
         aStanje[nPos][5] += kolicina
      endif
   elseif idtipdok=="21"
      aStanje[nPos][4] += kolicina
   endif
   skip
enddo

if fotv
 selec fakt; use
else
//  set order to (nIOrd)
  dbsetorder(nIOrd)
  go nFRec
endif
select roba
fakt_box_stanje(aStanje, cIdRoba)      // nUl,nIzl,nRevers,nRezerv)
return



/*! \fn fakt_box_stanje(aStanje,cIdRoba)
 *  \brief
 *  \param aStanje
 *  \param cIdRoba
 */
 
function fakt_box_stanje(aStanje,cIdroba)

local picdem:="9999999.999", nR, nC, nTSta := 0, nTRev := 0, nTRez := 0,;
      nTOst := 0, npd, cDiv := " ³ ", nLen

 npd := LEN (picdem)
 nLen := LEN (aStanje)

 // ucitajmo dodatne parametre stanja iz FMK.INI u aDodPar
 
 aDodPar := {}
 FOR i:=1 TO 6
   cI := ALLTRIM(STR(i))
   cPomZ := IzFMKINI( "BoxStanje" , "ZaglavljeStanje"+cI , "" , KUMPATH )
   cPomF := IzFMKINI( "BoxStanje" , "FormulaStanje"+cI   , "" , KUMPATH )
   IF !EMPTY( cPomF )
     AADD( aDodPar , { cPomZ , cPomF } )
   ENDIF
 NEXT
 nLenDP := IF( LEN(aDodPar)>0 , LEN(aDodPar)+1 , 0 )

 select roba
 //PushWa()
 set order to tag "ID"; seek cIdRoba
 Box(,6+nLen+INT((nLenDP)/2),75)
  Beep(1)
  @ m_x+1,m_y+2 SAY "ARTIKAL: "
  @ m_x+1,col() SAY PADR(AllTrim(cIdRoba) + " - " + LEFT(roba->naz,40), 51) COLOR "GR+/B"
  @ m_x+3,m_y+2 SAY cDiv + "RJ" + cDiv + PADC ("Stanje", npd) + cDiv+ ;
                    PADC ("Na reversu", npd) + cDiv + ;
                    PADC ("Rezervisano", npd) + cDiv + PADC ("Ostalo", npd) ;
                    + cDiv
  nR := m_x+4
  FOR nC := 1 TO nLen
//{idfirma, nUl,nIzl,nRevers,nRezerv }
    @ nR,m_y+2 SAY cDiv
    @ nR,col() SAY aStanje [nC][1]
    @ nR,col() SAY cDiv
    nPom := aStanje [nC][2]-aStanje [nC][3]
    @ nR,col() SAY nPom pict picdem
    @ nR,col() SAY cDiv
    nTSta += nPom
    @ nR,col() SAY aStanje [nC][4] pict picdem
    @ nR,col() SAY cDiv
    nTRev += aStanje [nC][4]
    nPom -= aStanje [nC][4]
    @ nR,col() SAY aStanje [nC][5] pict picdem
    @ nR,col() SAY cDiv
    nTRez += aStanje [nC][5]
    nPom -= aStanje [nC][5]
    @ nR,col() SAY nPom pict picdem
    @ nR,col() SAY cDiv
    nTOst += nPom
    nR ++
  NEXT
    @ nR,m_y+2 SAY cDiv + "--" + cDiv + REPL ("-", npd) + cDiv+ ;
                   REPL ("-", npd) + cDiv + ;
                   REPL ("-", npd) + cDiv + REPL ("-", npd) + cDiv
    nR ++
    @ nR,m_y+2 SAY " ³ UK.³ "
    @ nR,col() SAY nTSta pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY nTRev pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY nTRez pict picdem
    @ nR,col() SAY cDiv
    @ nR,col() SAY nTOst pict picdem
    @ nR,col() SAY cDiv

    // ispis dodatnih parametara stanja
 
    IF nLenDP>0
      ++nR
      @ nR, m_y+2 SAY REPL("-",74)
      FOR i:=1 TO nLenDP-1

        cPom777 := aDodPar[i,2]

        IF "TARIFA->" $ UPPER(cPom777)
          SELECT (F_TARIFA)
          IF !USED(); O_TARIFA; ENDIF
          SET ORDER TO TAG "ID"
          HSEEK ROBA->idtarifa
          SELECT ROBA
        ENDIF

        IF i%2!=0
          ++nR
          @ nR, m_y+2 SAY PADL( aDodPar[i,1] , 15 ) COLOR "W+/B"
          @ nR, col()+2 SAY &cPom777 COLOR "R/W"
        ELSE
          @ nR, m_y+37 SAY PADL( aDodPar[i,1] , 15 ) COLOR "W+/B"
          @ nR, col()+2 SAY &cPom777 COLOR "R/W"
        ENDIF

      NEXT
    ENDIF

  inkey(0)
 BoxC()
 
return




function P_FTxt(cId, dx, dy)
local _vrati
local _t_area := SELECT()
local _p_bottom 
local _p_top
local _p_left
local _p_right
local _box_h := MAXROWS() - 20
local _box_w := MAXCOLS() - 3
private ImeKol
private Kol

O_FTXT

ImeKol:={}
Kol := {}

AADD(ImeKol, { PADR("ID",2),   {|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    } )
add_mcode(@ImeKol)
AADD(ImeKol,{ "Naziv",  {|| naz},  "naz" , { || .t. }, ;
		{ || wnaz := strtran( wnaz, "##", hb_eol() ), .t. }, NIL, "@S50" } )

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

_p_bottom := 15
_p_top := 3
_p_left := 1
_p_right := maxcols()-3

Prozor1( _p_top, _p_left, _p_bottom, _p_right, "PREGLED TEKSTA" )

@ _p_bottom, 0 SAY ""

_vrati := PostojiSifra( F_FTXT, 1, _box_h, _box_w, "Faktura - tekst na kraju fakture", @cId , , , {|| PrikFTXT( _p_top, _p_left, 8, _p_right )})

Prozor0()

select ( _t_area )
RETURN _vrati



/*! \fn PrikFTxt()
 *  \brief Prikazuje uzorak teksta
 */
 
function PrikFTxt( top_pos, left_pos, bott_pos, text_length )
local _i := 0
local _arr := {}

@ top_pos, 6 SAY "uzorak teksta id: " + field->id

_arr := TXTuNIZ( field->naz , text_length - 1 - left_pos )
 
FOR _i := 1 TO bott_pos
    IF _i > LEN( _arr )
        @ top_pos + _i, left_pos + 1 SAY SPACE( text_length - 1 - left_pos )
    ELSE
        @ top_pos + _i, left_pos + 1 SAY PADR( _arr[_i], text_length - 1 - left_pos )
    ENDIF
NEXT

return -1


/*! \fn fn ObSif()
 *  \brief
 */
 
static function ObSif()

IF glDistrib
   O_RELAC
   O_VOZILA
   O_KALPOS
ENDIF

O_SIFK
O_SIFV
O_KONTO
O_PARTN
O_ROBA
O_FTXT
O_TARIFA
O_VALUTE
O_RJ
O_SAST
O_UGOV
O_RUGOV

IF RUGOV->(FIELDPOS("DEST"))<>0
	O_DEST
ENDIF

IF gNW=="T"
	O_FADO
   	O_FADE
ENDIF

O_VRSTEP
O_OPS

return



/*! \fn ima_u_fakt_kumulativ(cKljuc,cTag)
 *  \brief
 *  \param cKljuc
 *  \param cTag
 */
 
function ima_u_fakt_kumulativ(cKljuc,cTag)

LOCAL lVrati:=.f., lUsed:=.t., nArr:=SELECT()
SELECT (F_FAKT)
  
IF !USED()
    lUsed:=.f.
    O_FAKT
ELSE
    PushWA()
ENDIF
  
IF !EMPTY(INDEXKEY(VAL(cTag)+1))
    SET ORDER TO TAG (cTag)
    seek cKljuc
    lVrati:=found()
ENDIF

IF !lUsed
    USE
ELSE
    PopWA()
ENDIF
select (nArr)
RETURN lVrati




/*! \fn OsvjeziIdJ()
 *  \brief Osvjezavanje fakta javnim siframa
 */
 
function OsvjeziIdJ()

if Pitanje(,"Osvjeziti FAKT javnim siframa ....","N")=="D"
O_FAKT
O_ROBA ; set order to tag "ID"
O_SIFK
O_SIFV
select fakt
set order to
go top
MsgO("Osvjezavam promjene sifarskog sistema u prometu ...")
nCount:=0
do while !eof()
  select roba
  hseek fakt->idroba
  if fakt->idroba_J <> roba->id_j
    select fakt
    replace IdRoba_J with roba->ID_J
  endif
  select fakt
  @ m_x+3,m_y+3 SAY str(++ncount,3)
  skip
enddo
MsgC()


if pitanje(,"Postaviti javne sifre za id_j prazno ?","N")=="D"
  select roba ; set order to
  go top
  do while !eof()
    if empty(id_j)
       replace id_j with id
    endif
    skip
  enddo
endif
endif

return

/*! \fn SMark(cNazPolja)
 *  \brief Vraca samo markiranu robu
 *  \param cNazPolja - ime polja koje sadrzi internu sifru artikla koji se trazi */
 
function SMark(cNazPolja)

// izbor prodajnog mjesta
function P_IDPM(cId,cIdPartner)

LOCAL lVrati:=.f.
local nArr:=SELECT()
local aNaz:={}

  SELECT SIFV
  SET ORDER TO TAG "ID"

  HSEEK "PARTN   "+"PRMJ"+PADR(cIdPartner,15)
  DO WHILE !EOF() .and.;
           id+oznaka+idsif=="PARTN   "+"PRMJ"+PADR(cIdPartner,15)
    IF !EMPTY(naz)
      AADD( aNaz , PADR( naz , LEN(cId) ) )
    ENDIF
    SKIP 1
  ENDDO
  IF LEN(aNaz)>0
    nPom := ASCAN( aNaz , {|x| x=TRIM(cId)} )
    IF nPom<1; nPom:=1; ENDIF
    Box(,LEN(aNaz)+4,18)
       @ m_x+1, m_y+2 SAY "POSTOJECA PRODAJNA"
       @ m_x+2, m_y+2 SAY "      MJESTA      "
       @ m_x+3, m_y+2 SAY "------------------"
#ifndef TEST
     CLEAR TYPEAHEAD
#endif
     nPom := Menu2(m_x+3,m_y+3,aNaz,nPom)
    BoxC()
    IF nPom>0
      lVrati:=.t.
      cId := aNaz[nPom]
    ENDIF
  ELSE
    lVrati:=.t.
    cId := SPACE(LEN(cId))
  ENDIF
  SELECT (nArr)
RETURN lVrati



/*! \fn IzborRelacije(cIdRelac,cIdDist,cIdVozila,dDatum,cMarsuta)
 *  \brief Izbor relacije
 *  \param cIdRelac    - id relacije
 *  \param cIdDist     - id distribucije
 *  \param cIdVozila   - id vozila
 *  \param dDatum
 *  \param cMarsuta    - marsuta
 */
 
function IzborRelacije(cIdRelac,cIdDist,cIdVozila,dDatum,cMarsruta)

LOCAL lVrati:=.t., aMogRel:={}, nArr:=SELECT(), aIzb:={}
 IF cIdRelac=="NN  "
   cIdDist   := SPACE(LEN(cIdDist  ))
   cIdVozila := SPACE(LEN(cIdVozila))
   cMarsruta := SPACE(LEN(cMarsruta))
   RETURN .t.
 ENDIF
 SELECT KALPOS; SET ORDER TO TAG "2"
 SELECT RELAC; SET ORDER TO TAG "1"
 GO TOP
 HSEEK _idpartner+_idpm
 DO WHILE !EOF() .and. idpartner+idpm==_idpartner+_idpm
   SELECT KALPOS
   SEEK RELAC->id+DTOS(dDatum)
   DO WHILE !EOF() .and. idrelac==RELAC->id .and. DTOS(datum)>=DTOS(dDatum)
     AADD( aMogRel , {DTOC(datum)+"³"+idrelac+"³"+iddist+"³"+idvozila,;
                      idrelac,iddist,idvozila,datum,RELAC->naz} )
     SKIP 1
   ENDDO
   SELECT RELAC
   SKIP 1
 ENDDO
 IF LEN(aMogRel)>0
   ASORT(aMogRel,,,{|x,y| DTOS(x[5])+x[2]<DTOS(y[5])+y[2]})
   AEVAL(aMogRel,{|x| AADD(aIzb,x[1])})
   nPom := ASCAN( aMogRel, {|x| x[2]+x[3]+x[4]+DTOS(x[5])==;
                                cidrelac+ciddist+cidvozila+DTOS(ddatum)} )
   Box(,LEN(aIzb)+4,28)
      @ m_x+1, m_y+2 SAY "SLIJEDECE RELACIJE  "
      @ m_x+2, m_y+2 SAY "PO KALENDARU POSJETA"
      @ m_x+3, m_y+2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
    nPom:=Menu2(m_x+3,m_y+3,aIzb,nPom)
   BoxC()
   IF nPom>0
     cIdRelac  := aMogRel[nPom,2]
     cIdDist   := aMogRel[nPom,3]
     cIdVozila := aMogRel[nPom,4]
     dDatum    := aMogRel[nPom,5]
     cMarsruta := aMogRel[nPom,6]
   ELSE
     lVrati:=.f.
   ENDIF
 ELSE
   MsgBeep("Za zadanog kupca i datum ne postoji planirana relacija u kalendaru posjeta!#"+;
           "Ukoliko se radi npr. o skladiçnoj prodaji, kucajte NN u relaciju!")
   lVrati:=.f.
 ENDIF
 SELECT (nArr)
RETURN lVrati



