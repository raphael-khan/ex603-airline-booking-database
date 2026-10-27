# Unit 4 Findings — From Rows to Insight

Theme: Airline Booking
Dataset: airline.sql
Event table: bookings
Producer: flights.flight_id
Actor: passengers.passenger_id
Region: flights.origin_country

## Task 4.1: Measure the Platform

Platform-wide summary

The dataset contains 200 booking events associated with 30 unique passengers. I used aggregate functions to examine total fare revenue, average fare, minimum and maximum fares, and booking volume.

One important observation is that the minimum fare is $0.00. This does not automatically indicate a data-quality error because cancelled bookings can legitimately have zero recorded fare. A separate query checks how many zero-fare bookings are cancelled so that these values are interpreted correctly rather than excluded without justification.

The average fare also needs context. It includes all booking records, including cancellations, and therefore should not be interpreted as the average amount paid for completed bookings.

Per-producer breakdown

Grouping by flight_id shows how booking activity varies across flights. The event count identifies which flights generate the greatest booking volume, while the average fare provides an additional measure of their financial activity.

The airline's operations manager or revenue management analyst could use this breakdown to identify high-demand flights, evaluate pricing patterns, and determine which flights deserve closer investigation.

However, average fare and booking count do not reveal the full distribution of fares or explain why bookings were cancelled. A flight with a high average fare may still have a significant number of zero-fare cancellations. Aggregate results can also hide whether bookings come from many passengers or repeated activity by a smaller group.

HAVING threshold

I used HAVING COUNT(*) >= 15 to identify relatively high-volume flights. This threshold reduces the influence of flights with very small booking counts and creates a more meaningful group for comparing performance.

The threshold is an analytical choice rather than a business rule. A smaller flight may still have an important operational issue even if it does not meet the volume requirement.

Two-dimensional grouping

I grouped bookings by flight identifier and flight origin country using flights.origin_country.

This allows the report to connect individual flight performance to a geographic region. The geographic attribute comes directly from the flights table, so no substitute regional mapping is necessary.

Because each flight has one recorded origin country, this grouping does not split a single flight across multiple regions. It identifies the origin region associated with each flight.

## Task 4.2: Build the Breakdown Leadership Asked For

**Part A** 

Conditional aggregation answers two business questions side by side:

How many total booking events did each flight generate?

How many of those bookings were cancelled because of a passenger no-show?

Using COUNT(*) alongside SUM(CASE WHEN ... THEN 1 ELSE 0 END) produces both totals in the same grouped result.

This makes it possible to calculate each flight's no-show rate without excluding successful bookings from the denominator. The query also identifies flights with zero failures, which could disappear from a separate failure-only query.

For this analysis, a failure is specifically defined as a booking with status cancelled and cancellation reason Passenger no show. Other cancellation reasons are not classified as passenger no-show failures.

**Part B** 
The regional director needs summarized results by flight origin country rather than a long list of individual flights.

The GROUPING SETS query produces one subtotal for each origin country and a single platform-wide grand total. The country rows are regional subtotals, while the row labeled ALL REGIONS represents all bookings across the platform.

Regional subtotals help the director compare geographic performance and decide where targeted operational improvements may be needed.

The grand total supports a different decision: whether passenger no-shows are sufficiently widespread to justify a platform-wide intervention. Regional rows alone cannot communicate the complete platform rate as directly.

**Part C** 
The CTE pipeline answers the question:

What is the combined passenger no-show rate for high-volume flights with at least 15 bookings?

The first step summarizes total bookings and passenger no-shows for each flight.

The second step selects flights meeting the 15-booking threshold and aggregates their totals into a common performance baseline.

This produces a booking-weighted failure rate. Flights with more bookings contribute proportionally more to the baseline than flights with fewer bookings.

The baseline can be used to compare individual high-volume flights against the broader high-volume group.

## Reflection

Conditional aggregation allows us to calculate total bookings and passenger no-shows together while examining the same group of booking records. Using COUNT(*) and SUM(CASE WHEN ...) in one query gives each flight both its total activity and its failure count. This makes the results easier to compare and ensures that the no-show rate uses the correct denominator.

An alternative would be to run one filtered query to count all bookings and another to count only passenger no-shows. Although both approaches can produce the same results, separate queries require additional work to combine the outputs. They can also create complications when a flight has no failures because that flight may be missing from the failure-only results. The developer must account for these missing groups to avoid incorrect comparisons.

At one million booking records, repeated table scans and additional merging operations can increase processing time and resource consumption. Conditional aggregation can reduce unnecessary work by calculating related metrics during the same grouped analysis. It also makes the logic easier to review because the numerator and denominator are defined together.

However, performance depends on indexes, the query optimizer, and the execution plan. A single query is not automatically faster in every situation. Its strongest advantages are consistency, clarity, and easier maintenance as the dataset grows.
