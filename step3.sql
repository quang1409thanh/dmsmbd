--CREATE TABLE galaxies (
-- id NUMBER,
-- name VARCHAR2(50),
-- doc VARCHAR2(500),
-- embedding VECTOR
--);
--INSERT INTO galaxies VALUES (1, 'M31', 'Messier 31 is a barred spiral galaxy in the Andromeda constellation which has a lot of barred spiral galaxies.', '[0.26833928, 0.012467232, -0.48890606, 0.61341953, 0.5590402]');
--INSERT INTO galaxies VALUES (2, 'M33', 'Messier 33 is a spiral galaxy in the Triangulum constellation.', '[0.43291375, -0.06379729, -0.40366283, 0.77222455, 0.2219036]');
--INSERT INTO galaxies VALUES (3, 'M58', 'Messier 58 is an intermediate barred spiral galaxy in the Virgo constellation.', '[-0.07266286, 0.0802545, -0.34327424, 0.8917586, 0.27424216]');
--INSERT INTO galaxies VALUES (4, 'M63', 'Messier 63 is a spiral galaxy in the Canes Venatici constellation.', '[0.16099164, -0.28416803, -0.32071748, 0.7423811, 0.4892247]');
--INSERT INTO galaxies VALUES (5, 'M77', 'Messier 77 is a barred spiral galaxy in the Cetus constellation.', '[0.43336692, -0.20248333, -0.38971466, 0.6521541, 0.44046697]');
--INSERT INTO galaxies VALUES (6, 'M91', 'Messier 91 is a barred spiral galaxy in the Coma Berenices constellation.', '[0.41154075, 0.14537011, -0.42996794, 0.33680823, 0.7149753]');
--INSERT INTO galaxies VALUES (7, 'M49', 'Messier 49 is a giant elliptical galaxy in the Virgo constellation.', '[0.45378348, 0.37351337, -0.33156702, 0.7252909, 0.13632572]');
--INSERT INTO galaxies VALUES (8, 'M60', 'Messier 60 is an elliptical galaxy in the Virgo constellation.', '[0.124404885, 0.1522709, -0.27538168, 0.9206997, 0.19445813]');
--INSERT INTO galaxies VALUES (9, 'NGC1073', 'NGC 1073 is a barred spiral galaxy in Cetus constellation.', '[-0.11507724, -0.3145153, -0.42180404, 0.50861514, 0.67173606]');
--COMMIT;
--SELECT
-- g1.name AS galaxy_1,
-- g2.name AS galaxy_2,
-- VECTOR_DISTANCE(g2.embedding, g1.embedding) AS distance
--FROM galaxies g1, galaxies g2
--WHERE g1.id = 1
--ORDER BY distance ASC;

--SELECT
-- g1.name AS galaxy_1,
-- g2.name AS galaxy_2,
-- VECTOR_DISTANCE(g2.embedding, g1.embedding, COSINE) AS distance
--FROM galaxies g1, galaxies g2
--WHERE g1.id = 1
--ORDER BY distance ASC;

--SELECT
-- g1.name AS galaxy_1,
-- g2.name AS galaxy_2,
-- VECTOR_DISTANCE(g2.embedding, g1.embedding, DOT) AS distance
--FROM galaxies g1, galaxies g2
--WHERE g1.id = 1
--ORDER BY distance ASC;

--SELECT
-- g1.name AS galaxy_1,
-- g2.name AS galaxy_2,
-- VECTOR_DISTANCE(g2.embedding, g1.embedding, EUCLIDEAN) AS distance
--FROM galaxies g1, galaxies g2
--WHERE g1.id = 1
--ORDER BY distance ASC;
--

--SELECT
-- g1.name AS galaxy_1,
-- g2.name AS galaxy_2,
-- g2.embedding <=> g1.embedding AS distance
--FROM galaxies g1, galaxies g2
--WHERE g1.id = 1
--ORDER BY distance ASC;

SELECT
 g1.name AS galaxy_1,
 g2.name AS galaxy_2,
 g2.embedding <-> g1.embedding AS distance
FROM galaxies g1, galaxies g2
WHERE g1.id = 1
ORDER BY distance ASC;

