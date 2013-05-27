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




#include "kadev.ch"

// ----------------------------------------------
// unos podataka
// ----------------------------------------------
function kadev_data()
private ImeKol := {}
private Kol := {}
private fNovi

//SET EPOCH TO 1910

kadev_o_tables()

ImeKol:={ { 'Prezime', {|| Prezime}     },;
          { 'Ime oca', {|| ImeRod}     },;
          { 'Ime',     {|| Ime}         },;
          { 'RJ',      {|| IdRJ }      },;
          { 'RMJ',     {|| IdRMJ }      },;
          { 'ID-Mat.br', {|| Id}        },;
          { 'Status',    {|| status}     },;
          { 'StrSpr',    {|| idstrspr  }     },;
          { 'RRASP',    {|| idrrasp }     };
          }

for i:=1 to LEN(ImeKol)
	AADD( Kol, i )
next

select kadev_0
set order to tag "2"

go top

cTrPrezime := KADEV_0->PREZIME          
cTrIme     := KADEV_0->IME              
cTrID      := KADEV_0->ID         

ObjDbEdit('bpod',20,76,{|| data_handler() },'<Ctrl-N> Novi, <ENTER> Edit, <Ctrl-T> Brisanje, <R> Rjesenje','<T> Trazi(prezime+ime), <S> Trazi(ID), <P> Pregled promjene')

close all
return


// ---------------------------------------------
// key handler
// ---------------------------------------------
function data_handler()
local nPrOrd:=0
local aNiz:={}
local aPom:={}
local nGetStrana:=0
local nGetTekStrana:=1
local aNezelim:={}

private fNovi:=.f.

if Ch==K_CTRL_N .or. Ch=K_ENTER

	if (deleted() .or. eof() .or. bof()) .and. Ch==K_ENTER
       		return DE_CONT
     	endif

     	if Ch==K_CTRL_N
       		append blank
       		fNovi:=.t.
     	endif
	
     	Scatter()
     	
	if ent_K_0()
                
		Gather()
        	
		fNovi:=.f.
        	RETURN DE_REFRESH
		
     	else
       		
		if fNovi
          		BrisiKarton(.t.)
       		endif
       		
		fnovi:=.f.
       		return DE_REFRESH
		
     endif

elseif Ch == K_CTRL_T
	
	if !( deleted() .or. eof() .or. bof() )
    		
		BrisiKarton()
    		RETURN DE_REFRESH
		
 	endif

elseif Ch==ASC("T") .or. Ch==ASC("t")

    if VarEdit({ {"Prezime","cTrPrezime","","",""},;
                 {"Ime","cTrIme","","",""} },;
                 11,1,16,78,"TRAZENJE RADNIKA","B1")
      
      DO WHILE TB:rowPos>1
      	TB:up()
        DO WHILE !TB:stable
          Tb:stabilize()
        ENDDO
      ENDDO
      nPrOrd:=INDEXORD()
      SET ORDER TO TAG "2"
      SEEK BToE(cTrPrezime+cTrIme)
      DBSETORDER(nPrOrd)
      return DE_REFRESH
    endif

elseif Ch==ASC("S") .or. Ch==ASC("s")

    if VarEdit({ {"ID","cTrID","","",""} },;
                 11,1,15,78,"TRAZENJE RADNIKA","B1")
      DO WHILE TB:rowPos>1
        TB:up()
        DO WHILE !TB:stable
          Tb:stabilize()
        ENDDO
      ENDDO
      nPrOrd:=INDEXORD()
      SET ORDER TO TAG "1"
      SEEK cTrID
      DBSETORDER(nPrOrd)
      return DE_REFRESH
    endif

elseif Ch==ASC("P") .or. Ch==ASC("p")

	nPrArr := SELECT()
  	
	Box("uk0_1", 20, 75, .f.)
  	
	@ m_x+21,m_y+2 SAY "RADNIK: "+TRIM(K_0->prezime)+" "+TRIM(K_0->ime)+", ID: "+TRIM(K_0->id)
  	
	set cursor on
  	
	Scatter()
  	
	get_4( .t. )
  
	Gather()
  	
	BoxC()
  	
	select (nPrArr)

elseif Ch==ASC("R") .or. Ch==ASC("r")

	nPrArr:=SELECT()
  	
	p_rjes()
  	
	IF LASTKEY()==K_ESC
		SELECT (nPrArr)
		RETURN DE_CONT
  	ENDIF
  
	aNiz0:={}
	aNiz:={}
	aPom:={}
	nGetStrana:=0
	nGetTekStrana:=1
  	private cTempVar:=""
	private cTempIzraz:=""
	private nGetP0:=0
	private nGetP1:=0

  	SELECT KDV_DEFRJES
  	SET ORDER TO TAG "3"
  	SEEK KDV_RJES->id

  	DO WHILE !EOF().and.idrjes==KDV_RJES->id
    		IF EMPTY(ID)
			SKIP 1
			LOOP
		ENDIF
    		
		cTempVar:=ALLTRIM(id)
    		cTempIzraz:=ALLTRIM(izraz)
    		ID&cTempVar:=&cTempIzraz
    		IF priun=="0"
     			AADD( aNiz0 , {RTRIM(upit),"ID"+cTempVar,RTRIM(uvalid),RTRIM(upict),IF(obrada=="D",".t.",".f.")} )
     			++nGetP0
    		ELSE
     			AADD( aNiz , {RTRIM(upit),"ID"+cTempVar,RTRIM(uvalid),RTRIM(upict),IF(obrada=="D",".t.",".f.")} )
     			++nGetP1
    		ENDIF
    		SKIP 1	
  	ENDDO
  	
	SET ORDER TO TAG "1"

  	// unos prioritetnih podataka
  	IF nGetP0>0
    		nGetStrana := INT(nGetP0/20)+IF(nGetP0%20>0,1,0)
    		DO WHILE .t.
      			aPom:={}
      			FOR i:=1 TO 20
        			IF i+(nGetTekStrana-1)*20 > LEN(aNiz0)
          				EXIT
        			ELSE
          				AADD( aPom , aNiz0[i+(nGetTekStrana-1)*20] )
        			ENDIF
      			NEXT
      			VarEdit(aPom,1,1,4+LEN(aPom),79,ALLTRIM(KDV_RJES->naz)+","+K_0->(TRIM(prezime)+" "+TRIM(ime))+", STR."+ALLTRIM(STR(nGetTekStrana))+"/"+ALLTRIM(STR(nGetStrana)),"B1")
      			
			IF LASTKEY()==K_PGUP
        			--nGetTekStrana
      			ELSE
        			++nGetTekStrana
      			ENDIF
      			IF nGetTekStrana<1
				nGetTekStrana:=1
			ENDIF
      			IF nGetTekStrana>nGetStrana
				EXIT
			ENDIF
    		ENDDO

    		IF LASTKEY()==K_ESC
      			SELECT (nPrArr)
			RETURN DE_CONT
    		ENDIF
  	ENDIF

  	// ispitivanje unosa i eventualne modifikacije unosa preostalih podataka
  	nVecPostoji:=0
  	IF KDV_RJES->idpromj=="G1"      
		// godisnji odmor
    		SELECT (F_KADEV_1)
    		PushWA()
    		SET ORDER TO TAG "3"
    		SEEK KADEV_0->id+"G1"
    		PRIVATE nImaDana:=0, nIskorDana:=0
    		DO WHILE !EOF() .and. id==KADEV_0->id .and. idpromj=="G1"
      			IF nAtr1 == ID06
				// ID06 je sad za sad godina prava, kao i nAtr1
        			IF nAtr2>0
          				nImaDana:=nAtr2
          				IF FIELDPOS("NATR3")>0
            					nGOKrit1:=nAtr3
            					nGOKrit2:=nAtr4
            					nGOKrit3:=nAtr5
            					nGOKrit4:=nAtr6
            					nGOKrit5:=nAtr7
            					nGOKrit6:=nAtr8
            					nGOKrit7:=nAtr9
          				ENDIF
        			ENDIF
        			nIskorDana += ImaRDana(DatumOd,DatumDo)
        			nVecPostoji++
      			ENDIF
      			SKIP 1
    		ENDDO
    		PRIVATE PREOSTD:=ALLTRIM(STR(nImaDana-nIskorDana))
    		PopWA()
  	ENDIF

  	IF nVecPostoji>1
    		MsgBeep("Vec postoje "+STR(nVecPostoji,2)+" rjesenja!#Za istu godinu moguce je napraviti max.2 rjesenja!#Provjeriti promjene tipa G1!")
    		SELECT (nPrArr)
		RETURN DE_CONT
  	ELSEIF nVecPostoji>0
    		MsgBeep("Vec postoji jedno rjesenje koje definise pravo na godisnji odmor!#Mozete napraviti rjesenje samo za drugi dio godisnjeg odmora.#Ako zelite ponovo definisati pravo, provjerite promjene tipa G1!")
  	ENDIF

  	IF nVecPostoji>0
    		// izbacimo ne§eljene stavke iz aNiz-a
    		aNezelim := { "ID07","ID08","ID09","ID10","ID11","ID12","ID13","ID14","ID15","ID16","ID17","ID18" }
    		FOR i:=1 TO LEN(aNezelim)
      			cPom:=aNezelim[i]       
			// ispraznimo nezeljene
      			&cPom:=BLANK(&cPom)     
			// varijable
      			nPom:=ASCAN(aNiz,{|x| x[2]==aNezelim[i]})
      			IF nPom>0
         			ADEL(aNiz,nPom)
         			ASIZE(aNiz,LEN(aNiz)-1)
         			nGetP1--
      			ENDIF
    		NEXT
    		PRIVATE SAMO2:=".t."
    		// kad vec znam da je ID20 br.dana za 2.dio god.odmora
    		IF !("U" $ TYPE("nGOKrit1"))
      			ID07:=INT(nGOKrit1)
      			ID08:=INT(nGOKrit2)
      			ID09:=INT(nGOKrit3)
      			ID10:=INT(nGOKrit4)
      			ID11:=INT(nGOKrit5)
      			ID12:=INT(nGOKrit6)
      			ID13:=INT(nGOKrit7)
      			ID14:=INT(nImaDana)
    		ENDIF
    		
		ID20:=INT(nImaDana-nIskorDana)
  	ELSE
    		PRIVATE SAMO2:=".f."
  	ENDIF

  	// unos ostalih podataka
  	IF nGetP1>0
    		nGetStrana := INT(nGetP1/20)+IF(nGetP1%20>0,1,0)
    		nGetTekStrana:=1
    		DO WHILE .t.
      			aPom:={}
      			FOR i:=1 TO 20
        			IF i+(nGetTekStrana-1)*20 > LEN(aNiz)
          				EXIT
        			ELSE
          				AADD( aPom , aNiz[i+(nGetTekStrana-1)*20] )
        			ENDIF
      			NEXT
      			VarEdit(aPom,1,1,4+LEN(aPom),79,ALLTRIM(KDV_RJES->naz)+","+K_0->(TRIM(prezime)+" "+TRIM(ime))+", STR."+ALLTRIM(STR(nGetTekStrana))+"/"+ALLTRIM(STR(nGetStrana)),"B1")
      			IF LASTKEY()==K_PGUP
        			--nGetTekStrana
      			ELSE
        			++nGetTekStrana
      			ENDIF
      			IF nGetTekStrana<1
				nGetTekStrana:=1
			ENDIF
      			IF nGetTekStrana>nGetStrana
				EXIT
			ENDIF
    		ENDDO
    		IF LASTKEY()==K_ESC
      			SELECT (nPrArr)
			RETURN DE_CONT
    		ENDIF
  	ENDIF

  	rpt_rjes()

  	IF !EMPTY(KDV_RJES->idpromj) .and. Pitanje(,"Zelite li da se efekat ovog rjesenja evidentira u promjenama? (D/N)","D")=="D"
    		ERUP(aNezelim)
  	ENDIF

  	SELECT (nPrArr)

endif
RETURN DE_CONT


// -----------------------------------------
// stampa rjesenja
// -----------------------------------------
function rpt_rjes()
local aPom:={}
local i
local nLin
local nPocetak
local nPreskociRedova
local cLin
local cPom

START PRINT CRET
gp10cpi()

if EMPTY(KDV_RJES->fajl)
	for i:=1 to gnTMarg
		QOUT()
	next
else
	
	nLin:=BrLinFajla(my_home()+ALLTRIM(KDV_RJES->fajl))
	nPocetak:=0
	nPreskociRedova:=0

	FOR i:=1 TO nLin
		aPom:=SljedLin(my_home()+ALLTRIM(KDV_RJES->fajl),nPocetak)
      		nPocetak:=aPom[2]
      		cLin:=aPom[1]
      	
		IF nPreskociRedova>0
        		--nPreskociRedova
        		LOOP
      		ENDIF
      	
		IF i>1
			?
		ENDIF
      	
		DO WHILE .t.
        		nPom:=AT("#",cLin)
        		IF nPom>0
          			cPom:=SUBSTR(cLin,nPom,4)
          			aPom:=UzmiVar( SUBSTR(cPom,2,2) )
          			?? LEFT(cLin,nPom-1)
          			cLin:=SUBSTR(cLin,nPom+4)
          			
				IF !EMPTY(aPom[1])
            				PrnKod_ON(aPom[1])
         			ENDIF
				
          			IF aPom[1]=="K"  
					// ako evaluacija vrsi i stampu npr.
            				cPom:=&(aPom[2]) 
					// ako je aPom[2]="gPU_ON()"
          			ELSE
            				cPom:=&(aPom[2])
            				?? cPom
          			ENDIF
          			
				IF !EMPTY(aPom[1])
            				PrnKod_OFF(aPom[1])
          			ENDIF
        		ELSE
          			?? cLin
          			EXIT
        		ENDIF
      		ENDDO
	NEXT
endif

FF
END PRINT

return



function UzmiVar(cVar)
local cVrati:={"","''"}

SELECT KDV_DEFRJES
SEEK KDV_RJES->id+cVar
IF FOUND()                           
	cVrati := { tipslova , iizraz }    
	
	// tip slova je string sacinjen od
	// slova U,I i B
	// (U-underline,I-italic,B-bold)
	
ENDIF
return cVrati


function PRNKod_ON(cKod)
 LOCAL i:=0
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_ON()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_ON()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_ON()
    ENDCASE
  NEXT
RETURN (NIL)


FUNCTION PRNKod_OFF(cKod)
 LOCAL i:=0
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_OFF()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_OFF()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_OFF()
    ENDCASE
  NEXT
RETURN (NIL)


function ERUP(aNezelim)
  LOCAL nArr:=SELECT(),cDokument:=""
  PRIVATE cPP:="", cPR:=""
  SELECT KADEV_1
  APPEND BLANK
  Scatter()
   _id      := KADEV_0->id
   _idpromj := KDV_RJES->idpromj
   SELECT KDV_DEFRJES
   SET ORDER TO TAG "2"
   SEEK KDV_RJES->id
   cIPromj:=ipromj
   lImaPodataka:=.f.
   DO WHILE !EOF().and.idrjes==KDV_RJES->id
     IF ASCAN(aNezelim,{|x| RIGHT(x,2)==KDV_DEFRJES->id})>0
       SKIP 1; LOOP
     ENDIF
     IF ipromj<>cIPromj .and. LEN(aNezelim)==0
       cIPromj:=ipromj; SELECT K_1; Gather(); Scatter()
       IF !lImaPodataka; DELETE; ENDIF
       lImaPodataka:=.f.; APPEND BLANK
       SELECT KDV_DEFRJES
     ENDIF
     IF !EMPTY(ppromj)
       cPP:=ALLTRIM(ppromj)
       cPR:="ID"+ALLTRIM(id)
       _&cPP:=&cPR
       IF !EMPTY(&cPR)
         lImaPodataka:=.t.
         IF ALLTRIM(ppromj)=="DOKUMENT"
           cDokument:=_DOKUMENT
         ENDIF
       ENDIF
     ENDIF
     SKIP 1
   ENDDO
   SET ORDER TO TAG "1"
   SELECT KADEV_1
  Gather()
  IF !lImaPodataka; DELETE; ENDIF
  IF !EMPTY(cDokument)
    SELECT KDV_RJES; Scatter(); _zadbrdok:=cDokument; Gather()
  ENDIF
  SELECT (nArr)
RETURN



function ent_K_0()

Box("uk0_1",20,75,.f.)
set cursor on

nStrana:=1

do while .t.

@ m_x+21,m_y+2 SAY "RADNIK: "+TRIM(KADEV_0->prezime)+" "+TRIM(KADEV_0->ime)+", ID: "+TRIM(KADEV_0->id)

@ m_x+1,m_y+1 CLEAR TO m_x+20,m_y+76

if nStrana==1
  nR:=GET_1()
elseif nStrana==2
  nR:=GET_2()
elseif nStrana==3
  nR:=GET_3()
elseif nStrana==4
  nR:=GET_4()
endif

if nR==K_ESC
  exit
elseif nR==K_PGUP
  --nStrana
elseif nR==K_PGDN .or. nR==K_ENTER
  ++nStrana
endif

if nStrana==0
     nStrana++
elseif nStrana==5
     exit
endif

enddo

BoxC()

if lastkey()<>K_ESC
  return .t.
else
  return .f.
endif


// --------------------------------------
// unos prve stranice
// --------------------------------------
function get_1()
@  m_x+1, m_y+2 SAY " 1. Prezime                "  GET _Prezime PICTURE "@!"
@  m_x+3, m_y+2 SAY " 2. Ime jednog roditelja   "  GET _ImeRod PICTURE "@!"
@  m_x+5, m_y+2 SAY " 3. Ime                    "  GET _Ime  PICTURE "@!"
@  m_x+5, COL()+2  SAY " Pol "  GET _Pol  VALID _Pol $ "MZ"  PICTURE "@!"
@  m_x+7 ,m_y+2 SAY " 4. Nacija                 "  GET _idNac  VALID P_Nac(@_idNac,7,40) PICTURE "@!"
@  m_x+9 ,m_y+2 SAY " 5. Jedinstveni mat.broj   "  GET _id  VALID DobarId(@_id) PICTURE "@!"
@  m_x+9 ,COL()+2 SAY " b) ID broj/2  "  GET _id2  VALID DobarId2(@_id2) PICTURE "@!"
@  m_x+11,m_y+2 SAY " 7. Mjesto rodjenja        "  GET _MjRodj  PICTURE "@!"
@  m_x+13,m_y+2 SAY " 8. Datum. rodj "  GET _DatRodj
@  m_x+13,COL()+2 SAY "  9. Broj LK "  GET _BrLK    PICTURE "@!"
@  m_x+15,m_y+2 SAY "10. Adresa stanovanja      "
@  m_x+16,m_y+2 SAY "  a) mjesto                "  GET _MjSt             PICTURE "@!"
@  m_x+17,m_y+2 SAY "  b) mjesna zajednica      "  GET _IdMZSt  Valid P_MZ(@_idMzSt,17,40) PICTURE "@!"
@  m_x+18,m_y+2 SAY "  c) ulica                 "  GET _UlSt   PICTURE "@!"
@  m_x+19,m_y+2 SAY "  d) broj kucnog telefona  "  GET _BrTel1 PICTURE "@!"
read

if !DobarId(_id)
	--nStrana
endif

return LastKey()


// --------------------------------------------
// unos druge stranice
// --------------------------------------------
function get_2()
local aRstE
local aRstB
local aRstU

@  m_x+1, m_y+2 SAY "11. Strucna sprema          " + _IdStrSpr+"-"+P_STRSPR(@_IdStrSpr,-2)
@  m_x+3, m_y+2 SAY "12. Vrsta str.spr.          " + _IdZanim+"-"+P_Zanim(@_Idzanim,-2)
@  m_x+5, m_y+2 SAY "13. R.jedinica RJ " + _IdRj+"-"+P_Kadev_Rj(_IdRj,-2)
@  m_x+7, m_y+2 SAY "14. R.mjesto RMJ  " + _idRMJ+"-"+P_RMJ(_IdRMj,-2)
@  m_x+8, m_y+2 SAY "    Broj bodova   "+STR(Ocitaj(F_KDV_RJRMJ,_IdRj+_IdRMJ,"BODOVA",.t.),7,2)
@  m_x+9, m_y+2 SAY "15. Na radnom mjestu od     " + DTOC(_DatURMJ)
@  m_x+9, m_y+40 SAY "U Firmi od   " + DTOC(_DatUF)
@  m_x+11,m_y+2 SAY "16. Van firme od            " + DTOC(_DatVRMJ)
aRstE:=GMJD(_RadStE); aRstB:=GMJD(_RadStB); aRStU:=ADDGMJD(aRStE,aRStB)
@  m_x+13,m_y+2 SAY "17. Radni staz:      Efekt  " + STR(aRstE[1],2)+"g."+STR(aRstE[2],2)+"m."+STR(aRstE[3],2)+"d."
@  m_x+14,m_y+2 SAY "                     Benef  " + STR(aRstB[1],2)+"g."+STR(aRstB[2],2)+"m."+STR(aRstB[3],2)+"d."
@  m_x+15,m_y+2 SAY "                         ä  " + STR(aRstU[1],2)+"g."+STR(aRstU[2],2)+"m."+STR(aRstU[3],2)+"d."
@  m_x+17,m_y+2 SAY "18. Status ...............  " + _Status
@  m_x+19,m_y+2 SAY "19. broj telefona /2       "  GET _BrTel2 PICTURE "@!"
@  m_x+20,m_y+2 SAY "20. broj telefona /3       "  GET _BrTel3 PICTURE "@!"
read
return LastKey()

// --------------------------------------------
// unos treæe stranice
// --------------------------------------------
function get_3()

aVr:=GMJD(_VrSlVr)

@  m_x+ 1,m_y+2 SAY "21.PORODICA, OPSTI PODACI"
@  m_x+ 3,m_y+2 SAY "  a) Bracno stanje          "  GET _BracSt  PICTURE "@!"
@  m_x+ 4,m_y+2 SAY "  b) Broj djece             "  GET _BrDjece PICTURE "@!"
@  m_x+ 5,m_y+2 SAY "  c) Stambene prilike       "  GET _Stan    PICTURE "@!"
@  m_x+ 6,m_y+2 SAY "  d) Krvna grupa            "  GET _Krv     Valid _Krv $ "   #A+ #A- #B+ #B- #AB+#AB-#0+ #0- #A  #B  #AB #0  "  PICTURE "@!"
@  m_x+ 7,m_y+2 SAY "  e) "+gDodKar1+"       "  GET _idK1    Valid P_K1(@_idK1,7,40)  PICTURE "@!"
@  m_x+ 8,m_y+2 SAY "  f) "+gDodKar2+"       "  GET _idK2    Valid P_K2(@_idK2,8,40)  PICTURE "@!"
@  m_x+ 9,m_y+2 SAY "  g) Karakt. (opisno)..... 1"  GET _KOp1    PICTURE "@!"
@  m_x+10,m_y+2 SAY "  h) Karakt. (opisno)..... 2"  GET _KOp2    PICTURE "@!"

@  m_x+12,m_y+2 SAY "22. ODBRANA"
@  m_x+14,m_y+2 SAY "  a) Ratni raspored        "+_IdRRasp+"-"+P_RRASP(_IdRRasp,-2)
@  m_x+15,m_y+2 SAY "  b) Sluzio vojni rok      "+_SlVR

if _SlVr=="D"
	@  m_x+15,COL()+2 SAY ", u trajanju: "+STR(aVr[1],2)+"g."+STR(aVr[2],2)+"m."+STR(aVr[3],2)+"d."
endif

@  m_x+16,m_y+2 SAY "  c) "+IF(glBezVoj,"Pozn.rada na racunaru","Sposobnost za voj.sl.") GET _SposVSl PICTURE "@!"
@  m_x+17,m_y+2 SAY "  d) Cin       " GET _IdCin VALID P_Cin(@_IdCin,17,30) PICTURE "@!"
@  m_x+18,m_y+2 SAY "  e) "+IF(glBezVoj,"Str.jezici ","VES       ") GET _IdVES VALID P_VES(@_IdVES,18,30) PICTURE "@!"
@  m_x+19,m_y+2 SAY "  f) "+IF(glBezVoj,"Otisli bi iz firme?  ","Sekretarijat odbrane ") GET _NazSekr PICTURE "@!S40"
read

return LastKey()



// ---------------------------------------
// unos èetvrte stranice
// ---------------------------------------
function get_4( lBrzi )
private ImeKol

if lBrzi == NIL
	lBrzi := .f.
endif

if lBrzi
	ImeKol:={ {"Datum ", {|| datumOd} }, ;
          {"Do    ", {|| datumDo} }, ;
          {"Kar.",  {|| IdK}      }, ;
          {"Opis", {|| opis}    } ,;
          {"Dokument",  {|| Dokument}      }, ;
          {"Nadlezan",  {|| Nadlezan}      }, ;
          {"RJ", {|| IdRJ}    } ,;
          {"RMj",{|| IdRMJ}    } ,;
          {"nAtr1",{|| nAtr1}    }, ;
          {"nAtr2",{|| nAtr2}    }, ;
          {"cAtr1",{|| cAtr1}    }, ;
          {"cAtr2",{|| cAtr2}    } ;
        }
  	
	@ m_x,m_y+2  SAY PADC(" TIP PROMJENE: "+gTrPromjena+"-"+TRIM(Ocitaj(F_KDV_PROMJ, gTrPromjena, "naz")) + " ", 70, "Í")

else

	ImeKol:={ {"Datum ", {|| datumOd} }, ;
          {"Do    ", {|| datumDo} }, ;
          {"Promjena", {|| IdPromj+"-"+P_Promj(IdPromj,-2)}      }, ;
          {"Kar.",  {|| IdK}      }, ;
          {"Dokument",  {|| Dokument}      }, ;
          {"Nadlezan",  {|| Nadlezan}      }, ;
          {"Opis", {|| opis}    } ,;
          {"RJ", {|| IdRJ}    } ,;
          {"RMj",{|| IdRMJ}    } ,;
          {"nAtr1",{|| nAtr1}    }, ;
          {"nAtr2",{|| nAtr2}    }, ;
          {"cAtr1",{|| cAtr1}    }, ;
          {"cAtr2",{|| cAtr2}    } ;
        }
endif

cID := kadev_0->id

select kadev_1
 
if lBrzi
	set order to tag "3"
else
   	set order to tag "1"
endif

cOldH := h[1]

h[1] := "Lista promjena "

CentrTxt( h[1], 24 )

@ m_x+1,m_y+2  SAY "23. Promjene - <Ctrl-End> Kraj pregleda, <Strelice> setanje kroz listu"
@ m_x+2,m_y+2  SAY "               <Ctrl-N> Novi zapis, <Ctrl-T> brisanje, <ENTER> edit"
@ m_x+3,m_y+2  SAY "               <Alt-K> Zatvaranje intervalne promjene"

BrowseKey( m_x + 5, m_y + 2, m_x + 16, m_y + 68, ImeKol, {|Ch| EdPromj(Ch)}, IF(lBrzi, "id+idpromj == cID+gTrPromjena" , "id==cID" ), cId, 2, 4, 60)

h[1] := cOldH

@ m_x+17,m_y+2 SAY "24. Operater " GET _operater PICTURE "@!"

read

if !lBrzi
	@ m_x+19,m_y+2 SAY "  ----  <PgUp> Prethodna strana, <PgDn> snimi, <ESC> otkazi promjene --- "
  	Inkey(0)
endif

set relation to
select kadev_0

return lastkey()



// --------------------------------------
// edit promjena
// --------------------------------------
function EdPromj(ch)
local lPom:=.f.

do case

	case Ch==K_ENTER .or. Ch=K_CTRL_N

     		if EOF() .and. Ch==K_ENTER
      			return DE_CONT
     		endif

     		if Ch==K_CTRL_N
       			append blank
       			replace id with cId
     		endif

     		SCATTER("q")

     		Box("btxt",12+IF(!("U" $ TYPE("qnAtr3")),7,0),60,.f.,"<Esc> otkazi operaciju")
     		set cursor on

     		@ m_x + 1, m_y + 2 SAY "Datum         " GET qdatumOd
     		@ m_x + 3, m_y + 2 SAY "Tip promjene  " GET qIdPromj;
			VALID P_Promj(@qIdPromj,3,40) PICTURE "@!"
     		@ m_x + 4, m_y + 2 SAY "Karakteristika" GET qIdK PICT "@!"
     		
		read

     		if qIdPromj == "G1"     
			// godisnji odmor
       			@ m_x+6, m_y+2 SAY "Koristi pravo na godisnji odmor za godinu   :"  GET qnAtr1 PICT "9999"
       			@ m_x+7, m_y+2 SAY "Broj dana godisnjeg odmora na koji ima pravo:"  GET qnAtr2  PICT "9999"
       			
			IF !("U" $ TYPE("qnAtr3"))
          			@ m_x+ 8,m_y+2 SAY "Zakonski minimum                         :"  GET qnAtr3  PICTURE "999"
          			@ m_x+ 9,m_y+2 SAY "Po osnovu vrste poslova i zadataka       :"  GET qnAtr4  PICTURE "999"
          			@ m_x+10,m_y+2 SAY "Po osnovu slozenosti poslova i zadataka  :"  GET qnAtr5  PICTURE "999"
          			@ m_x+11,m_y+2 SAY "Po osnovu duzine radnog staza            :"  GET qnAtr6  PICTURE "999"
          			@ m_x+12,m_y+2 SAY "Po osnovu uslova pod kojim radnik zivi   :"  GET qnAtr7  PICTURE "999"
          			@ m_x+13,m_y+2 SAY "Po osnovu zdravstvenog stanja radnika    :"  GET qnAtr8  PICTURE "999"
          			@ m_x+14,m_y+2 SAY "Umanjenje preko 30 dana                  :"  GET qnAtr9  PICTURE "999"
       			ENDIF
     		endif

     		if qDatumOd >= _DatURMJ 
			// ako se ubacuje stara promjena ovaj uslov
      			qIdRJ := _IdRJ   
			// nije zadovoljen
      			qIdRMJ := _IdRmj
     		endif

     		if P_Promj(qIdPromj, -6 ) == "1"  
			// srj = "1" ako se mijenja promjenom radno mjesto
      			
			@ m_x+6, m_y+2 SAY "RJ" GET qIdRj PICT "@!"
			@ m_x+6, col()+2 SAY "RMJ" GET qIdRmj VALID EVAL({|| lPom := P_RJRMJ(@qIdRj,@qIdRmj), SETPOS(m_x+7,m_y+3), QQOUT(Ocitaj(F_RJ,qIdRj,1)),SETPOS(m_x+8,m_y+3),QQOUT(Ocitaj(F_RMJ,qIdRmj,1)),lPom}) PICTURE "@!"
     		endif

     		if (cTipPromj := P_PROMJ(qIdPromj, -4)) == "X" ;
			.and. P_Promj(qIdPromj, -7) $ "+-*A=" 
				// -7 = URst
        		// znaci da se setuje Radni staz
       			aRe:=GMJD(nAtr1); aRb:=GMJD(nAtr2)
       			nGE:=aRe[1];nME:=aRe[2];nDe:=aRe[3]
       			nGB:=aRb[1];nMb:=aRb[2];nDb:=aRb[3]
       			@ m_x+6,m_y+2  SAY "Radni staz '"+cTipPromj +"'"
       			@ m_x+7,m_y+2  SAY "Efektivan G." GET nGE PICTURE "99"
       			@ m_x+7,COL() SAY " Mj." GET nME  PICTURE "99"
       			@ m_x+7,COL() SAY " D." GET nDE  PICTURE "99"
      			@ m_x+7,COL() SAY "    Benef. G." GET nGB  PICTURE "99"
       			@ m_x+7,COL() SAY " Mj." GET nMB PICTURE "99"
       			@ m_x+7,COL() SAY " D." GET nDB PICTURE "99"
      			read
       			qnAtr1:=nGE*365.125+nME*30.41+nDE
       			qnAtr2:=nGB*365.125+nMB*30.41+nDB
     		endif

     		if P_PROMJ(qIdPromj,-8) == "1" 
			// u Ratni raspored
       			cRRasp:=LEFT(qcAtr1,4)
       			@ m_x+6,m_y+2 SAY "Ratni raspored "  GET cRRasp VALID P_RRasp(@cRRasp,7,2)  PICTURE "@!"
       			read
       			qcAtr1:=cRRasp
     		endif

     		if P_PROMJ(qIdPromj,-9) == "1" 
			// u strucnu spremu
       			cStrSpr:=LEFT(qcAtr1,3)
       			cVStrSpr:=LEFT(qcAtr2,4)
       			@ m_x+6,m_y+2 SAY "Stepen str.spr"  GET cStrSpr VALID  P_StrSpr(@cStrSpr)  PICTURE "@!"
       			@ m_x+7,m_y+2 SAY " Vrsta str.spr"  GET cVStrSpr VALID P_Zanim(@cVStrSpr)  PICTURE "@!"
       			read
       			qcAtr1:=cStrSpr
       			qcAtr2:=cVstrSpr
     		endif
	
     		@ m_x+ 9+IF(!("U" $ TYPE("qnAtr3")),7,0),m_y+2 SAY "Dokument  " GET qDokument PICTURE "@!"
     		@ m_x+10+IF(!("U" $ TYPE("qnAtr3")),7,0),m_y+2 SAY "Opis      " GET qOpis     PICTURE "@!"
     		@ m_x+12+IF(!("U" $ TYPE("qnAtr3")),7,0),m_y+2 SAY "Nadlezan  " GET qNadlezan PICTURE "@!"
     		
		read
     		
		BoxC()

     		if lastkey()<>K_ESC
        		Gather("q")
        		if (Ch==K_CTRL_N .and. Pitanje("p09","Zelite li azurirati ovu promjenu ?","D")=="D") .or. (Ch==K_ENTER .and. Pitanje("p10","Zelite li ponovo azurirati ovu promjenu ?","N")=="D")

           			if P_PROMJ(qIDPromj,-4) <> "X" 
					// Tip X - samo postavlja odre|ene parametre
            				_status:=P_PROMJ(qIdPromj,-5)
           			endif

           			if P_PROMJ(qIdPromj,-6)=="1"  // SRMJ=="1" - promjena radnog mjesta
               				_idRj:=qIdRj
               				_idRMJ:=qIdRMJ
               				_DatURMJ:=qDatumOd
               				if empty(_datuf)
                				_DatUF:=qDatumOd
               				endif
               				_DatVRmj:=CTOD("")
           			endif

           			if P_PROMJ(qIdPromj,-4)=="I"  
					// intervalna promjena
               				_DatVRMJ:=qDatumOd
               				replace DatumDo with CTOD("") 
					// "otvori promjenu !"
           			endif

           			if P_PROMJ(qIDPromj,-8)=="1"   
	   				// uRRasp = 1
              				_IdRRasp:=qcAtr1
           			endif

           			if P_PROMJ(qIDPromj,-9)=="1"    // uStrSpr = 1
              				_IdStrSpr:=qcAtr1
              				_IdZanim:=qcAtr2
           			endif

        		endif
        		
			return DE_REFRESH
     		else
        		if Ch==K_CTRL_N
            			delete
            			skip -1
        		endif
        		
			return DE_REFRESH
     		endif
	case Ch=K_CTRL_T
     		if Pitanje("p08","Sigurno zelite izbrisati ovu promjenu ???","N")=="D"
      			delete
			skip -1
      			return DE_REFRESH
     		else
      			return DE_CONT
     		endif

  	case Ch==K_CTRL_END
     		return DE_ABORT
	case Ch==K_ALT_K
     		if P_PROMJ(IdPromj,-4)="I" .and. empty(DatumDo) 
			// intervalna promjena
        		dPom:=DATE()
        		Box("bzatv",3,40,.f.)
        		set cursor on
        		@ m_x+1,m_y+1 SAY "Datum zatvaranja:" GET dPom VALID dPom>=DatumOd
        		read
        		BoxC()
        		if lastkey()<>K_ESC
          			_Status:="A" 
				// zatvaranje promjene
          			_DatVRMJ:=CTOD("")
          			replace DatumDo with dPom
          			if P_PROMJ(IDPromj,-8)=="1"
            				_IdRRasp:=""
          			endif

          			if P_PROMJ(IdPromj,-5)="M" .and.;
					P_RRASP(left(cAtr1,4),-4)="V" 
					// sluzenje vojnog roka
             				_SlVr:="D"
             				_VrSlVr+=DatumDo-DatumOd
             				_IdRRasp:=""
          			endif
        		endif
      		else
        		Msg("Promjena mora biti nezatvorena, intervalnog tipa",5)
      		endif
      		return DE_REFRESH
  	otherwise
     		return DE_CONT
endcase

return



function DobarId(noviId)

if empty(noviId)
   MsgO("ID broj ne moze biti prazan!")
   Inkey(0)
   MsgC()
   return .f.
endif

nRec:=RECNO()
nOrd:=INDEXORD()
set order to tag "1"
seek noviId

if found() .and. recno()<>nRec
  MsgO("Vec postoji zapis sa ovim ID brojem. Ispravite to !")
  Inkey(0)
  MsgC()
  dbsetorder(nOrd)
  go nRec
  noviId=kadev_0->id
  return .f.
endif

dbsetorder(nOrd)
go nRec

if noviId<>kadev_0->id

  if !empty(kadev_0->id) .and. !(KLevel $ "01")
     Msg("Vi ne mozete mijenjati postojece podatke !",15)
     noviId:=k_0->id
     return .t.
  endif

  if empty(kadev_0->id) .or. Pitanje("p01","Promijenili ste ID broj. Zelite li ovo snimiti (D/N) ?"," ")=="D"

        select kadev_1
        set order to tag "1"
        seek kadev_0->id
        do while kadev_0->id==id .and. !eof()
          skip; nSRec:=RECNO()
          skip -1; replace id with noviId
          go nSRec
        enddo

        select kadev_0
        replace id with noviId
   else
        noviId=kadev_0->id
   endif
endif

return .t.



function DobarId2(noviId2)

if !empty(noviId2)  // dozvoljeno je da je noviId2 prazan
nRec:=RECNO()
nOrd:=INDEXORD()
set order to tag "3"
seek noviId2
if found() .and. recno()<>nRec
  MsgO("Vec postoji zapis sa ovim ID2 brojem. Ispravite to !")
  Inkey(0)
  MsgC()
  dbsetorder(nOrd)
  go nRec
  noviId2=kadev_0->id2
  return .f.
endif

dbsetorder(nOrd)
go nRec
endif 
return .t.



// ---------------------------------------------------------
// brisanje osnovnog i njemu pridruzenih slogova
// ---------------------------------------------------------
function BrisiKarton(fDa)

 if fDa==NIL
   fDa=.f.
 endif

 if fDa .or. Pitanje("p02","Izbrisati karton: "+id+" (D/N) ?","N")=="D"
   MsgO("Brisem pridruzene zapise")
   select kadev_1
   set order to tag "1"
   seek kadev_0->id
   do while kadev_0->id==id .and. !eof()
     skip; nRec:=recno(); skip -1
     delete
     go nRec
   enddo


   select kadev_0
   delete; skip -1
   MsgC()

 endif





