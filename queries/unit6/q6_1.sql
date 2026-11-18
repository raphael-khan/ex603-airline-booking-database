-- ------------------------------------------------------------
-- Question 1A: Window average
-- Requirement: Use AVG() OVER (PARTITION BY ...).
--
-- Business question:
-- How does each booking's fare compare with the average
-- fare paid for the same flight?
-- ------------------------------------------------------------

SELECT
    b.booking_id,
    b.flight_id,
    b.fare_paid,
    ROUND(
        AVG(b.fare_paid) OVER (
            PARTITION BY b.flight_id
        ), 2
    ) AS flight_avg_fare,
    ROUND(
        b.fare_paid -
        AVG(b.fare_paid) OVER (
            PARTITION BY b.flight_id
        ), 2
    ) AS difference_from_avg
FROM bookings b
ORDER BY b.flight_id, b.booking_id;


-- ------------------------------------------------------------
-- Question 1B: GROUP BY comparison
-- Requirement: Calculate the same producer average
-- using traditional aggregation.
--
-- Business question:
-- What is the average booking fare for each flight?
-- ------------------------------------------------------------

SELECT
    flight_id,
    ROUND(AVG(fare_paid), 2) AS flight_avg_fare
FROM bookings
GROUP BY flight_id
ORDER BY flight_id;


-- ------------------------------------------------------------
-- Question 1C: Compare row counts
-- Requirement: Show how many rows each approach returns.
--
-- Business question:
-- How many individual booking rows are preserved by
-- the window query compared with GROUP BY?
-- ------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM bookings)
        AS window_query_rows,
    (SELECT COUNT(*)
     FROM (
         SELECT flight_id
         FROM bookings
         GROUP BY flight_id
     ) grouped)
        AS group_by_rows;


-- ------------------------------------------------------------
-- Question 2: Rank producers three ways
-- Requirement: Use ROW_NUMBER(), RANK(), DENSE_RANK().
--
-- Business question:
-- How do flight rankings differ when multiple flights
-- have the same number of bookings?
-- ------------------------------------------------------------

WITH flight_counts AS (
    SELECT
        f.flight_id,
        f.flight_number,
        COUNT(b.booking_id) AS total_bookings
    FROM flights f
    LEFT JOIN bookings b
        ON f.flight_id = b.flight_id
    GROUP BY f.flight_id, f.flight_number
)
SELECT
    flight_id,
    flight_number,
    total_bookings,
    ROW_NUMBER() OVER (
        ORDER BY total_bookings DESC, flight_id
    ) AS row_number_rank,
    RANK() OVER (
        ORDER BY total_bookings DESC
    ) AS rank_position,
    DENSE_RANK() OVER (
        ORDER BY total_bookings DESC
    ) AS dense_rank_position
FROM flight_counts
ORDER BY total_bookings DESC, flight_id;


-- ------------------------------------------------------------
-- Question 3: Divide producers into four bands
-- Requirement: Use NTILE(4).
--
-- Business question:
-- Which booking-volume quartile does each flight
-- belong to, and can tied flights fall into
-- different bands?
-- ------------------------------------------------------------

WITH flight_counts AS (
    SELECT
        f.flight_id,
        f.flight_number,
        COUNT(b.booking_id) AS total_bookings
    FROM flights f
    LEFT JOIN bookings b
        ON f.flight_id = b.flight_id
    GROUP BY f.flight_id, f.flight_number
)
SELECT
    flight_id,
    flight_number,
    total_bookings,
    NTILE(4) OVER (
        ORDER BY total_bookings DESC, flight_id
    ) AS volume_band
FROM flight_counts
ORDER BY volume_band, total_bookings DESC, flight_id;
