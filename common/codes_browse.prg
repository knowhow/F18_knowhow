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


#include "fmk.ch"

#include "dbstruct.ch"

// static integer
static __PSIF_NIVO__:=0
// ;

static _LOG_PROMJENE := .f.

// static array __A_SIFV__;
#ifndef CPP
static __A_SIFV__:= { {NIL,NIL,NIL}, {NIL,NIL,NIL}, {NIL,NIL,NIL}, {NIL,NIL,NIL}}
#endif

function PostojiSifra( nDbf, nNtx, nVisina, nSirina, cNaslov, cID, dx, dy, ;
                      bBlok, aPoredak, bPodvuci, aZabrane, fInvert, aZabIsp )

local cRet, cIdBK
local i
private cNazSrch
private cUslovSrch
private fPoNaz:=.f.  // trazenje je po nazivu
private fID_J := .f.

if aZabIsp == nil
	aZabIsp := {}
endif

FOR i:=1 TO LEN(aZabIsp)
	aZabIsp[i] := UPPER(aZabIsp[i])
NEXT

// provjeri da li treba logirati promjene
if Logirati("FMK","SIF","PROMJENE")
	_LOG_PROMJENE := .t.	
endif

private nOrdId
private fBosanski:=.f.

// setuj match_code polje...
set_mc_imekol(nDbf)

PushWa()
PushSifV()

if finvert=NIL
 finvert:=.t.
endif

select (nDbf)

if !used()
   my_use(nDbf)
endif

nOrderSif:=indexord() 
nOrdId := ORDNUMBER("ID")

// POSTAVLJANJE ORDERA...
if valtype(nNTX)="N"
  
  if nNTX==1
    
    if nordid<>0
     set order to tag "ID"
    else
     set order to tag "1"
    endif

  else
    
    if nordid<>0
     if OrdNumber("NAZ_B")<>0
        set order to tag "NAZ_B"
        fBosanski:=.t.
     else
        set order to tag "NAZ"
        fbosanski:=.f.
     endif
    else
     set order to tag "2"
    endif
  endif
  
elseif valtype(nNTX)="C" .and. right(upper(trim(nNTX)),2)="_J"
// postavi order na ID_J

  set order to tag (nNTX)
  fID_J:=.t.

else

  // IDX varijanta:  TAG_IMEIDXA
  nPos:=AT("_",nNTX)
  if nPos<>0
   if empty(left(nNtx,nPos-1))
     dbsetindex(substr(nNTX,nPos+1))
   else
     set order to tag (left(nNtx,nPos-1)) IN (substr(nNTX,nPos+1))
   endif
  else
   set order to tag (nNtx)
  endif
endif

private cUslovSrch:=""
IF cId <>NIL  
 // IZVRSI SEEK
 
 if VALTYPE(cid)=="N"
	
	seek STR(cId)
	
 elseif right(trim(cid),1)=="*"

   if  fieldpos("KATBR")<>0 // trazi po kataloskom broju
     // SEEK KATBR
     set order to tag "KATBR"
     seek LEFT(cId, len(trim(cid))-1)
     cId:=id
   else
     seek "àáâ"
   endif

   if !FOUND()
     // trazi iz sifranika karakteristika
     cIdBK:=left(cid,len(trim(cid))-1)
     cId:=""
     ImauSifV("ROBA","KATB", cIdBK, @cId)
     if !empty(cID)
       select roba
       set order to tag "ID"
       seek cId  // nasao sam sifru !!
       cId:=Id
       if fid_j
          cId:=ID_J
	  set order to tag "ID_J"
	  seek cId
       endif

     endif
   endif

 elseif right(trim(cid),1) $ "./"
 // POSTAVI FILTER SA "/"

   if nordid<>0
    if OrdNumber("NAZ_B")<>0
       set order to tag "NAZ_B"
       fBosanski:=.t.
    else
       set order to tag "NAZ"
       fbosanski:=.f.
    endif
   else
    set order to tag "2"
   endif
   fPoNaz:=.t.
   cNazSrch:=""
   cUslovSrch:=""
   if left(trim(cid),1)=="/"
     private GetList:={}
     Box(,1,60)
       cUslovSrch:=space(120)
       Beep(1)
       @ m_x+1,m_y+2 SAY "Zelim pronaci:" GET cUslovSrch pict "@!S40"
       read
       cUslovSrch:=trim(cUslovSrch)
       if right(cUslovSrch,1)=="*"
          cUslovSrch:=left( cUslovSrch , len(cUslovSrch)-1 )
       endif

     BoxC()

  elseif left(TRIM(cid), 1)=="."
     // SEEK PO NAZ kada se unese DUGACKI DIO
     Box(,1,60)
       cNazSrch:=space(len(naz))
       Beep(1)
       private GetList:={}
       @ m_x+1,m_y+2 SAY "Unesi naziv:" GET cNazSrch PICTURE "@!S40"
       read
     BoxC()
      seek trim(cNazSrch)
     cId:=Id
   else
     seek left(cid, len(trim(cid))-1)
   endif

 elseif len(trim(cId))>10 .and. fieldpos("BARKOD")<>0 
	
	SeekBarKod(@cId,@cIdBk,.f.)

 else
 
   // SEEK PO ID , SEEK PO ID_J
   seek cID
   
   cId := &(FIELDNAME(1))
   
   // pretrazi po barkod-u
   if !found() .and. fieldpos("barkod")<>0
	SeekBarKod( @cId, @cIdBk, .t. )
   endif
   
 endif
 
ENDIF


if dx<>NIL .and. dx<0
// u slucaju negativne vrijednosti vraca se vrijednost polja
// koje je na poziciji ABS(i)
      if !found()
        go bottom
        skip  // id na eof, tamo su prazne vrijednosti
        cRet:=&(FIELDNAME(-dx))
        skip -1
      else
        cRet:=&(FIELDNAME(-dx))
      endif
      PopSifV()
      PopWa()
      return cRet
endif

if !empty(cUslovSrch)
  // postavi filter u sifrarniku
  SetSifFilt(cUslovSrch)  
endif

if (fPonaz .and. (cNazSrch=="" .or. !trim(cNazSrch)==trim(naz))) .or.;
   (!found() .and. cNaslov<>NIL)  .or.;
   cId==NIL .or. ;
   (cNaslov<>NIL .and. left(cNaslov,1)="#")  // if cID== nil - pregled sifrarnika

  lPrviPoziv:=.t.
  if eof() //.and. !bof()
   skip -1
  endif
  if cId==NIL // idemo bez parametara
   go top
  endif

   ObjDbedit(, nVisina,nSirina, ;
       {|| EdSif(nDbf, cNaslov, bBlok, aZabrane, aZabIsp)}, ;
       cNaslov, "", finvert,;
       {"<c-N> Novi","<F2>  Ispravka","<ENT> Odabir","<c-T> Brisi",;
        "<c-P> Print","<F4>  Dupliciraj","<c-F9> Brisi SVE",;
        "<c-F> Trazi","<a-S> Popuni kol.","<a-R> Zamjena vrij.",;
        "<c-A> Cirk.ispravka"}, ;
	1, bPodvuci, , , aPoredak)

   IF TYPE("id") $ "U#UE"       
     cID:=(nDbf)->(FIELDGET(1))
   ELSE
     cID:=(nDbf)->id
     if fID_J
       __A_SIFV__[__PSIF_NIVO__,1]:=(nDBF)->ID_J
     endif
   ENDIF
else
// nisam ni ulazio u objdb
  if fID_J
      cId:=(nDBF)->id
      __A_SIFV__[__PSIF_NIVO__,1]:= (nDBF)->ID_J
  endif
endif

__A_SIFV__[__PSIF_NIVO__,2]:= recno()

if dx<>NIL .and. dy<>nil
	if (nDbf)->(fieldpos("naz")) <> 0
		@ m_x+dx,m_y+dy SAY PADR(TRIM((nDbf)->naz), 70-dy)
	endif
	if (nDbf)->(fieldpos("naziv")) <> 0
		@ m_x+dx,m_y+dy SAY PADR(TRIM((nDbf)->naziv), 70-dy)
	endif
elseif dx<>NIL .and. dx>0 .and. dx<25
	if (nDbf)->(fieldpos("naz")) <> 0
  		CentrTxt(trim((nDbf)->naz),dx)
	endif
	if (nDbf)->(fieldpos("naziv")) <> 0
  		CentrTxt(trim((nDbf)->naziv),dx)
	endif
endif


select (nDbf)

//vrati order sifranika !!
ordsetfocus(nOrderSif)    

set filter to
PopSifV()
PopWa()
return .t.

// --------------------------
// --------------------------
function ID_J(nOffSet)

if nOffset=NIL
 nOffset:=1
endif
if __PSIF_NIVO__ + nOffset > 0
  return __A_SIFV__[__PSIF_NIVO__+nOffset,1]
else
  return __A_SIFV__[1,1]
endif
return

// -------------------------------------------
// setuje match_code imekol {}
// -------------------------------------------
function set_mc_imekol(nDBF)
local nSeek
local bPom

cFldId := "ID"
cFldMatchCode := "MATCH_CODE"

// ako nema polja match code ... nista...
if (nDBF)->(fieldpos(cFldMatchCode)) == 0
	return
endif

nSeek := ASCAN(ImeKol, {|xEditFieldNaz| UPPER(xEditFieldNaz[3]) == "ID" })
//cFldId := ImeKol[nSeek, 3]

// setuj prikaz polja
if nSeek > 0

	bPom := { || ;
		PADR( ALLTRIM(&cFldID) + ;
		IF( !EMPTY(&cFldMatchCode), ;
			IF( LEN(ALLTRIM(&cFldMatchCode)) > 4 , ;
			   "/" + LEFT(ALLTRIM(&cFldMatchCode), 2) + "..", ;
			   "/" + LEFT(ALLTRIM(&cFldMatchCode), 4)), ;
		""), ;
		LEN(&cFldID) + 5 ) ;
		}
	
	ImeKol[nSeek, 1] := "ID/MC"
	ImeKol[nSeek, 2] := bPom
	
	
endif

return

// ----------------------------------
// ----------------------------------
function SIF_TEKREC(cDBF, nOffset)

local xVal
local nArr
if nOffset=NIL
 nOffset:=1
endif
if __PSIF_NIVO__ + nOffset > 0
 xVal:= __A_SIFV__[__PSIF_NIVO__+nOffset,2]
else
 xVal:= __A_SIFV__[1,2]
endif

if cDBF<>NIL
    nArr:=select()
    select (cDBF)
      go xVal
    select (nArr)
endif
return xVal

// ---------------------------------------------------
// ---------------------------------------------------
function PushSifV()
__PSIF_NIVO__ ++
if __PSIF_NIVO__ > len(__A_SIFV__)
  AADD(__A_SIFV__,{"",0,0})
endif
return

// ------------------------------
// ------------------------------
static function PopSifV()

--__PSIF_NIVO__
return

// ------------------------------------------------------------
// -----------------------------------------------------------
static function EdSif(nDbf, cNaslov, bBlok, aZabrane, aZabIsp)

local i
local j
local imin
local imax
local nGet
local nRet 
local nOrder
local nLen
local nRed
local nKolona
local nTekRed
local nTrebaRedova
private cPom
private aQQ
private aUsl
private aStruct
private lNovi

// matrica zabrana
if aZabrane=nil
 aZabrane:={}
endif
 
// matrica zabrana ispravki polja
if aZabIsp=nil
 aZabIsp:={}
endif

Ch:=LASTKEY()

// deklarisi privatne varijable sifrarnika
// wPrivate
aStruct:=DBSTRUCT()
SkratiAZaD (@aStruct)
for i:=1 to LEN(aStruct)
     cImeP := aStruct[i,1]
     cVar := "w" + cImeP
     PRIVATE &cVar := &cImeP
next

nOrder := indexord()
nRet := -1
lZabIsp := .f.

if bBlok<>NIL
  nRet:=Eval(bBlok, Ch)
  if nret > 4
    if nRet == 5
      return DE_ABORT
    elseif nRet == 6
      return DE_CONT
    elseif nRet == 7
      return DE_REFRESH
    elseif nRet == 99 .and. LEN(aZabIsp) > 0
      lZabIsp := .t.
      nRet := -1
    endif
  endif
endif

cSecur:=SecurR(klevel,"Sifrarnici")

if (Ch==K_CTRL_N .and.  !ImaSlovo("AN", cSecur)  )  .or. ;
   (Ch==K_CTRL_A .and.  !ImaSlovo("AI", cSecur)  )  .or. ;
   (Ch==K_F2     .and.  !ImaSlovo("AI", cSecur)  )  .or. ;
   (Ch==K_CTRL_T .and.  !ImaSlovo("AB", cSecur)  )  .or. ;
   (Ch==K_F4     .and.  !ImaSlovo("AI", cSecur)  )  .or. ;
   (Ch==K_CTRL_F9 .and.  !ImaSlovo("A9", cSecur)  ) .or. ;
   ASCAN(azabrane,Ch)<>0  
   MsgBeep("Nivo rada:" + klevel + ":" + cSecur + ": Opcija nedostupna !")
   return DE_CONT
endif

cSecur:=SecurR(klevel,"SGLEDAJ")
if (Ch==K_CTRL_N .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_CTRL_A .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_F2     .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_CTRL_T .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_F4     .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_CTRL_F9 .and. ImaSlovo("D",cSecur)  )
   MsgBeep("Nivo rada:"+klevel+":"+cSecur+": Opcija nedostupna !")
   return DE_CONT
endif

if ((Ch==K_CTRL_N .or.Ch==K_CTRL_A .or. Ch==K_F2 .or. Ch==K_CTRL_T .or. Ch==K_F4 .or. Ch==K_CTRL_F9 .or. Ch==K_F10) .and. !ImaPravoPristupa(goModul:oDatabase:cName,"SIF","EDSIF")) 
	MsgBeep("Vi nemate pravo na promjenu podataka u sifrarnicima !")
	return DE_CONT
endif

do case

  case Ch==K_ENTER
    // ako sam u sifrarniku a ne u unosu dokumenta 
    if gMeniSif 
     return DE_CONT
    else
     // u unosu sam dokumenta
     lPrviPoziv:=.f.
     return DE_ABORT
    endif

  case UPPER(CHR(Ch)) == "F"
    // pretraga po MATCH_CODE
    if m_code_src() == 0
    	return DE_CONT
    else
    	return DE_REFRESH
    endif

  case Ch==ASC("/")

    cUslovSrch:=""
    Box(,1,60)
       cUslovSrch:=space(120)
       @ m_x+1,m_y+2 SAY "Zelim pronaci:" GET cUslovSrch pict "@!S40"
       read
       cUslovSrch:=trim(cUslovSrch)
       if right(cUslovSrch,1)=="*"
          cUslovSrch:=left( cUslovSrch , len(cUslovSrch)-1 )
       endif
    BoxC()

    if !empty(cUslovSrch)
      // postavi filter u sifrarniku
      SetSifFilt(cUslovSrch)  
    else
      set filter to
    endif
    return DE_REFRESH


  case (Ch==K_CTRL_N .or. Ch==K_F2 .or. Ch==K_F4 .or. Ch==K_CTRL_A)

    if EditSifItem(Ch, nOrder, aZabIsp) == 1
      return DE_REFRESH
    endif
    RETURN DE_CONT
    
  case Ch==K_CTRL_P

    PushWa()
    IzborP2(Kol,PRIVPATH + alias())
    if lastkey() == K_ESC
        return DE_CONT
    endif

    Izlaz("Pregled: " + ALLTRIM(cNaslov) + " na dan " + dtoc(date()) + " g.", "sifrarnik" )
    set filter to
    PopWa()

    return DE_CONT

  case Ch==K_ALT_F
     uslovsif()
     return DE_REFRESH

  case Ch==K_CTRL_F6
    Box(,1,30)
      public gIdFilter := eval(ImeKol[TB:ColPos,2])
      @ m_x+1,m_y+2 SAY "Filter :" GET gidfilter
      read
    BoxC()

    if empty(gidfilter)
      set filter to
    else
      set filter to eval(ImeKol[TB:ColPos,2])==gidfilter
      go top
    endif
    return DE_REFRESH

  case Ch==K_CTRL_T
     return sif_brisi_stavku()

  case Ch==K_CTRL_F9
     return sif_brisi_sve()

  case Ch==K_ALT_C
    return SifClipBoard()

  case Ch==K_F10
      SifPopup(nOrder)
      RETURN DE_CONT
  otherwise

     if nRet>-1
       return nRet
     else
       return DE_CONT
     endif

endcase
return

// ------------------------------------------
// ------------------------------------------
function EditSifItem(Ch, nOrder, aZabIsp)
local i
local j
local _jg
local imin
local imax
local nGet
local nRet 
local nLen
local nRed
local nKolona
local nTekRed
local nTrebaRedova
local oTable
local nPrevRecNo
local cMCField
local nMCScan
local _vars

private nXP
private nYP
private cPom
private aQQ
private aUsl
private aStruct

nPrevRecNo:=RECNO()
lNovi:=.f.

if _LOG_PROMJENE == .t.
        // daj stare vrijednosti
	cOldDesc := _g_fld_desc("w")
endif

// dodaj u matricu match_code ako ne postoji
cMCField := ALIAS()
if &cMCField->(fieldpos("MATCH_CODE")) <> 0
	nMCScan := ASCAN(ImeKol, {|xImeKol| UPPER(xImeKol[3]) == "MATCH_CODE"})
	
	// ako ne postoji dodaj ga...
	if nMCScan == 0
		// dodaj polje u ImeKol
		AADD(ImeKol, {"MATCH_CODE", {|| match_code}, "match_code" })
		// dodaj novu stavku u kol
		AADD( Kol, LEN(ImeKol) )
	endif
endif

__A_SIFV__[__PSIF_NIVO__,3]:=  Ch

if Ch==K_CTRL_N .or. Ch==K_F2
    if nordid<>0
        set order to tag "ID"
    else
        set order to tag "1"
    endif
	go (nPrevRecNo)
endif


if Ch==K_CTRL_N
	lNovi:=.t.
	go bottom
	skip 1
endif


if Ch==K_F4
	lNovi:=.t.
endif


do while .t.
   
    // setuj varijable za tekuci slog
    SetSifVars()
   
    nTrebaredova:=LEN(ImeKol)
    for i:=1 to LEN(ImeKol)
      if LEN(ImeKol[i]) >= 10 .and. Imekol[i, 10]<>NIL
         nTrebaRedova--
      endif
    next

    i:=1 
    // tekuci red u matrici imekol
    for _jg := 1 to 3  // glavna petlja
            
            // moguca su  tri get ekrana

            if _jg == 1
               Box(, min( 20, nTrebaRedova) + 1, 67 ,.f.)
            else
               BoxCLS()
            endif

            set cursor on
            Private Getlist:={}


            nGet:=1 // brojac get-ova
            nNestampati:=0  // broj redova koji se ne prikazuju (_?_)

            nTekRed:=1
            do while .t. 
            
                lShowPGroup := .f.
                
                if empty(ImeKol[i,3])  
                   // ovdje se kroji matrica varijabli.......
                   // area->nazpolja
                   cPom:=""  
                else
                    if left(ImeKol[i,3],6) != "SIFK->"

                        cPom:="w"+ImeKol[i,3]    //npr WVPC2
                        // ako provjerimo strukturu, onda mozemo vidjeti da trebamo uzeti
                        // varijablu karakteristike("ROBA","V2")

                     else
                            // ako je SIFK->GRUP, prikazuj status
                            if ALIAS() == "PARTN" .and. RIGHT(ImeKol[i,3],4) == "GRUP"
                                lShowPGroup := .t.
                            endif

                            cPom:= "wSifk_" + substr(ImeKol[i,3], 7)
                            &cPom:= IzSifk(ALIAS(), substr(ImeKol[i,3], 7))
                            if &cPom = NIL  
                                // ne koristi se !!!
                                cPom:=""
                            endif
                     endif
                endif

                cPic:=""
                // samo varijable koje mozes direktno mjenjati
                if !empty(cPom) 

                            // uzmi when, valid kodne blokove
                            if (Ch==K_F2 .and. lZabIsp .and. ASCAN(aZabIsp, UPPER(ImeKol[i,3]))>0)
                                bWhen := {|| .f.}
                            elseif (LEN(ImeKol[i])<4 .or. ImeKol[i,4]==nil)
                                bWhen := {|| .t.}
                            else
                                bWhen:=Imekol[i,4]
                            endif

                            if (len(ImeKol[i])<5 .or. ImeKol[i,5]==nil)
                                bValid := {|| .t.}
                            else
                                bValid:=Imekol[i,5]
                            endif

                            if LEN(ToStr(&cPom))>50
                                cPic:="@S50"
                                @ m_x+nTekRed+1,m_y+67 SAY Chr(16)
                            elseif Len(ImeKol[i])>=7 .and. ImeKol[i,7] <> NIL
                                cPic:= ImeKol[i,7]
                            else
                                cPic:=""
                            endif

                            nRed:=1
                            nKolona:=1
                            if Len(ImeKol[i]) >= 10 .and. imekol[i,10] <> NIL
                                nKolona:= imekol[i,10]+1
                                nRed:=0
                            endif

                            if nKolona=1
                                nTekRed++
                            endif
                            
                            if lShowPGroup
                                nXP := nTekRed
                                nYP := nKolona
                            endif
                            
                            @ m_x + nTekRed , m_y + nKolona SAY iif(nKolona>1,"  "+alltrim(ImeKol[i,1]) , PADL( alltrim(ImeKol[i,1]) ,15))  GET &cPom VALID eval(bValid) PICTURE cPic
                            // stampaj grupu za stavku "GRUP"
                            if lShowPGroup
                                p_gr(&cPom, nXP+1, nYP+1)
                            endif
                        
                            if cPom == "wSifk_"
                                // uzmi when valid iz SIFK
                                private cWhenSifk, cValidSifk
                                IzSifKWV(ALIAS(), substr(cPom,7) ,@cWhenSifk, @cValidSifk)

                                if !empty(cWhenSifk)
                                    Getlist[nGet]:PreBlock:=& ("{|| "+cWhenSifk +"}")
                                else
                                    GetList[nGet]:PreBlock:=bWhen
                                endif
                                if !empty(cValidSifk)
                                    Getlist[nGet]:PostBlock:= & ("{|| "+cValidSifk +"}")
                                else
                                    GetList[nGet]:PostBlock:=bValid
                                endif		  
                            else
                                    GetList[nGet]:PreBlock:=bWhen
                                    GetList[nGet]:PostBlock:=bValid
                            endif

                            nGet++
                else
                        // Empty(cpom)  - samo odstampaj
                        
                        nRed:=1
                        nKolona:=1
                        if Len(ImeKol[i]) >= 10 .and. imekol[i, 10] <> NIL
                            nKolona:= imekol[i,10]
                            nRed:=0
                        endif

                        // ne prikazuj nil vrijednosti
                        if EVAL(ImeKol[i,2]) <> NIL .and. ToStr(EVAL(ImeKol[i,2]))<>"_?_"  
                            if nKolona=1
                            ++nTekRed
                            endif
                            @ m_x+nTekRed, m_y + nKolona SAY PADL( alltrim(ImeKol[i,1]) ,15)
                            @ m_x+nTekRed, col() + 1 SAY EVAL(ImeKol[i,2])
                        else
                            ++nNestampati
                        endif

                endif 
                // empty(cpom)

                i++                               
                // ! sljedeci slog se stampa u istom redu
                if ( len(imeKol) < i) .or. (nTekRed > min(20, nTrebaRedova) .and. !(Len(ImeKol[i] ) >= 10 .and. imekol[i, 10]<>NIL)  )
                    // izadji dosao sam do zadnjeg reda boxa, ili do kraja imekol
                    exit 
                endif
        enddo

        // key handleri F8, F9, F5
        SET KEY K_F8 TO NNSifru()
        SET KEY K_F9 TO n_num_sif()
        SET KEY K_F5 TO NNSifru2()


        READ
        SET KEY K_F8 TO
        SET KEY K_F9 TO
        SET KEY K_F5 TO

        if ( len(imeKol) < i)
            exit
        endif


    next 
    BoxC()


        if Ch<>K_CTRL_A
            exit
        else
        if lastkey()==K_ESC
            exit
        endif

        _vars := f18_scatter_global_vars("w")
        f18_gather(_vars)
            
        //f18_gater radi sav posao GatherR("w")

        // TODO !!! 
        GatherSifk("w" , Ch==K_CTRL_N)

        Scatter("w")

        if lastkey()==K_PGUP
           skip -1
        else
            skip
        endif

        if eof()
            skip -1
            exit
        endif

    endif

enddo
// glavni enddo

if Ch==K_CTRL_N .or. Ch==K_F2
    ordsetfocus(nOrder)
endif

if lastkey()==K_ESC
    if lNovi
        go (nPrevRecNo)
    endif
    return 0
endif

if lNovi
    // provjeri da li vec ovaj id postoji ?
    nNSInfo := _chk_sif("w")

    if nNSInfo = 1  
        msgbeep("Ova sifra vec postoji !")
        return 0
    elseif nNSInfo = -1
        return 0
    endif

    append blank

    if _LOG_PROMJENE == .t. 
        // ako je novi zapis .. ovo su stare vrijednosti (prazno)
        cOldDesc := _g_fld_desc("w")
    endif
endif

_vars := f18_scatter_global_vars("w")
if ! f18_gather(_vars)
    // brisi appendovani zapis
    delete
endif

// TODO !! 
GatherSifk("w", lNovi )

Scatter("w")

if _LOG_PROMJENE == .t.
    // daj nove vrijednosti
    cNewDesc := _g_fld_desc("w") 
endif

nTArea := SELECT()

// logiraj promjenu sifrarnika...
if _LOG_PROMJENE == .t.

    cChanges := _g_fld_changes(cOldDesc, cNewDesc)
    if LEN(cChanges) > 250
        cCh1 := SUBSTR(cChanges, 1, 250)
        cCh2 := SUBSTR(cChanges, 251, LEN(cChanges))
    else
        cCh1 := cChanges
        cCh2 := ""
    endif

        EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
        "promjena na sifri: " + to_str( FIELDGET(1) ), cCh1,cCh2, ;
        DATE(),DATE(), "", ;
        "promjene u tabeli " +  ALIAS() + " : " + ;
        IIF(Ch==K_F2,"ispravka",IF(Ch==K_F4,"dupliciranje", "nova stavka")))
endif

select (nTArea)

if Ch==K_F4 .and. Pitanje( , "Vrati se na predhodni zapis","D")=="D"
    go (nPrevRecNo)
endif
    
return 1


// --------------------------------------------------
// --------------------------------------------------
static function _chk_sif( cMarker )
local cFName
local xFVal
local cFVal
local cType
local nTArea := SELECT()
local nTREC := RECNO()
local nRet := 0
local i := 1
local cArea := ALIAS( nTArea )
private cF_Seek
private GetList := {}

cFName := ALLTRIM( FIELD(i) )
xFVal := FIELDGET(i)
cType := VALTYPE(xFVal)
cF_Seek := &( cMarker + cFName )

if ( cType == "C" ) .and. ( cArea $ "#PARTN##" )
	
	Box(,1,40)
		@ m_x + 1, m_y + 2 SAY "Potvrdi sifru sa ENTER: " GET cF_seek
		read
	BoxC()
	
	if LastKey() == K_ESC
		nRet := -1
		return nRet
	endif
	
	go top
	seek cF_seek
	if FOUND()
		nRet := 1
		go (nTREC)
	endif
endif
	
select (nTArea)
return nRet


// --------------------------------------------------
// vraca naziv polja + vrijednost za tekuci alias
// cMarker = "w" ako je Scatter("w")
// --------------------------------------------------
static function _g_fld_desc( cMarker )
local cRet := ""
local i
local cFName
local xFVal
local cFVal
local cType

for i := 1 to FCOUNT()

	cFName := ALLTRIM( FIELD(i) )
	
	xFVal := FIELDGET(i)
	
	cType := VALTYPE(xFVal)
	
	if cType == "C"
		// string
		cFVal := ALLTRIM(xFVal)
	elseif cType == "N"
		// numeric
		cFVal := ALLTRIM(STR(xFVal, 12, 2))
	elseif cType == "D"
		// date
		cFVal := DTOC(xFVal)
	endif
	
	cRet += cFName + "=" + cFVal + "#"
next

return cRet

// ----------------------------------------------------
// uporedjuje liste promjena na sifri u sifrarniku
// ----------------------------------------------------
static function _g_fld_changes( cOld, cNew )
local cChanges := "nema promjena - samo prolaz sa F2"
local aOld
local aNew
local cTmp := ""

// stara matrica
aOld := TokToNiz(cOld, "#")
// nova matrica
aNew := TokToNiz(cNew, "#")

// kao osnovnu referencu uzmi novu matricu
for i := 1 to LEN( aNew )
	cVOld := ALLTRIM(aOld[i])
	cVNew := ALLTRIM(aNew[i])
	if cVNew == cVOld
		// do nothing....
	else
		cTmp += "nova " + cVNew + " stara " + cVOld + ","
	endif
next

if !EMPTY(cTmp)
	cChanges := cTmp
endif

return cChanges

// -----------------------
// -----------------------
function SetSifVars()
local _i, _struct
private cImeP
private cVar

_struct := DBSTRUCT()

SkratiAZaD(@_struct)

for _i:=1 to LEN(_struct)
     cImeP := _struct[_i, 1]
     cVar:="w" + cImeP
     &cVar := &cImeP

next

return


//-------------------------------------------------------
//-------------------------------------------------------
function SifPopup(nOrder)

private Opc:={}
private opcexe:={}
private Izbor

AADD(Opc, "1. novi                  ")
AADD(opcexe, {|| EditSifItem(K_CTRL_N, nOrder) } )
AADD(Opc, "2. edit  ")
AADD(opcexe, {|| EditSifItem(K_F2, nOrder) } )
AADD(Opc, "3. dupliciraj  ")
AADD(opcexe, {|| EditSifItem(K_F4, nOrder) } )
AADD(Opc, "4. <a+R> za sifk polja  ")
AADD(opcexe, {|| repl_sifk_item() } )
AADD(Opc, "5. copy polje -> sifk polje  ")
AADD(opcexe, {|| copy_to_sifk() } )

Izbor:=1
Menu_Sc("bsif")

return 0

/*!
 @function    NoviID_A
 @abstract    Novi ID - automatski
 @discussion  Za one koji ne pocinju iz pocetak, ID-ovi su dosadasnje sifre
              Program (radi prometnih datoteka) ove sifre ne smije dirati)
              Zato ce se nove sifre davati po kljucu Chr(246)+Chr(246) + sekvencijalni dio
*/
function NoviID_A()

local cPom , xRet

PushWA()

nCount:=1
do while .t.

set filter to 
// pocisti filter
set order to tag "ID"
go bottom
if id>"99"
   seek chr(246)+chr(246)+chr(246) 
   // chr(246) pokusaj
   skip -1
   if id < chr(246) + chr(246) + "9"
      cPom:=   str( val(substr(id,4))+nCount , len(id)-2 )
      xRet:= chr(246)+chr(246) + padl(  cPom , len(id)-2 ,"0")
   endif
else
  cPom:= str( val(id) + nCount , len(id) )
  xRet:= cPom
endif

++nCount
SEEK xRet
if !found()
  exit
endif

if nCount>100
  MsgBeep("Ne mogu da dodijelim sifru automatski ????")
  xRet:=""
  exit
endif

enddo

PopWa()

return xRet



// -------------------------------------------------------------------
// @function   Fill_IDJ
// @abstract   Koristi se za punjenje sifre ID_J sa zadatim stringom
// @discussion fja koja punjeni polje ID_J tako sto ce se uglavnom definisati
//             kao validacioni string u sifrarniku Sifk
//             Primjer:
//             - Zelim da napunim sifru po prinicpu ( GR1 + GR2 + GR3 + sekvencijalni dio)
//             - Zadajem sljedeci kWhenBlok:
//               When: FILL_IDJ( WSIFK_GR1 + WSIFK_GR2 + WSIFK_GR3)
// @param      cStr  zadati string
// --------------------------------------------------------------------
function Fill_IDJ(cSTR)

local nTrec , cPoz

PushWA()


nTrec:=recno()
set order to tag "ID_J"
seek cStr + chr(246)
skip -1
// ova fja se uvijek poziva nakon Edsif-a
// ako je __LAST_CH__=f4 onda se radi o dupliciranju

if (__A_SIFV__[__PSIF_NIVO__,3]==K_F4) .or. ;
   ( recno()<>nTrec .and. ( left(wId_J, len(cStr)) != cStr) ) 
   // ne mjenjam samog sebe
        if  right(alltrim(wNAZ),3)=="..."
           // naziv je u formi "KATEGORIJA ARTIKALA.........."
           cPoz:=  REPLICATE (".",len(ID_J)-LEN(cStr))
        elseif (left( ID_J, len(cStr) ) = cStr ) .and. ( SUBSTR(ID_J , len(cstr)+1,1)<>".")
           // GUMEPODA01
           // Len(id_j) - len( cStr )  = 10 - 8 = 2
           cPoz:=  PADL ( alltrim( STR( VAL (substr( ID_J , len(cstr)+1)) +1)) , len(ID_J) - LEN(cStr), "0" )
        else
           cPoz:=  PADL ( "1" , len(ID_J)-LEN(cStr), "0" )
        endif

        go nTrec
        //replace ID_J with   ( cStr +  cPoz)
        wID_J :=  ( cStr +  cPoz)
endif
PopWa()
return .t.


/*!
 @function   SetSifFilt
 @abstract
 @discussion postavlja _M1_ na "*" za polja kod kojih je cSearch .t.;
             takodje parsira ulaz (npr. RAKO, GSLO 10 20 30, GR1>55, GR2 20 $55#66#77#88 )

 @param
 @param
 @param
 @param
*/
// formiraj filterski uslov
// Ulaz 
function SetSifFilt(cSearch)

local n1,n2,cVarijabla, cTipVar
local fAddNaPost := .f.
local fOrNaPost  := .f.
local nCount, nCount2
private cFilt:=".t. "


cSearch:=ALLTRIM(trim(cSearch))
// zamjenit "NAZ $ MISHEL"  -> NAZ $MISHEL
cSearch:=strtran(cSearch,"$ ","$")

n1:= NumToken(cSearch,",")
for i:=1 to n1
 cUslov:= token(cSearch,",",i)
 n2:=numtoken(cUslov," ")
 if n2 = 1
   if cUslov="+"  // dodaj na postojeci uslov
      fAddNaPost := .t.
   elseif upper(cUslov)="*"  // dodaj na postojeci uslov
      fOrNaPost := .t.
   else
     cFilt += ".and."+;
              iif(fieldpos("ID_J")=0,"Id","ID_J")+"=" + token(cUslov," ",1)
   endif

 elseif n2 >= 2  // npr ....,GSLO 33 55 77,.......

   if  fieldpos( token(cUslov," ",1) ) <> 0  // radi se o polju unutar baze
      cVarijabla:=token(cUslov," ",1)
   else
      // radi se o polju sifk
      cVarijabla:="IzSifk('"+ALIAS()+"','"+ALLTRIM(token(cUslov," ",1))+",####',NIL,.f.,.t.)"
   endif


   cOperator:=NIL
   cFilt += ".and. ("
   for j:=2 to n2  // sada nastiklaj uslove ...
     if left(token(cUslov," ",j),1)=">"
        cOperator:=">"
     elseif left(token(cUslov," ",j),1)="$"
        cOperator:="$"
     elseif left(token(cUslov," ",j),1)="!"
        cOperator:="!"
     elseif left(token(cUslov," ",j),2)="<>"
        cOperator:="<>"
     elseif left(token(cUslov," ",j),1)="<"
        cOperator:="<"
     elseif left(token(cUslov," ",j),2)=">="
        cOperator:=">="
     elseif left(token(cUslov," ",j),2)="<="
        cOperator:="<="
     endif

     if coperator=NIL
      cOperator:="="
      cV2:= substr(token(cUslov," ",j),1)
     else
      //cV2:= substr(token(cUslov," ",j), 1+len(cOperator)) bug 31.10.2000
      if cOperator="="
       cV2:= substr(token(cUslov," ",j), len(cOperator))
      else
       cV2:= substr(token(cUslov," ",j), 1 + len(cOperator))
      endif
     endif
     cV2 := strtran(cV2,"_"," ")  // !!! pretvori "_" u " "


     if cVarijabla = "IzSifk("
       if cOperator="="
        cVarijabla:=strtran(cVarijabla,"####",cV2)
       else
        cVarijabla:=strtran(cVarijabla,",####","")
       endif
     endif

     cTipVar:=  VALTYPE( &cVarijabla )
     if j>2 ;  cFilt += ".or. " ; endif

     if cOperator="$"
         cFilt +=  "'" +cV2 + "'"  + cOperator + cVarijabla
     else

      if cOperator=="!"
        cOperator := "!="
      endif

      if cTipVar = "C"
         cFilt += cVarijabla + cOperator + "'" +cV2 + "'"
      elseif cTipVar = "N"
         cFilt += cVarijabla + cOperator +cV2
      elseif cTipVar = "D"
         cFilt += cVarijabla + "CTOD(" +cOperator +cV2 +")"
      endif
     endif

   next
   cFilt +=")"
 endif
next

if !fAddNaPost
  set filter to
endif
go top
// prodji kroz bazu i markiraj
@ 25,1 SAY cFilt
MsgO("Vrsim odabir zeljenih stavki: ....")
nCount:=0
nCount2:=0
do while !eof()
  sql_azur(.t.);Scatter()
  if empty(cFilt) .or. &cFilt
    replace _M1_ with "*"
    //replsql _M1_ with "*"
    ++nCount2
  else
    if !fOrNaPost
      replace _M1_ with " "
      //replsql _M1_ with " "
    endif
  endif
  ++nCount
  if (nCount%10 = 0)
   @ m_x+6,m_y+40 SAY nCount
  endif
  skip
enddo
Msgc()

@ m_x+1, m_y+20 SAY  str(nCount2,3)+"/"

#IFDEF PROBA
 CLS
 ? ncount, ncount2, cFilt
 DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
 INKEY()
 // inkey(0)
#ENDIF

private cFM1:="_M1_='*'"
SET FILTER TO  &cFM1
go top

return


// prikaz idroba
// nalazim se u tabeli koja sadrzi IDROBA, IDROBA_J
function StIdROBA()

static cPrikIdRoba:=""

if cPrikIdroba == ""
  cPrikIdRoba:=IzFmkIni('SIFROBA','PrikID','ID',SIFPATH)
endif

if cPrikIdRoba="ID_J"
  return IDROBA_J
else
  return IDROBA
endif

function aTacno(aUsl)
local i
for i=1 to len(aUsl)
   if !(Tacno(aUsl[i]))
       return .f.
   endif
next
return .t.


// -----------------------------------------
// nadji sifru, v2 funkcije
// -----------------------------------------
function n_num_sif()
local cFilter := "val(id) <> 0"
local i
local nLId
local lCheck
local lLoop

// ime polja : "wid"
private cImeVar := READVAR()
// vrijednost unjeta u polje
cPom := &(cImeVar)

if cImeVar == "WID"
	
	PushWA()
	
	nDuzSif := LEN( cPom )

	// postavi filter na numericke sifre
	set filter to &cFilter
  	
	// kreiraj indeks
	index on VAL(id) tag "_VAL"
	
	go bottom

	// zapis
	nTRec := RECNO()
	nLast := nTRec

	// sifra kao uzorak
	nLId := VAL( ID )
	lCheck := .f.

	do while lCheck = .f.
	   
	   lLoop := .f.
	   // ispitaj prekid sifri
	   for i := 1 to 10

		skip -1

		if nLId = VAL( field->id )
			// ako je zadnja sifra ista kao i prethodna
			// idi na sljedecu
			// ili idi na zadnju sifru
			nTRec := nLast
			lLoop := .t.
			exit
		endif

		if nLId - VAL( field->id ) <> i
			// ima prekid
			// idi, ponovo...
			nLID := VAL( field->id )
			nTRec := RECNO()
			lCheck := .f.
			lLoop := .f.
			exit
		else
			lLoop := .t.
		endif

	   next

	   if lLoop = .t.
	   	lCheck := .t.
	   endif

	enddo

	go (nTREC)
	
    	&(cImeVar) := PADR(NovaSifra( IF( EMPTY(id) , id , RTRIM(id) ) ), nDuzSif, " " )

	set filter to

	if nOrdId <> 0
   		set order to tag "ID"
  	else
   		set order to tag "1"
  	endif
  	
	GO TOP

endif

AEVAL(GetList,{|o| o:display()})
PopWA()

return nil


// ----------------------------------------------------
// nadji novu sifru - radi na pritisak F8 pri unosu
// nove sifre
// ----------------------------------------------------
function NNSifru()      
local cPom
local nDuzSif:=0
local lPopuni:=.f.
local nDuzUn:=0
local cLast:="¬¦æÑ"
local nKor:=0

IF IzFmkIni("NovaSifraOpc_F8","PopunjavaPraznine","N")=="D"
	lPopuni:=.t.
ENDIF

// ime polja
private cImeVar := READVAR()
// vrijednost unjeta u polje
cPom := &(cImeVar)

IF cImeVar == "WID"
	
	nDuzSif := LEN(cPom)
  	nDuzUn := LEN(TRIM(cPom))
  	cPom := PADR(RTRIM(cPom),nDuzSif,"Z")
  	
	PushWA()
  	
	if nOrdId <> 0
   		set order to tag "ID"
  	else
   		set order to tag "1"
  	endif
  	
	GO TOP
  	IF lPopuni
    		SEEK LEFT(cPom,nDuzUn)
    		DO WHILE !EOF() .and. LEFT(cPom,2)=LEFT(id,2)
      			// preskoci stavke opisa grupe artikala
      			IF LEN(TRIM(id))<=nDuzUn .or. RIGHT(TRIM(id),1)=="."
				SKIP 1
			ENDIF
      			IF cLast=="¬¦æÑ" // tj. prva konkretna u nizu
        			IF VAL(SUBSTR(id,nDuzUn+1)) > 1
          				// rupa odmah na poetku
          				nKor:= nDuzSif-LEN(TRIM(id))
          				EXIT
        			ENDIF
      			ELSEIF VAL(SUBSTR(id,nDuzUn+1))-VAL(cLast) > 1
        			// rupa izmeÐu
        			EXIT
      			ENDIF
      			cLast:=SUBSTR(id,nDuzUn+1)
      			SKIP 1
    		ENDDO
    		// na osnovu cLast formiram slijedeu çifru
    		cPom:=LEFT(cPom,nDuzUn)+IF(cLast=="¬¦æÑ",REPL("0",nDuzSif-nDuzUn-nKor),cLast)
    		&(cImeVar):=PADR(NovaSifra( IF( EMPTY(cPom) , cPom , RTRIM(cPom) ) ),nDuzSif," ")
  	ELSE
    		
		SEEK cPom
    		SKIP -1
    		&(cImeVar):=PADR(NovaSifra( IF( EMPTY(id) , id , RTRIM(id) ) ),nDuzSif," ")
  	
	ENDIF

  	AEVAL(GetList,{|o| o:display()})
	PopWA()
ENDIF

RETURN (NIL)



/*! \fn VpSifra(wId)
 *  \brief Stroga kontrola ID-a sifre pri unosu nove ili ispravci postojece!
 *  \param wId - ID koji se provjerava
 */

function VpSifra(wId)

local nRec:=RecNo()
local nRet:=.t.
local cUpozorenje:=" !!! Ovaj ID vec postoji !!! "
seek wId

if (FOUND() .and. Ch==K_CTRL_N)
	MsgBeep(cUpozorenje)
  	nRet:=.f.
elseif (gSKSif=="D" .and. FOUND())   // nasao na ispravci ili dupliciranju
	if nRec<>RecNo()
		MsgBeep(cUpozorenje)
    		nRet:=.f.
  	else       // bio isti zapis, idi na drugi
    		skip 1
    		if (!EOF() .and. wId==id)
			MsgBeep(cUpozorenje)
      			nRet:=.f.
    		endif
  	endif
endif
go nRec
return nRet




/*! \fn VpNaziv(wNaziv)
 *  \brief Stroga kontrola naziva sifre pri unosu nove ili ispravci postojece sifre
 *  \param wNaziv - Naziv koji se provjerava
 */
 
function VpNaziv(wNaziv)


local nRec:=RecNo()
local nRet:=.t.
local cId
local cUpozorenje:="Ovaj naziv se vec nalazi u sifri:   "

set order to tag "naz"
HSeek wNaziv
cId:=roba->id

if (FOUND() .and. Ch==K_CTRL_N)
	MsgBeep(cUpozorenje + ALLTRIM(cId) + " !!!")
  	nRet:=.f.
elseif (gSKSif=="D" .and. FOUND()) 
	if nRec<>RecNo()
		MsgBeep(cUpozorenje + ALLTRIM(cId) + " !!!")
    		nRet:=.f.
  	else       // bio isti zapis, idi na drugi
    		skip 1
    		if !EOF() .and. wNaziv==naz
			MsgBeep(cUpozorenje + ALLTRIM(cId) + " !!!")
      			nRet:=.f.
    		endif
  	endif
endif

set order to tag "ID"
go nRec

return nRet


// ---------------------------------
// ---------------------------------
function ImaSlovo(cSlova, cString)
local i
for i:=1 to len(cSlova)
 if substr(cSlova,i,1)  $ cString
    return .t.
 endif
next
return .f.

// ------------------------------
// ------------------------------
function UslovSif()
local aStruct:=DBSTRUCT()

SkratiAZaD(@aStruct)

Box("", IF(len(aStruct)>22, 22, LEN(aStruct)), 67, .f. ,"","Postavi kriterije za pretrazivanje")

private Getlist:={}

*
* postavljanje uslova
*
aQQ:={}
aUsl:={}

IF "U" $ TYPE("aDefSpremBaz")
	aDefSpremBaz := NIL
ENDIF

IF aDefSpremBaz != NIL .and. !EMPTY(aDefSpremBaz)
	FOR i:=1 TO LEN(aDefSpremBaz)
    		aDefSpremBaz[i,4]:=""
  	NEXT
ENDIF

set cursor on

for i:=1 to len(aStruct)
	if i==23
   		@ m_x+1,m_y+1 CLEAR TO m_x+22,m_y+67
 	endif
 	AADD(aQQ, SPACE(100))
 	AADD(aUsl, NIL)
 	@ m_x+IF(i>22, i-22, i), m_y+67 SAY Chr(16)
 	@ m_x+IF(i>22,i-22,i),m_y+1 SAY PADL( alltrim(aStruct[i,1]),15) GET aQQ[i] PICTURE "@S50" ;
    		valid {|| aUsl[i]:=Parsiraj(aQQ[i]:=_fix_usl(aQQ[i]),aStruct[i,1],iif(aStruct[i,2]=="M","C",aStruct[i,2])) , aUsl[i] <> NIL  }
 read
 IF LASTKEY()==K_ESC
   EXIT
 ELSE
   IF aDefSpremBaz!=NIL .and. !EMPTY(aDefSpremBaz) .and. aUsl[i]<>NIL .and.;
   aUsl[i]<>".t."
     FOR j:=1 TO LEN(aDefSpremBaz)
       IF UPPER(aDefSpremBaz[j,2]) == UPPER(aStruct[i,1])
         aDefSpremBaz[j,4] := aDefSpremBaz[j,4] +;
                              IF( !EMPTY(aDefSpremBaz[j,4]), ".and.", "") +;
                              IF( UPPER(aDefSpremBaz[j,2]) == UPPER(aDefSpremBaz[j,3]), aUsl[i],;
                                   Parsiraj(aQQ[i]:=_fix_usl(aQQ[i]),aDefSpremBaz[j,3],iif(aStruct[i,2]=="M","C",aStruct[i,2])) )
       ENDIF
     NEXT
   ENDIF
 ENDIF
next
read
BoxC()
if lastkey()==K_ESC; return DE_CONT; endif
aOKol:=ACLONE(Kol)

private cFilter:=".t."
for i:=1 to len(aUsl)
 if ausl[i]<>NIL .and. aUsl[i]<>".t."
   cFilter+=".and."+aUsl[i]
 endif
next
if cFilter==".t."
  set filter to
else
  if left(cfilter,8)==".t..and."
   cFilter:=substr(cFilter,9)
   set filter to &cFilter
  endif
endif
go top
return NIL

// -------------------------------------------
// sredi uslov ako nije postavljeno ; na kraj
// -------------------------------------------
static function _fix_usl(xUsl)
local nLenUsl := LEN(xUsl)
local xRet := SPACE(nLenUsl)

if EMPTY(xUsl)
	return xUsl
endif

if RIGHT(ALLTRIM(xUsl), 1) <> ";"
	xRet := PADR( ALLTRIM(xUsl) + ";", nLENUSL )
else
	xRet := xUsl
endif

return xRet


//---------------------------------
//---------------------------------
function P_Sifk(cId, dx, dy)
local i
private imekol,kol
Kol:={}
O_SIFK
O_SIFV
ImeKol:={ { padr("Id",15), {|| id}, "id"  }           ,;
          { padr("Naz",25), {||  naz}, "naz" }         ,;
          { padr("Sort",4), {||  sort}, "sort" } ,;
          { padr("Oznaka",4), {||  oznaka}, "oznaka" } ,;
          { padr("Veza",4), {||  veza}, "veza" }       ,;
          { padr("Izvor",15), {||  izvor}, "izvor" }   ,;
          { padr("Uslov",30), {||  uslov}, "uslov" }   ,;
          { padr("Tip",3), {|| tip}, "tip" }   ,;
          { padr("Unique",3), {|| Unique}, "Unique", NIL, NIL,NIL,NIL,NIL,NIL, 20}   ,;
          { padr("Duz",3), {|| duzina}, "duzina" }   ,;
          { padr("Dec",3), {|| decimal}, "decimal" }   ,;
          { padr("K Validacija",50), {|| KValid}, "KValid" }   ,;
          { padr("K When",50), {|| KWhen }, "KWhen" }   ,;
          { padr("UBrowsu",4), {|| UBrowsu}, "UBrowsu" }             ,;
          { padr("EdKolona",4), {|| EdKolona}, "EdKolona" }             ,;
          { padr("K1",4), {||  k1}, "k1" }             ,;
          { padr("K2",4), {||  k2}, "k2" }             ,;
          { padr("K3",4), {||  k3}, "k3" }             ,;
          { padr("K4",4), {||  k4}, "k4" }             ;
       }

FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
Private gTBDir:="N"
return PostojiSifra(F_SIFK,1,10,65,"sifk - Karakteristike",@cId,dx,dy)


// nadji novu sifru - radi na pritisak F5 pri unosu
// nove sifre
function NNSifru2()     

local cPom
local cPom2
local nOrder
local nDuz

private cK1:=""
private cImeVar:=""
private cNumDio:=""

if ALIAS()<>"ROBA" .or. IzFMKINI("ROBA","Planika","N",SIFPATH)<>"D" .or. FIELDPOS("K1")==0 .or. !((cImeVar:=READVAR())=="WID") .or. !EMPTY(cK1:=SPACE(LEN(K1))) .or. !VarEdit({ {"Unesite K1","cK1",,"@!",} },10,23,14,56,"Odredjivanje nove sifre artikla","B5")
	return (NIL)
endif
cNumDio := IzFMKINI("ROBA","NumDio","SUBSTR(ID,7,3)",SIFPATH)
cPom2   := &(cImeVar)
nDuz    := LEN(cPom2)
cPom2   := RTRIM(cPom2)
cPom    := cK1+CHR(255)
PushWA()

nOrder:=ORDNUMBER("BROBA")
IF nOrder=0
	MsgBeep("Ako ste u mrezi, svi korisnici moraju napustiti FMK. Zatim pritisnite Enter!")
   	MsgO("Kreiram tag(index) 'BROBA'")
    	cSort := IzFMKINI("ROBA","Sort","K1+SUBSTR(ID,7,3)",SIFPATH)
    	INDEX ON &cSort TAG BROBA
   	MsgC()
ENDIF
set order to tag "BROBA"
GO TOP
SEEK cPom
SKIP -1
cNumDio := &cNumDio
IF K1 == cK1
	&(cImeVar) := PADR( cPom2 + PADL(ALLTRIM(STR(VAL(cNumDio)+1)),LEN(cNumDio),"0") , nDuz )
else
   	&(cImeVar) := PADR( cPom2 + PADL("1",LEN(cNumDio),"0") , nDuz )
ENDIF

wk1 := cK1
AEVAL(GetList,{|o| o:display()})
PopWA()
KEYBOARD CHR(K_END)
RETURN (NIL)



function SeekBarKod(cId,cIdBk,lNFGR)
local nRec
if lNFGR==nil
	lNFGR:=.f.
endif
if lNFGR
	nRec:=RECNO()
endif

if fieldpos("BARKOD")<>0 // tra§i glavni barkod
	set order to tag "BARKOD"
	seek cID
	gOcitBarkod:=.t.
	cId:=ID
	if fID_J
		cID:=ID_J
		set order to tag "ID_J"
		seek cID
	endif
else
	seek "àáâ"
endif

// nisam nasao barkod u polju BARKOD
if !found()   
	cIdBK:=cID
	cId:=""
	ImauSifV("ROBA","BARK", cIdBK, @cId)
	if !empty(cID)
		Beep(1)
		select roba
		set order to tag "ID"
		seek cId  // nasao sam sifru !!
		cId:=Id
		if fID_J
			gOcitBarkod:=.t.
			cID:=ID_J
			set order to tag "ID_J"
			seek cID
		endif
	endif
endif

if lNFGR .and. !FOUND()
	set order to tag "ID"
	go (nRec)
endif
return

// -------------------------------
// -------------------------------
static function sif_brisi_stavku()

if Pitanje(,"Zelite li izbrisati ovu stavku ??","D")=="D"
    brisi_stavku_u_tabeli(ALIAS())
    return DE_REFRESH
else
    return DE_CONT
endif

RETURN DE_REFRESH

// -------------------------------
// -------------------------------
static function sif_brisi_sve()

if Pitanje(,"Zelite li sigurno izbrisati SVE zapise ??","N") == "N"
    return DE_CONT
endif
        
Beep(6)
    
nTArea := SELECT()
// logiraj promjenu brisanja stavke
if _LOG_PROMJENE == .t.
    EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
    "", "", "", DATE(), DATE(), "", ;
    "pokusaj brisanja kompletnog sifrarnika")
endif
select (nTArea)

if Pitanje(,"Ponavljam : izbrisati BESPOVRATNO kompletan sifrarnik ??","N")=="D"
        
    brisi_sve_u_tabeli(ALIAS())   
    select (nTArea)

endif
        
return DE_REFRESH

