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



STATIC FUNCTION kadev_search_data_relation()

   SELECT kdv_rmj
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO idRmj into kdv_rmj
   SELECT kdv_rj
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO idRj into kdv_rj ADDITIVE
   SELECT kdv_rjrmj
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO idRj + idrmj into kdv_rjrmj additive
   SELECT strspr
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdStrSpr into strspr ADDITIVE
   SELECT kdv_mz
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdMzSt into kdv_mz ADDITIVE
   SELECT kdv_k1
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdK1 into kdv_k1 ADDITIVE
   SELECT kdv_k2
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdK2 into kdv_k2 ADDITIVE
   SELECT kdv_zanim
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdZanim into kdv_zanim ADDITIVE
   SELECT kdv_nac
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO Idnac into kdv_nac ADDITIVE
   SELECT kdv_rrasp
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdRRasp into kdv_rrasp ADDITIVE
   SELECT kdv_cin
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdCin into kdv_cin ADDITIVE
   SELECT kdv_ves
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdVEs into kdv_ves ADDITIVE
   SELECT kdv_rjrmj
   SET ORDER TO TAG "ID"
   SELECT kadev_0
   SET RELATION TO IdRJ + IDRMJ into kdv_rjrmj additive
   SELECT kadev_0

   RETURN



FUNCTION kadev_search()

   SET EPOCH TO 1910

   kadev_o_tables()
   kadev_search_data_relation()

   SELECT kadev_0

   cPic := "@!S30"


   qqPrezime        := ;
      qqImeRod         := ;
      qqIme            := ;
      qqId             := ;
      qqDatRodj        := ;
      qqMjRodj         := ;
      qqBrLK           := ;
      qqMjSt           := ;
      qqIdMZSt         := ;
      qqUlSt           := ;
      qqBrTel1         := ;
      qqIdZanim        := ;
      qqIdStrSpr       := ;
      qqIdRj           := ;
      qqidRMJ          := ;
      qqDatURMJ        := qqDatUF := ;
      qqDatVRMJ        := ;
      qqStatus         := ;
      qqBrTel2         := ;
      qqBrTel3         := ;
      qqBrDjece        := ;
      qqidK1           := ;
      qqidK2           := ;
      qqKOp1           := ;
      qqKOp2           := ;
      qqIdPromj        := ;
      qqIdK            := ;
      qqRstE           := ;
      qqStBRst         := ;
      qqVSS1           := ;
      qqVSS2           := ;
      qqVSS3           := ;
      qqVSS4           := ;
      qqRstB           := Space( 80 )

   qqPol            := Space( 10 )
   qqStan           := ;
      qqBracSt         := ;
      qqKrv            := Space( 30 )

   qqRRasp          := ;
      qqSlVr           := ;
      qqVrSlVr         := ;
      qqSposVSl        := ;
      qqIdVES          := ;
      qqIdCin          := ;
      qqNazSekr        := Space( 80 )

   qqDatumOd        := ;
      qqDatumDo        := ;
      qqDokument       := ;
      qqOpis           := ;
      qqNadlezan       := ;
      qqIDRj1          := ;
      qqIDRMj1         := ;
      qqnAtr1          := ;
      qqnAtr2          := ;
      qqcAtr1          := ;
      qqcAtr2          := Space( 80 )

   qqBrIzvrs        := ;  // sistematizacija
   qqSSSOd          := ;
      qqSSSDo          := ;
      qqBodova         := ;
      qqSIdK1          := ;
      qqSIdK2          := Space( 80 )


   qqsort1 := "A"

   // if file(my_home() + "upit1.mem")
   // restore from upit1.mem additive
   // endif


   Box(, 22, 75 )
   SET CURSOR ON

   DO WHILE .T.

      nStrana := 1

      DO WHILE .T.

         @ m_x + 1, m_y + 1 CLEAR TO m_x + 22, m_y + 75

         IF nStrana == 1
            nR := pGET1()
         ELSEIF nStrana == 2
            nR := pGET2()
         ELSEIF nStrana == 3
            nR := pGET3()
         ELSEIF nStrana == 4
            nR := pGET4()
         ELSEIF nStrana == 5
            nR := pGET5()
         ENDIF

         IF nR == K_ESC
            EXIT
         ELSEIF nR == K_PGUP
            --nStrana
         ELSEIF nR == K_PGDN .OR. nR == K_ENTER
            ++nStrana
         ENDIF

         IF nStrana == 0
            nStrana++
         ELSEIF nStrana == 6
            EXIT
         ENDIF

      ENDDO


      IF LastKey() == K_ESC
         BoxC()
         EXIT
      ENDIF

      aUsl1 := Parsiraj(  qqPrezime,  "Prezime",  "C"  )
      aUsl2 := Parsiraj(  qqImeRod,  "ImeRod",  "C"  )
      aUsl3 := Parsiraj(  qqIme,  "Ime",  "C"  )
      aUsl4 := Parsiraj(  qqPol,  "Pol",  "C"  )
      aUsl5 := Parsiraj(  qqId,  "Id",  "C"  )
      aUsl6 := Parsiraj(  qqDatRodj,  "DatRodj",  "D"  )
      aUsl7 := Parsiraj(  qqMjRodj,  "MjRodj",  "C"  )
      aUsl8 := Parsiraj(  qqBrLK,  "BrLK",  "C"  )
      aUsl9 := Parsiraj(  qqMjSt,  "MjSt",  "C"  )
      aUsla := Parsiraj(  qqIdMZSt,  "IdMZSt",  "C"  )
      aUslb := Parsiraj(  qqUlSt,  "UlSt",  "C"  )
      aUslc := Parsiraj(  qqBrTel1,  "BrTel1",  "C"  )
      aUsld := Parsiraj(  qqIdZanim,  "IdZanim",  "C"  )
      aUsle := Parsiraj(  qqIdStrSpr,  "IdStrSpr",  "C"  )
      aUslf := Parsiraj(  qqIdRj,  "IdRj",  "C"  )
      aUslg := Parsiraj(  qqidRMJ,  "idRMJ",  "C"  )
      aUslh := Parsiraj(  qqDatURMJ,  "DatURMJ",  "D"  )
      aUslh2 := Parsiraj(  qqDatUF,  "DatUF",  "D"  )
      aUsli := Parsiraj(  qqDatVRMJ,  "DatVRMJ",  "D"  )
      aUslj := Parsiraj(  qqStatus,  "Status",  "C"  )
      aUslk := Parsiraj(  qqBrTel2,  "BrTel2",  "C"  )
      aUsll := Parsiraj(  qqBrTel3,  "BrTel3",  "C"  )
      aUslm := Parsiraj(  qqBracSt,  "BracSt",  "C"  )
      aUsln := Parsiraj(  qqBrDjece,  "BrDjece",  "N"  )
      aUslo := Parsiraj(  qqStan,  "Stan",  "C"  )
      aUslp := Parsiraj(  qqidK1,  "idK1",  "C"  )
      aUslq := Parsiraj(  qqidK2,  "idK2",  "C"  )
      aUslr := Parsiraj(  qqKOp1,  "KOp1",  "C"  )
      aUsls := Parsiraj(  qqKOp2,  "KOp2",  "C"  )
      aUslt := Parsiraj(  qqRStE,  "RadStE",  "N"  )
      aUslu := Parsiraj(  qqRStB,  "RadStB",  "N"  )
      aUslv := Parsiraj(  qqKrv,  "Krv",  "C"  )
      aUslO1 := Parsiraj( qqRRasp,   "IdRRasp", "C"  )
      aUslO2 := Parsiraj( qqSlVr,   "SlVr", "C"  )
      aUslO3 := Parsiraj( qqVrSlVr,   "VrSlVr", "N"  )
      aUslO4 := Parsiraj( qqSposVSl,   "SposVSl", "C"  )
      aUslO5 := Parsiraj( qqIdVES,   "IDVES", "C"  )
      aUslO6 := Parsiraj( qqIdCin,   "IDCin", "C"  )
      aUslO7 := Parsiraj( qqNazSekr,   "NazSekr", "C"  )

      aUslS1 := Parsiraj(  qqBrIzvrs,   "kdv_rjrmj->BrIzvrs", "N" )
      aUslS2 := Parsiraj(  qqSSSOd,   "kdv_rjrmj->IdStrSprOd", "C" )
      aUslS3 := Parsiraj(  qqSSSDo,   "kdv_rjrmj->IdStrSprDo", "C" )
      aUslS4 := Parsiraj(  qqBodova,   "kdv_rjrmj->Bodova", "N" )
      aUslS5 := Parsiraj(  qqSIdK1,   "kdv_rjrmj->idk1", "C" )
      aUslS6 := Parsiraj(  qqSIdK2,   "kdv_rjrmj->idk2", "C" )
      aUslS7 := Parsiraj(  qqStBRst,      "kdv_rjrmj->SBenefRSt", "C" )

      aUslS8 := Parsiraj(  qqVSS1,      "kdv_rjrmj->IdZanim1", "C" )
      aUslS9 := Parsiraj(  qqVSS2,      "kdv_rjrmj->IdZanim2", "C" )
      aUslSa := Parsiraj(  qqVSS3,      "kdv_rjrmj->IdZanim3", "C" )
      aUslSb := Parsiraj(  qqVSS4,      "kdv_rjrmj->IdZanim4", "C" )

      aUsl1a := Parsiraj(  qqIdPromj,  "IdPromj", "C"  )
      aUsl1b := Parsiraj( qqIdK,  "IdK","C"    )
      aUsl1c := Parsiraj( qqDatumOd,  "DatumOd","D"    )
      aUsl1d := Parsiraj( qqDatumDo,  "DatumDo","D"    )
      aUsl1e := Parsiraj( qqDokument,  "Dokument","C"    )
      aUsl1f := Parsiraj( qqOpis,  "Opis","C"    )
      aUsl1g := Parsiraj( qqNadlezan,  "Nadlezan","C"    )
      aUsl1h := Parsiraj( qqIDRj1,  "IDRj1","C"    )
      aUsl1i := Parsiraj( qqIDRMj1,  "IDRMj1","C"    )
      aUsl1j := Parsiraj( qqnAtr1,    "nAtr1","N"    )
      aUsl1k := Parsiraj( qqnAtr2,   "nAtr2","N"    )
      aUsl1l := Parsiraj( qqcAtr1,   "cAtr1","C"    )
      aUsl1m := Parsiraj( qqcAtr2,   "cAtr2","C"    )



      IF            aUsl1 ==  NIL  .OR. ;
            aUsl2 ==  NIL  .OR. ;
            aUsl3 ==  NIL  .OR. ;
            aUsl4 ==  NIL  .OR. ;
            aUsl5 ==  NIL  .OR. ;
            aUsl6 ==  NIL  .OR. ;
            aUsl7 ==  NIL  .OR. ;
            aUsl8 ==  NIL  .OR. ;
            aUsl9 ==  NIL  .OR. ;
            aUsla ==  NIL  .OR. ;
            aUslb ==  NIL  .OR. ;
            aUslc ==  NIL  .OR. ;
            aUsld ==  NIL  .OR. ;
            aUsle ==  NIL  .OR. ;
            aUslf ==  NIL  .OR. ;
            aUslg ==  NIL  .OR. ;
            aUslh ==  NIL  .OR. ;
            aUslh2 ==  NIL  .OR. ;
            aUsli ==  NIL  .OR. ;
            aUslj ==  NIL  .OR. ;
            aUslk ==  NIL  .OR. ;
            aUsll ==  NIL  .OR. ;
            aUslm ==  NIL  .OR. ;
            aUsln ==  NIL  .OR. ;
            aUslo ==  NIL  .OR. ;
            aUslp ==  NIL  .OR. ;
            aUslq ==  NIL  .OR. ;
            aUslr ==  NIL  .OR. ;
            aUsls ==  NIL  .OR. ;
            aUslt ==  NIL  .OR. ;
            aUslu ==  NIL  .OR. ;
            aUslv ==  NIL  .OR. ;
            aUslO1 == NIL  .OR. ;
            aUslO2 == NIL  .OR. ;
            aUslO3 == NIL  .OR. ;
            aUslO4 == NIL  .OR. ;
            aUslO5 == NIL  .OR. ;
            aUslO6 == NIL  .OR. ;
            aUslO7 == NIL  .OR. ;
            aUslS1 == NIL  .OR. ;
            aUslS2 == NIL  .OR. ;
            aUslS3 == NIL  .OR. ;
            aUslS4 == NIL  .OR. ;
            aUslS5 == NIL  .OR. ;
            aUslS6 == NIL  .OR. ;
            aUslS7 == NIL  .OR. ;
            aUslS8 == NIL  .OR. ;
            aUslS9 == NIL  .OR. ;
            aUslSa == NIL  .OR. ;
            aUslSb == NIL  .OR. ;
            aUsl1a ==  NIL  .OR. ;
            aUsl1b ==  NIL .OR. ;
            aUsl1c ==  NIL .OR. ;
            aUsl1d ==  NIL .OR. ;
            aUsl1e ==  NIL .OR. ;
            aUsl1f ==  NIL .OR. ;
            aUsl1g ==  NIL .OR. ;
            aUsl1h ==  NIL .OR. ;
            aUsl1i ==  NIL .OR. ;
            aUsl1j ==  NIL .OR. ;
            aUsl1k ==  NIL .OR. ;
            aUsl1l ==  NIL .OR. ;
            aUsl1m ==  NIL

         LOOP
      ELSE
         BoxC()
         EXIT
      ENDIF

   ENDDO

   IF LastKey() == K_ESC
      my_close_all_dbf()
      RETURN
   ENDIF


   bInit1 :=  {|| dbSelectArea( F_KADEV_1 ), dbSeek( kadev_0->id ) }
   bWhile1 := {|| !Eof() .AND. kadev_0->id == kadev_1->id }
   bSkip1 :=  {|| dbSkip() }
   bEnd1 :=   {|| dbSelectArea( F_KADEV_0 ) }


   cSort1 := cSort1a := "btoe(prezime+ime)"
   cSort1b := "idrj+idrmj+prezime"
   cSort1c := "idrj+prezime"
   cSort1d := "id+prezime"
   cSort1e := "idstrspr+idzanim+prezime"
   cSort1f := "id2+prezime"

   DO CASE
   CASE qqsort1 == "A"
      csort1 := csort1a
   CASE qqsort1 == "B"
      csort1 := csort1b
   CASE qqsort1 == "C"
      csort1 := csort1c
   CASE qqsort1 == "D"
      csort1 := csort1d
   CASE qqsort1 == "E"
      csort1 := csort1e
   CASE qqsort1 == "F"
      csort1 := csort1f
   ENDCASE

   aSvUsl := aUsl1a + ".and." + aUsl1b + ".and." + ;
      aUsl1c + ".and." + aUsl1d + ".and." + ;
      aUsl1e + ".and." + aUsl1f + ".and." + ;
      aUsl1g + ".and." + aUsl1h + ".and." + ;
      aUsl1i + ".and." + aUsl1j + ".and." + ;
      aUsl1k + ".and." + aUsl1l + ".and." + aUsl1m
   aSvUsl := StrTran( aSvUsl, ".t..and.", "" )

   cFilt := aUsl1 + ".and." + aUsl2 + ".and." + ;
      aUsl3 + ".and." + aUsl4 + ".and." + aUsl5 + ".and." + ;
      aUsl6 + ".and." + aUsl7 + ".and." + aUsl8 + ".and." + ;
      aUsl9 + ".and." + aUsla + ".and." + aUslb + ".and." + ;
      aUslc + ".and." + aUsld + ".and." + aUsle + ".and." + ;
      aUslf + ".and." + aUslg + ".and." + aUslh + ".and." +  aUslh2 + ".and." + ;
      aUsli + ".and." + aUslj + ".and." + aUslk + ".and." + ;
      aUsll + ".and." + aUslm + ".and." + aUsln + ".and." + ;
      aUslo + ".and." + aUslp + ".and." + aUslq + ".and." + ;
      aUslr + ".and." + aUsls + ".and." +  ;
      aUslt + ".and." + aUslu + ".and." +  aUslv + ".and." + ;
      aUslO1 + ".and." + aUslO2 + ".and." + aUslO3 + ".and." + aUslO4 + ".and." + ;
      aUslO5 + ".and." + aUslO6 + ".and." + aUslO7 + ".and." + ;
      aUslS1 + ".and." + aUslS2 + ".and." + aUslS3 + ".and." + aUslS4 + ".and." + ;
      aUslS5 + ".and." + aUslS6 + ".and." + aUSlS7 + ".and." + ;
      aUslS8 + ".and." + aUslS9 + ".and." + aUSlSa + ".and." + aUSlSb + ".and." + ;
      IF( Upper( aSvUsl ) = ".T.", ".t.", "TacnoNO(aSvUsl,bInit1,bWhile1,bSkip1,bEnd1)" )

   cFilt := StrTran( cFilt, ".t..and.", "" )

   SELECT ( F_KADEV_0 )
   GO TOP
   Box(, 2, 40 )
   nSlog := 0
   nUkupno := RECCOUNT2()
   INDEX on ( id ) TAG "1" TO "TMPKADEV_0"
   INDEX on ( id2 ) TAG "3" TO "TMPKADEV_0"
   INDEX ON &cSort1 TAG "2" TO "TMPKADEV_0" FOR &cFilt EVAL show_progress( nUkupno, cFilt )
   GO TOP
   Inkey( 0 )
   BoxC()

   nArr := F_KADEV_0

   ImeKol := {}
   AAdd( ImeKol, { PadR( "Prezime", 20 ),                {|| ( nArr )->prezime }                             } )
   AAdd( ImeKol, { PadR( "Ime Roditelja", 15 ),          {|| ( nArr )->ImeRod }                              } )
   AAdd( ImeKol, { PadR( "Ime", 15 ),                    {|| ( nArr )->Ime }                                 } )
   AAdd( ImeKol, {      "Pol",                        {|| ' ' + ( nArr )->Pol + ' ' }                         } )
   AAdd( ImeKol, { PadR( "Mat.broj-ID", 13 ),            {|| ( nArr )->Id }                                  } )
   AAdd( ImeKol, { PadR( "ID broj/2", 11 ),              {|| ( nArr )->Id2 }                                 } )
   AAdd( ImeKol, {      "Dat.Rodj",                   {|| ( nArr )->( DToC( datRodj ) ) }                     } )
   AAdd( ImeKol, { PadR( "Mjesto Rodjenja", 30 ),        {|| ( nArr )->mjRodj }                              } )
   AAdd( ImeKol, { PadR( "Broj LK", 12 ),                {|| ( nArr )->BrLk }                                } )
   AAdd( ImeKol, { PadR( "Mjesto stanovanja", 25 ),      {|| ( nArr )->MjSt }                                } )
   AAdd( ImeKol, { PadR( "Mjesna zajednica", 25 ),       {|| ( nArr )->IdMzSt + "-" + kdv_mz->naz }                  } )
   AAdd( ImeKol, { PadR( "Ulica stanovanja", 30 ),       {|| ( nArr )->UlSt }                                } )
   AAdd( ImeKol, { PadR( "Br.Tel.st", 10 ),              {|| ( nArr )->BrTel1 }                              } )
   AAdd( ImeKol, { "Zanimanje",              {|| kdv_zanim->naz }              } )
   AAdd( ImeKol, {      "Str.spr.",                   {|| PadC( ( nArr )->IdStrSpr, 8 ) }                  } )
   AAdd( ImeKol, {      "Rad.staz EF.",               {|| aRE := GMJD( ( nArr )->RadStE ), Str( aRE[ 1 ], 2 ) + "g." + Str( aRE[ 2 ], 2 ) + "m." + Str( aRE[ 3 ], 2 ) + "d." }       } )
   AAdd( ImeKol, {      "Rad.staz BF.",               {|| aRB := GMJD( ( nArr )->RadStB ), Str( aRB[ 1 ], 2 ) + "g." + Str( aRB[ 2 ], 2 ) + "m." + Str( aRB[ 3 ], 2 ) + "d." }       } )
   AAdd( ImeKol, {      "Rad.staz UK.",               {|| aRB := GMJD( ( nArr )->RadStB ), aRE := GMJD( ( nArr )->RadStE ), aRU := ADDGMJD( aRE, aRB ), Str( aRU[ 1 ], 2 ) + "g." + Str( aRU[ 2 ], 2 ) + "m." + Str( aRU[ 3 ], 2 ) + "d." }       } )
   AAdd( ImeKol, { PadR( "Radna jedinica", 25 ),         {|| kdv_rj->naz }                     } )
   AAdd( ImeKol, { PadR( "Radno mjesto", 35 ),           {|| kdv_rmj->naz }                   } )
   AAdd( ImeKol, {      "Dat.UF  ",                  {|| ( nArr )->( DToC( DatUF ) ) }                      } )
   AAdd( ImeKol, {      "Dat.URMJ",                  {|| ( nArr )->( DToC( DatURMJ ) ) }                      } )
   AAdd( ImeKol, {      "Dat.VRMJ",                  {|| ( nArr )->( DToC( DatVRMJ ) ) }                      } )
   AAdd( ImeKol, {      "Status",                     {|| PadC( ( nArr )->Status, 6 ) }                       } )
   AAdd( ImeKol, { PadR( "Br.Tel./2", 10 ),              {|| ( nArr )->BrTel2 }                               } )
   AAdd( ImeKol, { PadR( "Br.Tel./3", 10 ),             {|| ( nArr )->BrTel3 }                               } )
   AAdd( ImeKol, {      "Brac.St",                    {|| PadC( ( nArr )->BracSt, 7 ) }                       } )
   AAdd( ImeKol, {      "Br.Djece",                   {|| " " + Str( ( nArr )->BrDjece ) + Space( 5 ) }            } )
   AAdd( ImeKol, {      "Stan",                       {|| " " + ( nArr )->Stan + "  " }                        } )
   AAdd( ImeKol, {      "Krv",                        {|| ( nArr )->Krv             }                     } )
   AAdd( ImeKol, { PadR( gDodKar1, 23 ),          {|| ( nArr )->IdK1 + "-" + kdv_k1->naz }                     } )
   AAdd( ImeKol, { PadR( gDodKar2, 35 ),          {|| ( nArr )->IdK2 + "-" + kdv_k2->naz }                     } )
   AAdd( ImeKol, { PadR( "Karakt. Opis /1", 30 ),        {|| ( nArr )->KOp1 }                                 } )
   AAdd( ImeKol, { PadR( "Karakt. Opis /2", 30 ),        {|| ( nArr )->KOp2 }                                 } )
   AAdd( ImeKol, { "Br.izvrs",                        {|| Space( 3 ) + Str( kdv_rjrmj->BrIzvrs, 2 ) + Space( 3 ) }      } )
   AAdd( ImeKol, { "Bod ",                            {|| Str( kdv_rjrmj->bodova ) }                          } )
   AAdd( ImeKol, { "Tr.SS.od",           {|| PadC( kdv_rjrmj->IdStrSprOd, 8 ) }                   } )
   AAdd( ImeKol, { "Tr.SS.do",           {|| PadC( kdv_rjrmj->IdStrSprDo, 8 ) }                   } )
   AAdd( ImeKol, { "St.B.r.st",                {|| PadC( kdv_rjrmj->SBenefRst, 9 ) }                   } )
   AAdd( ImeKol, { "sistem.-K1",               {|| PadC( kdv_rjrmj->idk1, 9 ) }                         } )
   AAdd( ImeKol, { "sistem.-K2",               {|| PadC( kdv_rjrmj->idk2, 9 ) }                         } )
   AAdd( ImeKol, { "sistem.-vr.str.spr.1",     {|| Ocitaj( F_KDV_ZANIM, kdv_rjrmj->idzanim1, "naz" ) }  } )
   AAdd( ImeKol, { "sistem.-vr.str.spr.2",     {|| Ocitaj( F_KDV_ZANIM, kdv_rjrmj->idzanim2, "naz" ) }  } )
   AAdd( ImeKol, { "sistem.-vr.str.spr.3",     {|| Ocitaj( F_KDV_ZANIM, kdv_rjrmj->idzanim3, "naz" ) }  } )
   AAdd( ImeKol, { "sistem.-vr.str.spr.4",     {|| Ocitaj( F_KDV_ZANIM, kdv_rjrmj->idzanim4, "naz" ) }  } )
   AAdd( ImeKol, { "sistem. opis        ",     {|| kdv_rjrmj->opis }  } )
   Kol := {}
   ASize( Kol, Len( ImeKol ) )
   AFill( Kol, 0 )
   IzborP2( Kol, "kol_0" )

   lImaKol := .F.
   RKol := {}
   FOR i := 1 TO Len( Kol )
      IF Kol[ i ] > 0
         lImaKol := .T.
         AAdd( RKol, { Kol[ i ], ImeKol[ i, 1 ], "N", LENX( Eval( ImeKol[ i, 2 ] ) ) } )
      ENDIF
   NEXT
   IF LastKey() != K_ESC .AND. lImaKol
      ASort( RKol,,, {| x, y| x[ 1 ] < y[ 1 ] } )
      BirajPrelom()
      SELECT ( F_KADEV_0 )
      GO TOP
      my_db_edit( '', 20, 66, {|| EdK_02() }, '<Ctrl-T> Brisanje <Enter> Edit', '<Ctrl-P> Print pregled,<Ctrl-K> Print Karton,<Ctrl-A> Svi kartoni' )
      SELECT kadev_0
      SET RELATION TO
   ENDIF

   my_close_all_dbf()

   RETURN



// ----------------------------------------------------------------
// prikazuje se progres bar kod pretrage
// ----------------------------------------------------------------
STATIC FUNCTION show_progress( last_rec, filt )

   IF RecNo() <= last_rec
      @ m_x + 1, m_y + 2 SAY "Filter: " + AllTrim( Str ( RecNo() ) ) + " od " + AllTrim( Str( last_rec ) )
   ENDIF

   if &filt
      @ m_x + 2, m_y + 2 SAY "Pronasao: " + AllTrim( Str( ++nSlog ) )
   ENDIF

   RETURN .T.



FUNCTION EdK_02()

   LOCAL cBr

   // Ch:=Lastkey()

   IF Ch == K_CTRL_K
      PushWA()
      TekRec := kadev_0->( RecNo() )
      PRIVATE aRB, aRE, aRU, aVrSlVr
      Karton( {|| aVrSlVr := GMJD( ( nArr )->VrSlVr ), aRE := GMJD( ( nArr )->RadStE ), aRB := GMJD( ( nArr )->RadStB ), aRU := ADDGMJD( aRB, aRE ), kadev_0->( RecNo() ) == TekRec } )
      PopWa()
      RETURN DE_CONT
   ELSEIF Ch == K_CTRL_A
      PushWA()
      GO TOP
      PRIVATE aRB, aRE, ARu, aVrSlVr
      Karton( {|| aVrSlVr := GMJD( ( nArr )->VrSlVr ), aRE := GMJD( ( nArr )->RadStE ), aRB := GMJD( ( nArr )->RadStB ), aRU := ADDGMJD( aRB, aRE ), .T. } )
      PopWa()
      RETURN DE_CONT
   ELSEIF Ch = K_ENTER

      PushWA()
      SELECT kadev_0

      set_global_vars_from_dbf()

      IF ent_K_0()
         _rec := get_dbf_global_memvars()
         update_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )
      ENDIF

      PopWa()

      RETURN DE_REFRESH

   ELSEIF Ch = K_CTRL_T

      IF Pitanje( "p1", ( nArr )->( "Izbrisati karton: " + Trim( prezime ) + " " + Trim( ime ) + " ?" ), "N" ) == "D"
         cBr := broj
         brisi_kadrovski_karton()
         _rec := dbf_get_rec()
         delete_rec_server_and_dbf( "kadev_0", _rec, 1, "FULL" )
         SKIP -1
         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF
   ELSEIF Ch == K_CTRL_P
      PushWA()
      GO TOP
      PRIVATE aRB, aRE, aRU

      PRIVATE cdn := "N"
      IF Pitanje(, "Prikazati promjene unutar spiska ?", "N" ) == "D"
         cdn := "D"
         // dodati kolonu bez
         IF IzFMKINI( "KADEV", "SkratiPromjeneUSpisku", "N", KUMPATH ) == "D"
            cPom77PS := IzFMKINI( "PromjeneSkraceno", "Formula", 'idpromj+", "+DTOC(datumod)+"-"+DTOC(datumdo)', KUMPATH )
            nDuz77PS := Val( IzFMKINI( "PromjeneSkraceno", "Duzina", "27", KUMPATH ) )
            AAdd( ImeKol, { "P R O M J E N E",  {|| StProm2() }, .F., "P", nDuz77PS, 0  } )
         ELSE
            AAdd( ImeKol, { "P R O M J E N E",  {|| StProm() }, .F., "P", 70, 0  } )
         ENDIF
         AAdd( Kol, Len( imekol ) )
      ENDIF

      PRIVATE cDodKol := "N"
      IF Pitanje(, "Prikazati dodatnu kolonu ?", "N" ) == "D"
         c77DP1 := PadR( "POL.STR.ISPIT", 30 )
         c77DP2 := PadR( 'IF(ImaPromjenu("S2",KADEV_0->id),"DA","")', 100 )
         c77DP3 := "C"; c77DP4 := 15; c77DP5 := 0
         nObl := Select()
         O_PARAMS
         PRIVATE cSection := "2", cHistory := " ", aHistory := {}
         Params1()
         RPar( "c1", @c77DP1 ); RPar( "c2", @c77DP2 ); RPar( "c3", @c77DP3 )
         RPar( "c4", @c77DP4 ); RPar( "c5", @c77DP5 )
         c77DP2 := PadR( c77DP2, 100 )
         IF VarEdit( { { "Naziv kolone", "c77DP1", "", "", "" }, ;
               { "Formula", "c77DP2", "", "@!S50", "" }, ;
               { "Tip varijable (C/N/D/P)", "c77DP3", "c77DP3$'CNDP'", "@!", "" }, ;
               { "Sirina kolone (br.znakova)", "c77DP4", "c77DP4>0", "99", "" }, ;
               { "Ako je numericki podatak, broj decimala je", "c77DP5", "", "9", "" } }, ;
               11, 1, 19, 78, "DEFINICIJA DODATNE KOLONE", "B1" )

            cDodKol := "D"
            // dodati kolonu bez
            AAdd( ImeKol, { c77DP1,  {|| StDodKol() }, .F., c77DP3, c77DP4, c77DP5  } )
            AAdd( Kol, Len( imekol ) )
            IF Params2()
               WPar( "c1", @c77DP1 ); WPar( "c2", @c77DP2 ); WPar( "c3", @c77DP3 )
               WPar( "c4", @c77DP4 ); WPar( "c5", @c77DP5 )
            ENDIF
            SELECT params; USE
         ELSE
            cDodKol := "N"
         ENDIF
         SELECT ( nObl )
      ENDIF

      Izlaz( "Pregled evidencije na dan " + DToC( Date() ) + " godine.", "pregled",, .F. )

      IF cDN == "D"
         ASize( ImeKol, Len( imekol ) -1 )
         ASize( Kol, Len( kol ) -1 )
      ENDIF

      IF cDodKol == "D"
         ASize( ImeKol, Len( imekol ) -1 )
         ASize( Kol, Len( kol ) -1 )
      ENDIF

      kadev_o_tables()
      kadev_search_data_relation()

      PopWa()

      RETURN DE_CONT
   ELSE
      RETURN DE_CONT
   ENDIF

   RETURN

FUNCTION StDodKol()
   RETURN &( c77DP2 )

FUNCTION ImaPromjenu( cPromjena, cRadnik, lSamoInf )

   LOCAL lIma := .F., nRec

   IF lSamoInf == NIL; lSamoInf := .F. ; ENDIF
   PushWA()
   SELECT KADEV_1
   IF lSamoInf; nRec := RecNo(); ENDIF
   SEEK cRadnik
   DO WHILE !Eof() .AND. cRadnik == KADEV_1->id
      IF KADEV_1->idpromj == cPromjena
         lIma := .T.
         EXIT
      ENDIF
      SKIP 1
   ENDDO
   IF lSamoInf; GO ( nRec ); ENDIF
   PopWA()

   RETURN lIma

FUNCTION StProm()

   LOCAL cVrati := "", nOblast := Select()

   SELECT kadev_1
   SEEK kadev_0->id
   DO WHILE !Eof() .AND. kadev_0->id == kadev_1->id
      IF Tacno( aUsl1a ) .AND. Tacno( aUsl1b ) .AND. Tacno( aUsl1c ) .AND. ;
            Tacno( aUsl1d ) .AND. Tacno( aUsl1e ) .AND. Tacno( aUsl1f ) .AND. Tacno( aUsl1g ) .AND. ;
            Tacno( aUsl1h ) .AND. Tacno( aUsl1i ) .AND. Tacno( aUsl1j ) .AND. ;
            Tacno( aUsl1k ) .AND. Tacno( aUsl1l ) .AND. Tacno( aUsl1m )
         cVrati := cVrati + "Promjena:" + idpromj + " Rj-RMJ:" + idrj + "-" + idrmj + " Datum:" + DToC( datumod ) + "-" + DToC( datumdo ) + ;
            " K:" + idk + " Atributi(N1,N2,C1,C2):" + Str( nAtr1 ) + "," + Str( nAtr2 ) + "," + catr1 + "," + catr2 + ;
            " Dokument:" + dokument + "  Opis:" + opis + " " + Replicate( "�", 69 ) + " "
      ENDIF
      SKIP
   ENDDO
   SELECT ( nOblast )

   RETURN cVrati

FUNCTION StProm2()

   LOCAL cVrati := "", nOblast := Select()

   SELECT kadev_1
   SEEK kadev_0->id
   DO WHILE !Eof() .AND. kadev_0->id == kadev_1->id
      IF Tacno( aUsl1a ) .AND. Tacno( aUsl1b ) .AND. Tacno( aUsl1c ) .AND. ;
            Tacno( aUsl1d ) .AND. Tacno( aUsl1e ) .AND. Tacno( aUsl1f ) .AND. Tacno( aUsl1g ) .AND. ;
            Tacno( aUsl1h ) .AND. Tacno( aUsl1i ) .AND. Tacno( aUsl1j ) .AND. ;
            Tacno( aUsl1k ) .AND. Tacno( aUsl1l ) .AND. Tacno( aUsl1m )
         cVrati := cVrati + PadR( &cPom77PS, nDuz77PS - 1, "." ) + " "
      ENDIF
      SKIP
   ENDDO
   SELECT ( nOblast )

   RETURN cVrati

FUNCTION pGET1()

   @  m_x + 1, m_y + 2 SAY " 1. Prezime                   "    GET qqPrezime PICTURE cPic
   @  m_x + 3, m_y + 2 SAY " 2. Ime jednog roditelja      "    GET qqImeRod  PICTURE cPic
   @  m_x + 5, m_y + 2 SAY " 3. Ime "  GET qqIme     PICTURE cPic
   @  m_x + 5, Col() + 2 SAY "Pol"    GET qqPol     PICTURE "@!S5"
   @  m_x + 5, Col() + 2 SAY " Krv  "    GET qqKrv     PICTURE "@!S9"
   @  m_x + 7,m_y + 2 SAY " 4. Jedinstveni mat.broj      "    GET qqId      PICTURE cPic
   @  m_x + 9,m_y + 2 SAY " 5. Datum rodjenja            "    GET qqDatRodj PICTURE cPic
   @  m_x + 11, m_y + 2 SAY " 6. Mjesto rodjenja           "    GET qqMjRodj  PICTURE cPic
   @  m_x + 13, m_y + 2 SAY " 7. Broj Licne karte          "    GET qqBrLK    PICTURE cPic
   @  m_x + 15, m_y + 2 SAY " 8. Adresa stanovanja         "
   @  m_x + 16, m_y + 2 SAY "  a) mjesto                   "    GET qqMjSt    PICTURE cPic
   @  m_x + 17, m_y + 2 SAY "  b) mjesna zajednica         "    GET qqIdMZSt  PICTURE cPic
   @  m_x + 18, m_y + 2 SAY "  c) ulica                    "    GET qqUlSt    PICTURE cPic
   @  m_x + 19, m_y + 2 SAY "  d) broj kucnog telefona     "    GET qqBrTel1  PICTURE cPic
   @  m_x + 21, m_y + 2 SAY " 9. Zanimanje                 "    GET qqIdZanim    PICTURE cPic
   @  m_x + 22, m_y + 2 SAY "9b. Strucna sprema            "    GET qqIdStrSpr   PICTURE cPic
   READ

   RETURN LastKey()

FUNCTION pGET2()

   @  m_x + 1, m_y + 2 SAY "10. Radna jedinica RJ         "    GET qqIdRj       PICTURE cPic
   @  m_x + 2, m_y + 2 SAY "11. Radno mjesto RMJ          "    GET qqidRMJ      PICTURE cPic
   @  m_x + 3, m_y + 2 SAY "11. Rad.Staz Efekt.           "    GET qqRStE       PICTURE cPic
   @  m_x + 4, m_y + 2 SAY "11. Rad.Staz Benef.           "    GET qqRStB       PICTURE cPic
   @  m_x + 5, m_y + 2 SAY "12. Na radnom mjestu od       "    GET qqDatURMJ    PICTURE cPic
   @  m_x + 6, m_y + 2 SAY "13. Van firme od              "    GET qqDatVRMJ    PICTURE cPic
   @  m_x + 7, m_y + 2 SAY "13. Status ...............    "    GET qqStatus     PICTURE cPic
   @  m_x + 8, m_y + 2 SAY "14. broj telefona /2          "    GET qqBrTel2     PICTURE cPic
   @  m_x + 9, m_y + 2 SAY "15. broj telefona /3          "    GET qqBrTel3     PICTURE cPic

   @  m_x + 11, m_y + 2 SAY "SISTEMATIZACIJA"
   @  m_x + 12, m_y + 2 SAY "a) Broj izvrsilaca            "    GET qqBrIzvrs    PICTURE cPic
   @  m_x + 13, m_y + 2 SAY "b) Strucna sprema od          "    GET qqSSSOd      PICTURE cPic
   @  m_x + 14, m_y + 2 SAY "c) Strucna sprema do          "    GET qqSSSDo      PICTURE cPic
   @  m_x + 15, m_y + 2 SAY "d) Broj bodova                "    GET qqBodova     PICTURE cPic
   @  m_x + 16, m_y + 2 SAY "e) IDK1-karakterist. rmj /1   "    GET qqSIdK1      PICTURE cPic
   @  m_x + 17, m_y + 2 SAY "f) IDK2-karakterist. rmj /2   "    GET qqSIdK2      PICTURE cPic
   @  m_x + 18, m_y + 2 SAY "g) Stopa benef.radnog staza   "    GET qqStBRst     PICTURE cPic
   @  m_x + 19, m_y + 2 SAY "h) Vrsta strucne spreme /1    "    GET qqVSS1       PICTURE cPic
   @  m_x + 20, m_y + 2 SAY "i) Vrsta strucne spreme /2    "    GET qqVSS2       PICTURE cPic
   @  m_x + 21, m_y + 2 SAY "j) Vrsta strucne spreme /3    "    GET qqVSS3       PICTURE cPic
   @  m_x + 22, m_y + 2 SAY "k) Vrsta strucne spreme /4    "    GET qqVSS4       PICTURE cPic




   READ

   RETURN LastKey()

FUNCTION pGet3()

   @  m_x + 1, m_y + 2 SAY "16.PORODICA, OPSTI PODACI"
   @  m_x + 4, m_y + 2 SAY "  a) Bracno stanje            "    GET qqBracSt  PICTURE cPic
   @  m_x + 5, m_y + 2 SAY "  b) Broj djece               "    GET qqBrDjece PICTURE cPic
   @  m_x + 6, m_y + 2 SAY "  c) Stambene prilike         "    GET qqStan    PICTURE cPic
   @  m_x + 7, m_y + 2 SAY "  d) " + gDodKar1 + "         "    GET qqidK1    PICTURE cPic
   @  m_x + 8, m_y + 2 SAY "  e) " + gDodKar2 + "         "    GET qqidK2    PICTURE cPic
   @  m_x + 9, m_y + 2 SAY "  f) Karakt. (opisno).....    "    GET qqKOp1    PICTURE cPic
   @  m_x + 10, m_y + 2 SAY "  g) Karakt. (opisno).....    "    GET qqKOp2    PICTURE cPic

   @  m_x + 12, m_y + 2 SAY "17. ODBRANA"
   @  m_x + 14, m_y + 2 SAY "  a) Ratni raspored         # "    GET qqRRasp   PICTURE cPic
   @  m_x + 15, m_y + 2 SAY "  b) Sluzio vojni rok (D/N)   "    GET qqSlVr    PICTURE cPic
   @  m_x + 16, m_y + 2 SAY "  c) Vrijeme sluzenja v/r     "    GET qqVrSlVr  PICTURE cPic
   @  m_x + 17, m_y + 2 SAY "  d) " + IF( glBezvoj, "Pozn.rada na racun.(D/N) ", "Sposoban za voj.sl.(D/N) " )    GET qqSposVSl PICTURE cPic
   @  m_x + 18, m_y + 2 SAY "  e) " + IF( glBezVoj, "Poznavanje str.jezika ", "VES                   " ) + " # "    GET qqIdVES   PICTURE cPic
   @  m_x + 19, m_y + 2 SAY "  f) CIN                    # "    GET qqIdCin   PICTURE cPic
   @  m_x + 20, m_y + 2 SAY "  g) " + IF( glBezVoj, "Otisli bi iz firme?      ", "Naz.sekretarijata odbr.  " )    GET qqNazSekr PICTURE cPic


   READ

   RETURN LastKey()


FUNCTION pGET4()

   @  m_x + 1, m_y + 2 SAY "******* PROMJENE: *********"
   @  m_x + 3, m_y + 2 SAY "Promjena       #"                  GET qqIdPromj    PICTURE cPic
   @  m_x + 4, m_y + 2 SAY "Karakteristika  "                  GET qqIdK        PICTURE cPic
   @  m_x + 5, m_y + 2 SAY "Datum Od        "                  GET qqDatumOd    PICTURE cPic
   @  m_x + 6, m_y + 2 SAY "Datum Do        "                  GET qqDatumDo    PICTURE cPic
   @  m_x + 7, m_y + 2 SAY "Dokument        "                  GET qqDokument   PICTURE cPic
   @  m_x + 8, m_y + 2 SAY "Opis            "                  GET qqOpis       PICTURE cPic
   @  m_x + 9, m_y + 2 SAY "Nadlezan        "                  GET qqNadlezan   PICTURE cPic
   @  m_x + 10, m_y + 2 SAY "RJ             #"                  GET qqIDRj1      PICTURE cPic
   @  m_x + 11, m_y + 2 SAY "RMJ            #"                  GET qqIDRMj1     PICTURE cPic
   @  m_x + 13, m_y + 2 SAY "N.Atribut     /1"                  GET qqnAtr1      PICTURE cPic
   @  m_x + 14, m_y + 2 SAY "N.Atribut     /2"                  GET qqnAtr2      PICTURE cPic
   @  m_x + 16, m_y + 2 SAY "C.Atribut/1 (ratni raspored ili stepen str.spr.)" GET qqcAtr1 PICTURE "@!S20"
   @  m_x + 17, m_y + 2 SAY "C.Atribut/2 (zanimanje)                         " GET qqcAtr2 PICTURE "@!S20"
   READ

   RETURN LastKey()

FUNCTION pGET5()

   @  m_x + 1, m_y + 2 SAY "Nacin sortiranja:"
   @  m_x + 3, m_y + 4 SAY "A - Prezime, ImeRoditelja, Ime "
   @  m_x + 4, m_y + 4 SAY "B - RJ,RMJ, Prezime"
   @  m_x + 5, m_y + 4 SAY "C - RJ, Prezime"
   @  m_x + 6, m_y + 4 SAY "D - Maticni-ID broj, Prezime"
   @  m_x + 7, m_y + 4 SAY "E - Str.Sprema, Zanimanje, Prezime"
   @  m_x + 8, m_y + 4 SAY "F - ID2 (mat.broj 2) ..........................."   GET  qqsort1  ;
      VALID qqsort1 $ "ABCDEF"  PICTURE  "@!"
   READ

   RETURN LastKey()


// --------------------------------------------
// stampa kartona
// --------------------------------------------
FUNCTION Karton( bFor ) // nije bas bfor - vise bi odgovaralo bWhile

   LOCAL cTekst
   LOCAL nPom := 0

   // vidjeti sta je ovo ????!??????
   IniRPT()

   cImeFajla := AllTrim( IzborFajla( my_home() + "*.def" ) )

   IF Empty( cImeFajla )
      Ch := 0
      RETURN NIL
   ELSE
      cImefajla := my_home() + cImefajla
      cTekst := MemoRead( cImeFajla )
      DO WHILE .T.
         nPom := At( "#", cTekst )
         IF nPom != 0
            AAdd( aTijeloP, Blokovi( SubStr( cTekst, nPom + 1, 2 ) ) )
            cTekst := SubStr( cTekst, nPom + 3 )
         ELSE
            EXIT
         ENDIF
      ENDDO
   ENDIF

   // init detaila
   nCDet1 := 0
   AAdd( aDetInit, {|| nCDet1 := 0, PushWA(), dbSelectArea( F_KADEV_1 ), dbSeek( kadev_0->id ) } )

   // uslov detaila
   AAdd( aDetUsl, {|| id = kadev_0->id } )

   // calc detaila
   AAdd( aDetCalc, {|| nCDet1++ } )

   // for izraz
   AAdd( aDetFor, {|| Tacno( aUsl1a ) .AND. Tacno( aUsl1b ) .AND. Tacno( aUsl1c ) .AND. ;
      Tacno( aUsl1d ) .AND. Tacno( aUsl1f ) .AND. Tacno( aUsl1g ) .AND. ;
      Tacno( aUsl1h ) .AND. Tacno( aUsl1i ) .AND. Tacno( aUsl1j ) .AND. ;
      Tacno( aUsl1k ) .AND. Tacno( aUsl1l ) .AND. Tacno( aUsl1m ) ;
      } )

   // kraj detaila
   AAdd( aDetEnd, {|| PopWa() } )

   // polja detail
   AAdd( aDetP, { {|| datumOD }, {|| DatumDo }, {|| IdPromj }, ;
      {|| P_Promj( IdPromj, -2 ) }, {|| IdK }, {|| IdRj }, {|| IdRmj }, ;
      {|| nAtr1 }, {|| nAtr2 }, {|| cAtr1 }, {|| cAtr2 }, ;
      {|| Dokument }, {|| Opis }, {|| Nadlezan }, ;
      ;
      } )

   SELECT ( F_KADEV_0 )

   START PRINT RET
   IF gPrinter == "L"
      gPO_Land()
   ENDIF

   R2( cImeFajla, "PRN", bFor, 2 )

   IF gPrinter == "L"
      gPO_Port()
   ENDIF

   ENDPRINT
   SELECT ( F_KADEV_0 )

   RETURN NIL



FUNCTION Blokovi( cIndik )

   LOCAL bVrati

   DO CASE
   CASE cIndik == "01"
      bVrati := {|| ( nArr )->prezime }
   CASE cIndik == "02"
      bVrati := {|| ( nArr )->ImeRod }
   CASE cIndik == "03"
      bVrati := {|| ( nArr )->Ime }
   CASE cIndik == "04"
      bVrati := {|| ( nArr )->Pol }
   CASE cIndik == "05"
      bVrati := {|| ( nArr )->id }
   CASE cIndik == "06"
      bVrati := {|| ( nArr )->id2 }
   CASE cIndik == "07"
      bVrati := {|| ( nArr )->BrLk }
   CASE cIndik == "08"
      bVrati := {|| ( nArr )->DatRodj }
   CASE cIndik == "09"
      bVrati := {|| ( nArr )->MjRodj }
   CASE cIndik == "10"
      bVrati := {|| ( nArr )->IdNac }
   CASE cIndik == "11"
      bVrati := {||  kdv_nac->naz     }
   CASE cIndik == "12"
      bVrati := {|| ( nArr )->IDStrspr }
   CASE cIndik == "13"
      bVrati := {|| strspr->naz }
   CASE cIndik == "14"
      bVrati := {|| Str( aRE[ 1 ], 2 ) + "g." + Str( aRE[ 2 ], 2 ) + "m." + Str( aRE[ 3 ], 2 ) + "d." }
   CASE cIndik == "15"
      bVrati := {|| Str( aRB[ 1 ], 2 ) + "g." + Str( aRB[ 2 ], 2 ) + "m." + Str( aRB[ 3 ], 2 ) + "d." }
   CASE cIndik == "16"
      bVrati := {|| Str( aRU[ 1 ], 2 ) + "g." + Str( aRU[ 2 ], 2 ) + "m." + Str( aRU[ 3 ], 2 ) + "d." }
   CASE cIndik == "17"
      bVrati := {|| ( nArr )->Idzanim }
   CASE cIndik == "18"
      bVrati := {|| kdv_zanim->naz }
   CASE cIndik == "19"
      bVrati := {|| ( nArr )->idrj }
   CASE cIndik == "20"
      bVrati := {|| kdv_rj->naz }
   CASE cIndik == "21"
      bVrati := {|| ( nArr )->idrmj }
   CASE cIndik == "22"
      bVrati := {|| kdv_rmj->naz }
   CASE cIndik == "23"
      bVrati := {|| ( nArr )->datUrmj }
   CASE cIndik == "24"
      bVrati := {|| ( nArr )->datVRmj }
   CASE cIndik == "25"
      bVrati := {|| ( nArr )->mjSt }
   CASE cIndik == "26"
      bVrati := {|| ( nArr )->idMzSt }
   CASE cIndik == "27"
      bVrati := {||  kdv_mz->naz }
   CASE cIndik == "28"
      bVrati := {|| ( nArr )->UlSt }
   CASE cIndik == "29"
      bVrati := {|| ( nArr )->BrTel1 }
   CASE cIndik == "30"
      bVrati := {|| ( nArr )->BrTel2 }
   CASE cIndik == "31"
      bVrati := {|| ( nArr )->BrTel3 }
   CASE cIndik == "32"
      bVrati := {|| ( nArr )->IdK1 }
   CASE cIndik == "33"
      bVrati := {|| kdv_k1->naz }
   CASE cIndik == "34"
      bVrati := {|| ( nArr )->IdK2 }
   CASE cIndik == "35"
      bVrati := {|| kdv_k2->naz }
   CASE cIndik == "36"
      bVrati := {|| ( nArr )->kOp1 }
   CASE cIndik == "37"
      bVrati := {|| ( nArr )->kOp2 }
   CASE cIndik == "38"
      bVrati := {|| ( nArr )->Status }
   CASE cIndik == "39"
      bVrati := {|| ( nArr )->BracSt }
   CASE cIndik == "40"
      bVrati := {|| ( nArr )->Stan }
   CASE cIndik == "41"
      bVrati := {|| ( nArr )->BrDjece }
   CASE cIndik == "42"
      bVrati := {|| ( nArr )->Krv   }
   CASE cIndik == "43"
      bVrati := {|| ( nArr )->SposVSl }
   CASE cIndik == "44"
      bVrati := {|| ( nArr )->NazSekr }
   CASE cIndik == "45"
      bVrati := {|| ( nArr )->SlVr }
   CASE cIndik == "46"
      bVrati := {|| Str( aVrSlVr[ 1 ], 2 ) + "g." + Str( aVrSlVr[ 2 ], 2 ) + "m." + Str( aVrSlVr[ 3 ], 2 ) + "d." }
   CASE cIndik == "47"
      bVrati := {|| ( nArr )->IdRRasp }
   CASE cIndik == "48"
      bVrati := {|| kdv_rrasp->naz }
   CASE cIndik == "49"
      bVrati := {|| ( nArr )->IdCin }
   CASE cIndik == "50"
      bVrati := {|| kdv_cin->naz }
   CASE cIndik == "51"
      bVrati := {|| ( nArr )->IdVes }
   CASE cIndik == "52"
      bVrati := {|| kdv_ves->naz }
   CASE cIndik == "53"
      bVrati := {|| DToC( Date() ) }
   CASE cIndik == "54"
      bVrati := {|| ( nArr )->( PadC( Trim( Prezime ) + ;
         " (" + Trim( imeRod ) + ") " + Trim( ime ), 35 ) ) }
   CASE cIndik == "55"
      bVrati := {|| kdv_RJRMJ->bodova }
   CASE cIndik == "56"
      bVrati := {|| ( nArr )->datuf }
   CASE cIndik == "57"
      bVrati := {|| StrSprPP() }
   CASE cIndik == "58"
      bVrati := {|| IF( ImaPromjenu( "S2", ( nArr )->id, .T. ), "DA", "NE" ) }
   ENDCASE

   RETURN bVrati


FUNCTION TacnoNO( cIzraz, bIni, bWhile, bSkip, bEnd )

   LOCAL i, fRez := .F.
   PRIVATE cPom

   IF Upper( cizraz ) = ".T."; RETURN .T. ; ENDIF
   Eval( bIni )

   DO WHILE Eval( bWhile )
      fRez := &cIzraz
      IF fRez; RETURN .T. ; ENDIF
      Eval( bSkip )
   ENDDO

   Eval( bEnd )

   RETURN .F.



PROCEDURE BirajPrelom()

   LOCAL GetList := {}

   Box(, 23, 77 )
   @ m_x + 0, m_y + 1 SAY "IZABRALI STE KOLONE, SADA PODESITE NJIHOVU SIRINU AKO JE POTREBNO"
   @ m_x + 1, m_y + 1 SAY PadR( "KOLONA", 40, "." ) + "LOMITI..SIRINA PRELOMA"
   FOR i := 1 TO Len( RKol )
      c77 := AllTrim( Str( i ) )
      PRIVATE cPrelK&c77 := RKol[ i, 3 ], nSirK&c77 := RKol[ i, 4 ]
      @ m_x + i + 1, m_y + 1 SAY PadR( RKol[ i, 2 ], 40, "." ) GET cPrelK&c77 VALID cPrelK&c77 $ "DN" PICT "@!"
      @ m_x + i + 1, m_y + Col() + 10 GET nSirK&c77 WHEN cPrelK&c77 == "D" PICT "999"
   NEXT
   READ
   IF LastKey() != K_ESC
      FOR i := 1 TO Len( RKol )
         c77 := AllTrim( Str( i ) )
         RKol[ i, 3 ] := cPrelK&c77
         RKol[ i, 4 ] := nSirK&c77
      NEXT
   ENDIF
   BoxC()

   RETURN


// str.sprema predvi�ena pravilnikom
FUNCTION StrSprPP()

   LOCAL cV

   cV := "od " + KDV_RJRMJ->IdStrSprOd + " do " + KDV_RJRMJ->IdStrSprDo
   IF !Empty( KDV_RJRMJ->idzanim1 )
      cV += ", " + Trim( NazZanim( KDV_RJRMJ->idzanim1 ) )
   ENDIF
   IF !Empty( KDV_RJRMJ->idzanim2 )
      cV += ", " + Trim( NazZanim( KDV_RJRMJ->idzanim2 ) )
   ENDIF
   IF !Empty( KDV_RJRMJ->idzanim3 )
      cV += ", " + Trim( NazZanim( KDV_RJRMJ->idzanim3 ) )
   ENDIF
   IF !Empty( KDV_RJRMJ->idzanim4 )
      cV += ", " + Trim( NazZanim( KDV_RJRMJ->idzanim4 ) )
   ENDIF

   RETURN cV



FUNCTION NazZanim( cId )

   LOCAL nArr := Select()
   LOCAL cN := "", nRec

   SELECT KDV_ZANIM
   nRec := RecNo()
   SEEK cId
   cN := naz
   GO ( nRec )
   SELECT ( nArr )

   RETURN cN
