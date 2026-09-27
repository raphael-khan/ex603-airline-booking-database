-- ===================================================================
-- EX603 Assignment 2 - schema.sql
-- Theme: Airline Booking
-- Author: Raphael Khan
-- Target: PostgreSQL 18
-- ===================================================================

-- ===================================================================
-- Reset
-- Reverse creation order so no dependency blocks a drop
-- ===================================================================
DROP TABLE IF EXISTS FLIGHT_ROUTE CASCADE;
DROP TABLE IF EXISTS BOOKING CASCADE;
DROP TABLE IF EXISTS AIRPORT CASCADE;
DROP TABLE IF EXISTS FLIGHT CASCADE;
DROP TABLE IF EXISTS PASSENGER CASCADE;

-- ===================================================================
-- 1. PASSENGER
-- Created first because it does not reference another table.
-- Represents the passengers who use the booking platform.
-- ===================================================================
CREATE TABLE PASSENGER
(
    passenger_id   INTEGER GENERATED ALWAYS AS IDENTITY,
    passenger_name VARCHAR(100) NOT NULL,
    email          VARCHAR(254) NOT NULL,
    dob            DATE,
    gender         VARCHAR(15),
    nationality    VARCHAR(50),

    CONSTRAINT pk_passenger
        PRIMARY KEY (passenger_id),
    CONSTRAINT uq_passenger_email
        UNIQUE (email)
);

-- ===================================================================
-- 2. FLIGHT
-- Created before BOOKING and FLIGHT_ROUTE because both reference
-- flight_id.
-- ===================================================================
CREATE TABLE FLIGHT
(
    flight_id    INTEGER GENERATED ALWAYS AS IDENTITY,
    flight_name  VARCHAR(15) NOT NULL,
    is_active    BOOLEAN     NOT NULL,
    duration_min INTEGER     NOT NULL,

    CONSTRAINT pk_flight
        PRIMARY KEY (flight_id),
    CONSTRAINT chk_flight_duration
        CHECK (duration_min > 0)
);

-- ===================================================================
-- 3. AIRPORT
-- Created before FLIGHT_ROUTE because FLIGHT_ROUTE references
-- airport_id.
-- ===================================================================
CREATE TABLE AIRPORT
(
    airport_id      CHAR(3),
    airport_name    VARCHAR(100) NOT NULL,
    airport_city    VARCHAR(100) NOT NULL,
    airport_country VARCHAR(100) NOT NULL,

    CONSTRAINT pk_airport
        PRIMARY KEY (airport_id)
);

-- ===================================================================
-- 4. BOOKING
-- Created after PASSENGER and FLIGHT because it references both.
-- Records a passenger's booking of a flight.
-- ===================================================================
CREATE TABLE BOOKING
(
    booking_id   INTEGER GENERATED ALWAYS AS IDENTITY,
    passenger_id INTEGER        NOT NULL,
    flight_id    INTEGER        NOT NULL,
    booked_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fare_paid    NUMERIC(10, 2) NOT NULL,

    CONSTRAINT pk_booking
        PRIMARY KEY (booking_id),
    CONSTRAINT fk_booking_passenger
        FOREIGN KEY (passenger_id) REFERENCES PASSENGER (passenger_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_flight
        FOREIGN KEY (flight_id) REFERENCES FLIGHT (flight_id) ON DELETE RESTRICT,
    CONSTRAINT chk_bookings_fare
        CHECK (fare_paid >= 0)
);

-- ===================================================================
-- 5. FLIGHT_ROUTE
-- Created last because it references both FLIGHT and AIRPORT.
-- The composite primary key prevents the same flight/airport combination
-- from appearing more than once.
-- ===================================================================
CREATE TABLE FLIGHT_ROUTE
(
    flight_id    INTEGER     NOT NULL,
    airport_id   CHAR(3)     NOT NULL,
    airport_role VARCHAR(15) NOT NULL,

    CONSTRAINT pk_flight_route
        PRIMARY KEY (flight_id, airport_id),
    CONSTRAINT fk_flight_route_flight
        FOREIGN KEY (flight_id) REFERENCES FLIGHT (flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_flight_route_airport
        FOREIGN KEY (airport_id) REFERENCES AIRPORT (airport_id) ON DELETE RESTRICT,
    CONSTRAINT chk_flight_route_role
        CHECK (airport_role IN ('DEPARTURE', 'ARRIVAL'))
);
