CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	username VARCHAR(255)
);

CREATE TABLE foods (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	recipe TEXT
);

CREATE TABLE ingredients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    price_per_unit DECIMAL(10, 2)
);

CREATE TABLE food_ingredients (
    id SERIAL PRIMARY KEY,
    food_id INT,
    ingredient_id INT,
    amount DECIMAL(10,2),
	
	CONSTRAINT fk_food_id FOREIGN KEY (food_id) REFERENCES foods (id),
	CONSTRAINT fk_ingredient_id FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
);

CREATE TABLE user_ingredients (
    id SERIAL PRIMARY KEY,
    user_id INT,
    ingredient_id INT,
    amount DECIMAL(10,2),
	
	CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id),
	CONSTRAINT fk_ingredient_id FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
);

CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    user_id INT,
    food_id INT,
    rate SMALLINT,
	
	CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id),
	CONSTRAINT fk_food_id FOREIGN KEY (food_id) REFERENCES foods (id)
);


COPY users(id, username)
FROM 'D:\sql\data_q2\users.csv' DELIMITER ',' CSV HEADER;

COPY foods(id, name, recipe)
FROM 'D:\sql\data_q2\foods.csv' DELIMITER ',' CSV HEADER;

COPY ingredients(id, name, price_per_unit)
FROM 'D:\sql\data_q2\ingredients.csv' DELIMITER ',' CSV HEADER;

COPY food_ingredients(id, food_id, ingredient_id, amount)
FROM 'D:\sql\data_q2\food_ingredients.csv' DELIMITER ',' CSV HEADER;

COPY user_ingredients(id, user_id, ingredient_id, amount)
FROM 'D:\sql\data_q2\user_ingredients.csv' DELIMITER ',' CSV HEADER;

COPY ratings(id, user_id, food_id, rate)
FROM 'D:\sql\data_q2\ratings.csv' DELIMITER ',' CSV HEADER;


-- query 1
UPDATE foods SET recipe = REPLACE(recipe, '@hamid_ashpazbashi2', '@hamid_ashpazbashi')
	WHERE recipe LIKE '%@hamid_ashpazbashi2%';
	
-- query 2
SELECT f.id, f.name, COALESCE(AVG(r.rate), 0) AS rating, COALESCE(COUNT(r.id), 0) AS rate_count 
	FROM foods AS f 
	LEFT JOIN ratings AS r ON f.id = r.food_id
	GROUP BY f.id 
	ORDER BY rating DESC, rate_count DESC, f.id DESC
	LIMIT 10;
	
-- query 3
SELECT f.id, f.name, f.recipe, COALESCE(SUM(COALESCE(fi.amount, 0) * i.price_per_unit), 0) AS total_price 
	FROM  foods AS f 
	LEFT JOIN food_ingredients AS fi ON f.id = fi.food_id
	LEFT JOIN ingredients AS i ON fi.ingredient_id = i.id
	GROUP BY f.id
	ORDER BY f.id;

-- query 4
SELECT f.id
	FROM foods f
	INNER JOIN food_ingredients AS fi ON f.id = fi.food_id
	INNER JOIN user_ingredients AS ui ON fi.ingredient_id = ui.ingredient_id
	INNER JOIN users AS u ON ui.user_id = u.id
 	GROUP BY f.id 
	HAVING BOOL_AND(ui.amount >= fi.amount)
	ORDER BY f.id DESC;




