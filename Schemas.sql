-- CREATE DATABSE
create database amazon_db ;
use amazon_db ;

-- CREATE TABLES

-- 1. Category table 

select count(*) from category ;
select * from category ;

alter table category
modify category_name varchar(20) ;

-- 2. Customers table 

create table customers 
(customer_id int primary key, first_name varchar(20),
 last_name varchar(20), state varchar(20), 
 address varchar(5) default('xxxx') ) ;

select * from customers ;
select count(*) from customers ;

-- 3. Seller table 

create table sellers 
( seller_id int primary key, seller_name varchar(25), 
origin varchar(5)) ;

select * from sellers  ;
select count(*) from sellers  ;

-- 4. Products table

create table products 
(product_id int primary key, product_name varchar(50), 
price float, cogs float, category_id int ,
CONSTRAINT product_fk_category foreign key(category_id) references category(category_id) ) ;
 
 select * from products ;
 select count(*) from products ;

-- 5. Orders table

create table orders 
(order_id int primary key, order_date date, customer_id int, seller_id int, 
order_status varchar(15) ,
CONSTRAINT orders_fk_customers foreign key(customer_id) references customers (customer_id), 
CONSTRAINT orders_fk_sellers foreign key(seller_id ) references sellers (seller_id ) ) ;

select * from orders ;
select count(*) from orders ;

-- 6. Order_items table
 
create table order_items 
(order_item_id int primary key, order_id int, 
product_id int, quantity int, price_per_unit float,
CONSTRAINT orders_items_fk_orders foreign key(order_id) references orders (order_id), 
CONSTRAINT orders_items_fk_products foreign key(product_id ) references products (product_id) );

select * from order_items ;
select count(*) from order_items ;

-- 7. Payments table

create table payments 
( payment_id int primary key, order_id int, payment_date date, 
  payment_status varchar(20),
  CONSTRAINT payments_fk_orders foreign key(order_id) references orders (order_id) );

select * from payments  ;
select count(*) from payments  ;

-- 8. Shipping table

create table shipping 
( shipping_id int primary key, order_id int, shipping_date date, return_date date,
  shipping_providers varchar(15), delivery_status varchar(15) );
  
select * from shipping  ;
select count(*) from shipping ;

alter table shipping 
add CONSTRAINT shipping_fk_orders foreign key(order_id) references orders (order_id) ;
 
-- 9. Inventory table  

create table inventory
( inventory_id int primary key, product_id int, stock int, warehouse_id int,
  last_stock_date date,
  CONSTRAINT inventory_fk_products foreign key(product_id) references products (product_id) );

select * from inventory ;
select count(*) from inventory ;
