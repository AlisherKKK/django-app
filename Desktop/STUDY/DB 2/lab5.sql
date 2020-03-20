SET SERVEROUTPUT ON;/*
--1
DECLARE 
    CURSOR cur_dep(v_dep_idd departments.department_id%TYPE) IS 
        SELECT department_id, department_name FROM departments WHERE department_id=v_dep_idd;
    CURSOR cur_emp(v_dep_idd employees.department_id%TYPE) IS 
        SELECT first_name, last_name, salary FROM employees WHERE department_id=v_dep_idd;
    v_first_name employees.first_name%TYPE;
    v_last_name employees.last_name%TYPE;
    v_salary employees.salary%TYPE; 
    v_dep_id departments.department_id%TYPE;
    v_dep_name departments.department_name%TYPE;
    BEGIN
        OPEN cur_dep(30);
        FETCH cur_dep INTO v_dep_id, v_dep_name;
        IF cur_dep%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Not found');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_dep_id || ' ' || v_dep_name);
            DBMS_OUTPUT.PUT_LINE('--------------------------');
            OPEN cur_emp(30);
            LOOP
                FETCH cur_emp INTO v_first_name,v_last_name,v_salary;
                EXIT WHEN cur_emp%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name || ' ' || v_salary);
            END LOOP;
        END IF;
        CLOSE cur_dep;
        
    END;
--2
SELECT COUNT(country_id) FROM countries WHERE region_id=1
INSERT INTO countries(country_id, country_name,region_id) VALUES ('AK','AVT-KALASH',1);

DECLARE 
    CURSOR cur_cont(v_reg_idd countries.region_id%TYPE) IS 
        SELECT COUNT(country_id) FROM countries WHERE region_id=v_reg_idd;
        
    v_reg_name regions.region_name%TYPE;
    v_c INT;
    
    BEGIN
        FOR i IN 1..4 LOOP
            OPEN cur_cont(i);
            SELECT region_name INTO v_reg_name FROM regions WHERE region_id=i;
            FETCH cur_cont INTO v_c;
            IF v_c>10 THEN 
                DBMS_OUTPUT.PUT_LINE(v_reg_name || ' ' || v_c);
            END IF;
            CLOSE cur_cont;
        END LOOP;
    END;
        
--3
DECLARE 
    CURSOR cur_emp IS
        SELECT first_name,last_name,job_id,salary FROM employees ORDER BY(salary) DESC;
    v_cursor cur_emp%ROWTYPE;
BEGIN
    OPEN cur_emp;
    LOOP
        FETCH cur_emp INTO v_cursor;
        EXIT WHEN cur_emp%ROWCOUNT>6;
        DBMS_OUTPUT.PUT_LINE(v_cursor.first_name || ' ' || v_cursor.last_name || ' ' || v_cursor.job_id || ' ' || v_cursor.salary);
    END LOOP;
END;
--4
insert into departments(department_id, department_name, location_id) values(230, 'STH', 1000);
DECLARE
    CURSOR c_money IS
        SELECT * FROM employees WHERE salary>299 AND salary<1001;
    v_em c_money%ROWTYPE;
BEGIN
    OPEN c_money;
    LOOP
        FETCH c_money INTO v_em;
        EXIT WHEN c_money%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_em.first_name || ' ' || v_em.last_name || '  ' || v_em.salary);
    END LOOP;
    CLOSE c_money;
END;

--5
DECLARE
    CURSOR c_top IS
        SELECT department_name, ROUND(AVG(salary),2) AS avg_salary COUNT(*) AS count_work FROM departments d, employees e WHERE d.department_id=e.department_id GROUP BY department_name ORDER BY avg_salary DESC;
BEGIN
    OPEN c_top;
    FOR v_emp IN c_top LOOP
        DBMS_OUTPUT.PUT_LINE('Department: ' || v_emp.department_name  || , || 'Avarage salary: ' || v_emp.avg_salary || , || 'Amount of workers: ' || v_emp.count_work);
        EXIT WHEN c_top%ROWCOUNT>3;
    END LOOP;
    CLOSE c_top;
END;*/


















































