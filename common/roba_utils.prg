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


#include "f18.ch"



function OpenDB()
O_ROBA
if (goModul:oDataBase:cName=="KALK")
	O_KALK
endif
if (goModul:oDataBase:cName=="FAKT")
	O_FAKT
endif
return



// ----------------------------------
// svedi na standardnu jedinicu mjere
// ( npr. KOM->LIT ili KOM->KG )
// ----------------------------------

function SJMJ(nKol,cIdRoba,cJMJ)
 LOCAL nVrati:=0, nArr:=SELECT(), aNaz:={}, cKar:="SJMJ", nKO:=1, n_Pos:=0
  SELECT SIFV; SET ORDER TO TAG "ID"
  HSEEK "ROBA    "+cKar+PADR(cIdRoba,15)
  DO WHILE !EOF().and.id+oznaka+idsif=="ROBA    "+cKar+PADR(cIdRoba,15)
    IF !EMPTY(naz)
      AADD( aNaz , naz )
    ENDIF
    SKIP 1
  ENDDO
  IF LEN(aNaz)>0
    // slijedi preracunavanje
    // ----------------------
    n_Pos := AT( "_" , aNaz[1] )
    cPom   := ALLTRIM( SUBSTR( aNaz[1] , n_Pos+1 ) )
    nKO    := &cPom
    nVrati := nKol*nKO
    cJMJ   := ALLTRIM( LEFT( aNaz[1] , n_Pos-1 ) )
  ELSE
    // valjda je ve� u osnovnoj JMJ
    // ----------------------------
    nVrati:=nKol
  ENDIF
  SELECT (nArr)
return nVrati



// ----------------------------------------------------------
// sredi sifru dobavljaca, poravnanje i popunjavanje
//   ako je sifra manja od LEN(5) popuni na LEN(8) sa "0"
// 
// cSifra - sifra dobavljaca
// nLen - na koliko provjeravati
// cFill - cime popuniti
// ----------------------------------------------------------
function fix_sifradob( cSifra, nLen, cFill )
local nTmpLen

if gArtCDX = "SIFRADOB"

  nTmpLen := LEN( roba->sifradob )

  // dodaj prefiks ako je ukucano manje od 5
  if LEN( ALLTRIM( cSifra ) ) < 5
	cSifra := PADR( PADL( ALLTRIM(cSifra), nLen, cFill ) , nTmpLen )
  endif
endif

return .t.



