-- =====================================================
-- University Accommodation Management System (MySQL)
-- File name : university_accommodation.sql
-- =====================================================

DROP DATABASE IF EXISTS university_accommodation;
CREATE DATABASE university_accommodation;
USE university_accommodation;

-- ---------------------- TABLES -----------------------

CREATE TABLE student (
    StudentID   INT PRIMARY KEY AUTO_INCREMENT,
    FirstName   VARCHAR(50) NOT NULL,
    LastName    VARCHAR(50) NOT NULL,
    Email       VARCHAR(100) NOT NULL UNIQUE,
    Phone       VARCHAR(20),
    Programme   VARCHAR(100),
    YearOfStudy INT
);

CREATE TABLE residence (
    ResidenceID   INT PRIMARY KEY AUTO_INCREMENT,
    ResidenceName VARCHAR(100) NOT NULL,
    Location      VARCHAR(100),
    GenderPolicy  VARCHAR(20),
    TotalCapacity INT
);

CREATE TABLE room (
    RoomID      INT PRIMARY KEY AUTO_INCREMENT,
    ResidenceID INT NOT NULL,
    RoomNumber  VARCHAR(10) NOT NULL,
    RoomType    VARCHAR(20),
    Capacity    INT NOT NULL,
    Status      VARCHAR(20) DEFAULT 'Available',
    FOREIGN KEY (ResidenceID) REFERENCES residence(ResidenceID)
);

CREATE TABLE academic_period (
    PeriodID     INT PRIMARY KEY AUTO_INCREMENT,
    AcademicYear INT NOT NULL,
    Semester     INT NOT NULL,
    StartDate    DATE,
    EndDate      DATE
);

CREATE TABLE application (
    ApplicationID   INT PRIMARY KEY AUTO_INCREMENT,
    StudentID       INT NOT NULL,
    PeriodID        INT NOT NULL,
    ApplicationDate DATE,
    Status          VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (StudentID) REFERENCES student(StudentID),
    FOREIGN KEY (PeriodID)  REFERENCES academic_period(PeriodID)
);

-- ALLOCATION is the bridge table between STUDENT and ROOM (many-to-many)
CREATE TABLE allocation (
    AllocationID  INT PRIMARY KEY AUTO_INCREMENT,
    StudentID     INT NOT NULL,
    RoomID        INT NOT NULL,
    ApplicationID INT NOT NULL UNIQUE,
    StartDate     DATE,
    EndDate       DATE,
    Status        VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (StudentID)     REFERENCES student(StudentID),
    FOREIGN KEY (RoomID)        REFERENCES room(RoomID),
    FOREIGN KEY (ApplicationID) REFERENCES application(ApplicationID)
);

CREATE TABLE payment (
    PaymentID     INT PRIMARY KEY AUTO_INCREMENT,
    StudentID     INT NOT NULL,
    PaymentDate   DATE,
    Amount        DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(20),
    Status        VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (StudentID) REFERENCES student(StudentID)
);

CREATE TABLE staff (
    StaffID     INT PRIMARY KEY AUTO_INCREMENT,
    ResidenceID INT NOT NULL,
    FirstName   VARCHAR(50) NOT NULL,
    LastName    VARCHAR(50) NOT NULL,
    Email       VARCHAR(100) UNIQUE,
    Role        VARCHAR(50),
    FOREIGN KEY (ResidenceID) REFERENCES residence(ResidenceID)
);

CREATE TABLE maintenance_request (
    RequestID   INT PRIMARY KEY AUTO_INCREMENT,
    RoomID      INT NOT NULL,
    StudentID   INT NOT NULL,
    StaffID     INT,
    RequestDate DATE,
    Description VARCHAR(255),
    Priority    VARCHAR(10),
    Status      VARCHAR(20) DEFAULT 'Open',
    FOREIGN KEY (RoomID)    REFERENCES room(RoomID),
    FOREIGN KEY (StudentID) REFERENCES student(StudentID),
    FOREIGN KEY (StaffID)   REFERENCES staff(StaffID)
);

-- ---------------------- DATA -------------------------

INSERT INTO student VALUES
(1,  'Thabo',   'Mokoena',  'thabo@uni.ac.za',   '0711110001', 'Computer Science',    2),
(2,  'Aisha',   'Davids',   'aisha@uni.ac.za',   '0711110002', 'Information Systems', 1),
(3,  'Lerato',  'Khumalo',  'lerato@uni.ac.za',  '0711110003', 'Engineering',         3),
(4,  'Sipho',   'Ndlovu',   'sipho@uni.ac.za',   '0711110004', 'Computer Science',    3),
(5,  'Naledi',  'Jacobs',   'naledi@uni.ac.za',  '0711110005', 'Law',                 2),
(6,  'Pieter',  'van Wyk',  'pieter@uni.ac.za',  '0711110006', 'Commerce',            1),
(7,  'Zanele',  'Dlamini',  'zanele@uni.ac.za',  '0711110007', 'Computer Science',    2),
(8,  'Michael', 'Adams',    'michael@uni.ac.za', '0711110008', 'Natural Sciences',    4),
(9,  'Nomsa',   'Zulu',     'nomsa@uni.ac.za',   '0711110009', 'Health Sciences',     1),
(10, 'Ryan',    'Petersen', 'ryan@uni.ac.za',    '0711110010', 'Engineering',         2),
(11, 'Fatima',  'Hendricks','fatima.h@uni.ac.za','0711110011', 'Education',           3),
(12, 'Kyle',    'Brown',    'kyle@uni.ac.za',    '0711110012', 'Commerce',            1);

INSERT INTO residence VALUES
(1, 'Protea Residence',     'North Campus', 'Female', 5),
(2, 'Fynbos Residence',     'South Campus', 'Male',   6),
(3, 'Silvertree Residence', 'Main Campus',  'Mixed',  6);

INSERT INTO room VALUES
(1,  1, '101', 'Single', 1, 'Available'),
(2,  1, '102', 'Double', 2, 'Available'),
(3,  1, '103', 'Double', 2, 'Available'),
(4,  2, '201', 'Single', 1, 'Available'),
(5,  2, '202', 'Double', 2, 'Available'),
(6,  2, '203', 'Triple', 3, 'Available'),
(7,  3, '301', 'Single', 1, 'Available'),
(8,  3, '302', 'Double', 2, 'Available'),
(9,  3, '303', 'Double', 2, 'Available'),
(10, 3, '304', 'Single', 1, 'Under Maintenance');

INSERT INTO academic_period VALUES
(1, 2025, 1, '2025-02-03', '2025-06-27'),
(2, 2025, 2, '2025-07-14', '2025-11-28'),
(3, 2026, 1, '2026-02-02', '2026-06-26'),
(4, 2026, 2, '2026-07-13', '2026-11-27');

INSERT INTO application VALUES
(1,  1,  2, '2025-06-20', 'Approved'),
(2,  2,  2, '2025-06-21', 'Approved'),
(3,  3,  2, '2025-06-22', 'Approved'),
(4,  7,  2, '2025-06-23', 'Rejected'),
(5,  1,  3, '2026-01-10', 'Approved'),
(6,  2,  3, '2026-01-11', 'Approved'),
(7,  3,  3, '2026-01-12', 'Approved'),
(8,  4,  3, '2026-01-12', 'Approved'),
(9,  5,  3, '2026-01-13', 'Approved'),
(10, 6,  3, '2026-01-14', 'Approved'),
(11, 7,  3, '2026-01-15', 'Approved'),
(12, 8,  3, '2026-01-15', 'Approved'),
(13, 9,  3, '2026-01-18', 'Waitlisted'),
(14, 10, 3, '2026-01-16', 'Approved'),
(15, 11, 3, '2026-01-17', 'Rejected'),
(16, 12, 3, '2026-01-19', 'Pending'),
(17, 1,  4, '2026-06-05', 'Pending'),
(18, 4,  4, '2026-06-06', 'Pending'),
(19, 9,  4, '2026-06-07', 'Pending');

INSERT INTO allocation VALUES
(1,  1,  4, 1,  '2025-07-15', '2025-11-30', 'Completed'),
(2,  2,  1, 2,  '2025-07-15', '2025-11-30', 'Completed'),
(3,  3,  2, 3,  '2025-07-15', '2025-11-30', 'Completed'),
(4,  1,  5, 5,  '2026-02-01', '2026-06-30', 'Active'),
(5,  4,  5, 8,  '2026-02-01', '2026-06-30', 'Active'),
(6,  2,  1, 6,  '2026-02-01', '2026-06-30', 'Active'),
(7,  3,  2, 7,  '2026-02-01', '2026-06-30', 'Active'),
(8,  5,  2, 9,  '2026-02-01', '2026-06-30', 'Active'),
(9,  6,  7, 10, '2026-02-01', '2026-06-30', 'Active'),
(10, 7,  8, 11, '2026-02-01', '2026-06-30', 'Active'),
(11, 8,  6, 12, '2026-02-01', '2026-06-30', 'Active'),
(12, 10, 6, 14, '2026-02-01', '2026-06-30', 'Active');

INSERT INTO payment VALUES
(1,  1,  '2025-07-10',  9000.00, 'EFT',  'Paid'),
(2,  2,  '2025-07-12', 12000.00, 'EFT',  'Paid'),
(3,  3,  '2025-07-14',  6000.00, 'Card', 'Paid'),
(4,  1,  '2026-01-25',  8500.00, 'EFT',  'Paid'),
(5,  1,  '2026-03-01',  8500.00, 'Card', 'Paid'),
(6,  2,  '2026-01-28', 12000.00, 'EFT',  'Paid'),
(7,  3,  '2026-02-02',  6000.00, 'Card', 'Paid'),
(8,  3,  '2026-03-02',  6000.00, 'Card', 'Pending'),
(9,  4,  '2026-02-03',  8500.00, 'Cash', 'Paid'),
(10, 4,  '2026-03-03',  8500.00, 'Cash', 'Overdue'),
(11, 5,  '2026-02-01',  6000.00, 'EFT',  'Refunded'),
(12, 6,  '2026-02-05', 11000.00, 'EFT',  'Paid'),
(13, 7,  '2026-02-06',  7000.00, 'Card', 'Paid'),
(14, 7,  '2026-03-06',  7000.00, 'Card', 'Pending'),
(15, 8,  '2026-02-04',  5000.00, 'Card', 'Paid'),
(16, 8,  '2026-03-04',  5000.00, 'Card', 'Overdue'),
(17, 10, '2026-02-06',  5000.00, 'EFT',  'Paid'),
(18, 10, '2026-03-06',  5000.00, 'EFT',  'Paid');

INSERT INTO staff VALUES
(1, 1, 'Nokuthula', 'Mthembu', 'nokuthula@uni.ac.za', 'Residence Manager'),
(2, 2, 'Johan',     'Botha',   'johan@uni.ac.za',     'Residence Manager'),
(3, 1, 'Fatima',    'Salie',   'fatima@uni.ac.za',    'Maintenance Officer'),
(4, 2, 'Sam',       'Naidoo',  'sam@uni.ac.za',       'Maintenance Officer'),
(5, 3, 'Grace',     'Mensah',  'grace@uni.ac.za',     'Residence Manager'),
(6, 3, 'Bongani',   'Cele',    'bongani@uni.ac.za',   'Maintenance Officer'),
(7, 2, 'Priya',     'Pillay',  'priya@uni.ac.za',     'Maintenance Officer');

INSERT INTO maintenance_request VALUES
(1,  5, 1,  4,    '2026-02-15', 'Leaking tap',            'High',   'Resolved'),
(2,  2, 3,  3,    '2026-03-10', 'Broken window latch',    'Medium', 'In Progress'),
(3,  7, 6,  6,    '2026-03-12', 'Faulty ceiling light',   'Low',    'Resolved'),
(4,  6, 8,  4,    '2026-04-02', 'Heater not working',     'High',   'In Progress'),
(5,  6, 10, NULL, '2026-04-05', 'Heater not working',     'High',   'Open'),
(6,  1, 2,  3,    '2026-04-20', 'Door lock stuck',        'High',   'Resolved'),
(7,  5, 4,  4,    '2026-05-03', 'Mould on wall',          'Medium', 'Open'),
(8,  8, 7,  6,    '2026-05-10', 'Ceiling leak',           'High',   'In Progress'),
(9,  8, 7,  6,    '2026-05-18', 'Blocked drain',          'Medium', 'Open'),
(10, 2, 5,  3,    '2026-05-20', 'Broken desk chair',      'Low',    'Resolved'),
(11, 1, 2,  3,    '2026-06-01', 'Faulty power socket',    'Low',    'Closed');

-- ---------------------- QUERIES ----------------------

-- Q1: Number of rooms and total room capacity per residence
-- (shows how much space each residence offers)
SELECT r.ResidenceName,
       COUNT(rm.RoomID)  AS NumberOfRooms,
       SUM(rm.Capacity)  AS TotalBeds
FROM residence r
INNER JOIN room rm ON r.ResidenceID = rm.ResidenceID
GROUP BY r.ResidenceName;

-- Q2: Applications per period and status
-- (shows demand and how many applications are approved)
SELECT CONCAT(p.AcademicYear, ' Semester ', p.Semester) AS Period,
       a.Status,
       COUNT(a.ApplicationID) AS TotalApplications
FROM academic_period p
INNER JOIN application a ON p.PeriodID = a.PeriodID
GROUP BY p.AcademicYear, p.Semester, a.Status;

-- Q3: Unpaid fees per student
-- (finance office can follow up on students who owe money)
SELECT CONCAT(s.FirstName, ' ', s.LastName) AS Student,
       COUNT(py.PaymentID) AS UnpaidPayments,
       SUM(py.Amount)      AS AmountOwed
FROM student s
INNER JOIN payment py ON s.StudentID = py.StudentID
WHERE py.Status IN ('Pending', 'Overdue')
GROUP BY s.StudentID, s.FirstName, s.LastName;

-- Q4: Students who paid more than the average paid amount
-- (subquery in the WHERE clause)
SELECT CONCAT(s.FirstName, ' ', s.LastName) AS Student,
       py.Amount, py.PaymentDate
FROM student s
INNER JOIN payment py ON s.StudentID = py.StudentID
WHERE py.Status = 'Paid'
  AND py.Amount > (SELECT AVG(Amount) FROM payment WHERE Status = 'Paid');

-- Q5: Students who have no room allocation
-- (shows who still needs accommodation)
SELECT CONCAT(s.FirstName, ' ', s.LastName) AS Student,
       s.Programme
FROM student s
LEFT JOIN allocation al ON s.StudentID = al.StudentID
WHERE al.AllocationID IS NULL;

-- Q6: Maintenance requests per residence and priority
-- (helps plan where maintenance staff are needed)
SELECT r.ResidenceName,
       mr.Priority,
       COUNT(mr.RequestID) AS Requests
FROM maintenance_request mr
INNER JOIN room rm ON mr.RoomID = rm.RoomID
INNER JOIN residence r ON rm.ResidenceID = r.ResidenceID
GROUP BY r.ResidenceName, mr.Priority;

-- Q7: Workload of maintenance staff (including staff with no requests)
SELECT CONCAT(st.FirstName, ' ', st.LastName) AS StaffMember,
       st.Role,
       COUNT(mr.RequestID) AS RequestsHandled
FROM staff st
LEFT JOIN maintenance_request mr ON st.StaffID = mr.StaffID
WHERE st.Role LIKE '%Maintenance%'
GROUP BY st.StaffID, st.FirstName, st.LastName, st.Role;

-- Q8 (complex): Students living in rooms that have unresolved
-- maintenance requests and who have paid more than R5000 in total
SELECT CONCAT(s.FirstName, ' ', s.LastName) AS Student,
       r.ResidenceName,
       rm.RoomNumber,
       SUM(py.Amount) AS TotalPaid
FROM student s
INNER JOIN allocation al ON s.StudentID = al.StudentID
INNER JOIN room rm       ON al.RoomID = rm.RoomID
INNER JOIN residence r   ON rm.ResidenceID = r.ResidenceID
INNER JOIN payment py    ON s.StudentID = py.StudentID
WHERE py.Status = 'Paid'
  AND rm.RoomID IN (SELECT RoomID
                    FROM maintenance_request
                    WHERE Status IN ('Open', 'In Progress'))
GROUP BY s.StudentID, s.FirstName, s.LastName, r.ResidenceName, rm.RoomNumber
HAVING SUM(py.Amount) > 5000;


SELECT *
FROM student;

