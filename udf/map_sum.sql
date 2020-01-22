/*

Return the sum of values by key in an array of map entries.

The expected schema for entries is ARRAY<STRUCT<key ANY TYPE, value ANY TYPE>>,
where the type for value must be supported by SUM, which allows numeric data types
INT64, NUMERIC, and FLOAT64.

*/
CREATE TEMP FUNCTION udf_map_sum(entries ANY TYPE) AS (
  ARRAY(SELECT AS STRUCT key, SUM(value) AS value FROM UNNEST(entries) GROUP BY key)
);

-- Tests
SELECT
  assert_array_equals(
    [STRUCT('a' AS key, 3 AS value)],
    udf_map_sum(ARRAY<STRUCT<key STRING, value INT64>>[('a', 1), ('a', 2)])
  ),
  assert_array_equals(
    [STRUCT(5 AS key, 20 AS value)],
    udf_map_sum(ARRAY<STRUCT<key INT64, value INT64>>[(5, 10), (5, 10)])
  ),
  assert_array_equals(
    udf_map_sum(
      ARRAY<STRUCT<key BOOL, value INT64>>[
        (TRUE, 1),
        (TRUE, 1),
        (TRUE, 1),
        (FALSE, NULL),
        (NULL, 1)
      ]
    ),
    ARRAY<STRUCT<key BOOL, value INT64>>[(TRUE, 3), (FALSE, NULL), (NULL, 1)]
  );
