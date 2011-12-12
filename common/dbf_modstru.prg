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


/*! \fn ModStru(ime_dbf, path, string_par)
 *  \brief procedura modifikacija struktura
 * string_par - .t. ako saljem string umjesto imena fajla
 */

// ----------------------------------
// ----------------------------------
function modstru_form_file(chs_file)
local oFile
local _ret := {}

oFile := TFileRead():New(chs_file)
oFile:Open()

do while oFile:MoreToRead()
  AADD(_ret, oFile:ReadLine())
enddo

oFile:Close()

modstru(_ret)

// ------------------------------------------------------------------
//  Modstru({"*fin_budzet.dbf", "C EKKATEG C 5 0  IDKONTO C 7 0", "})

function ModStru (a_commands)
local _path, _ime_dbf
local _brisi_dbf := .f.,  _rename_dbf := NIL
local _linija := 0
local _lin
local _stru_changed := .f.
local _curr_stru, _new_stru

? SPACE(40),"bring.out, 10.99-11.11, ver 02.6"
? SPACE(40),"---------------------------------"
?
// ne kopiraj izbrisane zapise !!!
set deleted on  
close all

SET AUTOPEN OFF

? "modstru start:"

_ime_dbf:=""
_path := my_home()

for each _lin in a_commands
  
    if empty(_lin) .or.  left(_lin, 1) == ";"
        loop
    endif

    if LEFT(_lin, 1) == "*"
       
       kopi(_path, _ime_dbf, @_brisi_dbf, @_rename_dbf, @_stru_changed)
       
       _lin := substr(_lin, 2, len(trim(_lin))-1)

       _ime_dbf:=alltrim(_lin)
       _ime_dbf:= LOWER( _ime_dbf + iif( AT(".", _ime_dbf) <> 0, "", ".dbf") )

       ?  _path + _ime_dbf

       if file( _path + _ime_dbf )
           select 1
           my_usex ( "olddbf", _ime_dbf, .f.)
       else
           _ime_dbf := "*"
           ?? "  Ne nalazi se u direktorijumu"
       endif

       _stru_changed := .f.   
  
       _curr_stru := DBSTRUCT()
       _new_stru := ACLONE(_curr_stru)      

    endif

    if empty(_ime_dbf)
          ? "Nije zadat DBF fajl nad kojim se vrsi modifikacija strukture !"
          return .f.
    endif

    _op := Rjec(@_lin)
    chs_op(_op, @_lin, @_curr_stru, @_new_stru, @_brisi_dbf, @_rename_dbf, @_stru_changed)

next


kopi(_path, _ime_dbf, @_brisi_dbf, @_rename_dbf, @_stru_changed)


SET AUTOPEN ON 
return

// ---------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------
static function chs_op(op, lin, curr_stru, new_stru, brisi_dbf, rename_dbf, stru_changed)

local _ime_p, _tip, _len, _dec
local _ime_p_2, _tip_2, _len_2, _dec_2
local _pos, _pos_2
local _l := lin

op := ALLTRIM(op)

DO CASE

   CASE op == "IZBRISIDBF"
          brisi_dbf:=.t.

   CASE op == "IMEDBF"
          rename_dbf :=Rjec(@lin)

   CASE op == "A"
          _ime_p := Rjec(@lin)
          _tip := Rjec(@lin)
          _len := VAL(Rjec(@lin))
          _dec := VAL(Rjec(@lin))
          if !(_len > 0 .and. _len > _dec) .or. ( _tip == "C" .and. _dec > 0) .or. !(_tip $ "CNDM")
                ? "Greska: Dodavanje polja, linija:", _l
                return .f.
          endif

          _pos := ASCAN(curr_stru, {|x| x[1]== _ime_p})
          if _pos <>0
                ? "Greska: Polje " + _ime_p + " vec postoji u DBF-u, linija:", _l
                return .f.
          endif

          ? "Dodajem polje:", _ime_p, _tip, _len, _dec
          AADD(new_stru, { _ime_p, _tip, _len, _dec} )
         
         stru_changed := .t.

   CASE op == "D"

          _ime_p :=upper(Rjec(@_lin))
          _pos := ASCAN(new_stru, {|x| x[1]== _ime_p})
          if _pos<>0
                ? "Brisem polje:", _ime_p
                ADEL (stru_new, _pos)
                // prepakuj array
                Prepakuj(@_stru_new)  
                stru_changed:=.t.
          else
                ? "Greska: Brisanje nepostojeceg polja, linija:", _l
          endif

    CASE op == "C"

          _ime_p :=upper (Rjec(@lin))
          _tip := Rjec(@lin)
          _len := VAL(Rjec(@lin))
          _dec := VAL(Rjec(@lin))
           
          _pos := ASCAN(curr_stru, {|x| x[1]== _ime_p .and. x[2]== _tip .and. x[3]== _len .and. x[4]== _dec})
           if _pos ==0
                ? "Greska: zadana je promjena nepostojeceg polja, linija:", _l
                return .f.
           endif

           _ime_p_2 := UPPER(Rjec(@lin))
           _tip_2 := UPPER(Rjec(@lin))
           _len_2 := VAL(Rjec(@lin))
           _dec_2 := VAL(Rjec(@lin))
                 
           _pos_2 := ASCAN( curr_stru, {|x| x[1]== _ime_p_2})
           if _pos_2 <> 0 .and.  _ime_p <> _ime_p_2
                ? "Greska: zadana je promjena u postojece polje, linija:", _l
                return .t.
           endif
           stru_changed :=.t.

           if _tip == _tip_2
               stru_changed := .t.
           endif
 
            if ( _tip=="N" .and. _tip_2=="C")   
               stru_changed:=.t.
            endif
            
            if ( _tip=="C" .and. _tip_2=="N")   
               stru_changed:=.t.
            endif
            
            if ( _tip=="C" .and. _tip_2=="D")   
                stru_changed:=.t.
            endif
                
            if !stru_changed
                ? "Greska: Neispravna konverzija, linija:", _l
            endif

            AADD(curr_stru[_pos], _ime_p_2)
            AADD(curr_stru[_pos], _tip_2)
            AADD(curr_stru[_pos], _len_2)
            AADD(curr_stru[_pos], _dec_2)
                    

            _pos := ASCAN(new_stru, {|x| x[1]==_ime_p.and. x[2]==_tip .and. x[3]==_len .and. x[4]==_dec})
            new_stru[_pos] := { _ime_p_2, _tip_2, _len_2, _dec_2 }

            ? "Vrsim promjenu:",  _ime_p, _tip, _len, _dec, " -> ", _ime_p_2, _tip_2, _len_2, _dec_2
 
             stru_changed := .t.          

    OTHERWISE
           ? "greska nepostojeca operacija", op
           return .f.

END CASE


return .t. 


// -----------------------------
// _ime_dbf obavezno "test.dbf"
// -----------------------------
function kopi(path, ime_dbf, brisi_dbf, rename_dbf, stru_changed)
local _pos, _pos_2
local _ext, _ime_old, _ime_new
local _ime_p, _row, _path_2, _tmp
local _ime_file, _ime_tmp, _ime_bak
local _cdx_file

if brisi_dbf
     _pos := AT(".", ime_dbf)

     select olddbf
     use

     ferase(path + left( ime_dbf, _pos) + DBFEXT)
     ? "BRISEM :",path + left(ime_dbf, _pos) + DBFEXT

     ferase(path + left( ime_dbf,  _pos) + FPTEXT)
     ? "BRISEM :", path + left( ime_dbf, _pos) + FPTEXT

     brisi_dbf := .f.
     return
endif

if rename_dbf != NIL

     _pos := at(".", ime_dbf)
     _pos_2 := at(".", _rename_dbf)

     select olddbf
     use

     for each _ext in {DBFEXT, FPTEXT}

       ime_dbf_old := path + left(_ime_dbf, _pos) +  _ext
       ime_dbf_new := path + left(_rename_dbf, _pos_2) + _ext
           if FRENAME(_ime_old, _ime_new) == 0
          ? "PREIMENOVAO :", _ime_old," U ", _ime_new
       endif

     next

     _rename_dbf := NIL
endif


if stru_changed

     _pos := RAT(SLASH, ime_dbf)
     
     if _pos <> 0
       _path_2 := substr(ime_dbf, 1, _pos)
     else
       _path_2 := ""
     endif

     _cdx_file := strtran(ime_dbf, "." + DBFEXT, "." + INDEXEXT)
     if right(_cdx_file, 4) == "." + INDEXEXT 
       // izbrisi cdx
       FERASE( path + _cdx_file)
     endif

     for each _tmp in { FPTEXT, INDEXEXT, DBFEXT} 
        FERASE(path + _path_2 + "modstru_tmp." + _tmp)
     next

     DBCREATE( my_home() + "modstru_tmp." + DBFEXT, new_stru)

     select 2
     USE ( my_home() + "modstru_tmp." + DBFEXT) ALIAS "tmp" EXCLUSIVE 
     select olddbf  

     ?
     
     _row:=row()

     @ _row, 20 SAY "/"
     ?? reccount()

     set order to 0
     go top

     do while !eof()

        @ _row, 1  SAY recno()
        select tmp
     
        APPEND BLANK

        for _i := 1 to LEN(curr_stru)
         
         _ime_p := curr_stru[_i, 1]
         
            if len(curr_stru[_i]) > 4

                _ime_p_new := stru_new[_i, 5]

                DO CASE
                    
                    CASE curr_stru[_i, 2] == curr_stru[i, 6]
                        EVAL(FIELDBLOCK(_ime_p_new),  EVAL( FIELDWBLOCK("olddbf", _ime_p) )) 
                    CASE curr_stru[_i, 2] == "C" .and. curr_stru[i, 6] == "N"
                        EVAL(FIELDBLOCK(_ime_p_new),  VAL(EVAL( FIELDWBLOCK("olddbf", _ime_p) ))) 
                    CASE curr_stru[_i, 2] == "N" .and. curr_stru[i, 6] == "C"
                        EVAL(FIELDBLOCK(_ime_p_new),  STR(EVAL( FIELDWBLOCK("olddbf", _ime_p) ))) 
                        CASE curr_stru[_i, 2] == "C" .and. curr_stru[i, 6] == "D"
                        EVAL(FIELDBLOCK(_ime_p_new),  CTOD(EVAL( FIELDWBLOCK("olddbf", _ime_p) ))) 
                
                END CASE

            else
                _pos := ASCAN( stru_new, {|x| _ime_p== x[1]} )
                if _pos <> 0 
                    EVAL(FIELDBLOCK(_ime_p),  EVAL( FIELDWBLOCK("olddbf", _ime_p) )) 
                endif
            endif
        next

        select olddbf
        skip
    
   enddo 

   close all
     
   _pos := RAT(".", ime_dbf)


   for each _tmp in { DBFEXT, FPTEXT, INDEXEXT }

      _ime_file := my_home() + LEFT(ime_dbf, _pos) + _tmp + "_bak"
      // modstru_tmp.dbf
      _ime_tmp := my_home() + "modstru_tmp." + _tmp
      // fin_suban.dbf_bak
      _ime_bak := my_home() + LEFT(ime_dbf, _pos) + _tmp + "_bak"

      if FILE( _ime_file)
        FERASE( _ime_bak)
        FRENAME(_ime_tmp, _ime_bak)
        FERASE(_ime_tmp )
      endif

   next
 
endif

return


// -------------------
// -------------------
function Rjec(cLin)

local cOp,nPos

nPos:=aT(" ",cLin)
if nPos==0 .and. !empty(cLin) // zadnje polje
  cOp:=alltrim(clin)
  cLin:=""
  return cOp
endif

cOp:=alltrim(left(cLin,nPos-1))
cLin:=right(cLin,len(cLin)-nPos)
cLin:=alltrim(cLin)
return cOp


function Prepakuj(aNStru)

local i,aPom
aPom:={}
for i:=1 to len(aNStru)
  if aNStru[i]<>nil
   aadd(aPom,aNStru[i])
  endif
next
aNStru:=aClone(aPom)
return nil


