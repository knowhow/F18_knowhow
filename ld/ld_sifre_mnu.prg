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


FUNCTION ld_sifrarnici()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   o_ld_sif_tables()

   AAdd( _opc, "1. opći šifarnici                     " )
   AAdd( _opcexe, {|| ld_opci_sifrarnici() } )
   AAdd( _opc, "2. ostali šifrarnici" )
   AAdd( _opcexe, {|| ld_specificni_sifrarnici() } )

   f18_menu( "sif", .F., _izbor, _opc, _opcexe )

   RETURN



FUNCTION ld_opci_sifrarnici()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, lokal( "1. radnici                            " ) )
   AAdd( _opcexe, {|| P_Radn() } )
   AAdd( _opc, lokal( "5. radne jedinice" ) )
   AAdd( _opcexe, {|| P_LD_RJ() } )
   AAdd( _opc, lokal( "6. opštine" ) )
   AAdd( _opcexe, {|| P_Ops() } )
   AAdd( _opc, lokal( "9. vrste posla" ) )
   AAdd( _opcexe, {|| P_VPosla() } )
   AAdd( _opc, lokal( "B. stručne spreme" ) )
   AAdd( _opcexe, {|| P_StrSpr() } )
   AAdd( _opc, lokal( "C. kreditori" ) )
   AAdd( _opcexe, {|| P_Kred() } )
   AAdd( _opc, lokal( "F. banke" ) )
   AAdd( _opcexe, {|| P_Banke() } )
   AAdd( _opc, lokal( "G. sifk" ) )
   AAdd( _opcexe, {|| P_SifK() } )

   IF ( IsRamaGlas() )
      AAdd( _opc, lokal( "H. objekti" ) )
      AAdd( _opcexe, {|| P_fakt_objekti() } )
   ENDIF

   gLokal := AllTrim( gLokal )

   IF gLokal <> "0"
      AAdd( _opc, lokal( "L. lokalizacija" ) )
      AAdd( _opcexe, {|| P_Lokal() } )
   ENDIF

   f18_menu( "op", .F., _izbor, _opc, _opcexe )

   RETURN .T.



FUNCTION ld_specificni_sifrarnici()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. parametri obracuna                  " )
   AAdd( _opcexe, {|| P_ParObr() } )
   AAdd( _opc, "2. tipovi primanja" )
   AAdd( _opcexe, {|| P_TipPr() } )
   AAdd( _opc, "3. tipovi primanja / ostali obracuni" )
   AAdd( _opcexe, {|| P_TipPr2() } )
   AAdd( _opc, "4. porezne stope " )
   AAdd( _opcexe, {|| P_Por() } )
   AAdd( _opc, "5. doprinosi " )
   AAdd( _opcexe, {|| P_Dopr() } )
   AAdd( _opc, "6. koef.benef.rst" )
   AAdd( _opcexe, {|| P_KBenef() } )

   IF gSihtarica == "D"
      AAdd( _opc, "7. tipovi primanja u sihtarici" )
      AAdd( _opcexe, {|| P_TprSiht() } )
      AAdd( _opc, "8. norme radova u sihtarici   " )
      AAdd( _opcexe, {|| P_NorSiht() } )
   ENDIF

   IF gSihtGroup == "D"
      AAdd( _opc, "8. lista konta   " )
      AAdd( _opcexe, {|| p_konto() } )
   ENDIF

   f18_menu( "spc", .F., _izbor, _opc, _opcexe )

   RETURN



STATIC FUNCTION o_ld_sif_tables()

   O_SIFK
   O_SIFV
   O_BANKE
   O_TPRSIHT
   O_NORSIHT
   O_RADN
   O_PAROBR
   O_TIPPR
   O_LD_RJ
   O_POR
   O_DOPR
   O_STRSPR
   O_KBENEF
   O_VPOSLA
   O_OPS
   O_KRED
   O_TIPPR2

   IF ( IsRamaGlas() )
      O_FAKT_OBJEKTI
   ENDIF

   RETURN
