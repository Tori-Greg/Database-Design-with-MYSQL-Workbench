DROP SCHEMA IF EXISTS SereniCasa; -- This removes the schema/database if it previously existed
CREATE SCHEMA SereniCasa; -- This creates a new schema/database
USE SereniCasa; -- To set schema as default

-- After creating schema/database tables has to be created with columns
CREATE TABLE Customers-- Customers tables created
(
Customer_id BIGINT,
First_name VARCHAR(32),
Last_name VARCHAR(32),
Email VARCHAR(100),
Region VARCHAR(45),
Customer_type VARCHAR(45),
employee_attached BIGINT
);

DROP TABLE purchases;
CREATE TABLE Purchases -- purchases table created
(
Order_id BIGINT,
Customer_id BIGINT,
Product_id BIGINT,
Purchase_date DATE,
Payment_method VARCHAR(40),
Unit_price BIGINT,
Quantity BIGINT
);

CREATE TABLE Products -- Products table created
(
Product_id BIGINT,
Product_name VARCHAR(40),
Unit_price BIGINT,
Category VARCHAR(45),
Weight VARCHAR(45)
);

CREATE TABLE sales_employees -- Sales employees table created
(
Employee_id BIGINT,
First_name VARCHAR(50),
Last_name VARCHAR(50),
Start_date DATE
);
-- All tables have been generated, and data has been imported via the CSV file using the data import wizard.

------
-- Creating a stored procedure:
-- I have developed a stored procedure that displays the annual total purchases, broken down by month
-- to assist the manager in tracking actuals against budget.
DELIMITER // -- Changing the delimiter
-- Creating the procedure
CREATE PROCEDURE sp_totalpurchasesbreakdown()
BEGIN
SELECT 
	MONTHNAME(Purchase_date)Month,
    YEAR(Purchase_date)Year,
	SUM(Unit_price * Quantity)Total_amount
FROM purchases
GROUP BY 
	Month,
    Year;
END //
DELIMITER ; -- Changing the delimiter back to default

CALL sp_totalpurchasesbreakdown(); -- Calls the procedure we have created 

----

-- Creating Triggers: Created a Trigger to update purchases table with unit price from products table whenever a 
-- new purchase is made.
DELIMITER // -- It starts with DELIMITER // to change the delimiter temporarily to //. 
			-- This is necessary because the trigger body contains semicolons, and 
            -- changing the delimiter prevents conflicts.
CREATE TRIGGER updateprice
BEFORE INSERT ON purchases
FOR EACH ROW 
BEGIN
    DECLARE product_price DECIMAL(10, 2);

    -- Retrieving the Unit_price from the products table based on the Product_id
    SELECT Unit_price INTO product_price 
    FROM products
    WHERE Product_id = NEW.Product_id;
-- The SELECT statement retrieves the Unit_price from the products table based on the Product_id
--  of the new row being inserted into the purchases table. It stores the result in the product_price variable.

    -- Sets the Unit_price for the new row being inserted
    SET NEW.Unit_price = product_price;
END;
//
DELIMITER ;-- Changing delimiter back to default

  -- To confirm if trigger works i inserted new purchase orders without unit price
  INSERT INTO purchases (Order_id, Customer_id, Product_id, Purchase_date, Payment_method, Quantity) VALUES
  ('725', '1', '7486' , '2022-02-01', 'Credit', '1200'),
  ('726', '10', '7487' , '2022-02-03', 'Credit', '100'),
  ('727', '10', '7485' , '2022-02-02', 'Cash', '200'),
  ('728', '40', '7489' , '2022-02-03', 'Credit', '400');

  SELECT * FROM purchases; -- Selct statement to confirm accuracy of trigger created.
SHOW TRIGGERS -- To display triggers already created.    
    
