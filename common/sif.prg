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

#include "dbstruct.ch"

// static integer
static __PSIF_NIVO__:=0

static _LOG_PROMJENE := .f.

static __A_SIFV__:= { {NIL,NIL,NIL}, {NIL,NIL,NIL}, {NIL,NIL,NIL}, {NIL,NIL,NIL}}

function p_sifra_2( nDbf, nNtx, nVisina, nSirina, cNaslov, cID, dx, dy,  bBlok, aPoredak, bPodvuci, aZabrane, invert, aZabIsp )

local cRet, cIdBK
local _i
local _komande := {"<c-N> Novi", "<F2>  Ispravka", "<ENT> Odabir", _to_str("<c-T> Briši"), "<c-P> Print", ;
                   "<F4>  Dupliciraj", _to_str("<c-F9> Briši SVE"), _to_str("<c-F> Traži"), "<a-S> Popuni kol.",;
                   "<a-R> Zamjena vrij.", "<c-A> Cirk.ispravka"}
local cUslovSrch :=  ""
local cNazSrch

// trazenje je po nazivu
private fPoNaz:=.f.  
private fID_J := .f.

if aZabIsp == nil
    aZabIsp := {}
endif

FOR _i:=1 TO LEN(aZabIsp)
    aZabIsp[_i] := UPPER(aZabIsp[_i])
NEXT

// provjeri da li treba logirati promjene
if Logirati("FMK", "SIF", "PROMJENE")
    _LOG_PROMJENE := .t.    
endif

private nOrdId

PushWa()
PushSifV()

if invert == NIL
    invert := .t.
endif

select (nDbf)
if !used()
    MsgBeep("USED FALSE ?!")
    return .f.
endif

// setuj match_code polje...
set_mc_imekol(nDbf)

nOrderSif := indexord() 
nOrdId := index_tag_num("ID")

sif_set_order( nNTX, nOrdId, @fID_j )

sif_seek( @cId, @cIdBK, @cUslovSrch, @cNazSrch, fId_j, nOrdId )  

if dx <> NIL .and. dx < 0
    // u slucaju negativne vrijednosti vraca se vrijednost polja
    // koje je na poziciji ABS(i)
    if !FOUND()
        go bottom
        skip  // id na eof, tamo su prazne vrijednosti
        cRet := &(FIELDNAME(-dx))
        skip -1
    else
        cRet := &(FIELDNAME(-dx))
    endif

    PopSifV()
    PopWa()

    return cRet

endif

if !EMPTY( cUslovSrch )
    // postavi filter u sifrarniku
    SetSifFilt( cUslovSrch )  
endif

if ( fPonaz .and. ( cNazSrch == "" .or. !TRIM( cNazSrch ) == TRIM( naz ) ) ) ;
    .or. cId == NIL ;
    .or. ( !FOUND() .and. cNaslov <> NIL ) ;
    .or. ( cNaslov <> NIL .and. LEFT( cNaslov, 1 ) = "#" )   
  
    lPrviPoziv := .t.

    if EOF() 
        skip -1
    endif

    if cId == NIL 
        // idemo bez parametara
        go top
    endif

    browse_tbl_2(, nVisina, nSirina,  {|| EdSif( nDbf, cNaslov, bBlok, aZabrane, aZabIsp )}, cNaslov, "", invert, _komande, 1, bPodvuci, , , aPoredak )

    IF TYPE("id") $ "U#UE"       
        cID:=(nDbf)->(FIELDGET(1))
    ELSE

        if !(nDBf)->(USED())
            Alert("not used ?!")
        endif

        cID:=(nDbf)->id
        if fID_J
        __A_SIFV__[__PSIF_NIVO__,1]:=(nDBF)->ID_J
        endif
   ENDIF

else

    // nisam ni ulazio u objdb
    if fID_J
        cId:=(nDBF)->id
        __A_SIFV__[__PSIF_NIVO__,1] := (nDBF)->ID_J
    endif

endif

__A_SIFV__[__PSIF_NIVO__,2]:= recno()

// ispisi naziv

sif_ispisi_naziv(nDbf, dx, dy) 

select (nDbf)

//vrati order sifranika !!
ordsetfocus(nOrderSif)    

set filter to
PopSifV()
PopWa()
return .t.

// ------------------------------------------------
// ------------------------------------------------
static function sif_set_order(nNTX, nOrdId, fID_j)
local nPos

// POSTAVLJANJE ORDERA...
DO CASE
 CASE valtype(nNTX) == "N"
  
  if nNTX == 1   
        if nOrdid<>0
            set order to tag "ID"
        else
            set order to tag "1"
        endif
  else
        
        if nOrdid == 0
            set order to tag "2"
        endif
  endif
  
CASE valtype(nNTX) == "C" .and. right(upper(trim(nNTX)), 2) == "_J"

  // postavi order na ID_J
  set order to tag (nNTX)
  fID_J:=.t.

OTHERWISE

  // IDX varijanta:  TAG_IMEIDXA
  nPos := AT("_", nNTX)
  if nPos<>0
        if empty(left(nNtx, nPos-1))
            dbsetindex(substr(nNTX,nPos+1))
        else
            set order to tag (LEFT(nNtx, nPos-1)) IN (substr(nNTX,nPos+1))
        endif
  else
        set order to tag (nNtx)
  endif

END CASE

return .t.

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
static function sif_seek( cId, cIdBK, cUslovSrch, cNazSrch, fId_j, nOrdId )
local _bk := ""
local _order := indexord() 
local _tezina := 0

if cId == NIL
    return
endif 
        
if VALTYPE(cId) == "N"       
    seek STR(cId)
    return
endif
    
if RIGHT( TRIM( cId ), 1) == "*"
    sif_katbr_zvjezdica( @cId, @cIdBK, fId_j )
    return
endif    

if RIGHT( TRIM(cId), 1) $ "./$"
    sif_point_or_slash( @cId, @fPoNaz, @nOrdId, @cUslovSrch, @cNazSrch )
    return
endif

// glavni seek
// id, barkod

seek cId

if FOUND()
    // po id-u
    cId := &(FIELDNAME(1))
    return
endif
            
// po barkod-u
if LEN( cId ) > 10

    if !tezinski_barkod( @cId, @_tezina, .f. )
        barkod( @cId )
    endif

    ordsetfocus( _order )

    return

endif

return



// ----------------------------------------------------
// ----------------------------------------------------
static function sif_katbr_zvjezdica(cId, cIdBK, fId_j)

cId := PADR( cId, 10 )

if  fieldpos("KATBR")<>0 
    set order to tag "KATBR"
    seek LEFT( cId, len(trim(cId)) - 1 )
    cId := id
else
    seek CHR(250)+CHR(250)+CHR(250)
endif

if !FOUND()

    // trazi iz sifranika karakteristika
    cIdBK := LEFT(cId,len(trim(cId))-1)
    cId   := ""

    ImauSifV("ROBA","KATB", cIdBK, @cId)

    if !empty(cId)

        select roba
        set order to tag "ID"
        // nasao sam sifru !!
        seek cId  
        cId := Id
        if fid_j
            cId := ID_J
            set order to tag "ID_J"
            seek cId
        endif

    endif
endif

return .t.



static function sif_point_or_slash(cId, fPoNaz, nOrdId, cUslovSrch, cNazSrch)
local _filter

cId := PADR( cId, 10 )

if nOrdid <> 0
    set order to tag "NAZ"
else
    set order to tag "2"
endif

fPoNaz:=.t.

cNazSrch :=""
cUslovSrch :=""

if left(trim(cId), 1) == "/"

    private GetList:={}

    Box(, 1, 60)

        cUslovSrch:=space(120)
        Beep(1)
          @ m_x+1, m_y+2 SAY "Želim pronaći:" GET cUslovSrch PICT "@!S40"
        read

        cUslovSrch := TRIM( cUslovSrch )

        if RIGHT( cUslovSrch, 1 ) == "*"
            cUslovSrch := LEFT( cUslovSrch , len(cUslovSrch) - 1 )
        endif

    BoxC()

elseif left(TRIM(cId), 1) == "."

    // SEEK PO NAZ kada se unese DUGACKI DIO
    private GetList:={}

    Box(, 1, 60)

        cNazSrch := SPACE(LEN(naz))
        Beep(1)

        @ m_x + 1, m_y + 2 SAY "Unesi naziv:" GET cNazSrch PICT "@!S40"
        read

    BoxC()

    seek trim( cNazSrch )
    
    cId := field->id

elseif RIGHT(TRIM(cId), 1) == "$"
    
    // pretraga dijela sifre...
    _filter := _filter_quote( LEFT( UPPER(cId), LEN( TRIM( cId )) - 1 )) + " $ UPPER(naz)"
    set filter to
    set filter to &(_filter)
    go top

else

    seek LEFT( cId, LEN(TRIM( cId )) - 1 )

endif

return .t.

// ------------------------------------------------------------
// -----------------------------------------------------------
static function EdSif(nDbf, cNaslov, bBlok, aZabrane, aZabIsp)
local i
local j
local imin
local imax
local nGet
local nRet 
local nOrder
local nLen
local nRed
local nKolona
local nTekRed
local nTrebaRedova
local cUslovSrch
local lNovi
local oDb_lock := F18_DB_LOCK():New
local _db_locked := oDb_lock:is_locked()

private cPom
private aQQ
private aUsl
private aStruct

// matrica zabrana
if aZabrane=nil
  aZabrane:={}
endif
 
// matrica zabrana ispravki polja
if aZabIsp=nil
 aZabIsp:={}
endif

Ch := LASTKEY()

// deklarisi privatne varijable sifrarnika
// wPrivate
aStruct:=DBSTRUCT()
SkratiAZaD (@aStruct)
for i:=1 to LEN(aStruct)
     cImeP := aStruct[i,1]
     cVar := "w" + cImeP
     PRIVATE &cVar := &cImeP
next

nOrder := indexord()
nRet := -1
lZabIsp := .f.

if bBlok <> NIL
    nRet:=Eval(bBlok, Ch)
    if nret > 4
        if nRet == 5
            return DE_ABORT
        elseif nRet == 6
            return DE_CONT
        elseif nRet == 7
            return DE_REFRESH
        elseif nRet == 99 .and. LEN(aZabIsp) > 0
            lZabIsp := .t.
            nRet := -1
        endif
    endif
endif

if ASCAN( aZabrane, Ch ) <> 0  
    MsgBeep( "Nivo rada:" + klevel + " : Opcija nedostupna !" )
    return DE_CONT
endif

#ifndef TEST

// provjeri pristup opcijama koje mjenjaju podatke
if ( Ch == K_CTRL_N .or. Ch == K_CTRL_A .or. Ch == K_F2 .or. ;
        Ch == K_CTRL_T .or. Ch == K_F4 .or. Ch == K_CTRL_F9 .or. Ch == K_F10 ) .and. ;
    ( !ImaPravoPristupa(goModul:oDatabase:cName,"SIF","EDSIF") .or. _db_locked )
    
    oDb_lock:warrning()
    return DE_CONT

endif

#endif

do case

  case Ch == K_ENTER
    // ako sam u sifrarniku a ne u unosu dokumenta 
    if gMeniSif 
        return DE_CONT
    else
        // u unosu sam dokumenta
        lPrviPoziv:=.f.
        return DE_ABORT
    endif

  case UPPER(CHR(Ch)) == "F"

    // pretraga po MATCH_CODE
    if m_code_src() == 0
        return DE_CONT
    else
        return DE_REFRESH
    endif

  case Ch == ASC("/")

    cUslovSrch := ""

    Box( , 1, 60)
       cUslovSrch := space(120)
       @ m_x+1, m_y+2 SAY "Zelim pronaci:" GET cUslovSrch pict "@!S40"
       read
       cUslovSrch:=trim(cUslovSrch)
       if right(cUslovSrch,1) == "*"
          cUslovSrch := left( cUslovSrch , len(cUslovSrch)-1 )
       endif
    BoxC()

    if !empty(cUslovSrch)
       // postavi filter u sifrarniku
       SetSifFilt(cUslovSrch)  
    else
       set filter to
    endif
    return DE_REFRESH


  case (Ch==K_CTRL_N .or. Ch==K_F2 .or. Ch==K_F4 .or. Ch==K_CTRL_A)
   
    Tb:RefreshCurrent()

    if edit_item(Ch, nOrder, aZabIsp) == 1
        return DE_REFRESH
    endif

    RETURN DE_CONT
    
  case Ch==K_CTRL_P

    PushWa()
    IzborP2(Kol, PRIVPATH + ALIAS())
    if lastkey() == K_ESC
        return DE_CONT
    endif

    Izlaz("Pregled: " + ALLTRIM(cNaslov) + " na dan " + dtoc(date()) + " g.", "sifrarnik" )
    PopWa()

    return DE_CONT

  case Ch==K_ALT_F
     uslovsif()
     return DE_REFRESH

  case Ch==K_CTRL_F6

    Box( , 1, 30)
      public gIdFilter := eval(ImeKol[TB:ColPos,2])
      @ m_x+1, m_y+2 SAY "Filter :" GET gidfilter
      read
    BoxC()

    if empty(gidfilter)
      set filter to
    else
      set filter to eval(ImeKol[TB:ColPos,2])==gidfilter
      go top
    endif
    return DE_REFRESH

  case Ch==K_CTRL_T
     return sif_brisi_stavku()

  case Ch==K_CTRL_F9
     return sif_brisi_sve()

  case Ch==K_ALT_C
    return SifClipBoard()

  case Ch==K_F10
      popup(nOrder)
      RETURN DE_CONT

  otherwise
     if nRet>-1
        return nRet
     else
        return DE_CONT
     endif

endcase
return

// ------------------------------------------
// ------------------------------------------
static function edit_item(Ch, nOrder, aZabIsp)
local i
local j
local _alias
local _jg
local imin
local imax
local nGet
local nRet 
local nLen
local nRed
local nKolona
local nTekRed
local nTrebaRedova
local oTable
local nPrevRecNo
local cMCField
local nMCScan
local _vars

private nXP
private nYP
private cPom
private aQQ
private aUsl
private aStruct

nPrevRecNo:=RECNO()

lNovi:=.f.

if _LOG_PROMJENE == .t.
        // daj stare vrijednosti
    cOldDesc := _g_fld_desc("w")
endif

add_match_code(@ImeKol, @Kol)

__A_SIFV__[__PSIF_NIVO__,3] :=  Ch

if Ch==K_CTRL_N .or. Ch==K_F2

    if nOrdid<>0
        set order to tag "ID"
    else
        set order to tag "1"
    endif
    go (nPrevRecNo)

endif

//
// odrednica za novi zapis....
//

if Ch == K_CTRL_N
    lNovi := .t.
    go bottom
    skip 1
endif

if Ch == K_F4
    lNovi := .t.
endif


do while .t.
   
    // setuj varijable za tekuci slog
    set_sif_vars()
  
    if Ch == K_CTRL_N
        // nastimaj default vrijednosti za sifrarnik robe
        set_roba_defaults()
    endif
 
    nTrebaredova := LEN(ImeKol)

    for i := 1 to LEN(ImeKol)
        if LEN(ImeKol[i]) >= 10 .and. Imekol[i, 10] <> NIL
            nTrebaRedova--
        endif
    next

    i := 1 
    // tekuci red u matrici imekol
    for _jg := 1 to 3  // glavna petlja
            
        // moguca su  tri get ekrana

        if _jg == 1
            Box( NIL, MIN( MAXROWS()-7, nTrebaRedova) + 1, MAXCOLS()-20 ,.f.)
        else
            BoxCLS()
        endif

        set cursor on
        private Getlist:={}

        // brojac get-ova
        nGet := 1 

        // broj redova koji se ne prikazuju (_?_)
        nNestampati := 0  

        nTekRed := 1

        do while .t. 
           
            lShowPGroup := .f.
                
            if EMPTY( ImeKol[ i, 3 ] )  
                // ovdje se kroji matrica varijabli.......
                // area->nazpolja
                cPom := ""  
            else
                cPom := set_w_var(ImeKol, i, @lShowPGroup)
            endif

            cPic := ""

            // samo varijable koje mozes direktno mjenjati
            if !empty(cPom) 
                sif_getlist(cPom, @GetList,  lZabIsp, aZabIsp, lShowPGroup, Ch, @nGet, @i, @nTekRed)
                nGet++
            else
                nRed := 1
                nKolona:=1
                if LEN(ImeKol[i]) >= 10 .and. Imekol[i, 10] <> NIL
                    nKolona:= imekol[i, 10]
                    nRed := 0
                endif

                // TODO: ne prikazuj nil vrijednosti
                //if EVAL(ImeKol[i, 2]) <> NIL .and. ToStr(EVAL(ImeKol[i,2])) <> "_?_"  
                    if nKolona == 1
                        ++nTekRed
                    endif
                    @ m_x + nTekRed, m_y + nKolona SAY PADL( ALLTRIM(ImeKol[i, 1]) ,15)
                    @ m_x + nTekRed, col() + 1 SAY EVAL(ImeKol[i,2])
                //else
                //    ++nNestampati
                //endif

            endif 

            i++                               
                
            // ! sljedeci slog se stampa u istom redu
            if ( len(imeKol) < i) .or. (nTekRed > MIN( MAXROWS() -7, nTrebaRedova) .and. !(Len(ImeKol[i] ) >= 10 .and. imekol[i, 10] <> NIL)  )
                    // izadji dosao sam do zadnjeg reda boxa, ili do kraja imekol
                exit 
            endif
        enddo

        // key handleri F8, F9, F5
        SET KEY K_F8 TO NNSifru()
        SET KEY K_F9 TO n_num_sif()
        SET KEY K_F5 TO NNSifru2()

        READ
        
        SET KEY K_F8 TO
        SET KEY K_F9 TO
        SET KEY K_F5 TO

        if ( len(imeKol) < i)
            exit
        endif

    next 

    BoxC()

    if Ch <> K_CTRL_A
        exit
    else

        // ovo vazi samo za CTRL + A opciju !!!!!

        if LastKey() == K_ESC
            exit
        endif
             
        _vars := get_dbf_global_memvars("w")
        
        _alias := LOWER(ALIAS())        

        if !f18_lock_tables( { _alias, "sifv", "sifk", _alias } )
            log_write( "ERROR: nisam uspio lokovati tabele: " + _alias + ", sifk, sifv", 2 )
            exit
        endif

        sql_table_update( nil, "BEGIN" )

        // sifarnik
        update_rec_server_and_dbf( _alias, _vars, 1, "CONT" )

        // sifk/sifv
        update_sifk_na_osnovu_ime_kol_from_global_var(ImeKol, "w", Ch==K_CTRL_N, "CONT")

        f18_free_tables( { _alias, "sifv", "sifk" } )

        sql_table_update( nil, "END" )

        set_global_vars_from_dbf("w")

        if lastkey() == K_PGUP
            skip -1
        else
            skip
        endif

        if EOF()
            skip -1
            exit
        endif

    endif

enddo


if Ch == K_CTRL_N .or. Ch == K_F2
    ordsetfocus( nOrder )
endif

if lastkey() == K_ESC
    
    if lNovi
        go (nPrevRecNo)
    endif

    return 0

endif

// ako je novi zapis napravi APPEND BLANK
if lNovi

    // provjeri da li vec ovaj id postoji ?
    nNSInfo := _chk_sif("w")

    if nNSInfo = 1  
        msgbeep("Ova sifra vec postoji !")
        return 0
    elseif nNSInfo = -1
        return 0
    endif

    append blank

endif

//
// uzmi mi varijable sa unosne maske
//

_vars := get_dbf_global_memvars("w")

//
// lokuj tabele i napravi update zapisa....
//

if f18_lock_tables( { LOWER( ALIAS() ), "sifv", "sifk" } )

    sql_table_update( nil, "BEGIN" )
	
    if !update_rec_server_and_dbf( ALIAS(), _vars, 1, "CONT" )

        if lNovi
            delete_with_rlock()
        endif

        f18_free_tables( { LOWER( ALIAS() ), "sifv", "sifk" })
        sql_table_update( nil, "ROLLBACK" )

    else

        update_sifk_na_osnovu_ime_kol_from_global_var( ImeKol, "w", lNovi, "CONT" )
        f18_free_tables( { LOWER( ALIAS() ), "sifv", "sifk" } )
        sql_table_update( nil, "END" )
 
    endif
else

    if lNovi
        // izbrisi ovaj append koji si dodao....
        delete_with_rlock()
    endif

    MsgBeep("ne mogu lockovati " + LOWER(ALIAS()) + " sifk/sifv ?!") 

endif

// ovo je potrebno radi nekih sifrarnika koji nakon ove opcije opet koriste
// globalne memoriske varijable w....
set_global_vars_from_dbf("w")

if Ch == K_F4 .and. Pitanje( , "Vrati se na predhodni zapis", "D" ) == "D"
    go (nPrevRecNo)
endif
    
return 1


static function set_w_var(ImeKol, _i, show_grup)
local _tmp, _var_name

if left(ImeKol[_i, 3], 6) != "SIFK->"

    _var_name := "w" + ImeKol[_i, 3]    
    // npr WVPC2
    // ako provjerimo strukturu, onda mozemo vidjeti da trebamo uzeti
    // varijablu karakteristike("ROBA","V2")

else
      // ako je SIFK->GRUP, prikazuj status
    if ALIAS() == "PARTN" .and. RIGHT(ImeKol[_i, 3], 4) == "GRUP"
        show_grup := .t.
    endif

    _var_name := "wSifk_" + substr(ImeKol[_i, 3], 7)

    _tmp := IzSifk(ALIAS(), substr(ImeKol[_i, 3], 7))
      
    if _tmp == NIL  
        // ne koristi se !!!
        _var_name := ""
    else
        __MVPUBLIC(_var_name)
        EVAL(MEMVARBLOCK(_var_name), _tmp)
    endif

endif

return _var_name



static function sif_getlist(var_name, GetList, lZabIsp, aZabIsp, lShowGrup, Ch, nGet, i, nTekRed)
local bWhen, bValid, cPic
local nRed, nKolona
local cWhenSifk, cValidSifk
local _when_block, _valid_block
local _m_block := MEMVARBLOCK(var_name)
local tmpRec

// uzmi when, valid kodne blokove
if (Ch==K_F2 .and. lZabIsp .and. ASCAN(aZabIsp, UPPER(ImeKol[i, 3]))>0)
    bWhen := {|| .f.}
elseif (LEN(ImeKol[i]) < 4 .or. ImeKol[i, 4]==nil)
    bWhen := {|| .t.}
else
    bWhen := Imekol[i, 4]
endif

if (len(ImeKol[i]) < 5 .or. ImeKol[i, 5] == nil)
    bValid := {|| .t.}
else
    bValid := Imekol[i, 5]
endif

_m_block := MEMVARBLOCK(var_name) 

if _m_block == NIL
  MsgBeep("var_name nedefinisana :" + var_name)
endif

if LEN( ToStr( EVAL(_m_block)) ) > 50
        cPic := "@S50"
        @ m_x + nTekRed + 1, m_y + 67 SAY Chr(16)

elseif Len(ImeKol[i]) >= 7 .and. ImeKol[i , 7] <> NIL
        cPic := ImeKol[i, 7]
else
        cPic := ""
endif

nRed := 1
nKolona := 1

if Len(ImeKol[i]) >= 10 .and. Imekol[i,10] <> NIL
        nKolona := ImeKol[i, 10] + 1
        nRed := 0
endif

if nKolona == 1
        nTekRed ++
endif
    
if lShowPGroup
        nXP := nTekRed
        nYP := nKolona
endif

// stampaj grupu za stavku "GRUP"
if lShowPGroup
        p_gr( &var_name, m_x + nXP, m_y + nYP + 1 )
endif

if "wSifk_" $ var_name
        // uzmi when valid iz SIFK
        
        IzSifKWV(ALIAS(), substr(var_name, 7) , @cWhenSifk, @cValidSifk)

        if !empty(cWhenSifk)
            _when_block := & ("{|| " + cWhenSifk + "}")
        else
            _when_block := bWhen
        endif

        if !empty(cValidSifk)
            _valid_block := & ("{|| " + cValidSifk + "}")
        else
            _valid_block := bValid
        endif         
else
        _when_block := bWhen
        _valid_block := bValid
endif

@ m_x + nTekRed , m_y + nKolona SAY  IIF(nKolona > 1, "  " + ALLTRIM(ImeKol[i, 1]) , PADL( ALLTRIM(ImeKol[i, 1]) , 15))  + " "

if &var_name == NIL
    tmpRec = RECNO()
    GO BOTTOM
    SKIP
    // EOF record
    &var_name := EVAL(ImeKol[i, 2])
    go tmpRec
endif

AAdd( GetList, _GET_( &var_name, var_name,  cPic, _valid_block, _when_block) ) ;;

ATail(GetList):display()

return .t.


// -----------------------------------------
// -----------------------------------------
static function add_match_code(ImeKol, Kol)
local  _pos, cMCField := ALIAS()

// dodaj u matricu match_code ako ne postoji
if (cMCField)->(fieldpos("MATCH_CODE")) <> 0

    _pos := ASCAN(ImeKol, {|xImeKol| UPPER(xImeKol[3]) == "MATCH_CODE"})
    
    // ako ne postoji dodaj ga...
    if _pos == 0
        // dodaj polje u ImeKol
        AADD(ImeKol, {"MATCH_CODE", {|| match_code}, "match_code" })
        // dodaj novu stavku u kol
        AADD( Kol, LEN(ImeKol) )
    endif

endif


// --------------------------------------------------
// kod sifarnika partnera se mora potvrditi ma
// --------------------------------------------------
static function _chk_sif( cMarker )
local cFName
local xFVal
local cFVal
local cType
local nTArea := SELECT()
local nTREC := RECNO()
local nRet := 0
local i := 1
local cArea := ALIAS( nTArea )
private cF_Seek
private GetList := {}

cFName := ALLTRIM( FIELD(i) )
xFVal := FIELDGET(i)
cType := VALTYPE(xFVal)
cF_Seek := &( cMarker + cFName )

if ( cType == "C" ) .and. ( cArea $ "#PARTN#ROBA#" )
    
    go top
    seek cF_seek

    if FOUND()
        nRet := 1
        go (nTRec )
    endif

endif

select (nTArea)

return nRet


// --------------------------------------------------
// vraca naziv polja + vrijednost za tekuci alias
// cMarker = "w" ako je Scatter("w")
// --------------------------------------------------
static function _g_fld_desc( cMarker )
local cRet := ""
local i
local cFName
local xFVal
local cFVal
local cType

for i := 1 to FCOUNT()

    cFName := ALLTRIM( FIELD(i) )
    
    xFVal := FIELDGET(i)
    
    cType := VALTYPE(xFVal)
    
    if cType == "C"
        // string
        cFVal := ALLTRIM(xFVal)
    elseif cType == "N"
        // numeric
        cFVal := ALLTRIM(STR(xFVal, 12, 2))
    elseif cType == "D"
        // date
        cFVal := DTOC(xFVal)
    endif
    
    cRet += cFName + "=" + cFVal + "#"
next

return cRet

// ----------------------------------------------------
// uporedjuje liste promjena na sifri u sifrarniku
// ----------------------------------------------------
static function _g_fld_changes( cOld, cNew )
local cChanges := "nema promjena - samo prolaz sa F2"
local aOld
local aNew
local cTmp := ""

// stara matrica
aOld := TokToNiz(cOld, "#")
// nova matrica
aNew := TokToNiz(cNew, "#")

// kao osnovnu referencu uzmi novu matricu
for i := 1 to LEN( aNew )

    cVOld := ALLTRIM(aOld[i])
    cVNew := ALLTRIM(aNew[i])
    if cVNew == cVOld
        // do nothing....
    else
        cTmp += "nova " + cVNew + " stara " + cVOld + ","
    endif
next

if !EMPTY(cTmp)
    cChanges := cTmp
endif

return cChanges

// -----------------------
// -----------------------
static function set_sif_vars()
local _i, _struct
private cImeP
private cVar

_struct := DBSTRUCT()

SkratiAZaD(@_struct)

for _i := 1 to LEN(_struct)
     cImeP := _struct[_i, 1]
     cVar:="w" + cImeP
     
     &cVar := &cImeP
next

return


// --------------------------------------------------------
// setuje default vrijednosti tekuceg sloga za sif.roba
// --------------------------------------------------------
static function set_roba_defaults()

if ALIAS() <> "ROBA"
    return
endif

// set tarifa uvijek PDV17
widtarifa := PADR( "PDV17", 6 )

return



//-------------------------------------------------------
//-------------------------------------------------------
static function popup(nOrder)

private Opc:={}
private opcexe:={}
private Izbor

AADD(Opc, "1. novi                  ")
AADD(opcexe, {|| edit_item(K_CTRL_N, nOrder) } )
AADD(Opc, "2. edit  ")
AADD(opcexe, {|| edit_item(K_F2, nOrder) } )
AADD(Opc, "3. dupliciraj  ")
AADD(opcexe, {|| edit_item(K_F4, nOrder) } )
AADD(Opc, "4. <a+R> za sifk polja  ")
AADD(opcexe, {|| repl_sifk_item() } )
AADD(Opc, "5. copy polje -> sifk polje  ")
AADD(opcexe, {|| copy_to_sifk() } )

Izbor:=1
Menu_Sc("bsif")

return 0


// -------------------------------------------
// sredi uslov ako nije postavljeno ; na kraj
// -------------------------------------------
static function _fix_usl(xUsl)
local nLenUsl := LEN(xUsl)
local xRet := SPACE(nLenUsl)

if EMPTY(xUsl)
    return xUsl
endif

if RIGHT(ALLTRIM(xUsl), 1) <> ";"
    xRet := PADR( ALLTRIM(xUsl) + ";", nLENUSL )
else
    xRet := xUsl
endif

return xRet


// -------------------------------
// -------------------------------
static function sif_brisi_stavku()
local _rec_dbf, _rec, _alias

if Pitanje( , "Zelite li izbrisati ovu stavku ??","D") == "D"

    PushWa()

    _alias := ALIAS()

    sql_table_update(nil, "BEGIN")

    _rec_dbf := dbf_get_rec()
    delete_rec_server_and_dbf(ALIAS(), _rec_dbf, 1, "CONT")

    // ako postoji id polje, pobriši i sifv
    if hb_hhaskey( _rec_dbf, "id" )
        SELECT (F_SIFV)
        if !USED()
            O_SIFV
        endif
   
        _rec := hb_hash()
        _rec["id"]    := PADR(_alias, 8)
        _rec["idsif"] := PADR(_rec_dbf["id"], 15)
        // id + idsif
        delete_rec_server_and_dbf("sifv", _rec, 3, "CONT")
    endif

    sql_table_update(nil, "END")

    PopWa()
    return DE_REFRESH
else
    return DE_CONT
endif

RETURN DE_REFRESH

// -------------------------------
// -------------------------------
static function sif_brisi_sve()

if Pitanje( , "Zelite li sigurno izbrisati SVE zapise ??", "N") == "N"
    return DE_CONT
endif
        
Beep(6)
    
nTArea := SELECT()
// logiraj promjenu brisanja stavke
if _LOG_PROMJENE == .t.
    EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
    "", "", "", DATE(), DATE(), "", ;
    "pokusaj brisanja kompletnog sifrarnika")
endif
select (nTArea)

if Pitanje( , "Ponavljam : izbrisati BESPOVRATNO kompletan sifrarnik ??","N")=="D"
        
    delete_all_dbf_and_server(ALIAS())   
    select (nTArea)

endif
        
return DE_REFRESH


// ---------------------------------------------------
// ---------------------------------------------------
static function PushSifV()
__PSIF_NIVO__ ++
if __PSIF_NIVO__ > len(__A_SIFV__)
  AADD(__A_SIFV__,{"",0,0})
endif
return

// ------------------------------
// ------------------------------
static function PopSifV()
--__PSIF_NIVO__
return


// ---------------------------------------------------------------------
//  VpSifra(wId)
//  Stroga kontrola ID-a sifre pri unosu nove ili ispravci postojece!
//  wId - ID koji se provjerava
// --------------------------------------------------------------------
function sifra_postoji( wId, cTag )
local nRec := RecNo()
local nRet := .t.
local cUpozorenje

if cTag == NIL
   cTag := "ID"
endif

if index_tag_num(cTag) == 0
   _msg := "alias: " + ALIAS() + ", tag ne postoji :" + cTag
   log_write(_msg)
   MsgBeep(_msg)
   QUIT_1
endif

// ako nije tag = ID, dozvoli i dupli unos, moze biti barkod polje
if cTag <> "ID" .and. EMPTY( wId )
    return nRet
endif

cUpozorenje := "Vrijednost polja " + cTag + " vec postoji !!!"

PushWa()

SET ORDER TO TAG (cTag)
seek wId

if ( FOUND() .and. ( Ch == K_CTRL_N .or. Ch == K_F4 ) ) 
    
    MsgBeep( cUpozorenje )
    nRet := .f.

elseif ( gSKSif == "D" .and. FOUND() )    
    // nasao na ispravci ili dupliciranju
    if nRec <> RecNo()
        MsgBeep(cUpozorenje)
        nRet:=.f.
    else       
        // bio isti zapis, idi na drugi
        skip 1
        if (!EOF() .and. wId==id)
            MsgBeep(cUpozorenje)
            nRet := .f.
        endif
    endif
endif

PopWa()

return nRet


