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

MEMVAR GetList, gModul

THREAD STATIC s_cF18Txt

STATIC s_nDodatniRedoviPoStranici

FUNCTION f18_start_print( cFileName, xPrintOpt, cDocumentName )

   LOCAL cMsg, nI, cLogMsg := ""
   LOCAL cOpt
   LOCAL oPDF

   cFileName := set_print_file_name( cFileName )

   IF ( cDocumentName == NIL )
      cDocumentName :=  gModul + '_' + DToC( Date() )
   ENDIF

   IF ValType( xPrintOpt ) == "H"
      cOpt := xPrintOpt[ "tip" ]
   ELSEIF ValType( xPrintOpt ) == "C"
      cOpt := xPrintOpt
   ELSE
      cOpt := "V"
   ENDIF

   set_ptxt_sekvence()

   IF !( cOpt == "PDF" .OR. cOpt == "D" ) // pdf i direktna stampa bez dijaloga
      cOpt := print_dialog_box( cOpt )
      IF Empty( cOpt )
         RETURN ""
      ENDIF
   ENDIF

   set_print_codes( cOpt )

   PRIVATE GetList := {}

#ifdef F18_DEBUG_PRINT
   LOG_CALL_STACK cLogMsg
   Alert ( cLogMsg )
#endif

   MsgO( "Priprema " + iif( cOpt == "PDF", "PDF", "tekst" ) + " izvještaja ..." )

   LOG_CALL_STACK cLogMsg
   SetPRC( 0, 0 )
   SET CONSOLE OFF

   SET PRINTER OFF
   SET DEVICE TO PRINTER

   SET PRINTER TO ( cFileName )
   SET PRINTER ON

   IF cOpt != "PDF"
      GpIni( cDocumentName )
   ELSE
      hb_cdpSelect( "SLWIN" )
      oPDF := xPrintOpt[ "opdf" ]
      oPDF:cFileName := txt_print_file_name()
      oPDF:cHeader := cDocumentName
      IF xPrintOpt[ "layout" ] == "portrait"
         oPDF:SetType( PDF_TXT_PORTRAIT )
      ELSE
         oPDF:SetType( PDF_TXT_LANDSCAPE )
      ENDIF
      AltD()
      IF hb_HHasKey( xPrintOpt, "font_size" )
         oPDF:SetFontSize( xPrintOpt[ "font_size" ] )
      ENDIF
      oPDF:Begin()
      oPDF:PageHeader()
   ENDIF

   RETURN cOpt


STATIC FUNCTION set_print_codes( cOpt )

   DO CASE

   CASE cOpt $ "E#F#G"

      gPrinter := "E"
      set_epson_print_codes()

   OTHERWISE

      gPrinter := "R"
      set_ptxt_sekvence()

   ENDCASE

   RETURN .T.


FUNCTION f18_end_print( cFileName, xPrintOpt )

   LOCAL _ret
   LOCAL _cmd := ""
   LOCAL _port
   LOCAL cOpt
   LOCAL oPDF

   IF xPrintOpt == NIL
      cOpt := "V"
   ENDIF

   IF ValType( xPrintOpt ) == "C"
      cOpt := xPrintOpt
   ENDIF

   IF ValType( xPrintOpt ) == "H"
      cOpt := xPrintOpt[ "tip" ]
      IF cOpt == "PDF"
         oPDF := xPrintOpt[ "opdf" ]
      ENDIF
   ENDIF

   _port := get_printer_port( cOpt )
   cFileName := txt_print_file_name( cFileName )

   SET DEVICE TO SCREEN
   SET PRINTER OFF
   SET PRINTER TO
   SET CONSOLE ON

   Tone( 440, 2 )
   Tone( 440, 2 )

   MsgC()

   DO CASE

   CASE cOpt == "D"

   CASE cOpt == "P"

      txt_izvjestaj_podrska_email( cFileName )

   CASE cOpt $ "E#F#G"

#ifdef __PLATFORM__WINDOWS
      direct_print_windows( cFileName, _port )
#else
      direct_print_unix( cFileName, _port )
#endif

   CASE cOpt == "PDF"

      oPDF:End()

      oPDF := PDFClass():New()
      IF xPrintOpt[ "layout" ] == "portrait"
         oPDF:SetType( PDF_PORTRAIT )
      ELSE
         oPDF:SetType( PDF_LANDSCAPE )
      ENDIF
      IF hb_HHasKey( xPrintOpt, "left_space" )
         oPDF:SetLeftSpace( xPrintOpt[ "left_space" ] )
      ENDIF
      AltD()
      IF hb_HHasKey( xPrintOpt, "font_size" )
         oPDF:SetFontSize( xPrintOpt[ "font_size" ] )
      ENDIF
      oPDF:cFileName := StrTran( txt_print_file_name(), ".txt", ".pdf" )
      oPDF:Begin()
      oPDF:PrnToPdf( txt_print_file_name() )
      oPDF:End()

      oPDF:View()
      hb_cdpSelect( "SL852" )

   OTHERWISE

      _cmd := "f18_editor " + cFileName
      _ret := f18_run( _cmd )

      IF _ret <> 0
         MsgBeep ( "f18_edit nije u pathu ?!##" + "cmd:" + _cmd )
      ENDIF
   END CASE

   RETURN .T.


FUNCTION start_print_close_ret( xPrintOpt )

   IF Empty( f18_start_print( NIL, xPrintOpt ) )
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   RETURN .T.


FUNCTION end_print( xPrintOpt )

   RETURN f18_end_print( NIL, xPrintOpt )


STATIC FUNCTION get_printer_port( xPrintOpt )

   LOCAL _port := "1"

   DO CASE
   CASE xPrintOpt == "E"
      _port := "1"
   CASE xPrintOpt == "F"
      _port := "2"
   CASE xPrintOpt == "G"
      _port := "3"
   ENDCASE

   RETURN _port


STATIC FUNCTION direct_print_unix( cFileName, port_number )

   LOCAL _cmd
   LOCAL _printer := "epson"
   LOCAL _printer_name
   LOCAL _err

   IF port_number == NIL
      port_number := "1"
   ENDIF

   _printer_name := _printer + "_" + port_number

   _cmd := "lpq -P " + _printer_name + " | grep " + _printer_name

   _err := f18_run( _cmd )
   IF _err <> 0
      MsgBeep( "Printer " + _printer_name + " nije podešen !" )
      RETURN .F.
   ENDIF

   _cmd := "lpr -P "
   _cmd += _printer_name + " "
   _cmd += cFileName

   _err := f18_run( _cmd )

   IF _err <> 0
      MsgBeep( "Greška sa direktnom štampom !" )
   ENDIF

   RETURN .T.


STATIC FUNCTION direct_print_windows( cFileName, port_number )

   LOCAL _cmd
   LOCAL _err

   IF port_number == NIL
      port_number := "1"
   ENDIF

   cFileName := '"' + cFileName + '"'

   _cmd := "copy " + cFileName + " LPT" + port_number

   _err := f18_run( _cmd )

   IF _err <> 0
      MsgBeep( "Greška sa direktnom štampom !" )
   ENDIF

   RETURN .T.


FUNCTION txt_print_file_name( cFileName )

   IF cFileName == nil
      RETURN s_cF18Txt
   ENDIF

   RETURN cFileName


STATIC FUNCTION set_print_file_name( cFileName )

   LOCAL cDir, hFile, cTempFile

   IF cFileName == NIL

      IF my_home() == NIL
         cDir := my_home_root()
      ELSE
         cDir := my_home()
      ENDIF

      IF ( hFile := hb_vfTempFile( @cTempFile, cDir, "F18_rpt_", ".txt" ) ) != NIL // hb_vfTempFile( @<cFileName>, [ <cDir> ], [ <cPrefix> ], [ <cExt> ], [ <nAttr> ] )
         hb_vfClose( hFile )
         cFileName := cTempFile
      ELSE
         cFileName := OUTF_FILE
      ENDIF

   ENDIF
   s_cF18Txt := cFileName

   RETURN cFileName




FUNCTION GpIni( cDocumentName )

   IF cDocumentName == NIL .OR. gPrinter <> "R"
      cDocumentName := ""
   ENDIF

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF

   QQOut( gPini )

   IF !Empty( cDocumentName )
      QQOut( "#%DOCNA#" + cDocumentName )
   ENDIF

   RETURN .T.


FUNCTION gpPicH( nRows )

   LOCAL cPom

   IF nRows == nil
      nRows := 7
   ENDIF

   IF nRows > 0
      cPom := PadL( AllTrim( Str( nRows ) ), 2, "0" )
      Setpxlat()
      QQOut( "#%PH0" + cPom + "#" )
   ENDIF

   RETURN ""


FUNCTION gpPicF()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( "#%PIC_F#" )

   RETURN ""


FUNCTION gpCOND()

altd()
   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gpCOND )

   RETURN ""

FUNCTION gpCOND2()

altd()
   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gpCOND2 )

   RETURN ""

FUNCTION gp10CPI()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gP10CPI )

   RETURN ""

FUNCTION gp12CPI()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gP12CPI )

   RETURN ""

FUNCTION gpB_ON()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gPB_ON )

   RETURN ""


FUNCTION gpB_OFF()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gPB_OFF )

   RETURN ""

FUNCTION gpU_ON()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gPU_ON )

   RETURN ""

FUNCTION gpU_OFF()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gPU_OFF )

   RETURN ""

FUNCTION gpI_ON()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gPI_ON )

   RETURN ""

FUNCTION gpI_OFF()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gPI_OFF )

   RETURN ""

FUNCTION gpReset()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gPReset )

   RETURN ""

FUNCTION gpNR()

   QOut()

   RETURN ""

FUNCTION gPFF()

   IF !is_legacy_ptxt()
      ?E "FF ne koristiti u PDF izvjestajima"
      RETURN .F.
   ENDIF
   QQOut( hb_eol() + gPFF )
   SetPRC( 0, 0 )

   RETURN ""

FUNCTION gpO_Port()

   QQOut( gPO_Port )

   RETURN ""

FUNCTION gpO_Land()

   QQOut( gPO_Land )

   RETURN ""

FUNCTION gRPL_Normal()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gRPL_Normal )

   RETURN ""

FUNCTION gRPL_Gusto()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   QQOut( gRPL_Gusto )

   RETURN ""

FUNCTION RPar_Printer()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   RPAR( "01", @gPINI )
   RPAR( "02", @gPCOND )
   RPAR( "03", @gPCOND2 )
   RPAR( "04", @gP10CPI )
   RPAR( "05", @gP12CPI )
   RPAR( "06", @gPB_ON )
   RPAR( "07", @gPB_OFF )
   RPAR( "08", @gPI_ON )
   RPAR( "09", @gPI_OFF )
   RPAR( "10", @gPRESET )
   RPAR( "11", @gPFF )
   RPAR( "12", @gPU_ON )
   RPAR( "13", @gPU_OFF )
   RPAR( "14", @gPO_Port )
   RPAR( "15", @gPO_Land )
   RPAR( "16", @gRPL_Normal )
   RPAR( "17", @gRPL_Gusto )
   RPAR( "PP", @gPPort )
   IF Empty( gPPort )
      gPPort := "1"
   ENDIF
   RPar( "pt", @gPPTK )

   RETURN .T.


FUNCTION WPar_Printer()

   IF !is_legacy_ptxt()
      RETURN .T.
   ENDIF
   WPAR( "01", gPINI )
   WPAR( "02", gPCOND )
   WPAR( "03", gPCOND2 )
   WPAR( "04", gP10CPI )
   WPAR( "05", gP12CPI )
   WPAR( "06", gPB_ON )
   WPAR( "07", gPB_OFF )
   WPAR( "08", gPI_ON )
   WPAR( "09", gPI_OFF )
   WPAR( "10", gPRESET )
   WPAR( "11", gPFF )
   WPAR( "12", gPU_ON )
   WPAR( "13", gPU_OFF )
   WPAR( "14", gPO_Port )
   WPAR( "15", gPO_Land )
   WPAR( "16", gRPL_Normal )
   WPAR( "17", gRPL_Gusto )
   WPAR( "PP", gPPort )
   WPar( "pt", gPPTK )

   RETURN .T.




FUNCTION set_epson_print_codes()

   gPIni := ""
   gPCond := "P"
   gPCond2 := "M"
   gP10CPI := "P"
   gP12CPI := "M"
   gPB_ON := "G"
   gPB_OFF := "H"
   gPI_ON := "4"
   gPI_OFF := "5"
   gPU_ON := "-1"
   gPU_OFF := "-0"
   gPPort := "1"
   gPPTK := "  "
   gPO_Port := ""
   gPO_Land := ""
   gRPL_Normal := "0"
   gRPL_Gusto := "3" + Chr( 24 )
   gPReset := ""
   gPFF := Chr( 12 )

   RETURN .T.


FUNCTION InigHP()

   PUBLIC gPINI := Chr( 27 ) + "(17U(s4099T&l66F"
   PUBLIC gPCond := Chr( 27 ) + "(s4102T(s18H"
   PUBLIC gPCond2 := Chr( 27 ) + "(s4102T(s22H"
   PUBLIC gP10CPI := Chr( 27 ) + "(s4099T(s10H"
   PUBLIC gP12CPI := Chr( 27 ) + "(s4099T(s12H"
   PUBLIC gPB_ON := Chr( 27 ) + "(s3B"
   PUBLIC gPB_OFF := Chr( 27 ) + "(s0B"
   PUBLIC gPI_ON := Chr( 27 ) + "(s1S"
   PUBLIC gPI_OFF := Chr( 27 ) + "(s0S"
   PUBLIC gPU_ON := Chr( 27 ) + "&d0D"
   PUBLIC gPU_OFF := Chr( 27 ) + "&d@"
   PUBLIC gPRESET := ""
   PUBLIC gPFF := Chr( 12 )
   PUBLIC gPO_Port := "&l0O"
   PUBLIC gPO_Land := "&l1O"
   PUBLIC gRPL_Normal := "&l6D&a3L"
   PUBLIC gRPL_Gusto := "&l8D(s12H&a6L"

   RETURN .T.


FUNCTION All_GetPstr()

   gPINI       := GetPStr( gPINI   )
   gPCond      := GetPStr( gPCond  )
   gPCond2     := GetPStr( gPCond2 )
   gP10cpi     := GetPStr( gP10CPI )
   gP12cpi     := GetPStr( gP12CPI )
   gPB_ON      := GetPStr( gPB_ON   )
   gPB_OFF     := GetPStr( gPB_OFF  )
   gPI_ON      := GetPStr( gPI_ON   )
   gPI_OFF     := GetPStr( gPI_OFF  )
   gPU_ON      := GetPStr( gPU_ON   )
   gPU_OFF     := GetPStr( gPU_OFF  )
   gPRESET     := GetPStr( gPRESET )
   gPFF        := GetPStr( gPFF    )
   gPO_Port    := GetPStr( gPO_Port    )
   gPO_Land    := GetPStr( gPO_Land    )
   gRPL_Normal := GetPStr( gRPL_Normal )
   gRPL_Gusto  := GetPStr( gRPL_Gusto  )

   RETURN .T.


FUNCTION SetGParams( cs, ch, cid, cvar, cval )

   LOCAL cPosebno := "N"
   PRIVATE GetList := {}

   PushWA()

   PRIVATE cSection := cs
   PRIVATE cHistory := ch
   PRIVATE aHistory := {}

   SELECT ( F_PARAMS )
   USE
   O_PARAMS
   RPar( "p?", @cPosebno )
   SELECT params
   USE

   IF cPosebno == "D"
      SELECT ( F_GPARAMSP )
      USE
      O_GPARAMSP
   ELSE
      SELECT ( F_GPARAMS )
      USE
      O_GPARAMS
   ENDIF

   &cVar := cVal
   Wpar( cId, &cVar )
   SELECT gparams
   USE
   PopWa()

   RETURN .T.


FUNCTION dodatni_redovi_po_stranici( nSet )

   IF nSet != NIL
      set_metric( "print_dodatni_redovi_po_stranici", nil, nSet )
      s_nDodatniRedoviPoStranici := nSet
   ENDIF

   IF HB_ISNIL( s_nDodatniRedoviPoStranici )
      s_nDodatniRedoviPoStranici := fetch_metric( "print_dodatni_redovi_po_stranici", nil, 0 )
   ENDIF

   RETURN s_nDodatniRedoviPoStranici



FUNCTION page_length()

   RETURN fetch_metric( "rpt_duzina_stranice", my_user(), 60 ) + dodatni_redovi_po_stranici()
