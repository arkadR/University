DROP TABLE BANDY;
DROP TABLE FUNKCJE;
DROP TABLE KOCURY;
DROP TABLE WROGOWIE;
DROP TABLE WROGOWIE_KOCUROW;


create table BANDY
(
    nr_bandy   NUMBER(2)
        CONSTRAINT bnd_nrb_pk PRIMARY KEY,
    nazwa      VARCHAR2(20)
        CONSTRAINT bnd_naz_req NOT NULL,
    teren      VARCHAR2(15)
        CONSTRAINT bnd_ter_unq UNIQUE,
    szef_bandy VARCHAR2(15)
        CONSTRAINT bnd_szf_uq UNIQUE
);

create table FUNKCJE
(
    funkcja   VARCHAR2(20)
        CONSTRAINT fun_fun_pk PRIMARY KEY,
    min_myszy NUMBER(3)
        CONSTRAINT fun_min_rng CHECK ( min_myszy > 5 ),
    max_myszy NUMBER(3)
        CONSTRAINT fun_max_max CHECK ( max_myszy < 200 ),
    CONSTRAINT fun_max_min CHECK ( max_myszy >= min_myszy )
);

create table WROGOWIE
(
    imie_wroga       VARCHAR2(15)
        CONSTRAINT wrg_imi_pk PRIMARY KEY,
    stopien_wrogosci NUMBER(2)
        CONSTRAINT wrg_stp_rng CHECK ( stopien_wrogosci BETWEEN 1 AND 10),
    gatunek          VARCHAR2(15),
    lapowka          VARCHAR2(20)
);

create table KOCURY
(
    imie            VARCHAR2(15)
        CONSTRAINT koc_imi_req NOT NULL,
    plec            VARCHAR2(1)
        CONSTRAINT koc_plc_val CHECK ( plec IN ('M', 'D') ),
    pseudo          VARCHAR2(15)
        CONSTRAINT koc_psd_pk PRIMARY KEY,
    funkcja         VARCHAR2(10)
        CONSTRAINT koc_fun_fk REFERENCES FUNKCJE (funkcja),
    szef            VARCHAR2(15)
        CONSTRAINT koc_szf_fk REFERENCES KOCURY (pseudo),
    w_stadku_od     DATE DEFAULT SYSDATE,
    przydzial_myszy NUMBER(3),
    myszy_extra     NUMBER(3),
    nr_bandy        NUMBER(2)
        CONSTRAINT koc_nrb_fk REFERENCES BANDY (nr_bandy)
);

create table WROGOWIE_KOCUROW
(
    pseudo         VARCHAR2(15)
        CONSTRAINT wrk_psd_fk REFERENCES KOCURY (pseudo),
    imie_wroga     VARCHAR2(15)
        CONSTRAINT wrk_imi_fk REFERENCES WROGOWIE (imie_wroga),
    data_incydentu DATE
        CONSTRAINT wrk_dat_req NOT NULL,
    opis_incydentu VARCHAR2(50),
    CONSTRAINT wrk_pk PRIMARY KEY (pseudo, imie_wroga)
);

ALTER TABLE BANDY ADD CONSTRAINT bnd_szf_fk FOREIGN KEY (szef_bandy) REFERENCES KOCURY(pseudo);






ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

ALTER TABLE BANDY DISABLE CONSTRAINT BND_SZF_FK;
ALTER TABLE KOCURY DISABLE CONSTRAINT KOC_SZF_FK;

INSERT ALL
INTO BANDY VALUES(1,'SZEFOSTWO','CALOSC','TYGRYS'   )
INTO BANDY VALUES(2,'CZARNI RYCERZE','POLE','LYSY'  )
INTO BANDY VALUES(3,'BIALI LOWCY','SAD','ZOMBI'     )
INTO BANDY VALUES(4,'LACIACI MYSLIWI','GORKA','RAFA')
INTO BANDY VALUES(5,'ROCKERSI','ZAGRODA',NULL       )
SELECT * FROM DUAL;


INSERT ALL
INTO FUNKCJE VALUES('SZEFUNIO',90,110 )
INTO FUNKCJE VALUES('BANDZIOR',70,90  )
INTO FUNKCJE VALUES('LOWCZY',60,70    )
INTO FUNKCJE VALUES('LAPACZ',50,60    )
INTO FUNKCJE VALUES('KOT',40,50       )
INTO FUNKCJE VALUES('MILUSIA',20,30   )
INTO FUNKCJE VALUES('DZIELCZY',45,55  )
INTO FUNKCJE VALUES('HONOROWA',6,25   )
SELECT * FROM DUAL;

INSERT ALL
INTO KOCURY VALUES('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2    )
INTO KOCURY VALUES('BARI','M','RURA','LAPACZ','LYSY','2009-09-01',56,NULL,2       )
INTO KOCURY VALUES('MICKA','D','LOLA','MILUSIA','TYGRYS','2009-10-14',25,47,1     )
INTO KOCURY VALUES('LUCEK','M','ZERO','KOT','KURKA','2010-03-01',43,NULL,3        )
INTO KOCURY VALUES('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI','2010-11-18',20,35,3  )
INTO KOCURY VALUES('LATKA','D','UCHO','KOT','RAFA','2011-01-01',40,NULL,4         )
INTO KOCURY VALUES('DUDEK','M','MALY','KOT','RAFA','2011-05-15',40,NULL,4         )
INTO KOCURY VALUES('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1   )
INTO KOCURY VALUES('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS','2002-05-05',50,NULL,1)
INTO KOCURY VALUES('KOREK','M','ZOMBI','BANDZIOR','TYGRYS','2004-03-16',75,13,3   )
INTO KOCURY VALUES('BOLEK','M','LYSY','BANDZIOR','TYGRYS','2006-08-15',72,21,2    )
INTO KOCURY VALUES('ZUZIA','D','SZYBKA','LOWCZY','LYSY','2006-07-21',65,NULL,2    )
INTO KOCURY VALUES('RUDA','D','MALA','MILUSIA','TYGRYS','2006-09-17',22,42,1      )
INTO KOCURY VALUES('PUCEK','M','RAFA','LOWCZY','TYGRYS','2006-10-15',65,NULL,4    )
INTO KOCURY VALUES('PUNIA','D','KURKA','LOWCZY','ZOMBI','2008-01-01',61,NULL,3    )
INTO KOCURY VALUES('BELA','D','LASKA','MILUSIA','LYSY','2008-02-01',24,28,2       )
INTO KOCURY VALUES('KSAWERY','M','MAN','LAPACZ','RAFA','2008-07-12',51,NULL,4     )
INTO KOCURY VALUES('MELA','D','DAMA','LAPACZ','RAFA','2008-11-01',51,NULL,4       )
SELECT * FROM DUAL;

INSERT ALL
INTO WROGOWIE VALUES('KAZIO',10,'CZLOWIEK','FLASZKA'              )
INTO WROGOWIE VALUES('GLUPIA ZOSKA',1,'CZLOWIEK','KORALIK'        )
INTO WROGOWIE VALUES('SWAWOLNY DYZIO',7,'CZLOWIEK','GUMA DO ZUCIA')
INTO WROGOWIE VALUES('BUREK',4,'PIES','KOSC'                      )
INTO WROGOWIE VALUES('DZIKI BILL',10,'PIES',NULL                  )
INTO WROGOWIE VALUES('REKSIO',2,'PIES','KOSC'                     )
INTO WROGOWIE VALUES('BETHOVEN',1,'PIES','PEDIGRIPALL'            )
INTO WROGOWIE VALUES('CHYTRUSEK',5,'LIS','KURCZAK'                )
INTO WROGOWIE VALUES('SMUKLA',1,'SOSNA',NULL                      )
INTO WROGOWIE VALUES('BAZYLI',3,'KOGUT','KURA DO STADA'           )
SELECT * FROM DUAL;

INSERT ALL
INTO WROGOWIE_KOCUROW VALUES('TYGRYS','KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY'                   )
INTO WROGOWIE_KOCUROW VALUES('ZOMBI','SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY'                 )
INTO WROGOWIE_KOCUROW VALUES('BOLEK','KAZIO','2005-03-29','POSZCZUL BURKIEM'                           )
INTO WROGOWIE_KOCUROW VALUES('SZYBKA','GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI'            )
INTO WROGOWIE_KOCUROW VALUES('MALA','CHYTRUSEK','2007-03-07','ZALECAL SIE'                             )
INTO WROGOWIE_KOCUROW VALUES('TYGRYS','DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA'              )
INTO WROGOWIE_KOCUROW VALUES('BOLEK','DZIKI BILL','2007-11-10','ODGRYZL UCHO'                          )
INTO WROGOWIE_KOCUROW VALUES('LASKA','DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA'         )
INTO WROGOWIE_KOCUROW VALUES('LASKA','KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK'            )
INTO WROGOWIE_KOCUROW VALUES('DAMA','KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY'                    )
INTO WROGOWIE_KOCUROW VALUES('MAN','REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL'           )
INTO WROGOWIE_KOCUROW VALUES('LYSY','BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA'            )
INTO WROGOWIE_KOCUROW VALUES('RURA','DZIKI BILL','2009-09-03','ODGRYZL OGON'                           )
INTO WROGOWIE_KOCUROW VALUES('PLACEK','BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA')
INTO WROGOWIE_KOCUROW VALUES('PUSZYSTA','SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI'                    )
INTO WROGOWIE_KOCUROW VALUES('KURKA','BUREK','2010-12-14','POGONIL'                                    )
INTO WROGOWIE_KOCUROW VALUES('MALY','CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA'                )
INTO WROGOWIE_KOCUROW VALUES('UCHO','SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI'                )
SELECT * FROM DUAL;


ALTER TABLE BANDY ENABLE CONSTRAINT BND_SZF_FK;
ALTER TABLE KOCURY ENABLE CONSTRAINT KOC_SZF_FK;




CREATE OR REPLACE VIEW VW_INFO_BANDY AS
select B.NAZWA "NAZWA_BANDY",
       AVG(K.PRZYDZIAL_MYSZY) "SRE_SPOZ",
       MAX(K.PRZYDZIAL_MYSZY) "MAX_SPOZ",
       MIN(K.PRZYDZIAL_MYSZY) "MIN_SPOZ",
       COUNT(K.PSEUDO) "KOTY",
       COUNT(K.MYSZY_EXTRA) "KOTY_Z_DOD"
from BANDY B
    left join KOCURY K on B.NR_BANDY = K.NR_BANDY
group by B.NR_BANDY, B.NAZWA
order by MAX(K.PRZYDZIAL_MYSZY) desc;