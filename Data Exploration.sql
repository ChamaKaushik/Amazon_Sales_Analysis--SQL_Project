-- EDA

select * from category ;
select * from customers ;
select * from sellers  ;
select * from products ;
select * from orders ;
select * from order_items ;
select * from payments ;
select * from shipping ;
select * from inventory ;

select count(distinct product_name) from products ;

select distinct order_status from orders ;

select distinct payment_status from payments ;

select distinct delivery_status from shipping ;

select * from shipping  
where return_date is not null;

select * from shipping 
where return_date is null;