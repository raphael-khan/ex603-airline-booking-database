# Unit 2 — DDL Design Analysis

## Foreign Key Constraints
The following foreign key constraints define how related records are handled when a referenced parent record is deleted.

| Foreign Key | ON DELETE | Reason |
`BOOKING.passenger_id → PASSENGER.passenger_id` | `RESTRICT` | A passenger cannot be deleted while bookings reference them because the booking history must retain a valid passenger.
`BOOKING.flight_id → FLIGHT.flight_id` | `RESTRICT` | A flight cannot be deleted while bookings reference it because deleting the flight would invalidate existing booking records.
`FLIGHT_ROUTE.flight_id → FLIGHT.flight_id` | `CASCADE` | When a flight is deleted, its route records are automatically deleted because they have no meaning without the flight.
`FLIGHT_ROUTE.airport_id → AIRPORT.airport_id` | `RESTRICT` | An airport cannot be deleted while a flight route references it because doing so would leave the route without a valid airport.


