/*1. Write a query to display customer full name with their title (Mr/Ms), 
--both first name and last name are in upper case, customer email id, 
customer creation date and display customer’s category after applying below categorization rules: 
i) IF customer creation date Year <2005 Then Category A 
ii) IF customer creation date Year >=2005 and <2011 Then Category B 
iii)IF customer creation date Year>= 2011 Then Category C 
Hint: Use CASE statement, no permanent change in table required. [NOTE: TABLES to be used - ONLINE_CUSTOMER TABLE]*/
    
SELECT 
    CASE 
        WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A' 
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
        ELSE 'Category C'
    END AS Category,
    CONCAT(
        CASE CUSTOMER_GENDER
            WHEN 'M' THEN 'Mr.'
            WHEN 'F' THEN 'Ms.'
            ELSE ''
        END,
        ' ',
        UPPER(CUSTOMER_FNAME),
        ' ',
        UPPER(CUSTOMER_LNAME)
    ) AS Customer_Name,
    UPPER(CUSTOMER_EMAIL) AS Customer_Email,
    CUSTOMER_CREATION_DATE
FROM 
    ONLINE_CUSTOMER;

SELECT 
    CASE 
        WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A' 
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
        ELSE 'Category C'
    END AS Category,
    CASE CUSTOMER_GENDER
        WHEN 'M' THEN 'Mr.'
        WHEN 'F' THEN 'Ms.'
        ELSE ''
    END AS Title,
    CONCAT(
        UPPER(CUSTOMER_FNAME),
        ' ',
        UPPER(CUSTOMER_LNAME)
    ) AS Customer_Name,
    UPPER(CUSTOMER_EMAIL) AS Customer_Email,
    CUSTOMER_CREATION_DATE
FROM 
    ONLINE_CUSTOMER;

/* #2. Write a query to display the following information for the products, 
which have not been sold: product_id, product_desc, product_quantity_avail, product_price, 
inventory values (product_quantity_avail*product_price), New_Price after applying discount as per below criteria.
Sort the output with respect to decreasing value of Inventory_Value. 
i) IF Product Price > 20,000 then apply 20% discount 
ii) IF Product Price > 10,000 then apply 15% discount 
iii) IF Product Price =< 10,000 then apply 10% discount 
# Hint: Use CASE statement, no permanent change in table required. 
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]*/

SELECT p.product_id, p.product_desc, p.product_quantity_avail, p.product_price, 
    (p.product_quantity_avail * p.product_price) AS Inventory_Value,
    CASE 
        WHEN p.product_price > 20000 THEN (p.product_price * 0.8)
        WHEN p.product_price > 10000 THEN (p.product_price * 0.85)
        ELSE (p.product_price * 0.9)
    END AS New_Price
FROM product p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
ORDER BY Inventory_Value DESC;

/*3. Write a query to display Product_class_code, Product_class_description, 
Count of Product type in each productclass, Inventory Value (product_quantity_avail*product_price). 
Information should be displayed for only those product_class_code which have more than 1,00,000. Inventory Value. 
Sort the output with respect to decreasing value of Inventory_Value. 
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]*/
  
  SELECT pc.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC, COUNT(DISTINCT p.PRODUCT_ID) AS PRODUCT_TYPES, 
SUM(p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE) AS INVENTORY_VALUE 
FROM PRODUCT p 
INNER JOIN PRODUCT_CLASS pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE 
GROUP BY pc.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC 
HAVING INVENTORY_VALUE > 100000 
ORDER BY INVENTORY_VALUE DESC;

/*4. Write a query to display customer_id, full name, customer_email, customer_phone and country of customers
 who have cancelled all the orders placed by them (USE SUB-QUERY)
 [NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]*/
 
SELECT customer_id, CONCAT(CUSTOMER_FNAME, ' ', CUSTOMER_LNAME) AS full_name, customer_email, customer_phone, country
FROM ONLINE_CUSTOMER 
JOIN ADDRESS ON ONLINE_CUSTOMER.address_id = ADDRESS.address_id 
WHERE customer_id IN 
   (SELECT customer_id 
    FROM ORDER_HEADER 
    WHERE order_status = 'Cancelled'
    GROUP BY customer_id
    HAVING COUNT(*) = (SELECT COUNT(*) 
                       FROM ORDER_HEADER 
                       WHERE customer_id = ONLINE_CUSTOMER.customer_id));

/*5. Write a query to display Shipper name, City to which it is catering, number of customers catered by the shipper 
in the city and number of consignments delivered to that city for Shipper DHL 
[NOTE: TABLES to be used - SHIPPER,ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]*/

SELECT s.shipper_name, c.city, COUNT(DISTINCT oc.customer_id) AS customers_catered, 
COUNT(DISTINCT oh.order_id) AS consignments_delivered
FROM SHIPPER s
JOIN ORDER_HEADER oh ON s.shipper_id = oh.shipper_id
JOIN ONLINE_CUSTOMER oc ON oh.customer_id = oc.customer_id
JOIN ADDRESS c ON oc.address_id = c.address_id
WHERE s.shipper_name = 'DHL'
GROUP BY s.shipper_name, c.city;

/*6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and show 
inventory Status of products as below as per below condition: 
a. For Electronics and Computer categories, if sales till date is Zero then show 
'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 
'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 
'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 50% of quantity sold, show 
'Sufficient inventory' 
b. For Mobiles and Watches categories, if sales till date is Zero then show 
'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 
'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 
'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 
'Sufficient inventory' 
c. Rest of the categories, if sales till date is Zero then show 
'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 
'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 
'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 70% of quantity sold, show 
'Sufficient inventory' 
-- (USE SUB-QUERY) -- [NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]*/

SELECT 
   p.product_id, 
   p.product_desc, 
   p.product_quantity_avail, 
   SUM(oi.PRODUCT_QUANTITY) AS quantity_sold,
   CASE 
     -- Electronics and Computer categories
     WHEN pc.PRODUCT_CLASS_DESC IN ('Electronics', 'Computer') THEN 
       CASE 
         WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
         WHEN p.product_quantity_avail < (0.1 * SUM(oi.PRODUCT_QUANTITY)) THEN 'Low inventory, need to add inventory'
         WHEN p.product_quantity_avail < (0.5 * SUM(oi.PRODUCT_QUANTITY)) THEN 'Medium inventory, need to add some inventory'
         ELSE 'Sufficient inventory'
       END
     -- Mobiles and Watches categories
     WHEN pc.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN 
       CASE 
         WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
         WHEN p.product_quantity_avail < (0.2 * SUM(oi.PRODUCT_QUANTITY)) THEN 'Low inventory, need to add inventory'
         WHEN p.product_quantity_avail < (0.6 * SUM(oi.PRODUCT_QUANTITY)) THEN 'Medium inventory, need to add some inventory'
         ELSE 'Sufficient inventory'
       END
     -- Rest of the categories
     ELSE 
       CASE 
         WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
         WHEN p.product_quantity_avail < (0.3 * SUM(oi.PRODUCT_QUANTITY)) THEN 'Low inventory, need to add inventory'
         WHEN p.product_quantity_avail < (0.7 * SUM(oi.PRODUCT_QUANTITY)) THEN 'Medium inventory, need to add some inventory'
         ELSE 'Sufficient inventory'
       END
   END AS inventory_status
 FROM 
   PRODUCT p 
   INNER JOIN PRODUCT_CLASS pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE 
   LEFT JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id 
 GROUP BY 
   p.product_id, 
   p.product_desc, 
   p.product_quantity_avail, 
   pc.PRODUCT_CLASS_DESC,
   oi.PRODUCT_QUANTITY;

/*7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit 
in carton id 10 -- [NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]*/

SELECT oi.ORDER_ID, SUM(p.LEN * p.WIDTH * p.HEIGHT * oi.PRODUCT_QUANTITY) AS VOLUME
FROM order_items oi
INNER JOIN product p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE p.LEN * p.WIDTH * p.HEIGHT * oi.PRODUCT_QUANTITY <= (
  SELECT c.LEN * c.WIDTH * c.HEIGHT 
  FROM carton c
  WHERE c.CARTON_ID = 10
)
GROUP BY oi.ORDER_ID
ORDER BY VOLUME DESC
LIMIT 1;

/*8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G' 
--[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]*/

SELECT c.CUSTOMER_ID, CONCAT(c.CUSTOMER_FNAME, ' ', c.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME,
       SUM(oi.PRODUCT_QUANTITY) AS TOTAL_QUANTITY, 
       SUM(oi.PRODUCT_QUANTITY * p.PRODUCT_PRICE) AS TOTAL_VALUE
FROM online_customer c
INNER JOIN order_header oh ON c.CUSTOMER_ID = oh.CUSTOMER_ID
INNER JOIN order_items oi ON oh.ORDER_ID = oi.ORDER_ID
INNER JOIN product p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE oh.PAYMENT_MODE = 'Cash' AND c.CUSTOMER_LNAME LIKE 'G%'
GROUP BY c.CUSTOMER_ID, CUSTOMER_FULL_NAME;

/*9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
Display the output in descending order with respect to the tot_qty.
 -- (USE SUB-QUERY) -- [NOTE: TABLES to be used - order_items, product,order_header, online_customer, address]*/

SELECT p.product_id, p.product_desc, SUM(oi2.product_quantity) AS tot_qty
FROM order_items oi1
INNER JOIN order_header oh1 ON oi1.order_id = oh1.order_id
INNER JOIN online_customer oc ON oh1.customer_id = oc.customer_id
INNER JOIN address a ON oc.address_id = a.address_id
INNER JOIN product p ON oi1.product_id = p.product_id
INNER JOIN order_items oi2 ON oh1.order_id = oi2.order_id AND oi2.product_id <> oi1.product_id
INNER JOIN order_header oh2 ON oi2.order_id = oh2.order_id
WHERE oi1.product_id = 201
AND a.city NOT IN ('Bangalore', 'New Delhi')
AND oh2.order_shipment_date IS NOT NULL
GROUP BY p.product_id, p.product_desc
ORDER BY tot_qty DESC;

SELECT p1.product_id, p1.product_desc, SUM(oi1.product_quantity) AS tot_qty
FROM product p1
INNER JOIN order_items oi1 ON oi1.product_id = p1.product_id
INNER JOIN order_header oh1 ON oh1.order_id = oi1.order_id
INNER JOIN online_customer oc1 ON oc1.customer_id = oh1.customer_id
INNER JOIN address a1 ON a1.address_id = oc1.address_id
WHERE oi1.order_id IN (
  SELECT oi2.order_id
  FROM order_items oi2
  INNER JOIN order_header oh2 ON oh2.order_id = oi2.order_id
  INNER JOIN online_customer oc2 ON oc2.customer_id = oh2.customer_id
  INNER JOIN address a2 ON a2.address_id = oc2.address_id
  WHERE oi2.product_id = 201 AND a2.city NOT IN ('Bangalore', 'New Delhi')
)
AND oi1.product_id <> 201
AND a1.city NOT IN ('Bangalore', 'New Delhi')
GROUP BY p1.product_id, p1.product_desc
ORDER BY tot_qty DESC;

/*10. Write a query to display the order_id,customer_id and customer fullname, total quantity of 
products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
-- [NOTE: TABLES to be used - online_customer,Order_header, order_items,address]*/

SELECT oh.order_id, oh.customer_id, oc.customer_fullname, SUM(oi.quantity) AS total_quantity
FROM Order_header oh
JOIN online_customer oc ON oh.customer_id = oc.customer_id
JOIN order_items oi ON oh.order_id = oi.order_id
JOIN address a ON oh.shipping_address_id = a.address_id
WHERE oh.order_id % 2 = 0 AND a.pincode NOT LIKE '5%'
GROUP BY oh.order_id, oh.customer_id, oc.customer_fullname;

SELECT oh.ORDER_ID, oh.CUSTOMER_ID, oc.CUSTOMER_FNAME, oc.CUSTOMER_LNAME, SUM(oi.PRODUCT_QUANTITY) AS total_quantity
FROM online_customer oc
JOIN order_header oh ON oc.CUSTOMER_ID = oh.CUSTOMER_ID
JOIN order_items oi ON oh.ORDER_ID = oi.ORDER_ID
JOIN address a ON oh.SHIPPER_ID = a.ADDRESS_ID
WHERE oh.ORDER_ID % 2 = 0 AND a.PINCODE NOT LIKE '5%'
GROUP BY oh.ORDER_ID, oh.CUSTOMER_ID, oc.CUSTOMER_FNAME, oc.CUSTOMER_LNAME;
