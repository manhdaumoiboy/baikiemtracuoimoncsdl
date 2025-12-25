    BEGIN;

    -- 1. CLEANUP
    DROP TABLE IF EXISTS Payment CASCADE;
    DROP TABLE IF EXISTS Booking CASCADE;
    DROP TABLE IF EXISTS Room CASCADE;
    DROP TABLE IF EXISTS Customer CASCADE;
    DROP VIEW IF EXISTS view_early_bookings;
    DROP VIEW IF EXISTS view_large_rooms;
    DROP PROCEDURE IF EXISTS sp_add_customer;
    DROP PROCEDURE IF EXISTS sp_add_payment;
    DROP FUNCTION IF EXISTS func_check_booking_dates CASCADE;

    -- 2. TABLES & CONSTRAINTS
    CREATE TABLE Customer (
                              customer_id VARCHAR(10) PRIMARY KEY,
                              customer_fullname VARCHAR(100) NOT NULL,
                              customer_email VARCHAR(100) NOT NULL UNIQUE CHECK (customer_email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
                              customer_phone VARCHAR(15) NOT NULL,
                              customer_address VARCHAR(255) NOT NULL
    );

    CREATE TABLE Room (
                          room_id VARCHAR(10) PRIMARY KEY,
                          room_type VARCHAR(50) NOT NULL,
                          room_price DECIMAL(10, 2) NOT NULL CHECK (room_price > 0),
                          room_status VARCHAR(20) NOT NULL DEFAULT 'Available',
                          room_area INT CHECK (room_area > 0)
    );

    CREATE TABLE Booking (
                             booking_id SERIAL PRIMARY KEY,
                             customer_id VARCHAR(10) NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE,
                             room_id VARCHAR(10) NOT NULL REFERENCES Room(room_id) ON DELETE CASCADE,
                             check_in_date DATE NOT NULL,
                             check_out_date DATE NOT NULL,
                             total_amount DECIMAL(10, 2) DEFAULT 0 CHECK (total_amount >= 0),
                             CONSTRAINT chk_date_logic CHECK (check_out_date > check_in_date)
    );

    CREATE TABLE Payment (
                             payment_id SERIAL PRIMARY KEY,
                             booking_id INT NOT NULL REFERENCES Booking(booking_id) ON DELETE CASCADE,
                             payment_method VARCHAR(50) NOT NULL,
                             payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
                             payment_amount DECIMAL(10, 2) NOT NULL CHECK (payment_amount > 0)
    );

    -- 3. INDEXING (OPTIMIZATION)
    CREATE INDEX idx_booking_customer ON Booking(customer_id);
    CREATE INDEX idx_booking_room ON Booking(room_id);
    CREATE INDEX idx_payment_booking ON Payment(booking_id);
    CREATE INDEX idx_customer_search ON Customer(customer_fullname);

    -- 4. SEED DATA
    INSERT INTO Customer(customer_id, customer_fullname, customer_email, customer_phone, customer_address) VALUES
                                                                                                               ('C001', 'Nguyen Van Tu', 'tu.nguyen@example.com', '0912345678', 'Hanoi, Vietnam'),
                                                                                                               ('C002', 'Tran Thi Mai', 'mai.tran@example.com', '0923456789', 'Ho Chi Minh, Vietnam'),
                                                                                                               ('C003', 'Le Minh Hoang', 'hoang.le@example.com', '0934567890', 'Danang, Vietnam'),
                                                                                                               ('C004', 'Pham Hoang Nam', 'nam.pham@example.com', '0945678901', 'Hue, Vietnam'),
                                                                                                               ('C005', 'Vu Minh Thu', 'thu.vu@example.com', '0956789012', 'Hai Phong, Vietnam');

    INSERT INTO Room(room_id, room_type, room_price, room_status, room_area) VALUES
                                                                                 ('R001', 'Single', 100.0, 'Available', 25),
                                                                                 ('R002', 'Double', 150.0, 'Booked', 40),
                                                                                 ('R003', 'Suite', 250.0, 'Available', 60),
                                                                                 ('R004', 'Single', 120.0, 'Booked', 30),
                                                                                 ('R005', 'Double', 160.0, 'Available', 35);

    INSERT INTO Booking(customer_id, room_id, check_in_date, check_out_date, total_amount) VALUES
                                                                                               ('C001', 'R001', '2025-03-01', '2025-03-05', 400.0),
                                                                                               ('C002', 'R002', '2025-03-02', '2025-03-06', 600.0),
                                                                                               ('C003', 'R003', '2025-03-03', '2025-03-07', 1000.0),
                                                                                               ('C004', 'R004', '2025-03-04', '2025-03-08', 480.0),
                                                                                               ('C005', 'R005', '2025-03-05', '2025-03-09', 800.0);

    INSERT INTO Payment(booking_id, payment_method, payment_date, payment_amount) VALUES
                                                                                      (1, 'Cash', '2025-03-05', 400.0),
                                                                                      (2, 'Credit Card', '2025-03-06', 600.0),
                                                                                      (3, 'Bank Transfer', '2025-03-07', 1000.0),
                                                                                      (4, 'Cash', '2025-03-08', 480.0),
                                                                                      (5, 'Credit Card', '2025-03-09', 800.0);

    -- 5. QUERIES
    SELECT c.customer_fullname, b.room_id, b.check_in_date, b.check_out_date
    FROM Customer c
             JOIN Booking b ON c.customer_id = b.customer_id;

    SELECT c.customer_id, c.customer_fullname, p.payment_method, p.payment_amount
    FROM Customer c
             JOIN Booking b ON c.customer_id = b.customer_id
             JOIN Payment p ON b.booking_id = p.booking_id
    ORDER BY p.payment_amount DESC;

    UPDATE Booking SET total_amount = total_amount * 0.9 WHERE check_in_date < '2025-03-03';

    DELETE FROM Payment WHERE payment_method = 'Cash' AND payment_amount < 500;

    SELECT * FROM Customer ORDER BY customer_fullname DESC LIMIT 3 OFFSET 1;

    SELECT c.customer_id, c.customer_fullname, COUNT(b.room_id)
    FROM Customer c
             JOIN Booking b ON c.customer_id = b.customer_id
    GROUP BY c.customer_id, c.customer_fullname
    HAVING COUNT(b.room_id) >= 2;

    SELECT customer_id, customer_fullname, customer_email, customer_phone
    FROM Customer
    WHERE customer_fullname ILIKE '%minh%' OR customer_address ILIKE '%Hanoi%';

    SELECT c.customer_id, c.customer_fullname, b.room_id, SUM(p.payment_amount)
    FROM Customer c
             JOIN Booking b ON c.customer_id = b.customer_id
             JOIN Payment p ON b.booking_id = p.booking_id
    GROUP BY c.customer_id, c.customer_fullname, b.room_id
    HAVING SUM(p.payment_amount) > 1000;

    SELECT r.room_id, r.room_type, r.room_price, COUNT(DISTINCT b.customer_id)
    FROM Booking b
             JOIN Room r ON b.room_id = r.room_id
    GROUP BY r.room_id, r.room_type, r.room_price
    HAVING COUNT(DISTINCT b.customer_id) >= 3;

    -- 6. VIEWS
    CREATE VIEW view_early_bookings AS
    SELECT r.room_id, r.room_type, c.customer_id, c.customer_fullname, b.check_in_date
    FROM Customer c
             JOIN Booking b ON c.customer_id = b.customer_id
             JOIN Room r ON b.room_id = r.room_id
    WHERE b.check_in_date <= '2025-03-04';

    CREATE VIEW view_large_rooms AS
    SELECT c.customer_id, c.customer_fullname, r.room_id, r.room_area, b.check_out_date
    FROM Customer c
             JOIN Booking b ON c.customer_id = b.customer_id
             JOIN Room r ON b.room_id = r.room_id
    WHERE r.room_area > 30;

    -- 7. PROCEDURES
    CREATE OR REPLACE PROCEDURE sp_add_customer(
        p_id VARCHAR(10), p_name VARCHAR(100), p_email VARCHAR(100), p_phone VARCHAR(15), p_address VARCHAR(255)
    ) LANGUAGE plpgsql AS $$
    BEGIN
        INSERT INTO Customer(customer_id, customer_fullname, customer_email, customer_phone, customer_address)
        VALUES (p_id, p_name, p_email, p_phone, p_address);
    END;
    $$;

    CALL sp_add_customer('C006', 'Hoang Thi Lan', 'lan.hoang@example.com', '0967890123', 'Can Tho, Vietnam');

    CREATE OR REPLACE PROCEDURE sp_add_payment(
        p_booking_id INT, p_method VARCHAR(50), p_date DATE, p_amount DECIMAL(10,2)
    ) LANGUAGE plpgsql AS $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Booking WHERE booking_id = p_booking_id) THEN
            RAISE EXCEPTION 'Booking ID % does not exist', p_booking_id;
        END IF;
        INSERT INTO Payment(booking_id, payment_method, payment_date, payment_amount)
        VALUES (p_booking_id, p_method, p_date, p_amount);
    END;
    $$;

    -- 8. TRIGGER
    CREATE OR REPLACE FUNCTION func_check_booking_dates()
        RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.check_in_date >= NEW.check_out_date THEN
            RAISE EXCEPTION 'Check-in date must be before Check-out date';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER trg_check_booking_dates
        BEFORE INSERT OR UPDATE ON Booking
        FOR EACH ROW
    EXECUTE FUNCTION func_check_booking_dates();

    COMMIT;