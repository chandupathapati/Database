/*Create a procedure P1 that will have a record type based on emp_num, emp_fname,
 emp_lname and emp_sal.  Then, create a table type based on this record type.  
 The procedure should access relevant employee data from the employee table and
 store it into a table of the above table type and later display all the records.*/
 
CREATE OR REPLACE PROCEDURE P1 AS
type rec_emp is record(emp_num employee.emp_num%type,
					   emp_fname employee.emp_fname%type,
					   emp_lname employee.emp_lname%type,
					   emp_sal employee.emp_sal%type);
type tab_emp is table of rec_emp index by binary_integer;
blkvar tab_emp;

i number;
x number;
cursor c_emp is select emp_num,emp_fname,emp_lname,emp_sal from employee;

BEGIN

open c_emp;
i:=1;
loop

fetch c_emp into blkvar(i).emp_num,blkvar(i).emp_fname,blkvar(i).emp_lname,blkvar(i).emp_sal;

exit when c_emp%notfound;
i:=i+1;
end loop;


for x in 1..blkvar.count loop
dbms_output.put_line(blkvar(x).emp_num||' '||blkvar(x).emp_fname||' '||blkvar(x).emp_lname||' '||blkvar(x).emp_sal);
end loop;

close c_emp;

END;
/


/*Create a package named Pkg1 that will do the same thing as in the procedure P1.*/

CREATE OR REPLACE PACKAGE pkg1 is

type rec_emp is record(emp_num employee.emp_num%type,
					   emp_fname employee.emp_fname%type,
					   emp_lname employee.emp_lname%type,
					   emp_sal employee.emp_sal%type);
type tab_emp is table of rec_emp index by binary_integer;

procedure p1;

END;
/

CREATE OR REPLACE PACKAGE BODY pkg1 is

procedure p1 is 
blkvar tab_emp;
i number;
cursor c_emp is select emp_num,emp_fname,emp_lname,emp_sal from employee;
x number;

BEGIN
open c_emp;
i:=1;

loop
fetch c_emp into blkvar(i).emp_num,blkvar(i).emp_fname,blkvar(i).emp_lname,blkvar(i).emp_sal;
exit when c_emp%notfound;
i:=i+1;
end loop;
close c_emp;


for x in 1..blkvar.count loop
dbms_output.put_line(blkvar(x).emp_num||' '||blkvar(x).emp_fname||' '||blkvar(x).emp_lname||' '||blkvar(x).emp_sal);
end loop;

END p1;

END pkg1;
/


 

/*Create a procedure P2 that will have a table of varchar2.  
The procedure will access the names of the majors from the major table, 
assign it to this table of varchar2, and once all the majors have been stored in this table of 
varchar2, it will display all the majors.*/


CREATE OR REPLACE PROCEDURE P2 is
 
 type v_majors is table of varchar2(70) index by binary_integer;
 i number;
 x number;
 blkvar v_majors;
 temp varchar2(70);
 cursor c_majors is select maj_Desc from major;
 
 BEGIN
 I:=1;
 open c_majors;
 fetch c_majors into temp;
 while c_majors%found loop
 blkvar(i):=temp;
 fetch c_majors into temp;
 i:=i+1;
 end loop;
 close c_majors;
  for x in 1..blkvar.count loop
 dbms_output.put_line(blkvar(x));
 end loop;
 END;
 /

 

/*Create a package named Pkg2 that will have two functions and one procedure.  
Function F1 will receive the dept_id and return the highest salary of the department.  
Function F2 will receive a gender and return the number of employees belonging to that gender 
who earn less than the average salary for that gender.  The function will access the average salaries 
through a one-time-only procedure that will compute average salaries of the two genders.  
The procedure P1 will return the number of monitors that have not been used at all. */

CREATE OR REPLACE PACKAGE pkg2 AS
 function F1
			(bv_dept_id IN employee.dept_id%type)
			RETURN NUMBER;
 Function F2
			(bv_gend IN employee.emp_gend%type)
			RETURN NUMBER;

			
 Procedure P1(mon_count out number);
			
 END pkg2;
 /
 
 
 CREATE OR REPLACE PACKAGE BODY pkg2 IS
 
 avg_Sal_male number(10);
 avg_Sal_female number(10);
 
 Function F1 
			(bv_dept_id IN employee.dept_id%type)
			RETURN number
 IS
 high_sal number(5);
 BEGIN
 select max(emp_sal) into high_sal from employee where dept_id=bv_dept_id;
 
 RETURN(high_sal);
 END F1;
 
 Function F2
			(bv_gend IN employee.emp_gend%type)
			RETURN NUMBER
 IS
 
 num_emp number;
 
 BEGIN
 
 if lower(bv_gend)='male' 
 then select count(emp_num) into num_emp from employee where emp_gend='M' and emp_sal<avg_Sal_male;
 elsif lower(bv_gend)='female'
 then select count(emp_num) into num_emp from employee where emp_gend='F' and emp_sal<avg_Sal_female;
 end if;
 
 return num_emp;
 
 END F2;
 
 Procedure P1(mon_count out number) IS
 BEGIN
 select count(mon_id) into mon_count from monitor where mon_id not in(select distinct mon_id from pc);
 END P1;
 
 BEGIN
 
 SELECT round(avg(emp_sal)) into avg_Sal_female from employee where emp_gend='F';
 SELECT round(avg(emp_sal)) into avg_Sal_male from employee where emp_gend='M';
 
 END pkg2;
 /

Output:
Testing function f1:
SQL> declare
  2
  3  x NUMBER(5);
  4  dept department.dept_id%type;
  5  cursor c1 is select dept_id from department;
  6
  7  BEGIN
  8  open c1;
  9  fetch c1 into dept;
 10
 11  while c1%found loop
 12  x:=pkg2.F1(dept);
 13  dbms_output.put_line(x);
 14  fetch c1 into dept;
 15  end loop;
 16  close c1;
 17  end;
 18  /


/*Create a row trigger called “at_emp_sal” for the employee table. 
 When emp_sal is updated, the trigger will insert the username, emp_num, current date, 
 the existing and new emp_sal into the "log_emp" table. To insert this information, 
 create an appropriate "log_emp" first before you create the trigger.*/
 
 
create or replace trigger at_emp_sal
after update of emp_sal on employee
for each row
begin
insert into log_emp values(user,:new.emp_num,sysdate,:old.emp_sal,:new.emp_sal);
end;
/
Table:
CREATE TABLE LOG_EMP
  2  (username varchar2(10),
  3  emp_num varchar2(7),
  4  current_date date,
  5  existing_sal number(5),
  6  new_sal number(5));



 

Create a procedure that will receive the id of an employee and display the number of pcs assigned to
that employee.  If the employee does not have any pc assigned, then the system should return the value zero.

CREATE OR REPLACE PROCEDURE P3(id IN employee.emp_num%type,
								pc_count OUT number)
IS

BEGIN

select count(pc_num) into pc_count from pc where emp_num=id group by emp_num;
EXCEPTION
when no_data_found
then pc_count:=0;
END;
/



/*Testing the above procedure*/
DECLARE
  2  emp_id employee.emp_num%type;
  3  x number;
  4  cursor c1 is select emp_num from employee;
  5
  6
  7  BEGIN
  8  open c1;
  9  fetch c1 into emp_id;
 10
 11  while c1%found loop
 12  p3(emp_id,x);
 13  dbms_output.put_line(emp_id ||' '||x);
 14  fetch c1 into emp_id;
 15  end loop;
 16
 17  close c1;
 18
 19  END;
 20  /


 
/*Create a function that will allow a user to display the total cost of a pc (pc_cost) in a select statement. */

CREATE OR REPLACE FUNCTION F3
							(PC_ID IN COMP_EXP.PC_NUM%TYPE)
							RETURN NUMBER
IS

cost number;

BEGIN
select sum(cexp_amount) into cost from comp_exp where pc_num=pc_id group by pc_num;
return cost;
END;
/

 
/*Remove duplicate Data from person table*/
Explain plan for delete from persons where rowid not in (select max(rowid) from persons group by personid);
/*compare both the explain plans-Deletion using analytical function avoids full table scans and deletion is more efficient*/
Explain plan for Delete from persons 
where rowid in (select rid from 
( select rowid rid,row_number() over(partition by personid order by rowid) rn from persons)
where rn <> 1 );
