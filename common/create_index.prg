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
function create_index(cImeInd, xKljuc, alias, silent)
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
local cKljuc
local _unique := .f.

private cTag
private cKljuciz
private cFilter

if silent == nil
    silent := .f.
endif

if VALTYPE(xKljuc) == "C"
   cKljuc := xKljuc
   cFilter := NIL
else
   cKljuc := xKljuc[1]
   cFilter := xKljuc[2]
   if LEN(xKljuc) == 3
      _unique := xKljuc[3]
   endif   
endif

CLOSE ALL

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
          log_write( _msg, 2)
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
          QUIT_1
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
	nOrder := index_tag_num( cTag )
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
    
     private cTag :=""
     private cKljuciz := cKljuc
    
     if nPom<>0
         cTag := substr(cImeInd, nPom)
     else
         cTag := cImeInd
     endif

     //  provjeri indeksiranje na nepostojecim poljima ID_J, _M1_
     if  !(LEFT(cTag, 4)=="ID_J" .and. fieldpos("ID_J")==0) .and. !(cTag=="_M1_" .and. FIELDPOS("_M1_")==0)

     	cImeCdx := strtran(cImeCdx, "." + INDEXEXT, "")

        log_write("index on " + cKljucIz + " / " + cTag + " / " + cImeCdx + " FILTER: " + IIF(cFilter != NIL, cFilter, "-") + " / alias=" + alias + " / used() = " + hb_valToStr(USED()), 5 ) 
        if _tag == "DEL"
              INDEX ON deleted() TAG "DEL" TO (cImeCdx) FOR deleted()
        else
            if cFilter != NIL
              if _unique
     	         INDEX ON &cKljucIz  TAG (cTag)  TO (cImeCdx) FOR &cFilter UNIQUE
              else
     	         INDEX ON &cKljucIz  TAG (cTag)  TO (cImeCdx) FOR &cFilter
              endif
     	    else
              INDEX ON &cKljucIz  TAG (cTag)  TO (cImeCdx)
            endif 
        endif
     	USE


     endif

     if !silent
       MsgC()
     endif
     use

endif

next

CLOSE ALL
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
return


function MyErrHt(o)

BREAK o
return .t.




static function Every()
return


