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

/* \fn DBT2FPT(cImeDBF)
 * \brief Konvertuje memo polja iz DBT u FTP format (Clipper NTX -> FOX CDX)
 *
 * \note Obavezno proslijediti c:\sigma\ROBA - BEZ EXTENZIJE
 *
 */

function DBT2FPT(cImeDBF)

cImeDbf := strtran(cImeDBF,"."+DBFEXT,"")
my_close_all_dbf()

if file(cimedbf+".DBT") .and. Pitanje(,"Izvrsiti konverziju "+cImeDBF," ")=="D"
   if file(cimedbf+".FPT")
     MsgBeep("Ne smije postojati"+cImeDBF+".FPT ????#Prekidam operaciju !")
     return
   endif
     MY_use (cImeDBF, nil, .t., "DBFNTX")
   MsgO("Konvertujem "+cImeDBF+" iz DBT u FPT")
     Beep(1)
     copy structure extended to struct
     my_USEX("STRUCT", nil, .t.)
     dbappend()
     replace field_name with "BRISANO" , field_type with "C", ;
        field_len with 1, field_dec with 0
     use

     my_close_all_dbf()
     COPY FILE (cImeDBF+".DBF") TO (PRIVPATH+"TEMP.DBF")
     COPY FILE (cImeDBF+".DBT") TO (PRIVPATH+"TEMP.DBT")
     ferase(cImeDBF+".DBT")
     ferase(cImeDBF+".DBF")
     ferase(cImeDBF+".CDX")
     ferase(cImeDBF+".FPT")
     create (cImeDBF) from struct  VIA RDDENGINE
     my_close_all_dbf()
     MY_USE (PRIVPATH+"TEMP", nil, .t., "DBFNTX")
     set order to 0
     MY_USE (cImeDBF, "novi", .t., RDDENGINE)
     set order to 0
     select temp
     go top
     do while !eof()
       scatter()
       select novi
       append blank
       gather()
       select temp
       skip
     enddo

   MsgC()
endif

my_close_all_dbf()

return


