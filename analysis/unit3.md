# Unit 3 Findings — Dashboard Audit Findings

**To:** Dashboard Team  
**Subject:** Booking Failure Rate Investigation and Payout Recommendation

The dashboard reported that approximately 50% of booking events ended in failure, prompting leadership to freeze the quarterly route payout. Our investigation found that the underlying booking data does not support this figure. Across all 200 bookings, only 12 were classified as passenger no-shows, representing a 6% failure rate. Applying the platform's producer eligibility criteria—active flights with at least 180 seats—identified eight qualifying flights with 106 bookings. Of those, only six were passenger no-shows, resulting in a **5.66% failure rate**. Both measurements are substantially lower than the dashboard's reported figure.

The investigation demonstrated how incorrect handling of missing cancellation reasons can silently exclude valid booking records and distort the reported failure rate. It also identified a separate SQL issue involving a calculated column that was referenced before it was available.
These findings demonstrate why queries must be validated against the complete, intended population rather than accepted simply because their results appear reasonable. 

We recommend that the dashboard team correct and validate the reporting logic, confirm the appropriate eligibility criteria, and recalculate the route profitability metrics. **Leadership should reconsider the payout freeze based on the corrected results**, subject to the normal profitability and payout requirements. The original dashboard figure should not be used to justify continuing the freeze.
