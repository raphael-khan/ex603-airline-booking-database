-- 3.1a Active, high-capacity flights
-- Question: Which active flights have at least 180 seats?
-- Requirement: SELECT, WHERE, ORDER BY, LIMIT.
SELECT flight_id,
       flight_number,
       seat_capacity
FROM flights
WHERE is_active = TRUE
  AND seat_capacity >= 180
ORDER BY seat_capacity DESC, flight_id
LIMIT 10;


-- 3.1b Distinct booking statuses
-- Question: What different booking statuses exist in the dataset?
-- Requirement: SELECT DISTINCT.
SELECT DISTINCT booking_status
FROM bookings
ORDER BY booking_status;


-- 3.1c Numeric range filter
-- Question: Which bookings have a fare between 20 and 50?
-- Requirement: WHERE with BETWEEN.
SELECT booking_id, passenger_id, flight_id, fare_paid
FROM bookings
WHERE fare_paid BETWEEN 20 AND 50
ORDER BY fare_paid DESC, booking_id;


-- 3.1d Explicit list filter
-- Question: Which bookings are cancelled or disputed?
-- Requirement: WHERE with IN.
SELECT booking_id, passenger_id, flight_id, booking_status
FROM bookings
WHERE booking_status IN ('cancelled', 'disputed')
ORDER BY booking_id;


-- 3.1e Flight name pattern matching
-- Question: Which flights have a flight number beginning with VN2?
-- Requirement: LIKE.
SELECT flight_id, flight_number, is_active
FROM flights
WHERE flight_number LIKE 'VN2%'
ORDER BY flight_number;


-- 3.1f Missing cancellation reasons
-- Question: Which bookings have no cancellation reason recorded?
-- Requirement: IS NULL, COALESCE.
SELECT booking_id,
       booking_status,
       COALESCE(cancellation_reason, 'No reason provided') AS reason
FROM bookings
WHERE cancellation_reason IS NULL
ORDER BY booking_id;


-- 3.1g Calculated columns and plain-language categories
-- Question: How can we describe each booking's fare and outcome
-- in terms that a route manager can easily understand?
-- Requirement: Calculated columns, CASE.
SELECT booking_id,
       flight_id,
       fare_paid,
       fare_multiplier,
       ROUND(fare_paid * fare_multiplier, 2) AS adjusted_fare,
       CASE
           WHEN booking_status = 'confirmed' THEN 'Confirmed booking'
           WHEN booking_status = 'cancelled' THEN 'Cancelled booking'
           WHEN booking_status = 'disputed' THEN 'Booking under dispute'
           ELSE 'Other booking status'
       END AS booking_outcome
FROM bookings
ORDER BY booking_id;
