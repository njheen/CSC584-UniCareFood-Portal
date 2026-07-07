CREATE TABLE Users (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL -- 'DONOR' or 'STAFF'
);

CREATE TABLE Inventory (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity INT NOT NULL
);

-- Add new columns to the existing Users table
ALTER TABLE Users ADD COLUMN full_name VARCHAR(100);
ALTER TABLE Users ADD COLUMN student_id VARCHAR(50);
ALTER TABLE Users ADD COLUMN email VARCHAR(100);
ALTER TABLE Users ADD COLUMN phone VARCHAR(20);

-- Create the new Voucher Requests table
CREATE TABLE VoucherRequests (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INT,
    reason VARCHAR(500) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING'
);