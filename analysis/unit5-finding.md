# Unit 5: Leadership Findings and Recommendations

## Airline Booking Platform — Performance Review

### Summary

Our analysis identified two different concerns: flights with unusually high passenger no-show rates and flights that have never received a booking in the supplied dataset. These groups require different responses.

### 1. Flights with High No-Show Rates

Assignment 4 identified three flights worth investigating:

| Flight ID | No-shows | Total bookings | No-show rate |
|---|---:|---:|---:|
| 2 | 3 | 16 | 18.75% |
| 3 | 2 | 13 | 15.38% |
| 4 | 1 | 6 | 16.67% |

The platform-wide no-show rate was **6.00%**, making these flights potential areas of concern.

**Recommendation:** Prioritize flight 2 for a review of passenger no-shows because it has the highest number of no-shows and the highest observed rate among these three flights. Review booking dates, cancellation reasons, passenger communications, and check-in procedures to identify possible patterns.

Flights 3 and 4 should also be monitored, but their smaller booking samples make their percentages less reliable as indicators of persistent problems. Flight 3 is marked inactive in the dataset, so its current operating status should be confirmed before taking action.

A practical next step is to introduce or review pre-departure reminders and check-in instructions, then monitor whether no-show rates improve over subsequent booking periods.

### 2. Flights with No Booking Activity

Assignment 5 identified two flights with no recorded bookings:

| Flight ID | Flight number | Booking count |
|---|---|---:|
| 14 | VN214 | 0 |
| 15 | VN215 | 0 |

Both flights are marked active, but neither appears in the booking records.

**Recommendation:** Ask the operations team to verify that flights 14 and 15 are scheduled, available for booking, and visible to customers.

If both flights are correctly configured, the commercial team should investigate passenger demand, pricing, and route suitability before deciding whether to promote or adjust these services.

A flight with zero bookings is not necessarily experiencing operational failure. It may be newly introduced, unavailable during the recorded period, or simply receiving insufficient demand. Further investigation is needed to establish the cause.

### Conclusion

Leadership should take two separate actions:

- **High no-show flights:** Investigate booking reliability and passenger check-in behavior, starting with flight 2.
- **Zero-booking flights:** Verify operational availability and booking-system visibility for flights 14 and 15 before investigating demand.

These actions address different problems. The first focuses on improving outcomes for existing booking activity, while the second focuses on understanding why some active flights have no recorded activity.

The database identifies which flights deserve attention, but it does not establish the underlying causes. Any operational changes should be guided by additional investigation and subsequent performance monitoring.
