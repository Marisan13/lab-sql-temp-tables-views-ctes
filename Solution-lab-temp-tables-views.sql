# Step 1: Create a View
# First, create a view that summarizes rental information for each customer. 
# The view should include the customer's ID, name, email address, and total number of rentals (rental_count). 
create view customer_rental as
select customer.customer_id, concat(first_name, " ", last_name) as customer_name, email, count(rental_id) as rental_count
from sakila.customer
join sakila.rental
on customer.customer_id = rental.customer_id
group by customer_id, customer_name, email;
   
select * from customer_rental;

# Step 2: Create a Temporary Table
# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
# The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer. 
select * from customer;
create temporary table customer_payment as (
											select payment.customer_id, customer_name, sum(amount) as total_paid
                                            from customer_rental
											join sakila.payment
											on customer_rental.customer_id = payment.customer_id
											group by customer_id, customer_name);
select * from customer_payment;

# Step 3: Create a CTE and the Customer Summary Report 
# Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
# The CTE should include the customer's name, email address, rental count, and total amount paid. 

with summarized_customer_info as (
                                  select customer_rental.customer_id, customer_rental.customer_name, email, rental_count, total_paid
                                  from customer_rental
						          join customer_payment
                                  on customer_rental.customer_id = customer_payment.customer_id)

# Next, using the CTE, create the query to generate the final customer summary report, which should include: 
# customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
select customer_name, email, rental_count, total_paid, round(avg(total_paid/rental_count),2) as average_payment_per_rental
from summarized_customer_info
group by customer_name, email, rental_count, total_paid;