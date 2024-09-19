#####################################################################################################################

									/*	Practice all type of questions */

#####################################################################################################################
create database chatgpt2;
use chatgpt2;
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    salary DECIMAL(10, 2),
    dept_id INT,
    manager_id INT,
    hire_date DATE,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    salesperson_id INT,
    sale_amount DECIMAL(10, 2),
    sale_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (salesperson_id) REFERENCES employees(emp_id)
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_total DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
INSERT INTO departments (dept_id, dept_name) VALUES
(1, 'Sales'),
(2, 'Engineering'),
(3, 'HR');
INSERT INTO employees (emp_id, first_name, last_name, salary, dept_id, manager_id, hire_date) VALUES
(1, 'John', 'Doe', 5000.00, 1, NULL, '2010-05-01'),
(2, 'Jane', 'Smith', 6000.00, 1, 1, '2012-03-15'),
(3, 'Michael', 'Johnson', 4500.00, 2, NULL, '2015-07-30');
INSERT INTO categories (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Books');

INSERT INTO products (product_id, product_name, category_id) VALUES
(1, 'Laptop', 1),
(2, 'Smartphone', 1),
(3, 'Novel', 2);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'Alice', 'Brown', 'alice.brown@example.com'),
(2, 'Bob', 'White', 'bob.white@example.com'),
(3, 'Charlie', 'Green', 'charlie.green@example.com');
INSERT INTO orders (order_id, customer_id, order_date, order_total) VALUES
(101, 1, '2024-01-10', 1500.00),
(102, 2, '2024-02-15', 2300.00),
(103, 3, '2024-03-20', 1200.00);
INSERT INTO sales (sale_id, product_id, salesperson_id, sale_amount, sale_date) VALUES
(201, 1, 2, 800.00, '2024-02-01'),
(202, 2, 1, 1200.00, '2024-02-10'),
(203, 3, 3, 500.00, '2024-03-05');
INSERT INTO accounts (account_id, customer_id, balance) VALUES
(301, 1, 5000.00),
(302, 2, 3500.00),
(303, 3, 2000.00);
CREATE TABLE managers (
    manager_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT
);
INSERT INTO managers (manager_id, first_name, last_name, department_id) VALUES
(1, 'Michael', 'Scott', 1),
(2, 'Leslie', 'Knope', 2),
(3, 'Jack', 'Donaghy', 3);



#####################################################################################################################
/*Write a query to find the employees who have not been assigned to any department. Use the employees and departments tables*/
select * from employees;
select * from departments;
select e.emp_id, e.first_name , d.dept_id from employees e 
join departments d on e.dept_id=d.dept_id
where d.dept_id is null;

#####################################################################################################################
# Write a query to find pairs of employees who are in the same department
select  e1.emp_id, e1.first_name, e2.emp_id, e2.first_name from employees e1
join employees e2 on e1.dept_id=e2.dept_id  and e1.emp_id< e2.emp_id 
order by e1.dept_id, e1.emp_id, e2.emp_id;

#####################################################################################################################
# Write a query to calculate the average salary for each department.
select * from employees;
select dept_id, avg(salary) as avg_sal from employees group by dept_id ;
#####################################################################################################################
# Find all departments that have more than 5 employees and the total salary they are paying.
select dept_id, count(*) as cnt , sum(salary) as total from employees group by dept_id having cnt>5;
#####################################################################################################################
# Write a query to find employees whose salary is above the average salary in their department.
select first_name , salary from employees e where salary >(select avg(salary) as cc from employees WHERE 
            dept_id = e.dept_id) ;
#####################################################################################################################
# Write a query to find all employees and managers from two separate tables (employees, managers). Combine the results using UNION and avoid duplicates.
select * from employees;
select * from managers;
SELECT 
    emp_id AS id, 
    first_name, 
    last_name, 
    'Employee' AS role
FROM 
    employees

UNION

SELECT 
    manager_id AS id, 
    first_name, 
    last_name, 
    'Manager' AS role
FROM 
    managers;
#####################################################################################################################
# Write a query to rank employees within each department based on their salary using the RANK() window function.
select emp_id, salary, dept_id ,rank() over(partition by dept_id order by salary  ) as rnk from employees;
#####################################################################################################################
# Write a CTE that calculates the total sales for each salesperson and then use it to find the top 3 salespeople.
select * from sales;
with ss as (select salesperson_id, sum(sale_amount) as x, dense_rank() over ( order by sum(sale_amount) desc) as xx from sales group by salesperson_id )
select salesperson_id, x from ss where xx<=3;
#####################################################################################################################
#Create a view that displays the total sales for each product category.

select * from sales;
select * from products;
create view r as 
select  p.category_id , p.product_name, p.product_id, sum(s.sale_amount) as total from sales s 
join products p on p.product_id=s.product_id
join categories c on c.category_id=p.category_id
group by p.category_id,p.product_name, p.product_id;

select * from r;
#####################################################################################################################
# Write a transaction that deducts an amount from one account and adds it to another. Ensure that both operations are completed successfully, or neither is applied.
start transaction;
update account
set balance=balance-100
where account_id=1;
update account
set balance=balance+100;
if @@error <> 0 then 
	Rollback;
else
	commit;
end if;
#####################################################################################################################
# Explain how to create an index on the email column in the customers table. What is the advantage of indexing?
select * from customers;
create index ss on customers(email);
#####################################################################################################################
# Write a stored procedure that takes a department ID as an input and returns all employees in that department.
delimiter //
create procedure all_emp(in ddept_id int )
begin
	select dept_id, emp_id , concat(first_name ," ", last_name) as full_name 
	from employees where dept_id=ddept_id;
end //
delimiter ;

call all_emp(2);
#####################################################################################################################
# Write a query that classifies employees into salary bands (low, medium, high) based on their salary.
select * from employees;
select emp_id, salary,
		case 
			when salary <5000 then "low"
            when salary >=5000 and salary < 5999 then "medium"
            else "HIgh"
		end  as ss
from employees;
#####################################################################################################################
# Write a query to extract the domain name (everything after @) from the email addresses in the customers table.
select * from customers;
select customer_id ,email,  substring_index(email, "@",  -1) as domain from customers;
#####################################################################################################################
# Write a query to find all orders that were placed in the last 30 days.
select * from orders;
select * from orders where order_date >=date_sub(curdate(), interval 30 day);

#####################################################################################################################
# after @ and before .com
select email, substring(email, locate("@", email)+1, locate(".com",email)-locate("@", email)-1) as x from customers;
#####################################################################################################################

											# sting manipulation#
                                            
#####################################################################################################################
# 1. Extract Domain Name from Email (Customers Table)
select email, substring_index(email,"@", -1) as domain from customers;
#####################################################################################################################
# 2. Extract Part of Email Between @ and .com (Customers Table)
select email, substring(email, locate("@", email) + 1, locate(".com", email)-locate("@",email) -1 ) as domain from customers;

#####################################################################################################################
# 3. Format Product Names to Upper Case (Products Table)
select * from products;
select product_id, upper(product_name) as un from products;

#####################################################################################################################
# 4. ind employees whose last names are longer than 8 characters.
select emp_id, last_name from employees where length(last_name) >4; 

#####################################################################################################################
# 5.  Check if email domain matches a specific pattern (e.g., all emails should be from "example.com").
select email, 
case 
	when substring_index(email, "@", -1) = "example.com" then "valid"
	else "Invalid"
end as email_status
from customers;
#####################################################################################################################
# 6. extract a year 
select substring(sale_date, 1,4) from sales;
#####################################################################################################################
# 7. extract a month 
select substring(sale_date, 6,2) from sales;
#####################################################################################################################
# 8. extract a day 
select substring(sale_date, 9,2) from sales;
#####################################################################################################################
# 10. Extract  Name from Email (Customers Table)
select email, substring_index(email,"@", +1) as name from customers;
#####################################################################################################################
# 11. find the position of "@" in each email
SELECT LOCATE('@', email) AS at_position
FROM customers;






















        