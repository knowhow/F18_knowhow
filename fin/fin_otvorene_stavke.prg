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


#include "fin.ch"
#include "f18_separator.ch"

function Ostav()
private izbor:=1
private opc:={}
private opcexe:={}
private gnLost:=0

AADD(opc, "1. ručno zatvaranje                    ")
AADD(opcexe, {|| RucnoZat()})
AADD(opc, "2. automatsko zatvaranje")
AADD(opcexe, {|| AutoZat()})
AADD(opc, "3. kartica")
AADD(opcexe, {|| SubKart(.t.)})
AADD(opc, "4. kartica konto/konto2")
AADD(opcexe, {|| SubKart2(.t.)})
AADD(opc, "5. specifikacija")
AADD(opcexe, {|| SpecOtSt()})
AADD(opc, "6. ios")
AADD(opcexe, {|| IOS()})
AADD(opc, "7. kartice grupisane po brojevima veze")
AADD(opcexe, {|| StKart(.t.)})
AADD(opc, "8. kompenzacija")
AADD(opcexe, {|| Kompenzacija()})
AADD(opc, "9. asistent otvorenih stavki")
AADD(opcexe, {|| fin_asistent_otv_st()})
AADD(opc, "U. OASIST - undo")
AADD(opcexe, {|| OStUndo()})

Izbor := 1
Menu_SC("oas")

return

// ----------------------------------------------------
// specifikacija otvorenih stavki 
// ----------------------------------------------------
static function SpecOtSt()
local nKolTot := 85

cIdFirma:=gFirma
nRok := 0
cIdKonto := SPACE(7)
picBHD:=FormPicL("9 "+gPicBHD,21)
picDEM:=FormPicL("9 "+gPicDEM,21)

cIdRj:="999999"
cFunk:="99999"
cFond:="999"

qqBrDok:=SPACE(40)

O_PARTN
M := "---- " + REPL("-", LEN(PARTN->id))+" ------------------------------------- ----- ----------------- ---------- ---------------------- --------------------"
O_KONTO
dDatOd:=dDatDo:=ctod("")

cPrelomljeno:="D"
Box("Spec", 13, 75, .f.)

DO WHILE .t.
  set cursor on
  @ m_x+1,m_y+2 SAY "SPECIFIKACIJA OTVORENIH STAVKI"
  if gNW=="D"
    @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
   else
    @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
  endif
  @ m_x+4,m_y+2 SAY "Konto    " GET cIdKonto valid P_KontoFin(@cIDKonto) pict "@!"
  @ m_x+5,m_y+2 SAY "Od datuma" GET dDatOd
  @ m_x+5,col()+2 SAY "do" GET dDatdo
  @ m_x+7,m_y+2 SAY "Uslov za broj veze (prazno-svi) " GET qqBrDok PICT "@!S20"
  @ m_x+8,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"

  UpitK1k4(9,.f.)

  READ; ESC_BCR
  aBV:=Parsiraj(qqBrDok,"UPPER(BRDOK)","C")
  IF aBV<>NIL
    EXIT
  ENDIF
ENDDO

BoxC()

B:=0

*

if cPrelomljeno=="N"
 m+=" --------------------"
endif


nStr:=0

O_SUBAN

CistiK1k4(.f.)

select SUBAN
//IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)
set order to tag "3"   

cFilt1:="OTVST==' '"

IF !EMPTY(qqBrDok)
  cFilt1 += ( ".and." + aBV )
ENDIF

IF !EMPTY(dDatOd)
  cFilt1+=".and. IF( EMPTY(datval) , datdok>="+cm2str(dDatOd)+" , datval>="+cm2str(dDatOd)+" )"
ENDIF

IF !EMPTY(dDatDo)
  cFilt1+=".and. IF( EMPTY(datval) , datdok<="+cm2str(dDatDo)+" , datval<="+cm2str(dDatDo)+" )"
ENDIF

GO TOP

if gRj=="D" .and. len(cIdrj)<>0
  cFilt1 += ( ".and. idrj='"+cidrj+"'" )
endif

if gTroskovi=="D" .and. len(cFunk)<>0
  cFilt1 += ( ".and. Funk='"+cFunk+"'" )
endif

if gTroskovi=="D" .and. len(cFond)<>0
  cFilt1 += ( ".and. Fond='"+cFond+"'" )
endif

SET FILTER TO &cFilt1

seek cidfirma+cidkonto
NFOUND CRET

START PRINT  CRET

nDugBHD:=nPotBHD:=0


DO WHILESC !EOF() .and. cIDFirma==idfirma .AND. cIdKonto=IdKonto
   cIdPartner:=IdPartner
   DO WHILESC  !EOF() .and. cIDFirma==idfirma .AND. cIdKonto=IdKonto .and. cIdPartner=IdPartner


         if prow()==0; ZaglSpK(); endif
         if prow()>63+gPStranica; FF; ZaglSpK(); endif

         cBrDok:=BrDok
         nIznD:=0; nIznP:=0
         do WHILESC  !EOF() .AND. cIdKonto=IdKonto .and. cIdPartner=IdPartner ;
                  .and. cBrDok==BrDok
            if D_P=="1"; nIznD+=IznosBHD; else; nIznP+=IznosBHD; endif
            SKIP
         enddo
         @ prow()+1,0 SAY ++B PICTURE '9999'
         @ prow(),5 SAY cIdPartner

         SELECT PARTN
         HSEEK cIdPartner

         @ prow(),pcol()+1 SAY PADR( naz, 37 )
         @ prow(),pcol()+1 SAY PADR( PTT, 5 )
         @ prow(),pcol()+1 SAY PADR( Mjesto, 17 )

         SELECT SUBAN

         @ prow(),pcol()+1 SAY PADR(cBrDok,10)

         if cPrelomljeno=="D"
                 if round(nIznD-nIznP,4)>0
                     nIznD:=nIznD-nIznP
                     nIznP:=0
                 else
                     nIznP:=nIznP-nIznD
                     nIznD:=0
                 endif
         endif

         // @ prow(),85      SAY nIznD PICTURE picBHD
         nKolTot:=pcol()+1
         @ prow(),nKolTot      SAY nIznD PICTURE picBHD

         @ prow(),pcol()+1 SAY nIznP PICTURE picBHD
         if cPrelomljeno=="N"
          @ prow(),pcol()+1 SAY nIznD-nIznP PICTURE picBHD
         endif
         nDugBHD+=nIznD
         nPotBHD+=nIznP


   ENDDO // partner
ENDDO  //  konto

if prow()>63+gPStranica; FF; ZaglSpK(); endif

? M
? "UKUPNO za KONTO:"
@ prow(),nKolTot  SAY nDugBHD PICTURE picBHD
@ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD

if cPrelomljeno=="N"
       @ prow(),pcol()+1 SAY nDugBHD-nPotBHD PICTURE picBHD
else

 ? " S A L D O :"
 if nDugBhd-nPotBHD>0
    nDugBHD:=nDugBHD-nPotBHD
    nPotBHD:=0
 else
    nPotBHD:=nPotBHD-nDugBHD
    nDugBHD:=0
 endif
 @ prow(),nKolTot  SAY nDugBHD PICTURE picBHD
 @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD

endif
? M

nDugBHD:=nPotBHD:=0

FF
END PRINT

close all
return



/*! \fn ZaglSpK()
 *  \brief Zaglavlje specifikacije
 */
 
function ZaglSpK()

local nDSP:=0
?
P_COND
?? "FIN.P: SPECIFIKACIJA OTVORENIH STAVKI  ZA KONTO ",cIdKonto
if !(empty(dDatOd) .and. empty(dDatDo))
 ?? " ZA PERIOD ",dDatOd,"-",dDatDo
endif
?? "     NA DAN:",DATE()
IF !EMPTY(qqBrDok)
  ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '"+TRIM(qqBrDok)+"'"
ENDIF

@ prow(),125 SAY "Str:"+str(++nStr,3)

if gNW=="D"
 ? "Firma:",gFirma,gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cidfirma,partn->naz,partn->naz2
endif

if cPrelomljeno=="N"
  P_COND2
endif

?
PrikK1k4(.f.)

nDSP:=LEN(PARTN->id)

? M
? "*R. *"+PADC("SIFRA",nDSP)+"*       NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *  BROJ    *               IZNOS                      *"+iif(cPrelomljeno=="N","                    *","")
? "     "+SPACE(nDSP)+"                                                                          ---------------------- --------------------"+iif(cPrelomljeno=="N"," --------------------","")
? "*BR.*"+SPACE(nDSP)+"*                                     * BROJ*                 *  VEZE    *         DUGUJE       *      POTRAZUJE    *"+iif(cPrelomljeno=="N","       SALDO        *","")
? M
SELECT SUBAN
RETURN




/*! \fn AutoZat() 
 *  \brief Zatvaranje stavki automatski
 */
function AutoZat(lAuto, cKto, cPtn)
local _rec

if lAuto == nil
    lAuto := .f.
endif
if cPtn == nil
    cPtn := ""
endif
if cKto == nil
    cKto := ""
endif

if Logirati(goModul:oDataBase:cName,"DOK","ASISTENT")
    lLogAZat:=.t.
else
    lLogAZat:=.f.
endif

cIdFirma:=gFirma
cIdKonto:=space(7)
cIdPart:=SPACE(6)

if lAuto
    cIdKonto:=cKto
    cIdPart:=cPtn
    cPobSt := "D"
endif

qqPartner:=SPACE(60)
picD:="@Z "+FormPicL("9 "+gPicBHD,18)
picDEM:="@Z "+FormPicL("9 "+gPicDEM,9)

O_PARTN
O_KONTO

if !lAuto

Box("AZST",6,65,.f.)
set cursor on

 cPobST:="N"  // pobrisati stavke koje su se uzimale zatvorenim

 @ m_x+1,m_y+2 SAY "AUTOMATSKO ZATVARANJE STAVKI"
 if gNW=="D"
   @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+3,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+4,m_y+2 SAY "Konto: " GET cIdKonto  valid P_KontoFin(@cIdKonto)
 @ m_x+5,m_y+2 SAY "Partner (prazno-svi): " GET cIdPart  valid P_Firma(@cIdPart)
 @ m_x+6,m_y+2 SAY "Pobrisati stare markere zatv.stavki: " GET cPobSt pict "@!" valid cPobSt $ "DN"


 read; ESC_BCR


BoxC()

endif
cIdFirma:=left(cIdFirma,2)

O_SUBAN

select SUBAN
set order to tag "3"
// ORDER 3: SUBANi3: IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)
seek cidfirma+cidkonto
EOF CRET

log_write( "otvorene stavke, automatsko zatvaranje", 5 )

if cPobSt=="D" .and. Pitanje(,"Zelite li zaista pobrisati markere ??","N")=="D"

    MsgO("Brisem markere ...")

    f18_lock_tables({LOWER(ALIAS())})
    sql_table_update( nil, "BEGIN" )

    DO WHILESC !eof() .AND. idfirma==cidfirma .and. cIdKonto=IdKonto // konto
        if !Empty(cIdPart)
            if (cIdPart <> idpartner)
                skip
                loop
            endif
        endif

        _rec := dbf_get_rec()
        _rec["otvst"] := " "
        update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )

        SKIP

    ENDDO

    f18_free_tables({LOWER(ALIAS())})
    sql_table_update( nil, "END" )

    MSgC()

endif

Box("count",1,30,.f.)
nC:=0
@ m_x+1,m_y+2 SAY "Zatvoreno:"
@ m_x+1,m_y+12 SAY nC  // brojac zatvaranja

seek cidfirma+cidkonto
EOF CRET

f18_lock_tables({"fin_suban"})
sql_table_update( nil, "BEGIN" )

DO WHILESC !eof() .AND. idfirma==cidfirma .and. cIdKonto=IdKonto // konto

   if !Empty(cIdPart)
    if (cIdPart <> idpartner)
        skip
        loop
    endif
   endif
   cIdPartner=IdPartner
   cBrDok=BrDok
   cOtvSt:=" "
   nDugBHD:=nPotBHD:=0
   DO WHILESC !eof() .AND. idfirma==cidfirma .AND. cIdKonto=IdKonto .AND. cIdPartner=IdPartner .AND. cBrDok==BrDok
   // partner, brdok
      IF D_P="1"
         nDugBHD+=IznosBHD
         cOtvSt:="1"
      ELSE
         nPotBHD+=IznosBHD
         cOtvSt:="1"
      ENDIF
      SKIP
   ENDDO // partner, brdok

    IF ABS(round(nDugBHD-nPotBHD,3)) <= gnLOSt .AND. cOtvSt=="1"
        SEEK cIdFirma+cIdKonto+cIdPartner+cBrDok
        @ m_x+1,m_y+12 SAY ++nC  // brojac zatvaranja
        DO WHILESC !eof() .AND. cIdKonto=IdKonto .and. cIdPartner == IdPartner .and. cBrDok=BrDok
            _rec := dbf_get_rec()
            _rec["otvst"] := "9"
            update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )   
            SKIP
        ENDDO
    ENDIF

ENDDO

f18_free_tables({"fin_suban"})
sql_table_update( nil, "END" )

if lLogAZat
    EventLog(nUser,goModul:oDataBase:cName,"DOK","ASISTENT",nDugBHD,nPotBHD,nC,nil,"","","F:"+cIdFirma+"- K:"+cIdKonto,Date(),Date(),"","Automatsko zatvaranje otvorenih stavki")
endif

BoxC() 
// counter zatvaranja

close all
return


static function _o_ruc_zat( lOsuban )

if lOSuban == NIL
    lOSuban := .f.
endif

O_PARTN
O_KONTO
O_RJ

if lOSuban

    select (F_SUBAN)
    use
    select (F_OSUBAN)
    use

    // otvaram osuban kao suban alijas
    // radi stampe kartice itd...
    select ( F_SUBAN )
    my_use_temp( "SUBAN", my_home() + "osuban", .f., .f. ) 

else
    O_SUBAN
endif

return


// ------------------------------------------------------------------------
// rucno zatvaranje stavki 
// ------------------------------------------------------------------------
function RucnoZat()

_o_ruc_zat()

cIdFirma := gFirma
cIdPartner := space(len(partn->id))

picD := FormPicL("9 "+gPicBHD,14)
picDEM := FormPicL("9 "+gPicDEM,9)

cIdKonto := SPACE(len(konto->id))

Box(,7,66,)

    set cursor on

    @ m_x+1,m_y+2 SAY "ISPRAVKA BROJA VEZE - OTVORENE STAVKE"
    if gNW=="D"
        @ m_x+3,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
    else
        @ m_x+3,m_y+2 SAY "Firma  " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
    endif
    @ m_x+4,m_y+2 SAY "Konto  " GET cIdKonto  valid  P_KontoFin(@cIdKonto)
    @ m_x+5,m_y+2 SAY "Partner" GET cIdPartner valid empty(cIdPartner) .or. P_Firma(@cIdPartner) pict "@!"
    if gRj=="D"
        cIdRj:=SPACE(LEN(RJ->id))
        @ m_x+6,m_y+2 SAY "RJ" GET cidrj pict "@!" valid empty(cidrj) .or. P_Rj(@cidrj)
    endif
    read
    ESC_BCR

BoxC()

if EMPTY(cIdpartner)
    cIdPartner := ""
endif

cIdFirma := LEFT(cIdFirma,2)

select SUBAN
// IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr
set order to tag "1" 

IF gRJ == "D" .and. !EMPTY(cIdRJ)
    SET FILTER TO IDRJ == cIdRj
ENDIF

Box(, MAXROWS() - 5, MAXCOLS() - 10 )

    ImeKol:={}
    AADD(ImeKol,{ "O",          {|| OtvSt}             })
    AADD(ImeKol,{ "Partn.",     {|| IdPartner}         })
    AADD(ImeKol,{ "Br.Veze",    {|| BrDok}             })
    AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}            })
    AADD(ImeKol,{ "Opis",       {|| PADR(opis,20)}, "opis",  {|| .t.}, {|| .t.}, "V"  })
    AADD(ImeKol,{ PADR("Duguje " + ALLTRIM(ValDomaca()),13), {|| str((iif(D_P=="1",iznosbhd,0)),13,2)}     })
    AADD(ImeKol,{ PADR("Potraz." + ALLTRIM(ValDomaca()),13),   {|| str((iif(D_P=="2",iznosbhd,0)),13,2)}     })
    AADD(ImeKol,{ "M1",         {|| m1}                })
    AADD(ImeKol,{ PADR("Iznos "+ALLTRIM(ValPomocna()), 14),  {|| str(iznosdem,14,2)}                       })
    AADD(ImeKol,{ "nalog",      {|| idvn + "-" + brnal +"/" + rbr}                  })
    Kol:={}

    for i := 1 to len(ImeKol)
        AADD(Kol, i)
    next

    Private aPPos:={2,3}  

    // pozicija kolone partner, broj veze

    private bGoreRed := NIL
    private bDoleRed := NIL
    private bDodajRed := NIL
    private fTBNoviRed := .f. // trenutno smo u novom redu ?
    private TBCanClose := .t. // da li se moze zavrsiti unos podataka ?
    private TBAppend := "N"  // mogu dodavati slogove
    private bZaglavlje := NIL
        // zaglavlje se edituje kada je kursor u prvoj koloni
        // prvog reda
    private TBSkipBlock := { |nSkip| SkipDBBK(nSkip) }
    private nTBLine := 1      // tekuca linija-kod viselinijskog browsa
    private nTBLastLine := 1  // broj linija kod viselinijskog browsa
    private TBPomjerise := "" // ako je ">2" pomjeri se lijevo dva
                        // ovo se mo§e setovati u when/valid fjama
    private TBScatter := "N"  // uzmi samo tekuce polje
    adImeKol := {}

    for i:=1 TO LEN(ImeKol)
        AADD(adImeKol,ImeKol[i])
    next

    adKol:={}
    for i:=1 to LEN( adImeKol )
        AADD( adKol,i )
    next

    private bBKUslov := {|| idFirma + idkonto + idpartner = cIdFirma + cIdkonto + cIdpartner }
    private bBkTrazi := {|| cIdFirma + cIdkonto + cIdPartner}

    set cursor on

    private cPomBrDok := SPACE(10)

    seek EVAL( bBkUslov )  

    // prikazi opcije rucnog zatvaranja
    OSt_StatLin()

    ObjDbEdit( "Ost", MAXROWS() - 10, MAXCOLS() - 10, {|| EdRos() }, ;
                "", "", .f., NIL, 1, {|| otvst == "9" }, 6, 0, NIL, { |nSkip| SkipDBBK(nSkip) } )

BoxC()

close all
return


// --------------------------------------------
// key handler otv.st. rucno zatvaranje
// -------------------------------------------- 
function EdROS( l_osuban )
local _rec
local cMark
local cDn  := "N" 
local nRet := DE_CONT
local _otv_st := " "
local _t_rec := RECNO()
local _tb_filter := DbFilter()
local _t_area := SELECT()

if l_osuban == NIL
    l_osuban := .f.
endif

do case

    case Ch == K_ALT_E .and. FIELDPOS("_OBRDOK") = 0  

        // nema prebacivanja u
        // asistentu ot.st.

        IF Pitanje(,"Preci u mod direktog unosa podataka u tabelu? (D/N)","D")=="D"
            log_write( "otovrene stavke, mod direktnog unosa = D", 5 )
            gTBDir := "D"
            OSt_StatLin()
            DaTBDirektni() 
        ENDIF
     
    case Ch == K_ENTER

        cDn := "N"

        Box(, 3, 50)
            @ m_x+1, m_y + 2 SAY "Ne preporucuje se koristenje ove opcije !"
            @ m_x+3, m_y + 2 SAY "Zelite li ipak nastaviti D/N" GET cDN pict "@!" valid cDn $ "DN"
            read
        BoxC()

        if cDN=="D"

            if field->otvst <> "9"
                cMark   := ""
                _otv_st := "9" 
            else
                cMark   := "9"
                _otv_st := " "
            endif
      
            _rec := dbf_get_rec()
            _rec["otvst"] := _otv_st
            update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )
            
            log_write( "otvorene stavke, set marker=" + cMark, 5 )

            nRet := DE_REFRESH

        else

            nRet:=DE_CONT

        endif

    case ( Ch == ASC("K") .or. Ch == ASC("k") )
   
        if field->m1 <> "9"
            _otv_st := "9"
        else
            _otv_st := " "
        endif
        log_write( "otvorene stavke, marker=" + _otv_st, 5 )
        _rec := dbf_get_rec()
        _rec["m1"] := _otv_st
        
        update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )
        
        nReti := DE_REFRESH

    case Ch == K_F2
 
        cBrDok := field->BrDok
        cOpis := field->opis
        dDatDok := field->datdok
        dDatVal := field->datval

        Box("eddok", 5, 70, .f.)
            @ m_x+1, m_y+2 SAY "Broj Dokumenta (broj veze):" GET cBrDok
            @ m_x+2, m_y+2 SAY "Opis:" GET cOpis PICT "@S50"
            @ m_x+4, m_y+2 SAY "Datum dokumenta: " 
            ?? dDatDok
            @ m_x+5, m_y+2 SAY "Datum valute   :" GET dDatVal
            read
        BoxC()

        if lastkey() <> K_ESC

            _rec := dbf_get_rec()

            _rec["brdok"] := cBrDok
            _rec["opis"]  := cOpis
            _rec["datval"] := dDatVal
            log_write( "otvorene stavke, ispravka broja veze, set=" + cBrDok, 5 )
            update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )
                
        endif

        nRet := DE_REFRESH

    case Ch == K_F5

        cPomBrDok := field->BrDok

    case Ch == K_F6

        if fieldpos("_OBRDOK") <> 0  
            // nalazimo se u asistentu
            StAz()
            
            _o_ruc_zat( l_osuban )
            select ( _t_area )
            set filter to &(_tb_filter)
            go ( _t_rec )


        else
            if Pitanje(,"Zelite li da vezni broj "+ BrDok + " zamijenite brojem "+cPomBrDok+" ?","D") == "D"
    
                _rec := dbf_get_rec()
                _rec["brdok"] := cPomBrDok
                log_write( "otvorene stavke, zamjena broja veze, set=" + cPomBrDok, 5 )
                update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )
    
            endif
        endif

        nRet := DE_REFRESH

    case Ch == K_CTRL_P

        StKart()
         
        _o_ruc_zat( l_osuban )
        select ( _t_area )
        set filter to &(_tb_filter)
        go ( _t_rec )

       
        nRet := DE_REFRESH

    case Ch == K_ALT_P

        StBrVeze()
        
        _o_ruc_zat( l_osuban )
        select ( _t_area )
        set filter to &(_tb_filter)
        go ( _t_rec )

        nRet := DE_REFRESH

endcase

return nRet



// --------------------------------------------
// --------------------------------------------
function OSt_StatLin()
local _x, _y

_x := m_x + MAXROWS() - 15
_y := m_y + 1

@ _x,     _y SAY " <F2>   Ispravka broja dok.       <c-P> Print   <a-P> Print Br.Dok          "
@ _x + 1, _y SAY " <K>    Ukljuci/iskljuci racun za kamate         <F5> uzmi broj dok.        "
@ _x + 2, _y SAY '<ENTER> Postavi/Ukini zatvaranje                 <F6> "nalijepi" broj dok.  '

@ _x + 3, _y SAY REPL( BROWSE_PODVUCI, MAXCOLS() - 12 )

@ _x + 4, _y SAY ""
?? "Konto:", cIdKonto

return



/*! \fn StKart(fSolo,fTiho,bFilter)
 *  \brief Otvorene stavke grupisane po brojevima veze
 *  \param fSolo
 *  \param fTiho
 *  \param bFilter - npr. {|| getmjesto(cMjesto)}
 */
 
function StKart(fSolo,fTiho,bFilter)
local nCol1:=72, cSvi:="N", cSviD:="N", lEx:=.f.

IF fTiho==NIL
    fTiho:=.f.
ENDIF

private cIdPartner

cDokument:=SPACE(8)
picBHD:=FormPicL(gPicBHD,14)
picDEM:=FormPicL(gPicDEM,10)

IF fTiho .or. Pitanje(,"Zelite li prikaz sa datumima dokumenta i valutiranja ? (D/N)","D")=="D"
   lEx:=.t.         // lEx=.t. > varijanta napravljena za EXCLUSIVE
ENDIF

if fsolo==NIL
   fSolo:=.f.  // fsolo=.t. > poziv iz menija
endif

IF gVar1=="0"
   M:="----------- ------------- -------------- -------------- ---------- ---------- ---------- --"
ELSE
   M:="----------- ------------- -------------- -------------- --"
ENDIF

IF lEx
   m := "-------- -------- -------- " + m
ENDIF

nStr := 0
fVeci := .f.
cPrelomljeno := "N"

if fTiho

    cSvi:="D"

elseif fsolo

    O_SUBAN
    O_PARTN
    O_KONTO
    cIdFirma := gFirma
    cIdkonto := space(7)
    cIdPartner := space(6)

    Box(,5,60)
        if gNW=="D"
            @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
        else
            @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
        endif
        @ m_x+2,m_y+2 SAY "Konto:               " GET cIdkonto   pict "@!"  valid P_kontoFin(@cIdkonto)
        @ m_x+3,m_y+2 SAY "Partner (prazno svi):" GET cIdpartner pict "@!"  valid empty(cIdpartner)  .or. ("." $ cidpartner) .or. (">" $ cidpartner) .or. P_Firma(@cIdPartner)
        @ m_x+5,m_y+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cPrelomljeno $ "DN" pict "@!"
        read
        ESC_BCR
    Boxc()
else
    if Pitanje(,"Zelite li napraviti ovaj izvjestaj za sve partnere ?","N")=="D"
        cSvi:="D"
    endif
endif

if !fTiho .and. Pitanje(,"Prikazati dokumente sa saldom 0 ?","N")=="D"
   cSviD:="D"
endif

if fTiho
    // onda svi
elseif !fsolo

    if type('TB')="O"
        if VALTYPE(aPPos[1])="C"
            private cIdPartner:=aPPos[1]
        else
            private cIdPartner:=EVAL(TB:getColumn(aPPos[1]):Block)
        endif
    endif

else

    if "." $ cidpartner
        cidpartner:=strtran(cidpartner,".","")
        cIdPartner:=trim(cidPartner)
    endif

    if ">" $ cidpartner
        cidpartner:=strtran(cidpartner,">","")
        cIdPartner:=trim(cidPartner)
        fVeci:=.t.
    endif

    if empty(cIdpartner)
        cidpartner:=""
    endif

    cSvi := cIdpartner

endif

IF fTiho .or. lEx

    // odredjivanje prirode zadanog konta (dug. ili pot.)
    // --------------------------------------------------

    select (F_TRFP2)
    if !used()
        O_TRFP2
    endif

    HSEEK "99 "+LEFT(cIdKonto,1)
    DO WHILE !EOF() .and. IDVD=="99" .and. TRIM(idkonto)!=LEFT(cIdKonto,LEN(TRIM(idkonto)))
        SKIP 1
    ENDDO

    IF IDVD=="99" .and. TRIM(idkonto)==LEFT(cIdKonto,LEN(TRIM(idkonto)))
        cDugPot := D_P
    ELSE
        cDugPot:="1"
        Box( , 3, 60)
            @ m_x+2, m_y+2 SAY "Konto " + cIdKonto + " duguje / potrazuje (1/2)" GET cdugpot  VALID cdugpot $ "12" PICT "9"
            READ
        Boxc()
    ENDIF

    fin_create_pom_table(fTiho)

ENDIF


if !fTiho
    START PRINT RET
endif

nUkDugBHD := nUkPotBHD := 0

select suban
set order to tag "3"

if cSvi=="D"
    seek cidfirma+cidkonto
else
    seek cidfirma+cidkonto+cidpartner
endif

DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto

    if bFilter <> NIL
        if !eval(bFilter)
            SKIP
            LOOP
        endif
    endif

    cidPartner := idpartner

    nUDug2 := nUPot2 := 0
    nUDug := nUPot := 0
    fPrviprolaz := .t.

    DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner

        if bFilter<>NIL
            if !eval(bFilter)
                skip
                loop
            endif
        endif

        cBrDok:=BrDok; cOtvSt:=otvst
        nDug2:=nPot2:=0
        nDug:=nPot:=0
        aFaktura:={ CTOD(""), CTOD(""), CTOD("") }

        DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner ;
                     .and. brdok==cBrDok
            IF D_P=="1"
                nDug+=IznosBHD
                nDug2+=IznosDEM
            ELSE
                nPot+=IznosBHD
                nPot2+=IznosDEM
            ENDIF
            
            IF lEx .and. D_P == cDugPot
                aFaktura[1] := DATDOK
               aFaktura[2] := DATVAL
            ENDIF

            IF fTiho     
                // poziv iz procedure RekPPG()
                // za izvjestaj maksuz radjen za Opresu³22.03.01.³
                // ------------------------------------ÀÄ MSÄÄÄÄÄÙ
                if afaktura[3] < iif( empty(DatVal), DatDok, DatVal )
                    // datum zadnje promjene iif ubacen 03.11.2000 eh
                    // ----------------------------------------------
                    aFaktura[3]:=iif( empty(DatVal), DatDok, DatVal )
               endif
            ELSE
                // kao u asist.otv.stavki - koristi npr. Exclusive³22.03.01.³
                // -----------------------------------------------ÀÄ MSÄÄÄÄÄÙ
                if afaktura[3] < DatDok
                    aFaktura[3]:=DatDok
                endif
            ENDIF

            SKIP 1
        ENDDO

        if csvid=="N" .and. round(ndug-npot,2)==0
            // nista
        else
            IF lEx
                fPrviProlaz:=.f.
                if cPrelomljeno=="D"
                    if (ndug-npot)>0
                        nDug:=nDug-nPot
                        nPot:=0
                    else
                        nPot:=nPot-nDug
                        nDug:=0
                    endif
                    if (ndug2-npot2)>0
                        nDug2:=nDug2-nPot2
                        nPot2:=0
                    else
                        nPot2:=nPot2-nDug2
                        nDug2:=0
                    endif
            endif
            //
            SELECT POM
            APPEND BLANK
            Scatter()
            _idpartner := cIdPartner
            _datdok    := aFaktura[1]
            _datval    := aFaktura[2]
            _datzpr    := aFaktura[3]
            if empty(_DatDok) .and. empty(_DatVal) 
                _DatVal:=_DatZPR
            endif
            _brdok     := cBrDok
            _dug       := nDug
            _pot       := nPot
            _dug2      := nDug2
            _pot2      := nPot2
            _otvst     := cOtvSt
            Gather()
            SELECT SUBAN
        ELSE
            if !fTiho
                IF prow() > 52 + gPStranica
                    FF
                    ZagKStSif(.t.,lEx)
                    fPrviProlaz:=.f.
                ENDIF
                if fPrviProlaz
                    ZagkStSif(,lEx)
                    fPrviProlaz:=.f.
                endif
                ? padr(cBrDok,10)
                nCol1:=pcol()+1
            endif
            if cPrelomljeno=="D"
                if (ndug-npot)>0
                   nDug:=nDug-nPot
                   nPot:=0
                else
                   nPot:=nPot-nDug
                   nDug:=0
                endif
                if (ndug2-npot2)>0
                   nDug2:=nDug2-nPot2
                   nPot2:=0
                else
                   nPot2:=nPot2-nDug2
                   nDug2:=0
                endif
            endif
            if !fTiho
               @ prow(),nCol1 SAY nDug PICTURE picBHD
               @ prow(),pcol()+1  SAY nPot PICTURE picBHD
               @ prow(),pcol()+1  SAY nDug-nPot PICTURE picBHD
               IF gVar1=="0"
                @ prow(),pcol()+1  SAY nDug2 PICTURE picdem
                @ prow(),pcol()+1  SAY nPot2 PICTURE picdem
                @ prow(),pcol()+1  SAY nDug2-nPot2 PICTURE picdem
               ENDIF
               @ prow(),pcol()+2  SAY cOtvSt
            endif
            nUDug+=nDug; nUPot+=nPot
            nUDug2+=nDug2; nUPot2+=nPot2
        ENDIF
    endif

enddo 
// partner

if !fTiho
      
    IF prow()>58+gPStranica
        FF
        ZagKStSif(.t.,lEx)
    ENDIF
      
    if !lEx .and. !fPrviProlaz  
        // bilo je stavki
        ? M
        ? "UKUPNO:"
        @ prow(),nCol1 SAY nUDug PICTURE picBHD
        @ prow(),pcol()+1 SAY nUPot PICTURE picBHD
        @ prow(),pcol()+1 SAY nUDug-nUPot PICTURE picBHD
        IF gVar1=="0"
            @ prow(),pcol()+1 SAY nUDug2 PICTURE picdem
            @ prow(),pcol()+1 SAY nUPot2 PICTURE picdem
            @ prow(),pcol()+1 SAY nUDug2-nUPot2 PICTURE picdem
        ENDIF
        ? m
    endif
endif
  
if fTiho
    // idu svi
  elseif fsolo // iz menija
    if (!fveci .and. idpartner=cSvi) .or. fVeci
      if !lEx .and. !fPrviProlaz
       ? ;  ? ; ?
      endif
    else
      exit
    endif
  else
   if cSvi<>"D"
     exit
   else
      if !lEx .and. !fPrviProlaz
       ? ;  ? ; ?
      endif
   endif
  endif // fsolo
enddo

IF !fTiho .and. lEx   // ako je EXCLUSIVE, sada tek stampaj
  SELECT POM
  GO TOP
  DO WHILE !EOF()
    fPrviProlaz:=.t.
    cIdPartner:=IDPARTNER
    nUDug:=nUPot:=nUDug2:=nUPot2:=0
    DO WHILESC !EOF() .and. cIdPartner==IdPartner
      IF prow()>52+gPStranica; FF; ZagKStSif(.t.,lEx); fPrviProlaz:=.f.; ENDIF
      if fPrviProlaz
         ZagkStSif(,lEx)
         fPrviProlaz:=.f.
      endif
      SELECT POM
      ? datdok,datval,datzpr, PADR(brdok,10)
      nCol1:=pcol()+1
      ?? " "
      ?? TRANSFORM(dug,picbhd),;
         TRANSFORM(pot,picbhd),;
         TRANSFORM(dug-pot,picbhd)
      IF gVar1=="0"
        ?? " "+TRANSFORM(dug2,picdem),;
               TRANSFORM(pot2,picdem),;
               TRANSFORM(dug2-pot2,picdem)
      ENDIF
      ?? "  "+otvst
      nUDug+=Dug; nUPot+=Pot
      nUDug2+=Dug2; nUPot2+=Pot2
      SKIP 1
    ENDDO
    IF prow()>58+gPStranica; FF; ZagKStSif(.t.,lEx); ENDIF
    SELECT POM
    if !fPrviProlaz  // bilo je stavki
      ? M
      ? "UKUPNO:"
      @ prow(),nCol1 SAY nUDug PICTURE picBHD
      @ prow(),pcol()+1 SAY nUPot PICTURE picBHD
      @ prow(),pcol()+1 SAY nUDug-nUPot PICTURE picBHD
      IF gVar1=="0"
        @ prow(),pcol()+1 SAY nUDug2 PICTURE picdem
        @ prow(),pcol()+1 SAY nUPot2 PICTURE picdem
        @ prow(),pcol()+1 SAY nUDug2-nUPot2 PICTURE picdem
      ENDIF
      ? m
    endif
    ? ; ? ; ?
  ENDDO
ENDIF

if fTiho
  RETURN (NIL)
endif

FF

END PRINT

select (F_POM); use

IF fSolo
  CLOSERET
ELSE
  RETURN (NIL)
ENDIF




/*! \fn fin_create_pom_table(fTiho)
 *  \brief Kreira pomocnu tabelu
 *  \fTiho
 */
 
function fin_create_pom_table(fTiho, nParLen)
local i
local nPartLen
local _alias := "POM"
local _ime_dbf := my_home() + "pom"
local aDbf, aGod

if fTiho==NIL
    fTiho:=.f.
endif

select ( F_POM )
use

if nParLen == nil
    nParLen := 6
endif

// kreiranje pomocne baze POM.DBF
// ------------------------------

FERASE( _ime_dbf + ".dbf" )
FERASE( _ime_dbf + ".cdx" )

aDbf := {}
AADD(aDBf,{ 'IDPARTNER'   , 'C' ,  nParLen ,  0 })
AADD(aDBf,{ 'DATDOK'      , 'D' ,  8 ,  0 })
AADD(aDBf,{ 'DATVAL'      , 'D' ,  8 ,  0 })
AADD(aDBf,{ 'BRDOK'       , 'C' , 10 ,  0 })
AADD(aDBf,{ 'DUG'         , 'N' , 17 ,  2 })
AADD(aDBf,{ 'POT'         , 'N' , 17 ,  2 })
AADD(aDBf,{ 'DUG2'        , 'N' , 15 ,  2 })
AADD(aDBf,{ 'POT2'        , 'N' , 15 ,  2 })
AADD(aDBf,{ 'OTVST'       , 'C' ,  1 ,  0 })
AADD(aDBf,{ 'DATZPR'      , 'D' ,  8 ,  0 })  

// datum zadnje promjene
if fTiho
  FOR i := 1 TO LEN(aGod)
    AADD(aDBf, { 'GOD'+aGod[i,1], 'N' , 15 ,  2 }) 
  NEXT
  AADD(aDBf, { 'GOD'+STR(VAL(aGod[i-1,1])-1, 4), 'N' , 15 ,  2 })
  AADD(aDBf, { 'GOD'+STR(VAL(aGod[i-1,1])-2, 4), 'N' , 15 ,  2 })
endif

DBCREATE( _ime_dbf + ".dbf", aDbf )
use

select ( F_POM )
my_use_temp( _alias, _ime_dbf, .f., .t. )

index on ( IDPARTNER + DTOS(DATDOK) + DTOS( IIF(EMPTY(DATVAL), DATDOK, DATVAL) ) + BRDOK ) TAG "1"

SET ORDER TO TAG "1" 
GO TOP

return .t.




/*! \fn ZagKStSif(fStrana,lEx)
 *  \brief Zaglavlje kartice OS-a
 *  \param fStrana
 *  \param lEx
 */
function ZagKStSif(fStrana,lEx)
?
IF gVar1=="0"
  IF lEx
    P_COND
  ELSE
    F12CPI
  ENDIF
ELSE
  F10CPI
ENDIF
if fStrana==NIL
  fStrana:=.f.
endif

if nStr=0
  fStrana:=.t.
endif

?? "FIN.P: OTV.STAVKE - PREGLED (GRUPISANO PO BROJEVIMA VEZE)  NA DAN "; ?? DATE()
if fStrana
 @ prow(),110 SAY "Str:"+str(++nStr,3)
endif

SELECT PARTN
HSEEK cIdFirma
? "FIRMA:",cIdFirma,"-",gNFirma

SELECT KONTO
HSEEK cIdKonto

? "KONTO  :",cIdKonto,naz

SELECT PARTN
HSEEK cIdPartner
? "PARTNER:", cIdPartner,TRIM(naz)," ",TRIM(naz2)," ",TRIM(mjesto)

select suban
? M
?
IF lEx
  ?? "Dat.dok.*Dat.val.*Dat.ZPR.* "
ELSE
  ?? "*"
ENDIF
IF gVar1=="0"
 ?? "  BrDok   *   dug "+ValDomaca()+"  *   pot "+ValDomaca()+"   *  saldo  "+ValDomaca()+" * dug "+ValPomocna()+" * pot "+ValPomocna()+" *saldo "+ValPomocna()+"*O*"
ELSE
 ?? "  BrDok   *   dug "+ValDomaca()+"  *   pot "+ValDomaca()+"   *  saldo  "+ValDomaca()+" *O*"
ENDIF
? M

SELECT SUBAN
RETURN




/*! \fn StBrVeze()
 *  \brief Stampa broja veze
 */
 
function StBrVeze()

local nCol1:=35
cDokument:=SPACE(8)
picBHD:=FormPicL(gPicBHD,13)
picDEM:=FormPicL(gPicDEM,10)
IF gVar1=="0"
 M:="-------- -------- "+"------- ---- -- ------------- ------------- ------------- ---------- ---------- ---------- --"
ELSE
 M:="-------- -------- "+"------- ---- -- ------------- ------------- ------------- --"
ENDIF

nStr:=0

START PRINT RET


if VALTYPE(aPPos[1])="C"
   private cIdPartner:=aPPos[1]
else
   private cIdPartner:=EVAL(TB:getColumn(aPPos[1]):Block)
endif
if VALTYPE(aPPos[2])="C"
   private cBrDok:=aPPos[2]
else
   private cBrDok:=EVAL(TB:getColumn(aPPos[2]):Block)
endif

nUkDugBHD:=nUkPotBHD:=0
select suban; set order to tag "3"
seek cidfirma+cidkonto+cidpartner+cBrDok


nDug2:=nPot2:=0
nDug:=nPot:=0
ZagBRVeze()
DO WHILESC !EOF() .and. idfirma==cidfirma .AND. cIdKonto==IdKonto .and. cIdPartner==IdPartner ;
        .and. brdok==cBrDok

         IF prow()>63+gPStranica; FF; ZagBRVeze(); ENDIF
         ? datdok,datval,idvn,brnal,rbr,idtipdok
         nCol1:=pcol()+1
         IF D_P=="1"
            nDug+=IznosBHD
            nDug2+=IznosDEM
            @ prow(),pcol()+1 SAY iznosbhd pict picbhd
            @ prow(),pcol()+1 SAY space(len(picbhd))
            @ prow(),pcol()+1  SAY nDug-nPot pict picbhd
            IF gVar1=="0"
             @ prow(),pcol()+1 SAY iznosdem pict picdem
             @ prow(),pcol()+1 SAY space(len(picdem))
             @ prow(),pcol()+1  SAY nDug2-nPot2 pict picdem
            ENDIF
         ELSE
            nPot+=IznosBHD
            nPot2+=IznosDEM
            @ prow(),pcol()+1 SAY space(len(picbhd))
            @ prow(),pcol()+1 SAY iznosbhd pict picbhd
            @ prow(),pcol()+1  SAY nDug-nPot  pict picbhd
            IF gVar1=="0"
             @ prow(),pcol()+1 SAY space(len(picdem))
             @ prow(),pcol()+1 SAY iznosdem pict picdem
             @ prow(),pcol()+1  SAY nDug2-nPot2  pict picdem
            ENDIF
         ENDIF
         @ prow(),pcol()+2  SAY OtvSt
         skip
enddo // partner

IF prow() > 62+gPStranica
  FF
  ZagBRVeze()
ENDIF

? m
? "UKUPNO:"
@ prow(),nCol1     SAY nDug PICTURE picBHD
@ prow(),pcol()+1  SAY nPot PICTURE picBHD
@ prow(),pcol()+1  SAY nDug-nPot PICTURE picBHD
IF gVar1=="0"
 @ prow(),pcol()+1  SAY nDug2 PICTURE picdem
 @ prow(),pcol()+1  SAY nPot2 PICTURE picdem
 @ prow(),pcol()+1  SAY nDug2-nPot2 PICTURE picdem
ENDIF
? m

FF
END PRINT



/*! \fn ZagBRVeze()
 *  \brief Zaglavlje izvjestaja broja veze
 */
 
function ZagBRVeze()
?
IF gVar1=="0"
 P_COND
ELSE
 F12CPI
ENDIF
?? "FIN.P: KARTICA ZA ODREDJENI BROJ VEZE      NA DAN "; ?? DATE()
@ prow(),110 SAY "Str:"+str(++nStr,3)
SELECT PARTN; HSEEK cIdFirma
? "FIRMA:", cIdFirma,naz, naz2

SELECT KONTO; HSEEK cIdKonto
? "KONTO  :", cIdKonto,naz

SELECT PARTN; HSEEK cIdPartner
? "PARTNER:", cIdPartner,TRIM(naz)," ",TRIM(naz2)," ",TRIM(mjesto)

select suban
? "BROJ VEZE :",cBrDok
? M
IF gVar1=="0"
 ? "Dat.dok.*Dat.val."+"*NALOG * Rbr*TD*   dug "+ValDomaca()+"   *  pot "+ValDomaca()+"  *   saldo "+ValDomaca()+"*  dug "+ValPomocna()+"* pot "+ValPomocna()+" *saldo "+ValPomocna()+"* O"
ELSE
 ? "Dat.dok.*Dat.val."+"*NALOG * Rbr*TD*   dug "+ValDomaca()+"   *  pot "+ValDomaca()+"  *   saldo "+ValDomaca()+"* O"
ENDIF
? M

SELECT SUBAN
RETURN


// ------------------------------------------------------------------
// kreiraj oext
// ------------------------------------------------------------------
static function _cre_oext_struct()
local _table := "osuban"
local _struct 
local _ret := .t.

FERASE( my_home() + _table + ".cdx" )

select SUBAN
set order to tag "3" 

// uzmi suban strukturu
_struct := suban->( DBSTRUCT() )

// dodaj nova polja u strukturu
AADD( _struct, { "_RECNO"   , "N",  8,  0 } )
AADD( _struct, { "_PPK1"    , "C",  1,  0 } )
AADD( _struct, { "_OBRDOK"  , "C", 10,  0 } )

select ( F_OSUBAN )

// kreiraj tabelu
DbCreate( my_home() + "osuban.dbf", _struct )

// otvori osuban ekskluzivno
select ( F_OSUBAN )
my_use_temp( "OSUBAN", my_home() + _table + ".dbf", .f., .t. )

// kreiraj indekse
index on IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr tag "1"
index on idfirma+idkonto+idpartner+brdok tag "3"
index on dtos(datdok)+dtos(iif(empty(DatVal),DatDok,DatVal)) tag "DATUM"


return _ret



// ----------------------------------------------------------------
// asistent otvorenih stavki 
// ----------------------------------------------------------------
function fin_asistent_otv_st()
local nSaldo
local nSljRec
local nOdem
local _rec, _rec_suban
local _max_rows := MAXROWS() - 5
local _max_cols := MAXCOLS() - 5
private cIdKonto
private cIdFirma
private cIdPartner
private cBrDok

O_KONTO
O_PARTN
O_SUBAN

// ovo su parametri kartice
cIdFirma := gFirma
cIdKonto := space(len(suban->idkonto))
cIdPartner := space(len(suban->idPartner))

cIdFirma := fetch_metric("fin_kartica_id_firma", my_user(), cIdFirma )
cIdKonto := fetch_metric("fin_kartica_id_konto", my_user(), cIdKonto )
cIdPartner := fetch_metric( "fin_kartica_id_partner", my_user(), cIdPartner ) 

cIdKonto := padr(cidkonto,len(suban->idkonto))
cIdPartner := padr(cidpartner,len(suban->idPartner))
// kupci cDugPot:=1
cDugPot:="1"

Box(,3,60)
    @ m_x+1,m_y+2 SAY "Konto   " GET cIdKonto   valid p_kontoFin(@cIdKonto)  pict "@!"
    @ m_x+2,m_y+2 SAY "Partner " GET cIdPartner valid P_Firma(@cIdPartner) pict "@!"
    @ m_x+3,m_y+2 SAY "Konto duguje / potrazuje" get cdugpot when {|| cDugPot:=iif(cidkonto='54','2','1'), .t.} valid  cdugpot$"12"
    read
BoxC()

if LastKey() == K_ESC 
    return
endif

set_metric("fin_kartica_id_firma", my_user(), cIdFirma )
set_metric("fin_kartica_id_konto", my_user(), cIdKonto )
set_metric( "fin_kartica_id_partner", my_user(), cIdPartner ) 

// kreiraj oext
if !_cre_oext_struct()
    return
endif

select suban
seek cIdfirma + cIdkonto + cIdpartner

// ukupan broj storno racuna za partnera
nBrojStornoRacuna := 0

do while !EOF() .and. field->idfirma + field->idkonto + field->idpartner = cIdfirma + cIdkonto + cIdpartner

    cBrDok := field->brdok
    nSaldo := 0

    // proracunaj saldo za partner+dokument
    do while !EOF() .and. cIdfirma + cIdkonto + cIdpartner + cBrdok = field->idfirma + field->idkonto + field->idpartner + field->brdok

        if cDugPot = field->d_p .and. empty( field->brdok )
            MsgBeep("Postoje nepopunjen brojevi veze :" + ;
                field->idvn + "-" + field->brdok + "/" + field->rbr + "##Morate ih popuniti !")
            close all
            return
        endif

        if field->d_p = "1"
            nSaldo += field->iznosbhd
        else
            nSaldo -= field->iznosbhd
        endif
        skip
    enddo

    // saldo za dokument + partner postoji
    if ROUND( nSaldo, 4 ) <> 0 
        // napuni tabelu osuban za partner+dokument
        seek cIdfirma + cIdkonto + cIdpartner + cBrdok
        lStorno := .f.

        do while !EOF() .and. cIdfirma + cIdkonto + cIdpartner + cBrdok == ;
            field->idfirma + field->idkonto + field->idpartner + field->brdok
            
            select suban
            _rec_suban := dbf_get_rec()
            
            select osuban
            append blank
            // upisi mi sve u osuban iz suban
            dbf_update_rec( _rec_suban )
    
            // a sada poradi na ovom zapisu
            _rec := dbf_get_rec()
            
            _rec["_recno"] := suban->(recno())
            _rec["_ppk1"] := ""
            _rec["_obrdok"] := _rec["brdok"]
                
            if ( _rec["iznosbhd"] < 0 .and. _rec["d_p"] == cDugPot )
                lStorno := .t.
            endif

            if (( nSaldo > 0 .and. cDugPot = "2" ) ) .and. _rec["d_p"] <> cDugPot
                // neko je bez veze zatvorio uplate (ili se mozda radi o avansima)
                _rec["brdok"] := "AVANS"
            endif
              
            dbf_update_rec( _rec )  
                
            select suban
            skip
        
        enddo

        if lStorno
            ++nBrojStornoRacuna
        endif

    endif

enddo

select osuban 
set order to tag "DATUM"

do while .t.

    // svaki put prolazim ispocetka
    select osuban
    go top

    //varijabla koja kazuje da je racun/storno racun nadjen
    fNasao:=.f.
    
    // prvi krug  (nadji ukupno stvorene obaveze za jednog partnera
    nZatvori:=0
    // nijedan brdok dokument u bazi ne moze biti chr(200)+chr(255)
        
    cZatvori:=chr(200)+chr(255)
    dDatDok:=CTOD("")

    nZatvoriStorno:=0
    cZatvoriStorno:=chr(200)+chr(255)
    dDatDokStorno:=CTOD("")

    // ovdje su sada sve stavke za jednog partnera, sortirane hronoloski
    do while !EOF()

        // neobradjene stavke
        if EMPTY( field->_ppk1 ) 

            // nastanak duga
            if !fNasao .and. field->d_p == cDugPot 

                
                if ( field->iznosbhd > 0 )
                    if nBrojStornoRacuna>0
                        // prvo se moraju zatvoriti storno racuni
                        // zato preskacemo sve pozitivne racune koji se nalaze ispred

                        //MsgBeep("debug: pozitivne preskacem " + STR(nBrojStornoRacuna) + "  BrDok:" +  brdok )
                        skip
                        loop
                    endif
                    //racun
                    nZatvori := field->iznosbhd
                    cZatvori := field->brdok
                    dDatDok := field->datdok
                    cZatvoriStorno:=chr(200)+chr(255)
                 
                else

                    // storno racun
                    nZatvoriStorno := field->iznosbhd
                    cZatvoriStorno := field->brdok
                    dDatDokStorno := field->datdok
                    cZatvori:=chr(200)+chr(255)
                    --nBrojStornoRacuna
                    //MsgBeep("debug: -- " + STR(nBrojStornoRacuna) + " / BrDok:" + BrDok)

                endif

                fNasao := .t.
                
                _rec := dbf_get_rec()
                _rec["_ppk1"] := "1"
                dbf_update_rec( _rec )
                // prosli smo ovo
                go top 
                // idi od pocetka da saberes czatvori
                loop

            elseif fNasao .and. (cZatvori == field->brdok)

                // sve ostale stavke koje su hronoloski starije
                //  koje imaju isti broj dokumenta kao nadjeni racun
                // saberi

                if field->d_p == cDugPot
                    nZatvori += field->iznosbhd
                else
                    nZatvori -= field->iznosbhd
                endif

                _rec := dbf_get_rec()
                _rec["_ppk1"] := "1"
                dbf_update_rec( _rec )
                // prosli smo ovo - marker

            elseif fNasao .and. (cZatvoriStorno == field->brdok) 

                // isto vrijedi i za stavke iza storno racuna
                // a koje imaju isti broj veze
                
                if field->d_p == cDugPot
                    nZatvoriStorno += field->iznosbhd
                else
                    nZatvoriStorno -= field->iznosbhd
                endif
                    
                _rec := dbf_get_rec()
                _rec["_ppk1"] := "1"
                dbf_update_rec( _rec )
                // prosli smo ovo

            endif

        endif 
        skip
    enddo
        
    if !fNasao
        // nema racuna za zatvoriti
        MsgBeep("prosao sve racune - nisam  nista nasao - izlazim")
        exit 
    endif

    // drugi krug - sada se formiraju uplate
    //MsgBeep("2.krug: idem sada formirati uplate - zatvaranje racuna ")
    fNasao:=.f.
    go top

    do while !EOF()

        if empty(field->_ppk1)

            // potrazna strana
            if field->d_p <> cDugPot 

                nUplaceno := field->iznosbhd

                // prvo cemo se rijesiti storno racuna, ako ih ima
                if nUplaceno > 0  .and. ABS( nZatvoriStorno ) > 0 .and. ( dDatDokStorno <= field->datdok )

                    skip
                    nSljRec := RECNO()
                    skip -1
                    nOdem := field->iznosdem - nZatvoriStorno * field->iznosdem / field->iznosbhd
                                    
                    _rec := dbf_get_rec()

                    // zatvaram storno racun
                    _rec["brdok"] := cZatvoriStorno
                    _rec["_ppk1"] := "1"
                    _rec["iznosbhd"] := nZatvoriStorno
                    _rec["iznosdem"] := field->iznosdem - nODem

                    dbf_update_rec( _rec )

                    _rec := dbf_get_rec()
                    _rec["iznosbhd"] := nUplaceno - nZatvoriStorno
                    _rec["iznosdem"] := nOdem

                    if ROUND(_rec["iznosbhd"],4) <> 0 .and. ROUND( nOdem, 4 ) <> 0
                    
                        // prebacujem ostatak uplate na novu stavku
                        append blank

                        _rec["brdok"] := "AVANS"
                        _rec["_ppk1"] := ""

                        // resetuj broj zapisa iz suban tabele !
                        _rec["_recno"] := 0

                        // sredi mi redni broj stavke
                        // na osnovu zadnjeg broja unutar naloga
                        _rec["rbr"] := fin_dok_get_next_rbr( _rec["idfirma"], _rec["idvn"], _rec["brnal"] )

                        dbf_update_rec( _rec )

                    endif
                              
                    nZatvoriStorno := 0
                    go nSljRec 
                    loop

                elseif nUplaceno>0 .and. nZatvori>0  
                    
                    //pozitivni iznosi
                    if nZatvori >= nUplaceno  

                        _rec := dbf_get_rec()
                        _rec["brdok"] := cZatvori
                        _rec["_ppk1"] := "1"
                        dbf_update_rec( _rec )
                        nZatvori -= nUplaceno

                    elseif nZatvori < nUplaceno
                        
                        // imamo i ostatak sredstava razbij uplatu !!
                        skip
                        nSljRec := RECNO()
                        skip -1

                        nOdem := field->iznosdem - nZatvori * field->iznosdem / field->iznosbhd

                        // alikvotni dio..HA HA HA

                        _rec := dbf_get_rec()

                        _rec["brdok"] := cZatvori
                        _rec["_ppk1"] := "1"
                        _rec["iznosbhd"] := nZatvori
                        _rec["iznosdem"] := field->iznosdem - nODem

                        dbf_update_rec( _rec )
                        
                        _rec := dbf_get_rec()
                                
                        _rec["iznosbhd"] := nUplaceno - nZatvori
                        _rec["iznosdem"] := nOdem
                                
                        if ROUND( _rec["iznosbhd"], 4 ) <> 0 .and. ROUND( nOdem, 4 ) <> 0
                            
                            append blank
                            
                            _rec["brdok"] := "AVANS"
                            _rec["_ppk1"] := ""

                            // resetuj broj zapisa iz suban tabele !
                            _rec["_recno"] := 0

                            // sredi mi redni broj stavke
                            // na osnovu zadnjeg broja unutar naloga
                            _rec["rbr"] := fin_dok_get_next_rbr( _rec["idfirma"], _rec["idvn"], _rec["brnal"] )

                            dbf_update_rec( _rec )
                            
                        endif
                        
                        nZatvori := 0

                        go nSljRec 
                        loop

                    endif
                    
                    if nZatvori <= 0
                        exit
                    endif  

                endif  

            endif
 
        endif 

        skip
    
    enddo

enddo

// !!! markiraj stavke koje su postale zatvorene
set order to tag "3"
go top

do while !eof()
    
    cBrDok:=brdok
    nSaldo:=0
    nSljRec:=recno()
    
    do while !eof() .and. cidfirma+cidkonto+cidpartner+cbrdok=idfirma+idkonto+idpartner+brdok
        if d_p == "1"
            nSaldo += iznosbhd
        else
            nSaldo -= iznosbhd
        endif
        skip
    enddo
    if round(nsaldo,4)=0
        go nSljRec
        do while !eof() .and. cidfirma+cidkonto+cidpartner+cbrdok=idfirma+idkonto+idpartner+brdok
            _rec := dbf_get_rec()
            _rec["otvst"] := "9"
            dbf_update_rec( _rec )
            skip
        enddo
    endif
enddo

select (F_SUBAN)
use
select (F_OSUBAN)
use

// otvaram osuban kao suban alijas
// radi stampe kartice itd...
select ( F_SUBAN )
my_use_temp( "SUBAN", my_home() + "osuban", .f., .f. ) 

select suban
set order to tag "1" 
// IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr

if reccount() = 0
    use
    MsgBeep( "Nema otvorenih stavki" )
    return
endif

Box(, _max_rows, _max_cols )

    ImeKol:={}
    AADD(ImeKol,{ "O.Brdok",    {|| _OBrDok}                  })
    AADD(ImeKol,{ "Br.Veze",     {|| BrDok}                          })
    AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}                         })
    AADD(ImeKol,{ "Dat.Val.",   {|| DatVal}                         })
    AADD(ImeKol,{ PADR("Duguje "+ALLTRIM(ValDomaca()),18), {|| str((iif(D_P=="1",iznosbhd,0)),18,2)}     })
    AADD(ImeKol,{ PADR("Potraz."+ALLTRIM(ValDomaca()),18), {|| str((iif(D_P=="2",iznosbhd,0)),18,2)}     })
    AADD(ImeKol,{ "M1",         {|| m1}                          })
    AADD(ImeKol,{ PADR("Iznos "+ALLTRIM(ValPomocna()),14),  {|| str(iznosdem,14,2)}                       })
    AADD(ImeKol,{ "nalog",    {|| idvn+"-"+brnal+"/"+rbr}                  })
    AADD(ImeKol,{ "O",          {|| OtvSt}                          })
    AADD(ImeKol,{ "Partner",     {|| IdPartner}                          })
    
    Kol:={}
    for i:=1 to len(ImeKol)
        AADD(Kol,i)
    next

    private  bGoreRed:=NIL
    private  bDoleRed:=NIL
    private  bDodajRed:=NIL
    private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
    private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
    private  TBAppend:="N"  // mogu dodavati slogove
    private  bZaglavlje:=NIL
    // zaglavlje se edituje kada je kursor u prvoj koloni
    // prvog reda
    private  TBSkipBlock:={|nSkip| SkipDBBK(nSkip)}
    private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
    private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
    private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                        // ovo se mo§e setovati u when/valid fjama
    private  TBScatter:="N"  // uzmi samo tekue polje
    adImeKol:={}

    for i:=1 TO LEN(ImeKol)
        AADD(adImeKol,ImeKol[i])
    next

    adKol:={}

    for i:=1 to len(adImeKol)
        AADD(adKol,i)
    next

    private bBKUslov:= {|| idFirma+idkonto+idpartner=cidFirma+cidkonto+cidpartner}
    private bBkTrazi:= {|| cIdFirma+cIdkonto+cIdPartner}
    // Brows ekey uslova
    private aPPos:={cIdPartner,1}  // pozicija kolone partner, broj veze

    set cursor on

    @ m_x + ( _max_rows - 5 ), m_y + 1 SAY "****************  REZULTATI ASISTENTA ************"
    @ m_x + ( _max_rows - 4 ), m_y + 1 SAY REPL("=", MAXCOLS() - 2 )
    @ m_x + ( _max_rows - 3 ), m_y + 1 SAY " <F2> Ispravka broja dok.       <c-P> Print      <a-P> Print Br.Dok           "
    @ m_x + ( _max_rows - 2 ), m_y + 1 SAY " <K> Ukljuci/iskljuci racun za kamate "
    @ m_x + ( _max_rows - 1 ), m_y + 1 SAY ' < F6 > Stampanje izvrsenih promjena  '

    private cPomBrDok := SPACE(10)

    seek EVAL(bBkTrazi)

    ObjDbEdit( "Ost", _max_rows, _max_cols, {|| EdRos( .t. ) } , "", "", .f. ,NIL, 1, {|| brdok<>_obrdok}, 6, 0, ;  // zadnji par: nGPrazno
            NIL, {|nSkip| SkipDBBK(nSkip)} )

BoxC()

go top

fPromjene:=.f.
do while !eof() 
    if _obrdok <> brdok
        fPromjene:=.t.
        exit
    endif
    skip
enddo

if fpromjene
    go top
    if pitanje(,"Ostampati rezultate asistenta ?","N")="D"
        StAz()
    endif
else
    select suban
    use
    return  
    // izadji - nije bilo promjena
endif

select (F_OSUBAN)
use
select (F_SUBAN)
use

MsgBeep("U slucaju da azurirate rezultate asistenta#program ce izmijeniti sadrzaj subanalitickih podataka !")

if pitanje(, "Zelite li izvrsiti azuriranje rezultata asistenta u bazu SUBAN !!","N" ) == "D"   

    // ekskluzivno otvori
    select ( F_OSUBAN )
    my_use_temp( "OSUBAN", my_home() + "osuban", .f., .t. )

    O_SUBAN

    select osuban
    go top
            
    // prvi krug - provjeriti da neko nije slucajno dirao stavke ??!!-drugi korisnik
    do while !EOF()
            
        if osuban->_recno == 0
            // ovo su nove stavke, njih preskoci
            skip
            loop
        endif

        select suban
        go osuban->_recno
                
        if EOF() .or. idfirma<>osuban->idfirma .or. idvn<>osuban->idvn .or. brnal<>osuban->brnal .or. idkonto<>osuban->idkonto .or. idpartner<>osuban->idpartner .or. d_p<>osuban->d_p
                MsgBeep("Izgleda da je drugi korisnik radio na ovom partneru#Prekidam operaciju !!!")
            close all
        endif
                
        select osuban
        skip

    enddo
 
    // odradi lokovanje
    if !f18_lock_tables({ "suban" })
        Alert( "Prekidam opreraciju, nisam napravio lock !!!")
        return 
    endif

    sql_table_update( nil, "BEGIN" )
           
    // drugi krug - sve je cisto brisi iz suban!
    select osuban
    go top
            
    do while !EOF()
            
        if osuban->_recno == 0
            // ovo je nova stavka, nju preskoci !
            skip
            loop
        endif

        select suban
        go osuban->_recno
            
        if !EOF()
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
        endif
            
        select osuban
        skip

    enddo
            
    f18_free_tables({"suban"})
    sql_table_update( nil, "END" )

    // treci krug - dodaj iz osuban
    
    if !f18_lock_tables({ "suban" })
        Alert( "Prekidam opreraciju, nisam napravio lock !!!")
        return 
    endif

    sql_table_update( nil, "BEGIN" )
    
    select osuban
    go top

    do while !eof()
                
        _rec := dbf_get_rec()
            
        // ukloni viska polja za suban
        hb_hdel( _rec, "_recno" )
        hb_hdel( _rec, "_ppk1" )
        hb_hdel( _rec, "_obrdok" )

        select suban
        append blank
            
        update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
            
        select osuban
        skip

    enddo
            
    f18_free_tables({"suban"})
    sql_table_update( nil, "END" )

    MsgBeep("Promjene su izvrsene - provjerite na kartici")

endif

close all
return



/*! \fn StAz()
 *  \brief Stampa promjena
 */
 
function StAz()

aKol:={}
AADD(aKol,{ "Originalni",    {|| _obrdok}, .f., "C", 10,  0, 1, 1    })
AADD(aKol,{ "Br.Veze  " ,    {|| "#"}, .f., "C", 10,  0, 2, 1    })
AADD(aKol,{ "Br.Veze",       {|| BrDok}, .f.,"C", 10,0,1, 2  })

AADD(aKol,{ "Dat.Dok",       {|| DatDok}, .f.,"D", 8,0,1, 3  })
AADD(aKol,{ "Duguje",    {|| str((iif(D_P=="1",iznosbhd,0)),18,2)}, .f.,"C", 18,0,1, 4  })
AADD(aKol,{ "Potrazuje",    {|| str((iif(D_P=="2",iznosbhd,0)),18,2)}, .f.,"C", 18,0,1, 5  })
AADD(aKol,{ "Nalog",    {|| idvn+"-"+brnal+"/"+rbr}, .f.,"C", 20,0,1, 6  })
AADD(aKol,{ "Partner",     {|| IdPartner} , .f.,"C", 10,0,1, 7  })

go top
fPromjene:=.f.
do while !eof()
  if _obrdok<>brdok
     fPromjene:=.t.
     exit
  endif
  skip
enddo

go top
START PRINT CRET

StampaTabele(aKol,,,0,,;
    ,"Rezultati asistenta otvorenih stavki za: "+idkonto+"/"+idpartner+" na datum:"+dtoc(Date()))

END PRINT
return .t.




/*! \fn SkipDBBK(nRequest)
 *  \brief 
 *  \param nRequest
 */
 
static function SkipDBBK(nRequest)
local nCount

nCount := 0

if LastRec() != 0

   if .not. EVAL(bBKUslov)
      seek EVAL(bBkTrazi)
      if .not. EVAL(bBKUslov)
         go bottom
         skip 1
      endif
      nRequest = 0
   endif

   if nRequest>0
      do while nCount<nRequest .and. EVAL(bBKUslov)
         skip 1
         if EOF() .or. !EVAL(bBKUslov)
            skip -1
            exit
         endif
         nCount++
      enddo

   elseif nRequest<0
      do while nCount>nRequest .and. eval(bBKUslov)
         skip -1
         if ( BOF() )
            exit
         endif
         nCount--
      enddo
      if !EVAL(bBKUslov)
         skip 1
         nCount++
      endif

   endif

endif

return (nCount)



