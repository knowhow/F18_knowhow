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

function SifClipBoard()

if !SigmaSif("CLIP")
       msgBeep("Neispravna lozinka ....")
       return DE_CONT
endif

     private am_x:=m_x,am_y:=m_y
     m_x:=am_x
     m_y:=am_y
     private opc2[2]
     opc2[1]:="1. prenesi  -> sif0 (clipboard)  "
     opc2[2]:="2. uzmi    <-  sif0 (clipboard)  "
     private Izbor2:=1
     if reccount2()==0
       // ako je sifrarnik prazan, logicno je da ce se zeli preuzeti iz
       // clipboarda
       Izbor2:=2
     endif

     do while .t.
      Izbor2:=menu("9cf9",opc2,Izbor2,.f.)
      do case
        case Izbor2==0
            EXIT
        case izbor2 == 1
           // sifrarnik -> sif0

           nDBF:=select()
           if reccount2()==0
             MsgBeep("Sifrarnik je prazan, nema smisla prenositi u sif0")
             loop
           endif

           copy structure extended to struct
           nP2:=AT("\SIF",SIFPATH)         // c:\sigma\sif
           cPath:=left(SIFPATH,nP2) +"SIF0\"
           cDBF:=ALIAS()+".DBF"
           // c:\sigma\sif1\trfp.dbf -> c:\sigma\sif0\trfp.dbf
           DirMak2(cPath)
           if file(cPath+cDBF)
               MsgBeep("Tabela "+cPath+cDBF+" vec postoji !")
               if pitanje(,"Zelite li ipak prebaciti podatke u clipboard ?","N")=="N"
                    loop
               endif
           endif

           select (F_TMP)

           create (cPath+cDBF) from struct  VIA RDDENGINE alias TMP

           USE
           USEX (cPath+cDBF, "NOVI", .t.) 
           select (nDBF)
           set order to 0; go top
           do while !eof()
             scatter()
             select novi
             append blank; gather()
             select (nDBF)
             skip
           enddo
           SELECT novi; use

           select (nDBF); go top
           MsgBeep("sifrarnik je prenesen u clipboard ")

        case izbor2 == 2

           // sifrarnik <- sif0

           nDBF:=select()
           nP2:=AT("\SIF",SIFPATH)         // c:\sigma\sif
           cPath:=left(SIFPATH,nP2) +"SIF0\"
           cDBF:=ALIAS()+".DBF"   // TROBA.DBF
           // c:\sigma\sif1\trfp.dbf -> c:\sigma\sif0\trfp.dbf
           if !file(cPath+cDBF)
               MsgBeep("U clipboardu tabela "+cPath+cDBF+" ne postoji !")
               loop
           else
               // za svaki slucaj izbrisi CDX !! radi moguce korupcije
               ferase(strtran(cPath+cDbf,".DBF",".CDX"))
           endif

           USEX (cPath+cDBF, "CLIPB", .f.)
           select (nDBF)
           if reccount2() <> 0
              if pitanje(,"Sifrarnik nije prazan, izbrisati postojece stavke ?"," ")=="D"
                   zapp()
              else
                 if pitanje(,"Da li zelite na postojece stavke dodati clipboard ?","N")=="N"
                    loop
                 endif
              endif
           endif

           select CLIPB
           set order to 0; go top
           do while !eof()
             select (nDBF); Scatter(); select CLIPB
             scatter()
             select (nDBF)
             append blank; gather()
             select CLIPB
             skip
           enddo
           SELECT CLIPB; use

           select (nDBF); go top
           MsgBeep("Sifrarnik je osvjezen iz clipboarda")


      end case
     enddo
     m_x:=am_x; m_y:=am_y
     
return DE_REFRESH


