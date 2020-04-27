-------------------------1----------------1------------------1
CREATE OR REPLACE FUNCTION getPopular2019(t_year IN NUMBER, t_term IN NUMBER)  RETURN SYS_REFCURSOR IS
    sel_cursor SYS_REFCURSOR;
    res_cursor SYS_REFCURSOR;
    prac_cursor SYS_REFCURSOR;
    v_count int :=0;
    v_practice NUMBER;
    v_derskod  VARCHAR2(10);
    v_localmin FLOAT;
    v_min FLOAT := 10000000;
BEGIN
    IF (t_year = 2018) THEN
        OPEN sel_cursor FOR SELECT 
                        ders_kod, ((EXTRACT(DAY FROM max(reg_date)-min(reg_date))*24 + EXTRACT(HOUR FROM (MAX(reg_date) - MIN(reg_date))))/COUNT(stud_id)) AS diff
                    FROM course_sections_2018 WHERE term = t_term
                    GROUP BY (ders_kod) ORDER BY COUNT(stud_id);
        OPEN res_cursor FOR SELECT 
                        ders_kod, ((EXTRACT(DAY FROM max(reg_date)-min(reg_date))*24 + EXTRACT(HOUR FROM (MAX(reg_date) - MIN(reg_date))))/COUNT(stud_id)) AS diff
                    FROM course_sections_2018 WHERE term = t_term
                    GROUP BY (ders_kod) ORDER BY COUNT(stud_id);
    ELSIF (t_year = 2019) THEN
        OPEN sel_cursor FOR SELECT 
                        ders_kod, ((EXTRACT(DAY FROM max(reg_date)-min(reg_date))*24 + EXTRACT(HOUR FROM (MAX(reg_date) - MIN(reg_date))))/COUNT(stud_id)) AS diff
                    FROM course_sections_2019 WHERE term = t_term
                    GROUP BY (ders_kod) ORDER BY COUNT(stud_id);
        OPEN res_cursor FOR SELECT 
                        ders_kod, ((EXTRACT(DAY FROM max(reg_date)-min(reg_date))*24 + EXTRACT(HOUR FROM (MAX(reg_date) - MIN(reg_date))))/COUNT(stud_id)) AS diff
                    FROM course_sections_2019 WHERE term = t_term
                    GROUP BY (ders_kod) ORDER BY COUNT(stud_id);
    ELSIF (t_year = 2017) THEN
        OPEN sel_cursor FOR SELECT 
                        ders_kod, (EXTRACT(DAY FROM max(reg_date)-min(reg_date))*24)/COUNT(stud_id) AS diff
                    FROM course_sections_2017 WHERE term = t_term
                    GROUP BY (ders_kod) ORDER BY COUNT(stud_id);
        OPEN res_cursor FOR SELECT 
                        ders_kod, (EXTRACT(DAY FROM max(reg_date)-min(reg_date))*24)/COUNT(stud_id) AS diff
                    FROM course_sections_2017 WHERE term = t_term
                    GROUP BY (ders_kod) ORDER BY COUNT(stud_id);
    ELSIF (t_year=2016) THEN
        OPEN sel_cursor FOR SELECT 
                        ders_kod, (EXTRACT(DAY FROM max(reg_date)-min(reg_date))*24)/COUNT(stud_id) AS diff
                    FROM course_sections_2016 WHERE term = t_term and reg_date is not null
                    GROUP BY (ders_kod) ORDER BY COUNT(stud_id);
        OPEN res_cursor FOR SELECT 
                        ders_kod, (EXTRACT(DAY FROM max(reg_date)-min(reg_date))*24)/COUNT(stud_id) AS diff
                    FROM course_sections_2016 WHERE term = t_term and reg_date is not null
                    GROUP BY (ders_kod) ORDER BY COUNT(stud_id);
    END IF;
    LOOP
        FETCH sel_cursor INTO v_derskod, v_localmin;
        EXIT WHEN sel_cursor%NOTFOUND;
        IF (v_localmin<v_min) THEN v_min := v_localmin; END IF;
    END LOOP;
    LOOP
        FETCH res_cursor INTO v_derskod, v_localmin;
        EXIT WHEN res_cursor%NOTFOUND;
        IF (v_min = v_localmin) THEN 
            prac_cursor := getPractice(v_derskod);
            LOOP
                FETCH prac_cursor INTO v_practice;
                EXIT WHEN prac_cursor%NOTFOUND;
                IF (v_practice IS NOT NULL) THEN 
                    DBMS_OUTPUT.PUT_LINE(v_practice || ' ' || v_derskod); 
                END IF;
            END LOOP;
        END IF;
    END LOOP;
    RETURN res_cursor;
END;

CREATE OR REPLACE FUNCTION getPractice(v_derskod IN VARCHAR2) RETURN SYS_REFCURSOR IS
res_cursor SYS_REFCURSOR;
BEGIN
    OPEN res_cursor FOR SELECT practice FROM course_sections_2019 WHERE ders_kod=v_derskod;
    return res_cursor;
END;

SET SERVEROUTPUT ON;

DECLARE dd SYS_REFCURSOR;
BEGIN
    dd:=getpopular2019(2019, 1);
END;
-----------------2--------------------------2--------------------------2-------------------------------------

CREATE OR REPLACE PROCEDURE getTeachers(t_year IN NUMBER,
                                        t_term IN NUMBER,
                                        t_derskod IN varchar2,
                                        c_prac OUT SYS_REFCURSOR,
                                        c_lec OUT SYS_REFCURSOR) IS
BEGIN
    OPEN c_prac FOR SELECT COUNT(emp_id), emp_id FROM course_sections
                    WHERE type='P' AND year=t_year AND term=t_term AND ders_kod=t_derskod GROUP BY emp_id ORDER BY COUNT(emp_id) DESC;
    OPEN c_lec FOR SELECT COUNT(emp_id), emp_id FROM course_sections
                    WHERE (type='N' or type='L') AND year=t_year AND term=t_term AND ders_kod=t_derskod GROUP BY emp_id ORDER BY COUNT(emp_id) DESC;
END getTeachers;    

DECLARE 
    c_pr SYS_REFCURSOR;
    c_lec SYS_REFCURSOR;
    c_teacher NUMBER;
    c_count int;
BEGIN
    getTeachers(2018, 1, 'MAT 251', c_pr, c_lec);
    LOOP
        FETCH c_pr INTO c_count, c_teacher;
        EXIT WHEN c_pr%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Practice Teacher: ' || c_teacher || ' Count: ' || c_count);
    END LOOP;
    LOOP
        FETCH c_lec INTO c_count, c_teacher;
        EXIT WHEN c_lec%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Lecture Teacher: ' || c_teacher || ' Count: ' || c_count);
    END LOOP;
END;

-------------3---------------------------3--------------------3------------

CREATE OR REPLACE FUNCTION get_gpa(v_poi IN CHAR) RETURN FLOAT IS
BEGIN
    IF (v_poi = 'A') THEN RETURN 4;
    ELSIF (v_poi='A-') THEN RETURN 3.67;
    ELSIF (v_poi='B+') THEN RETURN 3.33;
    ELSIF (v_poi='B') THEN RETURN 3;
    ELSIF (v_poi='B-') THEN RETURN 2.67;
    ELSIF (v_poi='C+') THEN RETURN 2.33;
    ELSIF (v_poi='C') THEN RETURN 2;
    ELSIF (v_poi='C-') THEN RETURN 1.67;
    ELSIF (v_poi='D+') THEN RETURN 1.33;
    ELSIF (v_poi='D') THEN RETURN 1;
    ELSE RETURN 0;
    END IF;
END;

CREATE OR REPLACE PROCEDURE get_curs_byterm(v_stud IN VARCHAR2, v_year IN NUMBER, v_term IN NUMBER, v_res OUT SYS_REFCURSOR) IS
BEGIN
    IF (v_year = 2019) THEN
        OPEN v_res FOR SELECT csy.QIYMET_HERF, cs.credits FROM course_sections_2019 csy, course_sections cs WHERE 
            cs.year=v_year AND csy.year=v_year AND cs.term=v_term AND csy.term=v_term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
    ELSIF (v_year = 2018) THEN
        OPEN v_res FOR SELECT csy.QIYMET_HERF, cs.credits FROM course_sections_2018 csy, course_sections cs WHERE 
            cs.year=v_year AND csy.year=v_year AND cs.term=v_term AND csy.term=v_term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
    ELSIF (v_year = 2017) THEN
        OPEN v_res FOR SELECT csy.QIYMET_HERF, cs.credits FROM course_sections_2017 csy, course_sections cs WHERE 
            cs.year=v_year AND csy.year=v_year AND cs.term=v_term AND csy.term=v_term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
     ELSIF (v_year = 2016) THEN
        OPEN v_res FOR SELECT csy.QIYMET_HERF, cs.credits FROM course_sections_2016 csy, course_sections cs WHERE 
            cs.year=v_year AND csy.year=v_year AND cs.term=v_term AND csy.term=v_term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
    END IF;
END;
    
SET SERVEROUTPUT ON;

DECLARE 
    v_studid VARCHAR2(50) := '8FC9F68E8912FEC5D9948A9CCED642D36A767DFA';
    v_term NUMBER := 1;
    v_year NUMBER := 2019;
    CURSOR c_term2019(v_year NUMBER, v_term NUMBER, v_stud VARCHAR2) IS SELECT get_gpa(csy.QIYMET_HERF) as gp, cs.credits as cr FROM course_sections_2019 csy, course_sections cs WHERE 
            cs.year=v_year AND csy.year=v_year AND cs.term=v_term AND csy.term=v_term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
    CURSOR c_term2018(v_year NUMBER, v_term NUMBER, v_stud VARCHAR2) IS SELECT get_gpa(csy.QIYMET_HERF) as gp, cs.credits as cr FROM course_sections_2018 csy, course_sections cs WHERE 
            cs.year=v_year AND csy.year=v_year AND cs.term=v_term AND csy.term=v_term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
    CURSOR c_term2017(v_year NUMBER, v_term NUMBER, v_stud VARCHAR2) IS SELECT get_gpa(csy.QIYMET_HERF) as gp, cs.credits as cr FROM course_sections_2017 csy, course_sections cs WHERE 
            cs.year=v_year AND csy.year=v_year AND cs.term=v_term AND csy.term=v_term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
    CURSOR c_term2016(v_year NUMBER, v_term NUMBER, v_stud VARCHAR2) IS SELECT get_gpa(csy.QIYMET_HERF) as gp, cs.credits as cr FROM course_sections_2016 csy, course_sections cs WHERE 
            cs.year=v_year AND csy.year=v_year AND cs.term=v_term AND csy.term=v_term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
    CURSOR c_allt(v_stud VARCHAR2) IS SELECT get_gpa(csy.QIYMET_HERF) as gp, cs.credits as cr FROM course_sections_2016 csy, course_sections cs WHERE 
            cs.year=csy.year AND cs.term=csy.term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod union
                                        SELECT get_gpa(csy.QIYMET_HERF) as gp, cs.credits as cr FROM course_sections_2017 csy, course_sections cs WHERE 
            cs.year=csy.year AND cs.term=csy.term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod union
                                        SELECT get_gpa(csy.QIYMET_HERF) as gp, cs.credits as cr FROM course_sections_2018 csy, course_sections cs WHERE 
            cs.year=csy.year AND cs.term=csy.term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod union 
                                        SELECT get_gpa(csy.QIYMET_HERF) as gp, cs.credits as cr FROM course_sections_2019 csy, course_sections cs WHERE 
            cs.year=csy.year AND cs.term=csy.term AND csy.stud_id=v_stud AND csy.ders_kod=cs.ders_kod;
    v_termgpa FLOAT := 0;
    v_allgpa FLOAT :=0;
    v_rec c_term2019%ROWTYPE;
    v_crs INT:=1;
    v_allcr INT := 0;
BEGIN
    OPEN c_term2019(2019,1,v_studid);
    OPEN c_term2018(2018,1,v_studid);
    OPEN c_term2017(2017,1,v_studid);
    OPEN c_term2016(2016,1,v_studid);
    LOOP
        FETCH c_term2019 INTO v_rec;
        EXIT WHEN c_term2019%NOTFOUND;
        IF (v_rec.gp <> 0) THEN 
            v_termgpa := v_termgpa+(v_rec.gp*v_rec.cr); 
            v_crs := v_crs+v_rec.cr;   
        END IF; 
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Gpa for term ' || v_term || ' of year ' || v_year || ' is ' || v_termgpa/v_crs);  
    v_termgpa:=0;
    v_crs:=1;
    LOOP
        FETCH c_term2018 INTO v_rec;
        EXIT WHEN c_term2018%NOTFOUND;
        IF (v_rec.gp <> 0) THEN 
            v_termgpa := v_termgpa+(v_rec.gp*v_rec.cr); 
            v_crs := v_crs+v_rec.cr;   
        END IF; 
    END LOOP;
    v_termgpa:=0;
    v_crs:=1;
    DBMS_OUTPUT.PUT_LINE('Gpa for term 1 of year 2018 is ' || v_termgpa/v_crs);  
    LOOP
        FETCH c_term2017 INTO v_rec;
        EXIT WHEN c_term2017%NOTFOUND;
        IF (v_rec.gp <> 0) THEN 
            v_termgpa := v_termgpa+(v_rec.gp*v_rec.cr); 
            v_crs := v_crs+v_rec.cr;   
        END IF; 
    END LOOP;
    v_termgpa:=0;
    v_crs:=1;
    DBMS_OUTPUT.PUT_LINE('Gpa for term 1 of year 2017 is ' || v_termgpa/v_crs);  
    LOOP
        FETCH c_term2016 INTO v_rec;
        EXIT WHEN c_term2016%NOTFOUND;
        dbms_output.put_line(v_rec.gp);
        IF (v_rec.gp <> 0) THEN 
            v_termgpa := v_termgpa+(v_rec.gp*v_rec.cr); 
            v_crs := v_crs+v_rec.cr;   
        END IF; 
    END LOOP;
    OPEN c_allt(v_studid);
    LOOP
        FETCH c_allt INTO v_rec;
        EXIT WHEN c_allt%NOTFOUND;
            IF (v_rec.gp <> 0) THEN
                v_allgpa := v_allgpa+v_rec.gp*v_rec.cr;
                v_allcr := v_allcr+v_rec.cr;
            END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Student id: '||v_studid|| ' GPA: ' || v_allgpa/v_allcr);
END;

------------4------------------------4----------4--------

DECLARE 
    v_year NUMBER := 2019;
    v_term NUMBER := 1;
    c_res SYS_REFCURSOR;
    v_stud VARCHAR2(50);
BEGIN
    IF (v_year = 2019) THEN
        OPEN c_res FOR SELECT stud_id FROM course_sections_2019 WHERE term=v_term and reg_date is null;
    ELSIF (v_year = 2018) THEN
        OPEN c_res FOR SELECT stud_id FROM course_sections_2018 WHERE term=v_term and reg_date is null;
    ELSIF (v_year = 2017) THEN
        OPEN c_res FOR SELECT stud_id FROM course_sections_2017 WHERE term=v_term and reg_date is null;
    ELSIF (v_year = 2016) THEN
        OPEN c_res FOR SELECT stud_id FROM course_sections_2016 WHERE term=v_term and reg_date is null;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Students who did not register any subjects');
    LOOP 
        FETCH c_res INTO v_stud;
        EXIT WHEN c_res%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_stud);
    END LOOP;
END;

-------------------5-------------------5-----------------------5-------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE getStudentRetakes(t_year IN NUMBER,
                                        t_term IN NUMBER,
                                        t_stud_id IN varchar2,
                                        c_credit OUT SYS_REFCURSOR) IS
BEGIN
    IF (t_year = 2019) THEN
        OPEN c_credit FOR SELECT credits FROM course_sections
        WHERE ders_kod IN (SELECT ders_kod FROM course_sections_2019 WHERE term=t_term AND qiymet_herf='F' AND stud_id=t_stud_id) AND term=t_term; 
    ELSIF (t_year = 2018) THEN
        OPEN c_credit FOR SELECT credits FROM course_sections
        WHERE ders_kod IN (SELECT ders_kod FROM course_sections_2018 WHERE term=t_term AND qiymet_herf='F' AND stud_id=t_stud_id) AND term=t_term; 
    ELSIF (t_year=2017) THEN
        OPEN c_credit FOR SELECT credits FROM course_sections
        WHERE ders_kod IN (SELECT ders_kod FROM course_sections_2017 WHERE term=t_term AND qiymet_herf='F' AND stud_id=t_stud_id) AND term=t_term; 
    ELSIF (t_year=2016) THEN
        OPEN c_credit FOR SELECT credits FROM course_sections
        WHERE ders_kod IN (SELECT ders_kod FROM course_sections_2016 WHERE term=t_term AND qiymet_herf='F' AND stud_id=t_stud_id) AND term=t_term;  
    END IF;
END getStudentRetakes;    

DECLARE 
    c_credit SYS_REFCURSOR;
    c_credits NUMBER;
    c_sum int := 0;
BEGIN
    getStudentRetakes(2019, 1, '0BA949581DA857F93758F4ACF700640D72223D75', c_credit);
    LOOP
        FETCH c_credit INTO c_credits;
        EXIT WHEN c_credit%NOTFOUND;
        c_sum:=c_sum+ 25000*c_credits;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Money for term ' || c_sum);
END;

CREATE OR REPLACE PROCEDURE getStudentRetakesTotal(t_stud_id IN varchar2,
                                        c_total OUT SYS_REFCURSOR) IS
BEGIN
    OPEN c_total FOR SELECT credits FROM course_sections
    WHERE ders_kod IN (SELECT ders_kod FROM course_sections_2019 WHERE qiymet_herf='F' UNION SELECT ders_kod FROM course_sections_2018 WHERE qiymet_herf='F' UNION
SELECT ders_kod FROM course_sections_2017 WHERE qiymet_herf='F' UNION SELECT ders_kod FROM course_sections_2016 WHERE qiymet_herf='F' and stud_id='1BE62388007249890ADF37743AB9D9F27ADCD932') ; 
END getStudentRetakesTotal;    

DECLARE 
    c_total SYS_REFCURSOR;
    c_credits NUMBER;
    c_totalsum int := 0;
BEGIN
    getStudentRetakesTotal('2FAADAE73D0AA4B892F4242E98524CDF6D0C79B0', c_total);
    LOOP
        FETCH c_total INTO c_credits;
        EXIT WHEN c_total%NOTFOUND;
        c_totalsum:=c_totalsum+ 25000*c_credits;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Profit ' || c_totalsum);
END;

------------------6---------*-----6--------------6-------

CREATE OR REPLACE PROCEDURE teacher_hours (v_emp_id IN NUMBER, 
                                        v_term IN NUMBER, 
                                        v_year IN NUMBER,
                                        v_total OUT INT) IS 
BEGIN
    SELECT (2*(SELECT COUNT(cs.ders_kod) FROM course_sections cs WHERE cs.term=v_term AND cs.year=v_year AND cs.emp_id=v_emp_id AND (cs.type='N' OR cs.type='L'))+
        (SELECT COUNT(cs.ders_kod) FROM course_sections cs WHERE cs.term=v_term AND cs.year=v_year AND cs.emp_id=v_emp_id AND cs.type='P' )) INTO v_total  FROM dual;
    v_total := v_total*15;
END teacher_hours;

DECLARE 
    v_emp  NUMBER := 10051;
    v_term  NUMBER := 1;
    v_year  number := 2019;
    v_total  INT;
BEGIN
    teacher_hours(v_emp,v_term,v_year,v_total);
    DBMS_OUTPUT.PUT_LINE(v_total);
END;

-------------------7-----------------7------------------------7--------------------------------------------------------
CREATE OR REPLACE PACKAGE getTeacherSchedule IS
    FUNCTION get_schedule
        (t_empid IN NUMBER, t_term IN NUMBER, t_year IN NUMBER) RETURN SYS_REFCURSOR;
END getTeacherSchedule;

CREATE OR REPLACE PACKAGE BODY getTeacherSchedule IS
    FUNCTION get_schedule(t_empid IN NUMBER, t_term IN NUMBER, t_year IN NUMBER) RETURN SYS_REFCURSOR IS
        c_sch SYS_REFCURSOR;
    BEGIN 
         OPEN c_sch FOR SELECT cs.emp_id, cs.ders_kod, sch.minn 
                                FROM course_sections cs, course_schedule sch 
                                WHERE cs.emp_id=t_empid AND cs.term=t_term AND cs.ders_kod=sch.ders_kod AND cs.year=t_year AND sch.year=t_year;
        RETURN c_sch;
    END get_schedule;
END getTeacherSchedule;

DECLARE 
    v_setemp NUMBER := 10314;
    v_setterm NUMBER := 1;
    v_setyear NUMBER := 2019;
    v_emp NUMBER;
    v_derskod VARCHAR2(10);
    v_date course_schedule.minn%TYPE;
    c_sch SYS_REFCURSOR;
BEGIN
     c_sch:=getTeacherSchedule.get_schedule(v_setemp, v_setterm, v_setyear);
     DBMS_OUTPUT.PUT_LINE('Employee: ' || v_setemp);
     LOOP
        FETCH c_sch INTO v_emp, v_derskod, v_date;
        EXIT WHEN c_sch%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Ders kod: ' || v_derskod || '    Date: ' || v_date);
    END LOOP;
END;

--------------8----------------------------8-------------8----------

CREATE OR REPLACE PROCEDURE sch_student(v_studid IN VARCHAR2, 
                                        v_term IN NUMBER, 
                                        v_year IN NUMBER, 
                                        v_curs OUT SYS_REFCURSOR) IS 
BEGIN
    IF (v_year = 2019) THEN 
        OPEN v_curs FOR SELECT cs.ders_kod, sm.minn FROM course_sections_2019 cs, course_schedule sm 
            WHERE cs.stud_id=v_studid AND cs.ders_kod=sm.ders_kod AND sm.year=v_year AND cs.term = v_term;
    ELSIF (v_year = 2018) THEN
        OPEN v_curs FOR SELECT cs.ders_kod, sm.minn FROM course_sections_2018 cs, course_schedule sm 
            WHERE cs.stud_id=v_studid AND cs.ders_kod=sm.ders_kod AND sm.year=v_year AND cs.term = v_term;
    ELSIF (v_year = 2017) THEN
        OPEN v_curs FOR SELECT cs.ders_kod, sm.minn FROM course_sections_2017 cs, course_schedule sm 
            WHERE cs.stud_id=v_studid AND cs.ders_kod=sm.ders_kod AND sm.year=v_year AND cs.term = v_term;
    ELSIF (v_year = 2016) THEN
        OPEN v_curs FOR SELECT cs.ders_kod, sm.minn FROM course_sections_2016 cs, course_schedule sm 
            WHERE cs.stud_id=v_studid AND cs.ders_kod=sm.ders_kod AND sm.year=v_year AND cs.term = v_term;
    END IF;
END;

DECLARE 
    c_sch SYS_REFCURSOR;
    v_year NUMBER := 2019;
    v_term NUMBER := 1;
    v_studid VARCHAR2(50) := '549BDACC95CEDA20C439CC6F1E7A775316623CEC';
    v_derskod VARCHAR2(10);
    v_date TIMESTAMP;
BEGIN
    sch_student(v_studid, v_term, v_year, c_sch);
    LOOP
        FETCH c_sch INTO v_derskod, v_date;
        EXIT WHEN c_sch%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Ders kod ' || v_derskod || '    Time ' || v_date);
    END LOOP;
END;

---------------------9----------------9--------------------9

CREATE OR REPLACE FUNCTION get_ders_credit(v_derskod IN VARCHAR2, v_year IN NUMBER, v_term IN NUMBER) RETURN NUMBER IS
    v_res NUMBER;
BEGIN
    SELECT credits INTO v_res FROM course_sections WHERE ders_kod=v_derskod AND term=v_term AND year=v_year AND ROWNUM<2;
    RETURN v_res;
END;

CREATE OR REPLACE PROCEDURE get_st_ders(v_stud IN VARCHAR2, v_year IN NUMBER, v_term IN NUMBER, c_res OUT SYS_REFCURSOR) IS
BEGIN
    IF (v_year = 2019) THEN
        OPEN c_res FOR SELECT ders_kod, get_ders_credit(ders_kod,v_year,v_term) FROM course_sections_2019 WHERE stud_id=v_stud AND term=v_term AND reg_date IS NOT NULL;
    ELSIF (v_year = 2018) THEN
        OPEN c_res FOR SELECT ders_kod, get_ders_credit(ders_kod,v_year,v_term)  FROM course_sections_2018 WHERE stud_id=v_stud AND term=v_term AND reg_date IS NOT NULL;
    ELSIF (v_year = 2017) THEN
        OPEN c_res FOR SELECT ders_kod, get_ders_credit(ders_kod,v_year,v_term)  FROM course_sections_2017 WHERE stud_id=v_stud AND term=v_term AND reg_date IS NOT NULL;
    ELSIF (v_year = 2016) THEN
        OPEN c_res FOR SELECT ders_kod, get_ders_credit(ders_kod,v_year,v_term)  FROM course_sections_2016 WHERE stud_id=v_stud AND term=v_term AND reg_date IS NOT NULL;
    END IF;
END;

SELECT ders_kod, get_ders_credit(ders_kod,2019,1) FROM course_sections_2019 WHERE stud_id='549BDACC95CEDA20C439CC6F1E7A775316623CEC' AND term=1 AND reg_date IS NOT NULL;

SET SERVEROUTPUT ON;

DECLARE 
    v_stud VARCHAR2(50) := '549BDACC95CEDA20C439CC6F1E7A775316623CEC';
    v_year NUMBER := 2019;
    v_term NUMBER := 1;
    c_res SYS_REFCURSOR;
    v_ders VARCHAR2(10);
    v_cr NUMBER;
    r_cders INT := 0;
    r_ccred INT := 0;
BEGIN
    get_st_ders(v_stud, v_year, v_term, c_res);
    LOOP 
        FETCH c_res INTO v_ders, v_cr;
        EXIT WHEN c_res%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Ders ' || v_ders || ' credit ' ||v_cr);
        r_cders := r_cders + 1;
        r_ccred := r_ccred + v_cr;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Student selected ' || r_cders || ' subjects, its ' || r_ccred || ' credits');
END;

-------------10-----------------------10---------10-------

CREATE OR REPLACE PROCEDURE get_best(v_prac IN NUMBER, v_ders IN VARCHAR2) IS
    TYPE all_best IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
    bests all_best;
    CURSOR s_all(pr NUMBER, der course_sections_2019.ders_kod%TYPE) IS 
        SELECT * FROM (SELECT  ads, cnn,year, term FROM (SELECT AVG(QIYMET_YUZ) AS ads, COUNT(stud_id) AS cnn,year,term 
            FROM course_sections_2019 WHERE ders_kod=der AND practice=pr GROUP BY ders_kod,practice,year,term UNION
                                          SELECT AVG(QIYMET_YUZ) AS ads, COUNT(stud_id) AS cnn,year,term 
            FROM course_sections_2018 WHERE ders_kod=der AND practice=pr GROUP BY ders_kod,practice,year,term UNION
                                          SELECT AVG(QIYMET_YUZ) AS ads, COUNT(stud_id) AS cnn,year,term 
            FROM course_sections_2017 WHERE ders_kod=der AND practice=pr GROUP BY ders_kod,practice,year,term UNION
                                          SELECT AVG(QIYMET_YUZ) AS ads, COUNT(stud_id) AS cnn,year,term 
            FROM course_sections_2016 WHERE ders_kod=der AND practice=pr GROUP BY ders_kod,practice,year,term
            )WHERE ads IS NOT NULL ORDER BY ads DESC, cnn DESC) WHERE ROWNUM<2;
    av FLOAT;
    co INT;
    y NUMBER;
    ter NUMBER;
BEGIN 
    OPEN s_all(v_prac,v_ders);
    FETCH s_all INTO av,co,y,ter;
    DBMS_OUTPUT.PUT_LINE('Students of ' || v_prac || ' received ' || av || '(average) points on subject ' || v_ders || ' on ' || y || ' year and ' || ter || ' term. Count of students ' || co);
END;
    
DECLARE
    v_ders VARCHAR2(10) := 'PED 198';
    v_prac NUMBER := 18829;
BEGIN
    get_best(v_prac,v_ders);
END;


------------------11-----------------11--------------------------11

CREATE OR REPLACE PROCEDURE gettop_teachers(v_year IN NUMBER, v_term IN NUMBER, c_res OUT SYS_REFCURSOR) IS
BEGIN
    IF (v_year = 2019) THEN
        OPEN c_res FOR SELECT practice, COUNT(stud_id) FROM course_sections_2019 WHERE term=v_term GROUP BY practice ORDER BY COUNT(stud_id) DESC;
    ELSIF (v_year = 2018) THEN
        OPEN c_res FOR SELECT practice, COUNT(stud_id) FROM course_sections_2018 WHERE term=v_term GROUP BY practice ORDER BY COUNT(stud_id) DESC;
    ELSIF (v_year = 2017) THEN
        OPEN c_res FOR SELECT practice, COUNT(stud_id) FROM course_sections_2017 WHERE term=v_term GROUP BY practice ORDER BY COUNT(stud_id) DESC;
    ELSIF (v_year = 2016) THEN
        OPEN c_res FOR SELECT practice, COUNT(stud_id) FROM course_sections_2016 WHERE term=v_term GROUP BY practice ORDER BY COUNT(stud_id) DESC;
    END IF;
END;


SET SERVEROUTPUT ON;

DECLARE
    v_year NUMBER;
    v_term NUMBER;
    c_res SYS_REFCURSOR;
    TYPE teachers IS TABLE OF INT INDEX BY VARCHAR2(100);
    rating teachers;
    r_prac NUMBER;
    r_cou NUMBER;
    item VARCHAR2(100);
    i VARCHAR2(100);
BEGIN
    gettop_teachers(2019, 1, c_res);
    LOOP
        FETCH c_res INTO r_prac, r_cou;
        EXIT WHEN c_res%NOTFOUND;
        IF (r_prac IS NOT NULL) THEN
            item:=TO_CHAR(r_prac);
            rating(item) := r_cou;
            DBMS_OUTPUT.PUT_LINE('Teacher with id ' || r_prac || ' has ' || r_cou || ' students');
        END IF;
    END LOOP;
            DBMS_OUTPUT.PUT_LINE('************************************************************************************');

    i := rating.FIRST;
    WHILE i IS NOT NULL LOOP
       DBMS_Output.PUT_LINE
            ('Teacher with id ' || i || ' has ' || TO_CHAR(rating(i)) || ' students');
       i := rating.NEXT(i);
     END LOOP;
END;

--------------------12------------------12--------------12

CREATE OR REPLACE PROCEDURE gettop_course(v_year IN NUMBER, v_term IN NUMBER, c_res OUT SYS_REFCURSOR) IS
BEGIN
    IF (v_year = 2019) THEN
        OPEN c_res FOR SELECT ders_kod, COUNT(stud_id) FROM course_sections_2019 WHERE term=v_term GROUP BY ders_kod ORDER BY COUNT(stud_id) DESC;
    ELSIF (v_year = 2018) THEN
        OPEN c_res FOR SELECT ders_kod, COUNT(stud_id) FROM course_sections_2018 WHERE term=v_term GROUP BY ders_kod ORDER BY COUNT(stud_id) DESC;
    ELSIF (v_year = 2017) THEN
        OPEN c_res FOR SELECT ders_kod, COUNT(stud_id) FROM course_sections_2017 WHERE term=v_term GROUP BY ders_kod ORDER BY COUNT(stud_id) DESC;
    ELSIF (v_year = 2016) THEN
        OPEN c_res FOR SELECT ders_kod, COUNT(stud_id) FROM course_sections_2016 WHERE term=v_term GROUP BY ders_kod ORDER BY COUNT(stud_id) DESC;
    END IF;
END;

SET SERVEROUTPUT ON;

DECLARE
    v_year NUMBER;
    v_term NUMBER;
    c_res SYS_REFCURSOR;
    TYPE teachers IS TABLE OF INT INDEX BY VARCHAR2(100);
    rating teachers;
    ders VARCHAR2(10);
    r_cou NUMBER;
    item VARCHAR2(100);
    i VARCHAR2(100);
BEGIN
    gettop_course(2019, 1, c_res);
    LOOP
        FETCH c_res INTO ders, r_cou;
        EXIT WHEN c_res%NOTFOUND;
        IF (ders IS NOT NULL) THEN
            rating(ders) := r_cou;
            DBMS_OUTPUT.PUT_LINE('Subject with code ' || ders || ' has ' || r_cou || ' students');
        END IF;
    END LOOP;
            DBMS_OUTPUT.PUT_LINE('************************************************************************************');
    i := rating.FIRST;
    WHILE i IS NOT NULL LOOP
       DBMS_Output.PUT_LINE
            ('Subject with code ' || i || ' has ' || TO_CHAR(rating(i)) || ' students');
       i := rating.NEXT(i);
     END LOOP;
END;

---------------13------------------13------------------13-----
SET SERVEROUTPUT ON;
DECLARE
    CURSOR c_cur IS SELECT SUM(credits) AS cred, COUNT(*) AS coun FROM course_sections
        WHERE ders_kod IN (SELECT ders_kod FROM course_sections_2019 WHERE  QIYMET_HERF = 'F' UNION
                           SELECT ders_kod FROM course_sections_2017 WHERE  QIYMET_HERF = 'F' UNION
                           SELECT ders_kod FROM course_sections_2018 WHERE  QIYMET_HERF = 'F' UNION
                           SELECT ders_kod FROM course_sections_2016 WHERE  QIYMET_HERF = 'F');
    v_curs c_cur%ROWTYPE;
BEGIN
    OPEN c_cur;
    LOOP
        FETCH c_cur INTO v_curs;
        EXIT WHEN c_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Total retakes ' || v_curs.coun);
        DBMS_OUTPUT.PUT_LINE('Total credits ' || v_curs.cred);
        DBMS_OUTPUT.PUT_LINE('Profit ' || v_curs.cred*25000);
    END LOOP;
END;
    
    
    
    ------------trigger --------------------
CREATE TABLE sections_LOG ( log_date DATE
                             , action VARCHAR2(50))
                             
UPDATE students SET stud_id='121212' WHERE stud_id='180103125';

CREATE OR REPLACE TRIGGER MAP_UPDATE
  AFTER INSERT OR UPDATE OR DELETE
  ON course_sections
DECLARE
  log_action  sections_LOG.action%TYPE;
BEGIN
  IF INSERTING THEN
    log_action := 'Insert';
  ELSIF UPDATING THEN
    log_action := 'Update';
  ELSIF DELETING THEN
    log_action := 'Delete';
  ELSE
    DBMS_OUTPUT.PUT_LINE('This code is not reachable.');
  END IF;
  INSERT INTO sections_LOG (log_date, action)
    VALUES (SYSDATE, log_action);
END;   

CREATE OR REPLACE TRIGGER EVAL_CHANGE_TRIGGER
  AFTER INSERT OR UPDATE OR DELETE
  ON course_sections_2019
DECLARE
  log_action  sections_LOG.action%TYPE;
BEGIN
  IF INSERTING THEN
    log_action := 'Insert';
  ELSIF UPDATING THEN
    log_action := 'Update';
  ELSIF DELETING THEN
    log_action := 'Delete';
  ELSE
    DBMS_OUTPUT.PUT_LINE('This code is not reachable.');
  END IF;

  INSERT INTO sections_LOG (log_date, action)
    VALUES (SYSDATE, log_action);
END;    
    
    delete from to_delete where id=1
-----------------Dynamic sql---------------------------------------
    
CREATE OR REPLACE PROCEDURE insert_subject (v_derskod IN VARCHAR2, v_year IN NUMBER, v_term IN NUMBER, v_dersid IN NUMBER, v_sec IN CHAR, v_start IN TIMESTAMP) AS
BEGIN
  INSERT INTO course_schedule(ders_kod,year,term,ders_s_id,section, minn) VALUES(v_derskod,v_year,v_term,v_dersid, v_sec,v_start) ;
END;

DECLARE
  plsql_block VARCHAR2(500);
  v_derskod  VARCHAR2(10):='BBB 999';
  v_year   NUMBER := 2019;
  v_term   NUMBER := 2;
  v_dersid NUMBER := 998;
  v_sec CHAR(3) := '01';
  v_start TIMESTAMP := '01.09.2016 12:00:00,000000000';
BEGIN
  plsql_block := 'BEGIN insert_subject(:a, :b, :c, :d, :e, :f); END;';
  EXECUTE IMMEDIATE plsql_block
    USING IN OUT v_derskod,v_year,v_term,v_dersid,v_sec,v_start;
END;

-----------------transactions


update course_sections_2019 set QIYMET_YUZ=56 where stud_id='549BDACC95CEDA20C439CC6F1E7A775316623CEC' and practice=23771 and ders_kod='MDE 103'








  






