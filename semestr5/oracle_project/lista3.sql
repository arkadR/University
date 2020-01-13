
SET SERVEROUTPUT ON
/

-- ZADANIE 34
DECLARE
    LICZBA NUMBER;
BEGIN
    SELECT COUNT(*) INTO LICZBA
    FROM KOCURY K
    WHERE K.FUNKCJA = '&FUNKCJA';
    
    IF LICZBA > 0 THEN
        DBMS_OUTPUT.PUT_LINE('ZNALEZIONO');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('NIE ZNALEZIONO');
    END IF;
END;

-- ZADANIE 35
DECLARE
    IMIE1 KOCURY.IMIE%TYPE;
    PRZYDZIAL_ROCZNY NUMBER;
    MIESIAC_PRZYST NUMBER;
    SPELNIA BOOLEAN DEFAULT FALSE;
BEGIN
    SELECT K.IMIE,
        (K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)) * 12,
        EXTRACT(MONTH FROM K.W_STADKU_OD)
    INTO
        IMIE1, PRZYDZIAL_ROCZNY, MIESIAC_PRZYST
    FROM KOCURY K
    WHERE K.PSEUDO = '&PSEUDO';
    
    IF PRZYDZIAL_ROCZNY > 700 THEN 
        SPELNIA := TRUE;
        DBMS_OUTPUT.PUT_LINE(IMIE1 || ': calkowity roczny przydzial myszy > 700');
    END IF;
    IF IMIE1 LIKE '%A%' THEN
        SPELNIA := TRUE;
        DBMS_OUTPUT.PUT_LINE(IMIE1 || ': imie zawiera litere A');
    END IF;
    IF MIESIAC_PRZYST = 1 THEN
        SPELNIA := TRUE;
        DBMS_OUTPUT.PUT_LINE(IMIE1 || ': styczen jest miesiacem przystapienia do stada');
    END IF;
    IF NOT SPELNIA THEN 
        DBMS_OUTPUT.PUT_LINE(IMIE1 || ': nie odpowiada kryteriom');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('nie znaleziono kota');
END;


-- ZADANIE 36
ALTER TABLE KOCURY DISABLE ALL TRIGGERS;
ALTER TABLE KOCURY ENABLE ALL TRIGGERS;

DECLARE
    SUMA_PRZYDZIALOW NUMBER;
    ILE_PODWYZEK NUMBER DEFAULT 0;
    CURSOR KURSOR IS 
        SELECT K.PSEUDO PSEUDO, 
            K.PRZYDZIAL_MYSZY PRZYDZIAL,
            F.MAX_MYSZY MAX_MYSZY
        FROM KOCURY K JOIN FUNKCJE F ON K.FUNKCJA = F.FUNKCJA
        ORDER BY K.PRZYDZIAL_MYSZY;
        
    KOT KURSOR%ROWTYPE;
BEGIN
    SELECT SUM(K.PRZYDZIAL_MYSZY) INTO SUMA_PRZYDZIALOW
    FROM KOCURY K;

    OPEN KURSOR;
    WHILE SUMA_PRZYDZIALOW <= 1050
    LOOP
        FETCH KURSOR INTO KOT;
        
        IF KURSOR%NOTFOUND THEN
            CLOSE KURSOR;
            OPEN KURSOR;
            FETCH KURSOR INTO KOT;
        END IF;
        
        IF CEIL(KOT.PRZYDZIAL * 1.1) > KOT.MAX_MYSZY AND KOT.PRZYDZIAL <> KOT.MAX_MYSZY THEN
            SUMA_PRZYDZIALOW := SUMA_PRZYDZIALOW + (KOT.MAX_MYSZY - KOT.PRZYDZIAL);
            UPDATE KOCURY SET PRZYDZIAL_MYSZY = KOT.MAX_MYSZY WHERE PSEUDO = KOT.PSEUDO;
            ILE_PODWYZEK := ILE_PODWYZEK + 1;
        ELSIF KOT.PRZYDZIAL <> KOT.MAX_MYSZY THEN
            SUMA_PRZYDZIALOW := SUMA_PRZYDZIALOW + CEIL(0.1 * KOT.PRZYDZIAL);
            UPDATE KOCURY SET PRZYDZIAL_MYSZY = CEIL(KOT.PRZYDZIAL * 1.1) WHERE PSEUDO = KOT.PSEUDO;
            ILE_PODWYZEK := ILE_PODWYZEK + 1;
        END IF;
        --DBMS_OUTPUT.PUT_LINE(SUMA_PRZYDZIALOW || ' ' || ILE_PODWYZEK);
    END LOOP;
    CLOSE KURSOR;
    
    DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku: ' || SUMA_PRZYDZIALOW || ', Zmian: ' || ILE_PODWYZEK);
END;

SELECT IMIE, PRZYDZIAL_MYSZY
FROM KOCURY
ORDER BY PRZYDZIAL_MYSZY DESC;

SELECT SUM(K.PRZYDZIAL_MYSZY)
FROM KOCURY K;

ROLLBACK;
/

-- ZADANIE 37
DECLARE 
    CURSOR KURSOR IS
    SELECT ROWNUM "NR",
        PSEUDONIM "PSEUDONIM",
        ZJADA "ZJADA"
    FROM (
        SELECT K.PSEUDO "PSEUDONIM", 
            K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0) "ZJADA"
        FROM KOCURY K
        ORDER BY K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0) DESC)
    WHERE ROWNUM < 6;
   
BEGIN
    DBMS_OUTPUT.PUT_LINE('NR  PSEUDONIM  ZJADA');
    DBMS_OUTPUT.PUT_LINE('--------------------');
    FOR KOT IN KURSOR
    LOOP
        DBMS_OUTPUT.PUT_LINE(KOT.NR || '   ' || RPAD(KOT.PSEUDONIM, 10) || ' ' || KOT.ZJADA);
    END LOOP;
END;
/

-- ZADANIE 38
DECLARE
    CURSOR KURSOR IS
        SELECT K.IMIE, K.PSEUDO
        FROM KOCURY K
        WHERE K.FUNKCJA IN ('KOT', 'MILUSIA');
    PSEUDO_CURRENT    KOCURY.PSEUDO%TYPE;
    IMIE_CURRENT      KOCURY.IMIE%TYPE;
    PSEUDO_NEXT       KOCURY.SZEF%TYPE;
    COL_WIDTH         NUMBER DEFAULT 15;
    ILE_SZEFOW        NUMBER DEFAULT &ILE_SZEFOW;
BEGIN
    DBMS_OUTPUT.PUT(RPAD('IMIE ', COL_WIDTH));
    FOR COUNTER IN 1..ILE_SZEFOW
    LOOP
        DBMS_OUTPUT.PUT(RPAD('|  SZEF ' || COUNTER, COL_WIDTH));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', COL_WIDTH*(ILE_SZEFOW+1), '-'));
    FOR KOT IN KURSOR
    LOOP
        DBMS_OUTPUT.PUT(RPAD(KOT.IMIE, COL_WIDTH));
        SELECT SZEF INTO PSEUDO_NEXT FROM KOCURY WHERE PSEUDO = KOT.PSEUDO;
        FOR COUNTER IN 1..ILE_SZEFOW
        LOOP
            IF PSEUDO_NEXT IS NULL THEN
                DBMS_OUTPUT.PUT(RPAD('|  ', COL_WIDTH));
            
            ELSE
                SELECT K.IMIE, K.PSEUDO, K.SZEF INTO IMIE_CURRENT, PSEUDO_CURRENT, PSEUDO_NEXT
                FROM KOCURY K
                WHERE K.PSEUDO = PSEUDO_NEXT;
                DBMS_OUTPUT.PUT(RPAD('|  ' || IMIE_CURRENT, COL_WIDTH));
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/

-- ZADANIE 39
DECLARE
    NR_B                BANDY.NR_BANDY%TYPE DEFAULT &NR_BANDY;
    NAZWA_B             BANDY.NAZWA%TYPE    DEFAULT '&NAZWA_BANDY';   
    TEREN_B             BANDY.TEREN%TYPE    DEFAULT '&TEREN_BANDY';
    ZNALEZIONE          NUMBER;
    EXC_DUPLICATE       EXCEPTION;
    EXC_WRONG_NUMBER    EXCEPTION;
    EXC_MESSAGE         VARCHAR2(30) DEFAULT '';
BEGIN
    IF NR_B <= 0 THEN 
        RAISE EXC_WRONG_NUMBER;
    END IF;
    SELECT COUNT(*) INTO ZNALEZIONE FROM BANDY B WHERE B.NR_BANDY = NR_B;
    IF ZNALEZIONE <> 0 THEN
        EXC_MESSAGE := EXC_MESSAGE || ' ' || NR_B || ',';
    END IF;
    SELECT COUNT(*) INTO ZNALEZIONE FROM BANDY B WHERE B.NAZWA = NAZWA_B;
    IF ZNALEZIONE <> 0 THEN
        EXC_MESSAGE := EXC_MESSAGE || ' ' || NAZWA_B || ',';
    END IF;
    SELECT COUNT(*) INTO ZNALEZIONE FROM BANDY B WHERE B.TEREN = TEREN_B;
    IF ZNALEZIONE <> 0 THEN
        EXC_MESSAGE := EXC_MESSAGE || ' ' || TEREN_B || ',';
    END IF;
    IF LENGTH(EXC_MESSAGE) > 0 THEN
        RAISE EXC_DUPLICATE;
    END IF;
    INSERT INTO BANDY(NR_BANDY, NAZWA, TEREN) VALUES(NR_B, NAZWA_B, TEREN_B);
EXCEPTION
    WHEN EXC_DUPLICATE THEN
        DBMS_OUTPUT.PUT_LINE(TRIM(TRAILING ',' FROM EXC_MESSAGE) || ': JUZ ISTNIEJE');
    WHEN EXC_WRONG_NUMBER THEN 
        DBMS_OUTPUT.PUT_LINE('NR BANDY MUSI BYC LICZBA DODATNIA');
END;

SELECT *
FROM BANDY;

ROLLBACK;

-- ZADANIE 41
CREATE OR REPLACE TRIGGER TRG_INSERT_BANDA
BEFORE INSERT ON BANDY FOR EACH ROW
DECLARE
    LAST_IDX BANDY.NR_BANDY%TYPE;
BEGIN
    SELECT MAX(NR_BANDY) INTO LAST_IDX
    FROM BANDY;
    IF LAST_IDX+1 <> :NEW.NR_BANDY THEN 
        :NEW.NR_BANDY := LAST_IDX+1;
    END IF;
END;

BEGIN
    ZAD40(10, 'TEST', 'TEST');
END;

SELECT *
FROM BANDY;

ROLLBACK;

-- ZADANIE 42 A
CREATE OR REPLACE PACKAGE MEMORY_VIRUS IS
    KARA                NUMBER DEFAULT 0;
    NAGRODA             NUMBER DEFAULT 0;
    PRZYDZIAL_TYGRYSA   NUMBER;
END;

CREATE OR REPLACE TRIGGER TRG_VIRUS_BEFORE_UPDATE
BEFORE UPDATE OF PRZYDZIAL_MYSZY ON KOCURY
DECLARE
BEGIN
    SELECT PRZYDZIAL_MYSZY INTO MEMORY_VIRUS.PRZYDZIAL_TYGRYSA FROM KOCURY WHERE PSEUDO = 'TYGRYS';
END;

CREATE OR REPLACE TRIGGER TRG_VIRUS_BEFORE_UPDATE_ROW
BEFORE UPDATE OF PRZYDZIAL_MYSZY ON KOCURY FOR EACH ROW
DECLARE
BEGIN
    IF :NEW.FUNKCJA = 'MILUSIA'THEN 
        IF :NEW.PRZYDZIAL_MYSZY <= :OLD.PRZYDZIAL_MYSZY THEN 
            DBMS_OUTPUT.PUT_LINE('TEMP: BRAK ZMIANY');
            :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
        ELSIF :NEW.PRZYDZIAL_MYSZY - :OLD.PRZYDZIAL_MYSZY < 0.1*MEMORY_VIRUS.PRZYDZIAL_TYGRYSA THEN 
            DBMS_OUTPUT.PUT_LINE('TEMP: MNIEJSZY NIZ 10%');
            :NEW.PRZYDZIAL_MYSZY := :NEW.PRZYDZIAL_MYSZY + ROUND(0.1*MEMORY_VIRUS.PRZYDZIAL_TYGRYSA);
            :NEW.MYSZY_EXTRA := NVL(:NEW.MYSZY_EXTRA, 0) + 5;
            MEMORY_VIRUS.KARA := MEMORY_VIRUS.KARA + ROUND(0.1*MEMORY_VIRUS.PRZYDZIAL_TYGRYSA);
        ELSE
            MEMORY_VIRUS.NAGRODA := MEMORY_VIRUS.NAGRODA + 5;
        END IF;
    END IF;
END;

CREATE OR REPLACE TRIGGER TRG_VIRUS_AFTER_UPDATE
AFTER UPDATE OF PRZYDZIAL_MYSZY ON KOCURY
DECLARE 
    PRZYDZIAL KOCURY.PRZYDZIAL_MYSZY%TYPE;
    EKSTRA KOCURY.MYSZY_EXTRA%TYPE;
BEGIN 
    SELECT PRZYDZIAL_MYSZY, MYSZY_EXTRA INTO PRZYDZIAL, EKSTRA 
    FROM KOCURY K
    WHERE K.PSEUDO = 'TYGRYS';
    
    PRZYDZIAL := PRZYDZIAL - MEMORY_VIRUS.KARA;
    EKSTRA := EKSTRA + MEMORY_VIRUS.NAGRODA;
    
    IF MEMORY_VIRUS.KARA <> 0 OR MEMORY_VIRUS.NAGRODA <> 0 THEN
        MEMORY_VIRUS.KARA := 0;
        MEMORY_VIRUS.NAGRODA := 0;
        UPDATE KOCURY 
        SET PRZYDZIAL_MYSZY = PRZYDZIAL, 
            MYSZY_EXTRA = EKSTRA
        WHERE PSEUDO = 'TYGRYS';
    END IF;
END;
/
UPDATE KOCURY SET PRZYDZIAL_MYSZY = 31 WHERE IMIE = 'SONIA';
ROLLBACK;
/
DROP TRIGGER TRG_VIRUS_AFTER_UPDATE;
DROP TRIGGER TRG_VIRUS_BEFORE_UPDATE;
DROP TRIGGER TRG_VIRUS_BEFORE_UPDATE_ROW;
DROP PACKAGE MEMORY_VIRUS;
/

-- ZADANIE 42 B
CREATE OR REPLACE TRIGGER TRG_VIRUS_COMPOUND
FOR UPDATE OF PRZYDZIAL_MYSZY ON KOCURY
COMPOUND TRIGGER
    PRZYDZIAL_TYGRYSA   KOCURY.PRZYDZIAL_MYSZY%TYPE;
    EKSTRA              KOCURY.MYSZY_EXTRA%TYPE;
    KARA                NUMBER DEFAULT 0;
    NAGRODA             NUMBER DEFAULT 0;
    
    BEFORE STATEMENT IS 
    BEGIN
        SELECT PRZYDZIAL_MYSZY INTO PRZYDZIAL_TYGRYSA FROM KOCURY WHERE PSEUDO = 'TYGRYS';
    END BEFORE STATEMENT;
    
    BEFORE EACH ROW IS 
    BEGIN
        IF :NEW.FUNKCJA = 'MILUSIA' THEN 
            IF :NEW.PRZYDZIAL_MYSZY <= :OLD.PRZYDZIAL_MYSZY THEN 
                DBMS_OUTPUT.PUT_LINE('TEMP: BRAK ZMIANY');
                :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
            ELSIF :NEW.PRZYDZIAL_MYSZY - :OLD.PRZYDZIAL_MYSZY < 0.1*PRZYDZIAL_TYGRYSA THEN 
                DBMS_OUTPUT.PUT_LINE('TEMP: MNIEJSZY NIZ 10%');
                :NEW.PRZYDZIAL_MYSZY := :NEW.PRZYDZIAL_MYSZY + ROUND(0.1*PRZYDZIAL_TYGRYSA);
                :NEW.MYSZY_EXTRA := NVL(:NEW.MYSZY_EXTRA, 0) + 5;
                KARA := KARA + ROUND(0.1*PRZYDZIAL_TYGRYSA);
            ELSE
                NAGRODA := NAGRODA + 5;
            END IF;
        END IF;
    END BEFORE EACH ROW;
    
    AFTER STATEMENT IS 
    BEGIN
        SELECT MYSZY_EXTRA INTO EKSTRA 
        FROM KOCURY K
        WHERE K.PSEUDO = 'TYGRYS';
        
        PRZYDZIAL_TYGRYSA := PRZYDZIAL_TYGRYSA - KARA;
        EKSTRA := EKSTRA + NAGRODA;
        
        IF KARA <> 0 OR NAGRODA <> 0 THEN
            DBMS_OUTPUT.PUT_LINE('NOWY PRZYDZIAL: ' || PRZYDZIAL_TYGRYSA);
            KARA := 0;
            NAGRODA := 0;
            UPDATE KOCURY 
            SET PRZYDZIAL_MYSZY = PRZYDZIAL_TYGRYSA, 
                MYSZY_EXTRA = EKSTRA
            WHERE PSEUDO = 'TYGRYS';
        END IF;
    END AFTER STATEMENT;
END;

UPDATE KOCURY SET PRZYDZIAL_MYSZY = 21 WHERE IMIE = 'SONIA';
ROLLBACK;
/

-- ZADANIE 43
DECLARE
    COL_WIDTH   NUMBER DEFAULT 15;
    COL_COUNT   NUMBER DEFAULT 4;
    PLEC_K      KOCURY.PLEC%TYPE;
    ILE         NUMBER;
BEGIN
    DBMS_OUTPUT.PUT(RPAD('NAZWA BANDY', COL_WIDTH) || RPAD('PLEC', COL_WIDTH) || RPAD('ILE', COL_WIDTH));
    FOR FUNKCJA IN (SELECT FUNKCJA FROM FUNKCJE) LOOP
        DBMS_OUTPUT.PUT(RPAD(FUNKCJA.FUNKCJA, COL_WIDTH));
        COL_COUNT := COL_COUNT +1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('SUMA', COL_WIDTH));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', COL_WIDTH*COL_COUNT, '-'));
    FOR BANDA IN (SELECT NR_BANDY, NAZWA FROM BANDY) LOOP
        FOR PL IN 1..2 LOOP
            DBMS_OUTPUT.PUT(RPAD(BANDA.NAZWA, COL_WIDTH));
            IF PL = 1 THEN PLEC_K := 'D'; ELSE PLEC_K := 'M'; END IF;
            IF PL = 1 THEN DBMS_OUTPUT.PUT(RPAD('KOTKA', COL_WIDTH)); ELSE DBMS_OUTPUT.PUT(RPAD('KOCUR', COL_WIDTH)); END IF;
            SELECT COUNT(K.PSEUDO) INTO ILE
            FROM KOCURY K
            WHERE K.NR_BANDY = BANDA.NR_BANDY AND K.PLEC = PLEC_K;
            DBMS_OUTPUT.PUT(RPAD(ILE, COL_WIDTH));
            FOR FUNKCJA IN (SELECT FUNKCJA FROM FUNKCJE) LOOP
                SELECT SUM(K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)) INTO ILE
                FROM KOCURY K
                WHERE K.NR_BANDY = BANDA.NR_BANDY AND K.PLEC = PLEC_K AND K.FUNKCJA = FUNKCJA.FUNKCJA;
                DBMS_OUTPUT.PUT(RPAD(NVL(ILE, 0), COL_WIDTH));
            END LOOP;
            SELECT SUM(K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)) INTO ILE
            FROM KOCURY K
            WHERE K.NR_BANDY = BANDA.NR_BANDY AND K.PLEC = PLEC_K;
            DBMS_OUTPUT.PUT_LINE(RPAD(NVL(ILE, 0), COL_WIDTH));
        END LOOP;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', COL_WIDTH*COL_COUNT, '-'));
    DBMS_OUTPUT.PUT(RPAD('ZJADA RAZEM', COL_WIDTH) || RPAD(' ', COL_WIDTH) || RPAD(' ', COL_WIDTH));
    FOR FUNKCJA IN (SELECT FUNKCJA FROM FUNKCJE) LOOP
        SELECT SUM(K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)) INTO ILE
        FROM KOCURY K
        WHERE K.FUNKCJA = FUNKCJA.FUNKCJA;
        DBMS_OUTPUT.PUT(RPAD(NVL(ILE, 0), COL_WIDTH));
    END LOOP;
    SELECT SUM(K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0)) INTO ILE
    FROM KOCURY K;
    DBMS_OUTPUT.PUT_LINE(RPAD(NVL(ILE, 0), COL_WIDTH));
END;

-- ZADANIE 45
CREATE TABLE DODATKI_EXTRA(
    PSEUDO      VARCHAR2(15) NOT NULL,
    DOD_EXTRA   NUMBER(3) DEFAULT 0
)

CREATE OR REPLACE TRIGGER TRG_TYGRYS_UPDATE
BEFORE UPDATE OF PRZYDZIAL_MYSZY ON KOCURY FOR EACH ROW
DECLARE
    ILE NUMBER;
    DOD NUMBER;
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF LOGIN_USER <> 'TYGRYS' AND :NEW.PRZYDZIAL_MYSZY > :OLD.PRZYDZIAL_MYSZY AND :NEW.FUNKCJA = 'MILUSIA' THEN
        FOR KOTKA IN (SELECT PSEUDO FROM KOCURY WHERE FUNKCJA = 'MILUSIA') LOOP
            SELECT COUNT(*) INTO ILE FROM DODATKI_EXTRA WHERE PSEUDO = KOTKA.PSEUDO;
            IF ILE = 0 THEN
                INSERT INTO DODATKI_EXTRA(PSEUDO, DOD_EXTRA) VALUES(KOTKA.PSEUDO, -10);
            ELSE
                SELECT DOD_EXTRA INTO DOD FROM DODATKI_EXTRA WHERE PSEUDO = KOTKA.PSEUDO;
                UPDATE DODATKI_EXTRA SET DOD_EXTRA = DOD - 10 WHERE PSEUDO = KOTKA.PSEUDO;
            END IF;
            DBMS_OUTPUT.PUT_LINE(DOD);
            COMMIT;
        END LOOP;
    END IF;
END;

UPDATE KOCURY SET PRZYDZIAL_MYSZY = 21 WHERE IMIE = 'SONIA';
ROLLBACK;

-- ZADANIE 46
CREATE TABLE WYKROCZENIA (
    KTO VARCHAR2(15) NOT NULL,
    KIEDY DATE NOT NULL,
    KOMU VARCHAR2(15) NOT NULL,
    OPERACJA VARCHAR2(15) NOT NULL
);

CREATE OR REPLACE TRIGGER TRG_SPRAWDZ_PRZYDZIAL
BEFORE INSERT OR UPDATE OF PRZYDZIAL_MYSZY ON KOCURY FOR EACH ROW
DECLARE
    MIN_M           FUNKCJE.MIN_MYSZY%TYPE;
    MAX_M           FUNKCJE.MAX_MYSZY%TYPE;
    POZA_WIDELKAMI  EXCEPTION;
    CURR_DATE       DATE DEFAULT SYSDATE;
    EVENT           VARCHAR2(20);
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    SELECT MIN_MYSZY, MAX_MYSZY INTO MIN_M, MAX_M FROM FUNKCJE WHERE FUNKCJA = :NEW.FUNKCJA;
    IF MAX_M < :NEW.PRZYDZIAL_MYSZY OR :NEW.PRZYDZIAL_MYSZY < MIN_M THEN
        IF INSERTING THEN 
            EVENT := 'INSERT';
        ELSIF UPDATING THEN 
            EVENT := 'UPDATE';
        END IF;
        INSERT INTO WYKROCZENIA(KTO, KIEDY, KOMU, OPERACJA) VALUES(ORA_LOGIN_USER, CURR_DATE, :NEW.PSEUDO, EVENT);
        COMMIT;
        RAISE POZA_WIDELKAMI;
    END IF;
EXCEPTION
    WHEN POZA_WIDELKAMI THEN
        DBMS_OUTPUT.PUT_LINE('POZA WIDELKAMI');
END;
/

UPDATE KOCURY SET PRZYDZIAL_MYSZY = 80 WHERE IMIE = 'JACEK';
ROLLBACK;