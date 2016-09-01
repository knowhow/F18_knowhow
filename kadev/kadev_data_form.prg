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



function kadev_form()
local _izbor := 1
local _opc := {}
local _opcexe := {}

// otvori tabele
kadev_o_tables()
// setuj sve relacije tabela
kadev_set_relations()

select kadev_0

public aRez
public aGrupa
public aKatUsl
public aKatVal
public aZagl

// izbor obrasca
izbor_obrasca()

AADD( _opc, "1. ispravka definicije                      " )
AADD( _opcexe, {|| ispravka_obrasca() } )
AADD( _opc, "2. generisanje kalkulacije" )
AADD( _opcexe, {|| generisanje_obrasca() } )
AADD( _opc, "3. izbor obrasca" )
AADD( _opcexe, {|| izbor_obrasca() } )
AADD( _opc, "4. brisanje obrasca" )
AADD( _opcexe, {|| brisi_obrazac() } )

f18_menu( "obr", .f., _izbor, _opc, _opcexe )

@ 1,39 SAY SPACE(40) COLOR "N/N"

my_close_all_dbf()

return


// -----------------------------------------------------------
// brisanje obrasca
// -----------------------------------------------------------
static function brisi_obrazac()
local lInsert := READINSERT(.t.)
private cImeFOB := PADR( "kdv_obr_100.dbf        ", 30 ) 
  
if VarEdit( { { "Puni naziv obrasca koji zelite izbrisati" ,;
                 "cImeFOB",;
                 "PostojiFajl(cImeFOB)",;
                 "@!", } },;
              11, 1, 15, 78, "BRISANJE OBRASCA", "B1" )
    if FERASE( my_home() + LOWER( ALLTRIM( cImeFOB ) ) ) != 0
        Msg("Brisanje nije uspjelo. Navedeni obrazac se vjerovatno koristi kao tekuci!",3)
    endif
endif
  
READINSERT( lInsert )

return NIL



function PostojiFajl( file )
local lVrati := FILE( my_home() + ALLTRIM( file ) )
if !lVrati
    Msg("Navedeni fajl ne postoji!",3)
endif
return lVrati


// ----------------------------------------------------------
// izbor obrasca
// ----------------------------------------------------------
static function izbor_obrasca()
local nRed
private opc
private h

opc := {}
aFiles := DIRECTORY( my_home() + "kdv_obr_*.dbf" )
h := ARRAY( LEN( aFiles ) + 1 )
i := 0
AEVAL( aFiles, {|elem| h[++i]:="",AADD(opc,PADR(elem[1],15))})
AADD(opc,PADR("Novi obrazac",15))
h[i+1] := "Kreiranje novog obrasca"

Izb3:=1

do while .t.

    Izb3 := meni_0( "izobr", opc, izb3, .f. )

    do case

        case Izb3 == 0
            exit
            return

        case Izb3 < LEN(opc)

            select ( F_KDV_OBRAZDEF )
            use

            my_use_temp( "KDV_OBRAZDEF", my_home() + opc[ izb3 ], .f., .t. )
            index on tip + grupa + red_br tag "1"
            set order to tag "1"

            @ 1, 39 SAY PADR( "Tekuci obrazac: " + opc[ izb3 ], 40 ) COLOR "GR+/N"

        otherwise

            set cursor on
            
            Box("nobr", 1, 46, .f. )
                cIdObr := SPACE(3)
                @ m_x + 1, m_y + 2 SAY "Unesi tri slova za identifikaciju obrasca:" GET cIdObr VALID !EMPTY( cIdObr )
                read
            BoxC()
            set cursor off

            if FILE( my_home() + "kdv_obr_" + cIdObr + ".dbf")
                Msg( "Fajl vec postoji !!!",10)
            else
                aDbf := {}
                AADD(aDbf,{"Tip","C",1,0})
                AADD(aDbf,{"Grupa","C",1,0})
                AADD(aDbf,{"Red_Br","C",1,0})
                AADD(aDbf,{"Komentar","C",25,0})
                AADD(aDbf,{"Uslov","C",200,0})
                AADD(aDbf,{"id_uslova","C",8,0})
                AADD(aDbf,{"brisano","C",1,0})
                DBCREATE( my_home() + "kdv_obr_" + cIdObr, aDbf )
            endif
    endcase

enddo

return



function generisanje_obrasca()
aUslovi := {}

select kdv_globusl

DBEVAL( {|| AADD( aUslovi, { Komentar, ' ', trim(Uslov), trim(ime_baze) } ) })

if LEN( aUslovi ) == 0
    MsgO("Prekidam generisanje izvjestaja. Nije kreiran nijedan globalni uslov!")
    Inkey(0)
    MsgC()
    return
endif

Box( "musl", 10, 60, .f. )
    @ m_x, m_y + 2 SAY "<SPACE> markiranje"
    MABROWSE( aUslovi, m_x + 1, m_y + 1, m_x + 10, m_y + 60 )
BoxC()

if ASCAN( aUslovi, { |aElem| aElem[2] = '*' }) == 0
    MsgBeep( "Nije markiran niti jedan uslov sa <SPACE> !" )
    return
endif

IF ASCAN(aUslovi,{|x| ALLTRIM(x[4])!="KADEV_0".and.x[2]=='*'})!=0
    SELECT KADEV_0
    SET RELATION TO
    SELECT KDV_RJRMJ
    SET RELATION TO
ENDIF

lTDatumOd := .f.
lTDatumDo := .f.
d0 := CTOD("")
d1 := CTOD("")

nRed := 0
nArr := SELECT()

SELECT KDV_OBRAZDEF
GO TOP

DO WHILE !EOF()
    cStr := komentar + uslov
    IF "&D0" $ cStr
        ++ nRed
        lTDatumOd:=.t.
    ENDIF
    IF "&D1" $ cStr
        ++ nRed
        lTDatumDo:=.t.
    ENDIF
    SKIP 1
ENDDO

SELECT (nArr)

IF nRed>0
    Box("#DODATNI USLOVI ZA GENERACIJU IZVJESTAJA",2+nRed,77)
        nRed:=0
        IF lTDatumOd
            @ m_x+1+(++nRed), m_y+2 SAY "Od datuma" GET D0
        ENDIF
        IF lTDatumDo
            @ m_x+1+(++nRed), m_y+2 SAY "Do datuma" GET D1
        ENDIF
        READ
        IF LASTKEY()==K_ESC
            BoxC()
            RETURN
        ENDIF
    BoxC()
ENDIF

START PRINT CRET        

FOR gi:=1 to Len(aUslovi) 
    
    // odradi kalkulaciju za sve globalne uslove

    InitGlobMatr()   
    // inicijalizuje matricu prora~una

    IF gi==1
        IF gPrinter=="L"
            gPO_Land()
            GuSt2(25+LEN(aKatVal)*10,"L4")
        ELSE
            GuSt2(25+LEN(aKatVal)*10,"4")
        ENDIF
    ENDIF

    // otvaranje tabele !!!!
    select ( aUslovi[gi][4] )
    go top

    if aUslovi[gi][2]=='*'
        cPomDev:=SET(_SET_DEVICE)         //  izlaz na
        SET DEVICE TO SCREEN              //  ekran
        GlobalUsl:=  {|| &(aUslovi[gi][3])}
        nCount:=0
        Box("count",1,30,.f.)
            @ m_x,m_y+2 SAY aUslovi[gi][1]

            do while !eof()
                select (aUslovi[gi][4])
                if EVAL(GlobalUsl)
                    for i:=1 to LEN(aRez)
                        for j:=1 to len(aRez[i])   // aRez[i] tipa je aGrupa
                            // aRez[i][j] je tipa {bUslov,{0,0...,0}}
                            IF (lUslR:=EVAL(aRez[i][j][2]))
                                for x:=1 to LEN(aKatVal)  // ovo je broj kategorija
                                    lUslK:=EVAL(aKatUsl[x][2])
                                    if lUslK
                                        IF ALLTRIM(aUslovi[gi][4])=="RJRMJ"
                                            (aRez[i][j][3][x])+=brizvrs
                                        ELSE
                                            (aRez[i][j][3][x])++
                                        ENDIF
                                    endif
                                    // aRez[i][j][2] - tipa aKatVal
                                next
                            ENDIF
                        next
                    next
                    ++nCount
                    @ m_x+1,m_y+10 SAY nCount
                endif  // if eval(globusl)
                skip
            enddo

        BoxC()

        for i:=1 to LEN(aRez)
            AFILL(aKatVal,0)
            for j:=1 to len(aRez[i])   // aRez[i] tipa je aGrupa
                // aRez[i][j] je tipa {bUslov,{0,0...,0}}
                for x:=1 to LEN(aKatVal)  // ovo je broj kategorija
                    aKatVal[x]+=aRez[i][j][3][x]
                next
            next
            aKatvv:=ACLONE(aKatVal)
            AADD(aRez[i],{PADR("UKUPNO:",25),NIL,aKatvv})
        next

        // set console off     // bilo
        // set alternate on    // bilo

        SET(_SET_DEVICE,cPomDev)  // nije vise izlaz na ekran

        ?
        ? PADC(' '+alltrim(aUslovi[gi][1])+' ',70,"*")
        ?

        ? SPACE(25)
        for i:=1 to LEN(aKatVal)
            ?? padl(alltrim(aKatUsl[i][1]),10)
        next
        ? SPACE(25)+REPLICATE("=",len(aKatVal)*10)
        for i:=1 to LEN(aRez)
            ?
            ? aZagl[i]
            ? replicate("-",25+10*len(aKatVaL))
            for j:=1 to len(aRez[i])   // aRez[i] tipa je aGrupa
                // aRez[i][j] je tipa {bUslov,{0,0...,0}}
                ? aRez[i][j][1]
                for x:=1 to LEN(aKatVal)  // ovo je broj kategorija
                    ?? (aRez[i][j][3])[x]
                next
            next
            ? replicate("-",25+10*len(aKatVaL))
        next

        // set alternate off  // bilo
        // set console on     // bilo

    endif // if .... '*'

next   // kraj petlje " gi=1 to LEN(aUslovi) "

IF gPrinter=="L"
    gPO_Port()
ENDIF

FF
ENDPRINT             

kadev_o_tables()
kadev_set_relations()
select kadev_0

return



function InitGlobMatr()
select kdv_obrazdef
aRez:={}
aGrupa:={}
aKatUsl:={}
aKatVal:={}
aZagl:={}

seek "K"
do while Tip=="K"
  // cUsl:=TRIM(Uslov)
  cUsl:=Uslov
  cUsl:=STRTRAN(cUsl,"&D0",DTOC(D0))
  cUsl:=STRTRAN(cUsl,"&D1",DTOC(D1))
  cUsl:=TRIM(cUsl)
  cPom:=komentar
  cPom:=STRTRAN(cPom,"&D0",DTOC(D0))
  cPom:=STRTRAN(cPom,"&D1",DTOC(D1))
  AADD(aKatUsl,{cPom,{|| &cUsl}})
  AADD(aKatVal,0)
  skip
enddo


seek "Z"
do while Tip=="Z"
  cUsl:=Uslov
  cUsl:=STRTRAN(cUsl,"&D0",DTOC(D0))
  cUsl:=STRTRAN(cUsl,"&D1",DTOC(D1))
  cUsl:=LEFT(cUsl,70)
  AADD(aZagl,cUsl)
  skip
enddo


seek "R"
do while Tip="R"
 cGrupa:=Grupa
 aGrupa:={}
 do while grupa==cGrupa .and. Tip=="R"
   aKatvv:={}
   aKatvv:=ACLONE(aKatVal)

   // cUsl:=TRIM(Uslov)
   cUsl:=Uslov
   cUsl:=STRTRAN(cUsl,"&D0",DTOC(D0))
   cUsl:=STRTRAN(cUsl,"&D1",DTOC(D1))
   cUsl:=TRIM(cUsl)

   cPom:=komentar
   cPom:=STRTRAN(cPom,"&D0",DTOC(D0))
   cPom:=STRTRAN(cPom,"&D1",DTOC(D1))
   AADD(aGrupa,{cPom,{|| &cUsl},aKatvv})
   skip
 enddo
 AADD(aRez,aGrupa)
enddo

return




static function ispravka_obrasca()

Izb11:=1

PRIVATE opc[2]

opc[1]:="Globalni uslovi    "
opc[2]:="Definicija obrasca"
h[1]:="Globalni uslovi odredjuju jedinicu,duznosti,prisutnost"
h[2]:="Definicija redova i zaglavlja (po grupama), kolona obrasca"

do while .t.
    
    Izb11:=meni_0("edmeni",opc,Izb11,.F.)

    DO CASE

        CASE Izb11 == 0
            EXIT

        CASE Izb11 == 1

            select kdv_globusl
            go top
            ImeKol:={ {'Komentar',{|| komentar}}    ,;
                 {'Uslov'   ,{|| LEFT(Uslov,60)+".."}}, ;
                 {'DBF-baza',{|| ime_baze}}   ;
               }
            Kol:={1,2,3}
            my_db_edit('usl',10,77,{|| EdGlobUsl()},"<Ctrl-N> Dodaj, <Ctrl-T> Brisi, <F2> Edit, <F4> Dupliciraj ","",.f.)

        CASE Izb11==2
            select kdv_obrazdef
            go top
            ImeKol:={{'Tip',{|| tip}},;
               {'Grupa',{|| grupa}}, ;
               {'R.Br.'   ,{|| red_br}}, ;
               {'Komentar'   ,{|| Komentar}}, ;
               {'Uslov'   ,{|| LEFT(Uslov,70)+".."}} ;
                }
            Kol:={1,2,3,4,5}
            my_db_edit('usl',10,77,{|| EdObrazDef()},"<Ctrl-N> Dodaj, <Ctrl-T> Brisi, <F2> Edit, <F4> Dupliciraj","",.f.)

    ENDCASE
enddo

return




function EdGlobUsl()
local Ch,c1,c2

Ch := LastKey()

do case
  
    case Ch==K_CTRL_N .or. Ch==K_F4 .or. Ch==K_F2


        if Ch==K_CTRL_N
            APPEND BLANK
        endif

        set_global_vars_from_dbf()
        Box('EdIstIsp',3,70,.f.)
        set cursor on
        @ m_x+1,m_y+2 SAY "Komentar:" GET _Komentar PICTURE "@!"
        @ m_x+2,m_y+2 SAY "Uslov:" GET _Uslov PICTURE "@S60"
        @ m_x+3,m_y+2 SAY "Ime baze:" GET _ime_baze PICTURE "@!"
        READ
        set cursor off
        BoxC()
        if Ch==K_F4
            append blank
        endif
        _rec := get_dbf_global_memvars()
        update_rec_server_and_dbf( "kadev_globusl", _rec, 1, "FULL" )

        return DE_REFRESH

    case Ch==K_CTRL_T

        if Pitanje("p94","Izbrisati kriterij: "+trim(komentar)+" ?","N")="D"
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "kadev_globusl", _rec, 1, "FULL" )
            return DE_REFRESH
        else
            return DE_CONT
        endif

    case Ch==K_ENTER
        RETURN DE_ABORT
    case Ch==K_ESC
        RETURN DE_ABORT
    otherwise
        return DE_CONT
endcase

return




function EdObrazDef()
local Ch

Ch := LastKey()

do case
  
    case Ch==K_CTRL_N .or. Ch==K_F4 .OR. Ch==K_F2

        if Ch==K_CTRL_N
            APPEND BLANK
        endif

        set_global_vars_from_dbf()
        
        Box('EdIstIsp',6,77,.f.)
            set cursor on
            @ m_x+1,m_y+2 SAY "Tip:" GET _Tip PICTURE "@!"  VALID _Tip $ "KRZ"
            @ m_x+1,m_y+12 SAY "Grupa:" GET _Grupa  PICTURE "@!"
            @ m_x+1,m_y+22 SAY "R.br.:" GEt _red_Br PICTURE "@!"
            @ m_x+3,m_y+2 SAY "Komentar:" GET _Komentar
            @ m_x+5,m_y+2 SAY "Uslov:" GET _Uslov VALID validuslov(_Uslov) PICTURE "@S60"
            READ
        BoxC()
     
        if Ch == K_F4
            append blank
        endif

        _rec := get_dbf_global_memvars()

        if !hb_hhaskey( _rec, "id_uslova" )
            _rec["id_uslova"] := ""
        endif

        dbf_update_rec( _rec )
        // ne ide na server za sada...
        //update_rec_server_and_dbf( "kadev_obrazdef", _rec, 1, "FULL" )
        
        return DE_REFRESH

    case Ch == K_CTRL_T

        if Pitanje("p95","Izbrisati stavku: "+tip+"-"+grupa+"-"+red_Br+"-"+trim(komentar)+" ?","N") == "D"
            
            //_rec := dbf_get_rec()
            delete
            // ne ide na server
            // delete_rec_server_and_dbf( "kadev_obrazdef", _rec, 1, "FULL" )
            skip
            if eof()
                skip -1
            endif

            my_dbf_pack()

            return DE_REFRESH
        else
            return DE_CONT
        endif

    case Ch==K_ENTER
        RETURN DE_ABORT
    case Ch==K_ESC
        RETURN DE_ABORT
    otherwise
        return DE_CONT
endcase

return


function validuslov(cUslov)
 D0:=D1:=CTOD("")

 if !(Tip $ "KR")
   return .t.
 endif

 bErrorHandler:={|objError| GlobalErrorHandler(objError,.t.)}
 bLastHandler:=ErrorBlock(bErrorHandler)

 BEGIN SEQUENCE

 nOldArr:=SELECT()
 select kadev_0
 xRez:=&cUslov .and. .t.
 select(nOldArr)

 RECOVER USING ObjErrInfo

  BEEP(5)
  if ObjErrInfo:genCode = EG_SYNTAX
     MsgO(ObjErrInfo:description+':Neispravna sintaksa !!!!')
  elseif ObjErrInfo:genCode = EG_NOFUNC
     MsgO(ObjErrInfo:description+':Nepoznata funkcija !!!!')
  elseif ObjErrInfo:genCode = EG_ARG
     MsgO(ObjErrInfo:description+':Neispravan argument funkcije !!!!')
  elseif ObjErrInfo:genCode = EG_BOUND
     MsgO(ObjErrInfo:description+':Nepostojeci index u matrici !!!!')
  elseif ObjErrInfo:genCode = EG_NOVAR
     MsgO(ObjErrInfo:description+':Nepostojeca varijabla !!!!')
  elseif ObjErrInfo:genCode = EG_NOALIAS
     MsgO(ObjErrInfo:description+':Neispravna oznaka baze (ALIAS) !!!!')
  else
     MsgO(ObjErrInfo:description+':Greska !!!!')
  endif
  Inkey(0)
  MsgC()
  SELECT(nOldArr)

  ErrorBlock(bLastHandler)
  return .f.
 END SEQUENCE

ErrorBlock(bLastHandler)
return .t.




