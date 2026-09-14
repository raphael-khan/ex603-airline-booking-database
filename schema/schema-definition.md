```text
erDiagram
    PASSENGER ||--o{ BOOKINGS : makes
    FLIGHTS ||--o{ BOOKINGS : has
    FLIGHTS ||--o{ FLIGHT_ROUTES : includes
    AIRPORTS ||--o{ FLIGHT_ROUTES : serves

    PASSENGER {
        INT passenger_id PK
        VARCHAR passenger_name
        VARCHAR email UK
        DATE DOB
        VARCHAR(15) gender
        VARCHAR(15) nationality
    }

    FLIGHTS {
        INT flight_id PK
        VARCHAR(15) flight_name
        BOOLEAN is_Active
        INT duration_min
    }

    BOOKINGS {
        INT booking_id PK
        INT passenger_id FK
        INT flight_id FK
        DATETIME booked_at
        DECIMAL(10,2) fare_paid
    }

    AIRPORTS {
        CHAR(3) airport_id PK
        VARCHAR airport_name
        VARCHAR airport_city
        VARCHAR airport_country
    }

    FLIGHT_ROUTES {
        INT flight_id PK,FK
        VARCHAR airport_id PK,FK
        VARCHAR(15) airport_role
    }

