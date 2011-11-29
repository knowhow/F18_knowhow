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


// -----------------------------------------------
// pregled / stampa azuriranih dokumenata 
// -----------------------------------------------
function fakt_stampa_liste_dok()
local nCol1:=0
local nul,nizl,nRbr
local m
private cImekup,cidfirma,qqTipDok,cBrFakDok,qqPartn

private ddatod,ddatdo

private lVrsteP := ( IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D" )
private lOpcine := .t.

if lVrsteP
 	O_VRSTEP
endif

IF lOpcine
  	O_OPS
ENDIF

if glRadNal
	O_RNAL
endif

O_FAKT
O_PARTN
O_FAKT_DOKS

if lVrsteP
  	SET RELATION TO idvrstep INTO VRSTEP
endif

if lOpcine
  	SET RELATION TO idpartner INTO PARTN
endif

if glRadNal
	SET RELATION TO idfirma+idtipdok+brdok INTO FAKT
endif

if PrazanDBF()
  Beep(1)
  O_VALUTE
  O_FAKT

  select fakt
  go top

  do while !eof()
    select fakt_doks
    append blank
    select fakt

    cIDFirma:=idfirma
    private cBrDok:=BrDok,cIdTipDok:=IdTipDok,dDatDok:=datdok
    aMemo:=ParsMemo(txt)
    if len(aMemo)>=5
      cTxt:=trim(amemo[3])+" "+trim(amemo[4])+","+trim(amemo[5])
    else
      cTxt:=""
    endif
    cTxt:=padr(cTxt,30)

    nDug:=nRab:=0
    nDugD:=nRabD:=0
    cDinDem:=dindem
    cRezerv:=" "
    if cidtipdok $ "10#20#27" .and. left(Serbr,1)=="*"
      cRezerv:="*"
    endif
    select fakt_doks
    replace idfirma with cidfirma, brdok with cbrdok,;
            rezerv with cRezerv, datdok with ddatdok, idtipdok with cidtipdok,;
            partner with cTxt, dindem with cdindem, ;
            IdPartner with FAKT->IdPartner
    IF lVrsteP
      REPLACE idvrstep WITH FAKT->idvrstep
    ENDIF
    IF FIELDPOS("DATPL")>0
      REPLACE datpl WITH IF(LEN(aMemo)>=9,CTOD(aMemo[9]),CTOD(""))
    ENDIF
    select fakt

    do while !eof() .and. cIdFirma==IdFirma .and. cIdTipdok==IdTipDok .and. cBrDok==BrDok
      if cdindem==left(ValBazna(),3)
        nDug+=ROUND( kolicina*Cijena*(1-Rabat/100)*(1+Porez/100) ,ZAOKRUZENJE)
        nRab+=ROUND( kolicina*Cijena*Rabat/100 ,ZAOKRUZENJE)

      else
        nDugD+=round( kolicina*Cijena*1/UBaznuValutu(datdok)*(1-Rabat/100)*(1+Porez/100) ,ZAOKRUZENJE)
        nRabD+=round( kolicina*Cijena*Rabat/100*1/UBaznuValutu(datdok),ZAOKRUZENJE)
      endif
      skip
    enddo

    select fakt_doks
    if cDinDem==left(ValBazna(),3)
      replace iznos with nDug
      replace rabat with nRab
    else
      replace iznos with nDugD
      replace rabat with nRabD
    endif
    replace DINDEM with cDinDEM
    select fakt

  enddo

  select valute; use
  select fakt; use
endif
// generacija izvjestaja

O_VALUTE
O_RJ

qqVrsteP := SPACE(20)
dDatVal0 := dDatVal1 := CTOD("")

cIdfirma := gFirma
dDatOd := ctod("")
dDatDo := date()
qqTipDok := ""
qqPartn := space(20)
cTabela := "N"
cBrFakDok := SPACE(40)
cImeKup := space(20)
cOpcina := SPACE(30)

if glRadNal
	cRadniNalog := SPACE(10)
endif

Box( , 12 + IF( lVrsteP .or. lOpcine .or. glRadNal, 6, 0 ), 77 )

f18_get_metric("StampaListeIdFirma", @cIdFirma, .t. )
f18_get_metric("StampaListeDokumenti", @qqTipDok, .t. )
f18_get_metric("StampaListeDatumOd", @dDatOd, .t. )
f18_get_metric("StampaListeDatumDo", @dDatDo, .t. )
f18_get_metric("StampaListeTabelarniPregled", @cTabela, .t. )
f18_get_metric("StampaListeImeKupca", @cImeKup, .t. )
f18_get_metric("StampaListePartner", @qqPartn, .t. )
f18_get_metric("StampaListeBrojDokumenta", @cBrFakDok, .t. )

cImeKup := padr(cImeKup,20)
qqPartn := padr(qqPartn,20)
qqTipDok := padr(qqTipDok,2)

do while .t.
 if gNW$"DR"
   cIdFirma:=padr(cidfirma,2)
   @ m_x+1,m_y+2 SAY "RJ prazno svi" GET cIdFirma valid {|| empty(cidfirma) .or. cidfirma==gfirma .or. P_RJ(@cIdFirma) }
   read
 else
   @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 if !empty(cidfirma)
    @ m_x+2,m_y+2 SAY "Tip dokumenta (prazno svi tipovi)" GET qqTipDok pict "@!"
    qqtipdok:="  "
 else
    cIdfirma:=""
    qqtipdok:="  "
 endif
 @ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
 @ m_x+3,col()+1 SAY "do"  get dDatDo
 @ m_x+5,m_y+2 SAY "Ime kupca pocinje sa (prazno svi)"  get cImeKup pict "@!"
 @ m_x+6,m_y+2 SAY "Uslov po sifri kupca (prazno svi)"  get qqPartn pict "@!" ;
    valid {|| aUslSK:=Parsiraj(@qqPartn,"IDPARTNER","C",NIL,F_PARTN), .t.}
 @ m_x+7,m_y+2 SAY "Broj dokumenta (prazno svi)"  get cBrFakDok pict "@!"
 @ m_x+9,m_y+2 SAY "Tabelarni pregled"  get cTabela valid cTabela $ "DN" pict "@!"
 cRTarifa:="N"
 @ m_x+11,m_y+2 SAY "Rekapitulacija po tarifama ?"  get cRTarifa valid cRtarifa $"DN" pict "@!"
 IF lVrsteP
   @ m_x+12,m_y+2 SAY "----------------------------------------"
   @ m_x+13,m_y+2 SAY "Za fakture (Tip dok.10):"
   @ m_x+14,m_y+2 SAY "Nacin placanja:" GET qqVrsteP
   @ m_x+15,m_y+2 SAY "Datum valutiranja od" GET dDatVal0
   @ m_x+15,col()+2 SAY "do" GET dDatVal1
   @ m_x+16,m_y+2 SAY "----------------------------------------"
 ENDIF
 @ m_x+17,m_y+2 SAY "Opcina (prazno-sve): "  get cOpcina
 if glRadNal
   @ m_x+18,m_y+2 SAY "Radni nalog (prazno-svi): "  get cRadniNalog valid EMPTY(cRadniNalog) .or. P_RNal(@cRadniNalog)
 endif
 
 read

 ESC_BCR

 aUslBFD := Parsiraj(cBrFakDok,"BRDOK","C")
 aUslSK := Parsiraj(qqPartn,"IDPARTNER","C")
 aUslVrsteP := Parsiraj(qqVrsteP,"IDVRSTEP","C")
 aUslOpc := Parsiraj(cOpcina,"IDOPS","C")
 if glRadNal
 	//aUslRadNal:=
 endif
 if (!lOpcine .or. aUslOpc <> NIL) .and. aUslBFD<>NIL .and. aUslSK<>NIL .and. (!lVrsteP.or.aUslVrsteP<>NIL)
 	exit
 endif
enddo

qqTipDok := trim(qqTipDok)
qqPartn := trim(qqPartn)

f18_set_metric("StampaListeIdFirma", cIdFirma, .t. )
f18_set_metric("StampaListeDokumenti", qqTipDok, .t. )
f18_set_metric("StampaListeDatumOd", dDatOd, .t. )
f18_set_metric("StampaListeDatumDo", dDatDo, .t. )
f18_set_metric("StampaListeTabelarniPregled", cTabela, .t. )
f18_set_metric("StampaListeImeKupca", cImeKup, .t. )
f18_set_metric("StampaListePartner", qqPartn, .t. )
f18_set_metric("StampaListeBrojDokumenta", cBrFakDok, .t. )

BoxC()

select fakt_doks
set order to tag "1"
go top

Private cFilter:=".t."

IF !EMPTY(dDatVal0) .or. !EMPTY(dDatVal1)
  cFilter+=".and. (!idtipdok='10'.or.datpl>="+cm2str(dDatVal0)+".and. datpl<="+cm2str(dDatVal1)+")"
ENDIF

IF !EMPTY(qqVrsteP)
  cFilter += ".and. (!idtipdok='10'.or."+aUslVrsteP+")"
ENDIF

if !empty(qqTipDok)
   cFilter+=".and. idtipdok=="+cm2str(qqTipDok)
endif
if !empty(dDatOd) .or. !empty(dDatDo)
  cFilter+=".and.  datdok>="+cm2str(dDatOd)+".and. datdok<="+cm2str(dDatDo)
endif

if cTabela=="D"  // tabel prikaz

  if !empty(cimekup)
    cFilter+=".and. partner="+cm2str(trim(cImeKup))
  endif

  cFilter+=".and. IdFirma="+cm2str(cIdFirma)

  cFilter+=".and. PARTN->("+aUslOpc+")"

endif

// ako je rijec o radnim nalozima postavi filter u tabeli FAKT na polje idrnal
if glRadNal .and. !Empty(cRadniNalog)
  	cFilter+=".and. FAKT->idrnal="+Cm2Str(cRadniNalog)
endif

if !empty(cBrFakDok)
  cFilter+=".and."+aUslBFD
endif

if !empty(qqPartn)
  cFilter+=".and."+aUslSK
endif


if cFilter=".t..and."
  cFilter:=substr(cFilter,9)
endif

if cFilter==".t."
  set Filter to
else
  set Filter to &cFilter
endif

@ 22,77 SAY str(rloptlevel(),2)

qqTipDok := trim(qqTipDok)

seek cIdFirma + qqTipDok

EOF CRET

if cTabela == "D"

   ImeKol:={}
   
   if FIELDPOS("FISC_RN")>0
     AADD(ImeKol,{ " ", {|| g_fiscal_info(fisc_rn)} })
   endif

   AADD(ImeKol,{ "RJ",       {|| idfirma}  })
   AADD(ImeKol,{ "VD",       {|| idtipdok} })
   AADD(ImeKol,{ "Brdok",    {|| brdok+rezerv} })
   AADD(ImeKol,{ "VP",       {|| idvrstep } })
   AADD(ImeKol,{ "Datum",    {|| Datdok } })
   AADD(ImeKol,{ "Partner",  ;
      {|| PADR( iif(m1="Z","<<dok u pripremi>>",partner),28) } })
   AADD(ImeKol,{ "Ukupno-Rab ",    {|| iznos} })
   AADD(ImeKol,{ "Rabat",    {|| rabat} })
   AADD(ImeKol,{ "Ukupno",    {|| iznos+rabat} })
   
   IF lVrsteP
     AADD(ImeKol,{ "Nacin placanja", {|| idvrstep} })
   ENDIF
   
   IF FIELDPOS("DATPL")>0
     AADD(ImeKol,{ "Datum placanja", {|| datpl} })
   ENDIF

   
   if FIELDPOS("DOK_VEZA") <> 0
     AADD(ImeKol,{ "Vezni dokumenti", ;
     	{|| PADR( ALLTRIM( g_d_veza(idfirma,idtipdok,brdok,dok_veza)) , ;
		60) + "..." }})
   endif

   // datum otpremnice, datum isporuke
   if FIELDPOS("DAT_OTPR") <> 0
     AADD(ImeKol,{ "Dat.otpr", {|| dat_otpr} })
     AADD(ImeKol,{ "Dat.val.", {|| dat_val} })
   endif
   
   // prikaz operatera
   IF FIELDPOS("oper_id")>0
     AADD(ImeKol,{ "Operater", {|| oper_id} })
   ENDIF

   Kol:={}; for i:=1 to len(ImeKol); AADD(Kol,i); next
   Box(,21,72)

   @ m_x+18,m_y+2 SAY " <ENTER> Stampa dokumenta        ³ <P> Povrat dokumenta u pripremu    ³"
   @ m_x+19,m_y+2 SAY " <N>     Stampa narudzbenice     ³ <B> Stampa radnog naloga           ³ "
   @ m_x+20,m_y+2 SAY " <S>     Storno dokument         ³ <R> Rezervacija/Realizacija        ³"
   @ m_x+21,m_y+2 SAY " <R>  Stampa fiskalnog racuna    ³ <F> otpremnica -> faktura          ³"
   fUPripremu:=.f.

   adImeKol:={}

   private  bGoreRed:=NIL
   private  bDoleRed:=NIL
   private  bDodajRed:=NIL
   private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
   private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
   private  TBAppend:="N"  // mogu dodavati slogove
   private  bZaglavlje:=NIL
           // zaglavlje se edituje kada je kursor u prvoj koloni
           // prvog reda
   private  TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
   private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
   private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
   private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                           // ovo se mo§e setovati u when/valid fjama

   private  TBScatter:="N"  // uzmi samo teku†e polje
   for i:=1 TO LEN(ImeKol); AADD(adImeKol,ImeKol[i]); next
   ASIZE(adImeKol,LEN(adImeKol)+1)
   AINS(adImeKol,6)
   adImeKol[6] := { "ID PARTNER" , {|| idpartner}, "idpartner", ;
                   {|| .t.}, {|| P_Firma(@widpartner)}, "V" }
   adKol:={}; for i:=1 to len(adImeKol); AADD(adKol,i); next

   ObjDbedit("",19,72,{|| EdDatn()},"","", , , ,{ || if(gFC_use == "D", .f., .f. ) } ,2)
   BoxC()
   if fupripremu
     close all
     fakt_unos_dokumenta()
   endif
   closeret
endif

gaZagFix:={3,3}
START PRINT CRET DOCNAME "FAKT_stampa_dokumenata_na_dan_"+DTOC(date())
?
P_COND
?? space(gnLMarg)
?? "FAKT: Stampa dokumenata na dan:", date(), space(10), "za period",dDatOd,"-",dDatDo
?
? space(gnLMarg)
IspisFirme(cidfirma)
if !empty(qqTipDok)
	?? SPACE(2), "za tipove dokumenta:",trim(qqTipDok)
endif
if glRadNal .and. !Empty(cRadniNalog)
	?? SPACE(2), "uslov po radnom nalogu: ", TRIM(cRadniNalog)
	? GetNameRNal(cRadniNalog)
endif

m:="----- -------- -- -- --------- ------------------------------ ------------ ------------ ------------ ------------ ------------ ------------ ---"

if fieldpos("SIFRA")<>0
	m+=" --"
endif

if lVrsteP
  	m+=" -------"
endif

if fieldpos("DATPL")<>0
  	m+=" --------"
endif

P_COND2
? space(gnLMarg)
?? m
? space(gnLMarg)

?? "  Rbr Dat.Dok  RJ TD Br.Dok   Partner                            Ukupno       Rabat         UKUPNO     OSNOVICA       PDV       UK.SA PDV      VAL"

if fieldpos("SIFRA")<>0
	?? " OP"
endif

if lVrsteP
  	?? " Nac.pl."
endif

if fieldpos("DATPL")<>0
  	?? " Dat.pl. "
endif

? space(gnLMarg)
?? m

nC:=0
nIznos:=nRab:=0
nIznosD:=nRabD:=0
nIznos3:=nRab3:=0
nOsn_tot := 0
nPdv_tot := 0
nUkPDV_tot := 0
private cRezerv:=" "
cImeKup:=trim(cimekup)
do while !eof() .and. IdFirma=cIdFirma
  cDinDem:=dindem
  if !empty(cimekup)
     if !(partner=cimekup)
        skip; loop
     endif
  endif
  if lOpcine
      SELECT PARTN; HSEEK fakt_doks->idpartner; select fakt_doks
      if !(PARTN->(&aUslOpc))
         skip; loop
      endif
  endif

  ? space(gnLMarg); ?? Str(++nC,4)+".",datdok,idfirma,idtipdok,brdok+Rezerv+" "
  IF m1 <> "Z"
     ?? partner
  ELSE
     ?? PADR ("<<dokument u pripremi>>", LEN (partner))
  ENDIF
  nCol1:=pcol()+1
  if cDinDem==left(ValBazna(),3)
   @ prow(),pcol()+1 SAY str(iznos+rabat,12,2)
   @ prow(),pcol()+1 SAY str(Rabat,12,2)
   @ prow(),pcol()+1 SAY str(ROUND(iznos,gFZaok),12,2)
   
   // osnovica i pdv na prikazu
   @ prow(),pcol()+1 SAY ;
   	STR( nOsn_izn := ROUND(_osnovica( idtipdok, idpartner, iznos ),gFZaok),;
		12, 2 )
   @ prow(),pcol()+1 SAY ;
   	STR( nPdv_izn := ROUND(_pdv( idtipdok, idpartner, iznos ),gFZaok), ;
		12, 2 )
   @ prow(),pcol()+1 SAY ;
   	STR( nUkPdv_izn := ROUND(_uk_sa_pdv( idtipdok, idpartner, iznos ), ;
		gFZaok), 12, 2 )
  
   nIznos+=ROUND(iznos,gFZaok)
   nRab+=rabat
   nIznos3+=ROUND(iznos,gFZaok)
   nRab3+=rabat
   nOsn_tot += nOsn_izn
   nPdv_tot += nPdv_izn
   nUkPDV_tot += nUkPDV_izn

  else

   @ prow(),pcol()+1 SAY str(iznos+rabat,12,2)
   @ prow(),pcol()+1 SAY str(Rabat,12,2)
   @ prow(),pcol()+1 SAY str(ROUND(iznos,gFZaok),12,2)
   
   // osnovica i pdv na prikazu
   @ prow(),pcol()+1 SAY ;
   	STR( nOsn_izn := ROUND(_osnovica( idtipdok, idpartner, iznos ),gFZaok),;
		12, 2)
   @ prow(),pcol()+1 SAY ;
   	STR( nPDV_izn := ROUND(_pdv( idtipdok, idpartner, iznos ),gFZaok), ;
		12, 2)
   @ prow(),pcol()+1 SAY ;
   	STR( nUkPdv_izn := ROUND(_uk_sa_pdv( idtipdok, idpartner, iznos ), ;
		gFZaok), 12, 2 )

   nIznosD += ROUND(iznos,gFZaok)
   nRabD += rabat
   nIznos3 += ROUND(iznos*UBaznuValutu(datdok),gFZaok)
   nRab3 += rabat*UBaznuValutu(datdok)
   nOsn_tot += nOsn_izn * UBaznuValutu(datdok)
   nPdv_tot += nPdv_izn * UBaznuValutu(datdok)
   nUkPdv_tot += nUkPdv_izn * UBaznuValutu(datdok)

  endif

  @ prow(),pcol()+1 SAY cDinDEM
  if fieldpos("SIFRA")<>0
    @ prow(),pcol()+1 SAY iif(empty(sifra),space(2),left(CryptSC(sifra),2))
  endif
  if lVrsteP
    @ prow(),pcol()+1 SAY idvrstep+"-"+LEFT(VRSTEP->naz,4)
  endif
  if fieldpos("DATPL")<>0
    @ prow(),pcol()+1 SAY datpl
  endif
  skip
enddo

? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+ValBazna()+":"
@ prow(),nCol1    SAY  STR(nIznos+nRab,12,2)
@ prow(),pcol()+1 SAY  STR(nRab,12,2)
@ prow(),pcol()+1 SAY  STR(nIznos,12,2)
@ prow(),pcol()+1 SAY  STR(nOsn_tot,12,2)
@ prow(),pcol()+1 SAY  STR(nPDV_tot,12,2)
@ prow(),pcol()+1 SAY  STR(nUkPDV_tot,12,2)
@ prow(),pcol()+1 SAY  LEFT(ValBazna(),3)
? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+ValSekund()+":"
@ prow(),nCol1    SAY  STR(nIznosD+nRabD,12,2)
@ prow(),pcol()+1 SAY  STR(nRabD,12,2)
@ prow(),pcol()+1 SAY  STR(nIznosD,12,2)
@ prow(),pcol()+1 SAY  LEFT(ValSekund(),3)
? space(gnLMarg);?? m
? space(gnLMarg);?? m
? space(gnLMarg);?? "UKUPNO "+valbazna()+"+"+valsekund()+":"
@ prow(),nCol1    SAY  STR(nIznos3+nRab3,12,2)
@ prow(),pcol()+1 SAY  STR(nRab3,12,2)
@ prow(),pcol()+1 SAY  STR(nIznos3,12,2)
@ prow(),pcol()+1 SAY  LEFT(VAlBazna(),3)
? space(gnLMarg);?? m

set filter to  // ukini filter

if cRTarifa=="D" .and. empty(cImeKup) .and. qqTipDok $ "11#13#27"  // racun maloprodaje ili otpremnice u mp
  // ne moze se zadati za jednog kupca
  O_TARIFA
  O_SIFK; O_SIFV
  O_ROBA
  O_FAKT

  // zakaci se na roba!
  set relation to idroba into roba  
  cFilter+=".and. IdFirma="+cm2str(cIdFirma)

  index on roba->idtarifa to FaktTar for &cFilter  // pomocni index na tarifu!

  IF qqTipDok=="13"
    IF glCij13Mpc
      cpmp:="9"
    ELSEIF EMPTY(g13dcij) .and. gVar13!="2"
     Box(,1,50)
      cpmp:="9"
      @ m_x+1,m_y+2 SAY "Prikaz MPC ( 1/2/3/4/5/6/9 iz fakt-a) " GET cPMP valid cpmp $ "1234569"
      read
     BoxC()
    ELSE
     cPMP:=g13dcij
    ENDIF
  ELSE
    cpmp:="9"
  ENDIF

  fakt_rekap_tarifa(cPMP)
  select fakt; use
endif

FF
END PRINT

closeret
return


// ------------------------------------------
// vraca info o fiskalnom racunu
// ------------------------------------------
static function g_fiscal_info( _f_rn )
local cInfo := " "
if _f_rn > 0
	cInfo := "F"
endif
return cInfo



// ------------------------------------------------------
// vraca ukupno sa pdv
// ------------------------------------------------------
function _uk_sa_pdv( cIdTipDok, cPartner, nIznos )
local nRet := 0
local nTArea := SELECT()

if cIdTipDok $ "11#13#23"
	nRet := nIznos
else
	if !IsIno( cPartner ) .and. !IsOslClan( cPartner )
		nRet := ( nIznos * 1.17 )
	else
		nRet := nIznos
	endif
endif

select (nTArea)
return nRet


// ------------------------------------------------------
// vraca osnovicu dokumenta
// ------------------------------------------------------
function _osnovica( cIdTipDok, cPartner, nIznos )
local nRet := 0
local nTArea := SELECT()

if cIdTipDok $ "11#13#23"
	nRet := ( nIznos / 1.17 )
else
	nRet := nIznos
endif

select (nTArea)
return nRet



// -----------------------------------------------------
// vraca pdv dokumenta
// -----------------------------------------------------
function _pdv( cIdTipDok, cPartner, nIznos )
local nRet := 0
local nTArea := SELECT()

if cIdTipDok $ "11#13#23"
	nRet := ( nIznos / 1.17 ) * 0.17
else
	nRet := nIznos * 0.17
endif

select (nTArea)

return nRet


// printaj narudzbenicu
function pr_nar()
*{
select fakt_doks
nTrec:=recno()
_cIdFirma:=idfirma
_cIdTipDok:=idtipdok
_cBrDok:=brdok

close all
o_fakt_edit()
StampTXT(_cidfirma, _cIdTipdok, _cbrdok, .t.)
// printaj narudzbu
nar_print(.t.)
select (F_FAKT_DOKS); use
O_FAKT_DOKS
if lOpcine
	O_PARTN
	select fakt_doks
	set relation to idpartner into PARTN
endif
if cFilter==".t."
	set Filter to
else
	set Filter to &cFilter
endif
go nTrec

return DE_CONT
*}

// print radni nalog
function pr_rn()
*{
select fakt_doks
nTrec:=recno()
_cIdFirma:=idfirma
_cIdTipDok:=idtipdok
_cBrDok:=brdok
close all
o_fakt_edit()
StampTXT(_cidfirma, _cIdTipdok, _cbrdok, .t.)
// printaj radni nalog
rnal_print(.t.)
select (F_FAKT_DOKS); use
O_FAKT_DOKS
if lOpcine
	O_PARTN
       	select fakt_doks
       	set relation to idpartner into PARTN
endif
if cFilter==".t."
	set Filter to
else
	set Filter to &cFilter
endif
go nTrec
return DE_CONT
*}

// stampaj poresku fakturu
function pr_pf()
*{
select fakt_doks
nTrec:=recno()
_cIdFirma:=idfirma
_cIdTipDok:=idtipdok
_cBrDok:=brdok
close all
altd()
o_fakt_edit()
StampTXT(_cidfirma, _cIdTipdok, _cbrdok)
select (F_FAKT_DOKS); use
O_FAKT_DOKS
if lOpcine
	O_PARTN
       	select fakt_doks
       	set relation to idpartner into PARTN
endif
if cFilter==".t."
	set Filter to
else
	set Filter to &cFilter
endif
go nTrec
    
return DE_CONT


// stampaj poresku fakturu u odt formatu
function pr_odt()
*{
select fakt_doks
nTrec:=recno()
_cIdFirma:=idfirma
_cIdTipDok:=idtipdok
_cBrDok:=brdok
close all
o_fakt_edit()
StDokOdt( _cidfirma, _cIdTipdok, _cbrdok )
select (F_FAKT_DOKS)
use
O_FAKT_DOKS
if lOpcine
	O_PARTN
       	select fakt_doks
       	set relation to idpartner into PARTN
endif
if cFilter==".t."
	set Filter to
else
	set Filter to &cFilter
endif
go nTrec
    
return DE_CONT



// --------------------------
// generisi fakturu
// --------------------------
function gen_fakt()
local cTipDok
local cFirma
local cBrFakt
local nCnt := 0
local dDatFakt
local dDatVal
local dDatIsp
local i
local cPart
local aMemo := {}

if pitanje(,"Generisati fakturu na osnovu ponude ?", "D") == "N"
	return DE_CONT
endif

select fakt_doks
nTrec:=recno()

cTipDok := idtipdok
cFirma := idfirma
cBrFakt := brdok
cPart := idpartner
dDatFakt := datdok
dDatVal := datdok
dDatIsp := datdok

cNBrFakt := cBrFakt

// uslovi generisanja...
Box(, 7, 55)
	
	@ m_x + 1, m_y + 2 SAY "*** Parametri fakture "  
	
	@ m_x + 3, m_y + 2 SAY "  Datum fakture: " GET dDatFakt VALID !EMPTY(dDatFakt) 
	
	@ m_x + 4, m_y + 2 SAY "   Datum valute: " GET dDatVal VALID !EMPTY(dDatVal) 
	@ m_x + 5, m_y + 2 SAY " Datum isporuke: " GET dDatIsp VALID !EMPTY(dDatIsp) 
	

	@ m_x + 7, m_y + 2 SAY "   Broj fakture: " GET cBrFakt VALID !EMPTY(cBrFakt)

	read

BoxC()


set filter to
go top
seek cFirma + "10" + cBrFakt

if FOUND()
	
	msgbeep("dokument vec postoji !!!!")
	
	if pitanje(, "Naci sljedeci broj dokumenta ?", "D") == "N"
		return DE_CONT
	endif

	cNBrFakt := PADR( FaNoviBroj( cFirma, "10" ) , 8 )
	
endif

select fakt_doks
go top
seek cFirma + cTipDok + cBrFakt

// ubaci doks
Scatter()

append blank

// tip dok je "10"
_idtipdok := "10"
_brdok := cNBrFakt
_datdok := dDatFakt

Gather()

O_FAKT
select fakt
set order to tag "1"
go top

seek cFirma + cTipDok + cBrFakt


do while !EOF() .and. field->idfirma + field->idtipdok + field->brdok == ;
		cFirma + cTipDok + cBrFakt

	++ nCnt
	
	nFRec := RECNO()

	Scatter()

	aMemo := ParsMemo(_txt)

	append blank
	
	_idtipdok := "10"
	_brdok := cNBrFakt
	_datdok := dDatFakt
	
	// dodaj memo polje, samo prva stavka
	if nCnt = 1
	
		_txt := ""
		_txt += CHR(16) + aMemo[1] + CHR(17)
		_txt += CHR(16) + aMemo[2] + CHR(17)
		_txt += CHR(16) + aMemo[3] + CHR(17)
		_txt += CHR(16) + aMemo[4] + CHR(17)
		_txt += CHR(16) + aMemo[5] + CHR(17)
		_txt += CHR(16) + aMemo[6] + CHR(17)
		// datum otpremnice
		_txt += CHR(16) + DTOC(dDatIsp) + CHR(17)
		_txt += CHR(16) + aMemo[8] + CHR(17)
		// datum narudzbe / amemo[9]
		_txt += CHR(16) + DTOC(dDatVal) + CHR(17)
		// datum valute / amemo[10]
		_txt += CHR(16) + DTOC(dDatVal) + CHR(17)

		// dodaj i ostala polja

		if LEN(aMemo) > 10
			for i:=11 to LEN(aMemo)
				_txt += CHR(16) + aMemo[i] + CHR(17)
			next
		endif

	endif
	
	Gather()

	go ( nFRec )
	
	skip

enddo

if isugovori()

	if pitanje(,"Setovati datum uplate za partnera ?", "N") == "D"
		
		O_UGOV
		select ugov
		set order to tag "PARTNER"
		go top
		seek cPart

		if FOUND() .and. field->idpartner == cPart
			replace field->dat_l_fakt with DATE()
		endif
		
	endif

endif

select fakt_doks

if lOpcine
	O_PARTN
       	select fakt_doks
       	set relation to idpartner into PARTN
endif

if cFilter==".t."
	set Filter to
else
	set Filter to &cFilter
endif

go nTrec
   
msgbeep("Formiran dokument 10-" + cNBrFakt )

return DE_REFRESH





function pr_choice()
*{
local nSelected
private Opc:={}
private opcexe:={}
private Izbor
	
AADD(opc, "   >  stampa dokumenta        " )
AADD(opcexe, {|| nSelected:=Izbor, Izbor:=0  } )
AADD(opc, "   >  stampa narudzbenice     " )
AADD(opcexe, {|| nSelected:=Izbor, Izbor:=0  } )
AADD(opc, "   >  stampa radnog naloga    " )
AADD(opcexe, {|| nSelected:=Izbor, Izbor:=0  } )

Izbor := 1
Menu_SC("pch")

return nSelected



// ----------------------------------------------------------------
// vraca vezu dokumenta
// ----------------------------------------------------------------
function g_d_veza( cIdFirma, cTipDok, cBrDok, cDok_veza, cTxt )
local cVeza := ""
local nTArea := SELECT()
local lDok_veza := .f.

if cTxt == nil
	cTxt := ""
endif

if fakt_doks->(FIELDPOS("DOK_VEZA")) <> 0
	lDok_veza := .t.
endif

if lDok_veza .and. !EMPTY( cDok_veza )
	// uzmi iz polja dok_veza
	cVeza := ALLTRIM( cDok_veza )
else
	
	if EMPTY( cTxt )
		// uzmi iz fakt->memo polja broj veze
		O_FAKT
		select fakt
		go top
		seek cIdFirma + cTipDok + cBrDok
		cTxt := field->txt
	endif

	aTemp := ParsMemo( cTxt )
	
	select ( nTArea )

	if LEN( aTemp ) >= 19
		cVeza := ALLTRIM( aTemp[19] )
	else
		cVeza := ""
	endif
endif

return cVeza



// ----------------------------------------------------
// prikazuje brojeve veze
// ----------------------------------------------------
static function box_d_veza()
local cTmp := ""
local cPom
local aTmp := {}
local i
local nSelected
private GetList := {}
private Opc:={}
private opcexe:={}
private Izbor

cTmp := g_d_veza( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, ;
	doks->dok_veza )

if EMPTY( cTmp )
	msgbeep("Nema definisanih veznih dokumenata !")
	return
endif

// zamjeni karaktere ako su drugacije definisani
cTmp := STRTRAN( cTmp, ";", "," )

// dodaj u matricu vezne brojeve
aTmp := TokToNiz( cTmp, "," )

for i:=1 to LEN( aTmp )

	cPom := PADR( aTmp[ i ], 10 )
	
	AADD(opc, cPom )
	AADD(opcexe, {|| nSelected := Izbor, Izbor := 0  } )
next

Izbor := 1
// 0 - ako se kaze <ESC>
Menu_SC("o_dvz")

if LastKey() == K_ESC
	nSelected := 0
	Izbor := 0
endif

return nSelected


// -------------------------------------------------
// prikazuje broj fiskalnog racuna
// -------------------------------------------------
static function _veza_fc_rn()
local cFiscal

if fakt_doks->(FIELDPOS("FISC_RN")) = 0
	return
endif

cFiscal := ALLTRIM( STR( fakt_doks->fisc_rn ) )

// samo za izlazne dokumente
if fakt_doks->idtipdok $ "10#11"
	
	if cFiscal == "0"
		@ m_x + 1, m_y + 2 SAY ;
			PADR( "nema fiskalnog racuna !!!", 40 ) ;
			COLOR "W/R+"
	else
		@ m_x + 1, m_y + 2 SAY ;
			PADR( "fiskalni racun: " + cFiscal, 40 ) ;
			COLOR "GR+/B"
	endif
else
	@ m_x + 1, m_y + 2 SAY PADR( "", 40 )
endif

return



/*! \fn EdDatN()
 *  \brief Ispravka azuriranih dokumenata (u tabelarnom pregledu)
 */
 
function EdDatn()
local nRet:=DE_CONT

if gFC_use == "D"
	// ispis informacije o fiskalnom racunu
	_veza_fc_rn()
endif

do case
 
   case Ch==K_ALT_E
     IF gTBDir=="D"
        gTBDir:="N"
        NeTBDirektni()  // ELIB, vrati stari tbrowse
     ELSE
       IF Pitanje(,"Preci u mod direktog unosa podataka u tabelu? (D/N)","D")=="D"
         gTBDir:="D"
         select(F_PARTN); if !used(); O_PARTN; endif
         select fakt_doks
         DaTBDirektni() // ELIB, promjeni tbrowse na edit rezim
       ENDIF
     ENDIF
     
  case Ch==K_ENTER .and. gTBDir=="N"
     nRet := pr_pf()

  case Ch==K_ALT_P
     // print odt
     nRet := pr_odt()

  case Ch == K_F5
  
  	select fakt_doks
	go top

	// refresh tabele
	nRet := DE_REFRESH

  case CH == K_CTRL_V
  	
	// setovanje broj fiskalnog isjecka
	select fakt_doks
	
	if field->fisc_rn <> 0
		msgbeep("veza: fiskalni racun vec setovana !")
		if Pitanje(,"Promjeniti postojecu vezu (D/N)?", "N") == "N"
			return DE_CONT
		endif
	endif
	
	if Pitanje(,"Setovati novu vezu sa fiskalnim racunom (D/N)?") == "N"
		return DE_CONT
	endif
	
	nFiscal := field->fisc_rn

	Box(,1,40)
		@ m_x + 1, m_y + 2 SAY "fiskalni racun:" GET nFiscal ;
			PICT "9999999999"
		read
	BoxC()
	
	if nFiscal <> field->fisc_rn
		replace field->fisc_rn with nFiscal
		return DE_REFRESH
	endif
  
  case chr(Ch) $ "iI"
  	
	// info dokument
	msgbeep( getfullusername( field->oper_id ) )
	return DE_CONT


  case chr(Ch) $ "kK"
	
	// korekcija podataka na dokumentu
	if fakt_edit_data( field->idfirma, field->idtipdok, field->brdok ) = .t.
		return DE_REFRESH
	endif

  case chr(Ch) $ "rR"

	cFilter := DBFilter()

	select fakt_doks

  	// stampa fiskalnog racuna
	if field->idtipdok $ "10#11"
		
		if field->fisc_rn > 0
			
			msgbeep("Fiskalni racun vec stampan za ovaj dokument !!!#Ako je potrebna ponovna stampa resetujte broj veze.")
			
			return DE_CONT
		
		endif
		
		if Pitanje(,"Stampati fiskalni racun ?", "D") == "D"

			fakt_fisc_rn( field->idfirma, field->idtipdok, field->brdok )
		
			select fakt_doks
			set filter to &cFilter
			
			return DE_REFRESH

		endif

	endif

  case chr(Ch) $ "sS"

     // generisi storno dokument
     storno_dok( field->idfirma, field->idtipdok, field->brdok )
     
     if Pitanje(,"Preci u tabelu pripreme ?","D")=="D"
          fUPripremu:=.t.
          nRet:=DE_ABORT
     else
     	  nRet := DE_CONT
     endif
  
  case UPPER(chr(Ch)) == "V"
  	
	box_d_veza()

	return DE_CONT

  case UPPER(chr(Ch)) == "B"
     nRet:=pr_rn()  
     
  case chr(Ch) $ "nN"
     nRet:=pr_nar()
  
  case chr(Ch) $ "fF"
     if idtipdok $ "20"
       nRet:=gen_fakt()
     endif
     
  case chr(Ch) $ "vV"
     // ispravka valutiranja
     
     
     if ( PADR(dindem, 3) <> PADR(ValDomaca(), 3) ) 
       
       if !SigmaSif("PRVAL")
     		MsgBeep("!!! Opcija nedostupna !!!")
     		return DE_CONT
       endif
      
       if Pitanje(,"Izvrsiti ispravku valutiranja na dokumentu (D/N)?","N") == "N"
     	  return DE_CONT
	  
       endif
       
       O_FAKT 
       seek  fakt_doks->idfirma + fakt_doks->idtipdok + fakt_doks->brdok
       
       nPom1 := 0
       nPom2 := 0
       nPom3 := 0
       nDugD := 0
       nRabD := 0
       
       do while !EOF() .and. fakt->(idfirma+idtipdok+brdok)==fakt_doks->(idfirma+idtipdok+brdok)
         
	  nPrCij := fakt->cijena
	  
       	  v_pretvori("D", fakt->DinDem, fakt->DatDok, @nPrCij ) 
	  
	  replace cijena with nPrCij 
          
	  nPom1 := round( kolicina*Cijena*PrerCij() / UBaznuValutu(datdok) * (1-Rabat/100), ZAOKRUZENJE)
          nPom2 := ROUND( kolicina*Cijena*PrerCij()/UBaznuValutu(datdok)*Rabat/100 , ZAOKRUZENJE)
          nPom3 := ROUND( nPom1 * Porez/100, ZAOKRUZENJE)
          nDugD += nPom1 + nPom3
          nRabD += nPom2 
	  
	  skip
       
       enddo
       
       select fakt_doks
       
       replace iznos with nDugD
       replace rabat with nRabD
	  
       nRet := DE_REFRESH
     
     else
       
       MsgBeep("Opcija onemogucena !!! faktura je u domacoj valuti " + ValDomaca() )
       select fakt_doks
       nRet := DE_CONT
     
     endif
  
  case chr(Ch) $ "pP" .and. gTBDir=="N"  // povrat
     
     if !(ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
     	msgbeep( cZabrana )
	nRet := DE_CONT
	return nRet
     endif
     
     select fakt_doks
     nTrec:=recno()
     _cIdFirma:=idfirma
     _cIdTipDok:=idtipdok
     _cBrDok:=brdok
     close all
     nR_tmp := Povrat_fakt_dokumenta(.f.,_cidfirma,_cIdTipdok,_cbrdok)
     select (F_FAKT_DOKS)
     use
     O_FAKT_DOKS
     if lOpcine
       O_PARTN
       select fakt_doks
       set relation to idpartner into PARTN
     endif
     if cFilter==".t."
       set Filter to
     else
       set Filter to &cFilter
     endif
     go nTrec
     if nR_tmp <> 0 .and. Pitanje(,"Preci u tabelu pripreme ?","D")=="D"
      fUPripremu:=.t.
      nRet:=DE_ABORT
     else
      nRet:=DE_REFRESH
     endif
  case chr(Ch) $ "rR" .and. gTBDir=="N"  // povrat
     select fakt_doks
     nTrec      := recno()
     _cIdFirma  := idfirma
     _cIdTipDok := idtipdok
     _cBrDok    := brdok
     close all
     if _cidtipdok$"20#27"
       nR_tmp := Povrat_fakt_dokumenta(.t.,_cidfirma,_cIdTipdok,_cbrdok)
     elseif _cidtipdok $ "01#19"
       O_FAKT_DOKS
       seek _cidfirma+_cidtipdok+_cbrdok
       if rezerv="*"
         cZnak:=""
       else
         cZnak:="*"
       endif
       do while !eof() .and. idfirma+idtipdok+brdok==_cidfirma+_cidtipdok+_cbrdok
          replace rezerv with cZnak
          skip
       enddo
       O_FAKT
       seek  _cidfirma+_cidtipdok+_cbrdok
       do while !eof() .and. idfirma+idtipdok+brdok==_cidfirma+_cidtipdok+_cbrdok
          replace serbr with cznak
          skip
       enddo
       close all
     endif
     select (F_FAKT_DOKS)
     use
     O_FAKT_DOKS
     if lOpcine
       O_PARTN
       select fakt_doks
       set relation to idpartner into PARTN
     endif
     if cFilter==".t."
        set Filter to
     else
        set Filter to &cFilter
     endif
     go nTrec
     nRet:=DE_REFRESH

endcase
return nRet
*}


/*! \fn fakt_rekap_tarifa(cPMP,cRegion)
 *  \brief Rekapitulacija po tarifama
 *  \todo Prebaciti u /RPT
 *  \param cPMP
 *  \param cRegion
 */
 
function fakt_rekap_tarifa(cPMP,cRegion)
*{
// prosljedjuje cidfirma,cidvd,cbrdok
local nArea:=select()

if cRegion==NIL
	cRegion:=" "
ENDIF

if cPMP==NIL
  cPMP:="0"
endif

private gPicProc:="999999.99%"
private gPicDEM:= "9999999.99"


IF prow()>55+gPStranica; FF; endif
// @ prow(),123 SAY "Str:"+str(++nStr,3);  endif
nRec:=recno()

if !fDelphiRb
	?
	? space(gNlMarg)+"Rekapitulacija po tarifama:"
	m:=space(gNlMarg)+"------ ---------- ---------- ----------  ---------- ---------- ---------- ---------- ----------"
	? m
	? space(gNlMarg)+"* Tar *  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *   PP     * MPVSAPP *"
	? m
endif
nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
do while !eof()
  // cidtarifa:=roba->idtarifa
  IF cRegion=="3"
    cidtarifa:=roba->idtarifa3
    bTar:={|| !eof() .and. roba->idtarifa3==cidtarifa}
  ELSEIF cRegion=="2"
    cidtarifa:=roba->idtarifa2
    bTar:={|| !eof() .and. roba->idtarifa2==cidtarifa}
  ELSE
    cidtarifa:=roba->idtarifa
    bTar:={|| !eof() .and. roba->idtarifa==cidtarifa}
  ENDIF
  nU1:=nU2:=nU2b:=0
  nU3:=nU4:=0
  select tarifa
  hseek cidtarifa
  select (nArea)
  do while EVAL(bTar)
    NSRNPIdRoba((nArea)->idroba)
    select (nArea)
    _Cijena:=cijena
    if idtipdok=="13"
         if cPMP=="2"
           _cijena:=roba->mpc2
         elseif cPMP=="3"
           _cijena:=roba->mpc3
         elseif cPMP=="4"
           _cijena:=roba->mpc4
         elseif cPMP=="5"
           _cijena:=roba->mpc5
         elseif cPMP=="6"
           _cijena:=roba->mpc6
         elseif cPMP=="1"
           _cijena:=roba->mpc
         else
           _cijena:=(nArea)->cijena
         endif
    endif
    fakt_vt_porezi()

    // TODO: Opet ces imati problem zaokruzenja
    nU1+=round(_cijena*kolicina/(_ZPP+(1+_opp)*(1+_ppp)) ,ZAOKRUZENJE)
    nU2+=round(_cijena*kolicina/(_ZPP+(1+_opp)*(1+_ppp))*_OPP  ,ZAOKRUZENJE)
    nU2b+=round(_cijena*kolicina/(_ZPP+(1+_opp)*(1+_ppp))*_ZPP ,ZAOKRUZENJE)
    nU3+=round(_cijena*kolicina/(_ZPP+(1+_opp)*(1+_ppp))*(1+_opp)*_PPP ,ZAOKRUZENJE)
    nU4+=round(_cijena*kolicina ,ZAOKRUZENJE)
    skip
  enddo
  nTot1+=nu1; nTot2+=nU2;nTot2b+=nU2b; nTot3+=nU3
  nTot4+=nU4
  if !fDelphiRb
  	? space(gNlMarg)+cidtarifa
  	@ prow(),pcol()+1   SAY (_OPP*100) pict gpicproc
  	@ prow(),pcol()+1   SAY (_PPP*100) pict gpicproc
  	@ prow(),pcol()+1   SAY (_ZPP*100) pict gpicproc
  	nCol1:=pcol()+1
  	@ prow(),pcol()+1   SAY nu1  pict gpicdem
  	@ prow(),pcol()+1   SAY nu2  pict gpicdem
  	@ prow(),pcol()+1   SAY nu3  pict gpicdem
  	@ prow(),pcol()+1   SAY nu2b pict gpicdem
  	@ prow(),pcol()+1   SAY nu4  pict gpicdem
  endif	
enddo

if !fDelphiRb
? m
? space(gNlMarg)+"UKUPNO"
@ prow(),nCol1      SAY nTot1 pict gpicdem
@ prow(),pcol()+1   SAY nTot2 pict gpicdem
@ prow(),pcol()+1   SAY nTot3 pict gpicdem
@ prow(),pcol()+1   SAY nTot2b pict gpicdem
@ prow(),pcol()+1   SAY nTot4 pict gpicdem
? m
endif

return
*}



/*! \fn fakt_vt_porezi()
 *  \brief Smjesta poreze iz tarifa u javne varijable
 */

function fakt_vt_porezi()
*{
public _ZPP:=0
if roba->tip=="V"
  public _OPP:=0,_PPP:=tarifa->ppp/100
  public _PORVT:=tarifa->opp/100
elseif roba->tip=="K"
  public _OPP:=tarifa->opp/100,_PPP:=tarifa->ppp/100
  public _PORVT:=tarifa->opp/100
else
  public _OPP:=tarifa->opp/100
  public _PPP:=tarifa->ppp/100
  public _ZPP:=tarifa->zpp/100
  public _PORVT:=0
endif
return
*}


/*! \fn fakt_real_partnera()
 *  \brief Realizacija po partnerima
 *  \todo Prebaciti u /RPT
 */

function fakt_real_partnera()
*{
O_FAKT_DOKS
O_PARTN
O_VALUTE
O_RJ

cIdfirma:=gFirma
dDatOd:=ctod("")
dDatDo:=date()
qqTipDok:="10;"
Box(,11,77)

O_PARAMS
private cSection:="N",cHistory:=" "; aHistory:={}
//Params1()
RPar("c1",@cIdFirma)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
cTabela:="N"
cBrFakDok:=SPACE(40)
cImeKup:=space(20)
qqPartn:=space(20)
qqOpc:=space(20)
RPar("TA",@cTabela)
RPar("KU",@cImeKup)
RPar("sk",@qqPartn)
RPar("BD",@cBrFakDok)
qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,40)
qqOpc:=padr(qqOpc,20)

do while .t.
	cIdFirma:=padr(cidfirma,2)
 	@ m_x+1,m_y+2 SAY "RJ            " GET cIdFirma valid {|| empty(cidfirma) .or. cidfirma==gfirma .or. P_RJ(@cIdFirma) }
 	@ m_x+2,m_y+2 SAY "Tip dokumenta " GET qqTipDok pict "@!S20"
 	@ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
 	@ m_x+3,col()+1 SAY "do"  get dDatDo
 	@ m_x+6,m_y+2 SAY "Uslov po nazivu kupca (prazno svi)"  get qqPartn pict "@!"
 	@ m_x+7,m_y+2 SAY "Broj dokumenta (prazno svi)"  get cBrFakDok pict "@!"
 	@ m_x+9,m_y+2 SAY "Opcina (prazno sve)" get qqOpc pict "@!"
 	read
 	ESC_BCR
 	aUslBFD:=Parsiraj(cBrFakDok,"BRDOK","C")
 	//aUslSK:=Parsiraj(qqPartn,"IDPARTNER")
 	aUslTD:=Parsiraj(qqTipdok,"IdTipdok","C")
 	if aUslBFD<>NIL .and. aUslTD<>NIL
		exit
	endif
enddo

qqTipDok:=trim(qqTipDok)
qqPartn:=trim(qqPartn)

Params2()
WPar("c1",cIdFirma)
WPar("d1",dDatOd)
WPar("d2",dDatDo)
WPar("TA",cTabela)
WPar("sk",qqPartn)
WPar("BD",cBrFakDok)
select params
use

BoxC()

select fakt_doks

Private cFilter:=".t."

if !empty(dDatOd) .or. !empty(dDatDo)
  	cFilter+=".and.  datdok>="+cm2str(dDatOd)+".and. datdok<="+cm2str(dDatDo)
endif

if cTabela=="D"  // tabel prikaz
	cFilter+=".and. IdFirma="+cm2str(cIdFirma)
endif

if !empty(cBrFakDok)
  cFilter+=".and."+aUslBFD
endif

//if !empty(qqPartn)
//  cFilter+=".and."+aUslSK
//endif

if !empty(qqTipDok)
  cFilter+=".and."+aUslTD
endif

if cFilter=".t..and."
  cFilter:=substr(cFilter,9)
endif

if cFilter==".t."
  set Filter to
else
  set Filter to &cFilter
endif



EOF CRET

//gaZagFix:={3,3}
START PRINT CRET

private nStrana:=0
private m:="---- ------ -------------------------- ------------ ------------ ------------"
fakt_zagl_real_partnera()

set order to tag "6"
//"6","IdFirma+idpartner+idtipdok",KUMPATH+"DOKS"
seek cIdFirma

nC:=0
ncol1:=10
nTIznos:=nTRabat:=0
private cRezerv:=" "
do while !eof() .and. IdFirma=cIdFirma
	// uslov po partneru
	if !Empty(qqPartn)
  		if !(fakt_doks->partner=qqPartn)
			skip
			loop
		endif
  	endif
  	
	nIznos:=0
	nRabat:=0
  	cIdPartner:=idpartner
  	select partn
	hseek cIdPartner
	select fakt_doks
	
	
	// uslov po opcini
	if !Empty(qqOpc)
		if AT(partn->idops, qqOpc)==0
			skip
			loop
		endif
	endif
	
  	do while !eof() .and. IdFirma=cIdFirma .and. idpartner==cIdpartner
		if DinDem==left(ValBazna(),3)
      			nIznos+=ROUND(iznos,ZAOKRUZENJE)
      			nRabat+=ROUND(Rabat,ZAOKRUZENJE)
    		else
      			nIznos+=ROUND(iznos*UBaznuValutu(datdok),ZAOKRUZENJE)
      			nRabat+=ROUND(Rabat*UBaznuValutu(datdok),ZAOKRUZENJE)
    		endif
		skip
  	enddo
	if prow()>61
  		FF
		fakt_zagl_real_partnera()
  	endif

  	? space(gnLMarg)
	?? Str(++nC,4)+".", cIdPartner, partn->naz
  	nCol1:=pcol()+1
  	@ prow(),pcol()+1 SAY str(nIznos+nRabat,12,2)
  	@ prow(),pcol()+1 SAY str(nRabat,12,2)
  	@ prow(),pcol()+1 SAY str(nIznos,12,2)

  	ntIznos+=nIznos
  	ntRabat+=nRabat
enddo

if prow()>59
	FF
	fakt_zagl_real_partnera()
endif

? space(gnLMarg)
?? m
? space(gnLMarg)
?? " Ukupno"
@ prow(),nCol1 SAY str(ntIznos+ntRabat,12,2)
@ prow(),pcol()+1 SAY str(ntRabat,12,2)
@ prow(),pcol()+1 SAY str(ntIznos,12,2)
? space(gnLMarg)
?? m

set filter to  // ukini filter

FF
END PRINT

return
*}


// --------------------------------------------------------
// fakt_zagl_real_partnera()
// Zaglavlje izvjestaja realizacije partnera 
// --------------------------------------------------------
function fakt_zagl_real_partnera()

? 
P_12CPI
?? space(gnLMarg)
IspisFirme(cidfirma)
?
set century on
P_12CPI
? space(gnLMarg); ?? "FAKT: Stampa prometa partnera na dan:",date(),space(8),"Strana:",STR(++nStrana,3)
? space(gnLMarg); ?? "      period:",dDatOd,"-",dDatDo
if qqTipDok<>"10;"
 ? space(gnLMarg); ?? "-izvjestaj za tipove dokumenata :",trim(qqTipDok)
endif

set century off
P_12CPI
? space(gnLMarg); ?? m
? space(gnLMarg); ?? " Rbr  Sifra     Partner                  Ukupno        Rabat          UKUPNO"
? space(gnLMarg); ?? "                                           (1)          (2)            (1-2)"
? space(gnLMarg); ?? m

return
*}

