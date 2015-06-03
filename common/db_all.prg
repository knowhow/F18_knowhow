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

static aWaStack:={}
static aBoxStack:={}
static nPos:=0
static cPokPonovo:="Pokusati ponovo (D/N) ?"
static nPreuseLevel:=0


/*! \fn Scatter(cZn)
  * \brief vrijednosti field varijabli tekuceg sloga prebacuje u public varijable
  * 
  * \param cZn - Default = "_"; odredjuje prefixs varijabli koje ce generisati
  *
  * \code
  *
  *  use ROBA
  *  Scatter("_")
  *  ? _id, _naz, _jmj
  *
  * \endcode
  *
  */
 
function Scatter(cZn)
return set_global_vars_from_dbf(cZn)


function GatherR(cZn)
local i,j,aStruct

if cZn==nil
  cZn:="_"
endif
aStruct:=DBSTRUCT()
SkratiAZaD(@aStruct)
while .t.

         for j:=1 to len(aRel)
           if aRel[j,1]==ALIAS()  // {"K_0","ID","K_1","ID",1}
              // matrica relacija
              cVar:=cZn+aRel[j,2]
              xField:=&(aRel[j,2])
              if &cVar==xField // ako nije promjenjen broj
                loop
              endif
              select (aRel[j,3]); set order to aRel[j,5]
              do while .t.
               if flock()
                  seek xField
                  do while &(aRel[j,4])==xField .and. !eof()
                    skip
                    nRec:=RECNO()
                    skip -1
                    field->&(aRel[j,4]):=&cVar
                    go nRec
                  enddo

               else
                    inkey(0.4)
                    loop
               endif
               exit
              enddo // .t.
              select (aRel[j,1])
           endif
        next    // j


        for i:=1 to len(aStruct)
          cImeP:=aStruct[i,1]
          cVar:=cZn+cImeP
          field->&cImeP:= &cVar
        next
  exit
end

return nil


/*! \fn Gather2(cZn)
*   \brief Gather ne versi rlock-unlock
*   \note Gather2 pretpostavlja zakljucan zapis !!
*/

function Gather2(zn)
local _i, _struct
local _field_b, _var
 
if zn==nil
  zn:="_"
endif

_struct:=DBSTRUCT()

for _i:=1 to len(_struct)
  _ime_p := _struct[_i, 1]
  _field_b := FIELDBLOCK(_ime_p)
  _var :=  zn + _ime_p

  if  !("#" + _ime_p + "#"  $ "#BRISANO#_SITE_#_OID_#_USER_#_COMMIT_#_DATAZ_#_TIMEAZ_#")
     EVAL(_field_b, EVAL(MEMVARBLOCK(_var)) )
  endif
next
return


function delete2()
local nRec

do while .t.

if rlock()
  dbdelete2()
  DBUNLOCK()
  exit
else
    inkey(0.4)
    loop
endif

enddo
return nil


function dbdelete2()
if !eof() .or. !bof()
 Dbdelete()
endif
return nil


/*
*
* fcisti =  .t. - pocisti polja
*           .f. - ostavi stare vrijednosti polja
* funl    = .t. - otkljucaj zapis, pa zakljucaj zapis
*           .f. - ne diraj (pretpostavlja se da je zapis vec zakljucan)
*/

function appblank2(fcisti, funl)
local aStruct,i, nPrevOrd

if fcisti==nil
  fcisti:=.t.
endif

nPrevOrd:=indexord()

dbappend(.t.)

if fcisti // ako zelis pocistiti stare vrijednosti
	aStruct:=DBSTRUCT()
	for i:=1 to len(aStruct)
		cImeP:=aStruct[i,1]
		if !("#"+cImeP+"#"  $ "#BRISANO#_OID_#_COMMIT_#")
		do case
		case aStruct[i,2]=='C'
			field->&cImeP:=""
		case aStruct[i,2]=='N'
			field->&cImeP:=0
		case aStruct[i,2]=='D'
			field->&cImeP:=ctod("")
		case aStruct[i,2]=='L'
			field->&cImeP:=.f.
		endcase
		endif
	next
endif  // fcisti

ordsetfocus(nPrevOrd)

return nil


/*! \fn AppFrom(cFDbf, fOtvori)
*  \brief apenduje iz cFDbf-a u tekucu tabelu
*  \param cFDBF - ime dbf-a
*  \param fOtvori - .t. - otvori DBF, .f. - vec je otvorena
*/

function AppFrom(cFDbf,fOtvori)
local nArr
nArr:=SELECT()

cFDBF:=ToUnix(cFDBF)

do while .t.
 if !flock()
     inkey(0.4)
     loop
 endif
 exit
enddo

if fotvori
 use (cFDbf) new
else
 select (cFDbF)
endif

go top

do while !eof()
  select (nArr)
  Scatter("f")

  select (cFDBF)
  Scatter("f")

  select (nArr)   // prebaci se u tekuci fajl-u koji zelis staviti zapise
  appblank2(.f.,.f.)
  Gather2("f") // pretpostavlja zakljucan zapis

  select (cFDBF)
  skip
enddo
if fOtvori
  use // zatvori from DBF
endif

dbunlock()
select (nArr)

return



function PrazanDbf()
return .f.



/*! \fn reccount2()
 * \note COMIX - CDX verzija
 */
function reccount2()
local nRec, nPrevOrd

return reccount()


function seek2(cArg)
dbseek(cArg)
return nil

// -------------------------------------------------------------------
// brise sve zapise - ako jmarkira za brisanje sve zapise u bazi
// ako je exclusivno otvorena - __dbZap, ako je shared, 
// markiraj za deleted sve zapise
//
// - pack - prepakuj zapise
// -------------------------------------------------------------------

function zapp(pack)
local bErr

if pack == NIL
  pack := .f.
endif

bErr := ERRORBLOCK({|o| MyErrH(o)})
begin sequence

       log_write( "ZAP exclusive: " + ALIAS(), 5 )
       __dbzap()
       if pack
          __dbpack()
       endif

recover

       log_write( "ZAP shared: " + ALIAS(), 5 )
       PushWa()
       do while .t.

          // neophodno, posto je index po kriteriju deleted() !!
          set order to 0 
          go top
          do while !eof()
            delete_with_rlock()
            skip
          enddo

       exit
       enddo
       PopWa()

end sequence
bErr := ERRORBLOCK(bErr)

return nil


function nerr(oe)
break oe

/*! \fn EofFndRet(ef, close)
 *  \brief Daje poruku da ne postoje podaci
 *  \param ef = .t.   gledaj eof();  ef == .f. gledaj found()
 *  \return  .t. ako ne postoje podaci
 */
 
function EofFndRet(ef, close)
local fRet:=.f., cStr:="Ne postoje trazeni podaci.."
if ef // eof()
  if eof()
    if !gAppSrv
     Beep(1)
     Msg(cStr,6)
    endif
    fRet:=.t.
  endif
else
  if !found()
     if !gAppSrv
       Beep(1); Msg(cStr,6)
     endif
     fRet:=.t.
  endif
endif

if close .and. fRet
  close all
endif
return fRet


/*! \fn SigmaSif(cSif)
 *  \brief zasticene funkcije sistema
 *
 * za programske funkcije koje samo serviser
 * treba da zna, tj koje obicni korisniku
 * nece biti dokumentovane
 *
 * \note Default cSif=SIGMAXXX
 *
 * \return .t. kada je lozinka ispravna
*/

function SigmaSif( cSif )
local lGw_Status

lGw_Status := IF( "U" $ TYPE( "GW_STATUS" ) , "-", gw_status )

GW_STATUS := "-"

if cSif == NIL
    cSif := "SIGMAXXX"
else
    cSif := PADR( cSif, 8 )
endif

Box(, 2, 70 )
    cSifra := SPACE(8)
    @ m_x + 1, m_y + 2 SAY "Sifra za koristenje specijalnih funkcija:"
    cSifra := UPPER( GETSECRET( cSifra ) )
BoxC()

GW_STATUS := lGW_Status

if ALLTRIM( cSifra ) == ALLTRIM( cSif )
    return .t.
else
    return .f.
endif



/*! \fn O_POMDB(nArea,cImeDBF)
 *  \brief otvori pomocnu tabelu, koja ako se nalazi na CDU npr se kopira u lokalni
 *   direktorij pa zapuje
 */

function O_POMDB(nArea,cImeDBF)

select (nArea)

if right(upper(cImeDBF),4)<>"."+DBFEXT
  cImeDBF:=cImeDBf+"."+DBFEXT
endif
cImeCDX:=strtran(UPPER(cImeDBF),"."+DBFEXT,"."+INDEXEXT)
cImeCDX:=ToUnix(cImeCDX)

#xcommand USEXX <(db)>                                                    ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
             [<ro: READONLY>]                                           ;
             [INDEX <(index1)> [, <(indexn)>]]                          ;
                                                                        ;
      => dbUseArea(                                                     ;
                    <.new.>, <rdd>, <(db)>, <(a)>,                      ;
                     .f., .f.        ;
                  )                                                     ;

usex (PRIVPATH+cImeDBF)

return


function CheckROnly( cFileName )
if FILEATTR(cFileName) == 1 
	gReadOnly := .t.
	@ 1, 55 SAY "READ ONLY" COLOR "W/R"
else
	gReadOnly := .f.
	@ 1, 55 SAY "         "
endif

return


function SetROnly(lSilent)
if (lSilent == nil)
	lSilent := .f.
endif

if lSilent
	MsgO("Zakljucavam sezonu...")
endif

IF !lSilent .and. gReadOnly
   	MsgBeep("Podrucje je vec zakljucano!")
   	if Pitanje(,"Zelite otkljucati podrucje ?","N") == "D"
		SetWOnly()
		return
	endif
	RETURN
ENDIF

if !lSilent .and. !SigmaSif("ZAKSEZ")
	return
endif

IF "U" $ TYPE("gGlBaza")
	if !lSilent
		MsgBeep("Nemoguce izvrsiti zakljucavanje##Varijabla gGlBaza nedefinisana!")
   	endif
	RETURN
ENDIF

IF EMPTY(gGlBaza)
  	if !lSilent
		MsgBeep("Nemoguce izvrsiti zakljucavanje##Varijabla gGlBaza prazna!")
   	endif
	RETURN
ENDIF

if !lSilent
	MsgBeep("Izabrana opcija (Ctrl+F10) sluzi za zakljucavanje poslovne godine. #"+;
         "To znaci da nakon ove opcije nikakve ispravke podataka u trenutno #"+;
         "aktivnom podrucju nece biti moguce. Ukoliko ste sigurni da to zelite #"+;
         "na sljedece pitanje odgovorite potvrdno!" )
endif

IF !lSilent .and. Pitanje(,"Jeste li sigurni da zelite zastititi trenutno podrucje od ispravki? (D/N)","N")=="D"

   		IF SETFATTR(cDirRad + SLASH + gGlBaza, 1) == 0
     			gReadOnly:=.t.
			CheckROnly(cDirRad + SLASH + gGlBaza)
		ELSE
 			MsgBeep("Greska! F-ja zastite trenutno izabranog podrucja onemogucena! (SETFATTR)")
   		ENDIF
ELSE
	IF SETFATTR(cDirRad + SLASH + gGlBaza, 1) == 0
		gReadOnly:=.t.
	ENDIF	
ENDIF

if lSilent
	Sleep(3)
	MsgC()
	CheckROnly(cDirRad + SLASH + gGlBaza)
endif

return
*}

/*! \fn SetWOnly()
 *  \brief Set write atributa
 */
function SetWOnly(lSilent)
*{

if (lSilent == nil)
	lSilent := .f.
endif

if lSilent
	MsgO("Otkljucavam sezonu...")
endif

if !lSilent .and. !SigmaSif("OTKSEZ")
	return
endif

IF "U" $ TYPE("gGlBaza")
	if !lSilent
		MsgBeep("Nemoguce izvrsiti otljucavanje. Varijabla gGlBaza nedefinisana!")
   	endif
	RETURN
ENDIF

IF EMPTY(gGlBaza)
  	if !lSilent
		MsgBeep("Nemoguce izvrsiti otkljucavanje. Varijabla gGlBaza prazna!")
   	endif
	RETURN
ENDIF

IF !lSilent .and. Pitanje(,"Jeste li sigurni da zelite ukloniti zastitu? (D/N)","N")=="D"
	#ifdef CLIP
   		IF SETFATTR(goModul:oDatabase:cDirKum + SLASH + gGlBaza, 0) == 0
	#else
   		IF SETFATTR(cDirRad + SLASH + gGlBaza, 0) == 0
	#endif
     			gReadOnly:=.f.
			CheckROnly(cDirRad + SLASH + gGlBaza)
   		ELSE
     			MsgBeep("Greska! F-ja ukidanje zastite onemogucena! (SETFATTR)")
   		ENDIF
ELSE
   		IF SETFATTR(cDirRad + SLASH + gGlBaza, 0) == 0
			gReadOnly:=.f.
		ENDIF
ENDIF

if lSilent
	Sleep(3)
	MsgC()
	CheckROnly(cDirRad + SLASH + gGlBaza)
endif

return


 
/*! \fn Append2()
 * \brief Dodavanje novog zapisa u (nArr) -
 * \note koristi se kod dodavanja zapisa u bazu nakon Izdvajanja zapisa funkcijom Izdvoji()
 */

function Append2()
local nRec
select(nArr)
DbAppend()
nRec:=RECNO()
select(nTmpArr)
DbAppend()
replace recno with nRec

return nil

/*! \fn DbfName(nArea, lFull)
 *  \param nArea
 *  \param lFull True - puno ime cPath + cDbfName; False - samo cDbfName; default=False
 *
 */
 


function DbfName( nArea, lFull )
local nPos
local cPrefix

if lFull==nil
	lFull:=.f.
endif

cPrefix:=""
nPos := ASCAN( gaDbfs, {|x| x[1] == nArea } )

if nPos<1
 nPos:=ASCAN(gaSDbfs,{|x| x[1]==nArea})
 if nPos<1
   //MsgBeep("Ne postoji DBF Arrea "+STR(nArea)+" ?")
   return ""
 endif
 if lFull
 	cPrefix:=DbfPath(gaSDbfs[nPos,3])
 endif
 return cPrefix + gaSDbfs[nPos,2]
else
 if lFull 
 	cPrefix:=DbfPath(gaDbfs[nPos,3])
 endif
 return cPrefix+gaDbfs[nPos,2]
endif
return



function DbfPath(nPath)
do case
	CASE nPath==P_PRIVPATH
		return PRIVPATH
	CASE nPath==P_KUMPATH
		return KUMPATH
	CASE nPath==P_SIFPATH
		return SIFPATH
	CASE nPath==P_EXEPATH
		return EXEPATH
	CASE nPath==P_MODULPATH
		return DBFBASEPATH+SLASH+gModul+SLASH
	CASE nPath==P_TEKPATH
		return "."+SLASH
	CASE nPath==P_ROOTPATH
		return SLASH
	CASE nPath==P_KUMSQLPATH
		return KUMPATH+"SQL"+SLASH
	CASE nPath==P_SECPATH
		return goModul:oDatabase:cSigmaBD+SLASH+"SECURITY"+SLASH
end case
return 




function DbfArea( tbl, var )
local _rec
local _only_basic_params := .t.

if ( var == NIL )
    var := 0
endif

_rec := get_a_dbf_rec( LOWER( tbl ), _only_basic_params )

return _rec["wa"]




function NDBF( tbl )
return DbfArea( tbl ) 



function NDBFPos( tbl )
return DbfArea( tbl, 1 )



function F_Baze( tbl )
local _dbf_tbl 
local _area := 0
local _rec
local _only_basic_params := .t.

_rec := get_a_dbf_rec( LOWER( tbl ), _only_basic_params )

// ovo je work area
if _rec <> NIL
    _area := _rec["wa"]
endif

if _area <= 0
    close all
    quit
endif

return _area



function Sel_Bazu( tbl )
local _area
 
_area := F_baze( tbl )
 
if _area > 0
    select ( _area )
else
    close all
    quit
endif

return


function gaDBFDir( nPos )
return my_home()



function O_Bazu( tbl )
my_use( LOWER( tbl ) )
return



function ExportBaze(cBaza)
LOCAL nArr:=SELECT()
  FERASE(cBaza+"."+INDEXEXT)
  FERASE(cBaza+"."+DBFEXT)
  cBaza+="."+DBFEXT
  COPY STRUCTURE EXTENDED TO (PRIVPATH+"struct")
  CREATE (cBaza) FROM (PRIVPATH+"struct") NEW
  MsgO("apendujem...")
  APPEND FROM (ALIAS(nArr))
  MsgC()
  USE
  SELECT (nArr)
return


function PoljeBrisano(cImeDbf)
*{
* select je na bazi koju ispitujes

if fieldpos("BRISANO")=0 // ne postoji polje "brisano"
  use
  save screen to cScr
  cls
  Modstru(cImeDbf,"C  V C 15 0  FV C 15 0",.t.)
  Modstru(cImeDbf,"A BRISANO C 1 0",.t.)  // dodaj polje "BRISANO"
  inkey(10)
  restore screen from cScr

  use (cImeDBf)
endif
return nil


/*! \fn SmReplace(cField, xValue, lReplAlways)
 *  \brief Smart Replace - vrsi replace. Ako je lReplAlways .T. uvijek vrsi, .F. samo ako je vrijdnost polja razlicita 
 *  \note vrsi se i REPLSQL, kada je gSql=="D"
 */
 
function SmReplace(cField, xValue, lReplAlways)
private cPom

if (lReplAlways == nil)
	lReplAlways := .f.
endif

cPom:=cField

if ((&cPom<>xValue) .or. (lReplAlways == .t.))
	REPLACE &cPom WITH xValue
	if (gSql=="D")
		//REPLSQL &cPom WITH xValue
	endif
endif

return

/*! \fn  PreUseEvent(cImeDbf, fShared)
 *  \brief Poziva se prije svako otvaranje DBF-a komanom USE
 *
 * Za gSQL=="D":
 * Ako fajl KUMPATH + DOKS.gwu postoji, to znaci da je Gateway izvrsio
 * update fajla pa zato reindeksiraj i pakuj DBF
 * Na kraju izbrisi *.gwu fajl
 *
 */

function PreUseEvent(cImeDbf, fShared)
*{
local cImeCdx
local cImeGwu
local nArea
local cOnlyName

if (goModul:oDatabase<>nil) 
	if (goModul:oDatabase:lAdmin)
		return 0
	endif
else
	//sistem jos nije inicijaliziran, samo vrati isto ime tabele
	return cImeDbf
endif

if nPreuseLevel>0
	return 0
endif
// ne dozvoli rekurziju funkcije
nPreuseLevel:=1

cOnlyName:=ChangeEXT(ExFileName(cImeDbf),"DBF","")

cImeGwu:=ChangeEXT(cImeDbf, DBFEXT, "gwu")
cImeCdx:=ChangeEXT(cImeDbf, DBFEXT, INDEXEXT)

cImeDbf:=LOWER(cImeDbf)
cImeDbf:=STRTRAN(cImeDbf, ".korisn","korisn")
cImeGw:=ChangeEXT(cImeDbf, DBFEXT, "gwu")

if gReadOnly 
	nPreuseLevel:=0
	return cImeDbf
endif


if (GW_STATUS="-" .and. FILE(cImeGwu))

	nArea:=DbfArea(UPPER(cOnlyName))
	FERASE(cImeCdx)
	goModul:oDatabase:kreiraj(nArea)
	FERASE(cImeGwu)
		
endif

nPreuseLevel:=0
return cImeDbf
*}

/*! \fn ScanDb()
 *  \brief Prodji kroz sve tabele i pokreni PreuseEvent
 *  \note sve tabele koje je gateway azurirao bice indeksirane
 */
function ScanDb()
local i
local cDbfName

CLOSE ALL

for i:=1 to 250
	MsgO("ScanDb "+STR(i))
	cDbfName:=DbfName(i,.t.)
	if !EMPTY(cDbfName)
		if FILE(cDbfName+"."+DBFEXT)
			USEX (cDbfName)
			if (RECCOUNT()<>RecCount2())
				MsgO("Pakujem "+cDbfName)
					__DBPACK()
				MsgC()
			endif
			USE
		endif
		PreUseEvent(cDbfName, .f.)
	endif
	MsgC()
		
next
CLOSE ALL
return

// --------------------------------
// --------------------------------
function PushWA()

if used()
   StackPush(aWAStack, {select(), IndexOrd(), DBFilter(), RECNO()})
else
   StackPush(aWAStack, {NIL, NIL, NIL, NIL})
endif

return NIL


// ---------------------------
// ---------------------------
function PopWA()

local aWa
local i

aWa := StackPop(aWaStack)

if aWa[1]<>nil
   
   // select
   SELECT(aWa[1])
   
   // order
   if used()
	   if !empty(aWa[2])
	      ordsetfocus(aWa[2])
	   else
	    set order to
	   endif
   endif

   // filter
   if !empty(aWa[3])
     set filter to &(aWa[3])
   else
     if !empty(dbfilter())
       set filter to
     endif
     //   DBCLEARFILTER( )
   endif
   
   if used()
    go aWa[4]
   endif
   
endif  // wa[1]<>NIL

return nil


// ---------------------------------------------------------
// modificiranje polja, ubacivanje predznaka itd...
//
// params:
//   - cField = "SIFRADOB" 
//   - cIndex - indeks na tabeli "1" ili "ID" itd...
//   - cInsChar - karakter koji se insertuje
//   - nLen - duzina sifra na koju se primjenjuje konverzija
//            i insert (napomena: nije duzina kompletne sifre)
//            IDROBA = LEN(10), ali mi zelimo da konvertujemo
//            na LEN(5) sifre sa vodecom nulom
//   - nSufPref - sufiks (1) ili prefiks (2)
//   - funkcija vraca konvertovani broj zapisa
//   - lSilent - tihi mod rada .t. ili .f.
//   
//   Napomena:
//   tabela na kojoj radimo konverziju moraju biti prije pokretanja 
//   funkcije otvoreni
// ---------------------------------------------------------
function mod_f_val( cField, cIndex, cInsChar, nLen, nSufPref, lSilent )
local nCount := 0

if cIndex == nil
	cIndex := "1"
endif

if nSufPref == nil
	nSufPref := 2
endif

if lSilent == nil
	lSilent := .f.
endif

if lSilent == .f. .and. Pitanje(,"Izvrsiti konverziju ?", "N") == "N"
	return -1
endif

set order to tag cIndex
go top

do while !EOF()
	
	// trazena vrijednost iz polja
	cVal := ALLTRIM( field->&cField )
	nFld_len := LEN( field->&cField )
 
 	if !EMPTY( cVal ) .and. LEN( cVal ) < nLen

		if nSufPref == 1
			// sufiks
			cNew_val := PADR( cVal, nLen, cInsChar )
		else
			// prefiks
			cNew_Val := PADL( cVal, nLen, cInsChar )
 		endif

		// ubaci novu sifru sa nulama
		replace field->&cField with PADR( cNew_val, nFld_len )
		++ nCount 
	endif
	
	skip

enddo

return nCount

