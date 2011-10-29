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

/*

fin/o_fin.ch:#xcommand O_DEST     => select(F_DEST);  MY_USE  (STRTRAN(KUMPATH,"FIN","FAKT")+"DEST")     ; set order to tag "1"

*/

function my_use(cTable)

USE (my_home() + cTable)

return

function usex(cTable)
return my_use(cTable)


/*
#command USEX <(db)>                                                   ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
             [<ro: READONLY>]                                           ;
             [INDEX <(index1)> [, <(indexn)>]]                          ;
                                                                        ;
      =>  PreUseEvent(<(db)>,.f.,gReadOnly)				;
        ;  dbUseArea(                                                   ;
                    <.new.>, <rdd>, ToUnix(<(db)>), <(a)>,              ;
                     .f., gReadOnly       ;
                  )                                                     ;
                                                                        ;
      [; dbSetIndex( <(index1)> )]                                      ;
      [; dbSetIndex( <(indexn)> )]


*/


