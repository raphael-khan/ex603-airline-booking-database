-- 3.3a Disputed booking passengers using IN
-- Question: Which passengers have at least one disputed booking?
-- Requirement: Subquery using IN.
SELECT passenger_id,
       passenger_name,
       email
FROM passengers
WHERE passenger_id IN (
    SELECT passenger_id
    FROM bookings
    WHERE booking_status = 'disputed'
)
ORDER BY passenger_id;

-- 3.3b Disputed booking passengers using a CTE
-- Question: Which passengers have at least one disputed booking?
-- Requirement: Common Table Expression using WITH.
WITH disputed_passengers AS (
    SELECT DISTINCT passenger_id
    FROM bookings
    WHERE booking_status = 'disputed'
)
SELECT p.passenger_id,
       p.passenger_name,
       p.email
FROM passengers p
JOIN disputed_passengers dp
    ON p.passenger_id = dp.passenger_id
ORDER BY p.passenger_id;

-- 3.3c Disputed booking passengers using EXISTS
-- Question: Which passengers have at least one disputed booking?
-- Requirement: Correlated EXISTS subquery.
SELECT p.passenger_id,
       p.passenger_name,
       p.email
FROM passengers p
WHERE EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.passenger_id = p.passenger_id
      AND b.booking_status = 'disputed'
)
ORDER BY p.passenger_id;

-- 3.3d Verify that all three approaches return identical rows
-- Question: Do IN, CTE, and EXISTS return exactly the same passengers?
-- Requirement: Compare actual result sets using EXCEPT.
WITH
in_result AS (
    SELECT passenger_id, passenger_name, email
    FROM passengers
    WHERE passenger_id IN (
        SELECT passenger_id
        FROM bookings
        WHERE booking_status = 'disputed'
    )
),
cte_result AS (
    WITH disputed_passengers AS (
        SELECT DISTINCT passenger_id
        FROM bookings
        WHERE booking_status = 'disputed'
    )
    SELECT p.passenger_id, p.passenger_name, p.email
    FROM passengers p
    JOIN disputed_passengers dp
        ON p.passenger_id = dp.passenger_id
),
exists_result AS (
    SELECT p.passenger_id, p.passenger_name, p.email
    FROM passengers p
    WHERE EXISTS (
        SELECT 1
        FROM bookings b
        WHERE b.passenger_id = p.passenger_id
          AND b.booking_status = 'disputed'
    )
),
differences AS (
    (SELECT * FROM in_result
     EXCEPT
     SELECT * FROM cte_result)

    UNION ALL

    (SELECT * FROM cte_result
     EXCEPT
     SELECT * FROM in_result)

    UNION ALL

    (SELECT * FROM in_result
     EXCEPT
     SELECT * FROM exists_result)

    UNION ALL

    (SELECT * FROM exists_result
     EXCEPT
     SELECT * FROM in_result)
)
SELECT *
FROM differences;
