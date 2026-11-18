# EX603 — Unit 6: Final Leadership Memo

## Airline Booking Platform — Performance Findings and Next-Quarter Recommendations

### Executive Summary

The airline booking platform recorded 200 bookings during 2023, including 12 cancellations attributed to passenger no-shows. This represents an overall no-show rate of **6.00%**.

The monthly results do not demonstrate consistent improvement. Although October and November recorded no passenger no-shows, December ended with a **12.50% no-show rate**, compared with 0.00% in November.

The platform therefore experienced fluctuating performance, with a deterioration in the final observed month. Leadership should focus next quarter on reducing no-shows for higher-risk flights, verifying inactive booking activity, and establishing regular performance monitoring.

### 1. Is the Failure Problem Getting Better or Worse?

The monthly trend query from Task 6.3 groups bookings by calendar month and uses `LAG()` to compare each month's no-show rate with the previous month.

The results show several important patterns:

- **March:** The no-show rate reached 18.18%, with 2 no-shows across 11 bookings.
- **June through September:** Monthly rates remained between 5.00% and 6.25%.
- **October and November:** Both months recorded zero no-shows.
- **December:** The rate increased to 12.50%, with 2 no-shows across 16 bookings.

These results suggest that the problem was not consistently improving. The final month was worse than the two preceding months, although the relatively small number of bookings means that a few events can significantly change the monthly percentages.

The overall rate of 6.00% provides a baseline, but the month-over-month analysis reveals variation that the platform-wide average alone would hide.

**Conclusion:** The evidence does not support a sustained improvement. Performance fluctuated during 2023, and the final observed month showed a renewed increase in passenger no-shows.

### 2. What Should the Team Do Next Quarter?

**Priority 1: Investigate flights with elevated no-show rates.**

The producer-level aggregation from Unit 4 identified flights 2, 3, and 4 as having elevated no-show rates. Flight 2 had 3 no-shows across 16 bookings, or 18.75%, making it a reasonable starting point.

The operations team should review cancellation reasons, passenger reminders, and check-in communications for these flights. Flight 3 is marked inactive, so its operational status should be confirmed before making changes.

**Priority 2: Investigate flights with no booking activity.**

The outer joins and `NOT EXISTS` queries from Unit 5 identified flights 14 (VN214) and 15 (VN215) as having zero recorded bookings despite being marked active.

The team should verify that these flights were actually available for booking during the observed period. If they were available, leadership should investigate demand, pricing, and route suitability. Zero recorded bookings should not automatically be treated as an operational failure.

**Priority 3: Establish monthly performance monitoring.**

The monthly `LAG()` analysis from Unit 6 demonstrates why leadership should monitor changes over time instead of relying only on a single platform-wide percentage.

I recommend a monthly dashboard displaying total bookings, no-show counts, no-show rates, and changes from the previous month. The dashboard should also show flight-level results so that unusual increases can be investigated.

As a practical initial goal, leadership could aim to reduce the overall no-show rate below the historical 6.00% baseline while monitoring booking volume to ensure the improvement is meaningful.

### 3. Measuring Success

At the end of the next quarter, leadership should review whether:

1. The overall no-show rate has decreased below the 6.00% historical baseline.
2. Previously flagged flights show fewer no-shows without relying on unusually small booking samples.
3. The booking availability and activity status of flights 14 and 15 has been verified.
4. Monthly reporting is consistent enough to identify emerging problems before the end of a reporting period.

These measures would help the team distinguish genuine operational improvements from temporary fluctuations.

### Final Recommendation

The platform's failure problem is **not conclusively getting better**. The data shows periods of improvement followed by a renewed increase in December.

For the next quarter, leadership should prioritize targeted no-show investigations, verify the two zero-booking flights, and introduce recurring monthly performance reviews.

The goal should be to turn the SQL analysis into a repeatable process for identifying problems, taking action, and measuring whether those actions work.

### Supporting Queries

- **Unit 4 — Producer aggregation:** No-show counts and rates by flight.
- **Unit 5 — Outer joins and NOT EXISTS:** Identification of flights with no bookings.
- **Unit 6, Task 6.2:** Chronological booking comparisons and activity-gap detection.
- **Unit 6, Task 6.3 Part B:** Monthly no-show rates, previous-month comparisons, and percentage changes.
