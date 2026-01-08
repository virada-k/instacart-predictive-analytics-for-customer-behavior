

-- Find the day with the highest customers order volumn to prepare the stock.

SELECT
    CASE
      WHEN order_dow = 0 THEN 'Sunday'
      WHEN order_dow = 1 THEN 'Monday'
      WHEN order_dow = 2 THEN 'Tuesday'
      WHEN order_dow = 3 THEN 'Wednesday'
      WHEN order_dow = 4 THEN 'Thursday'
      WHEN order_dow = 5 THEN 'Friday'
      ELSE 'Saturday'
    END AS day_of_week, 
    COUNT(*) AS count_order_day
FROM orders
GROUP BY order_dow
ORDER BY count_order_day DESC;

-- ☞ From the result show that the three days with the highest number of product orders are Sunday to Tuesday.
