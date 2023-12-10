--Companies
CREATE TABLE Companies (
    CompanyId SERIAL PRIMARY KEY,
    CompanyName VARCHAR(30) NOT NULL
);

--Cities
CREATE TABLE Cities (
    CityId SERIAL PRIMARY KEY,
    CityName VARCHAR(30) NOT NULL,
	DistanceFromSplit INT
);

--Airports
CREATE TABLE Airports (
   	AirportId SERIAL PRIMARY KEY,
    AirportName VARCHAR(30) NOT NULL,
    Capacity INT NOT NULL
);

-- Flights
CREATE TABLE Flights (
    FlightId SERIAL PRIMARY KEY,
    Duration INT NOT NULL,
    StartTime TIMESTAMP NOT NULL,
    AirplaneId INT REFERENCES Airplanes(AirplaneId),
    CompanyId INT REFERENCES Companies(CompanyId),
    DepartureCityId INT REFERENCES Cities(CityId),
    DestinationCityId INT REFERENCES Cities(CityId),
    
	UNIQUE (AirplaneId, StartTime)
    --CHECK (AirplaneId IS NOT NULL AND AirplaneId NOT IN (SELECT AirplaneId FROM Airplanes WHERE status IN ('Popravak', 'Dijelovi')))
);

-- Airplanes
CREATE TABLE Airplanes (
    AirplaneId SERIAL PRIMARY KEY,
    DepartureAirportId INT REFERENCES Airports(AirportId),
    CurrentAirportId INT REFERENCES Airports(AirportId),
    Status VARCHAR(20) CHECK (status IN ('Aktivan', 'Popravak', 'Dijelovi')),
    Model VARCHAR(30),
    AirplaneName VARCHAR(30),
    Capacity INT,
	ManufactureDate DATE
);

--Pilots
CREATE TABLE Pilots (
    PilotId SERIAL PRIMARY KEY,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
	NumberOfFlights INT DEFAULT 0,
	DateOfBirth DATE,
	gender VARCHAR(10) CHECK (gender IN ('Male', 'Female'))
);

ALTER TABLE Pilots
ADD CONSTRAINT CheckPilotAge
CHECK (DateOfBirth > CURRENT_DATE - INTERVAL '20 years' AND dateOfBirth < CURRENT_DATE - INTERVAL '60 years');

--Staff
CREATE TABLE Staff (
    StaffId SERIAL PRIMARY KEY,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    Age INT CHECK (age BETWEEN 20 AND 60)
);

--Flight_Pilots
CREATE TABLE Flight_Pilots (
    FlightPilotId SERIAL PRIMARY KEY,
    FlightId INT REFERENCES Flights(FlightId),
    PilotId INT REFERENCES Pilots(PilotId)
);

--Flight_Staff
CREATE TABLE Flight_Staff (
    FlightStaffId SERIAL PRIMARY KEY,
    FlightId INT REFERENCES Flights(FlightId),
    StaffId INT REFERENCES Staff(StaffId)
);

-- Tickets
CREATE TABLE Tickets (
    TicketId SERIAL PRIMARY KEY,
    Price DECIMAL(10,2) NOT NULL,
    SeatType VARCHAR(20) CHECK (SeatType IN ('A1', 'B1','C1')),
    FlightId INT REFERENCES Flights(FlightId)
);

-- Customers
CREATE TABLE Customers (
    CustomerId SERIAL PRIMARY KEY,
    FirstName VARCHAR(30) NOT NULL,
    LastName VARCHAR(30) NOT NULL
);

-- Flight_Customers
CREATE TABLE Flight_Customers (
    FlightCustomerId SERIAL PRIMARY KEY,
    FlightId INT REFERENCES Flights(FlightId),
    TicketId INT REFERENCES Tickets(TicketId),
    CustomerId INT REFERENCES Customers(CustomerId),
    UNIQUE (FlightId, TicketId, CustomerId)
);

-- Reviews
CREATE TABLE Reviews (
    ReviewId SERIAL PRIMARY KEY,
    FlightId INT REFERENCES Flights(FlightId),
  
    Rating INT CHECK (rating BETWEEN 1 AND 5),
    Comment TEXT,
	
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
