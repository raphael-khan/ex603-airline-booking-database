-- ------------------------------------------------------------
-- Part A: LAG(), LEAD(), and delta
-- Requirement: Compare each event with the previous and
-- next event for the same producer.
--
-- Business question:
-- How does each booking fare compare with the previous
-- and next booking fare for the same flight?
-- ------------------------------------------------------------

WITH booking_comparison AS (
    SELECT
        b.booking_id,
        b.flight_id,
        b.booked_at,
        b.fare_paid,

        LAG(b.fare_paid) OVER (
            PARTITION BY b.flight_id
            ORDER BY b.booked_at, b.booking_id
        ) AS previous_fare,

        LEAD(b.fare_paid) OVER (
            PARTITION BY b.flight_id
            ORDER BY b.booked_at, b.booking_id
        ) AS next_fare

    FROM bookings b
)
SELECT
    booking_id,
    flight_id,
    booked_at,
    fare_paid,
    previous_fare,
    next_fare,
    fare_paid - previous_fare AS fare_delta
FROM booking_comparison
WHERE flight_id = 2
ORDER BY booked_at, booking_id;


-- ------------------------------------------------------------
-- Part B1: Running total and moving average
-- Requirement: Use cumulative SUM() and moving AVG()
-- with explicit ROWS window frames.
--
-- Business question:
-- How does cumulative booking revenue grow over time,
-- and what is the average fare of the latest 7 bookings?
-- ------------------------------------------------------------

WITH booking_trends AS (
    SELECT
        b.booking_id,
        b.flight_id,
        b.booked_at,
        b.fare_paid,

        SUM(b.fare_paid) OVER (
            ORDER BY b.booked_at, b.booking_id
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS running_total,

        AVG(b.fare_paid) OVER (
            ORDER BY b.booked_at, b.booking_id
            ROWS BETWEEN 6 PRECEDING
                     AND CURRENT ROW
        ) AS moving_avg_7_bookings

    FROM bookings b
)
SELECT
    booking_id,
    flight_id,
    booked_at,
    fare_paid,
    ROUND(running_total, 2) AS running_total,
    ROUND(moving_avg_7_bookings, 2) AS moving_avg_7_bookings,
    4000.00 AS target,
    ROUND(4000.00 - running_total, 2) AS remaining_to_target,
    ROUND(running_total / 4000.00 * 100, 2)
        AS target_pct
FROM booking_trends
ORDER BY booked_at, booking_id;


-- ------------------------------------------------------------
-- Part B2: Final progress summary
-- Requirement: Show how close the running total
-- gets to the target at the end of the dataset.
--
-- Business question:
-- What is the final cumulative fare total, and how
-- much remains to reach the target?
-- ------------------------------------------------------------

WITH running_fares AS (
    SELECT
        booking_id,
        booked_at,

        SUM(fare_paid) OVER (
            ORDER BY booked_at, booking_id
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS running_total

    FROM bookings
)
SELECT
    booked_at AS latest_booking_time,
    ROUND(running_total, 2) AS final_total,
    4000.00 AS target,
    ROUND(4000.00 - running_total, 2) AS remaining,
    ROUND(running_total / 4000.00 * 100, 2)
        AS target_pct
FROM running_fares
ORDER BY booked_at DESC, booking_id DESC
LIMIT 1;


-- ------------------------------------------------------------
-- Part C: Detect gaps in producer activity
-- Requirement: Use LAG(), a CTE, and an outer WHERE
-- to identify long gaps between booking events.
--
-- Business question:
-- Which flights experienced a gap of at least 60 days
-- between consecutive recorded bookings?
-- ------------------------------------------------------------

WITH booking_gaps AS (
    SELECT
        b.flight_id,
        b.booking_id,
        b.booked_at AS current_booking_time,

        LAG(b.booked_at) OVER (
            PARTITION BY b.flight_id
            ORDER BY b.booked_at, b.booking_id
        ) AS previous_booking_time

    FROM bookings b
),
gap_durations AS (
    SELECT
        flight_id,
        booking_id,
        previous_booking_time,
        current_booking_time,
        current_booking_time - previous_booking_time
            AS gap_duration
    FROM booking_gaps
    WHERE previous_booking_time IS NOT NULL
)
SELECT
    f.flight_id,
    f.flight_number,
    g.previous_booking_time,
    g.current_booking_time,
    g.gap_duration
FROM gap_durations g
INNER JOIN flights f
    ON g.flight_id = f.flight_id
WHERE g.gap_duration >= INTERVAL '60 days'
ORDER BY g.gap_duration DESC, f.flight_id;
