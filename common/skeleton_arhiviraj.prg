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



// -------------------------------------------------
// -------------------------------------------------
function IscitajCRC(cFajl)


LOCAL cPom
IF cFajl==NIL
	cFajl:="CRC.CRC"
ENDIF
cPom:=FILESTR(cFajl,22)
RETURN { VAL(LEFT(cPom,10)) , VAL(RIGHT(cPom,10)) }



function NapraviCRC(cFajl,n1,n2)
 
 LOCAL nH:=0
  IF cFajl==NIL; cFajl:="CRC.CRC"; ENDIF
  IF FILE( cFajl )
    FERASE( cFajl )
  ENDIF
  nH := FCREATE( cFajl , 0 )
  FWRITE( nH , STR(n1,10) )
  FWRITE( nH , CHR(13)+CHR(10) )
  FWRITE( nH , STR(n2,10) )
  FWRITE( nH , CHR(13)+CHR(10) )
  FCLOSE( nH )
RETURN


function IntegDBF(cBaza)

LOCAL berr, nRec:=RECNO(), nExpr:=0, nExpr2:=0, cStr:="", j:=0
   bErr:=ERRORBLOCK({|o| MyErrH(o)})
   BEGIN SEQUENCE
    //SET AUTOPEN OFF
    IF cBaza!=NIL
      USE (cBaza) NEW
    ENDIF
    GO TOP
    DO WHILE !EOF()
      FOR j:=1 TO FCOUNT()
         IF VALTYPE(FIELDGET(j))=="C"
           cStr:=TRIM(FIELDGET(j))
           nExpr+=len(cStr)
           nExpr2+=NUMAT("A",cStr)
         ENDIF
      NEXT
      SKIP 1
    ENDDO
    IF cBaza!=NIL
      USE
    ELSE
      GO (nRec)
    ENDIF
   RECOVER
      bErr:=ERRORBLOCK(bErr)
      MsgBeep("Ponovite prenos, podaci su osteceni !")
      //SET AUTOPEN ON
      return { 0 , 0 }
   END SEQUENCE
   bErr:=ERRORBLOCK(bErr)
   //SET AUTOPEN ON
RETURN { nExpr , nExpr2 }



