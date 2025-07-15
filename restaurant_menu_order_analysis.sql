/*====================================================================
  Restaurant Order & Menu Analysis
  --------------------------------------------------------------------
  Description:
  This script explores "menu_items" and "order_details" to answer key
  business questions about pricing, category mix, ordering patterns,
  and revenue.  It is organised into three sections that can be run
  independently.

  Assumptions:
  • A database named "restaurant_db" exists.
  • Tables:
      - menu_items(menu_item_id, item_name, category, price)
      - order_details(order_id, item_id, order_date)
=====================================================================*/

USE restaurant_db;

/*───────────────────────────────
  SECTION 1  –  Menu Exploration
────────────────────────────────*/

-- 1.1  Preview the full menu
SELECT *
FROM menu_items;

-- 1.2  Count total items on the menu
SELECT COUNT(*) AS total_menu_items
FROM menu_items;

-- 1.3  Identify the least‑ and most‑expensive menu items
SELECT *
FROM menu_items
ORDER BY price ASC;   -- Least expensive first

SELECT *
FROM menu_items
ORDER BY price DESC;  -- Most expensive first

-- 1.4  Italian‑category deep‑dive
--      a) Number of Italian dishes
SELECT COUNT(*) AS italian_count
FROM menu_items
WHERE category = 'Italian';

--      b) Cheapest and priciest Italian dishes
SELECT *
FROM menu_items
WHERE category = 'Italian'
  AND price = (SELECT MIN(price) FROM menu_items WHERE category = 'Italian');

SELECT *
FROM menu_items
WHERE category = 'Italian'
  AND price = (SELECT MAX(price) FROM menu_items WHERE category = 'Italian');

-- 1.5  Category mix – how many dishes per category?
SELECT category,
       COUNT(item_name) AS items_in_category
FROM menu_items
GROUP BY category;

-- 1.6  Average price by category
SELECT category,
       AVG(price) AS avg_price
FROM menu_items
GROUP BY category;

/*────────────────────────────────────
  SECTION 2  –  Order‑Level Analytics
────────────────────────────────────*/

-- 2.1  Preview order details
SELECT *
FROM order_details;

-- 2.2  Determine date range covered by the data set
SELECT MIN(order_date) AS first_order,
       MAX(order_date) AS last_order
FROM order_details;

-- 2.3  High‑level order volume metrics
--      a) Distinct orders in the period
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM order_details;

--      b) Total items ordered in the period
SELECT COUNT(*) AS total_items_ordered
FROM order_details;

-- 2.4  Orders with the largest item counts
SELECT order_id,
       COUNT(item_id) AS item_count
FROM order_details
GROUP BY order_id
ORDER BY item_count DESC;

-- 2.5  How many orders contained more than 12 items?
SELECT COUNT(*) AS orders_over_12_items
FROM (
  SELECT order_id
  FROM order_details
  GROUP BY order_id
  HAVING COUNT(item_id) > 12
) AS big_orders;

/*───────────────────────────────────────────
  SECTION 3  –  Menu × Order Blended Insights
────────────────────────────────────────────*/

-- 3.1  Join menu_items to order_details for holistic analysis
SELECT *
FROM menu_items AS m
LEFT JOIN order_details AS o
  ON m.menu_item_id = o.item_id;

-- 3.2  Least‑ and most‑ordered items + their categories
SELECT m.item_name,
       m.category,
       COUNT(o.item_id) AS times_ordered
FROM menu_items AS m
LEFT JOIN order_details AS o
  ON m.menu_item_id = o.item_id
GROUP BY m.item_name, m.category
ORDER BY times_ordered ASC;   -- Change to DESC for most‑ordered

-- 3.3  Top‑5 orders by spend
SELECT o.order_id,
       SUM(m.price) AS order_total
FROM menu_items AS m
LEFT JOIN order_details AS o
  ON m.menu_item_id = o.item_id
GROUP BY o.order_id
ORDER BY order_total DESC
LIMIT 5;

-- 3.4  Category breakdown for the highest‑spend order (e.g., order 440)
SELECT m.category,
       COUNT(o.item_id) AS items_in_category
FROM menu_items AS m
LEFT JOIN order_details AS o
  ON m.menu_item_id = o.item_id
WHERE o.order_id = 440
GROUP BY m.category;

-- 3.5  Category mix for the top‑5 spenders (orders 440, 2075, 1957, 330, 2675)
SELECT o.order_id,
       m.category,
       COUNT(o.item_id) AS items_in_category
FROM menu_items AS m
LEFT JOIN order_details AS o
  ON m.menu_item_id = o.item_id
WHERE o.order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY o.order_id, m.category;

/*───────────────────────────
  End of Script – Happy Querying!
────────────────────────────*/
