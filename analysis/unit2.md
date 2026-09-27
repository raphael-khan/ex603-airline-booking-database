# Unit 2 — DDL Design Analysis

## Foreign Key Constraints

The following foreign key constraints define how related records are handled when a referenced parent record is deleted.
Foreign Key | ON DELETE | Reason |
- `BOOKING.passenger_id → PASSENGER.passenger_id` | `RESTRICT` | A passenger cannot be deleted while bookings reference them because the booking history must retain a valid passenger.
- `BOOKING.flight_id → FLIGHT.flight_id` | `RESTRICT` | A flight cannot be deleted while bookings reference it because deleting the flight would invalidate existing booking records.
- `FLIGHT_ROUTE.flight_id → FLIGHT.flight_id` | `CASCADE` | When a flight is deleted, its route records are automatically deleted because they have no meaning without the flight.
- `FLIGHT_ROUTE.airport_id → AIRPORT.airport_id` | `RESTRICT` | An airport cannot be deleted while a flight route references it because doing so would leave the route without a valid airport.

### ON DELETE Reasoning

The `BOOKING.passenger_id` foreign key uses `ON DELETE RESTRICT`. On the platform, a passenger may have one or more historical bookings associated with their account. If an attempt is made to delete a passenger who still has bookings, the database rejects the deletion. This preserves the relationship between each booking and the passenger who made it. Using `CASCADE` instead would cause deleting a passenger to also delete their booking history, which could remove important transaction records.

The `BOOKING.flight_id` foreign key also uses `ON DELETE RESTRICT`. A flight may have bookings made by multiple passengers, so removing a flight that is still referenced by those bookings would affect every passenger booked on that flight. Restricting the deletion requires those booking records to be addressed before the flight can be removed. Using `CASCADE` would automatically delete all associated bookings and could result in unintended loss of booking history. The `is_active` attribute also provides a way to mark a flight as inactive without deleting its record when historical bookings still exist.

The `FLIGHT_ROUTE.flight_id` foreign key uses `ON DELETE CASCADE`. A flight-route record exists only to associate a particular flight with an airport and its role in that route. If a flight with no protected booking references is removed from the platform, its `FLIGHT_ROUTE` records no longer have a meaningful parent and should be removed automatically. Using `RESTRICT` here would require route records to be manually deleted before the flight could be deleted, even though those records have no independent purpose.

Finally, `FLIGHT_ROUTE.airport_id` uses `ON DELETE RESTRICT`. An airport can participate in the routes of multiple flights. If the airport were deleted while those relationships still existed, those flight routes would no longer identify a valid airport. `RESTRICT` prevents this invalid state and forces the affected route relationships to be addressed first. Using `CASCADE` would be undesirable because deleting one airport could automatically remove route information from many otherwise valid flights.

## CHECK Constraints

### Positive Flight Duration

The `chk_flight_duration` constraint requires:

`duration_min > 0`
This prevents a flight from being stored with a duration of zero or a negative duration. Such a state could arise from incorrect user input, an application bug, or invalid imported data. Since an actual flight must take a positive amount of time, rejecting these values at the database level prevents invalid duration data regardless of which application writes to the database.

### Non-negative Booking Fare

The `chk_booking_fare` constraint requires:
`fare_paid >= 0`
This prevents a booking from being stored with a negative fare. A negative value could result from incorrect calculations, malformed imported data, or an application error. A fare of zero remains valid so the model can represent a complimentary or fully discounted booking, but a negative amount is rejected as an invalid booking state.

### Valid Airport Role

The `chk_flight_route_role` constraint requires:
`airport_role IN ('DEPARTURE', 'ARRIVAL')`
This prevents a flight-route record from containing an unsupported airport role. Without this constraint, values such as `UNKNOWN`, `ORIGIN`, misspelled values, or arbitrary text could be inserted because the column is represented as `VARCHAR(15)`. Enforcing the permitted values in the database ensures that every stored route association has a role recognized by the current domain model. The application is responsible for ensuring that a complete flight route contains the appropriate departure and arrival associations.

