# EX603 — Unit 6: Window Functions and Analytics

## Task 6.1 — Compute Across a Window Without Collapsing

### Question 1: Comparing Individual Events with Their Producer's Average

A useful business question for the airline platform is: **Which individual bookings have fares that are unusually high or low compared with the average fare for the same flight?**

I used `AVG(fare_paid) OVER (PARTITION BY flight_id)` to calculate each flight's average fare while preserving every individual booking record. The query also calculates the difference between each booking's fare and its flight's average.

The window-function query returns **200 rows**, one for every booking. In comparison, the `GROUP BY` query returns **13 rows**, one for each flight with recorded bookings.

The grouped average alone cannot answer this question because it removes the individual booking records. Without the original fares, it is impossible to identify which bookings differ significantly from their flight's average. The window function provides both the individual and group-level information in the same result.

### Question 2: Ranking Producers

I ranked flights by their total number of bookings using `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`.

The results demonstrate how each function handles ties. For example, flights 5 and 7 both have 18 bookings. `ROW_NUMBER()` assigns them different positions, while `RANK()` and `DENSE_RANK()` assign them the same rank.

A useful platform feature would be a **flight booking activity leaderboard** for operations management. I would use `DENSE_RANK()` because flights with equal booking counts should receive equal recognition, and the next distinct booking count should receive the next rank without gaps.

This would make the leaderboard easier to interpret while avoiding arbitrary differences between flights with identical booking volumes.

### Question 3: Dividing Producers into Four Bands

I used `NTILE(4)` to divide the 15 flights into four booking-volume bands, with Band 1 containing the highest-volume flights.

The results show that flights 5 and 7 both have 18 bookings but fall into different bands. Flight 5 is assigned to Band 1, while flight 7 is assigned to Band 2.

This happens because `NTILE(4)` divides the ordered rows into groups of approximately equal size. It does not guarantee that tied values remain in the same band.

This is important when interpreting the results. Although quartile bands can help leadership identify high- and low-activity groups, they should not be treated as strict performance categories when tied flights fall on opposite sides of a boundary.

For decisions affecting individual flights, I would review the actual booking counts alongside the assigned bands.
