CREATE TABLE Department (
	department_id INTEGER NOT NULL, 
	department_name VARCHAR(20),
	
	CONSTRAINT PK_Department PRIMARY KEY (department_id)
);

CREATE TABLE Employee (
	employee_id INTEGER NOT NULL,
	first_name VARCHAR(20),
	last_name VARCHAR(20),
	birthdate DATE,
	hire_date DATE,
	department_id INTEGER,
	job_title VARCHAR(20),
	salary DECIMAL(10, 2),
	experience INTEGER,
	
	CONSTRAINT PK_Employee PRIMARY KEY (employee_id),
	CONSTRAINT employee_dep FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

CREATE TABLE Salary_Grade (
	grade_id INTEGER NOT NULL,
	min_salary DECIMAL(10, 2),
	max_salary DECIMAL(10, 2),
	
	CONSTRAINT PK_Salary_Grade PRIMARY KEY (grade_id)
);


INSERT INTO Department (department_id, department_name) VALUES (1, 'HR'), (2, 'IT'), (3, 'Finance');

INSERT INTO Employee (employee_id, first_name, last_name, birthdate, hire_date, department_id, job_title, salary, experience)
	VALUES
		(1, 'Reza','Rezvani','1980-05-15','2005-08-10',1,'Manager',65000.00,10),
		(2, 'Zahra', 'Salimi', '1985-03-20 ','2008-07-22', 2, 'Engineer', 55000.00, 7 ),
		(3, 'Amin', 'Nouri', '1990-12-10' ,'2010-11-05' ,3 ,'Analyst', 60000.00, 8  ),
		(4, 'Maryam', 'Ranjbar', '1982-07-30', '2007-06-15', 2, 'Manager' ,70000.00 ,12),
		(5, 'Farhad' ,'Abbasi' ,'1988-09-25','2009-04-18 ',3, 'Director', 80000.00, 11),
		(6, 'Sima' ,'Rahmani' ,'1987-02-17', '2006-03-29', 1 ,'Coordinator', 48000.00, 15);
	   
INSERT INTO Salary_Grade (grade_id, min_salary, max_salary) 
	VALUES
		(1, 45000.00, 60000.00),
		(2, 60001.00 ,75000.00),
		(3, 75001.00, 90000.00);
		
--	query 1
SELECT sg.grade_id, AVG(e.salary) 
	FROM Employee AS e INNER JOIN Salary_Grade As sg 
		ON e.salary BETWEEN sg.min_salary AND sg.max_salary
	GROUP BY sg.grade_id
	ORDER BY sg.grade_id;
	
-- query 2
SELECT * FROM Employee AS e
	WHERE e.salary IN (SELECT MAX(e2.salary) 
					   	FROM Department AS dep2 NATURAL JOIN Employee AS e2
					  	GROUP BY e2.department_id)
						ORDER BY e.salary DESC;

-- query 3
CREATE FUNCTION get_average_experience(id_ INTEGER) 
	RETURNS decimal(10, 2) AS $$
	DECLARE avg_experience decimal(10, 2);
	BEGIN
		SELECT AVG(e.experience) INTO avg_experience FROM Employee AS e WHERE e.department_id = id_
		GROUP BY id_;				
		RETURN avg_experience;
	END;
	$$ LANGUAGE plpgsql;
	
-- query 4
SELECT dep.* FROM Department AS dep WHERE get_average_experience(dep.department_id) > 8;

-- query 5
SELECT dep.* FROM Department AS dep WHERE get_average_experience(dep.department_id) > (SELECT AVG(e.experience) FROM Employee AS e);


