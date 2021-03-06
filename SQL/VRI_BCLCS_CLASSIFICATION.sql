﻿--Version 2 - Only taking Non-Vegetated Land to the 2nd Level
SELECT * FROM VRI_TSA_BCLCS_CLASSES
CREATE UNIQUE INDEX IDX_VRI_TSA_BCLCS_CLASSES ON VRI_TSA_BCLCS_CLASSES(FEATURE_ID_WITH_TFL)
-------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS VRI_TSA_BCLCS_CLASSES 
CREATE TABLE VRI_TSA_BCLCS_CLASSES 
AS
--------------------------------------------
--Final Query
SELECT A.*, B.BCLCS_GROUP_ID
FROM (
SELECT 
FEATURE_ID_WITH_TFL, 
CASE
WHEN L1 = 'N' AND L2 = 'L' THEN 'Non-Vegetated Land'
WHEN L1 = 'N' AND L2 = 'W' THEN 'Non-Vegeataed Water'
WHEN L1 = 'V' THEN 'Vegetated'
ELSE 'Other'
END BCLCS_DESC,

CASE
WHEN L1 = 'N' AND L2 = 'L' THEN concat_ws('-', L1, L2)
WHEN L1 = 'N' AND L2 = 'W' THEN concat_ws('-', L1, L2)
ELSE concat_ws('-', L1, L2, L3, L4, L5)
END BCLCS_CLASS 
FROM 
(
SELECT FEATURE_ID_WITH_TFL, BCLCS_LEVEL_1 L1, BCLCS_LEVEL_2 L2, BCLCS_LEVEL_3 L3,BCLCS_LEVEL_4 L4,BCLCS_LEVEL_5 L5
FROM VRI_TSA_ATT
) SUB
) A 
LEFT JOIN 
 (
SELECT ROW_NUMBER() OVER () AS BCLCS_GROUP_ID, * FROM
(
SELECT BCLCS_DESC, BCLCS_CLASS, COUNT(*) AS TOTAL_COUNT FROM 
(
SELECT 

CASE
WHEN L1 = 'N' AND L2 = 'L' THEN 'Non-Vegetated Land'
WHEN L1 = 'N' AND L2 = 'W' THEN 'Non-Vegeataed Water'
WHEN L1 = 'V' THEN 'Vegetated'
ELSE 'Other'
END BCLCS_DESC,

CASE
WHEN L1 = 'N' AND L2 = 'L' THEN concat_ws('-', L1, L2)
WHEN L1 = 'N' AND L2 = 'W' THEN concat_ws('-', L1, L2)
ELSE concat_ws('-', L1, L2, L3, L4, L5)
END BCLCS_CLASS 
FROM 
(
SELECT BCLCS_LEVEL_1 L1, BCLCS_LEVEL_2 L2, BCLCS_LEVEL_3 L3,BCLCS_LEVEL_4 L4,BCLCS_LEVEL_5 L5
FROM VRI_TSA_ATT
) SUB
) OUTTY
GROUP BY BCLCS_DESC, BCLCS_CLASS 
ORDER BY BCLCS_DESC ASC, BCLCS_CLASS ASC
) MAIN
) B ON A.BCLCS_CLASS = B.BCLCS_CLASS
