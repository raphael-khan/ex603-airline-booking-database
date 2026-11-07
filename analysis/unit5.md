# EX603 — Unit 5: Connecting the Tables

## Task 5.1 — Connect Producers to Their Data

### Question 1: What feature or report could use the three-table join?

The three-table join could support a booking activity report for the airline's operations team. It connects the `bookings`, `passengers`, and `flights` tables to display which passenger made each booking, the flight associated with the booking, and the date and time the booking occurred.

This report would help operations staff review booking activity, investigate passenger no-shows, and identify patterns involving specific flights. It would also provide more useful information than the producer IDs alone because staff could see the passengers and flight numbers associated with individual booking events.

### Question 2: Why is the junction table important?

The `flight_routes` junction table is important because flights and airports have a many-to-many relationship. A flight can be associated with multiple airports, and an airport can serve multiple flights. The junction table stores these relationships using `flight_id` and `airport_id`. By joining `flights` to `flight_routes` and then to `airports`, we can identify the airports associated with each flight. Without the junction table, the database would need to store airport information directly in the flight records or use repeated columns for multiple airports. This would make the design less flexible and complicate queries when flights serve different numbers of airports. 

The junction table also allows us to investigate whether flights with elevated passenger no-show rates share airport associations. 
However, a shared airport does not necessarily explain the higher failure rate; further operational data would be needed to establish a cause.

## Task 5.2 — Find Records That Joins May Exclude

### Part A — INNER JOIN vs. LEFT JOIN

The Airline Booking dataset contains 15 flights, but only 13 have matching booking records. The `INNER JOIN` excludes **flight IDs 14 (VN214) and 15 (VN215)** because neither has any bookings.

The `LEFT JOIN` preserves all 15 flights, including those with zero bookings. I used `COUNT(DISTINCT flight_id)` to count unique producers rather than counting individual booking rows, since a flight can have multiple bookings.

The difference is **2 excluded producers**.

### Part B — RIGHT JOIN and FULL OUTER JOIN

The `RIGHT JOIN` returns the same 15 flights as the `LEFT JOIN` when the order of the tables is reversed. Both queries preserve all flights and their corresponding booking counts.

The comparison query uses `EXCEPT` in both directions to check for differences between the two results. An empty result confirms that the returned flight IDs and booking counts match.

The `FULL OUTER JOIN` includes matching records and unmatched records from both tables. Unlike a one-sided outer join, it can reveal flights without bookings and bookings without valid flight records in the same result.

In this dataset, flights 14 and 15 have no bookings. There are no expected booking records without a matching flight because the database enforces a foreign key from `bookings.flight_id` to `flights.flight_id`.

### Part C — NOT EXISTS vs. EXCEPT

Both approaches identify flight IDs **14 and 15** as producers without booking events.

`NOT EXISTS` checks whether each flight has any matching booking record using a correlated subquery. `EXCEPT` compares the set of all flight IDs against the set of flight IDs appearing in bookings. Both approaches return the same identifiers, as verified by the comparison query.

### Write-up Questions

**1. Which producers were excluded by the inner join?**

Flight IDs 14 (VN214) and 15 (VN215) were excluded. Neither flight has a matching record in the `bookings` table.

**2. What does it mean when a producer has no events? What are some possible explanations?**

A flight with no booking events has no recorded bookings in the supplied dataset. Possible explanations include low demand, a newly introduced flight, an unavailable booking option, or incomplete event collection. Both flights are marked active, but the data does not establish why they have no bookings.

**3. How could a report based only on an inner join give leadership an incomplete picture of the platform?**

An inner join excludes flights without bookings, making it appear that only 13 flights exist instead of 15. Leadership could overlook flights that are available but generating no activity. This would make it harder to evaluate the complete flight portfolio and identify potential operational or demand problems.

**4. Why might leadership want to identify producers who have never been active?**

Leadership may want to identify flights that are not attracting bookings, determine whether they are correctly configured, and investigate whether demand or operational problems are preventing activity. These flights could represent unused capacity or missed revenue opportunities.

**5. What action could leadership take based on these findings?**

I recommend investigating flight IDs 14 and 15 to confirm that they are available for booking and correctly configured. The operations team could review their schedules, routes, and booking-system visibility before deciding whether changes to scheduling, pricing, or promotion are necessary.

The data confirms that these flights have zero recorded bookings, but it does not prove that they have never operated or explain the reason for their lack of activity.

## Task 5.3 Understanding join performance and execution plans.

### Part B — Examine a Query Execution Plan

I used PostgreSQL's `EXPLAIN` and `EXPLAIN (ANALYZE, BUFFERS)` commands to examine the three-table join from Task 5.1. The query connects `bookings`, `passengers`, and `flights` to display each passenger's booking, associated flight, and booking timestamp.

#### 1. Execution Plan

The complete execution plans are included below.

**EXPLAIN output:**

```text
Sort  (cost=35.98..36.48 rows=200 width=540)
  Sort Key: b.booked_at, b.booking_id
  ->  Nested Loop  (cost=12.40..28.34 rows=200 width=540)
        ->  Hash Join  (cost=12.25..17.80 rows=200 width=282)
              Hash Cond: (b.passenger_id = p.passenger_id)
              ->  Seq Scan on bookings b  (cost=0.00..5.00 rows=200 width=24)
              ->  Hash  (cost=11.00..11.00 rows=100 width=262)
                    ->  Seq Scan on passengers p  (cost=0.00..11.00 rows=100 width=262)
        ->  Memoize  (cost=0.15..0.41 rows=1 width=262)
              Cache Key: b.flight_id
              Cache Mode: logical
              ->  Index Scan using flights_pkey on flights f  (cost=0.14..0.40 rows=1 width=262)
                    Index Cond: (flight_id = b.flight_id)
```

**EXPLAIN ANALYZE summary:**

| Measurement | Observed result |
|---|---|
| Join algorithms | Hash Join and Nested Loop |
| Bookings scanned | 200 |
| Passengers scanned | 30 |
| Flight index searches | 13 |
| Memoize cache hits | 187 |
| Memoize cache misses | 13 |
| Final output rows | 200 |
| Sort method | Quicksort |
| Sort memory | 37 kB |
| Shared buffer hits | 30 |
| Planning time | 0.190 ms |
| Execution time | 0.401 ms |

#### 2. Join Algorithms Selected

PostgreSQL selected two join algorithms:

- **Hash Join:** Combines `bookings` and `passengers` using `b.passenger_id = p.passenger_id`. PostgreSQL builds a hash table from the smaller `passengers` table and matches booking records against it.
- **Nested Loop:** Connects the intermediate booking-passenger results to `flights` using an indexed lookup on `flights.flight_id`.

The Nested Loop also uses a `Memoize` operation, which caches flight lookup results. This avoids repeating the same index lookup when multiple bookings reference the same flight.

#### 3. Why PostgreSQL Selected These Algorithms

The Hash Join is appropriate because the passengers table is small and can be efficiently stored in memory. The execution plan shows that PostgreSQL scanned 30 passengers and built a hash table using only 10 kB of memory.

The Nested Loop is efficient because the `flights` table has a primary-key index on `flight_id`. Instead of scanning the entire flights table for each booking, PostgreSQL uses `flights_pkey` to retrieve matching records.

The Memoize operation further improves efficiency. Of the 200 flight lookups requested by the Nested Loop, 187 were served from the cache and only 13 required index searches. This makes sense because multiple bookings reference the same flights.

The execution plan also shows that PostgreSQL estimated 200 output rows and actually returned 200 rows. However, it estimated 100 passengers when only 30 were present, showing that some estimates were less accurate than others.

#### 4. Potential Performance Concerns

As the bookings table grows, the sequential scan and final sorting operation could become more expensive because both process the booking history.

The current sort uses quicksort and only 37 kB of memory. With millions of bookings, sorting could require significantly more memory or spill to disk.

The Hash Join may remain efficient if the passenger table stays relatively small. However, if the passenger population grows substantially, building the hash table could require more memory.

The Nested Loop currently performs well because of the primary-key index and Memoize cache. Its performance could change if the number of distinct flights grows significantly, reducing the cache hit rate.

#### 5. Why Understanding Join Algorithms Matters

Understanding the execution plan helps identify where PostgreSQL spends resources and whether the selected algorithms are appropriate for the data.

In this case, the query executes efficiently, completing in 0.401 ms. The plan shows that PostgreSQL combines a Hash Join, indexed Nested Loop, and Memoize cache to avoid unnecessary repeated work.

As the database grows, developers can compare execution plans to identify changes in scan methods, join strategies, row estimates, and sorting costs. These observations can guide decisions about indexing, filtering, and query optimization.

A different join algorithm might become more appropriate if the tables grow, the distribution of bookings changes, or new indexes are introduced. For example, a Merge Join could become attractive when both inputs are sorted by the join key, while an indexed Nested Loop could be effective for queries returning only a small number of bookings.
