--Query entire table to study dataset
SELECT *
FROM Dataset$;

----Total amount made per event from tickets sold
SELECT caldate1, eventname, priceperticket * qtysold As total_ticket_price
FROM Dataset$;

--Overall total amount made from ticket sales
SELECT SUM(priceperticket * qtysold) AS total_amount_made
FROM Dataset$;

--What event category brought in more revenue from ticket sales? Shows or Concerts?
WITH total_sales_by_event_category AS (
        SELECT caldate1, eventname, event_category, priceperticket * qtysold As total_ticket_price
        FROM Dataset$
					)
   SELECT event_category, SUM(total_ticket_price) AS total_ticket_sales
   FROM total_sales_by_event_category
   GROUP BY event_category
   ORDER BY SUM(total_ticket_price) DESC;

--Top 10 events with highest ticket sales
   SELECT TOP 10(eventname), event_category, SUM(priceperticket *qtysold) As total_ticket_price
   FROM Dataset$
   GROUP BY eventname, event_category
   ORDER BY SUM(priceperticket *qtysold) DESC;



