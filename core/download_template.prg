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

#define TEMPLATE_URL_BASE "https://github.com/hernad/F18_template/releases/download/"

STATIC s_cDirF18Template
STATIC s_cTemplateName
STATIC s_cUrl
STATIC s_cSHA256sum

FUNCTION download_all_templates()

   MsgO( "Download templates -> " + f18_exe_path() + "template" + " ..." )

   s_cSHA256sum := "a2faecede3dc1477161e848e8a288fb4359c767b29fac1b535d2082585a512b1"
   download_template( "f-std.odt" )

   s_cSHA256sum := "e4158099b8f42b10f9afc1d1fa7d622a56f2f05bb814776356e64beff00bb9c1"
   download_template( "f-stdk.odt" )

   s_cSHA256sum := "7661536736d43f3c678c3c11612e62952ea1e9c27c6dba953845b9349a105079"
   download_template( "f-stdm.odt" )

   s_cSHA256sum := "11db1d0d324024423dc153f67b19e1495fddfe5900740458c98b5bdc52f01e3f"
   download_template( "fin_bbl.odt" )

   s_cSHA256sum := "623667ba6348dd29eeed14877d78ec990cecb4e113ab27ffb802cd2a17063dd7"
   download_template( "fin_kart_brza.odt" )

   s_cSHA256sum := "e8b5d5d57400ce8eadec3da2b1cc68816cd266a321983ba9de6a2186c5f63a3a"
   download_template( "fin_kart_svi.odt" )

   s_cSHA256sum := "b1435934623a308b0a3e2c39c018840e92a86a66ebd5f2e5daa24722c8eae0ba"
   download_template( "fin_specif.odt" )

   s_cSHA256sum := "0d6a8b1dade0e934536ff1173598e39d498ae9480f495d2fe618ff32e6ea71df"
   download_template( "ios.odt" )

   s_cSHA256sum := "6b8fa9cb492c13e3abf6d45f3bc2c262958512b1ffc8bbe5c01242894714b5c0"
   download_template( "ios_2.odt" )

   s_cSHA256sum := "b1124faac9f8e579bdc03e4bdfb39f1d002e7e6c190bf8aa79aaddc981c3f588"
   download_template( "kalk_asort_nar.odt" )

   s_cSHA256sum := "ccf6c854f27e109357678b781716f38ba58bd72f7c901e699317fc04cc5031df"
   download_template( "kalk_llm.odt" )

   s_cSHA256sum := "82a8c006e7e6349334332997fbb37e0683d1ea870ad4876a4d9904625afd8495"
   download_template( "kalk_llp.odt" )

   s_cSHA256sum := "f745ca8770ca02b9781f935ecff90e0e34aa625af26b103d5e3a3f9d5f568ca8"
   download_template( "kalk_mp.odt" )

   s_cSHA256sum := "5442e7b9d5ef0044217e04a5294f3aa15577218b45850714b4152cddb86e26ca"
   download_template( "kalk_mp_pred.odt" )

   s_cSHA256sum := "7e38d1455c0f8be2054ec688eccf1106de2ca0a2d91ac60eb3553d492d522285"
   download_template( "kalk_vp.odt" )

   s_cSHA256sum := "7623ca44a8f2a0126dbb73540943e974f2e860cf884189ea9c5c67294cd87bc4"
   download_template( "komp_01.odt" )

   s_cSHA256sum := "8e996b671e63960c9466f5326cd78d00f2aefced0537104cda8b196763ccc55c"
   download_template( "kred_spec.odt" )

   s_cSHA256sum := "bd41446955e753f0e4f1e34b9f5f70aa44fcb455167117abfdb80403d18e938e"
   download_template( "ld_aop.odt" )

   s_cSHA256sum := "c010ca96454ca0e69c09a34c6293a919124a8f25409553946014b2ca56298fee"
   download_template( "ld_aop2.odt" )

   s_cSHA256sum := "9bb6dbb630c362cb0363d1830c3408e03ba28ff82882bfe9388577f6eeb62085"
   download_template( "ld_gip.odt" )

   s_cSHA256sum := "4f3f455942d21b48221435e59750b26e8402b0357b5a50aa3b99b6796e93029d"
   download_template( "ld_js_1.odt" )

   s_cSHA256sum := "a84eae91a305489ee8098ef963c810c99b9fb80f8b38c7c05de30354116f4cb0"
   download_template( "ld_mip.odt" )

   s_cSHA256sum := "8e019f9d8a646fe5ec3b5aee9b49d0e5b147cc6c54fbdd2ee4ebefcb4e589588"
   download_template( "ld_olp.odt" )

   s_cSHA256sum := "bd415862f7188148fffda5b0be007a3d47ae60f92e9532317635cd003c3f5ff7"
   download_template( "ld_pmip.odt" )

   s_cSHA256sum := "cd3fd5ebd1ac18d4b5abda4f9cbffcf01b6bc844d5725cb02dd9cce79ba235c0"
   download_template( "mat_invent.odt" )

   s_cSHA256sum := "51ad3aa8eb08836029345a48189e9acf08da758113b4346e542cfb980997eb19"
   download_template( "nalprg.odt" )

   s_cSHA256sum := "b8be3841cea218a18fe804e34ba9aa035924ce0449095b910365e6d1c83d70e9"
   download_template( "obrlist.odt" )

   s_cSHA256sum := "56c4e769a40a99f642878d3bf2876533a5611f2629c5c4e6a14155b31e4af78f"
   download_template( "rlab1.odt" )

   s_cSHA256sum := "f7ad93b382e9fdf26cada7b9cf95314b8e5d98cf17a926ab65ab53aa07ce74d8"
   download_template( "rlab2.odt" )

   s_cSHA256sum := "5663170cf9eb34b531bec51c6a24703d72bbd1f68741bfe1508387397a967940"
   download_template( "rnal_montaza.odt" )

   s_cSHA256sum := "bed30593b51aff30920179333346e46d3a0a8b992463d88232d4391f1902d2c5"
   download_template( "specnalp.odt" )

   s_cSHA256sum := "cec90f10beff71ca9ac3f487b7d1734dca727b1953c3bb8d3683313a25b35e27"
   download_template( "kupci_pregled_dugovanja.xlsx" )

   MsgC()

   RETURN .T.



FUNCTION download_template_ld_obr_2002()

   s_cTemplateName := "ld_obr_2002.xlsx"
   s_cSHA256sum := "b7f74944d0f30e0e3eed82a67ffff0f9cef943a79dd2fdc788bc05f2a6aac228"

   RETURN download_template()


FUNCTION download_template_ld_obr_2001()

   s_cTemplateName := "ld_obr_2001.xlsx"
   s_cSHA256sum := "23721f993561d4aa178730a18bde38294b3c720733d64bb9c691e973f00165fc"  // v17

   RETURN download_template()


FUNCTION f18_exe_template_file_name( cTemplate )

   RETURN f18_exe_path() + "template" + SLASH + cTemplate


STATIC FUNCTION download_template( cTemplateName )

   IF cTemplateName != NIL
      s_cTemplateName := cTemplateName
   ENDIF

   s_cDirF18Template := f18_exe_path() + "template" + SLASH
   s_cUrl := TEMPLATE_URL_BASE + ;
      f18_template_ver() + "/" + s_cTemplateName

   IF DirChange( s_cDirF18Template ) != 0
      IF MakeDir( s_cDirF18Template ) != 0
         error_bar( "tpl", "Kreiranje dir: " + s_cDirF18Template + " neuspješno?! STOP" )
         RETURN .F.
      ENDIF
   ENDIF

//#ifndef F18_DEBUG
   IF !File( s_cDirF18Template + s_cTemplateName ) .OR. ;
         ( sha256sum( s_cDirF18Template + s_cTemplateName ) != s_cSHA256sum )

      IF !Empty( download_file( s_cUrl, s_cDirF18Template + s_cTemplateName ) )
         info_bar( "tpl", "Download " + s_cDirF18Template + s_cTemplateName )
      ELSE
         error_bar( "tpl", "Error download:" + s_cDirF18Template + s_cTemplateName + "##" + s_cUrl )
         RETURN .F.
      ENDIF
   ENDIF

   IF sha256sum( s_cDirF18Template + s_cTemplateName ) != s_cSHA256sum
      MsgBeep( "ERROR sha256sum: " + s_cDirF18Template + s_cTemplateName + "##" + s_cSHA256sum )
      RETURN .F.
   ENDIF
//#endif

   RETURN .T.
