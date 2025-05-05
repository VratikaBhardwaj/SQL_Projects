create database pizza_hut;

create table pizza_order(
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id)
);

-- Q1 - total number of order placed
 SELECT 
    COUNT(order_id) AS total_order
FROM
    order_details;

-- Q2 - total revenue from generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;  

-- Q3 - which is the highest priced pizza?
SELECT pizzas.price, pizza_types.name from pizzas
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by price desc limit 1;

-- Q4 which is the most common pizza size ordered?
SELECT count(order_details.quantity) as number_of_order, pizzas.size FROM order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size 
order by number_of_order desc;

-- Q5 top5 most ordered pizza type along with quantity
SELECT pizza_types.name, sum(order_details.quantity) as good_quantity
from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by good_quantity desc limit 5;

-- q6 join the necesaary table to find the total quantity of each pizza category ordered.
SELECT sum(order_details.quantity) as quantity, pizza_types.category
FROM pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantity desc;

-- q7 determine the distribution of orders by hour of the day
select hour(order_time) as hourtime, count(order_id) as orders
 from pizza_order
 group by hourtime;
 
-- q8 join relevant table to find the category-wise distribution of pizzas
select category, count(name) as pizza_names
from pizza_types
group by category
order by pizza_names;


-- q8 group the order by date and calculate the average number of pizza ordered per day
select avg(quantity) from (
select pizza_order.order_date as dates, sum(order_details.quantity) as quantity
from pizza_order join order_details 
on pizza_order.order_id = order_details.order_id
group by dates) as average;

-- q9 determine the top 3 most ordered pizza type based on revenue.
select pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by name
order by revenue desc limit 3;

-- calculate the percentage contribution of each pizza type to total revenue
SELECT 
    category, revenue
FROM
    (SELECT 
        pizza_types.category,
            SUM(pizzas.price * order_details.quantity) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100 AS revenue
    FROM
        pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_types.category
    ORDER BY revenue DESC) AS revenue;


-- Analyze the cumulative revenue generated over time
select dates, sum(revenue) over (order by dates) as cummulative_rev from
 (select pizza_order.order_date as dates, sum(pizzas.price * order_details.quantity) as revenue
 from pizza_order join order_details on pizza_order.order_id = order_details.order_id
 join pizzas on pizzas.pizza_id = order_details.pizza_id
 group by dates) as sales;
 
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
select name, category, revenue from 
(select category, name, revenue, RANK() over (partition by category order by revenue desc) as ranking from
(SELECT pizza_types.name, pizza_types.category, sum(pizzas.price * order_details.quantity) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name, pizza_types.category) as a) as b
where ranking <= 3;






