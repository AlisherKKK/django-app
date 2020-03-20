SET SERVEROUTPUT ON;
--1
DECLARE 
    CURSOR cur_sth IS
        SELECT salary FROM employees FOR UPDATE NOWAIT;
    v_salary employees.salary%TYPE;
BEGIN
    OPEN cur_sth;   
    LOOP 
        FETCH cur_sth INTO v_salary;
        EXIT WHEN cur_sth%NOTFOUND;
        UPDATE employees
            SET salary = v_salary*1.1 WHERE CURRENT OF cur_sth;
    END LOOP;
    CLOSE cur_sth;
END;

--2
--You can change Neena and write employee name
DECLARE
    CURSOR c_emp IS
        SELECT department_id FROM employees WHERE department_id=(SELECT department_id FROM departments WHERE department_name='Executive') AND first_name='Neena' FOR UPDATE OF department_id;
BEGIN
    --Name and his department
    FOR c_row IN c_emp    LOOP
        UPDATE employees
        --change Administration to your own dep name
            SET department_id=(SELECT department_id FROM departments WHERE department_name='Administration') WHERE CURRENT OF c_emp;
    END LOOP;
END;

--3
DECLARE
    TYPE my_rec IS RECORD (
        emp_first employees.first_name%TYPE,
        emp_last employees.last_name%TYPE,
        emp_salary employees.salary%TYPE
    );
    TYPE my_refCur IS REF CURSOR RETURN my_rec;
    cur_emp my_refCur;
    v_first_name employees.first_name%TYPE;
    v_last_name employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    OPEN cur_emp FOR SELECT first_name, last_name, salary FROM employees WHERE employee_id = 200;
    FETCH cur_emp INTO v_first_name, v_last_name, v_salary;
    CLOSE cur_emp;
    DBMS_OUTPUT.PUT_LINE('Employee: ' || v_first_name || ', ' || v_last_name || '; Salary: ' || v_salary);
END;

--4
SET SERVEROUTPUT ON;
DECLARE    
    CURSOR c_deps IS
        SELECT department_id, department_name FROM departments ORDER BY(department_id);
    CURSOR c_emps IS
        SELECT first_name,last_name,salary, department_id FROM employees ORDER BY(last_name);
BEGIN
    FOR c_d_row IN c_deps LOOP
        DBMS_OUTPUT.PUT_LINE(c_d_row.department_id || ' ' || c_d_row.department_name);
        DBMS_OUTPUT.PUT_LINE('-------------------------');
        FOR c_e_row IN c_emps LOOP
            IF (c_d_row.department_id=c_e_row.department_id) THEN
                DBMS_OUTPUT.PUT_LINE(c_e_row.first_name || ' ' || c_e_row.last_name || ' ' || c_e_row.salary);
            END IF;
        END LOOP;
    END LOOP;
END;

--5
DECLARE 
    CURSOR c_coun(v_reg_id regions.region_id%TYPE) IS
        SELECT country_id, country_name FROM countries WHERE region_id=v_reg_id;
    CURSOR c_emp(v_coun_id countries.country_id%TYPE) IS
        SELECT COUNT(employee_id) FROM employees WHERE department_id=(SELECT department_id FROM departments WHERE location_id=(SELECT location_id FROM locations WHERE country_id=v_coun_id));
    v_c_n countries.country_name%TYPE;
    v_c_id countries.country_id%TYPE;
    v_count INT;
    v_reg_name regions.region_name%TYPE;
BEGIN
    FOR i IN 1..4 LOOP
        OPEN c_coun(i);
        SELECT region_name INTO v_reg_name FROM regions WHERE region_id=i;
        DBMS_OUTPUT.PUT_LINE(i || ' ' || v_reg_name);
        DBMS_OUTPUT.PUT_LINE('---------------------------');
        LOOP
            FETCH c_coun INTO v_c_id,v_c_n;
            EXIT WHEN c_coun%NOTFOUND;
            OPEN c_emp(v_c_id);
            FETCH c_emp INTO v_count;
            EXIT WHEN c_emp%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_c_n || ' ' || v_count);
            CLOSE c_emp;
       END LOOP; 
       CLOSE c_coun;
    END LOOP;
END;    
    
    
    
    
    
     