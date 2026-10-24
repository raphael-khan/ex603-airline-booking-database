# Unit 4 Findings — From Rows to Insight

## Task 4.1: Measure the Platform

The music-streaming dataset contains 226 playback events involving eight distinct listeners. Of these, 210 events have recorded playback durations, totaling 35,430 seconds. The average recorded duration is 168.71 seconds, with a minimum of 3 seconds and a maximum of 368 seconds. The remaining 16 events (7.08%) have missing duration measurements and are excluded from duration-based averages, although they still count as playback events. These missing values and unusually short plays merit defining a playback failure rate.

The per-producer breakdown identifies each song by its `track_id` and reports its event count and average recorded playback duration. The five-event minimum used in the `HAVING` query is an exploratory screening threshold suited to the small sample, not proof that a song's performance rate is statistically reliable. Sixteen of the 24 songs with recorded plays meet that threshold.

Aggregates hide important differences. An average listening duration conceals whether most listeners finish a song or whether a mix of very short and complete plays produces the same average. A play count conceals whether events came from many distinct listeners or repeated activity by a few.

## Task 4.2: Build the Breakdown Leadership Asked For

**Part A — Conditional aggregation.** The producer-level query answers two questions side by side: How many playback events occurred for each song, and how many of those events were classified as failures? For this exploratory analysis, a failure means a recorded playback duration shorter than 50% of the song's duration. Missing playback durations are counted separately as unknown outcomes rather than treated as successes or failures. A content operations manager should review songs with unusually high failure counts alongside their observed failure rates and event volumes.

**Part B — Subtotals and grand total.** A regional director would normally use geographic subtotals to identify where intervention is needed. The supplied music-streaming schema has no region field, so the query provides subscription-tier subtotals instead: one row for free listeners, one for premium listeners, and a platform-wide grand total labeled ALL TIERS. The tier rows support targeted investigation of listener segments; the grand total supports a platform-wide decision about whether playback abandonment warrants broader investigation. These are not geographic findings.

**Part C — Two-step baseline.** The CTE pipeline answers: Across songs with at least five playback events, what proportion of plays with recorded durations ended before half the song had played? It first aggregates counts by song, then combines only the qualifying songs to produce an event-weighted failure-rate baseline. Five events is an exploratory cutoff for this small dataset, not a statistically validated reliability threshold. The baseline should be interpreted alongside unknown outcomes, sample sizes, and the distribution of producer-level rates. The 50% failure definition and tier-as-region substitution remain provisional pending instructor clarification.

## Reflection — Conditional aggregation versus separate queries

Conditional aggregation allows us to calculate total playback events and failed playback events together while examining the same set of records. For example, one grouped summary can count every play for each producer and, at the same time, count only plays that meet the failure definition. This keeps both numbers aligned to the same population and makes it easier to calculate meaningful failure rates. It also lets us report missing durations separately without accidentally removing those events from the overall count.

An alternative would be to run one filtered query for all events and a second filtered query for failed events, then combine the results. Although this can produce the same answer, it creates extra work and more opportunities for inconsistencies. A producer with no failures might be absent from the failure-only result, requiring additional care when combining the two outputs. Separate queries can also observe different data if new events arrive between executions.

At one million rows, reducing repeated scans and avoiding extra result-merging steps can materially improve performance, especially when the analysis is refreshed frequently. Actual speed depends on indexes and the database's execution plan, so one query is not automatically faster in every situation. The main benefit is producing consistent, auditable metrics in a single grouped analysis.
