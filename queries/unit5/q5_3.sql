--  ------------------------------------------------------------
-- Part A1: Count the rows in two small source tables
-- Requirement: Count each table before using CROSS JOIN
-- Business question:
-- How many airports and flights are available for
-- a Cartesian-product comparison?
-- ------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM airports) AS airport_count,
    (SELECT COUNT(*) FROM flights) AS flight_count;


-- ------------------------------------------------------------
-- Part A2: CROSS JOIN
-- Requirement: Generate all combinations of rows from
-- two small tables.
--
-- Business question:
-- What would every possible flight-airport combination
-- look like, regardless of existing route assignments?
-- ------------------------------------------------------------

SELECT
    f.flight_id,
    f.flight_number,
    a.airport_id,
    a.iata_code
FROM flights f
CROSS JOIN airports a
ORDER BY f.flight_id, a.airport_id;


-- ------------------------------------------------------------
-- Part A3: Verify the Cartesian-product row count
-- Requirement: Compare the actual CROSS JOIN count with
-- the product of the two source-table counts.
--
-- Business question:
-- Does the number of generated combinations equal
-- the number of flights multiplied by the number
-- of airports?
-- ------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM flights) AS flight_count,
    (SELECT COUNT(*) FROM airports) AS airport_count,
    (SELECT COUNT(*) FROM flights)
        * (SELECT COUNT(*) FROM airports)
        AS expected_combinations,
    COUNT(*) AS actual_combinations
FROM flights f
CROSS JOIN airports a;


-- ------------------------------------------------------------
-- Part B1: EXPLAIN the three-table join from Task 5.1
-- Requirement: Examine PostgreSQL's execution plan.
--
-- Business question:
-- How does PostgreSQL plan to connect bookings,
-- passengers, and flights to produce booking history?
-- ------------------------------------------------------------

EXPLAIN
SELECT
    b.booking_id,
    p.passenger_id,
    p.passenger_name,
    f.flight_id,
    f.flight_number,
    b.booked_at
FROM bookings b
INNER JOIN passengers p
    ON b.passenger_id = p.passenger_id
INNER JOIN flights f
    ON b.flight_id = f.flight_id
ORDER BY b.booked_at, b.booking_id;


-- ------------------------------------------------------------
-- Part B2: EXPLAIN ANALYZE
-- Requirement: Observe actual execution behavior.
--
-- Business question:
-- How many rows are processed, and how long does the
-- booking-history query actually take?
-- ------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    b.booking_id,
    p.passenger_id,
    p.passenger_name,
    f.flight_id,
    f.flight_number,
    b.booked_at
FROM bookings b
INNER JOIN passengers p
    ON b.passenger_id = p.passenger_id
INNER JOIN flights f
    ON b.flight_id = f.flight_id
ORDER BY b.booked_at, b.booking_id;
