-- ------------------------------------------------------------
-- Part A: Top 3 bookings per flight
-- Requirement: Ranking window, CTE, rank <= 3,
-- and FIRST_VALUE().
--
-- Business question:
-- What are the three highest-fare bookings for each flight,
-- and how do they compare with that flight's highest fare?
-- ------------------------------------------------------------

WITH ranked_bookings AS (
    SELECT
        b.booking_id,
        b.flight_id,
        f.flight_number,
        b.booked_at,
        b.fare_paid,

        ROW_NUMBER() OVER (
            PARTITION BY b.flight_id
            ORDER BY b.fare_paid DESC, b.booking_id
        ) AS fare_rank,

        FIRST_VALUE(b.fare_paid) OVER (
            PARTITION BY b.flight_id
            ORDER BY b.fare_paid DESC, b.booking_id
        ) AS highest_fare

    FROM bookings b
    INNER JOIN flights f
        ON b.flight_id = f.flight_id
)
SELECT
    flight_id,
    flight_number,
    booking_id,
    booked_at,
    fare_paid,
    fare_rank,
    highest_fare,
    highest_fare - fare_paid AS difference_from_top
FROM ranked_bookings
WHERE fare_rank <= 3
ORDER BY flight_id, fare_rank;


-- ------------------------------------------------------------
-- Part B1: Monthly no-show trend
-- Requirement: DATE_TRUNC(), LAG(), percentage change,
-- division-by-zero protection, and missing-month check.
--
-- Business question:
-- Is the platform's passenger no-show rate improving
-- or worsening from one calendar month to the next?
-- ------------------------------------------------------------

WITH monthly_bookings AS (
    SELECT
        DATE_TRUNC('month', booked_at)::date
            AS booking_month,
        COUNT(*) AS total_bookings,
        COUNT(*) FILTER (
            WHERE booking_status = 'cancelled'
              AND cancellation_reason = 'Passenger no show'
        ) AS no_show_bookings
    FROM bookings
    GROUP BY DATE_TRUNC('month', booked_at)::date
),
calendar_months AS (
    SELECT
        GENERATE_SERIES(
            (SELECT MIN(booking_month) FROM monthly_bookings),
            (SELECT MAX(booking_month) FROM monthly_bookings),
            INTERVAL '1 month'
        )::date AS booking_month
),
monthly_series AS (
    SELECT
        c.booking_month,
        COALESCE(m.total_bookings, 0) AS total_bookings,
        COALESCE(m.no_show_bookings, 0) AS no_show_bookings,
        ROUND(
            100.0 * m.no_show_bookings
            / NULLIF(m.total_bookings, 0),
            2
        ) AS no_show_rate_pct,
        CASE
            WHEN m.booking_month IS NULL THEN TRUE
            ELSE FALSE
        END AS missing_month
    FROM calendar_months c
    LEFT JOIN monthly_bookings m
        ON c.booking_month = m.booking_month
),
monthly_comparison AS (
    SELECT
        booking_month,
        total_bookings,
        no_show_bookings,
        no_show_rate_pct,
        missing_month,

        LAG(no_show_rate_pct) OVER (
            ORDER BY booking_month
        ) AS previous_month_rate_pct,

        LAG(total_bookings) OVER (
            ORDER BY booking_month
        ) AS previous_month_bookings

    FROM monthly_series
)
SELECT
    booking_month,
    total_bookings,
    no_show_bookings,
    no_show_rate_pct,
    previous_month_rate_pct,

    ROUND(
        no_show_rate_pct - previous_month_rate_pct,
        2
    ) AS rate_change_pp,

    ROUND(
        100.0 *
        (no_show_rate_pct - previous_month_rate_pct)
        / NULLIF(previous_month_rate_pct, 0),
        2
    ) AS rate_change_pct,

    previous_month_bookings,
    missing_month,

    CASE
        WHEN missing_month THEN 'No recorded bookings'
        WHEN previous_month_rate_pct IS NULL
            THEN 'No prior rate available'
        WHEN no_show_rate_pct < previous_month_rate_pct
            THEN 'Improving'
        WHEN no_show_rate_pct > previous_month_rate_pct
            THEN 'Worsening'
        ELSE 'Unchanged'
    END AS performance_trend

FROM monthly_comparison
ORDER BY booking_month;


-- ------------------------------------------------------------
-- Part B2: Check for missing calendar months
-- Requirement: Verify whether any months are missing
-- from the original booking data.
--
-- Business question:
-- Are there calendar months with no booking records
-- that could distort month-over-month comparisons?
-- ------------------------------------------------------------

WITH monthly_bookings AS (
    SELECT
        DATE_TRUNC('month', booked_at)::date
            AS booking_month
    FROM bookings
    GROUP BY DATE_TRUNC('month', booked_at)::date
),
calendar_months AS (
    SELECT
        GENERATE_SERIES(
            (SELECT MIN(booking_month) FROM monthly_bookings),
            (SELECT MAX(booking_month) FROM monthly_bookings),
            INTERVAL '1 month'
        )::date AS booking_month
)
SELECT
    c.booking_month AS missing_month
FROM calendar_months c
LEFT JOIN monthly_bookings m
    ON c.booking_month = m.booking_month
WHERE m.booking_month IS NULL
ORDER BY c.booking_month;
