-- Test data for Aggregations tables triggers & create_table trigger
INSERT INTO property (accommodates) VALUES
(1),
(2);

INSERT INTO host (name) VALUES
("host1"),
("host2");

INSERT INTO country (country) VALUES
("Portugal"),
("Spain");

INSERT INTO state (state, country_id) VALUES
("Porto", 1),
("Lisboa", 1),
("Barcelona", 2),
("Madrid", 2);

INSERT INTO city (city, state_id) VALUES
("Cidade Porto 1", 1),
("Cidade Porto 2", 1),
("Cidade Lisboa 1", 2),
("Cidade Lisboa 2", 2),
("Cidade Barcelona 1", 3),
("Cidade Barcelona 2", 3),
("Cidade Madrid 1", 4),
("Cidade Madrid 2", 4);

INSERT INTO neighbourhood (neighbourhood, city_id) VALUES
("Neighbourhood 1", 1),
("Neighbourhood 2", 1),
("Neighbourhood 3", 2),
("Neighbourhood 4", 2),
("Neighbourhood 5", 3),
("Neighbourhood 6", 3),
("Neighbourhood 7", 4),
("Neighbourhood 8", 4),
("Neighbourhood 9", 5),
("Neighbourhood 10", 5),
("Neighbourhood 11", 6),
("Neighbourhood 12", 6),
("Neighbourhood 13", 7),
("Neighbourhood 14", 7),
("Neighbourhood 15", 8),
("Neighbourhood 16", 8);

INSERT INTO location (latitude, longitude, neighbourhood_id) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 7, 7),
(8, 8, 8),
(9, 9, 9),
(10, 10, 10),
(11, 11, 11),
(12, 12, 12),
(13, 13, 13),
(14, 14, 14),
(15, 15, 15),
(16, 16, 16);

INSERT INTO listing (property_id, host_id, location_id, price, description) VALUES
(1, 1, 1, 5, "listing 1"),
(1, 1, 1, 10, "listing 2"),
(1, 1, 2, 15, "listing 3"),
(1, 1, 2, 20, "listing 4"),
(1, 1, 3, 25, "listing 5"),
(1, 1, 3, 30, "listing 6"),
(1, 1, 4, 35, "listing 7"),
(1, 1, 4, 40, "listing 8"),
(1, 1, 5, 45, "listing 9"),
(1, 1, 5, 50, "listing 10"),
(1, 1, 6, 55, "listing 11"),
(1, 1, 6, 60, "listing 12"),
(1, 1, 7, 65, "listing 13"),
(1, 1, 7, 70, "listing 14"),
(1, 1, 8, 75, "listing 15"),
(1, 1, 8, 80, "listing 16"),
(1, 1, 9, 85, "listing 17"),
(1, 1, 9, 90, "listing 18"),
(1, 1, 10, 95, "listing 19"),
(1, 1, 10, 100, "listing 20"),
(1, 1, 11, 105, "listing 21"),
(1, 1, 11, 110, "listing 22"),
(1, 1, 12, 115, "listing 23"),
(1, 1, 12, 120, "listing 24"),
(1, 1, 13, 125, "listing 25"),
(1, 1, 13, 130, "listing 26"),
(1, 1, 14, 135, "listing 27"),
(1, 1, 14, 140, "listing 28"),
(1, 1, 15, 145, "listing 29"),
(1, 1, 15, 150, "listing 30"),
(1, 1, 16, 155, "listing 31"),
(1, 1, 16, 160, "listing 32");

INSERT INTO reviewer (name) VALUES
("reviewer 1");

INSERT INTO date (sqlDate, day_id, day_number, month_id, month_name, month_number, year_id, year_number) VALUES 
('2023-01-01', 1, 1, 1, 'January', 1, 1, 2023);

INSERT INTO review (date_id, property_id, host_id, reviewer_id, listing_id) VALUES
(1, 1, 1, 1, 1),
(1, 1, 1, 1, 1);
