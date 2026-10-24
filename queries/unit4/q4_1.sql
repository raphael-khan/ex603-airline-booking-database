-- Task 4.1.1: Platform-wide playback summary
-- Question: How many plays occurred, how much listening time was recorded,
-- and how many distinct listeners participated?
SELECT COUNT(*) AS total_events,
       SUM(play_duration_seconds) AS total_play_seconds,
       ROUND(AVG(play_duration_seconds), 2) AS avg_play_seconds,
       MIN(plays.play_duration_seconds) AS min_play_seconds,
       MAX(play_duration_seconds) AS max_play_seconds,
       COUNT(DISTINCT user_id) AS unique_listeners
FROM plays;

-- Task 4.1.1: Check completeness of playback durations
-- Question: How many playback events have missing duration measurements?
SELECT COUNT(*) AS total_events,
       COUNT(play_duration_seconds) AS recorded_durations,
       COUNT(*) - COUNT(play_duration_seconds) AS missing_durations
FROM plays;

-- Task 4.1.2: Playback metrics by producer
-- Question: Which songs receive the most plays, and how long are they played on average?
SELECT track_id AS producer_id,
       COUNT(*) AS total_events,
       ROUND(AVG(play_duration_seconds), 2) AS avg_play_seconds
FROM plays
GROUP BY track_id
ORDER BY total_events DESC, producer_id;

-- Task 4.1.3: Producers with at least five events
-- Question: Which songs have at least five plays and what is their average play duration?
SELECT track_id AS producer_id,
       COUNT(*) AS total_events,
       ROUND(AVG(play_duration_seconds), 2) AS avg_play_seconds
FROM plays
GROUP BY track_id
HAVING COUNT(*) >= 5
ORDER BY total_events DESC, producer_id;

-- Task 4.1.4: Two-dimensional aggregation (provisional alternative)
-- Question: How does playback activity vary by song and subscription tier?
SELECT p.track_id AS producer_id,
       l.subscription_tier,
       COUNT(*) AS total_events,
       ROUND(AVG(p.play_duration_seconds), 2) AS avg_play_seconds,
       COUNT(*) FILTER (WHERE p.play_duration_seconds IS NULL) AS missing_durations
FROM plays p
JOIN listeners l ON p.user_id = l.account_id
GROUP BY p.track_id, l.subscription_tier
ORDER BY producer_id, l.subscription_tier;
