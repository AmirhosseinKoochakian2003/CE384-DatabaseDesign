CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE contests (
    id BIGINT PRIMARY KEY,
    title VARCHAR(255)
);

CREATE TABLE problems (
    id BIGINT PRIMARY KEY,
    contest_id BIGINT,
    title VARCHAR(255),
	
	CONSTRAINT fk_ci FOREIGN KEY (contest_id) REFERENCES contests (id)
);

CREATE TABLE submissions (
    id BIGINT PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    problem_id BIGINT REFERENCES problems(id),
    score BIGINT,
	
	CONSTRAINT fk_ui FOREIGN KEY (user_id) REFERENCES users (id),
	CONSTRAINT fk_pi FOREIGN KEY (problem_id) REFERENCES problems (id)
);

COPY users(id, name)
FROM 'D:\sql\data_q4\users.csv' DELIMITER ',' CSV HEADER;

COPY contests(id, title)
FROM 'D:\sql\data_q4\contests.csv' DELIMITER ',' CSV HEADER;

COPY problems(id, contest_id, title)
FROM 'D:\sql\data_q4\problems.csv' DELIMITER ',' CSV HEADER;

COPY submissions(id, user_id, problem_id, score)
FROM 'D:\sql\data_q4\submissions.csv' DELIMITER ',' CSV HEADER;

-- query 1
SELECT p.title AS p_title, c.title AS c_title
	FROM problems AS p
	INNER JOIN contests AS c ON p.contest_id = c.id
	INNER JOIN submissions AS s ON s.problem_id = p.id
	GROUP BY p.id, p.title, c.title
	ORDER BY COUNT(s.id) DESC, p.title, c.title;

-- query 2
SELECT c.title AS title, COUNT(DISTINCT s.user_id) AS amount
	FROM contests AS c
	INNER JOIN problems AS p ON c.id = p.contest_id
	INNER JOIN submissions AS s ON p.id = s.problem_id
	GROUP BY c.id, c.title
	ORDER BY amount DESC, title;
	
-- query 3
SELECT res.uname AS name, SUM(res.score) AS score
	FROM (SELECT u.id AS uid, p.id AS pid, u.name AS uname, MAX(s.score) AS score
		 	FROM problems AS p
		 	INNER JOIN contests AS c ON (p.contest_id = c.id) AND (c.title = 'mahale')
		 	INNER JOIN submissions AS s ON s.problem_id = p.id
		 	INNER JOIN users AS u ON s.user_id = u.id
		 	GROUP BY u.id, p.id, u.name) AS res
			GROUP BY res.uid, res.uname
			ORDER BY score DESC, res.uname;
			
-- query 4
SELECT res.uname AS name, COALESCE(SUM(res.score), 0) AS score
	FROM (SELECT u.id AS uid, p.id AS pid, u.name AS uname, MAX(s.score) AS score
		 	FROM problems AS p
		 	LEFT JOIN contests AS c ON (p.contest_id = c.id)
		 	LEFT JOIN submissions AS s ON s.problem_id = p.id
		 	RIGHT JOIN users AS u ON s.user_id = u.id
		 	GROUP BY u.id, p.id, u.name) AS res
			GROUP BY res.uid, res.uname
			ORDER BY score DESC, res.uname;

-- query 5
UPDATE contests
	SET title = 'Mosabeghe Mahale'
	WHERE title = 'mahale';
	
-- query 6
DELETE FROM contests
	WHERE id != ALL (SELECT c.id 
					 	FROM submissions AS s
						INNER JOIN problems AS p ON s.problem_id = p.id
						INNER jOIN contests AS c ON p.contest_id = c.id);
