-- ------------------------------------------------------------
-- Part A1: LEFT JOIN
-- Requirement: Return all producers, including those without
-- any booking events.
--
-- Business question:
-- How many bookings does each flight have, including flights
-- that have never received a booking?
-- ------------------------------------------------------------

SELECT
    f.flight_id,
    f.flight_number,
    f.is_active,
    COUNT(b.booking_id) AS total_bookings
FROM flights f
LEFT JOIN bookings b
    ON f.flight_id = b.flight_id
GROUP BY
    f.flight_id,
    f.flight_number,
    f.is_active
ORDER BY f.flight_id;


-- ------------------------------------------------------------
-- Part A2: INNER JOIN
-- Requirement: Return only producers with matching events.
--
-- Business question:
-- Which flights have at least one booking, and how many
-- bookings does each flight have?
-- ------------------------------------------------------------

SELECT
    f.flight_id,
    f.flight_number,
    f.is_active,
    COUNT(b.booking_id) AS total_bookings
FROM flights f
INNER JOIN bookings b
    ON f.flight_id = b.flight_id
GROUP BY
    f.flight_id,
    f.flight_number,
    f.is_active
ORDER BY f.flight_id;


-- ------------------------------------------------------------
-- Part A3: Compare producer counts
-- Requirement: Count producers excluded by INNER JOIN.
--
-- Business question:
-- How many flights disappear when INNER JOIN is used
-- instead of LEFT JOIN?
--
-- DISTINCT prevents counting a flight multiple times
-- because it has multiple booking events.
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT f.flight_id) AS total_producers,
    COUNT(DISTINCT b.flight_id) AS producers_with_events,
    COUNT(DISTINCT f.flight_id)
        - COUNT(DISTINCT b.flight_id)
        AS excluded_producers
FROM flights f
LEFT JOIN bookings b
    ON f.flight_id = b.flight_id;


-- ------------------------------------------------------------
-- Part A4: Identify excluded producers
--
-- Business question:
-- Which flights have no matching booking records?
-- ------------------------------------------------------------

SELECT
    f.flight_id,
    f.flight_number,
    f.is_active
FROM flights f
LEFT JOIN bookings b
    ON f.flight_id = b.flight_id
WHERE b.booking_id IS NULL
ORDER BY f.flight_id;


-- ------------------------------------------------------------
-- Part B1: RIGHT JOIN
-- Requirement: Return the same producer summary as LEFT JOIN.
--
-- Business question:
-- Can RIGHT JOIN preserve all flights, including those
-- without bookings, when the table order is reversed?
-- ------------------------------------------------------------

SELECT
    f.flight_id,
    f.flight_number,
    f.is_active,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
RIGHT JOIN flights f
    ON b.flight_id = f.flight_id
GROUP BY
    f.flight_id,
    f.flight_number,
    f.is_active
ORDER BY f.flight_id;


-- ------------------------------------------------------------
-- Part B2: Verify LEFT JOIN and RIGHT JOIN match
-- Requirement: Compare actual result sets.
--
-- Business question:
-- Do the two queries return identical flight IDs and
-- booking counts?
--
-- Expected result: zero differences.
-- ------------------------------------------------------------

WITH left_results AS (
    SELECT
        f.flight_id,
        COUNT(b.booking_id) AS total_bookings
    FROM flights f
    LEFT JOIN bookings b
        ON f.flight_id = b.flight_id
    GROUP BY f.flight_id
),
right_results AS (
    SELECT
        f.flight_id,
        COUNT(b.booking_id) AS total_bookings
    FROM bookings b
    RIGHT JOIN flights f
        ON b.flight_id = f.flight_id
    GROUP BY f.flight_id
)
SELECT 'LEFT_ONLY' AS difference, flight_id, total_bookings
FROM (
    SELECT * FROM left_results
    EXCEPT
    SELECT * FROM right_results
) left_only

UNION ALL

SELECT 'RIGHT_ONLY' AS difference, flight_id, total_bookings
FROM (
    SELECT * FROM right_results
    EXCEPT
    SELECT * FROM left_results
) right_only;


-- ------------------------------------------------------------
-- Part B3: FULL OUTER JOIN
-- Requirement: Include matching and unmatched records
-- from both tables.
--
-- Business question:
-- Which flights have bookings, which have no bookings,
-- and are there any booking records without a matching
-- flight?
-- ------------------------------------------------------------

SELECT
    COALESCE(f.flight_id, b.flight_id) AS flight_id,
    f.flight_number,
    COUNT(b.booking_id) AS total_bookings,
    CASE
        WHEN f.flight_id IS NULL
            THEN 'Booking without flight'
        WHEN COUNT(b.booking_id) = 0
            THEN 'Flight without bookings'
        ELSE 'Matched'
    END AS match_status
FROM flights f
FULL OUTER JOIN bookings b
    ON f.flight_id = b.flight_id
GROUP BY
    COALESCE(f.flight_id, b.flight_id),
    f.flight_id,
    f.flight_number
ORDER BY flight_id;


-- ------------------------------------------------------------
-- Part B4: Verify FULL OUTER JOIN results
--
-- Business question:
-- How many unique flights are matched, unmatched on the
-- flight side, or unmatched on the booking side?
-- ------------------------------------------------------------

WITH full_join_summary AS (
    SELECT
        f.flight_id AS producer_id,
        b.booking_id,
        CASE
            WHEN f.flight_id IS NULL THEN 'Booking without flight'
            WHEN b.booking_id IS NULL THEN 'Flight without bookings'
            ELSE 'Matched'
        END AS match_status
    FROM flights f
    FULL OUTER JOIN bookings b
        ON f.flight_id = b.flight_id
)
SELECT
    match_status,
    COUNT(DISTINCT producer_id) AS producer_count,
    COUNT(booking_id) AS booking_count
FROM full_join_summary
GROUP BY match_status
ORDER BY match_status;


-- ------------------------------------------------------------
-- Part C1: NOT EXISTS
-- Requirement: Find producers with no events.
--
-- Business question:
-- Which flights have never received a booking?
-- ------------------------------------------------------------

SELECT
    f.flight_id
FROM flights f
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.flight_id = f.flight_id
)
ORDER BY f.flight_id;


-- ------------------------------------------------------------
-- Part C2: EXCEPT
-- Requirement: Find producers with no events using set
-- difference.
--
-- Business question:
-- Which flight IDs exist in the flights table but not
-- in the bookings table?
-- ------------------------------------------------------------

SELECT flight_id
FROM flights

EXCEPT

SELECT flight_id
FROM bookings

ORDER BY flight_id;


-- ------------------------------------------------------------
-- Part C3: Verify NOT EXISTS and EXCEPT agree
-- Requirement: Compare both approaches.
--
-- Business question:
-- Do both approaches identify exactly the same flights
-- without booking events?
--
-- Expected result: zero differences.
-- ------------------------------------------------------------

WITH not_exists_results AS (
    SELECT f.flight_id
    FROM flights f
    WHERE NOT EXISTS (
        SELECT 1
        FROM bookings b
        WHERE b.flight_id = f.flight_id
    )
),
except_results AS (
    SELECT flight_id FROM flights
    EXCEPT
    SELECT flight_id FROM bookings
)
SELECT 'NOT_EXISTS_ONLY' AS difference, flight_id
FROM (
    SELECT * FROM not_exists_results
    EXCEPT
    SELECT * FROM except_results
) a

UNION ALL

SELECT 'EXCEPT_ONLY' AS difference, flight_id
FROM (
    SELECT * FROM except_results
    EXCEPT
    SELECT * FROM not_exists_results
) b;
