DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS listing;

DROP TABLE IF EXISTS neighbourhood_based_listing_statistics;
DROP TABLE IF EXISTS city_based_listing_statistics;
DROP TABLE IF EXISTS state_based_listing_statistics;
DROP TABLE IF EXISTS country_based_listing_statistics;

DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS neighbourhood;
DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS state;
DROP TABLE IF EXISTS country;

DROP TABLE IF EXISTS date;
DROP TABLE IF EXISTS host;
DROP TABLE IF EXISTS property;
DROP TABLE IF EXISTS reviewer;



-- all properties are not null unless otherwise specified!
-- reviewer_id, host_id is already defined

CREATE TABLE reviewer (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

CREATE TABLE date (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sqlDate DATE NOT NULL,
    day_id INT NOT NULL,
    day_number INT NOT NULL,
    month_id INT NOT NULL,
    month_name VARCHAR(50) NOT NULL,
    month_number INT NOT NULL,
    year_id INT NOT NULL,
    year_number INT NOT NULL
);

CREATE TABLE property (
    id INT PRIMARY KEY AUTO_INCREMENT,
    accommodates INT,
    bedrooms INT,
    beds INT,
    amenities TEXT, 
    room_type VARCHAR(100),
    property_type VARCHAR(100),
    bathrooms VARCHAR(100)
);

CREATE TABLE host (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    description TEXT,
    host_url VARCHAR(255),
    host_total_listings_count INT,
    is_superhost BOOLEAN,
    has_profile_pic BOOLEAN,
    has_identity_verified BOOLEAN,
    host_response_id INT,
    host_response_time VARCHAR(50),
    host_response_rate FLOAT,
    host_acceptance_rate FLOAT,
    host_verifications_id INT,
    host_verifications TEXT
);

CREATE TABLE country (
    id INT PRIMARY KEY AUTO_INCREMENT,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE state (
    id INT PRIMARY KEY AUTO_INCREMENT,
    state VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(id)
);

CREATE TABLE city (
    id INT PRIMARY KEY AUTO_INCREMENT,
    city VARCHAR(100) NOT NULL,
    state_id INT NOT NULL,
    FOREIGN KEY (state_id) REFERENCES state(id)
);

CREATE TABLE neighbourhood (
    id INT PRIMARY KEY AUTO_INCREMENT,
    neighbourhood VARCHAR(100) NOT NULL,
    city_id INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES city(id)
);

CREATE TABLE location (
    id INT PRIMARY KEY AUTO_INCREMENT,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    neighbourhood_id INT NOT NULL,
    FOREIGN KEY (neighbourhood_id) REFERENCES neighbourhood(id)
);

CREATE TABLE listing (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    host_id INT NOT NULL,
    location_id INT NOT NULL,
    price FLOAT NOT NULL,
    description TEXT,
    
    review_scores_rating INT,
    review_scores_accuracy INT,
    review_scores_cleanliness INT,
    review_scores_checkin INT,
    review_scores_communication INT,
    review_scores_location INT,
    review_scores_value INT,
    review_per_month FLOAT,

    availability_30 INT,
    availability_60 INT,
    availability_90 INT,
    availability_365 INT,
    review_count INT, -- trigger after creation review
    FOREIGN KEY (property_id) REFERENCES property(id),
    FOREIGN KEY (host_id) REFERENCES host(id),
    FOREIGN KEY (location_id) REFERENCES location(id)
);

CREATE TABLE review (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date_id INT NOT NULL,
    property_id INT NOT NULL,
    host_id INT NOT NULL,
    reviewer_id INT NOT NUll,
    review TEXT,
    listing_id INT NOT NULL,
    FOREIGN KEY (date_id) REFERENCES date(id),
    FOREIGN KEY (property_id) REFERENCES property(id),
    FOREIGN KEY (host_id) REFERENCES host(id),
    FOREIGN KEY (reviewer_id) REFERENCES reviewer(id),
    FOREIGN KEY (listing_id) REFERENCES listing(id)
);

-- Aggregations
CREATE TABLE neighbourhood_based_listing_statistics (
    neighbourhood_id INT PRIMARY KEY,
    price_min FLOAT NOT NULL,
    price_max FLOAT NOT NULL,
    price_average FLOAT NOT NULL,
    FOREIGN KEY (neighbourhood_id) REFERENCES neighbourhood(id)
);

CREATE TABLE city_based_listing_statistics (
    city_id INT PRIMARY KEY,
    price_min FLOAT NOT NULL,
    price_max FLOAT NOT NULL,
    price_average FLOAT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES city(id)
);

CREATE TABLE state_based_listing_statistics (
    state_id INT PRIMARY KEY,
    price_min FLOAT NOT NULL,
    price_max FLOAT NOT NULL,
    price_average FLOAT NOT NULL,
    FOREIGN KEY (state_id) REFERENCES state(id)
);

CREATE TABLE country_based_listing_statistics (
    country_id INT PRIMARY KEY,
    price_min FLOAT NOT NULL,
    price_max FLOAT NOT NULL,
    price_average FLOAT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(id)
);

-- Trigger to update review_count on the listing table after a review is created
DELIMITER //
CREATE TRIGGER after_review_insert
AFTER INSERT ON review
FOR EACH ROW
BEGIN
    UPDATE listing
    SET review_count = (SELECT COUNT(*) FROM review WHERE listing_id = NEW.listing_id)
    WHERE id = NEW.listing_id;
END;
//
DELIMITER ;

-- Triggers for AFTER INSERT on listing to create Aggregations
DELIMITER //
CREATE TRIGGER after_listing_insert_neighbourhood
AFTER INSERT ON listing
FOR EACH ROW
BEGIN
    DECLARE neighbourhood_id_val INT;
    DECLARE price_val FLOAT;

    SELECT l.neighbourhood_id, NEW.price
    INTO neighbourhood_id_val, price_val
    FROM location l
    WHERE l.id = NEW.location_id;

    INSERT INTO neighbourhood_based_listing_statistics (neighbourhood_id, price_min, price_max, price_average)
    VALUES (neighbourhood_id_val, price_val, price_val, price_val)
    ON DUPLICATE KEY UPDATE
        price_min = LEAST(price_val, price_min),
        price_max = GREATEST(price_val, price_max),
        price_average = (
           	SELECT AVG(l2.price)
            FROM listing l2
            WHERE l2.location_id IN (
                SELECT l3.id
                FROM location l3
                WHERE l3.neighbourhood_id = neighbourhood_id_val
            )
        );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_listing_insert_city
AFTER INSERT ON listing
FOR EACH ROW
BEGIN
    DECLARE city_id_val INT;
    DECLARE price_val FLOAT;

    SELECT neighbourhood.city_id, NEW.price
    INTO city_id_val, price_val
    FROM location JOIN neighbourhood ON location.neighbourhood_id = neighbourhood.id
    WHERE location.id = NEW.location_id;

    INSERT INTO city_based_listing_statistics (city_id, price_min, price_max, price_average)
    VALUES (city_id_val, price_val, price_val, price_val)
    ON DUPLICATE KEY UPDATE
        price_min = LEAST(price_val, price_min),
        price_max = GREATEST(price_val, price_max),
        price_average = (
            SELECT AVG(price)
            FROM listing
            WHERE location_id IN (
                SELECT location.id
                FROM location
                JOIN neighbourhood ON location.neighbourhood_id = neighbourhood.id
                WHERE neighbourhood.city_id = city_id_val
            )
        );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_listing_insert_state
AFTER INSERT ON listing
FOR EACH ROW
BEGIN
    DECLARE state_id_val INT;
    DECLARE price_val FLOAT;

    SELECT c.state_id, NEW.price
    INTO state_id_val, price_val
    FROM location l JOIN neighbourhood n ON l.neighbourhood_id = n.id
    	JOIN city c ON c.id = n.city_id
    WHERE l.id = NEW.location_id;

    INSERT INTO state_based_listing_statistics (state_id, price_min, price_max, price_average)
    VALUES (state_id_val, price_val, price_val, price_val)
    ON DUPLICATE KEY UPDATE
        price_min = LEAST(price_val, price_min),
        price_max = GREATEST(price_val, price_max),
        price_average = (
            SELECT AVG(price)
            FROM listing
            WHERE location_id IN (
                SELECT l.id
                FROM location l JOIN neighbourhood n ON l.neighbourhood_id = n.id
    				JOIN city c ON c.id = n.city_id
                WHERE c.state_id = state_id_val
            )
        );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_listing_insert_country
AFTER INSERT ON listing
FOR EACH ROW
BEGIN
    DECLARE country_id_val INT;
    DECLARE price_val FLOAT;

    SELECT s.country_id, NEW.price
    INTO country_id_val, price_val
    FROM location l JOIN neighbourhood n ON l.neighbourhood_id = n.id
    	JOIN city c ON c.id = n.city_id
    	JOIN state s ON s.id = c.state_id
    WHERE l.id = NEW.location_id;

    INSERT INTO country_based_listing_statistics (country_id, price_min, price_max, price_average)
    VALUES (country_id_val, price_val, price_val, price_val)
    ON DUPLICATE KEY UPDATE
        price_min = LEAST(price_val, price_min),
        price_max = GREATEST(price_val, price_max),
        price_average = (
            SELECT AVG(price)
            FROM listing
            WHERE location_id IN (
                SELECT l.id
                FROM location l JOIN neighbourhood n ON l.neighbourhood_id = n.id
    				JOIN city c ON c.id = n.city_id
    				JOIN state s ON s.id = c.state_id
                WHERE s.country_id = country_id_val
            )
        );
END;
//
DELIMITER ;

-- Triggers for AFTER UPDATE on listing to update Aggregations
DELIMITER //
CREATE TRIGGER after_listing_update_neighbourhood
AFTER UPDATE ON listing
FOR EACH ROW
BEGIN
    DECLARE neighbourhood_id_val INT;
    DECLARE price_val FLOAT;

    SELECT l.neighbourhood_id, NEW.price
    INTO neighbourhood_id_val, price_val
    FROM location l
    WHERE l.id = NEW.location_id;

    INSERT INTO neighbourhood_based_listing_statistics (neighbourhood_id, price_min, price_max, price_average)
    VALUES (neighbourhood_id_val, price_val, price_val, price_val)
    ON DUPLICATE KEY UPDATE
        price_min = LEAST(price_val, price_min),
        price_max = GREATEST(price_val, price_max),
        price_average = (
           	SELECT AVG(l2.price)
            FROM listing l2
            WHERE l2.location_id IN (
                SELECT l3.id
                FROM location l3
                WHERE l3.neighbourhood_id = neighbourhood_id_val
            )
        );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_listing_update_city
AFTER UPDATE ON listing
FOR EACH ROW
BEGIN
    DECLARE city_id_val INT;
    DECLARE price_val FLOAT;

    SELECT neighbourhood.city_id, NEW.price
    INTO city_id_val, price_val
    FROM location JOIN neighbourhood ON location.neighbourhood_id = neighbourhood.id
    WHERE location.id = NEW.location_id;

    INSERT INTO city_based_listing_statistics (city_id, price_min, price_max, price_average)
    VALUES (city_id_val, price_val, price_val, price_val)
    ON DUPLICATE KEY UPDATE
        price_min = LEAST(price_val, price_min),
        price_max = GREATEST(price_val, price_max),
        price_average = (
            SELECT AVG(price)
            FROM listing
            WHERE location_id IN (
                SELECT location.id
                FROM location
                JOIN neighbourhood ON location.neighbourhood_id = neighbourhood.id
                WHERE neighbourhood.city_id = city_id_val
            )
        );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_listing_update_state
AFTER UPDATE ON listing
FOR EACH ROW
BEGIN
    DECLARE state_id_val INT;
    DECLARE price_val FLOAT;

    SELECT c.state_id, NEW.price
    INTO state_id_val, price_val
    FROM location l JOIN neighbourhood n ON l.neighbourhood_id = n.id
    	JOIN city c ON c.id = n.city_id
    WHERE l.id = NEW.location_id;

    INSERT INTO state_based_listing_statistics (state_id, price_min, price_max, price_average)
    VALUES (state_id_val, price_val, price_val, price_val)
    ON DUPLICATE KEY UPDATE
        price_min = LEAST(price_val, price_min),
        price_max = GREATEST(price_val, price_max),
        price_average = (
            SELECT AVG(price)
            FROM listing
            WHERE location_id IN (
                SELECT l.id
                FROM location l JOIN neighbourhood n ON l.neighbourhood_id = n.id
    				JOIN city c ON c.id = n.city_id
                WHERE c.state_id = state_id_val
            )
        );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_listing_update_country
AFTER UPDATE ON listing
FOR EACH ROW
BEGIN
    DECLARE country_id_val INT;
    DECLARE price_val FLOAT;

    SELECT s.country_id, NEW.price
    INTO country_id_val, price_val
    FROM location l JOIN neighbourhood n ON l.neighbourhood_id = n.id
    	JOIN city c ON c.id = n.city_id
    	JOIN state s ON s.id = c.state_id
    WHERE l.id = NEW.location_id;

    INSERT INTO country_based_listing_statistics (country_id, price_min, price_max, price_average)
    VALUES (country_id_val, price_val, price_val, price_val)
    ON DUPLICATE KEY UPDATE
        price_min = LEAST(price_val, price_min),
        price_max = GREATEST(price_val, price_max),
        price_average = (
            SELECT AVG(price)
            FROM listing
            WHERE location_id IN (
                SELECT l.id
                FROM location l JOIN neighbourhood n ON l.neighbourhood_id = n.id
    				JOIN city c ON c.id = n.city_id
    				JOIN state s ON s.id = c.state_id
                WHERE s.country_id = country_id_val
            )
        );
END;
//
DELIMITER ;