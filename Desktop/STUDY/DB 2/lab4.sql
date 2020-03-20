SET SERVEROUTPUT ON
select * from countries where region_id=1
--1
CREATE TABLE cr_country(
    c_name varchar(255),
    population int
);
ALTER TABLE cr_country add c_id int;
INSERT INTO cr_country(c_name, population) VALUES ('India',1250000000);
INSERT INTO cr_country(c_name, population) VALUES ('China',1300000000);
INSERT INTO cr_country(c_name, population) VALUES ('Russia',170000000);
INSERT INTO cr_country(c_name, population) VALUES ('USA',550000000);
INSERT INTO cr_country(c_name, population) VALUES ('Kazakhstan',17500000);
INSERT INTO cr_country(c_name, population,c_id) VALUES ('C1',200000000, 51);
INSERT INTO cr_country(c_name, population,c_id) VALUES ('C2',200000000, 52);
INSERT INTO cr_country(c_name, population,c_id) VALUES ('C3',200000000, 53);
INSERT INTO cr_country(c_name, population,c_id) VALUES ('C4',200000000, 54);
INSERT INTO cr_country(c_name, population,c_id) VALUES ('C5',200000000, 55);
UPDATE cr_country set c_id=91 where c_name='India';
DECLARE 
    v_c_name cr_country.c_name%TYPE;
    v_population cr_country.population%TYPE;
BEGIN
    SELECT c_name, population INTO v_c_name, v_population FROM cr_country WHERE c_id=44;
IF v_population >1000000000 THEN
    DBMS_OUTPUT.PUT_LINE('population more than 1.000.000.000 ' ||v_c_name);
    END IF;
IF v_population<1000000000 THEN
    DBMS_OUTPUT.PUT_LINE('population less than 1.000.000.000 ' ||v_c_name);
    END IF;
END;

--2

DECLARE
    v_c_id countries.country_id%TYPE:=1;
    v_c_name countries.country_name%TYPE:='KZ';
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE('Country: ' || v_c_name ||' id: ' || v_c_id );
        v_c_id:=v_c_id+1;
        IF (v_c_id>3) THEN 
            EXIT;
        END IF;
    END LOOP;
END;

--3
select * from countries where country_id='AU';
DECLARE
    v_c_id cr_country.c_id%TYPE:=51;
    v_c_name cr_country.c_name%TYPE;
BEGIN
    SELECT c_id,c_name INTO v_c_id,v_c_name FROM cr_country WHERE c_id=v_c_id; 
    WHILE v_c_id <=55 
        LOOP
            DBMS_OUTPUT.PUT_LINE(v_c_name ||' '|| v_c_id);
            v_c_id:=v_c_id+1;
        END LOOP;
    END;


--4

DECLARE
    v_c_id cr_country.c_id%TYPE;
    v_c_name cr_country.c_name%TYPE;
BEGIN
    SELECT c_id,c_name INTO v_c_id,v_c_name FROM cr_country WHERE c_id=v_c_id; 
        FOR v_c_id IN REVERSE 51 .. 55 
            LOOP
                DBMS_OUTPUT.PUT_LINE(v_c_name||v_c_id);
            END LOOP;
END;









