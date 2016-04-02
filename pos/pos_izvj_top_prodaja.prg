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


static function _o_tables()
O_ODJ
O_KASE
O_SIFK
O_SIFV
O_ROBA
O_POS
O_POS_DOKS
return



function pos_top_narudzbe()
local aNiz := {}, cPor, cZaduz, aVrsteP
PRIVATE cIdPos, cRoba:=SPACE(60), dDat0, dDat1, nTop := 10, cSta := "I"
dDat0 := dDat1 := DATE ()

aDbf := {}
AADD (aDbf, {"IdRoba",   "C", 10, 0})
AADD (aDbf, {"Kolicina", "N", 15, 3})
AADD (aDbf, {"Iznos",    "N", 20, 3})
AADD (aDbf, {"Iznos2",    "N", 20, 3})
AADD (aDbf, {"Iznos3",    "N", 20, 3})
NaprPom( aDbf )

select ( F_POM )
if used()
	use
endif

my_use_temp( "POM", my_home() + "pom", .f., .t. )

index on ( idroba ) tag "1"
index on ( STR(iznos,20,3) ) tag "2"
index on ( STR(kolicina,15,3) ) tag "3"

set order to tag "1"

_o_tables()

private cIdPOS := gIdPos
IF gVrstaRS <> "K"
  aNiz := { {"Prodajno mjesto","cIdPos","cidpos='X' .or. Empty(cIdPos).or.P_Kase(@cIdPos)",,} }
ENDIF
AADD (aNiz, {"Roba (prazno-sve)","cRoba",,"@!S30",})
AADD (aNiz, {"Pregled po Iznosu/Kolicini/Oboje (I/K/O)","cSta","cSta$'IKO'","@!",})
AADD (aNiz, {"Izvjestaj se pravi od datuma","dDat0",,,})
AADD (aNiz, {"                   do datuma","dDat1",,,})
AADD (aNiz, {"Koliko artikala ispisati?","nTop","nTop > 0",,})
DO WHILE .t.
  IF !VarEdit(aNiz, 10,5,19,74,;
              'USLOVI ZA IZVJESTAJ "NAJPROMETNIJI ARTIKLI"',;
              "B1")
    CLOSERET
  ENDIF
  aUsl1:=Parsiraj(cRoba,"IdRoba","C")
  if aUsl1<>NIL.and.dDat0<=dDat1
    exit
  elseif aUsl1==NIL
    Msg("Kriterij za robu nije korektno postavljen!")
  else
    Msg("'Datum do' ne smije biti stariji nego 'datum od'!")
  endif
ENDDO // .t.

nTotal := 0

SELECT POS
IF !(aUsl1==".t.")
  set filter to &aUsl1
ENDIF

select pos_doks
set order to tag "2"        
// IdVd+DTOS (Datum)+Smjena

START PRINT CRET
?
ZagFirma()

? PADC ("NAJPROMETNIJI ARTIKLI", 40)
? padc ("-----------------------", 40)
? padc ("NA DAN: "+FormDat1 (gDatum), 40)
?
? PADC ("Za period od "+FormDat1 (dDat0)+ " do "+FormDat1 (dDat1), 40)
?

TopNizvuci (VD_RN, dDat0)
TopNizvuci (VD_PRR, dDat0)

// stampa izvjestaja
SELECT POM
IF cSta $ "IO"
  ?
  ? PADC ("POREDAK PO IZNOSU", 40)
  ?
  ? PADR("ID ROBA", 10), PADR ("Naziv robe", 20), PADC ("Vrijednost",19)
  ? REPL("-", 10), REPL ("-", 20), REPL ("-", 19)
  nCnt := 1
  Set order to tag "2"
  GO BOTTOM
  DO WHILE !BOF() .and. nCnt <= nTop
    select roba
    HSEEK POM->IdRoba
    ? roba->Id, LEFT (roba->Naz, 20), STR (POM->Iznos, 19, 2)
    SELECT POM
    nCnt ++
    SKIP -1
  ENDDO
ENDIF

IF cSta $ "KO"

    SELECT POM
    ?
    ? PADC ("POREDAK PO KOLICINI", 40)
    ?
    ? PADR("ID ROBA", 10), PADR ("Naziv robe", 20), PADC ("Kolicina",15)
    ? REPL("-", 10), REPL ("-", 20), REPL ("-", 15)
    
    nCnt := 1

    set order to tag "3"
    GO BOTTOM

    DO WHILE !BOF() .and. nCnt <= nTop
        select roba
        HSEEK POM->IdRoba
        ? roba->Id, LEFT (roba->Naz, 20), STR (POM->Kolicina, 15, 3)
        SELECT POM
        nCnt ++
        SKIP -1
    ENDDO

ENDIF

?

IF gVrstaRS == "K"
  PaperFeed ()
ENDIF

ENDPRINT

close all
return



/* TopNizvuci(cIdVd,dDat0)
 *     Punjenje pomocne baze realizacijom po robama
 */

function TopNizvuci(cIdVd,dDat0)

select pos_doks
seek cIdVd+DTOS (dDat0)
  
do While !EOF() .and. pos_doks->IdVd==cIdVd .and. pos_doks->Datum <= dDat1
    
    if (!pos_admin() .and. pos_doks->idpos="X") .or. ;
        (pos_doks->IdPos="X" .and. AllTrim(cIdPos)<>"X") .or. ;
        (!Empty(cIdPos) .and. pos_doks->IdPos<>cIdPos)
        skip
        loop
    endif

    SELECT POS
    seek pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)
    
    while !Eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

        select roba
		HSEEK pos->idroba
      	if roba->(FIELDPOS("idodj")) <> 0
			select odj
			HSEEK roba->idodj
		endif
        nNeplaca:=0
        if right(odj->naz,5)=="#1#0#"  // proba!!!
            nNeplaca:=pos->(Kolicina*Cijena)
        elseif right(odj->naz,6)=="#1#50#"
            nNeplaca:=pos->(Kolicina*Cijena)/2
        endif
      
        if gPopVar="P"
            nNeplaca += pos->(kolicina*NCijena)
        endif

      	SELECT POM
        go top
		HSEEK POS->IdRoba
        
        IF !FOUND ()
            APPEND BLANK
            REPLACE IdRoba   WITH POS->IdRoba, ;
                Kolicina WITH POS->Kolicina, ;
                Iznos    WITH POS->Kolicina*POS->Cijena,;
                iznos3   with nNeplaca
            if gPopVar=="P"
                replace iznos2   with pos->ncijena*pos->kolicina
            endif
        ELSE
            REPLACE Kolicina WITH Kolicina+POS->Kolicina, ;
                Iznos WITH Iznos+POS->Kolicina*POS->Cijena,;
                iznos3 with iznos3+nNePlaca
            if gPopVar=="P"
                replace iznos2   with iznos2 + pos->ncijena*pos->kolicina
            endif
        END

        SELECT POS
        SKIP

    EndDO
    select pos_doks
    SKIP

EndDO

return
*}


