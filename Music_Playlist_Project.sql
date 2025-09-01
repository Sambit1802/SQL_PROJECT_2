 # Q1: Who is the senior most employee based on job title?
 
 select concat(first_name," ",last_name) as name, title as job_title ,levels
 from employee
 order by levels desc
 limit 1
 
 # Q2: Which countries have the most Invoices?

select billing_country, count(invoice_id) as no_of_Invoice
from invoice
group by billing_country
order by no_of_invoice desc
limit 1

# Q3: What are top 3 values of total invoice?

select round(total,2) as total from invoice
order by total desc
limit 3

/* Q4: Which city has the best customers?
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals. */

select billing_city, round(sum(total),2) as total_revenue
from invoice
group by billing_city
order by total_revenue desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select concat(c.first_name," ",c.last_name) as customer_name, round(sum(i.total),2) as total_spending
from invoice as i
left join customer as c
on i.customer_id=c.customer_id
group by customer_name
order by total_spending desc 
limit 1

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select c.email, c.first_name, c.last_name, g.name as genre
from customer as c
join invoice as i on c.customer_id=i.customer_id
join invoice_line as il on i.invoice_id=il.invoice_id
join track as t on il.track_id=t.track_id
join genre as g on t.genre_id=g.genre_id
where g.name = 'Rock'
group by email, first_name, last_name
order by email asc


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.artist_id,ar.name, count(a.artist_id) as no_of_songs
from track as t
join album2 as a on t.album_id=a.album_id
join artist as ar on a.artist_id=ar.artist_id
join genre as g on t.genre_id=g.genre_id
where g.name = 'Rock'
group by ar.artist_id,ar.name
order by no_of_songs desc
limit 10

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds 
from track 
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc

/* Q9: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ar.name AS artist_name,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_spent
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
        JOIN
    invoice_line AS il ON i.invoice_id = il.invoice_id
        JOIN
    track AS t ON il.track_id = t.track_id
        JOIN
    album AS a ON t.album_id = a.album_id
        JOIN
    artist AS ar ON a.artist_id = ar.artist_id
GROUP BY 1 , 2
ORDER BY 3 DESC;

/* Q10: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre.
For countries where the maximum number of purchases is shared return all Genres. */

select country,Genre,Purchase
from
(select c.country,g.name as Genre,count(il.quantity) as Purchase,
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) as Rowno
from customer as c
join invoice as i on c.customer_id=i.customer_id
join invoice_line as il on i.invoice_id=il.invoice_id
join track as t on il.track_id=t.track_id
join genre as g on t.genre_id=g.genre_id
group by 1,2
order by 3 desc) as sub
where Rowno = 1

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

select name,customer_id,billing_country,total_spending
from
(select concat(c.first_name," ",c.last_name) as name,i.customer_id,i.billing_country,
round(sum(i.total),2)as total_spending,
ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS RowNo
from invoice as i
join customer as c
on c.customer_id=i.customer_id
group by 1,2,3
order by 4 desc) as sub
where RowNo = 1
