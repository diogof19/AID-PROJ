DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS listing;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS date;
DROP TABLE IF EXISTS host;
DROP TABLE IF EXISTS property;
DROP TABLE IF EXISTS reviewer;
DROP TABLE IF EXISTS location_based_listing_statistics;


-- all properties are not null unless otherwise specified!
-- reviewer_id, host_id is already defined

CREATE TABLE reviewer (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reviewer_name VARCHAR(50)
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
    accommodates INT NOT NULL,
    bedrooms INT NOT NULL,
    beds INT NOT NULL,
    amenities TEXT NOT NULL, 
    room_type VARCHAR(50) NOT NULL,
    property_type VARCHAR(50) NOT NULL,
    bathrooms VARCHAR(50) NOT NULL
);

CREATE TABLE host (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    host_url VARCHAR(255) NOT NULL,
    host_total_listings_count INT NOT NULL,
    is_superhost BOOLEAN NOT NULL,
    has_profile_pic BOOLEAN NOT NULL,
    has_identity_verified BOOLEAN NOT NULL,
    host_response_id INT NOT NULL,
    host_response_time VARCHAR(50) NOT NULL,
    host_response_rate FLOAT NOT NULL,
    host_acceptance_rate FLOAT NOT NULL,
    host_verifications_id INT NOT NULL,
    host_verifications TEXT NOT NULL
);

CREATE TABLE location (
    id INT PRIMARY KEY AUTO_INCREMENT,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    neighbourhood_id INT NOT NULL,
    neighborhood VARCHAR(100) NOT NULL,
    city_id INT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_id INT NOT NULL,
    state VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE listing (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    host_id INT NOT NULL,
    location_id INT NOT NULL,
    price FLOAT NOT NULL,
    description TEXT,

    review_scores_rating INT NOT NULL,
    review_scores_accuracy INT NOT NULL,
    review_scores_cleanliness INT NOT NULL,
    review_scores_checkin INT NOT NULL,
    review_scores_communication INT NOT NULL,
    review_scores_location INT NOT NULL,
    review_scores_value INT NOT NULL,
    review_per_month FLOAT NOT NULL,

    availability_30 INT NOT NULL,
    availability_60 INT NOT NULL,
    availability_90 INT NOT NULL,
    availability_365 INT NOT NULL,
    review_count INT NOT NULL, -- trigger after creation review
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

CREATE TABLE location_based_listing_statistics (
    -- trigger
    id INT PRIMARY KEY AUTO_INCREMENT,
    -- quantos ids para pôr
    price_min FLOAT NOT NULL,
    price_max FLOAT NOT NULL,
    price_average FLOAT NOT NULL 
);

