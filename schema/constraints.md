Primary Key Constraints:
1. PASSENGER. 
passenger_id is the primary key.  
Each passenger must have a unique, non-null identifier.  
email must be unique.  

2. FLIGHTS. 
flight_id is the primary key.  
Each flight must have a unique, non-null identifier.  
is_active boolean is restricted to either true or false.  
duration_min is restricted to positive integer values only.  

4. BOOKINGS. 
booking_id is the primary key.  
Each booking must have a unique, non-null identifier.  
fare_paid must be in USD dollars and is restricted to positive integer values.  

5. AIRPORTS. 
airport_id is the primary key.  
airport_id is restricted to universal 3 character convention.  
Each airport must have a unique, non-null identifier.  

6. FLIGHT_ROUTES. 
(flight_id, airport_id) is a composite primary key.  
A flight cannot be associated with the same airport more than once.  
airport_role is restricted to either Arrival or Departure.  

Foreign Key Constraints and ON DELETE Behavior:  
1. BOOKINGS.passenger_id → PASSENGER.passenger_id. 
Every booking must reference an existing passenger.   
ON DELETE RESTRICT: A passenger cannot be deleted while they have existing bookings.
This preserves booking history and prevents bookings from referencing a passenger that no longer exists.  

3. BOOKINGS.flight_id → FLIGHTS.flight_id. 
Every booking must reference an existing flight.  
ON DELETE RESTRICT: A flight cannot be deleted while it has existing bookings.
This preserves booking history and prevents existing bookings from referencing a nonexistent flight.  

5. FLIGHT_ROUTES.flight_id → FLIGHTS.flight_id. 
Every flight-route record must reference an existing flight.  
ON DELETE CASCADE: When a flight is deleted, its associated route records should also be deleted because those route records have no independent meaning without the flight.  

6. FLIGHT_ROUTES.airport_id → AIRPORTS.airport_id. 
Every flight-route record must reference an existing airport.  
ON DELETE RESTRICT: An airport cannot be deleted while it is associated with a flight route.
This prevents a flight route from referencing an airport that no longer exists.  
