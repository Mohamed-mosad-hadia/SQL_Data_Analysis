USE hotels;
-- Q1: What is the profit percentage for each month across all years?
		-- profit pre = (profit *100 ) / Cost price 
		-- profit = S.p - C.p  
		-- Revenue= Selling price S.p = ADR * (weekend +weeks)*(1-market_segment_table)
-- Combine tables from different years into one
WITH Hotels AS (
    SELECT * FROM y2018
    UNION ALL
    SELECT * FROM y2019
    UNION ALL
    SELECT * FROM y2020
),

-- Calculate total revenue for each month
revenue_table AS (
    SELECT 
        (Hotels.stays_in_weekend_nights + Hotels.stays_in_week_nights) * Hotels.adr * (1 - market_segment.Discount) AS total_revenue,
        Hotels.arrival_date_year, 
        Hotels.arrival_date_month
    FROM
        Hotels 
    LEFT JOIN 
        market_segment
    ON 
        Hotels.market_segment = market_segment.market_segment 
    WHERE 
        Hotels.reservation_status NOT LIKE 'Canceled'
)

-- Calculate profit percentage
SELECT
    arrival_date_year AS Year_date,
    arrival_date_month AS Month_date,
    SUM(total_revenue) AS Total_Revenue,
    ((SUM(total_revenue) - (SUM(total_revenue) * 0.60)) * 100) / (SUM(total_revenue) * 0.60) AS Profit_Percentage
FROM 
    revenue_table
GROUP BY 
    arrival_date_year,
    arrival_date_month
ORDER BY 
    Total_Revenue ASC;
    
    
    
    
    
-- Q2: Which meals and market segments (e.g., families, corporate clients, etc.) contribute the most to the total revenue for each hotel annually?
-- Combine tables from different years
WITH CombinedData AS (
    SELECT * FROM y2018
    UNION ALL
    SELECT * FROM y2019
    UNION ALL
    SELECT * FROM y2020
),

-- Calculate total revenue for each combination of hotel, meal, and market segment
RevenueByCategory AS (
    SELECT 
        h.arrival_date_year AS Year,
        h.hotel AS HotelType,
        h.meal AS MealType,
        h.market_segment AS MarketSegment,
        SUM((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr * (1 - COALESCE(m.discount, 0))) AS TotalRevenue
    FROM 
        CombinedData AS h
    LEFT JOIN 
        market_segment AS m
    ON 
        h.market_segment = m.market_segment
    WHERE 
        h.reservation_status NOT LIKE 'Canceled'
    GROUP BY 
        h.arrival_date_year, h.hotel, h.meal, h.market_segment
)

-- Select the top contributors by revenue
SELECT 
    Year,
    HotelType,
    MealType,
    MarketSegment,
    TotalRevenue
FROM 
    RevenueByCategory
ORDER BY 
    Year, TotalRevenue DESC;

    
    
    
    

    
    
    
    -- Q3: How does revenue compare between public holidays and regular days each year?
    WITH Hotels AS (
    SELECT * FROM y2018
    UNION ALL
    SELECT * FROM y2019
    UNION ALL
    SELECT * FROM y2020
),
revenuecompare AS (
    SELECT 
        arrival_date_year,
        
        COUNT(*) AS days_count,
        SUM(total_revenue) AS total_revenue,
        AVG(total_revenue) AS avg_revenue
    FROM 
        Hotels
    GROUP BY 
        arrival_date_year
)
SELECT 
    arrival_date_year,
    is_holiday,
    days_count,
    total_revenue,
    avg_revenue
FROM 
    revenuecompare
ORDER BY 
    arrival_date_year ; 



-- Q4: What are the key factors (e.g., hotel type, market type, meals offered, number of nights booked) significantly impact hotel revenue annually?


SELECT 
Hotels.hotel, 
Hotels.market_segment, 
Hotels.arrival_date_year,
Hotels.meal,
Hotels.stays_in_weekend_nights,
Hotels.stays_in_week_nights,
SUM(total_revenue) AS total_revenue
FROM
    (SELECT 
        (Hotels.stays_in_weekend_nights + Hotels.stays_in_week_nights) * Hotels.adr * (1 - market_segment.Discount) AS total_revenue,
        Hotels.hotel, 
        Hotels.market_segment, 
        Hotels.arrival_date_year,
        Hotels.meal,
        Hotels.stays_in_weekend_nights,
        Hotels.stays_in_week_nights
    FROM
        Hotels 
    LEFT JOIN 
        market_segment 
    ON 
        Hotels.market_segment = market_segment.market_segment 
    WHERE 
        Hotels.reservation_status NOT LIKE 'Canceled') AS subquery
GROUP BY
    Hotels.hotel, 
    Hotels.market_segment, 
    Hotels.arrival_date_year,
    Hotels.meal,
    Hotels.stays_in_weekend_nights,
    Hotels.stays_in_week_nights
ORDER BY
    total_revenue DESC;
    
    
    
    
-- Q5: Based on stay data, what are the yearly trends in customer preferences for room types (e.g., family rooms vs. single rooms), and how do these preferences influence revenue?
-- Q5: Based on stay data, what are the yearly trends in customer preferences for room types (e.g., family rooms vs. single rooms), and how do these preferences influence revenue?

SELECT 
    Hotels.hotel, 
    Hotels.room_type, 
    Hotels.arrival_date_year,
    SUM(total_revenue) AS total_revenue
FROM
    (SELECT 
        (Hotels.stays_in_weekend_nights + Hotels.stays_in_week_nights) * Hotels.adr * (1 - market_segment.Discount) AS total_revenue,
        Hotels.hotel, 
        Hotels.room_type, 
        Hotels.arrival_date_year
    FROM
        Hotels 
    LEFT JOIN 
        market_segment 
    ON 
        Hotels.market_segment = market_segment.market_segment 
    WHERE 
        Hotels.reservation_status NOT LIKE 'Canceled') AS subquery
GROUP BY
    Hotels.hotel, 
    Hotels.room_type, 
    Hotels.arrival_date_year
ORDER BY
    total_revenue DESC;
    