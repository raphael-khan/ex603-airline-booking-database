# EX603 — Unit 5: Connecting the Tables

## Task 5.1 — Connect Producers to Their Data

### Question 1: What feature or report could use the three-table join?

The three-table join could support a booking activity report for the airline's operations team. It connects the `bookings`, `passengers`, and `flights` tables to display which passenger made each booking, the flight associated with the booking, and the date and time the booking occurred.

This report would help operations staff review booking activity, investigate passenger no-shows, and identify patterns involving specific flights. It would also provide more useful information than the producer IDs alone because staff could see the passengers and flight numbers associated with individual booking events.

### Question 2: Why is the junction table important?

The `flight_routes` junction table is important because flights and airports have a many-to-many relationship. 

A flight can be associated with multiple airports, and an airport can serve multiple flights.

The junction table stores these relationships using `flight_id` and `airport_id`. By joining `flights` to `flight_routes` and then to `airports`, we can identify the airports associated with each flight.

Without the junction table, the database would need to store airport information directly in the flight records or use repeated columns for multiple airports. This would make the design less flexible and complicate queries when flights serve different numbers of airports.

The junction table also allows us to investigate whether flights with elevated passenger no-show rates share airport associations. However, a shared airport does not necessarily explain the higher failure rate; further operational data would be needed to establish a cause.
