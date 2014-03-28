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

elseif upper(Chr(Ch))=="O"
    if roba->(fieldpos("strings")) == 0
  	    return 6
    endif
    TB:Stabilize()
    PushWa()
    m_strings(roba->strings, roba->id)
    select roba
    PopWa()
    return 7

elseif upper(CHR(ch)) == "P"
    
    if gen_all_plu()
        return DE_REFRESH
    endif

elseif Ch==K_ALT_M

    if pitanje(,"Formirati MPC na osnovu VPC ? (D/N)","N")=="D"
        
        private GetList:={}
        private nZaokNa:=1
        private cMPC:=" "
        private cVPC:=" "
        
        Scatter()
        
        select tarifa
        hseek _idtarifa
        select roba

        Box(,4,70)
            @ m_x+2, m_y+2 SAY "Set cijena VPC ( /2)  :" GET cVPC VALID cVPC$" 2"
            @ m_x+3, m_y+2 SAY "Set cijena MPC ( /2/3):" GET cMPC VALID cMPC$" 23"
            READ
            IF EMPTY(cVPC); cVPC:=""; ENDIF
            IF EMPTY(cMPC); cMPC:=""; ENDIF
        BoxC()

        Box(,6,70)
            @ m_X+1, m_y+2 SAY trim(roba->id)+"-"+trim(LEFT(roba->naz,40))
            @ m_X+2, m_y+2 SAY "TARIFA"
            @ m_X+2, col()+2 SAY _idtarifa
            @ m_X+3, m_y+2 SAY "VPC"+cVPC
            @ m_X+3, col()+1 SAY _VPC&cVPC pict picdem
            @ m_X+4, m_y+2 SAY "Postojeca MPC"+cMPC
            @ m_X+4, col()+1 SAY roba->MPC&cMPC pict picdem
            @ m_X+5, m_y+2 SAY "Zaokruziti cijenu na (broj decimala):" GET nZaokNa VALID {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict "9"
            @ m_X+6, m_y+2 SAY "MPC"+cMPC GET _MPC&cMPC WHEN {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict picdem
            read
        BoxC()
        if lastkey()<>K_ESC
            Gather()
            IF Pitanje(,"Zelite li isto uraditi za sve artikle kod kojih je MPC"+cMPC+"=0 ? (D/N)","N")=="D"
                nRecAM:=RECNO()
                Postotak(1,RECCOUNT2(),"Formiranje cijena")
                nStigaoDo:=0
                GO TOP
                DO WHILE !EOF()
                    IF ROBA->MPC&cMPC == 0
                        Scatter()
                        select tarifa; hseek _idtarifa; select roba
                        _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa)
                        Gather()
                    ENDIF
                    Postotak(2,++nStigaoDo)
                    SKIP 1
                ENDDO
                Postotak(0)
                GO (nRecAM)
            ENDIF
            return DE_REFRESH
        endif
    elseif pitanje(,"Formirati VPC na osnovu MPC ? (D/N)","N")=="D"
        private GetList:={}, nZaokNa:=1, cMPC:=" ", cVPC:=" "
        Scatter()
        select tarifa; hseek _idtarifa; select roba

        Box(,4,70)
            @ m_x+2, m_y+2 SAY "Set cijena VPC ( /2)  :" GET cVPC VALID cVPC$" 2"
            @ m_x+3, m_y+2 SAY "Set cijena MPC ( /2/3):" GET cMPC VALID cMPC$" 23"
            READ
            IF EMPTY(cVPC); cVPC:=""; ENDIF
            IF EMPTY(cMPC); cMPC:=""; ENDIF
        BoxC()

        Box(,6,70)
            @ m_X+1, m_y+2 SAY trim(roba->id)+"-"+trim(LEFT(roba->naz,40))
            @ m_X+2, m_y+2 SAY "TARIFA"
            @ m_X+2, col()+2 SAY _idtarifa
            @ m_X+3, m_y+2 SAY "MPC"+cMPC
            @ m_X+3, col()+1 SAY _MPC&cMPC pict picdem
            @ m_X+4, m_y+2 SAY "Postojeca VPC"+cVPC
            @ m_X+4, col()+1 SAY roba->VPC&cVPC pict picdem
            @ m_X+5, m_y+2 SAY "Zaokruziti cijenu na (broj decimala):" GET nZaokNa VALID {|| _VPC&cVPC:=round(_MPC&cMPC / ((1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100)),nZaokNa),.t.} pict "9"
            @ m_X+6, m_y+2 SAY "VPC"+cVPC GET _VPC&cVPC WHEN {|| _VPC&cVPC:=round(_MPC&cMPC / ((1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100)),nZaokNa),.t.} pict picdem
            read
        BoxC()

        if lastkey()<>K_ESC
            Gather()
            IF Pitanje(,"Zelite li isto uraditi za sve artikle kod kojih je VPC"+cVPC+"=0 ? (D/N)","N")=="D"
                nRecAM:=RECNO()
                Postotak(1,RECCOUNT2(),"Formiranje cijena")
                nStigaoDo:=0
                GO TOP
                DO WHILE !EOF()
                    IF ROBA->VPC&cVPC == 0
                        Scatter()
                        select tarifa; hseek _idtarifa; select roba
                        _VPC&cVPC:=round(_MPC&cMPC / ((1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100)),nZaokNa)
                        Gather()
                    ENDIF
                    Postotak(2,++nStigaoDo)
                    SKIP 1
                ENDDO
                Postotak(0)
                GO (nRecAM)
            ENDIF
            return DE_REFRESH
        endif
    endif
    return DE_CONT

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





/*! \fn P_DefDok(cId,dx,dy)
 *  \brief Otvara sifranik definicije dokumenata 
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_DefDok(cId,dx,dy)

Private ImeKol:={}
Private Kol:={}
AADD (ImeKol,{ "Sifra/ID" , {|| id}       ,"id"       , {|| .t.},  {|| vpsifra(wid) }  } )
AADD (ImeKol,{ "Opis"   , {|| naz},      "Naz"                                       } )

Kol:={}
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

return PostojiSifra(F_FADO,1,10,60,"Lista dokumenata u FAKT <F5> - definisi izgled dokumenta",@cId,dx,dy,{|Ch| DefDokBlok(Ch)})



/*! \fn DefDokBlok(Ch)
 *  \brief Obradjuje dogadjaje za pritisnuti taster Ch
 *  \param Ch  - pritisnuti taster (npr. CTRL+T)
 */
 
function DefDokBlok(Ch)

if Ch==K_CTRL_T
 if Pitanje(,"Izbrisati dokument i definiciju izgleda dokumenta ?","N")=="D"
   if Pitanje(,"Jeste li sigurni?","N")=="D"
    cId:=id
    select fade
    seek cid
    do while !eof() .and. cid==id
       skip; nTrec:=recno(); skip -1
       delete
       go nTrec
    enddo
    select fado
    delete
    return 7  // prekini zavrsi i refresh
   endif
 endif

elseif Ch==K_F2
 if Pitanje(,"Promjena broja dokumenta ?","N")=="D"
     cIdOld:=id
     cId:=Id
     Box(,2,50)
      @ m_x+1, m_y+2 SAY "Novi broj dokumenta" GET cID  valid !empty(cid) .and. cid<>cidold
      read
     BoxC()
     if lastkey()==K_ESC; return DE_CONT; endif
     select fade
     seek cidOld
     do while !eof() .and. cidold==id
       skip; nTrec:=recno(); skip -1
       replace id with cid
       go nTrec
     enddo
     select fado
     replace id with cid

 endif
 return DE_CONT

elseif Ch==K_F5
 V_DefDok(fado->id)
 return 6 // DE_CONT2
else
  return DE_CONT
endif
return DE_CONT



/*! \fn V_DefDok()
 *  \brief
 *  \param cId  - Id ugovora
 */
 
function V_DefDok()

parameters cId
private GetList:={}
private ImeKol:={}
private Kol:={}

Box(,15,75)
select fade
ImeKol:={}
AADD(ImeKol,{ "ID      ",     {|| ID      }  })
AADD(ImeKol,{ "SEKCIJA ",     {|| SEKCIJA }  })
AADD(ImeKol,{ "KX      ",     {|| KX      }  })
AADD(ImeKol,{ "KY      ",     {|| KY      }  })
AADD(ImeKol,{ "TIPSLOVA",     {|| TIPSLOVA}  })
AADD(ImeKol,{ "FORMULA ",     {|| FORMULA }  })
AADD(ImeKol,{ "OPIS    ",     {|| OPIS    }  })
AADD(ImeKol,{ "TIPKOL  ",     {|| TIPKOL  }  })
AADD(ImeKol,{ "SIRKOL  ",     {|| SIRKOL  }  })
AADD(ImeKol,{ "SIRDEC  ",     {|| SIRDEC  }  })
AADD(ImeKol,{ "SUMIRATI",     {|| SUMIRATI}  })
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on
@ m_x+1,m_y+1 SAY ""; ?? "Dokument:",fado->id,fado->naz
BrowseKey(m_x+3,m_y+1,m_x+14,m_y+75,ImeKol,{|Ch| EdDefDok(Ch)},"id+brisano=='"+cid+" '",cid,2,,,{|| .f.})

select fado
BoxC()
return .t.



/*! \fn EdDefDok(Ch)
 *  \brief
 *  \param Ch - Pritisnuti taster
 */
 
function EdDefDok(Ch)

local  fK1:=.f.
local GetList:={}

local nRet:=DE_CONT
do case

  case Ch==K_F2  .or. Ch==K_CTRL_N

     sID       := FADO->id
     sSEKCIJA  := SEKCIJA
     sFORMULA  := FORMULA
     sOPIS     := OPIS
     IF Ch==K_CTRL_N
       sKX       := BLANK(KX)
       sKY       := BLANK(KY)
       sTIPSLOVA := BLANK(TIPSLOVA)
       sTIPKOL   := "C "
       sSIRKOL   := BLANK(SIRKOL)
       sSIRDEC   := BLANK(SIRDEC)
       sSUMIRATI := "N"
     ELSE
       sKX       := KX
       sKY       := KY
       sTIPSLOVA := TIPSLOVA
       sTIPKOL   := TIPKOL
       sSIRKOL   := SIRKOL
       sSIRDEC   := SIRDEC
       sSUMIRATI := SUMIRATI
     ENDIF

     Box(,12,75,.f.)
//       @ m_x+1,m_y+2 SAY "ID dokumenta     " GET sID       PICT "@!"
       @ m_x+ 2,m_y+2 SAY "Sekcija(A/B/C/D) " GET sSEKCIJA  PICT "@!" VALID sSekcija$"ABCD"
       @ m_x+ 3,m_y+2 SAY "Koordinata reda  " GET sKX       WHEN sSekcija$"BD" PICT "999"
       @ m_x+ 4,m_y+2 SAY "Koordinata kolone" GET sKY       WHEN sSekcija$"BCD" PICT "999"
       @ m_x+ 5,m_y+2 SAY "Izgled slova(BUI)" GET sTIPSLOVA WHEN sSekcija$"BD" PICT "@!"
       @ m_x+ 6,m_y+2 SAY "Formula          " GET sFORMULA
       @ m_x+ 7,m_y+2 SAY "Opis podatka     " GET sOPIS
       @ m_x+ 8,m_y+2 SAY "Tip (N /C /D /P )" GET sTIPKOL   WHEN sSekcija=="C" VALID sTipKol $ "N #C #N-#D #P " PICT "@!"
       @ m_x+ 9,m_y+2 SAY "Sirina kolone    " GET sSIRKOL   WHEN sSekcija=="C" PICT "999"
       @ m_x+10,m_y+2 SAY "Sirina decimala  " GET sSIRDEC   WHEN sSekcija=="C".and.sTipKol!="C " PICT "999"
       @ m_x+11,m_y+2 SAY "Sumirati (D/N)   " GET sSUMIRATI WHEN sSekcija=="C" PICT "@!" VALID sSumirati$"DN"
       read
     BoxC()
     if Ch==K_CTRL_N .and. lastkey()<>K_ESC
        append blank
        replace id with sid
     endif
     if lastkey()<>K_ESC
       replace SEKCIJA  WITH sSEKCIJA ,;
               KX       WITH sKX      ,;
               KY       WITH sKY      ,;
               TIPSLOVA WITH sTIPSLOVA,;
               FORMULA  WITH sFORMULA ,;
               OPIS     WITH sOPIS    ,;
               TIPKOL   WITH sTIPKOL  ,;
               SIRKOL   WITH sSIRKOL  ,;
               SIRDEC   WITH sSIRDEC  ,;
               SUMIRATI WITH sSUMIRATI
     endif
     nRet:=DE_REFRESH
  case Ch==K_CTRL_T
     if Pitanje(,"Izbrisati stavku ?","N")=="D"
        delete
     endif
     nRet:=DE_DEL

endcase
return nRet


/*! \fn ZipsTemp()
 *  \brief Generisanje ugovora na osnovu telefon fax
 */
 
function ZipsTemp()

PRIVATE DFTkolicina:=1, DFTidroba:=PADR("ZIPS",10)
PRIVATE DFTvrsta  :="1", DFTidtipdok :="20", DFTdindem   := gOznVal
PRIVATE DFTidtxt  :="10", DFTzaokr    :=2, DFTiddodtxt :="  "


DFTParUg(.t.)


select partn
go top

do while !eof()

select partn
if numtoken(telefon) <> numtoken(fax)
  MsgBeep("Sifra :"+id+" telefon<>fax  ???")
  skip ; loop
endif

nTokens:=numtoken(telefon)
if nTokens=0
   skip; loop
endif

select ugov
set order to tag PARTNER

seek partn->id
if found() // neki ugovor za partnera postoji, ne diraj !!!
  select partn
  skip ;  loop
endif


SELECT UGOV; set order to tag "ID"

nRecUg:=RECNO()
GO BOTTOM; SKIP 1; Scatter("w")

waktivan:="D"
wdatod:=DATE()
wdatdo:=CTOD("31.12.2059")
wdindem   := DFTdindem
widtipdok := DFTidtipdok
wzaokr    := DFTzaokr
wvrsta    := DFTvrsta
widtxt    := DFTidtxt
widdodtxt := DFTiddodtxt

SKIP -1
wid:=IF( EMPTY(id) , PADL("1",LEN(id),"0") ,;
           PADR(NovaSifra(TRIM(id)),LEN(ID)) )

wIdPartner:=partn->id

? partn->id, partn->naz

append blank
Gather("w")

SELECT RUGOV;  SET FILTER TO
// dodaj stavke robe

for i:=1 to nTokens
  append blank
  replace id with wId, kolicina with val(token(partn->telefon,i)),;
                      idroba with alltrim(token(partn->fax,i))
next


select partn
skip
enddo

MsgBeep("Kraj...")
return



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



