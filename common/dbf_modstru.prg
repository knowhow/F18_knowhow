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
#include "f18.ch"


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
//  Modstru({"*fin_budzet", "C IDKONTO C 10 0",  "A IDKONTO2 C 7 0"})
// ------------------------------------------------------------------
function modstru(a_commands)
local _path, _ime_dbf
local _brisi_dbf := .f.,  _rename_dbf := NIL
local _linija := 0
local _lin
local _stru_changed := .f.
local _curr_stru, _new_stru
local _full_name
local _msg

CLOSE ALL

log_write("Modstru cmd: " + pp(a_commands), 7)

Box(, 6, 65, .f., "DBF modstru")

@ m_x + 1, m_y + 2 SAY "DBF modifikacija struktura"


_ime_dbf:=""
_path := my_home()

for each _lin in a_commands
  
    if empty(_lin) .or.  left(_lin, 1) == ";"
        loop
    endif

    if LEFT(_lin, 1) == "*"
      
       kopi(_path, _ime_dbf, _curr_stru, _new_stru, @_brisi_dbf, @_rename_dbf, @_stru_changed)
       
       _lin := substr(_lin, 2, len(trim(_lin))-1)

       _ime_dbf := ALLTRIM(_lin)


       _full_name := _path + _ime_dbf + "." + DBFEXT       
       if file(_full_name)
           select 1

           _msg := "START modstru: " + _path + _ime_dbf
           log_write( _msg, 5 )
           @ m_x + 3, m_y + 2 SAY _msg

           USE  (_path + _ime_dbf) ALIAS OLDDBF EXCLUSIVE
       else
           _ime_dbf := "*i"
           BoxC()
           log_write( "MODSTRU, nepostojeca tabela: " +  _full_name, 2 )
           return .f.
       endif

       _stru_changed := .f.   
  
       _curr_stru := DBSTRUCT()
       _new_stru := ACLONE(_curr_stru)      

        if empty(_ime_dbf)
            log_write( "MODSTRU, nije zadat DBF fajl nad kojim se vrsi modifikacija strukture !", 3 )
            CLOSE ALL
            return .f.
        endif


    else
         _op := Rjec(@_lin)
         if !chs_op(_op, @_lin, @_curr_stru, @_new_stru, @_brisi_dbf, @_rename_dbf, @_stru_changed)
              log_write( "MODSTRU, problem: " + _ime_dbf, 2 )
         endif
    endif
next

kopi(_path, _ime_dbf, _curr_stru, _new_stru, @_brisi_dbf, @_rename_dbf, @_stru_changed)

log_write("END modstru ", 2)

BoxC()
CLOSE ALL
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
                log_write( "MODSTRU, greska: dodavanje polja, linija: " + _l, 5 )
                return .f.
          endif

          _pos := ASCAN(curr_stru, {|x| x[1]== _ime_p})
          if _pos <> 0
                log_write( "MODSTRU, greska: polje " + _ime_p + " vec postoji u DBF-u, linija: " + _l, 5 )
                return .f.
          endif

          log_write( "MODSTRU, dodajem polje: " + _ime_p + ", tip: " + _tip + ", duzina: " + ALLTRIM(STR(_len )) + ", dec: " + ALLTRIM( STR( _dec )), 5 )
          AADD(new_stru, { _ime_p, _tip, _len, _dec} )
         
         stru_changed := .t.

   CASE op == "D"

          _ime_p := upper(Rjec(@lin))
          _pos := ASCAN(new_stru, {|x| x[1]== _ime_p})
          if _pos<>0
                log_write( "MODSTRU, brisem polje: " + _ime_p, 5 )
                ADEL (new_stru, _pos)
                // prepakuj array
                Prepakuj(@new_stru)  
                stru_changed := .t.
          else
                log_write( "MODSTRU, greska: brisanje nepostojeceg polja, linija: " + _l, 5 )
                return .f.
          endif

    CASE op == "C"

          _ime_p := upper (Rjec(@lin))
          _tip :=   Rjec(@lin)
          _len :=   VAL(Rjec(@lin))
          _dec :=   VAL(Rjec(@lin))
           
          _pos := ASCAN(curr_stru, {|x| x[1]== _ime_p .and. x[2]== _tip .and. x[3]== _len .and. x[4]== _dec})
           if _pos ==0
                log_write( "MODSTRU, greska: zadana je promjena nepostojeceg polja, linija: " + _l, 5 )
                return .f.
           endif

           _ime_p_2 := UPPER(Rjec(@lin))
           _tip_2 := UPPER(Rjec(@lin))
           _len_2 := VAL(Rjec(@lin))
           _dec_2 := VAL(Rjec(@lin))
                 
           _pos_2 := ASCAN( curr_stru, {|x| x[1]== _ime_p_2})
           if _pos_2 <> 0 .and.  _ime_p <> _ime_p_2
                log_write( "MODSTRU, greska: zadana je promjena u postojece polje, linija: " + _l, 5 )
                return .f.
           endif
           stru_changed :=.t.

           if _tip == _tip_2
               stru_changed := .t.
           endif
 
            if ( _tip=="N" .and. _tip_2=="C")   
               stru_changed := .t.
            endif
            
            if ( _tip=="C" .and. _tip_2=="N")   
               stru_changed := .t.
            endif
            
            if ( _tip=="C" .and. _tip_2=="D")   
                stru_changed := .t.
            endif
                
            if !stru_changed
                log_write( "MODSTRU, greska: neispravna konverzija, linija: " + _l, 5 )
                return .f.
            endif

            AADD(curr_stru[_pos], _ime_p_2)
            AADD(curr_stru[_pos], _tip_2)
            AADD(curr_stru[_pos], _len_2)
            AADD(curr_stru[_pos], _dec_2)
                    

            _pos := ASCAN(new_stru, {|x| x[1]==_ime_p.and. x[2]==_tip .and. x[3]==_len .and. x[4]==_dec})
            new_stru[_pos] := { _ime_p_2, _tip_2, _len_2, _dec_2 }

            log_write( "MODSTRU, vrsim promjenu: " + _ime_p + ", tip: " + _tip + ", duzina: " + ALLTRIM( STR(_len)) + ", dec: " + ALLTRIM(STR( _dec )) + " -> " + _ime_p_2 + ", tip: " + _tip_2 + ", duzina: " + ALLTRIM(STR(_len_2)) + ", dec: " +  ALLTRIM(STR(_dec_2)), 5 )
 
             stru_changed := .t.          

    OTHERWISE
           log_write( "MODSTRU, greska nepostojeca operacija: " + op, 5 )
           return .f.

END CASE


return .t. 


// -----------------------------
// ime_dbf obavezno "fin_budzet"
// -----------------------------
function kopi(path, ime_dbf, curr_stru, new_stru, brisi_dbf, rename_dbf, stru_changed)
local _pos, _pos_2
local _ext, _ime_old, _ime_new
local _ime_p, _row, _path_2, _tmp
local _ime_file, _ime_tmp, _ime_bak
local _cdx_file
local _f
local _cnt 

_f := path + ime_dbf + "."
if brisi_dbf
     select OLDDBF
     use

     ferase(_f + DBFEXT)
     log_write( "MODSTRU, brisem: " + _f + DBFEXT, 5 )

     ferase(_f +  MEMOEXT)
     log_write( "MODSTRU, brisem: " + _f + MEMOEXT, 5 )

     brisi_dbf := .f.
     return
endif

if rename_dbf != NIL

     select OLDDBF
     use
     for each _ext in {DBFEXT, MEMOEXT}

       _ime_old := _f  +  _ext
       _ime_new := path + rename_dbf + _ext
       if FRENAME(_ime_old, _ime_new) == 0
          log_write( "MODSTRU, preimenovao: " + _ime_old + " U " + _ime_new, 5 )
       endif

     next
     rename_dbf := NIL
endif


if stru_changed

     _cdx_file := path + ime_dbf + "." + INDEXEXT
     if FILE(_cdx_file)
       FERASE( path + _cdx_file)
     endif

     for each _tmp in { MEMOEXT, INDEXEXT, DBFEXT} 
        FERASE(path + "modstru_tmp." + _tmp)
     next

     DBCREATE( my_home() + "modstru_tmp." + DBFEXT, new_stru)

     select 2
     USE ( my_home() + "modstru_tmp." + DBFEXT) ALIAS "tmp" EXCLUSIVE 
     
     select OLDDBF 
     

     @ m_x + 5, m_y + 2 SAY RECCOUNT()
     set order to 0
     go top

     _cnt := 0
     do while !eof()

        select tmp
     
        APPEND BLANK

        for _i := 1 to LEN(curr_stru)
         
            _ime_p := curr_stru[_i, 1]
         
            if len(curr_stru[_i]) > 4

                _ime_p_new := curr_stru[_i, 5]
                DO CASE
                    CASE curr_stru[_i, 2] == curr_stru[_i, 6]
                        EVAL(FIELDBLOCK(_ime_p_new),  EVAL( FIELDWBLOCK(_ime_p, 1) ))
 
                    CASE (curr_stru[_i, 2] $ "BNIY") .and.  (curr_stru[_i, 6] $ "BNYI")
                        // jedan tip numerika u drugi tip numerika
                        EVAL(FIELDBLOCK(_ime_p_new),  EVAL( FIELDWBLOCK(_ime_p, 1) )) 

                    CASE curr_stru[_i, 2] == "C" .and. (curr_stru[_i, 6] $ "BNIY")
                        EVAL(FIELDBLOCK(_ime_p_new),  VAL(EVAL( FIELDWBLOCK(_ime_p, 1) )))
 
                    CASE (curr_stru[_i, 2] $ "BNIY") .and. curr_stru[_i, 6] == "C"
                        EVAL(FIELDBLOCK(_ime_p_new),  STR(EVAL( FIELDWBLOCK(_ime_p, 1) )))
 
                    CASE curr_stru[_i, 2] == "C" .and. curr_stru[_i, 6] == "D"
                        EVAL(FIELDBLOCK(_ime_p_new),  CTOD(EVAL( FIELDWBLOCK(_ime_p, 1) ))) 
                
                END CASE

             else
                 _pos := ASCAN( new_stru, {|x| _ime_p== x[1]} )
                 if _pos <> 0 
                     EVAL(FIELDBLOCK(_ime_p),  EVAL( FIELDWBLOCK(_ime_p, 1) )) 
                 endif
             endif
        next

        select OLDDBF

        ++ _cnt
        if (_cnt % 5) == 0
              @ m_x + 5, m_y + 15 SAY _cnt
        endif

        skip
    
    enddo

   CLOSE ALL
     
   for each _tmp in { DBFEXT, MEMOEXT, INDEXEXT }

      _ime_file := _f + _tmp
      // modstru_tmp.dbf
      _ime_tmp := my_home() + "modstru_tmp." + _tmp
      // fin_suban.dbf_bak
      _ime_bak := _f + _tmp + "_bak"

      if FILE(_ime_file)
        FERASE(_ime_bak)
        FRENAME(_ime_file, _ime_bak)
        FRENAME(_ime_tmp, _ime_file)
      endif

   next
 
endif

return


// -------------------
// -------------------
function Rjec(cLin)
local cOp, nPos

nPos:=aT(" ",cLin)
if nPos==0 .and. !empty(cLin) // zadnje polje
  cOp:=alltrim(clin)
  cLin:=""
  return cOp
endif

cOp  := alltrim(left(cLin,nPos-1))
cLin := right(cLin,len(cLin)-nPos)
cLin := alltrim(cLin)
return cOp


function Prepakuj(aNStru)
local i, aPom

aPom:={}

for i:=1 to LEN(aNStru)
  if aNStru[i]<>nil
     AADD(aPom, aNStru[i])
  endif
next

aNStru := ACLONE(aPom)

return nil


