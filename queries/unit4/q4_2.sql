
-- ============================================================
-- EX603 | Unit 4 | Task 4.2: Build the Breakdown
-- Theme: Airline Booking
--
-- Failure definition:
-- booking_status = 'cancelled'
-- AND cancellation_reason = 'Passenger no show'
--
-- Producer: flight_id
-- Region: flights.origin_country
-- High-volume threshold: 15 bookings
-- ============================================================


-- ------------------------------------------------------------
-- Part A: Two numbers in one pass
-- Requirement: CASE inside an aggregate
--
-- Business question:
-- How many total bookings and passenger no-shows did each
-- flight generate?
--
-- No WHERE clause filters the event population.
-- ------------------------------------------------------------

SELECT
    flight_id AS producer_id,
    COUNT(*) AS total_events,
    SUM(
        CASE
            WHEN booking_status = 'cancelled'
             AND cancellation_reason = 'Passenger no show'
            THEN 1
            ELSE 0
        END
    ) AS failed_events,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN booking_status = 'cancelled'
                 AND cancellation_reason = 'Passenger no show'
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_pct
FROM bookings
GROUP BY flight_id
ORDER BY
    failed_events DESC,
    failure_rate_pct DESC,
    producer_id;


-- ------------------------------------------------------------
-- Part B: Regional subtotals and platform grand total
-- Requirement: GROUPING SETS without flight-level detail
--
-- Business question:
-- How many bookings and passenger no-shows occurred in
-- each flight origin region and across the entire platform?
-- ============================================================
-- EX603 | Unit 4 | Task 4.2: Build the Breakdown
-- Theme: Airline Booking
--
-- Failure definition:
-- booking_status = 'cancelled'
-- AND cancellation_reason = 'Passenger no show'
--
-- Producer: flight_id
-- Region: flights.origin_country
-- High-volume threshold: 15 bookings
-- ============================================================


-- ------------------------------------------------------------
-- Part A: Two numbers in one pass
-- Requirement: CASE inside an aggregate
--
-- Business question:
-- How many total bookings and passenger no-shows did each
-- flight generate?
--
-- No WHERE clause filters the event population.
-- ------------------------------------------------------------

SELECT
    flight_id AS producer_id,
    COUNT(*) AS total_events,
    SUM(
        CASE
            WHEN booking_status = 'cancelled'
             AND cancellation_reason = 'Passenger no show'
            THEN 1
            ELSE 0
        END
    ) AS failed_events,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN booking_status = 'cancelled'
                 AND cancellation_reason = 'Passenger no show'
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_pct
FROM bookings
GROUP BY flight_id
ORDER BY
    failed_events DESC,
    failure_rate_pct DESC,
    producer_id;


-- ------------------------------------------------------------
-- Part B: Regional subtotals and platform grand total
-- Requirement: GROUPING SETS without flight-level detail
--
-- Business question:
-- How many bookings and passenger no-shows occurred in
-- each flight origin region and across the entire platform?
--
-- Regional rows = subtotals
-- ALL REGIONS row = platform grand total
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN GROUPING(f.origin_country) = 1
        THEN 'ALL REGIONS'
        ELSE f.origin_country
    END AS region,
    COUNT(*) AS total_events,
    SUM(
        CASE
            WHEN b.booking_status = 'cancelled'
             AND b.cancellation_reason = 'Passenger no show'
            THEN 1
            ELSE 0
        END
    ) AS failed_events,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN b.booking_status = 'cancelled'
                 AND b.cancellation_reason = 'Passenger no show'
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_pct
FROM bookings b
JOIN flights f
    ON b.flight_id = f.flight_id
GROUP BY GROUPING SETS (
    (f.origin_country),
    ()
)
ORDER BY
    GROUPING(f.origin_country),
    f.origin_country;


-- ------------------------------------------------------------
-- Part C: Two-step aggregation pipeline
-- Requirement: WITH clause and second aggregation
--
-- Business question:
-- What is the booking-weighted passenger no-show rate
-- among flights with at least 15 bookings?
--
-- Step 1: Summarize bookings and failures per flight.
-- Step 2: Select high-volume flights and aggregate them
--         into one comparison baseline.
-- ------------------------------------------------------------

WITH producer_performance AS (
    SELECT
        flight_id AS producer_id,
        COUNT(*) AS total_events,
        SUM(
            CASE
                WHEN booking_status = 'cancelled'
                 AND cancellation_reason = 'Passenger no show'
                THEN 1
                ELSE 0
            END
        ) AS failed_events
    FROM bookings
    GROUP BY flight_id
)
SELECT
    COUNT(*) AS high_volume_producers,
    SUM(total_events) AS total_events,
    SUM(failed_events) AS failed_events,
    ROUND(
        100.0 * SUM(failed_events)
        / NULLIF(SUM(total_events), 0),
        2
    ) AS baseline_failure_rate_pct
FROM producer_performance
WHERE total_events >= 15;

-- ------------------------------------------------------------

SELECT
    CASE
        WHEN GROUPING(f.origin_country) = 1
        THEN 'ALL REGIONS'
        ELSE f.origin_country
    END AS region,
    COUNT(*) AS total_events,
    SUM(
        CASE
            WHEN b.booking_status = 'cancelled'
             AND b.cancellation_reason = 'Passenger no show'
            THEN 1
            ELSE 0
        END
    ) AS failed_events,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN b.booking_status = 'cancelled'
                 AND b.cancellation_reason = 'Passenger no show'
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_pct
FROM bookings b
JOIN flights f
    ON b.flight_id = f.flight_id
GROUP BY GROUPING SETS (
    (f.origin_country),
    ()
)
ORDER BY
    GROUPING(f.origin_country),
    f.origin_country;


-- ------------------------------------------------------------
-- Part C: Two-step aggregation pipeline
-- Requirement: WITH clause and second aggregation
--
-- Business question:
-- What is the booking-weighted passenger no-show rate
-- among flights with at least 15 bookings?
--
-- Step 1: Summarize bookings and failures per flight.
-- Step 2: Select high-volume flights and aggregate them
--         into one comparison baseline.
-- ------------------------------------------------------------

WITH producer_performance AS (
    SELECT
        flight_id AS producer_id,
        COUNT(*) AS total_events,
        SUM(
            CASE
                WHEN booking_status = 'cancelled'
                 AND cancellation_reason = 'Passenger no show'
                THEN 1
                ELSE 0
            END
        ) AS failed_events
    FROM bookings
    GROUP BY flight_id
)
SELECT
    COUNT(*) AS high_volume_producers,
    SUM(total_events) AS total_events,
    SUM(failed_events) AS failed_events,
    ROUND(
        100.0 * SUM(failed_events)
        / NULLIF(SUM(total_events), 0),
        2
    ) AS baseline_failure_rate_pct
FROM producer_performance
WHERE total_events >= 15;
