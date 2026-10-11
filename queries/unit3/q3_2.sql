-- 3.2a.1 Reproduce the NULL comparison bug
-- Question: How many bookings do not have "Passenger no show"
-- as their cancellation reason?
-- Requirement: Inequality predicate on a nullable column.
SELECT COUNT(*) AS non_no_show_count
FROM bookings
WHERE cancellation_reason != 'Passenger no show';

-- 3.2a.2 Count the opposite condition
-- Question: How many bookings have "Passenger no show"
-- as their cancellation reason?
-- Requirement: Count the opposite condition to expose omitted rows.
SELECT COUNT(*) AS no_show_count
FROM bookings
WHERE cancellation_reason = 'Passenger no show';

-- 3.2a.3 Identify silently omitted records
-- Question: How many bookings exist, and how many have no
-- cancellation reason recorded?
-- Requirement: COUNT(*), IS NULL.
SELECT
    COUNT(*) AS total_bookings,
    COUNT(*) FILTER (
        WHERE cancellation_reason IS NULL
    ) AS null_reason_count
FROM bookings;

-- 3.2a.4 Repair the inequality predicate
-- Question: How many bookings are not marked as passenger
-- no-shows, including bookings with no cancellation reason?
-- Requirement: Explicit IS NULL to repair three-valued logic.
SELECT COUNT(*) AS corrected_non_no_show_count
FROM bookings
WHERE cancellation_reason != 'Passenger no show'
   OR cancellation_reason IS NULL;

-- 3.2b.1 Reproduce the SELECT alias visibility error
-- Question: Which bookings have an adjusted fare greater than $30?
-- Requirement: Define an alias in SELECT and incorrectly reference it in WHERE.
SELECT booking_id,
       fare_paid,
       fare_multiplier,
       ROUND(fare_paid * fare_multiplier, 2) AS adjusted_fare
FROM bookings
WHERE adjusted_fare > 30;

-- [42703] ERROR: column "adjusted_fare" does not exist
-- Position: 144

-- 3.2b.2 Fix the alias error by repeating the expression
-- Question: Which bookings have an adjusted fare greater than $30?
-- Requirement: Repeat the SELECT calculation in WHERE.
SELECT booking_id,
       fare_paid,
       fare_multiplier,
       ROUND(fare_paid * fare_multiplier, 2) AS adjusted_fare
FROM bookings
WHERE ROUND(fare_paid * fare_multiplier, 2) > 30
ORDER BY adjusted_fare DESC, booking_id;

-- 3.2b.3 Fix the alias error using a CTE
-- Question: Which bookings have an adjusted fare greater than $30?
-- Requirement: Define the alias in a CTE and filter it in the outer query.
WITH booking_fares AS (
    SELECT booking_id,
           fare_paid,
           fare_multiplier,
           ROUND(fare_paid * fare_multiplier, 2) AS adjusted_fare
    FROM bookings
)
SELECT booking_id,
       fare_paid,
       fare_multiplier,
       adjusted_fare
FROM booking_fares
WHERE adjusted_fare > 30
ORDER BY adjusted_fare DESC, booking_id;

