# Airline Booking Database & SQL Analytics

**A PostgreSQL portfolio project that models airline bookings and analyzes booking volume, passenger no-shows, fares, and operational trends using SQL.**

## Domain overview

An airline booking platform connects passengers, flights, airports, and bookings. In the initial modeling phase (Units 1–2), I designed a relational schema to represent passenger reservations and the airports associated with each flight. This work focused on entities, relationships, primary and foreign keys, and constraints that protect data integrity.

In the analytics phase (Units 3–6), I worked with an **instructor-provided airline booking dataset** (`airline.sql`). I used SQL to answer questions that matter to an airline operations team: Which flights attract the most bookings? Which have disproportionately high passenger no-show rates? Are cancellations improving month by month? Are some flights marked active despite having no recorded bookings? How can analysts distinguish a change in booking activity from a gap in the underlying data?

The project follows a progression from row-level data validation and aggregation through joins, execution-plan analysis, and window functions. The final objective is not simply to produce query results, but to translate those results into operational recommendations, while explaining the limits of the evidence.

## Database overview

The initial ERD models five core entities: `PASSENGER`, `FLIGHT`, `AIRPORT`, `BOOKING`, and `FLIGHT_ROUTE`. `BOOKING` connects a passenger to a flight; `FLIGHT_ROUTE` associates a flight with airports and their departure/arrival roles. Keys, foreign-key constraints, and domain checks support referential integrity.

![Original passenger booking ERD](https://github.com/user-attachments/assets/0e47190f-8a0f-4c9a-83f7-32b32762a644)

The Unit 3 reference DDL and seed data are contained in [`airline.sql`](schema/airline.sql). Its main tables are:

| Table | Role in the analysis |
| --- | --- |
| `passengers` | Passenger details, including signup dates and home countries |
| `flights` | Flight identifiers, flight numbers, origin countries, capacity, and active status |
| `bookings` | Individual booking events, timestamps, fares, statuses, and cancellation reasons |
| `airports` | Airport reference information |
| `flight_routes` | Flight-to-airport associations |
| `flight_services` | Services associated with flights |

The reference dataset contains **200 bookings, 30 passengers, and 15 flights**. In the analytical work, an **event** means a booking, a **producer** means a flight, and the principal financial metric is `bookings.fare_paid`. A **passenger no-show** is defined narrowly as a booking with `booking_status = 'cancelled'` and `cancellation_reason = 'Passenger no show'`; it does not include every type of cancellation or dispute. The dataset does not explicitly specify a currency for fares.

## Query catalogue

### Unit 3 — Query fundamentals and data validation

| Query | Business question | Techniques |
| --- | --- | --- |
| [`q3_1.sql`](queries/unit3/q3_1.sql) | Which flights and bookings meet the operational eligibility criteria? | Population filtering |
| [`q3_2.sql`](queries/unit3/q3_2.sql) | Could missing values cause records to be incorrectly included or excluded? | `NULL` and three-valued logic |
| [`q3_3.sql`](queries/unit3/q3_3.sql) | Can equivalent SQL formulations produce the same correct result? | Query rewrites and aliases |

[Unit 3 findings and reflection](analysis/unit3.md)

### Unit 4 — Aggregation and grouping

| Query | Business question | Techniques |
| --- | --- | --- |
| [`q4_1.sql`](queries/unit4/q4_1.sql) | What are total bookings, unique passengers, and fare statistics? | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` |
| [`q4_1.sql`](queries/unit4/q4_1.sql) | Which flights have the most bookings and which meet a volume threshold? | `GROUP BY`, `HAVING` |
| [`q4_1.sql`](queries/unit4/q4_1.sql) | How does activity vary by flight and origin country? | Joins, multidimensional grouping |
| [`q4_2.sql`](queries/unit4/q4_2.sql) | How many passenger no-shows occur by flight? | Conditional aggregation |
| [`q4_2.sql`](queries/unit4/q4_2.sql) | How do no-shows vary by region and platform-wide? | `GROUPING SETS` |
| [`q4_2.sql`](queries/unit4/q4_2.sql) | Which high-volume flights warrant attention? | CTEs, second-stage aggregation |

[Unit 4 findings and reflection](analysis/unit4.md)\
[Unit 4 leadership breakdown](analysis/unit4-finding.md)

### Unit 5 — Connecting tables and query performance

| Query | Business question | Techniques |
| --- | --- | --- |
| [`q5_1.sql`](queries/unit5/q5_1.sql) | How can booking events be enriched with passenger, flight, and airport context? | Inner joins, junction joins, self-joins |
| [`q5_2.sql`](queries/unit5/q5_2.sql) | Which flights have no bookings, and what do outer joins preserve? | Left/right/full joins, `NOT EXISTS`, `EXCEPT` |
| [`q5_3.sql`](queries/unit5/q5_3.sql) | How does PostgreSQL execute a multi-table join, and what would a cross join produce? | `CROSS JOIN`, `EXPLAIN (ANALYZE, BUFFERS)` |

[Unit 5 analysis and reflection](analysis/unit5.md)\
[Unit 5 leadership findings and recommedation](analysis/unit5-finding.md)

### Unit 6 — Window functions and reporting

| Query | Business question | Techniques |
| --- | --- | --- |
| [`q6_1.sql`](queries/unit6/q6_1.sql) | Which fares differ from their flight average, and how should flights be ranked and banded? | `AVG OVER`, `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE` |
| [`q6_2.sql`](queries/unit6/q6_2.sql) | How do consecutive fares, cumulative totals, moving averages, and activity gaps change over time? | `LAG`, `LEAD`, running `SUM`, moving `AVG` |
| [`q6_3.sql`](queries/unit6/q6_3.sql) | What are the top three fares per flight, and how does the monthly no-show rate change? | `FIRST_VALUE`, top-N CTEs, `DATE_TRUNC`, `LAG` |

[Unit 6 analysis and reflection](analysis/unit6.md)\
[Final leadership memo](analysis/unit6-finding.md)

## Technical highlights

1. **Conditional aggregation:** Counted passenger no-shows and total bookings in the same query, producing interpretable flight-level rates without excluding non-failure events.
2. **Joins and anti-joins:** Connected booking facts to flight and passenger dimensions, and used `NOT EXISTS` to find active flights with no booking records.
3. **CTEs and multi-stage analysis:** Separated intermediate calculations from final filtering, particularly for high-volume flight screening and detecting gaps between booking timestamps.
4. **Window functions:** Kept individual booking rows while adding flight averages, rankings, adjacent-event comparisons, cumulative fare totals, and month-over-month comparisons.
5. **Query-plan inspection:** Used PostgreSQL `EXPLAIN (ANALYZE, BUFFERS)` to examine join strategy, memoization, and execution behavior rather than assuming a query's cost from its SQL syntax.

## Findings and recommendations

### 1. Passenger no-shows require targeted attention

Across **200 bookings**, **12** were classified as passenger no-shows: a **6.00%** overall rate. Flight **2** recorded **3 no-shows out of 16 bookings (18.75%)**. Flights **3** and **4** also had elevated rates, although their samples were small. **Recommendation:** review reminders, check-in communications, and cancellation patterns for these flights before introducing broad policy changes.

### 2. Active status does not guarantee booking activity

Flights **14 (VN214)** and **15 (VN215)** are marked active but have **no recorded bookings** in the reference dataset. **Recommendation:** check scheduling and booking availability first, then investigate demand or pricing if the flights were genuinely available. Zero recorded bookings alone do not prove that a flight was operating without passengers.

### 3. Monthly failure rates fluctuate rather than improving consistently

The window-function reporting pattern compares monthly no-show rates using `LAG`. The overall annual rate is a useful baseline, but monthly percentages can shift sharply when booking counts are small. **Recommendation:** track both monthly no-show counts and rates, compare consecutive months, and investigate sustained changes rather than acting on one volatile percentage.

See the [final leadership memo](analysis/unit6-finding.md) for the supporting analysis and proposed next-quarter actions.

## Limitations and future improvements

The reference dataset is small and represents a limited observation period. Monthly rates and flight-level comparisons can change substantially with only one or two additional no-shows, so they should not be interpreted as causal evidence or statistically reliable forecasts. The data also lacks flight-operation logs, reminder-delivery history, and booking-availability records; without those sources, a gap in bookings cannot establish whether a flight stopped operating or the data collection process missed events.

A useful next step would be to join bookings with scheduled flight operations and notification records, track performance over a longer period, and compare no-show rates using sufficient sample sizes. This would make operational recommendations more defensible.

## Video presentation

[![EX603 - Video Presentation](https://youtube.com)](https://youtu.be/O6ZOdPIyE-0)

The video will walk through the business problem, selected queries from Units 4–6, the most important findings, leadership memo and the recommended next-quarter actions.

## How to run

**Requirements:** PostgreSQL with the `psql` command-line client, and the repository files.

```bash
git clone https://github.com/raphael-khan/ex603-airline-booking-database.git
cd ex603-airline-booking-database

createdb ex603_data                                # skip if using an existing database
psql -d ex603_data -f schema/airline.sql           # add -U/-h if your setup needs them

psql -d ex603_data -f queries/unit4/q4_1.sql
psql -d ex603_data -f queries/unit6/q6_3.sql
```
