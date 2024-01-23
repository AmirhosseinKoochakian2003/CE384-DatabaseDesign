CREATE TABLE offices (
    officeCode VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50),
    phone VARCHAR(50),
    addressLine1 VARCHAR(50),
    addressLine2 VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postalCode VARCHAR(15),
    territory VARCHAR(10)
);

CREATE TABLE employees (
    employeeNumber INTEGER PRIMARY KEY,
    lastName VARCHAR(50),
    firstName VARCHAR(50),
    extension VARCHAR(10),
    email VARCHAR(100),
    officeCode VARCHAR(10),
    reportsTo INTEGER,
    jobTitle VARCHAR(50),
	
	CONSTRAINT fk_oc FOREIGN KEY (officeCode) REFERENCES offices(officeCode)
);

CREATE TABLE customers (
    customerNumber INTEGER PRIMARY KEY,
    customerName VARCHAR(50),
    contactLastName VARCHAR(50),
    contactFirstName VARCHAR(50),
    phone VARCHAR(50),
    addressLine1 VARCHAR(50),
    addressLine2 VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postalCode VARCHAR(15),
    country VARCHAR(50),
    salesRepEmployeeNumber INTEGER,
    creditLimit DECIMAL(10,2),
	
	CONSTRAINT fk_sren FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees (employeeNumber)
);

CREATE TABLE orders (
    orderNumber INTEGER PRIMARY KEY,
    orderDate DATE,
    requiredDate DATE,
    shippedDate DATE,
    status VARCHAR(15),
    comments TEXT,
    customerNumber INT,
	
	CONSTRAINT fk_cn FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber)
);

CREATE TABLE payments (
    customerNumber INTEGER,
    checkNumber VARCHAR(15),
    paymentDate DATE,
    amount DECIMAL(10,2)
);

CREATE TABLE productlines (
    productLine VARCHAR(50) PRIMARY KEY,
    textDescription VARCHAR(4000),
    htmlDescription TEXT,
    image BYTEA
);

CREATE TABLE products (
    productCode VARCHAR(15) PRIMARY KEY,
    productName VARCHAR(70),
    productLine VARCHAR(50),
    productScale VARCHAR(10),
    productVendor VARCHAR(50),
    productDescription TEXT,
    quantityInStock SMALLINT,
    buyPrice DECIMAL(10,2),
    MSRP DECIMAL(10,2),
	
	CONSTRAINT fk_pl FOREIGN KEY (productLine) REFERENCES productLines (productLine)
);

CREATE TABLE orderdetails (
    orderNumber INTEGER,
    productCode VARCHAR(15),
    quantityOrdered INT,
    priceEach DECIMAL(10,2),
    orderLineNumber SMALLINT,
	
    CONSTRAINT pk_on_pc PRIMARY KEY (orderNumber, productCode),
	CONSTRAINT fk_on FOREIGN KEY (orderNumber) REFERENCES orders (orderNumber),
	CONSTRAINT fk_pc FOREIGN KEY (productCode) REFERENCES products (productCode)
);

COPY offices (officeCode, city, phone, addressLine1, addressLine2, state, country, postalCode, territory)
FROM 'D:\sql\data_q3\offices.csv'  DELIMITER ',' CSV NULL '' HEADER;

COPY employees (employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
FROM 'D:\sql\data_q3\employees.csv'  DELIMITER ',' CSV NULL '' HEADER;

COPY customers (customerNumber, customerName, contactLastName, contactFirstName, phone, addressLine1, addressLine2, city, state, postalCode, country, salesRepEmployeeNumber, creditLimit)
FROM 'D:\sql\data_q3\customers.csv'  DELIMITER ',' CSV NULL '' HEADER;

COPY orders (orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber)
FROM 'D:\sql\data_q3\orders.csv'  DELIMITER ',' CSV NULL '' HEADER;

COPY productlines (productLine, textDescription, htmlDescription, image)
FROM 'D:\sql\data_q3\productlines.csv'  DELIMITER ',' CSV NULL '' HEADER;

COPY products (productCode, productName, productLine, productScale, productVendor, productDescription, quantityInStock, buyPrice, MSRP)
FROM 'D:\sql\data_q3\products.csv'  DELIMITER ',' CSV NULL '' HEADER;

COPY payments (customerNumber, checkNumber, paymentDate, amount)
FROM 'D:\sql\data_q3\payments.csv'  DELIMITER ',' CSV NULL '' HEADER;

COPY orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
FROM 'D:\sql\data_q3\orderdetails.csv'  DELIMITER ',' CSV NULL '' HEADER;

-- query 1
SELECT e.employeeNumber AS employeeNumber, CONCAT(e.firstName, ' ', e.lastName) AS Name, COUNT(c.customerNumber) AS CustomersCount
	FROM employees AS e 
	INNER JOIN customers AS c ON e.employeeNumber = c.salesRepEmployeeNumber
	GROUP BY e.employeeNumber
	ORDER BY CustomersCount DESC;

-- query 2
SELECT res.customerNumber AS customerNumber
	FROM (SELECT o.customerNumber, SUM(od.quantityOrdered * od.priceEach) AS p FROM
		  orders AS o 
		  INNER JOIN orderDetails AS od ON o.orderNumber = od.orderNumber
		  GROUP BY o.customerNumber) AS res
	ORDER BY res.p DESC
	LIMIT 5;
	
-- query 3
SELECT res.productLine, res.productName, res.value, res.value_rank 
	FROM (SELECT pl.productLine, p.productName, p.quantityInStock * (p.MSRP - p.buyPrice) AS value, 
		  RANK() OVER (
    		PARTITION BY pl.productLine
    		ORDER BY p.quantityInStock * (p.MSRP - p.buyPrice) DESC) AS value_rank
		  FROM products AS p 
		  INNER JOIN productLines As pl ON p.productLine = pl.productLine
		 ) AS res;
