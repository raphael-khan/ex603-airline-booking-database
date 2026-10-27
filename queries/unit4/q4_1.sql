
-- ============================================================
-- EX603 | Unit 4 | Task 4.1: Measure the Platform
-- Theme: Airline Booking
--
-- Event table: bookings
-- Producer: flights.flight_id
-- Actor: passengers.passenger_id
-- Region: flights.origin_country
-- Theme metric: bookings.fare_paid
--
-- Scope: All booking events, including bookings for inactive
-- flights. This provides a platform-wide baseline.
-- ============================================================


-- ------------------------------------------------------------
-- Task 4.1A: Platform-wide aggregate summary
-- Requirement: COUNT, SUM, AVG, MIN, MAX, COUNT(DISTINCT)
--
-- Business question:
-- How many bookings occurred, how much fare revenue was
-- recorded, what was the fare distribution, and how many
-- unique passengers made bookings?
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_bookings,
    ROUND(SUM(fare_paid), 2) AS total_fare_paid,
    ROUND(AVG(fare_paid), 2) AS avg_fare_paid,
    MIN(fare_paid) AS min_fare_paid,
    MAX(fare_paid) AS max_fare_paid,
    COUNT(DISTINCT passenger_id) AS unique_passengers
FROM bookings;


-- ------------------------------------------------------------
-- Task 4.1A: Data-quality follow-up
--
-- Business question:
-- How many bookings have a zero fare, and how many of those
-- bookings were cancelled?
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS zero_fare_bookings,
    COUNT(*) FILTER (
        WHERE booking_status = 'cancelled'
    ) AS cancelled_zero_fare_bookings
FROM bookings
WHERE fare_paid = 0;


-- ------------------------------------------------------------
-- Task 4.1B: Per-producer aggregation
-- Requirement: GROUP BY with descending event count
--
-- Business question:
-- Which flights generated the most bookings, and what was
-- the average fare paid for each flight?
-- ------------------------------------------------------------

SELECT
    flight_id AS producer_id,
    COUNT(*) AS total_bookings,
    ROUND(AVG(fare_paid), 2) AS avg_fare_paid
FROM bookings
GROUP BY flight_id
ORDER BY total_bookings DESC, producer_id;


-- ------------------------------------------------------------
-- Task 4.1C: High-volume producer filter
-- Requirement: HAVING
--
-- Business question:
-- Which flights generated at least 15 bookings, and what
-- was their average fare?
--
-- Rationale:
-- Fifteen bookings is a practical threshold for separating
-- relatively high-volume flights from smaller groups.
-- ------------------------------------------------------------

SELECT
    flight_id AS producer_id,
    COUNT(*) AS total_bookings,
    ROUND(AVG(fare_paid), 2) AS avg_fare_paid
FROM bookings
GROUP BY flight_id
HAVING COUNT(*) >= 15
ORDER BY total_bookings DESC, producer_id;


-- ------------------------------------------------------------
-- Task 4.1D: Two-dimensional grouping
-- Requirement: Group by producer and region
--
-- Business question:
-- How does booking volume and average fare vary by flight
-- and flight origin country?
-- ------------------------------------------------------------

SELECT
    b.flight_id AS producer_id,
    f.origin_country AS region,
    COUNT(*) AS total_bookings,
    ROUND(AVG(b.fare_paid), 2) AS avg_fare_paid
FROM bookings b
JOIN flights f
    ON b.flight_id = f.flight_id
GROUP BY
    b.flight_id,
    f.origin_country
ORDER BY
    region,
    total_bookings DESC,
    producer_id;
