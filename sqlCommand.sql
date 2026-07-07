-- Create the new Voucher Requests table
CREATE TABLE VoucherRequests (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INT,
    reason VARCHAR(500) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING'
);

-- 1. Create Staff Table
CREATE TABLE Staff (
    staff_id VARCHAR(50) PRIMARY KEY,
    role VARCHAR(20) NOT NULL, -- 'STAFF' or 'ADMIN'
    password VARCHAR(50) NOT NULL
);

-- 2. Create Donors Table
CREATE TABLE Donors (
    email VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_num VARCHAR(20),
    password VARCHAR(50) NOT NULL
);

-- 3. Create Students Table
CREATE TABLE Students (
    student_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_num VARCHAR(20),
    password VARCHAR(50) NOT NULL
);

-- 4. Recreate Voucher Requests linking to Student ID
CREATE TABLE VoucherRequests (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    student_id VARCHAR(50),
    reason VARCHAR(500) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING'
);

-- Insert a default Admin so you don't get locked out!
INSERT INTO Staff (staff_id, role, password) VALUES ('admin01', 'ADMIN', 'admin123');