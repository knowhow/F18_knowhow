CREATE SCHEMA p15;

ALTER SCHEMA p15 OWNER TO admin;

CREATE TABLE p15.roba (
    id character(10) NOT NULL,
    match_code character(10),
    sifradob character(20),
    naz character varying(250),
    jmj character(3),
    idtarifa character(6),
    nc numeric(18,8),
    vpc numeric(18,8),
    mpc numeric(18,8),
    tip character(1),
    carina numeric(5,2),
    opis text,
    vpc2 numeric(18,8),
    mpc2 numeric(18,8),
    mpc3 numeric(18,8),
    k1 character(4),
    k2 character(4),
    n1 numeric(12,2),
    n2 numeric(12,2),
    plc numeric(18,8),
    mink numeric(12,2),
    _m1_ character(1),
    barkod character(13),
    zanivel numeric(18,8),
    zaniv2 numeric(18,8),
    trosk1 numeric(15,5),
    trosk2 numeric(15,5),
    trosk3 numeric(15,5),
    trosk4 numeric(15,5),
    trosk5 numeric(15,5),
    fisc_plu numeric(10,0),
    k7 character(4),
    k8 character(4),
    k9 character(4),
    strings numeric(10,0),
    idkonto character(7),
    mpc4 numeric(18,8),
    mpc5 numeric(18,8),
    mpc6 numeric(18,8),
    mpc7 numeric(18,8),
    mpc8 numeric(18,8),
    mpc9 numeric(18,8)
);


ALTER TABLE p15.roba OWNER TO admin;

GRANT ALL ON SCHEMA p15 TO xtrole;
GRANT ALL ON TABLE p15.roba TO xtrole;
