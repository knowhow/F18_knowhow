#include "f18.ch"


FUNCTION parametri_eNabavke

    LOCAL nX := 1
    LOCAL GetList := {}

    LOCAL cIdKontoPDV := PadR( fetch_metric( "fin_enab_idkonto_pdv", NIL, "270" ), 7 )
    LOCAL cIdKontoPDVUvoz := PadR( fetch_metric( "fin_enab_idkonto_pdv_u", NIL, "271" ), 7 )
    LOCAL cIdKontoPDVAvansi := PadR( fetch_metric( "fin_enab_idkonto_pdv_a", NIL, "272" ), 7 )
    LOCAL cIdKontoPDVUslugeStranaLica := PadR( fetch_metric( "fin_enab_idkonto_pdv_ust", NIL, "273" ), 7 )
    LOCAL cIdKontoPDVPolj := PadR( fetch_metric( "fin_enab_idkonto_pdv_p", NIL, "274" ), 7 )
    LOCAL cIdKontoPDVNP := PadR( fetch_metric( "fin_enab_idkonto_pdv_np", NIL, "5559" ), 7 )
    LOCAL cNabExcludeIdvn := PadR( fetch_metric( "fin_enab_idvn_exclude", NIL, "I1,I2,IB,B1,B2,B3,PD" ), 100 )

    Box(, 10, 80 )

       @ box_x_koord() + nX++, box_y_koord() + 2 SAY "***** eIsporuke PARAMETRI *****"
       @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 "Konto PDV poslovne svrhe      " GET cIdKontoPDV VALID P_Konto(cIdKontoPDV)
       @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 "Konto PDV uvoz                " GET cIdKontoPDVUvoz VALID P_Konto(cIdKontoPDVUvoz)
       @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 "Konto PDV dati avansi         " GET cIdKontoPDVAvansi VALID P_Konto(cIdKontoPDVAvansi)
       @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 "Konto PDV usluge strana lica  " GET cIdKontoPDVUslugeStranaLica VALID P_Konto(cIdKontoPDVUslugeStranaLica)
       @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 "Konto PDV paušal poljoprivr.  " GET cIdKontoPDVPolj VALID P_Konto(cIdKontoPDVPolj)

       @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 "Konto PDV neposlovne svrhe    " GET cIdKontoPDVNP VALID P_Konto(cIdKontoPDVNP)


       @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 "FIN nalozi koji su isključuju iz generacije e-nabavki"
       @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 "(blagajna, izvodi, obračun PDV)" GET cNabExcludeIdvn PICTURE "@S35" 



       READ
    BoxC()

    IF Lastkey() == K_ESC
       RETURN .F.
    ENDIF


    set_metric( "fin_enab_idkonto_pdv", NIL, cIdKontoPDV)
    set_metric( "fin_enab_idkonto_pdv_u", NIL, cIdKontoPDVUvoz)
    set_metric( "fin_enab_idkonto_pdv_a", NIL, cIdKontoPDVAvansi)
    set_metric( "fin_enab_idkonto_pdv_ust", NIL, cIdKontoPDVUslugeStranaLica)
    set_metric( "fin_enab_idkonto_pdv_p", NIL, cIdKontoPDVPolj)
    set_metric( "fin_enab_idkonto_pdv_np", NIL, cIdKontoPDVNP )
    set_metric( "fin_enab_idvn_exclude", NIL, Trim(cNabExcludeIdvn) )



    RETURN .T.


FUNCTION get_sql_expression_exclude_idvns(cNabExcludeIdvn)
    
    LOCAL nI, nNumTokens
    LOCAL cTmp, cTmps

     nNumTokens := NumToken( cNabExcludeIdvn, "," )
     cTmps := ""
     FOR nI := 1 TO nNumTokens
       cTmp := Token( cNabExcludeIdvn, ",", nI )
       cTmps += sql_quote( cTmp )
       IF nI < nNumTokens
         cTmps += ","
       ENDIF
     NEXT

    RETURN cTmps


FUNCTION check_eNabavke()

    LOCAL cIdKontoPDV := PadR( fetch_metric( "fin_enab_idkonto_pdv", NIL, "270" ), 7 )
    LOCAL cIdKontoPDVUvoz := PadR( fetch_metric( "fin_enab_idkonto_pdv_u", NIL, "271" ), 7 )
    LOCAL cIdKontoPDVAvansi := PadR( fetch_metric( "fin_enab_idkonto_pdv_a", NIL, "272" ), 7 )
    LOCAL cIdKontoPDVUslugeStranaLica := PadR( fetch_metric( "fin_enab_idkonto_pdv_ust", NIL, "273" ), 7 )
    LOCAL cIdKontoPDVPolj := PadR( fetch_metric( "fin_enab_idkonto_pdv_p", NIL, "274" ), 7 )
    LOCAL cIdKontoPDVNP := PadR( fetch_metric( "fin_enab_idkonto_pdv_np", NIL, "5559" ), 7 )
    LOCAL cNabExcludeIdvn := TRIM( fetch_metric( "fin_enab_idvn_exclude", NIL, "I1,I2,IM,IB,B1,B2,PD" ) )
    LOCAL cSelectFields, cBrDokFinFin2, cFinNalogNalog2, cLeftJoinFin2
    LOCAL cTmps

    LOCAL dDatOd := fetch_metric( "fin_enab_dat_od", my_user(), DATE()-1 )
    LOCAL dDatDo := fetch_metric( "fin_enab_dat_do", my_user(), DATE() )
    LOCAL nX := 1
    LOCAL GetList := {}
    LOCAL cQuery, cQuery2, cQuery3, cQuery4, cQuery5, cQuery6
    

    Box(,3, 70)
       @ box_x_koord() + nX++, box_y_koord() + 2 SAY "***** eIsporuke Generacija *****"
       @ box_x_koord() + nX, box_y_koord() + 2 SAY "Za period od:" GET dDatOd
       @ box_x_koord() + nX++, col() + 2 SAY "Za period od:" GET dDatDo
       READ
    BoxC()


    IF Lastkey() == K_ESC
      RETURN .F.
    ENDIF

    set_metric( "fin_enab_dat_od", my_user(), dDatOd )
    set_metric( "fin_enab_dat_do", my_user(), dDatDo )

    cTmps := get_sql_expression_exclude_idvns(cNabExcludeIdvn)

    cSelectFields := "SELECT fin_suban.idfirma, fin_suban.idvn, fin_suban.brnal, fin_suban.rbr, fin_suban.idkonto as idkonto, sub2.idkonto as idkonto2, fin_suban.BrDok"
    cBrDokFinFin2 := "fin_suban.brdok=sub2.brdok"
    cFinNalogNalog2 := "fin_suban.idfirma=sub2.idfirma and fin_suban.idvn=sub2.idvn and fin_suban.brnal=sub2.brnal"
    cLeftJoinFin2 := " left join fmk.fin_suban sub2 on " + cFinNalogNalog2 + " and " + cBrDokFinFin2 + " and sub2.idkonto like '43%'"

    // 2700
    cQuery := cSelectFields
    cQuery += " from fmk.fin_suban "
    cQuery += cLeftJoinFin2
    cQuery += " left join fmk.partn on sub2.idpartner=partn.id"
    cQuery += " where fin_suban.idkonto like  '"  + Trim(cIdKontoPDV) + "%'"
    cQuery += " and fin_suban.datdok >= " + sql_quote(dDatOd) + " and fin_suban.datdok <= " + sql_quote(dDatDo)
    cQuery += " and not fin_suban.idvn in (" + cTmps + ")"
    cQuery += "  and (sub2.idpartner  is null or trim(sub2.idpartner) ='')"
 
    // 2710
    cQuery2 := cSelectFields
    cQuery2 += " from fmk.fin_suban "
    cQuery2 += cLeftJoinFin2
    cQuery2 += " left join fmk.partn on sub2.idpartner=partn.id"
    cQuery2 += " where fin_suban.idkonto like  '"  + Trim(cIdKontoPDVUvoz) + "%'"
    cQuery2 += " and fin_suban.datdok >= " + sql_quote(dDatOd) + " and fin_suban.datdok <= " + sql_quote(dDatDo)
    cQuery2 += " and not fin_suban.idvn in (" + cTmps + ")"
    cQuery2 += "  and (sub2.idpartner  is null or trim(sub2.idpartner) ='')"

    // 2720
    cQuery3 := cSelectFields
    cQuery3 += " from fmk.fin_suban "
    cQuery3 += cLeftJoinFin2
    cQuery3 += " left join fmk.partn on sub2.idpartner=partn.id"
    cQuery3 += " where fin_suban.idkonto like  '"  + Trim(cIdKontoPDVAvansi) + "%'"
    cQuery3 += " and fin_suban.datdok >= " + sql_quote(dDatOd) + " and fin_suban.datdok <= " + sql_quote(dDatDo)
    cQuery3 += " and not fin_suban.idvn in (" + cTmps + ")"
    cQuery3 += "  and (sub2.idpartner  is null or trim(sub2.idpartner) ='')"

    // 2730
    cQuery4 := cSelectFields
    cQuery4 += " from fmk.fin_suban "
    cQuery4 += cLeftJoinFin2
    cQuery4 += " left join fmk.partn on sub2.idpartner=partn.id"
    cQuery4 += " where fin_suban.idkonto like  '"  + Trim(cIdKontoPDVUslugeStranaLica) + "%'"
    cQuery4 += " and fin_suban.datdok >= " + sql_quote(dDatOd) + " and fin_suban.datdok <= " + sql_quote(dDatDo)
    cQuery4 += " and not fin_suban.idvn in (" + cTmps + ")"
    cQuery4 += "  and (sub2.idpartner  is null or trim(sub2.idpartner) ='')"

    // 2740
    cQuery5 := cSelectFields
    cQuery5 += " from fmk.fin_suban "
    cQuery5 += cLeftJoinFin2
    cQuery5 += " left join fmk.partn on sub2.idpartner=partn.id"
    cQuery5 += " where fin_suban.idkonto like  '"  + Trim(cIdKontoPDVPolj) + "%'"
    cQuery5 += " and fin_suban.datdok >= " + sql_quote(dDatOd) + " and fin_suban.datdok <= " + sql_quote(dDatDo)
    cQuery5 += " and not fin_suban.idvn in (" + cTmps + ")"
    cQuery5 += "  and (sub2.idpartner  is null or trim(sub2.idpartner) ='')"

    // 5559
    cQuery6 := cSelectFields
    cQuery6 += " from fmk.fin_suban "
    cQuery6 += cLeftJoinFin2
    cQuery6 += " left join fmk.partn on sub2.idpartner=partn.id"
    cQuery6 += " where fin_suban.idkonto like  '"  + Trim(cIdKontoPDVNP) + "%'"
    cQuery6 += " and fin_suban.datdok >= " + sql_quote(dDatOd) + " and fin_suban.datdok <= " + sql_quote(dDatDo)
    cQuery6 += " and not fin_suban.idvn in (" + cTmps + ")"
    cQuery6 += "  and (sub2.idpartner  is null or trim(sub2.idpartner) ='')"


    IF !use_sql( "ENAB", "(" + cQuery + ") UNION (" + cQuery2 + ") UNION (" + cQuery3 + ") UNION (" + cQuery4 + ") UNION (" + cQuery5 + ") UNION (" + cQuery6 +")" +;
                          " order by idfirma, idvn, brnal, rbr")
        RETURN .F.
    ENDIF

    nX:=1
    Box( ,15, 85)
    @ box_x_koord() + nX++, box_y_koord() + 2 SAY "****** FIN nalozi koji nemaju zadane ispravne partnere ili veze (brdok ili opis):"

    ++nX
    DO WHILE !EOF()
        @ box_x_koord() + nX++, box_y_koord() + 2 SAY enab->idfirma + "-" + enab->idvn + "-" + enab->brnal + " Rbr:" + str(enab->rbr,4) +;
                   " Konto:" + trim(enab->idkonto) + " / " + trim(enab->idkonto2)
        IF nX > 13
           Inkey(0)
           nX := 1
        ENDIF
        IF LastKey() == K_ESC
            EXIT
        ENDIF
        skip
    ENDDO
    Inkey(0)
    BoxC()

    USE
    MsgBeep("check eNabavke")
    RETURN .T.


STATIC FUNCTION create_csv( cFile )

    IF cFile == nil
        cFile := my_home() + "data.csv"
    ENDIF
     
    SET PRINTER to ( cFile )
    SET PRINTER ON
    SET CONSOLE OFF
     
    RETURN .T.

STATIC FUNCTION close_csv()

    SET PRINTER TO
    SET PRINTER OFF
    SET CONSOLE ON
     
    RETURN .T.


/*

CREATE sequence if not exists enabavke_id_seq;

CREATE TABLE if not exists public.enabavke  (
    enabavke_id  integer not null default nextval('enabavke_id_seq'),
    tip varchar(2) constraint allowed_enabavke_vrste check (tip in ('01', '02', '03', '04', '05')),
    porezni_period varchar(4),
    br_fakt varchar(100) not NULL,
    dat_fakt date not null,
    dat_fakt_prijem date,
    dob_naz varchar(100) not null,
    dob_sjediste varchar(100),
    dob_pdv varchar(12),
    dob_jib varchar(13),
    fakt_iznos_bez_pdv numeric(24,2) not null,
    fakt_iznos_sa_pdv numeric(24,2) not null,
    fakt_iznos_poljo_pausal numeric(24,2),
    fakt_iznos_pdv numeric(24,2),
    fakt_iznos_pdv_np numeric(24,2),
    fakt_iznos_pdv_np_32 numeric(24,2),
    fakt_iznos_pdv_np_33 numeric(24,2),
    fakt_iznos_pdv_np_34 numeric(24,2)
   
);
    
COMMENT ON COLUMN enabavke.tip IS '01-roba i usluge iz zemlje, 02-vlastita potrosnja vanposlovne svrhe, 03-avansna faktura dati avans,04-JCI uvoz, 05 - ostalo: fakture za primljene usluge ino itd';

ALTER SEQUENCE public.enabavke_id_seq OWNER TO "admin";
GRANT ALL ON TABLE public.enabavke TO "admin";
GRANT ALL ON TABLE public.enabavke TO xtrole;


alter table enabavke add column fin_idfirma varchar(2) not null;
alter table enabavke add column fin_idvn varchar(2) not null;
alter table enabavke add column fin_brnal varchar(8) not null;
alter table enabavke add column fin_rbr int not null;
alter table enabavke add column opis varchar(500);

DROP INDEX if exists enabavke_fin_nalog;
CREATE unique INDEX enabavke_fin_nalog ON public.enabavke USING btree (fin_idfirma, fin_idvn, fin_brnal, fin_rbr);

ALTER TABLE public.eNabavke OWNER TO "admin";
GRANT ALL ON TABLE public.eNabavke TO "admin";
GRANT ALL ON TABLE public.eNabavke TO xtrole;

*/
STATIC FUNCTION db_insert_enab( hRec )

    LOCAL cQuery := "INSERT INTO public.enabavke", oRet
    
    cQuery += "(enabavke_id, tip, porezni_period, br_fakt, dat_fakt, dat_fakt_prijem,"
    cQuery += "dob_naz,dob_sjediste, dob_pdv, dob_jib,"
    cQuery += "fakt_iznos_bez_pdv, fakt_iznos_sa_pdv, fakt_iznos_poljo_pausal, fakt_iznos_pdv, fakt_iznos_pdv_np, fakt_iznos_pdv_np_32, fakt_iznos_pdv_np_33, fakt_iznos_pdv_np_34,"
    cQuery += "opis, fin_idfirma, fin_idvn,fin_brnal,fin_rbr) "
    cQuery += "VALUES("
    cQuery += sql_quote(hRec["enabavke_id"]) + ","
    cQuery += sql_quote(hRec["tip"]) + ","
    cQuery += sql_quote(hRec["porezni_period"]) + ","
    cQuery += sql_quote(hRec["br_fakt"]) + ","
    cQuery += sql_quote(hRec["dat_fakt"]) + ","
    cQuery += sql_quote(hRec["dat_fakt_prijem"]) + ","
    cQuery += sql_quote(hRec["dob_naz"]) + ","
    cQuery += sql_quote(hRec["dob_sjediste"]) + ","
    cQuery += sql_quote(hRec["dob_pdv"]) + ","
    cQuery += sql_quote(hRec["dob_jib"]) + ","
    cQuery += sql_quote(ROUND(hRec["fakt_iznos_bez_pdv"],2)) + ","
    cQuery += sql_quote(ROUND(hRec["fakt_iznos_sa_pdv"],2)) + ","
    cQuery += sql_quote(ROUND(hRec["fakt_iznos_poljo_pausal"],2)) + ","
    cQuery += sql_quote(ROUND(hRec["fakt_iznos_pdv"],2)) + ","
    cQuery += sql_quote(ROUND(hRec["fakt_iznos_pdv_np"],2)) + ","
    cQuery += sql_quote(ROUND(hRec["fakt_iznos_pdv_np_32"],2)) + ","
    cQuery += sql_quote(ROUND(hRec["fakt_iznos_pdv_np_33"],2)) + ","
    cQuery += sql_quote(ROUND(hRec["fakt_iznos_pdv_np_34"],2)) + ","
    cQuery += sql_quote(hRec["opis"]) + ","
    cQuery += sql_quote(hRec["fin_idfirma"]) + ","
    cQuery += sql_quote(hRec["fin_idvn"]) + ","
    cQuery += sql_quote(hRec["fin_brnal"]) + ","
    cQuery += sql_quote(hRec["fin_rbr"]) + ")"

    oRet := run_sql_query(cQuery)

    IF sql_error_in_query( oRet, "INSERT" )
      RETURN .F.
    ENDIF

    RETURN .T.




STATIC FUNCTION say_number( nNumber )
    RETURN AllTRIM(TRANSFORM(nNumber, "9999999999999999999999.99"))


STATIC FUNCTION say_string( cString, nLen, lToUTF)
    LOCAL cTmp
    
    IF lToUTF == NIL
        lToUTF := .T.
    ENDIF

    // ukloniti ";" -> "/"
    cTmp := STRTRAN(cString, ";", "/")
    cTmp := PADR( cTmp, nLen )
    cTmp := TRIM( cTmp )

    if lToUTF
        cTmp := hb_StrToUTF8(cTmp)
    ENDIF

    RETURN cTmp


/*

 select get_sifk('PARTN', 'PDVB', sub2.idpartner) as pdv_broj, get_sifk('PARTN', 'IDBR', sub2.idpartner) as jib, 
        ((case when sub2.d_p='1' then 1 else -1 end) * sub2.iznosbhd - (case when fin_suban.d_p='2' then 1 else -1 end) * fin_suban.iznosbhd) * -1 as bez_pdv,
        (case when fin_suban.d_p='2' then 1 else -1 end) * fin_suban.iznosbhd * -1 as pdv, 
        (case when sub2.d_p='1' then 1 else -1 end) * sub2.iznosbhd * -1 as iznos_sa_pdv,
        fin_suban.idkonto, partn.id, partn.naz, sub2.idkonto, fin_suban.* from fmk.fin_suban

     left join fmk.fin_suban sub2 on fin_suban.idfirma=sub2.idfirma and fin_suban.idvn=sub2.idvn and fin_suban.brnal=sub2.brnal and fin_suban.brdok=sub2.brdok and sub2.idkonto like '4%'
     
     left join fmk.partn on sub2.idpartner=partn.id
      
     where fin_suban.idkonto like  '270%' and fin_suban.datdok >= '2020-10-01' and fin_suban.datdok <= '2020-10-31' 
           and not fin_suban.idvn in ('PD','IB');


*/
STATIC FUNCTION gen_enabavke_stavke(nRbr, dDatOd, dDatDo, cPorezniPeriod, cTipDokumenta, cIdKonto, cNabExcludeIdvn, lPDVNule, hUkupno )

    LOCAL cSelectFields, cBrDokFinFin2, cFinNalogNalog2, cLeftJoinFin2
    LOCAL cQuery, cTmps
    LOCAL cCSV := ";"
    LOCAL n32, n33, n34
    LOCAL cPDVBroj, cJib
    LOCAL nPDVNP, nPDVPosl
    LOCAL hRec := hb_hash()

    
    cTmps := get_sql_expression_exclude_idvns(cNabExcludeIdvn)

    cSelectFields := "SELECT get_sifk('PARTN', 'PDVB', sub2.idpartner) as pdv_broj, get_sifk('PARTN', 'IDBR', sub2.idpartner) as jib,"
    cSelectFields += "((case when sub2.d_p='1' then 1 else -1 end) * sub2.iznosbhd - (case when fin_suban.d_p='2' then 1 else -1 end) * fin_suban.iznosbhd) * -1 as bez_pdv,"
    cSelectFields += "(case when fin_suban.d_p='2' then 1 else -1 end) * fin_suban.iznosbhd * -1 as pdv,"
    cSelectFields += "(case when sub2.d_p='1' then 1 else -1 end) * sub2.iznosbhd * -1 as iznos_sa_pdv,"
    cSelectFields += "fin_suban.idkonto as idkonto, partn.id, partn.naz, partn.adresa, sub2.idkonto as idkonto2, fin_suban.idfirma, fin_suban.idvn, fin_suban.brnal, fin_suban.rbr,"
    cSelectFields += "fin_suban.brdok, fin_suban.opis, fin_suban.d_p, fin_suban.datdok, fin_suban.datval,"
    cSelectFields += "partn.id as partn_id, partn.naz as partn_naz, partn.adresa as partn_adresa, partn.ptt as partn_ptt, partn.mjesto as partn_mjesto, partn.rejon partn_rejon"
    
    cBrDokFinFin2 := "fin_suban.brdok=sub2.brdok"
    cFinNalogNalog2 := "fin_suban.idfirma=sub2.idfirma and fin_suban.idvn=sub2.idvn and fin_suban.brnal=sub2.brnal"
    cLeftJoinFin2 := " left join fmk.fin_suban sub2 on " + cFinNalogNalog2 + " and " + cBrDokFinFin2 + " and sub2.idkonto like '43%'"

    cQuery := cSelectFields
    cQuery += " from fmk.fin_suban "
    cQuery += cLeftJoinFin2
    cQuery += " left join fmk.partn on sub2.idpartner=partn.id"
    cQuery += " where fin_suban.idkonto like  '"  + Trim(cIdKonto) + "%'"
    cQuery += " and fin_suban.datdok >= " + sql_quote(dDatOd) + " and fin_suban.datdok <= " + sql_quote(dDatDo)
    cQuery += " and not fin_suban.idvn in (" + cTmps + ")"
    cQuery += "  and NOT (sub2.idpartner is null or trim(sub2.idpartner) ='')"
 
    IF !use_sql( "ENAB",  cQuery + " order by fin_suban.datdok, fin_suban.idfirma, fin_suban.idvn, fin_suban.brnal, fin_suban.rbr")
        RETURN .F.
    ENDIF

    
    
    DO WHILE !EOF()

        hRec["enabavke_id"] := nRbr
        hRec["tip"] := cTipDokumenta
        hRec["porezni_period"] := cPorezniPeriod
        hRec["br_fakt"] := enab->brdok
        hRec["dat_fakt"] := enab->datdok
        hRec["dat_fakt_prijem"] := enab->datdok
        hRec["dob_naz"] := say_string(enab->partn_naz, 100, .F.)
        hRec["dob_sjediste"] := say_string(trim(enab->partn_ptt) + " " + trim(enab->partn_mjesto) + " " + trim(enab->partn_adresa), 100, .F.)

        cPDVBroj := enab->pdv_broj 
        // uvoz
        IF cTipDokumenta == "04" .OR. lPDVNule
            cPDVBroj := REPLICATE("0",12)
        ENDIF
        hRec["dob_pdv"] := cPDVBroj
        cJib := enab->jib
        IF LEN(TRIM(cJib)) < 13
            cJib := ""
        ENDIF
        hRec["dob_jib"] := cJib


        IF cTipDokumenta == "02"
            nPDVNP := enab->pdv
            nPDVPosl := 0
        
        ELSE
            nPDVNP := 0
            nPDVPosl := enab->pdv
        ENDIF

        n32 := 0
        n33 := 0
        n34 := 0
        IF cTipDokumenta == "02" // vanposlovno
            SWITCH enab->partn_rejon
                    CASE "2" // RS
                       n34 := enab->pdv
                       EXIT
                    CASE "3" // BD
                       n33 := enab->pdv
                       EXIT
                    OTHERWISE
                       // FBiH
                       n32 :=  enab->pdv
                       EXIT     
            ENDSWITCH

        ENDIF

        hRec["fakt_iznos_bez_pdv"] := enab->bez_pdv
        hRec["fakt_iznos_sa_pdv"] := enab->iznos_sa_pdv
        hRec["fakt_iznos_poljo_pausal"] := 0

        hRec["fakt_iznos_pdv"] := nPDVPosl
        hRec["fakt_iznos_pdv_np"] := nPDVNP
        hRec["fakt_iznos_pdv_np_32"] := n32 
        hRec["fakt_iznos_pdv_np_33"] := n33
        hRec["fakt_iznos_pdv_np_34"] := n34
        hRec["fin_idfirma"] := enab->idfirma
        hRec["fin_idvn"] := enab->idvn
        hRec["fin_brnal"] := enab->brnal
        hRec["fin_rbr"] := enab->rbr
        hRec["opis"] := enab->opis
        db_insert_enab( hRec)


        // Vrsta sloga 2 = slogovi nabavki
        ? "2" + cCSV
        ?? cPorezniPeriod + cCSV
        ?? PADL(AllTrim(STR(nRbr,10,0)), 10, "0") + cCSV
        ?? cTipDokumenta + cCSV
        // 5. broj fakture ili dokumenta
        ?? say_string(enab->brdok, 100) + cCSV
        // 6. datum fakture ili dokumenta
        ?? STRTRAN(sql_quote(enab->datdok),"'","") + cCSV
        // 7. datum prijema
        ?? STRTRAN(sql_quote(enab->datdok),"'","") + cCSV
        // 8. naziv dobavljaca
        ?? say_string(enab->partn_naz, 100) + cCSV
        // Sjediste dobavljaca
        ?? say_string(trim(enab->partn_ptt) + " " + trim(enab->partn_mjesto) + " " + trim(enab->partn_adresa), 100) + cCSV


        // 10. PDV dobav
        ??  cPDVBroj + cCSV
        // 11. JIB dobav
        ?? cJib + cCSV
        // 12. bez PDV
        ?? say_number(enab->bez_pdv) + cCSV
        hUkupno["bez"] += enab->bez_pdv

        // 13. sa PDV
        ?? say_number(enab->iznos_sa_pdv) + cCSV
        hUkupno["sa_pdv"] += enab->iznos_sa_pdv

        // 14. pausalna naknada
        ?? say_number(0) + cCSV
        hUkupno["paus"] += 0


        hUkupno["np"] += nPDVNP
        hUkupno["posl"] += nPDVPosl

        // 15. ulazni pdv 
        ?? say_number(nPDVPosl + nPDVNP) + cCSV
        
        // 16. ulazni PDV koji se moze odbiti
        ?? say_number(nPDVPosl) + cCSV
 
        // 17. ulazni PDV koji se ne moze odbiti
        ?? say_number(nPDVNP) + cCSV
 
        hUkupno["np_32"] += n32
        hUkupno["np_33"] += n33
        hUkupno["np_34"] += n34

        // 17. ulazni PDV koji se ne moze odbiti, ulazi u polje 32 PDV FBiH
        ?? say_number(n32) + cCSV
        // 17. ulazni PDV koji se ne moze odbiti, ulazi u polje 33 PDV RS
        ?? say_number(n33) + cCSV
        // 17. ulazni PDV koji se ne moze odbiti, ulazi u polje 34 PDV Brcko
        ?? say_number(n34)

        hUkupno["redova"] += 1
        nRbr ++

        SKIP
    ENDDO

    USE

    RETURN .T.



/*

 -- 4321 - dobavljaci nepdv obveznici, ili fakture PDV0  4320 - ali u opisu ima PDV0 (isporukka dobrara i usluge na koje se ne obracunava pdv)
   select get_sifk('PARTN', 'PDVB', idpartner) as pdv_broj, get_sifk('PARTN', 'IDBR', idpartner) as jib,  
        (case when d_p='2' then 1 else -1 end) * iznosbhd as iznos,
        fin_suban.idkonto, partn.id, partn.naz, idkonto, fin_suban.* from fmk.fin_suban 
   left join fmk.partn on fin_suban.idpartner=partn.id
   where (trim(fin_suban.idkonto) = '4321' or (trim(fin_suban.idkonto) = '4320' and opis like '%PDV0%' )) and 
         fin_suban.datdok >= '2020-10-01' and fin_suban.datdok <= '2020-10-31' 
        and not fin_suban.idvn in ('PD','IB', 'B1', 'B2', 'B3');


Ovaj upit je bolji:

 -- 4321 - dobavljaci nepdv obveznici, ili fakture PDV0  4320 - ali u opisu ima PDV0 (isporukka dobrara i usluge na koje se ne obracunava pdv)
select get_sifk('PARTN', 'PDVB', fin_suban.idpartner) as pdv_broj, get_sifk('PARTN', 'IDBR', fin_suban.idpartner) as jib,  
        (case when fin_suban.d_p='2' then 1 else -1 end) * fin_suban.iznosbhd as iznos,
        fin_suban.idkonto, partn.id, partn.naz, fin_suban.idkonto, sub2.idkonto as idkonto2
   from fmk.fin_suban 
   left join fmk.partn on fin_suban.idpartner=partn.id
   left join fmk.fin_suban sub2 on fin_suban.brdok=sub2.brdok and fin_suban.idfirma=sub2.idfirma and fin_suban.idvn=sub2.idvn and fin_suban.brnal=sub2.brnal and (sub2.idkonto like '27%' or sub2.idkonto like '5559%')
   where trim(fin_suban.idkonto) like '432%' and 
         fin_suban.datdok >= '2020-10-01' and fin_suban.datdok <= '2020-10-31'
         and sub2.idkonto is null
        and not fin_suban.idvn in ('PD','IB', 'B1', 'B2', 'B3');

*/
STATIC FUNCTION gen_enabavke_stavke_pdv0(nRbr, dDatOd, dDatDo, cPorezniPeriod, cTipDokumenta, cPDVNPExclude, cNabExcludeIdvn, lPDVNule, hUkupno )

    LOCAL cSelectFields, cBrDokFinFin2, cFinNalogNalog2, cLeftJoinFin2
    LOCAL cQuery, cTmps
    LOCAL cCSV := ";"
    LOCAL n32, n33, n34
    LOCAL cPDVBroj, cJib
    LOCAL nPDVNP, nPDVPosl
    LOCAL hRec := hb_hash()

    
    cTmps := get_sql_expression_exclude_idvns(cNabExcludeIdvn)

    cSelectFields := "SELECT get_sifk('PARTN', 'PDVB', fin_suban.idpartner) as pdv_broj, get_sifk('PARTN', 'IDBR', fin_suban.idpartner) as jib,"
    cSelectFields += "(case when fin_suban.d_p='2' then 1 else -1 end) * fin_suban.iznosbhd as iznos,"
    cSelectFields += "fin_suban.idkonto as idkonto, partn.id, partn.naz, partn.adresa, fin_suban.idfirma, fin_suban.idvn, fin_suban.brnal,fin_suban.rbr,"
    cSelectFields += "fin_suban.brdok, fin_suban.opis, fin_suban.d_p, fin_suban.datdok, fin_suban.datval,"
    cSelectFields += "partn.id as partn_id, partn.naz as partn_naz, partn.adresa as partn_adresa, partn.ptt as partn_ptt, partn.mjesto as partn_mjesto, partn.rejon partn_rejon"
    
    cBrDokFinFin2 := "fin_suban.brdok=sub2.brdok"
    cFinNalogNalog2 := "fin_suban.idfirma=sub2.idfirma and fin_suban.idvn=sub2.idvn and fin_suban.brnal=sub2.brnal"
    // ovdje fin_suban 43% konto povezujemo sa sub2.idkonto 27%/5559% i ocekujemo DA NEMA VEZE - da ne postoji uparen konto PDV-a ! 
    cLeftJoinFin2 := " left join fmk.fin_suban sub2 on " + cFinNalogNalog2 + " and " + cBrDokFinFin2 
    cLeftJoinFin2 += "  and (sub2.idkonto like '27%' or sub2.idkonto like '" + trim( cPDVNPExclude) + "%')"

    cQuery := cSelectFields
    cQuery += " from fmk.fin_suban "
    cQuery += " left join fmk.partn on fin_suban.idpartner=partn.id"
    cQuery += cLeftJoinFin2
    cQuery += " where fin_suban.datdok >= " + sql_quote(dDatOd) + " and fin_suban.datdok <= " + sql_quote(dDatDo)
    cQuery += " and not fin_suban.idvn in (" + cTmps + ")"
    cQuery += " and sub2.idkonto is null"
    cQuery += " and trim(fin_suban.idkonto) like '432%'"
    // or (trim(fin_suban.idkonto) = '4320' and opis like '%PDV0%' )) and 
 

    IF !use_sql( "ENAB",  cQuery + " order by fin_suban.datdok, fin_suban.idfirma, fin_suban.idvn, fin_suban.brnal, fin_suban.rbr")
        RETURN .F.
    ENDIF
        
    DO WHILE !EOF()


        hRec["enabavke_id"] := nRbr
        hRec["tip"] := cTipDokumenta
        hRec["porezni_period"] := cPorezniPeriod
        hRec["br_fakt"] := enab->brdok
        hRec["dat_fakt"] := enab->datdok
        hRec["dat_fakt_prijem"] := enab->datdok
        hRec["dob_naz"] := say_string(enab->partn_naz, 100, .F.)
        hRec["dob_sjediste"] := say_string(trim(enab->partn_ptt) + " " + trim(enab->partn_mjesto) + " " + trim(enab->partn_adresa), 100, .F.)

        cPDVBroj := enab->pdv_broj 
        // uvoz
        IF cTipDokumenta == "04" .OR. lPDVNule
            cPDVBroj := REPLICATE("0",12)
        ENDIF
        hRec["dob_pdv"] := cPDVBroj
        cJib := enab->jib
        IF LEN(TRIM(cJib)) < 13
            cJib := ""
        ENDIF
        hRec["dob_jib"] := cJib

        nPDVPosl := 0
        nPDVNP := 0
        n32 := 0
        n33 := 0
        n34 := 0

        hRec["fakt_iznos_bez_pdv"] := enab->iznos
        hRec["fakt_iznos_sa_pdv"] := enab->iznos
        hRec["fakt_iznos_poljo_pausal"] := 0

        hRec["fakt_iznos_pdv"] := nPDVPosl
        hRec["fakt_iznos_pdv_np"] := nPDVNP
        hRec["fakt_iznos_pdv_np_32"] := n32 
        hRec["fakt_iznos_pdv_np_33"] := n33
        hRec["fakt_iznos_pdv_np_34"] := n34
        hRec["fin_idfirma"] := enab->idfirma
        hRec["fin_idvn"] := enab->idvn
        hRec["fin_brnal"] := enab->brnal
        hRec["fin_rbr"] := enab->rbr
        hRec["opis"] := enab->opis
        db_insert_enab( hRec)

        // Vrsta sloga 2 = slogovi nabavki
        ? "2" + cCSV
        ?? cPorezniPeriod + cCSV
        ?? PADL(AllTrim(STR(nRbr, 10, 0)), 10, "0") + cCSV
        ?? cTipDokumenta + cCSV
        // 5. broj fakture ili dokumenta
        ?? say_string(enab->brdok, 100) + cCSV
        // 6. datum fakture ili dokumenta
        ?? STRTRAN(sql_quote(enab->datdok),"'","") + cCSV
        // 7. datum prijema
        ?? STRTRAN(sql_quote(enab->datdok),"'","") + cCSV
        // 8. naziv dobavljaca
        ?? say_string(enab->partn_naz, 100) + cCSV
        // Sjediste dobavljaca
        ?? say_string(trim(enab->partn_ptt) + " " + trim(enab->partn_mjesto) + " " + trim(enab->partn_adresa), 100) + cCSV

      
        // 10. PDV dobav
        ??  cPDVBroj + cCSV
        // 11. JIB dobav
        ?? cJib + cCSV
        // 12. bez PDV
        ?? say_number(enab->iznos) + cCSV
        hUkupno["bez"] += enab->iznos

        // 13. sa PDV
        ?? say_number(enab->iznos) + cCSV
        hUkupno["sa_pdv"] += enab->iznos

        // 14. pausalna naknada
        ?? say_number(0) + cCSV
        hUkupno["paus"] += 0

        
        hUkupno["np"] += nPDVNP
        hUkupno["posl"] += nPDVPosl

        // 15. ulazni pdv 
        ?? say_number(nPDVPosl + nPDVNP) + cCSV
        
        // 16. ulazni PDV koji se moze odbiti
        ?? say_number(nPDVPosl) + cCSV
 
        // 17. ulazni PDV koji se ne moze odbiti
        ?? say_number(nPDVNP) + cCSV
        
        hUkupno["np_32"] += n32
        hUkupno["np_33"] += n33
        hUkupno["np_34"] += n34

        // 17. ulazni PDV koji se ne moze odbiti, ulazi u polje 32 PDV FBiH
        ?? say_number(n32) + cCSV
        // 17. ulazni PDV koji se ne moze odbiti, ulazi u polje 33 PDV RS
        ?? say_number(n33) + cCSV
        // 17. ulazni PDV koji se ne moze odbiti, ulazi u polje 34 PDV Brcko
        ?? say_number(n34)

        hUkupno["redova"] += 1
        nRbr++

        SKIP
    ENDDO

    USE

    RETURN .T.



FUNCTION gen_eNabavke()
    
    LOCAL nX := 1 
    LOCAL cIdKontoPDV := PadR( fetch_metric( "fin_enab_idkonto_pdv", NIL, "270" ), 7 )
    LOCAL cIdKontoPDVUvoz := PadR( fetch_metric( "fin_enab_idkonto_pdv_u", NIL, "271" ), 7 )
    LOCAL cIdKontoPDVAvansi := PadR( fetch_metric( "fin_enab_idkonto_pdv_a", NIL, "272" ), 7 )
    LOCAL cIdKontoPDVUslugeStranaLica := PadR( fetch_metric( "fin_enab_idkonto_pdv_ust", NIL, "273" ), 7 )
    LOCAL cIdKontoPDVPolj := PadR( fetch_metric( "fin_enab_idkonto_pdv_p", NIL, "274" ), 7 )
    LOCAL cIdKontoPDVNP := PadR( fetch_metric( "fin_enab_idkonto_pdv_np", NIL, "5559" ), 7 )
    LOCAL cNabExcludeIdvn := TRIM( fetch_metric( "fin_enab_idvn_exclude", NIL, "IM,I1,I2,IB,B1,B2,B3,PD" ) )

    LOCAL cPDV  := fetch_metric( "fin_enab_my_pdv", NIL, PadR( "<POPUNI>", 12 ) )
    LOCAL dDatOd := fetch_metric( "fin_enab_dat_od", my_user(), DATE()-1 )
    LOCAL dDatDo := fetch_metric( "fin_enab_dat_do", my_user(), DATE() )
    LOCAL cExportFile, nFileNo
    LOCAL cCSV := ";"
    LOCAL cPorezniPeriod
    LOCAL hUkupno := hb_hash()
    LOCAL nRbr := 0
    LOCAL nRbr2
    LOCAL cBrisatiDN := "N"
    LOCAL nCnt

    LOCAL GetList := {}
    LOCAL cLokacijaExport := my_home() + "export" + SLASH, nCreate


    Box(, 6, 70 )
        @ box_x_koord() + nX++, box_y_koord() + 2 SAY8 " Vaš PDV broj:" GET cPDV
        @ box_x_koord() + nX, box_y_koord() + 2 SAY "Za period od:" GET dDatOd
        @ box_x_koord() + nX++, col() + 2 SAY "Za period od:" GET dDatDo
        READ
        nX++

        // godina: 2020 -> 20   mjesec: 01, 02, 03 ...
       cPorezniPeriod := RIGHT(AllTrim(STR(Year(dDatOd))), 2) + PADL(AllTrim(STR(Month(dDatOd))), 2, "0")

        SELECT F_TMP
        IF !use_sql( "ENAB", "select max(enabavke_id) as max from public.enabavke where porezni_period<>" + sql_quote(cPorezniPeriod))
            MsgBeep("enabavke sql tabela nedostupna?!")
            BoxC()
            RETURN .F.
        ENDIF
        nRbr := enab->max + 1
        USE
        SELECT F_TMP
        IF !use_sql( "ENAB", "select max(g_r_br) as max from fmk.epdv_kuf")
            MsgBeep("fmk.epdv_kuf sql tabela nedostupna?!")
            BoxC()
            RETURN .F.
        ENDIF
        nRbr2 := enab->max + 1
        USE
        nRbr := Round(Max(nRbr, nRbr2), 0)
        
        @ box_x_koord() + nX++, box_y_koord() + 2 SAY " brisati period " + cPorezniPeriod +" pa ponovo generisati?:" GET cBrisatiDN PICT "@!" VALID cBrisatiDN $ "DN"
        @ box_x_koord() + nX++, box_y_koord() + 2 SAY "Redni broj naredne eIsporuke:" GET nRbr PICT 99999
        READ
    BoxC()

    IF Lastkey() == K_ESC
        RETURN .F.
     ENDIF
     
    set_metric( "fin_enab_my_pdv", NIL, cPDV )
    set_metric( "fin_enab_dat_od", my_user(), dDatOd )
    set_metric( "fin_enab_dat_do", my_user(), dDatDo )


    IF DirChange( cLokacijaExport ) != 0
           nCreate := MakeDir ( cLokacijaExport )
           IF nCreate != 0
              MsgBeep( "kreiranje " + cLokacijaExport + " neuspješno ?!" )
              log_write( "dircreate err:" + cLokacijaExport, 6 )
              RETURN .F.
           ENDIF
    ENDIF

    IF cBrisatiDN == "D"
        run_sql_query("DELETE from public.enabavke where porezni_period=" + sql_quote(cPorezniPeriod))
        nCnt := table_count( "public.enabavke", "porezni_period=" + sql_quote(cPorezniPeriod))
        IF nCnt > 0
            MsgBeep("Za porezni period " + cPorezniPeriod + " postoje zapisi?!##STOP")
        RETURN .F.
        ENDIF
    ENDIF

    DirChange( cLokacijaExport )
    info_bar( "csv", "lokacija csv: " + cLokacijaExport )
    
    cExportFile := cPDV + "_"

 
    cExPortFile += cPorezniPeriod
    
    cExportFile += "_1_" 

    nFileNo := 1
    cExPortFile += PADL( AllTrim(STR(nFileNo, 2)), 2, "0")
    cExportFile += ".csv"

    info_bar( "csv", "kreiranje: " + cExportFile )

    create_csv( cExportFile )
    // slog zaglavlja
    // 1. vrsta sloga
    ?? "1" + cCSV
    // 2. PDV broj
    ?? cPDV + cCSV
    // 3. YYMM
    ?? cPorezniPeriod + cCSV
    // 4. tip datoteke - 1 Nabavke
    ?? "1" + cCSV
    // 5. redni broj datoteke
    ?? PADL( AllTrim(STR(nFileNo, 2)), 2, "0") + cCSV
    // 6. datum kreiranja YYY-MM-YY
    ?? STRTRAN(sql_quote(date()),"'","") + cCSV
    // 7. vrijeme
    ?? Time()

    hUkupno["bez"] := 0
    hUkupno["sa_pdv"] := 0
    hUkupno["paus"] := 0
    hUkupno["posl"] := 0
    hUkupno["np"] := 0
    hUkupno["np_32"] := 0
    hUkupno["np_33"] := 0
    hUkupno["np_34"] := 0
    hUkupno["redova"] := 0

    // 01 standardne nabavke
    gen_enabavke_stavke(@nRbr, dDatOd, dDatDo, cPorezniPeriod, "01", cIdKontoPDV, cNabExcludeIdvn, .F., @hUkupno)
    
    // 02 vanposlovne
    gen_enabavke_stavke(@nRbr, dDatOd, dDatDo, cPorezniPeriod, "02", cIdKontoPDVNP, cNabExcludeIdvn, .F., @hUkupno)

    // NEPDV obveznici i fakture koje ne sadrze PDV (npr postanske usluge)
    gen_enabavke_stavke_pdv0(@nRbr, dDatOd, dDatDo, cPorezniPeriod, "02", cIdKontoPDVNP, cNabExcludeIdvn, .F., @hUkupno)

    // 05 ostale
    gen_enabavke_stavke(@nRbr, dDatOd, dDatDo, cPorezniPeriod, "05", cIdKontoPDVUslugeStranaLica, cNabExcludeIdvn, .T., @hUkupno)

  
    // 1. 3 - prateći slog
    ? "3" + cCSV
    // 2. ukupan iznos faktura bez PDV
    ?? say_number( hUkupno["bez"] ) + cCSV
    // 3. ukupan iznos faktura sa PDV
    ?? say_number( hUkupno["sa_pdv"] ) + cCSV
    // 4. ukupan iznos poljop paushalne naknade
    ?? say_number( hUkupno["paus"] ) + cCSV
    // 5. ukupan iznos ulaznog pdv (sve)
    ?? say_number( hUkupno["posl"] + hUkupno["np"] ) + cCSV
    // 6. ukupan ulazni pdv koji se moze odbiti (poslovni)
    ?? say_number( hUkupno["posl"] ) + cCSV
    // 7. ukupan ulazni pdv koji se ne moze odbiti (vanposlovni)
    ?? say_number( hUkupno["np"] ) + cCSV
    // 8. ukupan PDV koji se ne moze odbiti 32 PDV prijava
    ?? say_number( hUkupno["np_32"] ) + cCSV
    // 9. ukupan PDV koji se ne moze odbiti 33 PDV prijava
    ?? say_number( hUkupno["np_33"] ) + cCSV
    // 10. ukupan PDV koji se ne moze odbiti 34 PDV prijava
    ?? say_number( hUkupno["np_34"] ) + cCSV
    // 11. ukupan broj redova (sirine 10)
    ?? AllTrim(Str(hUkupno["redova"] ))


    close_csv()
       
    DirChange( my_home() )
     
  
    f18_copy_to_desktop( cLokacijaExport, cExportFile, cExportFile )
     

    RETURN .T.
       
    


FUNCTION export_eNabavke()

    MsgBeep("export eNabavke")
    RETURN .T.


