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

#include "f18.ch"

static __par_len


// ----------------------------------------------
// pregled promjena na racunu
// ----------------------------------------------
function PrPromRn()
qqIDVN  := "I1;I2;"
qqKonto := "2000;"
dOd     := dDo := DATE()
cNazivFirme := gNFirma

private picBHD:=FormPicL(gPicBHD,16)
private picDEM:=FormPicL(gPicDEM,12)

O_PARAMS
Private cSection:="o",cHistory:=" ",aHistory:={}
RPar("q1",@qqIDVN)
RPar("q2",@qqKonto)
RPar("q3",@dOd)
RPar("q4",@dDo)
RPar("q5",@cNazivFirme)
SELECT PARAMS; USE

qqIDVN      := PADR( qqIDVN      , 60 )
qqKonto     := PADR( qqKonto     , 60 )
cNazivFirme := PADR( cNazivFirme , 60 )

Box("#PREGLED PROMJENA NA RACUNU",8,75)
 DO WHILE .t.
   @ m_x+2, m_y+2 SAY "Vrste naloga za knjizenje izvoda:" GET qqIDVN  PICT "@S20"
   @ m_x+3, m_y+2 SAY "Konto/konta ziro racuna         :" GET qqKonto PICT "@S20"
   @ m_x+4, m_y+2 SAY "Period od datuma:" GET dOd
   @ m_x+4, col()+2 SAY "do datuma:" GET dDo
   @ m_x+5, m_y+2 SAY "Puni naziv firme:" GET cNazivFirme PICT "@S35"
   READ; ESC_BCR
   aUsl1 := Parsiraj( qqIDVN, "IDVN" )
   aUsl2 := Parsiraj( qqKonto, "IDKONTO" )
   IF aUsl1<>NIL .and. aUsl2<>NIL; EXIT; ENDIF
 ENDDO
BoxC()

qqIDVN      := TRIM( qqIDVN      )
qqKonto     := TRIM( qqKonto     )
cNazivFirme := TRIM( cNazivFirme )

O_PARAMS
Private cSection:="o",cHistory:=" ",aHistory:={}
WPar("q1",qqIDVN)
WPar("q2",qqKonto)
WPar("q3",dOd)
WPar("q4",dDo)
WPar("q5",cNazivFirme)
SELECT PARAMS; USE

O_KONTO
O_PARTN
O_SUBAN

__par_len := LEN(partn->id)

// SET ORDER TO TAG "5"
// idFirma+IdKonto+dtos(DatDok)+idpartner

cFilter := aUsl1
IF !EMPTY(dOd); cFilter += ( ".and. DATDOK>=" + cm2str(dOd) ); ENDIF
IF !EMPTY(dDo); cFilter += ( ".and. DATDOK<=" + cm2str(dDo) ); ENDIF

cSort := "dtos(datdok)"
INDEX ON &cSort TO "SUBTMP" FOR &cFilter
// SET FILTER TO &cFilter

nDug:=0
nPot:=0

m := "------ -------- " + REPL("-", __par_len) + " "+REPL("-",40)+" "+REPL("-",16)
z := "R.BR. * DATUM  *" + PADC("PARTN.", __par_len) + "*"+PADC("NAZIV PARTNERA ILI OPIS PROMJENE",40)+"*"+PADC("UPLATA KM",16)

START PRINT CRET
nStranica := 0
ZagPPR("U")

nCnt := 0

GO TOP
DO WHILE !EOF()
  
  IF prow()>60+gPstranica
     FF
     ZagPPR("U")
  ENDIF
  
  IF &aUsl2
    SKIP 1
    LOOP
  ENDIF
  
  IF d_p=="2"
    ? STR(++nCnt, 6), RedIspisa()
    nPot += iznosbhd
  ENDIF
  
  SKIP

ENDDO

? m
? "UKUPNO UPLATE"+PADL(TRANSFORM(nPot,picbhd),67)
? m

?

IF prow()>60+gPstranica
   FF
   ZagPPR("I")
ELSE
   ? "PREGLED ISPLATA:"
   ? m; ? z; ? m
ENDIF

nCnt := 0

GO TOP
DO WHILE !EOF()
  
  IF prow()>60+gPstranica
     FF
     ZagPPR("I")
  ENDIF
  
  IF &aUsl2
    SKIP 1
    LOOP
  ENDIF
  
  IF d_p == "1"
    ? STR(++nCnt, 6), RedIspisa()
    nDug += iznosbhd
  ENDIF
  
  SKIP

ENDDO

? m
? "UKUPNO ISPLATE"+PADL(TRANSFORM(nDug,picbhd),66)
? m

FF
END PRINT

CLOSERET
return



/*! \fn RedIspisa()
 *  \brief
 */
 
function RedIspisa()
LOCAL cVrati:=""
  cVrati := DTOC(datdok)+" "+idpartner+" "
  IF EMPTY(idpartner)
    cVrati += PADR( opis , 40 )
  ELSE
    cVrati += PADR( Ocitaj(F_PARTN,idpartner,"naz") , 40 )
  ENDIF
  cVrati += ( " " + TRANSFORM(iznosbhd,picbhd) )
RETURN cVrati



/*! \fn ZagPPR(cI)
 *  \brief Zaglavlje pregleda promjena na racunu
 *  \param cI
 */
function ZagPPR(cI)

? cNazivFirme
  ? PADL("Str."+ALLTRIM(STR(++nStranica)),80)
  ? PADC( StrKZN("PREGLED PROMJENA NA RA�UNU","8",gKodnaS) , 80 )
  ? PADC( "ZA PERIOD "+DTOC(dOd)+" - "+DTOC(dDo) , 80 )
  ?
  IF cI=="U"
    ? "PREGLED UPLATA:"
  ELSE
    ? "PREGLED ISPLATA:"
  ENDIF
  ? m; ? z; ? m
RETURN


