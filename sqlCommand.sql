
-- db name: FoodbankDB
--usename: app
--password: app

-- 1. DROP TABLES (In reverse order to avoid dependency errors)
-- This clears everything so they can start fresh without errors
DROP TABLE VoucherRequests;
DROP TABLE Inventory;
DROP TABLE Students;
DROP TABLE Donors;
DROP TABLE Staff;

-- 2. CREATE TABLES

-- Staff Table
CREATE TABLE Staff (
    staff_id VARCHAR(50) PRIMARY KEY,
    role VARCHAR(20) NOT NULL, -- STAFF or ADMIN
    password VARCHAR(50) NOT NULL
);

-- Donors Table
CREATE TABLE Donors (
    email VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_num VARCHAR(20),
    password VARCHAR(50) NOT NULL
);

-- Students Table
CREATE TABLE Students (
    student_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_num VARCHAR(20),
    password VARCHAR(50) NOT NULL
);

-- Inventory Table (Linked to Donors)
CREATE TABLE Inventory (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    donor_email VARCHAR(100),
    CONSTRAINT fk_donor FOREIGN KEY (donor_email) REFERENCES Donors(email) ON DELETE SET NULL
);

-- VoucherRequests Table (Linked to Students)
CREATE TABLE VoucherRequests (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    student_id VARCHAR(50),
    reason VARCHAR(500) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE
);

-- 3. INSERT DEFAULT ADMIN
-- This ensures there is always one account to log in with
INSERT INTO Staff (staff_id, role, password) VALUES ('admin01', 'ADMIN', 'admin123');