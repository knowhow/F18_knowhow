/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"
#include "fileio.ch"
 
*static string
static OID_ASK:="0"
*;

*static string
static nSlogova:=0
*;

// -----------------------------------------------------
// -----------------------------------------------------
function create_index(cImeInd, cKljuc, alias, silent)
local _force_erase := .f.
local bErr
local cFulDbf
local nH
local cImeCDXIz
local cImeCDX
local nOrder
local nPos
local cImeDbf
local _a_dbf_rec
local _wa
local _dbf
local _tag

private cTag
private cKljuciz

if silent == nil
    silent := .f.
endif


close all

alias := FILEBASE(alias)
 
_a_dbf_rec := get_a_dbf_rec(alias, .t.)
_wa := _a_dbf_rec["wa"]


for each _tag in { cTag, "DEL" }

cImeDbf := f18_ime_dbf(alias)
cImeCdx := ImeDbfCdx(cImeDbf)
 
nPom := RAT(SLASH, cImeInd )
cTag := ""

cKljucIz := cKljuc

if nPom <> 0
   cTag := substr(cImeInd, nPom+1)
else
   cTag := cImeInd
endif


if _tag == "DEL"
     cTag    := "DEL"
     cKljuc  := "deleted()"
     cImeInd := cTag
endif


fPostoji := .t.

select (_wa)

_dbf := f18_ime_dbf(alias)

begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }
          dbUseArea( .f., DBFENGINE, _dbf , NIL, .t. , .f.)

recover using _err

          _msg := "ERR-CI: " + _err:description + ": tbl:" + alias + " se ne moze otvoriti ?!"
          log_write( _msg, 3 )
          Alert(_msg)
         
          // _err:GenCode = 23 
          if _err:description == "Read error"
             _force_erase := .t.
          endif

          // kada imamo pokusaj duplog otvaranja onda je
          // _err:GenCode = 21
          // _err:description = "Open error"
 
          ferase_dbf(alias, _force_erase)

          repair_dbfs()
          QUIT
end sequence


// open index
begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }
     if FILE( ImeDbfCdx(_dbf))
            dbSetIndex(ImeDbfCdx(_dbf))
     endif
recover using _err
     // ostecen index brisi ga
     FERASE(ImeDbfCdx(_dbf))
end sequence

if  FILE(ImeDbfCdx(_dbf, OLD_INDEXEXT))
    FERASE(ImeDbfCdx(_dbf, OLD_INDEXEXT))
endif


if USED()
	nOrder := ORDNUMBER( cTag )
	cOrdKey := ORDKEY(cTag)
	select (_wa)
	use
else
	log_write("create_index: Ne mogu otvoriti " + cImeDbf, 3 )
	fPostoji := .f.
endif

if !fPostoji
	return
endif

if !FILE(LOWER(cImeCdx)) .or. nOrder==0 .or. ALLTRIM(UPPER( cOrdKey )) <> ALLTRIM(UPPER( cKljuc ))

     SELECT(_wa)
     use
     USE (f18_ime_dbf(alias)) EXCLUSIVE
 
     if !silent
          MsgO("Baza:" + cImeDbf + ", Kreiram index-tag :" + cImeInd + "#" + ExFileName(cImeCdx))
     endif
   
	 log_write("Kreiram indeks za tabelu " + cImeDbf + ", " + cImeInd, 7 )

     nPom:=RAT( SLASH, cImeInd)
    
     private cTag:=""
     private cKljuciz:=cKljuc
    
     if nPom<>0
         cTag := substr(cImeInd, nPom)
     else
         cTag := cImeInd
     endif

     //  provjeri indeksiranje na nepostojecim poljima ID_J, _M1_
     if  !(LEFT(cTag, 4)=="ID_J" .and. fieldpos("ID_J")==0) .and. !(cTag=="_M1_" .and. FIELDPOS("_M1_")==0)

     	cImeCdx := strtran(cImeCdx, "." + INDEXEXT, "")

        log_write("index on " + cKljucIz + " / " + cTag + " / " + cImeCdx + " / alias=" + alias + " / used() = " + hb_valToStr(USED()), 7 )     
        if _tag == "DEL"
              INDEX ON deleted() TAG "DEL" TO (cImeCdx) FOR deleted()
        else
     	      INDEX ON &cKljucIz  TAG (cTag)  TO (cImeCdx) 
        endif
     	USE


     endif

     if !silent
       MsgC()
     endif
     use

endif

next

close all
return


function IsFreeForReading(cFulDBF, fSilent)

local nH

nH:=FOPEN(cFulDbf,2)  // za citanje i pisanje
if FERROR()<>0
      Beep(2)
      if !fSilent
       Msg("Ne mogu otvoriti "+cFulDBF+" - vjerovatno ga neko koristi#"+;
              "na mrezi. Ponovite operaciju kada ovo rijesite !")
       return .f.
      else
        cls
        ? "Ne mogu otvoriti",cFulDbf
        INKEY()
      endif
      FCLOSE(nH)
      return .t.
endif
FCLOSE(nH)
return .t.


function AddFldBrisano(cImeDbf)
use
save screen to cScr
CLS
       Modstru(cImeDbf,"C H C 1 0  FH  C 1 0",.t.)
       Modstru(cImeDbf,"C SEC C 1 0  FSEC C 1 0",.t.)
       Modstru(cImeDbf,"C VAR C 2 0 FVAR C 2 0",.t.)
       Modstru(cImeDbf,"C VAR C 15 0 FVAR C 15 0",.t.)
       Modstru(cImeDbf,"C  V C 15 0  FV C 15 0",.t.)
       Modstru(cImeDbf,"A BRISANO C 1 0",.t.)  // dodaj polje "BRISANO"
inkey(3)
restore screen from cScr

select (F_TMP)
usex (cImeDbf)
return


function KZNbaza(aPriv,aKum,aSif,cIz,cU, cSamoId)


// cSamoId  "1"- konvertuj samo polja koja pocinju sa id
//          "2"- konvertuj samo polja koja ne pocinju sa id
//          "3" ili nil - konvertuj sva polja
//      "B" - konvertuj samo IDRADN polja iz LD-a  

 LOCAL i:=0, j:=0, k:=0, aPom:={}, xVar:="", anPolja:={}
 CLOSE ALL
 SET EXCLUSIVE ON
 IF aPriv==nil; aPriv:={}; ENDIF
 IF aKum==nil ; aKum:={} ; ENDIF
 IF aSif==nil ; aSif:={} ; ENDIF
 if cSamoid==nil; cSamoid:="3"; endif
private cPocStanjeSif
private cKrajnjeStanjeSif
 if !gAppSrv
   Box("xx",1,50,.f.,"Vrsi se konverzija znakova u bazama podataka")
   @ m_x+1,m_y+1 say "Konvertujem:"
 else
   ? "Vrsi se konverzija znakova u tabelama"
 endif
 FOR j:=1 TO 3
   DO CASE
     CASE j==1
       aPom:=aPriv
     CASE j==2
       aPom:=aKum
     CASE j==3
       aPom:=aSif
   ENDCASE
   FOR i:=1 TO LEN(aPom)
     nDbf:=aPom[i]
     goModul:oDatabase:obaza(nDbf)
     DBSELECTArea (nDbf)
     if !gAppSrv
       @ m_x+1,m_y+25 SAY SPACE(12)
       @ m_x+1,m_y+25 SAY ALIAS(nDBF)
     else
        ? "Konvertujem: " + ALIAS(nDBF)
     endif
     if used()
       beep(1)
       ordsetfocus(0)
       GO TOP
       anPolja:={}
       FOR k:=1 TO FCOUNT()
        if (cSamoId=="3") .or. (cSamoId=="1" .and. upper(fieldname(k)) = "ID") .or. (cSamoId=="2"  .and. !(upper(fieldname(k)) = "ID")) .or. (cSamoId=="B" .and. ((UPPER(FieldName(k)) = "IDRADN") .or. ((UPPER(FieldName(k)) = "ID") .and. ALIAS(nDbf)=="RADN")))
         xVar:=FIELDGET(k)
         IF VALTYPE(xVar)$"CM"
           AADD(anPolja,k)
         ENDIF
        endif  // csamoid
       NEXT
       DO WHILE !EOF()
         FOR k:=1 TO LEN(anPolja)
           xVar:=FIELDGET(anPolja[k])
           FIELDPUT(anPolja[k],StrKZN(xVar,cIz,cU))
           // uzmi za radnika ime i prezime
     if (cSamoId=="B") .and. UPPER(FIELDNAME(1)) = "ID" .and. ALIAS(nDbf)=="RADN"
    //AADD(aSifRev, {FIELDGET(4)+" "+FIELDGET(5), cPocStanjeSif, cKrajnjeStanjeSif})
     endif
   NEXT
         SKIP 1
       ENDDO
       use
     endif
   NEXT
 NEXT
 if !gAppSrv
   BoxC()
 endif
 SET EXCLUSIVE OFF
 if !gAppSrv
   BrisiPaK()
 else
     ? "Baze konvertovane!!!"
     BrisiPaK()
 endif
return


function MyErrHt(o)

BREAK o
return .t.



function Reindex(ff)


*  REINDEXiranje DBF-ova

local nDbf
local lZakljucana

IF (ff<>nil .and. ff==.t.) .or. if( !gAppSrv,  Pitanje("","Reindeksirati DB (D/N)","N")=="D", .t.)

if !gAppSrv
  Box("xx",1,56,.f.,"Vrsi se reindeksiranje DB-a ")
else
  ? "Vrsi se reindex tabela..."
endif

// Provjeri da li je sezona zakljucana
lZakljucana := .f.

if gReadOnly
  lZakljucana := .t.
  // otkljucaj sezonu
  SetWOnly(.t.)
endif
//

close all

// CDX verzija
set exclusive on
for nDbf:=1 to 250
  if !gAppSrv
           @ m_x+1,m_y+2 SAY SPACE(54)
     endif
#ifndef FMK_DEBUG
    bErr:=ERRORBLOCK({|o| MyErrHt(o)})
    BEGIN SEQUENCE
    // sprijeciti ispadanje kad je neko vec otvorio bazu
    goModul:oDatabase:obaza(nDbf)
    RECOVER
    Beep(2)
    if !gAppSrv
      @ m_x+1,m_y+2 SAY "Ne mogu administrirati "+DbfName(nDbf)+" / "+alltrim(str(nDbf))
    else
      ? "Ne mogu administrirati: " + DBFName(nDbf) + " / " + ALLTRIM(STR(nDBF))
    endif

    if !EMPTY(DBFName(nDbf))
      // ovaj modul "zna" za ovu tabelu, ali postoji problem
      inkey(3)
    endif
    END SEQUENCE
    bErr:=ERRORBLOCK(bErr)
#else
    goModul:oDatabase:obaza(nDbf)
    if !gAppSrv
      @ m_x+1,m_y+2  SAY SPACE(40)
    endif
#endif

  DBSELECTArea (nDbf)
  if !gAppSrv
    @ m_x+1,m_y+2 SAY "Reindeksiram: " + ALIAS(nDBF)
  else
    ? "Reindexiram: " + ALIAS(nDBF)
  endif

  if used()
    beep(1)
    ordsetfocus(0)
    nSlogova:=0
    REINDEX
    //EVAL { || Every() } EVERY 150
    use
  endif

   next
   set exclusive off
   if !gAppSrv
     BoxC()
   endif  
endif

if lZakljucana == .t.
  SetROnly(.t.)
endif

closeret
return nil



function Pakuj(ff)

local nDbfff,cDN

IF (ff<>nil .and. ff==.t.) .or. (cDN:=Pitanje("pp","Prepakovati bazu (D/N/L)","N")) $ "DL"


 Box("xx",1,50,.f.,"Fizicko brisanje zapisa iz baze koji su markirani za brisanje")
   @ m_x+1,m_y+1 say "Pakuje se DB:"


close all

set exclusive on
for nDbfff:=1 to 250
   goModul:oDatabase:obaza(nDbfff)
   if used()
    @ m_x+1,m_y+30 SAY SPACE(12)
    @ m_x+1,m_y+30 SAY ALIAS()
    
    // bezuslovno trazi deleted()
    if cDN=="L"  
     //locate for deleted()
    else
     if norder<>0
      set order to TAG "BRISAN"
      
      // nadji izbrisan zapis
      seek "1"   
     endif
    endif
    if nOrder=0 .or. found()  
      BEEP(1)
      ordsetfocus(0)
      @ m_x+1,m_y+36 SAY reccount() pict "999999"
      __DBPACK()
      @ m_x+1,m_y+42 SAY "+"
      @ m_x+1,m_y+44 SAY reccount() pict "99999"
    else
      @ m_x+1,m_y+36 SAY space(4)
      @ m_x+1,m_y+42 SAY "-"
      @ m_x+1,m_y+44 SAY space(4)
    endif
    inkey(0.4)


    use
   endif //used
next
BoxC()

endif

closeret
return



function BrisiPAk(fSilent)

if fSilent==nil
  fSilent:=.f.
endif

#ifdef FMK_DEBUG

if !gAppSrv
  Msgbeep("Brisipak procedura...")
endif

#endif

if fSilent .or. if(!gAppSrv, Pitanje(,"Izbrisati "+INDEXEXT+" fajlove pa ih nanovo kreirati","N")=="D", .t.)
   close all
   cMask:="*."+INDEXEXT
   if !gAppSrv
     cScr:=""
     save screen to cScr
     cls
  if fSilent .or. pitanje(,"Indeksi iz privatnog direktorija ?","D")=="D"
         DelSve(cMask,trim(cDirPriv))
         inkey(1)
     endif
     if fSilent .or.  pitanje(,"Indeksi iz direktorija kumulativa ?","N")=="D"
         DelSve(cMask,trim(cDirRad))
         inkey(1)
     endif
     if fSilent .or.  pitanje(,"Indeksi iz direktorija sifrarnika ?","N")=="D"
        DelSve(cMask,trim(cDirSif))
         inkey(1)
     endif
     if fSilent .or.  pitanje(,"Indeksi iz tekuceg direktorija?","N")=="D"
         DelSve(cMask,".")
         inkey(1)
     endif
     if fSilent .or. pitanje(,"Indeksi iz korjenog direktorija?","N")=="D"
         DelSve(cMask,SLASH)
         inkey(1)
     endif
   else
     ? "Brisem sve indexe..."
  ? "Radni dir: " + TRIM(cDirRad)
  DelSve(cMask, TRIM(cDirRad))
  DelSve(cMask, TRIM(cDirSif))
  DelSve(cMask, TRIM(cDirPriv))
   endif  
   if !gAppSrv
     restore screen from cScr
   endif
   CreParams()
   close all
   if gAppSrv
     ? "Kreiram sve indexe ...."
  ? "Radni dir: " + cDirRad
   endif
   goModul:oDatabase:kreiraj()
   if gAppSrv
     ? "Kreirao index-e...."
   endif
endif

return


/*! \fn AppModS(cCHSName)
 *  \brief Modifikacija struktura APPSRV rezim rada
 *  \param cCHSName - ime chs fajla (npr. FIN)
 */
function AppModS(cCHSName)

local cCHSFile:=""

if !gAppSrv
  return
endif

// ako nije zadan parametar uzmi osnovnu modifikaciju
if cCHSName==NIL
  cCHSFile:=(EXEPATH + gModul + ".CHS")
else
  cCHSFile:=(EXEPATH + cCHSName + ".CHS")
endif

? "Modifikacija struktura " + cCHSFile
? "Pricekajte koji trenutak ..."

cEXT:=SLASH+"*."+INDEXEXT

? "Modifikacija u privatnom direktoriju ..."
close all
Modstru(TRIM(cCHSFile), trim(goModul:oDataBase:cDirPriv))

? "Modifikacija u direktoriju sifrarnika ..."
close all
Modstru(TRIM(cCHSFile), trim(goModul:oDataBase:cDirSif))

? "Modifikacija u direktoriju kumulativa ..."
close all
Modstru(TRIM(cCHSFile), trim(goModul:oDataBase:cDirKum))


// kreiraj, reindex
close all
goModul:oDatabase:kreiraj()
Reindex(.t.)

return


/*! \fn RunModS(fDa)
 *  \param fDa - True -> Batch obrada (neinteraktivno)
 */
function RunModS(fDa)


if fda==nil
  fda:=.f.
endif

cImeCHS:=EXEPATH+gModul+".CHS"

if fda .or. PitMstru(@cImeCHS)
  cScr:=""
         save screen to cScr
         cEXT:=SLASH+"*."+INDEXEXT
         cls
         if fda .or. Pitanje(,"Modifikacija u Priv dir ?","D")=="D"
          close all
           Modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirPriv))
         endif

         if fda .or. Pitanje(,"Modifikacija u SIF dir ?","N")=="D"
          close all
          Modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirSif))
         endif

         if fda .or. Pitanje(,"Modifikacija u KUM dir ?","N")=="D"
          close all
           Modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirKum))
         endif

         if fda .or. Pitanje(,"Modifikacija u tekucem dir ?","N")=="D"
          close all
           Modstru(TRIM(cImeCHS),".")
         endif

         Beep(1)
         restore screen from cScr
         close all
         goModul:oDatabase:kreiraj()
         Reindex(.t.)
endif

return


static function PitMstru(cImeChs)

local cDN:="N"

cImeChs:=padr(cImeChs,30)
Box(,3,50)
  @ m_x+1,m_y+2 SAY "Izvrsiti modifikaciju struktura D/N" GET cDN pict "@!" valid cdn $ "DN"
  read
  if cDN=="D"
    @ m_x+3,m_y+2 SAY "CHS Skript:" GET cImeCHS
    read
    cImeCHS:=ToUnix(trim(cImeChs))
  endif
BoxC()

if cDn == "D"
  return .t.
else
  return .f.
endif

function FillOid(cImeDbf, cImeCDX)

private cPomKey

if FIELDPOS("_OID_")==0
  return 0
endif


cImeCDX:=STRTRAN(cImeCDX,"."+INDEXEXT,"")

nOrder:=ORDNUMBER("_OID_")
cOrdKey:=ORDKEY("_OID_")
if !( nOrder==0  .or. !(LEFT(cOrdKey,5)="_OID_") )
  return
endif

if (field->_OID_==0 .and. RecCount2()<>0)
    
   Msgbeep("OID "+ALIAS()+" nepopunjen ")

   if OID_ASK=="0"
            // OID nije inicijaliziran
            if SigmaSif("OIDFILL")
               OID_ASK:="D"
            endif
   endif

   if  (OID_ASK=="D") .and. Pitanje(,"Popuniti OID u tabeli "+ALIAS()+" ?"," ")=="D"
         MsgO("Popunjavam OID , tabela "+ALIAS())
   cPomKey:="_OID_"
   index on &cPomKey TAG "_OID_"  TO (cImeCDX) 
         go top
         if field->_OID_=0
           set order to 0
           go top
           do while !eof()
             replace _OID_ with New_Oid()
             skip
           enddo
         endif
         MsgC()
   endif
endif

return


/*! \fn ImdDBFCDX(cIme)
 *  \brief Mjenja DBF u indeksnu extenziju
 *
 * \code 
 *  suban     -> suban.CDX
 *  suban.DBF -> suban.CDX
 * \endcode
 */
 
function ImeDBFCDX(cIme, ext)

if ext == NIL
  ext := INDEXEXT
endif

cIme:=trim(strtran(ToUnix(cIme), "." + DBFEXT, "." + ext))
if right(cIme,4) <> "." + ext
  cIme := cIme + "." + ext
endif
return  cIme


static function Every()
return


