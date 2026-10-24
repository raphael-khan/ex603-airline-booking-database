# EX603-Airline-Booking-database-model
A relational database model for an airline booking system, capturing passengers, flights, airports, and the bookings and routes that connect them. 

## Theme
Airline Booking - This project models the core data behind an airline booking platform—the type of system that supports workflows such as searching for flights, viewing flight routes, and booking flights. 
The model focuses on passenger, flight, airport, booking, and the relationships between flight and the airport they serve.

## The domain
The platform represents passengers who book flights and flights that operate between airports. 
Passengers can make multiple bookings, while each booking is associated with one passenger and one flight. 
The booking records also capture when the booking was made and the fare paid, allowing the system to track both the transaction and its associated flight.

Flights are associated with airports through defined flight routes. 
Each airport associated with a flight is assigned a role, such as DEPARTURE or ARRIVAL. 
Flight data also includes whether a flight is currently active and its scheduled duration. 
Airport information includes the airport's name, city, and country, providing descriptive information about the locations served by each flight.

The database must be able to answer questions such as:

- Which flights has a given passenger booked, and what did they pay?
- Which passengers have booked a particular flight?
- What airports are associated with a given flight, and what role does each airport serve?
- What is the departure and arrival airport for a given flight?
- Is a given flight currently active, and how long is its duration?
- Which airports are served by active flights?

## Schema
The relational schema consists of five tables:

- `PASSENGER` — stores passenger information, including a unique passenger ID, name, email, date of birth, gender, and nationality.
- `FLIGHT` — stores flight information, including a unique flight ID, flight name, active status, and duration in minutes.
- `AIRPORT` — stores airport information using a three-character airport code as its primary key, along with the airport name, city, and country.
- `BOOKING` — records the relationship between a passenger and a flight, including when the booking was created and the fare paid.
- `FLIGHT_ROUTE` — associates flights with airports and identifies each airport's role as either `DEPARTURE` or `ARRIVAL`.

Several design decisions are reflected in the schema. `PASSENGER`, `FLIGHT`, and `BOOKING` use generated integer identifiers as surrogate primary keys, while `AIRPORT` uses its three-character airport code as a natural key. `FLIGHT_ROUTE` uses the composite primary key `(flight_id, airport_id)` because each row represents the association between a specific flight and airport.

Foreign keys enforce the relationships between the tables. Historical booking information is protected by restricting the deletion of passengers or flights that are still referenced by bookings. Airport deletion is similarly restricted while an airport is referenced by a flight route. In contrast, deleting a flight cascades to its dependent `FLIGHT_ROUTE` records because those associations have no meaning without the flight.

The schema also enforces important domain rules through database constraints. Passenger email addresses must be unique, flight durations must be greater than zero, booking fares cannot be negative, and an airport's role within a flight route must be either `DEPARTURE` or `ARRIVAL`. Flights can be marked inactive rather than deleted, allowing historical booking records to remain intact.

## ERD
<img width="4860" height="3168" alt="Passenger Booking Flow Model-2026-09-27-150745" src="https://github.com/user-attachments/assets/0e47190f-8a0f-4c9a-83f7-32b32762a644" />

## Unit 4 — Aggregation and Grouping: From Rows to Insight

#### Query Catalogue

| Query | Business Question | SQL Concepts |
|---|---|---|
| `queries/unit4/q4_1.sql` — 4.1.1 | How many playback events occurred, what are the total, average, minimum, and maximum playback durations, and how many unique listeners participated? | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `COUNT(DISTINCT)` |
| `queries/unit4/q4_1.sql` — 4.1.1 Data Quality | How many playback events are missing duration information? | `COUNT`, NULL handling |
| `queries/unit4/q4_1.sql` — 4.1.2 | Which producers generate the most playback events, and how does average listening duration vary across producers? | `GROUP BY`, `COUNT`, `AVG`, `ORDER BY` |
| `queries/unit4/q4_1.sql` — 4.1.3 | Which producers have at least five playback events, providing a minimum volume for performance comparisons? | `GROUP BY`, `HAVING`, `COUNT` |
| `queries/unit4/q4_1.sql` — 4.1.4 | How does playback activity and average listening duration vary across producers and subscription tiers? | `JOIN`, `GROUP BY` with two dimensions, `AVG`, `COUNT` |
| `queries/unit4/q4_2.sql` — 4.2A | How many total playback events and failed playback events does each producer generate? | Conditional aggregation, `SUM(CASE WHEN ...)`, `COUNT`, `JOIN` |
| `queries/unit4/q4_2.sql` — 4.2B | How do playback failures compare between subscription tiers, and what are the platform-wide totals? | `GROUPING SETS`, `GROUPING`, conditional aggregation |
| `queries/unit4/q4_2.sql` — 4.2C | What is the combined failure-rate baseline for high-volume producers with at least five playback events? | Common Table Expressions (`WITH`), `GROUP BY`, aggregate filtering, `SUM` |

#### Analysis and Findings

The detailed analysis, leadership findings, and reflection are documented in [`analysis/unit4-complete.md`](analysis/unit4-complete.md).








