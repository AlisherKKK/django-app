CREATE USER username IDENTIFIED BY password;

GRANT CONNECT TO username;

SET SERVEROUTPUT ON;

BEGIN
DBMS_OUTPUT.PUT_LINE('Hello WORld ! ');
END ;

DECLARE
  inc   NUMBER(8,2);
BEGIN
  SELECT salary * 0.12 INTO inc
  FROM employees
  WHERE employee_id = 110;
DBMS_OUTPUT.PUT_LINE('Incentive  = ' || TO_CHAR(inc));
END;

DECLARE
    salar NUMBER(8,2);
BEGIN
    SELECT salary INTO salar 
    FROM employees 
    WHERE hire_date=(
        SELECT MIN(hire_date) 
        FROM employees);
DBMS_OUTPUT.PUT_LINE(salar);
END;

DECLARE
    coun INT;
BEGIN
    SELECT COUNT(department_id) INTO coun
    FROM departments
    WHERE department_name='IT';
DBMS_OUTPUT.PUT_LINE(coun);
END;

DECLARE 
    dep_name VARCHAR2(30 BYTE);
BEGIN
    SELECT department_name INTO dep_name FROM departments WHERE department_id=(SELECT department_id FROM employees WHERE salary=(SELECT MAX(salary) FROM employees));
DBMS_OUTPUT.PUT_LINE(dep_name);
END;    










