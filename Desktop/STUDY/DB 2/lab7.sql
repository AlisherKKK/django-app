/*vocabulary
1) Functions
2) Arguments
3) Named
4) Combination
5) Positional
6) IN OUT parameter

TRY IT / SOLVE IT
1) MODES:
    a) IN: default mode, will be our input, can not be modified 
    b) OUT: will return some value when we call procedure
    c) IN OUT: will be our input and can be returned when we call the procadure (we can take it as input, change it and return to caller (can be modified))
*/
--2)
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE count_inf(p_coun_id IN cr_country.c_id%TYPE,
                                      p_name OUT cr_country.c_name%TYPE,
                                      p_pop OUT cr_country.population%TYPE) IS
BEGIN 
    SELECT c_name,population INTO p_name, p_pop FROM cr_country WHERE c_id=p_coun_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found exceptions handling'); 
END count_inf;
   
DECLARE
    c_name cr_country.c_name%TYPE;
    c_pop cr_country.population%TYPE;
BEGIN
--id's: 1-9, 44,45,51-55,91
    count_inf(10, c_name, c_pop);
    IF c_pop>0 THEN
        DBMS_OUTPUT.PUT_LINE('Country ' || c_name);
        DBMS_OUTPUT.PUT_LINE('Population ' || c_pop);
    END IF;
END;

--modified version (2.c task)
CREATE OR REPLACE PROCEDURE count_inf_2 (
                                      p_name OUT cr_country.c_name%TYPE,
                                      p_pop OUT cr_country.population%TYPE,
                                      p_dens OUT NUMBER,
                                      p_coun_id IN cr_country.c_id%TYPE) IS
BEGIN 
    SELECT c_name,population,population/area INTO p_name, p_pop, p_dens FROM cr_country WHERE c_id=p_coun_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found exceptions handling'); 
END count_inf_2;
--2c,2d
DECLARE
    c_name cr_country.c_name%TYPE;
    c_pop cr_country.population%TYPE;
    c_dens NUMBER;
BEGIN
--id's: 1-9, 44,45,51-55,91
    count_inf_2( c_name, c_pop,c_dens, 5);
    IF c_pop>0 THEN
        DBMS_OUTPUT.PUT_LINE('Country ' || c_name);
        DBMS_OUTPUT.PUT_LINE('Population ' || c_pop);
        DBMS_OUTPUT.PUT_LINE('Density ' || c_dens);        
    END IF;
END;

--3)
CREATE OR REPLACE PROCEDURE square (p_val IN OUT INT) IS
BEGIN
    p_val := (p_val*p_val);
END;

DECLARE
    c_val INT:= -20;
BEGIN
    square(c_val);
    DBMS_OUTPUT.PUT_LINE('RESULT: ' || c_val);
END;

--4)
--4A
DECLARE
    c_name cr_country.c_name%TYPE;
    c_pop cr_country.population%TYPE;
    c_dens NUMBER;
BEGIN
--id's: 1-9, 44,45,51-55,91
    count_inf_2( c_name, c_pop,c_dens,p_coun_id=>2);
    IF c_pop>0 THEN
        DBMS_OUTPUT.PUT_LINE('Country ' || c_name);
        DBMS_OUTPUT.PUT_LINE('Population ' || c_pop);
        DBMS_OUTPUT.PUT_LINE('Density ' || c_dens);        
    END IF;
END;
--4B can not be completed because positional passing parameters should be  stay before named passing parameters;
--4A can be answer to 4C

/* 5. We use default only for IN mode parameters. If parameter has default value we can send it in procedure header
we can send default value with two ways: 1) in parameter write (variable := 5 (5 is default value))
                                         2) variable DEFAULT 5 (5 is default value)(by DEFAULT option)
*/

--6
CREATE OR REPLACE PROCEDURE count_inf_3 (
                                      p_name OUT cr_country.c_name%TYPE,
                                      p_pop OUT cr_country.population%TYPE,
                                      p_dens OUT NUMBER,
                                      p_coun_id cr_country.c_id%TYPE := 2) IS
BEGIN 
    SELECT c_name,population,population/area INTO p_name, p_pop, p_dens FROM cr_country WHERE c_id=p_coun_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found exceptions handling'); 
END count_inf_3;
--2c,2d
DECLARE
    c_name cr_country.c_name%TYPE;
    c_pop cr_country.population%TYPE;
    c_dens NUMBER;
BEGIN
--id's: 1-9, 44,45,51-55,91
    count_inf_3( c_name, c_pop,c_dens);
    IF c_pop>0 THEN
        DBMS_OUTPUT.PUT_LINE('Country ' || c_name);
        DBMS_OUTPUT.PUT_LINE('Population ' || c_pop);
        DBMS_OUTPUT.PUT_LINE('Density ' || c_dens);        
    END IF;
END;







