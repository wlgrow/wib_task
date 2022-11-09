DROP DATABASE IF EXISTS task;
CREATE DATABASE task;
use task;


DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
	userid SERIAL,
	age INT NOT NULL,
	PRIMARY KEY (userid)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
INSERT INTO `Users` VALUES 
(1,24),
(2,23),
(3,24),
(4,20),
(5,25),
(6,30),
(7,31),
(8,44),
(9,22),
(10,61),
(11,53),
(12,43),
(13,18),
(14,41),
(15,30);
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;


DROP TABLE IF EXISTS Items;
CREATE TABLE Items (
	itemid SERIAL,
	price FLOAT NOT NULL,
	PRIMARY KEY (itemid)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


LOCK TABLES `Items` WRITE;
/*!40000 ALTER TABLE `Items` DISABLE KEYS */;
INSERT INTO `Items` VALUES 
(1,1000.5),
(2,1199),
(3,2678.33),
(4,9001),
(5,3450),
(6,900),
(7,1240),
(8,850.99),
(9,600),
(10,10500),
(11,24000),
(12,8500.5),
(13,5000),
(14,3000),
(15,1590);
/*!40000 ALTER TABLE `Items` ENABLE KEYS */;
UNLOCK TABLES;


DROP TABLE IF EXISTS Purchases;
CREATE TABLE Purchases (
	purchaseid SERIAL,
	userid BIGINT UNSIGNED NOT NULL,
	itemid BIGINT UNSIGNED NOT NULL,
	date DATETIME,
	PRIMARY KEY (purchaseid),
	CONSTRAINT users_f_key FOREIGN KEY (userid) REFERENCES Users(userid),
	CONSTRAINT items_f_key FOREIGN KEY (itemid) REFERENCES Items(itemid)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


LOCK TABLES `Purchases` WRITE;
/*!40000 ALTER TABLE `Purchases` DISABLE KEYS */;
INSERT INTO `Purchases` VALUES 
(1,15,8,'2021-01-06 07:31:13'),
(2,3,4,'2021-02-07 10:30:00'),
(3,12,9,'2021-02-07 11:21:10'),
(4,1,6,'2021-05-07 12:30:45'),
(5,2,5,'2021-06-07 19:45:12'),
(6,13,13,'2021-06-08 07:45:05'),
(7,8,10,'2021-10-08 07:31:10'),
(8,10,1,'2021-11-09 19:30:00'),
(9,11,3,'2021-12-10 11:40:55'),
(10,14,2,'2022-01-10 12:31:59'),
(11,4,8,'2022-01-10 14:31:41'),
(12,5,6,'2022-02-11 20:23:23'),
(13,9,7,'2022-02-12 07:56:46'),
(14,6,11,'2022-03-13 12:27:13'),
(15,7,8,'2022-04-14 07:31:12'),
(16,15,12,'2022-05-15 09:43:05'),
(17,15,15,'2022-06-16 07:23:07'),
(18,10,7,'2022-07-16 17:07:12'),
(19,1,2,'2022-09-17 11:10:47'),
(20,3,9,'2022-09-18 10:31:32');
/*!40000 ALTER TABLE `Purchases` ENABLE KEYS */;
UNLOCK TABLES;







-- SELECTS



--
-- A) какую сумму в среднем в месяц тратят пользователи в возрастном диапазоне от 18 до 25 лет включительно
--

SELECT ROUND(AVG(temp.m_orders), 2) as users_18_25_month_avg
FROM
(
SELECT 
SUM(i.price) as m_orders
FROM Purchases p 
Join Users u on p.userid = u.userid
Join Items i on p.itemid = i.itemid 
WHERE u.age >= 18 and u.age <= 25
GROUP BY EXTRACT(YEAR_MONTH FROM p.date)
) as temp;


--
-- A) какую сумму в среднем в месяц тратят пользователи в возрастном диапазоне от 26 до 35 лет включительно
--

SELECT ROUND(AVG(temp.m_orders), 2) as users_26_35_month_avg
FROM
(
SELECT 
SUM(i.price) as m_orders
FROM Purchases p 
Join Users u on p.userid = u.userid
Join Items i on p.itemid = i.itemid 
WHERE u.age >= 26 and u.age <= 35
GROUP BY EXTRACT(YEAR_MONTH FROM p.date)
) as temp;


--
-- Б) в каком месяце года выручка от пользователей в возрастном диапазоне 35+ самая большая
--


SELECT
ROUND(SUM(i.price), 2) as users_older_35_max_month
,EXTRACT(YEAR FROM p.date) as year_
,EXTRACT(MONTH FROM p.date) as month_number
FROM Purchases p 
Join Users u on p.userid = u.userid
Join Items i on p.itemid = i.itemid 
WHERE u.age >= 35
GROUP BY year_, month_number
ORDER BY users_older_35_max_month desc
LIMIT 1;


--
-- В) какой товар обеспечивает дает наибольший вклад в выручку за последний год
--
SELECT
temp.itemid as max_sales_item
,temp.sales
FROM
(
SELECT
i.itemid as itemid
,SUM(i.price) as sales
FROM Purchases p 
Join Users u on p.userid = u.userid
Join Items i on p.itemid = i.itemid 
WHERE EXTRACT(YEAR FROM p.date) = 2022
GROUP BY i.itemid
) as temp
ORDER BY temp.sales desc
LIMIT 1;




--
-- Г) топ-3 товаров по выручке и их доля в общей выручке за любой год
--
SET @year = 2022; 
SELECT
temp.itemid as max_sales_items
,temp.sales as year_sales
,temp.sales/year_sales.year_sales_sum as ratio
FROM
	(
	SELECT
	i.itemid as itemid
	,SUM(i.price) as sales
	FROM Purchases p 
	Join Users u on p.userid = u.userid
	Join Items i on p.itemid = i.itemid 
	WHERE EXTRACT(YEAR FROM p.date) = @year
	GROUP BY i.itemid
	) as temp,
	(
	SELECT SUM(i.price) as year_sales_sum
	FROM Purchases p 
	Join Items i on p.itemid = i.itemid 
	WHERE EXTRACT(YEAR FROM p.date) = @year
	) as year_sales
ORDER BY temp.sales desc
LIMIT 3;

