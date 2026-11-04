-- ------------------------------------------------------------
-- Question 1: Three-table INNER JOIN
-- Requirement: Join actor, event, and producer tables.
--
-- Business question:
-- Which passenger made each booking, which flight was booked,
-- and when did the booking occur?
-- ------------------------------------------------------------

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
-- Question 2: Junction-table JOIN
-- Requirement: Connect producers to catalog records through
-- the junction table.
--
-- Business question:
-- Which flights are associated with cataloged airports,
-- and which of the previously flagged flights use them?
--
-- The flight_routes table connects flights to airports.
-- ------------------------------------------------------------

SELECT
    f.flight_id,
    f.flight_number,
    a.airport_id,
    a.iata_code,
    a.airport_name
FROM flights f
INNER JOIN flight_routes fr
    ON f.flight_id = fr.flight_id
INNER JOIN airports a
    ON fr.airport_id = a.airport_id
WHERE f.flight_id IN (2, 3, 4)
ORDER BY f.flight_id, a.iata_code;


-- ------------------------------------------------------------
-- Question 3: Producer self join
-- Requirement: Compare records within the producer table.
--
-- Business question:
-- Which other flights share the same origin country as
-- the flights identified in Assignment 4, and how do their
-- seat capacities and activity statuses compare?
-- ------------------------------------------------------------

SELECT
    f1.flight_id AS flagged_flight_id,
    f1.flight_number AS flagged_flight_number,
    f1.origin_country,
    f1.seat_capacity AS flagged_capacity,
    f1.is_active AS flagged_active,
    f2.flight_id AS comparison_flight_id,
    f2.flight_number AS comparison_flight_number,
    f2.seat_capacity AS comparison_capacity,
    f2.is_active AS comparison_active
FROM flights f1
INNER JOIN flights f2
    ON f1.origin_country = f2.origin_country
   AND f1.flight_id <> f2.flight_id
WHERE f1.flight_id IN (2, 3, 4)
ORDER BY f1.flight_id, f2.flight_id;
