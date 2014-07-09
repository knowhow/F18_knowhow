1.7.117  2014-07-09, vsasa

  - brisanje log tabele : stari zapisi F18_DOK_OPER
  - KALK, količinsko stanje zaliha / prodaje - korekcije
  - FIN, ažuriranje naloga lOk - bugfix
 
1.7.116  2014-07-09, vsasa

  - FIN, ažuriranje naloga, nepostojeća varijabla _ok
  - KALK, štampa izvještaja stanje po objektima - bugfix
 
1.7.115  2014-07-08, vsasa

  - FIN, ažuriranje u jednoj transakciji
 
1.7.114  2014-07-08, vsasa

  - ePDV, štampa KUF/KIF izvještaja ne prelama dobro stranice - bugfix
  - F18 fiskalne funkcije, aktiviranje, deaktiviranje - bugfix + logiranje operacije
  - F18 fiskalne funkcije, prepakivanje artikala na 100 komada samo kada je količina > 1
 
1.7.113  2014-07-07, vsasa

  - KALK, ažuriranje dokumenta u jednoj transakciji
 
1.7.112  2014-07-07, vsasa

  - FAKT, ažuriranje dokumenta u jednoj transakciji
  - ePDV, s_partner() vraća PDV broj i ID broj 

1.7.111  2014-07-07, vsasa

  - LD, specifikacija po rasponima primanja, vraćen stari izvještaj
 
1.7.110  2014-07-03, vsasa

  - RNAL, ažuriranje naloga i promjena u log-u
  - f18_lock_semaphore, f18_unlock_semaphore unutar transakcije
  - F18, logiranje verzije aplikacije kod uspješne konekcije na server
 
1.7.109  2014-07-02, vsasa

  - RNAL, log tabele i naša slova - bugfix
 
1.7.108  2014-07-02, vsasa

  - LD, setovanje minulog rada kod unosa podataka obračuna - bugfix
  - RNAL, ažuriranje naloga, lock semafora u transakciji
 
1.7.107  2014-06-27, vsasa

  - LD, specifikacija po radnim jedinicama, trijaž
  - F18, ko je zaključao semafor tabelu
 
1.7.106  2014-06-25, vsasa

  - FIN, uvedene tabele fin_komp_dug, fin_komp_pot za opciju kompenzacija
  - F18 podrška email, ispravljeno
 
1.7.105  2014-06-24, vsasa

  - FAKT, fiskalni računi obrada zaglavljivanja uslijed nedostatka pologa
 
1.7.104  2014-06-24, vsasa

  - FAKT, fiskalni računi za robu sa zaštićenom cijenom - bugfix
  - FAKT, rekalmirani računi, iznos reklamiranog računa prije štampe
 
1.7.103  2014-06-23, vsasa

  - RNAL, konfiguracija pozicije pečata, korekcija funkcije
  - FAKT, udaljena razmjena podataka, korekcija funkcija
 
1.7.102  2014-06-17, vsasa

  - Fiskalne opcije, bezgotovinski račun moguć bez podataka partnera
  - FAKT, bugfix, štampa liste dokumenata
 
1.7.101  2014-06-11, vsasa

  - ID broj, PDV broj, obrada kod fiskalnog računa, obrada kod kontiranja dokumenta
  - LD, generisanje virmana nakon rekapitulacije onemogućeno ako je modul VIRM neaktivan
 
1.7.100  2014-06-10, vsasa

  - TPQuery:Refresh() izbačeno
 
1.7.99  2014-06-09, vsasa

  - razne sitne ispravke i korekcije
 
1.7.98  2014-06-06, vsasa

  - RNAL, ispravke bugova, full synchro rnal_e_att
 
1.7.97  2014-06-06, vsasa

  - RNAL, naručioci i kontakti, rnal_sifre_bez_tacke()
  - ePDV, greška kod otvaranja KIF tabele kod ažuriranja dokumenta
  - export DBF tabele i otvaranje sa LO, ispravljeno
 
1.7.96  2014-06-06, vsasa

  - RNAL, danasnji_datum() umjesto DATE()
  - FIN, bruto bilans, odt ili txt na vrhu izvještaja
  - LD, mip obrazac, kontrola datuma isplate
  - RNAL, unos artikla, odabir šeme ESC bugfix
  - fiskalne funkcije POS, pogrešan fajl odgovora handliranje, lockovanje fajla odgovora
 
1.7.95  2014-06-02, vsasa

  - LD, specifikacija plate - bugfix
  - RNAL, refactor rnal_matrica_artikla()
  - Fiskalne opcije FPRINT, automatski polog samo u Z varijanti izvještaja
  - RNAL, RAL obrada, samo dvije vrste valjka
  - FIN, bruto bilans ODT varijanta vraćena u varijanti "A" 
 
1.7.94  2014-05-28, vsasa

  - FAKT, štampa id broja + pdv broja na fakturi (txt, odt)
 
1.7.93  2014-05-28, vsasa

  - RNAL, štampanje naljepnica razbijeno na po 200 komada
  - LD, mip obrazac, validacija datuma
 
1.7.92  2014-05-27, vsasa

  - F18 backup, izbačena ERR poruka o udaljenoj lokaciji ako nije setovana
  - TOPS, ispravka artikla u pripremi računa - bugfix
  - izbačena opcija ALT+C iz šifrarnika
 
1.7.91  2014-05-27, hernad

  - fiskalne opcije refactor
 
1.7.90  2014-05-23, vsasa

  - LD, unos novog kredita, bugfix
  - FAKT, spori browse dokumenata i greška sa fiskalnim opcijama
  - FIN, kolone iznosdem i iznosbhd u browse-u
  - USE_SQL, COALESCE umjesto CASE
 
1.7.89  2014-05-23, vsasa

  - USE_SQL, casting sada gleda i obrađuje NULL polja
  - KALK, refactor funkcije VtPorezi
 
1.7.88  2014-05-22, vsasa

  - FIN, sintetički bruto bilans - bugfix
  - USE_SQL, casting ispravljen
 
1.7.87  2014-05-22, vsasa

  - RNAL, dupliciranje artikla - bugfix
 
1.7.86  2014-05-21, hernad

  - hernad ispravio opasan bug sa my_dbf_zap()
 
1.7.85  2014-05-19, vsasa

  - FAKT, fiskalni_uredjaj_model() i algoritam za provjeru fiskalnog računa
 
1.7.84  2014-05-19, vsasa, hernad

  - FIN, pravila uzrokovala bug kod unosa naloga
  - RNAL, štampanje specifikacije sa izmjenjenim količinama - bugfix
  - hernad: korekcije na common funkcijama
 
1.7.83  2014-05-16, vsasa

  - FAKT, ispitivanje stanja fiskalnih računa
 
1.7.82  2014-05-16, vsasa

  - ePDV, ulazak iz sezone, problem sa dodavanjem tarifa / 2
  - FAKT, storno računi bugfix
 
1.7.81  2014-05-15, vsasa

  - ePDV, ulazak iz sezone, problem sa dodavanjem tarifa
  - POS, korekcije i refactor koda
  - FIN, bruto bilans BBKLAS prebacio na my_use sa my_usex
 
1.7.80  2014-05-14, vsasa, hernad

  - FAKT, štampa naljepnica sa adresama
  - POS, brisanje stavke računa, izbacio pakovanje tabele
  - SYNHRO bugovi, hernad radio
 
1.7.79  2014-05-14, vsasa

  - FIN, bruto bilans sa radnim jedinicama - bugfix
 
1.7.78  2014-05-13, hernad

  - filter ALT+F bugfix
 
1.7.77  2014-05-12, vsasa

  - RNAL, specifikacija za poslovođe - bugfix
 
1.7.76  2014-05-12, vsasa, hernad

  - KALK, kontiranje dokumenta, kontrola zbira naloga - bugfix
  - Parsiraj(), bugfix 
  - FAKT, reklamni => reklamirani 
  - FAKT, povrat dokumenta bez uslova fisklanih opcija, provjera fiskalne veze
  - FAKT, fiskalni račun, provjera broja veze prilikom izdavanja računa
 
1.7.75  2014-05-09, vsasa

  - KALK, kartica magacin štampa u sezoni - bugfix 
 
1.7.74  2014-05-08, vsasa

  - ePDV, štampa pdv prijave bugfix
  - KALK, lager lista prodavnice - opis kolona u zaglavlju vraćen
  - KALK, kartica prodavnice - bugfix
  - LD, pregled obračunatih doprinosa, izvještaj izdvojen u poseban prg fajl
 
1.7.73  2014-05-07, vsasa, hernad

  - ePDV, štampa dokumenata u sezoni - bugfix
  - DBFRDD, ako postoji DBF struktura se u SQLMIX čita iz njega
 
1.7.72  2014-05-07, vsasa

  - RNAL, dodavanje novog artikla - bugfix
 
1.7.71  2014-05-07, vsasa

  - FAKT, refactor-out
  - FIN, stari izvještaji bilansa verzija B

1.7.70  2014-05-05, hernad

  - FAKT, izbačena opcija štampe fiskalnih računa za period
 
1.7.69  2014-04-29, vsasa

  - KALK, kontiranje sa menija - bugfix
 
1.7.68  2014-04-29, vsasa

  - log_level prebačen u SQL parametre
  - FAKT, brisanje stavke iz pripreme - atributi bugfix
  - FAKT, promjena rednog broja stavke - atributi bugfix
  - RNAL, kontrola unosa repromaterijala, F18 ROBA
 
1.7.67  2014-04-28, hernad

  - F18, popwa, pushwa
 
1.7.66  2014-04-25, vsasa, hernad

  - vsasa: FIN - dnevnik naloga MONTH()  
  - hernad: FAKT, menu funkcija odabira dokumenta - greška
 
1.7.65  2014-04-25, vsasa

  - FAKT, artikal kao usluga setuje polje fakt_fakt->porez - bugfix
 
1.7.64  2014-04-25, vsasa

  - KALK, promjena cijena, setovanje cijene u šifrarnik - bugfix
  - FAKT, alt+P iz pripreme vraćeno
  - KALK, gTopsDest, čitanje parametra bugfix

1.7.63  2014-04-24, hernad

  - FIN, problem subanalitičke kartice i my_use
 
1.7.62  2014-04-24, hernad

  - F18, my_use ne može otvoriti tabelu
  - LD, tabela LD_RJ se ne vraća na područje prije otvaranja
  - KALK, neka ispravka "mkonot"
 
1.7.61  2014-04-24, hernad

  - F18, my_use ne može otvoriti tabelu nakon pakovanja - bugfix
 
1.7.60  2014-04-23, vsasa

  - FIN, štampa naloga
  - ePDV, generisanje kuf/kif korekcija - otvaranje tabela
  - FAKT, lager lista - bugfix
 
1.7.59  2014-04-22, vsasa

  - FAKT/KALK, obračunski listovi poreza izbrisani 
  - čišćenje RREPLACE
  - isplanika(), isplns() izbrisani
  - log bug report error - bugfix
  - FIN, štampa naloga ESC - bugfix
  - FIN, štampa naloga sa datumom - dDatNal 
 
1.7.58  2014-04-22, hernad

  - hernad radio svašta (oko funkcija kontiranja i štampe finansijskog naloga te neke druge bugove ispravljao)
 
1.7.57  2014-04-21, vsasa

  - F18 LOG, obrnuti poredak i modifikacija prikaza
  - F18 BUG REPORT, server log se pravi bez filtera po useru i bez filtera za F18_DOK_OPER
  - RNAL, export dijalog korekcija

1.7.56  2014-04-21, hernad

  - DEBUG fakt idops, kontiranje naloga

1.7.55  2014-04-18, vsasa

  - FAKT, štampa dodatnog teksta na fakturi - bugfix
  - IOS, problem sa opcijom - bugfix
  - FAKT, pregled kartice, ROBA alias - bugfix

1.7.54  2014-04-18, vsasa

  - #33397 - po nalogu da tagiram zatečeno stanje

1.7.53  2014-04-17, hernad

  - #33388 - dbPack zloupotreba

1.7.52  2014-04-17, hernad

  - #33381 nDopr1X nije definisana

1.7.51  2014-04-17, hernad

  - exp_bank #33384 dijagnostika

1.7.50  2014-04-16, hernad

  - unicode SIFV, povrat naloga dijagnostika

1.7.49  2014-04-16, vsasa

  - masovna izmjena replace komandi sa RREPLACE komandom
  - RNAL, korekcije bug-ova
 
1.7.48  2014-04-16, vsasa

  - RJ se sada otvara sa use_sql_rj()
  - VALUTE, casting select izraza u use_sql_valute()
 
1.7.47  2014-04-15, vsasa

  - FIN, štampa bruto bilansa i nepostojeća konta
  - FIN, štampa ažuriranog dokumenta - bugfix 

1.7.46  2014-04-15, vsasa

  - FAKT, štampanje faktura, otvaranje tabela DRN, RN - bugfix 
  - semafori, dupli full sinhro - bugfix

1.7.45  2014-04-14, hernad

  - FIN, automatsko zatvaranje otvorenih stavki - bugfix 

1.7.44  2014-04-14, vsasa

  - KALK, unos dokumenata 14, 15, 94, 95, 96, PR, RN - bugfix lock required 

1.7.43  2014-04-14, vsasa

  - DEBUG: #33269 fakt_barkod => barkod

1.7.42  2014-04-14, hernad

  - DEBUG: #33258 _id_partn => _id_partner

1.7.41  2014-04-14, hernad

  - DEBUG: REOPEN_EXCLUSIVE_AND_ZAP ... RECOVER ... fali "WITH"

1.7.40  2014-04-14, hernad

  - DEBUG & REFACTOR: narudzbenice, Alias does not exists bugovi

1.7.34  2014-04-11, vsasa

  - FAKT, lager lista - bugfix 
 
1.7.33  2014-04-11, vsasa

  - korekcije poziva Gather() u mnogim dijelovima koda
  - KALK, renumercija pripreme
  - FIN, otvorene stavke lock required
 
1.7.32  2014-04-11, vsasa

  - otvaranje adresara - bugfix
 
1.7.31  2014-04-11, vsasa

  - FAKT, udaljene lokacije prenos
  - KALK, izbrisani pozivi tabela P_DOKSRC, DOKSRC
  - KALK, razmjena podataka FAKT->KALK
  - FIN, štampa suban kartice, filovanje tabele
  - KALK, ažuriranje fakt dokumenta prenos
  - razni lock required bugovi fix 

1.7.30  2014-04-10, vsasa

  - RNAL, import podataka iz CSV fajlova
  - objdbedit(), korekcija praznina
  - ePDV, snimanje pdv prijave u bazu - bugfix
  - KAM, ispravke sa LOCK REQUIRED

1.7.29  2014-04-08, vsasa

  - POS, ažuriranje zaduženja/inventure - bugfix LOCK REQUIRED 
  - VIRM, ispravka dokumenta, bugfix LOCK REQUIRED
 
1.7.28  2014-04-08, vsasa

  - MAT, otvaranje tabela SIFK/SIFV - bugfix
  - setovanje valuta, table_count() umjesto _select_all_from_table()
  - KALK, unos/ispravka dokumenta - bugfix LOCK REQUIRED 
 
1.7.27  2014-04-08, vsasa

  - POS, prenos realizacije u KALK, bugfix sa POM tabelom
 
1.7.26  2014-04-08, vsasa

  - POS, ispravke dijelova koda sa otvaranjem tabela
  - insert valuta prebačen na SQL insert
 
1.7.25  2014-04-07, vsasa

  - dosta tabela pripreme prebačeno na my_use()
  - VIRM, štampa virmana - korekcija lock required
 
1.7.24  2014-04-07, vsasa

  - bug report na email
  - PrikK1K4() ispravka funkcije, prikaz radne jedinice na uslovima izvještaja 
 
1.7.23  2014-04-04, vsasa

  - lock required i workarea not in use greške - bugfix 
  - CLOSE ALL => my_close_all_dbf()
 
1.7.22  2014-04-03, vsasa

  - ePDV, greške kod štampe dokumenata i manipulacija tabelam pripreme
  - indexi i otvaranja tabela PKONTO, VALUTE, OPS, LOKAL, itd... bugfix 
 
1.7.21  2014-04-01, vsasa

  - VIRM, generisani virmani imaju redni broj 0
  - atrib_server_to_dbf() korekcija
  - RNAL, tabela dodatnih operacija iskočila iz glavne forme
  - RNAL, odabir elementa artikla menu problem
  - FIN, bruto bilans PTXT print - bugfix 
 
1.7.20  2014-03-31, vsasa

  - FIN, otvaranje tabele KONTO i korekcija funkcije p_kontofin()
  - KALK, povrat dokumenta u pripremu - bugfix 
 
1.7.14  2014-03-31, vsasa

  - TARIFA, use_sql_tarifa() funkcija, bugfix sa NIL poljima tabele tarifa
 
1.7.13  2014-03-28, vsasa

  - VIRM, update šifranika LDVIRM, problem dužine polja rješen
 
1.7.12  2014-03-27, vsasa

  - FAKT, štampa dokumenta iz pripreme puca kod otvaranja tabele - bugfix 
  - ostalo, mnoštvo problema sa otvarnjem indeksa nakon otvaranja tabale - bugfix
  - DBF verzija 0.9.4

1.7.11  2014-03-25, hernad

  - PERFORMANCE: SQLRDD nasa slova za 16-tak tabela #32846, DEBUG #32854

1.7.10  2014-03-25, hernad

  - DEBUG PARTN/SIFV #32839

1.7.9   2014-03-25, hernad

  - DEBUG sifk/edkolona = NIL

1.7.8   2014-03-25, hernad

  - DEBUG my_use full sync, PERFORMANCE: izbaceno iz my_use F18_DB_LOCK

1.7.7   2014-03-22, hernad

  - DEBUG RDDSQL nasa slova #32809

1.7.6   2014-03-21, hernad

  - DEBUG novi harbour 32/hbpgsql uzrokovali bug na semaforima
 
1.7.5   2014-03-21, vsasa

  - FIN, bruto bilans SQL, korekcije

1.7.4   2014-03-19, hernad

  - DEBUG/NEW blinkanje off, dbf_rec[ chk0 ], refresh_me se poziva iz my_use
  - REFACTOR hbformat na par prg-ova

1.7.2   2014-03-18, vsasa

  - backport fin bruto bilans izvještaja iz no-dbf branča (#32713) 

1.7.1   2014-03-17, hernad

  - SQLRDD/SDDPG #32746, #32745 (use_sql_sif: tnal, tdok)

1.4.292 2014-03-14, vsasa
 
  - Fiskalne funkcije, provjera količine i cijene prije slanja fiskalnog računa na fiskalni uređaj - bugfix #32714 
 
1.4.291 2014-03-14, vsasa
 
  - RNAL, refaktor validacije na unosu naloga, #32624
 
1.4.290 2014-03-12, vsasa
 
  - RNAL, ispis repromaterijala po stavkama na nalogu za proizvodnju #32627
  - FAKT, kod štampe narudžbenice i reversa ODT bez cijena
  - RNAL, unos nepravilnog oblika stakla samo sa osnovnim dimenzijama #32624
  - KADEV, ispravka matičnog broja uposlenika #32684
  - KADEV, snimanje promjena - bug fix #32684
 
1.4.289 2014-03-05, vsasa
 
  - FAKT, pogrešna referenca na tabelu kod štampe dokumenta
  - LD, export podataka za banke - korekcija 
 
1.4.288 2014-02-26, vsasa
 
  - KALK, generisanje inventure, ako je količina = 0 i FCJ = 0 kao i NC itd...
 
1.4.287 2014-02-21, vsasa
 
  - RNAL, dorade na unosu naloga, stavke, operacije, logiranja, promjena broja stavke itd...
 
1.4.286 2014-02-20, vsasa
 
  - FAKT, količinski pregled po artiklima - proširenje izvještaja
  - KALK, lager lista ulaz/izlaz količine sa decimalama 
 
1.4.285 2014-02-18, vsasa
 
  - LD, export podataka kredita za banke
 
1.4.284 2014-02-18, vsasa
 
  - KALK, više konta na jednoj kalkulaciji - parametar 
 
1.4.283 2014-02-17, vsasa
 
  - KALK, dokument 81 unos kaskadnog rabata + unos ukupne fakturne vrijednosti 
 
1.4.282 2014-02-14, vsasa
 
  - FAKT, provjera PDV-a prilikom štampanja fakture 
 
1.4.281 2014-02-14, vsasa
 
  - LD, štampa specifikacije za RS, omjer doprinosa za zdravstvo
 
1.4.280 2014-02-11, vsasa
 
  - RNAL, datum štampanja specifikacije / obračunskog lista
  - RNAL, štampa specifikacije - korekcije
 
1.4.279 2014-02-06, vsasa
 
  - FAKT, štampa ODT faktura, odabir template-a uvijek ide iz /opt/knowhowERP/template/ lokacije 
  - OS, opcija sanacija kod obračuna amortizacije sredstava
  - KALK, brisanje grupe dokumenata - bugfix
  - FAKT, štampa fiskalnog računa, bugfix (ino partner, virmansko plaćanje)
 
1.4.278 2014-01-29, vsasa
 
  - FAKT, fiskalne funkcije, selekcija partnera i vrste plaćanja G ili VR itd... 
 
1.4.277 2014-01-29, vsasa
 
  - KALK, TKM, opis stavke ako je predispozicija 
 
1.4.276 2014-01-28, vsasa
 
  - KALK, TKM, rabat iskazan kao negativno zaduženje treba biti u bruto iznosu, 
    sa uračunatim PDV-om
 
1.4.275 2014-01-28, vsasa
 
  - FIN, štampanje fin kartice ODT, dupla konverzija
 
1.4.274 2014-01-28, vsasa
 
  - MAT, štampanje dokumenata i PICT kodovi, ispravka
 
1.4.273 2014-01-23, vsasa
 
  - KALK, izvještaj TKM, popust u maloprodaji na ulaznoj strani u minusu 
 
1.4.272 2014-01-22, vsasa
 
  - OS, popisna lista, datum obrade u headeru izvještaja
 
1.4.271 2014-01-21, vsasa
 
  - FAKT, kritični bug kod štampanja dokumenta
 
1.4.270 2014-01-21, vsasa
 
  - FAKT, provjera brojača dokumenta - bugfix
 
1.4.269 2014-01-21, vsasa
 
  - MAT, proširenje izvještaja
 
1.4.268 2014-01-17, vsasa
 
  - KADEV, bugfix, snimanje promjena 
  - MAT, bugfix, opcija početnog stanja, proširenje izvještaja
 
1.4.267 2014-01-16, vsasa
 
  - FAKT, fiskalne opcije - korekcija 
  - KALK, LLM/LLP ODT varijanta izvještaja
 
1.4.266 2014-01-15, vsasa
 
  - FAKT, štampa fiskalnih računa 11 i tip placanja VR i INO partner - korekcija
  - OS, popisna lista
 
1.4.265 2014-01-15, vsasa
 
  - F18 atributi dokumenta, korekcije
 
1.4.264 2014-01-15, vsasa
 
  - LD, git export - bugfix 
 
1.4.263 2014-01-15, vsasa
 
  - KALK, generisanje labela - korekcije
  - MAT, popisna lista inventure ODT
 
1.4.262 2014-01-13, vsasa
 
  - KALK, početno stanje magacina - bugfix 
 
1.4.261 2013-12-31, vsasa
 
  - KALK, bugfix kod automatskog prenosa TOPS->KALK
  - F18, otvaranje nove baze, reset RNAL brojača
  - POS, storniranje računa, otvaranje tabela POS, POS_DOKS
 
1.4.260 2013-12-30, vsasa
 
  - POS, inventura/nivelacija - korekcije na formi unosa (kontrole itd...)
 
1.4.259 2013-12-11, vsasa
 
  - TRING fiskalne funkcije, korekcije
 
1.4.258 2013-12-06, vsasa
 
  - KALK, unos/ispravka dokumenta 80 (predisp.) bugfix
 
1.4.257 2013-12-03, vsasa
 
  - KALK, unos atributa - korekcije na opciji CTRL+A
 
1.4.256 2013-11-29, vsasa
 
  - F18 update, korekcije
  - FAKT, atributi korekcije
  - KALK, atributi, rok trajanja kartica prodavnice

1.4.255 2013-11-28, vsasa
 
  - KALK, FIN, atributi stavki kod unosa dokumenta

1.4.254 2013-11-22, vsasa
 
  - F18, update aplikacije - windows update

1.4.253 2013-11-22, vsasa
 
  - F18, update aplikacije korekcije
 
1.4.252 2013-11-22, vsasa
 
  - F18, update aplikacije
 
1.4.251 2013-11-20, vsasa
 
  - POS, generisanje plu kodova nakon zaduženja iz KALK-a
 
1.4.250 2013-11-20, vsasa
 
  - KALK, dorada, lager liste i minimalna količina
 
1.4.249 2013-11-19, vsasa
 
  - FIN, specifikacija po dospjeću, picture iznosa parametar
  - KALK, korekcija izvještaja pregled po objektima
  - FIN, specifikacija dospjeća po ročnim intervalima
 
1.4.248 2013-11-19, vsasa
 
  - Kurs() opet bug, ispravljeno (beskonačna petlja)
 
1.4.247 2013-11-19, vsasa
 
  - poziv funkcije _sql_get_value() ispravljen
 
1.4.246 2013-11-19, vsasa
 
  - Kurs() korekcija funkcije, problem kod knjiženja naloga
 
1.4.245 2013-11-18, vsasa
 
  - VALUTE, opcije valutiranja Kurs(), Omjer() ... korekcije
 
1.4.244 2013-11-15, vsasa
 
  - FAKT, fiskalne opcije, miksani račun PDV0, PDV17
 
1.4.243 2013-11-12, vsasa
 
  - KALK, kontiranje naloga domaća/strana valuta - bugfix 
 
1.4.242 2013-11-12, vsasa
 
  - F18, otvaranje novih baza, uslov sve baze bugfix
 
1.4.241 2013-11-11, vsasa
 
  - KADEV, šifrarnik sistematizacije, korekcije (uvođenje opcije F4)
 
1.4.240 2013-11-07, vsasa
 
  - F18, otvaranje nove godine za sve ili pojedinačnu bazu (admin opcije F10)
  - KADEV, korekcija indeksa kod pretrage podataka
 
1.4.239 2013-11-04, vsasa
 
  - KADEV, informacije o stažu i statusu uposlenika na formi podataka
  - KADEV, 3 nova odt izvještaja
 
1.4.238 2013-10-31, vsasa
 
  - VIRM, firma nalogodavac kod ručnog unosa virmana
 
1.4.237 2013-10-25, vsasa
 
  - KADEV, ispis progres bara kod filterisanja zapisa
 
1.4.236 2013-10-24, vsasa
 
  - KADEV, browse obrazaca korekcije
  - FAKT, provjera PLU kod-a kod generisanja stavki računa
 
1.4.235 2013-10-22, vsasa
 
  - KALK, štampa liste dokumenata sa ispisom sadržaja - korekcije
 
1.4.234 2013-10-22, vsasa
 
  - KALK, izvještaj po objektima - korekcije
  - KALK/POS prenos, setovanje PLU kodova
 
1.4.233 2013-10-09, vsasa
 
  - StartPrint() -> START PRINT CRET / fakturno, štampa
 
1.4.232 2013-10-02, vsasa
 
  - fiskalne funkcije FPRINT, štampanje VP fakture vrsta plaćanja "G" - sa partnerom
  - kalk/fin, kontiranje DATVAL() korekcije
  - F18_DB_LOCK - korekcija ispitivanja datuma  
 
1.4.231 2013-09-24, vsasa
 
  - fiskalne funkcije FPRINT, štampanje duplikata, korekcije
  - FAKT, kontrola broja dokumenta kod ažuriranja
 
1.4.230 2013-09-19, vsasa
 
  - LD, mip-1023, beneficirani radni staž - dorade
  - čišćenje statusa backup-a kod novog pokretanja aplikacije
  - KALK, prenos FAKT 11 -> KALK 41, popust bez PDV
 
1.4.229 2013-09-17, vsasa
 
  - FAKT, FPRINT fiskalni uredjaj, duplikat računa iz pregleda računa
 
1.4.228 2013-09-13, vsasa
 
  - FAKT, provjera broja dokumenta kod promjene tip-a dokumenta
  - KALK, ažuriranje dokumenta 11, problem sa poljima
  - KALK, stavimpcsif() koristi se gDefNiv varijabla za promjenu cijena
 
1.4.227 2013-09-12, vsasa
 
  - Fiskalne funkcije FPRINT, čitanje fajla greške - dorade
  - RNAL, unos novog naloga, nalog tip 
  - RNAL, pregled naloga, uslov po tipu naloga
 
1.4.226 2013-09-09, vsasa
 
  - RNAL, neusklađen proizvod, dorade
 
1.4.225 2013-09-06, vsasa
 
  - FAKT, realizacija maloprodaje po vrstama placanja
  - RNAL, neusklađeni proizvodi, init funkcije
  - KALK, štampa dokumenta, provjera cijena - koji redni broj nije ok
 
1.4.224 2013-09-03, vsasa
 
  - KALK, kontiranje PREDISP() funkcija, da li je dokument predispozicija
 
1.4.223 2013-08-30, vsasa
 
  - KALK, uzmi MPC iz šifrarnika korekcije
 
1.4.222 2013-08-28, vsasa
 
  - LD, update minulog rada u šifrarniku radnika, korekcija
  - FAKT, promjena podataka dokumenta, dodatak promjene vrste plaćanja
 
1.4.221 2013-08-27, vsasa
 
  - POS, vrste plaćanja za fiskalni račun, pretvori u UPPER prije provjere
  - POS, import šifrarnika FMK/ROBA, fisc_plu polje
  - FAKT, storno dokument, resetuj vrstu placanja na gotovina obavezno
 
1.4.220 2013-08-26, vsasa
 
  - FAKT, MP račun za ino kupca ili kupca oslobođenog od plaćanja PDV-a
  - FAKT, KO obrada PDV-a
 
1.4.219 2013-08-25, vsasa
 
  - KALK, ubaci mpcsapp iz sifrarnika u dokument prema odrednici tipa cijene i konta
 
1.4.218 2013-08-25, vsasa
 
  - RNAL, izmjena kratkog i dodatnog opisa naloga, korekcija ODT template-a
 
1.4.217 2013-08-02, vsasa
 
  - ePDV, export kif tabele
 
1.4.216 2013-08-01, vsasa
 
  - RNAL, export fajla za lisec, korekcije na liniji GRx
 
1.4.215 2013-08-01, vsasa
 
  - RNAL, export fajla za lisec, korekcije
  - RNAL, export naloga u FAKT, puširanje veze na server
 
1.4.214 2013-07-31, vsasa
 
  - ePDV, štampa pregleda dokumenata, R_KIF -> epdv_r_kif
 
1.4.213 2013-07-31, vsasa
 
  - ePDV, štampa kuf dokumenta, polja i_pdv i i_pdv2
 
1.4.212 2013-07-31, vsasa
 
  - ePDV, export kuf/kif dokumenata
 
1.4.211 2013-07-29, vsasa
 
  - LD, parametri prebačeni na set/fetch metric
 
1.4.210 2013-07-26, vsasa
 
  - F18, otvaranje nove baze, briši i lock statuse
  - KALK/FIN kontiranje, datum valute - korekcija
  - LD/VIRM, export podataka za banke, dupliciranje podešenje, kopiranje formule iz postojeće
 
1.4.209 2013-07-26, vsasa
 
  - KALK, sh+F8, brisanje stavki dokumenta od-do
  - F18 db lock, napravi sinhro ako se desi zakljucavanje automatsko baze
 
1.4.208 2013-07-19, vsasa
 
  - F18 lock database, init
  - FIN, automatsko zatvaranje otvorenih stavki, može i partner prazno (za sve partnere)
  - KALK/POS razmjena podataka, problem sa unmount-om na unix sistemu
  - LD, odabir broja obračuna pri ulasku u program
  - LD, izbačena varijanta obračuna sa forme kod ulaska u obračun
 
1.4.207 2013-07-16, vsasa
 
  - kadev, korekcije na rekalkulaciji podataka / radni staž
 
1.4.206 2013-07-15, vsasa
 
  - kadev, korekcije na rekalkulaciji podataka
  - ld, kartica plate prikaz broja obračuna
  - ld/fin, korekcije dužine stranica na izvještajima

1.4.205 2013-07-11, vsasa
 
  - kadev, korekcije na obrascima 

1.4.204 2013-07-11, vsasa
 
  - kalk, prenos podataka pos->kalk 42, razrada popusta

1.4.203 2013-07-11, vsasa
 
  - fin, bruto bilansi A3 i A4L su identični, samo orjentacija papira različita

1.4.202 2013-07-10, vsasa
 
  - fin, bruto bilansi txt varijanta, dužina stranice potret/lendskejp

1.4.201 2013-07-09, vsasa
 
  - kadev, korekcije na unosu podataka i pretrazi
  - fin, bruto bilans txt varijanta, dužina stranice potret/lendskejp

1.4.200 2013-07-04, vsasa
 
  - ld, izvještaj topli obrok, korekcije na formi uslova itd..
  - rnal, ažuriranje naloga, provjera ispravnosti rednih brojeva naloga

1.4.199 2013-07-02, vsasa
 
  - ld, eksport fajla topli obrok, konverzija znakova

1.4.198 2013-07-02, vsasa
 
  - šifranik artikala, setovanje mpc iz vpc / ubačeno u KALK admin opcije
  - ld, eksport fajla topli obrok, konverzija znakova
 
1.4.197 2013-06-26, vsasa
 
  - LD, radni sati unos, korekcije
 
1.4.196 2013-06-25, vsasa
 
  - FIN, bruto bilans subanalitika ODT...
  - KALK, štampa labela, parametar dužine naziva artikla
  - F18, otvaranje nove baze, bugfix
  - F18, update db, update baze sa zadatim nazivom, update empty tabela
 
1.4.195 2013-06-19, vsasa
 
  - KALK, dužina stranice za izvještaje i dokumente / 2
  - LD, kartica plate, prikaz prebijenog stanje pozitivnih i negativnih nakanada
 
1.4.194 2013-06-19, vsasa
 
  - KALK, dužina stranice za izvještaje i dokumente
  - RNAL, specifikacija poslovođa, broj stakala
 
1.4.193 2013-06-18, vsasa
 
  - F18, ispis verzije db servera na glavnom meniju preduzeća
  - LD, izvještaj topli obrok - bugfix
  - LD, zaštita obračuna, otključavanje/zaključavanje
  - FIN, štampa IOS-a bez praznog partnera u šifrarniku
  - FIN, brojač naloga - varijanta "2" ( firma + brnal ) 
  - LD, pretraga radnika, opcija "q" ispravka
  - POS, izdavanje storno računa plaćenog karticom - bugfix
  - FAKT, dupliciranje dokumenta, naša slova, današnji datum

1.4.192 2013-06-14, vsasa
 
  - fakt, štampa fakture ODT, ispis stope PDV-a u totalu
 
1.4.191 2013-06-13, vsasa
 
  - mat, korekcije na izvještajima i parametrima
 
1.4.190 2013-06-13, vsasa
 
  - ld, rekapitulacija plate za sve rj, provjera kredita
 
1.4.189 2013-06-12, vsasa
 
  - ld, rekapitulacija plate, provjera kredita
 
1.4.188 2013-06-07, vsasa
 
  - F18, sinhronizacija baza master/slave
  - RNAL, štampa specifikacije materijala na specifikaciji ODT
 
1.4.187 2013-06-06, vsasa
 
  - FAKT, biranje template-a na osnovu parametara
 
1.4.186 2013-06-06, vsasa
 
  - POS, storniranje računa F7, odabir pos računa
  - POS, popust preko određenog iznosa - bugfix
  - POS, import šifrarnika FMK/TOPS - polje tip dodano također u import proceduru
  - F18, admin, update baze - bugfix
  - FAKT, odabir odt template-a na osnovu parametara
 
1.4.185 2013-05-30, vsasa
 
  - F18, otvaranje nove baze, brisanje, otvaranje nove godine
 
1.4.184 2013-05-27, vsasa
 
  - LD, šifranik radnika, filter šifranika po pojedinim uslovima, opcija "Q"
  - KADEV, init verzija modula (stavljanje u funkciju iz FMK/KADEV reposa)
  - FAKT, štampa maloprodajnih faktura ODT, maloprodajne cijene
  - RNAL, promjena strukture tabele rnal_docs, polje "doc_type"
  - RNAL, setovanje statusa operacija, u toku...
  - RNAL, štampa obračunskog lista ODT varijanta
  - RNAL, logiranje baznih operacija kao F18_DOK_OPER log status
  - F18, kreiranje nove baze podataka, brisanje podataka itd...
 
1.4.183 2013-05-22, vsasa
 
  - F18, informacije o tekućim grupama za korisnika
 
1.4.182 2013-05-22, vsasa
 
  - F18, group/user role - login funkcije korekcije
 
1.4.181 2013-05-21, vsasa
 
  - ld, specifikacija kredita, dodatni uslovi kod pregleda izvještaja 
 
1.4.180 2013-05-21, vsasa
 
  - F18, logiranje bitnih dokument operacija modula FIN/KALK/FAKT/LD
 
1.4.179 2013-05-21, vsasa
 
  - F18, filter za baze u .f18_config.ini
  - paginacije izvještaja
 
1.4.178 2013-05-20, vsasa
 
  - ld, import podataka iz FMK/LD (spajanje više obračunskih jedinica u jednu)
  - ld, specifikacija kredita po kreditorima (sql varijanta)
 
1.4.177 2013-05-09, vsasa
 
  - fakt, unos dokumenta, polje poreza izbačeno
  - kalk, početna stanja mag/prod, automatsko ažuriranje dokumenata
  - fin, početno stanje, automatsko ažuriranje dokumenata 
  - fin, parametar potpisa na nalogu
 
1.4.176 2013-05-07, vsasa
 
  - virm, export podataka za banke, datum prazan zamjeni sa 0
 
1.4.175 2013-05-07, vsasa
 
  - pos/kalk, prenos podataka, kreiranje i provjera postojanja fajla
  - fin, početno stanje, upisivanje strane valute u početnom stanju
 
1.4.174 2013-04-29, vsasa
 
  - export izvještaja i podataka na user-friendly lokaciju
  - kalk/fakt, prenos podataka, setovanje idpartner polja
  - čišćenje header-a FMK => F18 knowhowERP
 
1.4.173 2013-04-29, vsasa
 
  - fakt, povrat dokumenta u pripremu, provjera fiskalnih opcija
 
1.4.172 2013-04-29, vsasa
 
  - ld, pregled plata, razdojeno prikaz primanja i odbitaka
  - prikaz verzije na glavnom meniju F18
  - virm, krediti za istog partnera sumirano 

1.4.171 2013-04-27, vsasa
 
  - virm, prenos kredita iz ld-a, partija kreditora na virmanu
  - fakt, prikaz fiskalnog / reklamnog racuna u pregledu dokumenata
 
1.4.170 2013-04-25, vsasa
 
  - kalk, import txt (varaždin), setovanje mpc iz šifranika na osnovu tabele koncij
  - virm, generisanje virmana za plate - broj računa radnika za kredit

1.4.169 2013-04-22, vsasa

  - virm, export podataka virmana u txt fajl (eksport za banke) 
 
1.4.168 2013-04-19, vsasa

  - fakt, grupna stampa faktura po zadatom uslovu / eksport na lokaciju
  - fakt, novi template fakture (f-std.odt, f-stdk.odt) / automatska selekcija template-a 
 
1.4.167 2013-04-17, vsasa

  - virm, parametar firme nalogodavca
  - virm, proširenje pripreme naloga (ispis više informacija)
  - šifrarnik općina, polje region ubačeno 
  - nakon fiskalne štampe vrati tekući direktorij u my_home()
 
1.4.166 2013-04-16, vsasa

  - rnal, štampa naloga za proizvodnju, korekcije
 
1.4.165 2013-04-16, vsasa

  - ld, štampa kartice plate nakon unosa obračuna - bugfix
 
1.4.164 2013-04-16, vsasa

  - kalk, dokument 81, ispis broja dokumenta
 
1.4.163 2013-04-16, vsasa

  - rnal, izvještaj za poslovođe, odabir datuma za izvještaj
  - os, početno stanje, prenos promjena - korekcije
  - rnal, izvještaj za poslovođe, nova forma parametara sa hash matricom
  - fakt, fiskalne funkcije, zabrana ZPDV + INO u kombinaciji, provjera i upozorenje
 
1.4.162 2013-04-12, vsasa

  - pos, stanje prodavnice ili magacina sa konta
  - pos, nepravilna cijena K_UP
 
1.4.161 2013-04-09, vsasa

  - status modula na glavnom ekranu modula
  - kalk, razmjena podataka tops/kalk automatski
  - bterm funkcije - bugfix
  - ostale korekcije
 
1.4.160 2013-04-05, vsasa

  - vpn podrška na glavnom meniju (F10)
  - promjena sezone, init globalnih parametara modula, refresh info screen
 
1.4.159 2013-04-04, vsasa

  - rnal, izvještaj za poslovođe, sortiranje po datumu isporuke
  - fakt, w - duplikat > dupliciraj
 
1.4.158 2013-04-02, vsasa

  - ld, export izvještaja za banku, korekcije
 
1.4.157 2013-04-01, vsasa

  - rnal, specifikacija za poslovođe, gledati datum isporuke umjesto datuma naloga
 
1.4.156 2013-04-01, vsasa

  - rnal, specifikacija za poslovođe, korekcije
 
1.4.155 2013-04-01, vsasa

  - fakt, fiskalni računi - bugfix
  - f18 db update - bugfix
 
1.4.154 2013-03-29, vsasa

  - fakt, pregled podataka, refresh bugfix
  - fakt, ostale sitnice

1.4.153 2013-03-29, vsasa

  - ld, parametri sati/iznosa

1.4.152 2013-03-28, vsasa

  - f18, login, matrica za odabir firmi je uvijek aktuelna radi mogućeg upgrade-a baze

1.4.151 2013-03-27, vsasa

  - f18, db update, korekcije

1.4.150 2013-03-27, vsasa

  - f18, db update, korekcije

1.4.149 2013-03-27, vsasa

  - f18, db update

1.4.148 2013-03-26, vsasa

  - f18, radovi na novom login-u

1.4.147 2013-03-26, vsasa

  - f18, radovi na novom login-u

1.4.146 2013-03-26, vsasa

  - f18, radovi na novom login-u

1.4.145 2013-03-22, vsasa

  - rnal, štampa naloga ODT varijanta  [#30150](http://redmine.bring.out.ba/issues/30150)
  - f18, sh+F6 vraćeno u funkciju
  - f18, radovi na novom login-u

1.4.144 2013-03-19, vsasa

  - ld, exporti za banke [#30450](http://redmine.bring.out.ba/issues/30450)
  - roba, sastavnice, ispravka opisa proizvoda u sastavnicama

1.4.143 2013-03-19, vsasa

  - f18, kreiranje tabela i modifikacije struktura

1.4.142 2013-03-15, vsasa

  - fin, informacije o stanju konta kod knjiženja naloga (samo za konto/partner)
  - ld, proširen pregled šifrarnika 

1.4.141 2013-03-14, vsasa

  - fakt, ugovori naljepnice, problem sa indeksima

1.4.140 2013-03-14, vsasa

  - kalk, TKV, po NC ili po PC, parametar kod povlačenja izvještaja
 
1.4.139 2013-03-13, vsasa

  - fprint, answer file u log levelu 3 umjesto 5
  - fakt, povrat dokumenta, zabrana ako je fiskalni
  - ld, unos obracuna, izlazak sa ESC hendliranje
  - fakt, zbirni fiskalni račun, skraćen opis
  - dbf_update_rec bez alerta, sporni događaj se logira
  - kalk, lager lista sa VPC iz šifrarnika ili VPC iz tabele KALK (sa dokumenata)
 
1.4.138 2013-03-13, vsasa

  - f18, kreiranje dbf tabela, korekcije [#30524](http://redmine.bring.out.ba/issues/30524)
 
1.4.137 2013-03-12, vsasa

  - fin, parametri proizvoljnih izvještaja
  - ld, izlazak iz pripreme, brisanje zapisa - bugfix
  - fin, proizvoljni izvještaji, setpxlat() korekcije
  - f18 modules, reports po defaultu jedini na meniju
  - fin, početno stanje, kopiraj i ubaci šifre u novoj sezoni

1.4.136 2013-03-11, vsasa

  - fin, proizvoljni izvještaji
 
1.4.135 2013-03-08, vsasa

  - f18 tezinski barkod, provjera dužine formiranog barkod-a na osnovu težinskog barkod-a
  - f18 reports modul

1.4.134 2013-03-07, vsasa

  - windows backup funkcija stavljena u pogon
  - windwos ping time parametar ubačen, samo se pojavljuje kod windows instalacije
  - f18 backup, set last backup date samo kod automatskog backup-a

1.4.133 2013-03-06, vsasa

  - ld, radne jedinice, validacija polja tip rada
  - fin, brisanje pripreme po zadatim uslovima (nova opcija)
  - kalk, težinski barkod kod dokumenta "80" (predispozicija) bugfix

1.4.132 2013-03-05, vsasa

  - os, unos promjena na isti datum - bugfix
  - kalk, unos dokumenta "24"
  - kalk, štampa dokumenta "24" iz pripreme, štampa se rekapitulacija
  - fakt, invetura unos i štampa - bugfix

1.4.131 2013-03-04, vsasa

  - f18 backup funkcije, init...
  - brisanje loga pri startu aplikacije, parametri logova/backup-a
  - fakt, fiskalni dnevni izvještaji - kontrola (parametar u fiskalnim parametrima za user-a)
  - os, pokretanje početnog stanja u sezoni
  - ld, prenos virmana, partija kredita
  - kalk, opis asistenta a+F10 izbačen, postavljeno samo A
 
1.4.130 2013-02-25, vsasa

  - kalk, kalkulacija cijena vp (prikaz PV sa PDV) u ODT varijanti
  - kalk, početna stanja, korekcija sa brojem dokumenta

1.4.129 2013-02-22, vsasa

  - fakt, brisanje ugovora - bugfix

1.4.128 2013-02-22, vsasa

  - fin, prikaz kartica sa saldom nula u odt varijanti 

1.4.127 2013-02-22, vsasa

  - fin, korekcija kod ažuriranja i provjere konta
  - ld, export gip obrasca, greška sa karakterima
  - fakt, štampa ugovora i naljepnica korekcije

1.4.126 2013-02-18, vsasa

  - fakt, ispravka partnera na postojećim dokumentima - bugfix

1.4.125 2013-02-15, vsasa

  - kalk, izvještaj poreza prodavnice ukalkulisani/realizovani- bugfix partn alias
 
1.4.124 2013-02-14, vsasa

  - kalk, izvještaj poreza prodavnice - bugfix
  - fin, ažuriranje i povrat grupe naloga
  - pos, stanje artikla moguće gledati i iz kalk-a
  - pos, prenos dokumenta inventure KALK->POS, korekcije
 
1.4.123 2013-02-11, vsasa

  - kalk, unos po težinskom barkod-u unutar dokumenata MP i VP
  - rnal/fakt, valuta uvijek kao UPPER()
  - rnal export lisec, nakon eksporta fajla, zatvori ga 

1.4.122 2013-02-07, vsasa

  - kalk/fakt, ispis grupacije robe na fakturi, pregled na lager listi

1.4.121 2013-02-07, vsasa

  - ld, olp/mip/gip parametri naziva firme - bugfix

1.4.120 2013-02-06, vsasa

  - fakt, realizacija mp, razvrstavanje po tipu partnera

1.4.119 2013-02-06, vsasa

  - fin, subanalitička specifikacija sql [#29508](http://redmine.bring.out.ba/issues/29508)
  - fin, subanalitička kartica - bugfix 
  - kalk, stanje magacina sql - bugfix 

1.4.118 2013-02-04, hernad

  - delphirb stampa virmana tabele se zakljucaju
  - kolicina HCP 12,3 kao i neosoft

1.4.117 2013-01-31, vsasa

  - fin, prenos početnog stanja - po otvorenim stavkama, opcija "1"
  - rnal, export naloga u otpremnicu - uslovi exporta
  - fakt, formiranje računa na osnovu otpremnica - set valuta
  - os, generisanje početnog stanja i generisanje podataka za novu sezonu
  - f18 pregled loga sa glavnog menija

1.4.116 2013-01-31, vsasa

  - fakt, labelu.dbf, problem sa indeksima 

1.4.115 2013-01-31, hernad, vsasa

  - open_folder = f18_open_document
  - fakt, štampanje naljepnica za ugovore - korekcije u kodu

1.4.114 2013-01-31, hernad

  - ludara sa f18_run uvodim f18_open_document

1.4.113 2013-01-31, hernad
  
  - build with patchirani harbour (bold fontovi)

1.4.112 2013-01-31, hernad

  - delphirb zaglavljuje: linux f18_run je primarno system a ne hb_runprocess

1.4.111 2013-01-30, vsasa

  - fakt, prikaz txt pregleda dokumenata u KM/EUR i sabiranje iznosa

1.4.110 2013-01-30, vsasa

  - rnal, kontrola cjelovitosti artikala/elemenata - izvještaj
  - rnal, unos artikla - bugfix
  - rnal, unos naloga, da li je artikal ispravan !!! provjera

1.4.109 2013-01-30, hernad

  - fakt_atributi - create_index(UNIQUE), brisanje svih sirocica
  - linux odt stampa linux/xdg-open trazi "&" i __run_system

1.4.108 2013-01-29, vsasa

  - rnal, export izvještaja u oo3
  - rnal, pregled izvještaja "efekat proizvodnje" - bugfix
  - fakt, kontrola atributa kod ažuriranja dokumenta
  - prikaz tekućeg usera i baze na glavnom meniju
 
1.4.107 2013-01-28, vsasa

  - kalk, provjera duplih barkod-ova unutar šifranika artikala
  - os, generacija podataka za novu sezonu
  - kalk, kontiranje naloga ručno, bez generisanja broja naloga
 
1.4.106 2013-01-25, vsasa, hernad

  - fin/kalk/fakt - udaljene lokacije razmjena podataka - korekcije
  - fakt - evidentiranje uplata
  - direktna štampa na lpt
 
1.4.105 2013-01-24, vsasa

  - rnal, štampa naloga/otpremnice - korekcije na izvještajima
  - rnal, export otpremnice na osnovu naloga, broj otpremnice "22"
  - rnal, izvještaj "pregled prebačenih otpremnica", korekcije

1.4.104 2013-01-23, vsasa

  - fin, ručno zatvaranje o.stavki - vraćanje filtera samo kod štampe

1.4.103 2013-01-23, hernad

  - #30139 iskljucujem FWRITE u log 

1.4.102 2013-01-23, hernad, vsasa

 - promjena verzije

1.4.100 2013-01-23, vsasa

 - fin, štampanje fin naloga bez veze konto/partner - nema ih u šifrarniku
 - fakt, unos dokumenta - refresh stavki
 - rnal, export naloga u otpremnicu - bugfix sa opisima

1.4.99 2013-01-22, vsasa

 - f18_run, korekcije (hernad)
 - bildanje mysql librarija pod win os-om sada radi, opcije redmine/RNAL

1.4.98 2013-01-22, vsasa

 - fakt/fin/kalk, import/eksport podataka udaljene lokacije - korekcije 
 
1.4.97 2013-01-21, vsasa

 - fakt, brojač otpremnica po tipu dokumenta 22 - ispravka drito na brojaču fakt dokumenata
 
1.4.96 2013-01-21, vsasa

 - fakt, brojač otpremnica po tipu dokumenta 22 - bugfix
 
1.4.95 2013-01-21, hernad

 - fakt, sumiranje usluga kod pretvaranja otpremnica u račun
 
1.4.94 2013-01-21, vsasa

 - fakt, brojač po otpremnicama tip-a "22" - bugfix
 - rnal, export naloga u fakt - opisi
 - rnal, pregled naloga - bugfix

1.4.93 2013-01-18, vsasa

 - štampa txt dokumenta, samo sa starim buildom

1.4.92 2013-01-18, vsasa

 - fakt, unos nove otpremnice, brojač gledati po tip-u dokumenta "22"
 - fakt, parametrizirana opcija generisanja računa na osnovu otpremnice

1.4.91 2013-01-18, hernad

 - hbmysql windows

1.4.90 2013-01-18, hernad

 - sql_fakt [#30053](http://redmine.bring.out.ba/issues/30053)

1.4.88 2013-01-17, vsasa

 - unos šifrarnika artikala, unos opisa artikla, pregled opisa na opciju "D" u šifrarniku
 
1.4.87 2013-01-16, vsasa

 - unos šifrarnika artikala, može i bez "idkonto"
 - fakt, generacija računa na osnovu otpremnica - privremeno ukinut foreign ključ sa fakt_fakt_atributi
 
1.4.86 2013-01-15, vsasa

 - rnal, unos naloga i dodavanje nove šifre - bugfix 
 
1.4.85 2013-01-15, vsasa

 - hcp uređaji, minimalna količina kod izdavanja računa
 
1.4.84 2013-01-15, vsasa

 - fakt, pregled dokumenata, pravilno računanje osnovice/pdv/ukupne vrijednosti
 - fakt, opcija "T" u unosu dokumenta, ispravljena greška sa valutom
 
1.4.83 2013-01-15, vsasa

 - fin/kalk/fakt/pos, pocetna stanja, ispravka sa karaktrima hb_utf8tostr 
 
1.4.82 2013-01-14, vsasa

 - fakt, generisanje računa na osnovu otpremnice, bugfix
 
1.4.81 2013-01-12, vsasa

 - fakt, generisanje računa na osnovu otpremnice, ispis ko trenutno koristi opciju
 
1.4.80 2013-01-12, vsasa

 - fakt, generisanje računa na osnovu otpremnice, sređivanje opcije, više poruka za korisnika
 
1.4.79 2013-01-11, vsasa

 - rnal, unos naloga bez brisanja memvars
 - fakt, generisanje računa iz otpremnica - lock
 
1.4.78 2013-01-11, vsasa

 - rnal, ispis težine na specifikaciji... 
 
1.4.77 2013-01-10, vsasa

 - mat, azuriranje/povrat naloga - korekcije
 - fakt, formiranje računa na osnovu otpremnice, transakcija i obrada transakcije
 
1.4.76 2013-01-10, vsasa

 - epdv, semafori korekcije... [#29989](http://redmine.bring.out.ba/issues/29989)
 - fin, prenos LD->VIRM
 
1.4.75 2013-01-10, vsasa

 - epdv, semafori korekcije... [#29989](http://redmine.bring.out.ba/issues/29989)
 
1.4.74 2013-01-10, vsasa

 - epdv, semafori korekcije... [#29989](http://redmine.bring.out.ba/issues/29989)
 - fakt, izvještaj realizacija maloprodaje - bugfix
 - ld, prenos podataka ld->fin, korekcije
 
1.4.73 2013-01-09, vsasa

 - rnal, štampa specifikacije, problem sa zaokruženjem kada je isključeno
 - kalk, prenos dokumenata fakt->kalk, korekcija 
 
1.4.72 2013-01-09, vsasa

 - pos, import nivelacija iz modula KALK - BUGFIX
 
1.4.71 2013-01-08, vsasa

 - fin, specifikacija dobavljača po telefonima - BUGFIX
 - os, unos promjena na sredstvima - BUGFIX
 - ispis informacije o sezonskom području na glavnom meniju modula
 - kalk, formiranje početnog stanja magacina - sql varijanta
 - os, radna jedinica je dužine 4, korekcija na izvještajima i unosu... [#29972](http://redmine.bring.out.ba/issues/29972)
 
1.4.70 2013-01-07, vsasa

 - pos, povrat inventure sa spajanjem - BUGFIX 
 - kalk, provjera maloprodajnih cijena sa decimalama većim od 2 
 - rnal, štampa specifikacije sa promjenom isporuke - BUGFIX
 
1.4.69 2013-01-07, vsasa

 - fakt, fiskalni INO računi, problem sa plaćanjem - BUGFIX
 
1.4.68 2013-01-06, vsasa

 - pos, sređivanje opcija unosa / povrata itd...
 - valute, prošireno polje kurs na 6 decimala
 - fakt, korekcije
 
1.4.67 2013-01-05, vsasa

 - pos, spajanje dokumenata kod povrata u pripremu
 - fakt, čišćenje
 
1.4.66 2013-01-05, vsasa

 - fakt, prikaz DINDEM u pripremi dokumenta
 
1.4.65 2013-01-05, vsasa

 - rnal, unos dokuemnta - bugfix
 - pos, čišćenje
 
1.4.64 2013-01-04, vsasa

 - fakt, kreiranje računa za INO kupce - bugfix 
 
1.4.63 2013-01-04, vsasa

 - fakt, kreiranje računa u EUR - bugfix 
 
1.4.62 2013-01-04, vsasa

 - kreiranje valuta u šifrarniku kod prazne instance - bugfix
 
1.4.61 2013-01-03, vsasa

 - rnal, čišćenje koda
 - kalk, prenos fakt->kalk, prenos objekta, ispis dokumenta 95,96 sređen
 - fin, početno stanje sql
 
1.4.60 2013-01-03, vsasa

 - rnal, štampa labela
 
1.4.59 2013-01-03, vsasa

 - šifranici, F4 - bugfix
 - rnal, zatvarnje naloga, logiranje... 
 - rnal, štampanje rekapitulacije repromaterijala, unos repromaterijala
 - rnal, unos naloga, korekcije sa unosom elemenata
 
1.4.58 2013-01-03, vsasa

 - rnal, semafor tabele "customs" - bugfix
 
1.4.57 2013-01-03, vsasa

 - rnal, ažuriranje naloga - bugfix
 
1.4.56 2013-01-03, vsasa

 - rnal, ažuriranje naloga - bugfix
 
1.4.55 2013-01-03, vsasa

 - rnal, dodjeljivanje novih šifri u šifrarniku sql parametar kao i brojač naloga
 
1.4.54 2013-01-03, vsasa

 - rnal, ažuriranje naloga u mrežnom radu
 
1.4.53 2013-01-03, vsasa

 - fprint dnevni izvještaj, automatski polog - bugfix
 
1.4.52 2013-01-03, vsasa

 - fiskalni parametri, fiskalni računi po tipu dokumenta 
 
1.4.51 2012-12-31, vsasa

 - fakt, početno stanje [#29908](http://redmine.bring.out.ba/issues/29908)
 
1.4.50 2012-12-31, vsasa

 - rnal, parametri zaokruženja naloga [#29852](http://redmine.bring.out.ba/issues/29852)
 - fakt, kod ispravke prve stavke izmjeni i fakt atribute
 - pos, formiranje dokumenta početnog stanja [#29899](http://redmine.bring.out.ba/issues/29899)
 
1.4.49 2012-12-28, vsasa

 - fiskalne opcije, čekiranje stavki računa - novi bugfix
 - fakt, fiskalni računi, roba tip "U" hendliranje
 
1.4.48 2012-12-28, vsasa

 - fakt fiskalne opcije, ino bugfix
 - fiskalne opcije, čekiranje stavki računa - bugfix
 
1.4.47 2012-12-28, vsasa

 - hcp pos, filovanje vrste plaćanja [#29881](http://redmine.bring.out.ba/issues/29881)
 
1.4.46 2012-12-27, vsasa

 - hcp fiskalne funkcije, test režim štampe [#29881](http://redmine.bring.out.ba/issues/29881)
 - pos, inventura, korekcije [#29882](http://redmine.bring.out.ba/issues/29882)
 - os, obračun amortizacije - bugfix [#29879](http://redmine.bring.out.ba/issues/29879)
 - hcp, sitni bugfix-ovi
 
1.4.45 2012-12-26, vsasa

 - odt print, više izlaznih fajlova istovremeno
 
1.4.44 2012-12-26, vsasa

 - fiskalne funkcije, provjera direktorija izlaznih fajlova [#29854](http://redmine.bring.out.ba/issues/29854)
 - fakt, ispravi prvu stavku i koriguj sve ostale automatski [#29859](http://redmine.bring.out.ba/issues/29859)
 - fiskalne funkcije, niz bugfix-ova 
 - fakt, stanje robe, proširenje kolona na izvještaju
 - IOS-i, ne prikazuj stavke ako je dug + pot = 0 u režimu prebijanja stavki  
        [#29873](http://redmine.bring.out.ba/issues/29873)
 
1.4.43 2012-12-26, vsasa

 - KALK, IP(), IM() prikaz barkod-a [#29825](http://redmine.bring.out.ba/issues/29825)
 
1.4.42 2012-12-22, vsasa

 - P_Sast IDNUN_ROBAPRO bugfix
 - IOS [#29945](http://redmine.bring.out.ba/issues/29845)
 
1.4.41 2012-12-22, vsasa

 - fakt, fakt_doks/fakt_fakt relacije, parametar dok veze umjesto provjere RNAL modula

1.4.40 2012-12-19, vsasa

 - pos, fiskalni opcije, default pos uređaj

1.4.39 2012-12-19, vsasa

 - pos, fiskalni računi, vrsta plaćanja

1.4.38 2012-12-11, hernad

 - fakt objekti, idrnal ciscenje

1.4.37 2012-12-11, vsasa

  - fakt, objekti [#29724](http://redmine.bring.out.ba/issues/29724)
  - fakt, rnal->fakt veza [#29725](http://redmine.bring.out.ba/issues/29725)
  - fakt, administrativne opcije [#29724](http://redmine.bring.out.ba/issues/29724)
 
1.4.36 2012-12-07, vsasa

  - os, izvještaj amortizacija, bugfix [#29603](http://redmine.bring.out.ba/issues/29603)
 
1.4.35 2012-12-06, vsasa

  - fakt, unos dokumenta, bugfix [#29738](http://redmine.bring.out.ba/issues/29738)
 
1.4.34 2012-12-05, vsasa

  - fin, parametri k1, k2, k3... korekcije [#29733](http://redmine.bring.out.ba/issues/29733)
 
1.4.33 2012-12-01, vsasa

  - fakt, destinacija, dok_veza, korekcije [#29772](http://redmine.bring.out.ba/issues/29772)
  - fakt, atributi, promjena naziva lokalne tabele [#28966](http://redmine.bring.out.ba/issues/28966)
  - semafori, tabela rj beskonačna petlja [#29698](http://redmine.bring.out.ba/issues/29698)

1.4.32 2012-12-01, hernad

  - opis unos - azuriranje/povrat, ovo tek sada radi

1.4.3 2012-12-01, hernad
 
  - fakt atribut opis: get_fakt_atribut_opis()

1.4.00 2012-12-01, hernad
  
  - i_fakt testovi ponovo green nakon promjena na fakt_unos (vsasa)  

1.3.81 2012-11-27, vsasa

  - tremol linux fiskalni drajver, čitanje grešaka [#29690](http://redmine.bring.out.ba/issues/29690)
  - fakt, atributi stavke [#28966](http://redmine.bring.out.ba/issues/28966)
 
1.3.80 2012-11-27, vsasa

  - semafori, izolirane transakcije [#29667](http://redmine.bring.out.ba/issues/29667)
 
1.3.76 2012-11-24, vsasa

  - semafori, promjena logike [#29667](http://redmine.bring.out.ba/issues/29667)
 
1.3.75 2012-11-22, vsasa

  - semafori, bugfix [#29667](http://redmine.bring.out.ba/issues/29667)
 
1.3.74 2012-11-21, vsasa

  - fiskalne funkcije, tarifa, bugfix [#29663](http://redmine.bring.out.ba/issues/29663)
 
1.3.73 2012-11-20, vsasa

  - fin kartica, ODT template, više kartica [#29510](http://redmine.bring.out.ba/issues/29510)
 
1.3.72 2012-11-20, vsasa

  - fiskalne HCP funkcije, bugfix [#29631](http://redmine.bring.out.ba/issues/29631)
 
1.3.71 2012-11-20, vsasa

  - fin, IOS, korekcije [#26751](http://redmine.bring.out.ba/issues/26751)
 
1.3.70 2012-11-20, vsasa

  - fin, IOS, korekcije, print u odt [#26751](http://redmine.bring.out.ba/issues/26751)
  - fiskalne opcije, redizajn [#29631](http://redmine.bring.out.ba/issues/29631)
 
1.3.69 2012-11-12, vsasa

  - fin, globalni brojač naloga [#29545](http://redmine.bring.out.ba/issues/29545)
 
1.3.68 2012-11-09, vsasa

  - kalk, encoding kod asortimana [#29537](http://redmine.bring.out.ba/issues/29537)
 
1.3.67 2012-11-09, vsasa

  - fin, ažuriranje naloga, bugfix [#29595](http://redmine.bring.out.ba/issues/29595)
  - kalk, asortiman forma narudžbe
 
1.3.66 2012-11-08, vsasa

  - fin, budžet opcije, korekcije [#29584](http://redmine.bring.out.ba/issues/29584)
  - virm, generisanje virmana, bugfix [#29561](http://redmine.bring.out.ba/issues/29561)
  - fakt, količinsko stanje artikla sa kalk konta [#29489](http://redmine.bring.out.ba/issues/29489)
  - kalk, lista dokumenata, ispis naziva partnera [#29536](http://redmine.bring.out.ba/issues/29536)
  - kalk, narudžba po asortimanu, obrazac [#29537](http://redmine.bring.out.ba/issues/29537)
 
1.3.65 2012-11-02, vsasa

  - kalk, ažuriranje dokumenta... bugfix [#29573](http://redmine.bring.out.ba/issues/29573)
 
1.3.64 2012-11-02, vsasa

  - update_rec_server_and_dbf... bugfix [#29566](http://redmine.bring.out.ba/issues/29566)
  - logiranje operacija my_use_semaphore_on i off [#29567](http://redmine.bring.out.ba/issues/29567)
  - indikator stanja my_use_semaphore_on i off [#29570](http://redmine.bring.out.ba/issues/29570)
  - ld, unos datuma isplate plata - bugfix [#29571](http://redmine.bring.out.ba/issues/29571)
  - virm, prenos virmana, ukupan broj radnika na virmanu [#29572](http://redmine.bring.out.ba/issues/29572)
 
1.3.63 2012-11-02, vsasa

  - lock_semaphore, log na levelu 7 [#29539](http://redmine.bring.out.ba/issues/29539)
 
1.3.62 2012-11-01, hernad

  - f18_lock_tables - rollback situacija CORE_LIB 3.8.2
 
1.3.61 2012-11-01, hernad

  - my_use set alias kako treba F18_CORE_LIB 3.8.1

1.3.60 2012-11-01, hernad

  - test test test

1.3.56 2012-11-01, hernad

  - izolacija funkcija -  dbf tabele [#29547](http://redmine.bring.out.ba/issues/29547)

1.3.55 2012-11-01, hernad

  - fin_azur_sql, fakt_azur_sql funkcije moraju biti izolovane sa stanovista stanja otvorenih dbf tabela

1.3.54 2012-11-01, hernad

  - f18_lock tables koristi my_use, tako da su sve tabele koje su lockovane garantovano otvorene

1.3.53 2012-11-01, vsasa

  - pos, ručni unos zaduženja - bugfix [#29543](http://redmine.bring.out.ba/issues/29543)
 
1.3.52 2012-10-31, vsasa

  - fakt, ažuriranje dokumenta, bugfix
 
1.3.51 2012-10-31, vsasa

  - template fakture uvijek treba da počinje sa "f-" 
  - fin, suban.kartica, korekcije [#29510](http://redmine.bring.out.ba/issues/29510)
  - sql_date_parse, korekcije [#29509](http://redmine.bring.out.ba/issues/29509)

1.3.50 2012-10-30, hernad

  - synchro debug - refresh dbfs nakon lockovanja tabela [#29400](http://redmine.bring.out.ba/issues/29400)

1.3.43  2012-10-26, vsasa

 - labele za robu, ubačena varijabla grad [#29494](http://redmine.bring.out.ba/issues/29494)
 - fin, subanalitička kartica u odt varijanti [#29510](http://redmine.bring.out.ba/issues/29510)
 
1.3.42 2012-10-25, vsasa

 - pos, update fiskalni račun broj - bug sa lock-om pos_pos [#29500](http://redmine.bring.out.ba/issues/29500)
 
1.3.41  2012-10-25, vsasa

 - rnal, čišćenje [#29486](http://redmine.bring.out.ba/issues/29486)
 - set confirm on/off na print dijalogu [#29495](http://redmine.bring.out.ba/issues/29495)
 - kalk, udaljena razmjena, bugfix [#29498](http://redmine.bring.out.ba/issues/29498)
 - rj, ubačena polja tip i konto [#29488](http://redmine.bring.out.ba/issues/29488)
 - ostale sitne dorade

1.3.40  2012-10-19, vsasa

 - kalk, modifikacija polja tabele kalk_kalk [#29453](http://redmine.bring.out.ba/issues/29453)
 - rnal, čišćenje
 
1.3.39  2012-10-19, vsasa

 - kalk, import udaljene lokacije iz FMK, korekcije [#29463](http://redmine.bring.out.ba/issues/29463)
 
1.3.38  2012-10-17, vsasa

 - ld, parametri obračuna, loš indeks kod semafora [#29445](http://redmine.bring.out.ba/issues/29445)
 
1.3.37  2012-10-17, vsasa

 - kalk, import podataka iz FMK, bugfix [#29443](http://redmine.bring.out.ba/issues/29443)
 - fin, dnevnik naloga, bugfix [#29444](http://redmine.bring.out.ba/issues/29444)
 
1.3.36  2012-10-16, vsasa

 - fiskalni račun, štampa latin karatera, bugfix, parametar [#29419](http://redmine.bring.out.ba/issues/29419)
 
1.3.35  2012-10-15, vsasa

 - fin, štampa sintetičke kartice, bugfix [#29416](http://redmine.bring.out.ba/issues/29416)
 - fakt, odt štampa, bugfix [#29418](http://redmine.bring.out.ba/issues/29418)
 - pos, štampa zaduženja nakon unosa, bugfix [#29417](http://redmine.bring.out.ba/issues/29417)
 - PDV17 kao default tarifa u unosu novih artikala [#29421](http://redmine.bring.out.ba/issues/29421)

1.3.34  2012-10-12, vsasa

 - fin, otvorene stavke iz pripreme naloga, BUGFIX !!!
 
1.3.33  2012-10-11, vsasa

 - fakt, pregled prodaje, proširenje uslova na izvještaju
 
1.3.32  2012-10-11, vsasa

 - fin, ažuriranje naloga, BUGFIX !!!! 
 
1.3.31  2012-10-11, vsasa

 - fin, otvorene stavke, korekcije [#29291](http://redmine.bring.out.ba/issues/29291)
 - kalk, izvještaj pregleda po dobavljačima magacin korekcija
 
1.3.30  2012-10-02, vsasa

 - kalk, pregled asortimana [#29338](http://redmine.bring.out.ba/issues/29338)
 - fakt, generisanje ugovora, čišćenja
 
1.3.29  2012-09-27, vsasa

 - inventure, peglanje [#29308](http://redmine.bring.out.ba/issues/29308)
 - fin, kreiranje pom tabele [#29263](http://redmine.bring.out.ba/issues/29263)
 
1.3.28  2012-09-27, vsasa

 - štampanje na lpt1, lpt2 windows, bugfix [#29262](http://redmine.bring.out.ba/issues/29262)
 
1.3.27  2012-09-27, vsasa

 - pos, seta cijena za korištenje [#29262](http://redmine.bring.out.ba/issues/29262)
 - pos, inventura, prikaz trenutnog stanja [#29264](http://redmine.bring.out.ba/issues/29264)
 - fin, specifikacija otvorenih stavki [#29274](http://redmine.bring.out.ba/issues/29274)
 
1.3.26  2012-09-23, vsasa

 - kalk, kopiranje seta cijena [#29249](http://redmine.bring.out.ba/issues/29249)
 
1.3.25  2012-09-20, vsasa

 - pos, opcije inventure, dorade, korekcije [#29241](http://redmine.bring.out.ba/issues/29241)
 
1.3.24  2012-09-20, vsasa

 - pos, opcije inventure [#29241](http://redmine.bring.out.ba/issues/29241)
 
1.3.23  2012-09-19, vsasa

 - pos, kalk, opcije inventure, bugfix [#29232](http://redmine.bring.out.ba/issues/29232)
 - pos, štampanje kartice artikla, stanja artikala, bugfix [#29238](http://redmine.bring.out.ba/issues/29238)
 - pos, ispis stanja artikla pored opisa na unosu računa [#29240](http://redmine.bring.out.ba/issues/29240)
 
1.3.22  2012-09-12, vsasa

 - fakt, ažuriranje storno računa, bugfix [#29198](http://redmine.bring.out.ba/issues/29198)
 - razne sitne dorade
 
1.3.21  2012-09-07, vsasa

 - ld, otvaranje tabele tippr, tippr2, bugfix [#29141](http://redmine.bring.out.ba/issues/29141)
 
1.3.20  2012-09-07, vsasa

 - ld, unos obračuna broj 2 [#29141](http://redmine.bring.out.ba/issues/29141)
 - ld, ostale korekcije
 - ks šifranik (kamatne stope) kreiranje prebačeno u dio sa šifranicima
 
1.3.19  2012-09-04, vsasa

 - ld, mip korekcija
 - fin, kalk, korekcije
 - fin, kamate, korekcije

1.3.18  2012-09-04, vsasa

 - ld, korekcija stampanja specifkacije

1.3.17  2012-09-01, hernad

 - test print fakture (txt, odt)

1.3.16  2012-08-31, hernad

 - FISC logiranje

1.3.15  2012-08-30, hernad

 - F18 corelib 3.5.2 - modstru numericka polja
 - DBF ver 0.8.4 - konvercija NC, MPC  numeric (N)  => float (B) 
 - FIN, ubačene opcije kamata iz modula KAM

1.3.14  2012-08-31, vsasa

 - fprint polog, limit na 100 [#28930](http://redmine.bring.out.ba/issues/28930)
 - ld, odvojeni parametri doprinosa na specifikacijama [#29023](http://redmine.bring.out.ba/issues/29023)
 - pos, unos ukupno uplaćenog iznosa kod izdavanja računa [#28876](http://redmine.bring.out.ba/issues/28876)
 - kalk, formiranje tabela rekap1, rekap2... [#29020](http://redmine.bring.out.ba/issues/29020)
 - kalk, kontvise() bugfix [#29030](http://redmine.bring.out.ba/issues/29030)
 - ld, opis naknada na kartici [#28843](http://redmine.bring.out.ba/issues/28843)

1.3.13  2012-08-30, hernad

 - test fakturisanje v1 OK!

1.3.12  2012-08-29, hernad

 - #29011 kontiranje nakon izbacivanja kalk->DatKurs ne radi - fix 

1.3.11  2012-08-29, hernad

 - #29009

1.3.10  2012-08-29, hernad

 - workaround za lose imenovanje tabela u ld, virm modulima

1.3.9  2012-08-28, hernad

 - fix, refactor alt_r

1.3.8  2012-08-28, hernad

 - alias pretvori u tabelu ako treba

1.3.7  2012-08-28, hernad

 - vratio dbf_get_rec() greskom izbrisan bug #28984

1.3.6  2012-08-28, hernad

 - ostao debug full sync u prosloj verziji
 
1.3.5  2012-08-28, hernad

 - init kreiranje tabela - modstru greske (nema tabele) ne ispadaj, nepostojece tabele dbf_stru ne ispadaj, repair_dbfs rekurzija off  

1.3.3  2012-08-26, hernad

 - full sync SERIABLE transaction

1.3.3  2012-08-26, hernad

 - FAKT stampa dokumenta opis out

1.3.2  2012-08-26, hernad

 - kalk datkurs -> out

1.3.1  2012-08-26, hernad

 - borba sa indeksima nakon full sync

1.3.0  2012-08-26, hernad
 
 - kalk_compress, fakt_compress, novi semaphore engine

1.1.7  2012-08-24, hernad
  
 - branch 1.1

1.1.6  2012-08-17, vsasa

 - fakt, štampa odt faktura od-do [#28910](http://redmine.bring.out.ba/issues/28910)
 - ugovori, labeliranje [#28918](http://redmine.bring.out.ba/issues/28918)
 - semafori, push ids - bugfix [#28915](http://redmine.bring.out.ba/issues/28915)
 - log_write() sa parametrom nivoa, ini parametar [#28722](http://redmine.bring.out.ba/issues/28722)
 
1.1.5  2012-08-11, vsasa

 - kalk, štampa kalkulacije cijena odt, bugfix [#28741](http://redmine.bring.out.ba/issues/28741)
 - fakt, ispis salda kupac/dobavljač, ubačen uslov idfirma [#28635](http://redmine.bring.out.ba/issues/28635)
 - PostojiSifra(), barkod pretraga ispravljena [#28860](http://redmine.bring.out.ba/issues/28860)
 - pos, unos stavki, polje ukupno sada vidljivo u pripremi [#28863](http://redmine.bring.out.ba/issues/28863)
 - pos, prikaz barkod polja unutar browse-a šifrarnika iz računa [#28862](http://redmine.bring.out.ba/issues/28862)
 - pos, unos inventure - bugfix [#28874](http://redmine.bring.out.ba/issues/28874)
 - roba, nedozvoljen unos duplog barkod-a u šifrarnik [#28788](http://redmine.bring.out.ba/issues/28788)
 - kalk, specifične opcije kod IP [#28834](http://redmine.bring.out.ba/issues/28834)
 - virm, generisanje virmana, fali id javnog prihoda [#28684](http://redmine.bring.out.ba/issues/28684)
 - ld, štampa ostalih specifikacija, delphi štampa 1000 stranica [#28897](http://redmine.bring.out.ba/issues/28897)
 - pos, storno po fiskalnom računu [#28864](http://redmine.bring.out.ba/issues/28864)
 - pos, provjera količine kod unosa računa [#28729](http://redmine.bring.out.ba/issues/28729)
 - provjera rednih brojeva dokumenta [#28847](http://redmine.bring.out.ba/issues/28847)
 - fakt, štampa fakture txt, polje opis [#28773](http://redmine.bring.out.ba/issues/28773)
 - pos, opcije sezona trenutno isključene [#28763](http://redmine.bring.out.ba/issues/28763)

1.1.4  2012-07-31, hernad

 - fiskalni racun FAKT IdTipDok=11, nacin placanja=VR [#28823](http://redmine.bring.out.ba/issues/28823)
 - rabat omogucen kod IdTipDok=27, ponuda u maloprodaji

1.1.3  2012-07-31, hernad

 - saga o barkodovima, ponovo vracen set confirm on [#28789](http://redmine.bring.out.ba/issues/28789)

1.1.2  2012-07-31, hernad

 - kratki barkodovi kod unosa pos racuna [#28789](http://redmine.bring.out.ba/issues/28789)

1.1.1  2012-07-31, hernad

 - [#28783](http://redmine.bring.out.ba/issues/28783)
 - inventura unos barkoda

1.1.0  2012-07-30, hernad
 
 - multi session F18 [#28770](http://redmine.bring.out.ba/issues/28770)
 - barcod ENTER [#28758](http://redmine.bring.out.ba/issues/28758)
 - fiskalne funkcije prodavca POS [#28755](http://redmine.bring.out.ba/issues/28755)

1.0.76 2012-07-25, hernad

 - [#28742](http://redmine.bring.out.ba/issues/28742) naljepnice PADR bug

1.0.75 2012-07-23, hernad

  - oper_id bug, fakt_doks partner prosiren, u slucaju data_width numerickih polja RaiseError [#28718](http://redmine.bring.out.ba/issues/28718)

1.0.74 2012-07-20, vsasa

  - kalk, 41-42 dokumenti, idtarifa sa dokumenta umjesto iz šifrarnika [#28707](http://redmine.bring.out.ba/issues/28707)
 
1.0.73 2012-07-20, vsasa

  - fiskalne funkcije flink dorađene [#28699](http://redmine.bring.out.ba/issues/28699)
  - ostale sitne dorade
 
1.0.72 2012-07-19, vsasa

  - fakt, štampa odt fakutre, datum ako je prazno upiši prazno u xml [#28577](http://redmine.bring.out.ba/issues/28577)
 
1.0.71 2012-07-16, vsasa

  - štampa fakture odt, txt, dužina za polje količine [#28639](http://redmine.bring.out.ba/issues/28639)
  - stanje kupaca i dobavljača za fakturu, saldo kupca dobavljača iz sql [#28635](http://redmine.bring.out.ba/issues/28635)
  - pos, inventura/nivelacija datum rada = datum dokumenta [#28640](http://redmine.bring.out.ba/issues/28640)
  - fakt, F5 - kontrola zbira dokumenta [#28578](http://redmine.bring.out.ba/issues/28578)
  - fakt, brisanje stavki pripreme, 1 stavku kopiraj podatke prije brisanja [#26924](http://redmine.bring.out.ba/issues/26924)
 
1.0.70 2012-07-11, vsasa

  - korekcija težinski barkodovi, fprint količina na 3 decimale [#28614](http://redmine.bring.out.ba/issues/28614)
 
1.0.69 2012-07-10, vsasa

  - pretraga barkod-a bugfix, težinski barkod [#28607](http://redmine.bring.out.ba/issues/28607)
                                              [#28609](http://redmine.bring.out.ba/issues/28609)
 
1.0.68 2012-07-10, vsasa

  - kalk, pos, čišćenje opcija inventure [#28525](http://redmine.bring.out.ba/issues/28525)
 
1.0.67 2012-07-09, vsasa

  - kalk, pos, čišćenje opcija inventure [#28525](http://redmine.bring.out.ba/issues/28525)
 
1.0.66 2012-07-03, vsasa

  - virm, generisanje virmana, bugfix [#28542](http://redmine.bring.out.ba/issues/28542)
 
1.0.65 2012-07-03, vsasa

  - kalk, fin stanje prodavnice uslov za robu [#28538](http://redmine.bring.out.ba/issues/28538)
  - kalk, fin, provjera postojanja dokumenta na serveru prije ažuriranja [#28540](http://redmine.bring.out.ba/issues/28540)
 
1.0.64 2012-07-02, vsasa

  - pos, opcije inventure, korekcije [#28525](http://redmine.bring.out.ba/issues/28525)
 
1.0.63 2012-06-27, vsasa

  - kalk, fin stanje prodavnice, mpv-popust kolona dodata 
 
1.0.62 2012-06-26, vsasa

  - kalk, štampanje labela sa cijenama [#28351](http://redmine.bring.out.ba/issues/28351)
  - kalk, fakt, pomoć sa rabatom kod izlaza i ulaza [#28464](http://redmine.bring.out.ba/issues/28464)
  - virm, generisanje virmana - čišćenje opcije [#28476](http://redmine.bring.out.ba/issues/28476)
 
1.0.61 2012-06-21, vsasa

  - kalk, kartica prodavnica [#28431](http://redmine.bring.out.ba/issues/28431)
  - fiskalne funkcije, prekid opcije čitanja fajla odgovora ALT_Q
  - roba, ubacio kolone mpc4 - mpc9 [#28446](http://redmine.bring.out.ba/issue/28446)
 
1.0.60 2012-06-21, vsasa

  - ld, korekcije [#28441](http://redmine.bring.out.ba/issues/28441)
                  [#28443](http://redmine.bring.out.ba/issues/28443)
                  [#28444](http://redmine.bring.out.ba/issues/28444)
  - fin, povrat naloga [#28445](http://redmine.bring.out.ba/issues/28445)
  - kalk, lista dokumenata uslov po kontima [#28437](http://redmine.bring.out.ba/issues/28437)
 
1.0.59 2012-06-20, vsasa

  - direktna štampa na epson, lpq ispravka [#28072](http://redmine.bring.out.ba/issues/28072)
 
1.0.58 2012-06-20, vsasa

  - kalk, povrat dokumenta u pripremu, bugfix [#28424](http://redmine.bring.out.ba/issues/28424)
 
1.0.57 2012-06-19, vsasa

  - fin, fakt, kalk, povrat dokumenta u pripremu [#28424](http://redmine.bring.out.ba/issues/28424)
 
1.0.56 2012-06-18, vsasa

  - fiskalne funkcije, čišćenja [#28409](http://redmine.bring.out.ba/issues/28409)
  - fakt, spajanje stavki kod 12 -> 11 [#28370](http://redmine.bring.out.ba/issues/28370)
  - fakt, unos dodatnog teksta, hendliranje [#28407](http://redmine.bring.out.ba/issues/28407)
 
1.0.55 2012-06-15, vsasa

  - fin, datum valute, bugfix
 
1.0.54 2012-06-15, vsasa

  - fakt, setovanje veze sa fiskalnim računom, bugfix [#28410](http://redmine.bring.out.ba/issues/28410)
 
1.0.53 2012-06-15, vsasa

  - pos, update broj fiskalnog računa nakon štampe, korekcije
  - kalk, predispozicija, svođenje mpc sa porezom, korekcije

1.0.52 2012-06-15, vsasa

  - pos, ažuriranje bez rezervacije broja [#28397](http://redmine.bring.out.ba/issues/28397)

1.0.51 2012-06-14, vsasa

  - pos, korekcija izvještaja i indeksnih fajlova [#28396](http://redmine.bring.out.ba/issues/28396)
 
1.0.50 2012-06-14, vsasa

  - fakt, mp faktura vrsta plaćanja [#28383](http://redmine.bring.out.ba/issues/28383)
  - kalk, mp predispozicija u odt [#28322](http://redmine.bring.out.ba/issues/28322)
  - fiskalne opcije prebačene na parametre po korisniku [#28380](http://redmine.bring.out.ba/issues/28380)
  - fakt, predračun u račun iz pripreme [#28345](http://redmine.bring.out.ba/issues/28345)
 
1.0.49 2012-06-12, vsasa

  - pos, korekcije unosa [#28361](http://redmine.bring.out.ba/issues/28361)
                         [#28360](http://redmine.bring.out.ba/issues/28360)
                         [#28358](http://redmine.bring.out.ba/issues/28358)
  - rnal, podatak o naljepnici [#28362](http://redmine.bring.out.ba/issues/28362)
  - fiskalne opcije fprint, brisanje plu kodova [#28365](http://redmine.bring.out.ba/issues/28365)
  - kalk, fakt, barkodovi [#28363](http://redmine.bring.out.ba/issues/28363)
  - kalk, ispis barkodova na dokumentima [#28364](http://redmine.bring.out.ba/issues/28364)
  - pos, storniranje računa [#28366](http://redmine.bring.out.ba/issues/28366)

1.0.48 2012-06-11, vsasa

  - težinski barkod [#28340](http://redmine.bring.out.ba/issues/28340)
  - pos, fiskalne opcije za prodavača [#28348](http://redmine.bring.out.ba/issues/28348)
  - pos, unos računa bez izlaska iz pripreme [#28350](http://redmine.bring.out.ba/issues/28350)
  - sastavnice, loša postavka semafora - bugfix [#28343](http://redmine.bring.out.ba/issues/28343)
  - pos, mnoštvo sitnih korekcija

1.0.47 2012-06-11, vsasa

  - pos, unos računa, sređivanje forme [#28335](http://redmine.bring.out.ba/issues/28335)
  - kalk, štampanje labela sa cijenama [#28333](http://redmine.bring.out.ba/issues/28333)
  - ostale sitne dorade

1.0.46 2012-06-08, vsasa

  - pos, brojač dokumenta na osnovu sql/db [#28328](http://redmine.bring.out.ba/issues/28328)
  - ostale sitne dorade

1.0.45 2012-06-07, vsasa

  - kalk, unos dokumenanata 80 i 81, sređivanje forme [#27455](http://redmine.bring.out.ba/issues/27455)
  - ostale sitne dorade

1.0.44 2012-06-07, vsasa

  - semafori i šifre koje počinju sa "#" [#28084](http://redmine.bring.out.ba/issues/28084)
  - fakt, generisanje faktura na osnovu ponuda, opcija "F"  [#28271](http://redmine.bring.out.ba/issues/28271)
  - štampanje delphirb procesa odvojeno na unix-u [#28311](http://redmine.bring.out.ba/issues/28311)
 
1.0.43 2012-06-01, vsasa

  - fakt, opcija "T" refresh [#28262](http://redmine.bring.out.ba/issues/28262)
 
1.0.42 2012-06-01, vsasa

  - fakt, setovanje prikaza cijena [#28260](http://redmine.bring.out.ba/issues/28260)
 
1.0.41 2012-05-31, hernad  
 
  - 1024 x 1280 rezolucija font setovan na 24

1.0.40 2012-05-31, vsasa

  - f18 glavni meni, redizajn koda [#28235](http://redmine.bring.out.ba/issues/28235)
  - f18, čekiranje tabela [#28235](http://redmine.bring.out.ba/issues/28235)
  - fakt, realizacija partnera [#28233](http://redmine.bring.out.ba/issues/28233)
  - fakt, prikaz totala dokumenta u pripremi [#28094](http://redmine.bring.out.ba/issues/28094)
 
1.0.39 2012-05-30, vsasa

  - kalk, ažuriranje dokumenta tipa "97" [#28196](http://redmine.bring.out.ba/issues/28196)
  - kalk, prenos dokumenta "97" u fakt isključen za sada [#28194](http://redmine.bring.out.ba/issues/28194)
  - fakt, parametri prikaza cijena - bugfix [#28189](http://redmine.bring.out.ba/issues/28189)
 
1.0.38 2012-05-28, vsasa

  - fakt, setovanje fiskalnog računa nakon štampe [#28160](http://redmine.bring.out.ba/issues/28160)
  - fakt, štampa template-a fakture [#28154](http://redmine.bring.out.ba/issues/28154)
 
1.0.37 2012-05-25, vsasa

  - kalk, paginacija dokumenata [#28146](http://redmine.bring.out.ba/issues/28146)
  - fin, unos datuma valute - bugfix [#28151](http://redmine.bring.out.ba/issues/25151)
  - ostale sitne korekcije
 
1.0.36 2012-05-21, vsasa

  - direktna štampa na epson štampače [#28072](http://redmine.bring.out.ba/issues/28072)
  - fin, kontrola zbira [#25823](http://redmine.bring.out.ba/issues/25823)
  - ostale sitne korekcije
 
1.0.35 2012-05-18, vsasa

  - fin, kalk, početna stanja, korekcije [#28021](http://redmine.bring.out.ba/issues/28021)
  - fin, kompenzacija [#28029](http://redmine.bring.out.ba/issues/28029)
  - ePDV, avnansne fakture [#27954](http://redmine.bring.out.ba/issues/27954)
  - fiskalne funkcije [#27052](http://redmine.bring.out.ba/issues/27052)
  - to_us_encoding [#27344](http://redmine.bring.out.ba/issues/27344)
  - fakt, ažuriranje duplog dokumenta [#28057](http://redmine.bring.out.ba/issues/28057)
  - kalk, unos dokumenta tipa "10" raširen ekran [#27455](http://redmine.bring.out.ba/issues/27455)
  - mat, izvještaj po ročnosti korigovan [#28044](http://redmine.bring.out.ba/issues/28044)
 
1.0.34 2012-05-14, vsasa

  - rnal, korekcije [#25977](http://redmine.bring.out.ba/issues/25977)
  - kalk, stavka - protustavka, bugfix [#27665](http://redmine.bring.out.ba/issues/27665)
  - kalk, kontrola cijena prije štampe [#27953](http://redmine.bring.out.ba/issues/27953)
  - fakt, generisanje faktura na osnovu ugovora [#28021](http://redmine.bring.out.ba/issues/28021)
 
1.0.33 2012-05-11, vsasa

  - mat, semafori v.1.1 [#27986](http://redmine.bring.out.ba/issues/27986)
  - ostale sitne korekcije
 
1.0.32 2012-05-11, vsasa

  - ld, beneficirani staž po više stopa, specifikacija, mip itd.. [#27909](http://redmine.bring.out.ba/issues/27909)
  - ld, mip, olp, pregled, prvi seek ispravljen [#27950](http://redmine.bring.out.ba/issues/27950)
  - rnal, semafori, maske za unos modifikovane [#27978](http://redmine.bring.out.ba/issues/27978)
  - import elba, sql/db parametar
  - ostale sitne korekcije ...

1.0.31 2012-05-09, vsasa

  - ld, beneficirani staž po više stopa, specifikacija, mip itd.. [#27909](http://redmine.bring.out.ba/issues/27909)
 
1.0.30 2012-05-08, vsasa

  - ld, beneficirani staž po više stopa [#27909](http://redmine.bring.out.ba/issues/27909)
  - rnal, semafori 1.1 [#25915](http://redmine.bring.out.ba/issues/25915)
  - sastavnice [#27933](http://redmine.bring.out.ba/issues/27933)
 
1.0.29 2012-05-07, vsasa, hernad

  - linux terminus podrska za 1440x900, 1280x800, 1280x1024, 1024x768, 800x600 [#27880](http://redmine.bring.out.ba/issues/27880)
  - ld, beneficirani staž po više stopa [#27909](http://redmine.bring.out.ba/issues/27909)
  - kompenzacije, proširen broj dokumenta [#27906](http://redmine.bring.out.ba/issues/27906)

1.0.28 2012-05-07, vsasa

  - kalk fakt prenos proizvodnja bugfix [#27902](http://redmine.bring.out.ba/issues/27902)
  - kalk F6 kartica prodavnice bugfix [#27896](http://redmine.bring.out.ba/issues/27896)
 
1.0.27 2012-05-04, vsasa

  - ld, specifkacija, ako nema obračuna poruka [#27868](http://redmine.bring.out.ba/issues/27868)
  - barkod parametri u modulu FAKT [#27796](http://redmine.bring.out.ba/issues/27796)
  - FAKT, KALK, opcije smeća [#27874](http://redmine.bring.out.ba/issues/27874)
  - ostale sitne korekcije
 
1.0.26 2012-05-03, vsasa

  - fakt, tekuća vrijednost za rok plaćanja stavljena u funkciju [#27858](http://redmine.bring.out.ba/issues/27858)
  - ostale sitne korekcije
 
1.0.25 2012-05-03, vsasa

  - fakt, unos destinacije na fakturi [#27851](http://redmine.bring.out.ba/issues/27851)
 
1.0.24 2012-05-03, vsasa

  - fakt, alt+P iz pripreme, bugfix [#27843](http://redmine.bring.out.ba/issues/27843)
  - fakt, import podataka udaljena razmjena - korekcije [#27846](http://redmine.bring.out.ba/issues/27846)
 
1.0.23 2012-05-03, vsasa

  - prenos fakt->fakt po broju dokumenta [#27833](http://redmine.bring.out.ba/issues/27833)
  - kalk, kartica artikla F5 [#27802](http://redmine.bring.out.ba/issues/27802)
 
1.0.22 2012-04-27, vsasa

  - fakt, pregled dokumenata [#27813](http://redmine.bring.out.ba/issues/27813)
  - virm, semafori [#27815](http://redmine.bring.out.ba/issues/27815)
 
1.0.21 2012-04-26, vsasa

  - alt+R, alt+S opcije bugfix [#27804](http://redmine.bring.out.ba/issues/27804)
  - odt konvertovanje u pdf [#27662](http://redmine.bring.out.ba/issues/27662)
  - ld specifikacija 1000 stranica - bugfix [#27809](http://redmine.bring.out.ba/issues/27809)
  - štampa template fajlova, provjera verzije template-a [#27810](http://redmine.bring.out.ba/issues/27810)
  - ostale sitne korekcije
 
1.0.20 2012-04-25, vsasa

  - hcp, xml encoding kod slanja xml fajla [#27789](http://redmine.bring.out.ba/issues/27789)
  - kalk, prikaz fin naloga jednovalutno [#27786](http://redmine.bring.out.ba/issues/27786)
  - pos, prikaz računa opcija "P" ispravljena [#27787](http://redmine.bring.out.ba/issues/27787)
 
1.0.19 2012-04-25, vsasa

  - pos, korekcije [#27773](http://redmine.bring.out.ba/issues/27773)
 
1.0.18 2012-04-24, vsasa

  - kalk, brojač po kontima [#27768](http://redmine.bring.out.ba/issues/27768)
  - pos, korekcije semafora [#27773](http://redmine.bring.out.ba/issues/27773)
  - fiskalne funkcije tremol, korekcije [#27771](http://redmine.bring.out.ba/issues/27771)

1.0.17 2012-04-24, vsasa

  - pos, import šifrarnika robe iz fmk-pos [#27751](http://redmine.bring.out.ba/issues/27751)

1.0.16 2012-04-23, vsasa

  - pos, import šifrarnika robe iz fmk-pos

1.0.15 2012-04-23, vsasa

  - fakt, import podataka, udaljene lokacije - korekcije
 
1.0.14 2012-04-23, vsasa

  - pos, indeksi pomoćnih tabela [#27743](http://redmine.bring.out.ba/issues/27743)
  - fin, otvorene stavke [#27742](http://redmine.bring.out.ba/issues/27742)
  - kalk, šeme kontiranja, promjena definicije tabela [#27745](http://redmine.bring.out.ba/issues/27745)
 
1.0.13 2012-04-23, vsasa

  - fakt, ispis barkodova [#27731](http://redmine.bring.out.ba/issues/27731)
  - fin, parametri sql [#27733](http://redmine.bring.out.ba/issues/27733)
  - kalk, prenos iz fakt [#27740](http://redmine.bring.out.ba/issues/27740)
 
1.0.12 2012-04-20, vsasa

  - kalk, ispis zaglavlja [#27680](http://redmine.bring.out.ba/issues/27680)
  - tops, update fisc_rn polje, korekcija [#27721](http://redmine.bring.out.ba/issues/27721)
  - fakt, default radna jedinica [#27724](http://redmine.bring.out.ba/issues/27724)
  - fin, asistent otvorenih stavki stavljen u funkciju
 
1.0.11 2012-04-19, vsasa

  - fakt, radna jedinica na left 2 [#27710](http://redmine.bring.out.ba/issues/27710)
  - fakt, stampa barkodova, labeliranje [#27715](http://redmine.bring.out.ba/issues/27715)
  - hcp unix verzija, korekcije [#27714](http://redmine.bring.out.ba/issues/27714)
  - ostale sitne korekcije

1.0.10  2012-04-18, hernad

  - kompenz + odt stampa

1.0.9 2012-04-18, vsasa, hernad

  - kompenzacije [#27681](http://redmine.bring.out.ba/issues/27681)

1.0.8 2012-04-17, hernad

 - close all, start.exe 

1.0.6 2012-04-17, vsasa

  - odt štampa dokumenta, korekcije [#26262](http://redmine.bring.out.ba/issues/26262)
  - odt template lokacija za unix definisana
  - kalk, razmjena tops->kalk, korekcije [#27085](http://redmine.bring.out.ba/issues/27085)

1.0.5 2012-04-16, vsasa

  - ld, epdv, korekcije [#27597](http://redmine.bring.out.ba/issues/27597)
  - ostale sitne korekcije

1.0.4 2012-04-13, vsasa, hernad

  - idemo odmah na 1.0.4 ver posto je vsasa još nešto radio

1.0.3 2012-04-13, vsasa, hernad

  - [#27608](http://redmine.bring.out.ba/issues/27608)
  - [#27606](http://redmine.bring.out.ba/issues/27606)
 
1.0.2 2012-04-13, hernad

  - debug lager lista, dbf_pack feature [#27600](http://redmine.bring.out.ba/issues/27600)

1.0.0 2012-04-13, hernad

  - debug valuta (fakt_doks->dinem) [#27598](http://redmine.bring.out.ba/issues/27598)

0.9.99 2012-04-13, hernad

  - vratolomije

0.9.98 2012-04-13, hernad 

  - [#27590](http://redmine.bring.out.ba/issues/27590)

0.9.97 2012-04-13, hernad

  - [#27589](http://redmine.bring.out.ba/issues/27589)

0.9.96 2012-04-13, vsasa

  - kreiranje tabela, set_a_dbfs sređivanje (semafori 1.1) [#27575](http://redmine.bring.out.ba/issues/27575)
  - sitne korekcije

0.9.95 2012-04-12, vsasa

  - ukinuo alerte u set_a_dbfs... 
  - kalk, ažuriranje, povrat dokumenta (semafori 1.1) [#27518](http://redmine.bring.out.ba/issues/27518)
  - kalk, export podataka za POS [#27085](http://redmine.bring.out.ba/issues/27085)
  - pos, import podataka iz KALK [#27085](http://redmine.bring.out.ba/issues/27085)
  - sitne korekcije

0.9.94 2012-04-07, hernad

  - merge 0.9.81

0.9.93 2012-04-04, hernad

  - merge with 0.9.78
  - FAKT semaphores v1.1

0.0.90 2012-03-27, hernad

  - merge semaphore v1.1 brancha, haos-2 - ovo ne radi

0.9.81 2012-04-07, hernad

  - common: [#27474](http://redmine.bring.out.ba/issues/27474)

0.9.80 2012-04-05, vsasa
 
  - FIN, KALK, FAKT ažuriranje, jedna transakcija [#27435](http://redmine.bring.out.ba/issues/27435)
  - LD, obrazac JS-3400 [#27178](http://redmine.bring.out.ba/issues/27178)
  - LD, obrazac PMIP-1024 [#27179](http://redmine.bring.out.ba/issues/27179)

0.9.79 2012-04-04, vsasa
 
  - semafori, lock bugfix [#27399](http://redmine.bring.out.ba/issues/27399)

0.9.78 2012-04-03, vsasa
 
  - LD korekcije (izvještaji, unos, brisanje kredita, itd...) [#27390](http://redmine.bring.out.ba/issues/27390)
  - ostale sitne korekcije

0.9.77 2012-03-29, vsasa
 
  - LD zbrka sa našim slovima [#27310](http://redmine.bring.out.ba/issues/27310)
  - uvedena tabela adresara [#27320](http://redmine.bring.out.ba/issues/27320)

0.9.76 2012-03-28, vsasa
 
  - parametri FAKT, zbrka sa našim slovima [#27263](http://redmine.bring.out.ba/issues/27263)
  - modul FAKT, štampa fakture nakon fiskalnog računa [#27248](http://redmine.bring.out.ba/issues/27248)

0.9.75 2012-03-28, vsasa
 
  - modul KALK, obrada dokumenata 96/16 [#27284](http://redmine.bring.out.ba/issues/27284)
  - modul KALK, automtasko ažuriranje fakt dokumenata [#27286](http://redmine.bring.out.ba/issues/27286)
>>>>>>> origin/semaphores_v1.0

0.9.74 2012-03-27, vsasa
 
  - modul FAKT, adresa u parametrima [#27249](http://redmine.bring.out.ba/issues/27249)

0.9.73 2012-03-26, vsasa
 
  - modul FAKT/KALK, sql parametri [#27223](http://redmine.bring.out.ba/issues/27223)
  - modul KALK, sitne korekcije

0.9.72 2012-03-25, hernad
 
  - close all print [#27235](http://redmine.bring.out.ba/issues/27235)

0.9.71 2012-03-23, vsasa
 
  - modul LD, radnici odradjeni više puta za jedan mjesec, korekcija izvještaja [#27220](http://redmine.bring.out.ba/issues/27220)
  - sitne korekcije

0.9.70 2012-03-23, vsasa
 
  - modul LD, radnici odradjeni više puta za jedan mjesec [#27220](http://redmine.bring.out.ba/issues/27220)
  - modul FAKT, fiskalni računi za partnere oslobođene po članu, ispis podataka [#27221](http://redmine.bring.out.ba/issues/27221)

0.9.69 2012-03-23, vsasa
 
  - modul LD, greška sa EVAL izrazima [#27199](http://redmine.bring.out.ba/issues/27199)

0.9.68 2012-03-22, vsasa
 
  - fakt, globalni brojač, finalizirana opcija [#27166](http://redmine.bring.out.ba/issues/27166)

0.9.67 2012-03-21, vsasa
 
  - fakt, globalni brojač, korekcije [#27166](http://redmine.bring.out.ba/issues/27166)
  - sifk/sifv, korekcija bug-a ! [#27174](http://redmine.bring.out.ba/issues/27174)
  - ostale sitne korekcije

0.9.66 2012-03-15, hernad
 
  - rezolucija 30 x 100 Lucida Console za manje rezolucije

0.9.65 2012-03-15, hernad, vsasa
  
  - mogućnost podešenja fontova i rezolucije [#27127](http://redmine.bring.out.ba/issues/27127)
  - korekcija IDS algoritma kod semafora [#27131](http://redmine.bring.out.ba/issues/27131)
  - sitne korekcije

0.9.64 2012-03-15, vsasa

  - fakt, brojač dokumenata [#26954](http://redmine.bring.out.ba/issues/26954)
  - korekcije ostalih sitnih grešaka

0.9.63 2012-03-11, vsasa

  - kontrola integriteta podataka fmk [#27063](http://redmine.bring.out.ba/issues/27063)
  - modul POS, cišćenje, semafori [#27077](http://redmine.bring.out.ba/issues/27077)

0.9.62 2012-03-07, vsasa

  - modul MAT, korekcija početnog stanja i proširenje polja rbr [#26989](http://redmine.bring.out.ba/issues/26989)
 
0.9.61 2012-03-05, vsasa

  - modul MAT, korekcije i sitne dorade [#26970](http://redmine.bring.out.ba/issues/26970)
  - modul FAKT, grupisanje partnera po vrsti isporuke robe [#26952](http://redmine.bring.out.ba/issues/26952)
  - modul FAKT, količinski pregled isporuka robe [#26953](http://redmine.bring.out.ba/issues/26953)

0.9.60 2012-03-02, vsasa

  - modul FAKT, ispravka bug-a sa fiskalnim opcijama [#26950](http://redmine.bring.out.ba/issues/26950) 

0.9.59 2012-02-29, vsasa

  - modul LD, korekcije [#26643](http://redmine.bring.out.ba/issues/26643) 
  - refactor fiskalnih parametara [#26250](http://redmine.bring.out.ba/issues/26250)
  - korekcije sitnih grešaka...

0.9.58 2012-02-28, vsasa

  - modul LD, korekcija obracuna plate [#26643](http://redmine.bring.out.ba/issues/26643) 
  - štampanje odt izvještaja [#26878](http://redmine.bring.out.ba/issues/26878)
  - korekcije sitnih grešaka...

0.9.57 2012-02-24, vsasa

  - modul KALK, izvještaji TKV [#26698](http://redmine.bring.out.ba/issues/26698) i TKM [#26699](http://redmine.bring.out.ba/issues/26699)
  - modul KALK, štampa odt obrazaca kalkulacija cijena za vp [#26700](http://redmine.bring.out.ba/issues/26700) i mp [#26701](http://redmine.bring.out.ba/issues/26701)
  - korekcije sitnih grešaka...

0.9.56 2012-02-22, vsasa

  - modul LD, generisanje obrazaca MIP/GIP/OLP [#26674](http://redmine.bring.out.ba/issues/26674)
  - modul KALK, korigovana obrada dokumenta tip-a 41, 42 [#26824](http://redmine.bring.out.ba/issues/26824)
  - korekcije sitnih grešaka...

0.9.55 2012-02-20, vsasa

  - modul KALK, razmjena podataka između udaljenih lokacija [#26695](http://redmine.bring.out.ba/issues/26695) rewrite opcije.
  - korekcije sitnih grešaka

0.9.54 2012-02-15, hernad

  - [#26732](http://redmine.bring.out.ba/issues/26732)

0.9.53 2012-02-15, hernad, vsasa

 - CRITICAL BUG: [#26722](http://redmine.bring.out.ba/issues/26722) broj veze fin,  [#26728](http://redmine.bring.out.ba/issues/26728) polja otvorene stavke

0.9.52 2012-02-14, hernad

 - [#26688](http://redmine.bring.out.ba/issues/26688) fin povrat

0.9.51  2012-02-13, vsasa

 - modul LD, ciscenje (vise obracuna, sihtarice, itd...)
 - moduli KALK, FIN, korekcija opcije povrata dokumenta
 - modul OS, popisna lista - export u dbf/odt

0.9.50  2012-02-10, vsasa

 - korekcija semafor funkcija u FIN, KALK, FAKT, azuriranje povrat, upisivanje u semafor tabelu

0.9.49  2012-02-09, vsasa

  - korekcija fiskalnih funkcija fprint za unix varijantu

0.9.48  2012-02-08, vsasa

  - dorade na KALK proizvodnja

0.9.47  2012-02-07, vsasa

  - modul FIN, ciscenje opcija povrata dokumenta u pripremu [#26549](http://redmine.bring.out.ba/issues/26549)
  - modul VIRM, stampanje virmana omoguceno na op.sis. Windows
  - modul KALK, ciscenje funkcija proizvodnje
  - ostalo ciscenje, tipke ALT+R (trazi/zamijeni) omogucene
  
0.9.46  2012-02-03, vsasa

  -  modul SII spojen sa OS-om [#25358](http://redmine.bring.out.ba/issues/25358)

0.9.45  2012-02-03, vsasa

  -  modul OS stavljen u funkciju [#25358](http://redmine.bring.out.ba/issues/25358)

0.9.44  2012-02-02, hernad

  -  IOS ručno zatvaranje [#26495](http://redmine.bring.out.ba/issues/26495)

0.9.43  2012-01-30, vsasa

  - bitne opcije modula VIRM osposobljene, generisanje virmana iz ld-a, rekapitulacija uplata

0.9.42  2012-01-25, vsasa

  - modul Fin, generisanje pocetnog stanja u radno podrucje
  - nove tabele na sql/db strani pkonto, vrstep
  - modul Fakt, vrste placanja na dokumentu 10 [#26382](http://redmine.bring.out.ba/issues/26382)
  - modul ePDV, povrat naloga osposobljen
  - modul KALK, povrat dokumenta osposobljen
  - ostala sitna ciscenja

0.9.41  2012-01-23, vsasa
  
  - generalno čišćenje funkcija modula FAKT
  - update server db 4.1.4 (nepostojeća polja) [#26350](http://redmine.bring.out.ba/issues/26350)
  - template za štampu odt fakture prebačen na lokaciju c:\knowhowERP\template
  - init port modul VIRM [#25359](http://redmine.bring.out.ba/issues/25359)

0.9.40  2012-01-19, hernad

  - org_pdv_broj
  - haos sa parametrima  [#26300](http://redmine.bring.out.ba/issues/26300)
  - LD MIP export [#26298](http://redmine.bring.out.ba/issues/26298)

0.9.39  2012-01-17, vsasa

  - fakt, ciscenje od debug informacija, modstru, sinhro itd...
  - fakt, ciscenje opcije stampe na fiskalni uredjaj
  - fakt, ciscenje opcije stampe odt fakture

0.9.38  2012-01-16, hernad
 
  - vsasa IOS update tekst
  - hernad scripts/build_release.sh

0.9.37  2012-01-06, vsasa, LD specif

  - [#26099](http://redmine.bring.out.ba/issues/26099)

0.9.36  2012-01-04, hernad, test_sem_1 bug

  - [#26059](http://redmine.bring.out.ba/issues/26059)

0.9.35  2012-01-04, hernad, dbf ver 0.4.1

  - [#26048](http://redmine.bring.out.ba/issues/26048)
  - dbf ver 0.4.1

0.9.33  2011-12-30, vsasa, ld, ciscenje, stavljanje u funkciju
  
  - [#26010](http://redmine.bring.out.ba/issues/26010)

0.9.32  2011-12-30, hernad, v2 dbf refaktoring

  - [#25990](http://redmine.bring.out.ba/issues/25990)
  - [#25997](http://redmine.bring.out.ba/issues/25997)

0.9.31  2011-12-29, hernad, relogin

  - [#25889](http://redmine.bring.out.ba/issues/25889)

0.9.30  2011-12-29, vsasa, MAT v2 ročni intervali

  - [#25951](http://redmine.bring.out.ba/issues/25951) - podešavanje rezolucije ekrana u ini fajlu
  - [#25923](http://redmine.bring.out.ba/issues/25923) - modul MAT, specifikacija artikala po ročnim intervalima
  - ostale sitne korekcije na mat izvještajima i slično

0.9.29  2011-12-28, hernad, fin azuriranje

  - [#25927](http://redmine.bring.out.ba/issues/25927) - ispravka psuban_suban, otvorene stavke slati na server

0.9.28  2011-12-28, hernad, MAT-IDKONTO verzija

  - Napomena: FIN azuriranje ne radi, verzija namjenjena za MAT korisnike
  - [#25931](http://redmine.bring.out.ba/issues/25931) vsasa, mat, condens stampa ne radi
  - [#25929](http://redmine.bring.out.ba/issues/25929) vsasa, mat, sinhronizacija sifrarnika robe, polje idkonto
  - [#25909](http://redmine.bring.out.ba/issues/25909) hernad, fakt_offset
  - [#25905](http://redmine.bring.out.ba/issues/25905) hernad, bug report v3
  - [#25928](http://redmine.bring.out.ba/issues/25928) vsasa, mat, korekcija izvjestaja

0.9.27  2011-12-27, hernad

  - [#25888](http://redmine.bring.out.ba/issues/25888), db parametri
  - [#25750](http://redmine.bring.out.ba/issues/25750), bug_report iter-2
  - [#25881](http://redmine.bring.out.ba/issues/25881), check_server_db
  - [#25815](http://redmine.bring.out.ba/issues/25815), modstru vise ne ispada kada nema tabele, cre_all_fin iter-1
  - REQUIRED server db: 4.0.8

0.9.26  2011-12-24, hernad fetch_metric, set_metric

  - [#25877](http://redmine.bring.out.ba/issues/25877)
  - NAPOMENA: required server db: 4.0.6

0.9.25  2011-12-23, "segmentation fault" problem otklonjen, fin, kalk pametni semafori

  - [#25791](http://redmine.bring.out.ba/issues/25791)
  - [#25871](http://redmine.bring.out.ba/issues/25871)

0.9.24  2011-12-23, hernad, "MAT" release

0.9.23  2011-12-23, vsasa, otklonjena greška kod funkcija štampe 

 - [#25768](http://redmine.bring.out.ba/issues/25768)

0.9.22  2011-12-22, hernad,, sifk kreiranje
 
 - [#25829](http://redmine.bring.out.ba/issues/25829)
 - niz promjena vsasa/MAT

0.9.21  2011-12-21, hernad, fakt->fin

 - my_usex faktfin [#25795](http://redmine.bring.out.ba/issues/25795)

0.9.20  2011-12-21, hernad, refactoring scatter/gather

 - gather/scatter out [#25776](http://redmine.bring.out.ba/issues/25776)
 - "--test" switch [#25788](http://redmine.bring.out.ba/issues/25788)
 - sifk/sifv [#25721](http://redmine.bring.out.ba/issues/25721)
 - refactor-1 code_browse.prg [#25789](http://redmine.bring.out.ba/issues/25789)
 - ... i još "mali milion ciscenja i promjena zabiljezenih na commit log-u F18"

0.9.18  2011-12-14, hernad f18_start_print/f18_end_print
 
 - [#25684](http://redmine.bring.out.ba/issues/25684)

0.9.17  2011-12-13, hernad, bug report

  - [#25663](http://redmine.bring.out.ba/issues/25663)

0.9.16  2011-12-12, hernad, test init

  - modstru_test [#25648](http://redmine.bring.out.ba/issues/25648)

0.9.15  2011-12-12, hernad haos_2

  - uvodim mouse podrsku [#25300](http://redmine.bring.out.ba/issues/25300)
  - legacy [#25640](http://redmine.bring.out.ba/issues/25640)

0.9.14  2011-12-09, hernad FAKT

  - inteligentnije azuriranje FAKT [#25631](http://redmine.bring.out.ba/issues/25631)

0.9.13  2011-12-09, hernad FAKT
 
  - FAKT naša slova [#25622](http://redmine.bring.out.ba/issues/25622)

0.9.9,  2011-12-07, hernad, cistim haos, init

  - refactoring init replace => update_rec_dbf_and_server
 
0.9.8, 2011-12-06, hernad, pravim haos

  - my_use default shared - trazi rlock
    sada se pojavljuje milion "lock required"

  - uvodim get_rec, update_rec

0.9.7, 2011-12-06, hernad,  sem_ver uklonjeno iz semafora

  - [sem_ver #25395](http://redmine.bring.out.ba/issues/25395)
    

0.9.5, 2011-12-02, vsasa, moduli FIN, KALK, FAKT stavljeni u funkciju 

0.9.0, 2011-11-25, hernad, init changelog 

    #define F18_VER  "0.9.5"
    #define F18_VER_DATE  "02.12.2011"

--------------------

Contributor(s):

* vsasa - Saša Vranić, sasa.vranic@bring.out.ba
* hernad - Ernad Husremović, ernad.husremovic@bring.out.ba
