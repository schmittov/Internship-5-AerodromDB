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
ALTER TABLE Airports
ADD COLUMN CityID INT REFERENCES Cities(CityId);
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
CREATE TABLE LoyalityCards(
	LoyalityCardId SERIAL PRIMARY KEY,
	CustomerId INT REFERENCES Customers(CustomerId),
	RegisterTime DATE
)
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


--queries
--ispis imena i modela svih aviona s kapacitetom većim od 100
SELECT AirplaneName, Model
FROM Airplanes
WHERE capacity > 100;

--Ispis svih karata čija je cijena između 100 i 200 eura
SELECT *
FROM Tickets
WHERE Price BETWEEN 100 AND 200;

--Ispis svih pilotkinja s više od 20 odrađenih letova do danas
SELECT *
FROM Pilots
WHERE (Pilots.Gender='Female' AND NumberOfFlights>20)

--ispis broja letova u Split/iz Splita 2023. godine
SELECT COUNT(*)
FROM Flights
WHERE (Flights.DepartureCityId=(SELECT CityId FROM Cities WHERE CityName = 'Split') AND EXTRACT(YEAR FROM StartTime) = 2023);

--spis svih letova za Beč u prosincu 2023.
SELECT *
FROM Flights
WHERE (Flights.DestinationCityId=(SELECT CityId FROM Cities WHERE CityName = 'Beč') AND EXTRACT(YEAR FROM StartTime) = 2023 AND EXTRACT(MONTH FROM StartTime) = 12);

--ispis broj prodanih Economy letova kompanije AirDUMP u 2021.
SELECT COUNT(*) AS NumberOfSoldEconomyTickets
FROM Tickets
JOIN Flights ON Tickets.FlightId = Flights.FlightId
JOIN Companies ON Flights.CompanyId = Companies.CompanyId
WHERE (Companies.CompanyName = 'AirDUMP' AND EXTRACT(YEAR FROM Flights.StartTime) = 2021 AND Tickets.SeatType = 'B1');

--ispis prosječne ocjene letova kompanije AirDUMP
SELECT AVG(Reviews.Rating) AS AverageGrade
FROM Reviews
JOIN Flights ON Reviews.FlightId = Flights.FlightId
JOIN Companies ON Flights.CompanyId = Companies.CompanyId
WHERE (Companies.CompanyName = 'AirDUMP');

--ispis svih aerodroma udaljenih od Splita manje od 1500km
SELECT Airports.AirportName
FROM Airports
JOIN Cities ON Cities.CityID = Airports.CityID
WHERE (Cities.DistanceFromSplit<1500);

--razmontirajte avione starije od 20 godina koji nemaju letove pred sobom
UPDATE Airplanes
SET Status = 'Dijelovi'
WHERE ManufactureDate < CURRENT_DATE - INTERVAL '20 years'
    AND AirplaneId NOT IN (
        SELECT DISTINCT AirplaneId
        FROM Flights
        WHERE StartTime > CURRENT_TIMESTAMP
    );
	
--izbrišite sve letove koji nemaju ni jednu prodanu kartu
DELETE FROM Flights
WHERE FlightId NOT IN 
(
    SELECT DISTINCT F.FlightId
    FROM Flights f
    JOIN Tickets t ON F.FlightId = T.FlightId
);

--izbrišite sve kartice vjernosti putnika čije prezime završava na -ov/a, -in/a (diskriminešn)
DELETE FROM LoyalityCards
WHERE CustomerId IN (
    SELECT CustomerId
    FROM Customers
    WHERE LastName LIKE '%ov' OR LastName LIKE '%in' OR LastName LIKE '%ina' OR LastName LIKE '%ova'
);