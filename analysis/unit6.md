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

## Task 6.2 — Compare Each Row to Its Neighbors

### Part A — Row-to-Row Comparison

I used `LAG()` and `LEAD()` to compare each booking's fare with the previous and next booking for the same flight. The window is partitioned by `flight_id` and ordered by `booked_at` and `booking_id`, ensuring a consistent chronological sequence.

For the final output, I selected flight 2 (VN202), which was previously identified as having an elevated passenger no-show rate.

The delta column calculates the current booking fare minus the previous booking fare. A positive delta indicates an increase, while a negative delta indicates a decrease.

A large delta could indicate unusual pricing, a different fare multiplier, or a cancelled booking with a zero fare. However, a large change between two individual bookings does not necessarily indicate a sustained pricing trend.

The operations team should investigate unusually large changes by reviewing booking status, fare multipliers, and cancellation reasons before deciding whether corrective action is necessary.

### Part B — Cumulative and Smoothed Performance

I used `SUM() OVER()` to calculate the running total of fares across all bookings in chronological order. I also used `AVG() OVER()` with a seven-row window to calculate the average fare across the current booking and six preceding bookings.

I selected a target of **4,000 fare units** for the dataset. The final cumulative fare is **3,628.19**, reaching **90.70% of the target**, with **371.81 remaining**.

A regular `SUM()` would provide the final total but would not show how that total developed over time. The running total preserves each booking and shows the cumulative contribution at every point, helping leadership identify when activity increased or slowed.

I chose a seven-booking moving average because it smooths individual fare fluctuations while remaining responsive to recent changes. A shorter window would react more strongly to individual bookings, while a longer window would produce a smoother but slower-changing trend.

The seven-row window represents seven booking events, not seven calendar days. Periods with fewer bookings may therefore cover a longer amount of time.

With `ROWS`, the window is based on row positions. With `RANGE`, the frame is based on ordering values, so rows sharing the same timestamp may be included together rather than treated individually.

### Part C — Identifying Activity Gaps

I used `LAG()` to compare consecutive booking timestamps for each flight. A CTE calculates the elapsed time between bookings, and an outer `WHERE` clause identifies gaps lasting at least 60 days.

One example is flight 9 (VN209), which has a gap between January 5, 2023, and April 28, 2023. The interval is approximately 112.6 days.

This demonstrates a substantial period without recorded booking events, followed by renewed recorded activity.

However, the data does not establish whether the flight stopped operating, experienced low demand, or had missing booking records.

I would classify this as a **confirmed gap in recorded booking activity with an undetermined cause**, rather than automatically treating it as a data-quality error or operational shutdown.

To investigate, I would compare the booking history with flight schedules, booking-system availability logs, and operational records.

If the flight was unavailable, the response might involve reviewing scheduling or operational decisions. If bookings were missing because of a data collection problem, the team should correct the reporting process. If the flight remained available but received no bookings, leadership should investigate demand and pricing before making changes.

This is important when interpreting the results. Although quartile bands can help leadership identify high- and low-activity groups, they should not be treated as strict performance categories when tied flights fall on opposite sides of a boundary.

For decisions affecting individual flights, I would review the actual booking counts alongside the assigned bands.
