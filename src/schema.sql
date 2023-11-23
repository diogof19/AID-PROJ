DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS listing;
DROP TABLE IF EXISTS availability;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS neighborhood;
DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS state;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS host;
DROP TABLE IF EXISTS host_verifications;
DROP TABLE IF EXISTS host_response;
DROP TABLE IF EXISTS property;
DROP TABLE IF EXISTS property_type;
DROP TABLE IF EXISTS bathroom_type;
DROP TABLE IF EXISTS room_type;
DROP TABLE IF EXISTS listing_score;
DROP TABLE IF EXISTS date;
DROP TABLE IF EXISTS year;
DROP TABLE IF EXISTS month;
DROP TABLE IF EXISTS day;
DROP TABLE IF EXISTS reviewer;


-- all properties are not null unless otherwise specified!
-- all ids start in 1 
-- reviewer_id is already defined

CREATE TABLE reviewer (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reviewer_name VARCHAR(50)
);

CREATE TABLE day (
    id INT PRIMARY KEY AUTO_INCREMENT,
    day_number INT NOT NULL
);

CREATE TABLE month (
    id INT PRIMARY KEY AUTO_INCREMENT,
    month_name VARCHAR(50) NOT NULL,
    month_number INT NOT NULL
);

CREATE TABLE year (
    id INT AUTO_INCREMENT PRIMARY KEY,
    year_number INT NOT NULL
);

CREATE TABLE date (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sqlDate DATE NOT NULL,
    day_id INT NOT NULL,
    month_id INT NOT NULL,
    year_id INT NOT NULL,
    FOREIGN KEY (day_id) REFERENCES day(id),
    FOREIGN KEY (month_id) REFERENCES month(id),
    FOREIGN KEY (year_id) REFERENCES year(id)
);

CREATE TABLE listing_score (
    id INT PRIMARY KEY AUTO_INCREMENT,
    review_scores_rating INT NOT NULL,
    review_scores_accuracy INT NOT NULL,
    review_scores_cleanliness INT NOT NULL,
    review_scores_checkin INT NOT NULL,
    review_scores_communication INT NOT NULL,
    review_scores_location INT NOT NULL,
    review_scores_value INT NOT NULL,
    review_per_month FLOAT NOT NULL
);

CREATE TABLE room_type (
    id INT PRIMARY KEY AUTO_INCREMENT,
    room_type VARCHAR(50) NOT NULL
);

CREATE TABLE bathroom_type (
    id INT PRIMARY KEY AUTO_INCREMENT,
    bathroom_type VARCHAR(50) NOT NULL
);

CREATE TABLE property_type (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_type VARCHAR(50) NOT NULL
);

CREATE TABLE property (
    id INT PRIMARY KEY AUTO_INCREMENT,
    accommodates INT NOT NULL,
    bedrooms INT NOT NULL,
    beds INT NOT NULL,
    amenities TEXT NOT NULL, -- should be a list of strings
    square_feet INT NOT NULL,
    room_type_id INT NOT NULL,
    property_type_id INT NOT NULL,
    bathroom_type_id INT NOT NULL,
    FOREIGN KEY (room_type_id) REFERENCES room_type(id),
    FOREIGN KEY (property_type_id) REFERENCES property_type(id),
    FOREIGN KEY (bathroom_type_id) REFERENCES bathroom_type(id)
);

CREATE TABLE host_response (
    id INT PRIMARY KEY AUTO_INCREMENT,
    host_response_time VARCHAR(50) NOT NULL,
    host_response_rate FLOAT NOT NULL,
    host_acceptance_rate FLOAT NOT NULL
);

CREATE TABLE host_verifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    host_verifications TEXT NOT NULL -- should be a list of strings
);

CREATE TABLE host (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    host_url VARCHAR(255) NOT NULL,
    host_listing_count INT NOT NULL,
    host_total_listings_count INT NOT NULL,
    is_superhost BOOLEAN NOT NULL,
    has_profile_pic BOOLEAN NOT NULL,
    has_identity_verified BOOLEAN NOT NULL,
    host_response_id INT NOT NULL,
    host_verifications_id INT NOT NULL,
    FOREIGN KEY (host_response_id) REFERENCES host_response(id),
    FOREIGN KEY (host_verifications_id) REFERENCES host_verifications(id)
);

CREATE TABLE country (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE state (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE city (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE neighborhood (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE location (
    id INT PRIMARY KEY AUTO_INCREMENT,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    country_id INT NOT NULL,
    state_id INT NOT NULL,
    city_id INT NOT NULL,
    neighborhood_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES country(id),
    FOREIGN KEY (state_id) REFERENCES state(id),
    FOREIGN KEY (city_id) REFERENCES city(id),
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhood(id)
);

CREATE TABLE availability (
    id INT PRIMARY KEY AUTO_INCREMENT,
    availability_30 INT NOT NULL,
    availability_60 INT NOT NULL,
    availability_90 INT NOT NULL,
    availability_365 INT NOT NULL
);

CREATE TABLE listing (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    host_id INT NOT NULL,
    location_id INT NOT NULL,
    listing_score_id INT NOT NULL,
    availability_id INT NOT NULL,
    price FLOAT NOT NULL,
    FOREIGN KEY (property_id) REFERENCES property(id),
    FOREIGN KEY (host_id) REFERENCES host(id),
    FOREIGN KEY (location_id) REFERENCES location(id),
    FOREIGN KEY (listing_score_id) REFERENCES listing_score(id),
    FOREIGN KEY (availability_id) REFERENCES availability(id)
);

CREATE TABLE review (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date_id INT NOT NULL,
    property_id INT NOT NULL,
    host_id INT NOT NULL,
    listing_score INT NOT NULL,
    reviewer_id INT NOT NUll,
    review TEXT,
    FOREIGN KEY (date_id) REFERENCES date(id),
    FOREIGN KEY (property_id) REFERENCES property(id),
    FOREIGN KEY (host_id) REFERENCES host(id),
    FOREIGN KEY (listing_score) REFERENCES listing_score(id),
    FOREIGN KEY (reviewer_id) REFERENCES reviewer(id)
);
