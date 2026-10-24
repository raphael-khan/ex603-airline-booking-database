-- Task 4.2A: Conditional aggregation by producer
-- Question: How many playback events and failures does each song have?
-- A failure threshold is play duration below 50% of the song length.
SELECT p.track_id AS producer_id,
       COUNT(*) AS total_events,
       SUM(CASE WHEN p.play_duration_seconds < s.duration_seconds * 0.50 THEN 1 ELSE 0 END) AS failed_events,
       SUM(CASE WHEN p.play_duration_seconds IS NULL THEN 1 ELSE 0 END) AS unknown_events,
       ROUND(100.0 * SUM(CASE WHEN p.play_duration_seconds < s.duration_seconds * 0.50 THEN 1 ELSE 0 END)
             / NULLIF(COUNT(p.play_duration_seconds), 0), 2) AS observed_failure_rate_pct
FROM plays p
JOIN songs s ON p.track_id = s.song_id
GROUP BY p.track_id
ORDER BY failed_events DESC, total_events DESC, producer_id;

-- Task 4.2B: Group subtotals and platform grand total
-- Question: How many plays and failures occur in each subscription tier and platform-wide?
-- Subscription tier substitutes for Region.
-- Note: The free and premium rows are subtotals, and ALL TIERS is the platform grand total.
SELECT CASE WHEN GROUPING(l.subscription_tier) = 1 THEN 'ALL TIERS' ELSE l.subscription_tier END AS subscription_group,
       COUNT(*) AS total_events,
       SUM(CASE WHEN p.play_duration_seconds < s.duration_seconds * 0.50 THEN 1 ELSE 0 END) AS failed_events,
       SUM(CASE WHEN p.play_duration_seconds IS NULL THEN 1 ELSE 0 END) AS unknown_events,
       ROUND(100.0 * SUM(CASE WHEN p.play_duration_seconds < s.duration_seconds * 0.50 THEN 1 ELSE 0 END)
             / NULLIF(COUNT(p.play_duration_seconds), 0), 2) AS observed_failure_rate_pct
FROM plays p
JOIN songs s ON p.track_id = s.song_id
JOIN listeners l ON p.user_id = l.account_id
GROUP BY GROUPING SETS ((l.subscription_tier), ())
ORDER BY GROUPING(l.subscription_tier), l.subscription_tier;

-- Task 4.2C: Two-step high-volume producer baseline
-- Question: What is the combined observed failure rate among songs with at least five plays?
WITH producer_performance AS (
    SELECT p.track_id AS producer_id,
           COUNT(*) AS total_events,
           COUNT(p.play_duration_seconds) AS known_events,
           SUM(CASE WHEN p.play_duration_seconds < s.duration_seconds * 0.50 THEN 1 ELSE 0 END) AS failed_events
    FROM plays p
    JOIN songs s ON p.track_id = s.song_id
    GROUP BY p.track_id
)
SELECT COUNT(*) AS high_volume_producers,
       SUM(total_events) AS total_events,
       SUM(known_events) AS known_events,
       SUM(failed_events) AS failed_events,
       ROUND(100.0 * SUM(failed_events) / NULLIF(SUM(known_events), 0), 2) AS observed_failure_rate_pct
FROM producer_performance
WHERE total_events >= 5;
