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

THREAD STATIC s_cF18Txt


FUNCTION f18_start_print( f_name, print_opt, document_name )

   LOCAL cMsg, nI, cLogMsg := ""

   IF print_opt == NIL
      print_opt := "V"
   ENDIF

   set_print_f_name( @f_name )
   read_printer_params()

   set_ptxt_sekvence()

   IF ( document_name == nil )
      document_name :=  gModul + '_' + DToC( Date() )
   ENDIF

   IF print_opt != "D"
      print_opt := print_dialog_box( print_opt )
   ENDIF

   IF Empty( print_opt )
      RETURN ""
   ENDIF

   set_print_codes( print_opt )

   PRIVATE GetList := {}

#ifdef F18_DEBUG_PRINT
   LOG_CALL_STACK cLogMsg
   Alert ( cLogMsg )
#endif

   MsgO( "Priprema tekst izvještaja ..." )

   LOG_CALL_STACK cLogMsg
   SetPRC( 0, 0 )
   SET CONSOLE OFF

   SET PRINTER OFF
   SET DEVICE TO PRINTER

   SET PRINTER TO ( f_name )
   SET PRINTER ON

   GpIni( document_name )

   RETURN print_opt


STATIC FUNCTION set_print_codes( print_opt )

   DO CASE

   CASE print_opt $ "E#F#G"

      gPrinter := "E"
      set_epson_print_codes()

   OTHERWISE

      gPrinter := "R"
      set_ptxt_sekvence()

   ENDCASE

   RETURN .T.


FUNCTION f18_end_print( f_name, print_opt )

   LOCAL _ret
   LOCAL _cmd := ""
   LOCAL _port := get_printer_port( print_opt )

   IF print_opt == NIL
      print_opt := "V"
   ENDIF

   f_name := get_print_f_name( f_name )

   SET DEVICE TO SCREEN
   SET PRINTER OFF
   SET PRINTER TO
   SET CONSOLE ON


   Tone( 440, 2 )
   Tone( 440, 2 )

   MsgC()

   DO CASE

   CASE print_opt == "D"

   CASE print_opt == "P"

      txt_izvjestaj_podrska_email( f_name )

   CASE print_opt $ "E#F#G"

#ifdef __PLATFORM__WINDOWS
      direct_print_windows( f_name, _port )
#else
      direct_print_unix( f_name, _port )
#endif

   OTHERWISE

      _cmd := "f18_editor " + f_name
      _ret := f18_run( _cmd )

      IF _ret <> 0
         MsgBeep ( "f18_edit nije u pathu ?!##" + "cmd:" + _cmd )
      ENDIF
   END CASE

   RETURN .T.





STATIC FUNCTION get_printer_port( print_opt )

   LOCAL _port := "1"

   DO CASE
   CASE print_opt == "E"
      _port := "1"
   CASE print_opt == "F"
      _port := "2"
   CASE print_opt == "G"
      _port := "3"
   ENDCASE

   RETURN _port


STATIC FUNCTION direct_print_unix( f_name, port_number )

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
      RETURN
   ENDIF

   _cmd := "lpr -P "
   _cmd += _printer_name + " "
   _cmd += f_name

   _err := f18_run( _cmd )

   IF _err <> 0
      MsgBeep( "Greška sa direktnom štampom !" )
   ENDIF

   RETURN .T.


STATIC FUNCTION direct_print_windows( f_name, port_number )

   LOCAL _cmd
   LOCAL _err

   IF port_number == NIL
      port_number := "1"
   ENDIF

   f_name := '"' + f_name + '"'

   _cmd := "copy " + f_name + " LPT" + port_number

   _err := f18_run( _cmd )

   IF _err <> 0
      MsgBeep( "Greška sa direktnom štampom !" )
   ENDIF

   RETURN .T.


STATIC FUNCTION get_print_f_name( f_name )

   IF f_name == nil
      RETURN s_cF18Txt
   ENDIF

   RETURN f_name


STATIC FUNCTION set_print_f_name( f_name )

   LOCAL cDir, hFile, cTempFile

   IF f_name == NIL


      IF my_home() == NIL
         cDir := my_home_root()
      ELSE
         cDir := my_home()
      ENDIF

      IF ( hFile := hb_vfTempFile( @cTempFile, cDir, "F18_rpt_", ".txt" ) ) != NIL // hb_vfTempFile( @<cFileName>, [ <cDir> ], [ <cPrefix> ], [ <cExt> ], [ <nAttr> ] )
         hb_vfClose( hFile )
         f_name := cTempFile
      ELSE
         f_name := OUTF_FILE
      ENDIF

   ENDIF
   s_cF18Txt := f_name

   RETURN f_name



STATIC FUNCTION read_printer_params()

   gPStranica := fetch_metric( "print_dodatni_redovi_po_stranici", nil, 0 )

   RETURN .T.


FUNCTION GpIni( document_name )

   IF document_name == NIL .OR. gPrinter <> "R"
      document_name := ""
   ENDIF

   QQOut( gPini )

   IF !Empty( document_name )
      QQOut( "#%DOCNA#" + document_name )
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

   QQOut( "#%PIC_F#" )

   RETURN ""


FUNCTION gpCOND()

   QQOut( gpCOND )

   RETURN ""

FUNCTION gpCOND2()

   QQOut( gpCOND2 )

   RETURN ""

FUNCTION gp10CPI()

   QQOut( gP10CPI )

   RETURN ""

FUNCTION gp12CPI()

   QQOut( gP12CPI )

   RETURN ""

FUNCTION gpB_ON()

   QQOut( gPB_ON )

   RETURN ""


FUNCTION gpB_OFF()

   QQOut( gPB_OFF )

   RETURN ""

FUNCTION gpU_ON()

   QQOut( gPU_ON )

   RETURN ""

FUNCTION gpU_OFF()

   QQOut( gPU_OFF )

   RETURN ""

FUNCTION gpI_ON()

   QQOut( gPI_ON )

   RETURN ""

FUNCTION gpI_OFF()

   QQOut( gPI_OFF )

   RETURN ""

FUNCTION gpReset()

   QQOut( gPReset )

   RETURN ""

FUNCTION gpNR()

   QOut()

   RETURN ""

FUNCTION gPFF()

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

   Setpxlat()
   QQOut( gRPL_Normal )

   RETURN ""

FUNCTION gRPL_Gusto()

   Setpxlat()
   QQOut( gRPL_Gusto )

   RETURN ""

FUNCTION RPar_Printer()

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
   RPar( "r-", @gPStranica )
   RPar( "pt", @gPPTK )

   RETURN


FUNCTION WPar_Printer()

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
   WPar( "r-", gPStranica )
   WPar( "pt", gPPTK )

   RETURN



FUNCTION init_print_variables()

   PUBLIC gPIni := ""
   PUBLIC gPCond
   PUBLIC gPCond2
   PUBLIC gP10CPI
   PUBLIC gP12CPI
   PUBLIC gPB_ON
   PUBLIC gPB_OFF
   PUBLIC gPI_ON
   PUBLIC gPI_OFF
   PUBLIC gPU_ON
   PUBLIC gPU_OFF
   PUBLIC gPPort := "1"
   PUBLIC gPStranica := 0
   PUBLIC gPPTK
   PUBLIC gPO_Port
   PUBLIC gPO_Land
   PUBLIC gRPL_Normal
   PUBLIC gRPL_Gusto
   PUBLIC gPReset := ""
   PUBLIC gPFF

   RETURN



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
   gPStranica := 0
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

   RETURN


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

   RETURN
