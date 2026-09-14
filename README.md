# EX603-Airline-Booking-database-model
A relational database model for an airline booking system, capturing passengers, flights, airports, and the bookings and routes that connect them. 

## Theme
Airline Booking - This project models the core data behind an airline booking platform—the type of system that supports workflows such as searching for flights, viewing flight routes, and booking flights. 
The model focuses on passengers, flights, airports, bookings, and the relationships between flights and the airports they serve.

## The domain
The platform represents passengers who book flights and flights that operate between airports. 
Passengers can make multiple bookings, while each booking is associated with one passenger and one flight. 
The booking records also capture when the booking was made and the fare paid, allowing the system to track both the transaction and its associated flight.

Flights are associated with airports through defined flight routes. 
Each airport associated with a flight is assigned a role, such as DEPARTURE or ARRIVAL. 
Flight data also includes whether a flight is currently active and its scheduled duration. 
Airport information includes the airport's name, city, and country, providing descriptive information about the locations served by each flight.

The database must be able to answer questions such as:

- Which flights has a given passenger booked, and what did they pay?
- Which passengers have booked a particular flight?
- What airports are associated with a given flight, and what role does each airport serve?
- What is the departure and arrival airport for a given flight?
- Is a given flight currently active, and how long is its duration?
- Which airports are served by active flights?

<img width="5636" height="3168" alt="Passenger Booking Flow Model-2026-09-14-011429" src="https://github.com/user-attachments/assets/961d6835-0926-42ee-9ec8-105f63e626d2" />
