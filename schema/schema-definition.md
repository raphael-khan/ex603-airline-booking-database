```text
erDiagram
    PASSENGER ||--o{ BOOKING : makes
    FLIGHT ||--o{ BOOKING : has
    FLIGHT ||--o{ FLIGHT_ROUTE : includes
    AIRPORT ||--o{ FLIGHT_ROUTE : serves
    PASSENGER {
        INT passenger_id PK
        VARCHAR(100) passenger_name
        VARCHAR(254) email UK
        DATE dob
        VARCHAR(15) gender
        VARCHAR(50) nationality
    }
    FLIGHT {
        INT flight_id PK
        VARCHAR(15) flight_name
        BOOLEAN is_active
        INT duration_min
    }
    BOOKING {
        INT booking_id PK
        INT passenger_id FK
        INT flight_id FK
        DATETIME booked_at
        DECIMAL(10,2) fare_paid
    }
    AIRPORT {
        CHAR(3) airport_id PK
        VARCHAR(100) airport_name
        VARCHAR(100) airport_city
        VARCHAR(100) airport_country
    }
    FLIGHT_ROUTE {
        INT flight_id PK,FK
        CHAR(3) airport_id PK,FK
        VARCHAR(15) airport_role
    }

